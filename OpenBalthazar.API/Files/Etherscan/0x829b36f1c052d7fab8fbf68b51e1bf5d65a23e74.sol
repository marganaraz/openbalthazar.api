[{"SourceCode":"pragma solidity ^0.5.2;\r\n\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://eips.ethereum.org/EIPS/eip-20\r\n */\r\ninterface IERC20 {\r\n    function transfer(address to, uint256 value) external returns (bool);\r\n\r\n    function approve(address spender, uint256 value) external returns (bool);\r\n\r\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\r\n\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    function balanceOf(address who) external view returns (uint256);\r\n\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    function okToTransferTokens(address _holder, uint256 _amountToAdd) external view returns (bool);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Unsigned math operations with safety checks that revert on error.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Multiplies two unsigned integers, reverts on overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, \u0022SafeMath: division by zero\u0022);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a, \u0022SafeMath: subtraction overflow\u0022);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Adds two unsigned integers, reverts on overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),\r\n     * reverts when dividing by zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0, \u0022SafeMath: modulo by zero\u0022);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n\r\ninterface IFactory {\r\n    function changeATFactoryAddress(address) external;\r\n    function changeTDeployerAddress(address) external;\r\n    function changeFPDeployerAddress(address) external;\r\n    function changeDeployFees (uint256) external;\r\n    function changeFeesCollector (address) external;\r\n    function deployPanelContracts(string calldata, string calldata, string calldata, bytes32, uint8, uint8, uint8, uint256) external;\r\n    function getTotalDeployFees() external view returns (uint256);\r\n    function isFactoryDeployer(address) external view returns(bool);\r\n    function isFactoryATGenerated(address) external view returns(bool);\r\n    function isFactoryTGenerated(address) external view returns(bool);\r\n    function isFactoryFPGenerated(address) external view returns(bool);\r\n    function getTotalDeployer() external view returns(uint256);\r\n    function getTotalATContracts() external view returns(uint256);\r\n    function getTotalTContracts() external view returns(uint256);\r\n    function getTotalFPContracts() external view returns(uint256);\r\n    function getContractsByIndex(uint256) external view returns (address, address, address, address);\r\n    function getDeployerAddressByIndex(uint256) external view returns (address);\r\n    function getATAddressByIndex(uint256) external view returns (address);\r\n    function getTAddressByIndex(uint256) external view returns (address);\r\n    function getFPAddressByIndex(uint256) external view returns (address);\r\n    function withdraw(address) external;\r\n}\r\n\r\n\r\n/**\r\n * @title SeedDex\r\n * @dev This is the main contract for the Seed Decentralised Exchange.\r\n */\r\ncontract SeedDex {\r\n\r\n  using SafeMath for uint;\r\n\r\n  /// Variables\r\n  address public seedToken; // the seed token\r\n  address public factoryAddress; // Address of the factory\r\n  address private ethAddress = address(0);\r\n\r\n  // True when Token.transferFrom is being called from depositToken\r\n  bool private depositingTokenFlag;\r\n\r\n  // mapping of token addresses to mapping of account balances (token=0 means Ether)\r\n  mapping (address =\u003E mapping (address =\u003E uint)) private tokens;\r\n\r\n  // mapping of user accounts to mapping of order hashes to booleans (true = submitted by user, equivalent to offchain signature)\r\n  mapping (address =\u003E mapping (bytes32 =\u003E bool)) private orders;\r\n\r\n  // mapping of user accounts to mapping of order hashes to uints (amount of order that has been filled)\r\n  mapping (address =\u003E mapping (bytes32 =\u003E uint)) private orderFills;\r\n\r\n  /// Logging Events\r\n  event Order(address indexed tokenGet, uint amountGet, address indexed tokenGive, uint amountGive, uint expires, uint nonce, address indexed user);\r\n  event Cancel(address indexed tokenGet, uint amountGet, address indexed tokenGive, uint amountGive, uint expires, uint nonce, address indexed user);\r\n  event Trade(address indexed tokenGet, uint amountGet, address  indexed tokenGive, uint amountGive, uint expires, uint nonce, address indexed get, uint amount, uint executedAmount, address give);\r\n  event Deposit(address indexed token, address indexed user, uint amount, uint balance);\r\n  event Withdraw(address indexed token, address indexed user, uint amount, uint balance);\r\n\r\n  /// Constructor function. This is only called on contract creation.\r\n  constructor(address _seedToken, address _factoryAddress)  public {\r\n    seedToken = _seedToken;\r\n    factoryAddress = _factoryAddress;\r\n    depositingTokenFlag = false;\r\n  }\r\n\r\n  /// The fallback function. Ether transfered into the contract is not accepted.\r\n  function() external {\r\n    revert(\u0022ETH not accepted!\u0022);\r\n  }\r\n\r\n  ////////////////////////////////////////////////////////////////////////////////\r\n  // Deposits, Withdrawals, Balances\r\n  ////////////////////////////////////////////////////////////////////////////////\r\n\r\n\r\n  /**\r\n  * This function handles deposits of Ether into the contract.\r\n  * Emits a Deposit event.\r\n  * Note: With the payable modifier, this function accepts Ether.\r\n  */\r\n  function deposit() public payable {\r\n    tokens[ethAddress][msg.sender] = tokens[ethAddress][msg.sender].add(msg.value);\r\n    emit Deposit(ethAddress, msg.sender, msg.value, tokens[ethAddress][msg.sender]);\r\n  }\r\n\r\n  /**\r\n  * This function handles withdrawals of Ether from the contract.\r\n  * Verifies that the user has enough funds to cover the withdrawal.\r\n  * Emits a Withdraw event.\r\n  * @param amount uint of the amount of Ether the user wishes to withdraw\r\n  */\r\n  function withdraw(uint amount) public {\r\n    require(tokens[ethAddress][msg.sender] \u003E= amount, \u0022Not enough balance\u0022);\r\n    tokens[ethAddress][msg.sender] = tokens[ethAddress][msg.sender].sub(amount);\r\n    msg.sender.transfer(amount);\r\n    emit Withdraw(ethAddress, msg.sender, amount, tokens[ethAddress][msg.sender]);\r\n  }\r\n\r\n  /**\r\n  * This function handles deposits of Ethereum based tokens to the contract.\r\n  * Does not allow Ether.\r\n  * If token transfer fails, transaction is reverted and remaining gas is refunded.\r\n  * Emits a Deposit event.\r\n  * Note: Remember to call Token(address).approve(this, amount) or this contract will not be able to do the transfer on your behalf.\r\n  * @param token Ethereum contract address of the token or 0 for Ether\r\n  * @param amount uint of the amount of the token the user wishes to deposit\r\n  */\r\n  function depositToken(address token, uint amount) public {\r\n    require(token != ethAddress, \u0022Seed: expecting the zero address to be ERC20\u0022);\r\n    require(IFactory(factoryAddress).isFactoryTGenerated(token) || token == seedToken, \u0022Seed: deposit allowed only for known tokens\u0022);\r\n\r\n    depositingTokenFlag = true;\r\n    IERC20(token).transferFrom(msg.sender, address(this), amount);\r\n    depositingTokenFlag = false;\r\n    tokens[token][msg.sender] = tokens[token][msg.sender].add(amount);\r\n    emit Deposit(token, msg.sender, amount, tokens[token][msg.sender]);\r\n  }\r\n\r\n\r\n\r\n  /**\r\n  * This function handles withdrawals of Ethereum based tokens from the contract.\r\n  * Does not allow Ether.\r\n  * If token transfer fails, transaction is reverted and remaining gas is refunded.\r\n  * Emits a Withdraw event.\r\n  * @param token Ethereum contract address of the token or 0 for Ether\r\n  * @param amount uint of the amount of the token the user wishes to withdraw\r\n  */\r\n  function withdrawToken(address token, uint amount) public {\r\n    require(token != ethAddress, \u0022Seed: expecting the zero address to be ERC20\u0022);\r\n    require(tokens[token][msg.sender] \u003E= amount, \u0022Not enough balance\u0022);\r\n\r\n    tokens[token][msg.sender] = tokens[token][msg.sender].sub(amount);\r\n    require(IERC20(token).transfer(msg.sender, amount), \u0022Transfer failed\u0022);\r\n    emit Withdraw(token, msg.sender, amount, tokens[token][msg.sender]);\r\n  }\r\n\r\n  /**\r\n  * Retrieves the balance of a token based on a user address and token address.\r\n  * @param token Ethereum contract address of the token or 0 for Ether\r\n  * @param user Ethereum address of the user\r\n  * @return the amount of tokens on the exchange for a given user address\r\n  */\r\n  function balanceOf(address token, address user) public view returns (uint) {\r\n    return tokens[token][user];\r\n  }\r\n\r\n  ////////////////////////////////////////////////////////////////////////////////\r\n  // Trading\r\n  ////////////////////////////////////////////////////////////////////////////////\r\n\r\n  /**\r\n  * Stores the active order inside of the contract.\r\n  * Emits an Order event.\r\n  * Note: tokenGet \u0026 tokenGive can be the Ethereum contract address.\r\n  * @param tokenGet Ethereum contract address of the token to receive\r\n  * @param amountGet uint amount of tokens being received\r\n  * @param tokenGive Ethereum contract address of the token to give\r\n  * @param amountGive uint amount of tokens being given\r\n  * @param expires uint of block number when this order should expire\r\n  * @param nonce arbitrary random number\r\n  */\r\n  function order(\r\n          address tokenGet,\r\n          uint amountGet,\r\n          address tokenGive,\r\n          uint amountGive,\r\n          uint expires,\r\n          uint nonce) public {\r\n    require(expires \u003E block.number, \u0022expires must be in the future\u0022);\r\n    require(isValidPair(tokenGet, tokenGive), \u0022Not a valid pair\u0022);\r\n    require(canBeTransferred(tokenGet, msg.sender, amountGet), \u0022Token quota exceeded\u0022);\r\n    bytes32 hash = sha256(abi.encodePacked(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce));\r\n    orders[msg.sender][hash] = true;\r\n    emit Order(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, msg.sender);\r\n  }\r\n\r\n  /**\r\n  * Facilitates a trade from one user to another.\r\n  * Requires that the transaction is signed properly, the trade isn\u0027t past its expiration, and all funds are present to fill the trade.\r\n  * Calls tradeBalances().\r\n  * Updates orderFills with the amount traded.\r\n  * Emits a Trade event.\r\n  * Note: tokenGet \u0026 tokenGive can be the Ethereum contract address.\r\n  * Note: amount is in amountGet / tokenGet terms.\r\n  * @param tokenGet Ethereum contract address of the token to receive\r\n  * @param amountGet uint amount of tokens being received\r\n  * @param tokenGive Ethereum contract address of the token to give\r\n  * @param amountGive uint amount of tokens being given\r\n  * @param expires uint of block number when this order should expire\r\n  * @param nonce arbitrary random number\r\n  * @param user Ethereum address of the user who placed the order\r\n  * @param amount uint amount in terms of tokenGet that will be \u0022buy\u0022 in the trade\r\n  */\r\n  function trade(\r\n        address  tokenGet,\r\n        uint     amountGet,\r\n        address  tokenGive,\r\n        uint     amountGive,\r\n        uint     expires,\r\n        uint     nonce,\r\n        address  user,\r\n        uint     amount) public {\r\n    require(block.number \u003C= expires, \u0022Order Expired\u0022);\r\n\r\n    require(isValidPair(tokenGet, tokenGive), \u0022Not a valid pair\u0022);\r\n    require(canBeTransferred(tokenGet, msg.sender, amountGet), \u0022Token quota exceeded\u0022);\r\n    bytes32 hash = sha256(abi.encodePacked(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce));\r\n    require(orders[user][hash], \u0022Order does not exist\u0022);\r\n    require(orderFills[user][hash].add(amount) \u003C= amountGet, \u0022Order amount exceeds maximum availability\u0022);\r\n\r\n    tradeBalances(tokenGet, amountGet, tokenGive, amountGive, user, amount);\r\n    orderFills[user][hash] = orderFills[user][hash].add(amount);\r\n    uint executedAmount = amountGive.mul(amount) / amountGet;\r\n    emit Trade(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, user, amount, executedAmount, msg.sender);\r\n  }\r\n\r\n  /**\r\n  * This is a private function and is only being called from trade().\r\n  * Handles the movement of funds when a trade occurs.\r\n  * Takes fees.\r\n  * Updates token balances for both buyer and seller.\r\n  * Note: tokenGet \u0026 tokenGive can be the Ethereum contract address.\r\n  * Note: amount is in amountGet / tokenGet terms.\r\n  * @param tokenGet Ethereum contract address of the token to receive\r\n  * @param amountGet uint amount of tokens being received\r\n  * @param tokenGive Ethereum contract address of the token to give\r\n  * @param amountGive uint amount of tokens being given\r\n  * @param user Ethereum address of the user who placed the order\r\n  * @param amount uint amount in terms of tokenGet that will be \u0022buy\u0022 in the trade\r\n  */\r\n  function tradeBalances(address tokenGet, uint amountGet, address tokenGive, uint amountGive, address user, uint amount) private {\r\n    tokens[tokenGet][msg.sender] = tokens[tokenGet][msg.sender].sub(amount);\r\n    tokens[tokenGet][user] = tokens[tokenGet][user].add(amount);\r\n    tokens[tokenGive][user] = tokens[tokenGive][user].sub(amountGive.mul(amount).div(amountGet));\r\n    tokens[tokenGive][msg.sender] = tokens[tokenGive][msg.sender].add(amountGive.mul(amount).div(amountGet));\r\n  }\r\n\r\n  /**\r\n  * This function is to test if a trade would go through.\r\n  * Note: tokenGet \u0026 tokenGive can be the Ethereum contract address.\r\n  * Note: amount is in amountGet / tokenGet terms.\r\n  * @param tokenGet Ethereum contract address of the token to receive\r\n  * @param amountGet uint amount of tokens being received\r\n  * @param tokenGive Ethereum contract address of the token to give\r\n  * @param amountGive uint amount of tokens being given\r\n  * @param expires uint of block number when this order should expire\r\n  * @param nonce arbitrary random number\r\n  * @param user Ethereum address of the user who placed the order\r\n  * @param amount uint amount in terms of tokenGet that will be \u0022buy\u0022 in the trade\r\n  * @param sender Ethereum address of the user taking the order\r\n  * @return bool: true if the trade would be successful, false otherwise\r\n  */\r\n  function testTrade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint amount, address sender) public view returns(bool) {\r\n    if (tokens[tokenGet][sender] \u003C amount) return false;\r\n    if (availableVolume(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, user) \u003C amount) return false;\r\n    if (!canBeTransferred(tokenGet, msg.sender, amountGet)) return false;\r\n\r\n    return true;\r\n  }\r\n\r\n  function canBeTransferred(address token, address user, uint newAmt) private view returns(bool) {\r\n    return (token == seedToken || token == ethAddress || IERC20(token).okToTransferTokens(user, newAmt \u002B tokens[token][user]) ) ;\r\n  }\r\n\r\n  /**\r\n  * This function checks the available volume for a given order.\r\n  * Note: tokenGet \u0026 tokenGive can be the Ethereum contract address.\r\n  * @param tokenGet Ethereum contract address of the token to receive\r\n  * @param amountGet uint amount of tokens being received\r\n  * @param tokenGive Ethereum contract address of the token to give\r\n  * @param amountGive uint amount of tokens being given\r\n  * @param expires uint of block number when this order should expire\r\n  * @param nonce arbitrary random number\r\n  * @param user Ethereum address of the user who placed the order\r\n  * @return uint: amount of volume available for the given order in terms of amountGet / tokenGet\r\n  */\r\n  function availableVolume(\r\n          address tokenGet,\r\n          uint amountGet,\r\n          address tokenGive,\r\n          uint amountGive,\r\n          uint expires,\r\n          uint nonce,\r\n          address user\r\n  ) public view returns(uint) {\r\n\r\n    bytes32 hash = sha256(abi.encodePacked(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce));\r\n\r\n    if ( ! (orders[user][hash] || block.number \u003C= expires )) {\r\n      return 0;\r\n    }\r\n\r\n    uint[2] memory available;\r\n    available[0] = amountGet.sub(orderFills[user][hash]);\r\n    available[1] = tokens[tokenGive][user].mul(amountGet) / amountGive;\r\n\r\n    if (available[0] \u003C available[1]) {\r\n      return available[0];\r\n    } else {\r\n      return available[1];\r\n    }\r\n\r\n  }\r\n\r\n  /**\r\n  * This function checks the amount of an order that has already been filled.\r\n  * Note: tokenGet \u0026 tokenGive can be the Ethereum contract address.\r\n  * @param tokenGet Ethereum contract address of the token to receive\r\n  * @param amountGet uint amount of tokens being received\r\n  * @param tokenGive Ethereum contract address of the token to give\r\n  * @param amountGive uint amount of tokens being given\r\n  * @param expires uint of block number when this order should expire\r\n  * @param nonce arbitrary random number\r\n  * @param user Ethereum address of the user who placed the order\r\n  * @return uint: amount of the given order that has already been filled in terms of amountGet / tokenGet\r\n  */\r\n  function amountFilled(\r\n          address tokenGet,\r\n          uint amountGet,\r\n          address tokenGive,\r\n          uint amountGive,\r\n          uint expires,\r\n          uint nonce,\r\n          address user) public view returns(uint) {\r\n    bytes32 hash = sha256(abi.encodePacked(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce));\r\n    return orderFills[user][hash];\r\n  }\r\n\r\n  /**\r\n  * This function cancels a given order by editing its fill data to the full amount.\r\n  * Requires that the transaction is signed properly.\r\n  * Updates orderFills to the full amountGet\r\n  * Emits a Cancel event.\r\n  * Note: tokenGet \u0026 tokenGive can be the Ethereum contract address.\r\n  * @param tokenGet Ethereum contract address of the token to receive\r\n  * @param amountGet uint amount of tokens being received\r\n  * @param tokenGive Ethereum contract address of the token to give\r\n  * @param amountGive uint amount of tokens being given\r\n  * @param expires uint of block number when this order should expire\r\n  * @param nonce arbitrary random number\r\n  * @return uint: amount of the given order that has already been filled in terms of amountGet / tokenGet\r\n  */\r\n  function cancelOrder(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce) public {\r\n    bytes32 hash = sha256(abi.encodePacked(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce));\r\n    require(orders[msg.sender][hash], \u0022Order does not exist\u0022);\r\n    orderFills[msg.sender][hash] = amountGet;\r\n    emit Cancel(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, msg.sender);\r\n  }\r\n\r\n  /**\r\n  * this function check if the given pair is valid.\r\n  * @param tokenGet ethereum contract address of the token to receive\r\n  * @param tokenGive ethereum contract address of the token to give\r\n  * @return bool: return true if given pair is valid, otherwise false.\r\n  */\r\n  function isValidPair(address tokenGet, address tokenGive) private view returns(bool) {\r\n     if( isEthSeedPair(tokenGet, tokenGive) ) return true;\r\n     return isSeedPair(tokenGet, tokenGive);\r\n  }\r\n\r\n  /**\r\n  * this function check if the given pair is ETH-SEED or SEED-ETH.\r\n  * @param tokenGet ethereum contract address of the token to receive\r\n  * @param tokenGive ethereum contract address of the token to give\r\n  * @return bool: return true if it\u0027s either ETH-SEED or SEED-ETH, otherwise false.\r\n  */\r\n  function isEthSeedPair(address tokenGet, address tokenGive) private view returns(bool) {\r\n      if (tokenGet == ethAddress \u0026\u0026 tokenGive == seedToken) return true;\r\n      if (tokenGet == seedToken \u0026\u0026 tokenGive == ethAddress) return true;\r\n      return false;\r\n  }\r\n\r\n  /**\r\n  * this function check if the given pair of tokens include the seed native token.\r\n  * @param tokenGet ethereum contract address of the token to receive\r\n  * @param tokenGive ethereum contract address of the token to give\r\n  * @return bool: return true if one of the token is seed, otherwise false.\r\n  */\r\n  function isSeedPair(address tokenGet, address tokenGive) private view returns(bool) {\r\n      if (tokenGet == tokenGive) return false;\r\n      if (tokenGet == seedToken) return true;\r\n      if (tokenGive == seedToken) return true;\r\n      return false;\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenGet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amountGet\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022tokenGive\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amountGive\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022expires\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022order\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenGet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amountGet\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022tokenGive\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amountGive\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022expires\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022testTrade\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenGet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amountGet\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022tokenGive\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amountGive\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022expires\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022amountFilled\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022seedToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022depositToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenGet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amountGet\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022tokenGive\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amountGive\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022expires\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022availableVolume\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenGet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amountGet\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022tokenGive\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amountGive\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022expires\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022cancelOrder\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenGet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amountGet\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022tokenGive\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amountGive\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022expires\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022trade\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022factoryAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022deposit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_seedToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_factoryAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenGet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amountGet\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenGive\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amountGive\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022expires\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Order\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenGet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amountGet\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenGive\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amountGive\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022expires\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Cancel\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenGet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amountGet\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenGive\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amountGive\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022expires\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022get\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022executedAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022give\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Trade\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Deposit\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Withdraw\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"SeedDex","CompilerVersion":"v0.5.2\u002Bcommit.1df8f40c","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000c969e16e63ff31ad4bcac3095c616644e6912d7900000000000000000000000035c8c5d9bec0dcd50ce4bd929fa3bed9ed1f7c89","Library":"","SwarmSource":"bzzr://6f8519ee3dac8b323523f3f4bd1d4efb9b97c088c88d745dda60b72989550b07"}]