# LDAP Query Lambda Function

Lambda function that is used to perform actions against a target ldap database

## Overview

This function must be deployed into a VPC that has layer 3 connectivity to the target LDAP deployment.

When provided an event with the `query` action this function will:

1. Query ldap for the target objects and group them according to their time of last password change. (By default this is 120, 90, and 60 days)
2. Generate human readable and machine readable artifacts which are then placed into S3
3. Generate S3 presigned URLs of the artifacts

When provided an event with the `disable` action this function will:

1. Retrieve the previous scan results from the provided s3 object key in the disable event (the expectation is that this object was generated during the `query` run of this function)
2. Disable objects that have not have their passwords updated within the last 120 days.
