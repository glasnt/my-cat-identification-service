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
    request_json = request.get_json(silent=True)

    if request_json and 'bucket' in request_json:
        bucket = request_json['bucket']
    if request_json and 'resource' in request_json:
        resource = request_json['resource']

    uri = f"gs://{bucket}/{resource}"

    image.source.image_uri = uri
    response = client.label_detection(image=image)
    labels = response.label_annotations
    result = ", ".join([l.description for l in labels])
    print(result)
    return result