#Include "PROTHEUS.CH"
#INCLUDE "GPER625.CH"

Static cAliasTMP

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER625  ³ Autor ³ Ricardo Berti                   ³ Data ³04/10/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao do Informe de Assegurados por Empresa - 						³±±
±±³          ³ APORTE CAJA DE SALUD DE LA BANCA PRIVADA                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER625()                                                          	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista	 ³ Data     ³ CHAMADO      ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³06/05/2015³    PCREQ-4256³Se elimina la funcion AjustaSX1, la cual  ³±±
±±³            ³          ³              ³realiza la modificacion aldiccionario de  ³±±
±±³            ³          ³              ³datos(SX1) por motivo de adecuacion  nueva³±±
±±³            ³          ³              ³estructura de SXs para version 12         ³±±
±±³L.Enríquez  ³30/01/2017³SERINN001-824 ³Merge 12.1.15 Se elimina utilización de   ³±±
±±³            ³          ³              ³función CriaTrab para utilizar clase      ³±±
±±³            ³          ³              ³FWTemporaryTable y asi evitar creación de ³±±
±±³            ³          ³              ³archivo .dtc en carpeta system.           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER625()
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Locais (Basicas)                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Local cDesc1 		:= STR0001		//"Aportes Caja de Salud de la Banca Privada"
	Local cDesc2 		:= STR0002		//"Se imprimira de acuerdo con los parametros solicitados por el usuario."
	Local cDesc3 		:= ""
	Local cString		:= "SRA"        // alias do arquivo principal (Base)
	Local aOrd      	:= {STR0004,STR0005,STR0006}	//"Sucursal + Matricula"###"Sucursal+ + C. Costo"###"Sucural + Nombre"

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Define Variaveis Private(Basicas)                            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Private nomeprog	:= "GPER625"
	Private aReturn 	:= { , 1,, 2, 2, 1,"",1 }
	Private nLastKey 	:= 0
	Private cPerg   	:= "GPR625"

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Variaveis Utilizadas na funcao IMPR                          ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Private Titulo 		:= STR0001 // "Aportes Caja de Salud de la Banca Privada"
	Private nTamanho		:= "M"
	Private nOrdem
	Private cFilialDe   	:= ""
	Private cFilialAte  	:= ""
	Private cMes			:= ""
	Private cAno			:= ""
	Private cMatDe     	:= ""
	Private cMatAte     	:= ""
	Private cCustoDe    	:= ""
	Private cCustoAte   	:= ""
	Private cNomeDe     	:= ""
	Private cNomeAte    	:= ""
	Private cSit        	:= ""
	Private cCat        	:= ""

	Private oPrint

	//-- Objeto para impressao grafica
	oPrint 	:= TMSPrinter():New( STR0001 ) //"Aportes Caja de Salud de la Banca Privada"



	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Variaveis utilizadas para parametros                         ³
	³ mv_par01        //  Filial De						           ³
	³ mv_par02        //  Filial Ate					           ³
	³ mv_par03        //  Mes/Ano Competenc.MMAAAA?		           |
	³ mv_par04        //  Matricula De                             ³
	³ mv_par05        //  Matricula Ate                            ³
	³ mv_par06        //  Centro de Custo De                       ³
	³ mv_par07        //  Centro de Custo Ate                      ³
	³ mv_par08        //  Nome De                                  ³
	³ mv_par09        //  Nome Ate                                 ³
	³ mv_par10        //  Situacoes ?       		               ³
	³ mv_par11        //  Categorias? 		                       ³
	³ mv_par12        //  Ordem                                    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	//oPrint:SetLandscape()	//Imprimir Somente Paisagem
	If Pergunte(cPerg,.T.,Titulo)

		If Empty(mv_par03)
			Help(" ",1,"XINVMESANO")
			Return (.F.)
		EndIf

		cFilialDe 	:= mv_par01
		cFilialAte  := mv_par02
		cMesAno		:= mv_par03
		cMes 		:= substr( mv_par03, 1, 2 )
		cAno 		:= substr( mv_par03, 3, 4 )
		cMatDe		:= mv_par04
		cMatAte     := mv_par05
		cCustoDe    := mv_par06
		cCustoAte   := mv_par07
		cNomeDe     := mv_par08
		cNomeAte    := mv_par09
		cSit        := mv_par10
		cCat        := mv_par11
		nOrdem		:= mv_par12

		MsgRun(STR0003,"",{|| CursorWait(), ImpAsCajaS() ,CursorArrow()}) //"Gerando relatorio, aguarde..."

		oPrint:Preview()	// Visualiza impressao grafica antes de imprimir

	Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpAsCajaSºAutor  ³Ricardo Berti       º Data ³  04/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obs.: O GPER625 e GPR624Proc() chamam esta mesma funcao,   º±±
