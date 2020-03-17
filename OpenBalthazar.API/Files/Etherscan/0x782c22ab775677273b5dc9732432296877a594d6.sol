[{"SourceCode":"pragma solidity ^0.4.18;\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n  address public owner;\r\n\r\n\r\n  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n\r\n  /**\r\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n   * account.\r\n   */\r\n  function Ownable() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n   * @param newOwner The address to transfer ownership to.\r\n   */\r\n  function transferOwnership(address newOwner) public onlyOwner {\r\n    require(newOwner != address(0));\r\n    OwnershipTransferred(owner, newOwner);\r\n    owner = newOwner;\r\n  }\r\n\r\n}\r\n\r\n/**\r\n * @title ERC20Basic\r\n * @dev Simpler version of ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/179\r\n */\r\ncontract ERC20Basic {\r\n  function totalSupply() public view returns (uint256);\r\n  function balanceOf(address who) public view returns (uint256);\r\n  function transfer(address to, uint256 value) public returns (bool);\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n\r\n  /**\r\n  * @dev Multiplies two numbers, throws on overflow.\r\n  */\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n    uint256 c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Integer division of two numbers, truncating the quotient.\r\n  */\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n  */\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  /**\r\n  * @dev Adds two numbers, throws on overflow.\r\n  */\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n}\r\n\r\n/**\r\n * @title Basic token\r\n * @dev Basic version of StandardToken, with no allowances.\r\n */\r\ncontract BasicToken is ERC20Basic {\r\n  using SafeMath for uint256;\r\n\r\n  mapping(address =\u003E uint256) balances;\r\n\r\n  uint256 totalSupply_;\r\n\r\n  /**\r\n  * @dev total number of tokens in existence\r\n  */\r\n  function totalSupply() public view returns (uint256) {\r\n    return totalSupply_;\r\n  }\r\n\r\n  /**\r\n  * @dev transfer token for a specified address\r\n  * @param _to The address to transfer to.\r\n  * @param _value The amount to be transferred.\r\n  */\r\n  function transfer(address _to, uint256 _value) public returns (bool) {\r\n    require(_to != address(0));\r\n    require(_value \u003C= balances[msg.sender]);\r\n\r\n    // SafeMath.sub will throw if there is not enough balance.\r\n    balances[msg.sender] = balances[msg.sender].sub(_value);\r\n    balances[_to] = balances[_to].add(_value);\r\n    Transfer(msg.sender, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n  * @dev Gets the balance of the specified address.\r\n  * @param _owner The address to query the the balance of.\r\n  * @return An uint256 representing the amount owned by the passed address.\r\n  */\r\n  function balanceOf(address _owner) public view returns (uint256 balance) {\r\n    return balances[_owner];\r\n  }\r\n\r\n}\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ncontract ERC20 is ERC20Basic {\r\n  function allowance(address owner, address spender) public view returns (uint256);\r\n  function transferFrom(address from, address to, uint256 value) public returns (bool);\r\n  function approve(address spender, uint256 value) public returns (bool);\r\n  event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n/**\r\n * @title Standard ERC20 token\r\n *\r\n * @dev Implementation of the basic standard token.\r\n * @dev https://github.com/ethereum/EIPs/issues/20\r\n * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol\r\n */\r\ncontract StandardToken is ERC20, BasicToken {\r\n\r\n  mapping (address =\u003E mapping (address =\u003E uint256)) internal allowed;\r\n\r\n\r\n  /**\r\n   * @dev Transfer tokens from one address to another\r\n   * @param _from address The address which you want to send tokens from\r\n   * @param _to address The address which you want to transfer to\r\n   * @param _value uint256 the amount of tokens to be transferred\r\n   */\r\n  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {\r\n    require(_to != address(0));\r\n    require(_value \u003C= balances[_from]);\r\n    require(_value \u003C= allowed[_from][msg.sender]);\r\n\r\n    balances[_from] = balances[_from].sub(_value);\r\n    balances[_to] = balances[_to].add(_value);\r\n    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n    Transfer(_from, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\r\n   *\r\n   * Beware that changing an allowance with this method brings the risk that someone may use both the old\r\n   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\r\n   * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\r\n   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n   * @param _spender The address which will spend the funds.\r\n   * @param _value The amount of tokens to be spent.\r\n   */\r\n  function approve(address _spender, uint256 _value) public returns (bool) {\r\n    allowed[msg.sender][_spender] = _value;\r\n    Approval(msg.sender, _spender, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Function to check the amount of tokens that an owner allowed to a spender.\r\n   * @param _owner address The address which owns the funds.\r\n   * @param _spender address The address which will spend the funds.\r\n   * @return A uint256 specifying the amount of tokens still available for the spender.\r\n   */\r\n  function allowance(address _owner, address _spender) public view returns (uint256) {\r\n    return allowed[_owner][_spender];\r\n  }\r\n\r\n  /**\r\n   * @dev Increase the amount of tokens that an owner allowed to a spender.\r\n   *\r\n   * approve should be called when allowed[_spender] == 0. To increment\r\n   * allowed value is better to use this function to avoid 2 calls (and wait until\r\n   * the first transaction is mined)\r\n   * From MonolithDAO Token.sol\r\n   * @param _spender The address which will spend the funds.\r\n   * @param _addedValue The amount of tokens to increase the allowance by.\r\n   */\r\n  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {\r\n    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);\r\n    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Decrease the amount of tokens that an owner allowed to a spender.\r\n   *\r\n   * approve should be called when allowed[_spender] == 0. To decrement\r\n   * allowed value is better to use this function to avoid 2 calls (and wait until\r\n   * the first transaction is mined)\r\n   * From MonolithDAO Token.sol\r\n   * @param _spender The address which will spend the funds.\r\n   * @param _subtractedValue The amount of tokens to decrease the allowance by.\r\n   */\r\n  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {\r\n    uint oldValue = allowed[msg.sender][_spender];\r\n    if (_subtractedValue \u003E oldValue) {\r\n      allowed[msg.sender][_spender] = 0;\r\n    } else {\r\n      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\r\n    }\r\n    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n    return true;\r\n  }\r\n\r\n}\r\n\r\n/**\r\n * @title InbestToken\r\n * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.\r\n * Note they can later distribute these tokens as they wish using \u0060transfer\u0060 and other\r\n * \u0060StandardToken\u0060 functions.\r\n */\r\ncontract InbestToken is StandardToken {\r\n\r\n  string public constant name = \u0022Inbest Token\u0022;\r\n  string public constant symbol = \u0022IBST\u0022;\r\n  uint8 public constant decimals = 18;\r\n\r\n  // TBD\r\n  uint256 public constant INITIAL_SUPPLY = 17656263110 * (10 ** uint256(decimals));\r\n\r\n  /**\r\n   * @dev Constructor that gives msg.sender all of existing tokens.\r\n   */\r\n  function InbestToken() public {\r\n    totalSupply_ = INITIAL_SUPPLY;\r\n    balances[msg.sender] = INITIAL_SUPPLY;\r\n    Transfer(0x0, msg.sender, INITIAL_SUPPLY);\r\n  }\r\n\r\n}\r\n\r\n/**\r\n * @title Inbest Token initial distribution\r\n *\r\n * @dev Distribute Investors\u0027 and Company\u0027s tokens\r\n */\r\ncontract InbestDistribution is Ownable {\r\n  using SafeMath for uint256;\r\n\r\n  // Token\r\n  InbestToken public IBST;\r\n\r\n  // Status of admins\r\n  mapping (address =\u003E bool) public admins;\r\n\r\n  // Number of decimal places for tokens\r\n  uint256 private constant DECIMALFACTOR = 10**uint256(18);\r\n\r\n  // Cliff period = 6 months\r\n  uint256 CLIFF = 180 days;  \r\n  // Vesting period = 12 months after cliff\r\n  uint256 VESTING = 365 days; \r\n  \r\n  // Total of tokens\r\n  uint256 public constant INITIAL_SUPPLY   =    17656263110 * DECIMALFACTOR; // 14.000.000.000 IBST\r\n  // Total of available tokens\r\n  uint256 public AVAILABLE_TOTAL_SUPPLY    =    17656263110 * DECIMALFACTOR; // 14.000.000.000 IBST\r\n  // Total of available tokens for presale allocations\r\n  uint256 public AVAILABLE_PRESALE_SUPPLY  =    16656263110 * DECIMALFACTOR; // 500.000.000 IBST, 18 months vesting, 6 months cliff\r\n  // Total of available tokens for company allocation\r\n  uint256 public AVAILABLE_COMPANY_SUPPLY  =    1000000000 * DECIMALFACTOR; // 13.500.000.000 INST at token distribution event\r\n\r\n  // Allocation types\r\n  enum AllocationType { PRESALE, COMPANY}\r\n\r\n  // Amount of total tokens claimed\r\n  uint256 public grandTotalClaimed = 0;\r\n  // Time when InbestDistribution goes live\r\n  uint256 public startTime;\r\n\r\n  // The only wallet allowed for Company supply\r\n  address public companyWallet;\r\n\r\n  // Allocation with vesting and cliff information\r\n  struct Allocation {\r\n    uint8 allocationType;   // Type of allocation\r\n    uint256 endCliff;       // Tokens are locked until\r\n    uint256 endVesting;     // This is when the tokens are fully unvested\r\n    uint256 totalAllocated; // Total tokens allocated\r\n    uint256 amountClaimed;  // Total tokens claimed\r\n  }\r\n  mapping (address =\u003E Allocation) public allocations;\r\n\r\n  // Modifier to control who executes functions\r\n  modifier onlyOwnerOrAdmin() {\r\n    require(msg.sender == owner || admins[msg.sender]);\r\n    _;\r\n  }\r\n\r\n  // Event fired when a new allocation is made\r\n  event LogNewAllocation(address indexed _recipient, AllocationType indexed _fromSupply, uint256 _totalAllocated, uint256 _grandTotalAllocated);\r\n  // Event fired when IBST tokens are claimed\r\n  event LogIBSTClaimed(address indexed _recipient, uint8 indexed _fromSupply, uint256 _amountClaimed, uint256 _totalAllocated, uint256 _grandTotalClaimed);\r\n  // Event fired when admins are modified\r\n  event SetAdmin(address _caller, address _admin, bool _allowed);\r\n  // Event fired when refunding tokens mistakenly sent to contract\r\n  event RefundTokens(address _token, address _refund, uint256 _value);\r\n\r\n  /**\r\n    * @dev Constructor function - Set the inbest token address\r\n    * @param _startTime The time when InbestDistribution goes live\r\n    * @param _companyWallet The wallet to allocate Company tokens\r\n    */\r\n  function InbestDistribution(uint256 _startTime, address _companyWallet) public {\r\n    require(_companyWallet != address(0));\r\n    require(_startTime \u003E= now);\r\n    require(AVAILABLE_TOTAL_SUPPLY == AVAILABLE_PRESALE_SUPPLY.add(AVAILABLE_COMPANY_SUPPLY));\r\n    startTime = _startTime;\r\n    companyWallet = _companyWallet;\r\n    IBST = new InbestToken();\r\n    require(AVAILABLE_TOTAL_SUPPLY == IBST.totalSupply()); //To verify that totalSupply is correct\r\n\r\n    // Allocate Company Supply\r\n    uint256 tokensToAllocate = AVAILABLE_COMPANY_SUPPLY;\r\n    AVAILABLE_COMPANY_SUPPLY = 0;\r\n    allocations[companyWallet] = Allocation(uint8(AllocationType.COMPANY), 0, 0, tokensToAllocate, 0);\r\n    AVAILABLE_TOTAL_SUPPLY = AVAILABLE_TOTAL_SUPPLY.sub(tokensToAllocate);\r\n    LogNewAllocation(companyWallet, AllocationType.COMPANY, tokensToAllocate, grandTotalAllocated());\r\n  }\r\n\r\n  /**\r\n    * @dev Allow the owner or admins of the contract to assign a new allocation\r\n    * @param _recipient The recipient of the allocation\r\n    * @param _totalAllocated The total amount of IBST tokens available to the receipient (after vesting and cliff)\r\n    */\r\n  function setAllocation (address _recipient, uint256 _totalAllocated) public onlyOwnerOrAdmin {\r\n    require(_recipient != address(0));\r\n    require(startTime \u003E now); //Allocations are allowed only before starTime\r\n    require(AVAILABLE_PRESALE_SUPPLY \u003E= _totalAllocated); //Current allocation must be less than remaining presale supply\r\n    require(allocations[_recipient].totalAllocated == 0 \u0026\u0026 _totalAllocated \u003E 0); // Must be the first and only allocation for this recipient\r\n    require(_recipient != companyWallet); // Receipient of presale allocation can\u0027t be company wallet\r\n\r\n    // Allocate\r\n    AVAILABLE_PRESALE_SUPPLY = AVAILABLE_PRESALE_SUPPLY.sub(_totalAllocated);\r\n    allocations[_recipient] = Allocation(uint8(AllocationType.PRESALE), startTime.add(CLIFF), startTime.add(CLIFF).add(VESTING), _totalAllocated, 0);\r\n    AVAILABLE_TOTAL_SUPPLY = AVAILABLE_TOTAL_SUPPLY.sub(_totalAllocated);\r\n    LogNewAllocation(_recipient, AllocationType.PRESALE, _totalAllocated, grandTotalAllocated());\r\n  }\r\n\r\n  /**\r\n   * @dev Transfer a recipients available allocation to their address\r\n   * @param _recipient The address to withdraw tokens for\r\n   */\r\n function transferTokens (address _recipient) public {\r\n   require(_recipient != address(0));\r\n   require(now \u003E= startTime); //Tokens can\u0027t be transfered until start date\r\n   require(_recipient != companyWallet); // Tokens allocated to COMPANY can\u0027t be withdrawn.\r\n   require(now \u003E= allocations[_recipient].endCliff); // Cliff period must be ended\r\n   // Receipient can\u0027t claim more IBST tokens than allocated\r\n   require(allocations[_recipient].amountClaimed \u003C allocations[_recipient].totalAllocated);\r\n\r\n   uint256 newAmountClaimed;\r\n   if (allocations[_recipient].endVesting \u003E now) {\r\n     // Transfer available amount based on vesting schedule and allocation\r\n     newAmountClaimed = allocations[_recipient].totalAllocated.mul(now.sub(allocations[_recipient].endCliff)).div(allocations[_recipient].endVesting.sub(allocations[_recipient].endCliff));\r\n   } else {\r\n     // Transfer total allocated (minus previously claimed tokens)\r\n     newAmountClaimed = allocations[_recipient].totalAllocated;\r\n   }\r\n\r\n   //Transfer\r\n   uint256 tokensToTransfer = newAmountClaimed.sub(allocations[_recipient].amountClaimed);\r\n   allocations[_recipient].amountClaimed = newAmountClaimed;\r\n   require(IBST.transfer(_recipient, tokensToTransfer));\r\n   grandTotalClaimed = grandTotalClaimed.add(tokensToTransfer);\r\n   LogIBSTClaimed(_recipient, allocations[_recipient].allocationType, tokensToTransfer, newAmountClaimed, grandTotalClaimed);\r\n }\r\n\r\n /**\r\n  * @dev Transfer IBST tokens from Company allocation to reicipient address - Only owner and admins can execute\r\n  * @param _recipient The address to transfer tokens for\r\n  * @param _tokensToTransfer The amount of IBST tokens to transfer\r\n  */\r\n function manualContribution(address _recipient, uint256 _tokensToTransfer) public onlyOwnerOrAdmin {\r\n   require(_recipient != address(0));\r\n   require(_recipient != companyWallet); // Company can\u0027t withdraw tokens for itself\r\n   require(_tokensToTransfer \u003E 0); // The amount must be valid\r\n   require(now \u003E= startTime); // Tokens cant\u0027t be transfered until start date\r\n   //Company can\u0027t trasnfer more tokens than allocated\r\n   require(allocations[companyWallet].amountClaimed.add(_tokensToTransfer) \u003C= allocations[companyWallet].totalAllocated);\r\n\r\n   //Transfer\r\n   allocations[companyWallet].amountClaimed = allocations[companyWallet].amountClaimed.add(_tokensToTransfer);\r\n   require(IBST.transfer(_recipient, _tokensToTransfer));\r\n   grandTotalClaimed = grandTotalClaimed.add(_tokensToTransfer);\r\n   LogIBSTClaimed(_recipient, uint8(AllocationType.COMPANY), _tokensToTransfer, allocations[companyWallet].amountClaimed, grandTotalClaimed);\r\n }\r\n\r\n /**\r\n  * @dev Returns remaining Company allocation\r\n  * @return Returns remaining Company allocation\r\n  */\r\n function companyRemainingAllocation() public view returns (uint256) {\r\n   return allocations[companyWallet].totalAllocated.sub(allocations[companyWallet].amountClaimed);\r\n }\r\n\r\n /**\r\n  * @dev Returns the amount of IBST allocated\r\n  * @return Returns the amount of IBST allocated\r\n  */\r\n  function grandTotalAllocated() public view returns (uint256) {\r\n    return INITIAL_SUPPLY.sub(AVAILABLE_TOTAL_SUPPLY);\r\n  }\r\n\r\n  /**\r\n   * @dev Admin management\r\n   * @param _admin Address of the admin to modify\r\n   * @param _allowed Status of the admin\r\n   */\r\n  function setAdmin(address _admin, bool _allowed) public onlyOwner {\r\n    require(_admin != address(0));\r\n    admins[_admin] = _allowed;\r\n     SetAdmin(msg.sender,_admin,_allowed);\r\n  }\r\n\r\n  function refundTokens(address _token, address _refund, uint256 _value) public onlyOwner {\r\n    require(_refund != address(0));\r\n    require(_token != address(0));\r\n    require(_token != address(IBST));\r\n    ERC20 token = ERC20(_token);\r\n    require(token.transfer(_refund, _value));\r\n    RefundTokens(_token, _refund, _value);\r\n  }\r\n}\r\n\r\ncontract InbestTokenBuybackProcessor  is Ownable {\r\n  InbestDistribution public inbestDistribution;\r\n  InbestToken public inbestToken;\r\n  // Status of admins\r\n  mapping (address =\u003E bool) public admins;\r\n\r\n  // Modifier to control who executes functions\r\n  modifier onlyOwnerOrAdmin() {\r\n    require(msg.sender == owner || admins[msg.sender]);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Constructor recibe the inbestDistribution address contract.\r\n   */\r\n  function InbestTokenBuybackProcessor(InbestDistribution _inbestDistribution, InbestToken _inbestToken) public {\r\n    require(_inbestDistribution != address(0));\r\n    inbestDistribution = _inbestDistribution;\r\n    inbestToken = _inbestToken;\r\n  }\r\n\r\n  /**\r\n   * For each wallet on _addresses parameter call to transferTokens over the inbestDistribution contract and then send thoes ibst to another wallet.\r\n   */\r\n  function distributeTokensToDestinationWallet(address[] _addresses, address _addressDestination) public onlyOwnerOrAdmin{\r\n    require(_addresses.length \u003E 0);\r\n    uint arrayLength = _addresses.length;\r\n    for (uint i=0; i \u003C arrayLength; i\u002B\u002B) {\r\n      address investorAddress = _addresses[i];\r\n      distributeToAddressAndSendToDestination(investorAddress, _addressDestination);\r\n    }\r\n  }\r\n\r\n  function distributeToAddressAndSendToDestination(address _investorAddress, address _addressDestination) public onlyOwnerOrAdmin{\r\n    inbestDistribution.transferTokens(_investorAddress);\r\n    uint256 ibstBalance = inbestToken.balanceOf(_investorAddress);\r\n    require (inbestToken.transferFrom(_investorAddress, _addressDestination, ibstBalance));\r\n    TokensRecoveredFromInvestor(_investorAddress,_addressDestination, ibstBalance);\r\n  }\r\n\r\n  function inbestDistributionTransferTokens(address _recipient) public onlyOwnerOrAdmin{\r\n    inbestDistribution.transferTokens(_recipient);\r\n  }\r\n\r\n  // ERC20 interface for futures implementations.\r\n  function getBalance(address _investorAddress) public view onlyOwnerOrAdmin  returns (uint256){\r\n    return inbestToken.balanceOf(_investorAddress);\r\n  }\r\n\r\n  function tokenTransferFrom(address _fromAddress, address _toAddress, uint256 _ibstAmount) public onlyOwnerOrAdmin returns (bool){\r\n    return inbestToken.transferFrom(_fromAddress, _toAddress, _ibstAmount);\r\n  }\r\n\r\n  function tokenTransfer(address _to, uint256 _value) public onlyOwnerOrAdmin returns (bool){\r\n    return inbestToken.transfer(_to, _value);\r\n  }\r\n\r\n  function approve(address _spender, uint256 _value) public onlyOwnerOrAdmin returns (bool){\r\n    return inbestToken.approve(_spender, _value);\r\n  }\r\n\r\n  event TokensRecoveredFromInvestor(address indexed investor, address indexed newDestination, uint256 amount);\r\n\r\n\r\n  // Admins management\r\n  /**\r\n   * @dev Admin management\r\n   * @param _admin Address of the admin to modify\r\n   * @param _allowed Status of the admin\r\n   */\r\n  function setAdmin(address _admin, bool _allowed) public onlyOwnerOrAdmin {\r\n    require(_admin != address(0));\r\n    admins[_admin] = _allowed;\r\n    SetAdmin(msg.sender,_admin,_allowed);\r\n  }\r\n  // Event fired when admins are modified\r\n  event SetAdmin(address _caller, address _admin, bool _allowed);\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_investorAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_addressDestination\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022distributeToAddressAndSendToDestination\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022admins\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_admin\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_allowed\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addresses\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_addressDestination\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022distributeTokensToDestinationWallet\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022tokenTransfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022inbestDistribution\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_fromAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_toAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_ibstAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022tokenTransferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_recipient\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022inbestDistributionTransferTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022inbestToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_investorAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_inbestDistribution\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_inbestToken\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022investor\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newDestination\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022TokensRecoveredFromInvestor\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_caller\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_admin\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_allowed\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022SetAdmin\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"InbestTokenBuybackProcessor","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000fe0a38f4e1a8833f5db7830bf62d93e80568e7eb00000000000000000000000034f49e2ea4fb9b80714f8776932528a79c39de28","Library":"","SwarmSource":"bzzr://f3d41ecd5480bd2b7471420e3266577b8fc1cd5372ff1cb3204ec8ba7cec275b"}]