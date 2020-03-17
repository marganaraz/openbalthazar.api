[{"SourceCode":"pragma solidity ^0.5.0;\r\npragma experimental ABIEncoderV2;\r\n\r\ninterface IERC20 {\r\n    function totalSupply() external view returns (uint256);\r\n    function balanceOf(address account) external view returns (uint256);\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n    function decimals() external view returns (uint8);\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\ncontract Context {\r\n    constructor () internal { }\r\n    // solhint-disable-previous-line no-empty-blocks\r\n\r\n    function _msgSender() internal view returns (address payable) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view returns (bytes memory) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}\r\ncontract Ownable is Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n    constructor () internal {\r\n        _owner = _msgSender();\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n    function isOwner() public view returns (bool) {\r\n        return _msgSender() == _owner;\r\n    }\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\nlibrary SafeMath {\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003E 0, errorMessage);\r\n        uint256 c = a / b;\r\n\r\n        return c;\r\n    }\r\n    function divCeil(\r\n        uint256 a,\r\n        uint256 b\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        uint256 quotient = div(a, b);\r\n        uint256 remainder = a - quotient * b;\r\n        if (remainder \u003E 0) {\r\n            return quotient \u002B 1;\r\n        } else {\r\n            return quotient;\r\n        }\r\n    }\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\nlibrary Decimal {\r\n    using SafeMath for uint256;\r\n\r\n    uint256 constant BASE = 10**18;\r\n\r\n    function one()\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        return BASE;\r\n    }\r\n\r\n    function onePlus(\r\n        uint256 d\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        return d.add(BASE);\r\n    }\r\n\r\n    function mulFloor(\r\n        uint256 target,\r\n        uint256 d\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        return target.mul(d) / BASE;\r\n    }\r\n\r\n    function mulCeil(\r\n        uint256 target,\r\n        uint256 d\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        return target.mul(d).divCeil(BASE);\r\n    }\r\n\r\n    function divFloor(\r\n        uint256 target,\r\n        uint256 d\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        return target.mul(BASE).div(d);\r\n    }\r\n\r\n    function divCeil(\r\n        uint256 target,\r\n        uint256 d\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        return target.mul(BASE).divCeil(d);\r\n    }\r\n}\r\n\r\nlibrary Address {\r\n    function isContract(address account) internal view returns (bool) {\r\n        bytes32 codehash;\r\n        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;\r\n        // solhint-disable-next-line no-inline-assembly\r\n        assembly { codehash := extcodehash(account) }\r\n        return (codehash != 0x0 \u0026\u0026 codehash != accountHash);\r\n    }\r\n    function toPayable(address account) internal pure returns (address payable) {\r\n        return address(uint160(account));\r\n    }\r\n    function sendValue(address payable recipient, uint256 amount) internal {\r\n        require(address(this).balance \u003E= amount, \u0022Address: insufficient balance\u0022);\r\n\r\n        // solhint-disable-next-line avoid-call-value\r\n        (bool success, ) = recipient.call.value(amount)(\u0022\u0022);\r\n        require(success, \u0022Address: unable to send value, recipient may have reverted\u0022);\r\n    }\r\n}\r\n\r\n// Compound\r\ninterface Compound {\r\n  function interestRateModel() external view returns (address);\r\n  function reserveFactorMantissa() external view returns (uint256);\r\n  function totalBorrows() external view returns (uint256);\r\n  function totalReserves() external view returns (uint256);\r\n\r\n  function supplyRatePerBlock() external view returns (uint);\r\n  function getCash() external view returns (uint256);\r\n}\r\n\r\n// Fulcrum\r\ninterface Fulcrum {\r\n  function supplyInterestRate() external view returns (uint256);\r\n  function nextSupplyInterestRate(uint256 supplyAmount) external view returns (uint256);\r\n}\r\n\r\ninterface DyDx {\r\n  struct val {\r\n       uint256 value;\r\n   }\r\n\r\n   struct set {\r\n      uint128 borrow;\r\n      uint128 supply;\r\n  }\r\n\r\n  function getEarningsRate() external view returns (val memory);\r\n  function getMarketInterestRate(uint256 marketId) external view returns (val memory);\r\n  function getMarketTotalPar(uint256 marketId) external view returns (set memory);\r\n}\r\n\r\ninterface LendingPoolAddressesProvider {\r\n    function getLendingPoolCore() external view returns (address);\r\n}\r\n\r\ninterface LendingPoolCore  {\r\n  function getReserveCurrentLiquidityRate(address _reserve)\r\n  external\r\n  view\r\n  returns (\r\n      uint256 liquidityRate\r\n  );\r\n  function getReserveInterestRateStrategyAddress(address _reserve) external view returns (address);\r\n  function getReserveTotalBorrows(address _reserve) external view returns (uint256);\r\n  function getReserveTotalBorrowsStable(address _reserve) external view returns (uint256);\r\n  function getReserveTotalBorrowsVariable(address _reserve) external view returns (uint256);\r\n  function getReserveCurrentAverageStableBorrowRate(address _reserve)\r\n     external\r\n     view\r\n     returns (uint256);\r\n  function getReserveAvailableLiquidity(address _reserve) external view returns (uint256);\r\n}\r\n\r\ninterface IReserveInterestRateStrategy {\r\n\r\n    function getBaseVariableBorrowRate() external view returns (uint256);\r\n    function calculateInterestRates(\r\n        address _reserve,\r\n        uint256 _utilizationRate,\r\n        uint256 _totalBorrowsStable,\r\n        uint256 _totalBorrowsVariable,\r\n        uint256 _averageStableBorrowRate)\r\n    external\r\n    view\r\n    returns (uint256 liquidityRate, uint256 stableBorrowRate, uint256 variableBorrowRate);\r\n}\r\n\r\ninterface InterestRateModel {\r\n  function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) external view returns (uint);\r\n}\r\n\r\ncontract Structs {\r\n  struct Asset {\r\n    address lendingPool;\r\n    address priceOralce;\r\n    address interestModel;\r\n  }\r\n}\r\n\r\ncontract IDDEX is Structs {\r\n\r\n  function getInterestRates(address token, uint256 extraBorrowAmount)\r\n    external\r\n    view\r\n    returns (uint256 borrowInterestRate, uint256 supplyInterestRate);\r\n  function getIndex(address token)\r\n    external\r\n    view\r\n    returns (uint256 supplyIndex, uint256 borrowIndex);\r\n  function getTotalSupply(address asset)\r\n    external\r\n    view\r\n    returns (uint256 amount);\r\n  function getTotalBorrow(address asset)\r\n    external\r\n    view\r\n    returns (uint256 amount);\r\n  function getAsset(address token)\r\n    external\r\n    view returns (Asset memory asset);\r\n}\r\n\r\ninterface IDDEXModel {\r\n  function polynomialInterestModel(uint256 borrowRatio) external view returns (uint256);\r\n}\r\n\r\ninterface ILendF {\r\n  function getSupplyBalance(address account, address token)\r\n    external\r\n    view\r\n    returns (uint256);\r\n  function supplyBalances(address account, address token)\r\n    external\r\n    view\r\n    returns (uint256 principal, uint256 interestIndex);\r\n  function supply(address asset, uint256 amount) external;\r\n  function withdraw(address asset, uint256 amount) external;\r\n  function markets(address asset) external view returns (\r\n    bool isSupported,\r\n    uint256 blockNumber,\r\n    address interestRateModel,\r\n    uint256 totalSupply,\r\n    uint256 supplyRateMantissa,\r\n    uint256 supplyIndex,\r\n    uint256 totalBorrows,\r\n    uint256 borrowRateMantissa,\r\n    uint256 borrowIndex\r\n  );\r\n}\r\n\r\ninterface ILendFModel {\r\n    function getSupplyRate(address asset, uint cash, uint borrows) external view returns (uint, uint);\r\n}\r\n\r\n\r\n\r\ncontract APRWithPoolOracle is Ownable, Structs {\r\n  using SafeMath for uint256;\r\n  using Address for address;\r\n\r\n  uint256 DECIMAL = 10 ** 18;\r\n\r\n  address public DYDX;\r\n  address public AAVE;\r\n  address public DDEX;\r\n  address public LENDF;\r\n\r\n  uint256 public liquidationRatio;\r\n\r\n  constructor() public {\r\n    DYDX = address(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e);\r\n    AAVE = address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8);\r\n    DDEX = address(0x241e82C79452F51fbfc89Fac6d912e021dB1a3B7);\r\n    LENDF = address(0x0eEe3E3828A45f7601D5F54bF49bB01d1A9dF5ea);\r\n    liquidationRatio = 50000000000000000;\r\n  }\r\n\r\n  function set_new_AAVE(address _new_AAVE) public onlyOwner {\r\n      AAVE = _new_AAVE;\r\n  }\r\n  function set_new_DDEX(address _new_DDEX) public onlyOwner {\r\n      DDEX = _new_DDEX;\r\n  }\r\n  function set_new_DYDX(address _new_DYDX) public onlyOwner {\r\n      DYDX = _new_DYDX;\r\n  }\r\n  function set_new_LENDF(address _new_LENDF) public onlyOwner {\r\n      LENDF = _new_LENDF;\r\n  }\r\n  function set_new_Ratio(uint256 _new_Ratio) public onlyOwner {\r\n      liquidationRatio = _new_Ratio;\r\n  }\r\n\r\n  function getLENDFAPR(address token) public view returns (uint256) {\r\n    (,,,,uint256 supplyRateMantissa,,,,) = ILendF(LENDF).markets(token);\r\n    return supplyRateMantissa.mul(2102400);\r\n  }\r\n\r\n  function getLENDFAPRAdjusted(address token, uint256 supply) public view returns (uint256) {\r\n    if (token == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)) {\r\n      return 0;\r\n    }\r\n    uint256 totalCash = IERC20(token).balanceOf(LENDF).add(supply);\r\n    (,, address interestRateModel,,,, uint256 totalBorrows,,) = ILendF(LENDF).markets(token);\r\n    if (interestRateModel == address(0)) {\r\n      return 0;\r\n    }\r\n    (, uint256 supplyRateMantissa) = ILendFModel(interestRateModel).getSupplyRate(token, totalCash, totalBorrows);\r\n    return supplyRateMantissa.mul(2102400);\r\n  }\r\n\r\n  function getDDEXAPR(address token) public view returns (uint256) {\r\n    if (token == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)) {\r\n      token = address(0x000000000000000000000000000000000000000E);\r\n    }\r\n    (uint256 supplyIndex,) = IDDEX(DDEX).getIndex(token);\r\n    if (supplyIndex == 0) {\r\n      return 0;\r\n    }\r\n    (,uint256 supplyRate) = IDDEX(DDEX).getInterestRates(token, 0);\r\n    return supplyRate;\r\n  }\r\n  function getDDEXAPRAdjusted(address token, uint256 _supply) public view returns (uint256) {\r\n    if (token == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)) {\r\n      token = address(0x000000000000000000000000000000000000000E);\r\n    }\r\n    (uint256 supplyIndex,) = IDDEX(DDEX).getIndex(token);\r\n    if (supplyIndex == 0) {\r\n      return 0;\r\n    }\r\n    uint256 supply = IDDEX(DDEX).getTotalSupply(token).add(_supply);\r\n    uint256 borrow = IDDEX(DDEX).getTotalBorrow(token);\r\n    uint256 borrowRatio = borrow.mul(Decimal.one()).div(supply);\r\n    address interestRateModel = IDDEX(DDEX).getAsset(token).interestModel;\r\n    uint256 borrowRate = IDDEXModel(interestRateModel).polynomialInterestModel(borrowRatio);\r\n    uint256 borrowInterest = Decimal.mulCeil(borrow, borrowRate);\r\n    uint256 supplyInterest = Decimal.mulFloor(borrowInterest, Decimal.one().sub(liquidationRatio));\r\n    return Decimal.divFloor(supplyInterest, supply);\r\n  }\r\n\r\n  function getCompoundAPR(address token) public view returns (uint256) {\r\n    return Compound(token).supplyRatePerBlock().mul(2102400);\r\n  }\r\n\r\n  function getCompoundAPRAdjusted(address token, uint256 _supply) public view returns (uint256) {\r\n    Compound c = Compound(token);\r\n    InterestRateModel i = InterestRateModel(Compound(token).interestRateModel());\r\n    uint256 cashPrior = c.getCash().add(_supply);\r\n    return i.getSupplyRate(cashPrior, c.totalBorrows(), c.totalReserves().add(_supply), c.reserveFactorMantissa()).mul(2102400);\r\n  }\r\n\r\n  function getFulcrumAPR(address token) public view returns(uint256) {\r\n    return Fulcrum(token).supplyInterestRate().div(100);\r\n  }\r\n\r\n  function getFulcrumAPRAdjusted(address token, uint256 _supply) public view returns(uint256) {\r\n    return Fulcrum(token).nextSupplyInterestRate(_supply).div(100);\r\n  }\r\n\r\n  function getDyDxAPR(uint256 marketId) public view returns(uint256) {\r\n    uint256 rate      = DyDx(DYDX).getMarketInterestRate(marketId).value;\r\n    uint256 aprBorrow = rate * 31622400;\r\n    uint256 borrow    = DyDx(DYDX).getMarketTotalPar(marketId).borrow;\r\n    uint256 supply    = DyDx(DYDX).getMarketTotalPar(marketId).supply;\r\n    uint256 usage     = (borrow * DECIMAL) / supply;\r\n    uint256 apr       = (((aprBorrow * usage) / DECIMAL) * DyDx(DYDX).getEarningsRate().value) / DECIMAL;\r\n    return apr;\r\n  }\r\n  function getDyDxAPRAdjusted(uint256 marketId, uint256 _supply) public view returns(uint256) {\r\n    uint256 rate      = DyDx(DYDX).getMarketInterestRate(marketId).value;\r\n    uint256 aprBorrow = rate * 31622400;\r\n    uint256 borrow    = DyDx(DYDX).getMarketTotalPar(marketId).borrow;\r\n    uint256 supply    = DyDx(DYDX).getMarketTotalPar(marketId).supply;\r\n    supply = supply.add(_supply);\r\n    uint256 usage     = (borrow * DECIMAL) / supply;\r\n    uint256 apr       = (((aprBorrow * usage) / DECIMAL) * DyDx(DYDX).getEarningsRate().value) / DECIMAL;\r\n    return apr;\r\n  }\r\n\r\n  function getAaveCore() public view returns (address) {\r\n    return address(LendingPoolAddressesProvider(AAVE).getLendingPoolCore());\r\n  }\r\n\r\n  function getAaveAPR(address token) public view returns (uint256) {\r\n    LendingPoolCore core = LendingPoolCore(LendingPoolAddressesProvider(AAVE).getLendingPoolCore());\r\n    return core.getReserveCurrentLiquidityRate(token).div(1e9);\r\n  }\r\n\r\n  function getAaveAPRAdjusted(address token, uint256 _supply) public view returns (uint256) {\r\n    LendingPoolCore core = LendingPoolCore(LendingPoolAddressesProvider(AAVE).getLendingPoolCore());\r\n    IReserveInterestRateStrategy apr = IReserveInterestRateStrategy(core.getReserveInterestRateStrategyAddress(token));\r\n    (uint256 newLiquidityRate,,) = apr.calculateInterestRates(\r\n      token,\r\n      core.getReserveAvailableLiquidity(token).add(_supply),\r\n      core.getReserveTotalBorrowsStable(token),\r\n      core.getReserveTotalBorrowsVariable(token),\r\n      core.getReserveCurrentAverageStableBorrowRate(token)\r\n    );\r\n    return newLiquidityRate.div(1e9);\r\n  }\r\n\r\n  // incase of half-way error\r\n  function inCaseTokenGetsStuck(IERC20 _TokenAddress) onlyOwner public {\r\n      uint qty = _TokenAddress.balanceOf(address(this));\r\n      _TokenAddress.transfer(msg.sender, qty);\r\n  }\r\n  // incase of half-way error\r\n  function inCaseETHGetsStuck() onlyOwner public{\r\n      (bool result, ) = msg.sender.call.value(address(this).balance)(\u0022\u0022);\r\n      require(result, \u0022transfer of ETH failed\u0022);\r\n  }\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022AAVE\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022DDEX\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022DYDX\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022LENDF\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getAaveAPR\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_supply\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getAaveAPRAdjusted\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAaveCore\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getCompoundAPR\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_supply\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getCompoundAPRAdjusted\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getDDEXAPR\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_supply\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getDDEXAPRAdjusted\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022marketId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getDyDxAPR\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022marketId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_supply\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getDyDxAPRAdjusted\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getFulcrumAPR\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_supply\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getFulcrumAPRAdjusted\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getLENDFAPR\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022supply\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getLENDFAPRAdjusted\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022inCaseETHGetsStuck\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022_TokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022inCaseTokenGetsStuck\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022liquidationRatio\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_new_AAVE\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022set_new_AAVE\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_new_DDEX\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022set_new_DDEX\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_new_DYDX\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022set_new_DYDX\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_new_LENDF\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022set_new_LENDF\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_new_Ratio\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022set_new_Ratio\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"APRWithPoolOracle","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://11158ede95775c470726b56c783c1509b4d3c662d1875ae7a7df1c91e36334bc"}]