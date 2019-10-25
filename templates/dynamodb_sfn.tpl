"dynamodb_cleanup": {
"Type": "Task",
"Resource": "arn:aws:states:::lambda:invoke",
"Catch": [
  {
    "ErrorEquals": [ "States.TaskFailed" ],
    "Next": "send_error_to_slack"
  }
],
"Parameters": {
  "FunctionName": "${function_arn}",
  "Payload": {
    "slack_message_key.$": "$.Payload.slack_message_key",
    "ldap_scan_results.$": "$.Payload.ldap_scan_results",
    "action": "remove"
  }
},
"Next": "send_status_to_slack"
},
