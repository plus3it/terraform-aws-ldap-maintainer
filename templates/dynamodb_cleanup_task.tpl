{
  "StartAt": "dynamodb_cleanup",
  "States": {
    "dynamodb_cleanup": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${function_arn}",
        "Payload": {
          "slack_message_key.$": "$.Payload.slack_message_key",
          "ldap_scan_results.$": "$.Payload.ldap_scan_results",
          "action": "remove"
        }
      },
      "End": true
    }
  }
}
