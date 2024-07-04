#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWBROWSE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FINWS002

Tabela de integração Protheus x Copastur

@author  CM Solutions - Allan Constantino Bonfim
@since   16/10/2019
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
User Function FINWS002()

	Local aArea		:= GetArea()
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZWQ")
	oBrowse:SetDescription("Integrações")
	oBrowse:DisableDetails()
	
	oBrowse:AddLegend("ZWQ_STATUS = '01'"	, "BR_AMARELO"	, "Integração pendente")
	oBrowse:AddLegend("ZWQ_STATUS = '02'"	, "BR_VERMELHO"	, "Integração com erro")
	oBrowse:AddLegend("ZWQ_STATUS = '05'"	, "BR_VERDE"	, "Integração concluída")
	oBrowse:DisableDetails()
	oBrowse:Activate()
	
	RestArea(aArea)

Return         


//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF

MenuDef - Padrão MVC

@author  CM Solutions - Allan Constantino Bonfim
@since   16/10/2019
@version P12
@return array, Funções da Rotina

/*/
//-------------------------------------------------------------------   
Static Function MENUDEF()

	Local aRotina 	:= {} 
	
	ADD OPTION aRotina TITLE "Pesquisar"	ACTION "PesqBrw"          	OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.FINWS002"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Reprocessar"	ACTION "U_FWS2REPR()"	 	OPERATION 4 ACCESS 0 
	ADD OPTION aRotina TITLE "Incluir"		ACTION "VIEWDEF.FINWS002" 	OPERATION 3 ACCESS 0 
	ADD OPTION aRotina TITLE "Alterar"		ACTION "VIEWDEF.FINWS002" 	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"		ACTION "VIEWDEF.FINWS002" 	OPERATION 5 ACCESS 0
					
Return aRotina     


//-------------------------------------------------------------------
/*/{Protheus.doc} MODELDEF

ModelDef - Padrão MVC

@author  CM Solutions - Allan Constantino Bonfim
@since   16/10/2019
@version P12
@return objeto, Objeto do Model

/*/
//-------------------------------------------------------------------   
STATIC FUNCTION MODELDEF()

	Local oStruct1
	Local oModel
	
	//oModel	:= MPFormModel():New("FIWS2MOD",, /*{|oModel| WWI4VLD(oModel)}*/, {|oModel| FINWS02G(oModel)})
	oModel	:= MPFormModel():New("FIWS2MOD",,, {|oModel| FINWS02G(oModel)})
	oStruct1	:= FWFormStruct(1, "ZWQ")
	
	//Estrutura Model
	oModel:AddFields("ZWQ_ALATUR",,oStruct1)
	
	oModel:SetPrimaryKey({})

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} VIEWDEF

ViewDef - Padrão MVC

@author  CM Solutions - Allan Constantino Bonfim
@since   16/10/2019
@version P12
@return objeto, Objeto da View

