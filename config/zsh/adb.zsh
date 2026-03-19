setup_adb_reverse() {
  adb reverse tcp:9090 tcp:9090
  adb reverse tcp:9999 tcp:9999
  adb reverse tcp:8080 tcp:8080
  adb reverse tcp:8081 tcp:8081
  adb reverse tcp:8097 tcp:8097
  adb reverse tcp:5000 tcp:5000
}
