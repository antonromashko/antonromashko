variable "description" {
    type = string
}

resource "null_resource" "add_annotation5" {
  provisioner "local-exec" {
    command = "python3 main.py $TAGS $DESCRIPTION"
    environment = {
      TAGS = "0"
      DESCRIPTION = var.description
    }
  }
}
