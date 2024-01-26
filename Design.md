## 合约设计

### 主要参数定义
- 定义类型
```js
address deployer; // 合约部署者
uint256 deployTime; // 部署时间
string name;    // 铭文名称
bytes32 inscriptionId; // 铭文id
uint256 totalSupply;   // 总发行量
uint256 limitPerMint;  // 每次铸币的最小数量
uint256 maxPerWallet;  // 每个地址最大铸币数量
uint256 minted;  // 已铸币数量
uint256 holders; // token持有人数
uint256 curPID; // 当前铭文打到第几张 
mapping (address => uint256[]) usersHolding; // 用户持有铭文信息(第几张id)
mapping (uint256 => Paper) paperInfo;  // 每一张铭文信息

// 每一张铭文结构体定义
struct Paper {
    uint256 pid;       // Paper ID
    string randDes;    // 随机数描述
}

```

### 接口说明

#### 铭文合约构造函数

```js
constructor(string memory _name, uint256 _totalSupply, uint256 _limitPerMint, uint256 _maxPerWallet)
```

> 入参说明：
>
> - _name： 铭文名称；
> - _totalSupply：总发行量
> - _limitPerMint：每次铸币的最小数量
> - _maxPerWallet：每个地址最大铸币数量

#### 铭文函数签名

```js
// 0xfb69af88c98f006e0a73f84cb295f4b9008a4feb2770084e18acbf12041a00fd
function funcSign() external pure returns(bytes32 funcSign_) 
```

> 返回参数说明：
>
> - funcSign_： 函数签名；

#### 获取铭文信息 

```js
function getInScriptionInfo() public view returns(
    address deployer_,
    uint256 deployTime_,
    string memory name_,
    bytes32 inscriptionId_,
    uint256 totalSupply_,
    uint256 limitPerMint_,
    uint256 maxPerWallet_,
    uint256 minted_,
    uint256 holders_)
```
> 返回参数说明：
> - deployer_: 铭文合约部署者；
> - deployTime_: 铭文合约部署时间；
> - name_： 铭文名称；
> - inscriptionId_：铭文ID；
> - totalSupply_：总发行量
> - limitPerMint_：每次铸币的最小数量
> - maxPerWallet_：每个地址最大铸币数量
> - minted_：已铸铭文数量
> - holders_：铭文持有人数

#### 获取用户的paper信息

包括ID和随机数描述信息 

```js
function getUserPaperInfos(address _user) public view returns(uint256[] memory pidList_, string[] memory randDesList_)
```
> 入参说明：
>
> - _user：用户地址
>
> 返回参数说明：
>
> - pidList_：用户打出的铭文的paper id列表；
> - randDesList_：对应铭文paper的随机数描述信息；

#### 铸币接口

```js
function mint(string calldata _randNum) public
```
> 入参说明：
>
> - _randNum：外部随机数；

#### 批量转账

```js
function batchTransfer(address _to, uint256[] memory _pids) public 
```
> 入参说明：
>
> - _to：铭文接收地址；
> - _pids：转移铭文paper id列表；

### 合约事件

```js
/// @notice 部署合约事件
/// @dev 部署铭文合约
/// @param _deployer 铭文合约部署者
/// @param _deployTime 铭文合约部署时间
/// @param _name 铭文名称
/// @param _inscriptionId 铭文id
/// @param _totalSupply 总发行量
/// @param _limitPerMint 每次铸币的最小数量
/// @param _maxPerWallet 每个地址最大铸币数量
event Deploy(address _deployer, uint256 _deployTime, string _name, bytes32 indexed _inscriptionId, uint256 _totalSupply, uint256 _limitPerMint, uint256 _maxPerWallet);

/// @notice 铸币事件
/// @dev 打铭文时触发
/// @param _user 用户
/// @param _curPid 当前Paper ID
/// @param _randDesc 铭文随机数描述信息
/// @param _minted 已打铭文数量
event Mint(address indexed _user, uint256 indexed _curPid, string _randDesc, uint256 _minted);

/// @notice 批量转移铭文事件
/// @param _from 付款地址
/// @param _to 收款地址
/// @param _pids 转移的paper id
event BatchTransfer(address indexed _from, address indexed _to, uint256[] _pids);
```

