[{"SourceCode":"pragma solidity \u003E=0.5.0 \u003C0.7.0;\r\n\r\n\r\n/// @title Multi Send - Allows to batch multiple transactions into one.\r\n/// @author Nick Dodson - \u003Cnick.dodson@consensys.net\u003E\r\n/// @author Gon\u00E7alo S\u00E1 - \u003Cgoncalo.sa@consensys.net\u003E\r\n/// @author Stefan George - \u003Cstefan@gnosis.io\u003E\r\n/// @author Richard Meissner - \u003Crichard@gnosis.io\u003E\r\ncontract MultiSend {\r\n\r\n    bytes32 constant private GUARD_VALUE = keccak256(\u0022multisend.guard.bytes32\u0022);\r\n\r\n    bytes32 guard;\r\n\r\n    constructor() public {\r\n        guard = GUARD_VALUE;\r\n    }\r\n\r\n    /// @dev Sends multiple transactions and reverts all if one fails.\r\n    /// @param transactions Encoded transactions. Each transaction is encoded as a packed bytes of\r\n    ///                     operation as a uint8 with 0 for a call or 1 for a delegatecall (=\u003E 1 byte),\r\n    ///                     to as a address (=\u003E 20 bytes),\r\n    ///                     value as a uint256 (=\u003E 32 bytes),\r\n    ///                     data length as a uint256 (=\u003E 32 bytes),\r\n    ///                     data as bytes.\r\n    ///                     see abi.encodePacked for more information on packed encoding\r\n    function multiSend(bytes memory transactions)\r\n        public\r\n    {\r\n        require(guard != GUARD_VALUE, \u0022MultiSend should only be called via delegatecall\u0022);\r\n        // solium-disable-next-line security/no-inline-assembly\r\n        assembly {\r\n            let length := mload(transactions)\r\n            let i := 0x20\r\n            for { } lt(i, length) { } {\r\n                // First byte of the data is the operation.\r\n                // We shift by 248 bits (256 - 8 [operation byte]) it right since mload will always load 32 bytes (a word).\r\n                // This will also zero out unused data.\r\n                let operation := shr(0xf8, mload(add(transactions, i)))\r\n                // We offset the load address by 1 byte (operation byte)\r\n                // We shift it right by 96 bits (256 - 160 [20 address bytes]) to right-align the data and zero out unused data.\r\n                let to := shr(0x60, mload(add(transactions, add(i, 0x01))))\r\n                // We offset the load address by 21 byte (operation byte \u002B 20 address bytes)\r\n                let value := mload(add(transactions, add(i, 0x15)))\r\n                // We offset the load address by 53 byte (operation byte \u002B 20 address bytes \u002B 32 value bytes)\r\n                let dataLength := mload(add(transactions, add(i, 0x35)))\r\n                // We offset the load address by 85 byte (operation byte \u002B 20 address bytes \u002B 32 value bytes \u002B 32 data length bytes)\r\n                let data := add(transactions, add(i, 0x55))\r\n                let success := 0\r\n                switch operation\r\n                case 0 { success := call(gas, to, value, data, dataLength, 0, 0) }\r\n                case 1 { success := delegatecall(gas, to, data, dataLength, 0, 0) }\r\n                if eq(success, 0) { revert(0, 0) }\r\n                // Next entry starts at 85 byte \u002B data length\r\n                i := add(i, add(0x55, dataLength))\r\n            }\r\n        }\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022transactions\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022multiSend\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"MultiSend","CompilerVersion":"v0.5.14\u002Bcommit.1f1aaa4","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://70e31d7e2b8deef68f8407778b9a272b991540a320ad488b6de31c17790f348a"}]