[{"SourceCode":"pragma solidity 0.4.26;\r\n\r\nlibrary SafeMath {\r\n\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n        c = a * b;\r\n        assert(c / a == b);\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n        // uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n        return a / b;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n}\r\n\r\ncontract ERC20Basic {\r\n    function totalSupply() public view returns (uint256);\r\n    function balanceOf(address who) public view returns (uint256);\r\n    function transfer(address to, uint256 value) public returns (bool);\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n\r\ncontract ERC20 is ERC20Basic {\r\n    function allowance(address owner, address spender) public view returns (uint256);\r\n    function transferFrom(address from, address to, uint256 value) public returns (bool);\r\n    function approve(address spender, uint256 value) public returns (bool);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\ncontract BasicToken is ERC20Basic {\r\n    using SafeMath for uint256;\r\n\r\n    mapping(address =\u003E uint256) balances;\r\n\r\n    uint256 totalSupply_;\r\n\r\n    function totalSupply() public view returns (uint256) {\r\n        return totalSupply_;\r\n    }\r\n\r\n    function transfer(address _to, uint256 _value) public returns (bool) {\r\n        require(_to != address(0));\r\n        require(_value \u003C= balances[msg.sender]);\r\n\r\n        balances[msg.sender] = balances[msg.sender].sub(_value);\r\n        balances[_to] = balances[_to].add(_value);\r\n        emit Transfer(msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    function balanceOf(address _owner) public view returns (uint256) {\r\n        return balances[_owner];\r\n    }\r\n\r\n}\r\n\r\ncontract StandardToken is ERC20, BasicToken {\r\n\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) internal allowed;\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {\r\n        require(_to != address(0));\r\n        require(_value \u003C= balances[_from]);\r\n        require(_value \u003C= allowed[_from][msg.sender]);\r\n\r\n        balances[_from] = balances[_from].sub(_value);\r\n        balances[_to] = balances[_to].add(_value);\r\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n        emit Transfer(_from, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    function approve(address _spender, uint256 _value) public returns (bool) {\r\n        allowed[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address _owner, address _spender) public view returns (uint256) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n\r\n    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {\r\n        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);\r\n        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n        return true;\r\n    }\r\n\r\n    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {\r\n        uint oldValue = allowed[msg.sender][_spender];\r\n        if (_subtractedValue \u003E oldValue) {\r\n            allowed[msg.sender][_spender] = 0;\r\n        } else {\r\n            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\r\n        }\r\n        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n        return true;\r\n    }\r\n\r\n}\r\n\r\ncontract HBIF is StandardToken {\r\n    // \u57FA\u672C\u4FE1\u606F\r\n    string public constant name = \u0022HBIF\u0022;\r\n    string public constant symbol = \u0022HBIF\u0022;\r\n    uint256 public INITIAL_SUPPLY = 1000000000000000;\r\n    uint8 public constant decimals = 8;\r\n\r\n    // \u51BB\u7ED3\r\n    mapping(address =\u003E bool) private frozenAccount;\r\n    mapping(address =\u003E uint256) private frozenTimestamp;\r\n\r\n    // \u5408\u7EA6\u6240\u6709\u8005\r\n    address public owner;\r\n\r\n    // \u5355\u4E2A\u6D88\u606F\u7ED3\u6784\u4F53\r\n    struct Msg {\r\n        uint256 timestamp;\r\n        address sender;\r\n        string content;\r\n    }\r\n\r\n    // \u8BB0\u5F55\u53D1\u9001\u6D88\u606F\r\n    Msg[] private msgs;\r\n\r\n    mapping(uint =\u003E address) public msgToOwner;\r\n    mapping(address =\u003E uint) ownerMsgCount;\r\n\r\n    // \u4E8B\u4EF6\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n    event SendMsgEvent(address indexed _from, string _content);\r\n\r\n    // \u6784\u9020\u51FD\u6570, \u4E0D\u9700\u8981\u53C2\u6570\r\n    constructor() public {\r\n        totalSupply_ = INITIAL_SUPPLY; // 5\u0027000\u0027000\r\n        balances[0x537b569f39EfB56a7D1512e7e19185bA2C360e64] = INITIAL_SUPPLY; // 5\u0027000\u0027000\r\n        owner = 0x537b569f39EfB56a7D1512e7e19185bA2C360e64; //\r\n        emit Transfer(address(0),owner,totalSupply_);\r\n    }\r\n\r\n    // \u6807\u51C6\u4FEE\u6539\u5668, \u4EC5\u6240\u6709\u8005\u53EF\u8C03\u7528\r\n    modifier onlyOwner {\r\n        require(msg.sender == owner, \u0022onlyOwner method called by non-owner.\u0022);\r\n        _;\r\n    }\r\n\r\n    // \u589E\u52A0\u4EE3\u5E01\r\n    function increaseToken(address _target, uint256 _amount) external onlyOwner returns (bool) {\r\n        require(_target != address(0));\r\n        require(_amount \u003E 0);\r\n        balances[_target] = balances[_target].add(_amount);\r\n        totalSupply_ = totalSupply_.add(_amount);\r\n        INITIAL_SUPPLY = totalSupply_;\r\n        return true;\r\n    }\r\n\r\n    // \u51CF\u5C11\u4EE3\u5E01\r\n    function decreaseToken(address _target, uint256 _amount) external onlyOwner returns (bool) {\r\n        require(_target != address(0));\r\n        require(_amount \u003E 0);\r\n        balances[_target] = balances[_target].sub(_amount);\r\n        totalSupply_ = totalSupply_.sub(_amount);\r\n        INITIAL_SUPPLY = totalSupply_;\r\n        return true;\r\n    }\r\n\r\n    // \u51BB\u7ED3\u5E10\u6237\r\n    function freeze(address _target, bool _freeze) external onlyOwner returns (bool) {\r\n        require(_target != address(0));\r\n        frozenAccount[_target] = _freeze;\r\n        return true;\r\n    }\r\n\r\n    // \u51BB\u7ED3\u5E10\u6237\r\n    function freezeByTimestamp(address _target, uint256 _timestamp) external onlyOwner returns (bool) {\r\n        require(_target != address(0));\r\n        frozenTimestamp[_target] = _timestamp;\r\n        return true;\r\n    }\r\n\r\n    // \u67E5\u8BE2\u51BB\u7ED3\u5E10\u6237\u7ED3\u675F\u65F6\u95F4\r\n    function getFrozenTimestamp(address _target) external onlyOwner view returns (uint256) {\r\n        require(_target != address(0));\r\n        return frozenTimestamp[_target];\r\n    }\r\n\r\n    // \u8F6C\u5E10\r\n    function transfer(address _to, uint256 _amount) public returns (bool) {\r\n        require(_to != address(0));\r\n        require(frozenAccount[msg.sender] != true);\r\n        require(frozenTimestamp[msg.sender] \u003C now);\r\n        require(balances[msg.sender] \u003E= _amount);\r\n\r\n        balances[msg.sender] = balances[msg.sender].sub(_amount);\r\n        balances[_to] = balances[_to].add(_amount);\r\n\r\n        emit Transfer(msg.sender, _to, _amount);\r\n        return true;\r\n    }\r\n\r\n    // \u4ECE\u67D0\u5730\u5740\u8F6C\u5E10\r\n    function transferByOwner(address _from, address _to, uint256 _amount) external onlyOwner returns (bool) {\r\n        require(_from != address(0));\r\n        require(_to != address(0));\r\n        require(balances[_from] \u003E= _amount);\r\n\r\n        balances[_from] = balances[_from].sub(_amount);\r\n        balances[_to] = balances[_to].add(_amount);\r\n\r\n        emit Transfer(_from, _to, _amount);\r\n        return true;\r\n    }\r\n\r\n    // \u83B7\u53D6\u4F59\u989D\r\n    function getBalance() external view returns (uint256) {\r\n        return address(this).balance;\r\n    }\r\n\r\n    // \u9500\u6BC1\r\n    function kill() external onlyOwner {\r\n        selfdestruct(msg.sender);\r\n    }\r\n\r\n    // \u53D1\u9001\u6D88\u606F\r\n    function sendMsg(string _content) external {\r\n        uint id = msgs.push(Msg({\r\n            timestamp:uint256(now),\r\n            sender:msg.sender,\r\n            content:_content\r\n        })) - 1;\r\n\r\n        msgToOwner[id] = msg.sender;\r\n        ownerMsgCount[msg.sender]\u002B\u002B;\r\n\r\n        emit SendMsgEvent(msg.sender, _content);\r\n    }\r\n\r\n    // \u83B7\u53D6\u6D88\u606F\r\n    function getMsg(uint _id) external view onlyOwner returns (string memory content, uint timestamp) {\r\n        require(_id \u003C msgs.length, \u0022id should not larger than array length.\u0022);\r\n        content = msgs[_id].content;\r\n        timestamp = msgs[_id].timestamp;\r\n        return (content, timestamp);\r\n    }\r\n\r\n    // \u83B7\u53D6\u67D0\u4EBA\u53D1\u7684\u6240\u6709\u6D88\u606F\r\n    function getMsgsByOwner(address _owner) external view onlyOwner returns (uint[]) {\r\n        uint[] memory result = new uint[](ownerMsgCount[_owner]);\r\n        uint counter = 0;\r\n        for (uint i = 0; i \u003C msgs.length; i\u002B\u002B) {\r\n            if (msgToOwner[i] == _owner) {\r\n                result[counter] = i;\r\n                counter\u002B\u002B;\r\n            }\r\n        }\r\n        return result;\r\n    }\r\n\r\n    // \u83B7\u53D6\u6240\u6709\u6D88\u606F\r\n    function getMsgsLength() external view onlyOwner returns (uint len) {\r\n        len = msgs.length;\r\n        return len;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getMsg\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022content\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022timestamp\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022INITIAL_SUPPLY\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022kill\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferByOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getMsgsByOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_content\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022sendMsg\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_freeze\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022freeze\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getMsgsLength\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022len\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_timestamp\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022freezeByTimestamp\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_target\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getFrozenTimestamp\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022msgToOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_content\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022SendMsgEvent\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"HBIF","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://58cf3b115c7ff9a812db3e9193c27bae1a5c0e6aec8eadc9ba4901286c94a0a2"}]