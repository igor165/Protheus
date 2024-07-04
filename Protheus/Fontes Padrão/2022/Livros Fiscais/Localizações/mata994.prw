#Include "Mata994.ch"
#Include "SigaWin.ch"
#Include "Protheus.ch"
#INCLUDE 'FWLIBVERSION.CH'
#Include "rwmake.ch"

#xtranslate bSETGET(<uVar>) => ;
{ | u | If( PCount() == 0, <uVar>, <uVar> := u ) }

#DEFINE _M2_ATUALIZA  3
#DEFINE _ZONFIS       "FF_ZONFIS"
#DEFINE CRLF Chr(13)+Chr(10)

Static _lMetric	:= Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ FUNCAO   ³ MATA994  ³ AUTOR ³ Leonardo Ruben        ³ DATA ³ 21.09.99   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DESCRICAO³ Tabela generica de retencao e percepcao de impostos          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ Generico - Localizacoes                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS     ³  MOTIVO DA ALTERACAO                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Laura Medina  ³20/01/14³          ³Se agrego el campo FF_CFORA(Argentina)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glez ³06/07/15³PCREQ-4256³Se eliminan las funciones AjustaSX3() ³±±
±±³              ³        ³          ³y AjustaSX2 que hace modificacion a   ³±±
±±³              ³        ³          ³diccionario por motivo de adecuacion  ³±±
±±³              ³        ³          ³a fuentes a nuevas estructuras SX para³±±
±±³              ³        ³          ³Version 12.                           ³±±
±±³              ³        ³          ³                                      ³±±
±±³              ³        ³          ³                                      ³±±
±±³  M.Camargo   ³09.11.15³PCREQ-4262³Merge sistemico v12.1.8               ³±±
±±³ Marco A. Glz ³22/04/16³  TV7996  ³Se agregan las funciones A994ExcFis() ³±±
±±³              ³        ³          ³y A994UpdExc() para la funcionalidad  ³±±
±±³              ³        ³          ³Actualizacion de Excepciones Fiscales ³±±
±±³              ³        ³          ³para version 12.1.7 (COL)             ³±±
±±³Luis Enriquez ³23.12.16³SERINN001 ³-Se realizo merge para hacer cambio en³±±
±±³              ³        ³-768      ³ creacion de tablas temporales CTREE. ³±±
±±³ Laura Medina ³31/01/17³MMI-4731  ³Nuevo registro se asigna el impuesto  ³±±
±±³              ³        ³          ³Ganacias (GAN) y cuando se modifique  ³±±
±±³              ³        ³          ³se validad irectamente contra el regis³±±
±±³              ³        ³          ³tro que ya trae almacenado.           ³±±  
±±³ Alf. Medrano ³01/03/17³MMI-4537  ³se redimensiona pantalla para Inclu/  ³±±
±±³              ³        ³          ³ modif / Visualizar en func A994SUSS_M³±±
±±³              ³        ³          ³se quita Lower para los campos de la  ³±±
±±³              ³        ³          ³tabla temp en func A994SUSS()         ³±±  
±±³              ³21/03/17³          ³merge Main vs 12.1.14                 ³±± 
±±³ Dora Vega    ³11/04/17³MMI-4705  ³Merge de replica del issue MMI-4653.  ³±± 
±±³              ³        ³          ³Se agrega la funcion fBoxTPLIM para   ³±±
±±³              ³        ³          ³agregar opciones en FF_TPLIM.(ARG)    ³±±
±±³ Alf. Medrano ³29/06/17³MMI-6110  ³se asignan STR0149 y STR0150          ³±±
±±³Ivan Gomez    ³29/08/17³DMICNS-20 ³Se agrega funcionalidad  para calculo ³±±
±±³              ³        ³          ³de impuestos importación              ³±±
±±³Roberto Glz   ³10/07/17³DMICNS-108³Se toman del campo X3_CBOXSPA los     ³±±
±±³              ³        ³          ³valores del tipo de calculo para SUSS ³±±
±±³              ³        ³          ³y los considera para validaciones.    ³±±
±±³              ³        ³          ³ajusta posicion de datos en pantalla. ³±±
±±³Dora Vega     ³13/12/17³DMINA-934 ³Se modifican las funciones A994IGV,   ³±±
±±³              ³        ³Replica de³A994Avisigv, A994Aincligv, A994Altigv,³±±
±±³              ³        ³DMINA-553 ³A994deligv para que tome el tamanio de³±±
±±³              ³        ³          ³forma automatica y se cambian textos  ³±±
±±³              ³        ³          ³por etiquetas STRXXXXXX.(PERU)        ³±±
±±³Jose Glex     ³12/01/18³TSSERMI01 ³Se agrega la declaracion del arreglo  ³±±
±±³              ³        ³-241		 ³aMemos, se evita errorloc en vinculo  ³±±
±±³              ³        ³ 		 ³de impuestos de importacion en campo  ³±±
±±³              ³        ³          ³ TEC.                                 ³±±
±±³M.Camargo     ³13/04/18³DMINA-2720³Se modifica asignación de variable    ³±±
±±³              ³        ³          ³VK_F4 utilizando función SetKey       ³±±
±±³Luis Enríquez ³05/12/18³DMINA-1012³Rép. DMINA-253 Se realizan cambios al ³±±
±±³              ³        ³(EUA)     ³fuente para localizacion Fiscal.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mata994()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cCadastro := STR0078
Private oTmpTable := Nil
Private aOrdem := {}
Private lAutomato := isBlind()
Private nIncMtr := 0
Private nExcMtr := 0
Private lAltMtr := .F.

If cPaisLoc =="ARG" .AND. Type("aMemos") == "U" 
	PRIVATE aMemos:={{"YD_TEXTO","YD_VM_TEXT"}} //LRL 25/05/04 
EndIf

SetPrvt("MV_PAR01,_SALIAS,CPERG,AREGS,I,J")
SetPrvt("aYesFields,aYesEscala") // Array com campos para montagem da GetDados

If !(cPaisLoc $ "BRA/EUA") //Si es Brasil o EUA no genera información en SFF cuando este vacia.
	CriaSFF(.T.)
EndIf

mv_par01 := 0
dbSelectArea("SFB")
SFB->(dbSetOrder(1))
dbSelectArea("SFF")

//+--------------------------------------------------------------------+
//¦ Variaveis utilizadas para parametros                               ¦
//¦ mv_par01  // Tabla genérica de ? Ganancias, IVA e Ingresos Brutos  ¦
//+--------------------------------------------------------------------+
If cPaisLoc == "MEX"
   A994Mex()
ElseIf cPaisLoc == "EUA"
	MenuDef()
	DBSelectArea("SFF")
	SFF->(DBSetOrder(1)) //FF_FILIAL + FF_NUM + FF_ITEM
	mBrowse(6,1,22,75,"SFF")
ElseIf cPaisLoc == "ARG"
	A994AjMon("000001")
	A994AjGan("000001")//Retencion de Ganancias Sobre Derechos de Autor
	mv_par01:=A994IMPARG()
	If mv_par01<>0
		If mv_par01		== 1
			A994Ganan()
		ElseIf mv_par01	== 2
			A994IVA()
		ElseIf mv_par01	== 3
			A994IngBrt()
   		ElseIf mv_par01	== 4
			If GetMV("MV_EASY") == "S"
				A994IMPORT()                     
			Else
				A994IMPSYD()
			Endif  
	   	ElseIf mv_par01	== 5
			A994SLI()
		ElseIf mv_par01	== 6
			A994SUSS()
		ElseIf mv_par01	== 7
			A994ISI()
		ElseIf mv_par01	== 8 // Impuestos Internos
			A994MU()
		ElseIf mv_par01	== 9
			A994GENE()
		ElseIf mv_par01	== 10 // Impuesto MSA - Salta
			A994MSA()
		ElseIf MV_PAR01	== 11 //Impuesto Municipal Cordoba - MCO
			A994MCO()
		ElseIf MV_PAR01 == 12
			A994ASimIm()
		EndIf
	EndIf
ElseIf cPaisLoc $ "CHI|PAR"
		A994IMPORT()
ElseIf cPaisLoc == "URU"
		a994IMPUru()
ElseIf cPaisLoc $ "NIC/COL"
	If cPaisLoc == "COL"
		MenuDef()
		dbSelectArea("SFF")
		dbSetOrder(1)
		mBrowse(6,1,22,75,"SFF")
	Else
		AxCadastro("SFF",OemToAnsi(STR0078))  //"Excecoes Fiscais"
	EndIf
ElseIf cPaisLoc == "PTG"
	CCJPTG()
	AxCadastro("SFF",OemToAnsi(STR0099))  //"Plano IVA"
ElseIf cPaisLoc == "VEN"
	CRIACCJ(.T.)
	CriaSFF(.T.)
	A994VEN()
ElseIf cPaisLoc == "BOL"
	If AliasIndic("SFF") .And. SFF->(FieldPos("FF_PARTAR")) > 0
		If SFF->(RecCount()) == 0
			SFFBOL()
		EndIf
		If !SFB->(DbSeek(xFilial("SFB")+"ICE"))
			UPDICEBOL(.T.)
		EndIf
		AxCadastro("SFF",OemToAnsi(STR0111)) // "Conf. Adicionais Impostos"
	Else
		cTitulo 	:= STR0111 // "Conf. Adicionais Impostos"
		cErro		:= STR0112 // "Não foram encontrados os campos para configuração do ICE."
		cSolucao	:= STR0113 // "Execute o compatibilizador UPDBOL para ajuste do dicionario."
		xMagHelpFis(cTitulo,cErro,cSolucao)
	EndIf
ElseIf cPaisLoc == "PER"
	A994IGV()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A994IMPARGºAutor  ³Marcelloa           ºFecha ³ 05/10/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta tela para selecao do imposto.                         º±±
±±º          ³Argentina                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA994                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A994IMPARG()
Local nRet := 0
Local nG := 0, nImp := 0, cImp := ""
Local aImpDesc := {}
Local oCbox,oDlg

aImpDesc:={STR0071,STR0063,STR0072,STR0081,STR0093,STR0160,STR0130,STR0116,STR0161, STR0162,STR0135,STR0131}//"SUSS" - "Otros Conceptos Provinciales" - "MSA-Seg. Salubridad e Higiene de Salta"
nRet:=0
@000,000 TO 180,400 DIALOG oDlg TITLE STR0070 //"¿Tabla generica de ?"
@010,003 MSCOMBOBOX oCbox VAR cImp ITEMS aImpDesc ON CHANGE (nImp:=oCbox:nAt) SIZE 120,50 OF oDlg PIXEL
@008,133 BMPBUTTON TYPE 1 ACTION (nRet:=oCbox:nAt,oDlg:End())
@008,169 BMPBUTTON TYPE 2 ACTION (nRet:=0,oDlg:End())
ACTIVATE DIALOG oDlg CENTERED
Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A994SUSS  ºAutor  ³Marcello            ºFecha ³ 23/09/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para manutencao da tabela de aliquotas para SUSS.    º±±
±±º          ³Argentina                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Mata994                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A994SUSS()
	Local aCpos		:= {}
	Local cAlias	:= GetNextAlias()
	Local cFilSFF	:= xFilial("SFF")
	Local cDescTipo := ""
	Local cDescZona := ""
	
	Private aFixe := {}
	
	aFixe:=	{{OemToAnsi(STR0007),"CONCSUSS","","","",""},;
			 {OemToAnsi(STR0010),"DESCCONC","","","",""},;
			 {OemToAnsi(STR0096),"TIPOOBR","","","",""},;
			 {OemToAnsi(STR0010),"DESCTIPO","","","",""},;
			 {OemToAnsi(STR0097),"ZONAGEO","","","",""},;
			 {OemToAnsi(STR0010),"DESCZONA","","","",""},;
			 {OemToAnsi(STR0098),"Transform(MINIMO,PesqPict('SFF','FF_IMPORTE'))","","","",""},; 		//"Valor Minimo"
			 {OemToAnsi(STR0074),"Transform(ALIQUOTA,PesqPict('SFF','FF_ALIQ'))","","","",""},;
	 		 {OemToAnsi(STR0008),"CFOC","","","",""},;
			 {OemToAnsi(STR0009),"CFOV","","","",""},;
	 		 {OemToAnsi(STR0057),"CFO","","","",""}}
	
	If FieldPos("FF_TPCALC") > 0
		aAdd(aFixe, {OemToAnsi(STR0119),"TIPOCALC","","","",""})
	Endif
	
	aCpos :=	{{"CONCSUSS","C",TamSX3("FF_ITEM")[1],0},;
				 {"DESCCONC","C",40,0},;
				 {"TIPOOBR ","C",01,0},;
				 {"DESCTIPO","C",30,0},;
				 {"ZONAGEO ","C",02,0},;
				 {"DESCZONA","C",50,0},;
				 {"MINIMO  ","N",TamSX3("FF_IMPORTE")[1],TamSX3("FF_IMPORTE")[2]},;
				 {"ALIQUOTA","N",TamSX3("FF_ALIQ")[1],TamSX3("FF_ALIQ")[2]},;
				 {"NUM","C",06,0},;
				 {"CFOC","C",TamSX3("FF_CFO_C")[1],TamSX3("FF_CFO_C")[2]},;
				 {"CFOV","C",TamSX3("FF_CFO_V")[1],TamSX3("FF_CFO_V")[2]},;
	 			 {"CFO","C",TamSX3("FF_CFO")[1],TamSX3("FF_CFO")[2]},;
				 {"NUMREC","N",10,0}}
	
	If FieldPos("FF_TPCALC") > 0
		aAdd(aCpos, {"TIPOCALC","C",01,0})
	Endif
	
	aRotina :=	{{STR0002,"A994SUSS_M",0,2,0,NIL},;		// Visualizar
				{STR0003,"A994SUSS_M",0,3,0,NIL},;		// Incluir
				{STR0004,"A994SUSS_M",0,4,0,NIL},;		// Modificar
				{STR0005,"A994SUSS_M",0,6,0,NIL}}		// Borrar
	cCadastro := STR0160 //"SUSS"
	
	oTmpTable := FWTemporaryTable():New(cAlias) 
	oTmpTable:SetFields( aCpos ) 
	
	aOrdem	:=	{"CONCSUSS", "TIPOOBR", "ZONAGEO"}
	oTmpTable:AddIndex("T1ORD1", aOrdem) 
	oTmpTable:Create()
	
	dbSelectArea("SFF")
	SFF->(dbSetOrder(9)) //FF_FILIAL + FF_IMPOSTO + FF_GRUPO
	SFF->(DbSeek(cFilSFF + "SUS"))
	While SFF->FF_FILIAL == cFilSFF .And. SFF->FF_IMPOSTO == "SUS"
		cDescZona := Substr(SFF->FF_GRUPO,2,2)
		SX5->(DbSeek(xFilial("SX5")+"ZG"+cDescZona))
		cDescZona := Alltrim(X5Descri())
		cDescTipo := Substr(SFF->FF_GRUPO,1,1)
		SX5->(DbSeek(xFilial("SX5")+"CO"+cDescTipo))
		cDescTipo:=Alltrim(X5Descri())
		RecLock(cAlias,.T.)
		Replace (cAlias)->CONCSUSS	With SFF->FF_ITEM
		Replace (cAlias)->DESCCONC	With SFF->FF_CONCEPT
		Replace (cAlias)->TIPOOBR	With Substr(SFF->FF_GRUPO,1,1)
		Replace (cAlias)->DESCTIPO	With cDescTipo
		Replace (cAlias)->ZONAGEO	With Substr(SFF->FF_GRUPO,2,2)
		Replace (cAlias)->DESCZONA	With cDescZona
		Replace (cAlias)->MINIMO	With SFF->FF_IMPORTE
		Replace (cAlias)->ALIQUOTA	With SFF->FF_ALIQ
		Replace (cAlias)->NUM		With Alltrim(Alltrim(SFF->FF_ITEM)+Substr(SFF->FF_GRUPO,1,1)+Substr(SFF->FF_GRUPO,2,2))
		Replace (cAlias)->NUMREC	With  SFF->(RECNO())
		Replace (cAlias)->CFOV		With SFF->FF_CFO_V
		Replace (cAlias)->CFOC		With SFF->FF_CFO_C
		Replace (cAlias)->CFO		With SFF->FF_CFO
		If SFF->(FieldPos("FF_TPCALC")) <> 0
			Replace (cAlias)->TIPOCALC With SFF->FF_TPCALC
		Endif
		(cAlias)->(DbCommit())
		DbSelectArea("SFF")
		SFF->(DbSkip())
	Enddo
	DbSelectArea(cAlias)
	dbGoTop()
	mBrowse(6,1,22,75,cAlias,aFixe)
	DbSelectArea(cAlias)
	DbCloseArea()
	
	If oTmpTable <> Nil   
		oTmpTable:Delete()  
		oTmpTable := Nil 
	EndIf 
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A994SUSS_MºAutor  ³Marcello            ºFecha ³ 23/09/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para manutencao da tabela de aliquotas para SUSS.    º±±
±±º          ³Argentina                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ A994SUSS                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A994SUSS_M(cAlias,nReg,nOpc)

Local cFilSX5		:= xFilial("SX5")
Local lIncl			:= .F.
Local lAlt			:= .F.
Local lOk			:= .F.
Local oDlg
Local cConceito		:= ""
Local nConceito		:= 0
Local aConceito		:= {}
Local oConceito
Local cTipoObra		:= ""
Local nTipoObra		:= 0
Local aTipoObra		:= {}
Local oTipoObra
Local cZonaGeo		:= ""
Local nZonaGeo 		:= 0
Local aZonaGeo 		:= {}
Local oZonaGeo
Local nTipoCalc		:= 0
Local aTipoCalc		:= {}
Local oTipoCalc
Local nMinimo		:= 0
Local oMinimo
Local nAliq			:= 0
Local oAliq
Local oBrow 		:= GetObjBrow()
Local aConceitoChv	:= {}
Local aTipoObraChv	:= {}
Local aZonaGeoChv	:= {}
Local cBox := ""

oBrow:lDisablePaint := .F.

lIncl := (aRotina[nOpc][4]==3)
lAlt := (aRotina[nOpc][4]==4)

nMinimo := If(lIncl,0,(cAlias)->MINIMO)
nAliq := If(lIncl,0,(cAlias)->ALIQUOTA)

cCFOV := If(lIncl,Space(TamSX3("FF_CFO_V")[1]),(cAlias)->CFOV)
cCFOC := If(lIncl,Space(TamSX3("FF_CFO_C")[1]),(cAlias)->CFOC)
cCFO := If(lIncl,Space(TamSX3("FF_CFO")[1]),(cAlias)->CFO)

If SFF->(ColumnPos("FF_TPCALC")) != 0
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	If SX3->(MsSeek("FF_TPCALC"))
    	cBox := X3Cbox()
		aTipoCalc := StrToKarr(cBox, ";")
	EndIf
	Aadd(aTipoCalc,"")
	nTipoCalc := If(lIncl .Or. (cAlias)->TIPOCALC == "",Len(aTipoCalc),Val((cAlias)->TIPOCALC))
	If cValToChar(nOpc) $ "1|3"
		If (cAlias)->TIPOCALC == " " 
			nTipoCalc := Len(aTipoCalc)
		Else
		 	nTipoCalc := Val((cAlias)->TIPOCALC)
		Endif	  
	Endif
Endif
SX5->(dbSeek(cFilSX5 + "CS"))
While SX5->X5_FILIAL==cFilSX5 .And. SX5->X5_TABELA=="CS"
	aAdd(aConceito,Alltrim(SX5->X5_CHAVE) + " - " + Alltrim(X5Descri()))
	aAdd(aConceitoChv,{AllTrim(SX5->X5_CHAVE),AllTrim(X5Descri())})
	SX5->(dbSkip())
Enddo
nConceito := If(lIncl,Len(aConceito),aScan(aConceitoChv,{|x| x[1] == AllTrim((cAlias)->CONCSUSS)}))
cConceito := aConceito[nConceito]
/**/
SX5->(DbSeek(cFilSX5 + "CO"))
While SX5->X5_FILIAL==cFilSX5 .And. SX5->X5_TABELA=="CO"
	aAdd(aTipoObra,Alltrim(SX5->X5_CHAVE) + " - " + Alltrim(X5Descri()))
	aAdd(aTipoObraChv,{Alltrim(SX5->X5_CHAVE),AllTrim(X5Descri())})
	SX5->(DbSkip())
Enddo
Aadd(aTipoObra," ")
nTipoObra := If(lIncl,Len(aTipoObra),aScan(aTipoObraChv,{|x| x[1] == AllTrim((cAlias)->TIPOOBR)}))
cTipoObra := aTipoObra[nTipoObra]
/**/
nZonaGeo:=0
SX5->(DbSeek(cFilSX5 + "ZG"))
While SX5->X5_FILIAL==cFilSX5 .And. SX5->X5_TABELA=="ZG"
	aAdd(aZonaGeo,Alltrim(SX5->X5_CHAVE)+" - "+Alltrim(X5Descri()))
	aAdd(aZonaGeoChv,{Alltrim(SX5->X5_CHAVE),AllTrim(X5Descri())})
	If !lIncl
		If Alltrim(SX5->X5_CHAVE)==(cAlias)->ZONAGEO
			nZonaGeo := Len(aZonaGeo)
		Endif
	Endif
	SX5->(DbSkip())
Enddo
Aadd(aZonaGeo,"  ")
cZonaGeo:=If(nZonaGeo==0,aZonaGeo[Len(aZonaGeo)],aZonaGeo[nZonaGeo])
/**/

DEFINE MSDIALOG oDlg FROM 6,1 TO 300,500 TITLE cCadastro Of oMainWnd PIXEL
	@037,005 SAY aFixe[1][1] SIZE 061,010
	@035,040 MSCOMBOBOX oConceito Var cConceito ITEMS aConceito SIZE 60,10 PIXEL OF oDlg FONT oDlg:oFont ON CHANGE (nConceito := oConceito:nAt) WHEN lIncl
	@037,115 SAY aFixe[3][1] SIZE 061,010
	@035,147 MSCOMBOBOX oTipoObra VAR cTipoObra ITEMS aTipoObra SIZE 65,10 PIXEL OF oDlg FONT oDlg:oFont ON CHANGE (nTipoObra := oTipoObra:nAt) WHEN lIncl
	@059,005 SAY aFixe[5][1] SIZE 061,010
	@057,050 MSCOMBOBOX oZonaGeo VAR cZonaGeo ITEMS aZonaGeo SIZE 162,10 PIXEL OF oDlg FONT oDlg:oFont ON CHANGE (nZonaGeo := oZonaGeo:nAt) WHEN lIncl
	@081,005 SAY aFixe[7][1] SIZE 031,020
	@079,050 MSGET oMinimo VAR nMinimo Picture PesqPict("SFF","FF_IMPORTE") SIZE 60,10 PIXEL OF oDlg FONT oDlg:oFont WHEN (lIncl .Or. lAlt)
	@081,120 SAY aFixe[8][1] SIZE 061,010
	@079,147 MSGET oAliq VAR nAliq Picture PesqPict("SFF","FF_ALIQ") SIZE 63,10 PIXEL OF oDlg FONT oDlg:oFont WHEN (lIncl .Or. lAlt)
	@103,005 SAY aFixe[9][1] SIZE 061,010
	@101,050 MSGET oAliq VAR cCFOC    F3 "13" Picture PesqPict("SFF","FF_CFO_C") Valid ( Vazio() .OR. (ExistCpo("SX5","13"+M->cCFOC)  .And. MaAvalTes("E",M->cCFOC) ) )  SIZE 50,10 PIXEL OF oDlg FONT oDlg:oFont WHEN (lIncl .Or. lAlt)
	@103,120 SAY aFixe[10][1] SIZE 061,010
	@101,160 MSGET oAliq VAR cCFOV     F3 "13" Picture PesqPict("SFF","FF_CFO_V")  Valid (Vazio() .OR. (ExistCpo("SX5","13"+M->cCFOV) .And. MaAvalTes("S",M->cCFOV) ) )  SIZE 50,10 PIXEL OF oDlg FONT oDlg:oFont WHEN (lIncl .Or. lAlt)
	@125,005 SAY aFixe[11][1] SIZE 061,010
	@123,050 MSGET oAliq VAR cCFO    F3 "13" Picture PesqPict("SFF","FF_CFO")   SIZE 50,10 PIXEL OF oDlg FONT oDlg:oFont WHEN (lIncl .Or. lAlt)
	If SFF->(FieldPos("FF_TPCALC")) <> 0
		@125,115 SAY aFixe[12][1] SIZE 061,010
		@123,160 MSCOMBOBOX oTipoCalc Var nTipoCalc ITEMS aTipoCalc SIZE 50,10 PIXEL OF oDlg FONT oDlg:oFont ON CHANGE (nTipoCalc := oTipoCalc:nAt) WHEN (lIncl .Or. lAlt)
	Endif
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| lOk:=A994SUSS_V(lIncl,cConceito,cTipoObra,cZonaGeo),If(lOk,oDlg:End(),)},{||lOk:=.F.,oDlg:End()}) CENTERED
/**/
nIncMtr:= 0
nExcMtr := 0
lAltMtr := .F.
If aRotina[nOpc][4] > 2
	If lOk
		DbSelectArea("SFF")
		If lIncl
			RecLock("SFF",.T.)
			Replace FF_FILIAL	With xFilial("SFF")
			Replace FF_IMPOSTO	With "SUS"
			Replace FF_ITEM	With aConceitoChv[nConceito,1]
			Replace FF_CONCEPT	With aConceitoChv[nConceito,2]
			Replace FF_GRUPO	With aTipoObraChv[nTipoObra,1] + aZonaGeoChv[nZonaGeo,1]
			Replace FF_IMPORTE	With nMinimo
			Replace FF_ALIQ	With nAliq
			Replace FF_NUM		With Alltrim(aConceitoChv[nConceito,1] + aTipoObraChv[nTipoObra,1] + aZonaGeoChv[nZonaGeo,1])
			Replace FF_CFO_V	With cCFOV
			Replace FF_CFO_C	With cCFOC
			Replace FF_CFO		With cCFO
			Replace FF_CFO		With cCFO
			If SFF->(FieldPos("FF_TPCALC")) <> 0
				Replace FF_TPCALC With Iif(Empty(aTipoCalc[nTipoCalc]), "", Str(nTipoCalc,1))
			Endif
			MsUnLock()
			dbSelectArea(cAlias)
			RecLock(cAlias,.T.)
			Replace (cAlias)->CONCSUSS	With aConceitoChv[nConceito,1]
			Replace (cAlias)->DESCCONC	With aConceitoChv[nConceito,2]
			Replace (cAlias)->TIPOOBR	With aTipoObraChv[nTipoObra,1]
			Replace (cAlias)->DESCTIPO	With aTipoObraChv[nTipoObra,2]
			Replace (cAlias)->ZONAGEO	With aZonaGeoChv[nZonaGeo,1]
			Replace (cAlias)->DESCZONA	With aZonaGeoChv[nZonaGeo,2]
			Replace (cAlias)->MINIMO	With nMinimo
			Replace (cAlias)->ALIQUOTA	With nAliq
			Replace (cAlias)->NUM		With Alltrim(aConceitoChv[nConceito,1] + aTipoObraChv[nTipoObra,1] + aZonaGeoChv[nZonaGeo,1])
			Replace (cAlias)->NUMREC  	With  SFF->(Recno())
			Replace (cAlias)->CFOV		With cCFOV
			Replace (cAlias)->CFOC		With cCFOC
			Replace (cAlias)->CFO		With cCFO
			If SFF->(FieldPos("FF_TPCALC")) <> 0
				Replace (cAlias)->TIPOCALC	With Iif(Empty(aTipoCalc[nTipoCalc]), "", Str(nTipoCalc,1))
			Endif
			MsUnLock()
			dbCommitAll()
			nIncMtr ++
		Else
			dbSelectArea("SFF")
			SFF->(dbSetOrder(1))
			SFF->(dbGoto((cAlias)->NUMREC))
			If lAlt
				RecLock("SFF",.F.)
				Replace FF_IMPORTE	With nMinimo
				Replace FF_ALIQ	With nAliq
			   	Replace FF_NUM		With Alltrim(aConceitoChv[nConceito,1] + aTipoObraChv[nTipoObra,1] + aZonaGeoChv[nZonaGeo,1])
				Replace FF_CFO_V	With cCFOV
				Replace FF_CFO_C	With cCFOC
				Replace FF_CFO		With cCFO
				If SFF->(FieldPos("FF_TPCALC")) <> 0
					Replace FF_TPCALC With Iif(Empty(aTipoCalc[nTipoCalc]), "", Str(nTipoCalc,1))
				Endif
				MsUnLock()
				dbSelectArea(cAlias)
				RecLock(cAlias,.F.)
				Replace (cAlias)->MINIMO	With nMinimo
				Replace (cAlias)->ALIQUOTA	With nAliq
				Replace (cAlias)->NUM		With Alltrim(aConceitoChv[nConceito,1] + aTipoObraChv[nTipoObra,1] + aZonaGeoChv[nZonaGeo,1])
				Replace (cAlias)->CFOV		With cCFOV
				Replace (cAlias)->CFOC		With cCFOC
				Replace (cAlias)->CFO		With cCFO
				If SFF->(FieldPos("FF_TPCALC")) <> 0
					Replace (cAlias)->TIPOCALC	With Iif(Empty(aTipoCalc[nTipoCalc]), "", Str(nTipoCalc,1))
				Endif
				MsUnLock()
				DbCommitAll()
				lAltMtr := .T.
			Else
				RecLock("SFF",.F.)
				DbDelete()
				MsUnLock()
				DbSelectArea(cAlias)
				RecLock(cAlias,.F.)
				DbDelete()
				MsUnLock()
				DbCommitAll()
				nExcMtr ++
			Endif
		Endif
		oBrow:Refresh()
	Endif
Endif

If nIncMtr > 0
	//Chamada da função para geração da metrica para inclusão
	M994Mtr("suss","inclusão",nIncMtr)
Endif
If nExcMtr > 0
	//Chamada da função para geração da metrica para exclusão
	M994Mtr("suss","exclusão",nExcMtr)
Endif
If lAltMtr
	//Chamada da função para geração da metrica para alteração
	M994Mtr("suss","alteração",1)
Endif

dbSelectArea(cAlias)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A994SUSS_VºAutor  ³Marcello            ºFecha ³ 05/10/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para verificação das informacoes a serem gravadas na º±±
±±º          ³tabela de aliquotas para SUSS.                              º±±
±±º          ³Argentina                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ A994SUSS                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A994SUSS_V(lIncl,cConceito,cTipoObra,cZonaGeo)
Local lRet := .T.
Local cFilSFF := xFilial("SFF")
Local cGrupo := ""

If lIncl
	cGrupo := Substr(cTipoObra,1,1)+Substr(cZonaGeo,1,2)
	cConceito := Left(cConceito,1)
	If SFF->(DbSeek(cFilSFF+"SUS"+cGrupo))
		While SFF->FF_FILIAL==cFilSFF .And. SFF->FF_IMPOSTO=="SUS" .And. SFF->FF_GRUPO==cGrupo .And. lRet
			If cPaisLoc == "ARG"
				lRet := cConceito <> Alltrim(SFF->FF_ITEM) .Or. ( cConceito == Alltrim(SFF->FF_ITEM) .And. M->cCFO <> SFF->FF_CFO )
			Else
				lRet := cConceito <> Alltrim(SFF->FF_ITEM)
			EndIf
			SFF->(DbSkip())
		Enddo
		If !lRet
			Help(" ",1,"JAGRAVADO")
		Endif
	Endif
Endif

If Empty(cConceito)  .or. Empty(cTipoObra)  .or. Empty(cZonaGeo) 
		MsgAlert (OemToAnsi(STR0184))
	lRet := .F.
EndiF

Return lRet

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994ASimIm¦ Autor ¦ Jesus Peñaloza       ¦ Data ¦ 08/06/14 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Tabla de Arancel sim Impo                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994ASimIm()
Local cGet1 := "   "
Local nGet1 := 0
Private oDlg
dbSelectArea("SFF")
SFF->(dbSetOrder(1))
If SFF->(dbSeek(xFilial()+"FFFFFF"))
	cGet1 := SFF->FF_IMPOSTO
	nGet1 := SFF->FF_IMPORTE
EndIf
DEFINE MSDIALOG oDlg FROM 0,0 TO 270,460 PIXEL TITLE STR0131
oGroup:= tGroup():New(0,0,140,260,'',oDlg,,,.T.)
@ 073, 017 SAY STR0012 SIZE 50, 10 OF oGroup PIXEL
@ 070, 042 MSGET oGet1 VAR cGet1 HASBUTTON F3 "SFB" VALID A994ImpValid(cGet1) SIZE 50, 10 OF oGroup PIXEL
@ 073, 132 SAY STR0058 SIZE 50, 10 OF oGroup PIXEL
@ 070, 157 MSGET oGet2 VAR nGet1 PICTURE '@E 999,999.9999' SIZE 50,10 OF oGroup PIXEL
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {||lOk:=.T.,A994GravAr(cGet1, nGet1)},{|| lOK := .F., oDlg:End()},,{{"EXCLUIR",{||A994DelAr()},"Eliminar"}}) CENTERED
Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦A994ImpValiD¦ Autor ¦ Jesus Peñaloza      ¦ Data ¦ 08/06/14 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Valida que el impuesto ingresado exista en la tabla SFB    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function A994ImpValid(cImp)
Local lRet := .T.

If Len(Alltrim(cImp)) != 0
	dbSelectArea("SFB")
	SFB->(dbSetOrder(1))
	IF !SFB->(dbSeek(xFilial("SFB")+cImp))
		lRet := .F.
		MsgAlert(STR0134)
	EndIf
EndIf
Return lRet

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦A994GravAr ¦ Autor ¦ Jesus Peñaloza       ¦ Data ¦ 08/06/14 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Guarda en la tabla SFF el Arancel sim Impo                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Parametros¦ cExp1: Codigo del Impuesto                                 ¦¦¦
¦¦¦          ¦ nExp1: Importe del impuesto                                ¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function A994GravAr(cImp, nImp)
If !Empty(Alltrim(cImp)) .and. nImp > 0
	dbSelectArea("SFF")
	SFF->(dbSetOrder(1))
	If SFF->(dbSeek(xFilial()+"FFFFFF"))
		RecLock("SFF", .F.)
		SFF->(dbDelete())
		SFF->(MsUnlock())
	EndIf
	RecLock("SFF", .T.)
	SFF->FF_FILIAL := xFilial('SFF')
	SFF->FF_NUM := 'FFFFFF'
	SFF->FF_IMPOSTO := cImp
	SFF->FF_IMPORTE := nImp
	SFF->(MsUnlock())
	MsgInfo(STR0133)
	oDlg:End()
Else
	MsgAlert(STR0163) //"Ingresa impuesto e importe."
EndIf
Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦A994DelAr  ¦ Autor ¦ Jesus Peñaloza       ¦ Data ¦ 08/06/14 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Elimina de la tabla SFF el Arancel sim Impo                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function A994DelAr()
dbSelectArea("SFF")
SFF->(dbSetOrder(1))
If MsgYesNo(STR0164,STR0165) //"¿Está seguro de eliminar?" - "Confirmar"
	If SFF->(dbSeek(xFilial()+"FFFFFF"))
		RecLock("SFF", .F.)
		SFF->(dbDelete())
		SFF->(MsUnlock())
	EndIf
	oDlg:End()
EndIf
Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf010  ¦ Autor ¦ José Lucas            ¦ Data ¦ 07/08/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Tabela de Ganancia/Fondo Cooperativo.                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994Ganan()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("AFIXE,AROTINA,CCADASTRO,")

aFixe := {{OemToAnsi(STR0006) ,"FF_NUM"},;    // Planilla
	  	   {OemToAnsi(STR0007) ,"FF_ITEM"},;   // Concepto
		   {OemToAnsi(STR0057) ,"FF_CFO"},;  // CFO
		   {OemToAnsi(STR0010) ,"FF_CONCEPT"} }  // Descricion

