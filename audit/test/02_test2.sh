#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

PRESALECONTRACTSDIR=`grep ^PRESALECONTRACTSDIR= settings.txt | sed "s/^.*=//"`
CONTRACTSDIR=`grep ^CONTRACTSDIR= settings.txt | sed "s/^.*=//"`

MASSTOKENSOL=`grep ^MASSTOKENSOL= settings.txt | sed "s/^.*=//"`
MASSTOKENTEMPSOL=`grep ^MASSTOKENTEMPSOL= settings.txt | sed "s/^.*=//"`
MASSTOKENJS=`grep ^MASSTOKENJS= settings.txt | sed "s/^.*=//"`

STANDARDTOKENSOL=`grep ^STANDARDTOKENSOL= settings.txt | sed "s/^.*=//"`
STANDARDTOKENTEMPSOL=`grep ^STANDARDTOKENTEMPSOL= settings.txt | sed "s/^.*=//"`
STANDARDTOKENJS=`grep ^STANDARDTOKENJS= settings.txt | sed "s/^.*=//"`

SAFEMATHSOL=`grep ^SAFEMATHSOL= settings.txt | sed "s/^.*=//"`
SAFEMATHTEMPSOL=`grep ^SAFEMATHTEMPSOL= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST2OUTPUT=`grep ^TEST2OUTPUT= settings.txt | sed "s/^.*=//"`
TEST2RESULTS=`grep ^TEST2RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

# Setting time to be a block representing one day
BLOCKSINDAY=1

if [ "$MODE" == "dev" ]; then
  # Start time now
  STARTTIME=`echo "$CURRENTTIME" | bc`
else
  # Start time 1m 10s in the future
  STARTTIME=`echo "$CURRENTTIME+75" | bc`
fi
STARTTIME_S=`date -r $STARTTIME -u`
ENDTIME=`echo "$CURRENTTIME+60*4" | bc`
ENDTIME_S=`date -r $ENDTIME -u`

printf "MODE                    = '$MODE'\n"
printf "GETHATTACHPOINT         = '$GETHATTACHPOINT'\n"
printf "PASSWORD                = '$PASSWORD'\n"

printf "PRESALECONTRACTSDIR     = '$PRESALECONTRACTSDIR'\n"
printf "CONTRACTSDIR            = '$CONTRACTSDIR'\n"

printf "MASSTOKENSOL            = '$MASSTOKENSOL'\n"
printf "MASSTOKENTEMPSOL        = '$MASSTOKENTEMPSOL'\n"
printf "MASSTOKENJS             = '$MASSTOKENJS'\n"

printf "STANDARDTOKENSOL        = '$STANDARDTOKENSOL'\n"
printf "STANDARDTOKENTEMPSOL    = '$STANDARDTOKENTEMPSOL'\n"
printf "STANDARDTOKENJS         = '$STANDARDTOKENJS'\n"

printf "SAFEMATHSOL             = '$SAFEMATHSOL'\n"
printf "SAFEMATHTEMPSOL         = '$SAFEMATHTEMPSOL'\n"

printf "DEPLOYMENTDATA          = '$DEPLOYMENTDATA'\n"
printf "INCLUDEJS               = '$INCLUDEJS'\n"
printf "TEST2OUTPUT             = '$TEST2OUTPUT'\n"
printf "TEST2RESULTS            = '$TEST2RESULTS'\n"
printf "CURRENTTIME             = '$CURRENTTIME' '$CURRENTTIMES'\n"
printf "STARTTIME               = '$STARTTIME' '$STARTTIME_S'\n"
printf "ENDTIME                 = '$ENDTIME' '$ENDTIME_S'\n"

# Make copy of SOL file and modify start and end times ---
`cp $CONTRACTSDIR/$MASSTOKENSOL $MASSTOKENTEMPSOL`
`cp $CONTRACTSDIR/$STANDARDTOKENSOL $STANDARDTOKENTEMPSOL`
`cp $CONTRACTSDIR/$SAFEMATHSOL $SAFEMATHTEMPSOL`



