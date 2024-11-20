#!/bin/bash
echo "Begin testing..."
sleep 3

host=localhost
port=80

# Function to check if the database is connected
check_db_connection() {
  response=$(curl -s -o /dev/null -w "%{http_code}" $host:$port/api)
  if [ "$response" -eq 200 ]; then
    return 0
  else
    return 1
  fi
}

# Retry mechanism to wait for the database connection
max_retries=5
retry_count=0
until check_db_connection || [ $retry_count -eq $max_retries ]; do
  echo "Waiting for database connection..."
  sleep 3
  retry_count=$((retry_count + 1))
done

if [ $retry_count -eq $max_retries ]; then
  echo "Failed to connect to the database after $max_retries attempts."
  exit 1
fi

# Check if there are existing messages
messages_response=`curl -s $host:$port/api`
if [[ $messages_response != '[]' ]]; then
    echo "Messages already exist in the database. Skipping initial message response test."
else
    if [[ $messages_response != '[]' ]]; then
        >&2 echo Unexpected initial messages response: $messages_response
        exit 1
    fi
    echo Passed initial message response test
fi

post_response=`curl -s -XPOST -H "Content-Type: application/json" -d '{"message":"test"}' $host:$port/api`
if [[ $post_response != *"test"* || $post_response != *"_id"* ]]; then
    >&2 echo Unexpected response to adding a message: $post_response
    exit 1
fi
echo Passed adding a message test

messages_response=`curl -s $host:$port/api`
if [[ $messages_response != *"test"* ]]; then
    >&2 echo Unexpected messages response after adding a message: $messages_response
    exit 1
fi
echo Passed messages response test after adding a message

echo SUCCESS - passed all tests
exit 0