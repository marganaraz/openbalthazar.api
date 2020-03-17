[{"SourceCode":"pragma solidity \u003E=0.4.21 \u003C0.6.0;\r\n//\r\n/**\r\n * @title RahimCoin ERC20 Token\r\n * @title https://rahimblak.com  \r\n * @dev Token code : RCE\r\n */\r\ninterface ERC20 {\r\n    function balanceOf(address who) external view returns (uint256);\r\n    function transfer(address to, uint256 value) external returns (bool);\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\r\n    function approve(address spender, uint256 value) external returns (bool);\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n//\r\n/**\r\n * @title Interface for handling voluntary token upgrade\r\n *\r\n * @notice ERC20 has some known flaws, but no other standard is so widely accepted \r\n * @notice at a time this text is written. We can not stick to this standard forever, so we \r\n * @notice added this functionality for future use, but without posibility to force anyone to migrate.\r\n * @notice Burn function can be invoked only by UpgradeContract in case of a token\r\n * @notice exchange, to persist total supply at constant 100 million.\r\n * @notice The only way to upgrade Sapiency token will be through upgrade contract at\r\n * @notice upgradeContract address. Sapiency is made to last, so we have to have  \r\n * @notice a possibility to support expected functionality in the future.\r\n *\r\n * @notice Pros: Owner cannot change contract to change the rules without community acceptance\r\n * @notice Cons: Upgraded contract will have new address\r\n * @notice Cons: For some time both version would still be in active use at the same time\r\n */\r\ninterface TokenVoluntaryUpgrade {\r\n    function setUpgradeContract(address _upgradeContractAddress) external returns(bool);\r\n    function burnAfterUpgrade(uint256 value) external returns (bool success);\r\n    event UpgradeContractChange(address owner, address indexed _exchangeContractAddress);\r\n    event UpgradeBurn(address indexed _exchangeContract, uint256 _value);\r\n}\r\n//\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        //\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n        uint256 c = a * b;\r\n        assert(c / a == b);\r\n        return c;\r\n    }\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n        return c;\r\n    }\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n    function uintSub(uint a, uint b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n}\r\n// https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol\r\n// b7d60f2f9a849c5c2d59e24062f9c09f3390487a\r\n// with some minor changes\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n    address private _owner;\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n    /**\r\n     * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n     * account.\r\n     */\r\n    constructor () internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n    /**\r\n     * @return the address of the owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Only owner can do that\u0022);\r\n        _;\r\n    }\r\n    /**\r\n     * @return true if \u0060msg.sender\u0060 is the owner of the contract.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return msg.sender == _owner;\r\n    }\r\n    /**\r\n     * @dev Allows the current owner to relinquish control of the contract.\r\n     * @notice Renouncing to ownership will leave the contract without an owner.\r\n     * It will not be possible to call the functions with the \u0060onlyOwner\u0060\r\n     * modifier anymore.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n    /**\r\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n    /**\r\n     * @dev Transfers control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022newOwner parameter must be set\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n//\r\n//\r\ncontract RahimCoinToken is Ownable, TokenVoluntaryUpgrade  {\r\n    string  internal _name              = \u0022RahimCoin ERC20\u0022;\r\n    string  internal _symbol            = \u0022RCE\u0022;\r\n    string  internal _standard          = \u0022ERC20\u0022;\r\n    uint8   internal _decimals          = 18;\r\n    uint     internal _totalSupply      = 1000000 * 1 ether;\r\n    //\r\n    string  internal _trustedIPNS       = \u0022\u0022;\r\n    //\r\n    address internal _upgradeContract   = address(0);\r\n    //\r\n    mapping(address =\u003E uint256)                     internal balances;\r\n    mapping(address =\u003E mapping(address =\u003E uint256)) internal allowed;\r\n    //\r\n    event Transfer(\r\n        address indexed _from,\r\n        address indexed _to,\r\n        uint256 _value\r\n    );\r\n    //\r\n    event Approval(\r\n        address indexed _owner,\r\n        address indexed _spender,\r\n        uint256 _value\r\n    );\r\n    //\r\n    event UpgradeContractChange(\r\n        address owner,\r\n        address indexed _exchangeContractAddress\r\n    );\r\n    //\r\n    event UpgradeBurn(\r\n        address indexed _upgradeContract,\r\n        uint256 _value\r\n    );\r\n    //\r\n    constructor () public Ownable() {\r\n        balances[msg.sender] = totalSupply();\r\n    }\r\n    // Try to prevent sending ETH to SmartContract by mistake.\r\n    function () external payable  {\r\n        revert(\u0022This SmartContract is not payable\u0022);\r\n    }\r\n    //\r\n    // Getters and Setters\r\n    //\r\n    function name() public view returns (string memory) {\r\n        return _name;\r\n    }\r\n    //\r\n    function symbol() public view returns (string memory) {\r\n        return _symbol;\r\n    }\r\n    //\r\n    function standard() public view returns (string memory) {\r\n        return _standard;\r\n    }\r\n    //\r\n    function decimals() public view returns (uint8) {\r\n        return _decimals;\r\n    }\r\n    //\r\n    function totalSupply() public view returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n    //\r\n    // Contract common functions\r\n    //\r\n    function transfer(address _to, uint256 _value) public returns (bool) {\r\n        //\r\n        require(_to != address(0), \u0022\u0027_to\u0027 address has to be set\u0022);\r\n        require(_value \u003C= balances[msg.sender], \u0022Insufficient balance\u0022);\r\n        //\r\n        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);\r\n        balances[_to] = SafeMath.add(balances[_to], _value);\r\n        //\r\n        emit Transfer(msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n    //\r\n    function approve(address _spender, uint256 _value) public returns (bool success) {\r\n        require (_spender != address(0), \u0022_spender address has to be set\u0022);\r\n        require (_value \u003E 0, \u0022\u0027_value\u0027 parameter has to greater than 0\u0022);\r\n        //\r\n        allowed[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n    //\r\n    function safeApprove(address _spender, uint256 _currentValue, uint256 _value)  public returns (bool success) {\r\n        // If current allowance for _spender is equal to _currentValue, then\r\n        // overwrite it with _value and return true, otherwise return false.\r\n        if (allowed[msg.sender][_spender] == _currentValue) return approve(_spender, _value);\r\n        return false;\r\n    }\r\n    //\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {\r\n        //\r\n        require(_from != address(0), \u0022\u0027_from\u0027 address has to be set\u0022);\r\n        require(_to != address(0), \u0022\u0027_to\u0027 address has to be set\u0022);\r\n        require(_value \u003C= balances[_from], \u0022Insufficient balance\u0022);\r\n        require(_value \u003C= allowed[_from][msg.sender], \u0022Insufficient allowance\u0022);\r\n        //\r\n        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);\r\n        balances[_from] = SafeMath.sub(balances[_from], _value);\r\n        balances[_to] = SafeMath.add(balances[_to], _value);\r\n        //\r\n        emit Transfer(_from, _to, _value);\r\n        //\r\n        return true;\r\n    }\r\n    //\r\n    function allowance(address _owner, address _spender) public view returns (uint256) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n    //\r\n    function balanceOf(address _owner) public view returns (uint256) {\r\n        return balances[_owner];\r\n    }\r\n    // Voluntary token upgrade logic\r\n    //\r\n    /**\r\n     * @dev Gets trusted IPNS address\r\n     */\r\n    function trustedIPNS() public view returns(string memory) {\r\n        return  _trustedIPNS;\r\n    }\r\n    /** \r\n    * @dev Sets trusted IPNS address for use communication chanel for Sapiency Team\r\n    * @notice For future use - this variable is not used in contract logic and plays olny information role using blockchain as trusted medium\r\n    */\r\n    function setTrustedIPNS(string memory _trustedIPNSparam) public onlyOwner returns(bool) {\r\n        _trustedIPNS = _trustedIPNSparam;\r\n        return true;\r\n    }\r\n    //\r\n    /** \r\n     * @dev Gets SmartContract that could upgrade Tokens - empty == no upgrade\r\n     */\r\n    function upgradeContract() public view returns(address) {\r\n        return _upgradeContract;\r\n    }\r\n    //\r\n    /** \r\n     * @dev Sets SmartContract that could upgrade Tokens to a new version in a future\r\n     */\r\n    function setUpgradeContract(address _upgradeContractAddress) public onlyOwner returns(bool) {\r\n        _upgradeContract = _upgradeContractAddress;\r\n        emit UpgradeContractChange(msg.sender, _upgradeContract);\r\n        //\r\n        return true;\r\n    }\r\n    function burnAfterUpgrade(uint256 _value) public returns (bool success) {\r\n        require(_upgradeContract != address(0), \u0022upgradeContract is not set\u0022);\r\n        require(msg.sender == _upgradeContract, \u0022only upgradeContract can execute token burning\u0022);\r\n        require(_value \u003C= balances[msg.sender], \u0022Insufficient balance\u0022);\r\n        //\r\n        _totalSupply = SafeMath.sub(_totalSupply, _value);\r\n        balances[msg.sender] = SafeMath.sub(balances[msg.sender],_value);\r\n        emit UpgradeBurn(msg.sender, _value);\r\n        //\r\n        return true;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022upgradeContract\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burnAfterUpgrade\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022standard\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_trustedIPNSparam\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022setTrustedIPNS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_upgradeContractAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setUpgradeContract\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022trustedIPNS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_currentValue\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022safeApprove\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_exchangeContractAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022UpgradeContractChange\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_upgradeContract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022UpgradeBurn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"RahimCoinToken","CompilerVersion":"v0.5.0\u002Bcommit.1d4f565a","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"0000000000000000000000000000000000000000000000000000000000001a0a000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000c4d736354657374436f696e31000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000054d5343543100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000054552433230000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://49831d14cee02418c2ead9703c6981b0f4b3d2bb9c0c93584383dd44e7e21bf7"}]