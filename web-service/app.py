import os
import urllib3
import flask
from google.cloud import storage
import tempfile

BUCKET_NAME = os.environ.get("BUCKET_NAME")
FUNCTION_NAME = os.environ.get("FUNCTION_NAME")

app = flask.Flask(__name__)
storage = storage.Client()
bucket = storage.bucket(BUCKET_NAME)


@app.route("/cat/<img>")
def cat(img):
    blob = bucket.blob(img)
    with tempfile.NamedTemporaryFile() as temp:
        blob.download_to_filename(temp.name)
        return flask.send_file(temp.name, attachment_filename=img)

def get_cats(bucket):
    images = storage.list_blobs(BUCKET_NAME)
    http = urllib3.PoolManager()
    
    cats = []
    for img in images:
        r = http.request("GET", FUNCTION_NAME, headers={"Content-Type", "application/json"}, data={"name": "cat"})
        cats.append({"image": img, "data": r.data})
    
    return cats


@app.route("/")
def hello_cats():
    if not BUCKET_NAME:
        return flask.render_template_string(
            "<h1>I have no cats.</h1>BUCKET_NAME environment variable required."
        )

    cats = get_cats(BUCKET_NAME)
    return flask.render_template("cats.html", cats=cats)


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