/*/
//-------------------------------------------------------------------   
STATIC FUNCTION VIEWDEF()

	Local oStruct1
	Local oModel
	Local oView
	
	oModel		:= FWLoadModel("FINWS002") //Chamada do model utilizando o nome do fonte (PRW)
	oStruct1	:= FWFormStruct(2, "ZWQ")
	oView    	:= FWFormView():New() //View da MVC
	
	oView:SetModel(oModel)
	
	//Estrutura View
	oView:AddField("VIEW_ZWQ", oStruct1, "ZWQ_ALATUR")
	
	//Formatação da Tela
	oView:CreateHorizontalBox("BOXZWQ"	,100) //Uma barra horizontal com proporção de 35% da tela.
	oView:SetOwnerView("VIEW_ZWQ", "BOXZWQ")
	oView:SetCloseOnOk({|| .T.})

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} FWS2REPR

Rotina para o reprocessamento da integração

@author  CM Solutions - Allan Constantino Bonfim
@since   27/11/2019
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
User Function FWS2REPR(cFilZWQ, cCodZWQ, lOk)

	Local aArea		:= GetArea()
	Local aZWQDados	:= {}
	Local lRet		:= .T.
	Local lReproc	:= .T.	
	
	Default cFilZWQ	:= ZWQ->ZWQ_FILIAL
	Default cCodZWQ	:= ZWQ->ZWQ_CODIGO
	Default lOk		:= .T.
	
	DbSelectArea("ZWQ")
	DbSetOrder(1) //ZWQ_FILIAL+ZWQ_CODIGO
	
	If ZWQ->(DbSeek(cFilZWQ+cCodZWQ))	
		If ZWQ->ZWQ_STATUS == "02"
		
			If lOk
				lReproc := MsgYesNo ("Confirma o reprocessamento da integração "+ALLTRIM(ZWQ->ZWQ_CODIGO)+" ?", "FINWS002")
			EndIf
			
			If lReproc		
				AADD(aZWQDados, {"ZWQ_FILIAL"	, ZWQ->ZWQ_FILIAL, Nil})
				AADD(aZWQDados, {"ZWQ_CODIGO"	, ZWQ->ZWQ_CODIGO, Nil})
				AADD(aZWQDados, {"ZWQ_FILORI"	, ZWQ->ZWQ_FILORI, Nil})
				AADD(aZWQDados, {"ZWQ_CALIAS"	, ZWQ->ZWQ_CALIAS, Nil})
				AADD(aZWQDados, {"ZWQ_STATUS"	, "01", Nil})
				AADD(aZWQDados, {"ZWQ_DTINTE"	, CTOD(""), Nil})
				AADD(aZWQDados, {"ZWQ_HRINTE"	, "", Nil})
				AADD(aZWQDados, {"ZWQ_USINTE"	, "", Nil})
				AADD(aZWQDados, {"ZWQ_DTREPR"	, dDatabase, Nil})
				AADD(aZWQDados, {"ZWQ_HRREPR"	, Time(), Nil})
				AADD(aZWQDados, {"ZWQ_USREPR"	, cUserName, Nil})				
				AADD(aZWQDados, {"ZWQ_WSREQ"	, "", Nil})
				AADD(aZWQDados, {"ZWQ_WSRET"	, "", Nil})
				AADD(aZWQDados, {"ZWQ_OBSERV"	, "", Nil})
				AADD(aZWQDados, {"ZWQ_ERRO"		, "", Nil})	
				
				lRet := U_FINWS2GR(4, aZWQDados)
				
				If !lRet
					MsgStop("Ocorreu um erro no reprocessamento da integração.", "FINWS002")
				EndIf			 					
			EndIf
		Else
			MsgInfo("Operação não permitida para o status atual.", "FINWS002")
		EndIf
	EndIf
			
	RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FINWS02G

Gravação customizada do Model

@author  CM Solutions - Allan Constantino Bonfim
@since   07/04/2020
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
STATIC FUNCTION FINWS02G(oModelAtu)

	Local aArea		:= GetArea()
	Local aAreaZWQ	:= ZWQ->(GetArea())
	Local lRet		:= .T. 
	Local nOper		:= oModelAtu:GetOperation()   
	Local oModel	:= oModelAtu:GetModel("ZWQ_ALATUR")
	Local cCodZWQ	:= ""
	Local lGrava	:= .F.

	If nOper == 3	
		cCodZWQ := U_FWS02NUM() //oModel:GetValue("ZWP_CODIGO")

		DbSelectArea("ZWQ")
		ZWQ->(DbSetOrder(1)) //ZWP_FILIAL, ZWP_CODIGO
					
		While !lGrava
			If ZWQ->(DbSeek(oModel:GetValue("ZWQ_FILIAL")+cCodZWQ))
				cCodZWQ := U_FWS02NUM()
			Else
				lGrava := .T.
				
				oModel:SetValue("ZWQ_CODIGO", cCodZWQ)
			EndIf
		EndDo	
	EndIf

	lRet := FWFormCommit(oModelAtu)

	RestArea(aAreaZWQ)
	RestArea(aArea)
  
Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINWS2GR

Rotina para gravação do processamento do webservice

@author CM Solutions - Allan Constantino Bonfim
@since  26/11/2019
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
USER FUNCTION FINWS2GR(nOper, aDados, cZWQCODIGO, cZWQEMPORI, cZWQFILORI, cZWQCALIAS, nZWQINDICE, cZWQFILALI, cZWQCHAVE, nZWQRECORI, cZWQSTATUS, cZWQTPINCL, cZWQTINTEG, cZWQTPPROC, cZWQWSREQ, cZWQWSRET, cZWQERRO, cZWQOBSERV, cZWQLOGIN, cZWQEMAIL, cZWQCodAla, nZWQValAla)

	Local aArea			:= GetArea()
	Local lRet			:= .T.
	Local cModel		:= "FINWS002"
	Local cIdMdlId		:= "ZWQ_ALATUR"
	Local cLog			:= ""
	Local aTmpLog 		:= {}
	Local nX			:= 0
	Local cAliasOk		:= ""
	Local nPoscAlias 	:= 0
	Local nPosStatus 	:= 0
	Local nPosRecOri 	:= 0
	Local nRecOk		:= 0
	Local cStatOk		:= ""
	Local nTamErro		:= TAMSX3("ZWQ_ERRO")[1]

	Private oModel		:= NIL
	Private lMsErroAuto	:= .F.
	Private aRotina		:= MENUDEF()
	
	Default aDados		:= {}
	Default nOper 		:= 1
	Default cZWQCODIGO	:= ""
	Default cZWQEMPORI	:= ""
	Default cZWQFILORI	:= ""
	Default cZWQCALIAS	:= ""
	Default nZWQINDICE	:= 0
	Default cZWQFILALI	:= ""
	Default cZWQCHAVE	:= ""
	Default nZWQRECORI	:= 0
	Default cZWQSTATUS	:= ""
	Default cZWQTPINCL	:= ""
	Default cZWQTINTEG	:= ""
	Default cZWQTPPROC	:= ""
	Default cZWQWSREQ	:= ""
	Default cZWQWSRET	:= ""
	Default cZWQERRO	:= ""
	Default cZWQOBSERV	:= ""
	Default cZWQLOGIN	:= ""
	Default cZWQEMAIL	:= ""
	Default cZWQCodAla	:= ""
	Default nZWQValAla	:= 0


	If EMPTY(aDados)
		AADD(aDados, {"ZWQ_FILIAL"	, FwxFilial("ZWQ"), Nil})
		
		If nOper <> 3 
			AADD(aDados, {"ZWQ_CODIGO"	, cZWQCODIGO, Nil})
		EndIf
		AADD(aDados, {"ZWQ_CALIAS"	, cZWQCALIAS, Nil})
		AADD(aDados, {"ZWQ_INDICE"	, nZWQINDICE, Nil})
		AADD(aDados, {"ZWQ_FILALI"	, cZWQFILALI, Nil})
		AADD(aDados, {"ZWQ_CHAVE"	, cZWQCHAVE, Nil})
		AADD(aDados, {"ZWQ_RECORI"	, nZWQRECORI, Nil})
		AADD(aDados, {"ZWQ_EMPORI"	, cZWQEMPORI, Nil})
		AADD(aDados, {"ZWQ_FILORI"	, cZWQFILORI, Nil})
		AADD(aDados, {"ZWQ_STATUS"	, cZWQSTATUS, Nil}) 
		AADD(aDados, {"ZWQ_TPINCL"	, cZWQTPINCL, Nil}) //1=Automatica;2=Manual                                                                                                           
		AADD(aDados, {"ZWQ_TINTEG"	, cZWQTINTEG, Nil})	//1=Inclusao;2=Alteracao;3=Exclusao;4=Consulta		
		AADD(aDados, {"ZWQ_TPPROC"	, cZWQTPPROC, Nil}) //1=Participante;2=Aprovador;3=Centro Custo;4=Adiantamento;5=Despesas
		AADD(aDados, {"ZWQ_WSREQ"	, cZWQWSREQ, Nil})
	   	AADD(aDados, {"ZWQ_WSRET"	, cZWQWSRET, Nil})
		AADD(aDados, {"ZWQ_ERRO"	, Substr(cZWQERRO, 1, nTamErro), Nil})	
		AADD(aDados, {"ZWQ_OBSERV"	, cZWQOBSERV, Nil})
		
		If !Empty(cZWQLOGIN)
			AADD(aDados, {"ZWQ_LOGIN"	, cZWQLOGIN, Nil})
		EndIf
		
		If !Empty(cZWQEMAIL)
			AADD(aDados, {"ZWQ_EMAIL"	, cZWQEMAIL, Nil})	
		EndIf

		If !Empty(cZWQCodAla)
			AADD(aDados, {"ZWQ_CODALA"	, cZWQCodAla, Nil})	
		EndIf

		If !Empty(nZWQValAla)
			AADD(aDados, {"ZWQ_VALALA"	, nZWQValAla, Nil})	
		EndIf

		If nOper == 3
			AADD(aDados, {"ZWQ_USUARI"	, cUserName, Nil})
			AADD(aDados, {"ZWQ_DATA"	, dDatabase, Nil})
			AADD(aDados, {"ZWQ_HORA"	, TIME(), Nil}) 
		ElseIf nOper == 4	
			/*If cZWQSTATUS == "01"
				AADD(aDados, {"ZWQ_USINTE"	, cUserName, Nil})
				AADD(aDados, {"ZWQ_DTINTE"	, dDatabase, Nil})
				AADD(aDados, {"ZWQ_HRINTE"	, TIME(), Nil}) 
				AADD(aDados, {"ZWQ_DTREPR"	, cUserName, Nil})
				AADD(aDados, {"ZWQ_HRREPR"	, dDatabase, Nil})
				AADD(aDados, {"ZWQ_USREPR"	, TIME(), Nil})
			EndIf */ 
		EndIf		
		
		If cZWQSTATUS == "05"
			AADD(aDados, {"ZWQ_USINTE"	, cUserName, Nil})
			AADD(aDados, {"ZWQ_DTINTE"	, dDatabase, Nil})
			AADD(aDados, {"ZWQ_HRINTE"	, TIME(), Nil}) 
		EndIf
		
	EndIf	

	lRet := Len(aDados) > 0
	
	If lRet	
		DbSelectArea("ZWQ")
		DbSetOrder(1)
		
		oModelZWQ 	:= FWLoadModel(cModel)
		
		FWMVCRotAuto(oModelZWQ, "ZWQ", nOper, {{cIdMdlId, aDados}}, .T.) //Model //Alias //Operacao //Dados
	
	    //Se houve erro no ExecAuto, mostra mensagem
	    If lMsErroAuto     	
	     	// A estrutura do vetor com erro é:
			// [1] identificador (ID) do formulário de origem
			// [2] identificador (ID) do campo de origem
			// [3] identificador (ID) do formulário de erro
			// [4] identificador (ID) do campo de erro
			// [5] identificador (ID) do erro
			// [6] mensagem do erro
			// [7] mensagem da solução
			// [8] Valor atribuído
			// [9] Valor anterior
	     	
	     	aTmpLog := oModelZWQ:GetErrorMessage()
	     	//ConOut("WWIS0002 - Erro: "+AllToChar(aLog[6]+" "+AllToChar(aLog[4]+Dtoc(DATE())+" - "+Time())))   
	     	
	     	For nX := 1 to Len(aTmpLog)
				If !Empty(aTmpLog[nX])
					cLog += Alltrim(aTmpLog[nX]) + " " + CRLF
				EndIf
			Next
			
			MOSTRAERRO()
	   EndIf

		//Atualiza o status da integração na tabela origem
		nPoscAlias 	:= ASCAN(aDados, {|x| x[1] == "ZWQ_CALIAS"})
		nPosStatus 	:= ASCAN(aDados, {|x| x[1] == "ZWQ_STATUS"})
		nPosRecOri 	:= ASCAN(aDados, {|x| x[1] == "ZWQ_RECORI"})

		If !Empty(nPoscAlias) .And. !Empty(nPosStatus) .And. !Empty(nPosRecOri)
			cAliasOk 	:= aDados[nPoscAlias][2]
			nRecOk		:= aDados[nPosRecOri][2]
			cStatOk		:= aDados[nPosStatus][2]

			DbSelectArea(cAliasOk)
			DbGoto(nRecOk)

			Reclock(cAliasOk, .F.)
				If cStatOk = "05"
					(cAliasOk)->&(cAliasOk+"_XALSTA") := "3" //Integrado
				Else
					(cAliasOk)->&(cAliasOk+"_XALSTA") := "2" //Pendente Integracao
				EndIf			
			(cAliasOk)->(MsUnlock())
		ENDIF

		oModelZWQ:Deactivate()
		oModelZWQ:Destroy()	
		FreeObj(oModelZWQ)
		oModelZWQ 	:= NIL
		aSize(aDados,0)
		aDados	:= NIL			
	 EndIf
	 
	RestArea(aArea)

