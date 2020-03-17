[{"SourceCode":"pragma solidity ^0.5.1;\r\n\r\n\r\nlibrary SafeMath {\r\n\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n        uint256 c = a * b;\r\n        assert(c / a == b);\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n        return c;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n    \r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n\r\n        uint256 c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n}\r\n\r\n\r\ncontract ERC223Interface {\r\n    uint public totalSupply;\r\n    function balanceOf(address who) public view returns (uint);\r\n    function transfer(address to, uint value) public;\r\n    function transfer(address to, uint value, bytes memory data) public;\r\n    event Transfer(address indexed from, address indexed to, uint value, bytes data);\r\n}\r\n\r\n\r\n/**\r\n * @title Contract that will work with ERC223 tokens.\r\n * source: https://github.com/ethereum/EIPs/issues/223\r\n */\r\ninterface ERC223ReceivingContract {\r\n    /**\r\n     * @dev Standard ERC223 function that will handle incoming token transfers.\r\n     *\r\n     * @param from  Token sender address.\r\n     * @param value Amount of tokens.\r\n     * @param data  Transaction metadata.\r\n     */\r\n    function tokenFallback( address from, uint value, bytes calldata data ) external;\r\n}\r\n\r\n\r\n/**\r\n * @title Ownership\r\n * @author Prashant Prabhakar Singh\r\n * @dev Contract that allows to hande ownership of contract\r\n */\r\ncontract Ownership {\r\n\r\n    address public owner;\r\n    event LogOwnershipTransferred(address indexed oldOwner, address indexed newOwner);\r\n\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    modifier onlyOwner {\r\n        require(msg.sender == owner, \u0022Only owner is allowed\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of contract to other address\r\n     * @param _newOwner address The address of new owner\r\n     */\r\n    function transferOwnership(address _newOwner)\r\n        public\r\n        onlyOwner\r\n    {\r\n        require(_newOwner != address(0), \u0022Zero address not allowed\u0022);\r\n        address oldOwner = owner;\r\n        owner = _newOwner;\r\n        emit LogOwnershipTransferred(oldOwner, _newOwner);\r\n    }\r\n\r\n}\r\n\r\n/**\r\n * @title Freezable\r\n * @author Prashant Prabhakar Singh\r\n * @dev Contract that allows freezing/unfreezing an address or complete contract\r\n */\r\ncontract Freezable is Ownership {\r\n\r\n    bool public emergencyFreeze;\r\n    mapping (address =\u003E bool) public frozen;\r\n\r\n    event LogFreezed(address indexed target, bool indexed freezeStatus);\r\n    event LogEmergencyFreezed(bool emergencyFreezeStatus);\r\n\r\n    modifier unfreezed(address _account) {\r\n        require(!frozen[_account], \u0022Account is unfreezed\u0022);\r\n        _;\r\n    }\r\n\r\n    modifier noEmergencyFreeze() {\r\n        require(!emergencyFreeze, \u0022Account is freezed\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Freezes or unfreezes an addreess\r\n     * this does not check for previous state before applying new state\r\n     * @param _target the address which will be feeezed.\r\n     * @param _freeze boolean status. Use true to freeze and false to unfreeze.\r\n     */\r\n    function freezeAccount (address _target, bool _freeze)\r\n        public\r\n        onlyOwner\r\n    {\r\n        require(_target != address(0), \u0022Zero address not allowed\u0022);\r\n        frozen[_target] = _freeze;\r\n        emit LogFreezed(_target, _freeze);\r\n    }\r\n\r\n   /**\r\n     * @dev Freezes or unfreezes the contract\r\n     * this does not check for previous state before applying new state\r\n     * @param _freeze boolean status. Use true to freeze and false to unfreeze.\r\n     */\r\n    function emergencyFreezeAllAccounts (bool _freeze)\r\n        public\r\n        onlyOwner\r\n    {\r\n        emergencyFreeze = _freeze;\r\n        emit LogEmergencyFreezed(_freeze);\r\n    }\r\n}\r\n\r\n\r\n/**\r\n * @title Standard Token\r\n * @author Prashant Prabhakar Singh\r\n * @dev A Standard Token contract that follows ERC-223 standard\r\n */\r\ncontract StandardToken is ERC223Interface, Freezable {\r\n\r\n    using SafeMath for uint;\r\n\r\n    string public name;\r\n    string public symbol;\r\n    uint public decimals;\r\n    uint public totalSupply;\r\n    uint public currentSupply;\r\n\r\n    mapping (address =\u003E uint) internal balances;\r\n    mapping (address =\u003E mapping (address =\u003E uint) ) private  allowed;\r\n\r\n    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);\r\n\r\n    constructor () public {\r\n        name = \u0027Cryptonity Exchange\u0027;\r\n        symbol = \u0027CNEX\u0027;\r\n        decimals = 8;\r\n        totalSupply = 400000000 * ( 10 ** decimals ); // 400 million\r\n    }\r\n\r\n    /**\r\n     * @dev Transfer the specified amount of tokens to the specified address.\r\n     *      Invokes the \u0060tokenFallback\u0060 function if the recipient is a contract.\r\n     *      The token transfer fails if the recipient is a contract\r\n     *      but does not implement the \u0060tokenFallback\u0060 function\r\n     *      or the fallback function to receive funds.\r\n     *\r\n     *   Compitable wit ERC-20 Standard\r\n     *\r\n     * @param _to    Receiver address.\r\n     * @param _value Amount of tokens that will be transferred.\r\n     */\r\n    function transfer(address _to, uint _value)\r\n        public\r\n        unfreezed(_to)\r\n        unfreezed(msg.sender)\r\n        noEmergencyFreeze()\r\n    {\r\n        bytes memory _data;\r\n        _transfer223(msg.sender, _to, _value, _data);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfer the specified amount of tokens to the specified address.\r\n     *      Invokes the \u0060tokenFallback\u0060 function if the recipient is a contract.\r\n     *      The token transfer fails if the recipient is a contract\r\n     *      but does not implement the \u0060tokenFallback\u0060 function\r\n     *      or the fallback function to receive funds.\r\n     *\r\n     * @param _to    Receiver address.\r\n     * @param _value Amount of tokens that will be transferred.\r\n     * @param _data  Transaction metadata.\r\n     */\r\n    function transfer(address _to, uint _value, bytes memory _data)\r\n        public\r\n        unfreezed(_to)\r\n        unfreezed(msg.sender)\r\n        noEmergencyFreeze()\r\n    {\r\n        _transfer223(msg.sender, _to, _value, _data);\r\n    }\r\n\r\n    /**\r\n     * @dev Utility method to check if an address is contract address\r\n     *\r\n     * @param _addr address which is being checked.\r\n     * @return true if address belongs to a contract else returns false\r\n     */\r\n    function isContract( address _addr )\r\n        private\r\n        view\r\n        returns (bool)\r\n    {\r\n        uint length;\r\n        assembly { length := extcodesize(_addr) }\r\n        return (length \u003E 0);\r\n    }\r\n\r\n    /**\r\n     * @dev To change the approve amount you first have to reduce the addresses\r\n     * allowance to zero by calling \u0060approve(_spender, 0)\u0060 if it is not\r\n     * already 0 to mitigate the race condition described here\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     * Recommended is to use increase approval and decrease approval instead\r\n     *\r\n     * Requires either that _value of allwance is 0\r\n     * @param _spender address who is allowed to spend\r\n     * @param _value the no of tokens spender can spend\r\n     * @return true if everything goes well\r\n     */\r\n    function approve(address _spender, uint _value)\r\n        public\r\n        unfreezed(_spender)\r\n        unfreezed(msg.sender)\r\n        noEmergencyFreeze()\r\n        returns (bool success)\r\n    {\r\n        require((_value == 0) || (allowed[msg.sender][_spender] == 0), \u0022Approval needs to be 0 first\u0022);\r\n        require(_spender != msg.sender, \u0022Can not approve to self\u0022);\r\n        allowed[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev increases current allowance\r\n     *\r\n     * @param _spender address who is allowed to spend\r\n     * @param _addedValue the no of tokens added to previous allowance\r\n     * @return true if everything goes well\r\n     */\r\n    function increaseApproval(address _spender, uint _addedValue)\r\n        public\r\n        unfreezed(_spender)\r\n        unfreezed(msg.sender)\r\n        noEmergencyFreeze()\r\n        returns (bool success)\r\n    {\r\n        require(_spender != msg.sender, \u0022Can not approve to self\u0022);\r\n        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);\r\n        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev decrease current allowance\r\n     * @param _spender address who is allowed to spend\r\n     * @param _subtractedValue the no of tokens deducted to previous allowance\r\n     * If _subtractedValue is greater than prev allowance, allowance becomes 0\r\n     * @return true if everything goes well\r\n     */\r\n    function decreaseApproval(address _spender, uint _subtractedValue)\r\n        public\r\n        unfreezed(_spender)\r\n        unfreezed(msg.sender)\r\n        noEmergencyFreeze()\r\n        returns (bool success)\r\n    {\r\n        require(_spender != msg.sender, \u0022Can not approve to self\u0022);\r\n        uint oldAllowance = allowed[msg.sender][_spender];\r\n        if (_subtractedValue \u003E oldAllowance) {\r\n            allowed[msg.sender][_spender] = 0;\r\n        } else {\r\n            allowed[msg.sender][_spender] = oldAllowance.sub(_subtractedValue);\r\n        }\r\n        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Transfer tokens from one address to another.\r\n     * @param _from address The address from which you want to send tokens.\r\n     * @param _to address The address to which you want to transfer tokens.\r\n     * @param _value uint256 the amount of tokens to be transferred.\r\n     */\r\n    function transferFrom(address _from, address _to, uint _value)\r\n        public\r\n        unfreezed(_to)\r\n        unfreezed(msg.sender)\r\n        noEmergencyFreeze()\r\n        returns (bool success)\r\n    {\r\n        require(_value \u003C= allowed[_from][msg.sender], \u0022insufficient allowance\u0022);\r\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n        bytes memory _data;\r\n        _transfer223(_from, _to, _value, _data);\r\n        return true;\r\n    }\r\n\r\n      /**\r\n     * @dev Transfer tokens from one address to another.\r\n     * @param _from address The address from which you want to send tokens.\r\n     * @param _to address The address to which you want to transfer tokens.\r\n     * @param _value uint256 the amount of tokens to be transferred\r\n     * @param _data bytes Transaction metadata.\r\n     */\r\n    function transferFrom(address _from, address _to, uint _value, bytes memory _data)\r\n        public\r\n        unfreezed(_to)\r\n        unfreezed(msg.sender)\r\n        noEmergencyFreeze()\r\n        returns (bool success)\r\n    {\r\n        require(_value \u003C= allowed[_from][msg.sender], \u0022insufficient allowance\u0022);\r\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n        _transfer223(_from, _to, _value, _data);\r\n        return true;\r\n    }\r\n\r\n\r\n    /**\r\n     * @dev Function that burns an amount of the token of a sender.\r\n     * reduces total and current supply.\r\n     * only owner is allowed to burn tokens.\r\n     *\r\n     * @param _value The amount that will be burnt.\r\n     */\r\n    function burn(uint256 _value)\r\n        public\r\n        unfreezed(msg.sender)\r\n        noEmergencyFreeze()\r\n        onlyOwner\r\n        returns (bool success)\r\n    {\r\n        require(balances[msg.sender] \u003E= _value, \u0022Insufficinet balance\u0022);\r\n        balances[msg.sender] = balances[msg.sender].sub(_value);\r\n        totalSupply = totalSupply.sub(_value);\r\n        currentSupply = currentSupply.sub(_value);\r\n        bytes memory _data;\r\n        emit Transfer(msg.sender, address(0), _value, _data);\r\n        return true;\r\n    }\r\n\r\n  \r\n    /**\r\n     * @dev Gets the balance of the specified address.\r\n     * @param _tokenOwner The address to query the balance of.\r\n     * @return A uint256 representing the amount owned by the passed address.\r\n     */\r\n    function balanceOf(address _tokenOwner) public view returns (uint) {\r\n        return balances[_tokenOwner];\r\n    }\r\n\r\n    /**\r\n     * @dev Function to check the amount of tokens that an owner allowed to a spender.\r\n     * @param _tokenOwner address The address which owns the funds.\r\n     * @param _spender address The address which will spend the funds.\r\n     * @return A uint256 specifying the amount of tokens still available for the spender.\r\n     */\r\n    function allowance(address _tokenOwner, address _spender) public view returns (uint) {\r\n        return allowed[_tokenOwner][_spender];\r\n    }\r\n\r\n    /**\r\n     * @dev Function to withdraw any accidently sent ERC20 or 223 Token.\r\n     * the value should be pre-multiplied by decimals of token wthdrawan\r\n     * @param _tokenAddress address The contract address of ERC20 token.\r\n     * @param _value uint amount to tokens to be withdrawn\r\n     */\r\n    function transferAnyERC20Token(address _tokenAddress, uint _value)\r\n        public\r\n        onlyOwner\r\n    {\r\n        ERC223Interface(_tokenAddress).transfer(owner, _value);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfer the specified amount of tokens to the specified address.\r\n     *      Invokes the \u0060tokenFallback\u0060 function if the recipient is a contract.\r\n     *      The token transfer fails if the recipient is a contract\r\n     *      but does not implement the \u0060tokenFallback\u0060 function\r\n     *      or the fallback function to receive funds.\r\n     *\r\n     * @param _from Sender address.\r\n     * @param _to    Receiver address.\r\n     * @param _value Amount of tokens that will be transferred.\r\n     * @param _data  Transaction metadata.\r\n     */\r\n    function _transfer223(address _from, address _to, uint _value, bytes memory _data)\r\n        private\r\n    {\r\n        require(_to != address(0), \u0022Zero address not allowed\u0022);\r\n        require(balances[_from] \u003E= _value, \u0022Insufficinet balance\u0022);\r\n        uint balBeforeTransfer = balances[_from].add(balances[_to]);\r\n        balances[_from] = balances[_from].sub(_value);\r\n        balances[_to] = balances[_to].add(_value);\r\n        if (isContract(_to)) {\r\n            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);\r\n            receiver.tokenFallback(msg.sender, _value, _data);\r\n        }\r\n        uint balAfterTransfer = balances[_from].add(balances[_to]);\r\n        assert(balBeforeTransfer == balAfterTransfer);\r\n        emit Transfer(_from, _to, _value, _data); // ERC223-compat version\r\n    }\r\n\r\n}\r\n\r\n/**\r\n * @title CNEX Token\r\n * @author Prashant Prabhakar Singh\r\n * @dev CNEX implementation of ERC-223 standard token\r\n */\r\ncontract CNEXToken is StandardToken {\r\n\r\n    uint public icoFunds;\r\n    uint public consumerProtectionFund;\r\n    uint public ecoSystemDevelopmentAndOperationFund;\r\n    uint public teamAndFounderFund;\r\n\r\n    bool public consumerProtectionFundAllocated = false;\r\n    bool public ecoSystemDevelopmentAndOperationFundAllocated = false;\r\n    bool public teamAndFounderFundAllocated = false;\r\n\r\n    uint public tokenDeploymentTime;\r\n\r\n    constructor() public StandardToken(){\r\n        owner = msg.sender;\r\n        icoFunds = 200000000 * (10 ** decimals); // 200 million\r\n        consumerProtectionFund = 60000000 * (10 ** decimals); // 60 million\r\n        ecoSystemDevelopmentAndOperationFund = 100000000 * (10 ** decimals); // 100 million\r\n        teamAndFounderFund = 40000000 * (10 ** decimals); // 40 million\r\n        tokenDeploymentTime = now;\r\n        _mint(msg.sender, icoFunds);\r\n    }\r\n    \r\n    /**\r\n     * @dev Function to mint tokens allocated for consumer\r\n     * protection to owner address. Owner then sends them\r\n     * to responsible parties\r\n     */\r\n    function allocateConsumerProtectionFund()\r\n        public\r\n        onlyOwner\r\n    {\r\n        require(!consumerProtectionFundAllocated, \u0022Already allocated\u0022);\r\n        consumerProtectionFundAllocated = true;\r\n        _mint(owner, consumerProtectionFund);\r\n    }\r\n\r\n    /**\r\n     * @dev Function to mint tokens allocated for Ecosystem development\r\n     * and operations to owner address. Owner then sends them\r\n     * to responsible parties\r\n     */\r\n    function allocateEcoSystemDevelopmentAndOperationFund()\r\n        public\r\n        onlyOwner\r\n    {\r\n        require(!ecoSystemDevelopmentAndOperationFundAllocated, \u0022Already allocated\u0022);\r\n        ecoSystemDevelopmentAndOperationFundAllocated = true;\r\n        _mint(owner, ecoSystemDevelopmentAndOperationFund);\r\n    }\r\n    \r\n    /**\r\n     * @dev Function to mint tokens allocated for team\r\n     * and founders to owner address. Owner then sends them\r\n     * to responsible parties.\r\n     * Tokens are loacked for 1 year and can be claimed after 1 year\r\n     * from date of deployment\r\n     */\r\n    function allocateTeamAndFounderFund()\r\n        public\r\n        onlyOwner\r\n    {\r\n        require(!teamAndFounderFundAllocated, \u0022Already allocated\u0022);\r\n        require(now \u003E tokenDeploymentTime \u002B 365 days, \u0022Vesting period no over yet\u0022);\r\n        teamAndFounderFundAllocated = true;\r\n        _mint(owner, teamAndFounderFund);\r\n    }\r\n\r\n    /**\r\n     * @dev Function to mint tokens\r\n     * @param _to The address that will receive the minted tokens.\r\n     * @param _value The amount of tokens to mint.\r\n     */\r\n    function _mint(address _to, uint _value)\r\n        private\r\n        onlyOwner\r\n    {\r\n        require(currentSupply.add(_value) \u003C= totalSupply, \u0022Exceeds total supply\u0022);\r\n        balances[_to] = balances[_to].add(_value);\r\n        currentSupply = currentSupply.add(_value);\r\n        bytes memory _data;\r\n        emit Transfer(address(0), _to, _value, _data);\r\n    }\r\n    \r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022allocateEcoSystemDevelopmentAndOperationFund\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ecoSystemDevelopmentAndOperationFund\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ecoSystemDevelopmentAndOperationFundAllocated\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022allocateTeamAndFounderFund\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022teamAndFounderFundAllocated\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022currentSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_freeze\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022emergencyFreezeAllAccounts\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022consumerProtectionFund\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tokenDeploymentTime\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022teamAndFounderFund\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022consumerProtectionFundAllocated\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022allocateConsumerProtectionFund\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022frozen\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferAnyERC20Token\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_freeze\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022freezeAccount\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022icoFunds\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022emergencyFreeze\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022freezeStatus\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022LogFreezed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022emergencyFreezeStatus\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022LogEmergencyFreezed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022oldOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogOwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"CNEXToken","CompilerVersion":"v0.5.4\u002Bcommit.9549d8ff","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://0f52c311a0948675bbf214c863d62aa2836b6411ffc8a6785fd2fd9b70c5ded3"}]