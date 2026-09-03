# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
#
# Component: ./kube
# Resources:  kubernetes_namespace_v1, kubernetes_manifest
# Providers:  kubernetes (~> 2.32.0)

# ─────────────────────────────────────────────────────────────────────────────
# Policy 1 — resource_policy: kubernetes_namespace_v1
# Enforce namespace has a non-empty name in its metadata
# ─────────────────────────────────────────────────────────────────────────────
policy {
  
}

resource_policy "kubernetes_namespace_v1" "require_namespace_name" {
  enforcement_level = input.enforcement_level
  locals {
    metadata_name_ok = attrs.metadata[0].name == "deferred-demo"
  }

  enforce {
    condition     = local.metadata_name_ok
    info_message = "Require namespace name deferred-demo"
    error_message = "kubernetes_namespace_v1 must set metadata.name to deferred-demo."
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Policy 2 — provider_policy: kubernetes
# Enforce Kubernetes provider version stays in the ~> 2.32.0 range declared in kube/kube.tf
# ─────────────────────────────────────────────────────────────────────────────
provider_policy "kubernetes" "require_kubernetes_provider_version" {
  enforcement_level = input.enforcement_level
  locals {
    version                        = meta.version
    kubernetes_provider_version_ok = core::semverconstraint(local.version, ">= 2.32.0, < 3.0.0")
  }

  enforce {
    condition     = local.kubernetes_provider_version_ok
    info_message = "Require k8s provider version ${local.version}"
    error_message = "Kubernetes provider must be >= 2.32.0 and < 3.0.0. Got: ${local.version}"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Policy 3 — module_policy: ./kube
# Enforce the kube component is sourced from the local ./kube path
# ─────────────────────────────────────────────────────────────────────────────
module_policy "./kube" "kube_source_is_local" {
  enforcement_level = input.enforcement_level
  locals {
    is_local = core::try(core::regex("^\\./kube", meta.source), null) != null
  }

  enforce {
    condition     = local.is_local
    info_message =  "info - Kube component must be sourced from ./kube. Got."
    error_message = "Kube component must be sourced from ./kube. Got: ${meta.source}"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Policy 4 — resource_policy: kubernetes_manifest
# Enforce manifest metadata has a non-empty namespace
# ─────────────────────────────────────────────────────────────────────────────
resource_policy "kubernetes_manifest" "require_manifest_namespace" {
  enforcement_level = input.enforcement_level
  locals {
    manifest_namespace_ok = attrs.manifest.metadata.namespace == "demo-ns"
  }

  enforce {
    condition     = local.manifest_namespace_ok
    info_message =  "info - kubernetes_manifest must set manifest.metadata.namespace to demo-ns."
    error_message = "error -kubernetes_manifest must set manifest.metadata.namespace to demo-ns."
  }
}