# outputs.tf

output "namespace" {
  value = kubernetes_namespace.strimzi.metadata[0].name
}
