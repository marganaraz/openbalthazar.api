[{"SourceCode":"/*! nep.sol | (c) 2019 Develop by BelovITLab LLC (smartcontract.ru), author @stupidlovejoy | License: MIT */\r\n\r\npragma solidity 0.5.12;\r\n\r\nlibrary SafeMath {\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if(a == 0) return 0;\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003E 0, \u0022SafeMath: division by zero\u0022);\r\n        return a / b;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a, \u0022SafeMath: subtraction overflow\u0022);\r\n        return a - b;\r\n    }\r\n\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n        return c;\r\n    }\r\n\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0, \u0022SafeMath: modulo by zero\u0022);\r\n        return a % b;\r\n    }\r\n}\r\n\r\nlibrary Address {\r\n    function isContract(address account) internal view returns (bool) {\r\n        bytes32 codehash;\r\n        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;\r\n        \r\n        assembly { codehash := extcodehash(account) }\r\n        return (codehash != 0x0 \u0026\u0026 codehash != accountHash);\r\n    }\r\n    \r\n    function toPayable(address account) internal pure returns (address payable) {\r\n        return address(uint160(account));\r\n    }\r\n}\r\n\r\ncontract Ownable {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    constructor() internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n\r\n    function isOwner() public view returns (bool) {\r\n        return msg.sender == _owner;\r\n    }\r\n\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\ninterface IERC20 {\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n\r\n    function transfer(address to, uint256 value) external returns (bool);\r\n    function approve(address spender, uint256 value) external returns (bool);\r\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\r\n    function totalSupply() external view returns (uint256);\r\n    function balanceOf(address who) external view returns (uint256);\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n}\r\n\r\ncontract IERC223Recipient {\r\n    function tokenFallback(address from, uint value, bytes memory data) public;\r\n}\r\n\r\ncontract StandardToken is IERC20 {\r\n    using SafeMath for uint256;\r\n\r\n    mapping (address =\u003E uint256) private _balances;\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) private _allowed;\r\n\r\n    uint256 private _totalSupply;\r\n    string private _name;\r\n    string private _symbol;\r\n    uint8 private _decimals;\r\n\r\n    constructor(string memory name, string memory symbol, uint8 decimals) public {\r\n        _name = name;\r\n        _symbol = symbol;\r\n        _decimals = decimals;\r\n    }\r\n\r\n    function name() public view returns (string memory) {\r\n        return _name;\r\n    }\r\n\r\n    function symbol() public view returns (string memory) {\r\n        return _symbol;\r\n    }\r\n\r\n    function decimals() public view returns (uint8) {\r\n        return _decimals;\r\n    }\r\n\r\n    function totalSupply() public view returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    function balanceOf(address owner) public view returns (uint256) {\r\n        return _balances[owner];\r\n    }\r\n\r\n    function allowance(address owner, address spender) public view returns (uint256) {\r\n        return _allowed[owner][spender];\r\n    }\r\n    \r\n    function transfer(address to, uint256 value) public returns (bool) {\r\n        _transfer(msg.sender, to, value);\r\n        return true;\r\n    }\r\n\r\n    function multiTransfer(address[] memory to, uint256[] memory value) public returns (bool) {\r\n        require(to.length \u003E 0 \u0026\u0026 to.length == value.length, \u0022Invalid params\u0022);\r\n\r\n        for(uint i = 0; i \u003C to.length; i\u002B\u002B) {\r\n            _transfer(msg.sender, to[i], value[i]);\r\n        }\r\n\r\n        return true;\r\n    }\r\n\r\n    function approve(address spender, uint256 value) public returns (bool) {\r\n        _approve(msg.sender, spender, value);\r\n        return true;\r\n    }\r\n\r\n    function transferFrom(address from, address to, uint256 value) public returns (bool) {\r\n        _transfer(from, to, value);\r\n        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));\r\n        return true;\r\n    }\r\n\r\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\r\n        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));\r\n        return true;\r\n    }\r\n\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\r\n        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));\r\n        return true;\r\n    }\r\n\r\n    function _transfer(address from, address to, uint256 value) internal {\r\n        require(to != address(0), \u0022ERC20: transfer to the zero address\u0022);\r\n\r\n        _balances[from] = _balances[from].sub(value);\r\n        _balances[to] = _balances[to].add(value);\r\n        \r\n        bytes memory empty = hex\u002200000000\u0022;\r\n        if(Address.isContract(to)) {\r\n            IERC223Recipient receiver = IERC223Recipient(to);\r\n            receiver.tokenFallback(from, value, empty);\r\n        }\r\n\r\n        emit Transfer(from, to, value);\r\n    }\r\n\r\n    function _mint(address account, uint256 value) internal {\r\n        require(account != address(0), \u0022ERC20: mint to the zero address\u0022);\r\n\r\n        _totalSupply = _totalSupply.add(value);\r\n        _balances[account] = _balances[account].add(value);\r\n\r\n        emit Transfer(address(0), account, value);\r\n    }\r\n    \r\n    function _burn(address account, uint256 value) internal {\r\n        require(account != address(0), \u0022ERC20: burn from the zero address\u0022);\r\n\r\n        _totalSupply = _totalSupply.sub(value);\r\n        _balances[account] = _balances[account].sub(value);\r\n\r\n        emit Transfer(account, address(0), value);\r\n    }\r\n    \r\n    function _approve(address owner, address spender, uint256 value) internal {\r\n        require(owner != address(0), \u0022ERC20: approve from the zero address\u0022);\r\n        require(spender != address(0), \u0022ERC20: approve to the zero address\u0022);\r\n\r\n        _allowed[owner][spender] = value;\r\n\r\n        emit Approval(owner, spender, value);\r\n    }\r\n    \r\n    function _burnFrom(address account, uint256 value) internal {\r\n        _burn(account, value);\r\n        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));\r\n    }\r\n}\r\n\r\ncontract MintableToken is StandardToken, Ownable {\r\n    bool public mintingFinished = false;\r\n\r\n    event MintFinished(address account);\r\n\r\n    modifier canMint() {\r\n        require(!mintingFinished);\r\n        _;\r\n    }\r\n\r\n    function finishMinting() onlyOwner canMint public returns(bool) {\r\n        mintingFinished = true;\r\n\r\n        emit MintFinished(msg.sender);\r\n        return true;\r\n    }\r\n\r\n    function mint(address to, uint256 value) public canMint onlyOwner returns (bool) {\r\n        _mint(to, value);\r\n        return true;\r\n    }\r\n}\r\n\r\ncontract CappedToken is MintableToken {\r\n    uint256 private _cap;\r\n\r\n    constructor(uint256 cap) public {\r\n        require(cap \u003E 0, \u0022ERC20Capped: cap is 0\u0022);\r\n\r\n        _cap = cap;\r\n    }\r\n\r\n    function cap() public view returns (uint256) {\r\n        return _cap;\r\n    }\r\n\r\n    function _mint(address account, uint256 value) internal {\r\n        require(totalSupply().add(value) \u003C= _cap, \u0022ERC20Capped: cap exceeded\u0022);\r\n        super._mint(account, value);\r\n    }\r\n}\r\n\r\ncontract BurnableToken is StandardToken {\r\n    function burn(uint256 value) public {\r\n        _burn(msg.sender, value);\r\n    }\r\n\r\n    function burnFrom(address from, uint256 value) public {\r\n        _burnFrom(from, value);\r\n    }\r\n}\r\n\r\ncontract Withdrawable is Ownable {\r\n    event WithdrawEther(address indexed to, uint value);\r\n\r\n    function withdrawEther(address payable _to, uint _value) onlyOwner public {\r\n        require(_to != address(0));\r\n        require(address(this).balance \u003E= _value);\r\n\r\n        address(_to).transfer(_value);\r\n\r\n        emit WithdrawEther(_to, _value);\r\n    }\r\n\r\n    function withdrawTokensTransfer(IERC20 _token, address _to, uint256 _value) onlyOwner public {\r\n        require(_token.transfer(_to, _value));\r\n    }\r\n\r\n    function withdrawTokensTransferFrom(IERC20 _token, address _from, address _to, uint256 _value) onlyOwner public {\r\n        require(_token.transferFrom(_from, _to, _value));\r\n    }\r\n\r\n    function withdrawTokensApprove(IERC20 _token, address _spender, uint256 _value) onlyOwner public {\r\n        require(_token.approve(_spender, _value));\r\n    }\r\n}\r\n\r\ncontract Pausable is Ownable {\r\n    event Paused(address account);\r\n    event Unpaused(address account);\r\n\r\n    bool private _paused;\r\n\r\n    constructor() internal {\r\n        _paused = false;\r\n    }\r\n\r\n    function paused() public view returns (bool) {\r\n        return _paused;\r\n    }\r\n\r\n    modifier whenNotPaused() {\r\n        require(!_paused, \u0022Pausable: paused\u0022);\r\n        _;\r\n    }\r\n\r\n    modifier whenPaused() {\r\n        require(_paused, \u0022Pausable: not paused\u0022);\r\n        _;\r\n    }\r\n\r\n    function pause() public onlyOwner whenNotPaused {\r\n        _paused = true;\r\n\r\n        emit Paused(msg.sender);\r\n    }\r\n\r\n    function unpause() public onlyOwner whenPaused {\r\n        _paused = false;\r\n\r\n        emit Unpaused(msg.sender);\r\n    }\r\n}\r\n\r\n\r\n/*\r\n    NEP Token\r\n*/\r\ncontract Token is CappedToken, BurnableToken, Withdrawable {\r\n    constructor() CappedToken(120000000000 * 1e4) StandardToken(\u0022NEP Index\u0022, \u0022NEP\u0022, 4) public {\r\n        \r\n    }\r\n}\r\n\r\ncontract Wallet is Ownable {\r\n    struct WalletItem {\r\n        address payable addr;\r\n        uint percent;\r\n    }\r\n\r\n    WalletItem[] public wallets;\r\n\r\n    function setWallet(uint _index, address payable _addr, uint _percent) onlyOwner external {\r\n        wallets[_index].addr = _addr;\r\n        wallets[_index].percent = _percent;\r\n    }\r\n\r\n    function addWallet(address payable _addr, uint _percent) onlyOwner external {\r\n        wallets.push(WalletItem({addr: _addr, percent: _percent}));\r\n    }\r\n}\r\n\r\ncontract IncomingStream is Wallet, Withdrawable {\r\n    using SafeMath for uint;\r\n\r\n    Token public token;\r\n\r\n    uint public rate = 500;\r\n    uint public min_buy_amount = 100e4;\r\n\r\n    event Operation(address indexed addr, uint256 eth, uint256 tokens);\r\n\r\n    constructor(Token _token) public {\r\n        token = _token;\r\n    }\r\n\r\n    function() payable external {\r\n        uint tokens = msg.value.mul(rate).div(1e14);\r\n\r\n        require(token.balanceOf(address(this)) \u003E= tokens, \u0022Insufficient funds\u0022);\r\n        require(token.transfer(msg.sender, tokens), \u0022Error send tokens\u0022);\r\n        require(tokens \u003E= min_buy_amount, \u0022Invalid amount\u0022);\r\n\r\n        for(uint i = 0; i \u003C wallets.length; i\u002B\u002B) {\r\n            if(wallets[i].percent \u003E 0) {\r\n                address(wallets[i].addr).transfer(msg.value.mul(wallets[i].percent).div(100));\r\n            }\r\n        }\r\n\r\n        emit Operation(msg.sender, msg.value, tokens);\r\n    }\r\n\r\n    function setRate(uint _rate) onlyOwner external {\r\n        rate = _rate;\r\n    }\r\n\r\n    function setMinBuyAmount(uint _min_buy_amount) onlyOwner external {\r\n        min_buy_amount = _min_buy_amount;\r\n    }\r\n}\r\n\r\ncontract OutgoingStream is Wallet, Withdrawable {\r\n    using SafeMath for uint;\r\n\r\n    event Operation(address indexed addr, uint256 eth);\r\n\r\n    function() payable external {\r\n        for(uint i = 0; i \u003C wallets.length; i\u002B\u002B) {\r\n            if(wallets[i].percent \u003E 0) {\r\n                address(wallets[i].addr).transfer(msg.value.mul(wallets[i].percent).div(100));\r\n            }\r\n        }\r\n\r\n        emit Operation(msg.sender, msg.value);\r\n    }\r\n}\r\n\r\ncontract ExchangerToken is Withdrawable, IERC223Recipient {\r\n    using SafeMath for uint;\r\n    using Address for address;\r\n\r\n    Token public token;\r\n    address public tokenHolder;\r\n\r\n    uint public rate = 650;\r\n\r\n    event Operation(address indexed addr, uint256 tokens, uint256 eth);\r\n\r\n    constructor(Token _token) public {\r\n        token = _token;\r\n    }\r\n\r\n    function() payable external {\r\n        \r\n    }\r\n    \r\n    function tokenFallback(address from, uint value, bytes memory data) public {\r\n        require(msg.sender == address(token), \u0022Invalid token\u0022);\r\n\r\n        uint eth = value.mul(1e14).div(rate);\r\n        address payable to = from.toPayable();\r\n\r\n        require(address(this).balance \u003E= eth, \u0022Insufficient funds\u0022);\r\n        to.transfer(eth);\r\n\r\n        if(tokenHolder != address(0)) {\r\n            token.transfer(tokenHolder, value);\r\n        }\r\n \r\n        emit Operation(to, value, eth);\r\n    }\r\n\r\n    function setRate(uint _rate) onlyOwner external {\r\n        rate = _rate;\r\n    }\r\n\r\n    function setTokenHolder(address _addr) onlyOwner external {\r\n        tokenHolder = _addr;\r\n    }\r\n}","ABI":"[{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022eth\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Operation\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022WithdrawEther\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_percent\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022addWallet\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_index\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_percent\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setWallet\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022wallets\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022percent\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawEther\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawTokensApprove\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawTokensTransfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawTokensTransferFrom\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"OutgoingStream","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://6fb88ca99c592e68856b31a4788df3aafc74c9eedc30bba3c767b938cefcf7a3"}]