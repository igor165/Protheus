#Include "Totvs.ch"
#Include 'protheus.ch'
#Include "Colors.ch"
#Include "TopConn.CH"
#Include "rwmake.ch"
#Include "Font.ch"
#Include "ap5mail.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"
#Include "FAT002OM.ch"

/*/{Protheus.doc} FAT002OM
Rotina de Despacho - Faturamento/Expedição
@type function
@version 1.0
@author MAURICIO LIMA DE SOUZA / MSOFTCONSULTORIA - OMAMORI / CERATTI
@since 01/11/2007
/*/
*----------------------------------------------------------------------------*
USER FUNCTION FAT002OM()
	*----------------------------------------------------------------------------*
	Local aSizeAut    := MsAdvSize(,.F.,400)
	Local aObjects	  := {}
	local aDialogs    := {"Lançamento de Despacho","Multi-Lote"}
	local aDialogs2   := {"Itens"}

	Local aTitles     := {OemToAnsi("Despacho"),OemToAnsi("Multi-Lote")}
	Local aTitles2    := {OemToAnsi("Itens")}

	Local aFldCBAtu   := Array(Len(aTitles))
	Local aPages	  := {"HEADER"}
	LOCAL aButtons    :={}
	Local dUlFat      := GetMV('MV_DATFAT')

	//Tratamento Ermida CFRJ
	Local lDigita 		:= .T.
	Local lBlqTransp	:= AllTrim(__cUserId) $ AllTrim(SuperGetMv("OM_USRIDER",,"000302")) //Usuario Ermida.
	Local cTranDefault 	:= AllTrim(SuperGetMv("OM_TRANDEF",,"000478"))

	private oOrdem
	private oCAIXA
	private oNauto
	private oPallet
	private oOrdG
	private _ORDG
	private nLSEQ     :=0
	private cOrdem    :=  SuperGetMv("OM_ORDDESP",,'3 - Codigo de Produto')//'1 - Zona crescente Roteiro Crescente'
	private cCAIXA    :=  '1 - Calculo Peso por Caixa'
	private cNauto    :=  '1 - NF Normal'
	private cNpallet  :=  '1'
	private aOrdens	  := {'1 - Zona crescente Roteiro Crescente','2 - Zona Crescente Roteiro Decrescente','3 - Codigo de Produto','4 - Cidade'}
	private acaixa	  := {'1 - Calculo Peso por Caixa','2 - Calculo Peso a granel' }
	private aNauto	  := {'1 - NF Normal','2 - NF Automatico'}
	private aNpallet  := {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20'}
	private cOrdG     :=  '1 - Todos Itens'
	private aOrdG	  := {'1 - Todos Itens','2 - Itens a granel','3 - Peso Padrao'}
	private cZONA     :=SPACE(06)
	Private a103Var	  := {0,0,0,0,0,0,0,0}
	private lFirst    :=.T.
	private lFirst2   :=.T.
	private lFirst3   :=.T.
	Private cPICT     :="@E 999,999.999"
	Private aCols     := {}
	Private aHeader   := {}
	Private aHeadLote := {}
	Private aCOLSLote := {}
	Private aCOLSLT   := {}
	Private dData2    :=date()
	Private dData3    :=date()
	Private cData1    :=""
	Private cData2    :=""
	Private cCLI1     :=SPACE(06)
	Private cTRANSP   :=SPACE(06)
	Private cCLI2     :='ZZZZZZ'

	Private cNUM1     :=SPACE(06)
	Private cNUM2     :='ZZZZZZ'
	Private cLOJA1    :=SPACE(01)
	Private cLOJA2    :='ZZ'
	Private nITEM     :=0
	Private nVOLUME   :=0

	Private nOpcx     :=0
	Private l103Class := .F.
	Private ny:=1

	Private lEXPALERT :=.T.

	//--------------------------objetos---------------------------
	Private oTOT
	Private nTOT
	Private oTOTVOL
	Private nTOTVOL
	Private oTOT2
	Private oTOT3
	Private nTOT2
	Private oPROD
	Private cPROD
	Private oCLIE
	Private cCLIE
	Private oENDR
	Private cENDR
	Private oTOTL
	Private nTOTL
	private oFont                // Objeto Fonte
	private oFontNW
	private oFontGRD             // Objeto Fonte
	private oFontBRW             // Objeto Fonte
	private oFontBRW2
	private oFontBRW3
	private oFontBRW4
	private oDESCI

	private cDESCI
	private oDESC2
	private cDESC2
	private oNTRANPA
	private oNTRANSP
	private cNTRANSP
	private oNTRANSP1
	private cNTRANSP2
	private oNTRANSP3
	private oNTRANENT
	private cNTRANSP3
	private cPLACA2
	private oPLACA2
	private cPLACA3
	private oPLACA3
	Private oPEDVEN
	Private cPEDVEN
	Private oMLOTE1
	//--------------------------cabeçalho
	Private dData1     :=dUlFat
	Private cTRANSP    :=SPACE(06)
	Private cNTRANSP   :=SPACE(30)
	Private cPLACA2    :=SPACE(08)
	Private cTRANSP2   :=SPACE(06)
	Private cNTRANSP2  :=SPACE(30)
	Private cPLACA3    :=SPACE(08)
	Private cTRANSP3   :=SPACE(06)
	Private cNTRANSP3  :=SPACE(30)
	Private	_PREAL     := 0
	Private cNota      :=SPACE(06)
	Private cSerie     :=SPACE(03)


	Private cFlTpCli   := Space(1)
	Private aFlTpCli   := {'R=Rede','V=Varejo'}
	Private cFtTpShelf := Space(1)
	Private aFtTpShelf := {'1=1/3','2=2/3'}
	Private cFiltraRom := Space(1)
	Private aFiltraRom := {'N=Não', 'S=Sim'}
	Private cFtNrRom   := Space(12)
	Private cFtEstado  := 'SP'
	Private aFtEstado  := { 'AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO' }


	PRIVATE cEMP   := 'Omamori/BM'
	//PRIVATE cEMP   := 'Ceratti'
	PRIVATE aEMP   :={'Omamori/BM', 'Ceratti'}
	PRIVATE oEMP
	//-------------------------------------------------
	PRIVATE cPECA     :=space(03)
	PRIVATE nPECA     :=0
	//-------------------------------------------------
	Private _cHoraIni  := TIME()
	Private _cHoraFim  := TIME()

	Private lShwRomane := GetMV('ZZ_FT2ROMA', .F., .T. ) //Exibe a coluna com o Romaneio?
	Private lShwSldWMs := GetMV('ZZ_FT2SLDW', .F., .T. ) //Exibe a coluna com o Saldo do WMS?
	Private lInicia	   := .F.
	Private cCliCFGru := GetMV('OM_CLCFGRU', .F., '07850601') //Cliente Clean Field Guarulhos

	SetKey(VK_F12, { || LER_LOTE(oGetDados) } )

	U_REGTRANSP()

	IF ALLTRIM(SM0->M0_CODIGO)<>'01'
		msgalert('Empresa '+ SM0->M0_NOME+'              ' )
		msgalert('Executar essa rotina na Empresa/Filial  01-OMAMORI / 01- MATRIZ')
		RETURN
	ENDIF

	IF ALLTRIM(SM0->M0_CODIGO)=='01'  .AND. ALLTRIM(SM0->M0_CODFIL)<>'01'
		msgalert('Empresa '+ SM0->M0_NOME+' Filial'+SM0->M0_CODFIL )
		msgalert('Executar essa rotina na Empresa/Filial  01-OMAMORI / 01- MATRIZ')
		RETURN
	ENDIF

	aAdd( aButtons, {'EDIT'        , {||  FAT002E()  },"PesoPAD"  } )
	aAdd( aButtons, {'NOVACELULA ' , {||  FAT002D()  },"Limpar"                     }) //
	aAdd( aButtons, {'LOCALIZA'    , {||  FAT002B()  },"Visualizar"                 }) //
	aAdd( aButtons, {'PEDIDO'      , {||  FATNAUTO() },"GeraNF"                     }) //
	aAdd( aButtons, {'VOLUME'      , {||  FATPRVOL() },"Prenc Vol"                  }) //
	aAdd( aButtons, {'RELATORIO'   , {||  FATETQ1()  },"Etiquetas"                  }) //
	aAdd( aButtons, {'ALT_CAD'     , {||  maneFAT002F()  },"Zera Vol."                  }) //
	aAdd( aButtons, {'PROCESSA'    , {||  FAT002C()  },"Despachar"                  }) //

	cDATA1:=DTOS(dDATA1)
	cDATA2:=DTOS(dDATA2)

	AADD(aHeader,  {    "Pedido"    	,   "PEDIDO"     ,""       ,18,0,""            ,"","C","","","","",".F."})//01
	AADD(aHeader,  {    "Cod. Cliente"  ,   "IDCLIE"     ,""       ,09,0,""            ,"","C","","","","",".F."})//02
	AADD(aHeader,  {    "Razão Social"  ,   "RAZAO"      ,""       ,15,0,""            ,"","C","","","","",".F."})//03
	AADD(aHeader,  {    "Zona"      	,   "ZONA"       ,""       ,04,0,""            ,"","C","","","","",".F."})//04
	AADD(aHeader,  {    "Roteiro"   	,   "ROTEIRO"    ,""       ,08,0,""            ,"","C","","","","",".F."})//05
	AADD(aHeader,  {    "Produto"   	,   "PRODUTO"    ,""       ,15,0,""            ,"","C","","","","",".F."})//06
	AADD(aHeader,  {    "Qtde. Vend."   ,   "QTDEP"      ,"@E 9999",04,0,""            ,"","N","","","","",".F."})//07
	AADD(aHeader,  {    "Peso Vend."    ,   "PESOP"      ,cPICT    ,09,3,""            ,"","N","","","","",".F."})//08
	AADD(aHeader,  {    "Unid. Med."    ,   "UNM"        ,""       ,02,0,""            ,"","C","","","","",".F."})//09
	AADD(aHeader,  {    "Qtde. Desp."   ,   "QTDED"      ,"@E 9999",04,0,"U_PFldTo2A()","","N","","","","",".T."})//10
	AADD(aHeader,  {    "Peso Desp."    ,   "PESOD"      ,cPICT    ,09,3,"U_PFldTot1()","","N","","","","",".T."})//11
	AADD(aHeader,  {    "Volume(s)"    	,   "VOLUME"     ,"@E 9999",04,0,"U_PFldVol1()","","N","","","","",".T."})//12
	AADD(aHeader,  {    "NCS   "    	,   "LOTE"       ,""       ,06,0,""            ,"","C","","","","",".F."})//13
	AADD(aHeader,  {    "Lote VIF"   	,   "Z6_LOTEVIF" ,""       ,45,0,""            ,"","C","","","","",".T."})//14 // mls

	If lShwRomane
		AADD(aHeader,  {    "Romaneio"   	,   "ROMANEIO"   ,""       ,12,0,""            ,"","C","","","","",".T."})//15
	Endif

	If lShwSldWMs
		AADD(aHeader,  {    "Saldo WMS"   	,   "SALDOWMS"   ,cPICT    ,09,3,""            ,"","N","","","","",".T."})//16
	Endif

	AADD(aHeadLOTE,{    "Cod. Barra"  	,   "CODBAR"      ,""       ,10,0,""            ,"","C","","","","",".F."})//01
	AADD(aHeadLOTE,{    "Produto" 		,   "PRODUTO"     ,""       ,15,0,""            ,"","C","","","","",".F."})//02
	AADD(aHeadLOTE,{    "Lote"    		,   "LOTE"        ,""       ,17,0,""            ,"","C","","","","",".F."})//03
	AADD(aHeadLOTE,{    "Validade"		,   "VALIDADE"    ,""       ,10,0,""            ,"","D","","","","",".F."})//04
	AADD(aHeadLOTE,{    "Qtde."    		,   "QTDE"        ,cPICT    ,15,4,"U_PFLTALT1()","","N","","","","",".T."})//05
	AADD(aHeadLOTE,{    "Peso"    		,   "PESO"        ,"@E 9,999,999.999"   ,07,3,"","","N","","","","",".F."})//06
	AADD(aHeadLOTE,{    "NCS"     		,   "NCS"         ,""       ,10,0,""            ,"","C","","","","",".F."})//07
	AADD(aHeadLOTE,{    "Sequencia"    	,   "LSEQ"        ,"@E 9999",15,4,""            ,"","N","","","","",".F."})//08

	AAdd( aObjects, { 0,    65, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 0,    75, .T., .F. } )

	aInfo   := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,;
		{{3,40,95,165,217,234,268},;
		{10,40,111,145,223,268,60},;
		{5,70,160,205,295},;
		{6,34,200,215},;
		{6,34,80,113,160,185},;
		{6,34,245,268,260},;
		{10,50,150,190},;
		{273,130,190},;
		{8,45,80,103,139,173,200,235,270},;
		{133,190,144,190,289,293},;
		{142,293,140},;
		{9,47,188,148,9,146} } )

	DEFINE FONT oFont     NAME "Arial" SIZE 0,-25 BOLD
	DEFINE FONT oFontGRD  NAME "Arial" SIZE 0,-40 BOLD
	DEFINE FONT oFontBRW  NAME "Arial" SIZE 0,-15 BOLD
	DEFINE FONT oFontBRW2 NAME "Arial" SIZE 0,-17 BOLD
	DEFINE FONT oFontBRW3 NAME "Arial" SIZE 0,-13 BOLD
	DEFINE FONT oFontBRW4 NAME "Arial" SIZE 0,-19 BOLD
	DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE OemToAnsi("Lançamento de Despacho V4") OF oMainWnd PIXEL

	//³Define o cabecalho da rotina                                  ³

	nMeio:=INT( ((oMainWnd:nBottom-60) -(oMainWnd:nTop+125) ) / 4 )-10


	//nLin := 36
	@ aPosObj[3,2],aPosGet[1,1] TO 95,aPosGet[1,1]+(aPosGet[1,1]*100) LABEL ""               OF oDlg PIXEL
	nLin := 39

	@ nLin+001,aPosGet[1,1]+(aPosGet[1,1]*02) SAY OemToAnsi("Filtra Romaneio?")          OF oDlg PIXEL SIZE 055,010 FONT oFontBRW3
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*12) combobox oNauto var cFiltraRom items aFiltraRom WHEN(lDigita) size 045,010 of oDlg pixel COLOR CLR_BLUE  FONT oFontBRW3

	@ nLin+001,aPosGet[1,1]+(aPosGet[1,1]*22) SAY OemToAnsi("Tp. Cliente")               OF oDlg PIXEL SIZE 040,010 FONT oFontBRW3
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*28) combobox oNauto var cFlTpCli items aFlTpCli WHEN(lDigita .AND. cFiltraRom == 'S') size 045,010 of oDlg pixel COLOR CLR_BLUE  FONT oFontBRW3

	@ nLin+001,aPosGet[1,1]+(aPosGet[1,1]*36) SAY OemToAnsi("Tipo Shelf")                OF oDlg PIXEL SIZE 035,010 FONT oFontBRW3
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*42) combobox oNauto var cFtTpShelf items aFtTpShelf WHEN(lDigita .AND. cFiltraRom == 'S') size 045,010 of oDlg pixel COLOR CLR_BLUE  FONT oFontBRW3

	@ nLin+001,aPosGet[1,1]+(aPosGet[1,1]*51) SAY OemToAnsi("Estado")          OF oDlg PIXEL SIZE 055,010 FONT oFontBRW3
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*55) combobox oNauto var cFtEstado items aFtEstado WHEN(lDigita .AND. cFiltraRom == 'S') size 035,010 of oDlg pixel COLOR CLR_BLUE  FONT oFontBRW3

	@ nLin+001,aPosGet[1,1]+(aPosGet[1,1]*65) SAY OemToAnsi("Romaneio:")                 OF oDlg PIXEL SIZE 035,010 FONT oFontBRW3
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*72) MSGET cFtNrRom   WHEN(lDigita .AND. cFiltraRom == 'S')       OF oDlg PIXEL SIZE 055,005 FONT oFontBRW3

	@ nLin+001,aPosGet[1,1]+(aPosGet[1,1]*82) SAY OemToAnsi("Pallet :")                 OF oDlg PIXEL SIZE 035,010 FONT oFontBRW3
	//@ nLin,aPosGet[1,1]+(aPosGet[1,1]*72) MSGET cFtNrRom   WHEN(lDigita .AND. cFiltraRom == 'S')       OF oDlg PIXEL SIZE 055,005 FONT oFontBRW3
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*86) combobox oPallet var cNpallet items aNpallet WHEN(.T.) size 065,010 of oDlg pixel COLOR CLR_BLUE  FONT oFontBRW3

	nLin := nLin+15
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*02) SAY OemToAnsi("Entrega ")                OF oDlg PIXEL SIZE 030,010 FONT oFontBRW3
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*08) MSGET dData1   VALID(U_VALIDDATA(M->dDATA1))  WHEN(.T.)       OF oDlg PIXEL SIZE 045,005 FONT oFontBRW3
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*17) SAY OemToAnsi("Transp. Padrão")   OF oDlg PIXEL SIZE 070,010
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*25) MSGET oNTRANPA VAR cTRANSP  VALID(U_NTRSP01A()) WHEN(lDigita)  F3 "A42"       OF oDlg PIXEL SIZE 040,005 COLOR CLR_RED  FONT oFontBRW3
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*32) MSGET oNTRANSP VAR cNTRANSP WHEN(.F.)    OF oDlg PIXEL SIZE 120,005                     COLOR CLR_RED  FONT oFontBRW3
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*68) SAY OemToAnsi("Zona ")                   OF oDlg PIXEL SIZE 030,010 FONT oFontBRW3
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*72) MSGET cZONA WHEN(.T.)   F3 "ACY"         OF oDlg PIXEL SIZE 030,005
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*77) combobox oNauto var cNauto items aNauto WHEN(lDigita) size 065,010 of oDlg pixel COLOR CLR_BLUE  FONT oFontBRW3

	nLin := nLin+12
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*02) SAY OemToAnsi("Placa Primaria")                   OF oDlg PIXEL SIZE 040,010
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*08) MSGET oPLACA2 VAR cPLACA2 VALID(u_vldplc('1')) WHEN(.T.)    OF oDlg PIXEL SIZE 030,005 //PICTURE("@! XXX-9999")
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*17) SAY OemToAnsi("Transp. Primaria") OF oDlg PIXEL SIZE 070,010
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*25) MSGET oNTRANSP1 VAR cTRANSP2  VALID(U_NTRSP02A()) WHEN(lDigita)  F3 "A41"      OF oDlg PIXEL SIZE 040,005
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*32) MSGET oNTRANSP2 VAR cNTRANSP2  WHEN(.F.)OF oDlg PIXEL SIZE 120,005
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*72) combobox oOrdG var cOrdG items aOrdG size 125,08 of oDlg pixel  COLOR CLR_RED  FONT oFontBRW3
	nLin := nLin+12
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*02) SAY OemToAnsi("Placa Entrega")                   OF oDlg PIXEL SIZE 040,010
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*08) MSGET oPLACA3 VAR cPLACA3 VALID(u_vldplc('2')) WHEN(.T.)    OF oDlg PIXEL SIZE 030,005
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*17) SAY OemToAnsi("Transp. Entrega")  OF oDlg PIXEL SIZE 070,010
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*25) MSGET oNTRANENT VAR cTRANSP3  WHEN(lDigita)  F3 "A41"   OF oDlg PIXEL SIZE 040,005
	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*32) MSGET oNTRANSP3 VAR cNTRANSP3 WHEN(.F.)  OF oDlg PIXEL SIZE 120,005

	@ nLin,aPosGet[1,1]+(aPosGet[1,1]*72) combobox oOrdem var cOrdem items aOrdens size 125,08 of oDlg pixel COLOR CLR_BLUE  FONT oFontBRW3

	oGetDados  := (MsNewGetDados():New( aPosObj[2,1],aPosObj[3,2],aPosObj[3,1]-15,aPosObj[3,4]-aPosObj[3,2]-(aPosObj[1,1]*0),GD_UPDATE ,/*"U_FAT002LOK()"*/  ,/*REQ_OPSD3()*/,/*inicpos*/,/*aCpoHead*/,/*nfreeze*/,9999 ,/*Ffieldok*/,/*superdel*/,/*delok*/,/*oFoldertst:aDialogs[1]*/,aHeader,aCols))
	oGetDados:oBrowse:lUseDefaultColors := .F.
	//oGetDados:oBrowse:SetBlkBackColor({|| GETDCLR(oGetDados:aCols,oGetDados:nAt,aHeader)})
	oGetDados:oBrowse:SetBlkBackColor({|| LOTECLR(oGetDados:aCols,oGetDados:nAt,aHeader)})

	DEFINE FONT oFontNW  NAME "Arial" SIZE 0,-15 BOLD
	oGetDados:oBrowse:oFont := oFontNW
	oGetDados:cFieldOk := "U_FAT2LOK2()"
	oGetDados:oBrowse:Refresh()
	oGetDados:oBrowse:bChange:={||U_FAT002LOK(oGetDados)}

	//rodapé
	oFolder   := TFolder():New(aPosObj[3,1]-15,aPosObj[3,2],aTitles,aPages,oDlg,,,, .T., .F.,aPosObj[3,4],aPosObj[3,3]+aPosObj[3,1],)
	oFolder:bSetOption := {|nDst| NfeFldChg(nDst,oFolder:nOption,oFolder,aFldCBAtu)}
	bRefresh := {|nX| NfeFldChg(nX,oFolder:nOption,oFolder,aFldCBAtu)}


	//³ Folder detalhe item e Totalizadores                          ³

	oFolder:aDialogs[1]:oFont := oDlg:oFont
	U_PEFldTot1(oFolder:aDialogs[1],a103Var,aPosGet[3],@aFldCBAtu[1])


	//³ Folder Multi Lote                                            ³

	oFolder:aDialogs[2]:oFont :=oFontBRW2
	oMLOTE1 := (MsNewGetDados():New(004,010,055,450,GD_UPDATE+GD_DELETE,,/*"NfeTOkSE2"*/,/*inicpos*/,/*aCpoHead*/,/*freeze*/,1000 ,/*fieldok*/,,,oFolder:aDialogs[2],aHeadLote,aCOLSLote))
	oMLOTE1:oBrowse:lUseDefaultColors := .F.
	oMLOTE1:oBrowse:SetBlkBackColor({|| GETDCLR(oMLOTE1:aCols,oMLOTE1:nAt,aHeadLote)})

	oMLOTE1:oBrowse:lHscroll := .F.
	oMLOTE1:oBrowse:bChange:={||U_MLOTE1DEL(oMLOTE1,oGetDados)}
	oMLOTE1:oBrowse:REFRESH()

	_cHoraIni := Time()
	@ 00,(aPosGet[1,1]*82)  SAY   "Peso Total Item"   Of oFolder:aDialogs[2]  SIZE 58 ,9  PIXEL COLOR CLR_BLUE FONT oFontBRW //"Total "
	@ 10,(aPosGet[1,1]*82)  MSGET oTOTL  VAR nTOTL     PICTURE "@E 999,999.999"   OF oFolder:aDialogs[2] PIXEL COLOR CLR_BLUE FONT oFont When .F. SIZE 100,10
	@ 25,(aPosGet[1,1]*82)  SAY   "Peso Total "       Of oFolder:aDialogs[2]  SIZE 58 ,9  PIXEL COLOR CLR_BLUE FONT oFontBRW //"Total "
	@ 35,(aPosGet[1,1]*82)  MSGET oTOT2  VAR nTOT2      PICTURE "@E 999,999.999"  OF oFolder:aDialogs[2] PIXEL COLOR CLR_BLUE FONT oFont When .F. SIZE 100,10
	@ 60,010 MSGET oDESC2 VAR cDESC2     PICTURE PesqPict('SB1','B1_DESC')    OF oFolder:aDialogs[2]  PIXEL COLOR CLR_RED  FONT oFontBRW2 When .F. SIZE 480,09

	If lBlqTransp
		lDigita	:= .F.
		cTRANSP	:= cTranDefault
		u_NTRSP01A(.F.)
	EndIf
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||(FATFIN(),nOpcA:=9)}    ,{||(FATFIN(),nOpcA:=0)},,aButtons) centered

	PutMv("MV_DATFAT"  ,dDATA1) // atualiza o parametro MV_DATFAT

	U_MCERLOG()
RETURN

/*/{Protheus.doc} FATPRVOL
Metodo para preencher os volumes
@author    Fabio Hayama - Geeker Company
@since     12/01/2018
/*/
static function FATPRVOL()
	if(MsgYesNo("Deseja preencher o volume para impressão das etiquetas?"))
		MsAguarde( { || pFATPRVOL() } , "Aguarde..." )
	endIf
return

/*/{Protheus.doc} pFATPRVOL
Metodo para preencher os volumes
@author    Fabio Hayama - Geeker Company
@since     12/01/2018
/*/
static function pFATPRVOL()
	Local nX         := 1
	Local nIx        := 0
	Local nxTamArray := 0

	for nX := 1 to Len(oGETDADOS:aCOLS)
		if(oGETDADOS:aCOLS[nX][P1_VOLUME] <= 0)
			oGETDADOS:aCOLS[nX][P1_VOLUME] := oGETDADOS:aCOLS[nX][P1_QTDEP]
		endIf
	next
	oGetDados:oBrowse:Refresh()

	//I2107-110 - Paulo Apolinário. 22/07/2021
	SZ5->(DBSELECTAREA('SZ5'))
	SZ5->(DBSETORDER(1))//NUMERO

	SZ6->(DBSELECTAREA('SZ6'))
	SZ6->(DBSETORDER(3))//NUMERO+CLIENTE+LOJA+PRODUTO

	nxTamArray := Len( oGetDados:aCOLS )
	If nxTamArray > 0
		For nIx := 1 To nxTamArray
			SZ6->(DBSEEK(xFILIAL('SZ6')+oGetDados:aCOLS[nIx][P1_PEDIDO]+SUBSTR(oGetDados:aCOLS[nIx][P1_IDCLIE],1,6)+SUBSTR(oGetDados:aCOLS[nIx][P1_IDCLIE],8,2)+oGetDados:aCOLS[nIx][P1_PRODUTO]))
			IF SZ6->(FOUND())
				DO WHILE .NOT. SZ6->(EOF()) .AND.  SZ6->Z6_FILIAL==xFILIAL('SZ6') .AND.;
						SZ6->Z6_NUM     == oGetDados:aCOLS[nIx][P1_PEDIDO]             .AND.  ;
						SZ6->Z6_CLI     == SUBSTR(oGetDados:aCOLS[nIx][P1_IDCLIE],1,6) .AND.  ;
						SZ6->Z6_LOJA    == SUBSTR(oGetDados:aCOLS[nIx][P1_IDCLIE],8,2) .AND.  ;
						SZ6->Z6_PRODUTO == oGetDados:aCOLS[nIx][P1_PRODUTO]

					IF SZ6->Z6_ITEM == oGetDados:aCOLS[nIx][P1_ITEM]
						SZ6->(RECLOCK('SZ6',.F.))
						SZ6->Z6_OMAVOL   :=oGetDados:aCOLS[nIx][P1_VOLUME] //       11
						SZ6->(MSUNLOCK())
					ENDIF
					SZ6->(DBSKIP())
				ENDDO
			ENDIF
		Next nIx
	Endif
	//Fim I2107-110 - Paulo Apolinário. 22/07/2021

return

Static Function GETDCLR(aLinha,nLinha,aHeader)
	Local nRet := RGB(128,128,128)

	if Len(aLinha) > 0
		If Mod(nLinha,2) == 0 .AND. !( aLinha[ nLinha, Len( aLinha[ nlinha ] ) ] )
			nRet := RGB(255,255,255)
		ElseIf !( aLinha[ nLinha, Len( aLinha[ nlinha ] ) ] )
			nRet := RGB(178,203,231)
		Else
			nRet := RGB(128,128,128)
		Endif
	EndIf
Return nRet

Static Function LOTECLR(aLinha,nLinha,aHeader)
	Local nRet        := RGB(0,0,255)
	Local nQtdV       := 0
	Local nQtdD       := 0
	Local nPesoD      := 0
	Local cDNcs       := ""
	Local lLoteOk     := .F.
	Local cProduto    := ''
	Local aAreaSB1    := {}
	Local nPSMIN      := 0
	Local nPSMAX      := 0
	Local lKitPrd	  := .F.

	If Len(aLinha) > 0 .AND. Len( aLinha[nLinha] ) >= P1_VVISTA .AND. !( aLinha[nLinha, P1_DELETE] )

		If lInicia

			aAreaSB1 := SB1->( GetArea() )

			//cProduto := GDFieldGet("PRODUTO",nLinha)
			cProduto := aLinha[ nLinha, P1_PRODUTO]

			SB1->( dbSetOrder( 1 ) )
			SB1->( dbSeek( FwxFilial("SB1") + cProduto ) )

			nPSMIN := SB1->B1_PESOMIN
			nPSMAX := SB1->B1_PESOMAX

			RestArea( aAreaSB1 )

			// nQtdV   := GDFieldGet("QTDEP",nLinha)
			// nQtdD   := GDFieldGet("VOLUME",nLinha)
			// nPesoD  := GDFieldGet("PESOD",nLinha)
			// cDNcs   := GDFieldGet("NCS",nLinha)
			nQtdV   := aLinha[ nLinha, P1_QTDEP ]
			nQtdD   := aLinha[ nLinha, P1_VOLUME ]
			nPesoD  := aLinha[ nLinha, P1_PESOD ]
			// cDNcs   := aLinha[ nLinha, P1_NCS ]

			If (nQtdD >= nQtdV) .AND. nPesoD >= ( nQtdV * nPSMIN ) //.and. ALLTRIM(cDNcs) <> ""
				lLoteOk:= .T.
			EndIF

			If !Empty(aCOLS[nLinha,P1_KIT])
				lKitPrd:= .T.
			EndIf

		EndIf

		If aLinha[nLinha,P1_VVISTA] <> 'S' .And. Empty(aLinha[nLinha,P1_KIT])
			If nPesoD == 0 .AND. Mod(nLinha,2) == 0 .AND. !( aLinha[ nLinha, Len( aLinha[ nlinha ] ) ] )
				nRet := RGB(255,255,255)
			ElseIf nPesoD == 0 .AND. !( aLinha[ nLinha, Len( aLinha[ nlinha ] ) ] )
				nRet := RGB(178,203,231)
			Elseif nPesoD > 0 .AND. !lLoteOk .AND. !( aLinha[ nLinha, Len( aLinha[ nlinha ] ) ] )
				nRet := RGB(0, 0, 255)
			Elseif nPesoD > 0 .AND. lLoteOk .AND. !( aLinha[ nLinha, Len( aLinha[ nlinha ] ) ] )
				nRet := RGB(128,128,128)
			Elseif nPesoD > 0 .AND. lLoteOk .AND. ( aLinha[ nLinha, Len( aLinha[ nlinha ] ) ] )
				nRet := RGB(128,128,128)
			Endif
		ElseIf aLinha[nLinha,P1_VVISTA] == 'S' .And. Empty(aLinha[nLinha,P1_KIT])
			If nPesoD == 0 .AND. Mod(nLinha,2) == 0 .AND. !( aLinha[ nLinha, Len( aLinha[ nlinha ] ) ] )
				nRet := RGB(247,217,23)
			ElseIf nPesoD == 0 .AND. !( aLinha[ nLinha, Len( aLinha[ nlinha ] ) ] )
				nRet := RGB(245,240,213)
			Elseif nPesoD > 0 .AND. !lLoteOk
				nRet := RGB(0, 0, 255)
			Elseif nPesoD > 0 .AND. lLoteOk
				nRet := RGB(128,128,128)
			Elseif (aLinha[nLinha, Len( aLinha[ nlinha ] ) ] )
				nRet := RGB(128,128,128)
			Endif
		ElseIf aLinha[nLinha,P1_VVISTA] <> 'S' .And. !Empty(aLinha[nLinha,P1_KIT])
			If Mod(nLinha,2) == 0 .AND. !(aLinha[nLinha,Len(aLinha[nlinha])])
				nRet := RGB(214,0,110)
			ElseIf !(aLinha[nLinha,Len(aLinha[nlinha])])
				nRet := RGB(255,0,255)
			Elseif lLoteOk
				nRet := RGB(242,184,216)
			Elseif (aLinha[nLinha,Len(aLinha[nlinha])])
				nRet := RGB(242,184,216)
			Endif
		Endif
	Else
		If !( aLinha[nLinha, Len( aLinha[nlinha] ) ] )
			If Mod(nLinha,2) == 0
				nRet := RGB(255,255,255)
			Else
				nRet := RGB(178,203,231)
			Endif
		Else
			nRet := RGB(128,128,128)
		Endif
	EndIf

