import os
import socket
import subprocess

from flask import Flask

app = Flask(__name__)


@app.route("/", methods=["GET"])
def get():
    os.remove("/tmp/service.out")
    p = subprocess.Popen("natural madio=0 batchmode cmsynin=/service/get.cmd cmobjin=/service/get.cmd cmprint=/tmp/out natlog=err",
                         shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in p.stdout.readlines():
        print(line)
    retval = p.wait()
    print(retval)
    f = os.open("/tmp/service.out", "r")
    return f.read()


@app.route("/", methods=["POST"])
def post():
    os.remove("/tmp/service.out")
    p = subprocess.Popen("natural madio=0 batchmode cmsynin=/service/post.cmd cmobjin=/service/post.cmd cmprint=/tmp/out natlog=err",
                         shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in p.stdout.readlines():
        print(line)
    retval = p.wait()
    print(retval)
    f = os.open("/tmp/service.out", "r")
    return f.read()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
