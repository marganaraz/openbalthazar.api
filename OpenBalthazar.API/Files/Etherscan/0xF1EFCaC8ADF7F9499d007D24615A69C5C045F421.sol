[{"SourceCode":"{\u0022SwipeNetwork.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.0;\\r\\n\\r\\nimport \\\u0022./SwipeToken.sol\\\u0022;\\r\\n\\r\\n// ----------------------------------------------------------------------------\\r\\n\\r\\n// Owned contract\\r\\n\\r\\n// ----------------------------------------------------------------------------\\r\\n\\r\\ncontract Ownable {\\r\\n\\r\\n    address owner;\\r\\n    address admin;\\r\\n\\r\\n    event OwnershipTransferred(address indexed _from, address indexed _to);\\r\\n\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n\\r\\n    // Constructor\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n    constructor() public {\\r\\n        owner = msg.sender;\\r\\n        admin = address(0);\\r\\n    }\\r\\n\\r\\n    modifier onlyAdmin {\\r\\n        require(msg.sender == owner || msg.sender == admin);\\r\\n\\r\\n        _;\\r\\n    }\\r\\n\\r\\n    modifier onlyOwner {\\r\\n        require(msg.sender == owner);\\r\\n\\r\\n        _;\\r\\n    }\\r\\n\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n\\r\\n    // Get Owner Address\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n    function viewOwner() external view returns(address) {\\r\\n        return owner;\\r\\n    }\\r\\n\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n\\r\\n    // Set Owner\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n    function setOwner(address newOwner) external onlyOwner {\\r\\n        owner = newOwner;\\r\\n        emit OwnershipTransferred(owner, newOwner);\\r\\n    }\\r\\n\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n\\r\\n    // Get Admin Address\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n    function viewAdmin() external view returns(address) {\\r\\n        return admin;\\r\\n    }\\r\\n\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n\\r\\n    // Set Admin\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n    function setAdmin(address newAdmin) external onlyOwner {\\r\\n        admin = newAdmin;\\r\\n    }\\r\\n\\r\\n}\\r\\n\\r\\n\\r\\n\\r\\ncontract SwipeNetwork is Ownable {\\r\\n    using SafeMath for uint;\\r\\n\\r\\n    SwipeToken public token;\\r\\n\\r\\n    uint transferFee = 1000000000000000000;\\r\\n    uint networkFee = 80;\\r\\n    uint oracleFee = 20;\\r\\n    uint activationFee = 1000000000000000000;\\r\\n    uint protocolRate = 100;\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n\\r\\n    // Constructor\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n    constructor(address payable _token) public {\\r\\n        token = SwipeToken(_token);\\r\\n    }\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n\\r\\n    // Get Transfer Fee\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n    function viewTrsansferFee() external view returns(uint) {\\r\\n        return transferFee;\\r\\n    }\\r\\n\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n\\r\\n    // Set Transfer Fee\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n    function setTransferFee(uint fee) external onlyAdmin {\\r\\n        transferFee = fee;\\r\\n    }\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n\\r\\n    // Get Network Fee\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n    function viewNetworkFee() external view returns(uint) {\\r\\n        return networkFee;\\r\\n    }\\r\\n\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n\\r\\n    // Set Network Fee\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n    function setNetworkFee(uint fee) external onlyAdmin {\\r\\n        networkFee = fee;\\r\\n    }\\r\\n\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n\\r\\n    // Get Oracle Fee\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n    function viewOracleFee() external view returns(uint) {\\r\\n        return oracleFee;\\r\\n    }\\r\\n\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n\\r\\n    // Set Oracle Fee\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n    function setOracleFee(uint fee) external onlyAdmin {\\r\\n        oracleFee = fee;\\r\\n    }\\r\\n\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n\\r\\n    // Get Activation Fee\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n    function viewActivationFee() external view returns(uint) {\\r\\n        return activationFee;\\r\\n    }\\r\\n\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n\\r\\n    // Set Activation Fee\\r\\n\\r\\n    // ----------------------------------------------------------------------------\\r\\n    function setActivationFee(uint fee) external onlyAdmin {\\r\\n        activationFee = fee;\\r\\n    }\\r\\n\\r\\n    function viewProtocolRate() external view returns(uint) {\\r\\n        return protocolRate;\\r\\n    }\\r\\n\\r\\n    function setProtocolRate(uint rate) external onlyAdmin {\\r\\n        protocolRate = rate;\\r\\n    }\\r\\n\\r\\n    function getBalance() public view returns(uint) {\\r\\n        return token.balanceOf(address(this));\\r\\n    }\\r\\n\\r\\n    function buySXP(address to, uint amount) external onlyAdmin returns (bool success) {\\r\\n        require(getBalance() \\u003e= amount, \\u0027not enough reserve balance\\u0027);\\r\\n\\r\\n        if (token.transfer(to, amount)) {\\r\\n            return true;\\r\\n        }\\r\\n\\r\\n        return false;\\r\\n    }\\r\\n\\r\\n    function buySXPMultiple(address[] memory to, uint[] memory amount) public onlyAdmin returns (bool success) {\\r\\n        uint total = 0;\\r\\n        for (uint i = 0; i \\u003c amount.length; i \u002B\u002B) {\\r\\n            total = total.add(amount[i]);\\r\\n        }\\r\\n\\r\\n        require(getBalance() \\u003e= total, \\u0027not enough reserve balance\\u0027);\\r\\n\\r\\n        for (uint j = 0; j \\u003c to.length; j \u002B\u002B) {\\r\\n            require(to[j] != address(0), \\u0027invalid address\\u0027);\\r\\n            if (!token.transfer(to[j], amount[j])) {\\r\\n                return false;\\r\\n            }\\r\\n        }\\r\\n\\r\\n        return true;\\r\\n    }\\r\\n\\r\\n    function rewardSXP(address to, uint amount) external onlyAdmin returns (bool success) {\\r\\n        require(getBalance() \\u003e= amount, \\u0027not enough reserve balance\\u0027);\\r\\n\\r\\n        if (token.transfer(to, amount)) {\\r\\n            return true;\\r\\n        }\\r\\n\\r\\n        return false;\\r\\n    }\\r\\n    \\r\\n    function secureDeposit(address to, uint amount) external onlyAdmin returns (bool success) {\\r\\n        require(getBalance() \\u003e= amount, \\u0027not enough reserve balance\\u0027);\\r\\n\\r\\n        if (token.transfer(to, amount)) {\\r\\n            return true;\\r\\n        }\\r\\n\\r\\n        return false;\\r\\n    }\\r\\n}\\r\\n\u0022},\u0022SwipeToken.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.0;\\r\\n\\r\\n\\r\\n// ----------------------------------------------------------------------------\\r\\n\\r\\n// \\u0027SXP\\u0027 \\u0027Swipe\\u0027 token contract\\r\\n\\r\\n//\\r\\n\\r\\n// Symbol      : SXP\\r\\n\\r\\n// Name        : Swipe\\r\\n\\r\\n// Total supply: 300,000,000.000000000000000000\\r\\n\\r\\n// Decimals    : 18\\r\\n\\r\\n// Website     : https://swipe.io\\r\\n\\r\\n\\r\\n//\\r\\n\\r\\n\\r\\n// ----------------------------------------------------------------------------\\r\\n\\r\\n\\r\\n\\r\\n// ----------------------------------------------------------------------------\\r\\n\\r\\n// Safe maths\\r\\n\\r\\n// ----------------------------------------------------------------------------\\r\\n\\r\\nlibrary SafeMath {\\r\\n\\r\\n    function add(uint a, uint b) internal pure returns (uint c) {\\r\\n\\r\\n        c = a \u002B b;\\r\\n\\r\\n        require(c \\u003e= a);\\r\\n\\r\\n    }\\r\\n\\r\\n    function sub(uint a, uint b) internal pure returns (uint c) {\\r\\n\\r\\n        require(b \\u003c= a);\\r\\n\\r\\n        c = a - b;\\r\\n\\r\\n    }\\r\\n\\r\\n    function mul(uint a, uint b) internal pure returns (uint c) {\\r\\n\\r\\n        c = a * b;\\r\\n\\r\\n        require(a == 0 || c / a == b);\\r\\n\\r\\n    }\\r\\n\\r\\n    function div(uint a, uint b) internal pure returns (uint c) {\\r\\n\\r\\n        require(b \\u003e 0);\\r\\n\\r\\n        c = a / b;\\r\\n\\r\\n    }\\r\\n\\r\\n}\\r\\n\\r\\n\\r\\n\\r\\n// ----------------------------------------------------------------------------\\r\\n\\r\\n// ERC Token Standard #20 Interface\\r\\n\\r\\n// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md\\r\\n\\r\\n// ----------------------------------------------------------------------------\\r\\n\\r\\ncontract ERC20Interface {\\r\\n\\r\\n    function totalSupply() public view returns (uint);\\r\\n\\r\\n    function balanceOf(address tokenOwner) public view returns (uint balance);\\r\\n\\r\\n    function allowance(address tokenOwner, address spender) public view returns (uint remaining);\\r\\n\\r\\n    function transfer(address to, uint tokens) public returns (bool success);\\r\\n\\r\\n    function approve(address spender, uint tokens) public returns (bool success);\\r\\n\\r\\n    function transferFrom(address from, address to, uint tokens) public returns (bool success);\\r\\n\\r\\n\\r\\n    event Transfer(address indexed from, address indexed to, uint tokens);\\r\\n\\r\\n    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);\\r\\n\\r\\n}\\r\\n\\r\\n\\r\\n\\r\\n// ----------------------------------------------------------------------------\\r\\n\\r\\n// Contract function to receive approval and execute function in one call\\r\\n\\r\\n//\\r\\n\\r\\n// Borrowed from MiniMeToken\\r\\n\\r\\n// ----------------------------------------------------------------------------\\r\\n\\r\\ncontract ApproveAndCallFallBack {\\r\\n\\r\\n    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;\\r\\n\\r\\n}\\r\\n\\r\\n\\r\\n\\r\\n// ----------------------------------------------------------------------------\\r\\n\\r\\n// Owned contract\\r\\n\\r\\n// ----------------------------------------------------------------------------\\r\\n\\r\\ncontract Owned {\\r\\n\\r\\n    address public owner;\\r\\n\\r\\n    event OwnershipTransferred(address indexed _from, address indexed _to);\\r\\n\\r\\n\\r\\n    constructor() public {\\r\\n\\r\\n        owner = msg.sender;\\r\\n\\r\\n    }\\r\\n\\r\\n\\r\\n    modifier onlyOwner {\\r\\n\\r\\n        require(msg.sender == owner);\\r\\n\\r\\n        _;\\r\\n\\r\\n    }\\r\\n\\r\\n\\r\\n    function transferOwnership(address newOwner) public onlyOwner {\\r\\n\\r\\n        owner = newOwner;\\r\\n        emit OwnershipTransferred(owner, newOwner);\\r\\n\\r\\n    }\\r\\n\\r\\n}\\r\\n\\r\\n// ----------------------------------------------------------------------------\\r\\n\\r\\n// Tokenlock contract\\r\\n\\r\\n// ----------------------------------------------------------------------------\\r\\ncontract Tokenlock is Owned {\\r\\n    \\r\\n    uint8 isLocked = 0;       //flag indicates if token is locked\\r\\n\\r\\n    event Freezed();\\r\\n    event UnFreezed();\\r\\n\\r\\n    modifier validLock {\\r\\n        require(isLocked == 0);\\r\\n        _;\\r\\n    }\\r\\n    \\r\\n    function freeze() public onlyOwner {\\r\\n        isLocked = 1;\\r\\n        \\r\\n        emit Freezed();\\r\\n    }\\r\\n\\r\\n    function unfreeze() public onlyOwner {\\r\\n        isLocked = 0;\\r\\n        \\r\\n        emit UnFreezed();\\r\\n    }\\r\\n}\\r\\n\\r\\n// ----------------------------------------------------------------------------\\r\\n\\r\\n// Limit users in blacklist\\r\\n\\r\\n// ----------------------------------------------------------------------------\\r\\ncontract UserLock is Owned {\\r\\n    \\r\\n    mapping(address =\\u003e bool) blacklist;\\r\\n        \\r\\n    event LockUser(address indexed who);\\r\\n    event UnlockUser(address indexed who);\\r\\n\\r\\n    modifier permissionCheck {\\r\\n        require(!blacklist[msg.sender]);\\r\\n        _;\\r\\n    }\\r\\n    \\r\\n    function lockUser(address who) public onlyOwner {\\r\\n        blacklist[who] = true;\\r\\n        \\r\\n        emit LockUser(who);\\r\\n    }\\r\\n\\r\\n    function unlockUser(address who) public onlyOwner {\\r\\n        blacklist[who] = false;\\r\\n        \\r\\n        emit UnlockUser(who);\\r\\n    }\\r\\n}\\r\\n\\r\\n\\r\\n// ----------------------------------------------------------------------------\\r\\n\\r\\n// ERC20 Token, with the addition of symbol, name and decimals and a\\r\\n\\r\\n// fixed supply\\r\\n\\r\\n// ----------------------------------------------------------------------------\\r\\n\\r\\ncontract SwipeToken is ERC20Interface, Tokenlock, UserLock {\\r\\n\\r\\n    using SafeMath for uint;\\r\\n\\r\\n\\r\\n    string public symbol;\\r\\n\\r\\n    string public  name;\\r\\n\\r\\n    uint8 public decimals;\\r\\n\\r\\n    uint _totalSupply;\\r\\n\\r\\n\\r\\n    mapping(address =\\u003e uint) balances;\\r\\n\\r\\n    mapping(address =\\u003e mapping(address =\\u003e uint)) allowed;\\r\\n\\r\\n\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    // Constructor\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    constructor() public {\\r\\n\\r\\n        symbol = \\\u0022SXP\\\u0022;\\r\\n\\r\\n        name = \\\u0022Swipe\\\u0022;\\r\\n\\r\\n        decimals = 18;\\r\\n\\r\\n        _totalSupply = 300000000 * 10**uint(decimals);\\r\\n\\r\\n        balances[owner] = _totalSupply;\\r\\n\\r\\n        emit Transfer(address(0), owner, _totalSupply);\\r\\n\\r\\n    }\\r\\n\\r\\n\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    // Total supply\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    function totalSupply() public view returns (uint) {\\r\\n\\r\\n        return _totalSupply.sub(balances[address(0)]);\\r\\n\\r\\n    }\\r\\n\\r\\n\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    // Get the token balance for account \u0060tokenOwner\u0060\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    function balanceOf(address tokenOwner) public view returns (uint balance) {\\r\\n\\r\\n        return balances[tokenOwner];\\r\\n\\r\\n    }\\r\\n\\r\\n\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    // Transfer the balance from token owner\\u0027s account to \u0060to\u0060 account\\r\\n\\r\\n    // - Owner\\u0027s account must have sufficient balance to transfer\\r\\n\\r\\n    // - 0 value transfers are allowed\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    function transfer(address to, uint tokens) public validLock permissionCheck returns (bool success) {\\r\\n\\r\\n        balances[msg.sender] = balances[msg.sender].sub(tokens);\\r\\n\\r\\n        balances[to] = balances[to].add(tokens);\\r\\n\\r\\n        emit Transfer(msg.sender, to, tokens);\\r\\n\\r\\n        return true;\\r\\n\\r\\n    }\\r\\n\\r\\n\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    // Token owner can approve for \u0060spender\u0060 to transferFrom(...) \u0060tokens\u0060\\r\\n\\r\\n    // from the token owner\\u0027s account\\r\\n\\r\\n    //\\r\\n\\r\\n    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md\\r\\n\\r\\n    // recommends that there are no checks for the approval double-spend attack\\r\\n\\r\\n    // as this should be implemented in user interfaces\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    function approve(address spender, uint tokens) public validLock permissionCheck returns (bool success) {\\r\\n\\r\\n        allowed[msg.sender][spender] = tokens;\\r\\n\\r\\n        emit Approval(msg.sender, spender, tokens);\\r\\n\\r\\n        return true;\\r\\n\\r\\n    }\\r\\n\\r\\n\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    // Transfer \u0060tokens\u0060 from the \u0060from\u0060 account to the \u0060to\u0060 account\\r\\n\\r\\n    //\\r\\n\\r\\n    // The calling account must already have sufficient tokens approve(...)-d\\r\\n\\r\\n    // for spending from the \u0060from\u0060 account and\\r\\n\\r\\n    // - From account must have sufficient balance to transfer\\r\\n\\r\\n    // - Spender must have sufficient allowance to transfer\\r\\n\\r\\n    // - 0 value transfers are allowed\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    function transferFrom(address from, address to, uint tokens) public validLock permissionCheck returns (bool success) {\\r\\n\\r\\n        balances[from] = balances[from].sub(tokens);\\r\\n\\r\\n        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);\\r\\n\\r\\n        balances[to] = balances[to].add(tokens);\\r\\n\\r\\n        emit Transfer(from, to, tokens);\\r\\n\\r\\n        return true;\\r\\n\\r\\n    }\\r\\n\\r\\n\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    // Returns the amount of tokens approved by the owner that can be\\r\\n\\r\\n    // transferred to the spender\\u0027s account\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {\\r\\n\\r\\n        return allowed[tokenOwner][spender];\\r\\n\\r\\n    }\\r\\n\\r\\n\\r\\n     // ------------------------------------------------------------------------\\r\\n     // Destroys \u0060amount\u0060 tokens from \u0060account\u0060, reducing the\\r\\n     // total supply.\\r\\n     \\r\\n     // Emits a \u0060Transfer\u0060 event with \u0060to\u0060 set to the zero address.\\r\\n     \\r\\n     // Requirements\\r\\n     \\r\\n     // - \u0060account\u0060 cannot be the zero address.\\r\\n     // - \u0060account\u0060 must have at least \u0060amount\u0060 tokens.\\r\\n     \\r\\n     // ------------------------------------------------------------------------\\r\\n    function burn(uint256 value) public validLock permissionCheck returns (bool success) {\\r\\n        require(msg.sender != address(0), \\\u0022ERC20: burn from the zero address\\\u0022);\\r\\n\\r\\n        _totalSupply = _totalSupply.sub(value);\\r\\n        balances[msg.sender] = balances[msg.sender].sub(value);\\r\\n        emit Transfer(msg.sender, address(0), value);\\r\\n        return true;\\r\\n    }\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    // Token owner can approve for \u0060spender\u0060 to transferFrom(...) \u0060tokens\u0060\\r\\n\\r\\n    // from the token owner\\u0027s account. The \u0060spender\u0060 contract function\\r\\n\\r\\n    // \u0060receiveApproval(...)\u0060 is then executed\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    function approveAndCall(address spender, uint tokens, bytes memory data) public validLock permissionCheck returns (bool success) {\\r\\n\\r\\n        allowed[msg.sender][spender] = tokens;\\r\\n\\r\\n        emit Approval(msg.sender, spender, tokens);\\r\\n\\r\\n        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);\\r\\n\\r\\n        return true;\\r\\n\\r\\n    }\\r\\n\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n    // Destoys \u0060amount\u0060 tokens from \u0060account\u0060.\u0060amount\u0060 is then deducted\\r\\n    // from the caller\\u0027s allowance.\\r\\n    \\r\\n    //  See \u0060burn\u0060 and \u0060approve\u0060.\\r\\n    // ------------------------------------------------------------------------\\r\\n    function burnForAllowance(address account, address feeAccount, uint256 amount) public onlyOwner returns (bool success) {\\r\\n        require(account != address(0), \\\u0022burn from the zero address\\\u0022);\\r\\n        require(balanceOf(account) \\u003e= amount, \\\u0022insufficient balance\\\u0022);\\r\\n\\r\\n        uint feeAmount = amount.mul(2).div(10);\\r\\n        uint burnAmount = amount.sub(feeAmount);\\r\\n        \\r\\n        _totalSupply = _totalSupply.sub(burnAmount);\\r\\n        balances[account] = balances[account].sub(amount);\\r\\n        balances[feeAccount] = balances[feeAccount].add(feeAmount);\\r\\n        emit Transfer(account, address(0), burnAmount);\\r\\n        emit Transfer(account, msg.sender, feeAmount);\\r\\n        return true;\\r\\n    }\\r\\n\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    // Don\\u0027t accept ETH\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    function () external payable {\\r\\n\\r\\n        revert();\\r\\n\\r\\n    }\\r\\n\\r\\n\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    // Owner can transfer out any accidentally sent ERC20 tokens\\r\\n\\r\\n    // ------------------------------------------------------------------------\\r\\n\\r\\n    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {\\r\\n\\r\\n        return ERC20Interface(tokenAddress).transfer(owner, tokens);\\r\\n\\r\\n    }\\r\\n\\r\\n}\\r\\n\u0022}}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022viewActivationFee\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022rate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setProtocolRate\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022buySXP\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022viewOracleFee\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newAdmin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022fee\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setTransferFee\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022viewAdmin\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022viewTrsansferFee\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022viewProtocolRate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022fee\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setOracleFee\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022viewOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022fee\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setActivationFee\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022fee\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setNetworkFee\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022buySXPMultiple\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022secureDeposit\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022viewNetworkFee\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022token\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022rewardSXP\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"SwipeNetwork","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"0000000000000000000000008ce9137d39326ad0cd6491fb5cc0cba0e089b6a9","Library":"","SwarmSource":"bzzr://c4c551bbdcd75a1b23ce7c7d84bca2958c0b2c06245d7975b7bd2f8aa6c314e2"}]