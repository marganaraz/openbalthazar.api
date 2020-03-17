[{"SourceCode":"pragma solidity 0.5.11;\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n        uint256 c = a * b;\r\n        assert(c / a == b);\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n        return c;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n}\r\n\r\n/**\r\n * @title ERC20Basic\r\n * @dev Simpler version of ERC20 interface\r\n * See https://github.com/ethereum/EIPs/issues/179\r\n */\r\ncontract ERC20Basic {\r\n    function totalSupply() public view returns (uint256);\r\n    function balanceOf(address who) public view returns (uint256);\r\n    function transfer(address to, uint256 value) public returns (bool);\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n\r\n/**\r\n * @title Basic token\r\n * @dev Basic version of StandardToken, with no allowances.\r\n */\r\ncontract BasicToken is ERC20Basic {\r\n    using SafeMath for uint256;\r\n\r\n    mapping(address =\u003E uint256) balances;\r\n\r\n    uint256 totalSupply_;\r\n\r\n    /**\r\n    * @dev Total number of tokens in existence\r\n    */\r\n    function totalSupply() public view returns (uint256) {\r\n        return totalSupply_;\r\n    }\r\n\r\n    /**\r\n    * @dev Transfer token for a specified address\r\n    * @param _to The address to transfer to.\r\n    * @param _value The amount to be transferred.\r\n    */\r\n    function transfer(address _to, uint256 _value) public returns (bool) {\r\n        require(_to != address(0), \u0022Address must not be zero.\u0022);\r\n        require(_value \u003C= balances[msg.sender], \u0022There is no enough balance.\u0022);\r\n\r\n        balances[msg.sender] = balances[msg.sender].sub(_value);\r\n        balances[_to] = balances[_to].add(_value);\r\n        emit Transfer(msg.sender, _to, _value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n    * @dev Gets the balance of the specified address.\r\n    * @param _owner The address to query the the balance of.\r\n    * @return An uint256 representing the amount owned by the passed address.\r\n    */\r\n    function balanceOf(address _owner) public view returns (uint256) {\r\n        return balances[_owner];\r\n    }\r\n\r\n}\r\n\r\ncontract AtomicSwapErc20 {\r\n    \r\n    struct Swap {\r\n        bytes32 hashedSecret;\r\n        bytes32 secret;\r\n        uint initTimestamp;\r\n        uint refundTime;\r\n        address payable initiator;\r\n        address payable participant;\r\n        uint256 value;\r\n        bool emptied;\r\n        bool initiated;\r\n        address token;\r\n    }\r\n\r\n    mapping(bytes32 =\u003E Swap) public swaps;\r\n\r\n    event Refunded(\r\n        bytes32 indexed _hashedSecret,\r\n        uint _refundTime\r\n    );\r\n    event Redeemed(\r\n        bytes32 indexed _hashedSecret,\r\n        bytes32 _secret,\r\n        uint _redeemTime\r\n    );\r\n    event Initiated(\r\n        bytes32 indexed _hashedSecret,\r\n        uint _initTimestamp,\r\n        uint _refundTime,\r\n        address indexed _participant,\r\n        address indexed _initiator,\r\n        uint256 _value\r\n    );\r\n\r\n    constructor() public {\r\n    }\r\n\r\n    modifier isRefundable(bytes32 _hashedSecret) {\r\n        require(block.timestamp \u003E swaps[_hashedSecret].initTimestamp \u002B swaps[_hashedSecret].refundTime, \u0022refundTime has not come\u0022);\r\n        _;\r\n    }\r\n\r\n    modifier isRedeemable(bytes32 _hashedSecret, bytes32 _secret) {\r\n        require(block.timestamp \u003C= swaps[_hashedSecret].initTimestamp \u002B swaps[_hashedSecret].refundTime, \u0022refundTime has already come\u0022);\r\n        require(sha256(abi.encodePacked(_secret)) == _hashedSecret, \u0022secret is not correct\u0022);\r\n        _;\r\n    }\r\n\r\n    modifier isInitiated(bytes32 _hashedSecret) {\r\n        require(swaps[_hashedSecret].emptied == false, \u0022swap for this hash is already emptied\u0022);\r\n        require(swaps[_hashedSecret].initiated == true, \u0022no initiated swap for such hash\u0022);\r\n        _;\r\n    }\r\n\r\n    modifier isInitiatable(bytes32 _hashedSecret) {\r\n        require(swaps[_hashedSecret].emptied == false, \u0022swap for this hash is already emptied\u0022);\r\n        require(swaps[_hashedSecret].initiated == false, \u0022swap for this hash is already initiated\u0022);\r\n        _;\r\n    }\r\n\r\n    function initiate (bytes32 _hashedSecret, uint _refundTime, address payable _participant, uint256 value, address payable token)\r\n    public payable isInitiatable(_hashedSecret) {\r\n        \r\n        swaps[_hashedSecret].hashedSecret = _hashedSecret;\r\n        swaps[_hashedSecret].initTimestamp = block.timestamp;\r\n        swaps[_hashedSecret].refundTime = _refundTime;\r\n        swaps[_hashedSecret].initiator = msg.sender;\r\n        swaps[_hashedSecret].participant = _participant;\r\n        swaps[_hashedSecret].value = value;\r\n        swaps[_hashedSecret].initiated = true;\r\n        swaps[_hashedSecret].token = token;\r\n\r\n        emit Initiated(\r\n            _hashedSecret,\r\n            swaps[_hashedSecret].initTimestamp,\r\n            swaps[_hashedSecret].refundTime,\r\n            swaps[_hashedSecret].participant,\r\n            msg.sender,\r\n            swaps[_hashedSecret].value\r\n        );\r\n    }\r\n    \r\n    function getContractAddress() public view returns (address){\r\n        return address(this);\r\n    }\r\n    \r\n    function redeem(bytes32 _hashedSecret, bytes32 _secret) public isInitiated(_hashedSecret) isRedeemable(_hashedSecret, _secret) {\r\n        swaps[_hashedSecret].emptied = true;\r\n        swaps[_hashedSecret].secret = _secret;\r\n\r\n        emit Redeemed(\r\n            _hashedSecret,\r\n            _secret,\r\n            block.timestamp\r\n        );\r\n\r\n        ERC20Basic(swaps[_hashedSecret].token).transfer(swaps[_hashedSecret].participant, swaps[_hashedSecret].value);\r\n    }\r\n\r\n    function refund(bytes32 _hashedSecret) public isInitiated(_hashedSecret) isRefundable(_hashedSecret) {\r\n        swaps[_hashedSecret].emptied = true;\r\n        swaps[_hashedSecret].initiated = false;\r\n\r\n        emit Refunded(\r\n            _hashedSecret,\r\n            block.timestamp\r\n        );\r\n\r\n        swaps[_hashedSecret].initiator.transfer(swaps[_hashedSecret].value);\r\n    }\r\n    \r\n    function stringToBytes32(string memory source) public view returns (bytes32 result) {\r\n        bytes memory tempEmptyStringTest = bytes(source);\r\n        if (tempEmptyStringTest.length == 0) {\r\n            return 0x0;\r\n        }\r\n        assembly {\r\n            result := mload(add(source, 32))\r\n        }\r\n    }\r\n\r\n    function bytes32ToSHA256(bytes32 _secret) public view returns(bytes32) {\r\n        return sha256(abi.encodePacked(_secret));\r\n    }\r\n    \r\n    function getTimestamp() public view returns(uint256) {\r\n        return block.timestamp;\r\n    }\r\n    \r\n    function getTimestampPlusHour() public view returns(uint256) {\r\n        return block.timestamp\u002B3600;\r\n    }\r\n    \r\n    function getBalanceSwap(bytes32 _hashedSecret) public view returns (uint256) {\r\n        return swaps[_hashedSecret].value;\r\n    }\r\n    \r\n    function getSecretSwap(bytes32 _hashedSecret) public view returns (bytes32) {\r\n        return swaps[_hashedSecret].secret;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getTimestamp\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getContractAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_hashedSecret\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_refundTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_participant\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022initiate\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_hashedSecret\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022getSecretSwap\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_hashedSecret\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022refund\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_hashedSecret\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022getBalanceSwap\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_hashedSecret\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_secret\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022redeem\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getTimestampPlusHour\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_secret\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022bytes32ToSHA256\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022source\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022stringToBytes32\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022result\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022swaps\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022hashedSecret\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022secret\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022initTimestamp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022refundTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022initiator\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022participant\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022emptied\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022initiated\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_hashedSecret\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_refundTime\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Refunded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_hashedSecret\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_secret\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_redeemTime\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Redeemed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_hashedSecret\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_initTimestamp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_refundTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_participant\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_initiator\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Initiated\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"AtomicSwapErc20","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://c92120328b58d2f8981e8553a5940d0d60a0e0f1558c278f0e7373d95d84b60b"}]