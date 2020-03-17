[{"SourceCode":"/**\r\n *  @authors: [@mtsalenc]\r\n *  @reviewers: []\r\n *  @auditors: []\r\n *  @bounties: []\r\n *  @deployments: []\r\n */\r\n\r\npragma solidity 0.5.10;\r\n\r\n\r\ninterface TokenDecimals {\r\n    function decimals() external view returns (uint);\r\n}\r\n\r\n/** @title TokensDecimalsView\r\n *  Utility view contract to fetch decimals from multiple token contracts at once.\r\n */\r\ncontract TokensDecimalsView {\r\n    \r\n    /** @dev Fetch up to 500 tokens decimals.\r\n     *  @param _tokenAddresses The addresses of the token contracts to query.\r\n     *  @return tokens The number of decimal places of each contract.\r\n     */\r\n    function getDecimals(address[] calldata _tokenAddresses) external view returns (uint[500] memory decimals) {\r\n        for (uint i = 0; i \u003C _tokenAddresses.length; i\u002B\u002B) {\r\n            TokenDecimals token = TokenDecimals(_tokenAddresses[i]);\r\n            decimals[i] = token.decimals();\r\n        }\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenAddresses\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022getDecimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022decimals\u0022,\u0022type\u0022:\u0022uint256[500]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"TokensDecimalsView","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://28997aef45780a94eb12f1edcfc665ed9f5ad783a1b33cea05137d42255f9208"}]