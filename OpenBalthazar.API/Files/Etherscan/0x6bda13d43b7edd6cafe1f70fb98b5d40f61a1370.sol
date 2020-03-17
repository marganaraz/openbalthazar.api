[{"SourceCode":"// hevm: flattened sources of /nix/store/lyn7sdbk7x628mry99f0sc04hii39fsp-dss-deploy-pause-proxy-actions-8e594a2/src/DssDeployPauseProxyActions.sol\r\npragma solidity =0.5.12;\r\n\r\n////// /nix/store/lyn7sdbk7x628mry99f0sc04hii39fsp-dss-deploy-pause-proxy-actions-8e594a2/src/DssDeployPauseProxyActions.sol\r\n/// DssDeployPauseProxyActions.sol\r\n\r\n// Copyright (C) 2018 Gonzalo Balabasquer \u003Cgbalabasquer@gmail.com\u003E\r\n//\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU Affero General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n//\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n// GNU Affero General Public License for more details.\r\n//\r\n// You should have received a copy of the GNU Affero General Public License\r\n// along with this program.  If not, see \u003Chttps://www.gnu.org/licenses/\u003E.\r\n\r\n/* pragma solidity 0.5.12; */\r\n\r\ncontract PauseLike {\r\n    function plot(address, bytes32, bytes memory, uint) public;\r\n    function exec(address, bytes32, bytes memory, uint) public;\r\n}\r\n\r\ncontract DssDeployPauseProxyActions {\r\n    function file(address pause, address actions, address who, bytes32 what, uint data) external {\r\n        bytes32 tag;\r\n        assembly { tag := extcodehash(actions) }\r\n        PauseLike(pause).plot(\r\n            address(actions),\r\n            tag,\r\n            abi.encodeWithSignature(\u0022file(address,bytes32,uint256)\u0022, who, what, data),\r\n            now\r\n        );\r\n        PauseLike(pause).exec(\r\n            address(actions),\r\n            tag,\r\n            abi.encodeWithSignature(\u0022file(address,bytes32,uint256)\u0022, who, what, data),\r\n            now\r\n        );\r\n    }\r\n\r\n    function file(address pause, address actions, address who, bytes32 ilk, bytes32 what, uint data) external {\r\n        bytes32 tag;\r\n        assembly { tag := extcodehash(actions) }\r\n        PauseLike(pause).plot(\r\n            address(actions),\r\n            tag,\r\n            abi.encodeWithSignature(\u0022file(address,bytes32,bytes32,uint256)\u0022, who, ilk, what, data),\r\n            now\r\n        );\r\n        PauseLike(pause).exec(\r\n            address(actions),\r\n            tag,\r\n            abi.encodeWithSignature(\u0022file(address,bytes32,bytes32,uint256)\u0022, who, ilk, what, data),\r\n            now\r\n        );\r\n    }\r\n\r\n    function file(address pause, address actions, address who, bytes32 ilk, bytes32 what, address data) external {\r\n        bytes32 tag;\r\n        assembly { tag := extcodehash(actions) }\r\n        PauseLike(pause).plot(\r\n            address(actions),\r\n            tag,\r\n            abi.encodeWithSignature(\u0022file(address,bytes32,bytes32,address)\u0022, who, ilk, what, data),\r\n            now\r\n        );\r\n        PauseLike(pause).exec(\r\n            address(actions),\r\n            tag,\r\n            abi.encodeWithSignature(\u0022file(address,bytes32,bytes32,address)\u0022, who, ilk, what, data),\r\n            now\r\n        );\r\n    }\r\n\r\n    function dripAndFile(address pause, address actions, address who, bytes32 what, uint data) external {\r\n        bytes32 tag;\r\n        assembly { tag := extcodehash(actions) }\r\n        PauseLike(pause).plot(\r\n            address(actions),\r\n            tag,\r\n            abi.encodeWithSignature(\u0022dripAndFile(address,bytes32,uint256)\u0022, who, what, data),\r\n            now\r\n        );\r\n        PauseLike(pause).exec(\r\n            address(actions),\r\n            tag,\r\n            abi.encodeWithSignature(\u0022dripAndFile(address,bytes32,uint256)\u0022, who, what, data),\r\n            now\r\n        );\r\n    }\r\n\r\n    function dripAndFile(address pause, address actions, address who, bytes32 ilk, bytes32 what, uint data) external {\r\n        bytes32 tag;\r\n        assembly { tag := extcodehash(actions) }\r\n        PauseLike(pause).plot(\r\n            address(actions),\r\n            tag,\r\n            abi.encodeWithSignature(\u0022dripAndFile(address,bytes32,bytes32,uint256)\u0022, who, ilk, what, data),\r\n            now\r\n        );\r\n        PauseLike(pause).exec(\r\n            address(actions),\r\n            tag,\r\n            abi.encodeWithSignature(\u0022dripAndFile(address,bytes32,bytes32,uint256)\u0022, who, ilk, what, data),\r\n            now\r\n        );\r\n    }\r\n\r\n    function setAuthorityAndDelay(address pause, address actions, address newAuthority, uint newDelay) external {\r\n        bytes32 tag;\r\n        assembly { tag := extcodehash(actions) }\r\n        PauseLike(pause).plot(\r\n            address(actions),\r\n            tag,\r\n            abi.encodeWithSignature(\u0022setAuthorityAndDelay(address,address,uint256)\u0022, pause, newAuthority, newDelay),\r\n            now\r\n        );\r\n        PauseLike(pause).exec(\r\n            address(actions),\r\n            tag,\r\n            abi.encodeWithSignature(\u0022setAuthorityAndDelay(address,address,uint256)\u0022, pause, newAuthority, newDelay),\r\n            now\r\n        );\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022pause\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022actions\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022ilk\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022what\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022dripAndFile\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022pause\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022actions\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022what\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022dripAndFile\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022pause\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022actions\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022ilk\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022what\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022file\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022pause\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022actions\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022what\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022file\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022pause\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022actions\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022ilk\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022what\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022file\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022pause\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022actions\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newAuthority\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022newDelay\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setAuthorityAndDelay\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"DssDeployPauseProxyActions","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://9ad1572dfda8c3288dfb1de5d839a5800bebf917737c3ed54530605a761567af"}]