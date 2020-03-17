[{"SourceCode":"pragma solidity ^0.4.26;\r\n\r\ncontract SafeMath {\r\n    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a * b;\r\n        _assert(a == 0 || c / a == b);\r\n        return c;\r\n    }\r\n\r\n    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        _assert(b \u003E 0);\r\n        uint256 c = a / b;\r\n        _assert(a == b * c \u002B a % b);\r\n        return c;\r\n    }\r\n\r\n    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        _assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        _assert(c \u003E= a \u0026\u0026 c \u003E= b);\r\n        return c;\r\n    }\r\n\r\n    function _assert(bool assertion) internal pure {\r\n        if (!assertion) {\r\n            revert();\r\n        }\r\n    }\r\n}\r\n\r\ncontract Owned {\r\n    address public owner;\r\n    address public newOwner;\r\n\r\n    event OwnershipTransferred(address indexed _from, address indexed _to);\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    modifier onlyOwner {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n    function transferOwnership(address _newOwner) public onlyOwner {\r\n        newOwner = _newOwner;\r\n    }\r\n    function acceptOwnership() public {\r\n        require(msg.sender == newOwner);\r\n        emit OwnershipTransferred(owner, newOwner);\r\n        owner = newOwner;\r\n        newOwner = address(0);\r\n    }\r\n}\r\n\r\ncontract KobeBadge is SafeMath,Owned {\r\n    string public name = \u0022Kobe Badge\u0022;\r\n    string public symbol = \u0022KOBE\u0022;\r\n    uint8 constant public decimals = 18;\r\n    mapping(address =\u003E uint256)  _balances;\r\n    mapping(address =\u003E mapping(address =\u003E uint256)) public _allowed;\r\n\r\n    uint256  public totalSupply = 100000000000 * 10**uint(decimals);\r\n\r\n\r\n    constructor () public{\r\n        _balances[msg.sender] = totalSupply;\r\n        emit Transfer(0x0, msg.sender, totalSupply);\r\n    }\r\n\r\n    function balanceOf(address addr) public view returns (uint256) {\r\n        return _balances[addr];\r\n    }\r\n\r\n\r\n    function transfer(address _to, uint256 _value)  public returns (bool) {\r\n        if (_to == address(0)) {\r\n            return burn(_value);\r\n        } else {\r\n            require(_balances[msg.sender] \u003E= _value \u0026\u0026 _value \u003E 0);\r\n            require(_balances[_to] \u002B _value \u003E= _balances[_to]);\r\n\r\n            _balances[msg.sender] = safeSub(_balances[msg.sender], _value);\r\n            _balances[_to] = safeAdd(_balances[_to], _value);\r\n            emit Transfer(msg.sender, _to, _value);\r\n            return true;\r\n        }\r\n    }\r\n\r\n    function burn(uint256 _value) public returns (bool) {\r\n        require(_balances[msg.sender] \u003E= _value \u0026\u0026 _value \u003E 0);\r\n        require(totalSupply \u003E= _value);\r\n        _balances[msg.sender] = safeSub(_balances[msg.sender], _value);\r\n        totalSupply = safeSub(totalSupply, _value);\r\n        emit Burn(msg.sender, _value);\r\n        return true;\r\n    }\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value)  public returns (bool) {\r\n        require(_to != address(0));\r\n        require(_balances[_from] \u003E= _value \u0026\u0026 _value \u003E 0);\r\n        require(_balances[_to] \u002B _value \u003E= _balances[_to]);\r\n\r\n        require(_allowed[_from][msg.sender] \u003E= _value);\r\n\r\n        _balances[_to] = safeAdd(_balances[_to], _value);\r\n        _balances[_from] = safeSub(_balances[_from], _value);\r\n        _allowed[_from][msg.sender] = safeSub(_allowed[_from][msg.sender], _value);\r\n        emit Transfer(_from, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    function approve(address spender, uint256 value)  public returns (bool) {\r\n        require(spender != address(0));\r\n        _allowed[msg.sender][spender] = value;\r\n        emit Approval(msg.sender, spender, value);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address _master, address _spender) public view returns (uint256) {\r\n        return _allowed[_master][_spender];\r\n    }\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n    event Transfer(address indexed _from, address indexed _to, uint256 value);\r\n    event Burn(address indexed _from, uint256 value);\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022_allowed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022newOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_master\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"KobeBadge","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://90f0f1373dd1c2c38c7422c0729b9b8d252d557d2f12277b4891257c5f6b8f4f"}]