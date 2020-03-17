[{"SourceCode":"{\u0022LeadToken.sol\u0022:{\u0022content\u0022:\u0022pragma solidity \\u003e=0.5.0 \\u003c 0.6.0;\\n\\nimport \\\u0022./Owned.sol\\\u0022;\\n\\nlibrary SafeMath {\\n    function add(uint a, uint b) internal pure returns (uint c) {\\n        c = a \u002B b;\\n        require(c \\u003e= a);\\n    }\\n\\n    function sub(uint a, uint b) internal pure returns (uint c) {\\n        require(b \\u003c= a);\\n        c = a - b;\\n    }\\n\\n    function mul(uint a, uint b) internal pure returns (uint c) {\\n        c = a * b;\\n        require(a == 0 || c / a == b);\\n    }\\n\\n    function div(uint a, uint b) internal pure returns (uint c) {\\n        require(b \\u003e 0);\\n        c = a / b;\\n    }\\n}\\n\\ninterface ERC20Interface {\\n    function totalSupply() external view returns (uint);\\n    function balanceOf(address _owner) external view returns (uint balance);\\n    function allowance(address _owner, address _spender) external view returns (uint remaining);\\n    function transfer(address _to, uint _tokens) external returns (bool success);\\n    function approve(address _spender, uint _tokens) external returns (bool success);\\n    function transferFrom(address _from, address _to, uint _tokens) external returns (bool success);\\n    event Transfer(address indexed _from, address indexed _to, uint _tokens);\\n    event Approval(address indexed _owner, address indexed _spender, uint _tokens);\\n}\\n\\ncontract LeadToken is ERC20Interface, Owned {\\n    using SafeMath for uint;\\n    \\n    string public name;\\n    string public symbol;\\n    uint8 public decimals; // 18 decimals is the strongly suggested default, avoid changing it\\n    uint public _totalSupply;\\n    \\n    /**\\n     * Constrctor function\\n     *\\n     * Initializes contract with initial supply tokens to the creator of the contract\\n     */\\n    constructor() public {\\n        name = \\\u0022Lead Token\\\u0022;\\n        symbol = \\\u0022LEAD\\\u0022;\\n        decimals = 18;\\n        _totalSupply = 1000000000000000000000000000;\\n        \\n        balances[0xEF263326533E2803e56148a5A8857817e9dE7e6F] = _totalSupply;\\n        emit Transfer(address(0), 0xEF263326533E2803e56148a5A8857817e9dE7e6F, _totalSupply);\\n    }\\n    \\n    // Generates a public event on the blockchain that will notify clients\\n    event Transfer(\\n        address indexed _from,\\n        address indexed _to,\\n        uint _value\\n    );\\n    \\n    // This notifies clients about the amount burnt\\n    event Burn(\\n        address indexed from, \\n        uint value\\n    );                                                                                          \\n    \\n    // Generates a public event on the blockchain that will notify clients\\n    event Approval(\\n        address indexed _owner,\\n        address indexed _spender,\\n        uint _value\\n    );\\n    \\n    // This creates an array with all balances\\n    mapping(address =\\u003e uint) balances;\\n    mapping(address =\\u003e mapping(address =\\u003e uint)) allowed;\\n    \\n  \\n    function totalSupply() external view returns (uint) {\\n        return _totalSupply;\\n    }\\n    \\n    /**\\n     * Internal transfer, can only be called by this contract\\n     */\\n    function _transfer(address _from, address _to, uint _value) internal {\\n        require(_to != address(0x0));\\n        require(balances[_from] \\u003e= _value);\\n        require(balances[_to].add(_value) \\u003e= balances[_to]);\\n        balances[_from] = balances[_from].sub(_value);\\n        balances[_to] = balances[_to].add(_value);\\n        emit Transfer(_from, _to, _value);\\n    }\\n    \\n    /**\\n     * Transfer tokens\\n     *\\n     * Send \u0060_value\u0060 tokens to \u0060_to\u0060 from your account\\n     *\\n     * @param _to The address of the recipient\\n     * @param _value the amount to send\\n     */\\n    function transfer(address _to, uint _value) public returns(bool success){\\n        _transfer(msg.sender, _to, _value);\\n        return true;\\n    }\\n    \\n    /**\\n     * Transfer tokens from other address\\n     *\\n     * Send \u0060_value\u0060 tokens to \u0060_to\u0060 in behalf of \u0060_from\u0060\\n     *\\n     * @param _from The address of the sender\\n     * @param _to The address of the recipient\\n     * @param _value the amount to send\\n     */\\n    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {\\n        require(_value \\u003c= allowed[_from][msg.sender]);\\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\\n        _transfer(_from, _to, _value);\\n        return true;\\n    }\\n    \\n    /**\\n     * Set allowance for other address\\n     *\\n     * Allows \u0060_spender\u0060 to spend no more than \u0060_value\u0060 tokens in your behalf\\n     *\\n     * @param _spender The address authorized to spend\\n     * @param _value the max amount they can spend\\n     */\\n    function approve(address _spender, uint _value) public returns (bool success) {\\n        allowed[msg.sender][_spender] = _value;\\n        emit Approval(msg.sender, _spender, _value);\\n        return true;\\n    }\\n    \\n    /**\\n     * Returns the amount of tokens approved by the owner that can be transferred to the spender\\u0027s account\\n     */\\n    function allowance(address _owner, address _spender) public view returns (uint remaining) {\\n        return allowed[_owner][_spender];\\n    }\\n    \\n    /**\\n     * Get the token balance for account \u0060tokenOwner\u0060\\n     */\\n    function balanceOf(address _owner) public view returns (uint balance) {\\n        return balances[_owner];\\n    }\\n    \\n    /** \\n     * @dev Creates \u0060amount\u0060 tokens and assigns them to \u0060account\u0060, increasing\\n     * the total supply.\\n     *\\n     * Emits a {Transfer} event with \u0060from\u0060 set to the zero address.\\n     *\\n     * Requirements\\n     *\\n     * - \u0060to\u0060 cannot be the zero address.\\n     */\\n    function _mint(address _account, uint256 _amount) internal {\\n        require(_account != address(0x0), \\\u0022ERC20: mint to the zero address\\\u0022);\\n        _totalSupply = _totalSupply.add(_amount);\\n        balances[_account] = balances[_account].add(_amount);\\n        emit Transfer(address(0), _account, _amount);\\n    }\\n    \\n    /**\\n     * Destroy tokens\\n     *\\n     * Remove \u0060_value\u0060 tokens from the system irreversibly\\n     *\\n     * @param _value is the amount of token to burn\\n     */\\n    function burn(uint _value) public returns (bool success) {\\n        require(balances[msg.sender] \\u003e= _value);   \\n        balances[msg.sender] = balances[msg.sender].sub(_value);\\n        _totalSupply = _totalSupply.sub(_value);                      \\n        emit Burn(msg.sender, _value);\\n        return true;\\n    }\\n    \\n    /**\\n     * Destroy tokens from other account\\n     *\\n     * Remove \u0060_value\u0060 tokens from the system irreversibly on behalf of \u0060_from\u0060.\\n     *\\n     * @param _from the address of the sender\\n     * @param _value the amount of money to burn\\n     */\\n    function burnFrom(address _from, uint _value) public returns (bool success) {\\n        require(balances[_from] \\u003e= _value);                \\n        require(_value \\u003c= allowed[_from][msg.sender]); \\n        balances[_from] =  balances[_from].sub(_value);                        \\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);             \\n        _totalSupply = _totalSupply.sub(_value);                             \\n        emit Burn(_from, _value);\\n        return true;\\n    }\\n    \\n    /**\\n     * Owner can transfer out any accidentally sent ERC20 tokens\\n     */\\n\\n    function transferAnyERC20Token(address _tokenAddress, uint _tokens) public onlyOwner returns (bool success) {\\n        return ERC20Interface(_tokenAddress).transfer(owner, _tokens);\\n    }\\n    \\n}\\n\u0022},\u0022Owned.sol\u0022:{\u0022content\u0022:\u0022pragma solidity \\u003e=0.5.0 \\u003c 0.6.0;\\n\\n/**\\n * @title Owned\\n * Copied from OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol\\n * @dev The Owned contract has an owner address, and provides basic authorization control\\n * functions, this simplifies the implementation of \\\u0022user permissions\\\u0022.\\n */\\n  \\ncontract Owned {\\n    address public owner;\\n\\n    event OwnershipTransferred(address indexed _from, address indexed _to);\\n\\n/**\\n  * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\\n  * account.\\n  */\\n  \\n    constructor() public {\\n        owner = msg.sender;\\n    }\\n\\n/**\\n  * @dev Throws if called by any account other than the owner.\\n  */\\n  \\n    modifier onlyOwner {\\n        require(msg.sender == owner);\\n        _;\\n    }\\n\\n/**\\n * @dev Allows the current owner to transfer control of the contract to a newOwner.\\n * @param _newOwner is the address to transfer ownership to.\\n */\\n \\n    function transferOwnership(address _newOwner) public onlyOwner {\\n        owner = _newOwner;\\n        emit OwnershipTransferred(owner, _newOwner); \\n    }\\n}\\n\u0022}}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burnFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferAnyERC20Token\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"LeadToken","CompilerVersion":"v0.5.0\u002Bcommit.1d4f565a","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://a876e132c65b9b08e9441548bba99a066fa56e55dba8f3c62a36a9a9453052e1"}]