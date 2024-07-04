#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'TMSXFUNF.ch'

//-------------------------------------------------------------------------------------------------
/*/ BIBLIOTECA DE FUNÇÕES USADAS PELAS ROTINAS DE DEMANDA
//-------------------------------------------------------------------------------------------------
/*/


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMUpQtMDmd
Realiza a soma ou subtração das quantidades da meta do contrato de demanda.
@return ${aRet}, array contendo 2 informações:
	aRet[1]: .T. se a operação foi executada com sucesso ou .F. se não foi.
	aRet[2]: mensagem de erro caso a operação não tenha sido executada com sucesso.
@param cFilial: filial do contrato de demanda.
@param cCodCrt: código do contrato de demanda.
@param cCodGrd: código do grupo de região vinculado à meta.
@param cTipVei: código do tipo de veículo vinculado à meta.
@param cSeqMeta: código da sequência da meta.
@param nQtd: quantidade a ser atualizada
@param nOper: indica qual a operação está sendo efetuada.
		1 = Inclusão de DEMANDA 
		2 = Exclusão de DEMANDA
		3 = Inclusão de PLANEJAMENTO DE DEMANDA
		4 = Exclusão de PLANEJAMENTO DE DEMANDA
		5 = Inclusão de PROGRAMAÇÃO DE CARGA
		6 = Exclusão de PROGRAMAÇÃO DE CARGA
		7 = Inclusão de VIAGEM
		8 = Exclusão de VIAGEM
		9 = Inclusão de RECUSA DE DEMANDA (Transportadora)
		10 = Inclusão de RECUSA DE DEMANDA (Cliente)
		11 = Inclusão do ENCERRAMENTO DA DEMANDA
		12 = Exclusão do ENCERRAMENTO DA DEMANDA
		Opções de finalização do processo de Demandas sem integração com o TMS:
		13 = Em Transito 
		14 = Estorna em Transito
		15 = Cancelamento de demanda
		16 = Estorno de cancelamento de demanda
		17 = Bloqueio de demanda a partir de documentos sem viagem
		18 = Desbloqueio de demanda a partir de documentos sem viagem
		19 = Bloqueio de demanda a partir de documentos com viagem
		20 = Desbloqueio de demanda a partir de documentos com viagem
		21 = De reprocesso para documentos com viagem
		22 = Estorno da operação de reprocesso para documentos com viagem 
		23 = De reprocesso para documentos sem viagem e com programação
		24 = Estorno da operação de reprocesso para documentos sem viagem e com programação 
		25 = Encerramento da demanda a partir do reprocesso
		26 = Estorno do encerramento da demanda a partir do reprocesso
		27 = Bloqueio de demanda a partir de documentos em reprocesso
		28 = Envio para reprocesso a partir de demandas bloqueadas

@type function
@author Wander Horongoso
@version 12.1.17
@since 09/04/2018
/*/
//-------------------------------------------------------------------------------------------------
Function TMUpQtMDmd(cFilCrt, cCodCrt, cCodGrd, cTipVei, cSeqMeta, nQtd, nOper)
Local aRet := {.T.,''}
Local aArea 
Local aAreaDL7 

	If !Vazio(cCodCrt) .And. !Vazio(cCodGrd) .And. !Vazio(cSeqMeta) //O tipo de veículo pode estar vazio pois não é obrigatório

		aRet := TMLockDmd("DLG_" + cFilCrt + cCodCrt + cCodGrd + cTipVei + cSeqMeta)
		If aRet[1]
	
			aArea := DLG->(GetArea())
			DLG->(dbSetOrder(1))
			
			If DLG->(DbSeek(cFilCrt + cCodCrt + cCodGrd + cTipVei + cSeqMeta))
				RecLock("DLG",.F.)
			
				Do Case
					Case nOper == 1 				//Inclusão de DEMANDA 
						DLG->DLG_QTDDEM += nQtd
					Case nOper == 2 				//Exclusão de DEMANDA
						DLG->DLG_QTDDEM -= nQtd
					Case nOper == 3 				//Inclusão de PLANEJAMENTO DE DEMANDA
						DLG->DLG_QTDPLN += nQtd
						DLG->DLG_QTDDEM -= nQtd
					Case nOper == 4 				//Exclusão de PLANEJAMENTO DE DEMANDA
						DLG->DLG_QTDPLN -= nQtd
						DLG->DLG_QTDDEM += nQtd
					Case nOper == 5 				//Inclusão de PROGRAMAÇÃO DE CARGA
						DLG->DLG_QTDPRG += nQtd
						DLG->DLG_QTDPLN -= nQtd
					Case nOper == 6 				//Exclusão de PROGRAMAÇÃO DE CARGA
						DLG->DLG_QTDPRG -= nQtd
						DLG->DLG_QTDPLN += nQtd
					Case nOper == 7 				//Inclusão de VIAGEM
						DLG->DLG_QTDVIA += nQtd
						DLG->DLG_QTDPRG -= nQtd
					Case nOper == 8 				//Exclusão de VIAGEM
						DLG->DLG_QTDVIA -= nQtd
						DLG->DLG_QTDPRG += nQtd
					Case nOper == 9 				//Inclusão de RECUSA DE DEMANDA (Transportadora)
						DLG->DLG_QTDREC += nQtd
						DLG->DLG_QTDDEM -= nQtd
					Case nOper == 10 				//Inclusão de RECUSA DE DEMANDA (Cliente)
						aAreaDL7 := DL7->(GetArea())
						DL7->(DbSetOrder(1))
						If DL7->(DbSeek(cFilCrt + cCodCrt))
							If DL7->DL7_RECUSA == "2" 
								If !IsInCallStack("T153RECPL")
									DLG->DLG_QTDDEM -= nQtd
								EndIf
							Else
								DLG->DLG_QTDRCL += nQtd
								DLG->DLG_QTDDEM -= nQtd							
							EndIf		
						EndIf
						RestArea(aAreaDL7)						
					Case nOper == 11 				//Encerramento da demanda a partir da viagem
						DLG->DLG_QTDVIA -= nQtd
						DLG->DLG_QTDENC += nQtd
					Case nOper == 12 				//Estorno do encerramento da demanda a partir da viagem
						DLG->DLG_QTDVIA += nQtd
						DLG->DLG_QTDENC -= nQtd
					Case nOper == 13 				//Em Transito sem integração com TMS
						DLG->DLG_QTDVIA += nQtd
						DLG->DLG_QTDPLN -= nQtd
					Case nOper == 14 				//Estorna em Transito sem integração com TMS ou exclusão de viagem com integração com TMS)
						DLG->DLG_QTDPLN += nQtd
						DLG->DLG_QTDVIA -= nQtd
					Case nOper == 15 				//Cancelamento da demanda
						DLG->DLG_QTDCAN += nQtd
						DLG->DLG_QTDVIA -= nQtd
					Case nOper == 16 				//Estorno cancelamento da demanda
						DLG->DLG_QTDVIA += nQtd
						DLG->DLG_QTDCAN -= nQtd
					Case nOper == 17 				//Bloqueio da demanda para documentos sem viagem
						DLG->DLG_QTDBLQ += nQtd
						DLG->DLG_QTDPRG -= nQtd
					Case nOper == 18 				//Desbloqueio da demanda para documentos sem viagem
						DLG->DLG_QTDPRG += nQtd
						DLG->DLG_QTDBLQ -= nQtd
					Case nOper == 19 				//Bloqueio da demanda para documentos com viagem
						DLG->DLG_QTDBLQ += nQtd
						DLG->DLG_QTDVIA -= nQtd
					Case nOper == 20 				//Desbloqueio da demanda para documentos com viagem
						DLG->DLG_QTDVIA += nQtd
						DLG->DLG_QTDBLQ -= nQtd
					Case nOper == 21 				//De reprocesso para documentos em viagem
						If DLG->(ColumnPos("DLG_QTDREP")) > 0
							DLG->DLG_QTDVIA += nQtd
							DLG->DLG_QTDREP -= nQtd
						EndIf
					Case nOper == 22 				//Estorno da operação de reprocesso para documentos em viagem
						If DLG->(ColumnPos("DLG_QTDREP")) > 0
							DLG->DLG_QTDREP += nQtd
							DLG->DLG_QTDVIA -= nQtd
						EndIf
					Case nOper == 23 				//De reprocesso para documentos sem viagem e com programação
						If DLG->(ColumnPos("DLG_QTDREP")) > 0
							DLG->DLG_QTDPRG += nQtd
							DLG->DLG_QTDREP -= nQtd
						EndIf
					Case nOper == 24 				//Estorno da operação de reprocesso para documentos sem viagem e com programação
						If DLG->(ColumnPos("DLG_QTDREP")) > 0
							DLG->DLG_QTDREP += nQtd
							DLG->DLG_QTDPRG -= nQtd
						EndIf
					Case nOper == 25 				//Encerramento da demanda a partir do reprocesso
						If DLG->(ColumnPos("DLG_QTDREP")) > 0
							DLG->DLG_QTDENC += nQtd
							DLG->DLG_QTDREP -= nQtd
						EndIf
					Case nOper == 26 				//Estorno do encerramento da demanda a partir do reprocesso
						If DLG->(ColumnPos("DLG_QTDREP")) > 0
							DLG->DLG_QTDREP += nQtd
							DLG->DLG_QTDENC -= nQtd
						EndIf							
					Case nOper == 27 				//Bloqueio de demanda a partir de documentos em reprocesso
						If DLG->(ColumnPos("DLG_QTDREP")) > 0
							DLG->DLG_QTDBLQ += nQtd
							DLG->DLG_QTDREP -= nQtd
						EndIf							
					Case nOper == 28 				//Envio para reprocesso a partir de demandas bloqueadas
						If DLG->(ColumnPos("DLG_QTDREP")) > 0
							DLG->DLG_QTDREP += nQtd
							DLG->DLG_QTDBLQ -= nQtd
						EndIf							
				EndCase
					
				MsUnlock("DLG")
								
				aRet := TMUpQtCDmd(cFilCrt, cCodCrt, nQtd, nOper) //Se atualizar a meta, atualiza o contrato.				
				
			Else
				aRet[1] := .F.
				aRet[2] := STR0027 + AllTrim(cCodCrt) + STR0028 + AllTrim(cCodGrd) //Não foi possível localizar meta para o contrato / , com grupo de região 

				If !Vazio(cTipVei)
					aRet[2] += STR0029 + AllTrim(cTipVei) //, tipo de veículo
				EndIf
				
				aRet[2] += STR0030 // e no período em que a data informada está contida, para atualizar a quantidade consumida.
			EndIf
			
			RestArea(aArea)
			
			TMUnLockDmd("DLG_" + cFilCrt + cCodCrt + cCodGrd + cTipVei + cSeqMeta)
		EndIf
		
	EndIf			

Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMUpQtCDmd
Realiza a soma ou subtração das quantidades do contrato de demanda.
@author wander.horongoso
@since 19/06/2018
@version 1.0
@return ${aRet}, array contendo 2 informações:
	aRet[1]: .T. se a operação foi executada com sucesso ou .F. se não foi.
	aRet[2]: mensagem de erro caso a operação não tenha sido executada com sucesso.
@param cFilial: filial do contrato de demanda.
@param cCod: código do contrato de demanda.
@param nQtd: quantidade a ser atualizada
@param nOper: indica qual a operação está sendo efetuada.
		1 = Inclusão de DEMANDA 
		2 = Exclusão de DEMANDA
		3 = Inclusão de PLANEJAMENTO DE DEMANDA
		4 = Exclusão de PLANEJAMENTO DE DEMANDA
		5 = Inclusão de PROGRAMAÇÃO DE CARGA
		6 = Exclusão de PROGRAMAÇÃO DE CARGA
		7 = Inclusão de VIAGEM
		8 = Exclusão de VIAGEM
		9 = Inclusão de RECUSA DE DEMANDA (Transportadora)
		10 = Inclusão de RECUSA DE DEMANDA (Cliente)
		11 = Inclusão do ENCERRAMENTO DA DEMANDA
		12 = Exclusão do ENCERRAMENTO DA DEMANDA
		Opções de finalização do processo de Demandas sem integração com o TMS:
		13 = Em Transito 
		14 = Estorna em Transito
		15 = Cancelamento de demanda
		16 = Estorno de cancelamento de demanda
		17 = Bloqueio de demanda a partir de documentos sem viagem
		18 = Desbloqueio de demanda a partir de documentos sem viagem
		19 = Bloqueio de demanda a partir de documentos com viagem
		20 = Desbloqueio de demanda a partir de documentos com viagem
		21 = De Reprocesso para documentos com viagem
		22 = Estorno da operação de reprocesso para documentos com viagem
		23 = De Reprocesso para documentos sem viagem e com programação
		24 = Estorno da operação de reprocesso para documentos sem viagem e com programação
		25 = Encerramento da demanda a partir do reprocesso
		26 = Estorno do encerramento da demanda a partir do reprocesso
		27 = Bloqueio de demanda a partir de documentos em reprocesso
		28 = Envio para reprocesso a partir de demandas bloqueadas
@type function
/*/
//-------------------------------------------------------------------------------------------------
Function TMUpQtCDmd(cFilCrt, cCodCrt, nQtd, nOper) 
Local aRet := {.T., ''}
Local aArea 

	If !Empty(cCodCrt)
		
		aRet := TMLockDmd("DL7_" + cFilCrt + cCodCrt)
		If aRet[1]
	
			aArea := DL7->(GetArea())
			DL7->(dbSetOrder(1))
			
			If DL7->(DbSeek(cFilCrt + cCodCrt))
				RecLock("DL7",.F.)
			
				Do Case
					Case nOper == 1 				//Inclusão de DEMANDA 
						DL7->DL7_QTDDEM += nQtd
					Case nOper == 2 				//Exclusão de DEMANDA
						DL7->DL7_QTDDEM -= nQtd
					Case nOper == 3 				//Inclusão de PLANEJAMENTO DE DEMANDA
						DL7->DL7_QTDPLN += nQtd
						DL7->DL7_QTDDEM -= nQtd
					Case nOper == 4 				//Exclusão de PLANEJAMENTO DE DEMANDA
						DL7->DL7_QTDPLN -= nQtd
						DL7->DL7_QTDDEM += nQtd
					Case nOper == 5 				//Inclusão de PROGRAMAÇÃO DE CARGA
						DL7->DL7_QTDPRG += nQtd
						DL7->DL7_QTDPLN -= nQtd
					Case nOper == 6 				//Exclusão de PROGRAMAÇÃO DE CARGA
						DL7->DL7_QTDPRG -= nQtd
						DL7->DL7_QTDPLN += nQtd
					Case nOper == 7 				//Inclusão de VIAGEM
						DL7->DL7_QTDVIA += nQtd
						DL7->DL7_QTDPRG -= nQtd
					Case nOper == 8 				//Exclusão de VIAGEM
						DL7->DL7_QTDVIA -= nQtd
						DL7->DL7_QTDPRG += nQtd
					Case nOper == 9 				//Inclusão de RECUSA DE DEMANDA (Trasnportadora)
						DL7->DL7_QTDREC += nQtd
						DL7->DL7_QTDDEM -= nQtd
					Case nOper == 10 				//Inclusão de RECUSA DE DEMANDA (Cliente)
						If DL7->DL7_RECUSA == "2" 
							If !IsInCallStack("T153RECPL")
								DL7->DL7_QTDDEM -= nQtd
							EndIf	
						Else
							DL7->DL7_QTDRCL += nQtd
							DL7->DL7_QTDDEM -= nQtd						
						EndIf								
					Case nOper == 11 				//Encerramento da demanda
						DL7->DL7_QTDVIA -= nQtd
						DL7->DL7_QTDENC += nQtd
					Case nOper == 12 				//Estorno do encerramento da demanda
						DL7->DL7_QTDVIA += nQtd
						DL7->DL7_QTDENC -= nQtd
					Case nOper == 13 				//Em Transito sem integração com TMS
						DL7->DL7_QTDVIA += nQtd
						DL7->DL7_QTDPLN -= nQtd
					Case nOper == 14 				//Estorna em Transito sem integração com TMS
						DL7->DL7_QTDPLN += nQtd
						DL7->DL7_QTDVIA -= nQtd
					Case nOper == 15 				//Cancelamento da demanda
						DL7->DL7_QTDCAN += nQtd
						DL7->DL7_QTDVIA -= nQtd
					Case nOper == 16 				//Estorno cancelamento da demanda
						DL7->DL7_QTDVIA += nQtd
						DL7->DL7_QTDCAN -= nQtd
					Case nOper == 17 				//Bloqueio da demanda para documentos sem viagem
						DL7->DL7_QTDBLQ += nQtd
						DL7->DL7_QTDPRG -= nQtd
					Case nOper == 18 				//Desbloqueio da demanda para documentos sem viagem
						DL7->DL7_QTDPRG += nQtd
						DL7->DL7_QTDBLQ -= nQtd
					Case nOper == 19 				//Bloqueio da demanda para documentos com viagem
						DL7->DL7_QTDBLQ += nQtd
						DL7->DL7_QTDVIA -= nQtd
					Case nOper == 20 				//Desbloqueio da demanda para documentos com viagem
						DL7->DL7_QTDVIA += nQtd
						DL7->DL7_QTDBLQ -= nQtd
					Case nOper == 21 				//Reprocesso para documentos com viagem
						If DL7->(ColumnPos("DL7_QTDREP")) > 0	
							DL7->DL7_QTDVIA += nQtd
							DL7->DL7_QTDREP -= nQtd
						EndIf 
					Case nOper == 22 				//Estorno da operação de reprocesso para documentos com viagem
						If DL7->(ColumnPos("DL7_QTDREP")) > 0
							DL7->DL7_QTDREP += nQtd
							DL7->DL7_QTDVIA -= nQtd
						EndIf
					Case nOper == 23 				//Reprocesso para documentos sem viagem e com programação
						If DL7->(ColumnPos("DL7_QTDREP")) > 0	
							DL7->DL7_QTDPRG += nQtd
							DL7->DL7_QTDREP -= nQtd
						EndIf 
					Case nOper == 24 				//Estorno da operação de reprocesso para documentos sem viagem e com programação
						If DL7->(ColumnPos("DL7_QTDREP")) > 0
							DL7->DL7_QTDREP += nQtd
							DL7->DL7_QTDPRG -= nQtd
						EndIf
					Case nOper == 25 				//Encerramento da demanda a partir do reprocesso
						If DL7->(ColumnPos("DL7_QTDREP")) > 0
							DL7->DL7_QTDENC += nQtd
							DL7->DL7_QTDREP -= nQtd
						EndIf
					Case nOper == 26 				//Estorno do encerramento da demanda a partir do reprocesso
						If DL7->(ColumnPos("DL7_QTDREP")) > 0
							DL7->DL7_QTDREP += nQtd
							DL7->DL7_QTDENC -= nQtd
						EndIf 													
					Case nOper == 27 				//Bloqueio de demanda a partir de documentos em reprocesso
						If DL7->(ColumnPos("DL7_QTDREP")) > 0
							DL7->DL7_QTDBLQ += nQtd
							DL7->DL7_QTDREP -= nQtd
						EndIf							
					Case nOper == 28 				//Envio para reprocesso a partir de demandas bloqueadas
						If DL7->(ColumnPos("DL7_QTDREP")) > 0
							DL7->DL7_QTDREP += nQtd
							DL7->DL7_QTDBLQ -= nQtd
						EndIf							
				EndCase
					
				MsUnlock("DL7")
			EndIf
			
			RestArea(aArea)
			
			TMUnLockDmd("DL7_" + cFilCrt + cCodCrt)
		EndIf		
				
	EndIf			
	
