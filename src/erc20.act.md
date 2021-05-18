# `ERC20`

The following is an executable specification for a simple token conforming to the `ERC20` standard.

The spec currently uses the following (as yet) unimplemented features of the `act` language:

- min / max operators for types (e.g. `max(uint256)`)
- block local variable binding using `let`
- specification of logging behaviour using the `logs` block
- single branch case statements
- ommision of variable declarations for storage reads (i.e. if you just read from a storage var, you
    don't need to declare it in the `storage` block)
- `pre` and `post` operators in the `ensures` block
- nested case expressions
- case local `iff`
- a `sum` operator for mappings

## `constructor`

We define first the data and invariants of the contract. There are two critical invariants:

1. The `totalSupply` is constant
1. The sum of all elements in the `balanceOf` mapping will always be equal to `totalSupply`

The remaining invariants state simply that the `name`, `symbol`, and `decimals` storage slots are immutable.

```act
constructor of ERC20
interface constructor(uint _totalSupply)

creates

  string name := "Token"
  string symbol = "TKN"
  uint8 decimals = 18
  uint totalSupply := _totalSupply
  mapping (address => uint) balanceOf := [ CALLER := _totalSupply ]
  mapping (address => mapping (address => uint)) allowance := []

logs

  Transfer(address(0), CALLER, _totalSupply)

invariants

  sum(balanceOf) == _totalSupply
  totalSupply == _totalSupply
  name == "Token"
  symbol == "TKN"
  decimals == 18
```

## Mutators

### `transfer`

The `transfer` method transfers `amt` tokens from the caller to the `dst` address.
`transfer` will revert on over / underflow and always returns `true` if the transfer has succeeded.

The following postconditions must hold:

- `dst`'s balance cannot decrease
- `CALLER`'s balance cannot increase
- `dst`'s balance must increase by the same amount as `CALLER`'s decreases

```act
behaviour transfer of Token
interface transfer(address dst, uint amt) returns bool

iff in range uint256

  balanceOf[CALLER] - amt

case CALLER =/= dst:

  iff balanceOf[dst] + amt <= max(uint)

  storage

     balanceOf[CALLER] => balanceOf[CALLER] - amt
     balanceOf[dst]    => balanceOf[dst] + amt

ensures

  pre(balanceOf[dst]) <= post(balanceOf[dst])
  pre(balanceOf[CALLER]) >= post(balanceOf[CALLER])
  post(balanceOf[dst]) - pre(balanceOf[dst]) == pre(balanceOf[CALLER]) - post(balanceOf[CALLER])

logs Transfer(CALLER, dst, amt)
returns true
```

### `transferFrom`

`transferFrom` will transfer `amt` tokens from `src` to `dst`.

If `src` is not the caller, then the caller must have been approved by `src` for at least `amt`, and
the callers allowance from `src` will decrease by `amt`.

In the special case that the caller has been approved by `src` for `MAX_UINT` tokens, then the
allowance will not be decreased as a result of the call to `transferFrom`.

`transferFrom` will revert if there are any arithmetic over/underflows.

The following postconditions must hold:

- the callers approval from `src` cannot decrease
- `src`'s balance cannot increase
- `dst`'s balance cannot decrease
- `src`'s balance must decrease by the same amount as `dst`'s balance increases

```act
behaviour transferFrom of Token
interface transferFrom(address src, address dst, uint amt) returns bool

iff amt <= balanceOf[src]

case src =/= dst:

  iff balanceOf[dst] + amt <= MAX_UINT

  storage

    balanceOf[src] => balanceOf[src] - amt
    balanceOf[dst] => balanceOf[dst] + amt

  case CALLER =/= src and allowance[src][CALLER] < max(uint256):

    iff amt <= allowance[src][CALLER]

    storage

      allowance[src][CALLER] => allowance[src][CALLER] - amt

ensures

  let approval = allowance[src][CALLER]
      srcBal = balanceOf[src]
      dstBal = balanceOf[dst]

  pre(approval) >= post(approval)
  pre(srcBal) >= post(srcBal)
  pre(dstBal) <= post(dstBal)
  pre(srcBal) - post(srcBal) == post(dstBal) - pre(dstBal)

logs Transfer(src, dst, amt)
returns true
```

### `approve`

`approve` allows the caller to set their allowance for `usr` to `amt`.

`approve` can never revert and always returns `true`

```act
behaviour approve of ERC20
interface approve(address usr, uint amt) returns bool

storage

  allowance[CALLER][usr] => amt

logs

  Approval(CALLER, usr, wad);

returns true
```

## Accessors

The following methods allow other smart contracts access to various regions of the contracts storage via an on chain call.

```act
behaviour name of ERC20
interface name()
returns name
```

```act
behaviour symbol of ERC20
interface symbol()
returns symbol
```

```act
behaviour decimals of ERC20
interface decimals()
returns decimals
```

```act
behaviour totalSupply of ERC20
interface totalSupply()
returns totalSupply
```

```act
behaviour balanceOf of ERC20
interface balanceOf(address usr)
returns balanceOf[usr]
```

```act
behaviour allowance of ERC20
interface allowance(address src, address dst)
returns allowance[src][dst]
```

