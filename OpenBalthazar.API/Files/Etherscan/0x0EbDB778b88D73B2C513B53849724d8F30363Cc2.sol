[{"SourceCode":"// File: @aragon/court/contracts/lib/os/IsContract.sol\r\n\r\n// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/IsContract.sol\r\n// Adapted to use pragma ^0.5.8 and satisfy our linter rules\r\n\r\npragma solidity ^0.5.8;\r\n\r\n\r\ncontract IsContract {\r\n    /*\r\n    * NOTE: this should NEVER be used for authentication\r\n    * (see pitfalls: https://github.com/fergarrui/ethereum-security/tree/master/contracts/extcodesize).\r\n    *\r\n    * This is only intended to be used as a sanity check that an address is actually a contract,\r\n    * RATHER THAN an address not being a contract.\r\n    */\r\n    function isContract(address _target) internal view returns (bool) {\r\n        if (_target == address(0)) {\r\n            return false;\r\n        }\r\n\r\n        uint256 size;\r\n        assembly { size := extcodesize(_target) }\r\n        return size \u003E 0;\r\n    }\r\n}\r\n\r\n// File: @aragon/court/contracts/lib/os/ERC20.sol\r\n\r\n// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/lib/token/ERC20.sol\r\n// Adapted to use pragma ^0.5.8 and satisfy our linter rules\r\n\r\npragma solidity ^0.5.8;\r\n\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ncontract ERC20 {\r\n    function totalSupply() public view returns (uint256);\r\n\r\n    function balanceOf(address _who) public view returns (uint256);\r\n\r\n    function allowance(address _owner, address _spender) public view returns (uint256);\r\n\r\n    function transfer(address _to, uint256 _value) public returns (bool);\r\n\r\n    function approve(address _spender, uint256 _value) public returns (bool);\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);\r\n\r\n    event Transfer(\r\n        address indexed from,\r\n        address indexed to,\r\n        uint256 value\r\n    );\r\n\r\n    event Approval(\r\n        address indexed owner,\r\n        address indexed spender,\r\n        uint256 value\r\n    );\r\n}\r\n\r\n// File: @aragon/court/contracts/lib/os/SafeERC20.sol\r\n\r\n// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/SafeERC20.sol\r\n// Adapted to use pragma ^0.5.8 and satisfy our linter rules\r\n\r\npragma solidity ^0.5.8;\r\n\r\n\r\n\r\nlibrary SafeERC20 {\r\n    // Before 0.5, solidity has a mismatch between \u0060address.transfer()\u0060 and \u0060token.transfer()\u0060:\r\n    // https://github.com/ethereum/solidity/issues/3544\r\n    bytes4 private constant TRANSFER_SELECTOR = 0xa9059cbb;\r\n\r\n    /**\r\n    * @dev Same as a standards-compliant ERC20.transfer() that never reverts (returns false).\r\n    *      Note that this makes an external call to the token.\r\n    */\r\n    function safeTransfer(ERC20 _token, address _to, uint256 _amount) internal returns (bool) {\r\n        bytes memory transferCallData = abi.encodeWithSelector(\r\n            TRANSFER_SELECTOR,\r\n            _to,\r\n            _amount\r\n        );\r\n        return invokeAndCheckSuccess(address(_token), transferCallData);\r\n    }\r\n\r\n    /**\r\n    * @dev Same as a standards-compliant ERC20.transferFrom() that never reverts (returns false).\r\n    *      Note that this makes an external call to the token.\r\n    */\r\n    function safeTransferFrom(ERC20 _token, address _from, address _to, uint256 _amount) internal returns (bool) {\r\n        bytes memory transferFromCallData = abi.encodeWithSelector(\r\n            _token.transferFrom.selector,\r\n            _from,\r\n            _to,\r\n            _amount\r\n        );\r\n        return invokeAndCheckSuccess(address(_token), transferFromCallData);\r\n    }\r\n\r\n    /**\r\n    * @dev Same as a standards-compliant ERC20.approve() that never reverts (returns false).\r\n    *      Note that this makes an external call to the token.\r\n    */\r\n    function safeApprove(ERC20 _token, address _spender, uint256 _amount) internal returns (bool) {\r\n        bytes memory approveCallData = abi.encodeWithSelector(\r\n            _token.approve.selector,\r\n            _spender,\r\n            _amount\r\n        );\r\n        return invokeAndCheckSuccess(address(_token), approveCallData);\r\n    }\r\n\r\n    function invokeAndCheckSuccess(address _addr, bytes memory _calldata) private returns (bool) {\r\n        bool ret;\r\n        assembly {\r\n            let ptr := mload(0x40)    // free memory pointer\r\n\r\n            let success := call(\r\n                gas,                  // forward all gas\r\n                _addr,                // address\r\n                0,                    // no value\r\n                add(_calldata, 0x20), // calldata start\r\n                mload(_calldata),     // calldata length\r\n                ptr,                  // write output over free memory\r\n                0x20                  // uint256 return\r\n            )\r\n\r\n            if gt(success, 0) {\r\n            // Check number of bytes returned from last function call\r\n                switch returndatasize\r\n\r\n                // No bytes returned: assume success\r\n                case 0 {\r\n                    ret := 1\r\n                }\r\n\r\n                // 32 bytes returned: check if non-zero\r\n                case 0x20 {\r\n                // Only return success if returned data was true\r\n                // Already have output in ptr\r\n                    ret := eq(mload(ptr), 1)\r\n                }\r\n\r\n                // Not sure what was returned: don\u0027t mark as success\r\n                default { }\r\n            }\r\n        }\r\n        return ret;\r\n    }\r\n}\r\n\r\n// File: @aragon/court/contracts/standards/ERC900.sol\r\n\r\npragma solidity ^0.5.8;\r\n\r\n\r\n// Interface for ERC900: https://eips.ethereum.org/EIPS/eip-900\r\ninterface ERC900 {\r\n    event Staked(address indexed user, uint256 amount, uint256 total, bytes data);\r\n    event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);\r\n\r\n    /**\r\n    * @dev Stake a certain amount of tokens\r\n    * @param _amount Amount of tokens to be staked\r\n    * @param _data Optional data that can be used to add signalling information in more complex staking applications\r\n    */\r\n    function stake(uint256 _amount, bytes calldata _data) external;\r\n\r\n    /**\r\n    * @dev Stake a certain amount of tokens in favor of someone\r\n    * @param _user Address to stake an amount of tokens to\r\n    * @param _amount Amount of tokens to be staked\r\n    * @param _data Optional data that can be used to add signalling information in more complex staking applications\r\n    */\r\n    function stakeFor(address _user, uint256 _amount, bytes calldata _data) external;\r\n\r\n    /**\r\n    * @dev Unstake a certain amount of tokens\r\n    * @param _amount Amount of tokens to be unstaked\r\n    * @param _data Optional data that can be used to add signalling information in more complex staking applications\r\n    */\r\n    function unstake(uint256 _amount, bytes calldata _data) external;\r\n\r\n    /**\r\n    * @dev Tell the total amount of tokens staked for an address\r\n    * @param _addr Address querying the total amount of tokens staked for\r\n    * @return Total amount of tokens staked for an address\r\n    */\r\n    function totalStakedFor(address _addr) external view returns (uint256);\r\n\r\n    /**\r\n    * @dev Tell the total amount of tokens staked\r\n    * @return Total amount of tokens staked\r\n    */\r\n    function totalStaked() external view returns (uint256);\r\n\r\n    /**\r\n    * @dev Tell the address of the token used for staking\r\n    * @return Address of the token used for staking\r\n    */\r\n    function token() external view returns (address);\r\n\r\n    /*\r\n    * @dev Tell if the current registry supports historic information or not\r\n    * @return True if the optional history functions are implemented, false otherwise\r\n    */\r\n    function supportsHistory() external pure returns (bool);\r\n}\r\n\r\n// File: contracts/lib/uniswap/interfaces/IUniswapExchange.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\ninterface IUniswapExchange {\r\n  event TokenPurchase(address indexed buyer, uint256 indexed eth_sold, uint256 indexed tokens_bought);\r\n  event EthPurchase(address indexed buyer, uint256 indexed tokens_sold, uint256 indexed eth_bought);\r\n  event AddLiquidity(address indexed provider, uint256 indexed eth_amount, uint256 indexed token_amount);\r\n  event RemoveLiquidity(address indexed provider, uint256 indexed eth_amount, uint256 indexed token_amount);\r\n\r\n   /**\r\n   * @notice Convert ETH to Tokens.\r\n   * @dev User specifies exact input (msg.value).\r\n   * @dev User cannot specify minimum output or deadline.\r\n   */\r\n  function () external payable;\r\n\r\n /**\r\n   * @dev Pricing function for converting between ETH \u0026\u0026 Tokens.\r\n   * @param input_amount Amount of ETH or Tokens being sold.\r\n   * @param input_reserve Amount of ETH or Tokens (input type) in exchange reserves.\r\n   * @param output_reserve Amount of ETH or Tokens (output type) in exchange reserves.\r\n   * @return Amount of ETH or Tokens bought.\r\n   */\r\n  function getInputPrice(uint256 input_amount, uint256 input_reserve, uint256 output_reserve) external view returns (uint256);\r\n\r\n /**\r\n   * @dev Pricing function for converting between ETH \u0026\u0026 Tokens.\r\n   * @param output_amount Amount of ETH or Tokens being bought.\r\n   * @param input_reserve Amount of ETH or Tokens (input type) in exchange reserves.\r\n   * @param output_reserve Amount of ETH or Tokens (output type) in exchange reserves.\r\n   * @return Amount of ETH or Tokens sold.\r\n   */\r\n  function getOutputPrice(uint256 output_amount, uint256 input_reserve, uint256 output_reserve) external view returns (uint256);\r\n\r\n\r\n  /** \r\n   * @notice Convert ETH to Tokens.\r\n   * @dev User specifies exact input (msg.value) \u0026\u0026 minimum output.\r\n   * @param min_tokens Minimum Tokens bought.\r\n   * @param deadline Time after which this transaction can no longer be executed.\r\n   * @return Amount of Tokens bought.\r\n   */ \r\n  function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256);\r\n\r\n  /** \r\n   * @notice Convert ETH to Tokens \u0026\u0026 transfers Tokens to recipient.\r\n   * @dev User specifies exact input (msg.value) \u0026\u0026 minimum output\r\n   * @param min_tokens Minimum Tokens bought.\r\n   * @param deadline Time after which this transaction can no longer be executed.\r\n   * @param recipient The address that receives output Tokens.\r\n   * @return  Amount of Tokens bought.\r\n   */\r\n  function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns(uint256);\r\n\r\n\r\n  /** \r\n   * @notice Convert ETH to Tokens.\r\n   * @dev User specifies maximum input (msg.value) \u0026\u0026 exact output.\r\n   * @param tokens_bought Amount of tokens bought.\r\n   * @param deadline Time after which this transaction can no longer be executed.\r\n   * @return Amount of ETH sold.\r\n   */\r\n  function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns(uint256);\r\n  /** \r\n   * @notice Convert ETH to Tokens \u0026\u0026 transfers Tokens to recipient.\r\n   * @dev User specifies maximum input (msg.value) \u0026\u0026 exact output.\r\n   * @param tokens_bought Amount of tokens bought.\r\n   * @param deadline Time after which this transaction can no longer be executed.\r\n   * @param recipient The address that receives output Tokens.\r\n   * @return Amount of ETH sold.\r\n   */\r\n  function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256);\r\n\r\n  /** \r\n   * @notice Convert Tokens to ETH.\r\n   * @dev User specifies exact input \u0026\u0026 minimum output.\r\n   * @param tokens_sold Amount of Tokens sold.\r\n   * @param min_eth Minimum ETH purchased.\r\n   * @param deadline Time after which this transaction can no longer be executed.\r\n   * @return Amount of ETH bought.\r\n   */\r\n  function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256);\r\n\r\n  /** \r\n   * @notice Convert Tokens to ETH \u0026\u0026 transfers ETH to recipient.\r\n   * @dev User specifies exact input \u0026\u0026 minimum output.\r\n   * @param tokens_sold Amount of Tokens sold.\r\n   * @param min_eth Minimum ETH purchased.\r\n   * @param deadline Time after which this transaction can no longer be executed.\r\n   * @param recipient The address that receives output ETH.\r\n   * @return  Amount of ETH bought.\r\n   */\r\n  function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256);\r\n\r\n  /** \r\n   * @notice Convert Tokens to ETH.\r\n   * @dev User specifies maximum input \u0026\u0026 exact output.\r\n   * @param eth_bought Amount of ETH purchased.\r\n   * @param max_tokens Maximum Tokens sold.\r\n   * @param deadline Time after which this transaction can no longer be executed.\r\n   * @return Amount of Tokens sold.\r\n   */\r\n  function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256);\r\n\r\n  /**\r\n   * @notice Convert Tokens to ETH \u0026\u0026 transfers ETH to recipient.\r\n   * @dev User specifies maximum input \u0026\u0026 exact output.\r\n   * @param eth_bought Amount of ETH purchased.\r\n   * @param max_tokens Maximum Tokens sold.\r\n   * @param deadline Time after which this transaction can no longer be executed.\r\n   * @param recipient The address that receives output ETH.\r\n   * @return Amount of Tokens sold.\r\n   */\r\n  function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256);\r\n\r\n  /**\r\n   * @notice Convert Tokens (token) to Tokens (token_addr).\r\n   * @dev User specifies exact input \u0026\u0026 minimum output.\r\n   * @param tokens_sold Amount of Tokens sold.\r\n   * @param min_tokens_bought Minimum Tokens (token_addr) purchased.\r\n   * @param min_eth_bought Minimum ETH purchased as intermediary.\r\n   * @param deadline Time after which this transaction can no longer be executed.\r\n   * @param token_addr The address of the token being purchased.\r\n   * @return Amount of Tokens (token_addr) bought.\r\n   */\r\n  function tokenToTokenSwapInput(\r\n    uint256 tokens_sold, \r\n    uint256 min_tokens_bought, \r\n    uint256 min_eth_bought, \r\n    uint256 deadline, \r\n    address token_addr) \r\n    external returns (uint256);\r\n\r\n  /**\r\n   * @notice Convert Tokens (token) to Tokens (token_addr) \u0026\u0026 transfers\r\n   *         Tokens (token_addr) to recipient.\r\n   * @dev User specifies exact input \u0026\u0026 minimum output.\r\n   * @param tokens_sold Amount of Tokens sold.\r\n   * @param min_tokens_bought Minimum Tokens (token_addr) purchased.\r\n   * @param min_eth_bought Minimum ETH purchased as intermediary.\r\n   * @param deadline Time after which this transaction can no longer be executed.\r\n   * @param recipient The address that receives output ETH.\r\n   * @param token_addr The address of the token being purchased.\r\n   * @return Amount of Tokens (token_addr) bought.\r\n   */\r\n  function tokenToTokenTransferInput(\r\n    uint256 tokens_sold, \r\n    uint256 min_tokens_bought, \r\n    uint256 min_eth_bought, \r\n    uint256 deadline, \r\n    address recipient, \r\n    address token_addr) \r\n    external returns (uint256);\r\n\r\n\r\n  /**\r\n   * @notice Convert Tokens (token) to Tokens (token_addr).\r\n   * @dev User specifies maximum input \u0026\u0026 exact output.\r\n   * @param tokens_bought Amount of Tokens (token_addr) bought.\r\n   * @param max_tokens_sold Maximum Tokens (token) sold.\r\n   * @param max_eth_sold Maximum ETH purchased as intermediary.\r\n   * @param deadline Time after which this transaction can no longer be executed.\r\n   * @param token_addr The address of the token being purchased.\r\n   * @return Amount of Tokens (token) sold.\r\n   */\r\n  function tokenToTokenSwapOutput(\r\n    uint256 tokens_bought, \r\n    uint256 max_tokens_sold, \r\n    uint256 max_eth_sold, \r\n    uint256 deadline, \r\n    address token_addr) \r\n    external returns (uint256);\r\n\r\n  /**\r\n   * @notice Convert Tokens (token) to Tokens (token_addr) \u0026\u0026 transfers\r\n   *         Tokens (token_addr) to recipient.\r\n   * @dev User specifies maximum input \u0026\u0026 exact output.\r\n   * @param tokens_bought Amount of Tokens (token_addr) bought.\r\n   * @param max_tokens_sold Maximum Tokens (token) sold.\r\n   * @param max_eth_sold Maximum ETH purchased as intermediary.\r\n   * @param deadline Time after which this transaction can no longer be executed.\r\n   * @param recipient The address that receives output ETH.\r\n   * @param token_addr The address of the token being purchased.\r\n   * @return Amount of Tokens (token) sold.\r\n   */\r\n  function tokenToTokenTransferOutput(\r\n    uint256 tokens_bought, \r\n    uint256 max_tokens_sold, \r\n    uint256 max_eth_sold, \r\n    uint256 deadline, \r\n    address recipient, \r\n    address token_addr) \r\n    external returns (uint256);\r\n\r\n  /**\r\n   * @notice Convert Tokens (token) to Tokens (exchange_addr.token).\r\n   * @dev Allows trades through contracts that were not deployed from the same factory.\r\n   * @dev User specifies exact input \u0026\u0026 minimum output.\r\n   * @param tokens_sold Amount of Tokens sold.\r\n   * @param min_tokens_bought Minimum Tokens (token_addr) purchased.\r\n   * @param min_eth_bought Minimum ETH purchased as intermediary.\r\n   * @param deadline Time after which this transaction can no longer be executed.\r\n   * @param exchange_addr The address of the exchange for the token being purchased.\r\n   * @return Amount of Tokens (exchange_addr.token) bought.\r\n   */\r\n  function tokenToExchangeSwapInput(\r\n    uint256 tokens_sold, \r\n    uint256 min_tokens_bought, \r\n    uint256 min_eth_bought, \r\n    uint256 deadline, \r\n    address exchange_addr) \r\n    external returns (uint256);\r\n\r\n  /**\r\n   * @notice Convert Tokens (token) to Tokens (exchange_addr.token) \u0026\u0026 transfers\r\n   *         Tokens (exchange_addr.token) to recipient.\r\n   * @dev Allows trades through contracts that were not deployed from the same factory.\r\n   * @dev User specifies exact input \u0026\u0026 minimum output.\r\n   * @param tokens_sold Amount of Tokens sold.\r\n   * @param min_tokens_bought Minimum Tokens (token_addr) purchased.\r\n   * @param min_eth_bought Minimum ETH purchased as intermediary.\r\n   * @param deadline Time after which this transaction can no longer be executed.\r\n   * @param recipient The address that receives output ETH.\r\n   * @param exchange_addr The address of the exchange for the token being purchased.\r\n   * @return Amount of Tokens (exchange_addr.token) bought.\r\n   */\r\n  function tokenToExchangeTransferInput(\r\n    uint256 tokens_sold, \r\n    uint256 min_tokens_bought, \r\n    uint256 min_eth_bought, \r\n    uint256 deadline, \r\n    address recipient, \r\n    address exchange_addr) \r\n    external returns (uint256);\r\n\r\n  /**\r\n   * @notice Convert Tokens (token) to Tokens (exchange_addr.token).\r\n   * @dev Allows trades through contracts that were not deployed from the same factory.\r\n   * @dev User specifies maximum input \u0026\u0026 exact output.\r\n   * @param tokens_bought Amount of Tokens (token_addr) bought.\r\n   * @param max_tokens_sold Maximum Tokens (token) sold.\r\n   * @param max_eth_sold Maximum ETH purchased as intermediary.\r\n   * @param deadline Time after which this transaction can no longer be executed.\r\n   * @param exchange_addr The address of the exchange for the token being purchased.\r\n   * @return Amount of Tokens (token) sold.\r\n   */\r\n  function tokenToExchangeSwapOutput(\r\n    uint256 tokens_bought, \r\n    uint256 max_tokens_sold, \r\n    uint256 max_eth_sold, \r\n    uint256 deadline, \r\n    address exchange_addr) \r\n    external returns (uint256);\r\n\r\n  /**\r\n   * @notice Convert Tokens (token) to Tokens (exchange_addr.token) \u0026\u0026 transfers\r\n   *         Tokens (exchange_addr.token) to recipient.\r\n   * @dev Allows trades through contracts that were not deployed from the same factory.\r\n   * @dev User specifies maximum input \u0026\u0026 exact output.\r\n   * @param tokens_bought Amount of Tokens (token_addr) bought.\r\n   * @param max_tokens_sold Maximum Tokens (token) sold.\r\n   * @param max_eth_sold Maximum ETH purchased as intermediary.\r\n   * @param deadline Time after which this transaction can no longer be executed.\r\n   * @param recipient The address that receives output ETH.\r\n   * @param exchange_addr The address of the exchange for the token being purchased.\r\n   * @return Amount of Tokens (token) sold.\r\n   */\r\n  function tokenToExchangeTransferOutput(\r\n    uint256 tokens_bought, \r\n    uint256 max_tokens_sold, \r\n    uint256 max_eth_sold, \r\n    uint256 deadline, \r\n    address recipient, \r\n    address exchange_addr) \r\n    external returns (uint256);\r\n\r\n\r\n  /***********************************|\r\n  |         Getter Functions          |\r\n  |__________________________________*/\r\n\r\n  /**\r\n   * @notice external price function for ETH to Token trades with an exact input.\r\n   * @param eth_sold Amount of ETH sold.\r\n   * @return Amount of Tokens that can be bought with input ETH.\r\n   */\r\n  function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256);\r\n\r\n  /**\r\n   * @notice external price function for ETH to Token trades with an exact output.\r\n   * @param tokens_bought Amount of Tokens bought.\r\n   * @return Amount of ETH needed to buy output Tokens.\r\n   */\r\n  function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256);\r\n\r\n  /**\r\n   * @notice external price function for Token to ETH trades with an exact input.\r\n   * @param tokens_sold Amount of Tokens sold.\r\n   * @return Amount of ETH that can be bought with input Tokens.\r\n   */\r\n  function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256);\r\n\r\n  /**\r\n   * @notice external price function for Token to ETH trades with an exact output.\r\n   * @param eth_bought Amount of output ETH.\r\n   * @return Amount of Tokens needed to buy output ETH.\r\n   */\r\n  function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256);\r\n\r\n  /** \r\n   * @return Address of Token that is sold on this exchange.\r\n   */\r\n  function tokenAddress() external view returns (address);\r\n\r\n  /**\r\n   * @return Address of factory that created this exchange.\r\n   */\r\n  function factoryAddress() external view returns (address);\r\n\r\n\r\n  /***********************************|\r\n  |        Liquidity Functions        |\r\n  |__________________________________*/\r\n\r\n  /** \r\n   * @notice Deposit ETH \u0026\u0026 Tokens (token) at current ratio to mint UNI tokens.\r\n   * @dev min_liquidity does nothing when total UNI supply is 0.\r\n   * @param min_liquidity Minimum number of UNI sender will mint if total UNI supply is greater than 0.\r\n   * @param max_tokens Maximum number of tokens deposited. Deposits max amount if total UNI supply is 0.\r\n   * @param deadline Time after which this transaction can no longer be executed.\r\n   * @return The amount of UNI minted.\r\n   */\r\n  function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);\r\n\r\n  /**\r\n   * @dev Burn UNI tokens to withdraw ETH \u0026\u0026 Tokens at current ratio.\r\n   * @param amount Amount of UNI burned.\r\n   * @param min_eth Minimum ETH withdrawn.\r\n   * @param min_tokens Minimum Tokens withdrawn.\r\n   * @param deadline Time after which this transaction can no longer be executed.\r\n   * @return The amount of ETH \u0026\u0026 Tokens withdrawn.\r\n   */\r\n  function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);\r\n}\r\n\r\n// File: contracts/lib/uniswap/interfaces/IUniswapFactory.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\ninterface IUniswapFactory {\r\n  event NewExchange(address indexed token, address indexed exchange);\r\n\r\n  function initializeFactory(address template) external;\r\n  function createExchange(address token) external returns (address payable);\r\n  function getExchange(address token) external view returns (address payable);\r\n  function getToken(address token) external view returns (address);\r\n  function getTokenWihId(uint256 token_id) external view returns (address);\r\n}\r\n\r\n// File: contracts/Refundable.sol\r\n\r\npragma solidity ^0.5.8;\r\n\r\n\r\n\r\n\r\ncontract Refundable {\r\n    using SafeERC20 for ERC20;\r\n\r\n    string private constant ERROR_NOT_GOVERNOR = \u0022REF_NOT_GOVERNOR\u0022;\r\n    string private constant ERROR_ZERO_AMOUNT = \u0022REF_ZERO_AMOUNT\u0022;\r\n    string private constant ERROR_NOT_ENOUGH_BALANCE = \u0022REF_NOT_ENOUGH_BALANCE\u0022;\r\n    string private constant ERROR_ETH_REFUND = \u0022REF_ETH_REFUND\u0022;\r\n    string private constant ERROR_TOKEN_REFUND = \u0022REF_TOKEN_REFUND\u0022;\r\n\r\n    address public governor;\r\n\r\n    modifier onlyGovernor() {\r\n        require(msg.sender == governor, ERROR_NOT_GOVERNOR);\r\n        _;\r\n    }\r\n\r\n    constructor(address _governor) public {\r\n        governor = _governor;\r\n    }\r\n\r\n    /**\r\n    * @notice Refunds accidentally sent ETH. Only governor can do it\r\n    * @param _recipient Address to send funds to\r\n    * @param _amount Amount to be refunded\r\n    */\r\n    function refundEth(address payable _recipient, uint256 _amount) external onlyGovernor {\r\n        require(_amount \u003E 0, ERROR_ZERO_AMOUNT);\r\n        uint256 selfBalance = address(this).balance;\r\n        require(selfBalance \u003E= _amount, ERROR_NOT_ENOUGH_BALANCE);\r\n\r\n        // solium-disable security/no-call-value\r\n        (bool result,) = _recipient.call.value(_amount)(\u0022\u0022);\r\n        require(result, ERROR_ETH_REFUND);\r\n    }\r\n\r\n    /**\r\n    * @notice Refunds accidentally sent ERC20 tokens. Only governor can do it\r\n    * @param _token Token to be refunded\r\n    * @param _recipient Address to send funds to\r\n    * @param _amount Amount to be refunded\r\n    */\r\n    function refundToken(ERC20 _token, address _recipient, uint256 _amount) external onlyGovernor {\r\n        require(_amount \u003E 0, ERROR_ZERO_AMOUNT);\r\n        uint256 selfBalance = _token.balanceOf(address(this));\r\n        require(selfBalance \u003E= _amount, ERROR_NOT_ENOUGH_BALANCE);\r\n\r\n        require(_token.safeTransfer(_recipient, _amount), ERROR_TOKEN_REFUND);\r\n    }\r\n}\r\n\r\n// File: contracts/UniswapWrapper.sol\r\n\r\npragma solidity ^0.5.8;\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\ncontract UniswapWrapper is Refundable, IsContract {\r\n    using SafeERC20 for ERC20;\r\n\r\n    string private constant ERROR_TOKEN_NOT_CONTRACT = \u0022UW_TOKEN_NOT_CONTRACT\u0022;\r\n    string private constant ERROR_REGISTRY_NOT_CONTRACT = \u0022UW_REGISTRY_NOT_CONTRACT\u0022;\r\n    string private constant ERROR_UNISWAP_FACTORY_NOT_CONTRACT = \u0022UW_UNISWAP_FACTORY_NOT_CONTRACT\u0022;\r\n    string private constant ERROR_RECEIVED_WRONG_TOKEN = \u0022UW_RECEIVED_WRONG_TOKEN\u0022;\r\n    string private constant ERROR_WRONG_DATA_LENGTH = \u0022UW_WRONG_DATA_LENGTH\u0022;\r\n    string private constant ERROR_ZERO_AMOUNT = \u0022UW_ZERO_AMOUNT\u0022;\r\n    string private constant ERROR_TOKEN_TRANSFER_FAILED = \u0022UW_TOKEN_TRANSFER_FAILED\u0022;\r\n    string private constant ERROR_TOKEN_APPROVAL_FAILED = \u0022UW_TOKEN_APPROVAL_FAILED\u0022;\r\n    string private constant ERROR_UNISWAP_UNAVAILABLE = \u0022UW_UNISWAP_UNAVAILABLE\u0022;\r\n\r\n    bytes32 internal constant ACTIVATE_DATA = keccak256(\u0022activate(uint256)\u0022);\r\n\r\n    ERC20 public bondedToken;\r\n    ERC900 public registry;\r\n    IUniswapFactory public uniswapFactory;\r\n\r\n    constructor(address _governor, ERC20 _bondedToken, ERC900 _registry, IUniswapFactory _uniswapFactory) Refundable(_governor) public {\r\n        require(isContract(address(_bondedToken)), ERROR_TOKEN_NOT_CONTRACT);\r\n        require(isContract(address(_registry)), ERROR_REGISTRY_NOT_CONTRACT);\r\n        require(isContract(address(_uniswapFactory)), ERROR_UNISWAP_FACTORY_NOT_CONTRACT);\r\n\r\n        bondedToken = _bondedToken;\r\n        registry = _registry;\r\n        uniswapFactory = _uniswapFactory;\r\n    }\r\n\r\n    /**\r\n    * @dev This function must be triggered by an external token\u0027s approve-and-call fallback.\r\n    *      It will pull the approved tokens and convert them in Uniswap, and activate the converted\r\n    *      tokens into a jurors registry instance of an Aragon Court.\r\n    * @param _from Address of the original caller (juror) converting and activating the tokens\r\n    * @param _amount Amount of external tokens to be converted and activated\r\n    * @param _token Address of the external token triggering the approve-and-call fallback\r\n    * @param _data Contains:\r\n    *        - 1st word: activate If non-zero, it will signal token activation in the registry\r\n    *        - 2nd word: minTokens Uniswap param\r\n    *        - 3rd word: minEth Uniswap param\r\n    *        - 4th word: deadline Uniswap param\r\n    */\r\n    function receiveApproval(address _from, uint256 _amount, address _token, bytes calldata _data) external {\r\n        require(_token == msg.sender, ERROR_RECEIVED_WRONG_TOKEN);\r\n        // data must have 4 words\r\n        require(_data.length == 128, ERROR_WRONG_DATA_LENGTH);\r\n\r\n        bool activate;\r\n        uint256 minTokens;\r\n        uint256 minEth;\r\n        uint256 deadline;\r\n        bytes memory data = _data;\r\n        assembly {\r\n            activate := mload(add(data, 0x20))\r\n            minTokens := mload(add(data, 0x40))\r\n            minEth := mload(add(data, 0x60))\r\n            deadline := mload(add(data, 0x80))\r\n        }\r\n\r\n        _contributeExternalToken(_from, _amount, _token, minTokens, minEth, deadline, activate);\r\n    }\r\n\r\n    /**\r\n    * @dev This function needs a previous approval on the external token used for the contributed amount.\r\n    *      It will pull the approved tokens, convert them in Uniswap to the bonded token,\r\n    *      and activate the converted tokens in the jurors registry instance of the Aragon Court.\r\n    * @param _amount Amount of contribution tokens to be converted and activated\r\n    * @param _token Address of the external contribution token used\r\n    * @param _minTokens Minimum amount of bonded tokens obtained in Uniswap\r\n    * @param _minEth Minimum amount of ETH obtained in Uniswap (Uniswap internally converts first to ETH and then to target token)\r\n    * @param _deadline Transaction deadline for Uniswap\r\n    * @param _activate Signal activation of tokens in the registry\r\n    */\r\n    function contributeExternalToken(\r\n        uint256 _amount,\r\n        address _token,\r\n        uint256 _minTokens,\r\n        uint256 _minEth,\r\n        uint256 _deadline,\r\n        bool _activate\r\n    )\r\n        external\r\n    {\r\n        _contributeExternalToken(msg.sender, _amount, _token, _minTokens, _minEth, _deadline, _activate);\r\n    }\r\n\r\n    /**\r\n    * @dev It will send the received ETH to Uniswap to get bonded tokens,\r\n    *      and activate the converted tokens in the jurors registry instance of the Aragon Court.\r\n    * @param _minTokens Minimum amount of bonded tokens obtained in Uniswap\r\n    * @param _deadline Transaction deadline for Uniswap\r\n    * @param _activate Signal activation of tokens in the registry\r\n    */\r\n    function contributeEth(uint256 _minTokens, uint256 _deadline, bool _activate) external payable {\r\n        require(msg.value \u003E 0, ERROR_ZERO_AMOUNT);\r\n\r\n        // get the Uniswap exchange for the bonded token\r\n        address payable uniswapExchangeAddress = uniswapFactory.getExchange(address(bondedToken));\r\n        require(uniswapExchangeAddress != address(0), ERROR_UNISWAP_UNAVAILABLE);\r\n        IUniswapExchange uniswapExchange = IUniswapExchange(uniswapExchangeAddress);\r\n\r\n        // swap tokens\r\n        uint256 bondedTokenAmount = uniswapExchange.ethToTokenSwapInput.value(msg.value)(_minTokens, _deadline);\r\n\r\n        // stake and activate in the registry\r\n        _stakeAndActivate(msg.sender, bondedTokenAmount, _activate);\r\n    }\r\n\r\n    function _contributeExternalToken(\r\n        address _from,\r\n        uint256 _amount,\r\n        address _token,\r\n        uint256 _minTokens,\r\n        uint256 _minEth,\r\n        uint256 _deadline,\r\n        bool _activate\r\n    )\r\n        internal\r\n    {\r\n        require(_amount \u003E 0, ERROR_ZERO_AMOUNT);\r\n\r\n        // move tokens to this contract\r\n        ERC20 token = ERC20(_token);\r\n        require(token.safeTransferFrom(_from, address(this), _amount), ERROR_TOKEN_TRANSFER_FAILED);\r\n\r\n        // get the Uniswap exchange for the external token\r\n        address payable uniswapExchangeAddress = uniswapFactory.getExchange(_token);\r\n        require(uniswapExchangeAddress != address(0), ERROR_UNISWAP_UNAVAILABLE);\r\n        IUniswapExchange uniswapExchange = IUniswapExchange(uniswapExchangeAddress);\r\n\r\n        require(token.safeApprove(address(uniswapExchange), _amount), ERROR_TOKEN_APPROVAL_FAILED);\r\n\r\n        // swap tokens\r\n        uint256 bondedTokenAmount = uniswapExchange.tokenToTokenSwapInput(_amount, _minTokens, _minEth, _deadline, address(bondedToken));\r\n\r\n        // stake and activate in the registry\r\n        _stakeAndActivate(_from, bondedTokenAmount, _activate);\r\n    }\r\n\r\n    function _stakeAndActivate(address _from, uint256 _amount, bool _activate) internal {\r\n        // activate in registry\r\n        bondedToken.approve(address(registry), _amount);\r\n        bytes memory data;\r\n        if (_activate) {\r\n            data = abi.encodePacked(ACTIVATE_DATA);\r\n        }\r\n        registry.stakeFor(_from, _amount, data);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022governor\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_minTokens\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_deadline\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_activate\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022contributeEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_minTokens\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_minEth\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_deadline\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_activate\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022contributeExternalToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022registry\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022uniswapFactory\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022receiveApproval\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022refundToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022refundEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022bondedToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_governor\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_bondedToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_registry\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_uniswapFactory\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"UniswapWrapper","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"1","Runs":"10000","ConstructorArguments":"0000000000000000000000005e8c17a6065c35b172b10e80493d2266e2947df4000000000000000000000000cd62b1c403fa761baadfc74c525ce2b51780b1840000000000000000000000000f7471c1df2021ff45f112878f755aabe7aa16bf000000000000000000000000c0a47dfe034b400b47bdad5fecda2621de6c4d95","Library":"","SwarmSource":"bzzr://53e753b2de57c4be09b6a038af59776b213422c9e2053a73d73f7f98125c3f64"}]