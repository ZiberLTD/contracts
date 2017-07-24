pragma solidity ^0.4.13;

import '/src/common/SafeMath.sol';
import '/src/common/lifecycle/Haltable.sol';
import '/src/common/lifecycle/Killable.sol';
import '/src/ico/ZiberToken.sol';

/// @title ZiberCrowdsale contract - contract for token sales.
/// @author dev@smartcontracteam.com
contract ZiberCrowdsale is Haltable, Killable, SafeMath {

  /// Total count of tokens distributed via ICO
  uint public constant TOTAL_ICO_TOKENS = 1e8;

  /// Miminal tokens funding goal in Wei, if this goal isn't reached during ICO, refund will begin
  uint public constant MIN_ICO_GOAL = 5e3 ether;

  /// Maximal tokens funding goal in Wei
  uint public constant MAX_ICO_GOAL = 5e4 ether;

  /// the UNIX timestamp 5e4 ether funded
  uint public maxGoalReachedAt = 0;

  /// The duration of ICO
  uint public constant ICO_DURATION = 10 days;

  /// The duration of ICO
  uint public constant AFTER_MAX_GOAL_DURATION = 24 hours;

  /// The token we are selling
  ZiberToken public token;

  /// the UNIX timestamp start date of the crowdsale
  uint public startsAt;

  /// How many wei of funding we have raised
  uint public weiRaised = 0;

  /// How much wei we have returned back to the contract after a failed crowdfund.
  uint public loadedRefund = 0;

  /// How much wei we have given back to investors.
  uint public weiRefunded = 0;

  /// Has this crowdsale been finalized
  bool public finalized;

  /// How much ETH each address has invested to this crowdsale
  mapping (address => uint256) public investedAmountOf;

  /// How much tokens this crowdsale has credited for each investor address
  mapping (address => uint256) public tokenAmountOf;

  /// Define a structure for one investment event occurrence
  struct Investment {
      /// Who invested
      address source;
      /// Amount invested
      uint weiValue;
  }

  Investment[] public investments;

  /// State machine
  /// Preparing: All contract initialization calls and variables have not been set yet
  /// Prefunding: We have not passed start time yet
  /// Funding: Active crowdsale
  /// Success: Minimum funding goal reached
  /// Failure: Minimum funding goal not reached before ending time
  /// Finalized: The finalized has been called and succesfully executed\
  /// Refunding: Refunds are loaded on the contract for reclaim.
  enum State {Unknown, Preparing, Funding, Success, Failure, Finalized, Refunding}

  /// A new investment was made
  event Invested(address investor, uint weiAmount);
  /// Refund was processed for a contributor
  event Refund(address investor, uint weiAmount);

  /// @dev Modified allowing execution only if the crowdsale is currently running
  modifier inState(State state) {
    require(getState() == state);
    _;
  }

  /// @dev Constructor
  /// @param _token Pay Fair token address
  /// @param _start token ICO start date
  function Crowdsale(address _token, uint _start) {
    require(_token != 0);
    require(_start != 0);

    owner = msg.sender;
    token = ZiberToken(_token);
    startsAt = _start;
  }

  ///  Don't expect to just send in money and get tokens.
  function() payable {
    buy();
  }

   /// @dev Make an investment. Crowdsale must be running for one to invest.
   /// @param receiver The Ethereum address who receives the tokens
  function investInternal(address receiver) stopInEmergency private {
    var state = getState();
    require(state == State.Funding);
    require(msg.value > 0);

    // Add investment record
    var weiAmount = msg.value;
    investedAmountOf[receiver] = safeAdd(investedAmountOf[receiver], weiAmount);
    investments.push(Investment(receiver, weiAmount));

    // Update totals
    weiRaised = safeAdd(weiRaised, weiAmount);
    // Max ICO goal reached at
    if(maxGoalReachedAt == 0 && weiRaised >= MAX_ICO_GOAL)
      maxGoalReachedAt = now;
    // Tell us invest was success
    Invested(receiver, weiAmount);
  }

  /// @dev Allow anonymous contributions to this crowdsale.
  /// @param receiver The Ethereum address who receives the tokens
  function invest(address receiver) public payable {
    investInternal(receiver);
  }

  /// @dev The basic entry point to participate the crowdsale process.
  function buy() public payable {
    invest(msg.sender);
  }

  /// @dev Finalize a succcesful crowdsale.
  function finalize() public inState(State.Success) onlyOwner stopInEmergency {
    require(!finalized);

    finalized = true;
    finalizeCrowdsale();
  }

  /// @dev Owner can withdraw contract funds
  function withdraw() public onlyOwner {
    // Transfer funds to the team wallet
    owner.transfer(this.balance);
  }

  /// @dev Finalize a succcesful crowdsale.
  function finalizeCrowdsale() internal {
    // Calculate divisor of the total token count
    uint divisor;
    for (uint i = 0; i < investments.length; i++)
       divisor = safeAdd(divisor, investments[i].weiValue);

    var multiplier = 10 ** token.decimals();
    // Get unit price
    uint unitPrice = safeDiv(safeMul(TOTAL_ICO_TOKENS, multiplier), divisor);

    // Distribute tokens among investors
    for (i = 0; i < investments.length; i++) {
        var tokenAmount = safeMul(unitPrice, investments[i].weiValue);
        tokenAmountOf[investments[i].source] += tokenAmount;
        assignTokens(investments[i].source, tokenAmount);
    }
    assignTokens(owner, 2e7);
    token.releaseTokenTransfer();
  }

  /// @dev Allow load refunds back on the contract for the refunding.
  function loadRefund() public payable inState(State.Failure) {
    require(msg.value > 0);
    loadedRefund = safeAdd(loadedRefund, msg.value);
  }

  /// @dev Investors can claim refund.
  function refund() public inState(State.Refunding) {
    uint256 weiValue = investedAmountOf[msg.sender];
    if (weiValue == 0)
      return;
    investedAmountOf[msg.sender] = 0;
    weiRefunded = safeAdd(weiRefunded, weiValue);
    Refund(msg.sender, weiValue);
    msg.sender.transfer(weiValue);
  }

  /// @dev Minimum goal was reached
  /// @return true if the crowdsale has raised enough money to not initiate the refunding
  function isMinimumGoalReached() public constant returns (bool reached) {
    return weiRaised >= MIN_ICO_GOAL;
  }

  /// @dev Check if the ICO goal was reached.
  /// @return true if the crowdsale has raised enough money to be a success
  function isCrowdsaleFull() public constant returns (bool) {
    return weiRaised >= MAX_ICO_GOAL && now > maxGoalReachedAt + AFTER_MAX_GOAL_DURATION;
  }

  /// @dev Crowdfund state machine management.
  /// @return State current state
  function getState() public constant returns (State) {
    if (finalized)
      return State.Finalized;
    if (address(token) == 0)
      return State.Preparing;
    if (now >= startsAt && now < startsAt + ICO_DURATION && !isCrowdsaleFull())
      return State.Funding;
    if (isCrowdsaleFull())
      return State.Success;
    if (!isMinimumGoalReached() && weiRaised > 0 && loadedRefund >= weiRaised)
      return State.Refunding;
    return State.Failure;
  }

   /// @dev Dynamically create tokens and assign them to the investor.
   /// @param receiver investor address
   /// @param tokenAmount The amount of tokens we try to give to the investor in the current transaction
   function assignTokens(address receiver, uint tokenAmount) private {
     token.mint(receiver, tokenAmount);
   }
}