aYesFields := {"FF_ITEM","FF_CONCEPT","FF_CFO","FF_ALQINSC","FF_ALQNOIN","FF_IMPORTE","FF_ESCALA","FF_SERIENF"}
aYesEscala := {"FF_ITEM","FF_CFO","FF_FXDE","FF_FXATE","FF_RETENC","FF_PERC","FF_EXCEDE","FF_IMPORTE"}

If SFF->(ColumnPos("FF_ALNOIPF")) > 0  
	aYesFields := {"FF_ITEM","FF_CONCEPT","FF_CFO","FF_ALQINSC","FF_ALQNOIN","FF_ALNOIPF","FF_IMPORTE","FF_ESCALA","FF_SERIENF"}
EndIf

If SFF->(ColumnPos("FF_INCIMP")) > 0
	aAdd(aYesFields, "FF_INCIMP")
EndIf

If SFF->(FieldPos("FF_MINUNIT")) > 0 .And. SFF->(FieldPos("FF_LIMITE")) > 0
	aAdd(aYesFields, "FF_TIPO")
	aAdd(aYesFields, "FF_MINUNIT")
	aAdd(aYesFields, "FF_LIMITE")

	If SFF->(FieldPos("FF_TPLIM")) > 0
		aAdd(aYesFields,"FF_TPLIM")
	Endif

	aAdd(aYesFields, "FF_REDBASE")
Endif


aRotina := {{ OemToAnsi(STR0001),"AxPesqui"		,0,1,0,.F.},;		// Buscar
			{ OemToAnsi(STR0002),'A994Avisual'	,0, 2,0,NIL},;		// Visualizar
			{ OemToAnsi(STR0003),'A994Ainclui'	,0, 3,0,NIL},;		// Incluir
			{ OemToAnsi(STR0004),'A994Aaltera'	,0, 4,0,NIL},;		// Modificar
			{ OemToAnsi(STR0005),'A994Adeleta'	,0, 5,0,NIL} }		// Borrar


cCadastro := OemToAnsi(STR0011)  // Planilla de Ganancias/Fondo Cooperativo

//+--------------------------------------------------------------+
//¦ Prepara o SFF para filtrar os registro para Ganancias...     ¦
//+--------------------------------------------------------------+
dbSelectArea("SFF")
dbSetOrder(1)
dbSetFilter({|| FF_FILIAL==xFilial('SFF') .and. FF_IMPOSTO=='GAN'},"FF_FILIAL==xFilial('SFF') .and. FF_IMPOSTO=='GAN'")
dbGoTop()

//+--------------------------------------------------------------+
//¦ Pesquisa Especifica pelo Nome Reduzido indice 4              ¦
//+--------------------------------------------------------------+
mBrowse( 6, 1,22,75,"SFF",aFixe)

dbSelectArea("SFF")
dbClearFilter()
dbSetOrder(1)
Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf050  ¦ Autor ¦ José Lucas            ¦ Data ¦ 25/03/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Tabela de Generica de Impuesto de Valor Agregado-IVA.      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994IVA()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

MsgAlert(OemToAnsi(STR0185)+CHr(13)+chr(10)+OemToAnsi(STR0186)+CHr(13)+chr(10))

SetPrvt("AFIXE,AROTINA,CCADASTRO,")

aFixe := { {OemToAnsi(STR0012) ,"FF_IMPOSTO"},;  // Impuesto
  		   {OemToAnsi(STR0013) ,"FF_SERIENF"},;  // Serie Fac.
		   {OemToAnsi(STR0057) ,"FF_CFO"  },;  // CFO Compras
		   {OemToAnsi(STR0008) ,"FF_CFO_C"  },;  // CFO Compras
		   {OemToAnsi(STR0009) ,"FF_CFO_V"  },;  // CFO Ventas
		   {OemToAnsi(STR0010) ,"FF_CONCEPT"} }  // Descricion

//aYesFields := {"FF_IMPOSTO","FF_SERIENF","FF_CFO","FF_CFO_C","FF_CFO_V","FF_CONCEPT","FF_ALIQ","FF_IMPORTE"}


If SFF->(FieldPos("FF_ALIQLEX")) > 0 .And. SFF->(FieldPos("FF_VLRLEX")) > 0
	aYesFields := {"FF_IMPOSTO","FF_SERIENF","FF_CFO","FF_CFO_C","FF_CFO_V","FF_CONCEPT","FF_ALIQ","FF_IMPORTE","FF_ALIQLEX","FF_VLRLEX","FF_INCIMP"}
Else
	aYesFields := {"FF_IMPOSTO","FF_SERIENF","FF_CFO","FF_CFO_C","FF_CFO_V","FF_CONCEPT","FF_ALIQ","FF_IMPORTE"}
Endif

If SFF->(FieldPos("FF_MINUNIT")) > 0 .And. SFF->(FieldPos("FF_LIMITE")) > 0
	aAdd(aYesFields,"FF_TIPO")
	aAdd(aYesFields,"FF_ITEM")
	aAdd(aYesFields,"FF_MINUNIT")
	aAdd(aYesFields,"FF_LIMITE")
Endif

If SFF->(FieldPos("FF_VALMIN")) > 0
	aAdd(aYesFields,"FF_VALMIN")
Endif

If SFF->(FieldPos("FF_TPLIM")) > 0
	aAdd(aYesFields,"FF_TPLIM")
Endif

If SFF->(ColumnPos("FF_REDALIQ")) > 0	
	aAdd(aYesFields,"FF_REDALIQ")
Endif

If SFF->(ColumnPos("FF_SISA")) > 0
	aAdd(aYesFields,"FF_SISA")
Endif

If SFF->(ColumnPos("FF_TIPAGRO")) > 0	
	aAdd(aYesFields,"FF_TIPAGRO")
Endif

aRotina := {{ OemToAnsi(STR0001),"AxPesqui"		,0,1,0,.F.},;		// Buscar
			{ OemToAnsi(STR0002),'A994Bvisual'	,0,2,0,NIL},;		// Visualizar
			{ OemToAnsi(STR0003),'A994Binclui'	,0,3,0,NIL},;		// Incluir
			{ OemToAnsi(STR0004),'A994Baltera'	,0,4,0,NIL},;		// Modificar
			{ OemToAnsi(STR0005),'A994Bdeleta'	,0,5,0,NIL} }		// Borrar

cCadastro := OemToAnsi(STR0014)  // Planilla de Impuesto de Valor Agregado

//+--------------------------------------------------------------+
//¦ Prepara o SFF para filtrar os registro para IVA...           ¦
//+--------------------------------------------------------------+
dbSelectArea("SFF")
dbSetOrder(2)
dbSetFilter({|| FF_FILIAL==xFilial('SFF') .and. Subs(FF_IMPOSTO,1,2)=='IV'},"FF_FILIAL==xFilial('SFF') .and. Subs(FF_IMPOSTO,1,2)=='IV'")
dbGoTop()

//+--------------------------------------------------------------+
//¦ Pesquisa Especifica pelo Nome Reduzido indice 4              ¦
//+--------------------------------------------------------------+
mBrowse( 6, 1,22,75,"SFF",aFixe)

dbClearFilter()

dbSelectArea("SFF")
dbSetOrder(1)
Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf100  ¦ Autor ¦ José Lucas            ¦ Data ¦ 25/03/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Tabela de Generica de Ingresos Brutos.                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
30/07/99 JOSE LUIS - trata de CFO Compras e Vendas
*/
Function A994IngBrt()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("AFIXE,AROTINA,CCADASTRO,")

aFixe := { {OemToAnsi(STR0012) ,"FF_IMPOSTO"},;  // Impuesto
		   {OemToAnsi(STR0015) ,"FF_ZONFIS" },;  // Zona Fiscal
		   {OemToAnsi(STR0008) ,"FF_CFO_C"  },;  // CFO Compras
		   {OemToAnsi(STR0009) ,"FF_CFO_V"  },;  // CFO Ventas
 		   {OemToAnsi(STR0010) ,"FF_CONCEPT"} }  // Descricion

If SFF->(FieldPos("FF_INCIMP")) > 0
	aYesFields := {"FF_IMPOSTO","FF_ZONFIS","FF_CFO_C","FF_CFO_V","FF_CFO","FF_CONCEPT","FF_ALIQ","FF_ALQNOIN","FF_IMPORTE","FF_TIPO","FF_PRALQIB","FF_INCIMP","FF_FORMAPG","FF_DESCFOR","FF_ALIQPAG","FF_VALMIN"}// verificar pq no deleta tem menos campos
Else
	aYesFields := {"FF_IMPOSTO","FF_ZONFIS","FF_CFO_C","FF_CFO_V","FF_CFO","FF_CONCEPT","FF_ALIQ","FF_ALQNOIN","FF_IMPORTE","FF_TIPO","FF_PRALQIB","FF_FORMAPG","FF_DESCFOR","FF_ALIQPAG","FF_VALMIN"} // verificar pq no deleta tem menos campos
Endif

If SFF->(FieldPos("FF_CFORA")) > 0       //Agregar campo de Cod. Fiscal Adicional
	aAdd(aYesFields,"FF_CFORA")
Endif

If SFF->(FieldPos("FF_MINUNIT")) > 0 .And. SFF->(FieldPos("FF_LIMITE")) > 0
	aAdd(aYesFields,"FF_ITEM")
	aAdd(aYesFields,"FF_MINUNIT")
	aAdd(aYesFields,"FF_LIMITE")
Endif

If SFF->(FieldPos("FF_TPLIM")) > 0
		aAdd(aYesFields,"FF_TPLIM")
Endif

If cPaisLoc == "ARG" .and. SFF->(FieldPos("FF_REDBASE")) > 0 
	aAdd(aYesFields, "FF_REDBASE")		
Endif

/*
 * Campos do fornecedor padrão de impostos
 */
If SFF->(FieldPos("FF_FORNECE")) > 0 .AND. SFF->(FieldPos("FF_LOJA")) > 0
	aAdd(aYesFields,"FF_FORNECE")
	aAdd(aYesFields,"FF_LOJA")
EndIf

aRotina := {{ OemToAnsi(STR0001),"AxPesqui"		,0,1,0,.F.},;		// Buscar
			{ OemToAnsi(STR0002),'A994Cvisual'	,0,2,0,NIL},;		// Visualizar
			{ OemToAnsi(STR0003),'A994Cinclui'	,0,3,0,NIL},;		// Incluir
			{ OemToAnsi(STR0004),'A994Caltera'	,0,4,0,NIL},;		// Modificar
			{ OemToAnsi(STR0005),'A994Cdeleta'	,0,5,0,NIL} }		// Borrar

cCadastro := OemToAnsi(STR0016)   // Planilla de Ingresos Brutos

//+--------------------------------------------------------------+
//¦ Prepara o SFF para filtrar os registro para IVA...           ¦
//+--------------------------------------------------------------+
dbSelectArea("SFF")
dbSetOrder(4)
dbSetFilter({|| FF_FILIAL==xFilial('SFF') .and. 'IB'$FF_IMPOSTO},"FF_FILIAL==xFilial('SFF') .and. 'IB'$FF_IMPOSTO")
dbGoTop()

//+--------------------------------------------------------------+
//¦ Pesquisa Especifica pelo Nome Reduzido indice 4              ¦
//+--------------------------------------------------------------+
mBrowse( 6, 1,22,75,"SFF",aFixe)

dbSelectArea("SFF")
dbClearFilter()
dbSetOrder(1)
Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf011  ¦ Autor ¦ José Lucas            ¦ Data ¦ 23/06/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Visualizacao da Tabela de Ganancias/Fondo Cooperativo.     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994AVisual()

Local cSeek, cWhile
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("AHEADER,ACOLS,CTABELA,CMESREF,CMESEXT")
SetPrvt("NVALIMPORTE,NTOTALITENS,CTITULO,AC")
SetPrvt("AR,ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2")
SetPrvt("AMES,NI,ACAB,APICTURE,CCADASTRO")
SetPrvt("OLBX,NOPCA")

nOpcx:=2


//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela   := SFF->FF_NUM
cMesRef   := SFF->FF_MESREF
cMesExt   := Space(09)

MesExt()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader e aCols                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sintaxe da FillGetDados(nOpcx,cAlias,nOrder,cSeekKey,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry,bCriaVar,lUserFields) |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeek	:= xFilial("SFF")+cTabela
cWhile	:= "FF_FILIAL+FF_NUM"
FillGetDados(nOpcx,"SFF",1,cSeek,{|| &cWhile },{|| .T. },/*aNoFields*/,aYesFields,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bBeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/,/*bCriaVar*/)

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens := len(aCols)

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:= OemToAnsi(STR0017)  // "Ganancias/Fondo Cooperativo"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
aC:={}
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!"      ,".T.",,.F.})  // Nr. Tabla
AADD(aC,{"cMesRef"  ,{30,011} ,OemToAnsi(STR0073),"@R 99/99",".T.",,.F.})  // Fch. Ref.
AADD(aC,{"cMesExt"  ,{30,070} ," "               ,"@!"      ,".T.",,.F.})

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk:="AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,".T.",".T.",,,,SFF->(Reccount())+100)

If lRetMod2
	//+--------------------------------------------------------------+
	//¦ Edicao e Visualizacao da Escala Aplicable (1).               ¦
	//+--------------------------------------------------------------+
	EscalaVis()
EndIf
Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ MesExt   ¦ Autor ¦ José Lucas            ¦ Data ¦ 23/06/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Retornar o Mes por extenso.                                ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> Function MesExt
Static Function MesExt()
Local nI := 0
aMes:={}
AADD(aMes,OemToAnsi(STR0018)) // "ENERO    "
AADD(aMes,OemToAnsi(STR0019)) // "FEBRERO  "
AADD(aMes,OemToAnsi(STR0020)) // "MARZO    "
AADD(aMes,OemToAnsi(STR0021)) // "ABRIL    "
AADD(aMes,OemToAnsi(STR0022)) // "MAYO     "
AADD(aMes,OemToAnsi(STR0023)) // "JUNIO    "
AADD(aMes,OemToAnsi(STR0024)) // "JULIO    "
AADD(aMes,OemToAnsi(STR0025)) // "AGOSTO   "
AADD(aMes,OemToAnsi(STR0026)) // "SETIEMBRE"
AADD(aMes,OemToAnsi(STR0027)) // "OCTUBRE  "
AADD(aMes,OemToAnsi(STR0028)) // "NOVIEMBRE"
AADD(aMes,OemToAnsi(STR0029)) // "DICIEMBRE"
For nI := 1 To 12
	If nI == Val(Subs(cMesRef,1,2))
		cMesExt := aMes[nI]
		Exit
	EndIf
Next nI
Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Escala   ¦ Autor ¦ José Lucas            ¦ Data ¦ 10/08/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Edicao de Cpos para a Escala Aplicable.                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> Function Escala
Static Function EscalaVis()
//+--------------------------------------------------------------+
//¦ Montando Array...                                            ¦
//+--------------------------------------------------------------+
Local nCnt := 0
Local aArrEscala := {}
dbSelectArea("SFF")
dbSetOrder(1)
dbSeek(xFilial("SFF")+cTabela)
While !EOF() .And. FF_FILIAL+FF_NUM == xFilial("SFF")+cTabela
	If Val(FF_ITEM) > 12
		nCnt := nCnt + 1
		AADD( aArrEscala,{StrZero(nCnt,2),FF_FXDE,FF_FXATE,FF_RETENC,FF_PERC,FF_EXCEDE})
	EndIf
	dbSkip()
End

If ! Empty(aArrEscala)

	aCab := { OemToAnsi(STR0030),;  // Iten
 			  OemToAnsi(STR0031),;  // De mas de $
			  OemToAnsi(STR0032),;  // a $
			  OemToAnsi(STR0033),;  // $
			  OemToAnsi(STR0034),;  // Mas el %
			  OemToAnsi(STR0035) }  // Excedente

	aPicture :=  { "99",;
  				   "@E 999,999,999,999.99",;
				   "@E 999,999,999,999.99",;
				   "@E 999,999,999,999.99",;
				   "@E 999.99",;
				   "@E 999,999,999,999.99" }

	cCadastro := OemToAnsi(STR0036)  // "Escala Aplicable (1)"

    @ 0,0 TO 190,600 DIALOG oDlg TITLE cCadastro

    // Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> 		//@ 4,5 TO 70,295 MULTILINE MODIFY DELETE VALID Execute(LineOk) FREEZE 1
	//@ 4,5 TO 70,295 MULTILINE MODIFY DELETE VALID LineOk() FREEZE 1

	oLbx := RDListBox(.6, .4, 291, 60, aArrEscala, aCab,, aPicture)

    // Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> 		@ 77.5,234 BMPBUTTON TYPE 1 ACTION Execute(oOk)
	@ 77.5,234 BMPBUTTON TYPE 1 ACTION oOk()
    // Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> 		@ 77.5,266 BMPBUTTON TYPE 2 ACTION Execute(oCancel)
	@ 77.5,266 BMPBUTTON TYPE 2 ACTION oCancel()

	ACTIVATE DIALOG oDlg CENTERED

EndIf
Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf012  ¦ Autor ¦ José Lucas            ¦ Data ¦ 22/06/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Inclusao da Tabela de Ganancias/Fondo Cooperativo.         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994Ainclui()

Local nX := 0
Local nY := 0
Local nI := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("AHEADER,ACOLS")
SetPrvt("CTABELA,CMESDESDE,CMESATE,CPLANILLA,NTOTALITENS,CTITULO")
SetPrvt("AC,AR,ACGD,CLINHAOK,CTUDOOK,AGETEDIT")
SetPrvt("LRETMOD2,NOPCA,NMAXARRAY,NY,NCNTITEM,NX")
SetPrvt("CVAR,AROTINA,CCADASTRO,AHEADESCALA")
SetPrvt("ACOLSESCALA")

nOpcx:=3

//+--------------------------------------------------------------+
//¦ Inicializar o proximo numero da Tabela.                      ¦
//+--------------------------------------------------------------+
dbSelectArea("SFF")
dbSetOrder(1)
dbSeek(xFilial("SFF")+"000001")
If Found()
	MsgBox( OemToAnsi(STR0049), OemToAnsi(STR0050),STR0180 ) //"Atencion" - "INFO"
	Return
EndIf

//+--------------------------------------------------------------+
//¦ Montando array de Conceptos...                               ¦
//+--------------------------------------------------------------+
aConceptos := {}
AADD(aConceptos,OemToAnsi(STR0037) ) // "INTERESES POR OPERACIONES EN ENTIDADES FINANCIERAS, AGENTES DE BOLSA O MERCADO ABERTO             "
AADD(aConceptos,OemToAnsi(STR0038) ) // "INTERESES POR FINANCIAMENTO O EVENTUALES INCUMPLIMIENTOS                                          "
AADD(aConceptos,OemToAnsi(STR0039) ) // "OTROS INTERESES                                                                                   "
AADD(aConceptos,OemToAnsi(STR0040) ) // "ALQUILERES DE BIENES MUEBLES E INMUEBLES                                                          "
AADD(aConceptos,OemToAnsi(STR0041) ) // "REGALIAS UTILIDADES E INTERESES DE COOPERATIVAS (EXCEPTO LAS DE CONSUMO); OBLIGACIONES DE NO HACER"
AADD(aConceptos,OemToAnsi(STR0042) ) // "VENTA DE BIENES DE CAMBIO, BIENES MUEBLES; LOCACIONES DE OBRA Y/O SERVICIOS; TRANSFERENCIA DEFINIT";
                                     //+"IVA DE LLAVES, MARCAS, PATENTES DE INVENCION, REGALIAS, CONCESION Y SIMILARES                     "

AADD(aConceptos,OemToAnsi(STR0043) ) // "EJERCICIO DE PROFESIONES LIBERALES U OFICIOS; SINDICO; MANDATARIO; DIRECTOR DE SOCIEDADES ANONIMAS";
                                     //+"; CORREDOR; VIAJANTE DE COMERCIO Y DESPACHANTE DE ADUANA                                          "
AADD(aConceptos,OemToAnsi(STR0044) ) // "PAGOS EFECTUADOS POR CADA ADMINISTRACION DESCENTRALIZADA, CAJA CHICA O FONDO FIJO                 "
AADD(aConceptos,OemToAnsi(STR0045) ) // "TRANSPORTE DE CARGA INTERNACIONAL                                                                 "
AADD(aConceptos,OemToAnsi(STR0046) ) // "OPERACIONES REALIZADAS A TRAVES DE MERCADOS DE CEREALES A TERMINO                                 "
AADD(aConceptos,OemToAnsi(STR0047) ) // "LOCACION DE DERECHOS, DISTRIBUCION DE PELICULAS CINEMATOGRAFICAS                                  "
AADD(aConceptos,OemToAnsi(STR0048) ) // "RETENCION MINIMA                                                                                  "

//+--------------------------------------------------------------+
//¦ Montando aHeader                                             ¦
//+--------------------------------------------------------------+
aHeader:={}

dbSelectArea("SX3")
dbSeek("SFF")
While !Eof() .And. X3_ARQUIVO == "SFF"
	IF (X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. Ascan(aYesFields,Trim(SX3->X3_CAMPO)) != 0) .Or.;
		(X3_PROPRI == "U".And. cNivel >= X3_NIVEL)
		Aadd(aHeader,{TRIM(X3TITULO()), X3_CAMPO, X3_PICTURE,X3_TAMANHO,X3_DECIMAL,;
		X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT})
	EndIf
	dbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os campos de Alias e Recno ao aHeader para WalkThru.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ADHeadRec("SFF",aHeader)

dbSetOrder(1)
aCOLS:=Array(Len(aConceptos),Len(aHeader)+1)
//+--------------------------------------------------------------+
//¦ Montando aCols                                               ¦
//+--------------------------------------------------------------+

For nI := 1 To Len(aConceptos)

	For nY := 1 to Len(aHeader)
		If IsHeadRec(aHeader[nY][2])
			aCols[nI][nY] := 0
		ElseIf IsHeadAlias(aHeader[nY][2])
			aCols[nI][nY] := "SFF"
		ElseIf AllTrim(aHeader[nY,2]) == "FF_ITEM"
			aCols[nI][nY] 	:= StrZero(nI,TAMSX3("FF_ITEM")[1])
		ElseIf aHeader[nY,2] == "FF_CONCEPT"
			aCols[nI][nY] 	:= aConceptos[nI]
		Else
			aCols[nI][nY] := CriaVar(aHeader[nY][2])
		EndIf
	Next nY

	aCols[nI][Len(aHeader)+1] := .F.

Next nI

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela   := "000001"
cMesDesde := Space(04)
cMesAte   := Space(04)

cPlanilla := "GAN"

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens:=0

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:= OemToAnsi(STR0051) // "Tabla de Ganancias/Fondo Cooperativo"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!","A994VTabla()",,.F.})  //"Nr. Tabla"
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,}) //"Fecha desde:"
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,}) //"Fecha hasta:"

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0055),"@E 999",,,.F.}) // "Total de Conceptos"

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
// cLinhaOk:="A994AlinOk()"
cLinhaOk:= "AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou
lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,".T.",,,,SFF->(Reccount())+100)

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente
If lRetMod2

	//+--------------------------------------------------------------+
	//¦ Edicao e Visualizacao da Escala Aplicable (1).               ¦
	//+--------------------------------------------------------------+
	nOpca := 0
	EscalaInc()
	If nOpca != 1
		Return
	EndIf

	//+--------------------------------------------------------------+
	//¦ Atualiza o Corpo da Tabela                                   ¦
	//+--------------------------------------------------------------+
	dbSelectArea("SFF")
	nMaxArray := Len(aCols)
	For ny := 1 to Len(aHeader)
		If Empty(aCols[nMaxArray][ny]) .AND. Trim(aHeader[ny][2]) == "FF_ITEM"
			nMaxArray := nMaxArray - 1
			Exit
		EndIf
	Next ny

	nCntItem:= 1
	For nx := 1 to nMaxArray
		IF !aCols[nx][Len(aCols[nx])]

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do tabela.                                    ¦
			//+--------------------------------------------------------------+
			dbSelectArea("SFF")
			RecLock("SFF",.T.)
			Replace 	FF_FILIAL  With xFilial("SFF"),;
			       		FF_NUM     With cTabela,;
						FF_DESDE   With cMesDesde,;
						FF_ATE	   With cMesAte,;
						FF_IMPOSTO With "GAN"


			//+--------------------------------------------------------------+
			//¦ Atualiza dados do corpo da Tabela.                           ¦
			//+--------------------------------------------------------------+
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
				Endif
			Next ny
			dbUnLock()

			nCntItem:=nCntItem + 1
		EndIF
	Next nx

	//+--------------------------------------------------------------+
	//¦ Atualizar a Escala Aplicable.                                ¦
	//+--------------------------------------------------------------+
	dbSelectArea("SFF")
	nMaxArray := Len(aCOLSEscala)
	For ny := 1 to Len(aHeadEscala)
		If Empty(aCols[nMaxArray][ny]) .AND. Trim(aHeadEscala[ny][2]) == "FF_ITEM"
			nMaxArray := nMaxArray - 1
			Exit
		EndIf
	Next ny

	nCntItem := IIf( nCntItem==0,1,nCntItem)
	For nx := 1 to nMaxArray
		IF !aCOLSEscala[nx][Len(aCOLSEscala[nx])]

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do tabela.                                    ¦
			//+--------------------------------------------------------------+
			dbSelectArea("SFF")
			RecLock("SFF",.T.)
			Replace 	FF_FILIAL  With xFilial("SFF"),;
				       	FF_NUM     With cTabela,;
						FF_DESDE   With cMesDesde,;
						FF_ATE     With cMesAte

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do corpo da Tabela.                           ¦
			//+--------------------------------------------------------------+
			For ny := 1 to Len(aHeadEscala)
				If aHeadEscala[ny][10] # "V"
					SFF->(FieldPut(FieldPos(Trim(aHeadEscala[ny][2])),aCOLSEscala[nx][ny]))
				Endif
			Next ny
			Replace FF_ITEM    With StrZero(nCntItem,2)
			Replace FF_CONCEPT With OemToAnsi(STR0056)+ aCOLSEscala[nx][1]  // "ESCALA APLICABLE - FAJA " +
			Replace FF_IMPOSTO With "GAN"
 		    dbUnLock()

			nCntItem:=nCntItem + 1
		EndIF
	Next nx
Endif
//+-------------------------------------------------------+
//¦ Forçar o array aRotina para dribar a funcao ExecBrow. ¦
//+-------------------------------------------------------+
SFF->(DbSetOrder(1))
aRotina[3][4] := 0
Return


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Escala   ¦ Autor ¦ José Lucas            ¦ Data ¦ 10/08/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Edicao de Cpos para a Escala Aplicable.                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> Function Escala
Static Function EscalaInc()

Local nY
Local aHeaderAnt	:= AClone(aHeader)
Local aCOLSAnt		:= AClone(aCOLS)

//+--------------------------------------------------------------+
//¦ Montando aHeader                                             ¦
//+--------------------------------------------------------------+
aHeader:={}

dbSelectArea("SX3")
dbSeek("SFF")
While !Eof() .And. X3_ARQUIVO == "SFF"
	IF (X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. Ascan(aYesEscala,Trim(SX3->X3_CAMPO)) != 0)
		Aadd(aHeader,{TRIM(X3TITULO()), X3_CAMPO, X3_PICTURE,X3_TAMANHO,X3_DECIMAL,;
		X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT})
	EndIf
	dbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os campos de Alias e Recno ao aHeader para WalkThru.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ADHeadRec("SFF",aHeader)

//Alterando função de validação do campo FF_ITEM
aHeader[aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ITEM" })][6] := "A994V2Item()"

dbSetOrder(1)
aCOLS:=Array(1,Len(aHeader)+1)
//+--------------------------------------------------------------+
//¦ Montando aCols                                               ¦
//+--------------------------------------------------------------+

For nY := 1 to Len(aHeader)
	If IsHeadRec(aHeader[nY][2])
		aCols[1][nY] := 0
	ElseIf IsHeadAlias(aHeader[nY][2])
		aCols[1][nY] := "SFF"
	ElseIf AllTrim(aHeader[nY,2]) == "FF_ITEM"
		aCols[1][nY] := StrZero(1,TAMSX3("FF_ITEM")[1])
	Else
		aCols[1][nY] := CriaVar(aHeader[nY][2])
	EndIf
Next nY

aCols[1][Len(aHeader)+1] := .F.

cCadastro := OemToAnsi(STR0036)   // Escala Aplicable (1)

	@ 0,0 TO 190,600 DIALOG oDlg TITLE cCadastro

    // Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> 	@ 4,5 TO 70,295 MULTILINE MODIFY DELETE VALID Execute(LineOk) FREEZE 1
	@ 4,5 TO 70,295 MULTILINE MODIFY DELETE VALID LineOk() FREEZE 1

    // Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> 	@ 77.5,234 BMPBUTTON TYPE 1 ACTION Execute(oOk)
	@ 77.5,234 BMPBUTTON TYPE 1 ACTION oOk()
    // Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> 	@ 77.5,266 BMPBUTTON TYPE 2 ACTION Execute(oCancel)
	@ 77.5,266 BMPBUTTON TYPE 2 ACTION oCancel()

	ACTIVATE DIALOG oDlg CENTERED

	aHeadEscala := AClone(aHeader)
	aCOLSEscala := AClone(aCOLS)

	aHeader := {}
	aCOLS   := {}
	aHeader := AClone(aHeaderAnt)
	aCOLS   := AClone(aCOLSAnt)

Return

// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> Function oOk
Static Function oOk()
	nOpcA := 1
	Close(oDlg)
Return

// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> Function oCANCEL
Static Function oCANCEL()
	nOpcA := 2
	Close(oDlg)
Return

// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> Function LineOk
Static Function LineOk()
Return(.T.)


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf013  ¦ Autor ¦ José Lucas            ¦ Data ¦ 10/08/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Alteracao da Tabela de Imp GANACIAS                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994Aaltera()
Local nY := 0
Local nX := 0
Local cSeek
Local cWhile
Local cImposto
Local cImpGAN := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,AHEADER,CTABELA,CMESDESDE,CMESATE")
SetPrvt("CPLANILLA,ACOLS,NVALIMPORTE,NTOTALITENS")
SetPrvt("NTOTITENSFF,CTITULO,AC,AR,ACGD,CLINHAOK")
SetPrvt("CTUDOOK,AGETEDIT,LRETMOD2,NOPCA,NCNTITEM,NX")
SetPrvt("NY,CVAR,AMES,NI,CMESEXT,AHEADERANT")
SetPrvt("ACOLSANT,NTOTITENSESC,CCADASTRO,AHEADESCALA")
SetPrvt("ACOLSESCALA,LRET,NV,")

nOpcx:=4


//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela   := SFF->FF_NUM
cMesDesde := SFF->FF_DESDE
cMesAte   := SFF->FF_ATE
cImposto  := SFF->FF_IMPOSTO

cPlanilla := "GAN"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader e aCols                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sintaxe da FillGetDados(nOpcx,cAlias,nOrder,cSeekKey,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry,bCriaVar,lUserFields) |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeek	:= xFilial("SFF")+cTabela
cWhile	:= "FF_FILIAL+FF_NUM"
dbSetFilter({|| FF_FILIAL==xFilial('SFF') .and. FF_IMPOSTO=='GAN'},"FF_FILIAL==xFilial('SFF') .and. FF_IMPOSTO=='GAN'")
FillGetDados(nOpcx,"SFF",1,cSeek,{|| &cWhile },{|| .T. },/*aNoFields*/,aYesFields,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bBeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/,/*bCriaVar*/)

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens	:= len(aCols)
nTotItensFF	:= len(aCols)
//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:= OemToAnsi(STR0051) // "Tabla de Ganancias/Fondo Cooperativo"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!","A994VTabla()",,.F.})  // Nr.Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,.F.})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,.F.})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0055),"@E 999",,,.F.})  // Total de Conceptos

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
// cLinhaOk:="A994AlinOk()"
cLinhaOk:= "AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou
lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,".T.",,,,SFF->(Reccount())+100)

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente
If lRetMod2

	//+--------------------------------------------------------------+
	//¦ Edicao e Visualizacao da Escala Aplicable (1).               ¦
	//+--------------------------------------------------------------+
	nOpca := 0
	EscalaAlt()
	If nOpca != 1
		Return
	EndIf
	
	nIncMtr := 0
	nExcMtr := 0
	lAltMtr := .F.
	
	nCntItem:= 1
 	For nx := 1 to Len(aCols)
		IF !aCols[nx][Len(aCols[nx])]
			//+--------------------------------------------------------------+
			//¦ Se e um iten novo, incluir-lo , senao so atualizar           ¦
			//+--------------------------------------------------------------+
			If nX > nTotItensFF
				RecLock("SFF",.T.)
				cImpGAN := "GAN"
				nIncMtr ++
			Else
				SFF->(DbGoTo(aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "FF_REC_WT" })]))
				RecLock("SFF",.F.)
				cImpGAN := SFF->FF_IMPOSTO
				lAltMtr := .T.
			Endif

			If cImpGAN == "GAN"
				Replace	FF_FILIAL  With xFilial("SFF"),;
			    	   	FF_NUM     With cTabela,;
						FF_DESDE   With cMesDesde,;
						FF_ATE	   With cMesAte,;
						FF_IMPOSTO With "GAN"

				//+--------------------------------------------------------------+
				//¦ Atualiza dados do corpo da Tabela.                           ¦
				//+--------------------------------------------------------------+
				For ny := 1 to Len(aHeader)
					If aHeader[ny][10] # "V"
						SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
					Endif
				Next ny
				dbUnLock()
				nCntItem:=nCntItem + 1
			EndIf
		Else
			If nX <=	nTotItensFF
				SFF->(DbGoTo(aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "FF_REC_WT" })]))
				RecLock("SFF",.F.)
				SFF->(DbDelete())
				MsUnLock()
			Endif
			nExcMtr ++
		EndIF
	Next nx
	
	If nIncMtr > 0
		//Chamada da função para geração da metrica para inclusão
		M994Mtr("ganancias","inclusão",nIncMtr)
	Endif
	If nExcMtr > 0
		//Chamada da função para geração da metrica para exclusão
		M994Mtr("ganancias","exclusão",nExcMtr)
	Endif
	
	If lAltMtr
		//Chamada da função para geração da metrica para alteração
		M994Mtr("ganancias","alteração",1)
	Endif
	//+--------------------------------------------------------------+
	//¦ Atualizar a Escala Aplicable.                                ¦
	//+--------------------------------------------------------------+
	nCntItem := IIf( nCntItem==0,1,nCntItem)
	For nx := 1 to Len(aColsEscala)
		IF !aColsEscala[nx][Len(aColsEscala[nx])]
			//+--------------------------------------------------------------+
			//¦ Se e um iten novo, incluir-lo , senao so atualizar           ¦
			//+--------------------------------------------------------------+
         If nX > nTotItensEsc
				RecLock("SFF",.T.)
			Else
				SFF->(DbGoTo(aColsEscala[nX][aScan(aHeadEscala,{|x| Alltrim(x[2]) == "FF_REC_WT" })]))
				RecLock("SFF",.F.)
			Endif
  			Replace	FF_FILIAL With xFilial("SFF"),;
			       	FF_NUM    With cTabela,;
					FF_DESDE  With cMesDesde,;
					FF_ATE	  With cMesAte

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do corpo da Tabela.                           ¦
			//+--------------------------------------------------------------+

			For ny := 1 to Len(aHeadEscala)
				If aHeadEscala[ny][10] # "V"
					SFF->(FieldPut(FieldPos(Trim(aHeadEscala[ny][2])),aCOLSEscala[nx][ny]))
				Endif
			Next ny
			MsUnLock()
			nCntItem:=nCntItem + 1
		Else
			If nX <=	nTotItensEsc
				SFF->(DbGoTo(aColsEscala[nX][aScan(aHeadEscala,{|x| Alltrim(x[2]) == "FF_REC_WT" })]))
				RecLock("SFF",.F.)
				SFF->(DbDelete())
				MsUnLock()
			Endif
      EndIF
	Next nx
