[{"SourceCode":"pragma solidity ^0.5.8;\r\n\r\ninterface TokenInterface {\r\n    function allowance(address, address) external view returns (uint);\r\n    function balanceOf(address) external view returns (uint);\r\n    function approve(address, uint) external;\r\n    function transfer(address, uint) external returns (bool);\r\n    function transferFrom(address, address, uint) external returns (bool);\r\n}\r\n\r\n/** Swap Functionality */\r\ninterface ScdMcdMigration {\r\n    function swapDaiToSai(uint daiAmt) external;\r\n    function swapSaiToDai(uint saiAmt) external;\r\n}\r\n\r\ninterface InstaMcdAddress {\r\n    function migration() external returns (address payable);\r\n}\r\n\r\n\r\ncontract Helpers {\r\n     /**\r\n     * @dev get MakerDAO MCD Address contract\r\n     */\r\n    function getMcdAddresses() public pure returns (address mcd) {\r\n        mcd = 0xF23196DF1C440345DE07feFbe556a5eF0dcD29F0;\r\n    }\r\n\r\n    /**\r\n     * @dev get Sai (Dai v1) address\r\n     */\r\n    function getSaiAddress() public pure returns (address sai) {\r\n        sai = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;\r\n    }\r\n\r\n    /**\r\n     * @dev get Dai (Dai v2) address\r\n     */\r\n    function getDaiAddress() public pure returns (address dai) {\r\n        dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;\r\n    }\r\n}\r\n\r\n\r\ncontract InstaMcdSwap is Helpers {\r\n    function swapDaiToSai(\r\n        uint wad // Amount to swap\r\n    ) external\r\n    {\r\n        address scdMcdMigration = InstaMcdAddress(getMcdAddresses()).migration();    // Migration contract address\r\n        TokenInterface dai = TokenInterface(getDaiAddress());\r\n        dai.transferFrom(msg.sender, address(this), wad);\r\n        if (dai.allowance(address(this), scdMcdMigration) \u003C wad) {\r\n            dai.approve(scdMcdMigration, wad);\r\n        }\r\n        ScdMcdMigration(scdMcdMigration).swapDaiToSai(wad);\r\n        TokenInterface(getSaiAddress()).transfer(msg.sender, wad);\r\n    }\r\n\r\n    function swapSaiToDai(\r\n        uint wad // Amount to swap\r\n    ) external\r\n    {\r\n        address scdMcdMigration = InstaMcdAddress(getMcdAddresses()).migration();    // Migration contract address\r\n        TokenInterface sai = TokenInterface(getSaiAddress());\r\n        sai.transferFrom(msg.sender, address(this), wad);\r\n        if (sai.allowance(address(this), scdMcdMigration) \u003C wad) {\r\n            sai.approve(scdMcdMigration, wad);\r\n        }\r\n        ScdMcdMigration(scdMcdMigration).swapSaiToDai(wad);\r\n        TokenInterface(getDaiAddress()).transfer(msg.sender, wad);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getDaiAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022dai\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getSaiAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022sai\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022swapDaiToSai\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getMcdAddresses\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022mcd\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022wad\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022swapSaiToDai\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"InstaMcdSwap","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://c8de265b1e860560c641ddcb18bd4c0eb06a325aab7261cf478362718cc9f42b"}]