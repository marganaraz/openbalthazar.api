[{"SourceCode":"pragma solidity 0.5.12;\r\n\r\n// https://github.com/dapphub/ds-pause\r\ncontract DSPauseAbstract {\r\n    function delay() public view returns (uint256);\r\n    function plot(address, bytes32, bytes memory, uint256) public;\r\n    function exec(address, bytes32, bytes memory, uint256) public returns (bytes memory);\r\n}\r\n\r\n// https://github.com/makerdao/dss/blob/master/src/pot.sol\r\ncontract PotAbstract {\r\n    function file(bytes32, uint256) external;\r\n    function file(bytes32, address) external;\r\n    function drip() external returns (uint256);\r\n}\r\n\r\n// https://github.com/makerdao/dss/blob/master/src/jug.sol\r\ncontract JugAbstract {\r\n    function ilks(bytes32) public view returns (uint256, uint256);\r\n    function drip(bytes32) external returns (uint256);\r\n}\r\n\r\n\r\ncontract SpellAction {\r\n    // Provides a descriptive tag for bot consumption\r\n    // This should be modified weekly to provide a summary of the actions\r\n    string  constant public description = \u00222020-03-06 Weekly Executive: DSR spread adjustment\u0022;\r\n\r\n    // The contracts in this list should correspond to MCD core contracts, verify\r\n    //  against the current release list at:\r\n    //     https://changelog.makerdao.com/releases/mainnet/1.0.3/contracts.json\r\n    //\r\n    // Contract addresses pertaining to the SCD ecosystem can be found at:\r\n    //     https://github.com/makerdao/sai#dai-v1-current-deployments\r\n    address constant public MCD_PAUSE = 0xbE286431454714F511008713973d3B053A2d38f3;\r\n    address constant public MCD_JUG = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;\r\n    address constant public MCD_POT = 0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7;\r\n\r\n    // Many of the settings that change weekly rely on the rate accumulator\r\n    // described at https://docs.makerdao.com/smart-contract-modules/rates-module\r\n    // To check this yourself, use the following rate calculation (example 8%):\r\n    //\r\n    // $ bc -l \u003C\u003C\u003C \u0027scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )\u0027\r\n    //\r\n    uint256 constant public SEVEN_PCT_RATE = 1000000002145441671308778766;\r\n    uint256 constant public EIGHT_PCT_RATE = 1000000002440418608258400030;\r\n\r\n    function execute() external {\r\n\r\n        // Drip Pot and Jugs prior to all modifications.\r\n        PotAbstract(MCD_POT).drip();\r\n        JugAbstract(MCD_JUG).drip(\u0022ETH-A\u0022);\r\n        JugAbstract(MCD_JUG).drip(\u0022BAT-A\u0022);\r\n\r\n\r\n        // MCD Modifications\r\n\r\n\r\n        // Set the Dai Savings Rate\r\n        // DSR_RATE is a value determined by the rate accumulator calculation (see above)\r\n        //  ex. an 8% annual rate will be 1000000002440418608258400030\r\n        //\r\n        // Poll: Dai Savings Rate Spread Adjustment - March 2, 2020\r\n        // https://vote.makerdao.com/polling-proposal/qmccrai2s7twl6y6yyhrznysnkbengrqg4ibhpw8cnhunp\r\n        //\r\n        // Existing Rate: 8%\r\n        // New Rate: 7%\r\n        uint256 DSR_RATE = SEVEN_PCT_RATE;\r\n        PotAbstract(MCD_POT).file(\u0022dsr\u0022, DSR_RATE);\r\n\r\n\r\n        // Set the ETH-A stability fee\r\n        //\r\n        // Poll: Dai Stability Fee Adjustment - March 2, 2020\r\n        // https://vote.makerdao.com/polling-proposal/qmacgdz8euruq4lsqyzgjhumhexu5jnhihbmgbh54law7s\r\n        //\r\n        // Existing Rate: 8%\r\n        // New Rate: 8%\r\n        // Since the rate is not changing this week, we want to ensure that no other\r\n        //  spell has changed the state preemptively. We want to avoid a situation where\r\n        //  the stability fee is lower than the DSR.\r\n        (uint256 dutyETH,) = JugAbstract(MCD_JUG).ilks(\u0022ETH-A\u0022);\r\n        require(dutyETH == EIGHT_PCT_RATE, \u0022Unexpected ETH-A Stability Fee\u0022);\r\n\r\n    }\r\n}\r\n\r\ncontract DssSpell {\r\n\r\n    DSPauseAbstract  public pause =\r\n        DSPauseAbstract(0xbE286431454714F511008713973d3B053A2d38f3);\r\n    address          public action;\r\n    bytes32          public tag;\r\n    uint256          public eta;\r\n    bytes            public sig;\r\n    uint256          public expiration;\r\n    bool             public done;\r\n\r\n    constructor() public {\r\n        sig = abi.encodeWithSignature(\u0022execute()\u0022);\r\n        action = address(new SpellAction());\r\n        bytes32 _tag;\r\n        address _action = action;\r\n        assembly { _tag := extcodehash(_action) }\r\n        tag = _tag;\r\n        expiration = now \u002B 30 days;\r\n    }\r\n\r\n    function description() public view returns (string memory) {\r\n        return SpellAction(action).description();\r\n    }\r\n\r\n    function schedule() public {\r\n        require(now \u003C= expiration, \u0022This contract has expired\u0022);\r\n        require(eta == 0, \u0022This spell has already been scheduled\u0022);\r\n        eta = now \u002B DSPauseAbstract(pause).delay();\r\n        pause.plot(action, tag, sig, eta);\r\n\r\n        // NOTE: \u0027eta\u0027 check should mimic the old behavior of \u0027done\u0027, thus\r\n        // preventing these SCD changes from being executed again.\r\n\r\n\r\n        // Set the Sai stability fee\r\n        //\r\n        // Poll: Sai Stability Fee Adjustment - March 2, 2020\r\n        // https://vote.makerdao.com/polling-proposal/qme4mhhlcuvcg7pwyfh1pdgqwp45abrdtvrdwvcbfggunj\r\n        //\r\n        // Existing Rate: 9.5%\r\n        // New Rate: 9.5%\r\n    }\r\n\r\n    function cast() public {\r\n        require(!done, \u0022spell-already-cast\u0022);\r\n        done = true;\r\n        pause.exec(action, tag, sig, eta);\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022action\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022cast\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022description\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022done\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022eta\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022expiration\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract DSPauseAbstract\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022schedule\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sig\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tag\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"DssSpell","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://dae8d58ddd50e779d3bcdee25f2ce607b458a4ed5ef379f17c978058fc970db4"}]