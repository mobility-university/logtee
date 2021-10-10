from subprocess import check_call


def before_scenario(_context, _):
    check_call(["mkdir -p build; rm -rf build/*; cp -r src build"], shell=True)


def after_scenario(context, _):
    if hasattr(context, "process"):
        context.process.terminate()
