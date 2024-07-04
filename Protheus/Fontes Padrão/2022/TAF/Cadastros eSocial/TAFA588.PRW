#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TAFA588.CH"

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAFA588
Funcao generica MVC do model - S-2231 Cessão/Exercício em Outro Órgão
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TAFA588()

	Private oBrw := FwMBrowse():New()
	Private l2405 := .F.

	If TafAtualizado( .T. ,'TAFA588' )

		oBrw:SetDescription( STR0016 ) //"Cadastro de Beneficiário"
		oBrw:SetAlias( "V73" )
		oBrw:SetMenuDef( "TAFA588" )
		oBrw:SetFilterDefault( "V73_ATIVO == '1' .AND. V73_NOMEVE == 'S2400'" )
		TafLegend(2,"V73",@oBrw)

		oBrw:Activate()
	EndIf
    
Return

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Static Function MenuDef()

	Local aFuncao 		:= {}
	Local aRotina 		:= {}
	Local aRotExcl		:= {}
	Local cFunName		:= FunName()
	Local lAltFunName	:= .F.

	// Como a MenuDef é chamada em rotinas de FrameWork e o TAF "customiza" ela, força o nome do menu chamador, para que o comportamento seja idêntico em ambas chamadas.
	If !FWIsInCallStack( "TAFA588" )
		lAltFunName := .T.
		SetFunName( "TAFA588" )
	EndIf

	//Indica se o menu tera todas as opções de cadastro ou apenas a visualização
	lMenuDIf := Iif( Type( "lMenuDIf" ) == "U", .F., lMenuDIf )

	Aadd( aFuncao, { "" , "TAF588XMLVLD(1)"			, "1" } )
	Aadd( aFuncao, { "" , "loadChangeHistory" 	, "3" } )
	Aadd( aFuncao, { "" , "XmlLote588" 					, "5" } )
	Aadd( aFuncao, { "" , "xFunAltRec( 'V73' )" , "10" } )

	If (!lMenuDIf .And. cModulo <> "CFG") .Or. cModulo == "CFG"
		aRotina	:=	xFunMnuTAF( "TAFA588" , , aFuncao )
	EndIf

	If (lMenuDIf .And. cModulo <> "CFG" .And. IsInCallStack("loadChangeHistory")) .Or. cModulo == "CFG"

		If cModulo != "CFG"
			ADD OPTION aRotina Title STR0017 Action 'loadViewBen' OPERATION 2 ACCESS 0 //"Visualizar"
		EndIf

		ADD OPTION aRotina Title STR0018 	Action "TAF588AltExt('A')" 	OPERATION 3 ACCESS 0 //"Inclusão Extp."
		ADD OPTION aRotina Title STR0019 	Action "TAF588AltExt('R')" 	OPERATION 4 ACCESS 0 //"Retificação Extp."
		ADD OPTION aRotina Title STR0020 	Action "" 									OPERATION 5 ACCESS 0 // "Excluir Extp."
		ADD OPTION aRotina Title STR0021	Action 'xFunAltRec() 	'			OPERATION 3 ACCESS 0 //"Ajuste de Recibo"

		//Grupo de opções para exclusão
		Aadd(aRotExcl,{STR0022	, "TAF588ExcExt('E','1')"	, 0, 3, 0, Nil, Nil, Nil} ) // "Excluir Registro"
		Aadd(aRotExcl,{STR0023	, "TAF588ExcExt('E','2')"	, 0, 5, 0, Nil, Nil, Nil} ) // "Desfazer Exclusão"
		Aadd(aRotExcl,{STR0024	, "TAF588ExcExt('E','3')"	, 0, 2, 0, Nil, Nil, Nil} ) // "Visualizar Registro de Exclusão"

		aRotina[4][2] := aRotExcl
	EndIf

	// Restaura o valor inicial do FunName() caso tenha sido alterada
	If lAltFunName
		SetFunName(cFunName)
	EndIf

Return( aRotina )

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Static Function ModelDef()

Return ( Nil )

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Static Function ViewDef()

Return ( Nil )

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF588Inc
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TAF588Inc()

	FWMsgRun(,{||FWExecView(STR0025, "TAFA589", 3,,{||.T.} )},,STR0026) //"Executando Rotina do Cadastro de Beneficiário... "

Return

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF588Alt
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TAF588Alt()

	Local cStaV73		:= V73->V73_STATUS
	Local cVerAntV73	:= V73->V73_VERANT
	Local aOpcoes		:= {} 
	Local cMsgErr		:= ""
	Local lOption		:= .F.
	Local lAltS2400		:= .F.
	Local nOption 		:= 0
				
	If cStaV73 == '2'
		cMsgErr := STR0001 //"Registro não pode ser alterado, pois encontra-se em processo de transmissão."

	ElseIf cStaV73 == '6'
		cMsgErr := STR0002 //"Registro não pode ser alterado. Aguardando processo de transmissão do evento de Exclusão S-3000."

	ElseIf cStaV73 == '7'
		cMsgErr := STR0003 //"Registro não pode ser alterado, pois o evento de exclusão encontra-se na base do RET."

	ElseIf cStaV73 $ ' 3' .And. Empty(cVerAntV73)
		lAltS2400 := .T.

	ElseIf cStaV73 == '4' .Or. !Empty(cVerAntV73)
		aAdd(aOpcoes, STR0004) // "S-2400 Retificar Cadastro de Beneficiário - Início"
		aAdd(aOpcoes, STR0005) // "S-2405 Incluir Cadastro de Beneficiário - Alteração"
		lOption := .T.

		If ExistS2405(.F.,V73->V73_FILIAL, V73->V73_ID,.F.)
			aAdd(aOpcoes, STR0006) //"S-2405 Alterar Cadastro de Beneficiário - Alteração"
		EndIf

		If ExistS2405(.T.,V73->V73_FILIAL,V73->V73_ID,.T.) //carrega infor do ultimo 2405 transmitido para retificação do 2400
			aAdd(aOpcoes, STR0007) //"S-2405 Retificar Cadastro de Beneficiário - Alteração"
		EndIf
	EndIf

	If lOption
		nOption := TAF588Options(aOpcoes)

		If nOption == 1 // 1 - "S-2400 Retificar Cadastro de Beneficiário - Início"
			INCLUI := .T.
			ALTERA := .F.

			FWMsgRun(,{||TAF588Carr(STR0027,"TAFA589",MODEL_OPERATION_UPDATE,nOption)},,STR0026) //"Alteração do Cadastro de Beneficiário - Início"

		ElseIf nOption == 2 // 2 - "S-2405 Incluir Cadastro de Beneficiário - Alteração"
			INCLUI := .T.
			ALTERA := .F.

			FWMsgRun(,{||TAF588Carr(STR0028,"TAFA590",MODEL_OPERATION_INSERT,nOption)},,STR0026)//"Inclusão do Cadastro de Beneficiário - Alteração"

		ElseIf nOption == 3 // 3 - "S-2405 Alterar Cadastro de Beneficiário - Alteração"
			INCLUI := .F.
			ALTERA := .T.

			ExistS2405(.F.,V73->V73_FILIAL,V73->V73_ID,.T.)

			FWMsgRun(,{||nExView:=FWExecView(STR0029,"TAFA590",MODEL_OPERATION_UPDATE,,{||.T.} )},,STR0026) //"Alteração do Cadastro de Beneficiário - Alteração"

		ElseIf nOption == 4 // 4 - "S-2405 Retificar Cadastro de Beneficiário - Alteração"
			INCLUI := .T.
			ALTERA := .F.

			ExistS2405(.T.,V73->V73_FILIAL,V73->V73_ID,.T.)

			FWMsgRun(,{||TAF588Carr(STR0029,"TAFA590",MODEL_OPERATION_UPDATE,nOption)},,STR0026) //"Alteração do Cadastro de Beneficiário - Alteração"
		EndIf

	ElseIf lAltS2400
		INCLUI := .F.
		ALTERA := .T.

		FWMsgRun(,{||nExView:=FWExecView(STR0027,"TAFA589",MODEL_OPERATION_UPDATE,,{||.T.} )},,STR0026) //"Alteração do Cadastro de Beneficiário - Início"
	Else
		MsgAlert(cMsgErr)
	EndIf

