#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER402.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER402  ³ Autor ³ Christiane Vieira       ³    Data    ³   21.12.2010  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o relatório de Mapa de Férias                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Portugal                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³               ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ³ Data     ³     FNC      ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Christiane V  ³21/12/2010³000029236/2010³ Desenvolvimento Inicial                   ³±±
±±³Christiane V  ³13/05/2011³000005011/2011³ Impressão dos feriados no rodape do Rel.  ³±±
±±³              ³          ³              ³                                           ³±±
±±³Jonathan Glez ³06/05/2015³    PCREQ-4256³Se elimina la funcion AjustaSX1, la cual   ³±±
±±³              ³          ³              ³realiza la modificacion aldiccionario de   ³±±
±±³              ³          ³              ³datos(SX1) por motivo de adecuacion a nueva³±±
±±³              ³          ³              ³estructura de SXs para version 12          ³±±
±±³  Marco A.    ³ 16/04/18 ³  DMINA-2310  ³Se remueven sentencias CriaTrab y se apli- ³±± 
±±³			     ³		    ³              ³ca FWTemporaryTable(), para el manejo de   ³±±
±±³			     ³		    ³              ³las tablas temporales.                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER402()
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Locais (Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cDesc1 		:= STR0001		//"Mapa de Férias "
Local cDesc2 		:= STR0021		//"Será impresso de acordo com os parametros informados pelo usuario."
Local cString		:= "SRA"        // alias do arquivo principal (Base)

Private Titulo	    := STR0001		//Mapa de Férias
Private nTamanho    := "G"
Private cFilIni     := ""
Private cCcIni      := ""
Private cMatric     := ""
Private cNome	    := ""
Private cSituacao   := ""
Private cCategoria  := ""
Private nAno		:= ""
Private cCodEs		:= ""
Private aInfo		:= {}

// Define Variaveis Private(Basicas)
Private NomeProg	:= "GPER402"
Private aReturn 	:={ "", 1, "", 2, 2, 1,"",1 }
Private nLastKey 	:= 0
Private cPerg	   	:= "GPR402"
Private aCodFol	:= {}
Private cAliasSP3	:= GetNextAlias()
Private nMaxFer	:= 0

Pergunte("GPR402",.F.)

// Envia controle para a funcao SETPRINT
wnrel:="GPER402"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,,.F.,,.F.,nTamanho,,.F.)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

nOrdem   := aReturn[8]

cSituacao  	:= mv_par05   //  Situacao Funcionario
cCategoria 	:= mv_par06   //  Categoria Funcionario
nAno		:= mv_par07   //  Ano

//Carregar os feriados do exercicio
CarregaFeriados(nAno)

//-- Objeto para impressao grafica
oPrint 	:= TMSPrinter():New( STR0001 ) //"Mapa de Férias
oPrint:SetLandscape()

Titulo := STR0001//Mapa de Férias

RptStatus({|lEnd| GPER402Imp(@lEnd,wnRel,cString )},Capital(Titulo))

