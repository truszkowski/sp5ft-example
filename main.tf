provider "spacelift" {}

terraform {
  required_providers {
    spacelift = {
      source = "spacelift.io/spacelift-io/spacelift"
    }
  }
}

data "spacelift_current_stack" "this" {}

variable worker_pool_id {
  type = string
}

resource random_pet pet {
  length = 2
}

output PET {
  value = random_pet.pet.id
}

resource "spacelift_stack" "stack" {
  name        = "sp5ft-stack-${random_pet.pet.id}"
  description = "This is created by ${data.spacelift_current_stack.this.id}. It has scheduled task & drift (destroy + reconcilation loop)."
  branch      = "main"
  raw_git {
    url = "https://github.com/truszkowski/sp5ft-example2"
    namespace = "truszkowski"
  }
  repository     = "sp5ft-example"
  worker_pool_id = "${var.worker_pool_id}"
  autodeploy     = true
}

resource "spacelift_stack_dependency" "dep" {
  stack_id            = spacelift_stack.stack.id
  depends_on_stack_id = data.spacelift_current_stack.this.id
}

resource "spacelift_stack_dependency_reference" "ref" {
  stack_dependency_id = spacelift_stack_dependency.dep.id
  output_name         = "PET"
  input_name          = "TF_VAR_PET"
}

resource "spacelift_drift_detection" "drift" {
  reconcile = true
  stack_id  = spacelift_stack.stack.id
  schedule  = ["1/10 * * * *"]
}

resource "spacelift_scheduled_task" "task" {
  stack_id = spacelift_stack.stack.id
  command  = "terraform destroy --auto-approve"
  every    = ["6/10 * * * *"]
}






