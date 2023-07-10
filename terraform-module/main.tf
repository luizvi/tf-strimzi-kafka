# Resource: Namespace
resource "kubernetes_namespace" "strimzi" {
  metadata {
    name = var.namespace_name
  }
}

# Resource: Apply Strimzi installation YAML usando o Helm
resource "helm_release" "strimzi_installation" {
  name       = "strimzi-installation"
  repository = "https://strimzi.io/charts/"

  chart    = "strimzi-kafka-operator"
  version  = "0.35.0"
  namespace = kubernetes_namespace.strimzi.metadata[0].name

  # Executa o comando curl e kubectl apply usando o Helm
  provisioner "local-exec" {
    command = "curl -L https://strimzi.io/install/latest | sed 's/namespace: .*/namespace: ${var.namespace_name}/' | kubectl apply -f - -n ${kubernetes_namespace.strimzi.metadata[0].name}"
  }

  # Mensagem de log informativa
  provisioner "local-exec" {
    command = "echo STEP 1 CHECK"
  }

  # Executa o comando kubectl apply usando o Helm
  provisioner "local-exec" {
    command = "kubectl apply -f config/my-cluster.yaml -n ${kubernetes_namespace.strimzi.metadata[0].name}"
  }

  # Mensagem de log informativa
  provisioner "local-exec" {
    command = "echo STEP 2 CHECK"
  }
}

# Resource: Run Kafka Producer Performance Test usando o kubectl
resource "null_resource" "run_producer_perf_test" {
  triggers = {
    timestamp = timestamp()
  }

  # Executa o comando para iniciar o envio de mensagens de teste do Kafka
  provisioner "local-exec" {
    command = <<EOT
      kubectl -n ${kubernetes_namespace.strimzi.metadata[0].name} run kafka-producer-perf-test \
      --image=quay.io/strimzi/kafka:0.35.1-kafka-3.4.0 \
      -- bin/kafka-producer-perf-test.sh \
      --topic my-topic \
      --throughput 1 \
      --record-size 10 \
      --num-records 10 \
      --producer-props "bootstrap.servers=my-cluster-kafka-bootstrap:9092" "key.serializer=org.apache.kafka.common.serialization.StringSerializer" "value.serializer=org.apache.kafka.common.serialization.StringSerializer"
    EOT
  }

  depends_on = [helm_release.strimzi_installation]
}

# Resource: Run Kafka Console Consumer usando o kubectl
resource "null_resource" "run_console_consumer" {
  triggers = {
    timestamp = timestamp()
  }

  # Executa o comando para validar o recebimento de mensagens de teste do Kafka
  provisioner "local-exec" {
    command = <<EOT
      kubectl -n ${kubernetes_namespace.strimzi.metadata[0].name} run kafka-console-consumer \
      --image=quay.io/strimzi/kafka:0.35.1-kafka-3.4.0 \
      --restart=OnFailure \
      -- \
      bin/kafka-console-consumer.sh \
      --bootstrap-server my-cluster-kafka-bootstrap:9092 \
      --topic my-topic \
      --from-beginning
    EOT
  }

  depends_on = [helm_release.strimzi_installation]
}
