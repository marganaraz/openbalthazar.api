[{"SourceCode":"pragma solidity ^0.5.8;\r\n/**\r\n This scd to mcd migration works without pool.\r\n ETH free(scd) =\u003E lock(mcd) ==\u003E dai draw(mcd) =\u003E swap(dai=\u003Esai) =\u003E wipe(scd)\r\n*/\r\n\r\ninterface TubInterface {\r\n    function open() external returns (bytes32);\r\n    function join(uint) external;\r\n    function exit(uint) external;\r\n    function lock(bytes32, uint) external;\r\n    function free(bytes32, uint) external;\r\n    function draw(bytes32, uint) external;\r\n    function wipe(bytes32, uint) external;\r\n    function give(bytes32, address) external;\r\n    function shut(bytes32) external;\r\n    function cups(bytes32) external view returns (address, uint, uint, uint);\r\n    function gem() external view returns (TokenInterface);\r\n    function gov() external view returns (TokenInterface);\r\n    function skr() external view returns (TokenInterface);\r\n    function sai() external view returns (TokenInterface);\r\n    function ink(bytes32) external view returns (uint);\r\n    function tab(bytes32) external returns (uint);\r\n    function rap(bytes32) external returns (uint);\r\n    function per() external view returns (uint);\r\n    function pep() external view returns (PepInterface);\r\n}\r\n\r\ninterface TokenInterface {\r\n    function allowance(address, address) external view returns (uint);\r\n    function balanceOf(address) external view returns (uint);\r\n    function approve(address, uint) external;\r\n    function transfer(address, uint) external returns (bool);\r\n    function transferFrom(address, address, uint) external returns (bool);\r\n    function deposit() external payable;\r\n    function withdraw(uint) external;\r\n}\r\n\r\ninterface PepInterface {\r\n    function peek() external returns (bytes32, bool);\r\n}\r\n\r\ninterface UniswapExchange {\r\n    function getEthToTokenOutputPrice(uint256 tokensBought) external view returns (uint256 ethSold);\r\n    function getTokenToEthOutputPrice(uint256 ethBought) external view returns (uint256 tokensSold);\r\n    function tokenToTokenSwapOutput(\r\n        uint256 tokensBought,\r\n        uint256 maxTokensSold,\r\n        uint256 maxEthSold,\r\n        uint256 deadline,\r\n        address tokenAddr\r\n    ) external returns (uint256  tokensSold);\r\n    function ethToTokenSwapOutput(uint256 tokensBought, uint256 deadline) external payable returns (uint256  ethSold);\r\n}\r\n\r\ninterface UniswapFactoryInterface {\r\n    function getExchange(address token) external view returns (address exchange);\r\n}\r\n\r\ninterface MCDInterface {\r\n    function swapDaiToSai(uint wad) external;\r\n    function migrate(bytes32 cup) external returns (uint cdp);\r\n}\r\n\r\ninterface PoolInterface {\r\n    function accessToken(address[] calldata ctknAddr, uint[] calldata tknAmt, bool isCompound) external;\r\n    function paybackToken(address[] calldata ctknAddr, bool isCompound) external payable;\r\n}\r\n\r\ninterface OtcInterface {\r\n    function getPayAmount(address, address, uint) external view returns (uint);\r\n    function buyAllAmount(\r\n        address,\r\n        uint,\r\n        address,\r\n        uint\r\n    ) external;\r\n}\r\n\r\ninterface GemLike {\r\n    function approve(address, uint) external;\r\n    function transfer(address, uint) external;\r\n    function transferFrom(address, address, uint) external;\r\n    function deposit() external payable;\r\n    function withdraw(uint) external;\r\n}\r\n\r\ninterface JugLike {\r\n    function drip(bytes32) external returns (uint);\r\n}\r\n\r\ninterface ManagerLike {\r\n    function cdpCan(address, uint, address) external view returns (uint);\r\n    function ilks(uint) external view returns (bytes32);\r\n    function owns(uint) external view returns (address);\r\n    function urns(uint) external view returns (address);\r\n    function vat() external view returns (address);\r\n    function open(bytes32, address) external returns (uint);\r\n    function give(uint, address) external;\r\n    function cdpAllow(uint, address, uint) external;\r\n    function urnAllow(address, uint) external;\r\n    function frob(uint, int, int) external;\r\n    function flux(uint, address, uint) external;\r\n    function move(uint, address, uint) external;\r\n    function exit(\r\n        address,\r\n        uint,\r\n        address,\r\n        uint\r\n    ) external;\r\n    function quit(uint, address) external;\r\n    function enter(address, uint) external;\r\n    function shift(uint, uint) external;\r\n}\r\n\r\ninterface VatLike {\r\n    function can(address, address) external view returns (uint);\r\n    function ilks(bytes32) external view returns (uint, uint, uint, uint, uint);\r\n    function dai(address) external view returns (uint);\r\n    function urns(bytes32, address) external view returns (uint, uint);\r\n    function frob(\r\n        bytes32,\r\n        address,\r\n        address,\r\n        address,\r\n        int,\r\n        int\r\n    ) external;\r\n    function hope(address) external;\r\n    function move(address, address, uint) external;\r\n}\r\n\r\ninterface GemJoinLike {\r\n    function dec() external returns (uint);\r\n    function gem() external returns (GemLike);\r\n    function join(address, uint) external payable;\r\n    function exit(address, uint) external;\r\n}\r\n\r\ninterface GNTJoinLike {\r\n    function bags(address) external view returns (address);\r\n    function make(address) external returns (address);\r\n}\r\n\r\ninterface DaiJoinLike {\r\n    function vat() external returns (VatLike);\r\n    function dai() external returns (GemLike);\r\n    function join(address, uint) external payable;\r\n    function exit(address, uint) external;\r\n}\r\n\r\n/** Swap Functionality */\r\ninterface ScdMcdMigration {\r\n    function swapDaiToSai(uint daiAmt) external;\r\n    function swapSaiToDai(uint saiAmt) external;\r\n}\r\n\r\ninterface InstaMcdAddress {\r\n    function manager() external returns (address);\r\n    function dai() external returns (address);\r\n    function daiJoin() external returns (address);\r\n    function vat() external returns (address);\r\n    function jug() external returns (address);\r\n    function cat() external returns (address);\r\n    function gov() external returns (address);\r\n    function adm() external returns (address);\r\n    function vow() external returns (address);\r\n    function spot() external returns (address);\r\n    function pot() external returns (address);\r\n    function esm() external returns (address);\r\n    function mcdFlap() external returns (address);\r\n    function mcdFlop() external returns (address);\r\n    function mcdDeploy() external returns (address);\r\n    function mcdEnd() external returns (address);\r\n    function proxyActions() external returns (address);\r\n    function proxyActionsEnd() external returns (address);\r\n    function proxyActionsDsr() external returns (address);\r\n    function getCdps() external returns (address);\r\n    function saiTub() external returns (address);\r\n    function weth() external returns (address);\r\n    function bat() external returns (address);\r\n    function sai() external returns (address);\r\n    function ethAJoin() external returns (address);\r\n    function ethAFlip() external returns (address);\r\n    function batAJoin() external returns (address);\r\n    function batAFlip() external returns (address);\r\n    function ethPip() external returns (address);\r\n    function batAPip() external returns (address);\r\n    function saiJoin() external returns (address);\r\n    function saiFlip() external returns (address);\r\n    function saiPip() external returns (address);\r\n    function migration() external returns (address payable);\r\n}\r\n\r\ncontract DSMath {\r\n\r\n    function add(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x \u002B y) \u003E= x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    function sub(uint x, uint y) internal pure returns (uint z) {\r\n        z = x - y \u003C= x ? x - y : 0;\r\n    }\r\n\r\n    function mul(uint x, uint y) internal pure returns (uint z) {\r\n        require(y == 0 || (z = x * y) / y == x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    uint constant WAD = 10 ** 18;\r\n    uint constant RAY = 10 ** 27;\r\n\r\n    function rmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), RAY / 2) / RAY;\r\n    }\r\n\r\n    function wmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), WAD / 2) / WAD;\r\n    }\r\n\r\n    function rdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, RAY), y / 2) / y;\r\n    }\r\n\r\n    function wdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, WAD), y / 2) / y;\r\n    }\r\n\r\n    function toInt(uint x) internal pure returns (int y) {\r\n        y = int(x);\r\n        require(y \u003E= 0, \u0022int-overflow\u0022);\r\n    }\r\n\r\n    function toRad(uint wad) internal pure returns (uint rad) {\r\n        rad = mul(wad, 10 ** 27);\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract Helpers is DSMath {\r\n\r\n    /**\r\n     * @dev get MakerDAO SCD CDP engine\r\n     */\r\n    function getSaiTubAddress() public pure returns (address sai) {\r\n        sai = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;\r\n    }\r\n\r\n     /**\r\n     * @dev get MakerDAO MCD Address contract\r\n     */\r\n    function getMcdAddresses() public pure returns (address mcd) {\r\n        mcd = 0xF23196DF1C440345DE07feFbe556a5eF0dcD29F0;\r\n    }\r\n\r\n    /**\r\n     * @dev get ETH Address\r\n     */\r\n    function getETHAddress() public pure returns (address ethAddr) {\r\n        ethAddr = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // main\r\n    }\r\n\r\n    /**\r\n     * @dev get Sai (Dai v1) address\r\n     */\r\n    function getSaiAddress() public pure returns (address sai) {\r\n        sai = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;\r\n    }\r\n\r\n    /**\r\n     * @dev get Dai (Dai v2) address\r\n     */\r\n    function getDaiAddress() public pure returns (address dai) {\r\n        dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;\r\n    }\r\n\r\n    /**\r\n     * @dev get Compound WETH Address\r\n     */\r\n    function getWETHAddress() public pure returns (address wethAddr) {\r\n        wethAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // main\r\n    }\r\n\r\n    /**\r\n     * @dev get OTC Address\r\n     */\r\n    function getOtcAddress() public pure returns (address otcAddr) {\r\n        otcAddr = 0x39755357759cE0d7f32dC8dC45414CCa409AE24e; // main\r\n    }\r\n\r\n    /**\r\n     * @dev get InstaDApp CDP\u0027s Address\r\n     */\r\n    function getGiveAddress() public pure returns (address addr) {\r\n        addr = 0xc679857761beE860f5Ec4B3368dFE9752580B096;\r\n    }\r\n\r\n    /**\r\n     * @dev get uniswap MKR exchange\r\n     */\r\n    function getUniswapMKRExchange() public pure returns (address ume) {\r\n        ume = 0x2C4Bd064b998838076fa341A83d007FC2FA50957;\r\n    }\r\n\r\n    /**\r\n     * @dev get uniswap MKR exchange\r\n     */\r\n    function getUniFactoryAddr() public pure returns (address ufa) {\r\n        ufa = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;\r\n    }\r\n\r\n    /**\r\n     * @dev setting allowance if required\r\n     */\r\n    function setApproval(address erc20, uint srcAmt, address to) internal {\r\n        TokenInterface erc20Contract = TokenInterface(erc20);\r\n        uint tokenAllowance = erc20Contract.allowance(address(this), to);\r\n        if (srcAmt \u003E tokenAllowance) {\r\n            erc20Contract.approve(to, uint(-1));\r\n        }\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract MKRSwapper is  Helpers {\r\n\r\n    function getBestMkrSwap(address srcTknAddr, uint destMkrAmt) public view returns(uint bestEx, uint srcAmt) {\r\n        uint oasisPrice = getOasisSwap(srcTknAddr, destMkrAmt);\r\n        uint uniswapPrice = getUniswapSwap(srcTknAddr, destMkrAmt);\r\n        require(oasisPrice != 0 \u0026\u0026 uniswapPrice != 0, \u0022swap price 0\u0022);\r\n        srcAmt = oasisPrice \u003C uniswapPrice ? oasisPrice : uniswapPrice;\r\n        bestEx = oasisPrice \u003C uniswapPrice ? 0 : 1; // if 0 then use Oasis for Swap, if 1 then use Uniswap\r\n    }\r\n\r\n    function getOasisSwap(address tokenAddr, uint destMkrAmt) public view returns(uint srcAmt) {\r\n        TokenInterface mkr = TubInterface(getSaiTubAddress()).gov();\r\n        address srcTknAddr = tokenAddr == getETHAddress() ? getWETHAddress() : tokenAddr;\r\n        srcAmt = OtcInterface(getOtcAddress()).getPayAmount(srcTknAddr, address(mkr), destMkrAmt);\r\n    }\r\n\r\n    function getUniswapSwap(address srcTknAddr, uint destMkrAmt) public view returns(uint srcAmt) {\r\n        UniswapExchange mkrEx = UniswapExchange(getUniswapMKRExchange());\r\n        if (srcTknAddr == getETHAddress()) {\r\n            srcAmt = mkrEx.getEthToTokenOutputPrice(destMkrAmt);\r\n        } else {\r\n            address buyTknExAddr = UniswapFactoryInterface(getUniFactoryAddr()).getExchange(srcTknAddr);\r\n            UniswapExchange buyTknEx = UniswapExchange(buyTknExAddr);\r\n            srcAmt = buyTknEx.getTokenToEthOutputPrice(mkrEx.getEthToTokenOutputPrice(destMkrAmt)); //Check thrilok is this correct\r\n        }\r\n    }\r\n\r\n    function swapToMkr(address tokenAddr, uint govFee) internal {\r\n        (uint bestEx, uint srcAmt) = getBestMkrSwap(tokenAddr, govFee);\r\n        if (bestEx == 0) {\r\n            swapToMkrOtc(tokenAddr, srcAmt, govFee);\r\n        } else {\r\n            swapToMkrUniswap(tokenAddr, srcAmt, govFee);\r\n        }\r\n    }\r\n\r\n    function swapToMkrOtc(address tokenAddr, uint srcAmt, uint govFee) internal {\r\n        address mkr = InstaMcdAddress(getMcdAddresses()).gov();\r\n        address srcTknAddr = tokenAddr == getETHAddress() ? getWETHAddress() : tokenAddr;\r\n        if (srcTknAddr == getWETHAddress()) {\r\n            TokenInterface weth = TokenInterface(getWETHAddress());\r\n            weth.deposit.value(srcAmt)();\r\n        } else if (srcTknAddr != getSaiAddress() \u0026\u0026 srcTknAddr != getDaiAddress()) {\r\n            require(TokenInterface(srcTknAddr).transferFrom(msg.sender, address(this), srcAmt), \u0022Tranfer-failed\u0022);\r\n        }\r\n\r\n        setApproval(srcTknAddr, srcAmt, getOtcAddress());\r\n        OtcInterface(getOtcAddress()).buyAllAmount(\r\n            mkr,\r\n            govFee,\r\n            srcTknAddr,\r\n            srcAmt\r\n        );\r\n    }\r\n\r\n    function swapToMkrUniswap(address tokenAddr, uint srcAmt, uint govFee) internal {\r\n        UniswapExchange mkrEx = UniswapExchange(getUniswapMKRExchange());\r\n        address mkr = InstaMcdAddress(getMcdAddresses()).gov();\r\n\r\n        if (tokenAddr == getETHAddress()) {\r\n            mkrEx.ethToTokenSwapOutput.value(srcAmt)(govFee, uint(1899063809));\r\n        } else {\r\n            if (tokenAddr != getSaiAddress() \u0026\u0026 tokenAddr != getDaiAddress()) {\r\n               require(TokenInterface(tokenAddr).transferFrom(msg.sender, address(this), srcAmt), \u0022not-approved-yet\u0022);\r\n            }\r\n            address buyTknExAddr = UniswapFactoryInterface(getUniFactoryAddr()).getExchange(tokenAddr);\r\n            UniswapExchange buyTknEx = UniswapExchange(buyTknExAddr);\r\n            setApproval(tokenAddr, srcAmt, buyTknExAddr);\r\n            buyTknEx.tokenToTokenSwapOutput(\r\n                    govFee,\r\n                    srcAmt,\r\n                    uint(999000000000000000000),\r\n                    uint(1899063809), // 6th March 2030 GMT // no logic\r\n                    mkr\r\n                );\r\n        }\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract SCDResolver is MKRSwapper {\r\nfunction getFeeOfCdp(bytes32 cup, uint _wad) internal returns (uint mkrFee) {\r\n        TubInterface tub = TubInterface(getSaiTubAddress());\r\n        (bytes32 val, bool ok) = tub.pep().peek();\r\n        if (ok \u0026\u0026 val != 0) {\r\n            // MKR required for wipe = Stability fees accrued in Dai / MKRUSD value\r\n            mkrFee = rdiv(tub.rap(cup), tub.tab(cup));\r\n            mkrFee = rmul(_wad, mkrFee);\r\n            mkrFee = wdiv(mkrFee, uint(val));\r\n        }\r\n    }\r\n\r\n    function open() internal returns (bytes32 cup) {\r\n        cup = TubInterface(getSaiTubAddress()).open();\r\n    }\r\n\r\n    function wipeSai(bytes32 cup, uint _wad, address payFeeWith) internal {\r\n        if (_wad \u003E 0) {\r\n            TubInterface tub = TubInterface(getSaiTubAddress());\r\n            TokenInterface dai = tub.sai();\r\n            TokenInterface mkr = tub.gov();\r\n\r\n            (address lad,,,) = tub.cups(cup);\r\n            require(lad == address(this), \u0022cup-not-owned\u0022);\r\n\r\n            setAllowance(dai, getSaiTubAddress());\r\n            setAllowance(mkr, getSaiTubAddress());\r\n\r\n            uint mkrFee = getFeeOfCdp(cup, _wad);\r\n\r\n            if (payFeeWith != address(mkr) \u0026\u0026 mkrFee \u003E 0) {\r\n                swapToMkr(payFeeWith, mkrFee); //otc or uniswap\r\n            } else if (payFeeWith == address(mkr) \u0026\u0026 mkrFee \u003E 0) {\r\n                require(TokenInterface(address(mkr)).transferFrom(msg.sender, address(this), mkrFee), \u0022Tranfer-failed\u0022);\r\n            }\r\n\r\n            tub.wipe(cup, _wad);\r\n        }\r\n    }\r\n\r\n    function scdFree(bytes32 cup, uint jam) internal {\r\n        if (jam \u003E 0) {\r\n            address tubAddr = getSaiTubAddress();\r\n\r\n            TubInterface tub = TubInterface(tubAddr);\r\n            TokenInterface peth = tub.skr();\r\n\r\n            uint ink = rdiv(jam, tub.per());\r\n            ink = rmul(ink, tub.per()) \u003C= jam ? ink : ink - 1;\r\n            tub.free(cup, ink);\r\n\r\n            setAllowance(peth, tubAddr);\r\n\r\n            tub.exit(ink);\r\n        }\r\n    }\r\n\r\n    function setAllowance(TokenInterface _token, address _spender) private {\r\n        if (_token.allowance(address(this), _spender) != uint(-1)) {\r\n            _token.approve(_spender, uint(-1));\r\n        }\r\n    }\r\n}\r\n\r\n\r\ncontract MCDResolver is SCDResolver {\r\n    function openVault() public returns (uint cdp) {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        bytes32 ilk = 0x4554482d41000000000000000000000000000000000000000000000000000000;\r\n        cdp = ManagerLike(manager).open(ilk, address(this));\r\n    }\r\n\r\n    function mcdLock(\r\n        uint cdp,\r\n        uint ink\r\n    ) internal\r\n    {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        address ethJoin = InstaMcdAddress(getMcdAddresses()).ethAJoin();\r\n        GemJoinLike(ethJoin).gem().approve(address(ethJoin), ink);\r\n        GemJoinLike(ethJoin).join(address(this), ink);\r\n\r\n        // Locks WETH amount into the CDP\r\n        VatLike(ManagerLike(manager).vat()).frob(\r\n            ManagerLike(manager).ilks(cdp),\r\n            ManagerLike(manager).urns(cdp),\r\n            address(this),\r\n            address(this),\r\n            int(ink),\r\n            0\r\n        );\r\n    }\r\n\r\n    function daiDraw(\r\n        uint cdp,\r\n        uint wad\r\n    ) internal\r\n    {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        address jug = InstaMcdAddress(getMcdAddresses()).jug();\r\n        address daiJoin = InstaMcdAddress(getMcdAddresses()).daiJoin();\r\n        address urn = ManagerLike(manager).urns(cdp);\r\n        address vat = ManagerLike(manager).vat();\r\n        bytes32 ilk = ManagerLike(manager).ilks(cdp);\r\n        // Updates stability fee rate before generating new debt\r\n        uint rate = JugLike(jug).drip(ilk); // Check Thrilok - check if its working\r\n\r\n        int dart;\r\n        // Gets actual rate from the vat\r\n        // (, uint rate,,,) = VatLike(vat).ilks(ilk); // Check Thrilok - check if above its working\r\n        // Gets DAI balance of the urn in the vat\r\n        uint dai = VatLike(vat).dai(urn);\r\n\r\n        // If there was already enough DAI in the vat balance, just exits it without adding more debt\r\n        if (dai \u003C mul(wad, RAY)) {\r\n            // Calculates the needed dart so together with the existing dai in the vat is enough to exit wad amount of DAI tokens\r\n            dart = int(sub(mul(wad, RAY), dai) / rate);\r\n            // This is neeeded due lack of precision. It might need to sum an extra dart wei (for the given DAI wad amount)\r\n            dart = mul(uint(dart), rate) \u003C mul(wad, RAY) ? dart \u002B 1 : dart;\r\n        }\r\n\r\n        ManagerLike(manager).frob(cdp, 0, dart);\r\n        // Moves the DAI amount (balance in the vat in rad) to proxy\u0027s address\r\n        ManagerLike(manager).move(cdp, address(this), toRad(wad));\r\n        // Allows adapter to access to proxy\u0027s DAI balance in the vat\r\n        if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {\r\n            VatLike(vat).hope(daiJoin);\r\n        }\r\n        DaiJoinLike(daiJoin).exit(address(this), wad);\r\n    }\r\n}\r\n\r\n\r\ncontract MigrateHelper is MCDResolver {\r\n    function swapDaiToSai(\r\n        uint wad // Amount to swap\r\n    ) internal\r\n    {\r\n        address scdMcdMigration = InstaMcdAddress(getMcdAddresses()).migration();    // Migration contract address\r\n        TokenInterface dai = TokenInterface(getDaiAddress());\r\n        if (dai.allowance(address(this), scdMcdMigration) \u003C wad) {\r\n            dai.approve(scdMcdMigration, wad);\r\n        }\r\n        ScdMcdMigration(scdMcdMigration).swapDaiToSai(wad);\r\n    }\r\n\r\n     function setSplitAmount(\r\n        bytes32 cup,\r\n        uint toConvert,\r\n        address payFeeWith,\r\n        address saiJoin\r\n    ) internal returns (uint _wad, uint _ink, uint maxConvert)\r\n    {\r\n        // Set ratio according to user.\r\n        TubInterface tub = TubInterface(getSaiTubAddress());\r\n\r\n        maxConvert = toConvert;\r\n        uint saiBal = tub.sai().balanceOf(saiJoin);\r\n        uint _wadTotal = tub.tab(cup);\r\n\r\n        uint feeAmt = 0;\r\n\r\n        // wad according to toConvert ratio\r\n        _wad = wmul(_wadTotal, toConvert);\r\n\r\n        // if migration is by debt method, Add fee(SAI) to _wad\r\n        if (payFeeWith == getDaiAddress()) {\r\n            uint mkrAmt = getFeeOfCdp(cup, _wad);\r\n            (, feeAmt) = getBestMkrSwap(getSaiAddress(), mkrAmt);\r\n            _wad = add(_wad, feeAmt);\r\n        }\r\n\r\n        //if sai_join has enough sai to migrate.\r\n        if (saiBal \u003C _wad) {\r\n            // set saiBal as wad amount And sub feeAmt(feeAmt \u003E 0, when its debt method).\r\n            _wad = sub(saiBal, 100000);\r\n            // set new convert ratio according to sai_join balance.\r\n            maxConvert = sub(wdiv(saiBal, _wadTotal), 100);\r\n        }\r\n\r\n        // ink according to maxConvert ratio.\r\n        _wad = sub(_wad, feeAmt);\r\n        _ink = wmul(tub.ink(cup), maxConvert);\r\n    }\r\n\r\n    function ethScdToMcd(\r\n        bytes32 scdCup,\r\n        uint mcdCup,\r\n        uint _ink\r\n    ) internal\r\n    {\r\n        //transfer assets from scdCup to mcdCup.\r\n        scdFree(scdCup, _ink);\r\n        mcdLock(mcdCup, _ink);\r\n    }\r\n\r\n    function drawDaiAndPaySai(\r\n        bytes32 scdCup,\r\n        uint mcdCup,\r\n        uint _wad,\r\n        address payFeeWith\r\n    ) internal\r\n    {\r\n        uint _wadForDebt = payFeeWith == getDaiAddress() || payFeeWith == getSaiAddress() ? add(_wad, getFeeOfCdp(scdCup, _wad)) : _wad;\r\n\r\n        daiDraw(mcdCup, _wadForDebt);\r\n\r\n        swapDaiToSai((payFeeWith == getSaiAddress() ? _wadForDebt :_wad));\r\n\r\n        wipeSai(scdCup, _wad, payFeeWith);\r\n\r\n    }\r\n}\r\n\r\n\r\ncontract MigrateResolver is MigrateHelper {\r\n\r\n    event LogScdToMcdMigrate(uint scdCdp, uint toConvert, uint coll, uint debt, address payFeeWith, uint mcdCdp, uint newMcdCdp);\r\n\r\n    function migrate(\r\n        uint scdCDP,\r\n        uint mergeCDP,\r\n        uint toConvert,\r\n        address payFeeWith\r\n    ) external payable\r\n    {\r\n\r\n        uint mcdCdp = mergeCDP == 0 ? openVault() : mergeCDP;\r\n        bytes32 scdCup = bytes32(scdCDP);\r\n\r\n        uint maxConvert = toConvert;\r\n\r\n        uint _wad;\r\n        uint _ink;\r\n        (_wad, _ink, maxConvert) = setSplitAmount(\r\n            scdCup,\r\n            toConvert,\r\n            payFeeWith,\r\n            InstaMcdAddress(getMcdAddresses()).saiJoin());\r\n\r\n        ethScdToMcd(\r\n            scdCup,\r\n            mcdCdp,\r\n            _ink\r\n        );\r\n\r\n        drawDaiAndPaySai(\r\n            scdCup,\r\n            mcdCdp,\r\n            _wad,\r\n            payFeeWith\r\n        );\r\n\r\n        //Transfer if any ETH leftover.\r\n        if (address(this).balance \u003E 0) {\r\n            msg.sender.transfer(address(this).balance);\r\n        }\r\n\r\n        emit LogScdToMcdMigrate(\r\n            uint(scdCup),\r\n            maxConvert,\r\n            _ink,\r\n            _wad,\r\n            payFeeWith,\r\n            mergeCDP,\r\n            mcdCdp\r\n        );\r\n    }\r\n}\r\n\r\n\r\ncontract InstaMcdMigrate is MigrateResolver {\r\n    function() external payable {}\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getGiveAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022srcTknAddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022destMkrAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getBestMkrSwap\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022bestEx\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022srcAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getUniFactoryAddr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022ufa\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getDaiAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022dai\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenAddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022destMkrAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getOasisSwap\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022srcAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getSaiAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022sai\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022scdCDP\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022mergeCDP\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022toConvert\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022payFeeWith\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022migrate\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022openVault\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022cdp\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getUniswapMKRExchange\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022ume\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getWETHAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022wethAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getETHAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022ethAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getMcdAddresses\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022mcd\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getOtcAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022otcAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022srcTknAddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022destMkrAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getUniswapSwap\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022srcAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getSaiTubAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022sai\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022scdCdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022toConvert\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022coll\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022debt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022payFeeWith\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022mcdCdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022newMcdCdp\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogScdToMcdMigrate\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"InstaMcdMigrate","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://76fc9abe03cac6007f3f25b48eeb007bc94392cb986730be5d882e12d739744c"}]