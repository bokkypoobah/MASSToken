// Jul 14 2017
var ethPriceUSD = 205.452;

// -----------------------------------------------------------------------------
// Accounts
// -----------------------------------------------------------------------------
var accounts = [];
var accountNames = {};

addAccount(eth.accounts[0], "Account #0 - Miner");
addAccount(eth.accounts[1], "Account #1 - Contract Owner");
addAccount(eth.accounts[2], "Account #2 - ETH Fund");
addAccount(eth.accounts[3], "Account #3 - MASS Fund");
addAccount(eth.accounts[4], "Account #4 - ETH Fee");
addAccount(eth.accounts[5], "Account #5 - MASS Promisory");
addAccount(eth.accounts[6], "Account #6 - ETH Promisory");
addAccount(eth.accounts[7], "Account #7 - MASS Bounty");
addAccount(eth.accounts[8], "Account #8 - ETH Bounty");
addAccount(eth.accounts[9], "Account #9 - Contrib #1");
addAccount(eth.accounts[10], "Account #A - Contrib #2");
addAccount(eth.accounts[11], "Account #B - Contrib #2");

var minerAccount = eth.accounts[0];
var contractOwnerAccount = eth.accounts[1];
var ethFundAccount = eth.accounts[2];
var massFundAccount = eth.accounts[3];
var ethFeeAccount = eth.accounts[4];
var massPromisoryAccount = eth.accounts[5];
var ethPromisoryAccount = eth.accounts[6];
var massBountyAccount = eth.accounts[7];
var ethBountyAccount = eth.accounts[8];
var contrib1Account = eth.accounts[9];
var contrib2Account = eth.accounts[10];
var contrib3Account = eth.accounts[11];

var baseBlock = eth.blockNumber;

function unlockAccounts(password) {
  for (var i = 0; i < eth.accounts.length; i++) {
    personal.unlockAccount(eth.accounts[i], password, 100000);
  }
}

function addAccount(account, accountName) {
  accounts.push(account);
  accountNames[account] = accountName;
}


// -----------------------------------------------------------------------------
// Token Contract
// -----------------------------------------------------------------------------
var tokenContractAddress = null;
var tokenContractAbi = null;

function addTokenContractAddressAndAbi(address, tokenAbi) {
  tokenContractAddress = address;
  tokenContractAbi = tokenAbi;
}


// -----------------------------------------------------------------------------
// Account ETH and token balances
// -----------------------------------------------------------------------------
function printBalances() {
  var token = tokenContractAddress == null || tokenContractAbi == null ? null : web3.eth.contract(tokenContractAbi).at(tokenContractAddress);
  var decimals = token == null ? 18 : token.decimals();
  var i = 0;
  var totalTokenBalance = new BigNumber(0);
  console.log("RESULT:  # Account                                             EtherBalanceChange                          Token Name");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  accounts.forEach(function(e) {
    var etherBalanceBaseBlock = eth.getBalance(e, baseBlock);
    var etherBalance = web3.fromWei(eth.getBalance(e).minus(etherBalanceBaseBlock), "ether");
    var tokenBalance = token == null ? new BigNumber(0) : token.balanceOf(e).shift(-decimals);
    totalTokenBalance = totalTokenBalance.add(tokenBalance);
    console.log("RESULT: " + pad2(i) + " " + e  + " " + pad(etherBalance) + " " + padToken(tokenBalance, decimals) + " " + accountNames[e]);
    i++;
  });
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  console.log("RESULT:                                                                           " + padToken(totalTokenBalance, decimals) + " Total Token Balances");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  console.log("RESULT: ");
}

function pad2(s) {
  var o = s.toFixed(0);
  while (o.length < 2) {
    o = " " + o;
  }
  return o;
}

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

function padToken(s, decimals) {
  var o = s.toFixed(decimals);
  var l = parseInt(decimals)+12;
  while (o.length < l) {
    o = " " + o;
  }
  return o;
}


// -----------------------------------------------------------------------------
// Transaction status
// -----------------------------------------------------------------------------
function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  var gasPrice = tx.gasPrice;
  var gasCostETH = tx.gasPrice.mul(txReceipt.gasUsed).div(1e18);
  var gasCostUSD = gasCostETH.mul(ethPriceUSD);
  console.log("RESULT: " + name + " gas=" + tx.gas + " gasUsed=" + txReceipt.gasUsed + " costETH=" + gasCostETH +
    " costUSD=" + gasCostUSD + " @ ETH/USD=" + ethPriceUSD + " gasPrice=" + gasPrice + " block=" + 
    txReceipt.blockNumber + " txId=" + txId);
}

function assertEtherBalance(account, expectedBalance) {
  var etherBalance = web3.fromWei(eth.getBalance(account), "ether");
  if (etherBalance == expectedBalance) {
    console.log("RESULT: OK " + account + " has expected balance " + expectedBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has balance " + etherBalance + " <> expected " + expectedBalance);
  }
}

function gasEqualsGasUsed(tx) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  return (gas == gasUsed);
}

function failIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: PASS " + msg);
    return 1;
  } else {
    console.log("RESULT: FAIL " + msg);
    return 0;
  }
}

