#INCLUDE "Protheus.ch"
#INCLUDE "MNTR881.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTR881
Relat�rio de movimenta��es do pneu

@author Andr� Felipe Joriatti
@since 28/02/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------

Function MNTR881( cBemPneu )

	Local aArea := GetArea()

	// Vari�veis padr�o para relat�rio Protheus
	Private WNREL    := "MNTR881"
	Private Limite   := 155
	Private cDesc1   := STR0001 // "Relat�rio de Movimenta��o do Pneu"
	Private cDesc2   := ""
	Private cDesc3   := ""
	Private cString  := "STZ"
	Private NomeProg := "MNTR881"
	Private Tamanho  := "G"
	Private aReturn  := { "Zebrado",1,"Administracao",1,2,1,"",1 }
	Private Titulo   := STR0002 // "Relat�rio de Movimenta��o do Pneu"
	Private nTipo    := 0
	Private nLastKey := 0
	Private CABEC1   := ""
	Private CABEC2   := ""

	// Vari�veis espec�ficas da rotina
	Private cGRPPerg := ""
	Private cTrbMov  := GetNextAlias()
	Private aDBFMov  := {}
	Private cPneu    := cBemPneu

	DbSelectArea( "SX1" )
	cGRPPerg := PadR( "MNT881",Len(Posicione("SX1", 1, "MNT881", "X1_GRUPO")) )

	// Inicializa vari�veis de perguntas
	Pergunte( cGRPPerg,.F. )

	// Envia controle para fun��o SetPrint
	WNREL := SetPrint( cString,WNREL,If( Empty( cPneu ),cGRPPerg,Nil ),Titulo,cDesc1,cDesc2,cDesc3,.F.,"" )

	If nLastKey == 27
		Set Filter To
	Else

		SetDefault( aReturn,cString )

		If !Empty( cPneu )

			MV_PAR01 := cPneu

			// De/At� Data Entrada
			MV_PAR02 := CTOD( "  /  /    " )
			MV_PAR03 := CTOD( "  /  /    " )

			// De/At� Data Fim
			MV_PAR04 := CTOD( "  /  /    " )
			MV_PAR05 := CTOD( "  /  /    " )

		EndIf

		// Impress�o do relat�rio
		RptStatus( { |lEnd| MNT881IMP( @lEnd,WNREL,Titulo,Tamanho ) },Titulo )

	EndIf

	RestArea( aArea )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT881IMP
Impress�o do relat�rio

@author Andr� Felipe Joriatti
@since 28/02/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function MNT881IMP( lEnd,WNREL,Titulo,Tamanho )

	Private cRODATXT := ""
	Private nCNTIMPR := 0
	Private li       := 80
	Private m_pag    := 1

	nTIPO  := IIf( aReturn[4] == 1,15,18 )

	// Processa movimenta��es do Pneu
	Processa( { |lEnd| fLoadMov() },STR0003,STR0004 ) // "Aguarde..."###"Processando Registros..."

	// Carrega relat�rio
	Processa( { |lEnd| fLoadReport() },STR0003,STR0005 ) // "Aguarde..."###"Processando Registros..."

	Roda( nCNTIMPR,cRODATXT,Tamanho )

	Set Filter To
	Set Device To Screen

	If aReturn[5] == 1 .And. Contar( cTrbMov,".T." ) > 0

		Set Printer To
		DbCommitAll()
		OurSpool( WNREL )

	ElseIf ( cTrbMov )->( RecCount() ) == 0
		MsgInfo( STR0027 ) // "N�o existem dados para imprimir o relat�rio."
	EndIf

	MS_FLUSH()

	( cTrbMov )->( DbCloseArea() )

	DbSelectArea( "ST9" ) // Bens
	DbSelectArea( "STZ" ) // Movimenta��es

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} MNT881VLD
Valida��o das perguntas do relat�rio

