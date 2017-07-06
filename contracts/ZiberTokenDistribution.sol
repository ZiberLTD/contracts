pragma solidity ^0.4.6;

import "./Crowdsale.sol";
import "./CrowdsaleToken.sol";
import "./SafeMathLib.sol";
import "./ZiberPricing.sol";
import "zeppelin/contracts/ownership/Ownable.sol";

/**
 * At the end of the successful crowdsale allocate % bonus of tokens and other parties.
 *
 * Unlock tokens.
 *
 */
contract ZiberTokenDistribution is FinalizeAgent, Ownable {

  using SafeMathLib for uint;

  CrowdsaleToken public token;
  Crowdsale public crowdsale;

  ZiberPricing public ZiberPricing;

  // Vaults:
  address futureRoundVault;
  address foundationWallet;
  address teamVault;
  address seedVault1; //  0
  address seedVault2; //  12 months

  // Expose the state of distribute for the examination
  uint public future_round_coins;
  uint public foundation_coins;
  uint public dev_coins;
  uint public bonus_coins;
  uint public team_coins;
  // uint public seed_coins_vault1;
  // uint public seed_coins_vault2;

  function ZiberTokenDistribution(CrowdsaleToken _token, Crowdsale _crowdsale, ZiberPricing _ZiberPricing) {
    token = _token;
    crowdsale = _crowdsale;

    // Interface check
    if(!crowdsale.isCrowdsale()) {
      throw;
    }

    ZiberPricing = _ZiberPricing;
  }

  /**
   * Post crowdsale distribution process.
   *
   * Exposed as public to make it testable.
   */
  function distribute(uint amount_raised_BGP, uint eth_BGP_price) {

    // Only crowdsale contract or owner (manually) can trigger the distribution
    if(!(msg.sender == address(crowdsale) || msg.sender == owner)) {
      throw;
    }

    // Distribute:
    // seed coins
    // foundation coins
    // team coins
    // future_round_coins

    future_round_coins = 100000000000;
    foundation_coins = 80000000000;
    bonus_сoins = 10000000000;
    dev_coins = 10000000000
    team_coins = bonus_сoins + dev_coins;
    // seed_coins_vault1 = 122400000000000;
    // seed_coins_vault2 = 489600000000000;

    token.mint(futureRoundVault, future_round_coins);
    token.mint(foundationWallet, foundation_coins);
    token.mint(teamVault, team_coins);
    // token.mint(seedVault1, seed_coins_vault1);
    // token.mint(seedVault2, seed_coins_vault2);
  }

  /// @dev Here you can set all the Vaults
  function setVaults(
    address _futureRoundVault,
    address _foundationWallet,
    address _teamVault,
    address _seedVault1,
    address _seedVault2
  ) onlyOwner {
    futureRoundVault = _futureRoundVault;
    foundationWallet = _foundationWallet;
    teamVault = _teamVault;
    seedVault1 = _seedVault1;
    seedVault2 = _seedVault2;
  }

  /* Can we run finalize properly */
  function isSane() public constant returns (bool) {
    // TODO: Check all vaults implement the correct vault interface
    return true;
  }

  function getDistributionFacts() public constant returns (uint BGPRaised, uint BGPRate) {
    uint _BGPRate = ZiberPricing.getEthBGPPrice();
    return(crowdsale.weiRaised().times(_BGPRate) / (10**18), _BGPRate);
  }

  /** Called once by crowdsale finalize() if the sale was success. */
  function finalizeCrowdsale() public {

    if(msg.sender == address(crowdsale) || msg.sender == owner) {
      // The owner can distribute tokens for testing and in emergency
      // Crowdsale distributes tokens at the end of the crowdsale
      var (BGPRaised, BGPRate) = getDistributionFacts();
      distribute(BGPRaised, BGPRate);
    } else {
       throw;
    }
  }

}
