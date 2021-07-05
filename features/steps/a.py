from behave import given, then, when
from subprocess import Popen, check_call, check_output, PIPE, TimeoutExpired
import re
from signal import SIGTERM, SIGKILL


IMAGE = "logtee_test"


@given("a dockerfile stage with")
def define_dockerfile(context):
    with open("build/Dockerfile", "w") as file:
        file.write(context.text)


@given('"{process}" is started')
def start_process(context, process):

    context.process = Popen(
        [] #["docker", "run", "-v", "./features/support:/support", "--rm", "-ti", IMAGE]
        + process.split(" "), stdout=PIPE, # stdin=PIPE, shell=False, #bufsize=0
    )

    import time
    time.sleep(5)
    
    try:
        print(context.process.communicate(timeout=.5))
        context.process.wait(timeout=.5)
        #assert False
    except TimeoutExpired:
        ...
    assert context.process.returncode is None, context.process.returncode
    #assert False


@when("building the docker image")
def building_image(context):
    check_call(["docker", "build", f"--tag={IMAGE}", "build", "--quiet"])


@when('I start "{command}"')
def run(context, command):
    # TODO: how to build?
    try:
        context.output = check_output(
            ["docker", "run", "--rm", "-ti", IMAGE] + command.split(" ")
        ).decode("utf-8")
    except Exception as exception:
        context.output = exception


@when("{signal} is sent")
def send_signal(context, signal):

    import time
    time.sleep(5)
    try:
        print(context.process.communicate(input=''.encode('utf-8'), timeout=.5))
    except TimeoutExpired:
        ...
    context.process.send_signal({"sig term": SIGTERM, "sig kill": SIGKILL}[signal])


@then("the program stops")
def assert_stops(context):
    # context.process.wait()
    import time
    time.sleep(5)
    #print(context.process.stdout.read())
    try:
        print(context.process.communicate(input=''.encode('utf-8'), timeout=.5))
    except TimeoutExpired:
        ...
    print(context.process.returncode)
    print(SIGTERM)
    # TODO: output!?
    assert context.process.returncode != 0, context.process.returncode 
    #assert False


@then("there is a binary under {path}")
def check_binary(context, path):
    check_call(["docker", "run", "--rm", "-ti", IMAGE, "which", path])


@then("I get")
def assert_output(context):
    actual = context.output.strip("\n").strip("\r")
    expected = context.text.strip("\n").strip("\r")
    assert re.match(expected, actual), f"'{expected}' != '{actual}'"


@then("it fails")
def assert_exception(context):
    assert isinstance(context.output, Exception)
