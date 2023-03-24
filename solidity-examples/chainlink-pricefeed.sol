// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./AggregatorV3Interface.sol";

contract PriceOracle {
    // BTC price
    AggregatorV3Interface private constant priceFeed =
        AggregatorV3Interface(0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c);

    function getPrice() public view returns (int) {
        (, int answer, , uint updatedAt, ) = priceFeed.latestRoundData();

        require(updatedAt >= block.timestamp - 3 hours, "stale price");

        return answer;
    }
}
