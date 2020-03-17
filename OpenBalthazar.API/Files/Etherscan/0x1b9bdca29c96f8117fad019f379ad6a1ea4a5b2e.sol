[{"SourceCode":"pragma solidity ^0.5.11;\r\n\r\n// Voken panel\r\n//\r\n// More info:\r\n//   https://vision.network\r\n//   https://voken.io\r\n//\r\n// Contact us:\r\n//   support@vision.network\r\n//   support@voken.io\r\n\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n */\r\ncontract Ownable {\r\n    address internal _owner;\r\n    address internal _newOwner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n    event OwnershipAccepted(address indexed previousOwner, address indexed newOwner);\r\n\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(msg.sender == _owner, \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     *\r\n     * IMPORTANT: Need to run {acceptOwnership} by the new owner.\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _newOwner = newOwner;\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     *\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Accept ownership of the contract.\r\n     *\r\n     * Can only be called by the new owner.\r\n     */\r\n    function acceptOwnership() public {\r\n        require(msg.sender == _newOwner, \u0022Ownable: caller is not the new owner address\u0022);\r\n        require(msg.sender != address(0), \u0022Ownable: caller is the zero address\u0022);\r\n\r\n        emit OwnershipAccepted(_owner, msg.sender);\r\n        _owner = msg.sender;\r\n        _newOwner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Rescue compatible ERC20 Token\r\n     *\r\n     * Can only be called by the current owner.\r\n     */\r\n    function rescueTokens(address tokenAddr, address recipient, uint256 amount) external onlyOwner {\r\n        IERC20 _token = IERC20(tokenAddr);\r\n        require(recipient != address(0), \u0022Rescue: recipient is the zero address\u0022);\r\n        uint256 balance = _token.balanceOf(address(this));\r\n\r\n        require(balance \u003E= amount, \u0022Rescue: amount exceeds balance\u0022);\r\n        _token.transfer(recipient, amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Withdraw Ether\r\n     *\r\n     * Can only be called by the current owner.\r\n     */\r\n    function withdrawEther(address payable recipient, uint256 amount) external onlyOwner {\r\n        require(recipient != address(0), \u0022Withdraw: recipient is the zero address\u0022);\r\n\r\n        uint256 balance = address(this).balance;\r\n\r\n        require(balance \u003E= amount, \u0022Withdraw: amount exceeds balance\u0022);\r\n        recipient.transfer(amount);\r\n    }\r\n}\r\n\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard\r\n */\r\ninterface IERC20 {\r\n    function balanceOf(address account) external view returns (uint256);\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n}\r\n\r\n\r\n/**\r\n * @dev Interface of Voken2.0\r\n */\r\ninterface IVoken2 {\r\n    function totalSupply() external view returns (uint256);\r\n    function whitelistingMode() external view returns (bool);\r\n    function safeMode() external view returns (bool);\r\n    function burningMode() external view returns (bool, uint16);\r\n    function balanceOf(address account) external view returns (uint256);\r\n    function reservedOf(address account) external view returns (uint256);\r\n    function whitelisted(address account) external view returns (bool);\r\n    function whitelistCounter() external view returns (uint256);\r\n    function whitelistReferralsCount(address account) external view returns (uint256);\r\n}\r\n\r\n\r\n/**\r\n * @title Voken2 Panel\r\n */\r\ncontract Voken2Panel is Ownable {\r\n\r\n    IVoken2 private _VOKEN = IVoken2(0xFfFAb974088Bd5bF3d7E6F522e93Dd7861264cDB);\r\n\r\n    event Donate(address indexed account, uint256 amount);\r\n\r\n\r\n    /**\r\n     * @dev Donate\r\n     */\r\n    function () external payable {\r\n        if (msg.value \u003E 0) {\r\n            emit Donate(msg.sender, msg.value);\r\n        }\r\n    }\r\n\r\n    function voken2() public view returns (uint256 totalSupply,\r\n                                           uint256 whitelistCounter,\r\n                                           bool whitelistingMode,\r\n                                           bool safeMode,\r\n                                           bool burningMode) {\r\n        totalSupply = _VOKEN.totalSupply();\r\n\r\n        whitelistCounter = _VOKEN.whitelistCounter();\r\n        whitelistingMode = _VOKEN.whitelistingMode();\r\n        safeMode = _VOKEN.safeMode();\r\n        (burningMode,) = _VOKEN.burningMode();\r\n    }\r\n\r\n\r\n    function accountVoken2(address account) public view returns (bool whitelisted,\r\n                                                                 uint256 whitelistReferralsCount,\r\n                                                                 uint256 balance,\r\n                                                                 uint256 reserved) {\r\n        whitelisted = _VOKEN.whitelisted(account);\r\n        whitelistReferralsCount = _VOKEN.whitelistReferralsCount(account);\r\n        balance = _VOKEN.balanceOf(account);\r\n        reserved = _VOKEN.reservedOf(account);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawEther\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022voken2\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022totalSupply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022whitelistCounter\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022whitelistingMode\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022safeMode\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022burningMode\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022tokenAddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022rescueTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022accountVoken2\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022whitelisted\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022whitelistReferralsCount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022reserved\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Donate\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipAccepted\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Voken2Panel","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://ae7b41170257fb52ba77d629078e69cd346ed636fc842e66dd56416df03497c3"}]