#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATR264.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR264  ³ Autor ³Bruno Schmidt			      ³ Data ³ 10/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ REGISTRO DE INVENTARIO PERMANENTE EN UNIDADES FISICAS            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS       ³ Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³L.Enríquez  ³21/12/16³SERINN001   ³ Se realizó merge contra los cambios      ³±±
±±³            ³        ³-375        ³ hechos para dejar de usar CriaTrab y     ³±±
±±³            ³        ³            ³ utilizar clase FWTemporaryTable.         ³±±
±±³  Marco A.  ³16/04/18³ DMINA-2310 ³Se remueven sentencias CriaTrab y se apli-³±±
±±³            ³        ³            ³ca FWTemporaryTable(), para el manejo de  ³±±
±±³            ³        ³            ³las tablas temporales.                    ³±±
±±³Alf Medrano ³27/04/18³ DMINA-1035 ³ se asigna funcionalida para serie 2 y 3 -³±±
±±³            ³        ³            ³ modifican las fun ReportDef, ReportPrint ³±±
±±³            ³        ³            ³ MATR264FillTrb y GerArq para Perú        ³±±
±±³LuisEnríquez³10/07/19³ DMINA-6847 ³ Se compatibiliza rutina con v11.8 usando ³±±
±±³            ³        ³            ³ funcion MATR264CT para creación de tabla ³±±
±±³            ³        ³            ³ temporal. (PER)                          ³±±
±±³ARodriguez  ³17/06/20³ DMINA-9200 ³ Nueva columna 8 condicionada por parám.  ³±±
±±³            ³        ³            ³ MV_PLEPERU, vigente 01/07/2020. PER      ³±±
±±³ARodriguez  ³17/12/20³ DMINA-10545³Ajustes en las columnas 5, 7, 8 y 9.      ³±±
±±³            ³        ³            ³manejo de MV_PLEPERU y tabla 13 SUNAT     ³±±
±±³ARodriguez  ³07/01/21³ DMINA-10791³Ajustes en las columnas 3, 12, 16 y 17    ³±±
±±³            ³        ³            ³en el TXT para prevenir rechazos PLE      ³±±
±±³Oscar Garcia³24/06/21³DMINA-12466 ³Se ajusta tamaño de campo Num Doc a tam.  ³±±
±±³            ³        ³            ³de campo F1_DOC en imp. de archivo. PER   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MATR264()
Local oReport	:= Nil

Private oTmpTable	:= Nil //usada en la rutina PERXTMP para tratamiento de tablas temporales
Private titulo		:= ""
Private cPosCpo     := IIf(cVersao=="11", "FieldPos", "ColumnPos")

oReport := ReportDef()
If Valtype( oReport ) == 'O'
	If ! Empty( oReport:uParam )
		Pergunte( oReport:uParam, .F. )
	EndIf
	oReport:PrintDialog()
Endif


