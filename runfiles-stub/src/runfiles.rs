// Platform-agnostic runfiles discovery and resolution. OS-specific behaviour
// (path separators, absolute-path detection, file I/O) is reached through the
// `platform` module so this logic is shared by every backend.

extern crate alloc;

use alloc::string::String;
use alloc::vec::Vec;

use crate::common::{cstr_len, Manifest};
use crate::platform;

pub struct Runfiles {
    manifest: Option<Manifest>,
    // Paths for environment variables (when export_runfiles_env is true)
    pub manifest_path: Option<String>, // RUNFILES_MANIFEST_FILE
    pub dir_path: Option<String>,      // RUNFILES_DIR and JAVA_RUNFILES
}

impl Runfiles {
    pub fn create(rt: &platform::RuntimeArgs) -> Option<Self> {
        let mut manifest = None;
        let mut manifest_path = None;
        let mut dir_path = platform::get_env_var(b"RUNFILES_DIR")
            .filter(|path| !path.is_empty() && path_exists(path));

        if let Some(env_manifest_path) = platform::get_env_var(b"RUNFILES_MANIFEST_FILE") {
            if !env_manifest_path.is_empty() {
                let mut path_with_null = Vec::from(env_manifest_path.as_bytes());
                path_with_null.push(0);

                if let Some(loaded_manifest) = platform::load_manifest(&path_with_null) {
                    if dir_path.is_none() {
                        if let Some(candidate) = runfiles_dir_from_manifest(&env_manifest_path) {
                            if path_exists(&candidate) {
                                dir_path = Some(candidate);
                            }
                        }
                    }
                    manifest = Some(loaded_manifest);
                    manifest_path = Some(env_manifest_path);
                }
            }
        }

        if manifest.is_some() || dir_path.is_some() {
            return Some(Self {
                manifest,
                manifest_path,
                dir_path,
            });
        }

        // Locate runfiles next to the launching executable:
        // <executable>.runfiles_manifest and <executable>.runfiles. The executable
        // path comes from the OS (an absolute, non-symlink-resolved launch path),
        // not from argv[0].
        if let Some(exe_path) = rt.executable_path() {
            let exe_len = cstr_len(&exe_path);
            if exe_len > 0 {
                // Convert the executable path to a string (if valid UTF-8).
                let exe_str = core::str::from_utf8(&exe_path[..exe_len]).ok()?;
                let runfiles_dir = String::from(exe_str) + ".runfiles";

                let manifest_file_path = String::from(exe_str) + ".runfiles_manifest";
                let mut manifest_path_with_null = Vec::from(manifest_file_path.as_bytes());
                manifest_path_with_null.push(0);

                let manifest = platform::load_manifest(&manifest_path_with_null);
                let dir_exists = path_exists(&runfiles_dir);
                if manifest.is_some() || dir_exists {
                    let has_manifest = manifest.is_some();
                    return Some(Self {
                        manifest,
                        manifest_path: if has_manifest {
                            Some(manifest_file_path)
                        } else {
                            None
                        },
                        dir_path: if dir_exists {
                            Some(runfiles_dir)
                        } else {
                            None
                        },
                    });
                }
            }
        }

        None
    }

    pub fn rlocation(&self, path: &str) -> Option<String> {
        // If path is absolute, don't resolve through runfiles.
        if platform::is_absolute(path) {
            return None;
        }

        if let Some(path) = self.directory_rlocation(path) {
            return Some(path);
        }
        if let Some(manifest) = &self.manifest {
            return resolve_manifest(manifest, path);
        }
        self.dir_path
            .as_ref()
            .map(|dir| join_runfiles_path(dir, path))
    }

    pub fn directory_rlocation(&self, path: &str) -> Option<String> {
        let result = join_runfiles_path(self.dir_path.as_ref()?, path);
        path_exists(&result).then_some(result)
    }

    pub fn argv0_rlocation(&self, path: &str) -> Option<String> {
        if let Some(path) = self.directory_rlocation(path) {
            return Some(path);
        }
        let dir = runfiles_dir_from_manifest(self.manifest_path.as_deref()?)?;
        Some(join_runfiles_path(&dir, path))
    }
}

