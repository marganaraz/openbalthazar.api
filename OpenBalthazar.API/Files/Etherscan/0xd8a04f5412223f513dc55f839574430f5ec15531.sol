[{"SourceCode":"// hevm: flattened sources of /nix/store/8xb41r4qd0cjb63wcrxf1qmfg88p0961-dss-6fd7de0/src/flip.sol\r\npragma solidity =0.5.12;\r\n\r\n////// /nix/store/8xb41r4qd0cjb63wcrxf1qmfg88p0961-dss-6fd7de0/src/lib.sol\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n// GNU General Public License for more details.\r\n\r\n// You should have received a copy of the GNU General Public License\r\n// along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\r\n\r\n/* pragma solidity 0.5.12; */\r\n\r\ncontract LibNote {\r\n    event LogNote(\r\n        bytes4   indexed  sig,\r\n        address  indexed  usr,\r\n        bytes32  indexed  arg1,\r\n        bytes32  indexed  arg2,\r\n        bytes             data\r\n    ) anonymous;\r\n\r\n    modifier note {\r\n        _;\r\n        assembly {\r\n            // log an \u0027anonymous\u0027 event with a constant 6 words of calldata\r\n            // and four indexed topics: selector, caller, arg1 and arg2\r\n            let mark := msize                         // end of memory ensures zero\r\n            mstore(0x40, add(mark, 288))              // update free memory pointer\r\n            mstore(mark, 0x20)                        // bytes type data offset\r\n            mstore(add(mark, 0x20), 224)              // bytes size (padded)\r\n            calldatacopy(add(mark, 0x40), 0, 224)     // bytes payload\r\n            log4(mark, 288,                           // calldata\r\n                 shl(224, shr(224, calldataload(0))), // msg.sig\r\n                 caller,                              // msg.sender\r\n                 calldataload(4),                     // arg1\r\n                 calldataload(36)                     // arg2\r\n                )\r\n        }\r\n    }\r\n}\r\n\r\n////// /nix/store/8xb41r4qd0cjb63wcrxf1qmfg88p0961-dss-6fd7de0/src/flip.sol\r\n/// flip.sol -- Collateral auction\r\n\r\n// Copyright (C) 2018 Rain \u003Crainbreak@riseup.net\u003E\r\n//\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU Affero General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n//\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n// GNU Affero General Public License for more details.\r\n//\r\n// You should have received a copy of the GNU Affero General Public License\r\n// along with this program.  If not, see \u003Chttps://www.gnu.org/licenses/\u003E.\r\n\r\n/* pragma solidity 0.5.12; */\r\n\r\n/* import \u0022./lib.sol\u0022; */\r\n\r\ncontract VatLike {\r\n    function move(address,address,uint) external;\r\n    function flux(bytes32,address,address,uint) external;\r\n}\r\n\r\n/*\r\n   This thing lets you flip some gems for a given amount of dai.\r\n   Once the given amount of dai is raised, gems are forgone instead.\r\n\r\n - \u0060lot\u0060 gems for sale\r\n - \u0060tab\u0060 total dai wanted\r\n - \u0060bid\u0060 dai paid\r\n - \u0060gal\u0060 receives dai income\r\n - \u0060usr\u0060 receives gem forgone\r\n - \u0060ttl\u0060 single bid lifetime\r\n - \u0060beg\u0060 minimum bid increase\r\n - \u0060end\u0060 max auction duration\r\n*/\r\n\r\ncontract Flipper is LibNote {\r\n    // --- Auth ---\r\n    mapping (address =\u003E uint) public wards;\r\n    function rely(address usr) external note auth { wards[usr] = 1; }\r\n    function deny(address usr) external note auth { wards[usr] = 0; }\r\n    modifier auth {\r\n        require(wards[msg.sender] == 1, \u0022Flipper/not-authorized\u0022);\r\n        _;\r\n    }\r\n\r\n    // --- Data ---\r\n    struct Bid {\r\n        uint256 bid;\r\n        uint256 lot;\r\n        address guy;  // high bidder\r\n        uint48  tic;  // expiry time\r\n        uint48  end;\r\n        address usr;\r\n        address gal;\r\n        uint256 tab;\r\n    }\r\n\r\n    mapping (uint =\u003E Bid) public bids;\r\n\r\n    VatLike public   vat;\r\n    bytes32 public   ilk;\r\n\r\n    uint256 constant ONE = 1.00E18;\r\n    uint256 public   beg = 1.05E18;  // 5% minimum bid increase\r\n    uint48  public   ttl = 3 hours;  // 3 hours bid duration\r\n    uint48  public   tau = 2 days;   // 2 days total auction length\r\n    uint256 public kicks = 0;\r\n\r\n    // --- Events ---\r\n    event Kick(\r\n      uint256 id,\r\n      uint256 lot,\r\n      uint256 bid,\r\n      uint256 tab,\r\n      address indexed usr,\r\n      address indexed gal\r\n    );\r\n\r\n    // --- Init ---\r\n    constructor(address vat_, bytes32 ilk_) public {\r\n        vat = VatLike(vat_);\r\n        ilk = ilk_;\r\n        wards[msg.sender] = 1;\r\n    }\r\n\r\n    // --- Math ---\r\n    function add(uint48 x, uint48 y) internal pure returns (uint48 z) {\r\n        require((z = x \u002B y) \u003E= x);\r\n    }\r\n    function mul(uint x, uint y) internal pure returns (uint z) {\r\n        require(y == 0 || (z = x * y) / y == x);\r\n    }\r\n\r\n    // --- Admin ---\r\n    function file(bytes32 what, uint data) external note auth {\r\n        if (what == \u0022beg\u0022) beg = data;\r\n        else if (what == \u0022ttl\u0022) ttl = uint48(data);\r\n        else if (what == \u0022tau\u0022) tau = uint48(data);\r\n        else revert(\u0022Flipper/file-unrecognized-param\u0022);\r\n    }\r\n\r\n    // --- Auction ---\r\n    function kick(address usr, address gal, uint tab, uint lot, uint bid)\r\n        public auth returns (uint id)\r\n    {\r\n        require(kicks \u003C uint(-1), \u0022Flipper/overflow\u0022);\r\n        id = \u002B\u002Bkicks;\r\n\r\n        bids[id].bid = bid;\r\n        bids[id].lot = lot;\r\n        bids[id].guy = msg.sender; // configurable??\r\n        bids[id].end = add(uint48(now), tau);\r\n        bids[id].usr = usr;\r\n        bids[id].gal = gal;\r\n        bids[id].tab = tab;\r\n\r\n        vat.flux(ilk, msg.sender, address(this), lot);\r\n\r\n        emit Kick(id, lot, bid, tab, usr, gal);\r\n    }\r\n    function tick(uint id) external note {\r\n        require(bids[id].end \u003C now, \u0022Flipper/not-finished\u0022);\r\n        require(bids[id].tic == 0, \u0022Flipper/bid-already-placed\u0022);\r\n        bids[id].end = add(uint48(now), tau);\r\n    }\r\n    function tend(uint id, uint lot, uint bid) external note {\r\n        require(bids[id].guy != address(0), \u0022Flipper/guy-not-set\u0022);\r\n        require(bids[id].tic \u003E now || bids[id].tic == 0, \u0022Flipper/already-finished-tic\u0022);\r\n        require(bids[id].end \u003E now, \u0022Flipper/already-finished-end\u0022);\r\n\r\n        require(lot == bids[id].lot, \u0022Flipper/lot-not-matching\u0022);\r\n        require(bid \u003C= bids[id].tab, \u0022Flipper/higher-than-tab\u0022);\r\n        require(bid \u003E  bids[id].bid, \u0022Flipper/bid-not-higher\u0022);\r\n        require(mul(bid, ONE) \u003E= mul(beg, bids[id].bid) || bid == bids[id].tab, \u0022Flipper/insufficient-increase\u0022);\r\n\r\n        vat.move(msg.sender, bids[id].guy, bids[id].bid);\r\n        vat.move(msg.sender, bids[id].gal, bid - bids[id].bid);\r\n\r\n        bids[id].guy = msg.sender;\r\n        bids[id].bid = bid;\r\n        bids[id].tic = add(uint48(now), ttl);\r\n    }\r\n    function dent(uint id, uint lot, uint bid) external note {\r\n        require(bids[id].guy != address(0), \u0022Flipper/guy-not-set\u0022);\r\n        require(bids[id].tic \u003E now || bids[id].tic == 0, \u0022Flipper/already-finished-tic\u0022);\r\n        require(bids[id].end \u003E now, \u0022Flipper/already-finished-end\u0022);\r\n\r\n        require(bid == bids[id].bid, \u0022Flipper/not-matching-bid\u0022);\r\n        require(bid == bids[id].tab, \u0022Flipper/tend-not-finished\u0022);\r\n        require(lot \u003C bids[id].lot, \u0022Flipper/lot-not-lower\u0022);\r\n        require(mul(beg, lot) \u003C= mul(bids[id].lot, ONE), \u0022Flipper/insufficient-decrease\u0022);\r\n\r\n        vat.move(msg.sender, bids[id].guy, bid);\r\n        vat.flux(ilk, address(this), bids[id].usr, bids[id].lot - lot);\r\n\r\n        bids[id].guy = msg.sender;\r\n        bids[id].lot = lot;\r\n        bids[id].tic = add(uint48(now), ttl);\r\n    }\r\n    function deal(uint id) external note {\r\n        require(bids[id].tic != 0 \u0026\u0026 (bids[id].tic \u003C now || bids[id].end \u003C now), \u0022Flipper/not-finished\u0022);\r\n        vat.flux(ilk, address(this), bids[id].guy, bids[id].lot);\r\n        delete bids[id];\r\n    }\r\n\r\n    function yank(uint id) external note auth {\r\n        require(bids[id].guy != address(0), \u0022Flipper/guy-not-set\u0022);\r\n        require(bids[id].bid \u003C bids[id].tab, \u0022Flipper/already-dent-phase\u0022);\r\n        vat.flux(ilk, address(this), msg.sender, bids[id].lot);\r\n        vat.move(msg.sender, bids[id].guy, bids[id].bid);\r\n        delete bids[id];\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022vat_\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022ilk_\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022lot\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022bid\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tab\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022gal\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Kick\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:true,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes4\u0022,\u0022name\u0022:\u0022sig\u0022,\u0022type\u0022:\u0022bytes4\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022arg1\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022arg2\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022LogNote\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022beg\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022bids\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022bid\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022lot\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022guy\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint48\u0022,\u0022name\u0022:\u0022tic\u0022,\u0022type\u0022:\u0022uint48\u0022},{\u0022internalType\u0022:\u0022uint48\u0022,\u0022name\u0022:\u0022end\u0022,\u0022type\u0022:\u0022uint48\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022gal\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tab\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022deal\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022lot\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022bid\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022dent\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022deny\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022what\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022file\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ilk\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022gal\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tab\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022lot\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022bid\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022kick\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022kicks\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022rely\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tau\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint48\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint48\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022lot\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022bid\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022tend\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022tick\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ttl\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint48\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint48\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022vat\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract VatLike\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022wards\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022yank\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"Flipper","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"00000000000000000000000035d1b3f3d7966a1dfe207aa4514c12a259a0492b4554482d41000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://4dc61355cd6fa8e35aaa1844cbf949745778e1cd4d9194a4628fcd2253ddbcfc"}]