oReport := Nil
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Bruno Schmidt		    ³ Data ³ 10/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatorio                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
	Local cPicD1Qt  := PesqPict("SD1","D1_QUANT" ,18)
	Local cPicD2Qt  := PesqPict("SD2","D2_QUANT" ,18)
	Local cPicB2Qt  := PesqPictQt("B2_QATU",18)
	Local oSection1
	Local oSection2
	Local oSection3
	Local oReport
	Local cDesc1 	:= ""
	Local cDesc2 	:= ""
	Local cDesc3 	:= ""
	Local cPerg		:="MTR264"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do componente de impressao                                      ³
	//³                                                                        ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oReport := TReport():New("MATR264",substr(STR0001,1,94),cPerg,{|oReport| ReportPrint(oReport)},cDesc1+cDesc2+cDesc3)
	oReport:SetTotalInLine(.F.)

	Pergunte(cPerg,.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MV_PAR01 - De Producto? ³
	//³MV_PAR02 - A Producto? ³
	//³MV_PAR03 - De Tipo?³
	//³MV_PAR04 - A Tipo? ³
	//³MV_PAR05 - De Periodo? ³
	//³MV_PAR06 - A Periodo? ³
	//³MV_PAR07 - Almacen (* Todos)? ³
	//³MV_PAR08 - De Grupo? ³
	//³MV_PAR09 - A Grupos? ³
	//³MV_PAR10 - Sucursal)? ³
	//³MV_PAR11 - Generar Archivo? ³
	//³MV_PAR12 - Directorio? ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao da Sessao 1 - Dados do Produto                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1 := TRSection():New(oReport,STR0063,{"SA1","SA2"}) //"Cabecalio"
	oSection1 :SetTotalInLine(.F.)
	oSection1 :SetReadOnly()
	oSection1 :SetLineStyle()
	oSection1 :SetHeaderPage()
	oSection1 :NCOLS:=1
	TRCell():New(oSection1,"CODIGO"	,"",STR0071	,/*Picture*/,TAMSX3("B1_COD")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"TIPO"	,"",STR0025 ,/*Picture*/,10         		 ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"DESC"	,"",STR0072	,/*Picture*/,TAMSX3("B1_DESC")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"CODUN"  ,"",STR0073	,/*Picture*/,50         	     ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"ESTABL" ,"","CODIGO DEL ESTABLECIMIENTO" ,/*Picture*/,50,/*lPixel*/,/*{|| code-block de impressao }*/)		// "cODIGO DEL ESTABLECIMIENTO
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao da Sessao 2 - Cont. dos dados do Produto           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection2 := TRSection():New(oSection1,STR0064,{"SB1","SB2"}) //"Produtos (Parte 2)"
	oSection2 :SetTotalInLine(.F.)
	oSection2 :SetReadOnly()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao da Sessao 3 - Movimentos                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection3 := TRSection():New(oSection2,STR0065,{"SD1","SD2","SD3"}) //"Movimentação dos Produtos"
	oSection3 :SetTotalInLine(.F.)
	oSection3 :SetTotalText(STR0021) //"T O T A I S  :"
	oSection3 :SetReadOnly()

	oSection3 :NCOLS:=1
	TRCell():New(oSection1," "	,"",SPACE(80),/*Picture*/,80,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1," "	,"",SPACE(80),/*Picture*/,80,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1," "	,"",Replicate("_",77),/*Picture*/,80,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1," "	,"",STR0084+CRLF+Replicate("_",77),/*Picture*/,80,/*lPixel*/,/*{|| code-block de impressao }*/) //"DOCUMENTO DE TRASLADO, COMPROBANTE DE PAGO, DOCUMENTO INTERNO O SIMILAR      :"
	oSection3 :NCOLS:=0
	TRCell():New(oSection3,"dDtMov"		,"   ",STR0040				,/*Picture*/,13         ,/*lPixel*/,/*{|| code-block de impressao }*/) //" (Tabla 10)"
	TRCell():New(oSection3,"Tipo"		,"   ",STR0058+STR0085,"@!"		,18			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"cCF"		,"   "," "					,"@!"		,04         ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"SERIE"		,"   ",STR0074				,"@!"		,20/*10*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"cDoc"		,"   ",STR0044				,"@!"		,29			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"cTraco1"	,"   ","|"+CRLF+"|"			,/*Picture*/,1			,/*lPixel*/,{|| "|" })
	TRCell():New(oSection3,"Tp Oper"	,"   ",STR0075 				,"@!"		,32			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"cTraco1"	,"   ","|"+CRLF+"|"			,/*Picture*/,1			,/*lPixel*/,{|| "|" })
	TRCell():New(oSection3,"nENTQtd"	,"   ",STR0045				,cPicD1Qt	,20			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"cTraco2"	,"   ","|"+CRLF+"|"			,/*Picture*/,1			,/*lPixel*/,{|| "|" })
	TRCell():New(oSection3,"nSAIQtd"	,"   ",STR0050	   			,cPicD2Qt	,20			,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection3,"cTraco6"	,"   ","|"+CRLF+"|"			,/*Picture*/,1			,/*lPixel*/,{|| "|" })
	TRCell():New(oSection3,"nSALDQtd"	,"   ",STR0051	   			,cPicD1Qt	,20			,/*lPixel*/,/*{|| code-block de impressao }*/)

	TRFunction():New(oSection3:Cell("nENTQtd"),NIL,"SUM",/*oBreak*/,"",cPicD1Qt	,/*uFormula*/,.T.,.F.)

	TRFunction():New(oSection3:Cell("nSAIQtd"),NIL,"SUM",/*oBreak*/,"",cPicD2Qt	,/*uFormula*/,.T.,.F.)

	TRFunction():New(oSection3:Cell("nSALDQtd"),NIL,"ONPRINT",/*oBreak*/,"",cPicB2Qt  ,{|| oSection3:Cell("nSALDQtd"):GetValue(.T.) },.T.,.F.)
Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Bruno Schmidt		    ³ Data ³ 10/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)
	Local oSection1		:= oReport:Section(1)
	Local oSection2		:= oReport:Section(1):Section(1)
	Local oSection3		:= oReport:Section(1):Section(1):Section(1)
	Local cWhereRE		:= ''

	Local CprodAux		:= ''
	Local nEntradas, nX	:= 0
	Local aSalAtu		:= {0,0,0,0,0,0,0}
	Local lRet		 	:= .T.

	Local nTamCod		:= TamSX3("B1_COD")[1]

	Local cTP			:= ""
	Local cYSerieF1     := ""
	Local cYSerieF2     := ""
	Local cGroupF1      := ""
	Local cGroupF2      := ""

	Local cTIPODOC		:= ""
	Local cEstabProd	:= ""
	Local cAliasTop 	:= ''
	Local lSele			:= .F.
	Local cTmpSD1Fil	:= ""
	Local cTmpSD2Fil	:= ""
	Local cTmpSD3Fil	:= ""
	Local cFilSFP		:=xFilial("SFP")
	Local aConSX5		:= {}
	Local cDessx5		:= ''
	Local nTamNDoc		:= GetSX3Cache("F1_DOC", "X3_TAMANHO")

	Private aSelFil		:= {}
	Private cSerKINV	:= SuperGetMv("MV_SERKINV" ,.F.,.F.)
	Private cSerKTM		:= SuperGetMv("MV_SERKTM" ,.F.,.F.)
	Private lUsaCodBar	:= SuperGetMv("MV_USACBAR" ,.F.,.F.)
	Private lusaTsx5	:= SuperGetMv("MV_USATSX5" ,.F.,.F.)
	Private lSerie2		:= GetNewPar("MV_LSERIE2",.T.)
	Private aLocal		:= {}
	Private nTamLocal	:= LEN(SB1->B1_LOCPAD)
	Private aLocalFiR	:= {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MV_CUSREP - Parametro utilizado para habilitar o calculo do   ³
	//³            Custo de Reposicao.                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private lCusRep  := SuperGetMv("MV_CUSREP",.F.,.F.) .And. (FindFunction("MA330AvRep") .And. MA330AvRep())

	titulo	:= oReport:Title()

	oReport:SetCustomText( {|| Cabec264( oReport ) })
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleccion de filiales y de almacenes                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(mv_par10) //Si sucursal vacio
		aSelFil := AdmGetFil()//llama a la pantalla de seleccion de filiales
		If Len( aSelFil ) <= 0
			lRet := .F.
		EndIf
	Else
		aSelFil := {mv_par10}
	EndIf

	MV_PAR07	:= MT263SelLocal(ALLTRIM(MV_PAR07),aSelFil) //llena con los almacenes seleccionados, si es que MV_PAR07 (Almacen) esta vacio
	lSele		:= .F.
	For nX:=1 To Len(aLocal)
		IF aLocal[nX,1]
			lSele := .T.
			EXIT
		ENDIF
	NEXT
	IF ! lSele
		MV_PAR07 := "('" + PADR('01', nTamLocal) +  "')"
	ENDIF




	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera arquivo de Trabalho                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aTamQ:=TamSX3("B2_QATU")
	aTamX:=TamSX3("F4_CF")
	aTamF:=TamSX3("A2_COD")
	aTamL:=TamSX3("A2_LOJA")
	aTamP:=TamSX3("B2_FILIAL")

	aCampos := {}
	AADD(aCampos,{"PRODUTO"  ,"C",nTamCod,0})
	AADD(aCampos,{"EMISSAO"  ,"D",08,0})
	AADD(aCampos,{"SEQCALC"  ,"C",14,0})
	AADD(aCampos,{"TES"      ,"C",03,0})
	AADD(aCampos,{"CF"       ,"C",aTamX[1],aTamX[2]})
	AADD(aCampos,{"TIPODOC"  ,"C",03,0})
	AADD(aCampos,{"NUMDOC"   ,"C",TamSX3('D1_DOC')[1],0})
	AADD(aCampos,{"SERIE"    ,"C",03,0})
	AADD(aCampos,{"QUANT"    ,"N",aTamQ[1],aTamQ[2]})
	AADD(aCampos,{"CLIFOR"   ,"C",aTamF[1],aTamF[2]})
	AADD(aCampos,{"LOJA"     ,"C",aTamL[1],aTamL[2]})
	AADD(aCampos,{"UM"       ,"C",03,0})
	AADD(aCampos,{"DTDIGIT"  ,"D",08,0})
	AADD(aCampos,{"NODIA"    ,"C",10,0})
	AADD(aCampos,{"SERIE3"   ,"C",20,0})
	AADD(aCampos,{"SERIE2"   ,"C",04,0})
	AADD(aCampos,{"FILIAL"   ,"C",aTamP[1],aTamP[2]})
	AADD(aCampos,{"XLOCAL"   ,"C",TamSX3('B2_LOCAL')[1],0})
	AADD(aCampos,{"XTPESTAB" ,"C",TamSX3('NNR_TIPOES')[1],0})
	AADD(aCampos,{"XIDESTAB" ,"C",TamSX3('NNR_IDSUNA')[1],0})
	AADD(aCampos,{"XITEM" 	 ,"C",10,0})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(oReport:uParam)

	cAliasTop := "TRC"


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatorio da secao 1                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):BeginQuery()
	If SF1->&(cPosCpo + '("F1_YSERIE")') > 0
		cYSerieF1 := "% F1_YSERIE %"
		cGroupF1  := "% F1_FILIAL,B1_TIPO,D1_COD,D1_SEQCALC,D1_DTDIGIT,D1_TES,D1_CF,D1_ESPECIE,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_UM,D1_DTDIGIT,F1_NODIA,F1_YSERIE,F1_SERIE2,D1_LOCAL,D1_ITEM %"
	Else
		cYSerieF1 := "% ' ' %"
		cGroupF1  := "% F1_FILIAL,B1_TIPO,D1_COD,D1_SEQCALC,D1_DTDIGIT,D1_TES,D1_CF,D1_ESPECIE,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_UM,D1_DTDIGIT,F1_NODIA,F1_SERIE2,D1_LOCAL,D1_ITEM %"
	EndIf

	cWhereD1 := "%"

	cWhereD1 +=  " SD1.D1_LOCAL IN "+mv_par07+" AND "
	cWhereD1 += " SD1.D1_FILIAL " + GetRngFil( aSelFil, "SD1", .T., @cTmpSD1Fil ) +  " AND "
	cWhereD1 += "%"


	If SF2->&(cPosCpo + '("F2_YSERIE")') > 0
		cYSerieF2 := "% F2_YSERIE %"
		cGroupF2 := "% F2_FILIAL,B1_TIPO,D2_COD,D2_SEQCALC,D2_EMISSAO,D2_TES,D2_CF,D2_ESPECIE,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_UM,D2_DTDIGIT,F2_NODIA,F2_YSERIE,F2_SERIE2,D2_LOCAL,D2_ITEM %"
	Else
		cYSerieF2 := "% ' ' %"
		cGroupF2  := "% F2_FILIAL,B1_TIPO,D2_COD,D2_SEQCALC,D2_EMISSAO,D2_TES,D2_CF,D2_ESPECIE,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_UM,D2_DTDIGIT,F2_NODIA,F2_SERIE2,D2_LOCAL,D2_ITEM %"
	EndIf

    cD2EMISSAO := "% D2_EMISSAO EMISSAO,%"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Complemento do Where da tabela SD2                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cWhereD2 := "%"

	cWhereD2 += " SD2.D2_LOCAL IN "+mv_par07+" AND "
	cWhereD2 += " SD2.D2_FILIAL " + GetRngFil( aSelFil, "SD2", .T., @cTmpSD2Fil )+  " AND "


	cWhereD2 += " SD2.D2_EMISSAO >= '"+Dtos(mv_par05)+"' AND "
	cWhereD2 += " SD2.D2_EMISSAO <= '"+Dtos(mv_par06)+"' AND "

	cWhereD2 += "%"

	cWhereRE := "%"
	cWhereRE += " (SD2.D2_REMITO   = '" + Space(TamSx3('D2_REMITO')[1]) + "' OR SD2.D2_TPDCENV IN ('1','A')) "
	cWhereRE += "%"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Complemento do WHERE da tabela SD3                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    cWhereD3 := "%"

	cWhereD3 += " SD3.D3_LOCAL IN " + mv_par07 + " AND"

   	If SuperGetMV('MV_D3ESTOR', .F., 'N') == 'N'
   		cWhereD3 += " SD3.D3_ESTORNO <> 'S' AND"
   	EndIf
	If SuperGetMV('MV_D3SERVI', .F., 'N') == 'N' .And. IntDL()
		cWhereD3 += " ( (D3_SERVIC = '   ') OR (D3_SERVIC <> '   ' AND D3_TM <= '500' AND D3_STSERV = '3') ) AND"
	EndIf
	cWhereD3 += " SD3.D3_FILIAL " + GetRngFil( aSelFil, "SD3", .T., @cTmpSD3Fil )+  " AND "
	cWhereD3 += "%"

	cOrder := "%"

	cOrder += " PRODUTO, EMISSAO, TES, UM,DTDIGIT"

	cOrder += "%"

	BeginSql Alias cAliasTop
		SELECT 	 F1_FILIAL FILIAL,
				 B1_TIPO TIPO,
		         D1_COD PRODUTO,
		         D1_SEQCALC SEQCALC,
		         D1_DTDIGIT EMISSAO,
		         D1_TES TES,
		         D1_CF CF,
		         D1_ESPECIE TIPODOC,
		         D1_DOC NUMDOC,
		         D1_SERIE SERIE,
		         sum(D1_QUANT) QUANT,
		         D1_FORNECE CLIFOR,
		         D1_LOJA LOJA,
		         D1_UM UM,
		         D1_DTDIGIT DTDIGIT,
		         F1_NODIA NODIA,
		         F1_SERIE2 SERIE2,
		         %exp:cYSerieF1% SERIE3,
		         D1_LOCAL XLOCAL,
		         D1_ITEM XITEM

		FROM %table:SD1% SD1,%table:SF4% SF4,%table:SB1% SB1,%table:SF1% SF1

		WHERE SD1.D1_FILIAL  =  %xFilial:SD1%	AND
              SD1.D1_COD     >= %Exp:mv_par01% 	AND
              SD1.D1_COD     <= %Exp:mv_par02%  AND
              %Exp:cWhereD1%
		      SD1.D1_DTDIGIT >= %Exp:mv_par05% 	AND
			  SD1.D1_DTDIGIT <= %Exp:mv_par06%	AND
			  SD1.D1_ORIGLAN <> 'LF'           	AND
			  SD1.D1_REMITO  = ' '             	AND
			  SD1.D1_TIPO_NF >= ' '            	AND
			  SD1.%NotDel%						AND
			  SF4.F4_FILIAL  =  %xFilial:SF4%	AND
			  SF4.F4_CODIGO  = SD1.D1_TES 		AND
			  SF4.F4_ESTOQUE = 'S' 				AND
			  SF4.%NotDel%                     	AND
			  SB1.B1_FILIAL  =  %xFilial:SB1%	AND
			  SB1.B1_COD     = SD1.D1_COD 		AND
              SB1.B1_TIPO    >= %Exp:mv_par03% 	AND
              SB1.B1_TIPO    <= %Exp:mv_par04% 	AND
              SB1.B1_GRUPO   >= %Exp:mv_par08% 	AND
              SB1.B1_GRUPO   <= %Exp:mv_par09% 	AND
              SB1.%NotDel%     						AND
				SF1.F1_FILIAL = %xFilial:SF1%  AND
				SF1.F1_DOC = SD1.D1_DOC   AND
				SF1.F1_SERIE = SD1.D1_SERIE AND
				SF1.F1_FORNECE = SD1.D1_FORNECE  AND
				SF1.F1_LOJA = SD1.D1_LOJA      AND
				SF1.F1_TIPO = SD1.D1_TIPO      AND
              SF1.%NotDel%

    		  GROUP BY %exp:cGroupF1%
	    UNION
   		SELECT 	F2_FILIAL FILIAL,
   				B1_TIPO TIPO,
		        D2_COD PRODUTO,
		        D2_SEQCALC SEQCALC,
		        %Exp:cD2EMISSAO%
		        D2_TES TES,
		        D2_CF CF,
		        D2_ESPECIE TIPODOC,
		        D2_DOC NUMDOC,
		        D2_SERIE SERIE,
		        sum(D2_QUANT) QUANT,
		        D2_CLIENTE CLIFOR,
		        D2_LOJA LOJA,
		        D2_UM UM,
		        D2_DTDIGIT DTDIGIT,
		        F2_NODIA NODIA,
		        F2_SERIE2 SERIE2,
		        %exp:cYSerieF2% SERIE3,
		        D2_LOCAL XLOCAL,
		        D2_ITEM XITEM

		FROM %table:SD2% SD2,%table:SF4% SF4,%table:SB1% SB1,%table:SF2% SF2

		WHERE SD2.D2_FILIAL  =  %xFilial:SD2%	AND
              SD2.D2_COD     >= %Exp:mv_par01% 	AND
              SD2.D2_COD     <= %Exp:mv_par02% AND
		      %Exp:cWhereD2%
			  SD2.D2_ORIGLAN <> 'LF'           	AND
			  %Exp:cWhereRE%                   	AND
			  SD2.%NotDel%						AND
			  SF4.F4_FILIAL  =  %xFilial:SF4%	AND
			  SF4.F4_CODIGO  = SD2.D2_TES 		AND
			  SF4.F4_ESTOQUE = 'S' 				AND
			  SF4.%NotDel%                     	AND
			  SB1.B1_FILIAL  =  %xFilial:SB1%	AND
			  SB1.B1_COD     = SD2.D2_COD 		AND
              SB1.B1_TIPO    >= %Exp:mv_par03% 	AND
              SB1.B1_TIPO    <= %Exp:mv_par04% 	AND
              SB1.B1_GRUPO   >= %Exp:mv_par08% 	AND
              SB1.B1_GRUPO   <= %Exp:mv_par09% 	AND
              SB1.%NotDel%                      AND
				SF2.F2_FILIAL = %xFilial:SF2%  AND
				SF2.F2_DOC = SD2.D2_DOC   AND
				SF2.F2_SERIE = SD2.D2_SERIE AND
				SF2.F2_CLIENTE = SD2.D2_CLIENTE  AND
				SF2.F2_LOJA = SD2.D2_LOJA      AND
				SF2.F2_TIPO = SD2.D2_TIPO      AND
              SF2.%NotDel%

              GROUP BY %exp:cGroupF2%
		UNION
   		SELECT 	D3_FILIAL FILIAL,
   				B1_TIPO TIPO,
		        D3_COD PRODUTO,
		        D3_SEQCALC SEQCALC,
		        D3_EMISSAO EMISSAO,
		        D3_TM TES,
		        D3_CF CF,
		        D3_CF TIPODOC,
		        D3_DOC NUMDOC,
		        ' ' SERIE,
		        sum(D3_QUANT) QUANT,
				' ' CLIFOR,
				' ' LOJA,
				D3_UM UM,
				D3_EMISSAO DTDIGIT,
				D3_NODIA NODIA,
				' ' SERIE3,
				' ' SERIE2,
				D3_LOCAL XLOCAL,
				' ' XITEM

		FROM %table:SD3% SD3,%table:SB1% SB1

		WHERE SD3.D3_FILIAL  =  %xFilial:SD3%	AND
              SD3.D3_COD     >= %Exp:mv_par01% 	AND
              SD3.D3_COD     <= %Exp:mv_par02% AND
		      SD3.D3_EMISSAO >= %Exp:mv_par05% 	AND
			  SD3.D3_EMISSAO <= %Exp:mv_par06%	AND
			  %Exp:cWhereD3%
			  SD3.%NotDel%						AND
			  SB1.B1_FILIAL  =  %xFilial:SB1%	AND
			  SB1.B1_COD     = SD3.D3_COD 		AND
              SB1.B1_TIPO    >= %Exp:mv_par03% 	AND
              SB1.B1_TIPO    <= %Exp:mv_par04% 	AND
              SB1.B1_GRUPO   >= %Exp:mv_par08% 	AND
              SB1.B1_GRUPO   <= %Exp:mv_par09% 	AND
              SB1.%NotDel%

          GROUP BY D3_FILIAL,B1_TIPO,D3_COD,D3_SEQCALC,D3_EMISSAO,D3_TM,D3_CF,D3_CF,D3_DOC,D3_UM,D3_EMISSAO,D3_NODIA,D3_LOCAL
		ORDER BY %Exp:cOrder%

	EndSql

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Metodo EndQuery ( Classe TRSection )                                    ³
	//³                                                                        ³
	//³Prepara o relatorio para executar o Embedded SQL.                       ³
	//³                                                                        ³
	//³ExpA1 : Array com os parametros do tipo Range                           ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

	aEval(aCampos, {|e| If(e[2]!= "C", TCSetField("TRC", e[1], e[2],e[3],e[4]),Nil)})
	MTR264FillTrb(aCampos)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicio da impressao do fluxo do relatório                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		CFilialProd := ""
	cEstabProd	:= ""
	aLocalFiR	:= {}
	aLocalFiR	:= {}