function failIfGasEqualsGasUsedOrContractAddressNull(contractAddress, tx, msg) {
  if (contractAddress == null) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    var gas = eth.getTransaction(tx).gas;
    var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
    if (gas == gasUsed) {
      console.log("RESULT: FAIL " + msg);
      return 0;
    } else {
      console.log("RESULT: PASS " + msg);
      return 1;
    }
  }
}

//-----------------------------------------------------------------------------
// PreSale Contract
//-----------------------------------------------------------------------------
var preSaleContractAddress = null;
var preSaleContractAbi = null;

function addPreSaleContractAddressAndAbi(address, abi) {
  preSaleContractAddress = address;
  preSaleContractAbi = abi;
}

var preSaleFromBlock = 0;
function printPreSaleContractDetails() {
  console.log("RESULT: preSaleContractAddress=" + preSaleContractAddress);
  // console.log("RESULT: crowdsaleContractAbi=" + JSON.stringify(crowdsaleContractAbi));
  if (preSaleContractAddress != null && preSaleContractAbi != null) {
    var contract = eth.contract(preSaleContractAbi).at(preSaleContractAddress);
    var decimals = contract.decimals();
    console.log("RESULT: preSale.isEnded=" + contract.isEnded());
    console.log("RESULT: preSale.contractOwner=" + contract.contractOwner());
    console.log("RESULT: preSale.massEthFund=" + contract.massEthFund());
    console.log("RESULT: preSale.presaleStartBlock=" + contract.presaleStartBlock());
    console.log("RESULT: preSale.presaleEndBlock=" + contract.presaleEndBlock());
    console.log("RESULT: preSale.tokenExchangeRate=" + contract.tokenExchangeRate());
    console.log("RESULT: preSale.tokenCap=" + contract.tokenCap().shift(-decimals));
    console.log("RESULT: preSale.totalSupply=" + contract.totalSupply().shift(-decimals));

    var latestBlock = eth.blockNumber;
    var i;

    var createPreSaleEvents = contract.CreatePreSale({}, { fromBlock: preSaleFromBlock, toBlock: latestBlock });
    i = 0;
    createPreSaleEvents.watch(function (error, result) {
      console.log("RESULT: CreatePreSale " + i++ + " #" + result.blockNumber + " _to=" + result.args._to + " _amount=" +
        result.args._amount.shift(-18));
    });
    createPreSaleEvents.stopWatching();

    preSaleFromBlock = parseInt(latestBlock) + 1;
  }
}


//-----------------------------------------------------------------------------
// Crowdsale Contract
//-----------------------------------------------------------------------------
var crowdsaleContractAddress = null;
var crowdsaleContractAbi = null;

function addCrowdsaleContractAddressAndAbi(address, abi) {
  crowdsaleContractAddress = address;
  crowdsaleContractAbi = abi;
}

