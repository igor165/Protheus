#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFA591.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA591
Funcao generica MVC do model - Cadastro de Benef�cio

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA591()

	Local aCamposV75  := xFunGetSX3( 'V75' , ,.T.)
	Local aOnlyFields := {}
	Local aLegend     := {}
	Local nI          := 0

	Private oBrw      := FWmBrowse():New()

	//��������������������������������������������������������������������������������Ŀ
	//� Preenchendo array com Nomes de Campos de todos os campos usados da tabela V75  �
	//����������������������������������������������������������������������������������
	For nI := 1 to Len( aCamposV75 )
		AAdd( aOnlyFields, aCamposV75[nI][2] )
	Next nI

	If FindFunction( "FilCpfNome" ) .And. GetSx3Cache("V75_CPFBEN","X3_CONTEXT") == "R" .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES")

		aAdd(aLegend, {"V75_EVENTO  == 'I'"							, "GREEN" 	, STR0001	} )	//"In�cio do Benef�cio (S-2410)"	
		aAdd(aLegend, {"V75_EVENTO  == 'A'"							, "YELLOW" 	, STR0002   } )	//"Benef�cio Retificado"
        aAdd(aLegend, {"V75_EVENTO  == 'E' .AND. V75_STATUS == '6'"	, "ORANGE" 	, STR0003  	} )	//"Benef�cio Exclu�do - Pendente de Transmiss�o"
		aAdd(aLegend, {"V75_EVENTO  == 'E' .AND. V75_STATUS == '7'"	, "RED" 	, STR0004	} )	//"Benef�cio Exclu�do"

		TafNewBrowse( "S-2410", "V75_DTINBE", , 2, STR0005, aOnlyFields, 2, 2, aLegend) //"Cadastro de Benef�cio"

	Else
    
		If TafAtualizado()

			//���������������������������������������������������������������������������������������������Ŀ
			//� Verifico se o dicion�rio do cliente est� compat�vel com a vers�o de reposit�rio que possui  �
			//�����������������������������������������������������������������������������������������������
			If TAFAlsInDic( "V75" )

				oBrw:SetDescription( STR0005 )	//"Cadastro de Benef�cio"
				oBrw:SetAlias( 'V75' )
				oBrw:SetMenuDef( 'TAFA591' )
				oBrw:SetCacheView( .F. )
				oBrw:DisableDetails()

				If FindFunction('TAFSetFilter')
					oBrw:SetFilterDefault(TAFBrwSetFilter("V75","TAFA591","S-2410"))
				Else
					oBrw:SetFilterDefault( "V75_ATIVO == '1'" ) //Filtro para que apenas os registros ativos sejam exibidos ( 1=Ativo, 2=Inativo )
				EndIf

				oBrw:AddLegend("V75_EVENTO  == 'I'", "GREEN" 	, STR0001  	)	//"In�cio do Benef�cio (S-2410)"	
				oBrw:AddLegend("V75_EVENTO  == 'R'", "YELLOW" 	, STR0002  	)	//"Benef�cio Retificado"
				oBrw:AddLegend("V75_EVENTO  == 'A'", "ORANGE" 	, STR0006  	)	//"Benef�cio Alterado (S-2416)"
				oBrw:AddLegend("V75_EVENTO  == 'T'", "BLACK" 	, STR0007 	)	//"T�rmino do Benef�cio (S-2420)"
				oBrw:AddLegend("V75_EVENTO  == 'E'", "RED" 	    , STR0004   )	//"Benef�cio Exclu�do"
				oBrw:AddLegend("V75_EVENTO  == 'V'", "WHITE" 	, STR0008  	)	//"Benef�cio Reativado (S-2418)"

				oBrw:Activate()

			Else

				Aviso( STR0009, TafAmbInvMsg(), { STR0010 }, 2 ) //##"Dicion�rio Incompat�vel" ##"Encerrar"

			EndIf

		EndIf

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotAfa  := Nil
	Local aRotExcl := {}
	Local aRotina  := {}

	lMenuDIf := Iif( Type( "lMenuDIf" ) == "U", .F., lMenuDIf )

	If FindFunction("FilCpfNome") .And. GetSx3Cache("V75_CPFBEN","X3_CONTEXT") == "R" .AND. !FwIsInCallStack("TAFPNFUNC") .AND. !FwIsInCallStack("TAFMONTES") .And. !lMenuDIf

		aRotAfa := Array(4,4)

		aRotAfa[1] := {STR0011	, "TafAltBen()", 0, 4}	//"Alterar/Retificar"
		aRotAfa[2] := {STR0012	, "InclS2416()", 0, 4}	//"Alterar Benef�cio (S-2416)"
		aRotAfa[3] := {STR0013	, "InclS2418()", 0, 4}	//"Reativar Benef�cio (S-2418)"
		aRotAfa[4] := {STR0007	, "InclS2420()", 0, 4}	//"T�rmino do Benef�cio (S-2420)"

		ADD OPTION aRotina TITLE STR0014 ACTION "TAF591CarVis"		OPERATION 2 ACCESS 0 //"Visualizar"
		ADD OPTION aRotina TITLE STR0015 ACTION "InclS2410"			OPERATION 3 ACCESS 0 //"Incluir"
		ADD OPTION aRotina TITLE STR0016 ACTION aRotAfa 			OPERATION 4 ACCESS 0 //"Alterar"
		ADD OPTION aRotina TITLE STR0017 ACTION 'VIEWDEF.TAFA261'	OPERATION 8 ACCESS 0 //'Imprimir'

	EndIf

	If (lMenuDIf .And. cModulo <> "CFG" .And. IsInCallStack("TAF591CarrHis"))

		If cModulo != "CFG"
			ADD OPTION aRotina TITLE STR0014 ACTION "TAF591CarVis"		OPERATION 2 ACCESS 0 //"Visualizar"
		EndIf

		// Verifica se contempla eventos extemporaneos
		If FindFunction( "TafxExtemp" ) .And. TafxExtemp()

			ADD OPTION aRotina Title STR0018	Action "TAF591AltExt('A')" 		OPERATION 3 ACCESS 0 //"Inclus�o Extp."
			ADD OPTION aRotina Title STR0019 	Action "TAF591AltExt('R')" 		OPERATION 4 ACCESS 0 //"Retifica��o Extp."
			ADD OPTION aRotina Title STR0020 	Action "" 						OPERATION 5 ACCESS 0 // vda "Excluir Extp."
			ADD OPTION aRotina Title STR0021	Action "xFunAltRec('V75')"		OPERATION 3 ACCESS 0 //"Ajuste de Recibo"

			//Grupo de op��es para exclus�o
			Aadd(aRotExcl,{STR0022	, "TAF591ExcExt('E','1')"	, 0, 3, 0, Nil, Nil, Nil} ) // vda "Excluir Registro"
			Aadd(aRotExcl,{STR0023	, "TAF591ExcExt('E','2')"	, 0, 5, 0, Nil, Nil, Nil} ) // vda "Desfazer Exclus�o"
			Aadd(aRotExcl,{STR0024	, "TAF591ExcExt('E','3')"	, 0, 2, 0, Nil, Nil, Nil} ) // vda "Visualizar Registro de Exclus�o"

			aRotina[4][2] := aRotExcl

		EndIf

	EndIf

Return( aRotina )

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@Return Nil

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

Return ( Nil )

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@Return Nil

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} InclS2410
Fun�ao que realiza a Inclus�o do Cadastro do Benef�cio (S-2410)

@Return 

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Function InclS2410()

	FWMsgRun(,{||FWExecView( STR0025, "TAFA592", 3,,{||.T.} )},, STR0026)	//##"Inclus�o do Benef�cio"#"Executando ... "

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} InclS2416
Fun�ao que realiza a Altera��o do Cadastro do Benef�cio (S-2416)

@Return 

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Function InclS2416()

	Local cMsgErr := ""
	Local cEvent  := "S2416"

	cMsgErr := TAF591VldInc(cEvent)

	If Empty(cMsgErr)

		FWMsgRun(,{||TAF591CarModel( STR0027, "TAFA593", 3, 13 )}, , STR0026) //##"Cadastro de Benef�cio - Altera��o"#"Executando ... "

	Else

		MsgAlert(cMsgErr)	

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} InclS2418
Fun�ao que realiza a Inclus�o do Cadastro do Benef�cio (S-2418)

@Return 

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Function InclS2418()

	Local cMsgErr := ""
	Local cEvent  := "S2418"

	cMsgErr := TAF591VldInc(cEvent)

	If Empty(cMsgErr)

		FWMsgRun(,{||TAF591CarModel( STR0028, "TAFA594", 3, 14)} , , STR0026) //##"Inclus�o de Reativa��o de Benef�cio"#"Executando ... "

	Else

		MsgAlert(cMsgErr)	

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} InclS2420
Fun�ao que realiza a Inclus�o do T�rmino Cadastro do Benef�cio (S-2420)

@Return 

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Function InclS2420()

	Local cMsgErr := ""
	Local cEvent  := "S2420"
	Local lRet    := .F.

	cMsgErr := TAF591VldInc(cEvent)

	If Empty(cMsgErr)

		FWMsgRun(,{||TAF591CarModel( STR0029, "TAFA595", 3, 15 )} , , STR0026) //##"Cadastro de Benef�cio - T�rmino"#"Executando ... "
		lRet := .T.

	Else

		MsgAlert(cMsgErr)	

	EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} xCarrVisul

Funcao para carregar a visualiza��o do cadastro do Benef�cio

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF591CarVis()

	Local nOperation := MODEL_OPERATION_VIEW
	Local aEvento    := {}
	Local aOpcoes	 := {}
	Local cNomeve	 := ""
	Local nRecno 	 := ""
	Local cTitulo    := STR0030	//"Visualiza��o do Cadastro"
	Local cMens	   	 := STR0031	//"Selecione o tipo de visualiza��o que deseja realizar:"
	Local cFuncao	 := ""

	If FWIsInCallStack("XFUNNEWHIS")// Quando for chamado pelo hist�rico de altera��es

		cNomeve	:= Substr((cAliasBen)->(NOMEVE),1,1) + "-" + Substr((cAliasBen)->(NOMEVE),2)
		nRecno	:= (cAliasBen)->(RECNO)

		aEvento := TAFRotinas((cAliasBen)->(cNomeve),4,.F.,2)

		DbSelectArea(aEvento[3])
		(aEvento[3])->(DbGoTo(nRecNo))
		cFuncao := aEvento[1]

	Else // Quando for chamado pelo bot�o de visualizar

		If Alltrim(V75->V75_NOMEVE) $ "S2410"

			aOpcoes := TAF591Events()

			nOpc := TAF591OptBen(aOpcoes, , cTitulo, cMens )

			If nOpc == 9 //S2410
				cFuncao := "TAFA592"
			ElseIf nOpc == 10 //S2416
				cFuncao := "TAFA593"
			ElseIf nOpc == 11 //S2418
				cFuncao := "TAFA594"
			ElseIf nOpc == 12 //S2420
				cFuncao := "TAFA595"
			EndIf

		EndIf

	EndIf

	If !Empty(cFuncao)
		FWExecView(cTitulo, cFuncao, nOperation, , {|| .T. } )
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafAltBen

Funcao utilizada para Alterar\Retificar um registro no cadastro do Benef�cio

@Param:
@Return:

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafAltBen()

	FWMsgRun(,{||TAF591AltBen()},,STR0032) //"Executando Rotina ..."

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA591
Funcao generica MVC do model - Cadastro de Benef�cio

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF591Xml()

	Local aOpcoes     := {}
	Local cAlias      := ""
	Local cFilBkp     := cFilAnt
	Local cFuncXML    := ""
	Local cMens       := STR0033 //"Selecione o Evento"
	Local cTitulo     := STR0034 //"Gera��o de XML"
	Local nOpc        := 0
	Local nRecno      := 0
	Local nRecnoHist  := 0

	Default cFunction := ""

	cFilAnt := Iif( IsInCallStack("TafNewBrowse") .And. ( V75->V75_FILIAL <> cFilAnt ), V75->V75_FILIAL, cFilAnt)

	If FwIsInCallStack("xNewHisAlt")

		cFunction := "xNewHisAlt"
		nRecnoHist := (cAliasHist)->RECNO

		If RetUltAtv( "V76", V75->V75_ID + "1", 1, .T., cFunction, nRecnoHist, "_DALTBE" )
			aAdd( aOpcoes, STR0035 )	//"S-2416 Benef�cio - Altera��o"
		ElseIf RetUltAtv("V77", V75->V75_ID + "1", 1, .T., cFunction, nRecnoHist, "_DTREAT" )
			aAdd( aOpcoes, STR0036 )	//"S-2418 Reativa��o de Benef�cio"
		ElseIf RetUltAtv("V78", V75->V75_ID + "1", 1, .T., cFunction, nRecnoHist, "_DTTERM" )
			aAdd( aOpcoes, STR0037 )	//"S-2420 Benef�cio - T�rmino"
		EndIf

	Else

		aOpcoes := TAF591Events()

	EndIf

	nOpc := TAF591OptBen(aOpcoes, , cTitulo, cMens )

	If nOpc == 9 //S2410
		cFuncXML := "TAF592"
		cAlias   := "V75"
		nRecno   := V75->(RECNO())
	ElseIf nOpc == 10 //S2416
		cFuncXML := "TAF593"
		cAlias   := "V76"
		nRecno   := V76->(RECNO())
	ElseIf nOpc == 11 //S2418
		cFuncXML := "TAF594"
		cAlias   := "V77"
		nRecno   := V77->(RECNO())
	ElseIf nOpc == 12 //S2420
		cFuncXML := "TAF595"
		cAlias   := "V78"
		nRecno   := V78->(RECNO())
	EndIf

	If nOpc > 0

		FWMsgRun(,{|| &(cFuncXML + "Xml( cAlias, nRecno, .F. )") },, STR0032) //"Executando Rotina ..."

	EndIf

	cFilAnt := cFilBkp

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF591CarrHis

