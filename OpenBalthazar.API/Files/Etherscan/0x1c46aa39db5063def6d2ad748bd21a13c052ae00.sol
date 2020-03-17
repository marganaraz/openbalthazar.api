[{"SourceCode":"// hevm: flattened sources of src/CdcAuthority.sol\npragma solidity =0.5.11 \u003E0.4.13 \u003E0.4.20 \u003E=0.4.23 \u003E=0.5.0 \u003C0.6.0 \u003E=0.5.5 \u003C0.6.0 \u003E=0.5.11 \u003C0.6.0;\n\n////// lib/ds-auth/src/auth.sol\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\n\n/* pragma solidity \u003E=0.4.23; */\n\ncontract DSAuthority {\n    function canCall(\n        address src, address dst, bytes4 sig\n    ) public view returns (bool);\n}\n\ncontract DSAuthEvents {\n    event LogSetAuthority (address indexed authority);\n    event LogSetOwner     (address indexed owner);\n}\n\ncontract DSAuth is DSAuthEvents {\n    DSAuthority  public  authority;\n    address      public  owner;\n\n    constructor() public {\n        owner = msg.sender;\n        emit LogSetOwner(msg.sender);\n    }\n\n    function setOwner(address owner_)\n        public\n        auth\n    {\n        owner = owner_;\n        emit LogSetOwner(owner);\n    }\n\n    function setAuthority(DSAuthority authority_)\n        public\n        auth\n    {\n        authority = authority_;\n        emit LogSetAuthority(address(authority));\n    }\n\n    modifier auth {\n        require(isAuthorized(msg.sender, msg.sig), \u0022ds-auth-unauthorized\u0022);\n        _;\n    }\n\n    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {\n        if (src == address(this)) {\n            return true;\n        } else if (src == owner) {\n            return true;\n        } else if (authority == DSAuthority(0)) {\n            return false;\n        } else {\n            return authority.canCall(src, address(this), sig);\n        }\n    }\n}\n\n////// lib/ds-guard/src/guard.sol\n// guard.sol -- simple whitelist implementation of DSAuthority\n\n// Copyright (C) 2017  DappHub, LLC\n\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\n\n/* pragma solidity \u003E=0.4.23; */\n\n/* import \u0022ds-auth/auth.sol\u0022; */\n\ncontract DSGuardEvents {\n    event LogPermit(\n        bytes32 indexed src,\n        bytes32 indexed dst,\n        bytes32 indexed sig\n    );\n\n    event LogForbid(\n        bytes32 indexed src,\n        bytes32 indexed dst,\n        bytes32 indexed sig\n    );\n}\n\ncontract DSGuard is DSAuth, DSAuthority, DSGuardEvents {\n    bytes32 constant public ANY = bytes32(uint(-1));\n\n    mapping (bytes32 =\u003E mapping (bytes32 =\u003E mapping (bytes32 =\u003E bool))) acl;\n\n    function canCall(\n        address src_, address dst_, bytes4 sig\n    ) public view returns (bool) {\n        bytes32 src = bytes32(bytes20(src_));\n        bytes32 dst = bytes32(bytes20(dst_));\n\n        return acl[src][dst][sig]\n            || acl[src][dst][ANY]\n            || acl[src][ANY][sig]\n            || acl[src][ANY][ANY]\n            || acl[ANY][dst][sig]\n            || acl[ANY][dst][ANY]\n            || acl[ANY][ANY][sig]\n            || acl[ANY][ANY][ANY];\n    }\n\n    function permit(bytes32 src, bytes32 dst, bytes32 sig) public auth {\n        acl[src][dst][sig] = true;\n        emit LogPermit(src, dst, sig);\n    }\n\n    function forbid(bytes32 src, bytes32 dst, bytes32 sig) public auth {\n        acl[src][dst][sig] = false;\n        emit LogForbid(src, dst, sig);\n    }\n\n    function permit(address src, address dst, bytes32 sig) public {\n        permit(bytes32(bytes20(src)), bytes32(bytes20(dst)), sig);\n    }\n    function forbid(address src, address dst, bytes32 sig) public {\n        forbid(bytes32(bytes20(src)), bytes32(bytes20(dst)), sig);\n    }\n\n}\n\ncontract DSGuardFactory {\n    mapping (address =\u003E bool)  public  isGuard;\n\n    function newGuard() public returns (DSGuard guard) {\n        guard = new DSGuard();\n        guard.setOwner(msg.sender);\n        isGuard[address(guard)] = true;\n    }\n}\n\n////// src/CdcAuthority.sol\n/* pragma solidity ^0.5.11; */\n\n/* import \u0022ds-guard/guard.sol\u0022; */\n\n\n/**\n * @title CdcExchangeAuthority\n * @dev Permissions whitelist with address-level granularity\n */\ncontract CdcAuthority is DSGuard {\n    bytes32 public name = \u0022Authority\u0022;\n}\n\n","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner_\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022sig\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022forbid\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022sig\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022forbid\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract DSAuthority\u0022,\u0022name\u0022:\u0022authority_\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setAuthority\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ANY\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022src_\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dst_\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes4\u0022,\u0022name\u0022:\u0022sig\u0022,\u0022type\u0022:\u0022bytes4\u0022}],\u0022name\u0022:\u0022canCall\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022authority\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract DSAuthority\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022sig\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022permit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022sig\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022permit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022sig\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022LogPermit\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022sig\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022LogForbid\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022authority\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogSetAuthority\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogSetOwner\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"CdcAuthority","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://a5b35be51f78fa749150fc9c1f6db45966fa6a80087b01c87d73617769dafdf2"}]