Return nRet

	*----------------------------------------------------------------------------*
STATIC FUNCTION FAT002E()
	*----------------------------------------------------------------------------*
	IF MSGYESNO('Preencher peso Despachado com o Peso Padrao do Produto  ?  ')
		MsAguarde( { || FAT002E2() } , "Aguarde Preenchendo com Peso Padrao..." )
	ENDIF

RETURN

	*----------------------------------------------------------------------------*
STATIC FUNCTION FAT002E2()
	*----------------------------------------------------------------------------*
	LOCAL nX
	LOCAL cCOD
	LOCAL nPESOP

	IF LEN(oGETDADOS:aCOLS)>0
		FOR nX := 1 TO LEN(oGETDADOS:aCOLS)
			IF oGETDADOS:aCOLS[nX][P1_QTDEP] >0
				cCOD   :=oGETDADOS:aCOLS[nX][P1_PRODUTO]+SPACE(15)
				cCOD   :=SUBSTR(cCOD,1,15)
				nPESOP :=POSICIONE('SB1',1,xFILIAL('SB1')+cCOD,'B1_PESO')
				IF nPESOP > 0 .AND. EMPTY(oGETDADOS:aCOLS[nX][P1_LOTE]) .AND. oGETDADOS:aCOLS[nX][P1_PESOD] == 0
					oGETDADOS:aCOLS[nX][P1_QTDED]  := oGETDADOS:aCOLS[nX][P1_QTDEP]
					oGETDADOS:aCOLS[nX][P1_PESOD]  := oGETDADOS:aCOLS[nX][P1_QTDEP] * nPESOP
					oGETDADOS:aCOLS[nX][P1_VOLUME] := oGETDADOS:aCOLS[nX][P1_QTDEP]
					oGETDADOS:aCOLS[nX][P1_DELETE] := .T.
				ENDIF
			ENDIF
		NEXT
		oGetDados:oBrowse:Refresh()
	ENDIF

RETURN

	*----------------------------------------------------------------------------*
STATIC FUNCTION FAT002B()
	*----------------------------------------------------------------------------*

	IF EMPTY(cTRANSP2)
		msgalert('Por Favor, preencher o Codigo e Placa  da Transportadora Primaria')
		RETURN
	ENDIF


	IF EMPTY(cPLACA2)
		msgalert('Por Favor, preencher a placa do caminhao da Transportadora Primaria')
		RETURN
	else
		cPLACA2 := UPPER(cPLACA2)
	ENDIF

	MsAguarde( { || FAT002B2() } , "Aguarde..." )

	// If Len( oGetDados:ACOLS ) > 0
	// 	For nI := 1 To Len( oGetDados:ACOLS )
	// 		oGetDados:nAt := nI
	// 		nQtdV := GDFieldGet("QTDEP",nI)
	// 		nQtdD := GDFieldGet("VOLUME",nI)
	// 		cDNcs := GDFieldGet("NCS",nI)
	// 		If ( nQtdD >= nQtdV ) .AND.
	// 			oGetDados:ACOLS[ nI, P1_DELETE] := .T.
	// 		Else
	// 			oGetDados:ACOLS[ nI, P1_DELETE] := .F.
	// 		EndIF
	// 		U_FAT002LOK(oGetDados)
	// 	Next
	// 	oGetDados:oBrowse:Refresh()
	// Endif

RETURN

	*----------------------------------------------------------------------------*
STATIC FUNCTION FAT002B2()
	*----------------------------------------------------------------------------*
	LOCAL cCTOP := SPACE(01)
	LOCAL lCTOP := .F.
	Local nI    := 0

	FAT002D()

	IF lFirst
		aCOLS2 := {}
		aCOLS  := {}
		oGetDados:ACOLS := AClone( aCOLS2 )
		oGetDados:oBrowse:Refresh()

		lFirst  := .F.
		cPROD   := space(15)
		cCLIE   := space(60)
		cENDR   := space(60)
		cPedven := space(30)
		nTOT    := 0
		nTOTVOL := 0
		nTOT2   := 0
		oTOT:REFRESH()
		oTOTVOL:REFRESH()
		oTOT2:REFRESH()
		oPROD:REFRESH()
		oCLIE:REFRESH()
		oENDR:REFRESH()
		oPEDVEN:REFRESH()
		oDESCI:REFRESH()
		oDESC2:REFRESH()

	ENDIF
	lCONTINUA :=.F.
	IF len(oGetDados:ACOLS) > 0
		IF MSGYESNO('Itens já preenchido Continua ?','Atenção')
			IF MSGNOYES('Itens já preenchido Continua ?, ','Atenção')
				aCOLS2   := {}
				aCOLS    := {}
				aCOLSLT  := {}
				aCOLSLOTE:= {}

				oGetDados:ACOLS := AClone( aCOLS2 )
				oGetDados:oBrowse:Refresh()
				oMLOTE1:ACOLS := AClone( aCOLSLT )
				oMLOTE1:oBrowse:Refresh()

				cPROD  :=space(15)
				cCLIE  :=space(90)
				cENDR   :=space(90)
				cPedven:=space(30)
				nTOT   :=0
				nTOTVOL :=0
				nTOT2  :=0
				oTOT:REFRESH()
				oTOTVOL:REFRESH()
				oTOT2:REFRESH()
				oPROD:REFRESH()
				oCLIE:REFRESH()
				oENDR:REFRESH()
				oPEDVEN:REFRESH()
				oDESCI:REFRESH()
				oDESC2:REFRESH()
				lCONTINUA :=.T.
			ENDIF
		ENDIF
	ELSE
		lCONTINUA :=.T.
	ENDIF
	IF lCONTINUA == .T.
		nCusto :=0

		cQUERY := CRLF + " SELECT Z5_VVISTA,Z5_NUM,Z5_CLIENTE,Z5_LOJACLI,A1_NREDUZ,A1_GRPVEN,A1_ROTENTR, "
		cQUERY += CRLF + "        Z5_TRANSP,Z5_TRANSP2,Z5_TRANSP3,Z5_VEICULO,Z5_VEIC2,Z5_NOTA,Z5_SERIE,         "
		cQUERY += CRLF + "        Z6_PRODUTO,Z6_UNSVEN,Z6_QTDVEN ,Z6_UM,Z6_QTDLIB2,Z6_QTDLIB,Z6_OMAVOL,Z6_OK,Z6_ITEM,Z5_CIDADE,Z5_END,A4_NOME,Z6_XPRDKIT "
		cQUERY += CRLF + "        , COALESCE(Z23.Z23_ID,'') Z23_ID, Z6_SALDWMS "

		cQUERY += CRLF + " FROM " + RetSqlName('SZ5') + " Z5 "

		cQUERY += CRLF + " INNER JOIN " + RetSqlName('SZ6') + " Z6 "
		cQUERY += CRLF + " 	  ON Z6.Z6_NUM = Z5.Z5_NUM "
		cQUERY += CRLF + "	 AND Z6_STATUS IN ('1')  "
		cQUERY += CRLF + "   AND Z6_ENTREG = '"+DTOS(dData1)+"'  "
		cQUERY += CRLF + "   AND Z6.D_E_L_E_T_ = ' ' "

		cQUERY += CRLF + " INNER JOIN " + RetSqlName('SA1') + " A1 "
		cQUERY += CRLF + "    ON A1_COD  = Z5_CLIENTE "
		cQUERY += CRLF + "   AND A1_LOJA = Z5_LOJACLI "
		IF !EMPTY(cZONA)
			cQUERY += CRLF + " AND A1_GRPVEN='"+cZONA+"'  "
		ENDIF
		cQUERY += CRLF + "   AND A1.D_E_L_E_T_ = ' ' "

		// cQUERY += CRLF + " INNER JOIN " + RetSQLName("ZZL") + " ZZL (NOLOCK)
		// cQUERY += CRLF + "    ON ZZL.ZZL_FILIAL = '" + xFilial("ZZL") + "' "
		// cQUERY += CRLF + "   AND ZZL.ZZL_COD = A1.A1_COD "
		// cQUERY += CRLF + "   AND ZZL.ZZL_LOJA = A1.A1_LOJA "
		// cQUERY += CRLF + "   AND ( 	  ZZL.ZZL_APTOVV = 'N' OR "
		// cQUERY += CRLF + "         	( ZZL.ZZL_APTOVV = 'S' AND ZZL.ZZL_VVISTA = 'N' ) "
		// cQUERY += CRLF + "       )"
		// cQUERY += CRLF + "   AND ZZL.D_E_L_E_T_ = '' "

		cQUERY += CRLF + " INNER JOIN " + RetSqlName('SA4') + " A4 "
		cQUERY += CRLF + "    ON A4_COD = Z5_TRANSP "
		cQUERY += CRLF + "	 AND A4.D_E_L_E_T_ = ' ' "

		cQUERY += CRLF + " INNER JOIN " + RetSqlName('SB1') + " B1 "
		cQUERY += CRLF + "	  ON B1_COD = Z6_PRODUTO "
		cQUERY += CRLF + "	  AND B1_FILIAL = '02' "

		//IF SUBSTR(cOrdG,1,1) =='2'   //'1 - TODOS ITENS '  '2 - ITENS A GRANEL'
		//	cQUERY += " AND B1_TPDESP='2'  "
		//ENDIF

		DO CASE                              //'1 - Todos Itens','2 - Itens a granel','3 - Peso Padrao'
		CASE SUBSTR(cOrdG,1,1) =='2'
			cQUERY += CRLF + " AND B1_TPDESP='2'  "
		CASE SUBSTR(cOrdG,1,1) =='3'
			cQUERY += CRLF + " AND B1_TPDESP='3'  "
		ENDCASE

		cQUERY += CRLF + "   AND B1.D_E_L_E_T_ = ' '  "

		cQUERY += CRLF + " LEFT JOIN " + RetSqlName('Z23') + " Z23 "
		cQUERY += CRLF + "   ON Z23_FILIAL = '02'"
		cQUERY += CRLF + "  AND Z23_NUM = Z6.Z6_NUM "
		cQUERY += CRLF + "  AND Z23.D_E_L_E_T_ = ' ' "

		cQUERY += CRLF + " WHERE  "
		cQUERY += CRLF + " 		Z5.D_E_L_E_T_ = ' ' "
		cQUERY += CRLF + "	AND Z5_TRANSP='"+cTRANSP+"' "

		//	IF cEMP=='Omamori/BM'
		//		cQUERY += "  AND Z5_EMPRESA IN ('2','3')"
		//	ELSE
		//		cQUERY += "  AND Z5_EMPRESA ='1'        "
		//	ENDIF

/* */
		//------------------------- ORDER------------------------------
		DO CASE
		CASE SUBSTR(cOrdem,1,1) =='1'   //'1 - Zona crescente Roteiro Crescente'
			cQUERY += CRLF + "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, A1_GRPVEN,A1_ROTENTR     ,Z5_CLIENTE ,Z5_LOJACLI,Z5_NUM,REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO) DESC  "
		CASE SUBSTR(cOrdem,1,1) =='2'   //'2 - Zona Crescente Roteiro Decrescente'
			cQUERY += CRLF + "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, A1_GRPVEN,A1_ROTENTR DESC,Z5_NUM,Z5_CLIENTE DESC ,Z5_LOJACLI,REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO)  "
		CASE SUBSTR(cOrdem,1,1) =='3'   //'3 - Codigo de Produto'
			cQUERY += CRLF + "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO),A1_GRPVEN,A1_ROTENTR ,Z5_CLIENTE ,Z5_LOJACLI,Z5_NUM  "
		CASE SUBSTR(cOrdem,1,1) =='4'   //'4 - Cidade'
			cQUERY += CRLF + "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, Z5_CIDADE,Z5_END,Z5_NUM,Z5_CLIENTE ,Z5_LOJACLI  "
		OTHERWISE
			cQUERY += CRLF + "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, A1_GRPVEN,A1_ROTENTR ,Z5_CLIENTE ,Z5_LOJACLI,Z5_NUM,REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO) DESC  "
		ENDCASE
		//-------------------------------------------------------------

		//Filtro por Romaneio
		If cFiltraRom == 'S'
			cQuery := GetQryRom()
		Endif

		cQuery := ChangeQuery(CQUERY)
		TcQuery cQuery ALIAS "TRB" NEW

		DBSELECTAREA("TRB")
		IF EMPTY(cTRANSP)
			cTRANSP   :=TRB->Z5_TRANSP
			cNTRANSP  :=POSICIONE('SA4',1,xFILIAL('SA4')+TRB->Z5_TRANSP ,'A4_NOME')
			oNTRANSP  :REFRESH()
		ENDIF
		//IF EMPTY(cTRANSP2)
		//	cTRANSP2  :=TRB->Z5_TRANSP2
		//	cPLACA2   :=TRB->Z5_VEICULO
		//	cNTRANSP2 :=POSICIONE('SA4',1,xFILIAL('SA4')+TRB->Z5_TRANSP2,'A4_NOME')
		//	oPLACA2   :REFRESH()
		//	oNTRANSP2 :REFRESH()
		//ENDIF
		IF EMPTY(cTRANSP3)
			cTRANSP3  :=TRB->Z5_TRANSP3
			cPLACA3   :=UPPER(TRB->Z5_VEICULO)
			cNTRANSP3 :=POSICIONE('SA4',1,xFILIAL('SA4')+TRB->Z5_TRANSP3,'A4_NOME')
			oPLACA3   :REFRESH()
			oNTRANSP3 :REFRESH()
		ENDIF

		cNUMPPV :=TRB->Z5_NUM

		_cSerie  := GetMV("MV_SERFAT")

		lFirst3 :=.T.

		DO WHILE !TRB->(EOF())

			cCTOP  :=TRB->Z6_OK
			DO CASE
			CASE cCTOP =='F'
				lCTOP :=.F.
			CASE cCTOP =='T'
				lCTOP :=.T.
			OTHERWISE
				lCTOP :=.F.
			ENDCASE
			nDISP  :=0
			cROTENT:=strzero(TRB->A1_ROTENTR,5)
			cROTENT:=SUBSTR(cROTENT,1,3)+' / '+SUBSTR(cROTENT,4,2)

			AADD(aCols,{	TRB->Z5_NUM								,;  //01
			TRB->Z5_CLIENTE+'-'+TRB->Z5_LOJACLI		,;  //02
			TRB->A1_NREDUZ							,;  //03
			TRB->A1_GRPVEN							,;  //04
			cROTENT									,;  //05
			TRB->Z6_PRODUTO							,;  //06
			TRB->Z6_UNSVEN							,;  //07
			TRB->Z6_QTDVEN							,;  //08
			TRB->Z6_UM								,;  //09
			TRB->Z6_QTDLIB2							,;  //10
			TRB->Z6_QTDLIB							,;  //11
			TRB->Z6_OMAVOL							,;  //12
			SPACE(06)								,;  //13
			SPACE(45)								,;  //14
			TRB->Z23_ID								,;  //15
			TRB->Z6_SALDWMS							,;  //16
			SPACE(45)								,;  //17
			TRB->Z5_NOTA							,;  //18
			TRB->Z5_SERIE							,;  //19
			TRB->Z6_ITEM							,;  //20
			TRB->Z5_VVISTA							,;	//21 Venda à Vista?
			TRB->Z6_XPRDKIT							,;  //22 COD KIT N
			lCTOP									})  //23 .F. POSICAO 8Flag de Delecao

			SZ7->(DBSELECTAREA('SZ7'))
			SZ7->(DBSETORDER(4))
			SZ7->(DBSEEK(xFILIAL('SZ7')+TRB->Z5_NUM+TRB->Z5_CLIENTE+TRB->Z5_LOJACLI+TRB->Z6_PRODUTO))

			IF SZ7->(FOUND())
				DO WHILE .NOT. SZ7->(EOF()) .AND. SZ7->Z7_FILIAL  ==xFILIAL('SZ7')   .AND. ;
						SZ7->Z7_PEDIDO  ==TRB->Z5_NUM      .AND. ;
						SZ7->Z7_CLIENTE ==TRB->Z5_CLIENTE  .AND. ;
						SZ7->Z7_LOJA    ==TRB->Z5_LOJACLI  .AND. ;
						SZ7->Z7_PRODUTO ==TRB->Z6_PRODUTO

					IF SZ7->Z7_ITEM == TRB->Z6_ITEM
						AADD(aCOLSLT,{	SZ7->Z7_CODBAR,;
							SZ7->Z7_PRODUTO,;
							SZ7->Z7_LOTE,;
							SZ7->Z7_VALID,;
							SZ7->Z7_QTDE,;
							SZ7->Z7_PESO,;
							SZ7->Z7_PEDIDO,;   //pedido
						SZ7->Z7_CLIENTE+'-'+SZ7->Z7_LOJA,;   //idclie
						SZ7->Z7_PRODUTO,;   //produto
						SUBSTR(SZ7->Z7_LOTE,08,06),;
							SZ7->Z7_NSEQ,;
							SZ7->Z7_ITEM,;
							.F.})  //.f. POSICAO 8Flag de Delecao]

						nLSEQ1 :=SZ7->Z7_NSEQ
						IF nLSEQ1 >nLSEQ
							nLSEQ:=nLSEQ1
						ENDIF
					ENDIF
					SZ7->(DBSKIP())
				ENDDO
			ENDIF

			TRB->(DBSKIP())
		ENDDO
		TRB->(DBCLOSEAREA())
		aCOLS2 := AClone( aCOLS )
		oGetDados:ACOLS := AClone( aCOLS2 )
		oGetDados:oBrowse:Refresh()
		oGetDados:ForceRefresh()
		_ORDG:=cORDG
		lInicia := .T.
	ENDIF
RETURN

	*----------------------------------------------------------------------------*
STATIC FUNCTION FAT002D()
	*----------------------------------------------------------------------------*
//IF MSGYESNO('Limpar Linhas Despacho ?','Atenção')
//	IF MSGNOYES('CANCELAR este Despacho ?','Atenção')
	aCOLS2 :={}
	aCOLS  :={}
	aCOLSLT  :={}
	aCOLSLOTE:={}

	oGetDados:ACOLS := AClone( aCOLS2 )
	oGetDados:oBrowse:Refresh()

	oMLOTE1:ACOLS := AClone( aCOLSLT )
	oMLOTE1:oBrowse:Refresh()

	cPROD  :=space(15)
	cCLIE  :=space(90)
	cENDR   :=space(90)
	cPedven:=space(30)
	nTOT   :=0
	nTOTVOL :=0
	nTOT2  :=0
	oTOT:REFRESH()
	oTOTVOL:REFRESH()
	oTOT2:REFRESH()
	oPROD:REFRESH()
	oCLIE:REFRESH()
	oENDR:REFRESH()
	oPEDVEN:REFRESH()
	oDESCI:REFRESH()
	oDESC2:REFRESH()

//ENDIF
//ENDIF
RETURN

	*----------------------------------------------------------------------------*
STATIC FUNCTION FAT002C()
	*----------------------------------------------------------------------------*
	Local aVVCorte := VldVVista()
	Local nI        := 0
	Local nTamArray := Len( aVVCorte )
	Local cMsgCorte := ''
	Local aKitCorte := VldKit()
	Local nTamKit	:= Len( aKitCorte )

	If nTamArray > 0
		cMsgCorte := 'OS PEDIDOS ABAIXO SÃO DO TIPO VENDA À VISTA E NÃO PODEM SOFRER CORTES:' + CRLF + CRLF
		For nI := 1 To nTamArray
			cMsgCorte += '- ' + aVVCorte[ nI ] + CRLF
		Next nI
		Aviso('PEDIDOS VENDA À VISTA', cMsgCorte,{"OK"}, 2)
		Return
	Endif

	If nTamKit > 0
		cMsgCorte := 'OS PEDIDOS ABAIXO SÃO DO TIPO KIT E NÃO PODEM SOFRER CORTES:' + CRLF + CRLF
		For nI := 1 To nTamArray
			cMsgCorte += '- ' + aKitCorte[ nI ] + CRLF
		Next nI
		Aviso('PEDIDOS KIT', cMsgCorte,{"OK"}, 2)
		Return
	Endif

	IF MSGYESNO('Despachar ?','Atenção')
		IF SUBSTR(_ORDG,1,1)=='2' .OR.  SUBSTR(cORDG,1,1)=='2'
			MSGALERT('Antes de despachar, '  +Chr(13)+Chr(10)+;
				'Alterar filtro de A GRANEL para Todos os Itens, '+Chr(13)+Chr(10)+;
				'E peressionar o botão Visualizar','Atenção')
			RETURN
		ELSE
			MsAguarde( { || FAT002C2() } , "Aguarde..." )
			//msgalert('Despachado Transportadora '+cTRANSP+'-'+cNTRANSP)
			cTIPE :='N'
			cTIT  :='DESPACHO'
			cMEN1 :=''
			cMEN2 :=''
			cMEN3 :='Despachado Transportadora '+cTRANSP+'-'+cNTRANSP
			cMEN4 :=''
			nP1   :=135
			nP2   :=0
			nP3   :=500
			nP4   :=700
			U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.
		ENDIF
	ENDIF
RETURN

	*----------------------------------------------------------------------------*
STATIC FUNCTION FAT002C2()
	*----------------------------------------------------------------------------*
	LOCAL nX 	  	:=0
	local ny 	  	:=0
	Local cPed 	  	:= ""

	SZ5->(DBSELECTAREA('SZ5'))
	SZ5->(DBSETORDER(1))//NUMERO

	SZ6->(DBSELECTAREA('SZ6'))
	SZ6->(DBSETORDER(3))//NUMERO+CLIENTE+LOJA+PRODUTO

	_cHoraFim := Time()
	FOR nY :=1 TO LEN(oGetDados:ACOLS)
		SZ6->(DBSEEK(xFILIAL('SZ6')+aCOLS[nY][P1_PEDIDO]+SUBSTR(aCOLS[nY][P1_IDCLIE],1,6)+SUBSTR(aCOLS[nY][P1_IDCLIE],8,2)+aCOLS[nY][P1_PRODUTO]))
		IF SZ6->(FOUND())
			DO WHILE .NOT. SZ6->(EOF()) .AND.  SZ6->Z6_FILIAL==xFILIAL('SZ6') .AND.;
					SZ6->Z6_NUM     == aCOLS[nY][P1_PEDIDO]             .AND.  ;
					SZ6->Z6_CLI     == SUBSTR(aCOLS[nY][P1_IDCLIE],1,6) .AND.  ;
					SZ6->Z6_LOJA    == SUBSTR(aCOLS[nY][P1_IDCLIE],8,2) .AND.  ;
					SZ6->Z6_PRODUTO == aCOLS[nY][P1_PRODUTO]

				IF SZ6->Z6_ITEM == aCOLS[nY][P1_ITEM]
					SZ6->(RECLOCK('SZ6',.F.))
					IF oGetDados:aCOLS[nY][P1_PESOD] >0
						SZ6->Z6_QTDLIB2  :=oGetDados:aCOLS[nY][P1_QTDED] //       10
					ELSE
						SZ6->Z6_QTDLIB2  :=0
					ENDIF
					SZ6->Z6_QTDLIB   :=oGetDados:aCOLS[nY][P1_PESOD] //       11
					SZ6->Z6_STATUS   :='2'
					SZ6->Z6_OMAVOL   :=oGetDados:aCOLS[nY][P1_VOLUME] //
					SZ6->(MSUNLOCK())
				ENDIF
				SZ6->(DBSKIP())
			ENDDO
		ELSE
			MSGALERT('MSG 000001','MSG')
		ENDIF
		SZ5->(DBSEEK(xFILIAL('SZ5')+ACOLS[nY][1]))
		IF SZ5->(FOUND())
			SZ5->(RECLOCK('SZ5',.F.))
			SZ5->Z5_VEICULO  :=UPPER(cPLACA3)
			SZ5->Z5_HORAINI  := _cHoraIni
			SZ5->Z5_HORAFIM  := _cHoraFim

			//Registra dados da transportadora
			SZ5->Z5_TRANSP2  :=cTRANSP2
			SZ5->Z5_TRANSP3  :=cTRANSP3
			SZ5->Z5_VEIC2    :=UPPER(cPLACA2)
			SZ5->Z5_VEICULO  :=UPPER(cPLACA3)

			IF EMPTY(SZ5->Z5_NOTA)
				SZ5->Z5_NOTA  :=ACOLS[nY][P1_NOTA]
				SZ5->Z5_SERIE :=ACOLS[nY][P1_SERIE]
			ENDIF

			SZ5->(MSUNLOCK())

		ELSE
			MSGALERT('MSG 000002','MSG')
		ENDIF
		cPed := aCOLS[nY][P1_PEDIDO]
	NEXT

	//U_FATA0020( aCols, aColsLT ) //Grava o despacho na tela outbound_dispatch do Middle (Integração WMS)

	U_FATA0024( oGetDados:ACOLS )  //Envia e-mail ao vendedor avisando que o pedido venda à vista foi cortado. Paulo Apolinário - Geeker Company. 21/05/2021

	aCOLS2   :={}
	aCOLS    :={}
	aCOLSLT  :={}
	aCOLSLOTE:={}
	oGetDados:ACOLS := ACLone( aCOLS2 )
	oGetDados:oBrowse:Refresh()
	oMLOTE1:ACOLS := AClone( aCOLSLT )
	oMLOTE1:oBrowse:Refresh()

	cPROD  :=space(15)
	cCLIE  :=space(90)
	cENDR   :=space(90)
	cPedven:=space(30)
	nTOT   :=0
	nTOTVOL :=0
	nTOT2  :=0
	oTOT:REFRESH()
	oTOTVOL:REFRESH()
	oTOT2:REFRESH()
	oPROD:REFRESH()
	oCLIE:REFRESH()
	oENDR:REFRESH()
	oPEDVEN:REFRESH()
	oDESCI:REFRESH()
	oDESC2:REFRESH()

	SA4->(DBSELECTAREA('SA4'))
	SA4->(DBSETORDER(1))
	SA4->(DBSEEK(xFILIAL('SA4')+cTRANSP))
	IF SA4->(FOUND())
		SA4->(RECLOCK('SA4',.F.))
		SA4->A4_LOCAL:='2'
		SA4->(MSUNLOCK())
	ENDIF

//mls   aqui gerar os pedidos     teste
//U_REGDAUT()

	U_UPDFGSZ4(cPed)

RETURN

	*----------------------------------------------------------------------------*
USER Function PEFldTot1(oDlg,aGets,aPosGet,bRefresh)
	*----------------------------------------------------------------------------*

	Local aObjetos := Array(Len(aGets))

	@ 06,aPosGet[1]    SAY   "Produto"    Of oDlg  PIXEL SIZE 55 ,9  FONT oFontBRW3 //"Valor da Mercadoria"
	@ 05,aPosGet[1]*05 MSGET oPROD VAR cPROD       PICTURE PesqPict('SB1','B1_DESC')    OF oDlg PIXEL COLOR CLR_BLUE FONT oFontBRW  When .F. SIZE 435,09 //220 300
	@ 18,aPosGet[1]    SAY   "Cliente"    Of oDlg  PIXEL SIZE 55 ,9 FONT oFontBRW3//"Descontos"
	@ 17,aPosGet[1]*05 MSGET oCLIE VAR cCLIE       PICTURE PesqPict('SA1','A1_NOME')    OF oDlg PIXEL COLOR CLR_BLUE FONT oFontBRW  When .F. SIZE 435,09

	@ 30,aPosGet[1]    SAY   "Pedido"     Of oDlg  PIXEL SIZE 55 ,9 FONT oFontBRW3//"pedido"
	@ 29,aPosGet[1]*05 MSGET oPedven VAR cPedven   PICTURE PesqPict('SB1','B1_DESC')    OF oDlg PIXEL COLOR CLR_BLUE FONT oFontBRW4 When .F. SIZE 435,09

	@ 42,aPosGet[1]    SAY   "Obs. Item"  Of oDlg  PIXEL SIZE 55 ,9 FONT oFontBRW3//"Valor da Mercadoria"
	@ 41,aPosGet[1]*05 MSGET oDESCI VAR cDESCI     PICTURE PesqPict('SB1','B1_DESC')    OF oDlg PIXEL COLOR CLR_RED  FONT oFontBRW2 When .F. SIZE 435,09

	@ 54,aPosGet[1]    SAY   "Endereço"   Of oDlg  PIXEL SIZE 55 ,9 FONT oFontBRW3// endereço
	@ 53,aPosGet[1]*05 MSGET oENDR VAR cENDR       PICTURE PesqPict('SB1','B1_DESC')    OF oDlg PIXEL COLOR CLR_RED  FONT oFontBRW2 When .F. SIZE 435,09

	@ 05,aPosGet[4]+aPosGet[1]*05    MSGET oTOT  VAR nTOT        PICTURE "@E 9,999,999,999.999"       OF oDlg PIXEL COLOR CLR_GREEN FONT oFontGRD  When .F. SIZE 160,30

	@ 38,aPosGet[4]+aPosGet[1]*05    MSGET oTOTVOL  VAR nTOTVOL  PICTURE "@E 9,999,999,999.999"       OF oDlg PIXEL COLOR CLR_GREEN FONT oFontGRD  When .F. SIZE 160,30


	oTOT:REFRESH()
	oTOTVOL:REFRESH()
	oPROD:REFRESH()
	oCLIE:REFRESH()
	oENDR:REFRESH()
	oPedven:REFRESH()
	oDESCI:REFRESH()

