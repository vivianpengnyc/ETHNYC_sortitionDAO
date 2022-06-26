import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";
import deployGovernanceToken from "./01-deploy-governance-token";
import {MIN_DELAY, PROPOSERS, EXECUTORS} from "../hardhat-helper-config"
const deployTimeLock: DeployFunction = async (
  hre: HardhatRuntimeEnvironment
) => {
  const { getNamedAccounts, deployments, network } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy, log } = deployments;


log("Deploying the TimeLock contract...");
const timeLock = await deploy("TimeLock", {
    from: deployer,
    args: [MIN_DELAY, PROPOSERS, EXECUTORS],
    log: true,
});
    log(`02-'TimeLock' contract deployed at ${timeLock.address}`)
};

export default deployTimeLock;
deployTimeLock.tags = ["all", "timelock"];
