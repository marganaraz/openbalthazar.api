[{"SourceCode":"// File: contracts/ERC20Interface.sol\r\n\r\npragma solidity 0.4.18;\r\n\r\n\r\n// https://github.com/ethereum/EIPs/issues/20\r\ninterface ERC20 {\r\n    function totalSupply() public view returns (uint supply);\r\n    function balanceOf(address _owner) public view returns (uint balance);\r\n    function transfer(address _to, uint _value) public returns (bool success);\r\n    function transferFrom(address _from, address _to, uint _value) public returns (bool success);\r\n    function approve(address _spender, uint _value) public returns (bool success);\r\n    function allowance(address _owner, address _spender) public view returns (uint remaining);\r\n    function decimals() public view returns(uint digits);\r\n    event Approval(address indexed _owner, address indexed _spender, uint _value);\r\n}\r\n\r\n// File: contracts/PermissionGroups.sol\r\n\r\npragma solidity 0.4.18;\r\n\r\n\r\ncontract PermissionGroups {\r\n\r\n    address public admin;\r\n    address public pendingAdmin;\r\n    mapping(address=\u003Ebool) internal operators;\r\n    mapping(address=\u003Ebool) internal alerters;\r\n    address[] internal operatorsGroup;\r\n    address[] internal alertersGroup;\r\n    uint constant internal MAX_GROUP_SIZE = 50;\r\n\r\n    function PermissionGroups() public {\r\n        admin = msg.sender;\r\n    }\r\n\r\n    modifier onlyAdmin() {\r\n        require(msg.sender == admin);\r\n        _;\r\n    }\r\n\r\n    modifier onlyOperator() {\r\n        require(operators[msg.sender]);\r\n        _;\r\n    }\r\n\r\n    modifier onlyAlerter() {\r\n        require(alerters[msg.sender]);\r\n        _;\r\n    }\r\n\r\n    function getOperators () external view returns(address[]) {\r\n        return operatorsGroup;\r\n    }\r\n\r\n    function getAlerters () external view returns(address[]) {\r\n        return alertersGroup;\r\n    }\r\n\r\n    event TransferAdminPending(address pendingAdmin);\r\n\r\n    /**\r\n     * @dev Allows the current admin to set the pendingAdmin address.\r\n     * @param newAdmin The address to transfer ownership to.\r\n     */\r\n    function transferAdmin(address newAdmin) public onlyAdmin {\r\n        require(newAdmin != address(0));\r\n        TransferAdminPending(pendingAdmin);\r\n        pendingAdmin = newAdmin;\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current admin to set the admin in one tx. Useful initial deployment.\r\n     * @param newAdmin The address to transfer ownership to.\r\n     */\r\n    function transferAdminQuickly(address newAdmin) public onlyAdmin {\r\n        require(newAdmin != address(0));\r\n        TransferAdminPending(newAdmin);\r\n        AdminClaimed(newAdmin, admin);\r\n        admin = newAdmin;\r\n    }\r\n\r\n    event AdminClaimed( address newAdmin, address previousAdmin);\r\n\r\n    /**\r\n     * @dev Allows the pendingAdmin address to finalize the change admin process.\r\n     */\r\n    function claimAdmin() public {\r\n        require(pendingAdmin == msg.sender);\r\n        AdminClaimed(pendingAdmin, admin);\r\n        admin = pendingAdmin;\r\n        pendingAdmin = address(0);\r\n    }\r\n\r\n    event AlerterAdded (address newAlerter, bool isAdd);\r\n\r\n    function addAlerter(address newAlerter) public onlyAdmin {\r\n        require(!alerters[newAlerter]); // prevent duplicates.\r\n        require(alertersGroup.length \u003C MAX_GROUP_SIZE);\r\n\r\n        AlerterAdded(newAlerter, true);\r\n        alerters[newAlerter] = true;\r\n        alertersGroup.push(newAlerter);\r\n    }\r\n\r\n    function removeAlerter (address alerter) public onlyAdmin {\r\n        require(alerters[alerter]);\r\n        alerters[alerter] = false;\r\n\r\n        for (uint i = 0; i \u003C alertersGroup.length; \u002B\u002Bi) {\r\n            if (alertersGroup[i] == alerter) {\r\n                alertersGroup[i] = alertersGroup[alertersGroup.length - 1];\r\n                alertersGroup.length--;\r\n                AlerterAdded(alerter, false);\r\n                break;\r\n            }\r\n        }\r\n    }\r\n\r\n    event OperatorAdded(address newOperator, bool isAdd);\r\n\r\n    function addOperator(address newOperator) public onlyAdmin {\r\n        require(!operators[newOperator]); // prevent duplicates.\r\n        require(operatorsGroup.length \u003C MAX_GROUP_SIZE);\r\n\r\n        OperatorAdded(newOperator, true);\r\n        operators[newOperator] = true;\r\n        operatorsGroup.push(newOperator);\r\n    }\r\n\r\n    function removeOperator (address operator) public onlyAdmin {\r\n        require(operators[operator]);\r\n        operators[operator] = false;\r\n\r\n        for (uint i = 0; i \u003C operatorsGroup.length; \u002B\u002Bi) {\r\n            if (operatorsGroup[i] == operator) {\r\n                operatorsGroup[i] = operatorsGroup[operatorsGroup.length - 1];\r\n                operatorsGroup.length -= 1;\r\n                OperatorAdded(operator, false);\r\n                break;\r\n            }\r\n        }\r\n    }\r\n}\r\n\r\n// File: contracts/Withdrawable.sol\r\n\r\npragma solidity 0.4.18;\r\n\r\n\r\n\r\n\r\n/**\r\n * @title Contracts that should be able to recover tokens or ethers\r\n * @author Ilan Doron\r\n * @dev This allows to recover any tokens or Ethers received in a contract.\r\n * This will prevent any accidental loss of tokens.\r\n */\r\ncontract Withdrawable is PermissionGroups {\r\n\r\n    event TokenWithdraw(ERC20 token, uint amount, address sendTo);\r\n\r\n    /**\r\n     * @dev Withdraw all ERC20 compatible tokens\r\n     * @param token ERC20 The address of the token contract\r\n     */\r\n    function withdrawToken(ERC20 token, uint amount, address sendTo) external onlyAdmin {\r\n        require(token.transfer(sendTo, amount));\r\n        TokenWithdraw(token, amount, sendTo);\r\n    }\r\n\r\n    event EtherWithdraw(uint amount, address sendTo);\r\n\r\n    /**\r\n     * @dev Withdraw Ethers\r\n     */\r\n    function withdrawEther(uint amount, address sendTo) external onlyAdmin {\r\n        sendTo.transfer(amount);\r\n        EtherWithdraw(amount, sendTo);\r\n    }\r\n}\r\n\r\n// File: contracts/wrappers/SetStepFunctionWrapper.sol\r\n\r\npragma solidity ^0.4.18;\r\n\r\n\r\n\r\n\r\ninterface SetStepFunctionInterface {\r\n    function setImbalanceStepFunction(\r\n        ERC20 token,\r\n        int[] xBuy,\r\n        int[] yBuy,\r\n        int[] xSell,\r\n        int[] ySell\r\n    ) public;\r\n}\r\n\r\ncontract SetStepFunctionWrapper2 is Withdrawable {\r\n    SetStepFunctionInterface public rateContract;\r\n    function SetStepFunctionWrapper(address admin, address operator) public {\r\n        addOperator(operator);\r\n        transferAdminQuickly(admin);\r\n    }\r\n\r\n    function setConversionRateAddress(SetStepFunctionInterface _contract) public onlyOperator {\r\n        rateContract = _contract;\r\n    }\r\n\r\n    function setImbalanceStepFunction(ERC20 token,\r\n        int[] xBuy,\r\n        int[] yBuy,\r\n        int[] xSell,\r\n        int[] ySell)\r\n    public onlyOperator\r\n    {\r\n        uint i;\r\n\r\n        // check all x for buy are positiv\r\n        for( i = 0 ; i \u003C xBuy.length ; i\u002B\u002B ) {\r\n            require(xBuy[i] \u003E= 0 );\r\n        }\r\n\r\n        // check all y for buy are negative\r\n        for( i = 0 ; i \u003C yBuy.length ; i\u002B\u002B ) {\r\n            require(yBuy[i] \u003C= 0 );\r\n        }\r\n\r\n        // check all x for sell are negative\r\n        for( i = 0 ; i \u003C xSell.length ; i\u002B\u002B ) {\r\n            require(xSell[i] \u003C= 0 );\r\n        }\r\n\r\n        // check all y for sell are negative\r\n        for( i = 0 ; i \u003C ySell.length ; i\u002B\u002B ) {\r\n            require(ySell[i] \u003C= 0 );\r\n        }\r\n\r\n        rateContract.setImbalanceStepFunction(token,xBuy,yBuy,xSell,ySell);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022alerter\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022removeAlerter\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pendingAdmin\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getOperators\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022sendTo\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022withdrawToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newAlerter\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addAlerter\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newAdmin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022claimAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newAdmin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferAdminQuickly\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAlerters\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOperator\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addOperator\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022operator\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022removeOperator\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022xBuy\u0022,\u0022type\u0022:\u0022int256[]\u0022},{\u0022name\u0022:\u0022yBuy\u0022,\u0022type\u0022:\u0022int256[]\u0022},{\u0022name\u0022:\u0022xSell\u0022,\u0022type\u0022:\u0022int256[]\u0022},{\u0022name\u0022:\u0022ySell\u0022,\u0022type\u0022:\u0022int256[]\u0022}],\u0022name\u0022:\u0022setImbalanceStepFunction\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_contract\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setConversionRateAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022sendTo\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022withdrawEther\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022admin\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022operator\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022SetStepFunctionWrapper\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022rateContract\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022admin\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022sendTo\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022TokenWithdraw\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022sendTo\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022EtherWithdraw\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022pendingAdmin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022TransferAdminPending\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022newAdmin\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022previousAdmin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022AdminClaimed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022newAlerter\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022isAdd\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022AlerterAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022newOperator\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022isAdd\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022OperatorAdded\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"SetStepFunctionWrapper2","CompilerVersion":"v0.4.18\u002Bcommit.9cf6e910","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://b54282661995a23746118a8ab22ba0765274738c043007a2b64970c83fedd5c9"}]