dbSelectArea("TRB")
oReport:SetMeter(TRB->(LastRec()))
dbGoTop()

While !oReport:Cancel() .And. !("TRB")->(Eof())


		nEntradas := 0
		nSalidas  := 0
		lImpCabec := .T.

		cProduto  := TRB->PRODUTO
		zLocal    := TRB->XLOCAL
		CprodAux := ""

		If TRB->FILIAL <> cFilialProd
			cFilialProd := TRB->FILIAL
			aLocalFiR := M264LocFil(zLocal,TRB->FILIAL,TRB->PRODUTO)
	    EndIF

		If TRB->XIDESTAB <> cEstabProd
			cEstabProd := TRB->XIDESTAB
	    EndIF

	    SB1->(DBSETORDER(1))
		if !SB1->(MsSeek(xFilial("SB1")+TRB->PRODUTO))
		   MSGSTOP("Error NO encontró  en la tabla SB1 el producto "+TRB->PRODUTO+", el informe puede tener inconsistencias!!")
		endif
		If oReport:Cancel()
			Exit
		EndIf

		oSection3:Cell("nSALDQtd"):SetValue(0)
		oSection3:Cell("nENTQtd") :SetValue(0)
		oSection3:Cell("nSAIQtd") :SetValue(0)

		if TRB->NUMDOC == "*SINMOV*"

			aSalAtu   := {0,0,0,0,0,0,0}
			nQtini :=0
			nSalIni:=0

			For nX:=1 To Len(aLocalFiR)
				IF aLocalFiR[nX,1]
				   aSalatu1:=M264fCalcEst(SB1->B1_COD,aLocalFiR[nX,2],MV_PAR05,TRB->FILIAL)
				   nQtIni +=aSalAtu1[1]           // QUANTIDADE

				ENDIF
			Next

			if nQtini == 0
				TRB->(dbSkip())
				loop
			endif

			aSalAtu[1]         +=nQtIni


			oSection1:Init()
			oSection1:Cell("CODIGO"):SetValue(SB1->B1_COD)
			oSection1:Cell("TIPO")  :SetValue(SB1->B1_TIPOEX)
			oSection1:Cell("DESC")  :SetValue(SB1->B1_DESC)
			oSection1:Cell("CODUN") :SetValue(fTabla6(SB1->B1_UM))
			aConSX5 := FWGetSX5( "XZ",TRB->XTPESTAB,"ES" )
			cDessx5 := aConSX5[1,4]
			oSection1:Cell("ESTABL") :SetValue(TRB->XIDESTAB+' - '+cDessx5 )

			oSection1:PrintLine()
			oSection1:Finish()

			oSection3:Init()
			oSection3:Cell("dDtMov")  :SetValue(MV_PAR05)
			oSection3:Cell("Tp Oper") :SetValue('16')
			oSection3:Cell("nENTQtd") :Show()
			oSection3:Cell("nENTQtd") :SetValue(nQtini)
			oSection3:Cell("nSALDQtd"):SetValue(nQtini)
			oSection3:Cell("cCF")     :Hide()
			oSection3:Cell("SERIE")   :Hide()
			oSection3:Cell("cDoc")    :Hide()
	   		oSection3:Cell("TIPO")    :Hide()
			oSection3:PrintLine()
			oReport:PrintText("NO HUBO MOVIMIENTO PARA ESTE PRODUCTO")
			oSection3:Finish()
			oReport:ThinLine()

			TRB->(dbSkip())
			loop

		endif

		CprodAux := ""

		While  TRB->(!Eof())  .And. TRB->PRODUTO == cProduto .and. TRB->XIDESTAB == cEstabProd

				If oReport:Cancel()
					Exit
				EndIf
				zLocal := TRB->XLOCAL

				oReport:IncMeter()

				If CprodAux <> TRB->PRODUTO
					oSection1:Init()
					oSection1:Cell("CODIGO"):SetValue(SB1->B1_COD)
					oSection1:Cell("TIPO")  :SetValue(SB1->B1_TIPOEX)
					oSection1:Cell("DESC")  :SetValue(SB1->B1_DESC)

					oSection1:Cell("CODUN") :SetValue(fTabla6(SB1->B1_UM))
					aConSX5 := FWGetSX5( "XZ",TRB->XTPESTAB,"ES" )
					cDessx5 := aConSX5[1,4]
					oSection1:Cell("ESTABL") :SetValue(TRB->XIDESTAB+' - '+cDessx5 )
					oSection1:PrintLine()
					CprodAux:= TRB->PRODUTO


					nQtini :=0
					nSalIni:=0

					For nX:=1 To Len(aLocalFiR)
						IF aLocalFiR[nX,1]
						   aSalatu1:=M264fCalcEst(SB1->B1_COD,aLocalFiR[nX,2],MV_PAR05,TRB->FILIAL)
						   nQtIni +=aSalAtu1[1]           // QUANTIDADE

						ENDIF
					Next

					oSection3:Init()



			           	cTP:=""
						cTP:="16"
						oSection3:Cell("dDtMov")  :SetValue(MV_PAR05)
						oSection3:Cell("Tp Oper") :SetValue(cTP)
						oSection3:Cell("nENTQtd") :Show()
						oSection3:Cell("nENTQtd") :SetValue(nQtini)
						oSection3:Cell("nSALDQtd"):SetValue(nQtini)


						oSection3:Cell("cCF")     :Hide()
						oSection3:Cell("SERIE")   :Hide()
						oSection3:Cell("cDoc")    :Hide()
				   		oSection3:Cell("TIPO")    :Hide()
				   		oSection3:PrintLine()


	            EndIf

				dbSelectArea("TRB")

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica la fecha para productos sin movimientos        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cTIPODOC := TRB->TIPODOC

				If ALLTRIM(TIPODOC) $ "FT/NF/"
				    	cTIPODOC := "FAC"
				EndIf

					oSection3:Cell("dDtMov"):Show()
					oSection3:Cell("dDtMov"):SetValue(EMISSAO)

					oSection3:Cell("cCF")   :Show()
					oSection3:Cell("cCF")   :SetValue(cTIPODOC)


					// ----------------------------------------------------------------------------------- //
					// Adicionado por SISTHEL para impresion de la serie 3 ( campo customizado )		   //
					// ----------------------------------------------------------------------------------- //
					_cSerieNf := SERIE

					If TES > "500" // Documentos de Salida
						SFP->(dbSetOrder(5)) //FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE
						If SFP->( MsSeek( cFilSFP+cFilAnt+_cSerieNf+"1" ) )
							If SFP->&(cPosCpo + '("FP_YSERIE")') > 0 .And. !Empty(SFP->FP_YSERIE)
								_cSerieNf := Alltrim(SFP->FP_YSERIE)
							EndIf
						Else
							If SFP->( MsSeek( cFilSFP+cFilAnt+_cSerieNf+"6" ) )
								If SFP->&(cPosCpo + '("FP_YSERIE")') > 0 .And. !Empty(SFP->FP_YSERIE)
									_cSerieNf := Alltrim(SFP->FP_YSERIE)
								EndIf
							EndIf
						EndIf
					Else
						If !Empty(SERIE3)
							_cSerieNf := Alltrim(SERIE3)
						EndIf
					EndIf

					If !Empty(SERIE2)
						_cSerieNf := Alltrim(SERIE2)
					EndIf

					If Alltrim(TRB->NUMDOC) $ "INVENT" .AND. Alltrim(TRB->CF) $ "DE0|RE0"
						_cSerieNf :=  Alltrim(cSerKINV)
					Elseif Alltrim(TRB->CF) $ "DE0|DE1|DE4|DE6|ER0|PR0|RE0|RE1|RE4|RE6"
						_cSerieNf :=  Alltrim(cSerKTM)
					EndIf
					oSection3:Cell("SERIE") :Show()
					oSection3:Cell("SERIE") :SetValue(_cSerieNf)
					oSection3:Cell("cDoc")  :Show()
					oSection3:Cell("cDoc")  :SetValue(Right(AllTrim(NUMDOC), nTamNDoc))

					If TES <= "500"
						oSection3:Cell("nENTQtd"):Show()
						oSection3:Cell("nENTQtd"):SetValue(QUANT)


						aSalAtu[1]:= aSalAtu[1]+ QUANT

						oSection3:Cell("nSAIQtd"):SetValue(0)
						oSection3:Cell("nSAIQtd"):Hide()
					Else
						oSection3:Cell("nSAIQtd"):Show()
						oSection3:Cell("nSAIQtd"):SetValue(QUANT)

						aSalAtu[1]:= aSalAtu[1] - QUANT

						oSection3:Cell("nENTQtd"):SetValue(0)
						oSection3:Cell("nENTQtd"):Hide()
					EndIf

			        If aSalAtu[1] != 0
						oSection3:Cell("nSALDQtd"):Show()
						oSection3:Cell("nSALDQtd"):SetValue(aSalAtu[1])
		        	Else

						oSection3:Cell("nSALDQtd"):Show()
						oSection3:Cell("nSALDQtd"):SetValue(aSalAtu[1])
		        	EndIf

					cMovto := ""

					If TRB->TES > "500" .And. ALLTRIM(TRB->TIPODOC) $ "REM|NF|FAC|RFN"
						cMovto := OemToAnsi(STR0030) //"CLI"
					ElseIf TRB->TES > "500" .And. ALLTRIM(TRB->TIPODOC) $ "RE0|DE0|RE8|DE8"
						cMovto := OemToAnsi(STR0032) //"CC"
					ElseIf TRB->TES <= "500" .And. ALLTRIM(TRB->TIPODOC) $ "RE6|DE6"
						cMovto := OemToAnsi(STR0034) //"MAN"
					ElseIf TRB->TES <= "500" .And. ALLTRIM(TRB->TIPODOC) $ "RE8|DE8"
						cMovto := OemToAnsi(STR0032) //"CC"
					ElseIf TRB->TES <= "500" .And. ALLTRIM(TRB->TIPODOC) $ "REM|NF|FAC|RFN"
						cMovto := OemToAnsi(STR0031) //"PROV"
					Else
						cMovto := OemToAnsi(STR0033) //"OP"
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Carrega os Tipos de Operacao ref. a tabela 12 da lei    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					If ALLTRIM(TRB->TIPODOC) $ "RE4|DE4"
						cTP:=""
						cTP:="11"
						oSection3:Cell("Tp Oper"):Show()
						oSection3:Cell("Tp Oper"):SetValue(cTP)
					ElseIf ALLTRIM(TRB->TIPODOC) $ "REM|NF|FAC|RCN|RFN"
						aArea:=Getarea()
						DbSelectArea("SF4")
						SF4->(dbSetOrder(1)) //F4_FILIAL+F4_CODIGO
						If MsSeek(cFilial+TRB->TES)
							oSection3:Cell("Tp Oper"):Show()
							oSection3:Cell("Tp Oper"):SetValue(SF4->F4_TPOP)
						EndIf
						RestArea(aArea)
					Else
						cTP:=""
					    cTP:="99"
					 	oSection3:Cell("Tp Oper"):Show()
					 	oSection3:Cell("Tp Oper"):SetValue(cTP)
					EndIf


		           	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Carrega os Tipos de Operacao ref. a tabela 10 da lei    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		            oSection3:Cell("TIPO"):Show()
		            If ALLTRIM(TRB->TIPODOC) $ "NDI"
		           		oSection3:Cell("TIPO"):SetValue("07")
		           	ElseIf ALLTRIM(TRB->TIPODOC) $ "FAC"
		           		oSection3:Cell("TIPO"):SetValue("01")
		           	ElseIf ALLTRIM(TRB->TIPODOC) $ "RCN/RTS/RTE/RFN/RCD"
		           		oSection3:Cell("TIPO"):SetValue("09")
		            ElseIf ALLTRIM(TRB->TIPODOC) $ "NCC"
		           		oSection3:Cell("TIPO"):SetValue("08")
		           	Else
		           		oSection3:Cell("TIPO"):SetValue("00")
		            EndIf

					nEntradas += Iif(TES <= "500",QUANT,0)
		         	nSalidas  += Iif(TES >  "500",QUANT,0)

					oSection3:PrintLine()

		     	dbSelectArea("TRB")
				dbSkip()
		EndDo
		If (nEntradas + nSalidas) > 0
		   	oSection1:Finish()
			oSection2:Finish()
			oSection3:Finish()
			aSalAtu[1]:= 0
			oReport:ThinLine()
	    ENDIF
