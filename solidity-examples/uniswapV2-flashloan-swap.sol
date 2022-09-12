// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IERC20.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Callee.sol";
import "./IUniswapV2Pair.sol";

contract UniswapV2FlashSwap is IUniswapV2Callee {
    address private constant UNISWAP_V2_FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IUniswapV2Factory private constant factory =
        IUniswapV2Factory(UNISWAP_V2_FACTORY);

    IERC20 private constant weth = IERC20(WETH);

    IUniswapV2Pair private immutable pair;

    constructor() {
        pair = IUniswapV2Pair(factory.getPair(DAI, WETH));
    }

    function flashSwap(uint256 wethAmount) external {
        bytes memory data = abi.encode(WETH, msg.sender);
        pair.swap(0, wethAmount, address(this), data);
    }

    // This function is called by the DAI/WETH pair contract
    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external {
        require(address(pair) == msg.sender, "not pair");
        require(sender == address(this), "not contract");
        (address tokenBorrow, address caller) = abi.decode(
            data,
            (address, address)
        );

        // Custom code goes here, such as arbitrage
        require(tokenBorrow == WETH, "token borrow != WETH");

        // 0.3% fee, + 1 to round up
        uint256 fee = ((amount1 * 3) / 997) + 1;
        uint256 amountToRepay = amount1 + fee;

        // Transfer flash swap fee from caller
        weth.transferFrom(caller, address(this), fee);

        // Repay
        weth.transfer(address(pair), amountToRepay);
    }
}
