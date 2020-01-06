# Create Layer Module

Terraform module to programmatically create lambda layers

## Overview

This module will automate the creation of lambda layers for python projects provided the following:

- the target project contains a `requirements.layers.txt` file.
- A dockerfile the supports the installation of the `requirements.layers.txt` file has been specified

**Note:** By default the target Dockerfile has been configured to use `amazonlinux` as its base but a user specified docker file is supported.

As currently implemented this project is designed to support layer creation for the [python-ldap](https://www.python-ldap.org/en/latest/reference/ldap.html) project