fn join_runfiles_path(dir: &str, path: &str) -> String {
    let mut result = String::from(dir);
    if !result.ends_with('/') && !result.ends_with(platform::SEP) {
        result.push(platform::SEP);
    }
    result.push_str(&platform::to_native_path(path));
    result
}

fn runfiles_dir_from_manifest(path: &str) -> Option<String> {
    if path == "MANIFEST" {
        return Some(String::from("."));
    }
    if let Some(prefix) = path.strip_suffix(".runfiles_manifest") {
        return Some(String::from(prefix) + ".runfiles");
    }
    if let Some(prefix) = path.strip_suffix("/MANIFEST") {
        return Some(String::from(prefix));
    }
    path.strip_suffix("\\MANIFEST").map(String::from)
}

pub(crate) fn path_exists(path: &str) -> bool {
    platform::utf8_path_exists(path)
}

/// Maximum number of relative manifest hops to follow before giving up. Bazel
/// emits only short symlink chains (e.g. `python` -> `python3` -> `../../interp`),
/// so a small bound is plenty and also breaks any accidental cycle.
const MAX_MANIFEST_HOPS: usize = 32;

/// Resolve a runfiles-relative `path` through a manifest.
///
/// A manifest line maps a runfiles-relative key (LHS) to a target (RHS) that
/// behaves exactly like a filesystem symlink target: an absolute RHS is the final
/// location, while a relative RHS is interpreted relative to the directory of its
/// key (POSIX symlink semantics). A relative target therefore names another
/// runfiles-relative path, which may itself be another manifest entry — Bazel
/// chains venv interpreter shims this way — so we follow the chain until it lands
/// on an absolute path.
fn resolve_manifest(manifest: &Manifest, path: &str) -> Option<String> {
    let mut key = String::from(path);
    for _ in 0..MAX_MANIFEST_HOPS {
        let value = match manifest.lookup(&key) {
            Some(v) => v,
            None => {
                // Prefix match for paths within a TreeArtifact: only the directory
                // is listed, the file beneath it is not. Such directory entries are
                // always absolute, so the joined path is the final location.
                if let Some((resolved_prefix, suffix)) = manifest.prefix_lookup(&key) {
                    let mut result = String::from(resolved_prefix);
                    result.push_str(suffix);
                    return Some(platform::to_native_path(&result));
                }
                return None;
            }
        };

        // An absolute target is the final location; hand it back natively.
        if platform::is_absolute(value) {
            return Some(platform::to_native_path(value));
        }

        // A relative target is a symlink relative to the key's directory. Resolve
        // it into a new runfiles-relative key and look that up in turn.
        key = join_relative(parent_dir(&key), value)?;
    }
    None
}

/// Directory portion of a forward-slash runfiles key, without the trailing slash.
/// `"a/b/c"` -> `"a/b"`; a key with no slash -> `""` (the runfiles root).
fn parent_dir(key: &str) -> &str {
    match key.rfind('/') {
        Some(i) => &key[..i],
        None => "",
    }
}

/// Resolve a relative symlink `target` against directory `base` — both
/// forward-slash, runfiles-relative — normalizing `.` and `..` components.
/// Returns the new runfiles-relative key, or `None` if it would escape the
/// runfiles root (a malformed entry we refuse rather than follow outside the tree).
fn join_relative(base: &str, target: &str) -> Option<String> {
    let mut stack: Vec<&str> = Vec::new();
    for comp in base.split('/').chain(target.split('/')) {
        match comp {
            "" | "." => {}
            // `pop()?` fails the whole resolution if `..` reaches above the root.
            ".." => {
                stack.pop()?;
            }
            other => stack.push(other),
        }
    }
    if stack.is_empty() {
        return None;
    }
    let mut result = String::new();
    for (i, comp) in stack.iter().enumerate() {
        if i > 0 {
            result.push('/');
        }
        result.push_str(comp);
    }
    Some(result)
}
