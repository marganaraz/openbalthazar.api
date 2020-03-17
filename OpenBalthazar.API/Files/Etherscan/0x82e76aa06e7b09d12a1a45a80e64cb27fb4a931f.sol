[{"SourceCode":"pragma solidity ^0.4.25;\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Unsigned math operations with safety checks that revert on error.\r\n */\r\nlibrary SafeMath {\r\n\r\n    /**\r\n     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a, \u0022SafeMath: subtraction overflow\u0022);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Adds two unsigned integers, reverts on overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n   function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n}\r\n\r\ncontract ERC20Basic {\r\n  uint256 public totalSupply;\r\n  function balanceOf(address who) public view returns (uint256);\r\n  function transfer(address to, uint256 value) public returns (bool);\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ncontract ERC20 is ERC20Basic {\r\n  function allowance(address owner, address spender) public view returns (uint256);\r\n  function transferFrom(address from, address to, uint256 value) public returns (bool);\r\n  function approve(address spender, uint256 value) public returns (bool);\r\n  event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n/**\r\n * @title SafeERC20\r\n * @dev Wrappers around ERC20 operations that throw on failure.\r\n * To use this library you can add a \u0060using SafeERC20 for ERC20;\u0060 statement to your contract,\r\n * which allows you to call the safe operations as \u0060token.safeTransfer(...)\u0060, etc.\r\n */\r\nlibrary SafeERC20 {\r\n  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {\r\n    assert(token.transfer(to, value));\r\n  }\r\n\r\n  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {\r\n    assert(token.transferFrom(from, to, value));\r\n  }\r\n\r\n  function safeApprove(ERC20 token, address spender, uint256 value) internal {\r\n    assert(token.approve(spender, value));\r\n  }\r\n}\r\n\r\n\r\ncontract Ownable {\r\n  address public owner;\r\n\r\n  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n  /**\r\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n   * account.\r\n   */\r\n  constructor() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n   * @param newOwner The address to transfer ownership to.\r\n   */\r\n  function transferOwnership(address newOwner) public onlyOwner {\r\n    require(newOwner != address(0));\r\n    emit OwnershipTransferred(owner, newOwner);\r\n    owner = newOwner;\r\n  }\r\n\r\n}\r\n\r\n/**\r\n * @title BIGG Cash Distribution\r\n *\r\n * @dev Distribute tokens\r\n */\r\ncontract BiggDistribution is Ownable {\r\n\r\n  using SafeMath for uint256;\r\n  using SafeERC20 for ERC20;\r\n\r\n  uint256 private constant decimalFactor = 10**uint256(18);\r\n\r\n  uint256 public startTime;\r\n  ERC20 public tokenContract;\r\n  uint256 public AVAILABLE_DISTRIBUTION_SUPPLY  =   10000000 * decimalFactor;\r\n  \r\n\r\n  uint256 public totalDistributed = 0;\r\n  uint256 public totalCount = 0;\r\n  uint256 public batchNumber = 0;\r\n\r\n  // Keeps track of whether or not a drop has been made to a particular address\r\n  mapping (address =\u003E bool) public distributed;\r\n\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  event BIGGDistributed(uint256 indexed _batchNumber, uint256 _distributionAmount,  uint256 _distributionCount, uint256 _totalCount, uint256 _totalDistributed, uint256 _totalLeft);\r\n  event BIGGDistributionUnprocessed(uint256 indexed _batchNumber, uint256 _index, address _recipient,  uint256 _amount, bool _distributed);\r\n\r\n\r\n  constructor(address _tokenContract, uint256 _startTime) public {\r\n    require(_startTime \u003E= now);\r\n    startTime = _startTime;\r\n    tokenContract = ERC20(_tokenContract);\r\n  }\r\n\r\n\r\n  function distributeTokens(address[] memory _recipient, uint256[] memory _amount) public onlyOwner {\r\n    require(now \u003E= startTime);\r\n    require(_recipient.length == _amount.length);\r\n\r\n    uint256 distributedCount = 0;\r\n    uint256 distributedAmount = 0;\r\n    uint256 ethAmount;\r\n    uint256 totalLeft;\r\n\r\n    totalLeft = tokenContract.balanceOf(address(this));\r\n    batchNumber = batchNumber.add(1);\r\n    for(uint256 i = 0; i \u003C _recipient.length; i\u002B\u002B)\r\n    {\r\n        if (!distributed[_recipient[i]] \u0026\u0026 _recipient[i] != address(0) \u0026\u0026 _amount[i] != 0) {\r\n          ethAmount = _amount[i].mul(decimalFactor);\r\n          if (totalLeft \u003E= ethAmount)\r\n            tokenContract.transfer(_recipient[i], ethAmount);\r\n          else\r\n            require(false, \u0022Cannot process batch, no more tokens left.\u0022);\r\n          distributed[_recipient[i]] = true;\r\n          distributedAmount = distributedAmount.add(ethAmount);\r\n          distributedCount = distributedCount.add(1);\r\n          totalCount = totalCount.add(1);\r\n          totalLeft = totalLeft.sub(ethAmount);\r\n          totalDistributed = totalDistributed.add(ethAmount);\r\n        } else {\r\n          emit BIGGDistributionUnprocessed(batchNumber, i\u002B1, _recipient[i], _amount[i], distributed[_recipient[i]]);\r\n        }\r\n\r\n    }\r\n    \r\n    emit BIGGDistributed(batchNumber, distributedAmount, distributedCount, totalCount, totalDistributed, totalLeft);\r\n\r\n  }\r\n\r\n  function closeContract() public onlyOwner { //onlyOwner is custom modifier\r\n    tokenContract.transfer(owner, tokenContract.balanceOf(this));\r\n    selfdestruct(owner);  // \u0060owner\u0060 is the owners address\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022AVAILABLE_DISTRIBUTION_SUPPLY\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalCount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_recipient\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022distributeTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tokenContract\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022distributed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022closeContract\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022startTime\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022batchNumber\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalDistributed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenContract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_startTime\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_batchNumber\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_distributionAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_distributionCount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_totalCount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_totalDistributed\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_totalLeft\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022BIGGDistributed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_batchNumber\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_index\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_distributed\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022BIGGDistributionUnprocessed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"BiggDistribution","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000d9d993fdd6dad5270c0896b364bdbeff38e010cf000000000000000000000000000000000000000000000000000000005d58fa31","Library":"","SwarmSource":"bzzr://d39305d7230e4741ca0421f0637f15a9619814215c97013c92f1b36b0f3154ce"}]