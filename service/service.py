import os
import socket
import subprocess

from flask import Flask

app = Flask(__name__)
serviceOutput = "/tmp/service.out"


@app.route("/", methods=["GET"])
def get():
    if os.path.exists(serviceOutput):
        os.remove(serviceOutput)
    p = subprocess.Popen("natural madio=0 batchmode cmsynin=/service/get.cmd cmobjin=/service/get.cmd cmprint=/tmp/out natlog=err",
                         shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in p.stdout.readlines():
        print(line)
    retval = p.wait()
    print(retval)
    f = os.open(serviceOutput, "r")
    return f.read()


@app.route("/", methods=["POST"])
def post():
    if os.path.exists(serviceOutput):
        os.remove(serviceOutput)
    p = subprocess.Popen("natural madio=0 batchmode cmsynin=/service/post.cmd cmobjin=/service/post.cmd cmprint=/tmp/out natlog=err",
                         shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in p.stdout.readlines():
        print(line)
    retval = p.wait()
    print(retval)
    f = os.open(serviceOutput, "r")
    return f.read()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
