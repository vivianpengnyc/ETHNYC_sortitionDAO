import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import {
  QUORUM_PERCENTAGE,
  VOTING_DELAY,
  VOTING_PERIOD,
  VRF_COORDINATOR,
  subscriptionId,
  gasLane,
  callbackGasLimit,
  INTERVAL
} from "../hardhat-helper-config";

const deployGovernorContract: DeployFunction = async (
  hre: HardhatRuntimeEnvironment
) => {
  const { getNamedAccounts, deployments, network } = hre;
  const { deploy, log, get } = deployments;
  const { deployer } = await getNamedAccounts();

  const governanceToken = await get("GovernanceToken");
  const timeLock = await get("TimeLock"); //get deployment object

  log("Deploying the Governor contract...");
  const governorContract = await deploy("GovernorContract", {
    from: deployer,
    args: [
      governanceToken.address,
      timeLock.address,
      VOTING_DELAY,
      VOTING_PERIOD,
      QUORUM_PERCENTAGE,
      VRF_COORDINATOR, // Chainlink Arguments line 33 to 37
      subscriptionId,
      INTERVAL,
      gasLane,
      callbackGasLimit
    ],
    log: true,
    waitConfirmations: 1, // optional
  });

  log(`03-Deployed 'GovernorContract' at ${governorContract.address} `);
};

export default deployGovernorContract;
deployGovernorContract.tags = ["all", "governor"];