# Create Layer Module

Terraform module to programmatically create lambda layers

## Overview

This module will automate the creation of lambda layers for python projects provided the following:

- the target project contains a `requirements.layers.txt` file.
- A dockerfile the supports the installation of the `requirements.layers.txt` file has been specified

**Note:** By default the target Dockerfile has been configured to use `amazonlinux` as its base but a user specified docker file is supported.

As currently implemented this project is designed to support layer creation for the [python-ldap](https://www.python-ldap.org/en/latest/reference/ldap.html) project

<!-- BEGIN TFDOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| external | n/a |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| layer\_description | Description to associate with the resulting layer | `string` | n/a | yes |
| layer\_name | Name to associate with the resulting layer | `string` | n/a | yes |
| additional\_docker\_bindmounts | (Optional) List of additional bind mounts to provide the layer creation docker image | `list(string)` | `[]` | no |
| compatible\_runtimes | (Optional) A list of Runtimes this layer is compatible with. Up to 5 runtimes can be specified. | `list(string)` | `[]` | no |
| docker\_commands | (Optional) additional commands to run in the docker container | `list(string)` | `[]` | no |
| docker\_image\_name | (Optional) Name to assign to the docker image | `string` | `""` | no |
| dockerfile | (Optional) Full file path to the dockerfile in which the layer will be created | `string` | `""` | no |
| layer\_build\_command | (Optional) command to send to the docker image to trigger the layer creation | `string` | `""` | no |
| layer\_build\_script | (Optional) Full file path to the layer build script | `string` | `""` | no |
| target\_lambda\_path | (Optional) Full file path to the target lambda function | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| layer\_arn | n/a |

<!-- END TFDOCS -->
