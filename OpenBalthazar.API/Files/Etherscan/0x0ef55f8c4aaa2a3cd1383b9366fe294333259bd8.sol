[{"SourceCode":"{\u0022Address.sol\u0022:{\u0022content\u0022:\u0022pragma solidity 0.4.25;\\n\\n/**\\n * Utility library of inline functions on addresses\\n */\\nlibrary Address {\\n    /**\\n     * Returns whether the target address is a contract\\n     * @dev This function will return false if invoked during the constructor of a contract,\\n     * as the code is not actually created until after the constructor finishes.\\n     * @param account address of the account to check\\n     * @return whether the target address is a contract\\n     */\\n    function isContract(address account) internal view returns (bool) {\\n        uint256 size;\\n        // XXX Currently there is no better way to check if there is a contract in an address\\n        // than to check the size of the code at that address.\\n        // See https://ethereum.stackexchange.com/a/14016/36603\\n        // for more details about how this works.\\n        // TODO Check this again before the Serenity release, because all addresses will be\\n        // contracts then.\\n        // solium-disable-next-line security/no-inline-assembly\\n        assembly { size := extcodesize(account) }\\n        return size \\u003e 0;\\n    }\\n}\\n\u0022},\u0022OracleResolver.sol\u0022:{\u0022content\u0022:\u0022pragma solidity 0.4.25;\\n\\nimport \\u0027./Address.sol\\u0027;\\n\\ninterface Aggregator {\\n    function currentAnswer() external view returns(uint256);\\n    function updatedHeight() external view returns(uint256);\\n}\\n\\ncontract OracleResolver {\\n    using Address for address;\\n\\n    Aggregator aggr;\\n\\n    uint256 public expiration;\\n\\n    constructor() public {\\n        if (address(0x79fEbF6B9F76853EDBcBc913e6aAE8232cFB9De9).isContract()) {\\n            // mainnet\\n            aggr = Aggregator(0x79fEbF6B9F76853EDBcBc913e6aAE8232cFB9De9);\\n            expiration = 120;\\n        } else if (address(0x0Be00A19538Fac4BE07AC360C69378B870c412BF).isContract()) {\\n            // ropsten\\n            aggr = Aggregator(0x0Be00A19538Fac4BE07AC360C69378B870c412BF);\\n            expiration = 4000;\\n        } else if (address(0x1AddCFF77Ca0F032c7dCA322fd8bFE61Cae66A62).isContract()) {\\n            // rinkeby\\n            aggr = Aggregator(0x1AddCFF77Ca0F032c7dCA322fd8bFE61Cae66A62);\\n            expiration = 1000;\\n        } else revert();\\n    }\\n\\n    function ethUsdPrice() public view returns (uint256) {\\n        require(block.number - aggr.updatedHeight() \\u003c expiration, \\\u0022Oracle data are outdated\\\u0022);\\n        return aggr.currentAnswer() / 1000;\\n    }\\n}\\n\u0022}}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022expiration\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ethUsdPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"OracleResolver","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://f5898442e9fc9ef1f45fba3573d06047aeb53d04e6152cddb5ff31e443307d86"}]