Endif

Set Filter TO

Return


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Escala   ¦ Autor ¦ José Lucas            ¦ Data ¦ 10/08/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Edicao de Cpos para a Escala Aplicable.                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> Function Escala
Static Function EscalaAlt()
Local nY := 0
Local aHeaderAnt := AClone(aHeader)
Local aCOLSAnt   := AClone(aCOLS)

//+--------------------------------------------------------------+
//¦ Montando aHeader                                             ¦
//+--------------------------------------------------------------+
aHeader:={}

dbSelectArea("SX3")
dbSeek("SFF")
While !Eof() .And. X3_ARQUIVO == "SFF"
	IF (X3USO(X3_USADO) .And. cNivel >= X3_NIVEL .And. Ascan(aYesEscala,Trim(SX3->X3_CAMPO)) != 0)
		Aadd(aHeader,{TRIM(X3TITULO()), X3_CAMPO, X3_PICTURE,X3_TAMANHO,X3_DECIMAL,;
		X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT})
	EndIf
	dbSkip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os campos de Alias e Recno ao aHeader para WalkThru.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ADHeadRec("SFF",aHeader)

//Alterando função de validação do campo FF_ITEM
aHeader[aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ITEM" })][6] := "A994V2Item()"

nCnt := 0
dbSelectArea("SFF")
dbSetOrder(1)
dbSeek(xFilial("SFF")+cTabela)
While !EOF() .And. FF_FILIAL+FF_NUM == xFilial("SFF")+cTabela
	If Val(FF_ITEM) > 12
		nCnt := nCnt + 1
	EndIf
	dbSkip()
End

aCOLS		:=	Array(nCnt,len(aHeader)+1)

//+--------------------------------------------------------------+
//¦ Montando aCols                                               ¦
//+--------------------------------------------------------------+
nCnt := 0
dbSelectArea("SFF")
dbSetOrder(1)
dbSeek(xFilial("SFF")+cTabela)
nPosCFO:= aScan(aHeaderAnt,{|x| Alltrim(x[2]) == "FF_CFO" })
nPosIMP:= aScan(aHeaderAnt,{|x| Alltrim(x[2]) == "FF_IMPORTE" })
nPosIT:= aScan(aHeaderAnt,{|x| Alltrim(x[2]) == "FF_ITEM" })
While !EOF() .And. FF_FILIAL+FF_NUM == xFilial("SFF")+cTabela
	If Val(FF_ITEM) > 12
		nCnt++
		nLAcolsAnt:= aScan(aCOLSAnt,{|x| Alltrim(x[nPosIT]) == FF_ITEM })
		For nY := 1 to Len(aHeader)
			If IsHeadRec(aHeader[nY][2])
				aCols[nCnt][nY] := SFF->(Recno())
			ElseIf IsHeadAlias(aHeader[nY][2])
				aCols[nCnt][nY] := "SFF"
			Else
				If Alltrim(aHeader[nY][2]) $ "FF_CFO" .and. nLAcolsAnt >0
				  	aCols[nCnt][nY]:= aCOLSAnt[nLAcolsAnt][nPosCFO]
				ElseIf Alltrim(aHeader[nY][2]) $ "FF_IMPORTE"  .and. nLAcolsAnt >0
				  	aCols[nCnt][nY]:= aCOLSAnt[nLAcolsAnt][nPosIMP]
				Else
					aCols[nCnt][nY] := &(aHeader[nY][2])
				EndIf
			EndIf
		Next nY
		aCOLS[nCnt][len(aHeader)+1] := .F.
	EndIf
	dbSkip()
End

nTotItensEsc :=	nCnt
cCadastro    := OemToAnsi(STR0036)// "Escala Aplicable (1)"


	@ 0,0 TO 190,600 DIALOG oDlg TITLE cCadastro

    // Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> 	@ 4,5 TO 70,295 MULTILINE MODIFY DELETE VALID Execute(LineOk) FREEZE 1
	@ 4,5 TO 70,295 MULTILINE MODIFY DELETE VALID LineOkAlt() FREEZE 1

    // Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> 	@ 77.5,234 BMPBUTTON TYPE 1 ACTION Execute(oOk)
	@ 77.5,234 BMPBUTTON TYPE 1 ACTION oOk()
    // Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> 	@ 77.5,266 BMPBUTTON TYPE 2 ACTION Execute(oCancel)
	@ 77.5,266 BMPBUTTON TYPE 2 ACTION oCancel()

	ACTIVATE DIALOG oDlg CENTERED

	aHeadEscala := AClone(aHeader)
	aCOLSEscala := AClone(aCOLS)

	aHeader := {}
	aCOLS := {}
	aHeader := AClone(aHeaderAnt)
	aCOLS := AClone(aCOLSAnt)

Return


// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> Function LineOk
Static Function LineOkAlt()
Local nV := 0

lRet	:=	.T.
For nV :=1  to  1
	If !aCOLS[n][Len(aCols[n])].And.Empty(aCols[n][nV])
		Help(" ",1,"OBRIGAT")
		nV		:=	3
		lRet	:=	.F.
	Endif
Next
Return(lRet)


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf014  ¦ Autor ¦ José Lucas            ¦ Data ¦ 10/08/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Exclusao da Tabela de Ganancias/Fondo Cooperativo.         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994Adeleta()

Local cSeek, cWhile
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,AHEADER,CTABELA,CMESDESDE,CMESATE")
SetPrvt("ACOLS,NVALIMPORTE,NTOTALITENS,CTITULO,AC")
SetPrvt("AR,ACGD,CLINHAOK,CTUDOOK,AGETEDIT,NOPCA")
SetPrvt("LRETMOD2,AMES,NI,CMESEXT,ACAB")
SetPrvt("APICTURE,CCADASTRO,OLBX,")

nOpcx:=5

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela   	:= SFF->FF_NUM
cMesDesde 	:= SFF->FF_DESDE
cMesAte   	:= SFF->FF_ATE
nValImporte	:= SFF->FF_IMPORTE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader e aCols                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sintaxe da FillGetDados(nOpcx,cAlias,nOrder,cSeekKey,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry,bCriaVar,lUserFields) |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeek	:= xFilial("SFF")+cTabela
cWhile	:= "FF_FILIAL+FF_NUM"
FillGetDados(nOpcx,"SFF",1,cSeek,{|| &cWhile },{|| .T. },/*aNoFields*/,aYesFields,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bBeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/,/*bCriaVar*/)

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens := len(aCols)

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:= OemToAnsi(STR0051) // "Tabla de Ganancias/Fondo Cooperativo"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!","A994VTabla()",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,.F.})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,.F.})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0055),"@E 999",,,.F.})  // Total de Conceptos

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk:="AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

nOpcA := 0

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,".T.",".T.",,,,SFF->(Reccount())+100)

If lRetMod2

	EscalaDel()

	//+--------------------------------------------------------------+
	//¦ Excluir os registros da tabela  SFF.                         ¦
	//+--------------------------------------------------------------+
	If nOpcA == 1
		dbSelectArea("SFF")
		dbSetOrder(1)
		dbSeek(xFilial("SFF")+cTabela)
		If Found()
			While !Eof() .and. FF_FILIAL+FF_NUM==xFilial("SFF")+cTabela
				RecLock("SFF",.F.)
				dbDelete()
				dbUnLock()
				dbSkip()
			End
		EndIf
	EndIf
EndIf
Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Escala   ¦ Autor ¦ José Lucas            ¦ Data ¦ 10/08/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Edicao de Cpos para a Escala Aplicable.                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> Function Escala
Static Function EscalaDel()
//+--------------------------------------------------------------+
//¦ Montando Array...                                            ¦
//+--------------------------------------------------------------+
Local nCnt := 0
Local aArrEscala := {}

dbSelectArea("SFF")
dbSetOrder(1)
dbSeek(xFilial("SFF")+cTabela)
While !EOF() .And. FF_FILIAL+FF_NUM == xFilial("SFF")+cTabela
	If Val(FF_ITEM) > 12
		nCnt := nCnt + 1
		AADD( aArrEscala,{StrZero(nCnt,2),FF_CFO,FF_FXDE,FF_FXATE,FF_RETENC,FF_PERC,FF_EXCEDE,FF_IMPORTE})
	EndIf
	dbSkip()
End

If ! Empty(aArrEscala)

	aCab := { OemToAnsi(STR0030),; // "Iten"),;
	          OemToAnsi(STR0057),; // "CFO"),;
			  OemToAnsi(STR0031),; // "De más de $"),;
			  OemToAnsi(STR0032),; // "  a $  "),;
			  OemToAnsi(STR0033),; // "  $  "),;
			  OemToAnsi(STR0034),; // "Mas el %"),;
			  OemToAnsi(STR0035),; // "Excedente"),;
			  OemToAnsi(STR0058) } // "Importe") }

	aPicture :=  { "99",;
  				   "@!",;
				   "@E 999,999,999,999.99",;
				   "@E 999,999,999,999.99",;
				   "@E 999,999,999,999.99",;
				   "@E 999.99",;
				   "@E 999,999,999,999.99",;
				   "@E 999,999,999,999.99" }

	cCadastro := OemToAnsi(STR0036)  // "Escala Aplicable (1)"

    @ 0,0 TO 190,600 DIALOG oDlg TITLE cCadastro

    // Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> 		//@ 4,5 TO 70,295 MULTILINE MODIFY DELETE VALID Execute(LineOk) FREEZE 1
	//@ 4,5 TO 70,295 MULTILINE MODIFY DELETE VALID LineOk() FREEZE 1

	oLbx := RDListBox(.6, .4, 291, 60, aArrEscala, aCab,, aPicture)

    // Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> 		@ 77.5,234 BMPBUTTON TYPE 1 ACTION Execute(oOk)
	@ 77.5,234 BMPBUTTON TYPE 1 ACTION oOk()
    // Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> 		@ 77.5,266 BMPBUTTON TYPE 2 ACTION Execute(oCancel)
	@ 77.5,266 BMPBUTTON TYPE 2 ACTION oCancel()

	ACTIVATE DIALOG oDlg CENTERED

EndIf
Return


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf015  ¦ Autor ¦ José Lucas            ¦ Data ¦ 10/08/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validar Numero da Tabela de Ganancias/Fondo Cooperativo.   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994VTabla()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_LRET,")

_lRet := .T.
If Empty(cTabela)
	_lRet := .F.
Else
	SFF->(dbSetOrder(1))
	SFF->(dbSeek(xFilial("SFF")+cTabela))
	If SFF->( Found() )
	   Help(" ",1,"GANF015")
		_lRet := .F.
	EndIf
EndIf
// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> __Return( _lRet )
Return( _lRet )        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf017  ¦ Autor ¦ José Lucas            ¦ Data ¦ 10/08/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validacao da os Itens da Tabela de Ganancias.              ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994V1Item()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_CVAR,_LRET,_NPOS,NTOTALITENS,")

_cVar := M->FF_ITEM
_lRet := .T.

If mv_par01 == 1
	If Empty(_cVar)
		_lRet := .F.
	Else
		_nPos := Ascan(aCOLS,{|x| x[1] == _cVar})
		If _nPos != 0
			If _nPos != n
				Help(" ",1,"GANF017")
				_lRet := .F.
			EndIf
		EndIf

	EndIf
	nTotalItens := Len(aCOLS)
EndIf

// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> __Return( _lRet )
Return( _lRet )        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf018  ¦ Autor ¦ José Lucas            ¦ Data ¦ 10/08/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validacao da os Itens da Escala Aplicable.                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994V2Item()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_CVAR,_LRET,_NPOS,")

_cVar := M->FF_ITEM
_lRet := .T.

If Empty(_cVar)
	_lRet := .F.
Else
	_nPos := Ascan(aCOLS,{|x| x[1] == _cVar})
   If _nPos != 0
		If _nPos != n
		   Help(" ",1,"GANF018")
			_lRet := .F.
		EndIf
	EndIf
EndIf
// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> __Return( _lRet )
Return( _lRet )        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf019  ¦ Autor ¦ Bruno Sobieski        ¦ Data ¦ 30/03/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validaciones generales de GANF010.                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994AlinOk()        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
Local nV := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("LRET,NV,")

lRet	:=	.T.
For nV :=1  to  3
   If !aCOLS[n][Len(aCols[n])].And.Empty(aCols[n][nV])
		Help(" ",1,"OBRIGAT")
		nV		:=	5
		lRet	:=	.F.
	Endif
Next
// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> __Return(lRet)
Return(lRet)        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf051  ¦ Autor ¦ José Lucas            ¦ Data ¦ 23/06/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Visualizacao da Tabela de IVA...								     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994Bvisual()

Local cSeek
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,AHEADER,CTABELA,CMESDESDE,CMESATE")
SetPrvt("NCNT,ACOLS,NTOTALITENS,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2,")

nOpcx:=2

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela := SFF->FF_NUM
cMesDesde := SFF->FF_DESDE
cMesAte := SFF->FF_ATE
cImp      := SFF->FF_IMPOSTO

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
cSeek := xFilial("SFF")+cImp
nTotalItens := MyFillGet(nOpcx,3,cSeek)

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:= OemToAnsi(STR0059) // "Tabla de Impuesto sobre Valor Agregado"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!"      ,".T.",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,.F.})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,.F.})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk:="AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,".T.",".T.",,,,SFF->(Reccount())+100)

Return


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf052  ¦ Autor ¦ José Lucas            ¦ Data ¦ 25/03/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Inclusao de la Tabla de Impuesto de Valor Agregado.        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994Binclui()
Local nY := 0
Local nX := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,AHEADER,ACOLS,CTABELA,CMESDESDE")
SetPrvt("CMESATE,CPLANILLA,NTOTALITENS,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2,NMAXARRAY")
SetPrvt("NY,NCNTITEM,NX,CVAR,AROTINA,")

nOpcx:=3

//+--------------------------------------------------------------+
//¦ Inicializar o proximo numero da Tabela.                      ¦
//+--------------------------------------------------------------+
dbSelectArea("SFF")
dbSetOrder(3)
dbSeek(xFilial("SFF")+"IV")
If Found()
	MsgBox( OemToAnsi(STR0061),OemToAnsi(STR0050),STR0180 ) //"Atencion" - "INFO"
	Return
EndIf

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela   := "000001"
cMesDesde := Space(04)
cMesAte   := Space(04)

cPlanilla := OemToAnsi(STR0063) // "IVA"

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens := MyFillGet(nOpcx)

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:= OemToAnsi(STR0062) // "Tabla de Impuesto de Valor Agregado - IVA"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!","A994VTabla()",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk:="AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou
lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,".T.",".T.",,,,SFF->(Reccount())+100)

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente
If lRetMod2

	//+--------------------------------------------------------------+
	//¦ Atualiza o Corpo da Tabela                                   ¦
	//+--------------------------------------------------------------+
	dbSelectArea("SFF")
	nMaxArray := Len(aCols)
	For ny := 1 to Len(aHeader)
		If Empty(aCols[nMaxArray][ny]) .AND. Trim(aHeader[ny][2]) == "FF_IMPOSTO"
			nMaxArray := nMaxArray - 1
			Exit
		EndIf
	Next ny

	nCntItem:= 1
	For nx := 1 to nMaxArray
		IF !aCols[nx][Len(aCols[nx])]

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do tabela.                                    ¦
			//+--------------------------------------------------------------+
			dbSelectArea("SFF")
			RecLock("SFF",.T.)
			Replace FF_FILIAL  With xFilial("SFF"),;
			       	FF_NUM     With cTabela,;
					FF_DESDE   With cMesDesde,;
					FF_ATE	   With cMesAte

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do corpo da Tabela.                           ¦
			//+--------------------------------------------------------------+
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
				Endif
			Next ny
		    dbUnLock()

			nCntItem:=nCntItem + 1
		EndIF
	Next nx

Endif
//+-------------------------------------------------------+
//¦ Forçar o array aRotina para dribar a funcao ExecBrow. ¦
//+-------------------------------------------------------+
aRotina[3][4] := 0

Return


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf053  ¦ Autor ¦ José Lucas            ¦ Data ¦ 26/03/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Alteracao da Tabela de IVA...                              ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994Baltera()
Local nX := 0
Local nY := 0
Local cSeek
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,AHEADER,CTABELA,CMESDESDE,CMESATE")
SetPrvt("CPLANILLA,NCNT,ACOLS,NTOTALITENS,NTOTITENSFF")
SetPrvt("CTITULO,AC,AR,ACGD,CLINHAOK,CTUDOOK")
SetPrvt("AGETEDIT,LRETMOD2,NMAXARRAY,NY,NCNTITEM,NX")
SetPrvt("CVAR,")

nOpcx:=4

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela   := SFF->FF_NUM
cMesDesde := SFF->FF_DESDE
cMesAte   := SFF->FF_ATE
cImp	  :=  SFF->FF_IMPOSTO

cPlanilla := OemToAnsi(STR0063) // "IVA"

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
cSeek := xFilial("SFF")+cImp
nTotalItens := MyFillGet(nOpcx,3,cSeek)
nTotItensFF := nTotalItens

//Alterando função de validação do campo FF_IMPOSTO
aHeader[aScan(aHeader,{|x| Alltrim(x[2]) == "FF_IMPOSTO" })][6] := "A994BlinOk(1)"

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:= OemToAnsi(STR0059) // "Tabla de Impuesto sobre Valor Agregado"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!","A994VTabla()",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,.T.})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,.T.})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
//cLinhaOk:="A994BlinOk(2)"
cLinhaOk:= "AlwaysTrue()"
cLinhaOk:= "AlwaysTrue()"

cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou
lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,".T.",,,,SFF->(Reccount())+100)

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente
If lRetMod2

	nIncMtr := 0
	nExcMtr := 0
	lAltMtr := .F.

   nCntItem:= 1
   For nx := 1 to Len(aCols)
		IF !aCols[nx][Len(aCols[nx])]
			//+--------------------------------------------------------------+
			//¦ Se e um iten novo, incluir-lo , senao so atualizar           ¦
			//+--------------------------------------------------------------+
         	If nX > nTotItensFF
				RecLock("SFF",.T.)
				nIncMtr ++
			Else
				SFF->(DbGoTo(aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "FF_REC_WT" })]))
				RecLock("SFF",.F.)
				lAltMtr := .T.
			Endif
			Replace FF_FILIAL  With xFilial("SFF"),;
			       	FF_NUM     With cTabela,;
					FF_DESDE   With cMesDesde,;
					FF_ATE	   With cMesAte
            //+--------------------------------------------------------------+
			//¦ Atualiza dados do corpo da Tabela.                           ¦
			//+--------------------------------------------------------------+
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
				Endif
			Next ny
		    MsUnLock()
			nCntItem:=nCntItem + 1
		Else
			If nX <=	nTotItensFF
				SFF->(DbGoTo(aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "FF_REC_WT" })]))
				RecLock("SFF",.F.)
				SFF->(DbDelete())
				MsUnLock()
			Endif
			nExcMtr ++
		Endif
	Next nX
	
	If nIncMtr > 0
		//Chamada da função para geração da metrica para inclusão
		M994Mtr("iva","inclusão",nIncMtr)
	Endif
	If nExcMtr > 0
		//Chamada da função para geração da metrica para exclusão
		M994Mtr("iva","exclusão",nExcMtr)
	Endif
	If lAltMtr
		//Chamada da função para geração da metrica para alteração
		M994Mtr("iva","alteração",1)
	Endif
Endif

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf014  ¦ Autor ¦ José Lucas            ¦ Data ¦ 26/03/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Exclusao da Tabela de IVA...                               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994Bdeleta()

Local cSeek
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,AHEADER,CTABELA,CMESDESDE,CMESATE")
SetPrvt("NCNT,ACOLS,NTOTALITENS,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2,")

nOpcx:=5

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela	  := SFF->FF_NUM
cMesDesde := SFF->FF_DESDE
cMesAte   := SFF->FF_ATE
cImp      := SFF->FF_IMPOSTO

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
cSeek := xFilial("SFF")+cImp
nTotalItens	:= MyFillGet(nOpcx,3,cSeek)

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:= OemToAnsi(STR0059) // "Tabla de Impuesto sobre Valor Agregado"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!"      ,".T.",,.F.}) // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,.F.}) // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,.F.}) // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk:="AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,".T.",".T.",,,,SFF->(Reccount())+100)

If lRetMod2

	//+--------------------------------------------------------------+
	//¦ Excluir os registros da tabela  SFF.                         ¦
	//+--------------------------------------------------------------+
	dbSelectArea("SFF")
	dbSetOrder(3)
	dbSeek(xFilial("SFF")+cImp)
	If Found()
		While !EOF() .And. FF_FILIAL+FF_IMPOSTO == xFilial("SFF")+cImp
			RecLock("SFF",.F.)
			dbDelete()
			dbUnLock()
			dbSkip()
		End
	EndIf
EndIf

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf057  ¦ Autor ¦ José Lucas            ¦ Data ¦ 25/03/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validacao da Coluna de CFO nas Planillas IVA e IB...       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function Ganf057()        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_LRET,CIMPOSTO,CSERIENF,CZONAFIS,NPOSIMPOS,NPOSSERIE")
SetPrvt("NPOSZONFIS,NPOSDESCR,_CVAR,ACOLS,NTOTALITENS,")

_lRet := .T.

cImposto := " "
cSerieNF := " "
cZonaFis := " "

nPosImpos := 0
nPosSerie := 0
nPosZonFis := 0

nPosDescr := ASCAN(aHeader,{|x| x[2] == "FF_CONCEPT"})

If cPlanilla == "IB "
	nPosImpos  := ASCAN(aHeader,{|x| x[2] == "FF_IMPOSTO"})
	nPosZonFis := ASCAN(aHeader,{|x| x[2] == "FF_ZONFIS "})
ElseIf cPlanilla == "IVA"
	nPosImpos := ASCAN(aHeader,{|x| x[2] == "FF_IMPOSTO"})
	nPosSerie := ASCAN(aHeader,{|x| x[2] == "FF_SERIENF"})
EndIf

_cVar := M->FF_CFO

If Empty(_cVar)
	_lRet := .F.
Else

   SX5->( dbSeek(xFilial("SX5")+"13"+_cVar) )
	If SX5->( Found() )
		If cPlanilla != "GAN"
  			If nPosDescr > 0
				aCOLS[n][nPosDescr] := SX5->X5_DESCRI
			EndIf
		EndIf
	Else
		MsgBox(OemToAnsi(STR0064),OemToAnsi(STR0050),STR0180) //"Atencion" - "INFO"
		_lRet := .F.
	EndIf

	If cPlanilla == "IVA"
		If ( nPosImpos > 0 .and. nPosSerie > 0 )
			cImposto := aCOLS[n][nPosImpos]
			cSerieNF := aCOLS[n][nPosSerie]

			SFF->( dbSetOrder(3) )
			SFF->( dbSeek(xFilial("SFF")+cImposto+cSerieNF+_cVar) )
			If SFF->( Found() )
                // "Impuesto ya ingresado...", "Atencion"
				MsgBox(OemToAnsi(STR0065),OemToAnsi(STR0050),STR0180) //"INFO"
				_lRet := .F.
			EndIf
		EndIf
	ElseIf cPlanilla == "IB "
		If ( nPosImpos > 0 .and. nPosZonFis > 0 )
			cImposto := aCOLS[n][nPosImpos]
			cZonaFis := aCOLS[n][nPosZonFis]

			SFF->( dbSetOrder(4) )
			SFF->( dbSeek(xFilial("SFF")+cImposto+cZonaFis+_cVar) )
			If SFF->( Found() )

				MsgBox(OemToAnsi(STR0065),OemToAnsi(STR0050),STR0180)// "Impuesto ya ingresado...", "Atencion" "INFO"
				_lRet := .F.
			EndIf
		EndIf
	Endif

EndIf
nTotalItens := Len(aCOLS)
If ! _lRet .AND. cPlanilla#"GAN"
	aCOLS[n][nPosDescr] := " "
EndIf
// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> __Return( _lRet )
Return( _lRet )        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf058  ¦ Autor ¦ Bruno Sobieski        ¦ Data ¦ 30/03/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validaciones generales de GANF050.                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994BlinOk( nParam)
Local nV := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("LRET,NV,")

lRet	:=	.T.
Do Case
Case nParam	==	1 //VALIDA CAMPO FF_IMPOSTO
	If (Subs(M->FF_IMPOSTO,1,2)#'IV')
		//MsgStop("El código de Impuesto debe comenzar con 'IV'")
		MsgStop(OemToAnsi(STR0066))
		lRet	:=	.F.
	Endif
Case nParam	==	2 // Valida LINHAOK
	For nV :=1  to  5
		If !aCOLS[n][Len(aCols[n])].And.Empty(aCols[n][nV])
			Help(" ",1,"OBRIGAT")
			nV		:=	5
			lRet	:=	.F.
		Endif
	Next
EndCase
// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> __Return(lRet)
Return(lRet)        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf101  ¦ Autor ¦ José Lucas            ¦ Data ¦ 26/03/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Visualizacao da Tabela de Ingresos Brutos...					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
31/07/99 jose luis - Trata de CFO Compras e Vendas
*/
Function A994Cvisual()
Local cSeek  := cSeek := xFilial("SFF")+"IB"
Local cWhile := "FF_FILIAL+Substr(FF_IMPOSTO,1,2)"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,AHEADER,CTABELA,CMESDESDE,CMESATE")
SetPrvt("NCNT,ACOLS,NTOTALITENS,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2,")

nOpcx:=2

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela   := SFF->FF_NUM
cMesDesde := SFF->FF_DESDE
cMesAte   := SFF->FF_ATE

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens := MyFillGet(nOpcx,4,cSeek,cWhile)

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:= OemToAnsi(STR0068) // "Tabla de Ingresos Brutos"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!"      ,".T.",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,.F.})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,.F.})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk:="AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,".T.",".T.",,,,SFF->(Reccount())+100)

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf102  ¦ Autor ¦ José Lucas            ¦ Data ¦ 25/03/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Inclusao de la Tabla de Ingresos Brutos.                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
30/07/99 jose luis - tratamiento de CFO Compras e Vendas
*/
Function A994Cinclui()
Local nX := 0
Local nY := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,AHEADER,ACOLS,CTABELA,CMESDESDE")
SetPrvt("CMESATE,CPLANILLA,NTOTALITENS,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2,NMAXARRAY")
SetPrvt("NY,NCNTITEM,NX,CVAR,AROTINA,")


// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _M2_ATUALIZA  3
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _ZONFIS       "FF_ZONFIS"

nOpcx:=_M2_ATUALIZA

//+--------------------------------------------------------------+
//¦ Inicializar o proximo numero da Tabela.                      ¦
//+--------------------------------------------------------------+
dbSelectArea("SFF")
dbSetOrder(4)
dbSeek(xFilial("SFF")+"IB")
If Found()
	MsgBox(OemToAnsi(STR0067),OemToAnsi(STR0050),STR0180 ) //"Atencion" - "INFO"
	Return
EndIf

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela   := "000001"
cMesDesde := Space(04)
cMesAte   := Space(04)
cPlanilla := "IB "

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens := MyFillGet(nOpcx)

//Alterando função de validação do campo FF_IMPOSTO
aHeader[aScan(aHeader,{|x| Alltrim(x[2]) == "FF_IMPOSTO" })][6] := "A994ClinOk(1)"

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:= OemToAnsi(STR0068) // "Tabla de Ingresos Brutos"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!","A994VTabla()",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk:="AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,".T.",".T.",,,,SFF->(Reccount())+100)

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente
If lRetMod2

	//+--------------------------------------------------------------+
	//¦ Atualiza o Corpo da Tabela                                   ¦
	//+--------------------------------------------------------------+
	dbSelectArea("SFF")
	nMaxArray := Len(aCols)
	For ny := 1 to Len(aHeader)
		If Empty(aCols[nMaxArray][ny]) .AND. Trim(aHeader[ny][2]) == "FF_IMPOSTO"
			nMaxArray := nMaxArray - 1
			Exit
		EndIf
	Next ny

	nCntItem:= 1
	For nx := 1 to nMaxArray
		IF !aCols[nx][Len(aCols[nx])]

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do tabela.                                    ¦
			//+--------------------------------------------------------------+
			dbSelectArea("SFF")
			RecLock("SFF",.T.)
			Replace FF_FILIAL  With xFilial("SFF"),;
			       	FF_NUM     With cTabela,;
					FF_DESDE   With cMesDesde,;
					FF_ATE	   With cMesAte

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do corpo da Tabela.                           ¦
			//+--------------------------------------------------------------+
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
				Endif
			Next ny
		    dbUnLock()

			nCntItem:=nCntItem + 1
		EndIF
	Next nx

Endif
//+-------------------------------------------------------+
//¦ Forçar o array aRotina para dribar a funcao ExecBrow. ¦
//+-------------------------------------------------------+
aRotina[3][4] := 0

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf103  ¦ Autor ¦ José Lucas            ¦ Data ¦ 26/03/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Alteracao da Tabela de Ingresos Brutos...                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
30/07/99 - jose luis - tratamiento de CFO Compras y ventas
*/
Function A994Caltera()
Local nX := 0
Local nY := 0
Local cSeek  := xFilial("SFF")+"IB"
Local cWhile := "FF_FILIAL+Substr(FF_IMPOSTO,1,2)"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,AHEADER,CTABELA,CMESDESDE,CMESATE")
SetPrvt("CPLANILLA,NCNT,ACOLS,NTOTALITENS,NTOTITENSFF")
SetPrvt("CTITULO,AC,AR,ACGD,CLINHAOK,CTUDOOK")
SetPrvt("AGETEDIT,LRETMOD2,NMAXARRAY,NY,NCNTITEM,NX")
SetPrvt("CVAR,")

nOpcx:=4

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela   := SFF->FF_NUM
cMesDesde := SFF->FF_DESDE
cMesAte   := SFF->FF_ATE
cPlanilla := "IB "

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens := MyFillGet(nOpcx,4,cSeek,cWhile)
nTotItensFF := nTotalItens

//Alterando função de validação do campo FF_IMPOSTO
aHeader[aScan(aHeader,{|x| Alltrim(x[2]) == "FF_IMPOSTO" })][6] := "A994ClinOk(1)"

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:=OemToAnsi(STR0068)  // "Tabla de Ingresos Brutos"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!","A994VTabla()",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,.T.})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,.T.})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
//cLinhaOk:="A994ClinOk(2)"
cLinhaOk:= "AlwaysTrue()
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou
lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,".T.",,,,SFF->(Reccount())+100)

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente
If lRetMod2
	
	nIncMtr := 0
	nExcMtr := 0
	lAltMtr := .F.
	
	nCntItem:= 1
    For nx := 1 to Len(aCols)
		IF !aCols[nx][Len(aCols[nx])]
			//+--------------------------------------------------------------+
			//¦ Se e um iten novo, incluir-lo , senao so atualizar           ¦
			//+--------------------------------------------------------------+
         	If nX > nTotItensFF
				RecLock("SFF",.T.)
				nIncMtr ++
			Else
				SFF->(DbGoTo(aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "FF_REC_WT" })]))
				RecLock("SFF",.F.)
				lAltMtr := .T.
			Endif
			Replace FF_FILIAL  With xFilial("SFF"),;
			       	FF_NUM     With cTabela,;
					FF_DESDE   With cMesDesde,;
					FF_ATE	   With cMesAte

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do corpo da Tabela.                           ¦
			//+--------------------------------------------------------------+
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
				Endif
			Next ny
		    MsUnLock()
            nCntItem := nCntItem + 1
  		Else
			If nX <=	nTotItensFF
				SFF->(DbGoTo(aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "FF_REC_WT" })]))
				RecLock("SFF",.F.)
				SFF->(DbDelete())
				MsUnLock()
			Endif
			nExcMtr ++
		Endif
	Next nX
	
	If nIncMtr > 0
		//Chamada da função para geração da metrica para inclusão
		M994Mtr("ib","inclusão",nIncMtr)
	Endif
	If nExcMtr > 0
		//Chamada da função para geração da metrica para exclusão
		M994Mtr("ib","exclusão",nExcMtr)
	Endif
	If lAltMtr
		//Chamada da função para geração da metrica para alteração
		M994Mtr("ib","alteração",1)
	Endif
	
Endif

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf104  ¦ Autor ¦ José Lucas            ¦ Data ¦ 26/03/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Exclusao da Tabela de Ingresos Brutos...                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
30/07/99 - jose luis - tratamiento de CFO Compras y ventas

*/
Function A994Cdeleta()

Local cSeek  := xFilial("SFF")+"IB"
Local cWhile := "FF_FILIAL+Substr(FF_IMPOSTO,1,2)"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,AHEADER,CTABELA,CMESDESDE,CMESATE")
SetPrvt("NCNT,ACOLS,NTOTALITENS,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2,")

nOpcx:=5

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela := SFF->FF_NUM
cMesDesde := SFF->FF_DESDE
cMesAte := SFF->FF_ATE

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens := MyFillGet(nOpcx,4,cSeek,cWhile)

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:=OemToAnsi(STR0068)  // "Tabla de Ingresos Brutos"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!"      ,".T.",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,.F.})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,.F.})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk:="AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,".T.",".T.",,,,SFF->(Reccount())+100)

If lRetMod2

	//+--------------------------------------------------------------+
	//¦ Excluir os registros da tabela  SFF.                         ¦
	//+--------------------------------------------------------------+
	dbSelectArea("SFF")
	dbSetOrder(4)
	dbSeek(xFilial("SFF")+"IB")
	If Found()
		While !Eof() .and. FF_FILIAL+Subs(FF_IMPOSTO,1,2)==xFilial("SFF")+"IB"
			RecLock("SFF",.F.)
			dbDelete()
			dbUnLock()
			dbSkip()
		End
	EndIf
EndIf

Return


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf108  ¦ Autor ¦ Bruno Sobieski        ¦ Data ¦ 30/03/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validaciones generales de GANF100.                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994ClinOk( cParam)
Local nV := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("LRET,NV,")

