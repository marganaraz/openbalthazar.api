[{"SourceCode":"// hevm: flattened sources of src/Wallet.sol\npragma solidity =0.5.11 \u003E0.4.13 \u003E0.4.20 \u003E=0.4.23 \u003E=0.5.0 \u003C0.6.0 \u003E=0.5.5 \u003C0.6.0 \u003E=0.5.11 \u003C0.6.0;\n\n////// lib/ds-auth/src/auth.sol\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\n\n/* pragma solidity \u003E=0.4.23; */\n\ncontract DSAuthority {\n    function canCall(\n        address src, address dst, bytes4 sig\n    ) public view returns (bool);\n}\n\ncontract DSAuthEvents {\n    event LogSetAuthority (address indexed authority);\n    event LogSetOwner     (address indexed owner);\n}\n\ncontract DSAuth is DSAuthEvents {\n    DSAuthority  public  authority;\n    address      public  owner;\n\n    constructor() public {\n        owner = msg.sender;\n        emit LogSetOwner(msg.sender);\n    }\n\n    function setOwner(address owner_)\n        public\n        auth\n    {\n        owner = owner_;\n        emit LogSetOwner(owner);\n    }\n\n    function setAuthority(DSAuthority authority_)\n        public\n        auth\n    {\n        authority = authority_;\n        emit LogSetAuthority(address(authority));\n    }\n\n    modifier auth {\n        require(isAuthorized(msg.sender, msg.sig), \u0022ds-auth-unauthorized\u0022);\n        _;\n    }\n\n    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {\n        if (src == address(this)) {\n            return true;\n        } else if (src == owner) {\n            return true;\n        } else if (authority == DSAuthority(0)) {\n            return false;\n        } else {\n            return authority.canCall(src, address(this), sig);\n        }\n    }\n}\n\n////// lib/ds-math/src/math.sol\n/// math.sol -- mixin for inline numerical wizardry\n\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\n\n/* pragma solidity \u003E0.4.13; */\n\ncontract DSMath {\n    function add(uint x, uint y) internal pure returns (uint z) {\n        require((z = x \u002B y) \u003E= x, \u0022ds-math-add-overflow\u0022);\n    }\n    function sub(uint x, uint y) internal pure returns (uint z) {\n        require((z = x - y) \u003C= x, \u0022ds-math-sub-underflow\u0022);\n    }\n    function mul(uint x, uint y) internal pure returns (uint z) {\n        require(y == 0 || (z = x * y) / y == x, \u0022ds-math-mul-overflow\u0022);\n    }\n\n    function min(uint x, uint y) internal pure returns (uint z) {\n        return x \u003C= y ? x : y;\n    }\n    function max(uint x, uint y) internal pure returns (uint z) {\n        return x \u003E= y ? x : y;\n    }\n    function imin(int x, int y) internal pure returns (int z) {\n        return x \u003C= y ? x : y;\n    }\n    function imax(int x, int y) internal pure returns (int z) {\n        return x \u003E= y ? x : y;\n    }\n\n    uint constant WAD = 10 ** 18;\n    uint constant RAY = 10 ** 27;\n\n    function wmul(uint x, uint y) internal pure returns (uint z) {\n        z = add(mul(x, y), WAD / 2) / WAD;\n    }\n    function rmul(uint x, uint y) internal pure returns (uint z) {\n        z = add(mul(x, y), RAY / 2) / RAY;\n    }\n    function wdiv(uint x, uint y) internal pure returns (uint z) {\n        z = add(mul(x, WAD), y / 2) / y;\n    }\n    function rdiv(uint x, uint y) internal pure returns (uint z) {\n        z = add(mul(x, RAY), y / 2) / y;\n    }\n\n    // This famous algorithm is called \u0022exponentiation by squaring\u0022\n    // and calculates x^n with x as fixed-point and n as regular unsigned.\n    //\n    // It\u0027s O(log n), instead of O(n) for naive repeated multiplication.\n    //\n    // These facts are why it works:\n    //\n    //  If n is even, then x^n = (x^2)^(n/2).\n    //  If n is odd,  then x^n = x * x^(n-1),\n    //   and applying the equation for even x gives\n    //    x^n = x * (x^2)^((n-1) / 2).\n    //\n    //  Also, EVM division is flooring and\n    //    floor[(n-1) / 2] = floor[n / 2].\n    //\n    function rpow(uint x, uint n) internal pure returns (uint z) {\n        z = n % 2 != 0 ? x : RAY;\n\n        for (n /= 2; n != 0; n /= 2) {\n            x = rmul(x, x);\n\n            if (n % 2 != 0) {\n                z = rmul(z, x);\n            }\n        }\n    }\n}\n\n////// lib/ds-note/src/note.sol\n/// note.sol -- the \u0060note\u0027 modifier, for logging calls as events\n\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\n\n/* pragma solidity \u003E=0.4.23; */\n\ncontract DSNote {\n    event LogNote(\n        bytes4   indexed  sig,\n        address  indexed  guy,\n        bytes32  indexed  foo,\n        bytes32  indexed  bar,\n        uint256           wad,\n        bytes             fax\n    ) anonymous;\n\n    modifier note {\n        bytes32 foo;\n        bytes32 bar;\n        uint256 wad;\n\n        assembly {\n            foo := calldataload(4)\n            bar := calldataload(36)\n            wad := callvalue\n        }\n\n        emit LogNote(msg.sig, msg.sender, foo, bar, wad, msg.data);\n\n        _;\n    }\n}\n\n////// lib/ds-stop/src/stop.sol\n/// stop.sol -- mixin for enable/disable functionality\n\n// Copyright (C) 2017  DappHub, LLC\n\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\n\n/* pragma solidity \u003E=0.4.23; */\n\n/* import \u0022ds-auth/auth.sol\u0022; */\n/* import \u0022ds-note/note.sol\u0022; */\n\ncontract DSStop is DSNote, DSAuth {\n    bool public stopped;\n\n    modifier stoppable {\n        require(!stopped, \u0022ds-stop-is-stopped\u0022);\n        _;\n    }\n    function stop() public auth note {\n        stopped = true;\n    }\n    function start() public auth note {\n        stopped = false;\n    }\n\n}\n\n////// lib/ds-token/lib/erc20/src/erc20.sol\n/// erc20.sol -- API for the ERC20 token standard\n\n// See \u003Chttps://github.com/ethereum/EIPs/issues/20\u003E.\n\n// This file likely does not meet the threshold of originality\n// required for copyright to apply.  As a result, this is free and\n// unencumbered software belonging to the public domain.\n\n/* pragma solidity \u003E0.4.20; */\n\ncontract ERC20Events {\n    event Approval(address indexed src, address indexed guy, uint wad);\n    event Transfer(address indexed src, address indexed dst, uint wad);\n}\n\ncontract ERC20 is ERC20Events {\n    function totalSupply() public view returns (uint);\n    function balanceOf(address guy) public view returns (uint);\n    function allowance(address src, address guy) public view returns (uint);\n\n    function approve(address guy, uint wad) public returns (bool);\n    function transfer(address dst, uint wad) public returns (bool);\n    function transferFrom(\n        address src, address dst, uint wad\n    ) public returns (bool);\n}\n\n////// lib/ds-token/src/base.sol\n/// base.sol -- basic ERC20 implementation\n\n// Copyright (C) 2015, 2016, 2017  DappHub, LLC\n\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\n\n/* pragma solidity \u003E=0.4.23; */\n\n/* import \u0022erc20/erc20.sol\u0022; */\n/* import \u0022ds-math/math.sol\u0022; */\n\ncontract DSTokenBase is ERC20, DSMath {\n    uint256                                            _supply;\n    mapping (address =\u003E uint256)                       _balances;\n    mapping (address =\u003E mapping (address =\u003E uint256))  _approvals;\n\n    constructor(uint supply) public {\n        _balances[msg.sender] = supply;\n        _supply = supply;\n    }\n\n    function totalSupply() public view returns (uint) {\n        return _supply;\n    }\n    function balanceOf(address src) public view returns (uint) {\n        return _balances[src];\n    }\n    function allowance(address src, address guy) public view returns (uint) {\n        return _approvals[src][guy];\n    }\n\n    function transfer(address dst, uint wad) public returns (bool) {\n        return transferFrom(msg.sender, dst, wad);\n    }\n\n    function transferFrom(address src, address dst, uint wad)\n        public\n        returns (bool)\n    {\n        if (src != msg.sender) {\n            require(_approvals[src][msg.sender] \u003E= wad, \u0022ds-token-insufficient-approval\u0022);\n            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);\n        }\n\n        require(_balances[src] \u003E= wad, \u0022ds-token-insufficient-balance\u0022);\n        _balances[src] = sub(_balances[src], wad);\n        _balances[dst] = add(_balances[dst], wad);\n\n        emit Transfer(src, dst, wad);\n\n        return true;\n    }\n\n    function approve(address guy, uint wad) public returns (bool) {\n        _approvals[msg.sender][guy] = wad;\n\n        emit Approval(msg.sender, guy, wad);\n\n        return true;\n    }\n}\n\n////// lib/ds-token/src/token.sol\n/// token.sol -- ERC20 implementation with minting and burning\n\n// Copyright (C) 2015, 2016, 2017  DappHub, LLC\n\n// This program is free software: you can redistribute it and/or modify\n// it under the terms of the GNU General Public License as published by\n// the Free Software Foundation, either version 3 of the License, or\n// (at your option) any later version.\n\n// This program is distributed in the hope that it will be useful,\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n// GNU General Public License for more details.\n\n// You should have received a copy of the GNU General Public License\n// along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\n\n/* pragma solidity \u003E=0.4.23; */\n\n/* import \u0022ds-stop/stop.sol\u0022; */\n\n/* import \u0022./base.sol\u0022; */\n\ncontract DSToken is DSTokenBase(0), DSStop {\n\n    bytes32  public  symbol;\n    uint256  public  decimals = 18; // standard token precision. override to customize\n\n    constructor(bytes32 symbol_) public {\n        symbol = symbol_;\n    }\n\n    event Mint(address indexed guy, uint wad);\n    event Burn(address indexed guy, uint wad);\n\n    function approve(address guy) public stoppable returns (bool) {\n        return super.approve(guy, uint(-1));\n    }\n\n    function approve(address guy, uint wad) public stoppable returns (bool) {\n        return super.approve(guy, wad);\n    }\n\n    function transferFrom(address src, address dst, uint wad)\n        public\n        stoppable\n        returns (bool)\n    {\n        if (src != msg.sender \u0026\u0026 _approvals[src][msg.sender] != uint(-1)) {\n            require(_approvals[src][msg.sender] \u003E= wad, \u0022ds-token-insufficient-approval\u0022);\n            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);\n        }\n\n        require(_balances[src] \u003E= wad, \u0022ds-token-insufficient-balance\u0022);\n        _balances[src] = sub(_balances[src], wad);\n        _balances[dst] = add(_balances[dst], wad);\n\n        emit Transfer(src, dst, wad);\n\n        return true;\n    }\n\n    function push(address dst, uint wad) public {\n        transferFrom(msg.sender, dst, wad);\n    }\n    function pull(address src, uint wad) public {\n        transferFrom(src, msg.sender, wad);\n    }\n    function move(address src, address dst, uint wad) public {\n        transferFrom(src, dst, wad);\n    }\n\n    function mint(uint wad) public {\n        mint(msg.sender, wad);\n    }\n    function burn(uint wad) public {\n        burn(msg.sender, wad);\n    }\n    function mint(address guy, uint wad) public auth stoppable {\n        _balances[guy] = add(_balances[guy], wad);\n        _supply = add(_supply, wad);\n        emit Mint(guy, wad);\n    }\n    function burn(address guy, uint wad) public auth stoppable {\n        if (guy != msg.sender \u0026\u0026 _approvals[guy][msg.sender] != uint(-1)) {\n            require(_approvals[guy][msg.sender] \u003E= wad, \u0022ds-token-insufficient-approval\u0022);\n            _approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);\n        }\n\n        require(_balances[guy] \u003E= wad, \u0022ds-token-insufficient-balance\u0022);\n        _balances[guy] = sub(_balances[guy], wad);\n        _supply = sub(_supply, wad);\n        emit Burn(guy, wad);\n    }\n\n    // Optional token name\n    bytes32   public  name = \u0022\u0022;\n\n    function setName(bytes32 name_) public auth {\n        name = name_;\n    }\n}\n\n////// src/Wallet.sol\n/* pragma solidity ^0.5.11; */\n\n/* import \u0022ds-math/math.sol\u0022; */\n/* import \u0022ds-auth/auth.sol\u0022; */\n/* import \u0022ds-token/token.sol\u0022; */\n/* import \u0022ds-stop/stop.sol\u0022; */\n/* import \u0022ds-note/note.sol\u0022; */\n\n/**\n* @dev Interface to ERC20 tokens.\n*/\ncontract TrustedErc20Wallet {\n    function totalSupply() public view returns (uint);\n    function balanceOf(address guy) public view returns (uint);\n    function allowance(address src, address guy) public view returns (uint);\n\n    function approve(address guy, uint wad) public returns (bool);\n    function transfer(address dst, uint wad) public returns (bool);\n    function transferFrom(\n        address src, address dst, uint wad\n    ) public returns (bool);\n}\n\n/**\n* @dev Interface to ERC721 tokens.\n*/\ncontract TrustedErci721Wallet {\n    function balanceOf(address guy) public view returns (uint);\n    function ownerOf(uint256 tokenId) public view returns (address);\n    function approve(address to, uint256 tokenId) public;\n    function getApproved(uint256 tokenId) public view returns (address);\n    function setApprovalForAll(address to, bool approved) public;\n    function isApprovedForAll(address owner, address operator) public view returns (bool);\n    function transferFrom(address from, address to, uint256 tokenId) public;\n    function safeTransferFrom(address from, address to, uint256 tokenId) public;\n    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public;\n}\n\n/**\n * @title Wallet is a contract to handle erc20 and erc721 tokens and ether.\n * @dev This token is used to store and transfer tokens that were paid as fee by users.\n */\ncontract Wallet is DSAuth, DSStop, DSMath {\n    event LogTransferEth(address src, address dst, uint256 amount);\n    address public eth = address(0xee);\n    bytes32 public name = \u0022Wal\u0022;                          // set human readable name for contract\n    bytes32 public symbol = \u0022Wal\u0022;                        // set human readable name for contract\n\n    function () external payable {\n    }\n\n    function transfer(address token, address payable dst, uint256 amt) public auth returns (bool) {\n        return sendToken(token, address(this), dst, amt);\n    }\n\n    function transferFrom(address token, address src, address payable dst, uint256 amt) public auth returns (bool) {\n        return sendToken(token, src, dst, amt);\n    }\n\n    function totalSupply(address token) public view returns (uint){\n        if (token == eth) {\n            require(false, \u0022wal-no-total-supply-for-ether\u0022);\n        } else {\n            return TrustedErc20Wallet(token).totalSupply();\n        }\n    }\n\n    function balanceOf(address token, address src) public view returns (uint) {\n        if (token == eth) {\n            return src.balance;\n        } else {\n            return TrustedErc20Wallet(token).balanceOf(src);\n        }\n    }\n\n    function allowance(address token, address src, address guy)\n    public view returns (uint) {\n        if( token == eth) {\n            require(false, \u0022wal-no-allowance-for-ether\u0022);\n        } else {\n            return TrustedErc20Wallet(token).allowance(src, guy);\n        }\n    }\n\n    function approve(address token, address guy, uint wad)\n    public auth returns (bool) {\n        if( token == eth) {\n            require(false, \u0022wal-can-not-approve-ether\u0022);\n        } else {\n            return TrustedErc20Wallet(token).approve(guy, wad);\n        }\n    }\n\n    function balanceOf721(address token, address guy) public view returns (uint) {\n        return TrustedErci721Wallet(token).balanceOf(guy);\n    }\n\n    function ownerOf721(address token, uint256 tokenId) public view returns (address) {\n        return TrustedErci721Wallet(token).ownerOf(tokenId);\n    }\n\n    function approve721(address token, address to, uint256 tokenId) public {\n        TrustedErci721Wallet(token).approve(to, tokenId);\n    }\n\n    function getApproved721(address token, uint256 tokenId) public view returns (address) {\n        return TrustedErci721Wallet(token).getApproved(tokenId);\n    }\n\n    function setApprovalForAll721(address token, address to, bool approved) public auth {\n        TrustedErci721Wallet(token).setApprovalForAll(to, approved);\n    }\n\n    function isApprovedForAll721(address token, address owner, address operator) public view returns (bool) {\n        return TrustedErci721Wallet(token).isApprovedForAll(owner, operator);\n    }\n\n    function transferFrom721(address token, address from, address to, uint256 tokenId) public auth {\n        TrustedErci721Wallet(token).transferFrom(from, to, tokenId);\n    }\n\n    function safeTransferFrom721(address token, address from, address to, uint256 tokenId) public auth {\n        TrustedErci721Wallet(token).safeTransferFrom(from, to, tokenId);\n    }\n\n    function safeTransferFrom721(address token, address from, address to, uint256 tokenId, bytes memory _data) public auth {\n        TrustedErci721Wallet(token).safeTransferFrom(from, to, tokenId, _data);\n    }\n\n    function transfer721(address token, address to, uint tokenId) public auth {\n        TrustedErci721Wallet(token).transferFrom(address(this), to, tokenId);\n    }\n\n    /**\n    * @dev send token or ether to destination\n    */\n    function sendToken(\n        address token,\n        address src,\n        address payable dst,\n        uint256 amount\n    ) internal returns (bool){\n        TrustedErc20Wallet erc20 = TrustedErc20Wallet(token);\n        if (token == eth \u0026\u0026 amount \u003E 0) {\n            require(src == address(this), \u0022wal-ether-transfer-invalid-src\u0022);\n            dst.transfer(amount);\n            emit LogTransferEth(src, dst, amount);\n        } else {\n            if (amount \u003E 0) erc20.transferFrom(src, dst, amount);   // transfer all of token to dst\n        }\n        return true;\n    }\n}\n\n","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022stop\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom721\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner_\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022safeTransferFrom721\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getApproved721\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022approved\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setApprovalForAll721\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ownerOf721\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022stopped\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract DSAuthority\u0022,\u0022name\u0022:\u0022authority_\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setAuthority\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022guy\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf721\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022eth\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer721\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022guy\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022operator\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isApprovedForAll721\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022start\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022authority\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract DSAuthority\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022safeTransferFrom721\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022guy\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokenId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve721\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogTransferEth\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022authority\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogSetAuthority\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogSetOwner\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:true,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes4\u0022,\u0022name\u0022:\u0022sig\u0022,\u0022type\u0022:\u0022bytes4\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022guy\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022foo\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022bar\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022fax\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022LogNote\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Wallet","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://89299660e952d6c48ca18135080ecf37e0290f6deaa53e6fdd8906212ae8b376"}]