±±º			 ³ porem, os mesmos tem perguntes distintos (GPR625 e GPR624) º±±
±±º		 	 ³	 	   Considerar esta inf. ao alterar o SX1. 			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ ImpAsCajaS(ExpL1)                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpL1: = .T., indica se deve gerar apenas o arq. TXT  (OPC)º±±
±±º          ³        = .F.(Default) - imprime apenas o relatorio		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPER625 / GPR624Proc()                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpAsCajaS(lTXT)

	Local cAcessaSRA	:= &( " { || " + ChkRH( "GPER625" , "SRA" , "2" ) + " } " )
	Local aPerAberto    := {}
	Local aPerFechado   := {}
	Local aPerTodos		:= {}
	Local aCodFol		:= {}
	Local aTabela		:= {}

	Local nAux		:= 0
	Local nLin		:= 0380
	Local cFilAnt
	Local cPeriodos	:= ''
	Local lAux		:= .F.
	Local lMsgS001	:= .F.

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Variaveis para controle em ambientes TOP.                    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Local cAlias   := ""
	Local cQrySRC  := "SRC"
	Local cQrySRD  := "SRD"
	Local cCateg   := ''
	Local cSitu    := ''
	Local cQuery   := ''
	Local cQueryOrd:= ""
	Local aStruct  := {}

	DEFAULT lTXT := .F.

	//variaveis contendo valores para impressao
	Private aInfo 	  := {}     //armazena dados da filial
	Private nNum	  := 0
	Private nTotGanad := 0
	Private nTotAport := 0
	Private nGTotGanad:= 0
	Private nGTotAport:= 0
	Private cQrySRA   := "SRA"
	Private dDataRef
	Private cTime	  := Time()
	Private dData	  := dDataBase

	Private oFont07, oFont07n, oFont09, oFont09n, oFont10, oFont12n
	oFont06	:= TFont():New("Courier New",06,06,,.F.,,,,.T.,.F.)
	oFont06n	:= TFont():New("Courier New",06,06,,.T.,,,,.T.,.F.) //Negrito//
	oFont07	:= TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)
	oFont07n	:= TFont():New("Courier New",07,07,,.T.,,,,.T.,.F.) //Negrito//
	oFont08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
	oFont08n	:= TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.) //Negrito//
	oFont09	:= TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.)
	oFont09n	:= TFont():New("Courier New",09,09,,.T.,,,,.T.,.F.) //Negrito//
	oFont10 	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
	oFont12n	:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.) //Negrito//

	nEpoca:= SET(5,1910)
	//-- MUDAR ANO PARA 4 DIGITOS
	SET CENTURY ON

	If nOrdem == 1
		cQueryOrd := "RA_FILIAL,RA_MAT"
	ElseIf nOrdem == 2
		cQueryOrd := "RA_FILIAL,RA_CC,RA_MAT"
	ElseIf nOrdem == 3
		cQueryOrd := "RA_FILIAL,RA_NOME,RA_MAT"
	EndIf

	cAlias := "SRA"
	cQrySRA := "QSRA"
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Buscar Situacao e Categoria em formato para SQL              ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cSitu   := "("
	For nAux := 1 To (Len( cSit )-1)
		cSitu += "'" + Substr( cSit, nAux, 1) + "',"
	Next nAux
	cSitu 	+= "'" + Substr( cSit, len(cSit), 1) + "')"

	cCateg   := "("
	For nAux := 1 To (Len( cCat )-1)
		cCateg += "'" + Substr( cCat, nAux, 1) + "',"
	Next nAux
	cCateg	+= "'" + Substr( cCat, len(cCat)-1, 1) + "')"

	//montagem da query
	cQuery := "SELECT"
	cQuery += " RA_FILIAL, RA_MAT, RA_CC, RA_ADMISSA, RA_PROCES, RA_CIC, RA_UFCI,"
	cQuery += " RA_PRINOME, RA_SECNOME, RA_PRISOBR, RA_SECSOBR, RA_BCDEPSA"
	cQuery += " FROM " + RetSqlName(cAlias)
	cQuery += " WHERE "
	cQuery += " RA_FILIAL BETWEEN '" + cFilialDe + "' AND '" + cFilialAte + "'"
	cQuery += "  AND "
	cQuery += " RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "'"
	cQuery += "  AND "
	cQuery += " RA_NOME BETWEEN '" + cNomeDe + "' AND '" + cNomeAte + "'"
	cQuery += "  AND "
	cQuery += " RA_CC BETWEEN '" + cCustoDe + "' AND '" + cCustoAte + "'"
	cQuery += "  AND "
	cQuery += " RA_SITFOLH IN " + cSitu
	cQuery += "  AND "
	cQuery += " RA_CATFUNC IN " + cCateg
	cQuery += "  AND "
	cQuery += " D_E_L_E_T_ <> '*'
	cQuery += " ORDER BY " + cQueryOrd

	cQuery := ChangeQuery(cQuery)
	aStruct := (cAlias)->(dbStruct())

	If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRA,.T.,.T.)
		For nAux := 1 To Len(aStruct)
			If ( aStruct[nAux][2] <> "C" )
				TcSetField(cQrySRA,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
			EndIf
		Next nAux
	EndIf

	dbSelectArea(cQrySRA)
	(cQrySRA)->(dbGoTop())

	dDataRef := ctod(Transform(f_UltDia(cToD("01/"+cMes+"/"+cAno)),"99")+"/"+cMes+"/"+cAno)

	//carrega periodo da competencia selecionada
	fRetPerComp( cMes , cAno , , , , @aPerAberto , @aPerFechado , @aPerTodos )

	fInfo(@aInfo,cFilialDe)			// carrega dados da filial

	While (cQrySRA)->( !Eof() )

		If cFilAnt <> (cQrySRA)->RA_FILIAL

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Carrega Variaveis Codigos Da Folha                           ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If !fP_CodFol(@aCodFol,(cQrySRA)->RA_FILIAL)
				Return
			EndIf
			cFilAnt := (cQrySRA)->RA_FILIAL

		EndIf

		If SRA->RA_ADMISSA > dDataRef  //se o funcionario foi admitido depois da competencia selecionada
			(cQrySRA)->(dbSkip())
			Loop
		EndIf

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Consiste Filiais e Acessos                                             ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF !((cQrySRA)->RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA )
			dbSelectArea("SRA")
			SRA->( dbSkip() )
			Loop
		EndIf

		//zera as variaveis para cada funcionario
		nTotGanad := 0
		nTotAport := 0

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Procura no SRC registros do funcionario no periodo aberto, se houver   |
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !(len(aPerAberto) < 1)
			cAlias := "SRC"
			cQrySRC := "QSRC"

			//busca periodos para formato Query
			cPeriodos   := "("
			For nAux:= 1 to (len(aPerAberto)-1)
				cPeriodos += "'" + aPerAberto[nAux][1] + "',"
			Next nAux
			cPeriodos += "'" + aPerAberto[len(aPerAberto)][1]+"')"

			//montagem da query
			cQuery := "SELECT"
			cQuery += " RC_FILIAL, RC_MAT, RC_PROCES, RC_ROTEIR, RC_PERIODO, RC_SEMANA, RC_VALOR, RC_PD"
			cQuery += " FROM " + RetSqlName(cAlias)
			cQuery += " WHERE"
			cQuery += " RC_FILIAL = '" + cFilAnt + "'"
			cQuery += " AND"
			cQuery += " RC_MAT = '" + (cQrySRA)->RA_MAT + "'"
			cQuery += " AND"
			cQuery += " RC_PERIODO IN " + cPeriodos
			cQuery += " AND"
			cQuery += " D_E_L_E_T_ <> '*'
			cQuery += " ORDER BY RC_FILIAL, RC_MAT, RC_PROCES, RC_ROTEIR, RC_PERIODO, RC_SEMANA"

			cQuery := ChangeQuery(cQuery)
			aStruct := (cAlias)->(dbStruct())

			If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRC,.T.,.T.)
				For nAux := 1 To Len(aStruct)
					If ( aStruct[nAux][2] <> "C" )
						TcSetField(cQrySRC,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
					EndIf
				Next nAux
			EndIf

			While (cQrySRC)->(!Eof()) .And. (cQrySRA)->(RA_FILIAL+RA_MAT) == (cQrySRC)->(RC_FILIAL+RC_MAT)
				Do Case
					Case (cQrySRC)->RC_PD == aCodFol[747,1]
					nTotGanad+= (cQrySRC)->RC_VALOR
					Case (cQrySRC)->RC_PD == aCodFol[0054,1] // desconta faltas do Ganho para bater liquido.
					nTotGanad -= (cQrySRC)->RC_VALOR
					Case (cQrySRC)->RC_PD == aCodFol[1237,1] // desconta domingos do Ganho para bater liquido.
					nTotGanad -= (cQrySRC)->RC_VALOR
				EndCase
				(cQrySRC)->(dbSkip())
			EndDo
			(cQrySRC)->(dbCloseArea())
		EndIf

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Procura no SRD registros do funcionario no periodo fechado, se houver  |
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If	!(len(aPerFechado) < 1)
			cAlias := "SRD"
			cQrySRD := "QSRD"

			//busca periodos para formato Query
			cPeriodos   := "("
			For nAux:= 1 to (len(aPerFechado)-1)
				cPeriodos += "'" + aPerFechado[nAux][1] + "',"
			Next nAux
			cPeriodos += "'" + aPerFechado[len(aPerFechado)][1]+"')"

			//montagem da query
			cQuery := "SELECT"
			cQuery += " RD_FILIAL, RD_MAT, RD_PROCES, RD_ROTEIR, RD_PERIODO, RD_SEMANA, RD_VALOR, RD_PD"
			cQuery += " FROM " + RetSqlName(cAlias)
			cQuery += " WHERE"
			cQuery += " RD_FILIAL = '" + cFilAnt + "'"
			cQuery += " AND"
			cQuery += " RD_MAT = '" + (cQrySRA)->RA_MAT + "'"
			cQuery += " AND"
			cQuery += " RD_PERIODO IN " + cPeriodos
			cQuery += " AND"
			cQuery += " D_E_L_E_T_ <> '*'
			cQuery += " ORDER BY RD_FILIAL, RD_MAT, RD_PROCES, RD_ROTEIR, RD_PERIODO, RD_SEMANA"

			cQuery := ChangeQuery(cQuery)
			aStruct := (cAlias)->(dbStruct())
			If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRD,.T.,.T.)
				For nAux := 1 To Len(aStruct)
					If ( aStruct[nAux][2] <> "C" )
						TcSetField(cQrySRD,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
					EndIf
				Next nAux
			EndIf

			While (cQrySRD)->(!Eof()) .And.  (cQrySRA)->(RA_FILIAL+RA_MAT) == (cQrySRD)->(RD_FILIAL+RD_MAT)
				Do Case
					Case (cQrySRD)->RD_PD == aCodFol[747,1]
					nTotGanad += (cQrySRD)->RD_VALOR
					Case (cQrySRD)->RD_PD == aCodFol[0054,1] // desconta faltas do Ganho para bater liquido.
					nTotGanad -= (cQrySRD)->RD_VALOR
					Case (cQrySRD)->RD_PD == aCodFol[1237,1] // desconta domingos do Ganho para bater liquido.
					nTotGanad -= (cQrySRD)->RD_VALOR
				EndCase
				(cQrySRD)->(dbSkip())
			EndDo
			(cQrySRD)->(dbCloseArea())
		EndIf

		If nTotGanad > 0

			nTotAport := Round(nTotGanad*0.1,2)  // 10% Aporte

			If lTXT
				G624Grava()	//Grava reg. arq. temporario
			Else
				//controle de impressao
				If nLin == 0380
					ImpCabec()
				EndIf

				ImpInfFunc(@nLin)
				nLin+= 30

				If nLin > 2200
					ImpRodape(@nLin)
					nLin := 0380
				EndIf
			EndIf

			nGTotGanad += nTotGanad
			nGTotAport += nTotAport

		EndIf

		(cQrySRA)->(dbSkip())
	EndDo

	If !lTXT

		If Empty(aInfo)
			fInfo(@aInfo,cFilialDe)
		EndIf

		If nLin > 2150
			ImpRodape(@nLin)
			nLin := 0380
			ImpCabec(.T.)
		EndIf

		If nGTotGanad > 0
			ImpTotais(@nLin)
		EndIf

	EndIf

	If Select(cQrySRA) > 0
		(cQrySRA)->(dbCloseArea())
	EndIf
	If Select(cQrySRD) > 0
		(cQrySRD)->(dbCloseArea())
	EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpCabec  ºAutor  ³Ricardo Berti       º Data ³  04/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do cabecalho                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpCabec(lTotal)

	DEFAULT lTotal := .F.

	oPrint:StartPage() 			//Inicia uma nova pagina
	oPrint:say ( 0050, 0030, aInfo[3], oFont09)		//razao social da filial

	oPrint:say ( 0050, 1970, STR0007, oFont09)	//"FECHA: "
	oPrint:say ( 0050, 2120, DToC(dData), oFont09)

	oPrint:say ( 0090, 1970, STR0008, oFont09)	//"HORA: "
	oPrint:say ( 0090, 2120, cTime , oFont09)

	oPrint:say ( 0100, 0680, STR0001, oFont12n )   //"Aportes Caja de Salud de la Banca Privada"
	oPrint:say ( 0150, 0890, STR0009+Upper(ALLTrim(MesExtenso(cMes)))+" "+STR0010 +" "+cAno, oFont10  )   //"MES DE "   //"DE"

	oPrint:say ( 0185, 0660, Replicate("-", 52), oFont10)
	oPrint:say ( 0190, 0660, Replicate("-", 52), oFont10)

	If !lTotal

		oPrint:say ( 0290, 0060, STR0011, oFont07)		//"No."
		oPrint:say ( 0290, 0150, STR0012, oFont07)		//"CI"
		oPrint:say ( 0290, 0330, STR0013, oFont07)		//"Exp"
		oPrint:say ( 0290, 0400, STR0014, oFont07)		//"Sucursal"
		oPrint:say ( 0290, 0580, STR0015, oFont07)		//"Agencia"
		oPrint:say ( 0290, 0780, STR0016, oFont07)		//"Nombre"
		oPrint:say ( 0290, 1500, STR0017, oFont07)		//"Total Ganado Real"
		oPrint:say ( 0290, 1860, STR0018, oFont07)		//"Aporte 10%"
		oPrint:say ( 0305, 0060, Replicate("_", 93), oFont10)

	EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpInfFuncºAutor  ³Erika Kanamori      º Data ³  03/19/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao das informacoes do funcionario.                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpInfFunc(nLin)

	Local cNome := 	Ltrim(Rtrim((cQrySRA)->RA_PRISOBR) + Space(1)) +;
	Ltrim(Rtrim((cQrySRA)->RA_SECSOBR) + Space(1)) +;
	Ltrim(Rtrim((cQrySRA)->RA_PRINOME) + Space(1)) +;
	Alltrim((cQrySRA)->RA_SECNOME)

	oPrint:say ( nLin, 0055, Str(++nNum,6), oFont07)
	oPrint:say ( nLin, 0150, (cQrySRA)->RA_CIC, oFont07)
	oPrint:say ( nLin, 0330, (cQrySRA)->RA_UFCI, oFont07)
	oPrint:say ( nLin, 0400, (cQrySRA)->RA_FILIAL, oFont07)
	oPrint:say ( nLin, 0580, (cQrySRA)->RA_BCDEPSA, oFont07)
	oPrint:say ( nLin, 0780, SubStr(cNome,1,40), oFont07)
	oPrint:say ( nLin, 1520, Transform(nTotGanad , "999,999,999.99"), oFont07)
	oPrint:say ( nLin, 1820, Transform(nTotAport , "999,999,999.99"), oFont07)

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpTotais ºAutor  ³Luciana Silveira    º Data ³  29/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao dos Totais da Planilha.                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpTotais(nLin)
	nLin+=40
	oPrint:say ( nLin, 1090, Replicate("_", 50), oFont09)
	nLin+= 40
	oPrint:say ( nLin, 1110, "TOTAL ", oFont09n )
	oPrint:say ( nLin, 1520, Transform(nGTotGanad,	"999,999,999.99"), oFont07)
	oPrint:say ( nLin, 1820, Transform(nGTotAport,	"999,999,999.99"), oFont07)
	nLin+= 40
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpRodape ºAutor  ³Erika Kanamori      º Data ³  03/19/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao do rodape.                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpRodape(nLin)
	nLin+=50
	oPrint:EndPage()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ GPR624Proc ³ Autor ³ Ricardo Berti	      ³ Data ³04/10/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Geracao do TXT Asegurados Caja Salud							³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER624                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPR624Proc()
	Private oTmpTable := Nil	

	Pergunte("GPR624",.F.)

	cFilialDe 	:= mv_par01
	cFilialAte	:= mv_par02
	cMesAno	:= mv_par03
	cMes 		:= substr( mv_par03, 1, 2 )
	cAno 		:= substr( mv_par03, 3, 4 )
	cMatDe		:= mv_par04
	cMatAte    := mv_par05
	cCustoDe   := mv_par06
	cCustoAte  := mv_par07
	cNomeDe    := mv_par08
	cNomeAte   := mv_par09
	cSit       := mv_par10
	cCat       := mv_par11
	nOrdem		:= 1
	cArqNome	:= mv_par12				// Nome arquivo TXT

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Variaveis utilizadas para parametros                         ³
	³ mv_par01        //  Filial De						           ³
	³ mv_par02        //  Filial Ate					           ³
	³ mv_par03        //  Mes/Ano Competencia ? 		           |
	³ mv_par04        //  Matricula De                             ³
	³ mv_par05        //  Matricula Ate                            ³
	³ mv_par06        //  Centro de Custo De                       ³
	³ mv_par07        //  Centro de Custo Ate                      ³
	³ mv_par08        //  Nome De                                  ³
	³ mv_par09        //  Nome Ate                                 ³
	³ mv_par10        //  Situacoes ?		                       ³
	³ mv_par11        //  Categorias ?      		               ³
	³ mv_par12        //  Path/Nome Arquivo TXT ?                  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	G624CriTMP()			//--- Cria arquivo temporario

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Processa os dados gravando arq. temporario   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	ImpAsCajaS(.T.)

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Gera o arquivo texto                         ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If Select(cAliasTMP) > 0 .And. (cAliasTMP)->(RecCount()) > 0

		G624GerTXT()

	Else
		MsgStop(STR0019+cArqNome)	// "Nao foi gerado o arquivo "
	Endif

	If Select(cAliasTMP) > 0
		If oTmpTable <> Nil   
			oTmpTable:Delete()  
			oTmpTable := Nil 
		EndIf 	
	EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ G624Grava  ³ Autor ³ Ricardo Berti	      ³ Data ³02/04/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Grava um registro no arq. temporario		                 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPR624Proc()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function G624Grava()

	RecLock(cAliasTMP,.T.)
	(cAliasTMP)->TMP_CI		:= (cQrySRA)->RA_CIC
	(cAliasTMP)->TMP_NOME	:= 	Ltrim(Rtrim((cQrySRA)->RA_PRISOBR) + Space(1)) +;
	Ltrim(Rtrim((cQrySRA)->RA_SECSOBR) + Space(1)) +;
	Ltrim(Rtrim((cQrySRA)->RA_PRINOME) + Space(1)) +;
	Alltrim((cQrySRA)->RA_SECNOME)
	(cAliasTMP)->TMP_APORTE	:= nTotAport
	(cAliasTMP)->(MsUnlock())

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³G624CriTMP³ Autor ³ Ricardo Berti	      	³ Data ³02/04/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria arquivo temporario                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³GPR624Proc()								  				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function G624CriTMP()

	Local aArea		:= GetArea()
	Local aCampos   := {}
	Local cTrab
	Local aOrdem := {}

	cAliasTMP := CriaTrab(aCampos,.F.) 

	aAdd( aCampos, { 'TMP_CI'		, "C", TamSX3('RA_CIC')[1]	, 0 } )
	aAdd( aCampos, { 'TMP_NOME'		, "C", 50	, 0 } )
	aAdd( aCampos, { 'TMP_APORTE'	, "N", 12	, 2 } )

	If Select(cAliasTMP) > 0
		dbSelectArea(cAliasTMP)
		dbCloseArea()
	EndIf

	oTmpTable := FWTemporaryTable():New(cAliasTMP)
	oTmpTable:SetFields( aCampos ) 
		
	aOrdem	:=	{"TMP_CI"}

	oTmpTable:AddIndex("IND", aOrdem)
	oTmpTable:Create() 

	RestArea( aArea )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ G624GerTXT   ³ Autor ³ Ricardo Berti	     ³ Data ³ 04/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que gera o arquivo texto                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPR624Proc()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function G624GerTXT()

	Local cLinDet	:= ""
	Local cSep	  	:= "|"
	Local nHandle 	:= MSFCREATE(cArqNome)

	If FERROR() # 0 .Or. nHandle < 0
		Help('',1, "OPENERROR",,STR0020+cArqNome,1)  // "Erro na criação do arquivo "
		FClose(nHandle)
		Return Nil
	EndIf

	dbSelectArea(cAliasTMP)
	dbGoTop()

	While !Eof()

		cLinDet	:=	AllTrim(TMP_CI)	  			+cSep+;    //123456789|TARQUI SOLARES JULIO CESAR|204.12
		AllTrim(TMP_NOME)			+cSep+;
		LTrim(Str(TMP_APORTE,12,2))
		FWrite(nHandle,cLinDet+CRLF)

		dbSkip()
	EndDo
	FClose(nHandle)

	MsgInfo(STR0021) // "O arquivo foi gerado com sucesso."

Return Nil
