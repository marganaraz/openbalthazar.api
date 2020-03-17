[{"SourceCode":"/**\r\n * Developed by The Flowchain Foundation\r\n *\r\n * The Flowchain tokens (FLC v2) smart contract\r\n */\r\npragma solidity 0.5.16;\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n    address public owner;\r\n    address public newOwner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n        newOwner = address(0);\r\n    }\r\n\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n    modifier onlyNewOwner() {\r\n        require(msg.sender != address(0));\r\n        require(msg.sender == newOwner);\r\n        _;\r\n    }\r\n    \r\n    function isOwner(address account) public view returns (bool) {\r\n        if( account == owner ){\r\n            return true;\r\n        }\r\n        else {\r\n            return false;\r\n        }\r\n    }\r\n\r\n    function transferOwnership(address _newOwner) public onlyOwner {\r\n        require(_newOwner != address(0));\r\n        newOwner = _newOwner;\r\n    }\r\n\r\n    function acceptOwnership() public onlyNewOwner {\r\n        emit OwnershipTransferred(owner, newOwner);        \r\n        owner = newOwner;\r\n        newOwner = address(0);\r\n    }\r\n}\r\n\r\n/**\r\n * @title Pausable\r\n * @dev The Pausable can pause and unpause the token transfers.\r\n */\r\ncontract Pausable is Ownable {\r\n    event Paused(address account);\r\n    event Unpaused(address account);\r\n\r\n    bool private _paused;\r\n\r\n    constructor () internal {\r\n        _paused = false;\r\n    }    \r\n\r\n    /**\r\n     * @return true if the contract is paused, false otherwise.\r\n     */\r\n    function paused() public view returns (bool) {\r\n        return _paused;\r\n    }\r\n\r\n    /**\r\n     * @dev Modifier to make a function callable only when the contract is not paused.\r\n     */\r\n    modifier whenNotPaused() {\r\n        require(!_paused);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Modifier to make a function callable only when the contract is paused.\r\n     */\r\n    modifier whenPaused() {\r\n        require(_paused);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev called by the owner to pause, triggers stopped state\r\n     */\r\n    function pause() public onlyOwner whenNotPaused {\r\n        _paused = true;\r\n        emit Paused(msg.sender);\r\n    }\r\n\r\n    /**\r\n     * @dev called by the owner to unpause, returns to normal state\r\n     */\r\n    function unpause() public onlyOwner whenPaused {\r\n        _paused = false;\r\n        emit Unpaused(msg.sender);\r\n    }\r\n}\r\n\r\n/**\r\n * @title The mintable FLC tokens.\r\n */\r\ncontract Mintable {\r\n    /**\r\n     * @dev Mint a amount of tokens and the funds to the user.\r\n     */\r\n    function mintToken(address to, uint256 amount) public returns (bool success);  \r\n\r\n    /**\r\n     * @dev Setup a mintable address that can mint or mine tokens.\r\n     */    \r\n    function setupMintableAddress(address _mintable) public returns (bool success);\r\n}\r\n\r\n/**\r\n * @title The off-chain issuable FLC tokens.\r\n */\r\ncontract OffchainIssuable {\r\n    /**\r\n     * The minimal withdraw ammount.\r\n     */\r\n    uint256 public MIN_WITHDRAW_AMOUNT = 100;\r\n\r\n    /**\r\n     * @dev Suspend the issuance of new tokens.\r\n     * Once set to false, \u0027_isIssuable\u0027 can never be set to \u0027true\u0027 again.\r\n     */\r\n    function setMinWithdrawAmount(uint256 amount) public returns (bool success);\r\n\r\n    /**\r\n     * @dev Resume the issuance of new tokens.\r\n     * Once set to false, \u0027_isIssuable\u0027 can never be set to \u0027true\u0027 again.\r\n     */\r\n    function getMinWithdrawAmount() public view returns (uint256 amount);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens redeemed to \u0060_owner\u0060.\r\n     * @param _owner The address from which the amount will be retrieved\r\n     * @return The amount\r\n     */\r\n    function amountRedeemOf(address _owner) public view returns (uint256 amount);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens withdrawn by \u0060_owner\u0060.\r\n     * @param _owner The address from which the amount will be retrieved\r\n     * @return The amount\r\n     */\r\n    function amountWithdrawOf(address _owner) public view returns (uint256 amount);\r\n\r\n    /**\r\n     * @dev Redeem the value of tokens to the address \u0027msg.sender\u0027\r\n     * @param to The user that will receive the redeemed token.\r\n     * @param amount Number of tokens to redeem.\r\n     */\r\n    function redeem(address to, uint256 amount) external returns (bool success);\r\n\r\n    /**\r\n     * @dev The user withdraw API.\r\n     * @param amount Number of tokens to redeem.\r\n     */\r\n    function withdraw(uint256 amount) public returns (bool success);   \r\n}\r\n\r\n/**\r\n * @dev The ERC20 standard as defined in the EIP.\r\n */\r\ncontract Token {\r\n    /**\r\n     * @dev The total amount of tokens.\r\n     */\r\n    uint256 public totalSupply;\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\r\n     * @param _owner The address from which the balance will be retrieved\r\n     * @return The balance\r\n     */\r\n    function balanceOf(address _owner) public view returns (uint256 balance);\r\n\r\n    /**\r\n     * @dev send \u0060_value\u0060 token to \u0060_to\u0060 from \u0060msg.sender\u0060\r\n     * @param _to The address of the recipient\r\n     * @param _value The amount of token to be transferred\r\n     * @return Whether the transfer was successful or not\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address _to, uint256 _value) public returns (bool success);\r\n\r\n    /**\r\n     * @notice send \u0060_value\u0060 token to \u0060_to\u0060 from \u0060_from\u0060 on the condition it is approved by \u0060_from\u0060\r\n     * @param _from The address of the sender\r\n     * @param _to The address of the recipient\r\n     * @param _value The amount of token to be transferred\r\n     * @return Whether the transfer was successful or not\r\n     */\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);\r\n\r\n    /**\r\n     * @notice \u0060msg.sender\u0060 approves \u0060_addr\u0060 to spend \u0060_value\u0060 tokens\r\n     * @param _spender The address of the account able to transfer the tokens\r\n     * @param _value The amount of wei to be approved for transfer\r\n     * @return Whether the approval was successful or not\r\n     */\r\n    function approve(address _spender, uint256 _value) public returns (bool success);\r\n\r\n    /**\r\n     * @param _owner The address of the account owning tokens\r\n     * @param _spender The address of the account able to transfer the tokens\r\n     * @return Amount of remaining tokens allowed to spent\r\n     */\r\n    function allowance(address _owner, address _spender) public view returns (uint256 remaining);\r\n\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n}\r\n\r\n/**\r\n * @dev The ERC20 standard implementation of FLC. \r\n */\r\ncontract StandardToken is Token {\r\n    uint256 constant private MAX_UINT256 = 2**256 - 1;\r\n    mapping (address =\u003E uint256) public balances;\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) public allowed;\r\n\r\n    function transfer(address _to, uint256 _value) public returns (bool success) {\r\n        require(balances[msg.sender] \u003E= _value);\r\n        \r\n        // Ensure not overflow\r\n        require(balances[_to] \u002B _value \u003E= balances[_to]);\r\n        \r\n        balances[msg.sender] -= _value;\r\n        balances[_to] \u002B= _value;\r\n\r\n        emit Transfer(msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {\r\n        uint256 allowance = allowed[_from][msg.sender];\r\n        require(balances[_from] \u003E= _value \u0026\u0026 allowance \u003E= _value);\r\n        \r\n        // Ensure not overflow\r\n        require(balances[_to] \u002B _value \u003E= balances[_to]);          \r\n\r\n        balances[_from] -= _value;\r\n        balances[_to] \u002B= _value;\r\n\r\n        if (allowance \u003C MAX_UINT256) {\r\n            allowed[_from][msg.sender] -= _value;\r\n        }  \r\n\r\n        emit Transfer(_from, _to, _value);\r\n        return true; \r\n    }\r\n\r\n    function balanceOf(address account) public view returns (uint256) {\r\n        return balances[account];\r\n    }\r\n\r\n    function approve(address _spender, uint256 _value) public returns (bool success) {\r\n        allowed[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {\r\n      return allowed[_owner][_spender];\r\n    }\r\n}\r\n\r\n\r\n/**\r\n * @dev Extension of ERC-20 that adds off-chain issuable and mintable tokens.\r\n * It allows miners to mint (create) new FLC tokens.\r\n *\r\n * At construction, the contract \u0060_mintableAddress\u0060 is the only token minter.\r\n */\r\ncontract FlowchainToken is StandardToken, Mintable, OffchainIssuable, Ownable, Pausable {\r\n\r\n    /* Public variables of the token */\r\n    string public name = \u0022Flowchain\u0022;\r\n    string public symbol = \u0022FLC\u0022;    \r\n    uint8 public decimals = 18;\r\n    string public version = \u00222.0\u0022;\r\n    address public mintableAddress;\r\n    address public multiSigWallet;\r\n\r\n    bool internal _isIssuable;\r\n\r\n    event Freeze(address indexed account);\r\n    event Unfreeze(address indexed account);\r\n\r\n    mapping (address =\u003E uint256) private _amountMinted;\r\n    mapping (address =\u003E uint256) private _amountRedeem;\r\n    mapping (address =\u003E bool) public frozenAccount;\r\n\r\n    modifier notFrozen(address _account) {\r\n        require(!frozenAccount[_account]);\r\n        _;\r\n    }\r\n\r\n    constructor(address _multiSigWallet) public {\r\n        // 1 billion tokens \u002B 18 decimals\r\n        totalSupply = 10**27;\r\n\r\n        // The multisig wallet that holds the unissued tokens\r\n        multiSigWallet = _multiSigWallet;\r\n\r\n        // Give the multisig wallet all initial tokens (unissued tokens)\r\n        balances[multiSigWallet] = totalSupply;  \r\n\r\n        emit Transfer(address(0), multiSigWallet, totalSupply);\r\n    }\r\n\r\n    function transfer(address to, uint256 value) public notFrozen(msg.sender) whenNotPaused returns (bool) {\r\n        return super.transfer(to, value);\r\n    }   \r\n\r\n    function transferFrom(address from, address to, uint256 value) public notFrozen(from) whenNotPaused returns (bool) {\r\n        return super.transferFrom(from, to, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Suspend the issuance of new tokens.\r\n     * Once set to false, \u0027_isIssuable\u0027 can never be set to \u0027true\u0027 again.\r\n     */\r\n    function suspendIssuance() external onlyOwner {\r\n        _isIssuable = false;\r\n    }\r\n\r\n    /**\r\n     * @dev Resume the issuance of new tokens.\r\n     * Once set to false, \u0027_isIssuable\u0027 can never be set to \u0027true\u0027 again.\r\n     */\r\n    function resumeIssuance() external onlyOwner {\r\n        _isIssuable = true;\r\n    }\r\n\r\n    /**\r\n     * @return bool return \u0027true\u0027 if tokens can still be issued by the issuer, \r\n     * \u0027false\u0027 if they can\u0027t anymore.\r\n     */\r\n    function isIssuable() public view returns (bool success) {\r\n        return _isIssuable;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens redeemed to \u0060_owner\u0060.\r\n     * @param _owner The address from which the amount will be retrieved\r\n     * @return The amount\r\n     */\r\n    function amountRedeemOf(address _owner) public view returns (uint256 amount) {\r\n        return _amountRedeem[_owner];\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens withdrawn by \u0060_owner\u0060.\r\n     * @param _owner The address from which the amount will be retrieved\r\n     * @return The amount\r\n     */\r\n    function amountWithdrawOf(address _owner) public view returns (uint256 amount) {\r\n        return _amountRedeem[_owner];\r\n    }\r\n\r\n    /**\r\n     * @dev Redeem user mintable tokens. Only the mining contract can redeem tokens.\r\n     * @param to The user that will receive the redeemed token.     \r\n     * @param amount The amount of tokens to be withdrawn\r\n     * @return The result of the redeem\r\n     */\r\n    function redeem(address to, uint256 amount) external returns (bool success) {\r\n        require(msg.sender == mintableAddress);    \r\n        require(_isIssuable == true);\r\n        require(amount \u003E 0);\r\n\r\n        // The total amount of redeem tokens to the user.\r\n        _amountRedeem[to] \u002B= amount;\r\n\r\n        // Mint new tokens and send the funds to the account \u0060mintableAddress\u0060\r\n        // Users can withdraw funds.\r\n        mintToken(mintableAddress, amount);\r\n\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev The user can withdraw his minted tokens.\r\n     * @param amount The amount of tokens to be withdrawn\r\n     * @return The result of the withdraw\r\n     */\r\n    function withdraw(uint256 amount) public returns (bool success) {\r\n        require(_isIssuable == true);\r\n\r\n        // Safety check\r\n        require(amount \u003E 0);        \r\n        require(amount \u003C= _amountRedeem[msg.sender]);\r\n        require(amount \u003E= MIN_WITHDRAW_AMOUNT);\r\n\r\n        // Transfer the amount of tokens in the mining contract \u0060mintableAddress\u0060 to the user account\r\n        require(balances[mintableAddress] \u003E= amount);\r\n\r\n        // The balance of the user redeemed tokens.\r\n        _amountRedeem[msg.sender] -= amount;\r\n\r\n        // Keep track of the tokens minted by the user.\r\n        _amountMinted[msg.sender] \u002B= amount;\r\n\r\n        balances[mintableAddress] -= amount;\r\n        balances[msg.sender] \u002B= amount;\r\n        \r\n        emit Transfer(mintableAddress, msg.sender, amount);\r\n        return true;               \r\n    }\r\n\r\n    /**\r\n     * @dev Setup the contract address that can mint tokens\r\n     * @param _mintable The address of the smart contract\r\n     * @return The result of the setup\r\n     */\r\n    function setupMintableAddress(address _mintable) public onlyOwner returns (bool success) {\r\n        mintableAddress = _mintable;\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Mint an amount of tokens and transfer to the user\r\n     * @param to The address of the user who will receive the tokens\r\n     * @param amount The amount of rewarded tokens\r\n     * @return The result of token transfer\r\n     */\r\n    function mintToken(address to, uint256 amount) public returns (bool success) {\r\n        require(msg.sender == mintableAddress);\r\n        require(balances[multiSigWallet] \u003E= amount);\r\n\r\n        balances[multiSigWallet] -= amount;\r\n        balances[to] \u002B= amount;\r\n\r\n        emit Transfer(multiSigWallet, to, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Suspend the issuance of new tokens.\r\n     * Once set to false, \u0027_isIssuable\u0027 can never be set to \u0027true\u0027 again.\r\n     */\r\n    function setMinWithdrawAmount(uint256 amount) public onlyOwner returns (bool success) {\r\n        require(amount \u003E 0);\r\n        MIN_WITHDRAW_AMOUNT = amount;\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Resume the issuance of new tokens.\r\n     * Once set to false, \u0027_isIssuable\u0027 can never be set to \u0027true\u0027 again.\r\n     */\r\n    function getMinWithdrawAmount() public view returns (uint256 amount) {\r\n        return MIN_WITHDRAW_AMOUNT;\r\n    }\r\n\r\n    /**\r\n     * @dev Freeze an user\r\n     * @param account The address of the user who will be frozen\r\n     * @return The result of freezing an user\r\n     */\r\n    function freezeAccount(address account) public onlyOwner returns (bool) {\r\n        require(!frozenAccount[account]);\r\n        frozenAccount[account] = true;\r\n        emit Freeze(account);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Unfreeze an user\r\n     * @param account The address of the user who will be unfrozen\r\n     * @return The result of unfreezing an user\r\n     */\r\n    function unfreezeAccount(address account) public onlyOwner returns (bool) {\r\n        require(frozenAccount[account]);\r\n        frozenAccount[account] = false;\r\n        emit Unfreeze(account);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev This function makes it easy to get the creator of the tokens\r\n     * @return The address of token creator\r\n     */\r\n    function getCreator() external view returns (address) {\r\n        return owner;\r\n    }\r\n\r\n    /**\r\n     * @dev This function makes it easy to get the mintableAddress\r\n     * @return The address of token creator\r\n     */\r\n    function getMintableAddress() external view returns (address) {\r\n        return mintableAddress;\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_multiSigWallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Freeze\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Paused\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Unfreeze\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Unpaused\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MIN_WITHDRAW_AMOUNT\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowed\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022amountRedeemOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022amountWithdrawOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balances\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022freezeAccount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022frozenAccount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCreator\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getMinWithdrawAmount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getMintableAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isIssuable\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022mintToken\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022mintableAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022multiSigWallet\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022newOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022redeem\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022resumeIssuance\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setMinWithdrawAmount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_mintable\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setupMintableAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022suspendIssuance\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022unfreezeAccount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022version\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"FlowchainToken","CompilerVersion":"v0.5.16\u002Bcommit.9c3226ce","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000009581973c54fce63d0f5c4c706020028af20ff723","Library":"","SwarmSource":"bzzr://cc95b1a1b607185ad9beda091fbd3deb8b785c5879f1302ac821219bbd858c74"}]