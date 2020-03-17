[{"SourceCode":"pragma solidity ^0.5.7;\r\n\r\ninterface TubInterface {\r\n    function open() external returns (bytes32);\r\n    function join(uint) external;\r\n    function exit(uint) external;\r\n    function lock(bytes32, uint) external;\r\n    function free(bytes32, uint) external;\r\n    function draw(bytes32, uint) external;\r\n    function wipe(bytes32, uint) external;\r\n    function give(bytes32, address) external;\r\n    function shut(bytes32) external;\r\n    function cups(bytes32) external view returns (address, uint, uint, uint);\r\n    function gem() external view returns (TokenInterface);\r\n    function gov() external view returns (TokenInterface);\r\n    function skr() external view returns (TokenInterface);\r\n    function sai() external view returns (TokenInterface);\r\n    function ink(bytes32) external view returns (uint);\r\n    function tab(bytes32) external returns (uint);\r\n    function rap(bytes32) external returns (uint);\r\n    function per() external view returns (uint);\r\n    function pep() external view returns (PepInterface);\r\n}\r\n\r\ninterface TokenInterface {\r\n    function allowance(address, address) external view returns (uint);\r\n    function balanceOf(address) external view returns (uint);\r\n    function approve(address, uint) external;\r\n    function transfer(address, uint) external returns (bool);\r\n    function transferFrom(address, address, uint) external returns (bool);\r\n    function deposit() external payable;\r\n    function withdraw(uint) external;\r\n}\r\n\r\ninterface PepInterface {\r\n    function peek() external returns (bytes32, bool);\r\n}\r\n\r\ninterface MakerOracleInterface {\r\n    function read() external view returns (bytes32);\r\n}\r\n\r\ninterface UniswapExchange {\r\n    function getEthToTokenOutputPrice(uint256 tokensBought) external view returns (uint256 ethSold);\r\n    function getTokenToEthOutputPrice(uint256 ethBought) external view returns (uint256 tokensSold);\r\n    function tokenToTokenSwapOutput(\r\n        uint256 tokensBought,\r\n        uint256 maxTokensSold,\r\n        uint256 maxEthSold,\r\n        uint256 deadline,\r\n        address tokenAddr\r\n        ) external returns (uint256  tokensSold);\r\n}\r\n\r\ninterface PoolInterface {\r\n    function accessToken(address[] calldata ctknAddr, uint[] calldata tknAmt, bool isCompound) external;\r\n    function paybackToken(address[] calldata ctknAddr, bool isCompound) external payable;\r\n}\r\n\r\ninterface CTokenInterface {\r\n    function redeem(uint redeemTokens) external returns (uint);\r\n    function redeemUnderlying(uint redeemAmount) external returns (uint);\r\n    function borrow(uint borrowAmount) external returns (uint);\r\n    function liquidateBorrow(address borrower, uint repayAmount, address cTokenCollateral) external returns (uint);\r\n    function liquidateBorrow(address borrower, address cTokenCollateral) external payable;\r\n    function exchangeRateCurrent() external returns (uint);\r\n    function getCash() external view returns (uint);\r\n    function totalBorrowsCurrent() external returns (uint);\r\n    function borrowRatePerBlock() external view returns (uint);\r\n    function supplyRatePerBlock() external view returns (uint);\r\n    function totalReserves() external view returns (uint);\r\n    function reserveFactorMantissa() external view returns (uint);\r\n    function borrowBalanceCurrent(address account) external returns (uint);\r\n\r\n    function totalSupply() external view returns (uint256);\r\n    function balanceOf(address owner) external view returns (uint256 balance);\r\n    function allowance(address, address) external view returns (uint);\r\n    function approve(address, uint) external;\r\n    function transfer(address, uint) external returns (bool);\r\n    function transferFrom(address, address, uint) external returns (bool);\r\n}\r\n\r\ninterface CERC20Interface {\r\n    function mint(uint mintAmount) external returns (uint); // For ERC20\r\n    function repayBorrow(uint repayAmount) external returns (uint); // For ERC20\r\n    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint); // For ERC20\r\n    function borrowBalanceCurrent(address account) external returns (uint);\r\n}\r\n\r\ninterface CETHInterface {\r\n    function mint() external payable; // For ETH\r\n    function repayBorrow() external payable; // For ETH\r\n    function repayBorrowBehalf(address borrower) external payable; // For ETH\r\n    function borrowBalanceCurrent(address account) external returns (uint);\r\n}\r\n\r\ninterface ComptrollerInterface {\r\n    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);\r\n    function exitMarket(address cTokenAddress) external returns (uint);\r\n    function getAssetsIn(address account) external view returns (address[] memory);\r\n    function getAccountLiquidity(address account) external view returns (uint, uint, uint);\r\n}\r\n\r\ninterface CompOracleInterface {\r\n    function getUnderlyingPrice(address) external view returns (uint);\r\n}\r\n\r\n\r\ncontract DSMath {\r\n\r\n    function sub(uint x, uint y) internal pure returns (uint z) {\r\n        z = x - y \u003C= x ? x - y : 0;\r\n    }\r\n\r\n    function add(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x \u002B y) \u003E= x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    function mul(uint x, uint y) internal pure returns (uint z) {\r\n        require(y == 0 || (z = x * y) / y == x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    uint constant WAD = 10 ** 18;\r\n    uint constant RAY = 10 ** 27;\r\n\r\n    function rmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), RAY / 2) / RAY;\r\n    }\r\n\r\n    function rdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, RAY), y / 2) / y;\r\n    }\r\n\r\n    function wmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), WAD / 2) / WAD;\r\n    }\r\n\r\n    function wdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, WAD), y / 2) / y;\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract Helper is DSMath {\r\n\r\n    /**\r\n     * @dev get ethereum address for trade\r\n     */\r\n    function getAddressETH() public pure returns (address eth) {\r\n        eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\r\n    }\r\n\r\n    /**\r\n     * @dev get MakerDAO CDP engine\r\n     */\r\n    function getSaiTubAddress() public pure returns (address sai) {\r\n        sai = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;\r\n    }\r\n\r\n    /**\r\n     * @dev get MakerDAO Oracle for ETH price\r\n     */\r\n    function getOracleAddress() public pure returns (address oracle) {\r\n        oracle = 0x729D19f657BD0614b4985Cf1D82531c67569197B;\r\n    }\r\n\r\n    /**\r\n     * @dev get uniswap MKR exchange\r\n     */\r\n    function getUniswapMKRExchange() public pure returns (address ume) {\r\n        ume = 0x2C4Bd064b998838076fa341A83d007FC2FA50957;\r\n    }\r\n\r\n    /**\r\n     * @dev get uniswap DAI exchange\r\n     */\r\n    function getUniswapDAIExchange() public pure returns (address ude) {\r\n        ude = 0x09cabEC1eAd1c0Ba254B09efb3EE13841712bE14;\r\n    }\r\n\r\n    /**\r\n     * @dev get InstaDApp Liquidity contract\r\n     */\r\n    function getPoolAddr() public pure returns (address poolAddr) {\r\n        poolAddr = 0x1564D040EC290C743F67F5cB11f3C1958B39872A;\r\n    }\r\n\r\n    /**\r\n     * @dev get Compound Comptroller Address\r\n     */\r\n    function getComptrollerAddress() public pure returns (address troller) {\r\n        troller = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;\r\n    }\r\n\r\n    /**\r\n     * @dev get Compound Oracle Address\r\n     */\r\n    function getCompOracleAddress() public pure returns (address troller) {\r\n        troller = 0xe7664229833AE4Abf4E269b8F23a86B657E2338D;\r\n    }\r\n\r\n    /**\r\n     * @dev get CETH Address\r\n     */\r\n    function getCETHAddress() public pure returns (address cEth) {\r\n        cEth = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;\r\n    }\r\n\r\n    /**\r\n     * @dev get DAI Address\r\n     */\r\n    function getDAIAddress() public pure returns (address dai) {\r\n        dai = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;\r\n    }\r\n\r\n    /**\r\n     * @dev get MKR Address\r\n     */\r\n    function getMKRAddress() public pure returns (address dai) {\r\n        dai = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;\r\n    }\r\n\r\n    /**\r\n     * @dev get CDAI Address\r\n     */\r\n    function getCDAIAddress() public pure returns (address cDai) {\r\n        cDai = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;\r\n    }\r\n\r\n    /**\r\n     * @dev setting allowance to compound contracts for the \u0022user proxy\u0022 if required\r\n     */\r\n    function setApproval(address erc20, uint srcAmt, address to) internal {\r\n        TokenInterface erc20Contract = TokenInterface(erc20);\r\n        uint tokenAllowance = erc20Contract.allowance(address(this), to);\r\n        if (srcAmt \u003E tokenAllowance) {\r\n            erc20Contract.approve(to, uint(-1));\r\n        }\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract MakerHelper is Helper {\r\n\r\n    event LogOpen(uint cdpNum, address owner);\r\n    event LogLock(uint cdpNum, uint amtETH, uint amtPETH, address owner);\r\n    event LogFree(uint cdpNum, uint amtETH, uint amtPETH, address owner);\r\n    event LogDraw(uint cdpNum, uint amtDAI, address owner);\r\n    event LogWipe(uint cdpNum, uint daiAmt, uint mkrFee, uint daiFee, address owner);\r\n    event LogShut(uint cdpNum);\r\n\r\n    /**\r\n     * @dev Allowance to Maker\u0027s contract\r\n     */\r\n    function setMakerAllowance(TokenInterface _token, address _spender) internal {\r\n        if (_token.allowance(address(this), _spender) != uint(-1)) {\r\n            _token.approve(_spender, uint(-1));\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev CDP stats by Bytes\r\n     */\r\n    function getCDPStats(bytes32 cup) internal view returns (uint ethCol, uint daiDebt) {\r\n        TubInterface tub = TubInterface(getSaiTubAddress());\r\n        (, uint pethCol, uint debt,) = tub.cups(cup);\r\n        ethCol = rmul(pethCol, tub.per()); // get ETH col from PETH col\r\n        daiDebt = debt;\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract CompoundHelper is MakerHelper {\r\n\r\n    event LogMint(address erc20, address cErc20, uint tokenAmt, address owner);\r\n    event LogRedeem(address erc20, address cErc20, uint tokenAmt, address owner);\r\n    event LogBorrow(address erc20, address cErc20, uint tokenAmt, address owner);\r\n    event LogRepay(address erc20, address cErc20, uint tokenAmt, address owner);\r\n\r\n    /**\r\n     * @dev Compound Enter Market which allows borrowing\r\n     */\r\n    function enterMarket(address cErc20) internal {\r\n        ComptrollerInterface troller = ComptrollerInterface(getComptrollerAddress());\r\n        address[] memory markets = troller.getAssetsIn(address(this));\r\n        bool isEntered = false;\r\n        for (uint i = 0; i \u003C markets.length; i\u002B\u002B) {\r\n            if (markets[i] == cErc20) {\r\n                isEntered = true;\r\n            }\r\n        }\r\n        if (!isEntered) {\r\n            address[] memory toEnter = new address[](1);\r\n            toEnter[0] = cErc20;\r\n            troller.enterMarkets(toEnter);\r\n        }\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract InstaPoolResolver is CompoundHelper {\r\n\r\n    function accessDai(uint daiAmt, bool isCompound) internal {\r\n        address[] memory borrowAddr = new address[](1);\r\n        uint[] memory borrowAmt = new uint[](1);\r\n        borrowAddr[0] = getCDAIAddress();\r\n        borrowAmt[0] = daiAmt;\r\n        PoolInterface(getPoolAddr()).accessToken(borrowAddr, borrowAmt, isCompound);\r\n    }\r\n\r\n    function returnDai(uint daiAmt, bool isCompound) internal {\r\n        address[] memory borrowAddr = new address[](1);\r\n        borrowAddr[0] = getCDAIAddress();\r\n        require(TokenInterface(getDAIAddress()).transfer(getPoolAddr(), daiAmt), \u0022Not-enough-DAI\u0022);\r\n        PoolInterface(getPoolAddr()).paybackToken(borrowAddr, isCompound);\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract MakerResolver is InstaPoolResolver {\r\n\r\n    /**\r\n     * @dev Open new CDP\r\n     */\r\n    function open() internal returns (uint) {\r\n        bytes32 cup = TubInterface(getSaiTubAddress()).open();\r\n        emit LogOpen(uint(cup), address(this));\r\n        return uint(cup);\r\n    }\r\n\r\n    /**\r\n     * @dev transfer CDP ownership\r\n     */\r\n    function give(uint cdpNum, address nextOwner) internal {\r\n        TubInterface(getSaiTubAddress()).give(bytes32(cdpNum), nextOwner);\r\n    }\r\n\r\n    function setWipeAllowances(TubInterface tub) internal { // to solve stack to deep error\r\n        TokenInterface dai = tub.sai();\r\n        TokenInterface mkr = tub.gov();\r\n        setMakerAllowance(dai, getSaiTubAddress());\r\n        setMakerAllowance(mkr, getSaiTubAddress());\r\n        setMakerAllowance(dai, getUniswapDAIExchange());\r\n    }\r\n\r\n    /**\r\n     * @dev Pay CDP debt\r\n     */\r\n    function wipe(uint cdpNum, uint _wad, bool isCompound) internal returns (uint daiAmt) {\r\n        if (_wad \u003E 0) {\r\n            TubInterface tub = TubInterface(getSaiTubAddress());\r\n            UniswapExchange daiEx = UniswapExchange(getUniswapDAIExchange());\r\n            UniswapExchange mkrEx = UniswapExchange(getUniswapMKRExchange());\r\n\r\n            bytes32 cup = bytes32(cdpNum);\r\n\r\n            (address lad,,,) = tub.cups(cup);\r\n            require(lad == address(this), \u0022cup-not-owned\u0022);\r\n\r\n            setWipeAllowances(tub);\r\n            (bytes32 val, bool ok) = tub.pep().peek();\r\n\r\n            // MKR required for wipe = Stability fees accrued in Dai / MKRUSD value\r\n            uint mkrFee = wdiv(rmul(_wad, rdiv(tub.rap(cup), tub.tab(cup))), uint(val));\r\n\r\n            uint daiFeeAmt = daiEx.getTokenToEthOutputPrice(mkrEx.getEthToTokenOutputPrice(mkrFee));\r\n            daiAmt = add(_wad, daiFeeAmt);\r\n\r\n            // Getting Liquidity from Liquidity Contract\r\n            accessDai(daiAmt, isCompound);\r\n\r\n            if (ok \u0026\u0026 val != 0) {\r\n                daiEx.tokenToTokenSwapOutput(\r\n                    mkrFee,\r\n                    daiFeeAmt,\r\n                    uint(999000000000000000000),\r\n                    uint(1899063809), // 6th March 2030 GMT // no logic\r\n                    getMKRAddress()\r\n                );\r\n            }\r\n\r\n            tub.wipe(cup, _wad);\r\n\r\n            emit LogWipe(\r\n                cdpNum,\r\n                daiAmt,\r\n                mkrFee,\r\n                daiFeeAmt,\r\n                address(this)\r\n            );\r\n\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Pay CDP debt\r\n     */\r\n    function wipeWithMkr(uint cdpNum, uint _wad, bool isCompound) internal {\r\n        if (_wad \u003E 0) {\r\n            TubInterface tub = TubInterface(getSaiTubAddress());\r\n            TokenInterface dai = tub.sai();\r\n            TokenInterface mkr = tub.gov();\r\n\r\n            bytes32 cup = bytes32(cdpNum);\r\n\r\n            (address lad,,,) = tub.cups(cup);\r\n            require(lad == address(this), \u0022cup-not-owned\u0022);\r\n\r\n            setMakerAllowance(dai, getSaiTubAddress());\r\n            setMakerAllowance(mkr, getSaiTubAddress());\r\n\r\n            (bytes32 val, bool ok) = tub.pep().peek();\r\n\r\n            // MKR required for wipe = Stability fees accrued in Dai / MKRUSD value\r\n            uint mkrFee = wdiv(rmul(_wad, rdiv(tub.rap(cup), tub.tab(cup))), uint(val));\r\n\r\n            // Getting Liquidity from Liquidity Contract\r\n            accessDai(_wad, isCompound);\r\n\r\n            if (ok \u0026\u0026 val != 0) {\r\n                require(mkr.transferFrom(msg.sender, address(this), mkrFee), \u0022MKR-Allowance?\u0022);\r\n            }\r\n\r\n            tub.wipe(cup, _wad);\r\n\r\n            emit LogWipe(\r\n                cdpNum,\r\n                _wad,\r\n                mkrFee,\r\n                0,\r\n                address(this)\r\n            );\r\n\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Withdraw CDP\r\n     */\r\n    function free(uint cdpNum, uint jam) internal {\r\n        if (jam \u003E 0) {\r\n            bytes32 cup = bytes32(cdpNum);\r\n            address tubAddr = getSaiTubAddress();\r\n\r\n            TubInterface tub = TubInterface(tubAddr);\r\n            TokenInterface peth = tub.skr();\r\n            TokenInterface weth = tub.gem();\r\n\r\n            uint ink = rdiv(jam, tub.per());\r\n            ink = rmul(ink, tub.per()) \u003C= jam ? ink : ink - 1;\r\n            tub.free(cup, ink);\r\n\r\n            setMakerAllowance(peth, tubAddr);\r\n\r\n            tub.exit(ink);\r\n            uint freeJam = weth.balanceOf(address(this)); // withdraw possible previous stuck WETH as well\r\n            weth.withdraw(freeJam);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Deposit Collateral\r\n     */\r\n    function lock(uint cdpNum, uint ethAmt) internal {\r\n        if (ethAmt \u003E 0) {\r\n            bytes32 cup = bytes32(cdpNum);\r\n            address tubAddr = getSaiTubAddress();\r\n\r\n            TubInterface tub = TubInterface(tubAddr);\r\n            TokenInterface weth = tub.gem();\r\n            TokenInterface peth = tub.skr();\r\n\r\n            (address lad,,,) = tub.cups(cup);\r\n            require(lad == address(this), \u0022cup-not-owned\u0022);\r\n\r\n            weth.deposit.value(ethAmt)();\r\n\r\n            uint ink = rdiv(ethAmt, tub.per());\r\n            ink = rmul(ink, tub.per()) \u003C= ethAmt ? ink : ink - 1;\r\n\r\n            setMakerAllowance(weth, tubAddr);\r\n            tub.join(ink);\r\n\r\n            setMakerAllowance(peth, tubAddr);\r\n            tub.lock(cup, ink);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Borrow DAI Debt\r\n     */\r\n    function draw(uint cdpNum, uint _wad, bool isCompound) internal {\r\n        bytes32 cup = bytes32(cdpNum);\r\n        if (_wad \u003E 0) {\r\n            TubInterface tub = TubInterface(getSaiTubAddress());\r\n\r\n            tub.draw(cup, _wad);\r\n\r\n            // Returning Liquidity To Liquidity Contract\r\n            returnDai(_wad, isCompound);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Check if entered amt is valid or not (Used in makerToCompound)\r\n     */\r\n    function checkCDP(bytes32 cup, uint ethAmt, uint daiAmt) internal returns (uint ethCol, uint daiDebt) {\r\n        TubInterface tub = TubInterface(getSaiTubAddress());\r\n        ethCol = rmul(tub.ink(cup), tub.per()) - 1; // get ETH col from PETH col\r\n        daiDebt = tub.tab(cup);\r\n        daiDebt = daiAmt \u003C daiDebt ? daiAmt : daiDebt; // if DAI amount \u003E max debt. Set max debt\r\n        ethCol = ethAmt \u003C ethCol ? ethAmt : ethCol; // if ETH amount \u003E max Col. Set max col\r\n    }\r\n\r\n    /**\r\n     * @dev Run wipe \u0026 Free function together\r\n     */\r\n    function wipeAndFreeMaker(\r\n        uint cdpNum,\r\n        uint jam,\r\n        uint _wad,\r\n        bool isCompound,\r\n        bool feeInMkr\r\n    ) internal returns (uint daiAmt)\r\n    {\r\n        if (feeInMkr) {\r\n            wipeWithMkr(cdpNum, _wad, isCompound);\r\n            daiAmt = _wad;\r\n        } else {\r\n            daiAmt = wipe(cdpNum, _wad, isCompound);\r\n        }\r\n        free(cdpNum, jam);\r\n    }\r\n\r\n    /**\r\n     * @dev Run Lock \u0026 Draw function together\r\n     */\r\n    function lockAndDrawMaker(\r\n        uint cdpNum,\r\n        uint jam,\r\n        uint _wad,\r\n        bool isCompound\r\n    ) internal\r\n    {\r\n        lock(cdpNum, jam);\r\n        draw(cdpNum, _wad, isCompound);\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract CompoundResolver is MakerResolver {\r\n\r\n    /**\r\n     * @dev Deposit ETH and mint CETH\r\n     */\r\n    function mintCEth(uint tokenAmt) internal {\r\n        enterMarket(getCETHAddress());\r\n        CETHInterface cToken = CETHInterface(getCETHAddress());\r\n        cToken.mint.value(tokenAmt)();\r\n        emit LogMint(\r\n            getAddressETH(),\r\n            getCETHAddress(),\r\n            tokenAmt,\r\n            msg.sender\r\n        );\r\n    }\r\n\r\n    /**\r\n     * @dev borrow DAI\r\n     */\r\n    function borrowDAIComp(uint daiAmt, bool isCompound) internal {\r\n        enterMarket(getCDAIAddress());\r\n        require(CTokenInterface(getCDAIAddress()).borrow(daiAmt) == 0, \u0022got collateral?\u0022);\r\n        // Returning Liquidity to Liquidity Contract\r\n        returnDai(daiAmt, isCompound);\r\n        emit LogBorrow(\r\n            getDAIAddress(),\r\n            getCDAIAddress(),\r\n            daiAmt,\r\n            address(this)\r\n        );\r\n    }\r\n\r\n    /**\r\n     * @dev Pay DAI Debt\r\n     */\r\n    function repayDaiComp(uint tokenAmt, bool isCompound) internal returns (uint wipeAmt) {\r\n        CERC20Interface cToken = CERC20Interface(getCDAIAddress());\r\n        uint daiBorrowed = cToken.borrowBalanceCurrent(address(this));\r\n        wipeAmt = tokenAmt \u003C daiBorrowed ? tokenAmt : daiBorrowed;\r\n        // Getting Liquidity from Liquidity Contract\r\n        accessDai(wipeAmt, isCompound);\r\n        setApproval(getDAIAddress(), wipeAmt, getCDAIAddress());\r\n        require(cToken.repayBorrow(wipeAmt) == 0, \u0022transfer approved?\u0022);\r\n        emit LogRepay(\r\n            getDAIAddress(),\r\n            getCDAIAddress(),\r\n            wipeAmt,\r\n            address(this)\r\n        );\r\n    }\r\n\r\n    /**\r\n     * @dev Redeem CETH\r\n     * @param tokenAmt Amount of token To Redeem\r\n     */\r\n    function redeemCETH(uint tokenAmt) internal returns(uint ethAmtReddemed) {\r\n        CTokenInterface cToken = CTokenInterface(getCETHAddress());\r\n        uint cethBal = cToken.balanceOf(address(this));\r\n        uint exchangeRate = cToken.exchangeRateCurrent();\r\n        uint cethInEth = wmul(cethBal, exchangeRate);\r\n        setApproval(getCETHAddress(), 2**128, getCETHAddress());\r\n        ethAmtReddemed = tokenAmt;\r\n        if (tokenAmt \u003E cethInEth) {\r\n            require(cToken.redeem(cethBal) == 0, \u0022something went wrong\u0022);\r\n            ethAmtReddemed = cethInEth;\r\n        } else {\r\n            require(cToken.redeemUnderlying(tokenAmt) == 0, \u0022something went wrong\u0022);\r\n        }\r\n        emit LogRedeem(\r\n            getAddressETH(),\r\n            getCETHAddress(),\r\n            ethAmtReddemed,\r\n            address(this)\r\n        );\r\n    }\r\n\r\n    /**\r\n     * @dev run mint \u0026 borrow together\r\n     */\r\n    function mintAndBorrowComp(uint ethAmt, uint daiAmt, bool isCompound) internal {\r\n        mintCEth(ethAmt);\r\n        borrowDAIComp(daiAmt, isCompound);\r\n    }\r\n\r\n    /**\r\n     * @dev run payback \u0026 redeem together\r\n     */\r\n    function paybackAndRedeemComp(uint ethCol, uint daiDebt, bool isCompound) internal returns (uint ethAmt, uint daiAmt) {\r\n        daiAmt = repayDaiComp(daiDebt, isCompound);\r\n        ethAmt = redeemCETH(ethCol);\r\n    }\r\n\r\n    /**\r\n     * @dev Check if entered amt is valid or not (Used in makerToCompound)\r\n     */\r\n    function checkCompound(uint ethAmt, uint daiAmt) internal returns (uint ethCol, uint daiDebt) {\r\n        CTokenInterface cEthContract = CTokenInterface(getCETHAddress());\r\n        uint cEthBal = cEthContract.balanceOf(address(this));\r\n        uint ethExchangeRate = cEthContract.exchangeRateCurrent();\r\n        ethCol = wmul(cEthBal, ethExchangeRate);\r\n        ethCol = wdiv(ethCol, ethExchangeRate) \u003C= cEthBal ? ethCol : ethCol - 1;\r\n        ethCol = ethCol \u003C= ethAmt ? ethCol : ethAmt; // Set Max if amount is greater than the Col user have\r\n\r\n        daiDebt = CERC20Interface(getCDAIAddress()).borrowBalanceCurrent(address(this));\r\n        daiDebt = daiDebt \u003C= daiAmt ? daiDebt : daiAmt; // Set Max if amount is greater than the Debt user have\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract InstaMakerCompBridge is CompoundResolver {\r\n\r\n    event LogMakerToCompound(uint ethAmt, uint daiAmt);\r\n    event LogCompoundToMaker(uint ethAmt, uint daiAmt);\r\n\r\n    /**\r\n     * @dev convert Maker CDP into Compound Collateral\r\n     */\r\n    function makerToCompound(\r\n        uint cdpId,\r\n        uint ethQty,\r\n        uint daiQty,\r\n        bool isCompound, // access Liquidity from Compound\r\n        bool feeInMkr\r\n        ) external\r\n        {\r\n        // subtracting 0.00000001 ETH from initialPoolBal to solve Compound 8 decimal CETH error.\r\n        uint initialPoolBal = sub(getPoolAddr().balance, 10000000000);\r\n\r\n        (uint ethAmt, uint daiDebt) = checkCDP(bytes32(cdpId), ethQty, daiQty);\r\n        uint daiAmt = wipeAndFreeMaker(\r\n            cdpId,\r\n            ethAmt,\r\n            daiDebt,\r\n            isCompound,\r\n            feeInMkr\r\n        ); // Getting Liquidity inside Wipe function\r\n        enterMarket(getCETHAddress());\r\n        enterMarket(getCDAIAddress());\r\n        mintAndBorrowComp(ethAmt, daiAmt, isCompound); // Returning Liquidity inside Borrow function\r\n\r\n        uint finalPoolBal = getPoolAddr().balance;\r\n        assert(finalPoolBal \u003E= initialPoolBal);\r\n\r\n        emit LogMakerToCompound(ethAmt, daiAmt);\r\n    }\r\n\r\n    /**\r\n     * @dev convert Compound Collateral into Maker CDP\r\n     * @param cdpId = 0, if user don\u0027t have any CDP\r\n     */\r\n    function compoundToMaker(\r\n        uint cdpId,\r\n        uint ethQty,\r\n        uint daiQty,\r\n        bool isCompound\r\n    ) external\r\n    {\r\n        // subtracting 0.00000001 ETH from initialPoolBal to solve Compound 8 decimal CETH error.\r\n        uint initialPoolBal = sub(getPoolAddr().balance, 10000000000);\r\n\r\n        uint cdpNum = cdpId \u003E 0 ? cdpId : open();\r\n        (uint ethCol, uint daiDebt) = checkCompound(ethQty, daiQty);\r\n        (uint ethAmt, uint daiAmt) = paybackAndRedeemComp(ethCol, daiDebt, isCompound); // Getting Liquidity inside Wipe function\r\n        ethAmt = ethAmt \u003C address(this).balance ? ethAmt : address(this).balance;\r\n        lockAndDrawMaker(\r\n            cdpNum,\r\n            ethAmt,\r\n            daiAmt,\r\n            isCompound\r\n        ); // Returning Liquidity inside Borrow function\r\n\r\n        uint finalPoolBal = getPoolAddr().balance;\r\n        assert(finalPoolBal \u003E= initialPoolBal);\r\n\r\n        emit LogCompoundToMaker(ethAmt, daiAmt);\r\n    }\r\n\r\n    function() external payable {}\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getMKRAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022dai\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getComptrollerAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022troller\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCompOracleAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022troller\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getUniswapMKRExchange\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022ume\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAddressETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022eth\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022cdpId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022ethQty\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022daiQty\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022isCompound\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022compoundToMaker\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getOracleAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022oracle\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCETHAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022cEth\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getUniswapDAIExchange\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022ude\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getPoolAddr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022poolAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getDAIAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022dai\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022cdpId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022ethQty\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022daiQty\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022isCompound\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022feeInMkr\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022makerToCompound\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getSaiTubAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022sai\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCDAIAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022cDai\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ethAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022daiAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogMakerToCompound\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ethAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022daiAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogCompoundToMaker\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022erc20\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022cErc20\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokenAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogMint\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022erc20\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022cErc20\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokenAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogRedeem\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022erc20\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022cErc20\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokenAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogBorrow\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022erc20\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022cErc20\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokenAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogRepay\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022cdpNum\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogOpen\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022cdpNum\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amtETH\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amtPETH\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogLock\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022cdpNum\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amtETH\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amtPETH\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogFree\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022cdpNum\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amtDAI\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogDraw\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022cdpNum\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022daiAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022mkrFee\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022daiFee\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogWipe\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022cdpNum\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogShut\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"InstaMakerCompBridge","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://f4d04431de7728b319bbc57653ff00fc59d7b7dff1f8c028d61f6891de8b02f0"}]