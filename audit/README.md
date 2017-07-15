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

<br />

<hr />

## Testing

See [test/README.md](test/README.md), [test/01_test1.sh](test/01_test1.sh) and [test/test1results.txt](test/test1results.txt).

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