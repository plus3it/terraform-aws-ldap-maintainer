# Agent Instructions

Before starting any task in this repository:

1. Run `make agents/sync`. It writes the shared Plus3 IT instructions for this repository's tardigrade-ci version to `.agents/plus3it/AGENTS.md`.
2. Read `.agents/plus3it/AGENTS.md` and follow it together with this file. If the sync fails, tell the user, and don't guess the conventions.

These rules always apply, even without the shared instructions:

- Don't push, open pull requests, publish releases, or apply infrastructure changes unless the user asks. List those steps for a person in your final report.
- Don't edit files under `.agents/plus3it/`; they are generated and overwritten by the sync.

@.agents/plus3it/AGENTS.md

## Repository-specific

### Purpose

This Terraform module deploys a Step Function that disables stale LDAP user accounts after a person approves the change in Slack. A schedule (monthly by default) starts the Step Function, which queries LDAP for accounts whose password has not changed in `days_since_pwdlastset` days, posts the list to a Slack channel, and waits for approval. The main inputs are `ldaps_url`, `domain_base_dn`, `svc_user_dn`, `svc_user_pwd_ssm_key`, `vpc_id`, the Slack settings (`slack_api_token`, `slack_signing_secret`, `slack_channel_id`), and `dynamodb_table_name` and `dynamodb_table_arn` for the cleanup step. The main outputs are `slack_event_listener_endpoint` and `slack_bot_listener_endpoint`, which are the URLs to enter in the Slack app, and `python_ldap_layer_arn`.

### Module-specific files

- `modules/api_gateway/` — Creates the REST API with the `event-listener` endpoint for Slack events; called by the root module
- `modules/slack_listener/` — Creates the Lambda function that handles Slack events; called by the root module
- `modules/ldap_query/` — Creates the Lambda function that queries LDAP, its security group, and a python-ldap Lambda layer built in Docker; called by the root module
- `modules/slack_notifier/` — Creates the Lambda function that posts to Slack and answers the Step Function activity; called by the root module
- `modules/slack_bot/` — Creates the Lambda function for Slack slash commands and adds its endpoint through `slack_bot/api_gateway`; called by the root module
- `modules/slack_bot/api_gateway/` — Creates the `proxy` resource, method, and deployment on the root API Gateway; called by `slack_bot`
- `modules/dynamodb_cleanup/` — Creates the Lambda function that cleans up the DynamoDB table; called by the root module, and the README submodule list omits it
- `templates/` — Step Function definition (`ldap_maintainer_stepfunction.tpl`) and the optional DynamoDB cleanup task (`dynamodb_cleanup_task.tpl`), rendered by the root `main.tf`
- Python Lambda source — `modules/dynamodb_cleanup/lambda.py`, and `lambda/lambda.py` in `ldap_query`, `slack_bot`, `slack_listener`, and `slack_notifier`; `lambda/requirements.txt` exists in `ldap_query`, `slack_bot`, and `slack_notifier`, and `modules/ldap_query/layer/requirements.txt` and `layer/Dockerfile` build the layer
- `modules/ldap_query/lambda/templates/html_table.html` — HTML table template used by the LDAP query function
- `tests/integration_test/` — Manually deployed end-to-end test with SimpleAD, a populate-LDAP Lambda function, and a Windows domain member
- `.pydocstyle` — Configures pydocstyle to ignore all docstring checks; `modules/slack_notifier/lambda/setup.cfg` sets an `[install]` prefix for local pip installs
- `_docs/` — State machine diagram used by the README
