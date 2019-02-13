from flask import Flask

import os
import socket
import subprocess

app = Flask(__name__)

@app.route("/")
def service():
    p = subprocess.Popen("natural stack=\"logon main;hello;fin\")", shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in p.stdout.readlines():
        print(line)
    retval = p.wait()
    print(retval)
    f = open("/tmp/test.out", "r")
    return f.read()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
