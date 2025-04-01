// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DosWithLoop {
    address[] public users;

    function register() external {
        users.push(msg.sender);
    }

    function reward() external {
        for (uint256 i = 0; i < users.length; i++) {
            (bool success, ) = users[i].call{value: 1 ether}("");
            require(success, "Transfer failed");
        }
    }

    receive() external payable {}
}
