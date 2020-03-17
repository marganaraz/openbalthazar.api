[{"SourceCode":"pragma solidity ^0.5.8;\r\n\r\n/*\r\n * Ownable\r\n *\r\n * Base contract with an owner.\r\n * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.\r\n */\r\n\r\ncontract Ownable {\r\n    address public owner;\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    modifier onlyOwner() {\r\n        require(\r\n            msg.sender == owner,\r\n            \u0022The function can only be called by the owner\u0022\r\n        );\r\n        _;\r\n    }\r\n\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        if (newOwner != address(0)) {\r\n            owner = newOwner;\r\n        }\r\n    }\r\n}\r\n\r\ncontract DepositLockerInterface {\r\n    function slash(address _depositorToBeSlashed) public;\r\n\r\n}\r\n\r\n/*\r\n  The DepositLocker contract locks the deposits for all of the winning\r\n  participants of the auction.\r\n\r\n  When the auction is running, the auction contract registers participants that\r\n  have successfully bid with the registerDepositor function. The DepositLocker\r\n  contracts keeps track of the number of participants and also keeps track if a\r\n  participant address can withdraw the deposit.\r\n\r\n  All of the participants have to pay the same eth amount when the auction ends.\r\n  The auction contract will deposit the sum of all amounts with a call to\r\n  deposit.\r\n\r\n*/\r\n\r\ncontract DepositLocker is DepositLockerInterface, Ownable {\r\n    bool public initialized = false;\r\n    bool public deposited = false;\r\n\r\n    /* We maintain two special addresses:\r\n       - the slasher, that is allowed to call the slash function\r\n       - the depositorsProxy that registers depositors and deposits a value for\r\n         all of the registered depositors with the deposit function. In our case\r\n         this will be the auction contract.\r\n    */\r\n\r\n    address public slasher;\r\n    address public depositorsProxy;\r\n    uint public releaseTimestamp;\r\n\r\n    mapping(address =\u003E bool) public canWithdraw;\r\n    uint numberOfDepositors = 0;\r\n    uint valuePerDepositor;\r\n\r\n    event DepositorRegistered(\r\n        address depositorAddress,\r\n        uint numberOfDepositors\r\n    );\r\n    event Deposit(\r\n        uint totalValue,\r\n        uint valuePerDepositor,\r\n        uint numberOfDepositors\r\n    );\r\n    event Withdraw(address withdrawer, uint value);\r\n    event Slash(address slashedDepositor, uint slashedValue);\r\n\r\n    modifier isInitialised() {\r\n        require(initialized, \u0022The contract was not initialized.\u0022);\r\n        _;\r\n    }\r\n\r\n    modifier isDeposited() {\r\n        require(deposited, \u0022no deposits yet\u0022);\r\n        _;\r\n    }\r\n\r\n    modifier isNotDeposited() {\r\n        require(!deposited, \u0022already deposited\u0022);\r\n        _;\r\n    }\r\n\r\n    modifier onlyDepositorsProxy() {\r\n        require(\r\n            msg.sender == depositorsProxy,\r\n            \u0022Only the depositorsProxy can call this function.\u0022\r\n        );\r\n        _;\r\n    }\r\n\r\n    function() external {}\r\n\r\n    function init(\r\n        uint _releaseTimestamp,\r\n        address _slasher,\r\n        address _depositorsProxy\r\n    ) external onlyOwner {\r\n        require(!initialized, \u0022The contract is already initialised.\u0022);\r\n        require(\r\n            _releaseTimestamp \u003E now,\r\n            \u0022The release timestamp must be in the future\u0022\r\n        );\r\n\r\n        releaseTimestamp = _releaseTimestamp;\r\n        slasher = _slasher;\r\n        depositorsProxy = _depositorsProxy;\r\n        initialized = true;\r\n        owner = address(0);\r\n    }\r\n\r\n    function registerDepositor(address _depositor)\r\n        public\r\n        isInitialised\r\n        isNotDeposited\r\n        onlyDepositorsProxy\r\n    {\r\n        require(\r\n            canWithdraw[_depositor] == false,\r\n            \u0022can only register Depositor once\u0022\r\n        );\r\n        canWithdraw[_depositor] = true;\r\n        numberOfDepositors \u002B= 1;\r\n        emit DepositorRegistered(_depositor, numberOfDepositors);\r\n    }\r\n\r\n    function deposit(uint _valuePerDepositor)\r\n        public\r\n        payable\r\n        isInitialised\r\n        isNotDeposited\r\n        onlyDepositorsProxy\r\n    {\r\n        require(numberOfDepositors \u003E 0, \u0022no depositors\u0022);\r\n        require(_valuePerDepositor \u003E 0, \u0022_valuePerDepositor must be positive\u0022);\r\n\r\n        uint depositAmount = numberOfDepositors * _valuePerDepositor;\r\n        require(\r\n            _valuePerDepositor == depositAmount / numberOfDepositors,\r\n            \u0022Overflow in depositAmount calculation\u0022\r\n        );\r\n        require(\r\n            msg.value == depositAmount,\r\n            \u0022the deposit does not match the required value\u0022\r\n        );\r\n\r\n        valuePerDepositor = _valuePerDepositor;\r\n        deposited = true;\r\n        emit Deposit(msg.value, valuePerDepositor, numberOfDepositors);\r\n    }\r\n\r\n    function withdraw() public isInitialised isDeposited {\r\n        require(\r\n            now \u003E= releaseTimestamp,\r\n            \u0022The deposit cannot be withdrawn yet.\u0022\r\n        );\r\n        require(canWithdraw[msg.sender], \u0022cannot withdraw from sender\u0022);\r\n\r\n        canWithdraw[msg.sender] = false;\r\n        msg.sender.transfer(valuePerDepositor);\r\n        emit Withdraw(msg.sender, valuePerDepositor);\r\n    }\r\n\r\n    function slash(address _depositorToBeSlashed)\r\n        public\r\n        isInitialised\r\n        isDeposited\r\n    {\r\n        require(\r\n            msg.sender == slasher,\r\n            \u0022Only the slasher can call this function.\u0022\r\n        );\r\n        require(canWithdraw[_depositorToBeSlashed], \u0022cannot slash address\u0022);\r\n        canWithdraw[_depositorToBeSlashed] = false;\r\n        address(0).transfer(valuePerDepositor);\r\n        emit Slash(_depositorToBeSlashed, valuePerDepositor);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022releaseTimestamp\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022initialized\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022canWithdraw\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_depositor\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022registerDepositor\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_releaseTimestamp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_slasher\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_depositorsProxy\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022init\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022slasher\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_valuePerDepositor\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022deposit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_depositorToBeSlashed\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022slash\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022depositorsProxy\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022deposited\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022depositorAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022numberOfDepositors\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022DepositorRegistered\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022totalValue\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022valuePerDepositor\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022numberOfDepositors\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Deposit\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022withdrawer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Withdraw\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022slashedDepositor\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022slashedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Slash\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"DepositLocker","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://d2eb26eae0eb7e2c713617d41899258d56d8542f3537323f4314664b28918fe8"}]