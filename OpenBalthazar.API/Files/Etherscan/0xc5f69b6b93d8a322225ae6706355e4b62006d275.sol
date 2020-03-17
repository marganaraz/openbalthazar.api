[{"SourceCode":"pragma solidity ^0.5.0;\r\npragma experimental ABIEncoderV2;\r\n\r\ninterface IERC20 {\r\n    function totalSupply() external view returns (uint256);\r\n    function balanceOf(address account) external view returns (uint256);\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\ncontract Context {\r\n    constructor () internal { }\r\n    // solhint-disable-previous-line no-empty-blocks\r\n\r\n    function _msgSender() internal view returns (address payable) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view returns (bytes memory) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}\r\n\r\ncontract ReentrancyGuard {\r\n    uint256 private _guardCounter;\r\n\r\n    constructor () internal {\r\n        _guardCounter = 1;\r\n    }\r\n\r\n    modifier nonReentrant() {\r\n        _guardCounter \u002B= 1;\r\n        uint256 localCounter = _guardCounter;\r\n        _;\r\n        require(localCounter == _guardCounter, \u0022ReentrancyGuard: reentrant call\u0022);\r\n    }\r\n}\r\n\r\ncontract Ownable is Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n    constructor () internal {\r\n        _owner = _msgSender();\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n    function isOwner() public view returns (bool) {\r\n        return _msgSender() == _owner;\r\n    }\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\nlibrary SafeMath {\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, errorMessage);\r\n        uint256 c = a / b;\r\n\r\n        return c;\r\n    }\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\nlibrary Address {\r\n    function isContract(address account) internal view returns (bool) {\r\n        bytes32 codehash;\r\n        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;\r\n        // solhint-disable-next-line no-inline-assembly\r\n        assembly { codehash := extcodehash(account) }\r\n        return (codehash != 0x0 \u0026\u0026 codehash != accountHash);\r\n    }\r\n    function toPayable(address account) internal pure returns (address payable) {\r\n        return address(uint160(account));\r\n    }\r\n    function sendValue(address payable recipient, uint256 amount) internal {\r\n        require(address(this).balance \u003E= amount, \u0022Address: insufficient balance\u0022);\r\n\r\n        // solhint-disable-next-line avoid-call-value\r\n        (bool success, ) = recipient.call.value(amount)(\u0022\u0022);\r\n        require(success, \u0022Address: unable to send value, recipient may have reverted\u0022);\r\n    }\r\n}\r\n\r\nlibrary SafeERC20 {\r\n    using SafeMath for uint256;\r\n    using Address for address;\r\n\r\n    function safeTransfer(IERC20 token, address to, uint256 value) internal {\r\n        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\r\n    }\r\n    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {\r\n        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\r\n    }\r\n    function safeApprove(IERC20 token, address spender, uint256 value) internal {\r\n        require((value == 0) || (token.allowance(address(this), spender) == 0),\r\n            \u0022SafeERC20: approve from non-zero to non-zero allowance\u0022\r\n        );\r\n        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\r\n    }\r\n    function callOptionalReturn(IERC20 token, bytes memory data) private {\r\n        require(address(token).isContract(), \u0022SafeERC20: call to non-contract\u0022);\r\n\r\n        // solhint-disable-next-line avoid-low-level-calls\r\n        (bool success, bytes memory returndata) = address(token).call(data);\r\n        require(success, \u0022SafeERC20: low-level call failed\u0022);\r\n\r\n        if (returndata.length \u003E 0) { // Return data is optional\r\n            // solhint-disable-next-line max-line-length\r\n            require(abi.decode(returndata, (bool)), \u0022SafeERC20: ERC20 operation did not succeed\u0022);\r\n        }\r\n    }\r\n}\r\n\r\ninterface OptionsContract {\r\n    function liquidate(address payable vaultOwner, uint256 oTokensToLiquidate) external;\r\n    function maxOTokensLiquidatable(address payable vaultOwner) external view returns (uint256);\r\n    function isUnsafe(address payable vaultOwner) external view returns (bool);\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n    function hasVault(address owner) external returns (bool);\r\n    function balanceOf(address owner) external view returns (uint256);\r\n    function maxOTokensIssuable(uint256 _amount) external view returns (uint256);\r\n    function addETHCollateralOption(uint256 tokensToMint, address receiver) external payable;\r\n    function createETHCollateralOption(uint256 tokensToMint, address receiver) external payable;\r\n}\r\n\r\ninterface WETH {\r\n  function withdraw(uint256 amount) external;\r\n  function deposit() external payable;\r\n}\r\n\r\ncontract Structs {\r\n    struct Val {\r\n        uint256 value;\r\n    }\r\n\r\n    enum ActionType {\r\n      Deposit,   // supply tokens\r\n      Withdraw,  // borrow tokens\r\n      Transfer,  // transfer balance between accounts\r\n      Buy,       // buy an amount of some token (externally)\r\n      Sell,      // sell an amount of some token (externally)\r\n      Trade,     // trade tokens against another account\r\n      Liquidate, // liquidate an undercollateralized or expiring account\r\n      Vaporize,  // use excess tokens to zero-out a completely negative account\r\n      Call       // send arbitrary data to an address\r\n    }\r\n\r\n    enum AssetDenomination {\r\n        Wei // the amount is denominated in wei\r\n    }\r\n\r\n    enum AssetReference {\r\n        Delta // the amount is given as a delta from the current value\r\n    }\r\n\r\n    struct AssetAmount {\r\n        bool sign; // true if positive\r\n        AssetDenomination denomination;\r\n        AssetReference ref;\r\n        uint256 value;\r\n    }\r\n\r\n    struct ActionArgs {\r\n        ActionType actionType;\r\n        uint256 accountId;\r\n        AssetAmount amount;\r\n        uint256 primaryMarketId;\r\n        uint256 secondaryMarketId;\r\n        address otherAddress;\r\n        uint256 otherAccountId;\r\n        bytes data;\r\n    }\r\n\r\n    struct Info {\r\n        address owner;  // The address that owns the account\r\n        uint256 number; // A nonce that allows a single address to control many accounts\r\n    }\r\n\r\n    struct Wei {\r\n        bool sign; // true if positive\r\n        uint256 value;\r\n    }\r\n}\r\n\r\ncontract DyDx is Structs {\r\n    function getAccountWei(Info memory account, uint256 marketId) public view returns (Wei memory);\r\n    function operate(Info[] memory, ActionArgs[] memory) public;\r\n}\r\n\r\n\r\ncontract oCurveFlashLiquidate is ReentrancyGuard, Ownable, Structs {\r\n  using SafeERC20 for IERC20;\r\n  using Address for address;\r\n  using SafeMath for uint256;\r\n\r\n  address public dydx;\r\n  address public weth;\r\n  address payable public _oToken;\r\n  address payable public _vault;\r\n  uint256 public _amount;\r\n\r\n  constructor () public {\r\n    dydx = address(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e);\r\n    weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);\r\n  }\r\n\r\n  function liquidate(uint256 amount, address payable vault, address payable oToken) public {\r\n    _vault = vault;\r\n    _amount = amount;\r\n    _oToken = oToken;\r\n\r\n    Info[] memory infos = new Info[](1);\r\n    ActionArgs[] memory args = new ActionArgs[](3);\r\n\r\n    infos[0] = Info(address(this), 0);\r\n\r\n    AssetAmount memory wamt = AssetAmount(false, AssetDenomination.Wei, AssetReference.Delta, amount);\r\n    ActionArgs memory withdraw;\r\n    withdraw.actionType = ActionType.Withdraw;\r\n    withdraw.accountId = 0;\r\n    withdraw.amount = wamt;\r\n    withdraw.primaryMarketId = 0;\r\n    withdraw.otherAddress = address(this);\r\n\r\n    args[0] = withdraw;\r\n\r\n    ActionArgs memory call;\r\n    call.actionType = ActionType.Call;\r\n    call.accountId = 0;\r\n    call.otherAddress = address(this);\r\n\r\n    args[1] = call;\r\n\r\n    ActionArgs memory deposit;\r\n    AssetAmount memory damt = AssetAmount(true, AssetDenomination.Wei, AssetReference.Delta, amount.add(1));\r\n    deposit.actionType = ActionType.Deposit;\r\n    deposit.accountId = 0;\r\n    deposit.amount = damt;\r\n    deposit.primaryMarketId = 0;\r\n    deposit.otherAddress = address(this);\r\n\r\n    args[2] = deposit;\r\n\r\n    DyDx(dydx).operate(infos, args);\r\n  }\r\n\r\n  function callFunction(\r\n      address sender,\r\n      Info memory accountInfo,\r\n      bytes memory data\r\n  ) public {\r\n    OptionsContract oToken = OptionsContract(_oToken);\r\n    require(oToken.isUnsafe(_vault), \u0027cannot liquidate a safe vault\u0027);\r\n\r\n    WETH(weth).withdraw(_amount);\r\n\r\n    uint256 tokensPerETH = oToken.maxOTokensIssuable(1e18);\r\n    uint256 maxToLiquidate = oToken.maxOTokensLiquidatable(_vault); //100 * 1e15\r\n    uint256 ethRequired = maxToLiquidate.mul(1e18).div(tokensPerETH);\r\n    if (oToken.hasVault(address(this))) {\r\n      oToken.addETHCollateralOption.value(ethRequired)(maxToLiquidate, address(this));\r\n    } else {\r\n      oToken.createETHCollateralOption.value(ethRequired)(maxToLiquidate, address(this));\r\n    }\r\n    oToken.liquidate(_vault, maxToLiquidate);\r\n\r\n    WETH(weth).deposit.value(_amount)();\r\n  }\r\n\r\n  function() external payable {\r\n\r\n  }\r\n\r\n  // incase of half-way error\r\n  function inCaseTokenGetsStuck(IERC20 _TokenAddress) onlyOwner public {\r\n      uint qty = _TokenAddress.balanceOf(address(this));\r\n      _TokenAddress.safeTransfer(msg.sender, qty);\r\n  }\r\n\r\n  // incase of half-way error\r\n  function inCaseETHGetsStuck() onlyOwner public{\r\n      (bool result, ) = msg.sender.call.value(address(this).balance)(\u0022\u0022);\r\n      require(result, \u0022transfer of ETH failed\u0022);\r\n  }\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_amount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_oToken\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_vault\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022components\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022number\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022internalType\u0022:\u0022struct Structs.Info\u0022,\u0022name\u0022:\u0022accountInfo\u0022,\u0022type\u0022:\u0022tuple\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022callFunction\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022dydx\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022inCaseETHGetsStuck\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022_TokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022inCaseTokenGetsStuck\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022vault\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022oToken\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022liquidate\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022weth\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"oCurveFlashLiquidate","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://c8cf2136e445aaa2a1569bf3aab58376de0344931a8d596b2d29e4efb84fdf42"}]