Return(.T.)

	*----------------------------------------------------------------------------*
USER Function PFldTot1(aGets,aObjetos)
	*----------------------------------------------------------------------------*
	LOCAL nX
	LOCAL nPSMIN  :=0
	LOCAL nPSMAX  :=0
	ny:=ny+1

	IF !EMPTY(oGetDados:aCOLS[n][P1_LOTE])
		MSGALERT('Item com LOTE nao pode ser alterado')
		Return(.F.)
	ElseIf SUBSTR(oGetDados:aCOLS[n][P1_IDCLIE],1,6)+SUBSTR(oGetDados:aCOLS[n][P1_IDCLIE],8,2)  == ALLTRIM(cCliCFGru)
		MSGALERT('Pedidos NT somente podem ter peso por despacho')
		Return(.F.)
	else
		SB1->(DBSELECTAREA('SB1'))
		SB1->(DBSETORDER(1))
		If Len(oGetDados:aCOLS) > 0
			SB1->(DbSeek(xFilial("SB1") + oGetDados:aCOLS[n][P1_PRODUTO]))
		EndIf

		nPSMIN := SB1->B1_PESOMIN
		nPSMAX := SB1->B1_PESOMAX

		IF M->PESOD >0
			IF  oGetDados:ACOLS[n][P1_QTDEP] >0
				IF oGetDados:aCOLS[n][P1_QTDED]*nPSMIN  > M->PESOD//07
					lReturn := fDigSenha()
					If !lReturn
						Return(.F.)
					Endif

				ELSEIF oGetDados:aCOLS[n][P1_QTDED] * nPSMAX < M->PESOD
					lReturn := fDigSenha()
					If !lReturn
						Return(.F.)
					Endif

				ENDIF
			ELSE
				IF  M->PESOD > oGetDados:ACOLS[n][P1_PESOP]
					IF !MSGYESNO('Peso Digitado maior que peso do Pedido continua ? '	+Chr(13)+Chr(10)+;
							'Peso Pedido  : ' +LTRIM(TransForm(oGetDados:ACOLS[n][P1_PESOP] ,'@E 999,999,999.999'))  )
						Return(.F.)
					ENDIF
				ENDIF
			ENDIF
		ENDIF


	ENDIF

	IF M->PESOD >0
		DO CASE
		CASE oGetDados:aCOLS[n][P1_QTDEP]  <> 0
			oGetDados:aCOLS[n][P1_VOLUME] := oGetDados:aCOLS[n][P1_QTDED]
		CASE oGetDados:aCOLS[n][P1_QTDEP]  == 0 .AND. oGetDados:aCOLS[n][P1_QTDED] <> 0
			oGetDados:aCOLS[n][P1_VOLUME] := oGetDados:aCOLS[n][P1_QTDED]
		CASE oGetDados:aCOLS[n][P1_QTDEP]  == 0 .AND. oGetDados:aCOLS[n][P1_QTDED] == 0
			oGetDados:aCOLS[n][P1_QTDED]  := 1
			oGetDados:aCOLS[n][P1_VOLUME] := 1
		ENDCASE
		oGetDados:ACOLS[n][P1_DELETE] := .T.
	ELSE
		oGetDados:aCOLS[n][P1_QTDED]  := 0
		oGetDados:aCOLS[n][P1_VOLUME] := 0
		oGetDados:ACOLS[n][P1_DELETE] := .F.
	ENDIF
	IF ny>=2

		aCOLS2 := AClone( oGetDados:ACOLS )
		nTOT :=0
		nTOTVOL:=0
		nTOT2 :=0

		FOR nX := 1 TO LEN(aCOLS2)
			IF nX==n
				nTOT :=nTOT+M->PESOD
				nTOTVOL :=nTOTVOL + oGetDados:aCOLS[n][P1_VOLUME]
				nTOT2:=nTOT
			ELSE
				nTOT :=nTOT+ACOLS2[nX][P1_PESOD]
				nTOTVOL :=nTOTVOL+ACOLS2[nX][P1_VOLUME]
				nTOT2:=nTOT
			ENDIF
		NEXT
	ENDIF

	oTOT:REFRESH()
	oTOTVOL:REFRESH()
	oTOT2:REFRESH()
	U_FATGRV1(oGetDados,'2')//mls

RETURN.T.

	*----------------------------------------------------------------------------*
USER Function PFLTALT1()
	*----------------------------------------------------------------------------*
	LOCAL nLIN  :=oMLOTE1:nat
	IF  !msgyesno('Alterar quantidade do Lote?','Confirma')
		Return .F.
	ELSE
		aCOLSLT[n][P2_QTDE] 		   := M->QTDE
		oMLOTE1:aCOLS[nLin][P3_QTDE]   := M->QTDE
		U_MLOTE1DEL(oMLOTE1,oGetDados)
	ENDIF
RETURN(.T.)

	*----------------------------------------------------------------------------*
USER Function PFldTo2A(aGets,aObjetos)
	*----------------------------------------------------------------------------*
	ny:=ny+1
	IF !EMPTY(oGetDados:aCOLS[n][P1_LOTE])
		msgalert('Quantidade com lote, só pode ser alterado no Lote','Mensagem')
		Return .F.
	ElseIf SUBSTR(oGetDados:aCOLS[n][P1_IDCLIE],1,6)+SUBSTR(oGetDados:aCOLS[n][P1_IDCLIE],8,2)  == ALLTRIM(cCliCFGru)
		MSGALERT('Pedidos NT somente podem ter peso por despacho','Mensagem')
		Return(.F.)
	ENDIF

RETURN(.T.)

	*----------------------------------------------------------------------------*