EndDo


If MV_PAR11 == 1  // - IMPRESSÃO DO ARQUIVO MAGNETICO
   Processa({|| GerArq(AllTrim(MV_PAR12))},,"Generando archivo...")
EndIf
TRB->(dbCloseArea())

Return



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MTR264NFExp ³ Autor ³Lucas				 ³ Data ³18/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega arquivo TRB com resultado da Query                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR264                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MTR264FillTrb(aCampos)
Local aCodsPrds	:= {}
Local _cAlias	:= getNextAlias()
Local cTiAlm	:= ""
Local cIdSUNA	:= ""
Local cNoProds	:= ""
Local nX		:= 0
Local nMesAnt	:= 0
Local nAnoAnt	:= 0

If Select("TRB") > 0
	TRB->(DbCloseArea())
EndIf
DbSelectArea("NNR")
NNR->( dbSetOrder(1) )

MATR264CT(aCampos) //genera la tabla temporal y sus indices, funcion ubicada en PERXTMP

DbSelectArea("TRC")
TRC->(DbGoTop())
While !TRC->(Eof())
		if TRC->QUANT==0
			DbSelectArea("TRC")
			DbSkip()
			Loop
		endif
		cTiAlm:="";	cIdSUNA:=""
		IF NNR->( MsSeek( xFilial("NNR")+TRC->XLOCAL ) )

		   cTiAlm:=NNR->NNR_TIPOES
		   cIdSUNA:=NNR->NNR_IDSUNA
		endif
		DbSelectArea("TRB")
		Reclock("TRB",.T.)
			PRODUTO		:=	TRC->PRODUTO
		 	EMISSAO 	:=	TRC->EMISSAO
			SEQCALC 	:=	TRC->SEQCALC
			TES 		:=	TRC->TES
			CF 			:=	TRC->CF
			TIPODOC 	:=	If(AllTrim(TRC->TIPODOC) $ "FT|NF","FAC",TRC->TIPODOC)
			NUMDOC 		:=	TRC->NUMDOC
			SERIE 		:=	TRC->SERIE
			QUANT 		:=	TRC->QUANT
			CLIFOR	 	:=	TRC->CLIFOR
			LOJA		:=	TRC->LOJA
			UM			:=	TRC->UM
			DTDIGIT		:=	TRC->DTDIGIT
			NODIA		:=	M264NodiaOrig(TRC->SERIE,Right(AllTrim(TRC->NUMDOC),8),TRC->TIPODOC,TRC->CLIFOR,TRC->LOJA,TRC->NUMDOC,TRC->FILIAL)	////Rutina ubicada en PERXTMP
			SERIE3 		:=	TRC->SERIE3
			SERIE2 		:=	TRC->SERIE2
			FILIAL 		:=	TRC->FILIAL
			XLOCAL 		:=	TRC->XLOCAL
			XTPESTAB	:=	cTiAlm
			XIDESTAB	:=	cIdSUNA
			XITEM 		:=	TRC->XITEM
		MsUnLock()

		if Ascan( aCodsPrds, TRC->PRODUTO )==0
			Aadd( aCodsPrds, TRC->PRODUTO )
		endif

		DbSelectArea("TRC")
		DbSkip()
