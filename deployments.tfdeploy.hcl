# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

store "varset" "aws_credentials" {
  id     = "varset-uuzUKGzuRJrZQZuW"
  category = "env"
}

deployment "development" {
  inputs = {
    cluster_name          = "stacks-demo"
    kubernetes_version    = "1.36"
    region                = "us-east-2"
    aws_access_key_id     = store.varset.aws_credentials.AWS_ACCESS_KEY_ID
    aws_secret_access_key = store.varset.aws_credentials.AWS_SECRET_ACCESS_KEY
    aws_session_token     = store.varset.aws_credentials.AWS_SESSION_TOKEN
    default_tags          = { stacks-preview-example = "eks-deferred-stack" }
  }
}
