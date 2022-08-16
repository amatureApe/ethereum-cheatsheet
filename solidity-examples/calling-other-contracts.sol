// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract TestContract {
    uint256 public x;
    uint256 public value = 123;

    function setX(uint256 _x) external {
        x = _x;
    }

    function getX() external view returns (uint256) {
        return x;
    }

    function setXandReceiveEther(uint256 _x) external payable {
        x = _x;
        value = msg.value;
    }

    function getXandValue() external view returns (uint256, uint256) {
        return (x, value);
    }

    function setXtoValue() external payable {
        x = msg.value;
    }

    function getValue() external view returns (uint256) {
        return value;
    }
}

contract CallTestContract {
    function setX(TestContract _test, uint256 _x) external {
        _test.setX(_x);
    }

    function setXfromAddress(address _addr, uint256 _x) external {
        TestContract test = TestContract(_addr);
        test.setX(_x);
    }

    function getX(address _addr) external view returns (uint256) {
        uint256 x = TestContract(_addr).getX();
        return x;
    }

    function setXandSendEther(TestContract _test, uint256 _x) external payable {
        _test.setXandReceiveEther{value: msg.value}(_x);
    }

    function getXandValue(address _addr)
        external
        view
        returns (uint256, uint256)
    {
        (uint256 x, uint256 value) = TestContract(_addr).getXandValue();
        return (x, value);
    }

    function setXwithEther(address _addr) external payable {
        TestContract test = TestContract(_addr);
        test.setXtoValue{value: msg.value}();
    }

    function getValue(address _addr) external view returns (uint256) {
        TestContract test = TestContract(_addr);
        return test.getValue();
    }
}
