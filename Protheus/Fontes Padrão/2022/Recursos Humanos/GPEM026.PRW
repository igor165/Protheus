#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM026.CH"
#INCLUDE "FWMVCDEF.CH"

STATIC lIntTAF		:= If(cPaisLoc == 'BRA' .AND. Findfunction("fG17TAF"), fG17TAF(), .F.) ////Integracao com TAF
Static lIntegTAF	:= If(cPaisLoc == 'BRA' ,SuperGetMv("MV_RHTAF",nil,.F.), .F.) ////Integracao com TAF
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static dDcgIni      := SuperGetMV("MV_DTCGINI", Nil, cToD("//") )
Static lMVDtFimA   	:= SuperGetMV("MV_DTFIMA", Nil, .F. )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    	³ GPEM026    ³ Autor ³ Alessandro Santos       	                ³ Data ³ 05/04/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao 	³ Funcoes para nao-eventuais eSocial                        			            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   	³                                                           	  		            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               			            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista     ³ Data     ³ FNC/Requisito  ³ Chamado ³  Motivo da Alteracao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Raquel Hager ³11/08/2014³00000026544/2014³TQHIID   ³Inclusao de fonte na Versao 12.		        ³±±
±±³EduardoVicent³02/06/2017³ 				³DRHESOCP-311³Inclusão de Funções para envido dos dados	³±±
±±³EduardoVicent³02/06/2017³ 				³DRHESOCP-311 ³para esocial		      					³±±
±±³EduardoVicent³05/07/2017³ 				³DRHESOCP-573 ³Retirada da TAG de Fim de afastamento	³±±
±±³Oswaldo L    ³27-07-17  ³                ³DRHESOCP-592 ³  Unificar a lista de opções da Tag      ³±±
±±³             ³          ³                ³SubTask 709  ³  <estCiv>                               ³±±
±±³Eduardo Vicente³02/08/2017³DRHESOCP-744            ³Ajustes na chamada da Função fGp23Cons       ³±±
±±³Oswaldo L      ³02/08/2017³DRHESOCP-755            ³Merge e-social versões 11.80 12.1.17         ³±±
±±³Eduardo V   ³11/08/2017 ³DRHESOCP-781    ³         ³Correções de erros apontadas a issue 592     ³±±
±±³Eduardo V   ³28/08/2017 ³DRHESOCP-873    ³         ³Ajuste na tratativa da filial quando não for ³±±
±±³Eduardo V   ³28/08/2017 ³DRHESOCP-873    ³         ³ a mesma logada   							³±±
±±|Claudinei S.|15/09/2017|DRHESOCP-1149 			  |Ajuste em IntAfast() para não apresentar msg |±±
±±|            |          |                           |caso a rotina for chamada pelo GPE240.       |±±
±±|Cecília Carv|08/01/2018|DRHESOCP-2682    ³         |Ajuste para geração de contrato intermitente |±±
±±|            |          |                 ³         | - evento S-2200.                            |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³InAvPrev  ³ Autor ³ Alessandro Santos     ³ Data ³ 05/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao responsavel por integrar as acoes realizadas na roti³±±
±±³          ³ na de Aviso Previo GPEA925 com o ambiente TAF.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±³          ³ Na rotina GPEA925 - Cadastro de Aviso Previo               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcA - Opcao escolhida (Inclusao, Alteracao ou Exclusao)  ³±±
±±³          ³ oModelGPE - Modelo de dados em uso                         ³±±
±±³          ³ aColsAux  - Conteudo do grid antes das alteracoes          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function InAvPrev(nOpcA, oModelGPE, aColsAux)

	Local aArea    := GetArea()
	Local oModel	:= Nil
	Local cIdAvis	:= ""
	Local cIdFunc	:= FGetIdInt("cpfTrab", "matricula", SRA->RA_CIC, SRA->(RA_FILIAL+RA_MAT)) //Id do funcionario
	Local nIndex 	:= 2
	Local nOpc		:= 0
	Local nI		:= 0
	Local aIncons	:= {}
	Local aChave	:= {}
	Local cFilEnv	:= fTafGetFil(FWCodEmp()+FWCodFil(), @aIncons, , .T.) //Filial de envio TAF

	If !Empty(cFilEnv)
	//Devido a possibilidade de alteracao na Data final do aviso que faz parte da chave do registro,
	//se opcao = alteracao, compara o grid anterior as mudancas com o atual e efetua a exclusao da S2405 se necessario.
		For nI := 1 To Len(aColsAux)
			If aScan(oModelGPE:ACOLS, {|X| X[1]+X[2]+DToS(X[9]) == aColsAux[nI, 1]+aColsAux[nI, 2]+DToS(aColsAux[nI, 3])}) == 0
				nOpc := 5 //Opcao de exclusao

			//Envia exclusao para o TAF
				aChave := {}
				Aadd(aChave, {"C", "CRG_TRABAL", cIdFunc, .T.}) //Id do funcionario
				Aadd(aChave, {"C", "CRG_DTCANC", DToS(aColsAux[nI, 3]), .T.}) //Data cancelamento do aviso

				Begin Transaction
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Funcao para validar se a operacao desejada pode ser realizada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If FTafVldOpe("CRG", nIndex, @nOpc, cFilEnv, @aIncons, aChave, @oModel, "TAFA286", "", 2)
						If nOpc == 5 .OR. nOpc == 7
						/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				  		  ³Efetiva a operacao desejada³
				  	  	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
							FWFormCommit(oModel)
							oModel:DeActivate()
						EndIf
					EndIf
				End Transaction
			EndIf
		Next nI

	//Verifica todas informacoes do grid
		For nI := 1 To oModelGPE:Length()
			oModelGPE:GoLine(nI) //Posiciona objeto na linha corrente

			aChave := {}
			Aadd(aChave, {"C", "CM8_TRABAL", cIdFunc, .T.}) //Id do funcionario
			Aadd(aChave, {"C", "CM8_DTAVIS", DToS(oModelGPE:GetValue("RFY_DTASVP")), .T.}) //Data do Aviso

			If nOpcA == 4 //Inclusao ou alteracao
				Begin Transaction
					If !oModelGPE:IsDeleted() //Linha habilitada
						nOpc := 3 //Opcao inclusao/alteracao

					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					  ³           S2400           ³
					  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Funcao para validar se a operacao desejada pode ser realizada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If FTafVldOpe("CM8", nIndex, @nOpc, cFilEnv, @aIncons, aChave, @oModel, "TAFA263", "", 2)
							If nOpc <> 5
								oModel:LoadValue("MODEL_CM8", "CM8_TRABAL", cIdFunc) 							//Id do funcionario
								oModel:LoadValue("MODEL_CM8", "CM8_DTAVIS", oModelGPE:GetValue("RFY_DTASVP")) 	//Data do aviso
								oModel:LoadValue("MODEL_CM8", "CM8_DTAFAS", oModelGPE:GetValue("RFY_DTPJAV")) 	//Data do afastamento
								oModel:LoadValue("MODEL_CM8", "CM8_TPAVIS", oModelGPE:GetValue("RFY_TPAVIS")) 	//Tipo do aviso
								oModel:LoadValue("MODEL_CM8", "CM8_OBSERV", oModelGPE:GetValue("RFY_OBSAV")) 	//Observacao

							/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							  ³Efetiva a operacao desejada³
							  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
								FWFormCommit(oModel)
								oModel:DeActivate()
							EndIf
						EndIf

					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					  ³           S2405           ³
					  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					//Se existe data de cancelamento, inclui ou altera
						If !Empty(oModelGPE:GetValue("RFY_DTCAP"))

							aChave := {}
							Aadd(aChave, {"C", "CRG_TRABAL", cIdFunc, .T.}) //Id do funcionario
							Aadd(aChave, {"C", "CRG_DTCANC", DToS(oModelGPE:GetValue("RFY_DTCAP")), .T.}) //Data cancelamento do aviso

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Funcao para validar se a operacao desejada pode ser realizada³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If FTafVldOpe("CRG", nIndex, @nOpc, cFilEnv, @aIncons, aChave, @oModel, "TAFA286", "", 2)
								If nOpc <> 5
									oModel:LoadValue("MODEL_CRG", "CRG_TRABAL", cIdFunc) 							//Id do funcionario
									oModel:LoadValue("MODEL_CRG", "CRG_DTCANC", oModelGPE:GetValue("RFY_DTCAP")) 	//Data do cancelamento
									oModel:LoadValue("MODEL_CRG", "CRG_OBSERV", oModelGPE:GetValue("RFY_OBSCAP"))	//Observacao
									oModel:LoadValue("MODEL_CRG", "CRG_MOTCAN", oModelGPE:GetValue("RFY_TPCAP")) 	//Motivo do cancelamento

								/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								  ³Efetiva a operacao desejada³
								  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
									FWFormCommit(oModel)
									oModel:DeActivate()
								EndIf
							EndIf
						EndIf
					Else //Linha deletada
						nOpc := 5 //Opcao de exclusao

					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					  ³           S2400           ³
					  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Funcao para validar se a operacao desejada pode ser realizada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If FTafVldOpe("CM8", nIndex, @nOpc, cFilEnv, @aIncons, aChave, @oModel, "TAFA263", "", 2)
							If nOpc == 5 .OR. nOpc == 7
							/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							  ³Efetiva a operacao desejada³
							  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
								FWFormCommit(oModel)
								oModel:DeActivate()
							EndIf
						EndIf

					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					  ³           S2405           ³
					  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					//Se existe data de cancelamento, deleta
						If !Empty(oModelGPE:GetValue("RFY_DTCAP"))
							aChave := {}
							Aadd(aChave, {"C", "CRG_TRABAL", cIdFunc, .T.}) //Id do funcionario
							Aadd(aChave, {"C", "CRG_DTCANC", DToS(oModelGPE:GetValue("RFY_DTCAP")), .T.}) //Data cancelamento do aviso

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Funcao para validar se a operacao desejada pode ser realizada³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If FTafVldOpe("CRG", nIndex, @nOpc, cFilEnv, @aIncons, aChave, @oModel, "TAFA286", "", 2)
								If nOpc == 5 .OR. nOpc == 7
								/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						  		  ³Efetiva a operacao desejada³
						  	  	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
									FWFormCommit(oModel)
									oModel:DeActivate()
								EndIf
							EndIf
						EndIf
					EndIf
				End Transaction
			ElseIf nOpcA == 5 //Exclusao
				nOpc := 5

				Begin Transaction
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				  ³           S2400           ³
				  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Funcao para validar se a operacao desejada pode ser realizada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If FTafVldOpe("CM8", nIndex, @nOpc, cFilEnv, @aIncons, aChave, @oModel, "TAFA263", "", 2)
						If nOpc == 5 .OR. nOpc == 7
						/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						  ³Efetiva a operacao desejada³
						  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
							FWFormCommit(oModel)
							oModel:DeActivate()
						EndIf
					EndIf

				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				  ³           S2405           ³
				  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				//Se existe data de cancelamento, deleta
					If !Empty(oModelGPE:GetValue("RFY_DTCAP"))
						aChave := {}
						Aadd(aChave, {"C", "CRG_TRABAL", cIdFunc, .T.}) //Id do funcionario
						Aadd(aChave, {"C", "CRG_DTCANC", DToS(oModelGPE:GetValue("RFY_DTCAP")), .T.}) //Data cancelamento do aviso

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Funcao para validar se a operacao desejada pode ser realizada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If FTafVldOpe("CRG", nIndex, @nOpc, cFilEnv, @aIncons, aChave, @oModel, "TAFA286", "", 2)
							If nOpc == 5 .OR. nOpc == 7
							/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						  	  ³Efetiva a operacao desejada³
						  	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
								FWFormCommit(oModel)
								oModel:DeActivate()
							EndIf
						EndIf
					EndIf
				End Transaction
			EndIf
		Next nI
	EndIf

	RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³IntEstab  ³ Autor ³ Alessandro Santos     ³ Data ³ 08/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao responsavel por integrar as acoes realizadas na roti³±±
