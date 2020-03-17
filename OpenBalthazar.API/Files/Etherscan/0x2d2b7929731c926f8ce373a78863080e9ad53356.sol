[{"SourceCode":"pragma solidity 0.4.21;\r\n\r\n\r\n// ---------------------------------------------------------------------\r\n// ERC-20 Token Standard Interface\r\n// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md\r\n// ---------------------------------------------------------------------\r\ncontract ERC20Interface {\r\n  /**\r\n  Returns the name of the token - e.g. \u0022MyToken\u0022\r\n   */\r\n  string public name;\r\n  /**\r\n  Returns the symbol of the token. E.g. \u0022HIX\u0022.\r\n   */\r\n  string public symbol;\r\n  /**\r\n  Returns the number of decimals the token uses - e. g. 8\r\n   */\r\n  uint8 public decimals;\r\n  /**\r\n  Returns the total token supply.\r\n   */\r\n  uint256 public totalSupply;\r\n  /**\r\n  Returns the account balance of another account with address _owner.\r\n   */\r\n  function balanceOf(address _owner) public view returns (uint256 balance);\r\n  /**\r\n  Transfers _value amount of tokens to address _to, and MUST fire the Transfer event. \r\n  The function SHOULD throw if the _from account balance does not have enough tokens to spend.\r\n   */\r\n  function transfer(address _to, uint256 _value) public returns (bool success);\r\n  /**\r\n  Transfers _value amount of tokens from address _from to address _to, and MUST fire the Transfer event.\r\n   */\r\n  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);\r\n  /**\r\n  Allows _spender to withdraw from your account multiple times, up to the _value amount. \r\n  If this function is called again it overwrites the current allowance with _value.\r\n   */\r\n  function approve(address _spender, uint256 _value) public returns (bool success);\r\n  /**\r\n  Returns the amount which _spender is still allowed to withdraw from _owner.\r\n   */\r\n  function allowance(address _owner, address _spender) public view returns (uint256 remaining);\r\n  /**\r\n  MUST trigger when tokens are transferred, including zero value transfers.\r\n   */\r\n  event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n  /**\r\n  MUST trigger on any successful call to approve(address _spender, uint256 _value).\r\n    */\r\n  event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n}\r\n\r\n/**\r\nOwned contract\r\n */\r\ncontract Owned {\r\n  address public owner;\r\n  address public newOwner;\r\n\r\n  event OwnershipTransferred(address indexed _from, address indexed _to);\r\n\r\n  function Owned() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  modifier onlyOwner {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  function transferOwnership(address _newOwner) public onlyOwner {\r\n    newOwner = _newOwner;\r\n  }\r\n\r\n  function acceptOwnership() public {\r\n    require(msg.sender == newOwner);\r\n    emit OwnershipTransferred(owner, newOwner);\r\n    owner = newOwner;\r\n    newOwner = address(0);\r\n  }\r\n}\r\n\r\n/**\r\nFunction to receive approval and execute function in one call.\r\n */\r\ncontract TokenRecipient { \r\n  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; \r\n}\r\n\r\n/**\r\nToken implement\r\n */\r\ncontract Token is ERC20Interface, Owned {\r\n\r\n  mapping (address =\u003E uint256) public balances;\r\n  mapping (address =\u003E mapping (address =\u003E uint256)) public allowed;\r\n  \r\n  // This notifies clients about the amount burnt\r\n  event Burn(address indexed from, uint256 value);\r\n  \r\n  function balanceOf(address _owner) public view returns (uint256 balance) {\r\n    return balances[_owner];\r\n  }\r\n\r\n  function transfer(address _to, uint256 _value) public returns (bool success) {\r\n    _transfer(msg.sender, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {\r\n    require(_value \u003C= allowed[_from][msg.sender]); \r\n    allowed[_from][msg.sender] -= _value;\r\n    _transfer(_from, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  function approve(address _spender, uint256 _value) public returns (bool success) {\r\n    allowed[msg.sender][_spender] = _value;\r\n    emit Approval(msg.sender, _spender, _value);\r\n    return true;\r\n  }\r\n\r\n  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {\r\n    return allowed[_owner][_spender];\r\n  }\r\n\r\n  \r\n  /**\r\n  Approves and then calls the receiving contract\r\n   */\r\n  function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {\r\n    TokenRecipient spender = TokenRecipient(_spender);\r\n    approve(_spender, _value);\r\n    spender.receiveApproval(msg.sender, _value, this, _extraData);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n  Destroy tokens.\r\n  Remove \u0060_value\u0060 tokens from the system irreversibly\r\n    */\r\n  function burn(uint256 _value) public returns (bool success) {\r\n    require(balances[msg.sender] \u003E= _value);\r\n    balances[msg.sender] -= _value;\r\n    totalSupply -= _value;\r\n    emit Burn(msg.sender, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n  Destroy tokens from other account.\r\n  Remove \u0060_value\u0060 tokens from the system irreversibly on behalf of \u0060_from\u0060.\r\n    */\r\n  function burnFrom(address _from, uint256 _value) public returns (bool success) {\r\n    require(balances[_from] \u003E= _value);\r\n    require(_value \u003C= allowed[_from][msg.sender]);\r\n    balances[_from] -= _value;\r\n    allowed[_from][msg.sender] -= _value;\r\n    totalSupply -= _value;\r\n    emit Burn(_from, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n  Internal transfer, only can be called by this contract\r\n    */\r\n  function _transfer(address _from, address _to, uint _value) internal {\r\n    // Prevent transfer to 0x0 address. Use burn() instead\r\n    require(_to != 0x0);\r\n    // Check if the sender has enough\r\n    require(balances[_from] \u003E= _value);\r\n    // Check for overflows\r\n    require(balances[_to] \u002B _value \u003E balances[_to]);\r\n    // Save this for an assertion in the future\r\n    uint previousBalances = balances[_from] \u002B balances[_to];\r\n    // Subtract from the sender\r\n    balances[_from] -= _value;\r\n    // Add the same to the recipient\r\n    balances[_to] \u002B= _value;\r\n    emit Transfer(_from, _to, _value);\r\n    // Asserts are used to use static analysis to find bugs in your code. They should never fail\r\n    assert(balances[_from] \u002B balances[_to] == previousBalances);\r\n  }\r\n\r\n}\r\n\r\ncontract BEECOIN is Token {\r\n\r\n  function BEECOIN() public {\r\n    name = \u0022Bee Coin\u0022;\r\n    symbol = \u0022BEECOIN\u0022;\r\n    decimals = 0;\r\n    totalSupply = 1000000000;\r\n    balances[msg.sender] = totalSupply;\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balances\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burnFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_extraData\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022approveAndCall\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022newOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"BEECOIN","CompilerVersion":"v0.4.21\u002Bcommit.dfe3193c","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://4b661501e50df0129ce59addd4eda7d0e033ab06efd4070e60a07928a1e6dac0"}]