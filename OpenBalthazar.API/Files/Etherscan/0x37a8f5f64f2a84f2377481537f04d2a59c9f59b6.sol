[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\n\r\n/**\r\n * @title EthereumProxy\r\n * @notice This contract performs an ethereum transfer and stores a reference\r\n */\r\ncontract EthereumProxy {\r\n  // Event to declare a transfer with a reference\r\n  event TransferWithReference(address to, uint256 amount, bytes indexed paymentReference);\r\n\r\n  // Fallback function returns funds to the sender\r\n  function() external payable {\r\n    revert(\u0022not payable fallback\u0022);\r\n  }\r\n\r\n  /**\r\n  * @notice Performs an ethereum transfer with a reference\r\n  * @param _to Transfer recipient\r\n  * @param _paymentReference Reference of the payment related\r\n  */\r\n  function transferWithReference(address payable _to, bytes calldata _paymentReference)\r\n    external\r\n    payable\r\n  {\r\n    _to.transfer(msg.value);\r\n    emit TransferWithReference(_to, msg.value, _paymentReference);\r\n  }\r\n}","ABI":"[{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022paymentReference\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022TransferWithReference\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022_paymentReference\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022transferWithReference\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"EthereumProxy","CompilerVersion":"v0.5.16\u002Bcommit.9c3226ce","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://681f757575599f1d8a376ac82978518c50e78e87188eb91153581ae88893ffd7"}]