from flask import Flask,render_template
#import socket
import os

app = Flask(__name__)

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def index(path):
    try:
        #host_name = socket.gethostname()
        #host_ip = socket.gethostbyname(host_name)
        return render_template('index.html', path=path, ip=os.environ.get("HOST_IP"))
    except:
        return render_template('error.html')


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=7777)
