[{"SourceCode":"pragma solidity 0.5.12;\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\n\r\nlibrary SafeMath \r\n{\r\n\r\n  /**\r\n  * @dev Multiplies two numbers, throws on overflow.\r\n  */\r\n\r\n  function mul(uint256 a, uint256 b) internal pure returns(uint256 c) \r\n  {\r\n     if (a == 0) \r\n     {\r\n     \treturn 0;\r\n     }\r\n\r\n     c = a * b;\r\n     require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n     return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Integer division of two numbers, truncating the quotient.\r\n  */\r\n\r\n  function div(uint256 a, uint256 b) internal pure returns(uint256) \r\n  {\r\n     require( b \u003E 0, \u0022SafeMath: division by zero\u0022);\r\n\r\n     return a / b;\r\n  }\r\n\r\n  /**\r\n  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n  */\r\n\r\n  function sub(uint256 a, uint256 b) internal pure returns(uint256) \r\n  {\r\n     require(b \u003C= a, \u0022SafeMath: subtraction overflow\u0022);\r\n\r\n     return a - b;\r\n  }\r\n\r\n  /**\r\n  * @dev Adds two numbers, throws on overflow.\r\n  */\r\n\r\n  function add(uint256 a, uint256 b) internal pure returns(uint256 c) \r\n  {\r\n     c = a \u002B b;\r\n\r\n     require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n     return c;\r\n  }\r\n}\r\n\r\ncontract ERC20Interface\r\n{\r\n    function totalSupply() public view returns (uint256);\r\n    function balanceOf(address _who) public view returns (uint256);\r\n    function transfer(address _to, uint256 _value) public returns (bool);\r\n    function allowance(address _owner, address _spender) public view returns (uint256);\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);\r\n    function approve(address _spender, uint256 _value) public returns (bool);\r\n\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n}\r\n\r\n/**\r\n * @title Basic token\r\n */\r\n\r\ncontract IFL is ERC20Interface\r\n{\r\n    using SafeMath for uint256;\r\n   \r\n    uint256 constant public TOKEN_DECIMALS = 10 ** 18;\r\n    string public constant name            = \u0022iflag\u0022;\r\n    string public constant symbol          = \u0022IFL\u0022;\r\n    uint256 public totalTokenSupply        = 60000000 * TOKEN_DECIMALS;\r\n\r\n    uint8 public constant decimals         = 18;\r\n    address public owner;\r\n    uint256 public totalBurned;\r\n\r\n    event Burn(address indexed _burner, uint256 _value);\r\n    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);\r\n\r\n    struct ClaimLimit \r\n    {\r\n       uint256 time_limit_epoch;\r\n       bool    limitSet;\r\n    }\r\n\r\n    /** mappings **/ \r\n    mapping(address =\u003E ClaimLimit) public claimLimits;\r\n    mapping(address =\u003E uint256) public  balances;\r\n    mapping(address =\u003E mapping(address =\u003E uint256)) internal  allowed;\r\n \r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n\r\n    modifier onlyOwner() \r\n    {\r\n       require(msg.sender == owner);\r\n       _;\r\n    }\r\n    \r\n    /** constructor **/\r\n\r\n    constructor() public\r\n    {\r\n       owner = msg.sender;\r\n       balances[address(this)] = totalTokenSupply;\r\n\r\n       emit Transfer(address(0x0), address(this), balances[address(this)]);\r\n    }\r\n\r\n    /**\r\n     * @dev Burn specified number of IFL tokens\r\n     * @param _value The amount of tokens to be burned\r\n     */\r\n\r\n     function burn(uint256 _value) onlyOwner public returns (bool) \r\n     {\r\n        require(_value \u003C= balances[msg.sender]);\r\n\r\n        address burner = msg.sender;\r\n\r\n        balances[burner] = balances[burner].sub(_value);\r\n        totalTokenSupply = totalTokenSupply.sub(_value);\r\n        totalBurned      = totalBurned.add(_value);\r\n\r\n        emit Burn(burner, _value);\r\n        emit Transfer(burner, address(0x0), _value);\r\n        return true;\r\n     }     \r\n\r\n     /**\r\n      * @dev total number of tokens in existence\r\n      * @return An uint256 representing the total number of tokens in existence\r\n      */\r\n\r\n     function totalSupply() public view returns(uint256 _totalSupply) \r\n     {\r\n        _totalSupply = totalTokenSupply;\r\n        return _totalSupply;\r\n     }\r\n\r\n    /**\r\n     * @dev Gets the balance of the specified address\r\n     * @param _owner The address to query the the balance of\r\n     * @return An uint256 representing the amount owned by the passed address\r\n     */\r\n\r\n    function balanceOf(address _owner) public view returns (uint256) \r\n    {\r\n       return balances[_owner];\r\n    }\r\n\r\n    /**\r\n     * @dev Transfer tokens from one address to another\r\n     * @param _from address The address which you want to send tokens from\r\n     * @param _to address The address which you want to transfer to\r\n     * @param _value uint256 the amout of tokens to be transfered\r\n     */\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool)     \r\n    {\r\n\r\n       if (_value == 0) \r\n       {\r\n           emit Transfer(_from, _to, _value);  // Follow the spec to launch the event when value is equal to 0\r\n           return true;\r\n       }\r\n\r\n       require(!claimLimits[msg.sender].limitSet, \u0022Limit is set and use claim\u0022);\r\n       require(_to != address(0x0));\r\n       require(balances[_from] \u003E= _value \u0026\u0026 allowed[_from][msg.sender] \u003E= _value \u0026\u0026 _value \u003E= 0);\r\n\r\n       balances[_from] = balances[_from].sub(_value);\r\n       allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n       balances[_to] = balances[_to].add(_value);\r\n\r\n       emit Transfer(_from, _to, _value);\r\n       return true;\r\n    }\r\n\r\n    /**\r\n     * @dev transfer tokens from smart contract to another account, only by owner\r\n     * @param _address The address to transfer to\r\n     * @param _tokens The amount to be transferred\r\n     */\r\n\r\n    function transferTo(address _address, uint256 _tokens) external onlyOwner returns(bool) \r\n    {\r\n       require( _address != address(0x0)); \r\n       require( balances[address(this)] \u003E= _tokens.mul(TOKEN_DECIMALS) \u0026\u0026 _tokens.mul(TOKEN_DECIMALS) \u003E 0);\r\n\r\n       balances[address(this)] = ( balances[address(this)]).sub(_tokens.mul(TOKEN_DECIMALS));\r\n       balances[_address] = (balances[_address]).add(_tokens.mul(TOKEN_DECIMALS));\r\n\r\n       emit Transfer(address(this), _address, _tokens.mul(TOKEN_DECIMALS));\r\n       return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender\r\n     *\r\n     * Beware that changing an allowance with this method brings the risk that someone may use both the old\r\n     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\r\n     * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     * @param _spender The address which will spend the funds\r\n     * @param _tokens The amount of tokens to be spent\r\n     */\r\n\r\n    function approve(address _spender, uint256 _tokens) public returns(bool)\r\n    {\r\n       require(_spender != address(0x0));\r\n\r\n       allowed[msg.sender][_spender] = _tokens;\r\n\r\n       emit Approval(msg.sender, _spender, _tokens);\r\n       return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Function to check the amount of tokens that an owner allowed to a spender\r\n     * @param _owner address The address which owns the funds\r\n     * @param _spender address The address which will spend the funds\r\n     * @return A uint256 specifing the amount of tokens still avaible for the spender\r\n     */\r\n\r\n    function allowance(address _owner, address _spender) public view returns(uint256)\r\n    {\r\n       require(_owner != address(0x0) \u0026\u0026 _spender != address(0x0));\r\n\r\n       return allowed[_owner][_spender];\r\n    }\r\n\r\n    /**\r\n     * @dev transfer token for a specified address\r\n     * @param _address The address to transfer to\r\n     * @param _tokens The amount to be transferred\r\n     */\r\n\r\n    function transfer(address _address, uint256 _tokens) public returns(bool)\r\n    {\r\n\r\n       if (_tokens == 0) \r\n       {\r\n           emit Transfer(msg.sender, _address, _tokens);  // Follow the spec to launch the event when tokens are equal to 0\r\n           return true;\r\n       }\r\n\r\n       require(!claimLimits[msg.sender].limitSet, \u0022Limit is set and use claim\u0022);\r\n       require(_address != address(0x0));\r\n       require(balances[msg.sender] \u003E= _tokens);\r\n\r\n       balances[msg.sender] = (balances[msg.sender]).sub(_tokens);\r\n       balances[_address] = (balances[_address]).add(_tokens);\r\n\r\n       emit Transfer(msg.sender, _address, _tokens);\r\n       return true;\r\n    }\r\n\r\n    /**\r\n     * @dev transfer ownership of this contract, only by owner\r\n     * @param _newOwner The address of the new owner to transfer ownership\r\n     */\r\n\r\n    function transferOwnership(address _newOwner)public onlyOwner\r\n    {\r\n       require( _newOwner != address(0x0));\r\n\r\n       balances[_newOwner] = (balances[_newOwner]).add(balances[owner]);\r\n       balances[owner] = 0;\r\n       owner = _newOwner;\r\n\r\n       emit Transfer(msg.sender, _newOwner, balances[_newOwner]);\r\n   }\r\n\r\n   /**\r\n    * @dev Increase the amount of tokens that an owner allowed to a spender\r\n    * approve should be called when allowed[_spender] == 0. To increment\r\n    * allowed value is better to use this function to avoid 2 calls (and wait until\r\n    * the first transaction is mined)\r\n    * From MonolithDAO Token.sol\r\n    * @param _spender The address which will spend the funds\r\n    * @param _addedValue The amount of tokens to increase the allowance by\r\n    */\r\n\r\n   function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) \r\n   {\r\n\r\n      allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);\r\n\r\n      emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n      return true;\r\n   }\r\n\r\n   /**\r\n    * @dev Decrease the amount of tokens that an owner allowed to a spender\r\n    * approve should be called when allowed[_spender] == 0. To decrement\r\n    * allowed value is better to use this function to avoid 2 calls (and wait until\r\n    * the first transaction is mined)\r\n    * From MonolithDAO Token.sol\r\n    * @param _spender The address which will spend the funds\r\n    * @param _subtractedValue The amount of tokens to decrease the allowance by\r\n    */\r\n\r\n   function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) \r\n   {\r\n      uint256 oldValue = allowed[msg.sender][_spender];\r\n\r\n\r\n      if (_subtractedValue \u003E oldValue) \r\n      {\r\n         allowed[msg.sender][_spender] = 0;\r\n      }\r\n      else \r\n      {\r\n         allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\r\n      }\r\n\r\n      emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n      return true;\r\n   }\r\n\r\n   /**\r\n    * @dev Transfer tokens to another account, time limit apply\r\n    */\r\n\r\n   function claim(address _recipient) public\r\n   {\r\n      require(_recipient != address(0x0), \u0022Invalid recipient\u0022);\r\n      require(msg.sender != _recipient, \u0022Self transfer\u0022);\r\n      require(claimLimits[msg.sender].limitSet, \u0022Limit not set\u0022);\r\n\r\n      require (now \u003E claimLimits[msg.sender].time_limit_epoch, \u0022Time limit\u0022);\r\n       \r\n      uint256 tokens = balances[msg.sender];\r\n       \r\n      balances[msg.sender] = (balances[msg.sender]).sub(tokens);\r\n      balances[_recipient] = (balances[_recipient]).add(tokens);\r\n       \r\n      emit Transfer(msg.sender, _recipient, tokens);\r\n   }\r\n \r\n   /**\r\n    * @dev Set limit on a claim per address\r\n    */\r\n\r\n   function setClaimLimit(address _address, uint256 _days) public onlyOwner\r\n   {\r\n      require(balances[_address] \u003E 0, \u0022No tokens\u0022);\r\n\r\n      claimLimits[_address].time_limit_epoch = (now \u002B ((_days).mul(1 days)));\r\n   \t\t\r\n      claimLimits[_address].limitSet = true;\r\n   }\r\n\r\n   /**\r\n    * @dev reset limit on address\r\n    */\r\n\r\n   function resetClaimLimit(address _address) public onlyOwner\r\n   {\r\n      claimLimits[_address].limitSet = false;\r\n   }\r\n\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_burner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKEN_DECIMALS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balances\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_recipient\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022claim\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022claimLimits\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022time_limit_epoch\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022limitSet\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseApproval\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseApproval\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022resetClaimLimit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_days\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setClaimLimit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalBurned\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_totalSupply\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalTokenSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferTo\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"IFL","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://aae05f298ff6cec79c677cbdfef5802fdb5f92d387c22daa455cf516483b1400"}]