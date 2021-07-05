from behave import given, then, when
from subprocess import run, Popen, check_call, check_output, PIPE, TimeoutExpired
import re
from signal import SIGTERM, SIGKILL


IMAGE = "logtee_test"


@given("a dockerfile stage with")
def define_dockerfile(context):
    with open("build/Dockerfile", "w") as file:
        file.write(context.text)


@given('"{process}" is started')
def start_process(context, process):

    context.process = Popen(process.split(" "), stdout=PIPE)
    try:
        context.process.wait(timeout=0.5)
    except TimeoutExpired:
        ...
    assert context.process.returncode is None, context.process.returncode


@given("a customized logging filter is configured like")
def write_customized_logging(context):
    with open("build/log_filter", "w") as file:
        file.write(context.text)


@when("building the docker image")
def building_image(context):
    context.output = run(
        ["docker", "build", f"--tag={IMAGE}", "--quiet", "build"], capture_output=True
    )


@when('I start "{command}"')
def run_command(context, command):
    try:
        context.output = check_output(command.split(" ")).decode("utf-8")
    except Exception as exception:
        context.output = exception


@when("{signal} is sent")
def send_signal(context, signal):
    context.process.send_signal({"sig term": SIGTERM, "sig kill": SIGKILL}[signal])


@then("the program stops")
def assert_stops(context):
    try:
        print(context.process.communicate(input="".encode("utf-8"), timeout=0.5))
    except TimeoutExpired:
        ...
    assert context.process.returncode != 0, context.process.returncode


@then("there is a binary under {path}")
def check_binary(context, path):
    check_call(["docker", "run", "--rm", "-ti", IMAGE, "which", path])


@then("I get")
def assert_output(context):
    actual = context.output.strip("\n").strip("\r")
    expected = context.text.strip("\n").strip("\r")
    assert re.match(expected, actual), f"'{expected}' != '{actual}'"


@then("the following gets forwarded")
def assert_forward_output(context):
    with open('build/log_filter.out', 'r') as file:
        actual = file.read().strip("\n").strip("\r")
    expected = context.text.strip("\n").strip("\r")
    assert re.match(expected, actual), f"'{expected}' != '{actual}'"


@then("it fails")
def assert_exception(context):
    assert isinstance(context.output, Exception)


@then("it fails with")
def assert_fails_with(context):
    assert context.output.returncode != 0
    assert context.text in context.output.stderr.decode("utf-8")
