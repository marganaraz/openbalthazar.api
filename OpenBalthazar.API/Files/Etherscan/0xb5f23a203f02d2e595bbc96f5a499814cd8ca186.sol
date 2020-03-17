[{"SourceCode":"pragma solidity 0.5.11;\r\n\r\n\r\ninterface ERC20Interface {\r\n  function balanceOf(address) external view returns (uint256);\r\n  function approve(address, uint256) external returns (bool);\r\n  function transfer(address, uint256) external returns (bool);\r\n  function transferFrom(address, address, uint256) external returns (bool);\r\n}\r\n\r\n\r\ninterface DTokenInterface {\r\n  function mint(uint256 underlyingToSupply) external returns (uint256 dTokensMinted);\r\n  function redeemUnderlying(uint256 underlyingToReceive) external returns (uint256 dTokensBurned);\r\n  function balanceOfUnderlying(address) external view returns (uint256);\r\n  function transfer(address, uint256) external returns (bool);\r\n  function transferUnderlyingFrom(\r\n    address sender, address recipient, uint256 underlyingEquivalentAmount\r\n  ) external returns (bool success);\r\n}\r\n\r\n\r\ninterface CurveInterface {\r\n  function exchange_underlying(int128, int128, uint256, uint256, uint256) external;\r\n  function get_dy_underlying(int128, int128, uint256) external view returns (uint256);\r\n}\r\n\r\n\r\nlibrary SafeMath {\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        require(b \u003C= a, \u0022SafeMath: subtraction overflow\u0022);\r\n        c = a - b;\r\n    }\r\n\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        if (a == 0) return 0;\r\n        c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        require(b \u003E 0, \u0022SafeMath: division by zero\u0022);\r\n        c = a / b;\r\n    }\r\n}\r\n\r\n\r\ncontract CurveReserveTradeHelperV1 {\r\n  using SafeMath for uint256;\r\n \r\n  DTokenInterface internal constant _DDAI = DTokenInterface(\r\n    0x00000000001876eB1444c986fD502e618c587430\r\n  );\r\n  \r\n  ERC20Interface internal constant _DAI = ERC20Interface(\r\n    0x6B175474E89094C44Da98b954EedeAC495271d0F\r\n  );\r\n\r\n  ERC20Interface internal constant _USDC = ERC20Interface(\r\n    0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48\r\n  );\r\n \r\n  CurveInterface internal constant _CURVE = CurveInterface(\r\n    0x2e60CF74d81ac34eB21eEff58Db4D385920ef419\r\n  );\r\n  \r\n  uint256 internal constant _SCALING_FACTOR = 1e18;\r\n  \r\n  constructor() public {\r\n    require(_USDC.approve(address(_CURVE), uint256(-1)));\r\n    require(_DAI.approve(address(_CURVE), uint256(-1)));\r\n    require(_DAI.approve(address(_DDAI), uint256(-1)));\r\n  }\r\n  \r\n  /// @param quotedExchangeRate uint256 The expected USDC/DAI exchange\r\n  /// rate, scaled up by 10^18 - this value is returned from the\r\n  /// \u0060getExchangeRateAndExpectedDai\u0060 view function as \u0060exchangeRate\u0060.\r\n  function tradeUSDCForDDai(\r\n    uint256 usdcAmount, uint256 quotedExchangeRate\r\n  ) external returns (uint256 dTokensMinted) {\r\n    // Ensure caller has sufficient USDC balance.\r\n    require(\r\n      _USDC.balanceOf(msg.sender) \u003E= usdcAmount,\r\n      \u0022Insufficient USDC balance.\u0022\r\n    );\r\n    \r\n    // Use that balance and quoted exchange rate to derive required Dai.\r\n    uint256 minimumDai = _getMinimumDai(usdcAmount, quotedExchangeRate);\r\n    \r\n    // Transfer USDC from the caller to this contract (requires approval).\r\n    require(_USDC.transferFrom(msg.sender, address(this), usdcAmount));\r\n    \r\n    // Exchange USDC for Dai using Curve.\r\n    _CURVE.exchange_underlying(\r\n      1, 0, usdcAmount, minimumDai, now \u002B 1\r\n    );\r\n    \r\n    // Get the received Dai and ensure it meets the requirement.\r\n    uint256 daiBalance = _DAI.balanceOf(address(this));\r\n    require(\r\n      daiBalance \u003E= minimumDai,\r\n      \u0022Realized exchange rate differs from quoted rate by over 1%.\u0022\r\n    );\r\n    \r\n    // mint Dharma Dai using the received Dai.\r\n    dTokensMinted = _DDAI.mint(daiBalance);\r\n    \r\n    // Transfer the dDai to the caller.\r\n    require(_DDAI.transfer(msg.sender, dTokensMinted));\r\n  }\r\n  \r\n  /// @param quotedExchangeRate uint256 The expected USDC/DAI exchange\r\n  /// rate, scaled up by 10^18 - this value is returned from the\r\n  /// \u0060getExchangeRateAndExpectedUSDC\u0060 view function as \u0060exchangeRate\u0060.\r\n  function tradeDDaiForUSDC(\r\n    uint256 daiEquivalentAmount, uint256 quotedExchangeRate\r\n  ) external returns (uint256 dTokensRedeemed) {\r\n    // Ensure caller has sufficient dDai balance.\r\n    require(\r\n      _DDAI.balanceOfUnderlying(msg.sender) \u003E= daiEquivalentAmount,\r\n      \u0022Insufficient Dharma Dai balance.\u0022\r\n    );\r\n    \r\n    // Transfer dDai from the caller to this contract (requires approval).\r\n    bool transferFromOK = _DDAI.transferUnderlyingFrom(\r\n      msg.sender, address(this), daiEquivalentAmount\r\n    );\r\n    require(transferFromOK, \u0022Dharma Dai transferFrom failed.\u0022);\r\n    \r\n    // Redeem dDai for Dai.\r\n    dTokensRedeemed = _DDAI.redeemUnderlying(daiEquivalentAmount);\r\n\r\n    // Use Dai equivalent balance and quoted rate to derive required USDC.\r\n    uint256 minimumUSDC = _getMinimumUSDC(\r\n      daiEquivalentAmount, quotedExchangeRate\r\n    );\r\n    \r\n    // Exchange Dai for USDC using Curve.\r\n    _CURVE.exchange_underlying(\r\n      0, 1, daiEquivalentAmount, minimumUSDC, now \u002B 1\r\n    );\r\n    \r\n    // Get the received USDC and ensure it meets the requirement.\r\n    uint256 usdcBalance = _USDC.balanceOf(address(this));\r\n    require(\r\n      usdcBalance \u003E= minimumUSDC,\r\n      \u0022Realized exchange rate differs from quoted rate by over 1%.\u0022\r\n    );\r\n    \r\n    // Transfer the USDC to the caller.\r\n    require(_USDC.transfer(msg.sender, usdcBalance));\r\n  }\r\n\r\n  function getExchangeRateAndExpectedDai(uint256 usdc) external view returns (\r\n    uint256 exchangeRate,\r\n    uint256 dai\r\n  ) {\r\n    if (usdc == 0) {\r\n      return (0, 0);\r\n    }\r\n\r\n    dai = _CURVE.get_dy_underlying(1, 0, usdc);\r\n    if (dai == 0) {\r\n      exchangeRate = 0;\r\n    } else {\r\n      exchangeRate = (usdc.mul(_SCALING_FACTOR)).div(dai);\r\n    }\r\n  }\r\n\r\n  function getExchangeRateAndExpectedUSDC(uint256 dai) external view returns (\r\n    uint256 exchangeRate,\r\n    uint256 usdc\r\n  ) {\r\n    if (dai == 0) {\r\n      return (0, 0);\r\n    }\r\n\r\n    usdc = _CURVE.get_dy_underlying(0, 1, dai);\r\n    if (usdc == 0) {\r\n      exchangeRate = 0;\r\n    } else {\r\n      exchangeRate = (dai.mul(_SCALING_FACTOR)).div(usdc);\r\n    }\r\n  }\r\n\r\n  function _getMinimumDai(uint256 usdc, uint256 quotedExchangeRate) internal pure returns (\r\n    uint256 minimumDai\r\n  ) {\r\n    uint256 quotedDai = (usdc.mul(quotedExchangeRate)).div(_SCALING_FACTOR);\r\n    minimumDai = (quotedDai.mul(99)).div(100);\r\n  }\r\n\r\n  function _getMinimumUSDC(uint256 dai, uint256 quotedExchangeRate) internal pure returns (\r\n    uint256 minimumUSDC\r\n  ) {\r\n    uint256 quotedUSDC = (dai.mul(quotedExchangeRate)).div(_SCALING_FACTOR);\r\n    minimumUSDC = (quotedUSDC.mul(99)).div(100);\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022usdcAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022quotedExchangeRate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022tradeUSDCForDDai\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022dTokensMinted\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022dai\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getExchangeRateAndExpectedUSDC\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022exchangeRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022usdc\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022usdc\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getExchangeRateAndExpectedDai\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022exchangeRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022dai\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022daiEquivalentAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022quotedExchangeRate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022tradeDDaiForUSDC\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022dTokensRedeemed\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"CurveReserveTradeHelperV1","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://2b5be1c162f50f6508f067768d24530efd64c3313af8b931b82ddd77394351f3"}]