# PreSaleToken

Source file [../../../contracts/presale/PreSaleToken.sol](../../../contracts/presale/PreSaleToken.sol).

<br />

<hr />

```javascript
// BK NOTE - Should be 0.4.11; but was previously deployed
pragma solidity ^0.4.10;

// BK Ok - This is a non-transferable token contract interface 
contract Token {
    // BK Ok
    uint256 public totalSupply;
    // BK Ok
    function balanceOf(address _owner) constant returns (uint256 balance);
}


/*  ERC 20 token */
// BK Ok - This is a non-transferable token contract - just records the token balances
contract PreSaleToken is Token {

    // BK Ok
    function balanceOf(address _owner) constant returns (uint256 balance) {
    	// BK Ok
        return balances[_owner];
    }
    
    // BK Ok
    mapping (address => uint256) balances;
}
```