[{"SourceCode":"pragma solidity ^0.5.12;\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that revert on error\r\n */\r\nlibrary SafeMath {\r\n\r\n    /**\r\n    * @dev Multiplies two numbers, reverts on overflow.\r\n    */\r\n    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n        if (_a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = _a * _b;\r\n        require(c / _a == _b);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.\r\n    */\r\n    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n        require(_b \u003E 0);\r\n        // Solidity only automatically asserts when dividing by 0\r\n        uint256 c = _a / _b;\r\n        // assert(_a == _b * c \u002B _a % _b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n    */\r\n    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n        require(_b \u003C= _a);\r\n        uint256 c = _a - _b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Adds two numbers, reverts on overflow.\r\n    */\r\n    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n        uint256 c = _a \u002B _b;\r\n        require(c \u003E= _a);\r\n\r\n        return c;\r\n    }\r\n\r\n}\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n    address payable private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n     * account.\r\n     */\r\n    constructor (address payable newOwner) public {\r\n        _owner = newOwner;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @return the address of the owner.\r\n     */\r\n    function owner() public view returns (address payable) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @return true if \u0060msg.sender\u0060 is the owner of the contract.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return msg.sender == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function transferOwnership(address payable newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function _transferOwnership(address payable newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\ncontract ReferStorage is Ownable {\r\n    using SafeMath for uint;\r\n\r\n    mapping(address =\u003E mapping(address =\u003E uint)) private referrerBalance;\r\n    // contractAddress -\u003E wallet -\u003E balance\r\n    mapping(address =\u003E uint) public percentReferrer;\r\n    // address contract -\u003E percent referrer\r\n\r\n    mapping(address =\u003E uint) public balanceContract;\r\n    // address contract -\u003E amount\r\n\r\n    mapping(address =\u003E bool) public whitelist;\r\n    // addressUser -\u003E bool\r\n\r\n    mapping(address =\u003E bool) private parentContract;\r\n    //address contract -\u003E bool\r\n\r\n    modifier onlyOwnerOrWhitelist(){\r\n        address _customerAddress = msg.sender;\r\n        require(whitelist[_customerAddress] || isOwner());\r\n        _;\r\n    }\r\n\r\n    modifier onlyParentContract {\r\n        require(parentContract[msg.sender] || isOwner(), \u0022onlyParentContract methods called by non - parent of contract.\u0022);\r\n        _;\r\n    }\r\n\r\n    event ReferrerWithdraw(address indexed investor, uint256 amount);\r\n    event ReferrerDeposit(address indexed investor, uint256 amount);\r\n    event AddWhitelist(address indexed walletUser, address indexed admin);\r\n    event PutAmountToFund(address indexed addressContract, uint amount, address indexed sender);\r\n    event GetAmountFromFund(address indexed addressContract, uint amount, address indexed beneficiary, address indexed sender);\r\n\r\n    constructor() public\r\n    Ownable(msg.sender)\r\n    {}\r\n\r\n    function() external payable {\r\n    }\r\n\r\n    function viewReferrerBalance(address _contractAddress, address _referrer) public view returns (uint256) {\r\n        return referrerBalance[_contractAddress][_referrer];\r\n    }\r\n\r\n    function getReferrerBalance(address _contractAddress) public {\r\n        address payable referrer = msg.sender;\r\n        uint amount = referrerBalance[_contractAddress][referrer];\r\n        if (amount \u003C= balanceContract[_contractAddress] \u0026\u0026 amount \u003C= balanceAll()) {\r\n            referrerBalance[_contractAddress][referrer] = referrerBalance[_contractAddress][referrer].sub(amount);\r\n            balanceContract[_contractAddress] = balanceContract[_contractAddress].sub(amount);\r\n            referrer.transfer(amount);\r\n            emit ReferrerWithdraw(referrer, amount);\r\n        }\r\n    }\r\n\r\n    function setWhitelist(address _newUser, bool _status) onlyParentContract public {\r\n        whitelist[_newUser] = _status;\r\n        emit AddWhitelist(_newUser, msg.sender);\r\n    }\r\n\r\n    function setReferrerPercent(address _contractAddress, uint _newPercent) onlyParentContract public {\r\n        require(_newPercent \u003E= 0);\r\n        percentReferrer[_contractAddress] = _newPercent;\r\n    }\r\n\r\n    function getReferrerPercent(address _contractAddress) public view returns(uint) {\r\n        return percentReferrer[_contractAddress];\r\n    }\r\n\r\n    function balanceAll() public view returns (uint) {\r\n        return address(this).balance;\r\n    }\r\n\r\n    function balanceByContract(address _contract) public view returns (uint) {\r\n        return balanceContract[_contract];\r\n    }\r\n\r\n    function depositFunds(address _contract) onlyOwnerOrWhitelist payable public {\r\n        require(_contract != address(0));\r\n        uint amount = msg.value;\r\n        if (amount \u003E 0) {\r\n            balanceContract[_contract] = balanceContract[_contract].add(amount);\r\n            emit PutAmountToFund(_contract, amount, msg.sender);\r\n        }\r\n    }\r\n\r\n    function withdrawFunds(uint _amount, address payable _beneficiary, address _contract) onlyParentContract public {\r\n        require(_contract != address(0));\r\n        require(balanceContract[_contract] \u003E= _amount \u0026\u0026 balanceAll() \u003E= _amount \u0026\u0026 _amount \u003E 0);\r\n        balanceContract[_contract] = balanceContract[_contract].sub(_amount);\r\n        _beneficiary.transfer(_amount);\r\n        emit GetAmountFromFund(_contract, _amount, _beneficiary, msg.sender);\r\n    }\r\n\r\n    function withdraw(uint _amount) onlyOwner public {\r\n        require(balanceAll() \u003E= _amount \u0026\u0026 _amount \u003E 0);\r\n        address payable contractOwner = owner();\r\n        contractOwner.transfer(_amount);\r\n        emit GetAmountFromFund(address(this), _amount, contractOwner, msg.sender);\r\n    }\r\n\r\n    function setParentContract(address _contract, bool _status) onlyOwner public {\r\n        parentContract[_contract] = _status;\r\n    }\r\n\r\n    function checkReferralLink(address _contract, address payable _referral, uint256 _amount, bytes memory _referrer) onlyOwnerOrWhitelist public {\r\n        if (_referrer.length == 20) {\r\n            address referrer = bytesToAddress(_referrer);\r\n            if (referrer != msg.sender \u0026\u0026 referrer != _referral ) {\r\n                uint _referrerAmount = _amount.mul(percentReferrer[_contract]).div(1000);\r\n                _addReferrerBalance(_contract, referrer, _referrerAmount);\r\n            }\r\n        }\r\n    }\r\n\r\n    function _addReferrerBalance(address _contract, address _referrer, uint _amount) internal {\r\n        referrerBalance[_contract][_referrer] = referrerBalance[_contract][_referrer].add(_amount);\r\n        emit ReferrerDeposit(_referrer, _amount);\r\n    }\r\n\r\n    function bytesToAddress(bytes memory source) internal pure returns (address) {\r\n        uint result;\r\n        uint mul = 1;\r\n        for (uint i = 20; i \u003E 0; i--) {\r\n            result \u002B= uint8(source[i - 1]) * mul;\r\n            mul = mul * 256;\r\n        }\r\n        return address(result);\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022walletUser\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022admin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022AddWhitelist\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addressContract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022beneficiary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022GetAmountFromFund\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addressContract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022PutAmountToFund\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022investor\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ReferrerDeposit\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022investor\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ReferrerWithdraw\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022balanceAll\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_contract\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceByContract\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceContract\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_contract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_referral\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022_referrer\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022checkReferralLink\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_contract\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022depositFunds\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_contractAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getReferrerBalance\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_contractAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getReferrerPercent\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022percentReferrer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_contract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_status\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setParentContract\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_contractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_newPercent\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setReferrerPercent\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newUser\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_status\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setWhitelist\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_contractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_referrer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022viewReferrerBalance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022whitelist\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_beneficiary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_contract\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022withdrawFunds\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"ReferStorage","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://e474efd14b9dbad7825d04fdd16986eeb021a3d770cc1dcf7e8c8d49a8067f45"}]