global:
  resolve_timeout: 5m

  smtp_from: "${smtp_from}"
  smtp_smarthost: "${smtp_smarthost}"
  smtp_auth_username: "${smtp_username}"
  smtp_auth_password: "${smtp_password}"
  slack_api_url: "${slack_api_url}"

route:
  receiver: "re-observe-pagerduty"
  routes:
  - receiver: "re-observe-ticket-alert"
    repeat_interval: 7d
    match:
      product: "prometheus"
      severity: "ticket"
  - receiver: "dgu-pagerduty"
    match:
      product: "data-gov-uk"
  - receiver: "registers-zendesk"
    repeat_interval: 7d
    match:
      product: "registers"
  - receiver: "re-observe-pagerduty"
    match:
      product: "prometheus"
      severity: "page"
  - receiver: "observe-cronitor"
    group_interval: 1m
    repeat_interval: 1m
    match:
      product: "prometheus"
      severity: "constant"
  - receiver: "autom8-slack"
    match:
      product: "verify"
    routes:
    - receiver: "verify-p1"
      match:
        deployment: prod
        severity: p1

receivers:
- name: "re-observe-pagerduty"
  pagerduty_configs:
    - service_key: "${observe_pagerduty_key}"
- name: "re-observe-ticket-alert"
  email_configs:
  - to: "${ticket_recipient_email}"
- name: "dgu-pagerduty"
  pagerduty_configs:
    - service_key: "${dgu_pagerduty_key}"
- name: "registers-zendesk"
  email_configs:
  - to: "${registers_zendesk}"
- name: "observe-cronitor"
  webhook_configs:
  - send_resolved: false
    url: "${observe_cronitor}"
- name: "autom8-slack"
  slack_configs:
  - channel: '#re-autom8-alerts'
    icon_emoji: ':verify-shield:'
    username: alertmanager
- name: "verify-p1"
  pagerduty_configs:
    - service_key: "${verify_p1_pagerduty_key}"
