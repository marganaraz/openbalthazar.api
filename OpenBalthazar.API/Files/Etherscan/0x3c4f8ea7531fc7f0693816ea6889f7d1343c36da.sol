[{"SourceCode":"pragma solidity ^0.4.24;\r\n\r\n// File: contracts/math/SafeMath.sol\r\n\r\n// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol\r\n\r\n// @title SafeMath: overflow/underflow checks\r\n// @notice Math operations with safety checks that throw on error\r\nlibrary SafeMath {\r\n\r\n  // @notice Multiplies two numbers, throws on overflow.\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n    uint256 c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  // @notice Integer division of two numbers, truncating the quotient.\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    // uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return a / b;\r\n  }\r\n\r\n  // @notice Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  // @notice Adds two numbers, throws on overflow.\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n\r\n  // @notice Returns fractional amount\r\n  function getFractionalAmount(uint256 _amount, uint256 _percentage)\r\n  internal\r\n  pure\r\n  returns (uint256) {\r\n    return div(mul(_amount, _percentage), 100);\r\n  }\r\n\r\n}\r\n\r\n// File: contracts/interfaces/ERC20.sol\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ninterface ERC20 {\r\n  function decimals() external view returns (uint8);\r\n\r\n  function totalSupply() external view returns (uint256);\r\n\r\n  function balanceOf(address _who) external view returns (uint256);\r\n\r\n  function allowance(address _owner, address _spender) external view returns (uint256);\r\n\r\n  function transfer(address _to, uint256 _value) external returns (bool);\r\n\r\n  function approve(address _spender, uint256 _value) external returns (bool);\r\n\r\n  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);\r\n\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n  event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n// File: contracts/interfaces/MinterInterface.sol\r\n\r\ninterface MinterInterface {\r\n  function cloneToken(string _uri, address _erc20Address) external returns (address asset);\r\n\r\n  function mintAssetTokens(address _assetAddress, address _receiver, uint256 _amount) external returns (bool);\r\n\r\n  function changeTokenController(address _assetAddress, address _newController) external returns (bool);\r\n}\r\n\r\n// File: contracts/interfaces/CrowdsaleReserveInterface.sol\r\n\r\ninterface CrowdsaleReserveInterface {\r\n  function issueETH(address _receiver, uint256 _amount) external returns (bool);\r\n  function receiveETH(address _payer) external payable returns (bool);\r\n  function refundETHAsset(address _asset, uint256 _amount) external returns (bool);\r\n  function issueERC20(address _receiver, uint256 _amount, address _tokenAddress) external returns (bool);\r\n  function requestERC20(address _payer, uint256 _amount, address _tokenAddress) external returns (bool);\r\n  function approveERC20(address _receiver, uint256 _amount, address _tokenAddress) external returns (bool);\r\n  function refundERC20Asset(address _asset, uint256 _amount, address _tokenAddress) external returns (bool);\r\n}\r\n\r\n// File: contracts/crowdsale/CrowdsaleETH.sol\r\n\r\ninterface Events {\r\n  function transaction(string _message, address _from, address _to, uint _amount, address _token)  external;\r\n  function asset(string _message, string _uri, address _assetAddress, address _manager);\r\n}\r\ninterface DB {\r\n  function addressStorage(bytes32 _key) external view returns (address);\r\n  function uintStorage(bytes32 _key) external view returns (uint);\r\n  function setUint(bytes32 _key, uint _value) external;\r\n  function deleteUint(bytes32 _key) external;\r\n  function setBool(bytes32 _key, bool _value) external;\r\n  function boolStorage(bytes32 _key) external view returns (bool);\r\n}\r\n\r\n// @title An asset crowdsale contract, which accepts Ether for funding.\r\n// @author Kyle Dewhurst \u0026 Peter Phillips, MyBit Foundation\r\n// @notice Starts a new crowdsale and returns asset dividend tokens for Wei received.\r\n// @dev The AssetManager\r\ncontract CrowdsaleETH {\r\n    using SafeMath for uint256;\r\n\r\n    DB private database;\r\n    Events private events;\r\n    MinterInterface private minter;\r\n    CrowdsaleReserveInterface private reserve;\r\n\r\n    // @notice Constructor: Initiates the database\r\n    // @param: The address for the database contract\r\n    constructor(address _database, address _events)\r\n    public {\r\n      database = DB(_database);\r\n      events = Events(_events);\r\n      minter = MinterInterface(database.addressStorage(keccak256(abi.encodePacked(\u0022contract\u0022, \u0022Minter\u0022))));\r\n      reserve = CrowdsaleReserveInterface(database.addressStorage(keccak256(abi.encodePacked(\u0022contract\u0022, \u0022CrowdsaleReserve\u0022))));\r\n    }\r\n\r\n\r\n    // @notice Investors can send Ether here to fund asset, receiving an equivalent number of asset-tokens.\r\n    // @param (bytes32) _assetAddress = The address of the asset which completed the crowdsale\r\n    function buyAssetOrderETH(address _assetAddress)\r\n    external\r\n    payable\r\n    requiresEther\r\n    validAsset(_assetAddress)\r\n    beforeDeadline(_assetAddress)\r\n    notFinalized(_assetAddress)\r\n    returns (bool) {\r\n      uint fundingRemaining = database.uintStorage(keccak256(abi.encodePacked(\u0022crowdsale.remaining\u0022, _assetAddress)));\r\n      uint amount; //The number of tokens that will be minted\r\n      if (msg.value \u003C fundingRemaining) {\r\n        amount = msg.value.mul(100).div(uint(100).add(database.uintStorage(keccak256(abi.encodePacked(\u0022platform.fee\u0022)))));\r\n        database.setUint(keccak256(abi.encodePacked(\u0022crowdsale.remaining\u0022, _assetAddress)), fundingRemaining.sub(msg.value));\r\n        //Mint tokens equal to the msg.value\r\n        require(minter.mintAssetTokens(_assetAddress, msg.sender, amount), \u0022Investor minting failed\u0022);\r\n        reserve.receiveETH.value(msg.value)(msg.sender);\r\n      } else {\r\n        amount = fundingRemaining.mul(100).div(uint(100).add(database.uintStorage(keccak256(abi.encodePacked(\u0022platform.fee\u0022)))));\r\n        //Funding complete, finalize crowdsale\r\n        database.setBool(keccak256(abi.encodePacked(\u0022crowdsale.finalized\u0022, _assetAddress)), true);\r\n        database.deleteUint(keccak256(abi.encodePacked(\u0022crowdsale.remaining\u0022, _assetAddress)));\r\n        //Since investor paid equal to or over the funding remaining, just mint for tokensRemaining\r\n        require(minter.mintAssetTokens(_assetAddress, msg.sender, amount), \u0022Investor minting failed\u0022);\r\n        reserve.receiveETH.value(fundingRemaining)(msg.sender);\r\n        //Return leftover WEI after cost of tokens calculated and subtracted from msg.value to msg.sender\r\n        msg.sender.transfer(msg.value.sub(fundingRemaining));\r\n        events.asset(\u0027Crowdsale finalized\u0027, \u0027\u0027, _assetAddress, msg.sender);\r\n      }\r\n      events.transaction(\u0027Asset purchased\u0027, address(this), msg.sender, amount, _assetAddress);\r\n\r\n      return true;\r\n    }\r\n\r\n    // @notice This is called once funding has succeeded. Sends Ether to a distribution contract where receiver \u0026 assetManager can withdraw\r\n    // @dev The contract manager needs to know  the address PlatformDistribution contract\r\n    // @param (bytes32) _assetAddress = The address of the asset which completed the crowdsale\r\n    function payoutETH(address _assetAddress)\r\n    external\r\n    whenNotPaused\r\n    finalized(_assetAddress)\r\n    notPaid(_assetAddress)\r\n    returns (bool) {\r\n      //Set paid to true\r\n      database.setBool(keccak256(abi.encodePacked(\u0022crowdsale.paid\u0022, _assetAddress)), true);\r\n      //Setup token\r\n      //Mint tokens for the asset manager and platform \u002B finish minting\r\n      address platformAssetsWallet = database.addressStorage(keccak256(abi.encodePacked(\u0022platform.wallet.assets\u0022)));\r\n      require(platformAssetsWallet != address(0), \u0022Platform assets wallet not set\u0022);\r\n      require(minter.mintAssetTokens(_assetAddress, database.addressStorage(keccak256(abi.encodePacked(\u0022contract\u0022, \u0022AssetManagerFunds\u0022))), database.uintStorage(keccak256(abi.encodePacked(\u0022asset.managerTokens\u0022, _assetAddress)))), \u0022Manager minting failed\u0022);\r\n      require(minter.mintAssetTokens(_assetAddress, platformAssetsWallet, database.uintStorage(keccak256(abi.encodePacked(\u0022asset.platformTokens\u0022, _assetAddress)))), \u0022Platform minting failed\u0022);\r\n      //Get the addresses for the receiver and platform\r\n      address receiver = database.addressStorage(keccak256(abi.encodePacked(\u0022asset.manager\u0022, _assetAddress)));\r\n      address platformFundsWallet = database.addressStorage(keccak256(abi.encodePacked(\u0022platform.wallet.funds\u0022)));\r\n      require(receiver != address(0) \u0026\u0026 platformFundsWallet != address(0), \u0022Receiver or platform wallet not set\u0022);\r\n      //Calculate amounts for platform and receiver\r\n      uint amount = database.uintStorage(keccak256(abi.encodePacked(\u0022crowdsale.goal\u0022, _assetAddress)));\r\n      uint platformFee = amount.getFractionalAmount(database.uintStorage(keccak256(abi.encodePacked(\u0022platform.fee\u0022))));\r\n      //Transfer funds to receiver and platform\r\n      require(reserve.issueETH(platformFundsWallet, platformFee), \u0027Platform funds not paid\u0027);\r\n      require(reserve.issueETH(receiver, amount), \u0027Operator funds not paid\u0027);\r\n      //Delete crowdsale start time\r\n      database.deleteUint(keccak256(abi.encodePacked(\u0022crowdsale.start\u0022, _assetAddress)));\r\n      //Increase asset count for manager\r\n      address manager = database.addressStorage(keccak256(abi.encodePacked(\u0022asset.manager\u0022, _assetAddress)));\r\n      database.setUint(keccak256(abi.encodePacked(\u0022manager.assets\u0022, manager)), database.uintStorage(keccak256(abi.encodePacked(\u0022manager.assets\u0022, manager))).add(1));\r\n      //Emit event\r\n      events.transaction(\u0027Asset payout\u0027, _assetAddress, receiver, amount, address(0));\r\n      return true;\r\n    }\r\n\r\n    function cancel(address _assetAddress)\r\n    external\r\n    whenNotPaused\r\n    validAsset(_assetAddress)\r\n    beforeDeadline(_assetAddress)\r\n    notFinalized(_assetAddress)\r\n    returns (bool){\r\n      require(msg.sender == database.addressStorage(keccak256(abi.encodePacked(\u0022asset.manager\u0022, _assetAddress))));\r\n      database.setUint(keccak256(abi.encodePacked(\u0022crowdsale.deadline\u0022, _assetAddress)), 1);\r\n      refund(_assetAddress);\r\n    }\r\n\r\n    // @notice Contributors can retrieve their funds here if crowdsale has paased deadline and not reached its goal\r\n    // @param (bytes32) _assetAddress = The address of the asset which completed the crowdsale\r\n    function refund(address _assetAddress)\r\n    public\r\n    whenNotPaused\r\n    validAsset(_assetAddress)\r\n    afterDeadline(_assetAddress)\r\n    notFinalized(_assetAddress)\r\n    returns (bool) {\r\n      require(database.uintStorage(keccak256(abi.encodePacked(\u0022crowdsale.deadline\u0022, _assetAddress))) != 0);\r\n      database.deleteUint(keccak256(abi.encodePacked(\u0022crowdsale.deadline\u0022, _assetAddress)));\r\n      ERC20 assetToken = ERC20(_assetAddress);\r\n      uint refundValue = assetToken.totalSupply().mul(uint(100).add(database.uintStorage(keccak256(abi.encodePacked(\u0022platform.fee\u0022))))).div(100); //total supply plus platform fees\r\n      reserve.refundETHAsset(_assetAddress, refundValue);\r\n      return true;\r\n    }\r\n\r\n    // @notice platform owners can recover tokens here\r\n    function recoverTokens(address _erc20Token)\r\n    onlyOwner\r\n    external {\r\n      ERC20 thisToken = ERC20(_erc20Token);\r\n      uint contractBalance = thisToken.balanceOf(address(this));\r\n      thisToken.transfer(msg.sender, contractBalance);\r\n    }\r\n\r\n    // @notice platform owners can destroy contract here\r\n    function destroy()\r\n    onlyOwner\r\n    external {\r\n      events.transaction(\u0027CrowdsaleETH destroyed\u0027, address(this), msg.sender, address(this).balance, address(0));\r\n      selfdestruct(msg.sender);\r\n    }\r\n\r\n    //------------------------------------------------------------------------------------------------------------------\r\n    //                                            Modifiers\r\n    //------------------------------------------------------------------------------------------------------------------\r\n\r\n\r\n    // @notice Requires that Ether is sent with the transaction\r\n    modifier requiresEther() {\r\n      require(msg.value \u003E 0);\r\n      _;\r\n    }\r\n\r\n    // @notice Sender must be a registered owner\r\n    modifier onlyOwner {\r\n      require(database.boolStorage(keccak256(abi.encodePacked(\u0022owner\u0022, msg.sender))), \u0022Not owner\u0022);\r\n      _;\r\n    }\r\n\r\n    // @notice function won\u0027t run if owners have paused this contract\r\n    modifier whenNotPaused {\r\n      require(!database.boolStorage(keccak256(abi.encodePacked(\u0022paused\u0022, address(this)))), \u0022Contract paused\u0022);\r\n      _;\r\n    }\r\n\r\n    // @notice reverts if the asset does not have a token address set in the database\r\n    modifier validAsset(address _assetAddress) {\r\n      require(database.addressStorage(keccak256(abi.encodePacked(\u0022asset.manager\u0022, _assetAddress))) != address(0), \u0022Invalid asset\u0022);\r\n      _;\r\n    }\r\n\r\n    // @notice reverts if the funding deadline has not passed\r\n    modifier beforeDeadline(address _assetAddress) {\r\n      require(now \u003C database.uintStorage(keccak256(abi.encodePacked(\u0022crowdsale.deadline\u0022, _assetAddress))), \u0022Before deadline\u0022);\r\n      _;\r\n    }\r\n\r\n    // @notice reverts if the funding deadline has already past or crowsale has not started\r\n    modifier betweenDeadlines(address _assetAddress) {\r\n      require(now \u003C= database.uintStorage(keccak256(abi.encodePacked(\u0022crowdsale.deadline\u0022, _assetAddress))), \u0022Past deadline\u0022);\r\n      require(now \u003E= database.uintStorage(keccak256(abi.encodePacked(\u0022crowdsale.start\u0022, _assetAddress))), \u0022Before start time\u0022);\r\n      _;\r\n    }\r\n\r\n    // @notice reverts if the funding deadline has already past\r\n    modifier afterDeadline(address _assetAddress) {\r\n      require(now \u003E database.uintStorage(keccak256(abi.encodePacked(\u0022crowdsale.deadline\u0022, _assetAddress))), \u0022Before deadline\u0022);\r\n      _;\r\n    }\r\n\r\n    // @notice returns true if crowdsale is finshed\r\n    modifier finalized(address _assetAddress) {\r\n      require( database.boolStorage(keccak256(abi.encodePacked(\u0022crowdsale.finalized\u0022, _assetAddress))), \u0022Crowdsale not finalized\u0022);\r\n      _;\r\n    }\r\n\r\n    // @notice returns true if crowdsale is not finshed\r\n    modifier notFinalized(address _assetAddress) {\r\n      require( !database.boolStorage(keccak256(abi.encodePacked(\u0022crowdsale.finalized\u0022, _assetAddress))), \u0022Crowdsale finalized\u0022);\r\n      _;\r\n    }\r\n\r\n    // @notice returns true if crowdsale has not paid out\r\n    modifier notPaid(address _assetAddress) {\r\n      require( !database.boolStorage(keccak256(abi.encodePacked(\u0022crowdsale.paid\u0022, _assetAddress))), \u0022Crowdsale had paid out\u0022);\r\n      _;\r\n    }\r\n\r\n  }","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_erc20Token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022recoverTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022cancel\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022destroy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022buyAssetOrderETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022payoutETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022refund\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_database\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_events\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"CrowdsaleETH","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000005fcebeb70b88e86dd880352684e775b0f4d57c71000000000000000000000000eb6533f29a54c2c18bb2ce2a100de717692a518f","Library":"","SwarmSource":"bzzr://788ee6f791f90161e48b07819763ecc45b8525aa15c8aefbd516e5e66c1da6f7"}]