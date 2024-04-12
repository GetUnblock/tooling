"use strict"
const fs = require('fs');

const ARTIFACT_DIR = "artifacts/sm-execution-list/";
const TEMP_DIR = "temp/executions/next-lists/";

fs.readdir(TEMP_DIR, (err, filenames) => {
    if (err) {
        console.error(err);
        process.exit(1);
    }
    for (const file of filenames) {
        const { executions, NextToken } = require("../" + TEMP_DIR + file);
        const parsedExecutions = executions
            .map(execution => execution.executionArn)
            .join("\n");
        fs.writeFileSync("./temp/executions/" + file.replace(".json", ""), parsedExecutions);
        const mainContent = require("../" + ARTIFACT_DIR + file);
        mainContent.executions.push(...executions);
        fs.writeFileSync(ARTIFACT_DIR + file, JSON.stringify(mainContent, null, 2));
        if (NextToken) {
            fs.writeFileSync("./temp/executions/next-tokens/" + file.replace(".json", ""), NextToken);
        }
    }
});

setTimeout(() => {}, 300);