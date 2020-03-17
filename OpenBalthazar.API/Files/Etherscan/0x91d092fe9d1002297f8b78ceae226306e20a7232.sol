[{"SourceCode":"pragma solidity ^0.5.11;\r\n\r\ncontract LegendreBounty {\r\n\r\n    struct Challenge {\r\n        uint check_value;\r\n        uint check_length;\r\n        uint prime;\r\n        uint bounty;\r\n        bool redeemed;\r\n    }\r\n\r\n    uint constant LEGENDRE_BIT_MULTI_MAX = 256;\r\n    uint constant HOUR = 3600;\r\n    uint constant DAY = 24 * HOUR;\r\n    uint constant CLAIM_DELAY = 1 * DAY;\r\n\r\n    address owner;\r\n\r\n    mapping(uint =\u003E Challenge) public challenges;\r\n    uint public challenges_length;\r\n\r\n    mapping(bytes32 =\u003E uint256) public claims;\r\n\r\n\r\n    constructor () public payable {\r\n        owner = msg.sender;\r\n        // Real challenges\r\n        challenges[0] = Challenge({check_value: 0x00000000000000000000000000000000574fb3b032a69799873a3335cf928752,\r\n                            check_length: 128,\r\n                            prime: 0x000000000000000000000000000000000000000000000000ffffffffffffffc5,\r\n                            bounty: 1000000000000000000,\r\n                            redeemed: true});\r\n        challenges[1] = Challenge({check_value: 0x0000000000000000000000000005bfc5abb616dcb96eb812884d9be93ef9f42e,\r\n                            check_length: 148,\r\n                            prime: 0x0000000000000000000000000000000000000000000003ffffffffffffffffdd,\r\n                            bounty: 2000000000000000000,\r\n                            redeemed: false});\r\n        challenges[2] = Challenge({check_value: 0x000000000000000000000000000bafca94ade9b5201633be31512efcaec7cbe6,\r\n                            check_length: 148,\r\n                            prime: 0x0000000000000000000000000000000000000000000fffffffffffffffffffdd,\r\n                            bounty: 4000000000000000000,\r\n                            redeemed: false});\r\n        challenges[3] = Challenge({check_value: 0x0000000000000000000000000008544ea9871766a120112b6106bb0a2e6e34c5,\r\n                            check_length: 148,\r\n                            prime: 0x000000000000000000000000000000000000000ffffffffffffffffffffffff1,\r\n                            bounty: 8000000000000000000,\r\n                            redeemed: false});\r\n        challenges[4] = Challenge({check_value: 0x000000000000000000000000000aaf064eee3a15f46755777368a8abc00f274e,\r\n                            check_length: 148,\r\n                            prime: 0x000000000000000000000000000fffffffffffffffffffffffffffffffffff59,\r\n                            bounty: 16000000000000000000,\r\n                            redeemed: false});\r\n        challenges_length = 5;\r\n    }\r\n\r\n\r\n    function expmod(uint base, uint e, uint m) private view returns (uint o) {\r\n        assembly {\r\n            // define pointer\r\n            let p := mload(0x40)\r\n            // store data assembly-favouring ways\r\n            mstore(p, 0x20)             // Length of Base\r\n            mstore(add(p, 0x20), 0x20)  // Length of Exponent\r\n            mstore(add(p, 0x40), 0x20)  // Length of Modulus\r\n            mstore(add(p, 0x60), base)  // Base\r\n            mstore(add(p, 0x80), e)     // Exponent\r\n            mstore(add(p, 0xa0), m)     // Modulus\r\n            if iszero(staticcall(sub(gas, 2000), 0x05, p, 0xc0, p, 0x20)) {\r\n                revert(0, 0)\r\n            }\r\n            // data\r\n            o := mload(p)\r\n        }\r\n    }\r\n    \r\n    \r\n    function legendre_bit(uint input_a, uint q) private view returns (uint) {\r\n        uint a = input_a;\r\n        if(a \u003E= q) {\r\n            a = a % q;\r\n        }\r\n        if(a == 0) {\r\n            return 1;\r\n        }\r\n    \r\n        require(q \u003E a \u0026\u0026 q \u0026 1 == 1);\r\n    \r\n        uint e = (q - 1) / 2;\r\n    \r\n        // Call expmod precompile\r\n        uint c = expmod(a, e, q);\r\n    \r\n        if(c == q - 1) {\r\n            return 0;\r\n        }\r\n        return 1;\r\n    }\r\n    \r\n    \r\n    function legendre_bit_multi(uint input_a, uint q, uint n) public view returns (uint) {\r\n        uint a = input_a;\r\n        uint r = 0;\r\n        require(n \u003C LEGENDRE_BIT_MULTI_MAX);\r\n        for(uint i = 0; i \u003C n; i\u002B\u002B) {\r\n            r = r \u003C\u003C 1;\r\n            r = r ^ legendre_bit(a, q);\r\n            a \u002B= 1;\r\n        }\r\n        return r;\r\n    }\r\n    \r\n    \r\n    function claim_bounty(bytes32 claim_hash) public {\r\n        require(claims[claim_hash] == 0);\r\n        claims[claim_hash] = block.timestamp \u002B CLAIM_DELAY;\r\n    }\r\n    \r\n    \r\n    function redeem_bounty(uint challenge_no, uint key) public {\r\n        require(challenge_no \u003C challenges_length);\r\n        require(!challenges[challenge_no].redeemed);\r\n    \r\n        bytes32 claim_hash = sha256(abi.encodePacked(bytes32(key), bytes32(uint256(msg.sender))));\r\n        require(claims[claim_hash] \u003E 0);\r\n        require(claims[claim_hash] \u003C block.timestamp);\r\n    \r\n        uint check_value = legendre_bit_multi(key, challenges[challenge_no].prime, challenges[challenge_no].check_length);\r\n        require(check_value == challenges[challenge_no].check_value);\r\n        challenges[challenge_no].redeemed = true;\r\n        msg.sender.transfer(challenges[challenge_no].bounty);\r\n    }\r\n    \r\n    \r\n    function terminate_contract() public {\r\n        require(msg.sender == owner);\r\n        selfdestruct(msg.sender);\r\n    }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022challenges_length\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022challenge_no\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022key\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022redeem_bounty\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022claim_hash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022claim_bounty\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022terminate_contract\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022challenges\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022check_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022check_length\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022prime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022bounty\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022redeemed\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022input_a\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022q\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022n\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022legendre_bit_multi\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022claims\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"LegendreBounty","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://0bc11bc407eb003523ce76c8447d5dee517b9f278abd7a83a6134d55991d13df"}]