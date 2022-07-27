// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract BetterticketReward is KeeperCompatibleInterface{
    IERC20 public rewardsToken;
    address public owner;

    // Duration of rewards to be paid out every week, Owner will need to setup new reward duration when the last one ends depending on the users demands
    //  --- Everything (in seconds)
    uint public duration;

    // Timestamp of when the rewards finish - December 30th, 2022
    uint public finishAt;

    // User address => rewards claimed
    mapping(address => uint) public rewards;

     // Rate of the reward is 10 token per duration the owner set
     // Owner can also reduce the amount of the reward depedning on the users demands --- Everything (in seconds)
    uint256 rewardRate = 10; 
  
    uint public immutable interval;
    uint public lastTimeStamp;

     modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    constructor (uint updateInterval) {
    interval = updateInterval;
    lastTimeStamp = block.timestamp;
    rewardsToken = IERC20(0x20Ec195ba5C43193A726cEC44067d791f97cB6dE);
}

    function lastTimeRewardApplicable() public view returns (uint) {
        return _min(finishAt, block.timestamp);
    }

    function setRewardsDuration(uint _duration) external onlyOwner {
        require(finishAt < block.timestamp, "reward duration not finished");
        duration = _duration;
    }

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }

    function checkUpkeep(bytes calldata  checkData ) external view override returns (bool upkeepNeeded, bytes memory performData ) {
    upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        performData = checkData;
    }

    function performUpkeep(bytes calldata performData) external override {
       rewardsToken.transfer(msg.sender, rewardRate);
       lastTimeStamp = block.timestamp;
       performData;
    }

}
