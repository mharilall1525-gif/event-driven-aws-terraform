import json
import boto3
import os

sqs = boto3.client("sqs")
QUEUE_URL = os.environ["QUEUE_URL"]

def lambda_handler(event, context):
    body = json.loads(event["body"])

    # Basic validation
    if "id" not in body or "message" not in body:
        return {
            "statusCode": 400,
            "body": json.dumps("Invalid input")
        }

    sqs.send_message(
        QueueUrl=QUEUE_URL,
        MessageBody=json.dumps(body)
    )

    return {
        "statusCode": 200,
        "body": json.dumps("Message sent to queue")
    }