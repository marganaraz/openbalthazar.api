[{"SourceCode":"pragma solidity ^0.5.8;\r\n\r\n\r\n/**\r\n * @title Owned\r\n * @dev Basic contract to define an owner.\r\n */\r\n\r\ncontract Owned {\r\n\r\n    // The owner\r\n    address public owner;\r\n\r\n    event OwnerChanged(address indexed _newOwner);\r\n\r\n    /// @dev Throws if the sender is not the owner.\r\n    modifier onlyOwner {\r\n        require(msg.sender == owner, \u0022Must be owner\u0022);\r\n        _;\r\n    }\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    /// @dev Return the ownership status of an address.\r\n    /// @param _potentialOwner Address being checked.\r\n    function isOwner(address _potentialOwner) external view returns (bool) {\r\n        return owner == _potentialOwner;\r\n    }\r\n\r\n    /// @dev Lets the owner transfer ownership of the contract to a new owner.\r\n    /// @param _newOwner The new owner.\r\n    function changeOwner(address _newOwner) external onlyOwner {\r\n        require(_newOwner != address(0), \u0022Address must not be null\u0022);\r\n        owner = _newOwner;\r\n        emit OwnerChanged(_newOwner);\r\n    }\r\n}\r\n\r\n/**\r\n * @title Managed\r\n * @dev Basic contract that defines a set of managers. Only the owner can add/remove managers.\r\n */\r\n\r\ncontract Managed is Owned {\r\n\r\n    // The managers\r\n    mapping (address =\u003E bool) public managers;\r\n\r\n    /// @dev Throws if the sender is not a manager.\r\n    modifier onlyManager {\r\n        require(managers[msg.sender] == true, \u0022Must be manager\u0022);\r\n        _;\r\n    }\r\n\r\n    event ManagerAdded(address indexed _manager);\r\n    event ManagerRevoked(address indexed _manager);\r\n\r\n    /// @dev Adds a manager.\r\n    /// @param _manager The address of the manager.\r\n    function addManager(address _manager) external onlyOwner {\r\n        require(_manager != address(0), \u0022Address must not be null\u0022);\r\n        if(managers[_manager] == false) {\r\n            managers[_manager] = true;\r\n            emit ManagerAdded(_manager);\r\n        }\r\n    }\r\n\r\n    /// @dev Revokes a manager.\r\n    /// @param _manager The address of the manager.\r\n    function revokeManager(address _manager) external onlyOwner {\r\n        require(managers[_manager] == true, \u0022Target must be an existing manager\u0022);\r\n        delete managers[_manager];\r\n        emit ManagerRevoked(_manager);\r\n    }\r\n}\r\n\r\n/**\r\n * ENS registry test contract.\r\n */\r\ncontract EnsRegistry {\r\n\r\n    struct Record {\r\n        address owner;\r\n        address resolver;\r\n        uint64 ttl;\r\n    }\r\n\r\n    mapping(bytes32=\u003ERecord) records;\r\n\r\n    // Logged when the owner of a node assigns a new owner to a subnode.\r\n    event NewOwner(bytes32 indexed _node, bytes32 indexed _label, address _owner);\r\n\r\n    // Logged when the owner of a node transfers ownership to a new account.\r\n    event Transfer(bytes32 indexed _node, address _owner);\r\n\r\n    // Logged when the resolver for a node changes.\r\n    event NewResolver(bytes32 indexed _node, address _resolver);\r\n\r\n    // Logged when the TTL of a node changes\r\n    event NewTTL(bytes32 indexed _node, uint64 _ttl);\r\n\r\n    // Permits modifications only by the owner of the specified node.\r\n    modifier only_owner(bytes32 _node) {\r\n        require(records[_node].owner == msg.sender, \u0022ENSTest: this method needs to be called by the owner of the node\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * Constructs a new ENS registrar.\r\n     */\r\n    constructor() public {\r\n        records[bytes32(0)].owner = msg.sender;\r\n    }\r\n\r\n    /**\r\n     * Returns the address that owns the specified node.\r\n     */\r\n    function owner(bytes32 _node) public view returns (address) {\r\n        return records[_node].owner;\r\n    }\r\n\r\n    /**\r\n     * Returns the address of the resolver for the specified node.\r\n     */\r\n    function resolver(bytes32 _node) public view returns (address) {\r\n        return records[_node].resolver;\r\n    }\r\n\r\n    /**\r\n     * Returns the TTL of a node, and any records associated with it.\r\n     */\r\n    function ttl(bytes32 _node) public view returns (uint64) {\r\n        return records[_node].ttl;\r\n    }\r\n\r\n    /**\r\n     * Transfers ownership of a node to a new address. May only be called by the current\r\n     * owner of the node.\r\n     * @param _node The node to transfer ownership of.\r\n     * @param _owner The address of the new owner.\r\n     */\r\n    function setOwner(bytes32 _node, address _owner) public only_owner(_node) {\r\n        emit Transfer(_node, _owner);\r\n        records[_node].owner = _owner;\r\n    }\r\n\r\n    /**\r\n     * Transfers ownership of a subnode sha3(node, label) to a new address. May only be\r\n     * called by the owner of the parent node.\r\n     * @param _node The parent node.\r\n     * @param _label The hash of the label specifying the subnode.\r\n     * @param _owner The address of the new owner.\r\n     */\r\n    function setSubnodeOwner(bytes32 _node, bytes32 _label, address _owner) public only_owner(_node) {\r\n        bytes32 subnode = keccak256(abi.encodePacked(_node, _label));\r\n        emit NewOwner(_node, _label, _owner);\r\n        records[subnode].owner = _owner;\r\n    }\r\n\r\n    /**\r\n     * Sets the resolver address for the specified node.\r\n     * @param _node The node to update.\r\n     * @param _resolver The address of the resolver.\r\n     */\r\n    function setResolver(bytes32 _node, address _resolver) public only_owner(_node) {\r\n        emit NewResolver(_node, _resolver);\r\n        records[_node].resolver = _resolver;\r\n    }\r\n\r\n    /**\r\n     * Sets the TTL for the specified node.\r\n     * @param _node The node to update.\r\n     * @param _ttl The TTL in seconds.\r\n     */\r\n    function setTTL(bytes32 _node, uint64 _ttl) public only_owner(_node) {\r\n        emit NewTTL(_node, _ttl);\r\n        records[_node].ttl = _ttl;\r\n    }\r\n}\r\n\r\n/**\r\n * ENS Resolver interface.\r\n */\r\ncontract EnsResolver {\r\n    function setName(bytes32 _node, string calldata _name) external {}\r\n}\r\n\r\n/**\r\n * ENS Reverse registrar test contract.\r\n */\r\ncontract EnsReverseRegistrar {\r\n   // namehash(\u0027addr.reverse\u0027)\r\n    bytes32 constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;\r\n\r\n    EnsRegistry public ens;\r\n    EnsResolver public defaultResolver;\r\n\r\n    /**\r\n     * @dev Constructor\r\n     * @param ensAddr The address of the ENS registry.\r\n     * @param resolverAddr The address of the default reverse resolver.\r\n     */\r\n    constructor(address ensAddr, address resolverAddr) public {\r\n        ens = EnsRegistry(ensAddr);\r\n        defaultResolver = EnsResolver(resolverAddr);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the reverse ENS record associated with the\r\n     *      calling account.\r\n     * @param owner The address to set as the owner of the reverse record in ENS.\r\n     * @return The ENS node hash of the reverse record.\r\n     */\r\n    function claim(address owner) public returns (bytes32) {\r\n        return claimWithResolver(owner, address(0));\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the reverse ENS record associated with the\r\n     *      calling account.\r\n     * @param owner The address to set as the owner of the reverse record in ENS.\r\n     * @param resolver The address of the resolver to set; 0 to leave unchanged.\r\n     * @return The ENS node hash of the reverse record.\r\n     */\r\n    function claimWithResolver(address owner, address resolver) public returns (bytes32) {\r\n        bytes32 label = sha3HexAddress(msg.sender);\r\n        bytes32 node = keccak256(abi.encodePacked(ADDR_REVERSE_NODE, label));\r\n        address currentOwner = ens.owner(node);\r\n\r\n        // Update the resolver if required\r\n        if(resolver != address(0) \u0026\u0026 resolver != address(ens.resolver(node))) {\r\n            // Transfer the name to us first if it\u0027s not already\r\n            if(currentOwner != address(this)) {\r\n                ens.setSubnodeOwner(ADDR_REVERSE_NODE, label, address(this));\r\n                currentOwner = address(this);\r\n            }\r\n            ens.setResolver(node, resolver);\r\n        }\r\n\r\n        // Update the owner if required\r\n        if(currentOwner != owner) {\r\n            ens.setSubnodeOwner(ADDR_REVERSE_NODE, label, owner);\r\n        }\r\n\r\n        return node;\r\n    }\r\n\r\n    /**\r\n     * @dev Sets the \u0060name()\u0060 record for the reverse ENS record associated with\r\n     * the calling account. First updates the resolver to the default reverse\r\n     * resolver if necessary.\r\n     * @param name The name to set for this address.\r\n     * @return The ENS node hash of the reverse record.\r\n     */\r\n    function setName(string memory name) public returns (bytes32 node) {\r\n        node = claimWithResolver(address(this), address(defaultResolver));\r\n        defaultResolver.setName(node, name);\r\n        return node;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the node hash for a given account\u0027s reverse records.\r\n     * @param addr The address to hash\r\n     * @return The ENS node hash.\r\n     */\r\n    function node(address addr) public returns (bytes32 ret) {\r\n        return keccak256(abi.encodePacked(ADDR_REVERSE_NODE, sha3HexAddress(addr)));\r\n    }\r\n\r\n    /**\r\n     * @dev An optimised function to compute the sha3 of the lower-case\r\n     *      hexadecimal representation of an Ethereum address.\r\n     * @param addr The address to hash\r\n     * @return The SHA3 hash of the lower-case hexadecimal encoding of the\r\n     *         input address.\r\n     */\r\n    function sha3HexAddress(address addr) private returns (bytes32 ret) {\r\n        assembly {\r\n            let lookup := 0x3031323334353637383961626364656600000000000000000000000000000000\r\n            let i := 40\r\n\r\n            for { } gt(i, 0) { } {\r\n                i := sub(i, 1)\r\n                mstore8(i, byte(and(addr, 0xf), lookup))\r\n                addr := div(addr, 0x10)\r\n                i := sub(i, 1)\r\n                mstore8(i, byte(and(addr, 0xf), lookup))\r\n                addr := div(addr, 0x10)\r\n            }\r\n            ret := keccak256(0, 40)\r\n        }\r\n    }\r\n}\r\n\r\n\r\n/**\r\n * @title AuthereumEnsResolver\r\n * @dev Authereum implementation of a Resolver.\r\n */\r\n\r\ncontract AuthereumEnsResolver is Managed {\r\n\r\n    bytes4 constant INTERFACE_META_ID = 0x01ffc9a7;\r\n    bytes4 constant ADDR_INTERFACE_ID = 0x3b3b57de;\r\n    bytes4 constant NAME_INTERFACE_ID = 0x691f3431;\r\n\r\n    event AddrChanged(bytes32 indexed node, address a);\r\n    event NameChanged(bytes32 indexed node, string name);\r\n\r\n    struct Record {\r\n        address addr;\r\n        string name;\r\n    }\r\n\r\n    EnsRegistry ens;\r\n    mapping (bytes32 =\u003E Record) records;\r\n    address public authereumEnsManager;\r\n    address public timelockContract;\r\n\r\n    /// @dev Constructor\r\n    /// @param ensAddr The ENS registrar contract.\r\n    /// @param _timelockContract Authereum timelock contract address\r\n    constructor(EnsRegistry ensAddr, address _timelockContract) public {\r\n        ens = ensAddr;\r\n        timelockContract = _timelockContract;\r\n    }\r\n\r\n    /**\r\n     * Setters\r\n     */\r\n\r\n    /// @dev Sets the address associated with an ENS node.\r\n    /// @notice May only be called by the owner of that node in the ENS registry.\r\n    /// @param node The node to update.\r\n    /// @param addr The address to set.\r\n    function setAddr(bytes32 node, address addr) public onlyManager {\r\n        records[node].addr = addr;\r\n        emit AddrChanged(node, addr);\r\n    }\r\n\r\n    /// @dev Sets the name associated with an ENS node, for reverse records.\r\n    /// @notice May only be called by the owner of that node in the ENS registry.\r\n    /// @param node The node to update.\r\n    /// @param name The name to set.\r\n    function setName(bytes32 node, string memory name) public onlyManager {\r\n        records[node].name = name;\r\n        emit NameChanged(node, name);\r\n    }\r\n\r\n    /**\r\n     * Getters\r\n     */\r\n\r\n    /// @dev Returns the address associated with an ENS node.\r\n    /// @param node The ENS node to query.\r\n    /// @return The associated address.\r\n    function addr(bytes32 node) public view returns (address) {\r\n        return records[node].addr;\r\n    }\r\n\r\n    /// @dev Returns the name associated with an ENS node, for reverse records.\r\n    /// @notice Defined in EIP181.\r\n    /// @param node The ENS node to query.\r\n    /// @return The associated name.\r\n    function name(bytes32 node) public view returns (string memory) {\r\n        return records[node].name;\r\n    }\r\n\r\n    /// @dev Returns true if the resolver implements the interface specified by the provided hash.\r\n    /// @param interfaceID The ID of the interface to check for.\r\n    /// @return True if the contract implements the requested interface.\r\n    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {\r\n        return interfaceID == INTERFACE_META_ID ||\r\n        interfaceID == ADDR_INTERFACE_ID ||\r\n        interfaceID == NAME_INTERFACE_ID;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022interfaceID\u0022,\u0022type\u0022:\u0022bytes4\u0022}],\u0022name\u0022:\u0022supportsInterface\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_manager\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addManager\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_potentialOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_manager\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022revokeManager\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022node\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022addr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022authereumEnsManager\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022node\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022node\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022setName\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022changeOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022timelockContract\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022node\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setAddr\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022managers\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022ensAddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_timelockContract\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022node\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022AddrChanged\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022node\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022NameChanged\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_manager\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022ManagerAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_manager\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022ManagerRevoked\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnerChanged\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"AuthereumEnsResolver","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000314159265dd8dbb310642f98f50c066173c1259b000000000000000000000000a80000228cf1a6d4d267aa7ea2ba5841d1952d1c","Library":"","SwarmSource":"bzzr://95f49cbf15c82928976a2220b2bae4744f2be114fb96450f148b96aca4f2d023"}]