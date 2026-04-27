policy {

}


resource_policy "aws_eks_cluster" "subnet_validation" {
    enforcement_level = "advisory"
    enforce {
        condition     = core::try(attrs.vpc_config[0].subnet_ids, []) != []
        error_message = "EKS cluster must be deployed in a valid VPC with subnet IDs specified"
        info_message  = "EKS cluster is deployed in a valid VPC with subnet IDs: ${core::try(attrs.vpc_config[0].subnet_ids, [])}"
    }
}

resource_policy "kubernetes_namespace_v1" "namespace_validation" {
    enforcement_level = "advisory"
    enforce {
        condition     = core::try(attrs.metadata.name, "") != "demo-ns"
        error_message = "Kubernetes namespace must have a valid name specified"
        info_message  = "Kubernetes namespace has a valid name: ${core::try(attrs.metadata[0].name, "")}"
    }
}   