lRet	:=	.T.
Do Case
Case cParam	==	1 //VALIDA CAMPO FF_IMPOSTO
  If (Subs(M->FF_IMPOSTO,1,2)#'IB') .and. (Subs(M->FF_IMPOSTO,1,2)#'CM') .and. (Subs(M->FF_IMPOSTO,1,2)#'CP')
      MsgStop(OemToAnsi(STR0129))
      lRet    :=      .F.
   Endif
Case cParam	==	2  // Valida LINHAOK
   For nV :=1  to  5
      If nV <> 2     //Zona Fiscal no es obligatorio.
         If !aCOLS[n][Len(aCols[n])].And.Empty(aCols[n][nV])
            Help(" ",1,"OBRIGAT")
            nV   := 5
            lRet := .F.
         Endif
      Endif
   Next
	If !aCOLS[n][Len(aCols[n])] .And. Empty(aCols[n][08])
    	Help(" ",1,"OBRIGAT")
        nV   := 5
        lRet := .F.
 	Endif
EndCase
// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> __Return(lRet)
Return(lRet)        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994STX  ¦ Autor ¦ Ronny Ctvrtnik        ¦ Data ¦ 05/09/00 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Cadastro de Tabela de Sales Tax. (imposto de venda)        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994STX()
	Private cCodImp
	SetPrvt("AROTINA,CCADASTRO,")
	cCadastro := OemToAnsi(STR0075)  // Planilla de Ganancias/Fondo Cooperativo

	aYesFields := {"FF_NUM","FF_ZONFIS","FF_ALIQ","FF_CFO_C","FF_CFO_V","FF_CONCEPT"}

	aRotina := MenuDef()

	dbSelectArea("SFF")
	dbSetOrder(1)
	dbGoTop()
	mBrowse( 6, 1, 22, 75, "SFF")
	dbSelectArea("SFF")
	dbClearFilter()
	dbSetOrder(1)
Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994DVisual  ¦ Autor ¦ Ronny Ctvrtnik    ¦ Data ¦ 20/09/00 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Visualizacao da Tabela de Ganancias/Fondo Cooperativo.     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994DVisual()

	Local cSeek, cWhile

	SetPrvt("NOPCX,,CTABELA,CMESREF,CMESEXT")
	SetPrvt("NCNT,NVALIMPORTE,CTITULO,AC")
	SetPrvt("AR,ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2")
	SetPrvt("AMES,NI,ACAB,APICTURE,CCADASTRO")
	SetPrvt("OLBX,NOPCA,")
	//
	nOpcx:=2

	Private aHeader	:={}
	Private aCols		:={}

	cTabela := SFF->FF_IMPOSTO
	nValImporte := SFF->FF_IMPORTE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader e aCols                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sintaxe da FillGetDados(nOpcx,cAlias,nOrder,cSeekKey,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry,bCriaVar,lUserFields) |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSeek	:= xFilial("SFF")+cTabela
	cWhile	:= "FF_FILIAL+FF_IMPOSTO"
	FillGetDados(nOpcx,"SFF",3,cSeek,{|| &cWhile },{|| .T. },/*aNoFields*/,aYesFields,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bBeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/,/*bCriaVar*/)

	aC := {{"cTabela"  ,{15,10} ,OemToAnsi(STR0052),"@!","A994DVlTab()",,.T.}}  //"Nr. Tabla"
	//+--------------------------------------------------------------+
	//¦ Variaveis do Rodape do Modelo 2                              ¦
	//+--------------------------------------------------------------+

	//+--------------------------------------------------------------+
	//¦ Titulo da Janela                                             ¦
	//+--------------------------------------------------------------+
	cTitulo:= OemToAnsi(STR0076)  // "Ganancias/Fondo Cooperativo"

	//+--------------------------------------------------------------+
	//¦ Array com coordenadas da GetDados no modelo2                 ¦
	//+--------------------------------------------------------------+
	aCGD:={44,5,118,315}

	//+--------------------------------------------------------------+
	//¦ Validacoes na GetDados da Modelo 2                           ¦
	//+--------------------------------------------------------------+
	cLinhaOk:="AlwaysTrue()"
	cTudoOk :="AlwaysTrue()"

	aGetEdit := {}

	//+--------------------------------------------------------------+
	//¦ Chamada da Modelo2                                           ¦
	//+--------------------------------------------------------------+
	// lRetMod2 = .t. se confirmou
	// lRetMod2 = .f. se cancelou

	lRetMod2:=Modelo2(cTitulo,aC,{},aCGD,nOpcx,".T.",".T.",,,,SFF->(Reccount())+100)
	SFF->(dbgotop())

	If lRetMod2
		//+--------------------------------------------------------------+
		//¦ Edicao e Visualizacao da Escala Aplicable (1).               ¦
		//+--------------------------------------------------------------+
	EndIf
	SFF->(dbgotop())
Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994DInclui  ¦ Autor ¦ Ronny Ctvrtnik    ¦ Data ¦ 21/09/00 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Inclusao da Tabela de Ganancias/Fondo Cooperativo.         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994Dinclui()
	Local nY := 0
	Local nC := 0
	Local nX := 0
	Local cSeek, cWhile
	SetPrvt("NOPCX,ACONCEPTOS,AHEADER,ACOLS,NI")
	SetPrvt("CTABELA,CMESDESDE,CMESATE,CPLANILLA,NTOTALITENS,CTITULO")
	SetPrvt("AC,AR,ACGD,CLINHAOK,CTUDOOK,AGETEDIT")
	SetPrvt("LRETMOD2,NOPCA,NMAXARRAY,NY,NCNTITEM,NX")
	SetPrvt("CVAR,AROTINA,AHEADERANT,ACOLSANT,CCADASTRO,AHEADESCALA")
	SetPrvt("ACOLSESCALA,")

	nOpcx	:= 3
	cTabela	:= Space(3)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader e aCols                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sintaxe da FillGetDados(nOpcx,cAlias,nOrder,cSeekKey,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry,bCriaVar,lUserFields) |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSeek	:= xFilial("SFF")+cTabela
	cWhile	:= "FF_FILIAL+FF_IMPOSTO"
	FillGetDados(nOpcx,"SFF",3,cSeek,{|| &cWhile },{|| .T. },/*aNoFields*/,aYesFields,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,.T.,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bBeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/,/*bCriaVar*/)

	//Inicializando o primeiro o item do aCols
	//aCols[1][Ascan(aHeader,{|x| AllTrim(x[2]) == "FF_NUM"})] := StrZero(1,StrZero(nI,TAMSX3("FF_NUM")[1]))

	cTabela := Space(3)
	nTotalItens:=0
	cTitulo:= OemToAnsi(STR0076) // "Tabla de Ganancias/Fondo Cooperativo"
	cCodigo := Space(6)
	aC := {{"cTabela"  ,{15,10} ,OemToAnsi(STR0052),"@!","A994DVlTab()",,.T.}}  //"Nr. Tabla"
	aCGD := {44,5,118,315}
//	cLinhaOk:="A994DlinOk()",
  	cLinhaOk:= "AlwaysTrue()
	cTudoOk :="AlwaysTrue()"
	aGetEdit := {}
	aR := {{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.}}  // Total de Items
	dbSelectArea("SFF")
	lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,".T.",,,,SFF->(Reccount())+100)
	If lRetMod2
		nMaxArray := Len(aCols)
		For ny := 1 to Len(aHeader)
			If Empty(aCols[nMaxArray][ny]) .AND. Trim(aHeader[ny][2]) == "FF_ITEM"
				nMaxArray := nMaxArray - 1
				Exit
			EndIf
		Next ny
		nCntItem:= 1
		For nx := 1 to nMaxArray
			IF !aCols[nx][Len(aCols[nx])]
				dbSelectArea("SFF")
				RecLock("SFF",.T.)

				//+--------------------------------------------------------------+
				//¦ Atualiza dados do corpo da Tabela.                           ¦
				//+--------------------------------------------------------------+
				For ny := 1 to Len(aHeader)
					If aHeader[ny][10] # "V"
						SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
					Endif
				Next ny

				Replace FF_FILIAL With xFilial("SFF"),;
						  FF_IMPOSTO WITH cTabela,;
						  FF_ITEM With cCodImp

			   dbUnLock()
			   nCntItem:=nCntItem + 1
			EndIF
		Next nx
	ENDIF
	SFF->(DbSetOrder(1))
	aRotina[3][4] := 0
	SFF->(dbgotop())
Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994DVlTab      Autor ¦ Ronny Ctvrtnik   ¦ Data ¦ 22/09/00 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Visualizacao da Tabela de Ganancias/Fondo Cooperativo.     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994DVlTab()
	nOrder := SFF->(IndexOrd())
	SFF->(dbSetOrder(3))
	bool := !SFF->(dbseek(xfilial("SFF") + cTabela))
	if !bool
		   Help(" ",1,"JAGRAVADO")
	Endif
	dbSelectArea("SFB")
	dbSetOrder(1)
	If !dbSeek(xFilial("SFB")+cTabela)
	     Help(" ",1,"NAOGRAVADO")
	     bool = .F.
	Else
		cCodImp = StrZero(Val(SFB->FB_CPOLVRO),2)
	Endif
	dbSelectArea("SFF")
	SFF->(dbSetOrder(nOrder))
Return(bool)

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦*-----------------------------------------------------------------------*¦¦
¦¦¦Funçào    ¦ A994StxVlCod    Autor ¦ Ronny Ctvrtnik   ¦ Data ¦ 31/01/01 ¦¦¦
¦¦*----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validação da digitacao do codigo do imposto.               ¦¦¦
¦¦*-----------------------------------------------------------------------*¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994StxVlCod()
	nOrder := SFF->(IndexOrd())
	SFF->(dbSetOrder(1))
	bool := !SFF->(dbseek(xfilial("SFF") + cCodigo))
	If !bool
		   Help(" ",1,"JAGRAVADO")
	Endif
	SFF->(dbSetOrder(nOrder))
Return(bool)

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994DAltera  ¦ Autor ¦ Ronny Ctvrtnik    ¦ Data ¦ 22/09/00 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Visualizacao da Tabela de Ganancias/Fondo Cooperativo.     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994DAltera()
	Local nX := 0
	Local nY := 0
	Local cSeek, cWhile
	SetPrvt("NOPCX,ALISTCPO,AHEADER,CTABELA,CMESREF,CMESEXT")
	SetPrvt("NCNT,ACOLS,NVALIMPORTE,CTITULO,AC")
	SetPrvt("AR,ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2")
	SetPrvt("AMES,NI,ACAB,APICTURE,CCADASTRO")
	SetPrvt("OLBX,NOPCA,")
	//
	nOpcx:=4

	cTabela := SFF->FF_IMPOSTO
	nOrder := SFF->(IndexOrd())
	dbSelectArea("SFB")
	dbSetOrder(1)
	If dbSeek(xFilial("SFB")+cTabela)
		cCodImp = StrZero(Val(SFB->FB_CPOLVRO),2)
	Else
		cCodImp = "00"
	Endif

	dbSelectArea("SFF")
	SFF->(dbSetOrder(nOrder))
	nValImporte := SFF->FF_IMPORTE
	aCols := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader e aCols                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sintaxe da FillGetDados(nOpcx,cAlias,nOrder,cSeekKey,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry,bCriaVar,lUserFields) |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSeek	:= xFilial("SFF")+cTabela
	cWhile	:= "FF_FILIAL+FF_IMPOSTO"
	FillGetDados(nOpcx,"SFF",3,cSeek,{|| &cWhile },{|| .T. },/*aNoFields*/,aYesFields,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bBeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/,/*bCriaVar*/)

	aC := {{"cTabela"  ,{15,10} ,OemToAnsi(STR0052),"@!","A994DVlTab()",,.F.}}  //"Nr. Tabla"
	//+--------------------------------------------------------------+
	//¦ Variaveis do Rodape do Modelo 2                              ¦
	//+--------------------------------------------------------------+
	nTotItens := len(aCols)
	//+--------------------------------------------------------------+
	//¦ Titulo da Janela                                             ¦
	//+--------------------------------------------------------------+
	cTitulo:= OemToAnsi(STR0076)  // "Ganancias/Fondo Cooperativo"
	//+--------------------------------------------------------------+
	//¦ Array com coordenadas da GetDados no modelo2                 ¦
	//+--------------------------------------------------------------+
	aCGD:={44,5,118,315}

	//+--------------------------------------------------------------+
	//¦ Validacoes na GetDados da Modelo 2                           ¦
	//+--------------------------------------------------------------+
//	cLinhaOk:="A994DlinOk()"
  	cLinhaOk:= "AlwaysTrue()
	cTudoOk :="AlwaysTrue()"
	aGetEdit := {}
	lRetMod2:=Modelo2(cTitulo,aC,{},aCGD,nOpcx,cLinhaOk,".T.",,,,SFF->(Reccount())+100)
	SFF->(dbgotop())
	If lRetMod2
		nCntItem:= 1
	    For nx := 1 to Len(aCols)
			IF !aCols[nx][Len(aCols[nx])]
				//+--------------------------------------------------------------+
				//¦ Se e um iten novo, incluir-lo , senao so atualizar           ¦
				//+--------------------------------------------------------------+
				If nX > nTotItens
					RecLock("SFF",.T.)
				Else
					SFF->(DbGoTo(aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "FF_REC_WT" })]))
					RecLock("SFF",.F.)
				Endif
				//+--------------------------------------------------------------+
				//¦ Atualiza dados do corpo da Tabela.                           ¦
				//+--------------------------------------------------------------+
				For ny := 1 to Len(aHeader)
					If aHeader[ny][10] # "V"
						SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
					Endif
				Next ny
				Replace FF_IMPOSTO  With cTabela
				dbUnLock()
				nCntItem:=nCntItem + 1
			Else
				If nX <=	nTotItens
					SFF->(DbGoTo(aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "FF_REC_WT" })]))
					RecLock("SFF",.F.)
					SFF->(DbDelete())
					MsUnLock()
				Endif
			EndIF
		Next nx
	Endif
	SFF->(dbgotop())
Return

/*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994Ddeleta  ¦ Autor ¦ Ronny Ctvrtnik    ¦ Data ¦ 22/09/00 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Delecao da Tabela de Ganancias/Fondo Cooperativo.          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994Ddeleta()
	Local nX := 0
	Local cSeek, cWhile

	SetPrvt("NOPCX,ALISTCPO,AHEADER,CTABELA,CMESREF,CMESEXT")
	SetPrvt("NCNT,ACOLS,NVALIMPORTE,CTITULO,AC")
	SetPrvt("AR,ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2")
	SetPrvt("AMES,NI,ACAB,APICTURE,CCADASTRO")
	SetPrvt("OLBX,NOPCA,")
	//
	nOpcx:=5

	cTabela := SFF->FF_IMPOSTO
	nValImporte := SFF->FF_IMPORTE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aHeader e aCols                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sintaxe da FillGetDados(nOpcx,cAlias,nOrder,cSeekKey,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry,bCriaVar,lUserFields) |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSeek	:= xFilial("SFF")+cTabela
	cWhile	:= "FF_FILIAL+FF_IMPOSTO"
	FillGetDados(nOpcx,"SFF",3,cSeek,{|| &cWhile },{|| .T. },/*aNoFields*/,aYesFields,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,/*lEmpty*/,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bBeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/,/*bCriaVar*/)

	aC := {{"cTabela"  ,{15,10} ,OemToAnsi(STR0052),"@!","A994DVlTab()",,.T.}}  //"Nr. Tabla"
	//+--------------------------------------------------------------+
	//¦ Variaveis do Rodape do Modelo 2                              ¦
	//+--------------------------------------------------------------+
	nTotItens := len(aCols)
	//+--------------------------------------------------------------+
	//¦ Titulo da Janela                                             ¦
	//+--------------------------------------------------------------+
	cTitulo:= OemToAnsi(STR0076)  // "Ganancias/Fondo Cooperativo"
	//+--------------------------------------------------------------+
	//¦ Array com coordenadas da GetDados no modelo2                 ¦
	//+--------------------------------------------------------------+
	aCGD:={44,5,118,315}
	//+--------------------------------------------------------------+
	//¦ Validacoes na GetDados da Modelo 2                           ¦
	//+--------------------------------------------------------------+
	cLinhaOk:="AlwaysTrue()"
	cTudoOk :="AlwaysTrue()"
	aGetEdit := {}
	lRetMod2:=Modelo2(cTitulo,aC,{},aCGD,nOpcx,cLinhaOk,".T.",,,,SFF->(Reccount())+100)
	SFF->(dbgotop())
	If lRetMod2
		nCntItem:= 1
	    For nx := 1 to Len(aCols)
				If nX <=	nTotItens
					SFF->(DbGoTo(aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "FF_REC_WT" })]))
					RecLock("SFF",.F.)
					SFF->(DbDelete())
					MsUnLock()
				Endif
		Next nx
	Endif
	SFF->(dbgotop())
Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào  ¦ A994DlinOk  ¦ Autor ¦ Leonardo Gentile      ¦ Data ¦ 22/09/00 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validaciones generales de A994DlinOk                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994DlinOk()        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99
Local nV := 0
Local _nPos
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("LRET,NV,")

_nPos := Ascan(aHeader,{|x| Alltrim(x[2]) == "FF_ALIQ"})

lRet	:=	.T.
For nV :=1  to  3
   If !aCOLS[n][Len(aCols[n])].And.(Empty(aCols[n][nV]).And.nV<>_nPos )
		Help(" ",1,"OBRIGAT")
		nV		:=	5
		lRet	:=	.F.
	Endif
Next
// Substituido pelo assistente de conversao do AP5 IDE em 09/09/99 ==> __Return(lRet)
Return(lRet)        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994Mex ¦ Autor ¦ Percy Horna            ¦ Data ¦ 10/10/00 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Cadastro de Execao de Impostos no Mexico                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
*/
Static Function A994Mex()

Private cString
Private cCadastro := OemToAnsi(STR0078)   // "Excepciones Fiscales"
Private aRotina   := MenuDef()

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

dbSelectArea("SFF")
dbSetOrder(1)

dbSelectArea("SFF")
mBrowse( 16,1,22,75,"SFF")

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994iMPORT Autor ¦ BRUNO                 ¦ Data ¦ 07/08/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Tabela de iMPORTACAO                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994Import()

Local aFixe := {}
Local nX	:=	1
Local nY	:=	1
Private aCpos := {"FF_IMPOSTO","FF_TEC","FF_ALIQ","FF_MOEDA"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetPrvt("AROTINA,CCADASTRO")

If cPaisLoc == "PAR"
	aYesFields := {"FF_IMPOSTO","FF_MOEDA","FF_ALIQ","FF_RETENC","FF_IMPORTE","FF_CONCEPT","FF_CFO","FF_CFO_C","FF_CFO_V","FF_SERIENF"}
Else
	aYesFields := {"FF_IMPOSTO","FF_MOEDA","FF_ALIQ","FF_RETENC","FF_IMPORTE","FF_CONCEPT"}
EndIf

If !SIX->(DbSeek("SFF7"))
	//"Crear el indice SFF 7 con la siguiente llave :"
	//"Si el campo FF_TEC no existe, por favor crearlo con las mismas caratecristicas del D1_TEC"
	MsgAlert(OemToAnsi(STR0079)+CHr(13)+chr(10);
	+"FF_FILIAL+FF_TEC+FF_IMPOSTO"+CHr(13)+chr(10)+CHr(13)+chr(10);
	+OemToAnsi(STR0080))
	Return .F.
Endif

SX3->(DbSetOrder(2))
For nX:=	1	To Len(aCpos)
	SX3->(DbSeek(aCpos[nX]))
	AAdd(aFixe,{SX3->(X3Titulo()),aCpos[nX]})
Next

If cPaisLoc == "ARG"
	aRotina := {	{ OemToAnsi(STR0001),"AxPesqui"		,0,1,0,.F.},;		// Buscar
					{ OemToAnsi(STR0002),'A994IVisual'	,0,2,0,NIL},;		// Visualizar
					{ OemToAnsi(STR0003),'A994IInclui'	,0,3,0,NIL},;		// Incluir
					{ OemToAnsi(STR0004),'A994IAltera'	,0,4,0,NIL},;		// Modificar
					{ OemToAnsi(STR0005),'A994IDeleta'	,0,5,0,NIL} }		// Borrar
Else
	aRotina := MenuDef()
EndIf

cCadastro := OemToAnsi(STR0081)  //"Vinculo de impuestos de importacion"

//+-----------------------------------------------+
//| Ativar tecla F4 para buscar pedidos em aberto |
//+-----------------------------------------------+

Set Key VK_F4 To A994F4()

//+--------------------------------------------------------------+
//¦ Prepara o SFF para filtrar os registro para Importacion...   ¦
//+--------------------------------------------------------------+
dbSelectArea("SFF")
dbSetOrder(1)
dbSetFilter({|| FF_FILIAL==xFilial('SFF')},"FF_FILIAL==xFilial('SFF')")
dbGoTop()


//+--------------------------------------------------------------+
//¦ Pesquisa Especifica pelo Nome Reduzido indice 4              ¦
///+--------------------------------------------------------------+
mBrowse( 6, 1,22,75,"SFF",aFixe)

Set key VK_F4 To

dbSelectArea("SFF")
dbClearFilter()
dbSetOrder(1)
Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994IInclui  ¦ Autor ¦ Silvia             ¦ Data ¦ 23/05/01 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Inclusao de la Tabla de Importacion.                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994IInclui()
Local nY := 0
Local nX := 0
Local nOpcx := 3
Private aHeader:={},aCols:={}
Private cTec, cTecSim, cVar

cDescr	:= " "
cTec	:= Criavar("FF_TEC")
cTecSim	:= Criavar("FF_TEC")

MyFillGet(nOpcx)

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTec    := Criavar("FF_TEC")
cTecSim := Criavar("FF_TEC")

/*
//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.

AADD(aC,{"cTec"  ,{15,010} ,OemToAnsi("TEC/NCM/CUAL"),"@!",".T.","SYD",.T.})
AADD(aC,{"cDescr", {15,200} ,OemToAnsi("Descripcion") ,"@!",".T.","SYD",.F.})

aR:={}
*/
//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou
//lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,".T.",".T.")
nOpca	:=	0
@ 140,0 To 400,635 DIALOG oDlg TITLE OemToAnsi(STR0081)  //"Vinculo de impuestos de importacion"
@ 040, 019 Say  OemToAnsi("TEC" ) SIZE 38,10
@ 040, 030 GET cTec F3 "SYY" Valid (ExistCpo("SYD",,1).And.a994VldTec(@oDescr))  SIZE 55,10
@ 040, 090 SAY cDescr SIZE 100,10 OBJECT oDescr
@ 040, 220 Say OemToAnsi(STR0082) SIZE 030,030   //"Estrutura Similar"
@ 040, 250 MSGET oTecSim VAR cTecSim SIZE 60,010 OF oDlg PIXEL

oGet := MSGetDados():New(70,5,118,315,4,"A994lineOK","AlwaysTrue","",.T.,,,.F.,2000)

ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()}) CENTERED

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente
//+--------------------------------------------------------------+
//¦ Atualiza o Corpo da Tabela                                   ¦
//+--------------------------------------------------------------+
dbSelectArea("SFF")
For nX := 1 to Len(aHeader)
	If Empty(aCols[Len(aCols)][nX]) .AND. Trim(aHeader[nX][2]) == "FF_IMPOSTO"
//		Len(aCols) := Len(aCols) - 1
		Exit
	EndIf
Next nx

//+--------------------------------------------------------------+
//¦ Atualiza dados do tabela.                                    ¦
//+--------------------------------------------------------------+
IF nOpcA ==1
	For nx := 1 to Len(aCols)
		IF !aCols[nx][Len(aCols[nx])]
			dbSelectArea("SFF")
			RecLock("SFF",.T.)
			Replace FF_FILIAL  With xFilial("SFF"),;
					FF_TEC     With cTec

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do corpo da Tabela.                           ¦
			//+--------------------------------------------------------------+
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
				Endif
			Next ny
			dbUnLock()
		EndIF
	Next nx

Endif
//+-------------------------------------------------------+
//¦ Forçar o array aRotina para dribar a funcao ExecBrow. ¦
//+-------------------------------------------------------+
aRotina[3][4] := 0

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994IVisual  ¦ Autor ¦ Silvia Taguti      ¦ Data ¦ 25/05/01 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Visualizacao da Tabela de Importacion ...	  		      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994IVisual()

Local nX := 0
Local cDescr,cTec
Local nOpcx := 2
Local cSeek, cWhile
Local aAreaSFF:={}
Private cTec1:=""
Private aHeader:={},aCols:={}


SYD->(DbSetOrder(1))
IF cPaisLoc == "ARG" .and. FWIsInCallStack("A994ImpSYD")
	cTec	:=	SYD->YD_TEC+ SYD->YD_EX_NCM+SYD->YD_EX_NBM // + SPACE(TAMSX3("FF_TEC")[1]-TAMSX3("YD_TEC")[1]) 
	cTec1	:=	SYD->YD_TEC+  SPACE(TAMSX3("FF_TEC")[1]-TAMSX3("YD_TEC")[1]) 
	
	SYD->(DbSeek(xFilial()+SYD->YD_TEC))
Else
	SYD->(DbSeek(xFilial()+SFF->FF_TEC))
	cTec	:=	SFF->FF_TEC
EndIf
cDescr	:=	SYD->YD_DESC_P

IF cPaisLoc == "ARG" .and. FWIsInCallStack("A994ImpSYD")
	aAreaSFF:=SFF->(GetArea())
	SFF->(DbSetOrder(1))
	If SFF->(DbSeek(xFilial("SFF")+cTec1))
		cSeek  := xFilial("SFF")+cTec1
	ElSe
		cSeek  := xFilial("SFF")+cTec
	EndIf
	SFF->(RestArea(aAreaSFF))
else
	cSeek  := xFilial("SFF")+cTec
EndIF


cWhile := "FF_FILIAL+FF_TEC"
MyFillGet(nOpcx,7,cSeek,cWhile)

aGetEdit := {}
nOpca	:=	1
@ 140,0 To 400,635 DIALOG oDlg TITLE OemToAnsi(STR0081)  //"Vinculo de impuestos de importacion"
@ 40, 019 Say   OemToAnsi("TEC" ) SIZE 38,10
@ 40, 030 GET cTEC SIZE 57,10 WHEN .F.
@ 40, 090 Say cDescr  SIZE 200,10

oGet := MSGetDados():New(60,5,118,315,2,"AlwaysTrue","AlwaysTrue","",.T.,,,.F.,2000)


ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()}) CENTERED

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994IAltera  ¦ Autor ¦Silvia              ¦ Data ¦ 28/05/01 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Modificacao de la Tabla de Importacion.                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994IAltera()
Local nX := 0
Local nY := 0
Local nOpcx := 4
Local cSeek, cWhile
Local aAreaSFF:={}
Local nPosRecNo := 0
Local lImpSYD   := FWIsInCallStack("A994ImpSYD")

Private aHeader:={},aCols:={}
Private cTec, cDescr,nTotalItens,cVar
Private cTec1:=""

SYD->(DbSetOrder(1))
IF cPaisLoc == "ARG" .And. lImpSYD
	cTec	:=	SYD->YD_TEC+ SYD->YD_EX_NCM+SYD->YD_EX_NBM 
	cTec1	:=	SYD->YD_TEC+  SPACE(TAMSX3("FF_TEC")[1]-TAMSX3("YD_TEC")[1]) 
	
	SYD->(DbSeek(xFilial()+SYD->YD_TEC))
Else
	SYD->(DbSeek(xFilial()+SFF->FF_TEC))
	cTec	:=	SFF->FF_TEC
EndIf
cDescr	:=	SYD->YD_DESC_P

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+

IF cPaisLoc == "ARG" .And. lImpSYD
	aAreaSFF:=SFF->(GetArea())
	SFF->(DbSetOrder(1))
	If SFF->(DbSeek(xFilial("SFF")+cTec1))
		cSeek  := xFilial("SFF")+cTec1
	ElSe
		cSeek  := xFilial("SFF")+cTec
	EndIf
	SFF->(RestArea(aAreaSFF))
else
	cSeek  := xFilial("SFF")+cTec
EndIF


cWhile := "FF_FILIAL+FF_TEC"
nTotalItens := MyFillGet(nOpcx,7,cSeek,cWhile)

aGetEdit 	:= {}
nOpca		:=	0

@ 140,0 To 400,635 DIALOG oDlg TITLE OemToAnsi(STR0081) //"Vinculo de impuestos de importacion"
@ 40, 019 Say   OemToAnsi("TEC" ) SIZE 38,10
@ 40, 030 GET cTEC SIZE 57,10 WHEN .F.
@ 40, 090 Say cDescr  SIZE 200,10
oGet := MSGetDados():New(60,5,118,315,4,"A994lineOK","AlwaysTrue","",.T.,,,.F.,2000)

ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()}) CENTERED

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente

//+--------------------------------------------------------------+
//¦ Atualiza o Corpo da Tabela                                   ¦
//+--------------------------------------------------------------+
dbSelectArea("SFF")
For nX := 1 to Len(aHeader)
	If Empty(aCols[Len(aCols)][nX]) .AND. Trim(aHeader[nX][2]) == "FF_IMPOSTO"
		//Len(aCols) := Len(aCols) - 1
		Exit
	EndIf
Next nx

//+--------------------------------------------------------------+
//¦ Atualiza dados do tabela.                                    ¦
//+--------------------------------------------------------------+

nPosRecNo := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_REC_WT" })

IF nOpcA ==1
	For nx := 1 to Len(aCols)
		IF !aCols[nx][Len(aCols[nx])]
			dbSelectArea("SFF")
			If nX > nTotalItens
				RecLock("SFF",.T.)
			Else
				SFF->(DbGoTo(aCols[nX][nPosRecNo]))
				RecLock("SFF",.F.)
			Endif

			Replace FF_FILIAL  With xFilial("SFF"),;
					FF_TEC     With cTec

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do corpo da Tabela.                           ¦
			//+--------------------------------------------------------------+
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
				Endif
			Next ny
			dbUnLock()
		Else
			If cPaisLoc == "ARG" .And. lImpSYD
				dbSelectArea("SFF")
				SFF->(DbGoTo(aCols[nX][nPosRecNo]))
				RecLock("SFF",.F.)
				SFF->(dbDelete())
				dbUnLock()
			EndIf
		EndIF
	Next nx

Endif
//+-------------------------------------------------------+
//¦ Forçar o array aRotina para dribar a funcao ExecBrow. ¦
//+-------------------------------------------------------+
aRotina[3][4] := 0

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994IDeleta  ¦ Autor ¦ Silvia             ¦ Data ¦ 26/05/01 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Exclusao da Tabela de Importacion                          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994IDeleta()
Local nX := 0
Local nOpcx := 5
Local cSeek, cWhile
Local aAreaSFF:={}
Private cTec1:=""
Private aHeader:={},aCols:={}
Private cTec, cDescr,nTotalItens

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+

SYD->(DbSetOrder(1))
IF cPaisLoc == "ARG" .and. FWIsInCallStack("A994ImpSYD")
	cTec	:=	SYD->YD_TEC+ SYD->YD_EX_NCM+SYD->YD_EX_NBM // + SPACE(TAMSX3("FF_TEC")[1]-TAMSX3("YD_TEC")[1]) 
	cTec1	:=	SYD->YD_TEC+  SPACE(TAMSX3("FF_TEC")[1]-TAMSX3("YD_TEC")[1]) 
	
	SYD->(DbSeek(xFilial()+SYD->YD_TEC))
Else
	SYD->(DbSeek(xFilial()+SFF->FF_TEC))
	cTec	:=	SFF->FF_TEC
EndIf
cDescr	:=	SYD->YD_DESC_P
              

IF cPaisLoc == "ARG" .and. FWIsInCallStack("A994ImpSYD")
	aAreaSFF:=SFF->(GetArea())
	SFF->(DbSetOrder(1))
	If SFF->(DbSeek(xFilial("SFF")+cTec1))
		cSeek  := xFilial("SFF")+cTec1
	ElSe
		cSeek  := xFilial("SFF")+cTec
	EndIf
	SFF->(RestArea(aAreaSFF))
else
	cSeek  := xFilial("SFF")+cTec
EndIF

cWhile := "FF_FILIAL+FF_TEC"
MyFillGet(nOpcx,7,cSeek,cWhile)

aGetEdit := {}
nOpca	:=	0
@ 140,0 To 400,635 DIALOG oDlg TITLE OemToAnsi(STR0081)  //"Vinculo de impuestos de importacion"
@ 40, 019 Say   OemToAnsi("TEC" ) SIZE 38,10
@ 40, 030 GET cTEC SIZE 57,10 WHEN .F.
@ 40, 090 Say cDescr  SIZE 200,10

oGet := MSGetDados():New(60,5,118,315,5,"AlwaysTrue","AlwaysTrue","",.T.,,,.F.,2000)

ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGet:TudoOk(),oDlg:End(),nOpca := 0)},{||oDlg:End()}) CENTERED

//+--------------------------------------------------------------+
//¦ Excluir os registros da tabela  SFF.                         ¦
//+--------------------------------------------------------------+

If nOpca == 1
	dbSelectArea("SFF")
	dbSetOrder(7)
	dbSeek(xFilial("SFF")+cTec)
	If Found()
		While !EOF() .And. FF_FILIAL+FF_TEC == xFilial("SFF")+cTec
			RecLock("SFF",.F.)
			dbDelete()
			dbUnLock()
			dbSkip()
		End
	EndIf
EndIf

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994Tudok Autor ¦ Bruno                  ¦ Data ¦ 10/10/00 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validacao do tudook do importacao                          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
*/
Function A994Tudok()
Local lRet  := .T.

If Empty(M->FF_TEC+M->FF_IMPOSTO)
	Help("",1,"Obrigat")
	lRet  := .F.
Endif

Return lRet

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994Tudok Autor ¦ Bruno                  ¦ Data ¦ 10/10/00 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validacao do tudook do importacao                          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
*/
Function A994LineOk()
Local nX 	:= 0
Local lRet  := .T.
Local nPosImp := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_IMPOSTO" })
Local nPosCon := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_CONCEPT" })
Local nPosAlq := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_ALIQ" })
If cPaisLoc=="PAR"

	If !aCols[N][Len(aCols[1])]
		If Empty(aCols[N][nPosImp])
			Help("",1,"Obrigatorio")
			lRet  := .F.
		ELSE
			cAtu 		:= aCols[N][nPosImp]
			cConc		:= aCols[N][nPosCon]
			cPosAliq	:= aCols[N][nPosAlq]
			For nx:=1 to len(Acols)
				if !aCols[Nx][Len(aCols[Nx])] .AND.aCols[nx][nPosImp] == cAtu .and. aCols[nx][nPosCon] == cConc .and. aCols[nx][nPosAlq] == cPosAliq .and. Nx <> n
					lret := .f.
					HELP(" ",1,"JA GRAVADO")
				ENDIF
			Next
		ENDIF
	Endif


Else
	If !aCols[N][Len(aCols[1])]
		If Empty(aCols[N][nPosImp])
			Help("",1,"Obrigatorio")
			lRet  := .F.
		ELSE
			cAtu := aCols[N][nPosImp]
			For nx:=1 to len(Acols)
				if !aCols[Nx][Len(aCols[Nx])] .AND. aCols[nx][nPosImp] == cAtu .and. Nx <> n
					lret := .f.
					HELP(" ",1,"JA GRAVADO")
				ENDIF
			Next
		ENDIF
	Endif
EndIf
Return lRet

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994VldTec Autor ¦ Bruno                 ¦ Data ¦23/05/001 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Descricao do Tec                                           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
*/

Static Function a994VldTec(oDescr)
Local nX := 0
Local aArea	:=	GetArea()
Local lRet  := .T.
dbSelectArea("SYD")
dbSetOrder(1)
If SYD->(DbSeek(xFilial("SYD")+cTec))
	oDescr:SetText(SYD->YD_DESC_P)
	oDescr:Refresh()
EndIf
dbSelectArea("SFF")
dbSetOrder(7)
SFF->(DbSeek(xFilial()+cTec))
   If Found()
	  MsgBox( STR0083,STR0050,STR0180 ) //"Atencion" - "INFO"
      lRet  := .F.
   Else
      If SFF->(DbSeek(xFilial()+SYD->YD_TEC+SYD->YD_EX_NCM+SYD->YD_EX_NBM))
       	 aCols	:=	{}
      	 While !EOF() .And. FF_FILIAL+FF_TEC == xFilial("SFF")+SYD->YD_TEC+SYD->YD_EX_NCM+SYD->YD_EX_NBM
   	  		Aadd(aCols,Array(Len(aHeader)+1))
			For nX:= 1 To Len(aHeader)
				aCOLS[Len(aCols)][nX] := SFF->(FieldGet(FieldPos(aHeader[nX][2])))
			Next
			aCols[Len(aCols)][nX] := .F.
    		dbSelectArea("SFF")
			dbSkip()
	     End
         lRet  := .T.
      Endif
   Endif
RestArea(aArea)
Return lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Funçào    ¦ A994F4() ¦ Autor ¦ Silvia               ¦ Data ¦ 01.06.01 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Descriçào ¦ Estruturas de Impostos F4         			              ¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994F4()
Local oQual, nX	:=	1
Local cImpTec, cImpimp
Private aHeaderSim:={},aColsSim:={}
Private nOpca :=0, nPosaQual := 0

