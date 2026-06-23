load("@hermetic_launcher//launcher:lib.bzl", "launcher")

def _starlark_fallback_impl(ctx):
    embedded_args = []
    transformed_args = []
    embedded_args, transformed_args = launcher.append_raw_transformed_arg(
        arg = "_main/missing-fallback-primary",
        embedded_args = embedded_args,
        transformed_args = transformed_args,
    )
    launcher.compile_stub(
        ctx = ctx,
        embedded_args = embedded_args,
        executable_relative_fallbacks = {0: ctx.attr.fallback_path},
        output_file = ctx.outputs.executable,
        transformed_args = transformed_args,
    )
    return DefaultInfo(
        executable = ctx.outputs.executable,
        runfiles = ctx.runfiles(
            transitive_files = ctx.attr.data[DefaultInfo].files,
        ),
    )

starlark_fallback = rule(
    implementation = _starlark_fallback_impl,
    attrs = {
        "data": attr.label(mandatory = True),
        "fallback_path": attr.string(mandatory = True),
    },
    executable = True,
    toolchains = [
        launcher.finalizer_toolchain_type,
        launcher.template_toolchain_type,
    ],
)
