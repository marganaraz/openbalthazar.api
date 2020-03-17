[{"SourceCode":"pragma solidity 0.5.12;\r\n\r\ncontract FileLike {\r\n    function file(bytes32, uint256) external;\r\n    function file(bytes32, bytes32, uint256) external;\r\n}\r\n\r\ncontract JugLike {\r\n    function drip(bytes32) external;\r\n    function file(bytes32, bytes32, uint256) external;\r\n}\r\n\r\ncontract PotLike {\r\n    function drip() external;\r\n    function file(bytes32, uint256) external;\r\n}\r\n\r\ncontract PauseLike {\r\n    function delay() external view returns (uint256);\r\n    function plot(address, bytes32, bytes calldata, uint256) external;\r\n    function exec(address, bytes32, bytes calldata, uint256) external;\r\n}\r\n\r\ncontract MomLike {\r\n    function setCap(uint256) external;\r\n    function setFee(uint256) external;\r\n}\r\n\r\ncontract DssUpdateParametersSpellAction {\r\n    uint256 constant RAD = 10 ** 45;\r\n    address constant public VAT = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;\r\n    address constant public JUG = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;\r\n    address constant public POT = 0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7;\r\n\r\n    function execute() external {\r\n        // drip\r\n        PotLike(POT).drip();\r\n        JugLike(JUG).drip(\u0022ETH-A\u0022);\r\n        JugLike(JUG).drip(\u0022BAT-A\u0022);\r\n\r\n        // 6%\r\n        uint256 duty = 1000000001847694957439350562;\r\n\r\n        // DSR to 6%\r\n        PotLike(POT).file(\u0022dsr\u0022, duty);\r\n\r\n\r\n        // set ETH-A duty to 6%\r\n        JugLike(JUG).file(\u0022ETH-A\u0022, \u0022duty\u0022, duty);\r\n\r\n        // set BAT-A duty to 6%\r\n        JugLike(JUG).file(\u0022BAT-A\u0022, \u0022duty\u0022, duty);\r\n    }\r\n}\r\n\r\ncontract DssJanuary3Spell {\r\n    PauseLike public pause =\r\n        PauseLike(0xbE286431454714F511008713973d3B053A2d38f3);\r\n    address constant public SAIMOM = 0xF2C5369cFFb8Ea6284452b0326e326DbFdCb867C;\r\n    uint256 constant public NEWFEE = 1000000001547125957863212448;\r\n    address   public action;\r\n    bytes32   public tag;\r\n    uint256   public eta;\r\n    bytes     public sig;\r\n    bool      public done;\r\n\r\n    constructor() public {\r\n        sig = abi.encodeWithSignature(\u0022execute()\u0022);\r\n        action = address(new DssUpdateParametersSpellAction());\r\n        bytes32 _tag;\r\n        address _action = action;\r\n        assembly { _tag := extcodehash(_action) }\r\n        tag = _tag;\r\n    }\r\n\r\n    function cast() external {\r\n        require(!done, \u0022spell-already-cast\u0022);\r\n        done = true;\r\n        pause.plot(action, tag, sig, now);\r\n        pause.exec(action, tag, sig, now);\r\n        // Increase Fee to 5%\r\n        MomLike(SAIMOM).setFee(NEWFEE);\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022NEWFEE\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022SAIMOM\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022action\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022cast\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022done\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022eta\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract PauseLike\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sig\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tag\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"DssJanuary3Spell","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://7922dcb62f04cc7493bc9eb18b28d39bbe565029ca25aeeb466c61730dbd9bac"}]