[{"SourceCode":"pragma solidity ^0.5.8;\r\n/**\r\n compound debt migrate\r\n */\r\ninterface CTokenInterface {\r\n    function mint(uint mintAmount) external returns (uint);\r\n    function redeem(uint redeemTokens) external returns (uint);\r\n    function borrow(uint borrowAmount) external returns (uint);\r\n    function borrowBalanceCurrent(address account) external returns (uint);\r\n    function repayBorrow(uint repayAmount) external returns (uint);\r\n    function totalReserves() external view returns (uint);\r\n    function underlying() external view returns (address);\r\n\r\n    function balanceOf(address owner) external view returns (uint256 balance);\r\n    function allowance(address, address) external view returns (uint);\r\n    function approve(address, uint) external;\r\n    function transfer(address, uint) external returns (bool);\r\n    function transferFrom(address, address, uint) external returns (bool);\r\n}\r\n\r\ninterface ERC20Interface {\r\n    function allowance(address, address) external view returns (uint);\r\n    function balanceOf(address) external view returns (uint);\r\n    function approve(address, uint) external;\r\n    function transfer(address, uint) external returns (bool);\r\n    function transferFrom(address, address, uint) external returns (bool);\r\n}\r\n\r\ninterface ComptrollerInterface {\r\n    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);\r\n    function exitMarket(address cTokenAddress) external returns (uint);\r\n    function getAssetsIn(address account) external view returns (address[] memory);\r\n    function getAccountLiquidity(address account) external view returns (uint, uint, uint);\r\n}\r\n\r\ninterface PoolInterface {\r\n    function accessToken(address[] calldata ctknAddr, uint[] calldata tknAmt, bool isCompound) external;\r\n    function paybackToken(address[] calldata ctknAddr, bool isCompound) external payable;\r\n}\r\n\r\n/** Swap Functionality */\r\ninterface ScdMcdMigration {\r\n    function swapDaiToSai(uint daiAmt) external;\r\n    function swapSaiToDai(uint saiAmt) external;\r\n}\r\n\r\ninterface InstaMcdAddress {\r\n    function saiJoin() external returns (address);\r\n    function migration() external returns (address payable);\r\n}\r\n\r\n\r\ncontract DSMath {\r\n\r\n    function sub(uint x, uint y) internal pure returns (uint z) {\r\n        z = x - y \u003C= x ? x - y : 0;\r\n    }\r\n\r\n    function add(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x \u002B y) \u003E= x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    function mul(uint x, uint y) internal pure returns (uint z) {\r\n        require(y == 0 || (z = x * y) / y == x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    uint constant WAD = 10 ** 18;\r\n\r\n    function wmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), WAD / 2) / WAD;\r\n    }\r\n\r\n    function wdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, WAD), y / 2) / y;\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract Helpers is DSMath {\r\n\r\n    /**\r\n     * @dev get Compound Comptroller Address\r\n     */\r\n    function getComptrollerAddress() public pure returns (address troller) {\r\n        troller = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;\r\n    }\r\n\r\n    /**\r\n     * @dev get MakerDAO MCD Address contract\r\n     */\r\n    function getMcdAddresses() public pure returns (address mcd) {\r\n        mcd = 0xF23196DF1C440345DE07feFbe556a5eF0dcD29F0;\r\n    }\r\n\r\n    /**\r\n     * @dev get Compound SAI Address\r\n     */\r\n    function getCSaiAddress() public pure returns (address csaiAddr) {\r\n        csaiAddr = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;\r\n    }\r\n\r\n    /**\r\n     * @dev get Compound DAI Address\r\n     */\r\n    function getCDaiAddress() public pure returns (address cdaiAddr) {\r\n        cdaiAddr = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;\r\n    }\r\n\r\n    /**\r\n     * @dev get SAI Address\r\n     */\r\n    function getSaiAddress() public pure returns (address saiAddr) {\r\n        saiAddr = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;\r\n    }\r\n\r\n    /**\r\n     * @dev get DAI Address\r\n     */\r\n    function getDaiAddress() public pure returns (address daiAddr) {\r\n        daiAddr = 0x6B175474E89094C44Da98b954EedeAC495271d0F;\r\n    }\r\n\r\n    /**\r\n     * @dev get InstaDapp\u0027s Pool Address\r\n     */\r\n    function getLiquidityAddress() public pure returns (address poolAddr) {\r\n        poolAddr = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;\r\n    }\r\n\r\n    function enterMarket(address cErc20) internal {\r\n        ComptrollerInterface troller = ComptrollerInterface(getComptrollerAddress());\r\n        address[] memory markets = troller.getAssetsIn(address(this));\r\n        bool isEntered = false;\r\n        for (uint i = 0; i \u003C markets.length; i\u002B\u002B) {\r\n            if (markets[i] == cErc20) {\r\n                isEntered = true;\r\n            }\r\n        }\r\n        if (!isEntered) {\r\n            address[] memory toEnter = new address[](1);\r\n            toEnter[0] = cErc20;\r\n            troller.enterMarkets(toEnter);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev setting allowance to compound for the \u0022user proxy\u0022 if required\r\n     */\r\n    function setApproval(address erc20, uint srcAmt, address to) internal {\r\n        ERC20Interface erc20Contract = ERC20Interface(erc20);\r\n        uint tokenAllowance = erc20Contract.allowance(address(this), to);\r\n        if (srcAmt \u003E tokenAllowance) {\r\n            erc20Contract.approve(to, uint(-1));\r\n        }\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract PoolActions is Helpers {\r\n\r\n    function accessLiquidity(uint amt) internal {\r\n        address[] memory ctknAddrArr = new address[](1);\r\n        ctknAddrArr[0] = getCSaiAddress();\r\n        uint[] memory tknAmtArr = new uint[](1);\r\n        tknAmtArr[0] = amt;\r\n        PoolInterface(getLiquidityAddress()).accessToken(ctknAddrArr, tknAmtArr, false);\r\n    }\r\n\r\n    function paybackLiquidity(uint amt) internal {\r\n        address[] memory ctknAddrArr = new address[](1);\r\n        ctknAddrArr[0] = getCSaiAddress();\r\n        ERC20Interface(getSaiAddress()).transfer(getLiquidityAddress(), amt);\r\n        PoolInterface(getLiquidityAddress()).paybackToken(ctknAddrArr, false);\r\n    }\r\n\r\n}\r\n\r\n\r\n/** Swap from Dai to Sai */\r\ncontract MigrationProxyActions is PoolActions {\r\n\r\n    function swapSaiToDai(\r\n        uint wad                            // Amount to swap\r\n    ) internal\r\n    {\r\n        address payable scdMcdMigration = InstaMcdAddress(getMcdAddresses()).migration();\r\n        ERC20Interface sai = ERC20Interface(getSaiAddress());\r\n        if (sai.allowance(address(this), scdMcdMigration) \u003C wad) {\r\n            sai.approve(scdMcdMigration, wad);\r\n        }\r\n        ScdMcdMigration(scdMcdMigration).swapSaiToDai(wad);\r\n    }\r\n\r\n    function swapDaiToSai(\r\n        uint wad                            // Amount to swap\r\n    ) internal\r\n    {\r\n        address payable scdMcdMigration = InstaMcdAddress(getMcdAddresses()).migration();\r\n        ERC20Interface dai = ERC20Interface(getDaiAddress());\r\n        if (dai.allowance(address(this), scdMcdMigration) \u003C wad) {\r\n            dai.approve(scdMcdMigration, wad);\r\n        }\r\n        ScdMcdMigration(scdMcdMigration).swapDaiToSai(wad);\r\n        paybackLiquidity(wad);\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract CompoundResolver is MigrationProxyActions {\r\n\r\n    function redeemCSai(uint cTokenAmt) internal {\r\n        CTokenInterface cToken = CTokenInterface(getCSaiAddress());\r\n        uint toRedeem = cToken.balanceOf(address(this));\r\n        toRedeem = toRedeem \u003E cTokenAmt ? cTokenAmt : toRedeem;\r\n        require(cToken.redeem(toRedeem) == 0, \u0022Redeem SAI went wrong\u0022);\r\n    }\r\n\r\n    function mintCDai() internal {\r\n        enterMarket(getCDaiAddress());\r\n        CTokenInterface cToken = CTokenInterface(getCDaiAddress());\r\n        address erc20 = cToken.underlying();\r\n        uint toDeposit = ERC20Interface(erc20).balanceOf(address(this));\r\n        setApproval(erc20, toDeposit, getCDaiAddress());\r\n        assert(cToken.mint(toDeposit) == 0);\r\n    }\r\n\r\n    function borrowDAI(uint tokenAmt) internal {\r\n        enterMarket(getCDaiAddress());\r\n        require(CTokenInterface(getCDaiAddress()).borrow(tokenAmt) == 0, \u0022got collateral?\u0022);\r\n    }\r\n\r\n    function repaySAI(uint tokenAmt) internal returns (uint toRepay) {\r\n        CTokenInterface cToken = CTokenInterface(getCSaiAddress());\r\n        toRepay = cToken.borrowBalanceCurrent(address(this));\r\n        toRepay = toRepay \u003E tokenAmt ? tokenAmt : toRepay;\r\n        accessLiquidity(toRepay);\r\n        setApproval(cToken.underlying(), toRepay, getCSaiAddress());\r\n        require(cToken.repayBorrow(toRepay) == 0, \u0022Enough Tokens?\u0022);\r\n    }\r\n}\r\n\r\n\r\ncontract CompMigration is CompoundResolver {\r\n\r\n    event LogCompMigrateCSaiToCDai(uint swapAmt, address owner);\r\n    event LogCompMigrateDebt(uint migrateAmt, address owner);\r\n\r\n    function migrateCSaiToCDai(uint ctknToMigrate) external {\r\n        redeemCSai(ctknToMigrate);\r\n        uint saiBal = ERC20Interface(getSaiAddress()).balanceOf(address(this));\r\n        swapSaiToDai(saiBal);\r\n        mintCDai();\r\n        emit LogCompMigrateCSaiToCDai(saiBal, address(this));\r\n    }\r\n\r\n    function migrateDebt(uint debtToMigrate) external {\r\n        uint initialPoolBal = sub(getLiquidityAddress().balance, 10000000000);\r\n\r\n        uint saiJoinBal = ERC20Interface(getSaiAddress()).balanceOf(InstaMcdAddress(getMcdAddresses()).saiJoin());\r\n        // Check SAI balance of migration contract. If less than debtToMigrate then set debtToMigrate = SAI_Bal\r\n        uint migrateAmt = debtToMigrate \u003C saiJoinBal ? debtToMigrate : sub(saiJoinBal, 10000);\r\n\r\n        uint debtPaid = repaySAI(migrateAmt); // Repaying SAI debt using InstaDApp pool\r\n        borrowDAI(debtPaid); // borrowing DAI debt\r\n        swapDaiToSai(debtPaid); // swapping SAI into DAI and paying back to InstaDApp pool\r\n        uint finalPoolBal = getLiquidityAddress().balance;\r\n        assert(finalPoolBal \u003E= initialPoolBal);\r\n        emit LogCompMigrateDebt(debtPaid, address(this));\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract InstaCompoundMigrate is CompMigration {\r\n\r\n    function() external payable {}\r\n\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022debtToMigrate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022migrateDebt\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getLiquidityAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022poolAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getDaiAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022daiAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getComptrollerAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022troller\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022ctknToMigrate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022migrateCSaiToCDai\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getSaiAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022saiAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCDaiAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022cdaiAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCSaiAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022csaiAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getMcdAddresses\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022mcd\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022swapAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogCompMigrateCSaiToCDai\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022migrateAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogCompMigrateDebt\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"InstaCompoundMigrate","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://f9b28e928d191d4aee0118c98167a6b5a77a84da7715d8c0ecf02a40146171d1"}]