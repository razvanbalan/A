variable "region" {}
variable "shared_credentials_file" {}
variable "profile" {}
variable "accountId" {}
variable "stage_name" {}



provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "${var.shared_credentials_file}"
  profile                 = "${var.profile}"
}

#AWS RDS Mysql
resource "aws_db_instance" "concordia-db" {
  #depends_on             = ["aws_security_group.default"]
  identifier             = "${var.identifier}"
  allocated_storage      = "${var.storage}"
  engine                 = "${var.engine}"
  engine_version         = "${lookup(var.engine_version, var.engine)}"
  instance_class         = "${var.instance_class}"
  name                   = "${var.db_name}"
  username               = "${var.username}"
  password               = "${var.password}"
  multi_az               = "${var.multi_az}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  #final_snapshot_identifier = "${var.final_snapshot_identifier}"
  skip_final_snapshot = true
  #db_subnet_group_name   = "${aws_db_subnet_group.default.id}"
  backup_retention_period    = 5
  backup_window              = "02:16-02:46"
  maintenance_window         = "sun:04:16-sun:04:46"
  publicly_accessible        = false
}

# AWS Cognito user pool and client application used by authentication lambdas

resource "aws_cognito_user_pool" "concordia_pool" {
  name = "ConcordiaUserPool"
}

resource "aws_cognito_user_pool_client" "concordia_pool_client" {
  name = "ConcordiaPoolClient"

  user_pool_id = "${aws_cognito_user_pool.concordia_pool.id}"

  generate_secret = true
  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH"]
}

######################


# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "authentication"
  description   = "Concordia Authentication API"
}

resource "aws_api_gateway_resource" "resource" {
  path_part = "authentication"
  parent_id = "${aws_api_gateway_rest_api.api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
}

#CORS for authentication
resource "aws_api_gateway_method" "authentication_options_method" {
    rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
    resource_id   = "${aws_api_gateway_resource.resource.id}"
    http_method   = "OPTIONS"
    authorization = "NONE"
}
resource "aws_api_gateway_method_response" "authentication_options_200" {
    rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
    resource_id   = "${aws_api_gateway_resource.resource.id}"
    http_method   = "${aws_api_gateway_method.authentication_options_method.http_method}"
    status_code   = "200"
    response_models {
        "application/json" = "Empty"
    }
    response_parameters {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }
    depends_on = ["aws_api_gateway_method.authentication_options_method"]
}
resource "aws_api_gateway_integration" "authentication_options_integration" {
    rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
    resource_id   = "${aws_api_gateway_resource.resource.id}"
    http_method   = "${aws_api_gateway_method.authentication_options_method.http_method}"
    type          = "MOCK"
    passthrough_behavior = "WHEN_NO_MATCH"

    request_templates ={
      "application/json" = "{\"statusCode\": 200}"
    }
    depends_on = ["aws_api_gateway_method.authentication_options_method"]
}
resource "aws_api_gateway_integration_response" "authentication_options_integration_response" {
    rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
    resource_id   = "${aws_api_gateway_resource.resource.id}"
    http_method   = "${aws_api_gateway_method.authentication_options_method.http_method}"
    status_code   = "${aws_api_gateway_method_response.authentication_options_200.status_code}"
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }
    depends_on = ["aws_api_gateway_method_response.authentication_options_200"]
}
#################

resource "aws_api_gateway_resource" "change_password" {
  path_part = "changepassword"
  parent_id = "${aws_api_gateway_rest_api.api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
}


#CORS for change_password
resource "aws_api_gateway_method" "change_password_options_method" {
    rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
    resource_id   = "${aws_api_gateway_resource.change_password.id}"
    http_method   = "OPTIONS"
    authorization = "NONE"
}
resource "aws_api_gateway_method_response" "change_password_options_200" {
    rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
    resource_id   = "${aws_api_gateway_resource.change_password.id}"
    http_method   = "${aws_api_gateway_method.change_password_options_method.http_method}"
    status_code   = "200"
    response_models {
        "application/json" = "Empty"
    }
    response_parameters {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }
    depends_on = ["aws_api_gateway_method.change_password_options_method"]
}
resource "aws_api_gateway_integration" "change_password_options_integration" {
    rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
    resource_id   = "${aws_api_gateway_resource.change_password.id}"
    http_method   = "${aws_api_gateway_method.change_password_options_method.http_method}"
    type          = "MOCK"
    passthrough_behavior = "WHEN_NO_MATCH"

    request_templates ={
      "application/json" = "{\"statusCode\": 200}"
    }
    depends_on = ["aws_api_gateway_method.change_password_options_method"]
}
resource "aws_api_gateway_integration_response" "change_password_options_integration_response" {
    rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
    resource_id   = "${aws_api_gateway_resource.change_password.id}"
    http_method   = "${aws_api_gateway_method.change_password_options_method.http_method}"
    status_code   = "${aws_api_gateway_method_response.change_password_options_200.status_code}"
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }
    depends_on = ["aws_api_gateway_method_response.change_password_options_200"]
}
#################


resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "change_password_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.change_password.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  resource_id             = "${aws_api_gateway_resource.resource.id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.authentication.arn}/invocations"

  depends_on    = ["aws_api_gateway_method.method", "aws_lambda_function.authentication"]
}

