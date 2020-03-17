[{"SourceCode":"/* Orchid - WebRTC P2P VPN Market (on Ethereum)\r\n * Copyright (C) 2017-2019  The Orchid Authors\r\n*/\r\n\r\n/* GNU Affero General Public License, Version 3 {{{ */\r\n/*\r\n * This program is free software: you can redistribute it and/or modify\r\n * it under the terms of the GNU Affero General Public License as published by\r\n * the Free Software Foundation, either version 3 of the License, or\r\n * (at your option) any later version.\r\n\r\n * This program is distributed in the hope that it will be useful,\r\n * but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n * GNU Affero General Public License for more details.\r\n\r\n * You should have received a copy of the GNU Affero General Public License\r\n * along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\r\n**/\r\n/* }}} */\r\n\r\n\r\npragma solidity 0.5.12;\r\n\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\r\n * the optional functions; to access them see {ERC20Detailed}.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from the caller\u0027s account to \u0060recipient\u0060.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that \u0060spender\u0060 will be\r\n     * allowed to spend on behalf of \u0060owner\u0060 through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from \u0060sender\u0060 to \u0060recipient\u0060 using the\r\n     * allowance mechanism. \u0060amount\u0060 is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when \u0060value\u0060 tokens are moved from one account (\u0060from\u0060) to\r\n     * another (\u0060to\u0060).\r\n     *\r\n     * Note that \u0060value\u0060 may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a \u0060spender\u0060 for an \u0060owner\u0060 is set by\r\n     * a call to {approve}. \u0060value\u0060 is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n\r\ninterface OrchidVerifier {\r\n    function good(bytes calldata shared, address target, bytes calldata receipt) external pure returns (bool);\r\n}\r\n\r\ncontract OrchidLottery {\r\n\r\n    IERC20 internal token_;\r\n\r\n    constructor(IERC20 token) public {\r\n        token_ = token;\r\n    }\r\n\r\n    function what() external view returns (IERC20) {\r\n        return token_;\r\n    }\r\n\r\n\r\n    struct Pot {\r\n        uint256 offset_;\r\n\r\n        uint128 amount_;\r\n        uint128 escrow_;\r\n\r\n        uint256 unlock_;\r\n\r\n        OrchidVerifier verify_;\r\n        bytes32 codehash_;\r\n        bytes shared_;\r\n    }\r\n\r\n    event Update(address indexed funder, address indexed signer, uint128 amount, uint128 escrow, uint256 unlock);\r\n\r\n    function send(address funder, address signer, Pot storage pot) private {\r\n        emit Update(funder, signer, pot.amount_, pot.escrow_, pot.unlock_);\r\n    }\r\n\r\n\r\n    struct Lottery {\r\n        address[] keys_;\r\n        mapping(address =\u003E Pot) pots_;\r\n    }\r\n\r\n    mapping(address =\u003E Lottery) internal lotteries_;\r\n\r\n\r\n    function find(address funder, address signer) private view returns (Pot storage) {\r\n        return lotteries_[funder].pots_[signer];\r\n    }\r\n\r\n    function kill(address signer) external {\r\n        address funder = msg.sender;\r\n        Lottery storage lottery = lotteries_[funder];\r\n        Pot storage pot = lottery.pots_[signer];\r\n        require(pot.offset_ != 0);\r\n        address key = lottery.keys_[lottery.keys_.length - 1];\r\n        lottery.pots_[key].offset_ = pot.offset_;\r\n        lottery.keys_[pot.offset_ - 1] = key;\r\n        --lottery.keys_.length;\r\n        delete lottery.pots_[signer];\r\n        send(funder, signer, pot);\r\n    }\r\n\r\n\r\n    function size(address funder) external view returns (uint256) {\r\n        return lotteries_[funder].keys_.length;\r\n    }\r\n\r\n    function keys(address funder) external view returns (address[] memory) {\r\n        return lotteries_[funder].keys_;\r\n    }\r\n\r\n    function seek(address funder, uint256 offset) external view returns (address) {\r\n        return lotteries_[funder].keys_[offset];\r\n    }\r\n\r\n    function page(address funder, uint256 offset, uint256 count) external view returns (address[] memory) {\r\n        address[] storage all = lotteries_[funder].keys_;\r\n        require(offset \u003C= all.length);\r\n        if (count \u003E all.length - offset)\r\n            count = all.length - offset;\r\n        address[] memory slice = new address[](count);\r\n        for (uint256 i = 0; i != count; \u002B\u002Bi)\r\n            slice[i] = all[offset \u002B i];\r\n        return slice;\r\n    }\r\n\r\n\r\n    function look(address funder, address signer) external view returns (uint128, uint128, uint256, OrchidVerifier, bytes32, bytes memory) {\r\n        Pot storage pot = lotteries_[funder].pots_[signer];\r\n        return (pot.amount_, pot.escrow_, pot.unlock_, pot.verify_, pot.codehash_, pot.shared_);\r\n    }\r\n\r\n\r\n    // XXX: _maybe_ allow anyone to call this function?\r\n    function push(address signer, uint128 total, uint128 escrow) external {\r\n        address funder = msg.sender;\r\n        require(total \u003E= escrow);\r\n        Pot storage pot = find(funder, signer);\r\n        if (pot.offset_ == 0)\r\n            pot.offset_ = lotteries_[funder].keys_.push(signer);\r\n        pot.amount_ \u002B= total - escrow;\r\n        pot.escrow_ \u002B= escrow;\r\n        send(funder, signer, pot);\r\n        require(token_.transferFrom(funder, address(this), total));\r\n    }\r\n\r\n    // XXX: implement a version of this callable by signers\r\n    //      (maybe make that one target address(0) w/receipt)\r\n    function move(address signer, uint128 amount) external {\r\n        address funder = msg.sender;\r\n        Pot storage pot = find(funder, signer);\r\n        require(pot.amount_ \u003E= amount);\r\n        amount = take(amount, pot);\r\n        pot.escrow_ \u002B= amount;\r\n        send(funder, signer, pot);\r\n    }\r\n\r\n    function burn(address signer, uint128 escrow) external {\r\n        address funder = msg.sender;\r\n        Pot storage pot = find(funder, signer);\r\n        if (escrow \u003E pot.escrow_)\r\n            escrow = pot.escrow_;\r\n        pot.escrow_ -= escrow;\r\n        send(funder, signer, pot);\r\n    }\r\n\r\n    // XXX: do some kind of log from this function so wallets can watch?\r\n    function bind(address signer, OrchidVerifier verify, bytes calldata shared) external {\r\n        address funder = msg.sender;\r\n        Pot storage pot = find(funder, signer);\r\n        require(pot.escrow_ == 0);\r\n\r\n        bytes32 codehash;\r\n        assembly { codehash := extcodehash(verify) }\r\n\r\n        pot.verify_ = verify;\r\n        pot.codehash_ = codehash;\r\n        pot.shared_ = shared;\r\n    }\r\n\r\n\r\n    struct Track {\r\n        uint256 until_;\r\n    }\r\n\r\n    mapping(address =\u003E mapping(bytes32 =\u003E Track)) internal tracks_;\r\n\r\n\r\n    function take(uint128 amount, Pot storage pot) private returns (uint128) {\r\n        if (pot.amount_ \u003E= amount)\r\n            pot.amount_ -= amount;\r\n        else {\r\n            amount = pot.amount_;\r\n            pot.escrow_ = 0;\r\n        }\r\n\r\n        return amount;\r\n    }\r\n\r\n    function take(address funder, address signer, uint128 amount, address payable target, Pot storage pot) private {\r\n        amount = take(amount, pot);\r\n        send(funder, signer, pot);\r\n\r\n        if (amount != 0)\r\n            require(token_.transfer(target, amount));\r\n    }\r\n\r\n    function take(address funder, address signer, uint128 amount, address payable target, bytes memory receipt) private {\r\n        Pot storage pot = find(funder, signer);\r\n        take(funder, signer, amount, target, pot);\r\n\r\n        OrchidVerifier verify = pot.verify_;\r\n        if (verify != OrchidVerifier(0)) {\r\n            bytes32 codehash;\r\n            assembly { codehash := extcodehash(verify) }\r\n            if (pot.codehash_ == codehash)\r\n                require(verify.good(pot.shared_, target, receipt));\r\n        }\r\n    }\r\n\r\n    // the arguments to this function are carefully ordered for stack depth optimization\r\n    // this function was marked public, instead of external, for lower stack depth usage\r\n    function grab(\r\n        bytes32 reveal, bytes32 commit,\r\n        uint8 v, bytes32 r, bytes32 s,\r\n        bytes32 nonce, address funder,\r\n        uint128 amount, uint128 ratio,\r\n        uint256 start, uint128 range,\r\n        address payable target, bytes memory receipt,\r\n        bytes32[] memory old\r\n    ) public {\r\n        require(keccak256(abi.encodePacked(reveal)) == commit);\r\n        require(uint256(keccak256(abi.encodePacked(reveal, nonce))) \u003E\u003E 128 \u003C= ratio);\r\n\r\n        // XXX: support EIP-712\r\n        bytes32 ticket = keccak256(abi.encode(commit, nonce, funder, amount, ratio, start, range, target, receipt));\r\n        address signer = ecrecover(keccak256(abi.encodePacked(\u0022\\x19Ethereum Signed Message:\\n32\u0022, ticket)), v, r, s);\r\n        require(signer != address(0));\r\n\r\n        {\r\n            mapping(bytes32 =\u003E Track) storage tracks = tracks_[target];\r\n\r\n            {\r\n                Track storage track = tracks[keccak256(abi.encodePacked(signer, ticket))];\r\n                uint256 until = start \u002B range;\r\n                require(until \u003E block.timestamp);\r\n                require(track.until_ == 0);\r\n                track.until_ = until;\r\n            }\r\n\r\n            for (uint256 i = 0; i != old.length; \u002B\u002Bi) {\r\n                Track storage track = tracks[old[i]];\r\n                if (track.until_ \u003C= block.timestamp)\r\n                    delete track.until_;\r\n            }\r\n        }\r\n\r\n        if (start \u003C block.timestamp) {\r\n            uint128 limit = uint128(uint256(amount) * (range - (block.timestamp - start)) / range);\r\n            if (amount \u003E limit)\r\n                amount = limit;\r\n        }\r\n\r\n        take(funder, signer, amount, target, receipt);\r\n    }\r\n\r\n    function give(address funder, address payable target, uint128 amount, bytes calldata receipt) external {\r\n        address signer = msg.sender;\r\n        take(funder, signer, amount, target, receipt);\r\n    }\r\n\r\n    function pull(address signer, address payable target, uint128 amount) external {\r\n        address funder = msg.sender;\r\n        Pot storage pot = find(funder, signer);\r\n        take(funder, signer, amount, target, pot);\r\n    }\r\n\r\n\r\n    function warn(address signer) external {\r\n        address funder = msg.sender;\r\n        Pot storage pot = find(funder, signer);\r\n        pot.unlock_ = block.timestamp \u002B 1 days;\r\n        send(funder, signer, pot);\r\n    }\r\n\r\n    function lock(address signer) external {\r\n        address funder = msg.sender;\r\n        Pot storage pot = find(funder, signer);\r\n        pot.unlock_ = 0;\r\n        send(funder, signer, pot);\r\n    }\r\n\r\n    function pull(address signer, address payable target, uint128 amount, uint128 escrow) external {\r\n        address funder = msg.sender;\r\n        Pot storage pot = find(funder, signer);\r\n        if (amount \u003E pot.amount_)\r\n            amount = pot.amount_;\r\n        if (escrow \u003E pot.escrow_)\r\n            escrow = pot.escrow_;\r\n        if (escrow != 0)\r\n            require(pot.unlock_ - 1 \u003C block.timestamp);\r\n        uint128 total = amount \u002B escrow;\r\n        pot.amount_ -= amount;\r\n        pot.escrow_ -= escrow;\r\n        if (pot.escrow_ == 0)\r\n            pot.unlock_ = 0;\r\n        send(funder, signer, pot);\r\n        require(token_.transfer(target, total));\r\n    }\r\n\r\n    function yank(address signer, address payable target) external {\r\n        address funder = msg.sender;\r\n        Pot storage pot = find(funder, signer);\r\n        if (pot.escrow_ != 0)\r\n            require(pot.unlock_ - 1 \u003C block.timestamp);\r\n        uint128 total = pot.amount_ \u002B pot.escrow_;\r\n        pot.amount_ = 0;\r\n        pot.escrow_ = 0;\r\n        pot.unlock_ = 0;\r\n        send(funder, signer, pot);\r\n        require(token_.transfer(target, total));\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022funder\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022signer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint128\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022escrow\u0022,\u0022type\u0022:\u0022uint128\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022unlock\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Update\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022signer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022contract OrchidVerifier\u0022,\u0022name\u0022:\u0022verify\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022shared\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022bind\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022signer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022escrow\u0022,\u0022type\u0022:\u0022uint128\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022funder\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint128\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022receipt\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022give\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022reveal\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022commit\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022v\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022r\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022s\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022funder\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint128\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022ratio\u0022,\u0022type\u0022:\u0022uint128\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022start\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022range\u0022,\u0022type\u0022:\u0022uint128\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022receipt\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022internalType\u0022:\u0022bytes32[]\u0022,\u0022name\u0022:\u0022old\u0022,\u0022type\u0022:\u0022bytes32[]\u0022}],\u0022name\u0022:\u0022grab\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022funder\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022keys\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022signer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022kill\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022signer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022lock\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022funder\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022signer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022look\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint128\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint128\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022contract OrchidVerifier\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022signer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint128\u0022}],\u0022name\u0022:\u0022move\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022funder\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022offset\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022count\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022page\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022signer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint128\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022escrow\u0022,\u0022type\u0022:\u0022uint128\u0022}],\u0022name\u0022:\u0022pull\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022signer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint128\u0022}],\u0022name\u0022:\u0022pull\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022signer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022total\u0022,\u0022type\u0022:\u0022uint128\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022escrow\u0022,\u0022type\u0022:\u0022uint128\u0022}],\u0022name\u0022:\u0022push\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022funder\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022offset\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022seek\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022funder\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022size\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022signer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022warn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022what\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022signer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022yank\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"OrchidLottery","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000ff9978b7b309021d39a76f52be377f2b95d72394","Library":"","SwarmSource":"bzzr://3b88174e0441782f4c6b1648e8a16773be208ce6999bf48c95d0004144cdbbf1"}]