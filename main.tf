locals {
  bin_dir = module.setup_clis.bin_dir
  tmp_dir = "${path.cwd}/.tmp"
}


module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"

  clis = ["helm"]
}

##
# Setup Preq's before MAS85 core
##


# Service Binding Operator / Catalog
resource "null_resource" "deploy_catalog" {
  triggers = {
    kubeconfig = var.cluster_config_file
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/deployCatalog.sh"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${path.module}/scripts/deployCatalog.sh destroy"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
}


# cert-manager
/*
resource "null_resource" "deploy_cert-manager" {
  triggers = {
    kubeconfig = var.cluster_config_file
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/deployCertManager.sh"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${path.module}/scripts/deployCertManager.sh destroy"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
}
*/

# BAS

# SLS





