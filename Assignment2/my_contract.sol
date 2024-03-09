// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.2/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@5.0.2/token/ERC20/extensions/ERC20Permit.sol";

contract ChuanYuWu is ERC20, ERC20Permit {
    address master;
    address censor;
    mapping(address => bool) private _blacklist;
    constructor() ERC20("ChuanYuWu", "CYW") ERC20Permit("ChuanYuWu") {
        _mint(msg.sender, 100000000 * 10 ** decimals());
        master = msg.sender;
        censor = msg.sender;
    }

    modifier onlyMaster() {
        require(msg.sender == master);
        _;
    }
    modifier onlyMasterAndCencor() {
        require(msg.sender == master || msg.sender == censor);
        _;
    }

    // function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
    //     super._beforeTokenTransfer(from, to, amount);
    //     require(!_blacklist[from] && !_blacklist[to]);
    // }

    function _update(address from, address to, uint256 value) internal virtual override  { 
        // override the function to make sure that addresses in _blacklist could not do any transfer
        require(!_blacklist[from] && !_blacklist[to]);
        super._update(from, to, value);
    }
    function changeMaster(address newMaster) external onlyMaster {
        master = newMaster;
    }
    function changeCensor(address newCensor) external onlyMaster {
        censor = newCensor;
    }
    function setBlacklist(address target, bool blacklisted) external onlyMasterAndCencor {
        _blacklist[target] = blacklisted;
    }
    function clawBack(address target, uint256 amount) external onlyMaster {
        _transfer(target, master, amount);
    }
    function mint(address target, uint256 amount) external onlyMaster {
        _mint(target, amount);
    }
    function burn(address target, uint256 amount) external onlyMaster {
        _burn(target, amount);
    }
}
