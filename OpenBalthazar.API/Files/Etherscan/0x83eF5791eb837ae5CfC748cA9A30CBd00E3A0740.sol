[{"SourceCode":"{\u0022erc20.sol\u0022:{\u0022content\u0022:\u0022/// erc20.sol -- API for the ERC20 token standard\\r\\n\\r\\n// See \\u003chttps://github.com/ethereum/EIPs/issues/20\\u003e.\\r\\n\\r\\n// This file likely does not meet the threshold of originality\\r\\n// required for copyright to apply.  As a result, this is free and\\r\\n// unencumbered software belonging to the public domain.\\r\\n\\r\\npragma solidity ^0.4.8;\\r\\n\\r\\ncontract ERC20Events {\\r\\n    event Approval(address indexed src, address indexed guy, uint wad);\\r\\n    event Transfer(address indexed src, address indexed dst, uint wad);\\r\\n}\\r\\n\\r\\ncontract ERC20 is ERC20Events {\\r\\n    function totalSupply() public view returns (uint);\\r\\n    function balanceOf(address guy) public view returns (uint);\\r\\n    function allowance(address src, address guy) public view returns (uint);\\r\\n\\r\\n    function approve(address guy, uint wad) public returns (bool);\\r\\n    function transfer(address dst, uint wad) public returns (bool);\\r\\n    function transferFrom(\\r\\n        address src, address dst, uint wad\\r\\n    ) public returns (bool);\\r\\n}\u0022},\u0022hex-otc.sol\u0022:{\u0022content\u0022:\u0022/// hex-otc.sol\\r\\n//\\r\\n// This program is free software: you can redistribute it and/or modify it\\r\\n//\\r\\n// This program is distributed in the hope that it will be useful,\\r\\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\\r\\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.\\r\\n//\\r\\n\\r\\npragma solidity ^0.4.18;\\r\\n\\r\\nimport \\\u0022./math.sol\\\u0022;\\r\\nimport \\\u0022./erc20.sol\\\u0022;\\r\\n\\r\\ncontract EventfulMarket {\\r\\n\\r\\n    event LogItemUpdate(uint id);\\r\\n\\r\\n    event LogTrade(uint pay_amt, uint buy_amt, uint escrowType);\\r\\n\\r\\n    event LogClose(\\r\\n        bytes32  indexed  id,\\r\\n        address  indexed  maker,\\r\\n        uint           pay_amt,\\r\\n        uint           buy_amt,\\r\\n        uint64            timestamp,\\r\\n        uint              escrowType\\r\\n    );\\r\\n\\r\\n    event LogMake(\\r\\n        bytes32  indexed  id,\\r\\n        address  indexed  maker,\\r\\n        uint           pay_amt,\\r\\n        uint           buy_amt,\\r\\n        uint64            timestamp,\\r\\n        uint              escrowType\\r\\n    );\\r\\n\\r\\n    event LogBump(\\r\\n        bytes32  indexed  id,\\r\\n        address  indexed  maker,\\r\\n        uint           pay_amt,\\r\\n        uint           buy_amt,\\r\\n        uint64            timestamp,\\r\\n        uint              escrowType\\r\\n    );\\r\\n\\r\\n    event LogTake(\\r\\n        bytes32           id,\\r\\n        address  indexed  maker,\\r\\n        address  indexed  taker,\\r\\n        uint          take_amt,\\r\\n        uint           give_amt,\\r\\n        uint64            timestamp,\\r\\n        uint              escrowType\\r\\n    );\\r\\n\\r\\n    event LogKill(\\r\\n        bytes32  indexed  id,\\r\\n        address  indexed  maker,\\r\\n        uint           pay_amt,\\r\\n        uint           buy_amt,\\r\\n        uint64            timestamp,\\r\\n        uint              escrowType\\r\\n    );\\r\\n}\\r\\n\\r\\ncontract SimpleMarket is EventfulMarket, DSMath {\\r\\n\\r\\n    ERC20 hexInterface;\\r\\n    address constant hexAddress = 0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39;\\r\\n    uint constant hexDecimals = 8;\\r\\n    uint public last_offer_id;\\r\\n\\r\\n    mapping (uint =\\u003e OfferInfo) public offers;\\r\\n\\r\\n    bool locked;\\r\\n\\r\\n    struct OfferInfo {\\r\\n        uint     pay_amt;\\r\\n        uint     buy_amt;\\r\\n        address  owner;\\r\\n        uint64   timestamp;\\r\\n        bytes32  offerId;\\r\\n        uint   escrowType; //0 HEX - 1 ETH\\r\\n    }\\r\\n\\r\\n    modifier can_buy(uint id) {\\r\\n        require(isActive(id), \\\u0022cannot buy, offer ID not active\\\u0022);\\r\\n        _;\\r\\n    }\\r\\n\\r\\n    modifier can_cancel(uint id) {\\r\\n        require(isActive(id), \\\u0022cannot cancel, offer ID not active\\\u0022);\\r\\n        require(getOwner(id) == msg.sender, \\\u0022cannot cancel, msg.sender not the same as offer maker\\\u0022);\\r\\n        _;\\r\\n    }\\r\\n\\r\\n    modifier can_offer {\\r\\n        _;\\r\\n    }\\r\\n\\r\\n    modifier synchronized {\\r\\n        require(!locked, \\\u0022Sync lock\\\u0022);\\r\\n        locked = true;\\r\\n        _;\\r\\n        locked = false;\\r\\n    }\\r\\n\\r\\n    constructor() public{\\r\\n            hexInterface = ERC20(hexAddress);\\r\\n    }\\r\\n\\r\\n    function isActive(uint id) public view returns (bool active) {\\r\\n        return offers[id].timestamp \\u003e 0;\\r\\n    }\\r\\n\\r\\n    function getOwner(uint id) public view returns (address owner) {\\r\\n        return offers[id].owner;\\r\\n    }\\r\\n\\r\\n    function getOffer(uint id) public view returns (uint, uint, bytes32) {\\r\\n      var offer = offers[id];\\r\\n      return (offer.pay_amt, offer.buy_amt, offer.offerId);\\r\\n    }\\r\\n\\r\\n    // ---- Public entrypoints ---- //\\r\\n\\r\\n    function bump(bytes32 id_)\\r\\n        public\\r\\n        can_buy(uint256(id_))\\r\\n    {\\r\\n        uint256 id = uint256(id_);\\r\\n        emit LogBump(\\r\\n            id_,\\r\\n            offers[id].owner,\\r\\n            uint(offers[id].pay_amt),\\r\\n            uint(offers[id].buy_amt),\\r\\n            offers[id].timestamp,\\r\\n            offers[id].escrowType\\r\\n        );\\r\\n    }\\r\\n\\r\\n    // Accept given \u0060quantity\u0060 of an offer. Transfers funds from caller to\\r\\n    // offer maker, and from market to caller.\\r\\n    function buyHEX(uint id, uint quantity) //quantiiy in wei\\r\\n        public\\r\\n        payable\\r\\n        can_buy(id)\\r\\n        synchronized\\r\\n        returns (bool)\\r\\n    {\\r\\n        OfferInfo memory offer = offers[id];\\r\\n        uint spend = mul(quantity, offer.buy_amt) / offer.pay_amt;\\r\\n        require(offer.escrowType == 0, \\\u0022Incorrect escrow type\\\u0022);\\r\\n        require(msg.value \\u003e 0 \\u0026\\u0026 msg.value == spend, \\\u0022msg.value error\\\u0022);\\r\\n\\r\\n        // for backwards semantic compatibility.\\r\\n        if (quantity == 0 || spend == 0 ||\\r\\n            quantity \\u003e offer.pay_amt || spend \\u003e offer.buy_amt)\\r\\n        {\\r\\n            return false;\\r\\n        }\\r\\n\\r\\n        offers[id].pay_amt = sub(offer.pay_amt, quantity);\\r\\n        offers[id].buy_amt = sub(offer.buy_amt, spend);\\r\\n\\r\\n        offer.owner.transfer(msg.value);//send eth to offer maker (seller)\\r\\n        require(hexInterface.transfer(msg.sender, quantity), \\\u0022Transfer failed\\\u0022); //send escrowed hex from contract to offer taker (buyer)\\r\\n\\r\\n        emit LogItemUpdate(id);\\r\\n        emit LogTake(\\r\\n            bytes32(id),\\r\\n            offer.owner,\\r\\n            msg.sender,\\r\\n            uint(quantity),\\r\\n            uint(spend),\\r\\n            uint64(now),\\r\\n            offer.escrowType\\r\\n        );\\r\\n        emit LogTrade(quantity, spend, offer.escrowType);\\r\\n\\r\\n        if (offers[id].pay_amt == 0) {\\r\\n            emit LogClose(bytes32(id), offers[id].owner, offers[id].pay_amt, offers[id].buy_amt, uint64(now), offers[id].escrowType);\\r\\n            delete offers[id];\\r\\n        }\\r\\n\\r\\n        return true;\\r\\n    }\\r\\n\\r\\n    // Accept given \u0060quantity\u0060 of an offer. Transfers funds from caller to\\r\\n    // offer maker, and from market to caller.\\r\\n    function buyETH(uint id, uint quantity) // quantity in hearts\\r\\n        public\\r\\n        can_buy(id)\\r\\n        synchronized\\r\\n        returns (bool)\\r\\n    {\\r\\n        OfferInfo memory offer = offers[id];\\r\\n        uint spend = mul(quantity, offer.buy_amt) / offer.pay_amt;\\r\\n        require(offer.escrowType == 1, \\\u0022Incorrect escrow type\\\u0022);\\r\\n        require(hexInterface.balanceOf(msg.sender) \\u003e= spend, \\\u0022Balance is less than requested spend amount\\\u0022);\\r\\n\\r\\n        // for backwards semantic compatibility.\\r\\n        if (quantity == 0 || spend == 0 ||\\r\\n            quantity \\u003e offer.pay_amt || spend \\u003e offer.buy_amt)\\r\\n        {\\r\\n            return false;\\r\\n        }\\r\\n\\r\\n        offers[id].pay_amt = sub(offer.pay_amt, quantity);\\r\\n        offers[id].buy_amt = sub(offer.buy_amt, spend);\\r\\n\\r\\n        require(hexInterface.transferFrom(msg.sender, offer.owner, spend), \\\u0022Transfer failed\\\u0022);//send HEX to offer maker (seller)\\r\\n        msg.sender.transfer(quantity);//send ETH to offer taker (buyer)\\r\\n\\r\\n        emit LogItemUpdate(id);\\r\\n        emit LogTake(\\r\\n            bytes32(id),\\r\\n            offer.owner,\\r\\n            msg.sender,\\r\\n            uint(quantity),\\r\\n            uint(spend),\\r\\n            uint64(now),\\r\\n            offer.escrowType\\r\\n        );\\r\\n        emit LogTrade(quantity, spend, offer.escrowType);\\r\\n\\r\\n        if (offers[id].pay_amt == 0) {\\r\\n            emit LogClose(bytes32(id), offers[id].owner, offers[id].pay_amt, offers[id].buy_amt, uint64(now), offers[id].escrowType);\\r\\n            delete offers[id];\\r\\n        }\\r\\n\\r\\n        return true;\\r\\n    }\\r\\n\\r\\n    // cancel an offer, refunds offer maker.\\r\\n    function cancel(uint id)\\r\\n        public\\r\\n        can_cancel(id)\\r\\n        synchronized\\r\\n        returns (bool success)\\r\\n    {\\r\\n        // read-only offer. Modify an offer by directly accessing offers[id]\\r\\n        OfferInfo memory offer = offers[id];\\r\\n        delete offers[id];\\r\\n        if(offer.escrowType == 0){ //hex\\r\\n            require(hexInterface.transfer(offer.owner, offer.pay_amt), \\\u0022Transfer failed\\\u0022);\\r\\n        }\\r\\n        else{ //eth\\r\\n            offer.owner.transfer(offer.pay_amt);\\r\\n        }\\r\\n        emit LogItemUpdate(id);\\r\\n        emit LogKill(\\r\\n            bytes32(id),\\r\\n            offer.owner,\\r\\n            uint(offer.pay_amt),\\r\\n            uint(offer.buy_amt),\\r\\n            uint64(now),\\r\\n            offer.escrowType\\r\\n        );\\r\\n\\r\\n        success = true;\\r\\n    }\\r\\n\\r\\n    //cancel\\r\\n    function kill(bytes32 id)\\r\\n        public\\r\\n    {\\r\\n        require(cancel(uint256(id)), \\\u0022Error on cancel order.\\\u0022);\\r\\n    }\\r\\n\\r\\n    //make\\r\\n    function make(\\r\\n        uint  pay_amt,\\r\\n        uint  buy_amt\\r\\n    )\\r\\n        public\\r\\n        payable\\r\\n        returns (bytes32 id)\\r\\n    {\\r\\n        if(msg.value \\u003e 0){\\r\\n            return bytes32(offerETH(pay_amt, buy_amt));\\r\\n        }\\r\\n        else{\\r\\n            return bytes32(offerHEX(pay_amt, buy_amt));\\r\\n        }\\r\\n    }\\r\\n\\r\\n    // make a new offer to sell ETH. Takes ETH funds from the caller into market escrow.\\r\\n    function offerETH(uint pay_amt, uint buy_amt) //amounts in wei / hearts\\r\\n        public\\r\\n        payable\\r\\n        can_offer\\r\\n        synchronized\\r\\n        returns (uint id)\\r\\n    {\\r\\n        require(pay_amt \\u003e 0, \\\u0022pay_amt is 0\\\u0022);\\r\\n        require(buy_amt \\u003e 0, \\\u0022buy_amt is 0\\\u0022);\\r\\n        require(pay_amt == msg.value, \\\u0022pay_amt not equal to msg.value\\\u0022);\\r\\n        newOffer(id, pay_amt, buy_amt, 1);\\r\\n        emit LogItemUpdate(id);\\r\\n        emit LogMake(\\r\\n            bytes32(id),\\r\\n            msg.sender,\\r\\n            uint(pay_amt),\\r\\n            uint(buy_amt),\\r\\n            uint64(now),\\r\\n            1\\r\\n        );\\r\\n    }\\r\\n\\r\\n    // make a new offer to sell HEX. Takes HEX funds from the caller into market escrow.\\r\\n    function offerHEX(uint pay_amt, uint buy_amt) //amounts in hearts / wei\\r\\n        public\\r\\n        can_offer\\r\\n        synchronized\\r\\n        returns (uint id)\\r\\n    {\\r\\n        require(hexInterface.balanceOf(msg.sender) \\u003e= pay_amt, \\\u0022Insufficient balanceOf hex\\\u0022);\\r\\n        require(pay_amt \\u003e 0, \\\u0022pay_amt is 0\\\u0022);\\r\\n        require(buy_amt \\u003e 0,  \\\u0022buy_amt is 0\\\u0022);\\r\\n        newOffer(id, pay_amt, buy_amt, 0);\\r\\n\\r\\n        require(hexInterface.transferFrom(msg.sender, address(this), pay_amt), \\\u0022Transfer failed\\\u0022);\\r\\n\\r\\n        emit LogItemUpdate(id);\\r\\n        emit LogMake(\\r\\n            bytes32(id),\\r\\n            msg.sender,\\r\\n            uint(pay_amt),\\r\\n            uint(buy_amt),\\r\\n            uint64(now),\\r\\n            0\\r\\n        );\\r\\n    }\\r\\n\\r\\n    //formulate new offer\\r\\n    function newOffer(uint id, uint pay_amt, uint buy_amt, uint escrowType)\\r\\n        internal\\r\\n    {\\r\\n        OfferInfo memory info;\\r\\n        info.pay_amt = pay_amt;\\r\\n        info.buy_amt = buy_amt;\\r\\n        info.owner = msg.sender;\\r\\n        info.timestamp = uint64(now);\\r\\n        info.escrowType = escrowType;\\r\\n        id = _next_id();\\r\\n        info.offerId = bytes32(id);\\r\\n        offers[id] = info;\\r\\n    }\\r\\n\\r\\n    //take\\r\\n    function take(bytes32 id, uint maxTakeAmount)\\r\\n        public\\r\\n        payable\\r\\n    {\\r\\n        if(msg.value \\u003e 0){\\r\\n            require(buyHEX(uint256(id), maxTakeAmount), \\\u0022Buy HEX failed\\\u0022);\\r\\n        }\\r\\n        else{\\r\\n            require(buyETH(uint256(id), maxTakeAmount), \\\u0022Sell HEX failed\\\u0022);\\r\\n        }\\r\\n\\r\\n    }\\r\\n\\r\\n    //get next id\\r\\n    function _next_id()\\r\\n        internal\\r\\n        returns (uint)\\r\\n    {\\r\\n        last_offer_id\u002B\u002B;\\r\\n        return last_offer_id;\\r\\n    }\\r\\n}\u0022},\u0022math.sol\u0022:{\u0022content\u0022:\u0022/// math.sol -- mixin for inline numerical wizardry\\r\\n\\r\\n// This program is free software: you can redistribute it and/or modify\\r\\n// it under the terms of the GNU General Public License as published by\\r\\n// the Free Software Foundation, either version 3 of the License, or\\r\\n// (at your option) any later version.\\r\\n\\r\\n// This program is distributed in the hope that it will be useful,\\r\\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\\r\\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\\r\\n// GNU General Public License for more details.\\r\\n\\r\\n// You should have received a copy of the GNU General Public License\\r\\n// along with this program.  If not, see \\u003chttp://www.gnu.org/licenses/\\u003e.\\r\\n\\r\\npragma solidity ^0.4.13;\\r\\n\\r\\ncontract DSMath {\\r\\n    function add(uint x, uint y) internal pure returns (uint z) {\\r\\n        require((z = x \u002B y) \\u003e= x);\\r\\n    }\\r\\n    function sub(uint x, uint y) internal pure returns (uint z) {\\r\\n        require((z = x - y) \\u003c= x);\\r\\n    }\\r\\n    function mul(uint x, uint y) internal pure returns (uint z) {\\r\\n        require(y == 0 || (z = x * y) / y == x);\\r\\n    }\\r\\n\\r\\n    function min(uint x, uint y) internal pure returns (uint z) {\\r\\n        return x \\u003c= y ? x : y;\\r\\n    }\\r\\n    function max(uint x, uint y) internal pure returns (uint z) {\\r\\n        return x \\u003e= y ? x : y;\\r\\n    }\\r\\n    function imin(int x, int y) internal pure returns (int z) {\\r\\n        return x \\u003c= y ? x : y;\\r\\n    }\\r\\n    function imax(int x, int y) internal pure returns (int z) {\\r\\n        return x \\u003e= y ? x : y;\\r\\n    }\\r\\n\\r\\n    uint constant WAD = 10 ** 18;\\r\\n    uint constant RAY = 10 ** 27;\\r\\n\\r\\n    function wmul(uint x, uint y) internal pure returns (uint z) {\\r\\n        z = add(mul(x, y), WAD / 2) / WAD;\\r\\n    }\\r\\n    function rmul(uint x, uint y) internal pure returns (uint z) {\\r\\n        z = add(mul(x, y), RAY / 2) / RAY;\\r\\n    }\\r\\n    function wdiv(uint x, uint y) internal pure returns (uint z) {\\r\\n        z = add(mul(x, WAD), y / 2) / y;\\r\\n    }\\r\\n    function rdiv(uint x, uint y) internal pure returns (uint z) {\\r\\n        z = add(mul(x, RAY), y / 2) / y;\\r\\n    }\\r\\n\\r\\n    // This famous algorithm is called \\\u0022exponentiation by squaring\\\u0022\\r\\n    // and calculates x^n with x as fixed-point and n as regular unsigned.\\r\\n    //\\r\\n    // It\\u0027s O(log n), instead of O(n) for naive repeated multiplication.\\r\\n    //\\r\\n    // These facts are why it works:\\r\\n    //\\r\\n    //  If n is even, then x^n = (x^2)^(n/2).\\r\\n    //  If n is odd,  then x^n = x * x^(n-1),\\r\\n    //   and applying the equation for even x gives\\r\\n    //    x^n = x * (x^2)^((n-1) / 2).\\r\\n    //\\r\\n    //  Also, EVM division is flooring and\\r\\n    //    floor[(n-1) / 2] = floor[n / 2].\\r\\n    //\\r\\n    function rpow(uint x, uint n) internal pure returns (uint z) {\\r\\n        z = n % 2 != 0 ? x : RAY;\\r\\n\\r\\n        for (n /= 2; n != 0; n /= 2) {\\r\\n            x = rmul(x, x);\\r\\n\\r\\n            if (n % 2 != 0) {\\r\\n                z = rmul(z, x);\\r\\n            }\\r\\n        }\\r\\n    }\\r\\n}\u0022}}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022last_offer_id\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022cancel\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getOffer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id_\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022bump\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022isActive\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022active\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022offers\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022pay_amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022buy_amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022timestamp\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022offerId\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022escrowType\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022pay_amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022buy_amt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022offerHEX\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022quantity\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022buyHEX\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022pay_amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022buy_amt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022make\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022pay_amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022buy_amt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022offerETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022kill\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022maxTakeAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022take\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022quantity\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022buyETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogItemUpdate\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022pay_amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022buy_amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022escrowType\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogTrade\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022maker\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022pay_amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022buy_amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022timestamp\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022escrowType\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogClose\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022maker\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022pay_amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022buy_amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022timestamp\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022escrowType\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogMake\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022maker\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022pay_amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022buy_amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022timestamp\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022escrowType\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogBump\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022maker\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022taker\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022take_amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022give_amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022timestamp\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022escrowType\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogTake\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022maker\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022pay_amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022buy_amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022timestamp\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022escrowType\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogKill\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"SimpleMarket","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://58d35659348ba1731a7ec8619458f4c013ec94842fe6b13d9c0dda78330b9c55"}]