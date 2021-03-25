{
  "Comment": "Ldap account deactivation manager",
  "StartAt": "run_ldap_query",
  "States": {

    "run_ldap_query": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Catch": [
        {
          "ErrorEquals": [ "States.TaskFailed" ],
          "ResultPath": "$.Cause",
          "Next": "send_error_to_slack"
        }
      ],
      "Parameters": {
        "FunctionName": "${ldap_query_lambda_name}",
        "Payload": {
          "action": "query"
        }
      },
      "Next": "wait_for_manual_approval"
    },

    "wait_for_manual_approval": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke.waitForTaskToken",
      "TimeoutSeconds": ${manual_approval_timeout},
      "Parameters": {
        "FunctionName": "${slack_notifier_lambda_name}",
        "Payload": {
          "event.$": "$",
          "token.$": "$$.Task.Token"
        }
      },
      "Next": "check_manual_approval"
    },

    "check_manual_approval": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.button_pressed",
          "StringEquals": "Approve",
          "Next": "notify_slack_of_approval"
        }
      ],
      "Default": "notify_slack_of_disapproval"
    },

    "notify_slack_of_disapproval": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${slack_notifier_lambda_name}",
        "Payload": {
          "slack_message_key.$": "$.slack_message_key",
          "message_to_slack": "The LDAP operation has been disapproved"
        }
      },
      "Next": "disapproved"
    },

    "disapproved": {
      "Type": "Fail",
      "Cause": "No Matches!"
    },

    "notify_slack_of_approval": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${slack_notifier_lambda_name}",
        "Payload": {
          "slack_message_key.$": "$.slack_message_key",
          "ldap_scan_results.$": "$.ldap_scan_results",
          "message_to_slack": "The LDAP operation has been approved. I'll notify you when the operation is complete."
        }
      },
      "Next": "cleanup_tasks"
    },

    "cleanup_tasks": {
      "Type": "Parallel",
      "Next": "send_success_status_to_slack",
      "Catch": [
        {
          "ErrorEquals": [ "States.TaskFailed" ],
          "ResultPath": "$.Cause",
          "Next": "send_error_to_slack"
        }
      ],
      "Branches": [
        {
          "StartAt": "run_ldap_query_again",
          "States": {
            "run_ldap_query_again": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "Parameters": {
                "FunctionName": "${ldap_query_lambda_name}",
                "Payload": {
                  "slack_message_key.$": "$.Payload.slack_message_key",
                  "ldap_scan_results.$": "$.Payload.ldap_scan_results",
                  "action": "disable"
                }
              },
              "End": true
            }
          }
        }
        ${additional_cleanup_tasks}
      ]
    },

    "send_success_status_to_slack": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${slack_notifier_lambda_name}",
        "Payload": {
          "slack_message_key.$": "$[0].Payload.slack_message_key",
          "ldap_scan_results.$": "$[0].Payload.ldap_scan_results",
          "message_to_slack": "LDAP operations are complete"
        }
      },
      "End": true
    },

    "send_error_to_slack": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${slack_notifier_lambda_name}",
        "Payload": {
          "slack_message_key.$": "$.Payload.slack_message_key",
          "ldap_scan_results.$": "$.Payload.ldap_scan_results",
          "message_to_slack": "An error occurred!"
        }
      },
      "End": true
    }
  }
}
