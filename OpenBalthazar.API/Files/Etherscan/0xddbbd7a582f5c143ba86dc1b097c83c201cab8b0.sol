[{"SourceCode":"pragma solidity ^0.4.24;\r\n\r\n/**\r\n * Math operations with safety checks\r\n */\r\ncontract SafeMath {\r\n  function mul(uint256 _a, uint256 _b) internal pure returns (uint256){\r\n    if (_a == 0) {\r\n      return 0;\r\n    }\r\n    uint256 c = _a * _b;\r\n    assert(c / _a == _b);\r\n    return c;\r\n  }\r\n\r\n  function div(uint256 _a, uint256 _b) internal pure returns (uint256){\r\n    uint256 c = _a / _b;\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return c;\r\n  }\r\n\r\n  function sub(uint256 _a, uint256 _b) internal pure returns (uint256){\r\n    assert(_b \u003C= _a);\r\n    return _a - _b;\r\n  }\r\n\r\n  function add(uint256 _a,uint256 _b) internal pure returns (uint256){\r\n    uint256 c = _a \u002B _b;\r\n    assert(c \u003E= _a);\r\n    return c;\r\n  }\r\n\r\n}\r\n\r\ncontract Ownable {\r\n  address public owner;\r\n\r\n  event OwnershipTransferred(\r\n    address indexed previousOwner,\r\n    address indexed newOwner\r\n  );\r\n\r\n  constructor () public{\r\n    owner = msg.sender;\r\n  }\r\n\r\n  modifier onlyOwner {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n  function transferOwnership(\r\n    address _newOwner\r\n  )\r\n    onlyOwner\r\n    public\r\n  {\r\n    require(_newOwner != address(0));\r\n    emit OwnershipTransferred(owner, _newOwner);\r\n    owner = _newOwner;\r\n  }\r\n}\r\n\r\ncontract ERC20StdToken is Ownable, SafeMath {\r\n  uint256 public totalSupply;\r\n\tstring  public name;\r\n\tuint8   public decimals;\r\n\tstring  public symbol;\r\n\tbool    public isMint;     // \u662F\u5426\u53EF\u589E\u53D1\r\n    bool    public isBurn;    // \u662F\u5426\u53EF\u9500\u6BC1\r\n    bool    public isFreeze; // \u662F\u5426\u53EF\u51BB\u7ED3\r\n\r\n  mapping (address =\u003E uint256) public balanceOf;\r\n  mapping (address =\u003E uint256) public freezeOf;\r\n  mapping (address =\u003E mapping (address =\u003E uint256)) public allowance;\r\n\r\n  constructor(\r\n    address _owner,\r\n    string _name,\r\n    string _symbol,\r\n    uint8 _decimals,\r\n    uint256 _initialSupply,\r\n    bool _isMint,\r\n    bool _isBurn,\r\n    bool _isFreeze) public {\r\n    require(_owner != address(0));\r\n    owner             = _owner;\r\n  \tdecimals          = _decimals;\r\n  \tsymbol            = _symbol;\r\n  \tname              = _name;\r\n  \tisMint            = _isMint;\r\n    isBurn            = _isBurn;\r\n    isFreeze          = _isFreeze;\r\n  \ttotalSupply       = _initialSupply * 10 ** uint256(decimals);\r\n    balanceOf[_owner] = totalSupply;\r\n }\r\n\r\n // This generates a public event on the blockchain that will notify clients\r\n event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n\r\n /* This notifies clients about the amount burnt */\r\n event Burn(address indexed _from, uint256 value);\r\n\r\n  /* This notifies clients about the amount frozen */\r\n event Freeze(address indexed _from, uint256 value);\r\n\r\n  /* This notifies clients about the amount unfrozen */\r\n event Unfreeze(address indexed _from, uint256 value);\r\n\r\n function approve(address _spender, uint256 _value) public returns (bool success) {\r\n   allowance[msg.sender][_spender] = _value;\r\n   emit Approval(msg.sender, _spender, _value);\r\n   success = true;\r\n }\r\n\r\n /// @notice send \u0060_value\u0060 token to \u0060_to\u0060 from \u0060msg.sender\u0060\r\n /// @param _to The address of the recipient\r\n /// @param _value The amount of token to be transferred\r\n /// @return Whether the transfer was successful or not\r\n function transfer(address _to, uint256 _value) public returns (bool success) {\r\n   require(_to != 0);\r\n   require(balanceOf[msg.sender] \u003E= _value);\r\n   require(balanceOf[_to] \u002B _value \u003E= balanceOf[_to]);\r\n   // balanceOf[msg.sender] -= _value;\r\n   balanceOf[msg.sender] = SafeMath.sub(balanceOf[msg.sender], _value);\r\n\r\n   // balanceOf[_to] \u002B= _value;\r\n   balanceOf[_to] = SafeMath.add(balanceOf[_to], _value);\r\n\r\n   emit Transfer(msg.sender, _to, _value);\r\n   success = true;\r\n }\r\n\r\n /// @notice send \u0060_value\u0060 token to \u0060_to\u0060 from \u0060_from\u0060 on the condition it is approved by \u0060_from\u0060\r\n /// @param _from The address of the sender\r\n /// @param _to The address of the recipient\r\n /// @param _value The amount of token to be transferred\r\n /// @return Whether the transfer was successful or not\r\n function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {\r\n   require(_to != 0);\r\n   require(balanceOf[_from] \u003E= _value);\r\n   require(allowance[_from][msg.sender] \u003E= _value);\r\n   require(balanceOf[_to] \u002B _value \u003E= balanceOf[_to]);\r\n   // balanceOf[_from] -= _value;\r\n   balanceOf[_from] = SafeMath.sub(balanceOf[_from], _value);\r\n   // balanceOf[_to] \u002B= _value;\r\n   balanceOf[_to] = SafeMath.add(balanceOf[_to], _value);\r\n\r\n   // allowance[_from][msg.sender] -= _value;\r\n   allowance[_from][msg.sender] = SafeMath.sub(allowance[_from][msg.sender], _value);\r\n\r\n   emit Transfer(_from, _to, _value);\r\n   success = true;\r\n }\r\n\r\n  function mint(uint256 amount) onlyOwner public {\r\n  \trequire(isMint);\r\n  \trequire(amount \u003E= 0);\r\n  \t// balanceOf[msg.sender] \u002B= amount;\r\n    balanceOf[msg.sender] = SafeMath.add(balanceOf[msg.sender], amount);\r\n  \t// totalSupply \u002B= amount;\r\n    totalSupply = SafeMath.add(totalSupply, amount);\r\n  }\r\n\r\n  function burn(uint256 _value) public returns (bool success) {\r\n    require(balanceOf[msg.sender] \u003E= _value);            // Check if the sender has enough\r\n    require(_value \u003E 0);\r\n    balanceOf[msg.sender] = SafeMath.sub(balanceOf[msg.sender], _value);                      // Subtract from the sender\r\n    totalSupply = SafeMath.sub(totalSupply, _value);                                // Updates totalSupply\r\n    emit Burn(msg.sender, _value);\r\n    success = true;\r\n }\r\n\r\n  function freeze(uint256 _value) public returns (bool success) {\r\n    require(balanceOf[msg.sender] \u003E= _value);            // Check if the sender has enough\r\n    require(_value \u003E 0);\r\n    balanceOf[msg.sender] = SafeMath.sub(balanceOf[msg.sender], _value);                      // Subtract from the sender\r\n    freezeOf[msg.sender] = SafeMath.add(freezeOf[msg.sender], _value);                                // Updates totalSupply\r\n    emit Freeze(msg.sender, _value);\r\n    success = true;\r\n  }\r\n\r\n  function unfreeze(uint256 _value) public returns (bool success) {\r\n    require(freezeOf[msg.sender] \u003E= _value);            // Check if the sender has enough\r\n    require(_value \u003E 0);\r\n    freezeOf[msg.sender] = SafeMath.sub(freezeOf[msg.sender], _value);                      // Subtract from the sender\r\n    balanceOf[msg.sender] = SafeMath.add(balanceOf[msg.sender], _value);\r\n    emit Unfreeze(msg.sender, _value);\r\n    success = true;\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isBurn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isMint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022unfreeze\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022mint\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isFreeze\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022freezeOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022freeze\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_symbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_decimals\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022_initialSupply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_isMint\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022_isBurn\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022_isFreeze\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Freeze\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Unfreeze\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"ERC20StdToken","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000a7536a83f4ef88b0435cc83695b7101f21e9ad2f000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000000000000000000000000000000004e9e57c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000054c41524b5400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024c54000000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://75bfe20b4b8713c4ccc9645c864499b1d32032cb37e816e6a076349345bd15a7"}]