[{"SourceCode":"pragma solidity ^0.5.12;\r\ncontract Medianizer {\r\n\tfunction peek() external pure returns (bytes32,bool) {}\r\n}\r\n\r\ncontract FiatContract {\r\n\tfunction USD(uint _id) external pure returns (uint256);\r\n}\r\n\r\ncontract EtherPriceWagers {\r\n\tuint constant gnHighestAcceptableResolutionDate = 1577577600;\r\n\tuint constant gcnPoint001 = 1000000000000000;\r\n\tuint constant gcnPoint00000001 = 10000000000;\r\n\tuint constant gcnTransactionFee_Divisor = 1015;\r\n\tuint constant gcnResolution_Fiat_Ropsten = 0;\r\n\tuint constant gcnResolution_Fiat_Main = 1;\r\n\tuint constant gcnResolution_MakerDAO_Main = 2;\r\n\r\n\taddress payable gadrOwner;\r\n\tuint gnOwnerBalance = 0;\r\n\tuint gnLastProposalID = 0;\r\n\tuint gnLastAcceptanceID = 0;\r\n\r\n\tMedianizer gobjMakerDAOContract_Mainnet;\r\n\tMedianizer gobjMakerDAOContract_Kovan;\r\n\tFiatContract gobjFiatContract_Mainnet;\r\n\tFiatContract gobjFiatContract_Ropsten;\r\n\r\n\tstruct clsProposal {\r\n\t\taddress payable adrProposerAddress;\r\n\t\tuint nDateCreated;\r\n\t\tuint nProposalAmount_start;\r\n\t\tuint nMinimumWager;\r\n\t\tuint nWantsAboveTargetPrice;\r\n\t\tuint nTargetPrice;\r\n\t\tuint nResolutionDate;\r\n\t\tuint nProfitPercentOffered;\r\n\t\tuint nResolutionSource;\r\n\t\tuint nProposalAmount_remaining;\r\n\t\tuint nCancellationDate;\r\n\t}\r\n\r\n\tstruct clsAcceptance {\r\n\t\tuint nProposalID;\r\n\t\taddress payable adrAcceptorAddress;\r\n\t\tuint nDateCreated;\r\n\t\tuint nAcceptedWagerAmount;\r\n\t\tuint nFinalized_Date;\r\n\t\taddress adrWagerFinalizer;\r\n\t\tuint nFinalized_FinalizedPrice;\r\n\t\tuint nFinalized_DidProposerWin;\r\n\t\tuint nFinalized_AmountProposerReceived;\r\n\t\tuint nFinalized_AmountAcceptorReceived;\r\n\t}\r\n\r\n\tmapping(uint =\u003E clsProposal) gmapProposals;\r\n\tmapping(uint =\u003E clsAcceptance) gmapAcceptances;\r\n\t\r\n\tconstructor() public {\r\n\t\tgadrOwner = msg.sender; \r\n\t\tgobjFiatContract_Mainnet = FiatContract(0x8055d0504666e2B6942BeB8D6014c964658Ca591);\r\n\t\tgobjFiatContract_Ropsten = FiatContract(0x2CDe56E5c8235D6360CCbb0c57Ce248Ca9C80909);\r\n\t\tgobjMakerDAOContract_Mainnet = Medianizer(0x729D19f657BD0614b4985Cf1D82531c67569197B);\r\n\t\tgobjMakerDAOContract_Kovan = Medianizer(0x9FfFE440258B79c5d6604001674A4722FfC0f7Bc);\r\n\t}\r\n\r\n\tmodifier OnlyByOwner()\r\n\t{\r\n\t\trequire(msg.sender == gadrOwner);\r\n\t\t_;\r\n\t}\r\n\r\n\tevent ProposalCreated(uint indexed ProposalID, address indexed Proposer, uint indexed ProposalAmount, uint MinimumWager, uint WantsAboveTargetPrice, uint TargetPrice, uint ResolutionDate, uint ProfitPercentOffered, uint ResolutionSource);\r\n\tevent AcceptanceCreated(uint indexed ProposalID, address indexed Acceptor, uint indexed AcceptedAmount, uint RemainingWager);\r\n\tevent WagerResolved(uint indexed ProposalID, address indexed Resolver, uint indexed AcceptanceID, uint TargetPrice, uint CurrentPrice, uint DidProposerWin, uint AmountSentToProposer, uint AmountSentToAcceptor);\r\n\tevent WagerCancelled(uint indexed ProposalID, address indexed Proposer, uint indexed AmountRefunded);\r\n\r\n\tfunction () external payable {}\r\n\r\n\tfunction zCreateProposal(uint nMinimumWager, uint nWantsAboveTargetPrice, uint nTargetPrice, uint nResolutionDate, uint nProfitPercentOffered, uint nResolutionSource) external payable {\r\n\t\tuint nProposerDeposit = (((msg.value / gcnPoint00000001) * gcnPoint00000001)*1000) / gcnTransactionFee_Divisor;\r\n\t\trequire(nProfitPercentOffered \u003E= 10 \u0026\u0026 nProfitPercentOffered \u003C= 1000 \u0026\u0026 nProposerDeposit \u003E= gcnPoint001 \u0026\u0026 nResolutionDate \u003C gnHighestAcceptableResolutionDate \u0026\u0026 \r\n\t\t\t\tnResolutionDate \u003E block.timestamp \u0026\u0026 nMinimumWager \u003E= gcnPoint001 \u0026\u0026 (nMinimumWager * nProfitPercentOffered) / 100 \u003C= nProposerDeposit);\r\n\r\n\t\tgnOwnerBalance \u002B= msg.value - nProposerDeposit;\r\n\t\t\r\n\t\tgnLastProposalID\u002B\u002B;\r\n\t\tgmapProposals[gnLastProposalID].adrProposerAddress = msg.sender;\r\n\t\tgmapProposals[gnLastProposalID].nDateCreated = block.timestamp;\r\n\t\tgmapProposals[gnLastProposalID].nProposalAmount_start = nProposerDeposit;\r\n\t\tgmapProposals[gnLastProposalID].nMinimumWager = nMinimumWager;\r\n\t\tgmapProposals[gnLastProposalID].nWantsAboveTargetPrice = nWantsAboveTargetPrice;\r\n\t\tgmapProposals[gnLastProposalID].nTargetPrice = nTargetPrice;\r\n\t\tgmapProposals[gnLastProposalID].nResolutionDate = nResolutionDate;\r\n\t\tgmapProposals[gnLastProposalID].nProfitPercentOffered = nProfitPercentOffered;\r\n\t\tgmapProposals[gnLastProposalID].nResolutionSource = nResolutionSource;\r\n\t\tgmapProposals[gnLastProposalID].nProposalAmount_remaining = nProposerDeposit;\r\n\r\n\t\temit ProposalCreated(\r\n\t\t\tgnLastProposalID,\r\n\t\t\tmsg.sender,\r\n\t\t\tnProposerDeposit,\r\n\t\t\tnMinimumWager,\r\n\t\t\tnWantsAboveTargetPrice,\r\n\t\t\tnTargetPrice,\r\n\t\t\tnResolutionDate,\r\n\t\t\tnProfitPercentOffered,\r\n\t\t\tnResolutionSource\r\n\t\t);\r\n\t}\r\n\r\n\tfunction zCreateAcceptance(uint nProposalID) external payable {\r\n\t\tuint nAcceptorDeposit = (((((msg.value / gcnPoint00000001) * gcnPoint00000001)*1000) / gcnTransactionFee_Divisor) / gcnPoint001) * gcnPoint001;\r\n\t\tuint nPossiblePayout = (((nAcceptorDeposit * gmapProposals[nProposalID].nProfitPercentOffered) / 100) / gcnPoint001) * gcnPoint001;\r\n\t\trequire(nAcceptorDeposit \u003E= gcnPoint001 \u0026\u0026 nAcceptorDeposit \u003E= gmapProposals[nProposalID].nMinimumWager \u0026\u0026 gmapProposals[nProposalID].nResolutionDate \u003E block.timestamp \u0026\u0026 gmapProposals[nProposalID].nProposalAmount_remaining \u003E= nPossiblePayout);\r\n\r\n\t\tgnOwnerBalance \u002B= msg.value - nAcceptorDeposit;\r\n\r\n\t\tgnLastAcceptanceID\u002B\u002B;\r\n\t\tgmapAcceptances[gnLastAcceptanceID].nProposalID = nProposalID;\r\n\t\tgmapAcceptances[gnLastAcceptanceID].adrAcceptorAddress = msg.sender;\r\n\t\tgmapAcceptances[gnLastAcceptanceID].nDateCreated = block.timestamp;\r\n\t\tgmapAcceptances[gnLastAcceptanceID].nAcceptedWagerAmount = nAcceptorDeposit;\r\n\r\n\t\tgmapProposals[nProposalID].nProposalAmount_remaining -= nPossiblePayout;\r\n\t\t\r\n\t\temit AcceptanceCreated(\r\n\t\t\tnProposalID,\r\n\t\t\tmsg.sender,\r\n\t\t\tnAcceptorDeposit,\r\n\t\t\tgmapProposals[nProposalID].nProposalAmount_remaining\r\n\t\t);\r\n\t}\r\n\r\n\tfunction zResolveWager(uint nAcceptanceID) external {\r\n\t\tclsProposal storage objProposal = gmapProposals[gmapAcceptances[nAcceptanceID].nProposalID];\r\n\t\trequire(objProposal.nResolutionDate \u003C block.timestamp \u0026\u0026 gmapAcceptances[nAcceptanceID].nFinalized_Date == 0);\r\n\t\t\r\n\t\tuint nCurrentPrice = getCurrentEtherPrice(objProposal.nResolutionSource);\r\n\t\trequire (nCurrentPrice != 0);\r\n\t\tuint nProposerWon = 0;\r\n\t\tif (objProposal.nWantsAboveTargetPrice == 1) {\r\n\t\t\tif (nCurrentPrice \u003E objProposal.nTargetPrice) {\r\n\t\t\t\tnProposerWon = 1;\r\n\t\t\t}\r\n\t\t} else {\r\n\t\t\tif(nCurrentPrice \u003C objProposal.nTargetPrice) {\r\n\t\t\t\tnProposerWon = 1;\r\n\t\t\t}\r\n\t\t}\r\n\r\n\t\tuint nAmountSentToProposer = 0;\r\n\t\tuint nAmountSentToAcceptor = 0;\r\n\t\tuint nAcceptorProfit = ((((gmapAcceptances[nAcceptanceID].nAcceptedWagerAmount * objProposal.nProfitPercentOffered) / 100)) / gcnPoint001) * gcnPoint001;\r\n\t\tif (nProposerWon == 1) {\r\n\t\t\tnAmountSentToProposer = gmapAcceptances[nAcceptanceID].nAcceptedWagerAmount \u002B nAcceptorProfit \u002B objProposal.nProposalAmount_remaining;\r\n\t\t} else {\r\n\t\t\tnAmountSentToProposer = objProposal.nProposalAmount_remaining;\r\n\t\t\tnAmountSentToAcceptor = nAcceptorProfit \u002B gmapAcceptances[nAcceptanceID].nAcceptedWagerAmount;\r\n\t\t\tgmapAcceptances[nAcceptanceID].adrAcceptorAddress.transfer(nAmountSentToAcceptor);\r\n\t\t}\r\n\t\tif (nAmountSentToProposer \u003E 0) {\r\n\t\t\tobjProposal.adrProposerAddress.transfer(nAmountSentToProposer);\r\n\t\t\tobjProposal.nProposalAmount_remaining = 0;\r\n\t\t}\r\n\r\n\t\tgmapAcceptances[nAcceptanceID].nFinalized_Date = block.timestamp;\r\n\t\tgmapAcceptances[nAcceptanceID].adrWagerFinalizer = msg.sender;\r\n\t\tgmapAcceptances[nAcceptanceID].nFinalized_FinalizedPrice = nCurrentPrice;\r\n\t\tgmapAcceptances[nAcceptanceID].nFinalized_DidProposerWin = nProposerWon;\r\n\t\tgmapAcceptances[nAcceptanceID].nFinalized_AmountProposerReceived = nAmountSentToProposer;\r\n\t\tgmapAcceptances[nAcceptanceID].nFinalized_AmountAcceptorReceived = nAmountSentToAcceptor;\r\n\t\t\r\n\t\temit WagerResolved(\r\n\t\t\tgmapAcceptances[nAcceptanceID].nProposalID,\r\n\t\t\tmsg.sender,\r\n\t\t\tnAcceptanceID,\r\n\t\t\tobjProposal.nTargetPrice,\r\n\t\t\tnCurrentPrice,\r\n\t\t\tnProposerWon,\r\n\t\t\tnAmountSentToProposer,\r\n\t\t\tnAmountSentToAcceptor\r\n\t\t);\r\n\t}\r\n\r\n\tfunction zCancelProposal(uint nProposalID) external {\r\n\t\trequire(gmapProposals[nProposalID].adrProposerAddress == msg.sender);\t\r\n\r\n\t\temit WagerCancelled (\r\n\t\t\tnProposalID,\r\n\t\t\tmsg.sender, \r\n\t\t\tgmapProposals[nProposalID].nProposalAmount_remaining\r\n\t\t);\r\n\t\t\r\n\t\tgmapProposals[nProposalID].adrProposerAddress.transfer(gmapProposals[nProposalID].nProposalAmount_remaining);\r\n\t\tgmapProposals[nProposalID].nProposalAmount_remaining = 0;\r\n\t\tgmapProposals[nProposalID].nCancellationDate = block.timestamp;\r\n\t}\r\n\r\n\tfunction getCurrentEtherPrice(uint nResolutionSource) public view returns (uint256) {\r\n\t\tif (nResolutionSource == gcnResolution_Fiat_Ropsten) {\r\n\t\t\treturn (10000000000000000000000000000000000 / gobjFiatContract_Ropsten.USD(0));\r\n\t\t}\r\n\t\tif (nResolutionSource == gcnResolution_Fiat_Main) {\r\n\t\t\treturn (10000000000000000000000000000000000 / gobjFiatContract_Mainnet.USD(0));\r\n\t\t}\r\n\t\tif (nResolutionSource == gcnResolution_MakerDAO_Main) {\r\n\t\t\t(bytes32 b32Price, bool bValid) =  gobjMakerDAOContract_Mainnet.peek();\r\n\t\t\tif (!bValid) {\r\n\t\t\t\treturn 0;\r\n\t\t\t} else {\r\n\t\t\t\treturn uint(b32Price);\r\n\t\t\t}\r\n\t\t}\r\n\t\treturn 0;\r\n\t}\r\n\r\n\tfunction getProposals() external view returns (uint[10][] memory anData, address[] memory aadrProposerAddress) {\r\n\t\tanData = new uint[10][](gnLastProposalID\u002B1);\r\n\t\taadrProposerAddress = new address[](gnLastProposalID\u002B1);\r\n\r\n\t\tfor (uint i = 1; i \u003C= gnLastProposalID; i\u002B\u002B) {\r\n\t\t\taadrProposerAddress[i] = gmapProposals[i].adrProposerAddress;\r\n\t\t\tanData[i][0] = gmapProposals[i].nDateCreated;\r\n\t\t\tanData[i][1] = gmapProposals[i].nProposalAmount_start;\r\n\t\t\tanData[i][2] = gmapProposals[i].nMinimumWager;\r\n\t\t\tanData[i][3] = gmapProposals[i].nWantsAboveTargetPrice;\r\n\t\t\tanData[i][4] = gmapProposals[i].nTargetPrice;\r\n\t\t\tanData[i][5] = gmapProposals[i].nResolutionDate;\r\n\t\t\tanData[i][6] = gmapProposals[i].nProfitPercentOffered;\r\n\t\t\tanData[i][7] = gmapProposals[i].nResolutionSource;\r\n\t\t\tanData[i][8] = gmapProposals[i].nProposalAmount_remaining;\r\n\t\t\tanData[i][9] = gmapProposals[i].nCancellationDate;\r\n\t\t}\r\n\t}\r\n\t\r\n\tfunction getAcceptances() external view returns (uint[13][] memory anData, address[3][] memory aadrAcceptorAddress) {\r\n\t\tanData = new uint[13][](gnLastAcceptanceID\u002B1);\r\n\t\taadrAcceptorAddress = new address[3][](gnLastAcceptanceID\u002B1);\r\n\t\tuint nProposerID;\r\n\r\n\t\tfor (uint i = 1; i \u003C= gnLastAcceptanceID; i\u002B\u002B) {\r\n\t\t\tnProposerID = gmapAcceptances[i].nProposalID;\r\n\t\t\tanData[i][0] = nProposerID;\r\n\t\t\taadrAcceptorAddress[i][0] = gmapAcceptances[i].adrAcceptorAddress;\r\n\t\t\taadrAcceptorAddress[i][1] = gmapAcceptances[i].adrWagerFinalizer;\r\n\t\t\taadrAcceptorAddress[i][2] = gmapProposals[nProposerID].adrProposerAddress;\r\n\t\t\tanData[i][1] = gmapAcceptances[i].nDateCreated;\r\n\t\t\tanData[i][2] = gmapAcceptances[i].nAcceptedWagerAmount;\r\n\t\t\tanData[i][3] = gmapAcceptances[i].nFinalized_Date;\r\n\t\t\tanData[i][4] = gmapAcceptances[i].nFinalized_FinalizedPrice;\r\n\t\t\tanData[i][5] = gmapAcceptances[i].nFinalized_DidProposerWin;\r\n\t\t\tanData[i][6] = gmapAcceptances[i].nFinalized_AmountProposerReceived;\r\n\t\t\tanData[i][7] = gmapAcceptances[i].nFinalized_AmountAcceptorReceived;\r\n\t\t\tanData[i][8] = gmapProposals[nProposerID].nTargetPrice;\r\n\t\t\tanData[i][9] = gmapProposals[nProposerID].nWantsAboveTargetPrice;\r\n\t\t\tanData[i][10] = gmapProposals[nProposerID].nResolutionDate;\r\n\t\t\tanData[i][11] = gmapProposals[nProposerID].nProfitPercentOffered;\r\n\t\t\tanData[i][12] = gmapProposals[nProposerID].nResolutionSource;\r\n\t\t}\r\n\t}\r\n\t\r\n\tfunction getOwnerBalance() public view returns (uint256) {\r\n\t\treturn gnOwnerBalance;\r\n\t}\r\n\r\n\tfunction zWithdrawOwnerBalance() OnlyByOwner() external {\r\n\t\tgadrOwner.transfer(gnOwnerBalance);\r\n\t\tgnOwnerBalance = 0;\r\n\t}\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022ProposalID\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022Acceptor\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022AcceptedAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022RemainingWager\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022AcceptanceCreated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022ProposalID\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022Proposer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022ProposalAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022MinimumWager\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022WantsAboveTargetPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022TargetPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022ResolutionDate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022ProfitPercentOffered\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022ResolutionSource\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ProposalCreated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022ProposalID\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022Proposer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022AmountRefunded\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022WagerCancelled\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022ProposalID\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022Resolver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022AcceptanceID\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022TargetPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022CurrentPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022DidProposerWin\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022AmountSentToProposer\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022AmountSentToAcceptor\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022WagerResolved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAcceptances\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256[13][]\u0022,\u0022name\u0022:\u0022anData\u0022,\u0022type\u0022:\u0022uint256[13][]\u0022},{\u0022internalType\u0022:\u0022address[3][]\u0022,\u0022name\u0022:\u0022aadrAcceptorAddress\u0022,\u0022type\u0022:\u0022address[3][]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nResolutionSource\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getCurrentEtherPrice\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getOwnerBalance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getProposals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256[10][]\u0022,\u0022name\u0022:\u0022anData\u0022,\u0022type\u0022:\u0022uint256[10][]\u0022},{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022aadrProposerAddress\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nProposalID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022zCancelProposal\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nProposalID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022zCreateAcceptance\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nMinimumWager\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nWantsAboveTargetPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nTargetPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nResolutionDate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nProfitPercentOffered\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nResolutionSource\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022zCreateProposal\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nAcceptanceID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022zResolveWager\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022zWithdrawOwnerBalance\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"EtherPriceWagers","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://e8dfcbbc7757971cda171385147932f5a45d80123c1f36c12823fd566d488402"}]