Return aRet

/*/{Protheus.doc} TmIncDem
Inclui ou fraciona uma demanda.
@Param cCodCrt: Codigo do contrato
@param cCodDem: Código da demanda original (Quando fracionamento)
@param cSeqDem: Sequencia da demanda original (Quando fracionamento)
@param aQtdDem: Array com todas as quantidades das demandas que deverão ser geradas
@param aGridReg: Array com todas as regioes de origem e destino da demanda
@param Ex.: aGridReg,{"1=Origem/2=Destino","Cod Reg.",Qtd.,"Prevista 1=Sim/2=Adicional"}) -  aGridReg,{"1","SC",50,"1"}) 
@param nOpc: 1- Inclusao de demanda a partir do contrato / 2 - Fracionamento de demanda
@type function
@author Ruan Ricardo Salvador
@version 12.1.17
@since 18/04/2018
/*/
Function TmIncDem(cCodCrt,cCodDem,cSeqDem,aQtdDem,aGridReg,nOpc,oModel,cCodCli,cLojCli,cUnidDmd)
	Local lRet 	  	:= .T.
	Local aAreaDL7	:= DL7->(GetArea())
	Local aAreaDL8	:= DL8->(GetArea())
	Local cCod 	  	:= ''
	Local cMsg 	  	:= ''
	Local cTemp	  	:= GetNextAlias()
	Local cQuery	:= ""
	Local cGridReg	:= ""
	Local oModelDL8	:= Nil
	Local oModelMDL8:= Nil
	Local oModelMDL7:= Nil
	Local nContOri	:= 01
	Local nContDes	:= 01
	Local nQtdTot 	:= 0
	Local nX		:= 0
	Local nY		:= 0
	Local nZ		:= 0
	Local nSeq		:= 0
	Local nIndex	:= DL8->(IndexOrd())

	Default cCodCrt := ''
	Default cCodDem := ''
	Default cSeqDem := ''
	Default aQtdDem := {}
	Default aGridReg:= {}
	Default nOpc 	:= 0
	Default oModel	:= Nil

	BEGIN TRANSACTION
		If nOpc == 1
			DL7->(DbSetOrder(1))
			If !DL7->(DbSeek(xFilial('DL7')+cCodCrt))
				Help( ,, 'HELP',, STR0016, 1, 0 ) //"Contrato de Demanda não encontrado"
				lRet := .F.
			EndIf
		EndIf	

		If lRet 
			oModelDL8 := FWLoadModel('TMSA153A')
			oModelMDL7:= oModel:GetModel('MASTER_DL7')
			oModelORI := oModelDL8:GetModel('GRID_ORI')
			oModelMDL8:= oModelDL8:GetModel('MASTER_DL8')
			
			If nOpc == 1
				oModelDL8:SetOperation(MODEL_OPERATION_INSERT)
				oModelDL8:GetModel('GRID_DES'):GetStruct():SetProperty('*', MODEL_FIELD_OBRIGAT,.F.)
				oModelDL8:Activate()
				oModelMDL8:GetStruct():SetProperty("DL8_TIPVEI", MODEL_FIELD_WHEN,{||.T.})
				oModelMDL8:GetStruct():SetProperty("DL8_CODGRD", MODEL_FIELD_WHEN,{||.T.})
				oModelMDL8:GetStruct():SetProperty('DL8_CODGRD', MODEL_FIELD_VALID,{||TM153AVal("M->DL8_CODGRD")})
			EndIf
			oModelMDL8:GetStruct():SetProperty("DL8_QTD", MODEL_FIELD_WHEN,{||.T.})
			For nX := 1 to Len(aQtdDem) 
					oModelMDL8:SetValue("DL8_FILIAL",xFilial("DL8"))
					oModelMDL8:LoadValue("DL8_CRTDMD",cCodCrt)
					oModelMDL8:LoadValue("DL8_CLIDEV",cCodCli)
					oModelMDL8:LoadValue("DL8_LOJDEV",cLojCli)
					oModelMDL8:LoadValue("DL8_UM",cUnidDmd)
					If !Empty(oModel)
						oModelMDL8:LoadValue("DL8_FILEXE",oModelMDL7:GetValue("DL7_FILEXE"))
						oModelMDL8:LoadValue("DL8_CODGRD",oModelMDL7:GetValue("DLE_CODGRD"))
						
						If !Empty(oModelMDL7:GetValue("DL7_TIPVEI"))
							oModelMDL8:LoadValue("DL8_TIPVEI",oModelMDL7:GetValue("DL7_TIPVEI"))
						EndIf
						oModelMDL8:LoadValue("DL8_DATPRV",oModelMDL7:GetValue("DL7_DTPREV"))
						oModelMDL8:LoadValue("DL8_HORPRV",Alltrim(oModelMDL7:GetValue("DL7_HRPREV")))
					EndIf
					
					oModelMDL8:LoadValue("DL8_CLIDEV",Iif(nOpc == 1,DL7->DL7_CLIDEV,DL8->DL8_CLIDEV))
					oModelMDL8:LoadValue("DL8_LOJDEV",Iif(nOpc == 1,cLojCli,DL8->DL8_LOJDEV))
					oModelMDL8:LoadValue("DL8_UM",Iif(nOpc == 1,DL7->DL7_UM,DL8->DL8_UM))
					oModelMDL8:GetStruct():SetProperty("DL8_QTD", MODEL_FIELD_WHEN,{||.T.})
					oModelMDL8:LoadValue("DL8_QTD",aQtdDem[nX])													
					oModelMDL8:LoadValue("DL8_STATUS",'1')

				If !Empty(cCodCrt)
					ClearGrid(oModelDL8, 'GRID_ORI')
					ClearGrid(oModelDL8, 'GRID_DES')
					If oModelDL8:GetModel('GRID_ORI'):IsDeleted()
						oModelDL8:GetModel('GRID_ORI'):UnDeleteLine()
					EndIf
					If oModelDL8:GetModel('GRID_DES'):IsDeleted()
						oModelDL8:GetModel('GRID_DES'):UnDeleteLine()
					EndIf
				EndIf 
					For nY:= 1 to Len(aGridReg)
						IF aGridReg[nY,1] == "1"
							cGridReg := "GRID_ORI"
							If nContOri > 01
								oModelDL8:GetModel(cGridReg):AddLine()
							EndIf
							oModelDL8:LoadValue(cGridReg,"DLA_FILIAL",xFilial("DLA"))
							oModelDL8:LoadValue(cGridReg,"DLA_CODDMD",M->DL8_COD)
							oModelDL8:LoadValue(cGridReg,"DLA_SEQDMD",M->DL8_SEQ)
							oModelDL8:LoadValue(cGridReg,"DLA_SEQREG",StrZero(nContOri,TamSx3("DLA_SEQREG")[1])) 
							oModelDL8:LoadValue(cGridReg,"DLA_CODREG",aGridReg[nY,2])
							oModelDL8:LoadValue(cGridReg,"DLA_DTPREV",aGridReg[nY,5])
							oModelDL8:LoadValue(cGridReg,"DLA_HRPREV",aGridReg[nY,6])
							
							oModelDL8:LoadValue(cGridReg,"DLA_CODCLI",aGridReg[nY,7])	
							oModelDL8:LoadValue(cGridReg,"DLA_LOJA", aGridReg[nY,8])	
	
							If cUnidDmd == '1'
								oModelDL8:LoadValue(cGridReg,"DLA_QTD" ,aGridReg[nY,3])
							EndIf					
							oModelDL8:LoadValue(cGridReg,"DLA_PREVIS",aGridReg[nY,4])
						Else
							cGridReg := "GRID_DES"
							If nContDes > 01
								oModelDL8:GetModel(cGridReg):AddLine()
							EndIf
							oModelDL8:LoadValue(cGridReg,"DLL_FILIAL",xFilial("DLL"))
							oModelDL8:LoadValue(cGridReg,"DLL_CODDMD",M->DL8_COD)
							oModelDL8:LoadValue(cGridReg,"DLL_SEQDMD",M->DL8_SEQ)
							oModelDL8:LoadValue(cGridReg,"DLL_SEQREG",StrZero(nContDes,TamSx3("DLL_SEQREG")[1])) 
							oModelDL8:LoadValue(cGridReg,"DLL_CODREG",aGridReg[nY,2])
							oModelDL8:LoadValue(cGridReg,"DLL_DTPREV",aGridReg[nY,4])
							oModelDL8:LoadValue(cGridReg,"DLL_HRPREV",aGridReg[nY,5])
							oModelDL8:LoadValue(cGridReg,"DLL_PREVIS",aGridReg[nY,3])
						EndIf
						
						IiF(cGridReg == "GRID_ORI",nContOri++,nContDes++)
					Next nY
				nContOri := 01
				nContDes := 01
				
				oModelMDL8:LoadValue("DL8_MARK",'')

				If oModelDL8:VldData() 
					If oModelDL8:CommitData()
						oModelDL8:DeActivate()
						//grava o MEMO separadamente pois estava dando problema na sequencia dos codigos
							
						oModelDL8 := FWLoadModel('TMSA153A')
						oModelDL8:SetOperation(MODEL_OPERATION_UPDATE)
						oModelDL8:Activate()
							
						If !Empty(cMsg)
							cCod := ''
							cCod:= MSMM(cCod,,,cMsg,1,,,"DL8","DL8_CODOBS")
							oModelDL8:LoadValue("MASTER_DL8","DL8_CODOBS",cCod)
						Endif
						If oModelDL8:VldData()        
							oModelDL8:CommitData()
						Endif							
					Else
						lRet := .F.
						If !Empty(oModel)
							FwClearHLP()
							oModel:SetErrorMessage (,,,,,oModelDL8:GetErrorMessage()[6])
						EndIf
						DisarmTransaction()
						Break
					EndIf
				Else
					If !Empty(oModel)
						FwClearHLP()
						oModel:SetErrorMessage (,,,,,oModelDL8:GetErrorMessage()[6])
					EndIf
					lRet := .F.  
					DisarmTransaction()
					Break
				EndIf 
				oModelDL8:DeActivate()
				
				//No ponto onde é chamado o Activate do Model "TMSA153A", são efetuados os Locks. Porém, antes não era feito nenhum Unlock. 
				//Este trecho visa efetuar o Unlock das Demandas geradas, de modo que outros usuários possam utilizá-las. 
				If !Empty(M->DL8_COD) .And. !Empty(M->DL8_SEQ)
					TMUnLockDmd('TMSA153A_' + xFilial("DL8") + M->DL8_COD + M->DL8_SEQ,.T.)
				EndIf
			Next nX
		EndIf		
	END TRANSACTION
	
	RestArea( aAreaDL7 )
	RestArea( aAreaDL8 )	
	DL8->(DbSetOrder(nIndex))
Return lRet

