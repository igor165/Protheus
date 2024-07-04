#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMBROWSE.CH'

#DEFINE nTamAlatur 10

//-------------------------------------------------------------------
/*/{Protheus.doc} FINWS003

Tela de monitoramento da integração Protheus x Copastur

@author  CM Solutions - Allan Constantino Bonfim
@since   28/11/2019
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
User Function FINWS003()

	Local aArea			:= GetArea()
	
	Private nTamLinha		:= 16
	Private cTel1Tmp1		:= GetNextAlias()
	Private cTel1Tmp2		:= GetNextAlias()	
	Private cTel1Tmp3		:= GetNextAlias()
	Private oTempBrw1
	Private oTempBrw2 	
	Private oTempBrw3
	Private oBrowse1
	Private oBrowse2
	Private oBrowse3	
	Private oBrowseCad
	Private oBrowseDet
	Private oBrowseInt
	Private aParamTmp
	
	FIWS3KEY(0)
	FIWS3KEY()
	
	//Tela de Parametros
	aParamTmp := FIWS3PAR(.T., .F.)
	
	If Len(aParamTmp) >= 4
		FWMsgRun(, {|| FIWS3EXE(aParamTmp)}, "Processando...", "Aguarde o carregamento da tela...")
	EndIf
	
	FIWS3KEY(0)
	
	If Select(cTel1Tmp1) > 0
		(cTel1Tmp1)->(DbCloseArea())
	EndIf
	
	If Select(cTel1Tmp2) > 0
		(cTel1Tmp2)->(DbCloseArea())
	EndIf

	If Select(cTel1Tmp3) > 0
		(cTel1Tmp3)->(DbCloseArea())
	EndIf

	RestArea(aArea)
Return         


//-------------------------------------------------------------------
/*/{Protheus.doc} FIWS3PAR

Parâmetros da rotina

@author  CM Solutions - Allan Constantino Bonfim
@since   30/08/2019
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
Static Function FIWS3PAR(lInit, lRefresh)

	Local aParambox		:= {}
	Local aRet			:= {}
	Local aOption1		:= {"1=Todos", "2=Em Processamento",  "3=Erros", "4=Integrados"}
	Local aOption2		:= {"1=Todos", "2=Adiantamento", "3=Despesas/Reembolsos"}
	Local aOption3		:= {"1=Todos", "2=Pagamento Pendente", "3=Pago"}

	Default lInit		:= .F.
	Default lRefresh	:= .F.
	
	If !lRefresh
		aAdd(aParambox, {2, "Situação"			, "1", aOption1, 80, ".T.", .F.})
		AADD(aParambox ,{1, "Participante:"		, SPACE(TAMSX3("RD0_CODIGO")[1])	, PesqPict("RD0", "RD0_CODIGO"), ".T.", "RD0", ".T.", 50, .F.})
		AADD(aParambox ,{1, "Centro de Custos:"	, SPACE(TAMSX3("CTT_CUSTO")[1])		, PesqPict("CTT", "CTT_CUSTO"), ".T.", "CTT", ".T.", 20, .F.})
		AADD(aParambox ,{1, "Aprovador:"		, SPACE(TAMSX3("RD0_CODIGO")[1])	, PesqPict("RD0", "RD0_CODIGO"), ".T.", "RD0", ".T.", 50, .F.})
		AADD(aParambox, {2, "Financeiro"		, "1", aOption2, 80, ".T.", .F.})
		AADD(aParambox, {2, "Título"			, "1", aOption3, 80, ".T.", .F.})
		AADD(aParambox ,{1, "Vencimento de:"	, CTOD("")							, PesqPict("SE2", "E2_VENCREA"), ".T.", "", ".T.", 50, .F.})
		AADD(aParambox ,{1, "Vencimento até:"	, CTOD("")							, PesqPict("SE2", "E2_VENCREA"), ".T.", "", ".T.", 50, .F.})

		//AADD(aParambox ,{1, "Status:"				, SPACE(TAMSX3("ZWQ_STATUS")[1])	, PesqPict("ZWQ", "ZWQ_STATUS"), ".T.", "", ".T.", 50, .F.})
		//AADD(aParambox ,{1, "Ação:"				, SPACE(TAMSX3("ZZB_CODIGO")[1])		, PesqPict("ZZB", "ZZB_CODIGO"), ".T.", "ZZB001", ".T.", 50, .F.})
		//AADD(aParambox ,{1, "Banco de:"			, SPACE(TAMSX3("A6_COD")[1])			, PesqPict("SA6", "A6_COD"), ".T.", "SA6BCO", ".T.", 50, .F.})
		//ADD(aParambox ,{1, "Banco até:"		, REPLICATE("Z", TAMSX3("A6_COD")[1])	, PesqPict("SA6", "A6_COD"), ".T.", "SA6BCO", ".T.", 50, .F.})
		//AADD(aParambox ,{1, "Tipo:"				, SPACE(TAMSX3("E1_TIPO")[1])			, PesqPict("SE1", "E1_TIPO"), ".T.", "05", ".T.", 50, .F.})
		//AADD(aParambox ,{1, "Natureza:"			, SPACE(TAMSX3("E1_NATUREZ")[1])		, PesqPict("SE1", "E1_NATUREZ"), ".T.", "SED", ".T.", 50, .F.})
		//AADD(aParambox ,{1, "Data Follow Up:"	, CTOD("")								, PesqPict("ZZF", "ZZF_DTFWUP"), ".T.", "", ".T.", 50, .F.})
					
		If ParamBox(aParambox, "Painel Copastur - Parâmetros",@aRet,,,,,,, "FINWS003", .T., .T.)
			aParamTmp 	:= aClone(aRet)			
			
			If lInit
				//FWMsgRun(, {|| U_FIWS3TMP(1, cTel1Tmp1, aRet), U_FIWS3TMP(2, cTel1Tmp2, aRet), U_FIWS3TMP(3, cTel1Tmp3, aRet)}, "Processando...", "Aguarde o carregamento da tela...")
			Else
				FWMsgRun(, {|| FIWS3REF(.T., .F.)}, "Processando...", "Aguarde o carregamento da tela...")
			EndIf							
		EndIf
	Else		
		FIWS3REF()	
	EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FIWS3REF

Refresh dos Objetos da tela

@author  CM Solutions - Allan Constantino Bonfim
@since   30/08/2019
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
Static Function FIWS3REF(lRecall, lConfirma)

	Local lRefresh 		:= .T.
	
	Default lRecall		:= .F.
	Default lConfirma 	:= .F.
	
	If lConfirma
		lRefresh := MsgYesNo("Deseja atualizar as informações apresentadas na tela? ATENÇÃO: Todas as alterações realizadas serão perdidas.", "FIWS3REF")
	EndIf
	
	If lRefresh	
		/*If Type("oBrowseCad") == "O"
			If lRecall	
				If Select(cTmpCad) > 0
					(cTmpCad)->(DbCloseArea())
				EndIf
				
				If Select(cTmpInt) > 0
					(cTmpInt)->(DbCloseArea())
				EndIf
				
				If IsInCallStack("U_FINWS03B")				
					cTmpCad := U_FIWS3TMP(4, cTmpCad, aParamTmp)
				Else
					cTmpCad := U_FIWS3TMP(5, cTmpCad, aParamTmp)
				EndIf
				
				cTmpInt := U_FIWS3TMP(6, cTmpInt, aParamTmp)
			EndIf
						
			oBrowseCad:Refresh(.T.)
			oBrowseCad:OnChange()			
			oBrowseInt:Refresh(.T.)
			oBrowseInt:OnChange()
		
		Else
		*/
		If Type("oBrowse1") == "O"		
			If lRecall	
				If Select(cTel1Tmp1) > 0
					(cTel1Tmp1)->(DbCloseArea())
				EndIf
				
				If Select(cTel1Tmp2) > 0
					(cTel1Tmp2)->(DbCloseArea())
				EndIf
		
				If Select(cTel1Tmp3) > 0
					(cTel1Tmp3)->(DbCloseArea())
				EndIf
				
				cTel1Tmp1 	:= U_FIWS3TMP(1, cTel1Tmp1, aParamTmp)
				cTel1Tmp2 	:= U_FIWS3TMP(2, cTel1Tmp2, aParamTmp)
				cTel1Tmp3 	:= U_FIWS3TMP(3, cTel1Tmp3, aParamTmp)
			EndIf
						
			oBrowse1:Refresh(.T.)
			oBrowse1:OnChange()			
			oBrowse2:Refresh(.T.)
			oBrowse2:OnChange()	
			oBrowse3:Refresh(.T.)
		EndIf				
	EndIf
			
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FIWS3RE1

Refresh dos Objetos da tela

@author  CM Solutions - Allan Constantino Bonfim
@since   15/12/2019
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
Static Function FIWS3RE1(lRecall, lConfirma, lRefCad, lRefInt, lRefIDet, lRefAdi, lRefDesp)

	Local lRefresh 		:= .T.
	
	Default lRecall		:= .F.
	Default lConfirma 	:= .F.
	Default lRefCad		:= .T.
	Default lRefInt		:= .T.
	Default lRefIDet	:= .T.
	Default lRefAdi		:= .F.
	Default lRefDesp	:= .F.

	If lConfirma
		lRefresh := MsgYesNo("Deseja atualizar as informações apresentadas na tela? ATENÇÃO: Todas as alterações realizadas serão perdidas.", "FIWS3REF")
	EndIf
	
	If lRefresh	
		If Type("oBrowseCad") == "O"
			If lRecall

				If lRefAdi
					If Select(cTmpAdi) > 0
						(cTmpAdi)->(DbCloseArea())
					EndIf

					cTmpAdi	:= U_FIWS3TMP(8, cTmpAdi, aParamTmp)	
				EndIf

				If lRefDesp
					If Select(cTmpDesp) > 0
						(cTmpDesp)->(DbCloseArea())
					EndIf

					cTmpDesp := U_FIWS3TMP(9, cTmpDesp, aParamTmp)
				EndIf

				If lRefIDet
					//If IsInCallStack("FINWS03C")
						If Select(cTmpDet) > 0
							(cTmpDet)->(DbCloseArea())
						EndIf
														
						cTmpDet := U_FIWS3TMP(5, cTmpDet, aParamTmp)
					//EndIf
				EndIf

				If lRefInt							
					If Select(cTmpInt) > 0
						(cTmpInt)->(DbCloseArea())
					EndIf
									
					cTmpInt := U_FIWS3TMP(6, cTmpInt, aParamTmp)
				EndIf

				If lRefCad
					If Select(cTmpCad) > 0
						(cTmpCad)->(DbCloseArea())
					EndIf
			 
					If IsInCallStack("FINWS03B")				
						cTmpCad := U_FIWS3TMP(4, cTmpCad, aParamTmp)
					ElseIf IsInCallStack("FINWS03C")									
						cTmpCad := U_FIWS3TMP(7, cTmpCad, aParamTmp)
					Else
						cTmpCad := U_FIWS3TMP(5, cTmpCad, aParamTmp)
					EndIf
				EndIf

			EndIf
						
			oBrowseCad:Refresh(.T.)
			oBrowseCad:OnChange()			
		EndIf
	EndIf
			
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FIWS3EXE

Rotina para a chamada da tela do principal do painel de cobrança

@author  CM Solutions - Allan Constantino Bonfim
@since   11/08/2019
@version P12

/*/
//-------------------------------------------------------------------   
Static Function FIWS3EXE(aParam) 

	Local aCoors 		:= FWGetDialogSize(oMainWnd) 
	Local aSeekTmp1		:= {}
	Local aSeekTmp3		:= {}
	Local aCposBrw1		:= {}
	Local aCposBrw2		:= {}
	Local aCposBrw3		:= {}
	Local oFWLayer
	Local oPanel1
	Local oPanel2
	Local oPanel3
	Local oTButton1
	Local oTButton2
	Local oTButton3
	Local oTButton4
	Local oTBar
	
	Default aParam		:= {}
	
	
		/////PAINEL PRINCIPAL
		Define MsDialog oDlg1Princ Title 'Painel de Integração Copastur' From aCoors[1], aCoors[2] To aCoors[3]-10, aCoors[4] Pixel 	
		
		//Botoes
		oTBar := TBar():New(oDlg1Princ, 50, 22, .F.,,,, .T.)		
		oTBar:Align := CONTROL_ALIGN_TOP
	
		oTButton1	:= TButton():New(00,00, "Participantes", oTBar, {|| FWMsgRun(, {|| FINWS03A()}, "Participantes...", "Aguarde o carregamento da tela...")}, 60, 22,,,,.T.,,,,,,)
		oTButton2	:= TButton():New(00,00, "Centro de Custos", oTBar, {||  FWMsgRun(, {|| FINWS03B()}, "Centro de Custos...", "Aguarde o carregamento da tela...") }, 60, 22,,,,.T.,,,,,,)
		oTButton3	:= TButton():New(00,00, "Aprovadores", oTBar, {||  FWMsgRun(, {|| FINWS03C()}, "Aprovadores...", "Aguarde o carregamento da tela...") }, 60, 22,,,,.T.,,,,,,)		
		oTButton4	:= TButton():New(00,00, "Financeiro", oTBar, {||  FWMsgRun(, {|| FINWS03D()}, "Pagamentos...", "Aguarde o carregamento da tela...") }, 60, 22,,,,.T.,,,,,,)		
		oTButton5	:= TButton():New(00,00, "Reprocessar", oTBar, {|| FWMsgRun(, {|| FIWS3RP1(oBrowse2)}, "Processando...", "Aguarde o reprocessamento da tabela integradora...")}, 60, 22,,,,.T.,,,,,,)
		oTButton6	:= TButton():New(00,00, "Detalhes", oTBar, {||  FWS03DE1(1)}, 60, 22,,,,.T.,,,,,,)
		oTButton7	:= TButton():New(00,00, "Sair", oTBar, {|| oDlg1Princ:End()}, 80, 22,,,,.T.,,,,,,)
			
		oTButton7:Align := CONTROL_ALIGN_RIGHT
		oTButton6:Align := CONTROL_ALIGN_RIGHT
		oTButton5:Align := CONTROL_ALIGN_RIGHT
		oTButton4:Align := CONTROL_ALIGN_RIGHT
		oTButton3:Align := CONTROL_ALIGN_RIGHT
		oTButton2:Align := CONTROL_ALIGN_RIGHT
		oTButton1:Align := CONTROL_ALIGN_RIGHT
		
		oFWLayer := FWLayer():New() 
		oFWLayer:Init(oDlg1Princ, .F., .T. ) 
		
		oFWLayer:AddLine('L1', 100, .F.)
		 
		oFWLayer:AddCollumn('C1', 100, .T., 'L1')
	
		oFWLayer:AddWindow('C1'	, 'P1', 'Participantes'	, 40, .T., .F.,, 'L1')
		oFWLayer:AddWindow('C1'	, 'P2', 'Integrações'	, 30, .T., .F.,, 'L1')
		oFWLayer:AddWindow('C1'	, 'P3', 'Financeiro'	, 40, .T., .F.,, 'L1')
		
		oPanel1 := oFWLayer:GetWinPanel('C1', 'P1', 'L1') 
		oPanel2 := oFWLayer:GetWinPanel('C1', 'P2', 'L1')
		oPanel3 := oFWLayer:GetWinPanel('C1', 'P3', 'L1')

		//Fecha o painel integrações
		oFWLayer:WinChgState('C1', 'P2', 'L1')
		
		/////BROWSES			
		//CLIENTES - Browse Principal
		//Estrutura e tabela temporaria
		cTel1Tmp1 	:= U_FIWS3TMP(1, cTel1Tmp1, aParam)	
		aCposBrw1 	:= FIWS3STR(1, cTel1Tmp1)
		
		oBrowse1:= FWMarkBrowse():New() //FWMBrowse
		oBrowse1:SetOwner(oPanel1) 
		oBrowse1:SetAlias(cTel1Tmp1)
		oBrowse1:SetDataTable(.T.)
		///oBrowse1:AddLegend("RD0_XALSTA = '1'", "RED", "Não Integrado")
		//oBrowse1:AddLegend("RD0_XALSTA = '2'", "YELLOW", "Pendente Integração")
		//oBrowse1:AddLegend("RD0_XALSTA = '3'", "GREEN", "Integrado")	
		oBrowse1:AddLegend("RD0STATUS = '00'", "RED", "Não Integrado")
		oBrowse1:AddLegend("RD0STATUS $ '01/02'", "YELLOW", "Pendente Integração")
		oBrowse1:AddLegend("RD0STATUS = '05'", "GREEN", "Integrado")	
		oBrowse1:SetColumns(aCposBrw1)
		oBrowse1:SetDescription('')   
		oBrowse1:SetProfileID('1') 
		oBrowse1:DisableReport() 
		oBrowse1:DisableConfig()
		oBrowse1:DisableLocate()
		oBrowse1:SetLineHeight(nTamLinha)
		oBrowse1:SetDoubleClick({|| FWMsgRun(, {|| FWS03DET(1, oBrowse1)}, "Participantes...", "Aguarde o carregamento da tela...")})	
		
		aSeekTmp1 := {	{"Codigo"	, {{"","C", 06, 0, "RD0_CODIGO", "@!"}}},;
						{"Nome"		, {{"","C", 30, 0, "", "@!"}}},;
						{"CPF"		, {{"","C", 11, 0, "", "@!"}}}} 	
								
		oBrowse1:SetSeek(.T., aSeekTmp1)

		oBrowse1:Activate()
		oBrowse1:oBrowse:Setfocus()
		
	
		//TITULOS - Browse Central
		//Estrutura e tabela temporaria	
		cTel1Tmp2 	:= U_FIWS3TMP(2, cTel1Tmp2, aParam)	
		aCposBrw2 	:= FIWS3STR(2, cTel1Tmp2)		
		
		oBrowse2:= FWBrowse():New() 
		oBrowse2:SetOwner(oPanel2) 
		oBrowse2:SetAlias(cTel1Tmp2)
		oBrowse2:SetDataTable(.T.)
		oBrowse2:AddLegend("ZWQ_STATUS = '01'", "YELLOW", "Pendente")
		oBrowse2:AddLegend("ZWQ_STATUS = '02'", "RED", "Erro")
		oBrowse2:AddLegend("ZWQ_STATUS = '05'", "GREEN", "Processado")		
		oBrowse2:SetColumns(aCposBrw2)
		oBrowse2:SetDescription('')   
		oBrowse2:SetProfileID('2') 		
		oBrowse2:DisableReport() 
		oBrowse2:DisableConfig()
		oBrowse2:DisableLocate()
		oBrowse2:SetLineHeight(nTamLinha)
		oBrowse2:SetDoubleClick({|| FWMsgRun(, {|| FWS03DET(2, oBrowse2)}, "Integrações...", "Aguarde o carregamento da tela...")})

		oBrowse2:Activate()			
	
	
		//HISTORICO - Browse Esquerda Baixo
		//aCposBrw3 := FIWS3STR(3, 'ZZF')
		cTel1Tmp3 	:= U_FIWS3TMP(3, cTel1Tmp3, aParam)
		aCposBrw3 	:= FIWS3STR(3, cTel1Tmp3)
		
		
		oBrowse3:= FWMarkBrowse():New() 
		oBrowse3:SetOwner(oPanel3) 
		oBrowse3:SetAlias(cTel1Tmp3)
		oBrowse3:SetDataTable(.T.)
		oBrowse3:AddLegend("EMPTY(E2_SALDO)", "RED", "Pago")
		oBrowse3:AddLegend("!Empty(E2_SALDO)", "GREEN", "Pagamento pendente")
		oBrowse3:SetColumns(aCposBrw3)
		oBrowse3:SetDescription('')   
		oBrowse3:SetProfileID('3') 
		oBrowse3:DisableReport() 
		oBrowse3:DisableConfig()
		oBrowse3:DisableLocate()
		oBrowse3:SetLineHeight(nTamLinha)
		oBrowse3:SetDoubleClick({|| FWMsgRun(, {|| FWS03DET(3, oBrowse3)}, "Títulos a Pagar...", "Aguarde o carregamento da tela...")})

		aSeekTmp3 := {	{"Cod. Copastur"				, {{"","C", nTamAlatur, 0, "E2_XALATUR", "@!"}}},;
						{"Número+Prefixo+Parcela+Tipo"	, {{"","C", 20, 0, "E2_NUM+E2_PREFIXO+E2_PARCELA+E2_TIPO", "@!"}}},;
						{"Vencimento"					, {{"","D", 08, 0, "E2_VENCREA", "@D"}}}}	
				
		oBrowse3:SetSeek(.T., aSeekTmp3)

		oBrowse3:Activate()
			
		Activate MsDialog oDlg1Princ Center 
		
Return NIL    


//-------------------------------------------------------------------
/*/{Protheus.doc} FIWS3KEY

WMS 100% - Atualiza as teclas de atalho após acessar outras rotinas

@author  Allan Constantino Bonfim
@since   28/09/2018
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
Static Function FIWS3KEY(nOpcao)

	Default nOpcao := 1
	
	If nOpcao == 0
		SetKey(VK_F5, {|| })
		//SetKey(VK_F6, {|| })
		SetKey(VK_F10, {|| })
	Else
		//SetKey(VK_F5, {|| FIWS3PAR(.F., .T.)})
		SetKey(VK_F5, {|| FWMsgRun(, {|| FIWS3PAR(.F., .T.)}, "Processando...", "Aguarde o carregamento da tela...")})
		//SetKey(VK_F6, {|| U_XTEL1DET()})
		SetKey(VK_F10, {|| FIWS3PAR(.F., .F.)})
	EndIf

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} FIWS3STR

Grid Acoes - Estrutura da tabela temporária 

