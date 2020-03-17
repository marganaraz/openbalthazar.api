[{"SourceCode":"pragma solidity ^0.5.11;\r\n\r\nlibrary SafeMath {\r\n\tfunction mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n\t\tif (a == 0) {\r\n\t\t\treturn 0;\r\n\t\t}\r\n\t\tc = a * b;\r\n\t\tassert(c / a == b);\r\n\t\treturn c;\r\n\t}\r\n\r\n\tfunction div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n\t\treturn a / b;\r\n\t}\r\n\t\r\n\tfunction sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n\t\tassert(b \u003C= a);\r\n\t\treturn a - b;\r\n\t}\r\n\r\n\tfunction add(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n\t\tc = a \u002B b;\r\n\t\tassert(c \u003E= a);\r\n\t\treturn c;\r\n\t}\r\n}\r\n\r\ncontract Ownable {\r\n\taddress public owner;\r\n\taddress public newOwner;\r\n\r\n\tevent OwnershipTransferred(address indexed oldOwner, address indexed newOwner);\r\n\r\n\tmodifier onlyOwner() {\r\n\t\trequire(msg.sender == owner, \u0022msg.sender == owner\u0022);\r\n\t\t_;\r\n\t}\r\n\r\n\tfunction transferOwnership(address _newOwner) public onlyOwner {\r\n\t\trequire(address(0) != _newOwner, \u0022address(0) != _newOwner\u0022);\r\n\t\tnewOwner = _newOwner;\r\n\t}\r\n\r\n\tfunction acceptOwnership() public {\r\n\t\trequire(msg.sender == newOwner, \u0022msg.sender == newOwner\u0022);\r\n\t\temit OwnershipTransferred(owner, msg.sender);\r\n\t\towner = msg.sender;\r\n\t\tnewOwner = address(0);\r\n\t}\r\n}\r\n\r\ncontract tokenInterface {\r\n\tfunction balanceOf(address _owner) public view returns (uint256 balance);\r\n\tfunction transfer(address _to, uint256 _value) public returns (bool);\r\n    uint8 public decimals;\r\n}\r\n\r\ncontract medianizerInterface {\r\n\tfunction read() public view returns(bytes32);\r\n}\r\n\r\ncontract STO is Ownable {\r\n    using SafeMath for uint256;\r\n\t\r\n\ttokenInterface public tokenContract;\r\n    uint256 public startTime;\r\n    uint256 public endTime;\r\n    \r\n    address payable public wallet;\r\n    \r\n    uint256 public etherMinimum;\r\n    uint256 public tknLocked;\r\n    uint256 public tknUnlocked;\r\n\t\r\n\tmapping(address =\u003E uint256) public tknUserPending; // address =\u003E token amount that will be claimed after KYC\r\n\r\n    bool internal initialized = true;\r\n    function init(address _tokenContract, address payable _wallet, string memory _name, string memory _symbol, uint8 _decimals, uint256 _startTime, uint256 _endTime, uint256 _etherMinimum, address _priceFeedContract, uint256 _priceTknUsd) public {\r\n        require(!initialized, \u0022!initialized\u0022);\r\n        initialized = true;\r\n        \r\n        tokenContract = tokenInterface(_tokenContract);\r\n        wallet = _wallet;\r\n        name = _name;\r\n        symbol = _symbol;\r\n        decimals = _decimals;\r\n        startTime = _startTime;\r\n        endTime = _endTime;\r\n        etherMinimum = _etherMinimum;\r\n        priceFeedContract = medianizerInterface(_priceFeedContract);\r\n        priceTknUsd = _priceTknUsd;\r\n        \r\n        owner = msg.sender;\r\n    }\r\n    \r\n    uint256 public priceTknUsd;\r\n    medianizerInterface public priceFeedContract;\r\n    \r\n    function priceUsd() public view returns(uint256) {\r\n        return uint256(priceFeedContract.read());\r\n    }\r\n    \r\n    function priceTknEth() public view returns(uint256) {\r\n        return priceTknUsd.mul(1e18).div(priceUsd());\r\n    }\r\n\r\n\t/***\r\n\t * Start ERC20 Implementation\r\n\t ***/\r\n\t \r\n \tstring public name;\r\n    string public symbol;\r\n    uint8 public decimals;\r\n\t\r\n    function totalSupply() view public returns(uint256){\r\n        return tknLocked;\r\n    }\r\n    \r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    function transfer(address , uint256 ) public pure returns (bool) {\r\n        require(false, \u0022false\u0022);\r\n    }\r\n\r\n    function balanceOf(address _tknHolder) public view returns (uint256 balance) {\r\n        return tknUserPending[_tknHolder];\r\n    }\r\n\t \r\n\t/***\r\n\t * End ERC20 Implementation\r\n\t ***/\r\n    \r\n    /***\r\n     * Start Functions for Owner\r\n     ***/\r\n    \r\n    function withdrawTokens(address to, uint256 value) public onlyOwner returns (bool) {\r\n        return tokenContract.transfer(to, value);\r\n    }\r\n    \r\n    function changeSettings(address _tokenContract, address payable _wallet, string memory _name, string memory _symbol, uint8 _decimals, uint256 _startTime, uint256 _endTime, uint256 _etherMinimum, address _priceFeedContract, uint256 _priceTknUsd) public onlyOwner {\r\n        if(_tokenContract != address(0)) tokenContract = tokenInterface(_tokenContract);\r\n        if(_wallet != address(0)) wallet = _wallet;\r\n        if(keccak256(abi.encodePacked(_name)) != keccak256(abi.encodePacked(\u0022\u0022))) name = _name;\r\n        if(keccak256(abi.encodePacked(_symbol)) != keccak256(abi.encodePacked(\u0022\u0022))) symbol = _symbol;\r\n        if(_decimals != 0) decimals = _decimals;\r\n        if(_startTime != 0) startTime = _startTime;\r\n        if(_endTime != 0) endTime = _endTime;\r\n        if(_etherMinimum != 0) etherMinimum = _etherMinimum;\r\n        if(_priceFeedContract != address(0)) priceFeedContract = medianizerInterface(_priceFeedContract);\r\n        if(_priceTknUsd != 0) priceTknUsd = _priceTknUsd;\r\n    }\r\n    \r\n    function authorizeUsers(address[] memory  _users) onlyOwner public {\r\n        for( uint256 i = 0; i \u003C _users.length; i \u002B= 1 ) {\r\n            giveToken(_users[i]);\r\n        }\r\n    }\r\n    \r\n    function refundBuyer(address _buyer) public onlyOwner {\r\n        emit Transfer(_buyer, address(0), tknUserPending[_buyer]);\r\n        tknLocked = tknLocked.sub(tknUserPending[_buyer]);\r\n        tknUserPending[_buyer] = 0;\r\n    }\r\n    \r\n    /***\r\n     * End Functions for Owner\r\n     ***/\r\n     \r\n    /***\r\n    * Start internal Functions \r\n    ***/\r\n    \r\n\tfunction takeEther(address payable _buyer) internal {\r\n\t    require( now \u003E startTime, \u0022now \u003E startTime\u0022 );\r\n\t\trequire( now \u003C endTime, \u0022now \u003C endTime\u0022);\r\n        require( msg.value \u003E= etherMinimum, \u0022msg.value \u003E= etherMinimum\u0022); \r\n        uint256 remainingTokens = tokenContract.balanceOf(address(this));\r\n        require( remainingTokens \u003E 0, \u0022remainingTokens \u003E 0\u0022 );\r\n        \r\n        uint256 oneToken = 10 ** uint256(tokenContract.decimals());\r\n        uint256 tokenAmount = msg.value.mul( oneToken ).div( priceTknEth() );\r\n        \r\n        uint256 refund = 0;\r\n        if ( remainingTokens \u003C tokenAmount ) {\r\n            refund = (tokenAmount - remainingTokens).mul(priceTknEth()).div(oneToken);\r\n            tokenAmount = remainingTokens;\r\n\t\t\tremainingTokens = 0; // set remaining token to 0\r\n            _buyer.transfer(refund);\r\n        } else {\r\n\t\t\tremainingTokens = remainingTokens.sub(tokenAmount); // update remaining token without bonus\r\n        }\r\n        \r\n        uint256 funds = msg.value.sub(refund);\r\n        wallet.transfer(funds);\r\n        \r\n        tknUserPending[_buyer] = tknUserPending[_buyer].add(tokenAmount);\t\r\n        \r\n        tknLocked = tknLocked.add(tokenAmount);\r\n        \r\n        emit Transfer(address(0), _buyer, tokenAmount);\r\n\t}\r\n\t\r\n\tfunction giveToken(address _buyer) internal {\r\n\t    require( tknUserPending[_buyer] \u003E 0, \u0022tknUserPending[_buyer] \u003E 0\u0022 );\r\n\t\r\n\t\ttknUnlocked = tknUnlocked.add(tknUserPending[_buyer]);\r\n\t\ttknLocked = tknLocked.sub(tknUserPending[_buyer]);\r\n\r\n\t\ttokenContract.transfer(_buyer, tknUserPending[_buyer]);\r\n        emit Transfer(_buyer, address(0), tknUserPending[_buyer]);\r\n        \r\n\t\ttknUserPending[_buyer] = 0;\r\n\t}\r\n\t\r\n    /***\r\n    * End internal Functions \r\n    ***/\r\n    \r\n\tfunction () external payable{\r\n\t    takeEther(msg.sender);\r\n\t}\r\n}","ABI":"[{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022oldOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022_users\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022authorizeUsers\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_tknHolder\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_tokenContract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_symbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022_decimals\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_startTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_endTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_etherMinimum\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_priceFeedContract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_priceTknUsd\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022changeSettings\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022endTime\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022etherMinimum\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_tokenContract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_symbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022_decimals\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_startTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_endTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_etherMinimum\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_priceFeedContract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_priceTknUsd\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022init\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022newOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022priceFeedContract\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract medianizerInterface\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022priceTknEth\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022priceTknUsd\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022priceUsd\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_buyer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022refundBuyer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022startTime\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tknLocked\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tknUnlocked\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022tknUserPending\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tokenContract\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract tokenInterface\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022wallet\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawTokens\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"STO","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://7c046737b329749c7699b1a2b70e2ffb0d1d823ee987b388480aeaf5a2909ed0"}]