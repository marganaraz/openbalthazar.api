[{"SourceCode":"pragma solidity ^0.5.1;\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n\r\n  /**\r\n  * @dev Multiplies two numbers, throws on overflow.\r\n  */\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n    uint256 c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Integer division of two numbers, truncating the quotient.\r\n  */\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a / b;\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n  */\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  /**\r\n  * @dev Adds two numbers, throws on overflow.\r\n  */\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n\r\n}\r\n\r\n/**\r\n * @title owned\r\n * @dev The owned contract has an owner address, and provides basic authorization\r\n *      control functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract owned {\r\n    address public owner;\r\n    /**\r\n     * @dev The owned constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n     * account.\r\n     */\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n     */\r\n    function transferOwnership(address newOwner) onlyOwner public {\r\n        require(newOwner != address(0));\r\n        owner = newOwner;\r\n    }\r\n}\r\n\r\ncontract ethBank is owned{\r\n    \r\n    function () payable external {}\r\n    \r\n    function withdrawForUser(address payable _address,uint amount) onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022);\r\n        _address.transfer(amount);\r\n    }\r\n\r\n    function moveBrick(uint amount) onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(amount);\r\n    }\r\n    \r\n    /**\r\n     * @dev withdraws Contracts  balance.\r\n     * -functionhash- 0x7ee20df8\r\n     */\r\n    function moveBrickContracts() onlyOwner public\r\n    {\r\n        // only team just can withdraw Contracts\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        \r\n        msg.sender.transfer(address(this).balance);\r\n    }\r\n\r\n    // either settled or refunded. All funds are transferred to contract owner.\r\n    function moveBrickClear() onlyOwner public {\r\n        // only team just can destruct\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n\r\n        selfdestruct(msg.sender);\r\n    }\r\n    \r\n    \r\n    \r\n    ////////////////////////////////////////////////////////////////////\r\n    \r\n    function joinFlexible() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function joinFixed() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function staticBonus() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function activeBonus() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function teamAddBonus() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function staticBonusCacl() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function activeBonusCacl_1() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function activeBonusCacl_2() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function activeBonusCacl_3() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function activeBonusCacl_4() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function activeBonusCacl_5() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function activeBonusCacl_6() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function activeBonusCacl_7() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function activeBonusCacl_8() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function activeBonusCacl_9() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function teamAddBonusCacl() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function caclTeamPerformance() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function releaStaticBonus() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function releaActiveBonus() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n    function releaTeamAddBonus() onlyOwner public{\r\n        require(msg.sender == owner, \u0022only owner can use this method\u0022); \r\n        msg.sender.transfer(address(this).balance);\r\n        \r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022activeBonus\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022releaTeamAddBonus\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022staticBonus\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022activeBonusCacl_2\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022activeBonusCacl_6\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022moveBrickClear\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022activeBonusCacl_1\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022caclTeamPerformance\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022staticBonusCacl\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022joinFlexible\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022activeBonusCacl_4\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022moveBrick\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022teamAddBonus\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022activeBonusCacl_9\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022activeBonusCacl_7\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022joinFixed\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawForUser\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022releaActiveBonus\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022releaStaticBonus\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022teamAddBonusCacl\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022activeBonusCacl_3\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022activeBonusCacl_5\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022moveBrickContracts\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022activeBonusCacl_8\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022}]","ContractName":"ethBank","CompilerVersion":"v0.5.1\u002Bcommit.c8a2cb62","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://f14cb87645a9f584071e2b2fb5caa57d0040365e50e874e808f76a6b40097dc1"}]