@author  CM Solutions - Allan Constantino Bonfim
@since   01/09/2019
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function FIWS3STR(nOpcBrw, cAliasTmp)
	
	Local aArea			:= GetArea()
	Local aTmpStru 		:= {}
	Local aCposBrw		:= {}
	Local aCpoTmp		:= {}
	Local aCpoTmpDsc	:= {}
	Local nX			:= 0
	Local nJ			:= 0
	Local nPosCpo		:= 0
	Local cCpoBox		:= ""
	
	Default nOpcBrw		:= 0
	Default cAliasTmp	:= ""
	
	
	//If Select(cAliasTmp) > 0
		If nOpcBrw == 1 .OR. nOpcBrw == 5
	
			//Campo
			AADD(aCpoTmp, "RD0_CODIGO")
			AADD(aCpoTmp, "RD0_NOME")
			AADD(aCpoTmp, "RD0_TIPO")
			AADD(aCpoTmp, "RD0_SEXO")
			AADD(aCpoTmp, "RD0_DTNASC")
			AADD(aCpoTmp, "RD0_CIC")
			AADD(aCpoTmp, "RD0_CC")
			AADD(aCpoTmp, "RD0_EMAIL")
			AADD(aCpoTmp, "RD0_EMAILC")
			AADD(aCpoTmp, "RD0_MSBLQL")
			AADD(aCpoTmp, "RD0_FORNEC")
			AADD(aCpoTmp, "RD0_LOJA")
			AADD(aCpoTmp, "RD0_LOGINR")
			AADD(aCpoTmp, "RD0_IDRESE")
			AADD(aCpoTmp, "RD0_EMPATU")
			AADD(aCpoTmp, "RD0_FILATU")
			AADD(aCpoTmp, "RD0_APROPC")
			AADD(aCpoTmp, "RD0_XADNAP")
			AADD(aCpoTmp, "RD0_XVINAP")
			AADD(aCpoTmp, "RD0_XVNNAP")
			AADD(aCpoTmp, "RD0_XRNAPR")
			AADD(aCpoTmp, "RD0_XSPTER")
			AADD(aCpoTmp, "RD0_XNAPRO")
			AADD(aCpoTmp, "RD0_XVIP")

			//Descrição
			AADD(aCpoTmpDsc, "Código")
			AADD(aCpoTmpDsc, "Nome")
			AADD(aCpoTmpDsc, "Tipo")
			AADD(aCpoTmpDsc, "Sexo")
			AADD(aCpoTmpDsc, "Data Nascimento")
			AADD(aCpoTmpDsc, "CPF")
			AADD(aCpoTmpDsc, "Centro de Custos")
			AADD(aCpoTmpDsc, "E-mail")
			AADD(aCpoTmpDsc, "E-mail Complementar")
			AADD(aCpoTmpDsc, "Ativo")
			AADD(aCpoTmpDsc, "Codigo Fornecedor")
			AADD(aCpoTmpDsc, "Loja Fornecedor")
			AADD(aCpoTmpDsc, "Login")
			AADD(aCpoTmpDsc, "ID")
			AADD(aCpoTmpDsc, "Empresa")
			AADD(aCpoTmpDsc, "Filial")
			AADD(aCpoTmpDsc, "Aprovador")
			AADD(aCpoTmpDsc, "Adiantamento s/ aprovar")
			AADD(aCpoTmpDsc, "Viagem internacional s/ aprovar")
			AADD(aCpoTmpDsc, "Viagem nacional s/ aprovar")
			AADD(aCpoTmpDsc, "Reembolso s/ aprovar")
			AADD(aCpoTmpDsc, "Solicitações p/ terceiros")
			AADD(aCpoTmpDsc, "Solicitações s/ aprovar")
			AADD(aCpoTmpDsc, "VIP")

			aTmpStru 	:= (cAliasTmp)->(DBStruct())
			cCpoBox		:= "RD0_TIPO/RD0_SEXO/RD0_MSBLQL/RD0_XADNAP/RD0_XVINAP/RD0_XVNNAP/RD0_XRNAPR/RD0_XSPTER/RD0_XNAPRO/RD0_XVIP"

			nJ := 1
			For nX := 1 to Len(aCpoTmp)
				nPosCpo := ASCAN(aTmpStru, {|x| x[1] == aCpoTmp[nX]})
				
				If nPosCpo > 0				
					AADD(aCposBrw, FWBrwColumn():New() )

					If Alltrim(aTmpStru[nPosCpo][1]) $ cCpoBox
						If Alltrim(aTmpStru[nPosCpo][1]) == "RD0_TIPO"
							aCposBrw[nJ]:aOptions := {"1=INTERNO", "2=EXTERNO"}
						ElseIf Alltrim(aTmpStru[nPosCpo][1]) == "RD0_SEXO"
							aCposBrw[nJ]:aOptions := {"F=FEMININO", "M=MASCULINO"}
						Else
							aCposBrw[nJ]:aOptions := STRTOKARR(UPPER(ALLTRIM(GetSX3Cache(aTmpStru[nPosCpo][1], "X3_CBOX"))), ";")
						EndIf
					EndIf

					aCposBrw[nJ]:SetData(&("{||" + aTmpStru[nPosCpo][1] + "}"))
					aCposBrw[nJ]:SetTitle(aCpoTmpDsc[nX])
					aCposBrw[nJ]:SetSize(aTmpStru[nPosCpo][3])
					
					aCposBrw[nJ]:SetDecimal(aTmpStru[nPosCpo][4])
					If ALLTRIM(aTmpStru[nPosCpo][2]) == "N"
						aCposBrw[nJ]:SetPicture("@E 999,999,999,999.99")
						aCposBrw[nJ]:SetAlign("RIGHT")			
					ElseIf ALLTRIM(aTmpStru[nPosCpo][2]) == "C"
						aCposBrw[nJ]:SetPicture("@!")
					Else
						aCposBrw[nJ]:SetPicture("")
						aCposBrw[nJ]:SetAlign("LEFT")					
					EndIf
	
					aCposBrw[nJ]:SetEdit(.F.)
					nJ++		
				EndIf
			Next

		ElseIf nOpcBrw == 2 .OR. nOpcBrw == 6

			aCpoTmp		:= {"ZWQ_CODIGO"	, "ZWQ_CODALA"	,"ZWQ_DATA"	, "ZWQ_HORA", "ZWQ_USUARI"	, "ZWQ_STATUS"	, "ZWQ_TPINCL"		, "ZWQ_TINTEG"		, "ZWQ_TPPROC"			, "ZWQ_DTINTE"		, "ZWQ_HRINTE"		, "ZWQ_USINTE"			, "ZWQ_ERRO"	, "ZWQ_DTREPR"				, "ZWQ_HRREPR"				, "ZWQ_USREPR"}
			aCpoTmpDsc	:= {"Codigo"		, "Cod Copastur", "Data"	, "Hora"	, "Usuário"		, "Status"		, "Tipo Inclusão"	, "Tipo Integração"	, "Tipo Processamento"	, "Data Integração"	, "Hora Integração"	, "Usuário Integração"	, "Erro"		, "Data Reprocessamento"	, "Hora Reprocessamento"	, "Usuário Reprocessamento"}
			
			aTmpStru 	:= (cAliasTmp)->(DBStruct())
			cCpoBox		:= "ZWQ_TPINCL/ZWQ_TINTEG/ZWQ_TPPROC"

			nJ := 1
			For nX := 1 to Len(aCpoTmp)
				nPosCpo := ASCAN(aTmpStru, {|x| x[1] == aCpoTmp[nX]})
				
				If nPosCpo > 0				
					AADD(aCposBrw, FWBrwColumn():New() )

					If Alltrim(aTmpStru[nPosCpo][1]) $ cCpoBox
						aCposBrw[nJ]:aOptions := STRTOKARR(UPPER(ALLTRIM(GetSX3Cache(aTmpStru[nPosCpo][1], "X3_CBOX"))), ";")
					EndIf

					aCposBrw[nJ]:SetData(&("{||" + aTmpStru[nPosCpo][1] + "}"))
					aCposBrw[nJ]:SetTitle(aCpoTmpDsc[nX])
					aCposBrw[nJ]:SetSize(aTmpStru[nPosCpo][3])
					aCposBrw[nJ]:SetDecimal(aTmpStru[nPosCpo][4])
					If ALLTRIM(aTmpStru[nPosCpo][2]) == "N"
						//aCposBrw[nJ]:SetPicture("@E 999,999,999.99")
						aCposBrw[nJ]:SetAlign("RIGHT")			
					ElseIf ALLTRIM(aTmpStru[nPosCpo][2]) == "C"
						aCposBrw[nJ]:SetPicture("@!")
					Else
						aCposBrw[nJ]:SetPicture("")
						aCposBrw[nJ]:SetAlign("LEFT")					
					EndIf
	
					aCposBrw[nJ]:SetEdit(.F.)
					nJ++		
				EndIf
			Next
	
		ElseIf nOpcBrw == 3 .OR. nOpcBrw == 8 .OR. nOpcBrw == 9

			//Campos
			AADD(aCpoTmp, "E2_XALATUR")
			AADD(aCpoTmp, "E2_FORNECE")
			AADD(aCpoTmp, "E2_LOJA")
			AADD(aCpoTmp, "E2_PREFIXO")
			AADD(aCpoTmp, "E2_NUM")
			AADD(aCpoTmp, "E2_PARCELA")
			AADD(aCpoTmp, "E2_TIPO")
			AADD(aCpoTmp, "E2_EMISSAO")
			AADD(aCpoTmp, "E2_VENCTO")
			AADD(aCpoTmp, "E2_VENCREA")
			AADD(aCpoTmp, "E2_BAIXA")
			AADD(aCpoTmp, "E2_VALOR")
			AADD(aCpoTmp, "E2_SALDO")

			//Descrição
			AADD(aCpoTmpDsc, "Código Copastur")
			AADD(aCpoTmpDsc, "Fornecedor")
			AADD(aCpoTmpDsc, "Loja")
			AADD(aCpoTmpDsc, "Prefixo")
			AADD(aCpoTmpDsc, "Número")
			AADD(aCpoTmpDsc, "Parcela")
			AADD(aCpoTmpDsc, "Tipo")
			AADD(aCpoTmpDsc, "Emissão")
			AADD(aCpoTmpDsc, "Vencimento")
			AADD(aCpoTmpDsc, "Venc. Real")
			AADD(aCpoTmpDsc, "Data Baixa")
			AADD(aCpoTmpDsc, "Valor")
			AADD(aCpoTmpDsc, "Saldo")

			cCpoBox		:= ""
			aTmpStru 	:= (cAliasTmp)->(DBStruct())
	
			nJ := 1
			For nX := 1 to Len(aCpoTmp)
				nPosCpo := ASCAN(aTmpStru, {|x| x[1] == aCpoTmp[nX]})
				
				If nPosCpo > 0				
					AADD(aCposBrw, FWBrwColumn():New() )
			
					If Alltrim(aTmpStru[nPosCpo][1]) $ cCpoBox
						aCposBrw[nJ]:aOptions := STRTOKARR(UPPER(ALLTRIM(GetSX3Cache(aTmpStru[nPosCpo][1], "X3_CBOX"))), ";")
					EndIf

					aCposBrw[nJ]:SetData(&("{||" + aTmpStru[nPosCpo][1] + "}"))
					aCposBrw[nJ]:SetTitle(aCpoTmpDsc[nX])
					aCposBrw[nJ]:SetSize(aTmpStru[nPosCpo][3])
					aCposBrw[nJ]:SetDecimal(aTmpStru[nPosCpo][4])
					If ALLTRIM(aTmpStru[nPosCpo][2]) == "N"
						If ALLTRIM(aTmpStru[nPosCpo][1]) $ "E2_VALOR;E2_SALDO"
							aCposBrw[nJ]:SetPicture("@E 999,999,999,999.99")
						EndIf
						aCposBrw[nJ]:SetAlign("RIGHT")			
					ElseIf ALLTRIM(aTmpStru[nPosCpo][2]) == "C"
						aCposBrw[nJ]:SetPicture("@!")
					Else
						aCposBrw[nJ]:SetPicture("")
						aCposBrw[nJ]:SetAlign("LEFT")					
					EndIf
	
					aCposBrw[nJ]:SetEdit(.F.)
					nJ++		
				EndIf
			Next			
		
		ElseIf nOpcBrw == 4
				
			//Campos
			AADD(aCpoTmp, "CTT_CUSTO")
			AADD(aCpoTmp, "CTT_DESC01")
			AADD(aCpoTmp, "CTT_BLOQ")

			//Descrição
			AADD(aCpoTmpDsc, "Código")
			AADD(aCpoTmpDsc, "Descrição")
			AADD(aCpoTmpDsc, "Bloqueio")

			cCpoBox 	:= "CTT_BLOQ"
			aTmpStru 	:= (cAliasTmp)->(DBStruct())
	
			nJ := 1
			For nX := 1 to Len(aCpoTmp)
				nPosCpo := ASCAN(aTmpStru, {|x| x[1] == aCpoTmp[nX]})
				
				If nPosCpo > 0				
					AADD(aCposBrw, FWBrwColumn():New() )

					If Alltrim(aTmpStru[nPosCpo][1]) $ cCpoBox
						aCposBrw[nJ]:aOptions := STRTOKARR(UPPER(ALLTRIM(GetSX3Cache(aTmpStru[nPosCpo][1], "X3_CBOX"))), ";")
					EndIf

					aCposBrw[nJ]:SetData(&("{||" + aTmpStru[nPosCpo][1] + "}"))
					aCposBrw[nJ]:SetTitle(aCpoTmpDsc[nX])
					aCposBrw[nJ]:SetSize(aTmpStru[nPosCpo][3])
					aCposBrw[nJ]:SetDecimal(aTmpStru[nPosCpo][4])
					If ALLTRIM(aTmpStru[nPosCpo][2]) == "N"
						//aCposBrw[nJ]:SetPicture("@E 999,999,999,999.99")
						aCposBrw[nJ]:SetAlign("RIGHT")			
					ElseIf ALLTRIM(aTmpStru[nPosCpo][2]) == "C"
						aCposBrw[nJ]:SetPicture("@!")
					Else
						aCposBrw[nJ]:SetPicture("")
						aCposBrw[nJ]:SetAlign("LEFT")					
					EndIf
	
					aCposBrw[nJ]:SetEdit(.F.)
					nJ++		
				EndIf
			Next					

		ElseIf nOpcBrw == 7 

			//Campo
			AADD(aCpoTmp, "RD0_CODIGO")
			AADD(aCpoTmp, "RD0_NOME")
			AADD(aCpoTmp, "RD0_TIPO")
			AADD(aCpoTmp, "RD0_SEXO")
			AADD(aCpoTmp, "RD0_DTNASC")
			AADD(aCpoTmp, "RD0_CIC")
			AADD(aCpoTmp, "RD0_CC")
			AADD(aCpoTmp, "RD0_EMAIL")
			AADD(aCpoTmp, "RD0_EMAILC")
			AADD(aCpoTmp, "RD0_MSBLQL")
			AADD(aCpoTmp, "RD0_FORNEC")
			AADD(aCpoTmp, "RD0_LOJA")
			AADD(aCpoTmp, "RD0_LOGINR")
			AADD(aCpoTmp, "RD0_IDRESE")
			AADD(aCpoTmp, "RD0_EMPATU")
			AADD(aCpoTmp, "RD0_FILATU")
			AADD(aCpoTmp, "RD0_XAPADT")
			AADD(aCpoTmp, "RD0_XAPCNF")
			AADD(aCpoTmp, "RD0_XAPINT")
			AADD(aCpoTmp, "RD0_XAPNAC")
			AADD(aCpoTmp, "RD0_XAPREE")
		
			//Descrição
			AADD(aCpoTmpDsc, "Código")
			AADD(aCpoTmpDsc, "Nome")
			AADD(aCpoTmpDsc, "Tipo")
			AADD(aCpoTmpDsc, "Sexo")
			AADD(aCpoTmpDsc, "Data Nascimento")
			AADD(aCpoTmpDsc, "CPF")
			AADD(aCpoTmpDsc, "Centro de Custos")
			AADD(aCpoTmpDsc, "E-mail")
			AADD(aCpoTmpDsc, "E-mail Complementar")
			AADD(aCpoTmpDsc, "Ativo")
			AADD(aCpoTmpDsc, "Codigo Fornecedor")
			AADD(aCpoTmpDsc, "Loja Fornecedor")
			AADD(aCpoTmpDsc, "Login")
			AADD(aCpoTmpDsc, "ID")
			AADD(aCpoTmpDsc, "Empresa")
			AADD(aCpoTmpDsc, "Filial")
			AADD(aCpoTmpDsc, "Aprov. Adiantamento")
			AADD(aCpoTmpDsc, "Aprov. Adiantamento")
			AADD(aCpoTmpDsc, "Aprov. Conferência")
			AADD(aCpoTmpDsc, "Aprov. Viagem Internacional")
			AADD(aCpoTmpDsc, "Aprov. Viagem Nacional")
			AADD(aCpoTmpDsc, "Aprov. Reembolso")
			
			aTmpStru 	:= (cAliasTmp)->(DBStruct())
			cCpoBox		:= "RD0_TIPO/RD0_SEXO/RD0_MSBLQL/RD0_XAPADT/RD0_XAPCNF/RD0_XAPINT/RD0_XAPNAC/RD0_XAPREE"

			nJ := 1
			For nX := 1 to Len(aCpoTmp)
				nPosCpo := ASCAN(aTmpStru, {|x| x[1] == aCpoTmp[nX]})
				
				If nPosCpo > 0				
					AADD(aCposBrw, FWBrwColumn():New() )

					If Alltrim(aTmpStru[nPosCpo][1]) $ cCpoBox
						If Alltrim(aTmpStru[nPosCpo][1]) == "RD0_TIPO"
							aCposBrw[nJ]:aOptions := {"1=INTERNO", "2=EXTERNO"}
						ElseIf Alltrim(aTmpStru[nPosCpo][1]) == "RD0_SEXO"
							aCposBrw[nJ]:aOptions := {"F=FEMININO", "M=MASCULINO"}
						Else
							aCposBrw[nJ]:aOptions := STRTOKARR(UPPER(ALLTRIM(GetSX3Cache(aTmpStru[nPosCpo][1], "X3_CBOX"))), ";")
						EndIf
						//aCposBrw[nJ]:aOptions := STRTOKARR(UPPER(ALLTRIM(GetSX3Cache(aTmpStru[nPosCpo][1], "X3_CBOX"))), ";")
					EndIf

					aCposBrw[nJ]:SetData(&("{||" + aTmpStru[nPosCpo][1] + "}"))
					aCposBrw[nJ]:SetTitle(aCpoTmpDsc[nX])
					aCposBrw[nJ]:SetSize(aTmpStru[nPosCpo][3])
					
					aCposBrw[nJ]:SetDecimal(aTmpStru[nPosCpo][4])
					If ALLTRIM(aTmpStru[nPosCpo][2]) == "N"
						aCposBrw[nJ]:SetPicture("@E 999,999,999,999.99")
						aCposBrw[nJ]:SetAlign("RIGHT")			
					ElseIf ALLTRIM(aTmpStru[nPosCpo][2]) == "C"
						aCposBrw[nJ]:SetPicture("@!")
					Else
						aCposBrw[nJ]:SetPicture("")
						aCposBrw[nJ]:SetAlign("LEFT")					
					EndIf
	
					aCposBrw[nJ]:SetEdit(.F.)
					nJ++		
				EndIf
			Next
		
		ElseIf nOpcBrw == 10

			//Campos
			AADD(aCpoTmp, "E2_XALATUR")
			AADD(aCpoTmp, "VALBRL")
			AADD(aCpoTmp, "VALUSD")
			AADD(aCpoTmp, "VALEUR")
			AADD(aCpoTmp, "VALTOT")
			AADD(aCpoTmp, "RD0_CODIGO")
			AADD(aCpoTmp, "RD0_NOME")
			AADD(aCpoTmp, "RD0_CIC")
			AADD(aCpoTmp, "RD0_XLOGIN")
			AADD(aCpoTmp, "RD0_EMAIL")
			AADD(aCpoTmp, "RD0_FORNEC")
			AADD(aCpoTmp, "RD0_LOJA")

			//Descrição
			AADD(aCpoTmpDsc, "Código Copastur")
			AADD(aCpoTmpDsc, "Valor (R$)")
			AADD(aCpoTmpDsc, "Valor (US$)")
			AADD(aCpoTmpDsc, "Valor (€)")
			AADD(aCpoTmpDsc, "Valor Total (R$)")
			AADD(aCpoTmpDsc, "Código")
			AADD(aCpoTmpDsc, "Participante")
			AADD(aCpoTmpDsc, "CPF")
			AADD(aCpoTmpDsc, "Login")
			AADD(aCpoTmpDsc, "E-mail")
			AADD(aCpoTmpDsc, "Cod. Fornecedor")
			AADD(aCpoTmpDsc, "Loja")

			aTmpStru 	:= (cAliasTmp)->(DBStruct())
	
			nJ := 1
			For nX := 1 to Len(aCpoTmp)
				nPosCpo := ASCAN(aTmpStru, {|x| x[1] == aCpoTmp[nX]})
				
				If nPosCpo > 0				
					AADD(aCposBrw, FWBrwColumn():New() )
					aCposBrw[nJ]:SetData(&("{||" + aTmpStru[nPosCpo][1] + "}"))
					aCposBrw[nJ]:SetTitle(aCpoTmpDsc[nX])
					aCposBrw[nJ]:SetSize(aTmpStru[nPosCpo][3])
					aCposBrw[nJ]:SetDecimal(aTmpStru[nPosCpo][4])
					If ALLTRIM(aTmpStru[nPosCpo][2]) == "N"
						If ALLTRIM(aTmpStru[nPosCpo][1]) $ "VALBRL/VALUSD/VALEUR/VALTOT"
							aCposBrw[nJ]:SetPicture("@E 999,999,999,999.99")
						EndIf
						aCposBrw[nJ]:SetAlign("RIGHT")			
					ElseIf ALLTRIM(aTmpStru[nPosCpo][2]) == "C"
						aCposBrw[nJ]:SetPicture("@!")
					Else
						aCposBrw[nJ]:SetPicture("")
						aCposBrw[nJ]:SetAlign("LEFT")					
					EndIf
	
					aCposBrw[nJ]:SetEdit(.F.)
					nJ++		
				EndIf
			Next

		EndIf
	//EndIf
		
	RestArea(aArea)

Return aCposBrw


