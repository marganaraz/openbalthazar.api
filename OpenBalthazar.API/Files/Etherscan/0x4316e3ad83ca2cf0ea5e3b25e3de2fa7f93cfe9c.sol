[{"SourceCode":"// File: @openzeppelin/upgrades/contracts/Initializable.sol\r\n\r\npragma solidity \u003E=0.4.24 \u003C0.6.0;\r\n\r\n\r\n/**\r\n * @title Initializable\r\n *\r\n * @dev Helper contract to support initializer functions. To use it, replace\r\n * the constructor with a function that has the \u0060initializer\u0060 modifier.\r\n * WARNING: Unlike constructors, initializer functions must be manually\r\n * invoked. This applies both to deploying an Initializable contract, as well\r\n * as extending an Initializable contract via inheritance.\r\n * WARNING: When used with inheritance, manual care must be taken to not invoke\r\n * a parent initializer twice, or ensure that all initializers are idempotent,\r\n * because this is not dealt with automatically as with constructors.\r\n */\r\ncontract Initializable {\r\n\r\n  /**\r\n   * @dev Indicates that the contract has been initialized.\r\n   */\r\n  bool private initialized;\r\n\r\n  /**\r\n   * @dev Indicates that the contract is in the process of being initialized.\r\n   */\r\n  bool private initializing;\r\n\r\n  /**\r\n   * @dev Modifier to use in the initializer function of a contract.\r\n   */\r\n  modifier initializer() {\r\n    require(initializing || isConstructor() || !initialized, \u0022Contract instance has already been initialized\u0022);\r\n\r\n    bool isTopLevelCall = !initializing;\r\n    if (isTopLevelCall) {\r\n      initializing = true;\r\n      initialized = true;\r\n    }\r\n\r\n    _;\r\n\r\n    if (isTopLevelCall) {\r\n      initializing = false;\r\n    }\r\n  }\r\n\r\n  /// @dev Returns true if and only if the function is running in the constructor\r\n  function isConstructor() private view returns (bool) {\r\n    // extcodesize checks the size of the code stored in an address, and\r\n    // address returns the current address. Since the code is still not\r\n    // deployed when running a constructor, any checks on its code size will\r\n    // yield zero, making it an effective way to detect if a contract is\r\n    // under construction or not.\r\n    uint256 cs;\r\n    assembly { cs := extcodesize(address) }\r\n    return cs == 0;\r\n  }\r\n\r\n  // Reserved storage space to allow for layout changes in the future.\r\n  uint256[50] private ______gap;\r\n}\r\n\r\n// File: @openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * \u0060SafeMath\u0060 restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060\u002B\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060*\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\r\n * the optional functions; to access them see {ERC20Detailed}.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from the caller\u0027s account to \u0060recipient\u0060.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that \u0060spender\u0060 will be\r\n     * allowed to spend on behalf of \u0060owner\u0060 through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from \u0060sender\u0060 to \u0060recipient\u0060 using the\r\n     * allowance mechanism. \u0060amount\u0060 is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when \u0060value\u0060 tokens are moved from one account (\u0060from\u0060) to\r\n     * another (\u0060to\u0060).\r\n     *\r\n     * Note that \u0060value\u0060 may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a \u0060spender\u0060 for an \u0060owner\u0060 is set by\r\n     * a call to {approve}. \u0060value\u0060 is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n// File: @openzeppelin/contracts-ethereum-package/contracts/utils/ReentrancyGuard.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n\r\n/**\r\n * @dev Contract module that helps prevent reentrant calls to a function.\r\n *\r\n * Inheriting from \u0060ReentrancyGuard\u0060 will make the {nonReentrant} modifier\r\n * available, which can be applied to functions to make sure there are no nested\r\n * (reentrant) calls to them.\r\n *\r\n * Note that because there is a single \u0060nonReentrant\u0060 guard, functions marked as\r\n * \u0060nonReentrant\u0060 may not call one another. This can be worked around by making\r\n * those functions \u0060private\u0060, and then adding \u0060external\u0060 \u0060nonReentrant\u0060 entry\r\n * points to them.\r\n */\r\ncontract ReentrancyGuard is Initializable {\r\n    // counter to allow mutex lock with only one SSTORE operation\r\n    uint256 private _guardCounter;\r\n\r\n    function initialize() public initializer {\r\n        // The counter starts at one to prevent changing it from zero to a non-zero\r\n        // value, which is a more expensive operation.\r\n        _guardCounter = 1;\r\n    }\r\n\r\n    /**\r\n     * @dev Prevents a contract from calling itself, directly or indirectly.\r\n     * Calling a \u0060nonReentrant\u0060 function from another \u0060nonReentrant\u0060\r\n     * function is not supported. It is possible to prevent this from happening\r\n     * by making the \u0060nonReentrant\u0060 function external, and make it call a\r\n     * \u0060private\u0060 function that does the actual work.\r\n     */\r\n    modifier nonReentrant() {\r\n        _guardCounter \u002B= 1;\r\n        uint256 localCounter = _guardCounter;\r\n        _;\r\n        require(localCounter == _guardCounter, \u0022ReentrancyGuard: reentrant call\u0022);\r\n    }\r\n\r\n    uint256[50] private ______gap;\r\n}\r\n\r\n// File: contracts/UpdatedZaps/WIP/UniSwapRemoveLiquidityGeneral_v1.sol\r\n\r\n// Copyright (C) 2019, 2020 dipeshsukhani, nodarjonashi, toshsharma, suhailg\r\n\r\n// This program is free software: you can redistribute it and/or modify\r\n// it under the terms of the GNU Affero General Public License as published by\r\n// the Free Software Foundation, either version 2 of the License, or\r\n// (at your option) any later version.\r\n//\r\n// This program is distributed in the hope that it will be useful,\r\n// but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n// GNU Affero General Public License for more details.\r\n//\r\n// Visit \u003Chttps://www.gnu.org/licenses/\u003Efor a copy of the GNU Affero General Public License\r\n\r\n/**\r\n * WARNING: This is an upgradable contract. Be careful not to disrupt\r\n * the existing storage layout when making upgrades to the contract. In particular,\r\n * existing fields should not be removed and should not have their types changed.\r\n * The order of field declarations must not be changed, and new fields must be added\r\n * below all existing declarations.\r\n *\r\n * The base contracts and the order in which they are declared must not be changed.\r\n * New fields must not be added to base contracts (unless the base contract has\r\n * reserved placeholder fields for this purpose).\r\n *\r\n * See https://docs.zeppelinos.org/docs/writing_contracts.html for more info.\r\n*/\r\n\r\npragma solidity ^0.5.0;\r\n\r\n\r\n\r\n\r\n\r\n///@author DeFiZap\r\n///@notice this contract implements one click conversion from Unipool liquidity tokens to ETH\r\n\r\ninterface IuniswapFactory_UniSwapRemoveLiquityGeneral_v1 {\r\n    function getExchange(address token)\r\n        external\r\n        view\r\n        returns (address exchange);\r\n}\r\n\r\ninterface IuniswapExchange_UniSwapRemoveLiquityGeneral_v1 {\r\n    // for removing liquidity (returns ETH removed, ERC20 Removed)\r\n    function removeLiquidity(\r\n        uint256 amount,\r\n        uint256 min_eth,\r\n        uint256 min_tokens,\r\n        uint256 deadline\r\n    ) external returns (uint256, uint256);\r\n\r\n    // to convert ERC20 to ETH and transfer\r\n    function getTokenToEthInputPrice(uint256 tokens_sold)\r\n        external\r\n        view\r\n        returns (uint256 eth_bought);\r\n    function tokenToEthTransferInput(\r\n        uint256 tokens_sold,\r\n        uint256 min_eth,\r\n        uint256 deadline,\r\n        address recipient\r\n    ) external returns (uint256 eth_bought);\r\n    /// -- optional\r\n    function tokenToEthSwapInput(\r\n        uint256 tokens_sold,\r\n        uint256 min_eth,\r\n        uint256 deadline\r\n    ) external returns (uint256 eth_bought);\r\n\r\n    // to convert ETH to ERC20 and transfer\r\n    function getEthToTokenInputPrice(uint256 eth_sold)\r\n        external\r\n        view\r\n        returns (uint256 tokens_bought);\r\n    function ethToTokenTransferInput(\r\n        uint256 min_tokens,\r\n        uint256 deadline,\r\n        address recipient\r\n    ) external payable returns (uint256 tokens_bought);\r\n    /// -- optional\r\n    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline)\r\n        external\r\n        payable\r\n        returns (uint256 tokens_bought);\r\n\r\n    // converting ERC20 to ERC20 and transfer\r\n    function tokenToTokenTransferInput(\r\n        uint256 tokens_sold,\r\n        uint256 min_tokens_bought,\r\n        uint256 min_eth_bought,\r\n        uint256 deadline,\r\n        address recipient,\r\n        address token_addr\r\n    ) external returns (uint256 tokens_bought);\r\n\r\n    // misc\r\n    function allowance(address _owner, address _spender)\r\n        external\r\n        view\r\n        returns (uint256);\r\n    function balanceOf(address _owner) external view returns (uint256);\r\n    function transfer(address _to, uint256 _value) external returns (bool);\r\n    function transferFrom(address from, address to, uint256 tokens)\r\n        external\r\n        returns (bool success);\r\n\r\n}\r\n\r\ncontract UniSwapRemoveLiquityGeneral_v1 is Initializable, ReentrancyGuard {\r\n    using SafeMath for uint256;\r\n\r\n    // state variables\r\n\r\n    // - THESE MUST ALWAYS STAY IN THE SAME LAYOUT\r\n    bool private stopped;\r\n    address payable public owner;\r\n    IuniswapFactory_UniSwapRemoveLiquityGeneral_v1 public UniSwapFactoryAddress;\r\n    uint16 public goodwill;\r\n    address public dzgoodwillAddress;\r\n    mapping(address =\u003E uint256) private userBalance;\r\n    IERC20 public DaiTokenAddress;\r\n\r\n    // events\r\n    event details(\r\n        IuniswapExchange_UniSwapRemoveLiquityGeneral_v1 indexed ExchangeAddress,\r\n        IERC20 TokenAdddress,\r\n        address _user,\r\n        uint256 LiqRed,\r\n        uint256 ethRec,\r\n        uint256 tokenRec,\r\n        string indexed func\r\n    );\r\n\r\n    // circuit breaker modifiers\r\n    modifier stopInEmergency {\r\n        if (stopped) {\r\n            revert(\u0022Temporarily Paused\u0022);\r\n        } else {\r\n            _;\r\n        }\r\n    }\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022you are not authorised to call this function\u0022);\r\n        _;\r\n    }\r\n\r\n    function initialize(\r\n        address _UniSwapFactoryAddress,\r\n        uint16 _goodwill,\r\n        address _dzgoodwillAddress,\r\n        address _DaiTokenAddress\r\n    ) public initializer {\r\n        ReentrancyGuard.initialize();\r\n        stopped = false;\r\n        owner = msg.sender;\r\n        UniSwapFactoryAddress = IuniswapFactory_UniSwapRemoveLiquityGeneral_v1(\r\n            _UniSwapFactoryAddress\r\n        );\r\n        goodwill = _goodwill;\r\n        dzgoodwillAddress = _dzgoodwillAddress;\r\n        DaiTokenAddress = IERC20(_DaiTokenAddress);\r\n    }\r\n\r\n    function set_new_UniSwapFactoryAddress(address _new_UniSwapFactoryAddress)\r\n        public\r\n        onlyOwner\r\n    {\r\n        UniSwapFactoryAddress = IuniswapFactory_UniSwapRemoveLiquityGeneral_v1(\r\n            _new_UniSwapFactoryAddress\r\n        );\r\n\r\n    }\r\n\r\n    function set_new_goodwill(uint16 _new_goodwill) public onlyOwner {\r\n        require(\r\n            _new_goodwill \u003E 0 \u0026\u0026 _new_goodwill \u003C 10000,\r\n            \u0022GoodWill Value not allowed\u0022\r\n        );\r\n        goodwill = _new_goodwill;\r\n\r\n    }\r\n\r\n    function set_new_dzgoodwillAddress(address _new_dzgoodwillAddress)\r\n        public\r\n        onlyOwner\r\n    {\r\n        dzgoodwillAddress = _new_dzgoodwillAddress;\r\n    }\r\n\r\n    function LetsWithdraw_onlyETH(\r\n        address _TokenContractAddress,\r\n        uint256 LiquidityTokenSold\r\n    ) public payable stopInEmergency nonReentrant returns (bool) {\r\n        IuniswapExchange_UniSwapRemoveLiquityGeneral_v1 UniSwapExchangeContractAddress = IuniswapExchange_UniSwapRemoveLiquityGeneral_v1(\r\n            UniSwapFactoryAddress.getExchange(_TokenContractAddress)\r\n        );\r\n        uint256 maxtokensPermitted = UniSwapExchangeContractAddress.allowance(\r\n            msg.sender,\r\n            address(this)\r\n        );\r\n        require(\r\n            LiquidityTokenSold \u003C= maxtokensPermitted,\r\n            \u0022Permission to DeFiZap is less than requested\u0022\r\n        );\r\n        uint256 goodwillPortion = SafeMath.div(\r\n            SafeMath.mul(LiquidityTokenSold, goodwill),\r\n            10000\r\n        );\r\n        require(\r\n            UniSwapExchangeContractAddress.transferFrom(\r\n                msg.sender,\r\n                address(this),\r\n                SafeMath.sub(LiquidityTokenSold, goodwillPortion)\r\n            ),\r\n            \u0022error2:defizap\u0022\r\n        );\r\n        require(\r\n            UniSwapExchangeContractAddress.transferFrom(\r\n                msg.sender,\r\n                dzgoodwillAddress,\r\n                goodwillPortion\r\n            ),\r\n            \u0022error3:defizap\u0022\r\n        );\r\n\r\n        (uint256 ethReceived, uint256 erc20received) = UniSwapExchangeContractAddress\r\n            .removeLiquidity(\r\n            SafeMath.sub(LiquidityTokenSold, goodwillPortion),\r\n            1,\r\n            1,\r\n            SafeMath.add(now, 1800)\r\n        );\r\n\r\n        uint256 eth_againstERC20 = UniSwapExchangeContractAddress\r\n            .getTokenToEthInputPrice(erc20received);\r\n        IERC20(_TokenContractAddress).approve(\r\n            address(UniSwapExchangeContractAddress),\r\n            erc20received\r\n        );\r\n        UniSwapExchangeContractAddress.tokenToEthTransferInput(\r\n            erc20received,\r\n            SafeMath.div(SafeMath.mul(eth_againstERC20, 98), 100),\r\n            SafeMath.add(now, 1800),\r\n            msg.sender\r\n        );\r\n        userBalance[msg.sender] = ethReceived;\r\n        require(send_out_eth(msg.sender), \u0022issue in transfer ETH\u0022);\r\n        emit details(\r\n            UniSwapExchangeContractAddress,\r\n            IERC20(_TokenContractAddress),\r\n            msg.sender,\r\n            SafeMath.sub(LiquidityTokenSold, goodwillPortion),\r\n            ethReceived,\r\n            erc20received,\r\n            \u0022onlyETH\u0022\r\n        );\r\n        return true;\r\n    }\r\n\r\n    function LetsWithdraw_onlyERC(\r\n        address _TokenContractAddress,\r\n        uint256 LiquidityTokenSold,\r\n        bool _returnInDai\r\n    ) public payable stopInEmergency nonReentrant returns (bool) {\r\n        IuniswapExchange_UniSwapRemoveLiquityGeneral_v1 UniSwapExchangeContractAddress = IuniswapExchange_UniSwapRemoveLiquityGeneral_v1(\r\n            UniSwapFactoryAddress.getExchange(_TokenContractAddress)\r\n        );\r\n        IuniswapExchange_UniSwapRemoveLiquityGeneral_v1 DAIUniSwapExchangeContractAddress = IuniswapExchange_UniSwapRemoveLiquityGeneral_v1(\r\n            UniSwapFactoryAddress.getExchange(address(DaiTokenAddress))\r\n        );\r\n        uint256 maxtokensPermitted = UniSwapExchangeContractAddress.allowance(\r\n            msg.sender,\r\n            address(this)\r\n        );\r\n        require(\r\n            LiquidityTokenSold \u003C= maxtokensPermitted,\r\n            \u0022Permission to DeFiZap is less than requested\u0022\r\n        );\r\n        uint256 goodwillPortion = SafeMath.div(\r\n            SafeMath.mul(LiquidityTokenSold, goodwill),\r\n            10000\r\n        );\r\n        require(\r\n            UniSwapExchangeContractAddress.transferFrom(\r\n                msg.sender,\r\n                address(this),\r\n                SafeMath.sub(LiquidityTokenSold, goodwillPortion)\r\n            ),\r\n            \u0022error2:defizap\u0022\r\n        );\r\n        require(\r\n            UniSwapExchangeContractAddress.transferFrom(\r\n                msg.sender,\r\n                dzgoodwillAddress,\r\n                goodwillPortion\r\n            ),\r\n            \u0022error3:defizap\u0022\r\n        );\r\n        (uint256 ethReceived, uint256 erc20received) = UniSwapExchangeContractAddress\r\n            .removeLiquidity(\r\n            SafeMath.sub(LiquidityTokenSold, goodwillPortion),\r\n            1,\r\n            1,\r\n            SafeMath.add(now, 1800)\r\n        );\r\n        if (_returnInDai) {\r\n            require(\r\n                _TokenContractAddress != address(DaiTokenAddress),\r\n                \u0022error5:defizap\u0022\r\n            );\r\n            DAIUniSwapExchangeContractAddress.ethToTokenTransferInput.value(\r\n                ethReceived\r\n            )(1, SafeMath.add(now, 1800), msg.sender);\r\n            IERC20(_TokenContractAddress).approve(\r\n                address(UniSwapExchangeContractAddress),\r\n                erc20received\r\n            );\r\n            UniSwapExchangeContractAddress.tokenToTokenTransferInput(\r\n                erc20received,\r\n                1,\r\n                1,\r\n                SafeMath.add(now, 1800),\r\n                msg.sender,\r\n                address(DaiTokenAddress)\r\n            );\r\n            emit details(\r\n                UniSwapExchangeContractAddress,\r\n                IERC20(_TokenContractAddress),\r\n                msg.sender,\r\n                SafeMath.sub(LiquidityTokenSold, goodwillPortion),\r\n                ethReceived,\r\n                erc20received,\r\n                \u0022onlyDAI\u0022\r\n            );\r\n        } else {\r\n            UniSwapExchangeContractAddress.ethToTokenTransferInput.value(\r\n                ethReceived\r\n            )(1, SafeMath.add(now, 1800), msg.sender);\r\n            IERC20(_TokenContractAddress).transfer(msg.sender, erc20received);\r\n            emit details(\r\n                UniSwapExchangeContractAddress,\r\n                IERC20(_TokenContractAddress),\r\n                msg.sender,\r\n                SafeMath.sub(LiquidityTokenSold, goodwillPortion),\r\n                ethReceived,\r\n                erc20received,\r\n                \u0022onlyERC\u0022\r\n            );\r\n        }\r\n\r\n        return true;\r\n    }\r\n\r\n    function send_out_eth(address _towhomtosendtheETH) internal returns (bool) {\r\n        require(userBalance[_towhomtosendtheETH] \u003E 0, \u0022error4:DefiZap\u0022);\r\n        uint256 amount = userBalance[_towhomtosendtheETH];\r\n        userBalance[_towhomtosendtheETH] = 0;\r\n        (bool success, ) = _towhomtosendtheETH.call.value(amount)(\u0022\u0022);\r\n        require(success, \u0022error5:DefiZap\u0022);\r\n        return true;\r\n    }\r\n\r\n    // - fallback function let you / anyone send ETH to this wallet without the need to call any function\r\n    function() external payable {}\r\n\r\n    // Should there be a need to withdraw any other ERC20 token\r\n    function withdrawERC20Token(IERC20 _targetContractAddress)\r\n        public\r\n        onlyOwner\r\n    {\r\n        uint256 OtherTokenBalance = _targetContractAddress.balanceOf(\r\n            address(this)\r\n        );\r\n        _targetContractAddress.transfer(owner, OtherTokenBalance);\r\n    }\r\n\r\n    // - to Pause the contract\r\n    function toggleContractActive() public onlyOwner {\r\n        stopped = !stopped;\r\n    }\r\n\r\n    // - to withdraw any ETH balance sitting in the contract\r\n    function withdraw() public onlyOwner {\r\n        owner.transfer(address(this).balance);\r\n    }\r\n\r\n    // - to kill the contract\r\n    function destruct() public onlyOwner {\r\n        selfdestruct(owner);\r\n    }\r\n\r\n    /**\r\n     * @return true if \u0060msg.sender\u0060 is the owner of the contract.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return msg.sender == owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address payable newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     */\r\n    function _transferOwnership(address payable newOwner) internal {\r\n        require(\r\n            newOwner != address(0),\r\n            \u0022Ownable: new owner is the zero address\u0022\r\n        );\r\n        owner = newOwner;\r\n    }\r\n\r\n}","ABI":"[{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022contract IuniswapExchange_UniSwapRemoveLiquityGeneral_v1\u0022,\u0022name\u0022:\u0022ExchangeAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022TokenAdddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022LiqRed\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022ethRec\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokenRec\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022func\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022details\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022DaiTokenAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_TokenContractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022LiquidityTokenSold\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_returnInDai\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022LetsWithdraw_onlyERC\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_TokenContractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022LiquidityTokenSold\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LetsWithdraw_onlyETH\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022UniSwapFactoryAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract IuniswapFactory_UniSwapRemoveLiquityGeneral_v1\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022destruct\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022dzgoodwillAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022goodwill\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint16\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint16\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_UniSwapFactoryAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint16\u0022,\u0022name\u0022:\u0022_goodwill\u0022,\u0022type\u0022:\u0022uint16\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_dzgoodwillAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_DaiTokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022initialize\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022initialize\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_new_UniSwapFactoryAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022set_new_UniSwapFactoryAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_new_dzgoodwillAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022set_new_dzgoodwillAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint16\u0022,\u0022name\u0022:\u0022_new_goodwill\u0022,\u0022type\u0022:\u0022uint16\u0022}],\u0022name\u0022:\u0022set_new_goodwill\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022toggleContractActive\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022_targetContractAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022withdrawERC20Token\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"UniSwapRemoveLiquityGeneral_v1","CompilerVersion":"v0.5.13\u002Bcommit.5b0b510c","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://045d79e140fca5902c77182843013b8939292348e6f3713c240b8d61a2ba5771"}]