//+--------------------------------------------------------------+
//¦ Lista de campos que serao mostrados pelo GetDados()          ¦
//+--------------------------------------------------------------+
aListCpo:={}
AADD(aListCpo,"FF_IMPOSTO")
AADD(aListCpo,"FF_ALIQ")
AADD(aListCpo,"FF_RETENC")
AADD(aListCpo,"FF_TEC")

//+--------------------------------------------------------------+
//¦ Montagem do aHeader                                          ¦
//+--------------------------------------------------------------+

aHeaderSim:={}
dbSelectArea("SX3")
dbSetOrder(2)
dbSeek("FF_IMPOSTO")
AADD(aHeaderSim,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
x3_tamanho, x3_decimal,x3_valid,;
x3_usado, x3_tipo, x3_arquivo, x3_context } )
dbSeek("FF_ALIQ")
AADD(aHeaderSim,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
x3_tamanho, x3_decimal,".T.",;
x3_usado, x3_tipo, x3_arquivo, x3_context } )
dbSeek("FF_RETENC")
AADD(aHeaderSim,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
x3_tamanho, x3_decimal, x3_valid,;
x3_usado, x3_tipo, x3_arquivo, x3_context } )
dbSeek("FF_TEC")
AADD(aHeaderSim,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
x3_tamanho, x3_decimal,x3_valid,;
x3_usado, x3_tipo, x3_arquivo, x3_context } )
dbSeek("FF_IMPORTE")
AADD(aHeaderSim,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
x3_tamanho, x3_decimal,x3_valid,;
x3_usado, x3_tipo, x3_arquivo, x3_context } )
dbSetOrder(1)

SYD->(DbSetOrder(1))
SYD->(DbSeek(xFilial()+SFF->FF_TEC))

cTecSim := Criavar("FF_TEC")

//+--------------------------------------------------------------+
//¦ Montando aCols                                               ¦
//+--------------------------------------------------------------+
dbSelectArea("SFF")
dbSetOrder(7)
dbSeek(xFilial("SFF"))
while !EOF()
	Aadd(aColsSim,Array(Len(aHeaderSim)+1))
	For nX:= 1 To Len(aHeaderSim)
		aCOLSSim[Len(aColsSim)][nX] := SFF->(FieldGet(FieldPos(aHeaderSim[nX][2])))
	Next
	aColsSim[Len(aColsSim)][nX] := .F.
	dbSelectArea("SFF")
	dbSkip()
End

If len(aColsSim) == 0
	Return
EndIf

@ 95,074 To 320,330 DIALOG oDlgSim TITLE OemToAnsi(STR0081)  //"Vinculo de impuestos de importacion"

//"Imposto","Aliq","Retenc"
@ 1,1 LISTBOX oQual VAR cTecSim Fields HEADER OemToAnsi(STR0084),OemToAnsi(STR0074),OemToAnsi(STR0077),OemToAnsi("Tec") SIZE 110,80
oQual:SetArray(aColsSim)
oQual:bLine	:=	{|| {aColsSim[oQual:nAt][1],aColsSim[oQual:nAt][2],aColsSim[oQual:nAt][3],aColsSim[oQual:nAt][4]} }

DEFINE SBUTTON FROM 095,60  Type 1 Action (nOpca:=1,nPosaQual:=oQual:nAt,oDlgSim:End()) enable
DEFINE SBUTTON FROM 095,90  Type 2 Action oDlgSim:End() enable
Activate DIALOG oDlgSim CENTERED
if nOpca == 1
	If nPosaQual > 0
	   cImpTec := aColsSim[nPosaQual][4]
	   cImpimp := aColsSim[nPosaQual][1]
       a994imp2(cImpTec,cImpimp)
	EndIf
endif
Return


Function A994imp2(cImpTec1,cImpImp1)

Local oDlgSim
Private aColsSim  := {},aRecnos := {}
Private _lReturn  := .T.
Private nPosImp   := Ascan(aHeaderSim,{|X| Trim(x[2])=="FF_IMPOSTO"})
Private nPosAliq  := Ascan(aHeaderSim,{|X| Trim(x[2])=="FF_ALIQ"})
Private nPosRet   := Ascan(aHeaderSim,{|X| Trim(x[2])=="FF_RETENC"})
Private nPosVlr   := Ascan(aHeaderSim,{|X| Trim(x[2])=="FF_IMPORTE"})

If !Empty(cImpTec1)
	dbSelectArea("SFF")
	dbSetOrder(7)
	If dbSeek(xFilial("SFF")+cImpTec1+cImpImp1)
	   While cImpTec1==FF_TEC .AND. cImpImp1== FF_IMPOSTO .AND. !EOF()
   	     	Aadd(aColsSim,{FF_IMPOSTO,FF_ALIQ,FF_RETENC})
			AAdd(aRecnos,RECNO())
		  	DbSkip()
	   Enddo
	Else
	   _lReturn := .F.
	Endif

Endif
Return(_lReturn)
/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ a994IMPUru ¦ Autor ¦ Percy Horna         * Data ¦ 19/11/01 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Cadastro de Impostos Uruguai - IMESI E IMEBA               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
*/
Static Function a994IMPUru()

	Local nRet := 0
	Local cImp:=""
	Local oCbox,oDlg
	Private aFixe := {}
	Private aImp:= {}
	Private cCadastro := STR0092
	Private aRotina := MenuDef()

	aImp:={"IMS","BA1","PVI","FIS","TCF","IRA",'IRP','PFR','IRN','RIV','RI2','PFI','IV2','IV3','IV4','IV5'}
	nRet:=0

	@000,000 TO 180,400 DIALOG oDlg TITLE STR0070
	@010,003 MSCOMBOBOX oCbox VAR cImp ITEMS aImp ON CHANGE (nImp:=oCbox:nAt) SIZE 120,50 OF oDlg PIXEL
	@008,133 BMPBUTTON TYPE 1 ACTION (nRet:=oCbox:nAt,oDlg:End())
	@008,169 BMPBUTTON TYPE 2 ACTION (nRet:=0,oDlg:End())
	ACTIVATE DIALOG oDlg CENTERED

	If nRet > 0

		MV_PAR01:=nRet

		SFB->(DbSeek(xFilial("SFB")+aImp[MV_PAR01]))
		cCadastro+=Alltrim(SFB->FB_DESCR)

		If MV_PAR01 == 3  .Or. MV_PAR01 == 4 .Or. MV_PAR01 == 5// "IMS|BA1|IRA"
			aFixe:=	{{OemToAnsi(STR0012),"FF_IMPOSTO"},;  		// Imposto
					{OemToAnsi(STR0085) ,"FF_GRUPO"},;	   		// Grupo
					{OemToAnsi(STR0058) ,"FF_IMPORTE"},;		// Importe
					{OemToAnsi(STR0007) ,"FF_CONCEPT"},;
					{STR0166 ,"FF_CONCIRP"},; //"Concepto"
					{STR0167 ,"FF_CFO_C"  },; //"Cod Fis Ent"
					{STR0168 ,"FF_CFO_V"  }} //"Cod Fis Sal"
					If aImp[MV_PAR01]=="TCF"
						Aadd(aFixe,	{OemToAnsi(STR0007) ,"FF_MOEDA"})			// Descripcion
					ElseIf aImp[MV_PAR01]=="FIS"
						Aadd(aFixe,{OemToAnsi(RetTitle("FF_ATIVIDA")),"FF_ATIVIDA"})	// Atividade do Cliente
					Endif
		Elseif MV_PAR01 == 6  .Or. MV_PAR01 == 7
			aFixe:=	{{OemToAnsi(STR0012),"FF_IMPOSTO"},;
					 {OemToAnsi(STR0085),"FF_GRUPO"  },;
					 {STR0169 ,"FF_ITEM"   },; //"Ítem"
					 {OemToAnsi(STR0058),"FF_IMPORTE"},;
					 {OemToAnsi(STR0007),"FF_CONCEPT"},;
					 {OemToAnsi(STR0074),"FF_ALIQ"   },;
					 {OemToAnsi(STR0007),"FF_MOEDA"  },;
					 {STR0166 ,"FF_CONCIRP"},; //"Concepto"
					 {STR0167 ,"FF_CFO_C"  },; //"Cod Fis Ent"
					 {STR0168 ,"FF_CFO_V"  }} //"Cod Fis Sal"

		Elseif MV_PAR01 == 8
			aFixe:=	{ {OemToAnsi(STR0012),"FF_IMPOSTO"},;
					  {OemToAnsi(STR0085),"FF_GRUPO"  },;
					  {STR0169 ,"FF_ITEM"   },; //"Ítem"
					  {OemToAnsi(STR0058),"FF_IMPORTE"},;
					  {OemToAnsi(STR0007),"FF_CONCEPT"},;
					  {OemToAnsi(STR0074),"FF_ALIQ"   },;
					  {OemToAnsi(STR0007),"FF_MOEDA"  },;
					  {STR0166 ,"FF_CONCIRP"},; //"Concepto"
					  {STR0167 ,"FF_CFO_C"  },; //"Cod Fis Ent"
					  {STR0168 ,"FF_CFO_V"  }} //"Cod Fis Sal"
		Else
			aFixe:=	{{OemToAnsi(STR0012),"FF_IMPOSTO"},;	// Imposto
					{OemToAnsi(STR0074) ,"FF_ALIQ"},;		// Alicuota
					{OemToAnsi(STR0085) ,"FF_GRUPO"},;		// Grupo
					{OemToAnsi(STR0007) ,"FF_CONCEPT"},;// Descripcion
				    {STR0166 ,"FF_CONCIRP"},; //"Concepto"
				  	{STR0167 ,"FF_CFO_C"  },; //"Cod Fis Ent"
				  	{STR0168 ,"FF_CFO_V"  }} //"Cod Fis Sal"
		Endif

		dbSelectArea("SFF")
		dbSetOrder(1)
		cFilter	:=	"FF_IMPOSTO =='"+aImp[MV_PAR01]+"'"
		Set Filter TO &cFilter.
		mBrowse( 16,1,22,75,"SFF",aFixe)
		dbClearFilter()
	EndIf
Return (Nil)
/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ a994IMPVis ¦ Autor ¦ Percy Horna         ¦ Data ¦ 28/11/01 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Cadastro de Impostos Uruguai - IMESI e IMEBA               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
*/
Function a994IMPVis(cAlias,nReg,nOpc)
Local nOpcao
Private aCpos := {}

	If MV_PAR01 == 3  .Or. MV_PAR01 == 4 .Or. MV_PAR01 == 5
		aCpos := {"FF_IMPORTE","FF_GRUPO","FF_CONCEPT","FF_CONCIRP","FF_CFO_C","FF_CFO_V"}
		If aImp[MV_PAR01]=="TCF"
			Aadd(aCpos,"FF_MOEDA")
		ElseIf aImp[MV_PAR01]=="FIS"
			Aadd(aCpos,"FF_ATIVIDA")
		Endif
	ElseIf MV_PAR01 == 6 .Or. MV_PAR01 == 7
		Aadd(aCpos,"FF_IMPOSTO")
		Aadd(aCpos,"FF_GRUPO")
		Aadd(aCpos,"FF_ITEM")
		Aadd(aCpos,"FF_IMPORTE")
		Aadd(aCpos,"FF_CONCEPT")
		Aadd(aCpos,"FF_ALIQ")
		Aadd(aCpos,"FF_MOEDA")
		Aadd(aCpos,"FF_CONCIRP")
		Aadd(aCpos,"FF_CFO_C")
		Aadd(aCpos,"FF_CFO_V")
	ElseIf MV_PAR01 == 8
		Aadd(aCpos,"FF_IMPOSTO")
		Aadd(aCpos,"FF_GRUPO")
		Aadd(aCpos,"FF_ITEM")
		Aadd(aCpos,"FF_IMPORTE")
		Aadd(aCpos,"FF_CONCEPT")
		Aadd(aCpos,"FF_ALIQ")
		Aadd(aCpos,"FF_MOEDA")
		Aadd(aCpos,"FF_CONCIRP")
		Aadd(aCpos,"FF_CFO_C")
		Aadd(aCpos,"FF_CFO_V")
	Else
		aCpos := {"FF_ALIQ","FF_IMPORTE","FF_GRUPO","FF_CONCEPT","FF_CONCIRP","FF_CFO_C","FF_CFO_V"}
	Endif
	nOpcao := AxVisual(cAlias,nReg,nOpc,aCpos)

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ a994IMPInc ¦ Autor ¦ Percy Horna         ¦ Data ¦ 19/11/01 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Cadastro de Impostos Uruguai - IMESI e IMEBA               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
*/
Function a994IMPInc(cAlias,nReg,nOpc)
Local nOpcao
Private aCpos := {}

	If MV_PAR01 == 3  .Or. MV_PAR01 == 4 .Or. MV_PAR01 == 5
		aCpos := {"FF_IMPORTE",,"FF_GRUPO","FF_CONCEPT","FF_CONCIRP","FF_CFO_C","FF_CFO_V"}
		If aImp[MV_PAR01]=="TCF"
			Aadd(aCpos,"FF_MOEDA")
		ElseIf aImp[MV_PAR01]=="FIS"
			Aadd(aCpos,"FF_ATIVIDA")
		Endif

	ElseIf MV_PAR01== 6 .Or. MV_PAR01 == 7
		Aadd(aCpos,"FF_IMPOSTO")
		Aadd(aCpos,"FF_GRUPO")
		Aadd(aCpos,"FF_ITEM")
		Aadd(aCpos,"FF_IMPORTE")
		Aadd(aCpos,"FF_CONCEPT")
		Aadd(aCpos,"FF_ALIQ")
		Aadd(aCpos,"FF_MOEDA")
		Aadd(aCpos,"FF_CONCIRP")
		Aadd(aCpos,"FF_CFO_C")
		Aadd(aCpos,"FF_CFO_V")
	ElseIf MV_PAR01 == 8
		Aadd(aCpos,"FF_IMPOSTO")
		Aadd(aCpos,"FF_GRUPO")
		Aadd(aCpos,"FF_ITEM")
		Aadd(aCpos,"FF_IMPORTE")
		Aadd(aCpos,"FF_CONCEPT")
		Aadd(aCpos,"FF_ALIQ")
		Aadd(aCpos,"FF_MOEDA")
		Aadd(aCpos,"FF_CONCIRP")
		Aadd(aCpos,"FF_CFO_C")
		Aadd(aCpos,"FF_CFO_V")
	Else
		aCpos := {"FF_ALIQ","FF_IMPORTE","FF_GRUPO","FF_CONCEPT","FF_CONCIRP","FF_CFO_C","FF_CFO_V"}
	Endif
	nOpcao := AxInclui(cAlias,nReg,nOpc,aCpos,,aCpos,"a994CheckGets('"+aImp[MV_PAR01]+"')")

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ a994IMPAlt ¦ Autor ¦ Percy Horna         ¦ Data ¦ 28/11/01 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Cadastro de Impostos Uruguai - IMESI e IMEBA- Alteracao    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
*/
Function a994IMPAlt(cAlias,nReg,nOpc)
Local nOpcao
Private aCpos := {}

	If MV_PAR01 == 3  .Or. MV_PAR01 == 4 .Or. MV_PAR01 == 5
		aCpos := {"FF_IMPORTE","FF_GRUPO","FF_CONCEPT","FF_CONCIRP","FF_CFO_C","FF_CFO_V"}
		If aImp[MV_PAR01]=="TCF"
			Aadd(aCpos,"FF_MOEDA")
		ElseIf aImp[MV_PAR01]=="FIS"
			Aadd(aCpos,"FF_ATIVIDA")
		Endif
	ElseIf MV_PAR01 ==6 .Or. MV_PAR01 ==7
		Aadd(aCpos,"FF_ITEM")
		Aadd(aCpos,"FF_IMPORTE")
		Aadd(aCpos,"FF_CONCEPT")
		Aadd(aCpos,"FF_ALIQ")
		Aadd(aCpos,"FF_MOEDA")
		Aadd(aCpos,"FF_CONCIRP")
		Aadd(aCpos,"FF_CFO_C")
		Aadd(aCpos,"FF_CFO_V")
	ElseIf MV_PAR01 == 8
		Aadd(aCpos,"FF_ITEM")
		Aadd(aCpos,"FF_IMPORTE")
		Aadd(aCpos,"FF_CONCEPT")
		Aadd(aCpos,"FF_ALIQ")
		Aadd(aCpos,"FF_MOEDA")
		Aadd(aCpos,"FF_CONCIRP")
		Aadd(aCpos,"FF_CFO_C")
		Aadd(aCpos,"FF_CFO_V")
	Else
		aCpos := {"FF_ALIQ","FF_GRUPO","FF_CONCEPT","FF_CONCIRP","FF_CFO_C","FF_CFO_V"}
	Endif
	nOpcao := AxAltera(cAlias,nReg,nOpc,aCpos,,aCpos,,"a994CheckGets('"+aImp[MV_PAR01]+"')")
Return
/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ a994IMSExc ¦ Autor ¦ Percy Horna         ¦ Data ¦ 29/11/01 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Cadastro de Impostos Uruguai - IMESI                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
*/
Function a994IMPExc(cAlias,nReg,nOpc)
Local nOpcao
Private aCpos := {}

	If MV_PAR01 == 3  .Or. MV_PAR01 == 4 .Or. MV_PAR01 == 5
		aCpos := {"FF_IMPORTE","FF_GRUPO","FF_CONCEPT","FF_CONCIRP","FF_CFO_C","FF_CFO_V"}
		If aImp[MV_PAR01]=="TCF"
			Aadd(aCpos,"FF_MOEDA")
		ElseIf aImp[MV_PAR01]=="FIS"
			Aadd(aCpos,"FF_ATIVIDA")
		Endif
	ElseIf MV_PAR01 == 6 .Or. MV_PAR01 == 7
		Aadd(aCpos,"FF_IMPOSTO")
		Aadd(aCpos,"FF_GRUPO")
		Aadd(aCpos,"FF_ITEM")
		Aadd(aCpos,"FF_IMPORTE")
		Aadd(aCpos,"FF_CONCEPT")
		Aadd(aCpos,"FF_ALIQ")
		Aadd(aCpos,"FF_MOEDA")
		Aadd(aCpos,"FF_CONCIRP")
		Aadd(aCpos,"FF_CFO_C")
		Aadd(aCpos,"FF_CFO_V")
	ElseIf MV_PAR01 == 8
		Aadd(aCpos,"FF_IMPOSTO")
		Aadd(aCpos,"FF_GRUPO")
		Aadd(aCpos,"FF_ITEM")
		Aadd(aCpos,"FF_IMPORTE")
		Aadd(aCpos,"FF_CONCEPT")
		Aadd(aCpos,"FF_ALIQ")
		Aadd(aCpos,"FF_MOEDA")
		Aadd(aCpos,"FF_CONCIRP")
		Aadd(aCpos,"FF_CFO_C")
		Aadd(aCpos,"FF_CFO_V")
	Else
		aCpos := {"FF_ALIQ","FF_GRUPO","FF_CONCEPT","FF_CONCIRP","FF_CFO_C","FF_CFO_V"}
	Endif
	nOpcao := AxDeleta(cAlias,nReg,nOpc,,aCpos)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ FUNCAO   ³a994CheckGets³ AUTOR ³ Percy A Horna      ³ DATA ³ 29/11/2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DESCRICAO³ Valida campos em branco                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ Uruguay                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a994CheckGets(cImposto)
Local lRet := .T.
Local aArea, cGrupo, nReg

	M->FF_IMPOSTO := cImposto
	If Empty(M->FF_GRUPO) .Or. (Empty(M->FF_ALIQ) .and. MV_PAR01<=2)
		lRet := .F.
	ElseIf MV_PAR01 == 6 .Or. MV_PAR01 == 7
		dbSelectArea("SFF")
		dbSetOrder(9)
		If dbSeek(xFilial()+M->FF_IMPOSTO+M->FF_GRUPO) .And. INCLUI
	        MsgAlert(STR0170) //"El impuesto ya existe."
			lRet := .F.
        EndIf
	ElseIf MV_PAR01 == 8
		dbSelectArea("SFF")
		dbSetOrder(5)
		If dbSeek(xFilial()+M->FF_IMPOSTO+M->FF_CFO_C) .And. INCLUI
	        MsgAlert(STR0170) //"El impuesto ya existe."
			lRet := .F.
		Else
			dbSetOrder(6)
			If dbSeek(xFilial()+M->FF_IMPOSTO+M->FF_CFO_V) .And. INCLUI
		        MsgAlert(STR0170) //"El impuesto ya existe."
				lRet := .F.
       		 EndIf
	   EndIf
	Else
		cGrupo := M->FF_GRUPO
		aArea := GetArea()
		dbSelectArea("SFF")
		dbSetOrder(3)
		nReg:=Recno()
		If dbSeek(xFilial()+M->FF_IMPOSTO)
			While FF_IMPOSTO == M->FF_IMPOSTO .And. FF_FILIAL == xFilial()
				If FF_GRUPO == cGrupo
					If Recno()<>nReg
						If If(aImp[MV_PAR01]=="FIS",(FF_ATIVIDA==M->FF_ATIVIDAD),.T.)
							MsgAlert(STR0091)
							lRet := .F.
							Exit
						Endif
					Endif
				Endif
         		dbSkip()
   			Enddo
		EndIf
		RestArea(aArea)

	EndIf
	If  lRet .And. cpaisLoc=="URU" .And. aImp[MV_PAR01]$"IRP|IRN|IRA|RIV|RI2|PFI|IV2|IV3|IV4|IV5" .And.;
			   (Empty(M->FF_CONCIRP)  .Or. Empty(M->FF_CFO_C) .OR. Empty(M->FF_CFO_V ))
		lRet := .F.
		MsgAlert(STR0127)

    Endif

Return(lRet)

/*
____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦  A994SLI  ¦ Autor ¦ Julio Cesar          ¦ Data ¦ 10/02/04 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina de manutencao da retencao de Servico de Limpieza    ¦¦¦
¦¦¦          ¦ de Inmuebles.                                              ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994SLI()
Local nY := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("AFIXE,AROTINA,CCADASTRO,")

aYesFields := {"FF_IMPOSTO","FF_CFO_C","FF_CFO_V","FF_ALIQ","FF_CONCEPT"}

aFixe := { {OemToAnsi(STR0012) ,"FF_IMPOSTO"},;  // Impuesto
{OemToAnsi(STR0008) ,"FF_CFO_C"  },;  // CFO Compras
{OemToAnsi(STR0009) ,"FF_CFO_V"  },;  // CFO Ventas
{OemToAnsi(STR0010) ,"FF_ALIQ"},;     // Alicuota
{OemToAnsi(STR0010) ,"FF_CONCEPT"} }  // Descricion

aRotina := {{ OemToAnsi(STR0001),"AxPesqui"		,0,1,0,.F.},;		// Buscar
			{ OemToAnsi(STR0002),'A994Jvisual'	,0,2,0,NIL},;		// Visualizar
			{ OemToAnsi(STR0003),'A994Jinclui'	,0,3,0,NIL},;		// Incluir
			{ OemToAnsi(STR0004),'A994Jaltera'	,0,4,0,NIL},;		// Modificar
			{ OemToAnsi(STR0005),'A994Jdeleta'	,0,5,0,NIL} }		// Borrar

cCadastro := STR0093 //"Planilla de Impuesto de Limpieza de Inmuebles"

//+--------------------------------------------------------------+
//¦ Prepara o SFF para filtrar os registro para SLI...           ¦
//+--------------------------------------------------------------+
dbSelectArea("SFF")
dbSetOrder(4)
dbSetFilter({|| FF_FILIAL==xFilial('SFF') .And. FF_IMPOSTO=='SLI'},"FF_FILIAL==xFilial('SFF') .And. FF_IMPOSTO=='SLI'")
dbGoTop()

//+--------------------------------------------------------------+
//¦ Pesquisa Especifica pelo Nome Reduzido indice 4              ¦
//+--------------------------------------------------------------+
mBrowse( 6, 1,22,75,"SFF",aFixe)

dbSelectArea("SFF")
dbClearFilter()
dbSetOrder(1)
Return

/*
____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦A994Jvisual¦ Autor ¦ Julio Cesar          ¦ Data ¦ 10/02/04 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Vizualizacion de la Tabla de Limpieza de Inmuebles         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994Jvisual()

Local cSeek  := xFilial("SFF")+"SLI"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,AHEADER,CTABELA,CMESDESDE,CMESATE")
SetPrvt("NCNT,ACOLS,NTOTALITENS,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2,")

nOpcx:=2

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela   := SFF->FF_NUM
cMesDesde := SFF->FF_DESDE
cMesAte   := SFF->FF_ATE

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens := MyFillGet(nOpcx,4,cSeek)

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:= STR0093 //"Planilla de Impuesto de Limpieza de Inmuebles"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!"      ,".T.",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,.F.})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,.F.})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk:="AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,".T.",".T.",,,,SFF->(Reccount())+100)

Return


/*
____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦A994Jinclui¦ Autor ¦ Julio Cesar          ¦ Data ¦ 10/02/04 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Inclusao de la Tabla de Limpieza de Inmuebles              ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994Jinclui()
Local nX := 0
Local nY := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,AHEADER,ACOLS,CTABELA,CMESDESDE")
SetPrvt("CMESATE,CPLANILLA,NTOTALITENS,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2,NMAXARRAY")
SetPrvt("NCNTITEM,CVAR,AROTINA,")


// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _M2_ATUALIZA  3
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _ZONFIS       "FF_ZONFIS"

nOpcx:=_M2_ATUALIZA

//+--------------------------------------------------------------+
//¦ Inicializar o proximo numero da Tabela.                      ¦
//+--------------------------------------------------------------+
dbSelectArea("SFF")
dbSetOrder(4)
dbSeek(xFilial("SFF")+"SLI")
If Found()
	MsgBox(STR0094,OemToAnsi(STR0050),STR0180 ) //"Planilla de Impuesto de Limpieza de Inmuebles ya existe!" - "Atencion" - "INFO"
	Return
EndIf

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela   := "000001"
cMesDesde := Space(04)
cMesAte   := Space(04)

cPlanilla := "SLI"

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens := MyFillGet(nOpcx,,cPlanilla)

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:= STR0093 //"Planilla de Impuesto de Limpieza de Inmuebles"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!","A994VTabla()",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk:="A994JlinOk(2)"
cTudoOk :="A994JlinOk(2)"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,{"FF_CFO_C","FF_CFO_V","FF_ALIQ","FF_CONCEPT"},,,SFF->(Reccount())+100)

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente
If lRetMod2
	//+--------------------------------------------------------------+
	//¦ Atualiza o Corpo da Tabela                                   ¦
	//+--------------------------------------------------------------+
	dbSelectArea("SFF")
	nMaxArray := Len(aCols)
	For ny := 1 to Len(aHeader)
		If Empty(aCols[nMaxArray][ny]) .AND. Trim(aHeader[ny][2]) == "FF_IMPOSTO"
			nMaxArray := nMaxArray - 1
			Exit
		EndIf
	Next ny

	nCntItem:= 1
	For nx := 1 to nMaxArray
		IF !aCols[nx][Len(aCols[nx])]

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do tabela.                                    ¦
			//+--------------------------------------------------------------+
			dbSelectArea("SFF")
			RecLock("SFF",.T.)
			Replace FF_FILIAL  With xFilial("SFF"),;
			FF_NUM     With cTabela,;
			FF_DESDE   With cMesDesde,;
			FF_ATE	   With cMesAte

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do corpo da Tabela.                           ¦
			//+--------------------------------------------------------------+
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
				Endif
			Next ny
			Replace FF_IMPOSTO  With "SLI"
			dbUnLock()
			nCntItem:=nCntItem + 1
		EndIF
	Next nx
Endif
//+-------------------------------------------------------+
//¦ Forçar o array aRotina para dribar a funcao ExecBrow. ¦
//+-------------------------------------------------------+
aRotina[3][4] := 0

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦A994Jaltera¦ Autor ¦ Julio Cesar          ¦ Data ¦ 10/02/04 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Alteracao da Tabela de Limpieza de Inmuebles               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994Jaltera()
Local nY := 0
Local nX := 0
Local cSeek  := xFilial("SFF")+"SLI"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetPrvt("NOPCX,AHEADER,CTABELA,CMESDESDE,CMESATE")
SetPrvt("CPLANILLA,NCNT,ACOLS,NTOTALITENS,NTOTITENSFF")
SetPrvt("CTITULO,AC,AR,ACGD,CLINHAOK,CTUDOOK")
SetPrvt("AGETEDIT,LRETMOD2,NMAXARRAY,NCNTITEM")
SetPrvt("CVAR,")

nOpcx:=4

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela   := SFF->FF_NUM
cMesDesde := SFF->FF_DESDE
cMesAte   := SFF->FF_ATE

cPlanilla := "SLI"

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens := MyFillGet(nOpcx,4,cSeek)
nTotItensFF := nTotalItens

//Alterando função de validação do campo FF_IMPOSTO


//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo := STR0093 //"Planilla de Impuesto de Limpieza de Inmuebles"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!","A994VTabla()",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,.T.})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,.T.})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk:="A994JlinOk(2)"
cTudoOk :="A994JlinOk(2)"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou
lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,{"FF_CFO_C","FF_CFO_V","FF_ALIQ","FF_CONCEPT"},,,SFF->(Reccount())+100)

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente
If lRetMod2
	nCntItem:= 1
	For nx := 1 to Len(aCols)
		IF !aCols[nx][Len(aCols[nx])]
			//+--------------------------------------------------------------+
			//¦ Se e um iten novo, incluir-lo , senao so atualizar           ¦
			//+--------------------------------------------------------------+
			If nX > nTotItensFF
				RecLock("SFF",.T.)
			Else
				SFF->(DbGoTo(aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "FF_REC_WT" })]))
				RecLock("SFF",.F.)
			Endif
			Replace FF_FILIAL  With xFilial("SFF"),;
			FF_NUM     With cTabela,;
			FF_DESDE   With cMesDesde,;
			FF_ATE	   With cMesAte

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do corpo da Tabela.                           ¦
			//+--------------------------------------------------------------+
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
				Endif
			Next ny
			Replace FF_IMPOSTO  With "SLI"
			MsUnLock()
			nCntItem := nCntItem + 1
		Else
			If nX <=	nTotItensFF
				SFF->(DbGoTo(aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "FF_REC_WT" })]))
				RecLock("SFF",.F.)
				SFF->(DbDelete())
				MsUnLock()
			Endif
		Endif
	Next nX
Endif

Return


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦A994Jdeleta¦ Autor ¦ Julio Cesar          ¦ Data ¦ 10/02/04 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Exclusao da Tabela de Impuesto de Limpieza de Inmuebles    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994Jdeleta()

Local cSeek  := xFilial("SFF")+"SLI"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,AHEADER,CTABELA,CMESDESDE,CMESATE")
SetPrvt("NCNT,ACOLS,NTOTALITENS,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2,")

nOpcx:=5

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela   := SFF->FF_NUM
cMesDesde := SFF->FF_DESDE
cMesAte   := SFF->FF_ATE

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens := MyFillGet(nOpcx,4,cSeek)

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo := STR0093 //"Planilla de Impuesto de Limpieza de Inmuebles"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!"      ,".T.",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,.F.})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,.F.})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk:="AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,".T.",".T.",,,,SFF->(Reccount())+100)

If lRetMod2
	//+--------------------------------------------------------------+
	//¦ Excluir os registros da tabela  SFF.                         ¦
	//+--------------------------------------------------------------+
	dbSelectArea("SFF")
	dbSetOrder(4)
	dbSeek(xFilial("SFF")+"SLI")
	If Found()
		While !Eof() .and. FF_FILIAL+FF_IMPOSTO==xFilial("SFF")+"SLI"
			RecLock("SFF",.F.)
			dbDelete()
			dbUnLock()
			dbSkip()
		End
	EndIf
EndIf

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦A994JlinOk¦ Autor ¦ Julio Cesar           ¦ Data ¦ 10/02/04 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validaciones generales de GANF100.                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994JlinOk(cParam)
Local nV := 0
Local lRet := .T.

Do Case
	Case cParam	==	1
		If Subs(M->FF_IMPOSTO,1,3) <> "SLI"
			MsgStop(STR0095)
			lRet := .F.
		Endif
	Case cParam	==	2
		For nV := 1  To  4
			 If !aCOLS[n][Len(aCols[n])] .And. Empty(aCols[n][nV])
				Help(" ",1,"OBRIGAT")
				lRet := .F.
				Exit
			Endif
		Next
EndCase
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()
	Private aRotina := {}
	
	If cPaisLoc == "MEX"
		aRotina := {	{ OemToAnsi(STR0001),"AxPesqui",0,1,0,.F.} ,;
							{ OemToAnsi(STR0002),"AxVisual",0,2,0,NIL} ,;
							{ OemToAnsi(STR0003),"a994MInclui",0,3,0,NIL} ,;
							{ OemToAnsi(STR0004),"AxAltera",0,4,0,NIL} ,;
							{ OemToAnsi(STR0005),"AxDeleta",0,5,0,NIL} }
	ElseIf cPaisLoc == "EUA"
		aRotina :=	{{OemToAnsi(STR0001)	, 'AxPesqui', 0, 1, 0, .F.},; //"Buscar"
					{OemToAnsi(STR0002)		, 'AxVisual', 0, 2, 0, NIL},; //"Visualizar"
					{OemToAnsi(STR0003)		, 'AxInclui', 0, 3, 0, NIL},; //"Incluir"
					{OemToAnsi(STR0004)		, 'AxAltera', 0, 4, 0, NIL},; //"Modificar"
					{OemToAnsi(STR0005)		, 'AxDeleta', 0, 5, 0, NIL}}  //"Borrar"
	ElseIf cPaisLoc $ "CHI|PAR"
		aRotina := {	{ OemToAnsi(STR0001),"AxPesqui"		,0,1,0,.F.},;		// Buscar
							{ OemToAnsi(STR0002),'A994IVisual'	,0,2,0,NIL},;		// Visualizar
							{ OemToAnsi(STR0003),'A994IInclui'	,0,3,0,NIL},;		// Incluir
							{ OemToAnsi(STR0004),'A994IAltera'	,0,4,0,NIL},;		// Modificar
							{ OemToAnsi(STR0005),'A994IDeleta'	,0,5,0,NIL} }		// Borrar
	ElseIf cPaisLoc == "URU"
			aRotina := {	{ OemToAnsi(STR0001),"AxPesqui"		,0,1,0,.F.} ,;
								{ OemToAnsi(STR0002),'a994IMPVis'	,0,2,0,NIL} ,;
								{ OemToAnsi(STR0003),'a994IMPInc'	,0,3,0,NIL} ,;
								{ OemToAnsi(STR0004),'a994IMPAlt'	,0,4,0,NIL} ,;
								{ OemToAnsi(STR0005),'a994IMPExc'	,0,5,0,NIL} }
	ElseIf cPaisLoc == "VEN"
		aRotina := {	{OemToAnsi(STR0001),"AxPesqui"	,0,1,0,.F.},;
						{OemToAnsi(STR0002),'AxVisual',0,2,0,NIL},;
						{OemToAnsi(STR0003),'AxInclui',0,3,0,NIL},;
						{OemToAnsi(STR0004),'AxAltera',0,4,0,NIL},;
						{OemToAnsi(STR0005),'AxDeleta',0,5,0,NIL}	}
	ElseIf cPaisLoc == "COL"
		aRotina := {	{OemToAnsi(STR0001), 'AxPesqui', 0, 1, 0, .F.},;
						{OemToAnsi(STR0002), 'AxVisual', 0, 2, 0, NIL},;
						{OemToAnsi(STR0003), 'AxInclui', 0, 3, 0, NIL},;
						{OemToAnsi(STR0004), 'AxAltera', 0, 4, 0, NIL},;
						{OemToAnsi(STR0005), 'AxDeleta', 0, 5, 0, NIL},;
						{OemToAnsi(STR0138),'A994ExcFis',0, 6, 0, NIL}} // "Actualizar Lim. Inicial"
	EndIf
	
	If ExistBlock("MA994MNU")
		ExecBlock("MA994MNU",.F.,.F.)
	EndIf
Return(aRotina)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MyFillGet ³ Autor ³ Liber De Esteban      ³ Data ³29/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Montagem do aHeader e aCols                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nCnt -> Numero de itens no aCols                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc -> Codigo da opcao (Incusao, Alteracao, ... )         ³±±
±±³          ³ nOrd -> Ordem para posicionamento na tabela SFF            ³±±
±±³          ³ cSeek -> Chave para posicionamento na tabela SFF           ³±±
±±³          ³ cWhile -> Expressão para comparacao no while do SFF        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³USO       ³ SIGAFIS - LOCALIZACOES                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MyFillGet(nOpc,nOrd,cSeek,cWhile)

Local nY   := 0
Local nI   := 0
Local nCnt := 0
Local lInclui := (nOpc == 3)
Local lAltera := (nOpc == 4)

DEFAULT nOrd   := 1
DEFAULT cSeek  := ""
DEFAULT cWhile := "FF_FILIAL+FF_IMPOSTO"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aHeader                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader:={}

dbSelectArea("SX3")
dbSetOrder(2) // Seleciono campo a campo para manter sequencia no aHeader
For nI := 1 to len(aYesFields)
	If "SLI"$cSeek .And. aYesFields[nI] == "FF_IMPOSTO" .And. (lInclui .or. lAltera)
		Loop
	ElseIf dbSeek(aYesFields[nI])
		Aadd(aHeader,{TRIM(X3TITULO()), X3_CAMPO, X3_PICTURE,X3_TAMANHO,X3_DECIMAL,;
		X3_VALID, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT})
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona os campos de Alias e Recno ao aHeader para WalkThru.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ADHeadRec("SFF",aHeader)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aCols                             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lInclui

	aCols	:= Array(1,Len(aHeader)+1)

	For nY := 1 to Len(aHeader)
		If IsHeadRec(aHeader[nY][2])
			aCols[1][nY] := 0
		ElseIf IsHeadAlias(aHeader[nY][2])
			aCols[1][nY] := "SFF"
		ElseIf AllTrim(aHeader[nY,2]) == "FF_ITEM" .And. !("IV" $ AllTrim(cSeek)).And. !("IB" $ AllTrim(cSeek))
			aCols[1][nY] := StrZero(1,TAMSX3("FF_ITEM")[1])
		Else
			aCols[1][nY] := CriaVar(aHeader[nY][2])
		EndIf
	Next nY
	aCols[1][Len(aHeader)+1] := .F.
Else
	dbSelectArea("SFF")
	dbSetOrder(nOrd)
	dbSeek(cSeek)
	While !EOF() .And. &(cWhile) == cSeek
		nCnt:=nCnt+1
		dbSkip()
	EndDo
	If nCnt == 0
		IF cPaisLoc == "ARG" .and. FWIsInCallStack("A994ImpSYD")
			MsgAlert(OemToAnsi(STR0192),OemToAnsi(STR0050)) //No fueron encontrados datos para este registro 
		Else
			Help(" ",1,"NOITENS")
		EndIf
		Return nCnt
	EndIf

	aCols	:= Array(nCnt,Len(aHeader)+1)
	nCnt	:= 0

	dbSeek(cSeek)
	While !EOF() .And. &(cWhile) == cSeek
		nCnt:=nCnt+1
		For nY := 1 to Len(aHeader)
			If IsHeadRec(aHeader[nY][2])
				aCols[nCnt][nY] := SFF->(Recno())
			ElseIf IsHeadAlias(aHeader[nY][2])
				aCols[nCnt][nY] := "SFF"
			ElseIf AllTrim(aHeader[nY,2]) == "FF_ITEM" .And. !("IV" $ AllTrim(cSeek)).And. !("IB" $ AllTrim(cSeek))
				aCols[nCnt][nY] := StrZero(nCnt,TAMSX3("FF_ITEM")[1])
			ElseIf aHeader[nY,10] # "V"
				aCols[nCnt][nY] := FieldGet(FieldPos(aHeader[nY][2]))
			ElseIF aHeader[nY,10] == "V"
				aCols[nCnt][nY] := CriaVar(aHeader[nY][2])
			EndIf
		Next nY

		aCols[nCnt][Len(aHeader)+1] := .F.
		dbSelectArea("SFF")
		dbSkip()
	EndDo
EndIf
Return (nCnt)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VerDataF ³ Autor ³ Sueli Santos           ³ Data ³17.10.07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se a data lancada pode ser utilizada na operacao.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Tipo de Operacao                                     ³±±
±±³          ³ExpC2: Data inicial Final                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VerDataF(cTipo,cData)
Local lRet := .T.

Do Case
Case cTipo == "F"
	If !Empty(M->FF_DTDE) .And. Dtos(cData) < Dtos(M->FF_DTDE)
		HELP("   ",1,"VALD_DF")
		lRet := .F.
	EndIf
Case cTipo == "I"
	If !Empty(M->FF_DTATE) .And. Dtos(cData) > Dtos(M->FF_DTATE)
		HELP("   ",1,"VALD_DI")
		lRet := .F.
	EndIf
EndCase

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³A994IncluiºAutor ³Sueli Santos        º Data ³  17.10.07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclusao da tabela de Ganancias/Fundo Cooperativo          º±±
±±º          ³                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a994MInclui()
Local cAlias	:="SFF"
Local nReg		:=SFF->(recno())
Local nOpc		:=3

AxInclui( cAlias, nReg, nOpc,,,,"a994MChkInc()")
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³a994MChkIncºAutor ³Sueli Santos        º Data ³  17.10.07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Checa se a os itens ja existem.                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÜßßßßßßßßßß
*/
Function a994MChkInc()
Local lRet			:=	.T.