@author Andr� Felipe Joriatti
@since 28/02/2014
@version MP11
@return Boolean: conforme resultado da avalia��o das perguntas do relat�rio
/*/
//---------------------------------------------------------------------

Function MNT881VLD()

	Local lRet := .T.

	Do Case

		Case ReadVar() == "MV_PAR01"
		lRet := If( Empty( MV_PAR01 ),.F.,NGSEEKCPO( "ST9",MV_PAR01 ) .And. NGVerPneu( MV_PAR01,.T. ) )
		Case ReadVar() == "MV_PAR02"
		lRet := .T.
		Case ReadVar() == "MV_PAR03"
		lRet := If( MV_PAR03 >= MV_PAR02,.T.,.F. )
		Case ReadVar() == "MV_PAR04"
		lRet := .T.
		Case ReadVar() == "MV_PAR05"
		lRet := If( MV_PAR05 >= MV_PAR04,.T.,.F. )

	EndCase

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} R881Load
Carrega movimenta��es do Pneu
*USADO NO MNTC125

@param String cPneu: indica c�digo do bem pneu, opcional
@author Andr� Felipe Joriatti
@since 28/02/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------

Function R881Load( cPneu )

	Local cQuery

	cPneu := If( IsInCallStack( "MNTR881" ),MV_PAR01,cPneu )

	DbSelectArea( cTrbMov )
	ZAP

	cQuery := "SELECT TZ_BEMPAI,TZ_LOCALIZ,TZ_DATAMOV,TZ_HORAENT,TZ_DATASAI,"
	cQuery += "        TZ_HORASAI,T8_NOME,STZ.R_E_C_N_O_ AS RECNO,"
	cQuery += " (SELECT MAX(TP_ACUMCON) FROM " + RetSQLName( "STP" ) + " STP1 "
	cQuery += "  WHERE STP1.D_E_L_E_T_ <> '*' AND TP_FILIAL = " + ValToSQL( xFilial("STP") )
	cQuery += "    AND TP_CODBEM = TZ_BEMPAI AND (TP_DTLEITU||TP_HORA) <= (TZ_DATAMOV||TZ_HORAENT)) AS KMENTRADA,"
	cQuery += " (SELECT MAX(TP_ACUMCON) FROM " + RetSQLName( "STP" ) + " STP2 "
	cQuery += "  WHERE STP2.D_E_L_E_T_ <> '*' AND TP_FILIAL = " + ValToSQL( xFilial( "STP" ) )
	cQuery += "    AND TP_CODBEM = TZ_BEMPAI AND (REPLACE(TZ_DATASAI, ' ', '') = '' OR ((TP_DTLEITU||TP_HORA) <= (TZ_DATASAI||TZ_HORASAI)))) AS KMSAIDA,"
	cQuery += " (SELECT MAX(TP_ACUMCON) FROM " + RetSQLName( "STP" ) + " STP3 "
	cQuery += "  WHERE STP3.D_E_L_E_T_ <> '*' AND TP_FILIAL = " + ValToSQL( xFilial( "STP" ) )
	cQuery += "    AND TP_CODBEM = TZ_CODBEM AND (REPLACE(TZ_DATASAI, ' ', '') = '' OR ((TP_DTLEITU||TP_HORA) <= (TZ_DATASAI||TZ_HORASAI)))) AS KMPNEU,"
	cQuery += "       (SELECT MAX(TP_ACUMCON)"
	cQuery += "          FROM " + RetSQLName( "STP" ) + " STP2"
	cQuery += "         WHERE STP2.D_E_L_E_T_ <> '*'"
	cQuery += "           AND TP_FILIAL = " + ValToSQL(xFilial("STP"))
	cQuery += "           AND TP_CODBEM = TZ_BEMPAI"
	cQuery += "           AND (REPLACE(TZ_DATASAI, ' ', '') = ''"
	cQuery += "            OR ((TP_DTLEITU||TP_HORA) <= (TZ_DATASAI||TZ_HORASAI))))-"
	cQuery += "       (SELECT MAX(TP_ACUMCON)"
	cQuery += "          FROM " + RetSQLName( "STP" ) + " STP1"
	cQuery += "         WHERE STP1.D_E_L_E_T_ <> '*'"
	cQuery += "           AND TP_FILIAL = " + ValToSQL(xFilial("STP"))
	cQuery += "           AND TP_CODBEM = TZ_BEMPAI"
	cQuery += "           AND (TP_DTLEITU||TP_HORA) <= (TZ_DATAMOV||TZ_HORAENT)) AS DIFERENCA"
	cQuery += " FROM " + RetSQLName( "STZ" ) + " STZ"
	cQuery += " LEFT JOIN " + RetSQLName( "ST8" ) + " ST8 ON ST8.D_E_L_E_T_ <> '*' AND T8_FILIAL = " + ValToSQL( xFilial( "ST8" ) )
	cQuery += "     AND T8_CODOCOR = TZ_CAUSA"
	cQuery += " WHERE STZ.D_E_L_E_T_ <> '*' AND TZ_FILIAL = " + ValToSQL( xFilial( "STZ" ) )
	cQuery += "   AND TZ_CODBEM = " + ValToSQL( cPneu )

	// Aplica filtro de Data caso n�o seja chamada externa
	If IsInCallStack( "MNTR881" ) .And. Empty( cPneu )
		cQuery += " AND TZ_DATAMOV BETWEEN '" + DTOS( MV_PAR02 ) + "' AND '" + DTOS( MV_PAR03 ) + "'"
		cQuery += " AND TZ_DATASAI BETWEEN '" + DTOS( MV_PAR04 ) + "' AND '" + DTOS( MV_PAR05 ) + "'"
	EndIf

	cQuery += " ORDER BY TZ_FILIAL,TZ_CODBEM,TZ_DATAMOV,TZ_HORAENT"

	SQLToTRB( cQuery,aDBFMov,cTrbMov )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} R881CriaTRB
Cria��o da TRB de movimenta��es do Pneu
*USADO NO MNTC125

@author Andr� Felipe Joriatti
@since 28/02/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------

Function R881CriaTRB()

	Private AVETINR := {}

	aAdd( aDBFMov,{ "TZ_FILIAL"  ,"C",TAMSX3( "TZ_FILIAL" )[1],  0 } )
	aAdd( aDBFMov,{ "TZ_CODBEM"  ,"C",TAMSX3( "TZ_CODBEM" )[1],  0 } )
	aAdd( aDBFMov,{ "TZ_BEMPAI"  ,"C",TAMSX3( "TZ_BEMPAI" )[1],  0 } )
	aAdd( aDBFMov,{ "TZ_LOCALIZ" ,"C",TAMSX3( "TZ_LOCALIZ" )[1], 0 } )
	aAdd( aDBFMov,{ "TZ_DATAMOV" ,"D", 08 , 0 } )
	aAdd( aDBFMov,{ "TZ_HORAENT" ,"C", 05 , 0 } )
	aAdd( aDBFMov,{ "TZ_DATASAI" ,"D", 08 , 0 } )
	aAdd( aDBFMov,{ "TZ_HORASAI" ,"C", 05 , 0 } )
	aAdd( aDBFMov,{ "KMSAIDA"    ,"N", 12 , 0 } )
	aAdd( aDBFMov,{ "KMENTRADA"  ,"N", 12 , 0 } )
	aAdd( aDBFMov,{ "DIFERENCA"  ,"N", 12 , 0 } )
	aAdd( aDBFMov,{ "KMPNEU"     ,"N", 12 , 0 } )
	aAdd( aDBFMov,{ "T8_NOME"    ,"C", 20 , 0 } )
	aAdd( aDBFMov,{ "RECNO" ,"N", 16 , 0 } )

	//Cria Tabela Tempor�ria
	oARQTR110 := NGFwTmpTbl(cTrbMov,aDBFMov,{{"TZ_FILIAL","TZ_CODBEM","TZ_DATAMOV","TZ_HORAENT"}})

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadMov
Carrega TRB de movimenta��es do Pneu

@author Andr� Felipe Joriatti
@since 28/02/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fLoadMov()

	// Cria��o de TRB
	R881CriaTRB()

	// Carrega dados da TRB de movimenta��o
	R881Load()

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadReport
Carrega relat�rio de movimenta��es

@author Andr� Felipe Joriatti
@since 28/02/2014
@version MP11
@return Nil
/*/
//---------------------------------------------------------------------

