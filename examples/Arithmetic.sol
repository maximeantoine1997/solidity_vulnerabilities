// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BuggyVault {
    mapping(address => uint256) public balances;
    uint256 public totalDeposits;
    uint256 public rewardPool;
    uint256 public sharePrice = 1e18;

    function deposit(uint256 amount) external {
        require(amount > 0, "Zero amount");
        balances[msg.sender] += amount;
        totalDeposits += amount;
    }

    function withdraw(uint256 shares) external {
        uint256 amount = shares * sharePrice / 1e18;
        require(amount <= balances[msg.sender], "Insufficient balance");
        balances[msg.sender] -= amount;
        totalDeposits -= amount;
    }

    function distributeRewards(uint256 reward) external {
        unchecked {
            rewardPool += reward;
        }
    }

    function calculateUserReward(address user) external view returns (uint256) {
        return (balances[user] * rewardPool) / totalDeposits;
    }

    function updateSharePrice() external {
        sharePrice = totalDeposits / 1e6;
    }

    function riskyCasting(uint256 bigValue) external pure returns (int256) {
        return int256(bigValue);
    }

    function loopReward(uint256 limit) external pure returns (uint256) {
        uint256 total;
        for (uint256 i = 0; i < limit; i++) {
            unchecked {
                total += i;
            }
        }
        return total;
    }

    function safeReward(uint256 input) external pure returns (uint256) {
        require(input < type(uint256).max / 2, "Input too large");
        return input * 2;
    }
}