/*/{Protheus.doc} TmIncTrk
Realiza a criação de um registro de tracking da demanda.
@param cTipDoc:   Tipo do documento 1 - Contrato, 2 - Demanda, 3 - Planejamento
@param cFilDoc:   Filial do documento
@param cCodDoc:   Código documento
@param cSeq:	  Sequência. Deve ser informado para tabelas com chave contendo sequencia (ex: DL8)
@param cDocPai:   Código documento pai do cCodDoc
@param cTipOpe:   Tipo de operação de tracking
@param cCodMotOpe:Código do motivo da operação. Deve ser informado quando o tracking for de recusa de planejamento ou de demanda, ou ainda suspensão ou retomada de contrato.
@param cObs: 	  Texto contendo as linhas da observação
@param cTpRecusa: Tipo da recusa : 1 - Cliente, 2-Transportadora, 3-Motorista
@param cCodProg:  Código da programação de carregamento 
@param cCodViagem:Código da viagem gerada a partir da programação de carregamento. 
@type function
@author Wander Horongoso
@version 12.1.17
@since 19/04/2018
/*/

Function TmIncTrk(cTipDoc, cFilDoc, cCodDoc, cSeqDoc, cDocPai, cTipOpe, cCodMotOpe, cObs, cTpRecusa, cCodProg, cCodViagem)
Local lRet 		:= .T.
Local oModelDLB := Nil
Local aArea 	:= {}
Local aAreaDA3	:= {}
Local cMsgErro	:= ''
Local lMmr		:= .F.
Local cQuery	:= {}
Local cTemp		:= GetNextAlias()

Default cCodMotOpe := ''
Default cTpRecusa  := ''
Default cSeqDoc	   := ''
Default cDocPai	   := ''
Default cObs 	   := ''

SaveInter()

	Do Case 
		Case cTipDoc == "1" //Contrato 
			aArea := DL7->(GetArea())
			DL7->(DbClearFilter()) //Comando para limpar o filtro da tela principal. Ao efetuar o RestArea no fim desta função, o filtro volta.
			DL7->(DbCloseArea())
			DL7->(DbSetOrder(1))
			
			If !DL7->(DbSeek(cFilDoc+cCodDoc))
				cMsgErro := 'Contrato ' + AllTrim(cCodDoc) + iIf(!Empty(cFilDoc), ' da filial ' + AllTrim(cFilDoc), '') + ' não encontrado.'
				lRet := .F.
			EndIf		
		
		Case cTipDoc == "2" //Demanda 
			aArea := DL8->(GetArea())
			DL8->(DbClearFilter()) //Comando para limpar o filtro da tela principal. Ao efetuar o RestArea no fim desta função, o filtro volta.
			DL8->(DbCloseArea())
			DL8->(DbSetOrder(1))
			
			If !DL8->(DbSeek(cFilDoc+cCodDoc+cSeqDoc))
				cMsgErro := 'Demanda ' + AllTrim(cCodDoc) + '/' + AllTrim(cSeqDoc) + iIf(!Empty(cFilDoc), ' da filial ' + AllTrim(cFilDoc), '') + ' não encontrada.'
				lRet := .F.
			EndIf
		
		Case cTipDoc == "3" //Planejamento 
			aArea := DL9->(GetArea())
			DL9->(DbClearFilter()) //Comando para limpar o filtro da tela principal. Ao efetuar o RestArea no fim desta função, o filtro volta.
			DL9->(DbCloseArea())
			DL9->(DbSetOrder(1))
			
			If !DL9->(dbSeek(cFilDoc+cCodDoc))
				cMsgErro := 'Planejamento ' + AllTrim(cCodDoc) + iIf(!Empty(cFilDoc), ' da filial ' + AllTrim(cFilDoc), '') + ' não encontrado.'
				lRet := .F.
			EndIf
		Otherwise
			cMsgErro := 'Tabela não definida para o código ' + cTipDoc + '.'
			lRet := .F.
	EndCase
		
	If !lRet		
		Help( ,, 'HELP',,STR0008 + cMsgErro, 1, 0 ) //"Erro ao gravar o tracking: "
		lRet := .F.
	Else

		oModelDLB := FWLoadModel('TMSA154')

		oModelDLB:SetOperation(MODEL_OPERATION_INSERT)
		oModelDLB:Activate()   
		oModelDLB:SetValue("MASTER_DLB","DLB_FILIAL",xFilial("DLB"))
		oModelDLB:SetValue("MASTER_DLB","DLB_TIPOPE",cTipOpe)
		If !Empty(cTpRecusa)
			oModelDLB:SetValue("MASTER_DLB","DLB_TPREC",cTpRecusa)
		EndIF
		oModelDLB:SetValue("MASTER_DLB","DLB_TIPDOC",cTipDoc)
		oModelDLB:SetValue("MASTER_DLB","DLB_CODMOP",cCodMotOpe)
		oModelDLB:SetValue("MASTER_DLB","DLB_CODUSR",__cUserId)
		If !Empty(cCodProg)
			oModelDLB:SetValue("MASTER_DLB","DLB_CODPRG",cCodProg)
		EndIF
		If !Empty(cCodViagem)
			oModelDLB:SetValue("MASTER_DLB","DLB_VIAGEM",cCodViagem)
		EndIF
		
		Do Case
			Case cTipDoc == "1" //Contrato
				oModelDLB:SetValue("MASTER_DLB","DLB_CRTDMD",DL7->DL7_COD)
				oModelDLB:SetValue("MASTER_DLB","DLB_TIPDOC","1")
				oModelDLB:SetValue("MASTER_DLB","DLB_CLIDEV",DL7->DL7_CLIDEV)
				oModelDLB:SetValue("MASTER_DLB","DLB_LOJDEV",DL7->DL7_LOJDEV)
				oModelDLB:SetValue("MASTER_DLB","DLB_QTD",DL7->DL7_QTDTOT)
				oModelDLB:SetValue("MASTER_DLB","DLB_UM",DL7->DL7_UM)
				
				oModelDLB:SetValue("MASTER_DLB","DLB_ABRANG",DL7->DL7_ABRANG)				

				cQuery:= " SELECT MAX(DLB_SEQTRK) DLB_SEQ "
				cQuery+= " FROM "+RetSqlName('DLB')+ " DLB "
				cQuery+= " WHERE DLB.DLB_FILIAL = '" + xFilial('DLB') + "'"
				cQuery+= " AND DLB.DLB_CRTDMD = '"+ DL7->DL7_COD +"'"
				cQuery+= " AND DLB.D_E_L_E_T_ = '' "
				
				cQuery := ChangeQuery( cQuery )	
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
			
				oModelDLB:SetValue("MASTER_DLB","DLB_SEQTRK",Soma1((cTemp)->DLB_SEQ))
				
				(cTemp)->(DbCloseArea())				
				
			Case cTipDoc == "2" //Demanda
				oModelDLB:SetValue("MASTER_DLB","DLB_CODDMD",DL8->DL8_COD)
				oModelDLB:SetValue("MASTER_DLB","DLB_SEQDMD",DL8->DL8_SEQ)
				oModelDLB:SetValue("MASTER_DLB","DLB_CRTDMD",DL8->DL8_CRTDMD)
				oModelDLB:SetValue("MASTER_DLB","DLB_TIPDOC","2")
				oModelDLB:SetValue("MASTER_DLB","DLB_CLIDEV",DL8->DL8_CLIDEV)
				oModelDLB:SetValue("MASTER_DLB","DLB_LOJDEV",DL8->DL8_LOJDEV)
				oModelDLB:SetValue("MASTER_DLB","DLB_QTD",DL8->DL8_QTD)
				oModelDLB:SetValue("MASTER_DLB","DLB_UM",DL8->DL8_UM)
				oModelDLB:SetValue("MASTER_DLB","DLB_CODPLN",IIf(Empty(cDocPai),DL8->DL8_PLNDMD, cDocPai))
				If cTipOpe == 'P' .Or. cTipOpe == 'D'
					
					aAreaDA3 := DA3->(GetArea())

					If IsInCallStack('T153BNovo')
						lMmr := .T.
					EndIf
					If !lMMr
						aAreaDL9 := DL9->(GetArea())
						DL9->(DbClearFilter())
						DL9->(DbSetOrder(1))		
					EndIf
					If IIF(!lMMr,DL9->(dbSeek(xFilial('DL9')+cDocPai)),.T.)
						DA3->(DbSetOrder(1))
						oModelDLB:SetValue("MASTER_DLB","DLB_CODVEI",IIF(lMmr, M->DL9_CODVEI, DL9->DL9_CODVEI))				
						oModelDLB:SetValue("MASTER_DLB","DLB_CODRB1",IIF(lMmr, M->DL9_CODRB1, DL9->DL9_CODRB1))
						oModelDLB:SetValue("MASTER_DLB","DLB_CODRB2",IIF(lMmr, M->DL9_CODRB2, DL9->DL9_CODRB2))
						oModelDLB:SetValue("MASTER_DLB","DLB_CODRB3",IIF(lMmr, M->DL9_CODRB3, DL9->DL9_CODRB3))
						oModelDLB:SetValue("MASTER_DLB","DLB_CODMOT",IIF(lMmr, M->DL9_CODMOT, DL9->DL9_CODMOT))
						
						If DA3->(dbSeek(xFilial("DA3")+IIF(lMmr, M->DL9_CODVEI, DL9->DL9_CODVEI)))
							oModelDLB:SetValue("MASTER_DLB","DLB_CODFOR",DA3->DA3_CODFOR)					
							oModelDLB:SetValue("MASTER_DLB","DLB_LOJFOR",DA3->DA3_LOJFOR)
						EndIf
					EndIf
					RestArea(aAreaDA3)
					IF !lMMr
						RestArea(aAreaDL9)
					EndIF
				EndIf
				oModelDLB:SetValue("MASTER_DLB","DLB_FILGER",DL8->DL8_FILGER)
				oModelDLB:SetValue("MASTER_DLB","DLB_FILEXE",DL8->DL8_FILEXE)				

				cQuery:= " SELECT MAX(DLB_SEQTRK) DLB_SEQ "
				cQuery+= " FROM "+RetSqlName('DLB')+ " DLB "
				cQuery+= " WHERE DLB.DLB_FILIAL = '" + xFilial('DLB') + "'"
				cQuery+= " AND DLB.DLB_CODDMD = '"+ cCodDoc +"'"
				cQuery+= " AND DLB.DLB_SEQDMD = '"+ cSeqDoc +"'"
				cQuery+= " AND DLB.D_E_L_E_T_ = '' "
				
				cQuery := ChangeQuery( cQuery )	
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
			
				oModelDLB:SetValue("MASTER_DLB","DLB_SEQTRK",Soma1((cTemp)->DLB_SEQ))
				
				(cTemp)->(DbCloseArea())				

				If !Empty(DL8->DL8_CRTDMD)

					cQuery:= " SELECT DL7_ABRANG "
					cQuery+= " FROM "+RetSqlName('DL7')+ " DL7 "
					cQuery+= " WHERE DL7.DL7_FILIAL = '" + xFilial('DL7') + "'"
					cQuery+= " AND DL7.DL7_COD = '"+ DL8->DL8_CRTDMD +"'"
					cQuery+= " AND DL7.D_E_L_E_T_ = '' "

					cQuery := ChangeQuery( cQuery )	
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )

					oModelDLB:SetValue("MASTER_DLB","DLB_ABRANG",(cTemp)->DL7_ABRANG)

					(cTemp)->(DbCloseArea())

				EndIf



			Case cTipDoc == "3" //Planejamento
				oModelDLB:SetValue("MASTER_DLB","DLB_CODPLN",DL9->DL9_COD)
				oModelDLB:SetValue("MASTER_DLB","DLB_TIPDOC","3")
				oModelDLB:SetValue("MASTER_DLB","DLB_CODVEI",DL9->DL9_CODVEI)				
				oModelDLB:SetValue("MASTER_DLB","DLB_CODRB1",DL9->DL9_CODRB1)
				oModelDLB:SetValue("MASTER_DLB","DLB_CODRB2",DL9->DL9_CODRB2)
				oModelDLB:SetValue("MASTER_DLB","DLB_CODRB3",DL9->DL9_CODRB3)
				oModelDLB:SetValue("MASTER_DLB","DLB_CODMOT",DL9->DL9_CODMOT)
				oModelDLB:SetValue("MASTER_DLB","DLB_FILGER",DL9->DL9_FILGER)
				oModelDLB:SetValue("MASTER_DLB","DLB_FILEXE",DL9->DL9_FILEXE)
				
				//Grava código do proprietário vinculado ao veículo tracionador do planejamento
				aAreaDA3 := DA3->(GetArea())
				DA3->(dbSetOrder(1))
				If DA3->(dbSeek(xFilial("DA3")+DL9->DL9_CODVEI))
					oModelDLB:SetValue("MASTER_DLB","DLB_CODFOR",DA3->DA3_CODFOR)					
					oModelDLB:SetValue("MASTER_DLB","DLB_LOJFOR",DA3->DA3_LOJFOR)
				EndIf
				RestArea(aAreaDA3)
				
				cQuery:= " SELECT MAX(DLB_SEQTRK) DLB_SEQ "
				cQuery+= " FROM "+RetSqlName('DLB')+ " DLB "
				cQuery+= " WHERE DLB.DLB_FILIAL = '" + xFilial('DLB') + "'"
				cQuery+= " AND DLB.DLB_CODPLN = '"+ DL9->DL9_COD +"'"
				cQuery+= " AND DLB.DLB_TIPDOC = '3' "
				cQuery+= " AND DLB.D_E_L_E_T_ = '' "
				
				cQuery := ChangeQuery( cQuery )	
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
			
				oModelDLB:SetValue("MASTER_DLB","DLB_SEQTRK",Soma1((cTemp)->DLB_SEQ))
				
				(cTemp)->(DbCloseArea())				
		EndCase
		
		//Após validar gravar o model, efetua a gravação da observação na tabela SYP e também o código dessa observação na tabela DLB 
		
		If oModelDLB:VldData()        
			oModelDLB:CommitData()
			
			If Len(cObs) > 0
				MSMM(DLB->DLB_CODOBS,,,cObs,1,,,"DLB","DLB_CODOBS")
			EndIf
		Else
			Help( ,, 'HELP',,STR0008 + oModelDLB:GetErrorMessage(), 1, 0 ) //"Erro ao gravar o tracking: "
			lRet := .F.
		EndIf  
		
		oModelDLB:DeActivate()
	EndIf							
							
	If aArea <> nil .And. Len(aArea) > 0
		RestArea(aArea)
	EndIf	

