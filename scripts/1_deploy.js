// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const configFile = process.cwd() + "/scripts/config.json";
const jsonfile = require('jsonfile');

async function main() {
  let config = await jsonfile.readFileSync(configFile);

  const [deployer, player1, player2] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address, player1.address, player2.address);


  // 部署TurnScription合约
  console.log("start to deploy TurnScription contract====");
  const TurnScription = await hre.ethers.getContractFactory("TurnScription");
  const turnScription = await TurnScription.deploy(); 
  console.log(`Depoly TurnScription contract successful, address: ${turnScription.address}`);

  // 更新config.json文件
  config.ethSeries.TurnScription = turnScription.address;
  jsonfile.writeFileSync(configFile, config, {spaces: 2});
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
.catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
