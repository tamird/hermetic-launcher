"""Module extension for downloading non-module dependencies."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

_download_attrs = {
    "finalize-stub-aarch64-linux": {
        "name": "finalize_stub_aarch64_linux",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260623/finalize-stub-aarch64-linux",
        "sha256": "1e3d8c990feb48907aa79553e96f5364a8e65e6423f8d6cf36d768734e7bbb5b",
    },
    "finalize-stub-aarch64-macos": {
        "name": "finalize_stub_aarch64_macos",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260623/finalize-stub-aarch64-macos",
        "sha256": "3cf1726a4a399a60cabbc7d850623fc269da13b41bf693e4b98e52fd958b10d9",
    },
    "finalize-stub-aarch64-windows.exe": {
        "name": "finalize_stub_aarch64_windows",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260623/finalize-stub-aarch64-windows.exe",
        "sha256": "4f759790911bfdcd92d572910d9079d94f87dbb2f3bee3a7a75ba2b3ad1e369f",
    },
    "finalize-stub-s390x-linux": {
        "name": "finalize_stub_s390x_linux",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260623/finalize-stub-s390x-linux",
        "sha256": "dcd4deaad5158aea2bcc0e5e1a3bd4f1941d5c7debae59330a713ac8a83dee91",
    },
    "finalize-stub-x86_64-linux": {
        "name": "finalize_stub_x86_64_linux",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260623/finalize-stub-x86_64-linux",
        "sha256": "5f1f612f9199576aa68e952fdeca7440f44b247405159226c742161a5cb5c6ac",
    },
    "finalize-stub-x86_64-macos": {
        "name": "finalize_stub_x86_64_macos",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260623/finalize-stub-x86_64-macos",
        "sha256": "76853c529a7ca6eb45dd09030416f0558a92cb47371b83eae90c1ae40de8d1ba",
    },
    "finalize-stub-x86_64-windows.exe": {
        "name": "finalize_stub_x86_64_windows",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260623/finalize-stub-x86_64-windows.exe",
        "sha256": "a3e4f2cef1f2f8667c630e6d65423743ec74cf3578cdc8e292be6b6e39e6ab34",
    },
    "runfiles-stub-aarch64-linux": {
        "name": "runfiles_stub_aarch64_linux",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260623/runfiles-stub-aarch64-linux",
        "sha256": "46bbfae94bd4b00ce2cf45cd629012f8246cc2bfc391e87b0836e5408627e58a",
    },
    "runfiles-stub-aarch64-macos": {
        "name": "runfiles_stub_aarch64_macos",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260623/runfiles-stub-aarch64-macos",
        "sha256": "9993a147338e39a294ce7fe0a6ca552b00ae734f2d52d6c08c217e20c20cf442",
    },
    "runfiles-stub-aarch64-windows.exe": {
        "name": "runfiles_stub_aarch64_windows",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260623/runfiles-stub-aarch64-windows.exe",
        "sha256": "2aef2163661e0c05acab44f8ff621d050390678bdfcefb312666404d5b83fc51",
    },
    "runfiles-stub-s390x-linux": {
        "name": "runfiles_stub_s390x_linux",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260623/runfiles-stub-s390x-linux",
        "sha256": "95727161b2217672f46770d1d72efe4badbd8cc56209443891dfecaa8490a438",
    },
    "runfiles-stub-x86_64-linux": {
        "name": "runfiles_stub_x86_64_linux",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260623/runfiles-stub-x86_64-linux",
        "sha256": "c2e0b0cb13bd6bb3b5b1f306a2f9571f2b87c51616d38e6ce7a8499e2f6067d2",
    },
    "runfiles-stub-x86_64-macos": {
        "name": "runfiles_stub_x86_64_macos",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260623/runfiles-stub-x86_64-macos",
        "sha256": "51cb173b853563f14aea331d7189caf6f7fd5486ce911b6528da0cace37024c7",
    },
    "runfiles-stub-x86_64-windows.exe": {
        "name": "runfiles_stub_x86_64_windows",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260623/runfiles-stub-x86_64-windows.exe",
        "sha256": "d7dd9fcca8d36aae3e801b3d17ac83c439799208f7829857876ea0f5b4b8c71b",
    },
}

def _non_module_dependencies_impl(ctx):
    for filename, attrs in _download_attrs.items():
        http_file(
            name = attrs["name"],
            url = attrs["url"],
            sha256 = attrs["sha256"],
            downloaded_file_path = filename,
            executable = True,
        )
    return ctx.extension_metadata(
        root_module_direct_deps = "all",
        root_module_direct_dev_deps = [],
        reproducible = True,
    )


non_module_dependencies = module_extension(
    implementation = _non_module_dependencies_impl,
)
