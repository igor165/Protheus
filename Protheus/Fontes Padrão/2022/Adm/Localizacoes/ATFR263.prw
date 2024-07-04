#INCLUDE "PROTHEUS.CH"          
#Define DMPAPER_A4 9
#Define DMPAPER_A4SMALL 10
#INCLUDE "ATFR263.CH"

Static __lDefTop := IfDefTopCTB()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ATFR263    ³ Autor ³ Felipe C. Cunha       ³ Data ³ 01.10.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Documento Guia de Abate do Ativo Fixo                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ ATFR263                                                      º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³ 24/06/15 ³PCREQ-4256³Se elimina la funcion CriaSx1(), por  ³±±
±±³            ³          ³          ³motivo de adecuacion a fuentes nuevas ³±±
±±³            ³          ³          ³estructuras SX para Version 12.       ³±±
±±³Jonathan Glz³09/10/15  ³PCREQ-4261³Merge v12.1.8                         ³±±
±±³            ³          ³          ³                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFR263(cAbatAtf)
	//Variaveis

	Local cPerg		:= STR0001  //"ATR263"
	Local aArea		:= {}
	Local lOk		:= .T.
	
	Default cAbatAtf  :=  SuperGetMV("MV_ABATATF",,.F.)       //Numero do Documento
	
	Private oPrint
	Private titulo	 := ""
	Private nomeprog := STR0001 //ATFR263

	//Controle de Posicionamento de colunas
	Private lin  := 50      // Distancia da linha vertical da margem esquerda
	Private lin1 := 330     // Distancia da linha vertical da margem superior
	Private lin2 := 1950    // Tamanho verttical da linha

	//Controle de Fontes
	Private oFont08  := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)  //Fonte08
	Private oFont09  := TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)  //Fonte09
	Private oFont10  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)  //Fonte10
	Private oFont11  := TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)  //Fonte11
	Private oFont12  := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)  //Fonte12
	Private oFont14  := TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)  //Fonte14
	Private oFont10n := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)  //Fonte10 Negrito
	Private oFont12n := TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)  //Fonte12 Negrito

	If Empty(cAbatAtf)
		MsgAlert(STR0003) //Parametro Inexistente - MV_ABATATF"
		lOk := .F.
	EndIf
	
	//Relatorio disponivel somente para ambientes TOPCONN/DBACESS
	If !__lDefTop
		MsgAlert(STR0004) //"Relatorio disponivel somente para ambientes TOPCONN/DBACESS"
		lOk := .T.
	Endif

	//Relatorio não disponivel para esta localização
	If lOk .And. cPaisLoc <> 'PTG'
		MsgAlert(STR0005) //"Relatorio não disponivel para esta localização"
		lOk := .T.
	Endif

	//Parametros de perguntas
	//+-------------------------+
	//| mv_par01 - Documento:   |             																		       |
	//+-------------------------+

	//Se o rel for chamado a partir da rotina de baixa
	// a tela de parametros e preenchida com o numero de abate
	// e não e exibida.
	If Alltrim(Upper(FunName())) == “ATFA036”
		Pergunte(cPerg,.F.)
	Else
		Pergunte(cPerg,.T.)
		cAbatAtf := MV_PAR01
	EndIf
	
	oPrint:= TMSPrinter():New(STR0007) //"Documento de Abate do Ativo Fixo - ATFR263"  // Monta objeto para impressão
	oPrint:SetLandscape()                                                              // Define orientação da página
	oPrint:SetPaperSize(9)  													        // A4 210 x 297 mm
	oPrint:Setup()                                                                     // Exibe tela de setup
	RptStatus({|lEnd| ImpRelATF(@lEnd,cAbatAtf)},STR0008) //"A imprimir..."                    //Impressão do Relatório
	oPrint:EndPage()                                                                   // Termina a página
	oPrint:Preview()                                                                   // Mostra tela de visualização de impressão
	oPrint :=  Nil
