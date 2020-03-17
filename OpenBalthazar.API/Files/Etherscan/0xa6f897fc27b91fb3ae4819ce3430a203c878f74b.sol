[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\ncontract Transfer {\r\n    \r\n    function bulkTransfer(address payable[] memory _tos, uint256[] memory _values) public payable {\r\n        uint256 total;\r\n        for (uint256 i; i \u003C _tos.length; i\u002B\u002B) {\r\n            _tos[i].transfer(_values[i]);\r\n            total \u002B= _values[i];\r\n        }\r\n        msg.sender.transfer(msg.value - total);\r\n    }\r\n    \r\n    function bulkTransferSameValue(address payable[] memory _tos, uint256 _value) public payable {\r\n        uint256 total;\r\n        for (uint256 i; i \u003C _tos.length; i\u002B\u002B) {\r\n            _tos[i].transfer(_value);\r\n            total \u002B= _value;\r\n        }\r\n        msg.sender.transfer(msg.value - total);\r\n    }\r\n\r\n    function transfer(address payable _to) public payable {\r\n        _to.transfer(msg.value);\r\n    }\r\n    \r\n    function balance(address _to) public view returns (uint256) {\r\n        return _to.balance;\r\n    }\r\n    \r\n    function kill() public {\r\n        selfdestruct(msg.sender);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable[]\u0022,\u0022name\u0022:\u0022_tos\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_values\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022bulkTransfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable[]\u0022,\u0022name\u0022:\u0022_tos\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022bulkTransferSameValue\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022kill\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"Transfer","CompilerVersion":"v0.5.16\u002Bcommit.9c3226ce","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://36aaf0eb62bfa6f37df01ea81a220eb0fc559ac946ccff34bdd09071d55b6a17"}]