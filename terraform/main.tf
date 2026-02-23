provider "kubernetes" {
  config_path = "~/.kube/config"
}

# --- Image Pull Secret for ECR ---
#resource "kubernetes_secret" "ecr_secret" {
#  metadata {
#    name = "ecr-secret"
#  }

#  data = {
#    ".dockerconfigjson" = base64encode(jsonencode({
#      auths = {
#        "528757815600.dkr.ecr.ap-south-1.amazonaws.com" = {
#         username = "AWS"
#          password = "eyJwYXlsb2FkIjoiTUt4enVZRWFSNUFTM2ZBNWF1K3NZYXpuR1p1YTdoN1RHejJSQ05kaDI0R3R6c1N3TCttRDAxYi9EeU5YYVllMnZERjBMeFBYTUZwWDFLSnNFdXRiV1g0OXhPYlJ3aGZDMjZiZWphWUI1ODhYM3RCbDRSc2dQTUtGc203WTZrWjJWajRub2JkL25hajdEQkFhcXJZNkNRQ0E2K2RvemFzc1dNUGNLZk9idTdmMGFqV2k1MVpoWkRxY1dMWGxDTnd2alQyV3RJOXkvRmpkR3B6OHpEYUZlbS9YSHpjQXlpWXZjNTR3dkorcnU4Y2I4dlRQdWFVeW54M3UyMW9waTd6N2FDM2dLNmZhTDh2NmZua1FFZFBBTXZhbWsrbUk1Q0p2Tk5sZHIra003R1pBWEJaVTFqU3lMZldDTUd0MXJtM2praHZFVFZTaDBCbmFlbHh0RnAvMVMrWHU1ck5VaEZUeE1oMDhDVFlRL0xzSWNYdEpMOS9RNUNETW9hZDlwSStvbC91Mkw3RDhYcUZkWjNBZ2Q2YzhrUEZzcnNzbXRCRlRwT1Q5NFB6RkVyTDBkK2JsVWJoblJyZXdiekJ2bWYvWnprYTh5Nnd0QmVCUlR3WCtxNzB0ZW9HMGI3TXg3WnVXOEd1S2Urdk5tSThGQ2Y5V2I1elJBREwwYUVxZll5VE1LOFlhTGUrYUorekdVbVVpYjVaOGNucDBjYlZNNmNZdDhTWE8xK3FJVUV2a0ZsZlZsNVlNVXpjTUVkUWRhcytNbzR5blYxNW43Q2tQRi8xY3pYZ3p5ZUtJSmxOS0ViNHMzMnEwWnU0bVBncFQrWjV2SmZDUjFEcXhoWGxRNEVFV3Z5eGQ5UnV5TElsWGgxQkJxUkxQTjd0Vkx5WkMrdU1OdWlySUVBL3pTeGVqVnZ1Vmx1czBNclF0NFcrRGtxd0FJZElka2gyaVpuSVpOWnZzbzU4MVpJMkVGdWtkSjFBdlJlY1p5dlg0NFgzZ09YOHdDcSs4aTRKMkJaVWJNS1JhQ2c3cXQzZGlCNzM3bW5pM3pVb1h2NjU4ZE55aGVlZlFLNnY4a3ZJV3M3ODB6RGhQV0NCckF3K2VPUk5mZ1lKbWNKZlNiTXRLMmg1T3NaZUFhYXVnMzFLV0pOdGN3KzVhSHNPUTdMNXNJcEc2OE1kNEQzK2JjQmR1eFg4bHZxRVpJYVdLYm93MTZVODdnSUhhTTNpT3hVRHdhR1hnL0wvRGJlUVZqZ3p1RGs0K0JQY3VVU2ZSUS8vRG9pd3piR0MrbGl2bTJ5UmplRFBWTDR1NVN6UzFsWnZsRXk2eFVYYWt2Y0JuNmxGRXJLN1d3akFYZHZwa0pBWngrUW9mdkxPYThRPT0iLCJkYXRha2V5IjoiQVFJQkFIaUhXYVlUblJVV0NibnorN0x2TUcrQVB2VEh6SGxCVVE5RnFFbVYyNkJkd3dGYUJRd2krTTJwbnJISEtsTXNHSEEzQUFBQWZqQjhCZ2txaGtpRzl3MEJCd2FnYnpCdEFnRUFNR2dHQ1NxR1NJYjNEUUVIQVRBZUJnbGdoa2dCWlFNRUFTNHdFUVFNUEk2bTc1ZHplZVkrQmVncUFnRVFnRHVmd2VsTVZLZ2dSejlFSitlaUp1YW0xaW5pVWhadFdCcHloZHBIbG54ZW1WN0ZUY25lUTI0QTBPdy95NUxHam9UTzZWUHJMaUx6ZVpSNm53PT0iLCJ2ZXJzaW9uIjoiMiIsInR5cGUiOiJEQVRBX0tFWSIsImV4cGlyYXRpb24iOjE3NzE4Nzk5NTF9"
#          email    = "none"
#        }
#      }
#    }))
#  }

#  type = "kubernetes.io/dockerconfigjson"
#}

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
