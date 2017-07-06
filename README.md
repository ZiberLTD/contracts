

## Ziber token and crowdsale features

* Zeppelin StandardToken with upgradeable trait (Golem like) and releaseable (owner can decide when tokens are transferred)
* Tokens are minted during the crowdsale (ZiberCrowdsale.assignTokens)
* Extra tokens for founders, seed round, etc. are minted after the crowdsale is over (ZiberTokenDistribution.distribute)
* Crowdsale priced in BGP (ZiberPricing.setConversionRate)
* Pricing has soft and hard cap (ZiberPricing.calculatePrice)
* Reaching soft cap triggers 240 hours (10 days) closing time (ZiberCrowdsale.triggerSoftCap)
* Crowdsale can whitelist early participants (Crowdsale.setEarlyParicipantWhitelist)
* Tokens are deposited to time locked vaults (MultiVault)
* The crowdsale can be stopped in emergency (Haltable)

## Installation

OSX or Linux required.

[Install solc 0.4.8](http://solidity.readthedocs.io/en/develop/installing-solidity.html#binary-packages). This exact version is required. Read full paragraph how to install it on OSX.

Install Populus in Python virtual environment.

Clone the repository and initialize submodules:

    git clone --recursive git@github.com:ZiberLTD/contracts.git

First Install Python 3.5. Then in the repo folder:

    cd contracts
    python3.5 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    pip install -e ico
    
Then test solc:

    solc --version
    
    solc, the solidity compiler commandline interface
    Version: 0.4.8+commit.60cc1668.Darwin.appleclang
    
Then test populus:
                                         
    populus          
    
    Usage: populus [OPTIONS] COMMAND [ARGS]...
    ...
                                                
## Compiling contracts
                   
Compile:                   
                             
    populus compile                                
                              
Output will be in `build` folder.                                       
                                        
## Running tests

Tests are written using `py.test` in tests folder.


##  Credits
Not to reinvent the wheel, we decided to go the more correct way and use the 
ready-made templates of ethereum smart contracts from the following projects:

https://github.com/OpenZeppelin/zeppelin-solidity/
https://github.com/MysteriumNetwork/contracts/                                                                           
https://github.com/TokenMarketNet/ico/

We express our deep gratitude to the developers of these projects without which there would
not be a ziber voip.