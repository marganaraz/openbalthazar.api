[{"SourceCode":"pragma solidity ^0.5.11;\r\n\r\ncontract RsaBounty {\r\n\r\n    struct Challenge {\r\n        bytes modulus;\r\n        bool redeemed;\r\n        uint bounty;\r\n    }\r\n\r\n    uint constant CLAIM_DELAY = 1 days;\r\n\r\n    address owner;\r\n\r\n    mapping(uint =\u003E Challenge) public challenges;\r\n    uint public challenges_length;\r\n\r\n    mapping(bytes32 =\u003E uint256) public claims;\r\n\r\n    constructor () public payable {\r\n        owner = msg.sender;\r\n\r\n        challenges[0] = Challenge({\r\n        modulus: hex\u0022bdbbd27309fc78576ef48a2ed1fd835f9a35c4b23ab4191d476fc54245a04c588af1c7b600c5009bcc064b58afa126aa49eca0c7dc02a92b1750b833172e85226e88290494fc11f1fd3e78e788e5\u0022,\r\n        redeemed: false,\r\n        bounty: 1 ether\r\n        });\r\n\r\n        challenges[1] = Challenge({\r\n        modulus: hex\u00227e50b8b8b973dd6422b77048168d24729c96c1144b4982a7871598af00fd908d48541594d47bc80ae03db5ca666f8ceff7d36bafeff7701d0de71a79b552fac7a431928761a42d818697920a0c8274100fe3950fd2591c50888432c685ac2d5f\u0022,\r\n        redeemed: false,\r\n        bounty: 4 ether\r\n        });\r\n\r\n        challenges[2] = Challenge({\r\n        modulus: hex\u0022a8046dd12415b1ccf11d841a39a39287bf2c761c7779e8bfef7fa7886793ea326b9ecc7c4cb600688595e64b26ee45685919473bc09862f8783d24fea6433decc2500f724f0c26b0007f76af9cda8f9b3576acfa3206c3432f03358184259dbbd813032cfb21634d6df7957a1bf1676aeb90750d85f6715c351c595a14fe373b\u0022,\r\n        redeemed: false,\r\n        bounty: 8 ether\r\n        });\r\n\r\n        challenges[3] = Challenge({\r\n        modulus: hex\u00227efce54e174bb141d000b4375659f45ac1e3e9ccc1afcde85cc98b7b6ce626457361e90d1d9fe0af72ba63f3b0d20af8084bd6f981584af1e9197288811e72afaf488a1360e4d5d6f9b08220e16dd05860bd571e3171eb10dcc60241bf6f64cf03ddfb0556aa9a61e9850874e442564c020cf283813f5215d36281748b766ffa8a3486cd70686b5590d499a1a72d9baa87c0dc223c8f5b71d18fd24888b2872f0530be8cde0f7be8f591848bc210f2966dcaab6853d09bfd550ebdcd244c394cc83ac19ec75bf8b82774719555483cc2e3fbac3201c1aa518d25fdb37d50e56f3515ad5e4609d252fa7ded3b5123c0abc8a0ce137ef9989843d1452b87ccca6b\u0022,\r\n        redeemed: false,\r\n        bounty: 16 ether\r\n        });\r\n\r\n        challenges_length = 4;\r\n    }\r\n\r\n\r\n    // Expmod for small operands\r\n    function expmod(uint base, uint e, uint m) public view returns (uint o) {\r\n        assembly {\r\n            // Get free memory pointer\r\n            let p := mload(0x40)\r\n            // Store parameters for the Expmod (0x05) precompile\r\n            mstore(p, 0x20)             // Length of Base\r\n            mstore(add(p, 0x20), 0x20)  // Length of Exponent\r\n            mstore(add(p, 0x40), 0x20)  // Length of Modulus\r\n            mstore(add(p, 0x60), base)  // Base\r\n            mstore(add(p, 0x80), e)     // Exponent\r\n            mstore(add(p, 0xa0), m)     // Modulus\r\n\r\n            // Call 0x05 (EXPMOD) precompile\r\n            if iszero(staticcall(sub(gas, 2000), 0x05, p, 0xc0, p, 0x20)) {\r\n                revert(0, 0)\r\n            }\r\n            o := mload(p)\r\n        }\r\n    }\r\n\r\n    // Expmod for bignum operands (encoded as bytes, only base and modulus)\r\n    function bignum_expmod(bytes memory base, uint e, bytes memory m) public view returns (bytes memory o) {\r\n        assembly {\r\n            // Get free memory pointer\r\n            let p := mload(0x40)\r\n\r\n            // Get base length in bytes\r\n            let bl := mload(base)\r\n            // Get modulus length in bytes\r\n            let ml := mload(m)\r\n\r\n            // Store parameters for the Expmod (0x05) precompile\r\n            mstore(p, bl)               // Length of Base\r\n            mstore(add(p, 0x20), 0x20)  // Length of Exponent\r\n            mstore(add(p, 0x40), ml)    // Length of Modulus\r\n            // Use Identity (0x04) precompile to memcpy the base\r\n            if iszero(staticcall(10000, 0x04, add(base, 0x20), bl, add(p, 0x60), bl)) {\r\n                revert(0, 0)\r\n            }\r\n            mstore(add(p, add(0x60, bl)), e) // Exponent\r\n            // Use Identity (0x04) precompile to memcpy the modulus\r\n            if iszero(staticcall(10000, 0x04, add(m, 0x20), ml, add(add(p, 0x80), bl), ml)) {\r\n                revert(0, 0)\r\n            }\r\n            \r\n            // Call 0x05 (EXPMOD) precompile\r\n            if iszero(staticcall(sub(gas, 2000), 0x05, p, add(add(0x80, bl), ml), add(p, 0x20), ml)) {\r\n                revert(0, 0)\r\n            }\r\n\r\n            // Update free memory pointer\r\n            mstore(0x40, add(add(p, ml), 0x20))\r\n\r\n            // Store correct bytelength at p. This means that with the output\r\n            // of the Expmod precompile (which is stored as p \u002B 0x20)\r\n            // there is now a bytes array at location p\r\n            mstore(p, ml)\r\n\r\n            // Return p\r\n            o := p\r\n        }\r\n    }\r\n\r\n    uint constant miller_rabin_checks = 28;\r\n\r\n    // Use the Miller-Rabin test to check whether n\u003E3, odd is a prime\r\n    function miller_rabin_test(uint n) public view returns (bool) {\r\n        require(n \u003E 3);\r\n        require(n \u0026 0x1 == 1);\r\n        uint d = n - 1;\r\n        uint r = 0;\r\n        while(d \u0026 0x1 == 0) {\r\n            d /= 2;\r\n            r \u002B= 1;\r\n        }\r\n        for(uint i = 0; i \u003C miller_rabin_checks; i\u002B\u002B) {\r\n            // pick a random integer a in the range [2, n \u2212 2]\r\n            uint a = (uint256(sha256(abi.encodePacked(n, i))) % (n - 3)) \u002B 2;\r\n            uint x = expmod(a, d, n);\r\n            if(x == 1 || x == n - 1) {\r\n                continue;\r\n            }\r\n            bool check_passed = false;\r\n            for(uint j = 1; j \u003C r; j\u002B\u002B) {\r\n                x = mulmod(x, x, n);\r\n                if(x == n - 1) {\r\n                    check_passed = true;\r\n                    break;\r\n                }\r\n            }\r\n            if(!check_passed) {\r\n                return false;\r\n            }\r\n        }\r\n        return true;\r\n    }\r\n\r\n    // Need to submit a \u0022claim\u0022 for a bounty 24 hrs before redeeming\r\n    // This prevents front-running attacks\r\n    function claim_bounty(bytes32 claim_hash) public {\r\n        require(claims[claim_hash] == 0);\r\n        claims[claim_hash] = block.timestamp \u002B CLAIM_DELAY;\r\n    }\r\n\r\n    function max(uint a, uint b) private pure returns (uint) {\r\n        return a \u003E b ? a : b;\r\n    }\r\n\r\n    function bignum_getdigit(bytes memory x, uint i) private pure returns (uint8) {\r\n        if(i \u003E= x.length) {\r\n            return 0;\r\n        } else {\r\n            return uint8(x[x.length - i - 1]);\r\n        }\r\n    }\r\n\r\n    // Add two bignums encoded as bytes (very inefficient byte by byte method)\r\n    function bignum_add(bytes memory x, bytes memory y) public pure returns (bytes memory) {\r\n        uint newlength = max(x.length, y.length) \u002B 1;\r\n        bytes memory r = new bytes(newlength);\r\n        uint carry = 0;\r\n        for(uint i = 0; i \u003C newlength; i\u002B\u002B) {\r\n            uint8 a = bignum_getdigit(x, i);\r\n            uint8 b = bignum_getdigit(y, i);\r\n            uint sum = uint(a) \u002B uint(b) \u002B carry;\r\n            r[r.length - i - 1] = byte(uint8(sum));\r\n            carry = sum \u003E\u003E 8;\r\n            require(carry \u003C 2);\r\n        }\r\n        return r;\r\n    }\r\n\r\n    // Compares two bignums encoded as bytes (very inefficient byte by byte method)\r\n    function bignum_cmp(bytes memory x, bytes memory y) public pure returns (int) {\r\n        int maxdigit = int(max(x.length, y.length)) - 1;\r\n        for(int i = maxdigit; i \u003E= 0; i--) {\r\n            uint8 a = bignum_getdigit(x, uint(i));\r\n            uint8 b = bignum_getdigit(y, uint(i));\r\n            if(a \u003E b) {\r\n                return 1;\r\n            }\r\n            if(b \u003E a) {\r\n                return -1;\r\n            }\r\n        }\r\n        return 0;\r\n    }\r\n    \r\n    // Mask used for hash to prime\r\n    // Prime has to be the same as sha256(x) where mask is 1\r\n    uint constant prime_mask = 0x7fff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_f000;\r\n\r\n    function redeem_bounty(uint challenge_no, bytes memory x, bytes memory y, uint p) public {\r\n        require(challenge_no \u003C challenges_length);\r\n        require(!challenges[challenge_no].redeemed);\r\n\r\n        // Check claim has been made for this challenge\r\n        bytes32 claim_hash = sha256(abi.encodePacked(challenge_no, x, y, p, bytes32(uint256(msg.sender))));\r\n        require(claims[claim_hash] \u003E 0);\r\n        require(claims[claim_hash] \u003C block.timestamp);\r\n\r\n        // Check p is correct result for hash-to-prime\r\n        require(p \u0026 prime_mask == uint(sha256(x)) \u0026 prime_mask);\r\n        require(p \u003E (1 \u003C\u003C 255));\r\n        require(miller_rabin_test(p));\r\n\r\n        // Check 1 \u003C x \u003C m - 1\r\n        require(bignum_cmp(x, hex\u002201\u0022) == 1);\r\n        require(bignum_cmp(bignum_add(x, hex\u002201\u0022), challenges[challenge_no].modulus) == -1);\r\n\r\n        // Check y^p = x (mod m)\r\n        bytes memory expmod_result = bignum_expmod(y, p, challenges[challenge_no].modulus);\r\n        require(sha256(abi.encodePacked(expmod_result)) == sha256(abi.encodePacked(x)));\r\n        \r\n        challenges[challenge_no].redeemed = true;\r\n        msg.sender.transfer(challenges[challenge_no].bounty);\r\n    }\r\n    \r\n    \r\n    function terminate_contract() public {\r\n        require(msg.sender == owner);\r\n        selfdestruct(msg.sender);\r\n    }\r\n\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022x\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022y\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022bignum_add\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022x\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022y\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022bignum_cmp\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022int256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022int256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022base\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022e\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022m\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022bignum_expmod\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022o\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022challenges\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022modulus\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022redeemed\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022bounty\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022challenges_length\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022claim_hash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022claim_bounty\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022claims\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022base\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022e\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022m\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022expmod\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022o\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022n\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022miller_rabin_test\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022challenge_no\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022x\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022y\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022p\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022redeem_bounty\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022terminate_contract\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"RsaBounty","CompilerVersion":"v0.5.16\u002Bcommit.9c3226ce","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://a3e290cb5022034182e6edafe07759e8108bc6f47ddf68356428731ea4d7d3d5"}]