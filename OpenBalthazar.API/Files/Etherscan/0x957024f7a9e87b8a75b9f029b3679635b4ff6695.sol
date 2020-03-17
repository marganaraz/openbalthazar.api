[{"SourceCode":"pragma solidity 0.4.25;\n\n// File: contracts/saga/interfaces/IPriceBandCalculator.sol\n\n/**\n * @title Price Band Calculator Interface.\n */\ninterface IPriceBandCalculator {\n    /**\n     * @dev Deduct price-band from a given amount of SDR.\n     * @param _sdrAmount The amount of SDR.\n     * @param _sgaTotal The total amount of SGA.\n     * @param _alpha The alpha-value of the current interval.\n     * @param _beta The beta-value of the current interval.\n     * @return The amount of SDR minus the price-band.\n     */\n    function buy(uint256 _sdrAmount, uint256 _sgaTotal, uint256 _alpha, uint256 _beta) external pure returns (uint256);\n\n    /**\n     * @dev Deduct price-band from a given amount of SDR.\n     * @param _sdrAmount The amount of SDR.\n     * @param _sgaTotal The total amount of SGA.\n     * @param _alpha The alpha-value of the current interval.\n     * @param _beta The beta-value of the current interval.\n     * @return The amount of SDR minus the price-band.\n     */\n    function sell(uint256 _sdrAmount, uint256 _sgaTotal, uint256 _alpha, uint256 _beta) external pure returns (uint256);\n}\n\n// File: openzeppelin-solidity/contracts/math/SafeMath.sol\n\n/**\n * @title SafeMath\n * @dev Math operations with safety checks that revert on error\n */\nlibrary SafeMath {\n\n  /**\n  * @dev Multiplies two numbers, reverts on overflow.\n  */\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n    // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\n    // benefit is lost if \u0027b\u0027 is also tested.\n    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\n    if (a == 0) {\n      return 0;\n    }\n\n    uint256 c = a * b;\n    require(c / a == b);\n\n    return c;\n  }\n\n  /**\n  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.\n  */\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\n    require(b \u003E 0); // Solidity only automatically asserts when dividing by 0\n    uint256 c = a / b;\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\n\n    return c;\n  }\n\n  /**\n  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).\n  */\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n    require(b \u003C= a);\n    uint256 c = a - b;\n\n    return c;\n  }\n\n  /**\n  * @dev Adds two numbers, reverts on overflow.\n  */\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\n    uint256 c = a \u002B b;\n    require(c \u003E= a);\n\n    return c;\n  }\n\n  /**\n  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),\n  * reverts when dividing by zero.\n  */\n  function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n    require(b != 0);\n    return a % b;\n  }\n}\n\n// File: contracts/saga/PriceBandCalculator.sol\n\n/**\n * Details of usage of licenced software see here: https://www.saga.org/software/readme_v1\n */\n\n/**\n * @title Price Band Calculator.\n */\ncontract PriceBandCalculator is IPriceBandCalculator {\n    string public constant VERSION = \u00221.0.0\u0022;\n\n    using SafeMath for uint256;\n\n    // Auto-generated via \u0027AutoGenerate/PriceBandCalculator/PrintConstants.py\u0027\n    uint256 public constant ONE     = 1000000000;\n    uint256 public constant MIN_RR  = 1000000000000000000000000000000000;\n    uint256 public constant MAX_RR  = 10000000000000000000000000000000000;\n    uint256 public constant GAMMA   = 179437500000000000000000000000000000000000;\n    uint256 public constant DELTA   = 29437500;\n    uint256 public constant BUY_N   = 2000;\n    uint256 public constant BUY_D   = 2003;\n    uint256 public constant SELL_N  = 1997;\n    uint256 public constant SELL_D  = 2000;\n    uint256 public constant MAX_SDR = 500786938745138896681892746900;\n\n    /**\n     * Denote r = sdrAmount\n     * Denote n = sgaTotal\n     * Denote a = alpha / A_B_SCALE\n     * Denote b = beta  / A_B_SCALE\n     * Denote c = GAMMA / ONE / A_B_SCALE\n     * Denote d = DELTA / ONE\n     * Denote w = c / (a - b * n) - d\n     * Return r / (1 \u002B w)\n     */\n    function buy(uint256 _sdrAmount, uint256 _sgaTotal, uint256 _alpha, uint256 _beta) external pure returns (uint256) {\n        assert(_sdrAmount \u003C= MAX_SDR);\n        uint256 reserveRatio = _alpha.sub(_beta.mul(_sgaTotal));\n        assert(MIN_RR \u003C= reserveRatio \u0026\u0026 reserveRatio \u003C= MAX_RR);\n        uint256 variableFix = _sdrAmount * (reserveRatio * ONE) / (reserveRatio * (ONE - DELTA) \u002B GAMMA);\n        uint256 constantFix = _sdrAmount * BUY_N / BUY_D;\n        return constantFix \u003C= variableFix ? constantFix : variableFix;\n    }\n\n    /**\n     * Denote r = sdrAmount\n     * Denote n = sgaTotal\n     * Denote a = alpha / A_B_SCALE\n     * Denote b = beta  / A_B_SCALE\n     * Denote c = GAMMA / ONE / A_B_SCALE\n     * Denote d = DELTA / ONE\n     * Denote w = c / (a - b * n) - d\n     * Return r * (1 - w)\n     */\n    function sell(uint256 _sdrAmount, uint256 _sgaTotal, uint256 _alpha, uint256 _beta) external pure returns (uint256) {\n        assert(_sdrAmount \u003C= MAX_SDR);\n        uint256 reserveRatio = _alpha.sub(_beta.mul(_sgaTotal));\n        assert(MIN_RR \u003C= reserveRatio \u0026\u0026 reserveRatio \u003C= MAX_RR);\n        uint256 variableFix = _sdrAmount * (reserveRatio * (ONE \u002B DELTA) - GAMMA) / (reserveRatio * ONE);\n        uint256 constantFix = _sdrAmount * SELL_N / SELL_D;\n        return constantFix \u003C= variableFix ? constantFix : variableFix;\n    }\n}\n","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_sdrAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_sgaTotal\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_alpha\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_beta\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022buy\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MAX_RR\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_sdrAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_sgaTotal\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_alpha\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_beta\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022sell\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022SELL_D\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MIN_RR\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022BUY_D\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022SELL_N\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ONE\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022BUY_N\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MAX_SDR\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022GAMMA\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022DELTA\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022VERSION\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"PriceBandCalculator","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"1","Runs":"6000","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://88df20e9f99e8fd4d2f4e969589d981aa91d9c9d7b3b792e343531069f139c06"}]