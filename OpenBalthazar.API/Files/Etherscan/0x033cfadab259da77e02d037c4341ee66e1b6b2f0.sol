[{"SourceCode":"pragma solidity ^0.5.7;\r\n\r\ncontract ERC20Interface {\r\n\r\n    function totalSupply() public view returns (uint);\r\n\r\n    function balanceOf(address tokenOwner) public view returns (uint balance);\r\n\r\n    function allowance(address tokenOwner, address spender) public view returns (uint remaining);\r\n\r\n    function transfer(address to, uint tokens) public returns (bool success);\r\n\r\n    function approve(address spender, uint tokens) public returns (bool success);\r\n\r\n    function transferFrom(address from, address to, uint tokens) public returns (bool success);\r\n\r\n\r\n    event Transfer(address indexed from, address indexed to, uint tokens);\r\n\r\n    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);\r\n\r\n}\r\n\r\ncontract GX_Team_Funds {\r\n    address public gxt_address = 0x60c87297A1fEaDC3C25993FfcadC54e99971e307;\r\n    string public gxt_allocation = \u0022GXT Team Funds\u0022;\r\n    \r\n    constructor (address _controller) public {\r\n        ERC20Interface token = ERC20Interface(gxt_address);\r\n        token.approve(_controller, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);\r\n    }\r\n\r\n     function getBalance() public view returns(uint256 balance){\r\n        ERC20Interface token = ERC20Interface(gxt_address);\r\n\r\n        return token.balanceOf(address(this));\r\n    }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022gxt_address\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022gxt_allocation\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_controller\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"GX_Team_Funds","CompilerVersion":"v0.5.7\u002Bcommit.6da8b019","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000008cc80d4b048f144fd6c6780d363153af65ccc43f","Library":"","SwarmSource":"bzzr://d1c014c2f995c9ed988081993feb1fc4f55c103393f293c76f6e7cd6437c1d2e"}]