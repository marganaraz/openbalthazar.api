[{"SourceCode":"pragma solidity ^0.4.11;\r\n\r\n// Token Issue Smart Contract for Bitconch Coin\r\n// Symbol       : CGA\r\n// Name         : Bitconch Token\r\n// Total Supply : 0.91 Billion\r\n// Decimal      : 8\r\n// Compiler     : 0.4.11\u002Bcommit.68ef5810.Emscripten.clang\r\n// Optimazation : Yes\r\n\r\n\r\n// @title SafeMath\r\n// @dev Math operations with safety checks that throw on error\r\nlibrary SafeMath {\r\n    function mul(uint256 a, uint256 b) internal constant returns (uint256) {\r\n        uint256 c = a * b;\r\n        assert(a == 0 || c / a == b);\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal constant returns (uint256) {\r\n        assert(b \u003E 0);\r\n        uint256 c = a / b;\r\n        assert(a == b * c \u002B a % b);\r\n        return c;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal constant returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    function add(uint256 a, uint256 b) internal constant returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n}\r\n\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control functions\r\n */\r\ncontract Ownable {\r\n    address public owner;\r\n\r\n    // @dev Constructor sets the original \u0060owner\u0060 of the contract to the sender account.\r\n    function Ownable() {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    // @dev Throws if called by any account other than the owner.\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n\r\n    // @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n    // @param newOwner The address to transfer ownership to.\r\n    function transferOwnership(address newOwner) onlyOwner {\r\n        if (newOwner != address(0)) {\r\n            owner = newOwner;\r\n        }\r\n    }\r\n\r\n}\r\n\r\n\r\n/**\r\n * @title Claimable\r\n * @dev the ownership of contract needs to be claimed.\r\n * This allows the new owner to accept the transfer.\r\n */\r\ncontract Claimable is Ownable {\r\n    address public pendingOwner;\r\n\r\n    // @dev Modifier throws if called by any account other than the pendingOwner.\r\n    modifier onlyPendingOwner() {\r\n        require(msg.sender == pendingOwner);\r\n        _;\r\n    }\r\n\r\n    // @dev Allows the current owner to set the pendingOwner address.\r\n    // @param newOwner The address to transfer ownership to.\r\n    function transferOwnership(address newOwner) onlyOwner {\r\n        pendingOwner = newOwner;\r\n    }\r\n\r\n    // @dev Allows the pendingOwner address to finalize the transfer.\r\n    function claimOwnership() onlyPendingOwner {\r\n        owner = pendingOwner;\r\n        pendingOwner = 0x0;\r\n    }\r\n}\r\n\r\n\r\n/**\r\n * @title Contactable token\r\n * @dev Allowing the owner to provide a string with their contact information.\r\n */\r\ncontract Contactable is Ownable{\r\n\r\n    string public contactInformation;\r\n\r\n    // @dev Allows the owner to set a string with their contact information.\r\n    // @param info The contact information to attach to the contract.\r\n    function setContactInformation(string info) onlyOwner{\r\n        contactInformation = info;\r\n    }\r\n}\r\n\r\n\r\n/**\r\n * @title Contracts that should not own Ether\r\n * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up\r\n * in the contract, it will allow the owner to reclaim this ether.\r\n * @notice Ether can still be send to this contract by:\r\n * calling functions labeled \u0060payable\u0060\r\n * \u0060selfdestruct(contract_address)\u0060\r\n * mining directly to the contract address\r\n*/\r\ncontract HasNoEther is Ownable {\r\n\r\n    /**\r\n    * @dev Constructor that rejects incoming Ether\r\n    * @dev The \u0060payable\u0060 flag is added so we can access \u0060msg.value\u0060 without compiler warning. If we\r\n    * leave out payable, then Solidity will allow inheriting contracts to implement a payable\r\n    * constructor. By doing it this way we prevent a payable constructor from working. Alternatively\r\n    * we could use assembly to access msg.value.\r\n    */\r\n    function HasNoEther() payable {\r\n        require(msg.value == 0);\r\n    }\r\n\r\n    /**\r\n     * @dev Disallows direct send by settings a default function without the \u0060payable\u0060 flag.\r\n     */\r\n    function() external {\r\n    }\r\n\r\n    /**\r\n     * @dev Transfer all Ether held by the contract to the owner.\r\n     */\r\n    function reclaimEther() external onlyOwner {\r\n        assert(owner.send(this.balance));\r\n    }\r\n}\r\n\r\n\r\n/**\r\n * @title Standard ERC20 token\r\n * @dev Implementation of the ERC20Interface\r\n * @dev https://github.com/ethereum/EIPs/issues/20\r\n */\r\ncontract ERC20 {\r\n    using SafeMath for uint256;\r\n\r\n    // private\r\n    mapping(address =\u003E uint256) balances;\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) allowed;\r\n    uint256 _totalSupply;\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n\r\n    // @dev Get the total token supply\r\n    function totalSupply() constant returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    // @dev Gets the balance of the specified address.\r\n    // @param _owner The address to query the the balance of.\r\n    // @return An uint256 representing the amount owned by the passed address.\r\n    function balanceOf(address _owner) constant returns (uint256 balance) {\r\n        return balances[_owner];\r\n    }\r\n\r\n    // @dev transfer token for a specified address\r\n    // @param _to The address to transfer to.\r\n    // @param _value The amount to be transferred.\r\n    function transfer(address _to, uint256 _value) returns (bool) {\r\n        require(_to != 0x0 );\r\n        require(_value \u003E 0 );\r\n\r\n        balances[msg.sender] = balances[msg.sender].sub(_value);\r\n        balances[_to] = balances[_to].add(_value);\r\n\r\n        Transfer(msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    // @dev Transfer tokens from one address to another\r\n    // @param _from address The address which you want to send tokens from\r\n    // @param _to address The address which you want to transfer to\r\n    // @param _value uint256 the amout of tokens to be transfered\r\n    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {\r\n        require(_from != 0x0 );\r\n        require(_to != 0x0 );\r\n        require(_value \u003E 0 );\r\n\r\n        var _allowance = allowed[_from][msg.sender];\r\n\r\n        balances[_to] = balances[_to].add(_value);\r\n        balances[_from] = balances[_from].sub(_value);\r\n        allowed[_from][msg.sender] = _allowance.sub(_value);\r\n\r\n        Transfer(_from, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    // @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.\r\n    // @param _spender The address which will spend the funds.\r\n    // @param _value The amount of tokens to be spent.\r\n    function approve(address _spender, uint256 _value) returns (bool) {\r\n        require(_spender != 0x0 );\r\n        // To change the approve amount you first have to reduce the addresses\u0060\r\n        // allowance to zero by calling \u0060approve(_spender, 0)\u0060 if it is not\r\n        // already 0 to mitigate the race condition described here:\r\n        // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n        require((_value == 0) || (allowed[msg.sender][_spender] == 0));\r\n\r\n        allowed[msg.sender][_spender] = _value;\r\n\r\n        Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    // @dev Function to check the amount of tokens that an owner allowed to a spender.\r\n    // @param _owner address The address which owns the funds.\r\n    // @param _spender address The address which will spend the funds.\r\n    // @return A uint256 specifing the amount of tokens still avaible for the spender.\r\n    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n}\r\n\r\ncontract StandardToken is ERC20 {\r\n    string public name;\r\n    string public symbol;\r\n    uint256 public decimals;\r\n\r\n    function isToken() public constant returns (bool) {\r\n        return true;\r\n    }\r\n}\r\n\r\n/**\r\n * @dev FreezableToken\r\n *\r\n */\r\ncontract FreezableToken is StandardToken, Ownable {\r\n    mapping (address =\u003E bool) public frozenAccounts;\r\n    event FrozenFunds(address target, bool frozen);\r\n\r\n    // @dev freeze account or unfreezen.\r\n    function freezeAccount(address target, bool freeze) onlyOwner {\r\n        frozenAccounts[target] = freeze;\r\n        FrozenFunds(target, freeze);\r\n    }\r\n\r\n    // @dev Limit token transfer if _sender is frozen.\r\n    modifier canTransfer(address _sender) {\r\n        require(!frozenAccounts[_sender]);\r\n\r\n        _;\r\n    }\r\n\r\n    function transfer(address _to, uint256 _value) canTransfer(msg.sender) returns (bool success) {\r\n        // Call StandardToken.transfer()\r\n        return super.transfer(_to, _value);\r\n    }\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) canTransfer(_from) returns (bool success) {\r\n        // Call StandardToken.transferForm()\r\n        return super.transferFrom(_from, _to, _value);\r\n    }\r\n}\r\n\r\n/**\r\n * @title CgaToken\r\n * @dev The CgaToken contract is Claimable, and provides ERC20 standard token.\r\n */\r\ncontract CgaToken is Claimable, Contactable, HasNoEther, FreezableToken {\r\n    // @dev Constructor initial token info\r\n    function CgaToken(){\r\n        uint256 _decimals = 8;\r\n        uint256 _supply = 910000000*(10**_decimals);\r\n\r\n        _totalSupply = _supply;\r\n        balances[msg.sender] = _supply;\r\n        name = \u0022CGA Token\u0022;\r\n        symbol = \u0022CGA\u0022;\r\n        decimals = _decimals;\r\n        contactInformation = \u0022Contact Email:info@broffering.com\u0022;\r\n    }\r\n}\r\n\r\n\r\ncontract CgaTokenLock is Ownable, HasNoEther {\r\n    using SafeMath for uint256;\r\n\r\n    // @dev How many investors we have now\r\n    uint256 public investorCount;\r\n    // @dev How many tokens investors have claimed so far\r\n    uint256 public totalClaimed;\r\n    // @dev How many tokens our internal book keeping tells us to have at the time of lock() when all investor data has been loaded\r\n    uint256 public tokensAllocatedTotal;\r\n\r\n    // must hold as much as tokens\r\n    uint256 public tokensAtLeastHold;\r\n\r\n    struct balance{\r\n        address investor;\r\n        uint256 amount;\r\n        uint256 freezeEndAt;\r\n        bool claimed;\r\n    }\r\n\r\n    mapping(address =\u003E balance[]) public balances;\r\n    // @dev How many tokens investors have claimed\r\n    mapping(address =\u003E uint256) public claimed;\r\n\r\n    // @dev token\r\n    FreezableToken public token;\r\n\r\n    // @dev We allocated tokens for investor\r\n    event Invested(address investor, uint256 amount, uint256 hour);\r\n\r\n    // @dev We distributed tokens to an investor\r\n    event Distributed(address investors, uint256 count);\r\n\r\n    /**\r\n     * @dev Create contract where lock up period is given days\r\n     *\r\n     * @param _owner Who can load investor data and lock\r\n     * @param _token Token contract address we are distributing\r\n     *\r\n     */\r\n    function CgaTokenLock(address _owner, address _token) {\r\n        require(_owner != 0x0);\r\n        require(_token != 0x0);\r\n\r\n        owner = _owner;\r\n        token = FreezableToken(_token);\r\n    }\r\n\r\n    // @dev Add investor\r\n    function addInvestor(address investor, uint256 _amount, uint256 hour) public onlyOwner {\r\n        require(investor != 0x0);\r\n        require(_amount \u003E 0); // No empty buys\r\n\r\n        uint256 amount = _amount *(10**token.decimals());\r\n        if(balances[investor].length == 0) {\r\n            investorCount\u002B\u002B;\r\n        }\r\n\r\n        balances[investor].push(balance(investor, amount, now \u002B hour*60*60, false));\r\n        tokensAllocatedTotal \u002B= amount;\r\n        tokensAtLeastHold \u002B= amount;\r\n        // Do not lock if the given tokens are not on this contract\r\n        require(token.balanceOf(address(this)) \u003E= tokensAtLeastHold);\r\n\r\n        Invested(investor, amount, hour);\r\n    }\r\n\r\n    // @dev can only withdraw rest of investor\u0027s tokens\r\n    function withdrawLeftTokens() onlyOwner {\r\n        token.transfer(owner, token.balanceOf(address(this))-tokensAtLeastHold);\r\n    }\r\n\r\n    // @dev Get the current balance of tokens\r\n    // @return uint256 How many tokens there are currently\r\n    function getBalance() public constant returns (uint256) {\r\n        return token.balanceOf(address(this));\r\n    }\r\n\r\n    // @dev Claim N bought tokens to the investor as the msg sender\r\n    function claim() {\r\n        withdraw(msg.sender);\r\n    }\r\n\r\n    function withdraw(address investor) internal {\r\n        require(balances[investor].length \u003E 0);\r\n\r\n        uint256 nowTS = now;\r\n        uint256 withdrawTotal;\r\n        for (uint i = 0; i \u003C balances[investor].length; i\u002B\u002B){\r\n            if(balances[investor][i].claimed){\r\n                continue;\r\n            }\r\n            if(nowTS\u003Cbalances[investor][i].freezeEndAt){\r\n                continue;\r\n            }\r\n\r\n            balances[investor][i].claimed=true;\r\n            withdrawTotal \u002B= balances[investor][i].amount;\r\n        }\r\n\r\n        claimed[investor] \u002B= withdrawTotal;\r\n        totalClaimed \u002B= withdrawTotal;\r\n        token.transfer(investor, withdrawTotal);\r\n        tokensAtLeastHold -= withdrawTotal;\r\n        require(token.balanceOf(address(this)) \u003E= tokensAtLeastHold);\r\n\r\n        Distributed(investor, withdrawTotal);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022contactInformation\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022claimOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022frozenAccounts\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022reclaimEther\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022info\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022setContactInformation\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pendingOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022freeze\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022freezeAccount\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:false,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022frozen\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022FrozenFunds\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"CgaToken","CompilerVersion":"v0.4.11\u002Bcommit.68ef5810","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://0a112e571de6f03e98e027dbfda48c1922867de69acc9b7fd7913b18aa237ba7"}]