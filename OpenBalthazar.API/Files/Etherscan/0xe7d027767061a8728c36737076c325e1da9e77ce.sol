[{"SourceCode":"pragma solidity ^0.4.23;\r\n\r\ncontract GAC {\r\n    mapping (address =\u003E uint256) private balances;\r\n    mapping (address =\u003E uint256[2]) private lockedBalances;\r\n    string public name;                   //fancy name: GAC\r\n    uint8 public decimals;                //How many decimals to show.\r\n    string public symbol;                 //An identifier: GAC\r\n    uint256 public totalSupply;\r\n    address public owner;\r\n        event Transfer(address indexed _from, address indexed _to, uint256 _value); \r\n    constructor(\r\n        uint256 _initialAmount,\r\n        string _tokenName,\r\n        uint8 _decimalUnits,\r\n        string _tokenSymbol,\r\n        address _owner,\r\n        address[] _lockedAddress,\r\n        uint256[] _lockedBalances,\r\n        uint256[] _lockedTimes\r\n    ) public {\r\n        balances[_owner] = _initialAmount;                   // Give the owner all initial tokens\r\n        totalSupply = _initialAmount;                        // Update total supply\r\n        name = _tokenName;                                   // Set the name for display purposes\r\n        decimals = _decimalUnits;                            // Amount of decimals for display purposes\r\n        symbol = _tokenSymbol;                               // Set the symbol for display purposes\r\n        owner = _owner;                                      // set owner\r\n        \r\n    }\r\n    function transfer(address _to, uint256 _value) public returns (bool success) {\r\n        \r\n        if(_to != address(0)){\r\n            if(lockedBalances[msg.sender][1] \u003E= now) {\r\n                require((balances[msg.sender] \u003E lockedBalances[msg.sender][0]) \u0026\u0026\r\n                 (balances[msg.sender] - lockedBalances[msg.sender][0] \u003E= _value));\r\n            } else {\r\n                require(balances[msg.sender] \u003E= _value);\r\n            }\r\n            balances[msg.sender] -= _value;\r\n            balances[_to] \u002B= _value;\r\n            emit Transfer(msg.sender, _to, _value);\r\n            return true;\r\n        }\r\n    }\r\n    function burnFrom(address _who,uint256 _value)public returns (bool){\r\n        require(msg.sender == owner);\r\n        assert(balances[_who] \u003E= _value);\r\n        totalSupply -= _value;\r\n        balances[_who] -= _value;\r\n        lockedBalances[_who][0] = 0;\r\n        lockedBalances[_who][1] = 0;\r\n        return true;\r\n    }\r\n    function makeCoin(uint256 _value)public returns (bool){\r\n        require(msg.sender == owner);\r\n        totalSupply \u002B= _value;\r\n        balances[owner] \u002B= _value;\r\n        return true;\r\n    }\r\n    function balanceOf(address _owner) public view returns (uint256 balance) {\r\n        return balances[_owner];\r\n    }\r\n    function withdraw() public{\r\n        require(msg.sender == owner);\r\n        msg.sender.transfer(address(this).balance);\r\n    }\r\n    function withdrawTo(address _to) public{\r\n        require(msg.sender == owner);\r\n        address(_to).transfer(address(this).balance);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022withdrawTo\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_who\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burnFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022makeCoin\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_initialAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_tokenName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_decimalUnits\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022_tokenSymbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_lockedAddress\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_lockedBalances\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022_lockedTimes\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"GAC","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000000000000000000000000000000000174876e8000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000001400000000000000000000000002fac3795ff3b8e674247824ab55738a0f58089c6000000000000000000000000000000000000000000000000000000000000018000000000000000000000000000000000000000000000000000000000000001c00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000347414300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003474143000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000002fac3795ff3b8e674247824ab55738a0f58089c6000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000005d430c80","Library":"","SwarmSource":"bzzr://60a8254bb088b0233992fe68340dc623eb545a4e0a2906f72206c84fe48ba937"}]