resource "aws_api_gateway_integration" "change_password_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  resource_id             = "${aws_api_gateway_resource.change_password.id}"
  http_method             = "${aws_api_gateway_method.change_password_method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.change_password.arn}/invocations"

  depends_on    = ["aws_api_gateway_method.change_password_method", "aws_lambda_function.change_password"]
}

# API Gw authentication response 200/method integration application/json
resource "aws_api_gateway_method_response" "authentication_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }

  depends_on = ["aws_api_gateway_method.method"]
}


resource "aws_api_gateway_integration_response" "AuthIntegrationResponse" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = "${aws_api_gateway_method_response.authentication_200.status_code}"

  depends_on = ["aws_api_gateway_method_response.authentication_200"]
}


#############

# API Gw change_password response 200/method integration application/json
resource "aws_api_gateway_method_response" "change_password_200" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.change_password.id}"
  http_method = "${aws_api_gateway_method.change_password_method.http_method}"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }

  depends_on = ["aws_api_gateway_method.change_password_method"]
}

resource "aws_api_gateway_integration_response" "ChangePasswordIntegrationResponse" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.change_password.id}"
  http_method = "${aws_api_gateway_method.change_password_method.http_method}"
  status_code = "${aws_api_gateway_method_response.change_password_200.status_code}"

  # assume json default

  depends_on = ["aws_api_gateway_method_response.change_password_200"]
}
##############


# API Gw authentication/change_password deployment
resource "aws_api_gateway_deployment" "AuthenticationDeployment" {
  depends_on = ["aws_api_gateway_integration.integration","aws_api_gateway_integration.change_password_integration"]

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "${var.stage_name}"
}


# API GW Lambda integration
resource "aws_lambda_permission" "apigw_authentication_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.authentication.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}

resource "aws_lambda_permission" "apigw_change_password_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.change_password.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.change_password.path}"
}

##############


# Lambda: authentication
resource "aws_lambda_function" "authentication" {
  filename         = "authentication.zip"
  function_name    = "authentication"
  role             = "${aws_iam_role.api_role.arn}"
  handler          = "authentication.lambda_handler"
  runtime          = "python2.7"
  source_code_hash = "${base64sha256(file("authentication.zip"))}"
  
  environment {
    variables = {
      USER_POOL_ID = "${aws_cognito_user_pool.concordia_pool.id}"
	  CLIENT_ID = "${aws_cognito_user_pool_client.concordia_pool_client.id}"
	  CLIENT_SECRET = "${aws_cognito_user_pool_client.concordia_pool_client.client_secret}"
    }
  }
}

# Lambda: change_password
resource "aws_lambda_function" "change_password" {
  filename         = "change_password.zip"
  function_name    = "change_password"
  role             = "${aws_iam_role.api_role.arn}"
  handler          = "change_password.lambda_handler"
  runtime          = "python2.7"
  source_code_hash = "${base64sha256(file("change_password.zip"))}"
  
  environment {
    variables = {
      USER_POOL_ID = "${aws_cognito_user_pool.concordia_pool.id}"
	  CLIENT_ID = "${aws_cognito_user_pool_client.concordia_pool_client.id}"
	  CLIENT_SECRET = "${aws_cognito_user_pool_client.concordia_pool_client.client_secret}"
    }
  }
}



# IAM api_role is used by authentication lambdas.
data aws_iam_policy_document iam_assume_role_policy {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "apigateway.amazonaws.com",
        "ec2.amazonaws.com",
        "lambda.amazonaws.com",
        "rds.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "api_role" {
  name = "api_role"
  assume_role_policy = "${data.aws_iam_policy_document.iam_assume_role_policy.json}"
}

data "aws_iam_policy_document" "lambda_iam_role_policy_document" {
  statement {
    sid = "1"

    actions = [
      "apigateway:*",
      "ec2:*",
      "cloudwatch:*",
      "lambda:*",
      "logs:*",
      "rds:*",
      "xray:*",
      "sns:*",
	  "cognito:*",
	  "cognito-idp:*",
	  "cognito-identity:*",
	  "cognito-sync:*"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name_prefix = "concordia-iam-policy-for-lambda"
  path = "/"
  policy = "${data.aws_iam_policy_document.lambda_iam_role_policy_document.json}"
}


resource "aws_iam_role_policy_attachment" "policy_attachment" {
  policy_arn = "${aws_iam_policy.iam_policy.arn}"
  role = "${aws_iam_role.api_role.name}"
}


#AWS RDS mysql provisioning
#resource "null_resource" "setup_db" {
 # depends_on = ["aws_db_instance.concordia-db"] #wait for the db to be ready
  #provisioner "local-exec" {
   # command = "mysql -u ${aws_db_instance.concordia-db.username} -p${var.password} -h ${aws_db_instance.concordia-db.address} < concordia.sql"
  #}
#}

#####AWS Concordia infrastructure output vars
output "AuthenticationApiURL" {
  value = "${aws_api_gateway_deployment.AuthenticationDeployment.invoke_url}"
}

output "db_instance_id" {
  value = "${aws_db_instance.concordia-db.id}"
}

output "db_instance_address" {
  value = "${aws_db_instance.concordia-db.address}"
}
