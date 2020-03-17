[{"SourceCode":"pragma solidity ^0.4.25;\n\n/**\n * @title SafeMath\n * @dev Math operations with safety checks that throw on error\n */\nlibrary SafeMath {\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n    uint256 c = a * b;\n    assert(a == 0 || c / a == b);\n    return c;\n  }\n\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\n    uint256 c = a / b;\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\n    return c;\n  }\n\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n    assert(b \u003C= a);\n    return a - b;\n  }\n\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\n    uint256 c = a \u002B b;\n    assert(c \u003E= a);\n    return c;\n  }\n}\n\n/**\n * @title Ownable\n * @dev The Ownable contract has an owner address, and provides basic authorization control\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\n */\ncontract Ownable {\n  address public owner;\n\n  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n  /**\n   * @dev The constructor sets the original \u0060owner\u0060 of the contract to the sender\n   * account.\n   */\n    constructor() public\n    {\n       owner = msg.sender;\n    }\n\n  /**\n   * @dev Throws if called by any account other than the owner.\n   */\n  modifier onlyOwner() {\n    require(msg.sender == owner);\n    _;\n  }\n\n\n  /**\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\n   * @param newOwner The address to transfer ownership to.\n   */\n  function transferOwnership(address newOwner) onlyOwner public {\n    require(newOwner != address(0));\n    emit OwnershipTransferred(owner, newOwner);\n    owner = newOwner;\n  }\n}\n\ncontract Token {\n\n    /// @return total amount of tokens\n    function totalSupply() constant returns (uint256 supply) {}\n\n    /// @param _owner The address from which the balance will be retrieved\n    /// @return The balance\n    function balanceOf(address _owner) constant returns (uint256 balance) {}\n\n    /// @notice send \u0060_value\u0060 token to \u0060_to\u0060 from \u0060msg.sender\u0060\n    /// @param _to The address of the recipient\n    /// @param _value The amount of token to be transferred\n    /// @return Whether the transfer was successful or not\n    function transfer(address _to, uint256 _value) returns (bool success) {}\n\n    /// @notice send \u0060_value\u0060 token to \u0060_to\u0060 from \u0060_from\u0060 on the condition it is approved by \u0060_from\u0060\n    /// @param _from The address of the sender\n    /// @param _to The address of the recipient\n    /// @param _value The amount of token to be transferred\n    /// @return Whether the transfer was successful or not\n    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}\n\n    /// @notice \u0060msg.sender\u0060 approves \u0060_addr\u0060 to spend \u0060_value\u0060 tokens\n    /// @param _spender The address of the account able to transfer the tokens\n    /// @param _value The amount of wei to be approved for transfer\n    /// @return Whether the approval was successful or not\n    function approve(address _spender, uint256 _value) returns (bool success) {}\n\n    /// @param _owner The address of the account owning tokens\n    /// @param _spender The address of the account able to transfer the tokens\n    /// @return Amount of remaining tokens allowed to spent\n    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}\n\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\n    event setNewBlockEvent(string SecretKey_Pre, string Name_New, string TxHash_Pre, string DigestCode_New, string Image_New, string Note_New);\n}\n\ncontract COLLATERAL  {\n    \n    function decimals() pure returns (uint) {}\n    function CreditRate()  pure returns (uint256) {}\n    function credit(uint256 _value) public {}\n    function repayment(uint256 _amount) public returns (bool) {}\n}\n\ncontract StandardToken is Token {\n\n    COLLATERAL dc;\n    address public collateral_contract;\n    uint public constant decimals = 8;\n\n function transfer(address _to, uint256 _value) returns(bool success) {\n        //Default assumes totalSupply can\u0027t be over max (2^256 - 1).\n        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn\u0027t wrap.\n        //Replace the if with this one instead.\n        //if (balances[msg.sender] \u003E= _value \u0026\u0026 balances[_to] \u002B _value \u003E balances[_to]) {\n        if (balances[msg.sender] \u003E= _value \u0026\u0026 _value \u003E 0) {\n            balances[msg.sender] -= _value;\n            balances[_to] \u002B= _value;\n            emit Transfer(msg.sender, _to, _value);\n            return true;\n        } else { return false; }\n    }\n\n    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {\n        //same as above. Replace this line with the following if you want to protect against wrapping uints.\n        //if (balances[_from] \u003E= _value \u0026\u0026 allowed[_from][msg.sender] \u003E= _value \u0026\u0026 balances[_to] \u002B _value \u003E balances[_to]) {\n        if (balances[_from] \u003E= _value \u0026\u0026 allowed[_from][msg.sender] \u003E= _value \u0026\u0026 _value \u003E 0) {\n            balances[_to] \u002B= _value;\n            balances[_from] -= _value;\n            allowed[_from][msg.sender] -= _value;\n            emit Transfer(_from, _to, _value);\n            return true;\n        } else { return false; }\n    }\n\n    function balanceOf(address _owner) constant returns (uint256 balance) {\n        return balances[_owner];\n    }\n\n    function approve(address _spender, uint256 _value) returns (bool success) {\n        allowed[msg.sender][_spender] = _value;\n        emit Approval(msg.sender, _spender, _value);\n        return true;\n    }\n\n    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {\n        return allowed[_owner][_spender];\n    }\n\n    mapping (address =\u003E uint256) balances;\n    mapping (address =\u003E mapping (address =\u003E uint256)) allowed;\n    uint256 public totalSupply;\n}\n\n\n/**\n * @title Debitable token\n * @dev ERC20 Token, with debitable token creation\n */\ncontract DebitableToken is StandardToken, Ownable {\n  event Debit(address collateral_contract, uint256 amount);\n  event Deposit(address indexed _to_debitor, uint256 _value);  \n  event DebitFinished();\n\n  using SafeMath for uint256;\n  bool public debitingFinished = false;\n\n  modifier canDebit() {\n    require(!debitingFinished);\n    _;\n  }\n\n  modifier hasDebitPermission() {\n    require(msg.sender == owner);\n    _;\n  }\n  \n  /**\n   * @dev Function to debit tokens\n   * @param _to The address that will receive the drawdown tokens.\n   * @param _amount The amount of tokens to debit.\n   * @return A boolean that indicates if the operation was successful.\n   */\n  function debit(\n    address _to,\n    uint256 _amount\n  )\n    public\n    hasDebitPermission\n    canDebit\n    returns (bool)\n  {\n    dc = COLLATERAL(collateral_contract);\n    uint256 rate = dc.CreditRate();\n    uint256 deci = 10 ** decimals; \n    uint256 _amount_1 =  _amount / deci / rate;\n    uint256 _amount_2 =  _amount_1 * deci * rate;\n    \n    require( _amount_1 \u003E 0);\n    dc.credit( _amount_1 );  \n    \n    uint256 _amountx = _amount_2;\n    totalSupply = totalSupply.add(_amountx);\n    balances[_to] = balances[_to].add(_amountx);\n    emit Debit(collateral_contract, _amountx);\n    emit Deposit( _to, _amountx);\n    return true;\n  }\n\n  /**\n   * @dev To stop debiting tokens.\n   * @return True if the operation was successful.\n   */\n  function finishDebit() public onlyOwner canDebit returns (bool) {\n    debitingFinished = true;\n    emit DebitFinished();\n    return true;\n  }\n\n  \n}\n\n\n\n/**\n * @title Repaymentable Token\n * @dev Debitor that can be repay to creditor.\n */\ncontract RepaymentToken is StandardToken, Ownable {\n    using SafeMath for uint256;\n    event Repayment(address collateral_contract, uint256 value);\n    event Withdraw(address debitor, uint256 value);\n    \n    modifier hasRepayPermission() {\n      require(msg.sender == owner);\n      _;\n    }\n\n    function repayment( uint256 _value )\n    hasRepayPermission\n    public \n    {\n        require(_value \u003E 0);\n        require(_value \u003C= balances[msg.sender]);\n\n        dc = COLLATERAL(collateral_contract);\n        address debitor = msg.sender;\n        uint256 rate = dc.CreditRate();\n        uint256 deci = 10 ** decimals; \n        uint256 _unitx = _value / deci / rate;\n        uint256 _value1 = _unitx * deci * rate;\n        balances[debitor] = balances[debitor].sub(_value1);\n        totalSupply = totalSupply.sub(_value1);\n\n        require(_unitx \u003E 0);\n        dc.repayment( _unitx );\n    \n        emit Repayment( collateral_contract, _value1 );\n        emit Withdraw( debitor, _value1 );\n    }\n    \n}\n\n\ncontract CloisonneCans is DebitableToken, RepaymentToken  {\n\n\n    constructor() public {    \n        totalSupply = INITIAL_SUPPLY;\n        balances[msg.sender] = INITIAL_SUPPLY;\n    }\n    \n    function connectContract(address _collateral_address ) public onlyOwner {\n        collateral_contract = _collateral_address;\n    }\n    \n    function getCreditRate() public view returns (uint256 result) {\n        dc = COLLATERAL( collateral_contract );\n        return dc.CreditRate();\n    }\n    \n    /* Public variables of the token */\n\n    /*\n    NOTE:\n    The following variables are OPTIONAL vanities. One does not have to include them.\n    They allow one to customise the token contract \u0026 in no way influences the core functionality.\n    Some wallets/interfaces might not even bother to look at this information.\n    */\n    \n    string public name = \u0022CloisonneCans\u0022;\n    string public symbol = \u0022CC\u0022;\n    uint256 public constant INITIAL_SUPPLY = 0 * (10 ** uint256(decimals));\n    string public Image_root = \u0022https://swarm.chainbacon.com/bzz:/40bdff367b42be22312caaa5ce94e362bdb1d4e7748fa9cf6e90a27c3840e2fa/\u0022;\n    string public Note_root = \u0022https://swarm.chainbacon.com/bzz:/21c72ee75f385dd6c2cb3cc72c9ec0ac0ebd21fa5ab4db0541988a0ee111db26/\u0022;\n    string public Document_root = \u0022none\u0022;\n    string public DigestCode_root = \u002267d6e6baaebaeef0e0293692664792e91dd83db150da505baacace1574983fa7\u0022;\n    function getIssuer() public pure returns(string) { return  \u0022Private\u0022; }\n    string public TxHash_root = \u0022genesis\u0022;\n\n    string public ContractSource = \u0022\u0022;\n    string public CodeVersion = \u0022v0.1\u0022;\n    \n    string public SecretKey_Pre = \u0022\u0022;\n    string public Name_New = \u0022\u0022;\n    string public TxHash_Pre = \u0022\u0022;\n    string public DigestCode_New = \u0022\u0022;\n    string public Image_New = \u0022\u0022;\n    string public Note_New = \u0022\u0022;\n    uint256 public DebitRate = 100 * (10 ** uint256(decimals));\n   \n    function getName() public view returns(string) { return name; }\n    function getDigestCodeRoot() public view returns(string) { return DigestCode_root; }\n    function getTxHashRoot() public view returns(string) { return TxHash_root; }\n    function getImageRoot() public view returns(string) { return Image_root; }\n    function getNoteRoot() public view returns(string) { return Note_root; }\n    function getCodeVersion() public view returns(string) { return CodeVersion; }\n    function getContractSource() public view returns(string) { return ContractSource; }\n\n    function getSecretKeyPre() public view returns(string) { return SecretKey_Pre; }\n    function getNameNew() public view returns(string) { return Name_New; }\n    function getTxHashPre() public view returns(string) { return TxHash_Pre; }\n    function getDigestCodeNew() public view returns(string) { return DigestCode_New; }\n    function getImageNew() public view returns(string) { return Image_New; }\n    function getNoteNew() public view returns(string) { return Note_New; }\n    function updateDebitRate(uint256 _rate) public onlyOwner returns (uint256) {\n        DebitRate = _rate;\n        return DebitRate;\n    }\n\n    function setNewBlock(string _SecretKey_Pre, string _Name_New, string _TxHash_Pre, string _DigestCode_New, string _Image_New, string _Note_New )  returns (bool success) {\n        SecretKey_Pre = _SecretKey_Pre;\n        Name_New = _Name_New;\n        TxHash_Pre = _TxHash_Pre;\n        DigestCode_New = _DigestCode_New;\n        Image_New = _Image_New;\n        Note_New = _Note_New;\n        emit setNewBlockEvent(SecretKey_Pre, Name_New, TxHash_Pre, DigestCode_New, Image_New, Note_New);\n        return true;\n    }\n\n    /* Approves and then calls the receiving contract */\n    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {\n        allowed[msg.sender][_spender] = _value;\n        emit Approval(msg.sender, _spender, _value);\n\n        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn\u0027t have to include a contract in here just for this.\n        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)\n        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.\n        require(!_spender.call(bytes4(bytes32(keccak256(\u0022receiveApproval(address,uint256,address,bytes)\u0022))), msg.sender, _value, this, _extraData));\n        return true;\n    }\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getName\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getDigestCodeRoot\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ContractSource\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getDigestCodeNew\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getContractSource\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getNoteRoot\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022INITIAL_SUPPLY\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getTxHashRoot\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TxHash_root\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022CodeVersion\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_collateral_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022connectContract\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022finishDebit\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getIssuer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getImageRoot\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022DigestCode_New\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Image_root\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022debit\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022repayment\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getNoteNew\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022debitingFinished\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getTxHashPre\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_SecretKey_Pre\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_Name_New\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_TxHash_Pre\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_DigestCode_New\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_Image_New\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_Note_New\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022setNewBlock\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022DigestCode_root\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getNameNew\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCodeVersion\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCreditRate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022result\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Note_root\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Document_root\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getImageNew\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_rate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022updateDebitRate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022DebitRate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TxHash_Pre\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_extraData\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022approveAndCall\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getSecretKeyPre\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Name_New\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022SecretKey_Pre\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Image_New\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Note_New\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022collateral_contract\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022collateral_contract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Repayment\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022debitor\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Withdraw\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022collateral_contract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Debit\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to_debitor\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Deposit\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022DebitFinished\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022SecretKey_Pre\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022Name_New\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022TxHash_Pre\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022DigestCode_New\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022Image_New\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022Note_New\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022setNewBlockEvent\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"CloisonneCans","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://e12c22f13f2df209b601ac69fbb96e618e4b6c8b620f15398d0e5ccdbe0e301e"}]