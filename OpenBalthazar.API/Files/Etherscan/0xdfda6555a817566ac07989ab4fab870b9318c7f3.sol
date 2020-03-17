[{"SourceCode":"pragma solidity ^0.4.25;\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n        uint256 c = a * b;\r\n        assert(c / a == b);\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n        return c;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n}\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n    address public owner;\r\n\r\n    /**\r\n      * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n      * account.\r\n      */\r\n    function Ownable() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    /**\r\n      * @dev Throws if called by any account other than the owner.\r\n      */\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n    /**\r\n    * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n    * @param newOwner The address to transfer ownership to.\r\n    */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        if (newOwner != address(0)) {\r\n            owner = newOwner;\r\n        }\r\n    }\r\n\r\n}\r\n\r\n/**\r\n * @title ERC20Basic\r\n * @dev Simpler version of ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ncontract ERC20Basic {\r\n    uint public _totalSupply;\r\n    function totalSupply() public constant returns (uint);\r\n    function balanceOf(address who) public constant returns (uint);\r\n    function transfer(address to, uint value) public;\r\n    event Transfer(address indexed from, address indexed to, uint value);\r\n}\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ncontract ERC20 is ERC20Basic {\r\n    function allowance(address owner, address spender) public constant returns (uint);\r\n    function transferFrom(address from, address to, uint value) public;\r\n    function approve(address spender, uint value) public;\r\n    event Approval(address indexed owner, address indexed spender, uint value);\r\n}\r\n\r\n/**\r\n * @title Basic token\r\n * @dev Basic version of StandardToken, with no allowances.\r\n */\r\ncontract BasicToken is Ownable, ERC20Basic {\r\n    using SafeMath for uint;\r\n\r\n    mapping(address =\u003E uint) public balances;\r\n\r\n    // additional variables for use if transaction fees ever became necessary\r\n    uint public basisPointsRate = 0;\r\n    uint public maximumFee = 0;\r\n\r\n    /**\r\n    * @dev Fix for the ERC20 short address attack.\r\n    */\r\n    modifier onlyPayloadSize(uint size) {\r\n        require(!(msg.data.length \u003C size \u002B 4));\r\n        _;\r\n    }\r\n\r\n    /**\r\n    * @dev transfer token for a specified address\r\n    * @param _to The address to transfer to.\r\n    * @param _value The amount to be transferred.\r\n    */\r\n    function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) {\r\n        uint fee = (_value.mul(basisPointsRate)).div(10000);\r\n        if (fee \u003E maximumFee) {\r\n            fee = maximumFee;\r\n        }\r\n        uint sendAmount = _value.sub(fee);\r\n        balances[msg.sender] = balances[msg.sender].sub(_value);\r\n        balances[_to] = balances[_to].add(sendAmount);\r\n        if (fee \u003E 0) {\r\n            balances[owner] = balances[owner].add(fee);\r\n            Transfer(msg.sender, owner, fee);\r\n        }\r\n        Transfer(msg.sender, _to, sendAmount);\r\n    }\r\n\r\n    /**\r\n    * @dev Gets the balance of the specified address.\r\n    * @param _owner The address to query the the balance of.\r\n    * @return An uint representing the amount owned by the passed address.\r\n    */\r\n    function balanceOf(address _owner) public constant returns (uint balance) {\r\n        return balances[_owner];\r\n    }\r\n\r\n}\r\n\r\n/**\r\n * @title Standard ERC20 token\r\n *\r\n * @dev Implementation of the basic standard token.\r\n * @dev https://github.com/ethereum/EIPs/issues/20\r\n * @dev Based oncode by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol\r\n */\r\ncontract StandardToken is BasicToken, ERC20 {\r\n\r\n    mapping (address =\u003E mapping (address =\u003E uint)) public allowed;\r\n\r\n    uint public constant MAX_UINT = 2**256 - 1;\r\n\r\n    /**\r\n    * @dev Transfer tokens from one address to another\r\n    * @param _from address The address which you want to send tokens from\r\n    * @param _to address The address which you want to transfer to\r\n    * @param _value uint the amount of tokens to be transferred\r\n    */\r\n    function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) {\r\n        var _allowance = allowed[_from][msg.sender];\r\n\r\n        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met\r\n        // if (_value \u003E _allowance) throw;\r\n\r\n        uint fee = (_value.mul(basisPointsRate)).div(10000);\r\n        if (fee \u003E maximumFee) {\r\n            fee = maximumFee;\r\n        }\r\n        if (_allowance \u003C MAX_UINT) {\r\n            allowed[_from][msg.sender] = _allowance.sub(_value);\r\n        }\r\n        uint sendAmount = _value.sub(fee);\r\n        balances[_from] = balances[_from].sub(_value);\r\n        balances[_to] = balances[_to].add(sendAmount);\r\n        if (fee \u003E 0) {\r\n            balances[owner] = balances[owner].add(fee);\r\n            Transfer(_from, owner, fee);\r\n        }\r\n        Transfer(_from, _to, sendAmount);\r\n    }\r\n\r\n    /**\r\n    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\r\n    * @param _spender The address which will spend the funds.\r\n    * @param _value The amount of tokens to be spent.\r\n    */\r\n    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {\r\n\r\n        // To change the approve amount you first have to reduce the addresses\u0060\r\n        //  allowance to zero by calling \u0060approve(_spender, 0)\u0060 if it is not\r\n        //  already 0 to mitigate the race condition described here:\r\n        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n        require(!((_value != 0) \u0026\u0026 (allowed[msg.sender][_spender] != 0)));\r\n\r\n        allowed[msg.sender][_spender] = _value;\r\n        Approval(msg.sender, _spender, _value);\r\n    }\r\n\r\n    /**\r\n    * @dev Function to check the amount of tokens than an owner allowed to a spender.\r\n    * @param _owner address The address which owns the funds.\r\n    * @param _spender address The address which will spend the funds.\r\n    * @return A uint specifying the amount of tokens still available for the spender.\r\n    */\r\n    function allowance(address _owner, address _spender) public constant returns (uint remaining) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n\r\n}\r\n\r\n\r\n/**\r\n * @title Pausable\r\n * @dev Base contract which allows children to implement an emergency stop mechanism.\r\n */\r\ncontract Pausable is Ownable {\r\n  event Pause();\r\n  event Unpause();\r\n\r\n  bool public paused = false;\r\n\r\n\r\n  /**\r\n   * @dev Modifier to make a function callable only when the contract is not paused.\r\n   */\r\n  modifier whenNotPaused() {\r\n    require(!paused);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Modifier to make a function callable only when the contract is paused.\r\n   */\r\n  modifier whenPaused() {\r\n    require(paused);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev called by the owner to pause, triggers stopped state\r\n   */\r\n  function pause() onlyOwner whenNotPaused public {\r\n    paused = true;\r\n    Pause();\r\n  }\r\n\r\n  /**\r\n   * @dev called by the owner to unpause, returns to normal state\r\n   */\r\n  function unpause() onlyOwner whenPaused public {\r\n    paused = false;\r\n    Unpause();\r\n  }\r\n}\r\n\r\ncontract BlackList is Ownable, BasicToken {\r\n\r\n    function getBlackListStatus(address _maker) external constant returns (bool) {\r\n        return isBlackListed[_maker];\r\n    }\r\n\r\n    function getOwner() external constant returns (address) {\r\n        return owner;\r\n    }\r\n\r\n    mapping (address =\u003E bool) public isBlackListed;\r\n    \r\n    function addBlackList (address _evilUser) public onlyOwner {\r\n        isBlackListed[_evilUser] = true;\r\n        AddedBlackList(_evilUser);\r\n    }\r\n\r\n    function removeBlackList (address _clearedUser) public onlyOwner {\r\n        isBlackListed[_clearedUser] = false;\r\n        RemovedBlackList(_clearedUser);\r\n    }\r\n\r\n    function destroyBlackFunds (address _blackListedUser) public onlyOwner {\r\n        require(isBlackListed[_blackListedUser]);\r\n        uint dirtyFunds = balanceOf(_blackListedUser);\r\n        balances[_blackListedUser] = 0;\r\n        _totalSupply -= dirtyFunds;\r\n        DestroyedBlackFunds(_blackListedUser, dirtyFunds);\r\n    }\r\n\r\n    event DestroyedBlackFunds(address _blackListedUser, uint _balance);\r\n\r\n    event AddedBlackList(address _user);\r\n\r\n    event RemovedBlackList(address _user);\r\n\r\n}\r\n\r\ncontract UpgradedStandardToken is StandardToken{\r\n    // those methods are called by the legacy contract\r\n    // and they must ensure msg.sender to be the contract address\r\n    function transferByLegacy(address from, address to, uint value) public;\r\n    function transferFromByLegacy(address sender, address from, address spender, uint value) public;\r\n    function approveByLegacy(address from, address spender, uint value) public;\r\n}\r\n\r\ncontract UDT is Pausable, StandardToken, BlackList {\r\n\r\n    string public name;\r\n    string public symbol;\r\n    uint public decimals;\r\n    address public upgradedAddress;\r\n    bool public deprecated;\r\n\r\n    //  The contract can be initialized with a number of tokens\r\n    //  All the tokens are deposited to the owner address\r\n    //\r\n    // @param _balance Initial supply of the contract\r\n    // @param _name Token Name\r\n    // @param _symbol Token symbol\r\n    // @param _decimals Token decimals\r\n    function UDT(uint _initialSupply, string _name, string _symbol, uint _decimals) public {\r\n        _totalSupply = _initialSupply;\r\n        name = _name;\r\n        symbol = _symbol;\r\n        decimals = _decimals;\r\n        balances[owner] = _initialSupply;\r\n        deprecated = false;\r\n    }\r\n\r\n    // Forward ERC20 methods to upgraded contract if this one is deprecated\r\n    function transfer(address _to, uint _value) public whenNotPaused {\r\n        require(!isBlackListed[msg.sender]);\r\n        if (deprecated) {\r\n            return UpgradedStandardToken(upgradedAddress).transferByLegacy(msg.sender, _to, _value);\r\n        } else {\r\n            return super.transfer(_to, _value);\r\n        }\r\n    }\r\n\r\n    // Forward ERC20 methods to upgraded contract if this one is deprecated\r\n    function transferFrom(address _from, address _to, uint _value) public whenNotPaused {\r\n        require(!isBlackListed[_from]);\r\n        if (deprecated) {\r\n            return UpgradedStandardToken(upgradedAddress).transferFromByLegacy(msg.sender, _from, _to, _value);\r\n        } else {\r\n            return super.transferFrom(_from, _to, _value);\r\n        }\r\n    }\r\n\r\n    // Forward ERC20 methods to upgraded contract if this one is deprecated\r\n    function balanceOf(address who) public constant returns (uint) {\r\n        if (deprecated) {\r\n            return UpgradedStandardToken(upgradedAddress).balanceOf(who);\r\n        } else {\r\n            return super.balanceOf(who);\r\n        }\r\n    }\r\n\r\n    // Forward ERC20 methods to upgraded contract if this one is deprecated\r\n    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {\r\n        if (deprecated) {\r\n            return UpgradedStandardToken(upgradedAddress).approveByLegacy(msg.sender, _spender, _value);\r\n        } else {\r\n            return super.approve(_spender, _value);\r\n        }\r\n    }\r\n\r\n    // Forward ERC20 methods to upgraded contract if this one is deprecated\r\n    function allowance(address _owner, address _spender) public constant returns (uint remaining) {\r\n        if (deprecated) {\r\n            return StandardToken(upgradedAddress).allowance(_owner, _spender);\r\n        } else {\r\n            return super.allowance(_owner, _spender);\r\n        }\r\n    }\r\n\r\n    // deprecate current contract in favour of a new one\r\n    function deprecate(address _upgradedAddress) public onlyOwner {\r\n        deprecated = true;\r\n        upgradedAddress = _upgradedAddress;\r\n        Deprecate(_upgradedAddress);\r\n    }\r\n\r\n    // deprecate current contract if favour of a new one\r\n    function totalSupply() public constant returns (uint) {\r\n        if (deprecated) {\r\n            return StandardToken(upgradedAddress).totalSupply();\r\n        } else {\r\n            return _totalSupply;\r\n        }\r\n    }\r\n\r\n    // Issue a new amount of tokens\r\n    // these tokens are deposited into the owner address\r\n    //\r\n    // @param _amount Number of tokens to be issued\r\n    function issue(uint amount) public onlyOwner {\r\n        require(_totalSupply \u002B amount \u003E _totalSupply);\r\n        require(balances[owner] \u002B amount \u003E balances[owner]);\r\n\r\n        balances[owner] \u002B= amount;\r\n        _totalSupply \u002B= amount;\r\n        Issue(amount);\r\n    }\r\n\r\n    // Redeem tokens.\r\n    // These tokens are withdrawn from the owner address\r\n    // if the balance must be enough to cover the redeem\r\n    // or the call will fail.\r\n    // @param _amount Number of tokens to be issued\r\n    function redeem(uint amount) public onlyOwner {\r\n        require(_totalSupply \u003E= amount);\r\n        require(balances[owner] \u003E= amount);\r\n\r\n        _totalSupply -= amount;\r\n        balances[owner] -= amount;\r\n        Redeem(amount);\r\n    }\r\n\r\n    function setParams(uint newBasisPoints, uint newMaxFee) public onlyOwner {\r\n        // Ensure transparency by hardcoding limit beyond which fees can never be added\r\n        require(newBasisPoints \u003C 20);\r\n        require(newMaxFee \u003C 50);\r\n\r\n        basisPointsRate = newBasisPoints;\r\n        maximumFee = newMaxFee.mul(10**decimals);\r\n\r\n        Params(basisPointsRate, maximumFee);\r\n    }\r\n\r\n    // Called when new token are issued\r\n    event Issue(uint amount);\r\n\r\n    // Called when tokens are redeemed\r\n    event Redeem(uint amount);\r\n\r\n    // Called when contract is deprecated\r\n    event Deprecate(address newAddress);\r\n\r\n    // Called if contract ever adds fees\r\n    event Params(uint feeBasisPoints, uint maxFee);\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_upgradedAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022deprecate\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022deprecated\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_evilUser\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addBlackList\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022upgradedAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balances\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022maximumFee\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_maker\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getBlackListStatus\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newBasisPoints\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022newMaxFee\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setParams\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022issue\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022redeem\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022basisPointsRate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isBlackListed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_clearedUser\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022removeBlackList\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MAX_UINT\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_blackListedUser\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022destroyBlackFunds\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_initialSupply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_symbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_decimals\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Issue\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Redeem\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022newAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Deprecate\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022feeBasisPoints\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022maxFee\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Params\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_blackListedUser\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022DestroyedBlackFunds\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022AddedBlackList\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022RemovedBlackList\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Pause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Unpause\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"UDT","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000000000000000000000000000008ac7230489e80000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000003554454000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000035544540000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://957a0f9dcab81e705df624fc799cd449c748992e46b50f925eba396dc7bcecaa"}]