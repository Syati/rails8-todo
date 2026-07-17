terraform {
  required_version = ">= 1.6.0"

  cloud {
    organization = "mizuki-y"

    workspaces {
      project = "rails8-todo"
      tags    = ["rails8-todo"]
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}
