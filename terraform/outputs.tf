output "uploads_bucket" {
  value = google_storage_bucket.uploads.name
}

output "processed_bucket" {
  value = google_storage_bucket.processed.name
}
