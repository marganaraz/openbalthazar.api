[{"SourceCode":"{\u0022OrderList.sol\u0022:{\u0022content\u0022:\u0022pragma solidity 0.4.18;\\n\\n\\nimport \\\u0022../../../PermissionGroups.sol\\\u0022;\\nimport \\\u0022./OrderListInterface.sol\\\u0022;\\n\\n\\ncontract OrderList is PermissionGroups, OrderListInterface {\\n\\n    struct Order {\\n        address maker;\\n        uint32 prevId;\\n        uint32 nextId;\\n        uint128 srcAmount;\\n        uint128 dstAmount;\\n    }\\n\\n    mapping (uint32 =\\u003e Order) public orders;\\n\\n    // Results of calling updateWithPositionHint.\\n    uint constant public UPDATE_ONLY_AMOUNTS = 0;\\n    uint constant public UPDATE_MOVE_ORDER = 1;\\n    uint constant public UPDATE_FAILED = 2;\\n\\n    uint32 constant public TAIL_ID = 1;\\n    uint32 constant public HEAD_ID = 2;\\n\\n    uint32 public nextFreeId = 3;\\n\\n    function OrderList(address _admin) public {\\n        require(_admin != address(0));\\n\\n        admin = _admin;\\n\\n        // Initializing a \\\u0022dummy\\\u0022 order as HEAD.\\n        orders[HEAD_ID].maker = 0;\\n        orders[HEAD_ID].prevId = 0;\\n        orders[HEAD_ID].nextId = TAIL_ID;\\n        orders[HEAD_ID].srcAmount = 0;\\n        orders[HEAD_ID].dstAmount = 0;\\n    }\\n\\n    function getOrderDetails(uint32 orderId)\\n        public\\n        view\\n        returns (\\n            address maker,\\n            uint128 srcAmount,\\n            uint128 dstAmount,\\n            uint32 prevId,\\n            uint32 nextId\\n        )\\n    {\\n        Order storage order = orders[orderId];\\n\\n        maker = order.maker;\\n        srcAmount = order.srcAmount;\\n        dstAmount = order.dstAmount;\\n        prevId = order.prevId;\\n        nextId = order.nextId;\\n    }\\n\\n    function add(\\n        address maker,\\n        uint32 orderId,\\n        uint128 srcAmount,\\n        uint128 dstAmount\\n    )\\n        public\\n        onlyAdmin\\n        returns(bool)\\n    {\\n        require(orderId != 0 \\u0026\\u0026 orderId != HEAD_ID \\u0026\\u0026 orderId != TAIL_ID);\\n\\n        uint32 prevId = findPrevOrderId(srcAmount, dstAmount);\\n        return addAfterValidId(maker, orderId, srcAmount, dstAmount, prevId);\\n    }\\n\\n    // Returns false if provided with bad hint.\\n    function addAfterId(\\n        address maker,\\n        uint32 orderId,\\n        uint128 srcAmount,\\n        uint128 dstAmount,\\n        uint32 prevId\\n    )\\n        public\\n        onlyAdmin\\n        returns (bool)\\n    {\\n        uint32 nextId = orders[prevId].nextId;\\n        if (!isRightPosition(srcAmount, dstAmount, prevId, nextId)) {\\n            return false;\\n        }\\n        return addAfterValidId(maker, orderId, srcAmount, dstAmount, prevId);\\n    }\\n\\n    function remove(uint32 orderId) public onlyAdmin returns (bool) {\\n        verifyCanRemoveOrderById(orderId);\\n\\n        // Disconnect order from list\\n        Order storage order = orders[orderId];\\n        orders[order.prevId].nextId = order.nextId;\\n        orders[order.nextId].prevId = order.prevId;\\n\\n        // Mark deleted order\\n        order.prevId = TAIL_ID;\\n        order.nextId = HEAD_ID;\\n\\n        return true;\\n    }\\n\\n    function update(uint32 orderId, uint128 srcAmount, uint128 dstAmount)\\n        public\\n        onlyAdmin\\n        returns(bool)\\n    {\\n        address maker = orders[orderId].maker;\\n        require(remove(orderId));\\n        require(add(maker, orderId, srcAmount, dstAmount));\\n\\n        return true;\\n    }\\n\\n    // Returns false if provided with a bad hint.\\n    function updateWithPositionHint(\\n        uint32 orderId,\\n        uint128 updatedSrcAmount,\\n        uint128 updatedDstAmount,\\n        uint32 updatedPrevId\\n    )\\n        public\\n        onlyAdmin\\n        returns (bool, uint)\\n    {\\n        require(orderId != 0 \\u0026\\u0026 orderId != HEAD_ID \\u0026\\u0026 orderId != TAIL_ID);\\n\\n        // Normal orders usually cannot serve as their own previous order.\\n        // For further discussion see Heinlein\\u0027s \\u0027\u2014All You Zombies\u2014\\u0027.\\n        require(orderId != updatedPrevId);\\n\\n        uint32 nextId;\\n\\n        // updatedPrevId is the intended prevId of the order, after updating its\\n        // values.\\n        // If it is the same as the current prevId of the order, the order does\\n        // not need to change place in the list, only update its amounts.\\n        if (orders[orderId].prevId == updatedPrevId) {\\n            nextId = orders[orderId].nextId;\\n            if (isRightPosition(\\n                updatedSrcAmount,\\n                updatedDstAmount,\\n                updatedPrevId,\\n                nextId)\\n            ) {\\n                orders[orderId].srcAmount = updatedSrcAmount;\\n                orders[orderId].dstAmount = updatedDstAmount;\\n                return (true, UPDATE_ONLY_AMOUNTS);\\n            }\\n        } else {\\n            nextId = orders[updatedPrevId].nextId;\\n            if (isRightPosition(\\n                updatedSrcAmount,\\n                updatedDstAmount,\\n                updatedPrevId,\\n                nextId)\\n            ) {\\n                // Let\\u0027s move the order to the hinted position.\\n                address maker = orders[orderId].maker;\\n                require(remove(orderId));\\n                require(\\n                    addAfterValidId(\\n                        maker,\\n                        orderId,\\n                        updatedSrcAmount,\\n                        updatedDstAmount,\\n                        updatedPrevId\\n                    )\\n                );\\n                return (true, UPDATE_MOVE_ORDER);\\n            }\\n        }\\n\\n        // bad hint.\\n        return (false, UPDATE_FAILED);\\n    }\\n\\n    function allocateIds(uint32 howMany) public onlyAdmin returns(uint32) {\\n        uint32 firstId = nextFreeId;\\n        require(nextFreeId \u002B howMany \\u003e= nextFreeId);\\n        nextFreeId \u002B= howMany;\\n        return firstId;\\n    }\\n\\n    function compareOrders(\\n        uint128 srcAmount1,\\n        uint128 dstAmount1,\\n        uint128 srcAmount2,\\n        uint128 dstAmount2\\n    )\\n        public\\n        pure\\n        returns(int)\\n    {\\n        uint256 s1 = srcAmount1;\\n        uint256 d1 = dstAmount1;\\n        uint256 s2 = srcAmount2;\\n        uint256 d2 = dstAmount2;\\n\\n        if (s2 * d1 \\u003c s1 * d2) return -1;\\n        if (s2 * d1 \\u003e s1 * d2) return 1;\\n        return 0;\\n    }\\n\\n    function findPrevOrderId(uint128 srcAmount, uint128 dstAmount)\\n        public\\n        view\\n        returns(uint32)\\n    {\\n        uint32 currId = HEAD_ID;\\n        Order storage curr = orders[currId];\\n\\n        while (curr.nextId != TAIL_ID) {\\n            currId = curr.nextId;\\n            curr = orders[currId];\\n            int cmp = compareOrders(\\n                srcAmount,\\n                dstAmount,\\n                curr.srcAmount,\\n                curr.dstAmount\\n            );\\n\\n            if (cmp \\u003c 0) {\\n                return curr.prevId;\\n            }\\n        }\\n        return currId;\\n    }\\n\\n    function getFirstOrder() public view returns(uint32 orderId, bool isEmpty) {\\n        return (\\n            orders[HEAD_ID].nextId,\\n            orders[HEAD_ID].nextId == TAIL_ID\\n        );\\n    }\\n\\n    function addAfterValidId(\\n        address maker,\\n        uint32 orderId,\\n        uint128 srcAmount,\\n        uint128 dstAmount,\\n        uint32 prevId\\n    )\\n        private\\n        returns(bool)\\n    {\\n        Order storage prevOrder = orders[prevId];\\n\\n        // Add new order\\n        orders[orderId].maker = maker;\\n        orders[orderId].prevId = prevId;\\n        orders[orderId].nextId = prevOrder.nextId;\\n        orders[orderId].srcAmount = srcAmount;\\n        orders[orderId].dstAmount = dstAmount;\\n\\n        // Update next order to point back to added order\\n        uint32 nextOrderId = prevOrder.nextId;\\n        if (nextOrderId != TAIL_ID) {\\n            orders[nextOrderId].prevId = orderId;\\n        }\\n\\n        // Update previous order to point to added order\\n        prevOrder.nextId = orderId;\\n\\n        return true;\\n    }\\n\\n    function verifyCanRemoveOrderById(uint32 orderId) private view {\\n        require(orderId != 0 \\u0026\\u0026 orderId != HEAD_ID \\u0026\\u0026 orderId != TAIL_ID);\\n\\n        Order storage order = orders[orderId];\\n\\n        // Make sure this order actually in the list.\\n        require(order.prevId != 0 \\u0026\\u0026 order.nextId != 0 \\u0026\\u0026 order.prevId != TAIL_ID \\u0026\\u0026 order.nextId != HEAD_ID);\\n    }\\n\\n    function isRightPosition(\\n        uint128 srcAmount,\\n        uint128 dstAmount,\\n        uint32 prevId,\\n        uint32 nextId\\n    )\\n        private\\n        view\\n        returns (bool)\\n    {\\n        if (prevId == TAIL_ID || nextId == HEAD_ID) return false;\\n\\n        Order storage prev = orders[prevId];\\n\\n        // Make sure prev order is either HEAD or properly initialised.\\n        if (prevId != HEAD_ID \\u0026\\u0026 (\\n                prev.prevId == 0 ||\\n                prev.nextId == 0 ||\\n                prev.prevId == TAIL_ID ||\\n                prev.nextId == HEAD_ID)) {\\n            return false;\\n        }\\n\\n        int cmp;\\n        // Make sure that the new order should be after the provided prevId.\\n        if (prevId != HEAD_ID) {\\n            cmp = compareOrders(\\n                srcAmount,\\n                dstAmount,\\n                prev.srcAmount,\\n                prev.dstAmount\\n            );\\n            // new order is better than prev\\n            if (cmp \\u003c 0) return false;\\n        }\\n\\n        // Make sure that the new order should be before provided prevId\\u0027s next order.\\n        if (nextId != TAIL_ID) {\\n            Order storage next = orders[nextId];\\n            cmp = compareOrders(\\n                srcAmount,\\n                dstAmount,\\n                next.srcAmount,\\n                next.dstAmount\\n            );\\n            // new order is worse than next\\n            if (cmp \\u003e 0) return false;\\n        }\\n\\n        return true;\\n    }\\n}\\n\u0022},\u0022OrderListFactory.sol\u0022:{\u0022content\u0022:\u0022pragma solidity 0.4.18;\\n\\n\\nimport \\\u0022./OrderList.sol\\\u0022;\\n\\n\\ncontract OrderListFactory {\\n    function newOrdersContract(address admin) public returns(OrderListInterface) {\\n        OrderList orders = new OrderList(admin);\\n        return orders;\\n    }\\n}\\n\u0022},\u0022OrderListInterface.sol\u0022:{\u0022content\u0022:\u0022pragma solidity 0.4.18;\\n\\n\\ninterface OrderListInterface {\\n    function getOrderDetails(uint32 orderId) public view returns (address, uint128, uint128, uint32, uint32);\\n    function add(address maker, uint32 orderId, uint128 srcAmount, uint128 dstAmount) public returns (bool);\\n    function remove(uint32 orderId) public returns (bool);\\n    function update(uint32 orderId, uint128 srcAmount, uint128 dstAmount) public returns (bool);\\n    function getFirstOrder() public view returns(uint32 orderId, bool isEmpty);\\n    function allocateIds(uint32 howMany) public returns(uint32);\\n    function findPrevOrderId(uint128 srcAmount, uint128 dstAmount) public view returns(uint32);\\n\\n    function addAfterId(address maker, uint32 orderId, uint128 srcAmount, uint128 dstAmount, uint32 prevId) public\\n        returns (bool);\\n\\n    function updateWithPositionHint(uint32 orderId, uint128 srcAmount, uint128 dstAmount, uint32 prevId) public\\n        returns(bool, uint);\\n}\\n\u0022},\u0022PermissionGroups.sol\u0022:{\u0022content\u0022:\u0022pragma solidity 0.4.18;\\n\\n\\ncontract PermissionGroups {\\n\\n    address public admin;\\n    address public pendingAdmin;\\n    mapping(address=\\u003ebool) internal operators;\\n    mapping(address=\\u003ebool) internal alerters;\\n    address[] internal operatorsGroup;\\n    address[] internal alertersGroup;\\n    uint constant internal MAX_GROUP_SIZE = 50;\\n\\n    function PermissionGroups() public {\\n        admin = msg.sender;\\n    }\\n\\n    modifier onlyAdmin() {\\n        require(msg.sender == admin);\\n        _;\\n    }\\n\\n    modifier onlyOperator() {\\n        require(operators[msg.sender]);\\n        _;\\n    }\\n\\n    modifier onlyAlerter() {\\n        require(alerters[msg.sender]);\\n        _;\\n    }\\n\\n    function getOperators () external view returns(address[]) {\\n        return operatorsGroup;\\n    }\\n\\n    function getAlerters () external view returns(address[]) {\\n        return alertersGroup;\\n    }\\n\\n    event TransferAdminPending(address pendingAdmin);\\n\\n    /**\\n     * @dev Allows the current admin to set the pendingAdmin address.\\n     * @param newAdmin The address to transfer ownership to.\\n     */\\n    function transferAdmin(address newAdmin) public onlyAdmin {\\n        require(newAdmin != address(0));\\n        TransferAdminPending(pendingAdmin);\\n        pendingAdmin = newAdmin;\\n    }\\n\\n    /**\\n     * @dev Allows the current admin to set the admin in one tx. Useful initial deployment.\\n     * @param newAdmin The address to transfer ownership to.\\n     */\\n    function transferAdminQuickly(address newAdmin) public onlyAdmin {\\n        require(newAdmin != address(0));\\n        TransferAdminPending(newAdmin);\\n        AdminClaimed(newAdmin, admin);\\n        admin = newAdmin;\\n    }\\n\\n    event AdminClaimed( address newAdmin, address previousAdmin);\\n\\n    /**\\n     * @dev Allows the pendingAdmin address to finalize the change admin process.\\n     */\\n    function claimAdmin() public {\\n        require(pendingAdmin == msg.sender);\\n        AdminClaimed(pendingAdmin, admin);\\n        admin = pendingAdmin;\\n        pendingAdmin = address(0);\\n    }\\n\\n    event AlerterAdded (address newAlerter, bool isAdd);\\n\\n    function addAlerter(address newAlerter) public onlyAdmin {\\n        require(!alerters[newAlerter]); // prevent duplicates.\\n        require(alertersGroup.length \\u003c MAX_GROUP_SIZE);\\n\\n        AlerterAdded(newAlerter, true);\\n        alerters[newAlerter] = true;\\n        alertersGroup.push(newAlerter);\\n    }\\n\\n    function removeAlerter (address alerter) public onlyAdmin {\\n        require(alerters[alerter]);\\n        alerters[alerter] = false;\\n\\n        for (uint i = 0; i \\u003c alertersGroup.length; \u002B\u002Bi) {\\n            if (alertersGroup[i] == alerter) {\\n                alertersGroup[i] = alertersGroup[alertersGroup.length - 1];\\n                alertersGroup.length--;\\n                AlerterAdded(alerter, false);\\n                break;\\n            }\\n        }\\n    }\\n\\n    event OperatorAdded(address newOperator, bool isAdd);\\n\\n    function addOperator(address newOperator) public onlyAdmin {\\n        require(!operators[newOperator]); // prevent duplicates.\\n        require(operatorsGroup.length \\u003c MAX_GROUP_SIZE);\\n\\n        OperatorAdded(newOperator, true);\\n        operators[newOperator] = true;\\n        operatorsGroup.push(newOperator);\\n    }\\n\\n    function removeOperator (address operator) public onlyAdmin {\\n        require(operators[operator]);\\n        operators[operator] = false;\\n\\n        for (uint i = 0; i \\u003c operatorsGroup.length; \u002B\u002Bi) {\\n            if (operatorsGroup[i] == operator) {\\n                operatorsGroup[i] = operatorsGroup[operatorsGroup.length - 1];\\n                operatorsGroup.length -= 1;\\n                OperatorAdded(operator, false);\\n                break;\\n            }\\n        }\\n    }\\n}\\n\u0022}}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022admin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022newOrdersContract\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"OrderListFactory","CompilerVersion":"v0.4.18\u002Bcommit.9cf6e910","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://13381ff039378e3e8265895a5978056bf06c25b6f71c1e5a8dd7ade86af966f4"}]