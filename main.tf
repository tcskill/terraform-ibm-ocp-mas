locals {
  bin_dir = module.setup_clis.bin_dir
  tmp_dir = "${path.cwd}/.tmp"
}


module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"

  clis = ["helm"]
}

##
# Setup Preq's before MAS core
##

# Service Binding Operator

resource "null_resource" "patchSBO" {
  depends_on = [
    null_resource.deploy_catalog
  ]
  
  triggers = {
    kubeconfig = var.cluster_config_file
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/patchSBO.sh"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${path.module}/scripts/patchSBO.sh destroy"
   
    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

}

# Create/Recreate the ibm-entitlement secret

resource "null_resource" "entitlesecret" {
  depends_on = [
    null_resource.deploy_catalog

  ]

  triggers = {
    mas_namespace=var.mas_namespace
    kubeconfig = var.cluster_config_file
  }

  provisioner "local-exec" {
    command = "kubectl create secret docker-registry ibm-entitlement --docker-server=cp.icr.io --docker-username='cp' --docker-password=${var.mas_key} -n ${self.triggers.mas_namespace}"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "kubectl delete secret ibm-entitlement -n ${self.triggers.mas_namespace}"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

}

