[{"SourceCode":"/**\r\n *Submitted for verification at Etherscan.io on 2018-06-22\r\n*/\r\n\r\npragma solidity ^0.4.18;\r\n\r\nlibrary SafeMath {\r\n\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n    uint256 c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return c;\r\n  }\r\n\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n}\r\n\r\n\r\ncontract Ownable {\r\n  address public owner;\r\n\r\n\r\n  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n  function Ownable() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  function transferOwnership(address newOwner) public onlyOwner {\r\n    require(newOwner != address(0));\r\n    OwnershipTransferred(owner, newOwner);\r\n    owner = newOwner;\r\n  }\r\n\r\n}\r\n\r\ncontract Pausable is Ownable {\r\n  event Pause();\r\n  event Unpause();\r\n\r\n  bool public paused = false;\r\n\r\n  modifier whenNotPaused() {\r\n    require(!paused);\r\n    _;\r\n  }\r\n\r\n  modifier whenPaused() {\r\n    require(paused);\r\n    _;\r\n  }\r\n\r\n  function pause() onlyOwner whenNotPaused public {\r\n    paused = true;\r\n    Pause();\r\n  }\r\n\r\n  function unpause() onlyOwner whenPaused public {\r\n    paused = false;\r\n    Unpause();\r\n  }\r\n}\r\n\r\n\r\n\r\ncontract ERC20 {\r\n    function totalSupply() public view returns (uint256);\r\n    function balanceOf(address who) public view returns (uint256);\r\n    function allowance(address owner, address spender) public view returns (uint256);\r\n    function transfer(address to, uint256 value) public returns (bool);\r\n    function transferFrom(address from, address to, uint256 value) public returns (bool);\r\n    function approve(address spender, uint256 value) public returns (bool);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n\r\ncontract FooPay is ERC20, Ownable, Pausable {\r\n    using SafeMath for uint256;\r\n    string public name;\r\n    string public symbol;\r\n    uint8 public decimals;\r\n    uint256 initialSupply;\r\n    uint256 totalSupply_;\r\n\r\n    mapping(address =\u003E uint256) balances;\r\n    mapping(address =\u003E bool) internal locks;\r\n    mapping(address =\u003E mapping(address =\u003E uint256)) internal allowed;\r\n\r\n    constructor() public {\r\n        name = \u0022FooPay\u0022;\r\n        symbol = \u0022FOO\u0022;\r\n        decimals = 8;\r\n        initialSupply = 3000000000;\r\n        totalSupply_ = initialSupply * 10 ** uint(decimals);\r\n        balances[owner] = totalSupply_;\r\n        Transfer(address(0), owner, totalSupply_);\r\n    }\r\n\r\n    function totalSupply() public view returns (uint256) {\r\n        return totalSupply_;\r\n    }\r\n\r\n    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {\r\n        require(_to != address(0));\r\n        require(_value \u003C= balances[msg.sender]);\r\n        require(locks[msg.sender] == false);\r\n\r\n        // SafeMath.sub will throw if there is not enough balance.\r\n        balances[msg.sender] = balances[msg.sender].sub(_value);\r\n        balances[_to] = balances[_to].add(_value);\r\n        Transfer(msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    function balanceOf(address _owner) public view returns (uint256 balance) {\r\n        return balances[_owner];\r\n    }\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {\r\n        require(_to != address(0));\r\n        require(_value \u003C= balances[_from]);\r\n        require(_value \u003C= allowed[_from][msg.sender]);\r\n        require(locks[_from] == false);\r\n\r\n        balances[_from] = balances[_from].sub(_value);\r\n        balances[_to] = balances[_to].add(_value);\r\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n        Transfer(_from, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {\r\n        require(_value \u003E 0);\r\n        allowed[msg.sender][_spender] = _value;\r\n        Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address _owner, address _spender) public view returns (uint256) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n\r\n    function burn(uint256 _value) public onlyOwner returns (bool success) {\r\n        require(_value \u003C= balances[msg.sender]);\r\n        address burner = msg.sender;\r\n        balances[burner] = balances[burner].sub(_value);\r\n        totalSupply_ = totalSupply_.sub(_value);\r\n        return true;\r\n    }\r\n\r\n    function lock(address _owner) public onlyOwner returns (bool) {\r\n        require(locks[_owner] == false);\r\n        locks[_owner] = true;\r\n        return true;\r\n    }\r\n\r\n    function unlock(address _owner) public onlyOwner returns (bool) {\r\n        require(locks[_owner] == true);\r\n        locks[_owner] = false;\r\n        return true;\r\n    }\r\n\r\n    function showLockState(address _owner) public view returns (bool) {\r\n        return locks[_owner];\r\n    }\r\n\r\n    function () public payable {\r\n        revert();\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022unlock\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022showLockState\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022lock\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Pause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Unpause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"FooPay","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://11aa58c1b71468b87bd79cb2b49294ea9758b57e7eacff6c5bd3aa5f8a15a614"}]