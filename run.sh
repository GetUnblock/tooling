#!/bin/bash
set -e

mkdir -p temp
mkdir -p temp/executions
mkdir -p temp/executions/next-lists
mkdir -p temp/executions/next-tokens
mkdir -p artifacts
mkdir -p artifacts/sm-execution-list
mkdir -p artifacts/execution-history

echo "-> fetching state machines"
aws stepfunctions list-state-machines > artifacts/state-machines.json

echo "-> fetching exectution list of each state machine"
node misc/transform-state-machines.js

cat temp/sm-arns | while read smArn 
do
   aws stepfunctions list-executions --max-items=100 --state-machine-arn=$smArn > artifacts/sm-execution-list/${smArn}.json
done
node misc/transform-execution-lists.js

SHOULD_RECURSE=true

FILES_IN_NEXT_TOKENS_DIR=$(ls -1q temp/executions/next-tokens/ | wc -l)
if [ "$FILES_IN_NEXT_TOKENS_DIR" -eq "0" ]; then
   SHOULD_RECURSE=false
fi

while $SHOULD_RECURSE
do
   for file in temp/executions/next-tokens/*
   do
      smArn="${file/temp\/executions\/next-tokens\//}"
      if [[ "$smArn" != "*" ]]; then
         aws stepfunctions list-executions --starting-token="$(cat $file)" --max-items=100 --state-machine-arn=$smArn > temp/executions/next-lists/${smArn}.json
      fi
   done
   rm -rf temp/executions/next-tokens
   mkdir -p temp/executions/next-tokens
   node misc/migrate-pages.js
   FILES_IN_NEXT_TOKENS_DIR=$(find temp/executions/next-tokens/ -maxdepth 1 -type f 2>/dev/null | wc -l)
   if [ "$FILES_IN_NEXT_TOKENS_DIR" -eq "0" ]; then
      SHOULD_RECURSE=false
   fi
   rm -rf temp/executions/next-lists
   mkdir -p temp/executions/next-lists
done

echo "-> fetching executing history"
for file in temp/executions/*
do
   cat $file | while read execution 
   do
      aws stepfunctions get-execution-history --execution-arn=$execution > artifacts/execution-history/${execution}.json || continue
   done
done