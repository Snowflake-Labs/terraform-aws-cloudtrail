# Copyright (c) 2023 Snowflake Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# 	http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

// Storage integration in SF
resource "snowflake_storage_integration" "this" {
  provider = snowflake

  name                      = "AWS_CLOUDTRAIL_STORAGE_INTEGRATION_${local.suffix}"
  type                      = "EXTERNAL_STAGE"
  enabled                   = true
  storage_allowed_locations = ["s3://${var.bucket_name}/${var.prefix}"]
  storage_provider          = "S3"
  storage_aws_role_arn      = "arn:aws:iam::${local.account_id}:role/${local.s3_reader_role_name}"
}

// SF external stage
resource "snowflake_stage" "this" {
  name                = local.snowflake_stage
  url                 = "s3://${var.bucket_name}/${var.prefix}"
  database            = var.database
  schema              = var.schema
  storage_integration = snowflake_storage_integration.this.name
}

// Table
resource "snowflake_table" "this" {
  change_tracking = true
  database        = var.database
  schema          = var.schema
  name            = var.table

  column {
    name     = "record"
    type     = "VARIANT"
    nullable = true
  }
}

// Wait for IAM role to be created
resource "time_sleep" "wait_for_role" {
  depends_on      = [aws_iam_role_policy.s3_reader]
  create_duration = "30s"
}

// Pipe
resource "snowflake_pipe" "this" {
  database       = var.database
  schema         = var.schema
  name           = "AWS_CLOUDTRAIL_PIPE_${local.suffix}"
  copy_statement = "copy into \"${var.database}\".\"${var.schema}\".\"${var.table}\" from @${var.database}.${var.schema}.${local.snowflake_stage} file_format = (type = json);"
  auto_ingest    = true
  depends_on = [
    snowflake_table.this,
    snowflake_stage.this,
    time_sleep.wait_for_role
  ]
}

// Non-materialized View: A materialized view might be better because of the lateral flatten but have a limitation of not being compatible with streams
resource "snowflake_view" "this" {
  database = var.database
  schema   = var.schema
  name     = var.view

  statement = <<-SQL
   select  
    VALUE:eventTime::TIMESTAMP as eventTime, 
    VALUE:eventVersion::string as eventVersion,
    VALUE:userIdentity::variant as userIdentity,
    VALUE:eventSource::string as eventSource,
    VALUE:eventName::string as eventName,
    VALUE:awsRegion::string as awsRegion,
    VALUE:sourceIPAddress::string as sourceIPAddress,
    VALUE:userAgent::string as userAgent,
    VALUE:errorCode::string as errorCode,
    VALUE:errorMessage::string as errorMessage,
    VALUE:requestParameters::variant as requestParameters,
    VALUE:responseElements::variant as responseElements,
    VALUE:additionalEventData::variant as additionalEventData,
    VALUE:requestID::string as requestID,
    VALUE:eventID::string as eventID,
    VALUE:eventType::string as eventType,
    VALUE:apiVersion::string as apiVersion,
    VALUE:managementEvent::variant as managementEvent,
    VALUE:resources::variant as resources,
    VALUE:recipientAccountId::string as recipientAccountId,
    VALUE:serviceEventDetails::variant as serviceEventDetails,
    VALUE:sharedEventID::string as sharedEventID,
    VALUE:eventCategory::string as eventCategory,
    VALUE:vpcEndpointId::string as vpcEndpointId,
    VALUE:addendum::string as addendum,
    VALUE:sessionCredentialFromConsole::string as sessionCredentialFromConsole,
    VALUE:edgeDeviceDetails::string as edgeDeviceDetails,
    VALUE:tlsDetails::variant as tlsDetails,
    VALUE:insightDetails::variant as insightDetails
  from "${var.database}"."${var.schema}"."${var.table}" , LATERAL FLATTEN(input => "record":Records);
SQL

  depends_on = [
    snowflake_table.this
  ]

}
