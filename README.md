# Turnscription
## 简介


## 环境搭建
- 说明

   使用Hardhat搭建项目，Truffle 测试的运行速度不如 Hardhat 那样快 ；

- 安装Node.js和npm

  ```bash
  # 卸载
  sudo apt-get remove nodejs -y
  sudo apt-get remove npm -y
  # 下载并执行nvm安装脚本
  wget https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh && chmod +x ./install.sh &&  ./install.sh
  # 环境变量生效
  source ~/.bashrc
  # 查看版本信息
  nvm -v
  # 安装node16版（truffle使用建议安装16版本，不要安装17版本，否则部署合约会报错）
  nvm install 16
  node -v 
  npm -v
  # 安装node17版, 会进行覆盖16的版本
  nvm install 17
  node -v 
  npm -v
  ```

- 使用npm安装Hardhat

  ```
  npm install --save-dev hardhat
  ```

 ## 创建Hardhat项目

以：Turnscription为例：

```bash
git clone https://github.com/part-blockchain/Turnscription.git && cd Turnscription && npm install
```

## 配置文件
生成hardhat.config.js配置文件模板：
```bash
npx hardhat
```

修改hardhat.config.js配置，和truffle的配置类型:

```js
require("@nomicfoundation/hardhat-toolbox");
const config = require("./scripts/config.json");

//选取ganache下的2个账户的私钥
// const PRIVATE_KEY1 = "02da90597bf4cef6621103622f27a31d65c0856a0a66ba2fd03e4663161f1c5b"; // 0x86d5b5903b0330d76b47D368bebF5A74dB6251dB
// const PRIVATE_KEY2 = "ef0ad8f183e9b39f801ce9ba03b8f332fbe338344a207c9995966795aa295970"; // 0xc3899703e578f13802c0F83Fb5Ee114a139910f0

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  // 定义网络
  networks: {
    // hardhat网络
    hardhat: {
      chainId: 1337
    },

    // ganache本地网络
    ganache: {
      url: `http://192.168.31.234:8545`,
      // 私钥方式
      // accounts: [`0x${PRIVATE_KEY1}`,`0x${PRIVATE_KEY2}`,`0x${PRIVATE_KEY3}`,`0x${PRIVATE_KEY4}`,`0x${PRIVATE_KEY5}`],
      // 助记词方式
      accounts: {
        mnemonic: config.ethSeries.mnemonic,
      },
    },
  }
}
```

## 合约编写/编译/部署

步骤如下：

- 编写合约

  在contracts目录下创建合约文件Turnscription.sol，并编写合约代码，相关设计文档参考：[Design.md](./Design.md)。
  ```
  # 创建游戏桌
  ```

- 编译合约

  ```bash
  npx hardhat compile
  ```

  > 编译后的合约代码将被保存在./artifacts/contracts目录中 ;

- 部署合约

  在Hardhat项目中，使用JavaScript编写合约部署脚本，并在终端中输入：

  ```
  # 先启动ganache等指定的网络
  npx hardhat run scripts/1_deploy.js --network ganache
  npx hardhat run scripts/2_run_test.js --network ganache
  ```

  以下是一个简单的部署脚本deploy.js的示例 ：

  ```js
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
  
    // 部署Turnscription合约
    console.log("start to deploy Turnscription contract====");
    const Turnscription = await hre.ethers.getContractFactory("Turnscription");
    const Turnscription = await Turnscription.deploy(); 
    console.log(`Depoly Turnscription contract successful, address: ${Turnscription.address}`);
  
    // 更新config.json文件
    config.ethSeries.Turnscription = Turnscription.address;
    jsonfile.writeFileSync(configFile, config, {spaces: 2});
  }
  
  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  
  ```

## 合约测试
  

- 测试Game合约

  ```bash
  npx hardhat test test/Turnscription.js
  ```

