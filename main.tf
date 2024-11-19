provider "spacelift" {}

terraform {
  required_providers {
    spacelift = {
      source = "spacelift.io/spacelift-io/spacelift"
    }
  }
}

resource random_pet suffix {
  length = 1
}

resource "spacelift_stack" "stack" {
  name       = "sp5ft-stack-${random_pet.suffix.id}"
  branch     = "main"
  raw_git {
    url = "https://github.com/truszkowski/sp5ft-example"
    namespace = "truszkowski"
  }
  project_root = "stack"
}

resource "spacelift_environment_variable" "" {
  stack_id   = spacelift_stack.stack.id
  name       = "TF_VAR_PET"
  value      = "${random_pet.suffix.id}"
  write_only = false
}
