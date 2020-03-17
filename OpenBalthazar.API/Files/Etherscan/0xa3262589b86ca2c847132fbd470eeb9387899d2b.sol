[{"SourceCode":"pragma solidity 0.5.11; // optimization runs: 200, evm version: petersburg\r\n\r\n\r\ninterface CTokenInterface {\r\n  function exchangeRateCurrent() external returns (uint256 exchangeRate);\r\n}\r\n\r\n\r\ninterface ERC20Interface {\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n}\r\n\r\n\r\n/**\r\n * @title DharmaUSDCInitializer\r\n * @author 0age\r\n * @notice Initializer for the Dharma USD Coin token.\r\n */\r\ncontract DharmaUSDCInitializer {\r\n  event Accrue(uint256 dTokenExchangeRate, uint256 cTokenExchangeRate);\r\n\r\n  // The block number and cToken \u002B dToken exchange rates are updated on accrual.\r\n  struct AccrualIndex {\r\n    uint112 dTokenExchangeRate;\r\n    uint112 cTokenExchangeRate;\r\n    uint32 block;\r\n  }\r\n\r\n  CTokenInterface internal constant _CUSDC = CTokenInterface(\r\n    0x39AA39c021dfbaE8faC545936693aC917d5E7563 // mainnet\r\n  );\r\n\r\n  ERC20Interface internal constant _USDC = ERC20Interface(\r\n    0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 // mainnet\r\n  );\r\n\r\n  uint256 internal constant _MAX_UINT_112 = 5192296858534827628530496329220095;\r\n\r\n  // Set block number and dToken \u002B cToken exchange rate in slot zero on accrual.\r\n  AccrualIndex private _accrualIndex;\r\n\r\n  /**\r\n   * @notice Initialize Dharma USD Coin by approving cUSDC to transfer USDC on\r\n   * behalf of this contract and setting the initial dUSDC and cUSDC exchange\r\n   * rates in storage.\r\n   */\r\n  function initialize() public {\r\n    // Approve cToken to transfer underlying for this contract in order to mint.\r\n    require(\r\n      _USDC.approve(address(_CUSDC), uint256(-1)),\r\n      \u0022Initial cUSDC approval failed.\u0022\r\n    );\r\n\r\n    // Initial dToken exchange rate is 1-to-1 (dTokens have 8 decimals).\r\n    uint256 dTokenExchangeRate = 1e16;\r\n\r\n    // Accrue cToken interest and retrieve the current cToken exchange rate.\r\n    uint256 cTokenExchangeRate = _CUSDC.exchangeRateCurrent();\r\n\r\n    // Initialize accrual index with current block number and exchange rates.\r\n    AccrualIndex storage accrualIndex = _accrualIndex;\r\n    accrualIndex.dTokenExchangeRate = uint112(dTokenExchangeRate);\r\n    accrualIndex.cTokenExchangeRate = _safeUint112(cTokenExchangeRate);\r\n    accrualIndex.block = uint32(block.number);\r\n    emit Accrue(dTokenExchangeRate, cTokenExchangeRate);\r\n  }\r\n\r\n  /**\r\n   * @notice Internal pure function to convert a uint256 to a uint112, reverting\r\n   * if the conversion would cause an overflow.\r\n   * @param input uint256 The unsigned integer to convert.\r\n   * @return The converted unsigned integer.\r\n   */\r\n  function _safeUint112(uint256 input) internal pure returns (uint112 output) {\r\n    require(input \u003C= _MAX_UINT_112, \u0022Overflow on conversion to uint112.\u0022);\r\n    output = uint112(input);\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022initialize\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022dTokenExchangeRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cTokenExchangeRate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Accrue\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"DharmaUSDCInitializer","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://fe26874cd075b61209640411033c5656f49f21cd3b820cda3069b337fa8468c8"}]