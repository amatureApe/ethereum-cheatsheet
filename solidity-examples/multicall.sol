// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract TestMultiCall {
    function test(uint256 _i) external pure returns (uint256) {
        return _i;
    }
}

contract MultiCall {
    function multiCall(address[] calldata targets, bytes[] calldata data)
        external
        view
        returns (bytes[] memory)
    {
        require(targets.length == data.length, "invalid inputs");
        bytes[] memory results = new bytes[](data.length);

        for (uint256 i = 0; i < targets.length; i++) {
            (bool success, bytes memory response) = targets[i].staticcall(
                data[i]
            );
            require(success, "call failed");
            results[i] = response;
        }

        return results;
    }
}
