[{"SourceCode":"// File: @gnosis.pm/util-contracts/contracts/Token.sol\r\n\r\n/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md\r\npragma solidity ^0.5.2;\r\n\r\n/// @title Abstract token contract - Functions to be implemented by token contracts\r\ncontract Token {\r\n    /*\r\n     *  Events\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint value);\r\n    event Approval(address indexed owner, address indexed spender, uint value);\r\n\r\n    /*\r\n     *  Public functions\r\n     */\r\n    function transfer(address to, uint value) public returns (bool);\r\n    function transferFrom(address from, address to, uint value) public returns (bool);\r\n    function approve(address spender, uint value) public returns (bool);\r\n    function balanceOf(address owner) public view returns (uint);\r\n    function allowance(address owner, address spender) public view returns (uint);\r\n    function totalSupply() public view returns (uint);\r\n}\r\n\r\n// File: contracts/Disbursement.sol\r\n\r\npragma solidity ^0.5.8;\r\n\r\n\r\n\r\n/// @title Disbursement contract - allows to distribute tokens over time\r\n/// @author Stefan George - \u003Cstefan@gnosis.pm\u003E\r\ncontract Disbursement {\r\n\r\n    /*\r\n     *  Storage\r\n     */\r\n    address public owner;\r\n    address public receiver;\r\n    address public wallet;\r\n    uint public disbursementPeriod;\r\n    uint public startDate;\r\n    uint public withdrawnTokens;\r\n    Token public token;\r\n\r\n    /*\r\n     *  Modifiers\r\n     */\r\n    modifier isOwner() {\r\n        if (msg.sender != owner)\r\n            revert(\u0022Only owner is allowed to proceed\u0022);\r\n        _;\r\n    }\r\n\r\n    modifier isReceiver() {\r\n        if (msg.sender != receiver)\r\n            revert(\u0022Only receiver is allowed to proceed\u0022);\r\n        _;\r\n    }\r\n\r\n    modifier isWallet() {\r\n        if (msg.sender != wallet)\r\n            revert(\u0022Only wallet is allowed to proceed\u0022);\r\n        _;\r\n    }\r\n\r\n    modifier isSetUp() {\r\n        if (address(token) == address(0))\r\n            revert(\u0022Contract is not set up\u0022);\r\n        _;\r\n    }\r\n\r\n    /*\r\n     *  Public functions\r\n     */\r\n    /// @dev Constructor function sets contract owner and wallet address, which is allowed to withdraw all tokens anytime\r\n    /// @param _receiver Receiver of vested tokens\r\n    /// @param _wallet Gnosis multisig wallet address\r\n    /// @param _disbursementPeriod Vesting period in seconds\r\n    /// @param _startDate Start date of disbursement period (cliff)\r\n    constructor(address _receiver, address _wallet, uint _disbursementPeriod, uint _startDate)\r\n        public\r\n    {\r\n        if (_receiver == address(0) || _wallet == address(0) || _disbursementPeriod == 0)\r\n            revert(\u0022Arguments are null\u0022);\r\n        owner = msg.sender;\r\n        receiver = _receiver;\r\n        wallet = _wallet;\r\n        disbursementPeriod = _disbursementPeriod;\r\n        startDate = _startDate;\r\n        if (startDate == 0){\r\n          startDate = now;\r\n        }\r\n    }\r\n\r\n    /// @dev Setup function sets external contracts\u0027 addresses\r\n    /// @param _token Token address\r\n    function setup(Token _token)\r\n        public\r\n        isOwner\r\n    {\r\n        if (address(token) != address(0) || address(_token) == address(0))\r\n            revert(\u0022Setup was executed already or address is null\u0022);\r\n        token = _token;\r\n    }\r\n\r\n    /// @dev Transfers tokens to a given address\r\n    /// @param _to Address of token receiver\r\n    /// @param _value Number of tokens to transfer\r\n    function withdraw(address _to, uint256 _value)\r\n        public\r\n        isReceiver\r\n        isSetUp\r\n    {\r\n        uint maxTokens = calcMaxWithdraw();\r\n        if (_value \u003E maxTokens){\r\n          revert(\u0022Withdraw amount exceeds allowed tokens\u0022);\r\n        }\r\n        withdrawnTokens \u002B= _value;\r\n        token.transfer(_to, _value);\r\n    }\r\n\r\n    /// @dev Transfers all tokens to multisig wallet\r\n    function walletWithdraw()\r\n        public\r\n        isWallet\r\n        isSetUp\r\n    {\r\n        uint balance = token.balanceOf(address(this));\r\n        withdrawnTokens \u002B= balance;\r\n        token.transfer(wallet, balance);\r\n    }\r\n\r\n    /// @dev Calculates the maximum amount of vested tokens\r\n    /// @return Number of vested tokens to withdraw\r\n    function calcMaxWithdraw()\r\n        public\r\n        view\r\n        returns (uint)\r\n    {\r\n        uint maxTokens = (token.balanceOf(address(this)) \u002B withdrawnTokens) * (now - startDate) / disbursementPeriod;\r\n        if (withdrawnTokens \u003E= maxTokens || startDate \u003E now){\r\n          return 0;\r\n        }\r\n        return maxTokens - withdrawnTokens;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdrawnTokens\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022startDate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022calcMaxWithdraw\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022wallet\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setup\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022walletWithdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022disbursementPeriod\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022receiver\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022token\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_disbursementPeriod\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_startDate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"Disbursement","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000224cf0b963c59b95623b3dd6ce07b4ce40f7b13400000000000000000000000052df85e9de71aa1c210873bcf37ec46d36c99dc2000000000000000000000000000000000000000000000000000000000197c5dd0000000000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://e9b6ad4af28fbccad7b5537d923f35ef4f87f29a69a90823ccd9eb99e5b02630"}]