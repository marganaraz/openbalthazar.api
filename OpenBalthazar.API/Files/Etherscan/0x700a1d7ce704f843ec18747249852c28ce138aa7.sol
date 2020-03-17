[{"SourceCode":"pragma solidity ^0.5.11;\r\n\r\nlibrary SafeMath {\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n        c = a * b;\r\n        assert(c / a == b);\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a / b;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n}\r\n\r\ncontract Ownable {\r\n\taddress public owner;\r\n\taddress public newOwner;\r\n\r\n\tevent OwnershipTransferred(address indexed oldOwner, address indexed newOwner);\r\n\r\n\tfunction OwnerConstructor() internal {\r\n\t    owner = msg.sender;\r\n\t\tnewOwner = address(0);\r\n\t}\r\n\r\n\tmodifier onlyOwner() {\r\n\t\trequire(msg.sender == owner, \u0022msg.sender == owner\u0022);\r\n\t\t_;\r\n\t}\r\n\r\n\tfunction transferOwnership(address _newOwner) public onlyOwner {\r\n\t\trequire(address(0) != _newOwner, \u0022address(0) != _newOwner\u0022);\r\n\t\tnewOwner = _newOwner;\r\n\t}\r\n\r\n\tfunction acceptOwnership() public {\r\n\t\trequire(msg.sender == newOwner, \u0022msg.sender == newOwner\u0022);\r\n\t\temit OwnershipTransferred(owner, msg.sender);\r\n\t\towner = msg.sender;\r\n\t\tnewOwner = address(0);\r\n\t}\r\n}\r\n\r\ncontract Authorizable is Ownable {\r\n    mapping(address =\u003E bool) public authorized;\r\n  \r\n    event AuthorizationSet(address indexed addressAuthorized, bool indexed authorization);\r\n\r\n    function AuthorizableConstructor() internal {\r\n        authorized[msg.sender] = true;\r\n\t}\r\n\r\n    modifier onlyAuthorized() {\r\n        require(authorized[msg.sender], \u0022authorized[msg.sender]\u0022);\r\n        _;\r\n    }\r\n\r\n    function setAuthorized(address addressAuthorized, bool authorization) onlyOwner public {\r\n        emit AuthorizationSet(addressAuthorized, authorization);\r\n        authorized[addressAuthorized] = authorization;\r\n    }\r\n  \r\n}\r\n\r\ncontract ERC20Basic {\r\n    string public name;\r\n    string public symbol;\r\n    uint8 public decimals;\r\n    uint256 public totalSupply;\r\n    function balanceOf(address who) public view returns (uint256);\r\n    function transfer(address to, uint256 value) public returns (bool);\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n\r\ncontract ERC20 is ERC20Basic {\r\n  function allowance(address owner, address spender) public view returns (uint256);\r\n  function transferFrom(address from, address to, uint256 value) public returns (bool);\r\n  function approve(address spender, uint256 value) public returns (bool);\r\n  event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\ncontract BasicToken is ERC20Basic {\r\n    using SafeMath for uint256;\r\n\r\n    mapping(address =\u003E uint256) balances;\r\n\r\n    function transferFunction(address _sender, address _to, uint256 _value) internal returns (bool) {\r\n        require(_to != address(0), \u0022_to != address(0)\u0022);\r\n        require(_to != address(this), \u0022_to != address(this)\u0022);\r\n        require(_value \u003C= balances[_sender], \u0022_value \u003C= balances[_sender]\u0022);\r\n\r\n        balances[_sender] = balances[_sender].sub(_value);\r\n        balances[_to] = balances[_to].add(_value);\r\n        emit Transfer(_sender, _to, _value);\r\n        return true;\r\n    }\r\n  \r\n    function transfer(address _to, uint256 _value) public returns (bool) {\r\n\t    return transferFunction(msg.sender, _to, _value);\r\n    }\r\n\r\n    function balanceOf(address _owner) public view returns (uint256 balance) {\r\n        return balances[_owner];\r\n    }\r\n}\r\n\r\ncontract ERC223TokenCompatible is BasicToken {\r\n  using SafeMath for uint256;\r\n  \r\n  event Transfer(address indexed from, address indexed to, uint256 value, bytes indexed data);\r\n\r\n\tfunction transfer(address _to, uint256 _value, bytes memory _data, string memory _custom_fallback) public returns (bool success) {\r\n\t    transferFunction(msg.sender, _to, _value);\r\n\t\tif( isContract(_to) ) {\r\n\t\t    (bool txOk, ) = _to.call.value(0)( abi.encodePacked(bytes4( keccak256( abi.encodePacked( _custom_fallback ) ) ), msg.sender, _value, _data) );\r\n\t\t\trequire( txOk, \u0022_to.call.value(0)( abi.encodePacked(bytes4( keccak256( abi.encodePacked( _custom_fallback ) ) ), msg.sender, _value, _data) )\u0022 );\r\n\r\n\t\t}\r\n\t\treturn true;\r\n\t}\r\n\r\n\tfunction transfer(address _to, uint256 _value, bytes memory _data) public returns (bool success) {\r\n\t\treturn transfer( _to, _value, _data, \u0022tokenFallback(address,uint256,bytes)\u0022);\r\n\t}\r\n\r\n\t//assemble the given address bytecode. If bytecode exists then the _addr is a contract.\r\n\tfunction isContract(address _addr) private view returns (bool is_contract) {\r\n\t\tuint256 length;\r\n\t\tassembly {\r\n            //retrieve the size of the code on target address, this needs assembly\r\n            length := extcodesize(_addr)\r\n\t\t}\r\n\t\treturn (length\u003E0);\r\n    }\r\n}\r\n\r\ncontract StandardToken is ERC20, BasicToken {\r\n\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) internal allowed;\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {\r\n        require(_value \u003C= allowed[_from][msg.sender], \u0022_value \u003C= allowed[_from][msg.sender]\u0022);\r\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n        transferFunction(_from, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    function approve(address _spender, uint256 _value) public returns (bool) {\r\n        allowed[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n\r\n    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {\r\n        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);\r\n        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n        return true;\r\n    }\r\n\r\n    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {\r\n        uint oldValue = allowed[msg.sender][_spender];\r\n        if (_subtractedValue \u003E oldValue) {\r\n            allowed[msg.sender][_spender] = 0;\r\n        } else {\r\n        allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\r\n        }\r\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n    return true;\r\n    }\r\n\r\n}\r\n\r\ncontract HumanStandardToken is StandardToken {\r\n    /* Approves and then calls the receiving contract */\r\n    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {\r\n        approve(_spender, _value);\r\n        (bool txOk, ) = _spender.call(abi.encodePacked(bytes4(keccak256(\u0022receiveApproval(address,uint256,bytes)\u0022)), msg.sender, _value, _extraData));\r\n        require(txOk, \u0027_spender.call(abi.encodePacked(bytes4(keccak256(\u0022receiveApproval(address,uint256,bytes)\u0022)), msg.sender, _value, _extraData))\u0027);\r\n        return true;\r\n    }\r\n    function approveAndCustomCall(address _spender, uint256 _value, bytes memory _extraData, bytes4 _customFunction) public returns (bool success) {\r\n        approve(_spender, _value);\r\n        (bool txOk, ) = _spender.call(abi.encodePacked(_customFunction, msg.sender, _value, _extraData));\r\n        require(txOk, \u0022_spender.call(abi.encodePacked(_customFunction, msg.sender, _value, _extraData))\u0022);\r\n        return true;\r\n    }\r\n}\r\n\r\ncontract Startable is Ownable, Authorizable {\r\n    event Start();\r\n\r\n    bool public started = false;\r\n\r\n    modifier whenStarted() {\r\n\t    require( started || authorized[msg.sender], \u0022started || authorized[msg.sender]\u0022 );\r\n        _;\r\n    }\r\n\r\n    function start() onlyOwner public {\r\n        started = true;\r\n        emit Start();\r\n    }\r\n}\r\n\r\ncontract StartToken is Startable, ERC223TokenCompatible, StandardToken {\r\n\r\n    function transfer(address _to, uint256 _value) public whenStarted returns (bool) {\r\n        return super.transfer(_to, _value);\r\n    }\r\n    function transfer(address _to, uint256 _value, bytes memory _data) public whenStarted returns (bool) {\r\n        return super.transfer(_to, _value, _data);\r\n    }\r\n    function transfer(address _to, uint256 _value, bytes memory _data, string memory _custom_fallback) public whenStarted returns (bool) {\r\n        return super.transfer(_to, _value, _data, _custom_fallback);\r\n    }\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) public whenStarted returns (bool) {\r\n        return super.transferFrom(_from, _to, _value);\r\n    }\r\n\r\n    function approve(address _spender, uint256 _value) public whenStarted returns (bool) {\r\n        return super.approve(_spender, _value);\r\n    }\r\n\r\n    function increaseApproval(address _spender, uint _addedValue) public whenStarted returns (bool success) {\r\n        return super.increaseApproval(_spender, _addedValue);\r\n    }\r\n\r\n    function decreaseApproval(address _spender, uint _subtractedValue) public whenStarted returns (bool success) {\r\n        return super.decreaseApproval(_spender, _subtractedValue);\r\n    }\r\n}\r\n\r\n\r\ncontract BurnToken is StandardToken {\r\n    uint256 public initialSupply;\r\n\r\n    event Burn(address indexed burner, uint256 value);\r\n    \r\n    function BurnConstructor(uint256 _totalSupply) internal {\r\n        initialSupply = _totalSupply;\r\n\t}\r\n    \r\n    function burnFunction(address _burner, uint256 _value) internal returns (bool) {\r\n        require(_value \u003E 0, \u0022_value \u003E 0\u0022);\r\n\t\trequire(_value \u003C= balances[_burner], \u0022_value \u003C= balances[_burner]\u0022);\r\n\r\n        balances[_burner] = balances[_burner].sub(_value);\r\n        totalSupply = totalSupply.sub(_value);\r\n        emit Burn(_burner, _value);\r\n\t\temit Transfer(_burner, address(0), _value);\r\n\t\treturn true;\r\n    }\r\n    \r\n\tfunction burn(uint256 _value) public returns(bool) {\r\n        return burnFunction(msg.sender, _value);\r\n    }\r\n\t\r\n\tfunction burnFrom(address _from, uint256 _value) public returns (bool) {\r\n\t\trequire(_value \u003C= allowed[_from][msg.sender], \u0022_value \u003C= allowed[_from][msg.sender]\u0022); // check if it has the budget allowed\r\n\t\tburnFunction(_from, _value);\r\n\t\tallowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n\t\treturn true;\r\n\t}\r\n}\r\n\r\ncontract Changable is Ownable, ERC20Basic {\r\n    function changeName(string memory _newName) public onlyOwner {\r\n        name = _newName;\r\n    }\r\n    function changeSymbol(string memory _newSymbol) public onlyOwner {\r\n        symbol = _newSymbol;\r\n    }\r\n}\r\n\r\ncontract Token is ERC20Basic, ERC223TokenCompatible, StandardToken, HumanStandardToken, StartToken, BurnToken, Changable {\r\n\r\n    function TokenConstructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply) internal {\r\n        name = _name;\r\n        symbol = _symbol;\r\n        decimals = _decimals;\r\n        totalSupply = _totalSupply;\r\n        \r\n        balances[msg.sender] = totalSupply;\r\n\t\temit Transfer(address(0), msg.sender, totalSupply);\r\n\t}\r\n    \r\n    \r\n    bool internal initialized = true;\r\n    function initialize(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply) public {\r\n        require(!initialized, \u0022!initialized\u0022);\r\n        initialized = true;\r\n        \r\n        OwnerConstructor();\r\n        AuthorizableConstructor();\r\n        TokenConstructor(_name, _symbol, _decimals, _totalSupply);\r\n        BurnConstructor(_totalSupply);\r\n    }\r\n    \r\n}","ABI":"[{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addressAuthorized\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022authorization\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022AuthorizationSet\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022burner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022oldOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Start\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022_extraData\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022approveAndCall\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022_extraData\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022internalType\u0022:\u0022bytes4\u0022,\u0022name\u0022:\u0022_customFunction\u0022,\u0022type\u0022:\u0022bytes4\u0022}],\u0022name\u0022:\u0022approveAndCustomCall\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022authorized\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burnFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_newName\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022changeName\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_newSymbol\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022changeSymbol\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseApproval\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseApproval\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022initialSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_symbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022_decimals\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_totalSupply\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022initialize\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022newOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addressAuthorized\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022authorization\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setAuthorized\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022start\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022started\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_custom_fallback\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"Token","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://dd84d6b445624b25bfb7d79ff8caf51a50d944798363c9329fafb9c860081cbd"}]