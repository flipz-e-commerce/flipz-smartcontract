	pragma solidity ^0.4.11;

	import './FlipzToken.sol';
	import '../token/Ownable.sol';

	contract FlipzTokenContract is Ownable {

		FlipzCoin public token  = new FlipzCoin();

		using SafeMath for uint256;

		// wallet address for funds 
		address public wallet;

		uint256 public maxSupply;

		// token cost per wei
		uint256 public rateCostF;

		uint256 public rateCostS;

		uint256 public minTransaction;

		// time limits of sale periods
		uint public firstStepStart;
		uint public firstStepEnd;
		uint public SecondStepStart;
		uint public SecondStepEnd;

		uint256 public EtherRaised = 0;
		uint256 public BitcoinRaised = 0;

		function FlipzTokenContract(address _wallet, uint _startF, uint _endF, uint _startS, uint _endS) {
			require(_wallet != 0x0);
			require(_startF < _endF);
			require(_startS < _endS);

			wallet = _wallet;

			// max supply of FLZ
			maxSupply = 100000000;

			rateCostF = 3000;

			rateCostS = 2500;

			// min  transaction
			minTransaction = 0.1 ether;

			firstStepStart = _startF;

			firstStepEnd = _endF;

			SecondStepStart = _startS;

			SecondStepEnd = _endS;

		}

		modifier inSalePeriod() {
			require((firstStepStart < now && now <= firstStepEnd) || (SecondStepStart < now && now <= SecondStepEnd));
			_;
		}

		modifier isUnderMaxMint() {
			require(token.totalSupply() < maxSupply);
			_;
		}

		function setFirstPeriod(uint _start, uint _end) onlyOwner {
			require(_start < _end);

			firstStepStart = _start;

			firstStepEnd = _end;

		}

		function setSecondPeriod(uint _start, uint _end) onlyOwner {
			require(_start < _end);

			SecondStepStart = _start;

			SecondStepEnd = _end;

		}

		function buyTokens() inSalePeriod isUnderMaxMint payable {
			require(msg.value >= minTransaction);

			uint256 tokenAmount = msg.value;

			EtherRaised = EtherRaised.add(tokenAmount);

			// calculate token amount to be created
			if(SecondStepStart < now && now <= SecondStepEnd) {
				uint256 tokens = tokenAmount.mul(rateCostS);
			} else {
				uint256 tokens = tokenAmount.mul(rateCostF);
			}

			tokens += countOfBonus(tokens);

			token.mint(msg.sender, tokens);

			wallet.transfer(msg.value);
		}

		// fallback function to buy tokens
		function () inSalePeriod payable {
				buyTokens();
		}

		function countOfBonus(uint256 _tokens) constant returns (uint256 bonus) {
			require(_tokens != 0);

			if (firstStepStart <= now && now < firstStepStart + 8 days) {
					return _tokens.div(10);
			} else if (firstStepStart + 8 days <= now && now < firstStepStart + 15 days ) {
					return _tokens.mul(7).div(100);
			} else if (firstStepStart + 15 days <= now && now < firstStepStart + 22 days ) {
					return _tokens.div(20);
			} else if (firstStepStart + 22 days <= now && now < firstStepStart + 29 days ) {
					return _tokens.div(50);
			}

			return 0;
		}

		function finishMinting() onlyOwner {
			token.finishMinting();
		}

		function totalSupply() returns(uint) {
			token.totalSupply();
		}

	}