±±³          ³ na de Estabilidade GPEA923 com o ambiente TAF.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±³          ³ Na rotina GPEA923 - Cadastro de Estabilidade               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcA - Opcao escolhida (Inclusao, Alteracao ou Exclusao)  ³±±
±±³          ³ oModelGPE - Modelo de dados em uso                         ³±±
±±³          ³ aColsAux  - Conteudo do grid antes das alteracoes          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function IntEstab(nOpcA, oModelGPE, aColsAux)

	Local aArea    := GetArea()
	Local oModel	:= Nil
	Local cCodEst	:= ""
	Local cTpEstb	:= ""
	Local cIdFunc	:= FGetIdInt("cpfTrab", "matricula", SRA->RA_CIC, SRA->(RA_FILIAL+RA_MAT)) //Id do funcionario
	Local nIndex 	:= 2
	Local nOpc		:= 0
	Local nI		:= 0
	Local aIncons	:= {}
	Local aChave	:= {}
	Local cFilEnv	:= fTafGetFil(FWCodEmp()+FWCodFil(), @aIncons, , .T.) //Filial de envio Taf

	If !Empty(cFilEnv)
	//Devido a possibilidade de alteracao na Data de cancelamento da estabilidade que faz parte da chave do registro,
	//se opcao = alteracao, compara o grid anterior as mudancas com o atual e efetua a exclusao da S2345 se necessario.
		For nI := 1 To Len(aColsAux)
			If aScan(oModelGPE:ACOLS, {|X| X[1]+X[2]+DToS(X[4])+X[5] == aColsAux[nI, 1]+aColsAux[nI, 2]+DToS(aColsAux[nI, 3])+aColsAux[nI, 4]}) == 0
				cTpEstb := Alltrim(fDescRCC("S053", oModelGPE:GetValue("RFX_TPESTB"), 1, 3, 104, 105))
				cCodEst := FGetIdInt("codMotivoEstabilidade", "", cTpEstb) //Obtem o codigo de estabilidade
				nOpc	:= 5 //Opcao de exclusao

			//Envia exclusao para o TAF
				aChave := {}
				Aadd(aChave, {"C", "CRH_TRABAL", cIdFunc, .T.}) //Id do funcionario
				Aadd(aChave, {"C", "CRH_DTFNES", DToS(aColsAux[nI, 3]), .T.}) //Data de cancelamento
				Aadd(aChave, {"C", "CRH_CODEST", cCodEst, .T.}) //Codigo estabilidade

				Begin Transaction
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Funcao para validar se a operacao desejada pode ser realizada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If FTafVldOpe("CRH", nIndex, @nOpc, cFilEnv, @aIncons, aChave, @oModel, "TAFA287", "", 2)
						If nOpc == 5 .OR. nOpc == 7
						/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				  		  ³Efetiva a operacao desejada³
				  	  	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
							FWFormCommit(oModel)
							oModel:DeActivate()
						EndIf
					EndIf
				End Transaction
			EndIf
		Next nI

	//Verifica todas informacoes do grid
		For nI := 1 To oModelGPE:Length()
			oModelGPE:GoLine(nI) //Posiciona objeto na linha corrente

			cTpEstb := AllTrim(fDescRCC("S053", oModelGPE:GetValue("RFX_TPESTB"), 1, 3, 104, 105))
			cCodEst := FGetIdInt("codMotivoEstabilidade", "", cTpEstb) //Obtem o codigo de estabilidade

			aChave := {}
			Aadd(aChave, {"C", "CM5_TRABAL", cIdFunc, .T.}) //Id do funcionario
			Aadd(aChave, {"C", "CM5_DTESTA", DToS(oModelGPE:GetValue("RFX_DATAI")), .T.}) //Data do Aviso
			Aadd(aChave, {"C", "CM5_CODEST", cCodEst, .T.}) //Codigo estabilidade

			If nOpcA == 4 //Inclusao ou alteracao
				Begin Transaction
					If !oModelGPE:IsDeleted() //Linha habilitada
						nOpc := 3 //Opcao inclusao/alteracao

					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					  ³           S2340           ³
					  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Funcao para validar se a operacao desejada pode ser realizada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If FTafVldOpe("CM5", nIndex, @nOpc, cFilEnv, @aIncons, aChave, @oModel, "TAFA260", "", 2)
							If nOpc <> 5
								oModel:LoadValue("MODEL_CM5", "CM5_TRABAL", cIdFunc) //Id do funcionario
								oModel:LoadValue("MODEL_CM5", "CM5_DTESTA", oModelGPE:GetValue("RFX_DATAI")) //Data inicio estabilidade
								oModel:LoadValue("MODEL_CM5", "CM5_CODEST", cCodEst) //Codigo estabilidade
								oModel:LoadValue("MODEL_CM5", "CM5_OBSERV", oModelGPE:GetValue("RFX_OBSEST")) //Observacao

							/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							  ³Efetiva a operacao desejada³
							  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
								FWFormCommit(oModel)
								oModel:DeActivate()
							EndIf
						EndIf

					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					  ³           S2345           ³
					  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					//Se existe data de cancelamento, inclui ou altera
						If !Empty(oModelGPE:GetValue("RFX_DATAF"))
							aChave := {}
							Aadd(aChave, {"C", "CRH_TRABAL", cIdFunc, .T.}) //Id do funcionario
							Aadd(aChave, {"C", "CRH_DTFNES", DToS(oModelGPE:GetValue("RFX_DATAF")), .T.}) //Data de cancelamento
							Aadd(aChave, {"C", "CRH_CODEST", cCodEst, .T.}) //Codigo estabilidade

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Funcao para validar se a operacao desejada pode ser realizada³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If FTafVldOpe("CRH", nIndex, @nOpc, cFilEnv, @aIncons, aChave, @oModel, "TAFA287", "", 2)
								If nOpc <> 5
									oModel:LoadValue("MODEL_CRH", "CRH_TRABAL", cIdFunc) //Id do funcionario
									oModel:LoadValue("MODEL_CRH", "CRH_DTFNES", oModelGPE:GetValue("RFX_DATAF")) //Data do cancelamento
									oModel:LoadValue("MODEL_CRH", "CRH_CODEST", cCodEst) //Codigo estabilidade
									oModel:LoadValue("MODEL_CRH", "CRH_OBSERV", oModelGPE:GetValue("RFX_OBSEST")) //Observacao

								/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								  ³Efetiva a operacao desejada³
								  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
									FWFormCommit(oModel)
									oModel:DeActivate()
								EndIf
							EndIf
						EndIf
					Else //Linha deletada
						nOpc := 5 //Opcao de exclusao

					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					  ³           S2340           ³
					  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Funcao para validar se a operacao desejada pode ser realizada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If FTafVldOpe("CM5", nIndex, @nOpc, cFilEnv, @aIncons, aChave, @oModel, "TAFA260", "", 2)
							If nOpc == 5 .OR. nOpc == 7
							/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							  ³Efetiva a operacao desejada³
							  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
								FWFormCommit(oModel)
								oModel:DeActivate()
							EndIf
						EndIf

					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					  ³           S2345           ³
					  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					//Se existe data de cancelamento, deleta
						If !Empty(oModelGPE:GetValue("RFX_DATAF"))
							aChave := {}
							Aadd(aChave, {"C", "CRH_TRABAL", cIdFunc, .T.}) //Id do funcionario
							Aadd(aChave, {"C", "CRH_DTFNES", DToS(oModelGPE:GetValue("RFX_DATAF")), .T.}) //Data de cancelamento
							Aadd(aChave, {"C", "CRH_CODEST", cCodEst, .T.}) //Codigo estabilidade

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Funcao para validar se a operacao desejada pode ser realizada³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If FTafVldOpe("CRH", nIndex, @nOpc, cFilEnv, @aIncons, aChave, @oModel, "TAFA287", "", 2)
								If nOpc == 5 .OR. nOpc == 7
								/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						  		  ³Efetiva a operacao desejada³
						  	  	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
									FWFormCommit(oModel)
									oModel:DeActivate()
								EndIf
							EndIf
						EndIf
					EndIf
				End Transaction
			ElseIf nOpcA == 5 //Exclusao
				nOpc := 5

				Begin Transaction
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³           S2340           ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Funcao para validar se a operacao desejada pode ser realizada³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If FTafVldOpe("CM5", nIndex, @nOpc, cFilEnv, @aIncons, aChave, @oModel, "TAFA260", "", 2)
						If nOpc == 5 .OR. nOpc == 7
						/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						³Efetiva a operacao desejada³
						ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
							FWFormCommit(oModel)
							oModel:DeActivate()
						EndIf
					EndIf

					/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³           S2345           ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					//Se existe data de cancelamento, deleta
					If !Empty(oModelGPE:GetValue("RFX_DATAF"))
						aChave := {}
						Aadd(aChave, {"C", "CRH_TRABAL", cIdFunc, .T.}) //Id do funcionario
						Aadd(aChave, {"C", "CRH_DTFNES", DToS(oModelGPE:GetValue("RFX_DATAF")), .T.}) //Data de cancelamento
						Aadd(aChave, {"C", "CRH_CODEST", cCodEst, .T.}) //Codigo estabilidade

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Funcao para validar se a operacao desejada pode ser realizada³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If FTafVldOpe("CRH", nIndex, @nOpc, cFilEnv, @aIncons, aChave, @oModel, "TAFA287", "", 2)
							If nOpc == 5 .OR. nOpc == 7
							/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							³Efetiva a operacao desejada³
							ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
								FWFormCommit(oModel)
								oModel:DeActivate()
							EndIf
						EndIf
					EndIf
				End Transaction
			EndIf
		Next nI
	EndIf

	RestArea(aArea)

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³IntAfast  ³ Autor ³ Alessandro Santos     ³ Data ³ 30/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao responsavel por integrar as acoes realizadas na roti³±±
±±³          ³ na de Afastamento GPEA240 com o ambiente TAF.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±³          ³ Na rotina GPEA240 - Afastamento - S2320   				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function IntAfast(oModel, aErros, aErrosTAF)

	Local aAreaSRA		:= SRA->(GetArea())
	Local aAreaSR8		:= SR8->(GetArea())
	Local aAreaCM6		:= {}
	Local cXml			:= ""
	Local cMsgLog		:= ""
	Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|304|306|701|702|703|711|712|713" //Trabalhador com vinculo
	Local dDtOld		:= cToD("//")
	Local nI			:= 0
	Local nA			:= 0
	Local nLido			:= {}
	Local aFilInTaf		:= {}
	Local aArrayFil		:= {}
	Local aEstb			:= {}
	Local aAfasteSoc	:= {}
	Local aAfastBkp		:= {}
	Local cFilEnv		:= ""
	Local lContinua		:= .T.
	Local lRet			:= .T.
	Local lIntgTAF		:= .F.
	Local lContAfa		:= .F.
	Local oGrid			:= oModel:GetModel("GPEA240_SR8")
	Local oGridSRA		:= oModel:GetModel("GPEA240_SRA")
	Local nLenGrid		:= oGrid:Length()
	Local nOperation	:= oModel:GetOperation()
	Local nSomaDias		:= 0
	Local cFilBkp		:= cFilAnt
	Local cStatus, cStat1, cStat2230	:= ""
	Local c2230INI		:= ""
	Local lExec			:= .T.
	Local cMsgErro		:= ""
	Local lAfast		:= Funname() $ 'GPEA240/GPEA011/MDTA685'
	Local lRetif		:= .F.
	Local lDtFim		:= .F.
	Local lDtIni		:= .F.
	Local cTrabSVinc	:= "201|202|305|308|401|410|701|711|712|721|722|723|731|734|738|741|751|761|771|781|901|902|903"
	Local cCatTSV		:= "701|711|712|741|"
	Local cContAfa		:= ""
	Local cTicket		:= ""
	Local cTafKey		:= ""
	Local cPredeces		:= ""
	Local cTpEnviar		:= "0" //Tipo de xml a ser enviado ao TAF de acordo com a alteração = "1"-Data Início | "2"-Data Fim | "3"-Data Inicio e Data Fim | "4" Retificar ou S-3000 para data fim | "5" Exclusão do registro
	Local cTpEnviado	:= "0" //Tipo de xml enviado ao TAF de acordo com as TAFKEYS        = "3"-Data Início e Data Fim | "4" Início e Fim enviados em momentos diferentes
	Local lTafKeys		:= SR8->(ColumnPos( "R8_TAFKI")) > 0 .And. SR8->(ColumnPos( "R8_TAFKF")) > 0
	Local cKey3000		:= ""
	Local lFimVazio		:= .F.
	Local lEnvAFim		:= .F.
	Local lIniFimDif	:= .F.
	Local lS3000		:= .F.
	Local cDtFant		:= ""

	Local aAfastCtrl	:= {}
	Local nPos			:= 0
	Local lEnvIniFim	:= .F.
	Local lNT15			:= .F.
	Local cVersEnvio	:= ""
	Local cEFDAviso		:= If(cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), SuperGetMv("MV_EFDAVIS",, "0")) //Integracao com TAF)
	Local cVersMw		:= ""
	Local cId			:= ""
	Local cChaveS2230	:= ""
	Local cMsgRJE		:= ""
	Local lAdmPubl		:= .F.
	Local aInfoC		:= {}
	Local cChaveMid		:= ""
	Local cNrInsc		:= ""
	Local cTpInsc		:= ""
	Local aDados		:= {}
	Local cRetfNew		:= ""
	Local cOperNew		:= ""
	Local cOper2230		:= "I"
	Local cRecib2230	:= ""
	Local cRecibAnt		:= ""
	Local cRecibXML		:= ""
	Local cRetf2230		:= "1"
	Local nRec2230		:= 0
	Local cStatNew		:= ""
	Local lExclui		:= .T.
	Local lNovoRJE		:= .F.
	Local lS1000		:= .T.
	Local lSemTAFKeys	:= .F.
	Local cMsgSemTAF	:= ""
	Local lGeraMat		:= .F.
	Local cChv2300		:= ""
	Local cRegInteg		:= ""
	Local lIntAte3d		:= SuperGetMv("MV_AFA3DIA",, .F.) // Integra afastamento opcional até 3 dias? .T. = Integra | .F. Não integra (padrão)
	Local lIntAt15d		:= SuperGetMv("MV_AFA15DI",, .T.) // Integra afastamento opcional até 15 dias? .T. = Integra (padrão) | .F. Não integra
	Local lDiasInsuf	:= .F.
	Local dData1000		:= cToD("//")
	Local lNaoAltInt	:= .F.
	Local lS2231		:= .F.
	Local cStat2231I	:= ""
	Local cIdC9V		:= ""

	Default oModel		:= Nil
	Default aErrosTAF	:= {}

	If lIntegTAF .Or. lMiddleware

		If FindFunction("fVersEsoc")
			fVersEsoc( "S2230", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio, Nil, @cVersMw, @lNT15  )
		EndIf

		nLenGrid	:= oGrid:Length()
		aEstb		:= fGM23SM0()
		If !lMiddleware
			aAreaCM6 := CM6->(GetArea())
			cFilAnt:= oGridSRA:GetValue("RA_FILIAL")
			fGp23Cons(@aFilInTaf, {cFilAnt}, @cFilEnv)
			cFilAnt:= cFilBkp

			If (Len(aFilInTaf[1,3]) > 1) .AND. !EMPTY(cFilEnv) //1XN
				cFilAnt := cFilEnv
			EndIf
		EndIf

		If Empty(cFilEnv)
			cFilEnv:= cFilAnt
		EndIf
		dbSelectArea("SRA")
		SRA->(dbSetOrder(1))
		If !lMiddleware
			DbSelectArea("CM6")
			CM6->(dbSetOrder(2))
		EndIf

		If Type("oModlBkp") == "U"
			oModlBkp	:= oModel:GetModel("GPEA240_SR8")
		Endif

		If SRA->(dbSeek(oGridSRA:GetValue("RA_FILIAL")+oGridSRA:GetValue("RA_MAT")))

			//VERIFICA SE FUNCIONÁRIO JÁ FOI INTEGRADO
			If lMiddleware
				fPosFil( cEmpAnt, oGridSRA:GetValue("RA_FILIAL") )
				aInfoC   := fXMLInfos()
				If LEN(aInfoC) >= 4
					cTpInsc  := aInfoC[1]
					lAdmPubl := aInfoC[4]
					cNrInsc  := aInfoC[2]
				Else
					cTpInsc  := ""
					lAdmPubl := .F.
					cNrInsc  := "0"
				EndIf
			EndIf
			IF !SRA->RA_CATEFD $ cTrabSVinc
				If !lMiddleware
					cStatus := TAFGetStat( "S-2200", SRA->RA_CIC+";"+SRA->RA_CODUNIC,cEmpAnt,cFilEnv)//ADMISSAO POR CADASTRO
				Else
					cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
					cStatus 	:= "-1"
					//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
					GetInfRJE( 2, cChaveMid, @cStatus )
				EndIf
			ELSE
				lGeraMat := ( cVersEnvio >= "9.0" .And. SRA->(ColumnPos("RA_DESCEP")) > 0 .And. SRA->RA_DESCEP == "1" )
				If !lMiddleware
					If cVersEnvio >= "9.0"
						cChv2300 := AllTrim( SRA->RA_CIC ) + ";" + If(lGeraMat, SRA->RA_CODUNIC, "") + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
					Else
						cChv2300 := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
					EndIf
					cStat1 	:= TAFGetStat( "S-2300", cChv2300, cEmpAnt, cFilEnv )
				Else
					cChv2300 := If( lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + dToS( SRA->RA_ADMISSA ))
					cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cChv2300, 40, " ")
					cStat1 	:= "-1"
					//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
					GetInfRJE( 2, cChaveMid, @cStat1 )
				EndIf
			ENDIF

			//Verifica se já existe algum afastamento cadastrado na CUP (Vinculos),
			//se existir registro e a data for igual ao início do afastamento, não envia as tags de início do afastamento no XML, apenas o fim do afastamento
			If !lMiddleware
				CUP->(dbSetOrder(1))
				dbSelectArea("CUP")
				cIdC9V	:= C9V->(C9V_ID)
				IF CUP->(MsSeek(C9V->(C9V_FILIAL) + C9V->(C9V_ID) + C9V->C9V_VERSAO))
					IF(oGrid:GetValue("R8_DATAINI") == CUP->(CUP_DTINIA) .AND. !EMPTY(oGrid:GetValue("R8_DATAFIM")))
						lEnvAFim := .T.
					ENDIF
				ENDIF
			EndIf

			If SRA->RA_CATEFD $ cCatTSV .And. cStat1 == "-1"
				Return .T.
			EndIf
		EndIf

		If cStatus != "4" .And. cStat1 != "4"
			lRet 		:= .F.
			lContinua	:= .F.
			If !lMiddleware
				If (!lAfast, MsgStop(OemToAnsi(STR0057), OemToAnsi(STR0001)),) //##"Não será possível integrar o afastamento com o TAF pois o registro de Admissão ou Carga Inicial deste funcionário ainda não foi efetivado no TAF."##"Atencao"
				cMsgLog := STR0057 //"Não será possível integrar o afastamento com o TAF pois o registro de Admissão ou Carga Inicial deste funcionário ainda não foi efetivado no TAF."
			Else
				If (!lAfast, MsgStop(OemToAnsi(STR0142), OemToAnsi(STR0001)),) //##"Não será possível integrar o afastamento com o Middleware pois o registro de Admissão ou Carga Inicial deste funcionário ainda não foi efetivado no Middleware."##"Atencao"
				cMsgLog := STR0142 //"Não será possível integrar o afastamento com o Middleware pois o registro de Admissão ou Carga Inicial deste funcionário ainda não foi efetivado no Middleware."
			EndIf
		EndIf

		//Verifica se ja foi integrado ao TAF
		lIntgTAF := SR8->(ColumnPos( "R8_INTGTAF")) > 0 .And. !Empty(oGrid:GetValue("R8_INTGTAF"))

		ValidPrazo(oGrid,nOperation)

		If lMiddleware
			cStatus:= "-1"
			dData1000 := oGrid:GetValue("R8_DATAINI")
			If !oGrid:IsFieldUpdated("R8_DATAINI") .And. oGrid:IsFieldUpdated("R8_DATAFIM")
				dData1000 := oGrid:GetValue("R8_DATAFIM")
			Endif
			lS1000 := fVld1000( AnoMes(dData1000), @cStatus )
			If !lS1000 .And. cEFDAviso != "2"
				Do Case
					Case cStatus == "-1" // nao encontrado na base de dados
						If cEFDAviso == "1"
							aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130) )//"Registro do evento X-XXXX não localizado na base de dados"
							lRet	:= .F.
						Else
							Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0130), 1, 0 )//"Registro do evento X-XXXX não localizado na base de dados"
						EndIf
					Case cStatus == "1" // nao enviado para o governo
						If cEFDAviso == "1"
							aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131) )//"Registro do evento X-XXXX não transmitido para o governo"
							lRet	:= .F.
						Else
							Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0131), 1, 0 )//"Registro do evento X-XXXX não transmitido para o governo"
						EndIf
					Case cStatus == "2" // enviado e aguardando retorno do governo
						If cEFDAviso == "1"
							aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132) )//"Registro do evento X-XXXX aguardando retorno do governo"
							lRet	:= .F.
						Else
							Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0132), 1, 0 )//"Registro do evento X-XXXX aguardando retorno do governo"
						EndIf
					Case cStatus == "3" // enviado e retornado com erro
						If cEFDAviso == "1"
							aAdd( aErros, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133) )//"Registro do evento X-XXXX retornado com erro do governo"
							lRet	:= .F.
						Else
							Help( ,, OemToAnsi(STR0001) ,, OemToAnsi(STR0129) + "S-1000" + OemToAnsi(STR0133), 1, 0 )//"Registro do evento X-XXXX retornado com erro do governo"
						EndIf
				EndCase
			EndIf
		EndIf

		//Efetua a integracao com TAF
		If lRet .And. !Empty(cFilEnv)
			For nI := 1 To nLenGrid

				//Restaura a variável lContinua
				lContinua	:= .T.
				aDados		:= {}
				cMsgErro	:= ""

				oGrid:GoLine(nI)

				If oGrid:GetValue("R8_TPEFD") == "40"
					lS2231 := .T.
				ElseIf !lMiddleware
					CM6->(DBGOTOP())
				EndIf

				/* Validação não sera realizada - Integrado no TAF e nao integrado do GPE
				c2230INI := RetCM6(xFilial("CM6", cFilEnv) + C9V->C9V_ID + DTOS(oGrid:GetValue("R8_DATAINI")), 1)
				c2230FIM := RetCM6(xFilial("CM6", cFilEnv) + C9V->C9V_ID + DTOS(oGrid:GetValue("R8_DATAINI")) + DTOS(oGrid:GetValue("R8_DATAFIM")), 2)

				lIntgTAF := SR8->(ColumnPos( "R8_INTGTAF")) > 0 .And. !Empty(oGrid:GetValue("R8_INTGTAF")) .And. !Empty(oGrid:GetValue("R8_TPEFD"))// ja esta integrado com TAF

				IF ((c2230INI <> "-1" .and. !empty(c2230INI) ) .or. (c2230FIM <> "-1" .and. !empty(c2230FIM))) .and. !lIntgTAF // esta integrado no TAF e nao no GPE
					loop
				endIf */

				lRetif := .F.
				lS3000 := .F.
				If !Empty(dDcgIni) .And. oGrid:GetValue("R8_DATAINI") < dDcgIni .And. (Empty(oGrid:GetValue("R8_DATAFIM")) .Or. oGrid:GetValue("R8_DATAFIM") < dDcgIni .Or. oGrid:GetValue("R8_DATAFIM") > dDatabase)
					loop
				EndIf

				If lTafKeys .And. !Empty(oGrid:GetValue("R8_INTGTAF")) .And. (oGrid:GetValue("R8_TAFKI") == oGrid:GetValue("R8_TAFKF")) .And.;
					(!Empty(oGrid:GetValue("R8_TAFKI") ) .AND. !Empty(oGrid:GetValue("R8_TAFKF") ) )
					lEnvIniFim := .T.
				Else
					lEnvIniFim := .F.
				Endif

				If (aScan(oGrid:aHeader, {|x| x[2] == 'R8_INTTAF'}) > 0 .And. oGrid:GetValue("R8_INTTAF") $ "2")
					Loop
				EndIf

				cContAfa	:= oGrid:GetValue("R8_CONTAFA")
				lContAfa	:= !Empty( cContAfa )
				lSemTAFKeys	:= Empty(oGrid:GetValue("R8_TAFKI")) .And. Empty(oGrid:GetValue("R8_TAFKF"))

				//Tratamento para não enviar afastamentos não relacionados ao trabalho menores que 3 dias
				If !oGrid:GetValue("R8_TPEFD") $ "01|02|40"
					aAfastBkp := aClone(aAfastEsoc)

					//Busca os dias de afastamento da continuação
					fGetContAf(oGrid,cContAfa,nLenGrid,@nSomaDias,@aAfastEsoc)

					//Restaura a posição no GRID
					oGrid:GoLine(nI)

					If nLenGrid == nI .And. !Empty(cContAfa)
						nSomaDias += oGrid:GetValue("R8_DURACAO")
					Endif
				Endif

				If (nOperation == 5 .Or. oGrid:IsDeleted(nI)) .And. lContinua .And. lRet
					If lIntgTAF
						//Se as TAFKEYS estiverem preenchidas e forem iguais, significa que Início e Fim foram enviados em uma única vez
						If lTafkeys .And. !Empty(oGrid:GetValue("R8_TAFKI") ) .And. !lS2231
							If Empty(oGrid:GetValue("R8_TAFKF")) .Or. (!Empty(oGrid:GetValue("R8_DATAFIM")) .And. oGrid:GetValue("R8_TAFKI") == oGrid:GetValue("R8_TAFKF"))
								cXml := ""
								If !lMiddleware
									c2230INI := RetCM6(xFilial("CM6", cFilEnv) + C9V->C9V_ID + DTOS(oGrid:GetValue("R8_DATAINI")), 1)

									If c2230INI <> "-1"
										aErros := {}
										cKey3000 := ""
										cKey3000 := oGrid:GetValue("R8_TAFKI")
										cTafKey  := cKey3000
										lS3000	 := .T.

										InExc3000(@cXml,'S-2230',Alltrim(cKey3000),SRA->RA_CIC,SRA->RA_PIS,,)

										AAdd(aAfasteSoc,{nI,"5",.T., oGrid:GetValue("R8_SEQ"), oGrid:GetValue("R8_DURACAO"), oGrid:GetValue("R8_CONTAFA"), oGrid:GetValue("R8_TPEFD")})
										MsgRun( OemToAnsi(STR0110) ,,{|| aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, Alltrim(cKey3000) , "3", "S3000", , /*cTicket*/, , , , "GPE", , /*cPredeces*/ )	} )

										If Len(aErros)> 0
											FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
											lRet:= IIF(aErros[1]!='000026',.F.,.T.)
										ENDIF
									ELSE
										MsgAlert(OemToAnsi(STR0125) , OemToAnsi(STR0001))
										lContinua := .F.
										lRet := .F.
										cMsgLog +=  OemToAnsi(STR0075) //Não enviado ao TAF
										cMsgLog += CRLF
									ENDIF
								Else
									aDados		:= {}
									If Empty(oGrid:GetValue("R8_TAFKF"))
										cChaveS2230	:= Iif(!SRA->RA_CATEFD $ cTrabSVinc .Or. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + dToS( SRA->RA_ADMISSA )) + dToS(oGrid:GetValue("R8_DATAINI")) + "I"
									Else
										cChaveS2230	:= Iif(!SRA->RA_CATEFD $ cTrabSVinc .Or. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + dToS( SRA->RA_ADMISSA )) + dToS(oGrid:GetValue("R8_DATAINI")) + "C"
									EndIf
									cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2230" + Padr(cChaveS2230, 40, " ")
									cStat2230 	:= "-1"
									nRec2230	:= 0
									cMsgRJE		:= ""
									GetInfRJE( 2, cChaveBus, @cStat2230, @cOper2230, @cRetf2230, @nRec2230, @cRecib2230, @cRecibAnt, Nil, Nil, .T. )

									//Retorno pendente impede o cadastro
									If cStat2230 == "2" .And. cEFDAviso != "2"
										cMsgErro 	:= STR0134//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
									//Evento com exclusão sem transmissão
									ElseIf cStat2230 == "99"
										cMsgErro 	:= STR0146//"Operação não será realizada pois há evento de exclusão pendente para transmissão"
									EndIf
									If !Empty(cMsgErro)
										aAdd( aErros, cMsgErro )
										lRet := .F.
									EndIf

									If Empty(cMsgErro) .And. cStat2230 != "-1"
										aInfoC   := fXMLInfos()
										If Len(aInfoC) >= 4
											cId   := aInfoC[3]
										Else
											cId  := ""
										EndIf
										cStatNew := ""
										cOperNew := ""
										cRetfNew := ""
										cRecibAnt:= ""
										cKeyMid	 := ""
										nRecEvt	 := 0
										lNovoRJE := .T.
										aDados	 := {}
										InExc3000(@cXml,'S-2230',cRecib2230,SRA->RA_CIC,SRA->RA_PIS, Nil, Nil, Nil, Nil, cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cId, @cStatNew, @cOperNew, @cRetfNew, @nRecEvt, @lNovoRJE, @cKeyMid, @aErros)
										If Len(aErros) == 0
											GrvTxtArq(alltrim(cXml), "S3000", SRA->RA_CIC)
											If cStat2230 != "4"
												If !( lRet := fExcluiRJE( nRec2230 ) )
													aAdd( aErros, STR0138 )//"Ocorreu um erro na exclusão do registro na tabela RJE"
												EndIf
											Else
												aAdd( aDados, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S3000", Space(6), cRecib2230, cId, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, NIL, NIL } )
												If !( lRet := fGravaRJE( aDados, cXML, lNovoRJE, nRecEvt ))
													aAdd( aErros, STR0138 )//"Ocorreu um erro na gravação do registro na tabela RJE"
												EndIf
											EndIf
										EndIf
									EndIf
								EndIf
							Else
								//"Se o início e fim do afastamento foram enviados em momentos distintos emite aviso solicitando a exclusão em 2 passos.
								If !lMiddleware .And. !IsBlind()
									//A integração com o módulo TAF não foi realizada
									//As datas de início e fim do afastamento foram enviadas ao TAF em momentos distintos, por este motivo a exclusão do registro deverá ser feita em 2 passos.
									//Primeiro limpe a data final do afastamento e confirme a alteração, em seguida exclua o registro de afastamento, desta forma serão enviados os registros de final e início de afastamento separadamente.
									MsgAlert(OemToAnsi(STR0104) + CRLF + OemToAnsi(STR0105) , OemtoAnsi(STR0029))
									lContinua := .F.
									lRet := .F.
									If !lMiddleware
										cMsgLog +=  OemToAnsi(STR0075) //Não enviado ao TAF
									Else
										cMsgLog +=  OemToAnsi(STR0143) //Não enviado ao Middleware
									EndIf
									cMsgLog += CRLF
								ElseIf lMiddleware
									aDados		:= {}
									cXml 		:= ""
									cChaveS2230	:= Iif(!SRA->RA_CATEFD $ cTrabSVinc .Or. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + dToS( SRA->RA_ADMISSA )) + dToS(oGrid:GetValue("R8_DATAINI")) + "F"
									cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2230" + Padr(cChaveS2230, 40, " ")
									cStat2230 	:= "-1"
									nRec2230	:= 0
									cMsgRJE		:= ""
									GetInfRJE( 2, cChaveBus, @cStat2230, @cOper2230, @cRetf2230, @nRec2230, @cRecib2230, @cRecibAnt, Nil, Nil, .T. )

									//Retorno pendente impede o cadastro
									If cStat2230 == "2" .And. cEFDAviso != "2"
										cMsgErro 	:= STR0134//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
									//Evento com exclusão sem transmissão
									ElseIf cStat2230 == "99"
										cMsgErro 	:= STR0146//"Operação não será realizada pois há evento de exclusão pendente para transmissão"
									EndIf
									If !Empty(cMsgErro)
										aAdd( aErros, cMsgErro )
										lRet := .F.
									EndIf

									If Empty(cMsgErro) .And. cStat2230 != "-1"
										aInfoC   := fXMLInfos()
										If Len(aInfoC) >= 4
											cId   := aInfoC[3]
										Else
											cId  := ""
										EndIf
										cStatNew := ""
										cOperNew := ""
										cRetfNew := ""
										cRecibAnt:= ""
										cKeyMid	 := ""
										nRecEvt	 := 0
										lNovoRJE := .T.
										aDados	 := {}
										InExc3000(@cXml,'S-2230',cRecib2230,SRA->RA_CIC,SRA->RA_PIS, Nil, Nil, Nil, Nil, cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cId, @cStatNew, @cOperNew, @cRetfNew, @nRecEvt, @lNovoRJE, @cKeyMid, @aErros)
										If Len(aErros) == 0
											GrvTxtArq(alltrim(cXml), "S3000", SRA->RA_CIC)
											If cStat2230 != "4"
												If !( lExclui := fExcluiRJE( nRec2230 ) )
													aAdd( aErros, STR0138 )//"Ocorreu um erro na exclusão do registro na tabela RJE"
												EndIf
											Else
												aAdd( aDados, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S3000", Space(6), cRecib2230, cId, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, NIL, NIL } )
												If !( lExclui := fGravaRJE( aDados, cXML, lNovoRJE, nRecEvt ))
													aAdd( aErros, STR0138 )//"Ocorreu um erro na gravação do registro na tabela RJE"
												EndIf
											EndIf
										EndIf
									EndIf

									aDados		:= {}
									cXml 		:= ""
									cMsgErro	:= ""
									cChaveS2230	:= Iif(!SRA->RA_CATEFD $ cTrabSVinc .Or. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + dToS( SRA->RA_ADMISSA )) + dToS(oGrid:GetValue("R8_DATAINI")) + "I"
									cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2230" + Padr(cChaveS2230, 40, " ")
									cStat2230 	:= "-1"
									nRec2230	:= 0
									cMsgRJE		:= ""
									GetInfRJE( 2, cChaveBus, @cStat2230, @cOper2230, @cRetf2230, @nRec2230, @cRecib2230, @cRecibAnt, Nil, Nil, .T. )

									//Retorno pendente impede o cadastro
									If cStat2230 == "2" .And. cEFDAviso != "2"
										cMsgErro 	:= STR0134//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
									//Evento com exclusão sem transmissão
									ElseIf cStat2230 == "99"
										cMsgErro 	:= STR0146//"Operação não será realizada pois há evento de exclusão pendente para transmissão"
									EndIf
									If !Empty(cMsgErro)
										aAdd( aErros, cMsgErro )
										lRet := .F.
									EndIf

									If Empty(cMsgErro) .And. cStat2230 != "-1"
										aInfoC   := fXMLInfos()
										If Len(aInfoC) >= 4
											cId   := aInfoC[3]
										Else
											cId  := ""
										EndIf
										cStatNew := ""
										cOperNew := ""
										cRetfNew := ""
										cRecibAnt:= ""
										cKeyMid	 := ""
										nRecEvt	 := 0
										lNovoRJE := .T.
										aDados	 := {}
										InExc3000(@cXml,'S-2230',cRecib2230,SRA->RA_CIC,SRA->RA_PIS, Nil, Nil, Nil, Nil, cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cId, @cStatNew, @cOperNew, @cRetfNew, @nRecEvt, @lNovoRJE, @cKeyMid, @aErros)
										If Len(aErros) == 0
											GrvTxtArq(alltrim(cXml), "S3000", SRA->RA_CIC)
											If cStat2230 != "4"
												If !( lExclui := fExcluiRJE( nRec2230 ) )
													aAdd( aErros, STR0138 )//"Ocorreu um erro na exclusão do registro na tabela RJE"
												EndIf
											Else
												aAdd( aDados, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S3000", Space(6), cRecib2230, cId, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, NIL, NIL } )
												If !( lExclui := fGravaRJE( aDados, cXML, lNovoRJE, nRecEvt ))
													aAdd( aErros, STR0138 )//"Ocorreu um erro na gravação do registro na tabela RJE"
												EndIf
											EndIf
										EndIf
									EndIf
									If !lExclui
										lRet := lExclui
									EndIf
								EndIf
							Endif
						Else
							lContinua := .F.
							If !lMiddleware
								lRet := MsgYesNo( OemToAnsi(STR0082) + CRLF + OemToAnsi(STR0081), OemToAnsi(STR0001) ) //Após esta exclusão é necessário excluir o evento no TAF para envio ao RET, Deseja continuar?"
							Else
								lRet := MsgYesNo( OemToAnsi(STR0144) + CRLF + OemToAnsi(STR0081), OemToAnsi(STR0001) ) //Após esta exclusão é necessário excluir o evento no Middleware para envio ao RET, Deseja continuar?"
							EndIf
							If !lRet
								cMsgLog +=  OemToAnsi(STR0086)
								cMsgLog += CRLF
							Endif
						Endif
					Endif
				//Se for uma Inclusão/Alteração
				ElseIf nOperation == 4

					//Se o campo R8_TPEFD estiver em branco o afastamento não será enviado ao TAF.
					lContinua :=  !Empty(oGrid:GetValue("R8_TPEFD"))

					//cStat2230 := TAFGetStat( "S-2230", SRA->RA_CODUNIC+";"+oGrid:GetValue("R8_SEQ")+";"+"INI"+";"+ If(lIntgTAF, DTOS(oGrid:GetValue("R8_INTGTAF")),),cEmpAnt,cFilEnv)
					If lContinua .And. lRet
						/*Não é possível registrar o início do afastamento em data futura, exceto se o motivo do afastamento for férias [15] cuja data de início
						não ultrapasse 60 dias do envio do evento.
						*/
						If oGrid:GetValue("R8_DATAINI") <= dDatabase .Or. (oGrid:GetValue('R8_TPEFD') == '15' .And. ( oGrid:GetValue('R8_DATAINI') + 1 ) - dDataBase <= 60 )
							/*Conforme alteração no MOS:
							O término do afastamento poderá ser registrado o retorno em data futura não superior a 15 dias da data do início,
							exceto no caso de férias, hipótese em que a data de retorno não poderá ultrapassar 60 dias do envio do evento.
							*/
							If !Empty(oGrid:GetValue("R8_DATAFIM")) .And. ( ;
								oGrid:GetValue("R8_DATAFIM") <= dDatabase .OR. ;
								(lNT15 .And. lMVDtFimA) .Or. ;
								(oGrid:GetValue('R8_TPEFD') == '15' .And. ( oGrid:GetValue('R8_DATAFIM') - dDataBase + 1) <= 60) .Or. ;
								(( oGrid:GetValue('R8_DATAFIM') - oGrid:GetValue('R8_DATAINI') + 1 ) <= 15) ;
								)
								lDtFim := .T.
								lContinua	:= .T.
							Else
								lDtFim := .F.
							Endif
						/* Prorrogação da Licença maternidade
							cuja data de inicio não ultrapasse 120 dias do envio do evento */
						ElseIf (oGrid:GetValue('R8_TPEFD') == '18' .And. ( oGrid:GetValue('R8_DATAINI') + 1 ) - dDataBase <= 120 )
							If !Empty(oGrid:GetValue("R8_DATAFIM"))
								lDtFim := .T.
								lContinua	:= .T.
							Else
								lDtFim := .F.
							EndIf
						Else
							lContinua	:= .F.
							cMsgLog	+= OemToAnsi(STR0083) //"A data de início do afastamento não pode ser superior a data base do sistema"
							cMsgLog	+= CRLF
							cMsgLog	+= OemToAnsi(STR0149) //"Caso exista cálculo de férias com início superior a 60 dias, este cálculo deverá ser excluído para que o afastamento/atestado seja incluído."
							cMsgLog	+= CRLF
							If cEFDAviso == "0"
								cMsgLog := CHR(10)+CHR(13) + OemToAnsi(STR0255) + oGrid:GetValue('R8_SEQ') + " - " + DtoC(oGrid:GetValue('R8_DATAINI')) + CHR(10)+CHR(13) + cMsgLog
								fEFDMsgErro(cMsgLog)
							ElseIf cEFDAviso == "1"
								lRet := .F.
							EndIf
						Endif
					Endif

					If lS2231
						If lContinua .And. lRet 
							//Pesquisa o status do evento de início e fim de afastamento
							cStat2231I	:= fRetV72(xFilial("C9V", cFilEnv) + cIdC9V + DTOS(oGrid:GetValue("R8_DATAINI")) + space(8) + "1", 2)

							//Se evento de início não foi integrado ou
							//Se início já foi integrado e campos do eSocial alterados. Só fará o envio se o fim não for estiver enviado.
							If Empty(oGrid:GetValue("R8_INTGTAF")) .Or.; 
							(!Empty(oGrid:GetValue("R8_INTGTAF")) .And. Empty(oGrid:GetValue("R8_TAFKF")) .And. (oGrid:isFieldUpdated('R8_TPCES') .Or. oGrid:isFieldUpdated('R8_CNPJCES')))
								If cStat2231I <> "-1"
									lRetif := .T.
								EndIf
								lRet := fInt2231I(oGrid, cFilEnv, @aErros, lRetif)
								If lRet
									fEFDMsg()
								EndIf
							ElseIf !Empty(oGrid:GetValue("R8_TAFKF")) .And. (oGrid:isFieldUpdated('R8_TPCES') .Or. oGrid:isFieldUpdated('R8_CNPJCES'))
								//cMsgLog += "Registro de término do evento já foi enviado ao TAF e alterações nos campos CNPJ do cessionário e Tipo de Cessão não são permitidas. Caso a alteração seja necessária, remova o término do afastamento."
								cMsgLog += OemToAnsi(STR0313)
								lRet := .F.
								loop
							EndIf
						EndIf
					Else
						// Validação para verificar se está tentando deletar a data fim de um afastamento que já foi enviado com data início e fim juntas.
						If  lContinua .AND. lRet .AND. lTafKeys .AND. !Empty( oGrid:GetValue("R8_DATAINI") ) .AND. ;
							!Empty( oGrid:GetValue("R8_TAFKF") ) .AND. oGrid:GetValue("R8_TAFKI") == oGrid:GetValue("R8_TAFKF")

								cDtFant := fDtFant( oGridSRA:GetValue("RA_FILIAL"), oGridSRA:GetValue("RA_MAT"), oGrid:GetValue("R8_DATAINI") )

								If Empty(cDtFant) .OR. Empty( oGrid:GetValue("R8_DATAFIM") )
									lRet 	:= .F.
									cMsgLog	+= OemToAnsi(STR0128) // "Não é permitido remover a data fim de um afastamento que já foi enviado de forma completa. Para realizar essa operação, é necessário excluir a linha atual e incluir uma nova linha."
									cMsgLog	+= CRLF
								ENDIF
						ENDIF

						If ( aScan(nLido, {|x| x == nI}) > 0 ) .Or. ( lExec := (ValidModf(oGrid, nOperation, @cTpEnviar, nI, cTrabSVinc, lAdmPubl, cTpInsc, cNrInsc, cVersEnvio, lGeraMat)) ) .And. lContinua .And. lRet
							//Adiciona Id do GRID no Array para geração do XML
							If ( aScan(aAfasteSoc, {|x| x[1] == nI}) == 0 )

								//Se estiver integrado ao TAF entende-se que se trata de uma alteração e não uma inclusão
								//Caso NÃO esteja com as TAFKEYS preenchidas permite a gravação do afastamento mas não envia ao TAF.
								//A Não ser que a alteração seja somente para informar a data final do afastamento, neste caso enviaremos ao TAF mesmo sem as TAFKEYS
								//Ou para informar o início e fim de um afastamento que já foi integrado com o taf, porém, foi excluído (no TAF) e está sendo reintegrado, como se fosse um novo afastamento.

								if lIntgTAF .And. ( lTafKeys .And. Empty(oGrid:GetValue("R8_TAFKI")) .And. Empty(oGrid:GetValue("R8_TAFKF")) .Or. !lTafKeys ) .And. !(cTpEnviar $ "0|2|3")
									lContinua := .F.
									//"Se já foi integrado anteriormente e não gravou nas TAFKEYS não integra ao TAF, mas permite a gravação do GPE
									If !IsBlind()
										MsgAlert(OemToAnsi(STR0102), OemtoAnsi(STR0029)) //A integração com o módulo TAF não foi realizada # Após a alteração do registro efetue a manutenção no TAF : eSocial\Eventos Não periódicos\Afastamento Temp.
									EndIf
								EndIf

								//Se alterou os campos pertinentes ao eSocial e também a data de retorno do afastamento deveria gerar 2 vezes o XML, 1 com data fim e outro com data de início
								//Por este motivo impediremos a gravação do afastamento.
								If lTafkeys .And. lContinua
									If 	cTpEnviar == "3" .And.;
										!Empty(oGrid:GetValue("R8_INTGTAF"))  .And.;
										(oGrid:GetValue("R8_TAFKI") <> oGrid:GetValue("R8_TAFKF")) .And.;
										(!Empty(oGrid:GetValue("R8_TAFKI") ) .AND. !Empty(oGrid:GetValue("R8_TAFKF") ) )

										//"Se não encontrar os campos TAKFEYS não envia o afastamento ao TAF
										If !IsBlind()
											MsgAlert(OemToAnsi(STR0103), OemtoAnsi(STR0029)) //A integração com o módulo TAF não foi realizada # Não é permitido alterar campos do afastamento juntamente com o a data fim, uma vez que o evento de afastamento temporário foi enviado ao TAF em 2 momentos."
											lContinua := .F.
											lRet	  := .F.
											If !lMiddleware
												cMsgLog +=  OemToAnsi(STR0075) //Não enviado ao TAF
											Else
												cMsgLog +=  OemToAnsi(STR0143) //Não enviado ao Middleware
											EndIf
											cMsgLog += CRLF
										EndIf
									Else
										AAdd(aAfasteSoc,{nI,cTpEnviar,lDtFim, oGrid:GetValue("R8_SEQ"), oGrid:GetValue("R8_DURACAO"), oGrid:GetValue("R8_CONTAFA"), oGrid:GetValue("R8_TPEFD"),lEnvIniFim})
									Endif
								ElseIf !lTafKeys .And. cTpEnviar == "2"
									AAdd(aAfasteSoc,{nI,cTpEnviar,lDtFim, oGrid:GetValue("R8_SEQ"), oGrid:GetValue("R8_DURACAO"), oGrid:GetValue("R8_CONTAFA"), oGrid:GetValue("R8_TPEFD"),lEnvIniFim})
								Endif
							Endif
						EndIf
					EndIf
				Endif
			Next nI

			If lRet .And. LEN(aAfasteSoc) > 0
				aSort(aAfasteSoc,,,{ | x,y | x[1] < y[1] } )

				For nA := 1 To Len(aAfasteSoc)

					IF EMPTY(aAfasteSoc[nA, 6])
						//Adiciona registros sem preenchimento de sequência no array de controle
						aAdd(aAfastCtrl, {aAfastEsoc[nA, 4], aAfastEsoc[nA, 5]})
					ELSE
						//Obtém posição das sequências (se houver) do array de controle
						nPos := aScan(aAfastCtrl, {|x| aAfastEsoc[nA, 6] $ x[1] })
						IF nPos > 0
							//Se existir registros de CONTINUAÇÃO na SEQUÊNCIA pesquisada no array de controle, concatena na posição X do array.
							aAfastCtrl[nPos, 1] += "|" + aAfastEsoc[nA, 4]
							aAfastCtrl[nPos, 2] += aAfastEsoc[nA, 5]
						ENDIF
					ENDIF
				NEXT nA

				For nA := 1 to Len(aAfasteSoc)
					aDados := {}
					lRetif := .F.
					cRecibAnt := ""
					oGrid:GoLine(aAfasteSoc[nA,1])	//Posiciona no registro a ser gerado o XML
					lIniFimDif := ( (!EMPTY(oGrid:GetValue("R8_TAFKI")) .And. !EMPTY(oGrid:GetValue("R8_TAFKF")) .And. oGrid:GetValue("R8_TAFKI") <> oGrid:GetValue("R8_TAFKF")  ) )
					cTpEnviado := "0"

					//Afastamento por motivo de doença não relacionada ao trabalho
					If !(aAfasteSoc[nA, 7] $ "01|02")
						If cVersEnvio >= "9.0" .And. !lIntAt15d .And. aAfasteSoc[nA, 7] == "03" // Não deseja enviar afastamentos até 15 dias
							lDiasInsuf := aAfasteSoc[nA, 5] <= 15 .And. nSomaDias <= 15 .And. aScan(aAfastCtrl, {|x| aAfasteSoc[nA, 4] $ x[1] .And. x[2] > 15}) == 0
						Else
							If lIntAte3d
								lDiasInsuf := aAfasteSoc[nA, 5] < 3 .And. nSomaDias < 3 .And. aScan(aAfastCtrl, {|x| aAfasteSoc[nA, 4] $ x[1] .And. x[2] >= 15}) == 0
							Else
								lDiasInsuf := aAfasteSoc[nA, 5] < 3 .And. aScan(aAfastCtrl, {|x| aAfasteSoc[nA, 4] $ x[1] .And. x[2] >= 15}) == 0
							EndIf
						EndIf
					EndIf

					//Não tiver sido alterado e integrado com o TAF
					lNaoAltInt := Iif(FindFunction("fVlAltEsoc"), !fVlAltEsoc(oGrid), !oGrid:IsUpdated(aAfasteSoc[nA,1])) .AND. (!EMPTY(oGrid:GetValue("R8_INTGTAF")) .OR. (EMPTY(oGrid:GetValue("R8_INTGTAF")) .AND. !EMPTY(oGrid:GetValue("R8_TAFKI")) .AND. !EMPTY(oGrid:GetValue("R8_TAFKF"))))

					//Não integra quando...
					//for diferente de exclusão e ( Não tiver sido alterado e integrado - OU - numero de dias for insuficiente para integrar )
					//Ou se houver alteração no campo data fim, ou dias de duração, e o tipo de envio = 2 (Enviar somente fim) e lDtFim (ref. Posição 3) = falso
					If  (	aAfasteSoc[nA, 2] <> "5" .AND. ( lNaoAltInt .OR. lDiasInsuf ) );
						.OR. ;
						(	(oGrid:IsFieldUpdated("R8_DATAFIM") .Or. oGrid:IsFieldUpdated("R8_DURACAO")) .AND. aAfasteSoc[nA,2] == "2" .AND. !aAfasteSoc[nA,3])

						LOOP
					EndIf

					If aAfasteSoc[nA,2] <> "5"
						cXml := ""
						If !lMiddleware
							cXml +='<eSocial>'
							cXml +='<evtAfastTemp>'
						EndIf

						If SRA->(dbSeek(oGridSRA:GetValue("RA_FILIAL")+oGridSRA:GetValue("RA_MAT")))
							//Verifica se vai gerar um registro de retificacao	(Ja foi integrado com o taf e não é apenas informação de término)
							If !Empty(oGrid:GetValue("R8_INTGTAF")) .AND. (!EMPTY(oGrid:GetValue("R8_TAFKI")) .OR. !EMPTY(oGrid:GetValue("R8_TAFKF"))) .And.;
								( aAfasteSoc[nA,2] <> "2" .Or. (Len(aAfasteSoc[nA]) > 7 .And. aAfasteSoc[nA,8] ) ) .Or. lIniFimDif

								lRetif := .T.
								If aAfasteSoc[nA,7] == "15"
									cStat2230 := RetCM6(xFilial("CM6", cFilEnv) + C9V->C9V_ID + DTOS(oGrid:GetValue("R8_DATAINI")) + DTOS(oGrid:GetValue("R8_DATAFIM"))+"1", 2)
									If cStat2230 <> "4"
										lRetif := .F.
									Endif
								Endif
								//Se as TAFKEYS estiverem preenchidas e forem diferentes, significa que Início e Fim foram enviados em momentos diferentes
								lFimVazio := .F.
								If lIniFimDif
									If aAfasteSoc[nA,2] == "4"
										cTpEnviado := "4"
										lRetif := .F.
									Elseif !lEnvAFim .And. !aAfastEsoc[nA,3]
										cTpEnviado := "3"
										lFimVazio := .T.
									EndIf
								Else
									If aAfasteSoc[nA,2] == "4"
										lFimVazio := .T.
										aAfastEsoc[nA,3] := .T.
									Endif
								Endif

								If !lMiddleware .And. lRetif
									cXml +='<ideEvento>'
									cXml +='	<indRetif>2</indRetif>'
									cXml +='</ideEvento>'
								EndIf

							EndIf
							If !lMiddleware
								cXml +='<ideVinculo>'
								cXml +='<cpfTrab>'+SRA->RA_CIC+'</cpfTrab>'
								If cVersEnvio < "9.0"
									cXml +='<nisTrab>'+SRA->RA_PIS+'</nisTrab>'
								EndIf
								If SRA->RA_CATEFD $ cTrabVincu .Or. lGeraMat
									cXml +='<matricula>'+SRA->RA_CODUNIC+'</matricula>'
								Else
									cXml +='<codCateg>'+ SRA->RA_CATEFD +'</codCateg>'
								EndIf
								cXml +='</ideVinculo>'
							EndIf
						EndIf
						If !lMiddleware
							cXml +='<infoAfastamento>'
						EndIf

						If lMiddleware
							aInfoC   := fXMLInfos()
							If Len(aInfoC) >= 4
								cId   := aInfoC[3]
							Else
								cId  := ""
							EndIf

							If ( ((( aAfasteSoc[nA,2] <> "2" .Or. lRetif ) .Or. !lIntgTAF) .And. !lEnvAFim) .And. !(aAfastEsoc[nA,3] .And. lIniFimDif))
								If (aAfastEsoc[nA,3] .OR. lEnvAFim )
									cChaveS2230	:= Iif(!SRA->RA_CATEFD $ cTrabSVinc .Or. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + dToS( SRA->RA_ADMISSA )) + dToS(oGrid:GetValue("R8_DATAINI")) + "C"
								Else
									cChaveS2230	:= Iif(!SRA->RA_CATEFD $ cTrabSVinc .Or. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + dToS( SRA->RA_ADMISSA )) + dToS(oGrid:GetValue("R8_DATAINI")) + "I"
								EndIf
							Else
								cChaveS2230	:= Iif(!SRA->RA_CATEFD $ cTrabSVinc .Or. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + dToS( SRA->RA_ADMISSA )) + dToS(oGrid:GetValue("R8_DATAINI")) + "F"
							EndIf
							cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2230" + Padr(cChaveS2230, 40, " ")
							cStat2230 	:= "-1"
							nRec2230	:= 0
							GetInfRJE( 2, cChaveBus, @cStat2230, @cOper2230, @cRetf2230, @nRec2230, @cRecib2230, @cRecibAnt, Nil, Nil, .T. )

							//Retorno pendente impede o cadastro
							If cStat2230 == "2" .And. cEFDAviso != "2"
								cMsgErro 	:= STR0134//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
							//Evento com exclusão sem transmissão
							ElseIf cStat2230 == "99"
								cMsgErro 	:= STR0146//"Operação não será realizada pois há evento de exclusão pendente para transmissão"
							//Evento sem transmissão, irá sobrescrever o registro na fila
							ElseIf cStat2230 $ "1/3"
								cOperNew 	:= cOper2230
								cRetfNew	:= cRetf2230
								cStatNew	:= "1"
								lNovoRJE	:= .F.
							//Evento diferente de exclusão transmitido, irá gerar uma retificação
							ElseIf cOper2230 != "E" .And. cStat2230 == "4"
								cOperNew 	:= "A"
								cRetfNew	:= "2"
								cStatNew	:=  "1"
								lNovoRJE	:= .T.
							//Será tratado como inclusão
							Else
								cOperNew 	:= "I"
								cRetfNew	:= "1"
								cStatNew	:= "1"
								lNovoRJE	:= .T.
							EndIf
							If !Empty(cMsgErro)
								aAdd( aErros, cMsgErro )
								lRet := .F.
							EndIf
							If cRetfNew == "2"
								If cStat2230 == "4"
									cRecibXML 	:= cRecib2230
									cRecibAnt	:= cRecib2230
									cRecib2230	:= ""
								Else
									cRecibXML 	:= cRecibAnt
								EndIf
							EndIf

							aAdd( aDados, { xFilial("RJE", cFilAnt), cFilAnt, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2230", Space(6), cChaveS2230, cId, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, cRecib2230, cRecibAnt } )

							cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtAfastTemp/v" + cVersMw + "'>"
							cXML += 	"<evtAfastTemp Id='" + cId + "'>"
							fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, 1, 1, "12" } )
							fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )

							cXml +='<ideVinculo>'
							cXml +='<cpfTrab>'+SRA->RA_CIC+'</cpfTrab>'
							If cVersEnvio < "9.0"
								cXml +='<nisTrab>'+AllTrim(SRA->RA_PIS)+'</nisTrab>'
							EndIf
							If SRA->RA_CATEFD $ cTrabVincu .Or. lGeraMat
								cXml +='<matricula>'+SRA->RA_CODUNIC+'</matricula>'
							Else
								cXml +='<codCateg>'+ SRA->RA_CATEFD +'</codCateg>'
							EndIf
							cXml +='</ideVinculo>'
							cXml +='<infoAfastamento>'
						EndIf

						//---------------------------------------
						//INFORMACAO DE RETIFICACAO DE AFASTAMENTO
						//---------------------------------------
						If lRetif .And. !Empty(oGrid:GetValue("R8_ORIGALT"))
							cXml +='<infoRetif>'
							cXml +='	<origRetif>'+ oGrid:GetValue("R8_ORIGALT")+'</origRetif>'
							If !Empty(oGrid:GetValue("R8_TPPROC"))
								cXml +='	<tpProc>'+ AllTrim(oGrid:GetValue("R8_TPPROC"))+'</tpProc>'
								cXml +='	<nrProc>'+ AllTrim(oGrid:GetValue("R8_NRPRCJU"))+'</nrProc>'
							EndIf
							cXml +='</infoRetif>'
						EndIf

						//---------------------------------------
						//INFORMACAO DE INICIO DE AFASTAMENTO
						//---------------------------------------
						//Essa informacao nao eh gerada quando a alteracao eh somente para informar o termino do afastamento
						//Mas pode ser gerada caso seja feita a retificacao do afastamento
						If !lMiddleware
							cStat2230   := RetCM6(xFilial("CM6", cFilEnv) + C9V->C9V_ID + DTOS(oGrid:GetValue("R8_DATAINI")), 1)
						Else
							cChaveS2230	:= Iif(!SRA->RA_CATEFD $ cTrabSVinc .Or. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + dToS( SRA->RA_ADMISSA )) + dToS(oGrid:GetValue("R8_DATAINI")) + "I"
							cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2230" + Padr(cChaveS2230, 40, " ")
							cStat2230 	:= "-1"
							GetInfRJE( 2, cChaveBus, @cStat2230, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.)
						EndIf
						If ((( aAfasteSoc[nA,2] <> "2" .Or. lRetif ) .Or. !lIntgTAF) .And. !lEnvAFim) .And. !(aAfastEsoc[nA,3] .And. lIniFimDif) .Or. (cStat2230 == "-1" .And. !lEnvAFim)
							lDtIni := .T.
							cXml +='<iniAfastamento>'
							If !lMiddleware
								cXml +='<dtIniAfast>'+ DTOS(oGrid:GetValue("R8_DATAINI"))+'</dtIniAfast>'
							Else
								cXml +='<dtIniAfast>'+ SubStr( DTOS(oGrid:GetValue("R8_DATAINI")), 1, 4 ) + "-" + SubStr( DTOS(oGrid:GetValue("R8_DATAINI")), 5, 2 ) + "-" + SubStr( DTOS(oGrid:GetValue("R8_DATAINI")), 7, 2 )+'</dtIniAfast>'
							EndIf
							cXml +='<codMotAfast>'+ oGrid:GetValue("R8_TPEFD")+'</codMotAfast>'

							If Empty(oGrid:GetValue("R8_CONTAFA")) .Or. Alltrim(oGrid:GetValue("R8_CONTAFA")) $ "0/000/00/"
								cXml +='<infoMesmoMtv>N</infoMesmoMtv>'
							Else
								cXml +='<infoMesmoMtv>S</infoMesmoMtv>'
							EndIf
							If oGrid:GetValue("R8_TPEFD") $ "01/03" .And. (!lMiddleware .Or. !Empty(oGrid:GetValue("R8_TIPOAT")))
								cXml += '<tpAcidTransito>'+ oGrid:GetValue("R8_TIPOAT")+'</tpAcidTransito>'
							EndIf
							If !lMiddleware .Or. !Empty(fSubst(oGrid:GetValue("R8_OBSAFAS")))
								cXml +='<observacao>'+ fSubst(oGrid:GetValue("R8_OBSAFAS"))+'</observacao>'
							EndIf
							If cVersEnvio >= "9.0"
								If SR8->(ColumnPos( "R8_DTINIF")) > 0
									If oGrid:GetValue("R8_TPEFD") == "15" .And. oGrid:GetValue("R8_DATAINI") >= Ctod("19/07/2021") .And. ;
									SRA->RA_CATEFD $ fCatTrabEFD("TCV")+"304|310|312|410" .And. !(SRA->RA_VIEMRAI $ "30|31|35") //férias
										cXml +='<perAquis>'
										If !lMiddleware
											cXml +='<dtInicio>'+ DTOS(oGrid:GetValue("R8_DTINIF"))+'</dtInicio>'
										Else
											cXml +='<dtInicio>'+ SubStr( DTOS(oGrid:GetValue("R8_DTINIF")), 1, 4 ) + "-" + SubStr( DTOS(oGrid:GetValue("R8_DTINIF")), 5, 2 ) + "-" + SubStr( DTOS(oGrid:GetValue("R8_DTINIF")), 7, 2 )+'</dtInicio>'
										EndIf
										If !Empty(oGrid:GetValue("R8_DTFMF"))
											If !lMiddleware
												cXml +='<dtFim>'+ DTOS(oGrid:GetValue("R8_DTFMF"))+'</dtFim>'
											Else
												cXml +='<dtFim>'+ SubStr( DTOS(oGrid:GetValue("R8_DTFMF")), 1, 4 ) + "-" + SubStr( DTOS(oGrid:GetValue("R8_DTFMF")), 5, 2 ) + "-" + SubStr( DTOS(oGrid:GetValue("R8_DTFMF")), 7, 2 )+'</dtFim>'
											EndIf
										EndIf
										cXml +='</perAquis>'
									ElseIf oGrid:GetValue("R8_TPEFD") == "22" //Mandato eletivo
										cXml +='<infoMandElet>'
										cXml +='<cnpjMandElet>'+ oGrid:GetValue("R8_CNPJE") +'</cnpjMandElet>'
										If SRA->RA_CATEFD == "301"
											If oGrid:GetValue("R8_REMUN") == "1"
												cXml +='<indRemunCargo>S</indRemunCargo>'
											ElseIf oGrid:GetValue("R8_REMUN") == "2"
												cXml +='<indRemunCargo>N</indRemunCargo>'
											EndIf
										EndIf
										cXml +='</infoMandElet>'
									EndIf
								EndIf
							ElseIf oGrid:GetValue("R8_TPEFD") $ "01/03/35"
								If !lNT15
									cXml +='<infoAtestado>'
									If !lMiddleware
										cXml +='	<codCID>'+ oGrid:GetValue("R8_CID")+'</codCID>'
									Else
										cXml +='	<codCID>'+ AllTrim(StrTran(oGrid:GetValue("R8_CID"), ".", "")) +'</codCID>'
									EndIf
									cXml +='	<qtdDiasAfast>'+ Alltrim(Str(oGrid:GetValue("R8_DURACAO")))+'</qtdDiasAfast>'
									cXml +='	<emitente>'
									cXml +='	<nmEmit>'+ SubStr(fSubst(oGrid:GetValue("R8_NMMED")),1,70)+'</nmEmit>'
									cXml +='	<ideOC>'+ oGrid:GetValue("R8_IDEOC")+'</ideOC>'
									cXml +='	<nrOc>'+ fSubst(oGrid:GetValue("R8_CRMMED"))+'</nrOc>'
									cXml +='	<ufOC>'+ oGrid:GetValue("R8_UFCRM ")+'</ufOC>'
									cXml +='	</emitente>'
									cXml +='</infoAtestado>'
								Else
									cXml +='<infoAtestado>'
									If !Empty(oGrid:GetValue("R8_CID"))
										If !lMiddleware
											cXml +='	<codCID>'+ oGrid:GetValue("R8_CID")+'</codCID>'
										Else
											cXml +='	<codCID>'+ AllTrim(StrTran(oGrid:GetValue("R8_CID"), ".", "")) +'</codCID>'
										EndIf
									Endif
									cXml +='	<qtdDiasAfast>'+ Alltrim(Str(oGrid:GetValue("R8_DURACAO")))+'</qtdDiasAfast>'
									If !Empty(oGrid:GetValue("R8_IDEOC")) .And. !Empty(oGrid:GetValue("R8_NMMED")) .And. !Empty(oGrid:GetValue("R8_CRMMED")) .And. !Empty(oGrid:GetValue("R8_UFCRM "))
										cXml +='	<emitente>'
										cXml +='	<nmEmit>'+ SubStr(fSubst(oGrid:GetValue("R8_NMMED")),1,70)+'</nmEmit>'
										cXml +='	<ideOC>'+ oGrid:GetValue("R8_IDEOC")+'</ideOC>'
										cXml +='	<nrOc>'+ fSubst(oGrid:GetValue("R8_CRMMED"))+'</nrOc>'
										cXml +='	<ufOC>'+ oGrid:GetValue("R8_UFCRM ")+'</ufOC>'
										cXml +='	</emitente>'
									Endif
									cXml +='</infoAtestado>'
								Endif
							EndIf
							If oGrid:GetValue("R8_TPEFD") == "14"
								cXml +='<infoCessao>'
								cXml +='	<cnpjCess>'+ oGrid:GetValue("R8_CNPJCES")+'</cnpjCess>'
								cXml +='	<infOnus>'+ oGrid:GetValue("R8_TPCES")+'</infOnus>'
								cXml +='</infoCessao>'
							EndIf
							If oGrid:GetValue("R8_TPEFD") == "24" .Or. ( cVersEnvio < "9.0" .And. oGrid:GetValue("R8_TPEFD") $ "22/23/24" )
								cXml +='<infoMandSind>'
								cXml +='	<cnpjSind>'+ oGrid:GetValue("R8_CNPJSIN")+'</cnpjSind>'
								cXml +='	<infOnusRemun>'+ oGrid:GetValue("R8_TPSIND")+'</infOnusRemun>'
								cXml +='</infoMandSind>'
							EndIf
							cXml +='</iniAfastamento>'
						Else
							lDtIni	:= .F.
						EndIf

						//---------------------------------------
						//INFORMACAO DE TERMINO DE AFASTAMENTO
						//---------------------------------------
						If aAfastEsoc[nA,3] .OR. lEnvAFim // lDtFim
							cXml +='<fimAfastamento>'
							If !lMiddleware
								cXml +='	<dtTermAfast>' + If(!lFimVazio, DTOS(oGrid:GetValue("R8_DATAFIM")), "" ) + '</dtTermAfast>'
							Else
								cXml +='	<dtTermAfast>' + SubStr( DTOS(oGrid:GetValue("R8_DATAFIM")), 1, 4 ) + "-" + SubStr( DTOS(oGrid:GetValue("R8_DATAFIM")), 5, 2 ) + "-" + SubStr( DTOS(oGrid:GetValue("R8_DATAFIM")), 7, 2 ) + '</dtTermAfast>'
							EndIf
							cXml +='</fimAfastamento>'
						Endif
						cXml +='</infoAfastamento>'
						cXml +='</evtAfastTemp>'
						cXml +='</eSocial>'
						//Espera 1 segundo para nao sobrescrever o XML quando gerar mais de um arquivo por funcionario
						If lContAfa
							Sleep( 1000 )
						EndIf

						cTafKey := fTafKAfast(FwxFilial("SR8",FWCodFil()), oGrid:GetValue("R8_MAT"), oGrid:GetValue("R8_SEQ") )

						If lRet .And. cTpEnviado == "4"
							cXml    := ""
                            dDtOld  := RetSR8( oGrid:GetValue("R8_SEQ") )
                            If !Empty(dDtOld) .And. (lMiddleware .Or. !( RetCM6(xFilial("CM6", cFilEnv) + C9V->C9V_ID + Space(8) + dToS(dDtOld) + "1", 2) $ "-1/2/6/7"))
                                If !lMiddleware
									cKey3000 := oGrid:GetValue("R8_TAFKF")
									lS3000	 := .T.
									InExc3000(@cXml,'S-2230',cKey3000,SRA->RA_CIC,SRA->RA_PIS,,)
									cTafKey := cKey3000
									cKey3000 := ""

									MsgRun( OemToAnsi(STR0110) ,,{|| aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, Alltrim(cTafKey) , "3", "S3000", , /*cTicket*/, , , , "GPE", , /*cPredeces*/ )	} )
								Else
									cChaveS2230	:= Iif(!SRA->RA_CATEFD $ cTrabSVinc .Or. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + dToS( SRA->RA_ADMISSA )) + dToS(oGrid:GetValue("R8_DATAINI")) + "F"
									cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2230" + Padr(cChaveS2230, 40, " ")
									cStat2230 	:= "-1"
									nRec2230	:= 0
									cMsgRJE		:= ""
									GetInfRJE( 2, cChaveBus, @cStat2230, @cOper2230, @cRetf2230, @nRec2230, @cRecib2230, @cRecibAnt, Nil, Nil, .T. )

									//Retorno pendente impede o cadastro
									If cStat2230 == "2" .And. cEFDAviso != "2"
										cMsgErro 	:= STR0134//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
									//Evento com exclusão sem transmissão
									ElseIf cStat2230 == "99"
										cMsgErro 	:= STR0146//"Operação não será realizada pois há evento de exclusão pendente para transmissão"
									EndIf
									If !Empty(cMsgErro)
										aAdd( aErros, cMsgErro )
										lRet := .F.
									EndIf

									If Empty(cMsgErro) .And. cStat2230 != "-1"
										aInfoC   := fXMLInfos()
										If Len(aInfoC) >= 4
											cId   := aInfoC[3]
										Else
											cId  := ""
										EndIf
										cStatNew := ""
										cOperNew := ""
										cRetfNew := ""
										cRecibAnt:= ""
										cKeyMid	 := ""
										nRecEvt	 := 0
										lNovoRJE := .T.
										aDados	 := {}
										InExc3000(@cXml,'S-2230',cRecib2230,SRA->RA_CIC,SRA->RA_PIS, Nil, Nil, Nil, Nil, cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cId, @cStatNew, @cOperNew, @cRetfNew, @nRecEvt, @lNovoRJE, @cKeyMid, @aErros)
										If Len(aErros) == 0
											If cStat2230 != "4"
												If !( lRet := fExcluiRJE( nRec2230 ) )
													aAdd( aErros, STR0138 )//"Ocorreu um erro na exclusão do registro na tabela RJE"
												EndIf
											Else
												aAdd( aDados, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S3000", Space(6), cRecib2230, cId, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, NIL, NIL } )
												If !( lRet := fGravaRJE( aDados, cXML, lNovoRJE, nRecEvt ))
													aAdd( aErros, STR0138 )//"Ocorreu um erro na gravação do registro na tabela RJE"
												EndIf
											EndIf
										EndIf
									EndIf
								EndIf

                                If Len(aErros)> 0
                                    FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
                                    lRet:= IIF(aErros[1]!='000026',.F.,.T.)
                                EndIf
                            EndIf
						Endif
					Endif
					GrvTxtArq(alltrim(cXml), Iif(lS3000, "S3000", "S2230"), SRA->RA_CIC)

					If lTafKeys
						If lRet .And. cTpEnviado <> "4" .And. aAfasteSoc[nA,2] <> "5"
							If lMiddleware .Or. !( aAfasteSoc[nA,2] == "2" .And. Empty(oGrid:GetValue("R8_TAFKI")) )
                                If !lMiddleware
									If aAfastEsoc[nA,3] .And. lRetif
										cStat2230 := RetCM6(xFilial("CM6", cFilEnv) + C9V->C9V_ID + DTOS(oGrid:GetValue("R8_DATAINI")) + DTOS(oGrid:GetValue("R8_DATAFIM")), 2)

										//Para casos de retificação da data final do afatamento quando o início e fim foram enviados separadamente
										If (cStat2230 == "-1" .Or. EMPTY(cStat2230)) .And. lIniFimDif
											cStat2230 := RetCM6(xFilial("CM6", cFilEnv) + C9V->C9V_ID + DTOS(oGrid:GetValue("R8_DATAINI")), 1)
										EndIf

										if cStat2230 <> "-1" .or. empty(cStat2230)
											cPredeces := oGrid:GetValue("R8_TAFKF")
										endIf
									ElseIf lDtIni .And. lRetif
										cStat2230   := RetCM6(xFilial("CM6", cFilEnv) + C9V->C9V_ID + DTOS(oGrid:GetValue("R8_DATAINI")), 1)

										if cStat2230 <> "-1" .or. empty(cStat2230)
											cPredeces := oGrid:GetValue("R8_TAFKI")
										endIf
									ElseIf aAfastEsoc[nA,3] //vai mandar a data final e nao eh retificacao
										cStat2230   := RetCM6(xFilial("CM6", cFilEnv) + C9V->C9V_ID + DTOS(oGrid:GetValue("R8_DATAINI")), 1)

										if cStat2230 <> "-1"
											cPredeces := oGrid:GetValue("R8_TAFKI")
										endIf
									EndIf
									aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, cTafKey , "3", "S2230", , cTicket, , , , "GPE", , cPredeces )
								Else
									If !( lRet := fGravaRJE( aDados, cXml, lNovoRJE, nRec2230 ) )
										aAdd(aErros, STR0136)//"Ocorreu um erro na gravação do registro na tabela RJE"
									EndIf
								EndIf
							Else
								aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S2230")
							EndIf
						Endif
					Else
						aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S2230")
					EndIf

					If Len(aErros) > 0
						If !lMiddleware
							If lSemTAFKeys .And. aErros[1] == OemtoAnsi(STR0157)
								cMsgSemTAF := ""
								cMsgSemTAF += CRLF + OemToAnsi(STR0246)	+ CRLF	//"Se há afastamento incluído por esta rotina enquanto o parâmetro MV_RHTAF estava habilitado e os campos TAFKinicio e/ou TAFKfinal ficaram em branco, verifique a necessidade de ajuste de base, pesquise por RHTAFKEY no TDN."
								cMsgSemTAF += CRLF + OemToAnsi(STR0150)	+ CRLF	//"Este erro também pode estar ocorrendo devido ao afastamento ter sido informado diretamente no TAF enquanto o parametro MV_RHTAF está desabilitado"
								cMsgSemTAF += OemToAnsi(STR0151)		+ CRLF	//"Se este foi o procedimento, é necessário seguir os seguintes procedimentos:"
								cMsgSemTAF += CRLF + OemToAnsi(STR0152)	+ CRLF	//"1 - Desabilitar o MV_RHTAF"
								cMsgSemTAF += OemToAnsi(STR0153)		+ CRLF	//"2 - Usando a rotina de afastamento (GPEA240), selecionar o registro correto, que vai estar com os campos TAFKinicio e TAFKfinal em branco."
								cMsgSemTAF += OemToAnsi(STR0154)		+ CRLF	//"3 - Informar os campos TAFKinicio e TAFKfinal, do afastamento, através desta rotina (GPEA240) com um número aleatório, por exemplo '99999'"
								cMsgSemTAF += OemToAnsi(STR0155)		+ CRLF	//"4 - Salvar o registro e habilitar novamente o MV_RHTAF"
								cMsgSemTAF += CRLF + OemToAnsi(STR0156)	+ CRLF	//"Assim, a próxima vez que for feita uma manutenção essa mensagem não será apresentada, pois este registro não será integrado ao TAF."

								Aadd(aErrosTAF, cMsgSemTAF)
							EndIf

							FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
							lRet:= IIF(aErros[1]!='000026',.F.,.T.)
						EndIf

						If lRet .And. cTpEnviado == "4"
							//Se a data fim foi deletada e não haverá retificação pois o evento foi deletado no TAF limpa o campo R8_TAFKF
							If lTafKeys .And. !aAfastEsoc[nA,3] .And. !lRetif
								oGrid:LoadValue("R8_TAFKF", "" )
							EndIf
							Exit
						EndIf
					Else
						lret := .T.
						If SR8->(ColumnPos('R8_DATALT')) > 0
							If (oGrid:GetValue('R8_TPEFDAN') == '03' .And. oGrid:GetValue('R8_TPEFD') == '01')
								oGrid:LoadValue('R8_DATALT', DDATABASE)
							EndIf
						Endif

						If lTafKeys .And. lDtIni
							//R8_TAFKI: TAFKEYINICIO 60 CARACTERES: Ao integrar com o TAF CODUNICO+SEQUENCIA AFASTAMENTO+ "INI" + DATA INTEGRAÇÃO
							oGrid:LoadValue("R8_TAFKI",cTafKey )
						Endif

						If lTafKeys .And. aAfastEsoc[nA,3]
							//R8_TAFKF: TAFKEYFINAL  60 CARACTERES: Ao integrar com o TAF CODUNICO+SEQUENCIA AFASTAMENTO+ "FIM" + DATA INTEGRAÇÃO
							oGrid:LoadValue("R8_TAFKF",cTafKey )

						Elseif lTafKeys .And. !aAfastEsoc[nA,3] .And. !lRetif
							oGrid:LoadValue("R8_TAFKF", "" )
						Endif

						//Se enviou a data fim antes da data, por exemplo, quando são menos de 15 dias de afastamento, gravar o final do afastamento no R8_INTGTAF e não a DDATABASE
						If ( !Empty(oGrid:GetValue("R8_DATAFIM") ) ) .And. (oGrid:GetValue('R8_TPEFD')  <> '15' .And. oGrid:GetValue('R8_DATAFIM') - oGrid:GetValue('R8_DATAINI') <= 15 )
							oGrid:LoadValue("R8_INTGTAF",oGrid:GetValue('R8_DATAFIM') )
						Else
							oGrid:LoadValue("R8_INTGTAF",DDATABASE )
						Endif

						oGrid:LoadValue("R8_TPEFDAN",oModlBkp:GetValue("R8_TPEFD") )
						cRegInteg += CHR(10)+CHR(13)
						cRegInteg += OemToAnsi(STR0255) + oGrid:GetValue('R8_SEQ') + " - " + DtoC(oGrid:GetValue('R8_DATAINI'))
					EndIf
				Next nA
			Endif
		EndIf
		//Se vier do GPEA240 e existir inconsistência manda a mensagem para exibição no retorno do modelo da rotina de afastamentos
		If( lAfast .And. !Empty(cMsgLog), Aadd(aErros, cMsgLog), )
	EndIf

	If !Empty(cXml) .And. (lRet .And. If( LEN(aErros) > 0, aErros[1]!='000026', .T. ) )
		fEFDMsg(cRegInteg)
    ElseIf( lAfast .And. !Empty(cMsgLog))
        Aadd(aErros, cMsgLog)
	EndIf

	RestArea(aAreaSRA)
	RestArea(aAreaSR8)
	If !lMiddleware
		RestArea(aAreaCM6)
	EndIf
	cFilAnt := cFilBkp

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGp26Cnpj ³ Autor ³ Alessandro Santos     ³ Data ³ 02/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida se Cnpj valido e se diferente do Cnpj do emitente.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRet - Cnpj valido                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fGp26Cnpj(cCnpJ, cFilEnv)

	Local aArea		:= GetArea()
	Local aAreaSM0	:= SM0->(GetArea())
	Local cRet 		:= ""
	Local nPos		:= 0

//Valida se Cnpj valido
	If !Empty(cCnpJ) .AND. Cgc(cCnpJ)
	//Busca CNPJ
		nPos := aScan(aSM0, {|x| x[1] == cEmpAnt .AND. AllTrim(x[2]) == AllTrim(cFilEnv)})

		If nPos > 0
			cRet := IIF(cCnpJ <> aSM0[nPos, 18], cCnpJ, "")
		EndIf
	EndIf

//Restaura areas
	RestArea(aAreaSM0)
	RestArea(aArea)

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fGP26SRA  ³ Autor ³ Glaucia Messina       ³ Data ³ 08/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Alteracao Contratual Trabalhador sem vinculo-eSocial - S2620³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fGP27s2620(aRotAuto,lGp010Auto,cFilEnv,cIdFunc )		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	aExp1: Array com campos alterados via MsAutoExec   	 	  ³±±
±±³          ³ 	lExp2: Indicativo de uso MsAutoExec             	 	  ³±±
±±³          ³ 	cExp3: Empresa centralizadora no TAF (S-1000)      	 	  ³±±
±±³          ³ 	cExp4: Id Trabalhador no TAF                              ³±±
±±³          ³ 	cExp5: nOperx - Qual o tipo de operacao Id Trab SRA       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEA010                              					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fGP26SRA(cCPF,cCateg,cMatric,nOperx,cOrigem, cTipoAdm,aSRAalt,aSraCpo, aSraOrig )
	Local aArea			:= GetArea()
	Local cTrabVI		:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|304|306|701|702|703|711|712|713"
	Local cTSV			:= fCatTrabEFD("TSV") //"201|202|203|305|401|701|702|703|711|712|713|721|722|731|732|733|734|735|736|741|901"
	Local lVinculo		:= .F.
	Local lTSV			:= .F.
	Local aIncons		:= {}
	Local cFilEnv 		:= ""
	Local lRet			:= .T.
	Local aCpoDesl		:= {}
	Local lDeslig 		:= .F.
	local dDeslig		:= CTOD('  /  /  ')
	Local dAdm			:= CTOD('  /  /  ')

	Static lTafImpl 	:= fGP17VrTaf()

	DEFAULT cTipoAdm	:= ""
	DEFAULT aSRAorig	:= {}
	DEFAULT aSraCpo	:= {}
	DEFAULT aSraAlt	:= {}

	If lIntTaf .AND. lTafImpl							//1- Verificacao se TAF ativo e em uso
		cFilEnv	:= fTafGetFil(FWCodEmp()+FWCodFil(), @aIncons, , .T.) 	//2- Verificacao se a filial associada esta configurad ao TAF
		If !(Empty(cFilEnv))
			If cCateg $ cTrabVI
				lVinculo := .T.
			ElseIf cCateg $ cTSV
				lTSV 	:= .T.
			EndIf
		EndIf
	EndIf

	If (lVinculo .OR. lTSV)
		If (nOperx == 3 .OR. nOperx == 4)
			If cOrigem $ 'GPEA010' .AND. lTSV .AND. (!cCateg $('721|722'))
				aCpoDesl	:= fGM27Cpo("RA_DEMISSA",aSraCpo,aSRAorig,aSRAalt)
				If len(aCpoDesl) > 0 // Verifica se eh Desligamento
					dDeslig		:= IIf(!EMPTY(aCpoDesl[2]),aCpoDesl[2], IIf(!EMPTY(aCpoDesl[1]),aCpoDesl[1], CTOD('  /  /  ')))
					dAdm		:= fGM26Cpo("RA_ADMISSA",aSraCpo,aSRAorig)
					cPis		:= fGM26Cpo("RA_PIS",aSraCpo,aSRAorig, .T.)

					If	(!EMPTY(dDeslig)) .AND. dDeslig >= dAdm
						lDeslig := .T.
						If (EMPTY(cPis) .AND. cCateg == '901') .OR. (!EMPTY(cPis) .AND. cCateg != '901')
							fInc2680(cCPF,cMatric,cFilEnv,cCateg, nOperx,cOrigem, dDeslig )
						Else
							cMsg := ""
							cMsg := OemtoAnsi(STR0029) + "." + CRLF									//"A integração com o módulo TAF não foi realizada."
							cMsg += OemtoAnsi(STR0032)+"." + CRLF									//"Problemas na carga evento S-2680"
							cMsg += OemtoAnsi(STR0030)												//"Verifique informaçoes deste trabalhador no módulo TAF."
							Help("",1,OemtoAnsi(STR0028),,cMsg,1,0)									//"Carga TAF não realizada"
						Endif
					EndIf
				EndIf
			EndIf

			If !lDeslig  //Se nao passou pela verificacao de desligamento
				fInc2200(aSRAalt,aSraCpo,cCPF,cMatric,cFilEnv,cCateg, nOperx,cOrigem, cTipoAdm,aSraOrig, IIf(lTSV,.T.,.F.) )
			EndIf

		ElseIf nOperx == 5 .AND. cOrigem $ 'GPEA010'
			lRet := fDel2200(cCPF,cMatric,cFilEnv,cCateg, nOperx,cOrigem)
		EndIf
	EndIf

	RestArea(aArea)
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fInc2200  ³ Autor ³ Glaucia Messina       ³ Data ³ 08/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Alteracao Contratual Trabalhador sem vinculo-eSocial - S2620³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fInc2200()                                   		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	aExp1: Array com campos alterados via MsAutoExec   	 	  ³±±
±±³          ³ 	lExp2: Indicativo de uso MsAutoExec             	 	  ³±±
±±³          ³ 	cExp3: Empresa centralizadora no TAF (S-1000)      	 	  ³±±
±±³          ³ 	cExp4: Id Trabalhador no TAF                              ³±±
±±³          ³ 	cExp5: nOperx - Qual o tipo de operacao Id Trab no TAF    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fInc2200(aSRAalt,aSraCpo,cCpf,cMatric,cFilEnv,cCateg, nOperx, cOrigem,cTipoAdm,aSRAOrig, lTSV)
	Local aArea		:= GetArea()
	Local cMsg			:= ""
	Local aTrab			:= {.F.,"","","",""}
	Local lCarga		:= .F.
	Local lEstagio		:= .F.
	Local cCatNO		:= "201|202|203|401|701|702|703|711|712|713|736|751"	//Categorias que nao possuem alteracao contratual
	Local lVerCad		:= .F.
	lOCAL lVerCont		:= .F.

	PRIVATE cMsgSRA 	:= ""

	aTrab := fGM26Trb(cCPF, "S2200",cCateg,FwCodFil()+cMatric, cFilEnv, lTSV)

	If aTrab[1] .AND.  !(aTrab[4] $ 'ALT|TERMINO')
		If  !lTSV .AND. aTrab[4] $ ('S2200|S2100') //COM VINCULO
			lCarga := fIncVinc(cFilEnv, cCpf, cMatric, cTipoAdm, aSraCpo, aSRAalt, cCateg, cOrigem, nOperx, aTrab[4])
		ElseIf	lTSV .AND. aTrab[4] $ ('S2600') //SEM VINCULO
			lCarga := fInc2600(aSRAalt,aSraCpo, aSraOrig,cCPF,cMatric,cFilEnv,cCateg, nOperx,cOrigem, aTrab, 'INCLUSAO')
		EndIf

	ElseIf aTrab[1] .AND. aTrab[4] == 'ALT'
	//ALTERACAO CADASTRAL
		If cOrigem == "GPEA010"
			lVerCad := fGP26Dif(aSraCpo,aSRAOrig,aSRAalt, .F., lTSV, "CADASTRO")
		Else
			lVerCad := .T.
		EndIf

		If lVerCad
			lCarga := fAltVinc(aSRAalt, aSraCpo, aSRAOrig, cCpf,cMatric, cFilEnv, cCateg, nOperx,cOrigem, aTrab ,lTSV)
		EndIf

	//ALTERACAO CONTRATUAL
		If lTSV .AND. cOrigem <> 'GPEA020'
			lEstagio := IIf(aTrab[3]=='901',.T.,.F.)
			lVerCont := !(aTrab[3] $ cCatNO)
			lVerCont := IIF(cOrigem == 'GPEA010',fDif2620(aSraCpo,aSRAOrig,aSRAalt, lEstagio), .T.)
			If lVerCont
				lCarga := fInc2600(aSRAalt,aSraCpo, aSraOrig,cCPF,cMatric,cFilEnv,cCateg, nOperx,cOrigem, aTrab, 'CONTRATO')
			Endif
		ElseIf (!lTSV)
			If cOrigem == "GPEA010"
				lVerCont := fGP26Dif(aSraCpo,aSRAOrig,aSRAalt, .F., .F., "CONTRATO")
			ElseIf cOrigem == "GPEA927"
				lVerCont := .T.
			EndIf

			If lVerCont
				lCarga :=  fInc2240(aSRAalt,aSraCpo, aSraOrig,cCPF,cMatric,cFilEnv,cCateg, nOperx,cOrigem)
			EndIf

		EndIf
	EndIf


	If (lVerCad .OR. lVerCont) .AND. !lCarga
		If len(aTrab) > 0 .AND. !(Empty(aTrab[2]))
			Help("",1,OemtoAnsi(STR0028),,aTrab[2],1,0)	//"Carga TAF não realizada"
		Else
			cMsg := ""
			cMsg := OemtoAnsi(STR0029) + "." + CRLF		//"A integração com o módulo TAF não foi realizada."
			cMsg += OemtoAnsi(STR0030)					//"Verifique informaçoes deste trabalhador no módulo TAF."
			Help("",1,OemtoAnsi(STR0028),,cMsg,1,0)		//"Carga TAF não realizada"
		EndIf
	EndIf
	RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGM26Crg  ³ Autor ³ Glaucia Messina       ³ Data ³02/07/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Realiza pre-carga de cargos                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fGM26Crg()                                             	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEM026- fG26Vinc	    		                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function fGM26Crg(cCrgoSRA,cCCSRA)
	Local aArea		:= GetArea()
	Local lSemFilial := .F.
	Local lEnvia	:= .T.
	Local cFilSQ3	:= FwxFilial("SQ3",FWCodFil())
	Local cAliaSQ3 := "SQ3"
	Local cCrgoTAF	:= ""
	Local lCC		:= .F.

	If FWModeAccess("SQ3",1)=="C" .AND. FWModeAccess("SQ3",2)=="C" .AND. FWModeAccess("SQ3",3)=="C"
		lSemFilial:=.T.
	Endif

	dbSelectArea("SQ3")
	dbSetOrder(1)
	If 	dbSeek(cFilSQ3 + cCrgoSRA + cCCSRA)
		lEnvia := .T.
		lCC		:= .T.
	ElseIf dbSeek(cFilSQ3 + cCrgoSRA)
		lEnvia := .T.
	EndIf

	If lEnvia .AND. (!(EMPTY((cAliaSQ3)->Q3_CARGO)) .AND. !(EMPTY((cAliaSQ3)->Q3_DESCSUM)))
	//SQ3 se o campo Filial esta compativel com o compartilhamento SX2
		If  !lSemFilial .And. (cAliaSQ3)->Q3_FILIAL <> FwxFilial("SQ3",FWCodFil())
			lEnvia	:= .F.
		EndIf
	EndIf

	If lEnvia
	//Tratamento para Cargo
		If !lSemFilial
			cCrgoTAF := ALLTRIM((cAliaSQ3)->Q3_FILIAL + (cAliaSQ3)->Q3_CARGO + IIf(lCC,(cAliaSQ3)->Q3_CC,''))
		Else
			cCrgoTAF := ALLTRIM((cAliaSQ3)->Q3_CARGO + IIf(lCC,(cAliaSQ3)->Q3_CC,''))
		EndIf

	//Validacao tamanho do cargo
		If Len(cCrgoTAF) > 30
			cCrgoTAF := ""
		EndIf
	EndIf

	RestArea(aArea)
Return (cCrgoTAF)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGM26Sind   ºAutor  ³Glaucia Messina     º Data ³  26/06/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carga de Sindicatos                                        º±±
±±º          ³ devolve em formato de array.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM026- fG26Vinc                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGM26Sind(cSindSRA)
	Local aArea 	:= GetArea()
	Local cFilRCE	:= FwxFilial("RCE",FWCodFil())
	Local cSinCNPJ := ""
	Local cSinDiss := ""

	dbSelectArea("RCE")
	RCE->(DbSetOrder(1))

	If dbSeek(cFilRCE + cSindSRA)
		If !EMPTY(RCE->RCE_CGC)
			cSinCNPJ := RCE->RCE_CGC
			cSinDiss := RCE->RCE_MESDIS
		EndIf
	EndIf

	RestArea(aArea)
Return({cSinCNPJ,cSinDiss})


//-------------------------------------------------------------------
/*/{Protheus.doc} function fDtFant
Função utilizada para pegar a data fim
do afastamento anterior ao do afastamento
que estiver sendo alterado.
@author  oliveira.hugo
@since   15/08/2019
@version 12.1.25 e V11.80
/*/
//-------------------------------------------------------------------
Static Function fDtFant(cFilSRA, cMat, cDtIni)
	Local aArea   	:= GetArea()
	Local cDtFim	:= ""

	DEFAULT cFilSRA := ""
	DEFAULT cMat 	:= ""
	DEFAULT cDtIni  := ""

	dbSelectArea("SR8")
	SR8->( DbSetOrder(1) )

	If dbSeek( cFilSRA + cMat + DTOS(cDtIni) )
		cDtFim := SR8->R8_DATAFIM
	EndIf

	RestArea(aArea)
Return cDtFim


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGM26Fun  ³ Autor ³ Glaucia Messina       ³ Data ³26/06/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Realiza pre-carga de funcao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fGM26Fun()                                             	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEM026- fG26Vinc	    		                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function fGM26Fun(cFunSRA, cFilSRA)
	Local aArea		    := GetArea()
	Local lSemFilial    := .F.
	Local lEnvia	    := .T.
	Local cFilSRJ	    := ""
	Local cAliaSRJ      := "SRJ"
	Local cFuncTAF	    := ""
	Local cCBOTAF	    := ""

    Default cFilSRA     := FWCodFil()

    cFilSRJ	:= FwxFilial("SRJ", cFilSRA)

	If FWModeAccess("SRJ",1)=="C" .AND. FWModeAccess("SRJ",2)=="C" .AND. FWModeAccess("SRJ",3)=="C"
		lSemFilial:=.T.
	Endif

	dbSelectArea("SRJ")
	dbSetOrder(1)
	If 	dbSeek(cFilSRJ + cFunSRA )
		lEnvia := !(EMPTY((cAliaSRJ)->RJ_FUNCAO)) .AND. !(EMPTY((cAliaSRJ)->RJ_DESC))

	//Verifica SRJ se o campo Filial esta compativel com o compartilhamento SX2
		If  !lSemFilial .And. (cAliaSRJ)->RJ_FILIAL <> cFilSRJ
			lEnvia	:= .F.
		EndIf

		If lEnvia
			If !lSemFilial
				cFuncTAF := ALLTRIM((cAliaSRJ)->RJ_FILIAL+(cAliaSRJ)->RJ_FUNCAO)
			Else
				cFuncTAF := ALLTRIM((cAliaSRJ)->RJ_FUNCAO)
			EndIf

		//Validacao tamanho do Funcao
			If Len(cFuncTAF) > 30
				cFuncTAF := ""
			Else
				cCBOTAF:= (cAliaSRJ)->RJ_CODCBO
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
Return ({cFuncTAF,cCBOTAF} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGM26CTT    ºAutor  ³Glaucia Messina     º Data ³  26/06/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carga de Lotacao do Funcionario.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM026- fG26Vinc                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGM26CTT(cSRACC)
	Local aArea			:= GetArea()
	Local aCTT			:= {}
	Local cCTT	 		:= ""
	Local lSemFilial	:= .F.
	Local cFilCCT		:= FwxFilial("CTT",FWCodFil())

	If FWModeAccess("CTT",1)=="C" .AND. FWModeAccess("CTT",2)=="C" .AND. FWModeAccess("CTT",3)=="C"
		lSemFilial := .T.
	Endif

	dbSelectArea("CTT")
	CTT->(DbSetOrder(1))

	If dbSeek(cFilCCT + cSRACC )
		If (!(EMPTY(CTT->CTT_NOME)) .AND. !(EMPTY(CTT->CTT_TPLOT)))
		//Consolidada
			If !lSemFilial
				cCTT := CTT->CTT_FILIAL + CTT->CTT_CUSTO
			Else
				cCTT := CTT->CTT_CUSTO
			EndIf
			aCTT := {cCTT,CTT->CTT_TIPO2,CTT->CTT_CEI2 ,CTT->CTT_TPLOT}
		EndIf
	EndIf

	RestArea(aArea)
Return(aCTT)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGM26Tur    ºAutor  ³Glaucia Messina     º Data ³  02/07/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carga Campo Turno/Horario Trabalhadores com Vinculo        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM026- fG26Vinc                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGM26Tur(cTurnSRA,cRegrSRA)
	Local aArea		:= GetArea()
	Local aTurnos	:= {}
	Local aAreaSR6 	:= SR6->(GetArea())
	Local aAreaSPJ 	:= SPJ->(GetArea())
	Local cCod		:= ""
	Local nPosTurno:= 0
	Local cFilTurn	:= FWxFilial("SR6", FWCodFil())

	dbSelectArea("SR6")	//TURNO
	dbSelectArea("SPJ")	//HORARIO

	SR6->(dbSetOrder(1))
	SPJ->(dbSetOrder(1))

	If SR6->(MsSeek(cFilTurn + cTurnSRA))
		If SPJ->(MsSeek(xFilial("SPJ") + cTurnSRA))  //PJ_FILIAL+PJ_TURNO+PJ_SEMANA+PJ_DIA
			While SPJ->(!EOF())
				If (SPJ->(PJ_FILIAL + PJ_TURNO) == SR6->(R6_FILIAL + cTurnSRA) .AND. SPJ->PJ_TPDIA == "S")
					nPosTurno := aScan(aTurnos,{|x| x[1] == cFilTurn .AND. ;
						x[2] == cTurnSRA .AND. ;
						x[3] == cRegrSRA })
					cCod := cFilTurn+SPJ->PJ_TURNO + cRegrSRA + SPJ->PJ_SEMANA + SPJ->PJ_DIA

					If nPosTurno == 0
						Aadd(aTurnos,{cFilTurn,cTurnSRA,cRegrSRA,{cCod,SPJ->PJ_DIA}})
					Else
						Aadd(aTurnos[nPosTurno],{cCod,SPJ->PJ_DIA})
					EndIf
				EndIf
				SPJ->(dbSkip())
			EndDo
		EndIf
	EndIf

	RestArea(aAreaSR6)
	RestArea(aAreaSPJ)
	RestArea(aArea)
Return (aTurnos)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fDel2200  ³ Autor ³ Glaucia Messina       ³ Data ³ 03/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Exclusao do evento S-2200 quando o mesmo nao enviado ao RET ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fG26Vinc()                                   		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	aExp1: Array com campos alterados via MsAutoExec   	 	  ³±±
±±³          ³ 	lExp2: Indicativo de uso MsAutoExec             	 	  ³±±
±±³          ³ 	cExp3: Empresa centralizadora no TAF (S-1000)      	 	  ³±±
±±³          ³ 	cExp4: Id Trabalhador no TAF                              ³±±
±±³          ³ 	cExp5: nOperx - Qual o tipo de operacao Id Trab no TAF    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fDel2200(cCpf,cMatric,cFilEnv,cCateg, cOrigem)
	Local aArea		:= GetArea()
	Local lRet		:= .F.
	Local aIncons	:= {}
	Local aChave	:= {}
	Local oModel
	Local nIndex   := 4	//C9V_FILIAL+C9V_CPF+C9V_NOMEVE+C9V_ATIVO
	Local aTrab		:= {}
	Local cRotTAF	:= ""
	Local cEvto 	:= ""

//MELHORAR para EXCLUSAO 2100/2200/2600
	aTrab := fGM26Trb(cCPF, "S2200",cCateg,FWCodFil()+cMatric, cFilEnv)

	If (len(aTrab) > 0) .AND. (aTrab[1])
		If aTrab[4] $ "S2200|S2100"
			cEvto := ALLTRIM(aTrab[4])

			aAdd( aChave, {"C", "C9V_CPF"   , ALLTRIM(cCPF), .T. } )
			aAdd( aChave, {"C", "C9V_NOMEVE" ,cEvto  , .T. } )

			cRotTAF := IIf(cEvto == "S2200","TAFA278","TAFA256")

			aAdd( aChave, {"C", "C9V_CPF"   , cCPF, .T. } )
			aAdd( aChave, {"C", "C9V_NOMEVE" ,cEvto  , .T. } )

			Begin Transaction
				If FTafVldOpe( "C9V", nIndex, 5 , cFilEnv , @aIncons, aChave, @oModel, cRotTAF ,"",,.F.,, FWCodFil()+cMatric)
					FWFormCommit( oModel )
					oModel:DeActivate()
					lRet := .T.
				EndIf
			End Transaction

		ElseIf aTrab[4] == "S2600"
			aAdd( aChave, {"C", "C9V_CPF"   	,ALLTRIM(cCPF)	, .T. } )
			aAdd( aChave, {"C", "C9V_NOMEVE"   ,"S2600"			, .T. } )
			Begin Transaction
				If FTafVldOpe( "C9V", nIndex, 5, cFilEnv, @aIncons, aChave, @oModel, "TAFA279" )
					FWFormCommit( oModel )
					oModel:DeActivate()
					lRet := .T.
				EndIf
			End Transaction
		EndIf
	EndIf

	RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³f26Carga  ³ Autor ³ Glaucia Messina       ³ Data ³ 08/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carga de dados Trabalhador no TAF - evento S-2200           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ f26Carga()                                   		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	oExp1: Modelo MVC que tera carga de campo    	    	  ³±±
±±³          ³ 	cExp2: Nome modelo                              	 	  ³±±
±±³          ³ 	cExp3: Nome do campo que sera atribuido no modelo  	 	  ³±±
±±³          ³ 	cExp4: Nome do campo SRA, que contem o valor a ser atrib  ³±±
±±³          ³ 	aExp5: Array com nome dos campos SRA                      ³±±
±±³          ³ 	aExp6: Array com o conteudo dos campos SRA                ³±±
±±³          ³ 	lExp7: indicar se o ALLTRIM devera ser utilizado.         ³±±
±±³          ³ 	nExp8: Tamanho limite no campo da string de carga.        ³±±
±±³          ³ 	nExp9: Se o campo na carga nao e string.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function f26Carga(oModel,cModel,cCpoMdl,cCpoSRA,aSraCpo,aSRAalt, lALLTRIM, nTam,lNcaract)
	Local aArea		:= GetArea()
	Local nPosCmp	:= 0
	Local cRetorno	:= ""
	Local lRet		:= .T.

	DEFAULT lALLTRIM	:= .F.
	DEFAULT nTam		:= 0
	DEFAULT lNcaract	:= .F.

	nPosCmp	:= aScan(aSraCpo, { |x| x[ 2 ] == cCpoSRA } )
	If nPosCmp > 0
		If !lNcaract
			cRetorno := IIF(lALLTRIM, ALLTRIM(aSRAalt[1,nPosCmp]), aSRAalt[1,nPosCmp])
			If (nTam ==0) .OR. (nTam > 0 .AND. len(cRetorno) <= nTam)
				oModel:LoadValue( cModel,cCpoMdl,cRetorno)
			EndIf
		Else
			oModel:LoadValue( cModel,cCpoMdl,aSRAalt[1,nPosCmp])
		EndIf
	Else
		cMsgSRA := OemtoAnsi(cCpoSRA) + CRLF
	EndIf

	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³f26Carga  ³ Autor ³ Glaucia Messina       ³ Data ³ 08/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carga de dados Trabalhador no TAF - evento S-2200           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ f26Carga()                                   		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	cExp1: Nome do campo SRA, que contem o valor a ser atrib  ³±±
±±³          ³ 	aExp2: Array com nome dos campos SRA                      ³±±
±±³          ³ 	aExp3: Array com o conteudo dos campos SRA                ³±±
±±³          ³ 	lExp4: indicar se o ALLTRIM devera ser utilizado.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fGM26Cpo(cCpoSRA,aSraCpo,aSRAalt, lALLTRIM)
	Local aArea		:= GetArea()
	Local nPosCmp	:= 0
	Local cRetorno	:= ""
	DEFAULT lALLTRIM	:= .F.

	nPosCmp	:= aScan(aSraCpo, { |x| x[ 2 ] == cCpoSRA } )
	If nPosCmp > 0
		cRetorno := IIf(lALLTRIM, ALLTRIM(aSRAalt[1,nPosCmp]),aSRAalt[1,nPosCmp])
	Else
		cMsgSRA := OemtoAnsi(cCpoSRA) + CRLF
	EndIf

	RestArea(aArea)
Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fGM26Trb  ³ Autor ³ Glaucia M             ³ Data ³ 24/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Função que define o comportamento do sistema conforme a de ³±±
±±³          ³ teccao integracao com o modulo TAF e SIGAGPE.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ eSocial - Uso Exclusivo Pais Brasil | GPEM026              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1: CPF do trabalhador                                  ³±±
±±³          ³ cExp2: Evento de integracao                                ³±±
±±³          ³ cExp3: Categoria Provinda do cadastro SRA                  ³±±
±±³          ³ cExp4: Matricula                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGM26Trb(cCpf, cEvento, cCateg, cMatric, cFilEnv , lTSV)
	Local aArea		:= GetArea()
	Local aTrab		:= {}
	Local lRet		:= .T.
	Local cMsg1		:= ""
	Local x			:= 1
	Local cTAFcat	:= ""
	Local cEvto		:= ""
	Local cId		:= ""
	Local lProcura	:= .T.

	DEFAULT cCpf	:= ""
	DEFAULT cEvento:= ""
	DEFAULT cCateg	:= ""
	DEFAULT cMatric:= ""
	DEFAULT lTSV	:= .F.

	aTrab := fG17TRAB( cCPF , cFilEnv ) //Adaptacao da funcao TafRetFun (TAF)

//Tratamento para eventos Trabalhadores COM vinculo

	While lProcura .AND. x <= len(aTrab)
		If !lTSV	//COM VINCULO
			If (cMatric == ALLTRIM(aTrab[x,5])) .AND. (aTrab[x,3] $ 'A|I') .AND.  aTrab[x,1] $ ('S2100|S2200|S2220|S2240|S2800')
				If (aTrab[x,2] $ ' |0|1')	.AND. aTrab[x,1] $ ('S2100|S2200')		//Se evento de carga nao foi transmitido
					cEvto := aTrab[x,1]
					cTAFcat	:= aTrab[x,4]			//Categoria cadastrada no TAF
					lProcura := .F.
				ElseIf !(aTrab[x,2] $ ' |0|1') .AND. !(aTrab[x,1] $ ('S2800')) 	//qualquer evento transmitido desta matricula habilita alteracao, exceto 2800
					cEvto 	:= "ALT"
					cId		:= aTrab[x,6]
					cTAFcat	:= aTrab[x,4]			//Categoria cadastrada no TAF
				ElseIf !(aTrab[x,2] $ ' |0|1') .AND. (aTrab[x,1] $ ('S2800')) 		//Se evento S2800 transmitido
					cEvto 	:= "TERMINO"
					lProcura := .F.
				EndIf
			EndIf

		ElseIf EMPTY(ALLTRIM(aTrab[x,5])) //SEM VINCULO
			If (aTrab[x,2] $ ' |0|1') .AND. (aTrab[x,3] $ 'A|I')	.AND. aTrab[x,1] $ ('S2600')
				cEvto 	:= "S2600"
				cId		:= aTrab[x,6]
				cTAFcat	:= aTrab[x,4]
				lProcura := .F.
			ElseIF 	!(aTrab[x,2] $ ' |0|1')	 .AND. aTrab[x,1] $ ('S2600|S2620|S2220|')
				cEvto 	:= "ALT"
			ElseIF 	!(aTrab[x,2] $ ' |0|1')	 .AND. aTrab[x,1] $ ('S2680')
				cEvto 	:= "TERMINO"
				lProcura := .F.
			EndIf
		EndIf
		x++
	EndDo

	If !lTSV
		cEvto	:= IIF(EMPTY(cEvto), "S2200", cEvto)
		cTAFcat	:= IIF(EMPTY(cTAFcat), cCateg, cTAFcat)
	Else
		cEvto	:= IIF(EMPTY(cEvto), "S2600", cEvto)
		cTAFcat	:= IIF(EMPTY(cTAFcat), cCateg, cTAFcat)
	EndIf

	RestArea(aArea)
Return ({lRet,cMsg1,cTAFcat,cEvto,cId,aTrab})


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fInc2600  ³ Autor ³ Glaucia Messina       ³ Data ³ 23/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Alteracao Contratual Trabalhador sem vinculo-eSocial - S2620³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fGP27s2620(aRotAuto,lGp010Auto,cFilEnv,cIdFunc )		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	aExp1: Array com campos alterados via MsAutoExec   	 	  ³±±
±±³          ³ 	lExp2: Indicativo de uso MsAutoExec             	 	  ³±±
±±³          ³ 	cExp3: Empresa centralizadora no TAF (S-1000)      	 	  ³±±
±±³          ³ 	cExp4: Id Trabalhador no TAF                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEA010                              					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Function fInc2600(aSraAlt,aSraCpo,aSRAori,cCPF,cMatric,cFilEnv,cCateg, nOperx, cOrigem, aTrab, cTpCad)
	Local aArea:= GetArea()
	Local aSind			:= {}
	Local aFuncao		:= {}
	Local nPosSind		:= 0
	Local cObsDef		:= ""
	Local nPosFunc		:= 0
	Local cHrInicio
	Local nContador		:= 0
	Local nContInc		:= 0
	Local nContAlt		:= 0
	Local cMenIni		:= ""
	Local lGeraTAF 		:= .T.
	Local aEstagio		:= {}
	Local aInstit		:= {}
	Local aAgente		:= {}
	Local aCoord		:= {}
	Local nOpc			:= 3
	Local aIncons		:= {}
	Local aChave		:= {}
	Local oModel
	Local l2600			:= .F.
	Local l2620			:= .F.
	Local aCpoCAT		:= {}
	Local aCpoCarg		:= {}
	Local aCpoFun		:= {}
	Local aCpoFun2		:= {}
	Local aCpo			:= {}
	Local cCC			:= ""
	Local cCmp			:= ""
	Local nPagoFixo		:= 0
	Local a2620			:= {}
	Local a2220			:= {}
	Local aPagoFixo		:= {{'H','1'},{'D','2'},{'S','3'},{'M','5'},{'T','6'}}
	Local cSitRET		:= ""
	Local cCI			:= '721|722|731|732|733|734|735|736|741|'
	Local lEstagio		:= .T.
	Local nI			:= 0
	Local aDepend		:= {}
	Local nTotVinc		:= 0
	Local aVinculot		:= {}
	Local lCarga		:= .F.

	PRIVATE cMsgSRA 	:= ""

//Carga S-2620 - Alteracao Contratual
	If (aTrab[1] .AND. cTpCad == "CONTRATO" .AND. cOrigem <> "GPEA020" )
		aChave := {}
		aAdd( aChave, {"C", "C9V_CPF"   ,cCPF, .T. } )
		aAdd( aChave, {"C", "C9V_DTALT" , Dtos(dDatabase), .T. } )
		aAdd( aChave, {"C", "C9V_NOMEVE" ,"S2620", .T. } )

		Begin Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao para validar se a operacao desejada pode ser realizada³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If FTafVldOpe( "C9V", 7, @nOpc, cFilEnv, @aIncons, aChave, @oModel, "TAFA277","",)

				If nOpc == 3 .OR. nOpc == 4
				//Caso se trate de uma inclusão gravo o evento na tabela C9V
					If nOpc == 3
						oModel:LoadValue("MODEL_C9V", "C9V_NOMEVE", "S2620" )
						oModel:LoadValue("MODEL_C9V","C9V_CPF",cCPF)
						oModel:LoadValue("MODEL_C9V","C9V_DTALT",dDatabase)
					EndIf

				//*******************
				//Carga Cadastral
				//*******************
					fG26Cad (oModel,aSraCpo,aSRAalt, .F.)

				//*******************
				//Carga Contratual
				//*******************
					fCtr2600 (oModel,aSraCpo,aSRAalt, cMatric, cOrigem, aTrab[3], 4 )

				//*******************
				//Contribuinte Individual
				//*******************
					If aTrab[3] $ cCI
						aCpoCAT := fGM27Cpo("RA_CATEFD",aSraCpo,aSRAori,aSRAalt, .T.)

						If len(aCpoCAT) > 0 .AND. (aCpoCAT[2] $ cCI)
							oModel:LoadValue( "MODEL_CUU","CUU_CATCI",FGetIdInt("codCateg","",aCpoCAT[2],"",.F.))
						EndIf

					//Cargo
						aCpoCarg:= fGM27Cpo("RA_CARGO",aSraCpo,aSRAori,aSRAalt)
						cCC		:= fGM26Cpo("RA_CC",aSraCpo,aSRAalt) //Conteudo do campo que sera gravado

						If Len(aCpoCarg) > 0
							cCmp	:= fGM26Crg(aCpoCarg[2] , cCC)
							oModel:LoadValue( "MODEL_CUU","CUU_CARCI",FGetIdInt("codCargo","",cCmp,"",.F.))
						EndIf

					//Funcao
						aCpoFun:= fGM27Cpo("RA_CODFUNC",aSraCpo,aSRAori,aSRAalt)
						If Len(aCpoFun) > 0
							aCpoFun2 := fGM26Fun(aCpoFun[2])
							If aCpoFun2 > 0
								oModel:LoadValue( "MODEL_CUU","CUU_CBOCI",FGetIdInt("codCBO","",	aCpoFun2[2],"",.F.)) 		//Carga CBO
								oModel:LoadValue( "MODEL_CUU","CUU_FUNCI",FGetIdInt("codFuncao","",	aCpoFun2[1],"",.F.))		//Carga Funcao
							EndIf
						EndIf

					//vlrSalFixo
						aCpo:= {}
						aCpo:= fGM27Cpo("RA_SALARIO",aSraCpo,aSRAori,aSRAalt)
						If len(aCpo) > 0
							oModel:LoadValue( "MODEL_CUU","CUU_VLSLCI",aCpo[2])
						EndIf

					//unidSalFixo
						aCpo:= {}
						aCpo:= fGM27Cpo("RA_CATFUNC",aSraCpo,aSRAori,aSRAalt)
						If len(aCpo) > 0
							nPagoFixo := aScan(aPagoFixo,{|x| Alltrim(x[1]) == aCpo[2]})

							If nPagoFixo <> 0
								oModel:LoadValue( "MODEL_CUU","CUU_UNSLCI",aPagoFixo[nPagoFixo,2])
							Endif
						EndIf
					EndIf

				//*******************
				//Servidor Publico indicado para conselho ou orgao de classe
				//*******************
					If aTrab[3] == '305'
					//Cargo
						aCpoCarg:= fGM27Cpo("RA_CARGO",aSraCpo,aSRAori,aSRAalt)
						cCC		:= fGM26Cpo("RA_CC",aSraCpo,aSRAalt) //Conteudo do campo que sera gravado

						If Len(aCpoCarg) > 0
							cCmp	:= fGM26Crg(aCpoCarg[2] , cCC)
							oModel:LoadValue( "MODEL_CUU","CUU_CARSP",FGetIdInt("codCargo","",cCmp,"",.F.))
						EndIf

					//Funcao
						aCpoFun:= fGM27Cpo("RA_CODFUNC",aSraCpo,aSRAori,aSRAalt)
						If Len(aCpoFun) > 0
							aCpoFun2 := fGM26Fun(aCpoFun[2])
							If len(aCpoFun2) > 0
								oModel:LoadValue( "MODEL_CUU","CUU_CBOSP",FGetIdInt("codCBO","",	aCpoFun2[2],"",.F.)) 		//Carga CBO
								oModel:LoadValue( "MODEL_CUU","CUU_FUNSP",FGetIdInt("codFuncao","",	aCpoFun2[1],"",.F.))		//Carga Funcao
							EndIf
						EndIf

					//vlrSalFixo
						aCpo:= {}
						aCpo:= fGM27Cpo("RA_SALARIO",aSraCpo,aSRAori,aSRAalt)
						If len(aCpo) > 0
							oModel:LoadValue( "MODEL_CUU","CUU_VLSLSP",aCpo[2])
						EndIf

					//unidSalFixo
						aCpo:= {}
						aCpo:= fGM27Cpo("RA_CATFUNC",aSraCpo,aSRAori,aSRAalt)
						If len(aCpo) > 0
							nPagoFixo := aScan(aPagoFixo,{|x| Alltrim(x[1]) == aCpo[2]})

							If nPagoFixo <> 0
								oModel:LoadValue( "MODEL_CUU","CUU_UNSLSP",aPagoFixo[nPagoFixo,2])
							Endif
						EndIf
					EndIf

				//*******************
				//ESTAGIARIO
				//*******************
					If aTrab[3] == '901'
						If cOrigem == "GPEA010"
						//vlrBolsa
							aCpo:= {}
							aCpo:= fGM27Cpo("RA_SALARIO",aSraCpo,aSRAori,aSRAalt)
							If len(aCpo) > 0
								oModel:LoadValue( "MODEL_CUU","CUU_VLBLES",aCpo[2])
							EndIf
						EndIf
						fG26Estg(oModel, cFilEnv, cMatric)
					EndIf
				EndIf

				FWFormCommit( oModel )
				oModel:DeActivate()
				lCarga		:= .T.
			EndIf
		End Transaction

	ElseIf (aTrab[1] .AND. cTpCad == "INCLUSAO")		//Carga S-2600 - Carga Completa TSV
		aAdd( aChave, {"C", "C9V_CPF"   ,ALLTRIM(cCPF), .T. } )
		aAdd( aChave, {"C", "C9V_NOMEVE" ,"S2600", .T. } )
		Begin Transaction
			If FTafVldOpe( "C9V", 4, @nOpc, cFilEnv, @aIncons, aChave, @oModel, "TAFA279","",4,.F. )
				If nOpc <> 5

				//DEPENDENTES - SRB
					If nOpc == 4 .AND. cOrigem == 'GPEA020'
						fG26Dep(oModel, cMatric)
					EndIf

					If  nOpc == 4 .AND. aTrab[3] == '401' .AND. cOrigem == 'GPEA926' //Sucessao de Vinculo somente dirigente sindical
						aVinculot := fGM23Vinc(FWCodFil(), cMatric)
						nTotVinc := LEN(aVinculot)
						If len(aVinculot) > 0 .AND. aVinculot[1,1] == "4"
							oModel:LoadValue( "MODEL_CUU","CUU_CATODS",FGetIdInt("codCateg","",aVinculot[1,12],"",.F.))
							oModel:LoadValue( "MODEL_CUU","CUU_CNPJDS",aVinculot[1,8])
							oModel:LoadValue( "MODEL_CUU","CUU_MATODS",aVinculot[1,9])
							oModel:LoadValue( "MODEL_CUU","CUU_DTADDS",aVinculot[1,10])
						EndIf
					EndIf

					If  nOpc == 4 .AND. aTrab[3] == '901' .AND. cOrigem == 'GPEA920'
						fG26Estg(oModel, cFilEnv, cMatric)
					EndIf

					If cOrigem == 'GPEA010'				//TRABALHADOR

						If nOpc == 3
							oModel:LoadValue( "MODEL_C9V","C9V_CPF"	,cCPF)
							oModel:LoadValue( "MODEL_C9V", "C9V_NOMEVE", "S2600" )

							If aTrab[3] == '901'
								fG26Estg(oModel, cFilEnv, cMatric)
							EndIf
						EndIf
					//*******************
					//Carga Cadastral
					//*******************
						fG26Cad (oModel,aSraCpo,aSRAalt, .F.)

					//*******************
					//Carga Contratual
					//*******************
						fCtr2600 (oModel,aSraCpo,aSRAalt, cMatric, cOrigem)
					EndIf

				EndIf

				FWFormCommit( oModel )
				oModel:DeActivate()
				lCarga		:= .T.
			EndIf

		End Transaction

	EndIf

	RestArea(aArea)
Return lCarga

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fGM27Cpo  ³ Autor ³ Glaucia Messina       ³ Data ³ 15/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carga de dados Trabalhador no TAF - evento S-2200           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fGM27Cpo                                     		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	cExp1: Nome do campo SRA, que contem o valor a ser atrib  ³±±
±±³          ³ 	aExp2: Array com nome dos campos SRA                      ³±±
±±³          ³ 	aExp3: Array com o conteudo dos campos SRA                ³±±
±±³          ³ 	lExp4: indicar se o ALLTRIM devera ser utilizado.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fGM27Cpo(cCpoSRA,aSraCpo,aSRAori,aSRAalt, lALLTRIM)
	Local aArea		:= GetArea()
	Local nPosCmp	:= 0
	Local cCpoOri	:= ""
	Local cCpoAlt	:= ""
	Local aRetorno	:= {}
	DEFAULT lALLTRIM	:= .F.

	nPosCmp	:= aScan(aSraCpo, { |x| x[ 2 ] == cCpoSRA } )
	If nPosCmp > 0 .AND. aSRAori[1,nPosCmp] <> aSRAalt[1,nPosCmp]
		aRetorno := {IIf(lALLTRIM, ALLTRIM(aSRAOri[1,nPosCmp]),aSRAOri[1,nPosCmp]), ;
			IIf(lALLTRIM, ALLTRIM(aSRAalt[1,nPosCmp]),aSRAalt[1,nPosCmp])}
	Else
		cMsgSRA := OemtoAnsi(cCpoSRA) + CRLF
	EndIf

	RestArea(aArea)
Return (aRetorno)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fG26Cad   ³ Autor ³ Glaucia Messina       ³ Data ³ 15/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carga cadastral do trabalhador TSV                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fG27Cad                                      		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	oExp1: Model de carga do trabalhador                      ³±±
±±³          ³ 	aExp2: Array com nome dos campos SRA                      ³±±
±±³          ³ 	aExp3: Array com o conteudo dos campos SRA                ³±±
±±³          ³ 	lExp4: indicar se o ALLTRIM devera ser utilizado.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fG26Cad (oModel,aSraCpo,aSRAalt, lTrabVin)
	Local aArea		:= GetArea()
	Local nPosCmp	:= 0
	Local cCmp		:= ''
	Local cCmp1		:= ''

	DEFAULT lTrabVin:= .F.
	DEFAULT aSraCpo := {}
	DEFAULT aSRAalt := {}

	STATIC aEstCivi		:= GpeEstCivi("1")
	STATIC aInstrucao	:= {{'10','01'},{'20','02'},{'25','03'},{'30','04'},{'35','05'},{'40','06'},{'45','07'},;
		{'50','08'},{'55','09'},{'65','11'},{'75','12'},{'85','10'},{'95','12'}}

	f26Carga(oModel,"MODEL_C9V","C9V_NIS","RA_PIS",aSraCpo,aSRAalt,.T.)
	cCmp := SUBSTR(fGM26Cpo("RA_NOMECMP",aSraCpo,aSRAalt,.T.),1,60)
	If EMPTY(cCmp)
		cCmp :=fGM26Cpo("RA_NOME",aSraCpo,aSRAalt,.T.)
	EndIf
	oModel:LoadValue( "MODEL_C9V","C9V_NOME"	, cCmp)

	f26Carga(oModel,"MODEL_C9V","C9V_SEXO","RA_SEXO",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_RCCOR","RA_RACACOR",aSraCpo,aSRAalt)

	nPosCmp := aScan(aEstCivi,{|x| Alltrim(x[1]) == fGM26Cpo("RA_ESTCIVI",aSraCpo,aSRAalt) })
	If nPosCmp > 0
		oModel:LoadValue( "MODEL_C9V","C9V_ESTCIV", aEstCivi[nPosCmp,2])
	EndIf

	nPosCmp := aScan(aInstrucao,{|x| Alltrim(x[1]) == fGM26Cpo("RA_GRINRAI",aSraCpo,aSRAalt) })
	If nPosCmp > 0
		oModel:LoadValue( "MODEL_C9V","C9V_GRINST",FGetIdInt("grauInstrucao","",aInstrucao[nPosCmp,2],"",.F.))
	EndIf

//NASCIMENTO
	f26Carga(oModel,"MODEL_C9V","C9V_DTNASC","RA_NASC",aSraCpo,aSRAalt,,,.T.)

	cCmp := fGM26Cpo("RA_CPAISOR",aSraCpo,aSRAalt,.T.)
	oModel:LoadValue( "MODEL_C9V","C9V_CODPAI",FGetIdInt( "paisNascto","",fM23Pais(cCmp) ),"",.F.)

	cCmp1 := fGM26Cpo("RA_NATURAL",aSraCpo,aSRAalt)
	cCmp2 := fGM26Cpo("RA_CODMUNN",aSraCpo,aSRAalt,.T.)

	If (cCmp == "01058") .AND. (cCmp1 != "EX")
		oModel:LoadValue( "MODEL_C9V","C9V_CODUF",FGetIdInt( "uf","",cCmp1,"",.F.))
		oModel:LoadValue( "MODEL_C9V","C9V_CODMUN",FGetIdInt("uf","codMunicipio",cCmp1,cCmp2,.F.))
	EndIf

	cCmp	:= fM23Pais(fGM26Cpo("RA_NACIONC",aSraCpo,aSRAalt,.T.))
	oModel:LoadValue( "MODEL_C9V","C9V_PAINAC",FGetIdInt("paisNacionalidade","",cCmp,"",.F.))

	f26Carga(oModel,"MODEL_C9V","C9V_NOMMAE","RA_MAE",aSraCpo,aSRAalt,.T.)
	f26Carga(oModel,"MODEL_C9V","C9V_NOMPAI","RA_PAI",aSraCpo,aSRAalt,.T.)

//DOCUMENTOS
//CTPS
	f26Carga(oModel,"MODEL_C9V","C9V_NRCTPS","RA_NUMCP",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_SERCTP","RA_SERCP",aSraCpo,aSRAalt)
	cCmp	:= fGM26Cpo("RA_UFCP",aSraCpo,aSRAalt,.T.)
	oModel:LoadValue( "MODEL_C9V","C9V_UFCTPS",FGetIdInt("ufCtps","",cCmp,"",.F.))

//RIC
	f26Carga(oModel,"MODEL_C9V","C9V_NRRIC","RA_NUMRIC",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_OREMRI","RA_EMISRIC",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_DTEXRI","RA_DEXPRIC",aSraCpo,aSRAalt,,,.T.)

//RG
	f26Carga(oModel,"MODEL_C9V","C9V_NRRG","RA_RG",aSraCpo,aSRAalt,.T.,14)
	f26Carga(oModel,"MODEL_C9V","C9V_OREMRG","RA_RGEXP",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_DTEMRG","RA_DTRGEXP",aSraCpo,aSRAalt,,,.T.)

//RNE
	f26Carga(oModel,"MODEL_C9V","C9V_NRRNE","RA_RNE",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_OREMRN","RA_RNEORG",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_DTEMRN","RA_RNEDEXP",aSraCpo,aSRAalt,,,.T.)

//Orgao de Classe
	f26Carga(oModel,"MODEL_C9V","C9V_NUMOC","RA_CODIGO",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_OREMOC","RA_OCEMIS",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_DTEXOC","RA_OCDTEXP",aSraCpo,aSRAalt,,,.T.)
	f26Carga(oModel,"MODEL_C9V","C9V_DTVLOC","RA_OCDTVAL",aSraCpo,aSRAalt,,,.T.)

//CNH
	f26Carga(oModel,"MODEL_C9V","C9V_NRCNH","RA_HABILIT",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_OREMCN","RA_CNHORG",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_DTEXCN","RA_DTEMCNH",aSraCpo,aSRAalt,,,.T.)
	f26Carga(oModel,"MODEL_C9V","C9V_DTVLCN","RA_DTVCCNH",aSraCpo,aSRAalt,,,.T.)

//Endereco
	f26Carga(oModel,"MODEL_C9V","C9V_LOGRAD","RA_LOGRDSC",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_NRLOG","RA_LOGRNUM",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_COMLOG","RA_COMPLEM",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_BAIRRO","RA_BAIRRO",aSraCpo,aSRAalt)

	cCmp := aSRAalt[1,aScan(aSraCpo, { |x| x[ 2 ] == "RA_RESEXT" })]
	If EMPTY(cCmp) .OR. cCmp=='2'
	//Residente no Brasil
		oModel:LoadValue( "MODEL_C9V","C9V_PAIS",FGetIdInt( "paisResidencia","","105","",.F.))
		cCmp := fGM26Cpo("RA_LOGRTP",aSraCpo,aSRAalt)
		oModel:LoadValue( "MODEL_C9V","C9V_TPLOGR",FGetIdInt("tpLogradouro","",cCmp,"",.T.))
		f26Carga(oModel,"MODEL_C9V","C9V_CEP","RA_CEP",aSraCpo,aSRAalt)

		cCmp := fGM26Cpo("RA_ESTADO",aSraCpo,aSRAalt)
		oModel:LoadValue( "MODEL_C9V","C9V_UF",FGetIdInt("uf", "", cCmp))

		cCmp1 := fGM26Cpo("RA_CODMUN",aSraCpo,aSRAalt,.T.)
		oModel:LoadValue( "MODEL_C9V","C9V_MUN",FGetIdInt("uf", "codMunicipio",cCmp, cCmp1))
	Else
	//Residente no exterior
		cCmp := fM23Pais(fGM26Cpo("RA_PAISEXT",aSraCpo,aSRAalt,.T.))
		oModel:LoadValue( "MODEL_C9V","C9V_PAIS",FGetIdInt( "paisResidencia","", cCmp,"",.F.))

		f26Carga(oModel,"MODEL_C9V","C9V_NOMCID","RA_MUNICIP",aSraCpo,aSRAalt)
		f26Carga(oModel,"MODEL_C9V","C9V_CEP","RA_CPOSTAL",aSraCpo,aSRAalt)
	EndIf

//Trabalhador estrangeiro
	f26Carga(oModel,"MODEL_C9V","C9V_DTCHEG","RA_DATCHEG",aSraCpo,aSRAalt,,,.T.)
	f26Carga(oModel,"MODEL_C9V","C9V_DTNATU","RA_DATNATU",aSraCpo,aSRAalt,,,.T.)
	f26Carga(oModel,"MODEL_C9V","C9V_CASBRA","RA_CASADBR",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_FILBRA","RA_FILHOBR",aSraCpo,aSRAalt)

//Info Deficiencia - campo Memo
	nPosCmp	:= aScan(aSraCpo, { |x| x[ 2 ] == "RA_OBSDEFI" } )
	If nPosCmp > 0
		oModel:LoadValue( "MODEL_C9V","C9V_OBSDEF",ALLTRIM(M->RA_OBSDEFI))
	EndIf

	cCmp := fGM26Cpo("RA_PORTDEF",aSraCpo,aSRAalt)
	oModel:LoadValue( "MODEL_C9V","C9V_DEFFIS",IIf(AT("1",cCmp) > 0 , "1","2"))
	oModel:LoadValue( "MODEL_C9V","C9V_DEFAUD",IIf(AT("2",cCmp) > 0 , "1","2"))
	oModel:LoadValue( "MODEL_C9V","C9V_DEFVIS",IIf(AT("3",cCmp) > 0 , "1","2"))
	oModel:LoadValue( "MODEL_C9V","C9V_DEFMEN",IIf(AT("4",cCmp) > 0 , "1","2"))
	oModel:LoadValue( "MODEL_C9V","C9V_DEFINT",IIf(AT("5",cCmp) > 0 , "1","2"))
	oModel:LoadValue( "MODEL_C9V","C9V_REABIL",IIf(AT("6",cCmp) > 0 , "1","2"))

//CONTATO
	f26Carga(oModel,"MODEL_C9V","C9V_DDDFPR","RA_DDDFONE",aSraCpo,aSRAalt,.T.,3)

	cCmp := fGM26Cpo("RA_TELEFON",aSraCpo,aSRAalt,.T.)
	oModel:LoadValue( "MODEL_C9V","C9V_FONPRC",SUBSTR(cCmp,1,12))

	f26Carga(oModel,"MODEL_C9V","C9V_DDDFAL","RA_DDDCELU",aSraCpo,aSRAalt,.T.,3)
	f26Carga(oModel,"MODEL_C9V","C9V_FONALT","RA_NUMCELU",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_EMAILP","RA_EMAIL",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_EMAILA","RA_EMAIL2",aSraCpo,aSRAalt)

	If lTrabVin
	//APOSENTADORIA
		cCmp := fGM26Cpo("RA_EAPOSEN",aSraCpo,aSRAalt)
		oModel:LoadValue( "MODEL_C9V","C9V_APOSEN",IIf(cCmp=='1','1','2'))
	EndIf

	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fDif2620  ³ Autor ³ Glaucia Messina       ³ Data ³ 15/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carga de dados Trabalhador Sem Vinculo TAF - evento S-2620  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ f26Carga()                                   		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	aExp1: Array com nome dos campos SRA     	        	  ³±±
±±³          ³ 	aExp2: Array com o conteudo dos campos SRA Originais 	  ³±±
±±³          ³ 	aExp3: Array com o conteudo dos campos SRA Alterados 	  ³±±
±±³          ³ 	lExp4: se trabalhador e estagiario                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
//Campos que caracterizam alteracao CONTRATUAL TSV
Static Function fDif2620(aSraCpo,aSRAOrig,aSRAalt, lEstagio)
	Local aArea		:= GetArea()
	Local nPosCmp	:= 0
	Local x			:= 1
	Local y			:= 0

	Local aCampos	:= {"RA_CARGO", "RA_CC", "RA_CODFUNC", "RA_SALARIO", "RA_CATFUNC"}
	Local lAltera	:= .F.

	If lEstagio
		aCampos	:= {"RA_SALARIO"}
	EndIf

	While !lAltera .AND. (x <= len(aCampos))
		nPosCmp	:= aScan(aSraCpo, { |y| y[ 2 ] == aCampos[x] } )
		If nPosCmp > 0 .AND. aSRAOrig[1,nPosCmp] <> aSRAalt[1,nPosCmp]
			lAltera := .T.
		EndIf
		x++
	Enddo

	RestArea(aArea)
Return lAltera

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fCtr2600  ³ Autor ³ Glaucia Messina       ³ Data ³ 28/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carga Contratual Admissao TSV - evento S-2600               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fCtr2600()                                   		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	oExp1: Modelo MVC que tera carga de campo    	    	  ³±±
±±³          ³ 	aExp2: Array com nome dos campos SRA               	 	  ³±±
±±³          ³ 	aExp3: Array com o conteudo dos campos SRA      	 	  ³±±
±±³          ³ 	cExp4: Matricula do trabalhador sem vinculo               ³±±
±±³          ³ 	cExp5: Rotina Origem que deseja fazer carga               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fCtr2600(oModel,aSraCpo,aSRAalt, cMatric, cOrigem, cCatOrig, nOpc)
	Local aArea			:= GetArea()
	Local nPosCmp	:= 0
	Local cCmp		:= ''
	Local cCmp1		:= ''
	Local cTSVcat	:= ""
	Local aPagoFixo	:= {{'H','1'},{'D','2'},{'S','3'},{'M','5'},{'T','6'}}
	Local aFuncao	:= {}
	Local cFilEnv	:= FwxFilial("SRA")
	local cCI		:= '721|722|731|732|733|734|735|736|741|'

	DEFAULT cCatOrig	:= ""
	DEFAULT nOpc		:= 3

	cTSVcat := fGM26Cpo("RA_CATEFD",aSraCpo,aSRAalt)

//*******************
//Trabalhador Avulso
//*******************
	If (nOpc == 3) .AND. (cTSVcat $ '201|202|203')
		f26Carga(oModel,"MODEL_CUU","CUU_DTINAV","RA_ADMISSA",aSraCpo,aSRAalt,,,.T.)
		oModel:LoadValue( "MODEL_CUU","CUU_CATAV",FGetIdInt("codCateg","",cTSVcat,"",.F.))

//*******************
//Contribuinte Individual
//*******************
	ElseIf cTSVcat $ cCI
		f26Carga(oModel,"MODEL_CUU","CUU_DTINCI","RA_ADMISSA",aSraCpo,aSRAalt,,,.T.)
		If (nOpc == 3) .OR. (nOpc == 4 .AND. cCatOrig $ cCI)
			oModel:LoadValue( "MODEL_CUU","CUU_CATCI",FGetIdInt("codCateg","",cTSVcat,"",.F.))
		EndIf


	//CARGO
		cCmp := fGM26Cpo("RA_CARGO",aSraCpo,aSRAalt)
		cCC := fGM26Cpo("RA_CC",aSraCpo,aSRAalt)
		If !Empty(cCmp) .AND. !(EMPTY(cCC))
			cCmp1	:= fGM26Crg(cCmp , cCC)
			If cCmp1 <> ""
				oModel:LoadValue( "MODEL_CUU","CUU_CARCI",FGetIdInt("codCargo","",cCmp1,"",.F.))
			EndIf
		EndIf

	//FUNCAO - CBO
		cCmp := fGM26Cpo("RA_CODFUNC",aSraCpo,aSRAalt)
		If !EMPTY(cCmp)
			aFuncao := fGM26Fun(cCmp)
			If Len(aFuncao) > 0
				oModel:LoadValue( "MODEL_CUU","CUU_CBOCI",FGetIdInt("codCBO","",aFuncao[2],"",.F.))
				oModel:LoadValue( "MODEL_CUU","CUU_FUNCI",FGetIdInt("codFuncao","",aFuncao[1],"",.F.))
			EndIf
		EndIf

	//REMUNERACAO
		f26Carga(oModel,"MODEL_CUU","CUU_VLSLCI","RA_SALARIO",aSraCpo,aSRAalt,,,.T.)

		cCmp := fGM26Cpo("RA_CATFUNC",aSraCpo,aSRAalt)
		nPosCmp := aScan(aPagoFixo,{|x| Alltrim(x[1]) == cCmp})
		If nPosCmp <> 0
			oModel:LoadValue( "MODEL_CUU","CUU_UNSLCI",aPagoFixo[nPosCmp,2])
		Endif

	//Informacoes exclusivas a categoria Diretor nao empregado com direito FGTS
		If cTSVcat $ '721'
			nPosCmp	:= aScan(aSraCpo, { |x| x[ 2 ] == "RA_OPCAO" } )
			If nPosCmp > 0
				dOpcao  := 	aSRAalt[1,nPosCmp]
				oModel:LoadValue( "MODEL_CUU","CUU_DTFGCI",dOpcao)

			//Optante pelo FGTS
				If 	dOpcao >= STOD('04/10/1988')
					nOptante:= '1'
				Else
					cCmp  := fGM26Cpo("RA_ALTOPC",aSraCpo,aSRAalt)
					nOptante := IIf(cCmp=='S','1','2')
				EndIf
				oModel:LoadValue( "MODEL_CUU","CUU_OPFGCI",nOptante)
			EndIf
		EndIf
//*******************
//Servidor Publico indicado para conselho ou orgao de classe
//*******************
	ElseIf cTSVcat == '305'
		f26Carga(oModel,"MODEL_CUU","CUU_DTINSP","RA_ADMISSA",aSraCpo,aSRAalt,,,.T.)
		If ( nOpc == 3 ) .OR. (nOpc == 4 .AND.  cCatOrig == '305')
			oModel:LoadValue("MODEL_CUU","CUU_CATSP",FGetIdInt("codCateg","",cTSVcat,"",.F.))
		EndIf

	//CARGO
		cCmp := fGM26Cpo("RA_CARGO",aSraCpo,aSRAalt)
		cCC := fGM26Cpo("RA_CC",aSraCpo,aSRAalt)
		If !Empty(cCmp) .AND. !(EMPTY(cCC))
			cCmp1	:= fGM26Crg(cCmp , cCC)
			If cCmp1 <> ""
				oModel:LoadValue( "MODEL_CUU","CUU_CARSP",FGetIdInt("codCargo","",cCmp1,"",.F.))
			EndIf
		EndIf

	//FUNCAO - CBO
		cCmp := fGM26Cpo("RA_CODFUNC",aSraCpo,aSRAalt)
		If !EMPTY(cCmp)
			aFuncao := fGM26Fun(cCmp)
			If Len(aFuncao) > 0
				oModel:LoadValue("MODEL_CUU","CUU_CBOSP",FGetIdInt("codCBO","",aFuncao[2],"",.F.)) 		//Carga CBO
				oModel:LoadValue("MODEL_CUU","CUU_FUNSP",FGetIdInt("codFuncao","",aFuncao[1],"",.F.))		//Carga Funcao
			EndIf
		EndIf

	//Remuneracao
		f26Carga(oModel,"MODEL_CUU","CUU_VLSLSP","RA_SALARIO",aSraCpo,aSRAalt,,,.T.)

		cCmp := fGM26Cpo("RA_CATFUNC",aSraCpo,aSRAalt)
		nPosCmp := aScan(aPagoFixo,{|x| Alltrim(x[1]) == cCmp})
		If nPosCmp <> 0
			oModel:LoadValue( "MODEL_CUU","CUU_UNSLSP",aPagoFixo[nPosCmp,2])
		Endif

//*******************
//DIRIGENTE SINDICAL
//*******************
	ElseIf nOpc == 3 .AND. cTSVcat == '401'
		f26Carga(oModel,"MODEL_CUU","CUU_DTINDS","RA_ADMISSA",aSraCpo,aSRAalt,,,.T.)
		If ( nOpc == 3 ) .AND. (nOpc == 4 .AND. cCatOrig == '401')
			oModel:LoadValue( "MODEL_CUU","CUU_CATDS",FGetIdInt("codCateg","",cTSVcat,"",.F.))
		EndIf

//*******************
//ESTAGIARIO
//*******************
	ElseIf cTSVcat == '901'
		f26Carga(oModel,"MODEL_CUU","CUU_DTINES","RA_ADMISSA",aSraCpo,aSRAalt,,,.T.)
		If ( nOpc == 3 ) .AND. (nOpc == 4 .AND. cCatOrig == '901')
			oModel:LoadValue( "MODEL_CUU","CUU_CATES",FGetIdInt("codCateg","",cTSVcat,"",.F.))
		EndIf
		f26Carga(oModel,"MODEL_CUU","CUU_VLBLES","RA_SALARIO",aSraCpo,aSRAalt,,,.T.)
	EndIf
	*/
	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fG26Estg  ³ Autor ³ Glaucia Messina       ³ Data ³ 29/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carga Contratual Admissao TSV - evento S-2600               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fG26Estg (oExp1,cExp2, cExp3 )                  		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	oExp1: Modelo MVC que tera carga de estagiario 	    	  ³±±
±±³          ³ 	cExp2: Filial TSV                                         ³±±
±±³          ³ 	cExp3: Matricula TSV                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fG26Estg(oModel, cFilEnv, cMatric)
	Local aArea			:= GetArea()
	Local aEstagio		:= {}
	Local aInstit		:= {}
	Local aAgente		:= {}
	Local aCoord		:= {}

	fGM23Estag(FWCodFil(),cMatric, dDatabase, @aEstagio, @aInstit, @aAgente, @aCoord )

	If len(aEstagio) == 1
		oModel:LoadValue( "MODEL_CUU","CUU_NATEES",aEstagio[1,1])
		oModel:LoadValue( "MODEL_CUU","CUU_NIVEES",aEstagio[1,2])
		oModel:LoadValue( "MODEL_CUU","CUU_AREAES",aEstagio[1,3])
		oModel:LoadValue( "MODEL_CUU","CUU_NRAPES",aEstagio[1,4])
		oModel:LoadValue( "MODEL_CUU","CUU_DTTEES",aEstagio[1,5])
	EndIf

	If len(aInstit) == 1
		oModel:LoadValue( "MODEL_CUU","CUU_CNPEES",aInstit[1,1])
		oModel:LoadValue( "MODEL_CUU","CUU_NOMEES",aInstit[1,2])
		oModel:LoadValue( "MODEL_CUU","CUU_LOGEES",aInstit[1,3])
	//oModel:LoadValue( "MODEL_CUU","CUU_NLGEES","") - Nao temos este item no cadastro
		oModel:LoadValue( "MODEL_CUU","CUU_BAREES",aInstit[1,4])
		oModel:LoadValue( "MODEL_CUU","CUU_CEPES",aInstit[1,5])
		oModel:LoadValue( "MODEL_CUU","CUU_MUNES",FGetIdInt("uf", "codMunicipio",aInstit[1,7],ALLTRIM(aInstit[1,6])))
		oModel:LoadValue( "MODEL_CUU","CUU_UFES",FGetIdInt("uf", "", aInstit[1,7]))
	EndIf

	If len(aAgente) == 1
		oModel:LoadValue( "MODEL_CUU","CUU_CNPAES",aAgente[1,1])
		oModel:LoadValue( "MODEL_CUU","CUU_NOMAES",aAgente[1,2])
		oModel:LoadValue( "MODEL_CUU","CUU_LOGAES",aAgente[1,3])
		oModel:LoadValue( "MODEL_CUU","CUU_NLGAES",aAgente[1,4])
		oModel:LoadValue( "MODEL_CUU","CUU_BARAES",aAgente[1,5])
		oModel:LoadValue( "MODEL_CUU","CUU_CEPAES",aAgente[1,6])
		oModel:LoadValue( "MODEL_CUU","CUU_MUNAES",	FGetIdInt("uf", "codMunicipio",aAgente[1,8],ALLTRIM(aAgente[1,7])))
		oModel:LoadValue( "MODEL_CUU","CUU_UFAES",FGetIdInt("uf", "", aAgente[1,8]))
	EndIf

	If len(aCoord) == 1
		oModel:LoadValue( "MODEL_CUU","CUU_CPFCES",aCoord[1,1])
		oModel:LoadValue( "MODEL_CUU","CUU_NOMCES",aCoord[1,2])
	EndIf

	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fG26Dep   ³ Autor ³ Glaucia Messina       ³ Data ³ 30/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carga Dependentes                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fG26Estg (oExp1,cExp2, cExp3 )                  		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	oExp1: Modelo MVC que tera carga de dependentes	    	  ³±±
±±³          ³ 	cExp2: Matricula TAF                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fG26Dep(oModel, cMatric)
	Local aArea			:= GetArea()
	Local aDepend		:= {}
	Local nI			:= 0

	For nI := 1 To oModel:GetModel("MODEL_C9Y"):Length()
		oModel:GetModel("MODEL_C9Y"):GoLine(nI)
		oModel:GetModel("MODEL_C9Y"):DeleteLine()
	Next nI

	aDepend:= fGM23Dep(FWCodFil(), cMatric)
	If len(aDepend) > 0
		nI := 1
		For nI:= 1 To len(aDepend)
			oModel:GetModel( "MODEL_C9Y" ):lValid:= .T.
			oModel:GetModel( "MODEL_C9Y" ):AddLine()

			oModel:LoadValue( "MODEL_C9Y", "C9Y_IDDEP" , StrZero(nI,6) )
			oModel:LoadValue( "MODEL_C9Y", "C9Y_TPDEP" , FGetIdInt( "tpDep", "",aDepend[nI,1],"",.F.  ))
			oModel:LoadValue( "MODEL_C9Y", "C9Y_NOMDEP", aDepend[nI,2] )
			oModel:LoadValue( "MODEL_C9Y", "C9Y_DTNASC", aDepend[nI,3] )
			oModel:LoadValue( "MODEL_C9Y", "C9Y_CPFDEP", aDepend[nI,4] )
			oModel:LoadValue( "MODEL_C9Y", "C9Y_DEPIRF", aDepend[nI,5] )
			oModel:LoadValue( "MODEL_C9Y", "C9Y_DEPSFA", aDepend[nI,6] )
		Next nI
	EndIf

	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fG26Vinc  ³ Autor ³ Glaucia Messina       ³ Data ³ 30/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carga Sucessao de Vinculos Trabalhador                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fG26Estg (oExp1,cExp2, cExp3 )                  		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	oExp1: Modelo MVC que tera carga de dependentes	    	  ³±±
±±³          ³ 	cExp2: Filial TAF                                         ³±±
±±³          ³ 	cExp3: Tipo de Admissao SRA                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fG26Vinc(oModel, cMatric, cTipoAdm)
	Local aArea		:= GetArea()
	Local aVinculot:= {}
	Local nTotVinc	:= 0

	aVinculot := fGM23Vinc(FWCodFil(), cMatric)
	nTotVinc := LEN(aVinculot)

	If nTotVinc > 0
		oModel:LoadValue( "MODEL_CUP","CUP_TPADMI",IIf(aVinculot[1,1]<>"",aVinculot[1,1],"1"))
		oModel:LoadValue( "MODEL_CUP","CUP_INDADM",IIf(aVinculot[1,1]<>"",aVinculot[1,2],"1"))
		oModel:LoadValue( "MODEL_CUP","CUP_INDPRE",IIf(aVinculot[1,3]<>"",aVinculot[1,3],cTipoAdm))
		oModel:LoadValue( "MODEL_CUP","CUP_CNPJEA",aVinculot[1,4]) //RFZ_CNPJAN
		oModel:LoadValue( "MODEL_CUP","CUP_MATANT",aVinculot[1,5]) //RFZ_MATANT
		oModel:LoadValue( "MODEL_CUP","CUP_DTINVI",aVinculot[1,6]) //RFZ_DTADAN
		oModel:LoadValue( "MODEL_CUP","CUP_OBSVIN",aVinculot[1,7]) //RFZ_OBSVAN
		oModel:LoadValue( "MODEL_CUP","CUP_CNPJCD",aVinculot[1,8]) //RFZ_CNPJCE
		oModel:LoadValue( "MODEL_CUP","CUP_MATRCD",aVinculot[1,9]) //RFZ_MATCED
		oModel:LoadValue( "MODEL_CUP","CUP_DTADCD",aVinculot[1,10])//RFZ_DTADCE
		oModel:LoadValue( "MODEL_CUP","CUP_INFOCD",aVinculot[1,11])//RFZ_INFONU

	Else //Array vazio indica que nao ha dados na RFZ
		oModel:LoadValue( "MODEL_CUP","CUP_TPADMI","1")
		oModel:LoadValue( "MODEL_CUP","CUP_INDADM","1")
		oModel:LoadValue( "MODEL_CUP","CUP_INDPRE",	cTipoAdm)
	//SUCESSAO
		oModel:LoadValue( "MODEL_CUP","CUP_CNPJEA","")
		oModel:LoadValue( "MODEL_CUP","CUP_MATANT","")
		oModel:LoadValue( "MODEL_CUP","CUP_DTINVI","")
		oModel:LoadValue( "MODEL_CUP","CUP_OBSVIN","")
	//CESSAO
		oModel:LoadValue( "MODEL_CUP","CUP_CNPJCD","")
		oModel:LoadValue( "MODEL_CUP","CUP_MATRCD","")
		oModel:LoadValue( "MODEL_CUP","CUP_DTADCD","")
		oModel:LoadValue( "MODEL_CUP","CUP_INFOCD","")
	EndIf
	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fG26Temp  ³ Autor ³ Glaucia Messina       ³ Data ³ 30/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carga Dependentes                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fG26Temp (oExp1,cExp2 )                       		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	oExp1: Modelo MVC que tera carga de dependentes	    	  ³±±
±±³          ³ 	cExp2: Matricula TAF                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fG26Temp(oModel, cMatric)
	Local aArea		:= GetArea()
	Local aAreaRBW := RBW->(GetArea())

	dbselectArea("RBW")
	RBW->(dbSetOrder(1))

	If (MsSeek((FWCodFil()+cMatric)))
		oModel:LoadValue( "MODEL_CUP","CUP_MOTCON",RBW->RBW_MOTIVO)
		If RBW->RBW_MOTIVO == '1'
			oModel:LoadValue( "MODEL_CUP","CUP_CPFTRS",RBW->RBW_CPFSUB)
			oModel:LoadValue( "MODEL_CUP","CUP_MATSUB",RBW->RBW_FILIAL+RBW->RBW_MATSUB)
		Else
			oModel:LoadValue( "MODEL_CUP","CUP_CPFTRS","")
			oModel:LoadValue( "MODEL_CUP","CUP_MATSUB","")
		Endif
	Else
		oModel:LoadValue( "MODEL_CUP","CUP_MOTCON","")
		oModel:LoadValue( "MODEL_CUP","CUP_CPFTRS","")
		oModel:LoadValue( "MODEL_CUP","CUP_MATSUB","")
	EndIf

	RestArea(aAreaRBW)
	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fGP26Dif  ³ Autor ³ Glaucia Messina       ³ Data ³ 30/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carga de dados Trabalhador Sem Vinculo TAF - evento S-2620  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ f26Carga()                                   		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	aExp1: Array com nome dos campos SRA                      ³±±
±±³          ³ 	aExp2: Array com o conteudo dos campos SRA antes Alteracao³±±
±±³          ³ 	aExp3: Array com o conteudo dos campos alterado           ³±±
±±³          ³ 	lExp4: Se Trab eh estagiario                              ³±±
±±³          ³ 	lExp5: Se trab eh TSV                                     ³±±
±±³          ³ 	cExp6: Tipo de alteracao CONTRATUAL ou CADASTRAL          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fGP26Dif(aSraCpo,aSRAOrig,aSRAalt, lEstagio, lTSV, cTipo)
	Local aArea		:= GetArea()
	Local nPosCmp	:= 0
	Local x			:= 1
	Local y			:= 0

	Local aCampos	:= {}
	Local lAltera	:= .F.

	If lTSV .AND. cTipo == "CONTRATO"
		aCampos := IIf (lEstagio, {"RA_SALARIO"}, {"RA_CARGO", "RA_CC", "RA_CODFUNC", "RA_SALARIO", "RA_CATFUNC"})
	ElseIf !lTSV .AND. cTipo == "CONTRATO"
		aCampos := 	{"RA_VIEMRAI", "RA_TPPREVI", "RA_TPJORNA", "RA_CATEFD", "RA_CODFUNC","RA_CARGO","RA_CBO",;
			"RA_SALARIO", "RA_CATFUNC", "RA_TPCONTR","RA_DTFIMCT", "RA_HRSEMAN", "RA_TNOTRAB",;
			"RA_REGRA", "RA_SEQTURN", "RA_SINDICA", "RA_NJUD14" }
	EndIf

	If cTipo == "CADASTRO"
		aCampos := 	{"RA_PIS","RA_NOMECMP", "RA_NOME",	"RA_SEXO",	"RA_RACACOR",;
			"RA_ESTCIVI","RA_GRINRAI", "RA_NASC", "RA_CPAISOR", "RA_NATURAL",;
			"RA_CODMUNN","RA_NACIONC", "RA_MAE", "RA_PAI",	"RA_NUMCP",;
			"RA_SERCP",	"RA_NUMRIC", "RA_EMISRIC", "RA_DEXPRIC", "RA_RG",;
			"RA_RGEXP",	"RA_DTRGEXP", "RA_RNE",	"RA_RNEORG","RA_RNEDEXP",;
			"RA_CODIGO","RA_OCEMIS","RA_OCDTEXP","RA_OCDTVAL","RA_HABILIT",;
			"RA_CNHORG","RA_DTEMCNH","RA_DTVCCNH","RA_LOGRDSC",	"RA_LOGRNUM",;
			"RA_COMPLEM","RA_BAIRRO","RA_RESEXT","RA_LOGRTP","RA_CEP","RA_ESTADO",;
			"RA_CODMUN","RA_PAISEXT","RA_MUNICIP","RA_CPOSTAL",	"RA_DATCHEG",;
			"RA_DATNATU","RA_CASADBR","RA_FILHOBR",	"RA_PORTDEF",	"RA_EAPOSEN",;
			"RA_DDDFONE","RA_TELEFON","RA_DDDCELU",	"RA_NUMCELU","RA_EMAIL","RA_EMAIL2"}
	Endif


	While !lAltera .AND. (x <= len(aCampos))
		nPosCmp	:= aScan(aSraCpo, { |y| y[ 2 ] == aCampos[x] } )
		If nPosCmp > 0 .AND. aSRAOrig[1,nPosCmp] <> aSRAalt[1,nPosCmp]
			lAltera := .T.
		EndIf
		x++
	Enddo

	RestArea(aArea)
Return lAltera

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fIncCad   ³ Autor ³ Glaucia Messina       ³ Data ³ 30/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Inclusao de Carga cadastral do trabalhador                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fIncCad (oExp1,cExp2, cExp3 )                  		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	oExp1: Modelo MVC que tera carga                    	  ³±±
±±³          ³ 	aExp2: array de campos disponiveis SRA                    ³±±
±±³          ³ 	aExp3: array de campos alterados  SRA                     ³±±
±±³          ³ 	lExp4: se trabalhador eh TSV                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fIncCad(oModel,aSraCpo,aSRAalt, lTSV)
	Local aArea			:= GetArea()
	Local nPosCmp	:= 0
	Local cCmp		:= ''
	Local cCmp1		:= ''
	Local cCmp2		:= ''

	DEFAULT lTSV		:= .F.

	STATIC aEstCivi		:= GpeEstCivi("1")
	STATIC aInstrucao	:= {{'10','01'},{'20','02'},{'25','03'},{'30','04'},{'35','05'},{'40','06'},{'45','07'},;
		{'50','08'},{'55','09'},{'65','11'},{'75','12'},{'85','10'},{'95','12'}}

	f26Carga(oModel,"MODEL_C9V","C9V_NIS","RA_PIS",aSraCpo,aSRAalt,.T.)

	cCmp := SUBSTR(fGM26Cpo("RA_NOMECMP",aSraCpo,aSRAalt,.T.),1,60)
	If EMPTY(cCmp)
		cCmp :=fGM26Cpo("RA_NOME",aSraCpo,aSRAalt,.T.)
	EndIf
	oModel:LoadValue( "MODEL_C9V","C9V_NOME"	, cCmp)

	f26Carga(oModel,"MODEL_C9V","C9V_SEXO","RA_SEXO",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_RCCOR","RA_RACACOR",aSraCpo,aSRAalt)

	nPosCmp := aScan(aEstCivi,{|x| Alltrim(x[1]) == fGM26Cpo("RA_ESTCIVI",aSraCpo,aSRAalt) })
	If nPosCmp > 0
		oModel:LoadValue( "MODEL_C9V","C9V_ESTCIV", aEstCivi[nPosCmp,2])
	EndIf

	nPosCmp := aScan(aInstrucao,{|x| Alltrim(x[1]) == fGM26Cpo("RA_GRINRAI",aSraCpo,aSRAalt) })
	If nPosCmp > 0
		oModel:LoadValue( "MODEL_C9V","C9V_GRINST",FGetIdInt("grauInstrucao","",aInstrucao[nPosCmp,2],"",.F.))
	EndIf

	//NASCIMENTO
	f26Carga(oModel,"MODEL_C9V","C9V_DTNASC","RA_NASC",aSraCpo,aSRAalt,,,.T.)

	cCmp := fGM26Cpo("RA_CPAISOR",aSraCpo,aSRAalt,.T.)
	oModel:LoadValue( "MODEL_C9V","C9V_CODPAI",FGetIdInt( "paisNascto","",fM23Pais(cCmp) ),"",.F.)

	cCmp1 := fGM26Cpo("RA_NATURAL",aSraCpo,aSRAalt)
	cCmp2 := fGM26Cpo("RA_CODMUNN",aSraCpo,aSRAalt,.T.)

	If (cCmp == "01058") .AND. (cCmp1 != "EX")
		oModel:LoadValue( "MODEL_C9V","C9V_CODUF",FGetIdInt( "uf","",cCmp1,"",.F.))
		oModel:LoadValue( "MODEL_C9V","C9V_CODMUN",FGetIdInt("uf","codMunicipio",cCmp1,cCmp2,.F.))
	EndIf

	cCmp	:= fM23Pais(fGM26Cpo("RA_NACIONC",aSraCpo,aSRAalt,.T.))
	oModel:LoadValue( "MODEL_C9V","C9V_PAINAC",FGetIdInt("paisNacionalidade","",cCmp,"",.F.))

	f26Carga(oModel,"MODEL_C9V","C9V_NOMMAE","RA_MAE",aSraCpo,aSRAalt,.T.)
	f26Carga(oModel,"MODEL_C9V","C9V_NOMPAI","RA_PAI",aSraCpo,aSRAalt,.T.)

	//DOCUMENTOS
	//CTPS
	f26Carga(oModel,"MODEL_C9V","C9V_NRCTPS","RA_NUMCP",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_SERCTP","RA_SERCP",aSraCpo,aSRAalt)
	cCmp	:= fGM26Cpo("RA_UFCP",aSraCpo,aSRAalt,.T.)
	oModel:LoadValue( "MODEL_C9V","C9V_UFCTPS",FGetIdInt("ufCtps","",cCmp,"",.F.))

	//RIC
	f26Carga(oModel,"MODEL_C9V","C9V_NRRIC","RA_NUMRIC",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_OREMRI","RA_EMISRIC",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_DTEXRI","RA_DEXPRIC",aSraCpo,aSRAalt,,,.T.)

	//RG
	f26Carga(oModel,"MODEL_C9V","C9V_NRRG","RA_RG",aSraCpo,aSRAalt,.T.,14)
	f26Carga(oModel,"MODEL_C9V","C9V_OREMRG","RA_RGEXP",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_DTEMRG","RA_DTRGEXP",aSraCpo,aSRAalt,,,.T.)

	//RNE
	f26Carga(oModel,"MODEL_C9V","C9V_NRRNE","RA_RNE",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_OREMRN","RA_RNEORG",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_DTEMRN","RA_RNEDEXP",aSraCpo,aSRAalt,,,.T.)

	//Orgao de Classe
	f26Carga(oModel,"MODEL_C9V","C9V_NUMOC","RA_CODIGO",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_OREMOC","RA_OCEMIS",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_DTEXOC","RA_OCDTEXP",aSraCpo,aSRAalt,,,.T.)
	f26Carga(oModel,"MODEL_C9V","C9V_DTVLOC","RA_OCDTVAL",aSraCpo,aSRAalt,,,.T.)

	//CNH
	f26Carga(oModel,"MODEL_C9V","C9V_NRCNH","RA_HABILIT",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_OREMCN","RA_CNHORG",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_DTEXCN","RA_DTEMCNH",aSraCpo,aSRAalt,,,.T.)
	f26Carga(oModel,"MODEL_C9V","C9V_DTVLCN","RA_DTVCCNH",aSraCpo,aSRAalt,,,.T.)

	//Endereco
	f26Carga(oModel,"MODEL_C9V","C9V_LOGRAD","RA_LOGRDSC",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_NRLOG","RA_LOGRNUM",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_COMLOG","RA_COMPLEM",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_BAIRRO","RA_BAIRRO",aSraCpo,aSRAalt)

	cCmp := aSRAalt[1,aScan(aSraCpo, { |x| x[ 2 ] == "RA_RESEXT" })]
	If EMPTY(cCmp) .OR. cCmp=='2'
		//Residente no Brasil
		oModel:LoadValue( "MODEL_C9V","C9V_PAIS",FGetIdInt( "paisResidencia","","105","",.F.))
		cCmp := fGM26Cpo("RA_LOGRTP",aSraCpo,aSRAalt)
		oModel:LoadValue( "MODEL_C9V","C9V_TPLOGR",FGetIdInt("tpLogradouro","",cCmp,"",.T.))
		f26Carga(oModel,"MODEL_C9V","C9V_CEP","RA_CEP",aSraCpo,aSRAalt)

		cCmp := fGM26Cpo("RA_ESTADO",aSraCpo,aSRAalt)
		oModel:LoadValue( "MODEL_C9V","C9V_UF",FGetIdInt("uf", "", cCmp))

		cCmp1 := fGM26Cpo("RA_CODMUN",aSraCpo,aSRAalt,.T.)
		oModel:LoadValue( "MODEL_C9V","C9V_MUN",FGetIdInt("uf", "codMunicipio",cCmp, cCmp1))
	Else
		//Residente no exterior
		cCmp := fM23Pais(fGM26Cpo("RA_PAISEXT",aSraCpo,aSRAalt,.T.))
		oModel:LoadValue( "MODEL_C9V","C9V_PAIS",FGetIdInt( "paisResidencia","", cCmp,"",.F.))

		f26Carga(oModel,"MODEL_C9V","C9V_NOMCID","RA_MUNICIP",aSraCpo,aSRAalt)
		f26Carga(oModel,"MODEL_C9V","C9V_CEP","RA_CPOSTAL",aSraCpo,aSRAalt)
	EndIf

	//Trabalhador estrangeiro
	f26Carga(oModel,"MODEL_C9V","C9V_DTCHEG","RA_DATCHEG",aSraCpo,aSRAalt,,,.T.)
	f26Carga(oModel,"MODEL_C9V","C9V_DTNATU","RA_DATNATU",aSraCpo,aSRAalt,,,.T.)
	f26Carga(oModel,"MODEL_C9V","C9V_CASBRA","RA_CASADBR",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_FILBRA","RA_FILHOBR",aSraCpo,aSRAalt)

	//Info Deficiencia - campo Memo
	nPosCmp	:= aScan(aSraCpo, { |x| x[ 2 ] == "RA_OBSDEFI" } )
	If nPosCmp > 0
		oModel:LoadValue( "MODEL_C9V","C9V_OBSDEF",ALLTRIM(M->RA_OBSDEFI))
	EndIf

	cCmp := fGM26Cpo("RA_PORTDEF",aSraCpo,aSRAalt)
	oModel:LoadValue( "MODEL_C9V","C9V_DEFFIS",IIf(AT("1",cCmp) > 0 , "1","2"))
	oModel:LoadValue( "MODEL_C9V","C9V_DEFAUD",IIf(AT("2",cCmp) > 0 , "1","2"))
	oModel:LoadValue( "MODEL_C9V","C9V_DEFVIS",IIf(AT("3",cCmp) > 0 , "1","2"))
	oModel:LoadValue( "MODEL_C9V","C9V_DEFMEN",IIf(AT("4",cCmp) > 0 , "1","2"))
	oModel:LoadValue( "MODEL_C9V","C9V_DEFINT",IIf(AT("5",cCmp) > 0 , "1","2"))
	oModel:LoadValue( "MODEL_C9V","C9V_REABIL",IIf(AT("6",cCmp) > 0 , "1","2"))

	//APOSENTADORIA
	If !lTSV
		cCmp := fGM26Cpo("RA_EAPOSEN",aSraCpo,aSRAalt)
		oModel:LoadValue( "MODEL_C9V","C9V_APOSEN",IIf(cCmp=='1','1','2'))
	EndIf

	//CONTATO
	f26Carga(oModel,"MODEL_C9V","C9V_DDDFPR","RA_DDDFONE",aSraCpo,aSRAalt,.T.,3)

	cCmp := fGM26Cpo("RA_TELEFON",aSraCpo,aSRAalt,.T.)
	oModel:LoadValue( "MODEL_C9V","C9V_FONPRC",SUBSTR(cCmp,1,12))

	f26Carga(oModel,"MODEL_C9V","C9V_DDDFAL","RA_DDDCELU",aSraCpo,aSRAalt,.T.,3)
	f26Carga(oModel,"MODEL_C9V","C9V_FONALT","RA_NUMCELU",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_EMAILP","RA_EMAIL",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_C9V","C9V_EMAILA","RA_EMAIL2",aSraCpo,aSRAalt)

	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fG26Hor   ³ Autor ³ Glaucia Messina       ³ Data ³ 30/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carga Horario Contratual                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³fG26Hor(oExp1 )                               		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	oExp1: Modelo MVC que tera carga de estagiario 	    	  ³±±
±±³          ³ 	aExp2: array de campos disponiveis SRA                    ³±±
±±³          ³ 	aExp3: array de campos alterados  SRA                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fGP26Hor(oModel, aSraCpo, aSRAalt, cOrigem)
	Local aArea		:= GetArea()
	Local nPosTurno:= 0
	Local cCmp		:= ''
	Local cCmp1		:= ''
	Local cCmp2		:= ''
	Local aTurno	:= {}
	Local nI		:= 0

	DEFAULT aSraCpo := {}
	DEFAULT aSRAalt := {}
	DEFAULT cOrigem := "GPEA010"

	If cOrigem == "GPEA010"
		f26Carga(oModel,"MODEL_CUP","CUP_QTDHJS","RA_HRSEMAN",aSraCpo,aSRAalt,,,.T.)
		cCmp  := fGM26Cpo("RA_TPJORNA",aSraCpo,aSRAalt)
		cCmp1 := fGM26Cpo("RA_TNOTRAB",aSraCpo,aSRAalt)
		cCmp2 := fGM26Cpo("RA_REGRA",aSraCpo,aSRAalt)
	ElseIf cOrigem=="GPEA927"
		oModel:LoadValue( "MODEL_CUP", "CUP_QTDHJS" , ("SRA")->RA_HRSEMAN )
		cCmp  := ("SRA")->RA_TPJORNA
		cCmp1 := ("SRA")->RA_TNOTRAB
		cCmp2 := ("SRA")->RA_REGRA
	EndIf

	aTurno := fGM26Tur(cCmp1, cCmp2)

	If cCmp == "1" .AND. Len(aTurno) > 0
		For nI := 1 To oModel:GetModel("MODEL_CRQ"):Length()
			oModel:GetModel("MODEL_CRQ"):GoLine(nI)
			oModel:GetModel("MODEL_CRQ"):DeleteLine()
		Next nI

		nPosTurno := aScan(aTurno,{|x| x[1] == FWxFilial("SR6",FWCodFil()) .AND. ;
			x[2] == cCmp1 .AND. ;
			x[3] == cCmp2 })

		If nPosTurno > 0
			For nI := 4 to len(aTurno[nPosTurno])
				oModel:GetModel( "MODEL_CRQ" ):lValid:= .T.
				oModel:GetModel( "MODEL_CRQ" ):AddLine()
				oModel:LoadValue( "MODEL_CRQ", "CRQ_CODDIA" , aTurno[nPosTurno][nI,2] )
				oModel:LoadValue( "MODEL_CRQ", "CRQ_CODHOR" , FGetIdInt( "codHorContratual", "",aTurno[nPosTurno][nI,1],"",.F.  ))
			Next nI
		EndIf
	EndIf
	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fIncCont  ³ Autor ³ Glaucia Messina       ³ Data ³ 30/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Inclusao de Carga Contratual do trabalhador                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fIncCont (oExp1,aExp2, aExp3,cExp4 )            		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	oExp1: Modelo MVC que tera carga de estagiario 	    	  ³±±
±±³          ³ 	aExp2: array de campos disponiveis SRA                    ³±±
±±³          ³ 	aExp3: array de campos alterados  SRA                     ³±±
±±³          ³ 	cExp4: Categoria eSocial do TRab                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fIncCont(oModel,aSraCpo,aSRAalt, cCateg)
	Local aArea			:= GetArea()
	Local nPosCmp	:= 0
	Local cCmp		:= ''
	Local cCmp1		:= ''
	Local cCmp2		:= ''
	Local cCC		:= ""
	Local nTpRegTrab	:= 0
	Local aSind		:= {}
	Local aCC		:= {}
	Local cTpInscr	:= ""
	Local cInscr	:= ""
	Local aEstb		:= {}
	Local aPagoFixo	:= {{'H','1'},{'D','2'},{'S','3'},{'M','5'},{'T','6'}}

	STATIC aTpRegTrab	:= {{'31','2'},{'30','3'}}

	aEstb	:= fGM23SM0()

	f26Carga(oModel,"MODEL_CUP","CUP_DTADMI","RA_ADMISSA",aSraCpo,aSRAalt,,,.T.)
	oModel:LoadValue( "MODEL_CUP","CUP_TPADMI","1")
	oModel:LoadValue( "MODEL_CUP","CUP_INDADM","1")

	cCmp := fGM26Cpo("RA_TIPOADM",aSraCpo,aSRAalt)
	oModel:LoadValue( "MODEL_CUP","CUP_INDPRE",	IIf(cCmp $ "1A|2A|3A|9A","1","2"))


	cCmp := fGM26Cpo("RA_VIEMRAI",aSraCpo,aSRAalt)
	nTpRegTrab := aScan(aTpRegTrab,{|x| Alltrim(x[1]) == cCmp})
	If nTpRegTrab > 0
		oModel:LoadValue( "MODEL_CUP","CUP_TPREGT",aTpRegTrab[nTpRegTrab,2])
	Else
		oModel:LoadValue( "MODEL_CUP","CUP_TPREGT",IIf(cCmp # '30|31|35','1',""))
	Endif

	f26Carga(oModel,"MODEL_CUP","CUP_TPREGP","RA_TPPREVI",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_CUP","CUP_TPREGJ","RA_TPJORNA",aSraCpo,aSRAalt)
	oModel:LoadValue( "MODEL_CUP","CUP_NATATV",Iif(cCmp $ ('20|25|70|75'),'2','1'))
	oModel:LoadValue( "MODEL_CUP","CUP_CODCAT",FGetIdInt("codCateg","",cCateg,"",.F.))

	//FUNCAO - CBO
	cCmp := fGM26Cpo("RA_CODFUNC",aSraCpo,aSRAalt)
	If !EMPTY(cCmp)
		aFuncao := fGM26Fun(cCmp)
		If Len(aFuncao) > 0
			oModel:LoadValue( "MODEL_CUP","CUP_CODCBO",FGetIdInt("codCBO","",aFuncao[2],"",.F.)) 		//Carga CBO
			oModel:LoadValue( "MODEL_CUP","CUP_CODFUN",FGetIdInt("codFuncao","",aFuncao[1],"",.F.))		//Carga Funcao
		EndIf
	EndIf

	//CARGO
	cCmp := fGM26Cpo("RA_CARGO",aSraCpo,aSRAalt)
	cCC := fGM26Cpo("RA_CC",aSraCpo,aSRAalt)
	If !Empty(cCmp) .AND. !(EMPTY(cCC))
		cCmp1	:= fGM26Crg(cCmp , cCC)
		If cCmp1 <> ""
			oModel:LoadValue( "MODEL_CUP","CUP_CODCGO",FGetIdInt("codCargo","",cCmp1,"",.F.))
		EndIf
	EndIf

	cCmp := fGM26Cpo("RA_SINDICA",aSraCpo,aSRAalt)
	aSind := fGM26Sind(cCmp)
	If !EMPTY(cCmp) .AND. LEN(aSind) > 0
		oModel:LoadValue("MODEL_CUP","CUP_DATAB",aSind[2])	//MES DATABASE Sindicato
		oModel:LoadValue("MODEL_CUP","CUP_CNPJSD",aSind[1])	//FILIACAO SINDICAL
	EndIf

	//REMUNERACAO
	f26Carga(oModel,"MODEL_CUP","CUP_VLSLFX","RA_SALARIO",aSraCpo,aSRAalt,,,.T.)

	cCmp := fGM26Cpo("RA_CATFUNC",aSraCpo,aSRAalt)
	nPosCmp := aScan(aPagoFixo,{|x| Alltrim(x[1]) == cCmp})

	If nPosCmp <> 0
		oModel:LoadValue( "MODEL_CUP","CUP_UNSLFX",aPagoFixo[nPosCmp,2])
	Endif

	//DURACAO
	f26Carga(oModel,"MODEL_CUP","CUP_TPCONT","RA_TPCONTR",aSraCpo,aSRAalt)
	f26Carga(oModel,"MODEL_CUP","CUP_DTTERM","RA_DTFIMCT",aSraCpo,aSRAalt,,,.T.)

	//LOCAL DE TRABALHO
	cTpInscr	:= ""
	cInscr		:= ""
	If !EMPTY(cCC)
		aCC := fGM26CTT(cCC)
		If LEN(aCC) > 0
			oModel:LoadValue( "MODEL_CUP","CUP_CODLOT",FGetIdInt("codLotacao","",aCC[1],"",.F.))
			If aCC[4] $ '|02|03|04|05|06|08|09|21|22|23|'
				cTpInscr	:= aCC[2]
				cInscr		:= aCC[3]
			EndIf
		EndIf
	EndIf

	nPosCmp := 0
	If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
		nPosCmp 	:= aScan(aEstb, {|x| x[1] == ALLTRIM(FWCodFil())})
		If nPosCmp > 0
			cTpInscr	:= aEstb[nPosCmp,3]
			cInscr		:= aEstb[nPosCmp,2]
		EndIf
	EndIf

	oModel:LoadValue( "MODEL_CUP","CUP_TPINSC",cTpInscr)
	oModel:LoadValue( "MODEL_CUP","CUP_NRINSC",cInscr)

	//HORARIO CONTRATUAL
	fGP26Hor(oModel,aSraCpo,aSRAalt)

	//ALVARA JUDICIAL
	cCmp  := fGM26Cpo("RA_NJUD14",aSraCpo,aSRAalt)
	If !EMPTY(cCmp)
		oModel:LoadValue( "MODEL_CUP","CUP_ALVJUD",FGetIdInt("tpProcesso","nrProcJud","J",cCmp))
	EndIf

	//FGTS
	//Por ser Ounicamo camo data a fazer este controle, realizado os valids aqui
	nPosCmp	:= aScan(aSraCpo, { |x| x[ 2 ] == "RA_OPCAO" } )
	If nPosCmp > 0
		dOpcao  := 	aSRAalt[1,nPosCmp]
		oModel:LoadValue( "MODEL_CUP","CUP_DTFGTS",dOpcao)

		//Optante pelo FGTS
		If 	dOpcao >= STOD('04/10/1988')
			nOptante:= '1'
		Else
			cCmp  := fGM26Cpo("RA_ALTOPC",aSraCpo,aSRAalt)
			nOptante := IIf(cCmp=='S','1','2')
		EndIf
		oModel:LoadValue( "MODEL_CUP","CUP_FGTSOP",nOptante)
	EndIf

	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fIncVinc  ³ Autor ³ Glaucia Messina       ³ Data ³ 30/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carga Admissao trabalhador com vinculo - S-2200/S-2100      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fCrgVinc (oExp1,cExp2, cExp3 )                  		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	cExp1: Filial de integracao com o TAF                     ³±±
±±³          ³ 	cExp2: CPF do trabalhador                                 ³±±
±±³          ³ 	cExp3: Matricula                                          ³±±
±±³          ³ 	cExp4: Tipo de Admissao                                   ³±±
±±³          ³ 	aExp5: Array com os campos SRA                            ³±±
±±³          ³ 	aExp6: Array com os campos alterados SRA                  ³±±
±±³          ³ 	cExp7: Categoria - RA_CATEFD                              ³±±
±±³          ³ 	cExp8: Origem da chamada de integracao TAF                ³±±
±±³          ³ 	cExp9: Operacao da rotina de Origem                       ³±±
±±³          ³ 	cExp10: Evento de carga que sera gerado no TAF            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fIncVinc(cFilEnv, cCpf, cMatric, cTipoAdm,aSraCpo,aSRAalt, cCateg, cOrigem, nOperx, cEvto)
	Local aArea			:= GetArea()
	Local aIncons	:= {}
	Local nIndex   := 4	//C9V_FILIAL+C9V_CPF+C9V_NOMEVE+C9V_ATIVO
	Local oModel
	Local nOpc		:= 3
	Local aChave	:= {}
	Local lCarga 	:= .F.
	Local cRotTAF 	:= ""

	aAdd( aChave, {"C", "C9V_CPF"   , cCPF, .T. } )
	aAdd( aChave, {"C", "C9V_NOMEVE" ,cEvto  , .T. } )

	cRotTAF := IIf(cEvto == "S2200","TAFA278","TAFA256")

	Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao para validar se a operacao desejada pode ser realizada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FTafVldOpe( "C9V", nIndex, @nOpc, cFilEnv , @aIncons, aChave, @oModel, cRotTAF ,"",,.F.,, FWCodFil()+cMatric)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando se tratar de uma Exclusao direta apenas preciso realizar ³
		//³o Commit(), nao eh necessaria nenhuma manutencao nas informacoes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc <> 5 .AND. nOperx <> 5

				If nOpc == 4 .AND. cOrigem <> 'GPEA010'
					If cOrigem == 'GPEA020' 		//DEPENDENTES - SRB
						fG26Dep(oModel, cMatric)
					ElseIf cOrigem == 'GPEA926'	//VINCULOS - RFZ
						fG26Vinc(oModel, cMatric, cTipoAdm)
					ElseIf cOrigem == 'GPEA927'	//TRABALHO TEMPORARIO
						fG26Temp(oModel, cMatric)
					EndIf
				EndIf

			//Carga provinda da tabela SRA
				If (cOrigem == 'GPEA010')
					If nOpc == 3
						oModel:LoadValue( "MODEL_C9V","C9V_CPF"	,cCPF)
						oModel:LoadValue( "MODEL_C9V", "C9V_NOMEVE", cEvto )
						oModel:LoadValue( "MODEL_CUP","CUP_MATRIC", FWCodFil() + cMatric )
					EndIf

				//Inclusao Dados Cadastrais
					fIncCad(oModel,aSraCpo,aSRAalt)

				//Inclusao Dados Contratuais
					fIncCont(oModel,aSraCpo,aSRAalt, cCateg)
				EndIf

			EndIf

			FWFormCommit( oModel )
			oModel:DeActivate()
			lCarga := .T.
		EndIf
	End Transaction

	If lCarga .AND. !empty(cMsgSRA)
		cMsg	:= OemtoAnsi(STR0020) + CRLF				//"Existem campos indisponíveis neste módulo para integração com o módulo TAF."
		If cModulo	<> "GPE"
			cMsg	+= OemtoAnsi(STR0021) + CRLF			//"Utilize o módulo SIGAGPE, para carga destes campos."
		Else
			cMsg	+= OemtoAnsi(STR0022) +", " + CRLF		//"Entre em contato com o Administador do Sitema"
			cMsg	+= OemtoAnsi(STR0023) + CRLF			//"para habilitar estes campos, e realizar a carga destes campos."
			cMsg	+= OemtoAnsi(STR0024) + CRLF			//"via esta rotina."
		EndIf
		cMsg	+= OemToAnsi(STR0025) + CRLF				//"antes que este registro seja enviado ao RET."
		cMsg	+= OemtoAnsi(STR0026) + CRLF				//"Os campos indisponíveis são:"
		cMsg	+= cMsgSRA
		Help("",1,OemtoAnsi(STR0027),,cMsg,1,0)				//"Campo Indisponível"
	EndIf

	RestArea(aArea)
Return 	lCarga

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fPreCad   ³ Autor ³ Glaucia Messina       ³ Data ³ 30/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Inclusao de Carga cadastral do trabalhador                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fPreCad(oModel, lTSV)                        		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	oExp1: Modelo MVC                           	    	  ³±±
±±³          ³ 	lExp2: Se trabalhador eh TSV                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fPreCad(oModel, lTSV)
	Local aArea			:= GetArea()
	Local nPosCmp	:= 0
	Local cCmp		:= ''
	Local cCmp1		:= ''
	Local cCmp2		:= ''
	Local cNomTra	:= ''
	Local cPais		:= ''
	Local nPosEC 		:= 0
	Local nPosInstr		:= 0
	Local aAreaSRA := ("SRA")->( GetArea() )

	DEFAULT lTSV		:= .F.

	STATIC aEstCivi		:= GpeEstCivi("1")
	STATIC aInstrucao	:= {{'10','01'},{'20','02'},{'25','03'},{'30','04'},{'35','05'},{'40','06'},{'45','07'},;
		{'50','08'},{'55','09'},{'65','11'},{'75','12'},{'85','10'},{'95','12'}}

//TRABALHADOR
	oModel:LoadValue( "MODEL_C9V","C9V_NIS"		,ALLTRIM(("SRA")->RA_PIS))
	cNomTrab := IIF(!EMPTY(ALLTRIM(("SRA")->RA_NOMECMP)),SUBSTR(("SRA")->RA_NOMECMP,1,60),ALLTRIM(("SRA")->RA_NOME) )
	oModel:LoadValue( "MODEL_C9V","C9V_NOME"	, cNomTrab)
	oModel:LoadValue( "MODEL_C9V","C9V_SEXO"	,("SRA")->RA_SEXO)
	oModel:LoadValue( "MODEL_C9V","C9V_RCCOR"	,("SRA")->RA_RACACOR)

	nPosEC := aScan(aEstCivi,{|x| Alltrim(x[1]) == ("SRA")->RA_ESTCIVI})
	If nPosEC > 0
		oModel:LoadValue( "MODEL_C9V","C9V_ESTCIV", aEstCivi[nPosEC,2])
	EndIf

	nPosInstr := aScan(aInstrucao,{|x| Alltrim(x[1]) == ("SRA")->RA_GRINRAI})
	If nPosInstr > 0
		oModel:LoadValue( "MODEL_C9V","C9V_GRINST",FGetIdInt("grauInstrucao","",aInstrucao[nPosInstr,2],"",.F.))
	EndIf

	//NASCIMENTO
	oModel:LoadValue( "MODEL_C9V","C9V_DTNASC",	("SRA")->RA_NASC )

	cPais := FGetIdInt( "paisNascto","",fM23Pais(ALLTRIM(("SRA")->RA_CPAISOR)))

	oModel:LoadValue( "MODEL_C9V","C9V_CODPAI",cPais,"",.F.)

	If ("SRA")->RA_CPAISOR=="01058" .AND. ("SRA")->RA_NATURAL != "EX"
		oModel:LoadValue( "MODEL_C9V","C9V_CODUF",FGetIdInt( "uf","",("SRA")->RA_NATURAL,"",.F.))
		oModel:LoadValue( "MODEL_C9V","C9V_CODMUN",FGetIdInt("uf","codMunicipio",("SRA")->RA_NATURAL,ALLTRIM(("SRA")->RA_CODMUNN),.F.))
	EndIf

	oModel:LoadValue( "MODEL_C9V","C9V_PAINAC",FGetIdInt("paisNacionalidade","",fM23Pais(ALLTRIM(("SRA")->RA_NACIONC)),"",.F.))

	oModel:LoadValue( "MODEL_C9V","C9V_NOMMAE",("SRA")->RA_MAE)
	oModel:LoadValue( "MODEL_C9V","C9V_NOMPAI",("SRA")->RA_PAI)

	//DOCUMENTOS
	//CTPS
	oModel:LoadValue( "MODEL_C9V","C9V_NRCTPS",("SRA")->RA_NUMCP)
	oModel:LoadValue( "MODEL_C9V","C9V_SERCTP",("SRA")->RA_SERCP)
	oModel:LoadValue( "MODEL_C9V","C9V_UFCTPS",FGetIdInt("ufCtps","",("SRA")->RA_UFCP,"",.F.))

	//RIC
	oModel:LoadValue( "MODEL_C9V","C9V_NRRIC",("SRA")->RA_NUMRIC)
	oModel:LoadValue( "MODEL_C9V","C9V_OREMRI",("SRA")->RA_EMISRIC)
	oModel:LoadValue( "MODEL_C9V","C9V_DTEXRI",	("SRA")->RA_DEXPRIC)

	//RG
	If LEN(ALLTRIM(("SRA")->RA_RG)) <= 14
		oModel:LoadValue( "MODEL_C9V","C9V_NRRG",ALLTRIM(("SRA")->RA_RG))
	EndIf
	oModel:LoadValue( "MODEL_C9V","C9V_OREMRG",("SRA")->RA_RGEXP)
	oModel:LoadValue( "MODEL_C9V","C9V_DTEMRG",("SRA")->RA_DTRGEXP)

	//RNE
	oModel:LoadValue( "MODEL_C9V","C9V_NRRNE",("SRA")->RA_RNE)
	oModel:LoadValue( "MODEL_C9V","C9V_OREMRN",("SRA")->RA_RNEORG)
	oModel:LoadValue( "MODEL_C9V","C9V_DTEMRN",("SRA")->RA_RNEDEXP)

	//Orgao de Classe
	oModel:LoadValue( "MODEL_C9V","C9V_NUMOC",("SRA")->RA_CODIGO)
	oModel:LoadValue( "MODEL_C9V","C9V_OREMOC",("SRA")->RA_OCEMIS)
	oModel:LoadValue( "MODEL_C9V","C9V_DTEXOC",("SRA")->RA_OCDTEXP)
	oModel:LoadValue( "MODEL_C9V","C9V_DTVLOC",("SRA")->RA_OCDTVAL)

	//CNH
	oModel:LoadValue( "MODEL_C9V","C9V_NRCNH",("SRA")->RA_HABILIT)
	oModel:LoadValue( "MODEL_C9V","C9V_OREMCN",("SRA")->RA_CNHORG)
	oModel:LoadValue( "MODEL_C9V","C9V_DTEXCN",("SRA")->RA_DTEMCNH)
	oModel:LoadValue( "MODEL_C9V","C9V_DTVLCN",("SRA")->RA_DTVCCNH)

	//Endereco
	If EMPTY(("SRA")->RA_RESEXT) .OR. ("SRA")->RA_RESEXT=='2'
		//Residente no Brasil
		oModel:LoadValue( "MODEL_C9V","C9V_PAIS",FGetIdInt( "paisResidencia","","105","",.F.))
		oModel:LoadValue( "MODEL_C9V","C9V_TPLOGR",FGetIdInt("tpLogradouro","",("SRA")->RA_LOGRTP,"",.T.))
		oModel:LoadValue( "MODEL_C9V","C9V_LOGRAD",("SRA")->RA_LOGRDSC)
		oModel:LoadValue( "MODEL_C9V","C9V_NRLOG",("SRA")->RA_LOGRNUM)
		oModel:LoadValue( "MODEL_C9V","C9V_COMLOG",("SRA")->RA_COMPLEM)
		oModel:LoadValue( "MODEL_C9V","C9V_BAIRRO",("SRA")->RA_BAIRRO)
		oModel:LoadValue( "MODEL_C9V","C9V_CEP",("SRA")->RA_CEP)
		oModel:LoadValue( "MODEL_C9V","C9V_UF",FGetIdInt("uf", "", ("SRA")->RA_ESTADO))
		oModel:LoadValue( "MODEL_C9V","C9V_MUN",FGetIdInt("uf", "codMunicipio",("SRA")->RA_ESTADO, AllTrim(("SRA")->RA_CODMUN)))
	Else
		//Residente no exterior
		oModel:LoadValue( "MODEL_C9V","C9V_PAIS",FGetIdInt( "paisResidencia","",fM23Pais(ALLTRIM(("SRA")->RA_PAISEXT)),"",.F.))
		oModel:LoadValue( "MODEL_C9V","C9V_LOGRAD",("SRA")->RA_LOGRDSC)
		oModel:LoadValue( "MODEL_C9V","C9V_NRLOG",("SRA")->RA_LOGRNUM)
		oModel:LoadValue( "MODEL_C9V","C9V_COMLOG",("SRA")->RA_COMPLEM)
		oModel:LoadValue( "MODEL_C9V","C9V_BAIRRO",("SRA")->RA_BAIRRO)
		oModel:LoadValue( "MODEL_C9V","C9V_NOMCID",("SRA")->RA_MUNICIP)
		oModel:LoadValue( "MODEL_C9V","C9V_CEP",("SRA")->RA_CPOSTAL)
	EndIf

	//Trabalhador estrangeiro
	oModel:LoadValue( "MODEL_C9V","C9V_DTCHEG",("SRA")->RA_DATCHEG)
	oModel:LoadValue( "MODEL_C9V","C9V_DTNATU",("SRA")->RA_DATNATU)
	oModel:LoadValue( "MODEL_C9V","C9V_CASBRA",("SRA")->RA_CASADBR)
	oModel:LoadValue( "MODEL_C9V","C9V_FILBRA",("SRA")->RA_FILHOBR)

	//Info Deficiencia

	oModel:LoadValue( "MODEL_C9V","C9V_OBSDEF",("SRA")->RA_OBSDEFI)
	oModel:LoadValue( "MODEL_C9V","C9V_DEFFIS",IIf(AT("1",("SRA")->RA_PORTDEF) > 0 , "1","2"))
	oModel:LoadValue( "MODEL_C9V","C9V_DEFAUD",IIf(AT("2",("SRA")->RA_PORTDEF) > 0 , "1","2"))
	oModel:LoadValue( "MODEL_C9V","C9V_DEFVIS",IIf(AT("3",("SRA")->RA_PORTDEF) > 0 , "1","2"))
	oModel:LoadValue( "MODEL_C9V","C9V_DEFMEN",IIf(AT("4",("SRA")->RA_PORTDEF) > 0 , "1","2"))
	oModel:LoadValue( "MODEL_C9V","C9V_DEFINT",IIf(AT("5",("SRA")->RA_PORTDEF) > 0 , "1","2"))
	oModel:LoadValue( "MODEL_C9V","C9V_REABIL",IIf(AT("6",("SRA")->RA_PORTDEF) > 0 , "1","2"))

	//APOSENTADORIA
	If !lTSV
		oModel:LoadValue( "MODEL_C9V","C9V_APOSEN",IIf(("SRA")->RA_EAPOSEN=='1','1','2'))
	EndIf

	//CONTATO
	If LEN(ALLTRIM(("SRA")->RA_DDDFONE)) < 4
		oModel:LoadValue( "MODEL_C9V","C9V_DDDFPR",ALLTRIM(("SRA")->RA_DDDFONE))
	EndIf

	oModel:LoadValue( "MODEL_C9V","C9V_FONPRC",SUBSTR(("SRA")->RA_TELEFON,1,12))

	If LEN(ALLTRIM(("SRA")->RA_DDDCELU)) < 4
		oModel:LoadValue( "MODEL_C9V","C9V_DDDFAL",ALLTRIM(("SRA")->RA_DDDCELU))
	EndIf

	oModel:LoadValue( "MODEL_C9V","C9V_FONALT",("SRA")->RA_NUMCELU)

	oModel:LoadValue( "MODEL_C9V","C9V_EMAILP",("SRA")->RA_EMAIL)
	oModel:LoadValue( "MODEL_C9V","C9V_EMAILA",("SRA")->RA_EMAIL2)

	RestArea( aAreaSRA )
	RestArea(aArea)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fAltVinc  ³ Autor ³ Glaucia Messina       ³ Data ³ 30/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Alteracao Cadastral trabalhador com e sem vinculo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fGP27s2620(aRotAuto,lGp010Auto,cFilEnv,cIdFunc )		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	aExp1: Array com os campos alterados SRA        	 	  ³±±
±±³          ³ 	aExp2: Array com os campos SRA                  	 	  ³±±
±±³          ³ 	aExp3: Array com os campos antes alteracaos SRA    	 	  ³±±
±±³          ³ 	cExp4: CPF do trabalhador                                 ³±±
±±³          ³ 	cExp5: Matricula                                          ³±±
±±³          ³ 	cExp6: Filial de integracao com o TAF                     ³±±
±±³          ³ 	cExp7: Categoria - RA_CATEFD                              ³±±
±±³          ³ 	cExp9: Operacao da rotina de Origem                       ³±±
±±³          ³ 	cExp10: Origem da chamada de integracao TAF               ³±±
±±³          ³ 	aExp11: Array com o retorno de registros com mesmo CPF taf³±±
±±³          ³ 	lExp12: Se trabalhador e TSV                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEA010                              					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Function fAltVinc(aSraAlt,aSraCpo,aSRAori,cCPF,cMatric,cFilEnv,cCateg, nOperx,cOrigem, aTrab , lTSV)
	Local aArea:= GetArea()
	Local nOpc			:= 3
	Local aIncons		:= {}
	Local aChave		:= {}
	Local oModel
	Local lCarga 		:= .F.

	aChave := {}
	aAdd( aChave, {"C", "C9V_CPF"   ,cCPF, .T. } )
	aAdd( aChave, {"C", "C9V_DTALT" , Dtos(dDatabase), .T. } )
	aAdd( aChave, {"C", "C9V_NOMEVE" ,"S2220", .T. } )

	Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao para validar se a operacao desejada pode ser realizada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FTafVldOpe( "C9V", 7, @nOpc, cFilEnv, @aIncons, aChave, @oModel, "TAFA275","",,.F.,, )
			If nOpc == 3 .OR. nOpc == 4
			//Caso se trate de uma inclusão gravo o evento na tabela C9V
				If nOpc == 3
					oModel:LoadValue("MODEL_C9V", "C9V_NOMEVE", "S2220" )
					oModel:LoadValue("MODEL_C9V","C9V_CPF",cCPF)
					oModel:LoadValue("MODEL_C9V","C9V_DTALT",dDatabase)
				EndIf

				If cOrigem = "GPEA010"
					fIncCad(oModel,aSraCpo,aSRAalt, lTSV)
				EndIf

				If cOrigem = "GPEA020"
					If nOpc == 3
					//Se S2220 partiu do cadastro de dependentes,
					//temos que copiar a carga cadastral
						fPreCad(oModel, lTSV)
					EndIf
				EndIf

			//Carga Dependentes
				fG26Dep(oModel, cMatric)
			EndIf

			FWFormCommit( oModel )
			oModel:DeActivate()
			lCarga := .T.
		EndIf
	End Transaction

	RestArea(aArea)
Return	lCarga

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fAltVinc  ³ Autor ³ Glaucia Messina       ³ Data ³ 30/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Alteracao Cadastral trabalhador com e sem vinculo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fGP27s2620(aRotAuto,lGp010Auto,cFilEnv,cIdFunc )		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	aExp1: Array com os campos alterados SRA        	 	  ³±±
±±³          ³ 	aExp2: Array com os campos SRA                  	 	  ³±±
±±³          ³ 	aExp3: Array com os campos antes alteracaos SRA    	 	  ³±±
±±³          ³ 	cExp4: CPF do trabalhador                                 ³±±
±±³          ³ 	cExp5: Matricula                                          ³±±
±±³          ³ 	cExp6: Filial de integracao com o TAF                     ³±±
±±³          ³ 	cExp7: Categoria - RA_CATEFD                              ³±±
±±³          ³ 	cExp9: Operacao da rotina de Origem                       ³±±
±±³          ³ 	cExp10: Origem da chamada de integracao TAF               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEA010                              					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Static Function fInc2680(cCPF,cMatric,cFilEnv,cCateg, nOperx,cOrigem, dDeslig)
	Local aArea			:= GetArea()
	Local lCarga 		:= .F.
	Local nOpc			:= 3
	Local aIncons		:= {}
	Local aChave		:= {}
	Local oModel
	Local cMsg			:= ""

	aTrab := fGM26Trb(cCPF, "S2600",cCateg,FwCodFil()+cMatric, cFilEnv, .T.)

	If aTrab[4] == 'ALT'

	//Chave do Registro
		aAdd( aChave, { "C", "C9V_CPF" , cCPF, .T. } )
		aAdd( aChave, { "C", "C9V_NOMEVE", "S2680" , .T. } )

	//Funcao para validar se a operacao desejada pode ser realizada
		If FTafVldOpe( "C9V", 4, @nOpc, cFilEnv, @aIncons, aChave, @oModel, "TAFA280", "", 2)

			If nOpc == 3 .OR. nOpc == 4
				If nOpc == 3
					oModel:LoadValue("MODEL_C9V", "C9V_NOMEVE", "S2680" )
					oModel:LoadValue("MODEL_C9V","C9V_CPF",cCPF)
					oModel:LoadValue("MODEL_C9V","C9V_DTALT",dDatabase)

				//Pre-Carga Cadastral
					fPreCad(oModel, .T.)
				EndIf

				If aTrab[3] $ '201|202|203'
					oModel:LoadValue("MODEL_CUU","CUU_DTERAV",dDeslig)
				ElseIf aTrab[3] $ '|701|702|703|711|712|713|731|732|733|734|735|736|741|'
					oModel:LoadValue("MODEL_CUU","CUU_DTERCI",dDeslig)
				ElseIf aTrab[3] $ '305'
					oModel:LoadValue("MODEL_CUU","CUU_DTTESP",dDeslig)
				ElseIf aTrab[3] $ '401'
					oModel:LoadValue("MODEL_CUU","CUU_DTTEDS",dDeslig)
				ElseIf aTrab[3] $ '901'
					oModel:LoadValue("MODEL_CUU","CUU_DTERES",dDeslig)
				EndIf
			EndIf
			FWFormCommit( oModel )
			oModel:DeActivate()
			lCarga := .T.
		EndIf
	EndIf

	If !lCarga .AND. aTrab[4] == "TERMINO"
		cMsg := ""
		cMsg := OemtoAnsi(STR0029) + "." + CRLF									//"A integração com o módulo TAF não foi realizada."
		cMsg += OemtoAnsi(STR0032)+"." + CRLF									//"Problemas na carga evento S-2680"
		cMsg += OemtoAnsi(STR0030)												//"Verifique informaçoes deste trabalhador no módulo TAF."
		Help("",1,OemtoAnsi(STR0028),,cMsg,1,0)									//"Carga TAF não realizada"
	ElseIf len(aTrab) > 0 .AND. !(Empty(aTrab[2]))
		Help("",1,OemtoAnsi(STR0028),,aTrab[2],1,0)	//"Carga TAF não realizada"
	EndIf

	RestArea(aArea)
Return	lCarga


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fPre2240  ³ Autor ³ Glaucia Messina       ³ Data ³ 06/08/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Inclusao de Carga contratual do trabalhador                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fPre2240(oModel, lTSV)                        		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	oExp1: Modelo MVC de carga                     	    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                                 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Static Function fPre2240(oModel, cOrigem)
	Local aArea		:= GetArea()
	Local aAreaSRA := ("SRA")->( GetArea() )
	Local nPosCmp	:= 0
	Local cCmp		:= ''
	Local cCmp1		:= ''
	Local cCmp2		:= ''
	Local cCC		:= ""
	Local nTpRegTrab	:= 0
	Local aSind		:= {}
	Local aCC		:= {}
	Local cTpInscr	:= ""
	Local cInscr	:= ""
	Local aEstb		:= {}
	Local aPagoFixo	:= {{'H','1'},{'D','2'},{'S','3'},{'M','5'},{'T','6'}}

	STATIC aTpRegTrab	:= {{'31','2'},{'30','3'}}

	aEstb	:= fGM23SM0()

	cCmp := ALLTRIM(("SRA")->RA_VIEMRAI)
	nTpRegTrab := aScan(aTpRegTrab,{|x| Alltrim(x[1]) == cCmp})
	If nTpRegTrab > 0
		oModel:LoadValue( "MODEL_CUP","CUP_TPREGT",aTpRegTrab[nTpRegTrab,2])
	Else
		oModel:LoadValue( "MODEL_CUP","CUP_TPREGT",IIf(cCmp # '30|31|35','1',""))
	Endif

	oModel:LoadValue( "MODEL_CUP","CUP_TPREGP",("SRA")->RA_TPPREVI )

	oModel:LoadValue( "MODEL_CUP","CUP_TPREGJ", ("SRA")->RA_TPJORNA)
	oModel:LoadValue( "MODEL_CUP","CUP_NATATV",Iif(cCmp $ ('20|25|70|75'),'2','1'))
	oModel:LoadValue( "MODEL_CUP","CUP_CODCAT",FGetIdInt("codCateg","",("SRA")->RA_CATEFD,"",.F.))

	//FUNCAO - CBO
	cCmp := ("SRA")->RA_CODFUNC
	If !EMPTY(cCmp)
		aFuncao := fGM26Fun(cCmp)
		If Len(aFuncao) > 0
			oModel:LoadValue( "MODEL_CUP","CUP_CODCBO",FGetIdInt("codCBO","",aFuncao[2],"",.F.)) 		//Carga CBO
			oModel:LoadValue( "MODEL_CUP","CUP_CODFUN",FGetIdInt("codFuncao","",aFuncao[1],"",.F.))		//Carga Funcao
		EndIf
	EndIf

	//CARGO
	cCmp:= ("SRA")->RA_CARGO
	cCC	:= ("SRA")->RA_CC
	If !Empty(cCmp) .AND. !(EMPTY(cCC))
		cCmp1	:= fGM26Crg(cCmp , cCC)
		If cCmp1 <> ""
			oModel:LoadValue( "MODEL_CUP","CUP_CODCGO",FGetIdInt("codCargo","",cCmp1,"",.F.))
		EndIf
	EndIf

	cCmp := ("SRA")->RA_SINDICA
	aSind := fGM26Sind(cCmp)
	If !EMPTY(cCmp) .AND. LEN(aSind) > 0
		oModel:LoadValue("MODEL_CUP","CUP_DATAB",aSind[2])	//MES DATABASE Sindicato
		oModel:LoadValue("MODEL_CUP","CUP_CNPJSD",aSind[1])	//FILIACAO SINDICAL
	EndIf

	//REMUNERACAO
	oModel:LoadValue("MODEL_CUP","CUP_VLSLFX",("SRA")->RA_SALARIO)

	cCmp := ("SRA")->RA_CATFUNC
	nPosCmp := aScan(aPagoFixo,{|x| Alltrim(x[1]) == cCmp})

	If nPosCmp <> 0
		oModel:LoadValue( "MODEL_CUP","CUP_UNSLFX",aPagoFixo[nPosCmp,2])
	Endif

	//DURACAO
	oModel:LoadValue("MODEL_CUP","CUP_TPCONT",("SRA")->RA_TPCONTR)
	oModel:LoadValue("MODEL_CUP","CUP_DTTERM",("SRA")->RA_DTFIMCT)

	//LOCAL DE TRABALHO
	cTpInscr	:= ""
	cInscr		:= ""
	If !EMPTY(cCC)
		aCC := fGM26CTT(cCC)
		If LEN(aCC) > 0
			oModel:LoadValue( "MODEL_CUP","CUP_CODLOT",FGetIdInt("codLotacao","",aCC[1],"",.F.))
			If aCC[4] $ '|02|03|04|05|06|08|09|21|22|23|'
				cTpInscr	:= aCC[2]
				cInscr		:= aCC[3]
			EndIf
		EndIf
	EndIf

	nPosCmp := 0
	If EMPTY(cTpInscr) .OR. EMPTY(cInscr)
		nPosCmp 	:= aScan(aEstb, {|x| x[1] == ALLTRIM(FWCodFil())})
		If nPosCmp > 0
			cTpInscr	:= aEstb[nPosCmp,3]
			cInscr		:= aEstb[nPosCmp,2]
		EndIf
	EndIf

	oModel:LoadValue( "MODEL_CUP","CUP_TPINSC",cTpInscr)
	oModel:LoadValue( "MODEL_CUP","CUP_NRINSC",cInscr)

	//HORARIO CONTRATUAL
	fGP26Hor(oModel,,,cOrigem)

	//ALVARA JUDICIAL
	cCmp  := ("SRA")->RA_NJUD14
	If !EMPTY(cCmp)
		oModel:LoadValue( "MODEL_CUP","CUP_ALVJUD",FGetIdInt("tpProcesso","nrProcJud","J",cCmp))
	EndIf

	RestArea( aAreaSRA )
	RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fInc2240  ³ Autor ³ Glaucia Messina       ³ Data ³ 30/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Alteracao Cadastral trabalhador com e sem vinculo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fGP27s2620(aRotAuto,lGp010Auto,cFilEnv,cIdFunc )		 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	aExp1: Array com os campos alterados SRA        	 	  ³±±
±±³          ³ 	aExp2: Array com os campos SRA                  	 	  ³±±
±±³          ³ 	aExp3: Array com os campos antes alteracaos SRA    	 	  ³±±
±±³          ³ 	cExp4: CPF do trabalhador                                 ³±±
±±³          ³ 	cExp5: Matricula                                          ³±±
±±³          ³ 	cExp6: Filial de integracao com o TAF                     ³±±
±±³          ³ 	cExp7: Categoria - RA_CATEFD                              ³±±
±±³          ³ 	cExp9: Operacao da rotina de Origem                       ³±±
±±³          ³ 	cExp10: Origem da chamada de integracao TAF               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPEM026                              					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Static Function fInc2240(aSraAlt,aSraCpo,aSRAori,cCPF,cMatric,cFilEnv,cCateg, nOperx,cOrigem)
	Local aArea:= GetArea()
	Local nOpc			:= 3
	Local aIncons		:= {}
	Local aChave		:= {}
	Local oModel
	Local lCarga 		:= .F.

	aChave := {}
	aAdd( aChave, {"C", "C9V_CPF"   ,cCPF, .T. } )
	aAdd( aChave, {"C", "C9V_DTALT" , Dtos(dDatabase), .T. } )
	aAdd( aChave, {"C", "C9V_NOMEVE" ,"S2240", .T. } )

	Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao para validar se a operacao desejada pode ser realizada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FTafVldOpe( "C9V", 7, @nOpc, cFilEnv, @aIncons, aChave, @oModel,"TAFA276", "",,.F.,, FWCodFil()+cMatric)
			If nOpc == 3 .OR. nOpc == 4
			//Caso se trate de uma inclusão gravo o evento na tabela C9V
				If nOpc == 3
					oModel:LoadValue("MODEL_C9V", "C9V_NOMEVE", "S2240" )
					oModel:LoadValue("MODEL_C9V","C9V_CPF",cCPF)
					oModel:LoadValue("MODEL_C9V","C9V_DTALT",dDatabase)
					oModel:LoadValue( "MODEL_CUP","CUP_MATRIC", FWCodFil() + cMatric )
				EndIf

				If cOrigem = "GPEA010"
				//Dados Contratuais
					fIncCont(oModel,aSraCpo,aSRAalt, cCateg)
				EndIf

				If cOrigem = "GPEA927"
					If nOpc == 3
						fPre2240(oModel, cOrigem)
					EndIf
				EndIf
			//Realizara a carga de trabalhador temporário se existir
			//dados na tabela RBW
				fG26Temp(oModel, cMatric)
			EndIf

			FWFormCommit( oModel )
			oModel:DeActivate()
			lCarga := .T.
		EndIf
	End Transaction

	RestArea(aArea)
Return	lCarga

/*/{Protheus.doc} ValidModf
Checa alteração de campos pertinentes ao eSocial
@type function
@author Eduardo
@since 02/06/2017
@version 1.0
@param oGrid, objeto, (Descrição do parâmetro)
@param nOperation, numérico, (Descrição do parâmetro)
@param cTpEnviar, caracter, (por referência, idica qual será o tipo de envio do xml, com início, com fim ou com ambos)
@param nLinha, numérico, (linha da Grid)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function ValidModf(oGrid, nOperation, cTpEnviar, nLinha, cTrabSVinc, lAdmPubl, cTpInsc, cNrInsc, cVersEnv, lGeraMat)
	Local cFilEnv	 	:= ""
	Local aFilInTaf 	:= {}
	Local aArrayFil 	:= {}
	Local aAreaSR8		:= SR8->( GetArea() )
	Local nI			:= 0
	Local nRecSR8		:= 0
	Local lRet			:= .F.
	Local aCpos 		:= {	"R8_DATAINI"	,;	//01 - R8_DATAINI - Só altera Data Inicial caso ainda não tenha sido enviado ao TAF
								"R8_TPEFD"		,;	//Código do Afastamento eSocial
								"R8_CONTAFA"	,;	//Continuação do Afastamento
								"R8_TIPOAT"		,;	//Tipo de Acidente de Transito
								"R8_OBSAFAS"	,;	//Observação Afastamento
								"R8_CNPJCES"	,;	//CNPJ do Sucessário
								"R8_TPCES"		,;	//Tipo de Ônus Cedente
								"R8_CNPJSIN"	,;	//CNPJ do Sindicato
								"R8_TPSIND"		,;	//Tipo Ônus Sindicato
								"R8_ORIGALT"	,;	//Origem da Alteração
								"R8_TPPROC"		,;	//Tipo de Processo
								"R8_TAFKI"		,;	//Código de integração do início
								"R8_TAFKF"		,;	//Código de integração do fim
								"R8_NRPRCJU"	}	//Número do Processo Judicial
								//O R8_DATAFIM deverá ser checado separadamente, pois se foi alterado juntamente com outros campos deve-se enviar a retificação em 2 xml's
								//"R8_DATAFIM"	}	//18 - R8_DATAFIM - Data de Término (é checada sepadaramente)
								//"R8_DURACAO"	,;	//06 - R8_DURACAO - Quantidade de dias (será checada com a data fim)
	Local cChaveS2230 := ""
	Local cChaveBus   := ""

	Default cTpEnviar := "0"
	Default nLinha 	  := 1
	Default cTrabSVinc:= ""
	Default lAdmPubl  := .F.
	Default cTpInsc   := ""
	Default cNrInsc   := ""
	Default cVersEnv  := ""
	Default lGeraMat  := ( cVersEnv >= "9.0" .And. SRA->(ColumnPos("RA_DESCEP")) > 0 .And. SRA->RA_DESCEP == "1" )

	If nOperation == MODEL_OPERATION_UPDATE

		If cVersEnv < "9.0"
			aAdd(aCpos, "R8_CID")		//Código Internacional da doença
			aAdd(aCpos, "R8_NMMED")		//Nome do emitente
			aAdd(aCpos, "R8_IDEOC")		//Órgão de Classe
			aAdd(aCpos, "R8_CRMMED")	//Inscrição do Emitente
			aAdd(aCpos, "R8_UFCRM")		//Código da UF
		ElseIf SR8->(ColumnPos("R8_DTINIF")) > 0
			aAdd(aCpos, "R8_DTINIF")	//Data Início perAq ferias
			aAdd(aCpos, "R8_DTFMF")		//Data Final perAq ferias
			aAdd(aCpos, "R8_CNPJE")		//CNPJ do orgao publico
			aAdd(aCpos, "R8_REMUN")		//Remuneracao Cargo Efetivo
		EndIf

		nRecSR8 := oGrid:GetDataId(nLinha)
		If nRecSR8 > 0
			SR8->( dbGoTo(nRecSR8) )
		EndIf

		For nI:= 1 to Len(aCpos)
			If oGrid:IsFieldUpdated(aCpos[nI])
				If (nRecSR8 == 0 .Or. (nRecSR8 > 0 .And. &("SR8->"+aCpos[nI]) != oGrid:GetValue(aCpos[nI]))) // Alterou e o conteúdo ficou diferente do conteúdo anteriormente gravado na SR8
					//Alterou algum campo pertinente ao eSocial
					lRet:= .T.
					cTpEnviar := "1" //Gerar o xml com a data de início
					EXIT
				EndIf
			Endif
		Next

		If ( oGrid:IsFieldUpdated("R8_DATAFIM") .And. ( nRecSR8 == 0 .Or. (nRecSR8 > 0 .And. SR8->R8_DATAFIM != oGrid:GetValue("R8_DATAFIM")) ) ) .Or.;
		   ( oGrid:IsFieldUpdated("R8_DURACAO") .And. ( nRecSR8 == 0 .Or. (nRecSR8 > 0 .And. SR8->R8_DURACAO != oGrid:GetValue("R8_DURACAO")) ) )
			If lRet
				//Alterou campos pertinentes e também a data fim do afastamento
				cTpEnviar := "3" //Gerar xml, com a data de início e com a data fim
			Else
				//Somente a data fim foi alterada
				If Empty(oGrid:GetValue("R8_DATAFIM")) .And. !Empty(oGrid:GetValue("R8_TAFKF"))
					cTpEnviar := "4" //Retificar a data fim ou Enviar o S-3000
				Else
					cTpEnviar := "2" //Gerar o xml com a data fim
				EndIf

				If !lMiddleware
					fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
					If (Len(aFilInTaf[1,3]) > 1) .AND. !EMPTY(cFilEnv) //1XN
						cFilAnt := cFilEnv
					EndIf
				EndIf

				If Empty(cFilEnv)
					cFilEnv:= cFilAnt
				EndIf

				If !lMiddleware
					cStat2230 := RetCM6(xFilial("CM6", cFilEnv) + C9V->C9V_ID + DTOS(oGrid:GetValue("R8_DATAINI")), 1)
				Else
					cChaveS2230	:= Iif(!SRA->RA_CATEFD $ cTrabSVinc .Or. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + dToS( SRA->RA_ADMISSA )) + dToS(oGrid:GetValue("R8_DATAINI")) + "I"
					cChaveBus	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2230" + Padr(cChaveS2230, 40, " ")
					cStat2230 	:= "-1"
					GetInfRJE( 2, cChaveBus, @cStat2230, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.)
				EndIf

				//Se o TAFKI e o TAFKF estiverem vazios, realiza o envio do início e fim do afastamento
				IF 	Empty(oGrid:GetValue("R8_TAFKI")) .And. Empty(oGrid:GetValue("R8_TAFKF")) .And. ;
					oGrid:GetValue("R8_DATAINI") >= dDcgIni .And. cStat2230 == "-1"
					cTpEnviar := "3"
				ENDIF

			Endif
			lRet := .T.
		Endif
	EndIf

	RestArea(aAreaSR8)

Return lRet

/*/{Protheus.doc} ValidPrazo
Exibe mensagem com prazo de envio do afastamento
@type function
@author Eduardo
@since 02/06/2017
@version 1.0
@param oGrid, objeto, (Descrição do parâmetro)
@param nOperation, numérico, (Descrição do parâmetro)
/*/
function ValidPrazo(oGrid,nOperation)
	Local cMsg		:= ""
	Local cMes		:= ""
	Local cAno		:= ""
	Local nI, nDias	:= 0
	Local dDcgIni	:= SuperGetMV( "MV_DTCGINI", Nil, CTOD(" / / ") )

	For nI := 1 to oGrid:Length()
		oGrid:GoLine(nI)
		if oGrid:GetValue("R8_TPEFD")$ '01/02/03/04' .And. ( Empty(oGrid:GetValue("R8_INTGTAF")) .Or. Empty(oGrid:GetValue("R8_TAFKI")) .Or. Empty(oGrid:GetValue("R8_TAFKF")) )
			nDias := If( Empty(oGrid:GetValue("R8_CONTAFA")), oGrid:GetValue("R8_DURACAO"), nDias + oGrid:GetValue("R8_DURACAO") )
			If !Empty(oGrid:GetValue("R8_DATAFIM"))
				cMes := StrZero(MONTH(oGrid:GetValue("R8_DATAFIM"))+1,2)
				cAno := CValToChar(YEAR(oGrid:GetValue("R8_DATAFIM")))
			EndIf

			If (oGrid:GetValue("R8_DURACAO") <= 15 .And. Empty(oGrid:GetValue("R8_DATAFIM")) .Or.;
			(oGrid:GetValue("R8_TPEFD") == '01' .AND. oGrid:GetValue("R8_DURACAO") <= 15 .And.;
			!Empty(oGrid:GetValue("R8_DATAINI")) .And. !Empty(oGrid:GetValue("R8_DATAFIM")) .And.;
			 oGrid:GetValue("R8_DATA") > STOD(cAno+cMes+"15") ))
			 	//"Afastamento temporário ocasionado por acidente de trabalho ou doença decorrente do trabalho com duração 
				//não superior a 15 dias, deve ser enviado até o dia 15 (quinze) do mês seguinte da sua ocorrência."
				cMsg += IIf(oGrid:GetValue("R8_TPEFD") == '01', OemToAnsi(STR0127) + StrZero(nI,3) + ": " + OemToAnsi(STR0314) + CRLF,"")
				//"Atenção, o prazo do envio deste evento é : " 
				cMsg += OemToAnsi(STR0059) + DTOC(STOD(cAno+cMes+"15"))+"." + CRLF + CRLF
			
			ElseIf (oGrid:GetValue("R8_DURACAO") > 15 .And. Empty(oGrid:GetValue("R8_DATAFIM")) .Or.;
			(oGrid:GetValue("R8_TPEFD")$ '01/03' .AND. oGrid:GetValue("R8_DURACAO") > 15 .And.;
			(!Empty(oGrid:GetValue("R8_DATAINI")) .And. !Empty(oGrid:GetValue("R8_DATAFIM")) .And.;
			 oGrid:GetValue("R8_DATA") > (oGrid:GetValue("R8_DATAINI")+16) .And.;
			 oGrid:GetValue("R8_DATAINI") > dDcgIni )))
			 	//"Afastamento temporário ocasionado por acidente de trabalho, acidente de qualquer natureza, 
				//ou doença com duração superior a 15 dias deve ser enviado até o 16º dia da sua ocorrência."
			 	cMsg += IIf(oGrid:GetValue("R8_TPEFD")$ '01/03',OemToAnsi(STR0127) + StrZero(nI,3) + ": " + OemToAnsi(STR0315) + CRLF,"")
				//"Atenção, o prazo do envio deste evento é : "
				cMsg += OemToAnsi(STR0059) + DTOC(oGrid:GetValue("R8_DATAINI")+16 )+"." + CRLF + CRLF
					
			ElseIf oGrid:GetValue("R8_TPEFD") $ '03/04' .And. nDias >= 3 .And. nDias <= 15 .And. oGrid:GetValue("R8_DATAINI") > dDcgIni
				//"Atenção, o prazo do envio deste evento é o dia 15 do mês seguinte ao do retorno do funcionário."
				cMsg += OemToAnsi(STR0127) + StrZero(nI,3) + ": " + OemToAnsi(STR0058) + CRLF			
			EndIf
			if !Empty(oGrid:GetValue("R8_CONTINU")) .and. ( oGrid:GetValue("R8_DPAGOS") + oGrid:GetValue("R8_SDPAGAR"))> 15
				cMsg += OemToAnsi(STR0127) + StrZero(nI,3) + ": " + OemToAnsi(STR0059) + DTOC(oGrid:GetValue("R8_DATAINI")+ 16) + CRLF
			EndIF
		EndIf

	Next nI

	If !Empty(cMsg)
		Aviso(OemToAnsi(STR0001), cMsg, {OemToAnsi(STR0038)})
	EndIf
Return

/*/{Protheus.doc} ValAntDp
Validação de Antes e Depois dos valores dos campos
@type function
@author Eduardo
@since 02/06/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param nI, numérico, (Descrição do parâmetro)
/*/
Function ValAntDp(oModel,nI,nTipo)
Local lRet:= .F.
oModlBkp:Goline(nI)

/*01 - Acidente/doença trabalho  para 03 - Acidente/doença não relacionado ao trabalho
01 - Acidente/doença trabalho  para 06 - Aposentadoria por invalidez
02 - Novo afastamento decorrente do mesmo acidente/doença do trabalho dentro de 60 dias  para 06 - Aposentadoria por invalidez
03 - Acidente/doença não relacionado ao trabalho para 01 - Acidente/doença trabalho
03 - Acidente/doença não relacionado ao trabalho para 06 - Aposentadoria por invalidez
04 - Novo afastamento decorrente do mesmo acidente/doença não relacionado a trabalho dentro de 60 dias para 06 - Aposentadoria por invalidez*/

//Verifica se houve alteracao do Tipo de Afastamento e se ele eh permitido
If nTipo == 1
	If 	( (oModel:GetValue("R8_TPEFD")=='01' .and. oModel:GetValue("R8_TPEFDAN") $ '03/06') .Or. ;
	 	(oModel:GetValue("R8_TPEFD")=='03' .and. oModel:GetValue("R8_TPEFDAN") $ '01/06') .Or. ;
	 	(oModel:GetValue("R8_TPEFD")=='02' .and. oModel:GetValue("R8_TPEFDAN") == '01') .Or. ;
	 	(oModel:GetValue("R8_TPEFD")=='04' .and. oModel:GetValue("R8_TPEFDAN") =='06') )
		lRet:= .T.
	EndIf
EndIf

//Valida se eh somente informacao de termino. Os campos R8_TPEFD e R8_TPEFDAN devem estar iguais porque o Tipo nao foi alterado
If nTipo == 2
	//Se o campo R8_TPEFDAN esta preenchido e ele eh igual R8_TPEFD indica que a alteracao eh somente para indicar o termino do afastamento
	If !Empty(oModel:GetValue("R8_DATAFIM")) .And. !Empty(oModel:GetValue("R8_TPEFDAN")) .And. ( oModel:GetValue("R8_TPEFDAN") == oModel:GetValue("R8_TPEFD") )
		lRet:= .T.
	EndIf
EndIf

Return lRet


/*/{Protheus.doc} InExc3000
Rotina Responsável peo preenchimento do XML de Exclusão
@type function
@author Eduardo
@since 05/06/2017
@version 1.0
@param ctpEvento, character, Código do Evento (S-xxx)
@param cRecibo, character, Código do Recibo
@param cCpf, character, Cpf do Trabalhador
@param cPis, character, Pis do Trabalhador
@param cIndApur, character, Indicativo de período de apuração: 1 - Mensal; 2 - Anual (13° salário).
@param cPerApur, character, Periodo de apuração
@return ${return}, ${return_description}
/*/
Function InExc3000(cXml, ctpEvento, cRecibo, cCpf, cPis, lFol, cIndApur, cPerApur, cCategESoc, cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cIdXml, cStatNew, cOperNew, cRetfNew, nRecEvt, lNovoRJE, cKeyMid, aErros)

Local lRet 			:= .T.
Local cChaveMid   	:= ""
Local cStatus   	:= "-1"
Local cVersMw   	:= ""
Local cVersEnv		:= ""

Default cXml		:= ""
Default ctpEvento	:= ""
Default cRecibo	 	:= ""
Default cCpf	 	:= ""
Default cPis	 	:= ""
Default cIndApur 	:= "1"
Default cPerApur	:= ""
Default cCategESoc	:= ""
Default lFol		:= .F.
Default cFilEnv		:= ""
Default lAdmPubl	:= .F.
Default cTpInsc		:= ""
Default cNrInsc		:= ""
Default cIdXml		:= ""
Default cStatNew	:= ""
Default cOperNew	:= ""
Default cRetfNew	:= ""
Default nRecEvt		:= 0
Default lNovoRJE	:= .F.
Default cKeyMid		:= ""
Default aErros		:= {}

fVersEsoc( "S3000", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnv, Nil, @cVersMw )

//processo de exclusão será realizado em outra issue especifica para esta operação
If lMiddleware
	cKeyMid		:= ctpEvento+cRecibo
	cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S3000" + Padr(cKeyMid, 40, " ")
	//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
	GetInfRJE( 2, cChaveMid, @cStatus, Nil, Nil, @nRecEvt )

	//Retorno pendente impede o cadastro
	If cStatus == "2"
		aAdd( aErros, OemToAnsi(STR0035) + SRA->RA_MAT + OemToAnsi(STR0137) + CRLF + OemToAnsi(STR0134) )//" não enviado(a) ao Middleware. Erro: "##"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
		Return .F.
	//Evento sem transmissão, irá sobrescrever o registro na fila
	ElseIf cStatus $ "1/3"
		cOperNew 	:= "I"
		cRetfNew	:= "1"
		cStatNew	:= "1"
		lNovoRJE	:= .F.
	//Será tratado como inclusão
	Else
		cOperNew 	:= "I"
		cRetfNew	:= "1"
		cStatNew	:= "1"
		lNovoRJE	:= .T.
	EndIf

	cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtExclusao/v" + cVersMw + "'>"
	cXML += 	"<evtExclusao Id='" + cIdXml + "'>"
	fXMLIdEve( @cXML, { Nil, Nil, Nil, Nil, 1, 1, "12" } )
	fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
Else
	cXml +='<eSocial>'
	cXml +='<evtExclusao>'
EndIf
cXml +='<infoExclusao>'
cXml +='<tpEvento>' + ctpEvento + '</tpEvento>'
If !lMiddleware
	cXml +='<nrRecEvt >' + cRecibo + '</nrRecEvt>'
Else
	cXml +='<nrRecEvt>' + cRecibo + '</nrRecEvt>'
EndIf
cXml +='<ideTrabalhador>'
cXml +='<cpfTrab>' + cCPF + '</cpfTrab>'
IF cVersEnv < "9.0.00" .And. !(ctpEvento $ "S-1210|S-2190") .AND. !(cCategESoc $ "901|903|904")
	If !lMiddleware
		cXml +='<nisTrab>' + cPis + '</nisTrab>'
	Else
		cXml +='<nisTrab>' + AllTrim(cPis) + '</nisTrab>'
	EndIf
ENDIF
cXml +='</ideTrabalhador>'
If lFol
	cXml +='<ideFolhaPagto>'
	//validação  folha
	IF cVersEnv < "9.0.00" .Or. ctpEvento <> "S-1210"
		cXml +='<indApuracao>' + cIndApur + '</indApuracao>'
	EndIf
	If !Empty(cPerApur)
		cXml +='<perApur>' + cPerApur+ '</perApur>'
	Else
		lRet:= .F.
	EndIF
	cXml +='</ideFolhaPagto>'
EndIf
cXml +='</infoExclusao>'
cXml +='</evtExclusao>'
cXml +='</eSocial>'

Return lRet

/*/{Protheus.doc} fGetContAf()
Função responsável por somar os dias de afastamento considerando as continuações
* Função Recursiva, pois o afastamento informado na continuação poderá ser uma continuação também.
@type function
@author Claudinei Soares
@since 11/10/2018
@version 1.0
@param oGrid	, object	, Grid do afastamento		, Default: oModel:GetModel("GPEA240_SR8")
@param cContAfa	, characters, Sequencia do afastamento	, Default: vazio
@param nLenGrid	, numeric	, Tamanho do GRID			, Default: oGrid:Length()
@param nDias	, numeric	, Dias de afastamento (@)	, Default: 0
@return Nil
/*/

Function fGetContAf(oGrid,cContAfa,nLenGrid,nDias,aAfastEsoc)
Local nG 			:= 0
Local cContAfaR		:= ""
Local lAchouAf		:= .F.

Default cContAfa	:= ""
Default nDias		:= 0
Default nLenGrid	:= oGrid:Length()
Default oGrid 		:= oModel:GetModel("GPEA240_SR8")
Default aAfastEsoc	:= {}

If !Empty(cContAfa)
	//Percorre o GRID para encontrar o afastamento informado na continuação
	For nG := 1 To nLenGrid
		oGrid:GoLine(nG)
		//Se for a sequência informada termina o For
		If cContAfa == oGrid:GetValue("R8_SEQ")
			lAchouAf := .T.
			Exit
		Else
			lAchouAf := .F.
		Endif
	Next nG

	//Posiciona no afastamento informado na continuação
	If lAchouAf
		//Posiciona no GRID encontrado
		oGrid:GoLine(nG)
		//Busca a quantidade de dias
		nDias += oGrid:GetValue("R8_DURACAO")
		cContAfaR := oGrid:GetValue("R8_CONTAFA")
		If Empty(dDcgIni) .Or. oGrid:GetValue("R8_DATAINI") >= dDcgIni  .Or. (!Empty(oGrid:GetValue("R8_DATAFIM")) .And. oGrid:GetValue("R8_DATAFIM") >= dDcgIni .And. oGrid:GetValue("R8_DATAFIM") > dDatabase)
			If ( aScan(aAfasteSoc, {|x| x[1] == nG}) == 0 )
				AAdd(aAfastEsoc,{nG,"",IIF(!EMPTY(oGrid:GetValue("R8_DATAFIM")), .T., .F.), oGrid:GetValue("R8_SEQ"), oGrid:GetValue("R8_DURACAO"), oGrid:GetValue("R8_CONTAFA"), oGrid:GetValue("R8_TPEFD")})
			ENDIF
		EndIf
		//Se o afastamento informado também for uma continuação, chama a função novamente
		//para somar os dias de afastamento corretamente.
		If !Empty(cContAfaR)
			fGetContAf(oGrid,cContAfaR,nLenGrid,,@aAfastEsoc)
		Endif
	EndIf
Endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} fTafKAfast
Função responsável por gerar Tafkey para ser usada nos campos do
afastamento
@author Rafael Reis
@since 06/11/2018
@version 1.0.0
/*/
//-------------------------------------------------------------------
Function fTafKAfast(cFil,cMat,cSeq)
Local cTafKey := ""

cTafKey := Substr(FWUUId(cFil+cMat+cSeq), 1, 60)

Return cTafKey


//-------------------------------------------------------------------
/*/{Protheus.doc} RetCm6
RETORNA O STAUTS DO REGISTRO DA CM6
@author GISELE NUNCHERINO
@since 31/05/2019
@version 1.0.0
/*/
//-------------------------------------------------------------------
Function RetCM6(cChave, nOrder)
Local cStatus := "-1"

IF nOrder == 1
	CM6->(DBSETORDER(6)) // apenas data de inicio
elseif nOrder == 2
	CM6->(DBSETORDER(7)) // data de inicio e fim
endIf

IF CM6->(DBSEEK(cChave))
	CSTATUS := CM6->CM6_STATUS
ENDIF

return cStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSR8
Retorna a data final antes da alteração do Grid
@author Allyson Mesashi
@since 03/06/2019
@version 1.0.0
/*/
//-------------------------------------------------------------------
Static Function RetSR8(cSeq)
Local aAreaSR8  := SR8->(GetArea())
Local dDataFim  := cToD("//")

Default cSeq    := ""

SR8->( dbSetOrder(2) )
If SR8->( dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + cSeq) )
	dDataFim := SR8->R8_DATAFIM
EndIf

RestArea(aAreaSR8)

Return dDataFim

/*/{Protheus.doc} fIntM030Off
Efetua integração offline do evento S-2230
@author allyson.mesashi
@since 07/05/2020
/*/
Function fIntM030Off( oModel, aErros, lLote )

Local aAreaSR8		:= SR8->(GetArea())
Local cTafKey		:= ""
Local dDataIni		:= cToD("")
Local dDtCarga  	:= SuperGetMv("MV_DTCGINI",, StoD("//"))
Local lRet			:= .F.

Default oModel		:= Nil
Default aErros		:= {}
Default lLote		:= .F.

If lLote
	dDataIni := M->RH_DATAINI
Else
	dDataIni := oModel:GetValue("GPEM030_MSRH","RH_DATAINI")
EndIf
Private cPeriodo := AnoMes(dDataIni)

SR8->( dbSetOrder(1) )//R8_FILIAL+R8_MAT+DTOS(R8_DATAINI)+R8_TIPO

If dDataIni >= dDtCarga
	If SR8->( dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+dToS(dDataIni) ) )
		If Empty(SR8->R8_TAFKI)
			If SR8->( RecLock("SR8", .F.) )
				cTafKey := Substr(FWUUId(SR8->(R8_FILIAL + R8_MAT + R8_SEQ)), 1, 60)
				SR8->R8_TAFKI	 := cTafKey
				SR8->R8_TAFKF 	 := cTafKey
				SR8->( MsUnlock() )
			EndIf
		EndIf
		lRet := IntFerTAF(@aErros, , .T., lLote)
	Else
		If !lLote
			Help( ,, OemToAnsi(STR0001),, OemToAnsi(STR0194), 1, 0 ) //"Atenção"##"Não foi encontrado o registro das férias na tabela SR8"
		Else
			aAdd( aErros, OemToAnsi(STR0194) )//"Não foi encontrado o registro das férias na tabela SR8"
		EndIf
	EndIf
Else
	If !lLote
		Help( ,, OemToAnsi(STR0001),, OemToAnsi(STR0195), 1, 0 ) //"Atenção"##"Data de início das férias anterior ao início da obrigatoriedade do envio do evento ao eSocial"
	Else
		aAdd( aErros, OemToAnsi(STR0195) )//"Data de início das férias anterior ao início da obrigatoriedade do envio do evento ao eSocial"
	EndIf
EndIf

RestArea( aAreaSR8 )

Return lRet

/*/{Protheus.doc} fIntM030Lot()
Cria um browse que permite a seleção dos funcionários para a integração em lote das férias para eSocial
@author allyson.mesashi
@since 07/05/2020
@version 1.0
/*/
Function fIntM030Lot()

Local aArea			:= GetArea()
Local aAreaSRA		:= SRA->( GetArea() )
Local aAreaSRH		:= SRH->( GetArea() )
Local aAreaSX3		:= SX3->( GetArea() )
Local aFieldFilt	:= {}
Local aSeek			:= {}
Local oTmpTable		:= Nil
Local lLibAtu		:= (GetApoInfo("FWFORMBROWSE.PRW")[4] > sToD("20200401"))

Private aMarcSRH	:= {}
Private _MarcReg	:= {}
Private aGpm040Log	:= {}
Private cAliasMark 	:= "TABAUX"
Private aSRHStruct	:= SRH->(DBSTRUCT())

Static _Marcados	:= {}

	fCrTmpM030(@oTmpTable, @aSRHStruct, @aFieldFilt)
	aColsMark:= fMntColM030(aSRHStruct)

	aAdd(aSeek, {STR0175,{{"", "C", FwGetTamFilial+TamSX3("RH_MAT")[1]+8, 0, "RH_FILIAL+RH_MAT+DTOS(RH_DATAINI)", "@!"}} } )//"Filial + Matricula + Inic. Ferias"

	oBrowse := FWMarkBrowse():New()
	oBrowse:SetAlias((cAliasMark))
	oBrowse:SetFields(aColsMark)
	oBrowse:SetFieldMark("RH_OKTRANS")
	oBrowse:SetMenuDef('')
	oBrowse:AddButton(STR0176, {|| ProcGpe( {|lEnd| fEnvLotM030()}, "" )},,,, .F., 2 ) //"Integrar"
	oBrowse:SetDescription(OemToAnsi(STR0177)) //"Férias"

	//Se a lib estiver atualizada libera a utilização de filtro padrão na MarkBrowse
	If lLibAtu
		oBrowse:SetFieldFilter(aFieldFilt)
	Else
		Aviso(OemToAnsi(STR0001), OemToAnsi(STR0243), {OemToAnsi(STR0038)})
	EndIf

	oBrowse:SetSeek(.T., aSeek)
	oBrowse:SetAfterMark({|| fMarcM030() })
	oBrowse:SetAllMark({|| fMrkAllM030() })
	oBrowse:Activate()

	If ValType(oTmpTable) == "O"
		oTmpTable:Delete()
	EndIf
	_Marcados	:= {}
	RestArea(aArea)
	RestArea(aAreaSRA)
	RestArea(aAreaSRH)
	RestArea(aAreaSX3)

Return

/*/{Protheus.doc} fCrTmpM030()
Efetua filtro dos registros da tabela SRH aptos a serem integrados
@author allyson.mesashi
@since 07/05/2020
@version 1.0
/*/
Static Function fCrTmpM030(oTmpTable, aColumns, aFldFilter)

Local cAliasSRH	:= GetNextAlias()
Local cValidFil	:= ""
Local nCont		:= 0
Local nPos		:= 0

// Filtro das filiais que o usuário tem acesso
If Len(fValidFil()) <= 2000
	cValidFil := "(AllTrim(SRH->RH_FILIAL) $ '" + fValidFil() + "')"
Else
	cValidFil := "(!AllTrim(SRH->RH_FILIAL) $ '" + fValidFil(, .T.) + "')"
EndIf

aAdd( aColumns, { "RH_OKTRANS","C",02,00 })

If (nPos := aScan( aColumns, { |x| x[1] == "RH_MAT" } )) > 0
	aAdd( aColumns )
	aIns( aColumns, nPos+1 )
	aColumns[nPos+1] := { "RH_NOME","C",TamSx3("RH_NOME")[1],00 }
	aAdd( aColumns )
	aIns( aColumns, nPos+2 )
	aColumns[nPos+2] := { "RA_CATEFD","C",3,00 }
EndIf
If (nPos := aScan( aColumns, { |x| x[1] == "RA_NOME" } )) > 0
	aDel( aColumns, nPos )
	aSize( aColumns, Len(aColumns)-1)
EndIf

//Efetua a criacao do arquivo temporario
oTmpTable := FWTemporaryTable():New(cAliasMark)
oTmpTable:SetFields( aColumns )
oTmpTable:AddIndex( "TABAUX1", {"RH_FILIAL","RH_MAT","RH_DATAINI"} )
oTmpTable:Create()

cWhere := "% SRH.D_E_L_E_T_ = ' ' %"

BeginSql alias cAliasSRH
	SELECT  R_E_C_N_O_ AS RECNOSRH
	FROM %table:SRH% SRH
	WHERE %exp:cWhere%
	ORDER BY SRH.RH_FILIAL, SRH.RH_MAT, SRH.RH_DATAINI
EndSql

SRA->(dbSetOrder(1))
While (cAliasSRH)->(!Eof())
	SRH->( dbGoto( (cAliasSRH)->RECNOSRH ) )
	If !( &( cValidFil ) )
		(cAliasSRH)->(dbSkip())
		Loop
	EndIf
	If SRA->( dbSeek( SRH->RH_FILIAL+SRH->RH_MAT ) )
		If RecLock(cAliasMark,.T.)
			(cAliasMark)->RH_FILIAL 	:= SRH->RH_FILIAL
			(cAliasMark)->RH_MAT 		:= SRH->RH_MAT
			(cAliasMark)->RH_NOME	 	:= SRA->RA_NOME
			(cAliasMark)->RA_CATEFD	 	:= SRA->RA_CATEFD
			(cAliasMark)->RH_SALMES 	:= SRH->RH_SALMES
			(cAliasMark)->RH_SALDIA  	:= SRH->RH_SALDIA
			(cAliasMark)->RH_SALDIA1	:= SRH->RH_SALDIA1
			(cAliasMark)->RH_SALHRS  	:= SRH->RH_SALHRS
			(cAliasMark)->RH_SALHRS1  	:= SRH->RH_SALHRS1
			(cAliasMark)->RH_DATABAS 	:= SRH->RH_DATABAS
			(cAliasMark)->RH_DBASEAT 	:= SRH->RH_DBASEAT
			(cAliasMark)->RH_DFERVEN 	:= SRH->RH_DFERVEN
			(cAliasMark)->RH_DFERIAS	:= SRH->RH_DFERIAS
			(cAliasMark)->RH_DABONPE	:= SRH->RH_DABONPE
			(cAliasMark)->RH_ABOPEC 	:= SRH->RH_ABOPEC
			(cAliasMark)->RH_DFALTAS 	:= SRH->RH_DFALTAS
			(cAliasMark)->RH_PERC13S	:= SRH->RH_PERC13S
			(cAliasMark)->RH_DATAINI 	:= SRH->RH_DATAINI
			(cAliasMark)->RH_DATAFIM  	:= SRH->RH_DATAFIM
			(cAliasMark)->RH_DTAVISO  	:= SRH->RH_DTAVISO
			(cAliasMark)->RH_DTRECIB 	:= SRH->RH_DTRECIB
			(cAliasMark)->RH_DIALRE1  	:= SRH->RH_DIALRE1
			(cAliasMark)->RH_ROTEIR  	:= SRH->RH_ROTEIR
			(cAliasMark)->RH_SALDIF 	:= SRH->RH_SALDIF
			(cAliasMark)->RH_PERIODO 	:= SRH->RH_PERIODO
			(cAliasMark)->RH_DIALREM 	:= SRH->RH_DIALREM
			(cAliasMark)->RH_NPAGTO 	:= SRH->RH_NPAGTO
			(cAliasMark)->RH_SALMIN   	:= SRH->RH_SALMIN
			(cAliasMark)->RH_SALMIND	:= SRH->RH_SALMIND
			(cAliasMark)->RH_SALARIO    := SRH->RH_SALARIO
			(cAliasMark)->RH_SALARDF 	:= SRH->RH_SALARDF
			(cAliasMark)->RH_TIPCAL     := SRH->RH_TIPCAL
			(cAliasMark)->RH_DAFASTA   	:= SRH->RH_DAFASTA
			(cAliasMark)->RH_MEDATU    	:= SRH->RH_MEDATU
			(cAliasMark)->RH_OBSERVA 	:= SRH->RH_OBSERVA
			(cAliasMark)->RH_PROCES  	:= SRH->RH_PROCES
			(cAliasMark)->RH_RHEXP    	:= SRH->RH_RHEXP
			(cAliasMark)->RH_ACEITE    	:= SRH->RH_ACEITE
			(cAliasMark)->(MsUnlock())
		EndIf
	EndIf
	(cAliasSRH)->( dbSkip() )
EndDo
(cAliasSRH)->( dbCloseArea() )

For nCont := 1 To Len(aColumns)
	aAdd( aFldFilter, { aColumns[nCont, 1], FWX3Titulo( aColumns[nCont, 1] ), aColumns[nCont, 2], aColumns[nCont, 3], aColumns[nCont, 4], X3Picture( aColumns[nCont, 1] ) } )
Next nCont

Return

/*/{Protheus.doc} fMntColM030
Carrega tabela temporária com dados para exibição na MarkBrowse
@author allyson.mesashi
@since 07/05/2020
@version 1.0
/*/
Static Function fMntColM030(aCampos)

Local aArea		:= GetArea()
Local aColsAux 	:=`{}
Local aColsSX3	:= {}
Local nX		:= 0

DbSelectArea("SX3")
DbSetOrder(2)

For nX := 1 to Len(aCampos)
	If SX3->( dbSeek(aCampos[nX,1]) )
		aColsSX3 := {X3Titulo(), &("{||(cAliasMark)->"+(aCampos[nX,1])+"}"), SX3->X3_TIPO, SX3->X3_PICTURE,1,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,,,,,,,,1}
		aAdd(aColsAux,aColsSX3)
		aColsSX3 := {}
	EndIf
Next nX

RestArea(aArea)

Return aColsAux

/*/{Protheus.doc} fMarcM030
Realiza a marcação de um registro no browse
@author allyson.mesashi
@since 07/05/2020
@version 1.0
/*/
Static Function fMarcM030()

Local cKey := (cAliasMark)->RH_FILIAL + (cAliasMark)->RH_MAT + dToS((cAliasMark)->RH_DATAINI)
Local nPos := aScan( aMarcSRH, { |x| ( x[1] == cKey )})

If oBrowse:IsMark()
	Aadd( aMarcSRH, { (cAliasMark)->RH_FILIAL + (cAliasMark)->RH_MAT + dToS((cAliasMark)->RH_DATAINI) } )
	Aadd(_Marcados, oBrowse:At())
Else
	If ( nPos > 0 )
		nLastSize := Len( aMarcSRH )
		aDel( aMarcSRH, nPos )
		aDel(_Marcados, nPos)
		aSize( aMarcSRH, ( nLastSize - 1 ))
		aSize(_Marcados, ( nLastSize - 1 ))
	EndIF
EndIf

Return

/*/{Protheus.doc} fMrkAllM030
Faz a marcação de todos os registros do browse
@author allyson.mesashi
@since 07/05/2020
@version 1.0
/*/
Static Function fMrkAllM030()

Local nUltimo

oBrowse:GoBottom(.F.)
nUltimo := oBrowse:At()
oBrowse:GoTop()

While .T.
	oBrowse:MarkRec()
	If nUltimo == oBrowse:At()
		oBrowse:GoTop()
		Exit
	EndIf
	oBrowse:GoDown()
EndDo

Return

/*/{Protheus.doc} fClearM030
Limpa as marcações do browse
@author allyson.mesashi
@since 07/05/2020
@version 1.0
/*/
Static Function fClearM030()

While Len(_Marcados) >= 1
	oBrowse:GoTo(_Marcados[1])
	oBrowse:MarkRec()
EndDo

oBrowse:Refresh(.T.)

Return

/*/{Protheus.doc} fEnvLotM030()
Efetua validação e envio do desligamento ao eSocial
@author allyson.mesashi
@since 07/05/2020
@version 1.0
/*/
Static Function fEnvLotM030()

Local aErros	:= {}
Local aLogTitle	:= { STR0178 }//"Férias Processadas:"
Local aLogFile	:= {}
Local aTpAlt 	:= {.F.,.F.,.F.}
Local cBkpFil	:= cFilAnt
Local cTrabVincu:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|307|309" //Trabalhador com vinculo
Local cStatus0 	:= "-1"
Local cVersEnvio:= ""
Local nCont		:= 0
Local nX		:= 0
Local lTemMat	:= SRA->(ColumnPos("RA_DESCEP")) > 0
Local lGeraMat	:= .F.

Private aInfoC		:= {}
Private cTpInsc  	:= ""
Private lAdmPubl 	:= .F.
Private cNrInsc  	:= "0"
Private cChaveMid	:= ""

If Len(aMarcSRH) < 1
	Help(' ', 1, STR0001, , STR0179, 1, 0) //"Atenção"##"Nenhuma férias foi selecionada."
	Return
EndIf

GPProcRegua( Len(aMarcSRH) )
oBrowse:Refresh(.T.)
fVersEsoc( "S2230", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio )
SRA->( dbSetOrder(1) )//RA_FILIAL+RA_MAT+RA_NOME
(cAliasMark)->( dbSetOrder(1) )//RH_FILIAL+RH_MAT+DTOS(RH_DATAINI)

For nCont := 1 To Len(aMarcSRH)
	(cAliasMark)->( dbSeek( aMarcSRH[nCont, 1] ) )
	SRA->( dbSeek( (cAliasMark)->RH_FILIAL+(cAliasMark)->RH_MAT ) )
	GPIncProc(STR0180 + SRA->RA_FILIAL + SRA->RA_MAT )//" Matrícula: "

	aErros		:= {}
	aTpAlt 		:= {.F.,.F.,.F.}
	cFilAnt		:= SRA->RA_FILIAL
	lRet		:= .T.

	If SRA->RA_CATEFD $ cTrabVincu
		cCPF := AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)
	Else
		lGeraMat := lTemMat .And. SRA->RA_DESCEP == "1"
		If !lMiddleware
			If cVersEnvio >= "9.0"
				cCPF := AllTrim( SRA->RA_CIC ) + ";" + If( lGeraMat, SRA->RA_CODUNIC, "" ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
			Else
				cCPF := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
			EndIf
		Else
			cCPF := If( cVersEnvio >= "9.0" .And. lGeraMat, SRA->RA_CODUNIC, AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA ) )
		EndIf
	EndIf
	If SRA->RA_CATEFD $ cTrabVincu
		If !lMiddleware
			cStatus1 := TAFGetStat( "S-2200", cCPF)
		Else
			cStatus1 := "-1"
			fPosFil( cEmpAnt, SRA->RA_FILIAL )
			aInfoC   := fXMLInfos()
			If LEN(aInfoC) >= 4
				cTpInsc  := aInfoC[1]
				lAdmPubl := aInfoC[4]
				cNrInsc  := aInfoC[2]
			Else
				cTpInsc  := ""
				lAdmPubl := .F.
				cNrInsc  := "0"
			EndIf
			cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
			cStatus1 	:= "-1"
			//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
			GetInfRJE( 2, cChaveMid, @cStatus1 )
		EndIf
	Else
		If !lMiddleware
			cStatus1 := TAFGetStat( "S-2300", cCPF)
		Else
			fPosFil( cEmpAnt, cFilAnt )
			aInfoC   := fXMLInfos()
			If LEN(aInfoC) >= 4
				cTpInsc  := aInfoC[1]
				lAdmPubl := aInfoC[4]
				cNrInsc  := aInfoC[2]
			Else
				cTpInsc  := ""
				lAdmPubl := .F.
				cNrInsc  := "0"
			EndIf
			cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cCPF, 40, " ")
			cStatus1 	:= "-1"
			//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
			GetInfRJE( 2, cChaveMid, @cStatus1 )
		EndIf
	EndIf
	If cStatus0 == '2' .OR. cStatus1 == '2'
		cErro := "2"
	ElseIf cStatus0 == '3' .OR. cStatus1 == '3' .OR. cStatus0 == ' ' .OR. cStatus1 == ' ' .OR. cStatus0 == '1' .OR. cStatus1 == '1'
		cErro := " |1|3"
	ElseIf cStatus0 == '-1' .AND. cStatus1 == '-1'
		cErro := "-1"
	Else
		fStatusTAF(@aTpAlt,cStatus0,cStatus1,/*cFuncaoPai*/, /*aContainer*/)
	EndIf
	If aTpAlt[3]
		RegToMemory(cAliasMark, .F., .F., .F., "fEnvLotM030")
		lRet := fIntM030Off( Nil, @aErros, .T. )

		If lRet
			aAdd( aLogfile, OemToAnsi(STR0183) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0193 + dToC((cAliasMark)->RH_DATAINI) ) //"O evento S-2230 - Afastamento Temporário foi gerado com sucesso para o funcionário: "##" Data de Início: "
			For nX := 1 To Len( aErros )
				aAdd( aLogfile, STR0184 + "#" + cValToChar(nX) + ": " + aErros[ nX ] )//"Aviso"
			Next
			aAdd( aLogfile, "" ) //Quebra de Linha
		Else
			aAdd( aLogfile, OemToAnsi(STR0185) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0193 + dToC((cAliasMark)->RH_DATAINI) ) //"O evento S-2230 - Afastamento Temporário não foi gerado para o funcionário: "##" Data de Início: "
			For nX := 1 To Len( aErros )
				aAdd( aLogfile, STR0186 + "#" + cValToChar(nX) + ": " + aErros[ nX ] )//"Erro"
			Next
			aAdd( aLogfile, "" ) //Quebra de Linha
		EndIf
	Else
		aAdd( aLogfile, OemToAnsi(STR0185) + SRA->RA_FILIAL + " - " + SRA->RA_MAT + " |" + STR0193 + dToC((cAliasMark)->RH_DATAINI) ) //"O evento S-2230 - Afastamento Temporário não foi gerado para o funcionário: "##" Data de Início: "
		If cErro $ "2"
			If !lMiddleware
				aAdd( aLogfile, STR0186 + ": " + OemToAnsi(STR0187)  ) //"Erro"##"Registro de Admissão do Funcionário está em trânsito TAF x RET. Verifique no sistema TAF. A rescisão não será efetivada."
			Else
				aAdd( aLogfile, STR0186 + ": " + OemToAnsi(STR0188)  ) //"Erro"##"Registro de Admissão do Funcionário está em trânsito ao RET. Verifique no Middleware. O afastamento não será efetivado."
			EndIf
		ElseIf cErro $ " |1|3"
			If !lMiddleware
				aAdd( aLogfile, STR0186 + ": " + OemToAnsi(STR0189)  ) //"Erro"##"Registro de Admissão do Funcionário ainda não foi transmitido ao RET ou consta inconsistências. Verifique no sistema TAF. O afastamento não será efetivado."
			Else
				aAdd( aLogfile, STR0186 + ": " + OemToAnsi(STR0190)  ) //"Erro"##"Registro de Admissão do Funcionário ainda não foi transmitido ao RET ou consta inconsistências. Verifique no Middleware. O afastamento não será efetivado."
			EndIf
		ElseIf cErro $ "-1"
			If !lMiddleware
				aAdd( aLogfile, STR0186 + ": " + OemToAnsi(STR0191)  ) //"Erro"##"O funcionário ainda não possui integração com o TAF. Realize a sua integração para poder gerar a rescisão. O afastamento não será efetivado."
			Else
				aAdd( aLogfile, STR0186 + ": " + OemToAnsi(STR0192)  ) //"Erro"##"O funcionário ainda não possui integração com o Middleware. Realize a sua integração para poder gerar a rescisão. O afastamento não será efetivado."
			EndIf
		EndIf
		aAdd( aLogfile, "" ) //Quebra de Linha
	EndIf
Next nCont

fMakeLog( {aLogFile}, aLogTitle, NIL, NIL, STR0181, STR0182, NIL, NIL, NIL, .F. ) //"Lote"##"Log de Ocorrências"

fClearM030()

cFilAnt := cBkpFil

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGM23Estag  ºAutor  ³Glaucia Messina     º Data ³  01/04/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se ha cadastro de estagio, para trab sem vinculo  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023- fCargTSV                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGM23Estag(cFil,cMat, dDataRef, aEstagio, aInstit, aAgente, aCoord, lCadEst, oMdl )
Local aArea     := GetArea()
Local lAchou    := .T.
Local cRFSEntid
Local cRFSAgent
Local cRFSCoord
Local cRFSDtFim
Local cRFSNatur
Local cRFSApoli
Local cRFSNivel
Local cRFSAtuac
Local lNrLogr    := RA0->(ColumnPos("RA0_NUMEND")) > 0

Default lCadEst    := .F.
Default oMdl := Nil

    If !lCadEst
        //---------------------------------------------
        //| Se vier da persistência ou carga inicial
        //| Posiciona no banco e da carga para memória
        //---------------------------------------------
        DbSelectArea("RFS")
        DbSetOrder(1)
        lAchou := DbSeek( cFil + cMat )

        If lAchou
            RegToMemory("RFS",,,.F.)
            cRFSEntid := M->RFS_ENTIDA
            cRFSAgent := M->RFS_AGENTE
            cRFSCoord := M->RFS_COORD
            cRFSDtFim := M->RFS_DTFIM
            cRFSNatur := M->RFS_NATUR
            cRFSApoli := M->RFS_APOLIC
            cRFSNivel := M->RFS_NIVEL
            cRFSAtuac := M->RFS_ATUA
        EndIf

    Else
        cRFSEntid := oMdl:GetValue("RFS_ENTIDA")
        cRFSAgent := oMdl:GetValue("RFS_AGENTE")
        cRFSCoord := oMdl:GetValue("RFS_COORD")
        cRFSDtFim := oMdl:GetValue("RFS_DTFIM")
        cRFSNatur := oMdl:GetValue("RFS_NATUR")
        cRFSApoli := oMdl:GetValue("RFS_APOLIC")
        cRFSNivel := oMdl:GetValue("RFS_NIVEL")
        cRFSAtuac := oMdl:GetValue("RFS_ATUA")
    EndIf

    If lAchou
        Aadd(aEstagio,{;
            Iif( cRFSNatur == '1','O','N'),;
            AllTrim(cRFSNivel)    ,;
            AllTrim(cRFSAtuac)    ,;
            AllTrim(cRFSApoli)    ,;
            M->RFS_DTFIM    })

        If !Empty(cRFSEntid)
            dbSelectArea("RA0")
            RA0->(DbSetOrder(1))
            If RA0->(DbSeek(FwxFilial("RA0",cFil) + cRFSEntid))
                Aadd(aInstit,{;
                    RA0->RA0_CGC,;
                    AllTrim(RA0->RA0_DESC),;
                    AllTrim(RA0->RA0_ENDERE),;
                    AllTrim(RA0->RA0_BAIRRO),;
                    RA0->RA0_CEP,;
                    RA0->RA0_CODMUN,;
                    RA0->RA0_ESTADO,;
                    Iif( lNrLogr, RA0->RA0_NUMEND, "" ) })
            EndIf
        EndIf

        If !Empty(cRFSAgent)
            dbSelectArea("RFR")
            RFR->(DbSetOrder(1))
            If RFR->(MsSeek(FwxFilial("RFR",cFil) + cRFSAgent))
                Aadd(aAgente,{;
                    RFR->RFR_CNPJ,;
                    AllTrim(RFR->RFR_NOME),;
                    AllTrim(RFR->RFR_END),;
                    AllTrim(RFR->RFR_NREND),;
                    AllTrim(RFR->RFR_BAIRRO),;
                    RFR->RFR_CEP,;
                    RFR->RFR_CODMUN,;
                    RFR->RFR_UF})
            EndIf
        EndIf

        If !Empty(cRFSCoord)
            dbSelectArea("RD0")
            RD0->(DbSetOrder(1))
            If RD0->(MsSeek(FwxFilial("RD0",cFil) + cRFSCoord))
                Aadd(aCoord,{RD0->RD0_CIC,RD0->RD0_NOME})
            EndIf
        EndIf
    EndIf

    RestArea(aArea)
Return

/*/{Protheus.doc} fInt2231I
Geração XML do evento S-2231 - Cessão - Início
@type  Function
@author isabel.noguti
@since 02/08/2022
@version 1.0
@param oGrid,	object,	Grid dos afastamentos
@param cFilEnv,	char,	Filial de envio no taf
@param aErros,	array,	descrição erros retornados
@return lRet,	logico,	indica se a integração foi efetuada com sucesso
/*/
Function fInt2231I(oGrid, cFilEnv, aErros, lRetif)

	Local cXml		:= ""
	Local lRet		:= .F.
	Local cMsgErro	:= ""

	Default oGrid	:= oModel:GetModel("GPEA240_SR8")
	Default aErros	:= {}
	Default lRetif	:= .F.

	If !lMiddleware
		cXml :='<eSocial>'
		cXml +=	'<evtCessao>'

		If lRetif
			cXml +='<ideEvento>'
			cXml +='	<indRetif>2</indRetif>'
			cXml +='</ideEvento>'
		EndIf

		cXml +=	'<ideVinculo>'
		cXml +=		'<cpfTrab>' + SRA->RA_CIC + '</cpfTrab>' //ja ta posicionado e ja conferiu status 2200
		cXml +=		'<matricula>' + SRA->RA_CODUNIC + '</matricula>'
		cXml +=	'</ideVinculo>'

		cXml +=	'<infoCessao>'
		cXml +=		'<iniCessao>'
		cXml +=			'<dtIniCessao>' + DTOS(oGrid:GetValue("R8_DATAINI")) + '</dtIniCessao>'
		cXml +=			'<cnpjCess>' + oGrid:GetValue("R8_CNPJCES") + '</cnpjCess>'
		cXml +=			'<respRemun>' + If(oGrid:GetValue("R8_TPCES") == "2", "N", "S") + '</respRemun>'
		cXml +=		'</iniCessao>'
		cXml +=	'</infoCessao>'

		cXml +=	'</evtCessao>'
		cXml +='</eSocial>'

		GrvTxtArq(alltrim(cXml), "S2231", SRA->RA_CIC)

		If Len(aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, ,"1", "S2231")) == 0
			oGrid:LoadValue( "R8_INTGTAF",	oGrid:GetValue("R8_DATA") )
			oGrid:LoadValue( "R8_TAFKI",	fTafKAfast( FwxFilial("SR8",FWCodFil()), oGrid:GetValue("R8_MAT"), oGrid:GetValue("R8_SEQ")) )
			lRet := .T.
		ElseIf len(aErros)> 0
			FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
			lRet:= IIF(aErros[1]!='000026',.F.,.T.)
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fRetV72
RETORNA O STAUTS DO REGISTRO DA V72
@author lidio.oliveira
@since 16/08/2022
@version 1.0
@param cChave,	char,	Chave utilizada para o dbseek na tabela
@param nIndex,	num,	indice utilizado
@return cStatus,char,	retorna o status do registro no TAF
@version 1.0.0
/*/
//-------------------------------------------------------------------
Static Function fRetV72(cChave, nIndex)

	Local aArea		:= GetArea()
	Local cStatus	:= "-1"

	V72->(DBSETORDER(nIndex)) // apenas data de inicio
	IF V72->(DBSEEK(cChave))
		CSTATUS := V72->V72_STATUS
	ENDIF

	RestArea(aArea)

return cStatus
