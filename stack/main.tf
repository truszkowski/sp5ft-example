variable PET {
  type    = string
  default = "goat"
}

output PET {
  value = "${var.PET}"
}
