locals {
  bin_dir = module.setup_clis.bin_dir
  tmp_dir = "${path.cwd}/.tmp"
  ingress_subdomain = var.cluster_ingress_hostname

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
    null_resource.patchSBO
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

# Update CRDs needed

resource "null_resource" "updateCRD" {

  triggers = {
    ingress=local.ingress_subdomain
    instanceid=var.mas_instanceid

    kubeconfig = var.cluster_config_file
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/updateCRD.sh ${self.triggers.instanceid} ${self.triggers.ingress}"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

}

