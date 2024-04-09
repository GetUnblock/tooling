#!/bin/bash
set -e

mkdir -p temp
mkdir -p temp/executions
mkdir -p artifacts
mkdir -p artifacts/sm-execution-list
mkdir -p artifacts/execution-history

echo "-> fetching state machines"
aws stepfunctions list-state-machines > artifacts/state-machines.json

echo "-> fetching exectution list of each state machine"
node misc/transform-state-machines.js
cat temp/sm-arns | while read smArn 
do
   aws stepfunctions list-executions --state-machine-arn=$smArn > artifacts/sm-execution-list/${smArn}.json
done

echo "-> fetching executing history"
node misc/transform-execution-lists.js
for file in temp/executions/*
do
   cat $file | while read execution 
   do
      aws stepfunctions get-execution-history --execution-arn=$execution > artifacts/execution-history/${execution}.json
   done
done