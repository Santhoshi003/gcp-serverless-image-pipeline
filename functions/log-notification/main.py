import base64, json, logging

def log_notification(event, context):
    data = json.loads(base64.b64decode(event["data"]))
    logging.info(json.dumps(data))
