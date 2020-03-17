[{"SourceCode":"// File: contracts/IManager.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\ncontract IManager {\r\n    event SetController(address controller);\r\n    event ParameterUpdate(string param);\r\n\r\n    function setController(address _controller) external;\r\n}\r\n\r\n// File: contracts/zeppelin/Ownable.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n    address public owner;\r\n\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n\r\n    /**\r\n    * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n    * account.\r\n    */\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n\r\n    /**\r\n    * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n    * @param newOwner The address to transfer ownership to.\r\n    */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(owner, newOwner);\r\n        owner = newOwner;\r\n    }\r\n}\r\n\r\n// File: contracts/zeppelin/Pausable.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\n\r\n/**\r\n * @title Pausable\r\n * @dev Base contract which allows children to implement an emergency stop mechanism.\r\n */\r\ncontract Pausable is Ownable {\r\n    event Pause();\r\n    event Unpause();\r\n\r\n    bool public paused = false;\r\n\r\n\r\n    /**\r\n    * @dev Modifier to make a function callable only when the contract is not paused.\r\n    */\r\n    modifier whenNotPaused() {\r\n        require(!paused);\r\n        _;\r\n    }\r\n\r\n    /**\r\n    * @dev Modifier to make a function callable only when the contract is paused.\r\n    */\r\n    modifier whenPaused() {\r\n        require(paused);\r\n        _;\r\n    }\r\n\r\n    /**\r\n    * @dev called by the owner to pause, triggers stopped state\r\n    */\r\n    function pause() public onlyOwner whenNotPaused {\r\n        paused = true;\r\n        emit Pause();\r\n    }\r\n\r\n    /**\r\n    * @dev called by the owner to unpause, returns to normal state\r\n    */\r\n    function unpause() public onlyOwner whenPaused {\r\n        paused = false;\r\n        emit Unpause();\r\n    }\r\n}\r\n\r\n// File: contracts/IController.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\n\r\ncontract IController is Pausable {\r\n    event SetContractInfo(bytes32 id, address contractAddress, bytes20 gitCommitHash);\r\n\r\n    function setContractInfo(bytes32 _id, address _contractAddress, bytes20 _gitCommitHash) external;\r\n    function updateController(bytes32 _id, address _controller) external;\r\n    function getContract(bytes32 _id) public view returns (address);\r\n}\r\n\r\n// File: contracts/Manager.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\n\r\n\r\ncontract Manager is IManager {\r\n    // Controller that contract is registered with\r\n    IController public controller;\r\n\r\n    // Check if sender is controller\r\n    modifier onlyController() {\r\n        require(msg.sender == address(controller), \u0022caller must be Controller\u0022);\r\n        _;\r\n    }\r\n\r\n    // Check if sender is controller owner\r\n    modifier onlyControllerOwner() {\r\n        require(msg.sender == controller.owner(), \u0022caller must be Controller owner\u0022);\r\n        _;\r\n    }\r\n\r\n    // Check if controller is not paused\r\n    modifier whenSystemNotPaused() {\r\n        require(!controller.paused(), \u0022system is paused\u0022);\r\n        _;\r\n    }\r\n\r\n    // Check if controller is paused\r\n    modifier whenSystemPaused() {\r\n        require(controller.paused(), \u0022system is not paused\u0022);\r\n        _;\r\n    }\r\n\r\n    constructor(address _controller) public {\r\n        controller = IController(_controller);\r\n    }\r\n\r\n    /**\r\n     * @notice Set controller. Only callable by current controller\r\n     * @param _controller Controller contract address\r\n     */\r\n    function setController(address _controller) external onlyController {\r\n        controller = IController(_controller);\r\n\r\n        emit SetController(_controller);\r\n    }\r\n}\r\n\r\n// File: contracts/ManagerProxyTarget.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\n\r\n/**\r\n * @title ManagerProxyTarget\r\n * @notice The base contract that target contracts used by a proxy contract should inherit from\r\n * @dev Both the target contract and the proxy contract (implemented as ManagerProxy) MUST inherit from ManagerProxyTarget in order to guarantee\r\n that both contracts have the same storage layout. Differing storage layouts in a proxy contract and target contract can\r\n potentially break the delegate proxy upgradeability mechanism\r\n */\r\ncontract ManagerProxyTarget is Manager {\r\n    // Used to look up target contract address in controller\u0027s registry\r\n    bytes32 public targetContractId;\r\n}\r\n\r\n// File: contracts/ManagerProxy.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\n\r\n/**\r\n * @title ManagerProxy\r\n * @notice A proxy contract that uses delegatecall to execute function calls on a target contract using its own storage context.\r\n The target contract is a Manager contract that is registered with the Controller.\r\n * @dev Both this proxy contract and its target contract MUST inherit from ManagerProxyTarget in order to guarantee\r\n that both contracts have the same storage layout. Differing storage layouts in a proxy contract and target contract can\r\n potentially break the delegate proxy upgradeability mechanism. Since this proxy contract inherits from ManagerProxyTarget which inherits\r\n from Manager, it implements the setController() function. The target contract will also implement setController() since it also inherits\r\n from ManagerProxyTarget. Thus, any transaction sent to the proxy that calls setController() will execute against the proxy instead\r\n of the target. As a result, developers should keep in mind that the proxy will always execute the same logic for setController() regardless\r\n of the setController() implementation on the target contract. Generally, developers should not add any additional functions to this proxy contract\r\n because any function implemented on the proxy will always be executed against the proxy and the call **will not** be forwarded to the target contract\r\n */\r\ncontract ManagerProxy is ManagerProxyTarget {\r\n    /**\r\n     * @notice ManagerProxy constructor. Invokes constructor of base Manager contract with provided Controller address.\r\n     * Also, sets the contract ID of the target contract that function calls will be executed on.\r\n     * @param _controller Address of Controller that this contract will be registered with\r\n     * @param _targetContractId contract ID of the target contract\r\n     */\r\n    constructor(address _controller, bytes32 _targetContractId) public Manager(_controller) {\r\n        targetContractId = _targetContractId;\r\n    }\r\n\r\n    /**\r\n     * @notice Uses delegatecall to execute function calls on this proxy contract\u0027s target contract using its own storage context.\r\n     This fallback function will look up the address of the target contract using the Controller and the target contract ID.\r\n     It will then use the calldata for a function call as the data payload for a delegatecall on the target contract. The return value\r\n     of the executed function call will also be returned\r\n     */\r\n    function() external payable {\r\n        address target = controller.getContract(targetContractId);\r\n        require(\r\n            target != address(0),\r\n            \u0022target contract must be registered\u0022\r\n        );\r\n\r\n        assembly {\r\n            // Solidity keeps a free memory pointer at position 0x40 in memory\r\n            let freeMemoryPtrPosition := 0x40\r\n            // Load the free memory pointer\r\n            let calldataMemoryOffset := mload(freeMemoryPtrPosition)\r\n            // Update free memory pointer to after memory space we reserve for calldata\r\n            mstore(freeMemoryPtrPosition, add(calldataMemoryOffset, calldatasize))\r\n            // Copy calldata (method signature and params of the call) to memory\r\n            calldatacopy(calldataMemoryOffset, 0x0, calldatasize)\r\n\r\n            // Call method on target contract using calldata which is loaded into memory\r\n            let ret := delegatecall(gas, target, calldataMemoryOffset, calldatasize, 0, 0)\r\n\r\n            // Load the free memory pointer\r\n            let returndataMemoryOffset := mload(freeMemoryPtrPosition)\r\n            // Update free memory pointer to after memory space we reserve for returndata\r\n            mstore(freeMemoryPtrPosition, add(returndataMemoryOffset, returndatasize))\r\n            // Copy returndata (result of the method invoked by the delegatecall) to memory\r\n            returndatacopy(returndataMemoryOffset, 0x0, returndatasize)\r\n\r\n            switch ret\r\n            case 0 {\r\n                // Method call failed - revert\r\n                // Return any error message stored in mem[returndataMemoryOffset..(returndataMemoryOffset \u002B returndatasize)]\r\n                revert(returndataMemoryOffset, returndatasize)\r\n            } default {\r\n                // Return result of method call stored in mem[returndataMemoryOffset..(returndataMemoryOffset \u002B returndatasize)]\r\n                return(returndataMemoryOffset, returndatasize)\r\n            }\r\n        }\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022targetContractId\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_controller\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setController\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022controller\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract IController\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_controller\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_targetContractId\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022controller\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022SetController\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022param\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022ParameterUpdate\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"ManagerProxy","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000f96d54e490317c557a967abfa5d6e33006be69b3f16f832ef171c8058cbd4a32de7d27c32a1a1ad90bb091b4b7f376f1d95ee254","Library":"","SwarmSource":"bzzr://7d6755ba58f18df7224df8cea30bd7ec958d77f46b6a85677a1177ecf3e5f078"}]