EndDo

	// --------------------------------- //
	// adiciona productos sin movimiento //
	// --------------------------------- //
cNoProds := "'"
for nX:=1 to len(aCodsPrds)
	cNoProds += aCodsPrds[nX]+"','"
next nX
cNoProds := substr(cNoProds,1,len(cNoProds)-2)

dDataAnt := mv_par06
nMesAnt := month(mv_par06)-1
nAnoAnt := year(mv_par06)
if nMesAnt<1
		nMesAnt := 12
		nAnoAnt := year(mv_par06)-1
endif
nMesAnt := strzero(nMesAnt,2)
nAnoAnt := strzero(nAnoAnt,4)

cSql := "SELECT B9_FILIAL,B9_COD,B9_LOCAL,B9_QINI,B9_DATA"
cSql += "  FROM " + RetSqlName("SB9")+ " SB9, "+ RetSqlName("SB1") +" SB1 "

cSql += " WHERE B9_COD= B1_COD AND  B9_FILIAL='"+XFILIAL("SB9")+"' AND B9_COD >= '"+ mv_par01 +"' AND B9_COD <= '" +mv_par02 +"' AND LEFT(B9_DATA,6)='"+nAnoAnt+nMesAnt+"' AND "
cSql += "  B1_FILIAL='"+XFILIAL("SB1")+"' AND B1_TIPO  >= '"+ mv_par03 +"' AND B1_TIPO <= '" +mv_par04 +"'  AND B1_GRUPO  >= '"+ mv_par08 +"' AND B1_GRUPO <= '" +mv_par09 +"' "
cSql += " AND SB1.D_E_L_E_T_='' AND SB9.D_E_L_E_T_='' AND B9_QINI<>0 "
If !Empty(cNoProds)
	cSql += "   AND B1_COD NOT IN ("+cNoProds+")"