Funcao para carregar a tela de hist�rico de altera��o.

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF591CarrHis()

	Local cAliasBen   := ''

	Private lHistLoop := .T.

	If !IsBlind()
		FWMsgRun(,{|| cAliasBen := TAF591HisAlt()},, STR0032) // "Executando Rotina ..."
	Else
		cAliasBen := TAF591HisAlt()
	EndIf

Return cAliasBen

//-------------------------------------------------------------------
/*/{Protheus.doc} AltBen

Funcao utilizada para Alterar\Retificar um registro no cadastro do Benef�cio

@Param:
@Return:

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF591AltBen()

	Local aOpcAlt    := {}
	Local aOpcoes    := {}
	Local cFilBkp    := cFilAnt
	Local cMsgErr    := ""
	Local cNomEvV75  := ""
	Local cStat2416  := ""
	Local cStat2418  := ""
	Local cStat2420  := ""
	Local cTitulo    := ""
	Local lExist2416 := .F.
	Local lExist2418 := .F.
	Local lExist2420 := .F.
	Local nExView    := -1
	Local x          := 0

	Private ALTERA
	Private INCLUI

	cFilAnt     := Iif( IsInCallStack("TafNewBrowse") .And. ( V75->V75_FILIAL <> cFilAnt ), V75->V75_FILIAL, cFilAnt)
	cStaEvV75	:= V75->V75_STATUS
	cNomEvV75	:= V75->V75_NOMEVE
	cVerAnt  	:= V75->V75_VERANT
	cChvVAnt 	:= V75->( V75_ID + V75_VERANT ) + cNomEvV75
	cTitulo  	:= "Altera��o de Cadastro"
	cMens		:= "Selecione o evento que deseja alterar:"

	aOpcoes := TAF591Events("TAF591AltBen")

	For x := 1 To Len(aOpcoes)

		aAdd(aOpcAlt, aOpcoes[x][1])

		If !Empty(aOpcoes[x][2])
			If aOpcoes[x][2] == "S-2416"
				cStat2416  := aOpcoes[x][3]
				lExist2416 := aOpcoes[x][4]
			ElseIf aOpcoes[x][2] == "S-2418"
				cStat2418  := aOpcoes[x][3]
				lExist2418 := aOpcoes[x][4]
			ElseIf aOpcoes[x][2] == "S-2420"
				cStat2420  := aOpcoes[x][3]
				lExist2420 := aOpcoes[x][4]
			EndIf
		EndIf

	Next

	nOption:= TAF591OptBen( aOpcAlt, cNomEvV75, cTitulo, cMens )

	cMsgErr := TAF591MsgErr( nOption, aOpcoes )

	If Empty(cMsgErr)

		If nOption == 1 .Or. nOption == 2

			INCLUI := .F.
			ALTERA := .T.

			If RetUltAtv('V75', V75->V75_ID + "1", 1, IiF(nOption == 2 .or. nOption == 1, .T., .F.))

				FWMsgRun(,{||nExView:=FWExecView("Altera��o do Cadastro de Benef�cio - In�cio", "TAFA592", MODEL_OPERATION_UPDATE, ,{||.T.} )}, , "Executando Rotina do Cadastro do Benef�cio... ")
						
			EndIf

		ElseIf nOption == 3 .Or. nOption == 4

			INCLUI := .F.
			ALTERA := .T.

			If RetUltAtv('V76', V76->V76_ID + "1", 1, IiF(nOption == 4 .or. nOption == 3, .T., .F.))

				FWMsgRun(,{||nExView:=FWExecView("Altera��o do Cadastro de Benef�cio - Altera��o", "TAFA593", MODEL_OPERATION_UPDATE, ,{||.T.} )}, , "Executando Rotina do Cadastro do Benef�cio... ")
						
			EndIf

		ElseIf nOption == 5 .Or. nOption == 6

			INCLUI := .F.
			ALTERA := .T.

			If RetUltAtv('V77', V77->V77_ID + "1", 1, IiF(nOption == 5 .or. nOption == 6, .T., .F.))

				FWMsgRun(,{||nExView:=FWExecView("Altera��o do Cadastro de Reativa��o de Benef�cio", "TAFA594", MODEL_OPERATION_UPDATE, ,{||.T.} )}, , "Executando Rotina do Cadastro do Benef�cio... ")
						
			EndIf

		ElseIf nOption == 7 .Or. nOption == 8

			INCLUI := .F.
			ALTERA := .T.

			If RetUltAtv('V78', V78->V78_ID + "1", 1, IiF(nOption == 8 .or. nOption == 7, .T., .F.))

				FWMsgRun(,{||nExView:=FWExecView("Altera��o do Cadastro de Benef�cio - T�rmino", "TAFA595", MODEL_OPERATION_UPDATE, ,{||.T.} )}, , "Executando Rotina do Cadastro do Benef�cio... ")
						
			EndIf

		EndIf

	Else

		MsgAlert(cMsgErr)

	EndIf

	cFilAnt := cFilBkp

Return nExView

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA591
Funcao onde valido quais eventos existem para o registro posicionado

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF591Events( cFunction )

	Local aOpcoes     := {}
	Local cFilBkp     := cFilAnt
	Local cId         := V75->V75_ID

	Default cFunction := ""

	cFilAnt := Iif( IsInCallStack("TafNewBrowse") .And. ( V75->V75_FILIAL <> cFilAnt ), V75->V75_FILIAL, cFilAnt)

	If RetUltAtv("V75", cId + "1", 1, .T.)

		If cFunction == "TAF591AltBen"

			If V75->V75_STATUS == "4"
				aAdd(aOpcoes, { STR0043, "S-2410", V75->V75_STATUS, .T. } )	//"S-2410 Retificar Cadastro de Benef�cio - In�cio"
			Else 
				aAdd(aOpcoes, { STR0042, "S-2410", V75->V75_STATUS, .T. } )	//"S-2410 Alterar Cadastro de Benef�cio - In�cio"
			EndIf

		Else

			aAdd(aOpcoes, STR0050 )	//"S-2410 Benef�cio - In�cio"

		EndIf

	EndIf

	If RetUltAtv( 'V76', cId + "1", 1, .T.)

		If cFunction == "TAF591AltBen"

			If V76->V76_STATUS == "4"
				aAdd(aOpcoes, { STR0045, "S-2416", V76->V76_STATUS, .T. } )	//"S-2416 Retificar Cadastro de Benef�cio - Altera��o"
			Else
				aAdd(aOpcoes, { STR0044, "S-2416", V76->V76_STATUS, .T. } )	//"S-2416 Alterar Cadastro de Benef�cio - Altera��o"
			EndIf

		Else

			aAdd(aOpcoes, STR0035 )	//"S-2416 Benef�cio - Altera��o"

		EndIf

	EndIf

	If RetUltAtv("V77", cId + "1", 1, .T.)

		If cFunction == "TAF591AltBen"

			If V77->V77_STATUS == "4"
				aAdd(aOpcoes, { STR0047, "S-2418", V77->V77_STATUS, .T. } )	//"S-2418 Retificar Cadastro de Reativa��o de Benef�cio"
			Else
				aAdd(aOpcoes, { STR0046, "S-2418", V77->V77_STATUS, .T. } )	//"S-2418 Alterar Cadastro de Reativa��o de Benef�cio"
			EndIf

		Else

			aAdd(aOpcoes, STR0036 )	//"S-2418 Reativa��o de Benef�cio"

		EndIf

	EndIf

	If RetUltAtv("V78", cId + "1", 1, .T.)

		If cFunction == "TAF591AltBen"

			If V78->V78_STATUS == "4"
				aAdd(aOpcoes, { STR0049, "S-2418", V78->V78_STATUS, .T. } )	//"S-2420 Retificar Cadastro de Benef�cio - T�rmino"
			Else
				aAdd(aOpcoes, { STR0048, "S-2418", V78->V78_STATUS, .T. } )	//"S-2420 Alterar Cadastro de Benef�cio - T�rmino"
			EndIf

		Else

			aAdd(aOpcoes, STR0037 )	//"S-2420 Benef�cio - T�rmino"

		EndIf

	EndIf

	cFilAnt := cFilBkp

Return aOpcoes

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAF591OptBen
Cria tela com op��es em um Radio para o usu�rio selecionar
aOpcoes - Array com as op��es que ser�o apresentadas para o usu�rio

@Return 
nOpc - N�mero referente a op��o selecionada pelo usu�rio
cNomEvt - Nome do evento do cadastro do trabalhador S2410, S2416, S2418 ou S2420
cTpTela - Utilizado para definir o tamanho e o formato da tela a ser construida
cTpTela -> Tipo de Tela que cont�m as op��es.
	   2 -> XML
	   3 -> VLD
	  "" -> Inclus�o do Evento do Trabalhador	 
cTitulo - Titulo da Tela

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0
/*/
//----------------------------------------------------------------------------
Function TAF591OptBen(aOpcoes, cNomEvt, cTitulo, cMens, lOk )

	Local oDlg         := Nil
	Local oRadio       := Nil
	Local oTBok        := Nil
	Local oTBSair      := Nil
	Local nOpc         := 0
	Local nLinFrom     := 0
	Local nColFrom     := 0
	Local nLinBtOk     := 0
	Local nColBtOk     := 0
	Local nLinBtSair   := 0
	Local nColBtSair   := 0
	Local nLinToMult   := 0
	Local nColToMult   := 0
	Local nLinFrMult   := 0
	Local nColFrMult   := 0

	Private oTMultiget := Nil
	Private oFont1     := TFont():New("MS Sans SerIf", 0, -14, , .F., 0, , 700, .F., .F., , , , , ,)
	Private oSay1      := Nil

	Default cTpTela    := '1'
	Default cTitulo    := STR0038	//"Benef�cio" 
	Default cMens      := STR0039	//"Selecione"
	Default lOk        := .F.

	nLinTo     := 680
	nColTo     := 1192
	nLinFrom   := 428
	nColFrom   := 741
	nLinBtSair := 100
	nColBtSair := 130
	nLinBtOk   := 100
	nColBtOK   := 058
	nSayCol    := 035
	nLinToMult := 70
	nColToMult := 01
	nLinFrMult := 350
	nColFrMult := 52

	DEFINE DIALOG oDlg TITLE cTitulo FROM nLinFrom,nColFrom TO nLinTo,nColTo PIXEL STYLE DS_MODALFRAME

		oDlg:lEscClose := .F.

		oRadio := TRadMenu():New (30, 25, aOpcoes, , oDlg, , , , , , , , 150, 32, , , , .T.)

		oRadio:bSetGet := {|u|Iif (PCount()==0,nOpc, nOpc := Taf591Opc(aOpcoes,u))}

		oTBok	:= TButton():New( nLinBtOk  , nColBtOk	, STR0040	, oDlg, {||@lOk := .T.	, oDlg:End()}, 37,12,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Confirmar"
		oTBSair	:= TButton():New( nLinBtSair, nColBtSair, STR0041	, oDlg, {||nOpc:=0		, oDlg:End()}, 37,12,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Sair"

	ACTIVATE DIALOG oDlg CENTERED

Return nOpc

//----------------------------------------------------------------------
/*/{Protheus.doc} Taf591Opc
Retorna o n�mero da op��o selecionada pelo usu�rio 

Como o Array aOpcoes � din�mico utilizo a fun��o Taf591Opc para definir 
um n�mero para	 cada uma das op��es poss�veis, retornando o n�mero 
correspondente a op��o selecionada.

aOpcoes -> Array com as op��es dispon�veis na Tela
nOpc 	 -> Op��o selecionada
cTpTela -> Tipo de Tela que cont�m as op��es.
	   2 -> XML
	   3 -> VLD
	  "" -> Inclus�o do Evento do Trabalhador	
@Return nOpc

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0
/*/
//-----------------------------------------------------------------------
Static Function Taf591Opc( aOpcoes, nOpc, cTpTela )

	Local nOpcRet   := 0
	Local cEvento   := aOpcoes[nOpc]

	Default aOpcoes := {}
	Default nOpc    := 0
	Default cTpTela := ""

	// Altera��o/Retifica��o
	If cEvento $  STR0042		//"S-2410 Alterar Cadastro de Benef�cio - In�cio"
		nOpcRet := 1
	ElseIf cEvento $ STR0043 	//"S-2410 Retificar Cadastro de Benef�cio - In�cio" 
		nOpcRet := 2
	ElseIf cEvento $ STR0044 	//"S-2416 Alterar Cadastro de Benef�cio - Altera��o"
		nOpcRet := 3
	ElseIf cEvento $ STR0045 	//"S-2416 Retificar Cadastro de Benef�cio - Altera��o"
		nOpcRet := 4
	ElseIf cEvento $ STR0046 	//"S-2418 Alterar Cadastro de Reativa��o de Benef�cio"
		nOpcRet := 5
	ElseIf cEvento $ STR0047 	//"S-2418 Retificar Cadastro de Reativa��o de Benef�cio"
		nOpcRet := 6
	ElseIf cEvento $ STR0048 	//"S-2420 Alterar Cadastro de Benef�cio - T�rmino" 
		nOpcRet := 7
	ElseIf cEvento $ STR0049 	//"S-2420 Retificar Cadastro de Benef�cio - T�rmino" 
		nOpcRet := 8

	// Visualiza��o/Exclus�o/Desfazer Exclus�o/ Visualizar Exclus�o\ Gerar XML
	ElseIf cEvento $ STR0050	//"S-2410 Benef�cio - In�cio"
		nOpcRet := 9
	ElseIf cEvento $ STR0035 	//"S-2416 Benef�cio - Altera��o" 
		nOpcRet := 10
	ElseIf cEvento $ STR0036 	//"S-2418 Reativa��o de Benef�cio" 
		nOpcRet := 11
	ElseIf cEvento $ STR0037 	//"S-2420 Benef�cio - T�rmino"
		nOpcRet := 12
	EndIf

Return nOpcRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF591HisAlt
Fun�ao que carrega o array com os campos que ser�o mostrados na tela
de historico de altera��es

@Return 

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAF591HisAlt()

	Local cQry			:= ""
	Local aStru			:= {}
	Local nX			:= 0
	Local nY			:= 0
	Local aCampos		:= {}
	Local aHeaderT  	:= {}
	Local cRotina		:= "TAFA591"
	Local cTitulo		:= STR0051 + V75->V75_ID	//"Hist�rio de Altera��es do ID - "
	Local oTmpTab 		:= Nil

	Private cAliasBen	:= ""
	Private oDlgPrinc	:= nil

	Private lMenuDIf 	:= .T.

	aAdd(aCampos,{STR0052	,'FILIAL'		,TamSX3("V75_FILIAL")[1]	,'C','@!',0,	0})	//"Filial"
	aAdd(aCampos,{STR0053	,'DTEVEN'		,8							,'D',''  ,1,	2})	//"Data Evento"
	aAdd(aCampos,{STR0054	,'ID'			,TamSX3("V75_ID")[1]		,'C','@!',1,	0})	//"ID."
	aAdd(aCampos,{STR0055	,'DATASYS'		,8							,'D',''  ,1,	2})	//"Data Sistemica"
	aAdd(aCampos,{STR0056	,'STASEC'		,1							,'C',''  ,1,	0})	//"Status Secund�rio"
	aAdd(aCampos,{STR0057 	,'NOMEVE'		,TamSX3("V75_NOMEVE")[1]	,'C','@!',1,	0})	//"Nome Evento"
	aAdd(aCampos,{STR0058	,'EVENTO'		,TamSX3("V75_EVENTO")[1]	,'C','@!',1,	0})	//"Evento"
	aAdd(aCampos,{STR0059	,'CPFBEN'		,TamSX3("V75_CPFBEN")[1]	,'C','@!',1,	5})	//"CPF Benef."
	aAdd(aCampos,{STR0060	,'NRBENF'		,TamSX3("V75_NRBENF")[1]	,'C','@!',1,	5})	//"Nr. Benef�cio"
	aAdd(aCampos,{STR0061	,'NOME'		    ,TamSX3("V75_DBENEF")[1]	,'C','@!',1,	0})	//"Nome"
	aAdd(aCampos,{STR0062	,'VERSAO'		,TamSX3("V75_VERSAO")[1]	,'C','@!',1,	0})	//"Vers�o"
	aAdd(aCampos,{STR0063	,'ALIASTAB'	    ,3							,'C',''  ,1,	0})	//"AliasTab"
	aAdd(aCampos,{STR0064	,'RECNO'		,10							,'N',''  ,1,	0})	//"RecNo"
	aAdd(aCampos,{STR0065	,'STATUS'		,1							,'C','@' ,1,	0})	//"Status de Transmiss�o"
	aAdd(aCampos,{STR0066	,'ATIVO'		,1							,'C','@' ,1,	0})	//"Ativo"

	For nX := 1 To Len(aCampos)
		aAdd(aStru,{ aCampos[nX][2]	, aCampos[nX][4], aCampos[nX][3], 0})
	Next nX

	cQry := ChangeQuery(TAF591Qry())
	TCQuery cQry New Alias 'cAliasSelec'

	cAliasBen := GetNextAlias()
	oTmpTab := FWTemporaryTable():New(cAliasBen, aStru)

	oTmpTab:AddIndex("1",{"EVENTO"})
	oTmpTab:AddIndex("2",{"DTEVEN","DATASYS"})
	oTmpTab:AddIndex("3",{"EVENTO","DTEVEN","DATASYS"})
	oTmpTab:Create()

	DbSelectArea(cAliasBen)
	(cAliasBen)->(DbSetOrder(2))
	(cAliasBen)->(DBGoTop())

	cAliasSelec->(dbGotop())

	nPosFld	:= aScan( aCampos, { |x| x[02] == 'NOME' } )
	nPosId	:= aScan( aCampos, { |x| x[02] == 'NOMEVE' } )

	While cAliasSelec->(!Eof())

		RecLock((cAliasBen),.T.)

		For nX := 1 To Len(aCampos)

			If nX == nPosFld
				(cAliasBen)->&(aCampos[nX][2]) := TafNameBen( xFilial("V75"), , cAliasSelec->CPFBEN, cAliasSelec->ID, .F. ) //Tratamento feito para os eventos que possuem campo _NOME como virtual
			Else
				If aCampos[Nx][04] == "D"
					(cAliasBen)->&(aCampos[nX][2]) := Stod(cAliasSelec->&(aCampos[nX][2]))
				Else
					(cAliasBen)->&(aCampos[nX][2]) := cAliasSelec->&(aCampos[nX][2])
				EndIf
			EndIf

		Next nX

		(cAliasBen)->(MsUnlock())
		cAliasSelec->(dbSkip())

	EndDo

	cAliasSelec->(dbCloseArea())

	//=================================+
	// Cria Colunas para o Browse	   ||
	//=================================+
	For nX := 1 To Len (aCampos)

		If !aCampos[nX][2] $ ("VERSAO|RECNO|EVENTO|ALIASTAB|STASEC")

			nY++
			aAdd(aHeaderT,FWBrwColumn():New())

			If 	aCampos[nX][7] <> 0
				nPosTamCol := 7
			Else
				nPosTamCol := 3
			EndIf

			If aCampos[nX][2] == "STATUS"
				aHeaderT[nY]:SetData( &("{||TAF591Sts((cAliasBen)->"+aCampos[nX][2]+")}") )
				aHeaderT[nY]:SetSize(30)
			ElseIf aCampos[nX][2] == "ATIVO"
				aHeaderT[nY]:SetData( &("{||TAF591Atv((cAliasBen)->"+aCampos[nX][2]+")}") )
				aHeaderT[nY]:SetSize(10)
			Else
				aHeaderT[nY]:SetData( &("{||(cAliasBen)->"+aCampos[nX][2]+"}") )
				aHeaderT[nY]:SetSize( aCampos[nX][nPosTamCol])
			EndIf

			aHeaderT[nY]:SetTitle(aCampos[nX][1])
			aHeaderT[nY]:SetType(aCampos[nX][4])
			aHeaderT[nY]:SetDecimal(0)
			aHeaderT[nY]:SetPicture(aCampos[nX][5])
			aHeaderT[nY]:SetAlign(aCampos[nX][6])

		EndIf

	Next nX

	//Chamo a Browse do Hist�rico
	If FWIsInCallStack("TafNewBrowse")
		If !IsBlind()
			If FindFunction( "xFunNewHis" )
				xFunNewHis( cAliasBen, cRotina, aHeaderT, cTitulo, .F., .T.)
			Else
				xFunHisAlt( cAliasBen, cRotina, aHeaderT, cTitulo, .T. )
			EndIf
		EndIf
	EndIf

Return aHeaderT

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF591Sts
Fun�ao que carrega o array com os campos que ser�o mostrados na tela
de historico de altera��es

@Return 

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAF591Sts(cStatus)

	Local cRetStatus := ""

	Do Case

		Case Empty(cStatus)
			cRetStatus = STR0067 //"AGUARDANDO PROCESSAMENTO"
		Case  cStatus == "0"
			cRetStatus = STR0068 //"V�LIDO"
		Case cStatus == "1"
			cRetStatus = STR0069 //"INV�LIDO"
		Case cStatus == "2"
			cRetStatus = STR0070 //"TRANSMITIDO (AGUARDANDO RETORNO)"
		Case cStatus == "3"
			cRetStatus = STR0071 //"TRANSMITIDO INV�LIDO"
		Case cStatus == "4"
			cRetStatus = STR0072 //"TRANSMITIDO V�LIDO"
		Case cStatus == "6"
			cRetStatus = STR0073 //"PENDENTE DE EXCLUS�O"
		Case cStatus == "7"
			cRetStatus = STR0074// "EXCLUS�O EFETIVADA"

	End Case

Return cRetStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF591Atv
Fun�ao que carrega o array com os campos que ser�o mostrados na tela
de historico de altera��es

@Return 

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAF591Atv(cAtivo)

	Local cRet := ""

	If cAtivo == "1"
		cRet = STR0066 //"Ativo"
	Else
		cRet = STR0075 //"Inativo"
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF591Qry
Funcao para retornar a query utilizada na sele��o do hist�rico das
altera��es do trabalhador.

@Return 

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF591Qry(cIdBen)

	Local cFilBen  := V75->V75_FILIAL
	Local cQry     := ''

	Default cIdBen := V75->V75_ID

	cQry += " SELECT V75_FILIAL AS FILIAL, V75_ID AS ID, V75_NOMEVE AS NOMEVE, V75_EVENTO AS EVENTO, V75_CPFBEN AS CPFBEN, V75_NRBENF AS NRBENF, "
	cQry += " V75_VERSAO AS VERSAO, V75_MATRIC AS MATRIC, V75.R_E_C_N_O_ AS RECNO, V75_STATUS AS STATUS, V75_ATIVO AS ATIVO, '' AS DTEVEN, "
	cQry += " V75_STASEC AS STASEC, V75_DINSIS AS DATASYS, 'V75' AS ALIASTAB, '' AS NOME "
	cQry += " FROM " + RetSqlName("V75") + " V75 "
	cQry += " WHERE V75_FILIAL = '" + cFilBen + "' "
	cQry += " AND V75_ID = '" + cIdBen + "' "
	cQry += " AND V75_ATIVO = '1' "
	cQry += " AND V75.D_E_L_E_T_ = '' "

	cQry += " UNION "

	cQry += " SELECT V76_FILIAL AS FILIAL, V76_ID AS ID, V76_NOMEVE AS NOMEVE, V76_EVENTO AS EVENTO, V76_CPFBEN AS CPFBEN, V76_NRBENF AS NRBENF, "
	cQry += " V76_VERSAO AS VERSAO, '' AS MATRIC, V76.R_E_C_N_O_ AS RECNO, V76_STATUS AS STATUS, V76_ATIVO AS ATIVO, V76_DALTBE AS DTEVEN, " 
	cQry += " V76_STASEC AS STASEC, V76_DINSIS AS DATASYS, 'V76' AS ALIASTAB, '' AS NOME " 
	cQry += " FROM " + RetSqlName("V76") + " V76 " 
	cQry += " WHERE V76_FILIAL = '" + cFilBen + "' " 
	cQry += " AND V76_ID = '" + cIdBen + "' " 
	cQry += " AND V76_ATIVO = '1' " 
	cQry += " AND V76.D_E_L_E_T_ = '' " 

	cQry += " UNION "

	cQry += " SELECT V77_FILIAL AS FILIAL, V77_ID AS ID, V77_NOMEVE AS NOMEVE, V77_EVENTO AS EVENTO, V77_CPFBEN AS CPFBEN, V77_NRBENF AS NRBENF, " 
	cQry += " V77_VERSAO AS VERSAO, '' AS MATRIC, V77.R_E_C_N_O_ AS RECNO, V77_STATUS AS STATUS, V77_ATIVO AS ATIVO, V77_DTREAT AS DTEVEN, "  
	cQry += " V77_STASEC AS STASEC, V77_DINSIS AS DATASYS, 'V77' AS ALIASTAB, '' AS NOME "  
	cQry += " FROM  " + RetSqlName("V77") + " V77 "
	cQry += " WHERE V77_FILIAL = '" + cFilBen + "' "  
	cQry += " AND V77_ID = '" + cIdBen + "' "  
	cQry += " AND V77_ATIVO = '1' "  
	cQry += " AND V77.D_E_L_E_T_ = '' "  

	cQry += " UNION "

	cQry += " SELECT V78_FILIAL AS FILIAL, V78_ID AS ID, V78_NOMEVE AS NOMEVE, V78_EVENTO AS EVENTO,V78_CPFBEN AS CPFBEN, V78_NRBENF AS NRBENF, "  
	cQry += " V78_VERSAO AS VERSAO, '' AS MATRIC, V78.R_E_C_N_O_ AS RECNO, V78_STATUS AS STATUS, V78_ATIVO AS ATIVO, V78_DTTERM AS DTEVEN, "   
	cQry += " V78_STASEC AS STASEC, V78_DINSIS AS DATASYS, 'V78' AS ALIASTAB, '' AS NOME "   
	cQry += " FROM " + RetSqlName("V78") + " V78 "   
	cQry += " WHERE V78_FILIAL = '" + cFilBen + "' "   
	cQry += " AND V78_ID = '" + cIdBen + "' "   
	cQry += " AND V78_ATIVO = '1' "   
	cQry += " AND V78.D_E_L_E_T_ = '' "   
	cQry += " ORDER BY FILIAL, NOMEVE "

Return (cQry)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF591VldInc
Funcao para verificar se � poss�vel incluir um novo S-2416

@Return 

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF591VldInc(cEvent)

	Local cCPFBen     := ""
	Local cDtReat     := ""
	Local cDtTerm     := ""
	Local cDtTerm2410 := ""
	Local cDtTerm2418 := ""
	Local cFilBkp     := cFilAnt
	Local cMsgErr     := ""
	Local cNrBenf     := ""
	Local cProtPn     := ""
	Local cProtul     := ""

	Default cMsgErr   := ""
	Default oModel    := Nil

	cCPFBen := V75->V75_CPFBEN
	cNrBenf := V75->V75_NRBENF

	cFilAnt := Iif( IsInCallStack("TafNewBrowse") .And. ( V75->V75_FILIAL <> cFilAnt ), V75->V75_FILIAL, cFilAnt)

	If RetUltAtv("V75", V75->V75_ID + "1", 1, .T. )

		cProtul     := V75->V75_PROTUL
		cProtPn     := V75->V75_PROTPN
		cDtTerm2410 := V75->V75_DTTERM

		If !Empty(cProtul) .Or. ( Empty(cProtul) .And. !Empty(cProtPn) )

			If cEvent $ "S2416"

				If RetUltAtv("V76", V75->V75_ID + "1", 1, .T. )

					cProtul := V76->V76_PROTUL

					If Empty(cProtul)

						cMsgErr := STR0105 //"Existe um Cadastro de Benef�cio - Altera�ao (S-2416) sem transmitir para este registro."

					EndIf

				EndIf

			ElseIf cEvent $ "S2418"

				If RetUltAtv("V78", V75->V75_ID + "1", 1, .T. )

					cProtul 	:= V78->V78_PROTUL
					cDtTerm2418	:= V78->V78_DTTERM

					If !Empty(cProtul)

						If RetUltAtv("V77", V75->V75_ID + "1", 1, .T. )

							cProtul := V77->V77_PROTUL
							cDtReat := V77->V77_DTREAT

							If Empty(cProtul)

								cMsgErr := STR0106 //"Existe um Cadastro de Reativa��o de Benef�cio (S-2418) sem transmitir para este registro."

							Else

								If cDtReat > cDtTerm2418

									cMsgErr := STR0108 //"N�o foi encontrado um evento de T�rmino (S-2420) para o CPF e N�mero de Benef�cio informados"

								EndIf

							EndIf

						EndIf

					Else

						cMsgErr := STR0107 //"Existe um Cadastro de Benef�cio - T�rmino (S-2420) sem transmitir para este registro."

					EndIf

				ElseIf Empty(cDtTerm2410)
					
					cMsgErr := STR0108 //"N�o foi encontrado um evento de T�rmino (S-2420) para o CPF e N�mero de Benef�cio informados"

				EndIf

			ElseIf cEvent $ "S2420"

				If RetUltAtv("V78", V75->V75_ID + "1", 1, .T. )

					cProtul := V78->V78_PROTUL
					cDtTerm := V78->V78_DTTERM

					If Empty(cProtul)

						cMsgErr := STR0107 //"Existe um Cadastro de Benef�cio - T�rmino (S-2420) sem transmitir para este registro."

					Else

						If RetUltAtv("V77", V75->V75_ID + "1", 1, .T. )

							If cDtTerm > V77->V77_DTREAT

								cMsgErr := STR0109 //"Foi encontrado um Cadastro de Benef�cio - T�rmino (S-2420) sem Reativa��o de Beneficio (S-2418) para este registro."

							EndIf

						Else
							
							cMsgErr := STR0109 //"Foi encontrado um Cadastro de Benef�cio - T�rmino (S-2420) sem Reativa��o de Beneficio (S-2418) para este registro."

						EndIf

					EndIf

				EndIf

			EndIf

		Else

			cMsgErr := STR0110 //"N�o foi encontrado um Cadastro de Beneficio - Inclus�o (S-2410) transmitido para o registro posicionado"			

		EndIf

	EndIf

	cFilAnt := cFilBkp

Return cMsgErr

//----------------------------------------------------------------------
/*/{Protheus.doc} TAF591CarrModel
Funcao para carregar o modelo de dados que ser� inicializado junto 
com a fun��o FWExecView
@Parametros:
cTitulo    -> Titulo da Tela que ser� carregada.
cFunName   -> Nome da rotina do cadastro que ser� carregado
nOper	    -> N�mero da opera��o que ser� realizada (Inclus�o ou Altera��o)
cEvento	-> Tipo de Evento

@Return 
@Author Silas Gomes
@Since 17/09/2021
@Version 1.0
/*/
//-----------------------------------------------------------------------
Function TAF591CarModel( cTitulo, cFunName, nOper, nOpc ) 

	Local aCamposV76   := {}
	Local aCamposV77   := {}
	Local aCamposV78   := {}
	Local cFilbkp      := cFilAnt
	Local lExists2416  := .T.
	Local lExists2418  := .T.
	Local lExists2420  := .T.

	Private oModelLoad := Nil

	Default cTitulo    := ""
	Default cFunName   := ""
	Default nOper      := 1
	Default nOpc       := 1

	cFilAnt := Iif( IsInCallStack("TafNewBrowse") .And. ( V75->V75_FILIAL <> cFilAnt ), V75->V75_FILIAL, cFilAnt)

	oModelLoad := FWLoadModel(cFunName)
	oModelLoad:SetOperation(nOper)
	oModelLoad:Activate()

	If ( nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 13 )

		If !FwIsInCallStack("GOSETEXTEMP")

			lExists2416 := RetUltAtv( 'V76', V75->V75_ID + "1", 1, .T.  )

		EndIf

		If lExists2416

			oModelLoad:LoadValue( "MODEL_V76","V76_BENEF "	, V76->V76_BENEF	)
			oModelLoad:LoadValue( "MODEL_V76","V76_DBENEF "	, GatMatSST(V76->V76_BENEF,.T.,"V75",.T.))
			oModelLoad:LoadValue( "MODEL_V76","V76_TRABAL"	, V75->V75_TRABAL	)
			oModelLoad:LoadValue( "MODEL_V76","V76_DTRABA"	, GatMatSST(V76->V76_TRABAL,.T.,"V75")	)
			oModelLoad:LoadValue( "MODEL_V76","V76_CPFBEN"	, V76->V76_CPFBEN	)
			oModelLoad:LoadValue( "MODEL_V76","V76_NRBENF"	, V76->V76_NRBENF	)
			oModelLoad:LoadValue( "MODEL_V76","V76_TPBENE"	, V76->V76_TPBENE	)
			oModelLoad:LoadValue( "MODEL_V76","V76_TPPLAN"	, V76->V76_TPPLAN	)
			oModelLoad:LoadValue( "MODEL_V76","V76_DESC"	, V76->V76_DESC		)
			oModelLoad:LoadValue( "MODEL_V76","V76_INDSUS"	, V76->V76_INDSUS	)
			oModelLoad:LoadValue( "MODEL_V76","V76_TPPENS"	, V76->V76_TPPENS	)
			oModelLoad:LoadValue( "MODEL_V76","V76_MTSUSP"	, V76->V76_MTSUSP	)
			oModelLoad:LoadValue( "MODEL_V76","V76_DSCSUS"	, V76->V76_DSCSUS	)

		Else 

			oModelLoad:LoadValue( "MODEL_V76","V76_BENEF "	, V75->V75_BENEF	)
			oModelLoad:LoadValue( "MODEL_V76","V76_DBENEF "	, GatMatSST(V75->V75_BENEF,.T.,"V75",.T.))
			oModelLoad:LoadValue( "MODEL_V76","V76_TRABAL"	, V75->V75_TRABAL	)
			oModelLoad:LoadValue( "MODEL_V76","V76_DTRABA"	, GatMatSST(V75->V75_TRABAL,.T.,"V75")	)
			oModelLoad:LoadValue( "MODEL_V76","V76_CPFBEN"	, V75->V75_CPFBEN	)
			oModelLoad:LoadValue( "MODEL_V76","V76_NRBENF"	, V75->V75_NRBENF	)
			oModelLoad:LoadValue( "MODEL_V76","V76_TPBENE"	, V75->V75_TPBENE	)
			oModelLoad:LoadValue( "MODEL_V76","V76_TPPLAN"	, V75->V75_TPPLAN	)
			oModelLoad:LoadValue( "MODEL_V76","V76_TPPENS"	, V75->V75_TPPENS	)

		EndIf

		aEval(aCamposV76, {|campo|oModelLoad:LoadValue( "MODEL_V76", campo[2], &("V76->" + AllTrim(campo[2]) ) ) })

	ElseIf ( nOpc == 5 .Or. nOpc == 6 .Or. nOpc == 14 )

		If !FwIsInCallStack("GOSETEXTEMP")

			lExists2418 := RetUltAtv( 'V77', V75->V75_ID + "1", 1, .T.  )

		EndIf

		If lExists2418 .And. nOpc <> 14

			oModelLoad:LoadValue( "MODEL_V77","V77_BENEF "	, V77->V77_BENEF	)
			oModelLoad:LoadValue( "MODEL_V77","V77_DBENEF "	, GatMatSST(V77->V77_BENEF,.T.,"V75",.T.))
			oModelLoad:LoadValue( "MODEL_V77","V77_TRABAL"	, V77->V77_TRABAL	)
			oModelLoad:LoadValue( "MODEL_V77","V77_DTRABA"	, GatMatSST(V77->V77_TRABAL,.T.,"V75")	)
			oModelLoad:LoadValue( "MODEL_V77","V77_CPFBEN"	, V77->V77_CPFBEN	)
			oModelLoad:LoadValue( "MODEL_V77","V77_NRBENF"	, V77->V77_NRBENF	)
			oModelLoad:LoadValue( "MODEL_V77","V77_DTREAT"	, V77->V77_DTREAT	)
			oModelLoad:LoadValue( "MODEL_V77","V77_DTEF"	, V77->V77_DTEF		)

		Else 

			oModelLoad:LoadValue( "MODEL_V77","V77_BENEF "	, V75->V75_BENEF	)
			oModelLoad:LoadValue( "MODEL_V77","V77_DBENEF "	, GatMatSST(V75->V75_BENEF,.T.,"V75",.T.))
			oModelLoad:LoadValue( "MODEL_V77","V77_TRABAL"	, V75->V75_TRABAL	)
			oModelLoad:LoadValue( "MODEL_V77","V77_DTRABA"	, GatMatSST(V75->V75_TRABAL,.T.,"V75")	)
			oModelLoad:LoadValue( "MODEL_V77","V77_CPFBEN"	, V75->V75_CPFBEN	)
			oModelLoad:LoadValue( "MODEL_V77","V77_NRBENF"	, V75->V75_NRBENF	)

		EndIf

		aEval(aCamposV77, {|campo|oModelLoad:LoadValue( "MODEL_V77", campo[2], &("V77->" + AllTrim(campo[2]) ) ) })

	ElseIf ( nOpc == 7 .Or. nOpc == 8 .Or. nOpc == 15 )

		If !FwIsInCallStack("GOSETEXTEMP")

			lExists2420 := RetUltAtv( 'V78', V75->V75_ID + "1", 1, .T.  )

		EndIf

		If lExists2420 .And. nOpc <> 15

			oModelLoad:LoadValue( "MODEL_V78","V78_BENEF "	, V78->V78_BENEF	)
			oModelLoad:LoadValue( "MODEL_V78","V78_DBENEF "	, GatMatSST(V78->V78_BENEF,.T.,"V75",.T.))
			oModelLoad:LoadValue( "MODEL_V78","V78_TRABAL"	, V78->V78_TRABAL	)
			oModelLoad:LoadValue( "MODEL_V78","V78_DTRABA"	, GatMatSST(V78->V78_TRABAL,.T.,"V75")	)
			oModelLoad:LoadValue( "MODEL_V78","V78_CPFBEN"	, V78->V78_CPFBEN	)
			oModelLoad:LoadValue( "MODEL_V78","V78_NRBENF"	, V78->V78_NRBENF	)
			oModelLoad:LoadValue( "MODEL_V78","V78_DTTERM"	, V78->V78_DTTERM	)
			oModelLoad:LoadValue( "MODEL_V78","V78_MTVTER"	, V78->V78_MTVTER	)

		Else 

			oModelLoad:LoadValue( "MODEL_V78","V78_BENEF "	, V75->V75_BENEF	)
			oModelLoad:LoadValue( "MODEL_V78","V78_DBENEF "	, GatMatSST(V75->V75_BENEF,.T.,"V75",.T.))
			oModelLoad:LoadValue( "MODEL_V78","V78_TRABAL"	, V75->V75_TRABAL	)
			oModelLoad:LoadValue( "MODEL_V78","V78_DTRABA"	, GatMatSST(V75->V75_TRABAL,.T.,"V75")	)
			oModelLoad:LoadValue( "MODEL_V78","V78_CPFBEN"	, V75->V75_CPFBEN	)
			oModelLoad:LoadValue( "MODEL_V78","V78_NRBENF"	, V75->V75_NRBENF	)

		EndIf

		aEval(aCamposV78, {|campo|oModelLoad:LoadValue( "MODEL_V78", campo[2], &("V78->" + AllTrim(campo[2]) ) ) })

	EndIf

	If !IsBlind()
		FWExecView( cTitulo, cFunName, nOper, , {||.T.}, , , , , , , oModelLoad ) 
	Else

		If cFunName == "TAFA591"
			oModelLoad:LoadValue("MODEL_V75", "V75_CPFBEN", V75->V75_CPFBEN)
		EndIf

		If oModelLoad:VldData()
			oModelLoad:CommitData()
		EndIf
	EndIf

	cFilAnt := cFilbkp

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF591MsgErr
Funcao para retornar a query utilizada na sele��o do hist�rico das
altera��es do trabalhador.

@Return 

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAF591MsgErr( nOption, aOpcoes )

	Local cStatus := ""
	Local cMsgErr := ""
	Local x		  := 0

	For x := 1 To Len(aOpcoes)

		If !Empty(aOpcoes[x][2])
			If aOpcoes[x][2] == "S-2416" .And. nOption == 3
				cStatus  := aOpcoes[x][3]
			ElseIf aOpcoes[x][2] == "S-2418" .And. nOption == 5
				cStatus  := aOpcoes[x][3]
			ElseIf aOpcoes[x][2] == "S-2420" .And. nOption == 7
				cStatus  := aOpcoes[x][3]
			EndIf
		EndIf

	Next

	If cStatus == '2'

		cMsgErr := STR0076	//"Registro n�o pode ser alterado, pois encontra-se em processo de transmiss�o."

	ElseIf cStatus == '6'

		cMsgErr := STR0077	//"Registro n�o pode ser alterado. Aguardando processo de transmiss�o do evento de Exclus�o S-3000."

	ElseIf cStatus == '7'

		cMsgErr := STR0078	//"Registro n�o pode ser alterado, pois o evento de exclus�o encontra-se na base do RET."

	EndIf 

Return cMsgErr

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF591AltExt
Funcao que possibilita o evento extemporaneo para os registros do beneficio 

@Return 

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAF591AltExt(cTpExtemp)

	Local nExView := 0

	Private lGoExtemp	:= .T.

	Eval( {|| nExView := GoSetExtemp( cTpExtemp ), Iif( lHistLoop .And. ValType(oDlgPrinc) == "O",oDlgPrinc:End(), Nil ) }) // vda

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF591ExcExt
Funcao que possibilita o evento extemporaneo para os registros do beneficio 

@Return 

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAF591ExcExt( cTpExtemp, cTpExcl )

	Default cTpExtemp := ""
	Default cTpExcl   := ""

	Private lGoExtemp := .T.

	GoDelExtemp(cTpExtemp, cTpExcl)

	TAF591RfhExt()

Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} GoSetExtemp
Funcao que possibilita o evento extemporaneo para os registros do trabalhador 

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0

@Return 
/*/
//-----------------------------------------------------------------------------
Static Function GoSetExtemp( cTpExtemp )

	Local aOpcoes      := {}
	Local cAlias       := ""
	Local cChvInd      := ""
	Local cFilBkp      := cFilAnt
	Local cIdBen       := ""
	Local cNomeEvto    := ""
	Local cRotina      := ""
	Local cStatAlt     := ""
	Local cStatSecn    := ""
	Local cStatsEve    := ""
	Local cTitulo      := ""
	Local cVersao      := ""
	Local dDtUtlAlt    := STOD("")
	Local lPermiAlt    := .T.
	Local lRetif       := .T.
	Local nExView      := -1
	Local nOpc         := 0
	Local nOpcAviso    := 0
	Local nOpera       := 0
	Local nRecno       := 0

	Private lExist2416 := .F.
	Private lExist2418 := .F.
	Private lExist2420 := .F.
	
	Private ALTERA
	Private INCLUI

	Default cTpExtemp   := ""

	cFilAnt    := Iif( IsInCallStack("TafNewBrowse") .And. ( V75->V75_FILIAL <> cFilAnt ), V75->V75_FILIAL, cFilAnt)
	lExist2416 := RetUltAtv("V76", V75->V75_ID + "1", 1, .T. )
	lExist2418 := RetUltAtv("V77", V75->V75_ID + "1", 1, .T. )
	lExist2420 := RetUltAtv("V78", V75->V75_ID + "1", 1, .T. )

	lHistLoop		:= .F.

	cIdBen			:= (cAliasHist)->ID
	cVersao			:= (cAliasHist)->VERSAO
	cStatsEve		:= (cAliasHist)->STATUS
	cStatSecn		:= (cAliasHist)->STASEC
	cNomeEvto		:= (cAliasHist)->NOMEVE
	nRecno			:= (cAliasHist)->RECNO
	cAlias			:= (cAliasHist)->ALIASTAB
	cCpfBenef		:= (cAliasHist)->CPFBEN
	cNrBenef		:= (cAliasHist)->NRBENF

	cChvInd := xFilial( cAlias ) + cIdBen + cVersao + "1"                                                                                                           

	If cNomeEvto == "S2410" .And. cAlias == "V75"
		dDtUtlAlt		:= V75->V75_DTINBE
		cCmpDtAlt		:= "_DTINBE"
	ElseIf lExist2416 .And. cAlias == "V76"
		dDtUtlAlt		:= V76->V76_DALTBE
		cCmpDtAlt		:= "_DALTBE"
	ElseIf lExist2418 .And. cAlias == "V77"
		dDtUtlAlt		:= V77->V77_DTREAT
		cCmpDtAlt		:= "_DTREAT"
	ElseIf lExist2420 .And. cAlias == "V78"
		dDtUtlAlt		:= V78->V78_DTTERM
		cCmpDtAlt		:= "_DTTERM"
	EndIf

	(cAlias)->( DBSetOrder( 2 ) )
	If (cAlias)->( MsSeek( cChvInd ) )

		If cTpExtemp == "R"
			If (cAlias)->&(cAlias + cCmpDtAlt) >= dDtUtlAlt
				lRetif := .F.
			EndIf
		EndIf

		If lRetif

			cStatsEve := (cAlias)->&(cAlias + "_STATUS")

			If cNomeEvto $ "S2410"

				Aviso(STR0079, STR0080, {STR0081}) //##"e-Social"#"Evento S-2410 n�o pode ser inclu�do / retificado por esta rotina."#"OK"

			ElseIf cStatsEve == '4'

				cChvTrab:= V75->V75_CPFBEN + '1'

				If cNomeEvto $ ('S2416/S2418/S2420')

					//==================================================================================++
					// O sistema permite ao usu�rio inserir varios eventos de altera��o (S-2400)		||
					// para o mesmo trabalhador com datas dIferentes. Por�m apenas � permitido retificar||
					// o �ltimo evento de altera��o enviado. Por isso a fun��o RetUltAtivo posiciona no	||
					// registro ativo com a maior data. 												||
					//==================================================================================++
					If cTpExtemp $ " /R"
						If cNomeEvto $ ("S2416")
							aAdd(aOpcoes,STR0045) //nOpc = 4#"S-2416 Retificar Cadastro de Benef�cio - Altera��o"
						ElseIf cNomeEvto $ ("S2418")
							aAdd(aOpcoes,STR0047) //nOpc = 5#"S-2418 Retificar Cadastro de Reativa��o de Benef�cio"
						ElseIf cNomeEvto $ ("S2420")
							aAdd(aOpcoes,STR0049) //nOpc = 6#"S-2420 Retificar Cadastro de Benef�cio - T�rmino"
						EndIf
					EndIf

					If lPermiAlt

						If cTpExtemp $ " /A"
							If cNomeEvto $ ("S2416")
								aAdd(aOpcoes,STR0044) //nOpc = 2#"S-2416 Alterar Cadastro de Benef�cio - Altera��o"
							ElseIf cNomeEvto $ ("S2418")
								aAdd(aOpcoes,STR0046) //nOpc = 3#"S-2418 Alterar Cadastro de Reativa��o de Benef�cio"
							ElseIf cNomeEvto $ ("S2420")
								aAdd(aOpcoes,STR0048) //nOpc = 6"S-2420 Alterar Cadastro de Benef�cio - T�rmino"
							EndIf
						EndIf

						//===========================================================================================+
						// nOpc == 3 - Alterar Cadastro de Benefici�rio - Altera��o (S-2405) # S-2405               ||
						// nOpc == 4 - Retificar Cadastro de Benefici�rio - Altera��o (S-2405) # S-2405             ||
						//===========================================================================================+
						nOpc := TAF591OptBen(aOpcoes)

						If nOpc > 0

							If ( nOpc == 3 .Or. nOpc == 4 ) .And. cNomeEvto $ ('S2416')
								cTitulo	:= STR0083   //"Altera��o Cadastro de Benef�cio - Altera��o"
								cRotina	:= "TAFA593"
							ElseIf ( nOpc == 5 .Or. nOpc == 6 ) .And. cNomeEvto $ ('S2418')
								cTitulo	:= STR0084   //"Altera��o de Reativa��o de Benef�cio"ho"
								cRotina	:= "TAFA594"
							ElseIf ( nOpc == 7 .Or. nOpc == 8 ).And. cNomeEvto $ ('S2420')
								cTitulo	:= STR0085   //"Altera��o Cadastro de Benef�cio - T�rmino" 
								cRotina	:= "TAFA595"
							EndIf

						EndIf
					Else
						msgAlert(xValStrEr("000727")) //"Registro n�o pode ser alterado. Aguardando processo da transmiss�o."
					EndIf
				EndIf

				If nOpc > 0

					//================================== OP��ES DE ALTERA��O ==========================================+
					// nOpc == 3 - Alterar Cadastro de Benefici�rio - Altera��o (S-2405) # S-2405                     ||
					// nOpc == 4 - Retificar Cadastro de Benefici�rio - Altera��o (S-2405) # S-2405               	  ||
					//=================================================================================================+

					(cAlias)->(dbGoTo(nRecno))

					//Inclus�o de evento de altera��o S-2416
					If nOpc == 3 .Or. nOpc == 4

						If nOpc == 3
							INCLUI := .T.
							ALTERA := .F.
							nOpera := MODEL_OPERATION_INSERT
						Else
							INCLUI := .F.
							ALTERA := .T.
							nOpera := MODEL_OPERATION_UPDATE
						EndIf

						cStatAlt := cStatsEve

						If cStatAlt $ '0|4' .Or. ( Empty( cStatAlt ) .And. cTpExtemp == "A")//Verifica se n�o existe evento de altera��o pendente de transmiss�o
							
							FWMsgRun(,{||TAF591CarModel( cTitulo, cRotina, nOpera, nOpc )},,STR0086)	//"Executando Rotina do Benef�cio - Altera��o..."

						ElseIf cStatAlt == '1' .Or. cStatAlt == '3'

							//N�o permito retifica��o do evento do benefici�rio se houver um evento de altera��o S2205 pendente.
							If cStatAlt == '1'

								nOpcAviso := Aviso( STR0079, STR0087 + CRLF + STR0088 +; 
								STR0089, { STR0090, STR0091 },3 )	//##"e-Social"#"Existe um evento pendente de transmiss�o ao RET."#"Deseja Excluir este evento para gerar uma "#"retifica��o?"#"Sim"#"N�o"

							ElseIf cStatAlt == '3'

								nOpcAviso := Aviso( STR0079, STR0092 + CRLF + STR0088 +; 
								STR0089, { STR0090, STR0091 },3 )	//##"e-Social"#"Existe um evento com retorno de inconsist�ncia do RET." #"Deseja Excluir este evento para gerar uma "#"retifica��o?"#"Sim"#"N�o"

							EndIf

							If nOpcAviso == 1 

								//Deleto o registro pendente
								DelEvento("TAFA593")

								//Carrego o modelo consolidando as informa��es para altera��o das informa��es
								FWMsgRun(,{||TAF591CarModel( cTitulo, cRotina, nOpera, nOpc )},,STR0086)	//"Executando Rotina do Benef�cio - Altera��o..."

							EndIf

						Else //cStatAlt == 2 - Evento em processo de transmiss�o

							msgAlert(xValStrEr("000727")) //"Registro n�o pode ser alterado, pois se encontra em processo de transmiss�o"

						EndIf

					ElseIf nOpc == 5 .Or. nOpc == 6

						If nOpc == 5
							INCLUI := .T.
							ALTERA := .F.
							nOpera := MODEL_OPERATION_INSERT
						Else
							INCLUI := .F.
							ALTERA := .T.
							nOpera := MODEL_OPERATION_UPDATE
						EndIf

						cStatAlt := cStatsEve

						If cStatAlt $ '0|4' .Or. ( Empty( cStatAlt ) .And. cTpExtemp == "A")//Verifica se n�o existe evento de altera��o pendente de transmiss�o
							
							FWMsgRun(,{||TAF591CarModel( cTitulo, cRotina, nOpera, nOpc )},,STR0086)	//"Executando Rotina do Benef�cio - Altera��o..."

						ElseIf cStatAlt == '1' .Or. cStatAlt == '3'

							//N�o permito retifica��o do evento do benefici�rio se houver um evento de altera��o S2205 pendente.
							If cStatAlt == '1'

								nOpcAviso := Aviso( STR0079, STR0087 + CRLF + STR0088 +; 
								STR0089, { STR0090, STR0091 },3 ) 	//##"e-Social"#"Existe um evento pendente de transmiss�o ao RET."#"Deseja Excluir este evento para gerar uma "#"retifica��o?"#"Sim"#"N�o"

							ElseIf cStatAlt == '3'

								nOpcAviso := Aviso( STR0079, STR0092 + CRLF + STR0088 +; 
								STR0089, { STR0090, STR0091 },3 ) 	//##"e-Social"#"Existe um evento com retorno de inconsist�ncia do RET."#"Deseja Excluir este evento para gerar uma "#"retifica��o?"#"Sim"#"N�o"

							EndIf

							If nOpcAviso == 1 

								//Deleto o registro pendente
								DelEvento("TAFA593")

								//Carrego o modelo consolidando as informa��es para altera��o das informa��es
								FWMsgRun(,{||TAF591CarModel( cTitulo, cRotina, nOpera, nOpc )},,STR0086)	//"Executando Rotina do Benef�cio - Altera��o..."

							EndIf

						Else //cStatAlt == 2 - Evento em processo de transmiss�o

							msgAlert(xValStrEr("000727")) //"Registro n�o pode ser alterado, pois se encontra em processo de transmiss�o"

						EndIf

					ElseIf nOpc == 7 .Or. nOpc == 8

						If nOpc == 7
							INCLUI := .T.
							ALTERA := .F.
							nOpera := MODEL_OPERATION_INSERT
						Else
							INCLUI := .F.
							ALTERA := .T.
							nOpera := MODEL_OPERATION_UPDATE
						EndIf

						cStatAlt := cStatsEve

						If cStatAlt $ '0|4' .Or. ( Empty( cStatAlt ) .And. cTpExtemp == "A")//Verifica se n�o existe evento de altera��o pendente de transmiss�o
							
							FWMsgRun(,{||TAF591CarModel( cTitulo, cRotina, nOpera, nOpc )},,STR0086)	//"Executando Rotina do Benef�cio - Altera��o..."

						ElseIf cStatAlt == '1' .Or. cStatAlt == '3'

							//N�o permito retifica��o do evento do benefici�rio se houver um evento de altera��o S2205 pendente.
							If cStatAlt == '1'

								nOpcAviso := Aviso( STR0079, STR0087 + CRLF + STR0088 +; 
								STR0089, { STR0090, STR0091 },3 ) 	//##"e-Social"#"Existe um evento pendente de transmiss�o ao RET."#"Deseja Excluir este evento para gerar uma "#"retifica��o?"#"Sim"#"N�o"

							ElseIf cStatAlt == '3'

								nOpcAviso := Aviso( STR0079, STR0092 + CRLF + STR0088 +; 
								STR0089, { STR0090, STR0091 },3 ) 	//##"e-Social"#"Existe um evento com retorno de inconsist�ncia do RET."#"Deseja Excluir este evento para gerar uma "#"retifica��o?"#"Sim"#"N�o"

							EndIf

							If nOpcAviso == 1 

								//Deleto o registro pendente
								DelEvento("TAFA595")

								//Carrego o modelo consolidando as informa��es para altera��o das informa��es
								FWMsgRun(,{||TAF591CarModel( cTitulo, cRotina, nOpera, nOpc )},,STR0086)	//"Executando Rotina do Benef�cio - Altera��o..."

							EndIf

						Else //cStatAlt == 2 - Evento em processo de transmiss�o

							msgAlert(xValStrEr("000727")) //"Registro n�o pode ser alterado, pois se encontra em processo de transmiss�o"

						EndIf

					EndIf

					If !Isblind()
						lHistLoop := .T.
					Else
						lHistLoop := .F.
					EndIf

				EndIf

			ElseIf cStatsEve == '2'

				msgAlert(xValStrEr("000727")) //"Registro n�o pode ser alterado. Aguardando processo da transmiss�o."

			ElseIf cStatsEve == '3'

				msgAlert( STR0079, STR0093, { STR0081 }, 3 ) 	//##"e-Social"#"Evento com retorno de inconsist�ncia do RET."#"OK"

			ElseIf cStatsEve == '6'

				msgAlert(xValStrEr("000728")) //"Registro n�o pode ser alterado. Aguardando processo de transmiss�o do evento de Exclus�o S-3000"

			ElseIf cStatsEve == '7'

				msgAlert(xValStrEr("000772")) //"Registro n�o pode ser alterado, pois o evento de exclus�o j� se encontra na base do RET"

			ElseIf cStatsEve $ (' |0|1|')

				msgAlert(xValStrEr("001119")) //"N�o � permitido incluir extempor�neo para eventos n�o trasmitidos com sucesso ao RET."

			EndIf

		Else

			msgAlert(STR0094)	//"�ltima Altera��o de Benef�cio n�o pode ser retificada via extempor�neo!"

		EndIf

	Else

		msgAlert(STR0095)	//"Registro n�o pode ser localizado"
		(cAlias)->( DBSetOrder( 1 ) )
		(cAlias)->( MsSeek( xFilial( cAlias ) + cIdBen + cVersao ) )

	EndIf

	TAF591RfhExt()

	cFilAnt := cFilBkp 

Return nExView

//-----------------------------------------------------------------------------
/*/{Protheus.doc} GoDelExtemp
Funcao que possibilita o evento extemporaneo para os registros do trabalhador 

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0

@Return 
/*/
//-----------------------------------------------------------------------------
Static Function GoDelExtemp( cTpExtemp, cTpExcl )

	Local cAlias      := ""
	Local cAtivo      := ""
	Local cChvBen     := V75->V75_ID + '1'
	Local cCmpDtAlt   := ""
	Local cFilBkp     := cFilAnt
	Local cIdBen      := ""
	Local cNomeEvto   := ""
	Local cStatSecn   := ""
	Local cStatsEve   := ""
	Local cVersao     := ""
	Local dDtUtlAlt   := STOD("")
	Local lDelet      := .T.
	Local lExist2416  := .F.
	Local lExist2418  := .F.
	Local lExist2420  := .F.
	Local nRecno      := 0

	Default cTpExtemp := ""
	Default cTpExcl   := ""

	Private ALTERA
	Private INCLUI

	cFilAnt    := Iif( IsInCallStack("TafNewBrowse") .And. ( V75->V75_FILIAL <> cFilAnt ), V75->V75_FILIAL, cFilAnt)
	lExist2416 := RetUltAtv("V76", cChvBen, 1, .T. )
	lExist2418 := RetUltAtv("V77", cChvBen, 1, .T. )
	lExist2420 := RetUltAtv("V78", cChvBen, 1, .T. )

	cIdBen     := (cAliasHist)->ID
	cVersao    := (cAliasHist)->VERSAO
	cStatsEve  := (cAliasHist)->STATUS
	cStatSecn  := (cAliasHist)->STASEC
	cNomeEvto  := (cAliasHist)->NOMEVE
	cAtivo     := (cAliasHist)->ATIVO
	nRecno     := (cAliasHist)->RECNO
	cAlias     := (cAliasHist)->ALIASTAB
	cCpfBenef  := (cAliasHist)->CPFBEN
	cNrBenef   := (cAliasHist)->NRBENF

	lHistLoop	:= .F.

	If cNomeEvto == "S2410" .And. cAlias == "V75"
		dDtUtlAlt		:= V75->V75_DTINBE
		cCmpDtAlt		:= "_DTINBE"
	ElseIf lExist2416 .And. cAlias == "V76"
		dDtUtlAlt		:= V76->V76_DALTBE
		cCmpDtAlt		:= "_DALTBE"
	ElseIf lExist2418 .And. cAlias == "V77"
		dDtUtlAlt		:= V77->V77_DTREAT
		cCmpDtAlt		:= "_DTREAT"
	ElseIf lExist2420 .And. cAlias == "V78"
		dDtUtlAlt		:= V78->V78_DTTERM
		cCmpDtAlt		:= "_DTTERM"
	EndIf

	(cAlias)->(dbGoTo(nRecno))   

	If (cAlias)->&(cAlias + cCmpDtAlt) >= dDtUtlAlt
		lDelet := .F.
	EndIf                                                                                                   

	If cNomeEvto $ "S2410"
		Aviso(STR0096, STR0097, {STR0081}) //##"Aviso"#"Evento 2410 n�o pode ser exclu�do por esta rotina."#
	ElseIf cStatsEve == '2'
		Aviso(STR0096, STR0098, {STR0081}) //##"Aviso"#"Registro j� foi transmitido e est� aguardando retorno. N�o pode ser excluido."#"OK"
	ElseIf cTpExcl == "1" .AND. cStatsEve == '6'
		Aviso(STR0096, STR0099, {STR0081})//##"Aviso"#"Registro pendente de exclus�o no Governo ( S-3000 ). N�o pode ser exclu�do."#"OK"
	ElseIf (cAlias)->&(cAlias + "_EVENTO") == 'I' .And. cStatsEve == '2' 
		Aviso(STR0096, STR0100, {STR0081})//##"Aviso"#"Evento S2416 inativo n�o pode ser exclu�do."#"OK"
	ElseIf !lDelet .And. cTpExcl == "1"
		Aviso(STR0096, STR0101, {STR0081}) //##"Aviso"#"�ltima altera��o de benef�cio n�o pode ser exclu�da via extempor�neo!"#"OK"
	ElseIf !lDelet .And. cTpExcl == "2" .Or. cTpExcl == "3"
		Aviso(STR0096, STR0111, {STR0081}) //"N�o existe exclus�o extempor�nea para �ltima altera��o de Benef�cio"
	Else

		nOpera := MODEL_OPERATION_DELETE
		INCLUI := .F.
		ALTERA := .F.

		//Efetuo a exclus�o no registro
		xTafVExc( cAlias, nRecno, Val(cTpExcl) )
		lHistLoop := .T.

	EndIf

	cFilAnt := cFilBkp

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF591RfhExt
Refresh da tela de hist�rico de altera��es

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF591RfhExt()

	Local aCampos := {}
	Local aStru   := {}
	Local cAlias  := ""
	Local cQuery  := ""
	Local nPosFld := 0
	Local nPosId  := 0
	Local nX      := 0
	Local cIdBen  := (cAliasBen)->ID

	If (lHistLoop)

		aAdd(aCampos,{STR0052	,'FILIAL'		,TamSX3("V75_FILIAL")[1]	,'C','@!',0,	0})	//"Filial"
		aAdd(aCampos,{STR0053	,'DTEVEN'		,8							,'D',''  ,1,	2})	//"Data Evento"
		aAdd(aCampos,{STR0054	,'ID'			,TamSX3("V75_ID")[1]		,'C','@!',1,	0})	//"ID."
		aAdd(aCampos,{STR0055	,'DATASYS'		,8							,'D',''  ,1,	2})	//"Data Sistemica"
		aAdd(aCampos,{STR0056	,'STASEC'		,1							,'C',''  ,1,	0})	//"Status Secund�rio"
		aAdd(aCampos,{STR0057 	,'NOMEVE'		,TamSX3("V75_NOMEVE")[1]	,'C','@!',1,	0})	//"Nome Evento"
		aAdd(aCampos,{STR0058	,'EVENTO'		,TamSX3("V75_EVENTO")[1]	,'C','@!',1,	0})	//"Evento"
		aAdd(aCampos,{STR0059	,'CPFBEN'		,TamSX3("V75_CPFBEN")[1]	,'C','@!',1,	5})	//"CPF Benef."
		aAdd(aCampos,{STR0060	,'NRBENF'		,TamSX3("V75_NRBENF")[1]	,'C','@!',1,	5})	//"Nr. Benef�cio"
		aAdd(aCampos,{STR0061	,'NOME'		    ,TamSX3("V75_DBENEF")[1]	,'C','@!',1,	0})	//"Nome"
		aAdd(aCampos,{STR0062	,'VERSAO'		,TamSX3("V75_VERSAO")[1]	,'C','@!',1,	0})	//"Vers�o"
		aAdd(aCampos,{STR0063	,'ALIASTAB'	    ,3							,'C',''  ,1,	0})	//"AliasTab"
		aAdd(aCampos,{STR0064	,'RECNO'		,10							,'N',''  ,1,	0})	//"RecNo"
		aAdd(aCampos,{STR0065	,'STATUS'		,1							,'C','@' ,1,	0})	//"Status de Transmiss�o"
		aAdd(aCampos,{STR0066	,'ATIVO'		,1							,'C','@' ,1,	0})	//"Ativo"

		For nX := 1 To Len(aCampos)
			aAdd(aStru,{ aCampos[nX][2]	, aCampos[nX][4], aCampos[nX][3], 0})
		Next nX

		DbSelectArea((cAliasBen))
		(cAliasBen)->(DbSetOrder(2))
		(cAliasBen)->(DbGoTop())

		While ((cAliasBen)->(!Eof()))

			RecLock((cAliasBen), .F.)
			(cAliasBen)->(DbDelete())
			(cAliasBen)->(MsUnlock())

			(cAliasBen)->(DbSkip())

		Enddo

		cQuery  := ChangeQuery(TAF591Qry(cIdBen))
		cAlias  := MPSysOpenQuery(cQuery)

		nPosFld := aScan( aCampos, { |x| x[02] == 'NOME' } )
		nPosId  := aScan( aCampos, { |x| x[02] == 'NOMEVE' } )

		While (cAlias)->(!Eof())

			RecLock((cAliasBen),.T.)
			cNomeve := (cAlias)->&(aCampos[nPosId][2])

			For nX := 1 To Len(aCampos)

				If nX == nPosFld
					(cAliasBen)->&(aCampos[nX][2]) := TafNameBen( xFilial("V75"), , (cAlias)->&CPFBEN, cValToChar((cAlias)->&ID), .F. ) //Tratamento feito para os eventos que possuem campo _NOME como virtual
				Else
					If aCampos[Nx][04] == "D"
						(cAliasBen)->&(aCampos[nX][2]) := Stod((cAlias)->&(aCampos[nX][2]))
					Else
						(cAliasBen)->&(aCampos[nX][2]) := (cAlias)->&(aCampos[nX][2])
					EndIf
				EndIf

			Next nX

			(cAliasBen)->(MsUnlock())
			(cAlias)->(dbSkip())

		EndDo

		(cAlias)->(dbCloseArea())

		If ValType(oDlgPrinc) == "O"
			oDlgPrinc:Refresh()
		EndIf

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf591RulCad
Regras para gravacao das informacoes do registros S-2410, S-2416, 
S-2418 e S-2420 do E-Social

@Param
nOper  - Operacao a ser realizada ( 3 = Inclusao / 4 = Alteracao / 5 = Exclusao )

@Return
aRull  - Regras para a gravacao das informacoes


@author @Author Silas Gomes
@since 23/09/2021
@version 1.0

/*/
//-------------------------------------------------------------------
Function Taf591RulCad( cCabecBen, cLayout, cAlias, cInconMsg, nSeqErrGrv, lTransmit, oModel, cCodEvent, cOwner )

	Local aRull         := {}
	Local cBenf         := ""
	Local cCabAlt       := ""
	Local cCabBenef     := ""
	Local cCabDados     := ""
	Local cCabInfMor    := ""
	Local cCabSusp      := ""
	Local cDadosBenef   := ""
	Local cIdFunc       := ""
	Local cInfBenef     := ""
	Local cInfPenMorte  := ""
	Local cInfTerm      := ""
	Local cInstPenMorte := ""
	Local cMudCPF       := ""
	Local cPath2410     := "/eSocial/evtCdBenIn"
	Local cPath2416     := "/eSocial/evtCdBenAlt"
	Local cPath2418     := "/eSocial/evtReativBen"
	Local cPath2420     := "/eSocial/evtCdBenTerm"
	Local cSucessBenef  := ""

	Default cAlias      := "V75"
	Default cCabecBen   := ""
	Default cCodEvent   := ""
	Default cInconMsg   := ""
	Default cLayout     := ""
	Default cOwner      := ""
	Default lTransmit   := .F.
	Default nSeqErrGrv  := 0
	Default oModel      := Nil

	//����������������������������������������������������������������������������Ŀ
	//� 				                  S-2410                                   �  
	//������������������������������������������������������������������������������
	If cLayout == "2410"

		//=======================================++
		//             <beneficiario>       	 ||
		//=======================================++
		cCabBenef := "/beneficiario"

		cIdFunc := Posicione( "C9V", 11, xFilial("C9V") + PADR( FTafGetVal( cPath2410 + cCabBenef + "/matricula", "C", .F.,, .F. ), (TamSX3("C9V_MATRIC")[1])) + "1", "C9V_ID")
		If !Empty(cIdFunc)
			Aadd(aRull, {"V75_TRABAL", cIdFunc, "C", .T.})
		EndIf
	
		cBenf = FGetIdInt( "cpfBenef", "",+cPath2410 + cCabBenef + "/cpfBenef",,,,@cInconMsg, @nSeqErrGrv,,,,,,,,,"S-2410")
		Aadd(aRull, {"V75_BENEF", cBenf , "C", .T.})

		If !Empty(cBenf)
			//<beneficiario>
			If TafXNode( oDados, cCodEvent, cOwner, ( cPath2410 + cCabBenef + "/cpfBenef"))
				aAdd( aRull, { cAlias + "_CPFBEN", cPath2410 + cCabBenef + "/cpfBenef", "C", .F. } )
			EndIf
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner, (cPath2410 + cCabBenef + "/matricula"))
			aAdd( aRull, { cAlias + "_MATRIC", cPath2410 + cCabBenef + "/matricula", "C", .F. } )
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner, (cPath2410 + cCabBenef + "/cnpjOrigem"))
			aAdd( aRull, { cAlias + "_CNPJDS", cPath2410 + cCabBenef + "/cnpjOrigem", "C", .F. } )
		EndIf

		//=======================================++
		//            <infoBenInicio>       	 ||
		//=======================================++
		cInfBenef := "/infoBenInicio"

		If TafXNode( oDados, cCodEvent, cOwner, (cPath2410 + cInfBenef + "/cadIni"))
			aAdd( aRull, { cAlias + "_CADINI", xFunTrcSN(TAFExisTag(cPath2410 + cInfBenef + "/cadIni"),2), "C", .T. } )
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner, (cPath2410 + cInfBenef + "/indSitBenef"))
			aAdd( aRull, { cAlias + "_SITBEN", cPath2410 + cInfBenef + "/indSitBenef", "C", .F. } )
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner, (cPath2410 + cInfBenef + "/nrBeneficio"))
			aAdd( aRull, { cAlias + "_NRBENF", cPath2410 + cInfBenef + "/nrBeneficio", "C", .F. } )
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner, (cPath2410 + cInfBenef + "/dtIniBeneficio"))
			aAdd( aRull, { cAlias + "_DTINBE", cPath2410 + cInfBenef + "/dtIniBeneficio", "D", .F. } )
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner, (cPath2410 + cInfBenef + "/dtPublic"))
			aAdd( aRull, { cAlias + "_DTPUBL", cPath2410 + cInfBenef + "/dtPublic", "D", .F. } )
		EndIf

		//=======================================++
		//            <dadosBeneficio>       	 ||
		//=======================================++
		cDadosBenef := "/dadosBeneficio"

		If TafXNode( oDados, cCodEvent, cOwner, (cPath2410 + cInfBenef + cDadosBenef + "/nrBeneficio"))
			aAdd( aRull, { cAlias + "_NRBENF", cPath2410 + cInfBenef + cDadosBenef + "/nrBeneficio", "C", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner,  ( cPath2410 + cInfBenef + cDadosBenef + "/tpBeneficio"))
			Aadd( aRull, { cAlias + "_TPBENE", FGetIdInt( "tpBeneficio", "", + cPath2410 + cInfBenef + cDadosBenef + "/tpBeneficio",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } )
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner, (cPath2410 + cInfBenef + cDadosBenef + "/tpPlanRP"))
			aAdd( aRull, { cAlias + "_TPPLAN", cPath2410 + cInfBenef + cDadosBenef + "/tpPlanRP", "C", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2410 + cInfBenef + cDadosBenef + "/dsc"))
			aAdd( aRull, { cAlias + "_DESC", cPath2410 + cInfBenef + cDadosBenef + "/dsc", "C", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2410 + cInfBenef + cDadosBenef + "/indDecJud"))
			aAdd( aRull, { cAlias + "_INDJUD", cPath2410 + cInfBenef + cDadosBenef + "/indDecJud", "C", .F. } )
		EndIf

		//=======================================++
		//             <infoPenMorte>       	 ||
		//=======================================++
		cInfPenMorte := "/infoPenMorte"

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2410 + cInfBenef + cDadosBenef + cInfPenMorte + "/tpPenMorte"))
			aAdd( aRull, { cAlias + "_TPPENS", cPath2410 + cInfBenef + cDadosBenef + cInfPenMorte + "/tpPenMorte", "C", .F. } )
		EndIf

		//=======================================++
		//             <instPenMorte>       	 ||
		//=======================================++
		cInstPenMorte := "/instPenMorte"

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2410 + cInfBenef + cDadosBenef + cInfPenMorte + cInstPenMorte + "/cpfInst"))
			aAdd( aRull, { cAlias + "_CPFINS", cPath2410 + cInfBenef + cDadosBenef + cInfPenMorte + cInstPenMorte + "/cpfInst", "C", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2410 + cInfBenef + cDadosBenef + cInfPenMorte + cInstPenMorte + "/dtInst"))
			aAdd( aRull, { cAlias + "_DTINST", cPath2410 + cInfBenef + cDadosBenef + cInfPenMorte + cInstPenMorte + "/dtInst", "D", .F. } )
		EndIf

		//=======================================++
		//             <sucessaoBenef>      	 ||
		//=======================================++
		cSucessBenef := "/sucessaoBenef"

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2410 + cInfBenef + cSucessBenef + "/cnpjOrgaoAnt"))
			aAdd( aRull, { cAlias + "_CNPJEA", cPath2410 + cInfBenef + cSucessBenef + "/cnpjOrgaoAnt", "C", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2410 + cInfBenef + cSucessBenef + "/nrBeneficioAnt"))
			aAdd( aRull, { cAlias + "_NRBANT", cPath2410 + cInfBenef + cSucessBenef + "/nrBeneficioAnt", "C", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2410 + cInfBenef + cSucessBenef + "/dtTransf"))
			aAdd( aRull, { cAlias + "_DTTRBE", cPath2410 + cInfBenef + cSucessBenef + "/dtTransf", "D", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2410 + cInfBenef + cSucessBenef + "/observacao"))
			aAdd( aRull, { cAlias + "_OBSVIN", cPath2410 + cInfBenef + cSucessBenef + "/observacao", "C", .F. } )
		EndIf

		//=======================================++
		//              <mudancaCPF>        	 ||
		//=======================================++
		cMudCPF := "/mudancaCPF"

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2410 + cInfBenef + cMudCPF + "/cpfAnt"))
			aAdd( aRull, { cAlias + "_CPFANT", cPath2410 + cInfBenef + cMudCPF + "/cpfAnt", "C", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2410 + cInfBenef + cMudCPF + "/nrBeneficioAnt"))
			aAdd( aRull, { cAlias + "_NRANTB", cPath2410 + cInfBenef + cMudCPF + "/nrBeneficioAnt", "C", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2410 + cInfBenef + cMudCPF + "/dtAltCPF"))
			aAdd( aRull, { cAlias + "_DTACPF", cPath2410 + cInfBenef + cMudCPF + "/dtAltCPF", "D", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2410 + cInfBenef + cMudCPF + "/observacao"))
			aAdd( aRull, { cAlias + "_OBSCPF", cPath2410 + cInfBenef + cMudCPF + "/observacao", "C", .F. } )
		EndIf

		//=======================================++
		//             <infoBenTermino>        	 ||
		//=======================================++
		cInfTerm := "/infoBenTermino"

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2410 + cInfBenef + cInfTerm + "/dtTermBeneficio"))
			aAdd( aRull, { cAlias + "_DTTERM", cPath2410 + cInfBenef + cInfTerm + "/dtTermBeneficio", "D", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2410 + cInfBenef + cInfTerm + "/mtvTermino"))
			Aadd( aRull, { cAlias + "_MTVTER", FGetIdInt( "mtvTermino", "", + cPath2410 + cInfBenef + cInfTerm + "/mtvTermino",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } )
		EndIf

	//����������������������������������������������������������������������������Ŀ
	//� 				                  S-2416                                   �  
	//������������������������������������������������������������������������������
	ElseIf cLayout == "2416"

		//=======================================++
		//             <ideBeneficio>        	 ||
		//=======================================++		 
		If TafXNode( oDados, cCodEvent, cOwner, ( cPath2416 + "/ideBeneficio/cpfBenef"))
			aAdd( aRull, { cAlias + "_CPFBEN", cPath2416 + "/ideBeneficio/cpfBenef", "C", .F. } )
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner, (cPath2416 + "/ideBeneficio/nrBeneficio"))
			aAdd( aRull, { cAlias + "_NRBENF", cPath2416 + "/ideBeneficio/nrBeneficio", "C", .F. } )
		EndIf

		//=======================================++
		//            <infoBenAlteracao>       	 ||
		//=======================================++	
		cCabAlt := "/infoBenAlteracao"

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2416 + cCabAlt + "/dtAltBeneficio"))
			aAdd( aRull, { cAlias + "_DALTBE", cPath2416 + cCabAlt + "/dtAltBeneficio", "D", .F. } )
		EndIf

		//=======================================++
		//            <dadosBeneficio>       	 ||
		//=======================================++
		cCabDados := "/dadosBeneficio"

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2416 + cCabAlt + cCabDados + "/tpBeneficio"))
			aAdd( aRull, { cAlias + "_TPBENE", FGetIdInt( "tpBeneficio" , "", cPath2416 + cCabAlt + cCabDados + "/tpBeneficio",,,,@cInconMsg, @nSeqErrGrv), "C", .T.} )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2416 + cCabAlt + cCabDados + "/tpPlanRP"))
			aAdd( aRull, { cAlias + "_TPPLAN", cPath2416 + cCabAlt + cCabDados + "/tpPlanRP", "C", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2416 + cCabAlt + cCabDados + "/dsc"))
			aAdd( aRull, { cAlias + "_DESC", cPath2416 + cCabAlt + cCabDados + "/dsc", "C", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2416 + cCabAlt + cCabDados + "/indSuspensao"))
			aAdd( aRull, { cAlias + "_INDSUS", cPath2416 + cCabAlt + cCabDados + "/indSuspensao", "C", .F. } )
		EndIf

		//=======================================++
		//             <infoPenMorte>       	 ||
		//=======================================++
		cCabInfMor := "/infoPenMorte"

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2416 + cCabAlt + cCabDados + cCabInfMor + "/tpPenMorte"))
			aAdd( aRull, { cAlias + "_TPPENS", cPath2416 + cCabAlt + cCabDados + cCabInfMor + "/tpPenMorte", "C", .F. } )
		EndIf

		//=======================================++
		//               <suspensao>        	 ||
		//=======================================++
		cCabSusp := "/suspensao"

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2416 + cCabAlt + cCabDados + cCabSusp + "/mtvSuspensao"))
			aAdd( aRull, { cAlias + "_MTSUSP", cPath2416 + cCabAlt + cCabDados + cCabSusp + "/mtvSuspensao", "C", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2416 + cCabAlt + cCabDados + cCabSusp + "/dscSuspensao"))
			aAdd( aRull, { cAlias + "_DSCSUS", cPath2416 + cCabAlt + cCabDados + cCabSusp + "/dscSuspensao", "C", .F. } )
		EndIf

	//����������������������������������������������������������������������������Ŀ
	//� 				                  S-2418                                   �  
	//������������������������������������������������������������������������������
	ElseIf cLayout == "2418"

		//=======================================++
		//             <ideBeneficio>        	 ||
		//=======================================++	
		If TafXNode( oDados, cCodEvent, cOwner, (cPath2418 + "/ideBeneficio/cpfBenef"))
			aAdd( aRull, { cAlias + "_CPFBEN", cPath2418 + "/ideBeneficio/cpfBenef", "C", .F. } )
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner, (cPath2418 + "/ideBeneficio/nrBeneficio"))
			aAdd( aRull, { cAlias + "_NRBENF", cPath2418 + "/ideBeneficio/nrBeneficio", "C", .F. } )
		EndIf

		//=======================================++
		//              <infoReativ>        	 ||
		//=======================================++	
		If TafXNode( oDados , cCodEvent, cOwner, (cPath2418 + "/infoReativ/dtEfetReativ"))
			aAdd( aRull, { cAlias + "_DTREAT", cPath2418 + "/infoReativ/dtEfetReativ", "D", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2418 + "/infoReativ/dtEfeito"))
			aAdd( aRull, { cAlias + "_DTEF", cPath2418 + "/infoReativ/dtEfeito", "D", .F. } )
		EndIf

	//����������������������������������������������������������������������������Ŀ
	//� 				                  S-2420                                   �  
	//������������������������������������������������������������������������������
	ElseIf cLayout == "2420"

		//=======================================++
		//              <ideBeneficio>        	 ||
		//=======================================++
		cIdeBen := "/ideBeneficio"

		If TafXNode( oDados, cCodEvent, cOwner, ( cPath2420 + cIdeBen + "/cpfBenef"))
			aAdd( aRull, { cAlias + "_CPFBEN", cPath2420 + cIdeBen + "/cpfBenef", "C", .F. } )
		EndIf

		If TafXNode( oDados, cCodEvent, cOwner, (cPath2420 + cIdeBen + "/nrBeneficio"))
			aAdd( aRull, { cAlias + "_NRBENF", cPath2420 + cIdeBen + "/nrBeneficio", "C", .F. } )
		EndIf

		//=======================================++
		//              <infoBenTermino>        	 ||
		//=======================================++
		cCabTerm := "/infoBenTermino"

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2420 + cCabTerm + "/dtTermBeneficio"))
			aAdd( aRull, { cAlias + "_DTTERM", cPath2420 + cCabTerm + "/dtTermBeneficio", "D", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2420 + cCabTerm + "/mtvTermino"))
			aAdd( aRull, { cAlias + "_MTVTER", FGetIdInt( "mtvTermino" , "", cPath2420 + cCabTerm + "/mtvTermino",,,,@cInconMsg, @nSeqErrGrv), "C", .T. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2420 + cCabTerm + "/cnpjOrgaoSuc"))
			aAdd( aRull, { cAlias + "_CNPJO ", cPath2420 + cCabTerm + "/cnpjOrgaoSuc", "C", .F. } )
		EndIf

		If TafXNode( oDados , cCodEvent, cOwner, (cPath2420 + cCabTerm + "/novoCPF"))
			aAdd( aRull, { cAlias + "_NEWCPF", cPath2420 + cCabTerm + "/novoCPF", "C", .F. } )
		EndIf

	EndIf

