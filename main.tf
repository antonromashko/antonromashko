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

resource "grafana_alert_notification" "email_someteam" {
  name = "Email that team"
  type = "email"
  is_default = false
}