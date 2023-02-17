# Copyright (c) 2023 Snowflake Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# 	http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



resource "aws_iam_role" "s3_reader" {
  name = local.s3_reader_role_name
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = snowflake_storage_integration.this.storage_aws_iam_user_arn
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = snowflake_storage_integration.this.storage_aws_external_id
          }
        }
      }
    ]
  })
}


resource "aws_iam_role_policy" "s3_reader" {
  name = local.s3_bucket_policy_name
  role = aws_iam_role.s3_reader.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ],
        "Resource" : "arn:aws:s3:::${var.bucket_name}/${var.prefix}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource" : "arn:aws:s3:::${var.bucket_name}"
      }
    ]
  })
}


// Event notification
resource "aws_s3_bucket_notification" "this" {
  count  = var.create_event_notification ? 1 : 0
  bucket = var.bucket_name


  queue {
    queue_arn     = snowflake_pipe.this.notification_channel
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = var.prefix
  }
}
