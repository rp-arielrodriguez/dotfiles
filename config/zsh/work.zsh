rp-settings() {
  echo "Ejecutando: adb shell am start -a android.intent.action.VIEW -d https://recargapay.com.br/user/settings"
  adb shell pm clear com.recarga.recarga
  setup_adb_reverse
  adb shell am start -a android.intent.action.VIEW -d "https://recargapay.com.br/user/settings" -n "com.recarga.recarga/.react.ReactHomeActivity" -S
}

rploginnewuserqa() {
  if [ $# -lt 1 ]; then
    echo "Parametros requeridos"
    echo " Ejemplo: rploginnewuserqa 'kyc=birthndoc-valid%2Cphoto-no%2Caddress-no%2Cphone-no%2Cincome-statement-no&pin=active&segment=10&account-type=no'"
    return 1
  fi
  query=$1
  echo "Param: $query"
  uri="https://api-qa.recarga.com"

  full_url="$uri/api/v2/qa-users?$query"
  echo "Consultando: $full_url"
  result=$(curl --location "$full_url" \
    --header 'accept: application/json' \
    --header 'content-type: application/json' \
    --header "x-uuid-credential: $RP_UUID_CREDENTIAL" \
    --header 'User-Agent: E2E: H LOCAL')
  magic_link=$(echo "$result" | grep -o "\"magicLinkToken\":\"[^\"]*" | sed 's/"magicLinkToken":"//')
  echo "Resultado del comando curl:"
  echo $result
  if [ -z "$magic_link" ]; then
    echo "Error obteniendo el magic link"
    return 1
  fi
  setup_adb_reverse
  echo "Ejecutando: adb shell am start -a android.intent.action.VIEW -d https://recargapay.com.br/?al=$magic_link"
  adb shell am start -a android.intent.action.VIEW -d "https://recargapay.com.br/?al=$magic_link" -n "com.recarga.recarga/.react.ReactHomeActivity" -S
}

rploginnewuserdev() {
  if [ $# -lt 1 ]; then
    echo "Parametros requeridos"
    echo " Ejemplo: rploginnewuserdev 'kyc=birthndoc-valid%2Cphoto-no%2Caddress-no%2Cphone-no%2Cincome-statement-no&pin=active&segment=10&account-type=no'"
    return 1
  fi
  query=$1
  echo "Param: $query"
  uri="https://api-dev.recarga.com"

  full_url="$uri/api/v2/qa-users?$query"
  echo "Consultando: $full_url"
  result=$(curl --location "$full_url" \
    --header 'accept: application/json' \
    --header 'content-type: application/json' \
    --header "x-uuid-credential: $RP_UUID_CREDENTIAL" \
    --header 'User-Agent: E2E: H LOCAL')
  magic_link=$(echo "$result" | grep -o "\"magicLinkToken\":\"[^\"]*" | sed 's/"magicLinkToken":"//')
  echo "Resultado del comando curl:"
  echo $result
  if [ -z "$magic_link" ]; then
    echo "Error obteniendo el magic link"
    return 1
  fi
  setup_adb_reverse
  echo "Ejecutando: adb shell am start -a android.intent.action.VIEW -d https://recargapay.com.br/?al=$magic_link"
  adb shell am start -a android.intent.action.VIEW -d "https://recargapay.com.br/?al=$magic_link" -n "com.recarga.recarga/.react.ReactHomeActivity" -S
}

magiclink-login() {
  if [ $# -lt 1 ]; then
    echo "Parametros requeridos"
    echo " Ejemplo: magiclink-login 'AT-87872903-5571-4E32-AE24-1B2687D72752'"
    return 1
  fi
  magic_link=$1
  echo "Ejecutando: adb shell am start -a android.intent.action.VIEW -d https://recargapay.com.br/?al=$magic_link"
  adb shell am start -a android.intent.action.VIEW -d "https://recargapay.com.br/?al=$magic_link" -n "com.recarga.recarga/.react.ReactHomeActivity" -S
}

rp-login() {
  userid=$1
  env=$2
  echo "userid: $userid"
  setup_adb_reverse
  uri="https://ts-${env}.recargapay.com"
  full_url="$uri/api-raw/1.0/qa-users/$userid/magic-link"
  echo "Consultando: $full_url"
  result=$(curl --location --request POST "$full_url" \
        --header 'accept: application/json' \
        --header 'content-type: application/json' \
        --header "x-qa-automation-api-key: $RP_QA_API_KEY" \
        --data '')
  magic_link=$(echo "$result" | grep -o "\"magic_link\":\"[^\"]*" | sed 's/"magic_link":"//')
  echo "Resultado del comando curl:"
  echo $result
  if [ -z "$magic_link" ]; then
      echo "Error obteniendo el magic link"
      return 1
  fi
  echo "Ejecutando: adb shell am start -a android.intent.action.VIEW -d https://recargapay.com.br$magic_link"
  adb shell am start -a android.intent.action.VIEW -d "https://recargapay.com.br$magic_link" -n "com.recarga.recarga/.react.ReactHomeActivity" -S
}

rp-loginqa() {
  rp-login $1 'qa'
}

rp-logindev() {
  rp-login $1 'dev'
}

alias redshift-login='aws sso login --profile=recargapay-data-dbs'
