variable "project_id" {
  type        = string
  description = "Google Cloud project ID for one deployment environment."
}

variable "tfc_organization" {
  type        = string
  description = "Terraform Cloud organization allowed to authenticate."
}

variable "tfc_project" {
  type        = string
  description = "Terraform Cloud project allowed to authenticate."
  default     = "rails8-todo"
}

variable "tfc_workspaces" {
  type        = set(string)
  description = "Terraform Cloud workspaces allowed to authenticate for this environment."
}
