// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const { expect } = require("chai");
const configFile = process.cwd() + "/scripts/config.json";
const jsonfile = require('jsonfile');

async function main() {
  let config = await jsonfile.readFileSync(configFile);

  const [deployer, addr1, addr2] = await ethers.getSigners();
  console.log("addr1:", addr1.address, ",addr2:", addr2.address);

  // 铭文合约
  const TurnScription = await ethers.getContractFactory("TurnScription");
  inscription = TurnScription.attach(config.ethSeries.TurnScription);
  
  // 批量铸币
  const times = 2;
  for(let i = 0; i < times; i++) {
    console.log("Start to mint TurnScription ==> i:", i);
    const randNum = "afadf!@#$%^1231ASDF";  // 随机数
    tx = await inscription.connect(addr1).mint(randNum);
    console.log("Mint TurnScription successful, i:", i, ", tx:", tx);
  }

  // 获取addr1的铭文信息
  add1PaperInfos = await inscription.getUserPaperInfos(addr1.address);
  console.log("addr1 paper infos:", add1PaperInfos.pidList_);
  expect(add1PaperInfos.pidList_.length).to.equal(times);  // 玩家人数

  // 批量转账
  console.log("Start to batch transfer TurnScription");
  tx = await inscription.connect(addr1).batchTransfer(addr2.address, [1,2]);
  console.log("Mint TurnScription successful, tx:", tx);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
.catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
