[{"SourceCode":"pragma solidity ^0.4.20;\r\n\r\nlibrary SafeMath {\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a * b;\r\n    assert(a == 0 || c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a / b;\r\n    return c;\r\n  }\r\n\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n}\r\n\r\ncontract ERC20Basic {\r\n    uint256 public totalSupply;\r\n    function balanceOf(address who) public constant returns (uint256);\r\n    function transfer(address to, uint256 value) public returns (bool);\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n\r\ncontract ERC20 is ERC20Basic {\r\n    function allowance(address owner, address spender) public constant returns (uint256);\r\n    function transferFrom(address from, address to, uint256 value) public returns (bool);\r\n    function approve(address spender, uint256 value) public returns (bool);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\ncontract FANCO is ERC20 {\r\n    \r\n    using SafeMath for uint256; \r\n    address owner = msg.sender; \r\n\t\r\n    mapping (address =\u003E uint256) balances; \r\n    mapping (address =\u003E mapping (address =\u003E uint256)) allowed;\r\n\r\n    mapping (address =\u003E uint256) times;\r\n\r\n    mapping (address =\u003E mapping (uint256 =\u003E uint256)) lockdata;\r\n    mapping (address =\u003E mapping (uint256 =\u003E uint256)) locktime;\r\n    mapping (address =\u003E mapping (uint256 =\u003E uint256)) lockday;\r\n    mapping (address =\u003E mapping (uint256 =\u003E uint256)) frozenday;\r\n    \r\n\r\n    string public constant name = \u0022FANCO\u0022;\r\n    string public constant symbol = \u0022FANCO\u0022;\r\n    uint public constant decimals = 3;\r\n    uint256 _Rate = 10 ** decimals; \r\n    uint256 public totalSupply = 5000000000 * _Rate;\r\n\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n\r\n\r\n\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n    modifier onlyPayloadSize(uint size) {\r\n        assert(msg.data.length \u003E= size \u002B 4);\r\n        _;\r\n    }\r\n\r\n     function FANCO() public {\r\n        owner = msg.sender;\r\n        balances[owner] = totalSupply;\r\n    }\r\n    \r\n     function nowInSeconds() public view returns (uint256){\r\n        return now;\r\n    }\r\n    \r\n    function transferOwnership(address newOwner) onlyOwner public {\r\n        if (newOwner != address(0) \u0026\u0026 newOwner != owner) {          \r\n             owner = newOwner;   \r\n        }\r\n    }\r\n\r\n    function locked(address _to,uint256 _frozenmonth, uint256 _month, uint256 _amount) private {\r\n\t\tuint lockmon;\r\n        uint frozenmon;\r\n        lockmon = _month * 30 * 1 days;\r\n        frozenmon =  _frozenmonth * 30 * 1 days;\r\n\t\ttimes[_to] \u002B= 1;\r\n        locktime[_to][times[_to]] = now;\r\n        lockday[_to][times[_to]] = lockmon;\r\n        lockdata[_to][times[_to]] = _amount;\r\n        frozenday[_to][times[_to]] = frozenmon;\r\n        \r\n        balances[msg.sender] = balances[msg.sender].sub(_amount);\r\n        balances[_to] = balances[_to].add(_amount);\r\n    }\r\n\r\n\r\n    function balanceOf(address _owner) constant public returns (uint256) {\r\n\t    return balances[_owner];\r\n    }\r\n\r\n    function lockOf(address _owner) constant public returns (uint256) {\r\n    uint locknum = 0;\r\n    uint unlocknum;\r\n    \r\n    for (uint8 i = 1; i \u003C times[_owner] \u002B 1; i\u002B\u002B){\r\n        if(frozenday[_owner][i]==0){\r\n            unlocknum = 30* 1 days;\r\n        }\r\n        else{\r\n            unlocknum = 1* 1 days;\r\n        }\r\n        if(now \u003C locktime[_owner][i] \u002B frozenday[_owner][i] \u002B unlocknum){\r\n            locknum \u002B= lockdata[_owner][i];\r\n        }\r\n        else{\r\n            if(now \u003C locktime[_owner][i] \u002B lockday[_owner][i] \u002B frozenday[_owner][i] \u002B 1* 1 days){\r\n\t\t\t\tuint lockmon = lockday[_owner][i].div(unlocknum);\r\n\t\t\t\tuint locknow = (now - locktime[_owner][i] - frozenday[_owner][i]).div(unlocknum);\r\n                locknum \u002B= ((lockmon-locknow).mul(lockdata[_owner][i])).div(lockmon);\r\n              }\r\n              else{\r\n                 locknum \u002B= 0;\r\n              }\r\n        }\r\n    }\r\n\r\n\r\n\t    return locknum;\r\n    }\r\n\r\n    function locktransfer(address _to, uint256 _month,uint256 _point) onlyOwner onlyPayloadSize(2 * 32) public returns (bool success) {\r\n        require( _point\u003E= 0 \u0026\u0026 _point\u003C= 10000);\r\n        uint256 amount; \r\n        amount = (totalSupply.div(10000)).mul( _point);\r\n        \r\n        require(_to != address(0));\r\n        require(amount \u003C= (balances[msg.sender].sub(lockOf(msg.sender))));\r\n        uint256 _frozenmonth = 0;              \r\n        locked(_to,_frozenmonth, _month, amount);\r\n        \r\n        Transfer(msg.sender, _to, amount);\r\n        return true;\r\n    }\r\n    \r\n        function frozentransfer(address _to,uint256 _frozenmonth, uint256 _month,uint256 _point) onlyOwner onlyPayloadSize(2 * 32) public returns (bool success) {\r\n        require( _point\u003E= 0 \u0026\u0026 _point\u003C= 10000);\r\n        require( _frozenmonth\u003E 0);\r\n        uint256 amount; \r\n        amount = (totalSupply.div(10000)).mul( _point);\r\n        \r\n        require(_to != address(0));\r\n        require(amount \u003C= (balances[msg.sender].sub(lockOf(msg.sender))));\r\n                      \r\n        locked(_to,_frozenmonth, _month, amount);\r\n        \r\n        Transfer(msg.sender, _to, amount);\r\n        return true;\r\n    }\r\n\r\n    function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) public returns (bool success) {\r\n\r\n        require(_to != address(0));\r\n        require(_amount \u003C= (balances[msg.sender].sub(lockOf(msg.sender))));\r\n                      \r\n        balances[msg.sender] = balances[msg.sender].sub(_amount);\r\n        balances[_to] = balances[_to].add(_amount);\r\n\t\t\r\n        Transfer(msg.sender, _to, _amount);\r\n        return true;\r\n    }\r\n  \r\n    function transferFrom(address _from, address _to, uint256 _amount) onlyPayloadSize(3 * 32) public returns (bool success) {\r\n\r\n        require(_to != address(0));\r\n        require(_amount \u003C= balances[_from]);\r\n        require(_amount \u003C= balances[_from].sub(lockOf(msg.sender)));\r\n        require(_amount \u003C= allowed[_from][msg.sender]);\r\n\r\n        \r\n        balances[_from] = balances[_from].sub(_amount);\r\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);\r\n        balances[_to] = balances[_to].add(_amount);\r\n        Transfer(_from, _to, _amount);\r\n        return true;\r\n    }\r\n\r\n    function approve(address _spender, uint256 _value) public returns (bool success) {\r\n        if (_value != 0 \u0026\u0026 allowed[msg.sender][_spender] != 0) { return false; }\r\n        allowed[msg.sender][_spender] = _value;\r\n        Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address _owner, address _spender) constant public returns (uint256) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n\r\n    function withdraw() onlyOwner public {\r\n        uint256 etherBalance = this.balance;\r\n        address theowner = msg.sender;\r\n        theowner.transfer(etherBalance);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022lockOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022nowInSeconds\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_frozenmonth\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_month\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_point\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022frozentransfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_month\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_point\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022locktransfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"FANCO","CompilerVersion":"v0.4.20\u002Bcommit.3155dd80","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://1a740f253efd2cf4c3f2119bc19130a94d2759a6e03c23e834f930b55eba2e46"}]