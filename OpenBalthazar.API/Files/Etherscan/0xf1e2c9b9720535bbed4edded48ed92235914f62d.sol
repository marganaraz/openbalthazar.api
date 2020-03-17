[{"SourceCode":"pragma solidity ^0.5.0;\r\npragma experimental ABIEncoderV2;\r\n\r\ninterface IERC20 {\r\n    function totalSupply() external view returns (uint256);\r\n    function balanceOf(address account) external view returns (uint256);\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\ncontract Context {\r\n    constructor () internal { }\r\n    // solhint-disable-previous-line no-empty-blocks\r\n\r\n    function _msgSender() internal view returns (address payable) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view returns (bytes memory) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}\r\n\r\ncontract ReentrancyGuard {\r\n    uint256 private _guardCounter;\r\n\r\n    constructor () internal {\r\n        _guardCounter = 1;\r\n    }\r\n\r\n    modifier nonReentrant() {\r\n        _guardCounter \u002B= 1;\r\n        uint256 localCounter = _guardCounter;\r\n        _;\r\n        require(localCounter == _guardCounter, \u0022ReentrancyGuard: reentrant call\u0022);\r\n    }\r\n}\r\n\r\ncontract Ownable is Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n    constructor () internal {\r\n        _owner = _msgSender();\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n    function isOwner() public view returns (bool) {\r\n        return _msgSender() == _owner;\r\n    }\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\nlibrary SafeMath {\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, errorMessage);\r\n        uint256 c = a / b;\r\n\r\n        return c;\r\n    }\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\nlibrary Address {\r\n    function isContract(address account) internal view returns (bool) {\r\n        bytes32 codehash;\r\n        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;\r\n        // solhint-disable-next-line no-inline-assembly\r\n        assembly { codehash := extcodehash(account) }\r\n        return (codehash != 0x0 \u0026\u0026 codehash != accountHash);\r\n    }\r\n    function toPayable(address account) internal pure returns (address payable) {\r\n        return address(uint160(account));\r\n    }\r\n    function sendValue(address payable recipient, uint256 amount) internal {\r\n        require(address(this).balance \u003E= amount, \u0022Address: insufficient balance\u0022);\r\n\r\n        // solhint-disable-next-line avoid-call-value\r\n        (bool success, ) = recipient.call.value(amount)(\u0022\u0022);\r\n        require(success, \u0022Address: unable to send value, recipient may have reverted\u0022);\r\n    }\r\n}\r\n\r\nlibrary SafeERC20 {\r\n    using SafeMath for uint256;\r\n    using Address for address;\r\n\r\n    function safeTransfer(IERC20 token, address to, uint256 value) internal {\r\n        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\r\n    }\r\n    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {\r\n        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\r\n    }\r\n    function safeApprove(IERC20 token, address spender, uint256 value) internal {\r\n        require((value == 0) || (token.allowance(address(this), spender) == 0),\r\n            \u0022SafeERC20: approve from non-zero to non-zero allowance\u0022\r\n        );\r\n        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\r\n    }\r\n    function callOptionalReturn(IERC20 token, bytes memory data) private {\r\n        require(address(token).isContract(), \u0022SafeERC20: call to non-contract\u0022);\r\n\r\n        // solhint-disable-next-line avoid-low-level-calls\r\n        (bool success, bytes memory returndata) = address(token).call(data);\r\n        require(success, \u0022SafeERC20: low-level call failed\u0022);\r\n\r\n        if (returndata.length \u003E 0) { // Return data is optional\r\n            // solhint-disable-next-line max-line-length\r\n            require(abi.decode(returndata, (bool)), \u0022SafeERC20: ERC20 operation did not succeed\u0022);\r\n        }\r\n    }\r\n}\r\n\r\ninterface yERC20 {\r\n  function withdraw(uint256 _amount) external;\r\n}\r\n\r\n// Solidity Interface\r\n\r\ninterface ICurveFi {\r\n\r\n  function remove_liquidity(\r\n    uint256 _amount,\r\n    uint256[4] calldata amounts\r\n  ) external;\r\n  function exchange(\r\n    int128 from, int128 to, uint256 _from_amount, uint256 _min_to_amount\r\n  ) external;\r\n}\r\n\r\ncontract yCurveZapOutV4 is ReentrancyGuard, Ownable {\r\n  using SafeERC20 for IERC20;\r\n  using Address for address;\r\n  using SafeMath for uint256;\r\n\r\n  address public DAI;\r\n  address public yDAI;\r\n  address public USDC;\r\n  address public yUSDC;\r\n  address public USDT;\r\n  address public yUSDT;\r\n  address public BUSD;\r\n  address public yBUSD;\r\n  address public SWAP;\r\n  address public CURVE;\r\n\r\n  constructor () public {\r\n    DAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);\r\n    yDAI = address(0xC2cB1040220768554cf699b0d863A3cd4324ce32);\r\n\r\n    USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);\r\n    yUSDC = address(0x26EA744E5B887E5205727f55dFBE8685e3b21951);\r\n\r\n    USDT = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);\r\n    yUSDT = address(0xE6354ed5bC4b393a5Aad09f21c46E101e692d447);\r\n\r\n    BUSD = address(0x4Fabb145d64652a948d72533023f6E7A623C7C53);\r\n    yBUSD = address(0x04bC0Ab673d88aE9dbC9DA2380cB6B79C4BCa9aE);\r\n\r\n    SWAP = address(0x79a8C46DeA5aDa233ABaFFD40F3A0A2B1e5A4F27);\r\n    CURVE = address(0x3B3Ac5386837Dc563660FB6a0937DFAa5924333B);\r\n\r\n    approveToken();\r\n  }\r\n\r\n  function() external payable {\r\n\r\n  }\r\n\r\n  function approveToken() public {\r\n      IERC20(yDAI).safeApprove(SWAP, uint(-1));\r\n      IERC20(yUSDC).safeApprove(SWAP, uint(-1));\r\n      IERC20(yUSDT).safeApprove(SWAP, uint(-1));\r\n      IERC20(yBUSD).safeApprove(SWAP, uint(-1));\r\n  }\r\n\r\n  // 0 = dai\r\n  // 1 = usdc\r\n  // 2 = usdt\r\n  // 3 = busd\r\n\r\n  function withdrawDAI(uint256 _amount)\r\n      external\r\n      nonReentrant\r\n  {\r\n      require(_amount \u003E 0, \u0022deposit must be greater than 0\u0022);\r\n      IERC20(CURVE).safeTransferFrom(msg.sender, address(this), _amount);\r\n\r\n      ICurveFi(SWAP).remove_liquidity(IERC20(CURVE).balanceOf(address(this)), [uint256(0),0,0,0]);\r\n      require(IERC20(CURVE).balanceOf(address(this)) == 0, \u0022CURVE remainder\u0022);\r\n\r\n      uint256 _ydai = IERC20(yDAI).balanceOf(address(this));\r\n      uint256 _yusdc = IERC20(yUSDC).balanceOf(address(this));\r\n      uint256 _yusdt = IERC20(yUSDT).balanceOf(address(this));\r\n      uint256 _ybusd = IERC20(yBUSD).balanceOf(address(this));\r\n\r\n      require(_ydai \u003E 0 || _yusdc \u003E 0 || _yusdt \u003E 0 || _ybusd \u003E 0, \u0022no y.tokens found\u0022);\r\n\r\n      if (_yusdc \u003E 0) {\r\n        ICurveFi(SWAP).exchange(1, 0, _yusdc, 0);\r\n        require(IERC20(yUSDC).balanceOf(address(this)) == 0, \u0022y.USDC remainder\u0022);\r\n      }\r\n      if (_yusdt \u003E 0) {\r\n        ICurveFi(SWAP).exchange(2, 0, _yusdt, 0);\r\n        require(IERC20(yUSDT).balanceOf(address(this)) == 0, \u0022y.USDT remainder\u0022);\r\n      }\r\n      if (_ybusd \u003E 0) {\r\n        ICurveFi(SWAP).exchange(3, 0, _ybusd, 0);\r\n        require(IERC20(yBUSD).balanceOf(address(this)) == 0, \u0022y.BUSD remainder\u0022);\r\n      }\r\n\r\n      yERC20(yDAI).withdraw(IERC20(yDAI).balanceOf(address(this)));\r\n      require(IERC20(yDAI).balanceOf(address(this)) == 0, \u0022y.DAI remainder\u0022);\r\n\r\n      IERC20(DAI).safeTransfer(msg.sender, IERC20(DAI).balanceOf(address(this)));\r\n      require(IERC20(DAI).balanceOf(address(this)) == 0, \u0022DAI remainder\u0022);\r\n  }\r\n\r\n  function withdrawUSDC(uint256 _amount)\r\n      external\r\n      nonReentrant\r\n  {\r\n      require(_amount \u003E 0, \u0022deposit must be greater than 0\u0022);\r\n      IERC20(CURVE).safeTransferFrom(msg.sender, address(this), _amount);\r\n\r\n      ICurveFi(SWAP).remove_liquidity(IERC20(CURVE).balanceOf(address(this)), [uint256(0),0,0,0]);\r\n      require(IERC20(CURVE).balanceOf(address(this)) == 0, \u0022CURVE remainder\u0022);\r\n\r\n      uint256 _ydai = IERC20(yDAI).balanceOf(address(this));\r\n      uint256 _yusdc = IERC20(yUSDC).balanceOf(address(this));\r\n      uint256 _yusdt = IERC20(yUSDT).balanceOf(address(this));\r\n      uint256 _ybusd = IERC20(yBUSD).balanceOf(address(this));\r\n\r\n      require(_ydai \u003E 0 || _yusdc \u003E 0 || _yusdt \u003E 0 || _ybusd \u003E 0, \u0022no y.tokens found\u0022);\r\n\r\n      if (_ydai \u003E 0) {\r\n        ICurveFi(SWAP).exchange(0, 1, _ydai, 0);\r\n        require(IERC20(yDAI).balanceOf(address(this)) == 0, \u0022y.DAI remainder\u0022);\r\n      }\r\n      if (_yusdt \u003E 0) {\r\n        ICurveFi(SWAP).exchange(2, 1, _yusdt, 0);\r\n        require(IERC20(yUSDT).balanceOf(address(this)) == 0, \u0022y.USDT remainder\u0022);\r\n      }\r\n      if (_ybusd \u003E 0) {\r\n        ICurveFi(SWAP).exchange(3, 1, _ybusd, 0);\r\n        require(IERC20(yBUSD).balanceOf(address(this)) == 0, \u0022y.BUSD remainder\u0022);\r\n      }\r\n\r\n      yERC20(yUSDC).withdraw(IERC20(yUSDC).balanceOf(address(this)));\r\n      require(IERC20(yUSDC).balanceOf(address(this)) == 0, \u0022y.USDC remainder\u0022);\r\n\r\n      IERC20(USDC).safeTransfer(msg.sender, IERC20(USDC).balanceOf(address(this)));\r\n      require(IERC20(USDC).balanceOf(address(this)) == 0, \u0022USDC remainder\u0022);\r\n  }\r\n\r\n  function withdrawUSDT(uint256 _amount)\r\n      external\r\n      nonReentrant\r\n  {\r\n      require(_amount \u003E 0, \u0022deposit must be greater than 0\u0022);\r\n      IERC20(CURVE).safeTransferFrom(msg.sender, address(this), _amount);\r\n\r\n      ICurveFi(SWAP).remove_liquidity(IERC20(CURVE).balanceOf(address(this)), [uint256(0),0,0,0]);\r\n      require(IERC20(CURVE).balanceOf(address(this)) == 0, \u0022CURVE remainder\u0022);\r\n\r\n      uint256 _ydai = IERC20(yDAI).balanceOf(address(this));\r\n      uint256 _yusdc = IERC20(yUSDC).balanceOf(address(this));\r\n      uint256 _yusdt = IERC20(yUSDT).balanceOf(address(this));\r\n      uint256 _ybusd = IERC20(yBUSD).balanceOf(address(this));\r\n\r\n      require(_ydai \u003E 0 || _yusdc \u003E 0 || _yusdt \u003E 0 || _ybusd \u003E 0, \u0022no y.tokens found\u0022);\r\n\r\n      if (_ydai \u003E 0) {\r\n        ICurveFi(SWAP).exchange(0, 2, _ydai, 0);\r\n        require(IERC20(yDAI).balanceOf(address(this)) == 0, \u0022y.DAI remainder\u0022);\r\n      }\r\n      if (_yusdc \u003E 0) {\r\n        ICurveFi(SWAP).exchange(1, 2, _yusdc, 0);\r\n        require(IERC20(yUSDC).balanceOf(address(this)) == 0, \u0022y.USDC remainder\u0022);\r\n      }\r\n      if (_ybusd \u003E 0) {\r\n        ICurveFi(SWAP).exchange(3, 2, _ybusd, 0);\r\n        require(IERC20(yBUSD).balanceOf(address(this)) == 0, \u0022y.BUSD remainder\u0022);\r\n      }\r\n\r\n      yERC20(yUSDT).withdraw(IERC20(yUSDT).balanceOf(address(this)));\r\n      require(IERC20(yUSDT).balanceOf(address(this)) == 0, \u0022y.USDT remainder\u0022);\r\n\r\n      IERC20(USDT).safeTransfer(msg.sender, IERC20(USDT).balanceOf(address(this)));\r\n      require(IERC20(USDT).balanceOf(address(this)) == 0, \u0022USDT remainder\u0022);\r\n  }\r\n\r\n  function withdrawBUSD(uint256 _amount)\r\n      external\r\n      nonReentrant\r\n  {\r\n      require(_amount \u003E 0, \u0022deposit must be greater than 0\u0022);\r\n      IERC20(CURVE).safeTransferFrom(msg.sender, address(this), _amount);\r\n\r\n      ICurveFi(SWAP).remove_liquidity(IERC20(CURVE).balanceOf(address(this)), [uint256(0),0,0,0]);\r\n      require(IERC20(CURVE).balanceOf(address(this)) == 0, \u0022CURVE remainder\u0022);\r\n\r\n      uint256 _ydai = IERC20(yDAI).balanceOf(address(this));\r\n      uint256 _yusdc = IERC20(yUSDC).balanceOf(address(this));\r\n      uint256 _yusdt = IERC20(yUSDT).balanceOf(address(this));\r\n      uint256 _ybusd = IERC20(yBUSD).balanceOf(address(this));\r\n\r\n      require(_ydai \u003E 0 || _yusdc \u003E 0 || _yusdt \u003E 0 || _ybusd \u003E 0, \u0022no y.tokens found\u0022);\r\n\r\n      if (_ydai \u003E 0) {\r\n        ICurveFi(SWAP).exchange(0, 3, _ydai, 0);\r\n        require(IERC20(yDAI).balanceOf(address(this)) == 0, \u0022y.DAI remainder\u0022);\r\n      }\r\n      if (_yusdc \u003E 0) {\r\n        ICurveFi(SWAP).exchange(1, 3, _yusdc, 0);\r\n        require(IERC20(yUSDC).balanceOf(address(this)) == 0, \u0022y.USDC remainder\u0022);\r\n      }\r\n      if (_yusdt \u003E 0) {\r\n        ICurveFi(SWAP).exchange(2, 3, _yusdt, 0);\r\n        require(IERC20(yUSDT).balanceOf(address(this)) == 0, \u0022y.USDT remainder\u0022);\r\n      }\r\n\r\n      yERC20(yBUSD).withdraw(IERC20(yBUSD).balanceOf(address(this)));\r\n      require(IERC20(yBUSD).balanceOf(address(this)) == 0, \u0022y.BUSD remainder\u0022);\r\n\r\n      IERC20(BUSD).safeTransfer(msg.sender, IERC20(BUSD).balanceOf(address(this)));\r\n      require(IERC20(BUSD).balanceOf(address(this)) == 0, \u0022BUSD remainder\u0022);\r\n  }\r\n\r\n  // incase of half-way error\r\n  function inCaseTokenGetsStuck(IERC20 _TokenAddress) onlyOwner public {\r\n      uint qty = _TokenAddress.balanceOf(address(this));\r\n      _TokenAddress.safeTransfer(msg.sender, qty);\r\n  }\r\n\r\n  // incase of half-way error\r\n  function inCaseETHGetsStuck() onlyOwner public{\r\n      (bool result, ) = msg.sender.call.value(address(this).balance)(\u0022\u0022);\r\n      require(result, \u0022transfer of ETH failed\u0022);\r\n  }\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022BUSD\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022CURVE\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022DAI\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022SWAP\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022USDC\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022USDT\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022approveToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022inCaseETHGetsStuck\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022_TokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022inCaseTokenGetsStuck\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawBUSD\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawDAI\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawUSDC\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawUSDT\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022yBUSD\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022yDAI\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022yUSDC\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022yUSDT\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"yCurveZapOutV4","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://0f1febdb0a9bd4da9de89c2f622aaed03bf8ff5e71276edbfe67e9221dff4208"}]