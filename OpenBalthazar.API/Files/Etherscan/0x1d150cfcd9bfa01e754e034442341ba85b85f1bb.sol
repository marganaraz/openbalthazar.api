[{"SourceCode":"pragma solidity ^0.4.21;\r\n\r\ninterface ExchangeInterface {\r\n\r\n    event Subscribed(address indexed user);\r\n    event Unsubscribed(address indexed user);\r\n\r\n    event Cancelled(bytes32 indexed hash);\r\n\r\n    event Traded(\r\n        bytes32 indexed hash,\r\n        address makerToken,\r\n        uint makerTokenAmount,\r\n        address takerToken,\r\n        uint takerTokenAmount,\r\n        address maker,\r\n        address taker\r\n    );\r\n\r\n    event Ordered(\r\n        address maker,\r\n        address makerToken,\r\n        address takerToken,\r\n        uint makerTokenAmount,\r\n        uint takerTokenAmount,\r\n        uint expires,\r\n        uint nonce\r\n    );\r\n\r\n    function subscribe() external;\r\n    function unsubscribe() external;\r\n\r\n    function trade(address[3] addresses, uint[4] values, bytes signature, uint maxFillAmount) external;\r\n    function cancel(address[3] addresses, uint[4] values) external;\r\n    function order(address[2] addresses, uint[4] values) external;\r\n\r\n    function canTrade(address[3] addresses, uint[4] values, bytes signature)\r\n        external\r\n        view\r\n        returns (bool);\r\n\r\n    function isSubscribed(address subscriber) external view returns (bool);\r\n    function availableAmount(address[3] addresses, uint[4] values) external view returns (uint);\r\n    function filled(bytes32 hash) external view returns (uint);\r\n    function isOrdered(address user, bytes32 hash) public view returns (bool);\r\n    function vault() public view returns (VaultInterface);\r\n\r\n}\r\n\r\ninterface VaultInterface {\r\n\r\n    event Deposited(address indexed user, address token, uint amount);\r\n    event Withdrawn(address indexed user, address token, uint amount);\r\n\r\n    event Approved(address indexed user, address indexed spender);\r\n    event Unapproved(address indexed user, address indexed spender);\r\n\r\n    event AddedSpender(address indexed spender);\r\n    event RemovedSpender(address indexed spender);\r\n\r\n    function deposit(address token, uint amount) external payable;\r\n    function withdraw(address token, uint amount) external;\r\n    function transfer(address token, address from, address to, uint amount) external;\r\n    function approve(address spender) external;\r\n    function unapprove(address spender) external;\r\n    function isApproved(address user, address spender) external view returns (bool);\r\n    function addSpender(address spender) external;\r\n    function removeSpender(address spender) external;\r\n    function latestSpender() external view returns (address);\r\n    function isSpender(address spender) external view returns (bool);\r\n    function tokenFallback(address from, uint value, bytes data) public;\r\n    function balanceOf(address token, address user) public view returns (uint);\r\n\r\n}\r\n\r\nlibrary SafeMath {\r\n\r\n    function mul(uint a, uint b) internal pure returns (uint) {\r\n        uint c = a * b;\r\n        assert(a == 0 || c / a == b);\r\n        return c;\r\n    }\r\n\r\n    function div(uint a, uint b) internal pure returns (uint) {\r\n        assert(b \u003E 0);\r\n        uint c = a / b;\r\n        assert(a == b * c \u002B a % b);\r\n        return c;\r\n    }\r\n\r\n    function sub(uint a, uint b) internal pure returns (uint) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    function add(uint a, uint b) internal pure returns (uint) {\r\n        uint c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n\r\n    function max64(uint64 a, uint64 b) internal pure returns (uint64) {\r\n        return a \u003E= b ? a : b;\r\n    }\r\n\r\n    function min64(uint64 a, uint64 b) internal pure returns (uint64) {\r\n        return a \u003C b ? a : b;\r\n    }\r\n\r\n    function max256(uint a, uint b) internal pure returns (uint) {\r\n        return a \u003E= b ? a : b;\r\n    }\r\n\r\n    function min256(uint a, uint b) internal pure returns (uint) {\r\n        return a \u003C b ? a : b;\r\n    }\r\n}\r\n\r\nlibrary SignatureValidator {\r\n\r\n    enum SignatureMode {\r\n        EIP712,\r\n        GETH,\r\n        TREZOR\r\n    }\r\n\r\n    /// @dev Validates that a hash was signed by a specified signer.\r\n    /// @param hash Hash which was signed.\r\n    /// @param signer Address of the signer.\r\n    /// @param signature ECDSA signature along with the mode (0 = EIP712, 1 = Geth, 2 = Trezor) {mode}{v}{r}{s}.\r\n    /// @return Returns whether signature is from a specified user.\r\n    function isValidSignature(bytes32 hash, address signer, bytes signature) internal pure returns (bool) {\r\n        require(signature.length == 66);\r\n        SignatureMode mode = SignatureMode(uint8(signature[0]));\r\n\r\n        uint8 v = uint8(signature[1]);\r\n        bytes32 r;\r\n        bytes32 s;\r\n        assembly {\r\n            r := mload(add(signature, 34))\r\n            s := mload(add(signature, 66))\r\n        }\r\n\r\n        if (mode == SignatureMode.GETH) {\r\n            hash = keccak256(\u0022\\x19Ethereum Signed Message:\\n32\u0022, hash);\r\n        } else if (mode == SignatureMode.TREZOR) {\r\n            hash = keccak256(\u0022\\x19Ethereum Signed Message:\\n\\x20\u0022, hash);\r\n        }\r\n\r\n        return ecrecover(hash, v, r, s) == signer;\r\n    }\r\n}\r\n\r\nlibrary OrderLibrary {\r\n\r\n    bytes32 constant public HASH_SCHEME = keccak256(\r\n        \u0022address Taker Token\u0022,\r\n        \u0022uint Taker Token Amount\u0022,\r\n        \u0022address Maker Token\u0022,\r\n        \u0022uint Maker Token Amount\u0022,\r\n        \u0022uint Expires\u0022,\r\n        \u0022uint Nonce\u0022,\r\n        \u0022address Maker\u0022,\r\n        \u0022address Exchange\u0022\r\n    );\r\n\r\n    struct Order {\r\n        address maker;\r\n        address makerToken;\r\n        address takerToken;\r\n        uint makerTokenAmount;\r\n        uint takerTokenAmount;\r\n        uint expires;\r\n        uint nonce;\r\n    }\r\n\r\n    /// @dev Hashes the order.\r\n    /// @param order Order to be hashed.\r\n    /// @return hash result\r\n    function hash(Order memory order) internal view returns (bytes32) {\r\n        return keccak256(\r\n            HASH_SCHEME,\r\n            keccak256(\r\n                order.takerToken,\r\n                order.takerTokenAmount,\r\n                order.makerToken,\r\n                order.makerTokenAmount,\r\n                order.expires,\r\n                order.nonce,\r\n                order.maker,\r\n                this\r\n            )\r\n        );\r\n    }\r\n\r\n    /// @dev Creates order struct from value arrays.\r\n    /// @param addresses Array of trade\u0027s maker, makerToken and takerToken.\r\n    /// @param values Array of trade\u0027s makerTokenAmount, takerTokenAmount, expires and nonce.\r\n    /// @return Order struct\r\n    function createOrder(address[3] addresses, uint[4] values) internal pure returns (Order memory) {\r\n        return Order({\r\n            maker: addresses[0],\r\n            makerToken: addresses[1],\r\n            takerToken: addresses[2],\r\n            makerTokenAmount: values[0],\r\n            takerTokenAmount: values[1],\r\n            expires: values[2],\r\n            nonce: values[3]\r\n        });\r\n    }\r\n}\r\n\r\ncontract Ownable {\r\n\r\n    address public owner;\r\n\r\n    modifier onlyOwner {\r\n        require(isOwner(msg.sender));\r\n        _;\r\n    }\r\n\r\n    function Ownable() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    function transferOwnership(address _newOwner) public onlyOwner {\r\n        owner = _newOwner;\r\n    }\r\n\r\n    function isOwner(address _address) public view returns (bool) {\r\n        return owner == _address;\r\n    }\r\n}\r\n\r\ninterface ERC20 {\r\n\r\n    function totalSupply() public view returns (uint);\r\n    function balanceOf(address owner) public view returns (uint);\r\n    function allowance(address owner, address spender) public view returns (uint);\r\n    function transfer(address to, uint value) public returns (bool);\r\n    function transferFrom(address from, address to, uint value) public returns (bool);\r\n    function approve(address spender, uint value) public returns (bool);\r\n\r\n}\r\n\r\ninterface HookSubscriber {\r\n\r\n    function tradeExecuted(address token, uint amount) external;\r\n\r\n}\r\n\r\ncontract Exchange is Ownable, ExchangeInterface {\r\n\r\n    using SafeMath for *;\r\n    using OrderLibrary for OrderLibrary.Order;\r\n\r\n    address constant public ETH = 0x0;\r\n\r\n    uint256 constant public MAX_FEE = 5000000000000000; // 0.5% ((0.5 / 100) * 10**18)\r\n    uint256 constant private MAX_ROUNDING_PERCENTAGE = 1000; // 0.1%\r\n    \r\n    uint256 constant private MAX_HOOK_GAS = 40000; // enough for a storage write and some accounting logic\r\n\r\n    VaultInterface public vault;\r\n\r\n    uint public takerFee = 0;\r\n    address public feeAccount;\r\n\r\n    mapping (address =\u003E mapping (bytes32 =\u003E bool)) private orders;\r\n    mapping (bytes32 =\u003E uint) private fills;\r\n    mapping (bytes32 =\u003E bool) private cancelled;\r\n    mapping (address =\u003E bool) private subscribed;\r\n\r\n    function Exchange(uint _takerFee, address _feeAccount, VaultInterface _vault) public {\r\n        require(address(_vault) != 0x0);\r\n        setFees(_takerFee);\r\n        setFeeAccount(_feeAccount);\r\n        vault = _vault;\r\n    }\r\n\r\n    /// @dev Withdraws tokens accidentally sent to this contract.\r\n    /// @param token Address of the token to withdraw.\r\n    /// @param amount Amount of tokens to withdraw.\r\n    function withdraw(address token, uint amount) external onlyOwner {\r\n        if (token == ETH) {\r\n            msg.sender.transfer(amount);\r\n            return;\r\n        }\r\n\r\n        ERC20(token).transfer(msg.sender, amount);\r\n    }\r\n\r\n    /// @dev Subscribes user to trade hooks.\r\n    function subscribe() external {\r\n        require(!subscribed[msg.sender]);\r\n        subscribed[msg.sender] = true;\r\n        emit Subscribed(msg.sender);\r\n    }\r\n\r\n    /// @dev Unsubscribes user from trade hooks.\r\n    function unsubscribe() external {\r\n        require(subscribed[msg.sender]);\r\n        subscribed[msg.sender] = false;\r\n        emit Unsubscribed(msg.sender);\r\n    }\r\n\r\n    /// @dev Takes an order.\r\n    /// @param addresses Array of trade\u0027s maker, makerToken and takerToken.\r\n    /// @param values Array of trade\u0027s makerTokenAmount, takerTokenAmount, expires and nonce.\r\n    /// @param signature Signed order along with signature mode.\r\n    /// @param maxFillAmount Maximum amount of the order to be filled.\r\n    function trade(address[3] addresses, uint[4] values, bytes signature, uint maxFillAmount) external {\r\n        trade(OrderLibrary.createOrder(addresses, values), msg.sender, signature, maxFillAmount);\r\n    }\r\n\r\n    /// @dev Cancels an order.\r\n    /// @param addresses Array of trade\u0027s maker, makerToken and takerToken.\r\n    /// @param values Array of trade\u0027s makerTokenAmount, takerTokenAmount, expires and nonce.\r\n    function cancel(address[3] addresses, uint[4] values) external {\r\n        OrderLibrary.Order memory order = OrderLibrary.createOrder(addresses, values);\r\n\r\n        require(msg.sender == order.maker);\r\n        require(order.makerTokenAmount \u003E 0 \u0026\u0026 order.takerTokenAmount \u003E 0);\r\n\r\n        bytes32 hash = order.hash();\r\n        require(fills[hash] \u003C order.takerTokenAmount);\r\n        require(!cancelled[hash]);\r\n\r\n        cancelled[hash] = true;\r\n        emit Cancelled(hash);\r\n    }\r\n\r\n    /// @dev Creates an order which is then indexed in the orderbook.\r\n    /// @param addresses Array of trade\u0027s makerToken and takerToken.\r\n    /// @param values Array of trade\u0027s makerTokenAmount, takerTokenAmount, expires and nonce.\r\n    function order(address[2] addresses, uint[4] values) external {\r\n        OrderLibrary.Order memory order = OrderLibrary.createOrder(\r\n            [msg.sender, addresses[0], addresses[1]],\r\n            values\r\n        );\r\n\r\n        require(vault.isApproved(order.maker, this));\r\n        require(vault.balanceOf(order.makerToken, order.maker) \u003E= order.makerTokenAmount);\r\n        require(order.makerToken != order.takerToken);\r\n        require(order.makerTokenAmount \u003E 0);\r\n        require(order.takerTokenAmount \u003E 0);\r\n\r\n        bytes32 hash = order.hash();\r\n\r\n        require(!orders[msg.sender][hash]);\r\n        orders[msg.sender][hash] = true;\r\n\r\n        emit Ordered(\r\n            order.maker,\r\n            order.makerToken,\r\n            order.takerToken,\r\n            order.makerTokenAmount,\r\n            order.takerTokenAmount,\r\n            order.expires,\r\n            order.nonce\r\n        );\r\n    }\r\n\r\n    /// @dev Checks if a order can be traded.\r\n    /// @param addresses Array of trade\u0027s maker, makerToken and takerToken.\r\n    /// @param values Array of trade\u0027s makerTokenAmount, takerTokenAmount, expires and nonce.\r\n    /// @param signature Signed order along with signature mode.\r\n    /// @return Boolean if order can be traded\r\n    function canTrade(address[3] addresses, uint[4] values, bytes signature)\r\n        external\r\n        view\r\n        returns (bool)\r\n    {\r\n        OrderLibrary.Order memory order = OrderLibrary.createOrder(addresses, values);\r\n\r\n        bytes32 hash = order.hash();\r\n\r\n        return canTrade(order, signature, hash);\r\n    }\r\n\r\n    /// @dev Returns if user has subscribed to trade hooks.\r\n    /// @param subscriber Address of the subscriber.\r\n    /// @return Boolean if user is subscribed.\r\n    function isSubscribed(address subscriber) external view returns (bool) {\r\n        return subscribed[subscriber];\r\n    }\r\n\r\n    /// @dev Checks how much of an order can be filled.\r\n    /// @param addresses Array of trade\u0027s maker, makerToken and takerToken.\r\n    /// @param values Array of trade\u0027s makerTokenAmount, takerTokenAmount, expires and nonce.\r\n    /// @return Amount of the order which can be filled.\r\n    function availableAmount(address[3] addresses, uint[4] values) external view returns (uint) {\r\n        OrderLibrary.Order memory order = OrderLibrary.createOrder(addresses, values);\r\n        return availableAmount(order, order.hash());\r\n    }\r\n\r\n    /// @dev Returns how much of an order was filled.\r\n    /// @param hash Hash of the order.\r\n    /// @return Amount which was filled.\r\n    function filled(bytes32 hash) external view returns (uint) {\r\n        return fills[hash];\r\n    }\r\n\r\n    /// @dev Sets the taker fee.\r\n    /// @param _takerFee New taker fee.\r\n    function setFees(uint _takerFee) public onlyOwner {\r\n        require(_takerFee \u003C= MAX_FEE);\r\n        takerFee = _takerFee;\r\n    }\r\n\r\n    /// @dev Sets the account where fees will be transferred to.\r\n    /// @param _feeAccount Address for the account.\r\n    function setFeeAccount(address _feeAccount) public onlyOwner {\r\n        require(_feeAccount != 0x0);\r\n        feeAccount = _feeAccount;\r\n    }\r\n\r\n    function vault() public view returns (VaultInterface) {\r\n        return vault;\r\n    }\r\n\r\n    /// @dev Checks if an order was created on chain.\r\n    /// @param user User who created the order.\r\n    /// @param hash Hash of the order.\r\n    /// @return Boolean if the order was created on chain.\r\n    function isOrdered(address user, bytes32 hash) public view returns (bool) {\r\n        return orders[user][hash];\r\n    }\r\n\r\n    /// @dev Executes the actual trade by transferring balances.\r\n    /// @param order Order to be traded.\r\n    /// @param taker Address of the taker.\r\n    /// @param signature Signed order along with signature mode.\r\n    /// @param maxFillAmount Maximum amount of the order to be filled.\r\n    function trade(OrderLibrary.Order memory order, address taker, bytes signature, uint maxFillAmount) internal {\r\n        require(taker != order.maker);\r\n        bytes32 hash = order.hash();\r\n\r\n        require(order.makerToken != order.takerToken);\r\n        require(canTrade(order, signature, hash));\r\n\r\n        uint fillAmount = SafeMath.min256(maxFillAmount, availableAmount(order, hash));\r\n\r\n        require(roundingPercent(fillAmount, order.takerTokenAmount, order.makerTokenAmount) \u003C= MAX_ROUNDING_PERCENTAGE);\r\n        require(vault.balanceOf(order.takerToken, taker) \u003E= fillAmount);\r\n\r\n        uint makeAmount = order.makerTokenAmount.mul(fillAmount).div(order.takerTokenAmount);\r\n        uint tradeTakerFee = makeAmount.mul(takerFee).div(1 ether);\r\n\r\n        if (tradeTakerFee \u003E 0) {\r\n            vault.transfer(order.makerToken, order.maker, feeAccount, tradeTakerFee);\r\n        }\r\n\r\n        vault.transfer(order.takerToken, taker, order.maker, fillAmount);\r\n        vault.transfer(order.makerToken, order.maker, taker, makeAmount.sub(tradeTakerFee));\r\n\r\n        fills[hash] = fills[hash].add(fillAmount);\r\n        assert(fills[hash] \u003C= order.takerTokenAmount);\r\n\r\n        if (subscribed[order.maker]) {\r\n            order.maker.call.gas(MAX_HOOK_GAS)(HookSubscriber(order.maker).tradeExecuted.selector, order.takerToken, fillAmount);\r\n        }\r\n\r\n        emit Traded(\r\n            hash,\r\n            order.makerToken,\r\n            makeAmount,\r\n            order.takerToken,\r\n            fillAmount,\r\n            order.maker,\r\n            taker\r\n        );\r\n    }\r\n\r\n    /// @dev Indicates whether or not an certain amount of an order can be traded.\r\n    /// @param order Order to be traded.\r\n    /// @param signature Signed order along with signature mode.\r\n    /// @param hash Hash of the order.\r\n    /// @return Boolean if order can be traded\r\n    function canTrade(OrderLibrary.Order memory order, bytes signature, bytes32 hash)\r\n        internal\r\n        view\r\n        returns (bool)\r\n    {\r\n        // if the order has never been traded against, we need to check the sig.\r\n        if (fills[hash] == 0) {\r\n            // ensures order was either created on chain, or signature is valid\r\n            if (!isOrdered(order.maker, hash) \u0026\u0026 !SignatureValidator.isValidSignature(hash, order.maker, signature)) {\r\n                return false;\r\n            }\r\n        }\r\n\r\n        if (cancelled[hash]) {\r\n            return false;\r\n        }\r\n\r\n        if (!vault.isApproved(order.maker, this)) {\r\n            return false;\r\n        }\r\n\r\n        if (order.takerTokenAmount == 0) {\r\n            return false;\r\n        }\r\n\r\n        if (order.makerTokenAmount == 0) {\r\n            return false;\r\n        }\r\n\r\n        // ensures that the order still has an available amount to be filled.\r\n        if (availableAmount(order, hash) == 0) {\r\n            return false;\r\n        }\r\n\r\n        return order.expires \u003E now;\r\n    }\r\n\r\n    /// @dev Returns the maximum available amount that can be taken of an order.\r\n    /// @param order Order to check.\r\n    /// @param hash Hash of the order.\r\n    /// @return Amount of the order that can be filled.\r\n    function availableAmount(OrderLibrary.Order memory order, bytes32 hash) internal view returns (uint) {\r\n        return SafeMath.min256(\r\n            order.takerTokenAmount.sub(fills[hash]),\r\n            vault.balanceOf(order.makerToken, order.maker).mul(order.takerTokenAmount).div(order.makerTokenAmount)\r\n        );\r\n    }\r\n\r\n    /// @dev Returns the percentage which was rounded when dividing.\r\n    /// @param numerator Numerator.\r\n    /// @param denominator Denominator.\r\n    /// @param target Value to multiply with.\r\n    /// @return Percentage rounded.\r\n    function roundingPercent(uint numerator, uint denominator, uint target) internal pure returns (uint) {\r\n        // Inspired by https://github.com/0xProject/contracts/blob/1.0.0/contracts/Exchange.sol#L472-L490\r\n        uint remainder = mulmod(target, numerator, denominator);\r\n        if (remainder == 0) {\r\n            return 0;\r\n        }\r\n\r\n        return remainder.mul(1000000).div(numerator.mul(target));\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022hash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022isOrdered\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022addresses\u0022,\u0022type\u0022:\u0022address[3]\u0022},{\u0022name\u0022:\u0022values\u0022,\u0022type\u0022:\u0022uint256[4]\u0022},{\u0022name\u0022:\u0022signature\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022name\u0022:\u0022maxFillAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022trade\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022addresses\u0022,\u0022type\u0022:\u0022address[3]\u0022},{\u0022name\u0022:\u0022values\u0022,\u0022type\u0022:\u0022uint256[4]\u0022},{\u0022name\u0022:\u0022signature\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022canTrade\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022addresses\u0022,\u0022type\u0022:\u0022address[3]\u0022},{\u0022name\u0022:\u0022values\u0022,\u0022type\u0022:\u0022uint256[4]\u0022}],\u0022name\u0022:\u0022availableAmount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022hash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022filled\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_takerFee\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setFees\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022takerFee\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_feeAccount\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setFeeAccount\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022feeAccount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022subscribe\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022addresses\u0022,\u0022type\u0022:\u0022address[3]\u0022},{\u0022name\u0022:\u0022values\u0022,\u0022type\u0022:\u0022uint256[4]\u0022}],\u0022name\u0022:\u0022cancel\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022subscriber\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isSubscribed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MAX_FEE\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022addresses\u0022,\u0022type\u0022:\u0022address[2]\u0022},{\u0022name\u0022:\u0022values\u0022,\u0022type\u0022:\u0022uint256[4]\u0022}],\u0022name\u0022:\u0022order\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022vault\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unsubscribe\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_takerFee\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_feeAccount\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_vault\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Subscribed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Unsubscribed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022hash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022Cancelled\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022hash\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022makerToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022makerTokenAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022takerToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022takerTokenAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022maker\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022taker\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Traded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022maker\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022makerToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022takerToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022makerTokenAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022takerTokenAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022expires\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Ordered\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Exchange","CompilerVersion":"v0.4.23\u002Bcommit.124ca40d","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004e1b7f0271f1c0698dfbbed7b61f690cd98dd6390000000000000000000000003956925d7d5199a6db1f42347fedbcd35312ae82","Library":"","SwarmSource":"bzzr://39d537f0ca5170a6ecba5701069b3e7202d76ade82f09c0a1bb10f08c2f30ded"}]