[{"SourceCode":"pragma solidity ^0.5.2;\r\n\r\n// LEE is a digital escrow program in beta. Use at your own risk. || lexDAO ||\r\n\r\ncontract lexDAOetherEscrow {\r\n    \r\n    address payable public buyer;\r\n    address payable public seller;\r\n    address payable public arbitrator;\r\n    uint256 public price;\r\n    string public details;\r\n    string public complaint;\r\n    bool public disputed;\r\n    bool public closed;\r\n    \r\n    event Released(uint256 indexed price);\r\n    event Disputed(address indexed complainant);\r\n    event Resolved(uint256 indexed buyerAward, uint256 indexed sellerAward);\r\n    \r\n    constructor(\r\n        address payable _buyer,\r\n        address payable _seller,\r\n        address payable _arbitrator,\r\n        string memory _details) payable public {\r\n        buyer = _buyer;\r\n        seller = _seller;\r\n        arbitrator = _arbitrator;\r\n        price = msg.value;\r\n        details = _details;\r\n    }\r\n    \r\n    function release() public {\r\n        require(msg.sender == buyer);\r\n        require(disputed == false);\r\n        address(seller).transfer(price);\r\n        closed = true;\r\n        emit Released(price);\r\n    }\r\n    \r\n    function dispute(string memory _complaint) public {\r\n        require(msg.sender == buyer || msg.sender == seller);\r\n        require(closed == false);\r\n        disputed = true;\r\n        complaint = _complaint;\r\n        emit Disputed(msg.sender);\r\n    }\r\n    \r\n    function resolve(uint256 buyerAward, uint256 sellerAward) public {\r\n        require(msg.sender == arbitrator);\r\n        require(disputed == true);\r\n        uint256 arbFee = price / 20;\r\n        require(buyerAward \u002B sellerAward \u002B arbFee == price);\r\n        address(buyer).transfer(buyerAward);\r\n        address(seller).transfer(sellerAward);\r\n        address(arbitrator).transfer(arbFee);\r\n        closed = true;\r\n        emit Resolved(buyerAward, sellerAward);\r\n    }\r\n    \r\n    function getBalance() public view returns (uint256) {\r\n        return address(this).balance;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022disputed\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022seller\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getBalance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022complaint\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_complaint\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022dispute\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022details\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022closed\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022arbitrator\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022buyer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022release\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022price\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022buyerAward\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022sellerAward\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022resolve\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_buyer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_seller\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_arbitrator\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_details\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022price\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Released\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022complainant\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Disputed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022buyerAward\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022sellerAward\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Resolved\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"lexDAOetherEscrow","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"0000000000000000000000001c0aa8ccd568d90d61659f060d1bfb1e6f855a20000000000000000000000000cc4dc8e92a6e30b6f5f6e65156b121d9f83ca18f00000000000000000000000097103fda00a2b47eac669568063c00e65866a6330000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000d67617320726566756e6420796f00000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://f4de98cd9c6a31cf4e4ad6f9ddc0f4dbf6f748b158e43d8cb4b2156c5bd200ec"}]