RestInter()

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TMSMotDmd()
Função da demanda que monta tela de motivo e retorna código do motivo e o conteúdo da observação.
Usado para recusa, encerramento e outras operações em contrato, demanda ou planejamento.
@author  Gustavo Krug
@since   20/04/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TMSMotDmd(cUtiTpRec) 
Local oEditor := nil
Local oDlMemo := nil
Local cStrBMemo := ""
Local aRet := {}
Local bOk     := {||IIF(!Empty(aRet := VldDescMem(cMotivo,cStrBMemo,cCombo) ) ,oDlMemo:End(),)}
Local bCancel := {|| oDlMemo:End() }
Local cMotivo := Space(2)
Local cDescMemo := Space(30)
Local cCombo := '' //Variavel que recebe valor do combo
Local aCombo := {}
Local cPosTxtMM := 72
Local cPosMemo := 80
Default cUtiTpRec := '0' //Utiliza tipo de Recusa : 0 - Não, 1 - Recusa Cliente e Transportadora, 2 - Recusa Cliente e Motorista


	If cUtiTpRec == '1'
		aCombo := {STR0033,STR0034} //Combo box 1=Transportadora, 2=Cliente		
	EndIF
	If cUtiTpRec == '2'
		aCombo := {STR0035,STR0034} //Combo box 1=Motorista, 2=Cliente
	EndIF
	
	If Empty(Alias())
		dbSelectArea("SB1")
	EndIf

    DEFINE MSDIALOG oDlMemo FROM 180,180 TO 620,700 TITLE STR0003 PIXEL 
    
        @ 042,030 SAY STR0004 Size 80,10 OF oDlMemo PIXEL	//Motivo
        @ 050,030 MSGET oMotivo VAR cMotivo F3 "NM" Size 30,10 OF oDlMemo VALID (VldMotivo(cMotivo)) PIXEL
        //--Help do campo
        oMotivo:bHelp := {||ShowHelpCpo(STR0039,{STR0040+Chr(13)+Chr(10),STR0041},2)} //"MOTIVO"#"Deverá ser informado o motivo."#"Para verificar os motivos existentes, utilize a tecla F3. A tabela de motivos poderá ser alterado no módulo Configurador (Tabela NM)"
                
        @ 042,080 SAY STR0005 Size 80,10 OF oDlMemo PIXEL	//Descricao
        @ 050,080 MSGET cDescMemo := Tabela("NM",cMotivo,.F.) Size 154,10 OF oDlMemo WHEN .F. PIXEL
        
        If !((cUtiTpRec) == '0')
        	oCombo1 := TComboBox():New(70,30,{|u|If(PCount()>0,cCombo:=u,cCombo)},aCombo,204,14,oDlMemo,,,,,,.T.,,,,,,,,,'cCombo',STR0032,1) //Tipo de meta
        	cPosTxtMM := 102
        	cPosMemo  := 110
        EndIF        
        
        @ cPosTxtMM,30 SAY STR0036 Size 80,10 OF oDlMemo PIXEL
        oEditor := tMultiget():new(cPosMemo,30,{|x| If( pCount()>0,cStrBMemo := x, cStrBMemo)},oDlMemo,203,100,,,,,,.T.)
        //Help do campo
        oEditor:bHelp := {||ShowHelpCpo(STR0042,{STR0043},2)} //"OBSERVACAO"#"Deverá ser informado uma observação para o motivo selecionado."

    ACTIVATE MSDIALOG oDlMemo CENTERED ON INIT EnchoiceBar(oDlMemo, bOk, bCancel)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldDescMem()
Função que valida se a observação foi informada.
@author  Natalia Maria Neves
@since   25/12/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------

Static Function VldDescMem(cMotivo,cStrBMemo,cCombo)
Local aRet := {}    

	If Empty(AllTrim(StrTran(cStrBMemo,CHR(13)+CHR(10),"")))
		MsgInfo(STR0046,STR0006) // Informe a observação. // Aviso
	Else
		AAdd(aRet, cMotivo)
		AAdd(aRet,cStrBMemo)
		AAdd(aRet,cCombo)
	EndIf

Return aRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} VldMotivo()
Função que valida se o motivo informado é valido.
@author  Gustavo Krug
@since   20/04/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------

Static Function VldMotivo(cMotivo)
Local lRet := .T.    
	If Empty(cMotivo)
		lRet  := .F.
		MsgInfo(STR0045,STR0006) // Informe o motivo. // Aviso
	Else
		lRet := !Empty(Tabela("NM",cMotivo,.F.))
		If !lRet
			MsgInfo(STR0007,STR0006) //Motivo inexistente. // Aviso
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} T153RecDmd()
Função para efetuar Recusa de Demanda
@author  Gustavo Krug
@since   23/04/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function T153RecDmd()
Local aAreaDL8	:= DL8->(GetArea()) 
Local aRet		:= {}
Local aDmd 		:= {}
Local cMsgErro	:= ''
Local cMarkDMD	:= ""
Local nCont 	:= 1
Local nIndex	:= DL8->(IndexOrd())
Local lRet 		:= .T.
Local oModelDL8	:= Nil
Local lYesno := .T.
Local lBlind := IsBlind()

Default  aJustIf := {}

	If !lBlind
		cMarkDMD := oBrwDeman:Mark()
	Else
		cMarkDMD := "kj"
	EndIf

	DL8->(DbSetOrder(2))
	//Refresh no browse Demanda
	nRfDMD := 1
	
	If DL8->(dbSeek(xFilial('DL8')+cMarkDMD))
		While DL8->(!Eof()) .And. Empty(DL8->DL8_PLNDMD) .And. DL8->DL8_MARK == cMarkDMD
			If DL8->DL8_STATUS == '2' .Or. !Empty(DL8->DL8_PLNDMD) //A demanda não pode estar planejada	
				Help( ,, STR0006,, STR0012 + DL8->DL8_COD + STR0013 + DL8->DL8_PLNDMD , 1, 0 ) //"Demanda " + DL8->DL8_COD + " possui planejamento de demanda"
				lRet := .F.
			Else
				aAdd(aDmd,DL8->(RECNO()))
			EndIf
			DL8->(dbSkip())
		EndDo 
	Else 
		Help( ,, 'HELP',, STR0044, 1, 0 ) //Selecionar ao menos uma Demanda.	
		lRet := .F.
	EndIf

	If lRet	
		If !lBlind
			lYesno := MSGYESNO(STR0009,STR0010) //"Deseja realmente encerrar o contrato? " "Confirmação"
		EndIf
		If lYesno
			If !lBlind
				aJustIf:= TMSMotDmd('1') //chamar tela de justIficativa
			EndIf
			If !Empty(aJustIf)
				BEGIN TRANSACTION
					While nCont <= Len(aDmd)
						DL8->(dbGoTo(aDmd[nCont]))
						//Retorna qtd da demanda para a meta/contrato
						IF aJustIf[3] == '1'//Recusa Transportadora
							aRet := TMUpQtMDmd(xFilial("DLG"), DL8->DL8_CRTDMD,DL8->DL8_CODGRD,PADR(DL8->DL8_TIPVEI,TamSx3('DL8_TIPVEI')[1]),DL8->DL8_SEQMET,DL8->DL8_QTD, 9)
						Else						
							aRet := TMUpQtMDmd(xFilial("DLG"), DL8->DL8_CRTDMD,DL8->DL8_CODGRD,PADR(DL8->DL8_TIPVEI,TamSx3('DL8_TIPVEI')[1]),DL8->DL8_SEQMET,DL8->DL8_QTD, 10)
						EndIF
						
						If !aRet[1]
							lRet:= .F.
							cMsgErro := aRet[2]
						EndIF				
						//Grava Tracking
						If lRet
							IF aJustIf[3] == '1'//Recusa Transportadora
								lRet := TmIncTrk('2', DL8->DL8_FILIAL, DL8->DL8_COD, DL8->DL8_SEQ,, 'U', aJustif[1], aJustif[2],'2')
							Else							
								lRet := TmIncTrk('2', DL8->DL8_FILIAL, DL8->DL8_COD, DL8->DL8_SEQ,, 'U', aJustif[1], aJustif[2],'1')
							EndIF
						EndIF
						
						If lRet
							oModelDL8 := FWLoadModel('TMSA153A')
							oModelDL8:SetOperation(MODEL_OPERATION_UPDATE)
							oModelDL8:Activate()
							oModelDL8:SetValue("MASTER_DL8","DL8_STATUS",'3')     
							oModelDL8:SetValue("MASTER_DL8","DL8_MARK",'')
							If oModelDL8:VldData()        
								oModelDL8:CommitData() 				
							Else
						   	lRet := .F.
						   	cMsgErro := oModelDL8:GetErrorMessage()[6]
 							EndIf 
					
							oModelDL8:DeActivate()
						EndIf	
						
						If !lRet
							Exit
						EndIF							
						nCont++
					EndDo				
				
					If !lRet
						DisarmTransaction()
						Help( ,, 'Help',, STR0031,2,0,,,,,, {cMsgErro})	//Não foi possível efetivar a recusa da(s) Demanda(s).		
						BREAK
					Else
						MsgInfo(STR0011) //Demanda(s) recusada(s)
					EndIF				
				END TRANSACTION
			EndIf
		EndIf
	EndIf
	
	DL8->(DbSetOrder(nIndex))
	RestArea(aAreaDL8)

	If !lBlind
		If !Empty(aJustIf)
			If !lRet
				oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
				oBrwDeman:GoTo(nPosDL8)
				oBrwDeman:Refresh()
			Else
				oBrwDeman:SetFilterDefault(TMA153Filt("DL8"))
				oBrwDeman:Refresh(.T.)
			EndIf
		EndIf
	EndIf
	
	FwFreeObj(aJustif)
	FwFreeObj(aRet)
	FwFreeObj(aDmd)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VALIDQTDEM()
Validaçao da quantidade de demanda
@author  Marcelo Radulski Nunes
@since   07/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function VALIDQTDEM(cCampoUM, cCampoQtd)
Local lRet := .T.
	If &cCampoUM == '2' .and. &cCampoQtd <> INT(&cCampoQtd)
		lRet := .F.
		Help( ,, 'HELP',, STR0015, 1, 0 )//Não é permitido valor decimal para a unidade veículo. 
	EndIF		
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AJUSTQTDEM()
Ajuste da quantidade de demanda
@author  Marcelo Radulski Nunes
@since   07/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function AJUSTQTDEM(cCampoUM, cCampoQtd)
	If &cCampoUM == '2' .and. &cCampoQtd <> INT(&cCampoQtd)
		&cCampoQtd := INT(&cCampoQtd)		 
	EndIF		
Return .T.


/*/{Protheus.doc} TmValPesCp
//Valida se o(s) veículo(s) possui(em) capacidade de carga para as demandas relacionadas.
//A validação será feita dependendo de parâmetro e somente se as demandas tiverem unidade de medida = 1-Peso.
@author wander.horongoso
@since 07/05/2018
@version 1.0
@return Lógico: retorna verdadeiro se existir capacidade de os veículos carregarem as demandas. Falso se não houver possibilidade.
@param aDmd, array, relação de pesos das demandas a serem validados. 
@param aVeic, array, relação de veículos da composição.
@type function
/*/
Function TmValPesCp(aDmd, aVeic)
Local lRet := .T.
Local cTemp := GetNextAlias()
Local cQuery := ''
Local nQtPesDmd := 0
Local nQtCapVei := 0
Local cAux := ''
Local nX := 0
Local nPesCap := SuperGetMv("MV_PESCAP",,"1")
Local cMsg := ''
Local aRet := { .T. ,""}

	If nPesCap $ "23"
		If Len(aDmd) > 0 .And. Len(aVeic) > 0

			for nX:=1 to Len(aDmd)
				nQtPesDmd += aDmd[nX]
			next

			//Calcula a capacidade dos veículos
			cAux := "'" + AllTrim(aVeic[1]) + "'"
			For nX := 2 to Len(aVeic)
				cAux += ", '" + AllTrim(aVeic[nX]) + "'"
			Next nX
	
			cQuery := " SELECT SUM(DA3.DA3_CAPACM) DA3_CAPACM "
			cQuery += " FROM " + RetSqlName("DA3") + " DA3, " + RetSqlName("DUT") + " DUT "
			cQuery += " WHERE DA3.DA3_FILIAL = '" + xFilial("DA3") + "'" 
			cQuery += " AND  DA3.DA3_COD IN (" + cAux + ")" 
			cQuery += " AND DUT.DUT_FILIAL = '" + xFilial("DUT") + "'"
			cQuery += " AND DUT.DUT_TIPVEI = DA3.DA3_TIPVEI"
			cQuery += " AND DUT.DUT_CATVEI <> '2'"	
			cQuery += " AND DUT.D_E_L_E_T_ = ''"	
			cQuery += " AND DA3.D_E_L_E_T_ = ''"
		
			cQuery := ChangeQuery( cQuery )	
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
			
			nQtCapVei := (cTemp)->DA3_CAPACM	
			(cTemp)->(DbCloseArea())
			
			//2 - Aviso: Efetua a validação de peso por capacidade do veículo e informa ao usuário.
			//3- Impede a operação: Efetua a validação de peso por capacidade do veículo e impede a continuidade da operação.				
			If nQtCapVei < nQtPesDmd
			
				cMsg := STR0018 + cValToChar(nQtPesDmd) + STR0019 + cValToChar(nQtCapVei) + ")."
				
				If nPesCap == '2'
					aRet[1] := .T.
					aRet[2] := cMsg
					
				Else				
					lRet := .F.
					aRet[1] := .F.
					aRet[2] := cMsg				
				EndIf
			EndIf
		EndIf
	EndIf
return aRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} VldQtdDLA()
Valida se habilita/desabilita campo quantidade no grid de regiões de origem, conforme campo Unidade de Medida
@author  Gustavo Krug
@since   11/05/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function VldQtdDLA()
Local lRet := .F.

    If !Empty(M->DL7_UM)
        If M->DL7_UM <> "2"
            lRet := .T.
        EndIf
    ElseIf !Empty(M->DL8_UM)
        If M->DL8_UM <> "2"
            lRet := .T.
        EndIf
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldQtdDLE()
Valida se habilita/desabilita campo quantidade no grid de grupos de regiões de origem, conforme campo Unidade de Medida
@author  Aluizio Fernando Habizenreuter
@since   07/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function VldQtdDLE()
Local lRet := .F.

    If !Empty(M->DL7_UM)
        If M->DL7_UM <> "1"
            lRet := .T.
        EndIf
    EndIf            

Return lRet

/*/{Protheus.doc} TMCalcQtd
//Função para calcular os campos de qtd saldo e qtd extra (estes campos são virtuais)

Tipo 1 usado em casos em que a tabela não está posicionada
Tipo 2 usado quando a tabela está posicionada e é necessário refazer o cálculo
Tipo 3 usado nos momentos em que está chamando pela demanda

@author gustavo.baptista
@since 15/05/2018
@version 1.0
@return ${return}, ${return_description}
param cCampo, characters, descricao
@param nTotAtu, numeric, descricao
@param lTipo, logical, descricao
@type function
/*/
Function TMCalcQtd(cCampo, nValAtu, lTipo)
	Local nRet:= 0
	Local nQtd:= 0
	Local nQtdExt:= 0
	Local nQtdSld:= 0
		
	Default nValAtu:= 0
	Default lTipo:= 2
	
	If lTipo == 1 //momentos em que dl7 não está posicionada
		nQtd := nValAtu - (M->DL7_QTDDEM + M->DL7_QTDPLN + M->DL7_QTDPRG + M->DL7_QTDVIA + M->DL7_QTDREC + M->DL7_QTDRCL + M->DL7_QTDENC + M->DL7_QTDBLQ + If ( DL7->(ColumnPos("DL7_QTDREP")) > 0, M->DL7_QTDREP, 0 ) )
	ElseIf lTipo == 2 //momentos em que dl7 está posicionada
		nQtd := nValAtu - (DL7->DL7_QTDDEM + DL7->DL7_QTDPLN + DL7->DL7_QTDPRG + DL7->DL7_QTDVIA + DL7->DL7_QTDREC + DL7->DL7_QTDRCL + DL7->DL7_QTDENC + DL7->DL7_QTDBLQ + If ( DL7->(ColumnPos("DL7_QTDREP")) > 0, DL7->DL7_QTDREP, 0 ) )
	ElseIf lTipo == 3 //momentos em que está chamando pela demanda
		
		If !EMPTY(M->DL8_CRTDMD)
			nQtd := DL7->DL7_QTDTOT - (nValAtu + DL7->DL7_QTDDEM + DL7->DL7_QTDPLN + DL7->DL7_QTDPRG + DL7->DL7_QTDVIA + DL7->DL7_QTDREC + DL7->DL7_QTDRCL + DL7->DL7_QTDENC + DL7->DL7_QTDBLQ + If ( DL7->(ColumnPos("DL7_QTDREP")) > 0, DL7->DL7_QTDREP, 0 ))
		Else
			nQtd:= 0
		EndIf
	
	EndIf

	If nQtd < 0
		nQtdExt := (nQtd)*-1
		nQtdSld:= 0
	Else
		nQtdExt := 0
		nQtdSld := nQtd		
	EndIf
	
	If cCampo == 'SALDO' 
		nRet:= nQtdSld
	Else
		nRet:= nQtdExt
	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TCalcSldMt
