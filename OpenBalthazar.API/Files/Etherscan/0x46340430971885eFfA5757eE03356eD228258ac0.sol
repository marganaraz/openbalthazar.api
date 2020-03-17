[{"SourceCode":"{\u0022EtherSwap.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.8;\\n\\nimport \\\u0022./Swap.sol\\\u0022;\\n\\n// solium-disable security/no-call-value\\ncontract EtherSwap is Swap {\\n    enum OrderState { HasFundingBalance, Claimed, Refunded }\\n\\n    struct SwapOrder {\\n        address payable user;\\n        bytes32 paymentHash;\\n        bytes32 preimage;\\n        uint onchainAmount;\\n        uint refundBlockHeight;\\n        OrderState state;\\n        bool exist;\\n    }\\n\\n    mapping(bytes16 =\\u003e SwapOrder) orders;\\n\\n    event OrderFundingReceived(bytes16 orderUUID, uint onchainAmount, bytes32 paymentHash, uint refundBlockHeight);\\n    event OrderClaimed(bytes16 orderUUID);\\n    event OrderRefunded(bytes16 orderUUID);\\n\\n    /**\\n     * Allow the sender to fund a swap in one or more transactions.\\n     */\\n    function fund(bytes16 orderUUID, bytes32 paymentHash) external payable {\\n        SwapOrder storage order = orders[orderUUID];\\n\\n        if (!order.exist) {\\n            order.user = msg.sender;\\n            order.exist = true;\\n            order.paymentHash = paymentHash;\\n            order.refundBlockHeight = block.number \u002B refundDelay;\\n            order.state = OrderState.HasFundingBalance;\\n            order.onchainAmount = 0;\\n        } else {\\n            require(order.state == OrderState.HasFundingBalance, \\\u0022Order already claimed or refunded.\\\u0022);\\n        }\\n        order.onchainAmount \u002B= msg.value;\\n\\n        emit OrderFundingReceived(orderUUID, order.onchainAmount, order.paymentHash, order.refundBlockHeight);\\n    }\\n\\n    /**\\n     * Allow the recipient to claim the funds once they know the preimage of the hashlock.\\n     * Anyone can claim but tokens only send to owner.\\n     */\\n    function claim(bytes16 orderUUID, bytes32 preimage) external {\\n        SwapOrder storage order = orders[orderUUID];\\n\\n        require(order.exist == true, \\\u0022Order does not exist.\\\u0022);\\n        require(order.state == OrderState.HasFundingBalance, \\\u0022Order cannot be claimed.\\\u0022);\\n        require(sha256(abi.encodePacked(preimage)) == order.paymentHash, \\\u0022Incorrect payment preimage.\\\u0022);\\n        require(block.number \\u003c= order.refundBlockHeight, \\\u0022Too late to claim.\\\u0022);\\n\\n        order.preimage = preimage;\\n        order.state = OrderState.Claimed;\\n\\n        (bool success, ) = owner.call.value(order.onchainAmount)(\\\u0022\\\u0022);\\n        require(success, \\\u0022Transfer failed.\\\u0022);\\n\\n        emit OrderClaimed(orderUUID);\\n    }\\n\\n    /**\\n     * Refund the sent amount back to the funder if the timelock has expired.\\n     */\\n    function refund(bytes16 orderUUID) external {\\n        SwapOrder storage order = orders[orderUUID];\\n\\n        require(order.exist == true, \\\u0022Order does not exist.\\\u0022);\\n        require(order.state == OrderState.HasFundingBalance, \\\u0022Order cannot be refunded.\\\u0022);\\n        require(block.number \\u003e order.refundBlockHeight, \\\u0022Too early to refund.\\\u0022);\\n\\n        order.state = OrderState.Refunded;\\n\\n        (bool success, ) = order.user.call.value(order.onchainAmount)(\\\u0022\\\u0022);\\n        require(success, \\\u0022Transfer failed.\\\u0022);\\n\\n        emit OrderRefunded(orderUUID);\\n    }\\n}\\n\u0022},\u0022Owned.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.8;\\n\\ncontract Owned {\\n    constructor() public { owner = msg.sender; }\\n    address payable public owner;\\n\\n    modifier onlyOwner {\\n        require(\\n            msg.sender == owner,\\n            \\\u0022Only owner can call this function.\\\u0022\\n        );\\n        _;\\n    }\\n}\\n\u0022},\u0022Swap.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.8;\\n\\nimport \\\u0022./Owned.sol\\\u0022;\\n\\ncontract Swap is Owned {\\n    // Refund delay. Default: 4 hours\\n    uint public refundDelay = 4 * 60 * 4;\\n\\n    // Max possible refund delay: 5 days\\n    uint constant MAX_REFUND_DELAY = 60 * 60 * 2 * 4;\\n\\n    /**\\n     * Set the block height at which a refund will successfully process.\\n     */\\n    function setRefundDelay(uint delay) external onlyOwner {\\n        require(delay \\u003c= MAX_REFUND_DELAY, \\\u0022Delay is too large.\\\u0022);\\n        refundDelay = delay;\\n    }\\n}\\n\u0022}}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022refundDelay\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022orderUUID\u0022,\u0022type\u0022:\u0022bytes16\u0022},{\u0022name\u0022:\u0022paymentHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022fund\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022delay\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setRefundDelay\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022orderUUID\u0022,\u0022type\u0022:\u0022bytes16\u0022},{\u0022name\u0022:\u0022preimage\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022claim\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022orderUUID\u0022,\u0022type\u0022:\u0022bytes16\u0022}],\u0022name\u0022:\u0022refund\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022orderUUID\u0022,\u0022type\u0022:\u0022bytes16\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022onchainAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022paymentHash\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022refundBlockHeight\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022OrderFundingReceived\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022orderUUID\u0022,\u0022type\u0022:\u0022bytes16\u0022}],\u0022name\u0022:\u0022OrderClaimed\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022orderUUID\u0022,\u0022type\u0022:\u0022bytes16\u0022}],\u0022name\u0022:\u0022OrderRefunded\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"EtherSwap","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://f997047520644312d9acf9755eef4ab3a00e09993a7415cf5bee2f2ef6e4b678"}]