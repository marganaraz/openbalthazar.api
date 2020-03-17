[{"SourceCode":"pragma solidity ^0.5.8;\r\npragma experimental ABIEncoderV2;\r\n\r\ninterface ERC20Interface {\r\n    function allowance(address, address) external view returns (uint);\r\n    function balanceOf(address) external view returns (uint);\r\n    function approve(address, uint) external;\r\n    function transfer(address, uint) external returns (bool);\r\n    function transferFrom(address, address, uint) external returns (bool);\r\n    function deposit() external payable;\r\n    function withdraw(uint) external;\r\n}\r\n\r\n\r\ncontract SoloMarginContract {\r\n\r\n    struct Info {\r\n        address owner;  // The address that owns the account\r\n        uint256 number; // A nonce that allows a single address to control many accounts\r\n    }\r\n\r\n    enum ActionType {\r\n        Deposit,   // supply tokens\r\n        Withdraw,  // borrow tokens\r\n        Transfer,  // transfer balance between accounts\r\n        Buy,       // buy an amount of some token (externally)\r\n        Sell,      // sell an amount of some token (externally)\r\n        Trade,     // trade tokens against another account\r\n        Liquidate, // liquidate an undercollateralized or expiring account\r\n        Vaporize,  // use excess tokens to zero-out a completely negative account\r\n        Call       // send arbitrary data to an address\r\n    }\r\n\r\n    enum AssetDenomination {\r\n        Wei, // the amount is denominated in wei\r\n        Par  // the amount is denominated in par\r\n    }\r\n\r\n    enum AssetReference {\r\n        Delta, // the amount is given as a delta from the current value\r\n        Target // the amount is given as an exact number to end up at\r\n    }\r\n\r\n    struct AssetAmount {\r\n        bool sign; // true if positive\r\n        AssetDenomination denomination;\r\n        AssetReference ref;\r\n        uint256 value;\r\n    }\r\n\r\n    struct ActionArgs {\r\n        ActionType actionType;\r\n        uint256 accountId;\r\n        AssetAmount amount;\r\n        uint256 primaryMarketId;\r\n        uint256 secondaryMarketId;\r\n        address otherAddress;\r\n        uint256 otherAccountId;\r\n        bytes data;\r\n    }\r\n\r\n    struct Wei {\r\n        bool sign; // true if positive\r\n        uint256 value;\r\n    }\r\n\r\n    function operate(Info[] memory accounts, ActionArgs[] memory actions) public;\r\n    function getAccountWei(Info memory account, uint256 marketId) public returns (Wei memory);\r\n\r\n}\r\n\r\n\r\ncontract DSMath {\r\n\r\n    function add(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x \u002B y) \u003E= x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    function mul(uint x, uint y) internal pure returns (uint z) {\r\n        require(y == 0 || (z = x * y) / y == x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    uint constant WAD = 10 ** 18;\r\n\r\n    function wmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), WAD / 2) / WAD;\r\n    }\r\n\r\n    function wdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, WAD), y / 2) / y;\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract Helpers is DSMath {\r\n\r\n    /**\r\n     * @dev get ethereum address\r\n     */\r\n    function getAddressETH() public pure returns (address eth) {\r\n        eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\r\n    }\r\n\r\n        /**\r\n     * @dev get WETH address\r\n     */\r\n    function getAddressWETH() public pure returns (address weth) {\r\n        weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;\r\n    }\r\n\r\n    /**\r\n     * @dev get Dydx Solo Address\r\n     */\r\n    function getSoloAddress() public pure returns (address addr) {\r\n        addr = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;\r\n    }\r\n\r\n    /**\r\n     * @dev setting allowance to dydx for the \u0022user proxy\u0022 if required\r\n     */\r\n    function setApproval(address erc20, uint srcAmt, address to) internal {\r\n        ERC20Interface erc20Contract = ERC20Interface(erc20);\r\n        uint tokenAllowance = erc20Contract.allowance(address(this), to);\r\n        if (srcAmt \u003E tokenAllowance) {\r\n            erc20Contract.approve(to, uint(-1));\r\n        }\r\n    }\r\n\r\n    /**\r\n    * @dev getting actions arg\r\n    */\r\n    function getActionsArgs(uint256 marketId, uint256 tokenAmt, bool sign) internal view returns (SoloMarginContract.ActionArgs[] memory) {\r\n        SoloMarginContract.ActionArgs[] memory actions = new SoloMarginContract.ActionArgs[](1);\r\n        SoloMarginContract.AssetAmount memory amount = SoloMarginContract.AssetAmount(\r\n            sign,\r\n            SoloMarginContract.AssetDenomination.Wei,\r\n            SoloMarginContract.AssetReference.Delta,\r\n            tokenAmt\r\n        );\r\n        bytes memory empty;\r\n        SoloMarginContract.ActionType action = sign ? SoloMarginContract.ActionType.Deposit : SoloMarginContract.ActionType.Withdraw;\r\n        actions[0] = SoloMarginContract.ActionArgs(\r\n            action,\r\n            0,\r\n            amount,\r\n            marketId,\r\n            0,\r\n            address(this),\r\n            0,\r\n            empty\r\n        );\r\n        return actions;\r\n    }\r\n\r\n    /**\r\n    * @dev getting acccount arg\r\n    */\r\n    function getAccountArgs() internal view returns (SoloMarginContract.Info[] memory) {\r\n        SoloMarginContract.Info[] memory accounts = new SoloMarginContract.Info[](1);\r\n        accounts[0] = (SoloMarginContract.Info(msg.sender, 0));\r\n        return accounts;\r\n    }\r\n\r\n    /**\r\n     * @dev getting dydx balance\r\n     */\r\n    function getDydxBal(uint256 marketId) internal returns (uint tokenBal, bool tokenSign) {\r\n        SoloMarginContract solo = SoloMarginContract(getSoloAddress());\r\n        SoloMarginContract.Wei memory tokenWeiBal = solo.getAccountWei(getAccountArgs()[0], marketId);\r\n        tokenBal = tokenWeiBal.value;\r\n        tokenSign = tokenWeiBal.sign;\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract DydxResolver is Helpers {\r\n\r\n    event LogDeposit(address erc20Addr, uint tokenAmt, address owner);\r\n    event LogWithdraw(address erc20Addr, uint tokenAmt, address owner);\r\n    event LogBorrow(address erc20Addr, uint tokenAmt, address owner);\r\n    event LogPayback(address erc20Addr, uint tokenAmt, address owner);\r\n\r\n    /**\r\n     * @dev Deposit ETH/ERC20\r\n     */\r\n    function deposit(uint256 marketId, address erc20Addr, uint256 tokenAmt) public payable {\r\n        if (erc20Addr == getAddressETH()) {\r\n            ERC20Interface(getAddressWETH()).deposit.value(msg.value)();\r\n            setApproval(getAddressWETH(), tokenAmt, getSoloAddress());\r\n        } else {\r\n            require(ERC20Interface(erc20Addr).transferFrom(msg.sender, address(this), tokenAmt), \u0022Allowance or not enough bal\u0022);\r\n            setApproval(erc20Addr, tokenAmt, getSoloAddress());\r\n        }\r\n        SoloMarginContract(getSoloAddress()).operate(getAccountArgs(), getActionsArgs(marketId, tokenAmt, true));\r\n        emit LogDeposit(erc20Addr, tokenAmt, address(this));\r\n    }\r\n\r\n    /**\r\n     * @dev Payback ETH/ERC20\r\n     */\r\n    function payback(uint256 marketId, address erc20Addr, uint256 tokenAmt) public payable {\r\n        (uint toPayback, bool tokenSign) = getDydxBal(marketId);\r\n        require(!tokenSign, \u0022No debt to payback\u0022);\r\n        toPayback = toPayback \u003E tokenAmt ? tokenAmt : toPayback;\r\n        if (erc20Addr == getAddressETH()) {\r\n            ERC20Interface(getAddressWETH()).deposit.value(toPayback)();\r\n            setApproval(getAddressWETH(), toPayback, getSoloAddress());\r\n            msg.sender.transfer(address(this).balance);\r\n        } else {\r\n            require(ERC20Interface(erc20Addr).transferFrom(msg.sender, address(this), toPayback), \u0022Allowance or not enough bal\u0022);\r\n            setApproval(erc20Addr, toPayback, getSoloAddress());\r\n        }\r\n        SoloMarginContract(getSoloAddress()).operate(getAccountArgs(), getActionsArgs(marketId, toPayback, true));\r\n        emit LogPayback(erc20Addr, toPayback, address(this));\r\n    }\r\n\r\n    /**\r\n     * @dev Withdraw ETH/ERC20\r\n     */\r\n    function withdraw(uint256 marketId, address erc20Addr, uint256 tokenAmt) public {\r\n        (uint toWithdraw, bool tokenSign) = getDydxBal(marketId);\r\n        require(tokenSign, \u0022token not deposited\u0022);\r\n        toWithdraw = toWithdraw \u003E tokenAmt ? tokenAmt : toWithdraw;\r\n        SoloMarginContract solo = SoloMarginContract(getSoloAddress());\r\n        solo.operate(getAccountArgs(), getActionsArgs(marketId, toWithdraw, false));\r\n        if (erc20Addr == getAddressETH()) {\r\n            ERC20Interface wethContract = ERC20Interface(getAddressWETH());\r\n            uint wethBal = wethContract.balanceOf(address(this));\r\n            toWithdraw = toWithdraw \u003C wethBal ? wethBal : toWithdraw;\r\n            setApproval(getAddressWETH(), toWithdraw, getAddressWETH());\r\n            ERC20Interface(getAddressWETH()).withdraw(toWithdraw);\r\n            msg.sender.transfer(toWithdraw);\r\n        } else {\r\n            require(ERC20Interface(erc20Addr).transfer(msg.sender, toWithdraw), \u0022Allowance or not enough bal\u0022);\r\n        }\r\n        emit LogWithdraw(erc20Addr, toWithdraw, address(this));\r\n    }\r\n\r\n    /**\r\n    * @dev Borrow ETH/ERC20\r\n    */\r\n    function borrow(uint256 marketId, address erc20Addr, uint256 tokenAmt) public {\r\n        SoloMarginContract(getSoloAddress()).operate(getAccountArgs(), getActionsArgs(marketId, tokenAmt, false));\r\n        if (erc20Addr == getAddressETH()) {\r\n            setApproval(getAddressWETH(), tokenAmt, getAddressWETH());\r\n            ERC20Interface(getAddressWETH()).withdraw(tokenAmt);\r\n            msg.sender.transfer(tokenAmt);\r\n        } else {\r\n            require(ERC20Interface(erc20Addr).transfer(msg.sender, tokenAmt), \u0022Allowance or not enough bal\u0022);\r\n        }\r\n        emit LogBorrow(erc20Addr, tokenAmt, address(this));\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract InstaDydx is DydxResolver {\r\n    function() external payable {}\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022marketId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022erc20Addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokenAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022borrow\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAddressWETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022weth\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022marketId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022erc20Addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokenAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022payback\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getSoloAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAddressETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022eth\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022marketId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022erc20Addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokenAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022deposit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022marketId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022erc20Addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokenAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022erc20Addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokenAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogDeposit\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022erc20Addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokenAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogWithdraw\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022erc20Addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokenAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogBorrow\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022erc20Addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokenAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogPayback\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"InstaDydx","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://8f9ed23438c552186a82180ad3fb1a647f8d3bd19e3e533774b14707eceaf28b"}]