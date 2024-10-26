resource "minio_iam_user" bucket_owner {
  for_each = toset(local.buckets)
  name = each.value
  force_destroy = false
  secret = local.secrets[each.value]
}

resource "minio_s3_bucket" bucket {
  for_each = toset(local.buckets)
  bucket = each.value
  acl    = "private"
}

resource "minio_iam_policy" access_policy {
  for_each = toset(local.buckets)
  name = each.value
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Sid":"BackupAccessPolicy",
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::${each.value}/*"
    }
  ]
}
EOF
}

resource "minio_iam_user_policy_attachment" access {
  for_each = toset(local.buckets)
  user_name   = minio_iam_user.bucket_owner[each.value].id
  policy_name = minio_iam_policy.access_policy[each.value].id
}
