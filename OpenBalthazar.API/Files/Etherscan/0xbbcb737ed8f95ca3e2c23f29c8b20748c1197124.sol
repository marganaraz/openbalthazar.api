[{"SourceCode":"/**\r\n *  @authors: [@mtsalenc]\r\n *  @reviewers: []\r\n *  @auditors: []\r\n *  @bounties: []\r\n *  @deployments: []\r\n */\r\n\r\npragma solidity 0.5.10;\r\npragma experimental ABIEncoderV2;\r\n\r\n\r\ninterface ArbitrableTokenList {\r\n    \r\n    enum TokenStatus {\r\n        Absent, // The token is not in the registry.\r\n        Registered, // The token is in the registry.\r\n        RegistrationRequested, // The token has a request to be added to the registry.\r\n        ClearingRequested // The token has a request to be removed from the registry.\r\n    }\r\n    \r\n    function getTokenInfo(bytes32) external view returns (string memory, string memory, address, string memory, TokenStatus, uint);\r\n    function queryTokens(bytes32 _cursor, uint _count, bool[8] calldata _filter, bool _oldestFirst, address _tokenAddr)\r\n        external\r\n        view\r\n        returns (bytes32[] memory values, bool hasMore);\r\n}\r\n\r\n/** @title TokensView\r\n *  Utility view contract to fetch multiple token information at once.\r\n */\r\ncontract TokensView {\r\n    \r\n    struct Token {\r\n        bytes32 ID;\r\n        string name;\r\n        string ticker;\r\n        address addr;\r\n        string symbolMultihash;\r\n        ArbitrableTokenList.TokenStatus status;\r\n        uint numberOfRequests;\r\n    }\r\n    \r\n    /** @dev Fetch up to 500 token IDs of the first tokens present on the tcr with the address.\r\n     *  @param _t2crAddress The address of the t2cr contract from where to fetch token information.\r\n     *  @param _tokenAddresses The address of each token.\r\n     *  @return The IDs of the tokens or 0 if the token is not present.\r\n     */\r\n    function getTokensIDsForAddresses(address _t2crAddress, address[] calldata _tokenAddresses) external view returns (bytes32[500] memory tokenIDs) {\r\n        ArbitrableTokenList t2cr = ArbitrableTokenList(_t2crAddress);\r\n        bytes32 ZERO_ID = 0x0000000000000000000000000000000000000000000000000000000000000000;\r\n        for (uint i = 0; i \u003C _tokenAddresses.length; i\u002B\u002B){\r\n            (bytes32[] memory tokenID, ) = t2cr.queryTokens(ZERO_ID, 50, [false, true, false, true, false, true, false, false], true, _tokenAddresses[i]);\r\n            tokenIDs[i] = tokenID[0];\r\n        }\r\n    }\r\n    \r\n    /** @dev Fetch up to 500 tokens information with token IDs.\r\n     *  @param _t2crAddress The address of the t2cr contract from where to fetch token information.\r\n     *  @param _tokenIDs The IDs of the tokens we want to query.\r\n     *  @return tokens The tokens information.\r\n     */\r\n    function getTokens(address _t2crAddress, bytes32[] calldata _tokenIDs) \r\n        external \r\n        view \r\n        returns (Token[500] memory tokens)\r\n    {\r\n        ArbitrableTokenList t2cr = ArbitrableTokenList(_t2crAddress);\r\n        for (uint i = 0; i \u003C _tokenIDs.length; i\u002B\u002B){\r\n            (\r\n                string memory tokenName, \r\n                string memory tokenTicker, \r\n                address tokenAddress, \r\n                string memory symbolMultihash, \r\n                ArbitrableTokenList.TokenStatus status, \r\n                uint numberOfRequests\r\n            ) = t2cr.getTokenInfo(_tokenIDs[i]);\r\n            \r\n            tokens[i] = Token(\r\n                _tokenIDs[i],\r\n                tokenName,\r\n                tokenTicker,\r\n                tokenAddress,\r\n                symbolMultihash,\r\n                status,\r\n                numberOfRequests\r\n            );\r\n        }\r\n\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_t2crAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_tokenAddresses\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022getTokensIDsForAddresses\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022tokenIDs\u0022,\u0022type\u0022:\u0022bytes32[500]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_t2crAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_tokenIDs\u0022,\u0022type\u0022:\u0022bytes32[]\u0022}],\u0022name\u0022:\u0022getTokens\u0022,\u0022outputs\u0022:[{\u0022components\u0022:[{\u0022name\u0022:\u0022ID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022ticker\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022symbolMultihash\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022status\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022numberOfRequests\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022tuple[500]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"TokensView","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://5aaab378b45614b61a6b49360df0980bf095beff7340621917ba3b85c9c580de"}]