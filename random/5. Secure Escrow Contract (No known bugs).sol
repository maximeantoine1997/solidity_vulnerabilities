// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleEscrow {
    address public payer;
    address public payee;
    address public arbiter;
    uint256 public amount;
    bool public isApproved;

    constructor(address _payee, address _arbiter) payable {
        payer = msg.sender;
        payee = _payee;
        arbiter = _arbiter;
        amount = msg.value;
    }

    function approve() external {
        require(msg.sender == arbiter, "Only arbiter");
        require(!isApproved, "Already approved");
        isApproved = true;
        (bool success, ) = payee.call{value: amount}("");
        require(success, "Payment failed");
    }
}
