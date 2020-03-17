[{"SourceCode":"pragma solidity 0.5.10;\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * \u0060onlyOwner\u0060, which can be aplied to your functions to restrict their use to\r\n * the owner.\r\n */\r\ncontract Ownable {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the caller is the current owner.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return msg.sender == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * \u0060onlyOwner\u0060 functions anymore. Can only be called by the current owner.\r\n     *\r\n     * \u003E Note: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\n/**\r\n * @title Roles\r\n * @dev Library for managing addresses assigned to a Role.\r\n */\r\nlibrary Roles {\r\n    struct Role {\r\n        mapping (address =\u003E bool) bearer;\r\n    }\r\n\r\n    /**\r\n     * @dev Give an account access to this role.\r\n     */\r\n    function add(Role storage role, address account) internal {\r\n        require(!has(role, account), \u0022Roles: account already has role\u0022);\r\n        role.bearer[account] = true;\r\n    }\r\n\r\n    /**\r\n     * @dev Remove an account\u0027s access to this role.\r\n     */\r\n    function remove(Role storage role, address account) internal {\r\n        require(has(role, account), \u0022Roles: account does not have role\u0022);\r\n        role.bearer[account] = false;\r\n    }\r\n\r\n    /**\r\n     * @dev Check if an account has this role.\r\n     * @return bool\r\n     */\r\n    function has(Role storage role, address account) internal view returns (bool) {\r\n        require(account != address(0), \u0022Roles: account is the zero address\u0022);\r\n        return role.bearer[account];\r\n    }\r\n}\r\n\r\ncontract PauserRole {\r\n    using Roles for Roles.Role;\r\n\r\n    event PauserAdded(address indexed account);\r\n    event PauserRemoved(address indexed account);\r\n\r\n    Roles.Role private _pausers;\r\n\r\n    constructor () internal {\r\n        _addPauser(msg.sender);\r\n    }\r\n\r\n    modifier onlyPauser() {\r\n        require(isPauser(msg.sender), \u0022PauserRole: caller does not have the Pauser role\u0022);\r\n        _;\r\n    }\r\n\r\n    function isPauser(address account) public view returns (bool) {\r\n        return _pausers.has(account);\r\n    }\r\n\r\n    function addPauser(address account) public onlyPauser {\r\n        _addPauser(account);\r\n    }\r\n\r\n    function renouncePauser() public {\r\n        _removePauser(msg.sender);\r\n    }\r\n\r\n    function _addPauser(address account) internal {\r\n        _pausers.add(account);\r\n        emit PauserAdded(account);\r\n    }\r\n\r\n    function _removePauser(address account) internal {\r\n        _pausers.remove(account);\r\n        emit PauserRemoved(account);\r\n    }\r\n}\r\n\r\n/**\r\n * @dev Contract module which allows children to implement an emergency stop\r\n * mechanism that can be triggered by an authorized account.\r\n *\r\n * This module is used through inheritance. It will make available the\r\n * modifiers \u0060whenNotPaused\u0060 and \u0060whenPaused\u0060, which can be applied to\r\n * the functions of your contract. Note that they will not be pausable by\r\n * simply including this module, only once the modifiers are put in place.\r\n */\r\ncontract Pausable is PauserRole {\r\n    /**\r\n     * @dev Emitted when the pause is triggered by a pauser (\u0060account\u0060).\r\n     */\r\n    event Paused(address account);\r\n\r\n    /**\r\n     * @dev Emitted when the pause is lifted by a pauser (\u0060account\u0060).\r\n     */\r\n    event Unpaused(address account);\r\n\r\n    bool private _paused;\r\n\r\n    /**\r\n     * @dev Initializes the contract in unpaused state. Assigns the Pauser role\r\n     * to the deployer.\r\n     */\r\n    constructor () internal {\r\n        _paused = false;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the contract is paused, and false otherwise.\r\n     */\r\n    function paused() public view returns (bool) {\r\n        return _paused;\r\n    }\r\n\r\n    /**\r\n     * @dev Modifier to make a function callable only when the contract is not paused.\r\n     */\r\n    modifier whenNotPaused() {\r\n        require(!_paused, \u0022Pausable: paused\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Modifier to make a function callable only when the contract is paused.\r\n     */\r\n    modifier whenPaused() {\r\n        require(_paused, \u0022Pausable: not paused\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Called by a pauser to pause, triggers stopped state.\r\n     */\r\n    function pause() public onlyPauser whenNotPaused {\r\n        _paused = true;\r\n        emit Paused(msg.sender);\r\n    }\r\n\r\n    /**\r\n     * @dev Called by a pauser to unpause, returns to normal state.\r\n     */\r\n    function unpause() public onlyPauser whenPaused {\r\n        _paused = false;\r\n        emit Unpaused(msg.sender);\r\n    }\r\n}\r\n\r\n\r\ninterface IWalletDeployer {\r\n\r\n    function deploy(address owner) external returns (address);\r\n}\r\n\r\n/**\r\n* @dev Wallet Manager contract\r\n*/\r\ncontract WalletManager is Ownable, Pausable {\r\n\r\n    //List of all wallets\r\n    mapping(address =\u003E address) private _userVsWallet;\r\n\r\n    //List of registered users\r\n    address[] private _users;\r\n\r\n    IWalletDeployer private _walletDeployer;\r\n\r\n    event WalletCreated(address indexed user, address indexed wallet);\r\n\r\n    event WalletDeployerUpdated(address indexed walletDeployer);\r\n\r\n    constructor(address walletDeployer) public {\r\n        require(\r\n            walletDeployer != address(0),\r\n            \u0022WalletManager: Invalid wallet deployer address!!\u0022\r\n        );\r\n\r\n        _walletDeployer = IWalletDeployer(walletDeployer);\r\n    }\r\n\r\n    /**\r\n    * @dev Returns wallet address of the user.\r\n    * If user is not registered so far than it will return zero address\r\n    * @param user Address of the user\r\n    */\r\n    function getWallet(address user) external view returns(address) {\r\n        return _userVsWallet[user];\r\n    }\r\n\r\n    /**\r\n    * @dev Returns total count of registered users\r\n    */\r\n    function getUserCount() external view returns (uint256) {\r\n        return _users.length;\r\n    }\r\n\r\n    /**\r\n    * @dev Returns list of registered users\r\n    */\r\n    function getUsers() external view returns(address[] memory) {\r\n        return _users;\r\n    }\r\n\r\n    /**\r\n    * @dev Returns the current wallet deployer address\r\n    */\r\n    function getWalletDeployer() external view returns(address) {\r\n        return address(_walletDeployer);\r\n    }\r\n\r\n    /**\r\n    * @dev Allows owner of the contract to update wallet deployer\r\n    * @param newWalletDeployer Address of the new wallet deployer\r\n    */\r\n    function setWalletDeployer(address newWalletDeployer) external onlyOwner {\r\n        require(\r\n            newWalletDeployer != address(0),\r\n            \u0022WalletManager: Invalid wallet deployer address!!\u0022\r\n        );\r\n        _walletDeployer = IWalletDeployer(newWalletDeployer);\r\n\r\n        emit WalletDeployerUpdated(newWalletDeployer);\r\n    }\r\n\r\n    /**\r\n    * @dev Allows new user to create a new wallet for themselves\r\n    */\r\n    function createWallet() external whenNotPaused {\r\n        require(\r\n            _userVsWallet[msg.sender] == address(0),\r\n            \u0022WalletManager: Wallet already exist for the user!!\u0022\r\n        );\r\n        address wallet = _walletDeployer.deploy(msg.sender);\r\n\r\n        _userVsWallet[msg.sender] = wallet;\r\n        _users.push(msg.sender);\r\n\r\n        emit WalletCreated(msg.sender, wallet);\r\n\r\n    }\r\n\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getUsers\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getWallet\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022createWallet\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isPauser\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renouncePauser\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getWalletDeployer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addPauser\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newWalletDeployer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setWalletDeployer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getUserCount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022walletDeployer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022wallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WalletCreated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022walletDeployer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WalletDeployerUpdated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Paused\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Unpaused\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022PauserAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022PauserRemoved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"WalletManager","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"0000000000000000000000007149d654413efa2203f3c29fc2d7d2c025237a98","Library":"","SwarmSource":"bzzr://1704bd174f56c6f22c687f76bbdfc1f773458b827bebf80e8fd27691848ffb41"}]