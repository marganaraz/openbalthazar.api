[{"SourceCode":"// File: localhost/contracts/OpenZepplinReentrancyGuard.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Contract module that helps prevent reentrant calls to a function.\r\n *\r\n * Inheriting from \u0060ReentrancyGuard\u0060 will make the {nonReentrant} modifier\r\n * available, which can be applied to functions to make sure there are no nested\r\n * (reentrant) calls to them.\r\n *\r\n * Note that because there is a single \u0060nonReentrant\u0060 guard, functions marked as\r\n * \u0060nonReentrant\u0060 may not call one another. This can be worked around by making\r\n * those functions \u0060private\u0060, and then adding \u0060external\u0060 \u0060nonReentrant\u0060 entry\r\n * points to them.\r\n *\r\n * _Since v2.5.0:_ this module is now much more gas efficient, given net gas\r\n * metering changes introduced in the Istanbul hardfork.\r\n */\r\ncontract ReentrancyGuard {\r\n    bool private _notEntered;\r\n\r\n    constructor () internal {\r\n        // Storing an initial non-zero value makes deployment a bit more\r\n        // expensive, but in exchange the refund on every call to nonReentrant\r\n        // will be lower in amount. Since refunds are capped to a percetange of\r\n        // the total transaction\u0027s gas, it is best to keep them low in cases\r\n        // like this one, to increase the likelihood of the full refund coming\r\n        // into effect.\r\n        _notEntered = true;\r\n    }\r\n\r\n    /**\r\n     * @dev Prevents a contract from calling itself, directly or indirectly.\r\n     * Calling a \u0060nonReentrant\u0060 function from another \u0060nonReentrant\u0060\r\n     * function is not supported. It is possible to prevent this from happening\r\n     * by making the \u0060nonReentrant\u0060 function external, and make it call a\r\n     * \u0060private\u0060 function that does the actual work.\r\n     */\r\n    modifier nonReentrant() {\r\n        // On the first call to nonReentrant, _notEntered will be true\r\n        require(_notEntered, \u0022ReentrancyGuard: reentrant call\u0022);\r\n\r\n        // Any calls to nonReentrant after this point will fail\r\n        _notEntered = false;\r\n\r\n        _;\r\n\r\n        // By storing the original value once again, a refund is triggered (see\r\n        // https://eips.ethereum.org/EIPS/eip-2200)\r\n        _notEntered = true;\r\n    }\r\n}\r\n// File: localhost/contracts/OpenZepplinIERC20.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\r\n * the optional functions; to access them see {ERC20Detailed}.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from the caller\u0027s account to \u0060recipient\u0060.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that \u0060spender\u0060 will be\r\n     * allowed to spend on behalf of \u0060owner\u0060 through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from \u0060sender\u0060 to \u0060recipient\u0060 using the\r\n     * allowance mechanism. \u0060amount\u0060 is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when \u0060value\u0060 tokens are moved from one account (\u0060from\u0060) to\r\n     * another (\u0060to\u0060).\r\n     *\r\n     * Note that \u0060value\u0060 may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a \u0060spender\u0060 for an \u0060owner\u0060 is set by\r\n     * a call to {approve}. \u0060value\u0060 is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n// File: localhost/contracts/OpenZepplinSafeMath.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * \u0060SafeMath\u0060 restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060\u002B\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060*\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n// File: localhost/contracts/OpenZepplinOwnable.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\ncontract Context {\r\n    // Empty internal constructor, to prevent people from mistakenly deploying\r\n    // an instance of this contract, which should be used via inheritance.\r\n    constructor () internal { }\r\n    // solhint-disable-previous-line no-empty-blocks\r\n\r\n    function _msgSender() internal view returns (address payable) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view returns (bytes memory) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * \u0060onlyOwner\u0060, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\ncontract Ownable is Context {\r\n    address payable public _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () internal {\r\n        address payable msgSender = _msgSender();\r\n        _owner = msgSender;\r\n        emit OwnershipTransferred(address(0), msgSender);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the caller is the current owner.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return _msgSender() == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * \u0060onlyOwner\u0060 functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address payable newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     */\r\n    function _transferOwnership(address payable newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n// File: localhost/contracts/UniSwap_ETH_cDAIv2.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n\r\n\r\n\r\n\r\n\r\n///@author DeFiZap\r\n///@notice this contract implements one click conversion from ETH to unipool liquidity tokens (cDAI)\r\n\r\ninterface IuniswapFactory {\r\n    function getExchange(address token) external view returns (address exchange);\r\n}\r\n\r\n\r\ninterface IuniswapExchange {\r\n    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);\r\n    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);\r\n    function balanceOf(address _owner) external view returns (uint256);\r\n    function transfer(address _to, uint256 _value) external returns (bool);\r\n    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);\r\n}\r\n\r\ninterface IKyberInterface {\r\n    function swapTokentoToken(IERC20 _srcTokenAddressERC20, IERC20 _dstTokenAddress, uint _slippageValue) external payable returns (uint);\r\n}\r\n\r\ninterface Compound {\r\n    function approve ( address spender, uint256 amount ) external returns ( bool );\r\n    function mint ( uint256 mintAmount ) external returns ( uint256 );\r\n    function balanceOf(address _owner) external view returns (uint256 balance);\r\n    function transfer(address _to, uint _value) external returns (bool success);\r\n}\r\n\r\n\r\ncontract UniSwap_ETH_CDAIZap is Ownable, ReentrancyGuard {\r\n    using SafeMath for uint;\r\n    \r\n    // events\r\n    event ERC20TokenHoldingsOnConversionDaiChai(uint);\r\n    event ERC20TokenHoldingsOnConversionEthDai(uint);\r\n    event LiquidityTokens(uint);\r\n\r\n    \r\n    // state variables\r\n    uint public balance = address(this).balance;\r\n    \r\n\r\n    // in relation to the emergency functioning of this contract\r\n    bool private stopped = false;\r\n     \r\n    // circuit breaker modifiers\r\n    modifier stopInEmergency {if (!stopped) _;}\r\n    modifier onlyInEmergency {if (stopped) _;}\r\n    \r\n    function toggleContractActive() onlyOwner public {\r\n        stopped = !stopped;\r\n    }\r\n    \r\n    // - Key Addresses\r\n    IuniswapFactory public UniSwapFactoryAddress = IuniswapFactory(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95);\r\n    IKyberInterface public KyberInterfaceAddresss;\r\n    IERC20 public NEWDAI_TOKEN_ADDRESS = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);\r\n    Compound public COMPOUND_TOKEN_ADDRESS = Compound(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);\r\n    \r\n    function set_KyberInterfaceAddresss(IKyberInterface _new_KyberInterfaceAddresss) public onlyOwner {\r\n        KyberInterfaceAddresss = _new_KyberInterfaceAddresss;\r\n    }\r\n    \r\n    \r\n    function LetsInvest(address _src, address _towhomtoissue, uint _MaxslippageValue) public payable stopInEmergency returns (uint) {\r\n        IERC20 ERC20TokenAddress = IERC20(address(COMPOUND_TOKEN_ADDRESS));\r\n        IuniswapExchange UniSwapExchangeContractAddress = IuniswapExchange(UniSwapFactoryAddress.getExchange(address(COMPOUND_TOKEN_ADDRESS)));\r\n\r\n        // determining the portion of the incoming ETH to be converted to the ERC20 Token\r\n        uint conversionPortion = SafeMath.div(SafeMath.mul(msg.value, 505), 1000);\r\n        uint non_conversionPortion = SafeMath.sub(msg.value,conversionPortion);\r\n\r\n        KyberInterfaceAddresss.swapTokentoToken.value(conversionPortion)(IERC20(_src), NEWDAI_TOKEN_ADDRESS, _MaxslippageValue);\r\n        uint tokenBalance = NEWDAI_TOKEN_ADDRESS.balanceOf(address(this));\r\n        // conversion of DAI to cDAI\r\n        uint qty2approve = SafeMath.mul(tokenBalance, 3);\r\n        require(NEWDAI_TOKEN_ADDRESS.approve(address(ERC20TokenAddress), qty2approve));\r\n        COMPOUND_TOKEN_ADDRESS.mint(tokenBalance);\r\n        uint ERC20TokenHoldings = ERC20TokenAddress.balanceOf(address(this));\r\n        require (ERC20TokenHoldings \u003E 0, \u0022the conversion did not happen as planned\u0022);\r\n        emit ERC20TokenHoldingsOnConversionDaiChai(ERC20TokenHoldings);\r\n        NEWDAI_TOKEN_ADDRESS.approve(address(ERC20TokenAddress), 0);\r\n        ERC20TokenAddress.approve(address(UniSwapExchangeContractAddress),ERC20TokenHoldings);\r\n\r\n        // adding Liquidity\r\n        uint max_tokens_ans = getMaxTokens(address(UniSwapExchangeContractAddress), ERC20TokenAddress, non_conversionPortion);\r\n        UniSwapExchangeContractAddress.addLiquidity.value(non_conversionPortion)(1,max_tokens_ans,SafeMath.add(now,1800));\r\n        ERC20TokenAddress.approve(address(UniSwapExchangeContractAddress),0);\r\n\r\n        // transferring Liquidity\r\n        uint LiquityTokenHoldings = UniSwapExchangeContractAddress.balanceOf(address(this));\r\n        emit LiquidityTokens(LiquityTokenHoldings);\r\n        UniSwapExchangeContractAddress.transfer(_towhomtoissue, LiquityTokenHoldings);\r\n        ERC20TokenHoldings = ERC20TokenAddress.balanceOf(address(this));\r\n        ERC20TokenAddress.transfer(_towhomtoissue, ERC20TokenHoldings);\r\n        return LiquityTokenHoldings;\r\n    }\r\n\r\n    function getMaxTokens(address _UniSwapExchangeContractAddress, IERC20 _ERC20TokenAddress, uint _value) internal view returns (uint) {\r\n        uint contractBalance = address(_UniSwapExchangeContractAddress).balance;\r\n        uint eth_reserve = SafeMath.sub(contractBalance, _value);\r\n        uint token_reserve = _ERC20TokenAddress.balanceOf(_UniSwapExchangeContractAddress);\r\n        uint token_amount = SafeMath.div(SafeMath.mul(_value,token_reserve),eth_reserve) \u002B 1;\r\n        return token_amount;\r\n    }\r\n    \r\n    \r\n\r\n\r\n    \r\n    // incase of half-way error\r\n    function withdrawERC20Token (address _TokenContractAddress) public onlyOwner {\r\n        IERC20 ERC20TokenAddress = IERC20(_TokenContractAddress);\r\n        uint StuckERC20Holdings = ERC20TokenAddress.balanceOf(address(this));\r\n        ERC20TokenAddress.transfer(_owner, StuckERC20Holdings);\r\n    }\r\n    \r\n    function set_new_cDAI_TokenContractAddress(address _new_cDAI_TokenContractAddress) public onlyOwner {\r\n        COMPOUND_TOKEN_ADDRESS = Compound(address(_new_cDAI_TokenContractAddress));\r\n        \r\n    }\r\n    \r\n\r\n    // fx in relation to ETH held by the contract sent by the owner\r\n    \r\n    // - this function lets you deposit ETH into this wallet\r\n    function depositETH() public payable  onlyOwner {\r\n        balance \u002B= msg.value;\r\n    }\r\n    \r\n    // - fallback function let you / anyone send ETH to this wallet without the need to call any function\r\n    function() external payable {\r\n        if (msg.sender == _owner) {\r\n            depositETH();\r\n        } else {\r\n            LetsInvest(address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE), msg.sender, 3);\r\n        }\r\n    }\r\n    \r\n\r\n    \r\n    // - to withdraw any ETH balance sitting in the contract\r\n    function withdraw() public onlyOwner {\r\n        _owner.transfer(address(this).balance);\r\n    }\r\n    \r\n    function _selfDestruct() public onlyOwner {\r\n        selfdestruct(_owner);\r\n    }\r\n    \r\n}","ABI":"[{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ERC20TokenHoldingsOnConversionDaiChai\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ERC20TokenHoldingsOnConversionEthDai\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LiquidityTokens\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022COMPOUND_TOKEN_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract Compound\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022KyberInterfaceAddresss\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract IKyberInterface\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_src\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_towhomtoissue\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_MaxslippageValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LetsInvest\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022NEWDAI_TOKEN_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022UniSwapFactoryAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract IuniswapFactory\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_selfDestruct\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022balance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022depositETH\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract IKyberInterface\u0022,\u0022name\u0022:\u0022_new_KyberInterfaceAddresss\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022set_KyberInterfaceAddresss\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_new_cDAI_TokenContractAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022set_new_cDAI_TokenContractAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022toggleContractActive\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_TokenContractAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022withdrawERC20Token\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"UniSwap_ETH_CDAIZap","CompilerVersion":"v0.5.13\u002Bcommit.5b0b510c","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://44f4a56d3e2dace096ea10b2887a2b4c6e95b79413accc96414e77078dfc64f0"}]