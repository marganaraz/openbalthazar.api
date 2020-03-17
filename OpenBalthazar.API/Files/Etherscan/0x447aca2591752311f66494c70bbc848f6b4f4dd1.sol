[{"SourceCode":"pragma solidity ^0.5.8;\r\n\r\ninterface TubInterface {\r\n    function open() external returns (bytes32);\r\n    function join(uint) external;\r\n    function exit(uint) external;\r\n    function lock(bytes32, uint) external;\r\n    function free(bytes32, uint) external;\r\n    function draw(bytes32, uint) external;\r\n    function wipe(bytes32, uint) external;\r\n    function give(bytes32, address) external;\r\n    function shut(bytes32) external;\r\n    function cups(bytes32) external view returns (address, uint, uint, uint);\r\n    function gem() external view returns (TokenInterface);\r\n    function gov() external view returns (TokenInterface);\r\n    function skr() external view returns (TokenInterface);\r\n    function sai() external view returns (TokenInterface);\r\n    function ink(bytes32) external view returns (uint);\r\n    function tab(bytes32) external returns (uint);\r\n    function rap(bytes32) external returns (uint);\r\n    function per() external view returns (uint);\r\n    function pep() external view returns (PepInterface);\r\n}\r\n\r\ninterface TokenInterface {\r\n    function allowance(address, address) external view returns (uint);\r\n    function balanceOf(address) external view returns (uint);\r\n    function approve(address, uint) external;\r\n    function transfer(address, uint) external returns (bool);\r\n    function transferFrom(address, address, uint) external returns (bool);\r\n    function deposit() external payable;\r\n    function withdraw(uint) external;\r\n}\r\n\r\ninterface PepInterface {\r\n    function peek() external returns (bytes32, bool);\r\n}\r\n\r\ninterface UniswapExchange {\r\n    function getEthToTokenOutputPrice(uint256 tokensBought) external view returns (uint256 ethSold);\r\n    function getTokenToEthOutputPrice(uint256 ethBought) external view returns (uint256 tokensSold);\r\n    function tokenToTokenSwapOutput(\r\n        uint256 tokensBought,\r\n        uint256 maxTokensSold,\r\n        uint256 maxEthSold,\r\n        uint256 deadline,\r\n        address tokenAddr\r\n    ) external returns (uint256  tokensSold);\r\n    function ethToTokenSwapOutput(uint256 tokensBought, uint256 deadline) external payable returns (uint256  ethSold);\r\n}\r\n\r\ninterface UniswapFactoryInterface {\r\n    function getExchange(address token) external view returns (address exchange);\r\n}\r\n\r\ninterface MCDInterface {\r\n    function swapDaiToSai(uint wad) external;\r\n    function migrate(bytes32 cup) external returns (uint cdp);\r\n}\r\n\r\ninterface PoolInterface {\r\n    function accessToken(address[] calldata ctknAddr, uint[] calldata tknAmt, bool isCompound) external;\r\n    function paybackToken(address[] calldata ctknAddr, bool isCompound) external payable;\r\n}\r\n\r\ninterface OtcInterface {\r\n    function getPayAmount(address, address, uint) external view returns (uint);\r\n    function buyAllAmount(\r\n        address,\r\n        uint,\r\n        address,\r\n        uint\r\n    ) external;\r\n}\r\n\r\ncontract DSMath {\r\n\r\n    function add(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x \u002B y) \u003E= x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    function sub(uint x, uint y) internal pure returns (uint z) {\r\n        z = x - y \u003C= x ? x - y : 0;\r\n    }\r\n\r\n    function mul(uint x, uint y) internal pure returns (uint z) {\r\n        require(y == 0 || (z = x * y) / y == x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    uint constant WAD = 10 ** 18;\r\n    uint constant RAY = 10 ** 27;\r\n\r\n    function rmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), RAY / 2) / RAY;\r\n    }\r\n\r\n    function wmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), WAD / 2) / WAD;\r\n    }\r\n\r\n    function rdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, RAY), y / 2) / y;\r\n    }\r\n\r\n    function wdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, WAD), y / 2) / y;\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract Helpers is DSMath {\r\n\r\n    /**\r\n     * @dev get MakerDAO CDP engine\r\n     */\r\n    function getSaiTubAddress() public pure returns (address sai) {\r\n        sai = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;\r\n    }\r\n    \r\n    /**\r\n     * @dev get Compound WETH Address\r\n     */\r\n    function getWETHAddress() public pure returns (address wethAddr) {\r\n        wethAddr = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // main\r\n    }\r\n\r\n    /**\r\n     * @dev get Compound OTC Address\r\n     */\r\n    function getOtcAddress() public pure returns (address otcAddr) {\r\n        otcAddr = 0x39755357759cE0d7f32dC8dC45414CCa409AE24e; // main\r\n    }\r\n\r\n    /**\r\n     * @dev setting allowance to compound for the \u0022user proxy\u0022 if required\r\n     */\r\n    function setApproval(address erc20, uint srcAmt, address to) internal {\r\n        TokenInterface erc20Contract = TokenInterface(erc20);\r\n        uint tokenAllowance = erc20Contract.allowance(address(this), to);\r\n        if (srcAmt \u003E tokenAllowance) {\r\n            erc20Contract.approve(to, 2**255);\r\n        }\r\n    }\r\n\r\n}\r\n\r\ncontract MkrResolver is Helpers {\r\n    event LogMkr(uint payAmt, uint mkrAmt);\r\n    function swapToMkrOtc(address tokenAddr, uint govFee) external payable {\r\n        TokenInterface mkr = TubInterface(getSaiTubAddress()).gov();\r\n        uint payAmt = OtcInterface(getOtcAddress()).getPayAmount(tokenAddr, address(mkr), govFee);\r\n        if (tokenAddr == getWETHAddress()) {\r\n            TokenInterface weth = TokenInterface(getWETHAddress());\r\n            weth.deposit.value(payAmt)();\r\n        } else {\r\n            require(TokenInterface(tokenAddr).transferFrom(msg.sender, address(this), payAmt), \u0022Tranfer-failed\u0022);\r\n        }\r\n        setApproval(tokenAddr, payAmt, getOtcAddress());\r\n        OtcInterface(getOtcAddress()).buyAllAmount(\r\n            address(mkr),\r\n            govFee,\r\n            tokenAddr,\r\n            payAmt\r\n        );\r\n        emit LogMkr(payAmt, mkr.balanceOf(address(this)));\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getWETHAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022wethAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getOtcAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022otcAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getSaiTubAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022sai\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenAddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022govFee\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022swapToMkrOtc\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022payAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022mkrAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogMkr\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"MkrResolver","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://d9230d78f4ba8a696169f03d07260c4b29e904b7acefd30eea9df6af8fa6bfde"}]