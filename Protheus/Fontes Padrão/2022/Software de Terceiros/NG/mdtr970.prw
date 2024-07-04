#INCLUDE "MDTR970.CH"
#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR970
Relat�rio de Treinamentos por necessidade legal

@author Felipe Helio dos Santos
@since 04/04/13
/*/
//---------------------------------------------------------------------
Function MDTR970()

	Local	aNGBEGINPRM	:= NGBEGINPRM( )
	Local	aPerg		:= {}
	Local	aArea		:= GetArea()
	Private cPerg		:= PADR( "MDTR970", 10 )

	/*----------------------
	//PADR�O				|
	|  De Necessidade  ?	|
	|  At� Necessidade ?	|
	|  De Treinamento  ?	|
	|  At� Treinamento ?	|
	------------------------*/

	If TRepInUse()
		oReport := ReportDef()
		oReport:SetPortrait()
		oReport:PrintDialog()
	Else
		MDTR970PAD()
	EndIf

	RestArea(aArea)
	NGRETURNPRM(aNGBEGINPRM)

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTR970PAD
Chamada do relat�rio padrao

@author Felipe Helio dos Santos
@since 04/04/13
/*/
//---------------------------------------------------------------------

Static Function MDTR970PAD()

	Local aNGBEGINPRM := NGBEGINPRM( )
	Local wnrel       := "MDTR970"
	Local cString     := "TA0"
	Local cDesc1      := STR0003//"Relat�rio de Treinamentos por Necessidade Legal"
	Local cDesc2      := ""
	Local cDesc3      := ""

	Private aReturn	 := {STR0001, 1, STR0002, 1, 1, 1, "", 1} //"Zebrado"##"Administra��o"
	Private nLastKey := 0
	private titulo	 := STR0003 //"Relat�rio de Treinamentos por Necessidade Legal"
	private tamanho	 := "M"
	Private nomeprog := "MDTR970"
	Private cabec1,cabec2,cabec3

	pergunte(cPerg,.F.)

	wnrel	:= "MDTR970"
	WnRel	:= SetPrint(cString,WnRel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)

	If nLastKey == 27
		Set Filter To
		Return
	EndIf

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Set Filter To
		Return
	EndIf

	RptStatus({|lEnd| MDTRPRINT(@lEnd,wnRel,titulo,tamanho)},titulo)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Imprime relat�rio no modelo TReport

@author Felipe Helio dos Santos
@since 04/04/13
/*/
//---------------------------------------------------------------------
Static Function ReportDef()

	Local oSection1
	Local oSection2
	Local oReport

	oReport := TReport():New("MDTR970",STR0003,cPerg,{|oReport| ReportPrint(oReport)},STR0003)
	//"Relat�rio de Treinamentos por Necessidade Legal"

	Pergunte(oReport:uParam,.F.)

	oSection1 := TRSection():New (oReport,STR0012,{"TA0"} ) // "Necessidade Legal"
	TRCell():New(oSection1, "TA0_CODLEG"			   ,"TA0",STR0012,"@!", 21, , ) // "Necessidade Legal"
	TRCell():New(oSection1, "Capital(TA0->TA0_EMENTA)" ,"TA0",STR0013,    , 80, , ) // "Descri��o da Necessidade Legal"

	oSection2 := TRSection():New (oReport,STR0014,{"TJE"},,,,,,,,,,5 )// "Treinamentos"
	TRCell():New(oSection2, "TJE_CALEND", "TJE", STR0014, "@!", 16, , ) // "Treinamentos"
	TRCell():New(oSection2, "TJE_DESC"  , "TJE", STR0015,     , 20, , {|| Capital(NGSEEK('RA2',TJE->TJE_CALEND,1,'RA2->RA2_DESC')) })
	// "Nome do Treinamento"

Return oReport

//---------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Imprime relat�rio personalizado

