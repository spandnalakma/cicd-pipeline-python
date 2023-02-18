from flask import Flask


flask_app= Flask(__name__)


@flask_app.route("/", methods=['GET'])
def health_check():
    return "health check"


if __name__== "__main__":
    flask_app.run()