var crowdsaleFromBlock = 0;
function printCrowdsaleContractDetails() {
  console.log("RESULT: crowdsaleContractAddress=" + crowdsaleContractAddress);
  // console.log("RESULT: crowdsaleContractAbi=" + JSON.stringify(crowdsaleContractAbi));
  if (crowdsaleContractAddress != null && crowdsaleContractAbi != null) {
    var contract = eth.contract(crowdsaleContractAbi).at(crowdsaleContractAddress);
    var decimals = contract.decimals();
    console.log("RESULT: crowdsale.name=" + contract.name());
    console.log("RESULT: crowdsale.symbol=" + contract.symbol());
    console.log("RESULT: crowdsale.decimals=" + decimals);
    console.log("RESULT: crowdsale.version=" + contract.version());
    console.log("RESULT: crowdsale.contractOwner=" + contract.contractOwner());
    console.log("RESULT: crowdsale.ethFundDeposit=" + contract.ethFundDeposit());
    console.log("RESULT: token.massFundDeposit=" + contract.massFundDeposit());
    console.log("RESULT: crowdsale.ethFeeDeposit=" + contract.ethFeeDeposit());
    console.log("RESULT: crowdsale.massPromisoryDeposit=" + contract.massPromisoryDeposit());
    console.log("RESULT: crowdsale.ethPromisoryDeposit=" + contract.ethPromisoryDeposit());
    console.log("RESULT: crowdsale.massBountyDeposit=" + contract.massBountyDeposit());
    console.log("RESULT: crowdsale.ethBountyDeposit=" + contract.ethBountyDeposit());
    console.log("RESULT: crowdsale.isFinalized=" + contract.isFinalized());
    console.log("RESULT: crowdsale.fundingStartBlock=" + contract.fundingStartBlock());
    console.log("RESULT: crowdsale.fundingEndBlock=" + contract.fundingEndBlock());
    console.log("RESULT: crowdsale.tokenExchangeRate=" + contract.tokenExchangeRate());
    console.log("RESULT: crowdsale.tokenCreationCap=" + contract.tokenCreationCap().shift(-decimals));
    console.log("RESULT: crowdsale.totalPreSale=" + contract.totalPreSale().shift(-18));
    console.log("RESULT: crowdsale.massFee=" + contract.massFee());
    console.log("RESULT: crowdsale.promisoryFee=" + contract.promisoryFee());
    console.log("RESULT: crowdsale.icoSaleBonus20=" + contract.icoSaleBonus20());
    console.log("RESULT: crowdsale.icoSaleBonus20Cap=" + contract.icoSaleBonus20Cap().shift(-decimals));
    console.log("RESULT: crowdsale.icoSaleBonus10=" + contract.icoSaleBonus10());
    console.log("RESULT: crowdsale.icoSaleBonus10Cap=" + contract.icoSaleBonus10Cap().shift(-decimals));

    console.log("RESULT: token._totalSupply=" + contract._totalSupply().shift(-decimals));
    console.log("RESULT: token.releaseFunds=" + contract.releaseFunds());
    console.log("RESULT: token.totalEthereum=" + contract.totalEthereum().shift(-18));
    console.log("RESULT: token.allowTransfers=" + contract.allowTransfers());
    var saleStart = contract.saleStart();
    console.log("RESULT: token.saleStart=" + saleStart + " " + new Date(saleStart * 1000).toUTCString());

    var latestBlock = eth.blockNumber;
    var i;

    var approvalEvents = contract.Approval({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    approvalEvents.watch(function (error, result) {
      console.log("RESULT: Approval " + i++ + " #" + result.blockNumber + " _owner=" + result.args._owner + " _spender=" + result.args._spender + " _amount=" +
        result.args._amount.shift(-decimals));
    });
    approvalEvents.stopWatching();

    var transferEvents = contract.Transfer({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    transferEvents.watch(function (error, result) {
      console.log("RESULT: Transfer " + i++ + " #" + result.blockNumber + ": _from=" + result.args._from + " _to=" + result.args._to +
        " _amount=" + result.args._amount.shift(-decimals));
    });
    transferEvents.stopWatching();

    var createMassEvents = contract.CreateMASS({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    createMassEvents.watch(function (error, result) {
      console.log("RESULT: CreateMASS " + i++ + " #" + result.blockNumber + ": _to=" + result.args._to +
        " _value=" + result.args._value.shift(-decimals));
    });
    createMassEvents.stopWatching();

    var updatedRewardsEvents = contract.UpdatedRewards({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    updatedRewardsEvents.watch(function (error, result) {
      console.log("RESULT: UpdatedRewards " + i++ + " #" + result.blockNumber + ": _to=" + result.args._to +
        " _value=" + result.args._value.shift(-decimals));
    });
    updatedRewardsEvents.stopWatching();

    var rewardSentEvents = contract.RewardSent({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    rewardSentEvents.watch(function (error, result) {
      console.log("RESULT: RewardSent " + i++ + " #" + result.blockNumber + ": _to=" + result.args._to +
        " _value=" + result.args._value.shift(-decimals));
    });
    rewardSentEvents.stopWatching();

    var blockRewardedEvents = contract.BlockRewarded({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    blockRewardedEvents.watch(function (error, result) {
      console.log("RESULT: BlockRewarded " + i++ + " #" + result.blockNumber + ": _remote=" + result.args._remote +
        " _value=" + result.args._value.shift(-decimals));
    });
    blockRewardedEvents.stopWatching();

    crowdsaleFromBlock = parseInt(latestBlock) + 1;
  }
}


//-----------------------------------------------------------------------------
// Token Contract
//-----------------------------------------------------------------------------
var tokenFromBlock = 0;
function printTokenContractDetails() {
  console.log("RESULT: tokenContractAddress=" + tokenContractAddress);
  // console.log("RESULT: tokenContractAbi=" + JSON.stringify(tokenContractAbi));
  if (tokenContractAddress != null && tokenContractAbi != null) {
    var contract = eth.contract(tokenContractAbi).at(tokenContractAddress);
    var decimals = contract.decimals();
    console.log("RESULT: token.controller=" + contract.controller());
    console.log("RESULT: token.symbol=" + contract.symbol());
    console.log("RESULT: token.name=" + contract.name());
    console.log("RESULT: token.decimals=" + decimals);
    console.log("RESULT: token.totalSupply=" + contract.totalSupply().shift(-decimals));
    // console.log("RESULT: token.mintingFinished=" + contract.mintingFinished());

    var latestBlock = eth.blockNumber;
    var i;

    var approvalEvents = contract.Approval({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    approvalEvents.watch(function (error, result) {
      console.log("RESULT: Approval " + i++ + " #" + result.blockNumber + " _owner=" + result.args._owner + " _spender=" + result.args._spender + " _amount=" +
        result.args._amount.shift(-decimals));
    });
    approvalEvents.stopWatching();

    var transferEvents = contract.Transfer({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    transferEvents.watch(function (error, result) {
      console.log("RESULT: Transfer " + i++ + " #" + result.blockNumber + ": _from=" + result.args._from + " _to=" + result.args._to +
        " _amount=" + result.args._amount.shift(-decimals));
    });
    transferEvents.stopWatching();

    tokenFromBlock = parseInt(latestBlock) + 1;
  }
}
