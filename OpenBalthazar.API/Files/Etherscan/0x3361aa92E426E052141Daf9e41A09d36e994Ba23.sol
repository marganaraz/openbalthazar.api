[{"SourceCode":"pragma solidity ^0.5.11;\r\n\r\n\r\ncontract Ownable {\r\n  address payable public owner;\r\n\r\n\r\n  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n\r\n\r\n  constructor() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n\r\n\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n\r\n\r\n  function transferOwnership(address payable newOwner) public onlyOwner {\r\n    require(newOwner != address(0));\r\n    emit OwnershipTransferred(owner, newOwner);\r\n    owner = newOwner;\r\n  }\r\n\r\n}\r\n\r\ncontract Destructible is Ownable {\r\n\r\n  constructor() public payable { }\r\n\r\n\r\n  function destroy() onlyOwner public {\r\n    selfdestruct(owner);\r\n  }\r\n\r\n  function destroyAndSend(address payable _recipient) onlyOwner public {\r\n    selfdestruct(_recipient);\r\n  }\r\n}\r\n\r\ninterface Conference {\r\n\r\n    event AdminGranted(address indexed grantee);\r\n    event AdminRevoked(address indexed grantee);\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    event RegisterEvent(address addr, uint256 index);\r\n    event FinalizeEvent(uint256[] maps, uint256 payout, uint256 endedAt);\r\n    event WithdrawEvent(address addr, uint256 payout);\r\n    event CancelEvent(uint256 endedAt);\r\n    event ClearEvent(address addr, uint256 leftOver);\r\n    event UpdateParticipantLimit(uint256 limit);\r\n\r\n\r\n\r\n    function owner() view external returns (address);\r\n\r\n    function name() view external returns (string memory);\r\n    function deposit() view external returns (uint256);\r\n    function limitOfParticipants() view external returns (uint256);\r\n    function registered() view external returns (uint256);\r\n    function ended() view external returns (bool);\r\n    function cancelled() view external returns (bool);\r\n    function endedAt() view external returns (uint256);\r\n    function totalAttended() view external returns (uint256);\r\n    function coolingPeriod() view external returns (uint256);\r\n    function payoutAmount() view external returns (uint256);\r\n    function participants(address participant) view external returns (\r\n        uint256 index,\r\n        address payable addr,\r\n        bool paid\r\n    );\r\n    function participantsIndex(uint256) view external returns(address);\r\n\r\n\r\n    function transferOwnership(address payable newOwner) external;\r\n\r\n    function grant(address[] calldata newAdmins) external;\r\n    function revoke(address[] calldata oldAdmins) external;\r\n    function getAdmins() external view returns(address[] memory);\r\n    function numOfAdmins() external view returns(uint);\r\n    function isAdmin(address admin) external view returns(bool);\r\n\r\n\r\n    function register() external payable;\r\n    function withdraw() external;\r\n    function totalBalance() view external returns (uint256);\r\n    function isRegistered(address _addr) view external returns (bool);\r\n    function isAttended(address _addr) external view returns (bool);\r\n    function isPaid(address _addr) external view returns (bool);\r\n    function cancel() external;\r\n    function clear() external;\r\n    function setLimitOfParticipants(uint256 _limitOfParticipants) external;\r\n    function changeName(string calldata _name) external;\r\n    function changeDeposit(uint256 _deposit) external;\r\n    function finalize(uint256[] calldata _maps) external;\r\n    function tokenAddress() external view returns (address);\r\n}\r\n\r\ninterface DeployerInterface {\r\n    function deploy(\r\n        string calldata _name,\r\n        uint256 _deposit,\r\n        uint _limitOfParticipants,\r\n        uint _coolingPeriod,\r\n        address payable _ownerAddress,\r\n        address _tokenAddress\r\n    )external returns(Conference c);\r\n}\r\n\r\ncontract Deployer is Destructible {\r\n    DeployerInterface ethDeployer;\r\n    DeployerInterface erc20Deployer;\r\n\r\n    constructor(address _ethDeployer, address _erc20Deployer) public {\r\n        ethDeployer = DeployerInterface(_ethDeployer);\r\n        erc20Deployer = DeployerInterface(_erc20Deployer);\r\n    }\r\n\r\n    event NewParty(\r\n        address indexed deployedAddress,\r\n        address indexed deployer\r\n    );\r\n\r\n\r\n    function deploy(\r\n        string calldata _name,\r\n        uint256 _deposit,\r\n        uint _limitOfParticipants,\r\n        uint _coolingPeriod,\r\n        address _tokenAddress\r\n    ) external {\r\n        Conference c;\r\n        if(_tokenAddress != address(0)){\r\n            c = erc20Deployer.deploy(\r\n                _name,\r\n                _deposit,\r\n                _limitOfParticipants,\r\n                _coolingPeriod,\r\n                msg.sender,\r\n                _tokenAddress\r\n            );\r\n        }else{\r\n            c = ethDeployer.deploy(\r\n                _name,\r\n                _deposit,\r\n                _limitOfParticipants,\r\n                _coolingPeriod,\r\n                msg.sender,\r\n                address(0)\r\n            );\r\n        }\r\n        emit NewParty(address(c), msg.sender);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022destroy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_deposit\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_limitOfParticipants\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_coolingPeriod\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022deploy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_recipient\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022destroyAndSend\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_ethDeployer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_erc20Deployer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022deployedAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022deployer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022NewParty\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Deployer","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000008f577ba05062283e37c4957d23b57cce4d75e10a000000000000000000000000d93ee21e39d23933c599154ea070ac89d5b1de72","Library":"","SwarmSource":"bzzr://d7fc33cfb7df78865a8ddaf1f1bce4ff1240ccd812e9320d26fe7fd616c903d2"}]