Static Function fLoadReport()

	ProcRegua( LastRec() )

	// Posiciona no registro TQS e ST9 correspondente ao pneu
	Posicione( "TQS",01,xFilial( "TQS" ) + MV_PAR01,"TQS_FILIAL" )
	Posicione( "ST9",01,xFilial( "ST9" ) + MV_PAR01,"T9_FILIAL" )

	NGSOMALI( 58 )

	@ Li,000 PSay Replicate( " ",095 ) + STR0016 // "Hist�rico de Movimenta��o"

	NGSOMALI( 58 )

	@ Li,000 PSay Replicate( "*",220 )

	NGSOMALI( 58 )
	@ Li,000 PSay STR0017 + AllTrim( MV_PAR01 ) + " - " + ST9->T9_NOME // "Pneu: "
	@ Li,070 PSay STR0018 + AllTrim( ST9->T9_STATUS ) + " - " + NGSEEK( "TQY",ST9->T9_STATUS,01,"TQY->TQY_DESTAT" ) // "Status: "
	NGSOMALI( 58 )
	@ Li,000 PSay STR0019 + cValToChar( TQS->TQS_SULCAT ) // "Sulco Atual: "
	@ Li,040 PSay STR0020 + DTOC( TQS->TQS_DTMEAT ) // "Dt. Sulco At.: "
	@ Li,070 PSay STR0021 + TQS->TQS_HRMEAT // "Hr. Med. Sulco: "
	NGSOMALI( 58 )
	@ Li,000 PSay STR0022 + TQS->TQS_DOT // "DOT: "
	@ Li,040 PSay STR0023 + NGRetSX3Box( "TQS_BANDAA",TQS->TQS_BANDAA ) // "Cod. Band. At.: "
	NGSOMALI( 58 )
	@ Li,000 PSay STR0024 + AllTrim( TQS->TQS_MEDIDA ) + " - " + AllTrim( NGSEEK( "TQT",TQS->TQS_MEDIDA,01,"TQT->TQT_DESMED" ) ) // "Medida Pneu: "
	@ Li,040 PSay STR0025 + cValToChar( ST9->T9_CONTACU ) // "Cont. Acumul.: "

	NGSOMALI( 58 )

	@ Li,000 PSay Replicate( "*",220 )

	NGSOMALI( 58 )

	// Cabe�alho
	@ Li,000 PSay STR0026 // "Bem Pai           Localiza��o       Dt. Entrada     Hora    Dt. Sa�da    Hora    Acumul.Ini.Ve�culo      Acumul.Fim.Ve�culo    Cont. Rodado      Acumul. Pneu    Motivo"

	NGSOMALI( 58 )

	DbSelectArea( cTrbMov )
	DbGoTop()

	While !EoF()

		IncProc( STR0003,STR0005 ) // "Aguarde..." ### "Imprimindo Relat�rio..."

		NGSOMALI( 58 )

		@ Li,000 PSay ( cTrbMov )->TZ_BEMPAI Picture "@!" // Bem Pai
		@ Li,018 PSay ( cTrbMov )->TZ_LOCALIZ Picture "@!" // Localiza��o
		@ Li,036 PSay ( cTrbMov )->TZ_DATAMOV Picture "99/99/9999" // Dt. Entrada
		@ Li,052 PSay ( cTrbMov )->TZ_HORAENT Picture "@!" // Hora
		@ Li,060 PSay ( cTrbMov )->TZ_DATASAI Picture "99/99/9999" // Dt. Sa�da
		@ Li,073 PSay ( cTrbMov )->TZ_HORASAI Picture "@!" // Hora
		@ Li,084 PSay ( cTrbMov )->KMENTRADA Picture "@E 999,999,999,999" // Acumul. Ini. Ve�culo
		@ Li,108 PSay ( cTrbMov )->KMSAIDA Picture "@E 999,999,999,999" // Acumul. Fim. Ve�culo
		@ Li,124 PSay ( cTrbMov )->DIFERENCA Picture "@E 999,999,999,999" // Cont. Rodado
		@ Li,142 PSay ( cTrbMov )->KMPNEU Picture "@E 999,999,999,999" // Acumul. Pneu
		@ Li,161 PSay ( cTrbMov )->T8_NOME Picture "@!" // Motivo

		DbSelectArea( cTrbMov )
		DbSkip()

	End While

Return Nil