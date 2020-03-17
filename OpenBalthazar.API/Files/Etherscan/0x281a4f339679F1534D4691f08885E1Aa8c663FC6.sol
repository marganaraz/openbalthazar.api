[{"SourceCode":"// ExternalRefunds\r\n// Created by Akeem @ Unlock-Protocol\r\n\r\n// Source below flattened with \u0060truffle-flattener\u0060\r\n\r\n\r\n// File: hardlydifficult-ethereum-contracts\\contracts\\interfaces\\IPublicLock.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n\r\n// Source: https://github.com/unlock-protocol/unlock/tree/master/smart-contracts\r\ninterface IPublicLock\r\n{\r\n  function getHasValidKey(address _account) external view returns (bool);\r\n  // TODO add all the other functions\r\n}\r\n\r\n// File: node_modules\\@openzeppelin\\contracts\\access\\Roles.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @title Roles\r\n * @dev Library for managing addresses assigned to a Role.\r\n */\r\nlibrary Roles {\r\n    struct Role {\r\n        mapping (address =\u003E bool) bearer;\r\n    }\r\n\r\n    /**\r\n     * @dev Give an account access to this role.\r\n     */\r\n    function add(Role storage role, address account) internal {\r\n        require(!has(role, account), \u0022Roles: account already has role\u0022);\r\n        role.bearer[account] = true;\r\n    }\r\n\r\n    /**\r\n     * @dev Remove an account\u0027s access to this role.\r\n     */\r\n    function remove(Role storage role, address account) internal {\r\n        require(has(role, account), \u0022Roles: account does not have role\u0022);\r\n        role.bearer[account] = false;\r\n    }\r\n\r\n    /**\r\n     * @dev Check if an account has this role.\r\n     * @return bool\r\n     */\r\n    function has(Role storage role, address account) internal view returns (bool) {\r\n        require(account != address(0), \u0022Roles: account is the zero address\u0022);\r\n        return role.bearer[account];\r\n    }\r\n}\r\n\r\n// File: node_modules\\@openzeppelin\\contracts\\access\\roles\\WhitelistAdminRole.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n\r\n/**\r\n * @title WhitelistAdminRole\r\n * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.\r\n */\r\ncontract WhitelistAdminRole {\r\n    using Roles for Roles.Role;\r\n\r\n    event WhitelistAdminAdded(address indexed account);\r\n    event WhitelistAdminRemoved(address indexed account);\r\n\r\n    Roles.Role private _whitelistAdmins;\r\n\r\n    constructor () internal {\r\n        _addWhitelistAdmin(msg.sender);\r\n    }\r\n\r\n    modifier onlyWhitelistAdmin() {\r\n        require(isWhitelistAdmin(msg.sender), \u0022WhitelistAdminRole: caller does not have the WhitelistAdmin role\u0022);\r\n        _;\r\n    }\r\n\r\n    function isWhitelistAdmin(address account) public view returns (bool) {\r\n        return _whitelistAdmins.has(account);\r\n    }\r\n\r\n    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {\r\n        _addWhitelistAdmin(account);\r\n    }\r\n\r\n    function renounceWhitelistAdmin() public {\r\n        _removeWhitelistAdmin(msg.sender);\r\n    }\r\n\r\n    function _addWhitelistAdmin(address account) internal {\r\n        _whitelistAdmins.add(account);\r\n        emit WhitelistAdminAdded(account);\r\n    }\r\n\r\n    function _removeWhitelistAdmin(address account) internal {\r\n        _whitelistAdmins.remove(account);\r\n        emit WhitelistAdminRemoved(account);\r\n    }\r\n}\r\n\r\n// File: @openzeppelin\\contracts\\access\\roles\\WhitelistedRole.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n\r\n\r\n/**\r\n * @title WhitelistedRole\r\n * @dev Whitelisted accounts have been approved by a WhitelistAdmin to perform certain actions (e.g. participate in a\r\n * crowdsale). This role is special in that the only accounts that can add it are WhitelistAdmins (who can also remove\r\n * it), and not Whitelisteds themselves.\r\n */\r\ncontract WhitelistedRole is WhitelistAdminRole {\r\n    using Roles for Roles.Role;\r\n\r\n    event WhitelistedAdded(address indexed account);\r\n    event WhitelistedRemoved(address indexed account);\r\n\r\n    Roles.Role private _whitelisteds;\r\n\r\n    modifier onlyWhitelisted() {\r\n        require(isWhitelisted(msg.sender), \u0022WhitelistedRole: caller does not have the Whitelisted role\u0022);\r\n        _;\r\n    }\r\n\r\n    function isWhitelisted(address account) public view returns (bool) {\r\n        return _whitelisteds.has(account);\r\n    }\r\n\r\n    function addWhitelisted(address account) public onlyWhitelistAdmin {\r\n        _addWhitelisted(account);\r\n    }\r\n\r\n    function removeWhitelisted(address account) public onlyWhitelistAdmin {\r\n        _removeWhitelisted(account);\r\n    }\r\n\r\n    function renounceWhitelisted() public {\r\n        _removeWhitelisted(msg.sender);\r\n    }\r\n\r\n    function _addWhitelisted(address account) internal {\r\n        _whitelisteds.add(account);\r\n        emit WhitelistedAdded(account);\r\n    }\r\n\r\n    function _removeWhitelisted(address account) internal {\r\n        _whitelisteds.remove(account);\r\n        emit WhitelistedRemoved(account);\r\n    }\r\n}\r\n\r\n// File: @openzeppelin\\contracts\\token\\ERC20\\IERC20.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\r\n * the optional functions; to access them see \u0060ERC20Detailed\u0060.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from the caller\u0027s account to \u0060recipient\u0060.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a \u0060Transfer\u0060 event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that \u0060spender\u0060 will be\r\n     * allowed to spend on behalf of \u0060owner\u0060 through \u0060transferFrom\u0060. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when \u0060approve\u0060 or \u0060transferFrom\u0060 are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * \u003E Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an \u0060Approval\u0060 event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from \u0060sender\u0060 to \u0060recipient\u0060 using the\r\n     * allowance mechanism. \u0060amount\u0060 is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a \u0060Transfer\u0060 event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when \u0060value\u0060 tokens are moved from one account (\u0060from\u0060) to\r\n     * another (\u0060to\u0060).\r\n     *\r\n     * Note that \u0060value\u0060 may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a \u0060spender\u0060 for an \u0060owner\u0060 is set by\r\n     * a call to \u0060approve\u0060. \u0060value\u0060 is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n// File: contracts\\ExternalRefund.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n\r\ncontract ExternalRefund is WhitelistedRole\r\n{\r\n  IPublicLock public lock;\r\n  mapping(address =\u003E bool) public refundee;\r\n  uint256 public refundAmount;\r\n  IERC20 public baseToken;\r\n\r\n  event Refund(\r\n    address indexed _recipient,\r\n    IERC20 indexed _token,\r\n    uint _amount\r\n  );\r\n\r\n  constructor(IPublicLock _lockAddress, uint256 _refundAmount, IERC20 _token) public\r\n  {\r\n    lock = _lockAddress;\r\n    refundAmount = _refundAmount;\r\n    baseToken = _token;\r\n  }\r\n\r\n  function refund(address recipient) public onlyWhitelisted()\r\n  {\r\n    require(!refundee[recipient], \u0027Recipient has already been refunded\u0027);\r\n    require(lock.getHasValidKey(recipient), \u0027Recipient does not own a key\u0027);\r\n\r\n    refundee[recipient] = true;\r\n    baseToken.transfer(recipient, refundAmount);\r\n    emit Refund(recipient, baseToken, refundAmount);\r\n  }\r\n\r\n  function drain() public onlyWhitelistAdmin()\r\n  {\r\n    uint256 balance = baseToken.balanceOf(address(this));\r\n    baseToken.transfer(msg.sender, balance);\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addWhitelisted\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022removeWhitelisted\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isWhitelisted\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceWhitelistAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addWhitelistAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022drain\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022refundee\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022refundAmount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isWhitelistAdmin\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022baseToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceWhitelisted\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022lock\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022refund\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_lockAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_refundAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Refund\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WhitelistedAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WhitelistedRemoved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WhitelistAdminAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WhitelistAdminRemoved\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"ExternalRefund","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000b0ad425ca5792dd4c4af9177c636e5b0e6c317bf000000000000000000000000000000000000000000000001158e460913d0000000000000000000000000000089d24a6b4ccb1b6faa2625fe562bdd9a23260359","Library":"","SwarmSource":"bzzr://fc8f03fb633e0d77a367009371685d240190ba882fa02f6e1b24988891f1dac6"}]