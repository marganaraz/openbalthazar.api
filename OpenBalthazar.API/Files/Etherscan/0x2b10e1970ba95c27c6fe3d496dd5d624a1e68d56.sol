[{"SourceCode":"pragma solidity ^0.5.7;\r\n\r\ninterface RegistryInterface {\r\n    function proxies(address) external view returns (address);\r\n}\r\n\r\ninterface UserWalletInterface {\r\n    function owner() external view returns (address);\r\n}\r\n\r\ninterface CTokenInterface {\r\n    function borrow(uint borrowAmount) external returns (uint);\r\n    function transfer(address, uint) external returns (bool);\r\n    function repayBorrow(uint repayAmount) external returns (uint);\r\n    function underlying() external view returns (address);\r\n    function borrowBalanceCurrent(address account) external returns (uint);\r\n}\r\n\r\ninterface CETHInterface {\r\n    function balanceOf(address) external view returns (uint);\r\n    function mint() external payable; // For ETH\r\n    function repayBorrow() external payable; // For ETH\r\n    function borrowBalanceCurrent(address account) external returns (uint);\r\n    function redeem(uint redeemAmount) external returns (uint);\r\n}\r\n\r\ninterface ComptrollerInterface {\r\n    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);\r\n    function exitMarket(address cTokenAddress) external returns (uint);\r\n}\r\n\r\ninterface TubInterface {\r\n    function open() external returns (bytes32);\r\n    function join(uint) external;\r\n    function exit(uint) external;\r\n    function lock(bytes32, uint) external;\r\n    function free(bytes32, uint) external;\r\n    function draw(bytes32, uint) external;\r\n    function wipe(bytes32, uint) external;\r\n    function give(bytes32, address) external;\r\n    function shut(bytes32) external;\r\n    function cups(bytes32) external view returns (address, uint, uint, uint);\r\n    function gem() external view returns (TokenInterface);\r\n    function gov() external view returns (TokenInterface);\r\n    function skr() external view returns (TokenInterface);\r\n    function sai() external view returns (TokenInterface);\r\n    function ink(bytes32) external view returns (uint);\r\n    function tab(bytes32) external returns (uint);\r\n    function rap(bytes32) external returns (uint);\r\n    function per() external view returns (uint);\r\n    function pep() external view returns (PepInterface);\r\n}\r\n\r\ninterface TokenInterface {\r\n    function allowance(address, address) external view returns (uint);\r\n    function balanceOf(address) external view returns (uint);\r\n    function approve(address, uint) external;\r\n    function transfer(address, uint) external returns (bool);\r\n    function deposit() external payable;\r\n    function withdraw(uint) external;\r\n}\r\n\r\ninterface PepInterface {\r\n    function peek() external returns (bytes32, bool);\r\n}\r\n\r\n\r\ncontract DSMath {\r\n\r\n    function add(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x \u002B y) \u003E= x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    function mul(uint x, uint y) internal pure returns (uint z) {\r\n        require(y == 0 || (z = x * y) / y == x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    uint constant WAD = 10 ** 18;\r\n    uint constant RAY = 10 ** 27;\r\n\r\n    function rmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), RAY / 2) / RAY;\r\n    }\r\n\r\n    function rdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, RAY), y / 2) / y;\r\n    }\r\n\r\n    function wdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, WAD), y / 2) / y;\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract Helpers is DSMath {\r\n\r\n    // address public registry = 0x498b3BfaBE9F73db90D252bCD4Fa9548Cd0Fd981;\r\n    address public comptrollerAddr = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;  //main\r\n    // address public comptrollerAddr = 0x142D11CB90a2b40f7d0C55ed1804988DfC316fAe; // kovan\r\n    address public saiTubAddress = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;// main\r\n    // address public saiTubAddress = 0xa71937147b55Deb8a530C7229C442Fd3F31b7db2;\r\n\r\n    address payable public controllerOne = 0xf4B9aaae3AB39325D12EA62fCcD3c05266e07e21;\r\n    address payable public controllerTwo = 0xe866ecE4bbD0Ac75577225Ee2C464ef16DC8b1F3;\r\n\r\n    \r\n    address public usdcAddr = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;\r\n    address public cEth = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;\r\n    address public cDai = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;\r\n    address public cUsdc = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;\r\n    \r\n    //test\r\n    // address public usdcAddr = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;\r\n    // address public cEth = 0xD83F707f003A1f0B1535028AB356FCE2667ab855;\r\n    // address public cDai = 0x0A1e4D0B5c71B955c0a5993023fc48bA6E380496;\r\n    // address public cUsdc = 0xDff375162cfE7D77473C1BEC4560dEDE974E138c;\r\n\r\n    bytes32 public CDPID;\r\n\r\n    // /**\r\n    //  * FOR SECURITY PURPOSE\r\n    //  * only InstaDApp smart wallets can access the liquidity pool contract\r\n    //  */\r\n    // modifier isUserWallet {\r\n    //     address userAdd = UserWalletInterface(msg.sender).owner();\r\n    //     address walletAdd = RegistryInterface(registry).proxies(userAdd);\r\n    //     require(walletAdd != address(0), \u0022not-user-wallet\u0022);\r\n    //     require(walletAdd == msg.sender, \u0022not-wallet-owner\u0022);\r\n    //     _;\r\n    // }\r\n\r\n}\r\n\r\n\r\ncontract CompoundResolver is Helpers {\r\n\r\n    function mintAndBorrow(address[] memory cErc20, uint[] memory tknAmt) internal {\r\n        CETHInterface(cEth).mint.value(address(this).balance)();\r\n        for (uint i = 0; i \u003C cErc20.length; i\u002B\u002B) {\r\n            if (tknAmt[i] \u003E 0) {\r\n                CTokenInterface ctknContract = CTokenInterface(cErc20[i]);\r\n                if (cErc20[i] != cEth) {\r\n                    address tknAddr = ctknContract.underlying();\r\n                    assert(ctknContract.borrow(tknAmt[i]) == 0);\r\n                    assert(TokenInterface(tknAddr).transfer(msg.sender, tknAmt[i]));\r\n                } else {\r\n                    assert(ctknContract.borrow(tknAmt[i]) == 0);\r\n                    msg.sender.transfer(tknAmt[i]);\r\n                }\r\n            }\r\n        }\r\n    }\r\n\r\n    function paybackAndWithdraw(address[] memory cErc20) internal {\r\n        CETHInterface cethContract = CETHInterface(cEth);\r\n        for (uint i = 0; i \u003C cErc20.length; i\u002B\u002B) {\r\n            CTokenInterface ctknContract = CTokenInterface(cErc20[i]);\r\n            uint tknBorrowed = ctknContract.borrowBalanceCurrent(address(this));\r\n            if (tknBorrowed \u003E 0) {\r\n                if (cErc20[i] != cEth) {\r\n                    assert(ctknContract.repayBorrow(tknBorrowed) == 0);\r\n                } else {\r\n                    cethContract.repayBorrow.value(tknBorrowed);\r\n                }\r\n            }\r\n        }\r\n        uint ethSupplied = cethContract.balanceOf(address(this));\r\n        if (ethSupplied \u003E 0) {\r\n            assert(cethContract.redeem(ethSupplied) == 0);\r\n        }\r\n    }\r\n}\r\n\r\n\r\ncontract MakerResolver is CompoundResolver {\r\n\r\n    function lockAndDraw(uint _wad) internal {\r\n        uint ethToSupply = address(this).balance;\r\n        bytes32 cup = CDPID;\r\n        address tubAddr = saiTubAddress;\r\n\r\n        TubInterface tub = TubInterface(tubAddr);\r\n        TokenInterface weth = tub.gem();\r\n\r\n        (address lad,,,) = tub.cups(cup);\r\n        require(lad == address(this), \u0022cup-not-owned\u0022);\r\n\r\n        weth.deposit.value(ethToSupply)();\r\n\r\n        uint ink = rdiv(ethToSupply, tub.per());\r\n        ink = rmul(ink, tub.per()) \u003C= ethToSupply ? ink : ink - 1;\r\n\r\n        tub.join(ink);\r\n        tub.lock(cup, ink);\r\n\r\n\r\n        if (_wad \u003E 0) {\r\n            tub.draw(cup, _wad);\r\n            tub.sai().transfer(msg.sender, _wad);\r\n        }\r\n    }\r\n\r\n    function wipeAndFree() internal {\r\n        TubInterface tub = TubInterface(saiTubAddress);\r\n        TokenInterface weth = tub.gem();\r\n\r\n        bytes32 cup = CDPID;\r\n        uint _wad = tub.tab(cup);\r\n\r\n        if (_wad \u003E 0) {\r\n            (address lad,,,) = tub.cups(cup);\r\n            require(lad == address(this), \u0022cup-not-owned\u0022);\r\n\r\n            tub.wipe(cup, _wad);\r\n        }\r\n\r\n        // free ETH\r\n        uint _jam = rmul(tub.ink(cup), tub.per());\r\n        uint ink = rdiv(_jam, tub.per());\r\n        ink = rmul(ink, tub.per()) \u003C= _jam ? ink : ink - 1;\r\n        if (ink \u003E 0) {\r\n            tub.free(cup, ink);\r\n\r\n            tub.exit(ink);\r\n            uint freeJam = weth.balanceOf(address(this)); // withdraw possible previous stuck WETH as well\r\n            weth.withdraw(freeJam);\r\n        }\r\n    }\r\n}\r\n\r\ncontract ProvideLiquidity is MakerResolver {\r\n\r\n    /**\r\n     * @dev user =\u003E ETH deposits\r\n     */\r\n    mapping (address =\u003E uint) public deposits;\r\n\r\n    event LogDepositETH(address user, uint amt);\r\n    event LogWithdrawETH(address user, uint amt);\r\n\r\n    /**\r\n     * @dev deposit ETH\r\n     */\r\n    function depositETH() external payable {\r\n        deposits[msg.sender] \u002B= msg.value;\r\n        emit LogDepositETH(msg.sender, msg.value);\r\n    }\r\n\r\n    /**\r\n     * @dev withdraw ETH\r\n     */\r\n    function withdrawETH(uint amount) external returns (uint withdrawAmt) {\r\n        require(deposits[msg.sender] \u003E 0, \u0022no-balance\u0022);\r\n        withdrawAmt = amount \u003C deposits[msg.sender] ? amount : deposits[msg.sender];\r\n        msg.sender.transfer(withdrawAmt);\r\n        deposits[msg.sender] -= withdrawAmt;\r\n        emit LogWithdrawETH(msg.sender, withdrawAmt);\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract Access is ProvideLiquidity {\r\n\r\n    event LogLiquidityBorrow(address user, address[] ctknAddr, uint[] amount , bool isCompound);\r\n    event LogLiquidityPayback(address user, address[] ctknAddr, bool isCompound);\r\n\r\n    /**\r\n     * @dev borrow token and use them on InstaDApp\u0027s contract wallets\r\n     */\r\n    function accessToken(address[] calldata ctknAddr, uint[] calldata tknAmt, bool isCompound) external  {\r\n        if (ctknAddr.length \u003E 0) {\r\n            if (isCompound) {\r\n                mintAndBorrow(ctknAddr, tknAmt);\r\n            } else {\r\n                lockAndDraw(tknAmt[0]);\r\n            }\r\n        }\r\n        emit LogLiquidityBorrow(msg.sender, ctknAddr, tknAmt, isCompound);\r\n    }\r\n\r\n    /**\r\n     * @dev Payback borrowed token and from InstaDApp\u0027s contract wallets\r\n     */\r\n    function paybackToken(address[] calldata ctknAddr, bool isCompound) external payable {\r\n        if (isCompound) {\r\n            paybackAndWithdraw(ctknAddr);\r\n        } else {\r\n            wipeAndFree();\r\n        }\r\n        emit LogLiquidityPayback(msg.sender, ctknAddr, isCompound);\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract Controllers is Access {\r\n\r\n    modifier isController {\r\n        require(msg.sender == controllerOne || msg.sender == controllerTwo, \u0022not-controller\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * give approval to other addresses\r\n     */\r\n    function setApproval(address erc20, address to) external isController {\r\n        TokenInterface(erc20).approve(to, uint(-1));\r\n    }\r\n\r\n\r\n    /**\r\n     * enter compound market to enable borrowing\r\n     */\r\n    function enterMarket(address[] calldata cTknAddrArr) external isController {\r\n        ComptrollerInterface troller = ComptrollerInterface(comptrollerAddr);\r\n        troller.enterMarkets(cTknAddrArr);\r\n    }\r\n\r\n    /**\r\n     * enter compound market to disable borrowing\r\n     */\r\n    function exitMarket(address cErc20) external isController {\r\n        ComptrollerInterface troller = ComptrollerInterface(comptrollerAddr);\r\n        troller.exitMarket(cErc20);\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract Pool is Controllers {\r\n\r\n    constructor() public {\r\n        TubInterface tub = TubInterface(saiTubAddress);\r\n        CDPID = tub.open(); // new SCD CDP\r\n        TokenInterface weth = tub.gem();\r\n        TokenInterface peth = tub.skr();\r\n        TokenInterface dai = tub.sai();\r\n        TokenInterface mkr = tub.gov();\r\n        weth.approve(saiTubAddress, uint(-1));\r\n        peth.approve(saiTubAddress, uint(-1));\r\n        dai.approve(saiTubAddress, uint(-1));\r\n        mkr.approve(saiTubAddress, uint(-1));\r\n        dai.approve(cDai, uint(-1));\r\n        TokenInterface(usdcAddr).approve(cUsdc, uint(-1));\r\n        TokenInterface(cDai).approve(cDai, uint(-1));\r\n        TokenInterface(cUsdc).approve(cUsdc, uint(-1));\r\n        TokenInterface(cEth).approve(cEth, uint(-1));\r\n        address[] memory enterAddr = new address[](3);\r\n        enterAddr[0] = cEth;\r\n        enterAddr[1] = cUsdc;\r\n        enterAddr[2] = cDai;\r\n        ComptrollerInterface troller = ComptrollerInterface(comptrollerAddr);\r\n        troller.enterMarkets(enterAddr);\r\n    }\r\n    \r\n    function() external payable {}\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022controllerOne\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022comptrollerAddr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022ctknAddr\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022isCompound\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022paybackToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022CDPID\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022cTknAddrArr\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022enterMarket\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022saiTubAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022controllerTwo\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022ctknAddr\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022tknAmt\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022isCompound\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022accessToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022usdcAddr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022cDai\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022cEth\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022erc20\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setApproval\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022cUsdc\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022cErc20\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022exitMarket\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022withdrawAmt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022depositETH\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022deposits\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ctknAddr\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022isCompound\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022LogLiquidityBorrow\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ctknAddr\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022isCompound\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022LogLiquidityPayback\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogDepositETH\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amt\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogWithdrawETH\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Pool","CompilerVersion":"v0.5.7\u002Bcommit.6da8b019","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://ec0d074f7b4cc660f035f9e0163b1b28eb32cff0158988b141750dceb333eea4"}]