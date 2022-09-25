// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IERC20.sol";
import "./IUniswapV3Pool.sol";

library PoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH =
        0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    function computeAddress(address factory, PoolKey memory key)
        internal
        pure
        returns (address pool)
    {
        require(key.token0 < key.token1);
        pool = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factory,
                            keccak256(
                                abi.encode(key.token0, key.token1, key.fee)
                            ),
                            POOL_INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }
}

contract UniswapV3Flash {
    address private constant FACTORY =
        0x1F98431c8aD98523631AE4a59f267346ea31F984;

    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    IERC20 private constant weth = IERC20(WETH);

    uint24 private constant POOL_FEE = 3000;

    struct FlashData {
        uint256 wethAmount;
        address caller;
    }

    IUniswapV3Pool private immutable pool;

    constructor() {
        pool = IUniswapV3Pool(
            PoolAddress.computeAddress(
                FACTORY,
                PoolAddress.getPoolKey(DAI, WETH, POOL_FEE)
            )
        );
    }

    function flash(uint256 wethAmount) external {
        bytes memory data = abi.encode(
            FlashData({wethAmount: wethAmount, caller: msg.sender})
        );
        pool.flash(address(this), 0, wethAmount, data);
    }

    function uniswapV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external {
        require(msg.sender == address(pool), "not authorized");

        FlashData memory decoded = abi.decode(data, (FlashData));

        weth.transferFrom(decoded.caller, address(this), fee1);
        weth.transfer(address(pool), decoded.wethAmount + fee1);
    }
}
