# variables.tf

variable "namespace_name" {
  description = "Nome do namespace"
  type        = string
  default     = "strimzi"
}

variable "kubeconfig_path" {
  description = "Caminho para o arquivo kubeconfig"
  type        = string
  default = "config/kubeconfig.yaml"
}

variable "kubeconfig_context" {
  description = "Contexto do kubeconfig"
  type        = string
  default = "minikube"
}