@author Felipe Helio dos Santos
@since 04/04/13
/*/
//---------------------------------------------------------------------
Static Function ReportPrint(oReport)

	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local nContTJE  := 0

	If oReport:Cancel()
		Return .T.
	EndIf

	oReport:SetMeter(RecCount())

	DbSelectArea("TA0")
	DbGoTop()

	oSection1:Init()
	DbSelectArea("TA0")
	DbSetOrder(01)
	DbSeek(xFilial("TA0")+MV_PAR01,.T.)
		If EoF()
			MsgInfo(STR0016,STR0017) //"N�o existem dados para montar o relat�rio!"###"ATEN��O"
			Return .F.
		EndIf
		While !EoF() .And. xFilial("TA0") == TA0->TA0_FILIAL .And. TA0->TA0_CODLEG <= MV_PAR02

			// Controle para impress�o de necessidade legal
			nContTJE := 0

			DbSelectArea( "TJE" )
			DbSetOrder( 01 ) // TJE_FILIAL+TJE_CODLEG+TJE_CALEND+TJE_CURSO+TJE_TURMA
			DbSeek( xFilial( "TJE" ) + TA0->TA0_CODLEG )
			While !EoF() .And. TJE->( TJE_FILIAL + TJE_CODLEG ) == xFilial( "TJE" ) + TA0->TA0_CODLEG
				If TJE->TJE_CALEND >= MV_PAR03 .And. TJE->TJE_CALEND <= MV_PAR04
					nContTJE++
				EndIf
				DbSelectArea( "TJE" )
				DbSkip()
			EndDo

			//---------------------------------------------------------------------
			// Omite registro de Necessidade legal caso treinamentos da mesma nao
			// estejam na faixa estabelecida pelos parametros MV_PAR03 e MV_PAR04
			//---------------------------------------------------------------------
			If nContTJE == 0
				DbSelectArea( "TA0" )
				DbSkip()
				Loop
			EndIf

			oSection1:Init()
			oSection1:PrintLine()

			DbSelectArea("TJE")
			DbSetOrder(01) //TJE_FILIAL+TJE_CODLEG+TJE_CALEND+TJE_CURSO+TJE_TURMA
			DbSeek(xFilial("TJE")+TA0->TA0_CODLEG)
			While !EoF() .And. TJE->( TJE_FILIAL + TJE_CODLEG ) == xFilial( "TJE" ) + Padr( TA0->TA0_CODLEG,TAMSX3( "TJE_CODLEG" )[1] )

				If TJE->TJE_CALEND < MV_PAR03 .Or. TJE->TJE_CALEND > MV_PAR04
					DbSelectArea( "TJE" )
					DbSkip()
					Loop
				EndIf

				oReport:IncMeter()
				oSection2:Init()
				oSection2:PrintLine()

				DbSelectArea("TJE")
				DbSkip()
			EndDo

			DbSelectArea("TA0")
			DbSkip()
			oSection2:Finish()
			oSection1:Finish()
		EndDo

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MDTRPRINT
Fun��o para imprimir o relat�rio padr�o

@author Felipe Helio dos Santos
@since 04/04/13
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function MDTRPRINT(lEND,WNREL,Titulo,Tamanho)

	Local cRODATXT   := ""
	Local nCNTIMPR   := 0
	Local nContTJE   := 0

	Private li := 80 ,m_pag := 1

	nTIPO  := IIf(aReturn[4]==1,15,18)

	CABEC1 := STR0018
	CABEC2 := STR0019

	/*/
	0         1         2         3         4         5         6         7         8         9         0         1         2         3
	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	***********************************************************************************************************************************
	Modelo:                            Treinamento por Necessidade Legal                             Data: 99/99/9999
	Necessidade    Descri��o da Necessidade Legal
			Treinamento   Nome do Treinamento
	***********************************************************************************************************************************
	XXXXXXXXXXXX	 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
					XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

			XXXX          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			XXXX          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			XXXX          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			XXXX          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	XXXXXXXXXXXX	 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

			XXXX          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			XXXX          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			XXXX          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			XXXX          XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	/*/

	NGSOMALI( 58 )

	DbSelectArea("TA0")
	DbSetOrder(01)
	DbSeek(xFilial("TA0")+MV_PAR01,.T.)
	SetRegua(LastRec())

	If EoF()
		MsgInfo(STR0016,STR0017) //"N�o existem dados para montar o relat�rio!"###"ATEN��O"
		Return .F.
	EndIf

	While !EoF() .And. xFilial("TA0") == TA0->TA0_FILIAL .And. TA0->TA0_CODLEG <= MV_PAR02

		// Controle para impress�o de necessidade legal
		nContTJE := 0

		DbSelectArea( "TJE" )
		DbSetOrder( 01 ) // TJE_FILIAL+TJE_CODLEG+TJE_CALEND+TJE_CURSO+TJE_TURMA
		DbSeek( xFilial( "TJE" ) + TA0->TA0_CODLEG )
		While !EoF() .And. TJE->( TJE_FILIAL + TJE_CODLEG ) == xFilial( "TJE" ) + TA0->TA0_CODLEG
			If TJE->TJE_CALEND >= MV_PAR03 .And. TJE->TJE_CALEND <= MV_PAR04
				nContTJE++
			EndIf
			DbSelectArea( "TJE" )
			DbSkip()
		EndDo

		// Omite registro de Necessidade legal caso treinamentos da mesma nao
		// estejam na faixa estabelecida pelos parametros MV_PAR03 e MV_PAR04
		If nContTJE == 0
			DbSelectArea( "TA0" )
			DbSkip()
			Loop
		EndIf

		@Li,00 Psay TA0->TA0_CODLEG
		@Li,15 Psay Capital(TA0->TA0_EMENTA)

		NGSOMALI( 58 )

		DbSelectArea("TJE")
		DbSetOrder(01) //TJE_FILIAL+TJE_CODLEG+TJE_CALEND+TJE_CURSO+TJE_TURMA
		DbSeek(xFilial("TJE")+TA0->TA0_CODLEG)

			While !EoF() .And. xFILIAL("TJE") == TJE->TJE_FILIAL .And. TJE->TJE_CODLEG == TA0->TA0_CODLEG

				If TJE->TJE_CALEND < MV_PAR03 .Or. TJE->TJE_CALEND > MV_PAR04
					DbSelectArea( "TJE" )
					DbSkip()
					Loop
				EndIf

				@ Li,009 Psay TJE->TJE_CALEND
				@ Li,022 Psay Capital(NGSEEK( "RA2",TJE->TJE_CALEND,1,"RA2->RA2_DESC" ))
				NGSOMALI( 58 )

				DbSelectArea("TJE")
				DbSkip()
			EndDo

		IncRegua()
		NGSOMALI(58)

		DbSelectArea("TA0")
		DbSkip()

	EndDo

	Roda(nCntImpr,cRodaTxt,Tamanho)

	// Devolve a condicao original do arquivo principal

	RetIndex("TA0")
	Set Filter To
	Set Device to Screen
	If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
	EndIf
	MS_FLUSH()

Return

//---------------------------------------------------------------------
/*/{Protheus.doc}
Valida parametros de SX1
@Parametros   - vPar01 : Primeiro par�metro (De)
		 		- vPar02 : Segundo par�metro  (At�)
				- nOpc   : Op��o (1=De,2=At�)
				- cAlias : Tabela de pesquisa

