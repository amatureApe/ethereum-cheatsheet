// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Account {
    address public bank;
    address public owner;
    uint256 public withdrawLimit;

    constructor(address _owner, uint256 _withdrawLimit) payable {
        bank = msg.sender;
        owner = _owner;
        withdrawLimit = _withdrawLimit;
    }
}

contract AccountFactory {
    Account[] public accounts;

    function createAccount(address _owner) external {
        Account account = new Account(_owner, 0);
        accounts.push(account);
    }

    function createAccountAndSendEther(address _owner) external payable {
        Account account = (new Account){value: msg.value}(_owner, 0);
        accounts.push(account);
    }

    function createSavingsAccount(address _owner) external {
        Account account = (new Account)(_owner, 1000);
        accounts.push(account);
    }
}
