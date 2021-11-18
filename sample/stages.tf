module "cluster" {
  source = "github.com/cloud-native-toolkit/terraform-ibm-ocp-vpc?ref=v1.9.0"

  resource_group_name = var.resource_group_name
  vpc_name            = var.cluster_vpc_name
  vpc_subnet_count    = var.cluster_vpc_subnet_count
  vpc_subnets         = []
  cos_id              = ""
  name_prefix         = var.name_prefix
  region              = var.region
  ibmcloud_api_key    = var.ibmcloud_api_key
  name                = var.cluster_name
  worker_count        = var.worker_count
  ocp_version         = var.ocp_version
  exists              = var.cluster_exists
  flavor              = var.cluster_flavor
  login               = var.cluster_login
}

module "certmgr" {
  source = "github.com/cloud-native-toolkit/terraform-ocp-certmanager"

  cluster_config_file      = module.cluster.config_file_path
  cluster_type             = module.cluster.platform.type_code
  cluster_ingress_hostname = module.cluster.platform.ingress
  tls_secret_name          = module.cluster.platform.tls_secret
}

module "mongo_namespace" {
  source = "github.com/cloud-native-toolkit/terraform-k8s-namespace?ref=v3.1.2"

  cluster_config_file_path = module.cluster.config_file_path
  name                     = "mongo"
  create_operator_group    = false
}

module "mongo" {
  source = "github.com/cloud-native-toolkit/terraform-ocp-mongodb"

  cluster_config_file      = module.cluster.config_file_path
  cluster_type             = module.cluster.platform.type_code
  cluster_ingress_hostname = module.cluster.platform.ingress
  tls_secret_name          = module.cluster.platform.tls_secret
  
  mongo_namespace       = module.mongo_namespace.name
  mongo_storageclass    = "ibmc-vpc-block-5iops-tier"
}


module "sls_namespace" {
  source = "github.com/ibm-garage-cloud/terraform-cluster-namespace?ref=v3.1.2"

  cluster_config_file_path = module.cluster.config_file_path
  name                     = "ibm-sls"
  create_operator_group    = true
}

module "sls" {
  source = "github.com/tcskill/terraform-ibm-ocp-sls-test"

  cluster_config_file      = module.cluster.config_file_path
  cluster_type             = module.cluster.platform.type_code
  cluster_ingress_hostname = module.cluster.platform.ingress
  tls_secret_name          = module.cluster.platform.tls_secret
  
  sls_namespace     = module.sls_namespace.name
  sls_key           = var.mysls_key
  sls_storageClass  = "portworx-db2-rwx-sc"
  mongo_dbpass      = module.mongo.mongo_pw
  mongo_namespace   = module.mongo.mongo_namespace
  mongo_svcname     = module.mongo.mongo_servicename
  certmgr_namespace = module.certmgr.cert_namespace
}

module "masbas" {
  source = "github.com/tcskill/terraform-ibm-ocp-bas-test"

  cluster_config_file      = module.cluster.config_file_path
  cluster_type             = module.cluster.platform.type_code
  cluster_ingress_hostname = module.cluster.platform.ingress
  tls_secret_name          = module.cluster.platform.tls_secret
  
  bas_dbpassword    = var.mybas_dbpassword
  bas_grafapassword = var.mybas_grafapassword
}

module "mas_namespace" {
  source = "github.com/cloud-native-toolkit/terraform-k8s-namespace?ref=v3.1.2"

  cluster_config_file_path = module.cluster.config_file_path
  name = "mas-mas85-core"
  create_operator_group = false

}

module "mas85" {
  source = "github.com/tcskill/terraform-ibm-mas-test"

  cluster_config_file      = module.cluster.config_file_path
  cluster_type             = module.cluster.platform.type_code
  cluster_ingress_hostname = module.cluster.platform.ingress
  tls_secret_name          = module.cluster.platform.tls_secret
  
  mas_key       = var.mymas_key
  mas_namespace = module.mas_namespace.name
  
  certmgr_namespace = module.certmgr.cert_namespace
  mongo_namespace   = module.mongo_namespace.name
  bas_namespace     = module.masbas.bas_namespace
  sls_namespace     = module.certmgr.cert_namespace
}