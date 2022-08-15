// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SimpleStorage {
    // Write your code here
    string public text;

    function set(string calldata _text) public {
        text = _text;
    }

    function get() public view returns (string memory) {
        return text;
    }
}