EndIf
cSql += "   AND LEFT(B9_DATA,6)='"+nAnoAnt+nMesAnt+"'"

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),_cAlias,.T.,.T.)

if (_cAlias)->( !eof() )

	While (_cAlias)->( !Eof() )

			//if Ascan( aCodsPrds, (_cAlias)->B9_COD ) == 0

				cTiAlm:="";	cIdSUNA:=""
				IF NNR->( MsSeek( xFilial("NNR")+TRC->XLOCAL ) )
				   cTiAlm:=NNR->NNR_TIPOES
				   cIdSUNA:=NNR->NNR_IDSUNA
				ENDIF


				DbSelectArea("TRB")
				TRB->(Reclock("TRB",.T.))
				Replace 	TRB->PRODUTO 	With	(_cAlias)->B9_COD
				Replace 	TRB->EMISSAO 	With	dDataAnt
				Replace 	TRB->NUMDOC 	With	"*SINMOV*"
				Replace 	TRB->DTDIGIT	With	dDataAnt
				Replace 	TRB->FILIAL 	With	(_cAlias)->B9_FILIAL
				Replace 	TRB->XLOCAL 	With	(_cAlias)->B9_LOCAL
				Replace 	TRB->XTPESTAB	With	NNR->NNR_TIPOES
				Replace 	TRB->XIDESTAB	With	NNR->NNR_IDSUNA
				TRB->(MsUnLock())
			//Endif
			(_cAlias)->( dbSkip() )
	Enddo
EndIf
(_cAlias)->( dbCloseArea() )
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Cabec264   ³ Autor ³ Bruno Schmidt       ³ Data ³ 15/06/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDesc.     ³Cria o cabecalio da rotia		                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATR262                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cabec264( oReport )

Local aCabec	:= {}
Local cChar		:= chr(160)  // caracter dummy para alinhamento do cabeçalho
Local cPERIODO	:= ""
Local aEmpres	:={}

cPERIODO := dtoC(mv_par05)+" "+STR0079+" "+DtoC(mv_par06)

aEmpres:= FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC","M0_FILIAL","M0_NOMECOM" } )

aCabec := {	"__LOGOEMP__" , cChar + "         " ;
		      + "         " + cChar + RptFolha+ TRANSFORM(oReport:Page(),'999999');
	          , cChar + "         " ;
	          + "         " + cChar ;
	          , "SIGA /" + 'MATR264' + " /v." + cVersao ;
	          + "         " + cChar + UPPER(AllTrim(titulo)) ;
	          + "         " + cChar;
	          , RptHora + " " + time() + "         " + cChar + SubStr(STR0001,95,50) + "         " + cChar + RptEmiss + " " + Dtoc(dDataBase),;
	          + "  ",;
	          + STR0087 + cPERIODO,; //"PERIODO :"
	          + STR0088 +aEmpres[1,2],; //" RUC.: "
	          + (STR0089 +Trim(aEmpres[3,2])),; //MO_NOMECOM
	          + "  "}
Return aCabec

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ GerArq   ³ Autor ³                     ³ Data ³ 04.01.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Gera o arquivo magnético do Registro de Inventário         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cDir - Diretorio de criacao do arquivo.                    ³±±
±±³            ³ cArq - Nome do arquivo com extensao do arquivo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal Peru - Registro de Inventário - Arquivo Magnetico   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GerArq(cDir)

Local cLin			:= ""
Local cSep			:= "|"
Local dEmiss		:= CTOD("  /  /  ")
Local nCont			:= 0
Local cArq			:= ""
Local dDtDigit		:= CTOD("  /  /  ")
Local cExisten		:= ""
Local cFilialProd	:= ""
Local cEstmento		:= ""
Local cNodiaAnt		:= "XX"
Local cProd			:= ""
Local aConSX5 		:= {}
Local cCodBar		:= ''
Local cTipEx		:= ''
Local cPrdSAT		:= ''
Local cUM			:= ''
Local cDesc			:= ''
Local cFilSB1		:= xFilial("SB1")
Local cFilSFP		:= xFilial("SFP")
Local cFilSA2 		:= xFilial("SA2")
Local cFilSAH		:= xFilial("SAH")
Local cCodProd		:= ""
Local cCatalogo		:= ""
Local lTipoRem		:= .F.

private nCorr		:= 1
Private aSelFil		:= {}
Private nHdl		:= 0
private nInd		:= 0
Private nPLEPeru	:= SuperGetMv("MV_PLEPERU", .F., 5150)	// Número de versión del PLE, v5.1.5.0 vigente hasta Jun/2020

aSelFil := {cFilAnt}

FOR nCont:=LEN(ALLTRIM(cDir)) TO 1 STEP -1
	IF SUBSTR(cDir,nCont,1)=='\'
			cDir:=Substr(cDir,1,nCont)
			EXIT
	ENDIF
NEXT

// Nome do arquivo TXT a ser impresso
cArq += "LE"                            // Fixo  'LE'
cArq +=  AllTrim(SM0->M0_CGC)           // Ruc
cArq +=  AllTrim(Str(Year(MV_PAR06)))   // Ano
cArq +=  AllTrim(Strzero(Month(MV_PAR06),2))  // Mes
cArq +=  "00"                            // Fixo '00'
cArq += "120100"                         // Fixo '120100'
cArq += "00"                             // Fixo '00'
cArq += "1"
cArq += "1"
cArq += "1"
cArq += "1"
cArq += ".TXT" // Extensao

nHdl := fCreate(cDir+UPPER(cArq),Nil,Nil,.F.)
If nHdl <= 0
	ApMsgStop(STR0091,"") //"Ha ocurrido un error al crear el archivo. Intente nuevamente."

