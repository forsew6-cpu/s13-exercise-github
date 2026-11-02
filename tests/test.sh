#!/bin/bash
# Automated test script for NewsGrid Docker website
set -e

CONTAINER_NAME="${1:-newsgrid-test}"
IMAGE_NAME="newsgrid"
PORT=8080

cleanup() {
  echo "Cleaning up..."
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

cleanup # Remove any existing container with the same name

echo "Starting container $CONTAINER_NAME from image $IMAGE_NAME..."
docker run -d --name "$CONTAINER_NAME" -p $PORT:80 "$IMAGE_NAME"

# Wait for the website to become available
for i in {1..15}; do
  if curl -s -o /dev/null "http://localhost:$PORT"; then
    break
  fi
  echo "Waiting for website... ($i)"
  sleep 1
done

# Test 1: HTTP status 200
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT")
if [ "$STATUS" != "200" ]; then
  echo "❌ Test failed: Expected HTTP 200, got $STATUS"
  exit 1
else
  echo "✅ HTTP status 200 test passed."
fi

# Test 2: Homepage contains 'NewsGrid'
BODY=$(curl -s "http://localhost:$PORT")
if ! echo "$BODY" | grep -q "NewsGrid"; then
  echo "❌ Test failed: Homepage does not contain 'NewsGrid'"
  exit 1
else
  echo "✅ Homepage contains 'NewsGrid'."
fi

echo "All tests passed."
exit 0
