[{"SourceCode":"/*\r\n Hashed time lock Contract ERC20 Token        \r\n*/\r\npragma solidity ^0.4.18;\r\n\r\n     //here we declare the function that we need for the token swap as an interface \r\n\r\n      contract ERC20 {\r\n      \r\n     function balanceOf(address _who )public view returns (uint256 balance);\r\n      function transfer(address _to, uint256 _value) public;\r\n         \r\n    \r\n    \r\n}\r\n\r\ncontract HTLC_ERC20_Token {\r\n          \r\n  uint public timeLock = now \u002B 200;     //here we set the time lock (using Unix timestamp)\r\n  address owner = msg.sender;           //owner of the contract                  \r\n  bytes32 public sha256_hashed_secret =0x863BBA74EA78B2B913311420656DEDF7603A07FF65EBF0AEB9F15BF27A698838; //hashed secret\r\n\r\n  ERC20 Your_token= ERC20(0x22a39C2DD54b71aC884657bb3e37308ABe2D02E1);  /* here we create an instance \r\n                                                            of the token using its adress to be able \r\n                                                            to interact with the contract and call its functions\r\n                                                         */\r\n                                                        \r\n\r\n  //here we make sure that only the owner can refund his tokens\r\n  modifier onlyOwner{require(msg.sender == owner); _; }\r\n\r\n\r\n  //here you claim the tokens\r\n    function claim(string _secret) public returns(bool result) {\r\n\r\n       require(sha256_hashed_secret == sha256(_secret)); //secret verification\r\n       require(msg.sender!=owner);                //verify that the claimer isn\u0027t the owner                 \r\n       uint256 allbalance=Your_token.balanceOf(address(this));// get the tokens that are locked in this HTLC\r\n       Your_token.transfer(msg.sender,allbalance);//transfer the tokens to the claimer \r\n       selfdestruct(owner);\r\n       return true;\r\n      \r\n       }\r\n    \r\n    \r\n    \r\n       //here the owner can refound the token when the timeout is expired \r\n        function refund() onlyOwner public returns(bool result) {\r\n        require(now \u003E= timeLock);\r\n        uint256 allbalance=Your_token.balanceOf(address(this)); \r\n        Your_token.transfer(owner,allbalance);\r\n        selfdestruct(owner);\r\n     \r\n        return true;\r\n      \r\n        }\r\n     \r\n    \r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022refund\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022result\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sha256_hashed_secret\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022timeLock\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_secret\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022claim\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022result\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"HTLC_ERC20_Token","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://cb002033ae36986d8e1fda706717777a10786838c72a08678dbb117a02d955ff"}]