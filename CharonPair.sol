pragma solidity >=0.6.0;

// Remote contract interfaces
interface ITONTokenWallet {
  function transferFromInternal(uint128 tokens, uint256 pubkey, int8 workchain_id) external functionID(32);
  function setNotifyAddress(address addr) external functionID(33);
}

interface ITONTokenRoot {
  function mintGrant(uint128 tokens, uint256 pubkey, int8 workchain_id) external functionID(30);
  function setNotifyAddress(address addr) external functionID(32);
}

interface ITONTokenNotify {
  function transferNotifyWithData(uint128 tokens, uint256 pubkey, int8 workchain_id, bytes data) external functionID(100);
  function burnNotifyWithData(uint128 tokens, uint256 pubkey, int8 workchain_id, bytes data) external functionID(101);
}

interface ICharonPair {

}

contract CharonPair is ICharonPair, ITONTokenNotify {

  /*
   * Exception codes:
   */
  uint32 constant ERROR_NOT_AUTHORIZED = 100;
  uint32 constant ERROR_INVALID_ARG = 101;
  uint32 constant ERROR_INSUFFICIENT_BALANCE = 102;
  uint32 constant ERROR_INSUFFICIENT_MSG_VALUE = 103;
  uint32 constant ERROR_INSUFFICIENT_RESERVES = 104;

  address _token1;
  address _token2;
  address _tokenLiqRoot;

  uint128 _token1Reserve;
  uint128 _token2Reserve;
  uint128 _tokenLiqTotal;

  uint128 _developerFeeToken1;
  uint128 _developerFeeToken2;

  mapping(uint256 => uint128) _balancesToken1;
  mapping(uint256 => uint128) _balancesToken2;
  mapping(uint256 => uint128) _balancesTokenLiq;

  // CONTROL
  address DEVELOPER_ADDRESS;
  address GOVERNANCE_ADDRESS;

  // FEES
  uint128 FEE_DEVELOPER; // 5 / 1000 = 0.005
  uint128 FEE_EXCHANGE; // 50 / 1000 = 0.050

  // COMMANDS
  uint8 constant CMD_EXCHANGE = 0x01;
  uint8 constant CMD_EXCHANGE_DIR_MASK = 0x30;
  uint8 constant CMD_EXCHANGE_DIR_1_TO_2 = 0x00;
  uint8 constant CMD_EXCHANGE_DIR_2_TO_1 = 0x10;
  uint8 constant CMD_EXCHANGE_VALUE_SPECIFIED = 0x40;

  uint8 constant CMD_LIQUIDITY_MINT = 0x02;
  uint8 constant CMD_LIQUIDITY_MINT_VALUE_SPECIFIED = 0x10;

  uint8 constant CMD_LIQUIDITY_BURN = 0x03;
  uint8 constant CMD_LIQUIDITY_BURN_VALUE_SPECIFIED = 0x10;

  uint8 constant CMD_SEND_TOKENS = 0x04;
  uint8 constant CMD_SEND_TOKENS_MASK = 0x30;
  uint8 constant CMD_SEND_TOKENS_VALUE_SPECIFIED = 0x40;
  uint8 constant CMD_SEND_TOKENS_PUBKEY_SPECIFIED = 0x80;
  uint8 constant CMD_SEND_TOKENS_TOKEN1 = 0x00;
  uint8 constant CMD_SEND_TOKENS_TOKEN2 = 0x10;
  uint8 constant CMD_SEND_TOKENS_TOKENLIQ = 0x20;

  uint128 constant MINIMUM_LIQUIDITY = 10**3;

  uint128 SWAP_MIN_FEES = 0.1 ton;

  constructor (address token1, address token2, address tokenLiqRoot, address developerAddress, address governanceAddress) public {
    require(tvm.pubkey() != 0, ERROR_NOT_AUTHORIZED);
    tvm.accept();

    _token1 = token1;
    _token2 = token2;
    _tokenLiqRoot = tokenLiqRoot;
    _token1Reserve = 0;
    _token2Reserve = 0;
    _tokenLiqTotal = 0;

    _developerFeeToken1 = 0;
    _developerFeeToken2 = 0;

    FEE_EXCHANGE = 2;
    FEE_DEVELOPER = 1;

    DEVELOPER_ADDRESS = developerAddress;
    GOVERNANCE_ADDRESS = governanceAddress;

    ITONTokenWallet(token1).setNotifyAddress{value: 0.1 ton}(address(this));
    ITONTokenWallet(token2).setNotifyAddress{value: 0.1 ton}(address(this));
    ITONTokenRoot(tokenLiqRoot).setNotifyAddress{value: 0.1 ton}(address(this));
  }

  modifier developerOnly {
    require(msg.sender == DEVELOPER_ADDRESS, ERROR_NOT_AUTHORIZED);
    _;
  }
  modifier governanceOnly {
    require(msg.sender == GOVERNANCE_ADDRESS, ERROR_NOT_AUTHORIZED);
    _;
  }

  function bytesToUint128(bytes b, uint pos) inline private pure returns (uint128) {
    uint128 number = 0;
    for(uint i=0; i<16; i++) {
      number = number + uint128(uint8(b[pos+i]))*uint128(2**(8*(15-(i))));
    }
    return number;
  }
  function bytesToUint256(bytes b, uint pos) inline private pure returns (uint256) {
    uint256 number = 0;
    for(uint i=0; i<32; i++) {
      number = number + uint256(uint8(b[pos+i]))*uint256(2**(8*(31-(i))));
    }
    return number;
  }
  function bytesToInt8(bytes b, uint pos) inline private pure returns (int8) {
    return int8(b[pos]);
  }

  function increaseBalanceToken1(uint256 pubkey, uint128 value) private {
    if (value == 0) {
      return;
    }
    if (_balancesToken1.exists(pubkey)) {
      uint128 balance = _balancesToken1[pubkey];
      balance += value;
      _balancesToken1.replace(pubkey, balance);
    } else {
      _balancesToken1.add(pubkey, value);
    }
  }

  function increaseBalanceToken2(uint256 pubkey, uint128 value) private {
    if (value == 0) {
      return;
    }
    if (_balancesToken2.exists(pubkey)) {
      uint128 balance = _balancesToken2[pubkey];
      balance += value;
      _balancesToken2.replace(pubkey, balance);
    } else {
      _balancesToken2.add(pubkey, value);
    }
  }

  function increaseBalanceTokenLiq(uint256 pubkey, uint128 value) private {
    if (value == 0) {
      return;
    }
    if (_balancesTokenLiq.exists(pubkey)) {
      uint128 balance = _balancesTokenLiq[pubkey];
      balance += value;
      _balancesTokenLiq.replace(pubkey, balance);
    } else {
      _balancesTokenLiq.add(pubkey, value);
    }
  }

  function decreaseBalanceToken1(uint256 pubkey, uint128 value) private {
    if (value == 0) {
      return;
    }
    require(_balancesToken1.exists(pubkey), ERROR_INSUFFICIENT_BALANCE);
    uint128 balance = _balancesToken1[pubkey];
    require(balance >= value, ERROR_INSUFFICIENT_BALANCE);
    balance -= value;
    if (balance == 0) {
      delete _balancesToken1[pubkey];
    } else {
      _balancesToken1.replace(pubkey, balance);
    }
  }

  function decreaseBalanceToken2(uint256 pubkey, uint128 value) private {
    if (value == 0) {
      return;
    }
    require(_balancesToken2.exists(pubkey), ERROR_INSUFFICIENT_BALANCE);
    uint128 balance = _balancesToken2[pubkey];
    require(balance >= value, ERROR_INSUFFICIENT_BALANCE);
    balance -= value;
    if (balance == 0) {
      delete _balancesToken2[pubkey];
    } else {
      _balancesToken2.replace(pubkey, balance);
    }
  }

  function decreaseBalanceTokenLiq(uint256 pubkey, uint128 value) private {
    if (value == 0) {
      return;
    }
    require(_balancesTokenLiq.exists(pubkey), ERROR_INSUFFICIENT_BALANCE);
    uint128 balance = _balancesTokenLiq[pubkey];
    require(balance >= value, ERROR_INSUFFICIENT_BALANCE);
    balance -= value;
    if (balance == 0) {
      delete _balancesTokenLiq[pubkey];
    } else {
      _balancesTokenLiq.replace(pubkey, balance);
    }
  }

  function processCommands(uint256 pubkey, int8 workchain_id, bytes data) private {

    require(msg.value >= SWAP_MIN_FEES, ERROR_INSUFFICIENT_MSG_VALUE);

    uint8 cmdPos = 0;
    bool msgSended = false;

    while (data.length >= cmdPos + 1) {
      uint8 cmdOpts = uint8(data[cmdPos]);
      uint8 cmd = cmdOpts & 0x0F;
      cmdPos += 1;

      if (cmd == CMD_EXCHANGE) {
        uint128 valueToSwap;
        uint8 direction = cmdOpts & CMD_EXCHANGE_DIR_MASK;
        uint128 srcBalance = 0;

        if (direction == CMD_EXCHANGE_DIR_1_TO_2) {
          require(_balancesToken1.exists(pubkey), ERROR_INSUFFICIENT_BALANCE);
          srcBalance = _balancesToken1[pubkey];
        } else if (direction == CMD_EXCHANGE_DIR_2_TO_1) {
          require(_balancesToken2.exists(pubkey), ERROR_INSUFFICIENT_BALANCE);
          srcBalance = _balancesToken2[pubkey];
        } else {
          revert(ERROR_INVALID_ARG);
        }

        require(data.length >= cmdPos + 16, ERROR_INVALID_ARG);
        uint128 minValue = bytesToUint128(data, cmdPos);
        cmdPos += 16;

        if (cmdOpts & CMD_EXCHANGE_VALUE_SPECIFIED != 0) {
          require(data.length >= cmdPos + 16, ERROR_INVALID_ARG);

          valueToSwap = bytesToUint128(data, cmdPos);
          require(srcBalance >= valueToSwap, ERROR_INSUFFICIENT_BALANCE);
          cmdPos += 16;
        } else {
          valueToSwap = srcBalance;
        }

        require(valueToSwap > 0, ERROR_INSUFFICIENT_BALANCE);

        uint256 K = uint256(_token1Reserve) * uint256(_token2Reserve);
        require(K > 0, ERROR_INSUFFICIENT_RESERVES);

        (uint128 serviceFee, uint128 divRest1) = math.muldivmod(valueToSwap, FEE_EXCHANGE, 1000);
        uint128 developerFee = 0;
        if (FEE_DEVELOPER > 0) {
          uint128 divRest2;
          (developerFee, divRest2) = math.muldivmod(valueToSwap, FEE_DEVELOPER, 1000);
        }
        require(valueToSwap > serviceFee + developerFee, ERROR_INSUFFICIENT_BALANCE);
        uint128 valueToSwapExceptFee = valueToSwap - developerFee - serviceFee;

        if (direction == CMD_EXCHANGE_DIR_1_TO_2) {

          uint128 dstToken2Reserve = uint128(math.divr(K, uint256(_token1Reserve + valueToSwapExceptFee)));
          uint128 dstValue = _token2Reserve - dstToken2Reserve;

          if (dstValue < _token2Reserve && dstValue >= minValue) {
            // swap was successfull
            _developerFeeToken1 += developerFee;
            _token1Reserve += valueToSwap - developerFee;
            _token2Reserve -= dstValue;
            decreaseBalanceToken1(pubkey, valueToSwap);
            increaseBalanceToken2(pubkey, dstValue);
          }
        } else if (direction == CMD_EXCHANGE_DIR_2_TO_1) {

          uint128 dstToken1Reserve = uint128(math.divr(K, uint256(_token2Reserve + valueToSwapExceptFee)));
          uint128 dstValue = _token1Reserve - dstToken1Reserve;

          if (dstValue < _token1Reserve && dstValue >= minValue) {
            // swap was successfull
            _developerFeeToken2 += developerFee;
            _token2Reserve += valueToSwap - developerFee;
            _token1Reserve -= dstValue;
            decreaseBalanceToken2(pubkey, valueToSwap);
            increaseBalanceToken1(pubkey, dstValue);
          }
        }
      }

      else if (cmd == CMD_LIQUIDITY_MINT) {

        require(_balancesToken1.exists(pubkey), ERROR_INSUFFICIENT_BALANCE);
        require(_balancesToken2.exists(pubkey), ERROR_INSUFFICIENT_BALANCE);

        uint128 valueBalance1 = _balancesToken1[pubkey];
        uint128 valueBalance2 = _balancesToken2[pubkey];
        uint128 token1Value = 0;
        uint128 token2Value = 0;
        uint128 liquidity = 0;
        uint128 expectedLiq = 0;

        if (_tokenLiqTotal == 0) {
          liquidity = sqrt(valueBalance1 * valueBalance2);
          _tokenLiqTotal += liquidity;

          // expectedLiq ignored
          if (cmdOpts & CMD_LIQUIDITY_MINT_VALUE_SPECIFIED != 0) {
            require(data.length >= cmdPos + 16, ERROR_INVALID_ARG);
            cmdPos += 16;
          }

          liquidity -= MINIMUM_LIQUIDITY;
          
          require(liquidity > 0, ERROR_INSUFFICIENT_BALANCE);

          token1Value = valueBalance1;
          token2Value = valueBalance2;
        } else {
          (uint128 token1Liq, uint128 _1) = math.muldivmod(valueBalance1, _tokenLiqTotal, _token1Reserve);
          (uint128 token2Liq, uint128 _2) = math.muldivmod(valueBalance2, _tokenLiqTotal, _token2Reserve);
          liquidity = math.min(token1Liq, token2Liq);

          if (cmdOpts & CMD_LIQUIDITY_MINT_VALUE_SPECIFIED != 0) {
            require(data.length >= cmdPos + 16, ERROR_INVALID_ARG);

            expectedLiq = bytesToUint128(data, cmdPos);
            liquidity = math.min(liquidity, expectedLiq);
            cmdPos += 16;
          }

          require(liquidity > 0, ERROR_INSUFFICIENT_BALANCE);

          uint128 _3;
          uint128 _4;
          (token1Value, _3) = math.muldivmod(liquidity, _token1Reserve, _tokenLiqTotal);
          (token2Value, _4) = math.muldivmod(liquidity, _token2Reserve, _tokenLiqTotal);
          if (token1Value > valueBalance1) {
            token1Value = valueBalance1;
          }
          if (token2Value > valueBalance2) {
            token2Value = valueBalance2;
          }

          _tokenLiqTotal += liquidity;
        }

        increaseBalanceTokenLiq(pubkey, liquidity);
        decreaseBalanceToken1(pubkey, token1Value);
        decreaseBalanceToken2(pubkey, token2Value);
        _token1Reserve += token1Value;
        _token2Reserve += token2Value;
      }

      else if (cmd == CMD_LIQUIDITY_BURN) {

        require(_balancesTokenLiq.exists(pubkey), ERROR_INSUFFICIENT_BALANCE);

        uint128 liquidity = _balancesTokenLiq[pubkey];

        if (cmdOpts & CMD_LIQUIDITY_BURN_VALUE_SPECIFIED != 0) {
          require(data.length >= cmdPos + 16, ERROR_INVALID_ARG);

          uint128 expectedLiq = bytesToUint128(data, cmdPos);
          liquidity = math.min(liquidity, expectedLiq);
          cmdPos += 16;
        }

        require(liquidity > 0, ERROR_INSUFFICIENT_BALANCE);

        (uint128 token1, uint128 _1) = math.muldivmod(liquidity, _token1Reserve, _tokenLiqTotal);
        (uint128 token2, uint128 _2) = math.muldivmod(liquidity, _token2Reserve, _tokenLiqTotal);
        require(token1 > 0 && token2 > 0, ERROR_INSUFFICIENT_BALANCE);

        decreaseBalanceTokenLiq(pubkey, liquidity);
        increaseBalanceToken1(pubkey, token1);
        increaseBalanceToken2(pubkey, token2);
        _tokenLiqTotal -= liquidity;
        _token1Reserve -= token1;
        _token2Reserve -= token2;
      }

      else if (cmd == CMD_SEND_TOKENS) {
        uint8 tokenToSend = cmdOpts & CMD_SEND_TOKENS_MASK;
        uint128 valueToWithdraw = 0;
        uint256 pubkeyToWithdraw = 0;
        int8 workchainToWithdraw = 0;

        if (cmdOpts & CMD_SEND_TOKENS_VALUE_SPECIFIED != 0) {
          require(data.length >= cmdPos + 16, ERROR_INVALID_ARG);

          valueToWithdraw = bytesToUint128(data, cmdPos);
          cmdPos += 16;
        }

        if (cmdOpts & CMD_SEND_TOKENS_PUBKEY_SPECIFIED != 0) {
          require(data.length >= cmdPos + 33, ERROR_INVALID_ARG);

          pubkeyToWithdraw = bytesToUint256(data, cmdPos);
          cmdPos += 32;
          workchainToWithdraw = bytesToInt8(data, cmdPos);
          cmdPos += 1;
        } else {
          pubkeyToWithdraw = pubkey;
          workchainToWithdraw = workchain_id;
        }

        if (msgSended) {
          continue;
        }

        if (tokenToSend == CMD_SEND_TOKENS_TOKEN1) {
          require(_balancesToken1.exists(pubkey), ERROR_INSUFFICIENT_BALANCE);
          uint128 valueBalance = _balancesToken1[pubkey];

          valueToWithdraw = valueToWithdraw > 0 ? valueToWithdraw : valueBalance;
          require(valueBalance >= valueToWithdraw, ERROR_INSUFFICIENT_BALANCE);
          
          transferToUser(_token1, pubkeyToWithdraw, workchainToWithdraw, valueToWithdraw);
          decreaseBalanceToken1(pubkey, valueToWithdraw);
          msgSended = true;
        }
        else if (tokenToSend == CMD_SEND_TOKENS_TOKEN2) {
          require(_balancesToken2.exists(pubkey), ERROR_INSUFFICIENT_BALANCE);
          uint128 valueBalance = _balancesToken2[pubkey];
          
          valueToWithdraw = valueToWithdraw > 0 ? valueToWithdraw : valueBalance;
          require(valueBalance >= valueToWithdraw, ERROR_INSUFFICIENT_BALANCE);
          
          transferToUser(_token2, pubkeyToWithdraw, workchainToWithdraw, valueToWithdraw);
          decreaseBalanceToken2(pubkey, valueToWithdraw);
          msgSended = true;
        }
        else if (tokenToSend == CMD_SEND_TOKENS_TOKENLIQ) {
          require(_balancesTokenLiq.exists(pubkey), ERROR_INSUFFICIENT_BALANCE);
          uint128 valueBalance = _balancesTokenLiq[pubkey];
          
          valueToWithdraw = valueToWithdraw > 0 ? valueToWithdraw : valueBalance;
          require(valueBalance >= valueToWithdraw, ERROR_INSUFFICIENT_BALANCE);

          mintToUser(pubkeyToWithdraw, workchainToWithdraw, valueToWithdraw);
          decreaseBalanceTokenLiq(pubkey, valueToWithdraw);
          msgSended = true;
        }
      }
    }
  }

  function transferNotifyWithData(uint128 tokens, uint256 pubkey, int8 workchain_id, bytes data) external override functionID(100) {
    require(msg.sender == _token1 || msg.sender == _token2, ERROR_NOT_AUTHORIZED);
    require(pubkey != 0, ERROR_INVALID_ARG);

    if (tokens > 0) {
      if (msg.sender == _token1) {
        increaseBalanceToken1(pubkey, tokens);
        tvm.commit();
      }
      else if (msg.sender == _token2) {
        increaseBalanceToken2(pubkey, tokens);
        tvm.commit();
      }
    }

    if (data.length < 1) {
      // nothing to be done
      return;
    }

    processCommands(pubkey, workchain_id, data);
  }

  function burnNotifyWithData(uint128 tokens, uint256 pubkey, int8 workchain_id, bytes data) external override functionID(101) {
    require(msg.sender == _tokenLiqRoot, ERROR_NOT_AUTHORIZED);

    if (tokens > 0) {
      increaseBalanceTokenLiq(pubkey, tokens);
      tvm.commit();
    }

    if (data.length < 1 || data.length > 255) {
      // nothing to be done
      return;
    }

    processCommands(pubkey, workchain_id, data);
  }

  function transferToUser(address token, uint256 pubkey, int8 workchain_id, uint128 tokens) private {
    ITONTokenWallet(token).transferFromInternal{value: 0 ton, bounce: true, flag: 64}(tokens, pubkey, workchain_id);
  }

  function mintToUser(uint256 pubkey, int8 workchain_id, uint128 tokens) private {
    ITONTokenRoot(_tokenLiqRoot).mintGrant{value: 0 ton, bounce: true, flag: 64}(tokens, pubkey, workchain_id);
  }

  /*
   * Developer part
   */
  function setDeveloperFee(uint128 value) external developerOnly {
    // 0.0% and 0.1% are valid
    require(value == 1 || value == 0, ERROR_INVALID_ARG);

    FEE_DEVELOPER = value;
  }
  function withdrawDeveloperFeeToken1(uint256 pubkey, int8 workchain_id, uint128 tokens) external developerOnly {
    require(tokens <= _developerFeeToken1, ERROR_INSUFFICIENT_BALANCE);
    _developerFeeToken1 -= tokens;
    transferToUser(_token1, pubkey, workchain_id, tokens);
  }
  function withdrawDeveloperFeeToken2(uint256 pubkey, int8 workchain_id, uint128 tokens) external developerOnly {
    require(tokens <= _developerFeeToken2, ERROR_INSUFFICIENT_BALANCE);
    _developerFeeToken2 -= tokens;
    transferToUser(_token2, pubkey, workchain_id, tokens);
  }
  function getDeveloperBalance() public view returns (uint128 token1, uint128 token2) {
    token1 = _developerFeeToken1;
    token2 = _developerFeeToken2;
  }


  /*
   * Governance part
   */
  function setExchangeFee(uint128 value) external governanceOnly {
    // 0.1 - 2.0%
    require(value >= 1 && value <= 20, ERROR_INVALID_ARG);

    FEE_EXCHANGE = value;
  }

  /*
   * Public Getters
   */
  function getTokensAddress() public view returns (address token1Address, address token2Address, address tokenLiqRoot) {
    token1Address = _token1;
    token2Address = _token2;
    tokenLiqRoot = _tokenLiqRoot;
  }
  function getReserves() public view returns (uint128 token1Reserve, uint128 token2Reserve, uint128 tokenLiqTotal) {
    token1Reserve = _token1Reserve;
    token2Reserve = _token2Reserve;
    tokenLiqTotal = _tokenLiqTotal;
  }
  function getFees() public view returns (uint128 exchangeFee, uint128 developerFee) {
    exchangeFee = FEE_EXCHANGE;
    developerFee = FEE_DEVELOPER;
  }
  function getExchangeRate(uint128 valueToSwap, uint8 direction) public view returns (uint128 dstValue, uint128 serviceFee, uint128 developerFee, uint128 token1Reserve, uint128 token2Reserve) {
    require(valueToSwap > 0, ERROR_INSUFFICIENT_BALANCE);

    token1Reserve = _token1Reserve;
    token2Reserve = _token2Reserve;
    
    uint256 K = uint256(_token1Reserve) * uint256(_token2Reserve);
    require(K > 0, ERROR_INSUFFICIENT_RESERVES);

    uint128 divRest1;
    (serviceFee, divRest1) = math.muldivmod(valueToSwap, FEE_EXCHANGE, 1000);
    developerFee = 0;
    if (FEE_DEVELOPER > 0) {
      uint128 divRest2;
      (developerFee, divRest2) = math.muldivmod(valueToSwap, FEE_DEVELOPER, 1000);
    }
    require(valueToSwap > serviceFee + developerFee, ERROR_INSUFFICIENT_BALANCE);
    uint128 valueToSwapExceptFee = valueToSwap - developerFee - serviceFee;

    if (direction == CMD_EXCHANGE_DIR_1_TO_2) {

      uint128 dstToken2Reserve = uint128(math.divr(K, uint256(_token1Reserve + valueToSwapExceptFee)));
      dstValue = _token2Reserve - dstToken2Reserve;
      require(dstValue < _token2Reserve, ERROR_INSUFFICIENT_RESERVES);

    } else if (direction == CMD_EXCHANGE_DIR_2_TO_1) {

      uint128 dstToken1Reserve = uint128(math.divr(K, uint256(_token2Reserve + valueToSwapExceptFee)));
      dstValue = _token1Reserve - dstToken1Reserve;
      require(dstValue < _token2Reserve, ERROR_INSUFFICIENT_RESERVES);

    }
  }

  function getBalance(uint256 pubkey) public view returns (uint128 token1Balance, uint128 token2Balance, uint128 tokenLiqBalance) {
    token1Balance = _balancesToken1.exists(pubkey) ? _balancesToken1[pubkey] : 0;
    token2Balance = _balancesToken2.exists(pubkey) ? _balancesToken2[pubkey] : 0;
    tokenLiqBalance = _balancesTokenLiq.exists(pubkey) ? _balancesTokenLiq[pubkey] : 0;
  }

  // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
  function sqrt(uint128 y) internal pure returns (uint128 z) {
    if (y > 3) {
      z = y;
      uint128 x = y / 2 + 1;
      while (x < z) {
        z = x;
        x = (y / x + x) / 2;
      }
    } else if (y != 0) {
      z = 1;
    }
  }
}