oPrint:Preview()  							// Visualiza impressao grafica antes de imprimir

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPER402Imp     ³ Autor ³ Christiane Vieira³ Data ³21/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Mapa de Segurança Social - Portugal           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER402                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GPER402Imp(lEnd,wnRel,cString)

	Local cAcessaSRA	:= &( " { || " + ChkRH( "GPER402" , "SRA", "2" ) + " } " )
	Local cRegAnt		:= ""
	Local cFilAnt 	:= ""
	Local cPerAnt 	:= ""
	Local aStru	  	:= {}
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Variaveis para controle em ambientes TOP.                    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	Local cQuery    := ""
	Local cSitQuery := ""
	Local cCatQuery := ""
	
	//Vaviaveis private para impressao
	Local cDescEst := ""
	Local nLinha   := 0, nReg    := 0, nPagina := 0
	
	Private nUltMes   := 0
	Private cFunAnt   := ""
	Private lMudaFunc := .T.
	Private lMudaPer  := .T.
	
	cSitQuery += ""
	For nReg := 1 to Len(cSituacao)
		cSitQuery += "'" +Subs(cSituacao,nReg,1)+"'"
		If (nReg+1) <= Len(cSituacao)
			cSitQuery += ","
		Endif
	next nReg
	
	cCatQuery := ""
	For nReg  := 1 to Len(cCategoria)
		cCatQuery += "'" +Subs(cCategoria,nReg,1)+"'"
		If (nReg+1) <= Len(cCategoria)
			cCatQuery += ","
		Endif
	next nReg
	
	cFilIni := ""
	For nReg := 1 to Len(alltrim(mv_par01)) Step 3
		cFilIni += "'" + Subs(mv_par01, nReg,2) + "'"
		If (nReg+3) <= Len(alltrim(mv_par01))
			cFilIni += ","
		Endif
	Next nReg
	
	cCcIni := ""
	For nReg := 1 to Len(Alltrim(mv_par02)) Step 9
		cCcIni += "'" + Subs(mv_par02, nReg,9) + "'"
		If (nReg+9) <= Len(alltrim(mv_par02))
			cCcIni += ","
		Endif
	Next nReg
	
	cMatric := ""
	For nReg := 1 to Len(Alltrim(mv_par03)) Step 6
		cMatric += "'" + Subs(mv_par03, nReg,6) + "'"
		If (nReg+6) <= Len(alltrim(mv_par03))
			cMatric += ","
		Endif
	Next nReg
	
	cNome := ""
	For nReg := 1 to Len(Alltrim(mv_par04)) Step 30
		cNome += "'" + Subs(mv_par04, nReg,30) + "'"
		If (nReg+30) <= Len(alltrim(mv_par04))
			cNome += ","
		Endif
	Next nReg
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Objetos para Impressao Grafica - Declaracao das Fontes Utilizadas.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private oFont07, oFont09, oFont07n, oFont12n
	
	oFont07	:= TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)
	oFont09	:= TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.)
	oFont07n	:= TFont():New("Courier New",07,07,,.T.,,,,.T.,.F.)     //Negrito//
	oFont12n	:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)     //Negrito//
	
	nEpoca:= SET(5,1910)
	//-- MUDAR ANO PARA 4 DIGITOS
	SET CENTURY ON

   	aStru := SRH->(dbStruct())

	cQuery:= "SELECT RA_FILIAL FILIAL, RA_MAT, RA_NOME, RA_DEPTO, QB_CESTAB,  "
	cQuery+= "RF_DIASDIR QTDDIAS, RF_DATABAS DATABAS,RH_DATAINI, RH_DATAFIM "
	cQuery+= "FROM "+RETSQLNAME("SRA")+" SRA "

	cQuery+= "INNER JOIN "+RETSQLNAME("SRF")+" SRF ON "
	cQuery+= "RF_FILIAL = RA_FILIAL "
	cQuery+= "AND RF_MAT=RA_MAT "
	cQuery+= "AND SRF.D_E_L_E_T_='' "

	cQuery+= "INNER JOIN "+RETSQLNAME("SRH")+" SRH ON "
	cQuery+= "RH_FILIAL = RF_FILIAL "
	cQuery+= "AND RH_MAT = RF_MAT "
	cQuery+= "AND RH_DATABAS = RF_DATABAS "
	cQuery+= "AND SRH.D_E_L_E_T_='' "

	cQuery+= "INNER JOIN "+RETSQLNAME("SQB")+" SQB ON "
	cQuery+= "QB_DEPTO=RA_DEPTO "
	cQuery+= "AND SQB.D_E_L_E_T_='' "

	cQuery+= "WHERE SRA.D_E_L_E_T_= '' AND SRH.RH_TIPO = '2' "
	cQuery+= "AND RA_CATFUNC IN (" + cCatQuery + ") "
	cQuery+= "AND RA_SITFOLH IN (" + cSitQuery + ") "

	If !Empty(cFilIni)
		cQuery+= "AND RA_FILIAL IN (" + cFilIni + ") "
	Endif
	If !Empty(cCcIni)
		cQuery+= "AND RA_CC IN (" + cCcIni + ") "
	Endif
	If !Empty(cMatric)
		cQuery+= "AND RA_MAT IN (" + cMatric + ") "
	Endif
	If !Empty(cNome)
		cQuery+= "AND UPPER(RA_NOME) IN (" + UPPER(cNome) + ") "
	Endif

	cQuery+= "ORDER BY QB_CESTAB,FILIAL,RA_MAT,RH_DATAINI,RH_DATAFIM"
	cQuery := ChangeQuery(cQuery)

	If Select("TRB")>0
		DbSelectArea("TRB")
		TRB->(DbCloseArea())
	Endif
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)

	For nReg := 1 To Len(aStru)
		If ( aStru[nReg][2] <> "C" )
			TcSetField("TRB",aStru[nReg][1],aStru[nReg][2],aStru[nReg][3],aStru[nReg][4])
		EndIf
	Next nReg
	cTpGer:="SQL"

	DbSelectArea("TRB")
	TRB->(DbGoTop())

	//Carrega Regua de Processamento
	SetPrc(0,0)
	SetRegua(TRB->(RecCount()))

	Do While TRB->(!EOF())
	 	IncRegua()

		If lEnd
			@Prow()+1,0 PSAY cCancel
			Exit
	    Endif

		If Year(TRB->RH_DATAINI) == nAno .Or. Year(TRB->RH_DATAFIM) == nAno
			If cFilAnt <> TRB->FILIAL       //se filial eh diferente da anterior
				If !FP_CODFOL(@aCodFol)
					Exit
				Endif
				If	!fInfo(@aInfo,SRA->RA_FILIAL)
					dbSelectArea( "TRB" )
					dbSkip()
					Loop
				Endif

				DbSelectArea("RCO")
				RCO->(DbGoTop())
				RCO->(DbSetOrder(RetOrder("RCO","RCO_FILIAL+RCO_CODIGO")))
				If DbSeek(xFilial("RCO")+TRB->QB_CESTAB)
					cDescEst := ALLTRIM(RCO->RCO_NOME)
					cCodEs := TRB->QB_CESTAB
				Endif
				DbSelectArea("TRB")

				nPagina += 1
				GeraCabMapa(cDescEst, nPagina)
				If nLinha <> 0
					GeraRodMapa(nLinha, .T.)
					oPrint:Endpage()
				Endif

				nLinha := 1
				cFilAnt := TRB->FILIAL
				cRegAnt := TRB->QB_CESTAB
				cFunAnt := TRB->RA_MAT
				cPerAnt	:= TRB->DATABAS
			ElseIf cRegAnt <> TRB->QB_CESTAB
				If nLinha <> 0
					GeraRodMapa(nLinha, .T.)
					oPrint:Endpage()
				Endif

				DbSelectArea("RCO")
				RCO->(DbGoTop())
				RCO->(DbSetOrder(RetOrder("RCO","RCO_FILIAL+RCO_CODIGO")))
				If DbSeek(xFilial("RCO")+TRB->QB_CESTAB)
					cDescEst := ALLTRIM(RCO->RCO_NOME)
					cCodEs := TRB->QB_CESTAB
				Endif
				DbSelectArea("TRB")

				nPagina += 1
				GeraCabMapa(cDescEst, nPagina)
				nLinha  := 1
				cFilAnt := TRB->FILIAL
				cRegAnt := TRB->QB_CESTAB
				cFunAnt := TRB->RA_MAT
				cPerAnt	:= TRB->DATABAS
				lMudaFunc := .T.
			Endif

			If (cFunAnt <> TRB->RA_MAT) .OR. (cFunAnt == TRB->RA_MAT .AND. nUltMes == Month(TRB->RH_DATAINI) )
				lMudaFunc := IIF(cFunAnt <> TRB->RA_MAT, .T., .F. )
			    lMudaPer  := IIF(cPerAnt <> TRB->DATABAS .And. !lMudaFunc, .T., .F. )
			    nLinha += 1
			    cFunAnt := TRB->RA_MAT
			ElseIf nLinha > 1
				lMudaFunc := .F.
				lMudaPer  := IIF(cPerAnt <> TRB->DATABAS, .T., .F. )
			Endif

			If cPerAnt <> TRB->DATABAS
				cPerAnt	:= TRB->DATABAS
			Endif

		    If nLinha > 20 - nMaxFer
			    GeraRodMapa(nLinha, .F.)
				oPrint:EndPage()
				nLinha := 1
			 	nPagina += 1
				GeraCabMapa(cDescEst, nPagina)
		    Endif
		    GeraDetMapa(nLinha, Month(TRB->RH_DATAINI))
		Endif
		TRB->(DbSkip())
	End
    If !nUltMes == 0
		GeraRodMapa(nLinha, .T.)
		oPrint:EndPage()
	Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraCabMapaºAutor  ³Christiane Vieira  º Data ³  21/12/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraCabMapa(cDescEst, nPag)
  	Local dData := DATE()
	Local cHora := TIME()
	Local cEnd	:= Substr(aInfo[4],1,40) + Space(8) + Substr(aInfo[14],1,20) + Space(7) + aInfo[13]
	Local cCompl:= AllTrim(aInfo[7]) + Space(10) + aInfo[5]

	oPrint:StartPage() 						//Inicia uma nova pagina

    oPrint:Box ( 0050, 0025, 480, 3260 ) 	//BOX EMPRESA

    oPrint:say ( 0080, 0045, aInfo[3], oFont09 ) // Razão Social
	oPrint:say ( 0080, 1300, STR0001, oFont12n )
	oPrint:say ( 0080, 1800, cValToChar(nAno), oFont12n )
    oPrint:say ( 0080, 2300, STR0002, oFont09 )
    oPrint:say ( 0080, 2800, cValToChar(nPag), oFont09 )	//Página nº

    oPrint:say ( 0130, 0045, cEnd, oFont09 )
    oPrint:say ( 0130, 2300, STR0003, oFont09 )
    oPrint:say ( 0130, 2510, DTOC(dData), oFont09 )

    oPrint:say ( 0180, 0045, cCompl, oFont09 )
    oPrint:say ( 0180, 2300, STR0004, oFont09 )
    oPrint:say ( 0180, 2510, cHora, oFont09 )

    oPrint:say ( 0230, 0045, aInfo[8], oFont09 )
    oPrint:say ( 0230, 2300, STR0005, oFont09 )
    oPrint:say ( 0230, 2510, "7.002", oFont09 )

	oPrint:line ( 0350, 0025, 0350, 3260 )  //LINHA HORIZONTAL
    oPrint:say ( 0380, 0145, cCodEs, oFont09 )
    oPrint:say ( 0380, 1145, cDescEst, oFont09 )

	oPrint:line ( 0430, 0025, 0430, 3260 )  //LINHA HORIZONTAL

	oPrint:say ( 440, 0085, STR0006, oFont07n )
	oPrint:line ( 0430, 0165, 0480, 0165 )  //LINHA VERTICAL
	oPrint:say ( 440, 0420, STR0007, oFont07n )
	oPrint:line ( 0430, 0815, 0480, 0815 )  //LINHA VERTICAL
	oPrint:say ( 440, 0830, STR0008, oFont07n )
	oPrint:line ( 0430, 0980, 0480, 0980 )  //LINHA VERTICAL
	oPrint:say ( 440, 1000, STR0009, oFont07n )
	oPrint:line ( 0430, 1170, 0480, 1170 )  //LINHA VERTICAL
	oPrint:say ( 440, 1190, STR0010, oFont07n )
	oPrint:line ( 0430, 1360, 0480, 1360 )  //LINHA VERTICAL
	oPrint:say ( 440, 1380, STR0011, oFont07n )
	oPrint:line ( 0430, 1550, 0480, 1550 )  //LINHA VERTICAL
	oPrint:say ( 440, 1570, STR0012, oFont07n )
	oPrint:line ( 0430, 1740, 0480, 1740 )  //LINHA VERTICAL
	oPrint:say ( 440, 1760, STR0013, oFont07n )
	oPrint:line ( 0430, 1930, 0480, 1930 )  //LINHA VERTICAL
	oPrint:say ( 440, 1950, STR0014, oFont07n )
	oPrint:line ( 0430, 2120, 0480, 2120 )  //LINHA VERTICAL
	oPrint:say ( 440, 2140, STR0015, oFont07n )
	oPrint:line ( 0430, 2310, 0480, 2310 )  //LINHA VERTICAL
	oPrint:say ( 440, 2330, STR0016, oFont07n )
	oPrint:line ( 0430, 2500, 0480, 2500 )  //LINHA VERTICAL
	oPrint:say ( 440, 2520, STR0017, oFont07n )
	oPrint:line ( 0430, 2690, 0480, 2690 )  //LINHA VERTICAL
	oPrint:say ( 440, 2710, STR0018, oFont07n )
	oPrint:line ( 0430, 2880, 0480, 2880 )  //LINHA VERTICAL
	oPrint:say ( 440, 2900, STR0019, oFont07n )
	oPrint:line ( 0430, 3070, 0480, 3070 )  //LINHA VERTICAL
	oPrint:say ( 440, 3090, STR0020, oFont07n )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraDetMapaºAutor  ³Christiane Vieira  º Data ³  21/12/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraDetMapa(nLinha, nColuna)
	Local nTamLin := 50
	Local nLinIni := 480
	Local nPosIni := 490
	Local nPosCol := 1040
	Local cDias1  := ""
	Local cDias2  := ""
	Local cPer	  := " (" + substr(TRB->DATABAS,1,4) + ")"
	
	oPrint:line ( nLinIni + (nTamLin * (nLinha - 1)), 0025, nLinIni + nTamLin + (nTamLin * (nLinha - 1)), 0025 )  //LINHA VERTICAL
	oPrint:line ( nLinIni + (nTamLin * (nLinha - 1)), 0165, nLinIni + nTamLin + (nTamLin * (nLinha - 1)), 0165 )  //LINHA VERTICAL
	oPrint:line ( nLinIni + (nTamLin * (nLinha - 1)), 0815, nLinIni + nTamLin + (nTamLin * (nLinha - 1)), 0815 )  //LINHA VERTICAL
	oPrint:line ( nLinIni + (nTamLin * (nLinha - 1)), 0980, nLinIni + nTamLin + (nTamLin * (nLinha - 1)), 0980 )  //LINHA VERTICAL
	oPrint:line ( nLinIni + (nTamLin * (nLinha - 1)), 1170, nLinIni + nTamLin + (nTamLin * (nLinha - 1)), 1170 )  //LINHA VERTICAL
	oPrint:line ( nLinIni + (nTamLin * (nLinha - 1)), 1360, nLinIni + nTamLin + (nTamLin * (nLinha - 1)), 1360 )  //LINHA VERTICAL
	oPrint:line ( nLinIni + (nTamLin * (nLinha - 1)), 1550, nLinIni + nTamLin + (nTamLin * (nLinha - 1)), 1550 )  //LINHA VERTICAL
 	oPrint:line ( nLinIni + (nTamLin * (nLinha - 1)), 1740, nLinIni + nTamLin + (nTamLin * (nLinha - 1)), 1740 )  //LINHA VERTICAL
	oPrint:line ( nLinIni + (nTamLin * (nLinha - 1)), 1930, nLinIni + nTamLin + (nTamLin * (nLinha - 1)), 1930 )  //LINHA VERTICAL
 	oPrint:line ( nLinIni + (nTamLin * (nLinha - 1)), 2120, nLinIni + nTamLin + (nTamLin * (nLinha - 1)), 2120 )  //LINHA VERTICAL
	oPrint:line ( nLinIni + (nTamLin * (nLinha - 1)), 2310, nLinIni + nTamLin + (nTamLin * (nLinha - 1)), 2310 )  //LINHA VERTICAL
 	oPrint:line ( nLinIni + (nTamLin * (nLinha - 1)), 2500, nLinIni + nTamLin + (nTamLin * (nLinha - 1)), 2500 )  //LINHA VERTICAL
 	oPrint:line ( nLinIni + (nTamLin * (nLinha - 1)), 2690, nLinIni + nTamLin + (nTamLin * (nLinha - 1)), 2690 )  //LINHA VERTICAL
 	oPrint:line ( nLinIni + (nTamLin * (nLinha - 1)), 2880, nLinIni + nTamLin + (nTamLin * (nLinha - 1)), 2880 )  //LINHA VERTICAL
 	oPrint:line ( nLinIni + (nTamLin * (nLinha - 1)), 3070, nLinIni + nTamLin + (nTamLin * (nLinha - 1)), 3070 )  //LINHA VERTICAL
	oPrint:line ( nLinIni + (nTamLin * (nLinha - 1)), 3260, nLinIni + nTamLin + (nTamLin * (nLinha - 1)), 3260 )  //LINHA VERTICAL

	If lMudaFunc
		oPrint:line ( nLinIni + (nTamLin * (nLinha - 1)), 0025, nLinIni + (nTamLin * (nLinha - 1)), 3260 )  //LINHA HORIZONTAL
		oPrint:say ( nPosIni + (nTamLin * (nLinha - 1)), 0045, TRB->RA_MAT, oFont07 ) //Identificação
		oPrint:say ( nPosIni + (nTamLin * (nLinha - 1)), 0180, TRB->RA_NOME, oFont07 ) //Nome do Trabalhador
		oPrint:say ( nPosIni + (nTamLin * (nLinha - 1)), 0830, cValToChar(TRB->QTDDIAS) + cPer, oFont07 ) //Quantidade de Dias
	ElseIf lMudaPer
		oPrint:line ( nLinIni + (nTamLin * (nLinha - 1)), 0025, nLinIni + (nTamLin * (nLinha - 1)), 3260 )  //LINHA HORIZONTAL
		oPrint:say ( nPosIni + (nTamLin * (nLinha - 1)), 0830, cValToChar(TRB->QTDDIAS) + cPer, oFont07 ) //Quantidade de Dias
	Endif

	nUltMes := nColuna
	If Year(TRB->RH_DATAINI) == nAno .And. Month(TRB->RH_DATAINI) == Month(TRB->RH_DATAFIM)
		If Day(TRB->RH_DATAINI) == Day(TRB->RH_DATAFIM)
			cDias1 := AllTrim(STR(Day(TRB->RH_DATAINI)))
		Else
			cDias1 := AllTrim(STR(Day(TRB->RH_DATAINI))) + "-" + AllTrim(STR(Day(TRB->RH_DATAFIM)))
		Endif
	ElseIf Year(TRB->RH_DATAINI) == nAno - 1 .And. Year(TRB->RH_DATAFIM) == nAno
		//Férias com início em dez do ano anterior e término em janeiro do ano da solicitação do relatório
		cDias1 := "1-" + AllTrim(STR(Day(TRB->RH_DATAFIM)))
		nUltMes := 1
		nColuna := 1
	Else
		cDias1 := AllTrim(STR(Day(TRB->RH_DATAINI))) + "-" + AllTrim(STR(F_ULTDIA(TRB->RH_DATAINI)))
		If Year(TRB->RH_DATAFIM) == nAno
			If Day(TRB->RH_DATAFIM) == 1
				cDias2 := "1"
			Else
				cDias2 := "1-" + AllTrim(STR(Day(TRB->RH_DATAFIM)))
			Endif
			nUltMes := nColuna + 1
		Endif
	Endif

	oPrint:say ( nPosIni + (nTamLin * (nLinha - 1)), nPosCol + ((nColuna - 1) * 190), cDias1, oFont07 ) //Dias
    If !Empty(cDias2)
		oPrint:say ( nPosIni + (nTamLin * (nLinha - 1)), nPosCol + (nColuna * 190), cDias2, oFont07 ) //Dias
    Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraRodMapaºAutor  ³Christiane Vieira  º Data ³  21/12/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraRodMapa(nLinha, bImpTotais)
	Local nTamLin := 50
	Local nLinIni := 480
	Local nPosIni := 490
  	Local dData   := DATE()
	Local cLoc	  := Padr(AllTrim(aInfo[5]) + ", " + Str(Day(dData),2)+ STR0024 + RTrim(FDESC_MES(Month(dData))) + STR0024 + Str(Year(dData),4),45)
	Local nColAnt := 0
	Local nLinAux := nLinha

	oPrint:line ( nLinIni + nTamLin + (nTamLin * (nLinha - 1)), 0025, nLinIni + nTamLin + (nTamLin * (nLinha - 1)), 3260 )  //LINHA HORIZONTAL

	//IMPRESSÃO DAS INFORMAÇÕES DE FERIADOS
	DbSelectArea(cAliasSP3)
	(cAliasSP3)->(DbGoTop())

	Do While (cAliasSP3)->(!EOF())
		If ((cAliasSP3)->P3_FILIAL == SRA->RA_FILIAL) .And. ( AllTrim((cAliasSP3)->P3_TIPCOD) == "" .Or. AllTrim((cAliasSP3)->P3_TIPCOD) == cCodEs )
			If !Val((cAliasSP3)->COLUNA) == nColAnt
				nColAnt := Val((cAliasSP3)->COLUNA)
				nLinha  := nLinAux
			Endif

 			oPrint:say ( nPosIni + (nTamLin * nLinha), 0045 + (785 * (nColAnt -1)), DTOC((cAliasSP3)->P3_DATA), oFont07 )
		 	oPrint:say ( nPosIni + (nTamLin * nLinha), 0200 + (785 * (nColAnt -1)), (cAliasSP3)->P3_DESC, oFont07 )

			nLinha ++
		Endif
		(cAliasSP3)->(DbSkip())
	End

	oPrint:say ( 2200, 150, cLoc, oFont09 ) //Local e Data
	oPrint:say ( 2300, 150, STR0025, oFont09 ) //Aprovado
	oPrint:say ( 2300, 400, Replicate('_',60), oFont09 )
	oPrint:say ( 2350, 650, STR0026, oFont09 ) //Aprovado
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CarregaFerºAutor  ³Christiane Vieira   º Data ³ 13/05/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CarregaFeriados(nAno)
	Local aStruSP3	:= {}
	Local cQryAux	:= ""
	Local cAno		:= cValToChar(nAno)
	Local nReg		:= 0
	Local cWhere	:= ""
	Local nFer1		:= 0
	Local nFer2		:= 0
	Local nFer3		:= 0
	Local nFer4 	:= 0

   	aStruSP3 := SP3->(dbStruct())

   	cWhere:= " SUBSTRING(P3_DATA,1,4) = '" + cAno + "' "
	cWhere+= " AND (P3_TIPO = '' OR P3_TIPO = '3') "
	cWhere+= " AND D_E_L_E_T_= '' "

	If !Empty(cFilIni)
		cWhere+= "AND P3_FILIAL IN (" + cFilIni + ") "
	Endif

	cQryAux:= "SELECT P3_FILIAL, P3_DATA, P3_DESC, P3_TIPO, P3_TIPCOD, "
	cQryAux+= " CASE WHEN SUBSTRING(P3_DATA,5,2) IN('01','02','03') THEN '1'"
	cQryAux+= "	WHEN SUBSTRING(P3_DATA,5,2) IN('04','05','06') THEN '2'     "
	cQryAux+= "	WHEN SUBSTRING(P3_DATA,5,2) IN('07','08','09') THEN '3'     "
	cQryAux+= "	ELSE '4' 	END COLUNA,	"
	cQryAux+= " ( SELECT MAX(dias) FROM ( "
	cQryAux+= " select count(*) dias from " + RETSQLNAME("SP3") + " Where SUBSTRING(P3_DATA,5,2) IN('01','02','03') AND " + cWhere
	cQryAux+= " union select count(*) dias from " + RETSQLNAME("SP3") + " Where SUBSTRING(P3_DATA,5,2) IN('04','05','06') AND " + cWhere
	cQryAux+= " union select count(*) dias from " + RETSQLNAME("SP3") + " Where SUBSTRING(P3_DATA,5,2) IN('07','08','09') AND "	+ cWhere
	cQryAux+= " union select count(*) dias from " + RETSQLNAME("SP3") + " Where SUBSTRING(P3_DATA,5,2) IN('10','11','12') AND " + cWhere + " ) Fer ) as DIAS"
	cQryAux+= " FROM " + RETSQLNAME("SP3")

	cQryAux+= " WHERE SUBSTRING(P3_DATA,1,4) = '" + cAno + "' "
	cQryAux+= " AND (P3_TIPO = '' OR P3_TIPO = '3') "
	cQryAux+= " AND D_E_L_E_T_= '' "

	If !Empty(cFilIni)
		cQryAux+= "AND P3_FILIAL IN (" + cFilIni + ") "
	Endif

	cQryAux+= "ORDER BY P3_FILIAL,P3_TIPCOD,P3_DATA"
	cQryAux := ChangeQuery(cQryAux)

	If ( Select( cAliasSP3 ) > 0 )
		( cAliasSP3 )->( dbCloseArea() )
	EndIf
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryAux),cAliasSP3,.T.,.T.)

	For nReg := 1 To Len(aStruSP3)
		If ( aStruSP3[nReg][2] <> "C" )
			TcSetField(cAliasSP3,aStruSP3[nReg][1],aStruSP3[nReg][2],aStruSP3[nReg][3],aStruSP3[nReg][4])
		EndIf
	Next nReg

	DbSelectArea (cAliasSP3)
	(cAliasSP3)->(DbGoTop())
	If (cAliasSP3)->(!EOF())
		nMaxFer := (cAliasSP3)->DIAS
	Endif

Return