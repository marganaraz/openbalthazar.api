[{"SourceCode":"pragma solidity ^0.5.8;\r\n\r\n//Change the contract name to your token name\r\ncontract FEX {\r\n    // Name your custom token\r\n    string public constant name = \u0022ForesterX\u0022;\r\n\r\n    // Name your custom token symbol\r\n    string public constant symbol = \u0022FEX\u0022;\r\n\r\n    uint8 public constant decimals = 18;\r\n    \r\n    // Contract owner will be your Link account\r\n    address public owner;\r\n\r\n    address public treasury;\r\n\r\n    uint256 public totalSupply;\r\n\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) private allowed;\r\n    mapping (address =\u003E uint256) private balances;\r\n\r\n    event Approval(address indexed tokenholder, address indexed spender, uint256 value);\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n\r\n        // Add your wallet address here which will contain your total token supply\r\n        treasury = address(0x452c3E4143604825b5f28B8B2497E5A8847Cdc3F);\r\n\r\n        // Set your total token supply (default 1000)\r\n        totalSupply = 300000000 * 10**uint(decimals);\r\n\r\n        balances[treasury] = totalSupply;\r\n        emit Transfer(address(0), treasury, totalSupply);\r\n    }\r\n\r\n    function () external payable {\r\n        revert();\r\n    }\r\n\r\n    function allowance(address _tokenholder, address _spender) public view returns (uint256 remaining) {\r\n        return allowed[_tokenholder][_spender];\r\n    }\r\n\r\n    function approve(address _spender, uint256 _value) public returns (bool) {\r\n        require(_spender != address(0));\r\n        require(_spender != msg.sender);\r\n\r\n        allowed[msg.sender][_spender] = _value;\r\n\r\n        emit Approval(msg.sender, _spender, _value);\r\n\r\n        return true;\r\n    }\r\n\r\n    function balanceOf(address _tokenholder) public view returns (uint256 balance) {\r\n        return balances[_tokenholder];\r\n    }\r\n\r\n    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {\r\n        require(_spender != address(0));\r\n        require(_spender != msg.sender);\r\n\r\n        if (allowed[msg.sender][_spender] \u003C= _subtractedValue) {\r\n            allowed[msg.sender][_spender] = 0;\r\n        } else {\r\n            allowed[msg.sender][_spender] = allowed[msg.sender][_spender] - _subtractedValue;\r\n        }\r\n\r\n        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n\r\n        return true;\r\n    }\r\n\r\n    function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {\r\n        require(_spender != address(0));\r\n        require(_spender != msg.sender);\r\n        require(allowed[msg.sender][_spender] \u003C= allowed[msg.sender][_spender] \u002B _addedValue);\r\n\r\n        allowed[msg.sender][_spender] = allowed[msg.sender][_spender] \u002B _addedValue;\r\n\r\n        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n\r\n        return true;\r\n    }\r\n\r\n    function transfer(address _to, uint256 _value) public returns (bool) {\r\n        require(_to != msg.sender);\r\n        require(_to != address(0));\r\n        require(_to != address(this));\r\n        require(balances[msg.sender] - _value \u003C= balances[msg.sender]);\r\n        require(balances[_to] \u003C= balances[_to] \u002B _value);\r\n        require(_value \u003C= transferableTokens(msg.sender));\r\n\r\n        balances[msg.sender] = balances[msg.sender] - _value;\r\n        balances[_to] = balances[_to] \u002B _value;\r\n\r\n        emit Transfer(msg.sender, _to, _value);\r\n\r\n        return true;\r\n    }\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {\r\n        require(_from != address(0));\r\n        require(_from != address(this));\r\n        require(_to != _from);\r\n        require(_to != address(0));\r\n        require(_to != address(this));\r\n        require(_value \u003C= transferableTokens(_from));\r\n        require(allowed[_from][msg.sender] - _value \u003C= allowed[_from][msg.sender]);\r\n        require(balances[_from] - _value \u003C= balances[_from]);\r\n        require(balances[_to] \u003C= balances[_to] \u002B _value);\r\n\r\n        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;\r\n        balances[_from] = balances[_from] - _value;\r\n        balances[_to] = balances[_to] \u002B _value;\r\n\r\n        emit Transfer(_from, _to, _value);\r\n\r\n        return true;\r\n    }\r\n\r\n    function transferOwnership(address _newOwner) public {\r\n        require(msg.sender == owner);\r\n        require(_newOwner != address(0));\r\n        require(_newOwner != address(this));\r\n        require(_newOwner != owner);\r\n\r\n        address previousOwner = owner;\r\n        owner = _newOwner;\r\n\r\n        emit OwnershipTransferred(previousOwner, _newOwner);\r\n    }\r\n\r\n    function transferableTokens(address holder) public view returns (uint256) {\r\n        return balanceOf(holder);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022treasury\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenholder\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022holder\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferableTokens\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenholder\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenholder\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"FEX","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://29b1d4a496a48b690d6ebaa89f83959235c97a5347fc68086405aa047b66e14b"}]