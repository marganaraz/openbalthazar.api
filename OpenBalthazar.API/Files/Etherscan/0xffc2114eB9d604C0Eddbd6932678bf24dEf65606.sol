[{"SourceCode":"pragma solidity ^0.4.11;\r\ncontract TheButton {\r\n    uint public lastPressed;\r\n    event ButtonPress(address presser, uint pressTime, uint score);\r\n    \r\n    /// @notice Press the button! \r\n    function press() {\r\n        ButtonPress(msg.sender, now, (now - lastPressed)%256);\r\n        lastPressed = now;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022lastPressed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022press\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022presser\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022pressTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022score\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ButtonPress\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"TheButton","CompilerVersion":"v0.4.11\u002Bcommit.68ef5810","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://6a677c3801cf51407f57f7cd20d15a1936d52d93c06de7f4e5a318f300cd55f3"}]