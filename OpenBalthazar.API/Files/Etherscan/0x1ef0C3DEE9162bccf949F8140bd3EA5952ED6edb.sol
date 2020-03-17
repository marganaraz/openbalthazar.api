[{"SourceCode":"pragma solidity 0.4.25;\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://eips.ethereum.org/EIPS/eip-20\r\n */\r\ncontract IERC20 {\r\n    function transfer(address to, uint256 value) public returns (bool);\r\n\r\n    function approve(address spender, uint256 value) public returns (bool);\r\n\r\n    function transferFrom(address from, address to, uint256 value) public returns (bool);\r\n\r\n    function balanceOf(address who) public view returns (uint256);\r\n\r\n    function allowance(address owner, address spender) public view returns (uint256);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Unsigned math operations with safety checks that revert on error.\r\n */\r\nlibrary SafeMath {\r\n  /**\r\n   * @dev Multiplies two unsigned integers, reverts on overflow.\r\n   */\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n    // benefit is lost if \u0027b\u0027 is also tested.\r\n    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n\r\n    uint256 c = a * b;\r\n    require(c / a == b);\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n   * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.\r\n   */\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // Solidity only automatically asserts when dividing by 0\r\n    require(b \u003E 0);\r\n    uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n   * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n   */\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    require(b \u003C= a);\r\n    uint256 c = a - b;\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n   * @dev Adds two unsigned integers, reverts on overflow.\r\n   */\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    require(c \u003E= a);\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n   * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),\r\n   * reverts when dividing by zero.\r\n   */\r\n  function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    require(b != 0);\r\n    return a % b;\r\n  }\r\n}\r\n\r\ncontract Auth {\r\n\r\n  address internal admin;\r\n\r\n  event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);\r\n\r\n  constructor(address _admin) internal {\r\n    admin = _admin;\r\n  }\r\n\r\n  modifier onlyAdmin() {\r\n    require(msg.sender == admin, \u0022onlyAdmin\u0022);\r\n    _;\r\n  }\r\n\r\n  function transferOwnership(address _newOwner) onlyAdmin internal {\r\n    require(_newOwner != address(0x0));\r\n    admin = _newOwner;\r\n    emit OwnershipTransferred(msg.sender, _newOwner);\r\n  }\r\n}\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://eips.ethereum.org/EIPS/eip-20\r\n */\r\ncontract IUSDT {\r\n    function transfer(address to, uint256 value) public;\r\n\r\n    function approve(address spender, uint256 value) public;\r\n\r\n    function transferFrom(address from, address to, uint256 value) public;\r\n\r\n    function balanceOf(address who) public view returns (uint256);\r\n\r\n    function allowance(address owner, address spender) public view returns (uint256);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\ncontract TagMembership is Auth {\r\n  using SafeMath for uint;\r\n\r\n  enum Type {\r\n    Monthly,\r\n    Yearly\r\n  }\r\n  enum Method {\r\n    TAG,\r\n    USDT\r\n  }\r\n  struct Membership {\r\n    Type[] types;\r\n    uint[] expiredAt;\r\n  }\r\n  mapping(string =\u003E Membership) memberships;\r\n  string[] private members;\r\n  IERC20 tagToken = IERC20(0x5Ac44ca5368698568d96437363BEcc8Cd84EF061);\r\n  IUSDT usdtToken = IUSDT(0xdAC17F958D2ee523a2206206994597C13D831ec7);\r\n  uint public tokenPrice = 2;\r\n  uint public vipMonthFee = 10000;\r\n  uint public vipYearFee = 100000;\r\n\r\n  event MembershipActivated(string userId, Type membershipType, uint expiredAt, Method method);\r\n\r\n  constructor(address _admin) public Auth(_admin) {}\r\n\r\n  // ADMIN FUNCTIONS\r\n\r\n  function countMembers() onlyAdmin public view returns(uint) {\r\n    return members.length;\r\n  }\r\n\r\n  function getUserInfoAt(string _user, uint _position) onlyAdmin public view returns(uint, uint) {\r\n    Membership storage memberShip = memberships[_user];\r\n    require(_position \u003C memberShip.types.length, \u0027position invalid\u0027);\r\n    return (\r\n      uint(memberShip.types[_position]),\r\n      memberShip.expiredAt[_position]\r\n    );\r\n  }\r\n\r\n  function updateTokenPrice(uint _tokenPrice) onlyAdmin public {\r\n    tokenPrice = _tokenPrice;\r\n  }\r\n\r\n  function setVipMonthFee(uint _vipMonthFee) onlyAdmin public {\r\n    require(_vipMonthFee \u003E 0, \u0027fee is invalid\u0027);\r\n    vipMonthFee = _vipMonthFee;\r\n  }\r\n\r\n  function setVipYearFee(uint _vipYearFee) onlyAdmin public {\r\n    require(_vipYearFee \u003E vipMonthFee, \u0027fee is invalid\u0027);\r\n    vipYearFee = _vipYearFee;\r\n  }\r\n\r\n  function updateAdmin(address _admin) public {\r\n    transferOwnership(_admin);\r\n  }\r\n\r\n  function drain() onlyAdmin public {\r\n    tagToken.transfer(admin, tagToken.balanceOf(address(this)));\r\n    usdtToken.transfer(admin, usdtToken.balanceOf(address(this)));\r\n    admin.transfer(address(this).balance);\r\n  }\r\n\r\n  // PUBLIC FUNCTIONS\r\n\r\n  function activateMembership(Type _type, string _userId, Method _method) public {\r\n    uint tokenAmount = calculateTokenAmount(_type, _method);\r\n    if (_method == Method.TAG) {\r\n      require(tagToken.allowance(msg.sender, address(this)) \u003E= tokenAmount, \u0027please call approve() first\u0027);\r\n      require(tagToken.balanceOf(msg.sender) \u003E= tokenAmount, \u0027you have not enough token\u0027);\r\n      require(tagToken.transferFrom(msg.sender, admin, tokenAmount), \u0027transfer token to contract failed\u0027);\r\n    } else {\r\n      require(usdtToken.allowance(msg.sender, address(this)) \u003E= tokenAmount, \u0027please call approve() first\u0027);\r\n      require(usdtToken.balanceOf(msg.sender) \u003E= tokenAmount, \u0027you have not enough token\u0027);\r\n      usdtToken.transferFrom(msg.sender, admin, tokenAmount);\r\n    }\r\n    if (!isMembership(_userId)) {\r\n      members.push(_userId);\r\n    }\r\n    Membership storage memberShip = memberships[_userId];\r\n    memberShip.types.push(_type);\r\n    uint newExpiredAt;\r\n    uint extendedPeriod = _type == Type.Monthly ? 30 days : 365 days;\r\n    bool userStillInMembership = memberShip.expiredAt.length \u003E 0 \u0026\u0026 memberShip.expiredAt[memberShip.expiredAt.length - 1] \u003E now;\r\n    if (userStillInMembership) {\r\n      newExpiredAt = memberShip.expiredAt[memberShip.expiredAt.length - 1].add(extendedPeriod);\r\n    } else {\r\n      newExpiredAt = now.add(extendedPeriod);\r\n    }\r\n    memberShip.expiredAt.push(newExpiredAt);\r\n    emit MembershipActivated(_userId, _type, newExpiredAt, _method);\r\n  }\r\n\r\n  function getMyMembership(string _userId) public view returns(uint, uint) {\r\n    Membership storage memberShip = memberships[_userId];\r\n    return (\r\n      uint(memberShip.types[memberShip.types.length - 1]),\r\n      memberShip.expiredAt[memberShip.expiredAt.length - 1]\r\n    );\r\n  }\r\n\r\n  // PRIVATE FUNCTIONS\r\n\r\n  function calculateTokenAmount(Type _type, Method _method) private view returns (uint) {\r\n    uint activationPrice = _type == Type.Monthly ? vipMonthFee : vipYearFee;\r\n    if (_method == Method.TAG) {\r\n      return activationPrice.div(tokenPrice).mul(70).div(100).mul(10 ** 18);\r\n    }\r\n    uint usdt = 1000;\r\n    return activationPrice.div(usdt).mul(1e6);\r\n  }\r\n\r\n  function isMembership(string _user) private view returns(bool) {\r\n    return memberships[_user].types.length \u003E 0;\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_type\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022_userId\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_method\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022name\u0022:\u0022activateMembership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022countMembers\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022vipMonthFee\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022vipYearFee\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_vipYearFee\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setVipYearFee\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenPrice\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022updateTokenPrice\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_userId\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022getMyMembership\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tokenPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_position\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getUserInfoAt\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022drain\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_vipMonthFee\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setVipMonthFee\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_admin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022updateAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_admin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022userId\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022membershipType\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022expiredAt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022method\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022name\u0022:\u0022MembershipActivated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"TagMembership","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000f8400e6d6b8ffc18ce2d44f30d581dc2ef90da5c","Library":"","SwarmSource":"bzzr://300c990ca8c8f11ee44e2590ae02e568402f31a89803e5d6504f5e528019305e"}]