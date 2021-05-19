// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.3;
pragma experimental SMTChecker;

interface ERC20 {
    function transfer(address dst, uint amt) external returns (bool);
    function transferFrom(address src, address dst, uint amt) external returns (bool);
    function balanceOf(address usr) external returns (uint);
}

contract AMM {

    // --- pair tokens ---

    ERC20 public token0;
    ERC20 public token1;

    // --- erc20 data ---

    string  public constant name = "Token";
    string  public constant symbol = "TKN";
    uint8   public decimals = 18;
    uint256 public totalSupply;

    mapping (address => uint)                      public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    event Approval(address indexed src, address indexed guy, uint amt);
    event Transfer(address indexed src, address indexed dst, uint amt);

    // --- math ---

    function min(uint x, uint y) internal pure returns (uint z) { return x <= y ? x : y; }

    // --- init ---

    constructor(address _token0, address _token1) {
        token0 = ERC20(_token0);
        token1 = ERC20(_token1);
    }

    // --- amm ---

    // join allows the caller to exchange amt0 and amt1 tokens for some amount
    // of pool shares. The exact amount of pool shares minted depends on the
    // state of the pool at the time of the call.
    function join(uint amt0, uint amt1) external {
        require(amt0 > 0 && amt1 > 0, "insufficient input amounts");

        uint bal0 = token0.balanceOf(address(this));
        uint bal1 = token1.balanceOf(address(this));

        uint shares = totalSupply == 0
                      ? min(amt0, amt1)
                      : min((totalSupply * amt0) / bal0,
                            (totalSupply * amt1) / bal1);

        balanceOf[msg.sender] = balanceOf[msg.sender] + shares;
        totalSupply = totalSupply + shares;

        token0.transferFrom(msg.sender, address(this), amt0);
        token1.transferFrom(msg.sender, address(this), amt1);
    }

    // exit allows the caller to exchange shares pool shares for the
    // proportional amount of the underlying tokens.
    function exit(uint shares) external {
        uint amt0 = (token0.balanceOf(address(this)) * shares) / totalSupply;
        uint amt1 = (token1.balanceOf(address(this)) * shares) / totalSupply;

        balanceOf[msg.sender] = balanceOf[msg.sender] - shares;
        totalSupply = totalSupply - shares;

        token0.transfer(msg.sender, amt0);
        token1.transfer(msg.sender, amt1);
    }

    // swap allows the caller to exchange amt of src for dst at a price given
    // by the constant product formula: x * y == k.
    function swap(address src, address dst, uint amt) external {
        require(src != dst, "no self swap");
        require(src == address(token0) || src == address(token1), "src not in pair");
        require(dst == address(token0) || dst == address(token1), "dst not in pair");

        uint K = token0.balanceOf(address(this)) * token1.balanceOf(address(this));

        ERC20(src).transferFrom(msg.sender, address(this), amt);

        uint srcBal = ERC20(dst).balanceOf(address(this));
        uint dstBal = ERC20(dst).balanceOf(address(this));
        uint out = dstBal - K / srcBal + 1; // + 1 for rounding

        ERC20(dst).transfer(msg.sender, out);

        uint KPost = token0.balanceOf(address(this)) * token1.balanceOf(address(this));
        assert(KPost >= K);
    }

    // --- erc20  ---

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