SFF->(dbsetorder(1))
If SFF->(DbSeek(xFilial("SFF")+M->FF_NUM+M->FF_ITEM))
   HELP("   ",1,"EXC_FIS")
   lRet := .F.
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CCJPTG    ºAutor  ³Mary C. Hergert     º Data ³  23/05/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria a tabela de regioes de tributacao para Portugal        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaFis                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CCJPTG()

Local aArea		:= GetArea()
Local aRegiao 	:= {{"001",STR0100},{"002",STR0101},{"003",STR0102},{"004",STR0103},{"005",STR0104}}
//	"CONTINENTE" "REGIÃO AUTÔNOMA DE MADEIRA" "REGIÃO AUTÔNOMA DE AÇORES" "INTRACOMUNITÁRIA" "EXTRACOMUNITÁRIA"
Local nX		:= 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Antes de criar o Plano IVA, executa a carga inicial da tabela CCJ - Regiões de Tributacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AliasIndic("CCJ") .And. CCJ->(reccount()) == 0

	dbSelectArea("CCJ")
	For nX := 1 to Len(aRegiao)

		If !CCJ->(dbSeek(xFilial("CCJ")+aRegiao[nX][01]))
			RecLock("CCJ",.T.)
			CCJ->CCJ_FILIAL := xFilial("CCJ")
			CCJ->CCJ_CODIGO := aRegiao[nX][01]
			CCJ->CCJ_REGIAO := aRegiao[nX][02]
			MsUnLock()
		Endif

	Next

	RestArea(aArea)
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a994PTG   ºAutor  ³Microsiga           º Data ³  05/26/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a inclusao do Plano IVA para Portugal.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaFis                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A994PTG()

Local aArea := SFF->(GetArea())
Local lRet	:= .T.

dbSelectArea("SFF")
SFF->(dbSetOrder(14))
If SFF->(dbSeek(xFilial("SFF")+M->FF_IMPOSTO+M->FF_REGIAO+M->FF_GRPPRD))
	Help(" ",1,"A994PTG")
	lRet := .F.
EndIf

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ a994Imp  ³ Autor ³ Percy A Horna         ³ Data ³22/11/2001º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Permite a escolha de varios impostos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA994                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function a994Imp(cImposto)

Local oDlgPed, oDlgTran, nI, nAt
Private _lReturn := .T.
Private lConfirmo   := .F.
Private nTarget, aTarget, nSource, aSource, aBkTarget
Private nPosInc

nSource   := 0
nTarget   := 0
aSource   := {}
aTarget   := {}
aBkTarget := {}
nAt       := 0

DbSelectArea("SFB")
If BOF() .And. EOF()
	Help(" ",1,"NORECNO")
	_lReturn := .F.
Else

	nPosInc := Ascan(aHeader,{|x| Trim(x[2])=="FF_INCIMP"})

	If AT(";",aCols[n][nPosInc]) <= 0
		AADD(aBkTarget,SubStr(aCols[n][nPosInc],1,3 ))
	Else
		For nI := 1 To Len(Alltrim(aCols[n][nPosInc])) Step 4
			AADD(aBkTarget,SubStr(aCols[n][nPosInc],nI,AT(";",aCols[n][nPosInc])-1 ))
		Next
	EndIf

	SFB->(dbSeek(xFilial()))
	Do While .Not. SFB->(Eof())
		If 	Ascan(aBkTarget,SFB->FB_CODIGO) > 0
			AADD(aTarget,SFB->FB_CODIGO + " - " + SFB->FB_DESCR)
		Else
			AADD(aSource,SFB->FB_CODIGO + " - " + SFB->FB_DESCR)
		EndIf
		SFB->(dbSkip())
	Enddo

	lConfirmo   := .F.
	oFntBox := TFont():New( "Courier New", 6,0)
	cCab    := STR0110
	DEFINE MSDIALOG oDlgPed FROM 105,074 To 300,712 TITLE STR0105 PIXEL//"Seleccione los impuestos"
	oCab1 := TSay():New(006,010,{||cCab},oDlgPed,,oFntBox,,,,.t.)
	oCab2 := TSay():New(006,180,{||cCab},oDlgPed,,oFntBox,,,,.t.)
	oSource := TListBox():New( 014,010,{|u| If(PCount()==0,nSource,nSource:=u)},aSource,130,65,,oDlgPed,,,,.T.,,,oFntBox)
	oTarget := TListBox():New( 014,180,{|u| If(PCount()==0,nTarget,nTarget:=u)},aTarget,130,65,,oDlgPed,,,,.T.,,,oFntBox)
	@ 020,146 Button OemToAnsi(STR0106) + " >" Size 29,12 Action AddItemIB() of oDlgPed PIXEL    //"_Incluir >>"
	@ 034,146 Button "< " + OemToAnsi(STR0107) Size 29,12 Action RemItemIB() of oDlgPed PIXEL  //"<< _Sacar"
	@ 048,146 Button OemToAnsi(STR0108) + " >>" Size 29,12 Action AddAllIB() of oDlgPed PIXEL  //"Todos ->"
	@ 062,146 Button "<< " + OemToAnsi(STR0108) Size 29,12 Action RemAllIB() of oDlgPed PIXEL  //"<- Todos"
	DEFINE SBUTTON FROM 083,250  Type 1 Action (lConfirmo   := .T.,_lReturn := .T.,oDlgPed:End()) enable
	DEFINE SBUTTON FROM 083,280  Type 2 Action oDlgPed:End() enable
	Activate DIALOG oDlgPed CENTERED
	oFntBox:End()

	If lConfirmo
		Processa({|| CargaImpIB()},,OemToAnsi(STR0109))  //"Cargando Impuestos..."
	EndIf

EndIf

Return(_lReturn)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³AddItemIB º Autor ³ Percy A Horna      º Data ³  22/11/2001 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Adiciona um item a lista target e remove da lista Source   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso		 ³ Espec¡fico para clientes Microsiga						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AddItemIB()

Local nNewTam

If nSource != 0
	aAdd(aTarget,aSource[nSource])
	oTarget:SetItems(aTarget)
	nNewTam := Len(aSource) - 1
	aSource := aSize(aDel(aSource,nSource),nNewTam)
	If nSource   >  Len(aSource)
		nDown  := Len(aSource)
	Else
		nDown := nSource
	EndIf
	oSource:SetItems(aSource)
	If nDown  >  0
		oSource:Select(nDown)
	EndIf
	oSource:SetFocus()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³RemItemIB º Autor ³ Percy A Horna      º Data ³  22/11/2001 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Remove um item da lista Target e adiciona a lista Source   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso		 ³ Espec¡fico para clientes Microsiga						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RemItemIB()

Local nNewTam

If nTarget != 0
	aAdd(aSource,aTarget[nTarget])
	aSort(aSource)
	oSource:SetItems(aSource)
	nNewTam := Len(aTarget) - 1
	aTarget := aSize(aDel(aTarget,nTarget), nNewTam)
	If nTarget   >  Len(aTarget)
		nDown  := Len(aTarget)
	Else
		nDown := nTarget
	EndIf
	oTarget:SetItems(aTarget)
	If nDown  >  0
		oTarget:Select(nDown)
	EndIf
	oTarget:SetFocus()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³AddAllIB  º Autor ³ Percy A Horna      º Data ³  22/11/2001 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Adiciona todos os itens da lista Source para a lista targetº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso		 ³ Espec¡fico para clientes Microsiga						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AddAllIB()

Local nB

For nB   := 1 To Len(aSource)
	Aadd(aTarget,aSource[nB])
Next

aSource  := {}
oSource:SetItems(aSource)
oTarget:SetItems(aTarget)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RemAllIB  º Autor ³ Percy A Horna      º Data ³  22/11/2001 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Remove todos os itens da lista target                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso		 ³ Espec¡fico para clientes Microsiga						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RemAllIB()

Local nB

For nB   := 1 To Len(aTarget)
	Aadd(aSource,aTarget[nB])
Next

aTarget  := {}
oSource:SetItems(aSource)
oTarget:SetItems(aTarget)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³CargaImpIBº Autor ³ Percy A Horna      º Data ³  22/11/2001 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Remove um item da lista Target e adiciona na lista Source  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso		 ³ Espec¡fico para clientes Microsiga						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function CargaImpIB

Local nI

ProcRegua(Len(aTarget))

aCols[n][nPosInc] := ""
For nI := 1  To Len(aTarget)
	IncProc()
	If Empty(aCols[n][nPosInc])
		aCols[n][nPosInc] := SubStr(aTarget[nI],1,3)
	Else
		If AT(SubStr(aTarget[nI],1,3),aCols[n][nPosInc]) <= 0
			aCols[n][nPosInc] := Alltrim(aCols[n][nPosInc]) + ";" +  SubStr(aTarget[nI],1,3)
		EndIf
	EndIf
Next

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |UPDICEBOL ³ Autor ³Liber De Esteban       ³ Data ³20.10.2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Criação do imposto ICE e TES com calculo do mesmo          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function UPDICEBOL(lSeek)

Local aSF4 		:= {}
Local aSFC		:= {}
Local cFilSF4	:= xFilial("SF4")
Local cFilSFC	:= xFilial("SFC")
Local nI		:= 0

DEFAULT lSeek := .T.

RecLock("SFB",lSeek)
Replace FB_FILIAL  With xFilial("SFB")
Replace FB_CODIGO  With "ICE"
Replace FB_DESCR   With "IMP. CONSUMOS ESPECIFICOS"
Replace FB_CPOLVRO With "5"
Replace FB_FORMENT With "M100ICE"
Replace FB_FORMSAI With "M460IC1"
Replace FB_COLBAS  With 1
Replace FB_COLVAL  With 1
Replace FB_ALIQ    With 1
Replace FB_DIAVENC With "30"
Replace FB_PERIODO With ""
Replace FB_JNS     With "N"
If (FieldPos("FB_TABELA") > 0 )
	Replace FB_TABELA  With ""
Endif
If (FieldPos("FB_INTEIC") > 0 )
	Replace FB_INTEIC  With "N"
EndIf
MsUnLock()

AADD(aSF4,{cFilSF4,"007","E","N","N","S","S","112","COMPRAS ICE         ",0.00,0.00,"N","N","","N","N","B","","","","","","1","","2" })
AADD(aSF4,{cFilSF4,"008","E","N","N","S","S","112","COMPRAS IVA Y ICE   ",0.00,0.00,"N","N","","N","N","B","","","","","","1","","2" })
AADD(aSF4,{cFilSF4,"507","S","N","N","S","S","511","VENTAS ICE          ",0.00,0.00,"N","N","","N","N","B","","","","","","1","","2" })
AADD(aSF4,{cFilSF4,"508","S","N","N","S","S","511","VENTAS IVA Y ICE    ",0.00,0.00,"N","N","","N","N","B","","","","","","1","","2" })

DbSelectArea("SF4")
SF4->(DbSetOrder(1))

For nI := 1 to Len(aSF4)

	If !SF4->(DbSeek(aSF4[nI][1]+aSF4[nI][2]))
		RecLock("SF4",.T.)
		Replace F4_FILIAL  With aSF4[nI][01]
		Replace F4_CODIGO  With aSF4[nI][02]
		Replace F4_TIPO    With aSF4[nI][03]
		Replace F4_IPI     With aSF4[nI][04]
		Replace F4_CREDIPI With aSF4[nI][05]
		Replace F4_DUPLIC  With aSF4[nI][06]
		Replace F4_ESTOQUE With aSF4[nI][07]
		Replace F4_CF      With aSF4[nI][08]
		Replace F4_TEXTO   With aSF4[nI][09]
		Replace F4_BASEICM With aSF4[nI][10]
		Replace F4_BASEIPI With aSF4[nI][11]
		Replace F4_PODER3  With aSF4[nI][12]
		Replace F4_CIAP    With aSF4[nI][13]
		Replace F4_LIVRO   With aSF4[nI][14]
		Replace F4_ATUTEC  With aSF4[nI][15]
		Replace F4_ATUATF  With aSF4[nI][16]
		Replace F4_TPIPI   With aSF4[nI][17]
		If (FieldPos("F4_DESTACA") > 0 )
			Replace F4_DESTACA   With aSF4[nI][18]
		Endif
		Replace F4_ICM     With aSF4[nI][19]
		Replace F4_CREDICM With aSF4[nI][20]
		Replace F4_LFICM   With aSF4[nI][21]
		Replace F4_GERALF  With aSF4[nI][23]
		If !Empty(aSF4[nI][24])
			Replace F4_TESDV   With aSF4[nI][24]
		EndIf
		Replace F4_QTDZERO With aSF4[nI][25]
		If Len(aSF4[nI]) > 25 .And. FieldPos("F4_TESNCC") > 0
			Replace F4_TESNCC   With aSF4[nI][26]
		EndIf
		MsUnLock()
	EndIf
Next nI

AADD(aSFC,{cFilSFC,"007","01","ICE","1","1","3","",0.00,"I","S","N"})
AADD(aSFC,{cFilSFC,"507","01","ICE","1","1","3","",0.00,"I","S","N"})
AADD(aSFC,{cFilSFC,"008","01","ICE","1","1","3","",0.00,"I","S","N"})
AADD(aSFC,{cFilSFC,"008","02","IVA","1","1","3","",0.00,"I","S","N"})
AADD(aSFC,{cFilSFC,"508","01","ICE","1","1","3","",0.00,"I","S","N"})
AADD(aSFC,{cFilSFC,"508","02","IVA","1","1","3","",0.00,"I","S","N"})

DbSelectArea("SFC")
SFC->(DbSetOrder(1))

For nI := 1 to Len(aSFC)

	If !SFC->(DbSeek(aSFC[nI][1]+aSFC[nI][02] + aSFC[nI][03]))
		RecLock("SFC",.T.)
		Replace FC_FILIAL  With aSFC[nI][01]
		Replace FC_TES     With aSFC[nI][02]
		Replace FC_SEQ     With aSFC[nI][03]
		Replace FC_IMPOSTO With aSFC[nI][04]
		Replace FC_INCDUPL With aSFC[nI][05]
		Replace FC_INCNOTA With aSFC[nI][06]
		Replace FC_CREDITA With aSFC[nI][07]
		Replace FC_INCIMP  With aSFC[nI][08]
		If (FieldPos("FC_BASE") > 0 )
			Replace FC_BASE    With aSFC[nI][09]
		Endif
		Replace FC_CALCULO With aSFC[nI][10]
		If (FieldPos("FC_LIQUIDO") > 0 )
			Replace FC_LIQUIDO With aSFC[nI][11]
		Endif
		If (FieldPos("FC_INTEIC") > 0 )
			Replace FC_INTEIC  With aSFC[nI][12]
		Endif
		If (FieldPos("FC_AGRBASE") > 0 )  .And. Len(aSFC[nI]) >= 13
			Replace FC_AGRBASE  With aSFC[nI][13]
		Endif
		MsUnLock()
	EndIf
Next nI

Return NIL

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994Zarate ¦ Autor ¦ Acacio Egas         ¦ Data ¦ 10/12/08 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina de manutencao da tasa por inspección de seguridad   ¦¦¦
¦¦¦          ¦ e higiene de la ciudad de Zarate.                          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Function A994ISI()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSELECTAREA("SA2")
SetPrvt("AFIXE,AROTINA,CCADASTRO,")

If SFF->(FieldPos("FF_RET_MUN")) > 0 .And. SA2->(FieldPos("A2_RET_MUN")) > 0 .And. SFE->(FieldPos("FE_RET_MUN")) > 0

aFixe := {{OemToAnsi(STR0006) ,"FF_NUM"},;    // Planilla
	  	   {OemToAnsi(STR0007) ,"FF_ITEM"},;   // Concepto
		   {OemToAnsi(STR0057) ,"FF_CFO"},;  // CFO
		   {OemToAnsi(STR0010) ,"FF_CONCEPT"} }  // Descricion

aRotina := {{ OemToAnsi(STR0001),"AxPesqui"		,0,1,0,.F.},;		// Buscar
			{ OemToAnsi(STR0002),'A994Zara'	,0, 2,0,NIL},;		// Visualizar
			{ OemToAnsi(STR0003),'A994Zara'	,0, 3,0,NIL},;		// Incluir
			{ OemToAnsi(STR0004),'A994Zara'	,0, 4,0,NIL},;		// Modificar
			{ OemToAnsi(STR0005),'A994Zara'	,0, 5,0,NIL} }		// Borrar


cCadastro := OemToAnsi(STR0011)  // Planilla de Ganancias/Fondo Cooperativo

//+--------------------------------------------------------------+
//¦ Prepara o SFF para filtrar os registro para Zarate...        ¦
//+--------------------------------------------------------------+
dbSelectArea("SFF")
dbSetOrder(1)
dbSetFilter({|| FF_FILIAL==xFilial('SFF') .and. FF_RET_MUN<>''},"FF_FILIAL==xFilial('SFF') .and. !Empty(FF_RET_MUN)")
//dbSetFilter({|| FF_FILIAL==xFilial('SFF') .and. FF_IMPOSTO=='ISI'},"FF_FILIAL==xFilial('SFF') .and. FF_IMPOSTO=='ISI'")
dbGoTop()

//+--------------------------------------------------------------+
//¦ Pesquisa Especifica pelo Nome Reduzido indice 4              ¦
//+--------------------------------------------------------------+
mBrowse( 6, 1,22,75,"SFF",aFixe)

dbSelectArea("SFF")
dbClearFilter()
dbSetOrder(1)
Else
	MsgAlert(OemToAnsi(STR0150 + STR0130))//"No se encontraron los campos para la configuracion de las "
Endif

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994Zara   ¦ Autor ¦ Acacio Egas         ¦ Data ¦ 10/12/08 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Vizualização, Inclusao, Alteração e Exclusão da Tabela de  ¦¦¦
¦¦¦          ¦ tasa por inspección de seguridad e higiene de              ¦¦¦
¦¦¦          ¦ la ciudad de Zarate.                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

Function A994Zara(cAlias,nReg,nOpcx)

Local nX := 0
Local nY := 0
Local nI := 0
Local aRecnos := {}
Local lExistSFF := .F.
Local nPos:= 0
Local nPosCfoC := 0
Local nPosCfoV := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("AHEADER,ACOLS")
SetPrvt("CTABELA,CMESDESDE,CMESATE,CPLANILLA,NTOTALITENS,CTITULO")
SetPrvt("AC,AR,ACGD,CLINHAOK,CTUDOOK,AGETEDIT")
SetPrvt("LRETMOD2,NOPCA,NMAXARRAY,NY,NCNTITEM,NX")
SetPrvt("CVAR,AROTINA,CCADASTRO,AHEADESCALA")
SetPrvt("ACOLSESCALA")

//+--------------------------------------------------------------+
//¦ Inicializar o proximo numero da Tabela.                      ¦
//+--------------------------------------------------------------+
If nOpcx==3
	DbselectArea("SFF")
	dbSetFilter({|| FF_FILIAL==xFilial('SFF') .and. FF_RET_MUN<>''},"FF_FILIAL==xFilial('SFF') .and. !Empty(FF_RET_MUN)")
	DbGoTop()
	While !SFF->(Eof()) .and. SFF->FF_FILIAL==xFilial('SFF')
		If !Empty(SFF->FF_RET_MUN)
			lExistSFF := .T.
			Exit
		Endif
		SFF->(DbSkip())
	EndDo
	If  lExistSFF
		MsgBox( OemToAnsi(STR0171), OemToAnsi(STR0050),STR0180 ) //"Tabla de Retenciones Municipales ya existe." - "Atencion" - "INFO"
		Return
	EndIf
EndIf
//aYesFields := {"FF_ITEM","FF_CONCEPT","FF_CFO","FF_ALQINSC","FF_ALQNOIN","FF_IMPORTE","FF_ESCALA","FF_SERIENF"}
aYesFields := {/*"FF_ALIQ",*/"FF_CFO_C","FF_CFO_V","FF_IMPORTE","FF_CONCEPT","FF_INCIMP"}
aYesEscala := {"FF_ITEM",            "FF_CFO","FF_FXDE","FF_FXATE","FF_RETENC","FF_PERC","FF_EXCEDE","FF_IMPORTE"}

If  SFF->(FieldPos("FF_RET_MUN")) > 0 .And. SA2->(FieldPos("A2_RET_MUN")) > 0 .And. SFE->(FieldPos("FE_RET_MUN")) > 0
	aYesFields := {"FF_CFO_C", "FF_CFO_V", "FF_IMPORTE", "FF_CONCEPT", "FF_IMPOSTO", "FF_RET_MUN", "FF_INCIMP","FF_ALIQ"}
	aYesEscala := {"FF_CFO_C", "FF_CFO_V", "FF_IMPORTE", "FF_CONCEPT", "FF_IMPOSTO", "FF_RET_MUN", "FF_INCIMP"}
EndIf

//+--------------------------------------------------------------+
//¦ Montando array de Conceptos...                               ¦
//+--------------------------------------------------------------+
/*
aConceptos := {}
AADD(aConceptos,OemToAnsi(STR0037) ) // "INTERESES POR OPERACIONES EN ENTIDADES FINANCIERAS, AGENTES DE BOLSA O MERCADO ABERTO             "
AADD(aConceptos,OemToAnsi(STR0038) ) // "INTERESES POR FINANCIAMENTO O EVENTUALES INCUMPLIMIENTOS                                          "
AADD(aConceptos,OemToAnsi(STR0039) ) // "OTROS INTERESES                                                                                   "
AADD(aConceptos,OemToAnsi(STR0040) ) // "ALQUILERES DE BIENES MUEBLES E INMUEBLES                                                          "
AADD(aConceptos,OemToAnsi(STR0041) ) // "REGALIAS UTILIDADES E INTERESES DE COOPERATIVAS (EXCEPTO LAS DE CONSUMO); OBLIGACIONES DE NO HACER"
AADD(aConceptos,OemToAnsi(STR0042) ) // "VENTA DE BIENES DE CAMBIO, BIENES MUEBLES; LOCACIONES DE OBRA Y/O SERVICIOS; TRANSFERENCIA DEFINIT";
                                     //+"IVA DE LLAVES, MARCAS, PATENTES DE INVENCION, REGALIAS, CONCESION Y SIMILARES                     "

AADD(aConceptos,OemToAnsi(STR0043) ) // "EJERCICIO DE PROFESIONES LIBERALES U OFICIOS; SINDICO; MANDATARIO; DIRECTOR DE SOCIEDADES ANONIMAS";
                                     //+"; CORREDOR; VIAJANTE DE COMERCIO Y DESPACHANTE DE ADUANA                                          "
AADD(aConceptos,OemToAnsi(STR0044) ) // "PAGOS EFECTUADOS POR CADA ADMINISTRACION DESCENTRALIZADA, CAJA CHICA O FONDO FIJO                 "
AADD(aConceptos,OemToAnsi(STR0045) ) // "TRANSPORTE DE CARGA INTERNACIONAL                                                                 "
AADD(aConceptos,OemToAnsi(STR0046) ) // "OPERACIONES REALIZADAS A TRAVES DE MERCADOS DE CEREALES A TERMINO                                 "
AADD(aConceptos,OemToAnsi(STR0047) ) // "LOCACION DE DERECHOS, DISTRIBUCION DE PELICULAS CINEMATOGRAFICAS                                  "
AADD(aConceptos,OemToAnsi(STR0048) ) // "RETENCION MINIMA                                                                                  "
*/
//+--------------------------------------------------------------+
//¦ Montando aHeader                                             ¦
//+--------------------------------------------------------------+
aHeader:= GetaHeader("SFF",aYesFields/*aCpos*/,/*aCposNo*/,/*aEnchAuto*/,/*aCposVisual*/,.T./*lWalk_Thru*/)

nPosCfoC := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_CFO_C" })
nPosCfoV := aScan(aHeader,{|x| Alltrim(x[2]) == "FF_CFO_V" })

If nPosCfoC > 0 .AND. nPosCfoV > 0
	aHeader[nPosCfoC,6] := "ExistCpo('SX5','13'+M->FF_CFO_C) .OR. Vazio()"
	aHeader[nPosCfoV,6] := "ExistCpo('SX5','13'+M->FF_CFO_V) .OR. Vazio()"
Endif

dbSetOrder(1)

If  nOpcx ==3
	aCols	:={}
	aAdd(aCols,Array(Len(aHeader) + 1))
	AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"FF_ALI_WT|FF_REC_WT",NIL,CriaVar(AllTrim(x[2])) ) })
	aCols[1,Len(aHeader) + 1] := .F.
	cTabela   := "000001"
	cMesDesde := Space(04)
	cMesAte   := Space(04)
Else
	DbselectArea("SFF")
	dbSetFilter({|| FF_FILIAL==xFilial('SFF') .and. FF_RET_MUN<>''},"FF_FILIAL==xFilial('SFF') .and. !Empty(FF_RET_MUN)")
	DbGoTop()
		aCols	:={}
		While !SFF->(Eof()) .and. SFF->FF_FILIAL==xFilial('SFF')
			If !Empty(SFF->FF_RET_MUN)
			//While !SFF->(Eof()) .and. SFF->FF_FILIAL==xFilial('SFF') .and. SFF->FF_IMPOSTO=='ISI'

				aAdd(aCols,Array(Len(aHeader) + 1))
				aAdd(aRecnos, Recno() )
				AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"FF_ALI_WT|FF_REC_WT", NIL , SFF->(FieldGet(FieldPos(x[2]))) ) })
				aCols[Len(aCols),Len(aHeader) + 1] := .F.
				cTabela   := SFF->FF_NUM
				cMesDesde := SFF->FF_DESDE
				cMesAte   := SFF->FF_ATE
			Endif
			DbSkip()
		EndDo
EndIf

//+--------------------------------------------------------------+
//¦ Montando aCols                                               ¦
//+--------------------------------------------------------------+

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+

cPlanilla := "ISI"

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens:=0

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:= OemToAnsi("Retenciones Municipales")
//cTitulo:= OemToAnsi("Retencion de Inspeccíon de Seguridad e Higiene de Zarate") // "Retencion de Inspeccíon de Seguridad e Higiene de Zarate"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!","A994VTabla()",,.F.})  //"Nr. Tabla"
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,}) //"Fecha desde:"
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,}) //"Fecha hasta:"

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0055),"@E 999",,,.F.}) // "Total de Conceptos"

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={75,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+

cLinhaOk:= "VldRetMun()"
cTudoOk :="VldRetMun()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou
lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,".T.",,,,SFF->(Reccount())+100)

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente
If lRetMod2 .and. (nOpcx>=3)

	//+--------------------------------------------------------------+
	//¦ Edicao e Visualizacao da Escala Aplicable (1).               ¦
	//+--------------------------------------------------------------+
	nOpca := 0
	//EscalaInc()
	//If nOpca != 1
	//	Return
	//EndIf

	//+--------------------------------------------------------------+
	//¦ Atualiza o Corpo da Tabela                                   ¦
	//+--------------------------------------------------------------+
	dbSelectArea("SFF")
	nMaxArray := Len(aCols)

	nCntItem:= 1
	For nx := 1 to nMaxArray
		IF !aCols[nx][Len(aCols[nx])] .and. nOpcx<>5

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do tabela.                                    ¦
			//+--------------------------------------------------------------+
			dbSelectArea("SFF")
			If nOpcx==4 .and. Len(aRecnos)>=nx
				DbGoto(aRecnos[nx])
				RecLock("SFF",.F.)
			Else
				RecLock("SFF",.T.)
			EndIf

			Replace 	FF_FILIAL  With xFilial("SFF"),;
			       		FF_NUM     With cTabela,;
						FF_DESDE   With cMesDesde,;
						FF_ATE	   With cMesAte
						//FF_IMPOSTO With "ISI"


			//+--------------------------------------------------------------+
			//¦ Atualiza dados do corpo da Tabela.                           ¦
			//+--------------------------------------------------------------+
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
				Endif
			Next ny
			dbUnLock()

			nCntItem:=nCntItem + 1
		ElseIf nOpcx>=4 .and. Len(aRecnos)>=nx
			DbGoTo( aRecnos[nx] )
			RecLock("SFF",.F.,.T.)
				DbDelete()
			MsUnlock()
		EndIF
	Next nx

Endif
//+-------------------------------------------------------+
//¦ Forçar o array aRotina para dribar a funcao ExecBrow. ¦
//+-------------------------------------------------------+
SFF->(DbSetOrder(1))
aRotina[3][4] := 0

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A994AjMon ºAutor  ³Marcos Berto        º Data ³  17/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Preenchimento dos conceitos de Ganancia padrao para        º±±
±±º          ³ monotributista.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A994AjMon(cTabela)

//Valores iniciais definidos pela resolucao(AFIP) 2549/2009

dbSelectArea("SFF")
dbSetOrder(1)

//Locaciones
If !dbSeek(xFilial("SFF")+cTabela+"G1")
	If SFF->(FieldPos("FF_LIMITE"))>0 .And. SFF->(FieldPos("FF_MINUNIT"))>0
		RecLock("SFF",.T.)
		Replace FF_FILIAL 	With xFilial("SFF")
		Replace FF_NUM 		With cTabela
		Replace FF_ITEM 	With "G1"
		Replace FF_DESDE 	With "0104"
		Replace FF_CONCEPT With STR0114
		Replace FF_IMPOSTO With "GAN"
		Replace FF_TIPO 	With "M"
		Replace FF_IMPORTE With 1200
		Replace FF_ALQNOIN With 28
		Replace FF_LIMITE 	With 72000
		Replace FF_MINUNIT With 0
	Endif
Endif

//Cosas Muebles
If !dbSeek(xFilial("SFF")+cTabela+"G2")
	If SFF->(FieldPos("FF_LIMITE"))>0 .And. SFF->(FieldPos("FF_MINUNIT"))>0
		RecLock("SFF",.T.)
		Replace FF_FILIAL 	With xFilial("SFF")
		Replace FF_NUM 		With cTabela
		Replace FF_ITEM 	With "G2"
		Replace FF_DESDE 	With "0104"
		Replace FF_CONCEPT With STR0115
		Replace FF_IMPOSTO With "GAN"
		Replace FF_TIPO 	With "M"
		Replace FF_IMPORTE With 12000
		Replace FF_ALQNOIN With 10
		Replace FF_LIMITE 	With 144000
		Replace FF_MINUNIT With 870
	Endif
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A994IGV   ºAutor  ³ROBERTO ROGÉRIO MEZZALIRA º Data ³ 29/11/09º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                              º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A994IGV()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

