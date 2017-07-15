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

* [ ] TODO - If any.

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

* [ ] TODO - Evaluate

<br />

<hr />

## TODO

* [ ] Code review

* [ ] Test

<br />

<hr />

## Notes

* TODO

<br />

<hr />

## Testing

See [test/README.md](test/README.md), [test/01_test1.sh](test/01_test1.sh) and [test/test1results.txt](test/test1results.txt).

<br />

<hr />

## Code Review

* [presale/MASSTokenPreSale.md](code-review/presale/MASSTokenPreSale.md)
  * contract MASSTokenPreSale is PreSaleToken
* [presale/PreSaleToken.md](code-review/presale/PreSaleToken.md)
  * contract Token
  * contract PreSaleToken is Token
* [MASSToken.md](code-review/MASSToken.md)
  * contract MASSToken is StandardToken
* [StandardToken.md](code-review/StandardToken.md)
  * contract Token
  * contract StandardToken is Token
* [SafeMath.md](code-review/SafeMath.md)
  * library SafeMath

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for MASS Cloud Ltd - July 15 2017