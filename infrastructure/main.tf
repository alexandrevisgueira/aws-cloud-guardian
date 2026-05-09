provider "aws" {
  region = "us-east-1"
}

resource "random_id" "bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "log_storage" {
  bucket        = "aws-cloud-guardian-logs-${random_id.bucket_id.hex}"
  force_destroy = true
}

resource "aws_s3_bucket" "lambda_code_bucket" {
  bucket        = "aws-cloud-guardian-code-${random_id.bucket_id.hex}"
  force_destroy = true
}

resource "aws_s3_object" "lambda_code" {
  bucket      = aws_s3_bucket.lambda_code_bucket.id
  key         = "lambda_function.zip"
  source      = "lambda_function.zip"
  source_hash = filebase64sha256("lambda_function.zip")
}

resource "aws_iam_role" "lambda_role" {
  name = "aws-cloud-guardian-lambda-role"

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

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/aws-cloud-guardian-processor"
  retention_in_days = 7
}

resource "aws_lambda_function" "processor" {
  function_name = "aws-cloud-guardian-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "processor.lambda_handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 256

  s3_bucket        = aws_s3_bucket.lambda_code_bucket.id
  s3_key           = aws_s3_object.lambda_code.key
  source_code_hash = aws_s3_object.lambda_code.source_hash

  environment {
    variables = {
      WEBHOOK_URL = "${aws_apigatewayv2_api.webhook_api.api_endpoint}/webhook"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_logs
  ]
}

resource "aws_apigatewayv2_api" "webhook_api" {
  name          = "gemini-webhook-gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.webhook_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.webhook_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.processor.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "webhook_route" {
  api_id    = aws_apigatewayv2_api.webhook_api.id
  route_key = "POST /webhook"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.webhook_api.execution_arn}/*/*"
}

output "webhook_url" {
  description = "URL pública do webhook HTTP via API Gateway"
  value       = "${aws_apigatewayv2_api.webhook_api.api_endpoint}/webhook"
}