PRIVATE cCadastro := STR0111 //"Config. Adicional. Impuestos"
PRIVATE cAlias  := "SFF"

PRIVATE aRotina := {}
PRIVATE aFixe   := {}


aFixe   := {{OemToAnsi(STR0012) ,"FF_IMPOSTO"},; //Impuesto
	  	   {OemToAnsi(STR0074) ,"FF_ALIQ"},; //"Alicuota"
		   {OemToAnsi(STR0058) ,"FF_IMPORTE"}} //"Importe"

aRotina := {{ OemToAnsi(STR0001),"AxPesqui"		,0,1,0,.F.},;		// Buscar
			{ OemToAnsi(STR0002),'A994Avisigv'	,0, 2,0,NIL},;		// Visualizar
			{ OemToAnsi(STR0003),'A994Aincligv'	,0, 3,0,NIL},;		// Incluir
			{ OemToAnsi(STR0004),'A994Altigv'	,0, 4,0,NIL},;		// Modificar
			{ OemToAnsi(STR0005),'A994deligv'	,0, 5,0,NIL} }		// Borrar

//+--------------------------------------------------------------+
//¦ Prepara o SFF para filtrar os registro para Ganancias...     ¦
//+--------------------------------------------------------------+
dbSelectArea("SFF")
dbSetOrder(1)
dbGoTop()

//+--------------------------------------------------------------+
//¦ Pesquisa Especifica pelo Nome Reduzido indice 4              ¦
//+--------------------------------------------------------------+
mBrowse( 6, 1,22,75,"SFF",aFixe)

dbSelectArea("SFF")
dbClearFilter()
dbSetOrder(1)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a994avisigv ºAutor  ³Roberto Rogerio Mezzalira º Data ³  29/1109  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                                  º±±
±±º          ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A994AVisigv(cAlias,nReg,nOpc)

Local aArea     := GetArea()
Local cCadastro := STR0151 //"Visualizacao Configuraçao Adicional de Imposto"
Local oSize
Local oDlg
Local nOpca    := 0
Private cImp      := CriaVar("FF_IMPOSTO")
Private nAliq     := CriaVar("FF_ALIQ")
Private nImporte  := CriaVar("FF_IMPORTE")

cImp      := SFF->FF_IMPOSTO
nAliq     := SFF->FF_ALIQ
nImporte  := SFF->FF_IMPORTE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o calculo automatico de dimensoes de objetos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New( .T. ) // Com enchoicebar
oSize:lLateral     := .F.  // Calculo vertical
oSize:Process()

DEFINE MSDIALOG oDlg TITLE cCadastro FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

@ oSize:aWindSize[1] + 35 ,oSize:aWindSize[2] TO (oSize:aWindSize[3] - 360) , (oSize:aWindSize[4] - 680) LABEL ''     OF oDlg PIXEL

@ oSize:aWindSize[1] + 50 , 10  SAY STR0152  OF oDlg PIXEL SIZE 065,010 //"Cod. Imposto: "
@ oSize:aWindSize[1] + 50 , 50  MSGET cImp  PICTURE PesqPict("SFF",'FF_IMPOSTO') WHEN .F.  OF oDlg PIXEL SIZE 060,010
@ oSize:aWindSize[1] + 70 , 10  SAY STR0153 OF oDlg PIXEL SIZE 065,010 //"Aliquota: "
@ oSize:aWindSize[1] + 70 , 50  MSGET nAliq PICTURE PesqPict('SFF','FF_ALIQ')     WHEN .F. OF oDlg PIXEL SIZE 060,010
@ oSize:aWindSize[1] + 90 , 10  SAY STR0154 OF oDlg PIXEL SIZE 065,010 //"Importe: "
@ oSize:aWindSize[1] + 90 , 50  MSGET nImporte PICTURE PesqPict('SFF','FF_IMPORTE')  WHEN .F. OF oDlg PIXEL  SIZE 060,010

ACTIVATE MSDIALOG oDlg  ON INIT M994IGVBAR(oDlg,{||nOpcA:=1,oDlg:End()},{||oDlg:End()},nOpcA) CENTERED

RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M994IGVBAR ³ Autor ³ ROBERTO R.MEZZALIRA  ³ Data ³ 29.11.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ EnchoiceBar especifica do MATA994                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oDlg: 	Objeto Dialog                                     ³±±
±±³          ³ bOk:  	Code Block para o Evento Ok                       ³±±
±±³          ³ bCancel: Code Block para o Evento Cancel                   ³±±
±±³          ³ nOpc:		nOpc transmitido pela mbrowse                 ³±±
±±³          ³ aForma: Array com as formas de pagamento                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M994IGVBAR(oDlg,bOk,bCancel,nOpc)

Local aButtons  := {}

Return (EnchoiceBar(oDlg,bOK,bCancel,,aButtons))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A994INCLIGV ºAutor  ³ROBERTO ROGERIO MEZZALIRA  º Data ³  29/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                                     º±±
±±º          ³                                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A994Aincligv(cAlias,nReg,nOpc)

Local aArea     := GetArea()
Local cCadastro := STR0155 //"Cadastrar Configuraçao Adicional de Imposto"
Local oSize
Local oDlg      := Nil
Local nOpca     := 0
Private cImp    := CriaVar("FF_IMPOSTO")
Private nAliq   := CriaVar("FF_ALIQ")
Private nImporte:= CriaVar("FF_IMPORTE")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o calculo automatico de dimensoes de objetos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New( .T. ) // Com enchoicebar
oSize:lLateral     := .F.  // Calculo vertical
oSize:Process()

DEFINE MSDIALOG oDlg TITLE cCadastro FROM oSize:aWindSize[1] , oSize:aWindSize[2] TO oSize:aWindSize[3] , oSize:aWindSize[4] PIXEL

@ oSize:aWindSize[1] + 35 ,oSize:aWindSize[2] TO (oSize:aWindSize[3] - 360) , (oSize:aWindSize[4] - 680) LABEL ''     OF oDlg PIXEL

@ oSize:aWindSize[1] + 50 , 10  SAY STR0152  OF oDlg PIXEL SIZE 065,010 //"Cod. Imposto: "
@ oSize:aWindSize[1] + 50 , 50  MSGET cImp  PICTURE PesqPict("SFF",'FF_IMPOSTO') WHEN .T.  OF oDlg PIXEL SIZE 060,010
@ oSize:aWindSize[1] + 70 , 10  SAY STR0153 OF oDlg PIXEL SIZE 065,010 //"Aliquota: "
@ oSize:aWindSize[1] + 70 , 50  MSGET nAliq PICTURE PesqPict('SFF','FF_ALIQ')     WHEN .T. OF oDlg PIXEL SIZE 060,010
@ oSize:aWindSize[1] + 90 , 10  SAY STR0154 OF oDlg PIXEL SIZE 065,010 //"Importe: "
@ oSize:aWindSize[1] + 90 , 50  MSGET nImporte PICTURE PesqPict('SFF','FF_IMPORTE')  WHEN .T. OF oDlg PIXEL  SIZE 060,010

ACTIVATE MSDIALOG oDlg ON INIT M994IGVBAR(oDlg,{||nOpcA:=1,oDlg:End()},{||oDlg:End()},nOpcA) CENTERED

If ( nOpcA == 1 )

	Begin Transaction

    	DbSelectArea("SFF")
		DbSetOrder(9) //FF_FILIAL+FF_IMPOSTO+FF_GRUPO
		IF DbSeek(xFilial("SFF")+cImp)
	     	MsgInfo(STR0156,STR0157)//"Atencion impuesto ya existe, utilize otro codigo." ##"Atencion, Impuesto ya existe."
	  	Else
			RecLock( "SFF", .T. )

				SFF->FF_FILIAL   := xFilial("SFF")
				SFF->FF_NUM		 := GETSX8NUM("SFF","FF_NUM")
				SFF->FF_ITEM	 := "01"
				SFF->FF_IMPOSTO  := cImp
				SFF->FF_ALIQ     := nAliq
				SFF->FF_IMPORTE  := nImporte
				SFF->FF_MOEDA    := 1

			MSUNLOCK()
			ConfirmSX8()
	    Endif

	End Transaction

Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A994ALTIGVºAutor  ³ROBERTO ROGERIO MEZZALIRA  º Data ³  29/11/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                                 º±±
±±º          ³                                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A994Altigv()
Local aArea     := GetArea()
Local cCadastro := STR0158 //"Alterar Configuraçao Adicional de Imposto"
Local oSize
Local oDlg      := Nil
Local nOpca     := 0

Private cImp      := CriaVar("FF_IMPOSTO")
Private nAliq     := CriaVar("FF_ALIQ")
Private nImporte  := CriaVar("FF_IMPORTE")
Private cNum  	  := Criavar("SFF->FF_NUM")
Private cItem     := Criavar("FF_ITEM")


cImp      := SFF->FF_IMPOSTO
nAliq     := SFF->FF_ALIQ
nImporte  := SFF->FF_IMPORTE
cNum  	  := SFF->FF_NUM
cItem     := SFF->FF_ITEM


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o calculo automatico de dimensoes de objetos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New( .T. ) // Com enchoicebar
oSize:lLateral     := .F.  // Calculo vertical
oSize:Process()

DEFINE MSDIALOG oDlg TITLE cCadastro FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

@ oSize:aWindSize[1] + 35 ,oSize:aWindSize[2] TO (oSize:aWindSize[3] - 360) , (oSize:aWindSize[4] - 680) LABEL ''     OF oDlg PIXEL

@ oSize:aWindSize[1] + 50 , 10  SAY STR0152  OF oDlg PIXEL SIZE 065,010 //"Cod. Imposto: "
@ oSize:aWindSize[1] + 50 , 50  MSGET cImp  PICTURE PesqPict("SFF",'FF_IMPOSTO') WHEN .F.  OF oDlg PIXEL SIZE 060,010
@ oSize:aWindSize[1] + 70 , 10  SAY STR0153 OF oDlg PIXEL SIZE 065,010 //"Aliquota: "
@ oSize:aWindSize[1] + 70 , 50  MSGET nAliq PICTURE PesqPict('SFF','FF_ALIQ')     WHEN .T. OF oDlg PIXEL SIZE 060,010
@ oSize:aWindSize[1] + 90 , 10  SAY STR0154 OF oDlg PIXEL SIZE 065,010 //"Importe: "
@ oSize:aWindSize[1] + 90 , 50  MSGET nImporte PICTURE PesqPict('SFF','FF_IMPORTE')  WHEN .T. OF oDlg PIXEL  SIZE 060,010

ACTIVATE MSDIALOG oDlg ON INIT M994IGVBAR(oDlg,{||nOpcA:=1,oDlg:End()},{||oDlg:End()},nOpcA) CENTERED

If ( nOpcA == 1 )

	Begin Transaction

    	DbSelectArea("SFF")
		DbSetOrder(9) //FF_FILIAL+FF_IMPOSTO+FF_GRUPO
		IF DbSeek(xFilial("SFF")+cImp)

	     	RecLock( "SFF", .F. )

				SFF->FF_FILIAL   := xFilial("SFF")
				SFF->FF_NUM		 :=	cNum
		        SFF->FF_ITEM	 := cItem
				SFF->FF_IMPOSTO  := cImp
				SFF->FF_ALIQ     := nAliq
				SFF->FF_IMPORTE  := nImporte
				SFF->FF_MOEDA    := 1

			MSUNLOCK()

	  	Else

			RecLock( "SFF", .T. )

				SFF->FF_FILIAL   := xFilial("SFF")
	  			SFF->FF_NUM		 := GETSX8NUM("SFF","FF_NUM")
				SFF->FF_ITEM	 := "01"
				SFF->FF_IMPOSTO  := cImp
				SFF->FF_ALIQ     := nAliq
				SFF->FF_IMPORTE  := nImporte
				SFF->FF_MOEDA    := 1

			MSUNLOCK()

	    Endif

	End Transaction

Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A994DELIGVºAutor  ³ROBERTO ROGERIO MEZZALIRA  º Data ³  29/11/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                                 º±±
±±º          ³                                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A994deligv()
Local aArea     := GetArea()
Local cCadastro := STR0159 //"Excluir Configuraçao Adicional de Imposto"
Local oSize
Local oDlg      := Nil
Local nOpca     := 0

Private cImp      := CriaVar("FF_IMPOSTO")
Private nAliq     := CriaVar("FF_ALIQ")
Private nImporte  := CriaVar("FF_IMPORTE")
cImp      := SFF->FF_IMPOSTO
nAliq     := SFF->FF_ALIQ
nImporte  := SFF->FF_IMPORTE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz o calculo automatico de dimensoes de objetos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New( .T. ) // Com enchoicebar
oSize:lLateral     := .F.  // Calculo vertical
oSize:Process()

DEFINE MSDIALOG oDlg TITLE cCadastro FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

@ oSize:aWindSize[1] + 35 ,oSize:aWindSize[2] TO (oSize:aWindSize[3] - 360) , (oSize:aWindSize[4] - 680) LABEL ''     OF oDlg PIXEL

@ oSize:aWindSize[1] + 50 , 10  SAY STR0152  OF oDlg PIXEL SIZE 065,010 //"Cod. Imposto: "
@ oSize:aWindSize[1] + 50 , 50  MSGET cImp  PICTURE PesqPict("SFF",'FF_IMPOSTO') WHEN .F.  OF oDlg PIXEL SIZE 060,010
@ oSize:aWindSize[1] + 70 , 10  SAY STR0153 OF oDlg PIXEL SIZE 065,010 //"Aliquota: "
@ oSize:aWindSize[1] + 70 , 50  MSGET nAliq PICTURE PesqPict('SFF','FF_ALIQ')     WHEN .F. OF oDlg PIXEL SIZE 060,010
@ oSize:aWindSize[1] + 90 , 10  SAY STR0154 OF oDlg PIXEL SIZE 065,010 //"Importe: "
@ oSize:aWindSize[1] + 90 , 50  MSGET nImporte PICTURE PesqPict('SFF','FF_IMPORTE')  WHEN .F. OF oDlg PIXEL  SIZE 060,010

ACTIVATE MSDIALOG oDlg ON INIT M994IGVBAR(oDlg,{||nOpcA:=1,oDlg:End()},{||oDlg:End()},nOpcA) CENTERED

If ( nOpcA == 1 )

	Begin Transaction

    	DbSelectArea("SFF")
		DbSetOrder(9) //FF_FILIAL+FF_IMPOSTO+FF_GRUPO
		IF DbSeek(xFilial("SFF")+cImp)

	     	RecLock( "SFF", .F. )
					dbDelete()
			MSUNLOCK()

	    Endif

	End Transaction

Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A994MU   ºAutor  ³ Paulo Augusto      º Data ³  01/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tabela Genereica de Imposto Municipal                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A994MU()

SetPrvt("AFIXE,AROTINA,CCADASTRO,")

aFixe := { {OemToAnsi(STR0012) ,"FF_IMPOSTO"},;  // Impuesto
  		   {OemToAnsi(STR0013) ,"FF_SERIENF"},;  // Serie Fac.
		   {OemToAnsi(STR0057) ,"FF_CFO"  },;  // CFO Compras
		   {OemToAnsi(STR0008) ,"FF_CFO_C"  },;  // CFO Compras
		   {OemToAnsi(STR0009) ,"FF_CFO_V"  },;  // CFO Ventas
		   {OemToAnsi(STR0010) ,"FF_CONCEPT"} }  // Descricion

aYesFields := {"FF_IMPOSTO","FF_SERIENF","FF_CFO","FF_CFO_C","FF_CFO_V","FF_CONCEPT","FF_ALIQ","FF_IMPORTE"}

aRotina := {{ OemToAnsi(STR0001),"AxPesqui"		,0,1,0,.F.},;		// Buscar
			{ OemToAnsi(STR0002),'A994VisMU'	,0,2,0,NIL},;		// Visualizar
			{ OemToAnsi(STR0003),'A994IncMU'	,0,3,0,NIL},;		// Incluir
			{ OemToAnsi(STR0004),'A994AltMU'	,0,4,0,NIL},;		// Modificar
			{ OemToAnsi(STR0005),'A994DelMU'	,0,5,0,NIL} }		// Borrar

cCadastro := OemToAnsi(STR0172) //"Planilla de Impuesto Municipal"

//+--------------------------------------------------------------+
//¦ Prepara o SFF para filtrar os registro para IVA...           ¦
//+--------------------------------------------------------------+
dbSelectArea("SFF")
dbSetOrder(2)
dbSetFilter({|| FF_FILIAL==xFilial('SFF') .and. Subs(FF_IMPOSTO,1,2)$'TE|PMP'},"FF_FILIAL==xFilial('SFF') .and. Subs(FF_IMPOSTO,1,2)$'TE|PMP'")
dbGoTop()

//+--------------------------------------------------------------+
//¦ Pesquisa Especifica pelo Nome Reduzido indice 4              ¦
//+--------------------------------------------------------------+
mBrowse( 6, 1,22,75,"SFF",aFixe)

dbClearFilter()

dbSelectArea("SFF")
dbSetOrder(1)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A994VisII ºAutor  ³ Fabio Fongaro      º Data ³  01/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Visualiza Planilla de Impuestos Internos                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A994VisMU()

Local cSeek

SetPrvt("NOPCX,AHEADER,CTABELA,CMESDESDE,CMESATE")
SetPrvt("NCNT,ACOLS,NTOTALITENS,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2,")

nOpcx:=2

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela := SFF->FF_NUM
cMesDesde := SFF->FF_DESDE
cMesAte := SFF->FF_ATE
cImp      := SFF->FF_IMPOSTO

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
cSeek := xFilial("SFF")+cImp
nTotalItens := MyFillGet(nOpcx,3,cSeek)

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:= STR0173 //"Tabla de Impuesto Municipal"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!"      ,".T.",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,.F.})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,.F.})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk:="AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,".T.",".T.",,,,SFF->(Reccount())+100)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ a994IncIIºAutor  ³Fabio Fongaro       º Data ³  01/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclui Planilla Impuesto Interno                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A994IncMU()
Local nY := 0
Local nX := 0

SetPrvt("NOPCX,AHEADER,ACOLS,CTABELA,CMESDESDE")
SetPrvt("CMESATE,CPLANILLA,NTOTALITENS,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2,NMAXARRAY")
SetPrvt("NY,NCNTITEM,NX,CVAR,AROTINA,")

nOpcx:=3

//+--------------------------------------------------------------+
//¦ Inicializar o proximo numero da Tabela.                      ¦
//+--------------------------------------------------------------+
dbSelectArea("SFF")
dbSetOrder(3)
dbSeek(xFilial("SFF")+"TE")
If Found()
	MsgBox( OemToAnsi(STR0174),OemToAnsi(STR0050),STR0180 ) //"Planilla de TE ya existe." - "Atencion" - "INFO"
	Return
EndIf

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela   := "000001"
cMesDesde := Space(04)
cMesAte   := Space(04)

cPlanilla := OemToAnsi("TE")

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens := MyFillGet(nOpcx)

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:= OemToAnsi(STR0175) //"Tabla de Impuesto Municipal - Tucuman "

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!","A994VTabla()",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk:="AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou
lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,".T.",".T.",,,,SFF->(Reccount())+100)

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente

nIncMtr := 0 

If lRetMod2

	//+--------------------------------------------------------------+
	//¦ Atualiza o Corpo da Tabela                                   ¦
	//+--------------------------------------------------------------+
	dbSelectArea("SFF")
	nMaxArray := Len(aCols)
	For ny := 1 to Len(aHeader)
		If Empty(aCols[nMaxArray][ny]) .AND. Trim(aHeader[ny][2]) == "FF_IMPOSTO"
			nMaxArray := nMaxArray - 1
			Exit
		EndIf
	Next ny

	nCntItem:= 1
	For nx := 1 to nMaxArray
		IF !aCols[nx][Len(aCols[nx])]

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do tabela.                                    ¦
			//+--------------------------------------------------------------+
			dbSelectArea("SFF")
			RecLock("SFF",.T.)
			Replace FF_FILIAL  With xFilial("SFF"),;
			       	FF_NUM     With cTabela,;
					FF_DESDE   With cMesDesde,;
					FF_ATE	   With cMesAte

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do corpo da Tabela.                           ¦
			//+--------------------------------------------------------------+
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
				Endif
			Next ny
		    dbUnLock()

			nCntItem:=nCntItem + 1
			nIncMtr ++
		EndIF
	Next nx

	If nIncMtr > 0
		//Chamada da função para geração da metrica para inclusão
		M994Mtr("imp-mun","inclusão",nIncMtr)
	Endif

Endif

//+-------------------------------------------------------+
//¦ Forçar o array aRotina para dribar a funcao ExecBrow. ¦
//+-------------------------------------------------------+
aRotina[3][4] := 0

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ a994AltIIºAutor  ³Fabio Fongaro       º Data ³  01/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Altera Planilla Impuesto Interno                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A994AltMU()
Local nX := 0
Local nY := 0
Local cSeek

SetPrvt("NOPCX,AHEADER,CTABELA,CMESDESDE,CMESATE")
SetPrvt("CPLANILLA,NCNT,ACOLS,NTOTALITENS,NTOTITENSFF")
SetPrvt("CTITULO,AC,AR,ACGD,CLINHAOK,CTUDOOK")
SetPrvt("AGETEDIT,LRETMOD2,NMAXARRAY,NY,NCNTITEM,NX")
SetPrvt("CVAR,")

nOpcx:=4

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela   := SFF->FF_NUM
cMesDesde := SFF->FF_DESDE
cMesAte   := SFF->FF_ATE
cImp	  := SFF->FF_IMPOSTO

cPlanilla := OemToAnsi("II")

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
cSeek := xFilial("SFF")+cImp
nTotalItens := MyFillGet(nOpcx,3,cSeek)
nTotItensFF := nTotalItens

//Alterando função de validação do campo FF_IMPOSTO
If FindFunction("A994LOKII")
	aHeader[aScan(aHeader,{|x| Alltrim(x[2]) == "FF_IMPOSTO" })][6] := "A994LOKII(1)"
Endif
//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:= OemToAnsi(STR0176) //Tabla de Impuesto Interno

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!","A994VTabla()",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,.T.})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,.T.})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
//cLinhaOk:="A994BlinOk(2)"
cLinhaOk:= "AlwaysTrue()"
cLinhaOk:= "AlwaysTrue()"

cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou
lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,".T.",,,,SFF->(Reccount())+100)

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente
nIncMtr := 0
lAltMtr := .F.
nExcMtr := 0
If lRetMod2
   nCntItem:= 1
   For nx := 1 to Len(aCols)
		IF !aCols[nx][Len(aCols[nx])]
			//+--------------------------------------------------------------+
			//¦ Se e um iten novo, incluir-lo , senao so atualizar           ¦
			//+--------------------------------------------------------------+
         	If nX > nTotItensFF
				RecLock("SFF",.T.)
				nIncMtr ++
			Else
				SFF->(DbGoTo(aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "FF_REC_WT" })]))
				RecLock("SFF",.F.)
				
			Endif
			Replace FF_FILIAL  With xFilial("SFF"),;
			       	FF_NUM     With cTabela,;
					FF_DESDE   With cMesDesde,;
					FF_ATE	   With cMesAte
            //+--------------------------------------------------------------+
			//¦ Atualiza dados do corpo da Tabela.                           ¦
			//+--------------------------------------------------------------+
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
				Endif
			Next ny
		    MsUnLock()
			nCntItem:=nCntItem + 1
			lAltMtr := .T.
		Else
			If nX <=	nTotItensFF
				SFF->(DbGoTo(aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "FF_REC_WT" })]))
				RecLock("SFF",.F.)
				SFF->(DbDelete())
				MsUnLock()
				nExcMtr ++
			Endif
		Endif
	Next nX
	
	If nIncMtr > 0
		//Chamada da função para geração da metrica para inclusão
		M994Mtr("imp_mun","inclusão",nIncMtr)
	Endif
	If nExcMtr > 0
		//Chamada da função para geração da metrica para exclusão
		M994Mtr("imp_mun","exclusão",nExcMtr)
	Endif
	If lAltMtr
		//Chamada da função para geração da metrica para alteração
		M994Mtr("imp_mun","alteração",1)
	Endif
	
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A995DelII ºAutor  ³ Fabio Fongaro      º Data ³  01/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exclusao de Planilla de Impuesto Interno                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A994DelMU()

Local cSeek

SetPrvt("NOPCX,AHEADER,CTABELA,CMESDESDE,CMESATE")
SetPrvt("NCNT,ACOLS,NTOTALITENS,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2,")

nOpcx:=5

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela	  := SFF->FF_NUM
cMesDesde := SFF->FF_DESDE
cMesAte   := SFF->FF_ATE
cImp      := SFF->FF_IMPOSTO

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
cSeek := xFilial("SFF")+cImp
nTotalItens	:= MyFillGet(nOpcx,3,cSeek)

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo:= OemToAnsi(STR0176) //"Tabla de Impuesto Interno"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!"      ,".T.",,.F.}) // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,.F.}) // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,.F.}) // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk:="AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,".T.",".T.",,,,SFF->(Reccount())+100)

nExcMtr := 0

If lRetMod2

	//+--------------------------------------------------------------+
	//¦ Excluir os registros da tabela  SFF.                         ¦
	//+--------------------------------------------------------------+
	dbSelectArea("SFF")
	dbSetOrder(3)
	dbSeek(xFilial("SFF")+cImp)
	If Found()
		While !EOF() .And. FF_FILIAL+FF_IMPOSTO == xFilial("SFF")+cImp
			RecLock("SFF",.F.)
			dbDelete()
			dbUnLock()
			dbSkip()
			nExcMtr ++
		End
	EndIf
	If nExcMtr > 0
		//Chamada da função para geração da metrica para exclusão
		M994Mtr("imp_mun","exclusão",nExcMtr)
	Endif
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A994LOKII ºAutor  ³ Fabio Fongaro      º Data ³  01/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao do LinkOK e Campo OK para Impuestos Internos     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A994LOKMU(nParam)
Local nV := 0

SetPrvt("LRET,NV,")

lRet	:=	.T.
Do Case
Case nParam	==	1 //VALIDA CAMPO FF_IMPOSTO
	If (Subs(M->FF_IMPOSTO,1,3)#'TE')
		MsgStop(OemToAnsi(STR0177)) //" El codigo de Impuesto debe comenzar con TE."
		lRet	:=	.F.
	Endif
Case nParam	==	2 // Valida LINHAOK
	For nV :=1  to  5
		If !aCOLS[n][Len(aCols[n])].And.Empty(aCols[n][nV])
			Help(" ",1,"OBRIGAT")
			nV		:=	5
			lRet	:=	.F.
		Endif
	Next
EndCase
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a994VLTp	ºAutor  ³ William P. Alves   º Data ³  11/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao do LinkOK e Campo OK para Impuestos Internos     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a994VLTp()
Local lRet:=.T.
Local nPosImp :=aScan(aHeader,{|x| Alltrim(x[2]) == "FF_IMPOSTO" })
Local lInfImp := Iif(nPosImp > 0, .T., .F.) //Imposto informado na tela de configuração ou não.

If lInfImp
	If  "IB" $ aCols[n][nPosImp]
		lRet:=&(ReadVar())$ "INXVM*"
	Else
		lRet:=&(ReadVar())$ "INXEFSM*"
	EndIf
Else //Se o imposto não for informado na tela, atribui a validação padrão
	lRet:=&(ReadVar())$ "INXEFSM*"
Endif
If !lRet
	MsgStop(STR0118)
EndIf
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  A994VEN	ºAutor  ³ Felipe C. Seolin   º Data ³  24/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. ³ Criação de tela e rotinas para Venezuela(Plano IR - Conceitos) º±±
±±º      ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso   ³ Venezuela                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A994VEN()
	cCadastro	:= OemToAnsi(STR0122)
	aRotina		:= MenuDef()

	DBSelectArea("SFF")
	DBSetOrder(1)
	DBGoTop()
	mBrowse(6,1,22,75,"SFF")
	DBSelectArea("SFF")
	DBClearFilter()
	DBSetOrder(1)
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATA994   ºAutor  ³Microsiga           º Data ³  10/26/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A994VldLim()

Local lReturn := .T.


If Type("M->FF_TIPO") <> "U" .And. Type("M->FF_TPLIM") <> "U"
	If M->FF_TIPO == "M" .And. M->FF_TPLIM <> "1"
		lReturn := .F.
		MsgAlert(STR0128)
	EndIf
EndIf
Return lReturn
/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf100  ¦ Autor ¦ Marivaldo             ¦ Data ¦ 25/03/13 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Tabela de Generica de Caja Medica.                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
30/07/99 JOSE LUIS - trata de CFO Compras e Vendas
*/
Function A994GENE()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("AFIXE,AROTINA,CCADASTRO,")

aFixe := { {OemToAnsi(STR0012) ,"FF_IMPOSTO"},;  // Impuesto
		   {OemToAnsi(STR0015) ,"FF_ZONFIS" },;  // Zona Fiscal
		   {OemToAnsi(STR0008) ,"FF_CFO_C"  },;  // CFO Compras
		   {OemToAnsi(STR0009) ,"FF_CFO_V"  },;  // CFO Ventas
 		   {OemToAnsi(STR0010) ,"FF_CONCEPT"} }  // Descricion

If SFF->(FieldPos("FF_INCIMP")) > 0
	aYesFields := {"FF_IMPOSTO","FF_ZONFIS","FF_CFO_C","FF_CFO_V","FF_CONCEPT","FF_ALIQ","FF_IMPORTE","FF_TIPO","FF_PRALQIB","FF_INCIMP","FF_FORMAPG","FF_DESCFOR","FF_ALIQPAG","FF_VALMIN"}// verificar pq no deleta tem menos campos
Else
	aYesFields := {"FF_IMPOSTO","FF_ZONFIS","FF_CFO_C","FF_CFO_V","FF_CONCEPT","FF_ALIQ","FF_IMPORTE","FF_TIPO","FF_PRALQIB","FF_FORMAPG","FF_DESCFOR","FF_ALIQPAG","FF_VALMIN"} // verificar pq no deleta tem menos campos
Endif

If SFF->(FieldPos("FF_MINUNIT")) > 0 .And. SFF->(FieldPos("FF_LIMITE")) > 0
	aAdd(aYesFields,"FF_ITEM")
	aAdd(aYesFields,"FF_MINUNIT")
	aAdd(aYesFields,"FF_LIMITE")
Endif

/*
 * Campos do fornecedor padrão de impostos
 */
If SFF->(FieldPos("FF_FORNECE")) > 0 .AND. SFF->(FieldPos("FF_LOJA")) > 0
	aAdd(aYesFields,"FF_FORNECE")
	aAdd(aYesFields,"FF_LOJA")
EndIf

aRotina := {{ OemToAnsi(STR0001),"AxPesqui"		,0,1,0,.F.},;		// Buscar
			{ OemToAnsi(STR0002),'A994Gvisual'	,0,2,0,NIL},;		// Visualizar
			{ OemToAnsi(STR0003),'A994Ginclui'	,0,3,0,NIL},;		// Incluir
			{ OemToAnsi(STR0004),'A994Galtera'	,0,4,0,NIL},;		// Modificar
			{ OemToAnsi(STR0005),'A994Gdeleta'	,0,5,0,NIL} }		// Borrar

cCadastro := STR0161 //"Otros Conceptos Provinciales"

//+--------------------------------------------------------------+
//¦ Prepara o SFF para filtrar os registro para IVA...           ¦
//+--------------------------------------------------------------+
dbSelectArea("SFF")
dbSetOrder(4)
dbSetFilter({|| FF_FILIAL==xFilial('SFF') .and. 'CMR'$FF_IMPOSTO .or. 'CPR'$FF_IMPOSTO },"FF_FILIAL==xFilial('SFF') .and. 'CMR'$FF_IMPOSTO  .or. 'CPR'$FF_IMPOSTO")
dbGoTop()

//+--------------------------------------------------------------+
//¦ Pesquisa Especifica pelo Nome Reduzido indice 4              ¦
//+--------------------------------------------------------------+
mBrowse( 6, 1,22,75,"SFF",aFixe)

dbSelectArea("SFF")
dbClearFilter()
dbSetOrder(1)
Return
/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf101  ¦ Autor ¦ José Lucas            ¦ Data ¦ 26/03/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Visualizacao da Tabela de Ingresos Brutos...					  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
31/07/99 jose luis - Trata de CFO Compras e Vendas
*/
Function A994Gvisual()

Local cImp   := SFF->FF_IMPOSTO
Local cSeek  := xFilial("SFF")+cImp
Local cWhile := "FF_FILIAL+FF_IMPOSTO"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,AHEADER,CTABELA,CMESDESDE,CMESATE")
SetPrvt("NCNT,ACOLS,NTOTALITENS,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2,")

nOpcx:=2

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela   := SFF->FF_NUM
cMesDesde := SFF->FF_DESDE
cMesAte   := SFF->FF_ATE
cPlanilla := cSeek

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens := MyFillGet(nOpcx,4,cSeek,cWhile)

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo := STR0161 //"Otros Conceptos Provinciales"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!"      ,".T.",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,.F.})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,.F.})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk:="AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,".T.",".T.",,,,SFF->(Reccount())+100)

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf102  ¦ Autor ¦ José Lucas            ¦ Data ¦ 25/03/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Inclusao de la Tabla de Ingresos Brutos.                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
30/07/99 jose luis - tratamiento de CFO Compras e Vendas
*/
Function A994Ginclui()
Local nX := 0
Local nY := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,AHEADER,ACOLS,CTABELA,CMESDESDE")
SetPrvt("CMESATE,CPLANILLA,NTOTALITENS,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2,NMAXARRAY")
SetPrvt("NY,NCNTITEM,NX,CVAR,AROTINA,")


// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _M2_ATUALIZA  3
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/09/99 ==> #DEFINE _ZONFIS       "FF_ZONFIS"

nOpcx:=_M2_ATUALIZA

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela   := "000001"
cMesDesde := Space(04)
cMesAte   := Space(04)
//cPlanilla := "IB "

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens := MyFillGet(nOpcx)

//Alterando função de validação do campo FF_IMPOSTO
aHeader[aScan(aHeader,{|x| Alltrim(x[2]) == "FF_IMPOSTO" })][6] := "A994ClinOk(1)"

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo := STR0161 //"Otros Conceptos Provinciales"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!","A994VTabla()",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk:="AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,".T.",".T.",,,,SFF->(Reccount())+100)

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente
If lRetMod2

	//+--------------------------------------------------------------+
	//¦ Atualiza o Corpo da Tabela                                   ¦
	//+--------------------------------------------------------------+
	dbSelectArea("SFF")
	nMaxArray := Len(aCols)
	For ny := 1 to Len(aHeader)
		If Empty(aCols[nMaxArray][ny]) .AND. Trim(aHeader[ny][2]) == "FF_IMPOSTO"
			nMaxArray := nMaxArray - 1
			Exit
		EndIf
	Next ny

	nCntItem:= 1
	For nx := 1 to nMaxArray
		IF !aCols[nx][Len(aCols[nx])]

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do tabela.                                    ¦
			//+--------------------------------------------------------------+
			dbSelectArea("SFF")
			RecLock("SFF",.T.)
			Replace FF_FILIAL  With xFilial("SFF"),;
			       	FF_NUM     With cTabela,;
					FF_DESDE   With cMesDesde,;
					FF_ATE	   With cMesAte

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do corpo da Tabela.                           ¦
			//+--------------------------------------------------------------+
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
				Endif
			Next ny
		    dbUnLock()

			nCntItem:=nCntItem + 1
		EndIF
	Next nx

Endif
//+-------------------------------------------------------+
//¦ Forçar o array aRotina para dribar a funcao ExecBrow. ¦
//+-------------------------------------------------------+
aRotina[3][4] := 0

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf103  ¦ Autor ¦ José Lucas            ¦ Data ¦ 26/03/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Alteracao da Tabela de Ingresos Brutos...                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
30/07/99 - jose luis - tratamiento de CFO Compras y ventas
*/
Function A994Galtera()
Local nX := 0
Local nY := 0
Local cImp 	:= SFF->FF_IMPOSTO
Local cSeek  := xFilial("SFF")+cImp
Local cWhile := "FF_FILIAL+FF_IMPOSTO"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,AHEADER,CTABELA,CMESDESDE,CMESATE")
SetPrvt("CPLANILLA,NCNT,ACOLS,NTOTALITENS,NTOTITENSFF")
SetPrvt("CTITULO,AC,AR,ACGD,CLINHAOK,CTUDOOK")
SetPrvt("AGETEDIT,LRETMOD2,NMAXARRAY,NY,NCNTITEM,NX")
SetPrvt("CVAR,")

nOpcx:=4

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela   := SFF->FF_NUM
cMesDesde := SFF->FF_DESDE
cMesAte   := SFF->FF_ATE
cPlanilla := cSeek

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens := MyFillGet(nOpcx,4,cSeek,cWhile)
nTotItensFF := nTotalItens

//Alterando função de validação do campo FF_IMPOSTO
aHeader[aScan(aHeader,{|x| Alltrim(x[2]) == "FF_IMPOSTO" })][6] := "A994ClinOk(1)"

//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo := STR0161 //"Otros Conceptos Provinciales"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!","A994VTabla()",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,.T.})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,.T.})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
//cLinhaOk:="A994ClinOk(2)"
cLinhaOk:= "AlwaysTrue()
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou
lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,".T.",,,,SFF->(Reccount())+100)

// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente
If lRetMod2

	nCntItem:= 1
    For nx := 1 to Len(aCols)
		IF !aCols[nx][Len(aCols[nx])]
			//+--------------------------------------------------------------+
			//¦ Se e um iten novo, incluir-lo , senao so atualizar           ¦
			//+--------------------------------------------------------------+
         	If nX > nTotItensFF
				RecLock("SFF",.T.)
			Else
				SFF->(DbGoTo(aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "FF_REC_WT" })]))
				RecLock("SFF",.F.)
			Endif
			Replace FF_FILIAL  With xFilial("SFF"),;
			       	FF_NUM     With cTabela,;
					FF_DESDE   With cMesDesde,;
					FF_ATE	   With cMesAte

			//+--------------------------------------------------------------+
			//¦ Atualiza dados do corpo da Tabela.                           ¦
			//+--------------------------------------------------------------+
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
				Endif
			Next ny
		    MsUnLock()
            nCntItem := nCntItem + 1
  		Else
			If nX <=	nTotItensFF
				SFF->(DbGoTo(aCols[nX][aScan(aHeader,{|x| Alltrim(x[2]) == "FF_REC_WT" })]))
				RecLock("SFF",.F.)
				SFF->(DbDelete())
				MsUnLock()
			Endif
		Endif
	Next nX
Endif

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Ganf104  ¦ Autor ¦ José Lucas            ¦ Data ¦ 26/03/99 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Exclusao da Tabela de Ingresos Brutos...                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
30/07/99 - jose luis - tratamiento de CFO Compras y ventas

*/
Function A994Gdeleta()
Local cImp   :=  SFF->FF_IMPOSTO
Local cSeek  := xFilial("SFF")+Substr(cImp,1,2)
Local cWhile := "FF_FILIAL+Substr(FF_IMPOSTO,1,2)"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NOPCX,AHEADER,CTABELA,CMESDESDE,CMESATE")
SetPrvt("NCNT,ACOLS,NTOTALITENS,CTITULO,AC,AR")
SetPrvt("ACGD,CLINHAOK,CTUDOOK,AGETEDIT,LRETMOD2,")

nOpcx:=5

//+--------------------------------------------------------------+
//¦ Variaveis do Cabecalho do Modelo 2                           ¦
//+--------------------------------------------------------------+
cTabela := SFF->FF_NUM
cMesDesde := SFF->FF_DESDE
cMesAte := SFF->FF_ATE
cPlanilla := cImp

//+--------------------------------------------------------------+
//¦ Variaveis do Rodape do Modelo 2                              ¦
//+--------------------------------------------------------------+
nTotalItens := MyFillGet(nOpcx,4,cSeek,cWhile)


//+--------------------------------------------------------------+
//¦ Titulo da Janela                                             ¦
//+--------------------------------------------------------------+
cTitulo := STR0161 //"Otros Conceptos Provinciales"

//+--------------------------------------------------------------+
//¦ Array com descricao dos campos do Cabecalho do Modelo 2      ¦
//+--------------------------------------------------------------+
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!"      ,".T.",,.F.})  // Nr. Tabla
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,.F.})  // Fecha desde:
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,.F.})  // Fecha hasta:

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0060),"@E 999",,,.F.})  // Total de Items

//+--------------------------------------------------------------+
//¦ Array com coordenadas da GetDados no modelo2                 ¦
//+--------------------------------------------------------------+
aCGD:={44,5,118,315}

//+--------------------------------------------------------------+
//¦ Validacoes na GetDados da Modelo 2                           ¦
//+--------------------------------------------------------------+
cLinhaOk:="AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//+--------------------------------------------------------------+
//¦ Chamada da Modelo2                                           ¦
//+--------------------------------------------------------------+
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,".T.",".T.",,,,SFF->(Reccount())+100)

If lRetMod2

	//+--------------------------------------------------------------+
	//¦ Excluir os registros da tabela  SFF.                         ¦
	//+--------------------------------------------------------------+
	dbSelectArea("SFF")
	dbSetOrder(4)
	dbSeek(xFilial("SFF")+Substr(cImp,1,2))
	If Found()
		While !Eof() .and. FF_FILIAL+Subs(FF_IMPOSTO,1,2)==xFilial("SFF")+Substr(cImp,1,2)
			RecLock("SFF",.F.)
			dbDelete()
			dbUnLock()
			dbSkip()
		End
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A994AjGan ºAutor  ³ Pedro Pereira Lima º Data ³  08/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Preenchimento dos conceitos de Ganancia padrao para        º±±
±±º          ³ Derechos de Autor                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A994AjGan(cTabela)

dbSelectArea("SFF")
dbSetOrder(1)

//Derechos de Autor
If !dbSeek(xFilial("SFF")+cTabela+"DA")
	RecLock("SFF",.T.)
	Replace FF_FILIAL  With xFilial("SFF")
	Replace FF_NUM 	 With cTabela
	Replace FF_ITEM 	 With "DA"
	Replace FF_CONCEPT With "RETENCION DE GANANCIAS SOBRE DERECHOS DE AUTOR"
	Replace FF_IMPOSTO With "GAN"
	Replace FF_TIPO 	 With ""
	Replace FF_IMPORTE With 1200
	Replace FF_ALQINSC With 0
	Replace FF_ALQNOIN With 28
	Replace FF_LIMITE  With 0
	Replace FF_MINUNIT With 0
	Replace FF_ESCALA  With "I"
	If FieldPos("FF_TPLIM") > 0
		Replace FF_TPLIM With "3"
	EndIf
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A994MSA   ºAutor  ³Camila Januário     º Data ³  06/12/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de manutenção de alíquotas do imposto                º±±
±±º          ³Seg. Salubridad e Higiene de Salta                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Argentina                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A994MSA()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("AFIXE,AROTINA,CCADASTRO,")

aFixe := {{OemToAnsi(STR0006)  ,"FF_NUM"} ,;    // Planilla
	  	   {OemToAnsi(STR0007) ,"FF_ITEM"},;    // Concepto
		   {OemToAnsi(STR0057) ,"FF_CFO"} ,;  	// CFO
		   {OemToAnsi(STR0010) ,"FF_CONCEPT"} } // Descricion

aRotina := {{ OemToAnsi(STR0001),"AxPesqui"	,0,1,0,.F.},;		// Buscar
			{ OemToAnsi(STR0002),'A994MSAx'	,0, 2,0,NIL},;		// Visualizar
			{ OemToAnsi(STR0003),'A994MSAx'	,0, 3,0,NIL},;		// Incluir
			{ OemToAnsi(STR0004),'A994MSAx'	,0, 4,0,NIL},;		// Modificar
			{ OemToAnsi(STR0005),'A994MSAx'	,0, 5,0,NIL} }		// Borrar


cCadastro := OemToAnsi(STR0011)  // Planilla de Ganancias/Fondo Cooperativo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄA¿
//³Filtra os registros do imposto MSA - Salta³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄAÙ
dbSelectArea("SFF")
dbSetOrder(1)
dbSetFilter({|| FF_FILIAL==xFilial('SFF') .and. FF_IMPOSTO=='MSA'},"FF_FILIAL==xFilial('SFF') .and. FF_IMPOSTO=='MSA'")
dbGoTop()

mBrowse( 6, 1,22,75,"SFF",aFixe)
dbSelectArea("SFF")
dbClearFilter()
dbSetOrder(1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A994MSAx   º	Autor  ³Camila Januário     º Data ³  06/12/12º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclusão, Visualização e Alteração do imposto              º±±
±±º          ³ Seg., Salubridad e Higiene de Salta                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Argentina                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A994MSAx(cAlias,nReg,nOpcx)

Local nX := 0
Local nY := 0
Local nI := 0
Local aRecnos := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetPrvt("AHEADER,ACOLS")
SetPrvt("CTABELA,CMESDESDE,CMESATE,CPLANILLA,NTOTALITENS,CTITULO")
SetPrvt("AC,AR,ACGD,CLINHAOK,CTUDOOK,AGETEDIT")
SetPrvt("LRETMOD2,NOPCA,NMAXARRAY,NY,NCNTITEM,NX")
SetPrvt("CVAR,AROTINA,CCADASTRO,AHEADESCALA")
SetPrvt("ACOLSESCALA")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o próximo número da tabela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx==3
	dbSelectArea("SFF")
	dbSetOrder(1)
	dbSeek(xFilial("SFF")+"000001")
	if SFF->FF_IMPOSTO == "MSA"
		If Found()
			MsgBox( OemToAnsi(STR0178), OemToAnsi(STR0050),STR0180 )// "Tabla de Seguridad e higiene de Salta ya existe." - "Atencion" - "INFO"
			Return
		EndIf
	EndIF
EndIf
aYesFields := {"FF_ALIQ","FF_CFO_C","FF_CFO_V","FF_IMPORTE","FF_CONCEPT","FF_INCIMP"}
aYesEscala := {"FF_ITEM",            "FF_CFO","FF_FXDE","FF_FXATE","FF_RETENC","FF_PERC","FF_EXCEDE","FF_IMPORTE"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montando aHeader³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader:= GetaHeader("SFF",aYesFields/*aCpos*/,/*aCposNo*/,/*aEnchAuto*/,/*aCposVisual*/,.T./*lWalk_Thru*/)

dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montando aCols  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx ==3
	aCols	:={}
	aAdd(aCols,Array(Len(aHeader) + 1))
	AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"FF_ALI_WT|FF_REC_WT",NIL,CriaVar(AllTrim(x[2])) ) })
	aCols[1,Len(aHeader) + 1] := .F.
Else
aCols	:={}
DbselectArea("SFF")
//DbGoTop()
dbSetOrder(3)
SFF->(dbSeek(xFilial("SFF")+"MSA"))
	While !SFF->(Eof()) .and. SFF->FF_FILIAL==xFilial('SFF') .and. SFF->FF_IMPOSTO=='MSA'
		aAdd(aCols,Array(Len(aHeader) + 1))
		aAdd(aRecnos, Recno() )
		AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"FF_ALI_WT|FF_REC_WT", NIL , SFF->(FieldGet(FieldPos(x[2]))) ) })
		aCols[Len(aCols),Len(aHeader) + 1] := .F.
		DbSkip()

	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variáveis do cabeçalho modelo 2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTabela   := "000001"
cMesDesde := Space(04)
cMesAte   := Space(04)

cPlanilla := "ISI"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variáveis do rodapé modelo 2   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotalItens:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Título da janela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo:= OemToAnsi(STR0179) // "Percepción Imp. Seg. Salubridad e Higiene de Salta"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array com descrição do cabeçalho da Modelo 2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!","A994VTabla()",,.F.})  //"Nr. Tabla"
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,}) //"Fecha desde:"
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,}) //"Fecha hasta:"

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0055),"@E 999",,,.F.}) // "Total de Conceptos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array com coordenadas da Getdados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCGD:={75,5,118,315}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validações da Getdados           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLinhaOk:= "AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da Modelo 2     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou
lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,".T.",,,,SFF->(Reccount())+100)

If lRetMod2 .and. (nOpcx>=3)
	nOpca := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o corpo da tabela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SFF")
	nMaxArray := Len(aCols)
	nCntItem:= 1
	For nx := 1 to nMaxArray
		IF !aCols[nx][Len(aCols[nx])] .and. nOpcx<>5
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Atualiza dados da tabela
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			dbSelectArea("SFF")
			If nOpcx==4 .and. Len(aRecnos)>=nx
				DbGoto(aRecnos[nx])
				RecLock("SFF",.F.)
			Else
				RecLock("SFF",.T.)
			EndIf

			Replace 	FF_FILIAL  With xFilial("SFF"),;
			       		FF_NUM     With cTabela,;
						FF_DESDE   With cMesDesde,;
						FF_ATE	   With cMesAte,;
						FF_IMPOSTO With "MSA"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ 
			//³Atualiza os dados do corpo da tabela³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ 
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
				Endif
			Next ny
			dbUnLock()

			nCntItem:=nCntItem + 1
		ElseIf nOpcx>=4 .and. Len(aRecnos)>=nx
			DbGoTo( aRecnos[nx] )
			RecLock("SFF",.F.,.T.)
				DbDelete()
			MsUnlock()
		EndIF
	Next nx

Endif
SFF->(DbSetOrder(1))
aRotina[3][4] := 0

Return

Function VldRetMun()
Local nPosImp := aScan(aHeader, {|x| Trim(x[2]) == "FF_IMPOSTO"} )
Local nPosMun := aScan(aHeader, {|x| Trim(x[2]) == "FF_RET_MUN"} )
Local nPosCfoC := aScan(aHeader, {|x| Trim(x[2]) == "FF_CFO_C"} )
Local nPosCfoV := aScan(aHeader, {|x| Trim(x[2]) == "FF_CFO_V"} )
Local lRet    := .T.
Local nLoop   := 0
Local nDeleted := 0
Local nQtdCei:=0
nDeleted := GdFieldPos ("GDDELETED", aHeader)

For nLoop := 1 to Len(aCols)
	If  !aCols[ nLoop , nDeleted ]
		If  Empty(aCols[ nLoop , nPosImp ]) .Or. Empty(aCols[ nLoop , nPosMun ])
			MsgAlert(OemToAnsi(STR0149) )//"Los campos Impuesto y Cod. Ret Municipal no deben ir vacios."    
	        lRet := .F.
	    	Exit
	     Endif
	     If (aCols[ nLoop, nPosImp ] <> "CEI" .OR. aCols[ nLoop, nPosMun ] <> "00004")
	     	If Empty(aCols[ nLoop, nPosCfoC ]) .OR. Empty(aCols[ nLoop, nPosCfoV ])
	     		MsgAlert(OemToAnsi(STR0181))
	     		lRet := .F.
	     	Endif 
	     Endif	
	     If aCols[ nLoop, nPosImp ] == "CEI"
		     nQtdCei := nQtdCei+1
	     EndiF
	Endif
Next nLoop         

If nQtdCei >1
	MsgAlert(OemToAnsi(STR0183),OemToAnsi(STR0182))
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A994MCO   ºAutor  ³Laura Medina        º Data ³  14/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rutina de mantenimiento de alicuotas de Impuestos MCO-      º±±
±±º          ³Actividad de Comercio e Industria de Cordoba.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Argentina                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A994MCO()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("AFIXE,AROTINA,CCADASTRO,")

aFixe := {{OemToAnsi(STR0006)  ,"FF_NUM"} ,;    // Planilla
	  	   {OemToAnsi(STR0007) ,"FF_ITEM"},;    // Concepto
		   {OemToAnsi(STR0057) ,"FF_CFO"} ,;  	 // CFO
		   {OemToAnsi(STR0010) ,"FF_CONCEPT"} } // Descricion

aRotina := {{ OemToAnsi(STR0001),"AxPesqui"	,0,1,0,.F.},;	// Buscar
			{ OemToAnsi(STR0002),'A994MCOx'	,0, 2,0,NIL},;		// Visualizar
			{ OemToAnsi(STR0003),'A994MCOx'	,0, 3,0,NIL},;		// Incluir
			{ OemToAnsi(STR0004),'A994MCOx'	,0, 4,0,NIL},;		// Modificar
			{ OemToAnsi(STR0005),'A994MCOx'	,0, 5,0,NIL} }		// Borrar


cCadastro := OemToAnsi(STR0135)  // Planilla de Ganancias/Fondo Cooperativo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtra os registros do imposto MSA - Salta³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SFF")
dbSetOrder(1)
dbSetFilter({|| FF_FILIAL==xFilial('SFF') .and. FF_IMPOSTO=='MCO'} ,"FF_FILIAL==xFilial('SFF') .and. FF_IMPOSTO=='MCO'")
dbGoTop()

mBrowse( 6, 1,22,75,"SFF",aFixe)
dbSelectArea("SFF")
dbClearFilter()
dbSetOrder(1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A994MCOx  ºAutor  ³Laura Medina        º Data ³  14/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclucion, Visualizacion y Alteracion del Impuesto de MCO   º±±
±±º          ³Act. de Comercio e Industria de la Municipalidad de Cordoba º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Argentina                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A994MCOx(cAlias,nReg,nOpcx)

Local nX := 0
Local nY := 0
Local nI := 0
Local aRecnos := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetPrvt("AHEADER,ACOLS")
SetPrvt("CTABELA,CMESDESDE,CMESATE,CPLANILLA,NTOTALITENS,CTITULO")
SetPrvt("AC,AR,ACGD,CLINHAOK,CTUDOOK,AGETEDIT")
SetPrvt("LRETMOD2,NOPCA,NMAXARRAY,NY,NCNTITEM,NX")
SetPrvt("CVAR,AROTINA,CCADASTRO,AHEADESCALA")
SetPrvt("ACOLSESCALA")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o próximo número da tabela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nOpcx==3
	dbSelectArea("SFF")
	dbSetOrder(1)
	dbSeek(xFilial("SFF")+"000001")
	If  SFF->FF_IMPOSTO == "MCO"
		If  Found()
			MsgBox( OemToAnsi(STR0136), OemToAnsi(STR0050),STR0180 ) // "Tabla de Actividad de Comercio e Industria de Córdoba ya existe!" - "Atencion" - "INFO"
			Return
		EndIf
	EndIF
EndIf
aYesFields := {"FF_ALIQ","FF_CFO_C","FF_CFO_V","FF_IMPORTE","FF_CONCEPT","FF_INCIMP"}
aYesEscala := {"FF_ITEM","FF_CFO","FF_FXDE","FF_FXATE","FF_RETENC","FF_PERC","FF_EXCEDE","FF_IMPORTE"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montando aHeader³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader:= GetaHeader("SFF",aYesFields/*aCpos*/,/*aCposNo*/,/*aEnchAuto*/,/*aCposVisual*/,.T./*lWalk_Thru*/)

dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montando aCols  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nOpcx ==3
	aCols	:={}
	aAdd(aCols,Array(Len(aHeader) + 1))
	AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"FF_ALI_WT|FF_REC_WT",NIL,CriaVar(AllTrim(x[2])) ) })
	aCols[1,Len(aHeader) + 1] := .F.
Else
	aCols	:={}
	DbselectArea("SFF")
	//DbGoTop()
	dbSetOrder(3)
	SFF->(dbSeek(xFilial("SFF")+"MCO"))
	While !SFF->(Eof()) .and. SFF->FF_FILIAL==xFilial('SFF') .and. SFF->FF_IMPOSTO=='MCO'
		aAdd(aCols,Array(Len(aHeader) + 1))
		aAdd(aRecnos, Recno() )
		AEval(aHeader, {|x,y| aCols[Len(aCols)][y] := If(Alltrim(x[2])$"FF_ALI_WT|FF_REC_WT", NIL , SFF->(FieldGet(FieldPos(x[2]))) ) })
		aCols[Len(aCols),Len(aHeader) + 1] := .F.
		SFF->(DbSkip())
	EndDo
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variáveis do cabeçalho modelo 2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTabela   := "000001"
cMesDesde := Space(04)
cMesAte   := Space(04)

cPlanilla := "MCO"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variáveis do rodapé modelo 2   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotalItens:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Título da janela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo:= OemToAnsi(STR0137) //"Percepción Actividad de Comercio e Industria de Córdoba"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8¿
//³Array com descrição do cabeçalho da Modelo 2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8Ù
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aC,{"cTabela"  ,{15,010} ,OemToAnsi(STR0052),"@!","A994VTabla()",,.F.})  //"Nr. Tabla"
AADD(aC,{"cMesDesde",{30,011} ,OemToAnsi(STR0053),"@R 99-99",".T.",,}) //"Fecha desde:"
AADD(aC,{"cMesAte"  ,{30,100} ,OemToAnsi(STR0054),"@R 99-99",".T.",,}) //"Fecha hasta:"

aR:={}

AADD(aR,{"nTotalItens"  ,{120,220},OemToAnsi(STR0055),"@E 999",,,.F.}) // "Total de Conceptos"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array com coordenadas da Getdados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCGD:={75,5,118,315}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validações da Getdados           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLinhaOk:= "AlwaysTrue()"
cTudoOk :="AlwaysTrue()"

aGetEdit := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da Modelo 2     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// lRetMod2 = .t. se confirmou
// lRetMod2 = .f. se cancelou
lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,".T.",,,,SFF->(Reccount())+100)

If  lRetMod2 .and. (nOpcx>=3)
	nOpca := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza o corpo da tabela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SFF")
	nMaxArray := Len(aCols)
	nCntItem:= 1
	For nx := 1 to nMaxArray
		IF !aCols[nx][Len(aCols[nx])] .and. nOpcx<>5
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Atualiza dados da tabela
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			dbSelectArea("SFF")
			If nOpcx==4 .and. Len(aRecnos)>=nx
				DbGoto(aRecnos[nx])
				RecLock("SFF",.F.)
			Else
				RecLock("SFF",.T.)
			EndIf

			Replace 	FF_FILIAL  With xFilial("SFF"),;
			       		FF_NUM     With cTabela,;
						FF_DESDE   With cMesDesde,;
						FF_ATE	   With cMesAte,;
						FF_IMPOSTO With "MCO"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ 
			//³Atualiza os dados do corpo da tabela³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ 
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					SFF->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
				Endif
			Next ny
			dbUnLock()

			nCntItem:=nCntItem + 1
		ElseIf nOpcx>=4 .and. Len(aRecnos)>=nx
			DbGoTo( aRecnos[nx] )
			RecLock("SFF",.F.,.T.)
			DbDelete()
			MsUnlock()
		EndIF
	Next nx

Endif
SFF->(DbSetOrder(1))
aRotina[3][4] := 0

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fBoxTPLIM ³ Autor ³ Emanuel O. Villicaña  ³ Data ³ 20/11/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna Combo para tipo Cal. Limite de SFF IIBB             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA994                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function fBoxTPLIM()
Local cOpcBox := ""

	cOpcBox += ( STR0187 ) //"0=Ninguna;" 
	cOpcBox += ( STR0188 ) //"1=Imp. Anual por Factura;" 
	cOpcBox += ( STR0189 ) //"2=Imp. Mensual Factura;" 
	cOpcBox += ( STR0190 ) //"3=Imp. Anual Dir. de Autor;"
	cOpcBox += ( STR0191 ) //"4=Acumulado Diario de Facturacion;"

Return( cOpcBox )

            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A994VdRBase³ Autor ³ Emanuel O. Villicaña  ³ Data ³ 01/12/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna si permite captura en el campo FF_REDBASE            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA994                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A994VdRBase()
Local lRetorna := .F.
Local nImposto := 0
Local cImposto := ""

nImposto := ASCAN(aHeader,{|x| x[2] == "FF_IMPOSTO"})
If nImposto > 0 
	cImposto := aCols[n][nImposto]
Else
	cImposto := ""
Endif
If Type("M->FF_REDBASE") <> "U" 
	If Substr(cImposto,1,2) == "IB"
		lRetorna := IIf((M->FF_REDBASE >= 0 .and. M->FF_REDBASE <= 100),.T.,.F.) 
	Else
		lRetorna := .T.
	Endif
Endif 

Return lRetorna

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A994ExcFis ³ Autor ³ Marco A. Glz. Rivera  ³ Data ³ 22/04/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Muestra la opcion para Actualizar la tabla de Excepciones    ³±±
±±³          ³ Fiscales en base al valor del UVT.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA994                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A994ExcFis()

	Local cTitulo := ""
	Local cAviso	:= ""
	Local cPerg	:= "MATA994"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³mv_par01 - Del Impuesto?     ³
	//³mv_par02 - Al Impuesto?      ³
	//³mv_par03 - Tipo Cod. Fiscal? ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cTitulo	:= STR0139 // "Actualización de Excepciones Fiscales"
	cAviso		:= STR0140 + CRLF	// "Este proceso actualiza el valor en pesos colombianos del campo FF_FXDE (Rango Inicial), de "
	cAviso		+= STR0141 + CRLF	// "acuerdo al valor del UVT contenido en el parametro MV_VALUVT multiplicado "
	cAviso		+= STR0142			// "por el valor en UVT's del campo FF_VALUVT (Rango Inicial)"

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 140,480 PIXEL

	@ 010,010 SAY cAviso SIZE 460,30 OF oDlg PIXEL

	DEFINE SBUTTON FROM 50,120 TYPE 5 ACTION (Pergunte(cPerg,.T.))		ENABLE OF oDlg
	DEFINE SBUTTON FROM 50,160 TYPE 1 ACTION (A994UpdExc(oDlg))			ENABLE OF oDlg
	DEFINE SBUTTON FROM 50,200 TYPE 2 ACTION (nOpca := 2,oDlg:End())	ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A994UpdExc ³ Autor ³ Marco A. Glz. Rivera  ³ Data ³ 22/04/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Actualiza el campo FF_FXDE de la tabla de Excepciones        ³±±
±±³          ³ Fiscales en base al valor del UVT.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA994                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function A994UpdExc(oDialog)

	Local cFil			:= ""
	Local cQryCom		:= ""
	Local cQryVen		:= ""
	Local nTotal		:= 0
	Local nValUVT		:= 0
	Local cAliasCom		:= ""
	Local cAliasVen		:= ""
	Local oBrow 		:= GetObjBrow()

	cFil	:= xFilial("SX6")

	dbSelectArea("SX6")
	dbSetOrder(1)

	If dbSeek(cFil+"MV_VALUVT")
		nValUVT := GetMv("MV_VALUVT")
		If !Empty(nValUVT)
			If !Empty(MV_PAR02) .And. !Empty(MV_PAR03)
				If MV_PAR03 == 1
					cAliasCom	:= criatrab( nil, .f. )
					cQryCom := "SELECT SFF.FF_FILIAL, SFF.FF_CFO_C, SFF.FF_FXDE, SFF.FF_VALUVT, SFF.R_E_C_N_O_ SFFRECNO"
					cQryCom += " FROM " + RetSqlName("SFF") + " SFF"
					cQryCom += " WHERE SFF.FF_FILIAL= '" + xFilial("SFF") + "'"
					cQryCom += " AND SFF.FF_CFO_C BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
					cQryCom += " AND SFF.D_E_L_E_T_ <> '*'"
					dbUseArea(.T., 'TOPCONN', TcGenQry( , , cQryCom), cAliasCom, .T., .T.)

					count to nTotal
					(cAliasCom)->(dbGoTop())

					If nTotal <> 0
						dbSelectArea("SFF")
						While (cAliasCom)->(!Eof())
							SFF->(dbGoto((cAliasCom)->SFFRECNO))
							RecLock("SFF", .F.)
								SFF->FF_FXDE := SFF->FF_VALUVT * nValUVT
							SFF->(MSUnlock())
							(cAliasCom)->(dbSkip())
						EndDo
						MsgInfo(STR0143 + CvalToChar(nTotal) + STR0144) // "Proceso finalizado con éxito. " y " registros actualizados."
						oBrow:Refresh()
						oDialog:End()
					Else
						MsgInfo(STR0145) // "No existen registros dentro de los parámetros seleccionados. Seleccione otros."
					EndIf
					(cAliasCom)->(dbCloseArea())
				EndIf
				If MV_PAR03 == 2
					cAliasVen	:= criatrab( nil, .f. )
					cQryVen := "SELECT SFF.FF_FILIAL, SFF.FF_CFO_V, SFF.FF_FXDE, SFF.FF_VALUVT, SFF.R_E_C_N_O_ SFFRECNO"
					cQryVen += " FROM " + RetSqlName("SFF") + " SFF"
					cQryVen += " WHERE SFF.FF_FILIAL= '" + xFilial("SFF") + "'"
					cQryVen += " AND SFF.FF_CFO_V BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
					cQryVen += " AND SFF.D_E_L_E_T_ <> '*'"
					dbUseArea(.T., 'TOPCONN', TcGenQry( , , cQryVen), cAliasVen, .T., .T.)

					count to nTotal
					(cAliasVen)->(dbGoTop())

					If nTotal <> 0
						dbSelectArea("SFF")
						While (cAliasVen)->(!Eof())
							SFF->(dbGoto((cAliasVen)->SFFRECNO))
							RecLock("SFF", .F.)
								SFF->FF_FXDE := SFF->FF_VALUVT * nValUVT
							SFF->(MSUnlock())
							(cAliasVen)->(dbSkip())
						EndDo
						MsgInfo(STR0143 + CvalToChar(nTotal) + STR0144) // "Proceso finalizado con éxito. " y " registros actualizados."
						oBrow:Refresh()
						oDialog:End()
					Else
						MsgInfo(STR0145) // "No existen registros dentro de los parámetros seleccionados. Seleccione otros."
					EndIf
					(cAliasVen)->(dbCloseArea())
				EndIf
			Else
				MsgInfo(STR0146) // "Los parámetros ¿Al Impuesto? y ¿Tipo Cód. Fiscal? son obligatorios"
			EndIf
		Else
			MsgInfo(STR0147) // "El parámetro MV_VALUVT se encuentra vacío. Es necesario colocar el valor de la UVT en pesos colombianos"
		EndIf
	Else
		MsgInfo(STR0148) // "Parámetro MV_VALUVT no existe, es necesario para colocar el valor de la UVT en pesos colombianos"
	EndIf

Return


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ A994IMPSYD Autor ¦ BRUNO                 ¦ Data ¦ 07/08/98 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Tabela de iMPORTACAO                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Function A994ImpSYD()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetPrvt("AROTINA,CCADASTRO")
If cPaisLoc == "ARG"
	aYesFields := {"FF_IMPOSTO","FF_MOEDA","FF_ALIQ","FF_PRALQIB","FF_RETENC","FF_IMPORTE"}
Else
	aYesFields := {"FF_IMPOSTO","FF_MOEDA","FF_ALIQ","FF_RETENC","FF_IMPORTE"}
Endif

If !SIX->(DbSeek("SFF7"))
	//"Crear el indice SFF 7 con la siguiente llave :"                                          
	//"Si el campo FF_TEC no existe, por favor crearlo con las mismas caratecristicas del D1_TEC"
	MsgAlert(OemToAnsi(STR0079)+CHr(13)+chr(10);    
	+"FF_FILIAL+FF_TEC+FF_IMPOSTO"+CHr(13)+chr(10)+CHr(13)+chr(10);
	+OemToAnsi(STR0080))
	Return .F.
Endif

If cPaisLoc == "ARG"
	aRotina := {	{ OemToAnsi(STR0001),"AxPesqui"		,0,1,0,.F.},;		// Buscar
					{ OemToAnsi(STR0002),'A994IVisual'	,0,2,0,NIL},;		// Visualizar
					{ OemToAnsi(STR0003),'A994IInclui'	,0,3,0,NIL},;		// Incluir
					{ OemToAnsi(STR0004),'A994IAltera'	,0,4,0,NIL},;		// Modificar
					{ OemToAnsi(STR0005),'A994IDeleta'	,0,5,0,NIL} }		// Borrar
Else
	aRotina := MenuDef()
EndIf

cCadastro := OemToAnsi(STR0081)  //"Vinculo de impuestos de importacion"

//+--------------------------------------------------------------+
//¦ Prepara o SFF para filtrar os registro para Importacion...   ¦
//+--------------------------------------------------------------+
dbSelectArea("SYD")
dbSetOrder(1)
dbGoTop()
                                 
//+--------------------------------------------------------------+
//¦ Pesquisa Especifica pelo Nome Reduzido indice 4              ¦
///+--------------------------------------------------------------+
mBrowse( 6, 1,22,75,"SYD")

dbSetOrder(1)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³lVldRegSFF³ Autor ³Luis Enríquez ³ Data         ³ 05/12/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida si existe relacion con tabla SFF.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FISA016 (EUA)                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function lVldRegSFF()
	Local lRet		:= .T.
	Local cQuery	:= ""
	Local nCount	:= 0
	Local cTmpSFF	:= CriaTrab(Nil, .F.)
	Local cFilSFF	:= xFilial("SFF")
	
	cQuery := "SELECT FF_IMPOSTO, FF_ZONFIS, FF_CODMUN, FF_COD_TAB"
	cQuery += " FROM " + RetSqlName("SFF") + " SFF"
	cQuery += " WHERE FF_FILIAL	= '" + cFilSFF	+ "'"
 	cQuery += " AND FF_IMPOSTO = '" + M->FF_IMPOSTO + "'"
 	cQuery += " AND FF_ZONFIS = '" + M->FF_ZONFIS + "'"
 	cQuery += " AND FF_CODMUN = '" + M->FF_CODMUN + "'"
 	cQuery += " AND FF_COD_TAB = '" + M->FF_COD_TAB + "'"
  	cQuery += " AND D_E_L_E_T_ = ' '"
  	
  	cQuery := ChangeQuery(cQuery)
  	   
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTmpSFF, .T., .T.)
	
	Count to nCount 
	
	(cTmpSFF)->(DBCloseArea())
	
	If nCount <> 0
		Help(" ", 1, "JAGRAVADOSFF")
		lRet := .F.
	EndIf
Return lRet

//±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³Fun‡…o   ³M994Mtr   ³ Autor ³ Mercado Internacional ³ Data ³.11.10.2021³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Descri‡…o ³Función utilizada para gerar metrica da rutina              ´±± 
//±±³           Configuração Adicional de impuestos                         ´±±    
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±

Function M994Mtr(TPImp,TpAcion,nQtd)

Local cIdMetric := ""
Local cSubRutina := ""

Default TPImp := ""
Default TpAcion := ""
Default nQtd := 0

//Metrica Config. Adic Imp.
If LibMt994Nf()
	cIdMetric   := "fiscal-protheus_manutencao-conf-adic-impostos_total"
	cSubRutina  := TPImp + "-" + TpAcion + "-media-manut-conf-adic-impostos" 
	If lAutomato
		cSubRutina  += "-auto"
	EndIf
	FWCustomMetrics():setAverageMetric(cSubRutina, cIdMetric, nQtd, /*dDateSend*/, /*nLapTime*/,"MATA994") ///*dDateSend*/ --alterar para dDatesend
EndIf

	
Return

/*/{Protheus.doc} LibMt994Nf
Función utilizada para validar la fecha de la LIB para ser utilizada en Telemetria
@type       Function
@author     Faturación
@since      2021
@version    12.1.27
@return     _lMetric, lógico, si la LIB puede ser utilizada para Telemetria
/*/
Static Function LibMt994Nf()

If _lMetric == Nil 
	_lMetric := (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')
EndIf

Return _lMetric
