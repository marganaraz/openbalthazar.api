[{"SourceCode":"// File: contracts/saga-genesis/interfaces/ISGNConversionManager.sol\r\n\r\npragma solidity 0.4.25;\r\n\r\n/**\r\n * @title SGN Conversion Manager Interface.\r\n */\r\ninterface ISGNConversionManager {\r\n    /**\r\n     * @dev Compute the SGA worth of a given SGN amount at a given minting-point.\r\n     * @param _amount The amount of SGN.\r\n     * @param _index The minting-point index.\r\n     * @return The equivalent amount of SGA.\r\n     */\r\n    function sgn2sga(uint256 _amount, uint256 _index) external view returns (uint256);\r\n}\r\n\r\n// File: contracts/saga-genesis/SGNConversionManager.sol\r\n\r\npragma solidity 0.4.25;\r\n\r\n\r\n/**\r\n * Details of usage of licenced software see here: https://www.saga.org/software/readme_v1\r\n */\r\n\r\n/**\r\n * @title SGN Conversion Manager.\r\n * @dev Calculate the conversion of SGN to SGA.\r\n * @notice Some of the code has been auto-generated via \u0027PrintSGNConversionManager.py\u0027,\r\n * in compliance with \u0027Saga Monetary Model.pdf\u0027 / APPENDIX D: SAGA MODEL POINTS.\r\n */\r\ncontract SGNConversionManager is ISGNConversionManager {\r\n    string public constant VERSION = \u00221.0.0\u0022;\r\n\r\n    uint256 public constant MAX_AMOUNT = 107000000e18;\r\n\r\n    uint256 public constant DENOMINATOR = 1000000;\r\n\r\n    uint256[105] public numerators;\r\n\r\n    constructor() public {\r\n        numerators[  0] =        0;\r\n        numerators[  1] =        0;\r\n        numerators[  2] =     2500;\r\n        numerators[  3] =    22650;\r\n        numerators[  4] =    22650;\r\n        numerators[  5] =    63504;\r\n        numerators[  6] =   125680;\r\n        numerators[  7] =   125680;\r\n        numerators[  8] =   209810;\r\n        numerators[  9] =   316560;\r\n        numerators[ 10] =   446570;\r\n        numerators[ 11] =   600530;\r\n        numerators[ 12] =   779120;\r\n        numerators[ 13] =   983070;\r\n        numerators[ 14] =   983070;\r\n        numerators[ 15] =  1213000;\r\n        numerators[ 16] =  1213000;\r\n        numerators[ 17] =  1267300;\r\n        numerators[ 18] =  1324800;\r\n        numerators[ 19] =  1385500;\r\n        numerators[ 20] =  1449200;\r\n        numerators[ 21] =  1515900;\r\n        numerators[ 22] =  1585500;\r\n        numerators[ 23] =  1657900;\r\n        numerators[ 24] =  1733000;\r\n        numerators[ 25] =  1810800;\r\n        numerators[ 26] =  1810800;\r\n        numerators[ 27] =  1884500;\r\n        numerators[ 28] =  1960500;\r\n        numerators[ 29] =  2038700;\r\n        numerators[ 30] =  2119000;\r\n        numerators[ 31] =  2201400;\r\n        numerators[ 32] =  2285900;\r\n        numerators[ 33] =  2372400;\r\n        numerators[ 34] =  2460900;\r\n        numerators[ 35] =  2551400;\r\n        numerators[ 36] =  2551400;\r\n        numerators[ 37] =  2636300;\r\n        numerators[ 38] =  2722900;\r\n        numerators[ 39] =  2811200;\r\n        numerators[ 40] =  2901100;\r\n        numerators[ 41] =  2992700;\r\n        numerators[ 42] =  3085900;\r\n        numerators[ 43] =  3180700;\r\n        numerators[ 44] =  3277100;\r\n        numerators[ 45] =  3375000;\r\n        numerators[ 46] =  3474500;\r\n        numerators[ 47] =  3575500;\r\n        numerators[ 48] =  3678100;\r\n        numerators[ 49] =  3782200;\r\n        numerators[ 50] =  3887800;\r\n        numerators[ 51] =  3994800;\r\n        numerators[ 52] =  4103300;\r\n        numerators[ 53] =  4216300;\r\n        numerators[ 54] =  4333800;\r\n        numerators[ 55] =  4455700;\r\n        numerators[ 56] =  4581900;\r\n        numerators[ 57] =  4712400;\r\n        numerators[ 58] =  4847200;\r\n        numerators[ 59] =  4986200;\r\n        numerators[ 60] =  5129400;\r\n        numerators[ 61] =  5276800;\r\n        numerators[ 62] =  5428400;\r\n        numerators[ 63] =  5584200;\r\n        numerators[ 64] =  5744100;\r\n        numerators[ 65] =  5908300;\r\n        numerators[ 66] =  6076700;\r\n        numerators[ 67] =  6076700;\r\n        numerators[ 68] =  6249300;\r\n        numerators[ 69] =  6426100;\r\n        numerators[ 70] =  6607100;\r\n        numerators[ 71] =  6792300;\r\n        numerators[ 72] =  6981600;\r\n        numerators[ 73] =  7175100;\r\n        numerators[ 74] =  7372700;\r\n        numerators[ 75] =  7574500;\r\n        numerators[ 76] =  7780400;\r\n        numerators[ 77] =  7990400;\r\n        numerators[ 78] =  8204500;\r\n        numerators[ 79] =  8422700;\r\n        numerators[ 80] =  8645000;\r\n        numerators[ 81] =  8871400;\r\n        numerators[ 82] =  9101900;\r\n        numerators[ 83] =  9336500;\r\n        numerators[ 84] =  9575200;\r\n        numerators[ 85] =  9818000;\r\n        numerators[ 86] = 10064000;\r\n        numerators[ 87] = 10320000;\r\n        numerators[ 88] = 10585000;\r\n        numerators[ 89] = 10860000;\r\n        numerators[ 90] = 11144000;\r\n        numerators[ 91] = 11438000;\r\n        numerators[ 92] = 11742000;\r\n        numerators[ 93] = 12056000;\r\n        numerators[ 94] = 12380000;\r\n        numerators[ 95] = 12380000;\r\n        numerators[ 96] = 12714000;\r\n        numerators[ 97] = 13058000;\r\n        numerators[ 98] = 13411000;\r\n        numerators[ 99] = 13774000;\r\n        numerators[100] = 14145000;\r\n        numerators[101] = 14525000;\r\n        numerators[102] = 14913000;\r\n        numerators[103] = 15000000;\r\n        numerators[104] = 15000000;\r\n    }\r\n\r\n    /**\r\n     * @dev Compute the amount of SGA received upon conversion of a given SGN amount at a given minting-point.\r\n     * @param _amount The amount of SGN.\r\n     * @param _index The minting-point index.\r\n     * @return The amount of SGA received upon conversion.\r\n     */\r\n    function sgn2sga(uint256 _amount, uint256 _index) external view returns (uint256) {\r\n        assert(_amount \u003C= MAX_AMOUNT);\r\n        assert(_index \u003C numerators.length);\r\n        return _amount * numerators[_index] / DENOMINATOR;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022sgn2sga\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022DENOMINATOR\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MAX_AMOUNT\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022numerators\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022VERSION\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"SGNConversionManager","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"1","Runs":"6000","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://c6e15e01f2cbb1908ac655a31b384945322269f7fa2a085fdb167cceed50cd97"}]