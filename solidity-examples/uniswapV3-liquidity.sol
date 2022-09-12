// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IERC20.sol";
import "./IERC721Receiver.sol";
import "./INonfungiblePositionManager.sol";

contract UniswapV3Liquidity is IERC721Receiver {
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IERC20 private constant dai = IERC20(DAI);
    IERC20 private constant weth = IERC20(WETH);

    int24 private constant MIN_TICK = -887272;
    int24 private constant MAX_TICK = -MIN_TICK;
    int24 private constant TICK_SPACING = 60;

    INonfungiblePositionManager public manager =
        INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);

    event Mint(uint256 tokenId);

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function mint(uint256 amount0ToAdd, uint256 amount1ToAdd) external {
        dai.transferFrom(msg.sender, address(this), amount0ToAdd);
        weth.transferFrom(msg.sender, address(this), amount1ToAdd);
        dai.approve(address(manager), amount0ToAdd);
        weth.approve(address(manager), amount1ToAdd);

        int24 tickLower = (MIN_TICK / TICK_SPACING) * TICK_SPACING;
        int24 tickUpper = (MAX_TICK / TICK_SPACING) * TICK_SPACING;

        INonfungiblePositionManager.MintParams
            memory params = INonfungiblePositionManager.MintParams({
                token0: DAI,
                token1: WETH,
                fee: 3000,
                tickLower: tickLower,
                tickUpper: tickUpper,
                amount0Desired: amount0ToAdd,
                amount1Desired: amount1ToAdd,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp
            });

        (
            uint256 tokenId,
            uint256 liquidity,
            uint256 amount0,
            uint256 amount1
        ) = manager.mint(params);

        dai.approve(address(manager), 0);
        weth.approve(address(manager), 0);

        if (amount0ToAdd > amount0) {
            dai.transfer(msg.sender, amount0ToAdd - amount0);
        }
        if (amount1ToAdd > amount1) {
            weth.transfer(msg.sender, amount1ToAdd - amount1);
        }

        emit Mint(tokenId);
    }

    function increaseLiquidity(
        uint256 tokenId,
        uint256 amount0ToAdd,
        uint256 amount1ToAdd
    ) external {
        dai.transferFrom(msg.sender, address(this), amount0ToAdd);
        weth.transferFrom(msg.sender, address(this), amount1ToAdd);

        dai.approve(address(manager), amount0ToAdd);
        weth.approve(address(manager), amount1ToAdd);

        INonfungiblePositionManager.IncreaseLiquidityParams
            memory params = INonfungiblePositionManager
                .IncreaseLiquidityParams({
                    tokenId: tokenId,
                    amount0Desired: amount0ToAdd,
                    amount1Desired: amount1ToAdd,
                    amount0Min: 0,
                    amount1Min: 0,
                    deadline: block.timestamp
                });

        (uint128 liquidity, uint256 amount0, uint256 amount1) = manager
            .increaseLiquidity(params);

        dai.approve(address(manager), 0);
        weth.approve(address(manager), 0);

        if (amount0 < amount0ToAdd) {
            dai.transfer(msg.sender, amount0ToAdd - amount0);
        }
        if (amount1 < amount1ToAdd) {
            weth.transfer(msg.sender, amount1ToAdd - amount1);
        }
    }

    function decreaseLiquidity(uint256 tokenId, uint128 liquidity) external {
        INonfungiblePositionManager.DecreaseLiquidityParams
            memory params = INonfungiblePositionManager
                .DecreaseLiquidityParams({
                    tokenId: tokenId,
                    liquidity: liquidity,
                    amount0Min: 0,
                    amount1Min: 0,
                    deadline: block.timestamp
                });

        manager.decreaseLiquidity(params);
    }

    function collect(uint256 tokenId) external {
        INonfungiblePositionManager.CollectParams
            memory params = INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: msg.sender,
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            });

        manager.collect(params);
    }
}
