[{"SourceCode":"pragma solidity 0.5.0;\r\n\r\ncontract DappHeroTest {\r\n    uint important = 20;\r\n    bytes32 hello = \u0022hello\u0022;\r\n    uint fee = 1 ether / 100;\r\n    \r\n    function viewNoArgsMultipleReturn() public view returns(uint _important, bytes32 _hello){\r\n        return (\r\n            important,\r\n            hello\r\n        );\r\n    }\r\n    \r\n    function viewMultipleArgsSingleReturn(address from, uint multiplier) public view returns(uint _balanceMultiplied){\r\n        return address(from).balance * multiplier;\r\n    }\r\n    \r\n    function viewMultipleArgsMultipleReturn(address from, uint multiplier) public view returns(uint _balanceMultiplied, bytes32 _hello){\r\n        return (\r\n            address(from).balance * multiplier,\r\n            hello\r\n        );\r\n    }\r\n\r\n    event EventTrigger(address indexed sender, uint value);\r\n    event ValueSent(address indexed sender);\r\n    event ValueSentWithMessage(address indexed sender, bytes32 message);\r\n\r\n    function triggerEvent(uint value) public {\r\n        emit EventTrigger (msg.sender, value);\r\n    }\r\n\r\n    modifier isCorrectFee() {\r\n        require(msg.value == fee);\r\n        _;\r\n    }\r\n\r\n    function sendEthNoArgs() isCorrectFee public payable {\r\n        emit ValueSent(msg.sender);\r\n    }\r\n\r\n    function sendEthWithArgs(bytes32 message) isCorrectFee public payable {\r\n        emit ValueSentWithMessage(msg.sender, message);\r\n    }\r\n\r\n    function sendVariableEthNoArgs() public payable {\r\n        require(msg.value \u003E fee / 10);\r\n        emit ValueSent(msg.sender);\r\n    }\r\n\r\n    function sendVariableEthWithArgs(bytes32 message) public payable {\r\n        require(msg.value \u003E fee / 10);\r\n        emit ValueSentWithMessage(msg.sender, message);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022sendEthWithArgs\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022multiplier\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022viewMultipleArgsMultipleReturn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_balanceMultiplied\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_hello\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sendVariableEthNoArgs\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022multiplier\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022viewMultipleArgsSingleReturn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_balanceMultiplied\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022viewNoArgsMultipleReturn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_important\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_hello\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022sendVariableEthWithArgs\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sendEthNoArgs\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022triggerEvent\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022EventTrigger\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022ValueSent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022ValueSentWithMessage\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"DappHeroTest","CompilerVersion":"v0.5.0\u002Bcommit.1d4f565a","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://6d66d0b86e0090ca8be942f23a9531a13e8ec76278c774b3535dd47406790787"}]