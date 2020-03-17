[{"SourceCode":"pragma solidity 0.5.11;\r\n\r\ninterface GemLike {\r\n    function approve(address, uint) external;\r\n    function transfer(address, uint) external;\r\n    function transferFrom(address, address, uint) external;\r\n    function deposit() external payable;\r\n    function withdraw(uint) external;\r\n}\r\n\r\ninterface ManagerLike {\r\n    function cdpCan(address, uint, address) external view returns (uint);\r\n    function ilks(uint) external view returns (bytes32);\r\n    function owns(uint) external view returns (address);\r\n    function urns(uint) external view returns (address);\r\n    function vat() external view returns (address);\r\n    function open(bytes32, address) external returns (uint);\r\n    function give(uint, address) external;\r\n    function cdpAllow(uint, address, uint) external;\r\n    function urnAllow(address, uint) external;\r\n    function frob(uint, int, int) external;\r\n    function flux(uint, address, uint) external;\r\n    function move(uint, address, uint) external;\r\n    function exit(\r\n        address,\r\n        uint,\r\n        address,\r\n        uint\r\n    ) external;\r\n    function quit(uint, address) external;\r\n    function enter(address, uint) external;\r\n    function shift(uint, uint) external;\r\n}\r\n\r\ninterface VatLike {\r\n    function can(address, address) external view returns (uint);\r\n    function ilks(bytes32) external view returns (uint, uint, uint, uint, uint);\r\n    function dai(address) external view returns (uint);\r\n    function urns(bytes32, address) external view returns (uint, uint);\r\n    function frob(\r\n        bytes32,\r\n        address,\r\n        address,\r\n        address,\r\n        int,\r\n        int\r\n    ) external;\r\n    function hope(address) external;\r\n    function move(address, address, uint) external;\r\n}\r\n\r\ninterface GemJoinLike {\r\n    function dec() external returns (uint);\r\n    function gem() external returns (GemLike);\r\n    function join(address, uint) external payable;\r\n    function exit(address, uint) external;\r\n}\r\n\r\ninterface DaiJoinLike {\r\n    function vat() external returns (VatLike);\r\n    function dai() external returns (GemLike);\r\n    function join(address, uint) external payable;\r\n    function exit(address, uint) external;\r\n}\r\n\r\ninterface HopeLike {\r\n    function hope(address) external;\r\n    function nope(address) external;\r\n}\r\n\r\ninterface JugLike {\r\n    function drip(bytes32) external returns (uint);\r\n}\r\n\r\ninterface ProxyRegistryLike {\r\n    function proxies(address) external view returns (address);\r\n    function build(address) external returns (address);\r\n}\r\n\r\ninterface ProxyLike {\r\n    function owner() external view returns (address);\r\n}\r\n\r\ninterface InstaMcdAddress {\r\n    function manager() external returns (address);\r\n    function dai() external returns (address);\r\n    function daiJoin() external returns (address);\r\n    function jug() external returns (address);\r\n    function proxyRegistry() external returns (address);\r\n    function ethAJoin() external returns (address);\r\n}\r\n\r\n\r\ncontract Common {\r\n    uint256 constant RAY = 10 ** 27;\r\n\r\n    /**\r\n     * @dev get MakerDAO MCD Address contract\r\n     */\r\n    function getMcdAddresses() public pure returns (address mcd) {\r\n        mcd = 0xF23196DF1C440345DE07feFbe556a5eF0dcD29F0; // Check Thrilok - add addr at time of deploy\r\n    }\r\n\r\n    /**\r\n     * @dev get InstaDApp CDP\u0027s Address\r\n     */\r\n    function getGiveAddress() public pure returns (address addr) {\r\n        addr = 0xc679857761beE860f5Ec4B3368dFE9752580B096;\r\n    }\r\n\r\n    function mul(uint x, uint y) internal pure returns (uint z) {\r\n        require(y == 0 || (z = x * y) / y == x, \u0022mul-overflow\u0022);\r\n    }\r\n\r\n    function sub(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x - y) \u003C= x, \u0022sub-overflow\u0022);\r\n    }\r\n\r\n    function toInt(uint x) internal pure returns (int y) {\r\n        y = int(x);\r\n        require(y \u003E= 0, \u0022int-overflow\u0022);\r\n    }\r\n\r\n    function toRad(uint wad) internal pure returns (uint rad) {\r\n        rad = mul(wad, 10 ** 27);\r\n    }\r\n\r\n    function convertTo18(address gemJoin, uint256 amt) internal returns (uint256 wad) {\r\n        // For those collaterals that have less than 18 decimals precision we need to do the conversion before passing to frob function\r\n        // Adapters will automatically handle the difference of precision\r\n        wad = mul(\r\n            amt,\r\n            10 ** (18 - GemJoinLike(gemJoin).dec())\r\n        );\r\n    }\r\n}\r\n\r\n\r\ncontract DssProxyHelpers is Common {\r\n    // Internal functions\r\n    function joinDaiJoin(address urn, uint wad) public {\r\n        address daiJoin = InstaMcdAddress(getMcdAddresses()).daiJoin();\r\n        // Gets DAI from the user\u0027s wallet\r\n        DaiJoinLike(daiJoin).dai().transferFrom(msg.sender, address(this), wad);\r\n        // Approves adapter to take the DAI amount\r\n        DaiJoinLike(daiJoin).dai().approve(daiJoin, wad);\r\n        // Joins DAI into the vat\r\n        DaiJoinLike(daiJoin).join(urn, wad);\r\n    }\r\n\r\n    function _getDrawDart(\r\n        address vat,\r\n        address jug,\r\n        address urn,\r\n        bytes32 ilk,\r\n        uint wad\r\n    ) internal returns (int dart)\r\n    {\r\n        // Updates stability fee rate\r\n        uint rate = JugLike(jug).drip(ilk);\r\n\r\n        // Gets DAI balance of the urn in the vat\r\n        uint dai = VatLike(vat).dai(urn);\r\n\r\n        // If there was already enough DAI in the vat balance, just exits it without adding more debt\r\n        if (dai \u003C mul(wad, RAY)) {\r\n            // Calculates the needed dart so together with the existing dai in the vat is enough to exit wad amount of DAI tokens\r\n            dart = toInt(sub(mul(wad, RAY), dai) / rate);\r\n            // This is neeeded due lack of precision. It might need to sum an extra dart wei (for the given DAI wad amount)\r\n            dart = mul(uint(dart), rate) \u003C mul(wad, RAY) ? dart \u002B 1 : dart;\r\n        }\r\n    }\r\n\r\n    function _getWipeDart(\r\n        address vat,\r\n        uint dai,\r\n        address urn,\r\n        bytes32 ilk\r\n    ) internal view returns (int dart)\r\n    {\r\n        // Gets actual rate from the vat\r\n        (, uint rate,,,) = VatLike(vat).ilks(ilk);\r\n        // Gets actual art value of the urn\r\n        (, uint art) = VatLike(vat).urns(ilk, urn);\r\n\r\n        // Uses the whole dai balance in the vat to reduce the debt\r\n        dart = toInt(dai / rate);\r\n        // Checks the calculated dart is not higher than urn.art (total debt), otherwise uses its value\r\n        dart = uint(dart) \u003C= art ? - dart : - toInt(art);\r\n    }\r\n\r\n    function _getWipeAllWad(\r\n        address vat,\r\n        address usr,\r\n        address urn,\r\n        bytes32 ilk\r\n    ) internal view returns (uint wad)\r\n    {\r\n        // Gets actual rate from the vat\r\n        (, uint rate,,,) = VatLike(vat).ilks(ilk);\r\n        // Gets actual art value of the urn\r\n        (, uint art) = VatLike(vat).urns(ilk, urn);\r\n        // Gets actual dai amount in the urn\r\n        uint dai = VatLike(vat).dai(usr);\r\n\r\n        uint rad = sub(mul(art, rate), dai);\r\n        wad = rad / RAY;\r\n\r\n        // If the rad precision has some dust, it will need to request for 1 extra wad wei\r\n        wad = mul(wad, RAY) \u003C rad ? wad \u002B 1 : wad;\r\n    }\r\n}\r\n\r\n\r\ncontract DssProxyActions is DssProxyHelpers {\r\n    // Public functions\r\n\r\n    function transfer(address gem, address dst, uint wad) public {\r\n        GemLike(gem).transfer(dst, wad);\r\n    }\r\n\r\n    function joinEthJoin(address urn) public payable {\r\n        address ethJoin = InstaMcdAddress(getMcdAddresses()).ethAJoin();\r\n        // Wraps ETH in WETH\r\n        GemJoinLike(ethJoin).gem().deposit.value(msg.value)();\r\n        // Approves adapter to take the WETH amount\r\n        GemJoinLike(ethJoin).gem().approve(address(ethJoin), msg.value);\r\n        // Joins WETH collateral into the vat\r\n        GemJoinLike(ethJoin).join(urn, msg.value);\r\n    }\r\n\r\n    function joinGemJoin(\r\n        address apt,\r\n        address urn,\r\n        uint wad,\r\n        bool transferFrom\r\n    ) public\r\n    {\r\n        // Only executes for tokens that have approval/transferFrom implementation\r\n        if (transferFrom) {\r\n            // Gets token from the user\u0027s wallet\r\n            GemJoinLike(apt).gem().transferFrom(msg.sender, address(this), wad);\r\n            // Approves adapter to take the token amount\r\n            GemJoinLike(apt).gem().approve(apt, wad);\r\n        }\r\n        // Joins token collateral into the vat\r\n        GemJoinLike(apt).join(urn, wad);\r\n    }\r\n\r\n    function hope(address obj, address usr) public {\r\n        HopeLike(obj).hope(usr);\r\n    }\r\n\r\n    function nope(address obj, address usr) public {\r\n        HopeLike(obj).nope(usr);\r\n    }\r\n\r\n    function open(bytes32 ilk, address usr) public returns (uint cdp) {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        cdp = ManagerLike(manager).open(ilk, usr);\r\n    }\r\n\r\n    function give(uint cdp, address usr) public {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        ManagerLike(manager).give(cdp, usr);\r\n    }\r\n\r\n    function shut(uint cdp) public {\r\n        give(cdp, getGiveAddress());\r\n    }\r\n\r\n    function giveToProxy(uint cdp, address dst) public {\r\n        address proxyRegistry = InstaMcdAddress(getMcdAddresses()).proxyRegistry(); //CHECK THRILOK -- Added proxyRegistry\r\n        // Gets actual proxy address\r\n        address proxy = ProxyRegistryLike(proxyRegistry).proxies(dst);\r\n        // Checks if the proxy address already existed and dst address is still the owner\r\n        if (proxy == address(0) || ProxyLike(proxy).owner() != dst) {\r\n            uint csize;\r\n            assembly {\r\n                csize := extcodesize(dst)\r\n            }\r\n            // We want to avoid creating a proxy for a contract address that might not be able to handle proxies, then losing the CDP\r\n            require(csize == 0, \u0022Dst-is-a-contract\u0022);\r\n            // Creates the proxy for the dst address\r\n            proxy = ProxyRegistryLike(proxyRegistry).build(dst);\r\n        }\r\n        // Transfers CDP to the dst proxy\r\n        give(cdp, proxy);\r\n    }\r\n\r\n    function cdpAllow(uint cdp, address usr, uint ok) public {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        ManagerLike(manager).cdpAllow(cdp, usr, ok);\r\n    }\r\n\r\n    function urnAllow(address usr, uint ok) public {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        ManagerLike(manager).urnAllow(usr, ok);\r\n    }\r\n\r\n    function flux(uint cdp, address dst, uint wad) public {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        ManagerLike(manager).flux(cdp, dst, wad);\r\n    }\r\n\r\n    function move(uint cdp, address dst, uint rad) public {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        ManagerLike(manager).move(cdp, dst, rad);\r\n    }\r\n\r\n    function frob(uint cdp, int dink, int dart) public {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        ManagerLike(manager).frob(cdp, dink, dart);\r\n    }\r\n\r\n    function quit(uint cdp, address dst) public {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        ManagerLike(manager).quit(cdp, dst);\r\n    }\r\n\r\n    function enter(address src, uint cdp) public {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        ManagerLike(manager).enter(src, cdp);\r\n    }\r\n\r\n    function shift(uint cdpSrc, uint cdpOrg) public {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        ManagerLike(manager).shift(cdpSrc, cdpOrg);\r\n    }\r\n\r\n    function lockETH(uint cdp) public payable {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        // Receives ETH amount, converts it to WETH and joins it into the vat\r\n        joinEthJoin(address(this));\r\n        // Locks WETH amount into the CDP\r\n        VatLike(ManagerLike(manager).vat()).frob(\r\n            ManagerLike(manager).ilks(cdp),\r\n            ManagerLike(manager).urns(cdp),\r\n            address(this),\r\n            address(this),\r\n            toInt(msg.value),\r\n            0\r\n        );\r\n    }\r\n\r\n    function safeLockETH(uint cdp, address owner) public payable {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        require(ManagerLike(manager).owns(cdp) == owner, \u0022owner-missmatch\u0022);\r\n        lockETH(cdp);\r\n    }\r\n\r\n    function lockGem(\r\n        address gemJoin,\r\n        uint cdp,\r\n        uint wad,\r\n        bool transferFrom\r\n    ) public\r\n    {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        // Takes token amount from user\u0027s wallet and joins into the vat\r\n        joinGemJoin(\r\n            gemJoin,\r\n            address(this),\r\n            wad,\r\n            transferFrom\r\n        );\r\n        // Locks token amount into the CDP\r\n        VatLike(ManagerLike(manager).vat()).frob(\r\n            ManagerLike(manager).ilks(cdp),\r\n            ManagerLike(manager).urns(cdp),\r\n            address(this),\r\n            address(this),\r\n            toInt(convertTo18(gemJoin, wad)),\r\n            0\r\n        );\r\n    }\r\n\r\n    function safeLockGem(\r\n        address gemJoin,\r\n        uint cdp,\r\n        uint wad,\r\n        bool transferFrom,\r\n        address owner\r\n    ) public\r\n    {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        require(ManagerLike(manager).owns(cdp) == owner, \u0022owner-missmatch\u0022);\r\n        lockGem(\r\n            gemJoin,\r\n            cdp,\r\n            wad,\r\n            transferFrom);\r\n    }\r\n\r\n    function freeETH(uint cdp, uint wad) public {\r\n        address ethJoin = InstaMcdAddress(getMcdAddresses()).ethAJoin();\r\n        // Unlocks WETH amount from the CDP\r\n        frob(\r\n            cdp,\r\n            -toInt(wad),\r\n            0\r\n        );\r\n        // Moves the amount from the CDP urn to proxy\u0027s address\r\n        flux(\r\n            cdp,\r\n            address(this),\r\n            wad\r\n        );\r\n        // Exits WETH amount to proxy address as a token\r\n        GemJoinLike(ethJoin).exit(address(this), wad);\r\n        // Converts WETH to ETH\r\n        GemJoinLike(ethJoin).gem().withdraw(wad);\r\n        // Sends ETH back to the user\u0027s wallet\r\n        msg.sender.transfer(wad);\r\n    }\r\n\r\n    function freeGem(address gemJoin, uint cdp, uint wad) public {\r\n        uint wad18 = convertTo18(gemJoin, wad);\r\n        // Unlocks token amount from the CDP\r\n        frob(\r\n            cdp,\r\n            -toInt(wad18),\r\n            0\r\n        );\r\n        // Moves the amount from the CDP urn to proxy\u0027s address\r\n        flux(\r\n            cdp,\r\n            address(this),\r\n            wad18\r\n        );\r\n        // Exits token amount to the user\u0027s wallet as a token\r\n        GemJoinLike(gemJoin).exit(msg.sender, wad);\r\n    }\r\n\r\n    function exitETH(uint cdp, uint wad) public {\r\n        address ethJoin = InstaMcdAddress(getMcdAddresses()).ethAJoin();\r\n        // Moves the amount from the CDP urn to proxy\u0027s address\r\n        flux(\r\n            cdp,\r\n            address(this),\r\n            wad\r\n        );\r\n\r\n        // Exits WETH amount to proxy address as a token\r\n        GemJoinLike(ethJoin).exit(address(this), wad);\r\n        // Converts WETH to ETH\r\n        GemJoinLike(ethJoin).gem().withdraw(wad);\r\n        // Sends ETH back to the user\u0027s wallet\r\n        msg.sender.transfer(wad);\r\n    }\r\n\r\n    function exitGem(address gemJoin, uint cdp, uint wad) public {\r\n        // Moves the amount from the CDP urn to proxy\u0027s address\r\n        flux(\r\n            cdp,\r\n            address(this),\r\n            convertTo18(gemJoin, wad)\r\n        );\r\n\r\n        // Exits token amount to the user\u0027s wallet as a token\r\n        GemJoinLike(gemJoin).exit(msg.sender, wad);\r\n    }\r\n\r\n    function draw(uint cdp, uint wad) public {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        address jug = InstaMcdAddress(getMcdAddresses()).jug();\r\n        address daiJoin = InstaMcdAddress(getMcdAddresses()).daiJoin();\r\n        address urn = ManagerLike(manager).urns(cdp);\r\n        address vat = ManagerLike(manager).vat();\r\n        bytes32 ilk = ManagerLike(manager).ilks(cdp);\r\n        // Generates debt in the CDP\r\n        frob(\r\n            cdp,\r\n            0,\r\n            _getDrawDart(\r\n                vat,\r\n                jug,\r\n                urn,\r\n                ilk,\r\n                wad\r\n            )\r\n        );\r\n        // Moves the DAI amount (balance in the vat in rad) to proxy\u0027s address\r\n        move(\r\n            cdp,\r\n            address(this),\r\n            toRad(wad)\r\n        );\r\n        // Allows adapter to access to proxy\u0027s DAI balance in the vat\r\n        if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {\r\n            VatLike(vat).hope(daiJoin);\r\n        }\r\n        // Exits DAI to the user\u0027s wallet as a token\r\n        DaiJoinLike(daiJoin).exit(msg.sender, wad);\r\n    }\r\n\r\n    function wipe(uint cdp, uint wad) public {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        address vat = ManagerLike(manager).vat();\r\n        address urn = ManagerLike(manager).urns(cdp);\r\n        bytes32 ilk = ManagerLike(manager).ilks(cdp);\r\n\r\n        address own = ManagerLike(manager).owns(cdp);\r\n        if (own == address(this) || ManagerLike(manager).cdpCan(own, cdp, address(this)) == 1) {\r\n            // Joins DAI amount into the vat\r\n            joinDaiJoin(urn, wad);\r\n            // Paybacks debt to the CDP\r\n            frob(\r\n                cdp,\r\n                0,\r\n                _getWipeDart(\r\n                    vat,\r\n                    VatLike(vat).dai(urn),\r\n                    urn,\r\n                    ilk\r\n                )\r\n            );\r\n        } else {\r\n             // Joins DAI amount into the vat\r\n            joinDaiJoin(address(this), wad);\r\n            // Paybacks debt to the CDP\r\n            VatLike(vat).frob(\r\n                ilk,\r\n                urn,\r\n                address(this),\r\n                address(this),\r\n                0,\r\n                _getWipeDart(\r\n                    vat,\r\n                    wad * RAY,\r\n                    urn,\r\n                    ilk\r\n                )\r\n            );\r\n        }\r\n    }\r\n\r\n    function safeWipe(uint cdp, uint wad, address owner) public {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        require(ManagerLike(manager).owns(cdp) == owner, \u0022owner-missmatch\u0022);\r\n        wipe(\r\n            cdp,\r\n            wad\r\n        );\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022ok\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022cdpAllow\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getGiveAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022gemJoin\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022exitGem\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022quit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022safeWipe\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022int256\u0022,\u0022name\u0022:\u0022dink\u0022,\u0022type\u0022:\u0022int256\u0022},{\u0022internalType\u0022:\u0022int256\u0022,\u0022name\u0022:\u0022dart\u0022,\u0022type\u0022:\u0022int256\u0022}],\u0022name\u0022:\u0022frob\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022urn\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022joinDaiJoin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022ilk\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022open\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022gemJoin\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022freeGem\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022enter\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022urn\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022joinEthJoin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022exitETH\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022lockETH\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022apt\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022urn\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022transferFrom\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022joinGemJoin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022flux\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022obj\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022nope\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022giveToProxy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022freeETH\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022obj\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022hope\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022ok\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022urnAllow\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022gem\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022gemJoin\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022transferFrom\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022lockGem\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getMcdAddresses\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022mcd\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022draw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022wipe\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022shut\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdpSrc\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdpOrg\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022shift\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022gemJoin\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022transferFrom\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022safeLockGem\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022safeLockETH\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022dst\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022move\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022usr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022give\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"DssProxyActions","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://25ca1a81d2edb9cda0b37235aebb11f489a55455cc2db868484c0bc49bc0c491"}]