[{"SourceCode":"pragma solidity ^0.5.16;\r\n    //This is the official Happy Face Place.\r\n    //You can send ChainFaces to this contract, but nobody will ever be able to retrieve them.\r\n    //No, not even Zoma\r\n\r\ncontract ChainFaces{\r\n    //Come to the Happy Face Place my beautiful children \u003C3\r\n    function createFace(uint256 seed) public payable {}\r\n}\r\n\r\ncontract IERC721Receiver {\r\n    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4);\r\n}\r\n\r\ncontract HappyFacePlace is IERC721Receiver{\r\n    \r\n    address natealex;\r\n    \r\n    uint previousBlockNumber;\r\n    \r\n    uint totalAscended = 0;\r\n    \r\n    ChainFaces chainFaces;\r\n    \r\n    modifier ZomaNotAllowed {\r\n        require(msg.sender == natealex);\r\n        _;\r\n    }\r\n    \r\n    constructor () public{\r\n        natealex = msg.sender;\r\n        chainFaces = ChainFaces(0x91047Abf3cAb8da5A9515c8750Ab33B4f1560a7A);\r\n    }\r\n    \r\n    function MintAFaceForTheHappyPlace() public ZomaNotAllowed{\r\n        //A Block a Face keeps the Faces Happy\r\n        require(previousBlockNumber \u003C block.number,\u0022Each block deserves a Face in the Happy Face Place.\u0022);\r\n        require(address(this).balance \u003E 20 finney, \u0022Any amount of Eth is worth eternal pleasure.\u0022);\r\n        previousBlockNumber = block.number-10; //Lets not get too crazy in here loves\r\n        \r\n        //Come home to papa\r\n        chainFaces.createFace.value(14 finney)(4206969);\r\n        \r\n        totalAscended\u002B\u002B;\r\n    }\r\n    \r\n    function UseDifferentAddress(address addr) public ZomaNotAllowed{\r\n        natealex = addr;\r\n    }\r\n    \r\n    function AddEth() public payable{\r\n        //Zoma you can use this one if you like \u003E.\u003E\r\n        require(msg.value \u003E 0 wei);\r\n    }\r\n    \r\n    function SubWei(uint weiAmt) public ZomaNotAllowed{\r\n        msg.sender.transfer(weiAmt);\r\n    }\r\n    function EmptyEth() public ZomaNotAllowed{\r\n        msg.sender.transfer(address(this).balance);\r\n    }\r\n    function GetTotalAscended() external view returns(uint){\r\n        return totalAscended;\r\n    }\r\n    //IERC721Receiver implementation\r\n    function onERC721Received(address, address, uint256, bytes memory) public returns (bytes4) {\r\n        return this.onERC721Received.selector;\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022AddEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022EmptyEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022GetTotalAscended\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MintAFaceForTheHappyPlace\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022weiAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022SubWei\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022UseDifferentAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022onERC721Received\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes4\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes4\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"HappyFacePlace","CompilerVersion":"v0.5.16\u002Bcommit.9c3226ce","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://542107d0553199f7823d5b2a6ac324429dad8ab1156849fc8377b64b1123e9a2"}]