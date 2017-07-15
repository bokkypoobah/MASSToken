# StandardToken

Source file [../../contracts/StandardToken.sol](../../contracts/StandardToken.sol).

<br />

<hr />

```javascript
// BK NOTE - Should use at least 0.4.11
pragma solidity ^0.4.10;
// BK Ok
import "./SafeMath.sol";

// BK Ok
contract Token {
    // BK Ok
    uint256 public _totalSupply;
    // BK Ok - MASS's tokens are not released until after 1 year when MASSToken.releaseVestedMASS() can be called
    bool public releaseFunds = false;
    // BK Ok
    address public massFundDeposit; // deposit address for MASS for MASS Ltd. owned tokens
    uint256 public totalEthereum = 0; // Hold the total value of Ethereum of the entire pool, used to calculate cashout/burn.
    // BK Ok - ERC20 function
    function totalSupply() constant returns (uint totalSupply);
    // BK Ok - ERC20 function
    function balanceOf(address _owner) constant returns (uint256 balance);
    // BK Ok - ERC20 function
    function transfer(address _to, uint256 _value) returns (bool success);
    // BK Ok - ERC20 function
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    // BK Ok - ERC20 function
    function approve(address _spender, uint256 _value) returns (bool success);
    // BK Ok - ERC20 function
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    // BK Next 4 Ok
    function stake(uint256 _value);
    function balanceStaked(address _owner) constant returns (uint256 staked);
    function unstake(uint256 _value);
    function burn(uint256 _amount);
    // BK Ok - ERC20 event
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    // BK Ok - ERC20 event
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    // BK Next 3 Ok
    event Stake(address indexed _from, uint256 _value);
    event UnStake(address indexed _from, uint256 _value);
    event Burn(address indexed _owner, uint256 _value);
    
    // extra functionality while live
    // BK Ok - Transfers are initially disabled
    bool public allowTransfers = false; // Stop transfers during payout to prevent abuse.
    // Lock MASS Ltd. tokens for 1 year
    // BK Ok
    uint256 public saleStart;
}


/*  ERC 20 token */
contract StandardToken is Token {
    // BK Ok
    using SafeMath for uint256;
    
    // BK Ok
    function totalSupply() constant returns (uint256 totalSupply) {
      totalSupply = _totalSupply;
    }

    // BK OK - ERC20 transfer(...) that returns true/false instead of throwing
    function transfer(address _to, uint256 _value) returns (bool success) {
      // BK Ok - Cannot transfer when transfers are disabled
      if (!allowTransfers) return false;
      //if MASS Ltd. is trying to trade, check that it's been 1 year.
      // BK Ok - To disable transfer of MASS's tokens before the funds are released after 1 year
      if (msg.sender == massFundDeposit) {
          // BK Ok - Funds not released yet
          if(!releaseFunds) return false;
      }
      // BK NOTE - balances[msg.sender] >= _value - Account has the balance to transfer
      //           _value > 0                     - Amount being transferred is non-zero
      //         - There is no overflow protection, but the numbers are in the range
      //           where there should be no overflows
      if (balances[msg.sender] >= _value && _value > 0) {
        // BK Ok - Subtract tokens from the sender's account
        balances[msg.sender] -= _value;
        // BK Ok - Add tokens to the recipient's account
        balances[_to] += _value;
        // BK Ok - Log event
        Transfer(msg.sender, _to, _value);
        // BK Ok
        return true;
      } else {
        // BK Ok
        return false;
      }
    }

    // BK OK - ERC20 transferFrom(...) that returns true/false instead of throwing
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      // BK Ok - Cannot transfer when transfers are disabled
      if (!allowTransfers) return false;
      //if MASS Ltd. is trying to trade, check that it's been 1 year.
      // BK Ok - To disable transfer of MASS's tokens before the funds are released after 1 year
      if (_from == massFundDeposit) {
          // BK Ok - Funds not released yet
          if(!releaseFunds) return false;
      }
      // BK NOTE - balances[_from] >= _value             - Source account has the balance to transfer
      //           allowed[_from][msg.sender] >= _value  - Spending from the source account has been approved
      //           _value > 0                            - Amount being transferred is non-zero
      //         - There is no overflow protection, but the numbers are in the range
      //           where there should be no overflows
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        // BK Ok - Add tokens to the recipients account
        balances[_to] += _value;
        // BK Ok - Subtract tokens from the source account
        balances[_from] -= _value;
        // BK Ok - Subtract tokens from the current allowance
        allowed[_from][msg.sender] -= _value;
        // BK Ok - Log event
        Transfer(_from, _to, _value);
        // BK Ok
        return true;
      } else {
        // BK Ok
        return false;
      }
    }

    // BK Ok - ERC20 function
    function balanceOf(address _owner) constant returns (uint256 balance) {
        // BK Ok
        return balances[_owner];
    }

    // BK Ok - ERC20 function
    function approve(address _spender, uint256 _value) returns (bool success) {
        // BK Ok - Record allowance
        allowed[msg.sender][_spender] = _value;
        // BK Ok - Log event
        Approval(msg.sender, _spender, _value);
        // BK Ok
        return true;
    }

    // BK Ok - ERC20 function
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      // BK Ok
      return allowed[_owner][_spender];
    }
    
    function stake(uint256 _value) {
        if (!allowTransfers) throw; // Don't allow staking during payouts.
        if (balances[msg.sender] < _value) throw; // Check to make sure they are not staking more than they have.
        balances[msg.sender] -= _value;
        staking[msg.sender] += _value;
        Stake(msg.sender, _value);
    }
    
    function balanceStaked(address _owner) constant returns (uint256 staked) {
        return staking[_owner];
    }

    function unstake(uint256 _value) {
        if (!allowTransfers) throw; // Don't allow staking during payouts.
        if (staking[msg.sender] < _value) throw; // Make sure they can't unstake more than they have staked.
        balances[msg.sender] += _value;
        staking[msg.sender] -= _value;
        UnStake(msg.sender, _value);
    }
    
    //Allow token holders to cash out and burn their tokens.
    //The backend will handle the math and sending the eth since Solidity isn't efficient at math nor is it precise enough.
    function burn(uint256 _value) {
        if (!allowTransfers) throw; //Don't allow burning during payouts.
        if (now < saleStart + (60 days)) throw; //Don't allow burn/cashout for 2 months. TEST
        _totalSupply -= _value;
        balances[msg.sender] -= _value;
        Burn(msg.sender, _value);
    }
    
    // BK Ok - For ERC20 balances
    mapping (address => uint256) balances;
    mapping (address => uint256) staking;
    mapping (address => uint256) rewards;
    // BK Ok - For ERC20 allowance
    mapping (address => mapping (address => uint256)) allowed;
}
```