[{"SourceCode":"// File: openzeppelin-solidity/contracts/ownership/Ownable.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * \u0060onlyOwner\u0060, which can be aplied to your functions to restrict their use to\r\n * the owner.\r\n */\r\ncontract Ownable {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the caller is the current owner.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return msg.sender == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * \u0060onlyOwner\u0060 functions anymore. Can only be called by the current owner.\r\n     *\r\n     * \u003E Note: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\r\n * the optional functions; to access them see \u0060ERC20Detailed\u0060.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from the caller\u0027s account to \u0060recipient\u0060.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a \u0060Transfer\u0060 event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that \u0060spender\u0060 will be\r\n     * allowed to spend on behalf of \u0060owner\u0060 through \u0060transferFrom\u0060. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when \u0060approve\u0060 or \u0060transferFrom\u0060 are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * \u003E Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an \u0060Approval\u0060 event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from \u0060sender\u0060 to \u0060recipient\u0060 using the\r\n     * allowance mechanism. \u0060amount\u0060 is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a \u0060Transfer\u0060 event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when \u0060value\u0060 tokens are moved from one account (\u0060from\u0060) to\r\n     * another (\u0060to\u0060).\r\n     *\r\n     * Note that \u0060value\u0060 may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a \u0060spender\u0060 for an \u0060owner\u0060 is set by\r\n     * a call to \u0060approve\u0060. \u0060value\u0060 is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n// File: contracts/TxBatching.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n\r\n\r\ncontract TxBatching is Ownable {\r\n  /**\r\n   * @notice Batch transfer amounts to payees in a single token.\r\n   * @param payees array of recipient addresses\r\n   * @param amounts array of amounts to send to payees\r\n   * @param token address of token being sent\r\n   */\r\n  function payout(address payable[] memory payees, uint256[] memory amounts, address token) public payable {\r\n    uint256 _i;\r\n    IERC20 _token_interface;\r\n\r\n    if (token != address(0)) {\r\n      _token_interface = IERC20(token);\r\n    }\r\n\r\n    require(payees.length \u003C= 100, \u0027Max addresses\u0027);\r\n    require(payees.length == amounts.length, \u0027Wrong amounts length\u0027);\r\n\r\n    for (_i = 0; _i \u003C amounts.length; _i\u002B\u002B) {\r\n      if (token == address(0)) {\r\n        payees[_i].transfer(amounts[_i]);\r\n      } else {\r\n        _token_interface.transferFrom(msg.sender, payees[_i], amounts[_i]);\r\n      }\r\n    }\r\n  }\r\n\r\n  /**\r\n   * @notice Claim total balance from the contract.\r\n   */\r\n  function claimBalance() public onlyOwner {\r\n    uint256 balance = address(this).balance;\r\n    msg.sender.transfer(balance);\r\n  }\r\n\r\n  /**\r\n   * @notice Kill the contract and recover any funds.\r\n   */\r\n  function kill() public onlyOwner { selfdestruct(msg.sender); }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022claimBalance\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022kill\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable[]\u0022,\u0022name\u0022:\u0022payees\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022amounts\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022payout\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"TxBatching","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://68f0a876a7c5609d7a8862890f18e7ed32bfe0deb0e70ab707b9bcad89e9fd99"}]