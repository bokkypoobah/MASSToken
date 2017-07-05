pragma solidity ^0.4.10;
import "./SafeMath.sol";

contract Token {
    uint256 public totalSupply;
    bool public releaseFunds = false;
    address public massFundDeposit; // deposit address for MASS for MASS Ltd. owned tokens
    uint256 public totalEthereum = 0; // Hold the total value of Ethereum of the entire pool, used to calculate cashout/burn.
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    function stake(uint256 _value) returns (bool success);
    function balanceStaked(address _owner) constant returns (uint256 staked);
    function unstake(uint256 _value) returns (bool success);
    function burn(uint256 _amount) returns (bool success);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Stake(address indexed _from, uint256 _value);
    event UnStake(address indexed _from, uint256 _value);
    event Burn(address indexed _owner, uint256 _value);
    
    // extra functionality while live
    bool public allowTransfers = true; // Stop transfers during payout to prevent abuse.
    // Lock MASS Ltd. tokens for 1 year
    uint256 public saleStart;
}


/*  ERC 20 token */
contract StandardToken is Token {
    using SafeMath for uint256;

    function transfer(address _to, uint256 _value) returns (bool success) {
      if (!allowTransfers) throw;
      //if MASS Ltd. is trying to trade, check that it's been 1 year.
      if (msg.sender == massFundDeposit) {
          if(!releaseFunds) throw;
      }
      if (balances[msg.sender] >= _value && _value > 0) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (!allowTransfers) throw;
      //if MASS Ltd. is trying to trade, check that it's been 1 year.
      if (_from == massFundDeposit) {
          if(!releaseFunds) throw;
      }
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
    
    function stake(uint256 _value) returns (bool success) {
        if (!allowTransfers) throw; // Don't allow staking during payouts.
        if (balances[msg.sender] < _value) throw; // Check to make sure they are not staking more than they have.
        balances[msg.sender] -= _value;
        staking[msg.sender] += _value;
        Stake(msg.sender, _value);
        return true;
    }
    
    function balanceStaked(address _owner) constant returns (uint256 staked) {
        return staking[_owner];
    }

    function unstake(uint256 _value) returns (bool success) {
        if (!allowTransfers) throw; // Don't allow staking during payouts.
        if (staking[msg.sender] < _value) throw; // Make sure they can't unstake more than they have staked.
        balances[msg.sender] += _value;
        staking[msg.sender] -= _value;
        UnStake(msg.sender, _value);
        return true;
    }
    
    //Allow token holders to cash out and burn their tokens.
    function burn(uint256 _value) returns (bool success) {
        if (!allowTransfers) throw; //Don't allow burning during payouts.
        if (now < saleStart + (60 days)) throw; //Don't allow burn/cashout for 2 months.
        // do the math and payout.
        uint256 ethVal = (_value.div(totalSupply)).mul(totalEthereum);
        uint256 burnFee = ethVal.div(10);
        ethVal = ethVal.sub(burnFee);
        totalSupply -= _value;
        balances[msg.sender] -= _value;
        totalEthereum -= ethVal;
        Burn(msg.sender, _value);
        if(!msg.sender.send(ethVal)) throw;
        return true;
    }
    
    mapping (address => uint256) balances;
    mapping (address => uint256) staking;
    mapping (address => uint256) rewards;
    mapping (address => mapping (address => uint256)) allowed;
}
