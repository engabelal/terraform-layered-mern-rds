#!/usr/bin/env bash
set -e
export AWS_PAGER="" # Disable AWS CLI paging
# ====== Configuration ======
REGION="eu-north-1"
BUCKET_NAME="terraform-layered-mern-rds-state"

echo "🧱 Terraform Remote State S3 Setup"
echo "----------------------------------"
echo "Bucket: $BUCKET_NAME"
echo "Region: $REGION"
echo

# ====== Check if bucket exists ======
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo "✅ Bucket already exists: $BUCKET_NAME"
else
  echo "🚀 Creating S3 bucket: $BUCKET_NAME ..."
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"
  echo "✅ Bucket created."
fi

# ====== Enable versioning if not already enabled ======
VERSIONING_STATUS=$(aws s3api get-bucket-versioning --bucket "$BUCKET_NAME" --query 'Status' --output text || echo "Disabled")
if [ "$VERSIONING_STATUS" = "Enabled" ]; then
  echo "🔄 Versioning already enabled."
else
  echo "🔧 Enabling versioning..."
  aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled
  echo "✅ Versioning enabled."
fi

# ====== Enable Object Lock (Governance mode, 1-day retention) ======
LOCK_STATUS=$(aws s3api get-object-lock-configuration --bucket "$BUCKET_NAME" --query 'ObjectLockConfiguration.ObjectLockEnabled' --output text 2>/dev/null || echo "None")

if [ "$LOCK_STATUS" = "Enabled" ]; then
  echo "🔐 Object Lock already enabled."
else
  echo "🔐 Enabling Object Lock (Governance mode, 1-day retention)..."
  aws s3api put-object-lock-configuration \
    --bucket "$BUCKET_NAME" \
    --object-lock-configuration "ObjectLockEnabled=Enabled,Rule={DefaultRetention={Mode=GOVERNANCE,Days=1}}"
  echo "✅ Object Lock enabled."
fi

# ====== Summary ======
echo
echo "----------------------------------"
echo "✅ S3 backend setup completed successfully!"
echo "Bucket: $BUCKET_NAME"
echo "Region: $REGION"
echo "Versioning: Enabled"
echo "Object Lock: Enabled (Governance, 1-day retention)"
echo "----------------------------------"
