[{"SourceCode":"pragma solidity \u003E0.4.99 \u003C0.6.0;\r\n\r\ncontract PostLike {\r\n  mapping(uint256 =\u003E uint256) public postLikeCount;\r\n}\r\n\r\ncontract GetMultiPostLikeCount {\r\n  PostLike postLikeContract = PostLike(0x2E8c1E33e82E2A5b93076f32Aa5EFE3dFaAa1676);\r\n  function Get(uint256[] memory postIdxList) public view returns (uint256[] memory counts) {\r\n    uint256[] memory results = new uint256[](postIdxList.length);\r\n    for (uint256 i = 0; i \u003C results.length; i\u002B\u002B) {\r\n        results[i] = postLikeContract.postLikeCount(postIdxList[i]);\r\n    }\r\n    return results;\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022postIdxList\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022Get\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022counts\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"GetMultiPostLikeCount","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://10e0055a6750263e55d9493db2366f5b285390e7fd0570b90f485f651eecf9af"}]