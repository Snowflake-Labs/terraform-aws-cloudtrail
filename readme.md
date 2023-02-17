# Terraform AWS Cloudtrail to Snowflake Module

![A diagram depicting the journey of CloudTrail logs to a snowflake database. The diagram is split between sections, AWS Cloud and Snowflake Cloud. The diagram begins on the AWS Cloud side a, an arrow leads from Cloudtrail to S3 External Stage, then to an SQS Queue with the description “Event Notification”. An arrow leads from the SQS queue to the Snowflake Cloud section of the diagram to an icon named Snowpipe. After Snowpipe the arrow leads back to S3 External stage with a description of “triggers”. Finally the path terminates on the Snowflake Cloud side at an icon named “Snowflake DB” with a description of “copy into”.](arch.png)

This module deploys an implementation for bringing AWS Cloudtrail logs into Snowflake. It will create all resources needed for ingesting logs from an AWS S3 Bucket into a Snowflake account. 

## Disclaimer
This module takes an opinionated approach in the architecture of Snowflake resources. Customers are encouraged customize the module and to talk with their account teams for performance and cost optimization strategies.

## Contributing
Please see CONTRIBUTING.md for instructions on how to submit bug reports, feature requests and PRs.

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.3)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (~> 4.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.0)

- <a name="requirement_snowflake"></a> [snowflake](#requirement\_snowflake) (~> 0.40)

- <a name="requirement_time"></a> [time](#requirement\_time) (~> 0.9.0)

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (~> 4.0)

- <a name="provider_random"></a> [random](#provider\_random) (~> 3.0)

- <a name="provider_snowflake"></a> [snowflake](#provider\_snowflake) (~> 0.40)

- <a name="provider_time"></a> [time](#provider\_time) (~> 0.9.0)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [aws_iam_role.s3_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)
- [aws_iam_role_policy.s3_reader](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) (resource)
- [aws_s3_bucket_notification.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) (resource)
- [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) (resource)
- [snowflake_pipe.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/pipe) (resource)
- [snowflake_stage.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/stage) (resource)
- [snowflake_storage_integration.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/storage_integration) (resource)
- [snowflake_table.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/table) (resource)
- [snowflake_view.this](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/latest/docs/resources/view) (resource)
- [time_sleep.wait_for_role](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name)

Description: Name of Bucket Containing CloudTrail logs

Type: `string`

### <a name="input_database"></a> [database](#input\_database)

Description: database to work on

Type: `string`

### <a name="input_ingestion_warehouse_name"></a> [ingestion\_warehouse\_name](#input\_ingestion\_warehouse\_name)

Description: Name of warehouse to use for creating materialized view

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_create_event_notification"></a> [create\_event\_notification](#input\_create\_event\_notification)

Description: Whether or not to create an event notification on the S3 bucket, this will overwrite any existing configuration

Type: `bool`

Default: `true`

### <a name="input_prefix"></a> [prefix](#input\_prefix)

Description: Prefix in CloudTrail bucket to read from, do not include leading or tailing slashes

Type: `string`

Default: `""`

### <a name="input_schema"></a> [schema](#input\_schema)

Description: database to work on

Type: `string`

Default: `"PUBLIC"`

### <a name="input_table"></a> [table](#input\_table)

Description: table to create for raw flow logs

Type: `string`

Default: `"AWS_CLOUDTRAIL_RAW"`

### <a name="input_view"></a> [view](#input\_view)

Description: view to create

Type: `string`

Default: `"AWS_CLOUDTRAIL"`

## Outputs

No outputs.