Else
	dbSelectArea("TRB")
	TRB->(dbGoTop())
	Do While TRB->(!EOF())

		If Round(TRB->QUANT,2) == 0
			TRB->( dbSkip() )
			Loop
		Endif

		if alltrim(TRB->NUMDOC)=="*SINMOV*"
			TRB->( dbSkip() )
			Loop
		endif

		dEmiss		:= TRB->EMISSAO
		dDtDigit	:= TRB->DTDIGIT
		cLin		:= ""	// Limpa conteúdo CLin

		If ((cEstmento <> TRB->XIDESTAB).Or.(AllTrim(TRB->PRODUTO) <> AllTrim(cProd)))

			fSaldoIni(TRB->PRODUTO,TRB->XIDESTAB)
			cFilialProd := TRB->XIDESTAB
			cProd := TRB->PRODUTO
			cEstmento := TRB->XIDESTAB
		EndIF

		// - 01 Periodo
		cLin += SubStr(DTOS(dEmiss),1,6)+"00"
		cLin += cSep

		// - 02 Código Único de la Operación (CUO)
		if empty(TRB->NODIA)
			cLin += "CUO-VACIO"
		else
			cLin += AllTrim(TRB->NODIA)
		endif
		cLin += cSeP

		// - 03 correlativo
		If !Empty(AllTrim(TRB->XITEM))
			cLin += "M"+StrZero(val(TRB->XITEM),5)
		Else
			If !Empty(AllTrim(TRB->NODIA)) .and. cNodiaAnt <> AllTrim(TRB->NODIA)
				cNodiaAnt := AllTrim(TRB->NODIA)
				nSecNodia := 0
				cLin += "M"+StrZero(++nSecNodia,5)
			ElseIf !Empty (AllTrim(TRB->NODIA)) .and. cNodiaAnt == AllTrim(TRB->NODIA)
				cLin += "M"+StrZero(++nSecNodia,5)
			Else
				If !Empty(cNodiaAnt)
					cNodiaAnt := ""
					nSecNodia := 0
					cLin += "M"+StrZero(++nSecNodia,5)
				Else
					cLin += "M"+StrZero(++nSecNodia,5)
				Endif
			Endif
		Endif

		cLin += cSeP

		// - 04 Estabelecimento
		cLin += AllTrim(cEstmento)
		cLin += cSep

		// - 05 Código del catálogo utilizado tabela 13 -  USAR 3(EAN) OU 9(OUTROS)
		cCodProd	:= Trim(TRB->PRODUTO)
		cCodBar		:= ''
		cTipEx		:= ''
		cPrdSAT		:= ''
		cUM			:= ''
		cDesc		:= ''

		SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
		If SB1->(MsSeek(cFilSB1+TRB->PRODUTO))
			cCodBar := StrTran(Trim(SB1->B1_CODBAR),"|","")
			cCodBar	:= StrTran(cCodBar,"/","")
			cTipEx := SB1->B1_TIPOEX
			cUM := SB1->B1_UM
			cDesc := SB1->B1_DESC
			cPrdSAT := Trim(SB1->B1_PRODSAT)
		EndIf

		If lUsaCodBar .and. cPrdSAT <> "" .And. cPrdSAT == cCodProd
			cCatalogo := "1"		// UNSPSC
		ElseIf lUsaCodBar .and. cCodBar <> "" .And. cCodBar == cCodProd
			cCatalogo := "3"		// GTIN
		Else
			cCatalogo := "9"		// otro
		Endif
		cLin += cCatalogo
		cLin += cSep

		// - 06 Tipo de existencia  - tabela 5, Creado en el UPDEST43
		cLin += ALLTRIM(cTipEx)
		cLin += cSeP

		// - 07 Código propio de la existencia correspondiente al catálogo señalado en el campo 5.
		If cCatalogo == "1"
			cLin += cPrdSAT
		ElseIf cCatalogo == "3"
			cLin += cCodBar
		Else
			cLin += cCodProd
		EndIf
		cLin += cSep

		// - [08] Código del catálogo utilizado. Establecido en anexo_2, vigente a partir de 07/2020, PLE > v5.1.5.0; en algunos libros no se admite este campo. Nuevamente publicado con algunos cambios vigente 01/01/2021, PLE > v5.1.8.1
		If lUsaCodBar .and. cPrdSAT <> ""
			cCatalogo := "1"		// UNSPSC
		ElseIf lUsaCodBar .and. cCodBar <> ""
			cCatalogo := "3"		// GTIN
		Else
			cCatalogo := ""			// otro (9 no es válido)
		Endif

		If nPLEPeru > 5181
			cLin += cCatalogo
			cLin += cSep
		Endif

		//- 08/09 Código de la existencia, de acuerdo al Catálogo de Bienes, Servicios y Obras (*) - UPDEST43
		IF cCatalogo == "1"
			cLin += Trim(cPrdSAT) + IIf( nPLEPeru > 5150, "00000000", "" )
		ElseIf cCatalogo == "3"
			cLin += cCodBar
		Else
			cLin += ""
		Endif
		cLin += cSep

		// - 09 Fecha de emisión del documento de traslado, comprobante de pago, documento interno o similar
		cLin += SubStr(DTOC(dEmiss),1,6)+SubStr(DTOS(dEmiss),1,4)
		cLin += cSeP

		// - 10 Tipo del documento de traslado, comprobante de pago, documento interno o similar TABELA 10
		lTipoRem := .F.

		If ALLTRIM(TRB->TIPODOC) $ "NDI/NCC"
			cLin +="07"
		ElseIf ALLTRIM(TRB->TIPODOC) $ "FAC"
			// ----------------------------------------------------------------------------------- //
			// Adicionado por SISTHEL para impresion de la serie 3 ( campo customizado )		   //
			// Adicionada a serie 12 para series de etiquetadoras								   //
			// ----------------------------------------------------------------------------------- //
			If TRB->TES > "500" // Documentos de Salida
				SFP->( dbSetOrder(5) ) //FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE
				If SFP->( MsSeek( cFilSFP+cFilAnt+TRB->SERIE+"1" ) )
					If SFP->&(cPosCpo + '("FP_YSERIE")') > 0
						If Len(Alltrim((SFP->FP_YSERIE))) <= 4
							cLin +="01"
						Else
							cLin +="12"
						EndIf
					EndIf
				Else
					If SFP->( MsSeek( xFilial("SFP")+cFilAnt+TRB->SERIE+"6" ) )
						If SFP->&(cPosCpo + '("FP_YSERIE")') > 0
							If Len(Alltrim((SFP->FP_YSERIE))) <= 4
								cLin +="01"
							Else
								cLin +="12"
							EndIf
						EndIf
					Else
						cLin +="01"
					EndIf
				EndIf
			Else
				if alltrim(Posicione("SA2",1,cFilSA2+TRB->CLIFOR+TRB->LOJA,"A2_EST"))=="EX"
					cLin +="91"
				else
					cLin +="01"
				endif
			EndIf
		ElseIf ALLTRIM(TRB->TIPODOC) $ "RCN/RTS/RTE/RFN/RCD"
			cLin +="09"
        	lTipoRem := .T.
		ElseIf AllTrim(TRB->TIPODOC) $ "NDC"
			cLin +="08"
		Else
			cLin +="00"
		EndIf
		cLin += cSeP

		// - 11 Número de serie del documento de traslado, comprobante de pago, documento interno o similar
		// ----------------------------------------------------------------------------------- //
		// Adicionado por SISTHEL para impresion de la serie 3 ( campo customizado )		   //
		// ----------------------------------------------------------------------------------- //
		_cSerieNf := ""
		If TRB->TES > "500" // Documentos de Salida
			_cSerieNf := M264getSerie2("1/3/4/5/6/7") ////Rutina ubicada en PERXTMP
		Else
			_cSerieNf := M264getSerie2("2") //Rutina ubicada en PERXTMP
		EndIf

		If Alltrim(TRB->NUMDOC) $ "INVENT" .AND. Alltrim(TRB->CF) $ "DE0|RE0"
			_cSerieNf :=  Alltrim(cSerKINV)
		Elseif Alltrim(TRB->CF) $ "DE0|DE1|DE4|DE6|ER0|PR0|RE0|RE1|RE4|RE6"
			_cSerieNf :=  Alltrim(cSerKTM)
		EndIf

		If Empty(_cSerieNf)
			If lSerie2 .And. !Empty(AllTrim(TRB->SERIE2))
				_cSerieNf := AllTrim(TRB->SERIE2)
			Elseif !Empty(AllTrim(TRB->SERIE))
				_cSerieNf := AllTrim(TRB->SERIE)
			Else
				_cSerieNf := "0"
			EndIf
		Endif

		if alltrim(Posicione("SA2",1,cFilSA2+TRB->CLIFOR+TRB->LOJA,"A2_EST"))=="EX"
			cLin += "0000"
		else
			If Len(Alltrim(_cSerieNf))==3
				cLin += "0"+_cSerieNf
			Else
				cLin += _cSerieNf
			EndIf
		endif
		cLin += cSeP

		// - 12 Número del documento de traslado, comprobante de pago, documento interno o similar
		If !Empty (AllTrim(TRB->NUMDOC))
			If _cSerieNf = "091" .Or. lTipoRem
				// En movimientos de Remisiones, el PLE acepta solo 8 caracteres en número de documento
				cLin += Right(AllTrim(TRB->NUMDOC),8)
			Else
				cLin += Right(AllTrim(TRB->NUMDOC),20)
			EndIf
		Else
			cLin += "0"
		EndIf
		cLin += cSeP

		// - 13 Tipo de operación efectuada - TABELA 12, Creado en el UPDEST43
		If ALLTRIM(TRB->TIPODOC) $ "REM|NF|FAC|RCN|RFN"
			aArea:=Getarea()
			DbSelectArea("SF4")
			SF4->(dbSetOrder(1)) //F4_FILIAL+F4_CODIGO
			If MsSeek(TRB->FILIAL+TRB->TES)
				cLin += ALLTRIM(SF4->F4_TPOP)
			ElseIf MsSeek(xFilial("SF4")+TRB->TES)
				cLin += ALLTRIM(SF4->F4_TPOP)
			else
				cLin +="99"
			EndIf
			RestArea(aArea)
		Else
			cLin +="99"
		EndIf
		cLin += cSeP

		// - 14 Descripción de la existencia P7 - Tabela 05 da Existencia, Creado en el UPDEST43
		if lusaTsx5
			aConSX5 := FWGetSX5( "P7",cTipEx,"ES" )
			cExisten := Trim(aConSX5[1,4])
		else
			cExisten := Trim(Substr(cDesc,1,80))
		EndIf
		cLin += cExisten
		cLin += cSeP

		// - 15 Código Unidade de Medida TABELA 6, Creado en el UPDEST43
		cLin += alltrim(Posicione("SAH",1,cFilSAH+cUM,"AH_CODERP"))
		cLin += cSeP

		// - 16 Entradas de las unidades físicas (la primera tupla corresponde al saldo inicial)
		If ALLTRIM(TRB->TES) < "500"
			cLin += AllTrim(StrTran(Transform(Max(TRB->QUANT,0),"@E 999999999999.99"),",","."))
		Else
			cLin += "0.00"
		Endif
		cLin += cSeP

		// - 17 Salidas de las unidades físicas. Somente negativo ou 0.00
		If ALLTRIM(TRB->TES) >= "500"
			cLin += AllTrim(StrTran(Transform(TRB->QUANT * -1,"@E 999999999999.99"),",","."))
		Else
			cLin += "0.00"
		Endif
		cLin += cSeP

		// - 18 Indica el estado de la operación
		//	'1' cuando la operación corresponde al periodo Registrar
		//	'8' cuando la operación corresponde a un periodo anterior y NO ha sido anotada en dicho periodo
		//	'9' cuando la operación corresponde a un periodo anterior y SI ha sido anotada en dicho periodo."

		If dDtDigit >= MV_PAR05 .And. dDtDigit <= MV_PAR06
			cLin += "1"
		Else
			cLin += "8"
		EndIf
		cLin += cSeP

		cLin += chr(13)+chr(10) // QUEBRA LINHA
		fWrite(nHdl,cLin)
		TRB->(DbSkip())

	EndDo

	fClose(nHdl)
	MsgAlert(STR0080,STR0092) //"Archivo"
