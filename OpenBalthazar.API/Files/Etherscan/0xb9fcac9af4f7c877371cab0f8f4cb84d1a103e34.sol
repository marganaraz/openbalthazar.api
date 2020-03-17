[{"SourceCode":"pragma solidity ^0.5.12;\r\n\r\ncontract tokenInterface {\r\n\tfunction balanceOf(address _owner) public view returns (uint256 balance);\r\n\tfunction transfer(address _to, uint256 _value) public returns (bool);\r\n}\r\n\r\ncontract Timelock_Swap_Trustless {\r\n\t\r\n\ttokenInterface public tcj;\r\n\ttokenInterface public xra;\r\n\tuint256 public dataUnlock;\r\n\taddress public addrCoinshare;\r\n\taddress public addrXriba;\r\n\r\n\tconstructor(address _tcj, address _xra, uint256 _dataUnlock, address _addrCoinshare, address _addrXriba) public {\r\n\t\ttcj = tokenInterface(_tcj);\r\n\t\txra = tokenInterface(_xra);\r\n\t\t\r\n\t\tdataUnlock = _dataUnlock;\r\n\t\t\r\n\t\taddrCoinshare = _addrCoinshare;\r\n\t\taddrXriba = _addrXriba;\r\n\t}\r\n\t\r\n\tbool withdrawn;\r\n\t\r\n\tfunction enabled() public view returns(bool) {\r\n\t    bool xriba_paid = xra.balanceOf(address(this)) \u003E 3333333 * 1e18;\r\n\t    bool coinshare_paid = tcj.balanceOf(address(this)) \u003E= 8333333 * 1e18;\r\n\t    \r\n\t    if(coinshare_paid \u0026\u0026 xriba_paid) {\r\n\t        return true;\r\n\t    } else if (withdrawn) {\r\n\t        return true;\r\n\t    } else {\r\n\t        return false;\r\n\t    }\r\n\t}\r\n\t\r\n\tfunction () external {\r\n\t    uint256 tcj_amount = tcj.balanceOf(address(this));\r\n\t    uint256 xra_amount = xra.balanceOf(address(this));\r\n\t    \r\n\t    if(enabled()) {\r\n\t        require(now\u003EdataUnlock,\u0022now\u003EdataUnlock\u0022);\r\n\t        if(msg.sender == addrCoinshare) {\r\n\t            require(xra_amount \u003E 0, \u0022xra_amount \u003E 0\u0022);\r\n\t            withdrawn = true;\r\n\t            xra.transfer(addrCoinshare, xra_amount);\r\n\t        } else if ( msg.sender == addrXriba ) {\r\n\t            require(tcj_amount \u003E 0, \u0022tcj_amount \u003E 0\u0022);\r\n\t            withdrawn = true;\r\n\t            tcj.transfer(addrXriba, tcj_amount);\r\n\t        } else {\r\n\t            revert(\u0022No auth.\u0022);\r\n\t        }\r\n\t    } else {\r\n\t        if(msg.sender == addrCoinshare) {\r\n\t            require(tcj_amount \u003E 0, \u0022tcj_amount \u003E 0\u0022);\r\n\t            tcj.transfer(addrCoinshare, tcj_amount);\r\n\t        } else if ( msg.sender == addrXriba ) {\r\n\t            require(xra_amount \u003E 0, \u0022xra_amount \u003E 0\u0022);\r\n\t            xra.transfer(addrXriba, xra_amount);\r\n\t        } else {\r\n\t            revert(\u0022No auth.\u0022);\r\n\t        }\r\n\t    }\r\n\t}\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_tcj\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_xra\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_dataUnlock\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_addrCoinshare\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_addrXriba\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022addrCoinshare\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022addrXriba\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022dataUnlock\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022enabled\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tcj\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract tokenInterface\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022xra\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract tokenInterface\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"Timelock_Swap_Trustless","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"00000000000000000000000044744e3e608d1243f55008b328fe1b09bd42e4cc0000000000000000000000007025bab2ec90410de37f488d1298204cd4d6b29d000000000000000000000000000000000000000000000000000000005f4d72e0000000000000000000000000c9d32ab70a7781a128692e9b4fecebca6c1bcce400000000000000000000000098719cfc0aee5de1ff30bb5f22ae3c2ce45e43f7","Library":"","SwarmSource":"bzzr://059d9699034dc8f004e3ff56372f9a0dd28bfd1a7763b81c1760467f50aa653e"}]