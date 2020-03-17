[{"SourceCode":"//www.structuredeth.com/gift\r\n\r\npragma solidity ^0.4.26;\r\n\r\n\r\nlibrary SafeMath {\r\n  function mul(uint256 a, uint256 b) internal constant returns (uint256) {\r\n    uint256 c = a * b;\r\n    assert(a == 0 || c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function div(uint256 a, uint256 b) internal constant returns (uint256) {\r\n    assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    uint256 c = a / b;\r\n    assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return c;\r\n  }\r\n\r\n  function sub(uint256 a, uint256 b) internal constant returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function add(uint256 a, uint256 b) internal constant returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n}\r\n\r\n\r\ncontract GiftOfCompoundRegistry {\r\n    \r\n    using SafeMath for uint256;\r\n    \r\n    uint256 totalGifted;\r\n    mapping (address=\u003Euint256) addresses;\r\n\r\n   \r\n    \r\n    //if smeone sends eth to this contract, throw it because it will just end up getting locked forever\r\n    function() payable {\r\n        throw;\r\n    }\r\n    \r\n    function addGift(address contractAddress, uint256 initialAmount){\r\n        totalGifted = totalGifted.add(initialAmount);\r\n        addresses[contractAddress] = initialAmount;\r\n        \r\n    }\r\n    function totalGiftedAmount()  constant returns (uint256){\r\n        return totalGifted;\r\n    }\r\n    function giftGiven(address theAddress)  constant returns (uint256){\r\n        return addresses[theAddress];\r\n    }\r\n    \r\n    \r\n    \r\n    \r\n\r\n    constructor() public {\r\n        \r\n       \r\n        \r\n    }\r\n    \r\n   \r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalGiftedAmount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022theAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022giftGiven\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022contractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022initialAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022addGift\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022}]","ContractName":"GiftOfCompoundRegistry","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://291896a3433ba41bf9f14ad9ba80a83e8bf9a455703f844f7df0aa8a550d6304"}]