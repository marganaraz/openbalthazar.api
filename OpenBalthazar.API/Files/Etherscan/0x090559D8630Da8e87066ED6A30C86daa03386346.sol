[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\nlibrary SafeMath {\r\n    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n        if (_a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = _a * _b;\r\n        require(c / _a == _b);\r\n\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n        uint256 c = _a / _b;\r\n        \r\n        return c;\r\n    }\r\n\r\n    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n        require(_b \u003C= _a);\r\n        uint256 c = _a - _b;\r\n\r\n        return c;\r\n    }\r\n    \r\n    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n        uint256 c = _a \u002B _b;\r\n        require(c \u003E= _a);\r\n\r\n        return c;\r\n    }\r\n}\r\n\r\ncontract King {\r\n    \r\n    using SafeMath for uint256;\r\n    event transferLogs(address indexed,string,uint256);\r\n    address internal owner;\r\n    \r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n    \r\n    function () external payable {}\r\n\r\n    modifier onlyOwner () {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n    \r\n    function TransferOut (address[] memory _users,uint256[] memory _amount,uint256 _allBalance) public onlyOwner payable {\r\n        require(_users.length\u003E0);\r\n        require(_amount.length\u003E0);\r\n        require(address(this).balance\u003E=_allBalance);\r\n        \r\n        for(uint256 i =0;i\u003C_users.length;i\u002B\u002B){\r\n            require(_users[i]!=address(0));\r\n            require(_amount[i]\u003E0);\r\n            \r\n            address(uint160(_users[i])).transfer(_amount[i]);\r\n            emit transferLogs(_users[i],\u0027\u8F6C\u8D26\u0027,_amount[i]);\r\n        }\r\n    }\r\n    \r\n    function kill() public onlyOwner{\r\n      selfdestruct(address(uint160(owner))); \r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022kill\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_users\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022_allBalance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022TransferOut\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferLogs\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"King","CompilerVersion":"v0.5.0\u002Bcommit.1d4f565a","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://3df0202f18bc43342c2e845b68b7f465cd51cb8a7231b8e5cb4cc9f06b96cd79"}]