# --- Modify parameters ---
#`perl -pi -e "s/tokenCap \= 13 \* \(10\*\*6\)/tokenCap \= 13 \* \(10\*\*4\)/" $MASSTOKENPRESALETEMPSOL`
#`perl -pi -e "s/tokenExchangeRate \= 1300/tokenExchangeRate \= 13/" $MASSTOKENPRESALETEMPSOL`
#`perl -pi -e "s/deadline \=  1499436000;.*$/deadline = $ENDTIME; \/\/ $ENDTIME_S/" $FUNFAIRSALETEMPSOL`
#`perl -pi -e "s/\/\/\/ \@return total amount of tokens.*$/function overloadedTotalSupply() constant returns (uint256) \{ return totalSupply; \}/" $DAOCASINOICOTEMPSOL`
#`perl -pi -e "s/BLOCKS_IN_DAY \= 5256;*$/BLOCKS_IN_DAY \= $BLOCKSINDAY;/" $DAOCASINOICOTEMPSOL`

DIFFS1=`diff $CONTRACTSDIR/$MASSTOKENSOL $MASSTOKENTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$MASSTOKENSOL $MASSTOKENTEMPSOL ---"
echo "$DIFFS1"

DIFFS1=`diff $CONTRACTSDIR/$STANDARDTOKENSOL $STANDARDTOKENTEMPSOL`
echo "--- Differences $CONTRACTSDIR/$STANDARDTOKENSOL $STANDARDTOKENTEMPSOL ---"
echo "$DIFFS1"

echo "var mtOutput=`solc --optimize --combined-json abi,bin,interface $MASSTOKENTEMPSOL`;" > $MASSTOKENJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee $TEST2OUTPUT
loadScript("$MASSTOKENJS");
loadScript("functions.js");

var mtAbi = JSON.parse(mtOutput.contracts["$MASSTOKENTEMPSOL:MASSToken"].abi);
var mtBin = "0x" + mtOutput.contracts["$MASSTOKENTEMPSOL:MASSToken"].bin;

// console.log("DATA: mtAbi=" + JSON.stringify(mtAbi));

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");

// -----------------------------------------------------------------------------
// Deploy MASSToken
// -----------------------------------------------------------------------------
var mtMessage = "Deploy MASSToken - Cap 100 ETH 130,000 MASS";
console.log("RESULT: " + mtMessage);
var startBlock = parseInt(eth.blockNumber) + 2;
var endBlock = parseInt(eth.blockNumber) + 100;
var mtContract = web3.eth.contract(mtAbi);
var mtTx = null;
var mtAddress = null;
var mt = mtContract.new(ethFundAccount, massFundAccount, ethFeeAccount, massPromisoryAccount, ethPromisoryAccount, massBountyAccount, 
    ethBountyAccount, startBlock, endBlock, {from: contractOwnerAccount, data: mtBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        mtTx = contract.transactionHash;
      } else {
        mtAddress = contract.address;
        addAccount(mtAddress, "MASSToken");
        addTokenContractAddressAndAbi(mtAddress, mtAbi);
        addCrowdsaleContractAddressAndAbi(mtAddress, mtAbi);
        printTxData("mtAddress=" + mtAddress, mtTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(mtTx, mtMessage);
printCrowdsaleContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait until startBlock 
// -----------------------------------------------------------------------------
console.log("RESULT: Waiting until startBlock #" + startBlock + " currentBlock=" + eth.blockNumber);
while (eth.blockNumber <= startBlock) {
}
console.log("RESULT: Waited until startBlock #" + startBlock + " currentBlock=" + eth.blockNumber);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var contribution1Message = "Crowdsale contribution";
// -----------------------------------------------------------------------------
console.log("RESULT: " + contribution1Message);
var contribution1Tx = eth.sendTransaction({from: contrib1Account, to: mtAddress, gas: 400000, value: web3.toWei("1", "ether")});
var contribution2Tx = eth.sendTransaction({from: contrib2Account, to: mtAddress, gas: 400000, value: web3.toWei("99", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("contribution1Tx", contribution1Tx);
printTxData("contribution2Tx", contribution2Tx);
printBalances();
failIfGasEqualsGasUsed(contribution1Tx, contribution1Message + " contrib1 1 ETH 1200 MASS");
failIfGasEqualsGasUsed(contribution2Tx, contribution1Message + " contrib2 99 ETH 118,800 MASS");
printCrowdsaleContractDetails();
console.log("RESULT: ");


exit;

// -----------------------------------------------------------------------------
var presaleContribution2Message = "PreSale contribution - Cap reached";
// -----------------------------------------------------------------------------
console.log("RESULT: " + presaleContribution2Message);
var presaleContribution3Tx = eth.sendTransaction({from: account5, to: mtpsAddress, gas: 400000, value: web3.toWei("1", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("presaleContribution3Tx", presaleContribution3Tx);
printBalances();
passIfGasEqualsGasUsed(presaleContribution3Tx, presaleContribution1Message + " ac5 1 ETH 1,300 MTPS fail");
printPreSaleContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var endPresaleMessage = "End PreSale early - Cap reached. Called by MASS ETH Fund";
// -----------------------------------------------------------------------------
console.log("RESULT: " + endPresaleMessage);
var endPresaleTx = mtps.endPreSale({from: massEthFund, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("endPresaleTx", endPresaleTx);
printBalances();
failIfGasEqualsGasUsed(endPresaleTx, endPresaleMessage);
printPreSaleContractDetails();
console.log("RESULT: ");


exit;

// -----------------------------------------------------------------------------
// Deploy AIT
// -----------------------------------------------------------------------------
var aitMessage = "Deploy AIT";
console.log("RESULT: " + aitMessage);
var aitContract = web3.eth.contract(aitAbi);
var aitTx = null;
var aitAddress = null;
var ait = aitContract.new(mmtfAddress, {from: contractOwnerAccount, data: aitBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        aitTx = contract.transactionHash;
      } else {
        aitAddress = contract.address;
        addAccount(aitAddress, "AIT");
        addTokenContractAddressAndAbi(aitAddress, aitAbi);
        printTxData("aitAddress=" + aitAddress, aitTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(aitTx, aitMessage);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Deploy PreSale
// -----------------------------------------------------------------------------
var psMessage = "Deploy PreSale";
console.log("RESULT: " + psMessage);
var psContract = web3.eth.contract(psAbi);
var psTx = null;
var psAddress = null;
var ps = psContract.new(aitAddress, {from: contractOwnerAccount, data: psBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        psTx = contract.transactionHash;
      } else {
        psAddress = contract.address;
        addAccount(psAddress, "PreSale");
        addCrowdsaleContractAddressAndAbi(psAddress, psAbi);
        printTxData("psAddress=" + psAddress, psTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(psTx, psMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// AIT ChangeController To PreSale 
// -----------------------------------------------------------------------------
var aitChangeControllerMessage = "AIT ChangeController To PreSale";
console.log("RESULT: " + aitChangeControllerMessage);
var aitChangeControllerTx = ait.changeController(psAddress, {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("aitChangeControllerTx", aitChangeControllerTx);
printBalances();
failIfGasEqualsGasUsed(aitChangeControllerTx, aitChangeControllerMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Initialise PreSale 
// -----------------------------------------------------------------------------
var initialisePresaleMessage = "Initialise PreSale";
var maxAitSupply = "1000000000000000000000000";
// Minimum investment in wei
var minimumInvestment = 10;
var startBlock = parseInt(eth.blockNumber) + 5;
var endBlock = parseInt(eth.blockNumber) + 10;
console.log("RESULT: " + initialisePresaleMessage);
var initialisePresaleTx = ps.initialize(maxAitSupply, minimumInvestment, startBlock, endBlock, {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("initialisePresaleTx", initialisePresaleTx);
printBalances();
failIfGasEqualsGasUsed(initialisePresaleTx, initialisePresaleMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait until startBlock 
// -----------------------------------------------------------------------------
console.log("RESULT: Waiting until startBlock #" + startBlock + " currentBlock=" + eth.blockNumber);
while (eth.blockNumber <= startBlock) {
}
console.log("RESULT: Waited until startBlock #" + startBlock + " currentBlock=" + eth.blockNumber);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var validContribution1Message = "Send Valid Contribution - 100 ETH From Account3";
console.log("RESULT: " + validContribution1Message);
var validContribution1Tx = eth.sendTransaction({from: account3, to: psAddress, gas: 400000, value: web3.toWei("100", "ether")});
var validContribution2Tx = eth.sendTransaction({from: account4, to: aitAddress, gas: 400000, value: web3.toWei("10", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("validContribution1Tx", validContribution1Tx);
printTxData("validContribution2Tx", validContribution2Tx);
printBalances();
failIfGasEqualsGasUsed(validContribution1Tx, validContribution1Message + " ac3->ps 100 ETH");
failIfGasEqualsGasUsed(validContribution2Tx, validContribution1Message + " ac4->ait 10 ETH");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait until endBlock 
// -----------------------------------------------------------------------------
console.log("RESULT: Waiting until endBlock #" + endBlock + " currentBlock=" + eth.blockNumber);
while (eth.blockNumber <= endBlock) {
}
console.log("RESULT: Waited until endBlock #" + endBlock + " currentBlock=" + eth.blockNumber);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Claim ETH 
// -----------------------------------------------------------------------------
var claimEthersMessage = "Claim Ethers";
console.log("RESULT: " + claimEthersMessage);
var claimEthersTx = ps.claimTokens(0, {from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("claimEthersTx", claimEthersTx);
printBalances();
failIfGasEqualsGasUsed(claimEthersTx, claimEthersMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Finalise PreSale 
// -----------------------------------------------------------------------------
var finalisePresaleMessage = "Initialise PreSale";
console.log("RESULT: " + finalisePresaleMessage);
var finalisePresaleTx = ps.finalize({from: contractOwnerAccount, gas: 2000000});
while (txpool.status.pending > 0) {
}
printTxData("finalisePresaleTx", finalisePresaleTx);
printBalances();
failIfGasEqualsGasUsed(finalisePresaleTx, finalisePresaleMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


exit;


var name = "Feed";
var symbol = "FEED";
var initialSupply = 0;
// NOTE: 8 or 18, does not make a difference in the tranches calculations
var decimals = 18;
var mintable = true;

var minimumFundingGoal = new BigNumber(1000).shift(18);
var cap = new BigNumber(2000).shift(18);

#      0 to 15,000 ETH 10,000 FEED = 1 ETH
# 15,000 to 28,000 ETH  9,000 FEED = 1 ETH
var tranches = [ \
  0, new BigNumber(1).shift(18).div(10000), \
  new BigNumber(1500).shift(18), new BigNumber(1).shift(18).div(9000), \
  cap, 0 \
];

var teamMembers = [ team1, team2, team3 ];
var teamBonus = [150, 150, 150];

// -----------------------------------------------------------------------------
var cstMessage = "Deploy CrowdsaleToken Contract";
console.log("RESULT: " + cstMessage);
var cstContract = web3.eth.contract(cstAbi);
console.log(JSON.stringify(cstContract));
var cstTx = null;
var cstAddress = null;

var cst = cstContract.new(name, symbol, initialSupply, decimals, mintable, {from: contractOwnerAccount, data: cstBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        cstTx = contract.transactionHash;
      } else {
        cstAddress = contract.address;
        addAccount(cstAddress, "Token '" + symbol + "' '" + name + "'");
        addTokenContractAddressAndAbi(cstAddress, cstAbi);
        console.log("DATA: teAddress=" + cstAddress);
      }
    }
  }
);


// -----------------------------------------------------------------------------
var etpMessage = "Deploy PricingStrategy Contract";
console.log("RESULT: " + etpMessage);
var etpContract = web3.eth.contract(etpAbi);
console.log(JSON.stringify(etpContract));
var etpTx = null;
var etpAddress = null;

var etp = etpContract.new(tranches, {from: contractOwnerAccount, data: etpBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        etpTx = contract.transactionHash;
      } else {
        etpAddress = contract.address;
        addAccount(etpAddress, "PricingStrategy");
        // addCstContractAddressAndAbi(etpAddress, etpAbi);
        console.log("DATA: etpAddress=" + etpAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printTxData("cstAddress=" + cstAddress, cstTx);
printTxData("etpAddress=" + etpAddress, etpTx);
printBalances();
failIfGasEqualsGasUsed(cstTx, cstMessage);
failIfGasEqualsGasUsed(etpTx, etpMessage);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var mecMessage = "Deploy MintedEthCappedCrowdsale Contract";
console.log("RESULT: " + mecMessage);
var mecContract = web3.eth.contract(mecAbi);
console.log(JSON.stringify(mecContract));
var mecTx = null;
var mecAddress = null;

var mec = mecContract.new(cstAddress, etpAddress, multisig, $STARTTIME, $ENDTIME, minimumFundingGoal, cap, {from: contractOwnerAccount, data: mecBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        mecTx = contract.transactionHash;
      } else {
        mecAddress = contract.address;
        addAccount(mecAddress, "Crowdsale");
        addCrowdsaleContractAddressAndAbi(mecAddress, mecAbi);
        console.log("DATA: mecAddress=" + mecAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printTxData("mecAddress=" + mecAddress, mecTx);
printBalances();
failIfGasEqualsGasUsed(mecTx, mecMessage);
printCrowdsaleContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var bfaMessage = "Deploy BonusFinalizerAgent Contract";
console.log("RESULT: " + bfaMessage);
var bfaContract = web3.eth.contract(bfaAbi);
console.log(JSON.stringify(bfaContract));
var bfaTx = null;
var bfaAddress = null;

var bfa = bfaContract.new(cstAddress, mecAddress, teamBonus, teamMembers, {from: contractOwnerAccount, data: bfaBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        bfaTx = contract.transactionHash;
      } else {
        bfaAddress = contract.address;
        addAccount(bfaAddress, "BonusFinalizerAgent");
        console.log("DATA: bfaAddress=" + bfaAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printTxData("bfaAddress=" + bfaAddress, bfaTx);
printBalances();
failIfGasEqualsGasUsed(bfaTx, bfaMessage);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var invalidContribution1Message = "Send Invalid Contribution - 100 ETH From Account6 - Before Crowdsale Start";
console.log("RESULT: " + invalidContribution1Message);
var invalidContribution1Tx = eth.sendTransaction({from: account6, to: mecAddress, gas: 400000, value: web3.toWei("100", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("invalidContribution1Tx", invalidContribution1Tx);
printBalances();
passIfGasEqualsGasUsed(invalidContribution1Tx, invalidContribution1Message);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var stitchMessage = "Stitch Contracts Together";
console.log("RESULT: " + stitchMessage);
var stitch1Tx = cst.setMintAgent(mecAddress, true, {from: contractOwnerAccount, gas: 400000});
var stitch2Tx = cst.setMintAgent(bfaAddress, true, {from: contractOwnerAccount, gas: 400000});
var stitch3Tx = cst.setReleaseAgent(bfaAddress, {from: contractOwnerAccount, gas: 400000});
var stitch4Tx = cst.setTransferAgent(mecAddress, true, {from: contractOwnerAccount, gas: 400000});
var stitch5Tx = mec.setFinalizeAgent(bfaAddress, {from: contractOwnerAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("stitch1Tx", stitch1Tx);
printTxData("stitch2Tx", stitch2Tx);
printTxData("stitch3Tx", stitch3Tx);
printTxData("stitch4Tx", stitch4Tx);
printTxData("stitch5Tx", stitch5Tx);
printBalances();
failIfGasEqualsGasUsed(stitch1Tx, stitchMessage + " 1");
failIfGasEqualsGasUsed(stitch2Tx, stitchMessage + " 2");
failIfGasEqualsGasUsed(stitch3Tx, stitchMessage + " 3");
failIfGasEqualsGasUsed(stitch4Tx, stitchMessage + " 4");
failIfGasEqualsGasUsed(stitch5Tx, stitchMessage + " 5");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for crowdsale start
// -----------------------------------------------------------------------------
var startsAtTime = mec.startsAt();
var startsAtTimeDate = new Date(startsAtTime * 1000);
console.log("RESULT: Waiting until startAt date at " + startsAtTime + " " + startsAtTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= startsAtTimeDate.getTime()) {
}
console.log("RESULT: Waited until start date at " + startsAtTime + " " + startsAtTimeDate +
  " currentDate=" + new Date());


// -----------------------------------------------------------------------------
var validContribution1Message = "Send Valid Contribution - 100 ETH From Account6 - After Crowdsale Start";
console.log("RESULT: " + validContribution1Message);
var validContribution1Tx = mec.investWithCustomerId(account6, 123, {from: account6, to: mecAddress, gas: 400000, value: web3.toWei("100", "ether")});

while (txpool.status.pending > 0) {
}
printTxData("validContribution1Tx", validContribution1Tx);
printBalances();
failIfGasEqualsGasUsed(validContribution1Tx, validContribution1Message);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var validContribution2Message = "Send Valid Contribution - 1900 ETH From Account7 - After Crowdsale Start";
console.log("RESULT: " + validContribution1Message);
var validContribution2Tx = mec.investWithCustomerId(account7, 124, {from: account7, to: mecAddress, gas: 400000, value: web3.toWei("1900", "ether")});

while (txpool.status.pending > 0) {
}
printTxData("validContribution2Tx", validContribution2Tx);
printBalances();
failIfGasEqualsGasUsed(validContribution2Tx, validContribution2Message);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var finaliseMessage = "Finalise Crowdsale";
console.log("RESULT: " + finaliseMessage);
var finaliseTx = mec.finalize({from: contractOwnerAccount, to: mecAddress, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("finaliseTx", finaliseTx);
printBalances();
failIfGasEqualsGasUsed(finaliseTx, finaliseMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var transfersMessage = "Testing token transfers";
console.log("RESULT: " + transfersMessage);
var transfers1Tx = cst.transfer(account8, "1000000000000000000", {from: account6, gas: 100000});
var transfers2Tx = cst.approve(account9,  "2000000000000000000", {from: account7, gas: 100000});
while (txpool.status.pending > 0) {
}
var transfers3Tx = cst.transferFrom(account7, account9, "2000000000000000000", {from: account9, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("transfers1Tx", transfers1Tx);
printTxData("transfers2Tx", transfers2Tx);
printTxData("transfers3Tx", transfers3Tx);
printBalances();
failIfGasEqualsGasUsed(transfers1Tx, transfersMessage + " - transfer 1 token ac6 -> ac8");
failIfGasEqualsGasUsed(transfers2Tx, transfersMessage + " - approve 2 tokens ac7 -> ac9");
failIfGasEqualsGasUsed(transfers3Tx, transfersMessage + " - transferFrom 2 tokens ac7 -> ac9");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var invalidPaymentMessage = "Send invalid payment to token contract";
console.log("RESULT: " + invalidPaymentMessage);
var invalidPaymentTx = eth.sendTransaction({from: account7, to: cstAddress, gas: 400000, value: web3.toWei("123", "ether")});

while (txpool.status.pending > 0) {
}
printTxData("invalidPaymentTx", invalidPaymentTx);
printBalances();
passIfGasEqualsGasUsed(invalidPaymentTx, invalidPaymentMessage);
printTokenContractDetails();
console.log("RESULT: ");


exit;


// -----------------------------------------------------------------------------
// Wait for crowdsale end
// -----------------------------------------------------------------------------
var endsAtTime = mec.endsAt();
var endsAtTimeDate = new Date(endsAtTime * 1000);
console.log("RESULT: Waiting until startAt date at " + endsAtTime + " " + endsAtTimeDate +
  " currentDate=" + new Date());
while ((new Date()).getTime() <= endsAtTimeDate.getTime()) {
}
console.log("RESULT: Waited until start date at " + endsAtTime + " " + endsAtTimeDate +
  " currentDate=" + new Date());

EOF
grep "DATA: " $TEST2OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST2OUTPUT | sed "s/RESULT: //" > $TEST2RESULTS
cat $TEST2RESULTS
