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

MASSTOKENPRESALESOL=`grep ^MASSTOKENPRESALESOL= settings.txt | sed "s/^.*=//"`
MASSTOKENPRESALETEMPSOL=`grep ^MASSTOKENPRESALETEMPSOL= settings.txt | sed "s/^.*=//"`
MASSTOKENPRESALEJS=`grep ^MASSTOKENPRESALEJS= settings.txt | sed "s/^.*=//"`

PRESALETOKENSOL=`grep ^PRESALETOKENSOL= settings.txt | sed "s/^.*=//"`
PRESALETOKENTEMPSOL=`grep ^PRESALETOKENTEMPSOL= settings.txt | sed "s/^.*=//"`
PRESALETOKENJS=`grep ^PRESALETOKENJS= settings.txt | sed "s/^.*=//"`

SAFEMATHSOL=`grep ^SAFEMATHSOL= settings.txt | sed "s/^.*=//"`
SAFEMATHTEMPSOL=`grep ^SAFEMATHTEMPSOL= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

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

printf "MASSTOKENPRESALESOL     = '$MASSTOKENPRESALESOL'\n"
printf "MASSTOKENPRESALETEMPSOL = '$MASSTOKENPRESALETEMPSOL'\n"
printf "MASSTOKENPRESALEJS      = '$MASSTOKENPRESALEJS'\n"

printf "PRESALETOKENSOL         = '$PRESALETOKENSOL'\n"
printf "PRESALETOKENTEMPSOL     = '$PRESALETOKENTEMPSOL'\n"
printf "PRESALETOKENJS          = '$PRESALETOKENJS'\n"

printf "SAFEMATHSOL             = '$SAFEMATHSOL'\n"
printf "SAFEMATHTEMPSOL         = '$SAFEMATHTEMPSOL'\n"

printf "DEPLOYMENTDATA          = '$DEPLOYMENTDATA'\n"
printf "INCLUDEJS               = '$INCLUDEJS'\n"
printf "TEST1OUTPUT             = '$TEST1OUTPUT'\n"
printf "TEST1RESULTS            = '$TEST1RESULTS'\n"
printf "CURRENTTIME             = '$CURRENTTIME' '$CURRENTTIMES'\n"
printf "STARTTIME               = '$STARTTIME' '$STARTTIME_S'\n"
printf "ENDTIME                 = '$ENDTIME' '$ENDTIME_S'\n"

# Make copy of SOL file and modify start and end times ---
`cp $PRESALECONTRACTSDIR/$MASSTOKENPRESALESOL $MASSTOKENPRESALETEMPSOL`
`cp $PRESALECONTRACTSDIR/$PRESALETOKENSOL $PRESALETOKENTEMPSOL`
`cp $CONTRACTSDIR/$SAFEMATHSOL $SAFEMATHTEMPSOL`

# --- Modify parameters ---
`perl -pi -e "s/tokenCap \= 13 \* \(10\*\*6\)/tokenCap \= 13 \* \(10\*\*4\)/" $MASSTOKENPRESALETEMPSOL`

DIFFS1=`diff $PRESALECONTRACTSDIR/$MASSTOKENPRESALESOL $MASSTOKENPRESALETEMPSOL`
echo "--- Differences $PRESALECONTRACTSDIR/$MASSTOKENPRESALESOL $MASSTOKENPRESALETEMPSOL ---"
echo "$DIFFS1"

DIFFS1=`diff $PRESALECONTRACTSDIR/$PRESALETOKENSOL $PRESALETOKENTEMPSOL`
echo "--- Differences $PRESALECONTRACTSDIR/$PRESALETOKENSOL $PRESALETOKENTEMPSOL ---"
echo "$DIFFS1"

echo "var mtpsOutput=`solc --optimize --combined-json abi,bin,interface $MASSTOKENPRESALETEMPSOL`;" > $MASSTOKENPRESALEJS


geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee $TEST1OUTPUT
loadScript("$MASSTOKENPRESALEJS");
loadScript("functions.js");

var mtpsAbi = JSON.parse(mtpsOutput.contracts["$MASSTOKENPRESALETEMPSOL:MASSTokenPreSale"].abi);
var mtpsBin = "0x" + mtpsOutput.contracts["$MASSTOKENPRESALETEMPSOL:MASSTokenPreSale"].bin;

// console.log("DATA: mtpsAbi=" + JSON.stringify(mtpsAbi));

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");

// -----------------------------------------------------------------------------
// Deploy MASSTokenPreSale
// -----------------------------------------------------------------------------
var mtpsMessage = "Deploy MASSTokenPreSale - Cap 100 ETH 130,000 MTPS";
console.log("RESULT: " + mtpsMessage);
var presaleStartBlock = parseInt(eth.blockNumber) + 2;
var presaleEndBlock = parseInt(eth.blockNumber) + 100;
var mtpsContract = web3.eth.contract(mtpsAbi);
var mtpsTx = null;
var mtpsAddress = null;
var mtps = mtpsContract.new(ethFundAccount, presaleStartBlock, presaleEndBlock, {from: contractOwnerAccount, data: mtpsBin, gas: 4000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        mtpsTx = contract.transactionHash;
      } else {
        mtpsAddress = contract.address;
        addAccount(mtpsAddress, "MASSTokenPreSale");
        addTokenContractAddressAndAbi(mtpsAddress, mtpsAbi);
        addPreSaleContractAddressAndAbi(mtpsAddress, mtpsAbi);
        printTxData("mtpsAddress=" + mtpsAddress, mtpsTx);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfGasEqualsGasUsed(mtpsTx, mtpsMessage);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait until presaleStartBlock 
// -----------------------------------------------------------------------------
console.log("RESULT: Waiting until presaleStartBlock #" + presaleStartBlock + " currentBlock=" + eth.blockNumber);
while (eth.blockNumber <= presaleStartBlock) {
}
console.log("RESULT: Waited until presaleStartBlock #" + presaleStartBlock + " currentBlock=" + eth.blockNumber);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var presaleContribution1Message = "PreSale contribution";
// -----------------------------------------------------------------------------
console.log("RESULT: " + presaleContribution1Message);
var presaleContribution1Tx = eth.sendTransaction({from: contrib1Account, to: mtpsAddress, gas: 400000, value: web3.toWei("1", "ether")});
var presaleContribution2Tx = eth.sendTransaction({from: contrib2Account, to: mtpsAddress, gas: 400000, value: web3.toWei("99", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("presaleContribution1Tx", presaleContribution1Tx);
printTxData("presaleContribution2Tx", presaleContribution2Tx);
printBalances();
failIfGasEqualsGasUsed(presaleContribution1Tx, presaleContribution1Message + " contrib1 1 ETH 1300 MTPS");
failIfGasEqualsGasUsed(presaleContribution2Tx, presaleContribution1Message + " contrib2 99 ETH 128,700 MTPS");
printPreSaleContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var presaleContribution2Message = "PreSale contribution - Cap reached";
// -----------------------------------------------------------------------------
console.log("RESULT: " + presaleContribution2Message);
var presaleContribution3Tx = eth.sendTransaction({from: contrib3Account, to: mtpsAddress, gas: 400000, value: web3.toWei("1", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("presaleContribution3Tx", presaleContribution3Tx);
printBalances();
passIfGasEqualsGasUsed(presaleContribution3Tx, presaleContribution1Message + " contrib3 1 ETH 1,300 MTPS fail");
printPreSaleContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var endPresaleMessage = "End PreSale early - Cap reached. Called by MASS ETH Fund";
// -----------------------------------------------------------------------------
console.log("RESULT: " + endPresaleMessage);
var endPresaleTx = mtps.endPreSale({from: ethFundAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("endPresaleTx", endPresaleTx);
printBalances();
failIfGasEqualsGasUsed(endPresaleTx, endPresaleMessage);
printPreSaleContractDetails();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
