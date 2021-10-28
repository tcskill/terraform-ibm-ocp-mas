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

/*
# cert-manager
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

/*
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

}
*/

# BAS
resource "null_resource" "deploy_bas" {
  triggers = {

    basprojectname=var.bas_projectName
    sc_archive=var.bas_storageClassArchive
    sc_db=var.bas_storageClassDB
    sc_kafka=var.bas_storageClassKafka
    sc_zookeep=var.bas_storageClassZookeeper
    bas_dbuser=var.bas_dbuser
    bas_dbpassword=var.bas_dbpassword
    bas_grafanauser=var.bas_grafanauser
    bas_grafapassword=var.bas_grafapassword
    kubeconfig = var.cluster_config_file
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/deployBAS.sh ${self.triggers.basprojectname} ${self.triggers.sc_archive} ${self.triggers.sc_db} ${self.triggers.sc_kafka} ${self.triggers.sc_zookeep} ${self.triggers.bas_dbuser} ${self.triggers.bas_dbpassword} ${self.triggers.bas_grafanauser} ${self.triggers.bas_grafapassword}"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${path.module}/scripts/destroyBAS.sh ${self.triggers.basprojectname}"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
}





# SLS

# Service Binding Operator / Catalog

/*
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

*/

