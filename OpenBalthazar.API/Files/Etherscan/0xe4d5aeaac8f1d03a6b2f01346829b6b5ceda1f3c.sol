[{"SourceCode":"pragma solidity \u003E= 0.4.21 \u003C= 0.5.12;\r\n\r\n/*\r\n    Author : Biplav Raj Osti\r\n    LinkedIn : https://www.linkedin.com/in/biplav-osti/\r\n    \r\n    Note: Smart contract has not been audited. Use at your own risk.\r\n    Licensed under New BSD License (3-clause License)\r\n*/\r\n\r\nlibrary ECDSA {\r\n\r\n  /**\r\n   * @dev Recover signer address from a message by using their signature\r\n   * @param __hash bytes32 message, the hash is the signed message. What is recovered is the signer address.\r\n   * @param __signature bytes signature, the signature is generated using web3.eth.sign()\r\n   */\r\n  function recover(bytes32 __hash, bytes memory __signature)\r\n    internal\r\n    pure\r\n    returns (address)\r\n  {\r\n    bytes32 r;\r\n    bytes32 s;\r\n    uint8 v;\r\n\r\n    // Check the signature length\r\n    if (__signature.length != 65) {\r\n      return (address(0));\r\n    }\r\n\r\n    // Divide the signature in r, s and v variables with inline assembly.\r\n    assembly {\r\n      r := mload(add(__signature, 0x20))\r\n      s := mload(add(__signature, 0x40))\r\n      v := byte(0, mload(add(__signature, 0x60)))\r\n    }\r\n\r\n    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions\r\n    if (v \u003C 27) {\r\n      v \u002B= 27;\r\n    }\r\n\r\n    // If the version is correct return the signer address\r\n    if (v != 27 \u0026\u0026 v != 28) {\r\n      return (address(0));\r\n    } else {\r\n      // solium-disable-next-line arg-overflow\r\n      return ecrecover(__hash, v, r, s);\r\n    }\r\n  }  \r\n}\r\n\r\n/*\r\n    A registry of digital signatures.\r\n    primary usage could be signing through state channels where owner of signature signs a piece of message and sends it to the\r\n    receiver (consumer). The consumer can now use this signature as proof that he is authorized by the owner.\r\n    the consumer will register (consume) that signature in the DigitalSignatureRegistry. the signature is of only one time use in the chain.\r\n    The owner can choose whom to allow or deny to consume the signature.\r\n    Since each signature is of one time use only, this can act as nonce in non replayable meta transaction.\r\n*/\r\ncontract DigitalSignatureRegistry {\r\n    using ECDSA for bytes32;\r\n    \r\n    // when new Digital Signature is added/registered\r\n    event DSA(bytes signature, bytes32 message, address consumer);\r\n    \r\n    // owner allows third party to add/register a signed message by owner\r\n    event Allowance(address owner, address consumer);\r\n    \r\n    //owner revokes the ability of third party to submit a signed message\r\n    event Denial(address owner, address consumer);\r\n    \r\n    \r\n    // maps owner =\u003E consumer =\u003E bool ( owner can have multiple consumer)\r\n    mapping(address =\u003E mapping(address =\u003E bool)) _allowedTo;\r\n    \r\n    // mapping signature =\u003E consumer (used by) address\r\n    mapping(bytes =\u003E address) private _consumer;\r\n    \r\n    // mapping signature =\u003E message signed\r\n    mapping(bytes =\u003E bytes32) private _message;\r\n    \r\n    /*\r\n        Owner allows a consumer to submit a signature\r\n    */\r\n    function allow(address __consumer) public {\r\n        require(__consumer != address(0));\r\n        require(msg.sender != address(0));\r\n        \r\n        _allowedTo[msg.sender][__consumer] = true;\r\n        \r\n        emit Allowance(msg.sender, __consumer);\r\n    }\r\n    \r\n    /*\r\n        Owner revoke the allowance given to a consumer to submit signature\r\n    */\r\n    function deny(address __consumer) public {\r\n        require(__consumer != address(0));\r\n        require(msg.sender != address(0));\r\n        \r\n        _allowedTo[msg.sender][__consumer] = false;\r\n        \r\n        emit Denial(msg.sender, __consumer);\r\n    }\r\n    \r\n    /*\r\n       Owner or the allowed party can register a signaure signed only by owner. \r\n    */\r\n    function add(bytes memory __signature, bytes32 __message) public returns (bool) {\r\n        \r\n        // signature should not have been consumed already\r\n        require(_consumer[__signature] == address(0));\r\n        \r\n        // check sender to be not zero\r\n        require(msg.sender != address(0));\r\n        \r\n        //recover signer address from signature\r\n        address signer = __message.recover(__signature);\r\n        \r\n        // check consumer (msg.sender) is allowed by signer\r\n        require(msg.sender == signer || _allowedTo[signer][msg.sender]); \r\n        \r\n        // register consumer and message\r\n        _consumer[__signature] = msg.sender;\r\n        _message[__signature] = __message;\r\n        \r\n        //trigger DS Added event\r\n        emit DSA(__signature, __message, msg.sender);\r\n        \r\n        return true;\r\n    }\r\n    \r\n    // get consumer of a signature\r\n    function consumer(bytes memory __signature) public view returns (address) {\r\n        return _consumer[__signature];\r\n    }\r\n    \r\n    // get message hash of a signature\r\n    function message(bytes memory __signature) public view returns (bytes32) {\r\n        return _message[__signature];\r\n    }\r\n}","ABI":"[{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022consumer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Allowance\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022signature\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022consumer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022DSA\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022consumer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Denial\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022__signature\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022__message\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022add\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022__consumer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allow\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022__signature\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022consumer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022__consumer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022deny\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022__signature\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022message\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"DigitalSignatureRegistry","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://455214d3bc8d7b7391b1bebc12913cc7a45cd347978269d2eef81d345aee5568"}]