Return lRet	


//-------------------------------------------------------------------
/*/{Protheus.doc} FWS02EXC

Rotina para a exclusão da integração

@author  CM Solutions - Allan Constantino Bonfim
@since   27/11/2019
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
User Function FWS02EXC(cFilZWQ, cCodZWQ, lOk)

	Local aArea		:= GetArea()
	Local aZWQDados	:= {}
	Local lRet		:= .T.
	Local lExclui	:= .T.	
	Local cAliasOk 	:= ""
	Local nRecOk	:= 0
	
	Default cFilZWQ	:= ZWQ->ZWQ_FILIAL
	Default cCodZWQ	:= ZWQ->ZWQ_CODIGO
	Default lOk		:= .T.
	
	DbSelectArea("ZWQ")
	DbSetOrder(1) //ZWQ_FILIAL+ZWQ_CODIGO
	
	If ZWQ->(DbSeek(cFilZWQ+cCodZWQ))	
		If ZWQ->ZWQ_STATUS == "01" .OR. ZWQ->ZWQ_STATUS == "02"
		
			If lOk
				lExclui := MsgYesNo ("Confirma a exclusão da integração "+ALLTRIM(ZWQ->ZWQ_CODIGO)+" ?", "FINWS002")
			EndIf
			
			If lExclui	
				cAliasOk 	:= ZWQ->ZWQ_CALIAS
				nRecOk		:= ZWQ->ZWQ_RECORI

				AADD(aZWQDados, {"ZWQ_FILIAL"	, ZWQ->ZWQ_FILIAL, Nil})
				AADD(aZWQDados, {"ZWQ_CODIGO"	, ZWQ->ZWQ_CODIGO, Nil})
				
				lRet := U_FINWS2GR(5, aZWQDados)
				
				If lRet
					If nRecOk > 0
						DbSelectArea(cAliasOk)
						DbGoto(nRecOk)

						Reclock(cAliasOk, .F.)
							(cAliasOk)->&(cAliasOk+"_XALSTA") := "1" //Não Integrado
						(cAliasOk)->(MsUnlock())
					EndIf
				Else
					MsgStop("Ocorreu um erro na exclusão da integração.", "FINWS002")
				EndIf			 					
			EndIf
		Else
			MsgInfo("Operação não permitida para o status atual.", "FINWS002")
		EndIf
	EndIf
			
	RestArea(aArea)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FINWSTAT

Função para verificar se existe tabela integradora para determinado status 

@author  CM Solutions - Allan Constantino Bonfim
@since   08/12/2019
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
User Function FINWSTAT(_cAliasZWQ, _cEmpOri, _cFilOri, _cFilZWQ, _cChaveZWQ, _cStatus, _cCodZWQ, _cTpInteg, _cTpProc, _lPosiciona)

	Local _aArea		:= GetArea()
	Local _cQuery 		:= ""
	Local _cQryZWQ		:= GetNextAlias()
	Local _lRet			:= .F.
	
	Default _cEmpOri	:= ""
	Default _cFilOri	:= ""
	Default _cFilZWQ	:= ""
	Default _cCodZWQ	:= ""
	Default _cAliasZWQ	:= ""
	Default _cChaveZWQ	:= ""
	Default _cStatus	:= ""
	Default _cTpInteg	:= ""
	Default _cTpProc	:= ""
	Default _lPosiciona	:= .F.
	
	If !Empty(_cAliasZWQ) .AND. !Empty(_cChaveZWQ) .AND. !Empty(_cStatus)
	
		_cQuery := "SELECT ZWQ_FILIAL, ZWQ_CODIGO, ZWQ_CALIAS, ZWQ_CHAVE, ZWQ_STATUS, ZWQ_TINTEG,  ZWQ_TPPROC, R_E_C_N_O_ AS ZWQREQ "+CHR(13)+CHR(10)	 
		_cQuery += "FROM "+RetSqlName("ZWQ")+" ZWQ (NOLOCK) "+CHR(13)+CHR(10)
		_cQuery += "WHERE ZWQ.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		_cQuery += "AND ZWQ_FILIAL = '"+FwxFilial("ZWQ")+"' "+CHR(13)+CHR(10)
		_cQuery += "AND ZWQ_CALIAS = '"+_cAliasZWQ+"' "+CHR(13)+CHR(10)
		_cQuery += "AND ZWQ_FILALI = '"+_cFilZWQ+"' "+CHR(13)+CHR(10)
		_cQuery += "AND ZWQ_CHAVE = '"+_cChaveZWQ+"' "+CHR(13)+CHR(10)
		_cQuery += "AND ZWQ_STATUS = '"+_cStatus+"' "+CHR(13)+CHR(10)

		If !Empty(_cEmpOri) 
			_cQuery += "AND ZWQ_EMPORI = '"+_cEmpOri+"' "+CHR(13)+CHR(10)
		EndIf
		
		If !Empty(_cFilOri) 
			_cQuery += "AND ZWQ_FILORI = '"+_cFilOri+"' "+CHR(13)+CHR(10)
		EndIf

		If !Empty(_cCodZWQ) 
			_cQuery += "AND ZWQ_CODIGO <> '"+_cCodZWQ+"' "+CHR(13)+CHR(10)
		EndIf

		If !Empty(_cTpInteg) 
			_cQuery += "AND ZWQ_TINTEG = '"+_cTpInteg+"' "+CHR(13)+CHR(10)
		EndIf

		If !Empty(_cTpProc) 
			_cQuery += "AND ZWQ_TPPROC = '"+_cTpProc+"' "+CHR(13)+CHR(10)
		EndIf

		_cQuery += "ORDER BY ZWQ_FILIAL, ZWQ_CHAVE, ZWQ_STATUS  "+CHR(13)+CHR(10)
		
		DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), _cQryZWQ, .F., .T.)
		
		If Select(_cQryZWQ) > 0 .AND. !(_cQryZWQ)->(EOF())
			_lRet := .T.
			
			If _lPosiciona
				DbSelectArea("ZWQ")
				ZWQ->(DbGoto((_cQryZWQ)->ZWQREQ))
			EndIf
		EndIf
	EndIf
	
	If Select(_cQryZWQ) <> 0
		(_cQryZWQ)->(DbCloseArea())
	Endif	
		
	RestArea(_aArea)
	
Return _lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FINWSESP

Função para Retirar caracteres especiais 

@author  CM Solutions - Allan Constantino Bonfim
@since   16/10/2019
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
User Function FINWSESP(cConteudo)

	//Local aArea		:= GetArea()
	//Local nTamOrig	:= Len(cConteudo)
	
	Default cConteudo	:= ""   	 
   	 
	//Retirando caracteres	
	cConteudo := StrTran(cConteudo, "#", " ")
	cConteudo := StrTran(cConteudo, "%", " ")
	cConteudo := StrTran(cConteudo, "*", " ")
	cConteudo := StrTran(cConteudo, "&", "e")
	cConteudo := StrTran(cConteudo, ">", " ")
	cConteudo := StrTran(cConteudo, "<", " ")
	cConteudo := StrTran(cConteudo, "!", " ")
	cConteudo := StrTran(cConteudo, "@", " ")
	cConteudo := StrTran(cConteudo, "$", " ")
	cConteudo := StrTran(cConteudo, "(", " ")
	cConteudo := StrTran(cConteudo, ")", " ")
	cConteudo := StrTran(cConteudo, "_", " ")
	cConteudo := StrTran(cConteudo, "=", " ")
	cConteudo := StrTran(cConteudo, "+", " ")
	cConteudo := StrTran(cConteudo, "{", " ")
	cConteudo := StrTran(cConteudo, "}", " ")
	cConteudo := StrTran(cConteudo, "[", " ")
	cConteudo := StrTran(cConteudo, "]", " ")
	//cConteudo := StrTran(cConteudo, "/", " ")
	cConteudo := StrTran(cConteudo, "?", " ")	
	//cConteudo := StrTran(cConteudo, "\", " ")
	cConteudo := StrTran(cConteudo, "|", " ")
	cConteudo := StrTran(cConteudo, ":", " ")
	cConteudo := StrTran(cConteudo, ";", " ")	
	cConteudo := StrTran(cConteudo, "°", " ")
	cConteudo := StrTran(cConteudo, "ª", " ")
	//cConteudo := StrTran(cConteudo, "-", " ")
	cConteudo := StrTran(cConteudo, "–", " ")
	cConteudo := StrTran(cConteudo, "  ", " ")
	cConteudo := StrTran(cConteudo, "º", "")
	cConteudo := StrTran(cConteudo,CHR(10) ," ") 
	//cConteudo := StrTran(cConteudo, '"', ' ')
	//cConteudo := StrTran(cConteudo, ".", "")	
	//cConteudo := StrTran(cConteudo, "'", " ")
	
	//Adicionando os espaços a direita
	cConteudo := Alltrim(cConteudo)
	cConteudo := FwNoAccent(cConteudo)
	cConteudo := FwCutOff(cConteudo, .T.)
	//cConteudo += Space(nTamOrig - Len(cConteudo))
          
	//RestArea(aArea)

Return cConteudo


//-------------------------------------------------------------------
/*/{Protheus.doc} FWS02NUM