return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ImpRelATF º Autor ³ Felipe C. Cunha    º Data ³  01/10/11    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Impressao do relatorio                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpRelATF(lEnd,cAbatAtf)
	Local lImprimir	 := .T.
	Local cArqAtivos := ""
	Private cPictQtd := ""
	Private cPictVlr := ""
	Private cPictDta := ""
        
	ImpCabec() // Impressão Cabeçalho
	MsgRun(STR0009 + ".",,{|| cArqAtivos := GeraDados(cAbatAtf)}) //"Selecionando os dados para a impressão"
	                                        	
    //Define a pictures a partir do dicionario de dados
	cPictQtd := PesqPict("SN4","N4_QUANTD")
	cPictVlr := PesqPict("SN4","N4_VLROC1")
	cPictDta := PesqPict("SN4","N4_DATA")
	
	DbSelectArea(cArqAtivos)
	(cArqAtivos)->(DbGoTop())
	
	//Dados do Abate
	oPrint:Say(213  ,2750,STR0010 + N3_SEQBX ,oFont10)                           //Numero de Abate: XXXXXXXXXXX
	oPrint:Say(263  ,2750,STR0011 + transform(STOD(N4_DATA),cPictDta) ,oFont10) //Data do Abate.....: 04/11/2011

	//Dados do Bem
	oPrint:Say(445,165,N4_CBASE + " - " + N4_ITEM,oFont08)               //Codigo base - Item
	oPrint:Say(445,565,N1_DESCRIC,oFont08)                               //Descrição
	oPrint:Say(445,2450,transform(N4_QUANTD,cPictQtd),oFont08)           //Quantidade
	oPrint:Say(445,2750,transform((N4_VLROC1 - VALOR),cPictVlr),oFont08) //Valor Unitário
	oPrint:Say(445,3100,transform((N4_VLROC1 - VALOR),cPictVlr),oFont08) //Valor Total

	oPrint:Say(1975,3020,transform((N4_VLROC1 - VALOR),cPictVlr),oFont10n)//Valor Total

	DbSelectArea(cArqAtivos)
	DbCloseArea()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ATFR263    ³ Autor ³ Felipe C. Cunha       ³ Data ³ 01.10.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Documento Guia de Abate do Ativo Fixo                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ ATFR263                                                      º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpCabec(cAbatAtf)
	oPrint:StartPage() // Inicia página

	//Monta Desenho do Relatorio
	oPrint:Box(50,50,320,1490)                        // Dados da Empresa (Logo/Nome/CNPJ)
	oPrint:Box(51,51,319,1489)

	oPrint:Box(50,1500,130,3330)                      // Nome do Relatório - Documento de Abate do Ativo Fixo
	oPrint:Box(51,1501,129,3329)

	oPrint:Box(140,1500,320,3330)                     // Data da Baixa - Numero/Data Abate
	oPrint:Box(141,1501,319,3329)

	oPrint:Box(430,50,330,3330)                       // Código do bem/Descrição/Quantidade/Valor/SubTotal
	oPrint:Box(429,51,331,3329)

	oPrint:Line(lin2,lin,lin1,lin)                    //Primeira linha vertical Detalhe
	oPrint:Line(lin2,lin+1,lin1,lin+1)

	oPrint:Line(lin2,lin+500,lin1,lin+500)           //Segunda linha vertical Detalhe
	oPrint:Line(lin2,lin+499,lin1,lin+499)

	oPrint:Line(lin2,lin+2250,lin1,lin+2250)          //Terceira linha vertical Detalhe
	oPrint:Line(lin2,lin+2249,lin1,lin+2249)

	oPrint:Line(lin2+90,lin+2590,lin1,lin+2590)       //Quarta linha vertical Detalhe
	oPrint:Line(lin2+90,lin+2589,lin1,lin+2589)

	oPrint:Line(lin2+90,lin+2930,lin1,lin+2930)       //Quinta linha vertical Detalhe
	oPrint:Line(lin2+90,lin+2929,lin1,lin+2929)

	oPrint:Line(lin2+90,lin+3280,lin1,lin+3280)      //Sexta linha vertical Detalhe
	oPrint:Line(lin2+90,lin+3279,lin1,lin+3279)

	oPrint:Line(1950,51,1950,3330)   	               // Linha Horizontal Fechando Colunas de Detalhe
	oPrint:Line(1949,51,1949,3329)

	oBrush1 := TBrush():New( , RGB(228,224,224) )    // Linha Total
	oPrint:FillRect({1953,2648,2040,3328}, oBrush1 )
	oPrint:FillRect({1954,2649,2039,3327}, oBrush1 )
	oBrush1:End()

	oPrint:Line(2042,2640,2042,3330)   	               // Linha Horizontal Fechando Colunas Total
	oPrint:Line(2041,2641,2041,3329)

	oPrint:Line(2242,2440,2242,3330)   	               // Linha Horizontal Assinatura Responsável
	oPrint:Line(2241,2441,2241,3329)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³GeraDados º Autor ³ Felipe C. Cunha    º Data ³  01/10/11    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ Impressao do relatorio                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraDados(cAbatAtf)
	Local cQuery    := "SN4"
	Local cWhere    := ""
	Local cArq	    := ""
	Local cFileLogo := GetSrvProfString('Startpath','')+'\LGRL'+SM0->M0_CODIGO + '.BMP'

	//Dados da Empresa
	SX3->( DbSetOrder(2) )
	SX3->( MsSeek( "A1_CGC" , .t.))

	If SM0->(Eof())
		SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
	Endif
	oPrint:SayBitmap(60,60,cFileLogo,350,250)                                                 // Logo da Empresa
	oPrint :Say(130,540,SM0->M0_NOMECOM,oFont10n)                                             // Nome da Empresa
	oPrint :Say(230,540,STR0012 + Alltrim( SM0->M0_CGC ),oFont10n) // "Número de Identificação Fiscal: "

	//Titulo Relatorio
	oPrint:Say(63   ,2100,STR0013,oFont12n)  //Documento de Abate do Ativo Fixo

	//Cabecalho
	oPrint:Say(365 ,170 , STR0014 ,oFont10n) //Código do Bem
	oPrint:Say(365 ,1365, STR0015 ,oFont10n) //Descrição
	oPrint:Say(365 ,2365, STR0016 ,oFont10n) //Quantidade
	oPrint:Say(365 ,2760, STR0017 ,oFont10n) //Valor
	oPrint:Say(365 ,3070, STR0018 ,oFont10n) //Sub-Total
	oPrint:Say(1975,2760, STR0019 ,oFont10n) //TOTAL
	oPrint:Say(2244,2760, STR0020 ,oFont10)  //Responsavel

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida o motivo de baixa a ser exibido               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cWhere := " (N4_MOTIVO = '02' OR N4_MOTIVO = '06') "

	#IFDEF TOP
		cArq := GetNextAlias()
		cQuery := " SELECT        "  + CRLF
		cQuery += "   SN4.N4_CBASE,   "  + CRLF
		cQuery += "   SN4.N4_ITEM,    "  + CRLF
		cQuery += "   SN1.N1_DESCRIC, "  + CRLF
		cQuery += "   SN4.N4_QUANTD,  "  + CRLF
		cQuery += "   SN4.N4_VLROC1,  "  + CRLF
		cQuery += "   SN4.N4_DATA,    "  + CRLF
		cQuery += "   SN3.N3_SEQBX,   "  + CRLF
		cQuery += "   SN4.N4_MOTIVO,  "  + CRLF
		cQuery += "	  (SELECT SUM(SN4R.N4_VLROC1)                "    + CRLF
		cQuery += " 		FROM " + RetSqlName("SN4") + " SN4R "     + CRLF
		cQuery += " 		WHERE " + CWHERE + CRLF //VALIDA MOTIVO DE BAIXA
		cQuery += " 		AND (SN4R.N4_TIPOCNT = '4')          " + CRLF
		cQuery += " 		AND SN4R.N4_CBASE = (SN1.N1_CBASE)   " + CRLF
		cQuery += " 		AND SN4.D_E_L_E_T_ = '') AS VALOR    " + CRLF
		cQuery += " FROM " + RetSqlName("SN4") + " SN4 " + CRLF
		cQuery += " 	LEFT JOIN " + RetSqlName("SN1") + " SN1 " + "ON SN1.N1_CBASE  = SN4.N4_CBASE " + CRLF
		cQuery += " 	AND SN1.N1_ITEM   = SN4.N4_ITEM   "        + CRLF
		cQuery += " 	AND SN1.N1_FILIAL = SN4.N4_FILIAL "        + CRLF
		cQuery += " 	LEFT JOIN " + RetSqlName("SN3") + " SN3 "  + CRLF
		cQuery += " 	ON SN1.N1_CBASE   = SN3.N3_CBASE  "        + CRLF
		cQuery += " 	AND SN1.N1_ITEM   = SN3.N3_ITEM   "        + CRLF
		cQuery += " 	AND SN1.N1_FILIAL = SN3.N3_FILIAL "        + CRLF
		cQuery += " WHERE " + CRLF
		cQuery += " 	SN4.N4_TIPOCNT = '1' AND "   + CRLF
		cQuery += " 	SN4.N4_OCORR   = '01'  AND " + CRLF
		cQuery += "     SN3.N3_SEQBX   = " + "'" + cAbatAtf + "' " + "AND " + CRLF
		cQuery +=  	CWHERE  + CRLF //VALIDA MOTIVO DE BAIXA
		cQuery += " 	AND SN4.D_E_L_E_T_ = ''  " + CRLF
		cQuery += " 	AND SN1.D_E_L_E_T_ = ''  " + CRLF
		cQuery += " GROUP BY "        + CRLF
		cQuery += " 	SN4.N4_CBASE,   "  + CRLF
		cQuery += " 	SN1.N1_CBASE,   "  + CRLF
		cQuery += "	    SN4.N4_ITEM,    "  + CRLF
		cQuery += " 	SN1.N1_DESCRIC, "  + CRLF
		cQuery += " 	SN4.N4_QUANTD,  "  + CRLF
		cQuery += " 	SN4.N4_VLROC1,  "  + CRLF
		cQuery += " 	SN4.N4_MOTIVO,  "  + CRLF
		cQuery += " 	SN4.N4_DATA,    "  + CRLF
		cQuery += " 	SN4.D_E_L_E_T_, "  + CRLF
		cQuery += " 	SN3.N3_SEQBX    "  + CRLF
		cQuery += " ORDER BY SN4.N4_CBASE, SN4.N4_ITEM " + CRLF
		cQuery := ChangeQuery(cQuery)
		MemoWrite( 'ATFR263.SQL', cQuery )
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArq,.T.,.T.)
		(cArq)->(DbGoTop())
	#ENDIF
Return(cArq)