Return

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF588Vis
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TAF588Vis()

	Local nOption 		:= -1
	Local cTitulo		:= STR0016
	Local cFuncao		:= "TAFA589"
	Local lExist2405 	:= .F.
	Local lOk 			:= .T.
	Local aOpcoes 		:= {}

	If !FWIsInCallStack("XFUNNEWHIS")

		aAdd(aOpcoes, STR0008) //"S-2400 Cadastro de Beneficiário - Início"

		If ExistS2405(.F.,V73->V73_FILIAL,V73->V73_ID,.F.,"' ','1','2','3','4','6','7'")
			aAdd(aOpcoes, STR0009) //"S-2405 Cadastro de Beneficiário - Alteração"
			lExist2405 := .T.
		EndIf

		If lExist2405

			nOption := TAF588Options(aOpcoes)

			If nOption > 1
				If nOption == 6
					cTitulo	:= STR0030
					cFuncao	:= "TAFA590"

					// posiciona no registro S-2405
					ExistS2405(.F.,V73->V73_FILIAL,V73->V73_ID,.T.,"' ','1','2','3','4','6','7'")
				EndIf
			Else
				lOk := .F.
			EndIf

		EndIf

		If lOk
			FWExecView(cTitulo,cFuncao,MODEL_OPERATION_VIEW,, {|| .T. } )
		EndIf

	EndIf

Return

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF588Del
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TAF588Del(cAlias,nReg,nOptExc)

	Local aOpcoes	:= {} 
	Local cMsgErr	:= ""
	Local lOption	:= .F.
	Local lOk		:= .T.
	Local nOption	:= 7

	If nOptExc == 1 //"Excluir Registro"

		aAdd(aOpcoes, STR0010) //"S-2400 Excluir - Início"
		If ExistS2405(.F.,V73->V73_FILIAL,V73->V73_ID,.F.,"' ','0','1','3','4'")
			aAdd(aOpcoes, STR0011) //"S-2405 Excluir - Alteração")
			lOption := .T.
		EndIf
		
	ElseIf nOptExc == 2 //"Desfazer Exclusão"

		nOption	:= 9
		aAdd(aOpcoes, STR0012) //"S-2400 Desfazer Exclusão - Início"

		If ExistS2405(.F.,V73->V73_FILIAL,V73->V73_ID,.F.,"'6'")
			aAdd(aOpcoes, STR0013) //"S-2405 Desfazer Exclusão - Alteração"
			lOption := .T.
		EndIf

	ElseIf nOptExc == 3 //"Visualizar Registro de Exclusão"

		nOption	:= 11
		aAdd(aOpcoes, STR0014) //"S-2400 Visualizar Exclusão - Início"

		If ExistS2405(.F.,V73->V73_FILIAL,V73->V73_ID,.F.,"' ','0','1','3','4','6','7'")
			aAdd(aOpcoes, STR0015) //"S-2405 Visualizar Exclusão - Alteração"
			lOption := .T.
		EndIf

	EndIf

	If lOption
		nOption := TAF588Options(aOpcoes)
		lOk 	:=  nOption > 0
	EndIf

	If lOk

		INCLUI := .F.
		ALTERA := .F.

		// 7 - "S-2400 Excluir - Início"
		// 8 - "S-2405 Excluir - Alteração"
		If nOption == 7 .Or. nOption == 8 

			If nOption == 8 
				ExistS2405(.F.,V73->V73_FILIAL,V73->V73_ID,.T.,"' ','0','1','3','4'")
				l2405 := .T.
			EndIf

			If nOption == 7 .And. ExistS2405(.F.,V73->V73_FILIAL,V73->V73_ID,.F.,"' ','0','1','3','4','6'") .And. Empty(V73->V73_PROTPN)
				cMsgErr := STR0056 //"Registro não pode ser excluído, pois possui um evento de alteração vinculado (S-2405)."
			ElseIf V73->V73_STATUS == '2'
				cMsgErr := STR0036 + " " + STR0037 // "Registro não pode ser excluído, pois encontra-se em processo de transmissão."
			ElseIf V73->V73_STATUS == '6'
				cMsgErr := STR0036 +  " " + STR0038 //"Aguardando processo de transmissão do evento de Exclusão S-3000."
			ElseIf V73->V73_STATUS == '7'
				cMsgErr := STR0039 //"Registro não pode ser alterado, pois já encontra-se excluído na base do RET."
			Else
				xTafVExc( 'V73', V73->(Recno()), 1 )
			EndIf

			If !Empty(cMsgErr)
				MsgAlert(cMsgErr)
			EndIf
			
		// 9 - "S-2400 Desfazer Exclusão - Início"
		// 10 - "S-2405 Desfazer Exclusão - Alteração"
		ElseIf nOption == 9 .Or. nOption == 10

			If nOption == 10
				ExistS2405(.T.,V73->V73_FILIAL,V73->V73_ID,.T.,"'6'")
			EndIf

			xTafVExc( 'V73', V73->(Recno()), 2 )

		// 11 - "S-2400 Visualizar Exclusão - Início"
		// 12 - "S-2405 Visualizar Exclusão - Alteração"
		ElseIf nOption == 11 .Or. nOption == 12

			If nOption == 12
				ExistS2405(.T.,V73->V73_FILIAL,V73->V73_ID,.T.,"'6','7'")
			EndIf

			xTafVExc( 'V73', V73->(Recno()), 3 )

		EndIf

	EndIf

	If ValType(oBrw) == "O"
		oBrw:Refresh()
	EndIf

Return

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF588AltExt
@author Fabio Santos de Mendonça
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TAF588AltExt(cTpExtemp)

	Local nExView     := 0

	Private lGoExtemp := .T.

	Eval( {|| nExView := AlteraExtemp( cTpExtemp ) })

Return

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExistS2405
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function ExistS2405(lTransmit,cFilV73, cIdV73, lSeek,cStatus)

	Local lRet        := .F.
	Local cAlias      := GetNextAlias()
	Local cWhere      := " V73_NOMEVE = 'S2405' "

	Default lTransmit := .F.
	Default lSeek     := .F.
	Default cStatus   := ''
	Default cIdV73    := ''

	If Empty(cStatus)
		cWhere += " AND V73_STATUS IN (" + IIF(lTransmit,"'4'","'0','1','3',' '") + ")"
	Else
		cWhere += " AND V73_STATUS IN (" + cStatus + ")"
	EndIf

	If !Empty(cIdV73)
		cWhere += " AND V73_ID = '" + cIdV73 + "' "
	EndIf

	cWhere := '%' + cWhere + '%'

	BeginSql Alias cAlias
		SELECT V73.R_E_C_N_O_ AS V73_RECNO
		FROM %Table:V73% V73
		WHERE V73.%NotDel%
		AND %Exp:cWhere%
		AND V73_ATIVO = '1'
		AND V73_FILIAL = %Exp:cFilV73%
		ORDER BY V73_DTALTE DESC
	EndSql

	If (cAlias)->(!EOF())
		lRet := .T.
		If lSeek
			V73->(DbGoTo( (cAlias)->V73_RECNO ))
		EndIf
	EndIf

	(cAlias)->(DbCloseArea())

