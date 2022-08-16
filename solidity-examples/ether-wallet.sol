// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract EtherWallet {
    fallback() external payable {}

    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    function withdraw(uint256 _amount) external {
        require(owner == msg.sender, "not owner");
        (bool sent, ) = owner.call{value: _amount}("");
        require(sent, "Failed to send");
    }
}
