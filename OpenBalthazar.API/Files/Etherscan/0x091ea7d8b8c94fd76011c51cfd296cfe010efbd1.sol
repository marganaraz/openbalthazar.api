[{"SourceCode":"/**\r\n *Submitted for verification at Etherscan.io on 2019-07-24\r\n*/\r\n\r\n/**\r\n *  @authors: [@mtsalenc]\r\n *  @reviewers: []\r\n *  @auditors: []\r\n *  @bounties: []\r\n *  @deployments: []\r\n */\r\n\r\npragma solidity 0.5.10;\r\npragma experimental ABIEncoderV2;\r\n\r\n\r\ninterface ArbitrableTokenList {\r\n    \r\n    enum TokenStatus {\r\n        Absent, // The token is not in the registry.\r\n        Registered, // The token is in the registry.\r\n        RegistrationRequested, // The token has a request to be added to the registry.\r\n        ClearingRequested // The token has a request to be removed from the registry.\r\n    }\r\n    \r\n    function getTokenInfo(bytes32) external view returns (string memory, string memory, address, string memory, TokenStatus, uint);\r\n    function queryTokens(bytes32 _cursor, uint _count, bool[8] calldata _filter, bool _oldestFirst, address _tokenAddr)\r\n        external\r\n        view\r\n        returns (bytes32[] memory values, bool hasMore);\r\n}\r\n\r\ninterface ExchangeRegistry {\r\n    function getExchange(address _tokenContract) external view returns (address);\r\n}\r\n\r\ninterface AddressRegistry {\r\n    function queryAddresses(address _cursor, uint _count, bool[8] calldata _filter, bool _oldestFirst)\r\n        external\r\n        view\r\n        returns (address[] memory values, bool hasMore);\r\n}\r\n\r\n/** @title TokensView\r\n *  Utility view contract to fetch multiple token information at once.\r\n */\r\ncontract TokensView {\r\n    \r\n    struct Token {\r\n        bytes32 ID;\r\n        string name;\r\n        string ticker;\r\n        address addr;\r\n        string symbolMultihash;\r\n        ArbitrableTokenList.TokenStatus status;\r\n        uint numberOfRequests;\r\n        address exchange;\r\n    }\r\n    \r\n    /** @dev Fetch up to 100 token information with badges.\r\n     *  @param _t2crAddress The address of the t2cr contract from where to fetch token information.\r\n     *  @param _exchangeRegistry The address of the registry contract for exchanges.\r\n     *  @param _badgeContract The address of badge contract to query.\r\n     *  @return tokens The tokens information.\r\n     */\r\n    function getTokensInfo(\r\n        address _t2crAddress, \r\n        address _exchangeRegistry, \r\n        address _badgeContract\r\n    ) \r\n        public \r\n        view \r\n        returns (Token[100] memory tokens)\r\n    {\r\n        ArbitrableTokenList t2cr = ArbitrableTokenList(_t2crAddress);\r\n        ExchangeRegistry exchangeRegistry = ExchangeRegistry(_exchangeRegistry);\r\n        AddressRegistry addressRegistry = AddressRegistry(_badgeContract);\r\n        (address[] memory _tokenAddresses,) = addressRegistry.queryAddresses(\r\n            0x0000000000000000000000000000000000000000, \r\n            100, \r\n            [false, true, false, true, false, true, false, false], \r\n            true\r\n        );\r\n        bytes32[100] memory _tokenIDs = getTokensIDsForAddresses(_t2crAddress, _tokenAddresses);\r\n        \r\n        for (uint i = 0; i \u003C _tokenIDs.length; i\u002B\u002B){\r\n            (\r\n                string memory tokenName, \r\n                string memory tokenTicker, \r\n                address tokenAddress, \r\n                string memory symbolMultihash, \r\n                ArbitrableTokenList.TokenStatus status, \r\n                uint numberOfRequests\r\n            ) = t2cr.getTokenInfo(_tokenIDs[i]);\r\n            \r\n            tokens[i] = Token(\r\n                _tokenIDs[i],\r\n                tokenName,\r\n                tokenTicker,\r\n                tokenAddress,\r\n                symbolMultihash,\r\n                status,\r\n                numberOfRequests,\r\n                exchangeRegistry.getExchange(tokenAddress)\r\n            );\r\n        }\r\n    }\r\n    \r\n    \r\n    /** @dev Fetch up to 100 token IDs of the first tokens present on the tcr with the address.\r\n     *  @param _t2crAddress The address of the t2cr contract from where to fetch token information.\r\n     *  @param _tokenAddresses The address of each token.\r\n     *  @return The IDs of the tokens or 0 if the token is not present.\r\n     */\r\n    function getTokensIDsForAddresses(address _t2crAddress, address[] memory _tokenAddresses) internal view returns (bytes32[100] memory tokenIDs) {\r\n        ArbitrableTokenList t2cr = ArbitrableTokenList(_t2crAddress);\r\n        bytes32 ZERO_ID = 0x0000000000000000000000000000000000000000000000000000000000000000;\r\n        for (uint i = 0; i \u003C 100; i\u002B\u002B){\r\n            (bytes32[] memory tokenID, ) = t2cr.queryTokens(ZERO_ID, 0, [false, true, false, true, false, true, false, false], true, _tokenAddresses[i]);\r\n            tokenIDs[i] = tokenID[0];\r\n        }\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_t2crAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_exchangeRegistry\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_badgeContract\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getTokensInfo\u0022,\u0022outputs\u0022:[{\u0022components\u0022:[{\u0022name\u0022:\u0022ID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022ticker\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022symbolMultihash\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022status\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022numberOfRequests\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022exchange\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022tuple[100]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"TokensView","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://a666e2c911ca247d6ebc4e964d4b266bd4a06dc89d807a022cdb1a01c79775d3"}]