[{"SourceCode":"pragma solidity ^0.5.11;\r\n\r\n/*\r\n * Creator: Democratic Republic of Congo Gold Token\r\n\r\n/*\r\n * Abstract Token Smart Contract\r\n *\r\n */\r\n\r\n \r\n /*\r\n * Safe Math Smart Contract. \r\n * https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol\r\n */\r\n\r\ncontract SafeMath {\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n    uint256 c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return c;\r\n  }\r\n\r\n  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n}\r\n\r\n\r\n\r\n\r\n/**\r\n * ERC-20 standard token interface, as defined\r\n * \u003Ca href=\u0022http://github.com/ethereum/EIPs/issues/20\u0022\u003Ehere\u003C/a\u003E.\r\n */\r\ncontract Token {\r\n  \r\n  function totalSupply() public view returns (uint256 supply);\r\n  function balanceOf(address _owner) public view returns (uint256 balance);\r\n  function transfer(address _to, uint256 _value) public returns (bool success);\r\n  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);\r\n  function approve(address _spender, uint256 _value) public returns (bool success);\r\n  function allowance(address _owner, address _spender) public view returns (uint256 remaining);\r\n  event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n  event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n}\r\n\r\n\r\n\r\n/**\r\n * Abstract Token Smart Contract that could be used as a base contract for\r\n * ERC-20 token contracts.\r\n */\r\ncontract AbstractToken is Token, SafeMath {\r\n  /**\r\n   * Create new Abstract Token contract.\r\n   */\r\n  constructor () public {\r\n    // Do nothing\r\n  }\r\n  \r\n  /**\r\n   * Get number of tokens currently belonging to given owner.\r\n   *\r\n   * @param _owner address to get number of tokens currently belonging to the\r\n   *        owner of\r\n   * @return number of tokens currently belonging to the owner of given address\r\n   */\r\n  function balanceOf(address _owner) public view returns (uint256 balance) {\r\n    return accounts [_owner];\r\n  }\r\n\r\n  /**\r\n   * Transfer given number of tokens from message sender to given recipient.\r\n   *\r\n   * @param _to address to transfer tokens to the owner of\r\n   * @param _value number of tokens to transfer to the owner of given address\r\n   * @return true if tokens were transferred successfully, false otherwise\r\n   * accounts [_to] \u002B _value \u003E accounts [_to] for overflow check\r\n   * which is already in safeMath\r\n   */\r\n  function transfer(address _to, uint256 _value) public returns (bool success) {\r\n    require(_to != address(0));\r\n    if (accounts [msg.sender] \u003C _value) return false;\r\n    if (_value \u003E 0 \u0026\u0026 msg.sender != _to) {\r\n      accounts [msg.sender] = safeSub (accounts [msg.sender], _value);\r\n      accounts [_to] = safeAdd (accounts [_to], _value);\r\n    }\r\n    emit Transfer (msg.sender, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * Transfer given number of tokens from given owner to given recipient.\r\n   *\r\n   * @param _from address to transfer tokens from the owner of\r\n   * @param _to address to transfer tokens to the owner of\r\n   * @param _value number of tokens to transfer from given owner to given\r\n   *        recipient\r\n   * @return true if tokens were transferred successfully, false otherwise\r\n   * accounts [_to] \u002B _value \u003E accounts [_to] for overflow check\r\n   * which is already in safeMath\r\n   */\r\n  function transferFrom(address _from, address _to, uint256 _value) public\r\n  returns (bool success) {\r\n    require(_to != address(0));\r\n    if (allowances [_from][msg.sender] \u003C _value) return false;\r\n    if (accounts [_from] \u003C _value) return false; \r\n\r\n    if (_value \u003E 0 \u0026\u0026 _from != _to) {\r\n\t  allowances [_from][msg.sender] = safeSub (allowances [_from][msg.sender], _value);\r\n      accounts [_from] = safeSub (accounts [_from], _value);\r\n      accounts [_to] = safeAdd (accounts [_to], _value);\r\n    }\r\n    emit Transfer(_from, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * Allow given spender to transfer given number of tokens from message sender.\r\n   * @param _spender address to allow the owner of to transfer tokens from message sender\r\n   * @param _value number of tokens to allow to transfer\r\n   * @return true if token transfer was successfully approved, false otherwise\r\n   */\r\n   function approve (address _spender, uint256 _value) public returns (bool success) {\r\n    allowances [msg.sender][_spender] = _value;\r\n    emit Approval (msg.sender, _spender, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * Tell how many tokens given spender is currently allowed to transfer from\r\n   * given owner.\r\n   *\r\n   * @param _owner address to get number of tokens allowed to be transferred\r\n   *        from the owner of\r\n   * @param _spender address to get number of tokens allowed to be transferred\r\n   *        by the owner of\r\n   * @return number of tokens given spender is currently allowed to transfer\r\n   *         from given owner\r\n   */\r\n  function allowance(address _owner, address _spender) public view\r\n  returns (uint256 remaining) {\r\n    return allowances [_owner][_spender];\r\n  }\r\n\r\n  /**\r\n   * Mapping from addresses of token holders to the numbers of tokens belonging\r\n   * to these token holders.\r\n   */\r\n  mapping (address =\u003E uint256) accounts;\r\n\r\n  /**\r\n   * Mapping from addresses of token holders to the mapping of addresses of\r\n   * spenders to the allowances set by these token holders to these spenders.\r\n   */\r\n  mapping (address =\u003E mapping (address =\u003E uint256)) private allowances;\r\n  \r\n}\r\n\r\n\r\n/**\r\n * DRCG smart contract.\r\n */\r\ncontract DRCG is AbstractToken {\r\n  /**\r\n   * Maximum allowed number of tokens in circulation.\r\n   * tokenSupply = tokensIActuallyWant * (10 ^ decimals)\r\n   */\r\n   \r\n   \r\n  uint256 constant MAX_TOKEN_COUNT = 100000000 * (10**18);\r\n   \r\n  /**\r\n   * Address of the owner of this smart contract.\r\n   */\r\n  address private owner;\r\n  \r\n  /**\r\n   * Frozen account list holder\r\n   */\r\n  mapping (address =\u003E bool) private frozenAccount;\r\n\r\n  /**\r\n   * Current number of tokens in circulation.\r\n   */\r\n  uint256 tokenCount = 0;\r\n  \r\n \r\n  /**\r\n   * True if tokens transfers are currently frozen, false otherwise.\r\n   */\r\n  bool frozen = false;\r\n  \r\n \r\n  /**\r\n   * Create new token smart contract and make msg.sender the\r\n   * owner of this smart contract.\r\n   */\r\n  constructor () public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  /**\r\n   * Get total number of tokens in circulation.\r\n   *\r\n   * @return total number of tokens in circulation\r\n   */\r\n  function totalSupply() public view returns (uint256 supply) {\r\n    return tokenCount;\r\n  }\r\n\r\n  string constant public name = \u0022Democratic Republic of Congo Gold Token\u0022;\r\n  string constant public symbol = \u0022DRCG\u0022;\r\n  uint8 constant public decimals = 18;\r\n  \r\n  /**\r\n   * Transfer given number of tokens from message sender to given recipient.\r\n   * @param _to address to transfer tokens to the owner of\r\n   * @param _value number of tokens to transfer to the owner of given address\r\n   * @return true if tokens were transferred successfully, false otherwise\r\n   */\r\n  function transfer(address _to, uint256 _value) public returns (bool success) {\r\n    require(!frozenAccount[msg.sender]);\r\n\tif (frozen) return false;\r\n    else return AbstractToken.transfer (_to, _value);\r\n  }\r\n\r\n  /**\r\n   * Transfer given number of tokens from given owner to given recipient.\r\n   *\r\n   * @param _from address to transfer tokens from the owner of\r\n   * @param _to address to transfer tokens to the owner of\r\n   * @param _value number of tokens to transfer from given owner to given\r\n   *        recipient\r\n   * @return true if tokens were transferred successfully, false otherwise\r\n   */\r\n  function transferFrom(address _from, address _to, uint256 _value) public\r\n    returns (bool success) {\r\n\trequire(!frozenAccount[_from]);\r\n    if (frozen) return false;\r\n    else return AbstractToken.transferFrom (_from, _to, _value);\r\n  }\r\n\r\n   /**\r\n   * Change how many tokens given spender is allowed to transfer from message\r\n   * spender.  In order to prevent double spending of allowance,\r\n   * To change the approve amount you first have to reduce the addresses\u0060\r\n   * allowance to zero by calling \u0060approve(_spender, 0)\u0060 if it is not\r\n   * already 0 to mitigate the race condition described here:\r\n   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n   * @param _spender address to allow the owner of to transfer tokens from\r\n   *        message sender\r\n   * @param _value number of tokens to allow to transfer\r\n   * @return true if token transfer was successfully approved, false otherwise\r\n   */\r\n  function approve (address _spender, uint256 _value) public\r\n    returns (bool success) {\r\n\trequire(allowance (msg.sender, _spender) == 0 || _value == 0);\r\n    return AbstractToken.approve (_spender, _value);\r\n  }\r\n\r\n  /**\r\n   * Create _value new tokens and give new created tokens to msg.sender.\r\n   * May only be called by smart contract owner.\r\n   *\r\n   * @param _value number of tokens to create\r\n   * @return true if tokens were created successfully, false otherwise\r\n   */\r\n  function createTokens(uint256 _value) public\r\n    returns (bool success) {\r\n    require (msg.sender == owner);\r\n\r\n    if (_value \u003E 0) {\r\n      if (_value \u003E safeSub (MAX_TOKEN_COUNT, tokenCount)) return false;\r\n\t  \r\n      accounts [msg.sender] = safeAdd (accounts [msg.sender], _value);\r\n      tokenCount = safeAdd (tokenCount, _value);\r\n\t  \r\n\t  // adding transfer event and _from address as null address\r\n\t  emit Transfer(address(0), msg.sender, _value);\r\n\t  \r\n\t  return true;\r\n    }\r\n\t\r\n\t  return false;\r\n    \r\n  }\r\n  \r\n  /**\r\n   * For future use only whne we will need more tokens for our main application\r\n   * Create mintedAmount new tokens and give new created tokens to target.\r\n   * May only be called by smart contract owner.\r\n   * @param mintedAmount number of tokens to create\r\n   * @return true if tokens were created successfully, false otherwise\r\n   */\r\n  \r\n  function mintToken(address target, uint256 mintedAmount) public\r\n  returns (bool success) {\r\n    require (msg.sender == owner);\r\n      if (mintedAmount \u003E 0) {\r\n\t  \r\n      accounts [target] = safeAdd (accounts [target], mintedAmount);\r\n      tokenCount = safeAdd (tokenCount, mintedAmount);\r\n\t  \r\n\t  // adding transfer event and _from address as null address\r\n\t  emit Transfer(address(0), target, mintedAmount);\r\n\t  \r\n\t   return true;\r\n    }\r\n\t  return false;\r\n   \r\n    }\r\n\t\r\n\t\r\n\r\n  /**\r\n   * Burn intended tokens.\r\n   * Only be called by by burnable addresses.\r\n   *\r\n   * @param _value number of tokens to burn\r\n   * @return true if burnt successfully, false otherwise\r\n   */\r\n  \r\n  function burn(uint256 _value) public returns (bool success) {\r\n  \r\n        require(accounts[msg.sender] \u003E= _value); \r\n\t\t\r\n\t\trequire (msg.sender == owner);\r\n\t\t\r\n\t\taccounts [msg.sender] = safeSub (accounts [msg.sender], _value);\r\n\t\t\r\n        tokenCount = safeSub (tokenCount, _value);\t\r\n\t\t\r\n        emit Burn(msg.sender, _value);\r\n\t\t\r\n        return true;\r\n    }\r\n  \r\n  \r\n\r\n  /**\r\n   * Set new owner for the smart contract.\r\n   * May only be called by smart contract owner.\r\n   *\r\n   * @param _newOwner address of new owner of the smart contract\r\n   */\r\n  function setOwner(address _newOwner) public {\r\n    require (msg.sender == owner);\r\n\r\n    owner = _newOwner;\r\n  }\r\n\r\n  /**\r\n   * Freeze ALL token transfers.\r\n   * May only be called by smart contract owner.\r\n   */\r\n  function freezeTransfers () public {\r\n    require (msg.sender == owner);\r\n\r\n    if (!frozen) {\r\n      frozen = true;\r\n      emit Freeze ();\r\n    }\r\n  }\r\n\r\n  /**\r\n   * Unfreeze ALL token transfers.\r\n   * May only be called by smart contract owner.\r\n   */\r\n  function unfreezeTransfers () public {\r\n    require (msg.sender == owner);\r\n\r\n    if (frozen) {\r\n      frozen = false;\r\n      emit Unfreeze ();\r\n    }\r\n  }\r\n  \r\n  \r\n  /**\r\n  * A user is able to unintentionally send tokens to a contract \r\n  * and if the contract is not prepared to refund them they will get stuck in the contract. \r\n  * The same issue used to happen for Ether too but new Solidity versions added the payable modifier to\r\n  * prevent unintended Ether transfers. However, there\u2019s no such mechanism for token transfers.\r\n  * so the below function is created\r\n  */\r\n  \r\n  function refundTokens(address _token, address _refund, uint256 _value) public {\r\n    require (msg.sender == owner);\r\n    require(_token != address(this));\r\n    AbstractToken token = AbstractToken(_token);\r\n    token.transfer(_refund, _value);\r\n    emit RefundTokens(_token, _refund, _value);\r\n  }\r\n  \r\n  /**\r\n   * Freeze specific account\r\n   * May only be called by smart contract owner.\r\n   */\r\n  function freezeAccount(address _target, bool freeze) public {\r\n      require (msg.sender == owner);\r\n\t  require (msg.sender != _target);\r\n      frozenAccount[_target] = freeze;\r\n      emit FrozenFunds(_target, freeze);\r\n }\r\n\r\n  /**\r\n   * Logged when token transfers were frozen.\r\n   */\r\n  event Freeze ();\r\n\r\n  /**\r\n   * Logged when token transfers were unfrozen.\r\n   */\r\n  event Unfreeze ();\r\n  \r\n  /**\r\n   * Logged when a particular account is frozen.\r\n   */\r\n  \r\n  event FrozenFunds(address target, bool frozen);\r\n  \r\n  \r\n   /**\r\n   * Logged when a token is burnt.\r\n   */  \r\n  \r\n  event Burn(address target,uint256 _value);\r\n\r\n\r\n\r\n  \r\n  /**\r\n   * when accidentally send other tokens are refunded\r\n   */\r\n  \r\n  event RefundTokens(address _token, address _refund, uint256 _value);\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022freezeTransfers\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022supply\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unfreezeTransfers\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022mintedAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022mintToken\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022createTokens\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_refund\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022refundTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022freeze\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022freezeAccount\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Freeze\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Unfreeze\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022frozen\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022FrozenFunds\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_refund\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022RefundTokens\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"DRCG","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://27957e9f5875ebb664cff8d331a5f4b47c134d3f209374f558db54683e9161e0"}]