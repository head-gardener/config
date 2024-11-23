auto_auth {
  method {
    type = "approle"

    config {
      role_id_file_path = "/etc/vault/role_id"
      secret_id_file_path = "/etc/vault/secret_id"
      remove_secret_id_file_after_reading = false
    }
  }
}

template_config {
  static_secret_render_interval = "5m"
  exit_on_retry_failure         = true
  max_connections_per_host      = 10
}

vault {
  address = "http://10.100.0.1:8200"
}

template {
  contents = "{{ with secret \"services/sing-box/vmess-uuid\" }}{{ .Data.data.uuid }}{{ end }}"
  destination = "./server.key"
  error_on_missing_key = true
  perms = "400"
}
