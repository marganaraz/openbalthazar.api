[{"SourceCode":"pragma solidity 0.5.10;\r\n\r\n/**\r\n * Copyright \u00A9 2017-2019 Ramp Network sp. z o.o. All rights reserved (MIT License).\r\n *\r\n * Permission is hereby granted, free of charge, to any person obtaining a copy of this software\r\n * and associated documentation files (the \u0022Software\u0022), to deal in the Software without restriction,\r\n * including without limitation the rights to use, copy, modify, merge, publish, distribute,\r\n * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software\r\n * is furnished to do so, subject to the following conditions:\r\n *\r\n * The above copyright notice and this permission notice shall be included in all copies\r\n * or substantial portions of the Software.\r\n *\r\n * THE SOFTWARE IS PROVIDED \u0022AS IS\u0022, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING\r\n * BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE\r\n * AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,\r\n * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\r\n * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\r\n */\r\n\r\n\r\ninterface Erc20Token {\r\n\r\n    /**\r\n     * Send \u0060_value\u0060 of tokens from \u0060msg.sender\u0060 to \u0060_to\u0060\r\n     *\r\n     * @param _to The recipient address\r\n     * @param _value The amount of tokens to be transferred\r\n     * @return Indication if the transfer was successful\r\n     */\r\n    function transfer(address _to, uint256 _value) external returns (bool success);\r\n\r\n    /**\r\n     * Approve \u0060_spender\u0060 to withdraw from sender\u0027s account multiple times, up to \u0060_value\u0060\r\n     * amount. If this function is called again it overwrites the current allowance with _value.\r\n     *\r\n     * @param _spender The address allowed to operate on sender\u0027s tokens\r\n     * @param _value The amount of tokens allowed to be transferred\r\n     * @return Indication if the approval was successful\r\n     */\r\n    function approve(address _spender, uint256 _value) external returns (bool success);\r\n\r\n    /**\r\n     * Transfer tokens on behalf of \u0060_from\u0060, provided it was previously approved.\r\n     *\r\n     * @param _from The transfer source address (tokens owner)\r\n     * @param _to The transfer destination address\r\n     * @param _value The amount of tokens to be transferred\r\n     * @return Indication if the approval was successful\r\n     */\r\n    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);\r\n\r\n    /**\r\n     * Returns the account balance of another account with address \u0060_owner\u0060.\r\n     */\r\n    function balanceOf(address _owner) external view returns (uint256);\r\n\r\n}\r\n\r\ncontract AssetAdapter {\r\n\r\n    uint16 public ASSET_TYPE;\r\n\r\n    constructor(\r\n        uint16 assetType\r\n    ) internal {\r\n        ASSET_TYPE = assetType;\r\n    }\r\n\r\n    /**\r\n     * Ensure the described asset is sent to the given address.\r\n     * Should revert if the transfer failed, but callers must also handle \u0060false\u0060 being returned,\r\n     * much like ERC-20\u0027s \u0060transfer\u0060.\r\n     */\r\n    function rawSendAsset(\r\n        bytes memory assetData,\r\n        uint256 _amount,\r\n        address payable _to\r\n    ) internal returns (bool success);  // solium-disable-line indentation\r\n    // indentation rule bug ^ https://github.com/duaraghav8/Ethlint/issues/268\r\n\r\n    /**\r\n     * Ensure the described asset is sent to this contract.\r\n     * Should revert if the transfer failed, but callers must also handle \u0060false\u0060 being returned,\r\n     * much like ERC-20\u0027s \u0060transfer\u0060.\r\n     */\r\n    function rawLockAsset(\r\n        uint256 amount,\r\n        address payable _from\r\n    ) internal returns (bool success) {\r\n        return RampInstantPoolInterface(_from).sendFundsToSwap(amount);\r\n    }\r\n\r\n    function getAmount(bytes memory assetData) internal pure returns (uint256);\r\n\r\n    /**\r\n     * Verify that the passed asset data can be handled by this adapter and given pool.\r\n     *\r\n     * @dev it\u0027s sufficient to use this only when creating a new swap -- all the other swap\r\n     * functions first check if the swap hash is valid, while a swap hash with invalid\r\n     * asset type wouldn\u0027t be created at all.\r\n     *\r\n     * @dev asset type is 2 bytes long, and it\u0027s at offset 32 in \u0060assetData\u0060\u0027s memory (the first 32\r\n     * bytes are the data length). We load the word at offset 2 (it ends with the asset type bytes),\r\n     * and retrieve its last 2 bytes into a \u0060uint16\u0060 variable.\r\n     */\r\n    modifier checkAssetTypeAndData(bytes memory assetData, address _pool) {\r\n        uint16 assetType;\r\n        // solium-disable-next-line security/no-inline-assembly\r\n        assembly {\r\n            assetType := and(\r\n                mload(add(assetData, 2)),\r\n                0xffff\r\n            )\r\n        }\r\n        require(assetType == ASSET_TYPE, \u0022invalid asset type\u0022);\r\n        checkAssetData(assetData, _pool);\r\n        _;\r\n    }\r\n\r\n    function checkAssetData(bytes memory assetData, address _pool) internal view;\r\n\r\n    function () external payable {\r\n        revert(\u0022this contract cannot receive ether\u0022);\r\n    }\r\n\r\n}\r\n\r\ncontract RampInstantPoolInterface {\r\n\r\n    uint16 public ASSET_TYPE;\r\n\r\n    function sendFundsToSwap(uint256 _amount)\r\n        public /*onlyActive onlySwapsContract isWithinLimits*/ returns(bool success);\r\n\r\n}\r\n\r\ncontract RampInstantTokenPoolInterface is RampInstantPoolInterface {\r\n\r\n    address public token;\r\n\r\n}\r\n\r\ncontract Ownable {\r\n\r\n    address public owner;\r\n\r\n    event OwnerChanged(address oldOwner, address newOwner);\r\n\r\n    constructor() internal {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner, \u0022only the owner can call this\u0022);\r\n        _;\r\n    }\r\n\r\n    function changeOwner(address _newOwner) external onlyOwner {\r\n        owner = _newOwner;\r\n        emit OwnerChanged(msg.sender, _newOwner);\r\n    }\r\n\r\n}\r\n\r\ncontract WithStatus is Ownable {\r\n\r\n    enum Status {\r\n        STOPPED,\r\n        RETURN_ONLY,\r\n        FINALIZE_ONLY,\r\n        ACTIVE\r\n    }\r\n\r\n    event StatusChanged(Status oldStatus, Status newStatus);\r\n\r\n    Status public status = Status.ACTIVE;\r\n\r\n    function setStatus(Status _status) external onlyOwner {\r\n        emit StatusChanged(status, _status);\r\n        status = _status;\r\n    }\r\n\r\n    modifier statusAtLeast(Status _status) {\r\n        require(status \u003E= _status, \u0022invalid contract status\u0022);\r\n        _;\r\n    }\r\n\r\n}\r\n\r\ncontract WithOracles is Ownable {\r\n\r\n    mapping (address =\u003E bool) oracles;\r\n\r\n    constructor() internal {\r\n        oracles[msg.sender] = true;\r\n    }\r\n\r\n    function approveOracle(address _oracle) external onlyOwner {\r\n        oracles[_oracle] = true;\r\n    }\r\n\r\n    function revokeOracle(address _oracle) external onlyOwner {\r\n        oracles[_oracle] = false;\r\n    }\r\n\r\n    modifier isOracle(address _oracle) {\r\n        require(oracles[_oracle], \u0022invalid oracle address\u0022);\r\n        _;\r\n    }\r\n\r\n    modifier onlyOracleOrPool(address _pool, address _oracle) {\r\n        require(\r\n            msg.sender == _pool || (msg.sender == _oracle \u0026\u0026 oracles[msg.sender]),\r\n            \u0022only the oracle or the pool can call this\u0022\r\n        );\r\n        _;\r\n    }\r\n\r\n}\r\n\r\ncontract WithSwapsCreator is Ownable {\r\n\r\n    address internal swapCreator;\r\n\r\n    event SwapCreatorChanged(address _oldCreator, address _newCreator);\r\n\r\n    constructor() internal {\r\n        swapCreator = msg.sender;\r\n    }\r\n\r\n    function changeSwapCreator(address _newCreator) public onlyOwner {\r\n        swapCreator = _newCreator;\r\n        emit SwapCreatorChanged(msg.sender, _newCreator);\r\n    }\r\n\r\n    modifier onlySwapCreator() {\r\n        require(msg.sender == swapCreator, \u0022only the swap creator can call this\u0022);\r\n        _;\r\n    }\r\n\r\n}\r\n\r\ncontract AssetAdapterWithFees is Ownable, AssetAdapter {\r\n\r\n    uint16 public feeThousandthsPercent;\r\n    uint256 public minFeeAmount;\r\n\r\n    constructor(uint16 _feeThousandthsPercent, uint256 _minFeeAmount) public {\r\n        require(_feeThousandthsPercent \u003C (1 \u003C\u003C 16), \u0022fee % too high\u0022);\r\n        require(_minFeeAmount \u003C= (1 \u003C\u003C 255), \u0022minFeeAmount too high\u0022);\r\n        feeThousandthsPercent = _feeThousandthsPercent;\r\n        minFeeAmount = _minFeeAmount;\r\n    }\r\n\r\n    function rawAccumulateFee(bytes memory assetData, uint256 _amount) internal;\r\n\r\n    function accumulateFee(bytes memory assetData) internal {\r\n        rawAccumulateFee(assetData, getFee(getAmount(assetData)));\r\n    }\r\n\r\n    function withdrawFees(\r\n        bytes calldata assetData,\r\n        address payable _to\r\n    ) external /*onlyOwner*/ returns (bool success);  // solium-disable-line indentation\r\n\r\n    function getFee(uint256 _amount) internal view returns (uint256) {\r\n        uint256 fee = _amount * feeThousandthsPercent / 100000;\r\n        return fee \u003C minFeeAmount\r\n            ? minFeeAmount\r\n            : fee;\r\n    }\r\n\r\n    function getAmountWithFee(bytes memory assetData) internal view returns (uint256) {\r\n        uint256 baseAmount = getAmount(assetData);\r\n        return baseAmount \u002B getFee(baseAmount);\r\n    }\r\n\r\n    function lockAssetWithFee(\r\n        bytes memory assetData,\r\n        address payable _from\r\n    ) internal returns (bool success) {\r\n        return rawLockAsset(getAmountWithFee(assetData), _from);\r\n    }\r\n\r\n    function sendAssetWithFee(\r\n        bytes memory assetData,\r\n        address payable _to\r\n    ) internal returns (bool success) {\r\n        return rawSendAsset(assetData, getAmountWithFee(assetData), _to);\r\n    }\r\n\r\n    function sendAssetKeepingFee(\r\n        bytes memory assetData,\r\n        address payable _to\r\n    ) internal returns (bool success) {\r\n        bool result = rawSendAsset(assetData, getAmount(assetData), _to);\r\n        if (result) accumulateFee(assetData);\r\n        return result;\r\n    }\r\n\r\n}\r\n\r\ncontract RampInstantEscrows\r\nis Ownable, WithStatus, WithOracles, WithSwapsCreator, AssetAdapterWithFees {\r\n\r\n    /// @dev contract version, defined in semver\r\n    string public constant VERSION = \u00220.5.0\u0022;\r\n\r\n    uint32 internal constant MIN_ACTUAL_TIMESTAMP = 1000000000;\r\n\r\n    /// @notice lock time limits for pool\u0027s assets, after which unreleased escrows can be returned\r\n    uint32 internal constant MIN_SWAP_LOCK_TIME_S = 24 hours;\r\n    uint32 internal constant MAX_SWAP_LOCK_TIME_S = 30 days;\r\n\r\n    event Created(bytes32 indexed swapHash);\r\n    event Released(bytes32 indexed swapHash);\r\n    event PoolReleased(bytes32 indexed swapHash);\r\n    event Returned(bytes32 indexed swapHash);\r\n    event PoolReturned(bytes32 indexed swapHash);\r\n\r\n    /**\r\n     * @notice Mapping from swap details hash to its end time (as a unix timestamp).\r\n     * After the end time the swap can be cancelled, and the funds will be returned to the pool.\r\n     */\r\n    mapping (bytes32 =\u003E uint32) internal swaps;\r\n\r\n    /**\r\n     * Swap creation, called by the Ramp Network. Checks swap parameters and ensures the crypto\r\n     * asset is locked on this contract.\r\n     *\r\n     * Emits a \u0060Created\u0060 event with the swap hash.\r\n     */\r\n    function create(\r\n        address payable _pool,\r\n        address _receiver,\r\n        address _oracle,\r\n        bytes calldata _assetData,\r\n        bytes32 _paymentDetailsHash,\r\n        uint32 lockTimeS\r\n    )\r\n        external\r\n        statusAtLeast(Status.ACTIVE)\r\n        onlySwapCreator()\r\n        isOracle(_oracle)\r\n        checkAssetTypeAndData(_assetData, _pool)\r\n        returns\r\n        (bool success)\r\n    {\r\n        require(\r\n            lockTimeS \u003E= MIN_SWAP_LOCK_TIME_S \u0026\u0026 lockTimeS \u003C= MAX_SWAP_LOCK_TIME_S,\r\n            \u0022lock time outside limits\u0022\r\n        );\r\n        bytes32 swapHash = getSwapHash(\r\n            _pool, _receiver, _oracle, keccak256(_assetData), _paymentDetailsHash\r\n        );\r\n        requireSwapNotExists(swapHash);\r\n        // Set up swap status before transfer, to avoid reentrancy attacks.\r\n        // Even if a malicious token is somehow passed to this function (despite the oracle\r\n        // signature of its details), the state of this contract is already fully updated,\r\n        // so it will behave correctly (as it would be a separate call).\r\n        // solium-disable-next-line security/no-block-members\r\n        swaps[swapHash] = uint32(block.timestamp) \u002B lockTimeS;\r\n        require(\r\n            lockAssetWithFee(_assetData, _pool),\r\n            \u0022escrow lock failed\u0022\r\n        );\r\n        emit Created(swapHash);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * Swap release, which transfers the crypto asset to the receiver and removes the swap from\r\n     * the active swap mapping. Normally called by the swap\u0027s oracle after it confirms a matching\r\n     * wire transfer on pool\u0027s bank account. Can be also called by the pool, for example in case\r\n     * of a dispute, when the parties reach an agreement off-chain.\r\n     *\r\n     * Emits a \u0060Released\u0060 or \u0060PoolReleased\u0060 event with the swap\u0027s hash.\r\n     */\r\n    function release(\r\n        address _pool,\r\n        address payable _receiver,\r\n        address _oracle,\r\n        bytes calldata _assetData,\r\n        bytes32 _paymentDetailsHash\r\n    ) external statusAtLeast(Status.FINALIZE_ONLY) onlyOracleOrPool(_pool, _oracle) {\r\n        bytes32 swapHash = getSwapHash(\r\n            _pool, _receiver, _oracle, keccak256(_assetData), _paymentDetailsHash\r\n        );\r\n        requireSwapCreated(swapHash);\r\n        // Delete the swap status before transfer, to avoid reentrancy attacks.\r\n        swaps[swapHash] = 0;\r\n        require(\r\n            sendAssetKeepingFee(_assetData, _receiver),\r\n            \u0022asset release failed\u0022\r\n        );\r\n        if (msg.sender == _pool) {\r\n            emit PoolReleased(swapHash);\r\n        } else {\r\n            emit Released(swapHash);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * Swap return, which transfers the crypto asset back to the pool and removes the swap from\r\n     * the active swap mapping. Can be called by the pool or the swap\u0027s oracle, but only if the\r\n     * escrow lock time expired.\r\n     *\r\n     * Emits a \u0060Returned\u0060 or \u0060PoolReturned\u0060 event with the swap\u0027s hash.\r\n     */\r\n    function returnFunds(\r\n        address payable _pool,\r\n        address _receiver,\r\n        address _oracle,\r\n        bytes calldata _assetData,\r\n        bytes32 _paymentDetailsHash\r\n    ) external statusAtLeast(Status.RETURN_ONLY) onlyOracleOrPool(_pool, _oracle) {\r\n        bytes32 swapHash = getSwapHash(\r\n            _pool, _receiver, _oracle, keccak256(_assetData), _paymentDetailsHash\r\n        );\r\n        requireSwapExpired(swapHash);\r\n        // Delete the swap status before transfer, to avoid reentrancy attacks.\r\n        swaps[swapHash] = 0;\r\n        require(\r\n            sendAssetWithFee(_assetData, _pool),\r\n            \u0022asset return failed\u0022\r\n        );\r\n        if (msg.sender == _pool) {\r\n            emit PoolReturned(swapHash);\r\n        } else {\r\n            emit Returned(swapHash);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * Given all valid swap details, returns its status. The return can be:\r\n     * 0: the swap details are invalid, swap doesn\u0027t exist, or was already released/returned.\r\n     * \u003E1: the swap was created, and the value is a timestamp indicating end of its lock time.\r\n     */\r\n    function getSwapStatus(\r\n        address _pool,\r\n        address _receiver,\r\n        address _oracle,\r\n        bytes calldata _assetData,\r\n        bytes32 _paymentDetailsHash\r\n    ) external view returns (uint32 status) {\r\n        bytes32 swapHash = getSwapHash(\r\n            _pool, _receiver, _oracle, keccak256(_assetData), _paymentDetailsHash\r\n        );\r\n        return swaps[swapHash];\r\n    }\r\n\r\n    /**\r\n     * Calculates the swap hash used to reference the swap in this contract\u0027s storage.\r\n     */\r\n    function getSwapHash(\r\n        address _pool,\r\n        address _receiver,\r\n        address _oracle,\r\n        bytes32 assetHash,\r\n        bytes32 _paymentDetailsHash\r\n    ) internal pure returns (bytes32) {\r\n        return keccak256(\r\n            abi.encodePacked(\r\n                _pool, _receiver, _oracle, assetHash, _paymentDetailsHash\r\n            )\r\n        );\r\n    }\r\n\r\n    function requireSwapNotExists(bytes32 swapHash) internal view {\r\n        require(\r\n            swaps[swapHash] == 0,\r\n            \u0022swap already exists\u0022\r\n        );\r\n    }\r\n\r\n    function requireSwapCreated(bytes32 swapHash) internal view {\r\n        require(\r\n            swaps[swapHash] \u003E MIN_ACTUAL_TIMESTAMP,\r\n            \u0022swap invalid\u0022\r\n        );\r\n    }\r\n\r\n    function requireSwapExpired(bytes32 swapHash) internal view {\r\n        require(\r\n            // solium-disable-next-line security/no-block-members\r\n            swaps[swapHash] \u003E MIN_ACTUAL_TIMESTAMP \u0026\u0026 block.timestamp \u003E swaps[swapHash],\r\n            \u0022swap not expired or invalid\u0022\r\n        );\r\n    }\r\n\r\n}\r\n\r\ncontract TokenAdapter is AssetAdapterWithFees {\r\n\r\n    uint16 internal constant TOKEN_TYPE_ID = 2;\r\n    uint16 internal constant TOKEN_ASSET_DATA_LENGTH = 54;\r\n    mapping (address =\u003E uint256) internal accumulatedFees;\r\n\r\n    constructor() internal AssetAdapter(TOKEN_TYPE_ID) {}\r\n\r\n    /**\r\n    * @dev token assetData bytes contents:\r\n    * offset length type     contents\r\n    * \u002B00    32     uint256  data length (== 0x36 == 54 bytes)\r\n    * \u002B32     2     uint16   asset type  (== TOKEN_TYPE_ID == 2)\r\n    * \u002B34    32     uint256  token amount in units\r\n    * \u002B66    20     address  token contract address\r\n    */\r\n    function getAmount(bytes memory assetData) internal pure returns (uint256 amount) {\r\n        // solium-disable-next-line security/no-inline-assembly\r\n        assembly {\r\n            amount := mload(add(assetData, 34))\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev To retrieve the address at offset 66, get the word at offset 54 and return its last\r\n     * 20 bytes. See \u0060getAmount\u0060 for byte offsets table.\r\n     */\r\n    function getTokenAddress(bytes memory assetData) internal pure returns (address tokenAddress) {\r\n        // solium-disable-next-line security/no-inline-assembly\r\n        assembly {\r\n            tokenAddress := and(\r\n                mload(add(assetData, 54)),\r\n                0xffffffffffffffffffffffffffffffffffffffff\r\n            )\r\n        }\r\n    }\r\n\r\n    function rawSendAsset(\r\n        bytes memory assetData,\r\n        uint256 _amount,\r\n        address payable _to\r\n    ) internal returns (bool success) {\r\n        Erc20Token token = Erc20Token(getTokenAddress(assetData));\r\n        return token.transfer(_to, _amount);\r\n    }\r\n\r\n    function rawAccumulateFee(bytes memory assetData, uint256 _amount) internal {\r\n        accumulatedFees[getTokenAddress(assetData)] \u002B= _amount;\r\n    }\r\n\r\n    function withdrawFees(\r\n        bytes calldata assetData,\r\n        address payable _to\r\n    ) external onlyOwner returns (bool success) {\r\n        address token = getTokenAddress(assetData);\r\n        uint256 fees = accumulatedFees[token];\r\n        accumulatedFees[token] = 0;\r\n        require(Erc20Token(token).transfer(_to, fees), \u0022fees transfer failed\u0022);\r\n        return true;\r\n    }\r\n\r\n    function checkAssetData(bytes memory assetData, address _pool) internal view {\r\n        require(assetData.length == TOKEN_ASSET_DATA_LENGTH, \u0022invalid asset data length\u0022);\r\n        require(\r\n            RampInstantTokenPoolInterface(_pool).token() == getTokenAddress(assetData),\r\n            \u0022invalid pool token address\u0022\r\n        );\r\n    }\r\n\r\n}\r\n\r\ncontract RampInstantTokenEscrows is RampInstantEscrows, TokenAdapter {\r\n\r\n    constructor(\r\n        uint16 _feeThousandthsPercent,\r\n        uint256 _minFeeAmount\r\n    ) public AssetAdapterWithFees(_feeThousandthsPercent, _minFeeAmount) {}\r\n\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_pool\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_oracle\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_assetData\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022name\u0022:\u0022_paymentDetailsHash\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022lockTimeS\u0022,\u0022type\u0022:\u0022uint32\u0022}],\u0022name\u0022:\u0022create\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022feeThousandthsPercent\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint16\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022status\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newCreator\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022changeSwapCreator\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_status\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022name\u0022:\u0022setStatus\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_oracle\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022revokeOracle\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ASSET_TYPE\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint16\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_pool\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_oracle\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_assetData\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022name\u0022:\u0022_paymentDetailsHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022getSwapStatus\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022status\u0022,\u0022type\u0022:\u0022uint32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_pool\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_oracle\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_assetData\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022name\u0022:\u0022_paymentDetailsHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022release\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022changeOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_pool\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_oracle\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_assetData\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022name\u0022:\u0022_paymentDetailsHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022returnFunds\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022assetData\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022withdrawFees\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_oracle\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022approveOracle\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022minFeeAmount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022VERSION\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_feeThousandthsPercent\u0022,\u0022type\u0022:\u0022uint16\u0022},{\u0022name\u0022:\u0022_minFeeAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022swapHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022Created\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022swapHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022Released\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022swapHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022PoolReleased\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022swapHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022Returned\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022swapHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022PoolReturned\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_oldCreator\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_newCreator\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022SwapCreatorChanged\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022oldStatus\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022newStatus\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022name\u0022:\u0022StatusChanged\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022oldOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnerChanged\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"RampInstantTokenEscrows","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"1","Runs":"420","ConstructorArguments":"00000000000000000000000000000000000000000000000000000000000005dc0000000000000000000000000000000000000000000000000000000000000064","Library":"","SwarmSource":"bzzr://600619f403d3ee22cdb4ff62e7bd60774355d6fa5d6ed4a07177f2b652df3273"}]