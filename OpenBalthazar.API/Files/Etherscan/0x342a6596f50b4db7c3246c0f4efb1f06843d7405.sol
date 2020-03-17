[{"SourceCode":"// File: @sablier/shared-contracts/interfaces/ICERC20.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\n/**\r\n * @title CERC20 interface\r\n * @author Sablier\r\n * @dev See https://compound.finance/developers\r\n */\r\ninterface ICERC20 {\r\n    function balanceOf(address who) external view returns (uint256);\r\n\r\n    function isCToken() external view returns (bool);\r\n\r\n    function approve(address spender, uint256 value) external returns (bool);\r\n\r\n    function balanceOfUnderlying(address account) external returns (uint256);\r\n\r\n    function exchangeRateCurrent() external returns (uint256);\r\n\r\n    function mint(uint256 mintAmount) external returns (uint256);\r\n\r\n    function redeem(uint256 redeemTokens) external returns (uint256);\r\n\r\n    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);\r\n\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n}\r\n\r\n// File: @openzeppelin/contracts-ethereum-package/contracts/GSN/Context.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/*\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they not should not be accessed in such a direct\r\n * manner, since when dealing with GSN meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\ncontract Context {\r\n    // Empty internal constructor, to prevent people from mistakenly deploying\r\n    // an instance of this contract, with should be used via inheritance.\r\n    constructor () internal { }\r\n    // solhint-disable-previous-line no-empty-blocks\r\n\r\n    function _msgSender() internal view returns (address) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view returns (bytes memory) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}\r\n\r\n// File: @openzeppelin/upgrades/contracts/Initializable.sol\r\n\r\npragma solidity \u003E=0.4.24 \u003C0.6.0;\r\n\r\n\r\n/**\r\n * @title Initializable\r\n *\r\n * @dev Helper contract to support initializer functions. To use it, replace\r\n * the constructor with a function that has the \u0060initializer\u0060 modifier.\r\n * WARNING: Unlike constructors, initializer functions must be manually\r\n * invoked. This applies both to deploying an Initializable contract, as well\r\n * as extending an Initializable contract via inheritance.\r\n * WARNING: When used with inheritance, manual care must be taken to not invoke\r\n * a parent initializer twice, or ensure that all initializers are idempotent,\r\n * because this is not dealt with automatically as with constructors.\r\n */\r\ncontract Initializable {\r\n\r\n  /**\r\n   * @dev Indicates that the contract has been initialized.\r\n   */\r\n  bool private initialized;\r\n\r\n  /**\r\n   * @dev Indicates that the contract is in the process of being initialized.\r\n   */\r\n  bool private initializing;\r\n\r\n  /**\r\n   * @dev Modifier to use in the initializer function of a contract.\r\n   */\r\n  modifier initializer() {\r\n    require(initializing || isConstructor() || !initialized, \u0022Contract instance has already been initialized\u0022);\r\n\r\n    bool isTopLevelCall = !initializing;\r\n    if (isTopLevelCall) {\r\n      initializing = true;\r\n      initialized = true;\r\n    }\r\n\r\n    _;\r\n\r\n    if (isTopLevelCall) {\r\n      initializing = false;\r\n    }\r\n  }\r\n\r\n  /// @dev Returns true if and only if the function is running in the constructor\r\n  function isConstructor() private view returns (bool) {\r\n    // extcodesize checks the size of the code stored in an address, and\r\n    // address returns the current address. Since the code is still not\r\n    // deployed when running a constructor, any checks on its code size will\r\n    // yield zero, making it an effective way to detect if a contract is\r\n    // under construction or not.\r\n    uint256 cs;\r\n    assembly { cs := extcodesize(address) }\r\n    return cs == 0;\r\n  }\r\n\r\n  // Reserved storage space to allow for layout changes in the future.\r\n  uint256[50] private ______gap;\r\n}\r\n\r\n// File: @sablier/shared-contracts/lifecycle/OwnableWithoutRenounce.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\n\r\n\r\n/**\r\n * @title OwnableWithoutRenounce\r\n * @author Sablier\r\n * @dev Fork of OpenZeppelin\u0027s Ownable contract, which provides basic authorization control, but with\r\n *  the \u0060renounceOwnership\u0060 function removed to avoid fat-finger errors.\r\n *  We inherit from \u0060Context\u0060 to keep this contract compatible with the Gas Station Network.\r\n * See https://github.com/OpenZeppelin/openzeppelin-contracts-ethereum-package/blob/master/contracts/ownership/Ownable.sol\r\n * See https://forum.openzeppelin.com/t/contract-request-ownable-without-renounceownership/1400\r\n * See https://docs.openzeppelin.com/contracts/2.x/gsn#_msg_sender_and_msg_data\r\n */\r\ncontract OwnableWithoutRenounce is Initializable, Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n     * account.\r\n     */\r\n    function initialize(address sender) public initializer {\r\n        _owner = sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @return the address of the owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner());\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @return true if \u0060msg.sender\u0060 is the owner of the contract.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return _msgSender() == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n\r\n    uint256[50] private ______gap;\r\n}\r\n\r\n// File: contracts/interfaces/ICTokenManager.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\n/**\r\n * @title CTokenManager Interface\r\n * @author Sablier\r\n */\r\ninterface ICTokenManager {\r\n    /**\r\n     * @notice Emits when the owner discards a cToken.\r\n     */\r\n    event DiscardCToken(address indexed tokenAddress);\r\n\r\n    /**\r\n     * @notice Emits when the owner whitelists a cToken.\r\n     */\r\n    event WhitelistCToken(address indexed tokenAddress);\r\n\r\n    function whitelistCToken(address tokenAddress) external;\r\n\r\n    function discardCToken(address tokenAddress) external;\r\n\r\n    function isCToken(address tokenAddress) external view returns (bool);\r\n}\r\n\r\n// File: contracts/CTokenManager.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\n\r\n\r\n\r\n/**\r\n * @title CTokenManager\r\n * @author Sablier\r\n */\r\ncontract CTokenManager is ICTokenManager, OwnableWithoutRenounce {\r\n    /*** Storage Properties ***/\r\n\r\n    /**\r\n     * @notice Mapping of cTokens which can be used\r\n     */\r\n    mapping(address =\u003E bool) private cTokens;\r\n\r\n    /*** Contract Logic Starts Here */\r\n\r\n    constructor() public {\r\n        OwnableWithoutRenounce.initialize(msg.sender);\r\n    }\r\n\r\n    /*** Owner Functions ***/\r\n\r\n    /**\r\n     * @notice Whitelists a cToken for compounding streams.\r\n     * @dev Throws if the caller is not the owner of the contract.\r\n     *  Throws is the token is whitelisted.\r\n     *  Throws if the given address is not a \u0060cToken\u0060.\r\n     * @param tokenAddress The address of the cToken to whitelist.\r\n     */\r\n    function whitelistCToken(address tokenAddress) external onlyOwner {\r\n        require(!isCToken(tokenAddress), \u0022cToken is whitelisted\u0022);\r\n        require(ICERC20(tokenAddress).isCToken(), \u0022token is not cToken\u0022);\r\n        cTokens[tokenAddress] = true;\r\n        emit WhitelistCToken(tokenAddress);\r\n    }\r\n\r\n    /**\r\n     * @notice Discards a previously whitelisted cToken.\r\n     * @dev Throws if the caller is not the owner of the contract.\r\n     *  Throws if token is not whitelisted.\r\n     * @param tokenAddress The address of the cToken to discard.\r\n     */\r\n    function discardCToken(address tokenAddress) external onlyOwner {\r\n        require(isCToken(tokenAddress), \u0022cToken is not whitelisted\u0022);\r\n        cTokens[tokenAddress] = false;\r\n        emit DiscardCToken(tokenAddress);\r\n    }\r\n\r\n    /*** View Functions ***/\r\n    /**\r\n     * @notice Checks if the given token address is one of the whitelisted cTokens.\r\n     * @param tokenAddress The address of the token to check.\r\n     * @return bool true=it is cToken, otherwise false.\r\n     */\r\n    function isCToken(address tokenAddress) public view returns (bool) {\r\n        return cTokens[tokenAddress];\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022whitelistCToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isCToken\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022initialize\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022discardCToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022DiscardCToken\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WhitelistCToken\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"CTokenManager","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://675db65f5a31e21413d5ded4c207ae8f39d4c318946e44231169a31f1dd29f9e"}]