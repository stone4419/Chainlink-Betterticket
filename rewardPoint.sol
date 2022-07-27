// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

// Hey this is Josue... The code I wrote here is for a contract that will be used to pay out rewards to users.
//  The owner of the contract will have the ability to set the duration of rewards
// Owner will need to setup new reward duration when the last one ends depending on the users demands.
// Owner can also reduce the amount of the reward depedning on the users demands --- Everything (in seconds)

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

    // Duration of rewards to be paid out (in seconds)
    uint public duration;

    // "finishAt" is used to represent when the rewards finish. 
    uint public finishAt;

    //"rewards" is used to represent all of the rewards claimed.
    // User address => rewards claimed
    mapping(address => uint) public rewards;

     // Rate of the reward is 10 token per duration the owner set
    uint256 rewardRate = 10; 
  
    // "interval" sets how often rewardsToken gives out its next reward.  
    uint public immutable interval;

    // "lastTimeStamp" stores when block number was created on the blockchain so that we know when our contract started running.
    uint public lastTimeStamp;

     modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    // This constructor will be used to set the interval between each block reward distribution.
    // The lastTimeStamp variable is also defined and initialized with the current block timestamp, which will be used to calculate rewardsToken's balance at any given time.
    constructor (uint updateInterval) {
    interval = updateInterval;
    lastTimeStamp = block.timestamp;
    rewardsToken = IERC20(0x20Ec195ba5C43193A726cEC44067d791f97cB6dE);
}

    // "lastTimeRewardApplicable" returns the time at which rewards can be claimed.
    function lastTimeRewardApplicable() public view returns (uint) {
        return _min(finishAt, block.timestamp);
    }

    //  "setRewardsDuration" sets how long rewards last for after they have been earned.
    function setRewardsDuration(uint _duration) external onlyOwner {
        require(finishAt < block.timestamp, "reward duration not finished");
        duration = _duration;
    }

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }
    //checkUpkeep checks if rewards need to be paid out or not based on when block timestamp is compared with lastTimeStamp
    function checkUpkeep(bytes calldata  checkData ) external view override returns (bool upkeepNeeded, bytes memory performData ) {
    upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        performData = checkData;
    }

    // The code is meant to transfer the rewards token from Betterticket to whoever users presses the button to claim the reward.
    function performUpkeep(bytes calldata performData) external override {
       rewardsToken.transfer(msg.sender, rewardRate);
       lastTimeStamp = block.timestamp;
       performData;
    }

}