//-------------------------------------------------------------------
/*/{Protheus.doc} FIWS3TMP

Criacao Tabela temporária 

@author  CM Solutions - Allan Constantino Bonfim
@since   08/09/2019
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
User Function FIWS3TMP(nOpcTmp, cAliasTmp, aParam, cTpProc)

	Local cQuery 		:= ""
	Local cQueryTmp		:= GetNextAlias()
	Local aEstrut		:= {}
	Local nX			:= 0
	Local cEmpOri		:= FwCodEmp()
	Local cFilOri		:= FwCodFil()
	
	Default nOpcTmp		:= 0
	Default cAliasTmp	:= GetNextAlias()
	Default aParam 		:= ARRAY(8)
	Default cTpProc		:= ""
		

	If nOpcTmp == 1 .OR. nOpcTmp == 5 .OR. nOpcTmp == 10 .OR. nOpcTmp == 11 //Participantes	
	
		cQuery := "SELECT RD0_FILIAL, RD0_EMPATU, RD0_FILATU,  RD0_CODIGO, RD0_NOME, RD0_TIPO, RD0_SEXO, "+CHR(13)+CHR(10)
		cQuery += "RD0_DTNASC, RD0_CIC, RD0_CC, RD0_EMAIL, RD0_EMAILC, RD0_MSBLQL,RD0_FORNEC, RD0_LOJA, RD0_XLOGIN, "+CHR(13)+CHR(10)
		cQuery += "RD0_EMPATU, RD0_FILATU, RD0_XADNAP, RD0_XVINAP, RD0_XVNNAP, RD0_XRNAPR, RD0_XSPTER, RD0_XNAPRO, "+CHR(13)+CHR(10)
		cQuery += "RD0_XVIP, RD0_MRKBRW, RD0_APROPC, RD0_XALSTA, RD0.R_E_C_N_O_ AS RD0REC, "+CHR(13)+CHR(10)
		cQuery += "ISNULL((SELECT MIN(ZWQ_STATUS) AS STATUS FROM "+RetSqlName("ZWQ")+" ZWQ (NOLOCK) WHERE ZWQ.D_E_L_E_T_ = ' ' AND ZWQ_FILIAL = '"+FwxFilial("ZWQ")+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWQ_EMPORI = RD0_EMPATU AND ZWQ_FILORI = RD0_FILATU AND ZWQ_CHAVE = RD0_CODIGO AND ZWQ_CALIAS = 'RD0' AND ZWQ_FILALI = RD0_FILIAL "+CHR(13)+CHR(10)
		
		If nOpcTmp == 5
			cQuery += "AND ZWQ_TPPROC = '1'), '00') AS RD0STATUS "+CHR(13)+CHR(10)
		ElseIf nOpcTmp == 10
			cQuery += "AND ZWQ_TPPROC = '2'), '00') AS RD0STATUS "+CHR(13)+CHR(10)
		ElseIf nOpcTmp == 11
			cQuery += "AND ZWQ_TPPROC IN ('4', '5')), '00') AS RD0STATUS "+CHR(13)+CHR(10)
		Else
			cQuery += "), '00') AS RD0STATUS "+CHR(13)+CHR(10)
		EndIf 

		cQuery += "FROM "+RetSqlName("RD0")+" RD0 (NOLOCK) "+CHR(13)+CHR(10)
		//cQuery += "INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK) "+CHR(13)+CHR(10)
		//cQuery += "ON (A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND SA1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
		cQuery += "WHERE RD0.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		cQuery += "AND RD0_FILIAL = '"+FwxFilial("RD0")+"' "+CHR(13)+CHR(10)
		cQuery += "AND RD0_XALATU = 'S' "+CHR(13)+CHR(10)
		cQuery += "AND RD0_EMPATU = '"+cEmpOri+"' "+CHR(13)+CHR(10)
		cQuery += "AND RD0_FILATU = '"+cFilOri+"' "+CHR(13)+CHR(10)

		If Len(aParam) > 0	
			If !Empty(aParam[2])
				cQuery += "AND RD0_CODIGO = '"+ALLTRIM(aParam[2])+"' "+CHR(13)+CHR(10)	
			EndIf
			
			If !Empty(aParam[3])
				cQuery += "AND RD0_CC = '"+ALLTRIM(aParam[3])+"' "+CHR(13)+CHR(10)	
			EndIf		

			If !Empty(aParam[4])
				cQuery += "AND RD0_APROPC = '"+ALLTRIM(aParam[4])+"' "+CHR(13)+CHR(10)	
			EndIf								
		EndIf	

		If Select(cQueryTmp) <> 0
			(cQueryTmp)->(DbCloseArea())
		Endif	
	
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQueryTmp, .F., .T.)
	 
		TcSetField(cQueryTmp, "RD0_DTNASC", "D")
				
		aEstrut := (cQueryTmp)->(DBStruct())

		If nOpcTmp == 5
			If Type("oTempBrw5") == "O"
				oTempBrw5:Delete()
			EndIf
					
			oTempBrw5 := FWTemporaryTable():New(cAliasTmp, aEstrut)
			oTempBrw5:AddIndex("1", {"RD0_CODIGO"})
			oTempBrw5:AddIndex("2", {"RD0_NOME"}) 
			oTempBrw5:AddIndex("3", {"RD0_CIC"}) 
			oTempBrw5:Create()	
		ElseIf nOpcTmp == 10
			If Type("oTempBrw10") == "O"
				oTempBrw10:Delete()
			EndIf
					
			oTempBrw10 := FWTemporaryTable():New(cAliasTmp, aEstrut)
			oTempBrw10:AddIndex("1", {"RD0_CODIGO"})
			oTempBrw10:AddIndex("2", {"RD0_NOME"}) 
			oTempBrw10:AddIndex("3", {"RD0_CIC"}) 
			oTempBrw10:Create()	
		ElseIf nOpcTmp == 11
			If Type("oTempBrw11") == "O"
				oTempBrw11:Delete()
			EndIf
					
			oTempBrw11 := FWTemporaryTable():New(cAliasTmp, aEstrut)
			oTempBrw11:AddIndex("1", {"RD0_CODIGO"})
			oTempBrw11:AddIndex("2", {"RD0_NOME"}) 
			oTempBrw11:AddIndex("3", {"RD0_CIC"}) 
			oTempBrw11:Create()	
		Else
			If Type("oTempBrw1") == "O"
				oTempBrw1:Delete()
			EndIf
					
			oTempBrw1 := FWTemporaryTable():New(cAliasTmp, aEstrut)
			oTempBrw1:AddIndex("1", {"RD0_CODIGO"})
			oTempBrw1:AddIndex("2", {"RD0_NOME"}) 
			oTempBrw1:AddIndex("3", {"RD0_CIC"})
			oTempBrw1:Create()	
		EndIf		
							
		DbSelectArea(cQueryTmp)
		(cQueryTmp)->(DbGoTop())
		
		While !(cQueryTmp)->(EOF())						 		
			RecLock(cAliasTmp, .T.)
				For nX := 1 to Len(aEstrut)
					(cAliasTmp)->&(aEstrut[nX][1]) := (cQueryTmp)->&(aEstrut[nX][1])
				Next
			(cAliasTmp)->(MsUnlock())
						
		    (cQueryTmp)->(DbSkip())
		EndDo
		
		(cAliasTmp)->(DbGotop())
	
	ElseIf nOpcTmp == 2 .OR. nOpcTmp == 6 //Integrações
	/*
		cQuery := "SELECT ZWQ_FILIAL, ZWQ_CODIGO, ZWQ_CALIAS, ZWQ_INDICE, ZWQ_FILALI, ZWQ_CHAVE, "+CHR(13)+CHR(10)
		cQuery += "ZWQ_RECORI, ZWQ_EMPORI, ZWQ_FILORI, ZWQ_LOGIN, ZWQ_EMAIL, ZWQ_DATA, ZWQ_HORA, ZWQ_USUARI, "+CHR(13)+CHR(10)
		cQuery += "ZWQ_STATUS, ZWQ_TPINCL, ZWQ_TINTEG, ZWQ_TPPROC, ZWQ_DTINTE, ZWQ_HRINTE, ZWQ_USINTE, ZWQ_ERRO, "+CHR(13)+CHR(10)
		cQuery += "ZWQ_DTREPR, ZWQ_HRREPR, ZWQ_USREPR, ZWQ_CODALA, R_E_C_N_O_ AS ZWQREC "+CHR(13)+CHR(10)
		cQuery += "FROM "+RetSqlName("ZWQ")+" ZWQ (NOLOCK) "+CHR(13)+CHR(10)
		//cQuery += "INNER JOIN "+RetSqlName("SA1")+" SA1 (NOLOCK) "+CHR(13)+CHR(10)
		//cQuery += "ON (A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND SA1.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
		cQuery += "WHERE ZWQ.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		cQuery += "AND ZWQ_FILIAL = '"+FwxFilial("ZWQ")+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWQ_EMPORI = '"+cEmpOri+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWQ_FILORI = '"+cFilOri+"' "+CHR(13)+CHR(10)
*/
		cQuery := "SELECT * FROM ( "+CHR(13)+CHR(10)
		cQuery += "SELECT ZWQ_FILIAL, ZWQ_CODIGO, ZWQ_CALIAS, ZWQ_INDICE, ZWQ_FILALI, ZWQ_CHAVE, "+CHR(13)+CHR(10)
		cQuery += "ZWQ_RECORI, ZWQ_EMPORI, ZWQ_FILORI, ZWQ_LOGIN, ZWQ_EMAIL, ZWQ_DATA, ZWQ_HORA, ZWQ_USUARI, "+CHR(13)+CHR(10)
		cQuery += "ZWQ_STATUS, ZWQ_TPINCL, ZWQ_TINTEG, ZWQ_TPPROC, ZWQ_DTINTE, ZWQ_HRINTE, ZWQ_USINTE, ZWQ_ERRO, "+CHR(13)+CHR(10)
		cQuery += "ZWQ_DTREPR, ZWQ_HRREPR, ZWQ_USREPR, ZWQ_CODALA, ZWQ.R_E_C_N_O_ AS ZWQREC, RD0_FILIAL, RD0_CODIGO, RD0_CC, RD0_APROPC "+CHR(13)+CHR(10)
		cQuery += "FROM "+RetSqlName("ZWQ")+" ZWQ (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "INNER JOIN "+RetSqlName("RD0")+" RD0 (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (ZWQ_CALIAS = 'RD0' AND ZWQ_FILALI = RD0_FILIAL AND ZWQ_CHAVE = RD0_CODIGO AND RD0.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
		cQuery += "WHERE ZWQ.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		cQuery += "AND ZWQ_CALIAS = 'RD0' "+CHR(13)+CHR(10)
		cQuery += "AND ZWQ_FILIAL = '"+FwxFilial("ZWQ")+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWQ_EMPORI = '"+cEmpOri+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWQ_FILORI = '"+cFilOri+"' "+CHR(13)+CHR(10)

		cQuery += "UNION ALL "+CHR(13)+CHR(10)

		cQuery += "SELECT ZWQ_FILIAL, ZWQ_CODIGO, ZWQ_CALIAS, ZWQ_INDICE, ZWQ_FILALI, ZWQ_CHAVE, "+CHR(13)+CHR(10)
		cQuery += "ZWQ_RECORI, ZWQ_EMPORI, ZWQ_FILORI, ZWQ_LOGIN, ZWQ_EMAIL, ZWQ_DATA, ZWQ_HORA, ZWQ_USUARI, "+CHR(13)+CHR(10)
		cQuery += "ZWQ_STATUS, ZWQ_TPINCL, ZWQ_TINTEG, ZWQ_TPPROC, ZWQ_DTINTE, ZWQ_HRINTE, ZWQ_USINTE, ZWQ_ERRO, "+CHR(13)+CHR(10)
		cQuery += "ZWQ_DTREPR, ZWQ_HRREPR, ZWQ_USREPR, ZWQ_CODALA, ZWQ.R_E_C_N_O_ AS ZWQREC,  CTT_FILIAL AS RD0_FILIAL, ' ' AS RD0_CODIGO, CTT_CUSTO AS RD0_CC, ' ' AS RD0_APROPC "+CHR(13)+CHR(10)
		cQuery += "FROM "+RetSqlName("ZWQ")+" ZWQ (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "INNER JOIN "+RetSqlName("CTT")+" CTT (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (ZWQ_FILALI = CTT_FILIAL AND ZWQ_CHAVE = CTT_CUSTO AND CTT.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
		cQuery += "WHERE ZWQ.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		cQuery += "AND ZWQ_CALIAS = 'CTT' "+CHR(13)+CHR(10)
		cQuery += "AND ZWQ_FILIAL = '"+FwxFilial("ZWQ")+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWQ_EMPORI = '"+cEmpOri+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWQ_FILORI = '"+cFilOri+"' "+CHR(13)+CHR(10)
		cQuery += " ) TMP "+CHR(13)+CHR(10)
		cQuery += "WHERE ZWQ_CODIGO <> ' ' "+CHR(13)+CHR(10)

		If Len(aParam) > 0	

			If aParam[1] == "2"
				cQuery += "AND ZWQ_STATUS = '01' "+CHR(13)+CHR(10)
			ElseIf aParam[1] == "3"
				cQuery += "AND ZWQ_STATUS = '02' "+CHR(13)+CHR(10)
			ElseIf aParam[1] == "4"
				cQuery += "AND ZWQ_STATUS = '05' "+CHR(13)+CHR(10)
			EndIf			

			If !Empty(cTpProc)
				cQuery += "AND ZWQ_TPPROC = '"+cTpProc+"' "+CHR(13)+CHR(10)
			EndIf

			If !Empty(aParam[2])
				cQuery += "AND RD0_CODIGO = '"+ALLTRIM(aParam[2])+"' "+CHR(13)+CHR(10)	
			EndIf
			
			If !Empty(aParam[3])
				cQuery += "AND RD0_CC = '"+ALLTRIM(aParam[3])+"' "+CHR(13)+CHR(10)	
			EndIf		

			If !Empty(aParam[4])
				cQuery += "AND RD0_APROPC = '"+ALLTRIM(aParam[4])+"' "+CHR(13)+CHR(10)	
			EndIf	

			/*
			If !Empty(aParam[2])
				cQuery += "AND ZWQ_CALIAS = 'RD0' AND ZWQ_TPPROC = '1' AND ZWQ_CHAVE = '"+ALLTRIM(aParam[2])+"'"+CHR(13)+CHR(10)	
			EndIf
			
			If !Empty(aParam[3])
				cQuery += "AND ZWQ_CALIAS = 'CTT' AND ZWQ_TPPROC = '3' AND ZWQ_CHAVE = '"+ALLTRIM(aParam[3])+"'"+CHR(13)+CHR(10)	
			EndIf		

			If !Empty(aParam[4])
				cQuery += "AND ZWQ_CALIAS = 'RD0' AND ZWQ_TPPROC = '2' AND ZWQ_CHAVE = '"+ALLTRIM(aParam[4])+"'"+CHR(13)+CHR(10)	
			EndIf				
			*/					
		EndIf	

		If Select(cQueryTmp) <> 0
			(cQueryTmp)->(DbCloseArea())
		Endif	
	
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQueryTmp, .F., .T.)

		 TcSetField(cQueryTmp, "ZWQ_DATA", "D")
		 TcSetField(cQueryTmp, "ZWQ_DTINTE", "D")
		 TcSetField(cQueryTmp, "ZWQ_DTREPR", "D")

		aEstrut := (cQueryTmp)->(DBStruct())

		//Ajuste do tamanho do campo para demonstração na tela
		For nX := 1 to Len(aEstrut)
			If aEstrut[nX][1] $ "ZWQ_CODALA"
				aEstrut[nX][3] := nTamAlatur
			EndIf
		Next

		If nOpcTmp == 6
			If Type("oTempBrw6") == "O"
				oTempBrw6:Delete()
			EndIf
					
			oTempBrw6 := FWTemporaryTable():New(cAliasTmp, aEstrut)
			oTempBrw6:AddIndex("1", {"ZWQ_CODALA"})
			oTempBrw6:AddIndex("2", {"ZWQ_CALIAS","ZWQ_FILALI", "ZWQ_CHAVE"})
			oTempBrw6:AddIndex("3", {"ZWQ_CODIGO"})
			oTempBrw6:Create()			
		Else
			If Type("oTempBrw2") == "O"
				oTempBrw2:Delete()
			EndIf
					
			oTempBrw2 := FWTemporaryTable():New(cAliasTmp, aEstrut)
			oTempBrw2:Create()	
		EndIf
					
		DbSelectArea(cQueryTmp)
		(cQueryTmp)->(DbGoTop())
		
		While !(cQueryTmp)->(EOF())						 		
			RecLock(cAliasTmp, .T.)
				For nX := 1 to Len(aEstrut)
					(cAliasTmp)->&(aEstrut[nX][1]) := (cQueryTmp)->&(aEstrut[nX][1])
				Next
			(cAliasTmp)->(MsUnlock())
						
		    (cQueryTmp)->(DbSkip())
		EndDo
		
		(cAliasTmp)->(DbGotop())
		
	ElseIf nOpcTmp == 3 .OR. nOpcTmp == 8 .OR. nOpcTmp == 9 //Financeiro
	
		If Select(cQueryTmp) <> 0
			(cQueryTmp)->(DbCloseArea())
		Endif	

		cQuery := "SELECT E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_VALOR, "+CHR(13)+CHR(10) 
		cQuery += "E2_SALDO, E2_EMISSAO, E2_VENCTO, E2_VENCREA, E2_BAIXA, E2_NATUREZ, E2_NUMBOR, E2_XALATUR, SE2.R_E_C_N_O_ AS SE2REC "+CHR(13)+CHR(10) 
		cQuery += "FROM "+RetSqlName("SE2")+" SE2 (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "LEFT JOIN "+RetSqlName("RD0")+" RD0 (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "ON (RD0_FILIAL = '"+FwxFilial("RD0")+"' AND RD0_FORNEC = E2_FORNECE AND RD0_LOJA = E2_LOJA AND RD0.D_E_L_E_T_ = ' ') "+CHR(13)+CHR(10)
		cQuery += "WHERE SE2.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		//cQuery += "AND E2_PREFIXO IN ('"+GetNewPar("MV_RESPREF", "ADT")+"','"+GetNewPar("MV_RESPFCP", "DP")+"') "+CHR(13)+CHR(10)
		//cQuery += "AND E2_TIPO IN ('"+GetNewPar("MV_RESTPAD", "PA")+"','"+GetNewPar("MV_RESTPPC", "DP")+"') "+CHR(13)+CHR(10)
		cQuery += "AND E2_XALATUR <> ' ' "+CHR(13)+CHR(10)
		//cQuery += "AND E1_VENCREA < '"+DTOS(_dDataRef)+"' "+CHR(13)+CHR(10)
		
		If Len(aParam) > 0		

			If !Empty(aParam[2])
				cQuery += "AND RD0_CODIGO = '"+ALLTRIM(aParam[2])+"' "+CHR(13)+CHR(10)	
			EndIf
			
			If !Empty(aParam[3])
				cQuery += "AND RD0_CC = '"+ALLTRIM(aParam[3])+"' "+CHR(13)+CHR(10)	
			EndIf		

			If !Empty(aParam[4])
				cQuery += "AND RD0_APROPC = '"+ALLTRIM(aParam[4])+"' "+CHR(13)+CHR(10)	
			EndIf	

			If aParam[5] == "2"
				cQuery += "AND E2_PREFIXO = '"+GetNewPar("MV_RESPREF", "ADT")+"' AND E2_TIPO = '"+GetNewPar("MV_RESTPAD", "PA")+"' "+CHR(13)+CHR(10)
			ElseIf aParam[5] == "3"
				cQuery += "AND E2_PREFIXO = '"+GetNewPar("MV_RESPFCP", "DP")+"' AND E2_TIPO = '"+GetNewPar("MV_RESTPPC", "DP")+"' "+CHR(13)+CHR(10)
			EndIf	

			If aParam[6] == "2"
				cQuery += "AND E2_SALDO > 0 "+CHR(13)+CHR(10)
			ElseIf aParam[6] == "3"
				cQuery += "AND E2_SALDO = 0 "+CHR(13)+CHR(10)
			EndIf	

			If !Empty(aParam[7])
				cQuery += "AND E2_VENCREA >= '"+DTOS(aParam[7])+"' "+CHR(13)+CHR(10)	
			EndIf
		
			If !Empty(aParam[8])
				cQuery += "AND E2_VENCREA <= '"+DTOS(aParam[8])+"' "+CHR(13)+CHR(10)	
			EndIf
		EndIf

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQueryTmp, .F., .T.)
	
		TCSetField(cQueryTmp, "E2_EMISSAO", "D")
		TCSetField(cQueryTmp, "E2_VENCTO", "D")
		TCSetField(cQueryTmp, "E2_VENCREA", "D")
		TCSetField(cQueryTmp, "E2_BAIXA", "D")
		TcSetField(cQueryTmp, "E2_VALOR", "N", 15, 2)
		TcSetField(cQueryTmp, "E2_SALDO", "N", 15, 2)
	 
		aEstrut := (cQueryTmp)->(DBStruct())

		//Ajuste do tamanho do campo para demonstração na tela
		For nX := 1 to Len(aEstrut)
			If aEstrut[nX][1] $ "E2_XALATUR"
				aEstrut[nX][3] := nTamAlatur
			EndIf
		Next
		
		If nOpcTmp == 8
			If Type("oTempBrw8") == "O"
				oTempBrw8:Delete()
			EndIf
			
			oTempBrw8 := FWTemporaryTable():New(cAliasTmp, aEstrut)
			oTempBrw8:AddIndex("1", {"E2_XALATUR"})
			oTempBrw8:AddIndex("2", {"E2_NUM","E2_PREFIXO","E2_PARCELA","E2_TIPO"})
			oTempBrw8:AddIndex("3", {"E2_VENCREA"})
			
	
			oTempBrw8:Create()	
		ElseIf nOpcTmp == 9
			If Type("oTempBrw9") == "O"
				oTempBrw9:Delete()
			EndIf
			
			oTempBrw9 := FWTemporaryTable():New(cAliasTmp, aEstrut)
			oTempBrw9:AddIndex("1", {"E2_XALATUR"})
			oTempBrw9:AddIndex("2", {"E2_NUM","E2_PREFIXO","E2_PARCELA","E2_TIPO"})
			oTempBrw9:AddIndex("3", {"E2_VENCREA"})
			
	
			oTempBrw9:Create()	
		Else
			If Type("oTempBrw3") == "O"
				oTempBrw3:Delete()
			EndIf
			
			oTempBrw3 := FWTemporaryTable():New(cAliasTmp, aEstrut)
			oTempBrw3:AddIndex("1", {"E2_XALATUR"})
			oTempBrw3:AddIndex("2", {"E2_NUM","E2_PREFIXO","E2_PARCELA","E2_TIPO"})
			oTempBrw3:AddIndex("3", {"E2_VENCREA"})
	
			oTempBrw3:Create()	
		EndIf		
			
		DbSelectArea(cQueryTmp)
		(cQueryTmp)->(DbGoTop())
		
		While !(cQueryTmp)->(EOF())		
			RecLock(cAliasTmp, .T.)
				For nX := 1 to Len(aEstrut)
					(cAliasTmp)->&(aEstrut[nX][1]) := (cQueryTmp)->&(aEstrut[nX][1])
				Next
			(cAliasTmp)->(MsUnlock())
			
		    (cQueryTmp)->(DbSkip())
		EndDo

		(cAliasTmp)->(DbGotop())


	ElseIf nOpcTmp == 4 //Centro de Custos

		If Select(cQueryTmp) <> 0
			(cQueryTmp)->(DbCloseArea())
		Endif	
			
		cQuery := "SELECT '  ' AS CTTOK, CTT_FILIAL, CTT_CUSTO, CTT_DESC01, CTT_CCSUP, CTT_ZZGRPA, "+CHR(13)+CHR(10)  
		cQuery += "CTT_BLOQ, CTT_XALSTA, R_E_C_N_O_ AS CTTREC, "+CHR(13)+CHR(10) 
		cQuery += "ISNULL((SELECT MIN(ZWQ_STATUS) AS STATUS FROM "+RetSqlName("ZWQ")+" ZWQ (NOLOCK) WHERE ZWQ.D_E_L_E_T_ = ' ' AND ZWQ_FILIAL = '"+FwxFilial("ZWQ")+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWQ_CHAVE = CTT_CUSTO AND ZWQ_CALIAS = 'CTT' AND ZWQ_FILALI = CTT_FILIAL), '00') AS CTTSTATUS "+CHR(13)+CHR(10)
		cQuery += "FROM " +RetSqlName("CTT")+ " CTT (NOLOCK) "+CHR(13)+CHR(10) 
		cQuery += "WHERE CTT.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10) 
		cQuery += "AND CTT_FILIAL = '"+FwxFilial("CTT")+"' "+CHR(13)+CHR(10)  
		cQuery += "AND CTT_CLASSE = '2' "+CHR(13)+CHR(10) 
		cQuery += "AND CTT_XALATU = 'S' "+CHR(13)+CHR(10)
		//cQuery += "AND NOT EXISTS(SELECT ZWQ_CODIGO FROM " +RetSqlName("ZWQ")+ " ZWQ (NOLOCK) WHERE ZWQ.D_E_L_E_T_ = ' ' AND ZWQ_FILIAL = '"+xFilial("ZWQ")+"' AND ZWQ_CALIAS = 'CTT' AND ZWQ_STATUS <> '05' AND ZWQ_RECORI = CTT.R_E_C_N_O_) "+CHR(13)+CHR(10)		

		If Len(aParam) > 0	
			If !Empty(aParam[3])
				cQuery += "AND CTT_CUSTO = '"+aParam[3]+"' "+CHR(13)+CHR(10)	
			EndIf			
		EndIf	

		cQuery += "ORDER BY CTT_FILIAL, CTT_CUSTO "+CHR(13)+CHR(10)
	
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQueryTmp, .F., .T.)
	 
		aEstrut := (cQueryTmp)->(DBStruct())

		If Type("oTempBrw4") == "O"
			oTempBrw4:Delete()
		EndIf
		
		oTempBrw4 := FWTemporaryTable():New(cAliasTmp, aEstrut)
		oTempBrw4:AddIndex("1", {"CTT_CUSTO"})
		oTempBrw4:AddIndex("2", {"CTT_DESC01"})
		oTempBrw4:Create()	
			
		DbSelectArea(cQueryTmp)
		(cQueryTmp)->(DbGoTop())
				
		While !(cQueryTmp)->(EOF())		
			RecLock(cAliasTmp, .T.)
				For nX := 1 to Len(aEstrut)
					(cAliasTmp)->&(aEstrut[nX][1]) := (cQueryTmp)->&(aEstrut[nX][1])
				Next
			(cAliasTmp)->(MsUnlock())
			
		    (cQueryTmp)->(DbSkip())
		EndDo

		(cAliasTmp)->(DbGotop())	

	ElseIf nOpcTmp == 7 //Aprovadores

		//cQuery := "SELECT * FROM ( "+CHR(13)+CHR(10)
		cQuery := "SELECT RD0_FILIAL, RD0_EMPATU, RD0_FILATU, RD0_CODIGO, RD0_NOME, RD0_TIPO, RD0_SEXO, "+CHR(13)+CHR(10) 
		cQuery += "RD0_DTNASC, RD0_CIC, RD0_CC, RD0_EMAIL, RD0_EMAILC, RD0_MSBLQL,RD0_FORNEC, RD0_LOJA, RD0_XLOGIN, "+CHR(13)+CHR(10) 
		cQuery += "RD0_EMPATU, RD0_FILATU, RD0_XAPADT, RD0_XAPCNF, RD0_XAPINT, RD0_XAPNAC, RD0_XAPREE, "+CHR(13)+CHR(10)
		cQuery += "RD0_MRKBRW, RD0_XALSTA, RD0.R_E_C_N_O_ AS RD0REC, "+CHR(13)+CHR(10)
		cQuery += "ISNULL((SELECT MIN(ZWQ_STATUS) AS STATUS FROM "+RetSqlName("ZWQ")+" ZWQ (NOLOCK) WHERE ZWQ.D_E_L_E_T_ = ' ' AND ZWQ_FILIAL = '"+FwxFilial("ZWQ")+"' "+CHR(13)+CHR(10)
		cQuery += "AND ZWQ_EMPORI = RD0_EMPATU AND ZWQ_FILORI = RD0_FILATU AND ZWQ_CHAVE = RD0_CODIGO AND ZWQ_CALIAS = 'RD0' AND ZWQ_FILALI = RD0_FILIAL "+CHR(13)+CHR(10)
		cQuery += "AND ZWQ_TPPROC = '1'), '00') AS RD0STATUS "+CHR(13)+CHR(10)
		cQuery += "FROM "+RetSqlName("RD0")+" RD0 (NOLOCK) "+CHR(13)+CHR(10)
		cQuery += "WHERE RD0.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		cQuery += "AND RD0.RD0_FILIAL = '"+FwxFilial("RD0")+"' "+CHR(13)+CHR(10)
		cQuery += "AND RD0.RD0_XALATU = 'S' "+CHR(13)+CHR(10)
		//cQuery += "AND RD0_EMPATU = '"+cEmpOri+"' "+CHR(13)+CHR(10)
		//cQuery += "AND RD0_FILATU = '"+cFilOri+"' "+CHR(13)+CHR(10)
		cQuery += "AND EXISTS (SELECT RD0_CODIGO FROM "+RetSqlName("RD0")+" RD0APR (NOLOCK) WHERE RD0APR.D_E_L_E_T_ = ' ' AND RD0APR.RD0_FILIAL = RD0.RD0_FILIAL AND RD0APR.RD0_EMPATU = '"+cEmpOri+"' AND RD0APR.RD0_FILATU = '"+cFilOri+"' AND RD0APR.RD0_APROPC = RD0.RD0_CODIGO) "+CHR(13)+CHR(10)

		If Len(aParam) > 0	
			/*
			If !Empty(aParam[2])
				cQuery += "AND RD0_CODIGO = '"+ALLTRIM(aParam[2])+"' "+CHR(13)+CHR(10)	
			EndIf
			*/
			If !Empty(aParam[3])
				cQuery += "AND RD0_CC = '"+ALLTRIM(aParam[3])+"' "+CHR(13)+CHR(10)	
			EndIf		

			If !Empty(aParam[4])
				//cQuery += "AND RD0_APROPC = '"+ALLTRIM(aParam[4])+"' "+CHR(13)+CHR(10)	
				cQuery += "AND RD0_CODIGO = '"+ALLTRIM(aParam[4])+"' "+CHR(13)+CHR(10)	
			EndIf								
		EndIf	

		If Select(cQueryTmp) <> 0
			(cQueryTmp)->(DbCloseArea())
		Endif	
	
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQueryTmp, .F., .T.)
	 
		TcSetField(cQueryTmp, "RD0_DTNASC", "D")
				
		aEstrut := (cQueryTmp)->(DBStruct())

		If Type("oTempBrw7") == "O"
			oTempBrw7:Delete()
		EndIf
				
		oTempBrw7 := FWTemporaryTable():New(cAliasTmp, aEstrut)
		//oTempBrw7:AddIndex("1", {"RD0_FILIAL", "RD0_CODIGO"})
		//oTempBrw7:AddIndex("2", {"RD0_FILIAL", "RD0_NOME"}) 
		oTempBrw7:AddIndex("1", {"RD0_CODIGO"})
		oTempBrw7:AddIndex("2", {"RD0_NOME"}) 
		oTempBrw7:AddIndex("3", {"RD0_CIC"})
		oTempBrw7:Create()	
							
		DbSelectArea(cQueryTmp)
		(cQueryTmp)->(DbGoTop())
		
		While !(cQueryTmp)->(EOF())						 		
			RecLock(cAliasTmp, .T.)
				For nX := 1 to Len(aEstrut)
					(cAliasTmp)->&(aEstrut[nX][1]) := (cQueryTmp)->&(aEstrut[nX][1])
				Next
			(cAliasTmp)->(MsUnlock())
						
		    (cQueryTmp)->(DbSkip())
		EndDo
		
		(cAliasTmp)->(DbGotop())

	EndIf

	If Select(cQueryTmp) <> 0
		(cQueryTmp)->(DbCloseArea())
	Endif	

	
Return cAliasTmp


//-------------------------------------------------------------------
/*/{Protheus.doc} FINWS03A

Rotina para a integração de usuários

@author  CM Solutions - Allan Constantino Bonfim
@since   04/12/2019
@version P12

/*/
//-------------------------------------------------------------------   
Static Function FINWS03A() 

	Local aArea			:= GetArea()
	Local aCoors 		:= FWGetDialogSize(oMainWnd) 
	Local aSeekT1		:= {}
	Local aCposBCad		:= {}
	Local aCposBInt		:= {}	
	Local oFWLayer
	Local oPanelC1
	Local oPanelC2
	Local oRelacBrw1
	Local oTButton1
	Local oTButton2
	Local oTButton3
	Local oTButton4
	Local oTButton5
	Local oTButton6
	Local oTButton7
	Local oTBar
	Local oDlgCad
	
	Private cTmpCad		:= GetNextAlias()
	Private cTmpImp		:= GetNextAlias()
	Private oTempBrw5 
	Private oTempBrw6	
	Private cMarcaCad	:= GetMark()
	
	
	If GetNewPar("ZZ_WSAINT1", .T.) 
		FIWS3KEY(0)

		/////PAINEL PRINCIPAL
		Define MsDialog oDlgCad Title 'Participantes' From aCoors[1], aCoors[2] To aCoors[3]-10, aCoors[4] Pixel 	
			
		//Botoes
		oTBar := TBar():New(oDlgCad, 50, 22, .F.,,,, .T.)		
		oTBar:Align := CONTROL_ALIGN_TOP

		//If FNWS3GRP() .OR. FNWS3USR() 	
			oTButton1	:= TButton():New(00,00, "Integrar", oTBar, {|| FWMsgRun(, {|| U_FIWS3INT(1, .T., .F., .F., oBrowseCad)}, "Processando...", "Aguarde a geração da tabela integradora...")}, 60, 22,,,,.T.,,,,,,)		
			oTButton2	:= TButton():New(00,00, "Integrar Online", oTBar, {|| FWMsgRun(, {|| U_FIWS3INT(1, .T., .T., .F., oBrowseCad)}, "Processando...", "Aguarde a integração com o Copastur...")}, 60, 22,,,,.T.,,,,,,)
			oTButton3	:= TButton():New(00,00, "Excluir", oTBar, {|| FWMsgRun(, {|| FIWS3EXC(1, oBrowseCad)}, "Processando...", "Aguarde a exclusão da tabela integradora...")}, 60, 22,,,,.T.,,,,,,)				
		//EndIf

		oTButton4	:= TButton():New(00,00, "Reprocessar", oTBar, {|| FWMsgRun(, {|| FIWS3REP(1, .T., oBrowseCad)}, "Processando...", "Aguarde o reprocessamento da tabela integradora...")}, 60, 22,,,,.T.,,,,,,)
		oTButton5	:= TButton():New(00,00, "Fornecedor", oTBar, {|| FWMsgRun(, {|| U_FINWS008(oBrowseCad)}, "Processando...", "Aguarde a criação do cadastro de fornecedor...")}, 60, 22,,,,.T.,,,,,,)
		oTButton6	:= TButton():New(00,00, "Resetar Senha", oTBar, {|| FWS03PSS(oBrowseCad)}, 60, 22,,,,.T.,,,,,,)
		oTButton7	:= TButton():New(00,00, "Detalhes", oTBar, {||  FWS03DE1(2)}, 60, 22,,,,.T.,,,,,,)
		oTButton8	:= TButton():New(00,00, "Sair", oTBar, {|| oDlgCad:End()}, 80, 22,,,,.T.,,,,,,)

		oTButton8:Align := CONTROL_ALIGN_RIGHT	
		oTButton7:Align := CONTROL_ALIGN_RIGHT	
		oTButton6:Align := CONTROL_ALIGN_RIGHT
		oTButton5:Align := CONTROL_ALIGN_RIGHT
		oTButton4:Align := CONTROL_ALIGN_RIGHT
		oTButton3:Align := CONTROL_ALIGN_RIGHT
		oTButton2:Align := CONTROL_ALIGN_RIGHT
		oTButton1:Align := CONTROL_ALIGN_RIGHT
		
		oFWLayer := FWLayer():New() 
		oFWLayer:Init(oDlgCad, .F., .T. ) 
					
		// Painel Inferior 
		oFWLayer:AddLine('L1', 100, .F.)
		
		oFWLayer:AddCollumn('C1', 100, .T., 'L1')
		
		oFWLayer:AddWindow('C1'	, 'P1', 'Participantes'	, 80, .T., .F.,, 'L1')
		oFWLayer:AddWindow('C1'	, 'P2', 'Integrações'	, 50, .T., .F.,, 'L1')
			
		oPanelC1 := oFWLayer:GetWinPanel('C1', 'P1', 'L1') 
		oPanelC2 := oFWLayer:GetWinPanel('C1', 'P2', 'L1')
	
		//Fecha o painel integrações
		oFWLayer:WinChgState('C1', 'P2', 'L1')

		/////BROWSES
			
		//Participantes
		//Estrutura e tabela temporaria
		cTmpCad		:= U_FIWS3TMP(5, cTmpCad, aParamTmp)	
		aCposBCad	:= FIWS3STR(5, cTmpCad)	

		oBrowseCad:= FWMarkBrowse():New() //FWMBrowse
		oBrowseCad:SetOwner(oPanelC1) 
		oBrowseCad:SetFieldMark("RD0_MRKBRW")
		oBrowseCad:SetAlias(cTmpCad)
		//oBrowseCad:SetDataTable(.T.)
		//oBrowseCad:AddLegend("RD0_XALSTA = '1'", "RED", "Não Integrado")
		//oBrowseCad:AddLegend("RD0_XALSTA = '2'", "YELLOW", "Pendente Integração")
		//oBrowseCad:AddLegend("RD0_XALSTA = '3'", "GREEN", "Integrado")	
		oBrowseCad:AddLegend("RD0STATUS = '00'", "RED", "Não Integrado")
		oBrowseCad:AddLegend("RD0STATUS $ '01/02'", "YELLOW", "Pendente Integração")
		oBrowseCad:AddLegend("RD0STATUS = '05'", "GREEN", "Integrado")		
		oBrowseCad:SetColumns(aCposBCad)
		oBrowseCad:SetMark(cMarcaCad, cTmpCad, "RD0_MRKBRW")
		oBrowseCad:SetDescription('')   
		oBrowseCad:SetProfileID('1') 
		oBrowseCad:DisableReport() 
		oBrowseCad:DisableConfig()
		oBrowseCad:DisableLocate()
		oBrowseCad:SetLineHeight(nTamLinha)
		oBrowseCad:SetAllMark({|| FWMsgRun(, {|| FINWS3AL(oBrowseCad)}, "Aguarde...", "Selecionando os registros...")})	
		oBrowseCad:SetDoubleClick({|| FWMsgRun(, {|| FWS03DET(1, oBrowseCad)},  "Participantes...", "Aguarde o carregamento da tela...")})
		
		aSeekT1 := {	{"Codigo"	, {{"","C", 06, 0, "", "@!"}}},;
						{"Nome"		, {{"","C", 30, 0, "", "@!"}}},;
						{"CPF"		, {{"","C", 11, 0, "", "@!"}}}} 		
					
		oBrowseCad:SetSeek(.T., aSeekT1)

		oBrowseCad:Activate()
		oBrowseCad:oBrowse:Setfocus()
		
		//Integrações
		//Estrutura e tabela temporaria
		cTmpInt 	:= U_FIWS3TMP(6, cTmpInt, aParamTmp)
		aCposBInt 	:= FIWS3STR(6, cTmpInt)
		
		oBrowseInt:= FWBrowse():New() 
		oBrowseInt:SetOwner(oPanelC2) 
		oBrowseInt:SetAlias(cTmpInt)
		oBrowseInt:SetDataTable(.T.)
		oBrowseInt:AddLegend("ZWQ_STATUS = '01'", "YELLOW", "Pendente")
		oBrowseInt:AddLegend("ZWQ_STATUS = '02'", "RED", "Erro")
		oBrowseInt:AddLegend("ZWQ_STATUS = '05'", "GREEN", "Processado")		
		oBrowseInt:SetColumns(aCposBInt)
		oBrowseInt:SetDescription('')   
		oBrowseInt:SetProfileID('2') 
		oBrowseInt:DisableReport() 
		oBrowseInt:DisableConfig()
		oBrowseInt:DisableLocate()
		oBrowseInt:SetLineHeight(nTamLinha)
		oBrowseInt:SetDoubleClick({|| FWMsgRun(, {|| FWS03DET(2, oBrowseInt)}, "Integrações...", "Aguarde o carregamento da tela...")})

		oBrowseInt:Activate()			

		///// Relacionamento entre os Paineis 
		
		//Centro de Custos x Integrações		
		oRelacBrw1:= FWBrwRelation():New()
		oRelacBrw1:AddRelation(oBrowseCad , oBrowseInt, {{"ZWQ_CALIAS", "'RD0'"}, {'ZWQ_FILALI', 'RD0_FILIAL'}, {'ZWQ_CHAVE', 'RD0_CODIGO'}, {'ZWQ_TPPROC', "'1'"}})
		oRelacBrw1:Activate()
				
		Activate MsDialog oDlgCad Center 
		
		
		FIWS3KEY()
		FIWS3REF(.T., .F.)
	Else
		Help(NIL, NIL, "FINWS03A", NIL, "A integração do cadastro de participantes está desativada.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique a configuração do parâmetro ZZ_WSAINT1."})
	EndIf
	
	RestArea(aArea)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FINWS03B

