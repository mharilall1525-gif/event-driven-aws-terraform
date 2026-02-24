import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):

    for record in event['Records']:
        body = json.loads(record['body'])

        item = {
            'id': body['id'],
            'message': body['message']
        }

        table.put_item(Item=item)

    return {
        'statusCode': 200,
        'body': json.dumps('Items processed successfully')
    }