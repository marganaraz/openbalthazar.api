[{"SourceCode":"pragma solidity 0.5.10;\r\n\r\n\r\ncontract Bytes {\r\n    function scriptNumSize(uint256 i) public pure returns (uint256) {\r\n        if      (i \u003E 0x7fffffff) { return 5; }\r\n        else if (i \u003E 0x7fffff  ) { return 4; }\r\n        else if (i \u003E 0x7fff    ) { return 3; }\r\n        else if (i \u003E 0x7f      ) { return 2; }\r\n        else if (i \u003E 0x00      ) { return 1; }\r\n        else                     { return 0; }\r\n    }\r\n\r\n    function scriptNumSizeHex(uint256 i) public pure returns (bytes memory) {\r\n        return toBytes(scriptNumSize(i));\r\n    }\r\n\r\n    function toBytes(uint256 x) public pure returns (bytes memory b) {\r\n        uint a = scriptNumSize(x);\r\n        b = new bytes(a);\r\n        for (uint i = 0; i \u003C a; i\u002B\u002B) {\r\n            b[i] = byte(uint8(x / (2**(8*(a - 1 - i)))));\r\n        }\r\n    }\r\n\r\n    function scriptNumEncode(uint256 num) public pure returns (bytes memory) {\r\n        uint a = scriptNumSize(num);\r\n        bytes memory b = toBytes(num);\r\n        for (uint i = 0; i \u003C (a/2); i\u002B\u002B) {\r\n            byte c = b[i];\r\n            b[i] = b[a - i - 1];\r\n            b[a - i - 1] = c;\r\n        }\r\n        return b;\r\n    }\r\n}\r\n\r\ninterface LoansInterface {\r\n    function secretHashes(bytes32) external view returns (bytes32, bytes32, bytes32, bytes32, bytes32, bool);\r\n    function pubKeys(bytes32) external view returns (bytes memory, bytes memory, bytes memory);\r\n    function liquidationExpiration(bytes32) external view returns (uint256);\r\n    function seizureExpiration(bytes32) external view returns (uint256);\r\n}\r\n\r\ncontract P2WSH is Bytes {\r\n  LoansInterface loans;\r\n\r\n  constructor(LoansInterface loans_) public {\r\n    loans = loans_;\r\n  }\r\n\r\n  function loanPeriodP2WSH(bytes32 loan, bytes memory script) internal view returns (bytes memory) {\r\n    (, bytes32 secretHashB1, bytes32 secretHashC1, , ,) = loans.secretHashes(loan);\r\n    (bytes memory borrowerPubKey, ,) = loans.pubKeys(loan);\r\n\r\n    bytes memory result = abi.encodePacked(\r\n      hex\u002263820120877ca820\u0022, \r\n      secretHashB1,\r\n      hex\u0022879352877c820120877ca820\u0022, \r\n      secretHashC1,\r\n      hex\u0022879352879351a26976a914\u0022, \r\n      ripemd160(abi.encodePacked(sha256(borrowerPubKey))),\r\n      hex\u002288ac67\u0022, \r\n      script,\r\n      hex\u002268\u0022 \r\n    );\r\n\r\n    return result;\r\n  }\r\n\r\n  function biddingPeriodSigP2WSH(bytes32 loan) internal view returns (bytes memory) {\r\n    (bytes memory borrowerPubKey, bytes memory lenderPubKey, bytes memory arbiterPubKey) = loans.pubKeys(loan);\r\n\r\n    bytes memory result = abi.encodePacked(\r\n      hex\u002252\u0022, \r\n      toBytes(borrowerPubKey.length),\r\n      borrowerPubKey,\r\n      toBytes(lenderPubKey.length),\r\n      lenderPubKey,\r\n      toBytes(arbiterPubKey.length),\r\n      arbiterPubKey,\r\n      hex\u002253ae\u0022 \r\n    );\r\n\r\n    return result;\r\n  }\r\n\r\n  function biddingPeriodP2WSH(bytes32 loan, bytes memory script) internal view returns (bytes memory) {\r\n    bytes memory result = abi.encodePacked(\r\n      hex\u002263\u0022, \r\n      biddingPeriodSigP2WSH(loan),\r\n      hex\u002267\u0022, \r\n      script,\r\n      hex\u002268\u0022 \r\n    );\r\n\r\n    return result;\r\n  }\r\n\r\n  function seizurePeriodSechP2WSH(bytes32 loan) internal view returns (bytes memory) {\r\n    (bytes32 secretHashA1,,,,,) = loans.secretHashes(loan);\r\n    uint256 liquidationExpiration = loans.liquidationExpiration(loan);\r\n\r\n    bytes memory result = abi.encodePacked(\r\n      hex\u002282012088a820\u0022, \r\n      secretHashA1,\r\n      hex\u002288\u0022, \r\n      scriptNumSizeHex(liquidationExpiration),\r\n      scriptNumEncode(liquidationExpiration),\r\n      hex\u0022b175\u0022 \r\n    );\r\n\r\n    return result;\r\n  }\r\n\r\n  function seizurePeriodP2WSH(bytes32 loan, bytes memory script, bool sez) internal view returns (bytes memory) {\r\n    (bytes memory borrowerPubKey, bytes memory lenderPubKey, ) = loans.pubKeys(loan);\r\n\r\n    bytes memory pubKey;\r\n\r\n    if (sez) {\r\n      pubKey = lenderPubKey;\r\n    } else {\r\n      pubKey = borrowerPubKey;\r\n    }\r\n\r\n    bytes memory result = abi.encodePacked(\r\n      hex\u002263\u0022, \r\n      seizurePeriodSechP2WSH(loan),\r\n      hex\u002276a914\u0022, \r\n      ripemd160(abi.encodePacked(sha256(pubKey))),\r\n      hex\u002288ac67\u0022, \r\n      script,\r\n      hex\u002268\u0022 \r\n    );\r\n\r\n    return result;\r\n  }\r\n\r\n  function refundablePeriodP2WSH(bytes32 loan) internal view returns (bytes memory) {\r\n    (bytes memory borrowerPubKey, , ) = loans.pubKeys(loan);\r\n    uint256 seizureExpiration = loans.seizureExpiration(loan);\r\n\r\n    bytes memory result = abi.encodePacked(\r\n      scriptNumSizeHex(seizureExpiration),\r\n      scriptNumEncode(seizureExpiration),\r\n      hex\u0022b17576a914\u0022, \r\n      ripemd160(abi.encodePacked(sha256(borrowerPubKey))),\r\n      hex\u002288ac\u0022 \r\n    );\r\n\r\n    return result;\r\n  }\r\n\r\n  function getP2WSH(bytes32 loan, bool sez) external view returns (bytes memory, bytes32) {\r\n    bytes memory script = loanPeriodP2WSH(loan, biddingPeriodP2WSH(loan, seizurePeriodP2WSH(loan, refundablePeriodP2WSH(loan), sez)));\r\n    bytes32 pubkh = sha256(script);\r\n\r\n    return (script, pubkh);\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022loan\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022sez\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022getP2WSH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022x\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022toBytes\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022i\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022scriptNumSizeHex\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022num\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022scriptNumEncode\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022i\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022scriptNumSize\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022loans_\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"P2WSH","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"00000000000000000000000023d2374f10b02f1c866498f3f534a1f24c9341b5","Library":"","SwarmSource":"bzzr://7d58c4a0117df28353f3dd5f142ee139c0eec743407896df35d40fb3aced6ffb"}]