[{"SourceCode":"pragma solidity \u003E0.4.99 \u003C0.6.0;\r\n\r\ncontract PostLike {\r\n  event Liked(uint256 indexed postIdx, address indexed user);\r\n  event Unliked(uint256 indexed postIdx, address indexed user);\r\n\r\n  mapping(uint256 =\u003E uint256) public postLikeCount;\r\n  mapping(address =\u003E mapping(uint256 =\u003E bool)) public liked;\r\n\r\n  function Like(uint256 postIdx) public {\r\n    require(!liked[msg.sender][postIdx]);\r\n    liked[msg.sender][postIdx] = true;\r\n    postLikeCount[postIdx] \u002B= 1;\r\n    emit Liked(postIdx, msg.sender);\r\n  }\r\n\r\n  function Unlike(uint256 postIdx) public {\r\n    require(liked[msg.sender][postIdx]);\r\n    liked[msg.sender][postIdx] = false;\r\n    postLikeCount[postIdx] -= 1;\r\n    emit Unliked(postIdx, msg.sender);\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022liked\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022postIdx\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Like\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022postIdx\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Unlike\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022postLikeCount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022postIdx\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Liked\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022postIdx\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Unliked\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"PostLike","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://df2e6fbd6323d82e7294df14bdc1f219ec88f1bc2b079c024626670795a41648"}]