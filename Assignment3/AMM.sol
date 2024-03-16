// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyAMM{
    address immutable token0 = 0xA318615EfB7CC17975613F56C861b8D2e2E33874;
    address immutable token1 = 0x0deD4bA6223A4F26e7746EAF163133cb04B7C38f;
    uint256 conversionRate = 5000;
    uint256 reserve0;
    uint256 reserve1;
    uint256 totalSupply;
    mapping(address=>uint256) private balanceOf;
    constructor() {}
    function _update() internal {
        reserve0 = IERC20(token0).balanceOf(address(this));
        reserve1 = IERC20(token1).balanceOf(address(this));
        totalSupply = reserve0 + reserve1 * 10000 / conversionRate; // record the share based on token0
    }
    function update() external {
        // used to do the initial update after calling the mint() from the token contract
        _update();
    }
    function trade(address tokenFrom, uint256 fromAmount) external payable {
        require(tokenFrom == token0 || tokenFrom == token1);
        uint256 toAmount;
        address tokenTo;
        bool isToken0 = tokenFrom == token0;
        if (isToken0) { // Token0 to Token1
            tokenTo = token1;
            toAmount = fromAmount * conversionRate / 10000;
            require(toAmount <= reserve1, "Error: no enough token1 in the contract");
        }
        else { // Token1 to Tken0
            tokenFrom = token1;
            tokenTo = token0;
            toAmount = fromAmount * 10000 / conversionRate;
            require(toAmount <= reserve0, "Error: no enough token0 in the contract");
        }
        require(toAmount > 0, "Error: trading amount is too small");
        IERC20(tokenFrom).transferFrom(msg.sender, address(this), fromAmount);
        IERC20(tokenTo).transfer(msg.sender, toAmount);
        _update();
    }
    function provideLiquidity(uint256 token0Amount, uint256 token1Amount) external payable {
        uint256 _token1Amount = token0Amount * reserve1 / reserve0;
        uint256 _token0Amount = token1Amount * reserve0 / reserve1;
        if (_token0Amount > token0Amount) {
            _token0Amount = token0Amount;
        }
        else if (_token1Amount > token1Amount) {
            _token1Amount = token1Amount;
        }
        require(_token0Amount > 0 || _token1Amount > 0, "Error: providing amount is too small");
        balanceOf[msg.sender] = _token0Amount + _token1Amount * 10000 / conversionRate;
        IERC20(token0).transferFrom(msg.sender, address(this), _token0Amount);
        IERC20(token1).transferFrom(msg.sender, address(this), _token1Amount);
        _update();
    }
    function withdrawLiquidity() external payable {
        require(balanceOf[msg.sender] > 0, "Error: no share of this address");
        IERC20(token0).transfer(msg.sender, reserve0 * balanceOf[msg.sender] / totalSupply);
        IERC20(token1).transfer(msg.sender, reserve1 * balanceOf[msg.sender] / totalSupply);
        _update();
    }
}