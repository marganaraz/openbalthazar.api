[{"SourceCode":"pragma solidity ^0.5.8;\r\npragma experimental ABIEncoderV2;\r\n\r\ninterface ERC20Interface {\r\n    function allowance(address, address) external view returns (uint);\r\n    function balanceOf(address) external view returns (uint);\r\n    function approve(address, uint) external;\r\n    function transfer(address, uint) external returns (bool);\r\n    function transferFrom(address, address, uint) external returns (bool);\r\n    function deposit() external payable;\r\n    function withdraw(uint) external;\r\n}\r\n\r\n\r\ncontract SoloMarginContract {\r\n\r\n    struct Info {\r\n        address owner;  // The address that owns the account\r\n        uint256 number; // A nonce that allows a single address to control many accounts\r\n    }\r\n\r\n    enum ActionType {\r\n        Deposit,   // supply tokens\r\n        Withdraw,  // supply tokens\r\n        Transfer,  // transfer balance between accounts\r\n        Buy,       // buy an amount of some token (externally)\r\n        Sell,      // sell an amount of some token (externally)\r\n        Trade,     // trade tokens against another account\r\n        Liquidate, // liquidate an undercollateralized or expiring account\r\n        Vaporize,  // use excess tokens to zero-out a completely negative account\r\n        Call       // send arbitrary data to an address\r\n    }\r\n\r\n    enum AssetDenomination {\r\n        Wei, // the amount is denominated in wei\r\n        Par  // the amount is denominated in par\r\n    }\r\n\r\n    enum AssetReference {\r\n        Delta, // the amount is given as a delta from the current value\r\n        Target // the amount is given as an exact number to end up at\r\n    }\r\n\r\n    struct AssetAmount {\r\n        bool sign; // true if positive\r\n        AssetDenomination denomination;\r\n        AssetReference ref;\r\n        uint256 value;\r\n    }\r\n\r\n    struct ActionArgs {\r\n        ActionType actionType;\r\n        uint256 accountId;\r\n        AssetAmount amount;\r\n        uint256 primaryMarketId;\r\n        uint256 secondaryMarketId;\r\n        address otherAddress;\r\n        uint256 otherAccountId;\r\n        bytes data;\r\n    }\r\n\r\n    struct Wei {\r\n        bool sign; // true if positive\r\n        uint256 value;\r\n    }\r\n\r\n    function operate(Info[] memory accounts, ActionArgs[] memory actions) public;\r\n    function getAccountWei(Info memory account, uint256 marketId) public view returns (Wei memory);\r\n    function getNumMarkets() public view returns (uint256);\r\n    function getMarketTokenAddress(uint256 marketI) public view returns (address);\r\n}\r\n\r\ninterface PoolInterface {\r\n    function accessToken(address[] calldata ctknAddr, uint[] calldata tknAmt, bool isCompound) external;\r\n    function paybackToken(address[] calldata ctknAddr, bool isCompound) external payable;\r\n}\r\n\r\n\r\ncontract DSMath {\r\n\r\n    function add(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x \u002B y) \u003E= x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    function sub(uint x, uint y) internal pure returns (uint z) {\r\n        z = x - y \u003C= x ? x - y : 0;\r\n    }\r\n\r\n    function mul(uint x, uint y) internal pure returns (uint z) {\r\n        require(y == 0 || (z = x * y) / y == x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    uint constant WAD = 10 ** 18;\r\n\r\n    function wmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), WAD / 2) / WAD;\r\n    }\r\n\r\n    function wdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, WAD), y / 2) / y;\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract Helpers is DSMath {\r\n\r\n    /**\r\n     * @dev get ethereum address\r\n     */\r\n    function getAddressETH() public pure returns (address eth) {\r\n        eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\r\n    }\r\n\r\n        /**\r\n     * @dev get WETH address\r\n     */\r\n    function getAddressWETH() public pure returns (address weth) {\r\n        weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;\r\n    }\r\n\r\n    /**\r\n     * @dev get Dydx Solo Address\r\n     */\r\n    function getSoloAddress() public pure returns (address addr) {\r\n        addr = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;\r\n    }\r\n\r\n    /**\r\n     * @dev get InstaDApp Liquidity Address\r\n     */\r\n    function getPoolAddress() public pure returns (address payable liqAddr) {\r\n        liqAddr = 0x1564D040EC290C743F67F5cB11f3C1958B39872A;\r\n    }\r\n\r\n    /**\r\n     * @dev setting allowance to dydx for the \u0022user proxy\u0022 if required\r\n     */\r\n    function setApproval(address erc20, uint srcAmt, address to) internal {\r\n        ERC20Interface erc20Contract = ERC20Interface(erc20);\r\n        uint tokenAllowance = erc20Contract.allowance(address(this), to);\r\n        if (srcAmt \u003E tokenAllowance) {\r\n            erc20Contract.approve(to, uint(-1));\r\n        }\r\n    }\r\n\r\n    /**\r\n    * @dev getting actions arg\r\n    */\r\n    function getActionsArgs(\r\n        address tknAccount,\r\n        uint accountIndex,\r\n        uint256 marketId,\r\n        uint256 tokenAmt,\r\n        bool sign\r\n    ) internal pure returns (SoloMarginContract.ActionArgs[] memory)\r\n    {\r\n        SoloMarginContract.ActionArgs[] memory actions = new SoloMarginContract.ActionArgs[](1);\r\n        SoloMarginContract.AssetAmount memory amount = SoloMarginContract.AssetAmount(\r\n            sign,\r\n            SoloMarginContract.AssetDenomination.Wei,\r\n            SoloMarginContract.AssetReference.Delta,\r\n            tokenAmt\r\n        );\r\n        bytes memory empty;\r\n        // address otherAddr = (marketId == 0 \u0026\u0026 sign) ? getSoloPayableAddress() : address(this);\r\n        SoloMarginContract.ActionType action = sign ? SoloMarginContract.ActionType.Deposit : SoloMarginContract.ActionType.Withdraw;\r\n        actions[0] = SoloMarginContract.ActionArgs(\r\n            action,\r\n            accountIndex,\r\n            amount,\r\n            marketId,\r\n            0,\r\n            tknAccount,\r\n            0,\r\n            empty\r\n        );\r\n        return actions;\r\n    }\r\n\r\n    /**\r\n    * @dev getting acccount arg\r\n    */\r\n    function getAccountArgs(address owner, uint accountId) internal pure returns (SoloMarginContract.Info[] memory) {\r\n        SoloMarginContract.Info[] memory accounts = new SoloMarginContract.Info[](1);\r\n        accounts[0] = (SoloMarginContract.Info(owner, accountId));\r\n        return accounts;\r\n    }\r\n\r\n    /**\r\n     * @dev getting dydx balance\r\n     */\r\n    function getDydxBal(address owner, uint256 marketId, uint accountId) internal view returns (uint tokenBal, bool tokenSign) {\r\n        SoloMarginContract solo = SoloMarginContract(getSoloAddress());\r\n        SoloMarginContract.Wei memory tokenWeiBal = solo.getAccountWei(getAccountArgs(owner, accountId)[0], marketId);\r\n        tokenBal = tokenWeiBal.value;\r\n        tokenSign = tokenWeiBal.sign;\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract ImportHelper is Helpers {\r\n    struct BorrowData {\r\n        uint[] borrowAmt;\r\n        address[] borrowAddr;\r\n        uint[] marketId;\r\n        uint borrowCount;\r\n    }\r\n\r\n    struct SupplyData {\r\n        uint[] supplyAmt;\r\n        address[] supplyAddr;\r\n        uint[] marketId;\r\n        uint supplyCount;\r\n    }\r\n\r\n    function getTokensData(uint accountId, uint toConvert) public returns(SupplyData memory, BorrowData memory) {\r\n        SoloMarginContract solo = SoloMarginContract(getSoloAddress());\r\n        uint markets = solo.getNumMarkets();\r\n        SupplyData memory supplyDataArr;\r\n        supplyDataArr.supplyAmt = new uint[](markets);\r\n        supplyDataArr.marketId = new uint[](markets);\r\n        supplyDataArr.supplyAddr = new address[](markets);\r\n        BorrowData memory borrowDataArr;\r\n        borrowDataArr.borrowAmt = new uint[](markets);\r\n        borrowDataArr.marketId = new uint[](markets);\r\n        borrowDataArr.borrowAddr = new address[](markets);\r\n        uint borrowCount = 0;\r\n        uint supplyCount = 0;\r\n\r\n        for (uint i = 0; i \u003C markets; i\u002B\u002B) {\r\n            (uint tokenbal, bool tokenSign) = getDydxBal(msg.sender, i, accountId);\r\n            if (tokenbal \u003E 0) {\r\n                if (tokenSign) {\r\n                    supplyDataArr.supplyAmt[supplyCount] = wmul(tokenbal, toConvert);\r\n                    supplyDataArr.supplyAddr[supplyCount] = solo.getMarketTokenAddress(i);\r\n                    supplyDataArr.marketId[supplyCount] = i;\r\n                    supplyCount\u002B\u002B;\r\n                } else {\r\n                    borrowDataArr.borrowAmt[borrowCount] = wmul(tokenbal, toConvert);\r\n                    borrowDataArr.borrowAddr[borrowCount] = solo.getMarketTokenAddress(i);\r\n                    borrowDataArr.marketId[borrowCount] = i;\r\n                    borrowCount\u002B\u002B;\r\n                }\r\n                setApproval(solo.getMarketTokenAddress(i), uint(-1), getSoloAddress());\r\n            }\r\n        }\r\n        borrowDataArr.borrowCount = borrowCount;\r\n        supplyDataArr.supplyCount = supplyCount;\r\n        return (supplyDataArr, borrowDataArr);\r\n    }\r\n\r\n    function getOperatorActionsArgs(SupplyData memory suppyArr, BorrowData memory borrowArr) public view\r\n    returns(SoloMarginContract.ActionArgs[] memory)\r\n    {\r\n        uint borrowCount = borrowArr.borrowCount;\r\n        uint supplyCount = suppyArr.supplyCount;\r\n        uint totalCount = borrowCount \u002B supplyCount;\r\n        SoloMarginContract.ActionArgs[] memory actions = new SoloMarginContract.ActionArgs[](totalCount*2);\r\n\r\n        for (uint i = 0; i \u003C borrowCount; i\u002B\u002B) {\r\n            actions[i] = getActionsArgs(\r\n                address(this),\r\n                0,\r\n                borrowArr.marketId[i],\r\n                borrowArr.borrowAmt[i],\r\n                true\r\n            )[0];\r\n            actions[i \u002B totalCount \u002B supplyCount] = getActionsArgs(\r\n                getPoolAddress(), // After borrowing transfer directly to InstaDApp\u0027s Pool.\r\n                1,\r\n                borrowArr.marketId[i],\r\n                borrowArr.borrowAmt[i],\r\n                false\r\n            )[0];\r\n        }\r\n\r\n        for (uint i = 0; i \u003C supplyCount; i\u002B\u002B) {\r\n            uint baseIndex = borrowCount \u002B i;\r\n            actions[baseIndex] = getActionsArgs(\r\n                address(this),\r\n                0,\r\n                suppyArr.marketId[i],\r\n                suppyArr.supplyAmt[i],\r\n                false\r\n            )[0];\r\n            actions[baseIndex \u002B supplyCount] = getActionsArgs(\r\n                address(this),\r\n                1,\r\n                suppyArr.marketId[i],\r\n                suppyArr.supplyAmt[i],\r\n                true\r\n            )[0];\r\n        }\r\n        return (actions);\r\n    }\r\n\r\n    function getOperatorAccountArgs(uint accountId) public view returns (SoloMarginContract.Info[] memory) {\r\n        SoloMarginContract.Info[] memory accounts = new SoloMarginContract.Info[](2);\r\n        accounts[0] = getAccountArgs(msg.sender, accountId)[0];\r\n        accounts[1] = getAccountArgs(address(this), 0)[0];\r\n        return accounts;\r\n    }\r\n}\r\n\r\n\r\ncontract ImportResolver is  ImportHelper {\r\n    event LogDydxImport(address owner, uint accountId, uint percentage, bool isCompound, SupplyData supplyData, BorrowData borrowData);\r\n\r\n    function importAssets(\r\n        uint toConvert,\r\n        uint accountId,\r\n        bool isCompound\r\n    ) external\r\n    {\r\n        // subtracting 0.00000001 ETH from initialPoolBal to solve Compound 8 decimal CETH error.\r\n        uint initialPoolBal = sub(getPoolAddress().balance, 10000000000);\r\n        (SupplyData memory supplyArr, BorrowData memory borrowArr) = getTokensData(accountId, toConvert);\r\n\r\n        // Get liquidity assets to payback user wallet borrowed assets\r\n        if (borrowArr.borrowCount \u003E 0) {\r\n            PoolInterface(getPoolAddress()).accessToken(borrowArr.borrowAddr, borrowArr.borrowAmt, isCompound);\r\n        }\r\n\r\n        // Creating actions args for solo operate\r\n        SoloMarginContract.ActionArgs[] memory actions = getOperatorActionsArgs(supplyArr, borrowArr);\r\n        SoloMarginContract.Info[] memory accounts = getOperatorAccountArgs(accountId);\r\n\r\n        // Import Assests from msg.sender to address(this)\r\n        SoloMarginContract solo = SoloMarginContract(getSoloAddress());\r\n        solo.operate(accounts, actions);\r\n\r\n        //payback InstaDApp liquidity\r\n        if (borrowArr.borrowCount \u003E 0) {\r\n            PoolInterface(getPoolAddress()).paybackToken(borrowArr.borrowAddr, isCompound);\r\n        }\r\n\r\n        uint finalPoolBal = getPoolAddress().balance;\r\n        assert(finalPoolBal \u003E= initialPoolBal);\r\n\r\n        emit LogDydxImport(\r\n            msg.sender,\r\n            accountId,\r\n            toConvert,\r\n            isCompound,\r\n            supplyArr,\r\n            borrowArr\r\n        );\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract InstaDydxImport is ImportResolver {\r\n    function() external payable {}\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAddressWETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022weth\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022accountId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022toConvert\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getTokensData\u0022,\u0022outputs\u0022:[{\u0022components\u0022:[{\u0022name\u0022:\u0022supplyAmt\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022supplyAddr\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022marketId\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022supplyCount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022tuple\u0022},{\u0022components\u0022:[{\u0022name\u0022:\u0022borrowAmt\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022borrowAddr\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022marketId\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022borrowCount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022tuple\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022accountId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getOperatorAccountArgs\u0022,\u0022outputs\u0022:[{\u0022components\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022number\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022tuple[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022toConvert\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022accountId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022isCompound\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022importAssets\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getSoloAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022components\u0022:[{\u0022name\u0022:\u0022supplyAmt\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022supplyAddr\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022marketId\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022supplyCount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022suppyArr\u0022,\u0022type\u0022:\u0022tuple\u0022},{\u0022components\u0022:[{\u0022name\u0022:\u0022borrowAmt\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022borrowAddr\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022marketId\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022borrowCount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022borrowArr\u0022,\u0022type\u0022:\u0022tuple\u0022}],\u0022name\u0022:\u0022getOperatorActionsArgs\u0022,\u0022outputs\u0022:[{\u0022components\u0022:[{\u0022name\u0022:\u0022actionType\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022accountId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022components\u0022:[{\u0022name\u0022:\u0022sign\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022denomination\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022ref\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022tuple\u0022},{\u0022name\u0022:\u0022primaryMarketId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022secondaryMarketId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022otherAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022otherAccountId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022tuple[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAddressETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022eth\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getPoolAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022liqAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022accountId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022percentage\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022isCompound\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022components\u0022:[{\u0022name\u0022:\u0022supplyAmt\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022supplyAddr\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022marketId\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022supplyCount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022indexed\u0022:false,\u0022name\u0022:\u0022supplyData\u0022,\u0022type\u0022:\u0022tuple\u0022},{\u0022components\u0022:[{\u0022name\u0022:\u0022borrowAmt\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022borrowAddr\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022marketId\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022borrowCount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022indexed\u0022:false,\u0022name\u0022:\u0022borrowData\u0022,\u0022type\u0022:\u0022tuple\u0022}],\u0022name\u0022:\u0022LogDydxImport\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"InstaDydxImport","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://18fde59e2bfe736bcb85e59e27f98035e2dad015347721ae39023a4b3dca1f13"}]