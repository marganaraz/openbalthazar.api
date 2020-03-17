[{"SourceCode":"pragma solidity ^0.4.16;\r\ninterface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }\r\n contract TokenERC20 {\r\nstring public name;\r\nstring public symbol;\r\nuint8 public decimals = 4; \r\nuint256 public totalSupply;\r\nmapping (address =\u003E uint256) public balanceOf;\r\nmapping (address =\u003E mapping (address =\u003E uint256)) public allowance;\r\nevent Transfer(address indexed from, address indexed to, uint256 value);\r\nevent Burn(address indexed from, uint256 value);\r\nfunction TokenERC20(uint256 initialSupply, string tokenName, string tokenSymbol) public {\r\n\ttotalSupply = initialSupply * 10 ** uint256(decimals); \r\n\tbalanceOf[msg.sender] = totalSupply;       \r\n\tname = tokenName;                     \r\n\tsymbol = tokenSymbol;                 \r\n}\r\n\r\nfunction _transfer(address _from, address _to, uint _value) internal {\r\n\trequire(_to != 0x0);\r\n\trequire(balanceOf[_from] \u003E= _value);\r\n\trequire(balanceOf[_to] \u002B _value \u003E balanceOf[_to]);\r\n\tuint previousBalances = balanceOf[_from] \u002B balanceOf[_to];\r\n\tbalanceOf[_from] -= _value;\r\n\tbalanceOf[_to] \u002B= _value;\r\n\tTransfer(_from, _to, _value);\r\n\tassert(balanceOf[_from] \u002B balanceOf[_to] == previousBalances);\r\n}\r\nfunction transfer(address _to, uint256 _value) public {\r\n\t_transfer(msg.sender, _to, _value);\r\n}\r\nfunction transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {\r\n\trequire(_value \u003C= allowance[_from][msg.sender]);     // Check allowance\r\n\tallowance[_from][msg.sender] -= _value;\r\n\t_transfer(_from, _to, _value);\r\n\treturn true;\r\n}\r\n\r\nfunction approve(address _spender, uint256 _value) public\r\nreturns (bool success) {\r\n\tallowance[msg.sender][_spender] = _value;\r\n\treturn true;\r\n}\r\n\r\n\r\nfunction approveAndCall(address _spender, uint256 _value, bytes _extraData)\r\n\tpublic\r\n\treturns (bool success) {\r\n\t\ttokenRecipient spender = tokenRecipient(_spender);\r\n\t\tif (approve(_spender, _value)) {\r\n\t\t\tspender.receiveApproval(msg.sender, _value, this, _extraData);\r\n\t\t\treturn true;\r\n\t\t}\r\n\t}\r\n\r\nfunction burn(uint256 _value) public returns (bool success) {\r\n\trequire(balanceOf[msg.sender] \u003E= _value);   \r\n\tbalanceOf[msg.sender] -= _value;           \r\n\ttotalSupply -= _value;               \r\n\tBurn(msg.sender, _value);\r\n\treturn true;\r\n}\r\n\r\nfunction burnFrom(address _from, uint256 _value) public returns (bool success) {\r\n\trequire(balanceOf[_from] \u003E= _value);        \r\n\trequire(_value \u003C= allowance[_from][msg.sender]);  \r\n\tbalanceOf[_from] -= _value;          \r\n\tallowance[_from][msg.sender] -= _value;  \r\n\ttotalSupply -= _value;            \r\n\tBurn(_from, _value);\r\n\treturn true;\r\n}\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burnFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_extraData\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022approveAndCall\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022initialSupply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022tokenName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022tokenSymbol\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"TokenERC20","CompilerVersion":"v0.4.16\u002Bcommit.d7661dd9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000000000000000000000000000000000001ee00d80000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000a4869546f7572426573740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000034854420000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://f0a6c5324b209ab889fb7c260fae5854e127a97d8c29760cdcf740e96dd1618a"}]