Rotina para a integração manual de centro de custos

@author  CM Solutions - Allan Constantino Bonfim
@since   02/12/2019
@version P12

/*/
//-------------------------------------------------------------------   
Static Function FINWS03B() 

	Local aArea			:= GetArea()
	Local aCoors 		:= FWGetDialogSize(oMainWnd) 
	Local aSeekT1		:= {}
	Local aCposBCad		:= {}
	Local aCposBInt		:= {}	
	Local oFWLayer
	Local oPanelC1
	Local oPanelC2
	Local oRelacBrw1
	Local oTButton1
	Local oTButton2
	Local oTButton3
	Local oTBar
	Local oDlgCad
	
	Private oBrowseCad
	Private oBrowseInt
	Private cTmpCad		:= GetNextAlias()
	Private cTmpImp		:= GetNextAlias()	
	Private cMarcaCad 	:= GetMark()
	Private oTempBrw4
	Private oTempBrw6
	

	If GetNewPar("ZZ_WSAINT3", .T.)		
		FIWS3KEY(0)
		
		/////PAINEL PRINCIPAL
		Define MsDialog oDlgCad Title 'Centro de Custos' From aCoors[1], aCoors[2] To aCoors[3]-10, aCoors[4] Pixel 	
			
		//Botoes
		oTBar := TBar():New(oDlgCad, 50, 22, .F.,,,, .T.)		
		oTBar:Align := CONTROL_ALIGN_TOP

		//If FNWS3GRP() .OR. FNWS3USR() 
			oTButton1	:= TButton():New(00,00, "Integrar", oTBar, {|| FWMsgRun(, {|| U_FIWS3INT(2, .T., .F., .F., oBrowseCad)}, "Processando...", "Aguarde a geração da tabela integradora...")}, 60, 22,,,,.T.,,,,,,)		
			oTButton2	:= TButton():New(00,00, "Integrar Online", oTBar, {|| FWMsgRun(, {|| U_FIWS3INT(2, .T., .T., .F., oBrowseCad)}, "Processando...", "Aguarde a integração com o Copastur...")}, 60, 22,,,,.T.,,,,,,)
			oTButton3	:= TButton():New(00,00, "Excluir", oTBar, {|| FWMsgRun(, {|| FIWS3EXC(2, oBrowseCad)}, "Processando...", "Aguarde a exclusão da tabela integradora...")}, 60, 22,,,,.T.,,,,,,)				
		//EndIf

		oTButton4	:= TButton():New(00,00, "Reprocessar", oTBar, {|| FWMsgRun(, {|| FIWS3REP(2, .T., oBrowseCad)}, "Processando...", "Aguarde o reprocessamento da tabela integradora...")}, 60, 22,,,,.T.,,,,,,)
		oTButton5	:= TButton():New(00,00, "Detalhes", oTBar, {||  FWS03DE1(3)}, 60, 22,,,,.T.,,,,,,)
		oTButton6	:= TButton():New(00,00, "Sair", oTBar, {|| oDlgCad:End()}, 80, 22,,,,.T.,,,,,,)
			
		oTButton6:Align := CONTROL_ALIGN_RIGHT
		oTButton5:Align := CONTROL_ALIGN_RIGHT
		oTButton4:Align := CONTROL_ALIGN_RIGHT
		oTButton3:Align := CONTROL_ALIGN_RIGHT
		oTButton2:Align := CONTROL_ALIGN_RIGHT
		oTButton1:Align := CONTROL_ALIGN_RIGHT
		
		oFWLayer := FWLayer():New() 
		oFWLayer:Init(oDlgCad, .F., .T. ) 
					
		// Painel Inferior 
		oFWLayer:AddLine('L1', 100, .F.)
		
		oFWLayer:AddCollumn('C1', 100, .T., 'L1')
		
		oFWLayer:AddWindow('C1'	, 'P1', 'Centro de Custos'	, 80, .T., .F.,, 'L1')
		oFWLayer:AddWindow('C1'	, 'P2', 'Integrações'		, 50, .T., .F.,, 'L1')
			
		oPanelC1 := oFWLayer:GetWinPanel('C1', 'P1', 'L1') 
		oPanelC2 := oFWLayer:GetWinPanel('C1', 'P2', 'L1')
	
		//Fecha o painel integrações
		oFWLayer:WinChgState('C1', 'P2', 'L1')

		/////BROWSES
			
		//Centro de Custos
		//Estrutura e tabela temporaria
		cTmpCad		:= U_FIWS3TMP(4, cTmpCad, aParamTmp)	
		aCposBCad	:= FIWS3STR(4, cTmpCad)
		
		oBrowseCad:= FWMarkBrowse():New() //FWMBrowse
		oBrowseCad:SetOwner(oPanelC1) 
		oBrowseCad:SetFieldMark("CTTOK")
		oBrowseCad:SetAlias(cTmpCad)
		//oBrowseCad:SetDataTable(.T.)	
		//oBrowseCad:AddLegend("CTT_XALSTA = '1'", "RED", "Não Integrado")
		//oBrowseCad:AddLegend("CTT_XALSTA = '2'", "YELLOW", "Pendente Integração")
		//oBrowseCad:AddLegend("CTT_XALSTA = '3'", "GREEN", "Integrado")
		oBrowseCad:AddLegend("CTTSTATUS = '00'", "RED", "Não Integrado")
		oBrowseCad:AddLegend("CTTSTATUS $ '01/02'", "YELLOW", "Pendente Integração")
		oBrowseCad:AddLegend("CTTSTATUS = '05'", "GREEN", "Integrado")
		oBrowseCad:SetColumns(aCposBCad)
		oBrowseCad:SetMark(cMarcaCad, cTmpCad, "CTTOK")
		oBrowseCad:SetAllMark({|| FWMsgRun(, {|| FINWS3AL(oBrowseCad)}, "Aguarde...", "Selecionando os registros...")})	
		oBrowseCad:SetDescription('')   
		oBrowseCad:SetProfileID('1') 
		oBrowseCad:DisableReport() 
		oBrowseCad:DisableConfig()
		oBrowseCad:DisableLocate()
		oBrowseCad:SetLineHeight(nTamLinha)	
		oBrowseCad:SetDoubleClick({|| FWMsgRun(, {|| FWS03DET(4, oBrowseCad)}, "Centro de Custos...", "Aguarde o carregamento da tela...")})

		aSeekT1 := {	{"Codigo"		, {{"","C", 09, 0, "", "@!"}}},;
						{"Descricao"	, {{"","C", 40, 0, "", "@!"}}}} 		
					
		oBrowseCad:SetSeek(.T., aSeekT1)

		oBrowseCad:Activate()
		oBrowseCad:oBrowse:Setfocus()
			
		//Integrações
		//Estrutura e tabela temporaria
		cTmpInt 	:= U_FIWS3TMP(6, cTmpInt, aParamTmp)
		aCposBInt 	:= FIWS3STR(6, cTmpInt)

		oBrowseInt:= FWBrowse():New() 
		oBrowseInt:SetOwner(oPanelC2) 
		oBrowseInt:SetAlias(cTmpInt)
		oBrowseInt:SetDataTable(.T.)
		oBrowseInt:AddLegend("ZWQ_STATUS = '01'", "YELLOW", "Pendente")
		oBrowseInt:AddLegend("ZWQ_STATUS = '02'", "RED", "Erro")
		oBrowseInt:AddLegend("ZWQ_STATUS = '05'", "GREEN", "Processado")		
		oBrowseInt:SetColumns(aCposBInt)
		oBrowseInt:SetDescription('')   
		oBrowseInt:SetProfileID('2') 
		oBrowseInt:DisableReport() 
		oBrowseInt:DisableConfig()
		oBrowseInt:DisableLocate()
		oBrowseInt:SetLineHeight(nTamLinha)
		oBrowseInt:SetDoubleClick({|| FWMsgRun(, {|| FWS03DET(2, oBrowseInt)}, "Integrações...", "Aguarde o carregamento da tela...")})
		
		oBrowseInt:Activate()			

		///// Relacionamento entre os Paineis 
		
		//Centro de Custos x Integrações		
		oRelacBrw1:= FWBrwRelation():New()
		oRelacBrw1:AddRelation(oBrowseCad , oBrowseInt, {{"ZWQ_FILIAL", "'"+FwxFIlial("ZWQ")+"'"}, {"ZWQ_CALIAS", "'CTT'"}, {'ZWQ_FILALI', 'CTT_FILIAL'}, {'ZWQ_CHAVE', 'CTT_CUSTO'}, {'ZWQ_TPPROC', "'3'"}})
		oRelacBrw1:Activate()
				
		Activate MsDialog oDlgCad Center
		
		FIWS3KEY()
		FIWS3REF(.T., .F.)
	Else
		Help(NIL, NIL, "FINWS03B", NIL, "A integração do cadastro de centro de custos está desativada.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique a configuração do parâmetro ZZ_WSAINT3."})
	EndIf

	RestArea(aArea)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FINWS03C

Rotina para a integração de aprovadores

@author  CM Solutions - Allan Constantino Bonfim
@since   17/12/2019
@version P12

/*/
//-------------------------------------------------------------------   
Static Function FINWS03C() 

	Local aArea			:= GetArea()
	Local aCoors 		:= FWGetDialogSize(oMainWnd) 
	Local aSeekT1		:= {}
	Local aCposBCad		:= {}
	Local aCposBInt		:= {}
	Local aCposBDet		:= {}	
	Local oFWLayer
	Local oPanelC1
	Local oPanelC2
	Local oPanelC3
	Local oRelacBrw1
	Local oRelacBrw2
	Local oTButton1
	Local oTButton2
	Local oTButton3
	Local oTButton4
	Local oTButton5
	Local oTButton6
	Local oTBar
	Local oDlgCad

	Private cTmpDet		:= GetNextAlias()
	Private cTmpCad		:= GetNextAlias()
	Private cTmpImp		:= GetNextAlias()
	Private oTempBrw5
	Private oTempBrw7 
	Private oTempBrw6	
	Private cMarcaCad	:= GetMark()
	
	

	If GetNewPar("ZZ_WSAINT2", .T.)		
		FIWS3KEY(0)
		
		/////PAINEL PRINCIPAL
		Define MsDialog oDlgCad Title 'Aprovadores' From aCoors[1], aCoors[2] To aCoors[3]-10, aCoors[4] Pixel 	
			
		//Botoes
		oTBar := TBar():New(oDlgCad, 50, 22, .F.,,,, .T.)		
		oTBar:Align := CONTROL_ALIGN_TOP

		//If FNWS3GRP() .OR. FNWS3USR() 
			oTButton1	:= TButton():New(00,00, "Integrar", oTBar, {|| FWMsgRun(, {|| U_FIWS3INT(3, .T., .F., .F., oBrowseCad, oBrowseDet)}, "Processando...", "Aguarde a geração da tabela integradora...")}, 60, 22,,,,.T.,,,,,,)		
			oTButton2	:= TButton():New(00,00, "Integrar Online", oTBar, {|| FWMsgRun(, {|| U_FIWS3INT(3, .T., .T., .F., oBrowseCad, oBrowseDet)}, "Processando...", "Aguarde a integração com o Copastur...")}, 60, 22,,,,.T.,,,,,,)
			oTButton3	:= TButton():New(00,00, "Excluir", oTBar, {|| FWMsgRun(, {|| FIWS3EXC(3, oBrowseCad)}, "Processando...", "Aguarde a exclusão da tabela integradora...")}, 60, 22,,,,.T.,,,,,,)				
		//EndIf

		oTButton4	:= TButton():New(00,00, "Reprocessar", oTBar, {|| FWMsgRun(, {|| FIWS3REP(3, .T., oBrowseCad)}, "Processando...", "Aguarde o reprocessamento da tabela integradora...")}, 60, 22,,,,.T.,,,,,,)
		oTButton5	:= TButton():New(00,00, "Detalhes", oTBar, {||  FWS03DE1(4)}, 60, 22,,,,.T.,,,,,,)
		oTButton6	:= TButton():New(00,00, "Sair", oTBar, {|| oDlgCad:End()}, 80, 22,,,,.T.,,,,,,)
			
		oTButton6:Align := CONTROL_ALIGN_RIGHT
		oTButton5:Align := CONTROL_ALIGN_RIGHT
		oTButton4:Align := CONTROL_ALIGN_RIGHT
		oTButton3:Align := CONTROL_ALIGN_RIGHT
		oTButton2:Align := CONTROL_ALIGN_RIGHT
		oTButton1:Align := CONTROL_ALIGN_RIGHT
		
		oFWLayer := FWLayer():New() 
		oFWLayer:Init(oDlgCad, .F., .T. ) 
					
		// Painel Inferior 
		oFWLayer:AddLine('L1', 100, .F.)
		
		oFWLayer:AddCollumn('C1', 100, .T., 'L1')
		
		oFWLayer:AddWindow('C1'	, 'P1', 'Aprovadores'	, 50, .T., .F.,, 'L1')
		oFWLayer:AddWindow('C1'	, 'P2', 'Participantes'	, 50, .T., .F.,, 'L1')
		oFWLayer:AddWindow('C1'	, 'P3', 'Integrações'	, 50, .T., .F.,, 'L1')
			
		oPanelC1 := oFWLayer:GetWinPanel('C1', 'P1', 'L1') 
		oPanelC2 := oFWLayer:GetWinPanel('C1', 'P2', 'L1')
		oPanelC3 := oFWLayer:GetWinPanel('C1', 'P3', 'L1')
	
		//Fecha o painel integrações
		oFWLayer:WinChgState('C1', 'P3', 'L1')

		/////BROWSES

		//Aprovadores
		//Estrutura e tabela temporaria
		cTmpCad	:= U_FIWS3TMP(7, cTmpCad, aParamTmp)	
		aCposBCad	:= FIWS3STR(7, cTmpCad)	

		oBrowseCad:= FWMarkBrowse():New() //FWMBrowse
		oBrowseCad:SetOwner(oPanelC1) 
		oBrowseCad:SetFieldMark("RD0_MRKBRW")
		oBrowseCad:SetAlias(cTmpCad)
		oBrowseCad:SetDataTable(.T.)
		//oBrowseCad:AddLegend("RD0_XALSTA = '1'", "RED", "Não Integrado")
		//oBrowseCad:AddLegend("RD0_XALSTA = '2'", "YELLOW", "Pendente Integração")
		//oBrowseCad:AddLegend("RD0_XALSTA = '3'", "GREEN", "Integrado")		
		oBrowseCad:AddLegend("RD0STATUS = '00'", "RED", "Não Integrado")
		oBrowseCad:AddLegend("RD0STATUS $ '01/02'", "YELLOW", "Pendente Integração")
		oBrowseCad:AddLegend("RD0STATUS = '05'", "GREEN", "Integrado")	
		oBrowseCad:SetColumns(aCposBCad)
		oBrowseCad:SetMark(cMarcaCad, cTmpCad, "RD0_MRKBRW")
		oBrowseCad:SetDescription('')   
		oBrowseCad:SetProfileID('1') 
		oBrowseCad:DisableReport() 
		oBrowseCad:DisableConfig()
		oBrowseCad:DisableLocate()
		oBrowseCad:SetLineHeight(nTamLinha)
		oBrowseCad:SetAllMark({|| FWMsgRun(, {|| FINWS3AL(oBrowseCad)}, "Aguarde...", "Selecionando os registros...")})	
		oBrowseCad:SetDoubleClick({|| FWMsgRun(, {|| FWS03DET(1, oBrowseCad)},  "Aprovadores...", "Aguarde o carregamento da tela...")})	

		aSeekT1 := {	{"Codigo"	, {{"","C", 06, 0, "", "@!"}}},;
						{"Nome"		, {{"","C", 30, 0, "", "@!"}}},;
						{"CPF"		, {{"","C", 11, 0, "", "@!"}}}} 		
					
		oBrowseCad:SetSeek(.T., aSeekT1)

		oBrowseCad:Activate()
		oBrowseCad:oBrowse:Setfocus()
		
			
		//Participantes
		//Estrutura e tabela temporaria
		cTmpDet	:= U_FIWS3TMP(10, cTmpDet, aParamTmp)	
		aCposBDet	:= FIWS3STR(5, cTmpDet)	

		oBrowseDet:= FWMarkBrowse():New() //FWMBrowse
		oBrowseDet:SetOwner(oPanelC2) 
		oBrowseDet:SetAlias(cTmpDet)
		oBrowseDet:SetDataTable(.T.)
		oBrowseDet:AddLegend("RD0_XALSTA = '1'", "RED", "Não Integrado")
		oBrowseDet:AddLegend("RD0_XALSTA = '2'", "YELLOW", "Pendente Integração")
		oBrowseDet:AddLegend("RD0_XALSTA = '3'", "GREEN", "Integrado")	
		oBrowseDet:SetColumns(aCposBDet)
		oBrowseDet:SetDescription('')   
		oBrowseDet:SetProfileID('2') 
		oBrowseDet:DisableReport() 
		oBrowseDet:DisableConfig()
		oBrowseDet:DisableLocate()
		oBrowseDet:SetLineHeight(nTamLinha)
		oBrowseDet:SetDoubleClick({|| FWMsgRun(, {|| FWS03DET(1, oBrowseDet)},  "Participantes...", "Aguarde o carregamento da tela...")})	
		oBrowseDet:Activate()
		oBrowseDet:oBrowse:Setfocus()
		
		//Integrações
		//Estrutura e tabela temporaria
		cTmpInt 	:= U_FIWS3TMP(6, cTmpInt, aParamTmp)
		aCposBInt 	:= FIWS3STR(6, cTmpInt)
		
		oBrowseInt:= FWBrowse():New() 
		oBrowseInt:SetOwner(oPanelC3) 
		oBrowseInt:SetAlias(cTmpInt)
		oBrowseInt:SetDataTable(.T.)
		oBrowseInt:AddLegend("ZWQ_STATUS = '01'", "YELLOW", "Pendente")
		oBrowseInt:AddLegend("ZWQ_STATUS = '02'", "RED", "Erro")
		oBrowseInt:AddLegend("ZWQ_STATUS = '05'", "GREEN", "Processado")		
		oBrowseInt:SetColumns(aCposBInt)
		oBrowseInt:SetDescription('')   
		oBrowseInt:SetProfileID('3') 
		oBrowseInt:DisableReport() 
		oBrowseInt:DisableConfig()
		oBrowseInt:DisableLocate()
		oBrowseInt:SetLineHeight(nTamLinha)
		oBrowseInt:SetDoubleClick({|| FWMsgRun(, {|| FWS03DET(2, oBrowseInt)}, "Integrações...", "Aguarde o carregamento da tela...")})
		oBrowseInt:Activate()			

		///// Relacionamento entre os Paineis 
		
		//Centro de Custos x Integrações		
		oRelacBrw1:= FWBrwRelation():New()
		oRelacBrw1:AddRelation(oBrowseCad, oBrowseDet, {{'RD0_FILIAL', 'RD0_FILIAL'}, {'RD0_APROPC', 'RD0_CODIGO'}})
		oRelacBrw1:Activate()

		oRelacBrw2:= FWBrwRelation():New()
		//oRelacBrw2:AddRelation(oBrowseCad, oBrowseInt, {{"ZWQ_CALIAS", "'RD0'"}, {'ZWQ_TPPROC', "'2'"}})
		oRelacBrw2:AddRelation(oBrowseDet , oBrowseInt, {{"ZWQ_CALIAS", "'RD0'"}, {'ZWQ_FILALI', 'RD0_FILIAL'}, {'ZWQ_CHAVE', 'RD0_CODIGO'}, {'ZWQ_TPPROC', "'2'"}})
		oRelacBrw2:Activate()

		//oRelacBrw3:= FWBrwRelation():New()
		//oRelacBrw3:AddRelation(oBrowseDet, oBrowseInt, {{"ZWQ_CALIAS", "'RD0'"}, {'ZWQ_FILALI', 'RD0_FILIAL'}, {'ZWQ_CHAVE', 'RD0_CODIGO'}})
		//oRelacBrw3:Activate()
					
		Activate MsDialog oDlgCad Center 
			
		FIWS3KEY()
		FIWS3REF(.T., .F.)
	Else
		Help(NIL, NIL, "FINWS03C", NIL, "A integração dos aprovadores está desativada.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique a configuração do parâmetro ZZ_WSAINT2."})
	EndIf

	RestArea(aArea)
				
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FINWS03D

Rotina para a integração do financeiro

@author  CM Solutions - Allan Constantino Bonfim
@since   23/02/2020
@version P12

