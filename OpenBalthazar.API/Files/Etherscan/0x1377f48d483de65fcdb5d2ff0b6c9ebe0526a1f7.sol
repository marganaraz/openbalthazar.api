[{"SourceCode":"pragma solidity ^0.5.11;\r\n\r\n// Contract for Voken2.0 Offer\r\n//\r\n// More info:\r\n//   https://vision.network\r\n//   https://voken.io\r\n//\r\n// Contact us:\r\n//   support@vision.network\r\n//   support@voken.io\r\n\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow checks.\r\n */\r\nlibrary SafeMath256 {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, errorMessage);\r\n        return a / b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n\r\n/**\r\n * @title Roles\r\n * @dev Library for managing addresses assigned to a Role.\r\n */\r\nlibrary Roles {\r\n    struct Role {\r\n        mapping(address =\u003E bool) bearer;\r\n    }\r\n\r\n    /**\r\n     * @dev Give an account access to this role.\r\n     */\r\n    function add(Role storage role, address account) internal {\r\n        require(!has(role, account), \u0022Roles: account already has role\u0022);\r\n        role.bearer[account] = true;\r\n    }\r\n\r\n    /**\r\n     * @dev Remove an account\u0027s access to this role.\r\n     */\r\n    function remove(Role storage role, address account) internal {\r\n        require(has(role, account), \u0022Roles: account does not have role\u0022);\r\n        role.bearer[account] = false;\r\n    }\r\n\r\n    /**\r\n     * @dev Check if an account has this role.\r\n     * @return bool\r\n     */\r\n    function has(Role storage role, address account) internal view returns (bool) {\r\n        require(account != address(0), \u0022Roles: account is the zero address\u0022);\r\n        return role.bearer[account];\r\n    }\r\n}\r\n\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard\r\n */\r\ninterface IERC20 {\r\n    function balanceOf(address account) external view returns (uint256);\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n}\r\n\r\n\r\n/**\r\n * @dev Interface of an allocation contract\r\n */\r\ninterface IAllocation {\r\n    function reservedOf(address account) external view returns (uint256);\r\n}\r\n\r\n\r\n/**\r\n * @dev Interface of Voken2.0\r\n */\r\ninterface IVoken2 {\r\n    function balanceOf(address account) external view returns (uint256);\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n    function mintWithAllocation(address account, uint256 amount, address allocationContract) external returns (bool);\r\n}\r\n\r\n\r\n/**\r\n * @dev Interface of Voken public-sale\r\n */\r\ninterface VokenPublicSale {\r\n    function queryAccount(address account) external view returns (\r\n        uint256 vokenIssued,\r\n        uint256 vokenBonus,\r\n        uint256 vokenReferral,\r\n        uint256 vokenReferrals,\r\n        uint256 weiPurchased,\r\n        uint256 weiRewarded);\r\n}\r\n\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n */\r\ncontract Ownable {\r\n    address internal _owner;\r\n    address internal _newOwner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n    event OwnershipAccepted(address indexed previousOwner, address indexed newOwner);\r\n\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the addresses of the current and new owner.\r\n     */\r\n    function owner() public view returns (address currentOwner, address newOwner) {\r\n        currentOwner = _owner;\r\n        newOwner = _newOwner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner(msg.sender), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the caller is the current owner.\r\n     */\r\n    function isOwner(address account) public view returns (bool) {\r\n        return account == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     *\r\n     * IMPORTANT: Need to run {acceptOwnership} by the new owner.\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _newOwner = newOwner;\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     *\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Accept ownership of the contract.\r\n     *\r\n     * Can only be called by the new owner.\r\n     */\r\n    function acceptOwnership() public {\r\n        require(msg.sender == _newOwner, \u0022Ownable: caller is not the new owner address\u0022);\r\n        require(msg.sender != address(0), \u0022Ownable: caller is the zero address\u0022);\r\n\r\n        emit OwnershipAccepted(_owner, msg.sender);\r\n        _owner = msg.sender;\r\n        _newOwner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Rescue compatible ERC20 Token\r\n     *\r\n     * Can only be called by the current owner.\r\n     */\r\n    function rescueTokens(address tokenAddr, address recipient, uint256 amount) external onlyOwner {\r\n        IERC20 _token = IERC20(tokenAddr);\r\n        require(recipient != address(0), \u0022Rescue: recipient is the zero address\u0022);\r\n        uint256 balance = _token.balanceOf(address(this));\r\n\r\n        require(balance \u003E= amount, \u0022Rescue: amount exceeds balance\u0022);\r\n        _token.transfer(recipient, amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Withdraw Ether\r\n     *\r\n     * Can only be called by the current owner.\r\n     */\r\n    function withdrawEther(address payable recipient, uint256 amount) external onlyOwner {\r\n        require(recipient != address(0), \u0022Withdraw: recipient is the zero address\u0022);\r\n\r\n        uint256 balance = address(this).balance;\r\n\r\n        require(balance \u003E= amount, \u0022Withdraw: amount exceeds balance\u0022);\r\n        recipient.transfer(amount);\r\n    }\r\n}\r\n\r\n\r\n/**\r\n * @title Voken 2.0 Offer\r\n */\r\ncontract VokenOffer is Ownable, IAllocation {\r\n    using SafeMath256 for uint256;\r\n    using Roles for Roles.Role;\r\n\r\n    IVoken2 private _VOKEN = IVoken2(0xFfFAb974088Bd5bF3d7E6F522e93Dd7861264cDB);\r\n    VokenPublicSale private _PUBLIC_SALE = VokenPublicSale(0xd4260e4Bfb354259F5e30279cb0D7F784Ea5f37A);\r\n\r\n    Roles.Role private _proxies;\r\n\r\n    mapping(address =\u003E bool) private _offered;\r\n    mapping(address =\u003E uint256) private _allocations;\r\n    mapping(address =\u003E uint256[]) private _rewards;\r\n    mapping(address =\u003E uint256[]) private _sales;\r\n\r\n    event Donate(address indexed account, uint256 amount);\r\n    event ProxyAdded(address indexed account);\r\n    event ProxyRemoved(address indexed account);\r\n\r\n\r\n    /**\r\n     * @dev Throws if called by account which is not a proxy.\r\n     */\r\n    modifier onlyProxy() {\r\n        require(isProxy(msg.sender), \u0022ProxyRole: caller does not have the Proxy role\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the \u0060account\u0060 has the Proxy role.\r\n     */\r\n    function isProxy(address account) public view returns (bool) {\r\n        return _proxies.has(account);\r\n    }\r\n\r\n    /**\r\n     * @dev Give an \u0060account\u0060 access to the Proxy role.\r\n     *\r\n     * Can only be called by the current owner.\r\n     */\r\n    function addProxy(address account) public onlyOwner {\r\n        _proxies.add(account);\r\n        emit ProxyAdded(account);\r\n    }\r\n\r\n    /**\r\n     * @dev Remove an \u0060account\u0060 access from the Proxy role.\r\n     *\r\n     * Can only be called by the current owner.\r\n     */\r\n    function removeProxy(address account) public onlyOwner {\r\n        _proxies.remove(account);\r\n        emit ProxyRemoved(account);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the allocation of \u0060account\u0060.\r\n     */\r\n    function allocation(address account) public view returns (uint256 amount, uint256[] memory sales, uint256[] memory rewards) {\r\n        amount = _allocations[account];\r\n        sales = _sales[account];\r\n        rewards = _rewards[account];\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the reserved amount of Voken by \u0060account\u0060.\r\n     */\r\n    function reservedOf(address account) public view returns (uint256 reserved) {\r\n        reserved = _allocations[account];\r\n\r\n        (,,, uint256 __vokenReferrals,,) = _PUBLIC_SALE.queryAccount(account);\r\n\r\n        for (uint256 i = 0; i \u003C _sales[account].length; i\u002B\u002B) {\r\n            if (__vokenReferrals \u003E= _sales[account][i] \u0026\u0026 reserved \u003E= _rewards[account][i]) {\r\n                reserved = reserved.sub(_rewards[account][i]);\r\n                break;\r\n            }\r\n        }\r\n    }\r\n\r\n\r\n    /**\r\n     * @dev Constructor\r\n     */\r\n    constructor () public {\r\n        addProxy(msg.sender);\r\n    }\r\n\r\n    /**\r\n     * @dev {Donate}\r\n     */\r\n    function() external payable {\r\n        if (msg.value \u003E 0) {\r\n            emit Donate(msg.sender, msg.value);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Send offer\r\n     *\r\n     * Can only be called by a proxy.\r\n     */\r\n    function offer(address account, uint256 amount, uint256[] memory sales, uint256[] memory rewards) public onlyProxy {\r\n        require(!_offered[account], \u0022VokenOffer: have already sent offer to this account\u0022);\r\n        require(sales.length == rewards.length, \u0022VokenOffer: length is not match (sales and rewards)\u0022);\r\n\r\n        _offered[account] = true;\r\n        _allocations[account] = amount;\r\n        _sales[account] = sales;\r\n        _rewards[account] = rewards;\r\n\r\n        assert(_VOKEN.mintWithAllocation(account, amount, address(this)));\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addProxy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isProxy\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawEther\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022sales\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022rewards\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022offer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022currentOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allocation\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022sales\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022rewards\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022removeProxy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022reservedOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022reserved\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022tokenAddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022rescueTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Donate\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022ProxyAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022ProxyRemoved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipAccepted\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"VokenOffer","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://19f66dbbbb0cf2df83e5203a7c801e906b009448a41c4e38a4503b79da0babeb"}]