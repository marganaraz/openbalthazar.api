[{"SourceCode":"/**\r\n *Submitted for verification at Etherscan.io on 2020-01-07\r\n*/\r\n\r\n/**\r\n *Submitted for verification at Etherscan.io on 2019-12-18\r\n*/\r\n\r\n/**\r\n* Commit sha: deaeb22e4fa5a2f69505293ba62d354aa7294833\r\n* GitHub repository: https://github.com/aragonone/court-presale-activate\r\n* Tool used for the deploy: https://github.com/aragon/aragon-network-deploy\r\n**/\r\n\r\n// File: @aragon/court/contracts/lib/os/IsContract.sol\r\n\r\n// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/IsContract.sol\r\n// Adapted to use pragma ^0.5.8 and satisfy our linter rules\r\n\r\npragma solidity ^0.5.8;\r\n\r\n\r\ncontract IsContract {\r\n    /*\r\n    * NOTE: this should NEVER be used for authentication\r\n    * (see pitfalls: https://github.com/fergarrui/ethereum-security/tree/master/contracts/extcodesize).\r\n    *\r\n    * This is only intended to be used as a sanity check that an address is actually a contract,\r\n    * RATHER THAN an address not being a contract.\r\n    */\r\n    function isContract(address _target) internal view returns (bool) {\r\n        if (_target == address(0)) {\r\n            return false;\r\n        }\r\n\r\n        uint256 size;\r\n        assembly { size := extcodesize(_target) }\r\n        return size \u003E 0;\r\n    }\r\n}\r\n\r\n// File: @aragon/court/contracts/lib/os/ERC20.sol\r\n\r\n// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/lib/token/ERC20.sol\r\n// Adapted to use pragma ^0.5.8 and satisfy our linter rules\r\n\r\npragma solidity ^0.5.8;\r\n\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ncontract ERC20 {\r\n    function totalSupply() public view returns (uint256);\r\n\r\n    function balanceOf(address _who) public view returns (uint256);\r\n\r\n    function allowance(address _owner, address _spender) public view returns (uint256);\r\n\r\n    function transfer(address _to, uint256 _value) public returns (bool);\r\n\r\n    function approve(address _spender, uint256 _value) public returns (bool);\r\n\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);\r\n\r\n    event Transfer(\r\n        address indexed from,\r\n        address indexed to,\r\n        uint256 value\r\n    );\r\n\r\n    event Approval(\r\n        address indexed owner,\r\n        address indexed spender,\r\n        uint256 value\r\n    );\r\n}\r\n\r\n// File: @aragon/court/contracts/lib/os/SafeERC20.sol\r\n\r\n// Brought from https://github.com/aragon/aragonOS/blob/v4.3.0/contracts/common/SafeERC20.sol\r\n// Adapted to use pragma ^0.5.8 and satisfy our linter rules\r\n\r\npragma solidity ^0.5.8;\r\n\r\n\r\n\r\nlibrary SafeERC20 {\r\n    // Before 0.5, solidity has a mismatch between \u0060address.transfer()\u0060 and \u0060token.transfer()\u0060:\r\n    // https://github.com/ethereum/solidity/issues/3544\r\n    bytes4 private constant TRANSFER_SELECTOR = 0xa9059cbb;\r\n\r\n    /**\r\n    * @dev Same as a standards-compliant ERC20.transfer() that never reverts (returns false).\r\n    *      Note that this makes an external call to the token.\r\n    */\r\n    function safeTransfer(ERC20 _token, address _to, uint256 _amount) internal returns (bool) {\r\n        bytes memory transferCallData = abi.encodeWithSelector(\r\n            TRANSFER_SELECTOR,\r\n            _to,\r\n            _amount\r\n        );\r\n        return invokeAndCheckSuccess(address(_token), transferCallData);\r\n    }\r\n\r\n    /**\r\n    * @dev Same as a standards-compliant ERC20.transferFrom() that never reverts (returns false).\r\n    *      Note that this makes an external call to the token.\r\n    */\r\n    function safeTransferFrom(ERC20 _token, address _from, address _to, uint256 _amount) internal returns (bool) {\r\n        bytes memory transferFromCallData = abi.encodeWithSelector(\r\n            _token.transferFrom.selector,\r\n            _from,\r\n            _to,\r\n            _amount\r\n        );\r\n        return invokeAndCheckSuccess(address(_token), transferFromCallData);\r\n    }\r\n\r\n    /**\r\n    * @dev Same as a standards-compliant ERC20.approve() that never reverts (returns false).\r\n    *      Note that this makes an external call to the token.\r\n    */\r\n    function safeApprove(ERC20 _token, address _spender, uint256 _amount) internal returns (bool) {\r\n        bytes memory approveCallData = abi.encodeWithSelector(\r\n            _token.approve.selector,\r\n            _spender,\r\n            _amount\r\n        );\r\n        return invokeAndCheckSuccess(address(_token), approveCallData);\r\n    }\r\n\r\n    function invokeAndCheckSuccess(address _addr, bytes memory _calldata) private returns (bool) {\r\n        bool ret;\r\n        assembly {\r\n            let ptr := mload(0x40)    // free memory pointer\r\n\r\n            let success := call(\r\n                gas,                  // forward all gas\r\n                _addr,                // address\r\n                0,                    // no value\r\n                add(_calldata, 0x20), // calldata start\r\n                mload(_calldata),     // calldata length\r\n                ptr,                  // write output over free memory\r\n                0x20                  // uint256 return\r\n            )\r\n\r\n            if gt(success, 0) {\r\n            // Check number of bytes returned from last function call\r\n                switch returndatasize\r\n\r\n                // No bytes returned: assume success\r\n                case 0 {\r\n                    ret := 1\r\n                }\r\n\r\n                // 32 bytes returned: check if non-zero\r\n                case 0x20 {\r\n                // Only return success if returned data was true\r\n                // Already have output in ptr\r\n                    ret := eq(mload(ptr), 1)\r\n                }\r\n\r\n                // Not sure what was returned: don\u0027t mark as success\r\n                default { }\r\n            }\r\n        }\r\n        return ret;\r\n    }\r\n}\r\n\r\n// File: @aragon/court/contracts/standards/ApproveAndCall.sol\r\n\r\npragma solidity ^0.5.8;\r\n\r\n\r\ninterface ApproveAndCallFallBack {\r\n    /**\r\n    * @dev This allows users to use their tokens to interact with contracts in one function call instead of two\r\n    * @param _from Address of the account transferring the tokens\r\n    * @param _amount The amount of tokens approved for in the transfer\r\n    * @param _token Address of the token contract calling this function\r\n    * @param _data Optional data that can be used to add signalling information in more complex staking applications\r\n    */\r\n    function receiveApproval(address _from, uint256 _amount, address _token, bytes calldata _data) external;\r\n}\r\n\r\n// File: @aragon/court/contracts/standards/ERC900.sol\r\n\r\npragma solidity ^0.5.8;\r\n\r\n\r\n// Interface for ERC900: https://eips.ethereum.org/EIPS/eip-900\r\ninterface ERC900 {\r\n    event Staked(address indexed user, uint256 amount, uint256 total, bytes data);\r\n    event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);\r\n\r\n    /**\r\n    * @dev Stake a certain amount of tokens\r\n    * @param _amount Amount of tokens to be staked\r\n    * @param _data Optional data that can be used to add signalling information in more complex staking applications\r\n    */\r\n    function stake(uint256 _amount, bytes calldata _data) external;\r\n\r\n    /**\r\n    * @dev Stake a certain amount of tokens in favor of someone\r\n    * @param _user Address to stake an amount of tokens to\r\n    * @param _amount Amount of tokens to be staked\r\n    * @param _data Optional data that can be used to add signalling information in more complex staking applications\r\n    */\r\n    function stakeFor(address _user, uint256 _amount, bytes calldata _data) external;\r\n\r\n    /**\r\n    * @dev Unstake a certain amount of tokens\r\n    * @param _amount Amount of tokens to be unstaked\r\n    * @param _data Optional data that can be used to add signalling information in more complex staking applications\r\n    */\r\n    function unstake(uint256 _amount, bytes calldata _data) external;\r\n\r\n    /**\r\n    * @dev Tell the total amount of tokens staked for an address\r\n    * @param _addr Address querying the total amount of tokens staked for\r\n    * @return Total amount of tokens staked for an address\r\n    */\r\n    function totalStakedFor(address _addr) external view returns (uint256);\r\n\r\n    /**\r\n    * @dev Tell the total amount of tokens staked\r\n    * @return Total amount of tokens staked\r\n    */\r\n    function totalStaked() external view returns (uint256);\r\n\r\n    /**\r\n    * @dev Tell the address of the token used for staking\r\n    * @return Address of the token used for staking\r\n    */\r\n    function token() external view returns (address);\r\n\r\n    /*\r\n    * @dev Tell if the current registry supports historic information or not\r\n    * @return True if the optional history functions are implemented, false otherwise\r\n    */\r\n    function supportsHistory() external pure returns (bool);\r\n}\r\n\r\n// File: contracts/lib/IPresale.sol\r\n\r\npragma solidity ^0.5.8;\r\n\r\n\r\n\r\ninterface IPresale {\r\n    function open() external;\r\n    function close() external;\r\n    function contribute(address _contributor, uint256 _value) external payable;\r\n    function refund(address _contributor, uint256 _vestedPurchaseId) external;\r\n    function contributionToTokens(uint256 _value) external view returns (uint256);\r\n    function contributionToken() external view returns (ERC20);\r\n}\r\n\r\n// File: contracts/CourtPresaleActivate.sol\r\n\r\npragma solidity ^0.5.8;\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\ncontract CourtPresaleActivate is IsContract, ApproveAndCallFallBack {\r\n    using SafeERC20 for ERC20;\r\n\r\n    string private constant ERROR_TOKEN_NOT_CONTRACT = \u0022CPA_TOKEN_NOT_CONTRACT\u0022;\r\n    string private constant ERROR_REGISTRY_NOT_CONTRACT = \u0022CPA_REGISTRY_NOT_CONTRACT\u0022;\r\n    string private constant ERROR_PRESALE_NOT_CONTRACT = \u0022CPA_PRESALE_NOT_CONTRACT\u0022;\r\n    string private constant ERROR_ZERO_AMOUNT = \u0022CPA_ZERO_AMOUNT\u0022;\r\n    string private constant ERROR_TOKEN_TRANSFER_FAILED = \u0022CPA_TOKEN_TRANSFER_FAILED\u0022;\r\n    string private constant ERROR_WRONG_TOKEN = \u0022CPA_WRONG_TOKEN\u0022;\r\n\r\n    bytes32 internal constant ACTIVATE_DATA = keccak256(\u0022activate(uint256)\u0022);\r\n\r\n    ERC20 public bondedToken;\r\n    ERC900 public registry;\r\n    IPresale public presale;\r\n\r\n    event BoughtAndActivated(address from, address collateralToken, uint256 buyAmount, uint256 activatedAmount);\r\n\r\n    constructor(ERC20 _bondedToken, ERC900 _registry, IPresale _presale) public {\r\n        require(isContract(address(_bondedToken)), ERROR_TOKEN_NOT_CONTRACT);\r\n        require(isContract(address(_registry)), ERROR_REGISTRY_NOT_CONTRACT);\r\n        require(isContract(address(_presale)), ERROR_PRESALE_NOT_CONTRACT);\r\n\r\n        bondedToken = _bondedToken;\r\n        registry = _registry;\r\n        presale = _presale;\r\n    }\r\n\r\n    /**\r\n    * @dev This function must be triggered by the contribution token approve-and-call fallback.\r\n    *      It will pull the approved tokens and convert them into the presale instance, and activate the converted tokens into a\r\n    *      jurors registry instance of an Aragon Court.\r\n    * @param _from Address of the original caller (juror) converting and activating the tokens\r\n    * @param _amount Amount of contribution tokens to be converted and activated\r\n    * @param _token Address of the contribution token triggering the approve-and-call fallback\r\n    */\r\n    function receiveApproval(address _from, uint256 _amount, address _token, bytes calldata) external {\r\n        require(_amount \u003E 0, ERROR_ZERO_AMOUNT);\r\n        require(_token == address(presale.contributionToken()), ERROR_WRONG_TOKEN);\r\n\r\n        // move tokens to this contract\r\n        require(ERC20(_token).safeTransferFrom(_from, address(this), _amount), ERROR_TOKEN_TRANSFER_FAILED);\r\n\r\n        // approve to presale\r\n        require(ERC20(_token).safeApprove(address(presale), _amount), ERROR_TOKEN_TRANSFER_FAILED);\r\n\r\n        // buy in presale\r\n        presale.contribute(address(this), _amount);\r\n        uint256 bondedTokensObtained = presale.contributionToTokens(_amount);\r\n\r\n        require(bondedToken.safeTransfer(_from, bondedTokensObtained), \u0022TRANSFER FAILED\u0022);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022registry\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022receiveApproval\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022bondedToken\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022presale\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_bondedToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_registry\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_presale\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022collateralToken\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022buyAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022activatedAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022BoughtAndActivated\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"CourtPresaleActivate","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000cd62b1c403fa761baadfc74c525ce2b51780b184000000000000000000000000f9dda954adf5e54b89f988c1560553a0a387cce1000000000000000000000000f89c8752d82972f94a4d1331e010ed6593e8ec49","Library":"","SwarmSource":"bzzr://18f194a1f4072c8660bcf8b173012cb17ced332f5bd9682833c6c49ee82f181e"}]