[{"SourceCode":"pragma solidity ^0.5.1;\r\n\r\ncontract SimpleOracle {\r\n\r\n    mapping(uint256 =\u003E uint8) public sensors_status;\r\n\r\n    function receiveResult(bytes32 id, bytes calldata b) external {\r\n        \r\n        //This Oracle does not check msg.sender. For testing purposes only.\r\n        \r\n        uint256 last_sensor_id;\r\n        uint8 last_sensor_status;\r\n        last_sensor_id = 0;\r\n        \r\n        uint x = uint8(b[1]); uint r = x/16; uint s = x%16; uint c = r*10\u002Bs;\r\n        last_sensor_id \u002B= c*1000000;\r\n            \r\n            \r\n        x = uint8(b[2]); r = x/16; s = x%16; c = r*10\u002Bs;\r\n        last_sensor_id \u002B= c*10000;\r\n            \r\n        x = uint8(b[3]); r = x/16; s = x%16; c = r*10\u002Bs;\r\n        last_sensor_id \u002B= c*100;\r\n            \r\n        x = uint8(b[4]); r = x/16; s = x%16; c = r*10\u002Bs;\r\n        last_sensor_id \u002B= c;\r\n        \r\n        last_sensor_status = uint8(b[5]);\r\n        sensors_status[last_sensor_id] = last_sensor_status;\r\n        \r\n    }\r\n\r\n \r\n  \r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022sensors_status\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022receiveResult\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"SimpleOracle","CompilerVersion":"v0.5.1\u002Bcommit.c8a2cb62","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://051f87c4f37be0cff7149cf991c0d834b2c5c89335eb3a43c21af76d3073c884"}]