# MASSTokenPreSale

Source file [../../../contracts/presale/MASSTokenPreSale.sol](../../../contracts/presale/MASSTokenPreSale.sol).

Presale contract deployed to [0x63c0f17c1f72e1315e3d4f8a89a37d95f1314793](https://etherscan.io/address/0x63c0f17c1f72e1315e3d4f8a89a37d95f1314793#readContract), commencing from block 4014040 until block 4085220.

<br />

<hr />

```javascript
// BK NOTE - Should be 0.4.11; but was previously deployed
pragma solidity ^0.4.10;
// BK Next 2 Ok
import "./PreSaleToken.sol";
import "./SafeMath.sol";

// BK Ok
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
    
    // BK Ok - Receive contributions
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
        // BK Ok - Add new tokens to the account that sent the ETH 
        balances[msg.sender] += tokens;
        // BK Ok - Log event
        CreatePreSale(msg.sender, tokens);
    }
    
    // BK Ok
    function endPreSale() public {
        // BK Ok - Only contract owner can execute this
        require (msg.sender == contractOwner);
        // BK Ok - Can only call this once
        if (isEnded) throw;
        // BK NOTE - (block.number < presaleEndBlock && totalSupply != tokenCap) is the same as
        //         - !(block.number >= presaleEndBlock || totalSupply == tokenCap)
        // BK Ok - Can end presale if we are past the ending block or the cap has been reached
        if (block.number < presaleEndBlock && totalSupply != tokenCap) throw;
        // BK Ok - Signal end
        isEnded = true;
        // BK Ok
        if (!massEthFund.send(this.balance)) throw;
    }
}
```