Atualiza quantidade dos campos Saldo e Extra da meta do contrato 
@author  Gustavo Krug
@since   03/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TCalcSldMt(cCampo, nValAtu, lTipo)
Local nRet:= 0
Local nQtd:= 0
Local nQtdExt:= 0
Local nQtdSld:= 0

Default nValAtu:= 0
Default lTipo:= 2
	
	If lTipo == 1 //momentos em que DLG não está posicionada
		nQtd := nValAtu - (M->DLG_QTDDEM + M->DLG_QTDPLN + M->DLG_QTDPRG + M->DLG_QTDVIA + M->DLG_QTDREC + M->DLG_QTDRCL + M->DLG_QTDENC + M->DLG_QTDBLQ + If ( DLG->(ColumnPos("DLG_QTDREP")) > 0, M->DLG_QTDREP, 0 ) )
	ElseIf lTipo == 2 //momentos em que DLG está posicionada
		nQtd := nValAtu - (DLG->DLG_QTDDEM + DLG->DLG_QTDPLN + DLG->DLG_QTDPRG + DLG->DLG_QTDVIA + DLG->DLG_QTDREC + DLG->DLG_QTDRCL + DLG->DLG_QTDENC + DLG->DLG_QTDBLQ + If ( DLG->(ColumnPos("DLG_QTDREP")) > 0, DLG->DLG_QTDREP, 0 ) )
	ElseIf lTipo == 3 //momentos em que está chamando pela demanda
		
		If !EMPTY(M->DL8_CRTDMD)
			nQtd := DLG->DLG_QTD - (nValAtu + DLG->DLG_QTDDEM + DLG->DLG_QTDPLN + DLG->DLG_QTDPRG + DLG->DLG_QTDVIA + DLG->DLG_QTDREC + DLG->DLG_QTDRCL + DLG->DLG_QTDENC + DLG->DLG_QTDBLQ + If ( DLG->(ColumnPos("DLG_QTDREP")) > 0, DLG->DLG_QTDREP, 0 ) )
		Else
			nQtd:= 0
		EndIf
	
	EndIf

	If nQtd < 0
		nQtdExt := (nQtd)*-1
		nQtdSld:= 0
	Else
		nQtdExt := 0
		nQtdSld := nQtd		
	EndIf
	
	If cCampo == 'SALDO' 
		nRet:= nQtdSld
	Else
		nRet:= nQtdExt
	EndIf

Return nRet


/*/{Protheus.doc} TMLockDmd
//Função para inclusão de registro no controle de semáforo.
Ao incluir o lock, o contador é iniciado com 1. Caso a tela permita ação de check e mais outra ação de menu (alterar
por exemplo, o contador é incrementado na ação). Após a ação, o contador é decrementado pela função TmUnLockDmd e, 
caso o registro não seja mais exibido na tela onde houve o check, deverá ser passado .T. para eliminar o lock.
Se a tela continuar exibindo o registro, deve ser passado .F. para manter o lock.
@author wander.horongoso
@since 24/05/2018
@version 1.0
@return .T. indica se o lock foi feito ou .F. se já existe lock
@return mensagem indicando que não foi possível efetuar o lock indicando o usuário que está bloqueando o registro.
@param cKey, characters, chave a ser controlada
@type function
/*/
Function TMLockDmd(cKey)
Local aRet := {.T., '',}
Local aLockInfo := {'','',''}

	//Obtém as informações adicionais do controle por semáforo
	aCopy(StrToKArr(GetGlbValue(cKey), ';'), aLockInfo)
	
	//Tenta efetuar o lock. Caso seja mesma thread tentando efetuar o lock, também é retornado .T.
	aRet[1] := LockByName(cKey, .T., .F.)
	
	If aRet[1]

		//Se o lock for da mesma thread, incrementar o contador
		//Senão grava as informações do lock
		If aLockInfo[1] == cValToChar(ThreadId()) 
			aLockInfo[3] := cValToChar(Val(aLockInfo[3]) + 1)
		Else
			
			ClearGlbValue(cKey) //limpa as variáveis criadas em outros processos que ficaram na memória 		

			aLockInfo[1] := cValToChar(ThreadId())
			aLockInfo[2] := __cUserId
			aLockInfo[3] := '1'
		EndIf
		
		PutGlbValue(cKey, aLockInfo[1] + ';' + aLockInfo[2] + ';' + aLockInfo[3])
			
	Else		
	
		If !aRet[1]
			aRet[2] := STR0020 + UsrFullName(aLockInfo[2]) + '.' //Registro bloqueado pelo usuário XXXX.
		EndIf	

	EndIf

return aRet

/*/{Protheus.doc} TMUnLockDmd
//Função para exclusão de registro no controle de semáforo.
@author wander.horongoso
@since 24/05/2018
@version 1.0
@return naõ há
@param cKey, characters, chave a ser controlada
@param lAllUnLock, boolean, .T. deve ser usado quando o registro está marcado em um grid na mesma tela em que a ação 
(alteração) foi efetuada, e deixará de ser mostrado após a ação.
.F. quando o registro continuará sendo exibido e, caso esteja marcado, continuará bloqueado para edição por outro usuário.
@type function
/*/
Function TMUnLockDmd(cKey, lAllUnLock)
Local aLockInfo := {'','',''}
Default lAllUnLock := .T.

	//Pode ser feito unlock da chave ou então decrementar o contador de locks e fazer apenas quando chegar a 0.
	//Na forma atual o contador de locks pode chegar a no máximo 2.
	If lAllUnlock	

		UnLockByName(cKey, .T., .F.)
		ClearGlbValue(cKey)

	Else	
				
		aCopy(StrToKArr(GetGlbValue(cKey), ';'), aLockInfo)
		
		If aLockInfo[3] == '1'		 
			UnLockByName(cKey, .T., .F.)
			ClearGlbValue(cKey)
		Else		
			aLockInfo[3] := cValToChar(Val(aLockInfo[3]) - 1)
			PutGlbValue(cKey, aLockInfo[1] + ';' + aLockInfo[2] + ';' + aLockInfo[3])
		EndIf		
		
	EndIf
	
Return


/*/{Protheus.doc} TGetSeqDLG
//Função que retorna o sequencial da meta a partir de contrato, grupo de região, veículo e data de previsão.
Retornará branco caso não encontre nenhuma meta com os dados informados.
@author wander.horongoso
@since 15/06/2018
@version 1.0
@return cSeq, characters, sequencial da meta
@param cCodCrt, characters, código do contrato
@param cCodGrd, characters, código do grupo de região
@param cTipVei, characters, código do tipo de veículo
@param dDatPrev, date, data de previsão 
@type function
/*/
Function TGetSeqDLG(cCodCrt, cCodGrd, cTipVei, dDatPrev)
Local cSeq := ''
Local cQuery := ''
Local cTemp := GetNextAlias() 
	
	cQuery := " SELECT DLG.DLG_SEQ FROM " + RetSqlName('DLG') + " DLG "
	cQuery += " WHERE DLG.DLG_FILIAL = '" + xFilial("DLG") + "'"
	cQuery += " AND DLG.DLG_CODCRT = '" + cCodCrt + "'"
	cQuery += " AND DLG.DLG_CODGRD = '" + cCodGrd + "'"
	cQuery += " AND DLG.DLG_TIPVEI = '" + cTipVei + "'"
	cQuery += " AND DLG.DLG_DATINI <= '" + dToS(dDatPrev) + "'"
	cQuery += " AND DLG.DLG_DATFIM >= '" + dToS(dDatPrev) + "'"	
	cQuery += " AND D_E_L_E_T_ = ''"
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )
	
	cSeq := (cTemp)->DLG_SEQ	
	
	(cTemp)->(DbCloseArea())

Return cSeq


/*/{Protheus.doc} TGetCrtDmd
//Função para retornar um conjunto de contratos e grupos de região a partir de um cliente,
de uma unidade de medida e de um grupo de regioes origem e regioes destino.
- Faz pesquisa com exatidão, ou seja, tenta localizar contratos contendo tão e somente todas as regiões origem
e todas as destino informadas;
- Caso não encontre, seleciona contratos que possuam ao menos 1 região origem e 1 região destino. 
@author ruan.salvador
@since 10/09/2018
@version 1.0
@param cCliDev, characters, codigo do cliente devedor do contrato
@param cLojDev, characters, loja do cliente devedor do contrato
@param cUM, characters, unidade de medida do contrato
@param aReg, array, array de regioes origem e destino. Cada item do array deve ser composto pelo codigo da regiao e o tipo (1-origem/2-destino)
@return array, conjunto de itens formado por codigo de contrato e codigo do grupo de região.
@type function
/*/
Function TGetCrtDmd(cCliDev, cLojDev, cUM, aReg)
	Local cTemp 	 := GetNextAlias()
	Local cQuery 	 := ''
	Local cSelect    := ''
	Local cRegOri 	 := ''
	Local cRegDes 	 := ''
	Local nCntInfOri := 0
	Local nCntInfDes := 0
	Local nX, nY	 := 0
	Local aRet 		 := {}
	Local aContrato  := {}
	Local aRegNiv    := {}
	Local aRegOri    := {}
	Local aRegDes    := {}
	
	For nX := 1 To Len(aReg)
		If aReg[nX,2] == '1'
			cRegOri += Iif(Empty(cRegOri), "'", ",'") + AllTrim(aReg[nX,1]) + "'"
			nCntInfOri++
		Else
			cRegDes += Iif(Empty(cRegDes), "'", ",'") + AllTrim(aReg[nX,1]) + "'"
			nCntInfDes++			
		EndIf
	Next nX
	
	//Comando comum para os 2 select usados na busca de região.
	cSelect := " SELECT DL7.DL7_COD, "
	cSelect += " 	   DL7.DL7_TIPCTR, "
	cSelect += " 	   DL7.DL7_ABRANG, "
	cSelect += "        DLE.DLE_CODGRD "
	cSelect += "   FROM " + RetSqlName("DL7") + " DL7" 
	cSelect += "        INNER JOIN " + RetSqlName("DLE") + " DLE" 
	cSelect += " 	           ON DLE.DLE_FILIAL = '" + xFilial('DLE') + "'"
	cSelect += " 		      AND DLE.DLE_CRTDMD = DL7.DL7_COD "
	cSelect += "               AND DLE.D_E_L_E_T_ = ' ' "
	cSelect += "  WHERE DL7.DL7_FILIAL = '" + xFilial('DL7') + "'"
	cSelect += "    AND DL7.DL7_CLIDEV = '" + cCliDev + "'"
	cSelect += "    AND (DL7.DL7_LOJDEV = '" + cLojDev + "' OR DL7.DL7_ABRANG = '2') "
	cSelect += "    AND DL7.DL7_STATUS = '1' "
	cSelect += "    AND DL7.DL7_UM = '" + cUM + "'"
	cSelect += "    AND DL7.D_E_L_E_T_ = ' ' "

	/*1. Monta query para localizar contratos com exatidão de regiões origem e destino.*/	
	cQuery := cSelect
	//Origens devem ser as mesmas passadas pela demanda 
	cQuery += "    AND (SELECT COUNT(DLM.DLM_CODREG) "
	cQuery += "            FROM " + RetSqlName("DLM") + " DLM" 
	cQuery += " 		  WHERE DLM.DLM_FILIAL = '" + xFilial('DLM') + "'"
	cQuery += " 		    AND DLM.DLM_CRTDMD = DLE.DLE_CRTDMD "
	cQuery += " 		    AND DLM.DLM_CODGRD = DLE.DLE_CODGRD "
	cQuery += " 			AND DLM.DLM_CODREG IN (" + Iif( Empty(cRegOri), "''", cRegOri ) + ")"
	cQuery += " 			AND DLM.D_E_L_E_T_ = ' ') = " + Str( nCntInfOri ) + " "
	//Quantidade total de regiões do grupo deve ser a mesma passada pela demanda
	cQuery += "    AND (SELECT COUNT(DLM.DLM_CODREG) "
	cQuery += "            FROM " + RetSqlName("DLM") + " DLM" 
	cQuery += " 		  WHERE DLM.DLM_FILIAL = '" + xFilial('DLM') + "'"
	cQuery += " 		    AND DLM.DLM_CRTDMD = DLE.DLE_CRTDMD "
	cQuery += " 		    AND DLM.DLM_CODGRD = DLE.DLE_CODGRD "
	cQuery += " 			AND DLM.D_E_L_E_T_ = ' ') = " + Str( nCntInfOri ) + ""
	//Destinos devem ser as mesmas passadas pela demanda 
	cQuery += "    AND (SELECT COUNT(DLN.DLN_CODREG) "
	cQuery += " 	       FROM " + RetSqlName("DLN") + " DLN" 
	cQuery += " 		  WHERE DLN.DLN_FILIAL = '" + xFilial('DLN') + "'"
	cQuery += " 		    AND DLN.DLN_CRTDMD = DLE.DLE_CRTDMD "
	cQuery += " 		    AND DLN.DLN_CODGRD = DLE.DLE_CODGRD "
	cQuery += " 			AND DLN.DLN_CODREG IN (" + Iif( Empty(cRegDes), "''", cRegDes )	 + ")"
	cQuery += " 			AND DLN.D_E_L_E_T_ = ' ') = " + Str( nCntInfDes ) + ""
	//Quantidade total de regiões do grupo deve ser a mesma passada pela demanda
	cQuery += "    AND (SELECT COUNT(DLN.DLN_CODREG) "
	cQuery += " 	       FROM " + RetSqlName("DLN") + " DLN" 
	cQuery += " 		  WHERE DLN.DLN_FILIAL = '" + xFilial('DLN') + "'"
	cQuery += " 		    AND DLN.DLN_CRTDMD = DLE.DLE_CRTDMD "
	cQuery += " 		    AND DLN.DLN_CODGRD = DLE.DLE_CODGRD "
	cQuery += " 			AND DLN.D_E_L_E_T_ = ' ') = " + Str( nCntInfDes ) + ""
	cQuery += "  ORDER BY DL7.DL7_ABRANG, DL7.DL7_TIPCTR "

	cQuery := ChangeQuery(cQuery)	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )

	/*Encontrou regiões com exatidão*/
	While !(cTemp)->(Eof())
		If (cTemp)->DL7_ABRANG == '1'
			Aadd(aContrato, { (cTemp)->DL7_COD, (cTemp)->DL7_TIPCTR, (cTemp)->DL7_ABRANG, (cTemp)->DLE_CODGRD })
		ElseIf aScan(aContrato, {|x| x[2] == (cTemp)->DL7_TIPCTR } ) == 0
			Aadd(aContrato, { (cTemp)->DL7_COD, (cTemp)->DL7_TIPCTR, (cTemp)->DL7_ABRANG, (cTemp)->DLE_CODGRD })
		EndIf
	
		(cTemp)->(dbSkip())
	EndDo

	(cTemp)->(dbCloseArea())

	/*2. Se não localizar contrato com as mesmas regiões origem/destino para o cliente, faz a busca de 
	contratos/grupo por aproximação, ou seja, que tenha ao menos 1 região origem e 1 destino.*/
	If Len(aContrato) == 0

		//Determina os níveis superiores de cada uma das regiões informadas e adiciona no array de regiões caso ainda não esteja no array
		For nX := 1 To Len(aReg)
			aRegNiv := TmsNivSup (aReg[nX,1])

			For nY := 1 To Len(aRegNiv)
				If aReg[nX,2] == '1'
					Iif (AScan(aRegOri, {|x| x == aRegNiv[nY]}) == 0, Aadd(aRegOri, aRegNiv[nY]),)
				Else
					Iif (AScan(aRegDes, {|x| x == aRegNiv[nY]}) == 0, Aadd(aRegDes, aRegNiv[nY]),)
				EndIf
			Next nY
		Next nX

		//Monta a sintaxe de regiões para filtros de origem e destino da query
		cRegOri := ''
		For nY := 1 To Len(aRegOri)
			cRegOri += Iif(Empty(cRegOri), "'", ",'") + AllTrim(aRegOri[nY]) + "'"
		Next nY
		
		cRegDes := ''
		For nY := 1 To Len(aRegDes)
			cRegDes += Iif(Empty(cRegDes), "'", ",'") + AllTrim(aRegDes[nY]) + "'"
		Next nY		
		
		cQuery := cSelect
		//Dever haver no mínimo 1 origem das informadas 
		cQuery += "    AND (SELECT COUNT(DLM.DLM_CODREG) "
		cQuery += "            FROM " + RetSqlName("DLM") + " DLM" 
		cQuery += " 		  WHERE DLM.DLM_FILIAL = '" + xFilial('DLM') + "'"
		cQuery += " 		    AND DLM.DLM_CRTDMD = DLE.DLE_CRTDMD "
		cQuery += " 		    AND DLM.DLM_CODGRD = DLE.DLE_CODGRD "
		cQuery += "			    AND DLM.DLM_CODREG IN (" + Iif( Empty(cRegOri), "''", cRegOri ) + ")"
		cQuery += " 			AND DLM.D_E_L_E_T_ = ' ') > 0 "
		//Dever haver no mínimo 1 destino dos informados caso haja regiões destino informadas
		If Len(aRegDes) > 0		 
			cQuery += "    AND (SELECT COUNT(DLN.DLN_CODREG) "
			cQuery += " 	       FROM " + RetSqlName("DLN") + " DLN" 
			cQuery += " 		  WHERE DLN.DLN_FILIAL = '" + xFilial('DLN') + "'"
			cQuery += " 		    AND DLN.DLN_CRTDMD = DLE.DLE_CRTDMD "
			cQuery += " 		    AND DLN.DLN_CODGRD = DLE.DLE_CODGRD "
			cQuery += " 			AND DLN.DLN_CODREG IN (" + Iif( Empty(cRegDes), "''", cRegDes )	 + ")"
			cQuery += " 			AND DLN.D_E_L_E_T_ = ' ') > 0 "
		EndIf
		
		cQuery += "  ORDER BY DL7.DL7_ABRANG, DL7.DL7_TIPCTR "
	
		cQuery := ChangeQuery(cQuery)		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTemp, .F., .T. )

		While !(cTemp)->(Eof())
			If aScan(aContrato, {|x| x[1] + x[4] == (cTemp)->DL7_COD + (cTemp)->DLE_CODGRD}) == 0
				Aadd(aContrato, { (cTemp)->DL7_COD, (cTemp)->DL7_TIPCTR, (cTemp)->DL7_ABRANG, (cTemp)->DLE_CODGRD })
			EndIf
			
			(cTemp)->(dbSkip())
		EndDo

		(cTemp)->(dbCloseArea())
	EndIf
	
	//--Envia pra o retorno - as informações corretas para a consulta
	For nx := 1 To Len(aContrato)
		Aadd(aRet, { aContrato[nx][1], aContrato[nx][4] })
	Next nx
			
