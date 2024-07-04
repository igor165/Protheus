#INCLUDE "PROTHEUS.CH"              
#INCLUDE "GPER870.CH"   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER870  ³ Autor ³ Abel Ribeiro                     ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Este programa tem a finalidade de imprimir os dados para o            ³±±
±±³			 ³ formulario de Certificacao e Ingressos e retencao (DIAN)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ BOPS / FNC     ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Ademar Jr.   ³08/08/11³00000020223/2011³-COL-Implementado mensagem pra quando nao ³±±
±±³             ³        ³Chamado TDMMLG  ³     existir o arquivo DIAN.BMP no System.³±±
±±³Ademar Jr.   ³13/03/13³Chamado: TERGCP ³-COL-Ajustes no LayOut de impressao.      ³±±
±±³Alfredo Med. ³22/11/13³Prj.:COL11.8_RH ³-COL-Agregó Sucursal Matriz, se actualizo ³±±
±±³             ³        ³Req.:239714     ³ el Tipo Doc, Período de Certificación    ³±±
±±³             ³        ³                ³ y Código de Depto. y alineación de datos ³±±
±±³Alfredo Med. ³20/01/14³Prj.:COL11.8_RH ³-COL-Se Adiciona el CC o NIT del          ³±±
±±³             ³        ³Req.:239714     ³ Dependiente (RB_CIC) y el Número de      ³±±
±±³             ³        ³                ³ Formulario (Consecutivo)                 ³±±
±±³Alfredo Med. ³21/01/14³Prj.:COL11.8_RH ³-COL- Toma como referencia de NIT el      ³±±
±±³             ³        ³Req.:239714     ³ campo RA_RG, en vez de RA_CIC. Inicializa³±± 
±±³             ³        ³                ³ variables de los Conceptos y Datos de    ³±±
±±³             ³        ³                ³ Cargo del asalariado.                    ³±±
±±³Alfredo Med. ³27/01/14³Prj.:COL11.8_RH ³-COL- Se agregó el filtro RGO_NIF=RA_RG   ³±±
±±³             ³        ³Req.:239714     ³ al query principal                       ³±±
±±³Alfredo Med. ³18/02/16³PDR_SER_MI002-54³-COL-Ajuste en layout fun GprImprDIAN     ³±±
±±³             ³        ³Req.:PCREQ-9393 ³                                          ³±±
±±³Alfredo Med. ³01/06/16³PCDEF2015_2016-5027³-COL-Ajuste en layout fun GprImprDIAN  ³±±
±±³             ³        ³Req.:PCREQ-9393 ³   V12                                    ³±±
±±³Alf. Medrano ³07/09/16³PDR_SER_MI002-56³Merge 12.1.13                             ³±±
±±³Marco A. Glz ³11/05/17³    MMI-215     ³ Replica de llamado TUZGYR - V118. Que    ³±±
±±³             ³        ³                ³ consiste en presentar tanto el Formato   ³±±
±±³             ³        ³                ³ como la informacion de Ingresos y Reten- ³±±
±±³             ³        ³                ³ ciones. (COL)                            ³±±
±±³Oscar G.     ³21/10/20³DMINA-10247     ³ Actualiza archivo DIAN.BMP y se ajusta el³±±
±±³             ³        ³                ³ layout de impresion.                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPER870() 

	Private oPrint			:= Nil	//Objeto de impressao
	Private aInfo	    	:= {} 
	Private cArquivo    	:= "DIAN.bmp"	//Nome do arquivo Bitmap que sera impresso na primeira pagina
	Private nLastKey  		:= 0  
	Private cPerg			:= "GPR870" 
	Private cTit    		:= OemToAnsi(STR0006)			//"Certificado de Ingresos e Retencao"
	Private cDesc1 		    := STR0007		//Ingressos e Retencao
	Private cDesc2 		    := STR0008		//"Ser  impresso de acordo com os parametros solicitados pelo"
	Private cDesc3 		    := STR0009		//"usu rio."
	Private nTamanho		:= "M"  
	Private aReturn			:= {"",1,"", 2, 1, 1, "",1 }
	Private lQuery		    := .F. 
	Private cFilDe	   	    := ""     //Filial DE
	Private cFilAte		    := ""     //Filial Ate
	Private cCcDe			:= ""     //Centro de Custo de 
	Private cCcAte			:= ""     //Centro de Custo ate
	Private cMatDe			:= ""     //Matricula de 
	Private cMatAte			:= ""     //Matricula ate
	Private cSit			:= ""     //Situacao
	Private cCat			:= ""     //Categoria
	Private cFilMtrz		:= ""     //Filial Matriz
	Private cAcessaSRA		:= &( " { || " + ChkRH( "GPER870" , "SRA" , "2" ) + " } " ) 
	Private cAno  		    := "" 	//Variavel utilizada para facilitar a verificacao do ano
	Private cString		    := "SRA"	 
	Private wnrel			:= "GPER870"	//Nome Default do relatorio em Disco   

	Private cSitQuery 	    := ""   
	Private cCatQuery		:= ""  
	Private nSalar   		:= 0
	Private nPagBonVar		:= 0
	Private nValCesan		:= 0
	Private nValFonCes		:= 0
	Private nValEPS	 	    := 0
	Private nValAFC		    := 0
	Private nValAFP		    := 0
	Private nCotVolReg		:= 0
	Private nValIR   		:= 0
	Private nGasRepr		:= 0

	Private nIngHonor		:= 0
	Private nIngServ		:= 0
	Private nIngComis		:= 0
	Private nIngPSoci		:= 0
	Private nIngViat		:= 0
	Private nIngComp		:= 0
	Private nApoVolPen		:= 0

	Private nPensaJub		:= 0
	Private nOutrIngr		:= 0
	Private nTotIngrBru  	:= 0
	Private nArrendRec     	:= 0
	Private nHonorRec  	    := 0
	Private nRendFinRc  	:= 0
	Private nAtFixoRec  	:= 0
	Private nLotRec    	    := 0
	Private nOutrosRec     	:= 0 

	Private nTotVlReceb  	:= 0
	Private nTotVlRetido  	:= 0
	Private nTotRetenAno	:= 0

	Private nArrendRet     	:= 0
	Private nHonorRet  	    := 0
	Private nRendFinRt  	:= 0
	Private nAtFixoRet  	:= 0
	Private nLotRet    	    := 0
	Private nOutrosRet    	:= 0
	Private nTotDeudas		:= 0
	Private aDep			:= {}  
	Private aBensPatr		:= {}
	Private m_graupar 	    := ""

	Private	oFont08			:= Nil
	Private	oFont09n		:= Nil
	Private oFont10			:= Nil
	Private oFont10n		:= Nil
	Private oFont11			:= Nil
	Private oFont12			:= Nil

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o arquivo .BMP existe no System                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File(cArquivo)
		MsgAlert(OemToAnsi(STR0013)+cArquivo)	//-"Arquivo não encontrado -> "
		Return
	EndIf

	If nLastKey == 27       
		Return
	Endif

	oPrint := TMSPrinter():New(STR0003) //Relatorio

	If ! oPrint:IsPrinterActive()
		oPrint:Setup()	//-- Seleciona a impressora	
		If ! oPrint:IsPrinterActive()	
			MsgAlert( OemToAnsi(STR0002), OemToAnsi(STR0001)) //Verifique a configuracao da impressora! ## Atencao 
			Return(Nil)
		Endif
	Endif

	oPrint:SetPortrait()	//Impressao em Modo Retrato

	oFont08		:= TFont():New("Times New Roman",,8,,.F.,,,,.T.,.F.)
	oFont09n	:= TFont():New("Times New Roman",,9,,.T.,,,,.T.,.F.)
	oFont10		:= TFont():New("Times New Roman",,10,,.F.,,,,.T.,.F.)
	oFont10n	:= TFont():New("Times New Roman",,10,,.T.,,,,.T.,.F.)
	oFont11		:= TFont():New("Times New Roman",,11,,.F.,,,,.T.,.F.)
	oFont12		:= TFont():New("Times New Roman",,12,,.T.,,,,.T.,.F.)

	If nLastKey == 27       
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)    

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:=SetPrint(cString,wnrel,cPerg,@cTit,cDesc1,cDesc2,cDesc3,.F.,,,nTamanho) 

	If nLastKey = 27
		Return
	Endif

	SetDefault(aReturn,cString)   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carregando variaveis mv_par?? para Variaveis do Sistema.	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilDe		:= MV_PAR01             //Filial de 
	cFilAte		:= MV_PAR02             //Filial Ate
	cCcDe		:= MV_PAR03             //C.Custo de
	cCcAte		:= MV_PAR04             //C.Custo Ate
	cMatDe		:= MV_PAR05             //Matricula Inicial
	cMatAte		:= MV_PAR06             //Matricula Final
	cNomDe		:= MV_PAR07             //Nome Inicial Inicial
	cNomAte		:= MV_PAR08             //Nome Final
	cSit 		:= MV_PAR09             //Situação
	cCat		:= MV_PAR10             //Categoria
	cAno        := MV_PAR11             //Ano Base
	cFilMtrz	:= MV_PAR12             //Sucursal Matriz
	dDtIni		:= CTOD("01/01/"+cAno)   //Periodo Inicial da Certificacao
	dDtFim		:= CTOD("31/12/"+cANO)   //Periodo Final da Certificacao

	RptStatus( {|lEnd|Imprime()},STR0006) 
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Imprime       ³ Autor ³ Abel Ribeiro            ³ Data ³03/02/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Este programa tem a finalidade de imprimir os dados para o        ³±±
±±³			 ³ formulario de Certificado de ingressos e Retencao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Imprime()                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Localizado Colombia                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Imprime()

	Local nS		:= 0   
	Local nCont		:= 0    
	Local nAUX01	:= 0
	Local nAUX01d	:= 0
	Local cTipo		:= ""
	
	Private nConsec	:= 1

	DbSelectArea("RGO")
	//-- Modifica variaveis para a Query
	For nCont:=1 to Len(cSit)
		cSitQuery += "'"+Subs(cSit,nCont,1)+"'"
		If ( nCont+1 ) <= Len(cSit)
			cSitQuery += ","
		Endif
	Next nCont

	cCatQuery := ""
	For nCont:=1 to Len(cCat)
		cCatQuery += "'"+Subs(cCat,nCont,1)+"'"
		If ( nCont+1 ) <= Len(cCat)
			cCatQuery += ","
		Endif
	Next nCont

	lQuery	:= .T.

	aStru 	:= RGO->(dbStruct())

	cQuery := "SELECT DISTINCT RA_FILIAL, RA_MAT, RA_TPCIC, RA_CIC, RA_CATFUNC, RA_CC, RA_NOME, RA_ESTADO,"
	cQuery += " RA_MUNICIP, RA_CEP, RA_PRISOBR, RA_SECSOBR, RA_PRINOME, RA_SECNOME, RGO_NIF,"
	cQuery += "	RGO_TIPREN, RGO_ANO, RGO_LOCREN, RGO_VLRREN, RGO_VLRRET, RA_ADMISSA, RA_DEMISSA, RA_SITFOLH, RA_RG"
	cQuery += " FROM " + RetSqlName("RGO") + " RGO"
	cQuery += " INNER JOIN " + RetSqlName("SRA") + " SRA ON"
	cQuery += " RGO_FILIAL = RA_FILIAL" 
	cQuery += " AND RGO_MAT = RA_MAT"
	cQuery += " AND RGO_NIF = RA_RG"
	cQuery += " AND RGO_ANO = '" + cANO + "'" 
	cQuery += " AND RA_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "'" 
	cQuery += " AND RA_CC BETWEEN '" + cCcDe + "' AND '" + cCcAte + "'" 
	cQuery += " AND RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "'" 
	cQuery += " AND RA_NOME BETWEEN '" + cNomDe + "' AND '" + cNomAte + "'" 
	cQuery += " AND RA_SITFOLH IN (" + Upper(cSitQuery) + ") AND"
	cQuery += " RA_CATFUNC IN (" + Upper(cCatQuery) + ") AND"
	cQuery += " SRA.D_E_L_E_T_ = ''"
	cQuery += " WHERE RGO.D_E_L_E_T_ = ''"
	cQuery += "	ORDER BY RA_FILIAL, RA_MAT, RGO_NIF, RGO_TIPREN"

	cQuery := ChangeQuery(cQuery)

	SRA->( dbCloseArea() ) //Fecha o SRA para uso da Query
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery ),"RGO9",.F.,.T.)
	TCSetField("RGO9","RA_ADMISSA","D") // Formato de fecha
	TCSetField("RGO9","RA_DEMISSA","D") // Formato de fecha
	For nS := 1 To Len(aStru)
		If ( aStru[nS][2] <> "C" )
			TcSetField("RGO9",aStru[nS][1],aStru[nS][2],aStru[nS][3],aStru[nS][4])
		EndIf
	Next nS  
	cQrySRA:= "RGO9"

	DbSelectArea(cQrySRA) 
	ProcRegua((cQrySRA)->(RecCount()))   
	DbGotop()    

	SetRegua(1)                             

	cMat	:= (cQrySRA)->RA_MAT

	While (cQrySRA)->( !Eof() )                       

		IncRegua()

		If !lQuery
			If	((cQrySRA)->RA_FILIAL  < cFilDe) .Or. ((cQrySRA)->RA_FILIAL   > cFilAte) .Or. ;
			((cQrySRA)->RA_CC      < cCcDe ) .Or. ((cQrySRA)->RA_CC       > cCcAte ) .Or. ;
			((cQrySRA)->RA_MAT     < cMatDe) .Or. ((cQrySRA)->RA_MAT      > cMatAte) .Or. ;
			((cQrySRA)->RA_NOME    < cNomDe) .Or. ((cQrySRA)->RA_NOME     > cNomAte)
				(cQrySRA)->(dbSkip()) 
				Loop
			EndIf 

			If !((cQrySRA)->RA_SITFOLH $ cSit) .Or. !((cQrySRA)->RA_CATFUNC $ cCat)
				(cQrySRA)->(dbSkip()) 
				Loop
			EndIf
		Endif

		If  !((cQrySRA)->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
			(cQrySRA)->(dbSkip()) 
			Loop
		EndIf 	

		cFil	:= (cQrySRA)->RA_FILIAL

		If (cQrySRA)->RA_ADMISSA > dDtIni
			dDtIni := (cQrySRA)->RA_ADMISSA
		EndIf

		If (cQrySRA)->RA_SITFOLH="D" .And. (cQrySRA)->RA_DEMISSA >= dDtIni .And. (cQrySRA)->RA_DEMISSA <= DDTFIM
			dDtFim := (cQrySRA)->RA_DEMISSA
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³FPOSTAB                                                   ³
		//³Parametros³cCodTab 	= Codigo da tabela                   ³
		//³          ³uCOnt1  	= Conteudo1 para comparacao          ³
		//³          ³cOper1    	= Operador 1 para comparacao     ³
		//³          ³nColTab1 	= Numero da Coluna1 para comparacao  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nAUX01  := FPOSTAB("S022",(cQrySRA)->RA_TPCIC,"=",4)
		nAUX01d := FPOSTAB("S010",(cQrySRA)->RA_FILIAL, "=", 1,) 
		cNomeRep  := RTRIM(LTRIM(fTabela("S010", 01, 11))) + " " + RTRIM(LTRIM(fTabela("S010", 01,12)))+ " " + RTRIM(LTRIM(fTabela("S010", 01, 13))) + " " + RTRIM(LTRIM(fTabela("S010", 01, 14)))//cNomeRep  := fTabela("S002", 01, 10)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³FTABELA                                           ³
		//³Parametros³cCodTab 	= Codigo da tabela           ³
		//³          ³nLinhaTab  	= Linha a ser retornada  ³
		//³          ³nColTab 	= Coluna a Ser Retornada     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		cTipDoc := If(nAUX01 <> 0, FTABELA("S022", nAUX01,6)," ")
		If nAUX01d == 0 .Or. nAUX01d == NIL
			nAUX01d := 1
		EndIf
		cCodDep := FTABELA("S010",nAUX01d,8) 

		cPriApel:= PADR((cQrySRA)->RA_PRISOBR, 15)
		cSegApel:= PADR((cQrySRA)->RA_SECSOBR, 15)
		cPriNom := PADR((cQrySRA)->RA_PRINOME, 15)
		cSegNom := PADR((cQrySRA)->RA_SECNOME, 15)
		cNumDoc	 := (cQrySRA)->RA_RG 

		// Obtiene Informacion de la tabla SM0
		If !fInfo(@aInfo,cFilMtrz)
			Exit
		Endif

		cNIT	:= PADR(aInfo[8], 14) //Pega o CNPJ da Empresa
		cRazao	:= PADR(aInfo[3], 40) //Razón Social
		cCidade	:= PADR(aInfo[5], 30) //Lugar - Ciudad
		cBairent := PADR(aInfo[13], 30)
		cCodMun	:= aInfo[19] 			//Cod. Municipio

		cMat	:= (cQrySRA)->RA_MAT  

		nSalar		:= 0
		nPagBonVar	:= 0
		nvalCesan	:= 0
		nValFonCes	:= 0
		nGasRepr	:= 0
		nPensaJub	:= 0
		nOutrIngr	:= 0
		nValEPS		:= 0
		nValAFP		:= 0
		nCotVolReg	:= 0
		nValAFC		:= 0
		nValIR		:= 0
		nArrendRec	:= 0
		nArrendRet	:= 0
		nHonorRec	:= 0
		nHonorRet	:= 0
		nRendFinRc	:= 0
		nRendFinRt	:= 0	
		nAtFixoRec	:= 0
		nAtFixoRet	:= 0	
		nLotRec		:= 0
		nLOtRet		:= 0 	
		nOutrosRec	:= 0
		nOutrosRet	:= 0
		nTotDeudas	:= 0				

		While (cQrySRA)->( !Eof() ) .AND. (cQrySRA)->RA_MAT == cMat .and. (cQrySRA)->RA_RG  == cNumDoc
			cTipo := AllTrim((cQrySRA)->RGO_TIPREN)
			IF cTipo == "A"
				nSalar := (cQrySRA)->RGO_VLRREN			//Salario o emolumentos eclesiásticos
			ELSEIF cTipo == "W"
				nPagBonVar := (cQrySRA)->RGO_VLRREN		//37 - W - Pagos realizados con bonos electrónicos o de papel de servicio, cheques, tarjetas, vales, etc.
			ELSEIF cTipo == "B"
				nvalCesan:= (cQrySRA)->RGO_VLRREN		//Valor Cesantias e intereses cesantias
			ELSEIF cTipo == "B1"
				nValFonCes := (cQrySRA)->RGO_VLRREN		//47 - B1 - Cesantías consignadas al fondo de cesantías
			ELSEIF cTipo == "C"
				nGasRepr := (cQrySRA)->RGO_VLRREN		//Gastos Representacion
			ELSEIF cTipo == "D"
				nPensaJub := (cQrySRA)->RGO_VLRREN		//Pensao jubilacion
			ELSEIF cTipo == "E"                          
				nOutrIngr := (cQrySRA)->RGO_VLRREN		//Outros Ingressos
			ELSEIF cTipo == "F"
				nValEPS := (cQrySRA)->RGO_VLRREN		//Aportes obrigatorios por saude
			ELSEIF cTipo == "G"
				nValAFP := (cQrySRA)->RGO_VLRREN		//Aportes obligatorios a fondos de pensiones
			ELSEIF cTipo == "G1"
				nCotVolReg := (cQrySRA)->RGO_VLRREN		//52 - G1 - Cotizaciones voluntarias al régimen de ahorro individual con solidaridad – RAIS
			ELSEIF cTipo == "H"
				nValAFC := (cQrySRA)->RGO_VLRREN		//Aportes voluntarios a fondos de pensao
			ELSEIF cTipo == "I"
				nValIR := (cQrySRA)->RGO_VLRRET			//valor Retido IR
			ELSEIF cTipo == "J"
				nArrendRec := (cQrySRA)->RGO_VLRREN		//56 - J - Arrendamientos (recibidos)
			ELSEIF cTipo == "J1"
				nArrendRet := (cQrySRA)->RGO_VLRREN		//63 - J1 - Arrendamientos (retenidos)
			ELSEIF cTipo == "K"
				nHonorRec  := (cQrySRA)->RGO_VLRREN		//57 - K - Honorarios, comisiones y servicios (recibidos)
			ELSEIF cTipo == "K1"
				nHonorRet  := (cQrySRA)->RGO_VLRREN		//64 - K1 - Honorarios, comisiones y servicios (retenidos)
			ELSEIF cTipo == "L"
				nRendFinRc := (cQrySRA)->RGO_VLRREN		//58 - L - Intereses y rendimientos financieros (recibidos)
			ELSEIF cTipo == "L1"
				nRendFinRt := (cQrySRA)->RGO_VLRREN		//65 - L - Intereses y rendimientos financieros (retenidos)
			ELSEIF cTipo == "M"
				nAtFixoRec := (cQrySRA)->RGO_VLRREN		//59 - M - Enajenación de activos fijos (recibidos)
			ELSEIF cTipo == "M1"
				nAtFixoRet := (cQrySRA)->RGO_VLRREN		//66 - M1 - Enajenación de activos fijos (retenidos)
			ELSEIF cTipo == "N"
				nLotRec := (cQrySRA)->RGO_VLRREN		//60 - N - Loterías, rifas, apuestas y similares (recibidos)
			ELSEIF cTipo == "N1"
				nLOtRet := (cQrySRA)->RGO_VLRREN		//67 - N1 - Loterías, rifas, apuestas y similares (retenidos)
			ELSEIF cTipo == "O"
				nOutrosRec := (cQrySRA)->RGO_VLRREN		//61 - O - Otros (recibidos)
			ELSEIF cTipo == "O1"
				nOutrosRet := (cQrySRA)->RGO_VLRREN		//68 - O - Otros (retenidos)
			ELSEIF cTipo == "P"
				nIngHonor	:= (cQrySRA)->RGO_VLRREN	//Honorarios
			ELSEIF cTipo == "Q"
				nIngServ	:= (cQrySRA)->RGO_VLRREN	//Servicios
			ELSEIF cTipo == "R"
				nIngComis	:= (cQrySRA)->RGO_VLRREN	//Comisiones
			ELSEIF cTipo == "S"
				nIngPSoci	:= (cQrySRA)->RGO_VLRREN	//Prestaciones sociales
			ELSEIF cTipo == "T"
				nIngViat	:= (cQrySRA)->RGO_VLRREN	//Viaticos
			ELSEIF cTipo == "U"
				nIngComp	:= (cQrySRA)->RGO_VLRREN	//Compensaciones por el trabajo asociado a cooperaticip
			ELSEIF cTipo == "V"
				nApoVolPen	:= (cQrySRA)->RGO_VLRREN	//Aportes voluntarios a fondos de pensiones
			ENDIF

			//Total de sección - Concepto de los Ingresos - (Sume 36 a 48)
			nTotIngrBru	:= (nSalar		+ ; //36 - A - Salarios o emulumentos eclesiasticos
							nPagBonVar	+ ; //37 - W - Pagos realizados con bonos electrónicos o de papel de servicio, cheques, tarjetas, vales, etc.
							nIngHonor	+ ; //38 - P - Pagos por honorarios
							nIngServ	+ ; //39 - Q - Pagos por servicios
							nIngComis	+ ; //40 - R - Pagos por comisiones
							nIngPSoci	+ ; //41 - S - Pagos por prestaciones sociales
							nIngViat	+ ; //42 - T - Pagos por viáticos
							nGasRepr	+ ; //43 - C - Pagos por gastos de representación
							nIngComp	+ ; //44 - U - Pagos por compensaciones por el trabajo asociado cooperativo
							nOutrIngr	+ ; //45 - E - Otros pagos
							nValCesan	+ ; //46 - B - Cesantías e intereses de cesantías efectivamente pagadas al empleado
							nValFonCes	+ ; //47 - B1 - Cesantías consignadas al fondo de cesantías
							nPensaJub	)	//48 - D - Pensiones de jubilación, vejez o invalidez
			
			//Total de sección  - Valor recibido - (Sume 56 a 61)
			nTotVlReceb	:= (nArrendRec	+ ; //56 - J - Arrendamientos
							nHonorRec	+ ; //57 - K - Honorarios, comisiones y servicios
							nRendFinRc	+ ; //58 - L - Intereses y rendimientos financieros
							nAtFixoRec	+ ; //59 - M - Enajenación de activos fijos
							nLotRec		+ ; //60 - N - Loterías, rifas, apuestas y similares
							nOutrosRec	)	//61 - O - Otros

			//Total de sección - Valor retenido - (Sume 63 a 68)
			nTotVlRetido:= (nArrendRet	+ ; //63 - J1 - Arrendamientos
							nHonorRet	+ ; //64 - K1 - Honorarios, comisiones y servicios
							nRendFinRt	+ ; //65 - L1 - Intereses y rendimientos financieros
							nAtFixoRet	+ ; //66 - M1 - Enajenación de activos fijos
							nLotRet		+ ; //67 - N1 - Loterías, rifas, apuestas y similares
							nOutrosRet	)	//68 - O1 - Otros
			
			nTotRetenAno:= (nValIR + nTotVlRetido )	//Total retenciones año gravable (Sume 55 y 69)

			(cQrySRA)->(dbSkip(1))   
		ENDDO

		fBuscaDep(cMat,cNumdoc,cANO)     //Carrega os Dependentes

		fBuscaBens(cMat,cNumdoc,cANO)    //Carrega os BEns do Funcionario

		GprImprDIAN()   //Imprime o Certificado             
		nConsec := nConsec +1     
	ENDDO

	oPrint:PREVIEW()       //Finaliza a pagina    

	(cQrySRA)->(dbCloseArea())
	
Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GprImprDian  ³ Autor ³ Abel Ribeiro            ³ Data ³ 10.02.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 	Imprime os dados.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GprImprDian()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GprImprDIAN()  

	Local nLinha	:= 0    
	Local nX		:= 0			
	Local cArquivoC	:= fLoadLogo(cArquivo)	// Carrega o Arquivo de imagem
	Local nPosLin1	:= 2050
	Local nPosLin2	:= 1550
	Local cPictVal	:= "@E 999,999,999,999.99"

	oPrint:StartPage()	// Inicia uma nova pagina

	If File(cArquivoC)

		oPrint:SayBitmap(05, 00, cArquivoC, 2350, 3350,,.F.) //Tem que estar abaixo do RootPath
		
		oPrint:say(230,1200,str(nConsec),oFont10)            //Consecutivo iniciando en 1
		oPrint:say(340,130,SUBSTR(cNIT,1,1)+SPACE(02)+SUBSTR(cNIT,2,1)+SPACE(03) +;
		SUBSTR(cNIT,3,1)+SPACE(02)+SUBSTR(cNIT,4,1)+SPACE(03) +;
		SUBSTR(cNIT,5,1)+SPACE(02)+SUBSTR(cNIT,6,1)+SPACE(03) +;
		SUBSTR(cNIT,7,1)+SPACE(02)+SUBSTR(cNIT,8,1)+SPACE(03) +;
		SUBSTR(cNIT,9,1)+SPACE(02)+SUBSTR(cNIT,10,1)+SPACE(03)+;
		SUBSTR(cNIT,11,1)+SPACE(02)+SUBSTR(cNIT,12,1)+SPACE(02) +;
		SUBSTR(cNIT,13,1)+SPACE(02)+SUBSTR(cNIT,14,1)+SPACE(03),ofont11)  //Identificacao Tributaria - NIT
		oPrint:say(435,145,cRazao,oFont10)            //Apelido/s y Nombre/s del Empleador Certificante

		oPrint:say(560,165,cTipDoc,oFont10) //Tipo DOC.
		oPrint:say(530,270,SUBSTR(cNUMDOC,1,1)+SPACE(02)+SUBSTR(cNUMDOC,2,1)+SPACE(03) +;
		SUBSTR(cNUMDOC,3,1)+SPACE(02)+SUBSTR(cNUMDOC,4,1)+SPACE(03) +;
		SUBSTR(cNUMDOC,5,1)+SPACE(02)+SUBSTR(cNUMDOC,6,1)+SPACE(03) +;
		SUBSTR(cNUMDOC,7,1)+SPACE(02)+SUBSTR(cNUMDOC,8,1)+SPACE(03) +;
		SUBSTR(cNUMDOC,9,1)+SPACE(02)+SUBSTR(cNUMDOC,10,1)+SPACE(03)+;
		SUBSTR(cNUMDOC,11,1)+SPACE(02)+SUBSTR(cNUMDOC,12,1)+SPACE(02) +;
		SUBSTR(cNUMDOC,13,1)+SPACE(02)+SUBSTR(cNUMDOC,14,1)+SPACE(03),oFont10)   //Numero Documento

		oPrint:say(530,910,cPriApel, oFont10)  //Ap Paterno 
		oPrint:say(530,1260,cSegApel, oFont10) //Ap Materno
		oPrint:say(530,1620,cPriNom , oFont10) //1er nombre
		oPrint:say(530,1980,cSegNom , oFont10) //2do nombre 

		oPrint:say(660,50,STR(YEAR(dDtIni))	+SPACE(03)+ SUBSTR(DTOC(dDtIni),4,2)	+SPACE(03)+ SUBSTR(DTOC(dDtIni),1,2),oFont10) //Data Inicial
		oPrint:say(660,500,STR(YEAR(dDtFim))	+SPACE(03)+ SUBSTR(DTOC(dDtFim),4,2)	+SPACE(03)+ SUBSTR(DTOC(DDTFIM),1,2),oFont10)//Data Final 
		oPrint:say(660,850,STR(YEAR(DDATABASE))	+SPACE(05)+ SUBSTR(DTOC(DDATABASE),4,2)	+SPACE(03)+ SUBSTR(DTOC(DDATABASE),1,2),oFont10) 
		oPrint:say(660,1360, cBairent+ " " +cCidade,oFont10)      
		oPrint:say(660,2040,Substr(cCodDep,1,1)+space(04)+Substr(cCodDep,2,1),oFont10)                                   //Codigo do Estado
		oPrint:say(660,2150,Substr(cCodMun,1,1)+sPace(03)+Substr(cCodMun,2,1)+space(05)+Substr(cCodMun,3,1),oFont10)      //Codigo Municipio

		//--- Concepto de los Ingresos ---
		oPrint:say(770	,nPosLin1,AlinhaPict(nSalar			, cPictVal),oFont10)		//36 - A - Salarios o emulumentos eclesiasticos
		oPrint:say(825	,nPosLin1,AlinhaPict(nPagBonVar		, cPictVal),oFont10)		//37 - W - Pagos realizados con bonos electrónicos o de papel de servicio, cheques, tarjetas, vales, etc.
		oPrint:say(880	,nPosLin1,AlinhaPict(nIngHonor		, cPictVal),oFont10)		//38 - P - Pagos por honorarios
		oPrint:say(935	,nPosLin1,AlinhaPict(nIngServ		, cPictVal),oFont10)		//39 - Q - Pagos por servicios
		oPrint:say(985	,nPosLin1,AlinhaPict(nIngComis		, cPictVal),oFont10)		//40 - R - Pagos por comisiones
		oPrint:say(1040	,nPosLin1,AlinhaPict(nIngPSoci		, cPictVal),oFont10)		//41 - S - Pagos por prestaciones sociales
		oPrint:say(1090	,nPosLin1,AlinhaPict(nIngViat		, cPictVal),oFont10)		//42 - T - Pagos por viáticos
		oPrint:say(1140	,nPosLin1,AlinhaPict(nGasRepr		, cPictVal),oFont10)		//43 - C - Pagos por gastos de representación
		oPrint:say(1195	,nPosLin1,AlinhaPict(nIngComp		, cPictVal),oFont10)		//44 - U - Pagos por compensaciones por el trabajo asociado cooperativo
		oPrint:say(1250	,nPosLin1,AlinhaPict(nOutrIngr		, cPictVal),oFont10)		//45 - E - Otros pagos
		oPrint:say(1305	,nPosLin1,AlinhaPict(nValCesan		, cPictVal),oFont10)		//46 - B - Cesantías e intereses de cesantías efectivamente pagadas al empleado
		oPrint:say(1360	,nPosLin1,AlinhaPict(nValFonCes		, cPictVal),oFont10)		//47 - B1 - Cesantías consignadas al fondo de cesantías
		oPrint:say(1410	,nPosLin1,AlinhaPict(nPensaJub		, cPictVal),oFont10)		//48 - D - Pensiones de jubilación, vejez o invalidez
		//Total de sección - Concepto de los Ingresos
		oPrint:say(1465	,nPosLin1,AlinhaPict(nTotIngrBru	, cPictVal),oFont10n)		//49 - Total ingresos brutos (sume 36 a 48)

		//--- Concepto de los Aportes ---
		oPrint:say(1580	,nPosLin1,AlinhaPict(ABS(nValEPS)		, cPictVal),oFont10)	//50 - F - Aportes obligatorios por salud a cargo del trabajador
		oPrint:say(1625	,nPosLin1,AlinhaPict(ABS(nValAFP)		, cPictVal),oFont10)	//51 - G - Aportes obligatorios a fondos de pensiones y solidaridad pensional a cargo del trabajador
		oPrint:say(1680	,nPosLin1,AlinhaPict(ABS(nCotVolReg)	, cPictVal),oFont10)	//52 - G1 - Cotizaciones voluntarias al régimen de ahorro individual con solidaridad - RAIS
		oPrint:say(1730	,nPosLin1,AlinhaPict(ABS(nValAFC)		, cPictVal),oFont10)	//53 - H - Aportes voluntarios a fondos de pensiones
		oPrint:say(1780	,nPosLin1,AlinhaPict(ABS(nApoVolPen)	, cPictVal),oFont10)	//54 - V - Aporte a cuentas AFC
		oPrint:say(1835	,nPosLin1,AlinhaPict(ABS(nValIR)		, cPictVal),oFont10n)	//55 - I - Valor de la retención en la fuente por ingresos laborales y de pensiones
		
		oPrint:say(1885	,0600,cNomeRep , oFont10) //Nombre del pagador o agente retenedor

		//--- Sección Datos a cargo del trabajador o pensionado ---

		// Columna de Valor recibido
		oPrint:say(2055	,nPosLin2,AlinhaPict(nArrendRec		, cPictVal),oFont10)		//56 - J - Arrendamientos
		oPrint:say(2105	,nPosLin2,AlinhaPict(nHonorRec		, cPictVal),oFont10)		//57 - K - Honorarios, comisiones y servicios
		oPrint:say(2160	,nPosLin2,AlinhaPict(nRendFinRc		, cPictVal),oFont10)		//58 - L - Intereses y rendimientos financieros
		oPrint:say(2210	,nPosLin2,AlinhaPict(nAtFixoRec		, cPictVal),oFont10)		//59 - M - Enajenación de activos fijos
		oPrint:say(2265	,nPosLin2,AlinhaPict(nLotRec		, cPictVal),oFont10)		//60 - N - Loterías, rifas, apuestas y similares
		oPrint:say(2315	,nPosLin2,AlinhaPict(nOutrosRec		, cPictVal),oFont10)		//61 - O - Otros

		oPrint:say(2370	,nPosLin2,AlinhaPict(nTotVlReceb	, cPictVal),oFont10n)		//62 - Totales: (Valor recibido: Sume 56 a 61)

		// Columna de Valor retenido
		oPrint:say(2055	,nPosLin1,AlinhaPict(nArrendRet		, cPictVal),oFont10)		//63 - J1 - Arrendamientos
		oPrint:say(2105	,nPosLin1,AlinhaPict(nHonorRet		, cPictVal),oFont10)		//64 - K1 - Honorarios, comisiones y servicios
		oPrint:say(2160	,nPosLin1,AlinhaPict(nRendFinRt		, cPictVal),oFont10)		//65 - L1 - Intereses y rendimientos financieros
		oPrint:say(2210	,nPosLin1,AlinhaPict(nAtFixoRet		, cPictVal),oFont10)		//66 - M1 - Enajenación de activos fijos
		oPrint:say(2265	,nPosLin1,AlinhaPict(nLotRet		, cPictVal),oFont10)		//67 - N1 - Loterías, rifas, apuestas y similares
		oPrint:say(2315	,nPosLin1,AlinhaPict(nOutrosRet		, cPictVal),oFont10)		//68 - O1 - Otros
		
		oPrint:say(2370	,nPosLin1,AlinhaPict(nTotVlRetido	, cPictVal),oFont10n)		//69 - Totales: (Valor retenido: Sume 63 a 68)

		//Sección Total de Datos a cargo del trabajador o pensionado
		oPrint:say(2425	,460,TransForm(cAno,"9999"),oFont09n)							//Año gravable
		oPrint:say(2425	,nPosLin1,AlinhaPict(ABS(nTotRetenAno),cPictVal),oFont10n)		//70 - Total retenciones año gravable (Sume 55 + 69)
		
		//Imprime los bienes y derechos poseídos
		nLinha := 2530

		For nX := 1 To Len(aBensPatr)
			If nX > 6
				Exit
			EndIf

			If aBensPatr[nX][4] == "1" //Solo obtiene registros considerados como 1 - Bienes
				oPrint:say(nLinha,150,aBensPatr[nX,2],oFont10) // 71 - Identificación de los bienes y derechos poseídos
				oPrint:say(nLinha,nPosLin1,AlinhaPict(aBensPatr[nX,3],cPictVal),oFont10) // 72 - Valor patrimonial
				nLinha += 50
			EndIf
		Next nX

		oPrint:say(2850, 570,TransForm(cAno,"9999"),oFont10n, , CLR_WHITE) //Año competencia

		//Imprime total de Deudas vigentes
		For nX := 1 To Len(aBensPatr)
			If aBensPatr[nX][4] == "2" //Solo obtiene registros considerados como 2 - Deudas
				nTotDeudas += aBensPatr[nX][3]
			EndIf
		Next nX

		oPrint:say(2850, nPosLin1, AlinhaPict(ABS(nTotDeudas),cPictVal), oFont10n)	// 73 - Valor de las Deudas vigentes a 31 de diciembre del Año competencia 

		//Imprime los Dependientes
		nLinha := 2980

		For nX := 1 To Len(aDep)
			IF nX > 2
				Exit
			ENDIF
			
			oPrint:say(nLinha, 100, aDep[nX, 4], oFont08)	// 74 - Tipo de Documento
			oPrint:say(nLinha, 300, aDep[nX, 1], oFont08)	// 75 - No. Documento
			oPrint:say(nLinha, 600, aDep[nX, 2], oFont08)	// 76 - Apellidos y Nombres
			oPrint:say(nLinha, 2000, aDep[nX, 3], oFont08)	// 77 - Parentesco
			
			nLinha += 30
		Next nX

	EndIf
	
	oPrint:EndPage()   //Finaliza a Pagina

	aDep     := {}
	aBensPatr:= {}

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |fLoadLogo ºAutor  ³Abel Ribeiro        º Data ³  02/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Esta funcao carrega as imagens que serao utilizadas na      º±±
±±º          ³impressao do formulario PS6.2                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Localizado Argentina                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fLoadLogo(cNomeArq)

	Local cStartPath := GetSrvProfString("Startpath","") 

	If Substr(cStartPath, Len(cStartPath), 1) == "\"
		cImagem := cStartPath + cNomeArq        
	Else
		cImagem := cStartPath + "\" + cNomeArq    
	Endif

Return cImagem

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |fBuscaDep ºAutor  ³Abel Ribeiro        º Data ³  02/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Esta funcao busca os dependentes do FUncionario             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Localizado Colombia                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function fBuscaDep(cMat,cCCNit,cANO)

	Local aAreaSRB	:= GetArea()
	Local cTipoDoc	:= ""

	Default cMat	:= ""
	Default cCCNit	:= ""
	Default cANO	:= ""

	DBSelectArea("SRB")
	SRB->(DBSetOrder(1)) //RB_FILIAL+RB_MAT+RB_COD
	SRB->(DBSeek(cFIL+cMAT))
	While SRB->(!Eof()) .And. cFIL+cMAT == SRB->(RB_FILIAL+RB_MAT)
		m_graupar	:= IIf(SRB->RB_GRAUPAR == "F", STR0010, (IIf(SRB->RB_GRAUPAR == "C", STR0011, STR0012))) // "Hijo" - "Conyuge" - "Otros"
		cTipoDoc	:= AllTrim(FDescRCC("S022", SRB->RB_TPCIC, 1, 2, 38, 2)) //Obtiene Columna correspondiente al Código de Cert. Ing. y Ret.
		aAdd(aDep, {SRB->RB_CIC, SRB->RB_NOME, m_graupar, cTipoDoc})
		SRB->(DBSkip())
	Enddo

	RestArea(aAreaSRB)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |fBuscaBensºAutor  ³Abel Ribeiro        º Data ³  02/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Esta funcao busca os Bens do Funcionario                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Localizado Colombia                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function fBuscaBens(cMat,cNumDoc,cAno)

	Local aAreaRCS	:= GetArea()

	Default cMat	:= ""
	Default cNumDoc	:= ""
	Default cAno	:= ""

	DBSelectArea("RCS")
	RCS->(DBSetOrder(4)) //RCS_FILIAL+RCS_ANO+RCS_MAT+RCS_CPFBEN+RCS_TIPORE
	RCS->(DBSeek(cFil+cAno+cMat+cNumDoc))
	While RCS->(!Eof()) .And. cFil+cMat = RCS->(RCS_FILIAL+RCS_MAT)
		aAdd(aBensPatr, {RCS->RCS_TIPORE, RCS->RCS_DESCRI, RCS->RCS_VALOR, RCS->RCS_ORIGEM})
		RCS->(DBSkip())
	Enddo

	RestArea(aAreaRCS)
	
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    |AlinhaPictºAutor  ³Abel Ribeiro        º Data ³  02/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Esta funcao faz o Alinhamento das Pictures dos valores      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Localizado Colombia                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AlinhaPict(nVlr,cPicture)

	Local cRet

	If Len(Alltrim(Str(Int(nVlr)))) == 9    
		cRet := PADL(" ",1," ") + AllTrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr)))) == 8                    
		cRet := PADL(" ",3," ") + AllTrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr)))) == 7                    
		cRet := PADL(" ",5," ") + AllTrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr)))) == 6                    
		cRet := PADL(" ",8," ") + AllTrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr)))) == 5                     
		cRet := PADL(" ",10," ") + AllTrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr)))) == 4                       
		cRet := PADL(" ",12," ") + AllTrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr)))) == 3                    
		cRet := PADL(" ",15," ") + AllTrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr)))) == 2               
		cRet := PADL(" ",17," ") + AllTrim(Transform(nVlr,cPicture))
	ElseIf Len(Alltrim(Str(Int(nVlr)))) == 1         
		cRet := PADL(" ",19," ") + AllTrim(Transform(nVlr,cPicture))
	Endif
	
Return (cRet)
