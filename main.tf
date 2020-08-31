terraform {
  required_providers {
    grafana = {
      source = "58231/grafana"
      version = "0.0.2"
    }
  }
}
provider "grafana" {
  url  = "http://localhost:3000/"
  auth = "admin:admin"
}
