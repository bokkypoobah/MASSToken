# MASSTokenPreSale

Presale contract deployed to [0x63c0f17c1f72e1315e3d4f8a89a37d95f1314793](https://etherscan.io/address/0x63c0f17c1f72e1315e3d4f8a89a37d95f1314793#readContract), commencing from block 4014040 until block 4085220.

<br />

<hr />

```javascript
pragma solidity ^0.4.11;

/**
 * Math operations with safety checks
 */
// BK Ok
library SafeMath {
  // BK Ok
  function mul(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  // BK Ok
  function div(uint256 a, uint256 b) internal returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  // BK Unused
  function sub(uint256 a, uint256 b) internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  // BK Ok
  function add(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  // BK Unused
  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  // BK Unused
  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  // BK Unused
  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  // BK Unused
  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

}

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

contract MASSTokenPreSale is PreSaleToken {
    // BK Ok
    using SafeMath for uint256;

    // BK NOTE - This should be a uint8, but uint256 has been used with other tokens and seems to be working
    uint256 public constant decimals = 18;
    
    // BK Next 5 Ok
    bool public isEnded = false;
    address public contractOwner;
    address public massEthFund;
    uint256 public presaleStartBlock;
    uint256 public presaleEndBlock;
    // BK Ok
    uint256 public constant tokenExchangeRate = 1300;
    // BK Ok - 13,000,000 which is equivalent to 10,000 ETH
    uint256 public constant tokenCap = 13 * (10**6) * 10**decimals;
    
    // BK Ok - Event
    event CreatePreSale(address indexed _to, uint256 _amount);
    
    // BK Ok - Constructor
    function MASSTokenPreSale(address _massEthFund, uint256 _presaleStartBlock, uint256 _presaleEndBlock) {
        // BK Ok
        massEthFund = _massEthFund;
        // BK Ok
        presaleStartBlock = _presaleStartBlock;
        // BK Ok
        presaleEndBlock = _presaleEndBlock;
        // BK Ok
        contractOwner = massEthFund;
        // BK Ok
        totalSupply = 0;
    }
    
    // 
    function () payable public {
        // BK Ok - Cannot contribute if ended
        if (isEnded) throw;
        // BK Ok - Cannot contributed before starting block
        if (block.number < presaleStartBlock) throw;
        // BK Ok - Cannot contribute after ending block
        if (block.number > presaleEndBlock) throw;
        // BK Ok - Cannot contribute 0 value
        if (msg.value == 0) throw;
        
        // BK Ok - Calculate tokens
        uint256 tokens = msg.value.mul(tokenExchangeRate);
        // BK Ok - Add tokens to totalSupply
        uint256 checkedSupply = totalSupply.add(tokens);
        
        // BK Ok - Total supply cannot be greater than the cap
        if (tokenCap < checkedSupply) throw;
        
        // BK Ok - Save new total supply
        totalSupply = checkedSupply;
        // BK Ok - Add new tokens to the sending account 
        balances[msg.sender] += tokens;
        // BK Ok - Log event
        CreatePreSale(msg.sender, tokens);
    }
    
    // BK Ok
    function endPreSale() public {
        // BK Ok - Only contract owner can execute this
        require (msg.sender == contractOwner);
        // Can only call this once
        if (isEnded) throw;
        // Can end early if cap reached
        if (block.number < presaleEndBlock && totalSupply != tokenCap) throw;
        // BK Ok
        isEnded = true;
        // BK Ok
        if (!massEthFund.send(this.balance)) throw;
    }
}
```