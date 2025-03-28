provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = var.clusterName
}

resource "aws_cloudwatch_log_group" "eks_log_group" {
  name = "/aws/eks/${local.cluster_name}/cluster"

  retention_in_days = 30  # Adjust as needed

  lifecycle {
    ignore_changes = [name]  # Prevent unnecessary changes
  }
}

# Import existing CloudWatch log group if it already exists
resource "null_resource" "import_log_group" {
  provisioner "local-exec" {
    command = <<EOT
      if aws logs describe-log-groups --log-group-name-prefix "/aws/eks/${local.cluster_name}/cluster" --region ${var.region} | grep logGroupName; then
        echo "Log Group Exists, Importing..."
        terraform import aws_cloudwatch_log_group.eks_log_group "/aws/eks/${local.cluster_name}/cluster" || echo "Already Managed"
      else
        echo "Log Group Does Not Exist, Creating..."
      fi
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}
