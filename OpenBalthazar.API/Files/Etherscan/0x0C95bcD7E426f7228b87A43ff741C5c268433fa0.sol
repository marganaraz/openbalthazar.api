[{"SourceCode":"/**************************************************************************\r\n *            ____        _                              \r\n *           / ___|      | |     __ _  _   _   ___  _ __ \r\n *          | |    _____ | |    / _\u0060 || | | | / _ \\| \u0027__|\r\n *          | |___|_____|| |___| (_| || |_| ||  __/| |   \r\n *           \\____|      |_____|\\__,_| \\__, | \\___||_|   \r\n *                                     |___/             \r\n * \r\n **************************************************************************\r\n *\r\n *  The MIT License (MIT)\r\n *\r\n * Copyright (c) 2016-2019 Cyril Lapinte\r\n *\r\n * Permission is hereby granted, free of charge, to any person obtaining\r\n * a copy of this software and associated documentation files (the\r\n * \u0022Software\u0022), to deal in the Software without restriction, including\r\n * without limitation the rights to use, copy, modify, merge, publish,\r\n * distribute, sublicense, and/or sell copies of the Software, and to\r\n * permit persons to whom the Software is furnished to do so, subject to\r\n * the following conditions:\r\n *\r\n * The above copyright notice and this permission notice shall be included\r\n * in all copies or substantial portions of the Software.\r\n *\r\n * THE SOFTWARE IS PROVIDED \u0022AS IS\u0022, WITHOUT WARRANTY OF ANY KIND, EXPRESS\r\n * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF\r\n * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.\r\n * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY\r\n * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,\r\n * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE\r\n * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\r\n *\r\n **************************************************************************\r\n *\r\n * Flatten Contract: RatesProvider\r\n *\r\n * Git Commit:\r\n * https://github.com/c-layer/contracts/tree/43925ba24cc22f42d0ff7711d0e169e8c2a0e09f\r\n *\r\n **************************************************************************/\r\n\r\n\r\n// File: contracts/interface/IRatesProvider.sol\r\n\r\npragma solidity \u003E=0.5.0 \u003C0.6.0;\r\n\r\n\r\n/**\r\n * @title IRatesProvider\r\n * @dev IRatesProvider interface\r\n *\r\n * @author Cyril Lapinte - \u003Ccyril.lapinte@openfiz.com\u003E\r\n */\r\ncontract IRatesProvider {\r\n\r\n  function defineRatesExternal(uint256[] calldata _rates) external returns (bool);\r\n\r\n  function name() public view returns (string memory);\r\n\r\n  function rate(bytes32 _currency) public view returns (uint256);\r\n\r\n  function currencies() public view\r\n    returns (bytes32[] memory, uint256[] memory, uint256);\r\n  function rates() public view returns (uint256, uint256[] memory);\r\n\r\n  function convert(uint256 _amount, bytes32 _fromCurrency, bytes32 _toCurrency)\r\n    public view returns (uint256);\r\n\r\n  function defineCurrencies(\r\n    bytes32[] memory _currencies,\r\n    uint256[] memory _decimals,\r\n    uint256 _rateOffset) public returns (bool);\r\n  function defineRates(uint256[] memory _rates) public returns (bool);\r\n\r\n  event RateOffset(uint256 rateOffset);\r\n  event Currencies(bytes32[] currencies, uint256[] decimals);\r\n  event Rate(bytes32 indexed currency, uint256 rate);\r\n}\r\n\r\n// File: contracts/util/math/SafeMath.sol\r\n\r\npragma solidity \u003E=0.5.0 \u003C0.6.0;\r\n\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n\r\n  /**\r\n  * @dev Multiplies two numbers, throws on overflow.\r\n  */\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n    // Gas optimization: this is cheaper than asserting \u0027a\u0027 not being zero, but the\r\n    // benefit is lost if \u0027b\u0027 is also tested.\r\n    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n\r\n    c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Integer division of two numbers, truncating the quotient.\r\n  */\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    // uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return a / b;\r\n  }\r\n\r\n  /**\r\n  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n  */\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  /**\r\n  * @dev Adds two numbers, throws on overflow.\r\n  */\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n    c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n}\r\n\r\n// File: contracts/util/governance/Ownable.sol\r\n\r\npragma solidity \u003E=0.5.0 \u003C0.6.0;\r\n\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n  address public owner;\r\n\r\n  event OwnershipRenounced(address indexed previousOwner);\r\n  event OwnershipTransferred(\r\n    address indexed previousOwner,\r\n    address indexed newOwner\r\n  );\r\n\r\n\r\n  /**\r\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n   * account.\r\n   */\r\n  constructor() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to relinquish control of the contract.\r\n   */\r\n  function renounceOwnership() public onlyOwner {\r\n    emit OwnershipRenounced(owner);\r\n    owner = address(0);\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n   * @param _newOwner The address to transfer ownership to.\r\n   */\r\n  function transferOwnership(address _newOwner) public onlyOwner {\r\n    _transferOwnership(_newOwner);\r\n  }\r\n\r\n  /**\r\n   * @dev Transfers control of the contract to a newOwner.\r\n   * @param _newOwner The address to transfer ownership to.\r\n   */\r\n  function _transferOwnership(address _newOwner) internal {\r\n    require(_newOwner != address(0));\r\n    emit OwnershipTransferred(owner, _newOwner);\r\n    owner = _newOwner;\r\n  }\r\n}\r\n\r\n// File: contracts/util/governance/Operable.sol\r\n\r\npragma solidity \u003E=0.5.0 \u003C0.6.0;\r\n\r\n\r\n\r\n/**\r\n * @title Operable\r\n * @dev The Operable contract enable the restrictions of operations to a set of operators\r\n *\r\n * @author Cyril Lapinte - \u003Ccyril.lapinte@openfiz.com\u003E\r\n *\r\n * Error messages\r\n * OP01: Message sender must be an operator\r\n * OP02: Address must be an operator\r\n * OP03: Address must not be an operator\r\n */\r\ncontract Operable is Ownable {\r\n\r\n  mapping (address =\u003E bool) private operators_;\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the operator\r\n   */\r\n  modifier onlyOperator {\r\n    require(operators_[msg.sender], \u0022OP01\u0022);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev constructor\r\n   */\r\n  constructor() public {\r\n    defineOperator(\u0022Owner\u0022, msg.sender);\r\n  }\r\n\r\n  /**\r\n   * @dev isOperator\r\n   * @param _address operator address\r\n   */\r\n  function isOperator(address _address) public view returns (bool) {\r\n    return operators_[_address];\r\n  }\r\n\r\n  /**\r\n   * @dev removeOperator\r\n   * @param _address operator address\r\n   */\r\n  function removeOperator(address _address) public onlyOwner {\r\n    require(operators_[_address], \u0022OP02\u0022);\r\n    operators_[_address] = false;\r\n    emit OperatorRemoved(_address);\r\n  }\r\n\r\n  /**\r\n   * @dev defineOperator\r\n   * @param _role operator role\r\n   * @param _address operator address\r\n   */\r\n  function defineOperator(string memory _role, address _address)\r\n    public onlyOwner\r\n  {\r\n    require(!operators_[_address], \u0022OP03\u0022);\r\n    operators_[_address] = true;\r\n    emit OperatorDefined(_role, _address);\r\n  }\r\n\r\n  event OperatorRemoved(address address_);\r\n  event OperatorDefined(\r\n    string role,\r\n    address address_\r\n  );\r\n}\r\n\r\n// File: contracts/RatesProvider.sol\r\n\r\npragma solidity \u003E=0.5.0 \u003C0.6.0;\r\n\r\n\r\n\r\n\r\n\r\n/**\r\n * @title RatesProvider\r\n * @dev RatesProvider interface\r\n * @dev The null value for a rate indicates that the rate is undefined\r\n * @dev It is recommended that smart contracts always check against a null rate\r\n *\r\n * @author Cyril Lapinte - \u003Ccyril.lapinte@openfiz.com\u003E\r\n *\r\n * Error messages\r\n *   RP01: Currencies must match decimals length\r\n *   RP02: rateOffset cannot be null\r\n *   RP03: Rates definition must only target configured currencies\r\n */\r\ncontract RatesProvider is IRatesProvider, Operable {\r\n  using SafeMath for uint256;\r\n\r\n  string internal name_;\r\n\r\n  // decimals offset with which rates are stored using the counter currency\r\n  // this must be high enought to cover worse case\r\n  // Can only be set to 1 with ETH or ERC20 which already have 18 decimals\r\n  // It should likely be configured to 10**16 (18-2) for GBP, USD or CHF.\r\n  uint256 internal rateOffset_ = 1;\r\n\r\n  // The first currency will be the counter currency\r\n  bytes32[] internal currencies_ =\r\n    [ bytes32(\u0022ETH\u0022), \u0022BTC\u0022, \u0022EOS\u0022, \u0022GBP\u0022, \u0022USD\u0022, \u0022CHF\u0022, \u0022EUR\u0022, \u0022CNY\u0022, \u0022JPY\u0022, \u0022CAD\u0022, \u0022AUD\u0022 ];\r\n  uint256[] internal decimals_ = [ uint256(18), 8, 4, 2, 2, 2, 2, 2, 2, 2, 2 ];\r\n\r\n  mapping(bytes32 =\u003E uint256) internal ratesMap;\r\n  uint256[] internal rates_ = new uint256[](currencies_.length-1);\r\n  uint256 internal updatedAt_;\r\n\r\n  /*\r\n   * @dev constructor\r\n   */\r\n  constructor(string memory _name) public {\r\n    name_ = _name;\r\n    for (uint256 i=0; i \u003C currencies_.length; i\u002B\u002B) {\r\n      ratesMap[currencies_[i]] = i;\r\n    }\r\n  }\r\n\r\n  /**\r\n   * @dev define all rates\r\n   * @dev The rates should be defined in the base currency (WEI, Satoshi, cents, ...)\r\n   * @dev Rates should also account for rateOffset\r\n   */\r\n  function defineRatesExternal(uint256[] calldata _rates)\r\n    external onlyOperator returns (bool)\r\n  {\r\n    require(_rates.length \u003C currencies_.length, \u0022RP03\u0022);\r\n\r\n    // solhint-disable-next-line not-rely-on-time\r\n    updatedAt_ = now;\r\n    for (uint256 i=0; i \u003C _rates.length; i\u002B\u002B) {\r\n      if (rates_[i] != _rates[i]) {\r\n        rates_[i] = _rates[i];\r\n        emit Rate(currencies_[i\u002B1], _rates[i]);\r\n      }\r\n    }\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev name\r\n   */\r\n  function name() public view returns (string memory) {\r\n    return name_;\r\n  }\r\n\r\n  /**\r\n   * @dev rate for a currency\r\n   */\r\n  function rate(bytes32 _currency) public view returns (uint256) {\r\n    return ratePrivate(_currency);\r\n  }\r\n\r\n  /**\r\n   * @dev currencies\r\n   */\r\n  function currencies() public view\r\n    returns (bytes32[] memory, uint256[] memory, uint256)\r\n  {\r\n    return (currencies_, decimals_, rateOffset_);\r\n  }\r\n\r\n  /**\r\n   * @dev rate as store for a currency\r\n   */\r\n  function rates() public view returns (uint256, uint256[] memory) {\r\n    return (updatedAt_, rates_);\r\n  }\r\n\r\n  /**\r\n   * @dev convert between two currency (base units)\r\n   */\r\n  function convert(uint256 _amount, bytes32 _fromCurrency, bytes32 _toCurrency)\r\n    public view returns (uint256)\r\n  {\r\n    if (_fromCurrency == _toCurrency) {\r\n      return _amount;\r\n    }\r\n\r\n    uint256 rateFrom = (_fromCurrency != currencies_[0]) ?\r\n      ratePrivate(_fromCurrency) : rateOffset_;\r\n    uint256 rateTo = (_toCurrency != currencies_[0]) ?\r\n      ratePrivate(_toCurrency) : rateOffset_;\r\n\r\n    return (rateTo != 0) ?\r\n      _amount.mul(rateFrom).div(rateTo) : 0;\r\n  }\r\n\r\n  /**\r\n   * @dev define all currencies\r\n   * @dev @param _rateOffset is to be used when the default currency\r\n   * @dev does not have enough decimals for sufficient rate precisions\r\n   */\r\n  function defineCurrencies(\r\n    bytes32[] memory _currencies,\r\n    uint256[] memory _decimals,\r\n    uint256 _rateOffset) public onlyOperator returns (bool)\r\n  {\r\n    require(_currencies.length == _decimals.length, \u0022RP01\u0022);\r\n    require(_rateOffset != 0, \u0022RP02\u0022);\r\n\r\n    for (uint256 i= _currencies.length; i \u003C currencies_.length; i\u002B\u002B) {\r\n      delete ratesMap[currencies_[i]];\r\n      emit Rate(currencies_[i], 0);\r\n    }\r\n    rates_.length = _currencies.length-1;\r\n\r\n    bool hasBaseCurrencyChanged = _currencies[0] != currencies_[0];\r\n    for (uint256 i=1; i \u003C _currencies.length; i\u002B\u002B) {\r\n      bytes32 currency = _currencies[i];\r\n      if (rateOffset_ != _rateOffset\r\n        || ratesMap[currency] != i\r\n        || hasBaseCurrencyChanged)\r\n      {\r\n        ratesMap[currency] = i;\r\n        rates_[i-1] = 0;\r\n\r\n        if (i \u003C currencies_.length) {\r\n          emit Rate(currencies_[i], 0);\r\n        }\r\n      }\r\n    }\r\n\r\n    if (rateOffset_ != _rateOffset) {\r\n      emit RateOffset(_rateOffset);\r\n      rateOffset_ = _rateOffset;\r\n    }\r\n\r\n    // solhint-disable-next-line not-rely-on-time\r\n    updatedAt_ = now;\r\n    currencies_ = _currencies;\r\n    decimals_ = _decimals;\r\n\r\n    emit Currencies(_currencies, _decimals);\r\n    return true;\r\n  }\r\n  \r\n  /**\r\n   * @dev define all rates\r\n   * @dev The rates should be defined in the base currency (WEI, Satoshi, cents, ...)\r\n   * @dev Rates should also account for rateOffset\r\n   */\r\n  function defineRates(uint256[] memory _rates)\r\n    public onlyOperator returns (bool)\r\n  {\r\n    require(_rates.length \u003C currencies_.length, \u0022RP03\u0022);\r\n\r\n    // solhint-disable-next-line not-rely-on-time\r\n    updatedAt_ = now;\r\n    for (uint256 i=0; i \u003C _rates.length; i\u002B\u002B) {\r\n      if (rates_[i] != _rates[i]) {\r\n        rates_[i] = _rates[i];\r\n        emit Rate(currencies_[i\u002B1], _rates[i]);\r\n      }\r\n    }\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev rate for a currency\r\n   */\r\n  function ratePrivate(bytes32 _currency) private view returns (uint256) {\r\n    if (_currency == currencies_[0]) {\r\n      return 1;\r\n    }\r\n\r\n    uint256 id = ratesMap[_currency];\r\n    return (id \u003E 0) ? rates_[id-1] : 0;\r\n  }\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bytes32[]\u0022,\u0022name\u0022:\u0022currencies\u0022,\u0022type\u0022:\u0022bytes32[]\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022decimals\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022Currencies\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022role\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022address_\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OperatorDefined\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022address_\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OperatorRemoved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipRenounced\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022currency\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Rate\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rateOffset\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022RateOffset\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_fromCurrency\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_toCurrency\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022convert\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022currencies\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32[]\u0022,\u0022name\u0022:\u0022_currencies\u0022,\u0022type\u0022:\u0022bytes32[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_decimals\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_rateOffset\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022defineCurrencies\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_role\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022defineOperator\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_rates\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022defineRates\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_rates\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022defineRatesExternal\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isOperator\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_currency\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022rate\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022rates\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022removeOperator\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"RatesProvider","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"1","Runs":"1000","ConstructorArguments":"0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000a416c74636f696e6f6d7900000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://7b49962ba154e7c10e84efe175497c10f32e6f07572ad6ef9796f90bd42c645f"}]