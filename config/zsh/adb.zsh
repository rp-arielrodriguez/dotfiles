# Ensure adb reverse mappings exist (smart: checks before adding)
# Usage:
#   adb_reverse_ensure 8081 5000          # same-port mappings
#   adb_reverse_ensure 8081:8081 5000:6000 # explicit remote:local pairs
adb_reverse_ensure() {
  local -A have
  local current key

  while IFS= read -r line; do
    local remote localp
    remote=$(printf "%s\n" "$line" | awk '{for(i=1;i<=NF;i++) if($i ~ /^tcp:[0-9]+$/){print substr($i,5); exit}}')
    localp=$(printf "%s\n" "$line" | awk '{c=0;for(i=1;i<=NF;i++) if($i ~ /^tcp:[0-9]+$/){c++; if(c==2){print substr($i,5); exit}}}')
    if [[ -n $remote && -n $localp ]]; then
      key="${remote}:${localp}"
      have[$key]=1
    fi
  done < <(adb reverse --list 2>/dev/null)

  local arg remote localp want
  for arg in "$@"; do
    if [[ $arg == *:* ]]; then
      remote=${arg%%:*}
      localp=${arg##*:}
    else
      remote=$arg
      localp=$arg
    fi
    want="${remote}:${localp}"

    if [[ -n ${have[$want]} ]]; then
      echo "reverse tcp:$remote -> tcp:$localp already exists."
    else
      echo "adding reverse tcp:$remote -> tcp:$localp"
      adb reverse "tcp:$remote" "tcp:$localp"
    fi
  done
}
