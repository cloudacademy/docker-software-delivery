#!/bin/bash

echo "Begin testing..."
sleep 3

host=localhost
port=80

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