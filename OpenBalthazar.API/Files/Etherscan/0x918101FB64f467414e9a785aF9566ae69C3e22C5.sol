[{"SourceCode":"/* Orchid - WebRTC P2P VPN Market (on Ethereum)\r\n * Copyright (C) 2017-2019  The Orchid Authors\r\n*/\r\n\r\n/* GNU Affero General Public License, Version 3 {{{ */\r\n/*\r\n * This program is free software: you can redistribute it and/or modify\r\n * it under the terms of the GNU Affero General Public License as published by\r\n * the Free Software Foundation, either version 3 of the License, or\r\n * (at your option) any later version.\r\n\r\n * This program is distributed in the hope that it will be useful,\r\n * but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n * GNU Affero General Public License for more details.\r\n\r\n * You should have received a copy of the GNU Affero General Public License\r\n * along with this program.  If not, see \u003Chttp://www.gnu.org/licenses/\u003E.\r\n**/\r\n/* }}} */\r\n\r\n\r\npragma solidity 0.5.13;\r\n\r\ninterface IERC20 {\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n}\r\n\r\ncontract OrchidDirectory {\r\n\r\n    IERC20 internal token_;\r\n\r\n    constructor(IERC20 token) public {\r\n        token_ = token;\r\n    }\r\n\r\n    function what() external view returns (IERC20) {\r\n        return token_;\r\n    }\r\n\r\n\r\n    struct Stakee {\r\n        uint256 amount_;\r\n    }\r\n\r\n    mapping(address =\u003E Stakee) internal stakees_;\r\n\r\n    function heft(address stakee) external view returns (uint256) {\r\n        return stakees_[stakee].amount_;\r\n    }\r\n\r\n\r\n    struct Primary {\r\n        bytes32 value_;\r\n    }\r\n\r\n    function name(address staker, address stakee) public pure returns (bytes32) {\r\n        return keccak256(abi.encodePacked(staker, stakee));\r\n    }\r\n\r\n    function name(Primary storage primary) private view returns (bytes32) {\r\n        return primary.value_;\r\n    }\r\n\r\n    function copy(Primary storage primary, address staker, address stakee) private {\r\n        primary.value_ = name(staker, stakee);\r\n    }\r\n\r\n    function copy(Primary storage primary, Primary storage other) private {\r\n        primary.value_ = other.value_;\r\n    }\r\n\r\n    function kill(Primary storage primary) private {\r\n        primary.value_ = bytes32(0);\r\n    }\r\n\r\n    function nope(Primary storage primary) private view returns (bool) {\r\n        return primary.value_ == bytes32(0);\r\n    }\r\n\r\n\r\n    struct Stake {\r\n        uint256 before_;\r\n        uint256 after_;\r\n\r\n        uint256 amount_;\r\n        uint128 delay_;\r\n\r\n        address stakee_;\r\n\r\n        bytes32 parent_;\r\n        Primary left_;\r\n        Primary right_;\r\n    }\r\n\r\n    mapping(bytes32 =\u003E Stake) internal stakes_;\r\n\r\n    Primary private root_;\r\n\r\n\r\n    function have() public view returns (uint256) {\r\n        if (nope(root_))\r\n            return 0;\r\n        Stake storage stake = stakes_[name(root_)];\r\n        return stake.before_ \u002B stake.after_ \u002B stake.amount_;\r\n    }\r\n\r\n    function seek(uint256 point) public view returns (address, uint128) {\r\n        require(!nope(root_));\r\n\r\n        Primary storage primary = root_;\r\n        for (;;) {\r\n            bytes32 key = name(primary);\r\n            Stake storage stake = stakes_[key];\r\n\r\n            if (point \u003C stake.before_) {\r\n                primary = stake.left_;\r\n                continue;\r\n            }\r\n\r\n            point -= stake.before_;\r\n\r\n            if (point \u003C stake.amount_)\r\n                return (stake.stakee_, stake.delay_);\r\n\r\n            point -= stake.amount_;\r\n\r\n            primary = stake.right_;\r\n        }\r\n    }\r\n\r\n    function pick(uint128 percent) external view returns (address, uint128) {\r\n        // for OXT, have() will be less than a uint128, so this math cannot overflow\r\n        return seek(have() * percent \u003E\u003E 128);\r\n    }\r\n\r\n\r\n    function turn(bytes32 key, Stake storage stake) private view returns (Primary storage) {\r\n        if (stake.parent_ == bytes32(0))\r\n            return root_;\r\n        Stake storage parent = stakes_[stake.parent_];\r\n        return name(parent.left_) == key ? parent.left_ : parent.right_;\r\n    }\r\n\r\n\r\n    function step(bytes32 key, Stake storage stake, uint256 amount, bytes32 root) private {\r\n        while (stake.parent_ != root) {\r\n            bytes32 parent = stake.parent_;\r\n            stake = stakes_[parent];\r\n            if (name(stake.left_) == key)\r\n                stake.before_ \u002B= amount;\r\n            else\r\n                stake.after_ \u002B= amount;\r\n            key = parent;\r\n        }\r\n    }\r\n\r\n    event Update(address indexed stakee, address indexed staker, uint256 local, uint256 global);\r\n\r\n    function lift(bytes32 key, Stake storage stake, uint256 amount, address staker, address stakee) private {\r\n        uint256 local = stake.amount_;\r\n        local \u002B= amount;\r\n        stake.amount_ = local;\r\n\r\n        uint256 global = stakees_[stakee].amount_;\r\n        global \u002B= amount;\r\n        stakees_[stakee].amount_ = global;\r\n\r\n        emit Update(stakee, staker, local, global);\r\n        step(key, stake, amount, bytes32(0));\r\n    }\r\n\r\n\r\n    event Delay(address indexed stakee, address indexed staker, uint128 delay);\r\n\r\n    function wait(Stake storage stake, uint128 delay, address staker, address stakee) private {\r\n        if (stake.delay_ != delay) {\r\n            require(stake.delay_ \u003C delay);\r\n            stake.delay_ = delay;\r\n            emit Delay(stakee, staker, delay);\r\n        }\r\n    }\r\n\r\n    function more(address stakee, uint256 amount, uint128 delay) private {\r\n        address staker = msg.sender;\r\n        bytes32 key = name(staker, stakee);\r\n        Stake storage stake = stakes_[key];\r\n\r\n        if (stake.amount_ == 0) {\r\n            require(amount != 0);\r\n\r\n            bytes32 parent = bytes32(0);\r\n            Primary storage primary = root_;\r\n\r\n            while (!nope(primary)) {\r\n                parent = name(primary);\r\n                Stake storage current = stakes_[parent];\r\n                primary = current.before_ \u003C current.after_ ? current.left_ : current.right_;\r\n            }\r\n\r\n            stake.parent_ = parent;\r\n            copy(primary, staker, stakee);\r\n\r\n            stake.stakee_ = stakee;\r\n        }\r\n\r\n        wait(stake, delay, staker, stakee);\r\n        lift(key, stake, amount, staker, stakee);\r\n    }\r\n\r\n    function push(address stakee, uint256 amount, uint128 delay) external {\r\n        more(stakee, amount, delay);\r\n        require(token_.transferFrom(msg.sender, address(this), amount));\r\n    }\r\n\r\n    function wait(address stakee, uint128 delay) external {\r\n        address staker = msg.sender;\r\n        bytes32 key = name(staker, stakee);\r\n        Stake storage stake = stakes_[key];\r\n        require(stake.amount_ != 0);\r\n        wait(stake, delay, staker, stakee);\r\n    }\r\n\r\n\r\n    struct Pending {\r\n        uint256 expire_;\r\n        address stakee_;\r\n        uint256 amount_;\r\n    }\r\n\r\n    mapping(address =\u003E mapping(uint256 =\u003E Pending)) private pendings_;\r\n\r\n    function pend(uint256 index, uint256 amount, uint128 delay) private returns (address) {\r\n        Pending storage pending = pendings_[msg.sender][index];\r\n        require(pending.expire_ \u003C= block.timestamp \u002B delay);\r\n        address stakee = pending.stakee_;\r\n\r\n        if (pending.amount_ == amount)\r\n            delete pendings_[msg.sender][index];\r\n        else {\r\n            require(pending.amount_ \u003E amount);\r\n            pending.amount_ -= amount;\r\n        }\r\n\r\n        return stakee;\r\n    }\r\n\r\n    function take(uint256 index, uint256 amount, address payable target) external {\r\n        pend(index, amount, 0);\r\n        require(token_.transfer(target, amount));\r\n    }\r\n\r\n    function stop(uint256 index, uint256 amount, uint128 delay) external {\r\n        more(pend(index, amount, delay), amount, delay);\r\n    }\r\n\r\n\r\n    function fixr(Stake storage stake, bytes32 location, Stake storage current) private {\r\n        if (nope(stake.right_))\r\n            return;\r\n        stakes_[name(stake.right_)].parent_ = location;\r\n        copy(current.right_, stake.right_);\r\n        current.after_ = stake.after_;\r\n    }\r\n\r\n    function fixl(Stake storage stake, bytes32 location, Stake storage current) private {\r\n        if (nope(stake.left_))\r\n            return;\r\n        stakes_[name(stake.left_)].parent_ = location;\r\n        copy(current.left_, stake.left_);\r\n        current.before_ = stake.before_;\r\n    }\r\n\r\n    function pull(address stakee, uint256 amount, uint256 index) external {\r\n        address staker = msg.sender;\r\n        bytes32 key = name(staker, stakee);\r\n        Stake storage stake = stakes_[key];\r\n        uint128 delay = stake.delay_;\r\n\r\n        require(stake.amount_ != 0);\r\n        require(stake.amount_ \u003E= amount);\r\n\r\n        lift(key, stake, -amount, staker, stakee);\r\n\r\n        if (stake.amount_ == 0) {\r\n            Primary storage pivot = turn(key, stake);\r\n            Primary storage child = stake.before_ \u003E stake.after_ ? stake.left_ : stake.right_;\r\n\r\n            if (nope(child))\r\n                kill(pivot);\r\n            else {\r\n                Primary storage last = child;\r\n                bytes32 location = name(last);\r\n                Stake storage current = stakes_[location];\r\n                for (;;) {\r\n                    Primary storage next = current.before_ \u003E current.after_ ? current.left_ : current.right_;\r\n                    if (nope(next))\r\n                        break;\r\n                    last = next;\r\n                    location = name(last);\r\n                    current = stakes_[location];\r\n                }\r\n\r\n                bytes32 direct = current.parent_;\r\n                copy(pivot, last);\r\n                current.parent_ = stake.parent_;\r\n\r\n                if (direct != key) {\r\n                    fixr(stake, location, current);\r\n                    fixl(stake, location, current);\r\n\r\n                    stake.parent_ = direct;\r\n                    copy(last, staker, stakee);\r\n                    step(key, stake, -current.amount_, current.parent_);\r\n                    kill(last);\r\n                } else if (name(stake.left_) == location) {\r\n                    fixr(stake, location, current);\r\n                } else {\r\n                    fixl(stake, location, current);\r\n                }\r\n            }\r\n\r\n            emit Delay(stakee, staker, 0);\r\n            delete stakes_[key];\r\n        }\r\n\r\n        Pending storage pending = pendings_[msg.sender][index];\r\n\r\n        uint256 expire = block.timestamp \u002B delay;\r\n        if (pending.expire_ \u003C expire)\r\n            pending.expire_ = expire;\r\n\r\n        if (pending.stakee_ == address(0))\r\n            pending.stakee_ = stakee;\r\n        else\r\n            require(pending.stakee_ == stakee);\r\n\r\n        pending.amount_ \u002B= amount;\r\n    }\r\n\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022stakee\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022staker\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022delay\u0022,\u0022type\u0022:\u0022uint128\u0022}],\u0022name\u0022:\u0022Delay\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022stakee\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022staker\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022local\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022global\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Update\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022have\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022stakee\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022heft\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022staker\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022stakee\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022percent\u0022,\u0022type\u0022:\u0022uint128\u0022}],\u0022name\u0022:\u0022pick\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint128\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022stakee\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022pull\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022stakee\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022delay\u0022,\u0022type\u0022:\u0022uint128\u0022}],\u0022name\u0022:\u0022push\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022point\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022seek\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint128\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022index\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022delay\u0022,\u0022type\u0022:\u0022uint128\u0022}],\u0022name\u0022:\u0022stop\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022index\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022take\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022stakee\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022delay\u0022,\u0022type\u0022:\u0022uint128\u0022}],\u0022name\u0022:\u0022wait\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022what\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"OrchidDirectory","CompilerVersion":"v0.5.13\u002Bcommit.5b0b510c","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"0000000000000000000000004575f41308ec1483f3d399aa9a2826d74da13deb","Library":"","SwarmSource":"bzzr://f85a87801f9df089d4cd9fe0c36c44be616242965847021b990f74203975cc26"}]