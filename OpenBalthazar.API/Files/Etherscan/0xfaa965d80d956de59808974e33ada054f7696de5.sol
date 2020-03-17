[{"SourceCode":"pragma solidity ^0.5.6;\r\n\r\nlibrary SafeMath {\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n        c = a * b;\r\n        assert(c / a == b);\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b != 0);\r\n        return a / b;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n}\r\n\r\ncontract Ownable {\r\n    address public owner;\r\n    address public authorizedCaller;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n        authorizedCaller = msg.sender;\r\n    }\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n    modifier onlyAuthorized() {\r\n        require(msg.sender == owner || msg.sender == authorizedCaller);\r\n        _;\r\n    }\r\n    function transferAuthorizedCaller(address _newAuthorizedCaller) public onlyOwner {\r\n        require(_newAuthorizedCaller != address(0));\r\n        authorizedCaller = _newAuthorizedCaller;\r\n    }\r\n\r\n    function transferOwnership(address _newOwner) public onlyOwner {\r\n        require(_newOwner != address(0));\r\n        emit OwnershipTransferred(owner, _newOwner);\r\n        owner = _newOwner;\r\n    }\r\n}\r\n\r\ncontract ERC20 {\r\n    function totalSupply() public view returns (uint256);\r\n\r\n    function balanceOf(address _tokenOwner) public view returns (uint);\r\n\r\n    function transfer(address _to, uint _amount) public returns (bool);\r\n\r\n    function transferFrom(address _from, address _to, uint _amount) public returns (bool);\r\n\r\n    function allowance(address _tokenOwner, address _spender) public view returns (uint);\r\n\r\n    function approve(address _spender, uint _amount) public returns (bool);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint tokens);\r\n    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);\r\n}\r\n\r\ncontract BTourToken is ERC20, Ownable {\r\n    using SafeMath for uint256;\r\n\r\n    uint8 public constant decimals = 18;\r\n    uint256 public constant _totalSupply = 2 * (10 ** 9) * (10 ** uint256(decimals));\r\n    string public constant name = \u0022BTour Chain\u0022;\r\n    string public constant symbol = \u0022BTOUR\u0022;\r\n\r\n    bool public isPayable = true;\r\n    bool public isHalted = false;\r\n\r\n    mapping(address =\u003E uint256) internal balances;\r\n    mapping(address =\u003E mapping(address =\u003E uint256)) internal allowed;\r\n    mapping(address =\u003E bool) public locked;\r\n\r\n    constructor() public {\r\n        balances[msg.sender] = _totalSupply;\r\n    }\r\n\r\n    modifier checkHalted() {\r\n        require(isHalted == false);\r\n        _;\r\n    }\r\n\r\n    function() external payable {\r\n        if (isPayable == false || isHalted == true) {\r\n            revert();\r\n        }\r\n    }\r\n\r\n    function totalSupply() public view returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    function sendFeeCurrency(address payable _receiver, uint256 _amount) external payable onlyAuthorized returns (bool) {\r\n        if (isPayable == false) {\r\n            revert();\r\n        }\r\n\r\n        _receiver.transfer(_amount);\r\n        return true;\r\n    }\r\n\r\n    function setIsPayable(bool p) external onlyAuthorized {\r\n        isPayable = p;\r\n    }\r\n\r\n    function setHalted(bool _isHalted) external onlyOwner {\r\n        isHalted = _isHalted;\r\n    }\r\n\r\n    function setLock(address _addr, bool _lock) external onlyAuthorized {\r\n        locked[_addr] = _lock;\r\n    }\r\n\r\n    function balanceOf(address _tokenOwner) public view returns (uint) {\r\n        return balances[_tokenOwner];\r\n    }\r\n\r\n    function transfer(address _to, uint _amount) public checkHalted returns (bool) {\r\n        if (msg.sender != owner) {\r\n            require(locked[msg.sender] == false \u0026\u0026 locked[_to] == false);\r\n        }\r\n        balances[msg.sender] = balances[msg.sender].sub(_amount);\r\n        balances[_to] = balances[_to].add(_amount);\r\n        emit Transfer(msg.sender, _to, _amount);\r\n        return true;\r\n    }\r\n\r\n    function transferFrom(address _from, address _to, uint _amount) public checkHalted returns (bool) {\r\n        if (msg.sender != owner) {\r\n            require(locked[msg.sender] == false \u0026\u0026 locked[_from] == false \u0026\u0026 locked[_to] == false);\r\n        }\r\n        require(_amount \u003C= balances[_from]);\r\n        if (_from != msg.sender) {\r\n            require(_amount \u003C= allowed[_from][msg.sender]);\r\n            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);\r\n        }\r\n        balances[_from] = balances[_from].sub(_amount);\r\n        balances[_to] = balances[_to].add(_amount);\r\n        emit Transfer(_from, _to, _amount);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address _tokenOwner, address _spender) public view returns (uint) {\r\n        return allowed[_tokenOwner][_spender];\r\n    }\r\n\r\n    function approve(address _spender, uint _amount) public checkHalted returns (bool) {\r\n        require(locked[_spender] == false \u0026\u0026 locked[msg.sender] == false);\r\n\r\n        allowed[msg.sender][_spender] = _amount;\r\n        emit Approval(msg.sender, _spender, _amount);\r\n        return true;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022sendFeeCurrency\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022authorizedCaller\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_lock\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setLock\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isHalted\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022locked\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isPayable\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_isHalted\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setHalted\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newAuthorizedCaller\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferAuthorizedCaller\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022p\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setIsPayable\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"BTourToken","CompilerVersion":"v0.5.6\u002Bcommit.b259423e","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://7af4b096634a665868d0c94b8b111f6f7b24a41264468ad939bda8834d28fd6e"}]