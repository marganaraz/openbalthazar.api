[{"SourceCode":"/// MkrAuthority -- custom authority for MKR token access control\r\n\r\n// Copyright (C) 2019 Maker Ecosystem Growth Holdings, INC.\r\n//\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU Affero General Public License as published\r\n// by the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n//\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n// GNU Affero General Public License for more details.\r\n//\r\n// You should have received a copy of the GNU Affero General Public License\r\n// along with this program.  If not, see \u003Chttps://www.gnu.org/licenses/\u003E.\r\n\r\npragma solidity ^0.5.12;\r\n\r\ncontract MkrAuthority {\r\n  address public root;\r\n  modifier sudo { require(msg.sender == root); _; }\r\n  event LogSetRoot(address indexed newRoot);\r\n  function setRoot(address usr) public sudo {\r\n    root = usr;\r\n    emit LogSetRoot(usr);\r\n  }\r\n\r\n  mapping (address =\u003E uint) public wards;\r\n  event LogRely(address indexed usr);\r\n  function rely(address usr) public sudo { wards[usr] = 1; emit LogRely(usr); }\r\n  event LogDeny(address indexed usr);\r\n  function deny(address usr) public sudo { wards[usr] = 0; emit LogDeny(usr); }\r\n\r\n  constructor() public {\r\n    root = msg.sender;\r\n  }\r\n\r\n  // bytes4(keccak256(abi.encodePacked(\u0027burn(uint256)\u0027)))\r\n  bytes4 constant burn = bytes4(0x42966c68);\r\n  // bytes4(keccak256(abi.encodePacked(\u0027burn(address,uint256)\u0027)))\r\n  bytes4 constant burnFrom = bytes4(0x9dc29fac);\r\n  // bytes4(keccak256(abi.encodePacked(\u0027mint(address,uint256)\u0027)))\r\n  bytes4 constant mint = bytes4(0x40c10f19);\r\n\r\n  function canCall(address src, address, bytes4 sig)\r\n      public view returns (bool)\r\n  {\r\n    if (sig == burn || sig == burnFrom || src == root) {\r\n      return true;\r\n    } else if (sig == mint) {\r\n      return (wards[src] == 1);\r\n    } else {\r\n      return false;\r\n    }\r\n  }\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogDeny\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogRely\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newRoot\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogSetRoot\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes4\u0022,\u0022name\u0022:\u0022sig\u0022,\u0022type\u0022:\u0022bytes4\u0022}],\u0022name\u0022:\u0022canCall\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022deny\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022rely\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022root\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setRoot\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022wards\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"MkrAuthority","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://61124948b0428630348ffa52dd3034f60a18071d8d0e96d44fbe674c8e8625a1"}]