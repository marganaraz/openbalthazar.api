[{"SourceCode":"pragma solidity ^0.4.23;\r\n\r\ncontract RVC {\r\n    mapping (address =\u003E uint256) private balances;\r\n    string public name;\r\n    uint8 public decimals;\r\n    string public symbol;\r\n    uint256 public totalSupply;\r\n    address public owner;\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value); \r\n    constructor(\r\n        uint256 _initialAmount,\r\n        string _tokenName,\r\n        uint8 _decimalUnits,\r\n        string _tokenSymbol,\r\n        address _owner\r\n    ) public {\r\n        balances[_owner] = _initialAmount;\r\n        totalSupply = _initialAmount;\r\n        name = _tokenName;\r\n        decimals = _decimalUnits;\r\n        symbol = _tokenSymbol;\r\n        owner = _owner;\r\n    }\r\n    function transfer(address _to, uint256 _value) public returns (bool success) {\r\n        if(_to != address(0)){\r\n            require(balances[msg.sender] \u003E= _value);\r\n            balances[msg.sender] -= _value;\r\n            balances[_to] \u002B= _value;\r\n            emit Transfer(msg.sender, _to, _value);\r\n            return true;\r\n        }\r\n    }\r\n    function burnFrom(address _who,uint256 _value)public returns (bool){\r\n        require(msg.sender == owner);\r\n        assert(balances[_who] \u003E= _value);\r\n        totalSupply -= _value;\r\n        balances[_who] -= _value;\r\n        return true;\r\n    }\r\n    function balanceOf(address _owner) public view returns (uint256 balance) {\r\n        return balances[_owner];\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_who\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burnFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_initialAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_tokenName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_decimalUnits\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022_tokenSymbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"RVC","CompilerVersion":"v0.4.23\u002Bcommit.124ca40d","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000000000000000000000000000089aaeb710be000000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000b803e1cfabecae21f2f66feb2ef7693433890f75000000000000000000000000000000000000000000000000000000000000001252756e6e696e67205661756c7420436f696e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000035256430000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://7dff49b0707eaf4f8cad53053ec7628b9a5bf6506f3c3d15719ebbb24d470e34"}]