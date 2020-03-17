[{"SourceCode":"// File: contracts/interfaces/CERC20.sol\r\n\r\npragma solidity ^0.5.2;\r\n\r\ninterface CERC20 {\r\n  function mint(uint256 mintAmount) external returns (uint256);\r\n  function redeem(uint256 redeemTokens) external returns (uint256);\r\n  function exchangeRateStored() external view returns (uint256);\r\n  function supplyRatePerBlock() external view returns (uint256);\r\n\r\n  function borrowRatePerBlock() external view returns (uint256);\r\n  function totalReserves() external view returns (uint256);\r\n  function getCash() external view returns (uint256);\r\n  function totalBorrows() external view returns (uint256);\r\n  function reserveFactorMantissa() external view returns (uint256);\r\n}\r\n\r\n// File: contracts/interfaces/iERC20.sol\r\n\r\npragma solidity ^0.5.2;\r\n\r\ninterface iERC20 {\r\n  function mint(\r\n    address receiver,\r\n    uint256 depositAmount)\r\n    external\r\n    returns (uint256 mintAmount);\r\n\r\n  function burn(\r\n    address receiver,\r\n    uint256 burnAmount)\r\n    external\r\n    returns (uint256 loanAmountPaid);\r\n\r\n  function tokenPrice()\r\n    external\r\n    view\r\n    returns (uint256 price);\r\n\r\n  function supplyInterestRate()\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function rateMultiplier()\r\n    external\r\n    view\r\n    returns (uint256);\r\n  function baseRate()\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function borrowInterestRate()\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function totalAssetBorrow()\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function totalAssetSupply()\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function nextSupplyInterestRate(uint256)\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function nextBorrowInterestRate(uint256)\r\n    external\r\n    view\r\n    returns (uint256);\r\n  function nextLoanInterestRate(uint256)\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function claimLoanToken()\r\n    external\r\n    returns (uint256 claimedAmount);\r\n\r\n  /* function burnToEther(\r\n    address receiver,\r\n    uint256 burnAmount)\r\n    external\r\n    returns (uint256 loanAmountPaid);\r\n\r\n\r\n  function supplyInterestRate()\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function assetBalanceOf(\r\n    address _owner)\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function claimLoanToken()\r\n    external\r\n    returns (uint256 claimedAmount); */\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\r\n * the optional functions; to access them see \u0060ERC20Detailed\u0060.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from the caller\u0027s account to \u0060recipient\u0060.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a \u0060Transfer\u0060 event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that \u0060spender\u0060 will be\r\n     * allowed to spend on behalf of \u0060owner\u0060 through \u0060transferFrom\u0060. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when \u0060approve\u0060 or \u0060transferFrom\u0060 are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * \u003E Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an \u0060Approval\u0060 event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from \u0060sender\u0060 to \u0060recipient\u0060 using the\r\n     * allowance mechanism. \u0060amount\u0060 is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a \u0060Transfer\u0060 event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when \u0060value\u0060 tokens are moved from one account (\u0060from\u0060) to\r\n     * another (\u0060to\u0060).\r\n     *\r\n     * Note that \u0060value\u0060 may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a \u0060spender\u0060 for an \u0060owner\u0060 is set by\r\n     * a call to \u0060approve\u0060. \u0060value\u0060 is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/math/SafeMath.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * \u0060SafeMath\u0060 restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060\u002B\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a, \u0022SafeMath: subtraction overflow\u0022);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060*\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, \u0022SafeMath: division by zero\u0022);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0, \u0022SafeMath: modulo by zero\u0022);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n// File: contracts/IdleHelp.sol\r\n\r\npragma solidity ^0.5.2;\r\n\r\n\r\n\r\n\r\n\r\nlibrary IdleHelp {\r\n  using SafeMath for uint256;\r\n  function getPriceInToken(address cToken, address iToken, address bestToken, uint256 totalSupply, uint256 poolSupply)\r\n    public view\r\n    returns (uint256 tokenPrice) {\r\n      // 1Token = net_asset_value / total_Token_liquidity\r\n      // net_asset_value = (rate of 1(cToken || iToken) in underlying_Token) * balanceOf((cToken || iToken))\r\n      uint256 navPool;\r\n      uint256 price;\r\n\r\n      // rate\r\n      if (bestToken == cToken) {\r\n        // exchangeRateStored is the rate (in wei, 8 decimals) of 1cDAI in DAI * 10**18\r\n        price = CERC20(cToken).exchangeRateStored(); // 202487304197710837666727644 -\u003E\r\n      } else {\r\n        price = iERC20(iToken).tokenPrice(); // eg 1001495070730287403 -\u003E 1iToken in wei = 1001495070730287403 Token\r\n      }\r\n      navPool = price.mul(poolSupply); // eg 43388429749999990000 in DAI\r\n      tokenPrice = navPool.div(totalSupply); // idleToken price in token wei\r\n  }\r\n  function getAPRs(address cToken, address iToken, uint256 blocksInAYear)\r\n    public view\r\n    returns (uint256 cApr, uint256 iApr) {\r\n      uint256 cRate = CERC20(cToken).supplyRatePerBlock(); // interest % per block\r\n      cApr = cRate.mul(blocksInAYear).mul(100);\r\n      iApr = iERC20(iToken).supplyInterestRate(); // APR in wei 18 decimals\r\n  }\r\n  function getBestRateToken(address cToken, address iToken, uint256 blocksInAYear)\r\n    public view\r\n    returns (address bestRateToken, uint256 bestRate, uint256 worstRate) {\r\n      (uint256 cApr, uint256 iApr) = getAPRs(cToken, iToken, blocksInAYear);\r\n      bestRateToken = cToken;\r\n      bestRate = cApr;\r\n      worstRate = iApr;\r\n      if (iApr \u003E cApr) {\r\n        worstRate = cApr;\r\n        bestRate = iApr;\r\n        bestRateToken = iToken;\r\n      }\r\n  }\r\n  function rebalanceCheck(address cToken, address iToken, address bestToken, uint256 blocksInAYear, uint256 minRateDifference)\r\n    public view\r\n    returns (bool shouldRebalance, address bestTokenAddr) {\r\n      shouldRebalance = false;\r\n\r\n      uint256 _bestRate;\r\n      uint256 _worstRate;\r\n      (bestTokenAddr, _bestRate, _worstRate) = getBestRateToken(cToken, iToken, blocksInAYear);\r\n      if (\r\n          bestToken == address(0) ||\r\n          (bestTokenAddr != bestToken \u0026\u0026 (_worstRate.add(minRateDifference) \u003C _bestRate))) {\r\n        shouldRebalance = true;\r\n        return (shouldRebalance, bestTokenAddr);\r\n      }\r\n\r\n      return (shouldRebalance, bestTokenAddr);\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022cToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022iToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022bestToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022totalSupply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022poolSupply\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getPriceInToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022tokenPrice\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022cToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022iToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022blocksInAYear\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getBestRateToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022bestRateToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022bestRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022worstRate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022cToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022iToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022bestToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022blocksInAYear\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022minRateDifference\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022rebalanceCheck\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022shouldRebalance\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022bestTokenAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022cToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022iToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022blocksInAYear\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getAPRs\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022cApr\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022iApr\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"IdleHelp","CompilerVersion":"v0.5.2\u002Bcommit.1df8f40c","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://c294b7508acd71d06c738d49a7d9e9047f102c54fe89ebc393a7e80b2d3b8bc2"}]