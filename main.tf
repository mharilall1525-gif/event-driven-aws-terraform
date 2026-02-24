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