# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
#
# Component: ./cluster
# Resources:  aws_eks_cluster, aws_eks_node_group, aws_vpc, aws_subnet, aws_iam_role
# Providers:  aws (~> 5.59.0), random (~> 3.6.2)

# ─────────────────────────────────────────────────────────────────────────────
# Policy 1 — resource_policy: aws_eks_cluster
# Enforce Kubernetes version is >= 1.29.0
# ─────────────────────────────────────────────────────────────────────────────
resource_policy "aws_eks_cluster" "require_kubernetes_version" {
  enforcement_level = "advisory"
  locals {
    version                = core::try(attrs.version, "")
    kubernetes_version_ok  = core::try(core::semverconstraint(local.version, "< 1.29.0"), false)
  }

  enforce {
    condition     = local.kubernetes_version_ok
    info_message = "Require aws k8s version ${local.version}"
    error_message = "EKS cluster must run Kubernetes >= 1.29.0. Got: ${local.version}"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Policy 2 — provider_policy: aws
# Enforce AWS provider version stays in the ~> 5.59.0 range declared in cluster/main.tf
# ─────────────────────────────────────────────────────────────────────────────
provider_policy "aws" "require_aws_provider_version" {
  enforcement_level = "advisory"
  locals {
    version                 = core::try(meta.version, "")
    aws_provider_version_ok = core::try(core::semverconstraint(local.version, "!= 5.59.0"), false)
  }

  enforce {
    condition     = local.aws_provider_version_ok
    info_message = "Require aws version ${local.version}"
    error_message = "AWS provider must be >= 5.59.0 and < 6.0.0. Got: ${local.version}"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Policy 3 — module_policy: ./cluster
# Enforce the cluster component is sourced from the local ./cluster path
# ─────────────────────────────────────────────────────────────────────────────
module_policy "./cluster" "cluster_source_is_local" {
  locals {
    is_local = core::try(core::regex("^\\./cluster", meta.source), null) != null
  }

  enforce {
    condition     = local.is_local
    error_message = "Cluster component must be sourced from ./cluster. Got: ${meta.source}"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Policy 4 — resource_policy: aws_vpc
# Enforce the demo VPC has DNS support enabled
# ─────────────────────────────────────────────────────────────────────────────
resource_policy "aws_vpc" "require_dns_support" {
  enforcement_level = "advisory"
  locals {
    dns_support_raw = core::try(attrs.enable_dns_support, null)
    dns_support     = local.dns_support_raw == null ? false : local.dns_support_raw
  }

  enforce {
    condition     = local.dns_support
    error_message = "aws_vpc must enable DNS support."
  }
}