import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    body = json.loads(event['body'])

    item = {
        'id': body['id'],
        'message': body['message']
    }

    table.put_item(Item=item)

    return {
        'statusCode': 200,
        'body': json.dumps('Item stored successfully')
    }