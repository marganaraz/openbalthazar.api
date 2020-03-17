[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\nlibrary SafeMath {\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\ncontract IERC20 {\r\n    function totalSupply() external view returns (uint256);\r\n    function balanceOf(address account) external view returns (uint256);\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n    function mint(address account, uint256 amount) public  returns (bool);\r\n    function burn(uint256 amount) public returns (bool);\r\n}\r\n\r\ncontract Ownable {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the caller is the current owner.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return msg.sender == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * \u0060onlyOwner\u0060 functions anymore. Can only be called by the current owner.\r\n     *\r\n     * \u003E Note: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\ncontract EgorasVault is Ownable{\r\naddress private egorasEUSDAddress;\r\naddress private egorasCoinddress;\r\nuint    private price;\r\naddress private messenger;\r\n\r\n\r\nusing SafeMath for uint256;\r\n\r\nconstructor(address _egorasEUSDAddress, address _egorasCoinddress, uint _initialPrice) public{\r\n   egorasEUSDAddress = _egorasEUSDAddress;\r\n   egorasCoinddress = _egorasCoinddress;\r\n   price = _initialPrice;\r\n}\r\n\r\nevent generated(address _generator, uint _amount, uint _amountGenerated, string ticker);\r\nevent priceChanged(address initiator, uint _from, uint _to);\r\nevent messengerChanged(address _from, address _to);\r\nmodifier onlyMessenger() {\r\n        require(msg.sender == messenger, \u0022caller is not a messenger\u0022);\r\n        _;\r\n}\r\n\r\n\r\nfunction generateEgorasEUSD(uint256 _amountOfEgorasCoin) public {\r\nIERC20 egorasEUSD = IERC20(egorasEUSDAddress);\r\nIERC20 egorasCoin = IERC20(egorasCoinddress);\r\nuint amountToGenerate = price.mul(_amountOfEgorasCoin);\r\nrequire(egorasCoin.allowance(msg.sender, address(this)) \u003E= _amountOfEgorasCoin, \u0022Fail to tranfer fund\u0022);\r\nrequire(egorasCoin.transferFrom(msg.sender, address(this), _amountOfEgorasCoin), \u0022Fail to tranfer fund\u0022);\r\nrequire(egorasEUSD.mint(msg.sender, amountToGenerate.div(10 ** 18)), \u0022Fail to generate fund\u0022);\r\nemit generated(msg.sender, _amountOfEgorasCoin, amountToGenerate.div(10 ** 18), \u0022EGR\u0022);\r\n}\r\n\r\nfunction generateEgorasCoin(uint256 _amountOfEgorasEUSD) public{\r\n    IERC20 egorasEUSD = IERC20(egorasEUSDAddress);\r\n    IERC20 egorasCoin = IERC20(egorasCoinddress);\r\n    uint amountToGenerate = _amountOfEgorasEUSD.div(price).mul(10 ** 18);\r\n    require(egorasEUSD.allowance(msg.sender, address(this)) \u003E= _amountOfEgorasEUSD, \u0022Fail to tranfer fund #1\u0022);\r\n    require(egorasCoin.balanceOf(address(this)) \u003E= amountToGenerate, \u0022Insufficient vault balance\u0022);\r\n    require(egorasCoin.transfer(msg.sender, amountToGenerate), \u0022Fail to generate fund #4\u0022);\r\n    require(egorasEUSD.transferFrom(msg.sender, address(this), _amountOfEgorasEUSD), \u0022Fail to burn fund #5\u0022);\r\n    emit generated(msg.sender, _amountOfEgorasEUSD, amountToGenerate, \u0022EUSD\u0022);\r\n        \r\n   \r\n}\r\n\r\n\r\nfunction updatePrice(uint256 _price) public onlyMessenger{\r\n    uint256 currentprice = price;\r\n    price = _price;\r\n    emit priceChanged(msg.sender, currentprice, _price);\r\n}\r\n\r\nfunction setMessenger(address _messenger) public onlyOwner{\r\n    address currentMessenger = messenger;\r\n    messenger = _messenger;\r\n    emit messengerChanged(currentMessenger, _messenger);\r\n}\r\n\r\nfunction emptyVault() public onlyOwner{\r\n    IERC20 egorasCoin = IERC20(egorasCoinddress);\r\n    require(egorasCoin.transfer(owner(), egorasCoin.balanceOf(address(this))), \u0022Fail to empty vault\u0022);\r\n}\r\n\r\nfunction burnVault() public onlyOwner{\r\n    IERC20 egorasEUSD = IERC20(egorasEUSDAddress);\r\n    require(egorasEUSD.burn(egorasEUSD.balanceOf(address(this))), \u0022Fail to empty vault\u0022);\r\n}\r\n\r\nfunction getPrice() public view returns (uint256 _price) {\r\n   return price;\r\n}\r\n     function setEgorasEusd(address _egorasEUSDAddress) public onlyOwner{\r\n     egorasEUSDAddress = _egorasEUSDAddress;\r\n    }\r\n\r\n     function setEgorasCoin(address _egorasCoinddress) public onlyOwner{\r\n     egorasCoinddress = _egorasCoinddress;\r\n    }\r\n\r\n    function getCoinAddresses() public view returns (address _egorasCoinddress, address _egorasEUSDAddress) {\r\n        return(egorasCoinddress, egorasEUSDAddress);\r\n    }\r\n\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_egorasEUSDAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_egorasCoinddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_initialPrice\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_generator\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amountGenerated\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022ticker\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022generated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022messengerChanged\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022initiator\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022priceChanged\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022burnVault\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022emptyVault\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amountOfEgorasEUSD\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022generateEgorasCoin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amountOfEgorasCoin\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022generateEgorasEUSD\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCoinAddresses\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_egorasCoinddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_egorasEUSDAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getPrice\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_price\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_egorasCoinddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setEgorasCoin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_egorasEUSDAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setEgorasEusd\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_messenger\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setMessenger\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_price\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022updatePrice\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"EgorasVault","CompilerVersion":"v0.5.16\u002Bcommit.9c3226ce","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000a90c43e0d6c92b8e6171a829beb38be28a0ad07300000000000000000000000073cee8348b9bdd48c64e13452b8a6fbc81630573000000000000000000000000000000000000000000000000000069f4c51dc800","Library":"","SwarmSource":"bzzr://3c8dbd6c1144f2c45fc23d5d8459370d609211573fb309a71708412b0a19f942"}]