import json
from google.cloud import storage, pubsub_v1

storage_client = storage.Client()
publisher = pubsub_v1.PublisherClient()

UPLOAD_BUCKET = "image-pipeline-uploads"
TOPIC = "projects/image-pipeline-project-485416/topics/image-processing-requests"

def upload_image(request):
    file = request.files["file"]
    blob = storage_client.bucket(UPLOAD_BUCKET).blob(file.filename)
    blob.upload_from_file(file)

    publisher.publish(TOPIC, json.dumps({
        "bucket": UPLOAD_BUCKET,
        "name": file.filename
    }).encode())

    return ("Uploaded", 202)
