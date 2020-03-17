[{"SourceCode":"pragma solidity \u003E=0.5.0 \u003C0.6.0;\r\npragma experimental ABIEncoderV2;\r\n\r\ncontract HashTimeLock {\r\n  mapping(bytes32 =\u003E LockContract) public contracts;\r\n\r\n  enum SwapStatus { INVALID, ACTIVE, REFUNDED, WITHDRAWN, EXPIRED }\r\n\r\n  struct LockContract {\r\n    uint256 inputAmount;\r\n    uint256 outputAmount;\r\n    uint256 expiration;\r\n    bytes32 hashLock;\r\n    SwapStatus status;\r\n    address payable sender;\r\n    address payable receiver;\r\n    string outputNetwork;\r\n    string outputAddress;\r\n  }\r\n\r\n  event Withdraw(\r\n    bytes32 indexed id,\r\n    bytes32 secret,\r\n    bytes32 hashLock,\r\n    address indexed sender,\r\n    address indexed receiver\r\n  );\r\n\r\n  event Refund(\r\n    bytes32 indexed id,\r\n    bytes32 hashLock,\r\n    address indexed sender,\r\n    address indexed receiver\r\n  );\r\n\r\n  event NewContract(\r\n    uint256 inputAmount,\r\n    uint256 outputAmount,\r\n    uint256 expiration,\r\n    bytes32 indexed id,\r\n    bytes32 hashLock,\r\n    address indexed sender,\r\n    address indexed receiver,\r\n    string outputNetwork,\r\n    string outputAddress\r\n  );\r\n\r\n  modifier withdrawable(bytes32 id, bytes32 secret) {\r\n    LockContract memory tempContract = contracts[id];\r\n    require(tempContract.status == SwapStatus.ACTIVE, \u0027SWAP_NOT_ACTIVE\u0027);\r\n    require(tempContract.expiration \u003E block.timestamp, \u0027INVALID_TIME\u0027);\r\n    require(\r\n      tempContract.hashLock == sha256(abi.encodePacked(secret)),\r\n      \u0027INVALID_SECRET\u0027\r\n    );\r\n    _;\r\n  }\r\n\r\n  modifier refundable(bytes32 id) {\r\n    LockContract memory tempContract = contracts[id];\r\n    require(tempContract.status == SwapStatus.ACTIVE, \u0027SWAP_NOT_ACTIVE\u0027);\r\n    require(tempContract.expiration \u003C= block.timestamp, \u0027INVALID_TIME\u0027);\r\n    require(tempContract.sender == msg.sender, \u0027INVALID_SENDER\u0027);\r\n    _;\r\n  }\r\n\r\n  function newContract(\r\n    uint256 outputAmount,\r\n    uint256 expiration,\r\n    bytes32 hashLock,\r\n    address payable receiver,\r\n    string memory outputNetwork,\r\n    string memory outputAddress\r\n  ) public payable {\r\n    address payable sender = msg.sender;\r\n    uint256 inputAmount = msg.value;\r\n\r\n    require(expiration \u003E block.timestamp, \u0027INVALID_TIME\u0027);\r\n\r\n    require(inputAmount \u003E 0, \u0027INVALID_AMOUNT\u0027);\r\n\r\n    bytes32 id = sha256(\r\n      abi.encodePacked(sender, receiver, inputAmount, hashLock, expiration)\r\n    );\r\n\r\n    contracts[id] = LockContract(\r\n      inputAmount,\r\n      outputAmount,\r\n      expiration,\r\n      hashLock,\r\n      SwapStatus.ACTIVE,\r\n      sender,\r\n      receiver,\r\n      outputNetwork,\r\n      outputAddress\r\n    );\r\n\r\n    emit NewContract(\r\n      inputAmount,\r\n      outputAmount,\r\n      expiration,\r\n      id,\r\n      hashLock,\r\n      sender,\r\n      receiver,\r\n      outputNetwork,\r\n      outputAddress\r\n    );\r\n  }\r\n\r\n  function withdraw(bytes32 id, bytes32 secret)\r\n    public\r\n    withdrawable(id, secret)\r\n    returns (bool)\r\n  {\r\n    LockContract storage c = contracts[id];\r\n    c.status = SwapStatus.WITHDRAWN;\r\n    c.receiver.transfer(c.inputAmount);\r\n    emit Withdraw(id, secret, c.hashLock, c.sender, c.receiver);\r\n    return true;\r\n  }\r\n\r\n  function refund(bytes32 id) external refundable(id) returns (bool) {\r\n    LockContract storage c = contracts[id];\r\n    c.status = SwapStatus.REFUNDED;\r\n    c.sender.transfer(c.inputAmount);\r\n    emit Refund(id, c.hashLock, c.sender, c.receiver);\r\n    return true;\r\n  }\r\n\r\n  function getContract(bytes32 id) public view returns (LockContract memory) {\r\n    LockContract memory c = contracts[id];\r\n    return c;\r\n  }\r\n\r\n  function contractExists(bytes32 id) public view returns (bool) {\r\n    return contracts[id].status != SwapStatus.INVALID;\r\n  }\r\n\r\n  function getStatus(bytes32[] memory ids)\r\n    public\r\n    view\r\n    returns (uint8[] memory)\r\n  {\r\n    uint8[] memory result = new uint8[](ids.length);\r\n\r\n    for (uint256 index = 0; index \u003C ids.length; index\u002B\u002B) {\r\n      result[index] = getStatus(ids[index]);\r\n    }\r\n\r\n    return result;\r\n  }\r\n\r\n  function getStatus(bytes32 id) public view returns (uint8 result) {\r\n    LockContract memory tempContract = contracts[id];\r\n\r\n    if (\r\n      tempContract.status == SwapStatus.ACTIVE \u0026\u0026\r\n      tempContract.expiration \u003C block.timestamp\r\n    ) {\r\n      result = uint8(SwapStatus.EXPIRED);\r\n    } else {\r\n      result = uint8(tempContract.status);\r\n    }\r\n  }\r\n}","ABI":"[{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022inputAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022outputAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022expiration\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022hashLock\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022outputNetwork\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022outputAddress\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022NewContract\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022hashLock\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022receiver\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Refund\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022secret\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022hashLock\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022receiver\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Withdraw\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022contractExists\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022contracts\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022inputAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022outputAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022expiration\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022hashLock\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022enum HashTimeLock.SwapStatus\u0022,\u0022name\u0022:\u0022status\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022outputNetwork\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022outputAddress\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022getContract\u0022,\u0022outputs\u0022:[{\u0022components\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022inputAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022outputAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022expiration\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022hashLock\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022enum HashTimeLock.SwapStatus\u0022,\u0022name\u0022:\u0022status\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022outputNetwork\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022outputAddress\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022internalType\u0022:\u0022struct HashTimeLock.LockContract\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022tuple\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32[]\u0022,\u0022name\u0022:\u0022ids\u0022,\u0022type\u0022:\u0022bytes32[]\u0022}],\u0022name\u0022:\u0022getStatus\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022getStatus\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022result\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022outputAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022expiration\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022hashLock\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022outputNetwork\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022outputAddress\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022newContract\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022refund\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022secret\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"HashTimeLock","CompilerVersion":"v0.5.16\u002Bcommit.9c3226ce","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://fa8ae950ed507bcfa88278a3b339331838f330d133c9362110dd8c89662608cc"}]