/*/
//-------------------------------------------------------------------   
Static Function FINWS03D() 

	Local aArea			:= GetArea()
	Local aCoors 		:= FWGetDialogSize(oMainWnd) 
//	Local aSeekT1		:= {}
	Local aCposCad		:= {}
	Local aCposAdi		:= {}
	Local aCposDesp		:= {}	
	Local aCposBInt		:= {}
	Local oFWLayer
	Local oPanelD1
	Local oPanelD2
	Local oPanelD3
	Local oPanelD4
	Local oRelacBrw1
	Local oRelacBrw2
	Local oRelacBrw3
	Local oTButton1
	Local oTButton2
	Local oTButton3
	Local oTButton4
	Local oTButton5
	Local oTButton6
	Local oTBar
	Local oDlgCad

	Private cTmpCad		:= GetNextAlias()
	Private cTmpAdi		:= GetNextAlias()
	Private cTmpDesp	:= GetNextAlias()
	Private cTmpInt		:= GetNextAlias()
	Private oTempBrw5
	Private oTempBrw8
	Private oTempBrw9
	Private cMarcaCad	:= GetMark()
	
	
	If GetNewPar("ZZ_WSAINT5", .T.)	
		FIWS3KEY(0)
		
		/////PAINEL PRINCIPAL
		Define MsDialog oDlgCad Title 'Financeiro' From aCoors[1], aCoors[2] To aCoors[3]-10, aCoors[4] Pixel 	
			
		//Botoes
		oTBar := TBar():New(oDlgCad, 50, 22, .F.,,,, .T.)		
		oTBar:Align := CONTROL_ALIGN_TOP

		//If FNWS3GRP() .OR. FNWS3USR() 
			oTButton1	:= TButton():New(00,00, "Integrar", oTBar, {|| FWMsgRun(, {|| U_FIWS3INT(4, .T., .F., .F., oBrowseCad, oBrowseDet)}, "Processando...", "Aguarde a geração da tabela integradora...")}, 60, 22,,,,.T.,,,,,,)		
			oTButton2	:= TButton():New(00,00, "Integrar Online", oTBar, {|| FWMsgRun(, {|| U_FIWS3INT(4, .T., .T., .F., oBrowseCad, oBrowseDet)}, "Processando...", "Aguarde a integração com o Copastur...")}, 60, 22,,,,.T.,,,,,,)
			oTButton3	:= TButton():New(00,00, "Excluir", oTBar, {|| FWMsgRun(, {|| FIWS3EXC(4, oBrowseCad)}, "Processando...", "Aguarde a exclusão da tabela integradora...")}, 60, 22,,,,.T.,,,,,,)				
		//EndIf

		oTButton4	:= TButton():New(00,00, "Reprocessar", oTBar, {|| FWMsgRun(, {|| FIWS3REP(4, .T., oBrowseCad)}, "Processando...", "Aguarde o reprocessamento da tabela integradora...")}, 60, 22,,,,.T.,,,,,,)
		oTButton5	:= TButton():New(00,00, "Adiantamento", oTBar, {|| FWMsgRun(, {|| U_FWS03ADI(oBrowseCad)}, "Processando...", "Integração de Adiantamentos...")}, 60, 22,,,,.T.,,,,,,)
		oTButton6	:= TButton():New(00,00, "Despesas", oTBar, {|| FWMsgRun(, {|| U_FWS03DSP(oBrowseCad)}, "Processando...", "Integração de Despesas...")}, 60, 22,,,,.T.,,,,,,)
		oTButton7	:= TButton():New(00,00, "Fornecedor", oTBar, {|| FWMsgRun(, {|| U_FINWS008(oBrowseCad)}, "Processando...", "Aguarde a criação do cadastro de fornecedor...")}, 60, 22,,,,.T.,,,,,,)
		oTButton8	:= TButton():New(00,00, "Detalhes", oTBar, {|| FWS03DE1(5)}, 60, 22,,,,.T.,,,,,,)
		oTButton9	:= TButton():New(00,00, "Sair", oTBar, {|| oDlgCad:End()}, 80, 22,,,,.T.,,,,,,)
		
		oTButton9:Align := CONTROL_ALIGN_RIGHT
		oTButton8:Align := CONTROL_ALIGN_RIGHT
		oTButton7:Align := CONTROL_ALIGN_RIGHT
		oTButton6:Align := CONTROL_ALIGN_RIGHT
		oTButton6:Align := CONTROL_ALIGN_RIGHT
		oTButton5:Align := CONTROL_ALIGN_RIGHT
		oTButton4:Align := CONTROL_ALIGN_RIGHT
		oTButton3:Align := CONTROL_ALIGN_RIGHT
		oTButton2:Align := CONTROL_ALIGN_RIGHT
		oTButton1:Align := CONTROL_ALIGN_RIGHT
		
		oFWLayer := FWLayer():New() 
		oFWLayer:Init(oDlgCad, .F., .T. ) 
					
		// Painel Inferior 
		oFWLayer:AddLine('L1', 100, .F.)
		oFWLayer:AddCollumn('D1', 100, .T., 'L1')
		oFWLayer:AddWindow('D1'	, 'P1', 'Participantes'	, 50, .T., .F.,, 'L1')
		oFWLayer:AddWindow('D1'	, 'P2', 'Adiantamentos'	, 50, .T., .F.,, 'L1')
		oFWLayer:AddWindow('D1'	, 'P3', 'Despesas'	, 50, .T., .F.,, 'L1')
		oFWLayer:AddWindow('D1'	, 'P4', 'Integrações'	, 40, .T., .F.,, 'L1')
		
		oPanelD1 := oFWLayer:GetWinPanel('D1', 'P1', 'L1') 
		oPanelD2 := oFWLayer:GetWinPanel('D1', 'P2', 'L1')
		oPanelD3 := oFWLayer:GetWinPanel('D1', 'P3', 'L1')
		oPanelD4 := oFWLayer:GetWinPanel('D1', 'P4', 'L1')
		
		//Fecha o painel integrações
		oFWLayer:WinChgState('D1', 'P3', 'L1')
		oFWLayer:WinChgState('D1', 'P4', 'L1')

		/////BROWSES

		//Participantes
		//Estrutura e tabela temporaria
		cTmpCad	:= U_FIWS3TMP(11, cTmpCad, aParamTmp)	
		aCposCad	:= FIWS3STR(5, cTmpCad)

		oBrowseCad:= FWMarkBrowse():New() //FWMBrowse
		oBrowseCad:SetOwner(oPanelD1) 
		oBrowseCad:SetFieldMark("RD0_MRKBRW")
		oBrowseCad:SetAlias(cTmpCad)
		oBrowseCad:SetDataTable(.T.)
		oBrowseCad:AddLegend("RD0_XALSTA = '1'", "RED", "Não Integrado")
		oBrowseCad:AddLegend("RD0_XALSTA = '2'", "YELLOW", "Pendente Integração")
		oBrowseCad:AddLegend("RD0_XALSTA = '3'", "GREEN", "Integrado")		
		oBrowseCad:SetColumns(aCposCad)
		oBrowseCad:SetMark(cMarcaCad, cTmpCad, "RD0_MRKBRW")
		oBrowseCad:SetDescription('')   
		oBrowseCad:SetProfileID('1') 
		oBrowseCad:DisableReport() 
		oBrowseCad:DisableConfig()
		oBrowseCad:DisableLocate()
		oBrowseCad:SetLineHeight(nTamLinha)
		oBrowseCad:SetAllMark({|| FWMsgRun(, {|| FINWS3AL(oBrowseCad)}, "Aguarde...", "Selecionando os registros...")})	
		oBrowseCad:SetDoubleClick({|| FWMsgRun(, {|| FWS03DET(1, oBrowseCad)},  "Aprovadores...", "Aguarde o carregamento da tela...")})	
		
		aSeekTmp1 := {	{"Codigo"	, {{"","C", 06, 0, "RD0_CODIGO", "@!"}}},;
						{"Nome"		, {{"","C", 30, 0, "RD0_NOME", "@!"}}},;
						{"Cpf"		, {{"","C", 11, 0, "RD0_CIC", "@!"}}}}				

		oBrowseCad:SetSeek(.T., aSeekTmp1) 

		oBrowseCad:Activate()
		oBrowseCad:oBrowse:Setfocus()

		//Adiantamentos
		//Estrutura e tabela temporaria
		cTmpAdi		:= U_FIWS3TMP(8, cTmpAdi, aParamTmp)	
		aCposAdi	:= FIWS3STR(8, cTmpAdi)	

		oBrowseAdi:= FWMarkBrowse():New() 
		oBrowseAdi:SetOwner(oPanelD2) 
		oBrowseAdi:SetAlias(cTmpAdi)
		oBrowseAdi:SetDataTable(.T.)
		oBrowseAdi:AddLegend("EMPTY(E2_SALDO)", "RED", "Pago")
		oBrowseAdi:AddLegend("!EMPTY(E2_SALDO)", "GREEN", "Pagamento pendente")
		oBrowseAdi:SetColumns(aCposAdi)
		oBrowseAdi:SetDescription('')   
		oBrowseAdi:SetProfileID('2') 
		oBrowseAdi:DisableReport() 
		oBrowseAdi:DisableConfig()
		oBrowseAdi:DisableLocate()
		oBrowseAdi:SetLineHeight(nTamLinha)
		oBrowseAdi:SetDoubleClick({|| FWMsgRun(, {|| FWS03DET(3, oBrowseAdi)}, "Adiantamentos - Títulos a Pagar...", "Aguarde o carregamento da tela...")})

		aSeekTmp3 := {	{"Cod. Copastur"				, {{"","C", nTamAlatur, 0, "E2_XALATUR", "@!"}}},;
						{"Número+Prefixo+Parcela+Tipo"	, {{"","C", 20, 0, "E2_NUM+E2_PREFIXO+E2_PARCELA+E2_TIPO", "@!"}}},;
						{"Vencimento"					, {{"","D", 08, 0, "E2_VENCREA", "@D"}}}}				

		oBrowseAdi:SetSeek(.T., aSeekTmp3)
		oBrowseAdi:Activate()
		
		
		//Despesas
		//Estrutura e tabela temporaria
		cTmpDesp 	:= U_FIWS3TMP(9, cTmpDesp, aParamTmp)
		aCposDesp 	:= FIWS3STR(9, cTmpDesp)
		
		oBrowseDesp:= FWMarkBrowse():New() 
		oBrowseDesp:SetOwner(oPanelD3) 
		oBrowseDesp:SetAlias(cTmpDesp)
		oBrowseDesp:SetDataTable(.T.)
		oBrowseDesp:AddLegend("EMPTY(E2_SALDO)", "RED", "Pago")
		oBrowseDesp:AddLegend("!EMPTY(E2_SALDO)", "GREEN", "Pagamento pendente")
		oBrowseDesp:SetColumns(aCposDesp)
		oBrowseDesp:SetDescription('')   
		oBrowseDesp:SetProfileID('3') 
		oBrowseDesp:DisableReport() 
		oBrowseDesp:DisableConfig()
		oBrowseDesp:DisableLocate()
		oBrowseDesp:SetLineHeight(nTamLinha)
		oBrowseDesp:SetDoubleClick({|| FWMsgRun(, {|| FWS03DET(3, oBrowseDesp)}, "Despesas - Títulos a Pagar...", "Aguarde o carregamento da tela...")})

		aSeekTmp3 := {	{"Cod. Copastur"				, {{"","C", nTamAlatur, 0, "E2_XALATUR", "@!"}}},;
						{"Número+Prefixo+Parcela+Tipo"	, {{"","C", 20, 0, "E2_NUM+E2_PREFIXO+E2_PARCELA+E2_TIPO", "@!"}}},;
						{"Vencimento"					, {{"","D", 08, 0, "E2_VENCREA", "@D"}}}}				

		oBrowseDesp:SetSeek(.T., aSeekTmp3)
		oBrowseDesp:Activate()

		//Integrações
		//Estrutura e tabela temporaria
		cTmpInt 	:= U_FIWS3TMP(6, cTmpInt, aParamTmp)
		aCposBInt 	:= FIWS3STR(6, cTmpInt)
		
		oBrowseInt:= FWBrowse():New() 
		oBrowseInt:SetOwner(oPanelD4) 
		oBrowseInt:SetAlias(cTmpInt)
		oBrowseInt:SetDataTable(.T.)
		oBrowseInt:AddLegend("ZWQ_STATUS = '01'", "YELLOW", "Pendente")
		oBrowseInt:AddLegend("ZWQ_STATUS = '02'", "RED", "Erro")
		oBrowseInt:AddLegend("ZWQ_STATUS = '05'", "GREEN", "Processado")		
		oBrowseInt:SetColumns(aCposBInt)
		oBrowseInt:SetDescription('')   
		oBrowseInt:SetProfileID('4') 
		oBrowseInt:DisableReport() 
		oBrowseInt:DisableConfig()
		oBrowseInt:DisableLocate()
		oBrowseInt:SetLineHeight(nTamLinha)
		oBrowseInt:SetDoubleClick({|| FWMsgRun(, {|| FWS03DET(2, oBrowseInt)}, "Integrações...", "Aguarde o carregamento da tela...")})
		oBrowseInt:Activate()	

		///// Relacionamento entre os Paineis 
		
		//Participante x Adiantamento		
		oRelacBrw1:= FWBrwRelation():New()
		oRelacBrw1:AddRelation(oBrowseCad, oBrowseAdi, {{'E2_FORNECE', 'RD0_FORNEC'}, {'E2_LOJA', 'RD0_LOJA'}, {'E2_PREFIXO', 'GetNewPar("MV_RESPREF", "ADT")'}})
		oRelacBrw1:Activate()

		//Participante x Reembolso
		oRelacBrw2:= FWBrwRelation():New()
		oRelacBrw2:AddRelation(oBrowseCad, oBrowseDesp, {{'E2_FORNECE', 'RD0_FORNEC'}, {'E2_LOJA', 'RD0_LOJA'}, {'E2_PREFIXO', 'GetNewPar("MV_RESPFCP", "DP")'}})
		oRelacBrw2:Activate()

		//Integrações
		oRelacBrw3:= FWBrwRelation():New()
		oRelacBrw3:AddRelation(oBrowseCad, oBrowseInt, {{"ZWQ_CALIAS", "'RD0'"}, {'ZWQ_FILALI', 'RD0_FILIAL'}, {'ZWQ_CHAVE', 'RD0_CODIGO'}, {'ZWQ_TPPROC', "'4/5'", '$'}})
		oRelacBrw3:Activate()
	
		Activate MsDialog oDlgCad Center //ON INIT {|| oFWLayer:Hide()}
			
		FIWS3KEY()
		FIWS3REF(.T., .F.)
	Else
		Help(NIL, NIL, "FINWS03D", NIL, "A integração dos pagamentos está desativada.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique a configuração do parâmetro ZZ_WSAINT5."})
	EndIf

	RestArea(aArea)
			
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FWS03ADI

Rotina para a integração dos pagamentos - Adiantamentos

@author  CM Solutions - Allan Constantino Bonfim
@since   05/02/2020
@version P12

/*/
//-------------------------------------------------------------------   
User Function FWS03ADI(oBrowse, cEmpOri, cFilOri, cFilPart, cCodPart, aAdiAla) 
	
	Local aArea			:= GetArea()
	Local cAliasBrw		:= ""
	//Local nX			:= 0
	Local nY 			:= 0
	Local lRet			:= .T.
	Local aAdto			:= {}
	Local lRefresh		:= .F.
	Local nLinAtu		:= 1
	//Local aAreaBrw
	
	Default oBrowse		:= NIL
	Default cEmpOri		:= FwCodEmp()
	Default cFilOri		:= FwCodFil()
	Default cFilPart	:= ""
	Default cCodPart	:= ""
	Default aAdiAla		:= {}


	If Valtype(oBrowse) == "O"
		cAliasBrw	:= oBrowse:Alias()
		//aAreaBrw 	:= (cAliasBrw)->(GetArea())
		cFilPart	:= (cAliasBrw)->RD0_FILIAL
		cCodPart	:= (cAliasBrw)->RD0_CODIGO
		nLinAtu		:= oBrowse:oBrowse:nAt
	EndIf	
	
	If !Empty(cCodPart)

		If Len(aAdiAla) > 0
			aAdto := aAdiAla
		Else
			FWMsgRun(, {|| aAdto := FWS3FSEL(1, cEmpOri, cFilOri, cFilPart, cCodPart)}, "Aguarde...", "Consultando os adiantamentos no Copastur...")
		EndIf

		If Len(aAdto) > 0
			lRefresh	:= .T.

			DbSelectArea("RD0")
			DbSetOrder(1)

			//Begin Transaction
				//For nX := 1 to Len(aAdto)

					//If Len(aAdto) > 0
						If RD0->(DbSeek((cAliasBrw)->RD0_FILIAL+(cAliasBrw)->RD0_CODIGO))	
							If !Empty(RD0->RD0_EMPATU) .AND. !Empty(RD0->RD0_FILATU)							
								cEmpOri	:= RD0->RD0_EMPATU
								cFilOri := RD0->RD0_FILATU
							ENDIF

							For nY := 1 to Len(aAdto)
								//Begin Transaction
									lRet := FIWS3REP(4, .F.,, cEmpOri, cFilOri, cFilPart, cCodPart, "4")

									FWMsgRun(, {|| lRet := U_FINWS05I(cEmpOri, cFilOri, cFilPart, cCodPart, "1", "4", Alltrim(aAdto[nY][1]), aAdto[nY][2])}, "Participante "+ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME), "Gerando o adiantamento "+Alltrim(aAdto[nY]))
									//If lRet
									FWMsgRun(, {|| lRet := U_FINWS03P(cEmpOri, cFilOri, "RD0", cFilPart, cCodPart,, "4",, Alltrim(aAdto[nY][1]))}, "Participante "+ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME), "Integrando o adiantamento "+Alltrim(aAdto[nY]))
									//EndIf
									
									If !lRet
										Help(NIL, NIL, "FWS03ADI", NIL, "Falha na integração do adiantamento "+Alltrim(aAdto[nY])+" do participante "+ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o log da integração e tente novamente."})
										DisarmTransaction()
									EndIf
								//End Transaction
							Next
						EndIf
					//EndIf
					//FWMsgRun(, {|| aRet := U_FIWS7FIN(cEmpOri, cFilOri, cFilPart, cCodPart, .T., .F., aAdto[nX][1], aAdto[nX][2])}, "Aguarde...", "Gerando o adiantamento "+Alltrim(aAdto[nX])+ " no Protheus...")	
				//Next
			//End Transaction			
		EndIf
	Else
		Help(NIL, NIL, "FWS03ADI", NIL, "O participante informado não foi localizado ("+Alltrim(cCodPart)+").", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o participante selecionado e tente novamente."})
	EndIF

	If Valtype(oBrowse) == "O"
		//RestArea(aAreaBrw)
		If lRefresh
			//FIWS3RE1(.T., .F., .F., .T., .F., .T., .T.)
			FIWS3RE1(.T., .F., .T., .T., .F., .T., .T.)
			oBrowse:GoTo(nLinAtu, .T.)
			oBrowse:OnChange()		
		EndIf
	EndIf

	RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FWS03DSP

Rotina para a integração dos pagamentos - Despesas / Reembolso

@author  CM Solutions - Allan Constantino Bonfim
@since   05/02/2020
@version P12

/*/
//-------------------------------------------------------------------   
User Function FWS03DSP(oBrowse, cEmpOri, cFilOri, cFilPart, cCodPart, aDespAla) 
	
	Local aArea			:= GetArea()
	Local cAliasBrw		:= ""
	//Local nX			:= 0
	Local nY 			:= 0
	Local lRet			:= .T.
	Local aDesp			:= {}
	Local lRefresh		:= .F.
	Local nLinAtu		:= 1

	Default oBrowse		:= NIL
	Default cEmpOri		:= FwCodEmp()
	Default cFilOri		:= FwCodFil()
	Default cFilPart	:= ""
	Default cCodPart	:= ""
	Default aDespAla		:= {}
	

	If Valtype(oBrowse) == "O"
		cAliasBrw	:= oBrowse:Alias()
		cFilPart	:= (cAliasBrw)->RD0_FILIAL
		cCodPart	:= (cAliasBrw)->RD0_CODIGO
		nLinAtu		:= oBrowse:oBrowse:nAt
	EndIf	

	If !Empty(cCodPart)

		If Len(aDespAla) > 0
			aDesp := aDespAla
		Else
			FWMsgRun(, {|| aDesp := FWS3FSEL(2, cEmpOri, cFilOri, cFilPart, cCodPart)}, "Aguarde...", "Consultando as despesas no Copastur...")
		EndIf

		If Len(aDesp) > 0
			lRefresh	:= .T.

			DbSelectArea("RD0")
			DbSetOrder(1)

			//Begin Transaction
				//For nX := 1 to Len(aDesp)

					//If Len(aDesp) > 0
						If RD0->(DbSeek((cAliasBrw)->RD0_FILIAL+(cAliasBrw)->RD0_CODIGO))	
							If !Empty(RD0->RD0_EMPATU) .AND. !Empty(RD0->RD0_FILATU)							
								cEmpOri	:= RD0->RD0_EMPATU
								cFilOri := RD0->RD0_FILATU
							ENDIF

							For nY := 1 to Len(aDesp)
								//Begin Transaction
									lRet := FIWS3REP(4, .F.,, cEmpOri, cFilOri, cFilPart, cCodPart, "5")

									FWMsgRun(, {|| lRet := U_FINWS05I(cEmpOri, cFilOri, cFilPart, cCodPart, "1", "5", Alltrim(aDesp[nY][1]), aDesp[nY][2])}, "Participante "+ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME), "Gerando a despesa "+Alltrim(aDesp[nY]))
									//If lRet
									FWMsgRun(, {|| lRet := U_FINWS03P(cEmpOri, cFilOri, "RD0", cFilPart, cCodPart,, "5",, Alltrim(aDesp[nY][1]))}, "Participante "+ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME), "Integrando a despesa "+Alltrim(aDesp[nY]))
									//EndIf
									
									If !lRet
										Help(NIL, NIL, "FWS03DSP", NIL, "Falha na integração da despesa "+Alltrim(aDesp[nY])+" do participante "+ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o log da integração e tente novamente."})
										DisarmTransaction()
									EndIf
								//End Transaction
							Next
						EndIf
					//EndIf
					//FWMsgRun(, {|| aRet := U_FIWS7FIN(cEmpOri, cFilOri, cFilPart, cCodPart, .T., .F., aAdto[nX][1], aAdto[nX][2])}, "Aguarde...", "Gerando o adiantamento "+Alltrim(aAdto[nX])+ " no Protheus...")	
				//Next
			//End Transaction			
		EndIf
	Else
		Help(NIL, NIL, "FWS03DSP", NIL, "O participante informado não foi localizado ("+Alltrim(cCodPart)+").", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o participante selecionado e tente novamente."})
	EndIF

	If Valtype(oBrowse) == "O"
		//RestArea(aAreaBrw)
		If lRefresh
			//FIWS3RE1(.T., .F., .F., .T., .T., .T., .T.)
			FIWS3RE1(.T., .F., .T., .T., .F., .T., .T.)
			oBrowse:GoTo(nLinAtu, .T.)
			oBrowse:OnChange()		
		EndIf
	EndIf

	RestArea(aArea)

	/*
	Local aArea			:= GetArea()
	Local cAliasBrw		:= ""
	Local aRet			:= {}
	Local aDesp			:= {}
	Local nX			:= 0
	Local aAreaBrw
	
	Default oBrowse		:= NIL
	Default cEmpOri		:= FwCodEmp()
	Default cFilOri		:= FwCodFil()
	Default cFilPart	:= ""
	Default cCodPart	:= ""


	If Valtype(oBrowse) == "O"
		cAliasBrw	:= oBrowse:Alias()
		aAreaBrw 	:= (cAliasBrw)->(GetArea())

		cFilPart	:= (cAliasBrw)->RD0_FILIAL
		cCodPart	:= (cAliasBrw)->RD0_CODIGO
	EndIf	
	
	If !Empty(cCodPart)
		FWMsgRun(, {|| aDesp := FWS3FSEL(2, cEmpOri, cFilOri, cFilPart, cCodPart)}, "Aguarde...", "Consultando as despesas no Copastur...")

		If Len(aDesp) > 0
			//If Len(aDesp) > 0		
				For nX := 1 to Len(aDesp)
					FWMsgRun(, {|| aRet := U_FIWS7FIN(cEmpOri, cFilOri, cFilPart, cCodPart, .F., .T., aDesp[nX][1], aDesp[nX][2])}, "Aguarde...", "Gerando a despesa "+Alltrim(aDesp[nX][1])+ " no Protheus...")	
				Next
		EndIf
	Else
		Help(NIL, NIL, "FWS03DSP", NIL, "O participante informado não foi localizado ("+Alltrim(cCodPart)+").", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o participante selecionado e tente novamente."})
	EndIF

	If Valtype(oBrowse) == "O"
		RestArea(aAreaBrw)
	EndIf

	RestArea(aArea)
*/
Return



//-------------------------------------------------------------------
/*/{Protheus.doc} FWS03DET

Visualização dos detalhes do grid

@author  CM Solutions - Allan Constantino Bonfim
@since   03/12/2019
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
Static Function FWS03DET(nGrid, oBrowse)
	
	Local aArea 			:= GetArea()
	Local aAreaRot	
	Local cAliasBrw
	Local cEmpBkp			:= ""
	Local cFilBkp			:= ""
	
	Private cCadastro		:= "" //Compatibilidade fonte APDA020
	Private lApd020Auto 	:= .F. //Compatibilidade fonte APDA020
	
	Default nGrid 	:= 0
	
	
	If nGrid = 1 //Participantes
			
		FIWS3KEY(0)
		cAliasBrw	:= oBrowse:Alias()
		aAreaRot 	:= GetArea()		
		cCadastro	:= "Participantes" //Compatibilidade fonte APDA020
		
		DbSelectArea("RD0")
		DbGoTo((cAliasBrw)->RD0REC)
				
		FWMsgRun(, {|| Apda020Mnt("RD0", RD0->(RECNO()), 2)}, "Carregando...", "Aguarde...")
		
		RestArea(aAreaRot)		
		FIWS3KEY(1)
		
	ElseIf nGrid = 2 //Integrações
			
		FIWS3KEY(0)
		cAliasBrw	:= oBrowse:Alias()
		aAreaRot 	:= GetArea()

		DbSelectArea("ZWQ")
		DbGoTo((cAliasBrw)->ZWQREC)
		
		FWMsgRun(, {|| FWExecView("",'FINWS002', MODEL_OPERATION_VIEW,, {||.T.})}, "Carregando...", "Aguarde.....")

		RestArea(aAreaRot)		
		FIWS3KEY(1)

	ElseIf nGrid = 3 //Financeiro

		FIWS3KEY(0)
		cAliasBrw	:= oBrowse:Alias()
		aAreaRot 	:= GetArea()
		
		cEmpBkp 	:= SM0->M0_CODIGO //Seto as variaveis de ambiente
		cFilBkp 	:= SM0->M0_CODFIL
		
		DbSelectArea("SE2")
		SE2->(DbGoto((cAliasBrw)->SE2REC))
		
		dbSelectArea("SM0") //Abro a SM0
		SM0->(dbSetOrder(1))
		SM0->(dbSeek(FWCodEmp()+SE2->E2_FILIAL, .T.)) //Posiciona Empresa
		
		cEmpAnt := SM0->M0_CODIGO //Seto as variaveis de ambiente
		cFilAnt := SM0->M0_CODFIL
		
		FWMsgRun(, {|| AxVisual("SE2", SE2->(Recno()),2)}, "Aguarde...", "Carregando titulos a pagar...")
		
		dbSelectArea("SM0") //Abro a SM0
		SM0->(dbSetOrder(1))
		SM0->(dbSeek(cEmpAnt+cFilAnt, .T.)) //Posiciona Empresa
		
		cEmpAnt := cEmpBkp
		cFilAnt := cFilBkp

		RestArea(aAreaRot)		
		FIWS3KEY(1)

	ElseIf nGrid = 4 //Centro de Custos
			
		FIWS3KEY(0)
		cAliasBrw	:= oBrowse:Alias()
		aAreaRot 	:= GetArea()

		DbSelectArea("CTT")
		DbGoTo((cAliasBrw)->CTTREC)
	
		FWMsgRun(, {|| AxVisual("CTT", CTT->(RECNO()), 2)}, "Carregando...", "Aguarde...")
	
		RestArea(aAreaRot)		
		FIWS3KEY(1)
		
	EndIf
	
	RestArea(aArea)

Return


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FIWS3INT

Copastur - Integra manualmente a tabela integradora

@author CM Solutions - Allan Constantino Bonfim
@since  05/12/2019
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FIWS3INT(nOpcao, lConfirm, lOnline, lIntSup, oBrowse, oBrwDet, cEmpOri, cFilOri, cRepFil, cRepChv, cTpProc, lReset)


	Local aArea 	:= GetArea()
	Local aAreaZWQ	:= ZWQ->(GetArea())	
	Local lRet		:= .T.
	Local nLinAtu	:= 1
	Local lRefresh	:= .F.
	Local _cEmpOri	:= FwCodEmp()
	Local _cFilOri	:= FwCodFil()
	Local aRetDesp	:= {}
	Local _nX		:= 0
	Local lContinua	:= .T.
	Local _lBrowse	:= ValtyPe(oBrowse) == "O"
	Local _cInteg	:= " dos cadastros "
	Local cAliasBrw
	Local aAreaBrw
	Local cABrwDet
	Local _cFilBrw	:= ""
	Local _aAreaRD0
	Local cBMarca	:= ""

	Default nOpcao	:= 0
	Default lConfirm:= .F.
	Default lOnline	:= .F.
	Default lIntSup	:= .F.
	Default oBrwDet	:= NIL
	Default cEmpOri	:= FwCodEmp()
	Default cFilOri	:= FwCodFil() 
	Default cRepFil := ""
	Default cRepChv	:= ""
	Default cTpProc	:= ""
	Default lReset	:= .F.


	If _lBrowse
		cAliasBrw	:= oBrowse:Alias()
		aAreaBrw 	:= (cAliasBrw)->(GetArea())
		nLinAtu		:= oBrowse:oBrowse:nAt
		cBMarca 	:= oBrowse:cMark

		If ValtyPe(oBrwDet) == "O" 
			cABrwDet	:= oBrwDet:Alias()	
		EndIf
	Else
		If !Empty(cRepChv) .AND. !Empty(cTpProc)
			cAliasBrw := U_FIWS3TMP(1,, {"1", Alltrim(cRepChv), "", ""}, cTpProc) //U_FIWS3TMP(2,, {"2"}, "1")
		EndIf
	EndIf
	
	If lConfirm
		If nOpcao == 1 //Participantes
			_cInteg := " dos participantes "
		ElseIf nOpcao == 2 //Centro de Custos
			_cInteg := " dos centro de custos "
		ElseIf nOpcao == 3 //Aprovadores
			_cInteg := " dos aprovadores "
		ElseIf nOpcao == 4 //Financeiro
			_cInteg := " das despesas "
		EndIf

		lContinua := MsgYesNo ("Confirma a integração para o Copastur "+_cInteg+" selecionados ?", "FIWS3INT")
	EndIf 

	If lContinua
		If nOpcao == 1 //Participantes

			DbSelectArea("FL2") //Cadastro empresas Copastur
			DbSetOrder(1) //FL2_FILIAL, FL2_BKOEMP, FL2_LICENC	

			DbSelectArea("RD0")
			DbSetOrder(1)
			
			If lReset
				//Participante
				If RD0->(DbSeek((cAliasBrw)->RD0_FILIAL+(cAliasBrw)->RD0_CODIGO))
					If !Empty(RD0->RD0_EMPATU) .AND. !Empty(RD0->RD0_FILATU)							
						_cEmpOri	:= RD0->RD0_EMPATU
						_cFilOri 	:= RD0->RD0_FILATU
					ENDIF

					FWMsgRun(, {|| lRet := U_FINWS05I(_cEmpOri, _cFilOri, RD0->RD0_FILIAL, RD0->RD0_CODIGO, "2", "1")}, "Participante...", ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))

					lRefresh := .T.
				EndIf	

				//Envia a integração para o Copastur manualmente
				If lRet .AND. lOnline					
					If RD0->(DbSeek((cAliasBrw)->RD0_FILIAL+(cAliasBrw)->RD0_CODIGO))	
						If !Empty(RD0->RD0_EMPATU) .AND. !Empty(RD0->RD0_FILATU)							
							_cEmpOri	:= RD0->RD0_EMPATU
							_cFilOri 	:= RD0->RD0_FILATU
						ENDIF

						If IsInCallStack("U_FIWS3RD0")
							lReset := .F.
						EndIf

						FWMsgRun(, {|| lRet := U_FINWS03P(_cEmpOri, _cFilOri, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO,,, lReset)}, "Integrando o participante...", ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
					EndIf
					
					lRefresh := .T.
				EndIf 		
			Else

				DbSelectArea(cAliasBrw)

				If !Empty(cBMarca)
					_cFilBrw := "(cAliasBrw)->RD0_MRKBRW == '"+cBMarca+"'"
				Else
					_cFilBrw := "(cAliasBrw)->RD0_MRKBRW <> ' '"
				EndIf

				SET FILTER TO &_cFilBrw
				
				(cAliasBrw)->(DbGoTop())
				
				While !(cAliasBrw)->(EOF())

					If !Empty((cAliasBrw)->RD0_MRKBRW) //oBrowse:IsMark() //!Empty((cAliasBrw)->RD0_MRKBRW)

						//Aprovador
						If lIntSup .AND. !Empty((cAliasBrw)->RD0_APROPC)
							If RD0->(DbSeek((cAliasBrw)->RD0_FILIAL+(cAliasBrw)->RD0_APROPC))	
								If !Empty(RD0->RD0_EMPATU) .AND. !Empty(RD0->RD0_FILATU)					
									_cEmpOri	:= RD0->RD0_EMPATU	
									_cFilOri 	:= RD0->RD0_FILATU
								EndIf

								FWMsgRun(, {|| lRet := U_FINWS05I(_cEmpOri, _cFilOri, RD0->RD0_FILIAL, RD0->RD0_CODIGO, "2", "2")}, "Aprovador...", ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))

								lRefresh := .T.	
							EndIf	
						EndIf			
						
						//Participante
						If RD0->(DbSeek((cAliasBrw)->RD0_FILIAL+(cAliasBrw)->RD0_CODIGO))
							If !Empty(RD0->RD0_EMPATU) .AND. !Empty(RD0->RD0_FILATU)							
								_cEmpOri	:= RD0->RD0_EMPATU
								_cFilOri 	:= RD0->RD0_FILATU
							ENDIF

							FWMsgRun(, {|| lRet := U_FINWS05I(_cEmpOri, _cFilOri, RD0->RD0_FILIAL, RD0->RD0_CODIGO, "2", "1")}, "Participante...", ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))

							lRefresh := .T.
						EndIf	
						
						//Envia a integração para o Copastur manualmente
						If lRet .AND. lOnline
							If lIntSup .AND. !Empty((cAliasBrw)->RD0_APROPC)
								If RD0->(DbSeek((cAliasBrw)->RD0_FILIAL+(cAliasBrw)->RD0_APROPC))	

									If !Empty(RD0->RD0_EMPATU) .AND. !Empty(RD0->RD0_FILATU)					
										_cEmpOri	:= RD0->RD0_EMPATU
										_cFilOri 	:= RD0->RD0_FILATU
									ENDIF

									FWMsgRun(, {|| lRet := U_FINWS03P(_cEmpOri, _cFilOri, "RD0", RD0->RD0_FILIAL, RD0->RD0_APROPC)}, "Integrando o aprovador...", ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
								EndIf
							EndIf

							If RD0->(DbSeek((cAliasBrw)->RD0_FILIAL+(cAliasBrw)->RD0_CODIGO))	
								If !Empty(RD0->RD0_EMPATU) .AND. !Empty(RD0->RD0_FILATU)							
									_cEmpOri	:= RD0->RD0_EMPATU
									_cFilOri 	:= RD0->RD0_FILATU
								ENDIF

								FWMsgRun(, {|| lRet := U_FINWS03P(_cEmpOri, _cFilOri, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO)}, "Integrando o participante...", ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
							EndIf
							
							lRefresh := .T.
						EndIf 
						
						If _lBrowse				
							oBrowse:MarkRec()								
						EndIf
					EndIf			
					
					(cAliasBrw)->(DbSkip())
				EndDo	

				
				DbSelectArea(cAliasBrw)
				_cFilBrw := ""
				SET FILTER TO &_cFilBrw
					
			EndIf

			If _lBrowse
				If lRefresh
					FIWS3RE1(.T., .F., .T., .T., .F., .F., .F.)
					oBrowse:GoTo(nLinAtu, .T.)
					oBrowse:OnChange()		
				EndIf
			EndIf

		ElseIf nOpcao == 2 //Centro de Custos

			DbSelectArea("CTT")
			DbSetOrder(1)
			
			DbSelectArea(cAliasBrw)
			_cFilBrw := "(cAliasBrw)->CTTOK <> ' '"
			SET FILTER TO &_cFilBrw

			(cAliasBrw)->(DbGoTop())
			
			While !(cAliasBrw)->(EOF())
				If !Empty((cAliasBrw)->CTTOK) //oBrowse:IsMark()
					//Centro de Custo Superior
					If lIntSup .AND. !Empty((cAliasBrw)->CTT_CCSUP)
						If CTT->(DbSeek((cAliasBrw)->CTT_FILIAL+(cAliasBrw)->CTT_CCSUP))															
							If (cAliasBrw)->CTT_BLOQ = "1"
								FWMsgRun(, {|| lRet := U_FINWS04I(_cEmpOri, _cFilOri, CTT->CTT_FILIAL, CTT->CTT_CUSTO, "3")}, "Centro de Custos Superior...", ALLTRIM(CTT->CTT_CUSTO) + " - " + ALLTRIM(CTT->CTT_DESC01))
							else
								FWMsgRun(, {|| lRet := U_FINWS04I(_cEmpOri, _cFilOri, CTT->CTT_FILIAL, CTT->CTT_CUSTO, "2")}, "Centro de Custos Superior...", ALLTRIM(CTT->CTT_CUSTO) + " - " + ALLTRIM(CTT->CTT_DESC01))
							ENDIF

							lRefresh := .T.
						EndIf					
					EndIf			
								
					//Centro de Custo
					If CTT->(DbSeek((cAliasBrw)->CTT_FILIAL+(cAliasBrw)->CTT_CUSTO))
						If (cAliasBrw)->CTT_BLOQ = "1"
							FWMsgRun(, {|| lRet := U_FINWS04I(_cEmpOri, _cFilOri, CTT->CTT_FILIAL, CTT->CTT_CUSTO, "3")}, "Centro de Custos...", ALLTRIM(CTT->CTT_CUSTO) + " - " + ALLTRIM(CTT->CTT_DESC01))
						Else
							FWMsgRun(, {|| lRet := U_FINWS04I(_cEmpOri, _cFilOri, CTT->CTT_FILIAL, CTT->CTT_CUSTO, "2")}, "Centro de Custos...", ALLTRIM(CTT->CTT_CUSTO) + " - " + ALLTRIM(CTT->CTT_DESC01))
						ENDIF

						lRefresh := .T.
					EndIf					
			
					//Envia a integração para o Copastur manualmente
					If lRet .AND. lOnline
						If lIntSup .AND. !Empty((cAliasBrw)->CTT_CCSUP)
							FWMsgRun(, {|| lRet := U_FINWS03P(_cEmpOri, _cFilOri, "CTT", (cAliasBrw)->CTT_FILIAL, (cAliasBrw)->CTT_CCSUP,, "3")}, "Integrando o centro de custos superior com o Copastur...", ALLTRIM((cAliasBrw)->CTT_CCSUP))
						EndIf
								
						FWMsgRun(, {|| lRet := U_FINWS03P(_cEmpOri, _cFilOri, "CTT", (cAliasBrw)->CTT_FILIAL, (cAliasBrw)->CTT_CUSTO,, "3")}, "Integrando o centro de custos com o Copastur...", ALLTRIM((cAliasBrw)->CTT_CUSTO) + " - " + ALLTRIM((cAliasBrw)->CTT_DESC01))
						lRefresh := .T.
					EndIf 
					If _lBrowse
						oBrowse:MarkRec()										
					EndIf
				EndIf			
				
				(cAliasBrw)->(DbSkip())
			EndDo		

			DbSelectArea(cAliasBrw)
			_cFilBrw := ""
			SET FILTER TO &_cFilBrw

			If _lBrowse
				If lRefresh
					FIWS3RE1(.T., .F., .T., .T., .F., .F., .F.)
					oBrowse:GoTo(nLinAtu, .T.)
					oBrowse:OnChange()		
				EndIf
			EndIf

		ElseIf nOpcao == 3 //Aprovadores

			DbSelectArea("FL2") //Cadastro empresas Copastur
			DbSetOrder(1) //FL2_FILIAL, FL2_BKOEMP, FL2_LICENC	

			DbSelectArea("RD0")
			//DbSetOrder(1)
			//DbOrderNickName("RD00000001") // RD0_FILIAL+RD0_APROPC

			DbSelectArea(cAliasBrw)
			
			If !Empty(cBMarca)
				_cFilBrw := "(cAliasBrw)->RD0_MRKBRW == '"+cBMarca+"'"
			Else
				_cFilBrw := "(cAliasBrw)->RD0_MRKBRW <> ' '"
			EndIf
			
			SET FILTER TO &_cFilBrw

			(cAliasBrw)->(DbGoTop())
			
			_aAreaRD0 := GetArea()

			While !(cAliasBrw)->(EOF())
				If !Empty((cAliasBrw)->RD0_MRKBRW) //oBrowse:IsMark()		
						RD0->(DbOrderNickName("RD00000001")) // RD0_FILIAL+RD0_APROPC
						If RD0->(DbSeek((cAliasBrw)->RD0_FILIAL+(cAliasBrw)->RD0_CODIGO))
							While !RD0->(EOF()) .AND. RD0->RD0_FILIAL == (cAliasBrw)->RD0_FILIAL .AND. RD0->RD0_APROPC == (cAliasBrw)->RD0_CODIGO
							
								If !Empty(RD0->RD0_EMPATU) .AND. !Empty(RD0->RD0_FILATU)					
									_cEmpOri	:= RD0->RD0_EMPATU
									_cFilOri 	:= RD0->RD0_FILATU
								ENDIF
								
								If cEmpOri+cFilOri == _cEmpOri+_cFilOri
									FWMsgRun(, {|| lRet := U_FINWS06I(_cEmpOri, _cFilOri, RD0->RD0_FILIAL, RD0->RD0_CODIGO, "1", "2")}, "Integrando o aprovador "+ALLTRIM((cAliasBrw)->RD0_CODIGO) + " - " + ALLTRIM((cAliasBrw)->RD0_NOME), "Participante "+ ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))

									lRefresh := .T.

									//Envia a integração para o Copastur manualmente
									If lRet .AND. lOnline
										FWMsgRun(, {|| lRet := U_FINWS03P(_cEmpOri, _cFilOri, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO, , "2")}, "Integrando o aprovador "+ALLTRIM((cAliasBrw)->RD0_CODIGO) + " - " + ALLTRIM((cAliasBrw)->RD0_NOME), "Participante "+ ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))

										lRefresh := .T.
									EndIf 
								EndIf

								RD0->(DbSkip())
							EndDo
						EndIf

	
					
/*
					While !(cABrwDet)->(EOF())						
						//Participante
						If RD0->(DbSeek((cABrwDet)->RD0_FILIAL+(cABrwDet)->RD0_CODIGO))
							If !Empty(RD0->RD0_EMPATU) .AND. !Empty(RD0->RD0_FILATU)					
								_cEmpOri	:= RD0->RD0_EMPATU
								_cFilOri 	:= RD0->RD0_FILATU
							ENDIF

							If Alltrim((cAliasBrw)->RD0_CODIGO) == (cABrwDet)->RD0_APROPC
								FWMsgRun(, {|| lRet := U_FINWS06I(_cEmpOri, _cFilOri, RD0->RD0_FILIAL, RD0->RD0_CODIGO, "1", "2")}, "Integrando o aprovador "+ALLTRIM((cAliasBrw)->RD0_CODIGO) + " - " + ALLTRIM((cAliasBrw)->RD0_NOME), "Participante "+ ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))

								lRefresh := .T.

								//Envia a integração para o Copastur manualmente
								If lRet .AND. lOnline
									If RD0->(DbSeek((cABrwDet)->RD0_FILIAL+(cABrwDet)->RD0_CODIGO))
										If !Empty(RD0->RD0_EMPATU) .AND. !Empty(RD0->RD0_FILATU)						
											_cEmpOri	:= RD0->RD0_EMPATU
											_cFilOri 	:= RD0->RD0_FILATU
										ENDIF

										FWMsgRun(, {|| lRet := U_FINWS03P(_cEmpOri, _cFilOri, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO, , "2")}, "Integrando o aprovador "+ALLTRIM((cAliasBrw)->RD0_CODIGO) + " - " + ALLTRIM((cAliasBrw)->RD0_NOME), "Participante "+ ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))

										lRefresh := .T.
									EndIf
								EndIf 
							EndIf
						EndIf	

						(cABrwDet)->(DbSkip())
					EndDo
*/

					If _lBrowse
						oBrowse:MarkRec()	
					EndIf
				EndIf
				
				(cAliasBrw)->(DbSkip())
			EndDo		
		
			RestArea(_aAreaRD0)	

			DbSelectArea(cAliasBrw)
			_cFilBrw := ""
			SET FILTER TO &_cFilBrw

/*
			DbSelectArea("FL2") //Cadastro empresas Copastur
			DbSetOrder(1) //FL2_FILIAL, FL2_BKOEMP, FL2_LICENC	

			DbSelectArea("RD0")
			DbSetOrder(1)
			
			(cAliasBrw)->(DbGoTop())
			
			While !(cAliasBrw)->(EOF())
				If !Empty((cAliasBrw)->RD0_MRKBRW) //oBrowse:IsMark() //!Empty((cAliasBrw)->RD0_MRKBRW)

					//Aprovador
					If lIntSup .AND. !Empty((cAliasBrw)->RD0_APROPC)
						If RD0->(DbSeek((cAliasBrw)->RD0_FILIAL+(cAliasBrw)->RD0_APROPC))	
							If !Empty(RD0->RD0_EMPATU) .AND. !Empty(RD0->RD0_FILATU)					
								_cEmpOri	:= RD0->RD0_EMPATU	
								_cFilOri 	:= RD0->RD0_FILATU
							EndIf

							FWMsgRun(, {|| lRet := U_FINWS05I(_cEmpOri, _cFilOri, RD0->RD0_FILIAL, RD0->RD0_CODIGO, "2", "2")}, "Aprovador...", ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))

							lRefresh := .T.	
						EndIf	
					EndIf			
					
					//Participante
					If RD0->(DbSeek((cAliasBrw)->RD0_FILIAL+(cAliasBrw)->RD0_CODIGO))
						If !Empty(RD0->RD0_EMPATU) .AND. !Empty(RD0->RD0_FILATU)							
							_cEmpOri	:= RD0->RD0_EMPATU
							_cFilOri 	:= RD0->RD0_FILATU
						ENDIF

						FWMsgRun(, {|| lRet := U_FINWS05I(_cEmpOri, _cFilOri, RD0->RD0_FILIAL, RD0->RD0_CODIGO, "2", "1")}, "Participante...", ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))

						lRefresh := .T.
					EndIf	
					
					//Envia a integração para o Copastur manualmente
					If lRet .AND. lOnline
						If lIntSup .AND. !Empty((cAliasBrw)->RD0_APROPC)
							If RD0->(DbSeek((cAliasBrw)->RD0_FILIAL+(cAliasBrw)->RD0_APROPC))	

								If !Empty(RD0->RD0_EMPATU) .AND. !Empty(RD0->RD0_FILATU)					
									_cEmpOri	:= RD0->RD0_EMPATU
									_cFilOri 	:= RD0->RD0_FILATU
								ENDIF

								FWMsgRun(, {|| lRet := U_FINWS03P(_cEmpOri, _cFilOri, "RD0", RD0->RD0_FILIAL, RD0->RD0_APROPC)}, "Integrando o aprovador...", ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
							EndIf
						EndIf

						If RD0->(DbSeek((cAliasBrw)->RD0_FILIAL+(cAliasBrw)->RD0_CODIGO))	
							If !Empty(RD0->RD0_EMPATU) .AND. !Empty(RD0->RD0_FILATU)							
								_cEmpOri	:= RD0->RD0_EMPATU
								_cFilOri 	:= RD0->RD0_FILATU
							ENDIF

							FWMsgRun(, {|| lRet := U_FINWS03P(_cEmpOri, _cFilOri, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO)}, "Integrando o participante...", ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
						EndIf
						
						lRefresh := .T.
					EndIf 
					If _lBrowse				
						oBrowse:MarkRec()									
					EndIf
				EndIf			
				
				(cAliasBrw)->(DbSkip())
			EndDo		
*/
			If _lBrowse
				If lRefresh
					FIWS3RE1(.T., .F., .T., .T., .T., .F., .F.)
					oBrowse:GoTo(nLinAtu, .T.)
					oBrowse:OnChange()		
				EndIf
			EndIf

		ElseIf nOpcao == 4 //Financeiro

			DbSelectArea("FL2") //Cadastro empresas Copastur
			DbSetOrder(1) //FL2_FILIAL, FL2_BKOEMP, FL2_LICENC	

			DbSelectArea("RD0")
			DbSetOrder(1)

			DbSelectArea(cAliasBrw)
			
			If !Empty(cBMarca)
				_cFilBrw := "(cAliasBrw)->RD0_MRKBRW == '"+cBMarca+"'"
			Else
				_cFilBrw := "(cAliasBrw)->RD0_MRKBRW <> ' '"
			EndIf
			
			SET FILTER TO &_cFilBrw
						
			(cAliasBrw)->(DbGoTop())
				
			While !(cAliasBrw)->(EOF())
				If !Empty((cAliasBrw)->RD0_MRKBRW) //oBrowse:IsMark()		
					//Participante
					If RD0->(DbSeek((cAliasBrw)->RD0_FILIAL+(cAliasBrw)->RD0_CODIGO))
						If !Empty(RD0->RD0_EMPATU) .AND. !Empty(RD0->RD0_FILATU)							
							_cEmpOri	:= RD0->RD0_EMPATU
							_cFilOri 	:= RD0->RD0_FILATU
						ENDIF

						//Despesas no Copastur
						aRetDesp := U_FIWS7FAL(_cEmpOri, _cFilOri, RD0->RD0_FILIAL, RD0->RD0_CODIGO, .F., .T.)

						If Len(aRetDesp) > 0
							For _nX := 1 to Len(aRetDesp)
								FWMsgRun(, {|| lRet := U_FINWS05I(_cEmpOri, _cFilOri, RD0->RD0_FILIAL, RD0->RD0_CODIGO, "1", "5", aRetDesp[_nX][1], aRetDesp[_nX][2])}, "Participante...", ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
							Next
						//Else
						//	Help(NIL, NIL, "FIWS3INT", NIL, "Não existem despesas pendentes para a integração do participante "+Alltrim(RD0->RD0_NOME)+".", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o participante selecionado e tente novamente."})
						EndIf

						lRefresh := .T.
					EndIf	
				
					//Gera os títulos a pagar
					If lRet .AND. lOnline

						If RD0->(DbSeek((cAliasBrw)->RD0_FILIAL+(cAliasBrw)->RD0_CODIGO))	
							If !Empty(RD0->RD0_EMPATU) .AND. !Empty(RD0->RD0_FILATU)							
								_cEmpOri	:= RD0->RD0_EMPATU
								_cFilOri 	:= RD0->RD0_FILATU
							ENDIF

							FWMsgRun(, {|| lRet := U_FINWS03P(_cEmpOri, _cFilOri, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO,, "5")}, "Integrando as despesas do participante...", ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
						EndIf
						
						lRefresh := .T.
					EndIf 

					If _lBrowse
						oBrowse:MarkRec()										
					EndIf
				EndIf			
				
				(cAliasBrw)->(DbSkip())
			EndDo		

			DbSelectArea(cAliasBrw)
			_cFilBrw := ""
			SET FILTER TO &_cFilBrw
			
			If _lBrowse
				If lRefresh
					If nOpcao == 4 //Financeiro
						FIWS3RE1(.T., .F., .T., .T., .F., .T., .T.)
					Else
						FIWS3RE1(.T., .F., .T., .T., .T., .T., .T.)
					EndIf
					
					oBrowse:GoTo(nLinAtu, .T.)
					oBrowse:OnChange()		
					RestArea(aAreaBrw)
				EndIf
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf
	
	RestArea(aAreaZWQ)
	RestArea(aArea)	

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FIWS3EXC

Copastur - Exclusão da tabela integradora do cadastro de Centro de Custos

@author CM Solutions - Allan Constantino Bonfim
@since  13/12/2019
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
Static FUNCTION FIWS3EXC(nOpcao, oBrowse)
	
	Local aArea 	:= GetArea()
	Local aAreaZWQ	:= ZWQ->(GetArea())
	Local aAreaRD0	:= RD0->(GetArea())
	Local lRet		:= .T.
	Local lRefresh	:= .F.
	Local cAliasBrw
	Local aAreaBrw
	
	Default nOpcao	:= 0
	
	If Valtype(oBrowse) == "O"
		cAliasBrw	:= oBrowse:Alias()
		aAreaBrw 	:= (cAliasBrw)->(GetArea())
		nLinAtu		:= oBrowse:oBrowse:nAt
	EndIf

	If nOpcao == 1 //Participantes
		
		If MsgYesNo ("Confirma a exclusão das integrações pendentes dos participantes selecionados ?", "FINWS003")		
			(cAliasBrw)->(DbGoTop())
		
			While !(cAliasBrw)->(EOF())
				If oBrowse:IsMark() //!Empty((cAliasBrw)->RD0_MRKBRW)
					While U_FINWSTAT("RD0",,, (cAliasBrw)->RD0_FILIAL, (cAliasBrw)->RD0_CODIGO, "01",,,"1",.T.)
						lRefresh := .T.
						lRet := U_FWS02EXC(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
					ENDDO

					While U_FINWSTAT("RD0",,, (cAliasBrw)->RD0_FILIAL, (cAliasBrw)->RD0_CODIGO, "02",,,"1",.T.)			
						lRefresh := .T.
						lRet := U_FWS02EXC(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
					ENDDO		
								
					oBrowse:MarkRec()			
				EndIf
				
				(cAliasBrw)->(DbSkip())
			EndDo
			
			If lRet
				MsgInfo("As integrações selecionadas foram excluídas com sucesso.", "FINWS003")		
			EndIf	

			If Valtype(oBrowse) == "O"
				//RestArea(aAreaBrw)
				If lRefresh
					FIWS3RE1(.T., .F., .T., .T., .F., .F., .F.)
					
					oBrowse:GoTo(nLinAtu, .T.)
					oBrowse:OnChange()		
				EndIf
			EndIf
		EndIf
				
	ElseIf nOpcao == 2 //Centro de custos

		If MsgYesNo ("Confirma a exclusão das integrações pendentes dos centros de custos selecionados ?", "FINWS003")
			(cAliasBrw)->(DbGoTop())
		
			While !(cAliasBrw)->(EOF())
				If oBrowse:IsMark() //!Empty((cAliasBrw)->RD0_MRKBRW)
					While U_FINWSTAT("CTT",,, (cAliasBrw)->CTT_FILIAL, (cAliasBrw)->CTT_CUSTO, "01",,,"3",.T.)
						lRefresh := .T.
						lRet := U_FWS02EXC(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
					ENDDO

					While U_FINWSTAT("CTT",,, (cAliasBrw)->CTT_FILIAL, (cAliasBrw)->CTT_CUSTO, "02",,,"3", .T.)				
						lRefresh := .T.
						lRet := U_FWS02EXC(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
					ENDDO		
								
					oBrowse:MarkRec()			
				EndIf
				
				(cAliasBrw)->(DbSkip())
			EndDo
			
			If lRet
				MsgInfo("As integrações selecionadas foram excluídas com sucesso.", "FINWS003")		
			EndIf

			If Valtype(oBrowse) == "O"
				//RestArea(aAreaBrw)
				If lRefresh
					FIWS3RE1(.T., .F., .T., .T., .F., .F., .F.)
					
					oBrowse:GoTo(nLinAtu, .T.)
					oBrowse:OnChange()		
				EndIf
			EndIf
		EndIf	
	
	ElseIf nOpcao == 3 //Aprovadores
		
		If MsgYesNo ("Confirma a exclusão das integrações pendentes dos aprovadores selecionados ?", "FINWS003")		
			(cAliasBrw)->(DbGoTop())
		
			While !(cAliasBrw)->(EOF())
				If oBrowse:IsMark() //!Empty((cAliasBrw)->RD0_MRKBRW)
					DbSelectArea("RD0")
					DbOrderNickName("RD00000001") // RD0_FILIAL+RD0_APROPC

					If RD0->(DbSeek((cAliasBrw)->RD0_FILIAL+(cAliasBrw)->RD0_CODIGO))
						While !RD0->(EOF()) .AND. RD0->RD0_FILIAL == (cAliasBrw)->RD0_FILIAL .AND. Alltrim(RD0->RD0_APROPC) == Alltrim((cAliasBrw)->RD0_CODIGO)
							While U_FINWSTAT("RD0",,, RD0->RD0_FILIAL, RD0->RD0_CODIGO, "01",,,"2",.T.)
								lRefresh := .T.
								lRet := U_FWS02EXC(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
							EndDo

							While U_FINWSTAT("RD0",,, RD0->RD0_FILIAL, RD0->RD0_CODIGO, "02",,,"2",.T.)
								lRefresh := .T.
								lRet := U_FWS02EXC(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
							EndDo
							RD0->(DbSkip())
						EndDo
					EndIf

					oBrowse:MarkRec()
				EndIf
				
				(cAliasBrw)->(DbSkip())
			EndDo
			
			If lRet
				MsgInfo("As integrações selecionadas foram excluídas com sucesso.", "FINWS003")		
			EndIf	

			If Valtype(oBrowse) == "O"
				//RestArea(aAreaBrw)
				If lRefresh
					FIWS3RE1(.T., .F., .T., .T., .F., .F., .F.)
					
					oBrowse:GoTo(nLinAtu, .T.)
					oBrowse:OnChange()		
				EndIf
			EndIf
		EndIf
	
	ElseIf nOpcao == 4 //Financeiro
		
		If MsgYesNo ("Confirma a exclusão das integrações pendentes dos participantes selecionados ?", "FINWS003")		
			(cAliasBrw)->(DbGoTop())
		
			While !(cAliasBrw)->(EOF())
				If oBrowse:IsMark() //!Empty((cAliasBrw)->RD0_MRKBRW)

					While U_FINWSTAT("RD0",,, (cAliasBrw)->RD0_FILIAL, (cAliasBrw)->RD0_CODIGO, "01",,,"4",.T.)
						lRefresh := .T.
						lRet := U_FWS02EXC(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
					ENDDO

					While U_FINWSTAT("RD0",,, (cAliasBrw)->RD0_FILIAL, (cAliasBrw)->RD0_CODIGO, "02",,,"4",.T.)			
						lRefresh := .T.
						lRet := U_FWS02EXC(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
					ENDDO		

					While U_FINWSTAT("RD0",,, (cAliasBrw)->RD0_FILIAL, (cAliasBrw)->RD0_CODIGO, "01",,,"5",.T.)
						lRefresh := .T.
						lRet := U_FWS02EXC(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
					ENDDO

					While U_FINWSTAT("RD0",,, (cAliasBrw)->RD0_FILIAL, (cAliasBrw)->RD0_CODIGO, "02",,,"5",.T.)			
						lRefresh := .T.
						lRet := U_FWS02EXC(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
					ENDDO		
								
					oBrowse:MarkRec()				
				EndIf
				
				(cAliasBrw)->(DbSkip())
			EndDo
			
			If lRet
				MsgInfo("As integrações selecionadas foram excluídas com sucesso.", "FINWS003")		
			EndIf

			If Valtype(oBrowse) == "O"
				//RestArea(aAreaBrw)
				If lRefresh
					FIWS3RE1(.T., .F., .T., .T., .F., .T., .T.)
					
					oBrowse:GoTo(nLinAtu, .T.)
					oBrowse:OnChange()		
				EndIf
			EndIf
		EndIf
				
	EndIf



	RestArea(aAreaRD0)
	RestArea(aAreaBrw)
	RestArea(aAreaZWQ)
	RestArea(aArea)
	
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FIWS3REP

Copastur - Reprocessamento da tabela integradora do cadastro de Centro de Custos

@author CM Solutions - Allan Constantino Bonfim
@since  26/11/2019
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
Static FUNCTION FIWS3REP(nOpcao, lConfirm, oBrowse, cEmpOri, cFilOri, cRepFil, cRepChave, cTpProc)
	
	Local aArea 		:= GetArea()
	Local aAreaZWQ		:= ZWQ->(GetArea())
	Local aAreaRD0		:= RD0->(GetArea())
	Local lRet			:= .T.
	Local lRefresh 		:= .T.
	Local cAliasBrw		:= ""
	Local lContinua		:= .T.
	Local lBrowse		:= .F.
	Local aAreaBrw
	
	Default nOpcao		:= 0
	Default lConfirm	:= .T.
	Default cEmpOri		:= FwCodEmp()
	Default cFilOri		:= FwCodFil()
	Default cRepFil 	:= ""
	Default cRepChave	:= ""
	Default cTpProc		:= ""
		

	If Valtype(oBrowse) == "O"
		lBrowse 	:= .T.
		cAliasBrw	:= oBrowse:Alias()
		aAreaBrw 	:= (cAliasBrw)->(GetArea())
		nLinAtu		:= oBrowse:oBrowse:nAt

		If nOpcao == 2
			cRepFil		:= (cAliasBrw)->CTT_FILIAL
			cRepChave	:= (cAliasBrw)->CTT_CUSTO
		Else
			cRepFil		:= (cAliasBrw)->RD0_FILIAL
			cRepChave	:= (cAliasBrw)->RD0_CODIGO
		EndIf
	EndIf

	If !Empty(cRepChave)
		
		If lConfirm
			lContinua := MsgYesNo ("Confirma o reprocessamento das integrações dos participantes selecionados ?", "FINWS003")
		EndIf 

		If nOpcao == 1 //Participantes
			If lContinua
				If lBrowse
					(cAliasBrw)->(DbGoTop())
					While !(cAliasBrw)->(EOF())
						If oBrowse:IsMark()
							cRepFil		:= (cAliasBrw)->RD0_FILIAL
							cRepChave	:= (cAliasBrw)->RD0_CODIGO
							
							While U_FINWSTAT("RD0", cEmpOri, cFilOri, cRepFil, cRepChave, "02",,,"1",.T.)
								lRefresh := .T.
								lRet := U_FWS2REPR(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
							ENDDO	
										
							oBrowse:MarkRec()			
						EndIf
						
						(cAliasBrw)->(DbSkip())
					EndDo
					
					If lRet
						If lConfirm
							MsgInfo("As integrações foram reprocessadas com sucesso.", "FINWS003")		
						EndIf
					EndIf
				Else
					While U_FINWSTAT("RD0", cEmpOri, cFilOri, cRepFil, cRepChave, "02",,,"1",.T.)
						lRet := U_FWS2REPR(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
					ENDDO
				EndIf

				If lBrowse
					RestArea(aAreaBrw)
					If lRefresh
						FIWS3RE1(.T., .F., .T., .T., .F., .F., .F.)
						oBrowse:GoTo(nLinAtu, .T.)
						oBrowse:OnChange()		
					EndIf
				EndIf
			ENDIF

		ElseIf nOpcao == 2 //Centro de custos
		
			If lContinua
				If lBrowse
					(cAliasBrw)->(DbGoTop())
					While !(cAliasBrw)->(EOF())
						If oBrowse:IsMark()
							cRepFil		:= (cAliasBrw)->CTT_FILIAL
							cRepChave	:= (cAliasBrw)->CTT_CUSTO
							While U_FINWSTAT("CTT", cEmpOri, cFilOri, cRepFil, cRepChave, "02",,,"3",.T.)
								lRefresh := .T.
								lRet := U_FWS2REPR(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
							ENDDO

							oBrowse:MarkRec()				
						EndIf
						
						(cAliasBrw)->(DbSkip())
					EndDo
					
					If lRet
						If lConfirm
							MsgInfo("As integrações foram reprocessadas com sucesso.", "FINWS003")		
						EndIf
					EndIf
				Else
					While U_FINWSTAT("CTT", cEmpOri, cFilOri, cRepFil, cRepChave, "02",,,"3",.T.)
						lRefresh := .T.
						lRet := U_FWS2REPR(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
					ENDDO
				EndIf

				If lBrowse
					RestArea(aAreaBrw)
					If lRefresh
						FIWS3RE1(.T., .F., .T., .T., .F., .F., .F.)
						oBrowse:GoTo(nLinAtu, .T.)
						oBrowse:OnChange()		
					EndIf
				EndIf
			EndIf

		ElseIf nOpcao == 3 //Aprovadores
					
			If lContinua
				If lBrowse
					(cAliasBrw)->(DbGoTop())
					While !(cAliasBrw)->(EOF())
						If oBrowse:IsMark()
							DbSelectArea("RD0")
							DbOrderNickName("RD00000001") // RD0_FILIAL+RD0_APROPC

							If RD0->(DbSeek((cAliasBrw)->RD0_FILIAL+(cAliasBrw)->RD0_CODIGO))
								While !RD0->(EOF()) .AND. RD0->RD0_FILIAL == (cAliasBrw)->RD0_FILIAL .AND. Alltrim(RD0->RD0_APROPC) == Alltrim((cAliasBrw)->RD0_CODIGO)
									While U_FINWSTAT("RD0", RD0->RD0_EMPATU, RD0->RD0_FILATU, RD0->RD0_FILIAL, RD0->RD0_CODIGO, "02",,,"2",.T.)
										lRefresh := .T.
										lRet := U_FWS2REPR(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
									EndDo
									RD0->(DbSkip())
								EndDo
							EndIf
							oBrowse:MarkRec()
						EndIf
						
						(cAliasBrw)->(DbSkip())
					EndDo
					
					If lRet
						If lConfirm
							MsgInfo("As integrações foram reprocessadas com sucesso.", "FINWS003")
						EndIf
					EndIf
				Else
					DbSelectArea("RD0")
					DbOrderNickName("RD00000001") // RD0_FILIAL+RD0_APROPC

					If RD0->(DbSeek((cAliasBrw)->RD0_FILIAL+(cAliasBrw)->RD0_CODIGO))
						While !RD0->(EOF()) .AND. RD0->RD0_FILIAL == (cAliasBrw)->RD0_FILIAL .AND. Alltrim(RD0->RD0_APROPC) == Alltrim((cAliasBrw)->RD0_CODIGO)
							While U_FINWSTAT("RD0", RD0->RD0_EMPATU, RD0->RD0_FILATU, RD0->RD0_FILIAL, RD0->RD0_CODIGO, "02",,,"2",.T.)
								lRet := U_FWS2REPR(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
							EndDo
							RD0->(DbSkip())
						EndDo
					EndIf
				EndIf

				If lBrowse
					RestArea(aAreaBrw)
					If lRefresh
						FIWS3RE1(.T., .F., .T., .T., .F., .F., .F.)
						oBrowse:GoTo(nLinAtu, .T.)
						oBrowse:OnChange()		
					EndIf
				EndIf
			ENDIF
		
		ElseIf nOpcao == 4 //Financeiro

			If lContinua
				If lBrowse
					(cAliasBrw)->(DbGoTop())

					While !(cAliasBrw)->(EOF())
						If oBrowse:IsMark() //!Empty((cAliasBrw)->RD0_MRKBRW)
							If Empty(cTpProc)
								While U_FINWSTAT("RD0",cEmpOri, cFilOri, cRepFil, cRepChave, "02",,, "4",.T.)
									lRefresh := .T.
									lRet := U_FWS2REPR(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
								ENDDO	
								While U_FINWSTAT("RD0",cEmpOri, cFilOri, cRepFil, cRepChave, "02",,, "5",.T.)
									lRefresh := .T.
									lRet := U_FWS2REPR(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
								ENDDO	
							Else
								While U_FINWSTAT("RD0",cEmpOri, cFilOri, cRepFil, cRepChave, "02",,, cTpProc,.T.)
									lRefresh := .T.
									lRet := U_FWS2REPR(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
								ENDDO	
							EndIf

							oBrowse:MarkRec()			
						EndIf
						
						(cAliasBrw)->(DbSkip())
					EndDo
					
					If lRet
						If lConfirm
							MsgInfo("As integrações foram reprocessadas com sucesso.", "FINWS003")		
						EndIf
					EndIf
				Else
					If Empty(cTpProc)
						While U_FINWSTAT("RD0",cEmpOri, cFilOri, cRepFil, cRepChave, "02",,, "4",.T.)
							lRet := U_FWS2REPR(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
						ENDDO	
						While U_FINWSTAT("RD0",cEmpOri, cFilOri, cRepFil, cRepChave, "02",,, "5",.T.)
							lRet := U_FWS2REPR(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
						ENDDO	
					Else
						While U_FINWSTAT("RD0",cEmpOri, cFilOri, cRepFil, cRepChave, "02",,, cTpProc,.T.)
							lRet := U_FWS2REPR(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .F.)
						ENDDO	
					EndIf
				EndIf

				If lBrowse
					RestArea(aAreaBrw)
					If lRefresh
						FIWS3RE1(.T., .F., .T., .T., .F., .T., .T.)
						oBrowse:GoTo(nLinAtu, .T.)
						oBrowse:OnChange()		
					EndIf
				EndIf
			ENDIF
		
		EndIf
	EndIf

	
	RestArea(aAreaRD0)
	RestArea(aAreaZWQ)
	RestArea(aArea)

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINWS03P

Copastur - Integração Protheus -> Copastur

@author CM Solutions - Allan Constantino Bonfim
@since  11/12/2019
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FINWS03P(_cEmpOri, _cFilOri, _cAliasInt, _cFilialInt, _cChaveInt, _cStatusInt, _cTpProc, _lReset, _cCodAla)

	Local _aArea		:= GetArea()
	Local _aAreaRD0		:= RD0->(GetArea())
	Local _cQDados		:= ""
	Local _cTmpInt		:= GetNextAlias()
	Local _aRetWs		:= {}
	Local _cChave		:= ""
	Local _cOpcInt		:= "1"
	Local _nIndice		:= 1
	Local _cFilChv		:= ""
	Local _nX			:= 0
	Local _lAprovAdt	:= .T.
	Local _lAproViag	:= .T.
	Local _lDesp		:= .F.
	Local _lAdto		:= .F.
	Local _cPartChave	:= ""
	Local _aRetAprov	:= {}
	Local _cCodAlatur	:= ""
	Local _aRetFin		:= {}
	Local _lRet			:= .T.
	Local _nValAlatur	:= 0

	Default _cEmpOri	:= FwCodEmp()
	Default _cFilOri	:= FwCodFil()
	Default _cAliasInt	:= ""
	Default _cFilialInt	:= ""
	Default _cChaveInt	:= ""
	Default _cStatusInt	:= "01"	
	Default _cTpProc	:= ""
	Default _lReset		:= .F.
	Default _cCodAla	:= ""

	
	If LockByName("FINWS03P", .T., .T.)
		DbSelectArea("ZWQ")

		_cQDados := "SELECT ZWQ_FILIAL, ZWQ_CODIGO, ZWQ_EMPORI, ZWQ_FILORI, ZWQ_CALIAS, ZWQ_CHAVE, ZWQ_RECORI, "+CHR(13)+CHR(10) 
		_cQDados += "ZWQ_TPINCL, ZWQ_TPPROC, ZWQ_TINTEG, ZWQ_INDICE, ZWQ_FILALI, ZWQ_CODALA, ZWQ_VALALA, ZWQ_LOGIN, ZWQ_EMAIL, ZWQ.R_E_C_N_O_ AS ZWQREC "+CHR(13)+CHR(10) 
		_cQDados += "FROM " +RetSqlName("ZWQ")+ " ZWQ (NOLOCK) "+CHR(13)+CHR(10) 
		_cQDados += "WHERE ZWQ.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10) 
		_cQDados += "AND ZWQ_FILIAL = '"+FwxFilial("ZWQ")+"' "+CHR(13)+CHR(10)  				

		If !Empty(_cAliasInt)
			_cQDados += "AND ZWQ_CALIAS = '"+_cAliasInt+"' "+CHR(13)+CHR(10)
		EndIf
		
		If !Empty(_cFilialInt)
			_cQDados += "AND ZWQ_FILALI = '"+_cFilialInt+"' "+CHR(13)+CHR(10)
		EndIf
		
		If !Empty(_cChaveInt)
			_cQDados += "AND ZWQ_CHAVE = '"+_cChaveInt+"' "+CHR(13)+CHR(10)
		EndIf
		
		If !Empty(_cStatusInt) 
			_cQDados += "AND ZWQ_STATUS = '"+_cStatusInt+"' "+CHR(13)+CHR(10)
		EndIf
		
		If !Empty(_cTpProc)
			_cQDados += "AND ZWQ_TPPROC = '"+_cTpProc+"' "+CHR(13)+CHR(10)
		ENDIF

		If !Empty(_cCodAla)
			_cQDados += "AND ZWQ_CODALA = '"+_cCodAla+"' "+CHR(13)+CHR(10)
		EndIf

		_cQDados += "ORDER BY ZWQ_FILIAL, ZWQ_FILALI, ZWQ_CALIAS, ZWQ.R_E_C_N_O_ "+CHR(13)+CHR(10)

		_cQDados := ChangeQuery(_cQDados)	
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQDados), _cTmpInt)	
		
		While !(_cTmpInt)->(EOF())
			ZWQ->(DbGoto((_cTmpInt)->ZWQREC))
			
			_aRetWs		:= {}
			_nIndice	:= (_cTmpInt)->ZWQ_INDICE
			_cFilChv	:= (_cTmpInt)->ZWQ_FILALI
			_cChave		:= Alltrim((_cTmpInt)->ZWQ_CHAVE)
			_cOpcInt	:= (_cTmpInt)->ZWQ_TINTEG
			_cEmpOri	:= (_cTmpInt)->ZWQ_EMPORI
			_cFilOri	:= (_cTmpInt)->ZWQ_FILORI
			_cCodAlatur	:= Alltrim((_cTmpInt)->ZWQ_CODALA)
			_nValAlatur := (_cTmpInt)->ZWQ_VALALA

			If (_cTmpInt)->ZWQ_CALIAS == "RD0"			
					
				If (_cTmpInt)->ZWQ_TINTEG == "1" //Inclusão	
					
					If (_cTmpInt)->(ZWQ_TPPROC) == "2" //Aprovador

						DbSelectArea("RD0") //Cadastro Participantes
						DbSetOrder(_nIndice) //RD0_FILIAL+RD0_CODIGO
						If RD0->(DbSeek(_cFilChv+_cChave))	
							If !Empty(RD0->RD0_EMPATU) .AND. !Empty(RD0->RD0_FILATU)						
								_cEmpOri := RD0->RD0_EMPATU
								_cFilOri := RD0->RD0_FILATU
							ENDIF
							_cPartChave	:= _cFilChv+_cChave

							If !Empty(RD0->RD0_APROPC) .AND. RD0->(DbSeek(_cFilChv+RD0->RD0_APROPC))
								_lAdto 	:= RD0->RD0_XAPADT == "S"
								_lDesp	:= RD0->RD0_XAPCNF == "S" .OR. RD0->RD0_XAPINT == "S" .OR. RD0->RD0_XAPNAC == "S" .OR. RD0->RD0_XAPREE == "S"

								RD0->(DbSeek(_cPartChave))	

								_nIndice	:= (_cTmpInt)->ZWQ_INDICE
								_cFilChv	:= (_cTmpInt)->ZWQ_FILALI
								_cChave		:= Alltrim((_cTmpInt)->ZWQ_CHAVE)
								_cOpcInt	:= (_cTmpInt)->ZWQ_TINTEG
								_cEmpOri	:= (_cTmpInt)->ZWQ_EMPORI
								_cFilOri	:= (_cTmpInt)->ZWQ_FILORI
								//_cEmailPart	:= (_cTmpInt)->ZWQ_EMAIL
								_cOpcInt 	:= "1"

								//Verifica aprovações existentes
								//If _lAdto
									_aRetWs := U_FINWS06A(1, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave, 1)
									If _aRetWs[1] == "0"
										_aRetAprov := _aRetWs[8] 
										//Cancela as aprovações existentes
										For _nX := 1 to Len(_aRetAprov)
											_aRetWs := U_FINWS06A(5, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave, 1, _aRetAprov[_nX])	
										Next
									EndIf
								/*EndIf
								
								If _lDesp
									_aRetWs := U_FINWS06A(1, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave, 2)
									If _aRetWs[1] == "0"
										_aRetAprov := _aRetWs[7] 
										//Cancela as aprovações existentes
										For _nX := 1 to Len(_aRetAprov)
											_aRetWs := U_FINWS06A(5, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave, 2, _aRetAprov[_nX])	
										Next
									EndIf
								EndIf */

								//Aprovador de adiantamentos
								If _lAdto
									//Envia a nova aprovação.
									_aRetWs := U_FINWS06A(3, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave, 1)					

									If _aRetWs[1] == "0"
										_lAprovAdt := .T.
									Else
										_lAprovAdt := .F.
									EndIf	
								EndIf

								//Aprovadores de Viagem Nacional, Internacional, Conferência e Reembolso
								If _lAprovAdt
									If _lDesp
										_aRetWs := U_FINWS06A(3, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave, 2)					

										If _aRetWs[1] == "0"
											_lAproViag := .T.
										Else
											_lAproViag := .F.
										EndIf	
									EndIf
								EndIf

								//Tratamento para aprovadores sem configuração dos campos na RD0. 
								If _lAprovAdt .OR. _lAproViag
									If Empty(_aRetWs)
										_aRetWs := {"1", "", "", "999999", "Aprovador não configurado no cadastro de participantes ("+_cFilChv+_cChave+"). Verifique os campos da aba aprovação.", "", ""}
									EndIf
								EndIf
							Else
								_aRetWs := {"1", "", "", "", "", "Aprovador do participante não localizado.", "Participante ("+_cFilChv+_cChave+") não contém um aprovador válido no cadastro de participantes (RD0)."}
							EndIf
						Else
							_aRetWs := {"1", "", "", "999999", "Participante não localizado no cadastro de participantes ("+_cFilChv+_cChave+").", "", ""}
						EndIf

					ElseIf (_cTmpInt)->(ZWQ_TPPROC) == "4" //Adiantamentos
					
						If !Empty(_cCodAlatur)
							FWMsgRun(, {|| _aRetFin := U_FIWS7FIN(_cEmpOri, _cFilOri, _cFilChv, _cChave, .T., .F., _cCodAlatur, _nValAlatur)}, "Aguarde...", "Gerando o adiantamento "+_cCodAlatur+ " no Protheus...")	
							
							_aRetWs := _aRetFin
						Else
							_aRetWs := {"1", "", "", "999999", "Codigo da despesa Copastur não gravado na integração ("+(_cTmpInt)->(ZWQ_CODIGO)+").", "", ""}
						EndIf


					ElseIf (_cTmpInt)->(ZWQ_TPPROC) == "5" //Despesas
					
						If !Empty(_cCodAlatur)
							FWMsgRun(, {|| _aRetFin := U_FIWS7FIN(_cEmpOri, _cFilOri, _cFilChv, _cChave, .F., .T., _cCodAlatur, _nValAlatur)}, "Aguarde...", "Gerando a despesa "+_cCodAlatur+ " no Protheus...")	
							
							_aRetWs := _aRetFin
						Else
							_aRetWs := {"1", "", "", "999999", "Codigo da despesa Copastur não gravado na integração ("+(_cTmpInt)->(ZWQ_CODIGO)+").", "", ""}
						EndIf
					
					Else
				
						//Get para verificar se o cadastro já existe
						_aRetWs := U_FINWS05A(2, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave)

						If _aRetWs[1] == "0" //0=Existe 1=Não Existe
							_aRetWs := U_FINWS05A(4, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave,,, _lReset)

							If _aRetWs[1] == "0"
								_cOpcInt := "1"
							EndIf
						Else
							_aRetWs := U_FINWS05A(3, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave,,, _lReset)					
							
							If _aRetWs[1] == "0"
								_cOpcInt := "2"
							EndIf					
						EndIf	

					EndIf

				ElseIf (_cTmpInt)->ZWQ_TINTEG == "2" //Alteração
				
					//Get para verificar se o cadastro já existe
					_aRetWs := U_FINWS05A(2, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave)
					
					If _aRetWs[1] == "0" //0=Existe 1=Não Existe
						_aRetWs := U_FINWS05A(4, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave,,, _lReset)
						If _aRetWs[1] == "0"
							_cOpcInt := "2"
						EndIf
					Else
						_aRetWs := U_FINWS05A(3, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave,,, _lReset)
						If _aRetWs[1] == "0"
							_cOpcInt := "1"
						EndIf
					EndIf			

				ElseIf (_cTmpInt)->ZWQ_TINTEG == "3" //Exclusão
					
					//Get para verificar se o cadastro já existe
					_aRetWs := U_FINWS05A(2, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave)
				
					If _aRetWs[1] == "0"
						_aRetWs := U_FINWS05A(5, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave)
						If _aRetWs[1] == "0"
							_cOpcInt := "3"
						EndIf
					else
						_aRetWs := {"0", "", "", "999999", "Exclusão não processada pois o participante não existe no Copastur", "", ""}
						_cOpcInt:= "3"
					EndIf

				ElseIf (_cTmpInt)->ZWQ_TINTEG == "4" //Consulta				
				
					//Get para verificar se o cadastro já existe
					_aRetWs := U_FINWS05A(2, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave)
					_cOpcInt := "4"
				EndIf
			
			ElseIf (_cTmpInt)->ZWQ_CALIAS == "CTT"			
				
				If (_cTmpInt)->ZWQ_TINTEG == "1" //Inclusão	
					
					//Get para verificar se o cadastro já existe
					_aRetWs := U_FINWS04A(2, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave)

					If _aRetWs[1] == "0" //0=Existe 1=Não Existe
						_aRetWs 	:= U_FINWS04A(4, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave)
						If _aRetWs[1] == "0"
							_cOpcInt 	:= "1"
						EndIf
					Else
						_aRetWs 	:= U_FINWS04A(3, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave)					
						
						If _aRetWs[1] == "0"
							_cOpcInt 	:= "2"
						EndIf					
					EndIf								
					
				ElseIf (_cTmpInt)->ZWQ_TINTEG == "2" //Alteração
				
					//Get para verificar se o cadastro já existe
					_aRetWs := U_FINWS04A(2, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave)
					
					If _aRetWs[1] == "0" //0=Existe 1=Não Existe
						_aRetWs 	:= U_FINWS04A(4, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave)
						If _aRetWs[1] == "0"
							_cOpcInt 	:= "2"
						EndIf
					Else
						_aRetWs 	:= U_FINWS04A(3, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave)
						If _aRetWs[1] == "0"
							_cOpcInt 	:= "1"
						EndIf
					EndIf								

				ElseIf (_cTmpInt)->ZWQ_TINTEG == "3" //Exclusão
					
					//Get para verificar se o cadastro já existe
					_aRetWs := U_FINWS04A(2, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave)
				
					If _aRetWs[1] == "0"
						_aRetWs 	:= U_FINWS04A(5, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave)
						If _aRetWs[1] == "0"
							_cOpcInt := "3"
						EndIf
					else
						_aRetWs 	:= {"0", "", "", "999999", "Exclusão não processada pois o centro de custo não existe no Copastur", "", ""}
						_cOpcInt	:= "3"
					EndIf
				
				ElseIf (_cTmpInt)->ZWQ_TINTEG == "4" //Consulta				

					//Get para verificar se o cadastro já existe
					_aRetWs 	:= U_FINWS04A(2, _cEmpOri, _cFilOri, _nIndice, _cFilChv, _cChave)
					_cOpcInt 	:= "4"
				
				EndIf
			EndIf

			//ALERT("_aRetWs[1] "+ _aRetWs[1])

			If _aRetWs[1] == "0"
				//ALERT("OK 05 "+ _cCodAlatur)
				_lRet := U_FINWS2GR(4,, (_cTmpInt)->ZWQ_CODIGO, (_cTmpInt)->ZWQ_EMPORI, (_cTmpInt)->ZWQ_FILORI, (_cTmpInt)->ZWQ_CALIAS, (_cTmpInt)->ZWQ_INDICE, (_cTmpInt)->ZWQ_FILALI, (_cTmpInt)->ZWQ_CHAVE, (_cTmpInt)->ZWQ_RECORI, "05", (_cTmpInt)->ZWQ_TPINCL, _cOpcInt, (_cTmpInt)->ZWQ_TPPROC, _aRetWs[2], _aRetWs[3], "", ("CODIGO :"+_aRetWs[4]+CHR(13)+CHR(10)+"MESSAGEM: "+_aRetWs[5]), (_cTmpInt)->ZWQ_LOGIN, (_cTmpInt)->ZWQ_EMAIL, _cCodAlatur)
			Else	
				//ALERT("OK 02 "+ _cCodAlatur)
				_lRet := U_FINWS2GR(4,, (_cTmpInt)->ZWQ_CODIGO, (_cTmpInt)->ZWQ_EMPORI, (_cTmpInt)->ZWQ_FILORI, (_cTmpInt)->ZWQ_CALIAS, (_cTmpInt)->ZWQ_INDICE, (_cTmpInt)->ZWQ_FILALI, (_cTmpInt)->ZWQ_CHAVE, (_cTmpInt)->ZWQ_RECORI, "02", (_cTmpInt)->ZWQ_TPINCL, _cOpcInt, (_cTmpInt)->ZWQ_TPPROC, _aRetWs[2], _aRetWs[3], _aRetWs[6], ("CODIGO :"+_aRetWs[4]+CHR(13)+CHR(10)+"MESSAGEM: "+_aRetWs[5]+CHR(13)+CHR(10)+"ERRO: "+_aRetWs[6]+CHR(13)+CHR(10)+"DET ERRO: "+_aRetWs[7]), (_cTmpInt)->ZWQ_LOGIN, (_cTmpInt)->ZWQ_EMAIL, _cCodAlatur)
			EndIf
					
			(_cTmpInt)->(DbSkip())
		EndDo
		
		If Select(_cTmpInt) > 0
			(_cTmpInt)->(DbCloseArea())
		EndIf

		UnLockByName("FINWS03P", .T., .F.)
	Else
		Help(NIL, NIL, "FINWS03P", NIL, "Rotina de integração em execução por outro usuário.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Aguarde a finalização da integração e tente novamente."})
		lRet := .F.
	EndIf

	RestArea(_aAreaRD0)
	RestArea(_aArea)

Return _lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FNWS3USR

Copastur - Verifica se o usuário tem acesso à rotinas específicas

@author  Allan Constantino Bonfim - CM Solutions
@since   04/12/2019
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
/*Static Function FNWS3USR(cUsers)

Local lRet 		:= .F.

Default cUsers	:= GetMV("ZZ_ZZFWS3U",,"000000") 

If __cUserId $ cUsers
	lRet := .F.
EndIf 

Return lRet
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} FNWS3GRP

Copastur - Verifica se o usuário tem acesso à rotinas específicas

@author  Allan Constantino Bonfim
@since   04/12/2019
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
/*Static Function FNWS3GRP(cUser, cGrupo)

Local lRet 		:= .F.
Local aGrupos		

Default cUser		:= __cUserId
Default cGrupo	:= GetMV("ZZ_ZZFWS3G",,"000000") 

aGrupos := UsrRetGrp(__cUserId)

lRet := ASCAN(aGrupos, {|x| x = cGrupo}) > 0

Return lRet
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} FWS03DE1

Visualização dos detalhes do grid

@author  CM Solutions - Allan Constantino Bonfim
@since   29/08/2019
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
Static Function FWS03DE1(nTela)

	Local aArea 		:= GetArea()
	Local aRetDoc		:= {}
	Local aRadio		:= {}
	Local aParambox	:= {}

	
	Default nTela		:= 1
	
	//Default nGrid 	:= 0
	
			
	If nTela == 1
		aRadio	:= {"Participantes", "Integrações", "Financeiro"}		
	ElseIf nTela == 2
		aRadio	:= {"Participantes", "Integrações"}
	ElseIf nTela == 3
		aRadio	:= {"Centro de Custos", "Integrações"}
	ElseIf nTela == 4
		aRadio	:= {"Aprovadores", "Participantes", "Integrações"}		
	ElseIf nTela == 5
		aRadio	:= {"Participantes", "Adiantamentos", "Despesas", "Integrações"}		
	EndIf

	//Tipo 3 -> Radio
	//           [2]-Descricao
	//           [3]-Numerico contendo a opcao inicial do Radio
	//           [4]-Array contendo as opcoes do Radio
	//           [5]-Tamanho do Radio
	//           [6]-Validacao
	//           [7]-Flag .T./.F. Parametro Obrigatorio ?
	//aAdd(aParamBox, {9, "Selecione o documento para a visulização.",150,7,.T.})
	aAdd(aParambox, {3, "Selecione a Opção:",1, aRadio, 150, "", .T.})
	
	If ParamBox(aParambox, "Detalhes",@aRetDoc,,,,,,, "XTEL1DET", .T., .T.)
		If nTela == 1
			If aRetDoc[1] == 1
				FWS03DET(1, oBrowse1)
			ElseIf aRetDoc[1] == 2
				FWS03DET(2, oBrowse2)
			ElseIf aRetDoc[1] == 3
				FWS03DET(3, oBrowse3)
			EndIf		
		ElseIf nTela == 2
			If aRetDoc[1] == 1
				FWS03DET(1, oBrowseCad)
			ElseIf aRetDoc[1] == 2
				FWS03DET(2, oBrowseInt)
			EndIf
		ElseIf nTela == 3
			If aRetDoc[1] == 1
				FWS03DET(4, oBrowseCad)
			ElseIf aRetDoc[1] == 2
				FWS03DET(2, oBrowseInt)
			EndIf	
		ElseIf nTela == 4
			If aRetDoc[1] == 1
				FWS03DET(1, oBrowseCad)
			ElseIf aRetDoc[1] == 2
				FWS03DET(1, oBrowseDet)
			ElseIf aRetDoc[1] == 3
				FWS03DET(2, oBrowseInt)
			EndIf	
		ElseIf nTela == 5
			If aRetDoc[1] == 1
				FWS03DET(1, oBrowseCad)
			ElseIf aRetDoc[1] == 2
				FWS03DET(3, oBrowseAdi)
			ElseIf aRetDoc[1] == 3
				FWS03DET(3, oBrowseDesp)
			ElseIf aRetDoc[1] == 4
				FWS03DET(2, oBrowseInt)
			EndIf	
		Else
			MsgStop("Selecione uma opção válida. Verifique os parâmetros informados e tente novamente.", "FINWS003")
		EndIf
	EndIf
		
	RestArea(aArea)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} FP024ALL

Marca / Desmarca todos os títulos para baixa.

@author  Allan Constantino Bonfim - CM Solutions
@since   11/01/2019
@version P12
@return array, Funções da Rotina
 
/*/
//------------------------------------------------------------------------------
Static Function FINWS3AL(oBrowse)

	Local lRet			:= .T.                           
	Local nLinha		:= 0
	Local cMarca 		:= ""
	Local cAliasBrw	:= ""
	Local cCpoMark	:= ""
	Local nLinAtu		:= 1
	
	Default oBrowse	:= NIL
	
	If Valtype(oBrowse) == "O"
		nLinha 		:= oBrowse:At()
		cMarca 		:= oBrowse:Mark()
		cAliasBrw	:= oBrowse:Alias()
		cCpoMark	:= oBrowse:cFieldMark
		nLinAtu		:= oBrowse:oBrowse:nAt
		
		(cAliasBrw)->(DbGoTop())
	
		While !(cAliasBrw)->(Eof())
			If oBrowse:IsMark(cMarca)
				RecLock(cAliasBrw, .F.)
					(cAliasBrw)->&cCpoMark := Criavar(cCpoMark)
				(cAliasBrw)->(MsUnLock())		
			Else
				RecLock(cAliasBrw, .F.)
					(cAliasBrw)->&cCpoMark  := cMarca
				(cAliasBrw)->(MsUnLock())
			EndIf
			(cAliasBrw)->(DbSkip())
		EndDo
	
		oBrowse:oBrowse:Refresh(.T.)
		oBrowse:GoTo(nLinAtu, .T.)
	EndIf

Return lRet   


//-------------------------------------------------------------------
/*/{Protheus.doc} FWS3FSEL

Monta a tela com os adiantamentos / reembolsos disponíveis no Copastur para seleção

@author  Allan Constantino Bonfim - CM Solutions
@since   25/02/2019
@version P12
@return array, Funções da Rotina

/*/
//-------------------------------------------------------------------   
Static Function FWS3FSEL(nOpc, cEmpOri, cFilOri, cFilPart, cCodPart)

	Local aArea			:= GetArea()
	Local aAreaRD0		:= RD0->(GetArea())
	Local aAreaSE2		:= SE2->(GetArea())
	Local aCBrw			:= {}
	//Local aCpoTmp		:= {"E2_XALATUR"	, "VALBRL"		, "VALUSD"		, "VALEUR"		, "VALTOT"			,  "RD0_CODIGO"	,"RD0_NOME"		, "RD0_CIC"	, "RD0_XLOGIN"	, "RD0_EMAIL"	, "RD0_FORNEC"		, "RD0_LOJA"}
	//Local aCpoTmpDsc	:= {"Cod. Copastur"	, "Valor (R$)"	, "Valor (US$)"	, "Valor (€)"	, "Valor Total R$"	, "Código"		, "Participante", "CPF"		, "Login"		, "E-mail"		, "Cod. Fornecedor"	, "Loja"	}
	Local nX			:= 0
	Local nY			:= 0
	Local aSeek   		:= {}
	Local cQuery 		:= ""
	Local aEstrut		:= {}
	Local cQTmp			:= GetNextAlias()
	Local cATmp			:= GetNextAlias()
	Local oBrwTmp 		:= Nil
	Local cTitMark		:= ""
	Local aRetFin		:= {}
	Local aRetTmp		:= {}
	Local aRetGrid		:= {}
	Local aRetDesp		:= {}
	Local lConfMrkBr	:= .F.
	Local bOk 			:= {|| IIF(FWS3FSOK(oBrwTmp, cATmp), (lConfMrkBr 	:= .T. , CloseBrowse()), NIL)}
	Local bCancel		:= {|| ((lConfMrkBr 	:= .F., CloseBrowse()))}
//	Local nPosCpo		:= 0
	Local nValBrl 		:= 0
	Local nValUsd 		:= 0
	Local nValEur 		:= 0
	Local nTotBrl		:= 0
	Local cPartLogin	:= ""
	
	Default nOpc		:= 1
	Default cEmpOri		:= FwCodEmp()	
	Default cFilOri		:= FwCodFil()
	Default cFilPart	:= ""
	Default cCodPart	:= ""
	

	//Query para montar a estrutura do mark
	cQuery := "SELECT TOP 1 E2_OK, E2_XALATUR, E2_VALOR AS VALBRL, E2_VALOR AS VALUSD, E2_VALOR AS VALEUR, E2_VALOR AS VALTOT, RD0_NOME, RD0_CIC, RD0_CODIGO, RD0_XLOGIN, RD0_EMAIL, RD0_FORNEC, RD0_LOJA "+CHR(13)+CHR(10)
	cQuery += "FROM "+RetSqlName("RD0")+" (NOLOCK), "+RetSqlName("SE2")+" (NOLOCK) "+CHR(13)+CHR(10) 

	If Select(cQTmp) <> 0
		(cQTmp)->(DbCloseArea())
	Endif
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQTmp, .F., .T.)
	
	aEstrut := (cQTmp)->(DBStruct())
	
	//Ajuste do tamanho do campo para demonstração na tela
	For nX := 1 to Len(aEstrut)
		If aEstrut[nX][1] $ "E2_XALATUR"
			aEstrut[nX][3] := nTamAlatur
		EndIf
	Next
	
	If Type("oTempSel") == "O"
		oTempSel:Delete()
	EndIf
		
	oTempSel := FWTemporaryTable():New(cATmp, aEstrut)
	oTempSel:AddIndex("1", {"E2_XALATUR"})
	oTempSel:AddIndex("2", {"RD0_NOME"})
	oTempSel:AddIndex("3", {"RD0_CODIGO"})
	oTempSel:AddIndex("4", {"RD0_CIC"})

	oTempSel:Create()	
	

	If nOpc == 1 //Adiantamento
		aRetTmp := U_FIWS7FAL(cEmpOri, cFilOri, cFilPart, cCodPart, .T., .F.)
	ElseIf nOpc == 2 //Reembolso
		aRetTmp := U_FIWS7FAL(cEmpOri, cFilOri, cFilPart, cCodPart, .F., .T.)
	EndIf 

	If Len(aRetTmp) > 0
		DbSelectArea("RD0")
		DbOrderNickName("RD00000002") //RD0_FILIAL+RD0_XLOGIN

		For nX := 1 to Len(aRetTmp)
			If nOpc == 1 //Adiantamento
				aRetDesp := aRetTmp[nX][3]
				aRateio	 := aRetTmp[nX][5]
			ElseIf nOpc == 2 //Reembolso
				aRetDesp := aRetTmp[nX][4]
				aRateio	 := aRetTmp[nX][5]
			EndIf

			nValBrl := 0
			nValUsd := 0
			nValEur := 0
			nTotBrl	:= 0
			cPartLogin := aRetTmp[nX][2]

			RD0->(Dbseek(FwxFilial("RD0")+Upper(Alltrim(cPartLogin))))
			
			For nY := 1 to Len(aRetDesp)
				If aRetDesp[nY][4] == "USD"
					nValUsd += (Val(aRetDesp[nY][5]) * Val(aRetDesp[nY][6]))
				ElseIf aRetDesp[nY][4] == "EUR"
					nValEur += (Val(aRetDesp[nY][5]) * Val(aRetDesp[nY][6]))
				Else
					nValBrl += (Val(aRetDesp[nY][5]) * Val(aRetDesp[nY][6]))
				EndIF
			Next
			
			If nValUsd + nValEur == 0
				nTotBrl := nValBrl
			EndIf

			AADD(aRetGrid, {"", aRetTmp[nX][1], nValBrl, nValUsd, nValEur, nTotBrl, RD0->RD0_NOME, RD0->RD0_CIC, RD0->RD0_CODIGO, RD0->RD0_XLOGIN, RD0->RD0_EMAIL, RD0->RD0_FORNEC, RD0->RD0_LOJA}) //E2_XALATUR, RD0_NOME, RD0_CIC, RD0_CODIGO, RD0_XLOGIN, RD0_EMAIL, 0 AS VALBRL, 0 AS VALUSD, 0 AS VALEUR
		Next
	EndIf

	If Len(aRetGrid) > 0
		For nY := 1 to Len(aRetGrid)
			RecLock(cATmp, .T.)
				For nX := 1 to Len(aEstrut) //Desconsiderar o campo Ok
				
					If !aEstrut[nX][1] == "E2_OK"
						If aEstrut[nX][2] == "C" 
							(cATmp)->&(aEstrut[nX][1]) := Alltrim(aRetGrid[nY][nX])
						Elseif aEstrut[nX][2] == "N" 
							(cATmp)->&(aEstrut[nX][1]) := aRetGrid[nY][nX]
						Else
							(cATmp)->&(aEstrut[nX][1]) := aRetGrid[nY][nX]
						EndIf
					EndIf		
				Next
			(cATmp)->(MsUnlock())
		Next
	EndIf

	If nOpc == 1 //Adiantamento
		cTitMark := "Adiantamento"
	Else
		cTitMark := "Despesas"
	EndIf 

	aCBrw 	:= FIWS3STR(10, cATmp)

	oBrwTmp:= FWMarkBrowse():New()
	oBrwTmp:SetDescription(cTitMark) //Titulo da Janela
	oBrwTmp:SetAlias(cATmp)
	oBrwTmp:SetFieldMark("E2_OK")
	oBrwTmp:SetColumns(aCBrw)
	oBrwTmp:SetDataTable(.T.)
	oBrwTmp:SetSemaphore(.F.)
	oBrwTmp:SetUseFilter(.T.)
	oBrwTmp:DisableDetails()
	oBrwTmp:SetMenuDef('') 
	oBrwTmp:SetProfileID('1') 
	oBrwTmp:ForceQuitButton()
	oBrwTmp:DisableReport() 
	oBrwTmp:DisableConfig()
	oBrwTmp:SetWalkThru(.F.)
	oBrwTmp:SetAmbiente(.F.)
	oBrwTmp:DisableFilter()
	oBrwTmp:SetCacheView(.F.) 

	aSeek 	:= {	{"Cod. Copastur", {{"","C", nTamAlatur, 0, "E2_XALATUR", "@!"}}},;	
					{"Codigo"		, {{"","C", 06, 0, "RD0_CODIGO", "@!"}}},;
					{"Nome"			, {{"","C", 30, 0, "RD0_NOME", "@!"}}},;
					{"Cpf"			, {{"","C", 11, 0, "RD0_CIC", "@!"}}}}				
	
	oBrwTmp:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
	
	//Adiciona botoes na janela
	oBrwTmp:AddButton("Taxa de câmbio"	, {|| FWS3FCMB(oBrwTmp, cATmp)},,,, .F., 2)
	oBrwTmp:AddButton("Confirmar"		, bOk,,,, .F., 2)
	oBrwTmp:AddButton("Sair"			, bCancel,,,, .F., 2)

	oBrwTmp:Activate()
	oBrwTmp:oBrowse:Setfocus() //Seta o foco na grade
	
	If lConfMrkBr
		//If MsgYesNo("Confirma a integração dos "+ IIf (nOpc == 1, "adiantamentos", "despesas")+" selecionados ?", "FWS3FSEL") 
			DbSelectArea(cATmp)
			(cATmp)->(DbGotop())

			While !(cATmp)->(EOF())
				If oBrwTmp:IsMark()
					If !Empty((cATmp)->VALTOT)
						AADD(aRetFin, {Alltrim((cATmp)->E2_XALATUR), (cATmp)->VALTOT})
					Else
						Help(NIL, NIL, "FWS3FSEL", NIL, "A despesa "+Alltrim((cATmp)->E2_XALATUR)+" não contém a taxa de câmbio da moeda estrangeira.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe a taxa de câmbio e tente novamente."})
						aRetFin := {}
						Exit
					EndiF
				EndIF

				(cATmp)->(DbSKip())
			EndDo
		//EndIf
	ENDIF

	If Type("oTempSel") == "O"
		oTempSel:Delete()
	EndIf
	
	If Select(cQTmp) <> 0
		(cQTmp)->(DbCloseArea())
	Endif

	RestArea(aAreaSE2)
	RestArea(aAreaRD0)
	RestArea(aArea)

Return aRetFin


//-------------------------------------------------------------------
/*/{Protheus.doc} FWS3FCMB

Informa a taxa de conversão dos títulos nas moedas estrangeiras

@author  Allan Constantino Bonfim - CM Solutions
@since   28/02/2019
@version P12
@return array, Funções da Rotina

/*/
//-------------------------------------------------------------------   
Static Function FWS3FCMB(oBrowse, cAliasBrw)

	Local aArea			:= GetArea()
	Local nLinAtu		:= 0
	Local aParambox		:= {}
	Local aRet			:= {}
	Local nTaxUsd		:= 0
	Local nTaxEuro		:= 0

	Default oBrowse		:= NIL
	Default cAliasBrw 	:= ""


	AADD(aParambox ,{1, "Dolar (US$)"	, nTaxUsd	, "@E 99,999.99", "Positivo()", "", ".T.", 50, .F.})
	AADD(aParambox ,{1, "Euro (€)"		, nTaxEuro	, "@E 99,999.99", "Positivo()", "", ".T.", 50, .F.})			

	If ParamBox(aParambox, "Informe a taxa de câmbio",@aRet,,,,,,, "FWS3FCMB", .T., .T.)
		nTaxUsd 	:= aRet[1]
		nTaxEuro	:= aRet[2]

		If Valtype(oBrowse) == "O"
			cAliasBrw	:= oBrowse:Alias()
			nLinAtu		:= oBrowse:oBrowse:nAt
		EndIf

		(cAliasBrw)->(DbGotop())
		
		While !(cAliasBrw)->(Eof())
			If !Empty((cAliasBrw)->E2_OK)

				Reclock(cAliasBrw, .F.)
					(cAliasBrw)->VALTOT := (cAliasBrw)->VALBRL + ((cAliasBrw)->VALUSD * nTaxUsd) + ((cAliasBrw)->VALEUR * nTaxEuro)

					If !Empty((cAliasBrw)->VALUSD) .and. nTaxUsd = 0
						(cAliasBrw)->VALTOT := 0
					EndIf

					If !Empty((cAliasBrw)->VALEUR) .and. nTaxEuro = 0
						(cAliasBrw)->VALTOT := 0
					EndIf

				(cAliasBrw)->(MsUnlock())
			EndIf
			(cAliasBrw)->(DbSkip())
		EndDo

		If Valtype(oBrowse) == "O"
			oBrowse:oBrowse:Refresh(.T.)
			oBrowse:GoTo(nLinAtu, .T.)
		EndIf
	EndIf


	RestArea(aArea)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FWS3FVLD

Validação da tabela de geração de adiantamento e despesas

@author  Allan Constantino Bonfim - CM Solutions
@since   28/02/2019
@version P12
@return array, Funções da Rotina

/*/
//-------------------------------------------------------------------   
Static Function FWS3FVLD(oBrowse, cAliasBrw)

	Local aArea			:= GetArea()
	Local nLinAtu		:= 0
	Local lRet			:= .T.

	Default oBrowse		:= NIL
	Default cAliasBrw 	:= ""

	If Valtype(oBrowse) == "O"
		cAliasBrw	:= oBrowse:Alias()
		nLinAtu		:= oBrowse:oBrowse:nAt
	EndIf

	(cAliasBrw)->(DbGotop())
	
	While !(cAliasBrw)->(Eof())
		If !Empty((cAliasBrw)->E2_OK)
			If Empty((cAliasBrw)->VALTOT)
				Help(NIL, NIL, "FWS3FSEL", NIL, "A despesa "+Alltrim((cAliasBrw)->E2_XALATUR)+" não contém o valor convertido da moeda estrangeira (Valor Total R$).", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe a taxa de câmbio e tente novamente."})
				lRet := .F.
				Exit
			EndiF
		EndIf

		(cAliasBrw)->(DbSkip())
	EndDo

	If Valtype(oBrowse) == "O"
		oBrowse:oBrowse:Refresh(.T.)
		oBrowse:GoTo(nLinAtu, .T.)
	EndIf

	RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FWS3FSOK

Botão Ok da tela de seleção de adiantamentos / despesas

@author  Allan Constantino Bonfim - CM Solutions
@since   28/02/2019
@version P12
@return array, Funções da Rotina

/*/
//-------------------------------------------------------------------   
Static Function FWS3FSOK(oBrowse, cAliasBrw)

	Local lRet			:= .F.
	
	If MsgYesNo("Confirma a integração dos pagamentos selecionados ?", "FWS3FSOK") 
		If FWS3FVLD(oBrowse, cAliasBrw)
			lRet := .T.
		EndIf
	EndIf

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FIWS3RD0

Chamada da rotina de geração da tabela integradora do participante

@author CM Solutions - Allan Constantino Bonfim
@since  02/03/2020
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function FIWS3RD0(_cAlias, _nRecno)

	Local _aArea	:= GetArea()
	Local _cEmpOri	:= FwCodEmp()
	Local _cFilOri	:= FwCodFil()
	Local _lRet		:= .T.
	Local _lOnline	:= GETNEWPAR("ZZ_WSACONL", .T.)

	Default _cAlias	:= ""
	Default _nRecno	:= 0


	If !Empty(_cAlias) .AND. !Empty(_nRecno)
		DbSelectArea("RD0")
		DbGoto(_nRecno)

		If  RD0->RD0_XALATU == "S"
			If  !Empty(RD0->RD0_XLOGIN)
				If !Empty(RD0->RD0_EMAIL)
					If _cEmpOri == RD0->RD0_EMPATU .AND. _cFilOri == RD0->RD0_FILATU
						//FWMsgRun(, {|| _lRet := U_FINWS05I(RD0->RD0_EMPATU, RD0->RD0_FILATU, RD0->RD0_FILIAL, RD0->RD0_CODIGO, "2", "1")}, "Participante...", ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))
						_lRet := U_FIWS3INT(1, .T., _lOnline, .F.,,, RD0->RD0_EMPATU, RD0->RD0_FILATU, RD0->RD0_FILIAL, RD0->RD0_CODIGO, "1", .T.)
						//nOpcao, lConfirm, lOnline, lIntSup, oBrowse, oBrwDet, cEmpOri, cFilOri, cRepFil, cRepChv, cTpProc
						//FWMsgRun(, {|| lRet := U_FINWS03P(RD0->RD0_EMPATU, RD0->RD0_FILATU, "RD0", RD0->RD0_FILIAL, RD0->RD0_CODIGO)}, "Integrando o participante...", ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME))

						If _lRet
							MsgInfo("Partipante "+RD0->RD0_CODIGO + " - "+ ALLTRIM(RD0->RD0_NOME)+" integrado com sucesso.", "FIWS3RD0")
						Else
							MsgInfo("Ocorreu um erro na integração do partipante "+RD0->RD0_CODIGO + " - "+ ALLTRIM(RD0->RD0_NOME)+". Verifique o log da tabela integradora.", "FIWS3RD0")
						EndIf
					Else
						Help(NIL, NIL, "FIWS3RD0", NIL, "O participante "+ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME)+" não pertence a empresa / filial atual. Empresa / filial do participante ("+RD0->RD0_EMPATU+ "/" + RD0->RD0_FILATU+ ")", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Acesse a empresa / filial do participante e tente novamente."})
					EndIf
				Else
					Help(NIL, NIL, "FIWS3RD0", NIL, "O participante "+ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME)+" não possui e-mail cadastrado.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o cadastro do participante e tente novamente."})
				EndIf
			Else
				Help(NIL, NIL, "FIWS3RD0", NIL, "O participante "+ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME)+" não possui login do Copastur cadastrado.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o cadastro do participante e tente novamente."})
			EndIf
		Else
			Help(NIL, NIL, "FIWS3RD0", NIL, "O participante "+ALLTRIM(RD0->RD0_CODIGO) + " - " + ALLTRIM(RD0->RD0_NOME)+" está configurado para não integrar ao Copastur.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o cadastro do participante e tente novamente."})
		EndIf
	EndIf

	RestArea(_aArea)

Return _lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FWS03PSS

Rotina para a troca de senha do participante selecionado

@author  Allan Constantino Bonfim - CM Solutions
@since   23/03/2019
@version P12
@return array, Funções da Rotina

/*/
//-------------------------------------------------------------------   
Static Function FWS03PSS(oBrowse)

	Local lRet			:= .F.
//	Local aArea			:= GetArea()
	Local nLinAtu		:= 0
	Local cUsrPass		:= ALLTRIM(GETNEWPAR("ZZ_FWSPDEF", "@ALATUR0099#"))
	Local cAliasBrw		

	Default oBrowse		:= NIL


	If Valtype(oBrowse) == "O"
		cAliasBrw	:= oBrowse:Alias()
		nLinAtu		:= oBrowse:oBrowse:nAt

		If MsgYesNo("Confirma o reset da senha do participante "+Alltrim((cAliasBrw)->RD0_CODIGO) + " - "+Alltrim((cAliasBrw)->RD0_NOME)+" ?", "FWS03PSS") 

			FWMsgRun(, {|| lRet := U_FIWS3INT(1, .F., .T., .F., oBrowseCad,,,,,,, .T.)}, "Processando...", "Aguarde a integração com o Copastur...")

			If lRet
				MsgInfo("A nova senha do participante é "+ cUsrPass+" . Solicite a alteração da senha para o participante após o acesso ao Copastur.", "FWS03PSS")
				
			Else
				MsgInfo("Falha na integração do participante. Verifique o log da tabela integradora e tente novamente.", "FWS03PSS")
			EndIf

			//FIWS3RE1(.T., .F., .T., .T., .F., .F., .F.)
			oBrowse:GoTo(nLinAtu, .T.)
			oBrowse:OnChange()		
		EndIf
	EndIf

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FIWS3RP1

Copastur - Reprocessamento da tabela integradora do cadastro de Centro de Custos

@author CM Solutions - Allan Constantino Bonfim
@since  26/11/2019
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
Static FUNCTION FIWS3RP1(oBrowse)
	
	Local aArea 		:= GetArea()
	Local aAreaZWQ		:= ZWQ->(GetArea())
	Local lRet			:= .T.
	Local lRefresh 		:= .F.
	Local cAliasBrw		:= ""
//	Local nOpcao		:= 0
	Local aAreaBrw		

	If Valtype(oBrowse) == "O"
		cAliasBrw	:= oBrowse:Alias()
		aAreaBrw 	:= (cAliasBrw)->(GetArea())
		nLinAtu		:= oBrowse:nAt

		DbSelectArea("ZWQ")
		ZWQ->(DbSetOrder(1))
		ZWQ->(DbSeek((cAliasBrw)->ZWQ_FILIAL+(cAliasBrw)->ZWQ_CODIGO))

		lRet := U_FWS2REPR(ZWQ->ZWQ_FILIAL, ZWQ->ZWQ_CODIGO, .T.)

		If lRet
			lRefresh := .T.
		EndIf

		RestArea(aAreaBrw)

		If lRefresh
			FIWS3REF(.T., .F.)
			oBrowse:GoTo(nLinAtu, .T.)
			oBrowse:OnChange()		
		EndIf
	EndIf

	RestArea(aAreaZWQ)
	RestArea(aArea)

Return lRet