Return( aRull )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF591XmlLt

Fun��o utilizada para executar a rotina de xml em lote para todos os 
eventos do cadastro do benef�cio

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF591XmlLt()

	Local aOpcoes := {}
	Local cMens   := STR0102 //"Selecione o tipo de evento desejado:"
	Local cTitulo := STR0103 //"Gera��o de XML em Lote"		
	Local nOpc    := 0

	aAdd( aOpcoes, STR0050	) 	//"S-2410 Benef�cio - In�cio"
	aAdd( aOpcoes, STR0035	) 	//"S-2416 Benef�cio - Altera��o"
	aAdd( aOpcoes, STR0036	) 	//"S-2418 Reativa��o de Benef�cio"
	aAdd( aOpcoes, STR0037	) 	//"S-2420 Benef�cio - T�rmino"

	nOpc := TAF591OptBen( aOpcoes, , cTitulo, cMens )

	If nOpc > 0
		If nOpc == 9 
			TAFXmlLote( 'V75', 'S-2410', 'evtCdBenIn'  , 'TAF592Xml', , Iif( Type("oBrw") <> "U",oBrw,Nil) )
		ElseIf nOpc == 10
			TAFXmlLote( 'V76', 'S-2416', 'evtCdBenAlt' , 'TAF593Xml', , Iif( Type("oBrw") <> "U",oBrw,Nil) )
		ElseIf nOpc == 11
			TAFXmlLote( 'V77', 'S-2418', 'evtReativBen', 'TAF594Xml', , Iif( Type("oBrw") <> "U",oBrw,Nil) )
		ElseIf nOpc == 12
			TAFXmlLote( 'V78', 'S-2420', 'evtCdBenTerm', 'TAF595Xml', , Iif( Type("oBrw") <> "U",oBrw,Nil) )
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF591XmlErp

