[{"SourceCode":"// hevm: flattened sources of /nix/store/im7ll7dx8gsw2da9k5xwbf8pbjfli2hc-multicall-df1e59d/src/Multicall.sol\r\npragma solidity \u003E=0.5.0;\r\npragma experimental ABIEncoderV2;\r\n\r\n////// /nix/store/im7ll7dx8gsw2da9k5xwbf8pbjfli2hc-multicall-df1e59d/src/Multicall.sol\r\n/* pragma solidity \u003E=0.5.0; */\r\n/* pragma experimental ABIEncoderV2; */\r\n\r\n/// @title Multicall - Aggregate results from multiple read-only function calls\r\n/// @author Michael Elliot \u003Cmike@makerdao.com\u003E\r\n/// @author Joshua Levine \u003Cjoshua@makerdao.com\u003E\r\n/// @author Nick Johnson \u003Carachnid@notdot.net\u003E\r\n\r\ncontract Multicall {\r\n    struct Call {\r\n        address target;\r\n        bytes callData;\r\n    }\r\n    function aggregate(Call[] memory calls) public returns (uint256 blockNumber, bytes[] memory returnData) {\r\n        blockNumber = block.number;\r\n        returnData = new bytes[](calls.length);\r\n        for(uint256 i = 0; i \u003C calls.length; i\u002B\u002B) {\r\n            (bool success, bytes memory ret) = calls[i].target.call(calls[i].callData);\r\n            require(success);\r\n            returnData[i] = ret;\r\n        }\r\n    }\r\n    // Helper functions\r\n    function getEthBalance(address addr) public view returns (uint256 balance) {\r\n        balance = addr.balance;\r\n    }\r\n    function getBlockHash(uint256 blockNumber) public view returns (bytes32 blockHash) {\r\n        blockHash = blockhash(blockNumber);\r\n    }\r\n    function getLastBlockHash() public view returns (bytes32 blockHash) {\r\n        blockHash = blockhash(block.number - 1);\r\n    }\r\n    function getCurrentBlockTimestamp() public view returns (uint256 timestamp) {\r\n        timestamp = block.timestamp;\r\n    }\r\n    function getCurrentBlockDifficulty() public view returns (uint256 difficulty) {\r\n        difficulty = block.difficulty;\r\n    }\r\n    function getCurrentBlockGasLimit() public view returns (uint256 gaslimit) {\r\n        gaslimit = block.gaslimit;\r\n    }\r\n    function getCurrentBlockCoinbase() public view returns (address coinbase) {\r\n        coinbase = block.coinbase;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022components\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022callData\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022internalType\u0022:\u0022struct Multicall.Call[]\u0022,\u0022name\u0022:\u0022calls\u0022,\u0022type\u0022:\u0022tuple[]\u0022}],\u0022name\u0022:\u0022aggregate\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022blockNumber\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes[]\u0022,\u0022name\u0022:\u0022returnData\u0022,\u0022type\u0022:\u0022bytes[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022blockNumber\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getBlockHash\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022blockHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCurrentBlockCoinbase\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022coinbase\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCurrentBlockDifficulty\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022difficulty\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCurrentBlockGasLimit\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022gaslimit\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCurrentBlockTimestamp\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022timestamp\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getEthBalance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getLastBlockHash\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022blockHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"Multicall","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://fb3b2e82a9c3bb95faba43cc72fc3b76f6ea73b1af9ddeaa3f145e6864b7b5b0"}]