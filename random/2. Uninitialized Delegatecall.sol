// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Library {
    uint256 public num;

    function setNum(uint256 _num) external {
        num = _num;
    }
}

contract UninitializedDelegatecall {
    address public lib;
    uint256 public num;

    function delegateSet(uint256 _num) external {
        lib.delegatecall(abi.encodeWithSignature("setNum(uint256)", _num));
    }
}
