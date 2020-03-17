[{"SourceCode":"pragma solidity 0.6.1;\r\n\r\n\r\nlibrary SafeMath {\r\n\r\n  \r\n  string constant OVERFLOW = \u0022008001\u0022;\r\n  string constant SUBTRAHEND_GREATER_THEN_MINUEND = \u0022008002\u0022;\r\n  string constant DIVISION_BY_ZERO = \u0022008003\u0022;\r\n\r\n  \r\n  function mul(\r\n    uint256 _factor1,\r\n    uint256 _factor2\r\n  )\r\n    internal\r\n    pure\r\n    returns (uint256 product)\r\n  {\r\n    \r\n    \r\n    \r\n    if (_factor1 == 0)\r\n    {\r\n      return 0;\r\n    }\r\n\r\n    product = _factor1 * _factor2;\r\n    require(product / _factor1 == _factor2, OVERFLOW);\r\n  }\r\n\r\n  \r\n  function div(\r\n    uint256 _dividend,\r\n    uint256 _divisor\r\n  )\r\n    internal\r\n    pure\r\n    returns (uint256 quotient)\r\n  {\r\n    \r\n    require(_divisor \u003E 0, DIVISION_BY_ZERO);\r\n    quotient = _dividend / _divisor;\r\n    \r\n  }\r\n\r\n  \r\n  function sub(\r\n    uint256 _minuend,\r\n    uint256 _subtrahend\r\n  )\r\n    internal\r\n    pure\r\n    returns (uint256 difference)\r\n  {\r\n    require(_subtrahend \u003C= _minuend, SUBTRAHEND_GREATER_THEN_MINUEND);\r\n    difference = _minuend - _subtrahend;\r\n  }\r\n\r\n  \r\n  function add(\r\n    uint256 _addend1,\r\n    uint256 _addend2\r\n  )\r\n    internal\r\n    pure\r\n    returns (uint256 sum)\r\n  {\r\n    sum = _addend1 \u002B _addend2;\r\n    require(sum \u003E= _addend1, OVERFLOW);\r\n  }\r\n\r\n  \r\n  function mod(\r\n    uint256 _dividend,\r\n    uint256 _divisor\r\n  )\r\n    internal\r\n    pure\r\n    returns (uint256 remainder)\r\n  {\r\n    require(_divisor != 0, DIVISION_BY_ZERO);\r\n    remainder = _dividend % _divisor;\r\n  }\r\n\r\n}\r\n\r\ninterface ERC165 {\r\n\r\n  \r\n  function supportsInterface(\r\n    bytes4 _interfaceID\r\n  )\r\n    external\r\n    view\r\n    returns (bool);\r\n\r\n}\r\n\r\ncontract SupportsInterface is\r\n  ERC165\r\n{\r\n\r\n  \r\n  mapping(bytes4 =\u003E bool) internal supportedInterfaces;\r\n\r\n  \r\n  constructor()\r\n    public\r\n  {\r\n    supportedInterfaces[0x01ffc9a7] = true; \r\n  }\r\n\r\n  \r\n  function supportsInterface(\r\n    bytes4 _interfaceID\r\n  )\r\n    external\r\n    override\r\n    view\r\n    returns (bool)\r\n  {\r\n    return supportedInterfaces[_interfaceID];\r\n  }\r\n\r\n}\r\n\r\ninterface ERC20 {\r\n\r\n  \r\n  function name()\r\n    external\r\n    view\r\n    returns (string memory _name);\r\n\r\n  \r\n  function symbol()\r\n    external\r\n    view\r\n    returns (string memory _symbol);\r\n\r\n  \r\n  function decimals()\r\n    external\r\n    view\r\n    returns (uint8 _decimals);\r\n\r\n  \r\n  function totalSupply()\r\n    external\r\n    view\r\n    returns (uint256 _totalSupply);\r\n\r\n  \r\n  function balanceOf(\r\n    address _owner\r\n  )\r\n    external\r\n    view\r\n    returns (uint256 _balance);\r\n\r\n  \r\n  function transfer(\r\n    address _to,\r\n    uint256 _value\r\n  )\r\n    external\r\n    returns (bool _success);\r\n\r\n  \r\n  function transferFrom(\r\n    address _from,\r\n    address _to,\r\n    uint256 _value\r\n  )\r\n    external\r\n    returns (bool _success);\r\n\r\n  \r\n  function approve(\r\n    address _spender,\r\n    uint256 _value\r\n  )\r\n    external\r\n    returns (bool _success);\r\n\r\n  \r\n  function allowance(\r\n    address _owner,\r\n    address _spender\r\n  )\r\n    external\r\n    view\r\n    returns (uint256 _remaining);\r\n\r\n  \r\n  event Transfer(\r\n    address indexed _from,\r\n    address indexed _to,\r\n    uint256 _value\r\n  );\r\n\r\n  \r\n  event Approval(\r\n    address indexed _owner,\r\n    address indexed _spender,\r\n    uint256 _value\r\n  );\r\n\r\n}\r\n\r\ncontract Token is\r\n  ERC20,\r\n  SupportsInterface\r\n{\r\n  using SafeMath for uint256;\r\n\r\n  \r\n  string constant NOT_ENOUGH_BALANCE = \u0022001001\u0022;\r\n  string constant NOT_ENOUGH_ALLOWANCE = \u0022001002\u0022;\r\n\r\n  \r\n  string internal tokenName;\r\n\r\n  \r\n  string internal tokenSymbol;\r\n\r\n  \r\n  uint8 internal tokenDecimals;\r\n\r\n  \r\n  uint256 internal tokenTotalSupply;\r\n\r\n  \r\n  mapping (address =\u003E uint256) internal balances;\r\n\r\n  \r\n  mapping (address =\u003E mapping (address =\u003E uint256)) internal allowed;\r\n\r\n  \r\n  event Transfer(\r\n    address indexed _from,\r\n    address indexed _to,\r\n    uint256 _value\r\n  );\r\n\r\n  \r\n  event Approval(\r\n    address indexed _owner,\r\n    address indexed _spender,\r\n    uint256 _value\r\n  );\r\n\r\n  \r\n  constructor()\r\n    public\r\n  {\r\n    supportedInterfaces[0x36372b07] = true; \r\n    supportedInterfaces[0x06fdde03] = true; \r\n    supportedInterfaces[0x95d89b41] = true; \r\n    supportedInterfaces[0x313ce567] = true; \r\n  }\r\n\r\n  \r\n  function name()\r\n    external\r\n    override\r\n    view\r\n    returns (string memory _name)\r\n  {\r\n    _name = tokenName;\r\n  }\r\n\r\n  \r\n  function symbol()\r\n    external\r\n    override\r\n    view\r\n    returns (string memory _symbol)\r\n  {\r\n    _symbol = tokenSymbol;\r\n  }\r\n\r\n  \r\n  function decimals()\r\n    external\r\n    override\r\n    view\r\n    returns (uint8 _decimals)\r\n  {\r\n    _decimals = tokenDecimals;\r\n  }\r\n\r\n  \r\n  function totalSupply()\r\n    external\r\n    override\r\n    view\r\n    returns (uint256 _totalSupply)\r\n  {\r\n    _totalSupply = tokenTotalSupply;\r\n  }\r\n\r\n  \r\n  function balanceOf(\r\n    address _owner\r\n  )\r\n    external\r\n    override\r\n    view\r\n    returns (uint256 _balance)\r\n  {\r\n    _balance = balances[_owner];\r\n  }\r\n\r\n  \r\n  function allowance(\r\n    address _owner,\r\n    address _spender\r\n  )\r\n    external\r\n    override\r\n    view\r\n    returns (uint256 _remaining)\r\n  {\r\n    _remaining = allowed[_owner][_spender];\r\n  }\r\n\r\n  \r\n  function transfer(\r\n    address _to,\r\n    uint256 _value\r\n  )\r\n    public\r\n    override\r\n    returns (bool _success)\r\n  {\r\n    require(_value \u003C= balances[msg.sender], NOT_ENOUGH_BALANCE);\r\n\r\n    balances[msg.sender] = balances[msg.sender].sub(_value);\r\n    balances[_to] = balances[_to].add(_value);\r\n\r\n    emit Transfer(msg.sender, _to, _value);\r\n    _success = true;\r\n  }\r\n\r\n  \r\n  function approve(\r\n    address _spender,\r\n    uint256 _value\r\n  )\r\n    public\r\n    override\r\n    returns (bool _success)\r\n  {\r\n    allowed[msg.sender][_spender] = _value;\r\n\r\n    emit Approval(msg.sender, _spender, _value);\r\n    _success = true;\r\n  }\r\n\r\n  \r\n  function transferFrom(\r\n    address _from,\r\n    address _to,\r\n    uint256 _value\r\n  )\r\n    public\r\n    override\r\n    returns (bool _success)\r\n  {\r\n    require(_value \u003C= balances[_from], NOT_ENOUGH_BALANCE);\r\n    require(_value \u003C= allowed[_from][msg.sender], NOT_ENOUGH_ALLOWANCE);\r\n\r\n    balances[_from] = balances[_from].sub(_value);\r\n    balances[_to] = balances[_to].add(_value);\r\n    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n\r\n    emit Transfer(_from, _to, _value);\r\n    _success = true;\r\n  }\r\n\r\n}\r\n\r\ncontract TokenCustom is\r\n  Token\r\n{\r\n  constructor(\r\n    string memory _name,\r\n    string memory _symbol,\r\n    uint256 _supply,\r\n    uint8 _decimals,\r\n    address _owner\r\n  )\r\n    public\r\n  {\r\n    tokenName = _name;\r\n    tokenSymbol = _symbol;\r\n    tokenDecimals = _decimals;\r\n    tokenTotalSupply = _supply;\r\n    balances[_owner] = tokenTotalSupply;\r\n    emit Transfer(address(0), _owner, tokenTotalSupply);\r\n  }\r\n}\r\n\r\ncontract TokenDeployProxy {\r\n  \r\n  function deploy(\r\n    string memory _name,\r\n    string memory _symbol,\r\n    uint256 _supply,\r\n    uint8 _decimals,\r\n    address _owner\r\n  )\r\n    public\r\n    returns (address token)\r\n  {\r\n    token = address(\r\n      new TokenCustom(\r\n        _name, _symbol, _supply, _decimals, _owner\r\n      )\r\n    );\r\n  }\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_symbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_supply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022_decimals\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022deploy\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"TokenDeployProxy","CompilerVersion":"v0.6.1\u002Bcommit.e6f7d5a4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"ipfs://e52eaba66f42a0ff325bc6c5c366141469a61e9f700dc388fe942eef1a6f2918"}]