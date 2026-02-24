##################################
# DynamoDB Table
##################################

resource "aws_dynamodb_table" "messages" {
  name         = "messages-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

##################################
# IAM Role for Lambda
##################################

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

##################################
# Attach Basic Lambda Logging Policy
##################################

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

##################################
# DynamoDB Permission for Lambda
##################################

resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "lambda-dynamodb-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["dynamodb:PutItem"]
      Resource = aws_dynamodb_table.messages.arn
    }]
  })
}

##################################
# SQS Permissions for Lambda
##################################

resource "aws_iam_role_policy" "lambda_sqs_policy" {
  name = "lambda-sqs-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ]
      Resource = aws_sqs_queue.event_queue.arn
    }]
  })
}

##################################
# Lambda Function
##################################

resource "aws_lambda_function" "app_lambda" {
  function_name = "app-lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.9"

  filename         = "lambda/function.zip"
  source_code_hash = filebase64sha256("lambda/function.zip")

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.messages.name
    }
  }
}

##################################
# Dead Letter Queue
##################################

resource "aws_sqs_queue" "dlq" {
  name = "event-dlq"
}

##################################
# Main Queue
##################################

resource "aws_sqs_queue" "event_queue" {
  name = "event-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })
}

##################################
# SQS Event Source Mapping
##################################

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.event_queue.arn
  function_name = aws_lambda_function.app_lambda.arn
  batch_size       = 1
}

##################################
# Allow Lambda to Send to SQS
##################################

resource "aws_iam_role_policy" "lambda_sqs_send_policy" {
  name = "lambda-sqs-send-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["sqs:SendMessage"]
      Resource = aws_sqs_queue.event_queue.arn
    }]
  })
}

##################################
# Ingest Lambda
##################################

resource "aws_lambda_function" "ingest_lambda" {
  function_name = "ingest-lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.9"

  filename         = "lambda_ingestion/function.zip"
  source_code_hash = filebase64sha256("lambda_ingestion/function.zip")

  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.event_queue.id
    }
  }
}

##################################
# HTTP API Gateway
##################################

resource "aws_apigatewayv2_api" "http_api" {
  name          = "event-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.ingest_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "post_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /message"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingest_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}