Return aRet

/*/{Protheus.doc} TVldDelMet
//Valida se é possível excluir as metas de um grupo de região.
Só permite caso todas as metas tenham saldo igual ao total da meta. Essa regra é a mesma da função de do cálculo do saldo da meta e contrato.
@author wander.horongoso
@since 22/06/2018
@version 1.0
@return ${return}, 
	aRet[1], logico, indica se a exclusão das metas foi efetuada
	aRet[2], character, caso não seja possível excluir as metas, indica o motivo.
@param cCodCrt, characters, código do contrato de demanda.
@param cCodGRD, characters, código do grupo de regiões do contrato.
@param cTipVei, characters, código do tipo de veículo. Usado para validar a exclusão de uma única meta.
@param cSeqMeta, characters, código sequencial da meta. Usado para validar a exclusão de uma única meta.
@type function
/*/
Function TVldDelMet(cCodCrt, cCodGRD, cTipVei, cSeqMeta)
Local aRet := {.T., ""}
Local cQuery := ''
Local cAliasQry := GetNextAlias()
Local cPeriodo := ''

Default cTipVei := ''
Default cSeqMeta := ''

 	cQuery := " SELECT DLG_DATINI, DLG_DATFIM, DLG_QTDDEM, DLG_QTDPLN, DLG_QTDPRG, DLG_QTDVIA, DLG_QTDREC, DLG_QTDRCL "
 	cQuery += " FROM " + RetSqlName("DLG")
 	cQuery += " WHERE DLG_FILIAL = '" + xFilial("DLG") + "'"
 	cQuery += " AND DLG_CODCRT = '" + cCodCrt + "'"
 	cQuery += " AND DLG_CODGRD = '" + cCodGRD + "'"
 	cQuery += " AND D_E_L_E_T_ = ''"
 	
 	If !Vazio(cTipVei)
 		cQuery += " AND DLG_TIPVEI = '" + cTipVei + "'"
 	EndIf
 	
 	If !Vazio(cSeqMeta)
 		cQuery += " AND DLG_SEQ = '" + cSeqMeta + "'"
 	EndIf 	
 	
 	cQuery := ChangeQuery(cQuery)
 	  
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .F., .T. )
	
	If (cAliasQry)->(Bof()) .And. (cAliasQry)->(Eof())
		aRet[1] := .F.
		aRet[2] := STR0025 //Não existem metas cadastradas para este grupo de veículo.                                                                                                                                                                                                                                                                                                                                                                                                                                                         
	Else
		(cAliasQry)->(dbGoTop())
		
		While !(cAliasQry)->(Eof())				
			If (cAliasQry)->(DLG_QTDDEM + DLG_QTDPLN + DLG_QTDPRG + DLG_QTDVIA + DLG_QTDREC + DLG_QTDRCL) > 0
				aRet[1] := .F.
				
				If Vazio(cPeriodo)
					cPeriodo := DtoC(StoD((cAliasQry)->DLG_DATINI)) + STR0024 + DtoC(StoD((cAliasQry)->DLG_DATFIM)) //  a
				Else				
					cPeriodo += STR0023 //e em outros períodos
					Exit
				EndIf			
			EndIf
			
			
			(cAliasQry)->(dbSkip())
		EndDo
		
		If !aRet[1]
			If !Vazio(cSeqMeta)
				aRet[2] := STR0026 //Não é possível excluir metas já consumidas.			
			Else		
				aRet[2] := STR0021 + AllTrim(cCodGRD) + STR0022 + cPeriodo + "." //Não é possível excluir as metas do grupo de região / , pois há consumo de meta no período de
			EndIf
		EndIf
	EndIf
	
	(cAliasQry)->(DbCloseArea())	

Return aRet

Function TmDelMeta(cCodCrt, cCodGRD, cTipVei, cSeqMeta)
Local lRet := .T.

	dbSelectArea("DLG")
	DLG->(dbSetOrder(1))
	DLG->(DbSeek(xFilial("DLG") + cCodCrt + cCodGRD))
	
	While !DLG->(Eof()) .And. DLG->(DLG_FILIAL + DLG_CODCRT + DLG_CODGRD) == xFilial("DLG") + cCodCrt + cCodGRD
		RecLock("DLG", .F.)
		DLG->(dbDelete())
		MsUnlock()
	
		DLG->(dbSkip())
	EndDo

Return lRet

/*/{Protheus.doc} TMSUpdDmd
Atualiza o status do planejamento e as quantidades da meta/contrato, caso a viagem seja gerada a partir de 
uma programação de carga oriunda do planejamento de demanda.
Será usado na geração de viagem e também no estorno da viagem.
@author wander.horongoso
@since 23/07/2018
@version 1.0
@return ${return}, ${return_description}
@param cCodPlnDmd, characters, código do planejamento
@param cDL9Status, characters, valor que será gravado no campo DL9_STATUS (3 para viagem e 2 para estorno da viagem).
@param cOpeMetDmd, characters, Operação que será usada para atualizar os valores da meta/contrato (7 para viagem e 8 para estorno de viagem)
@param cViagemPrg, characters, Codigo da viagem da progração de carregamento. 
@type function
/*/
Function TMSUpdDmd(cCodPlnDmd, cDL9Status, nOpeMetDmd, cViagemPrg)
Local cQuery 	:= ""
Local cAliasDL8 := GetNextAlias()
Local lTmsDmd 	:= SuperGetMV( "MV_ITMSDMD",, .F.)
Local cDbType	:= TCGetDB()

	If lTmsDmd .And. DL9->(ColumnPos("DL9_FILIAL")) > 0 //SUAVIZAÇÃO DEMANDAS

		DL9->(dbSetOrder(1))
		If DL9->(DbSeek(xFilial("DL9") + cCodPlnDmd))
			If !(DL9->DL9_STATUS == cDL9Status)
				RecLock ("DL9", .F.)
				DL9->DL9_STATUS := cDL9Status
				DL9->(MsUnLock())
			
				cQuery := " SELECT DL8_FILIAL, DL8_CRTDMD, DL8_CODGRD, DL8_TIPVEI, DL8_SEQMET, DL8_QTD" 
				cQuery += " FROM " +  RetSqlName("DL8") + " DL8 "
				cQuery += " WHERE DL8_FILIAL  = '" + xFilial('DL8') + "'"
				cQuery += " AND DL8_PLNDMD = '" + cCodPlnDmd + "'"
				cQuery += " AND D_E_L_E_T_  = ' '"
		   
	        	cQuery := ChangeQuery(cQuery)		   
		        dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasDL8,.T.,.T.)
		         
		        While (cAliasDL8)->(!Eof())
		        	TMUpQtMDmd((cAliasDL8)->DL8_FILIAL, (cAliasDL8)->DL8_CRTDMD, (cAliasDL8)->DL8_CODGRD, (cAliasDL8)->DL8_TIPVEI, (cAliasDL8)->DL8_SEQMET, (cAliasDL8)->DL8_QTD, nOpeMetDmd)
		            (cAliasDL8)->(dbSkip())
		        EndDo
		        If cDL9Status == "3" .AND. nOpeMetDmd = 7
		        	TmIncTrk('3', xFilial("DL9"), cCodPlnDmd,/*cSeqDoc*/,/*cDocPai*/,'V',/*cCodMotOpe*/,/*cObs*/,/*cTpRecusa*/,DF8->DF8_NUMPRG,DF8->DF8_VIAGEM)
		        ElseIf cDL9Status == "6" .AND. nOpeMetDmd = 8
		        	TmIncTrk('3', xFilial("DL9"), cCodPlnDmd,/*cSeqDoc*/,/*cDocPai*/,'Z',/*cCodMotOpe*/,/*cObs*/,/*cTpRecusa*/,DF8->DF8_NUMPRG,cViagemPrg)
		        ElseIf cDL9Status == "2" .AND. nOpeMetDmd = 6	
		        	TmIncTrk('3', xFilial("DL9"), cCodPlnDmd,/*cSeqDoc*/,/*cDocPai*/,'H',/*cCodMotOpe*/,/*cObs*/,/*cTpRecusa*/,DF8->DF8_NUMPRG,DF8->DF8_VIAGEM)
		        EndIf
		        (cAliasDL8)->(dbCloseArea())
	        EndIf
		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} TmExVgDmd
