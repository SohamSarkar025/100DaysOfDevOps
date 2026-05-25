variable "example_var" {
  description = "An example input variable"
  type        = string
  default     = "default_value"
}

resource "example_resource" "example" {
  name = var.example_var
  # other resource configurations
}

output "example_output" {
  description = "An example output variable"
  value       = resource.example_resource.example.id
}

output "root_output" {
  value = module.example_module.example_output
}
