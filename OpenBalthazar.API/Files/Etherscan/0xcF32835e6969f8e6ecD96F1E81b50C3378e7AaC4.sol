[{"SourceCode":"{\u0022Base.sol\u0022:{\u0022content\u0022:\u0022/*\\n  Copyright 2019 StarkWare Industries Ltd.\\n\\n  Licensed under the Apache License, Version 2.0 (the \\\u0022License\\\u0022).\\n  You may not use this file except in compliance with the License.\\n  You may obtain a copy of the License at\\n\\n  https://www.starkware.co/open-source-license/\\n\\n  Unless required by applicable law or agreed to in writing,\\n  software distributed under the License is distributed on an \\\u0022AS IS\\\u0022 BASIS,\\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\\n  See the License for the specific language governing permissions\\n  and limitations under the License.\\n*/\\n\\npragma solidity ^0.5.2;\\n\\n\\ncontract Base {\\n    event LogString(string str);\\n\\n    address payable internal operator;\\n    uint256 constant internal MINIMUM_TIME_TO_REVEAL = 1 days;\\n    uint256 constant internal TIME_TO_ALLOW_REVOKE = 7 days;\\n    bool internal isRevokeStarted = false;\\n    uint256 internal revokeTime = 0; // The time from which we can revoke.\\n    bool internal active = true;\\n\\n    // mapping: (address, commitment) -\\u003e time\\n    // Times from which the users may claim the reward.\\n    mapping (address =\\u003e mapping (bytes32 =\\u003e uint256)) private reveal_timestamps;\\n\\n\\n    constructor ()\\n        internal\\n    {\\n        operator = msg.sender;\\n    }\\n\\n    modifier onlyOperator()\\n    {\\n        require(msg.sender == operator, \\\u0022ONLY_OPERATOR\\\u0022);\\n        _; // The _; defines where the called function is executed.\\n    }\\n\\n    function register(bytes32 commitment)\\n        public\\n    {\\n        require(reveal_timestamps[msg.sender][commitment] == 0, \\\u0022Entry already registered.\\\u0022);\\n        reveal_timestamps[msg.sender][commitment] = now \u002B MINIMUM_TIME_TO_REVEAL;\\n    }\\n\\n\\n    /*\\n      Makes sure that the commitment was registered at least MINIMUM_TIME_TO_REVEAL before\\n      the current time.\\n    */\\n    function verifyTimelyRegistration(bytes32 commitment)\\n        internal view\\n    {\\n        uint256 registrationMaturationTime = reveal_timestamps[msg.sender][commitment];\\n        require(registrationMaturationTime != 0, \\\u0022Commitment is not registered.\\\u0022);\\n        require(now \\u003e= registrationMaturationTime, \\\u0022Time for reveal has not passed yet.\\\u0022);\\n    }\\n\\n\\n    /*\\n      WARNING: This function should only be used with call() and not transact().\\n      Creating a transaction that invokes this function might reveal the collision and make it\\n      subject to front-running.\\n    */\\n    function calcCommitment(uint256[] memory firstInput, uint256[] memory secondInput)\\n        public view\\n        returns (bytes32 commitment)\\n    {\\n        address sender = msg.sender;\\n        uint256 firstLength = firstInput.length;\\n        uint256 secondLength = secondInput.length;\\n        uint256[] memory hash_elements = new uint256[](1 \u002B firstLength \u002B secondLength);\\n        hash_elements[0] = uint256(sender);\\n        uint256 offset = 1;\\n        for (uint256 i = 0; i \\u003c firstLength; i\u002B\u002B) {\\n            hash_elements[offset \u002B i] = firstInput[i];\\n        }\\n        offset = 1 \u002B firstLength;\\n        for (uint256 i = 0; i \\u003c secondLength; i\u002B\u002B) {\\n            hash_elements[offset \u002B i] = secondInput[i];\\n        }\\n        commitment = keccak256(abi.encodePacked(hash_elements));\\n    }\\n\\n    function claimReward(\\n        uint256[] memory firstInput,\\n        uint256[] memory secondInput,\\n        string memory solutionDescription,\\n        string memory name)\\n        public\\n    {\\n        require(active == true, \\\u0022This challenge is no longer active. Thank you for participating.\\\u0022);\\n        require(firstInput.length \\u003e 0, \\\u0022First input cannot be empty.\\\u0022);\\n        require(secondInput.length \\u003e 0, \\\u0022Second input cannot be empty.\\\u0022);\\n        require(firstInput.length == secondInput.length, \\\u0022Input lengths are not equal.\\\u0022);\\n        uint256 inputLength = firstInput.length;\\n        bool sameInput = true;\\n        for (uint256 i = 0; i \\u003c inputLength; i\u002B\u002B) {\\n            if (firstInput[i] != secondInput[i]) {\\n                sameInput = false;\\n            }\\n        }\\n        require(sameInput == false, \\\u0022Inputs are equal.\\\u0022);\\n        bool sameHash = true;\\n        uint256[] memory firstHash = applyHash(firstInput);\\n        uint256[] memory secondHash = applyHash(secondInput);\\n        require(firstHash.length == secondHash.length, \\\u0022Output lengths are not equal.\\\u0022);\\n        uint256 outputLength = firstHash.length;\\n        for (uint256 i = 0; i \\u003c outputLength; i\u002B\u002B) {\\n            if (firstHash[i] != secondHash[i]) {\\n                sameHash = false;\\n            }\\n        }\\n        require(sameHash == true, \\\u0022Not a collision.\\\u0022);\\n        verifyTimelyRegistration(calcCommitment(firstInput, secondInput));\\n\\n        active = false;\\n        emit LogString(solutionDescription);\\n        emit LogString(name);\\n        msg.sender.transfer(address(this).balance);\\n    }\\n\\n    function applyHash(uint256[] memory elements)\\n        public view\\n        returns (uint256[] memory elementsHash)\\n    {\\n        elementsHash = sponge(elements);\\n    }\\n\\n    function startRevoke()\\n        public\\n        onlyOperator()\\n    {\\n        require(isRevokeStarted == false, \\\u0022Revoke already started.\\\u0022);\\n        isRevokeStarted = true;\\n        revokeTime = now \u002B TIME_TO_ALLOW_REVOKE;\\n    }\\n\\n    function revokeReward()\\n        public\\n        onlyOperator()\\n    {\\n        require(isRevokeStarted == true, \\\u0022Revoke not started yet.\\\u0022);\\n        require(now \\u003e= revokeTime, \\\u0022Revoke time not passed.\\\u0022);\\n        active = false;\\n        operator.transfer(address(this).balance);\\n    }\\n\\n    function sponge(uint256[] memory inputs)\\n        internal view\\n        returns (uint256[] memory outputElements);\\n\\n    function getStatus()\\n        public view\\n        returns (bool[] memory status)\\n    {\\n        status = new bool[](2);\\n        status[0] = isRevokeStarted;\\n        status[1] = active;\\n    }\\n}\\n\u0022},\u0022Sponge.sol\u0022:{\u0022content\u0022:\u0022/*\\n  Copyright 2019 StarkWare Industries Ltd.\\n\\n  Licensed under the Apache License, Version 2.0 (the \\\u0022License\\\u0022).\\n  You may not use this file except in compliance with the License.\\n  You may obtain a copy of the License at\\n\\n  https://www.starkware.co/open-source-license/\\n\\n  Unless required by applicable law or agreed to in writing,\\n  software distributed under the License is distributed on an \\\u0022AS IS\\\u0022 BASIS,\\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\\n  See the License for the specific language governing permissions\\n  and limitations under the License.\\n*/\\n\\npragma solidity ^0.5.2;\\n\\n\\ncontract Sponge {\\n    uint256 prime;\\n    uint256 r;\\n    uint256 c;\\n    uint256 m;\\n    uint256 outputSize;\\n    uint256 nRounds;\\n\\n    constructor (uint256 prime_, uint256 r_, uint256 c_, uint256 nRounds_)\\n        public\\n    {\\n        prime = prime_;\\n        r = r_;\\n        c = c_;\\n        m = r \u002B c;\\n        outputSize = c;\\n        nRounds = nRounds_;\\n    }\\n\\n    function LoadAuxdata()\\n        internal view\\n        returns (uint256[] memory /*auxdata*/);\\n\\n    function permutation_func(uint256[] memory /*auxdata*/, uint256[] memory /*elements*/)\\n        internal view\\n        returns (uint256[] memory /*hash_elements*/);\\n\\n    function sponge(uint256[] memory inputs)\\n        internal view\\n        returns (uint256[] memory outputElements)\\n    {\\n        uint256 inputLength = inputs.length;\\n        for (uint256 i = 0; i \\u003c inputLength; i\u002B\u002B) {\\n            require(inputs[i] \\u003c prime, \\\u0022elements do not belong to the field\\\u0022);\\n        }\\n\\n        require(inputLength % r == 0, \\\u0022Number of field elements is not divisible by r.\\\u0022);\\n\\n        uint256[] memory state = new uint256[](m);\\n        for (uint256 i = 0; i \\u003c m; i\u002B\u002B) {\\n            state[i] = 0; // fieldZero.\\n        }\\n\\n        uint256[] memory auxData = LoadAuxdata();\\n        uint256 n_columns = inputLength / r;\\n        for (uint256 i = 0; i \\u003c n_columns; i\u002B\u002B) {\\n            for (uint256 j = 0; j \\u003c r; j\u002B\u002B) {\\n                state[j] = addmod(state[j], inputs[i * r \u002B j], prime);\\n            }\\n            state = permutation_func(auxData, state);\\n        }\\n\\n        require(outputSize \\u003c= r, \\\u0022No support for more than r output elements.\\\u0022);\\n        outputElements = new uint256[](outputSize);\\n        for (uint256 i = 0; i \\u003c outputSize; i\u002B\u002B) {\\n            outputElements[i] = state[i];\\n        }\\n    }\\n\\n    function getParameters()\\n        public view\\n        returns (uint256[] memory status)\\n    {\\n        status = new uint256[](4);\\n        status[0] = prime;\\n        status[1] = r;\\n        status[2] = c;\\n        status[3] = nRounds;\\n    }\\n}\\n\u0022},\u0022STARK_Friendly_Hash_Challenge_Poseidon_S80a.sol\u0022:{\u0022content\u0022:\u0022/*\\n    This smart contract was written by StarkWare Industries Ltd. as part of the STARK-friendly hash\\n    challenge effort, funded by the Ethereum Foundation.\\n    The contract will pay out 2 ETH to the first finder of a collision in Poseidon with rate 2\\n    and capacity 2 at security level of 80 bits, if such a collision is discovered before the end\\n    of March 2020.\\n    More information about the STARK-friendly hash challenge can be found\\n    here https://starkware.co/hash-challenge/.\\n    More information about the STARK-friendly hash selection process (of which this challenge is a\\n    part) can be found here\\n    https://medium.com/starkware/stark-friendly-hash-tire-kicking-8087e8d9a246.\\n    Sage code reference implementation for the contender hash functions available\\n    at https://starkware.co/hash-challenge-implementation-reference-code/#common.\\n*/\\n\\n/*\\n  Copyright 2019 StarkWare Industries Ltd.\\n\\n  Licensed under the Apache License, Version 2.0 (the \\\u0022License\\\u0022).\\n  You may not use this file except in compliance with the License.\\n  You may obtain a copy of the License at\\n\\n  https://www.starkware.co/open-source-license/\\n\\n  Unless required by applicable law or agreed to in writing,\\n  software distributed under the License is distributed on an \\\u0022AS IS\\\u0022 BASIS,\\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\\n  See the License for the specific language governing permissions\\n  and limitations under the License.\\n*/\\n\\npragma solidity ^0.5.2;\\n\\nimport \\\u0022./Base.sol\\\u0022;\\nimport \\\u0022./Sponge.sol\\\u0022;\\n\\n\\ncontract STARK_Friendly_Hash_Challenge_Poseidon_S45b is Base, Sponge {\\n    uint256 MAX_CONSTANTS_PER_CONTRACT = 768;\\n\\n    address[] roundConstantsContracts;\\n    address mdsContract;\\n    uint256 nPartialRounds;\\n\\n    constructor (\\n        uint256 prime,  uint256 r,  uint256 c, uint256 nFullRounds,\\n        uint256 nPartialRounds_, address[] memory roundConstantsContracts_, address mdsContract_)\\n        public payable\\n        Sponge(prime, r, c, nFullRounds \u002B nPartialRounds_)\\n    {\\n        nPartialRounds = nPartialRounds_;\\n        roundConstantsContracts = roundConstantsContracts_;\\n        mdsContract = mdsContract_;\\n    }\\n\\n    function LoadAuxdata()\\n    internal view returns (uint256[] memory auxData)\\n    {\\n        uint256 round_constants = m*nRounds;\\n        require (\\n            round_constants \\u003c= 2 * MAX_CONSTANTS_PER_CONTRACT,\\n            \\\u0022The code supports up to 2 roundConstantsContracts.\\\u0022 );\\n\\n        uint256 mdsSize = m * m;\\n        auxData = new uint256[](round_constants \u002B mdsSize);\\n\\n        uint256 first_contract_n_elements = ((round_constants \\u003e MAX_CONSTANTS_PER_CONTRACT) ?\\n            MAX_CONSTANTS_PER_CONTRACT : round_constants);\\n        uint256 second_contract_n_elements = round_constants - first_contract_n_elements;\\n\\n        address FirstRoundsContractAddr = roundConstantsContracts[0];\\n        address SecondRoundsContractAddr = roundConstantsContracts[1];\\n        address mdsContractAddr = mdsContract;\\n\\n        assembly {\\n            let offset := add(auxData, 0x20)\\n            let mdsSizeInBytes := mul(mdsSize, 0x20)\\n            extcodecopy(mdsContractAddr, offset, 0, mdsSizeInBytes)\\n            offset := add(offset, mdsSizeInBytes)\\n            let firstSize := mul(first_contract_n_elements, 0x20)\\n            extcodecopy(FirstRoundsContractAddr, offset, 0, firstSize)\\n            offset := add(offset, firstSize)\\n            let secondSize := mul(second_contract_n_elements, 0x20)\\n            extcodecopy(SecondRoundsContractAddr, offset, 0, secondSize)\\n        }\\n    }\\n\\n\\n    function hades_round(\\n        uint256[] memory auxData, bool is_full_round, uint256 round_ptr,\\n        uint256[] memory workingArea, uint256[] memory elements)\\n        internal view {\\n\\n        uint256 prime_ = prime;\\n\\n        uint256 m_ = workingArea.length;\\n\\n        // Add-Round Key\\n        for (uint256 i = 0; i \\u003c m_; i\u002B\u002B) {\\n            workingArea[i] = addmod(elements[i], auxData[round_ptr \u002B i], prime_);\\n        }\\n\\n        // SubWords\\n        for (uint256 i = is_full_round ? 0 : m_ - 1; i \\u003c m_; i\u002B\u002B) {\\n            // workingArea[i] = workingArea[i] ** 3;\\n            workingArea[i] = mulmod(\\n                mulmod(workingArea[i], workingArea[i], prime_), workingArea[i], prime_);\\n        }\\n\\n        // MixLayer\\n        // elements = params.mds * workingArea.\\n        assembly {\\n            let mdsRowPtr := add(auxData, 0x20)\\n            let stateSize := mul(m_, 0x20)\\n            let workingAreaPtr := add(workingArea, 0x20)\\n            let statePtr := add(elements, 0x20)\\n            let mdsEnd := add(mdsRowPtr, mul(m_, stateSize))\\n\\n            for {} lt(mdsRowPtr, mdsEnd) { mdsRowPtr := add(mdsRowPtr, stateSize) } {\\n                let sum := 0\\n                for { let offset := 0} lt(offset, stateSize) { offset := add(offset, 0x20) } {\\n                    sum := addmod(\\n                        sum,\\n                        mulmod(mload(add(mdsRowPtr, offset)),\\n                               mload(add(workingAreaPtr, offset)),\\n                               prime_),\\n                        prime_)\\n                }\\n\\n                mstore(statePtr, sum)\\n                statePtr := add(statePtr, 0x20)\\n            }\\n        }\\n    }\\n\\n\\n    function permutation_func(uint256[] memory auxData, uint256[] memory elements)\\n        internal view\\n        returns (uint256[] memory hash_elements)\\n    {\\n        uint256 m_ = m;\\n        require (elements.length == m, \\\u0022elements.length != m.\\\u0022);\\n\\n        // auxData is composed of mdsMatrix followed by the round constants.\\n        // Skip mdsMatrix.\\n        uint256 round_ptr = (m_ * m_);\\n        //TODO(ilya): Move this to auxData?\\n        uint256[] memory workingArea = new uint256[](m_);\\n\\n        uint256 half_full_rounds = (nRounds - nPartialRounds) / 2;\\n\\n        for (uint256 i = 0; i \\u003c half_full_rounds; i\u002B\u002B) {\\n            hades_round(auxData, true, round_ptr, workingArea, elements);\\n            round_ptr \u002B= m_;\\n        }\\n\\n        for (uint256 i = 0; i \\u003c nPartialRounds; i\u002B\u002B) {\\n            hades_round(auxData, false, round_ptr, workingArea, elements);\\n            round_ptr \u002B= m_;\\n        }\\n\\n        for (uint256 i = 0; i \\u003c half_full_rounds; i\u002B\u002B) {\\n            hades_round(auxData, true, round_ptr, workingArea, elements);\\n            round_ptr \u002B= m_;\\n        }\\n\\n        return elements;\\n    }\\n}\\n\u0022}}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022firstInput\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022secondInput\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022calcCommitment\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022commitment\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022elements\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022applyHash\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022elementsHash\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022firstInput\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022secondInput\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022solutionDescription\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022claimReward\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getStatus\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool[]\u0022,\u0022name\u0022:\u0022status\u0022,\u0022type\u0022:\u0022bool[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022revokeReward\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022startRevoke\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getParameters\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022status\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022commitment\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022register\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022prime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022r\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022c\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nFullRounds\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nPartialRounds_\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022roundConstantsContracts_\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022mdsContract_\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022str\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022LogString\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"STARK_Friendly_Hash_Challenge_Poseidon_S45b","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000000000000000000000000200500000000000000001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000003300000000000000000000000000000000000000000000000000000000000000e00000000000000000000000002624af173ce578400cefbc0111e7800fdcb03aec00000000000000000000000000000000000000000000000000000000000000020000000000000000000000002b117e037d94e6d511e8287ecb513e6e78b295d3000000000000000000000000188c1ea0d18ff0265431540c71354e7b8d255175","Library":"","SwarmSource":"bzzr://49481d58b5b60f1b4a90c30365e26b90026f9466bcf0d007916a6c9f1b8f072a"}]