USER Function MLOTE1(cLOTEVIF)
	*----------------------------------------------------------------------------*
	Local cAlias 	:= GetNextAlias()
	Local cFornece 	:= SuperGetMV( "MV_YFORSA5", .F., "003811;003811" )
	Local lProdExt  := .F.
	Local cProdExt	:= ""

	nDIV      :=1
	cLOTEVIF  :=ALLTRIM(cLOTEVIF)
	cCodBar   :=ALLTRIM(cLOTEVIF)
	nPSMIN    := 0
	nPSMAX    := 0
	nPedPSMin := 0
	nPedPSMax := 0

	cPRODUTO  :=SUBSTR(ALLTRIM(cLOTEVIF),32,Len(cLoteVif))  // TAMANHO 26+ENTER =27
	cPRODUTO := AllTrim(cProduto)

	SB1->(DBSELECTAREA('SB1'))
	SB1->(DBSETORDER(1))
	IF SB1->(DBSEEK(xFILIAL('SB1')+cPRODUTO))
		nPSMIN := SB1->B1_PESOMIN
		nPSMAX := SB1->B1_PESOMAX
	EndIf

	//IF SUBSTR(ALLTRIM(cLOTEVIF),04,01) <> ',' // .or.  SUBSTR(ALLTRIM(cLOTEVIF),20,01) <>' '
	IF !( cValtoChar(At(',',cLoteVif)) $ "4/5" )
		cTIPE :='N'
		cTIT  :='Mensagem'
		cMEN1 :='Problema na leitura do Codigo de Barra '+cLOTEVIF+ ' '
		cMEN2 :='Selecionar outro código de barra, ou tente novamente. '
		cMEN3 :=''
		cMEN4 :=''
		nP1   :=135
		nP2   :=0
		nP3   :=300
		nP4   :=700

		U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

		//IF lEXPALERT ==.F.
		oGetDados:aCOLS[n][P1_LOTEVIF] := PadR('', TamSX3('Z6_LOTEVIF')[1])
		Return("")
		//ENDIF
	ENDIF

	If Len(AllTrim(cLOTEVIF)) == 26
		//  012,0100015961630060574152
		//  012,010 001   596163 0060574 152
		//  peso    peças nsc    lote    prod
		//	*--------PESO--------------
		cPESO     :=SUBSTR(ALLTRIM(cLOTEVIF),01,03)+'.'+SUBSTR(ALLTRIM(cLOTEVIF),05,03)
		nPESO     :=VAL(SUBSTR(ALLTRIM(cPESO),01,07))
		//	*--------PECA--------------
		cPECA     :=SUBSTR(ALLTRIM(cLOTEVIF),08,03)
		nPECA     :=VAL(SUBSTR(ALLTRIM(cPECA),01,03))
		//	*----------------------
		cNCS      :=SUBSTR(ALLTRIM(cLOTEVIF),11,06)
		cLOTE     :=SUBSTR(ALLTRIM(cLOTEVIF),17,07)
		cVALIDADE :=SPACE(10)
		//cPRODUTO  :=SUBSTR(ALLTRIM(cLOTEVIF),24,03)  // TAMANHO 26+ENTER =27
		cPRODUTO  :=SUBSTR(ALLTRIM(cLOTEVIF),24,Len(cLoteVif))  // TAMANHO 26+ENTER =27
		cProduto := AllTrim(cProduto)
		_QTDEP := oGetDados:ACOLS[n][P1_QTDEP]
		_PESOP := oGetDados:ACOLS[n][P1_PESOP]
		_QTDED := oGetDados:aCOLS[n][P1_QTDED]
		_PESOD := oGetDados:aCOLS[n][P1_PESOD]

	ElseIf Len(AllTrim(cLOTEVIF)) == 28 .Or. Len(AllTrim(cLOTEVIF)) == 29 //29 = ADELE
		//  012,0100015961630060574152
		//  012,010 001   596163 0060574 152
		//  peso    peças nsc    lote    prod

		*--------PESO--------------
		cPESO     :=SUBSTR(ALLTRIM(cLOTEVIF),01,03)+'.'+SUBSTR(ALLTRIM(cLOTEVIF),05,03)
		nPESO     :=VAL(SUBSTR(ALLTRIM(cPESO),01,07))
		*--------PECA--------------
		cPECA     :=SUBSTR(ALLTRIM(cLOTEVIF),08,03)
		nPECA     :=VAL(SUBSTR(ALLTRIM(cPECA),01,03))
		*----------------------
		cNCS      :=SUBSTR(ALLTRIM(cLOTEVIF),11,06)
		cLOTE     :=SUBSTR(ALLTRIM(cLOTEVIF),17,07)
		cVALIDADE :=SPACE(10)
		//cPRODUTO  :=SUBSTR(ALLTRIM(cLOTEVIF),24,03)  // TAMANHO 26+ENTER =27
		cPRODUTO  :=SUBSTR(ALLTRIM(cLOTEVIF),24,Len(cLoteVif))  // TAMANHO 26+ENTER =27
		cPRODUTO := AllTrim(cProduto)
		_QTDEP := oGetDados:ACOLS[n][P1_QTDEP]
		_PESOP := oGetDados:ACOLS[n][P1_PESOP]
		_QTDED := oGetDados:aCOLS[n][P1_QTDED]
		_PESOD := oGetDados:aCOLS[n][P1_PESOD]

	Elseif Len(AllTrim(cLOTEVIF)) == 36 .AND. At(',', cLOTEVIF) == 5
		*--------PESO--------------
		cPESO     :=SUBSTR(ALLTRIM(cLOTEVIF),01,04)+'.'+SUBSTR(ALLTRIM(cLOTEVIF),06,03)
		nPESO     :=VAL(SUBSTR(ALLTRIM(cPESO),01,08))
		*--------PECA--------------
		cPECA     :=SUBSTR(ALLTRIM(cLOTEVIF),09,02)
		nPECA     :=VAL(SUBSTR(ALLTRIM(cPECA),01,03))
		*----------------------
		cNCS      :=SUBSTR(ALLTRIM(cLOTEVIF),11,06)
		cLOTE     :=SUBSTR(ALLTRIM(cLOTEVIF),17,07)
		//cVALIDADE :=SPACE(10)
		cVALIDADE := SUBSTR(ALLTRIM(cLOTEVIF),24,08)
		//cPRODUTO  :=SUBSTR(ALLTRIM(cLOTEVIF),24,03)  // TAMANHO 26+ENTER =27
		cPRODUTO  :=SUBSTR(ALLTRIM(cLOTEVIF),32,Len(cLoteVif))  // TAMANHO 26+ENTER =27
		cPRODUTO := AllTrim(cProduto)
		_QTDEP := oGetDados:ACOLS[n][P1_QTDEP]
		_PESOP := oGetDados:ACOLS[n][P1_PESOP]
		_QTDED := oGetDados:aCOLS[n][P1_QTDED]
		_PESOD := oGetDados:aCOLS[n][P1_PESOD]

		If len(cPRODUTO) == 0

			cPRODUTO  :=SUBSTR(ALLTRIM(cLOTEVIF),21,Len(cLoteVif))  // TAMANHO 26+ENTER =27
			cPRODUTO := AllTrim(cProduto)

		ElseIF len(cPRODUTO) < 3

			cPRODUTO  :=SUBSTR(ALLTRIM(cLOTEVIF),24,Len(cLoteVif))  // TAMANHO 26+ENTER =27
			cPRODUTO := AllTrim(cProduto)

		EndIf
	Else
		//  012,010001596163006057427052016152
		//  012,010 001   596163 0060574 27052016  152
		//  peso    peças nsc    lote    validade  prod

		*--------PESO--------------
		cPESO     :=SUBSTR(ALLTRIM(cLOTEVIF),01,03)+'.'+SUBSTR(ALLTRIM(cLOTEVIF),05,03)
		nPESO     :=VAL(SUBSTR(ALLTRIM(cPESO),01,07))
		*--------PECA--------------
		cPECA     :=SUBSTR(ALLTRIM(cLOTEVIF),08,03)
		nPECA     :=VAL(SUBSTR(ALLTRIM(cPECA),01,03))
		*----------------------
		cNCS      :=SUBSTR(ALLTRIM(cLOTEVIF),11,06)
		cLOTE     :=SUBSTR(ALLTRIM(cLOTEVIF),17,07)
		//cVALIDADE :=SPACE(10)
		cVALIDADE := SUBSTR(ALLTRIM(cLOTEVIF),24,08)
		//cPRODUTO  :=SUBSTR(ALLTRIM(cLOTEVIF),24,03)  // TAMANHO 26+ENTER =27
		cPRODUTO  :=SUBSTR(ALLTRIM(cLOTEVIF),32,Len(cLoteVif))  // TAMANHO 26+ENTER =27
		cPRODUTO := AllTrim(cProduto)
		_QTDEP := oGetDados:ACOLS[n][P1_QTDEP]
		_PESOP := oGetDados:ACOLS[n][P1_PESOP]
		_QTDED := oGetDados:aCOLS[n][P1_QTDED]
		_PESOD := oGetDados:aCOLS[n][P1_PESOD]

		If len(cPRODUTO) == 0

			cPRODUTO  :=SUBSTR(ALLTRIM(cLOTEVIF),21,Len(cLoteVif))  // TAMANHO 26+ENTER =27
			cPRODUTO := AllTrim(cProduto)

		ElseIF len(cPRODUTO) < 3

			cPRODUTO  :=SUBSTR(ALLTRIM(cLOTEVIF),24,Len(cLoteVif))  // TAMANHO 26+ENTER =27
			cPRODUTO := AllTrim(cProduto)

		EndIf
	EndIf

	IF nPECA <=0      // .or.  SUBSTR(ALLTRIM(cLOTEVIF),20,01) <>' '
		cTIPE :='N'
		cTIT  :='Mensagem'
		cMEN1 :='Erro no codigo de barra, Quantidade '+cPECA+ ' PCs '
		cMEN2 :='Verique a etiqueta e faça a leitura novamente.   '
		cMEN3 :=''
		cMEN4 :=''
		nP1   :=135
		nP2   :=0
		nP3   :=300
		nP4   :=700

		U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

		//IF lEXPALERT ==.F.
		oGetDados:aCOLS[n][P1_LOTEVIF] := PadR('', TamSX3('Z6_LOTEVIF')[1])
		Return("")
		//ENDIF
	ENDIF

	IF EMPTY(oGetDados:aCOLS[n][P1_LOTE])
		nSALDO := _QTDEP
	ELSE
		nSALDO := _QTDEP -_QTDED
	ENDIF

	cQry:= " SELECT * FROM "+RetSqlName("SA5")+" A5 "
	//cQry+= " WHERE A5_FILIAL = '"+xFilial("SA5")+"' AND A5_CODPRF LIKE '%"+cProduto+"'"
	//cQry+= " WHERE A5_FILIAL = '"+xFilial("SA5")+"' AND A5_CODPRF = '"+cProduto+"'"
	cQry+= " WHERE A5_FILIAL = '  ' AND CAST (CAST (A5_CODPRF AS int) AS varchar) = '"+cProduto+"'"
	cQry+= " AND A5_FORNECE IN " + FormatIn(cFornece,";")
	cQry+= " AND D_E_L_E_T_ = ' ' "

	If SELECT(cAlias)>0
		dbSelectArea(cAlias)
		dbCloseArea()
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry), cAlias, .F., .T. )

	If !(cAlias)->(Eof())

		cPRODUTO := AllTrim((cAlias)->A5_PRODUTO)

	EndIf

	(cAlias)->(dbCloseArea())

	SB1->(DBSELECTAREA('SB1'))
	SB1->(DBSETORDER(1))


	nQE  := nPECA // QUANTIDADE NO CODIGO DE BARRAS


	IF SB1->(DBSEEK(xFILIAL('SB1')+cPRODUTO))
		//	nQE     := SB1->B1_QE
		//	nPSMIN  := (SB1->B1_PESOMIN)*(SB1->B1_QE)
		//	nPSMAX  := (SB1->B1_PESOMAX)*(SB1->B1_QE)

		nPSMIN  := (SB1->B1_PESOMIN)* nPECA
		nPSMAX  := (SB1->B1_PESOMAX)* nPECA

		cTPDESP := SB1->B1_TPDESP
		_DESCP  := SB1->B1_DESC
	ELSE
		//	nQE  := 1
		nPSMIN  := 0
		nPSMAX  := 0
		cTPDESP := SPACE(15)
		_DESCP  := SPACE(15)
	ENDIF

	IF ALLTRIM(oGetDados:ACOLS[n][P1_PRODUTO]) <> ALLTRIM(cPRODUTO)
		//	MSGALERT('Produto diferente do Pedido')
		//	Return("")
		cTIPE :='N'
		cTIT  :='Mensagem'
		cMEN1 :='Produto diferente do Pedido'
		cMEN2 :=''
		cMEN3 :=''
		cMEN4 :=''
		nP1   :=135
		nP2   :=0
		nP3   :=300
		nP4   :=700

		U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.


		//IF lEXPALERT ==.F.
		oGetDados:aCOLS[n][P1_LOTEVIF] := PadR('', TamSX3('Z6_LOTEVIF')[1])
		Return("")
		//ENDIF
	ENDIF

	// RETIRADO 26/03/2010 NOVA ETIQUETA JA VEM COM QUANTIDADE
	//1a chamada
	IF nPESO < nPSMIN
		//	IF !MSGYESNO('Peso minimo do cadastro '+LTRIM(TransForm(nPSMIN,'@E 999,999,999.999')) + ' ' +Chr(13)+Chr(10)+;
			//		'Peso da Etiqueta        '+LTRIM(TransForm(nPESO ,'@E 999,999,999.999')) +' Confirma  ?')
		//		Return("")
		//	ENDIF
		cTIPE :='N'
		cTIT  :='Mensagem 1/2'
		cMEN1 :='Peso minimo do cadastro '+LTRIM(TransForm(nPSMIN,'@E 999,999,999.999')) +' para '+LTRIM(TransForm(nQE ,'@E 999,999,999.999')) +' Pcs '
		cMEN2 :='Peso da Etiqueta        '+LTRIM(TransForm(nPESO ,'@E 999,999,999.999')) +' para '+LTRIM(TransForm(nQE ,'@E 999,999,999.999')) +' Pcs Confirma  ?'
		cMEN3 :=''//Quantidade '+LTRIM(TransForm(nQE ,'@E 999,999,999.999')) +' Pcs por Embalagem '
		cMEN4 :='DIFERENÇA    '+LTRIM(TransForm(nPESO-nPSMIN,'@E 999,999,999.999')) + ' Kg'
		nP1   :=135
		nP2   :=0
		nP3   :=400
		nP4   :=600

		U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

		IF lEXPALERT ==.F.
			oGetDados:aCOLS[n][P1_LOTEVIF] := PadR('', TamSX3('Z6_LOTEVIF')[1])
			Return("")
		ENDIF
	ENDIF

	//2a chamada
	IF nPESO < nPSMIN
		//	IF !MSGYESNO('Peso minimo do cadastro '+LTRIM(TransForm(nPSMIN,'@E 999,999,999.999')) + ' ' +Chr(13)+Chr(10)+;
			//		'Peso da Etiqueta        '+LTRIM(TransForm(nPESO ,'@E 999,999,999.999')) +' Confirma  ?')
		//		Return("")
		//	ENDIF
		cTIPE :='N'
		cTIT  :='Mensagem 2/2'
		cMEN1 :='Peso minimo do cadastro '+LTRIM(TransForm(nPSMIN,'@E 999,999,999.999')) +' para '+LTRIM(TransForm(nQE ,'@E 999,999,999.999')) +' Pcs '
		cMEN2 :='Peso da Etiqueta        '+LTRIM(TransForm(nPESO ,'@E 999,999,999.999')) +' para '+LTRIM(TransForm(nQE ,'@E 999,999,999.999')) +' Pcs Confirma  ?'
		cMEN3 :=''//Quantidade '+LTRIM(TransForm(nQE ,'@E 999,999,999.999')) +' Pcs por Embalagem '
		cMEN4 :='DIFERENÇA    '+LTRIM(TransForm(nPESO-nPSMIN,'@E 999,999,999.999')) + ' Kg'
		nP1   :=135
		nP2   :=0
		nP3   :=400
		nP4   :=600

		U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

		IF lEXPALERT ==.F.
			oGetDados:aCOLS[n][P1_LOTEVIF] := PadR('', TamSX3('Z6_LOTEVIF')[1])
			Return("")
		ENDIF
	ENDIF

	//1achamada
	IF nPESO > nPSMAX
		//	IF !MSGYESNO('Peso Maximo do cadastro '+LTRIM(TransForm(nPSMAX,'@E 999,999,999.999')) + ' ' +Chr(13)+Chr(10)+;
			//		'Peso da Etiqueta        '+LTRIM(TransForm(nPESO ,'@E 999,999,999.999')) +' Confirma  ?')
		//		Return("")
		//	ENDIF
		cTIPE :='N'
		cTIT  :='Mensagem 1/2'
		cMEN1 :='Peso maximo do cadastro '+LTRIM(TransForm(nPSMIN,'@E 999,999,999.999')) +' para '+LTRIM(TransForm(nQE ,'@E 999,999,999.999')) +' Pcs '
		cMEN2 :='Peso da Etiqueta        '+LTRIM(TransForm(nPESO ,'@E 999,999,999.999')) +' para '+LTRIM(TransForm(nQE ,'@E 999,999,999.999')) +' Pcs Confirma  ?'
		cMEN3 :=''//Quantidade '+LTRIM(TransForm(nQE ,'@E 999,999,999.999')) +' Pcs por Embalagem '
		cMEN4 :='DIFERENÇA    '+LTRIM(TransForm(nPESO-nPSMAX,'@E 999,999,999.999')) + ' Kg '
		nP1   :=135
		nP2   :=0
		nP3   :=400
		nP4   :=600

		U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

		IF lEXPALERT ==.F.
			oGetDados:aCOLS[n][P1_LOTEVIF] := PadR('', TamSX3('Z6_LOTEVIF')[1])
			Return("")
		ENDIF
	ENDIF

	//2achamada
	IF nPESO > nPSMAX
		//	IF !MSGYESNO('Peso Maximo do cadastro '+LTRIM(TransForm(nPSMAX,'@E 999,999,999.999')) + ' ' +Chr(13)+Chr(10)+;
			//		'Peso da Etiqueta        '+LTRIM(TransForm(nPESO ,'@E 999,999,999.999')) +' Confirma  ?')
		//		Return("")
		//	ENDIF
		cTIPE :='N'
		cTIT  :='Mensagem 2/2'
		cMEN1 :='Peso maximo do cadastro '+LTRIM(TransForm(nPSMIN,'@E 999,999,999.999')) +' para '+LTRIM(TransForm(nQE ,'@E 999,999,999.999')) +' Pcs '
		cMEN2 :='Peso da Etiqueta        '+LTRIM(TransForm(nPESO ,'@E 999,999,999.999')) +' para '+LTRIM(TransForm(nQE ,'@E 999,999,999.999')) +' Pcs Confirma  ?'
		cMEN3 :=''//Quantidade '+LTRIM(TransForm(nQE ,'@E 999,999,999.999')) +' Pcs por Embalagem '
		cMEN4 :='DIFERENÇA    '+LTRIM(TransForm(nPESO-nPSMAX,'@E 999,999,999.999')) + ' Kg '
		nP1   :=135
		nP2   :=0
		nP3   :=400
		nP4   :=600

		U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

		IF lEXPALERT ==.F.
			oGetDados:aCOLS[n][P1_LOTEVIF] := PadR('', TamSX3('Z6_LOTEVIF')[1])
			Return("")
		ENDIF
	ENDIF

	If oGetDados:ACOLS[n][P1_VOLUME] + nPECA > _QTDEP
		cTIPE :='N'
		cTIT  :='Mensagem'
		cMEN1 :='Quantidade de volumes maior que a quantidade do Pedido.'
		cMEN2 :='Verique a etiqueta e faça a leitura novamente.'
		cMEN3 :='Qtde do Pedido: ' + cValToChar( _QTDEP ) + ' PCS.'
		cMEN4 :='Qtde Bipada: ' + cValToChar( oGetDados:ACOLS[n][P1_VOLUME] + nPECA ) + ' PCS.'
		nP1   :=135
		nP2   :=0
		nP3   :=400
		nP4   :=700

		U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

		IF lEXPALERT
			If !fDigSenha()
				oGetDados:aCOLS[n][P1_LOTEVIF] := PadR('', TamSX3('Z6_LOTEVIF')[1])
				Return("")

			Endif

		Else
			oGetDados:aCOLS[n][P1_LOTEVIF] := PadR('', TamSX3('Z6_LOTEVIF')[1])
			Return("")

		Endif

	ElseIf oGetDados:ACOLS[n][P1_VOLUME] + nPECA == _QTDEP
		nPedPSMin := SB1->B1_PESOMIN * _QTDEP
		nPedPSMax := SB1->B1_PESOMAX * _QTDEP

		If (_PESOD + nPESO < nPedPSMin) .OR. (_PESOD + nPESO > nPedPSMax)
			cTIPE :='N'
			cTIT  :='Mensagem'
			cMEN1 :='Peso despachado (' + cValToChar(_PESOD + nPESO) + ') fora do intervalo permitido.'
			cMEN2 :='Verique a etiqueta e faça a leitura novamente.'
			cMEN3 :='Peso Mínimo: ' + cValToChar( nPedPSMin ) + ' KGs.'
			cMEN4 :='Peso Máximo: ' + cValToChar( nPedPSMax ) + ' KGs.'
			nP1   :=135
			nP2   :=0
			nP3   :=400
			nP4   :=700

			U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

			IF lEXPALERT
				If !fDigSenha()
					oGetDados:aCOLS[n][P1_LOTEVIF] := PadR('', TamSX3('Z6_LOTEVIF')[1])
					Return("")
				Endif
			Else
				oGetDados:aCOLS[n][P1_LOTEVIF] := PadR('', TamSX3('Z6_LOTEVIF')[1])
				Return("")
			Endif
		Endif

	Endif

	//Validação NT
	IF SUBSTR(oGetDados:aCOLS[n][P1_IDCLIE],1,6)+SUBSTR(oGetDados:aCOLS[n][P1_IDCLIE],8,2)  == ALLTRIM(cCliCFGru)
		cMEN1 := ValidZ24(cPRODUTO,cNCS,cLOTE,nPESO,nPECA)

		If ALLTRIM(cMEN1) <> ""
			cTIPE :='N'
			cTIT  :='Mensagem 1/1'
			//cMEN1 :=''
			cMEN2 :='Produto: '+ALLTRIM(cPRODUTO)+' '
			cMEN3 :='Linha: '+str(n)+''//Quantidade '+LTRIM(TransForm(nQE ,'@E 999,999,999.999')) +' Pcs por Embalagem '
			cMEN4 :=''
			nP1   :=135
			nP2   :=0
			nP3   :=400
			nP4   :=600

			U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

			lEXPALERT :=.F.

			IF lEXPALERT ==.F.
				oGetDados:aCOLS[n][P1_LOTEVIF] := PadR('', TamSX3('Z6_LOTEVIF')[1])
				Return("")
			ENDIF
		ENDIF
	ENDIF

	nQtde     := 0
	nTOTL     := 0
	nTOTLTMP  := 0

	SZ7->(DBSELECTAREA('SZ7'))
	SZ7->(DBSETORDER(1))
	SZ7->(DBSEEK(xFILIAL('SZ7')+cLOTEVIF))

	IF SZ7->(FOUND()) .AND. !EMPTY(cLOTEVIF)
		//	MSGALERT('Codigo de Barra '+cLOTEVIF+ ' Já despachado ' +Chr(13)+Chr(10)+;
			//	'Selecionar outro código de barra ')
		//	Return("")
		cTIPE :='N'
		cTIT  :='Mensagem'
		cMEN1 :='Codigo de Barra '+cLOTEVIF+ ' Já despachado '
		cMEN2 :='Selecionar outro código de barra '
		cMEN3 :=''
		cMEN4 :=''
		nP1   :=135
		nP2   :=0
		nP3   :=300
		nP4   :=700

		U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

		//IF lEXPALERT ==.F.
		oGetDados:aCOLS[n][P1_LOTEVIF] := PadR('', TamSX3('Z6_LOTEVIF')[1])
		Return("")
		//ENDIF

	ENDIF
	nQtde:= nQE

	IF cTPDESP=='2'

		_DESCP   :=POSICIONE('SB1',1,xFILIAL('SB1')+cPRODUTO+SPACE(12),'B1_DESC')

		_PRODUTO :=cPRODUTO+'-'+_DESCP
		_PLOTE   :=nPESO
		_PREAL   := 0
		_LOOP    :=.T.
		_nOPC1   :=2

		DO WHILE _LOOP
			DEFINE MSDIALOG oDlg2 FROM 0,0 TO 200,400 TITLE OemToAnsi("Item a Granel") OF oMainWnd PIXEL

			nLin:=18
			@ nLin,10 SAY OemToAnsi("ITEM A GRANEL") OF oDlg2 PIXEL COLOR CLR_RED  FONT oFontBRW SIZE 120,010
			nLin := nLin+18
			@ nLin,10 SAY OemToAnsi("Produto ")      OF oDlg2 PIXEL SIZE 040,010 FONT oFontBRW3
			@ nLin,50 MSGET _PRODUTO   WHEN(.F.)     OF oDlg2 PIXEL SIZE 130,005 FONT oFontBRW3
			nLin := nLin+12
			@ nLin,10 SAY OemToAnsi("Peso Lote")     OF oDlg2 PIXEL SIZE 040,010 FONT oFontBRW3
			@ nLin,50 MSGET  _PLOTE    WHEN(.F.)     PICTURE "@E 999,999.999" OF oDlg2 PIXEL SIZE 060,005 FONT oFontBRW3
			nLin := nLin+12
			@ nLin,10 SAY OemToAnsi("PESO REAL")     OF oDlg2 PIXEL SIZE 040,010 COLOR CLR_RED  FONT oFontBRW3
			@ nLin,50 MSGET _PREAL     WHEN(.T.)     PICTURE "@E 999,999.999"  OF oDlg2 PIXEL SIZE 060,005 COLOR CLR_RED  FONT oFontBRW3

			DEFINE SBUTTON FROM 080, 010 TYPE 1 ACTION (_nOPC1 := 1,oDlg2:End()) ENABLE OF oDlg2
			ACTIVATE MSDIALOG  oDlg2 ON INIT EnchoiceBar(oDlg2,{||_nOPC1:=1,oDlg2:End() },{||_NOPC1:=2,oDlg2:End() }) CENTERED

			IF _nOPC1==1
				IF _PREAL <=0
					MSGALERT('Peso Real nao pode ser Zero ' +Chr(13)+Chr(10)+;
						'Preencha o Peso Real do produto ')
					_LOOP :=.T.
				ELSE
					_LOOP :=.F.
					nPESO :=_PREAL
				ENDIF
			ENDIF
			IF _nOPC1==2
				_LOOP :=.T.
				oGetDados:aCOLS[n][P1_LOTEVIF] := PadR('', TamSX3('Z6_LOTEVIF')[1])
				Return("")
			ENDIF
		ENDDO

	ENDIF

	nTOTLTMP  :=nTOTL
	nTOTL     :=nTOTL+nPESO

	nTOTL   := oGetDados:aCOLS[n][P1_PESOD]  + nPESO
	nVOLUME := oGetDados:aCOLS[n][P1_VOLUME] + nQtde

	DO CASE
	CASE oGetDados:aCOLS[n][P1_QTDEP]==0 .AND. oGetDados:aCOLS[n][P1_PESOP]<>0
		IF nTOTL >(oGetDados:aCOLS[n][P1_PESOP])
			/*  RETIRADO EM 17/09/2008 POR EDSON
			IF !MSGYESNO('Peso total maior que peso do pedido ' +Chr(13)+Chr(10)+;
			'Peso Pedido  : ' +LTRIM(TransForm(aCOLS[n][P1_PESOP]       ,'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
			'Peso Produto : ' +LTRIM(TransForm(nTOTL             ,'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
			'Diferença    : ' +LTRIM(TransForm(nTOTL -aCOLS[n][P1_PESOP],'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
			'Aceita ?' )
			nTOTL := nTOTLTMP
			Return("")
				ENDIF
			*/
		ENDIF

	CASE oGetDados:aCOLS[n][P1_QTDEP]<>0 .AND. oGetDados:aCOLS[n][P1_PESOP]==0

		IF EMPTY(oGetDados:aCOLS[n][P1_LOTE]) // LOTE
			nITEM :=1
		ELSE
			nITEM :=oGetDados:aCOLS[n][P1_QTDED]+nQTDE
		ENDIF

		IF nITEM >(oGetDados:aCOLS[n][P1_QTDEP])
			IF !MSGYESNO('Quantidade total maior que quantidade do pedido ' +Chr(13)+Chr(10)+;
					'Qtde Pedido   : ' +LTRIM(TransForm(aCOLS[n][P1_QTDEP]       ,'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
					'Qtde Despacho : ' +LTRIM(TransForm(nITEM             ,'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
					'Diferença    : ' +LTRIM(TransForm(nITEM -aCOLS[n][P1_QTDEP],'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
					'Aceita ?' )
				nTOTL := nTOTLTMP
				oGetDados:aCOLS[n][P1_LOTEVIF] := PadR('', TamSX3('Z6_LOTEVIF')[1])
				Return("")
			ENDIF
		ENDIF

	OTHERWISE

		IF EMPTY(oGetDados:aCOLS[n][P1_LOTE]) // LOTE
			nITEM :=1
		ELSE
			nITEM :=oGetDados:aCOLS[n][P1_QTDED]+nQTDE
		ENDIF

		IF nITEM >(oGetDados:aCOLS[n][P1_QTDEP])
			IF !MSGYESNO('Quantidade total maior que quantidade do pedido ' +Chr(13)+Chr(10)+;
					'Qtde Pedido   : ' +LTRIM(TransForm(aCOLS[n][P1_QTDEP]       ,'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
					'Qtde Despacho : ' +LTRIM(TransForm(nITEM             ,'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
					'Diferença    : ' +LTRIM(TransForm(nITEM -aCOLS[n][P1_QTDEP],'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
					'Aceita ?' )
				nTOTL := nTOTLTMP
				oGetDados:aCOLS[n][P1_LOTEVIF] := PadR('', TamSX3('Z6_LOTEVIF')[1])
				Return("")
			ENDIF
		ELSE
			IF nTOTL >(oGetDados:aCOLS[n][P1_PESOP])   //
				/*  RETIRADO EM 17
				/09/2008 POR EDSON
				IF !MSGYESNO('Peso total maior que peso do pedido ' +Chr(13)+Chr(10)+;
				'Peso Pedido  : ' +LTRIM(TransForm(aCOLS[n][P1_PESOP]       ,'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
				'Peso Produto : ' +LTRIM(TransForm(nTOTL             ,'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
				'Diferença    : ' +LTRIM(TransForm(nTOTL -aCOLS[n][P1_PESOP],'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
				'Aceita ?' )
				nTOTL := nTOTLTMP
				Return("")
					ENDIF
				*/
			ENDIF
		ENDIF

	ENDCASE
	//ValidZ24(cPRODUTO,cNCS,cLOTE,nPESO,nPECA)
	GravaZ24(cPRODUTO,cCodBar,cLOTE,oGetDados:aCOLS[n][P1_PEDIDO],nPESO,nPECA,.F.)
	// If (nTOTL >= oGetDados:ACOLS[n][P1_PESOP]) .AND. (nVOLUME >= oGetDados:ACOLS[n][P1_QTDEP])
	//If (nTOTL >= nPSMIN ) .AND. ( nVOLUME >= oGetDados:ACOLS[n][P1_QTDEP] )
	oGetDados:ACOLS[n][P1_DELETE] :=.T.
	//Endif

	oTOTL:REFRESH()
	oGetDados:aCOLS[n][P1_PESOD]  := nTOTL
	oGetDados:aCOLS[n][P1_LOTE]   := cNCS
	oGetDados:aCOLS[n][P1_VOLUME] := nVOLUME
	oGetDados:aCOLS[n][P1_LOTEVIF] := PadR('', TamSX3('Z6_LOTEVIF')[1])
	nLSEQ  :=nLSEQ+1

	AADD(aCOLSLote,{cCodBar			,;
		cPRODUTO		,;
		cLOTE			,;
		cVALIDADE		,;
		nQtde			,;
		nPESO			,;
		cNCS			,;
		nLSEQ			,;
		.F.				})//.f. POSICAO 9 Flag de Delecao]

	AADD(aCOLSLT,{	cCodBar  								,;
		cPRODUTO 								,;
		cLOTE    								,;
		cVALIDADE								,;
		nQtde    								,;
		nPESO    								,;
		oGetDados:aCOLS[n][P1_PEDIDO] 		,; //pedido
	oGetDados:aCOLS[n][P1_IDCLIE] 		,; //idclie
	oGetDados:aCOLS[n][P1_PRODUTO]		,; //produto
	cNCS 									,;
		nLSEQ									,;
		oGetDados:aCOLS[n][P1_ITEM] 	,;
		.F.										}) //.f. POSICAO 13 Flag de Delecao]

	aCOLSLote2 := AClone( aCOLSLote )
	oMLOTE1:aCOLS := AClone( aCOLSLote2 )

	oMLOTE1:oBrowse:Refresh()
	aCols := AClone( oGetDados:aCOLS )//PAULO-210819
	oGetDados:oBrowse:Refresh()
	U_FAT002LOK(oGetDados)

//IF _QTDEP >= 10
//  LER_LOTE(oGetDados)  //F12 AUTOMATICO PARA ITEM COM + DE 10 PEÇAS
//ENDIF

Return(" ")


	*----------------------------------------------------------------------------*
STATIC FUNCTION FATFIN()
	*----------------------------------------------------------------------------*
	local lRet :=.F.
	IF MSGYESNO('Finaliza Despacho ?')
		IF MSGNOYES('CANCELAR e SAIR deste Despacho ?','Atenção')
			lRet :=.T.
			oDlg:End()
		ENDIF
	ENDIF

RETURN(lRET)

	*----------------------------------------------------------------------------*
USER FUNCTION FAT002LOK(oGetDados)
	*----------------------------------------------------------------------------*

	LOCAL nLIN :=oGetDados:nat
	Local nX	:=0
	if lfirst2 == .F. .AND. Len( oGetDados:Acols ) > 0
		cCODCLI   := SUBSTR(oGetDados:aCOLS[nLin][P1_IDCLIE],1,6)
		clojcli   := SUBSTR(oGetDados:aCOLS[nLin][P1_IDCLIE],8,2)
		cCOD      := SUBSTR(oGetDados:aCOLS[nLin][P1_PRODUTO],1,15)
		cPROD     := ALLTRIM(oGetDados:aCOLS[nLin][P1_PRODUTO])+"  "+ALLTRIM(POSICIONE('SB1',1,xFILIAL('SB1')+cCOD   ,'B1_DESC')) +' NF- '+ POSICIONE('SZ5',1,xFILIAL('SZ5')+oGetDados:aCOLS[nLin][P1_PEDIDO]    ,'Z5_NOTA')+'/'+POSICIONE('SZ5',1,xFILIAL('SZ5')+oGetDados:aCOLS[nLin][P1_PEDIDO]    ,'Z5_SERIE')
		cCLIE     := ALLTRIM(oGetDados:aCOLS[nLin][P1_IDCLIE])+"  "+ALLTRIM(POSICIONE('SA1',1,xFILIAL('SA1')+cCODCLI+cLOJCLI,'A1_NOME'))
		cENDR     := ALLTRIM(POSICIONE('SZ5',1,xFILIAL('SZ5')+oGetDados:aCOLS[nLin][P1_PEDIDO]    ,'Z5_CIDADE'))+" - "+ALLTRIM(POSICIONE('SZ5',1,xFILIAL('SZ5')+oGetDados:aCOLS[nLin][P1_PEDIDO]    ,'Z5_END'))
		cPedven   := ALLTRIM(oGetDados:aCOLS[nLin][P1_PEDIDO])
		cDESCI    := ALLTRIM(POSICIONE('SZ5',1,xFILIAL('SZ5')+oGetDados:aCOLS[nLin][P1_PEDIDO]    ,'Z5_MENNOTA'))
		cDESC2    := cDESCI

		aCOLS2 := AClone( oGetDados:ACOLS )
		nTOT   := 0
		nTOTVOL:= 0
		nTOT2  := 0
		FOR nX := 1 TO LEN(aCOLS2)
			nTOT := nTOT + ACOLS2[nX][P1_PESOD]
			nTOTVOL:=nTOTVOL+ACOLS2[nX][P1_VOLUME]
			nTOT2 :=nTOT
		NEXT

		oTOT:REFRESH()
		oTOTVOL:REFRESH()
		oTOT2:REFRESH()
		oPROD:REFRESH()
		oCLIE:REFRESH()
		oENDR:REFRESH()
		oPedven:REFRESH()
		oDESCI:REFRESH()
		oDESC2:REFRESH()
	endif
	lfirst2 :=.f.
	U_MLOTE1LOK(oGetDados)

RETURN(.t.)

	*----------------------------------------------------------------------------*
USER FUNCTION MLOTE1LOK(oGetDados)
	*----------------------------------------------------------------------------*
	local nX
	LOCAL nLIN :=oGetDados:nat

	aCOLSLote2 := {}
	aCOLSLote  := {}
	nTOTL      := 0
	nITEM      := 0
	nTOTVOL    := 0

	//oGetDados:aCOLS[nLin][Len(oGetDados:aCOLS[nLin])] := .F.

	For nX :=1 to len(aColsLT)

		IF  aCOLSLT[nX][P2_PEDIDO]   == oGetDados:aCOLS[nLin][P1_PEDIDO]   .AND. ;    //pedido
			aCOLSLT[nX][P2_ITEM]     == oGetDados:aCOLS[nLin][P1_ITEM]     .AND. ;    //ITEMPVidclie
			aCOLSLT[nX][P2_IDCLIE]   == oGetDados:aCOLS[nLin][P1_IDCLIE]   .AND. ;    //idclie
			aCOLSLT[nX][P2_PRODUTO2] == oGetDados:aCOLS[nLin][P1_PRODUTO]             //produto

			IF aCOLSLT[nX][P2_DELETE]   ==.F.
				AADD(aCOLSLote,{aCOLSLT[nX][P2_CODBAR]					,;
					aCOLSLT[nX][P2_PRODUTO]					,;
					aCOLSLT[nX][P2_LOTE]						,;
					aCOLSLT[nX][P2_VALID]					,;
					aCOLSLT[nX][P2_QTDE]						,;
					aCOLSLT[nX][P2_PESO]						,;
					SUBSTR(aCOLSLT[nX][P2_CODBAR],11,6)		,;			//SUBSTR(aCOLSLT[nX][P2_CODBAR],8,6)		,;
					aCOLSLT[nX][P2_NSEQ] 					,;
					.F.												})  //.f. POSICAO 8Flag de Delecao]

				nTOTL   := nTOTL   + aCOLSLT[nX][P2_PESO]
				nITEM   := nITEM   + aCOLSLT[nX][P2_QTDE]
				nTOTVOL := nTOTVOL + aCOLSLT[nX][P2_QTDE]

				oGetDados:aCOLS[nLin][P1_QTDED]  := nITEM
				oGetDados:aCOLS[nLin][P1_PESOD]  := nTOTL
				oGetDados:aCOLS[nLin][P1_VOLUME] := nTOTVOL
				oGetDados:aCOLS[nLin][P1_LOTE]   := SUBSTR(aCOLSLT[nX][P2_CODBAR],11,6)		//SUBSTR(aCOLSLT[nX][P2_CODBAR],8,6)

				// If oGetDados:aCOLS[nLin][P1_PESOD] >= oGetDados:aCOLS[nLin][P1_PESOP] .OR.;
					// 	oGetDados:aCOLS[nLin][P1_VOLUME] >= oGetDados:aCOLS[nLin][P1_QTDEP]
				// 	oGetDados:aCOLS[nLin][P1_DELETE] := .T.
				// Endif
			else
				//---------------------------
				AADD(aCOLSLote,{aCOLSLT[nX][P2_CODBAR] 		,;
					aCOLSLT[nX][P2_PRODUTO] 		,;
					aCOLSLT[nX][P2_LOTE] 		,;
					aCOLSLT[nX][P2_VALID] 		,;
					aCOLSLT[nX][P2_QTDE] 		,;
					aCOLSLT[nX][P2_PESO] 		,;
					aCOLSLT[nX][P2_NCS]			,;
					aCOLSLT[nX][P2_NSEQ]			,;
					.T.					})  //.f. POSICAO 8Flag de Delecao]
				//----------------------------
			ENDIF
		ENDIF

	Next
	oTOTL:REFRESH()

	aCOLS := AClone( oGetDados:aCols )
	aCOLSLote2 := AClone( aCOLSLote )
	oMLOTE1:aCOLS := AClone( aCOLSLote2 )
	oMLOTE1:oBrowse:Refresh()
	//oGetDados:oBrowse:Refresh()
	U_FATGRV1(oGetDados,'1')//TESTE PAULO 17.08.2021.

RETURN

	*----------------------------------------------------------------------------*
USER FUNCTION NTRSP01A(lTela)
	*----------------------------------------------------------------------------*
	LOCAL cA4LOC :=''
	LOCAL lRET   :=.T.

	Default lTela := .T.

	U_REGTRANSP()

	cNTRANSP :=POSICIONE('SA4',1,xFILIAL('SA4')+cTRANSP ,'A4_NOME')
	cA4LOC   :=POSICIONE('SA4',1,xFILIAL('SA4')+cTRANSP ,'A4_LOCAL')
	IF SUBSTR(cA4LOC,1,1)$('1|2')
		lRET   :=.T.
	ELSE
		MSGALERT('MSG 000003 - Transportadora nao Consta no arquivo de Despacho','Mensagem')
		cNTRANSP2 :=Space(30)
		cNTRANSP3 :=Space(30)

		cTRANSP  :=Space(06)
		cTRANSP2 :=Space(06)
		cTRANSP3 :=Space(06)

		oNTRANPA:REFRESH()
		oNTRANSP:REFRESH()
		oNTRANSP1:REFRESH()
		oNTRANSP2:REFRESH()
		oNTRANSP3:REFRESH()
		oNTRANENT:REFRESH()
		FAT002D()
		lRET   :=.F.
	ENDIF
	cNTRANSP2 :=cNTRANSP
	cNTRANSP3 :=cNTRANSP

	cTRANSP2  :=cTRANSP
	cTRANSP3  :=cTRANSP

	cPLACA2   :=UPPER(POSICIONE('SA4',1,xFILIAL('SA4')+cTRANSP ,'A4_PLACA'))
	cPLACA3   :=UPPER(POSICIONE('SA4',1,xFILIAL('SA4')+cTRANSP ,'A4_PLACA'))

	If lTela
		oPLACA2   :REFRESH()
		oPLACA3   :REFRESH()

		oNTRANSP  :REFRESH()
		oNTRANSP2 :REFRESH()
		oNTRANSP3 :REFRESH()
	EndIf
	FAT002B()
	//U_FAT002LOK(oGetDados) //Atualiza cores.//PAULO210406
RETURN lRET

	*----------------------------------------------------------------------------*
USER FUNCTION NTRSP02A()
	*----------------------------------------------------------------------------*
	LOCAL lRET   :=.T.
	cNTRANSP2 :=POSICIONE('SA4',1,xFILIAL('SA4')+cTRANSP2,'A4_NOME')
	cPLACA2   :=POSICIONE('SA4',1,xFILIAL('SA4')+cTRANSP2,'A4_PLACA')
	oPLACA2   :REFRESH()
	oNTRANSP2 :REFRESH()
RETURN lRET

	*----------------------------------------------------------------------------*
USER FUNCTION MLOTE1DEL(oMLOTE1,oGetDados)    //mls lote
	*----------------------------------------------------------------------------*
	local nX
	LOCAL nLIN  := oGetDados:nat
	aCOLSLote2  := {}
	aCOLSLote   := {}
	nTOTL       := 0
	nITEM       := 0
	nTOTVOL     := 0

	oGetDados:aCOLS[nLin][P1_QTDED]  := nITEM
	oGetDados:aCOLS[nLin][P1_PESOD]  := nTOTL
	oGetDados:aCOLS[nLin][P1_VOLUME] := nTOTVOL

	IF LEN(oMLOTE1:aCols) > 0
		For nX := 1 TO LEN(oMLOTE1:aCols)
			nPsLOTE    := aScan(aCOLSLT,{|x| x[P2_NSEQ]==oMLOTE1:aCOLS[nX][P3_LSEQ]})
			DO CASE
			CASE oMLOTE1:aCols[nX][P3_DELETE]==.T. .AND.  aCOLSLT[nPsLOTE][P2_DELETE] == .F.
				aCOLSLT[nPsLOTE][P2_DELETE]      := .T.
				If oGetDados:aCOLS[nLin][P1_QTDEP] == oMLOTE1:aCOLS[nX][P3_QTDE]
					oGetDados:aCOLS[nLin][P1_DELETE] := .F.
				Endif
			CASE oMLOTE1:aCols[nX][P3_DELETE] ==.F. .AND.  aCOLSLT[nPsLOTE][P2_DELETE]  ==.F.
				nTOTL   := nTOTL+oMLOTE1:aCOLS[nX][P3_PESO]
				nITEM   := nITEM+oMLOTE1:aCOLS[nX][P3_QTDE]
				nTOTVOL := nTOTVOL+oMLOTE1:aCOLS[nX][P3_QTDE]
				oGetDados:aCOLS[nLin][P1_QTDED]  := nITEM
				oGetDados:aCOLS[nLin][P1_PESOD]  := nTOTL
				oGetDados:aCOLS[nLin][P1_VOLUME] := nTOTVOL
				// oGetDados:aCOLS[nLin][P1_DELETE] := .F.
				// If nTOTL >= oGetDados:aCOLS[nLin][P1_PESOP] .OR. nITEM >= oGetDados:aCOLS[nLin][P1_QTDEP]
				If nTOTL >= 0
					oGetDados:aCOLS[nLin][P1_DELETE] := .T.
				Endif
				nPsLOTE    := aScan(aCOLSLT,{|x| x[P2_NSEQ]==oMLOTE1:aCOLS[nX][P3_LSEQ]})
				aCOLSLT[nPsLOTE][P2_QTDE]:=oMLOTE1:aCOLS[nX][P3_QTDE]
			CASE oMLOTE1:aCols[nX][P3_DELETE]==.F. .AND.  aCOLSLT[nPsLOTE][P2_DELETE]  ==.T.
				MSGALERT('Lote já Deletado')
				oMLOTE1:aCols[nX][P3_DELETE]:=.T.
			ENDCASE
		NEXT
	ELSE
		nTOTL   := 0
		nITEM   := 0
		nTOTVOL := 0
		oGetDados:aCOLS[nLin][P1_QTDED]  := nITEM
		oGetDados:aCOLS[nLin][P1_PESOD]  := nTOTL
		oGetDados:aCOLS[nLin][P1_VOLUME] := nTOTVOL
		oGetDados:aCOLS[nLin][P1_LOTE]   := ""
		oGetDados:aCOLS[nLin][Len( oGetDados:aCOLS[nLin] )] := .F.

	ENDIF

	IF oGetDados:aCOLS[nLin][P1_PESOD] == 0
		oGetDados:aCOLS[nLin][P1_VOLUME] := 0
		oGetDados:aCOLS[nLin][P1_LOTE]   := ""
		oGetDados:aCOLS[nLin][Len( oGetDados:aCOLS[nLin] )] := .F.
	ENDIF

	aCOLS := AClone( aCOLS )
	oTOTL:REFRESH()
	oGetDados:oBrowse:Refresh()
	U_FAT002LOK(oGetDados)
	LOTECLR(oGetDados:aCols,nLin,aHeader)
	//oGetDados:ForceRefresh()

RETURN

	*----------------------------------------------------------------------------*
USER FUNCTION FATGRV1(oGetDados,cTIPOGRV)
	*------------------------------------*
	LOCAL nLIN 	:=oGetDados:nat
	Local nX	:= 1
	Local lDel	:=.F.
	IF Len( oGetDados:Acols ) > 0 .AND. !empty(oGetDados:aCOLS[1][P1_PEDIDO])
		SZ5->(DBSELECTAREA('SZ5'))
		SZ5->(DBSETORDER(1))//NUMERO

		SZ6->(DBSELECTAREA('SZ6'))
		SZ6->(DBSETORDER(3))//NUMERO+CLIENTE+LOJA+PRODUTO

		SZ6->(DBSEEK(xFILIAL('SZ6')+oGetDados:aCOLS[nLin][P1_PEDIDO]+SUBSTR(oGetDados:aCOLS[nLin][P1_IDCLIE],1,6)+SUBSTR(oGetDados:aCOLS[nLin][P1_IDCLIE],8,2)+oGetDados:aCOLS[nLin][P1_PRODUTO]))
		IF SZ6->(FOUND())
			DO WHILE .NOT. SZ6->(EOF()) .AND.  SZ6->Z6_FILIAL==xFILIAL('SZ6') .AND.;
					SZ6->Z6_NUM     == oGetDados:aCOLS[nLin][P1_PEDIDO]             .AND.  ;
					SZ6->Z6_CLI     == SUBSTR(oGetDados:aCOLS[nLin][P1_IDCLIE],1,6) .AND.  ;
					SZ6->Z6_LOJA    == SUBSTR(oGetDados:aCOLS[nLin][P1_IDCLIE],8,2) .AND.  ;
					SZ6->Z6_PRODUTO == oGetDados:aCOLS[nLin][P1_PRODUTO]

				IF SZ6->Z6_ITEM == oGetDados:aCOLS[nLin][P1_ITEM]

					SZ6->(RECLOCK('SZ6',.F.))
					SZ6->Z6_QTDLIB2  :=oGetDados:aCOLS[nLin][P1_QTDED] //       10
					DO CASE
					CASE cTIPOGRV=='1'
						SZ6->Z6_QTDLIB   :=oGetDados:aCOLS[nLin][P1_PESOD] //       11
						SZ6->Z6_VALOR    :=oGetDados:aCOLS[nLin][P1_PESOD] * SZ6->Z6_PRCVEN
					CASE cTIPOGRV=='2'
						SZ6->Z6_QTDLIB   :=M->PESOD //       11
						SZ6->Z6_VALOR    :=M->PESOD * SZ6->Z6_PRCVEN
					ENDCASE
					SZ6->Z6_OMAVOL   :=oGetDados:aCOLS[nLin][P1_VOLUME] //       11
					IF oGetDados:aCOLS[nLin][P1_DELETE]==.F.
						SZ6->Z6_OK      :=.F.
					ELSE
						SZ6->Z6_OK      :=.T.
					ENDIF
					SZ6->(MSUNLOCK())
				ENDIF
				SZ6->(DBSKIP())
			ENDDO
		ELSE
			MSGALERT('MSG 000005','MSG')
		ENDIF
		SZ5->(DBSEEK(xFILIAL('SZ5')+oGetDados:aCOLS[nLin][P1_PEDIDO]))
		IF SZ5->(FOUND())
			SZ5->(RECLOCK('SZ5',.F.))
			SZ5->Z5_TRANSP2  :=cTRANSP2
			SZ5->Z5_TRANSP3  :=cTRANSP3
			SZ5->Z5_VEIC2    :=UPPER(cPLACA2)
			SZ5->Z5_VEICULO  :=UPPER(cPLACA3)
			IF EMPTY(SZ5->Z5_NOTA)
				SZ5->Z5_NOTA  :=oGetDados:aCOLS[nLin][P1_NOTA]
				SZ5->Z5_SERIE :=oGetDados:aCOLS[nLin][P1_SERIE]
			ENDIF
			SZ5->(MSUNLOCK())

		ELSE
			MSGALERT('MSG 000006','MSG')
		ENDIF

		SZ7->(DBSELECTAREA('SZ7'))
		SZ7->(DBSETORDER(1))//(1)Z6_XPRDKIT),11,06FILIAL+CODBAR+PRODUTO+PEDIDO+ITEM PV+CLIENTE+LOJA+Sequencia

		For nX :=1 to len(aColsLT)

			IF aCOLSLT[nX][P2_PEDIDO]   == oGetDados:aCOLS[nLin][P1_PEDIDO]   .AND. ;    //pedido
				aCOLSLT[nX][P2_ITEM] == oGetDados:aCOLS[nLin][P1_ITEM]  .AND. ;    //idclie
				aCOLSLT[nX][P2_IDCLIE]  == oGetDados:aCOLS[nLin][P1_IDCLIE]   .AND. ;    //idclie
				aCOLSLT[nX][P2_PRODUTO2]  == oGetDados:aCOLS[nLin][P1_PRODUTO]              //produto

				cLOTE :=SPACE(50)
				cCOD  :=SPACE(15)
				cPED  :=SPACE(29)
				cCLI  :=SPACE(06)
				cLOJ  :=SPACE(02)
				cITEM :=SPACE(02)

				cLOTE :=aCOLSLT[nX][P2_CODBAR]              +cLOTE
				cCOD  :=aCOLSLT[nX][P2_PRODUTO]              +cCOD
				cPED  :=aCOLSLT[nX][P2_PEDIDO]              +cPED
				cCLI  :=SUBSTR(aCOLSLT[nX][P2_IDCLIE],1,6)  +cCLI
				cLOJ  :=SUBSTR(aCOLSLT[nX][P2_IDCLIE],8,2)  +cLOJ
				cITEM :=aCOLSLT[nX][P2_ITEM]              +cITEM
				cSEQ  :=ALLTRIM(STR(aCOLSLT[nX][P2_NSEQ]))
				cCod128:= aCOLSLT[nX][P2_CODBAR]
				//Carrega data de validade quando tiver
				aCOLSLT[nX][P2_VALID] := StoD(If(Len(AllTrim(aCOLSLT[nX][P2_CODBAR])) >= 31, SubStr(aCOLSLT[nX][P2_CODBAR],28,4) + SubStr(aCOLSLT[nX][P2_CODBAR],26,2) + SubStr(aCOLSLT[nX][P2_CODBAR],24,2),""))
				//  		 FILIAL                CODBAR             PRODUTO           PEDIDO            ITEM PV            CLIENTE           LOJA       SEQUENCIA
				If SZ7->(DBSEEK(xFILIAL('SZ7')+substr(cLOTE,1,50)+SUBSTR(cCOD,1,15)+SUBSTR(cPED,1,29)+SUBSTR(cITEM,1,02)+SUBSTR(cCLI,1,06)+SUBSTR(cLOJ,1,02)+cSEQ      ))
					IF aCOLSLT[nX][P2_DELETE]
						SZ7->(RECLOCK('SZ7',.F.))
						SZ7->(dbDelete())
						SZ7->(MSUNLOCK())
						GravaZ24(cCOD,cCod128,cLOTE,cPED,aCOLSLT[nX][P2_PESO],aCOLSLT[nX][P2_QTDE],.T.)
						//lDel:=.T.
					ELSE
						SZ7->(RECLOCK('SZ7',.F.))
						SZ7->Z7_FILIAL  :=xFilial('SZ7')
						SZ7->Z7_CODBAR  :=aCOLSLT[nX][P2_CODBAR]
						SZ7->Z7_PRODUTO :=aCOLSLT[nX][P2_PRODUTO]
						SZ7->Z7_LOTE    :=aCOLSLT[nX][P2_LOTE]
						SZ7->Z7_VALID   :=aCOLSLT[nX][P2_VALID]
						SZ7->Z7_QTDE    :=aCOLSLT[nX][P2_QTDE]
						SZ7->Z7_PESO    :=aCOLSLT[nX][P2_PESO]
						SZ7->Z7_PEDIDO  :=aCOLSLT[nX][P2_PEDIDO]
						SZ7->Z7_ITEM    :=aCOLSLT[nX][P2_ITEM]
						SZ7->Z7_CLIENTE :=SUBSTR(aCOLSLT[nX][P2_IDCLIE],1,6)
						SZ7->Z7_LOJA    :=SUBSTR(aCOLSLT[nX][P2_IDCLIE],8,2)
						SZ7->Z7_NSEQ    :=aCOLSLT[nX][P2_NSEQ]
						/* SZ7->Z7_PALLET  :=cNpallet */
						SZ7->(MSUNLOCK())
						//GravaZ24(cCOD,cCod128,cLOTE,cPED,aCOLSLT[nX][P2_PESO],aCOLSLT[nX][P2_QTDE],.F.)
					ENDIF
				ELSE
					IF !aCOLSLT[nX][P2_DELETE]
						SZ7->(RECLOCK('SZ7',.T.))
						SZ7->Z7_FILIAL  :=xFilial('SZ7')
						SZ7->Z7_CODBAR  :=aCOLSLT[nX][P2_CODBAR]
						SZ7->Z7_PRODUTO :=aCOLSLT[nX][P2_PRODUTO]
						SZ7->Z7_LOTE    :=aCOLSLT[nX][P2_LOTE]
						SZ7->Z7_VALID   :=aCOLSLT[nX][P2_VALID]
						SZ7->Z7_QTDE    :=aCOLSLT[nX][P2_QTDE]
						SZ7->Z7_PESO    :=aCOLSLT[nX][P2_PESO]
						SZ7->Z7_PEDIDO  :=aCOLSLT[nX][P2_PEDIDO]
						SZ7->Z7_ITEM    :=aCOLSLT[nX][P2_ITEM]
						SZ7->Z7_CLIENTE :=SUBSTR(aCOLSLT[nX][P2_IDCLIE],1,6)
						SZ7->Z7_LOJA    :=SUBSTR(aCOLSLT[nX][P2_IDCLIE],8,2)
						SZ7->Z7_NSEQ    :=aCOLSLT[nX][P2_NSEQ]
						/* SZ7->Z7_PALLET  :=cNpallet */
						SZ7->(MSUNLOCK())
					ENDIF
				ENDIF
			ENDIF
		NEXT
	ENDIF
RETURN

	*----------------------------------------------------------------------------*
USER FUNCTION VALIDDATA(dDATA1B)
	*----------------------------------------------------------------------------*
	LOCAL lRET :=.T.
	LOCAL nDIFDAT := dDATA1B-DATE()
	IF nDIFDAT >=2
		IF MSGYESNO('Data atual '+ALLTRIM(dtoc(date()))+' data digitada '+ALLTRIM(dtoc(dDATA1B))+' entrega futura '+ALLTRIM(str(nDIFDAT))+' dias Confirma ?' ,'Atenção 1/2')
			IF MSGNOYES('Data atual '+ALLTRIM(dtoc(date()))+' data digitada '+ALLTRIM(dtoc(dDATA1B))+' entrega futura '+ALLTRIM(str(nDIFDAT))+' dias Confirma ?' ,'Atenção 2/2')
				lRET :=.T.
			ELSE
				lRET :=.F.
			ENDIF
		ELSE
			lRET :=.F.
		ENDIF
	ENDIF

RETURN lRET

	*----------------------------------------------------------------------------*
STATIC FUNCTION  FATNAUTO()
	*----------------------------------------------------------------------------*
	MsAguarde( { || FATNAUT2() } , "Aguarde..." )
RETURN

	*----------------------------------------------------------------------------*
STATIC FUNCTION FATNAUT2()
	*----------------------------------------------------------------------------*
	LOCAL cQUERYAUT := SPACE(01)
	Local nY        := 0
	Local nZ        := 0
	Local cBkpEmp	:= cEmpAnt
	Local cBkpFil	:= cFilAnt
	LOCAL cAutoFAT    := GETMV('MV_AUTOFAT')
	Local cGrpProd	:= ""

	PRIVATE lNFFirst :=.T.
	Private _cNumero :='000000000'

	aCOLS2 := AClone( aCOLS )
	oGetDados:ACOLS := AClone( aCOLS2 )
	oGetDados:oBrowse:Refresh()

	//U_FATGRV1(oGetDados,'1')
	SZ6->(DBSELECTAREA('SZ6'))
	SZ6->(DBSETORDER(3))//NUMERO+CLIENTE+LOJA+PRODUTO


	FOR nY :=1 TO LEN(oGetDados:ACOLS)
		SZ6->(DBSEEK(xFILIAL('SZ6')+aCOLS[nY][P1_PEDIDO]+SUBSTR(aCOLS[nY][P1_IDCLIE],1,6)+SUBSTR(aCOLS[nY][P1_IDCLIE],8,2)+aCOLS[nY][P1_PRODUTO]))
		IF SZ6->(FOUND())
			DO WHILE .NOT. SZ6->(EOF()) .AND.  SZ6->Z6_FILIAL==xFILIAL('SZ6') .AND.;
					SZ6->Z6_NUM     == aCOLS[nY][P1_PEDIDO]             .AND.  ;
					SZ6->Z6_CLI     == SUBSTR(aCOLS[nY][P1_IDCLIE],1,6) .AND.  ;
					SZ6->Z6_LOJA    == SUBSTR(aCOLS[nY][P1_IDCLIE],8,2) .AND.  ;
					SZ6->Z6_PRODUTO == aCOLS[nY][P1_PRODUTO]

				IF SZ6->Z6_ITEM == aCOLS[nY][P1_ITEM]
					SZ6->(RECLOCK('SZ6',.F.))
					SZ6->Z6_OMAVOL   := oGetDados:aCOLS[nY][P1_VOLUME] //
					SZ6->(MSUNLOCK())
				ENDIF
				SZ6->(DBSKIP())
			ENDDO
		ELSE
			MSGALERT('MSG 000001A','MSG')
		ENDIF
	NEXT


	IF len(oGetDados:ACOLS) > 0

		DO WHILE !EMPTY(cAutoFAT)
			MSGALERT('Geração  NF Bloqueado,  '+cAutoFAT)
			cAutoFAT := GETMV('MV_AUTOFAT')
		ENDDO

		PutMv("MV_AUTODES",SubStr(cUsuario,7,15)  )

		IF SUBSTR(cNAUTO,1,1)=='2' //.AND. EMPTY(TRB->Z5_NOTA)//NUMERAÇÃO AUTOMATICA DA NF

			IF MSGYESNO('Gravar numero automatico da NF no Pré Pedido ?','Atenção')
				IF MSGNOYES('Gravar numero automatico da NF no Pré Pedido ?','Atenção')

					cQUERYAUT := ""
					cQUERYAUT := " SELECT Z5_NUM,Z5_CLIENTE,Z5_LOJACLI,A1_NREDUZ,A1_GRPVEN,A1_ROTENTR, "
					cQUERYAUT += "        Z5_TRANSP,Z5_TRANSP2,Z5_TRANSP3,Z5_VEICULO,Z5_VEIC2,Z5_NOTA,Z5_SERIE,Z5_EMPRESA,        "
					cQUERYAUT += "        Z6_PRODUTO,Z6_UNSVEN,Z6_QTDVEN ,Z6_UM,Z6_QTDLIB2,Z6_QTDLIB,Z6_OMAVOL,Z6_OK,Z6_ITEM "
					cQUERYAUT += " FROM "+RetSqlName('SZ5')+" Z5, "+RetSqlName('SZ6')+" Z6, "+RetSqlName('SA1')+" A1, "+RetSqlName('SA4')+" A4, "
					cQUERYAUT += "      "+RetSqlName('SB1')+" B1 "
					cQUERYAUT += " WHERE Z6_NUM=Z5_NUM "
					cQUERYAUT += "   AND Z6_OMAVOL >0 "
					cQUERYAUT += "   AND A1_COD=Z5_CLIENTE AND A1_LOJA=Z5_LOJACLI "
					cQUERYAUT += "   AND A4_COD=Z5_TRANSP                         "
					cQUERYAUT += "   AND Z5_TRANSP='"+cTRANSP+"'   "
					cQUERYAUT += "   AND Z6_STATUS IN ('1')  "
					cQUERYAUT += "   AND B1_COD=Z6_PRODUTO "
					cQUERYAUT += "   AND Z6_ENTREG ='"+DTOS(dData1)+"'  "
					cQUERYAUT += "   AND Z5_EMPRESA IN ('1','B','R','P','6','7')  "//OMAMORI MATRIZ , OMAMORI VINHEDO //Incluso empresa 'R' - Marcus Amorim
					cQUERYAUT += "   AND Z6.D_E_L_E_T_<>'*' AND Z5.D_E_L_E_T_<>'*' AND A1.D_E_L_E_T_<>'*'  AND A4.D_E_L_E_T_<>'*' "
					cQUERYAUT += "   AND B1.D_E_L_E_T_<>'*'  "
					cQUERYAUT += " ORDER BY Z5_TRANSP,A1_GRPVEN,A1_ROTENTR,Z5_CLIENTE,Z5_LOJACLI,Z5_NUM,Z6_PRODUTO "

					cQueryAUT := ChangeQuery(CQUERYAUT)
					TcQuery cQueryAUT ALIAS "TRA" NEW

					TRA->(DBSELECTAREA("TRA"))

					cNUMPPV :=TRA->Z5_NUM

					_cSerie  := GetMV("MV_SERFAT")

					SZ5->(DBSELECTAREA('SZ5'))
					SZ5->(DBSETORDER(1))

					cPEDIDO :=TRA->Z5_NUM
					lFIRST3 :=.T.

					DO WHILE !TRA->(EOF())
						cGrpProd := AllTrim(POSICIONE('SB1',1,xFILIAL('SB1')+TRA->Z6_PRODUTO,'B1_GRUPO'))
						
						If TRA->Z5_EMPRESA == 'B' //((TRA->Z5_EMPRESA <> 'R' .AND. TRA->Z5_EMPRESA <> 'P')  .AND. cGrpProd == 'UNRI' ) .or. (TRA->Z5_EMPRESA <> 'R' .and. TRA->Z5_EMPRESA <> 'P' )
							SZ5->(DBSEEK(xFILIAL('SZ5')+TRA->Z5_NUM))
							IF SZ5->(FOUND())
								IF  TRA->Z5_NUM <>cPEDIDO .OR. lFIRST3==.T.	
									DO CASE
									CASE  SZ5->Z5_EMPRESA =='1' //MATRIZ
										_cSerie  := GetMV("MV_SERFAT")
									CASE  SZ5->Z5_EMPRESA =='B' //VINHEDO
										_cSerie  := ALLTRIM(GetMV("MV_SERFAT"))//'1  ' Rodolfo Vacari 22/02/2017
									OTHERWISE
										_cSerie  := GetMV("MV_SERFAT")
									ENDCASE
									cPEDIDO :=TRA->Z5_NUM
									lFIRST3:=.F.
									SZ5->(RECLOCK('SZ5',.F.))
									SZ5->Z5_TRANSP2  :=cTRANSP2
									SZ5->Z5_TRANSP3  :=cTRANSP3
									SZ5->Z5_VEIC2    :=UPPER(cPLACA2)
									SZ5->Z5_VEICULO  :=UPPER(cPLACA3)
									If Empty(ALLTRIM(SZ5->Z5_NOTA))
										cQUERYNFA := "SELECT X5_DESCRI FROM "+RetSqlName('SX5')+" WHERE X5_FILIAL = '"+XFILIAL('SX5')+"' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*' "  //MaConvNNota( X5Descri(),9)  //SomaIt( "1")
										TcQuery cQUERYNFA ALIAS "NXTNF" NEW
										NXTNF->(DBSELECTAREA("NXTNF"))
										_cNumero := STRZERO(Val(NXTNF->X5_DESCRI),9)
										NXTNF->(DBCLOSEAREA('NXTNF'))
										_cNumAux := Soma1(ALLTRIM(_cNumero))
										cQueryNFA2 := "UPDATE "+RetSqlName('SX5')+" SET X5_DESCRI = '"+_cNumAux+"', X5_DESCSPA = '"+_cNumAux+"', X5_DESCENG = '"+_cNumAux+"' WHERE X5_FILIAL = '"+XFILIAL('SX5')+"' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*'
										TCSQLEXEC(cQueryNFA2)
										cNOTA    :=ALLTRIM(_cNumero)
										cSERIE   :=_cSerie
										SZ5->Z5_NOTA  :=cNOTA
										SZ5->Z5_SERIE :=cSERIE
									EndIf
									SZ5->(MSUNLOCK())
								ENDIF

							ENDIF
						ElseIf TRA->Z5_EMPRESA == 'C'

							SZ5->(DBSEEK(xFILIAL('SZ5')+TRA->Z5_NUM))
							IF SZ5->(FOUND())
								IF  TRA->Z5_NUM <> cPEDIDO .OR. lFIRST3==.T.
									_cSerie  := '1  '
									cPEDIDO :=TRA->Z5_NUM
									lFIRST3:=.F.
									SZ5->(RECLOCK('SZ5',.F.))
									SZ5->Z5_TRANSP2  :=cTRANSP2
									SZ5->Z5_TRANSP3  :=cTRANSP3
									SZ5->Z5_VEIC2    :=UPPER(cPLACA2)
									SZ5->Z5_VEICULO  :=UPPER(cPLACA3)

									If Empty(SZ5->Z5_NOTA)
										cQUERYNFA := "SELECT X5_DESCRI FROM "+RetSqlName('SX5')+" WHERE X5_FILIAL = '"+XFILIAL('SX5')+"' and X5_TABELA = '01' and X5_CHAVE = '2' and D_E_L_E_T_ <> '*' "  //MaConvNNota( X5Descri(),9)  //SomaIt( "1")
										TcQuery cQUERYNFA ALIAS "NXTNF" NEW
										NXTNF->(DBSELECTAREA("NXTNF"))
										_cNumero := STRZERO(Val(NXTNF->X5_DESCRI),9)
										NXTNF->(DBCLOSEAREA('NXTNF'))
										_cNumAux := Soma1(ALLTRIM(_cNumero))
										cQueryNFA2 := "UPDATE "+RetSqlName('SX5')+" SET X5_DESCRI = '"+_cNumAux+"', X5_DESCSPA = '"+_cNumAux+"', X5_DESCENG = '"+_cNumAux+"' WHERE X5_FILIAL = '"+XFILIAL('SX5')+"' and X5_TABELA = '01' and X5_CHAVE = '2' and D_E_L_E_T_ <> '*'
										TCSQLEXEC(cQueryNFA2)
										cNOTA    :=ALLTRIM(_cNumero)
										cSERIE   :=_cSerie
										SZ5->Z5_NOTA  :=cNOTA
										SZ5->Z5_SERIE :=cSERIE
									EndIf
									SZ5->(MSUNLOCK())
								ENDIF
							ENDIF
							cFilEmp := cBkpEmp
							cFilAnt := cBkpFil
						ElseIf TRA->Z5_EMPRESA == '7'
							cEmpAnt := "07"
							cFilAnt := "01"
							SZ5->(DBSEEK(xFILIAL('SZ5')+TRA->Z5_NUM))
							IF SZ5->(FOUND())
								IF  TRA->Z5_NUM <> cPEDIDO .OR. lFIRST3==.T.
									_cSerie  := '1  '
									cPEDIDO :=TRA->Z5_NUM
									lFIRST3:=.F.
									SZ5->(RECLOCK('SZ5',.F.))
									SZ5->Z5_TRANSP2  :=cTRANSP2
									SZ5->Z5_TRANSP3  :=cTRANSP3
									SZ5->Z5_VEIC2    :=UPPER(cPLACA2)
									SZ5->Z5_VEICULO  :=UPPER(cPLACA3)

									If Empty(SZ5->Z5_NOTA)
										cQUERYNFA := "SELECT X5_DESCRI FROM SX5070 WHERE X5_FILIAL = '01' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*' "  //MaConvNNota( X5Descri(),9)  //SomaIt( "1")
										TcQuery cQUERYNFA ALIAS "NXTNF" NEW
										NXTNF->(DBSELECTAREA("NXTNF"))
										_cNumero := STRZERO(Val(NXTNF->X5_DESCRI),9)
										NXTNF->(DBCLOSEAREA('NXTNF'))
										_cNumAux := Soma1(ALLTRIM(_cNumero))
										cQueryNFA2 := "UPDATE SX5070 SET X5_DESCRI = '"+_cNumAux+"', X5_DESCSPA = '"+_cNumAux+"', X5_DESCENG = '"+_cNumAux+"' WHERE X5_FILIAL = '01' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*'
										TCSQLEXEC(cQueryNFA2)
										cNOTA    :=ALLTRIM(_cNumero)
										cSERIE   :=_cSerie
										SZ5->Z5_NOTA  :=cNOTA
										SZ5->Z5_SERIE :=cSERIE
									EndIf
									SZ5->(MSUNLOCK())
								ENDIF
							ENDIF
							cFilEmp := cBkpEmp
							cFilAnt := cBkpFil
						ElseIf TRA->Z5_EMPRESA == 'R'
							cEmpAnt := "07"
							cFilAnt := "02"
							SZ5->(DBSEEK(xFILIAL('SZ5')+TRA->Z5_NUM))
							IF SZ5->(FOUND())
								IF  TRA->Z5_NUM <> cPEDIDO .OR. lFIRST3==.T.
									_cSerie  := '1  '
									cPEDIDO :=TRA->Z5_NUM
									lFIRST3:=.F.
									SZ5->(RECLOCK('SZ5',.F.))
									SZ5->Z5_TRANSP2  :=cTRANSP2
									SZ5->Z5_TRANSP3  :=cTRANSP3
									SZ5->Z5_VEIC2    :=UPPER(cPLACA2)
									SZ5->Z5_VEICULO  :=UPPER(cPLACA3)

									If Empty(SZ5->Z5_NOTA)
										cQUERYNFA := "SELECT X5_DESCRI FROM SX5070 WHERE X5_FILIAL = '02' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*' "  //MaConvNNota( X5Descri(),9)  //SomaIt( "1")
										TcQuery cQUERYNFA ALIAS "NXTNF" NEW
										NXTNF->(DBSELECTAREA("NXTNF"))
										_cNumero := STRZERO(Val(NXTNF->X5_DESCRI),9)
										NXTNF->(DBCLOSEAREA('NXTNF'))
										_cNumAux := Soma1(ALLTRIM(_cNumero))
										cQueryNFA2 := "UPDATE SX5070 SET X5_DESCRI = '"+_cNumAux+"', X5_DESCSPA = '"+_cNumAux+"', X5_DESCENG = '"+_cNumAux+"' WHERE X5_FILIAL = '02' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*'
										TCSQLEXEC(cQueryNFA2)
										cNOTA    :=ALLTRIM(_cNumero)
										cSERIE   :=_cSerie
										SZ5->Z5_NOTA  :=cNOTA
										SZ5->Z5_SERIE :=cSERIE
									EndIf
									SZ5->(MSUNLOCK())
								ENDIF
							ENDIF
							cFilEmp := cBkpEmp
							cFilAnt := cBkpFil
						ElseIf TRA->Z5_EMPRESA == 'P'
							cEmpAnt := "07"
							cFilAnt := "04"
							SZ5->(DBSEEK(xFILIAL('SZ5')+TRA->Z5_NUM))
							IF SZ5->(FOUND())
								IF  TRA->Z5_NUM <> cPEDIDO .OR. lFIRST3==.T.
									_cSerie  := '1  '
									cPEDIDO :=TRA->Z5_NUM
									lFIRST3:=.F.
									SZ5->(RECLOCK('SZ5',.F.))
									SZ5->Z5_TRANSP2  :=cTRANSP2
									SZ5->Z5_TRANSP3  :=cTRANSP3
									SZ5->Z5_VEIC2    :=UPPER(cPLACA2)
									SZ5->Z5_VEICULO  :=UPPER(cPLACA3)

									If Empty(SZ5->Z5_NOTA)
										cQUERYNFA := "SELECT X5_DESCRI FROM SX5070 WHERE X5_FILIAL = '04' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*' "  //MaConvNNota( X5Descri(),9)  //SomaIt( "1")
										TcQuery cQUERYNFA ALIAS "NXTNF" NEW
										NXTNF->(DBSELECTAREA("NXTNF"))
										_cNumero := STRZERO(Val(NXTNF->X5_DESCRI),9)
										NXTNF->(DBCLOSEAREA('NXTNF'))
										_cNumAux := Soma1(ALLTRIM(_cNumero))
										cQueryNFA2 := "UPDATE SX5070 SET X5_DESCRI = '"+_cNumAux+"', X5_DESCSPA = '"+_cNumAux+"', X5_DESCENG = '"+_cNumAux+"' WHERE X5_FILIAL = '04' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*'
										TCSQLEXEC(cQueryNFA2)
										cNOTA    :=ALLTRIM(_cNumero)
										cSERIE   :=_cSerie
										SZ5->Z5_NOTA  :=cNOTA
										SZ5->Z5_SERIE :=cSERIE
									EndIf
									SZ5->(MSUNLOCK())
								ENDIF
							ENDIF
						ElseIf TRA->Z5_EMPRESA == 'G'
							cEmpAnt := "07"
							cFilAnt := "06"
							SZ5->(DBSEEK(xFILIAL('SZ5')+TRA->Z5_NUM))
							IF SZ5->(FOUND())
								IF  TRA->Z5_NUM <> cPEDIDO .OR. lFIRST3==.T.
									_cSerie  := '1  '
									cPEDIDO :=TRA->Z5_NUM
									lFIRST3:=.F.
									SZ5->(RECLOCK('SZ5',.F.))
									SZ5->Z5_TRANSP2  :=cTRANSP2
									SZ5->Z5_TRANSP3  :=cTRANSP3
									SZ5->Z5_VEIC2    :=UPPER(cPLACA2)
									SZ5->Z5_VEICULO  :=UPPER(cPLACA3)

									If Empty(SZ5->Z5_NOTA)
										cQUERYNFA := "SELECT X5_DESCRI FROM SX5070 WHERE X5_FILIAL = '06' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*' "  //MaConvNNota( X5Descri(),9)  //SomaIt( "1")
										TcQuery cQUERYNFA ALIAS "NXTNF" NEW
										NXTNF->(DBSELECTAREA("NXTNF"))
										_cNumero := STRZERO(Val(NXTNF->X5_DESCRI),9)
										NXTNF->(DBCLOSEAREA('NXTNF'))
										_cNumAux := Soma1(ALLTRIM(_cNumero))
										cQueryNFA2 := "UPDATE SX5070 SET X5_DESCRI = '"+_cNumAux+"', X5_DESCSPA = '"+_cNumAux+"', X5_DESCENG = '"+_cNumAux+"' WHERE X5_FILIAL = '06' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*'
										TCSQLEXEC(cQueryNFA2)
										cNOTA    :=ALLTRIM(_cNumero)
										cSERIE   :=_cSerie
										SZ5->Z5_NOTA  :=cNOTA
										SZ5->Z5_SERIE :=cSERIE
									EndIf
									SZ5->(MSUNLOCK())
								ENDIF
							ENDIF

						ElseIf TRA->Z5_EMPRESA == '6'
							cEmpAnt := "06"
							cFilAnt := "01"
							SZ5->(DBSEEK(xFILIAL('SZ5')+TRA->Z5_NUM))
							IF SZ5->(FOUND())
								IF  TRA->Z5_NUM <> cPEDIDO .OR. lFIRST3==.T.
									_cSerie  := '1  '
									cPEDIDO :=TRA->Z5_NUM
									lFIRST3:=.F.
									SZ5->(RECLOCK('SZ5',.F.))
									SZ5->Z5_TRANSP2  :=cTRANSP2
									SZ5->Z5_TRANSP3  :=cTRANSP3
									SZ5->Z5_VEIC2    :=UPPER(cPLACA2)
									SZ5->Z5_VEICULO  :=UPPER(cPLACA3)

									If Empty(SZ5->Z5_NOTA)
										cQUERYNFA := "SELECT X5_DESCRI FROM SX5060 WHERE X5_FILIAL = '' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*' "  //MaConvNNota( X5Descri(),9)  //SomaIt( "1")
										TcQuery cQUERYNFA ALIAS "NXTNF" NEW
										NXTNF->(DBSELECTAREA("NXTNF"))
										_cNumero := STRZERO(Val(NXTNF->X5_DESCRI),9)
										NXTNF->(DBCLOSEAREA('NXTNF'))
										_cNumAux := Soma1(ALLTRIM(_cNumero))
										cQueryNFA2 := "UPDATE SX5060 SET X5_DESCRI = '"+_cNumAux+"', X5_DESCSPA = '"+_cNumAux+"', X5_DESCENG = '"+_cNumAux+"' WHERE X5_FILIAL = '' and X5_TABELA = '01' and X5_CHAVE = '1' and D_E_L_E_T_ <> '*'
										TCSQLEXEC(cQueryNFA2)
										cNOTA    :=ALLTRIM(_cNumero)
										cSERIE   :=_cSerie
										SZ5->Z5_NOTA  :=cNOTA
										SZ5->Z5_SERIE :=cSERIE
									EndIf
									SZ5->(MSUNLOCK())
								ENDIF
							ENDIF

							cFilEmp := cBkpEmp
							cFilAnt := cBkpFil
						EndIf
						TRA->(DBSKIP())
					ENDDO
					//cQUERYNFA := ' SELECT X5_DESCRI,X5_DESCSPA,X5_DESCENG FROM SX5010  '
					//cQUERYNFA += " WHERE X5_TABELA='01' AND X5_CHAVE='3  ' AND D_E_L_E_T_<>'*'  "
					//TcQuery cQUERYNFA ALIAS "NFA" NEW
					//NFA->(DBSELECTAREA("NFA"))
					//_cNumero := Soma1(ALLTRIM(NFA->X5_DESCRI))
					//cNOTA    :=ALLTRIM(_cNumero)
					//cSERIE   :=_cSerie
					//SZ5->Z5_NOTA  :=cNOTA   // ESKOKADO
					//SZ5->Z5_SERIE :=cSERIE  // ESKOKADO
					//NFA->(DBCLOSEAREA('NFA'))
					//cQueryNFA2 :=' UPDATE  SX5010  '
					//cQueryNFA2 +=" SET  X5_DESCRI='"+ALLTRIM(cNOTA)+"',X5_DESCSPA='"+ALLTRIM(cNOTA)+"',X5_DESCENG='"+ALLTRIM(cNOTA)+"'   "
					//cQueryNFA2 +=" WHERE X5_TABELA='01' AND X5_CHAVE='3  ' AND D_E_L_E_T_<>'*'  "
					//TCSQLEXEC(cQueryNFA2)
					IF SELECT("TRA") <> 0
						TRA->(DBCLOSEAREA())
					ENDIF
				ENDIF
				// aScan(aHeader,{|x| Trim(x[2])=="C1_PRODUTO"})
				FOR nZ := 1 TO LEN(oGETDADOS:aCOLS)
					If Empty(oGETDADOS:aCOLS[nZ][P1_NOTA])
						oGETDADOS:aCOLS[nZ][P1_NOTA]  := POSICIONE('SZ5', 1, xFILIAL('SZ5') + oGetDados:aCOLS[nZ][P1_PEDIDO], 'Z5_NOTA'  )
						oGETDADOS:aCOLS[nZ][P1_SERIE] := POSICIONE('SZ5', 1, xFILIAL('SZ5') + oGetDados:aCOLS[nZ][P1_PEDIDO], 'Z5_SERIE' )
					EndIf
				NEXT
			ENDIF
		ELSE
			MSGALERT('Tipo de numeração NF 1 - Normal','Atenção')
		ENDIF
	ELSE
		MSGYESNO('Nao existe itens para numeração, pressione visualizar ','Atenção')
	ENDIF
	PutMv("MV_AUTODES",'')
RETURN


	*----------------------------------------------------------------------------------------
STATIC FUNCTION FATETQ1()
	*----------------------------------------------------------------------------------------
	LOCAL	nOPC1	:= 2

	PRIVATE cNF1	  := SPACE(9)
	PRIVATE cNF2	  := '999999999'

	PRIVATE cSERIE1	  := SPACE(3)
	PRIVATE cSERIE2	  := 'ZZZ'

	PRIVATE cCLIENTE1 := SPACE(6)
	PRIVATE cCLIENTE2 := 'ZZZZZZ'

	PRIVATE cPEDIDO1  := SPACE(10)
	PRIVATE cPEDIDO2  := 'ZZZZZZZZZZ'

	PRIVATE cProd1    := SPACE(15)
	PRIVATE cProd2    := 'ZZZZZZZZZZZZZZZ'



	PRIVATE aETQ	:= {}
	PRIVATE aPED	:= {}
	PRIVATE cQUERY	:= ""

	PRIVATE cNF		:= ""
	PRIVATE cZONA	:= ""
	PRIVATE cROTEIRO:= ""
	PRIVATE cPEDIDO	:= ""
	PRIVATE cPLACA	:= ""
	PRIVATE cMUN	:= ""
	PRIVATE nVOL	:= 0
	PRIVATE cDADOS	:= ""
	PRIVATE I		:= 1

	private oOrdETQ
	private cOrdETQ   :=  SuperGetMv("OM_ORDDESP",,'3 - Codigo de Produto')// '2 - Zona Crescente Roteiro Decrescente'
	private aOrdETQ	  := {'1 - Zona crescente Roteiro Crescente','2 - Zona Crescente Roteiro Decrescente','3 - Codigo de Produto','4 - Cidade'}

	private oTipoETQ
	private cTipoETQ  :=  '1 - Impressora Zebra'
	private aTipoETQ  := {'1 - Impressora Zebra','2 - Jato de Tinta   ' }



	DEFINE MSDIALOG oDlgETQ TITLE OemToAnsi("Etiquetas: Remessa por transportadora")  From 115,0 To 530,480 OF oMainWnd PIXEL

	@ 035,010 SAY OemToAnsi("N.F. de:    ") SIZE 055,007 OF oDlgETQ PIXEL
	@ 035,050 MSGET cNF1                    SIZE 055,007 OF oDlgETQ PIXEL
	@ 045,010 SAY OemToAnsi("N.F. ate:   ") SIZE 055,007 OF oDlgETQ PIXEL
	@ 045,050 MSGET cNF2                    SIZE 055,007 OF oDlgETQ PIXEL

	@ 055,010 SAY OemToAnsi("Serie de:   ") SIZE 055,007 OF oDlgETQ PIXEL
	@ 055,050 MSGET cSERIE1                 SIZE 055,007 OF oDlgETQ PIXEL
	@ 065,010 SAY OemToAnsi("Serie ate:  ") SIZE 055,007 OF oDlgETQ PIXEL
	@ 065,050 MSGET cSERIE2                 SIZE 055,007 OF oDlgETQ PIXEL

	@ 075,010 SAY OemToAnsi("Cliente de: ") SIZE 055,007 OF oDlgETQ PIXEL
	@ 075,050 MSGET cCLIENTE1               SIZE 055,007 OF oDlgETQ PIXEL
	@ 085,010 SAY OemToAnsi("Cliente ate:") SIZE 055,007 OF oDlgETQ PIXEL
	@ 085,050 MSGET cCLIENTE2               SIZE 055,007 OF oDlgETQ PIXEL

	@ 095,010 SAY OemToAnsi("Pedido de:  ") SIZE 055,007 OF oDlgETQ PIXEL
	@ 095,050 MSGET cPedido1                SIZE 055,007 OF oDlgETQ PIXEL
	@ 105,010 SAY OemToAnsi("Pedido ate: ") SIZE 055,007 OF oDlgETQ PIXEL
	@ 105,050 MSGET cPedido2                SIZE 055,007 OF oDlgETQ PIXEL

	@ 115,010 SAY OemToAnsi("Produto de: ") SIZE 055,007 OF oDlgETQ PIXEL
	@ 115,050 MSGET cProd1                  SIZE 055,007 OF oDlgETQ PIXEL
	@ 125,010 SAY OemToAnsi("Produto ate:") SIZE 055,007 OF oDlgETQ PIXEL
	@ 125,050 MSGET cProd2                  SIZE 055,007 OF oDlgETQ PIXEL

	@ 135,010 SAY OemToAnsi("Ordem :") SIZE 055,007 OF oDlgETQ PIXEL
	@ 135,050 combobox oOrdETQ var cOrdETQ items aOrdETQ     size 125,08 of oDlgETQ pixel

	@ 145,010 SAY OemToAnsi("Tipo  :") SIZE 055,007 OF oDlgETQ PIXEL
	@ 145,050 combobox oTipoETQ var cTipoETQ items aTipoETQ  size 125,08 of oDlgETQ pixel


	ACTIVATE DIALOG oDlgETQ ON INIT EnchoiceBar(oDlgETQ,{||nOPC1:=1,oDlgETQ:End() },{||NOPC1:=2,oDlgETQ:End() }) CENTERED

	IF nOPC1==2
		RETURN
	ENDIF

	PROCESSA({||FATETQ1A()})


RETURN

	*----------------------------------------------------------------------------------------
STATIC FUNCTION FATETQ1A()
	*----------------------------------------------------------------------------------------
	LOCAL cMunicipio :=Space(30)
	LOCAL cQUERYETQ  := ""
	LOCAL nCOUNT     := 1
	Local cNoReSNF   := AllTrim(SuperGetMv("OM_NORESNF",,"R"))
	Local cLRotEnt	 := ""

	cQUERYETQ := " SELECT Z5_EMPRESA, Z5_NUM,Z5_CLIENTE,Z5_LOJACLI,A1_NREDUZ,A1_GRPVEN,A1_ROTENTR,Z6_ENTREG, "
	cQUERYETQ += "        Z5_TRANSP,Z5_TRANSP2,Z5_TRANSP3,Z5_VEICULO,Z5_VEIC2,Z5_NOTA,Z5_SERIE,         "
	cQUERYETQ += "        Z6_PRODUTO,Z6_UNSVEN,Z6_QTDVEN ,Z6_UM,Z6_QTDLIB2,Z6_QTDLIB,Z6_OMAVOL,Z6_OK,Z6_ITEM,Z5_CIDADE,Z5_END "
	cQUERYETQ += " FROM "+RetSqlName('SZ5')+" Z5, "+RetSqlName('SZ6')+" Z6, "+RetSqlName('SA1')+" A1, "+RetSqlName('SA4')+" A4, "
	cQUERYETQ += "      "+RetSqlName('SB1')+" B1 "
	cQUERYETQ += " WHERE Z6_NUM=Z5_NUM    "
	cQUERYETQ += "   AND Z6_OMAVOL >0 "
	cQUERYETQ += "   AND A1_COD=Z5_CLIENTE AND A1_LOJA=Z5_LOJACLI "
	cQUERYETQ += "   AND A4_COD=Z5_TRANSP                         "
	cQUERYETQ += "   AND Z5_TRANSP='"+cTRANSP+"'   "
	cQUERYETQ += "   AND Z6_STATUS IN ('1')  "
	cQUERYETQ += "   AND B1_COD=Z6_PRODUTO "
	cQUERYETQ += "   AND B1_FILIAL = '02' "
	cQUERYETQ += "   AND Z6_ENTREG ='"+DTOS(dData1)+"'  "

	cQUERYETQ += "   AND Z5_NOTA    >='"+cNF1   +"'   AND  Z5_NOTA    <= '"+cNF2    +"'  "
	cQUERYETQ += "   AND Z5_SERIE   >='"+cSERIE1+"'   AND  Z5_SERIE   <= '"+cSERIE2 +"'  "
	cQUERYETQ += "   AND Z6_PRODUTO >='"+cPROD1 +"'   AND  Z6_PRODUTO <= '"+cPROD2  +"'  "
	cQUERYETQ += "   AND SUBSTRING(Z5_NUM,4,10) >='"+cPedido1+"'  AND SUBSTRING(Z5_NUM,4,10) <='"+cPedido2+"'  "
	cQUERYETQ += "   AND Z5_CLIENTE >='"+cCLIENTE1+"' AND  Z5_CLIENTE <= '"+cCLIENTE2+"' "

	cQUERYETQ += "   AND Z6.D_E_L_E_T_<>'*' AND Z5.D_E_L_E_T_<>'*' AND A1.D_E_L_E_T_<>'*'  AND A4.D_E_L_E_T_<>'*' "
	cQUERYETQ += "   AND B1.D_E_L_E_T_<>'*'  "

	DO CASE
	CASE SUBSTR(cOrdETQ,1,1) =='1'   //'1 - Zona crescente Roteiro Crescente'
		cQUERYETQ += " ORDER BY A1_GRPVEN,A1_ROTENTR     ,Z5_CLIENTE ,Z5_LOJACLI,Z5_NUM,REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO) DESC  "
	CASE SUBSTR(cOrdETQ,1,1) =='2'   //'2 - Zona Crescente Roteiro Decrescente'
		cQUERYETQ += " ORDER BY A1_GRPVEN,A1_ROTENTR DESC,Z5_NUM,Z5_CLIENTE DESC ,Z5_LOJACLI,REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO)  "
	CASE SUBSTR(cOrdETQ,1,1) =='3'   //'3 - Codigo de Produto'
		cQUERYETQ += " ORDER BY REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO),A1_GRPVEN,A1_ROTENTR ,Z5_CLIENTE ,Z5_LOJACLI,Z5_NUM   "
	CASE SUBSTR(cOrdETQ,1,1) =='4'   //'3 - Cidade'
		cQUERYETQ += " ORDER BY Z5_CIDADE,Z5_END,Z5_NUM,Z5_CLIENTE ,Z5_LOJACLI,REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO) "

	ENDCASE

	cQUERYETQ := ChangeQuery(cQUERYETQ)
	TcQuery cQUERYETQ ALIAS "TRE" NEW

	TRE->(DBSELECTAREA("TRE"))

	DO WHILE !TRE->(EOF())
		cLRotEnt := ""
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial('SA1')+TRE->Z5_CLIENTE+TRE->Z5_LOJACLI))
		cMUNICIPIO := AllTrim(SA1->A1_MUN) + "/" + AllTrim(SA1->A1_EST)
		If !Empty(SA1->A1_SEQVIS2)
			cLRotEnt += 'B'
		EndIf

		If !Empty(SA1->A1_SEQVIS3)
			cLRotEnt += 'C'
		EndIf

		If !Empty(SA1->A1_SEQVIS4)
			cLRotEnt += 'D'
		EndIf

		If !Empty(SA1->A1_SEQVIS5)
			cLRotEnt += 'E'
		EndIf

		If !Empty(SA1->A1_SEQVIS6)
			cLRotEnt += 'F'
		EndIf

		FOR nCOUNT := 1 TO TRE->Z6_OMAVOL  //oGETDADOS:aCOLS[nX][P1_VOLUME] //TR1->C5_VOLUME1
			cROTENT:=strzero(TRE->A1_ROTENTR,5)
			cROTENT:=SUBSTR(cROTENT,1,3)+'/'+SUBSTR(cROTENT,4,2)

			AADD(aETQ,{	TRE->Z5_NOTA+" "+TRE->Z5_SERIE,;
				TRE->A1_GRPVEN,;
				cROTENT,;
				ALLTRIM(SUBSTR(TRE->Z5_NUM,4,14)),;
				ALLTRIM(UPPER(cPLACA3)),;
				ALLTRIM(cMUNICIPIO) + " Entrega: " + cLRotEnt,;
				.F.,;
				TRE->Z5_EMPRESA,;
				TRE->Z5_NUM,;
				TRE->Z5_CLIENTE + "/" + TRE->Z5_LOJACLI,;
				AllTrim(Posicione("SA1",1,xFilial("SA1") + TRE->Z5_CLIENTE + TRE->Z5_LOJACLI, "A1_NOME"))})

			nPosPed    := aScan(aPED,{|x| x[1]==ALLTRIM(SUBSTR(TRE->Z5_NUM,4,14))})

			If nPosPed == 0
				AADD(aPED,{ALLTRIM(SUBSTR(TRE->Z5_NUM,4,14)),1,0})
			Else
				aPed[nPosPed][2] := aPed[nPosPed][2] + 1
			EndIf

		NEXT nCOUNT

		TRE->(DBSKIP())
	ENDDO

	TRE->(DBCLOSEAREA())

/*
	FOR nX :=1 TO LEN(oGETDADOS:aCOLS)

		IF oGETDADOS:aCOLS[nX][P1_VOLUME]>0 .AND.!EMPTY(oGETDADOS:aCOLS[nX][P1_NOTA])

			cMUNICIPIO:=POSICIONE('SA1',1,xFILIAL('SA1')+SUBSTR(oGETDADOS:aCOLS[nX][P1_IDCLIE],1,6)+SUBSTR(oGETDADOS:aCOLS[nX][P1_IDCLIE],8,2),'A1_MUN')

			IF  oGETDADOS:aCOLS[nX][P1_NOTA] >=cNF1     .AND. oGETDADOS:aCOLS[nX][P1_NOTA] <=cNF2     .AND. ;
				oGETDADOS:aCOLS[nX][P1_SERIE] >=cSERIE1  .AND. oGETDADOS:aCOLS[nX][P1_SERIE] <=cSERIE2  .AND. ;   
				oGETDADOS:aCOLS[nX][P1_PRODUTO] >=cProd1   .AND. oGETDADOS:aCOLS[nX][P1_PRODUTO] <=cProd2   .AND. ;
				SUBSTR(oGETDADOS:aCOLS[nX][P1_PEDIDO],4,10) >=cPedido1  .AND. SUBSTR(oGETDADOS:aCOLS[nX][P1_PEDIDO],4,6) <=cPedido2 .AND. ;
				SUBSTR(oGETDADOS:aCOLS[nX][P1_IDCLIE],1,06) >=cCLIENTE1 .AND. SUBSTR(oGETDADOS:aCOLS[nX][P1_IDCLIE],1,6) <=cCLIENTE2

					FOR nCOUNT := 1 TO oGETDADOS:aCOLS[nX][P1_VOLUME] //TR1->C5_VOLUME1
						AADD(aETQ,{oGETDADOS:aCOLS[nX][P1_NOTA]+" "+oGETDADOS:aCOLS[nX][P1_SERIE],;    
						ALLTRIM(oGETDADOS:aCOLS[nX][P1_ZONA]), ALLTRIM(oGETDADOS:aCOLS[nX][P1_ROTEIRO]),;
						ALLTRIM(SUBSTR(oGETDADOS:aCOLS[nX][P1_PEDIDO],4,10)), ALLTRIM(cPLACA3),;
						ALLTRIM(cMUNICIPIO),.F.})
				NEXT nCOUNT
			ENDIF

		ENDIF

	NEXT nX
*/
	IF SUBSTR(cTipoETQ,1,1)='1'
		PROCESSA({||FATETQ2B()})
	ELSE
		PROCESSA({||FATETQ1B()})
	ENDIF

RETURN

	*----------------------------------------------------------------------------*
STATIC FUNCTION FATETQ1B()
	*----------------------------------------------------------------------------*

	cString  :="SA1"
	cDesc1   := OemToAnsi("Impressao das etiquetas para caixas dos")
	cDesc2   := OemToAnsi("produtos enviados via transportadora.")
	cDesc3   := ""
	tamanho  :="G"
	aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	nomeprog :=""
	aLinha   := { }
	nLastKey := 0
	lEnd     := .f.
	titulo   :=""
	cabec1   :=""
	cabec2   :=""
	cCancel  := "***** CANCELADO PELO OPERADOR *****"

	m_pag    := 1  //Variavel que acumula numero da pagina

	wnrel    :="ETQTRANS"            //Nome Default do relatorio em Disco
	SetPrint(cString,wnrel,,titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)

	If nLastKey == 27
		//	Set Filter To
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		//	Set Filter To
		Return
	Endif

	RptStatus({|| (RptDetail()) })
Return

	*----------------------------------------------------------------------------*
STATIC Function RptDetail()
	*----------------------------------------------------------------------------*
	LOCAL nLIN	:= 3
	LOCAL nLIN2	:= 2
	LOCAL nLIN3	:= 2
	LOCAL nCOL	:= 5
	LOCAL nX	:= 1
	LOCAL nY	:= 1
	LOCAL nZ	:= 1

	SetRegua(LEN(aETQ)) //Ajusta numero de elementos da regua de relatorios

//Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) //Impressao do cabecalho
//1			2			3			4		5		6			7
//F2_DOC+" "+F2_SERIE, A1_GRPVEN, A1_ROTENTR, C5_NUM, C5_VEICULO, A1_MUN, C5_VOLUME1,.F.


/*************************************************************************************/
/*	O "FOR" ABAIXO IMPRIME AS ETIQUETAS DA MANEIRA CORRETA		4 32 60					 */
/*	VERIFIQUE A POSICAO DAS COLUNAS ANTES DE IMPRIMIR			5 35 66				 */
/*************************************************************************************/
	ncont :=0
	FOR nX := 1 TO LEN(aETQ)
		ncont :=ncont+1

		nPosPed    := aScan(aPED,{|x| x[1]==aETQ[nX][04]})

		If nPosPed > 0
			aPed[nPosPed][3] := aPed[nPosPed][3] + 1
			cEtiq := Alltrim(Str(aPed[nPosPed][3]))+ '/' + Alltrim(Str(aPed[nPosPed][2]))
		Else
			cEtiq := ''
		EndIf
		@ nLIN,4  PSAY cEtiq

		nLIN++
		@ nLIN,4  PSAY aETQ[nX][01]

		IF nX+1 <= LEN(aETQ)
			@ nLIN,32 PSAY aETQ[nX+1][01]
		ENDIF
		IF nX+2 <= LEN(aETQ)
			@ nLIN,60 PSAY aETQ[nX+2][01]
		ENDIF

		nLIN := nLIN + 1

		@ nLIN,4 PSAY aETQ[nX][02]+" - "+aETQ[nX][03]
		IF nX+1 <= LEN(aETQ)
			@ nLIN,32 PSAY aETQ[nX+1][02]+" - "+aETQ[nX+1][03]
		ENDIF
		IF nX+2 <= LEN(aETQ)
			@ nLIN,60 PSAY aETQ[nX+2][02]+" - "+aETQ[nX+2][03]
		ENDIF

		nLIN := nLIN + 1

		@ nLIN,4 PSAY aETQ[nX][04] +" "+ aETQ[nX][05]
		IF nX+1 <= LEN(aETQ)
			@ nLIN,32 PSAY aETQ[nX+1][04] +" "+ aETQ[nX+1][05]
		ENDIF
		IF nX+2 <= LEN(aETQ)
			@ nLIN,60 PSAY aETQ[nX+2][04] +" "+ aETQ[nX+2][05]
		ENDIF

		nLIN := nLIN + 1

		@ nLIN,4 PSAY aETQ[nX][06]
		IF nX+1 <= LEN(aETQ)
			@ nLIN,32 PSAY aETQ[nX+1][06]
		ENDIF
		IF nX+2 <= LEN(aETQ)
			@ nLIN,60 PSAY aETQ[nX+2][06]
		ENDIF

		DO CASE
		CASE NCONT ==1
			NLIN :=9
		CASE NCONT ==2
			NLIN :=15
		CASE NCONT ==3
			NLIN :=22
		CASE NCONT ==4
			NLIN :=28
		CASE NCONT ==5
			NLIN :=34
		CASE NCONT ==6
			NLIN :=40
		CASE NCONT ==7
			NLIN :=47
		CASE NCONT ==8
			NLIN :=53
		CASE NCONT ==9
			NLIN :=59
		CASE NCONT >=10
			NCONT:=0
			NLIN :=3
		ENDCASE

		nX	 := nX + 2
	NEXT

	IF aReturn[5] == 1
		Set Printer To
		Commit
		ourspool(wnrel) //Chamada do Spool de Impressao
	ENDIF

	MS_FLUSH() //Libera fila de relatorios em spool

RETURN
	*----------------------------------------------------------------------------*

	*----------------------------------------------------------------------------*
STATIC Function FATETQ2B()
	*----------------------------------------------------------------------------*
	LOCAL nX   	 := 1
	LOCAL cPorta :='LPT1'
	Local nCount := 1
	Local nPedAtu := ''
	Local cNoReSNF   := AllTrim(SuperGetMv("OM_NORESNF",,"R"))

	FOR nX := 1 TO LEN(aETQ)

		nPosPed    := aScan(aPED,{|x| x[1]==aETQ[nX][04]})

		If nPosPed > 0
			aPed[nPosPed][3] := aPed[nPosPed][3] + 1
			cEtiq := Alltrim(Str(aPed[nPosPed][3]))+ '/' + Alltrim(Str(aPed[nPosPed][2]))
		Else
			cEtiq := ''
		EndIf

		MSCBPRINTER("ZEBRA",cPorta,20,300,.F.,,,,,,.T.) // SETA IMPRESSORA ZEBRA ZPL
		MSCBBEGIN(1,6)
		MSCBBOX(1,1,31,20,04,"B")
		If AllTrim(aETQ[nX][08]) $ cNoReSNF .Or. Empty(aETQ[nX][01]) //Nota Fiscal Nao reservada imprime pedido.
			MSCBSAY(02,03 ,aETQ[nX][09]                                         ,"N","0","55,55")
			MSCBSAY(02,07 ,"Rot. "+AllTrim(aETQ[nX][02]) + " - " + aETQ[nX][03] ,"N","0","55,55")
			MSCBSAY(02,11 ,aETQ[nX][10] + ": " + SubStr(aETQ[nX][11],1, 20) 	,"N","H","015")
			MSCBSAY(02,13 ,"Placa: "+ aETQ[nX][05]					            ,"N","H","015")
			MSCBSAY(02,15 ,aETQ[nX][06]                                         ,"N","H","015")
			MSCBSAY(02,17 ,cEtiq                                        	 	,"N","H","018")
		Else
			MSCBSAY(02,02 ,aETQ[nX][01]                                         ,"N","G","015")
			MSCBSAY(02,05 ,aETQ[nX][10] + " - " + SubStr(aETQ[nX][11],1, 20)    ,"N","H","015")
			MSCBSAY(02,08 ,"Rot. "+aETQ[nX][02]+" - "+aETQ[nX][03]              ,"N","H","015")
			MSCBSAY(02,11 ,"Ped. "+aETQ[nX][04] +" "+ aETQ[nX][05]              ,"N","H","015")
			MSCBSAY(02,14 ,aETQ[nX][06]                                         ,"N","H","015")
			MSCBSAY(02,17 ,cEtiq                                 				,"N","H","018")
		EndIf

		//MSCBSAY(02,13 ,aETIQUETA[nX][08]+aETIQUETA[nX][06]     ,"N","G","030")
		//MSCBSAY(02,16 ,aETIQUETA[nX][07]                       ,"N","G","030")
		//MSCBLineH(01,05.5,33.5,1) //Horizontal 1
		MSCBEND()
		MSCBCLOSEPRINTER()
	NEXT nX

RETURN
	*----------------------------------------------------------------------------*

	*----------------------------------------------------------------------------*
STATIC FUNCTION FAT002F() // zera volume
	*----------------------------------------------------------------------------*
	MsAguarde( { || FAT002F2() } , "Aguarde..." )
RETURN

	*----------------------------------------------------------------------------*
STATIC FUNCTION FAT002F2()
	*----------------------------------------------------------------------------*

	Local nX :=0
	Local nY :=0

	IF MSGYESNO('Zera Coluna de Volume ?','Atenção')
		IF MSGNOYES('Zera Coluna de Volume ?','Atenção')

			For nX := 1 to len(oGetDados:ACOLS)
				IF EMPTY(oGETDADOS:aCOLS[nX][P1_LOTE])  //LOTE
					oGETDADOS:aCOLS[nX][P1_VOLUME] := 0
				ENDIF
			Next

			// aCOLS2 :=aCOLS
			aCOLS := AClone( oGetDados:ACOLS )
			oGetDados:oBrowse:Refresh()
		ENDIF
	ENDIF
	IF LEN(oGetDados:ACOLS) >0
		aCOLS2 := AClone( aCOLS )
		oGetDados:ACOLS := AClone( aCOLS2 )
		oGetDados:oBrowse:Refresh()

		SZ6->(DBSELECTAREA('SZ6'))
		SZ6->(DBSETORDER(3))//NUMERO+CLIENTE+LOJA+PRODUTO

		FOR nY :=1 TO LEN(oGetDados:ACOLS)
			SZ6->(DBSEEK(xFILIAL('SZ6')+aCOLS[nY][P1_PEDIDO]+SUBSTR(aCOLS[nY][P1_IDCLIE],1,6)+SUBSTR(aCOLS[nY][P1_IDCLIE],8,2)+aCOLS[nY][P1_PRODUTO]))
			IF SZ6->(FOUND())
				DO WHILE .NOT. SZ6->(EOF()) .AND.  SZ6->Z6_FILIAL==xFILIAL('SZ6') .AND.;
						SZ6->Z6_NUM     == aCOLS[nY][P1_PEDIDO]             .AND.  ;
						SZ6->Z6_CLI     == SUBSTR(aCOLS[nY][P1_IDCLIE],1,6) .AND.  ;
						SZ6->Z6_LOJA    == SUBSTR(aCOLS[nY][P1_IDCLIE],8,2) .AND.  ;
						SZ6->Z6_PRODUTO == aCOLS[nY][P1_PRODUTO]

					IF SZ6->Z6_ITEM == aCOLS[nY][P1_ITEM]
						SZ6->(RECLOCK('SZ6',.F.))
						SZ6->Z6_OMAVOL   :=oGetDados:aCOLS[nY][P1_VOLUME]
						SZ6->(MSUNLOCK())
					ENDIF
					SZ6->(DBSKIP())
				ENDDO
			ELSE
				MSGALERT('MSG 000001A','MSG')
			ENDIF
		NEXT
		oGetDados:oBrowse:Refresh()
	ENDIF

RETURN


USER FUNCTION EXPALERT(eTIPE,eCAB,eMEN1,eMEN2,eMEN3,eMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

	LOCAL   enOPC1 :=1
	PRIVATE oEXP
	DEFINE  FONT oFontX1    NAME "Arial" SIZE 0,-20 BOLD
	DEFINE  FONT oFontX2    NAME "Arial" SIZE 0,-35 BOLD

	DEFINE MSDIALOG oEXP TITLE OemToAnsi(eCAB)  From nP1,nP2 To nP3,nP4 OF oFolder:aDialogs[2] PIXEL//OF oMainWnd PIXEL

	@ 35,018 Say OEMTOANSI(eMEN1) OF oEXP PIXEL COLOR CLR_BLUE FONT oFontX1
	@ 50,018 Say OEMTOANSI(eMEN2) OF oEXP PIXEL COLOR CLR_BLUE FONT oFontX1
	@ 65,018 Say OEMTOANSI(eMEN3) OF oEXP PIXEL SIZE 280,050 COLOR CLR_RED  FONT oFontX1
	@ 80,018 Say OEMTOANSI(eMEN4) OF oEXP PIXEL SIZE 280,050 COLOR CLR_RED  FONT oFontX2

//IF eTIPE='S'
//   DEFINE SBUTTON FROM 080, 010 TYPE 1 ACTION (enOPC1 := 1,oEXP:End()) ENABLE OF oEXP
	DEFINE SBUTTON FROM 500, 500 TYPE 2 ACTION (enOPC1 := 1,oEXP:End()) ENABLE OF oEXP  FONT oFontX1 //COLOR CLR_BLUE
//ENDIF


	ACTIVATE MSDIALOG oEXP  ON INIT EnchoiceBar(oEXP ,{||enOPC1:=1, oEXP:End() },{||enOPC1:=2, oEXP:End() }) CENTERED

	IF enOPC1==1
		lEXPALERT :=.T.
		RETURN
	ENDIF

	IF enOPC1==2
		lEXPALERT :=.F.
		RETURN
	ENDIF

RETURN

USER FUNCTION PFldVol1(aGets,aObjetos)
	Local nX
	aCOLS2 := AClone( aCOLS )
	oGetDados:ACOLS := AClone( aCOLS2 )
	oGetDados:aCOLS[n][P1_VOLUME]:=M->VOLUME
	If oGetDados:ACOLS[n][P1_DELETE] .AND. oGetDados:aCOLS[n][P1_VOLUME] < oGetDados:aCOLS[n][P1_QTDEP]
		oGetDados:ACOLS[n][P1_DELETE] := .F.
	Endif

	nTOTVOL:=0
	FOR nX := 1 TO LEN(aCOLS2)
		IF nX==n
			nTOTVOL :=nTOTVOL+M->VOLUME
		ELSE
			nTOTVOL :=nTOTVOL+ACOLS2[nX][P1_VOLUME]
		ENDIF
	NEXT
	oTOTVOL:REFRESH()
	aCOLS := AClone( oGetDados:ACOLS )
	oGetDados:oBrowse:Refresh()
	U_FATGRV1(oGetDados,'1')
RETURN .T.







STATIC FUNCTION LER_LOTE(oGetDados)

	LOCAL _nOPC1 := 1

	LOCAL cLOTEL01    :=SPACE(27)
	LOCAL cLOTEL02    :=SPACE(27)
	LOCAL cLOTEL03    :=SPACE(27)
	LOCAL cLOTEL04    :=SPACE(27)
	LOCAL cLOTEL05    :=SPACE(27)
	LOCAL cLOTEL06    :=SPACE(27)
	LOCAL cLOTEL07    :=SPACE(27)
	LOCAL cLOTEL08    :=SPACE(27)
	LOCAL cLOTEL09    :=SPACE(27)
	LOCAL cLOTEL10    :=SPACE(27)

	Private oNCS01    :=SPACE(06)
	Private oNCS02    :=SPACE(06)
	Private oNCS03    :=SPACE(06)
	Private oNCS04    :=SPACE(06)
	Private oNCS05    :=SPACE(06)
	Private oNCS06    :=SPACE(06)
	Private oNCS07    :=SPACE(06)
	Private oNCS08    :=SPACE(06)
	Private oNCS09    :=SPACE(06)
	Private oNCS10    :=SPACE(06)
	Private oTOTML    :=0
	Private oTOTML2   :=0
	Private oTOTQDL   :=0

	Private cNCS01    :=SPACE(06)
	Private cNCS02    :=SPACE(06)
	Private cNCS03    :=SPACE(06)
	Private cNCS04    :=SPACE(06)
	Private cNCS05    :=SPACE(06)
	Private cNCS06    :=SPACE(06)
	Private cNCS07    :=SPACE(06)
	Private cNCS08    :=SPACE(06)
	Private cNCS09    :=SPACE(06)
	Private cNCS10    :=SPACE(06)
	Private nTOTML    :=nTOTL
	Private nTOTML2   :=nTOT
	Private nTOTQDL   :=nTOT

	Private _cPROD    := cPROD
	Private _cCLIE    := cCLIE
	Private _cPedven  := cPedven
	Private _cDESCI   := cDESCI

	PRIVATE nNCSCOUNT :=0

	n :=oGetDados:oBrowse:nAt

	IF EMPTY(oGetDados:ACOLS[n][P1_PEDIDO])
		return(.t.)
	ENDIF
	_QTDE   :=oGetDados:ACOLS[n][P1_QTDEP]
	_PESO   :=oGetDados:ACOLS[n][P1_PESOP]
	nTOTQDL :=oGetDados:aCOLS[n][P1_QTDED]

	cMessage :='ENTRADA CODIGO DE BARRAS LOTE VIF' //'  '+alltrim(oGetDados:aCOLS[n][P1_PRODUTO])+'-'+posicione('SB1',1,xFILIAL('SB1')+oGetDados:aCOLS[n][P1_PRODUTO],'B1_DESC')

//IF !EMPTY(cCodBar2)
//  cLOTEL01    :=cCodBar2
//ENDIF

	DEFINE MSDIALOG oDlgL FROM 0,0 TO 340,950 TITLE OemToAnsi(cMessage) OF oMainWnd PIXEL

	nLin:=05

	@ 06,005 SAY   "Produto"   Of oDlgL  PIXEL SIZE 55 ,9  FONT oFontBRW3
	@ 05,060 MSGET _cPROD      PICTURE PesqPict('SB1','B1_DESC')    OF oDlgL PIXEL COLOR CLR_BLUE FONT oFontBRW  When .F. SIZE 300,09

	@ 06,380 SAY   "Qtde"      Of oDlgL  PIXEL SIZE 55 ,9  FONT oFontBRW3
	@ 05,420 SAY  _QTDE        PICTURE "@E 9,999,999.999"   OF oDlgL PIXEL COLOR CLR_BLUE FONT oFontBRW4  SIZE 080,09
	@ 18,380 SAY   "Peso"      Of oDlgL  PIXEL SIZE 55 ,9 FONT oFontBRW3
	@ 17,420 SAY  _PESO        PICTURE "@E 9,999,999.999"   OF oDlgL PIXEL COLOR CLR_BLUE FONT oFontBRW4  SIZE 080,09


	@ 18,005 SAY   "Cliente"   Of oDlgL  PIXEL SIZE 55 ,9 FONT oFontBRW3
	@ 17,060 MSGET _cCLIE      PICTURE PesqPict('SA1','A1_NOME')    OF oDlgL PIXEL COLOR CLR_BLUE FONT oFontBRW  When .F. SIZE 300,09

	@ 30,005 SAY   "Pedido"    Of oDlgL  PIXEL SIZE 55 ,9 FONT oFontBRW3
	@ 29,060 MSGET _cPedven    PICTURE PesqPict('SB1','B1_DESC')    OF oDlgL PIXEL COLOR CLR_BLUE FONT oFontBRW4 When .F. SIZE 300,09

	@ 42,005 SAY   "Obs. Item"  Of oDlgL  PIXEL SIZE 55 ,9 FONT oFontBRW3
	@ 41,060 MSGET _cDESCI      PICTURE PesqPict('SB1','B1_DESC')    OF oDlgL PIXEL COLOR CLR_RED  FONT oFontBRW2 When .F. SIZE 300,09

	nLin:=60
	@ nLin,005 MSGET oLOTEL01  VAR cLOTEL01  WHEN(.T.) VALID(MLOTE2(M->cLOTEL01,'01'))   OF oDlgL PIXEL SIZE 130,010 FONT oFontBRW4
	@ nLin,140 MSGET oNCS01    VAR cNCS01    WHEN(.F.)                                   OF oDlgL PIXEL SIZE 085,010 FONT oFont  COLOR CLR_BLUE
	nLin := nLin+13
	@ nLin,005 MSGET oLOTEL02  VAR cLOTEL02  WHEN(.T.) VALID(MLOTE2(M->cLOTEL02,'02'))   OF oDlgL PIXEL SIZE 130,010 FONT oFontBRW4
	@ nLin,140 MSGET oNCS02    VAR cNCS02    WHEN(.F.)                                   OF oDlgL PIXEL SIZE 085,010 FONT oFont  COLOR CLR_BLUE
	nLin := nLin+13
	@ nLin,005 MSGET oLOTEL03  VAR cLOTEL03  WHEN(.T.) VALID(MLOTE2(M->cLOTEL03,'03'))   OF oDlgL PIXEL SIZE 130,010 FONT oFontBRW4
	@ nLin,140 MSGET oNCS03    VAR cNCS03    WHEN(.F.)                                   OF oDlgL PIXEL SIZE 085,010 FONT oFont  COLOR CLR_BLUE
	nLin := nLin+13
	@ nLin,005 MSGET oLOTEL04  VAR cLOTEL04  WHEN(.T.) VALID(MLOTE2(M->cLOTEL04,'04'))   OF oDlgL PIXEL SIZE 130,010 FONT oFontBRW4
	@ nLin,140 MSGET oNCS04    VAR cNCS04    WHEN(.F.)                                   OF oDlgL PIXEL SIZE 085,010 FONT oFont  COLOR CLR_BLUE
	nLin := nLin+13
	@ nLin,005 MSGET oLOTEL05  VAR cLOTEL05  WHEN(.T.) VALID(MLOTE2(M->cLOTEL05,'05'))   OF oDlgL PIXEL SIZE 130,010 FONT oFontBRW4
	@ nLin,140 MSGET oNCS05    VAR cNCS05    WHEN(.F.)                                   OF oDlgL PIXEL SIZE 085,010 FONT oFont  COLOR CLR_BLUE
	nLin := 60
	@ nLin,255 MSGET oLOTEL06  VAR cLOTEL06  WHEN(.T.) VALID(MLOTE2(M->cLOTEL06,'06'))   OF oDlgL PIXEL SIZE 130,010 FONT oFontBRW4
	@ nLin,390 MSGET oNCS06    VAR cNCS06    WHEN(.F.)                                   OF oDlgL PIXEL SIZE 085,010 FONT oFont  COLOR CLR_BLUE
	nLin := nLin+13
	@ nLin,255 MSGET oLOTEL07  VAR cLOTEL07  WHEN(.T.) VALID(MLOTE2(M->cLOTEL07,'07'))   OF oDlgL PIXEL SIZE 130,010 FONT oFontBRW4
	@ nLin,390 MSGET oNCS07    VAR cNCS07    WHEN(.F.)                                   OF oDlgL PIXEL SIZE 085,010 FONT oFont  COLOR CLR_BLUE
	nLin := nLin+13
	@ nLin,255 MSGET oLOTEL08  VAR cLOTEL08  WHEN(.T.) VALID(MLOTE2(M->cLOTEL08,'08'))   OF oDlgL PIXEL SIZE 130,010 FONT oFontBRW4
	@ nLin,390 MSGET oNCS08    VAR cNCS08    WHEN(.F.)                                   OF oDlgL PIXEL SIZE 085,010 FONT oFont  COLOR CLR_BLUE
	nLin := nLin+13
	@ nLin,255 MSGET oLOTEL09  VAR cLOTEL09  WHEN(.T.) VALID(MLOTE2(M->cLOTEL09,'09'))   OF oDlgL PIXEL SIZE 130,010 FONT oFontBRW4
	@ nLin,390 MSGET oNCS09    VAR cNCS09    WHEN(.F.)                                   OF oDlgL PIXEL SIZE 085,010 FONT oFont  COLOR CLR_BLUE
	nLin := nLin+13
	@ nLin,255 MSGET oLOTEL10 VAR cLOTEL10  WHEN(.T.) VALID(MLOTE2(M->cLOTEL10,'10'))    OF oDlgL PIXEL SIZE 130,010 FONT oFontBRW4
	@ nLin,390 MSGET oNCS10    VAR cNCS10   WHEN(.F.)                                    OF oDlgL PIXEL SIZE 085,010 FONT oFont  COLOR CLR_BLUE

	nLin := nLin+25
	@ nLin+00,005  SAY   "Peso Total Item"   Of oDlgL  SIZE 58 ,9  PIXEL COLOR CLR_BLUE FONT oFontBRW //"Total "
	@ nLin+00,140  MSGET oTOTML   VAR nTOTML     PICTURE "@E 999,999.999"   OF oDlgL PIXEL COLOR CLR_BLUE FONT oFont    When .F. SIZE 80,09
	@ nLin+00,255 MSGET oTOTQDL  VAR nTOTQDL    PICTURE "@E 999,999"      OF oDlgL PIXEL COLOR CLR_BLUE FONT oFontGRD When .F. SIZE 130,30
	@ nLin+13,005  SAY   "Peso Total "       Of oDlgL  SIZE 58 ,9  PIXEL COLOR CLR_BLUE FONT oFontBRW //"Total "
	@ nLin+13,140  MSGET oTOTML2  VAR nTOTML2      PICTURE "@E 999,999.999"  OF oDlgL PIXEL COLOR CLR_BLUE FONT oFont   When .F. SIZE 80,09

//IF !EMPTY(cCodBar2)
//  MLOTE2(M->cLOTEL01,'01')
//ENDIF

	ACTIVATE MSDIALOG  oDlgL  CENTERED

return(.t.)


	*----------------------------------------------------------------------------*
STATIC Function MLOTE2(cLOTEVIF,cFLAGLIN)
	*----------------------------------------------------------------------------*
	nDIV      :=1
	cLOTEVIF  :=ALLTRIM(cLOTEVIF)
	cCodBar   :=ALLTRIM(cLOTEVIF)
	n         :=oGetDados:oBrowse:nAt

	cNCS      :=SUBSTR(ALLTRIM(cLOTEVIF),11,06)
	nNCSCOUNT :=nNCSCOUNT+1
	ATUNCS(cFLAGLIN)

//002,001234560123456 150
//IF SUBSTR(ALLTRIM(cLOTEVIF),04,01) <>',' .or.  SUBSTR(ALLTRIM(cLOTEVIF),20,01) <>' '
//	MSGALERT('Problema na leitura do Codigo de Barra '+cLOTEVIF+ ' ' +Chr(13)+Chr(10)+;
//	'Selecionar outro código de barra, ou tente novamente. ')
//	Return("")
//ENDIF

	IF SUBSTR(ALLTRIM(cLOTEVIF),04,01) <>','// .or.  SUBSTR(ALLTRIM(cLOTEVIF),20,01) <>' '
		cTIPE :='N'
		cTIT  :='Mensagem'
		cMEN1 :='Problema na leitura do Codigo de Barra '+cLOTEVIF+ ' '
		cMEN2 :='Selecionar outro código de barra, ou tente novamente. '
		cMEN3 :=''
		cMEN4 :=''
		nP1   :=135
		nP2   :=0
		nP3   :=300
		nP4   :=700
		// U_DoneBeep('UTOPIAEX.WAV')
		U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

		//IF lEXPALERT ==.F.
		cNCS      :=cNCS+'ERRO '
		nNCSCOUNT :=nNCSCOUNT-1
		ATUNCS(cFLAGLIN)
		Return("")
		//ENDIF
	ENDIF

	If Len(AllTrim(cLoteVIF)) == 26

		*--------PESO--------------
		cPESO     :=SUBSTR(ALLTRIM(cLOTEVIF),01,03)+'.'+SUBSTR(ALLTRIM(cLOTEVIF),05,03)
		nPESO     :=VAL(SUBSTR(ALLTRIM(cPESO),01,07))
		*--------PECA--------------
		cPECA     :=SUBSTR(ALLTRIM(cLOTEVIF),08,03)
		nPECA     :=VAL(SUBSTR(ALLTRIM(cPECA),01,03))
		*----------------------
		cNCS      :=SUBSTR(ALLTRIM(cLOTEVIF),11,06)
		cLOTE     :=SUBSTR(ALLTRIM(cLOTEVIF),17,07)
		cVALIDADE :=SPACE(10)
		//cPRODUTO  :=SUBSTR(ALLTRIM(cLOTEVIF),24,03)  // TAMANHO 26+ENTER =27
		cPRODUTO  :=SUBSTR(ALLTRIM(cLOTEVIF),24,Len(cLoteVif))  // TAMANHO 26+ENTER =27
		cProduto := AllTrim(cProduto)

	Else
		*--------PESO--------------
		cPESO     :=SUBSTR(ALLTRIM(cLOTEVIF),01,03)+'.'+SUBSTR(ALLTRIM(cLOTEVIF),05,03)
		nPESO     :=VAL(SUBSTR(ALLTRIM(cPESO),01,07))
		*--------PECA--------------
		cPECA     :=SUBSTR(ALLTRIM(cLOTEVIF),08,03)
		nPECA     :=VAL(SUBSTR(ALLTRIM(cPECA),01,03))
		*----------------------
		cNCS      :=SUBSTR(ALLTRIM(cLOTEVIF),11,06)
		cLOTE     :=SUBSTR(ALLTRIM(cLOTEVIF),17,07)
		cVALIDADE := SUBSTR(ALLTRIM(cLOTEVIF),24,08)
		//cPRODUTO  :=SUBSTR(ALLTRIM(cLOTEVIF),24,03)  // TAMANHO 26+ENTER =27
		cPRODUTO  :=SUBSTR(ALLTRIM(cLOTEVIF),32,Len(cLoteVif))  // TAMANHO 26+ENTER =27
		cProduto := AllTrim(cProduto)
	EndIf


	_QTDEP := oGetDados:ACOLS[n][P1_QTDEP]
	_PESOP := oGetDados:ACOLS[n][P1_PESOP]
	_QTDED := oGetDados:aCOLS[n][P1_QTDED]
	_PESOD := oGetDados:aCOLS[n][P1_PESOD]


	IF EMPTY(oGetDados:aCOLS[n][P1_LOTE])
		nSALDO := _QTDEP
	ELSE
		nSALDO := _QTDEP -_QTDED
	ENDIF


	SB1->(DBSELECTAREA('SB1'))
	SB1->(DBSETORDER(1))


	IF SB1->(DBSEEK(xFILIAL('SB1')+cPRODUTO))

		//	nQE     := SB1->B1_QE
		//	nPSMIN  := (SB1->B1_PESOMIN)*(SB1->B1_QE)
		//	nPSMAX  := (SB1->B1_PESOMAX)*(SB1->B1_QE)

		nPSMIN  := (SB1->B1_PESOMIN)* nPECA
		nPSMAX  := (SB1->B1_PESOMAX)* nPECA

		cTPDESP := SB1->B1_TPDESP
		_DESCP  := SB1->B1_DESC



//	nQE     := SB1->B1_QE
//	nPSMIN  := (SB1->B1_PESOMIN)*(SB1->B1_QE)
//	nPSMAX  := (SB1->B1_PESOMAX)*(SB1->B1_QE)
//	cTPDESP := SB1->B1_TPDESP
//	_DESCP  := SB1->B1_DESC
	ELSE
		nQE  := 1
		nPSMIN  := 0
		nPSMAX  := 0
		cTPDESP := SPACE(15)
		_DESCP  := SPACE(15)
	ENDIF


	nQE :=nPECA

/*
	DO CASE
	CASE nQE > 1
		IF nSALDO >= nQE
_LTPCAIXA :=.T.
		ELSE
_LTPCAIXA :=.F.
		ENDIF
	CASE nQE < 1
nQE :=1
_LTPCAIXA :=.T.
	CASE nQE ==1
_LTPCAIXA :=.T.
	ENDCASE
*/
/*
	IF _LTPCAIXA ==.F.
nQE     := SB1->B1_QE
nPSMIN  := (SB1->B1_PESOMIN)// /nQE
nPSMAX  := (SB1->B1_PESOMAX)// /nQE
nQE     := 1
	ENDIF
*/

	IF ALLTRIM(oGetDados:ACOLS[n][P1_PRODUTO])<>ALLTRIM(cPRODUTO)
		//	MSGALERT('Produto diferente do Pedido')
		//	Return("")
		cTIPE :='N'
		cTIT  :='Mensagem'
		cMEN1 :='Produto diferente do Pedido'
		cMEN2 :=''
		cMEN3 :=''
		cMEN4 :=''
		nP1   :=135
		nP2   :=0
		nP3   :=300
		nP4   :=700
		// U_DoneBeep('UTOPIAEX.WAV')
		U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

		//IF lEXPALERT ==.F.
		cNCS      :=cNCS+'ERRO '
		nNCSCOUNT :=nNCSCOUNT-1
		ATUNCS(cFLAGLIN)
		Return("")
		//ENDIF
	ENDIF

//1a Chamada
	IF nPESO < nPSMIN
		//	IF !MSGYESNO('Peso minimo do cadastro '+LTRIM(TransForm(nPSMIN,'@E 999,999,999.999')) + ' ' +Chr(13)+Chr(10)+;
			//		'Peso da Etiqueta        '+LTRIM(TransForm(nPESO ,'@E 999,999,999.999')) +' Confirma  ?')
		//		Return("")
		//	ENDIF
		cTIPE :='N'
		cTIT  :='Mensagem 1/2'
		cMEN1 :='Peso minimo do cadastro '+LTRIM(TransForm(nPSMIN,'@E 999,999,999.999')) + ' '
		cMEN2 :='Peso da Etiqueta        '+LTRIM(TransForm(nPESO ,'@E 999,999,999.999')) +' Confirma  ?'
		cMEN3 :='Quantidade '+LTRIM(TransForm(nQE ,'@E 999,999,999.999')) +' Pcs por Embalagem '
		cMEN4 :='DIFERENÇA    '+LTRIM(TransForm(nPESO-nPSMIN,'@E 999,999,999.999')) + ' Kg'
		nP1   :=135
		nP2   :=0
		nP3   :=400
		nP4   :=600
		// U_DoneBeep('UTOPIAEX.WAV')
		U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

		IF lEXPALERT ==.F.
			cNCS      :=cNCS+'ERRO '
			nNCSCOUNT :=nNCSCOUNT-1
			ATUNCS(cFLAGLIN)
			Return("")
		ENDIF
	ENDIF

//2a Chamada
	IF nPESO < nPSMIN
		//	IF !MSGYESNO('Peso minimo do cadastro '+LTRIM(TransForm(nPSMIN,'@E 999,999,999.999')) + ' ' +Chr(13)+Chr(10)+;
			//		'Peso da Etiqueta        '+LTRIM(TransForm(nPESO ,'@E 999,999,999.999')) +' Confirma  ?')
		//		Return("")
		//	ENDIF
		cTIPE :='N'
		cTIT  :='Mensagem 2/2'
		cMEN1 :='Peso minimo do cadastro '+LTRIM(TransForm(nPSMIN,'@E 999,999,999.999')) + ' '
		cMEN2 :='Peso da Etiqueta        '+LTRIM(TransForm(nPESO ,'@E 999,999,999.999')) +' Confirma  ?'
		cMEN3 :='Quantidade '+LTRIM(TransForm(nQE ,'@E 999,999,999.999')) +' Pcs por Embalagem '
		cMEN4 :='DIFERENÇA    '+LTRIM(TransForm(nPESO-nPSMIN,'@E 999,999,999.999')) + ' Kg'
		nP1   :=135
		nP2   :=0
		nP3   :=400
		nP4   :=600
		// U_DoneBeep('UTOPIAEX.WAV')
		U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

		IF lEXPALERT ==.F.
			cNCS      :=cNCS+'ERRO '
			nNCSCOUNT :=nNCSCOUNT-1
			ATUNCS(cFLAGLIN)
			Return("")
		ENDIF
	ENDIF



//1a Chamada
	IF nPESO > nPSMAX
		//	IF !MSGYESNO('Peso Maximo do cadastro '+LTRIM(TransForm(nPSMAX,'@E 999,999,999.999')) + ' ' +Chr(13)+Chr(10)+;
			//		'Peso da Etiqueta        '+LTRIM(TransForm(nPESO ,'@E 999,999,999.999')) +' Confirma  ?')
		//		Return("")
		//	ENDIF
		cTIPE :='N'
		cTIT  :='Mensagem 1/2'
		cMEN1 :='Peso Maximo do cadastro '+LTRIM(TransForm(nPSMAX,'@E 999,999,999.999')) + ' '
		cMEN2 :='Peso da Etiqueta        '+LTRIM(TransForm(nPESO ,'@E 999,999,999.999')) +' Confirma  ?'
		cMEN3 :='Quantidade '+LTRIM(TransForm(nQE ,'@E 999,999,999.999')) +' Pcs por Embalagem '
		cMEN4 :='DIFERENÇA    '+LTRIM(TransForm(nPESO-nPSMAX,'@E 999,999,999.999')) + ' Kg'
		nP1   :=135
		nP2   :=0
		nP3   :=400
		nP4   :=600
		// U_DoneBeep('UTOPIAEX.WAV')
		U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

		IF lEXPALERT ==.F.
			cNCS      :=cNCS+'ERRO '
			nNCSCOUNT :=nNCSCOUNT-1
			ATUNCS(cFLAGLIN)
			Return("")
		ENDIF
	ENDIF

//2a Chamada
	IF nPESO > nPSMAX
		//	IF !MSGYESNO('Peso Maximo do cadastro '+LTRIM(TransForm(nPSMAX,'@E 999,999,999.999')) + ' ' +Chr(13)+Chr(10)+;
			//		'Peso da Etiqueta        '+LTRIM(TransForm(nPESO ,'@E 999,999,999.999')) +' Confirma  ?')
		//		Return("")
		//	ENDIF
		cTIPE :='N'
		cTIT  :='Mensagem 2/2'
		cMEN1 :='Peso Maximo do cadastro '+LTRIM(TransForm(nPSMAX,'@E 999,999,999.999')) + ' '
		cMEN2 :='Peso da Etiqueta        '+LTRIM(TransForm(nPESO ,'@E 999,999,999.999')) +' Confirma  ?'
		cMEN3 :='Quantidade '+LTRIM(TransForm(nQE ,'@E 999,999,999.999')) +' Pcs por Embalagem '
		cMEN4 :='DIFERENÇA    '+LTRIM(TransForm(nPESO-nPSMAX,'@E 999,999,999.999')) + ' Kg'
		nP1   :=135
		nP2   :=0
		nP3   :=400
		nP4   :=600
		// U_DoneBeep('UTOPIAEX.WAV')
		U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

		IF lEXPALERT ==.F.
			cNCS      :=cNCS+'ERRO '
			nNCSCOUNT :=nNCSCOUNT-1
			ATUNCS(cFLAGLIN)
			Return("")
		ENDIF
	ENDIF



	nQtde     :=0
	nTOTLTMP  :=0

	SZ7->(DBSELECTAREA('SZ7'))
	SZ7->(DBSETORDER(1))
	SZ7->(DBSEEK(xFILIAL('SZ7')+cLOTEVIF))

	IF SZ7->(FOUND()) .AND. !EMPTY(cLOTEVIF)
		//	MSGALERT('Codigo de Barra '+cLOTEVIF+ ' Já despachado ' +Chr(13)+Chr(10)+;
			//	'Selecionar outro código de barra ')
		//	Return("")
		cTIPE :='N'
		cTIT  :='Mensagem'
		cMEN1 :='Codigo de Barra '+cLOTEVIF+ ' Já despachado '
		cMEN2 :='Selecionar outro código de barra '
		cMEN3 :=''
		cMEN4 :=''
		nP1   :=135
		nP2   :=0
		nP3   :=300
		nP4   :=700
		// U_DoneBeep('UTOPIAEX.WAV')
		U_EXPALERT(cTIPE,cTIT,cMEN1,cMEN2,cMEN3,cMEN4,nP1,nP2,nP3,nP4)//lEXPALERT :=.T.

		//IF lEXPALERT ==.F.
		cNCS      :=cNCS+'ERRO '
		nNCSCOUNT :=nNCSCOUNT-1
		ATUNCS(cFLAGLIN)
		Return("")
		//ENDIF

	ENDIF
	nQtde:= nQE
//DO CASE
//	CASE SUBSTR(cPRODUTO,1,3) $('900|919|904|274')
//		nQtde:=4
//	OTHERWISE
//		nQtde:=1
//ENDCASE


//cTPDESP :=POSICIONE('SB1',1,xFILIAL('SB1')+cPRODUTO+SPACE(12),'B1_TPDESP')

	IF cTPDESP=='2'

		_DESCP   :=POSICIONE('SB1',1,xFILIAL('SB1')+cPRODUTO+SPACE(12),'B1_DESC')

		_PRODUTO :=cPRODUTO+'-'+_DESCP
		_PLOTE   :=nPESO
		_PREAL   := 0
		_LOOP    :=.T.
		_nOPC1   :=2

		DO WHILE _LOOP
			DEFINE MSDIALOG oDlg2 FROM 0,0 TO 200,400 TITLE OemToAnsi("Item a Granel") OF oMainWnd PIXEL

			nLin:=18
			@ nLin,10 SAY OemToAnsi("ITEM A GRANEL") OF oDlg2 PIXEL COLOR CLR_RED  FONT oFontBRW SIZE 120,010
			nLin := nLin+18
			@ nLin,10 SAY OemToAnsi("Produto ")      OF oDlg2 PIXEL SIZE 040,010 FONT oFontBRW3
			@ nLin,50 MSGET _PRODUTO   WHEN(.F.)     OF oDlg2 PIXEL SIZE 130,005 FONT oFontBRW3
			nLin := nLin+12
			@ nLin,10 SAY OemToAnsi("Peso Lote")     OF oDlg2 PIXEL SIZE 040,010 FONT oFontBRW3
			@ nLin,50 MSGET  _PLOTE    WHEN(.F.)     PICTURE "@E 999,999.999" OF oDlg2 PIXEL SIZE 060,005 FONT oFontBRW3
			nLin := nLin+12
			@ nLin,10 SAY OemToAnsi("PESO REAL")     OF oDlg2 PIXEL SIZE 040,010 COLOR CLR_RED  FONT oFontBRW3
			@ nLin,50 MSGET _PREAL     WHEN(.T.)     PICTURE "@E 999,999.999"  OF oDlg2 PIXEL SIZE 060,005 COLOR CLR_RED  FONT oFontBRW3

			DEFINE SBUTTON FROM 080, 010 TYPE 1 ACTION (_nOPC1 := 1,oDlg2:End()) ENABLE OF oDlg2
			ACTIVATE MSDIALOG  oDlg2 ON INIT EnchoiceBar(oDlg2,{||_nOPC1:=1,oDlg2:End() },{||_NOPC1:=2,oDlg2:End() }) CENTERED

			IF _nOPC1==1
				IF _PREAL <=0
					MSGALERT('Peso Real nao pode ser Zero ' +Chr(13)+Chr(10)+;
						'Preencha o Peso Real do produto ')
					_LOOP :=.T.
				ELSE
					_LOOP :=.F.
					nPESO :=_PREAL
				ENDIF
			ENDIF
			IF _nOPC1==2
				_LOOP :=.T.
				Return("")
			ENDIF
		ENDDO

	ENDIF

	nTOTLTMP  :=nTOTL
	nTOTL     :=nTOTL+nPESO

	nVOLUME :=oGetDados:aCOLS[n][P1_VOLUME] + nQtde

	DO CASE
	CASE oGetDados:aCOLS[n][P1_QTDEP]==0 .AND. oGetDados:aCOLS[n][P1_PESOP]<>0
		IF nTOTL >(oGetDados:aCOLS[n][P1_PESOP])
			/*  RETIRADO EM 17/09/2008 POR EDSON
			IF !MSGYESNO('Peso total maior que peso do pedido ' +Chr(13)+Chr(10)+;
			'Peso Pedido  : ' +LTRIM(TransForm(aCOLS[n][P1_PESOP]       ,'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
			'Peso Produto : ' +LTRIM(TransForm(nTOTL             ,'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
			'Diferença    : ' +LTRIM(TransForm(nTOTL -aCOLS[n][P1_PESOP],'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
			'Aceita ?' )
			nTOTL := nTOTLTMP
			Return("")
				ENDIF
			*/
		ENDIF

	CASE oGetDados:aCOLS[n][P1_QTDEP]<>0 .AND. oGetDados:aCOLS[n][P1_PESOP]==0

		IF EMPTY(oGetDados:aCOLS[n][P1_LOTE]) // LOTE
			nITEM :=1
		ELSE
			nITEM :=oGetDados:aCOLS[n][P1_QTDED]+nQTDE
		ENDIF

		IF nITEM >(oGetDados:aCOLS[n][P1_QTDEP])
			oDlgL:End()
			Return("")
			//IF !MSGYESNO('Quantidade total maior que quantidade do pedido ' +Chr(13)+Chr(10)+;
				//	'Qtde Pedido   : ' +LTRIM(TransForm(aCOLS[n][P1_QTDEP]       ,'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
				//	'Qtde Despacho : ' +LTRIM(TransForm(nITEM             ,'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
				//	'Diferença    : ' +LTRIM(TransForm(nITEM -aCOLS[n][P1_QTDEP],'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
				//	'Aceita ?' )
			//	nTOTL := nTOTLTMP
			//	Return("")
			//ENDIF
		ENDIF

	OTHERWISE

		IF EMPTY(oGetDados:aCOLS[n][P1_LOTE]) // LOTE
			nITEM :=1
		ELSE
			nITEM :=oGetDados:aCOLS[n][P1_QTDED]+nQTDE
		ENDIF

		IF nITEM >(oGetDados:aCOLS[n][P1_QTDEP])
			oDlgL:End()
			Return("")
			//IF !MSGYESNO('Quantidade total maior que quantidade do pedido ' +Chr(13)+Chr(10)+;
				//	'Qtde Pedido   : ' +LTRIM(TransForm(aCOLS[n][P1_QTDEP]       ,'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
				//	'Qtde Despacho : ' +LTRIM(TransForm(nITEM             ,'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
				//	'Diferença    : ' +LTRIM(TransForm(nITEM -aCOLS[n][P1_QTDEP],'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
				//	'Aceita ?' )
			//	nTOTL := nTOTLTMP
			//	Return("")
			//ENDIF
		ELSE
			IF nTOTL >(oGetDados:aCOLS[n][P1_PESOP])   //
				/*  RETIRADO EM 17
				/09/2008 POR EDSON
				IF !MSGYESNO('Peso total maior que peso do pedido ' +Chr(13)+Chr(10)+;
				'Peso Pedido  : ' +LTRIM(TransForm(aCOLS[n][P1_PESOP]       ,'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
				'Peso Produto : ' +LTRIM(TransForm(nTOTL             ,'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
				'Diferença    : ' +LTRIM(TransForm(nTOTL -aCOLS[n][P1_PESOP],'@E 999,999,999.999'))+Chr(13)+Chr(10)+;
				'Aceita ?' )
				nTOTL := nTOTLTMP
				Return("")
					ENDIF
				*/
			ENDIF
		ENDIF

	ENDCASE
	oGetDados:ACOLS[n][P1_DELETE]:=.T.

	oTOTL:REFRESH()
	oGetDados:aCOLS[n][P1_PESOD]:=nTOTL
	oGetDados:aCOLS[n][P1_LOTE]:=cNCS
	oGetDados:aCOLS[n][P1_VOLUME]:=nVOLUME
	nLSEQ  :=nLSEQ+1

	AADD(aCOLSLote,{	cCodBar			,;
		cPRODUTO		,;
		cLOTE			,;
		cVALIDADE		,;
		nQtde			,;
		nPESO			,;
		cNCS			,;
		nLSEQ			,;
		.F.				})  //.f. POSICAO 9 Flag de Delecao]

	AADD(aCOLSLT,{	cCodBar									,;
		cPRODUTO								,;
		cLOTE									,;
		cVALIDADE								,;
		nQtde									,;
		nPESO									,;
		oGetDados:aCOLS[n][P1_PEDIDO] 			,;   //pedido
	oGetDados:aCOLS[n][P1_IDCLIE] 			,;   //idclie
	oGetDados:aCOLS[n][P1_PRODUTO]			,;   //produto
	cNCS 									,;
		nLSEQ									,;
		oGetDados:aCOLS[n][P1_ITEM] 			,;
		.F.										})  //.f. POSICAO 13 Flag de Delecao]

	aCOLSLote2 := AClone( aCOLSLote )
	oMLOTE1:aCOLS := AClone( aCOLSLote2 )

	oMLOTE1:oBrowse:Refresh()
	aCols := AClone( oGetDados:aCOLS )
	oGetDados:oBrowse:Refresh()
	U_FAT002LOK(oGetDados)

	nTOTML      :=nTOTL
	nTOTML2     :=nTOT
	nTOTQDL     :=oGetDados:aCOLS[n][P1_QTDED]

	oTOTML:REFRESH()
	oTOTML2:REFRESH()
	oTOTQDL:REFRESH()
	IF nITEM==(oGetDados:aCOLS[n][P1_QTDEP])
		oDlgL:End()
	ENDIF
Return(" ")

STATIC FUNCTION ATUNCS(cFLAGLIN)

	DO CASE
	CASE cFLAGLIN='01'
		cNCS01 :=cNCS+'  '+LTRIM(TransForm(nNCSCOUNT ,'@E 999,999,999'))
		oNCS01:REFRESH()
	CASE cFLAGLIN='02'
		cNCS02 :=cNCS+'  '+LTRIM(TransForm(nNCSCOUNT ,'@E 999,999,999'))
		oNCS02:REFRESH()
	CASE cFLAGLIN='03'
		cNCS03 :=cNCS+'  '+LTRIM(TransForm(nNCSCOUNT ,'@E 999,999,999'))
		oNCS03:REFRESH()
	CASE cFLAGLIN='04'
		cNCS04 :=cNCS+'  '+LTRIM(TransForm(nNCSCOUNT ,'@E 999,999,999'))
		oNCS04:REFRESH()
	CASE cFLAGLIN='05'
		cNCS05 :=cNCS+'  '+LTRIM(TransForm(nNCSCOUNT ,'@E 999,999,999'))
		oNCS05:REFRESH()
	CASE cFLAGLIN='06'
		cNCS06 :=cNCS+'  '+LTRIM(TransForm(nNCSCOUNT ,'@E 999,999,999'))
		oNCS06:REFRESH()
	CASE cFLAGLIN='07'
		cNCS07 :=cNCS+'  '+LTRIM(TransForm(nNCSCOUNT ,'@E 999,999,999'))
		oNCS07:REFRESH()
	CASE cFLAGLIN='08'
		cNCS08 :=cNCS+'  '+LTRIM(TransForm(nNCSCOUNT ,'@E 999,999,999'))
		oNCS08:REFRESH()
	CASE cFLAGLIN='09'
		cNCS09 :=cNCS+'  '+LTRIM(TransForm(nNCSCOUNT ,'@E 999,999,999'))
		oNCS09:REFRESH()
	CASE cFLAGLIN='10'
		cNCS10 :=cNCS+'  '+LTRIM(TransForm(nNCSCOUNT ,'@E 999,999,999'))
		oNCS10:REFRESH()
	ENDCASE

RETURN

User Function vldplc(cOpt)

	if cOpt == '1'
		cPLACA2 := Upper(cPLACA2)
		oPLACA2:REFRESH()
	elseif cOpt == '2'
		cPLACA3 := Upper(cPLACA3)
		oPLACA3:REFRESH()
	endif

Return


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fDigSenha()
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	local  _lReturn := .f.
	Private cSenha   := Space(10)

//oDlg1:lEscClose     := .F. //Nao permite sair ao se pressionar a tecla ESC.
	DEFINE MsDialog Senhadlg From 067,020 To 169,312 Title OemToAnsi("Liberação de Acesso") Pixel Style DS_MODALFRAME

	Senhadlg:lEscClose     := .F. //Nao permite sair ao se pressionar a tecla ESC.

// @ 067,020 To 169,312 Dialog Senhadlg Title OemToAnsi("Liberação de Acesso")

	@ 015,005 Say OemToAnsi("Informe a senha para o acesso ?") Size 80,8
	@ 015,089 Get cSenha Size 50,10 Password
	@ 037,106 BmpButton Type 1 Action fOK(@_lReturn)
//@ 037,055 BmpButton Type 2 Action Close(Senhadlg)
	Activate MsDialog Senhadlg CENTERED
Return(_lReturn)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fOK(_lReturn)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	PRIVATE cUSRTRAN := SuperGetMV("OM_USRTRAN",.F.,"OMAMORI")
	Private cUserSys := RetCodUsr()
	PRIVATE nOpca    :=0
	PRIVATE oDlg
	PRIVATE lMsg:=.F.

	If Empty(cSenha)
		MsgStop("Senha não Confere !!!")
		cSenha  := Space(10)
		dlgRefresh(Senhadlg)
		_lReturn  := .F.
	endif

	IF ALLTRIM(cSenha) $ cUSRTRAN

		_lReturn  := .T.
		Close(Senhadlg)

	Else
		MsgStop("Senha não Confere !!!")
		cSenha  := Space(10)
		dlgRefresh(Senhadlg)
		_lReturn  := .F.
	Endif
Return(_lReturn)


/*/{Protheus.doc} FAT2LOK2
//Função para validação de Coluna
@author Manoel Nésio
@since 07/04/2020
@version undefined
@example
(examples)
@see (links_or_references)
/*/
User Function FAT2LOK2()
	oGetDados:oBrowse:bEditCol := {|| FAT2EDIT()}
Return(.t.)

Static Function FAT2EDIT()

	Local nCol1 := GdFieldPos('Z6_LOTEVIF', oGetDados:aHeader ) // Esse B1_CODBAR
	//Local nCol2 := GdFieldPos(‘B1_COD2‘, oGetDados:aHeader ) // Esse B1_CODBAR será a sua segunda coluna(mais a direita).
	Local nQtdV := GDFieldGet("QTDEP",oGetDados:nAT)
	Local nQtdD := GDFieldGet("VOLUME",oGetDados:nAT)
	Local cDNcs := GDFieldGet("NCS",oGetDados:nAT)

	If oGetDados:oBrowse:nColPos == nCol1 //.AND. ALLTRIM(cDNcs) <> ""//.and. oGetDados:nAT < Len(oGetDados:aCols)

		If (nQtdD >= nQtdV) .AND. oGetDados:nAT < Len(oGetDados:aCols)
			oGetDados:GoTo(n+1)
		EndIf

		oGetDados:oBrowse:nColPos := nCol1   //Muda a coluna para a 1
		oGetDados:Refresh() //Atualiza a Getdados
		oGetDados:oBrowse:Refresh() //Atualiza a Getdados do browse em tela.
		U_FAT002LOK(oGetDados)

	EndIf

Return(.t.)

/*/{Protheus.doc} GetQryRom
Monta Query considerando novos filtros do romaneio.
@type function
@version 1.0
@author Paulo Apolinário - Geeker Company
@since 08/03/2021
@return character, cRet - Query montada.
/*/
Static Function GetQryRom()
	Local cRet := ''

	cRet :=        " SELECT Z5_VVISTA,Z5_NUM,Z5_CLIENTE,Z5_LOJACLI,A1_NREDUZ,A1_GRPVEN,A1_ROTENTR "
	cRet += CRLF + "        , Z5_TRANSP,Z5_TRANSP2,Z5_TRANSP3,Z5_VEICULO,Z5_VEIC2,Z5_NOTA,Z5_SERIE "
	cRet += CRLF + "        , Z6_PRODUTO,Z6_UNSVEN,Z6_QTDVEN ,Z6_UM,Z6_QTDLIB2,Z6_QTDLIB,Z6_OMAVOL,Z6_OK,Z6_ITEM,Z5_CIDADE,Z5_END,A4_NOME, Z6_XPRDKIT "
	cRet += CRLF + "        , COALESCE(Z23.Z23_ID,'') Z23_ID, Z6_SALDWMS "

	cRet += CRLF + " FROM "+RetSqlName('SZ5')+" Z5 "

	cRet += CRLF + " INNER JOIN " + RetSqlName('SZ6') + " Z6 "
	cRet += CRLF + " 	ON Z6_NUM=Z5_NUM "
	cRet += CRLF + "   AND Z6_STATUS IN ('1')  "
	cRet += CRLF + "   AND Z6_ENTREG ='"+DTOS(dData1)+"'  "
	cRet += CRLF + "   AND Z6.D_E_L_E_T_=' ' "

	cRet += CRLF + " INNER JOIN " + RetSqlName('SA1') + " A1 "
	cRet += CRLF + "    ON A1_COD=Z5_CLIENTE  "
	cRet += CRLF + "   AND A1_LOJA=Z5_LOJACLI "
	cRet += CRLF + "   AND A1_XTPCLI  = '" + cFlTpCli + "'"
	cRet += CRLF + "   AND A1_EST = '" + cFtEstado + "'"
	IF !EMPTY(cZONA)
		cRet += CRLF + " AND A1_GRPVEN='"+cZONA+"'  "
	ENDIF
	cRet += CRLF + "   AND A1.D_E_L_E_T_=' ' "

	// cRet += CRLF + " INNER JOIN " + RetSQLName("ZZL") + " ZZL (NOLOCK)
	// cRet += CRLF + "    ON ZZL.ZZL_FILIAL = '" + xFilial("ZZL") + "' "
	// cRet += CRLF + "   AND ZZL.ZZL_COD = A1.A1_COD "
	// cRet += CRLF + "   AND ZZL.ZZL_LOJA = A1.A1_LOJA "
	// cRet += CRLF + "   AND ( 	  ZZL.ZZL_APTOVV = 'N' OR "
	// cRet += CRLF + "         	( ZZL.ZZL_APTOVV = 'S' AND ZZL.ZZL_VVISTA = 'N' ) OR "
	// cRet += CRLF + "         	( ZZL.ZZL_APTOVV = 'S' AND ZZL.ZZL_VVISTA = 'S' AND Z6.Z6_VVISTA = 'N' )"
	// cRet += CRLF + "       )"
	// cRet += CRLF + "   AND ZZL.D_E_L_E_T_ = '' "

	cRet += CRLF + " INNER JOIN " + RetSqlName('SA4') + " A4 "
	cRet += CRLF + "    ON A4_COD=Z5_TRANSP "
	cRet += CRLF + "   AND A4.D_E_L_E_T_=' ' "

	cRet += CRLF + " INNER JOIN " + RetSqlName('SB1') + " B1 "
	cRet += CRLF + "   ON  B1_COD=Z6_PRODUTO "
	cRet += CRLF + "   AND B1_FILIAL ='02'  "
	cRet += CRLF + "   AND B1.D_E_L_E_T_=' '  "

	If !Empty( cFtNrRom )
		cRet += CRLF + " INNER JOIN " + RetSqlName('Z23') + " Z23 "
		cRet += CRLF + "    ON Z23_FILIAL = '02'"
		cRet += CRLF + "   AND Z23_NUM = Z6.Z6_NUM "
		cRet += CRLF + "   AND Z23.D_E_L_E_T_=' '  "
		cRet += CRLF + "   AND Z23.Z23_ID = '" + cFtNrRom + "' "
	Else
		cRet += CRLF + " LEFT JOIN " + RetSqlName('Z23') + " Z23 "
		cRet += CRLF + "    ON Z23_FILIAL = '02'"
		cRet += CRLF + "   AND Z23_NUM = Z6.Z6_NUM "
		cRet += CRLF + "   AND Z23.D_E_L_E_T_=' '  "
	Endif

	cRet += CRLF + " WHERE Z5.D_E_L_E_T_=' '"
	cRet += CRLF + "   AND Z5_TRANSP='"+cTRANSP+"' "

	cRet += CRLF + "   AND CASE WHEN (Z5_XTPSHEL IS NULL OR Z5_XTPSHEL = '' ) "
	cRet += CRLF + "            THEN A1_XTPSHEL ELSE Z5_XTPSHEL END = '" + cFtTpShelf + "'

	DO CASE                              //'1 - Todos Itens','2 - Itens a granel','3 - Peso Padrao'
	CASE SUBSTR(cOrdG,1,1) =='2'
		cRet += CRLF + " AND B1_TPDESP='2'  "
	CASE SUBSTR(cOrdG,1,1) =='3'
		cRet += CRLF + " AND B1_TPDESP='3'  "
	ENDCASE

	//------------------------- ORDER------------------------------
	DO CASE
	CASE SUBSTR(cOrdem,1,1) =='1'   //'1 - Zona crescente Roteiro Crescente'
		cRet += CRLF + "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, A1_GRPVEN,A1_ROTENTR     ,Z5_CLIENTE ,Z5_LOJACLI,Z5_NUM,REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO) DESC  "
	CASE SUBSTR(cOrdem,1,1) =='2'   //'2 - Zona Crescente Roteiro Decrescente'
		cRet += CRLF + "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, A1_GRPVEN,A1_ROTENTR DESC,Z5_NUM,Z5_CLIENTE DESC ,Z5_LOJACLI,REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO)  "
	CASE SUBSTR(cOrdem,1,1) =='3'   //'3 - Codigo de Produto'
		cRet += CRLF + "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO),A1_GRPVEN,A1_ROTENTR ,Z5_CLIENTE ,Z5_LOJACLI,Z5_NUM  "
	CASE SUBSTR(cOrdem,1,1) =='4'   //'4 - Cidade'
		cRet += CRLF + "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, Z5_CIDADE,Z5_END,Z5_NUM,Z5_CLIENTE ,Z5_LOJACLI  "
	OTHERWISE
		cRet += CRLF + "ORDER BY Z5_VVISTA DESC, CASE WHEN Z5_VVISTA = 'S' THEN Z5_NUM ELSE '' END, A1_GRPVEN,A1_ROTENTR ,Z5_CLIENTE ,Z5_LOJACLI,Z5_NUM,REPLICATE('0', 8-LEN(Z6_PRODUTO))+RTRIM(Z6_PRODUTO) DESC  "
	ENDCASE

Return cRet


/*/{Protheus.doc} VldVVista
Valida Pedidos do Tipo Venda à Vista
@type function
@version 12.1.25
@author Paulo Apolinário - Geeker Company
@since 20/05/2021
@return Array, aRet - Array com os Pedidos de Venda não OK.
/*/
Static Function VldVVista()
	Local aRet      := {}
	Local aVVCorte  := {}
	Local nI        := 0
	Local nTamArray := 0
	Local nPosPV    := 0
	Local cPedido   := ''
	Local lVVCorte  := .F.
	Local lVVDesp   := .F.

	nTamArray := Len( oGetDados:aCols )
	If nTamArray > 0
		For nI := 1 To nTamArray
			If oGetDados:aCols[ nI, P1_VVISTA] == 'S'
				cPedido := oGetDados:aCols[ nI, P1_PEDIDO]
				If ( oGetDados:aCols[ nI, P1_VOLUME] > 0 ) .AND. ( oGetDados:aCols[ nI, P1_VOLUME] < oGetDados:aCols[ nI, P1_QTDEP] )
					lVVCorte := .T.
					lVVDesp  := .T.
				ElseIf ( oGetDados:aCols[ nI, P1_VOLUME] > 0 ) .AND. ( oGetDados:aCols[ nI, P1_VOLUME] == oGetDados:aCols[ nI, P1_QTDEP] )
					lVVCorte := .F.
					lVVDesp  := .T.
				Elseif oGetDados:aCols[ nI, P1_VOLUME] == 0
					lVVCorte := .T.
					lVVDesp  := .F.
				Endif
				If ( nPosPV := aScan( aVVCorte, { |x| x[1] == cPedido } ) ) == 0
					Aadd( aVVCorte, { cPedido, lVVDesp, lVVCorte } )
				Else
					If !aVVCorte[ nPosPV, 3] .AND. lVVCorte
						aVVCorte[ nPosPV, 3] := .T.
					Endif
					If !aVVCorte[ nPosPV, 2] .AND. lVVDesp
						aVVCorte[ nPosPV, 2] := .T.
					Endif
				Endif
			Endif
		Next nI

		nTamArray := Len( aVVCorte )
		For nI := 1 To nTamArray
			If aVVCorte[ nI, 2] .AND. aVVCorte[ nI, 3]
				Aadd( aRet, aVVCorte[ nI, 1] )
			Endif
		Next nI
	Endif
Return aRet

/*/{Protheus.doc} VldKit
Valida Pedidos do Tipo Venda KIT
@type function
@version 12.1.25
@author Leonardo Robes
@since 20/05/2021
@return Array, aRet - Array com os Pedidos de Venda não OK.
/*/
Static Function VldKit()

	Local aRet      := {}
	Local aKitCorte := {}
	Local nI        := 0
	Local nTamArray := 0
	Local nPosPV    := 0
	Local cPedido   := ''
	Local lKitCorte := .F.
	Local lKitDesp  := .F.

	nTamArray := Len( oGetDados:aCols )
	If nTamArray > 0
		For nI := 1 To nTamArray
			If !Empty(oGetDados:aCols[ nI, P1_KIT])
				cPedido := oGetDados:aCols[ nI, P1_PEDIDO]
				If ( oGetDados:aCols[ nI, P1_VOLUME] > 0 ) .AND. ( oGetDados:aCols[ nI, P1_VOLUME] < oGetDados:aCols[ nI, P1_QTDEP] )
					lKitCorte := .T.
					lKitDesp  := .T.
				ElseIf ( oGetDados:aCols[ nI, P1_VOLUME] > 0 ) .AND. ( oGetDados:aCols[ nI, P1_VOLUME] == oGetDados:aCols[ nI, P1_QTDEP] )
					lKitCorte := .F.
					lKitDesp  := .T.
				Elseif oGetDados:aCols[ nI, P1_VOLUME] == 0
					lKitCorte := .T.
					lKitDesp  := .F.
				Endif
				If ( nPosPV := aScan( aKitCorte, { |x| x[1] == cPedido } ) ) == 0
					Aadd( aKitCorte, { cPedido, lKitDesp, lKitCorte } )
				Else
					If !aKitCorte[ nPosPV, 3] .AND. lKitCorte
						aKitCorte[ nPosPV, 3] := .T.
					Endif
					If !aKitCorte[ nPosPV, 2] .AND. lKitDesp
						aKitCorte[ nPosPV, 2] := .T.
					Endif
				Endif
			Endif
		Next nI

		nTamArray := Len( aKitCorte )
		For nI := 1 To nTamArray
			If aKitCorte[ nI, 2] .AND. aKitCorte[ nI, 3]
				Aadd( aRet, aKitCorte[ nI, 1] )
			Endif
		Next nI
	Endif
Return aRet

/*/{Protheus.doc} ValidZ24
Valida as leituras do VIF
@type function
@version 12.1.25
@author Leonardo Robes
@since 06/06/2022
@return mensagem com o erro
/*/
Static Function ValidZ24(cPRODUTO,cNCS,cLOTE,nPESO,nPECA)
	Local cRet	:= ""
	Local cFornece 	:= SuperGetMV( "MV_YFORSA5", .F., "003811;003811" )
	Local lProdExt  := .F.
	Local cProdExt	:= ""
	Local cAliasTMP := GetNextAlias()
	Local cxLote	:= SUBSTR(cLOTE,2,6)

	cQuery := " SELECT * FROM " + RetSqlName("SA5") + " A5 "
	cQuery += " WHERE A5_FILIAL = '  ' AND A5_PRODUTO = '"+cPRODUTO+"'"
	cQuery += " AND A5_FORNECE IN " + FormatIn(cFornece,";")
	cQuery += " AND D_E_L_E_T_ = ' ' "

	If SELECT(cAliasTMP) > 0
		dbSelectArea(cAliasTMP)
		dbCloseArea()
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), cAliasTMP, .F., .T. )

	If !(cAliasTMP)->(Eof())
		cProdExt := cValToChar( Val( (cAliasTMP)->A5_CODPRF ) )
		lProdExt := .T.
	EndIf

	(cAliasTMP)->(dbCloseArea())

	If nPECA > 1

		cQuery := CRLF + "  SELECT Z24_PALETE MEDIDA, ISNULL(C2_QUJE,0) PROD,ISNULL(COUNT(Z24_PALETE),0) PECAS, ISNULL(SUM(Z24_QTDE),0) PESO "
		cQuery += CRLF + "  FROM "+ RetSqlName("Z24") +" (NOLOCK) Z24 "
		cQuery += CRLF + "  LEFT JOIN "+ RetSqlName("SC2") +" (NOLOCK) C2 ON C2_FILIAL = Z24_FILIAL AND C2_PRODUTO = Z24_PROD "
		cQuery += CRLF + "  AND SUBSTRING(C2_XOPVIF,1,6) = Z24_OF AND C2_QUANT >= 1 AND C2.D_E_L_E_T_ = ''
		cQuery += CRLF + "  WHERE   Z24.D_E_L_E_T_  = '' "
		cQuery += CRLF + "      AND Z24.Z24_FILIAL  = '02'  "
		cQuery += CRLF + "      AND Z24.Z24_PROD = '" + Iif( !lProdExt, cPRODUTO, cProdExt ) + "'  "
		cQuery += CRLF + "      AND ( RIGHT(RTRIM(Z24.Z24_PALETE),6) = '" + cNCS + "' OR SUBSTRING(RIGHT(RTRIM(Z24.Z24_PALETE),7),1,6) = '" + cNCS + "' )  "
		// cQuery += CRLF + "      AND Z24.Z24_VLDLT = '" + dDtValid + "'  "
		cQuery += CRLF + "      AND Z24_ESTORN = '' "
		cQuery += CRLF + "      AND Z24_NUPRPV = '' "
		cQuery += CRLF + "      AND Z24_DATA >= '20220101' "
		cQuery += CRLF + "  GROUP BY Z24_PALETE, C2_QUJE "

	Else

		cQuery := CRLF + "  SELECT TOP 1 Z24_CAIXA MEDIDA, ISNULL(C2_QUJE,0) PROD,1 PECAS, ISNULL(Z24_QTDE,0) PESO "
		cQuery += CRLF + "  FROM "+ RetSqlName("Z24") +" (NOLOCK) Z24 "
		cQuery += CRLF + "  LEFT JOIN "+ RetSqlName("SC2") +" (NOLOCK) C2 ON C2_FILIAL = Z24_FILIAL AND C2_PRODUTO = Z24_PROD "
		cQuery += CRLF + "  AND SUBSTRING(C2_XOPVIF,1,6) = Z24_OF AND C2_QUANT >= 1 AND C2.D_E_L_E_T_ = ''
		cQuery += CRLF + "  WHERE   Z24.D_E_L_E_T_  = '' "
		cQuery += CRLF + "      AND Z24.Z24_FILIAL  = '02'  "
		cQuery += CRLF + "      AND Z24.Z24_PROD = '" + Iif( !lProdExt, cPRODUTO, cProdExt ) + "'  "
		cQuery += CRLF + "      AND ( RIGHT(RTRIM(Z24.Z24_CAIXA),6) = '" + cNCS + "' OR SUBSTRING(RIGHT(RTRIM(Z24.Z24_CAIXA),7),1,6) = '" + cNCS + "' )  "
		cQuery += CRLF + "      AND ( Z24.Z24_LOTE = '" + cxLote + "' OR 1=1 ) "
		cQuery += CRLF + "      AND Z24_ESTORN = '' "
		cQuery += CRLF + "      AND Z24_NUPRPV = '' "
		cQuery += CRLF + "      AND Z24_DATA >= '20220101' "
		cQuery += CRLF + "  ORDER BY Z24.R_E_C_N_O_ DESC"

	EndIF

/* 	If SELECT(cAliasTMP) > 0
		dbSelectArea(cAliasTMP)
		dbCloseArea()
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), cAliasTMP, .F., .T. )

	If !(cAliasTMP)->(Eof())

		If (cAliasTMP)->PESO == 0
			cRet:= "Codigo de Barras não integrado Protheus "
		ElseIf (cAliasTMP)->PROD == 0 .AND. LEN(ALLTRIM(cPRODUTO)) < 5
			cRet:= "Encerramento de OP não integrado ao protheus! "
		ElseIf (cAliasTMP)->PECAS <> nPECA
			cRet:= "Quantidade de caixas lido diferente do integrado ao protheus! "
		ElseIf (cAliasTMP)->PESO <> nPESO
			cRet:= "Quantidade do peso lido diferente do integrado ao protheus! "
		EndIf
	Else
		cRet:= "Codigo de Barras não integrado Protheus ou ja bipado"
	EndIf

	(cAliasTMP)->(dbCloseArea()) */


Return(cRet)

/*/{Protheus.doc} GravaZ24
Valida as leituras do VIF
@type function
@version 12.1.25
@author Leonardo Robes
@since 06/06/2022
@return mensagem com o erro
/*/
Static Function GravaZ24(cPRODUTO,cCodbarr,cLOTE,cPed,nPeso1,nPeca1,lDel)
	//Local cRet	:= ""
	Local cFornece 	:= SuperGetMV( "MV_YFORSA5", .F., "003811;003811" )
	Local lProdExt  := .F.
	Local cProdExt	:= ""
	Local cAliasTMP := GetNextAlias()
	Local cxLote	:= SUBSTR(cLOTE,2,6)
	Local cNCS1		:= ""

	If Len(AllTrim(cCodbarr)) == 26
		cNCS1      :=SUBSTR(ALLTRIM(cCodbarr),11,06)
	ElseIf Len(AllTrim(cCodbarr)) == 28 .Or. Len(AllTrim(cCodbarr)) == 29 //29 = ADELE
		cNCS1      :=SUBSTR(ALLTRIM(cCodbarr),11,06)
	Elseif Len(AllTrim(cCodbarr)) == 36 .AND. At(',', cCodbarr) == 5
		cNCS1      :=SUBSTR(ALLTRIM(cCodbarr),11,06)
	Else
		cNCS1      :=SUBSTR(ALLTRIM(cCodbarr),11,06)
	EndIf

	cQuery := " SELECT * FROM " + RetSqlName("SA5") + " A5 "
	cQuery += " WHERE A5_FILIAL = '  ' AND A5_PRODUTO = '"+cPRODUTO+"'"
	cQuery += " AND A5_FORNECE IN " + FormatIn(cFornece,";")
	cQuery += " AND D_E_L_E_T_ = ' ' "

	If SELECT(cAliasTMP) > 0
		dbSelectArea(cAliasTMP)
		dbCloseArea()
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), cAliasTMP, .F., .T. )

	If !(cAliasTMP)->(Eof())
		cProdExt := cValToChar( Val( (cAliasTMP)->A5_CODPRF ) )
		lProdExt := .T.
	EndIf

	(cAliasTMP)->(dbCloseArea())

	If nPeca1 > 1

		cUpdate:= "  UPDATE Z24010 SET Z24_NUPRPV = '"+IIF(lDel,"",ALLTRIM(cPed))+"' "
		//cQuery += CRLF + "  FROM "+ RetSqlName("Z24") +" Z24 "
		//cQuery += CRLF + "  LEFT JOIN "+ RetSqlName("SC2") +" (NOLOCK) C2 ON C2_FILIAL = Z24_FILIAL AND C2_PRODUTO = Z24_PROD "
		//cQuery += CRLF + "  AND SUBSTRING(C2_XOPVIF,1,6) = Z24_OF AND C2.D_E_L_E_T_ = ''
		cUpdate+= "  WHERE   D_E_L_E_T_  = '' "
		cUpdate+= "      AND Z24_FILIAL  = '02'  "
		cUpdate+= "      AND Z24_PROD = '" + ALLTRIM(Iif( !lProdExt, cPRODUTO, cProdExt )) + "'  "
		cUpdate+= "      AND ( RIGHT(RTRIM(Z24_PALETE),6) = '" + cNCS1 + "' OR SUBSTRING(RIGHT(RTRIM(Z24_PALETE),7),1,6) = '" + cNCS1 + "' )  "
		// cQuery += CRLF + "      AND Z24.Z24_VLDLT = '" + dDtValid + "'  "
		//cQuery += CRLF + "      AND Z24_ESTORN = '' "
		cUpdate+= "      AND Z24_DATA >= '20220101' "
		//cQuery += CRLF + "  GROUP BY Z24_PALETE, C2_QUJE "

	Else

		//cQuery := CRLF + "  SELECT TOP 1 Z24_CAIXA MEDIDA, ISNULL(C2_QUJE,0) PROD,1 PECAS, ISNULL(Z24_QTDE,0) PESO "
		cUpdate:= "  UPDATE Z24010 SET Z24_NUPRPV = '"+IIF(lDel,"",ALLTRIM(cPed))+"' "
		//cQuery += CRLF + "  FROM "+ RetSqlName("Z24") +" Z24 "
		//cQuery += CRLF + "  LEFT JOIN "+ RetSqlName("SC2") +" (NOLOCK) C2 ON C2_FILIAL = Z24_FILIAL AND C2_PRODUTO = Z24_PROD "
		//cQuery += CRLF + "  AND SUBSTRING(C2_XOPVIF,1,6) = Z24_OF AND C2.D_E_L_E_T_ = ''
		cUpdate+= "  WHERE   D_E_L_E_T_  = '' "
		cUpdate+= "      AND Z24_FILIAL  = '02'  "
		cUpdate+= "      AND Z24_PROD = '" + ALLTRIM(Iif( !lProdExt, cPRODUTO, cProdExt )) + "'  "
		cUpdate+= "      AND ( RIGHT(RTRIM(Z24_CAIXA),6) = '" + cNCS1 + "' OR SUBSTRING(RIGHT(RTRIM(Z24_CAIXA),7),1,6) = '" + cNCS1 + "' )  "
		cUpdate+= "      AND ( Z24_LOTE = '" + cxLote + "' OR 1=1 ) "
		cUpdate+="      AND Z24_ESTORN = '' "
		cUpdate+= "      AND Z24_DATA >= '20220101' "
		//cQuery += CRLF + "  ORDER BY Z24.R_E_C_N_O_ DESC"

	EndIF

	If TcSqlExec( cUpdate ) < 0
		Alert( "TCSQLError() " + TCSQLError() )
	EndIf
Return
