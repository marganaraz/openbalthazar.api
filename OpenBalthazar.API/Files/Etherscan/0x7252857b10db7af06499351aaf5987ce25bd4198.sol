[{"SourceCode":"/**\r\n *Submitted for verification at Etherscan.io on 2018-05-14\r\n*/\r\n\r\npragma solidity ^0.4.21;\r\n\r\ncontract SafeMath {\r\n    function safeSub(uint a, uint b) pure internal returns (uint) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    function safeAdd(uint a, uint b) pure internal returns (uint) {\r\n        uint c = a \u002B b;\r\n        assert(c \u003E= a \u0026\u0026 c \u003E= b);\r\n        return c;\r\n    }\r\n}\r\n\r\n\r\ncontract ERC20 {\r\n    uint public totalSupply;\r\n    function balanceOf(address who) public constant returns (uint);\r\n    function allowance(address owner, address spender) public constant returns (uint);\r\n    function transfer(address toAddress, uint value) public returns (bool ok);\r\n    function transferFrom(address fromAddress, address toAddress, uint value) public returns (bool ok);\r\n    function approve(address spender, uint value) public returns (bool ok);\r\n    event Transfer(address indexed fromAddress, address indexed toAddress, uint value);\r\n    event Approval(address indexed owner, address indexed spender, uint value);\r\n}\r\n\r\n\r\ncontract StandardToken is ERC20, SafeMath {\r\n    mapping (address =\u003E uint) balances;\r\n    mapping (address =\u003E mapping (address =\u003E uint)) allowed;\r\n\r\n    function transfer(address _to, uint _value) public returns (bool success) {\r\n        balances[msg.sender] = safeSub(balances[msg.sender], _value);\r\n        balances[_to] = safeAdd(balances[_to], _value);\r\n        Transfer(msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {\r\n        var _allowance = allowed[_from][msg.sender];\r\n\r\n        balances[_to] = safeAdd(balances[_to], _value);\r\n        balances[_from] = safeSub(balances[_from], _value);\r\n        allowed[_from][msg.sender] = safeSub(_allowance, _value);\r\n        Transfer(_from, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    function balanceOf(address _owner) public constant returns (uint balance) {\r\n        return balances[_owner];\r\n    }\r\n\r\n    function approve(address _spender, uint _value) public returns (bool success) {\r\n        allowed[msg.sender][_spender] = _value;\r\n        Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address _owner, address _spender) public constant returns (uint remaining) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract VOGel is StandardToken {\r\n    string public name = \u0022VOGel\u0022;\r\n    string public symbol = \u0022VOG\u0022;\r\n    uint public decimals = 18;\r\n    uint public totalSupply = 400 * 1000 * 1000 ether;\r\n\r\n    function VOGel() public {\r\n        balances[msg.sender] = totalSupply;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022fromAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022toAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"VOGel","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://58bfd90b3ea55e496a1ee6ce69deef5e17f91a4f25f5944c618f479bbe1e9459"}]