Fun��o utilizada para executar a rotina de xml para todos os 
eventos do cadastro do benef�cio

@author Rodrigo Nicolino
@since 13/09/2021
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF591XmlErp()

	Local aOpcoes := {}
	Local cFilBkp := cFilAnt
	Local cMens   := STR0102 //"Selecione o tipo de evento desejado:"
	Local cTitulo := STR0104 //"Compara��o de XML ERP e TAF"
	Local nOpc    := 0

	cFilAnt := Iif( IsInCallStack("TafNewBrowse") .And. ( V75->V75_FILIAL <> cFilAnt ), V75->V75_FILIAL, cFilAnt)

	aOpcoes := TAF591Events()

	nOpc := TAF591OptBen( aOpcoes, , cTitulo, cMens )

	If nOpc > 0
		If nOpc == 9 
			XmlErpxTaf("V75", "TAF592Xml", "S-2410", xFilial("V75"))
		ElseIf nOpc == 10
			XmlErpxTaf("V76", "TAF593Xml", "S-2416", xFilial("V76"))
		ElseIf nOpc == 11
			XmlErpxTaf("V77", "TAF594Xml", "S-2418", xFilial("V77"))
		ElseIf nOpc == 12
			XmlErpxTaf("V78", "TAF595Xml", "S-2420", xFilial("V78"))
		EndIf
	EndIf

	cFilAnt := cFilBkp
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF591DTP

Fun��o utilizada para retornar a descri��o do tipo de beneficio

@author Karyna Rainho
@since 13/09/2021
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAF591DTP(cAlias)

	Local cRet := Posicione("V5Z", 1, xFilial("V5Z") + (cAlias)->&( (cAlias)+"_TPBENE" ),"V5Z_CODIGO + ' - ' + V5Z_DESCRI")

Return cRet
