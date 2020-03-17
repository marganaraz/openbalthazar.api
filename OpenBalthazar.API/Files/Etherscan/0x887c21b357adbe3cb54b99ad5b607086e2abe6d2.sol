[{"SourceCode":"pragma solidity ^0.4.16;\r\n \r\ninterface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }\r\n\r\ncontract owned {\r\n    address public owner;\r\n\r\n    function owned () public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    modifier onlyOwner {\r\n        require (msg.sender == owner);\r\n        _;\r\n    }\r\n \r\n  }\r\n \r\ncontract TokenERC20 is owned {\r\n    string public name; \r\n    string public symbol; \r\n    uint8 public decimals = 8;  \r\n    uint256 public totalSupply; \r\n \r\n    mapping (address =\u003E uint256) public balanceOf;\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);  \r\n \r\n    function TokenERC20(uint256 initialSupply, string tokenName, string tokenSymbol) public {\r\n\r\n        totalSupply = initialSupply * 10 ** uint256(decimals);   \r\n\r\n        balanceOf[msg.sender] = totalSupply;\r\n        name = tokenName;\r\n        symbol = tokenSymbol;\r\n    }\r\n \r\n\r\n    function _transfer(address _from, address _to, uint256 _value) internal {\r\n \r\n      require(_to != 0x0);\r\n \r\n      require(balanceOf[_from] \u003E= _value);\r\n \r\n      require(balanceOf[_to] \u002B _value \u003E balanceOf[_to]);\r\n \r\n      uint previousBalances = balanceOf[_from] \u002B balanceOf[_to];\r\n \r\n      balanceOf[_from] -= _value;\r\n \r\n      balanceOf[_to] \u002B= _value;\r\n \r\n      Transfer(_from, _to, _value);\r\n \r\n      assert(balanceOf[_from] \u002B balanceOf[_to] == previousBalances);\r\n \r\n    }\r\n \r\n  }","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022initialSupply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022tokenName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022tokenSymbol\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"TokenERC20","CompilerVersion":"v0.4.16\u002Bcommit.d7661dd9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"0000000000000000000000000000000000000000000000000000000000002710000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000a5445535420544f4b454e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000035454540000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://afb5dd15d0b7ff3267c8ca50352565f24f1536089d713eb361cf6151f43b68df"}]