[{"SourceCode":"pragma solidity 0.5.7;\r\n// produced by the Solididy File Flattener (c) David Appleton 2018\r\n// contact : dave@akomba.com\r\n// released under Apache 2.0 licence\r\ncontract Basket {\r\n    address[] public tokens;\r\n    mapping(address =\u003E uint256) public weights; // unit: aqToken/RSV\r\n    mapping(address =\u003E bool) public has;\r\n    // INVARIANT: {addr | addr in tokens} == {addr | has[addr] == true}\r\n    \r\n    // SECURITY PROPERTY: The value of prev is always a Basket, and cannot be set by any user.\r\n    \r\n    // WARNING: A basket can be of size 0. It is the Manager\u0027s responsibility\r\n    //                    to ensure Issuance does not happen against an empty basket.\r\n\r\n    /// Construct a new basket from an old Basket \u0060prev\u0060, and a list of tokens and weights with\r\n    /// which to update \u0060prev\u0060. If \u0060prev == address(0)\u0060, act like it\u0027s an empty basket.\r\n    constructor(Basket trustedPrev, address[] memory _tokens, uint256[] memory _weights) public {\r\n        require(_tokens.length == _weights.length, \u0022Basket: unequal array lengths\u0022);\r\n\r\n        // Initialize data from input arrays\r\n        tokens = new address[](_tokens.length);\r\n        for (uint256 i = 0; i \u003C _tokens.length; i\u002B\u002B) {\r\n            require(!has[_tokens[i]], \u0022duplicate token entries\u0022);\r\n            weights[_tokens[i]] = _weights[i];\r\n            has[_tokens[i]] = true;\r\n            tokens[i] = _tokens[i];\r\n        }\r\n\r\n        // If there\u0027s a previous basket, copy those of its contents not already set.\r\n        if (trustedPrev != Basket(0)) {\r\n            for (uint256 i = 0; i \u003C trustedPrev.size(); i\u002B\u002B) {\r\n                address tok = trustedPrev.tokens(i);\r\n                if (!has[tok]) {\r\n                    weights[tok] = trustedPrev.weights(tok);\r\n                    has[tok] = true;\r\n                    tokens.push(tok);\r\n                }\r\n            }\r\n        }\r\n        require(tokens.length \u003C= 10, \u0022Basket: bad length\u0022);\r\n    }\r\n\r\n    function getTokens() external view returns(address[] memory) {\r\n        return tokens;\r\n    }\r\n\r\n    function size() external view returns(uint256) {\r\n        return tokens.length;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022has\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022tokens\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022size\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022weights\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getTokens\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022trustedPrev\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_tokens\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_weights\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"Basket","CompilerVersion":"v0.5.7\u002Bcommit.6da8b019","OptimizationUsed":"1","Runs":"100000","ConstructorArguments":"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000030000000000000000000000008e870d67f660d95d5be530380d0ec0bd388289e10000000000000000000000000000000000085d4780b73119b644ae5ecd22b376000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb4800000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000403295f434236c799ce5b7400000000000000000000000000000000000000000403295f434236c799ce5b740000000000000000000000000000000000000000000000000004696128568c6fa980000","Library":"","SwarmSource":"bzzr://392880f562f3a87fda7b63f16c3d4edab814aa60350133017fe0dd9bc03c7be4"}]