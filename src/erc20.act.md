# `ERC20`

The following is an executable specification for a simple token conforming to the `ERC20` standard.

## `constructor`

We define first the data and invariants of the contract. There are two critical invariants:

1. The `totalSupply` is constant
1. The sum of all elements in the `balanceOf` mapping will always be equal to `totalSupply`

The remaining invariants state simply that the `name`, `symbol`, and `decimals` storage slots are immutable.

```act
constructor of ERC20
interface constructor(uint _totalSupply, uint8 _decimals, string _name, string _symbol)

creates

  string name := _name
  string symbol := _symbol
  uint8 decimals := _decimals
  uint totalSupply := _totalSupply
  mapping (address => uint) balanceOf := [ CALLER := _totalSupply ]
  mapping (address => mapping (address => uint)) allowance := []

invariants

  totalSupply == _totalSupply
  name == _name
  symbol == _symbol
  decimals == _decimals
```

## Mutators

### `transfer`

The `transfer` method transfers `amt` tokens from the caller to the `dst` address.
`transfer` will revert on over / underflow and always returns `true` if the transfer has succeeded.

```act
behaviour transfer of ERC20
interface transfer(address to, uint amt)

iff

  CALLVALUE == 0
  amt <= balanceOf[CALLER]
  CALLER =/= to => balanceOf[to] + amt < 2^256

case CALLER =/= to:

  storage

     balanceOf[CALLER] => balanceOf[CALLER] - amt
     balanceOf[to]     => balanceOf[to] + amt

  returns true

case CALLER == to:

  storage

    balanceOf[CALLER]
    balanceOf[to]

  returns true
```

### `transferFrom`

`transferFrom` will transfer `amt` tokens from `src` to `dst`.

If `src` is not the caller, then the caller must have been approved by `src` for at least `amt`, and
the callers allowance from `src` will decrease by `amt`.

In the special case that the caller has been approved by `src` for `MAX_UINT` tokens, then the
allowance will not be decreased as a result of the call to `transferFrom`.

`transferFrom` will revert if there are any arithmetic over/underflows.

```act
behaviour transferFrom of ERC20
interface transferFrom(address src, address dst, uint amt)

iff

  amt <= balanceOf[CALLER]
  src    =/= dst => balanceOf[dst] + amt < 2^256
  CALLER =/= src => 0 <= allowance[src][CALLER] - amt
  CALLVALUE == 0

case src =/= dst and CALLER == src:

  storage

     balanceOf[CALLER]
     allowance[src][CALLER]
     balanceOf[src] => balanceOf[src] - amt
     balanceOf[dst] => balanceOf[dst] + amt

  returns true

case src =/= dst and CALLER =/= src and allowance[src][CALLER] == 2^256 - 1:

  storage

     balanceOf[CALLER]
     allowance[src][CALLER]
     balanceOf[src] => balanceOf[src] - amt
     balanceOf[dst] => balanceOf[dst] + amt

  returns true

case src =/= dst and CALLER =/= src and allowance[src][CALLER] < 2^256 - 1:

  storage

    balanceOf[CALLER]
    allowance[src][CALLER] => allowance[src][CALLER] - amt
    balanceOf[src]         => balanceOf[src] - amt
    balanceOf[dst]         => balanceOf[dst] + amt

  returns true

case src == dst:

  storage

     balanceOf[CALLER]
     allowance[src][CALLER]
     balanceOf[src]
     balanceOf[dst]

  returns true
```

### `approve`

`approve` allows the caller to set their allowance for `usr` to `amt`.

`approve` can never revert and always returns `true`

```act
behaviour approve of ERC20
interface approve(address usr, uint amt)

storage

  allowance[CALLER][usr] => amt

returns true
```

## Accessors

The following methods allow other smart contracts access to various regions of the contracts storage via an on chain call.

```act
behaviour name of ERC20
interface name()
storage name
returns name
```

```act
behaviour symbol of ERC20
interface symbol()
storage symbol
returns symbol
```

```act
behaviour decimals of ERC20
interface decimals()
storage decimals
returns decimals
```

```act
behaviour totalSupply of ERC20
interface totalSupply()
storage totalSupply
returns totalSupply
```

```act
behaviour balanceOf of ERC20
interface balanceOf(address usr)
storage balanceOf[usr]
returns balanceOf[usr]
```

```act
behaviour allowance of ERC20
interface allowance(address src, address dst)
storage allowance[src][dst]
returns allowance[src][dst]
```

