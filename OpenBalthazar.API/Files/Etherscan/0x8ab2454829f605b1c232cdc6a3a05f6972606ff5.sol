[{"SourceCode":"// hevm: flattened sources of src/price-feed.sol\r\npragma solidity \u003E=0.4.13 \u003C0.5.0 \u003E=0.4.23 \u003C0.5.0;\r\n\r\n////// lib/ds-thing/lib/ds-auth/src/auth.sol\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n// GNU General Public License for more details.\r\n\r\n// You should have received a copy of the GNU General Public License\r\n// along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\r\n\r\n/* pragma solidity ^0.4.23; */\r\n\r\ncontract DSAuthority {\r\n    function canCall(\r\n        address src, address dst, bytes4 sig\r\n    ) public view returns (bool);\r\n}\r\n\r\ncontract DSAuthEvents {\r\n    event LogSetAuthority (address indexed authority);\r\n    event LogSetOwner     (address indexed owner);\r\n}\r\n\r\ncontract DSAuth is DSAuthEvents {\r\n    DSAuthority  public  authority;\r\n    address      public  owner;\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n        emit LogSetOwner(msg.sender);\r\n    }\r\n\r\n    function setOwner(address owner_)\r\n        public\r\n        auth\r\n    {\r\n        owner = owner_;\r\n        emit LogSetOwner(owner);\r\n    }\r\n\r\n    function setAuthority(DSAuthority authority_)\r\n        public\r\n        auth\r\n    {\r\n        authority = authority_;\r\n        emit LogSetAuthority(authority);\r\n    }\r\n\r\n    modifier auth {\r\n        require(isAuthorized(msg.sender, msg.sig));\r\n        _;\r\n    }\r\n\r\n    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {\r\n        if (src == address(this)) {\r\n            return true;\r\n        } else if (src == owner) {\r\n            return true;\r\n        } else if (authority == DSAuthority(0)) {\r\n            return false;\r\n        } else {\r\n            return authority.canCall(src, this, sig);\r\n        }\r\n    }\r\n}\r\n\r\n////// lib/ds-thing/lib/ds-math/src/math.sol\r\n/// math.sol -- mixin for inline numerical wizardry\r\n\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n// GNU General Public License for more details.\r\n\r\n// You should have received a copy of the GNU General Public License\r\n// along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\r\n\r\n/* pragma solidity ^0.4.13; */\r\n\r\ncontract DSMath {\r\n    function add(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x \u002B y) \u003E= x);\r\n    }\r\n    function sub(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x - y) \u003C= x);\r\n    }\r\n    function mul(uint x, uint y) internal pure returns (uint z) {\r\n        require(y == 0 || (z = x * y) / y == x);\r\n    }\r\n\r\n    function min(uint x, uint y) internal pure returns (uint z) {\r\n        return x \u003C= y ? x : y;\r\n    }\r\n    function max(uint x, uint y) internal pure returns (uint z) {\r\n        return x \u003E= y ? x : y;\r\n    }\r\n    function imin(int x, int y) internal pure returns (int z) {\r\n        return x \u003C= y ? x : y;\r\n    }\r\n    function imax(int x, int y) internal pure returns (int z) {\r\n        return x \u003E= y ? x : y;\r\n    }\r\n\r\n    uint constant WAD = 10 ** 18;\r\n    uint constant RAY = 10 ** 27;\r\n\r\n    function wmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), WAD / 2) / WAD;\r\n    }\r\n    function rmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), RAY / 2) / RAY;\r\n    }\r\n    function wdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, WAD), y / 2) / y;\r\n    }\r\n    function rdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, RAY), y / 2) / y;\r\n    }\r\n\r\n    // This famous algorithm is called \u0022exponentiation by squaring\u0022\r\n    // and calculates x^n with x as fixed-point and n as regular unsigned.\r\n    //\r\n    // It\u0027s O(log n), instead of O(n) for naive repeated multiplication.\r\n    //\r\n    // These facts are why it works:\r\n    //\r\n    //  If n is even, then x^n = (x^2)^(n/2).\r\n    //  If n is odd,  then x^n = x * x^(n-1),\r\n    //   and applying the equation for even x gives\r\n    //    x^n = x * (x^2)^((n-1) / 2).\r\n    //\r\n    //  Also, EVM division is flooring and\r\n    //    floor[(n-1) / 2] = floor[n / 2].\r\n    //\r\n    function rpow(uint x, uint n) internal pure returns (uint z) {\r\n        z = n % 2 != 0 ? x : RAY;\r\n\r\n        for (n /= 2; n != 0; n /= 2) {\r\n            x = rmul(x, x);\r\n\r\n            if (n % 2 != 0) {\r\n                z = rmul(z, x);\r\n            }\r\n        }\r\n    }\r\n}\r\n\r\n////// lib/ds-thing/lib/ds-note/src/note.sol\r\n/// note.sol -- the \u0060note\u0027 modifier, for logging calls as events\r\n\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n// GNU General Public License for more details.\r\n\r\n// You should have received a copy of the GNU General Public License\r\n// along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\r\n\r\n/* pragma solidity ^0.4.23; */\r\n\r\ncontract DSNote {\r\n    event LogNote(\r\n        bytes4   indexed  sig,\r\n        address  indexed  guy,\r\n        bytes32  indexed  foo,\r\n        bytes32  indexed  bar,\r\n        uint              wad,\r\n        bytes             fax\r\n    ) anonymous;\r\n\r\n    modifier note {\r\n        bytes32 foo;\r\n        bytes32 bar;\r\n\r\n        assembly {\r\n            foo := calldataload(4)\r\n            bar := calldataload(36)\r\n        }\r\n\r\n        emit LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);\r\n\r\n        _;\r\n    }\r\n}\r\n\r\n////// lib/ds-thing/src/thing.sol\r\n// thing.sol - \u0060auth\u0060 with handy mixins. your things should be DSThings\r\n\r\n// Copyright (C) 2017  DappHub, LLC\r\n\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n// GNU General Public License for more details.\r\n\r\n// You should have received a copy of the GNU General Public License\r\n// along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\r\n\r\n/* pragma solidity ^0.4.23; */\r\n\r\n/* import \u0027ds-auth/auth.sol\u0027; */\r\n/* import \u0027ds-note/note.sol\u0027; */\r\n/* import \u0027ds-math/math.sol\u0027; */\r\n\r\ncontract DSThing is DSAuth, DSNote, DSMath {\r\n\r\n    function S(string s) internal pure returns (bytes4) {\r\n        return bytes4(keccak256(abi.encodePacked(s)));\r\n    }\r\n\r\n}\r\n\r\n////// src/price-feed.sol\r\n/* pragma solidity ^0.4.23; */\r\n\r\n/* import \u0022ds-thing/thing.sol\u0022; */\r\n\r\ninterface Medianizer {\r\n    function poke() external;\r\n}\r\n\r\ncontract PriceFeed is DSThing {\r\n\r\n    uint128       val;\r\n    uint32 public zzz;\r\n\r\n    function peek() external view returns (bytes32,bool)\r\n    {\r\n        return (bytes32(val), now \u003C zzz);\r\n    }\r\n\r\n    function read() external view returns (bytes32)\r\n    {\r\n        require(now \u003C zzz);\r\n        return bytes32(val);\r\n    }\r\n\r\n    function poke(uint128 val_, uint32 zzz_) external note auth\r\n    {\r\n        val = val_;\r\n        zzz = zzz_;\r\n    }\r\n\r\n    function post(uint128 val_, uint32 zzz_, Medianizer med_) external note auth\r\n    {\r\n        val = val_;\r\n        zzz = zzz_;\r\n        med_.poke();\r\n    }\r\n\r\n    function void() external note auth\r\n    {\r\n        zzz = 0;\r\n    }\r\n\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner_\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022val_\u0022,\u0022type\u0022:\u0022uint128\u0022},{\u0022name\u0022:\u0022zzz_\u0022,\u0022type\u0022:\u0022uint32\u0022}],\u0022name\u0022:\u0022poke\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022read\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022peek\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022val_\u0022,\u0022type\u0022:\u0022uint128\u0022},{\u0022name\u0022:\u0022zzz_\u0022,\u0022type\u0022:\u0022uint32\u0022},{\u0022name\u0022:\u0022med_\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022post\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022authority_\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setAuthority\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022zzz\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022void\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022authority\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:true,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022sig\u0022,\u0022type\u0022:\u0022bytes4\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022guy\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022foo\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022bar\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022fax\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022LogNote\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022authority\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogSetAuthority\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogSetOwner\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"PriceFeed","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://985ab51351555c97564300998024b542e3346e692012621526dca38f038e73e8"}]