Excluir viagem gerada pela programacao que foi gerada pela gestao de demandas
- Cancela as coletas geradas
- Volta status do planejamento para 2 - Aberto com demandas
- Estorna o saldo das metas e do contrato
@author ruan.salvador	
@since 27/07/2018
@version 12.1.17
@param cCodPlnDmd: codigo do planejamento
nOpc: indica a ação (1-validação da exclusão / 2-exclusão)
@type function
/*/
Function TmExVgDmd(cCodPln, nOpc)
Local cAliasDT5  := GetNextAlias()
Local cAliasDL8  := GetNextAlias()
Local cQuery	 := ''
Local aAreaDL9   := DL9->(GetArea())
Local aInfPrgDmd := {}
Local aDT5       := {}
Local aCabecDT5  := {}
Local nX         := 0
Local aRet       := {.T., ''}
	
	cQuery := " SELECT DT5.DT5_FILIAL, DT5.DT5_FILORI, DT5.DT5_NUMSOL,"
	cQuery += "        DT5.DT5_FILDOC, DT5.DT5_DOC, DT5.DT5_SERIE"
	cQuery += "   FROM " + RetSqlName('DT5') + " DT5 "
	cQuery += "   JOIN " + RetSqlName('DL8') + " DL8 "
	cQuery += "     ON DL8.DL8_FILIAL = '" + xFilial('DL8') + "'"
	cQuery += "    AND DL8.DL8_PLNDMD = '" + cCodPln + "'" 
	cQuery += "    AND DL8.D_E_L_E_T_ = '' "
	cQuery += "  WHERE DT5.DT5_FILIAL = '" + xFilial('DT5') + "'"
	cQuery += "    AND DT5.DT5_ORIDMD = '1'"
	cQuery += "    AND DT5.DT5_CODDMD = DL8.DL8_COD "
	cQuery += "    AND DT5.DT5_SEQDMD = DL8.DL8_SEQ "
	cQuery += "    AND DT5.DT5_STATUS <> '9' "
	cQuery += "    AND DT5.D_E_L_E_T_ = '' "
	
	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasDT5, .F., .T. )	
	
	If nOpc == 1 //Valida se as coletas podem ser canceladas

		While (cAliasDT5)->(!EOF())			
			Aadd(aDT5, {(cAliasDT5)->DT5_FILDOC, (cAliasDT5)->DT5_DOC, (cAliasDT5)->DT5_SERIE})
			(cAliasDT5)->(dbSkip())
		EndDo
		
		aDT5 := Tmsa460Can(aDT5)
		For nX := 1 To Len(aDT5)
			If aDT5[nX][4] == .F.
				aRet[1] := .F.
				aRet[2] := STR0058 + AllTrim(aDT5[nX][1]) + '/' + AllTrim(aDT5[nX][2]) + '/' + AllTrim(aDT5[nX][3]) + STR0059 //Coleta XX/XXXXX/XXX não pode ser cancelada. 				
				Exit
			EndIf
		Next nX

	Else

		While (cAliasDT5)->(!EOF())
			aCabecDT5 := {}
			AAdd(aCabecDT5, {"DT5_FILIAL", (cAliasDT5)->DT5_FILIAL, Nil})
			AAdd(aCabecDT5, {"DT5_FILORI", (cAliasDT5)->DT5_FILORI, Nil})
			AAdd(aCabecDT5, {"DT5_NUMSOL", (cAliasDT5)->DT5_NUMSOL, Nil})
			MSExecAuto({|x,y,k,w,z| TMSA460(x,y,k,w,z)},aCabecDT5,,,,5)

			(cAliasDT5)->(dbSkip())
		EndDo
		
		//Volta o status do planejamento para 2 - Aberto com demandas 
		DL9->(DbSetOrder(1))
		If DL9->(DbSeek(xFilial('DL9') + cCodPln))
			RecLock("DL9", .F.)
			DL9->DL9_STATUS := '2'
			MsUnlock()

			If !IsInCallStack("TMSA146")
				aInfPrgDmd := TmsPrgDmd(cCodPln)
				If Len(aInfPrgDmd) > 0 .AND. ValType(aInfPrgDmd[1][1]) <> 'U' .AND. ValType(aInfPrgDmd[1][2]) <> 'U'
					TmIncTrk('3', xFilial('DL9'), DL9->DL9_COD,/*cSeqDoc*/,/*cDocPai*/,'Z',/*cCodMotOpe*/,/*cObs*/,/*cTpRecusa*/,aInfPrgDmd[1][1],aInfPrgDmd[1][2]) //tracking que excluiu a viagem
					TmIncTrk('3', xFilial('DL9'), DL9->DL9_COD,/*cSeqDoc*/,/*cDocPai*/,'H',/*cCodMotOpe*/,/*cObs*/,/*cTpRecusa*/,aInfPrgDmd[1][1])//Não grava viagem no tracking pois já foi deletada da programaçao
				EndIf
			EndIf
		EndIf
		
		RestArea(aAreaDL9)
		
		cQuery := " SELECT DL8.DL8_FILIAL, "
		cQuery += "        DL8.DL8_CRTDMD, "
		cQuery += "        DL8.DL8_CODGRD, "
		cQuery += "        DL8.DL8_TIPVEI, "
		cQuery += "        DL8.DL8_SEQMET, "
		cQuery += "        DL8.DL8_QTD     "  
		cQuery += "   FROM " + RetSqlName('DL8') + " DL8 "
		cQuery += "  WHERE DL8.DL8_FILIAL = '" + xFilial('DL8') + "'"
		cQuery += "    AND DL8.DL8_PLNDMD = '" + cCodPln + "'" 
		cQuery += "    AND DL8.D_E_L_E_T_ = '' "
		
		cQuery := ChangeQuery( cQuery )	
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasDL8, .F., .T. )	
		
		//Ajusta o saldo da meta e do contrato de viagem diretamente para planejamento
		While (cAliasDL8)->(!Eof()) .And. !Empty((cAliasDL8)->DL8_CRTDMD)
			TMUpQtMDmd((cAliasDL8)->DL8_FILIAL, (cAliasDL8)->DL8_CRTDMD, (cAliasDL8)->DL8_CODGRD, (cAliasDL8)->DL8_TIPVEI, (cAliasDL8)->DL8_SEQMET, (cAliasDL8)->DL8_QTD, 14)
			(cAliasDL8)->(dbSkip())
		EndDo
		
		(cAliasDL8)->(DbCloseArea())
		
	EndIf
	
	(cAliasDT5)->(DbCloseArea())
	
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TmAtuDmdSt
Função que atualiza o status do registro da demanda na Gestão de Demandas, grava o tracking do movimento 
além de movimentar qtde no contrato/meta.
@author	Wander Horongoso 
@version	1.0
@since		28/02/2019
@param
cCod: código da demanda
cSeq: sequência da demanda
cStatus: status da demanda
cMotStatus: motivo do status o observação do tracking
@return
aRet: array contendo:
se a execução foi efetuada com sucesso;
mensagem de erro caso ocorra erro. 
/*/
Function TmAtuDmdSt(cCod, cSeq, cStatus, cMotStatus)
Local aAreas     := {DL8->(GetArea()), DL9->(GetArea()), GetArea()}
Local cOpeTrk    := ''
Local nOpeQtd    := 0
Local aRetBox    := {}
Local aRet       := {.T., ''}

	If !Empty(cCod) .And. !Empty(cSeq) .And. !Empty(cStatus)
	
		DL8->(DbClearFilter())
		DL8->(DbSetOrder(1))
		If DL8->(DbSeek(xFilial("DL8") + cCod + cSeq))
			
			Do Case
				Case DL8->DL8_STATUS == '2' 
					Do Case
						Case cStatus == '4' //Finalizado
							cOpeTrk := 'F'
							nOpeQtd := 11   //Move qtde de viagem para encerrada
						Case cStatus == '5' //Em reprocesso
							cOpeTrk := 'L'
							nOpeQtd := TmGetOpeQtd(DL8->DL8_PLNDMD, 24, 22) //Move qtde de programação ou de viagem para reprocesso 
						Case cStatus == '6' //Bloqueado
							cOpeTrk := 'M'
							nOpeQtd := TmGetOpeQtd(DL8->DL8_PLNDMD, 17, 19) //Move qtde de programação ou de viagem para bloqueio 
						Case cStatus == '7'  //Cancelado
							cOpeTrk := 'J'
							nOpeQtd := 15 //Move qtde de viagem para cancelada
					EndCase
				Case DL8->DL8_STATUS == '4' 
					Do Case
						Case cStatus == '2' //Planejado
							cOpeTrk := 'B'
							nOpeQtd := 12   //Move qtde de encerrado para viagem
						Case cStatus == '5' //Em reprocesso
							cOpeTrk := 'B'
							nOpeQtd := 26   //Move qtde de encerrado para em reprocesso
					EndCase
				Case DL8->DL8_STATUS == '5' 
					Do Case
						Case cStatus == '4' //Finalizado
							cOpeTrk := 'F'
							nOpeQtd := 25   //Move qtde de reprocesso para encerrado
						Case cStatus == '2' //Planejado
							cOpeTrk := 'O'
							nOpeQtd := TmGetOpeQtd(DL8->DL8_PLNDMD, 23, 21) //Move qtde de reprocesso para programação ou viagem 
						Case cStatus == '6' //Bloqueado
							cOpeTrk := 'M'
							nOpeQtd := 27   //Move qtde de reprocesso para bloqueado
					EndCase 
				Case DL8->DL8_STATUS == '6' 	
					Do Case
						Case cStatus == '2'  //Planejado
							cOpeTrk := 'N' 
							nOpeQtd := TmGetOpeQtd(DL8->DL8_PLNDMD, 18, 20) //Move qtde de bloqueio para programação ou viagem 
						Case cStatus == '5' //Reprocesso
							cOpeTrk := 'L'
							nOpeQtd := 28   //Move qtde de bloqueado para reprocesso 
					EndCase
			
				Case DL8->DL8_STATUS == '7' 
					Do Case
						Case cStatus == '2'  //De cancelado para planejamento
							cOpeTrk := 'K'
							nOpeQtd := 16
					EndCase
			EndCase
			
			If !Empty(cOpeTrk) .And. nOpeQtd > 0
				RecLock("DL8",.F.)
				DL8->DL8_STATUS := cStatus
				If DL8->(ColumnPos('DL8_MOTSTA')) > 0
					DL8->DL8_MOTSTA := cMotStatus
				EndIf
				DL8->(MsUnlock())
			
				TmIncTrk('2', DL8->DL8_FILIAL, DL8->DL8_COD, DL8->DL8_SEQ, DL8->DL8_PLNDMD,cOpeTrk,,cMotStatus) 
				TMUpQtMDmd(DL8->DL8_FILIAL, DL8->DL8_CRTDMD, DL8->DL8_CODGRD, DL8->DL8_TIPVEI, DL8->DL8_SEQMET, DL8->DL8_QTD, nOpeQtd)
			Else
				aRetBox := RetSx3Box( Posicione('SX3', 2, 'DL8_STATUS', 'X3CBox()' ),,, Len(DL8->DL8_STATUS) )
				aRet[1] := .F.
				aRet[2] := STR0055 + aRetBox[Val(DL8->DL8_STATUS)][1] + STR0056 + aRetBox[Val(cStatus)][1] + STR0057 //Atualização de status da demanda de " + DL8->DL8_STATUS + " para " + cStatus + " não suportada."
			EndIf
		EndIf
	EndIf

aEval(aAreas,{|x| RestArea(x)})

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TmGetOpeQtd
Função retorna código da operação quando depender do status do planejamento.
É utilizada para quando a demanda estiver vinculada à um planejamento. É necessário ler o status do planejamento
para determinar origem/destino da quantidade.
Se estiver em programação (igual a 6), a operação irá mover as quantidades considerando os campos DL7_QTDPRG/DLG_QTDPRG. 
Se estiver em viagem  (diferente de 6), a operação irá mover as quantidades considerando os campos DL7_QTDVIA/DLG_QTDVIA.
@author	Wander Horongoso 
@version	1.0
@since		18/04/2019
@param
cCod: código do planejamento.
nOpePrg: código da operação a ser atribuído se o status do planejamento for 6=Em programação
nOpeVia: código da operação a ser atribuído se o status do planejamento for diferente de 6=Em programação
/*/
//-------------------------------------------------------------------
Function TmGetOpeQtd(cCod, nOpePrg, nOpeVia)
Local cDL9Status := ''
Local nRet := 0

	If !Empty(cCod)
		DL9->(DbClearFilter())
		DL9->(DbSetOrder(1))
		DL9->(dbSeek(FwFilial('DL9') + cCod))
		cDL9Status := DL9->DL9_STATUS

		If !Empty(cDL9Status)
			Iif (cDL9Status == "6", nRet := nOpePrg, nRet := nOpeVia) 
		EndIf		
	EndIf
	
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TmsDmdXDoc
Função que busca os documentos (coleta, conhecimentos normais, de reentrega, devolução) vinculados à uma demanda
Função que busca demandas a partir de um documento.
A função possui 2 funcionalidades para manter a mesma lógica de busca de relacionamento, ora a partir da demanda ora a partir dos documentos do TMS

@author	Wander Horongoso 
@version	1.0
@since		08/02/2019
@param
cCod: código da demanda. Usado para busca de documentos por demanda.
cSeq: sequência da demanda. Usado para busca de documentos por demanda.
cFilDoc: filial do documento. Usado para busca de demandas por documento.
cDoc: número do documento (coleta, ctrc). Usado para busca de demandas por documento.
cSerie: série do documento. Usado para busca de demandas por documento.
lConcCanc: indica se documentos cancelados serão considerados na busca
/*/
//-------------------------------------------------------------------
Function TmsDmdXDoc(cCod, cSeq, cFilDoc, cDoc, cSerie, lConsCanc) 
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
Local aRet      := {}
Local nTipDoc   := 0

Default cCod      := ''
Default cSeq      := ''
Default cFilDoc   := ''
Default cDoc      := ''
Default cSerie    := ''  
Default lConsCanc := .T.


	If !Empty(cCod) .And. !Empty(cSeq) //busca por demanda
		nTipDoc := 1
	ElseIf !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie) //busca por documento
		nTipDoc := 2
	EndIf
	
	If nTipDoc > 0

		//Coletas		
		If nTipDoc == 1
			cQuery := " SELECT DISTINCT DT5.DT5_FILDOC, DT5.DT5_DOC, DT5.DT5_SERIE"
		ElseIf nTipDoc == 2
			cQuery := " SELECT DISTINCT DT5.DT5_CODDMD, DT5.DT5_SEQDMD"
		EndIf

		cQuery += "  FROM " + RetSqlName("DT5") + " DT5 " 
		cQuery += " WHERE DT5.DT5_FILIAL = '" + xFilial('DT5') + "'"
		cQuery += "   AND DT5.D_E_L_E_T_ = '' "
		
		Iif (!lConsCanc, cQuery += " AND DT5.DT5_STATUS <> '9'",)
		
		If nTipDoc == 1
			cQuery += " AND DT5.DT5_CODDMD = '" + cCod + "'"			
			cQuery += " AND DT5.DT5_SEQDMD = '" + cSeq + "'"
		ElseIf nTipDoc == 2
			cQuery += " AND DT5.DT5_FILDOC = '" + cFilDoc + "'"
			cQuery += " AND DT5.DT5_DOC = '"    + cDoc + "'"
			cQuery += " AND DT5.DT5_SERIE = '"  + cSerie + "'"
		EndIf

		cQuery += "  UNION " //Conhecimentos normais
		If nTipDoc == 1
			cQuery += " SELECT DISTINCT DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE"
		ElseIf nTipDoc == 2
			cQuery += " SELECT DISTINCT DT5.DT5_CODDMD, DT5.DT5_SEQDMD"
		EndIf
		cQuery += "   FROM " + RetSqlName("DT5") + " DT5 "
		cQuery += "	  JOIN " + RetSqlName("DTC") + " DTC "
		cQuery += "	    ON DTC.DTC_FILCFS = DT5_FILORI"
		cQuery += "	   AND DTC.DTC_NUMSOL = DT5.DT5_DOC"
		cQuery += "	  JOIN " + RetSqlName("DT6") + " DT6 "
		cQuery += "     ON DT6.DT6_FILDOC = DTC.DTC_FILDOC"
		cQuery += "    AND DT6.DT6_DOC = DTC.DTC_DOC"
		cQuery += "    AND DT6.DT6_SERIE = DTC.DTC_SERIE"
		cQuery += "  WHERE DT5.DT5_FILIAL = '" + xFilial('DT5') + "'" 
		cQuery += "    AND DTC.DTC_FILIAL = '" + xFilial('DTC') + "'"
		cQuery += "    AND DT6.DT6_FILIAL = '" + xFilial('DT6') + "'"
		cQuery += "    AND DT5.D_E_L_E_T_ = ''"
		cQuery += "    AND DTC.D_E_L_E_T_ = ''"
		cQuery += "    AND DT6.D_E_L_E_T_ = ''"
		
		If !lConsCanc
			cQuery += " AND DT5.DT5_STATUS <> '9'"
			cQuery += " AND DT6.DT6_STATUS <> '9'"
		EndIf			

		If nTipDoc == 1
			cQuery += " AND DT5.DT5_CODDMD = '" + cCod + "'"
			cQuery += " AND DT5.DT5_SEQDMD = '" + cSeq + "'"
		ElseIf nTipDoc == 2
			cQuery += " AND DT6.DT6_FILDOC = '" + cFilDoc + "'"
			cQuery += " AND DT6.DT6_DOC = '"    + cDoc + "'"
			cQuery += " AND DT6.DT6_SERIE = '"  + cSerie + "'"
		EndIf 
		
		cQuery += " UNION " //Conhecimentos de reentrega/devolução
		
		If nTipDoc == 1
			cQuery += " SELECT DISTINCT DT6C.DT6_FILDOC, DT6C.DT6_DOC , DT6C.DT6_SERIE"
		ElseIf nTipDoc == 2
			cQuery += "SELECT DISTINCT DT5_CODDMD,DT5_SEQDMD"
		EndIf

		cQuery += "   FROM " + RetSqlName("DT5") + " DT5 "
		cQuery += "	  JOIN " + RetSqlName("DTC") + " DTC "
		cQuery += "     ON DTC.DTC_FILCFS = DT5_FILORI"
		cQuery += "	   AND DTC.DTC_NUMSOL = DT5.DT5_DOC"
		cQuery += "	  JOIN " + RetSqlName("DT6") + " DT6 "
		cQuery += "     ON DT6.DT6_FILDOC = DTC.DTC_FILDOC"
		cQuery += "    AND DT6.DT6_DOC = DTC.DTC_DOC"
		cQuery += "    AND DT6.DT6_SERIE = DTC.DTC_SERIE"
		cQuery += "   JOIN " + RetSqlName("DT6") + " DT6C"
		cQuery += "     ON DT6C.DT6_FILDCO = DT6.DT6_FILDOC"
		cQuery += "    AND DT6C.DT6_DOCDCO = DT6.DT6_DOC"
		cQuery += "    AND DT6C.DT6_SERDCO = DT6.DT6_SERIE"
		cQuery += "  WHERE DT5.DT5_FILIAL  = '"  + xFilial('DT5') + "'"
		cQuery += "	   AND DTC.DTC_FILIAL  = '"  + xFilial('DTC') + "'"
		cQuery += "	   AND DT6.DT6_FILIAL  = '"  + xFilial('DT6') + "'"
		cQuery += "	   AND DT6C.DT6_FILIAL = '" + xFilial('DT6') + "'"
		cQuery += "    AND DT5.D_E_L_E_T_  = ''
		cQuery += "	   AND DTC.D_E_L_E_T_  = ''"
		cQuery += "    AND DT6.D_E_L_E_T_  = ''"
		cQuery += "    AND DT6C.D_E_L_E_T_ = ''"
		
		If !lConsCanc
			cQuery += " AND DT5.DT5_STATUS <> '9'"
			cQuery += " AND DT6.DT6_STATUS <> '9'"
			cQuery += " AND DT6C.DT6_STATUS <> '9'"
		EndIf			

		If nTipDoc == 1
			cQuery += " AND DT5.DT5_CODDMD = '" + cCod + "'"
			cQuery += " AND DT5.DT5_SEQDMD = '" + cSeq + "'"		
		ElseIf nTipDoc == 2
			cQuery += " AND DT6C.DT6_FILDOC = '" + cFilDoc + "'"
			cQuery += " AND DT6C.DT6_DOC = '"    + cDoc + "'"
			cQuery += " AND DT6C.DT6_SERIE = '"  + cSerie + "'"
		EndIf
		 
		cQuery := ChangeQuery( cQuery )	
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.F.,.T.)

		While (cAliasQry)->(!Eof())
			If nTipDoc == 1
				If aScan(aRet,{|x| x[1]+x[2]+x[3] ==  (cAliasQry)->DT5_FILDOC, (cAliasQry)->DT5_DOC, (cAliasQry)->DT5_SERIE }) == 0 
					aAdd(aRet, {(cAliasQry)->DT5_FILDOC, (cAliasQry)->DT5_DOC, (cAliasQry)->DT5_SERIE})
				EndIf
			ElseIf nTipDoc == 2
				If aScan(aRet,{|x| x[1]+x[2] ==  (cAliasQry)->DT5_CODDMD, (cAliasQry)->DT5_SEQDMD }) == 0 
					aAdd(aRet, {(cAliasQry)->DT5_CODDMD, (cAliasQry)->DT5_SEQDMD})
				EndIf
			EndIf
			
			(cAliasQry)->(DbSkip())	
		EndDo                                                  
	
		(cAliasQry)->(DbCloseArea())
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TmsPrgDmd()
Retorna dados da programação de carregamento conforme codigo do planejamento.
@author  Marlon Augusto Heiber	
@since   03/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TmsPrgDmd(cCodPln)
Local aProgCar  := {}
Local cQueryDF8 := ''
Local cAliasDF8 := ''

	If DF8->(ColumnPos("DF8_PLNDMD")) > 0
		cAliasDF8 := GetNextAlias()
		cQueryDF8 := " SELECT DF8_NUMPRG, DF8_VIAGEM "
		cQueryDF8 += "   FROM "+RetSqlName('DF8')+ " DF8 "
		cQueryDF8 += "  WHERE DF8_FILIAL = '" + xFilial('DF8') + "' "
		cQueryDF8 += "    AND DF8_PLNDMD = '"+cCodPln+"' " 
		cQueryDF8 += "    AND DF8_STATUS <> '9' " 
		cQueryDF8 += "    AND D_E_L_E_T_ = ' ' "
		cQueryDF8 := ChangeQuery( cQueryDF8 )
		DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryDF8 ) , cAliasDF8, .F., .T. )	
		
		If !Empty((cAliasDF8)->DF8_NUMPRG) 
			Aadd(aProgCar,{(cAliasDF8)->DF8_NUMPRG,Iif(ValType((cAliasDF8)->DF8_VIAGEM) <> 'U',(cAliasDF8)->DF8_VIAGEM, " ")})
		EndIf
		
		(cAliasDF8)->(DbCloseArea())
	EndIf
Return aProgCar

//---------------------------------------------------------------------------------
/*/{Protheus.doc} VldColDMD
Funcao para validar assuntos a coletas via gestao de demandas 
@author  Ruan Ricardo Salvador	
@param   Opcoes de validacoes: 
          1 - Valida se filial de execucao da demanda eh igual a filial 
          informada na regiao de origem     
