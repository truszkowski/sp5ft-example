provider "spacelift" {}

terraform {
  required_providers {
    spacelift = {
      source = "spacelift.io/spacelift-io/spacelift"
    }
  }
}

variable worker_pool_id {
  type = string
}

resource random_pet pet {
  length = 1
}

output PET {
  value = random_pet.pet.id
}

resource "spacelift_stack" "stack" {
  name       = "sp5ft-stack-${random_pet.pet.id}"
  branch     = "main"
  raw_git {
    url = "https://github.com/truszkowski/sp5ft-example"
    namespace = "truszkowski"
  }
  repository = "sp5ft-example"
  project_root = "stack"
  worker_pool_id = "${var.worker_pool_id}"
}

data "spacelift_current_stack" "this" {}

resource "spacelift_stack_dependency" "dep" {
  stack_id            = spacelift_stack.stack.id
  depends_on_stack_id = data.spacelift_current_stack.this.id
}

resource "spacelift_stack_dependency_reference" "ref" {
  stack_dependency_id = spacelift_stack_dependency.dep.id
  output_name         = "PET"
  input_name          = "TF_VAR_PET"
}
