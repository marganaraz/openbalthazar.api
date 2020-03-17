[{"SourceCode":"pragma solidity ^0.5.3;\r\n\r\ncontract TokenERC20 {\r\n    mapping (address =\u003E uint256) public balanceOf;\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);\r\n}\r\ncontract multiSend{\r\n    address public baseAddr = 0x500Df47E1dF0ef06039218dCF0960253D89D6658;\r\n\tTokenERC20 bcontract = TokenERC20(baseAddr);\r\n    event cannotAirdrop(address indexed addr, uint balance, uint etherBalance);\r\n    uint public distributedAmount = 2001200;\r\n\r\n    function() external payable { \r\n        revert();\r\n    }\r\n    \r\n    function sendOutToken(uint256 limitInFinney, address[] memory addrs) public {\r\n        for(uint i=0;i\u003Caddrs.length;i\u002B\u002B){\r\n            if(addrs[i] == address(0)) continue;\r\n            if(bcontract.balanceOf(addrs[i]) \u003E0 || addrs[i].balance \u003C limitInFinney * (10 ** uint256(15))){ \r\n                emit cannotAirdrop(addrs[i],bcontract.balanceOf(addrs[i]),addrs[i].balance);\r\n            }else{\r\n                bcontract.transferFrom(msg.sender,addrs[i], 100 * (10 ** uint256(18)));\r\n                distributedAmount \u002B= 100;\r\n            } \r\n        }\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022distributedAmount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022baseAddr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022limitInFinney\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022addrs\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022sendOutToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022etherBalance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022cannotAirdrop\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"multiSend","CompilerVersion":"v0.5.3\u002Bcommit.10d17f24","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://71d24965cf548b8cd42f04a94e7b64aba889572da470c9aeeb2e8750f08fd599"}]