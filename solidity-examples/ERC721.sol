// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IERC721.sol";

contract ERC721 is IERC721 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed id
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    // Mapping from token ID to owner address
    mapping(uint256 => address) internal _ownerOf;

    // Mapping owner address to token count
    mapping(address => uint256) internal _balanceOf;

    // Mapping from token ID to approved address
    mapping(uint256 => address) internal _approvals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function ownerOf(uint256 id) external view returns (address owner) {
        owner = _ownerOf[id];
        require(owner != address(0), "token doesn't exist");
    }

    function balanceOf(address owner) external view returns (uint256 balance) {
        require(owner != address(0), "address zero");
        balance = _balanceOf[owner];
    }

    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = true;

        emit ApprovalForAll(msg.sender, operator, true);
    }

    function getApproved(uint256 id) external view returns (address approved) {
        require(_ownerOf[id] != address(0), "address zero");
        approved = _approvals[id];
    }

    function approve(address to, uint256 id) external {
        address owner = _ownerOf[id];
        require(
            msg.sender == owner || isApprovedForAll[owner][msg.sender],
            "Not Authorized"
        );

        _approvals[id] = to;
        emit Approval(msg.sender, to, id);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public {
        require(from == _ownerOf[id], "from != owner");
        require(to != address(0), "address zero");

        require(
            msg.sender == from ||
                isApprovedForAll[from][msg.sender] ||
                msg.sender == _approvals[id],
            "not authorized"
        );

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[id] = to;

        delete _approvals[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) external {
        require(from == _ownerOf[id], "from != owner");
        require(to != address(0), "address zero");

        require(
            msg.sender == from ||
                isApprovedForAll[from][msg.sender] ||
                msg.sender == _approvals[id],
            "not authorized"
        );

        if (to.code.length > 0) {
            IERC721Receiver(to).onERC721Received(msg.sender, from, id, "") ==
                IERC721Receiver.onERC721Received.selector;
        }

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[id] = to;

        delete _approvals[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) external {
        require(from == _ownerOf[id], "from != owner");
        require(to != address(0), "address zero");

        require(
            msg.sender == from ||
                isApprovedForAll[from][msg.sender] ||
                msg.sender == _approvals[id],
            "not authorized"
        );

        if (to.code.length > 0) {
            IERC721Receiver(to).onERC721Received(msg.sender, from, id, data) ==
                IERC721Receiver.onERC721Received.selector;
        }

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[id] = to;

        delete _approvals[id];

        emit Transfer(from, to, id);
    }

    function mint(address to, uint256 id) external {
        require(to != address(0), "zero address");
        require(_ownerOf[id] == address(0), "already minted");

        _ownerOf[id] = to;
        _balanceOf[to] += 1;

        emit Transfer(address(0), to, id);
    }

    function burn(uint256 id) external {
        require(_ownerOf[id] == msg.sender, "not owner");

        _balanceOf[msg.sender] -= 1;

        delete _ownerOf[id];
        delete _approvals[id];

        emit Transfer(msg.sender, address(0), id);
    }
}