EndIf
Return Nil



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ZMATR264  ºAutor  ³Microsiga           ºFecha ³  01/06/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fSaldoIni(cCodProd,cCodeSuc)

Local aAreaSb9	:= GetArea()
Local cLin		:= ""
Local cSep		:= "|"
Local nX		:= 0
Local ny		:= 0
Local cAlias	:= getNextAlias()
Local nQtini	:= 0
Local nSalIni	:= 0
Local aSalatu1	:= {}
Local nCusto	:= 0
Local nCusIni	:= 0
Local cCodBar	:= ''
Local cTipEx	:= ''
Local cPrdSAT	:= ''
Local cUM		:= ''
Local cFilSAH	:= xFilial("SAH")
Local cFilSB1	:= xFilial("SB1")
Local cCatalogo	:= ""
Local cEstmento	:= ""

For nX := 1 To Len(aSelFil)

	cQry := "SELECT NNR_IDSUNA,NNR_TIPOES,NNR_CODIGO  FROM "+RetSqlName("NNR")
	cQry += " WHERE NNR_IDSUNA='" + cCodeSuc +"'" + "   AND D_E_L_E_T_=''"
	cQry += " ORDER BY NNR_IDSUNA,NNR_CODIGO"

	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAlias,.T.,.T.)

	If (cAlias)->(!Eof())

		While (cAlias)->(!Eof())

			aSalAtu   := {0,0,0,0,0,0,0}
			nQtini :=0
			nSalIni:=0

		    aLocalFiR := M264LocFil((cAlias)->NNR_CODIGO,aSelFil[nX],cCodProd) //Rutina ubicada en PERXTMP

			For ny:=1 To Len(aLocalFiR)
				IF aLocalFiR[ny,1]
				   aSalatu1:=M264fCalcEst(cCodProd,aLocalFiR[ny,2],MV_PAR05,aSelFil[nX]) ////Rutina ubicada en PERXTMP

				   nQtIni +=aSalAtu1[1]           // QUANTIDADE
				   nSalIni+=aSalAtu1[2] 		 // VALOR
				ENDIF
			Next

			aSalAtu[1]      +=nQtIni
			aSalAtu[2]		+=nSalIni

			If nQtIni > 0

				cLin:=""
				If (cEstmento <> (cAlias)->NNR_IDSUNA)
					cEstmento := (cAlias)->NNR_IDSUNA
				EndIF

				nCusto := 0
				nCusIni  := nSalIni

				// - 01 Periodo
				cLin += SubStr(DTOS(TRB->EMISSAO),1,6)+"00"
				cLin += cSep

				// - 02 Código Único de la Operación (CUO)
				cLin += AllTrim("SLDINI")
				cLin += cSeP

				// - 03 correlativo
				cLin += "M"+StrZero(++nInd,5)
				cLin += cSeP

				// - 04 Estabelecimento
				cLin += AllTrim(cEstmento)
				cLin += cSep

				// - 05 Código del catálogo utilizado tabela 13 -  USAR 3(EAN) OU 9(OUTROS)
			 	cCodBar		:= ''
			 	cTipEx		:= ''
			 	cPrdSAT		:= ''
			 	cUM			:= ''
			 	cDesc		:= ''

			 	SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
				If SB1->(MsSeek(cFilSB1+TRB->PRODUTO))
					cCodBar := StrTran(Trim(SB1->B1_CODBAR),"|","")
					cCodBar	:= StrTran(cCodBar,"/","")
					cTipEx  := SB1->B1_TIPOEX
					cUM     := SB1->B1_UM
					cDesc   := SB1->B1_DESC
					cPrdSAT := Trim(SB1->B1_PRODSAT)
			    EndIf

				If lUsaCodBar .and. cPrdSAT <> "" .And. cPrdSAT == Trim(cCodProd)
					cCatalogo := "1"		// UNSPSC
				ElseIf lUsaCodBar .and. cCodBar <> "" .And. cCodBar == Trim(cCodProd)
					cCatalogo := "3"		// GTIN
				Else
					cCatalogo := "9"		// otro
				Endif
				cLin += cCatalogo
				cLin += cSep

				// - 06 Tipo de existencia  - tabela 5, Creado en el UPDEST43
				cLin += ALLTRIM(cTipEx)
				cLin += cSeP

				// - 07 Código propio de la existencia correspondiente al catálogo señalado en el campo 5.
				If cCatalogo == "1"
					cLin += cPrdSAT
				ElseIf cCatalogo == "3"
					cLin += cCodBar
				Else
					cLin += Trim(cCodProd)
				EndIf
				cLin += cSep

				//08- Código del catálogo utilizado. Versión PLE > 5.1.5.0, aplica anexo_2 vigente a partir de 07/2020
				If lUsaCodBar .and. cPrdSAT <> ""
					cCatalogo := "1"		// UNSPSC
				ElseIf lUsaCodBar .and. cCodBar <> ""
					cCatalogo := "3"		// GTIN
				Else
					cCatalogo := ""			// otro (9 no es válido)
				Endif

				If nPLEPeru > 5181
					cLin += cCatalogo
					cLin += cSep
				Endif

				//08/09 Código de la existencia, de acuerdo al Catálogo de Bienes, Servicios y Obras (*) - UPDEST43
				If cCatalogo == "1"
					cLin += Trim(cPrdSAT) + IIf( nPLEPeru > 5150, "00000000", "" )
				ElseIf cCatalogo == "3"
					cLin += cCodBar
				Else
					cLin += ""
				Endif
				cLin += cSep

				// - 09 Fecha de emisión del documento de traslado, comprobante de pago, documento interno o similar
				cLin += SubStr(DTOC(TRB->EMISSAO),1,6)+SubStr(DTOS(TRB->EMISSAO),1,4)
				cLin += cSeP

				// - 10 Tipo del documento de traslado, comprobante de pago, documento interno o similar TABELA 10
			  	cLin +="00"
				cLin += cSeP

				// - 11 Número de serie del documento de traslado, comprobante de pago, documento interno o similar
				cLin += "0"
				cLin += cSeP

				// - 12 Número del documento de traslado, comprobante de pago, documento interno o similar
				cLin += "0"
				cLin += cSeP

				// - 13 Tipo de operación efectuada - TABELA 12, Creado en el UPDEST43
				cLin +="16"
				cLin += cSeP

				// - 14 Descripción de la existencia P7 - Tabela 05 da Existencia, Creado en el UPDEST43
				if lusaTsx5
					aConSX5 := FWGetSX5( "P7",cTipEx,"ES" )
					cExisten := Trim(aConSX5[1,4])
				else
					cExisten := Trim(Substr(cDesc,1,80))
				EndIf
				cLin += cExisten
				cLin += cSeP

				// - 15 Código Unidade de Medida TABELA 6, Creado en el UPDEST43
				cLin += alltrim(Posicione("SAH",1,cFilSAH+cUM,"AH_CODERP"))
				cLin += cSeP

				// - 16 Entradas de las unidades físicas (la primera tupla corresponde al saldo inicial)
				cLin += AllTrim(StrTran(Transform(nQtIni,"@E 999999999999.99"),",","."))
				cLin += cSeP

				// - 17 Salidas de las unidades físicas. Somente negativo ou 0.00
				cLin += "0.00"
				cLin += cSeP

				// - 18 Indica el estado de la operación
				//	'1' cuando la operación corresponde al periodo Registrar
				//	'8' cuando la operación corresponde a un periodo anterior y NO ha sido anotada en dicho periodo
				//	'9' cuando la operación corresponde a un periodo anterior y SI ha sido anotada en dicho periodo."
				cLin += "1"
				cLin += cSeP

				cLin += chr(13)+chr(10) // QUEBRA LINHA

				fWrite(nHdl,cLin)

		    EndIf

		    (cAlias)->( dbSkip() )

		Enddo

	EndIf

	(cAlias)->( dbCloseArea() )

Next

RestArea(aAreaSb9)

Return

Static Function fTabla6(cUMedida)

Local cUM := ""
DEFAULT cUMedida := ""

SAH->( dbSetOrder(1) )
SAH->( MsSeek( xFilial("SAH")+cUMedida) )

cUM := Trim(SAH->AH_CODERP)+" - "+Trim(SAH->AH_DESCES)

Return(cUM)
