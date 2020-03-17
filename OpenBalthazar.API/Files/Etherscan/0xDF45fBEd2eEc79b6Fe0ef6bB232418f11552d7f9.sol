[{"SourceCode":"pragma solidity ^0.5.8;\r\n\r\n\r\n/*\r\n * @author Hamdi Allam hamdi.allam97@gmail.com\r\n * Please reach out with any questions or concerns\r\n *\r\n * Copyright 2018 Hamdi Allam\r\n *\r\n * Licensed to the Apache Software Foundation (ASF) under one\r\n * or more contributor license agreements.  See the NOTICE file\r\n * distributed with this work for additional information\r\n * regarding copyright ownership.  The ASF licenses this file\r\n * to you under the Apache License, Version 2.0 (the\r\n * \u0022License\u0022); you may not use this file except in compliance\r\n * with the License.  You may obtain a copy of the License at\r\n *\r\n * http://www.apache.org/licenses/LICENSE-2.0\r\n *\r\n * Unless required by applicable law or agreed to in writing,\r\n * software distributed under the License is distributed on an\r\n * \u0022AS IS\u0022 BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY\r\n * KIND, either express or implied.  See the License for the\r\n * specific language governing permissions and limitations\r\n * under the License.\r\n */\r\n\r\n/**\r\n    Taken from https://github.com/hamdiallam/Solidity-RLP/blob/cd39a6a5d9ddc64eb3afedb3b4cda08396c5bfc5/contracts/RLPReader.sol\r\n    with small modifications\r\n */\r\n\r\nlibrary RLPReader {\r\n    uint8 constant STRING_SHORT_START = 0x80;\r\n    uint8 constant STRING_LONG_START = 0xb8;\r\n    uint8 constant LIST_SHORT_START = 0xc0;\r\n    uint8 constant LIST_LONG_START = 0xf8;\r\n\r\n    uint8 constant WORD_SIZE = 32;\r\n\r\n    struct RLPItem {\r\n        uint len;\r\n        uint memPtr;\r\n    }\r\n\r\n    /*\r\n    * @param item RLP encoded bytes\r\n    */\r\n    function toRlpItem(bytes memory item)\r\n        internal\r\n        pure\r\n        returns (RLPItem memory)\r\n    {\r\n        require(item.length \u003E 0);\r\n\r\n        uint memPtr;\r\n        assembly {\r\n            memPtr := add(item, 0x20)\r\n        }\r\n\r\n        return RLPItem(item.length, memPtr);\r\n    }\r\n\r\n    /*\r\n    * @param item RLP encoded bytes\r\n    */\r\n    function rlpLen(RLPItem memory item) internal pure returns (uint) {\r\n        return item.len;\r\n    }\r\n\r\n    /*\r\n    * @param item RLP encoded bytes\r\n    */\r\n    function payloadLen(RLPItem memory item) internal pure returns (uint) {\r\n        return item.len - _payloadOffset(item.memPtr);\r\n    }\r\n\r\n    /*\r\n    * @param item RLP encoded list in bytes\r\n    */\r\n    function toList(RLPItem memory item)\r\n        internal\r\n        pure\r\n        returns (RLPItem[] memory result)\r\n    {\r\n        require(isList(item));\r\n\r\n        uint items = numItems(item);\r\n        result = new RLPItem[](items);\r\n\r\n        uint memPtr = item.memPtr \u002B _payloadOffset(item.memPtr);\r\n        uint dataLen;\r\n        for (uint i = 0; i \u003C items; i\u002B\u002B) {\r\n            dataLen = _itemLength(memPtr);\r\n            result[i] = RLPItem(dataLen, memPtr);\r\n            memPtr = memPtr \u002B dataLen;\r\n        }\r\n    }\r\n\r\n    // @return indicator whether encoded payload is a list. negate this function call for isData.\r\n    function isList(RLPItem memory item) internal pure returns (bool) {\r\n        if (item.len == 0) return false;\r\n\r\n        uint8 byte0;\r\n        uint memPtr = item.memPtr;\r\n        assembly {\r\n            byte0 := byte(0, mload(memPtr))\r\n        }\r\n\r\n        if (byte0 \u003C LIST_SHORT_START) return false;\r\n        return true;\r\n    }\r\n\r\n    /*\r\n    * Private Helpers\r\n    */\r\n\r\n    // @return number of payload items inside an encoded list.\r\n    function numItems(RLPItem memory item) private pure returns (uint) {\r\n        if (item.len == 0) return 0;\r\n\r\n        uint count = 0;\r\n        uint currPtr = item.memPtr \u002B _payloadOffset(item.memPtr);\r\n        uint endPtr = item.memPtr \u002B item.len;\r\n        while (currPtr \u003C endPtr) {\r\n            currPtr = currPtr \u002B _itemLength(currPtr); // skip over an item\r\n            count\u002B\u002B;\r\n        }\r\n\r\n        return count;\r\n    }\r\n\r\n    // @return entire rlp item byte length\r\n    function _itemLength(uint memPtr) private pure returns (uint len) {\r\n        uint byte0;\r\n        assembly {\r\n            byte0 := byte(0, mload(memPtr))\r\n        }\r\n\r\n        if (byte0 \u003C STRING_SHORT_START) return 1;\r\n        else if (byte0 \u003C STRING_LONG_START)\r\n            return byte0 - STRING_SHORT_START \u002B 1;\r\n        else if (byte0 \u003C LIST_SHORT_START) {\r\n            assembly {\r\n                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is\r\n                memPtr := add(memPtr, 1) // skip over the first byte\r\n\r\n                /* 32 byte word size */\r\n                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len\r\n                len := add(dataLen, add(byteLen, 1))\r\n            }\r\n        } else if (byte0 \u003C LIST_LONG_START) {\r\n            return byte0 - LIST_SHORT_START \u002B 1;\r\n        } else {\r\n            assembly {\r\n                let byteLen := sub(byte0, 0xf7)\r\n                memPtr := add(memPtr, 1)\r\n\r\n                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to the correct length\r\n                len := add(dataLen, add(byteLen, 1))\r\n            }\r\n        }\r\n    }\r\n\r\n    // @return number of bytes until the data\r\n    function _payloadOffset(uint memPtr) private pure returns (uint) {\r\n        uint byte0;\r\n        assembly {\r\n            byte0 := byte(0, mload(memPtr))\r\n        }\r\n\r\n        if (byte0 \u003C STRING_SHORT_START) return 0;\r\n        else if (\r\n            byte0 \u003C STRING_LONG_START ||\r\n            (byte0 \u003E= LIST_SHORT_START \u0026\u0026 byte0 \u003C LIST_LONG_START)\r\n        ) return 1;\r\n        else if (byte0 \u003C LIST_SHORT_START)\r\n            // being explicit\r\n            return byte0 - (STRING_LONG_START - 1) \u002B 1;\r\n        else return byte0 - (LIST_LONG_START - 1) \u002B 1;\r\n    }\r\n\r\n    /** RLPItem conversions into data types **/\r\n\r\n    // @returns raw rlp encoding in bytes\r\n    function toRlpBytes(RLPItem memory item)\r\n        internal\r\n        pure\r\n        returns (bytes memory)\r\n    {\r\n        bytes memory result = new bytes(item.len);\r\n        if (result.length == 0) return result;\r\n\r\n        uint ptr;\r\n        assembly {\r\n            ptr := add(0x20, result)\r\n        }\r\n\r\n        copy(item.memPtr, ptr, item.len);\r\n        return result;\r\n    }\r\n\r\n    // any non-zero byte is considered true\r\n    function toBoolean(RLPItem memory item) internal pure returns (bool) {\r\n        require(item.len == 1);\r\n        uint result;\r\n        uint memPtr = item.memPtr;\r\n        assembly {\r\n            result := byte(0, mload(memPtr))\r\n        }\r\n\r\n        return result == 0 ? false : true;\r\n    }\r\n\r\n    function toAddress(RLPItem memory item) internal pure returns (address) {\r\n        // 1 byte for the length prefix\r\n        require(item.len == 21);\r\n\r\n        return address(toUint(item));\r\n    }\r\n\r\n    function toUint(RLPItem memory item) internal pure returns (uint) {\r\n        require(item.len \u003E 0 \u0026\u0026 item.len \u003C= 33);\r\n\r\n        uint offset = _payloadOffset(item.memPtr);\r\n        uint len = item.len - offset;\r\n\r\n        uint result;\r\n        uint memPtr = item.memPtr \u002B offset;\r\n        assembly {\r\n            result := mload(memPtr)\r\n\r\n            // shift to the correct location if neccesary\r\n            if lt(len, 32) {\r\n                result := div(result, exp(256, sub(32, len)))\r\n            }\r\n        }\r\n\r\n        return result;\r\n    }\r\n\r\n    // enforces 32 byte length\r\n    function toUintStrict(RLPItem memory item) internal pure returns (uint) {\r\n        // one byte prefix\r\n        require(item.len == 33);\r\n\r\n        uint result;\r\n        uint memPtr = item.memPtr \u002B 1;\r\n        assembly {\r\n            result := mload(memPtr)\r\n        }\r\n\r\n        return result;\r\n    }\r\n\r\n    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {\r\n        require(item.len \u003E 0);\r\n\r\n        uint offset = _payloadOffset(item.memPtr);\r\n        uint len = item.len - offset; // data length\r\n        bytes memory result = new bytes(len);\r\n\r\n        uint destPtr;\r\n        assembly {\r\n            destPtr := add(0x20, result)\r\n        }\r\n\r\n        copy(item.memPtr \u002B offset, destPtr, len);\r\n        return result;\r\n    }\r\n    /*\r\n    * @param src Pointer to source\r\n    * @param dest Pointer to destination\r\n    * @param len Amount of memory to copy from the source\r\n    */\r\n    function copy(uint src, uint dest, uint len) private pure {\r\n        if (len == 0) return;\r\n\r\n        // copy as many word sizes as possible\r\n        for (; len \u003E= WORD_SIZE; len -= WORD_SIZE) {\r\n            assembly {\r\n                mstore(dest, mload(src))\r\n            }\r\n\r\n            src \u002B= WORD_SIZE;\r\n            dest \u002B= WORD_SIZE;\r\n        }\r\n\r\n        // left over bytes. Mask is used to remove unwanted bytes from the word\r\n        uint mask = 256 ** (WORD_SIZE - len) - 1;\r\n        assembly {\r\n            let srcpart := and(mload(src), not(mask)) // zero out src\r\n            let destpart := and(mload(dest), mask) // retrieve the bytes\r\n            mstore(dest, or(destpart, srcpart))\r\n        }\r\n    }\r\n}\r\n\r\n/**\r\n * @title Elliptic curve signature operations\r\n * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d\r\n * TODO Remove this library once solidity supports passing a signature to ecrecover.\r\n * See https://github.com/ethereum/solidity/issues/864\r\n */\r\n\r\nlibrary ECDSA {\r\n    /**\r\n     * @dev Recover signer address from a message by using their signature\r\n     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.\r\n     * @param signature bytes signature, the signature is generated using web3.eth.sign()\r\n     */\r\n    function recover(bytes32 hash, bytes memory signature)\r\n        internal\r\n        pure\r\n        returns (address)\r\n    {\r\n        bytes32 r;\r\n        bytes32 s;\r\n        uint8 v;\r\n\r\n        // Check the signature length\r\n        if (signature.length != 65) {\r\n            return (address(0));\r\n        }\r\n\r\n        // Divide the signature in r, s and v variables\r\n        // ecrecover takes the signature parameters, and the only way to get them\r\n        // currently is to use assembly.\r\n        // solium-disable-next-line security/no-inline-assembly\r\n        assembly {\r\n            r := mload(add(signature, 0x20))\r\n            s := mload(add(signature, 0x40))\r\n            v := byte(0, mload(add(signature, 0x60)))\r\n        }\r\n\r\n        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions\r\n        if (v \u003C 27) {\r\n            v \u002B= 27;\r\n        }\r\n\r\n        // If the version is correct return the signer address\r\n        if (v != 27 \u0026\u0026 v != 28) {\r\n            return (address(0));\r\n        } else {\r\n            // solium-disable-next-line arg-overflow\r\n            return ecrecover(hash, v, r, s);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * toEthSignedMessageHash\r\n     * @dev prefix a bytes32 value with \u0022\\x19Ethereum Signed Message:\u0022\r\n     * and hash the result\r\n     */\r\n    function toEthSignedMessageHash(bytes32 hash)\r\n        internal\r\n        pure\r\n        returns (bytes32)\r\n    {\r\n        // 32 is the length in bytes of hash,\r\n        // enforced by the type signature above\r\n        return\r\n            keccak256(\r\n                abi.encodePacked(\u0022\\x19Ethereum Signed Message:\\n32\u0022, hash)\r\n            );\r\n    }\r\n}\r\n\r\n/**\r\n * Utilities to verify equivocating behavior of validators.\r\n */\r\nlibrary EquivocationInspector {\r\n    using RLPReader for RLPReader.RLPItem;\r\n    using RLPReader for bytes;\r\n\r\n    uint constant STEP_DURATION = 5;\r\n\r\n    /**\r\n     * Get the signer address for a given signature and the related data.\r\n     *\r\n     * @dev Used as abstraction layer to the ECDSA library.\r\n     *\r\n     * @param _data       the data the signature is for\r\n     * @param _signature  the signature the address should be recovered from\r\n     */\r\n    function getSignerAddress(bytes memory _data, bytes memory _signature)\r\n        internal\r\n        pure\r\n        returns (address)\r\n    {\r\n        bytes32 hash = keccak256(_data);\r\n        return ECDSA.recover(hash, _signature);\r\n    }\r\n\r\n    /**\r\n     * Verify malicious behavior of an authority.\r\n     * Prove the presence of equivocation by two given blocks.\r\n     * Equivocation is proven by:\r\n     *    - two different blocks have been provided\r\n     *    - both signatures have been issued by the same address\r\n     *    - the step of both blocks is the same\r\n     *\r\n     * Block headers provided as arguments do not include their signature within.\r\n     * By design this is expected to be the source that has been signed.\r\n     *\r\n     * The function fails if the proof can not be verified.\r\n     * In case the proof can be verified, the function returns nothing.\r\n     *\r\n     * @dev Implement the rules of an equivocation.\r\n     *\r\n     * @param _rlpUnsignedHeaderOne   the RLP encoded header of the first block\r\n     * @param _signatureOne           the signature related to the first block\r\n     * @param _rlpUnsignedHeaderTwo   the RLP encoded header of the second block\r\n     * @param _signatureTwo           the signature related to the second block\r\n     */\r\n    function verifyEquivocationProof(\r\n        bytes memory _rlpUnsignedHeaderOne,\r\n        bytes memory _signatureOne,\r\n        bytes memory _rlpUnsignedHeaderTwo,\r\n        bytes memory _signatureTwo\r\n    ) internal pure {\r\n        // Make sure two different blocks have been provided.\r\n        bytes32 hashOne = keccak256(_rlpUnsignedHeaderOne);\r\n        bytes32 hashTwo = keccak256(_rlpUnsignedHeaderTwo);\r\n\r\n        // Different block rule.\r\n        require(\r\n            hashOne != hashTwo,\r\n            \u0022Equivocation can be proved for two different blocks only.\u0022\r\n        );\r\n\r\n        // Parse the RLP encoded block header list.\r\n        // Note that this can fail here, if the block header has no list format.\r\n        RLPReader.RLPItem[] memory blockOne = _rlpUnsignedHeaderOne\r\n            .toRlpItem()\r\n            .toList();\r\n        RLPReader.RLPItem[] memory blockTwo = _rlpUnsignedHeaderTwo\r\n            .toRlpItem()\r\n            .toList();\r\n\r\n        // Header length rule.\r\n        // Keep it open ended, since they could contain a list of empty messages for finality.\r\n        require(\r\n            blockOne.length \u003E= 12 \u0026\u0026 blockTwo.length \u003E= 12,\r\n            \u0022The number of provided header entries are not enough.\u0022\r\n        );\r\n\r\n        // Equal signer rule.\r\n        require(\r\n            getSignerAddress(_rlpUnsignedHeaderOne, _signatureOne) ==\r\n                getSignerAddress(_rlpUnsignedHeaderTwo, _signatureTwo),\r\n            \u0022The two blocks have been signed by different identities.\u0022\r\n        );\r\n\r\n        // Equal block step rule.\r\n        uint stepOne = blockOne[11].toUint() / STEP_DURATION;\r\n        uint stepTwo = blockTwo[11].toUint() / STEP_DURATION;\r\n\r\n        require(stepOne == stepTwo, \u0022The two blocks have different steps.\u0022);\r\n    }\r\n\r\n}\r\n\r\ncontract Ownable {\r\n    address public owner;\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    modifier onlyOwner() {\r\n        require(\r\n            msg.sender == owner,\r\n            \u0022The function can only be called by the owner\u0022\r\n        );\r\n        _;\r\n    }\r\n\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        if (newOwner != address(0)) {\r\n            owner = newOwner;\r\n        }\r\n    }\r\n}\r\n\r\ncontract DepositLockerInterface {\r\n    function slash(address _depositorToBeSlashed) public;\r\n\r\n}\r\n\r\ncontract ValidatorSlasher is Ownable {\r\n    bool public initialized = false;\r\n    DepositLockerInterface public depositContract;\r\n\r\n    function() external {}\r\n\r\n    function init(address _depositContractAddress) external onlyOwner {\r\n        require(!initialized, \u0022The contract is already initialized.\u0022);\r\n\r\n        depositContract = DepositLockerInterface(_depositContractAddress);\r\n\r\n        initialized = true;\r\n    }\r\n\r\n    /**\r\n     * Report a malicious validator for having equivocated.\r\n     * The reporter must provide the both blocks with their related signature.\r\n     * By the given blocks, the equivocation will be verified.\r\n     * In case a equivocation could been proven, the issuer of the blocks get\r\n     * removed from the set of validators, if his address is registered. Also\r\n     * his deposit will be slashed afterwards.\r\n     * In case any check before removing the malicious validator fails, the\r\n     * whole report procedure fails due to that.\r\n     *\r\n     * @param _rlpUnsignedHeaderOne   the RLP encoded header of the first block\r\n     * @param _signatureOne           the signature related to the first block\r\n     * @param _rlpUnsignedHeaderTwo   the RLP encoded header of the second block\r\n     * @param _signatureTwo           the signature related to the second block\r\n     */\r\n    function reportMaliciousValidator(\r\n        bytes calldata _rlpUnsignedHeaderOne,\r\n        bytes calldata _signatureOne,\r\n        bytes calldata _rlpUnsignedHeaderTwo,\r\n        bytes calldata _signatureTwo\r\n    ) external {\r\n        EquivocationInspector.verifyEquivocationProof(\r\n            _rlpUnsignedHeaderOne,\r\n            _signatureOne,\r\n            _rlpUnsignedHeaderTwo,\r\n            _signatureTwo\r\n        );\r\n\r\n        // Since the proof has already verified, that both blocks have been\r\n        // issued by the same validator, it doesn\u0027t matter which one is used here\r\n        // to recover the address.\r\n        address validator = EquivocationInspector.getSignerAddress(\r\n            _rlpUnsignedHeaderOne,\r\n            _signatureOne\r\n        );\r\n\r\n        depositContract.slash(validator);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022initialized\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_depositContractAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022init\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_rlpUnsignedHeaderOne\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022name\u0022:\u0022_signatureOne\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022name\u0022:\u0022_rlpUnsignedHeaderTwo\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022name\u0022:\u0022_signatureTwo\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022reportMaliciousValidator\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022depositContract\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022fallback\u0022}]","ContractName":"ValidatorSlasher","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"1","Runs":"100","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://b81d490eab67d42ab6a48a9d802214c8ac697e8810684beb1539095c234af527"}]