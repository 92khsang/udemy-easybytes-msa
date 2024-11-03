#!/bin/bash

# Configuration
NAMESPACE="kubernetes-dashboard"
SERVICE="kubernetes-dashboard-kong-proxy"
LOCAL_PORT=8443
REMOTE_PORT=443
PID_FILE="/tmp/k8s_dashboard_$LOCAL_PORT.pid"

# Function to start the dashboard
start_dashboard() {
  if [[ -f $PID_FILE ]] && kill -0 $(cat $PID_FILE) 2>/dev/null; then
    echo "Kubernetes Dashboard is already running with PID $(cat $PID_FILE)"
  else
    echo "Starting Kubernetes Dashboard..."
    nohup kubectl -n $NAMESPACE port-forward svc/$SERVICE $LOCAL_PORT:$REMOTE_PORT > /dev/null 2>&1 & echo $! > $PID_FILE
    echo "Kubernetes Dashboard started on https://localhost:$LOCAL_PORT with PID $(cat $PID_FILE)"
  fi
}

# Function to stop the dashboard
stop_dashboard() {
  if [[ -f $PID_FILE ]] && kill -0 $(cat $PID_FILE) 2>/dev/null; then
    echo "Stopping Kubernetes Dashboard with PID $(cat $PID_FILE)..."
    kill $(cat $PID_FILE) && rm -f $PID_FILE
    echo "Kubernetes Dashboard stopped."
  else
    echo "Kubernetes Dashboard is not running."
  fi
}

# Main script
case "$1" in
  start)
    start_dashboard
    ;;
  stop)
    stop_dashboard
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    ;;
esac
