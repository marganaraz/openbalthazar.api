[{"SourceCode":"// File: contracts/OpenZepplinOwnable.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\ncontract Context {\r\n    // Empty internal constructor, to prevent people from mistakenly deploying\r\n    // an instance of this contract, which should be used via inheritance.\r\n    constructor () internal { }\r\n    // solhint-disable-previous-line no-empty-blocks\r\n\r\n    function _msgSender() internal view returns (address payable) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view returns (bytes memory) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * \u0060onlyOwner\u0060, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\ncontract Ownable is Context {\r\n    address payable public _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () internal {\r\n        address payable msgSender = _msgSender();\r\n        _owner = msgSender;\r\n        emit OwnershipTransferred(address(0), msgSender);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the caller is the current owner.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return _msgSender() == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * \u0060onlyOwner\u0060 functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address payable newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     */\r\n    function _transferOwnership(address payable newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\n// File: contracts/OpenZepplinSafeMath.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * \u0060SafeMath\u0060 restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060\u002B\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060*\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n// File: contracts/OpenZepplinIERC20.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\r\n * the optional functions; to access them see {ERC20Detailed}.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from the caller\u0027s account to \u0060recipient\u0060.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that \u0060spender\u0060 will be\r\n     * allowed to spend on behalf of \u0060owner\u0060 through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from \u0060sender\u0060 to \u0060recipient\u0060 using the\r\n     * allowance mechanism. \u0060amount\u0060 is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when \u0060value\u0060 tokens are moved from one account (\u0060from\u0060) to\r\n     * another (\u0060to\u0060).\r\n     *\r\n     * Note that \u0060value\u0060 may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a \u0060spender\u0060 for an \u0060owner\u0060 is set by\r\n     * a call to {approve}. \u0060value\u0060 is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n// File: contracts/OpenZepplinReentrancyGuard.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Contract module that helps prevent reentrant calls to a function.\r\n *\r\n * Inheriting from \u0060ReentrancyGuard\u0060 will make the {nonReentrant} modifier\r\n * available, which can be applied to functions to make sure there are no nested\r\n * (reentrant) calls to them.\r\n *\r\n * Note that because there is a single \u0060nonReentrant\u0060 guard, functions marked as\r\n * \u0060nonReentrant\u0060 may not call one another. This can be worked around by making\r\n * those functions \u0060private\u0060, and then adding \u0060external\u0060 \u0060nonReentrant\u0060 entry\r\n * points to them.\r\n *\r\n * _Since v2.5.0:_ this module is now much more gas efficient, given net gas\r\n * metering changes introduced in the Istanbul hardfork.\r\n */\r\ncontract ReentrancyGuard {\r\n    bool private _notEntered;\r\n\r\n    constructor () internal {\r\n        // Storing an initial non-zero value makes deployment a bit more\r\n        // expensive, but in exchange the refund on every call to nonReentrant\r\n        // will be lower in amount. Since refunds are capped to a percetange of\r\n        // the total transaction\u0027s gas, it is best to keep them low in cases\r\n        // like this one, to increase the likelihood of the full refund coming\r\n        // into effect.\r\n        _notEntered = true;\r\n    }\r\n\r\n    /**\r\n     * @dev Prevents a contract from calling itself, directly or indirectly.\r\n     * Calling a \u0060nonReentrant\u0060 function from another \u0060nonReentrant\u0060\r\n     * function is not supported. It is possible to prevent this from happening\r\n     * by making the \u0060nonReentrant\u0060 function external, and make it call a\r\n     * \u0060private\u0060 function that does the actual work.\r\n     */\r\n    modifier nonReentrant() {\r\n        // On the first call to nonReentrant, _notEntered will be true\r\n        require(_notEntered, \u0022ReentrancyGuard: reentrant call\u0022);\r\n\r\n        // Any calls to nonReentrant after this point will fail\r\n        _notEntered = false;\r\n\r\n        _;\r\n\r\n        // By storing the original value once again, a refund is triggered (see\r\n        // https://eips.ethereum.org/EIPS/eip-2200)\r\n        _notEntered = true;\r\n    }\r\n}\r\n\r\n// File: contracts/PoolsFYI_UniSwapPool_ETH_SETH.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n\r\n\r\n\r\n\r\n\r\n// Interface for ETH_sETH_Addliquidity\r\ninterface UniSwap_Zap_Contract{\r\n    function LetsInvest() external payable;\r\n}\r\n\r\n// Objectives\r\n// - ServiceProvider\u0027s users should be able to send ETH to the UniSwap_ZAP contracts and get the UniTokens and the residual ERC20 tokens\r\n// - ServiceProvider should have the ability to charge a commission, should is choose to do so\r\n// - ServiceProvider should be able to provide a commission rate in basis points\r\n// - ServiceProvider WILL receive its commission from the incomimg UniTokens\r\n// - ServiceProvider WILL have to withdraw its commission tokens separately \r\n\r\n\r\ncontract ServiceProvider_UniSwap_Zap is Ownable, ReentrancyGuard {\r\n    using SafeMath for uint;\r\n\r\n    UniSwap_Zap_Contract public UniSwap_Zap_ContractAddress;\r\n    IERC20 public sETH_TokenContractAddress;\r\n    IERC20 public UniSwapsETHExchangeContractAddress;\r\n    \r\n    address internal ServiceProviderAddress;\r\n\r\n    uint public balance = address(this).balance;\r\n    uint private TotalServiceChargeTokens;\r\n    uint private serviceChargeInBasisPoints = 0;\r\n    \r\n    event TransferredToUser_liquidityTokens_residualsETH(uint, uint);\r\n    event ServiceChargeTokensTransferred(uint);\r\n\r\n    constructor (\r\n        UniSwap_Zap_Contract _UniSwap_Zap_ContractAddress, \r\n        IERC20 _sETH_TokenContractAddress, \r\n        IERC20 _UniSwapsETHExchangeContractAddress, \r\n        address _ServiceProviderAddress) \r\n        public {\r\n        UniSwap_Zap_ContractAddress = _UniSwap_Zap_ContractAddress;\r\n        sETH_TokenContractAddress = _sETH_TokenContractAddress;\r\n        UniSwapsETHExchangeContractAddress = _UniSwapsETHExchangeContractAddress;\r\n        ServiceProviderAddress = _ServiceProviderAddress;\r\n    }\r\n\r\n     // - in relation to the emergency functioning of this contract\r\n    bool private stopped = false;\r\n\r\n    // circuit breaker modifiers\r\n    modifier stopInEmergency {if (!stopped) _;}\r\n    \r\n    \r\n    function toggleContractActive() public onlyOwner {\r\n    stopped = !stopped;\r\n    }\r\n\r\n    \r\n    // should we ever want to change the address of ZapContractAddress\r\n    function set_UniSwap_Zap_ContractAddress(UniSwap_Zap_Contract _new_UniSwap_Zap_ContractAddress) public onlyOwner  {\r\n        UniSwap_Zap_ContractAddress = _new_UniSwap_Zap_ContractAddress;\r\n    }\r\n  \r\n    // should we ever want to change the address of the sETH_TOKEN_ADDRESS Contract\r\n    function set_sETH_TokenContractAddress (IERC20 _new_sETH_TokenContractAddress) public onlyOwner {\r\n        sETH_TokenContractAddress = _new_sETH_TokenContractAddress;\r\n    }\r\n\r\n    // should we ever want to change the address of the _UniSwap sETHExchange Contract Address\r\n    function set_UniSwapsETHExchangeContractAddress (IERC20 _new_UniSwapsETHExchangeContractAddress) public onlyOwner {\r\n        UniSwapsETHExchangeContractAddress = _new_UniSwapsETHExchangeContractAddress;\r\n    }\r\n\r\n \r\n    // to get the ServiceProviderAddress, only the Owner can call this fx\r\n    function get_ServiceProviderAddress() public view onlyOwner returns (address) {\r\n        return ServiceProviderAddress;\r\n    }\r\n    \r\n    // to set the ServiceProviderAddress, only the Owner can call this fx\r\n    function set_ServiceProviderAddress (address _new_ServiceProviderAddress) public onlyOwner  {\r\n        ServiceProviderAddress = _new_ServiceProviderAddress;\r\n    }\r\n\r\n    // to find out the serviceChargeRate, only the Owner can call this fx\r\n    function get_serviceChargeRate () public view onlyOwner returns (uint) {\r\n        return serviceChargeInBasisPoints;\r\n    }\r\n    \r\n    // should the ServiceProvider ever want to change the Service Charge rate, only the Owner can call this fx\r\n    function set_serviceChargeRate (uint _new_serviceChargeInBasisPoints) public onlyOwner {\r\n        require (_new_serviceChargeInBasisPoints \u003C= 10000, \u0022Setting Service Charge more than 100%\u0022);\r\n        serviceChargeInBasisPoints = _new_serviceChargeInBasisPoints;\r\n    }\r\n\r\n\r\n    function LetsInvest() public payable stopInEmergency nonReentrant returns (bool) {\r\n        UniSwap_Zap_ContractAddress.LetsInvest.value(msg.value)();\r\n        \r\n\r\n        // finding out the UniTokens received and the residual sETH Tokens Received\r\n        uint sETHLiquidityTokens = UniSwapsETHExchangeContractAddress.balanceOf(address(this));\r\n        uint residualsETHHoldings = sETH_TokenContractAddress.balanceOf(address(this));\r\n\r\n        // Adjusting for ServiceCharge\r\n        uint ServiceChargeTokens = SafeMath.div(SafeMath.mul(sETHLiquidityTokens,serviceChargeInBasisPoints),10000);\r\n        TotalServiceChargeTokens = TotalServiceChargeTokens \u002B ServiceChargeTokens;\r\n        \r\n\r\n        // Sending Back the Balance LiquityTokens and residual sETH Tokens to user\r\n        uint UserLiquidityTokens = SafeMath.sub(sETHLiquidityTokens,ServiceChargeTokens);\r\n        require(UniSwapsETHExchangeContractAddress.transfer(msg.sender, UserLiquidityTokens), \u0022Failure to send Liquidity Tokens to User\u0022);\r\n        require(sETH_TokenContractAddress.transfer(msg.sender, residualsETHHoldings), \u0022Failure to send residual sETH holdings\u0022);\r\n        emit TransferredToUser_liquidityTokens_residualsETH(UserLiquidityTokens, residualsETHHoldings);\r\n        return true;\r\n    }\r\n\r\n\r\n    // to find out the totalServiceChargeTokens, only the Owner can call this fx\r\n    function get_TotalServiceChargeTokens() public view onlyOwner returns (uint) {\r\n        return TotalServiceChargeTokens;\r\n    }\r\n    \r\n    \r\n    function withdrawServiceChargeTokens(uint _amountInUnits) public onlyOwner {\r\n        require(_amountInUnits \u003C= TotalServiceChargeTokens, \u0022You are asking for more than what you have earned\u0022);\r\n        TotalServiceChargeTokens = SafeMath.sub(TotalServiceChargeTokens,_amountInUnits);\r\n        require(UniSwapsETHExchangeContractAddress.transfer(ServiceProviderAddress, _amountInUnits), \u0022Failure to send ServiceChargeTokens\u0022);\r\n        emit ServiceChargeTokensTransferred(_amountInUnits);\r\n    }\r\n\r\n\r\n    // Should there be a need to withdraw any other ERC20 token\r\n    function withdrawAnyOtherERC20Token(IERC20 _targetContractAddress) public onlyOwner {\r\n        uint OtherTokenBalance = _targetContractAddress.balanceOf(address(this));\r\n        _targetContractAddress.transfer(_owner, OtherTokenBalance);\r\n    }\r\n    \r\n\r\n    // incase of half-way error\r\n    function withdrawsETH() public onlyOwner {\r\n        uint StucksETHHoldings = sETH_TokenContractAddress.balanceOf(address(this));\r\n        sETH_TokenContractAddress.transfer(_owner, StucksETHHoldings);\r\n    }\r\n    \r\n    function withdrawsETHLiquityTokens() public onlyOwner {\r\n        uint StucksETHLiquityTokens = UniSwapsETHExchangeContractAddress.balanceOf(address(this));\r\n        UniSwapsETHExchangeContractAddress.transfer(_owner, StucksETHLiquityTokens);\r\n    }\r\n\r\n    \r\n    // fx in relation to ETH held by the contract sent by the owner\r\n    \r\n    // - this function lets you deposit ETH into this wallet\r\n    function depositETH() public payable onlyOwner {\r\n        balance \u002B= msg.value;\r\n    }\r\n    \r\n    // - fallback function let you / anyone send ETH to this wallet without the need to call any function\r\n    function() external payable {\r\n        if (msg.sender == _owner) {\r\n            depositETH();\r\n        } else {\r\n            LetsInvest();\r\n        }\r\n    }\r\n    \r\n    // - to withdraw any ETH balance sitting in the contract\r\n    function withdraw() public onlyOwner {\r\n        _owner.transfer(address(this).balance);\r\n    }\r\n\r\n\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract UniSwap_Zap_Contract\u0022,\u0022name\u0022:\u0022_UniSwap_Zap_ContractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022_sETH_TokenContractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022_UniSwapsETHExchangeContractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_ServiceProviderAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ServiceChargeTokensTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022TransferredToUser_liquidityTokens_residualsETH\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022LetsInvest\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022UniSwap_Zap_ContractAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract UniSwap_Zap_Contract\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022UniSwapsETHExchangeContractAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022balance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022depositETH\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022get_ServiceProviderAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022get_TotalServiceChargeTokens\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022get_serviceChargeRate\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sETH_TokenContractAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_new_ServiceProviderAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022set_ServiceProviderAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract UniSwap_Zap_Contract\u0022,\u0022name\u0022:\u0022_new_UniSwap_Zap_ContractAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022set_UniSwap_Zap_ContractAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022_new_UniSwapsETHExchangeContractAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022set_UniSwapsETHExchangeContractAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022_new_sETH_TokenContractAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022set_sETH_TokenContractAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_new_serviceChargeInBasisPoints\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022set_serviceChargeRate\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022toggleContractActive\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022_targetContractAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022withdrawAnyOtherERC20Token\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amountInUnits\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawServiceChargeTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdrawsETH\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdrawsETHLiquityTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"ServiceProvider_UniSwap_Zap","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000d3eba712988df0f8a7e5073719a40ce4cbf60b330000000000000000000000005e74c9036fb86bd7ecdcb084a0673efc32ea31cb000000000000000000000000e9cf7887b93150d4f2da7dfc6d502b216438f244000000000000000000000000bf6b745307a874e9330440a4c1ecff369fd9d680","Library":"","SwarmSource":"bzzr://e6de35af6be7037308d4039300346afe00993b4f8e075b53660d52c21503d327"}]