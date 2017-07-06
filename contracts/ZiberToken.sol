pragma solidity ^0.4.7;

import "./CrowdsaleToken.sol";

contract ZiberToken is CrowdsaleToken {
  function ZiberToken(string _name, string _symbol, uint _initialSupply, uint _decimals)
   CrowdsaleToken(_name, _symbol, _initialSupply, _decimals) {
  }
}
