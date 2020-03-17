[{"SourceCode":"pragma solidity ^0.4.24;\r\n\r\ncontract Ownable {\r\n  address private _owner;\r\n\r\n\r\n  event OwnershipRenounced(address indexed previousOwner);\r\n  event OwnershipTransferred(\r\n    address indexed previousOwner,\r\n    address indexed newOwner\r\n  );\r\n\r\n\r\n  /**\r\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n   * account.\r\n   */\r\n  constructor() public {\r\n    _owner = msg.sender;\r\n  }\r\n\r\n  /**\r\n   * @return the address of the owner.\r\n   */\r\n  function owner() public view returns(address) {\r\n    return _owner;\r\n  }\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n  modifier onlyOwner() {\r\n    require(isOwner());\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @return true if \u0060msg.sender\u0060 is the owner of the contract.\r\n   */\r\n  function isOwner() public view returns(bool) {\r\n    return msg.sender == _owner;\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to relinquish control of the contract.\r\n   * @notice Renouncing to ownership will leave the contract without an owner.\r\n   * It will not be possible to call the functions with the \u0060onlyOwner\u0060\r\n   * modifier anymore.\r\n   */\r\n  function renounceOwnership() public onlyOwner {\r\n    emit OwnershipRenounced(_owner);\r\n    _owner = address(0);\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n   * @param newOwner The address to transfer ownership to.\r\n   */\r\n  function transferOwnership(address newOwner) public onlyOwner {\r\n    _transferOwnership(newOwner);\r\n  }\r\n\r\n  /**\r\n   * @dev Transfers control of the contract to a newOwner.\r\n   * @param newOwner The address to transfer ownership to.\r\n   */\r\n  function _transferOwnership(address newOwner) internal {\r\n    require(newOwner != address(0));\r\n    emit OwnershipTransferred(_owner, newOwner);\r\n    _owner = newOwner;\r\n  }\r\n}\r\n\r\n\r\ncontract Rlp {\r\n\r\n    uint256 constant ADDRESS_BYTES = 20;\r\n    uint256 constant MAX_SINGLE_BYTE = 128;\r\n    uint256 constant MAX_NONCE = 256**9 - 1;\r\n\r\n    // count number of bytes required to represent an unsigned integer\r\n    function count_bytes(uint256 n) pure internal returns (uint256 c) {\r\n        uint i = 0;\r\n        uint mask = 1;\r\n        while (n \u003E= mask) {\r\n            i \u002B= 1;\r\n            mask *= 256;\r\n        }\r\n\r\n        return i;\r\n    }\r\n\r\n    function mk_contract_address(address a, uint256 n) pure internal returns (address rlp) {\r\n        /*\r\n         * make sure the RLP encoding fits in one word:\r\n         * total_length      1 byte\r\n         * address_length    1 byte\r\n         * address          20 bytes\r\n         * nonce_length      1 byte (or 0)\r\n         * nonce           1-9 bytes\r\n         *                ==========\r\n         *                24-32 bytes\r\n         */\r\n        require(n \u003C= MAX_NONCE);\r\n\r\n        // number of bytes required to write down the nonce\r\n        uint256 nonce_bytes;\r\n        // length in bytes of the RLP encoding of the nonce\r\n        uint256 nonce_rlp_len;\r\n\r\n        if (0 \u003C n \u0026\u0026 n \u003C MAX_SINGLE_BYTE) {\r\n            // nonce fits in a single byte\r\n            // RLP(nonce) = nonce\r\n            nonce_bytes = 1;\r\n            nonce_rlp_len = 1;\r\n        } else {\r\n            // RLP(nonce) = [num_bytes_in_nonce nonce]\r\n            nonce_bytes = count_bytes(n);\r\n            nonce_rlp_len = nonce_bytes \u002B 1;\r\n        }\r\n\r\n        // [address_length(1) address(20) nonce_length(0 or 1) nonce(1-9)]\r\n        uint256 tot_bytes = 1 \u002B ADDRESS_BYTES \u002B nonce_rlp_len;\r\n\r\n        // concatenate all parts of the RLP encoding in the leading bytes of\r\n        // one 32-byte word\r\n        uint256 word = ((192 \u002B tot_bytes) * 256**31) \u002B\r\n                       ((128 \u002B ADDRESS_BYTES) * 256**30) \u002B\r\n                       (uint256(a) * 256**10);\r\n\r\n        if (0 \u003C n \u0026\u0026 n \u003C MAX_SINGLE_BYTE) {\r\n            word \u002B= n * 256**9;\r\n        } else {\r\n            word \u002B= (128 \u002B nonce_bytes) * 256**9;\r\n            word \u002B= n * 256**(9 - nonce_bytes);\r\n        }\r\n\r\n        uint256 hash;\r\n\r\n        assembly {\r\n            let mem_start := mload(0x40)        // get a pointer to free memory\r\n            mstore(mem_start, word)             // store the rlp encoding\r\n            hash := sha3(mem_start,\r\n                         add(tot_bytes, 1))     // hash the rlp encoding\r\n        }\r\n\r\n        // interpret hash as address (20 least significant bytes)\r\n        return address(hash);\r\n    }\r\n}\r\n\r\n\r\ncontract GasToken2 is Rlp {\r\n    //////////////////////////////////////////////////////////////////////////\r\n    // Generic ERC20\r\n    //////////////////////////////////////////////////////////////////////////\r\n\r\n    // owner -\u003E amount\r\n    mapping(address =\u003E uint256) s_balances;\r\n    // owner -\u003E spender -\u003E max amount\r\n    mapping(address =\u003E mapping(address =\u003E uint256)) s_allowances;\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n\r\n    // Spec: Get the account balance of another account with address \u0060owner\u0060\r\n    function balanceOf(address owner) public constant returns (uint256 balance) {\r\n        return s_balances[owner];\r\n    }\r\n\r\n    function internalTransfer(address from, address to, uint256 value) internal returns (bool success) {\r\n        if (value \u003C= s_balances[from]) {\r\n            s_balances[from] -= value;\r\n            s_balances[to] \u002B= value;\r\n            Transfer(from, to, value);\r\n            return true;\r\n        } else {\r\n            return false;\r\n        }\r\n    }\r\n\r\n    // Spec: Send \u0060value\u0060 amount of tokens to address \u0060to\u0060\r\n    function transfer(address to, uint256 value) public returns (bool success) {\r\n        address from = msg.sender;\r\n        return internalTransfer(from, to, value);\r\n    }\r\n\r\n    // Spec: Send \u0060value\u0060 amount of tokens from address \u0060from\u0060 to address \u0060to\u0060\r\n    function transferFrom(address from, address to, uint256 value) public returns (bool success) {\r\n        address spender = msg.sender;\r\n        if(value \u003C= s_allowances[from][spender] \u0026\u0026 internalTransfer(from, to, value)) {\r\n            s_allowances[from][spender] -= value;\r\n            return true;\r\n        } else {\r\n            return false;\r\n        }\r\n    }\r\n\r\n    // Spec: Allow \u0060spender\u0060 to withdraw from your account, multiple times, up\r\n    // to the \u0060value\u0060 amount. If this function is called again it overwrites the\r\n    // current allowance with \u0060value\u0060.\r\n    function approve(address spender, uint256 value) public returns (bool success) {\r\n        address owner = msg.sender;\r\n        if (value != 0 \u0026\u0026 s_allowances[owner][spender] != 0) {\r\n            return false;\r\n        }\r\n        s_allowances[owner][spender] = value;\r\n        Approval(owner, spender, value);\r\n        return true;\r\n    }\r\n\r\n    // Spec: Returns the \u0060amount\u0060 which \u0060spender\u0060 is still allowed to withdraw\r\n    // from \u0060owner\u0060.\r\n    // What if the allowance is higher than the balance of the \u0060owner\u0060?\r\n    // Callers should be careful to use min(allowance, balanceOf) to make sure\r\n    // that the allowance is actually present in the account!\r\n    function allowance(address owner, address spender) public constant returns (uint256 remaining) {\r\n        return s_allowances[owner][spender];\r\n    }\r\n\r\n    //////////////////////////////////////////////////////////////////////////\r\n    // GasToken specifics\r\n    //////////////////////////////////////////////////////////////////////////\r\n\r\n    uint8 constant public decimals = 2;\r\n    string constant public name = \u0022Gastoken.io\u0022;\r\n    string constant public symbol = \u0022GST2\u0022;\r\n\r\n    // We build a queue of nonces at which child contracts are stored. s_head is\r\n    // the nonce at the head of the queue, s_tail is the nonce behind the tail\r\n    // of the queue. The queue grows at the head and shrinks from the tail.\r\n    // Note that when and only when a contract CREATEs another contract, the\r\n    // creating contract\u0027s nonce is incremented.\r\n    // The first child contract is created with nonce == 1, the second child\r\n    // contract is created with nonce == 2, and so on...\r\n    // For example, if there are child contracts at nonces [2,3,4],\r\n    // then s_head == 4 and s_tail == 1. If there are no child contracts,\r\n    // s_head == s_tail.\r\n    uint256 s_head;\r\n    uint256 s_tail;\r\n\r\n    // totalSupply gives  the number of tokens currently in existence\r\n    // Each token corresponds to one child contract that can be SELFDESTRUCTed\r\n    // for a gas refund.\r\n    function totalSupply() public constant returns (uint256 supply) {\r\n        return s_head - s_tail;\r\n    }\r\n\r\n    // Creates a child contract that can only be destroyed by this contract.\r\n    function makeChild() internal returns (address addr) {\r\n        assembly {\r\n            // EVM assembler of runtime portion of child contract:\r\n            //     ;; Pseudocode: if (msg.sender != 0x0000000000b3f879cb30fe243b4dfee438691c04) { throw; }\r\n            //     ;;             suicide(msg.sender)\r\n            //     PUSH15 0xb3f879cb30fe243b4dfee438691c04 ;; hardcoded address of this contract\r\n            //     CALLER\r\n            //     XOR\r\n            //     PC\r\n            //     JUMPI\r\n            //     CALLER\r\n            //     SELFDESTRUCT\r\n            // Or in binary: 6eb3f879cb30fe243b4dfee438691c043318585733ff\r\n            // Since the binary is so short (22 bytes), we can get away\r\n            // with a very simple initcode:\r\n            //     PUSH22 0x6eb3f879cb30fe243b4dfee438691c043318585733ff\r\n            //     PUSH1 0\r\n            //     MSTORE ;; at this point, memory locations mem[10] through\r\n            //            ;; mem[31] contain the runtime portion of the child\r\n            //            ;; contract. all that\u0027s left to do is to RETURN this\r\n            //            ;; chunk of memory.\r\n            //     PUSH1 22 ;; length\r\n            //     PUSH1 10 ;; offset\r\n            //     RETURN\r\n            // Or in binary: 756eb3f879cb30fe243b4dfee438691c043318585733ff6000526016600af3\r\n            // Almost done! All we have to do is put this short (31 bytes) blob into\r\n            // memory and call CREATE with the appropriate offsets.\r\n            let solidity_free_mem_ptr := mload(0x40)\r\n            mstore(solidity_free_mem_ptr, 0x00756eb3f879cb30fe243b4dfee438691c043318585733ff6000526016600af3)\r\n            addr := create(0, add(solidity_free_mem_ptr, 1), 31)\r\n        }\r\n    }\r\n\r\n    // Mints \u0060value\u0060 new sub-tokens (e.g. cents, pennies, ...) by creating \u0060value\u0060\r\n    // new child contracts. The minted tokens are owned by the caller of this\r\n    // function.\r\n    function mint(uint256 value) public {\r\n        for (uint256 i = 0; i \u003C value; i\u002B\u002B) {\r\n            makeChild();\r\n        }\r\n        s_head \u002B= value;\r\n        s_balances[msg.sender] \u002B= value;\r\n    }\r\n\r\n    // Destroys \u0060value\u0060 child contracts and updates s_tail.\r\n    //\r\n    // This function is affected by an issue in solc: https://github.com/ethereum/solidity/issues/2999\r\n    // The \u0060mk_contract_address(this, i).call();\u0060 doesn\u0027t forward all available gas, but only GAS - 25710.\r\n    // As a result, when this line is executed with e.g. 30000 gas, the callee will have less than 5000 gas\r\n    // available and its SELFDESTRUCT operation will fail leading to no gas refund occurring.\r\n    // The remaining ~29000 gas left after the call is enough to update s_tail and the caller\u0027s balance.\r\n    // Hence tokens will have been destroyed without a commensurate gas refund.\r\n    // Fortunately, there is a simple workaround:\r\n    // Whenever you call free, freeUpTo, freeFrom, or freeUpToFrom, ensure that you pass at least\r\n    // 25710 \u002B \u0060value\u0060 * (1148 \u002B 5722 \u002B 150) gas. (It won\u0027t all be used)\r\n    function destroyChildren(uint256 value) internal {\r\n        uint256 tail = s_tail;\r\n        // tail points to slot behind the last contract in the queue\r\n        for (uint256 i = tail \u002B 1; i \u003C= tail \u002B value; i\u002B\u002B) {\r\n            mk_contract_address(this, i).call();\r\n        }\r\n\r\n        s_tail = tail \u002B value;\r\n    }\r\n\r\n    // Frees \u0060value\u0060 sub-tokens (e.g. cents, pennies, ...) belonging to the\r\n    // caller of this function by destroying \u0060value\u0060 child contracts, which\r\n    // will trigger a partial gas refund.\r\n    // You should ensure that you pass at least 25710 \u002B \u0060value\u0060 * (1148 \u002B 5722 \u002B 150) gas\r\n    // when calling this function. For details, see the comment above \u0060destroyChildren\u0060.\r\n    function free(uint256 value) public returns (bool success) {\r\n        uint256 from_balance = s_balances[msg.sender];\r\n        if (value \u003E from_balance) {\r\n            return false;\r\n        }\r\n\r\n        destroyChildren(value);\r\n\r\n        s_balances[msg.sender] = from_balance - value;\r\n\r\n        return true;\r\n    }\r\n\r\n    // Frees up to \u0060value\u0060 sub-tokens. Returns how many tokens were freed.\r\n    // Otherwise, identical to free.\r\n    // You should ensure that you pass at least 25710 \u002B \u0060value\u0060 * (1148 \u002B 5722 \u002B 150) gas\r\n    // when calling this function. For details, see the comment above \u0060destroyChildren\u0060.\r\n    function freeUpTo(uint256 value) public returns (uint256 freed) {\r\n        uint256 from_balance = s_balances[msg.sender];\r\n        if (value \u003E from_balance) {\r\n            value = from_balance;\r\n        }\r\n\r\n        destroyChildren(value);\r\n\r\n        s_balances[msg.sender] = from_balance - value;\r\n\r\n        return value;\r\n    }\r\n\r\n    // Frees \u0060value\u0060 sub-tokens owned by address \u0060from\u0060. Requires that \u0060msg.sender\u0060\r\n    // has been approved by \u0060from\u0060.\r\n    // You should ensure that you pass at least 25710 \u002B \u0060value\u0060 * (1148 \u002B 5722 \u002B 150) gas\r\n    // when calling this function. For details, see the comment above \u0060destroyChildren\u0060.\r\n    function freeFrom(address from, uint256 value) public returns (bool success) {\r\n        address spender = msg.sender;\r\n        uint256 from_balance = s_balances[from];\r\n        if (value \u003E from_balance) {\r\n            return false;\r\n        }\r\n\r\n        mapping(address =\u003E uint256) from_allowances = s_allowances[from];\r\n        uint256 spender_allowance = from_allowances[spender];\r\n        if (value \u003E spender_allowance) {\r\n            return false;\r\n        }\r\n\r\n        destroyChildren(value);\r\n\r\n        s_balances[from] = from_balance - value;\r\n        from_allowances[spender] = spender_allowance - value;\r\n\r\n        return true;\r\n    }\r\n\r\n    // Frees up to \u0060value\u0060 sub-tokens owned by address \u0060from\u0060. Returns how many tokens were freed.\r\n    // Otherwise, identical to \u0060freeFrom\u0060.\r\n    // You should ensure that you pass at least 25710 \u002B \u0060value\u0060 * (1148 \u002B 5722 \u002B 150) gas\r\n    // when calling this function. For details, see the comment above \u0060destroyChildren\u0060.\r\n    function freeFromUpTo(address from, uint256 value) public returns (uint256 freed) {\r\n        address spender = msg.sender;\r\n        uint256 from_balance = s_balances[from];\r\n        if (value \u003E from_balance) {\r\n            value = from_balance;\r\n        }\r\n\r\n        mapping(address =\u003E uint256) from_allowances = s_allowances[from];\r\n        uint256 spender_allowance = from_allowances[spender];\r\n        if (value \u003E spender_allowance) {\r\n            value = spender_allowance;\r\n        }\r\n\r\n        destroyChildren(value);\r\n\r\n        s_balances[from] = from_balance - value;\r\n        from_allowances[spender] = spender_allowance - value;\r\n\r\n        return value;\r\n    }\r\n}\r\n\r\ncontract GasSiphonWallet is Ownable {\r\n    \r\n    GasToken2 public gasToken;\r\n    uint public mintRate = 10;\r\n    \r\n    constructor(GasToken2 _gasToken) public {\r\n        gasToken = _gasToken;\r\n    }\r\n    \r\n    function() public payable {\r\n        mint(mintRate);\r\n        withdraw();\r\n    }\r\n    \r\n    function mint(uint _numTokens) internal {\r\n        gasToken.mint(_numTokens);\r\n    }\r\n    \r\n    function withdraw() internal {\r\n        uint bal = gasToken.balanceOf(address(this));\r\n        gasToken.transfer(msg.sender, bal);\r\n        msg.sender.transfer(this.balance);\r\n    }\r\n    \r\n    function setMintRate(uint _mintRate) public onlyOwner {\r\n        mintRate = _mintRate;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022gasToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022mintRate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_mintRate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setMintRate\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_gasToken\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipRenounced\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"GasSiphonWallet","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"0000000000000000000000000000000000b3f879cb30fe243b4dfee438691c04","Library":"","SwarmSource":"bzzr://d1b7964fb69dcdc4378786cc10754917246a2a27a77a59e460c845eb8e34af48"}]