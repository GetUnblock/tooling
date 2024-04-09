"use strict";
const fs = require("fs");
const { stateMachines } = require("../artifacts/state-machines.json");

const smList = stateMachines.map((sm) => sm.stateMachineArn).join("\n");

fs.writeFileSync("./temp/sm-arns", smList);
