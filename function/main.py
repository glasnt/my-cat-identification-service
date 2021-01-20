from flask import escape

from google.cloud import vision
client = vision.ImageAnnotatorClient()
image = vision.Image()

def detect_cat(request):
    """
    param:
      bucket: gcs bucket
      resource: gcs bucket resource

    returns:
      information about the image

    Testing data: {"bucket": "glasnt-terraform-3476-test", "resource": "loan-7AIDE8PrvA0-unsplash.jpg"}

    """
    print("ARGS", request.args)

    if 'bucket' in request.args:
        bucket = request.args['bucket']
    if 'resource' in request.args:
        resource = request.args['resource']

    if not resource and not bucket:
      return "Invalid invocation", 400

    uri = f"gs://{bucket}/{resource}"

    image.source.image_uri = uri
    response = client.label_detection(image=image)
    labels = response.label_annotations
    result = ", ".join([l.description for l in labels])
    print(result)
    return result