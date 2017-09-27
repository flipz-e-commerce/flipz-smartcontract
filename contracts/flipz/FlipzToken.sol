pragma solidity ^0.4.11;

import '../token/MintableToken.sol';

contract FlipzCoin is MintableToken {
	string public constant name = "Flipz";
	string public constant symbol = "FLZ";
	uint public constant decimals = 6;
}
