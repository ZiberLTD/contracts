pragma solidity ^0.4.7;

import "./Crowdsale.sol";
import "./ZiberPricing.sol";
import "./MintableToken.sol";


contract ZiberCrowdsale is Crowdsale {
  using SafeMathLib for uint;

  // Are we on the "end slope" (triggered after soft cap)
  bool public softCapTriggered;

  // The default minimum funding limit 10,000,000 BGP
  uint public minimumFundingBGP = 1000000 * 10000;

  uint public hardCapBGP = 20000000 * 10000;

  function ZiberCrowdsale(address _token, PricingStrategy _pricingStrategy, address _multisigWallet, uint _start, uint _end)
    Crowdsale(_token, _pricingStrategy, _multisigWallet, _start, _end, 0) {
  }

  /// @dev triggerSoftCap triggers the earlier closing time
  function triggerSoftCap() private {
    if(softCapTriggered)
      throw;

    uint softCap = ZiberPricing(pricingStrategy).getSoftCapInWeis();

    if(softCap > weiRaised)
      endsAt = now
      EndsAtChanged(endsAt);
      throw;
      
    // When contracts are updated from upstream, you should use:
    // setEndsAt (now + 24 hours);
    endsAt = now + (24*3600);
    EndsAtChanged(endsAt);

    softCapTriggered = true;
  }

  /**
   * Hook in to provide the soft cap time bomb.
   */
  function onInvest() internal {
     if(!softCapTriggered) {
         uint softCap = ZiberPricing(pricingStrategy).getSoftCapInWeis();
         if(weiRaised > softCap) {
           triggerSoftCap();
         }
     }
  }

  /**
   * Get minimum funding goal in wei.
   */
  function getMinimumFundingGoal() public constant returns (uint goalInWei) {
    return ZiberPricing(pricingStrategy).convertToWei(minimumFundingBGP);
  }

  /**
   * Allow reset the threshold.
   */
  function setMinimumFundingLimit(uint bgp) onlyOwner {
    minimumFundingBGP = bgp;
  }

  /**
   * @return true if the crowdsale has raised enough money to be a succes
   */
  function isMinimumGoalReached() public constant returns (bool reached) {
    return weiRaised >= getMinimumFundingGoal();
  }

  function getHardCap() public constant returns (uint capInWei) {
    return ZiberPricing(pricingStrategy).convertToWei(hardCapBGP);
  }

  /**
   * Reset hard cap.
   *
   * Give price in BGP * 10000
   */
  function sethardCapBGP(uint _hardCapBGP) onlyOwner {
    hardCapBGP = _hardCapBGP;
  }

  /**
   * Called from invest() to confirm if the curret investment does not break our cap rule.
   */
  function isBreakingCap(uint weiAmount, uint tokenAmount, uint weiRaisedTotal, uint tokensSoldTotal) constant returns (bool limitBroken) {
    return weiRaisedTotal > getHardCap();
  }

  function isCrowdsaleFull() public constant returns (bool) {
    return weiRaised >= getHardCap();
  }

  /**
   * @return true we have reached our soft cap
   */
  function isSoftCapReached() public constant returns (bool reached) {
    return weiRaised >= ZiberPricing(pricingStrategy).getSoftCapInWeis();
  }


  /**
   * Dynamically create tokens and assign them to the investor.
   */
  function assignTokens(address receiver, uint tokenAmount) private {
    MintableToken mintableToken = MintableToken(token);
    mintableToken.mint(receiver, tokenAmount);
  }

}
