# Copyright (c) 2023 Snowflake Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# 	http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable "bucket_name" {
  description = "Name of Bucket Containing CloudTrail logs"
  type        = string
}

variable "prefix" {
  description = "Prefix in CloudTrail bucket to read from, do not include leading or tailing slashes"
  type        = string
  default     = ""
}

variable "database" {
  description = "database to work on"
  type        = string
}

variable "schema" {
  description = "database to work on"
  default     = "PUBLIC"
  type        = string
}

variable "table" {
  description = "table to create for raw flow logs"
  default     = "AWS_CLOUDTRAIL_RAW"
  type        = string
}

variable "view" {
  description = "view to create"
  default     = "AWS_CLOUDTRAIL"
  type        = string
}

variable "create_event_notification" {
  type        = bool
  description = "Whether or not to create an event notification on the S3 bucket, this will overwrite any existing configuration"
  default     = true
}

variable "ingestion_warehouse_name" {
  type        = string
  description = "Name of warehouse to use for creating materialized view"
}
