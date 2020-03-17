[{"SourceCode":"/*\r\n-----------------------------------------------------------------\r\nFILE INFORMATION\r\n-----------------------------------------------------------------\r\n\r\nfile:       Owned.sol\r\nversion:    1.1\r\nauthor:     Anton Jurisevic\r\n            Dominic Romanowski\r\n\r\ndate:       2018-2-26\r\n\r\n-----------------------------------------------------------------\r\nMODULE DESCRIPTION\r\n-----------------------------------------------------------------\r\n\r\nAn Owned contract, to be inherited by other contracts.\r\nRequires its owner to be explicitly set in the constructor.\r\nProvides an onlyOwner access modifier.\r\n\r\nTo change owner, the current owner must nominate the next owner,\r\nwho then has to accept the nomination. The nomination can be\r\ncancelled before it is accepted by the new owner by having the\r\nprevious owner change the nomination (setting it to 0).\r\n\r\n-----------------------------------------------------------------\r\n*/\r\n\r\npragma solidity 0.4.25;\r\n\r\n/**\r\n * @title A contract with an owner.\r\n * @notice Contract ownership can be transferred by first nominating the new owner,\r\n * who must then accept the ownership, which prevents accidental incorrect ownership transfers.\r\n */\r\ncontract Owned {\r\n    address public owner;\r\n    address public nominatedOwner;\r\n\r\n    /**\r\n     * @dev Owned Constructor\r\n     */\r\n    constructor(address _owner)\r\n        public\r\n    {\r\n        require(_owner != address(0), \u0022Owner address cannot be 0\u0022);\r\n        owner = _owner;\r\n        emit OwnerChanged(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @notice Nominate a new owner of this contract.\r\n     * @dev Only the current owner may nominate a new owner.\r\n     */\r\n    function nominateNewOwner(address _owner)\r\n        external\r\n        onlyOwner\r\n    {\r\n        nominatedOwner = _owner;\r\n        emit OwnerNominated(_owner);\r\n    }\r\n\r\n    /**\r\n     * @notice Accept the nomination to be owner.\r\n     */\r\n    function acceptOwnership()\r\n        external\r\n    {\r\n        require(msg.sender == nominatedOwner, \u0022You must be nominated before you can accept ownership\u0022);\r\n        emit OwnerChanged(owner, nominatedOwner);\r\n        owner = nominatedOwner;\r\n        nominatedOwner = address(0);\r\n    }\r\n\r\n    modifier onlyOwner\r\n    {\r\n        require(msg.sender == owner, \u0022Only the contract owner may perform this action\u0022);\r\n        _;\r\n    }\r\n\r\n    event OwnerNominated(address newOwner);\r\n    event OwnerChanged(address oldOwner, address newOwner);\r\n}\r\n\r\n\r\ncontract ISynthetixState {\r\n    // A struct for handing values associated with an individual user\u0027s debt position\r\n    struct IssuanceData {\r\n        // Percentage of the total debt owned at the time\r\n        // of issuance. This number is modified by the global debt\r\n        // delta array. You can figure out a user\u0027s exit price and\r\n        // collateralisation ratio using a combination of their initial\r\n        // debt and the slice of global debt delta which applies to them.\r\n        uint initialDebtOwnership;\r\n        // This lets us know when (in relative terms) the user entered\r\n        // the debt pool so we can calculate their exit price and\r\n        // collateralistion ratio\r\n        uint debtEntryIndex;\r\n    }\r\n\r\n    uint[] public debtLedger;\r\n    uint public issuanceRatio;\r\n    mapping(address =\u003E IssuanceData) public issuanceData;\r\n\r\n    function debtLedgerLength() external view returns (uint);\r\n    function hasIssued(address account) external view returns (bool);\r\n    function incrementTotalIssuerCount() external;\r\n    function decrementTotalIssuerCount() external;\r\n    function setCurrentIssuanceData(address account, uint initialDebtOwnership) external;\r\n    function lastDebtLedgerEntry() external view returns (uint);\r\n    function appendDebtLedgerValue(uint value) external;\r\n    function clearIssuanceData(address account) external;\r\n}\r\n\r\n\r\ninterface ISynth {\r\n  function burn(address account, uint amount) external;\r\n  function issue(address account, uint amount) external;\r\n  function transfer(address to, uint value) public returns (bool);\r\n  function triggerTokenFallbackIfNeeded(address sender, address recipient, uint amount) external;\r\n  function transferFrom(address from, address to, uint value) public returns (bool);\r\n}\r\n\r\n\r\n/**\r\n * @title SynthetixEscrow interface\r\n */\r\ninterface ISynthetixEscrow {\r\n    function balanceOf(address account) public view returns (uint);\r\n    function appendVestingEntry(address account, uint quantity) public;\r\n}\r\n\r\n\r\ncontract IFeePool {\r\n    address public FEE_ADDRESS;\r\n    uint public exchangeFeeRate;\r\n    function amountReceivedFromExchange(uint value) external view returns (uint);\r\n    function amountReceivedFromTransfer(uint value) external view returns (uint);\r\n    function feePaid(bytes4 currencyKey, uint amount) external;\r\n    function appendAccountIssuanceRecord(address account, uint lockedAmount, uint debtEntryIndex) external;\r\n    function rewardsMinted(uint amount) external;\r\n    function transferFeeIncurred(uint value) public view returns (uint);\r\n}\r\n\r\n\r\n/**\r\n * @title ExchangeRates interface\r\n */\r\ninterface IExchangeRates {\r\n    function effectiveValue(bytes4 sourceCurrencyKey, uint sourceAmount, bytes4 destinationCurrencyKey) public view returns (uint);\r\n\r\n    function rateForCurrency(bytes4 currencyKey) public view returns (uint);\r\n\r\n    function anyRateIsStale(bytes4[] currencyKeys) external view returns (bool);\r\n\r\n    function rateIsStale(bytes4 currencyKey) external view returns (bool);\r\n}\r\n\r\n\r\n/**\r\n * @title Synthetix interface contract\r\n * @dev pseudo interface, actually declared as contract to hold the public getters \r\n */\r\n\r\n\r\ncontract ISynthetix {\r\n\r\n    // ========== PUBLIC STATE VARIABLES ==========\r\n\r\n    IFeePool public feePool;\r\n    ISynthetixEscrow public escrow;\r\n    ISynthetixEscrow public rewardEscrow;\r\n    ISynthetixState public synthetixState;\r\n    IExchangeRates public exchangeRates;\r\n\r\n    // ========== PUBLIC FUNCTIONS ==========\r\n\r\n    function balanceOf(address account) public view returns (uint);\r\n    function transfer(address to, uint value) public returns (bool);\r\n    function effectiveValue(bytes4 sourceCurrencyKey, uint sourceAmount, bytes4 destinationCurrencyKey) public view returns (uint);\r\n\r\n    function synthInitiatedFeePayment(address from, bytes4 sourceCurrencyKey, uint sourceAmount) external returns (bool);\r\n    function synthInitiatedExchange(\r\n        address from,\r\n        bytes4 sourceCurrencyKey,\r\n        uint sourceAmount,\r\n        bytes4 destinationCurrencyKey,\r\n        address destinationAddress) external returns (bool);\r\n    function exchange(\r\n        bytes4 sourceCurrencyKey,\r\n        uint sourceAmount,\r\n        bytes4 destinationCurrencyKey,\r\n        address destinationAddress) external returns (bool);\r\n    function collateralisationRatio(address issuer) public view returns (uint);\r\n    function totalIssuedSynths(bytes4 currencyKey)\r\n        public\r\n        view\r\n        returns (uint);\r\n    function getSynth(bytes4 currencyKey) public view returns (ISynth);\r\n    function debtBalanceOf(address issuer, bytes4 currencyKey) public view returns (uint);\r\n}\r\n\r\n\r\n/*\r\n-----------------------------------------------------------------\r\nFILE INFORMATION\r\n-----------------------------------------------------------------\r\n\r\nfile:       SynthetixAirdropper.sol\r\nversion:    1.0\r\nauthor:     Jackson Chan\r\n            Clinton Ennis\r\ndate:       2019-08-02\r\n\r\n-----------------------------------------------------------------\r\nMODULE DESCRIPTION\r\n-----------------------------------------------------------------\r\n\r\nThis contract was adapted for use by the Synthetix project from the\r\nairdropper contract that OmiseGO created here:\r\nhttps://github.com/omisego/airdrop/blob/master/contracts/Airdropper.sol\r\n\r\nIt exists to save gas costs per transaction that\u0027d otherwise be\r\nincurred running airdrops individually.\r\n\r\nOriginal license below.\r\n\r\n-----------------------------------------------------------------\r\n\r\nCopyright 2017 OmiseGO Pte Ltd\r\n\r\nLicensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\nyou may not use this file except in compliance with the License.\r\nYou may obtain a copy of the License at\r\n\r\n    http://www.apache.org/licenses/LICENSE-2.0\r\n\r\nUnless required by applicable law or agreed to in writing, software\r\ndistributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\nWITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\nSee the License for the specific language governing permissions and\r\nlimitations under the License.\r\n*/\r\n\r\n\r\ncontract SynthetixAirdropper is Owned {\r\n    /* ========== CONSTRUCTOR ========== */\r\n\r\n    /**\r\n     * @dev Constructor\r\n     * @param _owner The owner of this contract.\r\n     */\r\n    constructor (address _owner)\r\n        Owned(_owner)\r\n        public\r\n    {}\r\n\r\n    /**\r\n     * @notice Multisend airdrops tokens to an array of destinations.\r\n     */\r\n    function multisend(address _tokenAddress, address[] _destinations, uint256[] _values)\r\n        external\r\n        onlyOwner\r\n    {\r\n        // Protect against obviously incorrect calls.\r\n        require(_destinations.length == _values.length, \u0022Dests and values mismatch\u0022);\r\n\r\n        // Loop through each destination and perform the transfer.\r\n        uint256 i = 0;\r\n        while (i \u003C _destinations.length) {\r\n            ISynthetix(_tokenAddress).transfer(_destinations[i], _values[i]);\r\n            i \u002B= 1;\r\n        }\r\n    }\r\n\r\n    // fallback function for ether sent accidentally to contract\r\n    function ()\r\n        external\r\n        payable\r\n    {\r\n        owner.transfer(msg.value);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022nominateNewOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022nominatedOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_destinations\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_values\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022multisend\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnerNominated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022oldOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnerChanged\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"SynthetixAirdropper","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000b64ff7a4a33acdf48d97dab0d764afd0f6176882","Library":"","SwarmSource":"bzzr://e6d41ecea7532ac08d39e729a1e7114cbcbbe1c172235906f056cc7844d37d57"}]