[{"SourceCode":"// File: contracts/IAllocationStrategy.sol\r\n\r\npragma solidity ^0.5.8;\r\n\r\n/**\r\n * @notice Allocation strategy for assets.\r\n *         - It invests the underlying assets into some yield generating contracts,\r\n *           usually lending contracts, in return it gets new assets aka. saving assets.\r\n *         - Sainv assets can be redeemed back to the underlying assets plus interest any time.\r\n */\r\ninterface IAllocationStrategy {\r\n\r\n    /**\r\n     * @notice Underlying asset for the strategy\r\n     * @return address Underlying asset address\r\n     */\r\n    function underlying() external view returns (address);\r\n\r\n    /**\r\n     * @notice Calculates the exchange rate from the underlying to the saving assets\r\n     * @return uint256 Calculated exchange rate scaled by 1e18\r\n     */\r\n    function exchangeRateStored() external view returns (uint256);\r\n\r\n    /**\r\n      * @notice Applies accrued interest to all savings\r\n      * @dev This should calculates interest accrued from the last checkpointed\r\n      *      block up to the current block and writes new checkpoint to storage.\r\n      * @return bool success(true) or failure(false)\r\n      */\r\n    function accrueInterest() external returns (bool);\r\n\r\n    /**\r\n     * @notice Sender supplies underlying assets into the market and receives saving assets in exchange\r\n     * @dev Interst shall be accrued\r\n     * @param investAmount The amount of the underlying asset to supply\r\n     * @return uint256 Amount of saving assets created\r\n     */\r\n    function investUnderlying(uint256 investAmount) external returns (uint256);\r\n\r\n    /**\r\n     * @notice Sender redeems saving assets in exchange for a specified amount of underlying asset\r\n     * @dev Interst shall be accrued\r\n     * @param redeemAmount The amount of underlying to redeem\r\n     * @return uint256 Amount of saving assets burned\r\n     */\r\n    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);\r\n\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/ownership/Ownable.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * \u0060onlyOwner\u0060, which can be aplied to your functions to restrict their use to\r\n * the owner.\r\n */\r\ncontract Ownable {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the caller is the current owner.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return msg.sender == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * \u0060onlyOwner\u0060 functions anymore. Can only be called by the current owner.\r\n     *\r\n     * \u003E Note: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\r\n * the optional functions; to access them see \u0060ERC20Detailed\u0060.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from the caller\u0027s account to \u0060recipient\u0060.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a \u0060Transfer\u0060 event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that \u0060spender\u0060 will be\r\n     * allowed to spend on behalf of \u0060owner\u0060 through \u0060transferFrom\u0060. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when \u0060approve\u0060 or \u0060transferFrom\u0060 are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * \u003E Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an \u0060Approval\u0060 event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from \u0060sender\u0060 to \u0060recipient\u0060 using the\r\n     * allowance mechanism. \u0060amount\u0060 is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a \u0060Transfer\u0060 event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when \u0060value\u0060 tokens are moved from one account (\u0060from\u0060) to\r\n     * another (\u0060to\u0060).\r\n     *\r\n     * Note that \u0060value\u0060 may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a \u0060spender\u0060 for an \u0060owner\u0060 is set by\r\n     * a call to \u0060approve\u0060. \u0060value\u0060 is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n// File: compound/contracts/CErc20Interface.sol\r\n\r\npragma solidity \u003E=0.4.21 \u003C0.6.0;\r\n\r\n// converted from ethereum/contracts/compound/abi/CErc20.json\r\ninterface CErc20Interface {\r\n\r\n    function name() external view returns (\r\n        string memory\r\n    );\r\n\r\n    function approve(\r\n        address spender,\r\n        uint256 amount\r\n    ) external returns (\r\n        bool\r\n    );\r\n\r\n    function repayBorrow(\r\n        uint256 repayAmount\r\n    ) external returns (\r\n        uint256\r\n    );\r\n\r\n    function reserveFactorMantissa() external view returns (\r\n        uint256\r\n    );\r\n\r\n    function borrowBalanceCurrent(\r\n        address account\r\n    ) external returns (\r\n        uint256\r\n    );\r\n\r\n    function totalSupply() external view returns (\r\n        uint256\r\n    );\r\n\r\n    function exchangeRateStored() external view returns (\r\n        uint256\r\n    );\r\n\r\n    function transferFrom(\r\n        address src,\r\n        address dst,\r\n        uint256 amount\r\n    ) external returns (\r\n        bool\r\n    );\r\n\r\n    function repayBorrowBehalf(\r\n        address borrower,\r\n        uint256 repayAmount\r\n    ) external returns (\r\n        uint256\r\n    );\r\n\r\n    function pendingAdmin() external view returns (\r\n        address\r\n    );\r\n\r\n    function decimals() external view returns (\r\n        uint256\r\n    );\r\n\r\n    function balanceOfUnderlying(\r\n        address owner\r\n    ) external returns (\r\n        uint256\r\n    );\r\n\r\n    function getCash() external view returns (\r\n        uint256\r\n    );\r\n\r\n    function _setComptroller(\r\n        address newComptroller\r\n    ) external returns (\r\n        uint256\r\n    );\r\n\r\n    function totalBorrows() external view returns (\r\n        uint256\r\n    );\r\n\r\n    function comptroller() external view returns (\r\n        address\r\n    );\r\n\r\n    function _reduceReserves(\r\n        uint256 reduceAmount\r\n    ) external returns (\r\n        uint256\r\n    );\r\n\r\n    function initialExchangeRateMantissa() external view returns (\r\n        uint256\r\n    );\r\n\r\n    function accrualBlockNumber() external view returns (\r\n        uint256\r\n    );\r\n\r\n    function underlying() external view returns (\r\n        address\r\n    );\r\n\r\n    function balanceOf(\r\n        address owner\r\n    ) external view returns (\r\n        uint256\r\n    );\r\n\r\n    function totalBorrowsCurrent() external returns (\r\n        uint256\r\n    );\r\n\r\n    function redeemUnderlying(\r\n        uint256 redeemAmount\r\n    ) external returns (\r\n        uint256\r\n    );\r\n\r\n    function totalReserves() external view returns (\r\n        uint256\r\n    );\r\n\r\n    function symbol() external view returns (\r\n        string memory\r\n    );\r\n\r\n    function borrowBalanceStored(\r\n        address account\r\n    ) external view returns (\r\n        uint256\r\n    );\r\n\r\n    function mint(\r\n        uint256 mintAmount\r\n    ) external returns (\r\n        uint256\r\n    );\r\n\r\n    function accrueInterest() external returns (\r\n        uint256\r\n    );\r\n\r\n    function transfer(\r\n        address dst,\r\n        uint256 amount\r\n    ) external returns (\r\n        bool\r\n    );\r\n\r\n    function borrowIndex() external view returns (\r\n        uint256\r\n    );\r\n\r\n    function supplyRatePerBlock() external view returns (\r\n        uint256\r\n    );\r\n\r\n    function seize(\r\n        address liquidator,\r\n        address borrower,\r\n        uint256 seizeTokens\r\n    ) external returns (\r\n        uint256\r\n    );\r\n\r\n    function _setPendingAdmin(\r\n        address newPendingAdmin\r\n    ) external returns (\r\n        uint256\r\n    );\r\n\r\n    function exchangeRateCurrent() external returns (\r\n        uint256\r\n    );\r\n\r\n    function getAccountSnapshot(\r\n        address account\r\n    ) external view returns (\r\n        uint256,\r\n        uint256,\r\n        uint256,\r\n        uint256\r\n    );\r\n\r\n    function borrow(\r\n        uint256 borrowAmount\r\n    ) external returns (\r\n        uint256\r\n    );\r\n\r\n    function redeem(\r\n        uint256 redeemTokens\r\n    ) external returns (\r\n        uint256\r\n    );\r\n\r\n    function allowance(\r\n        address owner,\r\n        address spender\r\n    ) external view returns (\r\n        uint256\r\n    );\r\n\r\n    function _acceptAdmin() external returns (\r\n        uint256\r\n    );\r\n\r\n    function _setInterestRateModel(\r\n        address newInterestRateModel\r\n    ) external returns (\r\n        uint256\r\n    );\r\n\r\n    function interestRateModel() external view returns (\r\n        address\r\n    );\r\n\r\n    function liquidateBorrow(\r\n        address borrower,\r\n        uint256 repayAmount,\r\n        address cTokenCollateral\r\n    ) external returns (\r\n        uint256\r\n    );\r\n\r\n    function admin() external view returns (\r\n        address\r\n    );\r\n\r\n    function borrowRatePerBlock() external view returns (\r\n        uint256\r\n    );\r\n\r\n    function _setReserveFactor(\r\n        uint256 newReserveFactorMantissa\r\n    ) external returns (\r\n        uint256\r\n    );\r\n\r\n    function isCToken() external view returns (\r\n        bool\r\n    );\r\n\r\n    /*\r\n    constructor(\r\n        address underlying_,\r\n        address comptroller_,\r\n        address interestRateModel_,\r\n        uint256 initialExchangeRateMantissa_,\r\n        string  calldata name_,\r\n        string  calldata symbol_,\r\n        uint256 decimals_\r\n    );\r\n    */\r\n\r\n    event AccrueInterest(\r\n        uint256 interestAccumulated,\r\n        uint256 borrowIndex,\r\n        uint256 totalBorrows\r\n    );\r\n\r\n    event Mint(\r\n        address minter,\r\n        uint256 mintAmount,\r\n        uint256 mintTokens\r\n    );\r\n\r\n    event Redeem(\r\n        address redeemer,\r\n        uint256 redeemAmount,\r\n        uint256 redeemTokens\r\n    );\r\n\r\n    event Borrow(\r\n        address borrower,\r\n        uint256 borrowAmount,\r\n        uint256 accountBorrows,\r\n        uint256 totalBorrows\r\n    );\r\n\r\n    event RepayBorrow(\r\n        address payer,\r\n        address borrower,\r\n        uint256 repayAmount,\r\n        uint256 accountBorrows,\r\n        uint256 totalBorrows\r\n    );\r\n\r\n    event LiquidateBorrow(\r\n        address liquidator,\r\n        address borrower,\r\n        uint256 repayAmount,\r\n        address cTokenCollateral,\r\n        uint256 seizeTokens\r\n    );\r\n\r\n    event NewPendingAdmin(\r\n        address oldPendingAdmin,\r\n        address newPendingAdmin\r\n    );\r\n\r\n    event NewAdmin(\r\n        address oldAdmin,\r\n        address newAdmin\r\n    );\r\n\r\n    event NewComptroller(\r\n        address oldComptroller,\r\n        address newComptroller\r\n    );\r\n\r\n    event NewMarketInterestRateModel(\r\n        address oldInterestRateModel,\r\n        address newInterestRateModel\r\n    );\r\n\r\n    event NewReserveFactor(\r\n        uint256 oldReserveFactorMantissa,\r\n        uint256 newReserveFactorMantissa\r\n    );\r\n\r\n    event ReservesReduced(\r\n        address admin,\r\n        uint256 reduceAmount,\r\n        uint256 newTotalReserves\r\n    );\r\n\r\n    event Failure(\r\n        uint256 error,\r\n        uint256 info,\r\n        uint256 detail\r\n    );\r\n\r\n    event Transfer(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    );\r\n\r\n    event Approval(\r\n        address owner,\r\n        address spender,\r\n        uint256 amount\r\n    );\r\n\r\n}\r\n\r\n// File: contracts/CompoundAllocationStrategy.sol\r\n\r\npragma solidity ^0.5.8;\r\n\r\n\r\n\r\n\r\n\r\ncontract CompoundAllocationStrategy is IAllocationStrategy, Ownable {\r\n\r\n    CErc20Interface private cToken;\r\n    IERC20 private token;\r\n\r\n    constructor(CErc20Interface cToken_) public {\r\n        cToken = cToken_;\r\n        token = IERC20(cToken.underlying());\r\n    }\r\n\r\n    /// @dev ISavingStrategy.underlying implementation\r\n    function underlying() external view returns (address) {\r\n        return cToken.underlying();\r\n    }\r\n\r\n    /// @dev ISavingStrategy.exchangeRateStored implementation\r\n    function exchangeRateStored() external view returns (uint256) {\r\n        return cToken.exchangeRateStored();\r\n    }\r\n\r\n    /// @dev ISavingStrategy.accrueInterest implementation\r\n    function accrueInterest() external returns (bool) {\r\n        return cToken.accrueInterest() == 0;\r\n    }\r\n\r\n    /// @dev ISavingStrategy.investUnderlying implementation\r\n    function investUnderlying(uint256 investAmount) external onlyOwner returns (uint256) {\r\n        token.transferFrom(msg.sender, address(this), investAmount);\r\n        token.approve(address(cToken), investAmount);\r\n        uint256 cTotalBefore = cToken.totalSupply();\r\n        // TODO should we handle mint failure?\r\n        require(cToken.mint(investAmount) == 0, \u0022mint failed\u0022);\r\n        uint256 cTotalAfter = cToken.totalSupply();\r\n        uint256 cCreatedAmount;\r\n        if (cTotalAfter \u003E cTotalBefore) {\r\n            cCreatedAmount = cTotalAfter - cTotalBefore;\r\n        } // else can there be case that we mint but we get less cTokens!?\\\r\n        return cCreatedAmount;\r\n    }\r\n\r\n    /// @dev ISavingStrategy.redeemUnderlying implementation\r\n    function redeemUnderlying(uint256 redeemAmount) external onlyOwner returns (uint256) {\r\n        uint256 cTotalBefore = cToken.totalSupply();\r\n        // TODO should we handle redeem failure?\r\n        require(cToken.redeemUnderlying(redeemAmount) == 0, \u0022redeemUnderlying failed\u0022);\r\n        uint256 cTotalAfter = cToken.totalSupply();\r\n        uint256 cBurnedAmount;\r\n        if (cTotalAfter \u003C cTotalBefore) {\r\n            cBurnedAmount = cTotalBefore - cTotalAfter;\r\n        } // else can there be case that we end up with more cTokens ?!\r\n        token.transfer(msg.sender, redeemAmount);\r\n        return cBurnedAmount;\r\n    }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022exchangeRateStored\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022underlying\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022redeemAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022redeemUnderlying\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022accrueInterest\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022investAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022investUnderlying\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract CErc20Interface\u0022,\u0022name\u0022:\u0022cToken_\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"CompoundAllocationStrategy","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000f5dce57282a584d2746faf1593d3121fcac444dc","Library":"","SwarmSource":"bzzr://861bdc662fa117ee4e8cc2ad6868dabf5f7c219b6f9b971c5c01e346c84ff4c0"}]