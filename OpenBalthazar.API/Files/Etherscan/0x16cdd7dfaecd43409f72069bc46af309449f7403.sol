[{"SourceCode":"{\u0022ERC20Interface.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.17;\\n\\n// ----------------------------------------------------------------------------\\n// Standard ERC20 Interface\\n//\\n// Copyright (c) 2017 OpenST Ltd.\\n// https://simpletoken.org/\\n//\\n// The MIT Licence.\\n// ----------------------------------------------------------------------------\\n\\n\\n// ----------------------------------------------------------------------------\\n// Based on the \\u0027final\\u0027 ERC20 token standard as specified at:\\n// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md\\n// ----------------------------------------------------------------------------\\n\\ncontract ERC20Interface {\\n\\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\\n\\n    function name() public view returns (string);\\n    function symbol() public view returns (string);\\n    function decimals() public view returns (uint8);\\n    function totalSupply() public view returns (uint256);\\n\\n    function balanceOf(address _owner) public view returns (uint256 balance);\\n    function allowance(address _owner, address _spender) public view returns (uint256 remaining);\\n\\n    function transfer(address _to, uint256 _value) public returns (bool success);\\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);\\n    function approve(address _spender, uint256 _value) public returns (bool success);\\n}\\n\u0022},\u0022ERC20Token.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.17;\\n\\n// ----------------------------------------------------------------------------\\n// Standard ERC20 Token Implementation\\n//\\n// Copyright (c) 2017 OpenST Ltd.\\n// https://simpletoken.org/\\n//\\n// The MIT Licence.\\n// ----------------------------------------------------------------------------\\n\\nimport \\\u0022./ERC20Interface.sol\\\u0022;\\nimport \\\u0022./Owned.sol\\\u0022;\\nimport \\\u0022./SafeMath.sol\\\u0022;\\n\\n\\n//\\n// Standard ERC20 implementation, with ownership.\\n//\\ncontract ERC20Token is ERC20Interface, Owned {\\n\\n    using SafeMath for uint256;\\n\\n    string  private tokenName;\\n    string  private tokenSymbol;\\n    uint8   private tokenDecimals;\\n    uint256 internal tokenTotalSupply;\\n\\n    mapping(address =\\u003e uint256) balances;\\n    mapping(address =\\u003e mapping (address =\\u003e uint256)) allowed;\\n\\n\\n    function ERC20Token(string _symbol, string _name, uint8 _decimals, uint256 _totalSupply) public\\n        Owned()\\n    {\\n        tokenSymbol      = _symbol;\\n        tokenName        = _name;\\n        tokenDecimals    = _decimals;\\n        tokenTotalSupply = _totalSupply;\\n        balances[owner]  = _totalSupply;\\n\\n        // According to the ERC20 standard, a token contract which creates new tokens should trigger\\n        // a Transfer event and transfers of 0 values must also fire the event.\\n        Transfer(0x0, owner, _totalSupply);\\n    }\\n\\n\\n    function name() public view returns (string) {\\n        return tokenName;\\n    }\\n\\n\\n    function symbol() public view returns (string) {\\n        return tokenSymbol;\\n    }\\n\\n\\n    function decimals() public view returns (uint8) {\\n        return tokenDecimals;\\n    }\\n\\n\\n    function totalSupply() public view returns (uint256) {\\n        return tokenTotalSupply;\\n    }\\n\\n\\n    function balanceOf(address _owner) public view returns (uint256) {\\n        return balances[_owner];\\n    }\\n\\n\\n    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {\\n        return allowed[_owner][_spender];\\n    }\\n\\n\\n    function transfer(address _to, uint256 _value) public returns (bool success) {\\n        // According to the EIP20 spec, \\\u0022transfers of 0 values MUST be treated as normal\\n        // transfers and fire the Transfer event\\\u0022.\\n        // Also, should throw if not enough balance. This is taken care of by SafeMath.\\n        balances[msg.sender] = balances[msg.sender].sub(_value);\\n        balances[_to] = balances[_to].add(_value);\\n\\n        Transfer(msg.sender, _to, _value);\\n\\n        return true;\\n    }\\n\\n\\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {\\n        balances[_from] = balances[_from].sub(_value);\\n        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\\n        balances[_to] = balances[_to].add(_value);\\n\\n        Transfer(_from, _to, _value);\\n\\n        return true;\\n    }\\n\\n\\n    function approve(address _spender, uint256 _value) public returns (bool success) {\\n\\n        allowed[msg.sender][_spender] = _value;\\n\\n        Approval(msg.sender, _spender, _value);\\n\\n        return true;\\n    }\\n\\n}\\n\u0022},\u0022OpsManaged.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.17;\\n\\n// ----------------------------------------------------------------------------\\n// Admin / Ops Permission Model\\n//\\n// Copyright (c) 2017 OpenST Ltd.\\n// https://simpletoken.org/\\n//\\n// The MIT Licence.\\n// ----------------------------------------------------------------------------\\n\\n\\nimport \\\u0022./Owned.sol\\\u0022;\\n\\n\\n//\\n// Implements a more advanced ownership and permission model based on owner,\\n// admin and ops per Simple Token key management specification.\\n//\\ncontract OpsManaged is Owned {\\n\\n    address public opsAddress;\\n    address public adminAddress;\\n\\n    event AdminAddressChanged(address indexed _newAddress);\\n    event OpsAddressChanged(address indexed _newAddress);\\n\\n\\n    function OpsManaged() public\\n        Owned()\\n    {\\n    }\\n\\n\\n    modifier onlyAdmin() {\\n        require(isAdmin(msg.sender));\\n        _;\\n    }\\n\\n\\n    modifier onlyAdminOrOps() {\\n        require(isAdmin(msg.sender) || isOps(msg.sender));\\n        _;\\n    }\\n\\n\\n    modifier onlyOwnerOrAdmin() {\\n        require(isOwner(msg.sender) || isAdmin(msg.sender));\\n        _;\\n    }\\n\\n\\n    modifier onlyOps() {\\n        require(isOps(msg.sender));\\n        _;\\n    }\\n\\n\\n    function isAdmin(address _address) internal view returns (bool) {\\n        return (adminAddress != address(0) \\u0026\\u0026 _address == adminAddress);\\n    }\\n\\n\\n    function isOps(address _address) internal view returns (bool) {\\n        return (opsAddress != address(0) \\u0026\\u0026 _address == opsAddress);\\n    }\\n\\n\\n    function isOwnerOrOps(address _address) internal view returns (bool) {\\n        return (isOwner(_address) || isOps(_address));\\n    }\\n\\n\\n    // Owner and Admin can change the admin address. Address can also be set to 0 to \\u0027disable\\u0027 it.\\n    function setAdminAddress(address _adminAddress) external onlyOwnerOrAdmin returns (bool) {\\n        require(_adminAddress != owner);\\n        require(_adminAddress != address(this));\\n        require(!isOps(_adminAddress));\\n\\n        adminAddress = _adminAddress;\\n\\n        AdminAddressChanged(_adminAddress);\\n\\n        return true;\\n    }\\n\\n\\n    // Owner and Admin can change the operations address. Address can also be set to 0 to \\u0027disable\\u0027 it.\\n    function setOpsAddress(address _opsAddress) external onlyOwnerOrAdmin returns (bool) {\\n        require(_opsAddress != owner);\\n        require(_opsAddress != address(this));\\n        require(!isAdmin(_opsAddress));\\n\\n        opsAddress = _opsAddress;\\n\\n        OpsAddressChanged(_opsAddress);\\n\\n        return true;\\n    }\\n}\\n\\n\\n\u0022},\u0022Owned.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.17;\\n\\n// ----------------------------------------------------------------------------\\n// Basic Ownership Implementation\\n//\\n// Copyright (c) 2017 OpenST Ltd.\\n// https://simpletoken.org/\\n//\\n// The MIT Licence.\\n// ----------------------------------------------------------------------------\\n\\n\\n//\\n// Implements basic ownership with 2-step transfers.\\n//\\ncontract Owned {\\n\\n    address public owner;\\n    address public proposedOwner;\\n\\n    event OwnershipTransferInitiated(address indexed _proposedOwner);\\n    event OwnershipTransferCompleted(address indexed _newOwner);\\n\\n\\n    function Owned() public {\\n        owner = msg.sender;\\n    }\\n\\n\\n    modifier onlyOwner() {\\n        require(isOwner(msg.sender));\\n        _;\\n    }\\n\\n\\n    function isOwner(address _address) internal view returns (bool) {\\n        return (_address == owner);\\n    }\\n\\n\\n    function initiateOwnershipTransfer(address _proposedOwner) public onlyOwner returns (bool) {\\n        proposedOwner = _proposedOwner;\\n\\n        OwnershipTransferInitiated(_proposedOwner);\\n\\n        return true;\\n    }\\n\\n\\n    function completeOwnershipTransfer() public returns (bool) {\\n        require(msg.sender == proposedOwner);\\n\\n        owner = proposedOwner;\\n        proposedOwner = address(0);\\n\\n        OwnershipTransferCompleted(owner);\\n\\n        return true;\\n    }\\n}\\n\\n\\n\u0022},\u0022SafeMath.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.17;\\n\\n// ----------------------------------------------------------------------------\\n// SafeMath Library Implementation\\n//\\n// Copyright (c) 2017 OpenST Ltd.\\n// https://simpletoken.org/\\n//\\n// The MIT Licence.\\n//\\n// Based on the SafeMath library by the OpenZeppelin team.\\n// Copyright (c) 2016 Smart Contract Solutions, Inc.\\n// https://github.com/OpenZeppelin/zeppelin-solidity\\n// The MIT License.\\n// ----------------------------------------------------------------------------\\n\\n\\nlibrary SafeMath {\\n\\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\\n        uint256 c = a * b;\\n\\n        assert(a == 0 || c / a == b);\\n\\n        return c;\\n    }\\n\\n\\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\\n        // Solidity automatically throws when dividing by 0\\n        uint256 c = a / b;\\n\\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\\u0027t hold\\n        return c;\\n    }\\n\\n\\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\\n        assert(b \\u003c= a);\\n\\n        return a - b;\\n    }\\n\\n\\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\\n        uint256 c = a \u002B b;\\n\\n        assert(c \\u003e= a);\\n\\n        return c;\\n    }\\n}\\n\u0022},\u0022SimpleToken.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.17;\\n\\n// ----------------------------------------------------------------------------\\n// Simple Token Contract\\n//\\n// Copyright (c) 2017 OpenST Ltd.\\n// https://simpletoken.org/\\n//\\n// The MIT Licence.\\n// ----------------------------------------------------------------------------\\n\\n\\nimport \\\u0022./ERC20Token.sol\\\u0022;\\nimport \\\u0022./SimpleTokenConfig.sol\\\u0022;\\nimport \\\u0022./OpsManaged.sol\\\u0022;\\n\\n\\n//\\n// SimpleToken is a standard ERC20 token with some additional functionality:\\n// - It has a concept of finalize\\n// - Before finalize, nobody can transfer tokens except:\\n//     - Owner and operations can transfer tokens\\n//     - Anybody can send back tokens to owner\\n// - After finalize, no restrictions on token transfers\\n//\\n\\n//\\n// Permissions, according to the ST key management specification.\\n//\\n//                                    Owner    Admin   Ops\\n// transfer (before finalize)           x               x\\n// transferForm (before finalize)       x               x\\n// finalize                                      x\\n//\\n\\ncontract SimpleToken is ERC20Token, OpsManaged, SimpleTokenConfig {\\n\\n    bool public finalized;\\n\\n\\n    // Events\\n    event Burnt(address indexed _from, uint256 _amount);\\n    event Finalized();\\n\\n\\n    function SimpleToken() public\\n        ERC20Token(TOKEN_SYMBOL, TOKEN_NAME, TOKEN_DECIMALS, TOKENS_MAX)\\n        OpsManaged()\\n    {\\n        finalized = false;\\n    }\\n\\n\\n    // Implementation of the standard transfer method that takes into account the finalize flag.\\n    function transfer(address _to, uint256 _value) public returns (bool success) {\\n        checkTransferAllowed(msg.sender, _to);\\n\\n        return super.transfer(_to, _value);\\n    }\\n\\n\\n    // Implementation of the standard transferFrom method that takes into account the finalize flag.\\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {\\n        checkTransferAllowed(msg.sender, _to);\\n\\n        return super.transferFrom(_from, _to, _value);\\n    }\\n\\n\\n    function checkTransferAllowed(address _sender, address _to) private view {\\n        if (finalized) {\\n            // Everybody should be ok to transfer once the token is finalized.\\n            return;\\n        }\\n\\n        // Owner and Ops are allowed to transfer tokens before the sale is finalized.\\n        // This allows the tokens to move from the TokenSale contract to a beneficiary.\\n        // We also allow someone to send tokens back to the owner. This is useful among other\\n        // cases, for the Trustee to transfer unlocked tokens back to the owner (reclaimTokens).\\n        require(isOwnerOrOps(_sender) || _to == owner);\\n    }\\n\\n    // Implement a burn function to permit msg.sender to reduce its balance\\n    // which also reduces tokenTotalSupply\\n    function burn(uint256 _value) public returns (bool success) {\\n        require(_value \\u003c= balances[msg.sender]);\\n\\n        balances[msg.sender] = balances[msg.sender].sub(_value);\\n        tokenTotalSupply = tokenTotalSupply.sub(_value);\\n\\n        Burnt(msg.sender, _value);\\n\\n        return true;\\n    }\\n\\n\\n    // Finalize method marks the point where token transfers are finally allowed for everybody.\\n    function finalize() external onlyAdmin returns (bool success) {\\n        require(!finalized);\\n\\n        finalized = true;\\n\\n        Finalized();\\n\\n        return true;\\n    }\\n}\\n\u0022},\u0022SimpleTokenConfig.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.4.17;\\n\\n// ----------------------------------------------------------------------------\\n// Token Configuration\\n//\\n// Copyright (c) 2017 OpenST Ltd.\\n// https://simpletoken.org/\\n//\\n// The MIT Licence.\\n// ----------------------------------------------------------------------------\\n// ----------------------------------------------------------------------------\\n// Portions are:\\n// Copyright (c) 2018 Bixer Pte.Ltd.\\n// The MIT Licence.\\n// ----------------------------------------------------------------------------\\n\\n\\ncontract SimpleTokenConfig {\\n\\n    string  public constant TOKEN_SYMBOL   = \\\u0022TOC\\\u0022;\\n    string  public constant TOKEN_NAME     = \\\u0022TokenChat\\\u0022;\\n    uint8   public constant TOKEN_DECIMALS = 6;\\n\\n    uint256 public constant DECIMALSFACTOR = 10**uint256(TOKEN_DECIMALS);\\n    uint256 public constant TOKENS_MAX     = 1200000000 * DECIMALSFACTOR;\\n}\\n\u0022}}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKEN_NAME\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKEN_SYMBOL\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_adminAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setAdminAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022finalize\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKEN_DECIMALS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_opsAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setOpsAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022DECIMALSFACTOR\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022opsAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOKENS_MAX\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022finalized\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_proposedOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022initiateOwnershipTransfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022proposedOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022completeOwnershipTransfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022adminAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burnt\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Finalized\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_newAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022AdminAddressChanged\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_newAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OpsAddressChanged\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_proposedOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferInitiated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferCompleted\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"SimpleToken","CompilerVersion":"v0.4.18\u002Bcommit.9cf6e910","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://49661cee51378e5de480f9d7708d3ec6a0ca15194967d4b5b1d48e7c451e359b"}]