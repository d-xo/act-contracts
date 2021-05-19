// Copyright (C) 2017, 2018, 2019, 2020 dbrock, rain, mrchico, xvwx
// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.3;

contract ERC20 {
    // --- ERC20 Data ---
    string  public constant name = "Token";
    string  public constant symbol = "TKN";
    uint8   public decimals = 18;
    uint256 public totalSupply;

    mapping (address => uint)                      public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    event Approval(address indexed src, address indexed guy, uint amt);
    event Transfer(address indexed src, address indexed dst, uint amt);

    // --- Init ---
    constructor(uint _totalSupply) {
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // --- Token ---
    function transfer(address dst, uint amt) virtual public returns (bool) {
        return transferFrom(msg.sender, dst, amt);
    }
    function transferFrom(address src, address dst, uint amt) virtual public returns (bool) {
        allowance[src][msg.sender] = allowance[src][msg.sender] - amt;
        balanceOf[src] = balanceOf[src] - amt;
        balanceOf[dst] = balanceOf[dst] + amt;
        emit Transfer(src, dst, amt);
        return true;
    }
    function approve(address usr, uint amt) virtual public returns (bool) {
        allowance[msg.sender][usr] = amt;
        emit Approval(msg.sender, usr, amt);
        return true;
    }
}
