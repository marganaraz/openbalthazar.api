[{"SourceCode":"/**\r\n *\r\n * SpaceWave Contract for Initial Coin Offering\r\n *\r\n */\r\n\r\npragma solidity ^0.5.10;\r\n\r\n\r\n/**\r\n * @title ERC20 interface\r\n * see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md\r\n */\r\ninterface IERC20\r\n{\r\n  function name() external view returns (string memory);\r\n  \r\n  function symbol() external view returns (string memory);\r\n\r\n  function decimals() external view returns (uint8);\r\n\r\n  function totalSupply() external view returns (uint256);\r\n\r\n  function balanceOf(address who) external view returns (uint256 balance);\r\n\r\n  function transfer(address to, uint256 value) external returns (bool success);\r\n\r\n  function transferFrom(address from, address to, uint256 value) external returns (bool success);\r\n\r\n  function approve(address spender, uint256 value) external returns (bool success);\r\n\r\n  function allowance(address owner, address spender) external view returns (uint256 remaining);\r\n\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n  event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n/**\r\n * \r\n * Main Contract for creating and managing SPW Tokens\r\n * \r\n */\r\ncontract SpaceWave is IERC20\r\n{\r\n  ////////////////////////\r\n  //// Base variables\r\n  \r\n  uint256 internal _totalSupply;\r\n  uint8 internal _decimals;\r\n\r\n  function name() public view returns (string memory)                     { return \u0022SpaceWave\u0022; }\r\n  function symbol() public view returns (string memory)                   { return \u0022SPW\u0022; }\r\n  function decimals() public view returns (uint8)                           { return _decimals; }\r\n  function totalSupply() public view returns (uint256)                      { return _totalSupply; }\r\n\r\n  ////////////////////////\r\n  //// Owner related\r\n  address internal _owner;\r\n  \r\n  modifier byOwner {\r\n    require(msg.sender == _owner);\r\n    _;\r\n  }\r\n  \r\n  ////////////////////////\r\n  //// Pause functionality\r\n  \r\n  bool internal _paused;\r\n  \r\n  modifier whenNotPaused {\r\n    require(!_paused);\r\n    _;\r\n  }\r\n  \r\n  function pause() public byOwner returns (bool success) {\r\n    _paused = true;\r\n    return true;\r\n  }\r\n  \r\n  function resume() public byOwner returns (bool success) {\r\n    _paused = false;\r\n    return true;\r\n  }\r\n  \r\n  function isPaused() public view returns (bool paused) {\r\n    return _paused;\r\n  }\r\n  \r\n  ////////////////////////\r\n  /// Core maps related to \r\n  /// balance and allowance\r\n  \r\n  /* This creates a map with all balances */\r\n  mapping (address =\u003E uint256) internal _balanceOf;\r\n\r\n  function balanceOf(address who) public view returns (uint256 balance)   { return _balanceOf[who]; }\r\n\r\n  mapping (address =\u003E mapping (address =\u003E uint256)) internal _allowance;\r\n\r\n  function allowance(address owner, address spender) public view\r\n                                            returns (uint256 remaining)   { return _allowance[owner][spender]; }\r\n\r\n  ////////////////////////\r\n  // Core functions\r\n  \r\n  /** \r\n    * Initializes contract with initial supply tokens to the creator \r\n    * of the contract.\r\n    */\r\n  constructor() public\r\n  {\r\n    _totalSupply = 1000000000000000000000000000; // 1 Billion tokens to begin with, with 18 decimal precision\r\n    _decimals = 18;\r\n    _paused = false;\r\n    _balanceOf[msg.sender] = _totalSupply;              // Give the creator all initial tokens\r\n    _owner = msg.sender;\r\n  }\r\n\r\n  ////////////////////////\r\n  /// Core functions related \r\n  /// to ERC20 tokens\r\n  \r\n  /* Send SPW tokens */\r\n  function transfer(address to, uint256 value) public whenNotPaused returns (bool success)\r\n  {\r\n    require(to != address(0));                   // Prevent transfer to \u00270\u0027 address.\r\n    require(to != msg.sender);                   // Prevent transfer to self\r\n    require(value \u003E 0);\r\n    \r\n    uint256 f = _balanceOf[msg.sender];\r\n    \r\n    require(f \u003E= value);                         // Check if sender has enough\r\n    \r\n    uint256 t = _balanceOf[to];\r\n    uint256 t1 = t \u002B value;\r\n    \r\n    require((t1 \u003E t) \u0026\u0026 (t1 \u003E= value));\r\n                                                                                \r\n    _balanceOf[msg.sender] = f - value;          // Subtract from the sender\r\n    _balanceOf[to] = t1;                         // Add the same to the recipient\r\n\r\n    emit Transfer(msg.sender, to, value);        // Notify anyone listening that this transfer took place\r\n\r\n    return true;\r\n  }\r\n\r\n  /* Allow a spender to spend some SPW tokens in your behalf */\r\n  function approve(address spender, uint256 value) public whenNotPaused returns (bool success)\r\n  {\r\n    require(value \u003E 0);\r\n    require(_balanceOf[msg.sender] \u003E= value);                                 // Allow only how much the sender can spend\r\n\r\n    _allowance[msg.sender][spender] = value;\r\n\r\n    return true;\r\n  }\r\n\r\n  /* An approved third-party transfers SPW tokens */\r\n  function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool success)\r\n  {\r\n    require(to != address(0));                          // Prevent transfer to 0x0 address\r\n    require(from != to);                                // Prevent transfer to self\r\n    require(value \u003E 0);\r\n    \r\n    uint256 f = _balanceOf[from];\r\n    uint256 t = _balanceOf[to];\r\n    uint256 a = _allowance[from][msg.sender];\r\n    \r\n    require((f \u003E= value) \u0026\u0026 (a \u003E= value));\r\n    \r\n    uint256 t1 = t \u002B value;\r\n    \r\n    require((t1 \u003E t) \u0026\u0026 (t1 \u003E= value));\r\n    \r\n    \r\n    _balanceOf[from] = f - value;// Subtract from the sender\r\n    _balanceOf[to]   = t1;  // Add the same to the recipient\r\n\r\n    _allowance[from][msg.sender] = a - value;\r\n\r\n    emit Transfer(from, to, value);\r\n\r\n    return true;\r\n  }\r\n  \r\n  ///////////////////////////\r\n  /// Mint and burn functions\r\n  \r\n  /** \r\n    * This is used only under specific circumstances for increasing token supply\r\n    */\r\n  function mint(uint256 value) public whenNotPaused byOwner returns (bool success)\r\n  {\r\n    uint256 b = _balanceOf[_owner];\r\n    uint256 t = _totalSupply;\r\n    \r\n    uint256 b1 = b \u002B value;\r\n    require((b1 \u003E b) \u0026\u0026 (b1 \u003E= value)); // Ensure value \u003E 0 and there is no overflow\r\n    \r\n    uint256 t1 = t \u002B value;\r\n    require((t1 \u003E t) \u0026\u0026 (t1 \u003E= value));\r\n    \r\n    _balanceOf[_owner] = b1;\r\n    _totalSupply = t1;\r\n    \r\n    return true;\r\n  }\r\n  \r\n  /**\r\n    * Burn tokens. This will allow sender to burn specific number of tokens.\r\n    * WARNING: Use with caution as once some tokens are burnt, they will not come back!\r\n    */\r\n  function burn(uint256 value) public whenNotPaused returns (bool success)\r\n  {\r\n    require(value \u003E 0);\r\n    \r\n    uint256 b = _balanceOf[msg.sender];\r\n    \r\n    require(b \u003E= value);\r\n    \r\n    uint256 t = _totalSupply;\r\n    \r\n    uint256 b1 = b - value;\r\n    \r\n    uint256 t1 = t - value;\r\n    \r\n    require(t1 \u003C t);\r\n    \r\n    _balanceOf[msg.sender] = b1;\r\n    _totalSupply = t1;\r\n    \r\n    return true;\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022resume\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022mint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isPaused\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022paused\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"SpaceWave","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://d5c0026b7bb56cba4d3ee53373da47725f5364b7a5b45ffdc45ccf05b13f3436"}]