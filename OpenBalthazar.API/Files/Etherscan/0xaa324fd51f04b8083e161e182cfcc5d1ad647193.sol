[{"SourceCode":"pragma solidity ^0.5.12;\r\n\r\nlibrary SafeMath {\r\n\tfunction mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n\t\tif (a == 0) {\r\n\t\t\treturn 0;\r\n\t\t}\r\n\t\tc = a * b;\r\n\t\tassert(c / a == b);\r\n\t\treturn c;\r\n\t}\r\n\r\n\tfunction div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n\t\treturn a / b;\r\n\t}\r\n\t\r\n\tfunction sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n\t\tassert(b \u003C= a);\r\n\t\treturn a - b;\r\n\t}\r\n\r\n\tfunction add(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n\t\tc = a \u002B b;\r\n\t\tassert(c \u003E= a);\r\n\t\treturn c;\r\n\t}\r\n}\r\n\r\ncontract Ownable {\r\n\taddress public owner;\r\n\taddress public newOwner;\r\n\r\n\tevent OwnershipTransferred(address indexed oldOwner, address indexed newOwner);\r\n\r\n\tmodifier onlyOwner() {\r\n\t\trequire(msg.sender == owner, \u0022msg.sender == owner\u0022);\r\n\t\t_;\r\n\t}\r\n\r\n\tfunction transferOwnership(address _newOwner) public onlyOwner {\r\n\t\trequire(address(0) != _newOwner, \u0022address(0) != _newOwner\u0022);\r\n\t\tnewOwner = _newOwner;\r\n\t}\r\n\r\n\tfunction acceptOwnership() public {\r\n\t\trequire(msg.sender == newOwner, \u0022msg.sender == newOwner\u0022);\r\n\t\temit OwnershipTransferred(owner, msg.sender);\r\n\t\towner = msg.sender;\r\n\t\tnewOwner = address(0);\r\n\t}\r\n}\r\n\r\ncontract tokenInterface {\r\n\tfunction balanceOf(address _owner) public view returns (uint256 balance);\r\n\tfunction transfer(address _to, uint256 _value) public returns (bool);\r\n    uint8 public decimals;\r\n}\r\n\r\ncontract medianizerInterface {\r\n\tfunction read() public view returns(bytes32);\r\n}\r\n\r\ncontract STO is Ownable {\r\n    using SafeMath for uint256;\r\n\t\r\n\ttokenInterface public tokenContract;\r\n    uint256 public timeStart;\r\n    uint256 public timeEnd;\r\n    \r\n    address payable public wallet;\r\n    \r\n    uint256 public ethMin;\r\n    uint256 public tknLocked;\r\n    uint256 public tknUnlocked;\r\n\t\r\n\tmapping(address =\u003E uint256) public tknUserPending; // address =\u003E token amount that will be claimed after KYC\r\n\r\n    bool internal initialized = true;\r\n    function init(address _tokenContract, address payable _wallet, string memory _name, string memory _symbol, uint8 _decimals, uint256 _timeStart, uint256 _timeEnd, uint256 _ethMin, address _priceFeedContract) public {\r\n        require(!initialized, \u0022!initialized\u0022);\r\n        initialized = true;\r\n        \r\n        tokenContract = tokenInterface(_tokenContract);\r\n        wallet = _wallet;\r\n        name = _name;\r\n        symbol = _symbol;\r\n        decimals = _decimals;\r\n        timeStart = _timeStart;\r\n        timeEnd = _timeEnd;\r\n        ethMin = _ethMin;\r\n        priceFeedContract = medianizerInterface(_priceFeedContract);\r\n        \r\n        owner = msg.sender;\r\n    }\r\n\r\n    medianizerInterface public priceFeedContract;\r\n    \r\n    function priceUsd() public view returns(uint256) {\r\n        return uint256(priceFeedContract.read());\r\n    }\r\n    \r\n    function changeUsdToEth(uint256 _usd) public view returns(uint256 eth) {\r\n        eth =  _usd.mul(1e18).div(priceUsd());\r\n    }\r\n\r\n    function changeEthToUsd(uint256 _eth) public view returns(uint256 usd) {\r\n        usd =  _eth.mul(priceUsd()).div(1e18);\r\n    }\r\n\r\n\r\n\t/***\r\n\t * Start ERC20 Implementation\r\n\t ***/\r\n\t \r\n \tstring public name;\r\n    string public symbol;\r\n    uint8 public decimals;\r\n\t\r\n    function totalSupply() view public returns(uint256){\r\n        return tknLocked;\r\n    }\r\n    \r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    function transfer(address , uint256 ) public pure returns (bool) {\r\n        require(false, \u0022false\u0022);\r\n    }\r\n\r\n    function balanceOf(address _tknHolder) public view returns (uint256 balance) {\r\n        return tknUserPending[_tknHolder];\r\n    }\r\n\t \r\n\t/***\r\n\t * End ERC20 Implementation\r\n\t ***/\r\n    \r\n    /***\r\n     * Start Functions for Owner\r\n     ***/\r\n    \r\n    function withdrawTokens(address to, uint256 value) public onlyOwner returns (bool) {\r\n        return tokenContract.transfer(to, value);\r\n    }\r\n    \r\n    function changeSettings(address _tokenContract, address payable _wallet, string memory _name, string memory _symbol, uint8 _decimals, uint256 _timeStart, uint256 _timeEnd, uint256 _ethMin, address _priceFeedContract) public onlyOwner {\r\n        if(_tokenContract != address(0)) tokenContract = tokenInterface(_tokenContract);\r\n        if(_wallet != address(0)) wallet = _wallet;\r\n        if(keccak256(abi.encodePacked(_name)) != keccak256(abi.encodePacked(\u0022\u0022))) name = _name;\r\n        if(keccak256(abi.encodePacked(_symbol)) != keccak256(abi.encodePacked(\u0022\u0022))) symbol = _symbol;\r\n        if(_decimals != 0) decimals = _decimals;\r\n        if(_timeStart != 0) timeStart = _timeStart;\r\n        if(_timeEnd != 0) timeEnd = _timeEnd;\r\n        if(_ethMin != 0) ethMin = _ethMin;\r\n        if(_priceFeedContract != address(0)) priceFeedContract = medianizerInterface(_priceFeedContract);\r\n    }\r\n    \r\n    function authorizeUsers(address[] memory  _users) onlyOwner public {\r\n        for( uint256 i = 0; i \u003C _users.length; i \u002B= 1 ) {\r\n            giveToken(_users[i]);\r\n        }\r\n    }\r\n    \r\n    function refundBuyer(address _buyer) public onlyOwner {\r\n        emit Transfer(_buyer, address(0), tknUserPending[_buyer]);\r\n        tknLocked = tknLocked.sub(tknUserPending[_buyer]);\r\n        tknUserPending[_buyer] = 0;\r\n    }\r\n    \r\n    /***\r\n     * End Functions for Owner\r\n     ***/\r\n     \r\n    /***\r\n    * Start internal Functions \r\n    ***/\r\n    \r\n    function priceLevel(uint256 _eth) public view returns (uint256 priceTknEth) {\r\n        uint256 usd = changeEthToUsd(_eth);\r\n                               priceTknEth = changeUsdToEth(1.20 * 1e18);\r\n        if(usd \u003E= 200 *1e18)   priceTknEth = changeUsdToEth(0.80 * 1e18);\r\n        if(usd \u003E= 600 *1e18)   priceTknEth = changeUsdToEth(0.78 * 1e18);\r\n        if(usd \u003E= 1800 *1e18)  priceTknEth = changeUsdToEth(0.75 * 1e18);\r\n        if(usd \u003E= 5400 *1e18)  priceTknEth = changeUsdToEth(0.70 * 1e18);\r\n        if(usd \u003E= 16200 *1e18) priceTknEth = changeUsdToEth(0.64 * 1e18);\r\n        if(usd \u003E= 50000 *1e18) priceTknEth = changeUsdToEth(0.58 * 1e18);\r\n    }\r\n    \r\n\tfunction takeEther(address payable _buyer) internal {\r\n\t    require( now \u003E timeStart, \u0022now \u003E timeStart\u0022 );\r\n\t\trequire( now \u003C timeEnd, \u0022now \u003C timeEnd\u0022);\r\n        require( msg.value \u003E= ethMin, \u0022msg.value \u003E= ethMin\u0022); \r\n        uint256 remainingTokens = tokenContract.balanceOf(address(this));\r\n        require( remainingTokens \u003E 0, \u0022remainingTokens \u003E 0\u0022 );\r\n        \r\n        uint256 priceTknEth = priceLevel(msg.value);\r\n        \r\n        uint256 oneToken = 10 ** uint256(tokenContract.decimals());\r\n        uint256 tokenAmount = msg.value.mul( oneToken ).div( priceTknEth );\r\n        \r\n        uint256 refund = 0;\r\n        if ( remainingTokens \u003C tokenAmount ) {\r\n            refund = (tokenAmount - remainingTokens).mul(priceTknEth).div(oneToken);\r\n            tokenAmount = remainingTokens;\r\n\t\t\tremainingTokens = 0; // set remaining token to 0\r\n            _buyer.transfer(refund);\r\n        } else {\r\n\t\t\tremainingTokens = remainingTokens.sub(tokenAmount); \r\n        }\r\n        \r\n        uint256 funds = msg.value.sub(refund);\r\n        wallet.transfer(funds);\r\n        \r\n        tknUserPending[_buyer] = tknUserPending[_buyer].add(tokenAmount);\t\r\n        \r\n        tknLocked = tknLocked.add(tokenAmount);\r\n        \r\n        emit Transfer(address(0), _buyer, tokenAmount);\r\n\t}\r\n\t\r\n\tfunction giveToken(address _buyer) internal {\r\n\t    require( tknUserPending[_buyer] \u003E 0, \u0022tknUserPending[_buyer] \u003E 0\u0022 );\r\n\t\r\n\t\ttknUnlocked = tknUnlocked.add(tknUserPending[_buyer]);\r\n\t\ttknLocked = tknLocked.sub(tknUserPending[_buyer]);\r\n\r\n\t\ttokenContract.transfer(_buyer, tknUserPending[_buyer]);\r\n        emit Transfer(_buyer, address(0), tknUserPending[_buyer]);\r\n        \r\n\t\ttknUserPending[_buyer] = 0;\r\n\t}\r\n\t\r\n    /***\r\n    * End internal Functions \r\n    ***/\r\n    \r\n\tfunction () external payable{\r\n\t    takeEther(msg.sender);\r\n\t}\r\n}","ABI":"[{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022oldOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022_users\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022authorizeUsers\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_tknHolder\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_eth\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022changeEthToUsd\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022usd\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_tokenContract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_symbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022_decimals\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_timeStart\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_timeEnd\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_ethMin\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_priceFeedContract\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022changeSettings\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_usd\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022changeUsdToEth\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022eth\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ethMin\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_tokenContract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_symbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022_decimals\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_timeStart\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_timeEnd\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_ethMin\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_priceFeedContract\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022init\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022newOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022priceFeedContract\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract medianizerInterface\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_eth\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022priceLevel\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022priceTknEth\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022priceUsd\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_buyer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022refundBuyer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022timeEnd\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022timeStart\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tknLocked\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tknUnlocked\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022tknUserPending\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tokenContract\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract tokenInterface\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022wallet\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawTokens\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"STO","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://3dc4619459d6ebec0661b9395fcb65acee87f1c43a411c9635f3485344f95dd4"}]