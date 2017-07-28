# MASS.cloud Presale And Crowdsale Contract Audit

This is an audit of [MASS Cloud Ltd's crowdsale](https://MASS.cloud/) contracts.

TODO Commit [https://github.com/mass-ltd/MASSToken](https://github.com/mass-ltd/MASSToken).

<br />

<hr />

## Table Of Contents

* [Recommendation](#recommendation)
* [Potential Vulnerabilities](#potential-vulnerabilities)
* [Scope](#scope)
* [Limitations](#limitations)
* [Due Diligence](#due-diligence)
* [Risks](#risks)
* [Trustlessness Of The Crowdsale Contract](#trustlessness-of-the-crowdsale-contract)
* [TODO](#todo)
* [Notes](#notes)
* [Testing](#testing)
* [PreSale Contract Overview](#presale-contract-overview)
* [Crowdsale Contract Overview](#crowdsale-contract-overview)
* [Code Review](#code-review)

<br />

<hr />

## Recommendation

* LOW IMPORTANCE - The `MASSToken.changeOwnership(...)` should use the `acceptOwnership(...)` pattern to confirm the change in ownership. This
  is just for additional safety if the contract ownership needs to be changed.

* LOW IMPORTANCE - The crowdsale contracts should require the use of Solidity 0.4.11 or above instead of just 0.4.10 .

<br />

<hr />

## Potential Vulnerabilities

* [ ] TODO - Confirm that no potential vulnerabilities have been identified in the crowdsale and token contract.

<br />

<hr />

## Scope

This audit is into the technical aspects of the crowdsale contracts. The primary aim of this audit is to ensure that funds contributed to these contracts are not easily attacked or stolen by third parties. 
The secondary aim of this audit is that ensure the coded algorithms work as expected. This audit does not guarantee that that the code is bugfree, but intends to highlight any areas of
weaknesses.

<br />

<hr />

## Limitations

This audit makes no statements or warranties about the viability of the MASS Cloud Ltd's business proposition, the individuals involved in this business or the regulatory regime for the business model.

<br />

<hr />

## Due Diligence

As always, potential participants in any crowdsale are encouraged to perform their due diligence on the business proposition before funding the crowdsale.

Potential participants are also encouraged to only send their funds to the official crowdsale Ethereum address, published on MASS Cloud Ltd's official communication channel.

Scammers have been publishing phishing address in the forums, twitter and other communication channels, and some go as far as duplicating crowdsale websites.
Potential participants should NOT just click on any links received through these messages.
 
Potential participants should also confirm that the verified source code on EtherScan.io for the published crowdsale address matches the audited source code, and that 
the deployment parameters are correctly set, including the constant parameters.

* [ ] TODO - Any further issues

<br />

<hr />

## Risks

* The PreSale contract has a low security risk of hacks/trapping ETH/losing ETH, and this can be further reduced by passing ETH contributions directly into the owner's wallet
* [ ] TODO - Evaluate

<br />

<hr />

## Trustlessness Of The Crowdsale Contract

* MASS Cloud Ltd can enable and disable the token transfers in the MASSToken token contract at any time using the 
  `MASSToken.enableTransfers()` and `MASSToken.disableTransfers()`, and these functions are enabled once the crowdsale is finalised.

<br />

<hr />

## TODO

* [ ] Code review

* [ ] Test

<br />

<hr />

## Notes

* PreSale Contracts

  * `MASSTokenPreSale.decimals` and `MASSToken.decimals` should be declared as *uint8* instead of *uint256*. A number of token contracts
    already use *uint256* and these token contracts seem to be working correctly with other contracts that call the token contract's
    `decimals` and being returned a *uint256* instead of a *uint8*.

  * As there are no refunds in this non-transferable token contract, it would be slightly safer to move the ETH contributed by participants
    directly into the `massEthFund` wallet, when each contribution is made.

* Crowdsale Contracts

  * There are no minimum funding goal, and no caps

<br />

<hr />

## Testing

* PreSale Contract

  * The PreSale contract testing script [test/01_test1.sh](test/01_test1.sh) and results [test/test1results.txt](test/test1results.txt).

* Crowdsale Contract

  * The Crowdsale contract testing script [test/02_test2.sh](test/02_test2.sh) and results [test/test2results.txt](test/test2results.txt).

<br />

<hr />

## PreSale Contract Overview

* [x] This token contract is of low complexity
* [x] The code has been tested for a very limited subset of the normal [ERC20](https://github.com/ethereum/EIPs/issues/20) use cases:
  * [x] Deployment
  * [x] `balanceOf()` and `totalSupply()`
  * [x] **uint256** `decimals` INSTEAD OF the correct **uint8** decimals, but this is NOT IMPORTANT
  * [x] NO `transfer(...)` function, but this is NOT REQUIRED
  * [x] NO `approve(...)` and `transferFrom(...)` function, but this is NOT REQUIRED
* [x] NO `transferOwnership(...)` functionality
* [x] ETH contributed to this contract is NOT immediately moved to a separate wallet, but accumulates in this PreSale contract until the
  PreSale contract is finalised when the full balance is transferred to a standard or multisig wallet
  * [x] The ETH transfer to the wallet can only be executed once, by the owner
* [x] Once `finalize()`-d, the PreSale contract cannot accept further ETH contribution
* [x] ETH cannot be trapped in this contract due to the logic preventing ETH being sent to this contract outside the crowdfunding dates
* [x] There are NO divisions in this contract, so there should be no division by zero errors
* [x] All numbers used are **uint256**, INCLUDING `decimals`, reducing the risk of errors from type conversions
* [x] There are areas that are overflow protected and others that are NOT, but the numeric range in this contract is restricted to valid values so there should be no numeric overflows
* [x] There are NO areas requiring underflow protection
* [x] Function and event names are differentiated by case - function names begin with a lowercase character and event names begin with an uppercase character
* [x] The default function will receive contributions during the funding phase and mint NON-TRANSFERABLE token balances
  * [x] There is NO function to allow an account to contribute ETH for the tokens to be assigned to a different account (e.g. `proxyPayment(...)`), but this is NOT IMPORTANT
* [x] The is NO function for the owner to free any accidentally trapped ERC20 tokens and this is RECOMMENDED but NOT REQUIRED
* [x] There is no switch to pause and then restart the contract being able to receive contributions
* [x] The testing has been done using Geth/v1.6.7-stable-ab5646c5/darwin-amd64/go1.8.3 and solc 0.4.11+commit.68ef5810.Darwin.appleclang instead of one of the testing frameworks and JavaScript VMs to simulate the live environment as closely as possible
* [x] The test scripts can be found in [test/01_test1.sh](test/01_test1.sh)
* [x] The test results can be found in [test/test1results.txt](test/test1results.txt) for the results and [test/test1output.txt](test/test1output.txt) for the full output

<br />

<hr />

## Crowdsale Contract Overview

* [ ] This token contract is of low-moderate complexity
* [ ] The code has been tested for the normal [ERC20](https://github.com/ethereum/EIPs/issues/20) use cases, and around some of the boundary cases
  * [ ] Deployment, with correct `symbol()`, `name()`, `decimals()` and `totalSupply()`
  * [ ] `transfer(...)` from one account to another
  * [ ] `approve(...)` and `transferFrom(...)` from one account to another
  * While the `transfer(...)` and `transferFrom(...)` uses safe maths, there are checks so the function is able to return **true** and **false** instead of throwing an error
* `transfer(...)` and `transferFrom(...)` is only enabled when the crowdsale is finalised, when either the funds raised matches the cap, or the current time is beyond the crowdsale end date
* [ ] `transferOwnership(...)` and `acceptOwnership()` of the token contract
* [ ] ETH contributed to this contract is immediately moved to a separate wallet
* [ ] ETH cannot be trapped in this contract due to the logic preventing ETH being sent to this contract outside the crowdfunding dates
* [ ] There is only one statement with a division, and the divisor is a non-zero constant, so there should be no division by zero errors
  * `uint multisigTokens = tokens * 3 / 7;`
* [ ] All numbers used are **uint** (which is **uint256**), with the exception of `decimals`, reducing the risk of errors from type conversions
* [ ] Areas with potential overflow errors in `transfer(...)`, `transferFrom(...)`, `proxyPayment(...)` and `addPrecommitment(...)` have the logic to prevent overflows
* [ ] Areas with potential underflow errors in `transfer(...)` and `transferFrom(...)` have the logic to prevent underflows
* [ ] Function and event names are differentiated by case - function names begin with a lowercase character and event names begin with an uppercase character
* [ ] The default function will receive contributions during the crowdsale phase and mint tokens. Users can also directly call `proxyPayment(...)` to purchase tokens on behalf of another account
* [ ] The function `transferAnyERC20Token(...)` has been added in case the owner has to free any accidentally trapped ERC20 tokens
* [ ] There is no switch to pause and then restart the contract being able to receive contributions
* [ ] The [`transfer(...)`](https://github.com/ConsenSys/smart-contract-best-practices#be-aware-of-the-tradeoffs-between-send-transfer-and-callvalue) call is the last statements in the control flow of `proxyPayment(...)` to prevent the hijacking of the control flow
* NOTE that this contract does not implement the check for the number of bytes sent to functions to reject errors from the [short address attack](http://vessenes.com/the-erc20-short-address-attack-explained/)
* NOTE that this contract does not implement the modified `approve(...)` and `approveAnCall(...)` functions to mitigate the risk of [double spending](https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit#) in the `approve(...)` and `transferFrom(...)` calls
* [ ] The testing has been done using Geth/v1.6.7-stable-ab5646c5/darwin-amd64/go1.8.3 and solc 0.4.13+commit.0fb4cb1a.Darwin.appleclang instead of one of the testing frameworks and JavaScript VMs to simulate the live environment as closely as possible
* [ ] The test scripts can be found in [test/02_test2.sh](test/02_test2.sh)
* [ ] The test results can be found in [test/test2results.txt](test/test2results.txt) for the results and [test/test2output.txt](test/test2output.txt) for the full output

<br />

<hr />

## Code Review

* [x] [presale/MASSTokenPreSale.md](code-review/presale/MASSTokenPreSale.md)
  * [x] contract MASSTokenPreSale is PreSaleToken
* [x] [presale/PreSaleToken.md](code-review/presale/PreSaleToken.md)
  * [x] contract Token
  * [x] contract PreSaleToken is Token
* [MASSToken.md](code-review/MASSToken.md)
  * contract MASSToken is StandardToken
* [StandardToken.md](code-review/StandardToken.md)
  * [x] contract Token
  * contract StandardToken is Token
* [x] [SafeMath.md](code-review/SafeMath.md)
  * [x] library SafeMath

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for MASS Cloud Ltd - July 15 2017