@param   oModel - Modelo de rigioes
@param   cValor - Valor do campo a validar
@since   16/08/2018
@version 12.1.17
/*/
//---------------------------------------------------------------------------------
Function VldColDMD(nOpc, oModel, cValor)
	Local nOperation := 0
	Local nX 		 := 0
	Local lRet 		 := .T.	
	Local lTMSDCol 	 := SuperGetMv("MV_TMSDCOL",,.F.)	//-- Desconsidera filial de origem da solicitação de coleta.

	Default nOpc 	:= 0	
	Default oModel 	:= ''
	Default cValor 	:= ''
	
	If !lTMSDCol
		//Opcao de validacoes 
		Do Case 
			Case nOpc == 1 //Valida se filial de execucao da demanda eh igual a filial informada na regiao de origem
				nOperation:= oModel:GetOperation()
				If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE 
					For nX := 1 to oModel:GetQtdLine()
						oModel:GoLine(nX)
						If cValor != Posicione("DUY", 1, xFilial("DUY") + oModel:GetValue("DLA_CODREG"), "DUY_FILDES") .And. !oModel:IsDeleted(nX)
							Help( ,, 'Help',, STR0037 + oModel:GetValue("DLA_CODREG"), 1, 0,,,,,, {STR0038} ) //Filial de execucao da demanda esta diferente da filial informada para regiao origem:
							lRet := .F.
							Exit
						EndIf
					Next nX
				EndIf
			Case nOpc == 2
				//Realizar as proximas validacoes aqui
			Otherwise
				lRet := .T.	
		EndCase
	EndIf 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TClearFKey
Limpa SetKey das teclas de função
@author  Gustavo Krug
@since   21/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TClearFKey()

	SetKey(VK_F2,Nil)
	SetKey(VK_F3,Nil)
	SetKey(VK_F4,Nil)
	SetKey(VK_F5,Nil)
	SetKey(VK_F6,Nil)
	SetKey(VK_F7,Nil)
	SetKey(VK_F8,Nil)
	SetKey(VK_F9,Nil)
	SetKey(VK_F10,Nil)
	SetKey(VK_F11,Nil)
	SetKey(VK_F12,Nil)

Return

/*/{Protheus.doc} TMSCanPln
//Cancela o planejamento
@author ruan.salvador
@since 22/11/2018
@version 1.0
@param cNumViag, characters, numero da viagem
@type function
/*/
Function TMSCanPln(cNumViag, cStatus)
	Local cAliasDF8 := GetNextAlias()
	Local cQuery := ''
	
	Local nIndex	:= DL9->(IndexOrd())
	
	Local aAreaDL9 := DL9->(GetArea())

	cQuery := "SELECT DF8_PLNDMD, DL9.DL9_STATUS "
	cQuery += "  FROM "+RetSqlName('DF8')+ " DF8 "
	cQuery += "        INNER JOIN "+RetSqlName('DL9')+ " DL9 "
	cQuery += "           ON DL9.DL9_FILIAL = '" + xFilial('DL9') + "' ""
	cQuery += "          AND DL9.DL9_COD = DF8.DF8_PLNDMD "
	cQuery += "          AND DL9.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE DF8.DF8_FILIAL = '" + xFilial('DF8') + "' "
	cQuery += "   AND DF8.DF8_VIAGEM = '" + cNumViag + "' "  
	cQuery += "   AND DF8.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery( cQuery )
	DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasDF8, .F., .T. )	
	
	DL9->(DbSetOrder(1))
	If DL9->(DbSeek(xFilial("DL9") + (cAliasDF8)->DF8_PLNDMD ))
		RecLock("DL9",.F.)
		DL9->DL9_STATUS := cStatus
		DL9->(MsUnlock())
		
		If cStatus == "7" .And. (cAliasDF8)->DL9_STATUS <> "7"
			//Tracking de estorno cancelamento do planejamento
			TmIncTrk('3', xFilial("DL9"), (cAliasDF8)->DF8_PLNDMD,/*cSeqDoc*/,/*cDocPai*/,'K',/*cCodMotOpe*/,/*cObs*/,/*cTpRecusa*/,/*cCodProg*/,/*cCodViagem*/)
		ElseIf cStatus == "8" .And. (cAliasDF8)->DL9_STATUS <> "8"
			//Tracking de cancelamento do planejamento
			TmIncTrk('3', xFilial("DL9"), (cAliasDF8)->DF8_PLNDMD,/*cSeqDoc*/,/*cDocPai*/,'J',/*cCodMotOpe*/,/*cObs*/,/*cTpRecusa*/,/*cCodProg*/,/*cCodViagem*/)
		EndIf
	EndIf
		
	(cAliasDF8)->(DbCloseArea())
	
	DL9->(DbSetOrder(nIndex))
	RestArea(aAreaDL9)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TStrItens
Retorna uma string listando os itens passados por parâmetro, para 
facilitar a montagem de mensagens dinâmicas com 1 ou N itens. 
	Exemplo: Possuo em um array os itens {Item1, Produto2, Mesa3}
			 A função irá retornar uma string "Item1, Produto2 e Mesa3"
@param aItens, array, Array com itens que irão compor mensagem
@author  Gustavo Krug
@since   27/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function TStrItens(aItens)
	Local cItens := ''
	Local nX := 1
	
	If !Empty(aItens)
		cItens += aItens[1]
	EndIf
	
	For nX := 2 to Len(aItens)
		cItens += Iif( nX == Len(aItens) ,  " e " , ", ") + aItens[nX]
	Next

Return cItens

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSCLegDmd
Retorna a cor do status de um campo a partir do conteúdo dele.
@type function
@author Natália Maria Neves
@version 12.1.17
@since 26/07/2018
/*/
//-------------------------------------------------------------------------------------------------
Function TMSCLegDmd(cField, cValor)
Local cRet := ''

	If cField == 'DL8_STATUS'
		Do Case
			Case cValor == '1';	cRet := "BR_VERDE"
			Case cValor == '2';	cRet := "BR_LARANJA"
			Case cValor == '3';	cRet := "BR_VERMELHO"
			Case cValor == '4';	cRet := "BR_AZUL"
			Case cValor == '5';	cRet := "BR_AMARELO"
			Case cValor == '6';	cRet := "BR_CINZA"			
			Case cValor == '7';	cRet := "BR_PRETO"
			Otherwise;			cRet := "BR_BRANCO"
		EndCase
	EndIf

Return cRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSLegDmd
Exibe a legenda da demanda.
@type function
@author Wander Horongoso.
@version 12.1.17
@since 31/01/2019
/*/
//-------------------------------------------------------------------------------------------------
Function TMSLegDmd(cField)
Local aLegenda  := {}
	
	If Upper(cField) == 'DL8_STATUS' .Or. Upper(cField) == 'DL8_LEGDMD'
		aLegenda := TMSStaDmd(cField, 2)
	EndIf
	
	If Len (aLegenda) > 0
		BrwLegenda(STR0054,STR0054, aLegenda) // Legenda
	EndIf
	
Return .T.


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSLegDmd
Retorna, em um array, a descrição dos status da demanda, juntamente com o valor ou a cor respectiva.
É usado para as legendas e para F3 multivalorado da consulta de demandas.
@type function
@author Wander Horongoso
@version 12.1.17
@since 31/01/2019
@param
cField: Campo de status do documento;
nTipo: tipo da informação que será retornada junto à descrição, podendo ser 1-Código ou 2-Cor.
/*/
//-------------------------------------------------------------------------------------------------
Function TMSStaDmd(cField, nTipo)
Local aLegenda  := {}
	
	If Upper(cField) == 'DL8_STATUS' .Or. Upper(cField) == 'DL8_LEGDMD'
		Aadd(aLegenda,{Iif(nTipo==1, "1", "BR_VERDE"),   STR0047}) //Aberta
		Aadd(aLegenda,{Iif(nTipo==1, "2", "BR_LARANJA"), STR0048}) //Planejada
		Aadd(aLegenda,{Iif(nTipo==1, "3", "BR_VERMELHO"),STR0049}) //Recusada
		Aadd(aLegenda,{Iif(nTipo==1, "4", "BR_AZUL"),    STR0053}) //Finalizada
		Aadd(aLegenda,{Iif(nTipo==1, "5", "BR_AMARELO"), STR0052}) //Em Reprocesso
		Aadd(aLegenda,{Iif(nTipo==1, "6", "BR_CINZA"),   STR0050}) //Bloqueada
		Aadd(aLegenda,{Iif(nTipo==1, "7", "BR_PRETO"),   STR0051}) //Cancelada
	EndIf

Return aLegenda

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsAutCmt
Realiza a validação da automação, verificando o conteúdo dos registros criados.
@type function
@author Wander Horongoso
@version 12.1.17
@since 31/03/2019
@param
oHelper: objeto helper da automação
lAssert: indica se a automção deve retornar execução com (.T.) ou sem (.F.) sucesso.
lCommit: Se verdadeiro  efetua o commit. Senão não faz, pois já foi feito externamente.
aFields: relação de campos a serem validados.
	aFields[1]: nome do campo
	aFields[2]: conteúdo do campo
	aFields[3]: se o campo será usado para a pesquisa/condição where (.T.) ou para validação do contéudo gravado (.F.).
/*/
//-------------------------------------------------------------------------------------------------
Function TmsAutCmt(oHelper, lAssert, lCommit, aFields)
Local cQuery := ''
Local cTable := ''
Local nTable := 0
Local nField := 0
Local xVal := nil

	If lCommit
		lCommit := oHelper:UTCommitData()
	Else
		lCommit := .T.		
	EndIf	
	
	If lCommit
		For nTable := 1 to Len(aFields)
			cTable := aFields[nTable][1] 
			cQuery := cTable + "." + cTable + "_FILIAL = '" + xFilial(cTable) + "'"
			
			For nField := 1 To Len(aFields[nTable][2])
				If aFields[nTable][2][nField][3]
				    xVal := aFields[nTable][2][nField][2]
	
				    Iif (ValType(xVal) == 'C', xVal := "'" + xVal + "'",)
				    
					cQuery  += ' AND ' + cTable + "." + aFields[nTable][2][nField][1] + " = " + xVal
				EndIf
			Next nField
			
			For nField := 1 To Len(aFields[nTable][2])
				If !aFields[nTable][2][nField][3]				
					xVal := aFields[nTable][2][nField][2]

					Iif (ValType(xVal) == 'D', xVal := DTOS(xVal),)

					oHelper:UTQueryDB(cTable,aFields[nTable][2][nField][1], cQuery, aFields[nTable][2][nField][2])
				EndIf			
			Next nField
	
		Next nTable
	EndIf

	Iif (lAssert, oHelper:AssertTrue(),  oHelper:AssertFalse())

Return oHelper