Rotina para o controle da numeração customizada

@author  CM Solutions - Allan Constantino Bonfim
@since   07/04/2020
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
USER FUNCTION FWS02NUM(lSomaNum)

	Local cQuery		:= ""
	Local cNxtNum		:= ""
	Local aArea			:= GetArea()
	Local cNextTmp		:= GetNextAlias()
	Local nTamCpo		:= TAMSX3("ZWQ_CODIGO")[1]

	Default lSomaNum	:= .T.
	
	
	cQuery := "SELECT MAX(ZWQ_CODIGO) AS NEXTNUM "+CHR(13)+CHR(10)
	cQuery += "FROM "+RetSqlName("ZWQ")+" ZWQ "+CHR(13)+CHR(10) 	 	
	
    cQuery := ChangeQuery(cQuery)
    
    dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cNextTmp)
      
    //Se não tiver em branco
    If !(cNextTmp)->(EOF())
    	If !EMPTY((cNextTmp)->NEXTNUM)
        	cNxtNum := PADL(ALLTRIM((cNextTmp)->NEXTNUM), nTamCpo, "0")
        EndIf
    EndIf
    
    If Empty(cNxtNum)
    	cNxtNum := GETSX8NUM("ZWQ","ZWQ_CODIGO")
    Else
	   	If lSomaNum  		
			cNxtNum := SOMA1(cNxtNum, nTamCpo)  
	   EndIf    
    EndIf
   
	If Select(cNextTmp) > 0      
   		(cNextTmp)->(DbCloseArea())
   	EndIf

	RestArea(aArea)
	
Return cNxtNum
