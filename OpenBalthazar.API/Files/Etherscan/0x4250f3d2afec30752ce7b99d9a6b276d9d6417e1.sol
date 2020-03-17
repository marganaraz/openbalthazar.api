[{"SourceCode":"pragma solidity ^0.4.24;\r\n\r\n// File: contracts/math/SafeMath.sol\r\n\r\n// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol\r\n\r\n// @title SafeMath: overflow/underflow checks\r\n// @notice Math operations with safety checks that throw on error\r\nlibrary SafeMath {\r\n\r\n  // @notice Multiplies two numbers, throws on overflow.\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n    uint256 c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  // @notice Integer division of two numbers, truncating the quotient.\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    // uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return a / b;\r\n  }\r\n\r\n  // @notice Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  // @notice Adds two numbers, throws on overflow.\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n\r\n  // @notice Returns fractional amount\r\n  function getFractionalAmount(uint256 _amount, uint256 _percentage)\r\n  internal\r\n  pure\r\n  returns (uint256) {\r\n    return div(mul(_amount, _percentage), 100);\r\n  }\r\n\r\n}\r\n\r\n// File: contracts/database/API.sol\r\n\r\ninterface TokenView {\r\n  function totalSupply() external view returns (uint);\r\n  function balanceOf(address _investor) external view returns (uint);\r\n  function valuePerToken() external view returns (uint);\r\n  function scalingFactor() external view returns (uint);\r\n  function assetIncome() external view returns (uint);\r\n  function getERC20() external view returns (address);\r\n}\r\n\r\ninterface DBView {\r\n  function uintStorage(bytes32 _key) external view returns (uint);\r\n  function stringStorage(bytes32 _key) external  view returns (string);\r\n  function addressStorage(bytes32 _key) external  view returns (address);\r\n  function bytesStorage(bytes32 _key) external view returns (bytes);\r\n  function bytes32Storage(bytes32 _key) external view returns (bytes32);\r\n  function boolStorage(bytes32 _key) external view returns (bool);\r\n  function intStorage(bytes32 _key) external view returns (bool);\r\n}\r\n\r\n// @title A contract that gets variables from the _database\r\n// @notice The API contract can only view the database. It has no write privileges\r\ncontract API {\r\n  using SafeMath for uint256;\r\n\r\n  DBView private database;\r\n  uint constant scalingFactor = 10e32;\r\n\r\n  constructor(address _database)\r\n  public {\r\n    database = DBView(_database);\r\n  }\r\n\r\n  function getContract(string _name)\r\n  public\r\n  view\r\n  returns (address) {\r\n    return database.addressStorage(keccak256(abi.encodePacked(\u0027contract\u0027, _name)));\r\n  }\r\n\r\n  function getAddr(bytes32 _key)\r\n  public\r\n  view\r\n  returns (address) {\r\n    return database.addressStorage(_key);\r\n  }\r\n\r\n  function getUint(bytes32 _key)\r\n  public\r\n  view\r\n  returns (uint) {\r\n    return database.uintStorage(_key);\r\n  }\r\n\r\n  function hashSB(string _a, bytes32 _b)\r\n  public\r\n  pure\r\n  returns (bytes32) {\r\n    return keccak256(abi.encodePacked(_a, _b));\r\n  }\r\n\r\n  function getMethodID(string _functionString)\r\n  public\r\n  pure\r\n  returns (bytes4) {\r\n    return bytes4(keccak256(abi.encodePacked(_functionString)));\r\n  }\r\n\r\n  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n  //                                        Crowdsale and Assets\r\n  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n  function getAssetFundingToken(address _assetAddress)\r\n  public\r\n  view\r\n  returns(address) {\r\n    address fundingTokenAddress = TokenView(_assetAddress).getERC20();\r\n    return fundingTokenAddress;\r\n  }\r\n\r\n  function getAssetIPFS(address _assetAddress)\r\n  public\r\n  view\r\n  returns(string) {\r\n    return database.stringStorage(keccak256(abi.encodePacked(\u0022asset.ipfs\u0022, _assetAddress)));\r\n  }\r\n\r\n  // IF we decide not to store assetIncome\r\n  // function getAssetIncome(address _assetAddress)\r\n  // public\r\n  // view\r\n  // returns (uint) {\r\n  //   TokenView asset = TokenView(_assetAddress);\r\n  //   uint valuePerToken =  asset.valuePerToken();\r\n  //   return (valuePerToken * (asset.totalSupply())) / asset.scalingFactor();\r\n  // }\r\n\r\n  function getAssetROI(address _assetAddress)\r\n  public\r\n  view\r\n  returns (uint) {\r\n    TokenView assetToken = TokenView(_assetAddress);\r\n    return (assetToken.assetIncome() * 100) /  assetToken.totalSupply();\r\n  }\r\n\r\n  function getCrowdsaleGoal(address _assetAddress)\r\n  public\r\n  view\r\n  returns(uint) {\r\n    uint fundingGoal = database.uintStorage(keccak256(abi.encodePacked(\u0022crowdsale.goal\u0022, _assetAddress)));\r\n    return fundingGoal;\r\n  }\r\n\r\n  function getCrowdsaleDeadline(address _assetAddress)\r\n  public\r\n  view\r\n  returns(uint) {\r\n    return database.uintStorage(keccak256(abi.encodePacked(\u0022crowdsale.deadline\u0022, _assetAddress)));\r\n  }\r\n\r\n  function crowdsaleFinalized(address _assetAddress)\r\n  public\r\n  view\r\n  returns(bool) {\r\n    return database.boolStorage(keccak256(abi.encodePacked(\u0022crowdsale.finalized\u0022, _assetAddress)));\r\n  }\r\n\r\n  function crowdsalePaid(address _assetAddress)\r\n  public\r\n  view\r\n  returns(bool) {\r\n    return database.boolStorage(keccak256(abi.encodePacked(\u0022crowdsale.paid\u0022, _assetAddress)));\r\n  }\r\n\r\n  function crowdsaleFailed(address _assetAddress)\r\n  public\r\n  view\r\n  returns(bool) {\r\n    return (now \u003E getCrowdsaleDeadline(_assetAddress) \u0026\u0026 !crowdsaleFinalized(_assetAddress));\r\n  }\r\n\r\n\r\n  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n  //                                        Asset Manager and Operator\r\n  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n\r\n  function getAssetManager(address _assetAddress)\r\n  public\r\n  view\r\n  returns(address) {\r\n    address managerAddress = database.addressStorage(keccak256(abi.encodePacked(\u0022asset.manager\u0022, _assetAddress)));\r\n    return managerAddress;\r\n  }\r\n\r\n  function getAssetManagerFee(address _assetAddress)\r\n  public\r\n  view\r\n  returns(uint) {\r\n    uint managerFee = database.uintStorage(keccak256(abi.encodePacked(\u0022asset.managerTokens\u0022, _assetAddress)));\r\n    return managerFee;\r\n  }\r\n\r\n  function getAssetPlatformFee(address _assetAddress)\r\n  public\r\n  view\r\n  returns(uint) {\r\n    uint platformFee = database.uintStorage(keccak256(abi.encodePacked(\u0022asset.platformTokens\u0022, _assetAddress)));\r\n    return platformFee;\r\n  }\r\n\r\n  function getAssetManagerEscrowID(address _assetAddress, address _manager)\r\n  public\r\n  pure\r\n  returns(bytes32) {\r\n    bytes32 managerEscrowID = keccak256(abi.encodePacked(_assetAddress, _manager));\r\n    return managerEscrowID;\r\n  }\r\n\r\n  function getAssetManagerEscrow(bytes32 _managerEscrowID)\r\n  public\r\n  view\r\n  returns (uint) {\r\n    return database.uintStorage(keccak256(abi.encodePacked(\u0022asset.escrow\u0022, _managerEscrowID)));\r\n  }\r\n\r\n  function getAssetManagerEscrowRemaining(bytes32 _managerEscrowID)\r\n  public\r\n  view\r\n  returns(uint) {\r\n    uint redeemed = getAssetManagerEscrowRedeemed(_managerEscrowID);\r\n    uint escrow = getAssetManagerEscrow(_managerEscrowID);\r\n    return escrow.sub(redeemed);\r\n  }\r\n\r\n  function getAssetManagerEscrowRedeemed(bytes32 _managerEscrowID)\r\n  public\r\n  view\r\n  returns(uint) {\r\n    uint escrowRedeemed = database.uintStorage(keccak256(abi.encodePacked(\u0022asset.escrowRedeemed\u0022, _managerEscrowID)));\r\n    return escrowRedeemed;\r\n  }\r\n\r\n  function getAssetModelID(address _assetAddress)\r\n  public\r\n  view\r\n  returns(bytes32) {\r\n    bytes32 modelID = database.bytes32Storage(keccak256(abi.encodePacked(\u0022asset.modelID\u0022, _assetAddress)));\r\n    return modelID;\r\n  }\r\n\r\n  function checkAssetAcceptToken(bytes32 _modelID, address _tokenAddress)\r\n  external\r\n  view\r\n  returns(bool) {\r\n    return database.boolStorage(keccak256(abi.encodePacked(\u0022model.acceptsToken\u0022, _modelID, _tokenAddress)));\r\n  }\r\n\r\n  function checkAssetPayoutToken(bytes32 _modelID, address _tokenAddress)\r\n  external\r\n  view\r\n  returns(bool) {\r\n    return database.boolStorage(keccak256(abi.encodePacked(\u0022model.payoutToken\u0022, _modelID, _tokenAddress)));\r\n  }\r\n\r\n  function getAssetOperator(address _assetAddress)\r\n  public\r\n  view\r\n  returns(address) {\r\n    bytes32 modelID = getAssetModelID(_assetAddress);\r\n    address operatorAddress = getModelOperator(modelID);\r\n    return operatorAddress;\r\n  }\r\n\r\n  function generateOperatorID(string _operatorURI)\r\n  public\r\n  pure\r\n  returns(bytes32) {\r\n    bytes32 operatorID = keccak256(abi.encodePacked(\u0022operator.uri\u0022, _operatorURI));\r\n    return operatorID;\r\n  }\r\n\r\n  function getOperatorID(address _operatorAddress)\r\n  public\r\n  view\r\n  returns(bytes32) {\r\n    bytes32 operatorID = database.bytes32Storage(keccak256(abi.encodePacked(\u0022operator\u0022, _operatorAddress)));\r\n    return operatorID;\r\n  }\r\n\r\n  function getOperatorAddress(bytes32 _operatorID)\r\n  public\r\n  view\r\n  returns(address) {\r\n    address operatorAddress = database.addressStorage(keccak256(abi.encodePacked(\u0022operator\u0022, _operatorID)));\r\n    return operatorAddress;\r\n  }\r\n\r\n  function getOperatorIPFS(bytes32 _operatorID)\r\n  public\r\n  view\r\n  returns(string) {\r\n    return database.stringStorage(keccak256(abi.encodePacked(\u0022operator.ipfs\u0022, _operatorID)));\r\n  }\r\n\r\n  function generateModelID(string _modelURI, bytes32 _operatorID)\r\n  public\r\n  pure\r\n  returns(bytes32) {\r\n    bytes32 modelID = keccak256(abi.encodePacked(\u0027model.id\u0027, _operatorID, _modelURI));\r\n    return modelID;\r\n  }\r\n\r\n  function getModelOperator(bytes32 _modelID)\r\n  public\r\n  view\r\n  returns(address) {\r\n    address operatorAddress = database.addressStorage(keccak256(abi.encodePacked(\u0022model.operator\u0022, _modelID)));\r\n    return operatorAddress;\r\n  }\r\n\r\n  function getModelIPFS(bytes32 _modelID)\r\n  public\r\n  view\r\n  returns(string) {\r\n    return database.stringStorage(keccak256(abi.encodePacked(\u0022model.ipfs\u0022, _modelID)));\r\n  }\r\n\r\n  function getManagerAssetCount(address _manager)\r\n  public\r\n  view\r\n  returns(uint) {\r\n    return database.uintStorage(keccak256(abi.encodePacked(\u0022manager.assets\u0022, _manager)));\r\n  }\r\n\r\n  function getCollateralLevel(address _manager)\r\n  public\r\n  view\r\n  returns(uint) {\r\n    return database.uintStorage(keccak256(abi.encodePacked(\u0022collateral.base\u0022))).add(database.uintStorage(keccak256(abi.encodePacked(\u0022collateral.level\u0022, getManagerAssetCount(_manager)))));\r\n  }\r\n\r\n\r\n  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n  //                                        Platform and Contract State\r\n  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n//Platform functions\r\n  function getPlatformToken()\r\n  public\r\n  view\r\n  returns(address) {\r\n    address tokenAddress = database.addressStorage(keccak256(abi.encodePacked(\u0022platform.token\u0022)));\r\n    return tokenAddress;\r\n  }\r\n\r\n  function getPlatformTokenFactory()\r\n  public\r\n  view\r\n  returns(address) {\r\n    address factoryAddress = database.addressStorage(keccak256(abi.encodePacked(\u0022platform.tokenFactory\u0022)));\r\n    return factoryAddress;\r\n  }\r\n\r\n  function getPlatformFee()\r\n  public\r\n  view\r\n  returns(uint) {\r\n    uint fee = database.uintStorage(keccak256(abi.encodePacked(\u0022platform.fee\u0022)));\r\n    return fee;\r\n  }\r\n\r\n  function getPlatformPercentage()\r\n  public\r\n  view\r\n  returns(uint) {\r\n    uint percentage = database.uintStorage(keccak256(abi.encodePacked(\u0022platform.percentage\u0022)));\r\n    return percentage;\r\n  }\r\n\r\n  function getPlatformAssetsWallet()\r\n  public\r\n  view\r\n  returns(address) {\r\n    address walletAddress = database.addressStorage(keccak256(abi.encodePacked(\u0022platform.wallet.assets\u0022)));\r\n    return walletAddress;\r\n  }\r\n\r\n  function getPlatformFundsWallet()\r\n  public\r\n  view\r\n  returns(address) {\r\n    address walletAddress = database.addressStorage(keccak256(abi.encodePacked(\u0022platform.wallet.funds\u0022)));\r\n    return walletAddress;\r\n  }\r\n\r\n  function getContractAddress(string _contractName)\r\n  public\r\n  view\r\n  returns(address) {\r\n    address contractAddress = database.addressStorage(keccak256(abi.encodePacked(\u0022contract\u0022, _contractName)));\r\n    return contractAddress;\r\n  }\r\n\r\n  function contractPaused(address _contract)\r\n  public\r\n  view\r\n  returns(bool) {\r\n    bool status = database.boolStorage(keccak256(abi.encodePacked(\u0022paused\u0022, _contract)));\r\n    return status;\r\n  }\r\n\r\n  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n  //                                        Ownership\r\n  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n\r\n  function contractOwner(address _account)\r\n  public\r\n  view\r\n  returns(bool) {\r\n    bool status = database.boolStorage(keccak256(abi.encodePacked(\u0022owner\u0022, _account)));\r\n    return status;\r\n  }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022crowdsaleFinalized\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_contractName\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022getContractAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_modelID\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022getModelIPFS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getAssetFundingToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getAssetManager\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getCrowdsaleDeadline\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getPlatformPercentage\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getPlatformAssetsWallet\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getAssetROI\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_contract\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022contractPaused\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022getContract\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_functionString\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022getMethodID\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes4\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_modelURI\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_operatorID\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022generateModelID\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022crowdsalePaid\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_key\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022getAddr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_operatorURI\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022generateOperatorID\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022contractOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_operatorAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getOperatorID\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022crowdsaleFailed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_modelID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022checkAssetAcceptToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getAssetIPFS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getPlatformFee\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_manager\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getManagerAssetCount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getAssetManagerFee\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_operatorID\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022getOperatorIPFS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_managerEscrowID\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022getAssetManagerEscrow\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getCrowdsaleGoal\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_a\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_b\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022hashSB\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_modelID\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022getModelOperator\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_managerEscrowID\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022getAssetManagerEscrowRemaining\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getAssetOperator\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getPlatformToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_managerEscrowID\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022getAssetManagerEscrowRedeemed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_manager\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getAssetManagerEscrowID\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getPlatformFundsWallet\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_key\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022getUint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_modelID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022checkAssetPayoutToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getPlatformTokenFactory\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getAssetModelID\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_manager\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getCollateralLevel\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_operatorID\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022getOperatorAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getAssetPlatformFee\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_database\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"API","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000005fcebeb70b88e86dd880352684e775b0f4d57c71","Library":"","SwarmSource":"bzzr://d4e80e4a26b249c5933a85a09f5a5db4a52e3808070b66600e0d759aa5e02101"}]