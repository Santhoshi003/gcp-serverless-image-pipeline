import base64, json, io
from google.cloud import storage, pubsub_v1
from PIL import Image

storage_client = storage.Client()
publisher = pubsub_v1.PublisherClient()

OUT_BUCKET = "image-pipeline-processed"
TOPIC = "projects/image-pipeline-project-485416/topics/image-processing-results"

def process_image(event, context):
    data = json.loads(base64.b64decode(event["data"]))
    blob = storage_client.bucket(data["bucket"]).blob(data["name"])

    img = Image.open(io.BytesIO(blob.download_as_bytes())).convert("L")

    buf = io.BytesIO()
    img.save(buf, format="PNG")

    storage_client.bucket(OUT_BUCKET).blob(data["name"]).upload_from_string(buf.getvalue())

    publisher.publish(TOPIC, json.dumps({"status": "done"}).encode())
