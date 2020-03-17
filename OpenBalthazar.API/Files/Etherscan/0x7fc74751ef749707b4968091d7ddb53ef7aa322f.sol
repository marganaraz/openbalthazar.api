[{"SourceCode":"{{\r\n  \u0022language\u0022: \u0022Solidity\u0022,\r\n  \u0022settings\u0022: {\r\n    \u0022evmVersion\u0022: \u0022byzantium\u0022,\r\n    \u0022libraries\u0022: {},\r\n    \u0022optimizer\u0022: {\r\n      \u0022enabled\u0022: true,\r\n      \u0022runs\u0022: 200\r\n    },\r\n    \u0022remappings\u0022: [],\r\n    \u0022outputSelection\u0022: {\r\n      \u0022*\u0022: {\r\n        \u0022*\u0022: [\r\n          \u0022evm.bytecode\u0022,\r\n          \u0022evm.deployedBytecode\u0022,\r\n          \u0022abi\u0022\r\n        ]\r\n      }\r\n    }\r\n  },\r\n  \u0022sources\u0022: {\r\n    \u0022/Users/simon/ws/in3/in3-contracts/contracts/BlockhashRegistry.sol\u0022: {\r\n      \u0022keccak256\u0022: \u00220x159b52ca451f045503ca6c10ecbe0b76a0e78212a85e91c5e3c96ddaac315ae7\u0022,\r\n      \u0022content\u0022: \u0022/***********************************************************\\n* This file is part of the Slock.it IoT Layer.             *\\n* The Slock.it IoT Layer contains:                         *\\n*   - USN (Universal Sharing Network)                      *\\n*   - INCUBED (Trustless INcentivized remote Node Network) *\\n************************************************************\\n* Copyright (C) 2016 - 2018 Slock.it GmbH                  *\\n* All Rights Reserved.                                     *\\n************************************************************\\n* You may use, distribute and modify this code under the   *\\n* terms of the license contract you have concluded with    *\\n* Slock.it GmbH.                                           *\\n* For information about liability, maintenance etc. also   *\\n* refer to the contract concluded with Slock.it GmbH.      *\\n************************************************************\\n* For more information, please refer to https://slock.it   *\\n* For questions, please contact info@slock.it              *\\n***********************************************************/\\n\\npragma solidity 0.5.10;\\npragma experimental ABIEncoderV2;\\n\\n\\n/// @title Registry for blockhashes\\ncontract BlockhashRegistry {\\n\\n    /// a new blockhash and its number has been added to the contract\\n    event LogBlockhashAdded(uint indexed blockNr, bytes32 indexed bhash);\\n\\n    /// maps the blocknumber to its blockhash\\n    mapping(uint =\u003E bytes32) public blockhashMapping;\\n\\n    /// constructor, calls snapshot-function when contract get deployed as entry point\\n    /// @dev cannot be deployed in a genesis block\\n    constructor() public {\\n        snapshot();\\n    }\\n\\n    /// @notice searches for an already existing snapshot\\n    /// @param _startNumber the blocknumber to start searching\\n    /// @param _numBlocks the number of blocks to search for\\n    /// @return the closes snapshot of found within the given range, 0 else\\n    function searchForAvailableBlock(uint _startNumber, uint _numBlocks) external view returns (uint) {\\n        uint target = _startNumber \u002B _numBlocks;\\n\\n        require(target \u003C= block.number || target \u003C _startNumber, \\\u0022invalid search\\\u0022);\\n\\n        for (uint i = _startNumber; i \u003C= target; i\u002B\u002B) {\\n            if (blockhashMapping[i] != 0x0) {\\n                return i;\\n            }\\n        }\\n    }\\n\\n    /// @notice starts with a given blocknumber and its header and tries to recreate a (reverse) chain of blocks\\n    /// @notice only usable when the given blocknumber is already in the smart contract\\n    /// @notice it will be checked whether the provided chain is correct by using the reCalculateBlockheaders function\\n    /// @notice if successfull the last blockhash of the header will be added to the smart contract\\n    /// @param _blockNumber the block number to start recreation from\\n    /// @param _blockheaders array with serialized blockheaders in reverse order (youngest -\u003E oldest) =\u003E (e.g. 100, 99, 98)\\n    /// @dev reverts when there is not parent block already stored in the contract\\n    /// @dev reverts when the chain of headers is incorrect\\n    /// @dev function is public due to the usage of a dynamic bytes array (not yet supported for external functions)\\n    function recreateBlockheaders(uint _blockNumber, bytes[] memory _blockheaders) public {\\n        /// we should never fail this assert, as this would mean that we were able to recreate a invalid blockchain\\n        require(_blockNumber \u003E _blockheaders.length, \\\u0022too many blockheaders provided\\\u0022);\\n        require(_blockNumber \u003C block.number, \\\u0022cannot recreate a not yet existing block\\\u0022);\\n\\n        require(_blockheaders.length \u003E 0, \\\u0022no blockheaders provided\\\u0022);\\n\\n        uint bnr = _blockNumber - _blockheaders.length;\\n        require(blockhashMapping[bnr] == 0x0, \\\u0022block already stored\\\u0022);\\n\\n        bytes32 currentBlockhash = blockhashMapping[_blockNumber];\\n        require(currentBlockhash != 0x0, \\\u0022parentBlock is not available\\\u0022);\\n\\n        /// if the blocknumber we want to store is within the last 256 blocks, we use the evm hash\\n        if (bnr \u003E block.number-256) {\\n            saveBlockNumber(bnr);\\n            return;\\n        }\\n\\n        bytes32 calculatedHash = reCalculateBlockheaders(_blockheaders, currentBlockhash, _blockNumber);\\n        require(calculatedHash != 0x0, \\\u0022invalid headers\\\u0022);\\n\\n        blockhashMapping[bnr] = calculatedHash;\\n        emit LogBlockhashAdded(bnr, calculatedHash);\\n    }\\n\\n    /// @notice stores a certain blockhash to the state\\n    /// @param _blockNumber the blocknumber to be stored\\n    /// @dev reverts if the block can\u0027t be found inside the evm\\n    function saveBlockNumber(uint _blockNumber) public {\\n\\n        require(blockhashMapping[_blockNumber] == 0x0, \\\u0022block already stored\\\u0022);\\n\\n        bytes32 bHash = blockhash(_blockNumber);\\n\\n        require(bHash != 0x0, \\\u0022block not available\\\u0022);\\n\\n        blockhashMapping[_blockNumber] = bHash;\\n        emit LogBlockhashAdded(_blockNumber, bHash);\\n    }\\n\\n    /// @notice stores the currentBlock-1 in the smart contract\\n    function snapshot() public {\\n        /// blockhash cannot return the current block, so we use the previous block\\n        saveBlockNumber(block.number-1);\\n    }\\n\\n    /// @notice returns the value from rlp encoded data.\\n    ///         This function is limited to only value up to 32 bytes length!\\n    /// @param _data rlp encoded data\\n    /// @param _offset the offset\\n    /// @return the value\\n    function getRlpUint(bytes memory _data, uint _offset) public pure returns (uint value) {\\n        /// get the byte at offset to figure out the length of the value\\n        uint8 c = uint8(_data[_offset]);\\n\\n        /// we will not accept values above 0xa0, since this would mean we either have a list\\n        /// or we have a value with a length greater 32 bytes\\n        /// for the use cases (getting the blockNumber or difficulty) we can accept these limits.\\n        require(c \u003C 0xa1, \\\u0022lists or long fields are not supported\\\u0022);\\n        if (c \u003C 0x80)  // single byte-item\\n            return uint(c); // value = byte\\n\\n        // length of the value\\n        uint len = c - 0x80;\\n        // we skip the first 32 bytes since they contain the legth and add 1 because this byte contains the length of the value.\\n        uint dataOffset = _offset \u002B 33;\\n\\n        /// check the range\\n        require(_offset \u002B len \u003C= _data.length, \\\u0022invalid offset\\\u0022);\\n\\n        /// we are using assembly because we need to get the value of the next \u0060len\u0060 bytes\\n        /// This is done by copying the bytes in the \\\u0022scratch space\\\u0022 so we can take the first 32 bytes as value afterwards.\\n        // solium-disable-next-line security/no-inline-assembly\\n        assembly { // solhint-disable-line no-inline-assembly\\n            mstore(0x0, 0) // clean memory in the \\\u0022scratch space\\\u0022\\n            mstore(\\n                sub (0x20, len), // we move the position so the first bytes from rlp are the last bytes within the 32 bytes\\n                mload(\\n                    add ( _data, dataOffset ) // load the data from rlp-data\\n                )\\n            )\\n            value:=mload(0x0)\\n        }\\n        return value;\\n    }\\n\\n    /// @notice returns the blockhash and the parent blockhash from the provided blockheader\\n    /// @param _blockheader a serialized (rlp-encoded) blockheader\\n    /// @return the parent blockhash and the keccak256 of the provided blockheader (= the corresponding blockhash)\\n    function getParentAndBlockhash(bytes memory _blockheader) public pure returns (bytes32 parentHash, bytes32 bhash, uint blockNumber) {\\n\\n        /// we need the 1st byte of the blockheader to calculate the position of the parentHash\\n        uint8 first = uint8(_blockheader[0]);\\n\\n        /// calculates the offset\\n        /// by using the 1st byte (usually f9) and substracting f7 to get the start point of the parentHash information\\n        require(first \u003E 0xf7, \\\u0022invalid offset\\\u0022);\\n\\n        /// we also have to add \\\u00222\\\u0022 = 1 byte to it to skip the length-information\\n        uint offset = first - 0xf7 \u002B 2;\\n        require(offset\u002B32 \u003C _blockheader.length, \\\u0022invalid length\\\u0022);\\n\\n        /// we are using assembly because it\u0027s the most efficent way to access the parent blockhash within the rlp-encoded blockheader\\n        // solium-disable-next-line security/no-inline-assembly\\n        assembly { // solhint-disable-line no-inline-assembly\\n            // we load the provided blockheader\\n            // then we add 0x20 (32 bytes) to get to the start of the blockheader\\n            // then we add the offset we calculated\\n            // and load it to the parentHash variable\\n            parentHash :=mload(\\n                add(\\n                    add(\\n                        _blockheader, 0x20\\n                    ), offset)\\n            )\\n        }\\n\\n        // verify parentHash\\n        require(parentHash != 0x0, \\\u0022invalid parentHash\\\u0022);\\n        bhash = keccak256(_blockheader);\\n\\n        // get the blockNumber\\n        // we set the offset to the difficulty field which is fixed since all fields between them have a fixed length.\\n        offset \u002B= 444;\\n\\n        // we get the first byte for the difficulty field ( which is a field with a dynamic length)\\n        // and calculate the length, because the next field is the blockNumber\\n        uint8 c = uint8(_blockheader[offset]);\\n        require(c \u003C 0xa1, \\\u0022lists or long fields are not supported for difficulty\\\u0022);\\n        offset \u002B= c \u003C 0x80 ? 1 : (c - 0x80 \u002B 1);\\n\\n        // we fetch the blockNumber from the calculated offset\\n        blockNumber = getRlpUint(_blockheader, offset);\\n    }\\n\\n    /// @notice starts with a given blockhash and its header and tries to recreate a (reverse) chain of blocks\\n    /// @notice the array of the blockheaders have to be in reverse order (e.g. [100,99,98,97])\\n    /// @param _blockheaders array with serialized blockheaders in reverse order, i.e. from youngest to oldest\\n    /// @param _bHash blockhash of the 1st element of the _blockheaders-array\\n    /// @param _blockNumber blocknumber of the 1st element of the _blockheaders-array. This is only needed to verify the blockheader\\n    /// @return 0x0 if the functions detects a wrong chaining of blocks, blockhash of the last element of the array otherwhise\\n    function reCalculateBlockheaders(bytes[] memory _blockheaders, bytes32 _bHash, uint _blockNumber) public view returns (bytes32 bhash) {\\n\\n        require(_blockheaders.length \u003E 0, \\\u0022no blockheaders provided\\\u0022);\\n        require(_bHash != 0x0, \\\u0022invalid blockhash provided\\\u0022);\\n        bytes32 currentBlockhash = _bHash;\\n        bytes32 calcParent = 0x0;\\n        bytes32 calcBlockhash = 0x0;\\n        uint calcBlockNumber = 0;\\n        uint currentBlockNumber = _blockNumber;\\n\\n        /// save to use for up to 200 blocks, exponential increase of gas-usage afterwards\\n        for (uint i = 0; i \u003C _blockheaders.length; i\u002B\u002B) {\\n            /// we alway need to verify the blockHash and parentHash\\n            /// but in addition we also verify the blockNumber.\\n            /// This is just safety-check in case of detected hash collision which makes it almost impossible\\n            /// to add an invalid header which might create the correct hash.\\n            (calcParent, calcBlockhash, calcBlockNumber) = getParentAndBlockhash(_blockheaders[i]);\\n            if (calcBlockhash != currentBlockhash || calcParent == 0x0 || calcBlockNumber != currentBlockNumber) {\\n                return 0x0;\\n            }\\n\\n            uint currentBlock = block.number \u003E 256 ? block.number : 256;\\n\\n            if (currentBlock - 256 \u003C calcBlockNumber) {\\n                if (calcBlockhash != blockhash(calcBlockNumber)) {\\n                    return 0x0;\\n                }\\n            }\\n            currentBlockhash = calcParent;\\n            currentBlockNumber--;\\n        }\\n\\n        return currentBlockhash;\\n    }\\n}\\n\u0022\r\n    }\r\n  }\r\n}}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_blockNumber\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022saveBlockNumber\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_blockheader\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022getParentAndBlockhash\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022parentHash\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022bhash\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022blockNumber\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_startNumber\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_numBlocks\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022searchForAvailableBlock\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_blockNumber\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_blockheaders\u0022,\u0022type\u0022:\u0022bytes[]\u0022}],\u0022name\u0022:\u0022recreateBlockheaders\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022snapshot\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_blockheaders\u0022,\u0022type\u0022:\u0022bytes[]\u0022},{\u0022name\u0022:\u0022_bHash\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_blockNumber\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022reCalculateBlockheaders\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022bhash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022name\u0022:\u0022_offset\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getRlpUint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022blockhashMapping\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022blockNr\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022bhash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022LogBlockhashAdded\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"BlockhashRegistry","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://3d00ba2dda8befaef333c6948a10d1861f1a2e1a3f5eedaae5333b5f19e11136"}]