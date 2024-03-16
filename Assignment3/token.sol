// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Token0 is ERC20, ERC20Permit {
    constructor() ERC20("Token0", "TK0") ERC20Permit("Token0") {
        _mint(msg.sender, 10000000 * 10 ** decimals());
    }
    function mint(address target, uint256 amount) external { 
        // used to give the initial assset(2000 tokens) to amm
        _mint(target, amount);
    }
}

contract Token1 is ERC20, ERC20Permit {
    constructor() ERC20("Token1", "TK1") ERC20Permit("Token1") {
        _mint(msg.sender, 10000000 * 10 ** decimals());
    }
    function mint(address target, uint256 amount) external { 
        // used to give the initial assset(3000 tokens) to amm
        _mint(target, amount);
    }
}

