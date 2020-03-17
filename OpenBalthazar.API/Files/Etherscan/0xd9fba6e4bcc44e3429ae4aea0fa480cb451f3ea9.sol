[{"SourceCode":"pragma solidity ^0.5.8;\r\n/*\r\n  This file is part of The Colony Network.\r\n\r\n  The Colony Network is free software: you can redistribute it and/or modify\r\n  it under the terms of the GNU General Public License as published by\r\n  the Free Software Foundation, either version 3 of the License, or\r\n  (at your option) any later version.\r\n\r\n  The Colony Network is distributed in the hope that it will be useful,\r\n  but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n  GNU General Public License for more details.\r\n\r\n  You should have received a copy of the GNU General Public License\r\n  along with The Colony Network. If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\r\n*/\r\n\r\n\r\n\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n// GNU General Public License for more details.\r\n\r\n// You should have received a copy of the GNU General Public License\r\n// along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\r\n\r\n\r\n\r\ncontract DSAuthority {\r\n    function canCall(\r\n        address src, address dst, bytes4 sig\r\n    ) public view returns (bool);\r\n}\r\n\r\ncontract DSAuthEvents {\r\n    event LogSetAuthority (address indexed authority);\r\n    event LogSetOwner     (address indexed owner);\r\n}\r\n\r\ncontract DSAuth is DSAuthEvents {\r\n    DSAuthority  public  authority;\r\n    address      public  owner;\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n        emit LogSetOwner(msg.sender);\r\n    }\r\n\r\n    function setOwner(address owner_)\r\n        public\r\n        auth\r\n    {\r\n        owner = owner_;\r\n        emit LogSetOwner(owner);\r\n    }\r\n\r\n    function setAuthority(DSAuthority authority_)\r\n        public\r\n        auth\r\n    {\r\n        authority = authority_;\r\n        emit LogSetAuthority(address(authority));\r\n    }\r\n\r\n    modifier auth {\r\n        require(isAuthorized(msg.sender, msg.sig), \u0022ds-auth-unauthorized\u0022);\r\n        _;\r\n    }\r\n\r\n    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {\r\n        if (src == address(this)) {\r\n            return true;\r\n        } else if (src == owner) {\r\n            return true;\r\n        } else if (authority == DSAuthority(0)) {\r\n            return false;\r\n        } else {\r\n            return authority.canCall(src, address(this), sig);\r\n        }\r\n    }\r\n}\r\n/// base.sol -- basic ERC20 implementation\r\n\r\n// Copyright (C) 2015, 2016, 2017  DappHub, LLC\r\n\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n// GNU General Public License for more details.\r\n\r\n// You should have received a copy of the GNU General Public License\r\n// along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\r\n\r\n\r\n\r\n/// erc20.sol -- API for the ERC20 token standard\r\n\r\n// See \u003Chttps://github.com/ethereum/EIPs/issues/20\u003E.\r\n\r\n// This file likely does not meet the threshold of originality\r\n// required for copyright to apply.  As a result, this is free and\r\n// unencumbered software belonging to the public domain.\r\n\r\n\r\n\r\ncontract ERC20Events {\r\n    event Approval(address indexed src, address indexed guy, uint wad);\r\n    event Transfer(address indexed src, address indexed dst, uint wad);\r\n}\r\n\r\ncontract ERC20 is ERC20Events {\r\n    function totalSupply() public view returns (uint);\r\n    function balanceOf(address guy) public view returns (uint);\r\n    function allowance(address src, address guy) public view returns (uint);\r\n\r\n    function approve(address guy, uint wad) public returns (bool);\r\n    function transfer(address dst, uint wad) public returns (bool);\r\n    function transferFrom(\r\n        address src, address dst, uint wad\r\n    ) public returns (bool);\r\n}\r\n/// math.sol -- mixin for inline numerical wizardry\r\n\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU General Public License as published by\r\n// the Free Software Foundation, either version 3 of the License, or\r\n// (at your option) any later version.\r\n\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n// GNU General Public License for more details.\r\n\r\n// You should have received a copy of the GNU General Public License\r\n// along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\r\n\r\n\r\n\r\ncontract DSMath {\r\n    function add(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x \u002B y) \u003E= x, \u0022ds-math-add-overflow\u0022);\r\n    }\r\n    function sub(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x - y) \u003C= x, \u0022ds-math-sub-underflow\u0022);\r\n    }\r\n    function mul(uint x, uint y) internal pure returns (uint z) {\r\n        require(y == 0 || (z = x * y) / y == x, \u0022ds-math-mul-overflow\u0022);\r\n    }\r\n\r\n    function min(uint x, uint y) internal pure returns (uint z) {\r\n        return x \u003C= y ? x : y;\r\n    }\r\n    function max(uint x, uint y) internal pure returns (uint z) {\r\n        return x \u003E= y ? x : y;\r\n    }\r\n    function imin(int x, int y) internal pure returns (int z) {\r\n        return x \u003C= y ? x : y;\r\n    }\r\n    function imax(int x, int y) internal pure returns (int z) {\r\n        return x \u003E= y ? x : y;\r\n    }\r\n\r\n    uint constant WAD = 10 ** 18;\r\n    uint constant RAY = 10 ** 27;\r\n\r\n    function wmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), WAD / 2) / WAD;\r\n    }\r\n    function rmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), RAY / 2) / RAY;\r\n    }\r\n    function wdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, WAD), y / 2) / y;\r\n    }\r\n    function rdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, RAY), y / 2) / y;\r\n    }\r\n\r\n    // This famous algorithm is called \u0022exponentiation by squaring\u0022\r\n    // and calculates x^n with x as fixed-point and n as regular unsigned.\r\n    //\r\n    // It\u0027s O(log n), instead of O(n) for naive repeated multiplication.\r\n    //\r\n    // These facts are why it works:\r\n    //\r\n    //  If n is even, then x^n = (x^2)^(n/2).\r\n    //  If n is odd,  then x^n = x * x^(n-1),\r\n    //   and applying the equation for even x gives\r\n    //    x^n = x * (x^2)^((n-1) / 2).\r\n    //\r\n    //  Also, EVM division is flooring and\r\n    //    floor[(n-1) / 2] = floor[n / 2].\r\n    //\r\n    function rpow(uint x, uint n) internal pure returns (uint z) {\r\n        z = n % 2 != 0 ? x : RAY;\r\n\r\n        for (n /= 2; n != 0; n /= 2) {\r\n            x = rmul(x, x);\r\n\r\n            if (n % 2 != 0) {\r\n                z = rmul(z, x);\r\n            }\r\n        }\r\n    }\r\n}\r\n\r\ncontract DSTokenBase is ERC20, DSMath {\r\n    uint256                                            _supply;\r\n    mapping (address =\u003E uint256)                       _balances;\r\n    mapping (address =\u003E mapping (address =\u003E uint256))  _approvals;\r\n\r\n    constructor(uint supply) public {\r\n        _balances[msg.sender] = supply;\r\n        _supply = supply;\r\n    }\r\n\r\n    function totalSupply() public view returns (uint) {\r\n        return _supply;\r\n    }\r\n    function balanceOf(address src) public view returns (uint) {\r\n        return _balances[src];\r\n    }\r\n    function allowance(address src, address guy) public view returns (uint) {\r\n        return _approvals[src][guy];\r\n    }\r\n\r\n    function transfer(address dst, uint wad) public returns (bool) {\r\n        return transferFrom(msg.sender, dst, wad);\r\n    }\r\n\r\n    function transferFrom(address src, address dst, uint wad)\r\n        public\r\n        returns (bool)\r\n    {\r\n        if (src != msg.sender) {\r\n            require(_approvals[src][msg.sender] \u003E= wad, \u0022ds-token-insufficient-approval\u0022);\r\n            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);\r\n        }\r\n\r\n        require(_balances[src] \u003E= wad, \u0022ds-token-insufficient-balance\u0022);\r\n        _balances[src] = sub(_balances[src], wad);\r\n        _balances[dst] = add(_balances[dst], wad);\r\n\r\n        emit Transfer(src, dst, wad);\r\n\r\n        return true;\r\n    }\r\n\r\n    function approve(address guy, uint wad) public returns (bool) {\r\n        _approvals[msg.sender][guy] = wad;\r\n\r\n        emit Approval(msg.sender, guy, wad);\r\n\r\n        return true;\r\n    }\r\n}\r\n/*\r\n  This file is part of The Colony Network.\r\n\r\n  The Colony Network is free software: you can redistribute it and/or modify\r\n  it under the terms of the GNU General Public License as published by\r\n  the Free Software Foundation, either version 3 of the License, or\r\n  (at your option) any later version.\r\n\r\n  The Colony Network is distributed in the hope that it will be useful,\r\n  but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n  GNU General Public License for more details.\r\n\r\n  You should have received a copy of the GNU General Public License\r\n  along with The Colony Network. If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\r\n*/\r\n\r\n\r\n\r\n\r\n\r\n\r\ncontract ERC20Extended is ERC20 {\r\n  event Mint(address indexed guy, uint wad);\r\n  event Burn(address indexed guy, uint wad);\r\n\r\n  function mint(uint wad) public;\r\n  function mint(address guy, uint wad) public;\r\n  function burn(uint wad) public;\r\n  function burn(address guy, uint wad) public;\r\n}\r\n\r\n\r\ncontract Token is DSTokenBase(0), DSAuth, ERC20Extended {\r\n  uint8 public decimals;\r\n  string public symbol;\r\n  string public name;\r\n\r\n  bool public locked;\r\n\r\n  modifier unlocked {\r\n    if (locked) {\r\n      require(isAuthorized(msg.sender, msg.sig), \u0022colony-token-unauthorised\u0022);\r\n    }\r\n    _;\r\n  }\r\n\r\n  constructor(string memory _name, string memory _symbol, uint8 _decimals) public {\r\n    name = _name;\r\n    symbol = _symbol;\r\n    decimals = _decimals;\r\n    locked = true;\r\n  }\r\n\r\n  function transferFrom(address src, address dst, uint wad) public \r\n  unlocked\r\n  returns (bool)\r\n  {\r\n    return super.transferFrom(src, dst, wad);\r\n  }\r\n\r\n  function mint(uint wad) public auth {\r\n    mint(msg.sender, wad);\r\n  }\r\n\r\n  function burn(uint wad) public {\r\n    burn(msg.sender, wad);\r\n  }\r\n\r\n  function mint(address guy, uint wad) public auth {\r\n    _balances[guy] = add(_balances[guy], wad);\r\n    _supply = add(_supply, wad);\r\n    emit Mint(guy, wad);\r\n    emit Transfer(address(0x0), guy, wad);\r\n  }\r\n\r\n  function burn(address guy, uint wad) public {\r\n    if (guy != msg.sender) {\r\n      require(_approvals[guy][msg.sender] \u003E= wad, \u0022ds-token-insufficient-approval\u0022);\r\n      _approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);\r\n    }\r\n\r\n    require(_balances[guy] \u003E= wad, \u0022ds-token-insufficient-balance\u0022);\r\n    _balances[guy] = sub(_balances[guy], wad);\r\n    _supply = sub(_supply, wad);\r\n    emit Burn(guy, wad);\r\n  }\r\n\r\n  function unlock() public\r\n  auth\r\n  {\r\n    locked = false;\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022guy\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner_\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022guy\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022mint\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022authority_\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setAuthority\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022guy\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022mint\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unlock\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022authority\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022locked\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022guy\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_symbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_decimals\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022guy\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Mint\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022guy\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022authority\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogSetAuthority\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogSetOwner\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022guy\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Token","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000e4120546f6b656e206f66204a6f7900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000034a4f590000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://ed8de9a90263e33e6d6e4fb5554694081cb7508892aee98c6e637d87f2bec09a"}]