terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# -----------------------------
# GCS BUCKETS
# -----------------------------
resource "google_storage_bucket" "uploads" {
  name     = "image-pipeline-uploads"
  location = var.region

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 7
    }
  }
}

resource "google_storage_bucket" "processed" {
  name     = "image-pipeline-processed"
  location = var.region
}

# -----------------------------
# PUBSUB TOPICS
# -----------------------------
resource "google_pubsub_topic" "requests" {
  name = "image-processing-requests"
}

resource "google_pubsub_topic" "results" {
  name = "image-processing-results"
}

# -----------------------------
# SERVICE ACCOUNT
# -----------------------------
resource "google_service_account" "functions_sa" {
  account_id   = "image-functions-sa"
  display_name = "Image Functions Service Account"
}

# -----------------------------
# IAM ROLES
# -----------------------------
resource "google_project_iam_member" "sa_roles" {
  for_each = toset([
    "roles/storage.objectAdmin",
    "roles/pubsub.publisher",
    "roles/pubsub.subscriber",
    "roles/logging.logWriter",
    "roles/secretmanager.secretAccessor"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.functions_sa.email}"
}

# -----------------------------
# SECRET MANAGER (API KEY)
# -----------------------------
resource "google_secret_manager_secret" "api_key" {
  secret_id = "api-gateway-key"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "api_key_version" {
  secret      = google_secret_manager_secret.api_key.id
  secret_data = "dummy-api-key"
}
