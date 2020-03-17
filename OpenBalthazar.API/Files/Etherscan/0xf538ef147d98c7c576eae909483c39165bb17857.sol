[{"SourceCode":"pragma solidity ^0.4.25;\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a * b;\r\n    assert(a == 0 || c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return c;\r\n  }\r\n\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n}\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n  address public owner;\r\n\r\n  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n  /**\r\n   * @dev The constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n   * account.\r\n   */\r\n    constructor() public\r\n    {\r\n       owner = msg.sender;\r\n    }\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n\r\n  /**\r\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n   * @param newOwner The address to transfer ownership to.\r\n   */\r\n  function transferOwnership(address newOwner) onlyOwner public {\r\n    require(newOwner != address(0));\r\n    emit OwnershipTransferred(owner, newOwner);\r\n    owner = newOwner;\r\n  }\r\n}\r\n\r\ncontract Token {\r\n\r\n    /// @return total amount of tokens\r\n    function totalSupply() constant returns (uint256 supply) {}\r\n\r\n    /// @param _owner The address from which the balance will be retrieved\r\n    /// @return The balance\r\n    function balanceOf(address _owner) constant returns (uint256 balance) {}\r\n\r\n    /// @notice send \u0060_value\u0060 token to \u0060_to\u0060 from \u0060msg.sender\u0060\r\n    /// @param _to The address of the recipient\r\n    /// @param _value The amount of token to be transferred\r\n    /// @return Whether the transfer was successful or not\r\n    function transfer(address _to, uint256 _value) returns (bool success) {}\r\n\r\n    /// @notice send \u0060_value\u0060 token to \u0060_to\u0060 from \u0060_from\u0060 on the condition it is approved by \u0060_from\u0060\r\n    /// @param _from The address of the sender\r\n    /// @param _to The address of the recipient\r\n    /// @param _value The amount of token to be transferred\r\n    /// @return Whether the transfer was successful or not\r\n    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}\r\n\r\n    /// @notice \u0060msg.sender\u0060 approves \u0060_addr\u0060 to spend \u0060_value\u0060 tokens\r\n    /// @param _spender The address of the account able to transfer the tokens\r\n    /// @param _value The amount of wei to be approved for transfer\r\n    /// @return Whether the approval was successful or not\r\n    function approve(address _spender, uint256 _value) returns (bool success) {}\r\n\r\n    /// @param _owner The address of the account owning tokens\r\n    /// @param _spender The address of the account able to transfer the tokens\r\n    /// @return Amount of remaining tokens allowed to spent\r\n    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}\r\n\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n    event setNewBlockEvent(string SecretKey_Pre, string Name_New, string TxHash_Pre, string DigestCode_New, string Image_New, string Note_New);\r\n}\r\n\r\ncontract COLLATERAL  {\r\n    \r\n    function decimals() pure returns (uint) {}\r\n    function CreditRate()  pure returns (uint256) {}\r\n    function credit(uint256 _value) public {}\r\n    function repayment(uint256 _amount) public returns (bool) {}\r\n}\r\n\r\ncontract StandardToken is Token {\r\n\r\n    COLLATERAL dc;\r\n    address public collateral_contract;\r\n    uint public constant decimals = 0;\r\n\r\n function transfer(address _to, uint256 _value) returns(bool success) {\r\n        //Default assumes totalSupply can\u0027t be over max (2^256 - 1).\r\n        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn\u0027t wrap.\r\n        //Replace the if with this one instead.\r\n        //if (balances[msg.sender] \u003E= _value \u0026\u0026 balances[_to] \u002B _value \u003E balances[_to]) {\r\n        if (balances[msg.sender] \u003E= _value \u0026\u0026 _value \u003E 0) {\r\n            balances[msg.sender] -= _value;\r\n            balances[_to] \u002B= _value;\r\n            emit Transfer(msg.sender, _to, _value);\r\n            return true;\r\n        } else { return false; }\r\n    }\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {\r\n        //same as above. Replace this line with the following if you want to protect against wrapping uints.\r\n        //if (balances[_from] \u003E= _value \u0026\u0026 allowed[_from][msg.sender] \u003E= _value \u0026\u0026 balances[_to] \u002B _value \u003E balances[_to]) {\r\n        if (balances[_from] \u003E= _value \u0026\u0026 allowed[_from][msg.sender] \u003E= _value \u0026\u0026 _value \u003E 0) {\r\n            balances[_to] \u002B= _value;\r\n            balances[_from] -= _value;\r\n            allowed[_from][msg.sender] -= _value;\r\n            emit Transfer(_from, _to, _value);\r\n            return true;\r\n        } else { return false; }\r\n    }\r\n\r\n    function balanceOf(address _owner) constant returns (uint256 balance) {\r\n        return balances[_owner];\r\n    }\r\n\r\n    function approve(address _spender, uint256 _value) returns (bool success) {\r\n        allowed[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender, _spender, _value);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {\r\n        return allowed[_owner][_spender];\r\n    }\r\n\r\n    mapping (address =\u003E uint256) balances;\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) allowed;\r\n    uint256 public totalSupply;\r\n}\r\n\r\n\r\n/**\r\n * @title Debitable token\r\n * @dev ERC20 Token, with debitable token creation\r\n */\r\ncontract DebitableToken is StandardToken, Ownable {\r\n  event Debit(address collateral_contract, uint256 amount);\r\n  event Deposit(address indexed _to_debitor, uint256 _value);  \r\n  event DebitFinished();\r\n\r\n  using SafeMath for uint256;\r\n  bool public debitingFinished = false;\r\n\r\n  modifier canDebit() {\r\n    require(!debitingFinished);\r\n    _;\r\n  }\r\n\r\n  modifier hasDebitPermission() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n  \r\n  /**\r\n   * @dev Function to debit tokens\r\n   * @param _to The address that will receive the drawdown tokens.\r\n   * @param _amount The amount of tokens to debit.\r\n   * @return A boolean that indicates if the operation was successful.\r\n   */\r\n  function debit(\r\n    address _to,\r\n    uint256 _amount\r\n  )\r\n    public\r\n    hasDebitPermission\r\n    canDebit\r\n    returns (bool)\r\n  {\r\n    dc = COLLATERAL(collateral_contract);\r\n    uint256 rate = dc.CreditRate();\r\n    uint256 deci = 10 ** decimals; \r\n    uint256 _amount_1 =  _amount / deci / rate;\r\n    uint256 _amount_2 =  _amount_1 * deci * rate;\r\n    \r\n    require( _amount_1 \u003E 0);\r\n    dc.credit( _amount_1 );  \r\n    \r\n    uint256 _amountx = _amount_2;\r\n    totalSupply = totalSupply.add(_amountx);\r\n    balances[_to] = balances[_to].add(_amountx);\r\n    emit Debit(collateral_contract, _amountx);\r\n    emit Deposit( _to, _amountx);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev To stop debiting tokens.\r\n   * @return True if the operation was successful.\r\n   */\r\n  function finishDebit() public onlyOwner canDebit returns (bool) {\r\n    debitingFinished = true;\r\n    emit DebitFinished();\r\n    return true;\r\n  }\r\n\r\n  \r\n}\r\n\r\n\r\n\r\n/**\r\n * @title Repaymentable Token\r\n * @dev Debitor that can be repay to creditor.\r\n */\r\ncontract RepaymentToken is StandardToken, Ownable {\r\n    using SafeMath for uint256;\r\n    event Repayment(address collateral_contract, uint256 value);\r\n    event Withdraw(address debitor, uint256 value);\r\n    \r\n    modifier hasRepayPermission() {\r\n      require(msg.sender == owner);\r\n      _;\r\n    }\r\n\r\n    function repayment( uint256 _value )\r\n    hasRepayPermission\r\n    public \r\n    {\r\n        require(_value \u003E 0);\r\n        require(_value \u003C= balances[msg.sender]);\r\n\r\n        dc = COLLATERAL(collateral_contract);\r\n        address debitor = msg.sender;\r\n        uint256 rate = dc.CreditRate();\r\n        uint256 deci = 10 ** decimals; \r\n        uint256 _unitx = _value / deci / rate;\r\n        uint256 _value1 = _unitx * deci * rate;\r\n        balances[debitor] = balances[debitor].sub(_value1);\r\n        totalSupply = totalSupply.sub(_value1);\r\n\r\n        require(_unitx \u003E 0);\r\n        dc.repayment( _unitx );\r\n    \r\n        emit Repayment( collateral_contract, _value1 );\r\n        emit Withdraw( debitor, _value1 );\r\n    }\r\n    \r\n}\r\n\r\n\r\ncontract ChinToHaCoin is DebitableToken, RepaymentToken  {\r\n\r\n\r\n    constructor() public {    \r\n        totalSupply = INITIAL_SUPPLY;\r\n        balances[msg.sender] = INITIAL_SUPPLY;\r\n    }\r\n    \r\n    function connectContract(address _collateral_address ) public onlyOwner {\r\n        collateral_contract = _collateral_address;\r\n    }\r\n    \r\n    function getCreditRate() public view returns (uint256 result) {\r\n        dc = COLLATERAL( collateral_contract );\r\n        return dc.CreditRate();\r\n    }\r\n    \r\n    /* Public variables of the token */\r\n\r\n    /*\r\n    NOTE:\r\n    The following variables are OPTIONAL vanities. One does not have to include them.\r\n    They allow one to customise the token contract \u0026 in no way influences the core functionality.\r\n    Some wallets/interfaces might not even bother to look at this information.\r\n    */\r\n    \r\n    string public name = \u0022ChinToHaCoin\u0022;\r\n    string public symbol = \u0022CTHC\u0022;\r\n    uint256 public constant INITIAL_SUPPLY = 0 * (10 ** uint256(decimals));\r\n    string public Image_root = \u0022https://swarm.chainbacon.com/bzz:/3fe13660887b606b8dc90e4f232f835d51dc6b71e182fd079f22ec8f643b8853/\u0022;\r\n    string public Note_root = \u0022https://swarm.chainbacon.com/bzz:/73bcc5fda8642dd9b82b5e065fdb2288830bb7e8e93c404e0578bc4c896fa199/\u0022;\r\n    string public Document_root = \u0022https://swarm.chainbacon.com/bzz:/67ddcef52dce4cd6c0b8f39c291970572fb1d0b1f43c9d98b3d2202ca52e57fd/\u0022;\r\n    string public DigestCode_root = \u00229d7f53442ec1c2874bee0091f82d046a7cfce963ca84b9c5f5c6b0b011d23ea1\u0022;\r\n    function getIssuer() public pure returns(string) { return  \u0022ChinToHa\u0022; }\r\n    string public TxHash_root = \u0022genesis\u0022;\r\n\r\n    string public ContractSource = \u0022\u0022;\r\n    string public CodeVersion = \u0022v0.1\u0022;\r\n    \r\n    string public SecretKey_Pre = \u0022\u0022;\r\n    string public Name_New = \u0022\u0022;\r\n    string public TxHash_Pre = \u0022\u0022;\r\n    string public DigestCode_New = \u0022\u0022;\r\n    string public Image_New = \u0022\u0022;\r\n    string public Note_New = \u0022\u0022;\r\n    uint256 public DebitRate = 100 * (10 ** uint256(decimals));\r\n   \r\n    function getName() public view returns(string) { return name; }\r\n    function getDigestCodeRoot() public view returns(string) { return DigestCode_root; }\r\n    function getTxHashRoot() public view returns(string) { return TxHash_root; }\r\n    function getImageRoot() public view returns(string) { return Image_root; }\r\n    function getNoteRoot() public view returns(string) { return Note_root; }\r\n    function getCodeVersion() public view returns(string) { return CodeVersion; }\r\n    function getContractSource() public view returns(string) { return ContractSource; }\r\n\r\n    function getSecretKeyPre() public view returns(string) { return SecretKey_Pre; }\r\n    function getNameNew() public view returns(string) { return Name_New; }\r\n    function getTxHashPre() public view returns(string) { return TxHash_Pre; }\r\n    function getDigestCodeNew() public view returns(string) { return DigestCode_New; }\r\n    function getImageNew() public view returns(string) { return Image_New; }\r\n    function getNoteNew() public view returns(string) { return Note_New; }\r\n    function updateDebitRate(uint256 _rate) public onlyOwner returns (uint256) {\r\n        DebitRate = _rate;\r\n        return DebitRate;\r\n    }\r\n\r\n    function setNewBlock(string _SecretKey_Pre, string _Name_New, string _TxHash_Pre, string _DigestCode_New, string _Image_New, string _Note_New )  returns (bool success) {\r\n        SecretKey_Pre = _SecretKey_Pre;\r\n        Name_New = _Name_New;\r\n        TxHash_Pre = _TxHash_Pre;\r\n        DigestCode_New = _DigestCode_New;\r\n        Image_New = _Image_New;\r\n        Note_New = _Note_New;\r\n        emit setNewBlockEvent(SecretKey_Pre, Name_New, TxHash_Pre, DigestCode_New, Image_New, Note_New);\r\n        return true;\r\n    }\r\n\r\n    /* Approves and then calls the receiving contract */\r\n    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {\r\n        allowed[msg.sender][_spender] = _value;\r\n        emit Approval(msg.sender, _spender, _value);\r\n\r\n        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn\u0027t have to include a contract in here just for this.\r\n        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)\r\n        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.\r\n        require(!_spender.call(bytes4(bytes32(keccak256(\u0022receiveApproval(address,uint256,address,bytes)\u0022))), msg.sender, _value, this, _extraData));\r\n        return true;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022CreditRate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022repayment\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022credit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"COLLATERAL","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://62820138ec46cedc1bd7fa675d04f8a452c887bc7b36c339c4e2278143edb77a"}]