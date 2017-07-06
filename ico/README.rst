This package contains Ethereum smart contracts and Python based command line tools for launching your ICO crowdsale or token offering.

.. image:: https://img.shields.io/pypi/v/ico.svg
        :target: https://pypi.python.org/pypi/ico

.. image:: https://img.shields.io/travis/TokenMarketNet/ico.svg
        :target: https://travis-ci.org/TokenMarketNet/ico

.. image:: https://pyup.io/repos/github/TokenMarketNet/ico/shield.svg
     :target: https://pyup.io/repos/github/TokenMarketNet/ico/
     :alt: Updates

.. image:: https://readthedocs.org/projects/ico/badge/?version=latest
    :alt: Documentation Status
    :scale: 100%
    :target: https://ico.readthedocs.io/en/latest/?badge=latest

Links
=====

`Github issue tracker and source code <https://github.com/tokenmarketnet/ico>`_

`Documentation <https://ico.readthedocs.io/en/latest/>`_

About the project
=================

`ICO stands for a token or cryptocurrency initial offering crowdsale <https://tokenmarket.net/what-is/ico>`_. It is a common method in blockchain space, decentralized applications and in-game tokens for bootstrap funding of your project.

This project aims to provide standard, secure smart contracts and tools to create crowdsales for Ethereum blockchain.

As the writing of this, Ethereum smart contract ICO business has been booming almost a year. The industry and development teams are still figuring out the best practices. A lot of similar smart contracts get written over and over again. This project aims to tackle this problem by providing reusable ICO codebase, so that developers can focus on their own project specific value adding feature instead of rebuilding core crowdfunding logic. Having one well maintained codebase with best practice and security audits benefits the community as a whole.

This package provides

* Crowdsale contracts: token, ICO, uncapped ICO, pricing, transfer lock ups, token upgrade in Solidity smart contract programming language

* Automated test suite in Python

* Deployment tools and scripts

Features and design goals
=========================

* **Best practices**: Smart contracts are written with the modern best practices of Ethereum community

* **Separation of concerns**: Crowdsale, token and other logic lies in separate contracts that can be assembled together like lego bricks

* **Testable**: We aim for 100% branch code coverage by automated test suite

* **Auditable**: Our tool chain supports `verifiable EtherScan.io contract builds <http://ico.readthedocs.io/en/latest/verification.html>`_

* **Reusable**: The contract code is modularized and reusable across different projects, all variables are parametrized and there are no hardcoded values or magic numbers

* **Refund**: Built-in refund and minimum funding goal protect investors

* **Migration**: Token holders can opt in to a new version of the token contract in the case the token owner wants to add more functionality to their token

* **Reissuance**: There can be multiple crowdsales for the same token (pre-ICO, ICO, etc.)

* **Emergency stop**: To try to save the situation in the case we found an issue in the contract post-deploy

* **Build upon a foundation**: Instead of building everything from the scratch, use `OpenZeppelin contracts <https://github.com/OpenZeppelin/zeppelin-solidity/>`_ as much as possible as they are the gold standard of Solidity development

