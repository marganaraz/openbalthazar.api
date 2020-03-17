[{"SourceCode":"pragma solidity ^0.5.0;\r\npragma experimental ABIEncoderV2;\r\n\r\ncontract ReentrancyGuard {\r\n    uint256 private _guardCounter;\r\n\r\n    constructor () internal {\r\n        _guardCounter = 1;\r\n    }\r\n\r\n    modifier nonReentrant() {\r\n        _guardCounter \u002B= 1;\r\n        uint256 localCounter = _guardCounter;\r\n        _;\r\n        require(localCounter == _guardCounter, \u0022ReentrancyGuard: reentrant call\u0022);\r\n    }\r\n}\r\n\r\ncontract Context {\r\n    constructor () internal { }\r\n    // solhint-disable-previous-line no-empty-blocks\r\n\r\n    function _msgSender() internal view returns (address payable) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view returns (bytes memory) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}\r\n\r\ncontract Ownable is Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n    constructor () internal {\r\n        _owner = _msgSender();\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n    function isOwner() public view returns (bool) {\r\n        return _msgSender() == _owner;\r\n    }\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\nlibrary SafeMath {\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, errorMessage);\r\n        uint256 c = a / b;\r\n\r\n        return c;\r\n    }\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\nlibrary Address {\r\n    function isContract(address account) internal view returns (bool) {\r\n        bytes32 codehash;\r\n        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;\r\n        // solhint-disable-next-line no-inline-assembly\r\n        assembly { codehash := extcodehash(account) }\r\n        return (codehash != 0x0 \u0026\u0026 codehash != accountHash);\r\n    }\r\n    function toPayable(address account) internal pure returns (address payable) {\r\n        return address(uint160(account));\r\n    }\r\n    function sendValue(address payable recipient, uint256 amount) internal {\r\n        require(address(this).balance \u003E= amount, \u0022Address: insufficient balance\u0022);\r\n\r\n        // solhint-disable-next-line avoid-call-value\r\n        (bool success, ) = recipient.call.value(amount)(\u0022\u0022);\r\n        require(success, \u0022Address: unable to send value, recipient may have reverted\u0022);\r\n    }\r\n}\r\n\r\ninterface yToken {\r\n    function transferOwnership(address newOwner) external;\r\n    function set_new_APR(address _new_APR) external;\r\n    function set_new_FULCRUM(address _new_FULCRUM) external;\r\n    function set_new_COMPOUND(address _new_COMPOUND) external;\r\n    function set_new_DTOKEN(uint256 _new_DTOKEN) external;\r\n    function set_new_AAVE(address _new_AAVE) external;\r\n    function set_new_APOOL(address _new_APOOL) external;\r\n    function set_new_ATOKEN(address _new_ATOKEN) external;\r\n    function recommend() external view returns (uint8);\r\n    function balance() external view returns (uint256);\r\n    function balanceDydxAvailable() external view returns (uint256);\r\n    function balanceDydx() external view returns (uint256);\r\n    function balanceCompound() external view returns (uint256);\r\n    function balanceCompoundInToken() external view returns (uint256);\r\n    function balanceFulcrumAvailable() external view returns (uint256);\r\n    function balanceFulcrumInToken() external view returns (uint256);\r\n    function balanceFulcrum() external view returns (uint256);\r\n    function balanceAaveAvailable() external view returns (uint256);\r\n    function balanceAave() external view returns (uint256);\r\n    function withdrawSomeCompound(uint256 _amount) external;\r\n    function withdrawSomeFulcrum(uint256 _amount) external;\r\n    function withdrawAave(uint amount) external;\r\n    function withdrawDydx(uint256 amount) external;\r\n    function supplyDydx(uint256 amount) external;\r\n    function supplyAave(uint amount) external;\r\n    function supplyFulcrum(uint amount) external;\r\n    function supplyCompound(uint amount) external;\r\n}\r\n\r\ninterface IIEarnManager {\r\n    function recommend(address _token) external view returns (\r\n      string memory choice,\r\n      uint256 capr,\r\n      uint256 iapr,\r\n      uint256 aapr,\r\n      uint256 dapr\r\n    );\r\n}\r\n\r\ncontract yTokenProxy is ReentrancyGuard, Ownable {\r\n  using Address for address;\r\n  using SafeMath for uint256;\r\n\r\n  yToken public _yToken;\r\n\r\n  constructor () public {\r\n     _yToken = yToken(0xC2cB1040220768554cf699b0d863A3cd4324ce32);\r\n  }\r\n\r\n  function withdrawAave() public onlyOwner {\r\n    _yToken.withdrawAave(_yToken.balanceAave());\r\n  }\r\n\r\n  function withdrawDydx() public onlyOwner {\r\n    _yToken.withdrawDydx(_yToken.balanceDydx());\r\n  }\r\n\r\n  function set_new_yToken(yToken _new_yToken) public onlyOwner {\r\n      _yToken = _new_yToken;\r\n  }\r\n\r\n  function transferYTokenOwnership(address _newOwner) public onlyOwner {\r\n    _yToken.transferOwnership(_newOwner);\r\n  }\r\n\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_yToken\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract yToken\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract yToken\u0022,\u0022name\u0022:\u0022_new_yToken\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022set_new_yToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferYTokenOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdrawAave\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdrawDydx\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"yTokenProxy","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://3fb48bb2c04a6e2d843495dd1c654db7bf7f360c2e4311c8ea5c6c662b7e7252"}]