Return lRet

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF588Options
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TAF588Options(aOpcoes, cTitulo )

	Local oDlg			:= Nil
	Local oRadio		:= Nil
	Local oTBok			:= Nil
	Local oTBSair		:= Nil
	Local nOpc			:= 0
	Local nLinFrom  	:= 428
	Local nColFrom  	:= 741
	Local nLinBtOk  	:= 100
	Local nColBtOk  	:= 058
	Local nLinBtSair	:= 100
	Local nColBtSair	:= 130
	Local nLinTo     	:= 680
	Local nColTo     	:= 1192
	Local nSayCol    	:= 035
	Local cMens			:= STR0035 //Selecione a operação desejada:

	Private oTMultiget	:= Nil
	Private oFont1	  	:= TFont():New( "MS Sans SerIf",0,-14,,.F.,0,,700,.F.,.F.,,,,,, )
	Private oSay1		:= Nil
	
	Default cTitulo		:= STR0016

	DEFINE DIALOG oDlg TITLE cTitulo FROM nLinFrom,nColFrom TO nLinTo,nColTo PIXEL STYLE DS_MODALFRAME
	oDlg:lEscClose := .F.
	oRadio := TRadMenu():New (30,25,aOpcoes,,oDlg,,,,,,,,150,32,,,,.T.)
	oRadio:bSetGet := {|u|Iif (PCount()==0,nOpc, nOpc := TAF588ROpc(aOpcoes,u))}

	oSay1		:= TSay():New( 012,nSayCol,{||cMens},oDlg,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,168,010)
	oTBok		:= TButton():New( nLinBtOk  , nColBtOk, "Confirmar",oDlg,{||lOk := .T., oDlg:End()},37,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTBSair	:= TButton():New( nLinBtSair, nColBtSair, "Sair",oDlg,{||nOpc:=0,oDlg:End()}, 37,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE DIALOG oDlg CENTERED

Return nOpc

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF588ROpc
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Static Function TAF588ROpc( aOpcoes, nOpc )

	Local nOpcRet 	:= -1
	Local cTpEvento	:= aOpcoes[nOpc]

	Default aOpcoes	:= {}
	Default nOpc	:= 1

	// Alteração/Retificação
	If cTpEvento $  STR0004 //"S-2400 Retificar Cadastro de Beneficiário - Início"
		nOpcRet := 1
	ElseIf cTpEvento $ STR0005 // "S-2405 Incluir Cadastro de Beneficiário - Alteração"
		nOpcRet := 2
	ElseIf cTpEvento $ STR0006 // "S-2405 Alterar Cadastro de Beneficiário - Alteração"
		nOpcRet := 3
	ElseIf cTpEvento $ STR0007 //"S-2405 Retificar Cadastro de Beneficiário - Alteração"
		nOpcRet := 4

	// Visualização
	ElseIf cTpEvento $ STR0008 //"S-2400 Cadastro de Beneficiário - Início"
		nOpcRet := 5
	ElseIf cTpEvento $ STR0009 //"S-2405 Cadastro de Beneficiário - Alteração"
		nOpcRet := 6

	// Exclusão
	ElseIf cTpEvento $ STR0010 //"S-2400 Excluir - Cadastro de Beneficiário - Início"
		nOpcRet := 7
	ElseIf cTpEvento $ STR0011 //"S-2405 Excluir - Cadastro de Beneficiário - Alteração"
		nOpcRet := 8
	ElseIf cTpEvento $ STR0012 //"S-2400 Desfazer Exclusão - Cad. Beneficiário - Início"
		nOpcRet := 9
	ElseIf cTpEvento $ STR0013 //"S-2405 Desfazer Exclusão - Cad. Beneficiário - Alteração"
		nOpcRet := 10
	ElseIf cTpEvento $ STR0014 //"S-2400 Visualizar Exclusão - Cad. Beneficiário - Início"
		nOpcRet := 11
	ElseIf cTpEvento $ STR0015 //"S-2405 Visualizar Exclusão - Cad. Beneficiário - Alteração"
		nOpcRet := 12
	EndIf

Return nOpcRet

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF588Carr
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TAF588Carr( cTitulo,cFunName,nOper,nOpc)

	Local nDep 			:= 0
	Local aCamposV73	:= {}
	Local aCamposV74	:= {}
	Local oStruV73		:= FWFormStruct( 1, "V73" )
	Local oStruV74		:= FWFormStruct( 1, "V74" )

	Private oModelLoad	:= Nil

	Default cTitulo		:= ""
	Default cFunName	:= ""
	Default nOper		:= 1
	Default nOpc		:= 1

	oModelLoad := FWLoadModel(cFunName)
	oModelLoad:SetOperation(nOper)
	oModelLoad:Activate()

	//-------------------------------------------------------------
	// 1 - "S-2400 Retificar Cadastro de Beneficiário - Início"
	//-------------------------------------------------------------
	If nOpc == 1

		aCamposV73 := RemoveFld('V73', oStruV73)

		oModelLoad:LoadValue( "MODEL_V73","V73_NOMEB" ,V73->V73_NOMEB)
		
		aEval(aCamposV73,{|campo|oModelLoad:LoadValue( "MODEL_V73", campo[2], &("V73->" + Alltrim(campo[2]) ) ) })

		// carrega campos virtuais
		oModelLoad:LoadValue( "MODEL_V73","V73_DTPLOG",Alltrim(Posicione("C06",3,xFilial("C06")+&("V73->V73_TPLOG"),"Alltrim(C06_CESOCI)+' - '+C06_DESCRI")))

	//-------------------------------------------------------------
	// 2 - "S-2405 Incluir Cadastro de Beneficiário - Alteração"
	//-------------------------------------------------------------
	ElseIf nOpc == 2

		aCamposV73 := RemoveFld('V73', oStruV73,'S2405')

		oModelLoad:LoadValue( "MODEL_V73","V73_NOMEB" ,V73->V73_NOMEB)
		
		aEval(aCamposV73,{|campo|oModelLoad:LoadValue( "MODEL_V73", campo[2], &("V73->" + Alltrim(campo[2]) ) ) })

		// carrega campos virtuais
		oModelLoad:LoadValue( "MODEL_V73","V73_DTPLOG",Alltrim(Posicione("C06",3,xFilial("C06")+&("V73->V73_TPLOG"),"Alltrim(C06_CESOCI)+' - '+C06_DESCRI")))

		oModelLoad:LoadValue( "MODEL_V73","V73_DPAISR",Alltrim(Posicione("C08",3,xFilial("C08")+&("V73->V73_PAISRE"),"ALLTRIM(C08->(C08_CODIGO + ' - ' + C08_DESCRI))")))
		oModelLoad:LoadValue( "MODEL_V73","V73_DCODMU",Alltrim(Posicione("C07",3,xFilial("C07")+&("V73->V73_CODMUN"),"ALLTRIM(C07->(C07_CODIGO + ' - ' + C07_DESCRI))")))
		oModelLoad:LoadValue( "MODEL_V73","V73_DUF"   ,Alltrim(Posicione("C09",3,xFilial("C09")+&("V73->V73_UF"   ),"ALLTRIM(C09->(C09_UF + ' - ' + C09_DESCRI))")))
		
		// Dependentes
		V74->(dbSetOrder(1)) //V74_FILIAL+V74_ID+V74_VERSAO+V74_NOMEVE+V74_IDDEP
		V74->(dbGotop())

		If V74->(DbSeek( V73->(V73_FILIAL + V73_ID + V73_VERSAO + V73_NOMEVE) ))

			aCamposV74 := RemoveFld('V74', oStruV74)

			While V74->(!EOF()) .And. V74->(V74_FILIAL + V74_ID + V74_VERSAO) == V73->(V73_FILIAL + V73_ID + V73_VERSAO)

				If nDep > 0
					oModelLoad:GetModel( "MODEL_V74" ):lValid:= .T.
					oModelLoad:GetModel( "MODEL_V74" ):AddLine()
				EndIf

				aEval(aCamposV74,{|Campo|oModelLoad:LoadValue( "MODEL_V74",campo[2],&("V74->" + Alltrim(campo[2]) ) ) })

				// carrega campos vrituais
				oModelLoad:LoadValue( "MODEL_V74", "V74_DTPDE ",Alltrim(POSICIONE("CMI",1,XFILIAL("CMI") + V74->V74_TPDEP ,"CMI_CODIGO+' - '+CMI_DESCRI") ) )

				nDep ++

				V74->(DbSkip())
			EndDo

		EndIf

	//-------------------------------------------------------------
	// 4 - "S-2405 Retificar Cadastro de Beneficiário - Alteração"
	//-------------------------------------------------------------
	ElseIf nOpc == 4

		aCamposV73 := RemoveFld('V73', oStruV73)

		oModelLoad:LoadValue( "MODEL_V73","V73_NOMEB" ,V73->V73_NOMEB)
		
		aEval(aCamposV73,{|campo|oModelLoad:LoadValue( "MODEL_V73", campo[2], &("V73->" + Alltrim(campo[2]) ) ) })

		// carrega campos virtuais
		oModelLoad:LoadValue( "MODEL_V73","V73_DTPLOG",Alltrim(Posicione("C06",3,xFilial("C06")+&("V73->V73_TPLOG"),"Alltrim(C06_CESOCI)+' - '+C06_DESCRI")))
		oModelLoad:LoadValue( "MODEL_V73","V73_DPAISR",Alltrim(Posicione("C08",3,xFilial("C08")+&("V73->V73_PAISRE"),"ALLTRIM(C08->(C08_CODIGO + ' - ' + C08_DESCRI))")))
		oModelLoad:LoadValue( "MODEL_V73","V73_DCODMU",Alltrim(Posicione("C07",3,xFilial("C07")+&("V73->V73_CODMUN"),"ALLTRIM(C07->(C07_CODIGO + ' - ' + C07_DESCRI))")))
		oModelLoad:LoadValue( "MODEL_V73","V73_DUF"   ,Alltrim(Posicione("C09",3,xFilial("C09")+&("V73->V73_UF"   ),"ALLTRIM(C09->(C09_UF + ' - ' + C09_DESCRI))")))
	
	EndIf

	If !IsBlind()
		FWExecView(cTitulo,cFunName,nOper,,{||.T.},,,,,,,oModelLoad)
	Else
		If cFunName == "TAFA590"
			oModelLoad:LoadValue("MODEL_V73", "V73_DTALT", dDataBase)
		EndIf

		If oModelLoad:VldData()
			oModelLoad:CommitData()
		EndIf
	EndIf

Return

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} RemoveFld
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Static Function RemoveFld(cAlias, oStru, cEvento)

	Local nX 			:= 1
	Local nY 			:= 1
	Local aFldRemove 	:= {}
	Local aCampos		:= {}

	Default cEvento := 'S2400'

	If cAlias == 'V73'

		aFldRemove := {'V73_ATIVO','V73_STATUS','V73_NOMEVE','V73_FILIAL','V73_ID','V73_VERSAO','V73_ATIVO','V73_EVENTO','V73_VERANT','V73_PROTPN','V73_LOGOPE','V73_XMLID','V73_TAFKEY','V73_NOMEVE','V73_DTTRAN','V73_HTRANS','V73_DTRECP','V73_HRRECP','V73_STATUS','V73_STASEC','V73_PROTUL','V73_DTALTE'}

		If cEvento == 'S2405'
			aAdd(aFldRemove,'V73_DTINIC')
			aAdd(aFldRemove,'V73_DTNASC')
			aAdd(aFldRemove,'V73_DTINCF')
		EndIf

	ElseIf cAlias = 'V74'

		aFldRemove := {'V74_FILIAL','V74_ID','V74_VERSAO','V74_NOMEVE'}

	EndIf

	aCampos  := xFunGetSX3(cAlias,cAlias)

	For nX := 1 To Len(aFldRemove)
		For nY := 1 To Len(aCampos)
			nPosDel	:=	aScan( aCampos , { | aX | AllTrim( aCampos[nY][2] ) == aFldRemove[nX] } )
			If nPosDel > 0
				aDel( aCampos, nY )
				aSize( aCampos, Len( aCampos ) - 1 )
				Exit
			EndIf
		Next
	Next

	For nX := 1 To Len(aFldRemove)
		oStru:RemoveField(aFldRemove[nX])
	Next

Return aClone(aCampos)

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF588GetBenXml
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TAF588GetBenXml( cLayout, cAlias, cAliasDep, nRecno )

	Local cXml			:= ""
	Local cTagTrab		:= ""
	Local cCmpCEP		:= ""
	Local cPais			:= ""
	Local cXMLBras		:= ""
	Local cXMLExt		:= ""
	Local cCodMun		:= ""
	Local cCodUF		:= ""
	Local lPosV73		:= .F.

	Default nRecno      := 1
	Default cLayout		:= ""
	Default cAlias		:= ""
	Default cAliasDep	:= "V74"

	(cAlias)->(DbGoto(nRecno))

	If cLayout == "2405"
		cTagTrab := "dadosBenef"
	Else
		cTagTrab := "beneficiario"
	EndIf

	(cAliasDep)->( DBSetOrder( 1 ))

	If cLayout == "2405"
		cXml += "<ideBenef>"
		cXml +=	 	xTafTag( "cpfBenef", (cAlias)->&( cAlias + "_CPFBEN" ) )
		cXml += "</ideBenef>"
		cXml += "<alteracao>"
		cXml += 	xTafTag("dtAlteracao",(cAlias)->&( cAlias + "_DTALTE" ) )
	EndIf

	cXml +=	"<" + cTagTrab + ">"
	If cLayout $ "2400"
		cXml +=	 xTafTag( "cpfBenef", (cAlias)->&( cAlias + "_CPFBEN" ) )
	EndIf

	If FunName() == "TAFMIGR003" .And. cAlias == "V73"
		lPosV73 := .T. //Quando o Alias vem posicionado
	EndIf

	If cLayout $ "2405"
		cXml +=	 xTafTag("nmBenefic"	,FwCutOff((cAlias)->&( cAlias + "_NOMEB" ), .T.) )
		cXml +=	 xTafTag("sexo"			,(cAlias)->&( cAlias + "_SEXO" ),,.T. )
		cXml +=	 xTafTag("racaCor"		,(cAlias)->&( cAlias + "_RACA" ) )
		cXml +=	 xTafTag("estCiv"		,(cAlias)->&( cAlias + "_ESTCIV" ),,.T. )
		cXml +=	 xTafTag("incFisMen"	,(cAlias)->&( cAlias + "_INCFIS" ) )

	ElseIf cLayout $ "2400"

		cXml +=	 xTafTag("nmBenefic"	,FwCutOff( (cAlias)->&( cAlias + "_NOMEB" ), .T.) )
		cXml +=	 xTafTag("dtNascto"		,(cAlias)->&( cAlias + "_DTNASC" ))
		cXml +=	 xTafTag("dtInicio"		,(cAlias)->&( cAlias + "_DTINIC" ))
		cXml +=	 xTafTag("sexo"			,(cAlias)->&( cAlias + "_SEXO" ),,.T.)
		cXml +=	 xTafTag("racaCor"		,(cAlias)->&( cAlias + "_RACA" ) )
		cXml +=	 xTafTag("estCiv"		,(cAlias)->&( cAlias + "_ESTCIV" ),,.T. )
		cXml +=	 xTafTag("incFisMen"	,(cAlias)->&( cAlias + "_INCFIS" ) )
		cXml +=	 xTafTag("dtIncFisMen"  ,(cAlias)->&( cAlias + "_DTINCF" ),,.T. )

	EndIf

	cPais	:= Posicione("C08",3,xFilial("C08") + (cAlias)->&( cAlias + "_PAISRE" ), "C08_PAISSX")
	cCmpCEP := StrTran( (cAlias)->&( cAlias + "_CEP" ), "-", "" )

	If Empty(cPais)
		
		C07->(DBSetOrder(3))
		If C07->(MsSeek(xFilial("C07") + (cAlias)->&( cAlias + "_CODMUN" ) ) )
			
			C09->(DBSetOrder(3))
			If C09->(MsSeek(xFilial("C09") + C07->C07_UF))
				cCodMun := C09->C09_CODIGO + C07->C07_CODIGO
				cCodUF 	:= C09->C09_UF
			EndIf
		EndIf
		
		xTafTagGroup("brasil";
			,{{"tpLograd"			,Posicione("C06",3,xFilial("C06") + (cAlias)->&( cAlias + "_TPLOG" ),"C06_CESOCI")									,,.T.,.T.};
			, {"dscLograd"		,FwCutOff((cAlias)->&( cAlias + "_DLOG" ),.T.)	,,.F.,.T.};
			, {"nrLograd"			,(cAlias)->&( cAlias + "_NUMLOG" ),,.F.,.T.};
			, {"complemento"	,FwCutOff((cAlias)->&( cAlias + "_COMLOG" ),.T.)	,,.T.,.F.};
			, {"bairro"				,FwCutOff((cAlias)->&( cAlias + "_BAIRRO" ),.T.)	,,.T.,.F.};
			, {"cep"					,cCmpCEP,,.F.,.T.};
			, {"codMunic"			,cCodMun,,.F.,.T.};
			, {"uf"						,cCodUF,,.F.,.T.}};
			,@cXMLBras)

	Else
		xTafTagGroup("exterior";
			,{{"paisResid"	,Posicione("C08",3,xFilial("C08") + (cAlias)->&( cAlias + "_PAISRE" ),"C08_PAISSX"),,.F.,.T.};
			, {"dscLograd"	,FwCutOff((cAlias)->&( cAlias + "_DSCLOG" ),.T.),,.F.,.T.};
			, {"nrLograd"		,(cAlias)->&( cAlias + "_NRLOGR" ),,.F.,.T.};
			, {"complemento",FwCutOff((cAlias)->&( cAlias + "_LOGRAD" ), .T.),,.T.};
			, {"bairro"			,FwCutOff((cAlias)->&( cAlias + "_DISTRI" ), .T.),,.T.};
			, {"nmCid"			,FwCutOff((cAlias)->&( cAlias + "_NMCIDE" ), .T.),,.F.,.T.};
			, {"codPostal"	,cCmpCEP,,.T.}};
			,@cXMLExt)
	EndIf

	xTafTagGroup("endereco",;
		,@cXML;
		,{{"brasil"		,cXMLBras,0};
		, {"exterior"	,cXMLExt ,0}};
		,.T.;
		,.T.)

	If (cAliasDep)->(MsSeek(xFilial(cAliasDep) + (cAlias)->( &( cAlias + "_ID") + &( cAlias + "_VERSAO" ) ) ) )

		While (cAliasDep)->(!Eof()) .and. (cAliasDep)->(&(cAliasDep + "_FILIAL") + &(cAliasDep + "_ID") + &(cAliasDep + "_VERSAO")) == xFilial(cAliasDep) + (cAlias)->( &( cAlias + "_ID" ) + &( cAlias + "_VERSAO" ) )
			cXml +=	"<dependente>"

			If CMI->(MsSeek(xFilial("CMI") + (cAliasDep)->&(cAliasDep + "_TPDEP")))
				cXml +=	xTafTag("tpDep",CMI->CMI_CODIGO)
			EndIf

			cXml +=		xTafTag("nmDep"			,FwCutOff((cAliasDep)->&(cAliasDep + "_NMDEP"), .T.))
			cXml +=		xTafTag("dtNascto"	,(cAliasDep)->&(cAliasDep + "_DTNASC"))
			cXml +=		xTafTag("cpfDep"		,(cAliasDep)->&(cAliasDep + "_CPFDEP"),,.T.)
			cXml +=		xTafTag("sexoDep"		,(cAliasDep)->&(cAliasDep + "_SEXDEP"),,.T.)
			cXml +=		xTafTag("depIRRF"		,xFunTrcSN((cAliasDep)->&(cAliasDep + "_DEPIRF"),1))
			cXml +=		xTafTag("incFisMen"	,xFunTrcSN((cAliasDep)->&(cAliasDep + "_INCFIS"),1))

			cXml +=	"</dependente>"
			(cAliasDep)->(DBSkip())
		EndDo
	EndIf
	
	cXml +=	"</" + cTagTrab + ">"
	
	If cLayout == "2405"
		cXml += "</alteracao>"
	EndIf

Return( cXml )

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF588XmlVld
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TAF588XmlVld(nOpXmlVld, cFunction)

	Local cOpcXML		:= ""
	Local cTitulo		:= Iif(nOpXmlVld == 1, STR0031, STR0032) //"Geração de XML"//"Validação do Evento"
	Local cXml			:= ""
	Local nRecno		:= 0
	Local nOpc			:= 0
	Local lGerXml		:= .F.
	Local aGerXml		:= {}
	Local aXmls			:= {}
	Local aRet			:= {}
	Local aOpcoes		:= {}
	Local cTSSKey		:= ""
	Local cIdV73		:= ""
	Local lXmlVLd		:= IIF(FindFunction('TafXmlVLD'),TafXmlVLD('TAF588XMLVLD'),.T.)

	Default cFunction	:= ""
	Default nOpXmlVld	:= 0

	nRecno := V73->(Recno())

	//Geração do XML pelo Cadastro
	If (cFunction == "xNewHisAlt")

		aGerXml   := IIF(FindFunction('TAfxmltss'),TAfxmltss(),{})

		If Len(aGerXml) > 0
			lGerXml := aGerXml[1]
			cOpcXML := aGerXml[2]
			
			If lGerXml
				If cOpcXML == "1-XML TAF"
					If V73->V73_NOMEVE == "S2405"
						TAF590Xml( "V73", nRecno )
					Else
						TAF589Xml( "V73", nRecno )
					EndIf
				ElseIf cOpcXML == "2-XML RET"
					cTSSKey := V73->V73_NOMEVE + AllTrim(V73->V73_ID) + AllTrim(V73->V73_VERSAO)

					aAdd( aXmls, cTSSKey )

					aRet := TAFGETXMLTSS(aXmls)

					If len(aRet) > 0
						cXml := aRet[1][4]
						If !Empty(cXml)
							xTafGerXml( cXml, SubStr(cLayout,2) )
						Else
							MsgInfo("Verifique se o evento está transmitido.","XML não encontrado.")
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf	

	//Geração do XML pelo Hist. Alt.
	Else
		If V73->V73_NOMEVE == "S2400"
			aAdd(aOpcoes, STR0008) //"S-2400 Cadastro de Beneficiário - Início"
			If ExistS2405(.F.,V73->V73_FILIAL,cIdV73,.T.) .Or. ExistS2405(.T.,V73->V73_FILIAL,cIdV73,.T.)
				aAdd(aOpcoes, STR0009) //"S-2405 Cadastro de Beneficiário - Alteração")
			EndIf 
		EndIf

		If (!IsBlind()) .And. lXmlVLd

			nOpc := TAF588Options(aOpcoes, cTitulo)
			If nOpc > 0
				If nOpXmlVld == 1
					aGerXml := IIF(FindFunction('TAfxmltss'),TAfxmltss(),{})
				EndIf
				If Len(aGerXml) > 0
					lGerXml := aGerXml[1]
					cOpcXML := aGerXml[2]
					lRetXml := lGerXml .AND. cOpcXML == "1-XML TAF"
				Else
					lGerXml := .T.
					lRetXml := .T.
					cOpcXML := "1- XML TAF"
				EndIf
				If nOpc == 5
					If nOpXmlVld == 1  .AND. lRetXml
						TAF589Xml( "V73", nRecno )
					Else
						cLayout	:= "2400"
						cAlias	:= "V73"
					EndIf
					
				ElseIf nOpc == 6 
					nRecno := V73->(Recno())
					If nOpXmlVld == 1  .AND. lRetXml
						TAF590Xml( "V73", nRecno )
					Else
						cLayout	:= "2405"
						cAlias	:= "V73"
					EndIf
				EndIf

				If lGerXml .AND. cOpcXML == "2-XML RET"
					cTSSKey := "S" + cLayout + AllTrim( (cAlias)->&(cAlias+"_ID") ) + AllTrim( (cAlias)->&(cAlias+"_VERSAO") )
					aAdd( aXmls, cTSSKey )
					aRet := TAFGETXMLTSS(aXmls)
					If len(aRet) > 0
						cXml := aRet[1][4]
						If !Empty(cXml)
							xTafGerXml( cXml, cLayout )
						Else
							MsgInfo(STR0033,STR0034) //"Verifique se o evento está transmitido."//"XML não encontrado."
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf588RulCad
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function Taf588RulCad( cCabecTrab, cLayout, cAlias, cInconMsg, nSeqErrGrv, cOwner)

	Local aRull      		:= {}
	Local cPais				:= ""
	Local lNoVldEst			:= SuperGetMv("MV_TAFVLUF", .F., .F.)

	Default cCabecTrab		:= ""
	Default cLayout			:= ""
	Default cAlias			:= "V73"
	Default cCabecVinc		:= ""
	Default cInconMsg		:= ""
	Default nSeqErrGrv		:= 0
	Default lTransmit		:= .F.
	Default oModel			:= Nil
	Default aChave			:= {}
	Default aIncons			:= {}
	Default cCodEvent		:= ""
	Default cOwner			:= ""
	Default aChaveOri		:= {}

	//Inicio das TAGs - Beneficiario
	If cLayout == "2400"
		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/cpfBenef"))
			aAdd( aRull, { cAlias + "_CPFBEN", cCabecTrab + "/cpfBenef", "C", .F. } )
		EndIf
	ElseIf cLayout == "2405"
		If TafXNode( oDados , cCodEvent, cOwner, ("/eSocial/evtCdBenefAlt/ideBenef/cpfBenef"))
			aAdd( aRull, { cAlias + "_CPFBEN", "/eSocial/evtCdBenefAlt/ideBenef/cpfBenef", "C", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, ("/eSocial/evtCdBenefAlt/alteracao/dtAlteracao"))
			aAdd( aRull, { cAlias + "_DTALTE", "/eSocial/evtCdBenefAlt/alteracao/dtAlteracao", "D", .F.} )
		EndIf

		cCabecTrab := "/eSocial/evtCdBenefAlt/alteracao/dadosBenef"
	EndIf
		
	If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/nmBenefic"))
		aAdd( aRull, { cAlias + "_NOMEB",   cCabecTrab + "/nmBenefic", "C", .F. } )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/dtNascto"))
		aAdd( aRull, { cAlias + "_DTNASC", cCabecTrab + "/dtNascto", "D" , .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/dtInicio"))
		aAdd( aRull, { cAlias + "_DTINIC", cCabecTrab + "/dtInicio", "D" , .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/sexo"))
		aAdd( aRull, { cAlias + "_SEXO",   cCabecTrab + "/sexo", "C", .F.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/racaCor"))
		aAdd( aRull, { cAlias + "_RACA",  cCabecTrab + "/racaCor", "C", .F. } )
	EndIf
	
	If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/estCiv"))
		aAdd( aRull, { cAlias + "_ESTCIV", cCabecTrab + "/estCiv", "C", .F. } )
	EndiF

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/incFisMen"))
		aAdd( aRull, { cAlias + "_INCFIS", TAFExisTag( cCabecTrab + "/incFisMen" ) , "C", .T.} )
	EndIf

	If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/dtIncFisMen"))
		aAdd( aRull, { cAlias + "_DTINCF", cCabecTrab + "/dtIncFisMen", "D" , .F.} )
	EndIf

	//eSocial/.../endereco
	cPais = AllTrim( FTafGetVal( cCabecTrab + "/endereco/exterior/paisResid", , , {}, , ,  ) )

	If  !Empty(cPais)

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/exterior/paisResid"))
			aAdd( aRull, { cAlias + "_PAISRE"  , FGetIdInt( "paisResid", "", cCabecTrab + "/endereco/exterior/paisResid",,,,@cInconMsg, @nSeqErrGrv),"C", .T.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/exterior/dscLograd"))
			aAdd( aRull, { cAlias + "_DSCLOG", cCabecTrab + "/endereco/exterior/dscLograd", "C", .F.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/exterior/nrLograd"))
			aAdd( aRull, { cAlias + "_NRLOGR" , cCabecTrab + "/endereco/exterior/nrLograd", "C", .F.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/exterior/complemento"))
			aAdd( aRull, { cAlias + "_LOGRAD", cCabecTrab + "/endereco/exterior/complemento", "C", .F.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/exterior/bairro"))
			aAdd( aRull, { cAlias + "_DISTRI", cCabecTrab + "/endereco/exterior/bairro", "C", .F.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/exterior/nmCid"))
			aAdd( aRull, { cAlias + "_NMCIDE", cCabecTrab + "/endereco/exterior/nmCid", "C", .F.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/exterior/codPostal"))
			aAdd( aRull, { cAlias + "_CODPOS"   , cCabecTrab + "/endereco/exterior/codPostal", "C", .F.} )
		EndIf

	Else

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/brasil/tpLograd" ))
			aAdd( aRull, { cAlias + "_TPLOG", FGetIdInt( "tpLograd", "", cCabecTrab + "/endereco/brasil/tpLograd",,,,@cInconMsg, @nSeqErrGrv ), "C", .T. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/brasil/dscLograd"))
			aAdd( aRull, { cAlias + "_DLOG", cCabecTrab + "/endereco/brasil/dscLograd", "C", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/brasil/nrLograd"))
			aAdd( aRull, { cAlias + "_NUMLOG" , cCabecTrab + "/endereco/brasil/nrLograd", "C", .F.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/brasil/complemento"))
			aAdd( aRull, { cAlias + "_COMLOG", cCabecTrab + "/endereco/brasil/complemento", "C", .F.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/brasil/bairro"))
			aAdd( aRull, { cAlias + "_BAIRRO", cCabecTrab + "/endereco/brasil/bairro", "C", .F.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/brasil/cep"))
			aAdd( aRull, { cAlias + "_CEP"   , cCabecTrab + "/endereco/brasil/cep", "C", .F.} )
		EndIf

		getUfMunicipio(@aRull,lNoVldEst,cAlias,cCabecTrab + "/endereco/brasil/uf",cCabecTrab +"/endereco/brasil/codMunic",cAlias+"_CODMUN",@cInconMsg,@nSeqErrGrv,cCodEvent,cOwner)

		If TafXNode( oDados , cCodEvent, cOwner, (cCabecTrab + "/endereco/brasil/uf"))
			aAdd( aRull, { cAlias + "_UF", FGetIdInt( "uf", "", cCabecTrab + "/endereco/brasil/uf",,,,@cInconMsg, @nSeqErrGrv), "C", .T.} )
		EndIf

	EndIf

Return( aRull )

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} AlteraExtemp
@author Fabio Santos de Mendonça
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Static Function AlteraExtemp( cTpExtemp )

	Local cTitulo       := ""
	Local cRotina       := ""
	Local cIdBen        := ""
	Local cNomeEvto     := ""
	Local cStatAlt      := ""
	Local cStatsEve     := ""
	Local cStatSecn     := ""
	Local cChvInd       := ""
	Local cVersao       := ""
	Local cAlias        := "V73"
	Local cChvBen       := V73->V73_ID + '1'
	Local nRecno        := 0
	Local cDtUtlAlt     := ""
	Local nOpc          := 0
	Local nOpcAviso     := 0
	Local nOpera        := 0
	Local nExView       := -1
	Local aOpcoes       := {}
	Local lPermiAlt     := .T.
	Local lRetif        := .T.

	Private lPossui2405 := IIF(RetUlt2405Ativo(cChvBen,4,@cDtUtlAlt),.T.,.F.)
	Private ALTERA      := .F.
	Private INCLUI      := .T.

	Default cTpExtemp   := ""

	lHistLoop           := .F.
	cIdBen              := V73->V73_ID
	cVersao             := V73->V73_VERSAO
	cStatsEve           := V73->V73_STATUS
	cStatSecn           := V73->V73_STASEC
	cNomeEvto           := V73->V73_NOMEVE
	nRecno              := V73->(recno())

	cChvInd := xFilial( cAlias ) + cIdBen + cVersao

	(cAlias)->( DBSetOrder( 1 ) )
	If (cAlias)->( MsSeek( cChvInd ) )

		If cTpExtemp == "R"
			If V73->V73_DTALTE >= cDtUtlAlt
				lRetif := .F.
			EndIf
		EndIf

		If lRetif

			cStatsEve := V73->V73_STATUS

			If cNomeEvto $ "S2400"

				Aviso(STR0041, STR0055, {"OK"}) //"Evento S-2400 não pode ser incluído / retificado por esta rotina.",

			ElseIf cStatsEve == '4'

				cChvTrab:= V73->V73_ID + '1'

				If cNomeEvto $ ('S2405')

					//==================================================================================++
					// O sistema permite ao usuário inserir varios eventos de alteração (S-2400)		||
					// para o mesmo trabalhador com datas dIferentes. Porém apenas é permitido retificar||
					// o último evento de alteração enviado. Por isso a função RetUltAtivo posiciona no	||
					// registro ativo com a maior data. 												||
					//==================================================================================++
					If cTpExtemp $ " /R"
						If cNomeEvto $ ('S2405')
							aAdd(aOpcoes,STR0007) //nOpc = 4#"retificar Dados Cadastrais (S-2405)"
						EndIf
					EndIf

					If lPermiAlt

						If cTpExtemp $ " /A"
							If cNomeEvto $ ('S2405')
								aAdd(aOpcoes,STR0006) //nOpc = 3#"Alterar Cadastro de Beneficiário - Alteração (S-2405)"
							EndIf
						EndIf

						//===========================================================================================+
						// nOpc == 3 - Alterar Cadastro de Beneficiário - Alteração (S-2405) # S-2405               ||
						// nOpc == 4 - Retificar Cadastro de Beneficiário - Alteração (S-2405) # S-2405             ||
						//===========================================================================================+
						nOpc:= TAF588Options(aOpcoes) //Abro a tela com as opções de alteração para o usuário

						If nOpc > 0

							//Opc = 3#"Alterar Cadastro de Beneficiário - Alteração (S-2405)" # Opc = 4#"Retificar Cadastro de Beneficiário - Alteração (S-2405)"
							If (nOpc == 3 .or. nOpc == 4) .and. cNomeEvto $ ('S2405')
								cTitulo	:= STR0057 //"Alteração Cadastro de Beneficiários"
								cRotina	:= "TAFA590"
							EndIf
						EndIf

					Else

						MsgAlert(xValStrEr("000727")) //"Registro não pode ser alterado. Aguardando processo da transmissão."

					EndIf

				EndIf

				If nOpc > 0

					//================================== OPÇÕES DE ALTERAÇÃO ==========================================+
					// nOpc == 3 - Alterar Cadastro de Beneficiário - Alteração (S-2405) # S-2405                     ||
					// nOpc == 4 - Retificar Cadastro de Beneficiário - Alteração (S-2405) # S-2405               	  ||
					//=================================================================================================+

					(cAlias)->(dbGoTo(nRecno))

					//Inclusão de evento de alteração S-2405
					If nOpc == 3

						INCLUI := .T.
						ALTERA := .F.

						nOpera 	:= MODEL_OPERATION_INSERT
						cStatAlt:= cStatsEve

						If cStatAlt $ '0|4' .Or. ( Empty( cStatAlt ) .And. cTpExtemp == "A")//Verifica se não existe evento de alteração pendente de transmissão
							FWMsgRun(,{||TAF588Carr(cTitulo,cRotina,nOpera,2)},,STR0040) // "Executando Rotina do Beneficiário..."

						ElseIf cStatAlt == '1' .or. cStatAlt == '3'

							//Não permito retificação do evento do beneficiário se houver um evento de alteração S2205 pendente.
							If cStatAlt == '1'
								nOpcAviso := Aviso( STR0041, STR0050 + STR0051 + CRLF + STR0053 +; 
								STR0054, { "Sim", "Não" },3 ) 
							ElseIf cStatAlt == '3'
								nOpcAviso := Aviso( STR0041, STR0050 + STR0052 + CRLF + STR0053 +; 
								STR0054, { "Sim", "Não" },3 ) 
							EndIf

							If nOpcAviso == 1 
								//Deleto o registro pendente
								DelEvento("TAFA588")

								//Carrego o modelo consolidando as informações para alteração das informações
								FWMsgRun(,{||TAF588Carr(cTitulo,cRotina,nOpera,nOpc)},,STR0040) // "Executando Rotina do Beneficiário..."
							EndIf

						Else //cStatAlt == 2 - Evento em processo de transmissão
							msgAlert(xValStrEr("000727")) //"Registro não pode ser alterado, pois se encontra em processo de transmissão"
						EndIf

						If !Isblind()
							lHistLoop := .T.
						Else
							lHistLoop := .F.
						EndIf

					//retificação de um evento de alteração S-2405
					ElseIf nOpc == 4

						INCLUI := .F.
						ALTERA := .T.

						nOpera 		:= MODEL_OPERATION_UPDATE
						cStatAlt 	:= cStatsEve

						If cStatAlt == '1'

							//Efetuo alteração direta no registro
							FWMsgRun(,{||nExView:=FWExecView(cTitulo,cRotina,nOpera,,{||.T.} )},,STR0040) //"Executando Rotina do Beneficiário..."

						ElseIf cStatAlt == '4'

							If !Isblind()
								FWMsgRun(,{||TAF588Carr(cTitulo,cRotina,nOpera,nOpc)},,STR0040) //"Executando Rotina do Beneficiário..."
							Else
								TAF588Carr(cTitulo,cRotina,nOpera,nOpc)
							EndIf

						ElseIf cStatAlt == '3'

							nOpcAviso := Aviso( "e-Social", "Existe um evento" + " com retorno de inconsistência do RET." + CRLF + "Deseja Excluir este evento para gerar uma " +; 
							"retificação?", { "Sim", "Não" },3 ) 

							If nOpcAviso == 1 .and. cStatAlt <> '4'
								DelEvento("TAFA588")
							EndIf

						Else //cStatAlt == 2 - Evento em processo de transmissão
							msgAlert(xValStrEr("000727")) //"Registro não pode ser alterado, pois se encontra em processo de transmissão"
						EndIf

						If !Isblind()
							lHistLoop := .T.
						Else
							lHistLoop := .F.
						EndIf

					EndIf
				EndIf

			ElseIf cStatsEve == '2'

				msgAlert(xValStrEr("000727")) //"Registro não pode ser alterado. Aguardando processo da transmissão."

			ElseIf cStatsEve == '3'

				msgAlert( STR0041, STR0047, { "OK" }, 3 ) //"Evento com retorno de inconsistência do RET."

			ElseIf cStatsEve == '6'

				msgAlert(xValStrEr("000728")) //"Registro não pode ser alterado. Aguardando processo de transmissão do evento de Exclusão S-3000"

			ElseIf cStatsEve == '7'

				msgAlert(xValStrEr("000772")) //"Registro não pode ser alterado, pois o evento de exclusão já se encontra na base do RET"

			ElseIf cStatsEve $ (' |0|1|')

				msgAlert(xValStrEr("001119")) //"Não é permitido incluir extemporâneo para eventos não trasmitidos com sucesso ao RET."

			EndIf

		Else

			msgAlert(STR0048) //"Última Alteração de Beneficiário (S-2405) não pode ser retificada via extemporâneo!"

		EndIf

	Else

		msgAlert(STR0049) // "Registro não pode ser localizado"
		(cAlias)->( DBSetOrder( 1 ) )
		(cAlias)->( MsSeek( xFilial( cAlias ) + cIdBen + cVersao ) )

	EndIf

Return nExView

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetUlt2405Ativo
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function RetUlt2405Ativo(cChave,nInd,cDataAlt)

	Local aArea      := getArea()
	Local cAlias     := "V73"
	Local lReturn    := .F.
	Local nRecno     := 0
	Local cChvComp   := ""

	Default cDataAlt := ''

	(cAlias)->(dbSetorder(nInd)) // FILIAL + ID + ATIVO + DTALTE
	(cAlias)->(dbGoTop())

	If (cAlias)->(msSeek(xFilial(cAlias) + cChave))

		While (cAlias)->(!Eof()) .And. xFilial(cAlias) == (cAlias)->&(cAlias + "_FILIAL")

			cChvComp := (cAlias)->&(cAlias + "_ID") + (cAlias)->&(cAlias + "_ATIVO")

			If cChvComp == cChave
				// Passa registro até chegar no último evento para esse trabalhador
				nRecno := (cAlias)->(Recno())
			EndIf
			(cAlias)->(dbSkip())

		EndDo

		If nRecno > 0
			lReturn := .T.
			(cAlias)->(dbGoto(nRecno))
			cDataAlt := (cAlias)->V73_DTALTE
		EndIf

	EndIf

	RestArea(aArea)

Return lReturn

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF588ExcExt
@author Fabio Santos de Mendonça
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function TAF588ExcExt( cTpExtemp, cTpExcl )

	Default cTpExtemp := ""
	Default cTpExcl 	:= ""

	Private lGoExtemp := .T.

	exclusaoExtemp(cTpExtemp, cTpExcl)

Return

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} exclusaoExtemp
@author Fabio Santos de Mendonça
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Static Function exclusaoExtemp( cTpExtemp, cTpExcl )

	Local cNomeEvto     := ""
	Local cStatSecn     := ""
	Local cStatsEve     := ""
	Local cAlias        := "V73"
	Local cAtivo        := ""
	Local cChvBen       := V73->V73_ID + '1'
	Local cDtUltAlt2405 := ""
	Local nRecno        := 0
	Local lDelet        := .T.

	Default cTpExtemp   := ""
	Default cTpExcl     := ""

	Private ALTERA      := .F.
	Private INCLUI      := .T.

	cNomeEvto           := V73->V73_NOMEVE
	cStatSecn           := V73->V73_STASEC
	cStatsEve           := V73->V73_STATUS
	cAtivo              := V73->V73_ATIVO
	nRecno              := V73->(recno())
	lHistLoop           := .F.

	If cNomeEvto == "S2405"
		RetUlt2405Ativo(cChvBen,4,@cDtUltAlt2405)
		l2405 := .T.

		If V73->V73_DTALTE >= cDtUltAlt2405
			lDelet := .F.
		EndIf
	EndIf

	If cNomeEvto $ "S2400"
		Aviso(STR0041, STR0042, {"OK"}) //"Evento 2400 não pode ser excluído por esta rotina."
	ElseIf cStatsEve == '2'
		Aviso(STR0041, STR0043, {"OK"}) //"Registro já foi transmitido e está aguardando retorno. Não pode ser excluido."
	ElseIf cTpExcl == "1" .AND. cStatsEve == '6'
		Aviso(STR0041, STR0044, {"OK"}) //"Registro pendente de exclusão no Governo ( S-3000 ). Não pode ser excluído."
	ElseIf (cAlias)->V73_EVENTO == 'I' .And. cStatsEve == '2' // Verifica se há inativos já excluídos
		Aviso(STR0041, STR0045, {"OK"}) //"Evento S2405 inativo não pode ser excluído."
	ElseIf !lDelet
		Aviso(STR0041, STR0046, {"OK"}) //"Última alteração de beneficiário (S-2405) não pode ser excluída via extemporâneo!"
	Else
		nOpera := MODEL_OPERATION_DELETE
		INCLUI := .F.
		ALTERA := .F.

		//Efetuo a exclusão no registro
		xTafVExc( cAlias, nRecno, Val(cTpExcl) )
		lHistLoop := .T.
	EndIf

Return

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} loadViewBen
@author Fabio Santos de Mendonça
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function loadViewBen()

	FWMsgRun(,{||viewBen()},,STR0040) //"Executando Rotina do Beneficiário..."

Return

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} viewBen
@author Fabio Santos de Mendonça
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Static Function viewBen()

	Local nOperation 	:= MODEL_OPERATION_VIEW
	Local aEvento    	:= {}
	Local cNomeve	 	:= ""
	Local cTitulo    	:= ""
	Local nRecno 	 	:= ""
	Local cFuncao	 	:= ""

	cNomeve		:= Substr(V73->V73_NOMEVE,1,1) + "-" + Substr(V73->V73_NOMEVE,2)
	cTitulo		:= Iif(V73->V73_EVENTO == 'I',"Cadastro do Beneficiário", Iif(V73->V73_EVENTO == 'I',"Evento de Alteração",;
								Iif(V73->V73_EVENTO == 'A',"Informações do Beneficiário","Exclusão do Evento")))
	nRecno		:= V73->(recno())

	aEvento := TAFRotinas(V73->(cNomeve),4,.F.,2)
	
	DbSelectArea(aEvento[3])
	(aEvento[3])->(DbGoTo(nRecNo))
	
	cFuncao := aEvento[1]

	If !Empty(cFuncao)
		FWExecView(cTitulo,cFuncao,nOperation,, {|| .T. } )
	EndIf

Return

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} loadChangeHistory
@author Fabio Santos de Mendonça
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function loadChangeHistory()

	Private lHistLoop := .T.

	FWMsgRun(,{|| &("xNewHisAlt( 'V73', 'TAFA588')")},,STR0040) //"Executando Rotina do Beneficiário..."

Return 


//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} XmlLote588
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function XmlLote588()

	Local lLGPDperm := IIf(FindFunction("PROTDATA"),ProtData(),.T.)

	If lLGPDperm
		FWMsgRun(,{||OptXmlLote()},,STR0040) //"Executando Rotina do Beneficiário..."
	EndIf

Return

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc} OptXmlLote
@author Lucas A. dos Passos, Veronica de Almeida
@since 23/09/2021
@version 1.0
/*/
//----------------------------------------------------------------------------------------------
Function OptXmlLote()

	Local aOpcoes := {}
	Local nOpc    := 0
	Local cTitulo := "Geração de XML em Lote"

	aAdd(aOpcoes,STR0008) 
	aAdd(aOpcoes,STR0009) 

	nOpc := TAF588Options(aOpcoes, cTitulo)

	If nOpc == 5  //2400
		TAFXmlLote( 'V73', 'S-2400' , 'evtCdBenefIn' , 'TAF589Xml',,IIF( Type("oBrw") <> "U",oBrw,Nil) )
	ElseIf nOpc == 6  //2405
		TAFXmlLote( 'V73', 'S-2405' , 'evtCdBenefAlt' , 'TAF590Xml', ,iIf( Type("oBrw") <> "U",oBrw,Nil) )
	EndIf
	
Return
