[{"SourceCode":"/**\r\n *  @authors: [@mtsalenc]\r\n *  @reviewers: []\r\n *  @auditors: []\r\n *  @bounties: []\r\n *  @deployments: []\r\n */\r\n\r\npragma solidity 0.5.11;\r\npragma experimental ABIEncoderV2;\r\n\r\ninterface IArbitrableTokenList {\r\n    \r\n    enum TokenStatus {\r\n        Absent, // The token is not in the registry.\r\n        Registered, // The token is in the registry.\r\n        RegistrationRequested, // The token has a request to be added to the registry.\r\n        ClearingRequested // The token has a request to be removed from the registry.\r\n    }\r\n    \r\n    function getTokenInfo(bytes32) external view returns (string memory, string memory, address, string memory, TokenStatus, uint);\r\n    function queryTokens(bytes32 _cursor, uint _count, bool[8] calldata _filter, bool _oldestFirst, address _tokenAddr)\r\n        external\r\n        view\r\n        returns (bytes32[] memory values, bool hasMore);\r\n    function tokenCount() external view returns (uint);\r\n    function addressToSubmissions(address _addr, uint _index) external view returns (bytes32);\r\n}\r\n\r\n\r\n/** @title TokensView\r\n *  Utility view contract to fetch multiple token information at once.\r\n */\r\ncontract TokensView {\r\n    \r\n    struct Token {\r\n        bytes32 ID;\r\n        string name;\r\n        string ticker;\r\n        address addr;\r\n        string symbolMultihash;\r\n        IArbitrableTokenList.TokenStatus status;\r\n        uint decimals;\r\n    }\r\n    \r\n    /** @dev Fetch token IDs of the first tokens present on the tcr for the addresses.\r\n     *  @param _t2crAddress The address of the t2cr contract from where to fetch token information.\r\n     *  @param _tokenAddresses The address of each token.\r\n     */\r\n    function getTokensIDsForAddresses(\r\n        address _t2crAddress, \r\n        address[] calldata _tokenAddresses\r\n    ) external view returns (bytes32[] memory result) {\r\n        IArbitrableTokenList t2cr = IArbitrableTokenList(_t2crAddress);\r\n        result = new bytes32[](_tokenAddresses.length);\r\n        bytes32 ZERO_ID = 0x0000000000000000000000000000000000000000000000000000000000000000;\r\n        for (uint i = 0; i \u003C _tokenAddresses.length;  i\u002B\u002B){\r\n            // Detect how many submissions were made for an address.\r\n            address tokenAddr = _tokenAddresses[i];\r\n            bool success;\r\n            bytes4 sig = bytes4(keccak256(\u0022addressToSubmissions(address,uint256)\u0022));\r\n            uint submissions = 0;\r\n            while(success) {\r\n                assembly {\r\n                    let x := mload(0x40)   // Find empty storage location using \u0022free memory pointer\u0022\r\n                    mstore(x, sig)         // Set the signature to the first call parameter. \r\n                    mstore(add(x, 0x04), tokenAddr)\r\n                    mstore(add(x, 0x24), submissions)\r\n                    success := staticcall(\r\n                        30000,              // 30k gas\r\n                        _t2crAddress,       // The call target.\r\n                        x,                  // Inputs are stored at location x\r\n                        0x44,               // Input is 44 bytes long (signature (4B) \u002B address (20B) \u002B index(20B))\r\n                        x,                  // Overwrite x with output\r\n                        0x20                // The output length\r\n                    )\r\n                }\r\n                \r\n                if (success) {\r\n                    submissions\u002B\u002B;\r\n                }\r\n            }\r\n            \r\n            // Search for the oldest submission currently in the registry.\r\n            for(uint j = 0; j \u003C submissions; j\u002B\u002B) {\r\n                bytes32 tokenID = t2cr.addressToSubmissions(tokenAddr, j);\r\n                (,,,,IArbitrableTokenList.TokenStatus status,) = t2cr.getTokenInfo(tokenID);\r\n                if (status == IArbitrableTokenList.TokenStatus.Registered || status == IArbitrableTokenList.TokenStatus.ClearingRequested) \r\n                {\r\n                    result[i] = tokenID;\r\n                    break;\r\n                }\r\n            }\r\n        }\r\n    }\r\n    \r\n    /** @dev Fetch up token information with token IDs. If a token contract does not implement the decimals() function, its decimals field will be 0.\r\n     *  @param _t2crAddress The address of the t2cr contract from where to fetch token information.\r\n     *  @param _tokenIDs The IDs of the tokens we want to query.\r\n     *  @return tokens The tokens information.\r\n     */\r\n    function getTokens(address _t2crAddress, bytes32[] calldata _tokenIDs) \r\n        external \r\n        view \r\n        returns (Token[] memory tokens)\r\n    {\r\n        IArbitrableTokenList t2cr = IArbitrableTokenList(_t2crAddress);\r\n        tokens = new Token[](_tokenIDs.length);\r\n        for (uint i = 0; i \u003C _tokenIDs.length ; i\u002B\u002B){\r\n            string[] memory strings = new string[](3); // name, ticker and symbolMultihash respectively.\r\n            address tokenAddress;\r\n            IArbitrableTokenList.TokenStatus status;\r\n            (\r\n                strings[0], \r\n                strings[1], \r\n                tokenAddress, \r\n                strings[2], \r\n                status, \r\n            ) = t2cr.getTokenInfo(_tokenIDs[i]);\r\n            \r\n            tokens[i] = Token(\r\n                _tokenIDs[i],\r\n                strings[0],\r\n                strings[1],\r\n                tokenAddress,\r\n                strings[2],\r\n                status,\r\n                0\r\n            );\r\n            \r\n            // Call the contract\u0027s decimals() function without reverting when\r\n            // the contract does not implement it.\r\n            // \r\n            // Two things should be noted: if the contract does not implement the function\r\n            // and does not implement the contract fallback function, \u0060success\u0060 will be set to\r\n            // false and decimals won\u0027t be set. However, in some cases (such as old contracts) \r\n            // the fallback function is implemented, and so staticcall will return true\r\n            // even though the value returned will not be correct (the number below):\r\n            // \r\n            // 22270923699561257074107342068491755213283769984150504402684791726686939079929\r\n            //\r\n            // We handle that edge case by also checking against this value.\r\n            uint decimals;\r\n            bool success;\r\n            bytes4 sig = bytes4(keccak256(\u0022decimals()\u0022));\r\n            assembly {\r\n                let x := mload(0x40)   // Find empty storage location using \u0022free memory pointer\u0022\r\n                mstore(x, sig)          // Set the signature to the first call parameter. 0x313ce567 === bytes4(keccak256(\u0022decimals()\u0022)\r\n                success := staticcall(\r\n                    30000,              // 30k gas\r\n                    tokenAddress,       // The call target.\r\n                    x,                  // Inputs are stored at location x\r\n                    0x04,               // Input is 4 bytes long\r\n                    x,                  // Overwrite x with output\r\n                    0x20                // The output length\r\n                )\r\n                \r\n                decimals := mload(x)   \r\n            }\r\n            if (success \u0026\u0026 decimals != 22270923699561257074107342068491755213283769984150504402684791726686939079929) {\r\n                tokens[i].decimals = decimals;\r\n            }\r\n        }\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_t2crAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022_tokenAddresses\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022getTokensIDsForAddresses\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32[]\u0022,\u0022name\u0022:\u0022result\u0022,\u0022type\u0022:\u0022bytes32[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_t2crAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes32[]\u0022,\u0022name\u0022:\u0022_tokenIDs\u0022,\u0022type\u0022:\u0022bytes32[]\u0022}],\u0022name\u0022:\u0022getTokens\u0022,\u0022outputs\u0022:[{\u0022components\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022ID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022ticker\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022symbolMultihash\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022enum IArbitrableTokenList.TokenStatus\u0022,\u0022name\u0022:\u0022status\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022decimals\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022internalType\u0022:\u0022struct TokensView.Token[]\u0022,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022tuple[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"TokensView","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://fab2f23163f9b3ceb1b51ef15f175a2ccd880833a07737d7c9f52c11d4153a38"}]