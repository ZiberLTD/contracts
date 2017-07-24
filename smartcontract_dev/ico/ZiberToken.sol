pragma solidity ^0.4.13;

import '/src/common/ownership/Ownable.sol';
import '/src/common/token/ERC20.sol';
import '/src/common/SafeMath.sol';

/// @title ZiberToken contract - standard ERC20 token with Short Hand Attack and approve() race condition mitigation.
/// @author dev@smartcontracteam.com
contract ZiberToken is SafeMath, ERC20, Ownable {
 string public name = "Ziber Token";
 string public symbol = "ZBR";
 uint public decimals = 8;
 uint public constant FROZEN_TOKENS = 1e7;
 uint public constant FREEZE_PERIOD = 1 years;
 uint public crowdSaleOverTimestamp;

 /// contract that is allowed to create new tokens and allows unlift the transfer limits on this token
 address public crowdsaleAgent;
 /// A crowdsale contract can release us to the wild if ICO success. If false we are are in transfer lock up period.
 bool public released = false;
 /// approve() allowances
 mapping (address => mapping (address => uint)) allowed;
 /// holder balances
 mapping(address => uint) balances;

 /// @dev Limit token transfer until the crowdsale is over.
 modifier canTransfer() {
   if(!released) {
     require(msg.sender == crowdsaleAgent);
   }
   _;
 }

 modifier checkFrozenAmount(address source, uint amount) {
   if (source == owner && now < crowdSaleOverTimestamp + FREEZE_PERIOD) {
     var frozenTokens = 10 ** decimals * FROZEN_TOKENS;
     require(safeSub(balances[owner], amount) > frozenTokens);
   }
   _;
 }

 /// @dev The function can be called only before or after the tokens have been releasesd
 /// @param _released token transfer and mint state
 modifier inReleaseState(bool _released) {
   require(_released == released);
   _;
 }

 /// @dev The function can be called only by release agent.
 modifier onlyCrowdsaleAgent() {
   require(msg.sender == crowdsaleAgent);
   _;
 }

 /// @dev Fix for the ERC20 short address attack http://vessenes.com/the-erc20-short-address-attack-explained/
 /// @param size payload size
 modifier onlyPayloadSize(uint size) {
   require(msg.data.length >= size + 4);
    _;
 }

 /// @dev Make sure we are not done yet.
 modifier canMint() {
   require(!released);
    _;
  }

 /// @dev Constructor
 function ZiberToken() {
   owner = msg.sender;
 }

 /// Fallback method will buyout tokens
 function() payable {
   revert();
 }
 /// @dev Create new tokens and allocate them to an address. Only callably by a crowdsale contract
 /// @param receiver Address of receiver
 /// @param amount  Number of tokens to issue.
 function mint(address receiver, uint amount) onlyCrowdsaleAgent canMint public {
    totalSupply = safeAdd(totalSupply, amount);
    balances[receiver] = safeAdd(balances[receiver], amount);
    Transfer(0, receiver, amount);
 }

 /// @dev Set the contract that can call release and make the token transferable.
 /// @param _crowdsaleAgent crowdsale contract address
 function setCrowdsaleAgent(address _crowdsaleAgent) onlyOwner inReleaseState(false) public {
   crowdsaleAgent = _crowdsaleAgent;
 }
 /// @dev One way function to release the tokens to the wild. Can be called only from the release agent that is the final ICO contract. It is only called if the crowdsale has been success (first milestone reached).
 function releaseTokenTransfer() public onlyCrowdsaleAgent {
   crowdSaleOverTimestamp = now;
   released = true;
 }
 /// @dev Tranfer tokens to address
 /// @param _to dest address
 /// @param _value tokens amount
 /// @return transfer result
 function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) canTransfer checkFrozenAmount(msg.sender, _value) returns (bool success) {
   balances[msg.sender] = safeSub(balances[msg.sender], _value);
   balances[_to] = safeAdd(balances[_to], _value);

   Transfer(msg.sender, _to, _value);
   return true;
 }

 /// @dev Tranfer tokens from one address to other
 /// @param _from source address
 /// @param _to dest address
 /// @param _value tokens amount
 /// @return transfer result
 function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(2 * 32) canTransfer checkFrozenAmount(_from, _value) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
 }
 /// @dev Tokens balance
 /// @param _owner holder address
 /// @return balance amount
 function balanceOf(address _owner) constant returns (uint balance) {
   return balances[_owner];
 }

 /// @dev Approve transfer
 /// @param _spender holder address
 /// @param _value tokens amount
 /// @return result
 function approve(address _spender, uint _value) returns (bool success) {
   // To change the approve amount you first have to reduce the addresses`
   //  allowance to zero by calling `approve(_spender, 0)` if it is not
   //  already 0 to mitigate the race condition described here:
   //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729   
   require ((_value == 0) || (allowed[msg.sender][_spender] == 0));

   allowed[msg.sender][_spender] = _value;
   Approval(msg.sender, _spender, _value);
   return true;
 }

 /// @dev Token allowance
 /// @param _owner holder address
 /// @param _spender spender address
 /// @return remain amount
 function allowance(address _owner, address _spender) constant returns (uint remaining) {
   return allowed[_owner][_spender];
 }
}
