[{"SourceCode":"pragma solidity ^0.5.8;\r\n\r\n\r\n/**\r\n * @title Math\r\n * @dev Assorted math operations\r\n */\r\nlibrary Math {\r\n    /**\r\n     * @dev Returns the largest of two numbers.\r\n     */\r\n    function max(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a \u003E= b ? a : b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the smallest of two numbers.\r\n     */\r\n    function min(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a \u003C b ? a : b;\r\n    }\r\n\r\n    /**\r\n     * @dev Calculates the average of two numbers. Since these are integers,\r\n     * averages of an even and odd number cannot be represented, and will be\r\n     * rounded down.\r\n     */\r\n    function average(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // (a \u002B b) / 2 can overflow, so we distribute\r\n        return (a / 2) \u002B (b / 2) \u002B ((a % 2 \u002B b % 2) / 2);\r\n    }\r\n}\r\n\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Unsigned math operations with safety checks that revert on error\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Multiplies two unsigned integers, reverts on overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Adds two unsigned integers, reverts on overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),\r\n     * reverts when dividing by zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n     * account.\r\n     */\r\n    constructor () internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @return the address of the owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner());\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @return true if \u0060msg.sender\u0060 is the owner of the contract.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return msg.sender == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to relinquish control of the contract.\r\n     * It will not be possible to call the functions with the \u0060onlyOwner\u0060\r\n     * modifier anymore.\r\n     * @notice Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ninterface IERC20 {\r\n  function totalSupply() external view returns (uint256);\r\n\r\n  function balanceOf(address who) external view returns (uint256);\r\n\r\n  function allowance(address owner, address spender)\r\n    external view returns (uint256);\r\n\r\n  function transfer(address to, uint256 value) external returns (bool);\r\n\r\n  function approve(address spender, uint256 value)\r\n    external returns (bool);\r\n\r\n  function transferFrom(address from, address to, uint256 value)\r\n    external returns (bool);\r\n\r\n  event Transfer(\r\n    address indexed from,\r\n    address indexed to,\r\n    uint256 value\r\n  );\r\n\r\n  event Approval(\r\n    address indexed owner,\r\n    address indexed spender,\r\n    uint256 value\r\n  );\r\n}\r\n\r\n\r\n/**\r\n * @title SafeERC20\r\n * @dev Wrappers around ERC20 operations that throw on failure.\r\n * To use this library you can add a \u0060using SafeERC20 for ERC20;\u0060 statement to your contract,\r\n * which allows you to call the safe operations as \u0060token.safeTransfer(...)\u0060, etc.\r\n */\r\nlibrary SafeERC20 {\r\n    using SafeMath for uint256;\r\n\r\n    function safeTransfer(IERC20 token, address to, uint256 value) internal {\r\n        require(token.transfer(to, value));\r\n    }\r\n\r\n    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {\r\n        require(token.transferFrom(from, to, value));\r\n    }\r\n\r\n    function safeApprove(IERC20 token, address spender, uint256 value) internal {\r\n        // safeApprove should only be called when setting an initial allowance,\r\n        // or when resetting it to zero. To increase and decrease it, use\r\n        // \u0027safeIncreaseAllowance\u0027 and \u0027safeDecreaseAllowance\u0027\r\n        require((value == 0) || (token.allowance(msg.sender, spender) == 0));\r\n        require(token.approve(spender, value));\r\n    }\r\n\r\n    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {\r\n        uint256 newAllowance = token.allowance(address(this), spender).add(value);\r\n        require(token.approve(spender, newAllowance));\r\n    }\r\n\r\n    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {\r\n        uint256 newAllowance = token.allowance(address(this), spender).sub(value);\r\n        require(token.approve(spender, newAllowance));\r\n    }\r\n}\r\n\r\n\r\n/**\r\n * @title TokenSale\r\n */\r\ncontract TokenSale is Ownable {\r\n    using SafeMath for uint256;\r\n    using SafeERC20 for IERC20;\r\n\r\n    // token for sale\r\n    IERC20 public saleToken;\r\n\r\n    // address where funds are collected\r\n    address public fundCollector;\r\n\r\n    // address where has tokens to sell\r\n    address public tokenWallet;\r\n\r\n    // use whitelist[user] to get whether the user was allowed to buy\r\n    mapping(address =\u003E bool) public whitelist;\r\n\r\n    // exchangeable token\r\n    struct ExToken {\r\n        bool accepted;\r\n        uint256 rate;\r\n    }\r\n\r\n    // exchangeable tokens\r\n    mapping(address =\u003E ExToken) private _exTokens;\r\n\r\n    // bonus threshold\r\n    uint256 public bonusThreshold;\r\n\r\n    // tier-1 bonus\r\n    uint256 public tierOneBonusTime;\r\n    uint256 public tierOneBonusRate;\r\n\r\n    // tier-2 bonus\r\n    uint256 public tierTwoBonusTime;\r\n    uint256 public tierTwoBonusRate;\r\n\r\n    /**\r\n     * @param setter who set fund collector\r\n     * @param fundCollector address of fund collector\r\n     */\r\n    event FundCollectorSet(\r\n        address indexed setter,\r\n        address indexed fundCollector\r\n    );\r\n\r\n    /**\r\n     * @param setter who set sale token\r\n     * @param saleToken address of sale token\r\n     */\r\n    event SaleTokenSet(\r\n        address indexed setter,\r\n        address indexed saleToken\r\n    );\r\n\r\n    /**\r\n     * @param setter who set token wallet\r\n     * @param tokenWallet address of token wallet\r\n     */\r\n    event TokenWalletSet(\r\n        address indexed setter,\r\n        address indexed tokenWallet\r\n    );\r\n\r\n    /**\r\n     * @param setter who set bonus threshold\r\n     * @param bonusThreshold exceed the threshold will get bonus\r\n     * @param tierOneBonusTime tier one bonus timestamp\r\n     * @param tierOneBonusRate tier one bonus rate\r\n     * @param tierTwoBonusTime tier two bonus timestamp\r\n     * @param tierTwoBonusRate tier two bonus rate\r\n     */\r\n    event BonusConditionsSet(\r\n        address indexed setter,\r\n        uint256 bonusThreshold,\r\n        uint256 tierOneBonusTime,\r\n        uint256 tierOneBonusRate,\r\n        uint256 tierTwoBonusTime,\r\n        uint256 tierTwoBonusRate\r\n    );\r\n\r\n    /**\r\n     * @param setter who set the whitelist\r\n     * @param user address of the user\r\n     * @param allowed whether the user allowed to buy\r\n     */\r\n    event WhitelistSet(\r\n        address indexed setter,\r\n        address indexed user,\r\n        bool allowed\r\n    );\r\n\r\n    /**\r\n     * event for logging exchangeable token updates\r\n     * @param setter who set the exchangeable token\r\n     * @param exToken the exchangeable token\r\n     * @param accepted whether the exchangeable token was accepted\r\n     * @param rate exchange rate of the exchangeable token\r\n     */\r\n    event ExTokenSet(\r\n        address indexed setter,\r\n        address indexed exToken,\r\n        bool accepted,\r\n        uint256 rate\r\n    );\r\n\r\n    /**\r\n     * event for token purchase logging\r\n     * @param buyer address of token buyer\r\n     * @param exToken address of the exchangeable token\r\n     * @param exTokenAmount amount of the exchangeable tokens\r\n     * @param amount amount of tokens purchased\r\n     */\r\n    event TokensPurchased(\r\n        address indexed buyer,\r\n        address indexed exToken,\r\n        uint256 exTokenAmount,\r\n        uint256 amount\r\n    );\r\n\r\n    /**\r\n     * @param fundCollector address where collected funds will be forwarded to\r\n     * @param saleToken address of the token being sold\r\n     * @param tokenWallet address of wallet has tokens to sell\r\n     */\r\n    constructor (\r\n        address fundCollector,\r\n        address saleToken,\r\n        address tokenWallet,\r\n        uint256 bonusThreshold,\r\n        uint256 tierOneBonusTime,\r\n        uint256 tierOneBonusRate,\r\n        uint256 tierTwoBonusTime,\r\n        uint256 tierTwoBonusRate\r\n    )\r\n        public\r\n    {\r\n        _setFundCollector(fundCollector);\r\n        _setSaleToken(saleToken);\r\n        _setTokenWallet(tokenWallet);\r\n        _setBonusConditions(\r\n            bonusThreshold,\r\n            tierOneBonusTime,\r\n            tierOneBonusRate,\r\n            tierTwoBonusTime,\r\n            tierTwoBonusRate\r\n        );\r\n\r\n    }\r\n\r\n    /**\r\n     * @param fundCollector address of the fund collector\r\n     */\r\n    function setFundCollector(address fundCollector) external onlyOwner {\r\n        _setFundCollector(fundCollector);\r\n    }\r\n\r\n    /**\r\n     * @param collector address of the fund collector\r\n     */\r\n    function _setFundCollector(address collector) private {\r\n        require(collector != address(0), \u0022fund collector cannot be 0x0\u0022);\r\n        fundCollector = collector;\r\n        emit FundCollectorSet(msg.sender, collector);\r\n    }\r\n\r\n    /**\r\n     * @param saleToken address of the sale token\r\n     */\r\n    function setSaleToken(address saleToken) external onlyOwner {\r\n        _setSaleToken(saleToken);\r\n    }\r\n\r\n    /**\r\n     * @param token address of the sale token\r\n     */\r\n    function _setSaleToken(address token) private {\r\n        require(token != address(0), \u0022sale token cannot be 0x0\u0022);\r\n        saleToken = IERC20(token);\r\n        emit SaleTokenSet(msg.sender, token);\r\n    }\r\n\r\n    /**\r\n     * @param tokenWallet address of the token wallet\r\n     */\r\n    function setTokenWallet(address tokenWallet) external onlyOwner {\r\n        _setTokenWallet(tokenWallet);\r\n    }\r\n\r\n    /**\r\n     * @param wallet address of the token wallet\r\n     */\r\n    function _setTokenWallet(address wallet) private {\r\n        require(wallet != address(0), \u0022token wallet cannot be 0x0\u0022);\r\n        tokenWallet = wallet;\r\n        emit TokenWalletSet(msg.sender, wallet);\r\n    }\r\n\r\n    /**\r\n     * @param threshold exceed the threshold will get bonus\r\n     * @param t1BonusTime before t1 bonus timestamp will use t1 bonus rate\r\n     * @param t1BonusRate tier-1 bonus rate\r\n     * @param t2BonusTime before t2 bonus timestamp will use t2 bonus rate\r\n     * @param t2BonusRate tier-2 bonus rate\r\n     */\r\n    function setBonusConditions(\r\n        uint256 threshold,\r\n        uint256 t1BonusTime,\r\n        uint256 t1BonusRate,\r\n        uint256 t2BonusTime,\r\n        uint256 t2BonusRate\r\n    )\r\n        external\r\n        onlyOwner\r\n    {\r\n        _setBonusConditions(\r\n            threshold,\r\n            t1BonusTime,\r\n            t1BonusRate,\r\n            t2BonusTime,\r\n            t2BonusRate\r\n        );\r\n    }\r\n\r\n    /**\r\n     * @param threshold exceed the threshold will get bonus\r\n     */\r\n    function _setBonusConditions(\r\n        uint256 threshold,\r\n        uint256 t1BonusTime,\r\n        uint256 t1BonusRate,\r\n        uint256 t2BonusTime,\r\n        uint256 t2BonusRate\r\n    )\r\n        private\r\n        onlyOwner\r\n    {\r\n        require(threshold \u003E 0,\u0022 threshold cannot be zero.\u0022);\r\n        require(t1BonusTime \u003C t2BonusTime, \u0022invalid bonus time\u0022);\r\n        require(t1BonusRate \u003E= t2BonusRate, \u0022invalid bonus rate\u0022);\r\n\r\n        bonusThreshold = threshold;\r\n        tierOneBonusTime = t1BonusTime;\r\n        tierOneBonusRate = t1BonusRate;\r\n        tierTwoBonusTime = t2BonusTime;\r\n        tierTwoBonusRate = t2BonusRate;\r\n\r\n        emit BonusConditionsSet(\r\n            msg.sender,\r\n            threshold,\r\n            t1BonusTime,\r\n            t1BonusRate,\r\n            t2BonusTime,\r\n            t2BonusRate\r\n        );\r\n    }\r\n\r\n    /**\r\n     * @notice set allowed to ture to add the user into the whitelist\r\n     * @notice set allowed to false to remove the user from the whitelist\r\n     * @param user address of user\r\n     * @param allowed whether allow the user to deposit/withdraw or not\r\n     */\r\n    function setWhitelist(address user, bool allowed) external onlyOwner {\r\n        whitelist[user] = allowed;\r\n        emit WhitelistSet(msg.sender, user, allowed);\r\n    }\r\n\r\n    /**\r\n     * @dev checks the amount of tokens left in the allowance.\r\n     * @return amount of tokens left in the allowance\r\n     */\r\n    function remainingTokens() external view returns (uint256) {\r\n        return Math.min(\r\n            saleToken.balanceOf(tokenWallet),\r\n            saleToken.allowance(tokenWallet, address(this))\r\n        );\r\n    }\r\n\r\n    /**\r\n     * @param exToken address of the exchangeable token\r\n     * @param accepted true: accepted; false: rejected\r\n     * @param rate exchange rate\r\n     */\r\n    function setExToken(\r\n        address exToken,\r\n        bool accepted,\r\n        uint256 rate\r\n    )\r\n        external\r\n        onlyOwner\r\n    {\r\n        _exTokens[exToken].accepted = accepted;\r\n        _exTokens[exToken].rate = rate;\r\n        emit ExTokenSet(msg.sender, exToken, accepted, rate);\r\n    }\r\n\r\n    /**\r\n     * @param exToken address of the exchangeable token\r\n     * @return whether the exchangeable token is accepted or not\r\n     */\r\n    function accepted(address exToken) public view returns (bool) {\r\n        return _exTokens[exToken].accepted;\r\n    }\r\n\r\n    /**\r\n     * @param exToken address of the exchangeale token\r\n     * @return amount of sale token a buyer gets per exchangeable token\r\n     */\r\n    function rate(address exToken) external view returns (uint256) {\r\n        return _exTokens[exToken].rate;\r\n    }\r\n\r\n    /**\r\n     * @dev get exchangeable sale token amount\r\n     * @param exToken address of the exchangeable token\r\n     * @param amount amount of the exchangeable token (how much to pay)\r\n     * @return purchased sale token amount\r\n     */\r\n    function exchangeableAmounts(\r\n        address exToken,\r\n        uint256 amount\r\n    )\r\n        external\r\n        view\r\n        returns (uint256)\r\n    {\r\n        return _getTokenAmount(exToken, amount);\r\n    }\r\n\r\n    /**\r\n     * @dev buy tokens\r\n     * @dev buyer must be in whitelist\r\n     * @param exToken address of the exchangeable token\r\n     * @param amount amount of the exchangeable token\r\n     */\r\n    function buyTokens(\r\n        address exToken,\r\n        uint256 amount\r\n    )\r\n        external\r\n    {\r\n        require(_exTokens[exToken].accepted, \u0022token was not accepted\u0022);\r\n        require(amount != 0, \u0022amount cannot 0\u0022);\r\n        require(whitelist[msg.sender], \u0022buyer must be in whitelist\u0022);\r\n        // calculate token amount to sell\r\n        uint256 tokens = _getTokenAmount(exToken, amount);\r\n        require(tokens \u003E= 10**19, \u0022at least buy 10 tokens per purchase\u0022);\r\n        _forwardFunds(exToken, amount);\r\n        _processPurchase(msg.sender, tokens);\r\n        emit TokensPurchased(msg.sender, exToken, amount, tokens);\r\n    }\r\n\r\n    /**\r\n     * @dev buyer transfers amount of the exchangeable token to fund collector\r\n     * @param exToken address of the exchangeable token\r\n     * @param amount amount of the exchangeable token will send to fund collector\r\n     */\r\n    function _forwardFunds(address exToken, uint256 amount) private {\r\n        IERC20(exToken).safeTransferFrom(msg.sender, fundCollector, amount);\r\n    }\r\n\r\n    /**\r\n     * @dev calculated purchased sale token amount\r\n     * @param exToken address of the exchangeable token\r\n     * @param amount amount of the exchangeable token (how much to pay)\r\n     * @return amount of purchased sale token\r\n     */\r\n    function _getTokenAmount(\r\n        address exToken,\r\n        uint256 amount\r\n    )\r\n        private\r\n        view\r\n        returns (uint256)\r\n    {\r\n        // round down value (v) by multiple (m) = (v / m) * m\r\n        uint256 value = amount\r\n            .mul(_exTokens[exToken].rate)\r\n            .div(1000000000000000000)\r\n            .mul(1000000000000000000);\r\n        return _applyBonus(value);\r\n    }\r\n\r\n    function _applyBonus(\r\n        uint256 amount\r\n    )\r\n        private\r\n        view\r\n        returns (uint256)\r\n    {\r\n        if (amount \u003C bonusThreshold) {\r\n            return amount;\r\n        }\r\n\r\n        if (block.timestamp \u003C= tierOneBonusTime) {\r\n            return amount.mul(tierOneBonusRate).div(100);\r\n        } else if (block.timestamp \u003C= tierTwoBonusTime) {\r\n            return amount.mul(tierTwoBonusRate).div(100);\r\n        } else {\r\n            return amount;\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev transfer sale token amounts from token wallet to beneficiary\r\n     * @param beneficiary purchased tokens will transfer to this address\r\n     * @param tokenAmount purchased token amount\r\n     */\r\n    function _processPurchase(\r\n        address beneficiary,\r\n        uint256 tokenAmount\r\n    )\r\n        private\r\n    {\r\n        saleToken.safeTransferFrom(tokenWallet, beneficiary, tokenAmount);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022exToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022buyTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022exToken\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022rate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022threshold\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022t1BonusTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022t1BonusRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022t2BonusTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022t2BonusRate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setBonusConditions\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022exToken\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022accepted\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tierTwoBonusTime\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tierOneBonusTime\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022fundCollector\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022fundCollector\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setFundCollector\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022allowed\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setWhitelist\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tierTwoBonusRate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tierOneBonusRate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022whitelist\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022saleToken\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setSaleToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenWallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setTokenWallet\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022bonusThreshold\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022remainingTokens\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tokenWallet\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022saleToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022exToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022accepted\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022rate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setExToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022exToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022exchangeableAmounts\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022fundCollector\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022saleToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokenWallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022bonusThreshold\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022tierOneBonusTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022tierOneBonusRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022tierTwoBonusTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022tierTwoBonusRate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022setter\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022fundCollector\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022FundCollectorSet\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022setter\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022saleToken\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022SaleTokenSet\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022setter\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenWallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022TokenWalletSet\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022setter\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022bonusThreshold\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tierOneBonusTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tierOneBonusRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tierTwoBonusTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tierTwoBonusRate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022BonusConditionsSet\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022setter\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022allowed\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022WhitelistSet\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022setter\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022exToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022accepted\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022rate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ExTokenSet\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022buyer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022exToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022exTokenAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022TokensPurchased\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"TokenSale","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"00000000000000000000000023a03721afdc75a1879d6e04a5275bdceebe28fb0000000000000000000000001bb7c7f703ce521fa68524286d6a6d177741cd92000000000000000000000000997c031cde0d82ea7b2f43404167327be936309e00000000000000000000000000000000000000000000021e19e0c9bab2400000000000000000000000000000000000000000000000000000000000005d6a9980000000000000000000000000000000000000000000000000000000000000006e000000000000000000000000000000000000000000000000000000005e0b70800000000000000000000000000000000000000000000000000000000000000069","Library":"","SwarmSource":"bzzr://aeb685b9edab8056d261a3fcbb5391486951799b039333f2742692fbf5a814bc"}]