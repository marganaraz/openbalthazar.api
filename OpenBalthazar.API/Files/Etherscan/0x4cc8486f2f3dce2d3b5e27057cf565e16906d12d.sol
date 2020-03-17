[{"SourceCode":"{\u0022ECDSA.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.9;\\n/** \\nThe MIT License (MIT)\\n\\nCopyright (c) 2016-2019 zOS Global Limited\\n\\nPermission is hereby granted, free of charge, to any person obtaining\\na copy of this software and associated documentation files (the\\n\\\u0022Software\\\u0022), to deal in the Software without restriction, including\\nwithout limitation the rights to use, copy, modify, merge, publish,\\ndistribute, sublicense, and/or sell copies of the Software, and to\\npermit persons to whom the Software is furnished to do so, subject to\\nthe following conditions:\\n\\nThe above copyright notice and this permission notice shall be included\\nin all copies or substantial portions of the Software.\\n\\nTHE SOFTWARE IS PROVIDED \\\u0022AS IS\\\u0022, WITHOUT WARRANTY OF ANY KIND, EXPRESS\\nOR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF\\nMERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.\\nIN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY\\nCLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,\\nTORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE\\nSOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\\n*/\\n\\n/**\\n * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.\\n *\\n * These functions can be used to verify that a message was signed by the holder\\n * of the private keys of a given address.\\n */\\nlibrary ECDSA {\\n    /**\\n     * @dev Returns the address that signed a hashed message (\u0060hash\u0060) with\\n     * \u0060signature\u0060. This address can then be used for verification purposes.\\n     *\\n     * The \u0060ecrecover\u0060 EVM opcode allows for malleable (non-unique) signatures:\\n     * this function rejects them by requiring the \u0060s\u0060 value to be in the lower\\n     * half order, and the \u0060v\u0060 value to be either 27 or 28.\\n     *\\n     * (.note) This call _does not revert_ if the signature is invalid, or\\n     * if the signer is otherwise unable to be retrieved. In those scenarios,\\n     * the zero address is returned.\\n     *\\n     * (.warning) \u0060hash\u0060 _must_ be the result of a hash operation for the\\n     * verification to be secure: it is possible to craft signatures that\\n     * recover to arbitrary addresses for non-hashed data. A safe way to ensure\\n     * this is by receiving a hash of the original message (which may otherwise)\\n     * be too long), and then calling \u0060toEthSignedMessageHash\u0060 on it.\\n     */\\n    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {\\n        // Check the signature length\\n        if (signature.length != 65) {\\n            return (address(0));\\n        }\\n\\n        // Divide the signature in r, s and v variables\\n        bytes32 r;\\n        bytes32 s;\\n        uint8 v;\\n\\n        // ecrecover takes the signature parameters, and the only way to get them\\n        // currently is to use assembly.\\n        // solhint-disable-next-line no-inline-assembly\\n        assembly {\\n            r := mload(add(signature, 0x20))\\n            s := mload(add(signature, 0x40))\\n            v := byte(0, mload(add(signature, 0x60)))\\n        }\\n\\n        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature\\n        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines\\n        // the valid range for s in (281): 0 \\u003c s \\u003c secp256k1n \u00F7 2 \u002B 1, and for v in (282): v \u2208 {27, 28}. Most\\n        // signatures from current libraries generate a unique signature with an s-value in the lower half order.\\n        //\\n        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value\\n        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or\\n        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept\\n        // these malleable signatures as well.\\n        if (uint256(s) \\u003e 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {\\n            return address(0);\\n        }\\n\\n        if (v != 27 \\u0026\\u0026 v != 28) {\\n            return address(0);\\n        }\\n\\n        // If the signature is valid (and not malleable), return the signer address\\n        return ecrecover(hash, v, r, s);\\n    }\\n\\n    /**\\n     * @dev Returns an Ethereum Signed Message, created from a \u0060hash\u0060. This\\n     * replicates the behavior of the\\n     * [\u0060eth_sign\u0060](https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign)\\n     * JSON-RPC method.\\n     *\\n     * See \u0060recover\u0060.\\n     */\\n    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {\\n        // 32 is the length in bytes of hash,\\n        // enforced by the type signature above\\n        return keccak256(abi.encodePacked(\\\u0022\\\\x19Ethereum Signed Message:\\\\n32\\\u0022, hash));\\n    }\\n}\u0022},\u0022Gluwacoin.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.9;\\n\\n\\nimport \\\u0022./SafeMath.sol\\\u0022;\\nimport \\\u0022./ECDSA.sol\\\u0022;\\n\\ncontract Erc20\\n{   \\n    function totalSupply() public view returns (uint256 amount);\\n    function balanceOf(address _tokenOwner) public view returns (uint256 balance);\\n    function transfer(address _to, uint256 _value) public returns (bool success);\\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);\\n    function approve(address _spender, uint256 _value) public returns (bool success);\\n    function allowance(address _tokenOwner, address _spender) public view returns (uint256 remaining);\\n    \\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\\n}\\n\\n\\ncontract Erc20Plus is Erc20\\n{\\n    function burn(uint256 _value) public returns (bool success);\\n    function mint(address _to, uint256 _value) public returns (bool success);\\n\\n    event Mint(address indexed _mintTo, uint256 _value);\\n    event Burnt(address indexed _burnFrom, uint256 _value);\\n}\\n\\ncontract Owned\\n{\\n    address internal _owner;\\n\\n    constructor() public\\n    {\\n        _owner = msg.sender;\\n    }\\n\\n    modifier onlyOwner \\n    {\\n        require(msg.sender == _owner, \\\u0022Only contract owner can do this.\\\u0022);\\n        _;\\n    }   \\n\\n    function () external payable \\n    {\\n        require(false, \\\u0022eth transfer is disabled.\\\u0022); // throw\\n    }\\n}\\n\\n\\ncontract Gluwacoin is Erc20Plus, Owned\\n{\\n    using SafeMath for uint256;\\n    using ECDSA for bytes32;\\n\\n    string public constant name = \\\u0022KRW Gluwacoin\\\u0022;\\n    string public constant symbol = \\\u0022KRW-G\\\u0022;\\n    uint8 public constant decimals = 18;\\n\\n    mapping (address =\\u003e uint256) private _balances;\\n    mapping (address =\\u003e mapping (address =\\u003e uint256)) private _allowed;\\n    uint256 private _totalSupply;\\n\\n    enum ReservationStatus\\n    {\\n        Inactive,\\n        Active,\\n        Expired,\\n        Reclaimed,\\n        Completed\\n    }\\n\\n    struct Reservation\\n    {\\n        uint256 _amount;\\n        uint256 _fee;\\n        address _recipient;\\n        address _executor;\\n        uint256 _expiryBlockNum;\\n        ReservationStatus _status;\\n    }\\n\\n    // Address mapping to mapping of nonce to amount and expiry for that nonce.\\n    mapping (address =\\u003e mapping(uint256 =\\u003e Reservation)) private _reserved;\\n\\n    // Total amount of reserved balance for address\\n    mapping (address =\\u003e uint256) private _totalReserved;\\n\\n    mapping (address =\\u003e mapping (uint256 =\\u003e bool)) _usedNonces;\\n\\n    event NonceUsed(address indexed _user, uint256 _nonce);\\n\\n    function totalSupply() public view returns (uint256 amount)\\n    {\\n        return _totalSupply;\\n    }\\n\\n    /**\\n        Returns balance of token owner minus reserved amount.\\n     */\\n    function balanceOf(address _tokenOwner) public view returns (uint256 balance)\\n    {\\n        return _balances[_tokenOwner].subtract(_totalReserved[_tokenOwner]);\\n    }\\n\\n    /**\\n        Returns the total amount of tokens for token owner.\\n     */\\n    function totalBalanceOf(address _tokenOwner) public view returns (uint256 balance)\\n    {\\n        return _balances[_tokenOwner];\\n    }\\n\\n    function getReservation(address _tokenOwner, uint256 _nonce) public view returns (uint256 _amount, uint256 _fee, address _recipient, address _executor, uint256 _expiryBlockNum, ReservationStatus _status)\\n    {\\n        Reservation memory _reservation = _reserved[_tokenOwner][_nonce];\\n\\n        _amount = _reservation._amount;\\n        _fee = _reservation._fee;\\n        _recipient = _reservation._recipient;\\n        _executor = _reservation._executor;\\n        _expiryBlockNum = _reservation._expiryBlockNum;\\n\\n        if (_reservation._status == ReservationStatus.Active \\u0026\\u0026 _reservation._expiryBlockNum \\u003c= block.number)\\n        {\\n            _status = ReservationStatus.Expired;\\n        }\\n        else\\n        {\\n            _status = _reservation._status;\\n        }\\n    }\\n\\n    function transfer(address _to, uint256 _value) public returns (bool success)\\n    {\\n        require(_balances[msg.sender].subtract(_totalReserved[msg.sender]) \\u003e= _value, \\\u0022Insufficient balance for transfer\\\u0022);\\n        require(_to != address(0), \\\u0022Can not transfer to zero address\\\u0022);\\n\\n        _balances[msg.sender] = _balances[msg.sender].subtract(_value);\\n        _balances[_to] = _balances[_to].add(_value);\\n\\n        emit Transfer(msg.sender, _to, _value);\\n\\n        return true;\\n    }\\n\\n    function transfer(address _from, address _to, uint256 _value, uint256 _fee, uint256 _nonce, bytes memory _sig) public returns (bool success)\\n    {\\n        require(_to != address(0), \\\u0022Can not transfer to zero address\\\u0022);\\n\\n        uint256 _valuePlusFee = _value.add(_fee);\\n        require(_balances[_from].subtract(_totalReserved[_from]) \\u003e= _valuePlusFee, \\\u0022Insufficient balance for transfer\\\u0022);\\n        \\n\\n        bytes32 hash = keccak256(abi.encodePacked(address(this), _from, _to, _value, _fee, _nonce));\\n        validateSignature(hash, _from, _nonce, _sig);\\n\\n        _balances[_from] = _balances[_from].subtract(_valuePlusFee);\\n        _balances[_to] = _balances[_to].add(_value);\\n        _totalSupply = _totalSupply.subtract(_fee);\\n\\n        emit Transfer(_from, _to, _value);\\n        emit Transfer(_from, address(0), _fee);\\n        emit Burnt(_from, _fee);\\n\\n        return true;\\n    }\\n\\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)\\n    {\\n        require(_balances[_from].subtract(_totalReserved[_from]) \\u003e= _value, \\\u0022Insufficient balance for transfer\\\u0022);\\n        require(_allowed[_from][msg.sender] \\u003e= _value, \\\u0022Allowance exceeded\\\u0022);\\n        require(_to != address(0), \\\u0022Can not transfer to zero address\\\u0022);\\n\\n        _balances[_from] = _balances[_from].subtract(_value);\\n        _allowed[_from][msg.sender] = _allowed[_from][msg.sender].subtract(_value);\\n        _balances[_to] = _balances[_to].add(_value);\\n\\n        emit Transfer(_from, _to, _value);\\n\\n        return true;\\n    }\\n\\n    function approve(address _spender, uint256 _value) public returns (bool success)\\n    {\\n        require(_spender != address(0), \\\u0022Invalid spender address\\\u0022);\\n\\n        _allowed[msg.sender][_spender] = _value;\\n        emit Approval(msg.sender, _spender, _value);\\n        \\n        return true;\\n    }\\n\\n    function allowance(address _tokenOwner, address _spender) public view returns (uint256 remaining)\\n    {\\n        return _allowed[_tokenOwner][_spender];\\n    }\\n\\n    function burn(uint256 _value) public onlyOwner returns (bool success)\\n    {\\n        require(_balances[msg.sender].subtract(_totalReserved[msg.sender]) \\u003e= _value, \\\u0022Insufficient balance for burn\\\u0022);\\n\\n        _balances[msg.sender] = _balances[msg.sender].subtract(_value);\\n        _totalSupply = _totalSupply.subtract(_value);\\n\\n        emit Transfer(msg.sender, address(0), _value);\\n        emit Burnt(msg.sender, _value);\\n\\n        return true;\\n    }\\n\\n    function mint(address _to, uint256 _value) public onlyOwner returns (bool success)\\n    {\\n        require(_to != address(0), \\\u0022Can not mint to zero address\\\u0022);\\n\\n        _balances[_to] = _balances[_to].add(_value);\\n        _totalSupply = _totalSupply.add(_value);\\n\\n        emit Transfer(address(0), _owner, _value);\\n        emit Transfer(_owner, _to, _value);\\n        emit Mint(_to, _value);\\n\\n        return true;\\n    }\\n\\n    function reserve(address _from, address _to, address _executor, uint256 _amount, uint256 _fee, uint256 _nonce, uint256 _expiryBlockNum, bytes memory _sig) public returns (bool success)\\n    {\\n        require(_expiryBlockNum \\u003e block.number, \\\u0022Invalid block expiry number\\\u0022);\\n        require(_amount \\u003e 0, \\\u0022Invalid reserve amount\\\u0022);\\n        require(_from != address(0), \\\u0022Can\\u0027t reserve from zero address\\\u0022);\\n        require(_to != address(0), \\\u0022Can\\u0027t reserve to zero address\\\u0022);\\n        require(_executor != address(0), \\\u0022Can\\u0027t execute from zero address\\\u0022);\\n\\n        uint256 _amountPlusFee = _amount.add(_fee);\\n        require(_balances[_from].subtract(_totalReserved[_from]) \\u003e= _amountPlusFee, \\\u0022Insufficient funds to create reservation\\\u0022);\\n\\n        bytes32 hash = keccak256(abi.encodePacked(address(this), _from, _to, _executor, _amount, _fee, _nonce, _expiryBlockNum));\\n        validateSignature(hash, _from, _nonce, _sig);\\n\\n        _reserved[_from][_nonce] = Reservation(_amount, _fee, _to, _executor, _expiryBlockNum, ReservationStatus.Active);\\n        _totalReserved[_from] = _totalReserved[_from].add(_amountPlusFee);\\n\\n        return true;\\n    }\\n\\n    function execute(address _sender, uint256 _nonce) public returns (bool success)\\n    {\\n        Reservation storage _reservation = _reserved[_sender][_nonce];\\n\\n        require(_reservation._status == ReservationStatus.Active, \\\u0022Invalid reservation to execute\\\u0022);\\n        require(_reservation._expiryBlockNum \\u003e block.number, \\\u0022Reservation has expired and can not be executed\\\u0022);\\n        require(_reservation._executor == msg.sender, \\\u0022This address is not authorized to execute this reservation\\\u0022);\\n\\n        uint256 _amountPlusFee = _reservation._amount.add(_reservation._fee);\\n\\n        _balances[_sender] = _balances[_sender].subtract(_amountPlusFee);\\n        _balances[_reservation._recipient] = _balances[_reservation._recipient].add(_reservation._amount);\\n        _totalSupply = _totalSupply.subtract(_reservation._fee);\\n\\n        emit Transfer(_sender, _reservation._recipient, _reservation._amount);\\n        emit Transfer(_sender, address(0), _reservation._fee);\\n        emit Burnt(_sender, _reservation._fee);\\n\\n        _reserved[_sender][_nonce]._status = ReservationStatus.Completed;\\n        _totalReserved[_sender] = _totalReserved[_sender].subtract(_amountPlusFee);\\n\\n        return true;\\n    }\\n\\n    function reclaim(address _sender, uint256 _nonce) public returns (bool success)\\n    {\\n        Reservation storage _reservation = _reserved[_sender][_nonce];\\n        require(_reservation._status == ReservationStatus.Active, \\\u0022Invalid reservation status\\\u0022);\\n\\n        if (msg.sender != _owner)\\n        {\\n            require(msg.sender == _sender, \\\u0022Can not reclaim another user\\u0027s reservation for them\\\u0022);\\n            require(_reservation._expiryBlockNum \\u003c= block.number, \\\u0022Reservation has not expired yet\\\u0022);\\n        }\\n\\n        _reserved[_sender][_nonce]._status = ReservationStatus.Reclaimed;\\n        _totalReserved[_sender] = _totalReserved[_sender].subtract(_reservation._amount).subtract(_reservation._fee);\\n\\n        return true;\\n    }\\n\\n    function validateSignature(bytes32 _hash, address _from, uint256 _nonce, bytes memory _sig) internal\\n    {\\n        bytes32 messageHash = _hash.toEthSignedMessageHash();\\n\\n        address _signer = messageHash.recover(_sig);\\n        require(_signer == _from, \\\u0022Invalid signature\\\u0022);\\n\\n        require(!_usedNonces[_signer][_nonce], \\\u0022Nonce has already been used for this address\\\u0022);\\n        _usedNonces[_signer][_nonce] = true;\\n\\n        emit NonceUsed(_signer, _nonce);\\n    }\\n}\u0022},\u0022SafeMath.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.9;\\n/**\\nThe MIT License (MIT)\\n\\nCopyright (c) 2016 Smart Contract Solutions, Inc.\\n\\nPermission is hereby granted, free of charge, to any person obtaining\\na copy of this software and associated documentation files (the\\n\\\u0022Software\\\u0022), to deal in the Software without restriction, including\\nwithout limitation the rights to use, copy, modify, merge, publish,\\ndistribute, sublicense, and/or sell copies of the Software, and to\\npermit persons to whom the Software is furnished to do so, subject to\\nthe following conditions:\\n\\nThe above copyright notice and this permission notice shall be included\\nin all copies or substantial portions of the Software.\\n\\nTHE SOFTWARE IS PROVIDED \\\u0022AS IS\\\u0022, WITHOUT WARRANTY OF ANY KIND, EXPRESS\\nOR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF\\nMERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.\\nIN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY\\nCLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,\\nTORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE\\nSOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\\n */\\n\\n\\n/**\\n * @title SafeMath\\n * @dev Math operations with safety checks that revert on error\\n */\\nlibrary SafeMath {\\n\\n    /**\\n    * @dev Multiplies two numbers, reverts on overflow.\\n    */\\n    function multiply(uint256 a, uint256 b) internal pure returns (uint256)\\n    {\\n        // Gas optimization: this is cheaper than requiring \\u0027a\\u0027 not being zero, but the\\n        // benefit is lost if \\u0027b\\u0027 is also tested.\\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\\n        if (a == 0)\\n        {\\n            return 0;\\n        }\\n\\n        uint256 c = a * b;\\n        require(c / a == b, \\\u0022Multiplication overflow\\\u0022);\\n\\n        return c;\\n    }\\n\\n    /**\\n    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.\\n    */\\n    function divide(uint256 a, uint256 b) internal pure returns (uint256)\\n    {\\n        require(b \\u003e 0, \\\u0022Division by zero\\\u0022); // Solidity only automatically asserts when dividing by 0\\n        uint256 c = a / b;\\n\\n        return c;\\n    }\\n\\n    /**\\n    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).\\n    */\\n    function subtract(uint256 a, uint256 b) internal pure returns (uint256)\\n    {\\n        require(b \\u003c= a, \\\u0022Subtraction underflow\\\u0022);\\n        uint256 c = a - b;\\n\\n        return c;\\n    }\\n\\n    /**\\n    * @dev Adds two numbers, reverts on overflow.\\n    */\\n    function add(uint256 a, uint256 b) internal pure returns (uint256)\\n    {\\n        uint256 c = a \u002B b;\\n        require(c \\u003e= a, \\\u0022Addition overflow\\\u0022);\\n\\n        return c;\\n    }\\n}\u0022}}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_fee\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_nonce\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_sig\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_nonce\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022execute\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022mint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022totalBalanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_executor\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_fee\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_nonce\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_expiryBlockNum\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_sig\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022reserve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_nonce\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022reclaim\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_nonce\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getReservation\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_fee\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_executor\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_expiryBlockNum\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_status\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_nonce\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022NonceUsed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_mintTo\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Mint\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_burnFrom\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burnt\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Gluwacoin","CompilerVersion":"v0.5.9\u002Bcommit.e560f70d","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://9f250d70f64439099d8242981612285bef6b1f5695ca46c3a47ddbfcedf4130a"}]