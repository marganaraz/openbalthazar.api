[{"SourceCode":"pragma solidity ^0.5.8;\r\n\r\ninterface TubInterface {\r\n    function open() external returns (bytes32);\r\n    function join(uint) external;\r\n    function exit(uint) external;\r\n    function lock(bytes32, uint) external;\r\n    function free(bytes32, uint) external;\r\n    function draw(bytes32, uint) external;\r\n    function wipe(bytes32, uint) external;\r\n    function give(bytes32, address) external;\r\n    function shut(bytes32) external;\r\n    function cups(bytes32) external view returns (address, uint, uint, uint);\r\n    function gem() external view returns (TokenInterface);\r\n    function gov() external view returns (TokenInterface);\r\n    function skr() external view returns (TokenInterface);\r\n    function sai() external view returns (TokenInterface);\r\n    function ink(bytes32) external view returns (uint);\r\n    function tab(bytes32) external returns (uint);\r\n    function rap(bytes32) external returns (uint);\r\n    function per() external view returns (uint);\r\n    function pep() external view returns (PepInterface);\r\n}\r\n\r\ninterface TokenInterface {\r\n    function allowance(address, address) external view returns (uint);\r\n    function balanceOf(address) external view returns (uint);\r\n    function approve(address, uint) external;\r\n    function transfer(address, uint) external returns (bool);\r\n    function transferFrom(address, address, uint) external returns (bool);\r\n    function deposit() external payable;\r\n    function withdraw(uint) external;\r\n}\r\n\r\ninterface PepInterface {\r\n    function peek() external returns (bytes32, bool);\r\n}\r\n\r\ninterface UniswapExchange {\r\n    function getEthToTokenOutputPrice(uint256 tokensBought) external view returns (uint256 ethSold);\r\n    function getTokenToEthOutputPrice(uint256 ethBought) external view returns (uint256 tokensSold);\r\n    function tokenToTokenSwapOutput(\r\n        uint256 tokensBought,\r\n        uint256 maxTokensSold,\r\n        uint256 maxEthSold,\r\n        uint256 deadline,\r\n        address tokenAddr\r\n    ) external returns (uint256  tokensSold);\r\n    function ethToTokenSwapOutput(uint256 tokensBought, uint256 deadline) external payable returns (uint256  ethSold);\r\n}\r\n\r\ninterface UniswapFactoryInterface {\r\n    function getExchange(address token) external view returns (address exchange);\r\n}\r\n\r\ninterface MCDInterface {\r\n    function swapDaiToSai(uint wad) external;\r\n    function migrate(bytes32 cup) external returns (uint cdp);\r\n}\r\n\r\ninterface PoolInterface {\r\n    function accessToken(address[] calldata ctknAddr, uint[] calldata tknAmt, bool isCompound) external;\r\n    function paybackToken(address[] calldata ctknAddr, bool isCompound) external payable;\r\n}\r\n\r\ninterface OtcInterface {\r\n    function getPayAmount(address, address, uint) external view returns (uint);\r\n    function buyAllAmount(\r\n        address,\r\n        uint,\r\n        address,\r\n        uint\r\n    ) external;\r\n}\r\n\r\ninterface GemLike {\r\n    function approve(address, uint) external;\r\n    function transfer(address, uint) external;\r\n    function transferFrom(address, address, uint) external;\r\n    function deposit() external payable;\r\n    function withdraw(uint) external;\r\n}\r\n\r\ninterface ManagerLike {\r\n    function cdpCan(address, uint, address) external view returns (uint);\r\n    function ilks(uint) external view returns (bytes32);\r\n    function owns(uint) external view returns (address);\r\n    function urns(uint) external view returns (address);\r\n    function vat() external view returns (address);\r\n    function open(bytes32, address) external returns (uint);\r\n    function give(uint, address) external;\r\n    function cdpAllow(uint, address, uint) external;\r\n    function urnAllow(address, uint) external;\r\n    function frob(uint, int, int) external;\r\n    function flux(uint, address, uint) external;\r\n    function move(uint, address, uint) external;\r\n    function exit(\r\n        address,\r\n        uint,\r\n        address,\r\n        uint\r\n    ) external;\r\n    function quit(uint, address) external;\r\n    function enter(address, uint) external;\r\n    function shift(uint, uint) external;\r\n}\r\n\r\ninterface InstaMcdAddress {\r\n    function manager() external view returns (address);\r\n    function gov() external view returns (address);\r\n    function saiTub() external view returns (address);\r\n    function saiJoin() external view returns (address);\r\n    function migration() external view returns (address payable);\r\n}\r\n\r\n\r\ncontract DSMath {\r\n\r\n    function add(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x \u002B y) \u003E= x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    function sub(uint x, uint y) internal pure returns (uint z) {\r\n        z = x - y \u003C= x ? x - y : 0;\r\n    }\r\n\r\n    function mul(uint x, uint y) internal pure returns (uint z) {\r\n        require(y == 0 || (z = x * y) / y == x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    uint constant WAD = 10 ** 18;\r\n    uint constant RAY = 10 ** 27;\r\n\r\n    function rmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), RAY / 2) / RAY;\r\n    }\r\n\r\n    function wmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), WAD / 2) / WAD;\r\n    }\r\n\r\n    function rdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, RAY), y / 2) / y;\r\n    }\r\n\r\n    function wdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, WAD), y / 2) / y;\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract Helpers is DSMath {\r\n\r\n    /**\r\n     * @dev get MakerDAO SCD CDP engine\r\n     */\r\n    function getSaiTubAddress() public pure returns (address sai) {\r\n        sai = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;\r\n    }\r\n\r\n    /**\r\n     * @dev get MakerDAO MCD Address contract\r\n     */\r\n    function getMcdAddresses() public pure returns (address mcd) {\r\n        mcd = 0xF23196DF1C440345DE07feFbe556a5eF0dcD29F0;\r\n    }\r\n\r\n    /**\r\n     * @dev get Sai (Dai v1) address\r\n     */\r\n    function getSaiAddress() public pure returns (address sai) {\r\n        sai = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;\r\n    }\r\n\r\n    /**\r\n     * @dev get DAI (Dai v2) address\r\n     */\r\n    function getDaiAddress() public pure returns (address dai) {\r\n        dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;\r\n    }\r\n\r\n    /**\r\n     * @dev get ETH Address\r\n     */\r\n    function getETHAddress() public pure returns (address ethAddr) {\r\n        ethAddr = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // main\r\n    }\r\n\r\n    /**\r\n     * @dev get WETH Address\r\n     */\r\n    function getWETHAddress() public pure returns (address wethAddr) {\r\n        wethAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // main\r\n    }\r\n\r\n    /**\r\n     * @dev get OTC Address\r\n     */\r\n    function getOtcAddress() public pure returns (address otcAddr) {\r\n        otcAddr = 0x39755357759cE0d7f32dC8dC45414CCa409AE24e; // main\r\n    }\r\n\r\n    /**\r\n     * @dev get InstaDApp Liquidity Address\r\n     */\r\n    function getPoolAddress() public pure returns (address payable liqAddr) {\r\n        liqAddr = 0x1564D040EC290C743F67F5cB11f3C1958B39872A;\r\n    }\r\n\r\n    /**\r\n     * @dev get InstaDApp CDP\u0027s Address\r\n     */\r\n    function getGiveAddress() public pure returns (address addr) {\r\n        addr = 0xc679857761beE860f5Ec4B3368dFE9752580B096;\r\n    }\r\n\r\n    /**\r\n     * @dev get uniswap MKR exchange\r\n     */\r\n    function getUniswapMKRExchange() public pure returns (address ume) {\r\n        ume = 0x2C4Bd064b998838076fa341A83d007FC2FA50957;\r\n    }\r\n\r\n    /**\r\n     * @dev get uniswap MKR exchange\r\n     */\r\n    function getUniFactoryAddr() public pure returns (address ufa) {\r\n        ufa = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;\r\n    }\r\n\r\n    /**\r\n     * @dev setting allowance if required\r\n     */\r\n    function setApproval(address erc20, uint srcAmt, address to) internal {\r\n        TokenInterface erc20Contract = TokenInterface(erc20);\r\n        uint tokenAllowance = erc20Contract.allowance(address(this), to);\r\n        if (srcAmt \u003E tokenAllowance) {\r\n            erc20Contract.approve(to, uint(-1));\r\n        }\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract LiquidityResolver is Helpers {\r\n    //Had to write seprate for pool, remix was showing error.\r\n    function getLiquidity(uint _wad) internal {\r\n        uint[] memory _wadArr = new uint[](1);\r\n        _wadArr[0] = _wad;\r\n\r\n        address[] memory addrArr = new address[](1);\r\n        addrArr[0] = address(0);\r\n\r\n        // Get liquidity assets to payback user wallet borrowed assets\r\n        PoolInterface(getPoolAddress()).accessToken(addrArr, _wadArr, false);\r\n    }\r\n\r\n    function paybackLiquidity(uint _wad) internal {\r\n        address[] memory addrArr = new address[](1);\r\n        addrArr[0] = address(0);\r\n\r\n        // transfer and payback dai to InstaDApp pool.\r\n        require(TokenInterface(getSaiAddress()).transfer(getPoolAddress(), _wad), \u0022Not-enough-dai\u0022);\r\n        PoolInterface(getPoolAddress()).paybackToken(addrArr, false);\r\n    }\r\n}\r\n\r\n\r\ncontract MKRSwapper is  LiquidityResolver {\r\n\r\n    function getBestMkrSwap(address srcTknAddr, uint destMkrAmt) public view returns(uint bestEx, uint srcAmt) {\r\n        uint oasisPrice = getOasisSwap(srcTknAddr, destMkrAmt);\r\n        uint uniswapPrice = getUniswapSwap(srcTknAddr, destMkrAmt);\r\n        require(oasisPrice != 0 \u0026\u0026 uniswapPrice != 0, \u0022swap price 0\u0022);\r\n        srcAmt = oasisPrice \u003C uniswapPrice ? oasisPrice : uniswapPrice;\r\n        bestEx = oasisPrice \u003C uniswapPrice ? 0 : 1; // if 0 then use Oasis for Swap, if 1 then use Uniswap\r\n    }\r\n\r\n    function getOasisSwap(address tokenAddr, uint destMkrAmt) public view returns(uint srcAmt) {\r\n        TokenInterface mkr = TubInterface(getSaiTubAddress()).gov();\r\n        address srcTknAddr = tokenAddr == getETHAddress() ? getWETHAddress() : tokenAddr;\r\n        srcAmt = OtcInterface(getOtcAddress()).getPayAmount(srcTknAddr, address(mkr), destMkrAmt);\r\n    }\r\n\r\n    function getUniswapSwap(address srcTknAddr, uint destMkrAmt) public view returns(uint srcAmt) {\r\n        UniswapExchange mkrEx = UniswapExchange(getUniswapMKRExchange());\r\n        if (srcTknAddr == getETHAddress()) {\r\n            srcAmt = mkrEx.getEthToTokenOutputPrice(destMkrAmt);\r\n        } else {\r\n            address buyTknExAddr = UniswapFactoryInterface(getUniFactoryAddr()).getExchange(srcTknAddr);\r\n            UniswapExchange buyTknEx = UniswapExchange(buyTknExAddr);\r\n            srcAmt = buyTknEx.getTokenToEthOutputPrice(mkrEx.getEthToTokenOutputPrice(destMkrAmt)); //Check thrilok is this correct\r\n        }\r\n    }\r\n\r\n    function swapToMkr(address tokenAddr, uint govFee) internal {\r\n        (uint bestEx, uint srcAmt) = getBestMkrSwap(tokenAddr, govFee);\r\n        if (bestEx == 0) {\r\n            swapToMkrOtc(tokenAddr, srcAmt, govFee);\r\n        } else {\r\n            swapToMkrUniswap(tokenAddr, srcAmt, govFee);\r\n        }\r\n    }\r\n\r\n    function swapToMkrOtc(address tokenAddr, uint srcAmt, uint govFee) internal {\r\n        address mkr = InstaMcdAddress(getMcdAddresses()).gov();\r\n        address srcTknAddr = tokenAddr == getETHAddress() ? getWETHAddress() : tokenAddr;\r\n        if (srcTknAddr == getWETHAddress()) {\r\n            TokenInterface weth = TokenInterface(getWETHAddress());\r\n            weth.deposit.value(srcAmt)();\r\n        } else if (srcTknAddr != getSaiAddress() \u0026\u0026 srcTknAddr != getDaiAddress()) {\r\n            require(TokenInterface(srcTknAddr).transferFrom(msg.sender, address(this), srcAmt), \u0022Tranfer-failed\u0022);\r\n        }\r\n\r\n        setApproval(srcTknAddr, srcAmt, getOtcAddress());\r\n        OtcInterface(getOtcAddress()).buyAllAmount(\r\n            mkr,\r\n            govFee,\r\n            srcTknAddr,\r\n            srcAmt\r\n        );\r\n    }\r\n\r\n    function swapToMkrUniswap(address tokenAddr, uint srcAmt, uint govFee) internal {\r\n        UniswapExchange mkrEx = UniswapExchange(getUniswapMKRExchange());\r\n        address mkr = InstaMcdAddress(getMcdAddresses()).gov();\r\n\r\n        if (tokenAddr == getETHAddress()) {\r\n            mkrEx.ethToTokenSwapOutput.value(srcAmt)(govFee, uint(1899063809));\r\n        } else {\r\n            if (tokenAddr != getSaiAddress() \u0026\u0026 tokenAddr != getDaiAddress()) {\r\n                require(TokenInterface(tokenAddr).transferFrom(msg.sender, address(this), srcAmt), \u0022not-approved-yet\u0022);\r\n            }\r\n            address buyTknExAddr = UniswapFactoryInterface(getUniFactoryAddr()).getExchange(tokenAddr);\r\n            UniswapExchange buyTknEx = UniswapExchange(buyTknExAddr);\r\n            setApproval(tokenAddr, srcAmt, buyTknExAddr);\r\n            buyTknEx.tokenToTokenSwapOutput(\r\n                    govFee,\r\n                    srcAmt,\r\n                    uint(999000000000000000000),\r\n                    uint(1899063809), // 6th March 2030 GMT // no logic\r\n                    mkr\r\n                );\r\n        }\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract SCDResolver is MKRSwapper {\r\n\r\n    function getFeeOfCdp(bytes32 cup, uint _wad) internal returns (uint mkrFee) {\r\n        TubInterface tub = TubInterface(getSaiTubAddress());\r\n        (bytes32 val, bool ok) = tub.pep().peek();\r\n        if (ok \u0026\u0026 val != 0) {\r\n            // MKR required for wipe = Stability fees accrued in Dai / MKRUSD value\r\n            mkrFee = rdiv(tub.rap(cup), tub.tab(cup));\r\n            mkrFee = rmul(_wad, mkrFee);\r\n            mkrFee = wdiv(mkrFee, uint(val));\r\n        }\r\n\r\n    }\r\n\r\n    function open() internal returns (bytes32 cup) {\r\n        cup = TubInterface(getSaiTubAddress()).open();\r\n    }\r\n\r\n    function wipe(bytes32 cup, uint _wad, address payFeeWith) internal {\r\n        if (_wad \u003E 0) {\r\n            TubInterface tub = TubInterface(getSaiTubAddress());\r\n            TokenInterface dai = tub.sai();\r\n            TokenInterface mkr = tub.gov();\r\n\r\n            (address lad,,,) = tub.cups(cup);\r\n            require(lad == address(this), \u0022cup-not-owned\u0022);\r\n\r\n            setAllowance(dai, getSaiTubAddress());\r\n            setAllowance(mkr, getSaiTubAddress());\r\n\r\n            uint mkrFee = getFeeOfCdp(cup, _wad);\r\n\r\n            if (payFeeWith != address(mkr) \u0026\u0026 mkrFee \u003E 0) {\r\n                swapToMkr(payFeeWith, mkrFee); //otc or uniswap\r\n            } else if (payFeeWith == address(mkr) \u0026\u0026 mkrFee \u003E 0) {\r\n                require(TokenInterface(address(mkr)).transferFrom(msg.sender, address(this), mkrFee), \u0022Tranfer-failed\u0022);\r\n            }\r\n\r\n            tub.wipe(cup, _wad);\r\n        }\r\n    }\r\n\r\n    function free(bytes32 cup, uint ink) internal {\r\n        if (ink \u003E 0) {\r\n            TubInterface(getSaiTubAddress()).free(cup, ink); // free PETH\r\n        }\r\n    }\r\n\r\n    function lock(bytes32 cup, uint ink) internal {\r\n        if (ink \u003E 0) {\r\n            TubInterface tub = TubInterface(getSaiTubAddress());\r\n            TokenInterface peth = tub.skr();\r\n\r\n            (address lad,,,) = tub.cups(cup);\r\n            require(lad == address(this), \u0022cup-not-owned\u0022);\r\n\r\n            setAllowance(peth, getSaiTubAddress());\r\n            tub.lock(cup, ink);\r\n        }\r\n    }\r\n\r\n    function draw(bytes32 cup, uint _wad) internal {\r\n        if (_wad \u003E 0) {\r\n            TubInterface tub = TubInterface(getSaiTubAddress());\r\n            tub.draw(cup, _wad);\r\n        }\r\n    }\r\n\r\n    function setAllowance(TokenInterface _token, address _spender) private {\r\n        if (_token.allowance(address(this), _spender) != uint(-1)) {\r\n            _token.approve(_spender, uint(-1));\r\n        }\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract MCDResolver is SCDResolver {\r\n    function migrateToMCD(\r\n        bytes32 cup,                        // SCD CDP Id to migrate\r\n        address payGem                    // Token address\r\n    ) internal returns (uint cdp)\r\n    {\r\n        address payable scdMcdMigration = InstaMcdAddress(getMcdAddresses()).migration();\r\n        TubInterface tub = TubInterface(getSaiTubAddress());\r\n        tub.give(cup, address(scdMcdMigration));\r\n\r\n        // Get necessary MKR fee and move it to the migration contract\r\n        (bytes32 val, bool ok) = tub.pep().peek();\r\n        if (ok \u0026\u0026 uint(val) != 0) {\r\n            // Calculate necessary value of MKR to pay the govFee\r\n            uint govFee = wdiv(tub.rap(cup), uint(val));\r\n            if (govFee \u003E 0) {\r\n                if (payGem != address(tub.gov())) {\r\n                    swapToMkr(payGem, govFee);\r\n                    require(tub.gov().transfer(address(scdMcdMigration), govFee), \u0022transfer-failed\u0022);\r\n                } else {\r\n                    require(tub.gov().transferFrom(msg.sender, address(scdMcdMigration), govFee), \u0022transfer-failed\u0022);\r\n                }\r\n            }\r\n        }\r\n        // Execute migrate function\r\n        cdp = MCDInterface(scdMcdMigration).migrate(cup);\r\n    }\r\n\r\n    function giveCDP(\r\n        uint cdp,\r\n        address nextOwner\r\n    ) internal\r\n    {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        ManagerLike(manager).give(cdp, nextOwner);\r\n    }\r\n\r\n    function shiftCDP(\r\n        uint cdpSrc,\r\n        uint cdpOrg\r\n    ) internal\r\n    {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        require(ManagerLike(manager).owns(cdpOrg) == address(this), \u0022NOT-OWNER\u0022);\r\n        ManagerLike(manager).shift(cdpSrc, cdpOrg);\r\n    }\r\n}\r\n\r\n\r\ncontract MigrateHelper is MCDResolver {\r\n    function setSplitAmount(\r\n        bytes32 cup,\r\n        uint toConvert,\r\n        address payFeeWith,\r\n        address saiJoin\r\n    ) internal returns (uint _wad, uint _ink, uint maxConvert)\r\n    {\r\n        // Set ratio according to user.\r\n        TubInterface tub = TubInterface(getSaiTubAddress());\r\n\r\n        maxConvert = toConvert;\r\n        uint saiBal = tub.sai().balanceOf(saiJoin);\r\n        uint _wadTotal = tub.tab(cup);\r\n\r\n        uint feeAmt = 0;\r\n\r\n        // wad according to toConvert ratio\r\n        _wad = wmul(_wadTotal, toConvert);\r\n\r\n        // if migration is by debt method, Add fee(SAI) to _wad\r\n        if (payFeeWith == getSaiAddress()) {\r\n            uint mkrAmt = getFeeOfCdp(cup, _wad);\r\n            (, feeAmt) = getBestMkrSwap(getSaiAddress(), mkrAmt);\r\n            _wad = add(_wad, feeAmt);\r\n        }\r\n\r\n        //if sai_join has enough sai to migrate.\r\n        if (saiBal \u003C _wad) {\r\n            // set saiBal as wad amount And sub feeAmt(feeAmt \u003E 0, when its debt method).\r\n            _wad = sub(saiBal, 100000);\r\n            // set new convert ratio according to sai_join balance.\r\n            maxConvert = sub(wdiv(saiBal, _wadTotal), 100);\r\n        }\r\n\r\n        // ink according to maxConvert ratio.\r\n        _wad = sub(_wad, feeAmt);\r\n        _ink = wmul(tub.ink(cup), maxConvert);\r\n    }\r\n\r\n    function splitCdp(\r\n        bytes32 scdCup,\r\n        bytes32 splitCup,\r\n        uint _wad,\r\n        uint _ink,\r\n        address payFeeWith\r\n    ) internal\r\n    {\r\n        //getting InstaDApp Pool Balance.\r\n        uint initialPoolBal = sub(getPoolAddress().balance, 10000000000);\r\n\r\n        // Check if the split fee is paid by debt from the cdp.\r\n        uint _wadForDebt = _wad;\r\n        if (payFeeWith == getSaiAddress()) {\r\n            (, uint feeAmt) = getBestMkrSwap(getSaiAddress(), getFeeOfCdp(scdCup, _wad));\r\n            _wadForDebt = add(_wadForDebt, feeAmt);\r\n        }\r\n\r\n        //fetch liquidity from InstaDApp Pool.\r\n        getLiquidity(_wadForDebt);\r\n\r\n        //transfer assets from scdCup to splitCup.\r\n        wipe(scdCup, _wad, payFeeWith);\r\n        free(scdCup, _ink);\r\n        lock(splitCup, _ink);\r\n        draw(splitCup, _wadForDebt);\r\n\r\n        //transfer and payback liquidity to InstaDApp Pool.\r\n        paybackLiquidity(_wadForDebt);\r\n\r\n        uint finalPoolBal = getPoolAddress().balance;\r\n        assert(finalPoolBal \u003E= initialPoolBal);\r\n    }\r\n\r\n    function migrateWholeCdp(bytes32 cup, address payfeeWith) internal returns (uint newMcdCdp) {\r\n        if (payfeeWith == getSaiAddress()) {\r\n            // draw more SAI for debt method and 100% convert.\r\n            uint _wad = TubInterface(getSaiTubAddress()).tab(cup);\r\n            (, uint fee) = getBestMkrSwap(getSaiAddress(), getFeeOfCdp(cup, _wad));\r\n            // draw fee amt.\r\n            draw(cup, fee);\r\n        }\r\n        newMcdCdp = migrateToMCD(cup, payfeeWith);\r\n    }\r\n}\r\n\r\n\r\ncontract MigrateResolver is MigrateHelper {\r\n\r\n    event LogMigrate(uint scdCdp, uint toConvert, uint coll, uint debt, address payFeeWith, uint mcdCdp, uint newMcdCdp);\r\n\r\n    function migrate(\r\n        uint scdCDP,\r\n        uint mergeCDP,\r\n        uint toConvert,\r\n        address payFeeWith\r\n    ) external payable returns (uint newMcdCdp)\r\n    {\r\n        bytes32 scdCup = bytes32(scdCDP);\r\n        uint maxConvert = toConvert;\r\n        uint _wad;\r\n        uint _ink;\r\n        //set split amount according to toConvert and dai_join balance and decrease the ratio if needed.\r\n        (_wad, _ink, maxConvert) = setSplitAmount(\r\n            scdCup,\r\n            toConvert,\r\n            payFeeWith,\r\n            InstaMcdAddress(getMcdAddresses()).saiJoin());\r\n\r\n        if (maxConvert \u003C 10**18) {\r\n            //new cdp for spliting assets.\r\n            bytes32 splitCup = TubInterface(getSaiTubAddress()).open();\r\n\r\n            //split the assets into split cdp.\r\n            splitCdp(\r\n                scdCup,\r\n                splitCup,\r\n                _wad,\r\n                _ink,\r\n                payFeeWith\r\n            );\r\n\r\n            //migrate the split cdp.\r\n            newMcdCdp = migrateToMCD(splitCup, payFeeWith);\r\n        } else {\r\n            //migrate the scd cdp and check if fee is paid by debt.\r\n            newMcdCdp = migrateWholeCdp(scdCup, payFeeWith);\r\n        }\r\n\r\n        //merge the already existing mcd cdp with the new migrated cdp.\r\n        if (mergeCDP != 0) {\r\n            shiftCDP(newMcdCdp, mergeCDP);\r\n            giveCDP(newMcdCdp, getGiveAddress());\r\n        }\r\n\r\n        emit LogMigrate(\r\n            uint(scdCup),\r\n            maxConvert,\r\n            _ink,\r\n            _wad,\r\n            payFeeWith,\r\n            mergeCDP,\r\n            newMcdCdp\r\n        );\r\n    }\r\n}\r\n\r\n\r\ncontract InstaMcdMigrate is MigrateResolver {\r\n    function() external payable {}\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getGiveAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022srcTknAddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022destMkrAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getBestMkrSwap\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022bestEx\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022srcAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getUniFactoryAddr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022ufa\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getDaiAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022dai\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenAddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022destMkrAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getOasisSwap\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022srcAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getSaiAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022sai\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022scdCDP\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022mergeCDP\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022toConvert\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022payFeeWith\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022migrate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022newMcdCdp\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getUniswapMKRExchange\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022ume\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getWETHAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022wethAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getETHAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022ethAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getMcdAddresses\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022mcd\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getOtcAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022otcAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022srcTknAddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022destMkrAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getUniswapSwap\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022srcAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getSaiTubAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022sai\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getPoolAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022liqAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022scdCdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022toConvert\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022coll\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022debt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022payFeeWith\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022mcdCdp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022newMcdCdp\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogMigrate\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"InstaMcdMigrate","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://3f698e58a08f28bdb3feccfeaecc521bc532f405df0c94816349330d4dda38d4"}]