@Author Felipe Helio dos Santos
@Since 04/04/13
@Return L�gico
/*/
//---------------------------------------------------------------------
Function MDTR970VSX(vPar01,vPar02,nOpc,cAlias)

	If nOpc == 1
		If !Empty(vPar01) .And. !ExistCpo(cAlias,vPar01)
			Return .F.
		EndIf
		If !Empty(vPar01) .And. !Empty(vPar02) .And. vPar01 > vPar02
			ShowHelpDlg(STR0017, {STR0020},1,; //"ATEN��O"##"C�digo 'De' n�o pode ser maior que o c�digo 'At�'."
									{STR0021},1)	//"Informe um c�digo De menor que o c�digo At�."
			Return .F.
		EndIf
	ElseIf nOpc == 2
		If Empty(vPar02)
			ShowHelpDlg(STR0017,	{STR0022},1,; //"ATEN��O"##"C�digo At� n�o pode ser vazio."
									{STR0023},1)  //"Informe um c�digo."
			Return .F.
		ElseIf vPar02 < vPar01
			ShowHelpDlg(STR0017,	{STR0024},1,; //"ATEN��O"##"C�digo At� n�o pode ser menor que o c�digo De."
									{STR0025},1)  //"Informe um c�digo 'At'� maior que o c�digo 'De'."
			Return .F.
		EndIf
		If vPar02 = Replicate('Z',Len(vPar01))
			Return .T.
		EndIf
		If !Empty(vPar02) .And. !ExistCpo(cAlias,vPar02)
			Return .F.
		EndIf
	EndIf

Return