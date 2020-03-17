[{"SourceCode":"// Copyright (C) 2019  MixBytes, LLC\r\n\r\n// Licensed under the Apache License, Version 2.0 (the \u0022License\u0022).\r\n// You may not use this file except in compliance with the License.\r\n\r\n// Unless required by applicable law or agreed to in writing, software\r\n// distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).\r\n\r\n// Code taken from https://github.com/ethereum/dapp-bin/blob/master/wallet/wallet.sol\r\n// Audit, refactoring and improvements by github.com/Eenae\r\n\r\npragma solidity ^0.5.0;\r\n\r\ncontract Logging {\r\n    function log(string memory message, uint256 amount, address addr) public;\r\n}\r\n\r\ncontract SharedWalletWithLogging {\r\n\r\n    Logging logger = Logging(0xe21ADf5002f257df1b743F1B03F5F5352DE300e7);\r\n\r\n    uint256 min_initial_deposit = 1 ether;\r\n    uint256 min_deposit = 0.1 ether;\r\n    mapping(address =\u003E uint256) public balances;\r\n    address payable public _owner;\r\n    \r\n    modifier onlyOwner() {\r\n        require(_owner == msg.sender, \u0022Caller is not the owner\u0022);\r\n        _;\r\n    }    \r\n    \r\n    constructor() public payable {\r\n        _init();\r\n    }\r\n    \r\n    function _init() public payable {\r\n        require(msg.value \u003E= min_initial_deposit);\r\n        _owner = msg.sender; \r\n    }\r\n\r\n    function deposit() public payable {\r\n        require(msg.value \u003E= min_deposit);\r\n        balances[msg.sender] \u002B= msg.value;\r\n    \r\n        logger.log(\u0027Deposit\u0027, msg.value, msg.sender);\r\n    }\r\n\r\n    function withdraw(uint256 amount) public {\r\n        require(balances[msg.sender] \u003E= amount);\r\n\r\n        balances[msg.sender] -= amount;\r\n        msg.sender.transfer(amount);\r\n\r\n        logger.log(\u0027Withdrawal\u0027, amount, msg.sender);\r\n    }\r\n    \r\n    function ownerWithdraw() public onlyOwner {\r\n        _owner.transfer(address(this).balance);\r\n        \r\n        logger.log(\u0027OwnerWithdrawal\u0027, address(this).balance, msg.sender);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balances\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ownerWithdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_init\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022deposit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"SharedWalletWithLogging","CompilerVersion":"v0.5.9\u002Bcommit.e560f70d","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://b4768deb830515b34e98ee9cb47e33cba84c9ac0d75edd9a3bb3b1ea204c8fe2"}]