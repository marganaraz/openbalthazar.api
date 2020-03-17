[{"SourceCode":"pragma solidity ^0.5.8;\r\n\r\ninterface GemLike {\r\n    function approve(address, uint) external;\r\n    function transfer(address, uint) external;\r\n    function transferFrom(address, address, uint) external;\r\n    function deposit() external payable;\r\n    function withdraw(uint) external;\r\n}\r\n\r\ninterface ManagerLike {\r\n    function cdpCan(address, uint, address) external view returns (uint);\r\n    function ilks(uint) external view returns (bytes32);\r\n    function owns(uint) external view returns (address);\r\n    function urns(uint) external view returns (address);\r\n    function vat() external view returns (address);\r\n    function open(bytes32, address) external returns (uint);\r\n    function give(uint, address) external;\r\n    function cdpAllow(uint, address, uint) external;\r\n    function urnAllow(address, uint) external;\r\n    function frob(uint, int, int) external;\r\n    function flux(uint, address, uint) external;\r\n    function move(uint, address, uint) external;\r\n    function exit(\r\n        address,\r\n        uint,\r\n        address,\r\n        uint\r\n    ) external;\r\n    function quit(uint, address) external;\r\n    function enter(address, uint) external;\r\n    function shift(uint, uint) external;\r\n}\r\n\r\ninterface VatLike {\r\n    function can(address, address) external view returns (uint);\r\n    function ilks(bytes32) external view returns (uint, uint, uint, uint, uint);\r\n    function dai(address) external view returns (uint);\r\n    function urns(bytes32, address) external view returns (uint, uint);\r\n    function frob(\r\n        bytes32,\r\n        address,\r\n        address,\r\n        address,\r\n        int,\r\n        int\r\n    ) external;\r\n    function hope(address) external;\r\n    function move(address, address, uint) external;\r\n    function gem(bytes32, address) external view returns (uint);\r\n\r\n}\r\n\r\ninterface GemJoinLike {\r\n    function dec() external returns (uint);\r\n    function gem() external returns (GemLike);\r\n    function join(address, uint) external payable;\r\n    function exit(address, uint) external;\r\n}\r\n\r\ninterface DaiJoinLike {\r\n    function vat() external returns (VatLike);\r\n    function dai() external returns (GemLike);\r\n    function join(address, uint) external payable;\r\n    function exit(address, uint) external;\r\n}\r\n\r\ninterface JugLike {\r\n    function drip(bytes32) external returns (uint);\r\n}\r\n\r\ninterface oracleInterface {\r\n    function read() external view returns (bytes32);\r\n}\r\n\r\ninterface UniswapExchange {\r\n    function getEthToTokenOutputPrice(uint256 tokensBought) external view returns (uint256 ethSold);\r\n    function getTokenToEthOutputPrice(uint256 ethBought) external view returns (uint256 tokensSold);\r\n    function tokenToTokenSwapOutput(\r\n        uint256 tokensBought,\r\n        uint256 maxTokensSold,\r\n        uint256 maxEthSold,\r\n        uint256 deadline,\r\n        address tokenAddr\r\n        ) external returns (uint256  tokensSold);\r\n}\r\n\r\n\r\ninterface TokenInterface {\r\n    function allowance(address, address) external view returns (uint);\r\n    function balanceOf(address) external view returns (uint);\r\n    function approve(address, uint) external;\r\n    function transfer(address, uint) external returns (bool);\r\n    function transferFrom(address, address, uint) external returns (bool);\r\n    function deposit() external payable;\r\n    function withdraw(uint) external;\r\n}\r\n\r\ninterface KyberInterface {\r\n    function trade(\r\n        address src,\r\n        uint srcAmount,\r\n        address dest,\r\n        address destAddress,\r\n        uint maxDestAmount,\r\n        uint minConversionRate,\r\n        address walletId\r\n        ) external payable returns (uint);\r\n\r\n    function getExpectedRate(\r\n        address src,\r\n        address dest,\r\n        uint srcQty\r\n        ) external view returns (uint, uint);\r\n}\r\n\r\ninterface SplitSwapInterface {\r\n    function getBest(address src, address dest, uint srcAmt) external view returns (uint bestExchange, uint destAmt);\r\n    function ethToDaiSwap(uint splitAmt, uint slippageAmt) external payable returns (uint destAmt);\r\n    function daiToEthSwap(uint srcAmt, uint splitAmt, uint slippageAmt) external returns (uint destAmt);\r\n}\r\n\r\ninterface InstaMcdAddress {\r\n    function manager() external view returns (address);\r\n    function dai() external view returns (address);\r\n    function daiJoin() external view returns (address);\r\n    function vat() external view returns (address);\r\n    function jug() external view returns (address);\r\n    function ethAJoin() external view returns (address);\r\n}\r\n\r\n\r\ncontract DSMath {\r\n\r\n    function add(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x \u002B y) \u003E= x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    function sub(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x - y) \u003C= x, \u0022ds-math-sub-underflow\u0022);\r\n    }\r\n\r\n    function mul(uint x, uint y) internal pure returns (uint z) {\r\n        require(y == 0 || (z = x * y) / y == x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    uint constant WAD = 10 ** 18;\r\n    uint constant RAY = 10 ** 27;\r\n\r\n    function rmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), RAY / 2) / RAY;\r\n    }\r\n\r\n    function rdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, RAY), y / 2) / y;\r\n    }\r\n\r\n    function wmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), WAD / 2) / WAD;\r\n    }\r\n\r\n    function wdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, WAD), y / 2) / y;\r\n    }\r\n\r\n    function toInt(uint x) internal pure returns (int y) {\r\n        y = int(x);\r\n        require(y \u003E= 0, \u0022int-overflow\u0022);\r\n    }\r\n\r\n    function toRad(uint wad) internal pure returns (uint rad) {\r\n        rad = mul(wad, 10 ** 27);\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract Helpers is DSMath {\r\n\r\n    /**\r\n     * @dev get MakerDAO MCD Address contract\r\n     */\r\n    function getMcdAddresses() public pure returns (address mcd) {\r\n        mcd = 0xF23196DF1C440345DE07feFbe556a5eF0dcD29F0;\r\n    }\r\n\r\n    /**\r\n     * @dev get MakerDAO Oracle for ETH price\r\n     */\r\n    function getOracleAddress() public pure returns (address oracle) {\r\n        oracle = 0x729D19f657BD0614b4985Cf1D82531c67569197B;\r\n    }\r\n\r\n    /**\r\n     * @dev get ethereum address for trade\r\n     */\r\n    function getAddressETH() public pure returns (address eth) {\r\n        eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\r\n    }\r\n\r\n    /**\r\n     * @dev get dai address for trade\r\n     */\r\n    function getAddressDAI() public pure returns (address dai) {\r\n        dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;\r\n    }\r\n\r\n    /**\r\n     * @dev get admin address\r\n     */\r\n    function getAddressSplitSwap() public pure returns (address payable splitSwap) {\r\n        splitSwap = 0xc51a5024280d6AB2596e4aFFe1BDf6bDc2318da2;\r\n    }\r\n\r\n    function getVaultStats(uint cup) internal view returns (uint ethCol, uint daiDebt, uint usdPerEth) {\r\n        address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n        address urn = ManagerLike(manager).urns(cup);\r\n        bytes32 ilk = ManagerLike(manager).ilks(cup);\r\n        (ethCol, daiDebt) = VatLike(ManagerLike(manager).vat()).urns(ilk, urn);\r\n        (,uint rate,,,) = VatLike(ManagerLike(manager).vat()).ilks(ilk);\r\n        daiDebt = rmul(daiDebt, rate);\r\n        usdPerEth = uint(oracleInterface(getOracleAddress()).read());\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract MakerHelpers is Helpers {\r\n\r\n    event LogLock(uint vaultId, uint amtETH, address owner);\r\n    event LogFree(uint vaultId, uint amtETH, address owner);\r\n    event LogDraw(uint vaultId, uint daiAmt, address owner);\r\n    event LogWipe(uint vaultId, uint daiAmt, address owner);\r\n\r\n    function setAllowance(TokenInterface _token, address _spender) internal {\r\n        if (_token.allowance(address(this), _spender) != uint(-1)) {\r\n            _token.approve(_spender, uint(-1));\r\n        }\r\n    }\r\n\r\n    function _getDrawDart(\r\n        address vat,\r\n        address jug,\r\n        address urn,\r\n        bytes32 ilk,\r\n        uint wad\r\n    ) internal returns (int dart)\r\n    {\r\n        // Updates stability fee rate\r\n        uint rate = JugLike(jug).drip(ilk);\r\n\r\n        // Gets DAI balance of the urn in the vat\r\n        uint dai = VatLike(vat).dai(urn);\r\n\r\n        // If there was already enough DAI in the vat balance, just exits it without adding more debt\r\n        if (dai \u003C mul(wad, RAY)) {\r\n            // Calculates the needed dart so together with the existing dai in the vat is enough to exit wad amount of DAI tokens\r\n            dart = toInt(sub(mul(wad, RAY), dai) / rate);\r\n            // This is neeeded due lack of precision. It might need to sum an extra dart wei (for the given DAI wad amount)\r\n            dart = mul(uint(dart), rate) \u003C mul(wad, RAY) ? dart \u002B 1 : dart;\r\n        }\r\n    }\r\n\r\n    function _getWipeDart(\r\n        address vat,\r\n        uint dai,\r\n        address urn,\r\n        bytes32 ilk\r\n    ) internal view returns (int dart)\r\n    {\r\n        // Gets actual rate from the vat\r\n        (, uint rate,,,) = VatLike(vat).ilks(ilk);\r\n        // Gets actual art value of the urn\r\n        (, uint art) = VatLike(vat).urns(ilk, urn);\r\n\r\n        // Uses the whole dai balance in the vat to reduce the debt\r\n        dart = toInt(dai / rate);\r\n        // Checks the calculated dart is not higher than urn.art (total debt), otherwise uses its value\r\n        dart = uint(dart) \u003C= art ? - dart : - toInt(art);\r\n    }\r\n\r\n    function joinDaiJoin(address urn, uint wad) internal {\r\n        address daiJoin = InstaMcdAddress(getMcdAddresses()).daiJoin();\r\n        // Gets DAI from the user\u0027s wallet\r\n        DaiJoinLike(daiJoin).dai().transferFrom(msg.sender, address(this), wad);\r\n        // Approves adapter to take the DAI amount\r\n        DaiJoinLike(daiJoin).dai().approve(daiJoin, wad);\r\n        // Joins DAI into the vat\r\n        DaiJoinLike(daiJoin).join(urn, wad);\r\n    }\r\n\r\n    function lock(uint cdpNum, uint wad) internal {\r\n        if (wad \u003E 0) {\r\n            address ethJoin = InstaMcdAddress(getMcdAddresses()).ethAJoin();\r\n            address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n\r\n            // Wraps ETH in WETH\r\n            GemJoinLike(ethJoin).gem().deposit.value(wad)();\r\n            // Approves adapter to take the WETH amount\r\n            GemJoinLike(ethJoin).gem().approve(address(ethJoin), wad);\r\n            // Joins WETH collateral into the vat\r\n            GemJoinLike(ethJoin).join(address(this), wad);\r\n            // Locks WETH amount into the CDP\r\n            VatLike(ManagerLike(manager).vat()).frob(\r\n                ManagerLike(manager).ilks(cdpNum),\r\n                ManagerLike(manager).urns(cdpNum),\r\n                address(this),\r\n                address(this),\r\n                toInt(wad),\r\n                0\r\n            );\r\n            // Sends ETH back to the user\u0027s wallet\r\n            emit LogLock(\r\n                cdpNum,\r\n                wad,\r\n                address(this)\r\n            );\r\n        }\r\n    }\r\n\r\n    function free(uint cdp, uint wad) internal {\r\n        if (wad \u003E 0) {\r\n            address ethJoin = InstaMcdAddress(getMcdAddresses()).ethAJoin();\r\n            address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n\r\n            // Unlocks WETH amount from the CDP\r\n            ManagerLike(manager).frob(\r\n                cdp,\r\n                -toInt(wad),\r\n                0\r\n            );\r\n            // Moves the amount from the CDP urn to proxy\u0027s address\r\n            ManagerLike(manager).flux(\r\n                cdp,\r\n                address(this),\r\n                wad\r\n            );\r\n            // Exits WETH amount to proxy address as a token\r\n            GemJoinLike(ethJoin).exit(address(this), wad);\r\n            // Converts WETH to ETH\r\n            GemJoinLike(ethJoin).gem().withdraw(wad);\r\n            // Sends ETH back to the user\u0027s wallet\r\n\r\n            emit LogFree(\r\n                cdp,\r\n                wad,\r\n                address(this)\r\n            );\r\n        }\r\n    }\r\n\r\n    function draw(uint cdp, uint wad) internal {\r\n        if (wad \u003E 0) {\r\n            address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n            address jug = InstaMcdAddress(getMcdAddresses()).jug();\r\n            address daiJoin = InstaMcdAddress(getMcdAddresses()).daiJoin();\r\n            address urn = ManagerLike(manager).urns(cdp);\r\n            address vat = ManagerLike(manager).vat();\r\n            bytes32 ilk = ManagerLike(manager).ilks(cdp);\r\n            // Generates debt in the CDP\r\n            ManagerLike(manager).frob(\r\n                cdp,\r\n                0,\r\n                _getDrawDart(\r\n                    vat,\r\n                    jug,\r\n                    urn,\r\n                    ilk,\r\n                    wad\r\n                )\r\n            );\r\n            // Moves the DAI amount (balance in the vat in rad) to proxy\u0027s address\r\n            ManagerLike(manager).move(\r\n                cdp,\r\n                address(this),\r\n                toRad(wad)\r\n            );\r\n            // Allows adapter to access to proxy\u0027s DAI balance in the vat\r\n            if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {\r\n                VatLike(vat).hope(daiJoin);\r\n            }\r\n            // Exits DAI to the user\u0027s wallet as a token\r\n            DaiJoinLike(daiJoin).exit(address(this), wad);\r\n\r\n            emit LogDraw(\r\n                cdp,\r\n                wad,\r\n                address(this)\r\n            );\r\n        }\r\n    }\r\n\r\n    function wipe(uint cdp, uint wad) internal {\r\n        if (wad \u003E 0) {\r\n            address manager = InstaMcdAddress(getMcdAddresses()).manager();\r\n            address vat = ManagerLike(manager).vat();\r\n            address urn = ManagerLike(manager).urns(cdp);\r\n            bytes32 ilk = ManagerLike(manager).ilks(cdp);\r\n\r\n            address own = ManagerLike(manager).owns(cdp);\r\n            if (own == address(this) || ManagerLike(manager).cdpCan(own, cdp, address(this)) == 1) {\r\n                // Joins DAI amount into the vat\r\n                joinDaiJoin(urn, wad);\r\n                // Paybacks debt to the CDP\r\n                ManagerLike(manager).frob(\r\n                    cdp,\r\n                    0,\r\n                    _getWipeDart(\r\n                        vat,\r\n                        VatLike(vat).dai(urn),\r\n                        urn,\r\n                        ilk\r\n                    )\r\n                );\r\n            } else {\r\n                // Joins DAI amount into the vat\r\n                joinDaiJoin(address(this), wad);\r\n                // Paybacks debt to the CDP\r\n                VatLike(vat).frob(\r\n                    ilk,\r\n                    urn,\r\n                    address(this),\r\n                    address(this),\r\n                    0,\r\n                    _getWipeDart(\r\n                        vat,\r\n                        wad * RAY,\r\n                        urn,\r\n                        ilk\r\n                    )\r\n                );\r\n            }\r\n\r\n            emit LogWipe(\r\n                cdp,\r\n                wad,\r\n                address(this)\r\n            );\r\n\r\n        }\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract GetDetails is MakerHelpers {\r\n\r\n    function getMax(uint cdpID) public view returns (uint maxColToFree, uint maxDaiToDraw, uint ethInUSD) {\r\n        (uint ethCol, uint daiDebt, uint usdPerEth) = getVaultStats(cdpID);\r\n        uint colToUSD = sub(wmul(ethCol, usdPerEth), 10);\r\n        uint minColNeeded = add(wmul(daiDebt, 1500000000000000000), 10);\r\n        maxColToFree = wdiv(sub(colToUSD, minColNeeded), usdPerEth);\r\n        uint maxDebtLimit = sub(wdiv(colToUSD, 1500000000000000000), 10);\r\n        maxDaiToDraw = sub(maxDebtLimit, daiDebt);\r\n        ethInUSD = usdPerEth;\r\n    }\r\n\r\n    function getSave(uint cdpID, uint ethToSwap) public view returns (uint finalEthCol, uint finalDaiDebt, uint finalColToUSD, bool canSave) {\r\n        (uint ethCol, uint daiDebt, uint usdPerEth) = getVaultStats(cdpID);\r\n        (finalEthCol, finalDaiDebt, finalColToUSD, canSave) = checkSave(\r\n            ethCol,\r\n            daiDebt,\r\n            usdPerEth,\r\n            ethToSwap\r\n        );\r\n    }\r\n\r\n    function getLeverage(\r\n        uint cdpID,\r\n        uint daiToSwap\r\n    ) public view returns (\r\n        uint finalEthCol,\r\n        uint finalDaiDebt,\r\n        uint finalColToUSD,\r\n        bool canLeverage\r\n    )\r\n    {\r\n        (uint ethCol, uint daiDebt, uint usdPerEth) = getVaultStats(cdpID);\r\n        (finalEthCol, finalDaiDebt, finalColToUSD, canLeverage) = checkLeverage(\r\n            ethCol,\r\n            daiDebt,\r\n            usdPerEth,\r\n            daiToSwap\r\n        );\r\n    }\r\n\r\n    function checkSave(\r\n        uint ethCol,\r\n        uint daiDebt,\r\n        uint usdPerEth,\r\n        uint ethToSwap\r\n    ) internal view returns\r\n    (\r\n        uint finalEthCol,\r\n        uint finalDaiDebt,\r\n        uint finalColToUSD,\r\n        bool canSave\r\n    )\r\n    {\r\n        uint colToUSD = sub(wmul(ethCol, usdPerEth), 10);\r\n        uint minColNeeded = add(wmul(daiDebt, 1500000000000000000), 10);\r\n        uint colToFree = wdiv(sub(colToUSD, minColNeeded), usdPerEth);\r\n        if (ethToSwap \u003C colToFree) {\r\n            colToFree = ethToSwap;\r\n        }\r\n        (, uint expectedDAI) = SplitSwapInterface(getAddressSplitSwap()).getBest(getAddressETH(), getAddressDAI(), colToFree);\r\n        if (expectedDAI \u003C daiDebt) {\r\n            finalEthCol = sub(ethCol, colToFree);\r\n            finalDaiDebt = sub(daiDebt, expectedDAI);\r\n            finalColToUSD = wmul(finalEthCol, usdPerEth);\r\n            canSave = true;\r\n        } else {\r\n            finalEthCol = 0;\r\n            finalDaiDebt = 0;\r\n            finalColToUSD = 0;\r\n            canSave = false;\r\n        }\r\n    }\r\n\r\n    function checkLeverage(\r\n        uint ethCol,\r\n        uint daiDebt,\r\n        uint usdPerEth,\r\n        uint daiToSwap\r\n    ) internal view returns\r\n    (\r\n        uint finalEthCol,\r\n        uint finalDaiDebt,\r\n        uint finalColToUSD,\r\n        bool canLeverage\r\n    )\r\n    {\r\n        uint colToUSD = sub(wmul(ethCol, usdPerEth), 10);\r\n        uint maxDebtLimit = sub(wdiv(colToUSD, 1500000000000000000), 10);\r\n        uint debtToBorrow = sub(maxDebtLimit, daiDebt);\r\n        if (daiToSwap \u003C debtToBorrow) {\r\n            debtToBorrow = daiToSwap;\r\n        }\r\n        (, uint expectedETH) = SplitSwapInterface(getAddressSplitSwap()).getBest(getAddressDAI(), getAddressETH(), debtToBorrow);\r\n        if (ethCol != 0) {\r\n            finalEthCol = add(ethCol, expectedETH);\r\n            finalDaiDebt = add(daiDebt, debtToBorrow);\r\n            finalColToUSD = wmul(finalEthCol, usdPerEth);\r\n            canLeverage = true;\r\n        } else {\r\n            finalEthCol = 0;\r\n            finalDaiDebt = 0;\r\n            finalColToUSD = 0;\r\n            canLeverage = false;\r\n        }\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract Save is GetDetails {\r\n\r\n    /**\r\n     * @param what 2 for SAVE \u0026 3 for LEVERAGE\r\n     */\r\n    event LogTrade(\r\n        uint what, // 0 for BUY \u0026 1 for SELL\r\n        address src,\r\n        uint srcAmt,\r\n        address dest,\r\n        uint destAmt,\r\n        address beneficiary,\r\n        uint minConversionRate,\r\n        address affiliate\r\n    );\r\n\r\n    event LogSaveVault(\r\n        uint vaultId,\r\n        uint srcETH,\r\n        uint destDAI\r\n    );\r\n\r\n    event LogLeverageVault(\r\n        uint vaultId,\r\n        uint srcDAI,\r\n        uint destETH\r\n    );\r\n\r\n\r\n    function save(\r\n        uint cdpID,\r\n        uint colToSwap,\r\n        uint splitAmt,\r\n        uint slippageAmt\r\n    ) public\r\n    {\r\n        (uint ethCol, uint daiDebt, uint usdPerEth) = getVaultStats(cdpID);\r\n        uint colToFree = getColToFree(ethCol, daiDebt, usdPerEth);\r\n        require(colToFree != 0, \u0022no-collatral-to-free\u0022);\r\n        if (colToSwap \u003C colToFree) {\r\n            colToFree = colToSwap;\r\n        }\r\n        free(cdpID, colToFree);\r\n        uint ethToSwap = address(this).balance;\r\n        ethToSwap = ethToSwap \u003C colToFree ? ethToSwap : colToFree;\r\n        uint destAmt = SplitSwapInterface(getAddressSplitSwap()).ethToDaiSwap.value(ethToSwap)(splitAmt, slippageAmt);\r\n        uint finalDebt = sub(daiDebt, destAmt);\r\n        require(finalDebt \u003E= 20*10**18 || finalDebt == 0, \u0022Final Debt should be min 20Dai.\u0022);\r\n        wipe(cdpID, destAmt);\r\n\r\n        emit LogSaveVault(cdpID, ethToSwap, destAmt);\r\n    }\r\n\r\n    function leverage(\r\n        uint cdpID,\r\n        uint daiToSwap,\r\n        uint splitAmt,\r\n        uint slippageAmt\r\n    ) public\r\n    {\r\n        (uint ethCol, uint daiDebt, uint usdPerEth) = getVaultStats(cdpID);\r\n        uint debtToBorrow = getDebtToBorrow(ethCol, daiDebt, usdPerEth);\r\n        require(debtToBorrow != 0, \u0022No-debt-to-borrow\u0022);\r\n        if (daiToSwap \u003C debtToBorrow) {\r\n            debtToBorrow = daiToSwap;\r\n        }\r\n        draw(cdpID, debtToBorrow);\r\n        TokenInterface(getAddressDAI()).approve(getAddressSplitSwap(), debtToBorrow);\r\n        uint destAmt = SplitSwapInterface(getAddressSplitSwap()).daiToEthSwap(debtToBorrow, splitAmt, slippageAmt);\r\n        lock(cdpID, destAmt);\r\n\r\n        emit LogLeverageVault(cdpID, debtToBorrow, destAmt);\r\n    }\r\n\r\n    function getColToFree(uint ethCol, uint daiDebt, uint usdPerEth) internal pure returns (uint colToFree) {\r\n        uint colToUSD = sub(wmul(ethCol, usdPerEth), 10);\r\n        uint minColNeeded = add(wmul(daiDebt, 1500000000000000000), 10);\r\n        colToFree = sub(wdiv(sub(colToUSD, minColNeeded), usdPerEth), 10);\r\n    }\r\n\r\n    function getDebtToBorrow(uint ethCol, uint daiDebt, uint usdPerEth) internal pure returns (uint debtToBorrow) {\r\n        uint colToUSD = sub(wmul(ethCol, usdPerEth), 10);\r\n        uint maxDebtLimit = sub(wdiv(colToUSD, 1500000000000000000), 10);\r\n        debtToBorrow = sub(maxDebtLimit, daiDebt);\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract InstaMcdSave is Save {\r\n    function() external payable {}\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022cdpID\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022daiToSwap\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022splitAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022slippageAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022leverage\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022cdpID\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022ethToSwap\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getSave\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022finalEthCol\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022finalDaiDebt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022finalColToUSD\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022canSave\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAddressETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022eth\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getOracleAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022oracle\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAddressDAI\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022dai\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getMcdAddresses\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022mcd\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAddressSplitSwap\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022splitSwap\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022cdpID\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022colToSwap\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022splitAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022slippageAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022save\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022cdpID\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022daiToSwap\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getLeverage\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022finalEthCol\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022finalDaiDebt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022finalColToUSD\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022canLeverage\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022cdpID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getMax\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022maxColToFree\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022maxDaiToDraw\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022ethInUSD\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022what\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022srcAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022dest\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022destAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022beneficiary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022minConversionRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022affiliate\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogTrade\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022vaultId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022srcETH\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022destDAI\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogSaveVault\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022vaultId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022srcDAI\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022destETH\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogLeverageVault\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022vaultId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amtETH\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogLock\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022vaultId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amtETH\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogFree\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022vaultId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022daiAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogDraw\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022vaultId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022daiAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogWipe\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"InstaMcdSave","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://978b7c08e6a03b5f9a80dbd7e529de3876406cfb5ae84cc73e2b936825da9d5d"}]