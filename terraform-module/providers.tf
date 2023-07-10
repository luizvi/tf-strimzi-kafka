# providers.tf

provider "kubernetes" {
  config_path    = "config/kubeconfig.yaml"  # Caminho para o arquivo kubeconfig
  config_context = "minikube"  # Nome do contexto a ser usado
}

# Configuração do provider do Helm
provider "helm" {
  # Configure as opções do provider do Helm aqui

  kubernetes {
    config_path    = var.kubeconfig_path  # Caminho para o arquivo kubeconfig
    config_context = var.kubeconfig_context  # Contexto do kubeconfig
  }
}
