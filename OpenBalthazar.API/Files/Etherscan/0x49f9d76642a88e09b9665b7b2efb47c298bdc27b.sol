[{"SourceCode":"pragma solidity ^0.5.16;\r\n\r\ncontract KyberNetworkProxy {\r\n    function getExpectedRate(address src, address dest, uint srcQty) public view returns (uint expectedRate, uint slippageRate);\r\n}\r\n\r\ncontract UniswapExchange {\r\n    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);\r\n    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);\r\n}\r\n\r\ncontract PriceChecker {\r\n    KyberNetworkProxy constant private kyberNetworkProxy = KyberNetworkProxy(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);\r\n    address constant private ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\r\n\r\n    function check(\r\n        address token,\r\n        address uniswap_addr,\r\n        uint256 amount_eth,\r\n        uint256 amount_token\r\n    )\r\n    public\r\n    view\r\n    returns (\r\n        uint256 kyber_buy,\r\n        uint256 kyber_sell,\r\n        uint256 uniswap_buy,\r\n        uint256 uniswap_sell,\r\n        int256 buy_diff,\r\n        int256 sell_diff\r\n    )\r\n    {\r\n        UniswapExchange uniswap_exchange = UniswapExchange(uniswap_addr);\r\n        uint256 expectedRate;\r\n        uint256 slippageRate;\r\n        (expectedRate, slippageRate) = kyberNetworkProxy.getExpectedRate(ETH, token, amount_eth);\r\n        kyber_buy = expectedRate * amount_eth / 10 ** 18;\r\n        (expectedRate, slippageRate) = kyberNetworkProxy.getExpectedRate(token, ETH, amount_token);\r\n        kyber_sell = expectedRate * amount_token / 10 ** 18;\r\n        uniswap_buy = uniswap_exchange.getEthToTokenInputPrice(amount_eth);\r\n        uniswap_sell = uniswap_exchange.getTokenToEthInputPrice(amount_token);\r\n        buy_diff = int(uniswap_buy) - int(kyber_buy);\r\n        sell_diff = int(uniswap_sell) - int(kyber_sell);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022uniswap_addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount_eth\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount_token\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022check\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022kyber_buy\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022kyber_sell\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022uniswap_buy\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022uniswap_sell\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022int256\u0022,\u0022name\u0022:\u0022buy_diff\u0022,\u0022type\u0022:\u0022int256\u0022},{\u0022internalType\u0022:\u0022int256\u0022,\u0022name\u0022:\u0022sell_diff\u0022,\u0022type\u0022:\u0022int256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"PriceChecker","CompilerVersion":"v0.5.16\u002Bcommit.9c3226ce","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://d2d769784aa859658e53b46a7916c522b9ee2903e8c6af9e3dcfdecdaf8ef12a"}]