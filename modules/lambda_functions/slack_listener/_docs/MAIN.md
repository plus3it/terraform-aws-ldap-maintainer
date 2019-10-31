# Slack Listener Lambda

Lambda function that responds to slack events

## Overview

This function is intended for use with this project's API Gateway module. An API Gateway endpoint will be configured as the target slack integration's Interactive Component Request URL, so that on receipt of a slack event this function will:

1. Determine if the received slack event is valid
2. And if so provide a target step function with a wait token extracted from the response.
