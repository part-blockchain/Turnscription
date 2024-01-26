// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TurnScription {
    address deployer; // 铭文合约部署者
    uint256 deployTime; // 铭文合约部署时间
    string name;    // 铭文名称
    bytes32 inscriptionId; // 铭文id
    uint256 totalSupply;   // 总发行量
    uint256 limitPerMint;  // 每次铸币的最小数量
    uint256 maxPerWallet;  // 每个地址最大铸币数量
    uint256 maxPaperPerWallet; // 每个地址最大张数
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

    // 0xfb69af88c98f006e0a73f84cb295f4b9008a4feb2770084e18acbf12041a00fd
    function funcSign() external pure returns(bytes32 funcSign_) {
        funcSign_ = keccak256("TurnScription()");
    }

    constructor(string memory _name, uint256 _totalSupply, uint256 _limitPerMint, uint256 _maxPerWallet) {
        require(0 < _limitPerMint, "The number of coins minted at a time must be greater than 0");
        require(0 < _totalSupply && _maxPerWallet >= _limitPerMint && _totalSupply >= _maxPerWallet, "Exceed maximum circulation");
        require(0 == _maxPerWallet % _limitPerMint, "An integer multiple of the maximum coin size that is not the minimum coin size");
        maxPaperPerWallet = _maxPerWallet / _limitPerMint;
        deployer = msg.sender;
        deployTime = block.timestamp;
        name = _name;
        inscriptionId = bytes32(keccak256(abi.encodePacked(address(this))));
        totalSupply = _totalSupply;
        limitPerMint = _limitPerMint;
        maxPerWallet = _maxPerWallet;
        minted = 0;
        holders = 0;
        curPID = 1;   // 从第一张铭文开始打

        // 触发事件
        emit Deploy(deployer, deployTime, name, inscriptionId, totalSupply, limitPerMint, maxPerWallet);
    }

    // 获取铭文信息
    function getInScriptionInfo() public view returns(
        address deployer_,
        uint256 deployTime_,
        string memory name_,
        bytes32 inscriptionId_,
        uint256 totalSupply_,
        uint256 limitPerMint_,
        uint256 maxPerWallet_,
        uint256 minted_,
        uint256 holders_
    ) {
        deployer_ = deployer;
        deployTime_ = deployTime;
        name_ = name;
        inscriptionId_ = inscriptionId;
        totalSupply_ = totalSupply;
        limitPerMint_ = limitPerMint;
        maxPerWallet_ = maxPerWallet;
        minted_ = minted;
        holders_ = holders;
    }

    // // 获取用户持有的Paper ID
    // function getPaperIds(address user) public view returns(uint256[] memory) {
    //     return usersHolding[user];
    // }
    // // 根据paper id获取随机数描述信息
    // function getPaperInfo(uint256 pid) public view returns(string memory) {
    //     return paperInfo[pid].randDes;
    // }

    // 获取用户的paper信息，包括ID和随机数描述信息
    function getUserPaperInfos(address _user) public view returns(uint256[] memory pidList_, string[] memory randDesList_) {
        pidList_ = usersHolding[_user];
        randDesList_ = new string[](pidList_.length);
        for(uint256 i = 0; i < pidList_.length; i++) {
            uint256 pid = pidList_[i];
            randDesList_[i] = paperInfo[pid].randDes;
        }
    }

    // 将uint转换为字符串
    function uintToString(uint256 _value) internal pure returns (string memory) {
        if (_value == 0) {
            return "0";
        }
        
        uint256 temp = _value;
        uint256 digits;
        
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        
        bytes memory buffer = new bytes(digits);
        
        while (_value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + (_value % 10)));
            _value /= 10;
        }
        
        return string(buffer);
    }

    // 铸币
    function mint(string calldata _randNum) public {   
        // 判断是否将超出总发行量
        require(totalSupply >= (minted + limitPerMint), "Beyond the maximum circulation, no more inscriptions can be printed");
        // 获取用户的paper list
        uint256[] storage pidList = usersHolding[msg.sender];
        uint256 mintedNum = pidList.length;
        require( mintedNum < maxPaperPerWallet, "The address has reached the maximum number of engraved coins");
        if( mintedNum == 0) {
            // 此地址未打过铭文
            holders += 1;
        }
        Paper storage paper = paperInfo[curPID];
        paper.pid = curPID;
        string memory timeRand = uintToString(block.timestamp);
        paper.randDes = string.concat(_randNum, timeRand);
       
        pidList.push(curPID);
        // 已铸币数量
        minted += limitPerMint;
        curPID += 1;
        emit Mint(msg.sender, paper.pid, paper.randDes, minted);
    }

    function pidIsOwnerBySender(uint256 pid) internal view returns(bool, uint256) {
        uint256[] memory pidList = usersHolding[msg.sender];
        for(uint256 i = 0; i < pidList.length; i++) {
            if(pid == pidList[i]) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    // 删除发送者的pid
    function delSenderPid(uint256 _index) internal {
        uint256[] storage pidList = usersHolding[msg.sender];
        require(_index < pidList.length, "index is correct");
        for(uint256 i = _index; i < pidList.length - 1; i++) {
            pidList[i] = pidList[i+1];
        }
        pidList.pop();
    }

    // 批量转账
    function batchTransfer(address _to, uint256[] memory _pids) public {
        require(_to != msg.sender, "Error in transferring money to yourself");
        require(_pids.length > 0, "The transferred paper id cannot be empty");
        uint256[] memory pidList = usersHolding[msg.sender];
        require(pidList.length >= _pids.length, "The transferred paper id list has the wrong length");
        uint256[] storage toPidList = usersHolding[_to];
        // 批量转账之前to地址持有铭文数量
        uint256 toBeforeLen = toPidList.length;
        for(uint256 i = 0; i < _pids.length; i++) {
            // 校验pid是否存在
            uint256 pid = _pids[i];
            require(paperInfo[pid].pid > 0, "The transferred paper id does not exist");
            // 检查pid是否是msg.sender拥有
            (bool isOwner, uint256 index) = pidIsOwnerBySender(pid);
            require(isOwner, "pid is owned by non-sender and cannot be used for transfer");
            // 转账
            delSenderPid(index);
            toPidList.push(pid);
        }
        
        if(0 == toBeforeLen && 0 != usersHolding[msg.sender].length) {
            // 1.批量转账之前to地址未持有铭文；2.转账之后from地址仍然持有铭文
            holders += 1;
        } else if(toBeforeLen > 0 && 0 == usersHolding[msg.sender].length) {
            // 1.批量转账之前to地址已持有铭文；2.转账之后from地址不再持有铭文
            holders -= 1;
        }
        emit BatchTransfer(msg.sender, _to, _pids);
    }
}
