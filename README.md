#  Serverless Image Processing Pipeline on GCP

## Overview

This project implements a **multi-stage, event-driven, serverless image processing pipeline** on **Google Cloud Platform (GCP)** using **Cloud Functions (2nd Gen), Cloud Storage, Pub/Sub, API Gateway, Secret Manager, and Terraform**.

Users upload images via a **secure API Gateway endpoint**. The image is stored, processed asynchronously (converted to grayscale), and the completion is logged — all without managing servers.

The entire infrastructure is defined using **Terraform**, ensuring reproducibility, scalability, and best DevOps practices.

---

## Architecture

### High-Level Flow

1. Client uploads an image using a **POST API request**
2. **API Gateway** validates API Key & rate limits traffic
3. **upload-image Cloud Function**

   * Stores image in GCS uploads bucket
   * Publishes message to Pub/Sub
4. **process-image Cloud Function**

   * Downloads image
   * Converts it to grayscale
   * Stores processed image in another bucket
   * Publishes completion message
5. **log-notification Cloud Function**

   * Writes structured logs to Cloud Logging

### Architecture Diagram (Textual)

```
Client
  |
  v
API Gateway (API Key + Rate Limit)
  |
  v
upload-image (HTTP Cloud Function)
  |
  +--> GCS uploads bucket
  |
  +--> Pub/Sub: image-processing-requests
             |
             v
        process-image (Pub/Sub Cloud Function)
             |
             +--> GCS processed bucket
             |
             +--> Pub/Sub: image-processing-results
                        |
                        v
                 log-notification (Cloud Function)
                        |
                        v
                 Cloud Logging
```

---

## Technologies Used

* **Google Cloud Platform (GCP)**
* **Cloud Functions (2nd Gen)**
* **Cloud Storage**
* **Cloud Pub/Sub**
* **API Gateway**
* **Secret Manager**
* **Terraform**
* **gcloud CLI**

---

## Repository Structure

```
.
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── api-gateway.tf
│   ├── iam.tf
│   ├── storage.tf
│   ├── pubsub.tf
│   └── secrets.tf
│
├── functions/
│   ├── upload-image/
│   │   ├── main.py
│   │   └── requirements.txt
│   ├── process-image/
│   │   ├── main.py
│   │   └── requirements.txt
│   └── log-notification/
│       ├── main.py
│       └── requirements.txt
│
├── submission.json
├── README.md
└── .gitignore
```

---

## Cloud Resources Created

### Storage

* **GCS Uploads Bucket** (`*-uploads`)

  * Lifecycle rule: delete objects after **7 days**
* **GCS Processed Bucket** (`*-processed`)

### Messaging

* Pub/Sub Topic: `image-processing-requests`
* Pub/Sub Topic: `image-processing-results`

### Compute

* `upload-image` – HTTP Cloud Function (2nd Gen)
* `process-image` – Pub/Sub-triggered Cloud Function
* `log-notification` – Pub/Sub-triggered Cloud Function

### Security

* Dedicated **IAM Service Account**

  * `roles/storage.objectAdmin`
  * `roles/pubsub.publisher`
  * `roles/pubsub.subscriber`
  * `roles/secretmanager.secretAccessor`
  * `roles/logging.logWriter`

### API Management

* **API Gateway**

  * API Key required
  * Rate limit: **20 requests/minute**
  * OpenAPI-based routing

### Secrets

* API Key stored securely in **Secret Manager (managed via Terraform or CLI)**

---

## Prerequisites

Before deploying, ensure you have:

* GCP Project with billing enabled
* Terraform ≥ 1.5
* gcloud CLI installed and authenticated

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

Enable required APIs:

```bash
gcloud services enable \
  cloudfunctions.googleapis.com \
  apigateway.googleapis.com \
  pubsub.googleapis.com \
  secretmanager.googleapis.com \
  storage.googleapis.com \
  artifactregistry.googleapis.com
```

---

## Deployment Instructions

### 1️⃣ Initialize Terraform

```bash
cd terraform
terraform init
```

### 2️⃣ Configure Variables

Create `terraform.tfvars`:

```hcl
project_id = "your-gcp-project-id"
region     = "us-central1"
```

### 3️⃣ Deploy Infrastructure

```bash
terraform apply
```

Confirm with `yes`.

---

## Testing the API

### Upload an Image

```bash
curl -X POST \
  -H "x-api-key: YOUR_API_KEY" \
  -F "file=@sample.jpg" \
  https://YOUR_API_GATEWAY_URL/upload-image
```

### Expected Response

```
Request accepted and image upload initiated.
```

The processed grayscale image will appear in the **processed bucket**.

---

## submission.json Format

```json
{
  "api_url": "https://YOUR_API_GATEWAY_URL/upload-image",
  "api_key": "YOUR_API_KEY"
}
```

⚠️ This file **must be present at repo root** for evaluation.

---

## Error Handling & Reliability

* Functions are **idempotent**
* Pub/Sub ensures asynchronous retries
* Logs available in **Cloud Logging**
* Upload bucket auto-cleans after 7 days
* Least-privilege IAM enforced

---

## Cost Management

* Uses GCP free-tier friendly services
* Lifecycle rules prevent storage bloat
* No always-on servers

---

## Cleanup (IMPORTANT)

To avoid charges:

```bash
terraform destroy
```

Confirm with `yes`.

---

## Key Learnings

* Event-driven serverless architecture
* Secure API Gateway configuration
* Pub/Sub-based decoupling
* Terraform best practices
* Production-grade IAM design

---

## Project Author

Santhoshi

