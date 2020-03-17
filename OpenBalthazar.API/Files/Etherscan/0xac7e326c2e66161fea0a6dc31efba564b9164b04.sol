[{"SourceCode":"pragma solidity ^0.5.16;\r\n\r\nlibrary SafeMath {\r\n\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) \r\n            return 0;\r\n        uint256 c = a * b;\r\n        require(c / a == b);\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003E 0);\r\n        uint256 c = a / b;\r\n        return c;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a);\r\n        uint256 c = a - b;\r\n        return c;\r\n    }\r\n\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a);\r\n        return c;\r\n    }\r\n\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0);\r\n        return a % b;\r\n    }\r\n}\r\n\r\ncontract Ownable {\r\n    address public owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n    /**\r\n     * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n     * account.\r\n     */\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n    /**\r\n    * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n    * @param newOwner The address to transfer ownership to.\r\n    */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(owner, newOwner);\r\n        owner = newOwner;\r\n    }\r\n}\r\n\r\ncontract ERC20 {\r\n    using SafeMath for uint256;\r\n\r\n    mapping (address =\u003E uint256) internal _balances;\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) internal _allowed;\r\n    \r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n\r\n    uint256 internal _totalSupply;\r\n\r\n    /**\r\n    * @dev Total number of tokens in existence\r\n    */\r\n    function totalSupply() public view returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    /**\r\n    * @dev Gets the balance of the specified address.\r\n    * @param owner The address to query the balance of.\r\n    * @return A uint256 representing the amount owned by the passed address.\r\n    */\r\n    function balanceOf(address owner) public view returns (uint256) {\r\n        return _balances[owner];\r\n    }\r\n\r\n    /**\r\n    * @dev Function to check the amount of tokens that an owner allowed to a spender.\r\n    * @param owner address The address which owns the funds.\r\n    * @param spender address The address which will spend the funds.\r\n    * @return A uint256 specifying the amount of tokens still available for the spender.\r\n    */\r\n    function allowance(address owner, address spender) public view returns (uint256) {\r\n        return _allowed[owner][spender];\r\n    }\r\n\r\n    /**\r\n    * @dev Transfer token to a specified address\r\n    * @param to The address to transfer to.\r\n    * @param value The amount to be transferred.\r\n    */\r\n    function transfer(address to, uint256 value) public returns (bool) {\r\n        _transfer(msg.sender, to, value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\r\n    * Beware that changing an allowance with this method brings the risk that someone may use both the old\r\n    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\r\n    * race condition is to first reduce the spender\u0022s allowance to 0 and set the desired value afterwards:\r\n    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n    * @param spender The address which will spend the funds.\r\n    * @param value The amount of tokens to be spent.\r\n    */\r\n    function approve(address spender, uint256 value) public returns (bool) {\r\n        _allowed[msg.sender][spender] = value;\r\n        emit Approval(msg.sender, spender, value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n    * @dev Transfer tokens from one address to another.\r\n    * Note that while this function emits an Approval event, this is not required as per the specification,\r\n    * and other compliant implementations may not emit the event.\r\n    * @param from address The address which you want to send tokens from\r\n    * @param to address The address which you want to transfer to\r\n    * @param value uint256 the amount of tokens to be transferred\r\n    */\r\n    function transferFrom(address from, address to, uint256 value) public returns (bool) {\r\n        _transfer(from, to, value);\r\n        if(_allowed[msg.sender][to] \u003C uint256(-1)) {\r\n            _allowed[msg.sender][to] = _allowed[msg.sender][to].sub(value);\r\n        }\r\n        return true;\r\n    }\r\n\r\n    function _transfer(address from, address to, uint256 value) internal {\r\n        require(to != address(0));\r\n        _balances[from] = _balances[from].sub(value);\r\n        _balances[to] = _balances[to].add(value);\r\n        emit Transfer(from, to, value);\r\n    }\r\n\r\n}\r\n\r\ncontract ERC20Mintable is ERC20 {\r\n\r\n    function _mint(address to, uint256 amount) internal {\r\n        _balances[to] = _balances[to].add(amount);\r\n        _totalSupply = _totalSupply.add(amount);\r\n        emit Transfer(address(0), to, amount);\r\n    }\r\n\r\n    function _burn(address from, uint256 amount) internal {\r\n        _balances[from] = _balances[from].sub(amount);\r\n        _totalSupply = _totalSupply.sub(amount);\r\n        emit Transfer(from, address(0), amount);\r\n    }\r\n\r\n}\r\n\r\ncontract borrowTokenFallBack {\r\n    function receiveToken(address caller, address token, uint256 amount, uint256 amountToRepay, bytes calldata data) external;\r\n}\r\n\r\ncontract proxy {\r\n    function totalValue() external returns(uint256);\r\n    function totalValueStored() external view returns(uint256);\r\n    function deposit(uint256 amount) external returns(bool);\r\n    function withdraw(address to, uint256 amount) external returns(bool);\r\n    function isProxy() external returns(bool);\r\n}\r\n\r\ncontract DAIHub is ERC20Mintable, Ownable {\r\n    using SafeMath for uint256;\r\n\r\n    address public pendingProxy;\r\n    uint256 public mature;\r\n    uint256 public repayRate; // amount to repay = borrow * repayRate / 1e18\r\n\r\n    ERC20 constant DAI = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);\r\n\r\n    mapping(address =\u003E bool) public isProxy;\r\n\r\n    address[] public proxies;\r\n\r\n    event ProposeProxy(address proxy, uint256 mature);\r\n    event AddProxy(address proxy);\r\n    event Borrow(address indexed who, uint256 amount);\r\n\r\n    //calculate value from all proxies and cash\r\n    function totalValue() public returns(uint256 sum) {  \r\n        sum = cash();\r\n        for(uint256 i = 0; i \u003C proxies.length; i\u002B\u002B){\r\n            sum = sum.add(proxy(proxies[i]).totalValue());\r\n        }\r\n    }\r\n\r\n    function totalValueStored() external view returns(uint256 sum) {\r\n        sum = cash();\r\n        for(uint256 i = 0; i \u003C proxies.length; i\u002B\u002B){\r\n            sum = sum.add(proxy(proxies[i]).totalValueStored());\r\n        }\r\n    }\r\n\r\n    //cash value of an user\u0027s deposit\r\n    function balanceOfUnderlying(address who) public returns(uint256) {\r\n        return balanceOf(who).mul(totalValue()).div(totalSupply());\r\n    }\r\n\r\n    // cash in this contract\r\n    function cash() public view returns(uint256) {\r\n        return DAI.balanceOf(address(this));\r\n    }\r\n\r\n    // deposit money to this contract\r\n    function deposit(address to, uint256 amount) external returns(uint256 increased) {\r\n        \r\n        if(totalSupply() \u003E 0) {\r\n            increased = totalSupply().mul(amount).div(totalValue());\r\n            _mint(to, increased);\r\n        }\r\n        else {\r\n            increased = amount;\r\n            _mint(to, amount);\r\n        }\r\n\r\n        require(DAI.transferFrom(msg.sender, address(this), amount));\r\n    }\r\n\r\n    //withdraw money by burning \u0060amount\u0060 share\r\n    function withdraw(address to, uint256 amount) external {\r\n        uint256 withdrawal = amount.mul(totalValue()).div(totalSupply());\r\n        _burn(msg.sender, amount);\r\n        _withdraw(to, withdrawal);\r\n    }\r\n\r\n    //withdraw certain \u0060amount\u0060 of money\r\n    function withdrawUnderlying(address to, uint256 amount) external {\r\n        uint256 shareToBurn = amount.mul(totalSupply()).div(totalValue()).add(1);\r\n        _burn(msg.sender, shareToBurn);\r\n        _withdraw(to, amount);\r\n    }\r\n\r\n    //borrow \u0060amount\u0060 token, call by EOA\r\n    function borrow(address to, uint256 amount, bytes calldata data) external {\r\n        uint256 repayAmount = amount.mul(repayRate).div(1e18);\r\n        _withdraw(to, amount);\r\n        borrowTokenFallBack(to).receiveToken(msg.sender, address(DAI), amount, repayAmount, data);\r\n        require(DAI.transferFrom(to, address(this), repayAmount));\r\n    }\r\n\r\n    //borrow \u0060amount\u0060 token, call by contract\r\n    function borrow(uint256 amount) external {\r\n        uint256 repayAmount = amount.mul(repayRate).div(1e18);\r\n        _withdraw(msg.sender, amount);\r\n        borrowTokenFallBack(msg.sender).receiveToken(msg.sender, address(DAI), amount, repayAmount, bytes(\u0022\u0022));\r\n        require(DAI.transferFrom(msg.sender, address(this), repayAmount));\r\n    }\r\n\r\n    function _withdraw(address to, uint256 amount) internal {\r\n        uint256 _cash = cash();\r\n\r\n        if(amount \u003C= _cash) {\r\n            require(DAI.transfer(msg.sender, amount));\r\n        }\r\n        else {\r\n            require(DAI.transfer(msg.sender, _cash));\r\n            amount -= _cash;\r\n            \r\n            for(uint256 i = 0; i \u003C proxies.length \u0026\u0026 amount \u003E 0; i\u002B\u002B) {\r\n                _cash = proxy(proxies[i]).totalValue();\r\n                if(_cash == 0) continue;\r\n                if(amount \u003C= _cash) {\r\n                    proxy(proxies[i]).withdraw(to, amount);\r\n                    amount = 0;\r\n                }\r\n                else {\r\n                    proxy(proxies[i]).withdraw(to, _cash);\r\n                    amount -= _cash;\r\n                }\r\n            }\r\n            require(amount == 0);\r\n        }\r\n    }\r\n\r\n    //propose a new proxy to be added\r\n    function proposeProxy(address _proxy) external onlyOwner {\r\n        pendingProxy = _proxy;\r\n        mature = now.add(7 days);\r\n        emit ProposeProxy(_proxy, mature);\r\n    }\r\n\r\n    //add a new proxy by owner\r\n    function addProxy() external onlyOwner {\r\n        require(now \u003E= mature);\r\n        require(isProxy[pendingProxy] == false);\r\n        //require(proxy(pendingProxy).isProxy());\r\n        isProxy[pendingProxy] = true;\r\n        proxies.push(pendingProxy);\r\n        DAI.approve(pendingProxy, uint256(-1));\r\n        emit AddProxy(pendingProxy);\r\n        pendingProxy = address(0);\r\n    }\r\n\r\n    //invest cash to a proxy\r\n    function invest(address _proxy, uint256 amount) external onlyOwner {\r\n        require(isProxy[_proxy]);\r\n        proxy(_proxy).deposit(amount);\r\n    }\r\n\r\n    //redeem investment from a proxy\r\n    function redeem(address _proxy, uint256 amount) external onlyOwner {\r\n        require(isProxy[_proxy]);\r\n        proxy(_proxy).withdraw(address(this), amount);\r\n    }\r\n\r\n    //set new repay rate\r\n    function setRepayRate(uint256 newRepayRate) external onlyOwner {\r\n        require(newRepayRate \u003C= 1.05e18); //repayRate must be less than 105%\r\n        repayRate = newRepayRate;\r\n    }\r\n\r\n    //swap position of two proxies in list\r\n    function swapProxy(uint256 a, uint256 b) external onlyOwner {\r\n        require(a \u003C proxies.length \u0026\u0026 b \u003C proxies.length);\r\n        (proxies[a], proxies[b]) = (proxies[b], proxies[a]);\r\n    }\r\n\r\n    //ERC20 token info\r\n    uint8 public decimals;\r\n    string public name;\r\n    string public symbol; \r\n\r\n    //constructor\r\n    constructor(address[] memory _proxies) public {\r\n        for(uint256 i = 0; i \u003C _proxies.length; i\u002B\u002B){\r\n            proxies.push(_proxies[i]);\r\n            isProxy[_proxies[i]] = true;\r\n            DAI.approve(_proxies[i], uint256(-1));\r\n        }\r\n        repayRate = 1.002e18;\r\n        decimals = 18;\r\n        name = \u0022DAIHub\u0022;\r\n        symbol = \u0022hDAI\u0022;\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022_proxies\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022proxy\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022AddProxy\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Borrow\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022proxy\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022mature\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ProposeProxy\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022addProxy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOfUnderlying\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022borrow\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022borrow\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022cash\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022deposit\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022increased\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_proxy\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022invest\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isProxy\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022mature\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pendingProxy\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_proxy\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022proposeProxy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022proxies\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_proxy\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022redeem\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022repayRate\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022newRepayRate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setRepayRate\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022swapProxy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalValue\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022sum\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalValueStored\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022sum\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawUnderlying\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"DAIHub","CompilerVersion":"v0.5.16\u002Bcommit.9c3226ce","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000003000000000000000000000000fb2d0ccd602643132e527e6e2dd959597f914728000000000000000000000000e78b1172bdb1e2156e372b2dd499c6a44b6232290000000000000000000000008ff1bfde46e3f697b5a024639b636184ab298294","Library":"","SwarmSource":"bzzr://026e2bc310bc84cc4b8fa53bb52894a94e74573dd82a85cbdf5bff0de06429dc"}]