"""Module extension for downloading non-module dependencies."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

_download_attrs = {
    "finalize-stub-aarch64-linux": {
        "name": "finalize_stub_aarch64_linux",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260622-2/finalize-stub-aarch64-linux",
        "sha256": "1e3d8c990feb48907aa79553e96f5364a8e65e6423f8d6cf36d768734e7bbb5b",
    },
    "finalize-stub-aarch64-macos": {
        "name": "finalize_stub_aarch64_macos",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260622-2/finalize-stub-aarch64-macos",
        "sha256": "3cf1726a4a399a60cabbc7d850623fc269da13b41bf693e4b98e52fd958b10d9",
    },
    "finalize-stub-aarch64-windows.exe": {
        "name": "finalize_stub_aarch64_windows",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260622-2/finalize-stub-aarch64-windows.exe",
        "sha256": "17bd27370c28207a28fd4beb2b502aeda789294aa8f11bc2c73a5dff7bc0e7c9",
    },
    "finalize-stub-s390x-linux": {
        "name": "finalize_stub_s390x_linux",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260622-2/finalize-stub-s390x-linux",
        "sha256": "dcd4deaad5158aea2bcc0e5e1a3bd4f1941d5c7debae59330a713ac8a83dee91",
    },
    "finalize-stub-x86_64-linux": {
        "name": "finalize_stub_x86_64_linux",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260622-2/finalize-stub-x86_64-linux",
        "sha256": "5f1f612f9199576aa68e952fdeca7440f44b247405159226c742161a5cb5c6ac",
    },
    "finalize-stub-x86_64-macos": {
        "name": "finalize_stub_x86_64_macos",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260622-2/finalize-stub-x86_64-macos",
        "sha256": "76853c529a7ca6eb45dd09030416f0558a92cb47371b83eae90c1ae40de8d1ba",
    },
    "finalize-stub-x86_64-windows.exe": {
        "name": "finalize_stub_x86_64_windows",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260622-2/finalize-stub-x86_64-windows.exe",
        "sha256": "769ac0f57c395de3c4a907a531a44ad1629e336493f97754b23b67063ddad6c5",
    },
    "runfiles-stub-aarch64-linux": {
        "name": "runfiles_stub_aarch64_linux",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260622-2/runfiles-stub-aarch64-linux",
        "sha256": "ec1452a1824d215d2d238aca56349de709d8e739adebcd83e319d11b2adea579",
    },
    "runfiles-stub-aarch64-macos": {
        "name": "runfiles_stub_aarch64_macos",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260622-2/runfiles-stub-aarch64-macos",
        "sha256": "d2f956e988795c4e7cda9794bb16323cc412f1ed4d82b19c2c263de64ab9b760",
    },
    "runfiles-stub-aarch64-windows.exe": {
        "name": "runfiles_stub_aarch64_windows",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260622-2/runfiles-stub-aarch64-windows.exe",
        "sha256": "785f1b91cdca26e7de33f003e54e110dab48bf96893d3bea354800c0ea30bb91",
    },
    "runfiles-stub-s390x-linux": {
        "name": "runfiles_stub_s390x_linux",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260622-2/runfiles-stub-s390x-linux",
        "sha256": "7a7517f480615f66edf637180cd56f0a102ba22c82e7748b33aae5451c9ae0a9",
    },
    "runfiles-stub-x86_64-linux": {
        "name": "runfiles_stub_x86_64_linux",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260622-2/runfiles-stub-x86_64-linux",
        "sha256": "77e533241e94e8ec09ccbc1f03f62a81fe44a14e1419785e09c9bd548a747297",
    },
    "runfiles-stub-x86_64-macos": {
        "name": "runfiles_stub_x86_64_macos",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260622-2/runfiles-stub-x86_64-macos",
        "sha256": "7478e605aafe5ea603fc2f693de75000e46ee97d64e422554d5fcb76b20c3c35",
    },
    "runfiles-stub-x86_64-windows.exe": {
        "name": "runfiles_stub_x86_64_windows",
        "url": "https://github.com/tamird/hermetic-launcher/releases/download/binaries-20260622-2/runfiles-stub-x86_64-windows.exe",
        "sha256": "376d545522d61ec94fb712c24db7b99b12bb4bbc566b4a29153e1a37479f63f8",
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
