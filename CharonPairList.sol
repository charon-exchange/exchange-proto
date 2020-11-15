pragma solidity >=0.6.0;

interface ICharonPairListOwner {
  function addTokenOwner(address tokenAddress, bytes symbol, bytes name, bytes logoURI) external;
  function delTokenOwner(address tokenAddress) external;
  function addPairOwner(address pairAddress, address token1Address, address token2Address, address tokenLiqAddress) external;
  function delPairOwner(address pairAddress) external;
}

interface ICharonPairListGov {
  function addTokenGov(address tokenAddress, bytes symbol, bytes name, bytes logoURI) external;
  function delTokenGov(address tokenAddress) external;
  function addPairGov(address pairAddress, address token1Address, address token2Address, address tokenLiqAddress) external;
  function delPairGov(address pairAddress) external;
}

/*
interface ICharonPairGetters {
  function getTokenList() external view returns (address[] tokenAddress, bytes[] symbol, bytes[] name, bytes[] logoURI);
  function getPairList() external view returns (address[] pairAddress, address[] token1Address, address[] token2Address, address[] tokenLiqAddress);
  function getDescription() external view returns (bytes name, bytes description, bytes logoURI, bool ownerEnabled, address governanceAddress);
}
*/

contract CharonPairList is ICharonPairListOwner, ICharonPairListGov {

  /*
   * Exception codes:
   */
  uint32 constant ERROR_NOT_AUTHORIZED = 100;
  uint32 constant ERROR_INVALID_ARG = 101;

  bool _ownerEnabled;
  address GOVERNANCE_ADDRESS;

  bytes _name;
  bytes _description;
  bytes _logoURI;

  struct Token {
    address tokenAddress;
    bytes symbol;
    bytes name;
    bytes logoURI;
  }

  struct Pair {
    address pairAddress;
    address token1Address;
    address token2Address;
    address tokenLiqAddress;
  }

  mapping(address => Token) tokenList;
  mapping(address => Pair) pairList;

  constructor (bytes name, bytes description, bytes logoURI, bool ownerEnabled, address governanceAddress) public {
    require(tvm.pubkey() != 0, ERROR_NOT_AUTHORIZED);
    tvm.accept();

    _name = name;
    _description = description;
    _logoURI = logoURI;

    _ownerEnabled = ownerEnabled;
    GOVERNANCE_ADDRESS = governanceAddress;
  }

  function addTokenOwner(address tokenAddress, bytes symbol, bytes name, bytes logoURI) external override {
    require(_ownerEnabled && tvm.pubkey() == msg.pubkey(), ERROR_NOT_AUTHORIZED);
    tvm.accept();

    Token item;
    item.tokenAddress = tokenAddress;
    item.symbol = symbol;
    item.name = name;
    item.logoURI = logoURI;

    if (tokenList.exists(tokenAddress)) {
      tokenList.replace(tokenAddress, item);
    } else {
      tokenList.add(tokenAddress, item);
    }
  }

  function delTokenOwner(address tokenAddress) external override {
    require(_ownerEnabled && tvm.pubkey() == msg.pubkey(), ERROR_NOT_AUTHORIZED);
    require(tokenList.exists(tokenAddress));
    tvm.accept();

    delete tokenList[tokenAddress];
  }

  function addPairOwner(address pairAddress, address token1Address, address token2Address, address tokenLiqAddress) external override {
    require(_ownerEnabled && tvm.pubkey() == msg.pubkey(), ERROR_NOT_AUTHORIZED);
    require(tokenList.exists(token1Address) && tokenList.exists(token2Address), ERROR_INVALID_ARG);
    tvm.accept();

    Pair item;
    item.pairAddress = pairAddress;
    item.token1Address = token1Address;
    item.token2Address = token2Address;
    item.tokenLiqAddress = tokenLiqAddress;

    if (pairList.exists(pairAddress)) {
      pairList.replace(pairAddress, item);
    } else {
      pairList.add(pairAddress, item);
    }
  }

  function delPairOwner(address pairAddress) external override {
    require(_ownerEnabled && tvm.pubkey() == msg.pubkey(), ERROR_NOT_AUTHORIZED);
    require(pairList.exists(pairAddress));
    tvm.accept();

    delete pairList[pairAddress];
  }

  function addTokenGov(address tokenAddress, bytes symbol, bytes name, bytes logoURI) external override {
    require(msg.sender == GOVERNANCE_ADDRESS, ERROR_NOT_AUTHORIZED);

    Token item;
    item.tokenAddress = tokenAddress;
    item.symbol = symbol;
    item.name = name;
    item.logoURI = logoURI;

    if (tokenList.exists(tokenAddress)) {
      tokenList.replace(tokenAddress, item);
    } else {
      tokenList.add(tokenAddress, item);
    }
  }

  function delTokenGov(address tokenAddress) external override {
    require(msg.sender == GOVERNANCE_ADDRESS, ERROR_NOT_AUTHORIZED);
    require(tokenList.exists(tokenAddress));

    delete tokenList[tokenAddress];
  }

  function addPairGov(address pairAddress, address token1Address, address token2Address, address tokenLiqAddress) external override {
    require(msg.sender == GOVERNANCE_ADDRESS, ERROR_NOT_AUTHORIZED);
    require(tokenList.exists(token1Address) && tokenList.exists(token2Address), ERROR_INVALID_ARG);

    Pair item;
    item.pairAddress = pairAddress;
    item.token1Address = token1Address;
    item.token2Address = token2Address;
    item.tokenLiqAddress = tokenLiqAddress;

    if (pairList.exists(pairAddress)) {
      pairList.replace(pairAddress, item);
    } else {
      pairList.add(pairAddress, item);
    }
  }

  function delPairGov(address pairAddress) external override {
    require(msg.sender == GOVERNANCE_ADDRESS, ERROR_NOT_AUTHORIZED);
    require(pairList.exists(pairAddress));

    delete pairList[pairAddress];
  }

  function getTokenList() public view returns (address[] tokenAddress, bytes[] symbol, bytes[] name, bytes[] logoURI) {
    optional(address, Token) minToken = tokenList.min();
    if (minToken.hasValue()) {
      (address key, Token value) = minToken.get();
      tokenAddress.push(key);
      symbol.push(value.symbol);
      name.push(value.name);
      logoURI.push(value.logoURI);
      while(true) {
        optional(address, Token) nextToken = tokenList.next(key);
        if (nextToken.hasValue()) {
          (address nextKey, Token nextValue) = nextToken.get();
          tokenAddress.push(nextKey);
          symbol.push(nextValue.symbol);
          name.push(nextValue.name);
          logoURI.push(nextValue.logoURI);
          key = nextKey;
        } else {
          break;
        }
      }
    }
  }

  function getPairList() public view returns (address[] pairAddress, address[] token1Address, address[] token2Address, address[] tokenLiqAddress) {
    optional(address, Pair) minPair = pairList.min();
    if (minPair.hasValue()) {
      (address key, Pair value) = minPair.get();
      pairAddress.push(key);
      token1Address.push(value.token1Address);
      token2Address.push(value.token2Address);
      tokenLiqAddress.push(value.tokenLiqAddress);

      while(true) {
        optional(address, Pair) nextPair = pairList.next(key);
        if (nextPair.hasValue()) {
          (address nextKey, Pair nextValue) = nextPair.get();
          pairAddress.push(nextKey);
          token1Address.push(nextValue.token1Address);
          token2Address.push(nextValue.token2Address);
          tokenLiqAddress.push(nextValue.tokenLiqAddress);
          key = nextKey;
        } else {
          break;
        }
      }
    }
  }

  function getDescription() public view returns (bytes name, bytes description, bytes logoURI, bool ownerEnabled, address governanceAddress) {
    name = _name;
    description = _description;
    logoURI = _logoURI;
    ownerEnabled = _ownerEnabled;
    governanceAddress = GOVERNANCE_ADDRESS;
  }
  
}
