[{"SourceCode":"pragma solidity 0.5.12;\r\n\r\n\r\ninterface CTokenInterface {\r\n  function supplyRatePerBlock() external view returns (uint256 rate);\r\n  function exchangeRateStored() external view returns (uint256 rate);\r\n  function accrualBlockNumber() external view returns (uint256 blockNumber);\r\n}\r\n\r\n\r\nlibrary SafeMath {\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n    return c;\r\n  }\r\n\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    require(b \u003C= a, \u0022SafeMath: subtraction overflow\u0022);\r\n    uint256 c = a - b;\r\n\r\n    return c;\r\n  }\r\n\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n\r\n    uint256 c = a * b;\r\n    require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n    return c;\r\n  }\r\n}\r\n\r\n\r\ncontract CUSDCExchangeRateView {\r\n  using SafeMath for uint256;    \r\n    \r\n  uint256 internal constant _SCALING_FACTOR = 1e18;\r\n\r\n  CTokenInterface internal constant _CUSDC = CTokenInterface(\r\n    0x39AA39c021dfbaE8faC545936693aC917d5E7563 // mainnet\r\n  );   \r\n    \r\n  /**\r\n   * @notice Internal view function to get the current cUSDC exchange rate.\r\n   * @return The current cUSDC exchange rate, or amount of USDC that is redeemable\r\n   * for each cUSDC (with 18 decimal places added to the returned exchange rate).\r\n   */\r\n  function getCurrentExchangeRate() external view returns (uint256 exchangeRate) {\r\n    uint256 storedExchangeRate = _CUSDC.exchangeRateStored();\r\n    uint256 blockDelta = block.number.sub(_CUSDC.accrualBlockNumber());\r\n\r\n    if (blockDelta == 0) return storedExchangeRate;\r\n\r\n    exchangeRate = blockDelta == 0 ? storedExchangeRate : storedExchangeRate.add(\r\n      storedExchangeRate.mul(\r\n        _CUSDC.supplyRatePerBlock().mul(blockDelta)\r\n      ) / _SCALING_FACTOR\r\n    );\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCurrentExchangeRate\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022exchangeRate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"CUSDCExchangeRateView","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://8aa8a097c8d729e713a83855630d5d74719fd7c05d512281cbcd6d23c1bb277c"}]