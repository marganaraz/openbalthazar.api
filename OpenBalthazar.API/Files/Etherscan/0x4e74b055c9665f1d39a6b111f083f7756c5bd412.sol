[{"SourceCode":"pragma solidity 0.4.24;\r\n\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n\r\n    /**\r\n    * @dev Multiplies two numbers, throws on overflow.\r\n    */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n        uint256 c = a * b;\r\n        assert(c / a == b);\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Integer division of two numbers, truncating the quotient.\r\n    */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n    */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    /**\r\n    * @dev Adds two numbers, throws on overflow.\r\n    */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n}\r\n\r\n/**\r\n * @title ERC20Basic\r\n * @dev Simpler version of ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/179\r\n */\r\ncontract ERC20Basic {\r\n    function totalSupply() public view returns (uint256);\r\n    function balanceOf(address who) public view returns (uint256);\r\n    function transfer(address to, uint256 value) public returns (bool);\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n\r\n/**\r\n * @title Basic token\r\n * @dev Basic version of StandardToken, with no allowances.\r\n */\r\ncontract BasicToken is ERC20Basic {\r\n    using SafeMath for uint256;\r\n\r\n    mapping(address =\u003E uint256) balances;\r\n\r\n    uint256 totalSupply_;\r\n\r\n    /**\r\n    * @dev total number of tokens in existence\r\n    */\r\n    function totalSupply() public view returns (uint256) {\r\n        return totalSupply_;\r\n    }\r\n\r\n    /**\r\n    * @dev transfer token for a specified address\r\n    * @param _to The address to transfer to.\r\n    * @param _value The amount to be transferred.\r\n    */\r\n    function transfer(address _to, uint256 _value) public returns (bool) {\r\n        require(_to != address(0));\r\n        require(_value \u003C= balances[msg.sender]);\r\n\r\n        // SafeMath.sub will throw if there is not enough balance.\r\n        balances[msg.sender] = balances[msg.sender].sub(_value);\r\n        balances[_to] = balances[_to].add(_value);\r\n        emit Transfer(msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n    * @dev Gets the balance of the specified address.\r\n    * @param _owner The address to query the the balance of.\r\n    * @return An uint256 representing the amount owned by the passed address.\r\n    */\r\n    function balanceOf(address _owner) public view returns (uint256 balance) {\r\n        return balances[_owner];\r\n    }\r\n}\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ncontract ERC20 is ERC20Basic {\r\n    function allowance(address owner, address spender) public view returns (uint256);\r\n    function transferFrom(address from, address to, uint256 value) public returns (bool);\r\n    function approve(address spender, uint256 value) public returns (bool);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n/**\r\n * @title Standard ERC20 token\r\n *\r\n * @dev Implementation of the basic standard token.\r\n * @dev https://github.com/ethereum/EIPs/issues/20\r\n * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol\r\n */\r\ncontract StandardToken is ERC20, BasicToken {\r\n\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) internal allowed;\r\n\r\n    /**\r\n     * @dev Transfer tokens from one address to another\r\n     * @param _from address The address which you want to send tokens from\r\n     * @param _to address The address which you want to transfer to\r\n     * @param _value uint256 the amount of tokens to be transferred\r\n     */\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {\r\n        require(_to != address(0));\r\n        require(_value \u003C= balances[_from]);\r\n        require(_value \u003C= allowed[_from][msg.sender]);\r\n\r\n        balances[_from] = balances[_from].sub(_value);\r\n        balances[_to] = balances[_to].add(_value);\r\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n        emit Transfer(_from, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\r\n     *\r\n     * Beware that changing an allowance with this method brings the risk that someone may use both the old\r\n     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\r\n     * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     * @param _spender The address which will spend the funds.\r\n     * @param _value The amount of tokens to be spent.\r\n     */\r\n    function approve(address _spender, uint256 _value) public returns (bool) {\r\n        allowed[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Function to check the amount of tokens that an owner allowed to a spender.\r\n     * @param _owner address The address which owns the funds.\r\n     * @param _spender address The address which will spend the funds.\r\n     * @return A uint256 specifying the amount of tokens still available for the spender.\r\n     */\r\n    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n\r\n    /**\r\n     * approve should be called when allowed[_spender] == 0. To increment\r\n     * allowed value is better to use this function to avoid 2 calls (and wait until\r\n     * the first transaction is mined)\r\n     * From MonolithDAO Token.sol\r\n     */\r\n    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {\r\n        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);\r\n        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n        return true;\r\n    }\r\n\r\n    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {\r\n        uint oldValue = allowed[msg.sender][_spender];\r\n        if (_subtractedValue \u003E oldValue) {\r\n            allowed[msg.sender][_spender] = 0;\r\n        } else {\r\n            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\r\n        }\r\n        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n        return true;\r\n    }\r\n}\r\n\r\n/**\r\n * @title SafeERC20\r\n * @dev Wrappers around ERC20 operations that throw on failure.\r\n * To use this library you can add a \u0060using SafeERC20 for ERC20;\u0060 statement to your contract,\r\n * which allows you to call the safe operations as \u0060token.safeTransfer(...)\u0060, etc.\r\n */\r\nlibrary SafeERC20 {\r\n    function safeTransfer(ERC20Basic token, address to, uint256 value) internal {\r\n        assert(token.transfer(to, value));\r\n    }\r\n\r\n    function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {\r\n        assert(token.transferFrom(from, to, value));\r\n    }\r\n\r\n    function safeApprove(ERC20 token, address spender, uint256 value) internal {\r\n        assert(token.approve(spender, value));\r\n    }\r\n}\r\n\r\ncontract Owned {\r\n    address public owner;\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    modifier onlyOwner {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n}\r\n\r\n/**\r\n * @title TokenVesting\r\n * @dev A token holder contract that can release its token balance gradually like a\r\n * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the\r\n * owner.\r\n */\r\ncontract TokenVesting is Owned {\r\n    using SafeMath for uint256;\r\n    using SafeERC20 for ERC20Basic;\r\n\r\n    event Released(uint256 amount);\r\n    event Revoked();\r\n\r\n    // beneficiary of tokens after they are released\r\n    address public beneficiary;\r\n\r\n    uint256 public cliff;\r\n    uint256 public start;\r\n    uint256 public duration;\r\n\r\n    bool public revocable;\r\n\r\n    mapping (address =\u003E uint256) public released;\r\n    mapping (address =\u003E bool) public revoked;\r\n\r\n    address internal ownerShip;\r\n\r\n    /**\r\n     * @dev Creates a vesting contract that vests its balance of any ERC20 token to the\r\n     * _beneficiary, gradually in a linear fashion until _start \u002B _duration. By then all\r\n     * of the balance will have vested.\r\n     * @param _beneficiary address of the beneficiary to whom vested tokens are transferred\r\n     * @param _cliff duration in seconds of the cliff in which tokens will begin to vest\r\n     * @param _start the time (as Unix time) at which point vesting starts\r\n     * @param _duration duration in seconds of the period in which the tokens will vest\r\n     * @param _revocable whether the vesting is revocable or not\r\n     */\r\n    constructor(\r\n        address _beneficiary,\r\n        uint256 _start,\r\n        uint256 _cliff,\r\n        uint256 _duration,\r\n        bool _revocable,\r\n        address _realOwner\r\n    )\r\n        public\r\n    {\r\n        require(_beneficiary != address(0));\r\n        require(_cliff \u003C= _duration);\r\n\r\n        beneficiary = _beneficiary;\r\n        revocable = _revocable;\r\n        duration = _duration;\r\n        cliff = _start.add(_cliff);\r\n        start = _start;\r\n        ownerShip = _realOwner;\r\n    }\r\n\r\n    /**\r\n     * @notice Transfers vested tokens to beneficiary.\r\n     * @param token ERC20 token which is being vested\r\n     */\r\n    function release(ERC20Basic token) public {\r\n        uint256 unreleased = releasableAmount(token);\r\n\r\n        require(unreleased \u003E 0);\r\n\r\n        released[token] = released[token].add(unreleased);\r\n\r\n        token.safeTransfer(beneficiary, unreleased);\r\n\r\n        emit Released(unreleased);\r\n    }\r\n\r\n    /**\r\n     * @notice Allows the owner to revoke the vesting. Tokens already vested\r\n     * remain in the contract, the rest are returned to the owner.\r\n     * @param token ERC20 token which is being vested\r\n     */\r\n    function revoke(ERC20Basic token) public onlyOwner {\r\n        require(revocable);\r\n        require(!revoked[token]);\r\n\r\n        uint256 balance = token.balanceOf(this);\r\n\r\n        uint256 unreleased = releasableAmount(token);\r\n        uint256 refund = balance.sub(unreleased);\r\n\r\n        revoked[token] = true;\r\n\r\n        token.safeTransfer(ownerShip, refund);\r\n\r\n        emit Revoked();\r\n    }\r\n\r\n    /**\r\n     * @dev Calculates the amount that has already vested but hasn\u0027t been released yet.\r\n     * @param token ERC20 token which is being vested\r\n     */\r\n    function releasableAmount(ERC20Basic token) public view returns (uint256) {\r\n        return vestedAmount(token).sub(released[token]);\r\n    }\r\n\r\n    /**\r\n     * @dev Calculates the amount that has already vested.\r\n     * @param token ERC20 token which is being vested\r\n     */\r\n    function vestedAmount(ERC20Basic token) public view returns (uint256) {\r\n        uint256 currentBalance = token.balanceOf(this);\r\n        uint256 totalBalance = currentBalance.add(released[token]);\r\n\r\n        if (block.timestamp \u003C cliff) {\r\n            return 0;\r\n        } else if (block.timestamp \u003E= start.add(duration) || revoked[token]) {\r\n            return totalBalance;\r\n        } else {\r\n            return totalBalance.mul(block.timestamp.sub(start)).div(duration);\r\n        }\r\n    }\r\n}\r\n\r\n/**\r\n * @title TokenVault\r\n * @dev TokenVault is a token holder contract that will allow a\r\n * beneficiary to spend the tokens from some function of a specified ERC20 token\r\n */\r\ncontract TokenVault {\r\n    using SafeERC20 for ERC20;\r\n\r\n    // ERC20 token contract being held\r\n    ERC20 public token;\r\n\r\n    constructor(ERC20 _token) public {\r\n        token = _token;\r\n    }\r\n\r\n    /**\r\n     * @notice Allow the token itself to send tokens\r\n     * using transferFrom().\r\n     */\r\n    function fillUpAllowance() public {\r\n        uint256 amount = token.balanceOf(this);\r\n        require(amount \u003E 0);\r\n\r\n        token.approve(token, amount);\r\n    }\r\n}\r\n\r\n/**\r\n * @title Burnable Token\r\n * @dev Token that can be irreversibly burned (destroyed).\r\n */\r\ncontract BurnableToken is StandardToken {\r\n\r\n    event Burn(address indexed burner, uint256 value);\r\n\r\n    /**\r\n     * @dev Burns a specific amount of tokens.\r\n     * @param _value The amount of token to be burned.\r\n     */\r\n    function burn(uint256 _value) public {\r\n        require(_value \u003E 0);\r\n        require(_value \u003C= balances[msg.sender]);\r\n        // no need to require value \u003C= totalSupply, since that would imply the\r\n        // sender\u0027s balance is greater than the totalSupply, which *should* be an assertion failure\r\n\r\n        address burner = msg.sender;\r\n        balances[burner] = balances[burner].sub(_value);\r\n        totalSupply_ = totalSupply_.sub(_value);\r\n        emit Burn(burner, _value);\r\n    }\r\n}\r\n\r\ncontract TRT_Token is BurnableToken, Owned {\r\n    string public constant name = \u0022TOP RACING TOKEN\u0022;\r\n    string public constant symbol = \u0022TRT\u0022;\r\n    uint8 public constant decimals = 18;\r\n \r\n    /// Maximum tokens to be allocated ( 5.0 billion )\r\n    uint256 public constant HARD_CAP = 5000000000 * 10**uint256(decimals);\r\n\r\n    /// This address will be used to distribute the team, advisors and reserve tokens\r\n    address public saleTokensAddress;\r\n\r\n    /// This vault is used to keep the Founders, Advisors and Partners tokens\r\n    TokenVault public reserveTokensVault;\r\n\r\n    /// Date when the vesting for regular users starts\r\n    uint64 internal daySecond     = 86400;\r\n    uint64 internal lock90Days    = 90;\r\n    uint64 internal unlock100Days = 100;\r\n    uint64 internal lock365Days   = 365;\r\n\r\n    /// Store the vesting contract addresses for each sale contributor\r\n    mapping(address =\u003E address) public vestingOf;\r\n\r\n    constructor(address _saleTokensAddress) public payable {\r\n        require(_saleTokensAddress != address(0));\r\n\r\n        saleTokensAddress = _saleTokensAddress;\r\n\r\n        /// Maximum tokens to be sold - 5/10 ( 2.5 billion )\r\n        uint256 saleTokens = 2500000000;\r\n        createTokensInt(saleTokens, saleTokensAddress);\r\n\r\n        require(totalSupply_ \u003C= HARD_CAP);\r\n    }\r\n\r\n    /// @dev Create a ReserveTokenVault \r\n    function createReserveTokensVault() external onlyOwner {\r\n        require(reserveTokensVault == address(0));\r\n\r\n        /// Reserve tokens - 5/10 ( 2.5 billion )\r\n        uint256 reserveTokens = 2500000000;\r\n        reserveTokensVault = createTokenVaultInt(reserveTokens);\r\n\r\n        require(totalSupply_ \u003C= HARD_CAP);\r\n    }\r\n\r\n    /// @dev Create a TokenVault and fill with the specified newly minted tokens\r\n    function createTokenVaultInt(uint256 tokens) internal onlyOwner returns (TokenVault) {\r\n        TokenVault tokenVault = new TokenVault(ERC20(this));\r\n        createTokensInt(tokens, tokenVault);\r\n        tokenVault.fillUpAllowance();\r\n        return tokenVault;\r\n    }\r\n\r\n    // @dev create specified number of tokens and transfer to destination\r\n    function createTokensInt(uint256 _tokens, address _destination) internal onlyOwner {\r\n        uint256 tokens = _tokens * 10**uint256(decimals);\r\n        totalSupply_ = totalSupply_.add(tokens);\r\n        balances[_destination] = balances[_destination].add(tokens);\r\n        emit Transfer(0x0, _destination, tokens);\r\n\r\n        require(totalSupply_ \u003C= HARD_CAP);\r\n    }\r\n\r\n    /// @dev vest Detail : second unit\r\n    function vestTokensDetailInt(\r\n                        address _beneficiary,\r\n                        uint256 _startS,\r\n                        uint256 _cliffS,\r\n                        uint256 _durationS,\r\n                        bool _revocable,\r\n                        uint256 _tokensAmountInt) external onlyOwner {\r\n        require(_beneficiary != address(0));\r\n\r\n        uint256 tokensAmount = _tokensAmountInt * 10**uint256(decimals);\r\n\r\n        if(vestingOf[_beneficiary] == 0x0) {\r\n            TokenVesting vesting = new TokenVesting(_beneficiary, _startS, _cliffS, _durationS, _revocable, owner);\r\n            vestingOf[_beneficiary] = address(vesting);\r\n        }\r\n\r\n        require(this.transferFrom(reserveTokensVault, vestingOf[_beneficiary], tokensAmount));\r\n    }\r\n\r\n    /// @dev vest StartAt : day unit\r\n    function vestTokensStartAtInt(\r\n                            address _beneficiary, \r\n                            uint256 _tokensAmountInt,\r\n                            uint256 _startS,\r\n                            uint256 _afterDay,\r\n                            uint256 _cliffDay,\r\n                            uint256 _durationDay ) public onlyOwner {\r\n        require(_beneficiary != address(0));\r\n\r\n        uint256 tokensAmount = _tokensAmountInt * 10**uint256(decimals);\r\n        uint256 afterSec = _afterDay * daySecond;\r\n        uint256 cliffSec = _cliffDay * daySecond;\r\n        uint256 durationSec = _durationDay * daySecond;\r\n\r\n        if(vestingOf[_beneficiary] == 0x0) {\r\n            TokenVesting vesting = new TokenVesting(_beneficiary, _startS \u002B afterSec, cliffSec, durationSec, true, owner);\r\n            vestingOf[_beneficiary] = address(vesting);\r\n        }\r\n\r\n        require(this.transferFrom(reserveTokensVault, vestingOf[_beneficiary], tokensAmount));\r\n    }\r\n\r\n    /// @dev vest function from now\r\n    function vestTokensFromNowInt(address _beneficiary, uint256 _tokensAmountInt, uint256 _afterDay, uint256 _cliffDay, uint256 _durationDay ) public onlyOwner {\r\n        vestTokensStartAtInt(_beneficiary, _tokensAmountInt, now, _afterDay, _cliffDay, _durationDay);\r\n    }\r\n\r\n    /// @dev vest the sale contributor tokens for 100 days, 1% gradual release \r\n    function vestCmdNow1PercentInt(address _beneficiary, uint256 _tokensAmountInt) external onlyOwner {\r\n        vestTokensFromNowInt(_beneficiary, _tokensAmountInt, 0, 0, unlock100Days);\r\n    }\r\n    /// @dev vest the sale contributor tokens for 100 days, 1% gradual release after 3 month later, no cliff\r\n    function vestCmd3Month1PercentInt(address _beneficiary, uint256 _tokensAmountInt) external onlyOwner {\r\n        vestTokensFromNowInt(_beneficiary, _tokensAmountInt, lock90Days, 0, unlock100Days);\r\n    }\r\n\r\n    /// @dev vest the sale contributor tokens 100% release after 1 year\r\n    function vestCmd1YearInstantInt(address _beneficiary, uint256 _tokensAmountInt) external onlyOwner {\r\n        vestTokensFromNowInt(_beneficiary, _tokensAmountInt, 0, lock365Days, lock365Days);\r\n    }\r\n\r\n    /// @dev releases vested tokens for the caller\u0027s own address\r\n    function releaseVestedTokens() external {\r\n        releaseVestedTokensFor(msg.sender);\r\n    }\r\n\r\n    /// @dev releases vested tokens for the specified address.\r\n    /// Can be called by anyone for any address.\r\n    function releaseVestedTokensFor(address _owner) public {\r\n        TokenVesting(vestingOf[_owner]).release(this);\r\n    }\r\n\r\n    /// @dev check the vested balance for an address\r\n    function lockedBalanceOf(address _owner) public view returns (uint256) {\r\n        return balances[vestingOf[_owner]];\r\n    }\r\n\r\n    /// @dev check the locked but releaseable balance of an owner\r\n    function releaseableBalanceOf(address _owner) public view returns (uint256) {\r\n        if (vestingOf[_owner] == address(0) ) {\r\n            return 0;\r\n        } else {\r\n            return TokenVesting(vestingOf[_owner]).releasableAmount(this);\r\n        }\r\n    }\r\n\r\n    /// @dev revoke vested tokens for the specified address.\r\n    /// Tokens already vested remain in the contract, the rest are returned to the owner.\r\n    function revokeVestedTokensFor(address _owner) public onlyOwner {\r\n        TokenVesting(vestingOf[_owner]).revoke(this);\r\n    }\r\n\r\n    /// @dev Create a ReserveTokenVault \r\n    function makeReserveToVault() external onlyOwner {\r\n        require(reserveTokensVault != address(0));\r\n        reserveTokensVault.fillUpAllowance();\r\n    }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022createReserveTokensVault\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022HARD_CAP\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022releaseVestedTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022lockedBalanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_beneficiary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_tokensAmountInt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_startS\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_afterDay\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_cliffDay\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_durationDay\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022vestTokensStartAtInt\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022revokeVestedTokensFor\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_beneficiary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_tokensAmountInt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022vestCmdNow1PercentInt\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022saleTokensAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022makeReserveToVault\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022releaseableBalanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_beneficiary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_tokensAmountInt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022vestCmd1YearInstantInt\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022releaseVestedTokensFor\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022vestingOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_beneficiary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_tokensAmountInt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_afterDay\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_cliffDay\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_durationDay\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022vestTokensFromNowInt\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022reserveTokensVault\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_beneficiary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_startS\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_cliffS\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_durationS\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_revocable\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022_tokensAmountInt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022vestTokensDetailInt\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_beneficiary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_tokensAmountInt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022vestCmd3Month1PercentInt\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_saleTokensAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022burner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"TRT_Token","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000005c8bcfb5D4a573477A03989f0B3867895051a678","Library":"","SwarmSource":"bzzr://0cb37300488dd18f057cfc4ca8058d075ad006e358719712a46c71dea584a0e1"}]