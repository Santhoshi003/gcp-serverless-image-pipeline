resource "google_api_gateway_api" "image_api" {
  provider = google-beta
  api_id   = "image-upload-api"
}

resource "google_api_gateway_api_config" "image_api_config" {
  provider      = google-beta
  api           = google_api_gateway_api.image_api.api_id
  api_config_id = "v1"

  openapi_documents {
    document {
      path     = "openapi.yaml"
      contents = filebase64("${path.module}/openapi.yaml")
    }
  }
}

resource "google_api_gateway_gateway" "image_gateway" {
  provider   = google-beta
  gateway_id = "image-upload-gateway"
  api_config = google_api_gateway_api_config.image_api_config.id
  region     = var.region
}
