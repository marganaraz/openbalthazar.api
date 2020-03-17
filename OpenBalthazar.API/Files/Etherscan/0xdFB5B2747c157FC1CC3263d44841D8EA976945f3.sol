[{"SourceCode":"/**\r\n * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.\r\n * Licensed under the Apache License, Version 2.0.\r\n */\r\n\r\npragma solidity 0.5.16;\r\n\r\n\r\nlibrary SafeMath {\r\n\r\n  /**\r\n  * @dev Multiplies two numbers, throws on overflow.\r\n  */\r\n  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {\r\n    // Gas optimization: this is cheaper than asserting \u0027a\u0027 not being zero, but the\r\n    // benefit is lost if \u0027b\u0027 is also tested.\r\n    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n    if (_a == 0) {\r\n      return 0;\r\n    }\r\n\r\n    c = _a * _b;\r\n    assert(c / _a == _b);\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Integer division of two numbers, truncating the quotient.\r\n  */\r\n  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n    // assert(_b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    // uint256 c = _a / _b;\r\n    // assert(_a == _b * c \u002B _a % _b); // There is no case in which this doesn\u0027t hold\r\n    return _a / _b;\r\n  }\r\n\r\n  /**\r\n  * @dev Integer division of two numbers, rounding up and truncating the quotient\r\n  */\r\n  function divCeil(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n    if (_a == 0) {\r\n      return 0;\r\n    }\r\n\r\n    return ((_a - 1) / _b) \u002B 1;\r\n  }\r\n\r\n  /**\r\n  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n  */\r\n  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n    assert(_b \u003C= _a);\r\n    return _a - _b;\r\n  }\r\n\r\n  /**\r\n  * @dev Adds two numbers, throws on overflow.\r\n  */\r\n  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {\r\n    c = _a \u002B _b;\r\n    assert(c \u003E= _a);\r\n    return c;\r\n  }\r\n}\r\n\r\ncontract Ownable {\r\n  address public owner;\r\n\r\n\r\n  event OwnershipTransferred(\r\n    address indexed previousOwner,\r\n    address indexed newOwner\r\n  );\r\n\r\n\r\n  /**\r\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n   * account.\r\n   */\r\n  constructor() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n   * @param _newOwner The address to transfer ownership to.\r\n   */\r\n  function transferOwnership(address _newOwner) public onlyOwner {\r\n    _transferOwnership(_newOwner);\r\n  }\r\n\r\n  /**\r\n   * @dev Transfers control of the contract to a newOwner.\r\n   * @param _newOwner The address to transfer ownership to.\r\n   */\r\n  function _transferOwnership(address _newOwner) internal {\r\n    require(_newOwner != address(0));\r\n    emit OwnershipTransferred(owner, _newOwner);\r\n    owner = _newOwner;\r\n  }\r\n}\r\n\r\ncontract ERC20Basic {\r\n  function totalSupply() public view returns (uint256);\r\n  function balanceOf(address _who) public view returns (uint256);\r\n  function transfer(address _to, uint256 _value) public returns (bool);\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n\r\ncontract ERC20 is ERC20Basic {\r\n  function allowance(address _owner, address _spender)\r\n    public view returns (uint256);\r\n\r\n  function transferFrom(address _from, address _to, uint256 _value)\r\n    public returns (bool);\r\n\r\n  function approve(address _spender, uint256 _value) public returns (bool);\r\n  event Approval(\r\n    address indexed owner,\r\n    address indexed spender,\r\n    uint256 value\r\n  );\r\n}\r\n\r\ncontract ZeroXConnectorLogic is Ownable {\r\n    using SafeMath for uint256;\r\n\r\n    address internal target_;\r\n\r\n    address public constant vaultContract = 0x8B3d70d628Ebd30D4A2ea82DB95bA2e906c71633;\r\n    address public constant ZeroXExchange = 0x61935CbDd02287B511119DDb11Aeb42F1593b7Ef;\r\n    address public constant ZeroXProxy = 0x95E6F48254609A6ee006F7D493c8e5fB97094ceF;\r\n\r\n    address internal constant feeWallet = 0x13ddAC8d492E463073934E2a101e419481970299;\r\n\r\n    constructor() public {}\r\n\r\n    function() external {}\r\n\r\n\r\n    function trade(\r\n        ERC20 sourceToken,\r\n        ERC20 destToken,\r\n        address receiver,\r\n        uint256 sourceTokenAmount,\r\n        uint256 destTokenAmount,\r\n        bytes calldata loanDataBytes)\r\n        external\r\n        payable\r\n        returns (uint256 destTokenAmountReceived, uint256 sourceTokenAmountUsed)\r\n    {\r\n        require(msg.value != 0, \u0022no ether sent\u0022);\r\n        require(sourceToken != destToken, \u0022no same-token swap\u0022);\r\n\r\n        uint256 beforeSourceBalance = sourceToken.balanceOf(address(this));\r\n        uint256 beforeDestBalance = destToken.balanceOf(address(this));\r\n        uint256 beforeEtherBalance = address(this).balance.sub(msg.value);\r\n\r\n        require(sourceTokenAmount \u003E= beforeSourceBalance, \u0022not enough token sent\u0022);\r\n\r\n        address affiliateWallet = _handle0xSwap(\r\n            sourceToken,\r\n            sourceTokenAmount,\r\n            destTokenAmount,\r\n            loanDataBytes\r\n        );\r\n\r\n        (destTokenAmountReceived, sourceTokenAmountUsed) = _settleBalances(\r\n            sourceToken,\r\n            destToken,\r\n            sourceTokenAmount,\r\n            destTokenAmount,\r\n            beforeSourceBalance,\r\n            beforeDestBalance,\r\n            affiliateWallet\r\n        );\r\n\r\n        // ether (msg.value)\r\n        uint256 afterEtherBalance = address(this).balance;\r\n        if (afterEtherBalance \u003E beforeEtherBalance) {\r\n            (bool success,) = receiver.call.value(afterEtherBalance - beforeEtherBalance)(\u0022\u0022);\r\n            require(success, \u0022eth refund failed\u0022);\r\n        }\r\n    }\r\n\r\n    function _handle0xSwap(\r\n        ERC20 sourceToken,\r\n        uint256 sourceTokenAmount,\r\n        uint256 destTokenAmount,\r\n        bytes memory loanDataBytes)\r\n        internal\r\n        returns (address)\r\n    {\r\n        bool isBuyOrder = destTokenAmount != 0;\r\n        address affiliateWallet;\r\n        uint256 protocolFee;\r\n        (affiliateWallet, protocolFee, loanDataBytes) = _process0xData(\r\n            isBuyOrder,\r\n            loanDataBytes\r\n        );\r\n\r\n        uint256 tmpAmount;\r\n        if (!isBuyOrder) {\r\n            uint256 platformFee = _handleFees(\r\n                sourceToken,\r\n                sourceTokenAmount,\r\n                affiliateWallet\r\n            );\r\n\r\n            if (platformFee != 0) {\r\n                sourceTokenAmount = sourceTokenAmount\r\n                    .sub(platformFee);\r\n            }\r\n        }\r\n\r\n        assembly {\r\n            // replace target amount if needed\r\n            tmpAmount := mload(add(loanDataBytes, 68))\r\n\r\n            switch isBuyOrder\r\n            case 0 { // false\r\n                if gt(tmpAmount, sourceTokenAmount) {\r\n                    mstore(add(loanDataBytes, 68), sourceTokenAmount)\r\n                }\r\n            }\r\n            default { // true\r\n                if gt(tmpAmount, destTokenAmount) {\r\n                    mstore(add(loanDataBytes, 68), destTokenAmount)\r\n                }\r\n            }\r\n        }\r\n        require(\r\n            (isBuyOrder \u0026\u0026 tmpAmount \u003E= destTokenAmount) ||\r\n            (!isBuyOrder \u0026\u0026 tmpAmount \u003E= sourceTokenAmount),\r\n            \u00220x swap too small\u0022\r\n        );\r\n\r\n\r\n        tmpAmount = sourceToken.allowance(address(this), ZeroXProxy); // reclaim slot\r\n        if (tmpAmount \u003C sourceTokenAmount) {\r\n            if (tmpAmount != 0) {\r\n                // reset approval to 0 (some tokens enforce this)\r\n                sourceToken.approve(ZeroXProxy, 0);\r\n            }\r\n\r\n            sourceToken.approve(ZeroXProxy, uint256(-1));\r\n        }\r\n\r\n        (bool success,) = address(ZeroXExchange).call.value(protocolFee)(loanDataBytes);\r\n        require(success, \u00220x swap failed\u0022);\r\n\r\n        return affiliateWallet;\r\n    }\r\n\r\n   function _settleBalances(\r\n        ERC20 sourceToken,\r\n        ERC20 destToken,\r\n        uint256 sourceTokenAmount,\r\n        uint256 destTokenAmount,\r\n        uint256 beforeSourceBalance,\r\n        uint256 beforeDestBalance,\r\n        address affiliateWallet)\r\n        internal\r\n        returns (uint256 destTokenAmountReceived, uint256 sourceTokenAmountUsed)\r\n    {\r\n        bool success;\r\n\r\n        // sourceToken\r\n        uint256 afterSourceBalance = sourceToken.balanceOf(address(this));\r\n        success = afterSourceBalance \u003C beforeSourceBalance;\r\n        if (success) {\r\n            sourceTokenAmountUsed = beforeSourceBalance - afterSourceBalance;\r\n            if (sourceTokenAmount \u003E sourceTokenAmountUsed) {\r\n                uint256 sourceTokenRefund = sourceTokenAmount - sourceTokenAmountUsed;\r\n                success = sourceTokenRefund == 0 || sourceToken.transfer(\r\n                    vaultContract,\r\n                    sourceTokenRefund\r\n                );\r\n            }\r\n        }\r\n        require(success, \u00220x swap failed for Source\u0022);\r\n\r\n        // destToken\r\n        uint256 afterDestBalance = destToken.balanceOf(address(this));\r\n        success = afterDestBalance \u003E beforeDestBalance;\r\n        if (success) {\r\n            destTokenAmountReceived = afterDestBalance - beforeDestBalance;\r\n\r\n            if (destTokenAmount != 0) { // isBuyOrder == true\r\n                uint256 platformFee = _handleFees(\r\n                    destToken,\r\n                    destTokenAmountReceived,\r\n                    affiliateWallet\r\n                );\r\n\r\n                if (platformFee != 0) {\r\n                    destTokenAmountReceived = destTokenAmountReceived\r\n                        .sub(platformFee);\r\n                }\r\n            }\r\n\r\n            success = destTokenAmountReceived == 0 || destToken.transfer(\r\n                vaultContract,\r\n                destTokenAmountReceived\r\n            );\r\n        }\r\n        success = success \u0026\u0026 (destTokenAmount == 0 || destTokenAmountReceived \u003E= destTokenAmountReceived);\r\n        require(success, \u00220x swap failed for Dest\u0022);\r\n    }\r\n\r\n    function _process0xData(\r\n        bool isBuyOrder,\r\n        bytes memory loanDataBytes)\r\n        internal\r\n        returns (address, uint256, bytes memory)\r\n    {\r\n        uint256 dataLength = loanDataBytes.length;\r\n        require(dataLength \u003E 96, \u00220x data invalid\u0022);\r\n\r\n        bytes4 sig;\r\n        address affiliateWallet;\r\n        uint256 protocolFee;\r\n        assembly {\r\n            // get function sig\r\n            sig := mload(add(loanDataBytes, 32))\r\n\r\n            // get affiliateWallet\r\n            affiliateWallet := mload(add(loanDataBytes, dataLength))\r\n\r\n            // get protocolFee\r\n            protocolFee := mload(add(loanDataBytes, sub(dataLength, 32)))\r\n\r\n            // remove affiliateWallet, protocolFee, and offchainRate from end of data\r\n            mstore(loanDataBytes, sub(dataLength, 64))\r\n        }\r\n\r\n        // 0x78d29ac1: marketBuyOrdersNoThrow\r\n        // 0x8bc8efb3: marketBuyOrdersFillOrKill\r\n        // 0xa6c3bf33: marketSellOrdersFillOrKill\r\n        require(\r\n            (isBuyOrder \u0026\u0026 (sig == 0x8bc8efb3 || sig == 0x78d29ac1)) ||\r\n            (!isBuyOrder \u0026\u0026 sig == 0xa6c3bf33),\r\n            \u00220x sig invalid\u0022\r\n        );\r\n\r\n        require(msg.value != 0 \u0026\u0026 msg.value \u003E= protocolFee, \u0022insufficient ether\u0022);\r\n\r\n        return (affiliateWallet, protocolFee, loanDataBytes);\r\n    }\r\n\r\n    function _handleFees(\r\n        ERC20 feeToken,\r\n        uint256 feeTokenAmount,\r\n        address affiliateWallet)\r\n        internal\r\n        returns (uint256)\r\n    {\r\n        uint256 totalPlatformFee = feeTokenAmount\r\n            .mul(25 * 10**16)\r\n            .div(10**20); // 0.25% fee\r\n\r\n        uint256 platformFee = totalPlatformFee;\r\n\r\n        bool success = true;\r\n        if (affiliateWallet != address(0) \u0026\u0026 _checkWhitelist(affiliateWallet)) {\r\n            uint256 affiliateFee = platformFee.mul(30 * 10**18).div(10**20); // 30% fee share\r\n            if (affiliateFee != 0) {\r\n                platformFee = platformFee.sub(affiliateFee);\r\n                success = feeToken.transfer(\r\n                    affiliateWallet,\r\n                    affiliateFee\r\n                );\r\n            }\r\n        }\r\n\r\n        if (success \u0026\u0026 platformFee != 0) {\r\n            success = feeToken.transfer(\r\n                feeWallet,\r\n                platformFee\r\n            );\r\n        }\r\n        require (success, \u00220x transfer failed\u0022);\r\n\r\n        return totalPlatformFee;\r\n    }\r\n\r\n    function _checkWhitelist(\r\n        address affiliateWallet)\r\n        internal\r\n        view\r\n        returns (bool isWhitelisted)\r\n    {\r\n        // keccak256(\u0022AffiliateWhitelist\u0022)\r\n        bytes32 slot = keccak256(abi.encodePacked(affiliateWallet, uint256(0xcda2fc7eaefa672733be021532baa62a86147ef9434c91b60aa179578a939d72)));\r\n        assembly {\r\n            isWhitelisted := sload(slot)\r\n        }\r\n    }\r\n\r\n    function affiliateWhitelist(\r\n        address affiliateWallet,\r\n        bool enabled)\r\n        public\r\n        onlyOwner\r\n    {\r\n        // keccak256(\u0022AffiliateWhitelist\u0022)\r\n        bytes32 slot = keccak256(abi.encodePacked(affiliateWallet, uint256(0xcda2fc7eaefa672733be021532baa62a86147ef9434c91b60aa179578a939d72)));\r\n        assembly {\r\n            sstore(slot, enabled)\r\n        }\r\n    }\r\n\r\n    function recoverEther(\r\n        address receiver,\r\n        uint256 amount)\r\n        public\r\n        onlyOwner\r\n    {\r\n        uint256 balance = address(this).balance;\r\n        if (balance \u003C amount)\r\n            amount = balance;\r\n\r\n        (bool success,) = receiver.call.value(amount)(\u0022\u0022);\r\n        require(success,\r\n            \u0022transfer failed\u0022\r\n        );\r\n    }\r\n\r\n    function recoverToken(\r\n        address tokenAddress,\r\n        address receiver,\r\n        uint256 amount)\r\n        public\r\n        onlyOwner\r\n    {\r\n        ERC20 token = ERC20(tokenAddress);\r\n\r\n        uint256 balance = token.balanceOf(address(this));\r\n        if (balance \u003C amount)\r\n            amount = balance;\r\n\r\n        require(token.transfer(\r\n            receiver,\r\n            amount),\r\n            \u0022transfer failed\u0022\r\n        );\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ZeroXExchange\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ZeroXProxy\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022affiliateWallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022enabled\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022affiliateWhitelist\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022recoverEther\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022recoverToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract ERC20\u0022,\u0022name\u0022:\u0022sourceToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022contract ERC20\u0022,\u0022name\u0022:\u0022destToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022sourceTokenAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022destTokenAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022loanDataBytes\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022trade\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022destTokenAmountReceived\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022sourceTokenAmountUsed\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022vaultContract\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"ZeroXConnectorLogic","CompilerVersion":"v0.5.16\u002Bcommit.9c3226ce","OptimizationUsed":"1","Runs":"1000000","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://901b7a430fdd0061e761807c966b50b9d12fb7bd8b1fd8c5ad65c77b3bdf61e5"}]