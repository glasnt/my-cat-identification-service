import os

import flask
from google.cloud import storage
import tempfile

BUCKET_NAME = os.environ.get("BUCKET_NAME")
app = flask.Flask(__name__)
storage = storage.Client()
bucket = storage.bucket(BUCKET_NAME)


@app.route("/cat/<img>")
def cat(img):
    blob = bucket.blob(img)
    with tempfile.NamedTemporaryFile() as temp:
        blob.download_to_filename(temp.name)
        return flask.send_file(temp.name, attachment_filename=img)


@app.route("/")
def hello_cats():
    if not BUCKET_NAME:
        return flask.render_template_string(
            "<h1>I have no cats.</h1>BUCKET_NAME environment variable required."
        )

    cats = storage.list_blobs(BUCKET_NAME)
    return flask.render_template("cats.html", cats=cats)


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
