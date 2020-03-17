[{"SourceCode":"pragma solidity 0.5.11; // optimization runs: 200\r\n\r\n\r\ninterface CTokenInterface {\r\n  function balanceOf(address) external view returns (uint256);\r\n  function approve(address, uint256) external returns (bool);\r\n  function transfer(address, uint256) external returns (bool);\r\n  function transferFrom(address, address, uint256) external returns (bool);\r\n  function exchangeRateStored() external view returns (uint256);\r\n}\r\n\r\n\r\ninterface DTokenInterface {\r\n  function mintViaCToken(uint256 cTokensToSupply) external returns (uint256 dTokensMinted);\r\n  function redeemToCToken(uint256 dTokensToBurn) external returns (uint256 cTokensReceived);\r\n  function balanceOf(address) external view returns (uint256);\r\n  function approve(address, uint256) external returns (bool);\r\n  function transfer(address, uint256) external returns (bool);\r\n  function transferFrom(address, address, uint256) external returns (bool);\r\n}\r\n\r\n\r\ninterface CurveInterface {\r\n  function exchange(int128, int128, uint256, uint256, uint256) external;\r\n  function get_dy(int128, int128, uint256) external view returns (uint256);\r\n}\r\n\r\n\r\nlibrary SafeMath {\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        require(b \u003C= a, \u0022SafeMath: subtraction overflow\u0022);\r\n        c = a - b;\r\n    }\r\n\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        if (a == 0) return 0;\r\n        c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        require(b \u003E 0, \u0022SafeMath: division by zero\u0022);\r\n        c = a / b;\r\n    }\r\n}\r\n\r\n\r\ncontract CurveTradeHelperV1 {\r\n  using SafeMath for uint256;\r\n\r\n  CTokenInterface internal constant _CDAI = CTokenInterface(\r\n    0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643\r\n  );\r\n  \r\n  CTokenInterface internal constant _CUSDC = CTokenInterface(\r\n    0x39AA39c021dfbaE8faC545936693aC917d5E7563\r\n  );\r\n \r\n  DTokenInterface internal constant _DDAI = DTokenInterface(\r\n    0x00000000001876eB1444c986fD502e618c587430\r\n  );\r\n  \r\n  DTokenInterface internal constant _DUSDC = DTokenInterface(\r\n    0x00000000008943c65cAf789FFFCF953bE156f6f8\r\n  );\r\n  \r\n  CurveInterface internal constant _CURVE = CurveInterface(\r\n    0x2e60CF74d81ac34eB21eEff58Db4D385920ef419\r\n  );\r\n  \r\n  uint256 internal constant _SCALING_FACTOR = 1e18;\r\n  \r\n  constructor() public {\r\n    require(_CUSDC.approve(address(_CURVE), uint256(-1)));\r\n  }\r\n  \r\n  /// @param quotedExchangeRate uint256 The expected cUSDC/cDAI exchange\r\n  /// rate, scaled up by 10^18 - this value is returned from the\r\n  /// \u0060getExchangeRateAndExpectedDai\u0060 view function as \u0060exchangeRate\u0060.\r\n  function tradeCUSDCForCDai(uint256 quotedExchangeRate) external {\r\n    // Get the total cUSDC balance of the caller.\r\n    uint256 cUSDCBalance = _CUSDC.balanceOf(msg.sender);\r\n    require(cUSDCBalance \u003E 5000000, \u0022cUSDC balance too low to trade.\u0022);\r\n    \r\n    // Use that balance and quoted exchange rate to derive required cDai.\r\n    uint256 minimumCDai = _getMinimumCDai(cUSDCBalance, quotedExchangeRate);\r\n    \r\n    // Transfer all cUSDC from the caller to this contract (requires approval).\r\n    require(_CUSDC.transferFrom(msg.sender, address(this), cUSDCBalance));\r\n    \r\n    // Exchange cUSDC for cDai using Curve.\r\n    _CURVE.exchange(1, 0, cUSDCBalance, minimumCDai, now \u002B 1);\r\n    \r\n    // Get the received cDai and ensure it meets the requirement.\r\n    uint256 cDaiBalance = _CDAI.balanceOf(address(this));\r\n    require(\r\n      cDaiBalance \u003E= minimumCDai,\r\n      \u0022Realized exchange rate differs from quoted rate by over 1%.\u0022\r\n    );\r\n    \r\n    // Transfer the cDai to the caller.\r\n    require(_CDAI.transfer(msg.sender, cDaiBalance));\r\n  }\r\n\r\n  function tradeCUSDCForCDaiAtAnyRate() external {\r\n    // Get the total cUSDC balance of the caller.\r\n    uint256 cUSDCBalance = _CUSDC.balanceOf(msg.sender);\r\n    require(cUSDCBalance \u003E 5000000, \u0022cUSDC balance too low to trade.\u0022);\r\n    \r\n    // Transfer all cUSDC from the caller to this contract (requires approval).\r\n    require(_CUSDC.transferFrom(msg.sender, address(this), cUSDCBalance));\r\n    \r\n    // Exchange cUSDC for any amount of cDai using Curve.\r\n    _CURVE.exchange(1, 0, cUSDCBalance, 0, now \u002B 1);\r\n    \r\n    // Get the received cDai and transfer it to the caller.\r\n    require(_CDAI.transfer(msg.sender, _CDAI.balanceOf(address(this))));\r\n  }\r\n  \r\n  /// @param quotedExchangeRate uint256 The expected cUSDC/cDAI exchange\r\n  /// rate, scaled up by 10^18 - this value is returned from the\r\n  /// \u0060getExchangeRateAndExpectedDai\u0060 view function as \u0060exchangeRate\u0060.\r\n  function tradeDUSDCForDDai(uint256 quotedExchangeRate) external {\r\n    // Get the total dUSDC balance of the caller.\r\n    uint256 dUSDCBalance = _DUSDC.balanceOf(msg.sender);\r\n    require(dUSDCBalance \u003E 100000, \u0022dUSDC balance too low to trade.\u0022);\r\n    \r\n    // Transfer all dUSDC from the caller to this contract (requires approval).\r\n    require(_DUSDC.transferFrom(msg.sender, address(this), dUSDCBalance));\r\n\r\n    // Redeem dUSDC for cUSDC.\r\n    uint256 cUSDCBalance = _DUSDC.redeemToCToken(dUSDCBalance);\r\n    \r\n    // Use cUSDC balance and quoted exchange rate to derive required cDai.\r\n    uint256 minimumCDai = _getMinimumCDai(cUSDCBalance, quotedExchangeRate);\r\n    \r\n    // Exchange cUSDC for cDai using Curve.\r\n    _CURVE.exchange(1, 0, cUSDCBalance, minimumCDai, now \u002B 1);\r\n    \r\n    // Get the received cDai and ensure it meets the requirement.\r\n    uint256 cDaiBalance = _CDAI.balanceOf(address(this));\r\n    require(\r\n      cDaiBalance \u003E= minimumCDai,\r\n      \u0022Realized exchange rate differs from quoted rate by over 1%.\u0022\r\n    );\r\n    \r\n    // Mint dDai using the received cDai.\r\n    uint256 dDaiBalance = _DUSDC.mintViaCToken(_CDAI.balanceOf(address(this)));\r\n    \r\n    // Transfer the received dDai to the caller.\r\n    require(_DDAI.transfer(msg.sender, dDaiBalance));\r\n  }\r\n\r\n  function tradeDUSDCForDDaiAtAnyRate() external {\r\n    // Get the total dUSDC balance of the caller.\r\n    uint256 dUSDCBalance = _DUSDC.balanceOf(msg.sender);\r\n    require(dUSDCBalance \u003E 100000, \u0022dUSDC balance too low to trade.\u0022);\r\n    \r\n    // Transfer all dUSDC from the caller to this contract (requires approval).\r\n    require(_DUSDC.transferFrom(msg.sender, address(this), dUSDCBalance));\r\n    \r\n    // Redeem dUSDC for cUSDC.\r\n    uint256 cUSDCBalance = _DUSDC.redeemToCToken(dUSDCBalance);\r\n    \r\n    // Exchange cUSDC for any amount of cDai using Curve.\r\n    _CURVE.exchange(1, 0, cUSDCBalance, 0, now \u002B 1);\r\n    \r\n    // Mint dDai using the received cDai.\r\n    uint256 dDaiBalance = _DUSDC.mintViaCToken(_CDAI.balanceOf(address(this)));\r\n    \r\n    // Transfer the received dDai to the caller.\r\n    require(_DDAI.transfer(msg.sender, dDaiBalance));\r\n  }\r\n\r\n  function getExchangeRateAndExpectedDai(uint256 usdc) external view returns (\r\n    uint256 exchangeRate,\r\n    uint256 exchangeRateUnderlying,\r\n    uint256 dai\r\n  ) {\r\n    if (usdc == 0) {\r\n      return (0, 0, 0);\r\n    }\r\n\r\n    uint256 cUSDCEquivalent = (\r\n      usdc.mul(_SCALING_FACTOR)\r\n    ).div(_CUSDC.exchangeRateStored());\r\n    \r\n    uint256 cDaiEquivalent;\r\n    (exchangeRate, cDaiEquivalent) = _getExchangeRateAndExpectedCDai(\r\n      cUSDCEquivalent\r\n    );\r\n    \r\n    dai = (\r\n      cDaiEquivalent.mul(_CDAI.exchangeRateStored())\r\n    ).div(_SCALING_FACTOR);\r\n    \r\n    // Account for decimals and scale up 1e18 to get USDC/Dai rate\r\n    exchangeRateUnderlying = (dai.mul(1e6)).div(usdc);\r\n  }\r\n\r\n  function _getExchangeRateAndExpectedCDai(uint256 cUSDC) internal view returns (\r\n    uint256 exchangeRate,\r\n    uint256 cDai\r\n) {\r\n    cDai = _CURVE.get_dy(1, 0, cUSDC);\r\n    if (cDai == 0) {\r\n      exchangeRate = 0;\r\n    } else {\r\n      exchangeRate = (cUSDC.mul(_SCALING_FACTOR)).div(cDai);\r\n    }\r\n  }\r\n\r\n  function _getMinimumCDai(uint256 cUSDC, uint256 quotedExchangeRate) internal pure returns (\r\n    uint256 minimumCDai\r\n) {\r\n    uint256 quotedCDai = (cUSDC.mul(quotedExchangeRate)).div(_SCALING_FACTOR);\r\n    minimumCDai = (quotedCDai.mul(99)).div(100);\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tradeCUSDCForCDaiAtAnyRate\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022quotedExchangeRate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022tradeCUSDCForCDai\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022quotedExchangeRate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022tradeDUSDCForDDai\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tradeDUSDCForDDaiAtAnyRate\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022usdc\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getExchangeRateAndExpectedDai\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022exchangeRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022exchangeRateUnderlying\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022dai\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"CurveTradeHelperV1","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://f5a71bbcff3457f5481032b0ee1da796dfe86658b5a6844c87b819d40beedefe"}]