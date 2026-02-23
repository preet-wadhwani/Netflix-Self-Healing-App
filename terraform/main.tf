provider "kubernetes" {
  config_path = "~/.kube/config"
}

# --- Deployment ---
resource "kubernetes_deployment" "self_healing_app" {
  metadata {
    name = "self-healing-app"
    labels = {
      app = "self-healing-app"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "self-healing-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "self-healing-app"
        }
      }
      spec {
        image_pull_secrets {
          name = "ecr-secret"
        }
        container {
          name  = "self-healing-app"
          image = "528757815600.dkr.ecr.ap-south-1.amazonaws.com/self-healing-app:1.0"
          port {
            container_port = 5000
          }
          resources {
            requests = {
              cpu    = "20m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = 5000
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = 5000
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
      }
    }
  }
}

# --- Service (NodePort) ---
resource "kubernetes_service" "self_healing_service" {
  metadata {
    name = "self-healing-service"
  }

  spec {
    selector = {
      app = "self-healing-app"
    }
    type = "NodePort"
    port {
      port        = 5000
      target_port = 5000
      node_port   = 30007
    }
  }
}

# --- Horizontal Pod Autoscaler ---
resource "kubernetes_horizontal_pod_autoscaler_v2" "self_healing_hpa" {
  metadata {
    name = "self-healing-hpa"
  }

  spec {
    scale_target_ref {
      kind       = "Deployment"
      name       = kubernetes_deployment.self_healing_app.metadata[0].name
      api_version = "apps/v1"
    }
    min_replicas = 2
    max_replicas = 10
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 60
        }
      }
    }
  }
}

# --- ServiceMonitor for Prometheus ---
resource "kubernetes_manifest" "self_healing_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name   = "self-healing-monitor"
      namespace = "default"
      labels = {
        release = "monitoring"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          app = "self-healing-app"
        }
      }
      endpoints = [
        {
          port     = "http"
          path     = "/metrics"
          interval = "15s"
        }
      ]
    }
  }
}
