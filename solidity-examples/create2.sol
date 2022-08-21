// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract DeployWithCreate2 {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }
}

contract ComputeCreate2Address {
    function getContractAddress(
        address _factory,
        address _owner,
        uint256 _salt
    ) external pure returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(DeployWithCreate2).creationCode,
            abi.encode(_owner)
        );

        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), _factory, _salt, keccak256(bytecode))
        );

        return address(uint160(uint256(hash)));
    }
}

contract Create2Factory {
    event Deploy(address addr);

    function deploy(uint256 _salt) external {
        DeployWithCreate2 _contract = new DeployWithCreate2{
            salt: bytes32(_salt)
        }(msg.sender);
        emit Deploy(address(_contract));
    }
}
