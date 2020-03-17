[{"SourceCode":"pragma solidity ^0.4.23;\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Multiplies two numbers, throws on overflow.\r\n     **/\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n        c = a * b;\r\n        assert(c / a == b);\r\n        return c;\r\n    }\r\n    \r\n    /**\r\n     * @dev Integer division of two numbers, truncating the quotient.\r\n     **/\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n        // uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n        return a / b;\r\n    }\r\n    \r\n    /**\r\n     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n     **/\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n    \r\n    /**\r\n     * @dev Adds two numbers, throws on overflow.\r\n     **/\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n        c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n}\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n **/\r\n \r\ncontract Ownable {\r\n    address public owner;\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n/**\r\n     * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender account.\r\n     **/\r\n   constructor() public {\r\n      owner = msg.sender;\r\n    }\r\n    \r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     **/\r\n    modifier onlyOwner() {\r\n      require(msg.sender == owner);\r\n      _;\r\n    }\r\n    \r\n    /**\r\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     **/\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n      require(newOwner != address(0));\r\n      emit OwnershipTransferred(owner, newOwner);\r\n      owner = newOwner;\r\n    }\r\n}\r\n/**\r\n * @title ERC20Basic interface\r\n * @dev Basic ERC20 interface\r\n **/\r\ncontract ERC20Basic {\r\n    function totalSupply() public view returns (uint256);\r\n    function balanceOf(address who) public view returns (uint256);\r\n    function transfer(address to, uint256 value) public returns (bool);\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n **/\r\ncontract ERC20 is ERC20Basic {\r\n    function allowance(address owner, address spender) public view returns (uint256);\r\n    function transferFrom(address from, address to, uint256 value) public returns (bool);\r\n    function approve(address spender, uint256 value) public returns (bool);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n/**\r\n * @title Basic token\r\n * @dev Basic version of StandardToken, with no allowances.\r\n **/\r\ncontract BasicToken is ERC20Basic {\r\n    using SafeMath for uint256;\r\n    mapping(address =\u003E uint256) balances;\r\n    uint256 totalSupply_;\r\n    \r\n    /**\r\n     * @dev total number of tokens in existence\r\n     **/\r\n    function totalSupply() public view returns (uint256) {\r\n        return totalSupply_;\r\n    }\r\n    \r\n    /**\r\n     * @dev transfer token for a specified address\r\n     * @param _to The address to transfer to.\r\n     * @param _value The amount to be transferred.\r\n     **/\r\n    function transfer(address _to, uint256 _value) public returns (bool) {\r\n        require(_to != address(0));\r\n        require(_value \u003C= balances[msg.sender]);\r\n        \r\n        balances[msg.sender] = balances[msg.sender].sub(_value);\r\n        balances[_to] = balances[_to].add(_value);\r\n        emit Transfer(msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n    \r\n    /**\r\n     * @dev Gets the balance of the specified address.\r\n     * @param _owner The address to query the the balance of.\r\n     * @return An uint256 representing the amount owned by the passed address.\r\n     **/\r\n    function balanceOf(address _owner) public view returns (uint256) {\r\n        return balances[_owner];\r\n    }\r\n}\r\ncontract StandardToken is ERC20, BasicToken {\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) internal allowed;\r\n    /**\r\n     * @dev Transfer tokens from one address to another\r\n     * @param _from address The address which you want to send tokens from\r\n     * @param _to address The address which you want to transfer to\r\n     * @param _value uint256 the amount of tokens to be transferred\r\n     **/\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {\r\n        require(_to != address(0));\r\n        require(_value \u003C= balances[_from]);\r\n        require(_value \u003C= allowed[_from][msg.sender]);\r\n    \r\n        balances[_from] = balances[_from].sub(_value);\r\n        balances[_to] = balances[_to].add(_value);\r\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n        \r\n        emit Transfer(_from, _to, _value);\r\n        return true;\r\n    }\r\n    \r\n    /**\r\n     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\r\n     *\r\n     * Beware that changing an allowance with this method brings the risk that someone may use both the old\r\n     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\r\n     * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     * @param _spender The address which will spend the funds.\r\n     * @param _value The amount of tokens to be spent.\r\n     **/\r\n    function approve(address _spender, uint256 _value) public returns (bool) {\r\n        allowed[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n    \r\n    /**\r\n     * @dev Function to check the amount of tokens that an owner allowed to a spender.\r\n     * @param _owner address The address which owns the funds.\r\n     * @param _spender address The address which will spend the funds.\r\n     * @return A uint256 specifying the amount of tokens still available for the spender.\r\n     **/\r\n    function allowance(address _owner, address _spender) public view returns (uint256) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n    \r\n    /**\r\n     * @dev Increase the amount of tokens that an owner allowed to a spender.\r\n     *\r\n     * approve should be called when allowed[_spender] == 0. To increment\r\n     * allowed value is better to use this function to avoid 2 calls (and wait until\r\n     * the first transaction is mined)\r\n     * From MonolithDAO Token.sol\r\n     * @param _spender The address which will spend the funds.\r\n     * @param _addedValue The amount of tokens to increase the allowance by.\r\n     **/\r\n    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {\r\n        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);\r\n        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n        return true;\r\n    }\r\n    \r\n    /**\r\n     * @dev Decrease the amount of tokens that an owner allowed to a spender.\r\n     *\r\n     * approve should be called when allowed[_spender] == 0. To decrement\r\n     * allowed value is better to use this function to avoid 2 calls (and wait until\r\n     * the first transaction is mined)\r\n     * From MonolithDAO Token.sol\r\n     * @param _spender The address which will spend the funds.\r\n     * @param _subtractedValue The amount of tokens to decrease the allowance by.\r\n     **/\r\n    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {\r\n        uint oldValue = allowed[msg.sender][_spender];\r\n        if (_subtractedValue \u003E oldValue) {\r\n            allowed[msg.sender][_spender] = 0;\r\n        } else {\r\n            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\r\n        }\r\n        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n        return true;\r\n    }\r\n}\r\n/**\r\n * @title Configurable\r\n * @dev Configurable varriables of the contract\r\n **/\r\ncontract Configurable {\r\n    uint256 public constant cap = 1000000*10**18;\r\n    uint256 public constant basePrice = 100*10**18; // tokens per 1 ether\r\n    uint256 public tokensSold = 0;\r\n    \r\n    uint256 public constant tokenReserve = 1000000*10**18;\r\n    uint256 public remainingTokens = 0;\r\n}\r\n/**\r\n * @title CrowdsaleToken \r\n * @dev Contract to preform crowd sale with token\r\n **/\r\ncontract CrowdsaleToken is StandardToken, Configurable, Ownable {\r\n    /**\r\n     * @dev enum of current crowd sale state\r\n     **/\r\n     enum Stages {\r\n        none,\r\n        icoStart, \r\n        icoEnd\r\n    }\r\n    \r\n    Stages currentStage;\r\n  \r\n    /**\r\n     * @dev constructor of CrowdsaleToken\r\n     **/\r\n    constructor() public {\r\n        currentStage = Stages.none;\r\n        balances[owner] = balances[owner].add(tokenReserve);\r\n        totalSupply_ = totalSupply_.add(tokenReserve);\r\n        remainingTokens = cap;\r\n        emit Transfer(address(this), owner, tokenReserve);\r\n    }\r\n    \r\n    /**\r\n     * @dev fallback function to send ether to for Crowd sale\r\n     **/\r\n    function () public payable {\r\n        require(currentStage == Stages.icoStart);\r\n        require(msg.value \u003E 0);\r\n        require(remainingTokens \u003E 0);\r\n        \r\n        \r\n        uint256 weiAmount = msg.value; // Calculate tokens to sell\r\n        uint256 tokens = weiAmount.mul(basePrice).div(1 ether);\r\n        uint256 returnWei = 0;\r\n        \r\n        if(tokensSold.add(tokens) \u003E cap){\r\n            uint256 newTokens = cap.sub(tokensSold);\r\n            uint256 newWei = newTokens.div(basePrice).mul(1 ether);\r\n            returnWei = weiAmount.sub(newWei);\r\n            weiAmount = newWei;\r\n            tokens = newTokens;\r\n        }\r\n        \r\n        tokensSold = tokensSold.add(tokens); // Increment raised amount\r\n        remainingTokens = cap.sub(tokensSold);\r\n        if(returnWei \u003E 0){\r\n            msg.sender.transfer(returnWei);\r\n            emit Transfer(address(this), msg.sender, returnWei);\r\n        }\r\n        \r\n        balances[msg.sender] = balances[msg.sender].add(tokens);\r\n        emit Transfer(address(this), msg.sender, tokens);\r\n        totalSupply_ = totalSupply_.add(tokens);\r\n        owner.transfer(weiAmount);// Send money to owner\r\n    }\r\n/**\r\n     * @dev startIco starts the public ICO\r\n     **/\r\n    function startIco() public onlyOwner {\r\n        require(currentStage != Stages.icoEnd);\r\n        currentStage = Stages.icoStart;\r\n    }\r\n/**\r\n     * @dev endIco closes down the ICO \r\n     **/\r\n    function endIco() internal {\r\n        currentStage = Stages.icoEnd;\r\n        // Transfer any remaining tokens\r\n        if(remainingTokens \u003E 0)\r\n            balances[owner] = balances[owner].add(remainingTokens);\r\n        // transfer any remaining ETH balance in the contract to the owner\r\n        owner.transfer(address(this).balance); \r\n    }\r\n/**\r\n     * @dev finalizeIco closes down the ICO and sets needed varriables\r\n     **/\r\n    function finalizeIco() public onlyOwner {\r\n        require(currentStage != Stages.icoEnd);\r\n        endIco();\r\n    }\r\n    \r\n}\r\n/**\r\n * @title LKCToken \r\n * @dev Contract to create the LKC Token\r\n **/\r\ncontract LKCToken is CrowdsaleToken {\r\n    string public constant name = \u0022LKC\u0022;\r\n    string public constant symbol = \u0022LKC\u0022;\r\n    uint32 public constant decimals = 18;\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"BasicToken","CompilerVersion":"v0.4.23\u002Bcommit.124ca40d","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://403d505208aa3223bdf8bbb1892c081c8a6975cfbdb2954d7fdbfb86067443a4"}]