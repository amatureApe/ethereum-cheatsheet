// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Fallback {
    string[] public answers = ["receive", "fallback"];

    fallback() external payable {}

    receive() external payable {}
}
