complete -c vaulty -a 'login unlogin' --no-files

function vaulty -d "Vault tools"
  set help "Usage: vaulty login | unlogin | help"
  argparse --min-args=1 -- $argv
  or begin; echo $help; return 1; end
  set cmd $argv[1]
  set argv $argv[2..]
  switch "$cmd"
    case 'login'
      vaulty-login $argv
    case 'unlogin'
      vaulty-unlogin $argv
    case 'help' '*'
      echo $help
      return
  end
end

function vaulty-login -d "Logins with vault"
  argparse --max-args=0 'h/help' 'r/role=' 'a/addr=' -- $argv
  or return $status

  if set -ql _flag_h
    echo "Usage: vault-login [-h | --help] [-r | --role=APPROLE_NAME] [-a | --addr=VAULT_ADDR]" >&2
    return 1
  end

  set -l role "."
  set -ql _flag_role[1]
  and set role $_flag_role[-1]
  set -l addr "http://10.100.0.1:8200"
  set -ql _flag_addr[1]
  and set addr $_flag_addr[-1]

  set -gx VAULT_ADDR "$addr"

  echo "Trying $VAULT_ADDR/v1/auth/approle/login with /etc/vault/$role/role_id..."
  sudo true
  or return $status
  set -gx TF_VAR_vault_token "$(
    curl --fail-with-body -s -d "{
      \"role_id\": \"$(sudo cat "/etc/vault/$role/role_id")\",
      \"secret_id\": \"$(sudo cat "/etc/vault/$role/secret_id")\"
    }" "$VAULT_ADDR/v1/auth/approle/login" \
    | jq -r .auth.client_token)"
  pipefail || begin; echo "Login error!"; return 1; end
  set -gx VAULT_TOKEN "$TF_VAR_vault_token"

  [ -n "$VAULT_TOKEN" ] || begin; echo "Token is empty!"; return 1; end
  echo "Ok!"
end

function vaulty-unlogin -d "Unlogins with vault"
  argparse --max-args=0 -- $argv
  or return $status

  set -e VAULT_ADDR
  set -e VAULT_TOKEN
  set -e TF_VAR_vault_token
end
