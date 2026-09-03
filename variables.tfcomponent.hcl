# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "region" {
  type = string
}

variable "identity_token" {
  description = "Identity token for authentication."
  type        = string
  ephemeral   = true
}

variable "role_arn" {
  description = "ARN of role associated with identity token."
  type        = string
}

variable "default_tags" {
  description = "A map of default tags to apply to all AWS resources"
  type        = map(string)
  default     = {}
}
