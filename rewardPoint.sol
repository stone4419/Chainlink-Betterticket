// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

interface RewardPoint {
    function mint(address account, uint256 amount) external returns (bool);
}


// Minimum duration of each round of rewards in seconds is 86400

contract BetterticketPoint is KeeperCompatibleInterface{

    RewardPoint public minter;
    uint public immutable interval;
    uint public lastTimeStamp;
    uint256 reward = 10;
    uint256 rewardInWei = 0;  

constructor (uint updateInterval) {
    interval = updateInterval;
    lastTimeStamp = block.timestamp;
    minter = RewardPoint(0x20Ec195ba5C43193A726cEC44067d791f97cB6dE);
}


function checkUpkeep(bytes calldata  checkData ) external view override returns (bool upkeepNeeded, bytes memory performData ) {
    upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        performData = checkData;
    }

    function performUpkeep(bytes calldata performData) external override {
           {                
                rewardInWei = reward * 10 ** 18;
                minter.mint(msg.sender, rewardInWei);
           }
       lastTimeStamp = block.timestamp;
       performData;
    }

}