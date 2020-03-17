[{"SourceCode":"// File: contracts/common/Signatures.sol\r\n\r\n/**\r\n * Copyright 2017\u20132019, LaborX PTY\r\n * Licensed under the AGPL Version 3 license.\r\n */\r\n\r\npragma solidity ^0.4.25;\r\n\r\n\r\nlibrary Signatures {\r\n\r\n    bytes constant internal SIGNATURE_PREFIX = \u0022\\x19Ethereum Signed Message:\\n32\u0022;\r\n    uint constant internal SIGNATURE_LENGTH = 65;\r\n\r\n    function getSignerFromSignature(bytes32 _message, bytes _signature)\r\n    public\r\n    pure\r\n    returns (address)\r\n    {\r\n        bytes32 r;\r\n        bytes32 s;\r\n        uint8 v;\r\n\r\n        if (_signature.length != SIGNATURE_LENGTH) {\r\n            return 0;\r\n        }\r\n\r\n        assembly {\r\n            r := mload(add(_signature, 32))\r\n            s := mload(add(_signature, 64))\r\n            v := and(mload(add(_signature, 65)), 255)\r\n        }\r\n\r\n        if (v \u003C 27) {\r\n            v \u002B= 27;\r\n        }\r\n\r\n        return ecrecover(\r\n            keccak256(abi.encodePacked(SIGNATURE_PREFIX, _message)),\r\n            v,\r\n            r,\r\n            s\r\n        );\r\n    }\r\n\r\n    /// @notice Get signers from signatures byte array.\r\n    /// @param _message message hash\r\n    /// @param _signatures signatures\r\n    /// @return addresses of signers\r\n    function getSignersFromSignatures(bytes32 _message, bytes _signatures)\r\n    public\r\n    pure\r\n    returns (address[] memory _addresses)\r\n    {\r\n        require(validSignaturesLength(_signatures), \u0022SIGNATURES_SHOULD_HAVE_CORRECT_LENGTH\u0022);\r\n        _addresses = new address[](numSignatures(_signatures));\r\n        for (uint i = 0; i \u003C _addresses.length; i\u002B\u002B) {\r\n            _addresses[i] = getSignerFromSignature(_message, signatureAt(_signatures, i));\r\n        }\r\n    }\r\n\r\n    function numSignatures(bytes _signatures)\r\n    private\r\n    pure\r\n    returns (uint256)\r\n    {\r\n        return _signatures.length / SIGNATURE_LENGTH;\r\n    }\r\n\r\n    function validSignaturesLength(bytes _signatures)\r\n    internal\r\n    pure\r\n    returns (bool)\r\n    {\r\n        return (_signatures.length % SIGNATURE_LENGTH) == 0;\r\n    }\r\n\r\n    function signatureAt(bytes _signatures, uint position)\r\n    private\r\n    pure\r\n    returns (bytes)\r\n    {\r\n        return slice(_signatures, position * SIGNATURE_LENGTH, SIGNATURE_LENGTH);\r\n    }\r\n\r\n    function bytesToBytes4(bytes memory source)\r\n    private\r\n    pure\r\n    returns (bytes4 output) {\r\n        if (source.length == 0) {\r\n            return 0x0;\r\n        }\r\n        assembly {\r\n            output := mload(add(source, 4))\r\n        }\r\n    }\r\n\r\n    function slice(bytes _bytes, uint _start, uint _length)\r\n    private\r\n    pure\r\n    returns (bytes)\r\n    {\r\n        require(_bytes.length \u003E= (_start \u002B _length), \u0022SIGNATURES_SLICE_SIZE_SHOULD_NOT_OVERTAKE_BYTES_LENGTH\u0022);\r\n\r\n        bytes memory tempBytes;\r\n\r\n        assembly {\r\n            switch iszero(_length)\r\n            case 0 {\r\n                // Get a location of some free memory and store it in tempBytes as\r\n                // Solidity does for memory variables.\r\n                tempBytes := mload(0x40)\r\n\r\n                // The first word of the slice result is potentially a partial\r\n                // word read from the original array. To read it, we calculate\r\n                // the length of that partial word and start copying that many\r\n                // bytes into the array. The first word we copy will start with\r\n                // data we don\u0027t care about, but the last \u0060lengthmod\u0060 bytes will\r\n                // land at the beginning of the contents of the new array. When\r\n                // we\u0027re done copying, we overwrite the full first word with\r\n                // the actual length of the slice.\r\n                let lengthmod := and(_length, 31)\r\n\r\n                // The multiplication in the next line is necessary\r\n                // because when slicing multiples of 32 bytes (lengthmod == 0)\r\n                // the following copy loop was copying the origin\u0027s length\r\n                // and then ending prematurely not copying everything it should.\r\n                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))\r\n                let end := add(mc, _length)\r\n\r\n                for {\r\n                    // The multiplication in the next line has the same exact purpose\r\n                    // as the one above.\r\n                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)\r\n                } lt(mc, end) {\r\n                    mc := add(mc, 0x20)\r\n                    cc := add(cc, 0x20)\r\n                } {\r\n                    mstore(mc, mload(cc))\r\n                }\r\n\r\n                mstore(tempBytes, _length)\r\n\r\n                //update free-memory pointer\r\n                //allocating the array padded to 32 bytes like the compiler does now\r\n                mstore(0x40, and(add(mc, 31), not(31)))\r\n            }\r\n            //if we want a zero-length slice let\u0027s just return a zero-length array\r\n            default {\r\n                tempBytes := mload(0x40)\r\n\r\n                mstore(0x40, add(tempBytes, 0x20))\r\n            }\r\n        }\r\n\r\n        return tempBytes;\r\n    }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_message\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_signature\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022getSignerFromSignature\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_message\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_signatures\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022getSignersFromSignatures\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_addresses\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"Signatures","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://210994b0013221dab47346ec9f19ce1558853971ac430b0f64584f296af6c5fa"}]