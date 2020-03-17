[{"SourceCode":"// hevm: flattened sources of /nix/store/8xb41r4qd0cjb63wcrxf1qmfg88p0961-dss-6fd7de0/src/dai.sol\r\npragma solidity =0.5.12;\r\n\r\n////// /nix/store/8xb41r4qd0cjb63wcrxf1qmfg88p0961-dss-6fd7de0/src/lib.sol\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n// GNU General Public License for more details.\r\n\r\n// You should have received a copy of the GNU General Public License\r\n// along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\r\n\r\n/* pragma solidity 0.5.12; */\r\n\r\ncontract LibNote {\r\n    event LogNote(\r\n        bytes4   indexed  sig,\r\n        address  indexed  usr,\r\n        bytes32  indexed  arg1,\r\n        bytes32  indexed  arg2,\r\n        bytes             data\r\n    ) anonymous;\r\n\r\n    modifier note {\r\n        _;\r\n        assembly {\r\n            // log an \u0027anonymous\u0027 event with a constant 6 words of calldata\r\n            // and four indexed topics: selector, caller, arg1 and arg2\r\n            let mark := msize                         // end of memory ensures zero\r\n            mstore(0x40, add(mark, 288))              // update free memory pointer\r\n            mstore(mark, 0x20)                        // bytes type data offset\r\n            mstore(add(mark, 0x20), 224)              // bytes size (padded)\r\n            calldatacopy(add(mark, 0x40), 0, 224)     // bytes payload\r\n            log4(mark, 288,                           // calldata\r\n                 shl(224, shr(224, calldataload(0))), // msg.sig\r\n                 caller,                              // msg.sender\r\n                 calldataload(4),                     // arg1\r\n                 calldataload(36)                     // arg2\r\n                )\r\n        }\r\n    }\r\n}\r\n\r\n////// /nix/store/8xb41r4qd0cjb63wcrxf1qmfg88p0961-dss-6fd7de0/src/dai.sol\r\n// Copyright (C) 2017, 2018, 2019 dbrock, rain, mrchico\r\n\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU Affero General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n//\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n// GNU Affero General Public License for more details.\r\n//\r\n// You should have received a copy of the GNU Affero General Public License\r\n// along with this program.  If not, see \u003Chttps://www.gnu.org/licenses/\u003E.\r\n\r\n/* pragma solidity 0.5.12; */\r\n\r\n/* import \u0022./lib.sol\u0022; */\r\n\r\ncontract Dai is LibNote {\r\n    // --- Auth ---\r\n    mapping (address =\u003E uint) public wards;\r\n    function rely(address guy) external note auth { wards[guy] = 1; }\r\n    function deny(address guy) external note auth { wards[guy] = 0; }\r\n    modifier auth {\r\n        require(wards[msg.sender] == 1, \u0022Dai/not-authorized\u0022);\r\n        _;\r\n    }\r\n\r\n    // --- ERC20 Data ---\r\n    string  public constant name     = \u0022Dai Stablecoin\u0022;\r\n    string  public constant symbol   = \u0022DAI\u0022;\r\n    string  public constant version  = \u00221\u0022;\r\n    uint8   public constant decimals = 18;\r\n    uint256 public totalSupply;\r\n\r\n    mapping (address =\u003E uint)                      public balanceOf;\r\n    mapping (address =\u003E mapping (address =\u003E uint)) public allowance;\r\n    mapping (address =\u003E uint)                      public nonces;\r\n\r\n    event Approval(address indexed src, address indexed guy, uint wad);\r\n    event Transfer(address indexed src, address indexed dst, uint wad);\r\n\r\n    // --- Math ---\r\n    function add(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x \u002B y) \u003E= x);\r\n    }\r\n    function sub(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x - y) \u003C= x);\r\n    }\r\n\r\n    // --- EIP712 niceties ---\r\n    bytes32 public DOMAIN_SEPARATOR;\r\n    // bytes32 public constant PERMIT_TYPEHASH = keccak256(\u0022Permit(address holder,address spender,uint256 nonce,uint256 expiry,bool allowed)\u0022);\r\n    bytes32 public constant PERMIT_TYPEHASH = 0xea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb;\r\n\r\n    constructor(uint256 chainId_) public {\r\n        wards[msg.sender] = 1;\r\n        DOMAIN_SEPARATOR = keccak256(abi.encode(\r\n            keccak256(\u0022EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)\u0022),\r\n            keccak256(bytes(name)),\r\n            keccak256(bytes(version)),\r\n            chainId_,\r\n            address(this)\r\n        ));\r\n    }\r\n\r\n    // --- Token ---\r\n    function transfer(address dst, uint wad) external returns (bool) {\r\n        return transferFrom(msg.sender, dst, wad);\r\n    }\r\n    function transferFrom(address src, address dst, uint wad)\r\n        public returns (bool)\r\n    {\r\n        require(balanceOf[src] \u003E= wad, \u0022Dai/insufficient-balance\u0022);\r\n        if (src != msg.sender \u0026\u0026 allowance[src][msg.sender] != uint(-1)) {\r\n            require(allowance[src][msg.sender] \u003E= wad, \u0022Dai/insufficient-allowance\u0022);\r\n            allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);\r\n        }\r\n        balanceOf[src] = sub(balanceOf[src], wad);\r\n        balanceOf[dst] = add(balanceOf[dst], wad);\r\n        emit Transfer(src, dst, wad);\r\n        return true;\r\n    }\r\n    function mint(address usr, uint wad) external auth {\r\n        balanceOf[usr] = add(balanceOf[usr], wad);\r\n        totalSupply    = add(totalSupply, wad);\r\n        emit Transfer(address(0), usr, wad);\r\n    }\r\n    function burn(address usr, uint wad) external {\r\n        require(balanceOf[usr] \u003E= wad, \u0022Dai/insufficient-balance\u0022);\r\n        if (usr != msg.sender \u0026\u0026 allowance[usr][msg.sender] != uint(-1)) {\r\n            require(allowance[usr][msg.sender] \u003E= wad, \u0022Dai/insufficient-allowance\u0022);\r\n            allowance[usr][msg.sender] = sub(allowance[usr][msg.sender], wad);\r\n        }\r\n        balanceOf[usr] = sub(balanceOf[usr], wad);\r\n        totalSupply    = sub(totalSupply, wad);\r\n        emit Transfer(usr, address(0), wad);\r\n    }\r\n    function approve(address usr, uint wad) external returns (bool) {\r\n        allowance[msg.sender][usr] = wad;\r\n        emit Approval(msg.sender, usr, wad);\r\n        return true;\r\n    }\r\n\r\n    // --- Alias ---\r\n    function push(address usr, uint wad) external {\r\n        transferFrom(msg.sender, usr, wad);\r\n    }\r\n    function pull(address usr, uint wad) external {\r\n        transferFrom(usr, msg.sender, wad);\r\n    }\r\n    function move(address src, address dst, uint wad) external {\r\n        transferFrom(src, dst, wad);\r\n    }\r\n\r\n    // --- Approve by signature ---\r\n    function permit(address holder, address spender, uint256 nonce, uint256 expiry,\r\n                    bool allowed, uint8 v, bytes32 r, bytes32 s) external\r\n    {\r\n        bytes32 digest =\r\n            keccak256(abi.encodePacked(\r\n                \u0022\\x19\\x01\u0022,\r\n                DOMAIN_SEPARATOR,\r\n                keccak256(abi.encode(PERMIT_TYPEHASH,\r\n                                     holder,\r\n                                     spender,\r\n                                     nonce,\r\n                                     expiry,\r\n                                     allowed))\r\n        ));\r\n\r\n        require(holder != address(0), \u0022Dai/invalid-address-0\u0022);\r\n        require(holder == ecrecover(digest, v, r, s), \u0022Dai/invalid-permit\u0022);\r\n        require(expiry == 0 || now \u003C= expiry, \u0022Dai/permit-expired\u0022);\r\n        require(nonce == nonces[holder]\u002B\u002B, \u0022Dai/invalid-nonce\u0022);\r\n        uint wad = allowed ? uint(-1) : 0;\r\n        allowance[holder][spender] = wad;\r\n        emit Approval(holder, spender, wad);\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022chainId_\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022guy\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:true,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes4\u0022,\u0022name\u0022:\u0022sig\u0022,\u0022type\u0022:\u0022bytes4\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022arg1\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022arg2\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022LogNote\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022DOMAIN_SEPARATOR\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022PERMIT_TYPEHASH\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022guy\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022deny\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022mint\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022move\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022nonces\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022holder\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022expiry\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022allowed\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022v\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022r\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022s\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022permit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022pull\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022push\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022guy\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022rely\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022version\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022wards\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"Dai","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"0000000000000000000000000000000000000000000000000000000000000001","Library":"","SwarmSource":"bzzr://c0ae2c29860c0a59d5586a579abbcddfe4bcef0524a87301425cbc58c3e94e31"}]