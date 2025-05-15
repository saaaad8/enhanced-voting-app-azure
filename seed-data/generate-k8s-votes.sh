#!/bin/sh

# Use port forwarding to access the vote service
VOTE_URL="http://localhost:8080"

# Check if port forwarding is already set up
if ! nc -z localhost 8080 &>/dev/null; then
  echo "Setting up port forwarding for vote service..."
  echo "Note: Keep this terminal open while generating votes."
  echo "Press Ctrl+C after vote generation is complete."
  
  # Start port forwarding in the background
  kubectl port-forward svc/vote 8080:80 &
  PORT_FORWARD_PID=$!
  
  # Give it a moment to establish the connection
  sleep 2
fi

echo "Generating votes to $VOTE_URL"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create 5000 votes (4000 for option a, 1000 for option b)
echo "Generating 1000 votes for option B..."
ab -n 1000 -c 50 -p "$SCRIPT_DIR/postb" -T "application/x-www-form-urlencoded" $VOTE_URL/

echo "Generating 4000 votes for option A..."
ab -n 2000 -c 50 -p "$SCRIPT_DIR/posta" -T "application/x-www-form-urlencoded" $VOTE_URL/
ab -n 2000 -c 50 -p "$SCRIPT_DIR/posta" -T "application/x-www-form-urlencoded" $VOTE_URL/

echo "Vote generation complete!"

# Clean up port forwarding if we started it
if [ ! -z "$PORT_FORWARD_PID" ]; then
  echo "Cleaning up port forwarding..."
  kill $PORT_FORWARD_PID
  echo "Port forwarding stopped. You can now close this terminal."
fi
