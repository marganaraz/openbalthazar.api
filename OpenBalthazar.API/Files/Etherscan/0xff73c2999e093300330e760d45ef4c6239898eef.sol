[{"SourceCode":"/* \r\n\r\n*Submitted for verification at Etherscan.io on 2019-11-12\r\n*Deployed to Ethereum Mainnet on 28-02-2020\r\n*Developed by the Technical Team of Greyzdorf BTR LLC\r\n\r\nBacked By : Glass Apple Farm Property\r\nValuation : $8.5 Million - 27-02-2020\r\nTicker : APR\r\nTotalSupply : Variable Supply\r\nDecimal : 0\r\nBurning : available\r\nMinting : available\r\nWhitelisting : available\r\nFreeze : available\r\nType of Asset : Real Estate Backed\r\n\r\n*/\r\n\r\npragma solidity ^ 0.6.3;\r\n\r\n/* SafeMath functions */\r\n\r\ncontract SafeMath {\r\n    \r\n  function safeMul(uint256 a, uint256 b) pure internal returns (uint256) {\r\n    uint256 c = a * b;\r\n    assert(a == 0 || c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function safeDiv(uint256 a, uint256 b) pure internal returns (uint256) {\r\n    assert(b \u003E 0);\r\n    uint256 c = a / b;\r\n    assert(a == b * c \u002B a % b);\r\n    return c;\r\n  }\r\n\r\n  function safeSub(uint256 a, uint256 b) pure internal returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function safeAdd(uint256 a, uint256 b) pure internal returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c\u003E=a \u0026\u0026 c\u003E=b);\r\n    return c;\r\n  }\r\n\r\n}\r\n\r\ncontract APR is SafeMath {\r\n    \r\n    string public constant name = \u0022Glass Apple Estate\u0022;\r\n    string public constant symbol = \u0022APR\u0022;\r\n    uint256 public constant decimals = 0;\r\n    uint256 public totalSupply = 0;\r\n    uint256 public constant version = 1.0;\r\n    address payable public owner;\r\n    uint256 public lendersCount;\r\n    string public constant issuer = \u0022Greyzdorf BTR LLC\u0022;\r\n    string public constant website = \u0022https://www.greyzdorf.io\u0022;\r\n    \r\n    constructor() public{\r\n        uint256 initalSupply = 0;\r\n        owner = msg.sender;\r\n        balanceOf[msg.sender]=initalSupply;\r\n        totalSupply\u002B=initalSupply;\r\n        emit Transfer(address(0), owner, initalSupply);\r\n     }\r\n\r\n    \r\n    struct Lenders{\r\n        address LenderId;\r\n        bool verified;\r\n        string name;\r\n        string website;\r\n        string location;\r\n        string createdAt;\r\n    }\r\n\r\n    mapping (address =\u003E uint256) public balanceOf;\r\n    mapping (address =\u003E uint256) public freezeOf;\r\n    mapping (address =\u003E Lenders) lenders;\r\n    \r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    event Burn(address indexed from, uint256 value);\r\n    \r\n    \r\n    modifier onlyOwner(){\r\n        require(msg.sender==owner);\r\n        _;\r\n    }\r\n    \r\n    function createLender(string memory _name,address _lender,string memory _website,string memory _location,string memory _createdDate) public onlyOwner returns (bool){\r\n        Lenders storage lender = lenders[_lender];\r\n        if(lender.LenderId != _lender){\r\n        lender.LenderId = _lender;\r\n        lender.name = _name;\r\n        lender.website = _website;\r\n        lender.location = _location;\r\n        lender.createdAt=_createdDate;\r\n        lender.verified = true;\r\n        lendersCount\u002B\u002B;\r\n        return true;\r\n        }\r\n        else return false;\r\n     }\r\n    \r\n    function fetchLender(address _address)public view returns(string memory,string memory,string memory,string memory, bool){\r\n        Lenders storage lender = lenders[_address];\r\n        if(lender.LenderId==_address){\r\n            return(lender.name,lender.website,lender.location,lender.createdAt,lender.verified);\r\n        }\r\n        else if(_address == owner){\r\n            return(\u0022Owner of Property\u0022,\u0022https://greyzdorf.io\u0022,\u0022Atanta, GA, USA\u0022,\u002228-02-2020\u0022,false);\r\n        }\r\n        else return(\u0022No Lender Found\u0022,\u0022No Website Info\u0022,\u0022No Location Info\u0022,\u0022Not Created Yet\u0022,false);\r\n    }\r\n    \r\n    function disableLender(address _lender) public onlyOwner returns(bool){\r\n        Lenders storage lender = lenders[_lender];\r\n        if(lender.LenderId == _lender){\r\n            lender.verified = false;\r\n            lendersCount--;\r\n            return true;\r\n        }\r\n        else return false;\r\n    }\r\n    \r\n    function enableLender(address _lender) public onlyOwner returns(bool){\r\n        Lenders storage lender = lenders[_lender];\r\n        if(lender.LenderId == _lender){\r\n            lender.verified = true;\r\n            lendersCount\u002B\u002B;\r\n            return true;\r\n        }\r\n        else return false;\r\n    }\r\n    \r\n    function mint(uint256 _value) public onlyOwner returns (bool){\r\n        balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender],_value);\r\n        totalSupply = SafeMath.safeAdd(totalSupply,_value);\r\n        emit Transfer(address(0),msg.sender,_value);\r\n        return true;\r\n    }\r\n    \r\n    function burn(uint256 _value) public onlyOwner returns (bool success){\r\n        if(balanceOf[msg.sender]\u003E=_value){\r\n            balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender],_value);\r\n            totalSupply = SafeMath.safeSub(totalSupply,_value);\r\n            emit Burn(msg.sender, _value);\r\n            return true;\r\n        }\r\n        else return false;\r\n    }\r\n    \r\n    function transfer(address _reciever, uint256 _value) public returns (string memory){\r\n         Lenders storage lender = lenders[_reciever];\r\n         uint256 amount = SafeMath.safeSub(_value,freezeOf[msg.sender]);\r\n         if(balanceOf[msg.sender]\u003E=_value \u0026\u0026 lender.verified==true \u0026\u0026 amount != 0){\r\n            balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender],amount);\r\n            balanceOf[_reciever] = SafeMath.safeAdd(balanceOf[_reciever],amount);\r\n            emit Transfer(msg.sender,_reciever,amount);\r\n            return(\u0022Transaction Success\u0022);\r\n        }\r\n        else if (_reciever==owner \u0026\u0026 balanceOf[msg.sender]\u003E=_value \u0026\u0026 amount !=0){\r\n          balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender],_value);\r\n          balanceOf[_reciever] = SafeMath.safeAdd(balanceOf[_reciever],_value);\r\n          emit Transfer(msg.sender,_reciever,amount);\r\n          return(\u0022Transaction Success\u0022);   \r\n        }\r\n        else return(\u0022Transaction Failed\u0022);\r\n    }\r\n    \r\n    function freeze(address _lender, uint256 _value)  public onlyOwner returns (bool){\r\n        if(balanceOf[_lender]\u003E=_value){\r\n            freezeOf[_lender] = SafeMath.safeAdd(freezeOf[_lender],_value);\r\n            return true;\r\n        }\r\n        else return false;\r\n        \r\n    }\r\n    \r\n    function Unfreeze(address _lender,uint256 _value) public onlyOwner returns (bool){\r\n        if(freezeOf[_lender]\u003E=_value){\r\n            freezeOf[_lender] = SafeMath.safeSub(balanceOf[_lender],_value);\r\n            return true;\r\n        }\r\n        else  return false;\r\n    }\r\n    \r\n    function withdrawEther(uint256 amount) public onlyOwner returns (bool) {\r\n\t\tif(msg.sender == owner){\r\n\t\towner.transfer(amount);\r\n\t\treturn true;\r\n\t\t}\r\n\t\telse return false;\r\n\t}\r\n\t\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_lender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Unfreeze\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_lender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_website\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_location\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_createdDate\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022createLender\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_lender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022disableLender\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_lender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022enableLender\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022fetchLender\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_lender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022freeze\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022freezeOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022name\u0022:\u0022issuer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022name\u0022:\u0022lendersCount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022mint\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_reciever\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022name\u0022:\u0022version\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022name\u0022:\u0022website\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawEther\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"APR","CompilerVersion":"v0.6.3\u002Bcommit.8dda9521","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"ipfs://92f18a4b2398749098c592802480ffd1008e055e6e4e19e036e5736b13c5e584"}]