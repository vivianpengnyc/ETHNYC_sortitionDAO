import "@typechain/hardhat";
import "hardhat-deploy";
import "@nomiclabs/hardhat-ethers";
import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-waffle";

const ALCHEMY_API_KEY = "https://eth-rinkeby.alchemyapi.io/v2/ajAM0N0OLarH1Ah4SCKYLNR_LoZhreUn";
const RINKEBY_PRIVATE_KEY = "07e9b2bf09a042f411db2ed78b5060f1789eb450b10f72dbc57158096e62f805";

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
// module.exports = {
// solidity: {
//   version: "0.8.9",
//   settings: {
//     optimizer: {
//       enabled: true,
//       runs: 200,
//     },
//   },
// },
// };

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    // DEVELOPMENT BLOCKCHAINS
    hardhat: {
      chainId: 31337,
    },
    localhost: {
      chainId: 31337,
      gas: 600000,
    },
    rinkeby: {
      url: ALCHEMY_API_KEY,
      accounts: [RINKEBY_PRIVATE_KEY],//[process.env.PRIVATE_KEY],
      chainId: 4,
      saveDeployments: true,
      gas: 2100000,
  },
  },
  namedAccounts: {
    deployer: {
      default: 0, // INDEX for the deployer's account in the array of accounts that Hardhat gives us.
    },
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};

export default config;