[{"SourceCode":"pragma solidity ^0.4.24;\r\n\r\n// \u9632\u6B62\u6574\u6570\u6EA2\u51FA\r\nlibrary SafeMath {\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a * b;\r\n        assert(a == 0 || c / a == b);\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a / b;\r\n        return c;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        assert((c \u003E= a) \u0026\u0026 (c \u003E= b));\r\n        return c;\r\n    }\r\n}\r\n\r\n/*  \u6807\u51C6 token */\r\ncontract StandardToken {\r\n    using SafeMath for uint256;\r\n\r\n    string public name; // \u4EE3\u5E01\u540D\u79F0\r\n    string public symbol; // \u4EE3\u5E01\u7F29\u5199\r\n    uint8 public decimals; // \u5C0F\u6570\u4F4D\r\n    uint256 public totalSupply; // \u53D1\u884C\u91CF\r\n    string public version; // \u7248\u672C\r\n\r\n    /* \u5408\u7EA6\u884C\u4E3A */\r\n\r\n    // \u53D1\u8D77\u65B9(\u8C03\u7528\u8005)\u8F6C\u8D26 _value \u5230 address _to\r\n    function transfer(address _to, uint256 _value)  returns (bool success);\r\n\r\n    // \u4ECE _from \u8D26\u6237\u8F6C\u51FA _value \u6570\u91CF\u7684\u4EE3\u5E01\u5230 _to \u8D26\u6237\r\n    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) ;\r\n\r\n    // \u4EA4\u6613\u53D1\u8D77\u65B9\u628A _value \u6570\u91CF\u7684\u4EE3\u5E01\u4F7F\u7528\u6743\u4EA4\u7ED9 _spender, \u7531 _spender \u8C03\u7528 transferFrom \u5C06\u5E01\u8F6C\u7ED9\u53E6\u4E00\u4E2A\u8D26\u6237\r\n    function approve(address _spender, uint256 _value) returns (bool success);\r\n\r\n    // \u67E5\u8BE2 _spender \u76EE\u524D\u8FD8\u6709\u591A\u5C11 _owner \u8D26\u6237\u4EE3\u5E01\u4F7F\u7528\u6743\r\n    function allowance(address _owner, address _spender) constant returns (uint256 remaining) ;\r\n\r\n    // \u8F6C\u8D26\u6210\u529F\u4E8B\u4EF6\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n    // \u4F7F\u7528\u6743\u59D4\u6258\u6210\u529F\u4E8B\u4EF6\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n}\r\n\r\ncontract Owned {\r\n     modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n   address public owner;\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    address newOwner=0x0;\r\n\r\n    event OwnerUpdate(address _prevOwner, address _newOwner);\r\n\r\n    function changeOwner(address _newOwner) public onlyOwner {\r\n        require(_newOwner != owner);\r\n        newOwner = _newOwner;\r\n    }\r\n\r\n    function acceptOwnership() public{\r\n        require(msg.sender == newOwner);\r\n        emit OwnerUpdate(owner, newOwner);\r\n        owner = newOwner;\r\n        newOwner = 0x0;\r\n    }\r\n}\r\n\r\ncontract Controlled is Owned {\r\n    constructor() public {\r\n        setExclude(msg.sender,true);\r\n    }\r\n\r\n    bool public transferEnabled = true;\r\n\r\n    bool lockFlag=true;\r\n\r\n    mapping(address =\u003E bool) locked;\r\n\r\n    mapping(address =\u003E bool) exclude;\r\n\r\n    function enableTransfer(bool _enable) public onlyOwner returns (bool success){\r\n        transferEnabled=_enable;\r\n\t\treturn true;\r\n    }\r\n\r\n    function disableLock(bool _enable) public onlyOwner returns (bool success){\r\n        lockFlag=_enable;\r\n        return true;\r\n    }\r\n\r\n    function addLock(address _addr) public onlyOwner returns (bool success){\r\n        require(lockFlag == true);\r\n        require(_addr != msg.sender);\r\n        locked[_addr]=true;\r\n        return true;\r\n    }\r\n\r\n    function setExclude(address _addr,bool _enable) public onlyOwner returns (bool success){\r\n        exclude[_addr]=_enable;\r\n        return true;\r\n    }\r\n\r\n    function removeLock(address _addr) public onlyOwner returns (bool success){\r\n        locked[_addr]=false;\r\n        return true;\r\n    }\r\n\r\n    modifier transferAllowed(address _addr) {\r\n        if (!exclude[_addr]) {\r\n            require(transferEnabled,\u0022transfer is not enabeled now!\u0022);\r\n            if(lockFlag){\r\n                require(!locked[_addr],\u0022you are locked!\u0022);\r\n            }\r\n        }\r\n        _;\r\n    }\r\n}\r\n\r\ncontract DmToken is StandardToken,Controlled {\r\n\tmapping (address =\u003E uint256) public balanceOf;\r\n\tmapping (address =\u003E mapping (address =\u003E uint256)) internal allowed;\r\n\r\n    constructor() public {\r\n        totalSupply = 3000000 * 100000000;\r\n        name = \u0022Test Coin\u0022;\r\n        symbol = \u0022TEST\u0022;\r\n        decimals = 8;\r\n        version = \u00221.0\u0022;\r\n        balanceOf[msg.sender] = totalSupply;\r\n    }\r\n\r\n    function transfer(address _to, uint256 _value) public transferAllowed(msg.sender) returns (bool success) {\r\n\t\trequire(_to != address(0));\r\n\t\trequire(_value \u003C= balanceOf[msg.sender]);\r\n\r\n        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);\r\n        balanceOf[_to] = balanceOf[_to].add(_value);\r\n        emit Transfer(msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) public transferAllowed(_from) returns (bool success) {\r\n        require(_to != address(0));\r\n        require(_value \u003C= balanceOf[_from]);\r\n        require(_value \u003C= allowed[_from][msg.sender]);\r\n\r\n        balanceOf[_from] = balanceOf[_from].sub(_value);\r\n        balanceOf[_to] = balanceOf[_to].add(_value);\r\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n        emit Transfer(_from, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    function approve(address _spender, uint256 _value) public returns (bool success) {\r\n        allowed[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022removeLock\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022transferEnabled\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022version\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addLock\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_enable\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022disableLock\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_enable\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setExclude\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022changeOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_enable\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022enableTransfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_prevOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnerUpdate\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"DmToken","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://98ac40b47bf1c4b6e8c526cfaeb51e9715a455fac9dc1d3fcba090e30547fc0f"}]