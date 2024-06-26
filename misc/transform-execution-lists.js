"use strict"
const fs = require('fs');

const DIR = "artifacts/sm-execution-list/";

fs.readdir(DIR, (err, filenames) => {
    if (err) {
        console.error(err);
        process.exit(1);
    }
    for (const file of filenames) {
        const { executions, NextToken } = require("../" + DIR + file);
        const parsedExecutions = executions
            .map(execution => execution.executionArn)
            .join("\n");
        fs.writeFileSync("./temp/executions/" + file.replace(".json", ""), parsedExecutions);
        if (NextToken) {
            fs.writeFileSync("./temp/executions/next-tokens/" + file.replace(".json", ""), NextToken);
        }
    }
});