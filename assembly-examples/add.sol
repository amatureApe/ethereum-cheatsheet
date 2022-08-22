// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Add {
    function addAssembly(uint256 x, uint256 y) public pure returns (uint256) {
        assembly {
            let result := add(x, y)
            mstore(0x0, result)
            return(0x0, 32)
        }
    }

    function addSolidity(uint256 x, uint256 y) public pure returns (uint256) {
        return x + y;
    }
}
