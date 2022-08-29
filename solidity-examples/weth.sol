// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./ERC20.sol";

contract WETH is ERC20 {
    constructor() ERC20("Wrapped Ether", "WETH", 18) {}

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);

    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external {
        _burn(msg.sender, _amount);
        payable(msg.sender).call{value: _amount}("");
        emit Withdraw(msg.sender, _amount);
    }

    fallback() external payable {
        deposit();
    }
}
