// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UnderflowExample {
    mapping(address => uint256) public balances;

    function deposit(uint256 _amount) external {
        balances[msg.sender] += _amount;
    }

    function withdraw(uint256 _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        unchecked {
            // Manually disabling safety checks
            balances[msg.sender] -= _amount;
        }
    }
}
