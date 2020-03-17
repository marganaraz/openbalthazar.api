[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n     * account.\r\n     */\r\n    constructor () internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @return the address of the owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner());\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @return true if \u0060msg.sender\u0060 is the owner of the contract.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return msg.sender == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to relinquish control of the contract.\r\n     * @notice Renouncing to ownership will leave the contract without an owner.\r\n     * It will not be possible to call the functions with the \u0060onlyOwner\u0060\r\n     * modifier anymore.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\n// File: contracts/KBDChestSale.sol\r\n\r\npragma solidity 0.5.0;\r\n\r\n\r\n// https://github.com/ethereum/EIPs/issues/20\r\n\r\ninterface ERC20 {\r\n    function transfer(address to, uint256 value) external returns (bool);\r\n\r\n    function approve(address spender, uint256 value) external returns (bool);\r\n\r\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\r\n\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    function balanceOf(address who) external view returns (uint256);\r\n\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\nlibrary SafeMath {\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n    c = a \u002B b;\r\n    require(c \u003E= a);\r\n  }\r\n\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n    require(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n\r\n    c = a * b;\r\n    require(c / a == b);\r\n  }\r\n\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n    // Since Solidity automatically asserts when dividing by 0,\r\n    // but we only need it to revert.\r\n    require(b \u003E 0);\r\n    return a / b;\r\n  }\r\n\r\n  function mod(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n    // Same reason as \u0060div\u0060.\r\n    require(b \u003E 0);\r\n    return a % b;\r\n  }\r\n\r\n  function ceilingDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n    return add(div(a, b), mod(a, b) \u003E 0 ? 1 : 0);\r\n  }\r\n\r\n  function subU64(uint64 a, uint64 b) internal pure returns (uint64 c) {\r\n    require(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function addU8(uint8 a, uint8 b) internal pure returns (uint8 c) {\r\n    c = a \u002B b;\r\n    require(c \u003E= a);\r\n  }\r\n}\r\n\r\n/**\r\n * @dev KingdomsBeyond Founder Sale Smart contract\r\n * Facilitates the distribution of chests purchased \r\n * Chests can be purchased with ETH natively or \r\n * alternatively purchased with ERC20 Tokens via KyberSwap\r\n * or Fiat via NiftyGateway.\r\n */\r\ncontract KBDChestSale is\r\n  Ownable\r\n{\r\n  using SafeMath for uint256;\r\n\r\n  /**\r\n   * @dev Event is broadcast whenever a chest is purchased. \r\n   */ \r\n  event ChestPurchased(\r\n    uint16 _chestType,\r\n    uint16 _chestAmount,\r\n    address indexed _buyer,\r\n    address indexed _referrer,\r\n    uint256 _referralReward\r\n  );\r\n\r\n  struct Discount {\r\n    uint256 blockNumber; \r\n    uint256 percentage;\r\n  }\r\n  \r\n  event Swap(address indexed sender, ERC20 srcToken, ERC20 destToken);\r\n  \r\n  // Updated every day \r\n  uint256 ethPrice;\r\n  \r\n  mapping (uint256 =\u003E uint256) chestTypePricing;\r\n  mapping (address =\u003E bool) partnerReferral;\r\n  mapping (uint256 =\u003E Discount) discountMapping;    \r\n\r\n  constructor() public {\r\n    chestTypePricing[0] = 5; \r\n    chestTypePricing[1] = 20;\r\n    chestTypePricing[2] = 50;\r\n    ethPrice = 209;\r\n  }\r\n  \r\n  function setPartner(address _address, bool _status) external onlyOwner{\r\n      partnerReferral[_address] = _status;\r\n  }\r\n  \r\n  function setDiscount(uint256 _id, uint256 _blockNumber, uint256 _percentage) external onlyOwner{\r\n      Discount memory discount;\r\n      discount.blockNumber = _blockNumber;\r\n      discount.percentage = _percentage;\r\n      discountMapping[_id] = discount;\r\n  }\r\n  \r\n  // Sets the price of 1 Eth in volatile situations\r\n  function setPriceOfEth(uint256 _price) external onlyOwner {\r\n      ethPrice = _price;\r\n  }\r\n  \r\n  function getPriceOfEth() external view returns (uint256) {\r\n      return ethPrice;\r\n  }\r\n  \r\n  function setChestTypePricing(uint256 _chestType, uint256 _chestPrice) external onlyOwner {\r\n      chestTypePricing[_chestType] = _chestPrice;\r\n  }\r\n  \r\n  function purchaseChest(uint16 _chestType, uint16 _chestAmount, uint256 _discountId, address payable _referrer) external payable {\r\n        _purchaseChest(msg.sender, _referrer, _chestType, _chestAmount, msg.value, _discountId);\r\n  } \r\n  \r\n  // The cost of the chest in Wei\r\n  function getChestPrice(uint256 _chestType, uint256 _discountId) public view returns (uint256) {\r\n      uint256 chestPrice = chestTypePricing[_chestType];\r\n      require(chestPrice != 0, \u0022Invalid chest\u0022);\r\n      \r\n      Discount memory discount = discountMapping[_discountId];\r\n\r\n      if (discount.percentage != 0) {\r\n        require(discount.blockNumber \u003E= block.number, \u0022Discount has expired\u0022);\r\n        return ((chestPrice).mul(discount.percentage).div(10000)).mul(1000000000000000000).div(ethPrice);\r\n      } \r\n      \r\n      return (chestPrice).mul(1000000000000000000).div(ethPrice);\r\n  }\r\n  \r\n  function getChestPrice(uint8 _chestType, uint8 _chestAmount, uint256 _discountId) public view returns (uint256) {\r\n      require(_chestAmount \u003C 256, \u0022Invalid Amount\u0022);\r\n      \r\n      return getChestPrice(_chestType, _discountId) * _chestAmount;\r\n  }\r\n\r\n  function _getReferralPercentage(address _referrer, address _owner) internal view returns (uint256 _percentage) {\r\n      if (_referrer != _owner \u0026\u0026 _referrer != address (0)) {\r\n          if (partnerReferral[_referrer]) {\r\n              return 3000;\r\n          } else {\r\n              return 1000;\r\n          }\r\n      } \r\n      return 0;\r\n  }\r\n  \r\n  function _purchaseChest(\r\n      address payable _buyer, \r\n      address payable _referrer, \r\n      uint256 _chestType,\r\n      uint256 _chestAmount,\r\n      uint256 _ethAmount,\r\n      uint256 _discountId\r\n  ) internal {\r\n    uint256 _totalPrice = getChestPrice(uint8(_chestType), uint8(_chestAmount), _discountId);\r\n\r\n    // Check if we received enough payment.\r\n    require(_ethAmount \u003E= _totalPrice, \u0022Not enough ether\u0022);\r\n\r\n    // Send back the ETH change, if there is any.\r\n    if (_ethAmount \u003E _totalPrice) {\r\n      _buyer.transfer(_ethAmount - _totalPrice);\r\n    }\r\n\r\n    uint256 _referralReward = _totalPrice\r\n      .mul(_getReferralPercentage(_referrer, _buyer))\r\n      .div(10000);\r\n\r\n    emit ChestPurchased(uint16(_chestType), uint16(_chestAmount), _buyer, _referrer, _referralReward);\r\n\r\n    /// @dev If the referral reward cannot be sent because of a referrer\u0027s fault, set it to 0.\r\n    if (_referralReward \u003E 0 \u0026\u0026 !_referrer.send(_referralReward)) {\r\n      _referralReward = 0;\r\n    }\r\n  }\r\n  \r\n  /// @dev Withdraw function to withdraw the earnings \r\n  function withdrawBalance()\r\n  external onlyOwner {\r\n    msg.sender.transfer(address(this).balance);\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_chestType\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_chestPrice\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setChestTypePricing\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_status\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setPartner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_chestType\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_discountId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getChestPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getPriceOfEth\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdrawBalance\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_chestType\u0022,\u0022type\u0022:\u0022uint16\u0022},{\u0022name\u0022:\u0022_chestAmount\u0022,\u0022type\u0022:\u0022uint16\u0022},{\u0022name\u0022:\u0022_discountId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_referrer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022purchaseChest\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_chestType\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022_chestAmount\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022_discountId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getChestPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_blockNumber\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_percentage\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setDiscount\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_price\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setPriceOfEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_chestType\u0022,\u0022type\u0022:\u0022uint16\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_chestAmount\u0022,\u0022type\u0022:\u0022uint16\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_buyer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_referrer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_referralReward\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ChestPurchased\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022srcToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022destToken\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Swap\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"KBDChestSale","CompilerVersion":"v0.5.0\u002Bcommit.1d4f565a","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://0fa636418b4875a1789b6419094a17e2d92a885aacdf4b870246ba064247cce4"}]