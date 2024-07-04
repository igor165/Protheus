#Include "Protheus.Ch"
#INCLUDE "ctba290.ch"
#INCLUDE "Colors.ch"

Static __lMovCTT 
Static __lMovCTD 
Static __lMovCTH
Static __lMovE05 
Static __lMovE06
Static __lMovE07
Static __lMovE08
Static __lMovE09

Static cEmpInit := cEmpAnt
Static cFilInit := cFilAnt
Static nOrdSM0	:= SM0->(IndexOrd())
Static nRecSM0	:= SM0->(Recno())

Static _lCpoEnt05 //Entidade 05
Static _lCpoEnt06 //Entidade 06
Static _lCpoEnt07 //Entidade 07
Static _lCpoEnt08 //Entidade 08
Static _lCpoEnt09 //Entidade 09
//AMARRACAO
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA290   บAutor  ณMarcos S. Lobo      บ Data ณ  07/23/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de Configura็ใo do Intercompany (Cad. Intercompany)  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP - CTB                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION ctba290()

Local cAliasMain := "CV5"
Local nRecSM0	 := 1
Local nOrdSM0	 := 1
Local cExtDBF	 := GetSrvProfString("localdbextension","")
Local lInDB := FindFunction("MPDicInDB") .And. MPDicInDB() //Verifica se o dicionแrio esta no banco
Local cIdioma	 := Upper( Left( FWRetIdiom(), 2 ) )

Private aXFilial := {}


Public nOpcX    := 3

If !lInDB
	If ValType(cExtDBF) == "U" .or. Empty(cExtDBF)
		cExtDBF := ".DBF"
	Endif
	
	dbSelectArea("SM0")
	nRecSM0 := SM0->(Recno())
	nOrdSM0 := SM0->(IndexOrd())
	dbGoTop()
	While !SM0->(Eof())
		If !File("SX2"+alltrim(SM0->M0_CODIGO)+"0"+cExtDBF)
			Do Case 
				Case cIdioma == "EN"
					MsgAlert("File SX2"+alltrim(SM0->M0_CODIGO)+"0 not found !","Check the company: "+SM0->M0_CODIGO)			
				Case cIdioma == "ES"
					MsgAlert("Archivo SX2"+alltrim(SM0->M0_CODIGO)+"0 no encontrado !","Abra a empresa: "+SM0->M0_CODIGO)
				Otherwise
					MsgAlert("Arquivo SX2"+alltrim(SM0->M0_CODIGO)+"0 nao encontrado !","Verifique a empresa: "+SM0->M0_CODIGO)			
			EndCase
			Return
		Endif
		SM0->(dbSkip())
	EndDo
	SM0->(dbSetOrder(nOrdSM0))
	SM0->(dbGoTo(nRecSM0))
Else
	dbSelectArea("SM0")
	nRecSM0 := SM0->(Recno())
	nOrdSM0 := SM0->(IndexOrd())
	dbGoTop()
	While !SM0->(Eof())	
		OpenSxs(,,,,M0_CODIGO,"SX2INT","SX2",,.F.)
		If !(Select("SX2INT") > 0 ) 
			Do Case 
				Case cIdioma == "EN"
					MsgAlert("File SX2"+alltrim(SM0->M0_CODIGO)+"0 not found !","Check the company: "+SM0->M0_CODIGO)			
				Case cIdioma == "ES"
					MsgAlert("Tabla SX2"+alltrim(SM0->M0_CODIGO)+"0 no encontrado !","Abra a empresa: "+SM0->M0_CODIGO)
				Otherwise
					MsgAlert("Tabela SX2"+alltrim(SM0->M0_CODIGO)+"0 nao encontrado !","Verifique a empresa: "+SM0->M0_CODIGO)			
			Endcase
			Return
		Else
			("SX2INT") -> ( DbCloseArea() )
		Endif
		SM0->(dbSkip())
		
	EndDo
	SM0->(dbSetOrder(nOrdSM0))
	SM0->(dbGoTo(nRecSM0))

EndIf




dbSelectArea("SX2")
dbSetOrder(1)
If !MsSeek(cAliasMain)
	MsgInfo(STR0007,STR0008)
	Return
Endif

cCadastro	:= ALLTRIM(X2Nome(cAliasMain))
cPergs		:= "CTA290"

dbSelectArea("SX3")
dbSetOrder(1)
If !MsSeek(cAliasMain)
	MsgInfo(STR0007,STR0008)
	Return
Endif

dbSelectArea( cAliasMain )


Private aRotina := MenuDef(__lMovCTT,__lMovCTD,__lMovCTH,cEmpInit,cFilInit,nOrdSM0,nRecSM0)
SetKey(VK_F12,{|a,b|Pergunte(cPergs,.T.)})

If !Pergunte(cPergs,.T.)
	Return
Endif

Ctb290IniVar() 

mBrowse(6,1,22,75,cAliasMain)

SET KEY VK_F12 to

SM0->(dbSetOrder(nOrdSM0))
SM0->(dbGoto(nRecSM0))

cEmpAnt	 := cEmpInit
cFilAnt  := cFilInit

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA290   บAutor  ณMarcos S. Lobo      บ Data ณ  07/23/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela de Cadastro do Intercompany CTB                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ctb290Cad(nOpcX)

//Local aAreaMain 	:= GetArea()
Local aVarsGet		:= {}
Local cAliasMain	:= Alias()
Local lSoVisual		:= If(nOpcX == 3 .or. nOpcX == 4,.F.,.T.)
Local cEmpCad		:= cEmpInit
Local cFilCad		:= cFilInit

Local lCtaIgual		:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )
Local lCCIgual		:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )
Local lItIgual		:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )
Local lCvIgual		:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )
Local lE05Igual		:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )
Local lE06Igual		:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )
Local lE07Igual		:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )
Local lE08Igual		:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )
Local lE09Igual		:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )

Local lExstCT1Ig	:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )
Local lExstCTTIg	:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )
Local lExstCTDIg	:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )
Local lExstCTHIg	:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )
Local lExstE05Ig	:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )
Local lExstE06Ig	:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )
Local lExstE07Ig	:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )
Local lExstE08Ig	:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )
Local lExstE09Ig	:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )

Local cCpoDscE05	:= ""
Local cCpoDscE06	:= ""
Local cCpoDscE07	:= ""
Local cCpoDscE08	:= ""
Local cCpoDscE09	:= ""

Local nRet			:= 1
Local oDlg
Local oSize
Local aSize		:= MsAdvSize()
Local nLinIni	:= 0
Local nColIni	:= 0
Local nLinEnd	:= 0
Local nColEnd	:= 0
Local nLinLIni	:= 0
Local nColLIni	:= 0
Local nLinLEnd	:= 0
Local nColLEnd	:= 0
Local nXSize	:= 0
Local nYSize	:= 0
Local bAvExistCpo := {|x,y| (x)->(FieldPos(y)) > 0 .And. CtbUso(y) }

Private nOpca := 0
Private cSCOD	 := X3Texto("CV5_COD")
Private cSEmpOri := cSFilOri := cSCT1Ori := cSCTTOri := cSCTDOri := cSCTHOri := cSE05Ori := cSE06Ori := cSE07Ori := cSE08Ori := cSE09Ori := ""
Private cSEmpDes := cSFilDes := cSCT1Des := cSCTTDes := cSCTDDes := cSCTHDes := cSE05Des := cSE06Des := cSE07Des := cSE08Des := cSE09Des := ""
Private cSCT1Fim := cSCTTFim := cSCTDFim := cSCTHFim := cSE05Fim := cSE06Fim := cSE07Fim := cSE08Fim := cSE09Fim := ""

Private cAliasE05	:= ""
Private cAliasE06	:= ""
Private cAliasE07	:= ""
Private cAliasE08	:= ""
Private cAliasE09	:= ""

Private cPlano  := "" //Utilizada para consulta padrใo
Private cCodigo := "" //Utilizada para consulta padrใo

Public cEmpAtu := cEmpAnt
Public cFilAtu := cFilAnt                                            

__lMovCTT := Iif( __lMovCTT == NIL, CtbMovSaldo("CTT"), __lMovCTT )
__lMovCTD := Iif( __lMovCTD == NIL, CtbMovSaldo("CTD"), __lMovCTD )
__lMovCTH := Iif( __lMovCTH == NIL, CtbMovSaldo("CTH"), __lMovCTH )
If _lCpoEnt05
	__lMovE05 := If( __lMovE05 == NIL, CtbMovSaldo("CT0",,"05"), __lMovE05 )
EndIf
If _lCpoEnt06
	__lMovE06 := If( __lMovE06 == NIL, CtbMovSaldo("CT0",,"06"), __lMovE06 )
EndIf
If _lCpoEnt07
	__lMovE07 := If( __lMovE07 == NIL, CtbMovSaldo("CT0",,"07"), __lMovE07 )
EndIf
If _lCpoEnt08
	__lMovE08 := If( __lMovE08 == NIL, CtbMovSaldo("CT0",,"08"), __lMovE08 )
EndIf
If _lCpoEnt09
	__lMovE09 := If( __lMovE09 == NIL, CtbMovSaldo("CT0",,"09"), __lMovE09 )
EndIf

lExstCT1Ig := Eval( bAvExistCpo, "CV5", "CV5_CT1IGU")
lExstCTTIg := Eval( bAvExistCpo, "CV5", "CV5_CTTIGU")
lExstCTDIg := Eval( bAvExistCpo, "CV5", "CV5_CTDIGU")
lExstCTHIg := Eval( bAvExistCpo, "CV5", "CV5_CTHIGU")
lExstE05Ig := Eval( bAvExistCpo, "CV5", "CV5_E05IGU")
lExstE06Ig := Eval( bAvExistCpo, "CV5", "CV5_E06IGU")
lExstE07Ig := Eval( bAvExistCpo, "CV5", "CV5_E07IGU")
lExstE08Ig := Eval( bAvExistCpo, "CV5", "CV5_E08IGU")
lExstE09Ig := Eval( bAvExistCpo, "CV5", "CV5_E09IGU")

dbSelectArea("CT0")
dbSetOrder(1)
dbSeek(xFilial("CT0"))

Do While !CT0->(Eof()) .And. CT0->CT0_FILIAL==xFilial("CT0")
	If CT0->CT0_ID=="05"
		cAliasE05	:= CT0->CT0_ALIAS
		cCpoDscE05	:= CT0->CT0_CPODSC
	EndIf
     
	If CT0->CT0_ID=="06"
		cAliasE06	:= CT0->CT0_ALIAS
		cCpoDscE06	:= CT0->CT0_CPODSC
	EndIf

	If CT0->CT0_ID=="07"
		cAliasE07	:= CT0->CT0_ALIAS
		cCpoDscE07	:= CT0->CT0_CPODSC
	EndIf

	If CT0->CT0_ID=="08"
		cAliasE08	:= CT0->CT0_ALIAS
		cCpoDscE08	:= CT0->CT0_CPODSC
	EndIf

	If CT0->CT0_ID=="09"
		cAliasE09	:= CT0->CT0_ALIAS
		cCpoDscE09	:= CT0->CT0_CPODSC
	EndIf

	CT0->(dbSkip())
EndDo

Pergunte(cPergs,.F.)

dbSelectArea("SX3")
dbSetOrder(1)
MsSeek(cAliasMain)
While !SX3->(Eof()) .and. ALLTRIM(SX3->X3_ARQUIVO) == cAliasMain
	If X3Uso(SX3->X3_USADO)
		If nOpcX == 3						/// SE FOR INCLUSAO
			Private &(ALLTRIM(SX3->X3_CAMPO)) := PADR(&(SX3->X3_RELACAO),SX3->X3_TAMANHO)	//// CARREGA O CONTEUDO PADRAO NA VARIAVEL DE MEMORIA
		Else								/// CASO CONTRARIO USA O CONTEUDO DO POSICIONADO
			Private &(ALLTRIM(SX3->X3_CAMPO)) := &(cAliasMain+"->"+ALLTRIM(SX3->X3_CAMPO))	//// CARREGA O CONTEUDO PADRAO NA VARIAVEL DE MEMORIA
		Endif
		aAdd(aVarsGet,SX3->X3_CAMPO)		/// ACUMULA NO ARRAY DOS CAMPOS QUE SERรO VALIDADOS
	Endif
	SX3->(dbSkip())
Enddo

dbSelectArea(cAliasMain)
dbSetOrder(1)

nCarrOri := 1
nCarrDes := 1

If nOpcX == 4
	nRet:= 	Aviso(STR0030,STR0031,{STR0032,STR0033},1,"")  //"Altera็ใo InterCompany"###"ALTERAR?"###"ORIGEM"###"DESTINO"

	If nRet == 1
		nCarrOri := 1
		nCarrDes := 2
	Else
		nCarrOri := 2
		nCarrDes := 1
	Endif
Endif

If nCarrOri == 2
	lSoVisual := .T.
Else
	lSoVisual := .F.
Endif

If nOpcx == 3 
	M->CV5_EMPORI := cEmpAnt
	M->CV5_FILORI := cFilAnt
EndIF

DEFINE MSDIALOG oDlg FROM  000,000 To aSize[6],aSize[5] TITLE OemToAnsi(cCadastro) OF oMainWnd PIXEL
oDlg:lMaximized := .T.

oSize := FwDefSize():New(.T.,,,oDlg)
oSize:lLateral := .F.
oSize:lProp := .T.

oSize:AddObject("HEADER",100,004,.T.,.T.)
oSize:AddObject("FOOTER",100,096,.T.,.T.)

oSize:Process()

nLinIni := oSize:GetDimension("HEADER","LININI")
nColIni := oSize:GetDimension("HEADER","COLINI")
nLinEnd := oSize:GetDimension("HEADER","LINEND")
nColEnd := oSize:GetDimension("HEADER","COLEND")

//// CODIGO DA CONFIGURACAO INTERCOMPANY
@ nLinIni + 006,nColIni + 005 SAY oSCod VAR cSCod OF oDlg PIXEL COLOR CLR_HBLUE
@ nLinIni + 005,nColIni + 043 MSGET oCod VAR M->CV5_COD OF oDlg PIXEL VALID CheckSx3("CV5_COD",M->CV5_COD) .and. FreeForUse("CV5",M->CV5_COD) WHEN nOpcX == 3
oCod:lReadOnly := lSoVisual
oCod:cSX1Hlp := "CV5_COD"

@ nLinIni + 000,nColIni + 002 TO nLinIni + 021,nColEnd - 002 OF oDlg PIXEL

nLinLIni := oSize:GetDimension("FOOTER","LININI")
nColLIni := oSize:GetDimension("FOOTER","COLINI")
nLinLEnd := oSize:GetDimension("FOOTER","LINEND")
nColLEnd := oSize:GetDimension("FOOTER","COLEND")
nXSize   := oSize:GetDimension("FOOTER","XSIZE")
nYSize   := oSize:GetDimension("FOOTER","YSIZE")

@ nLinLIni + 002,nColLIni + 002 TO nLinLEnd - 010,nColLEnd - 002 OF oDlg PIXEL
@ nLinLIni + 005,nColLIni + 003 SCROLLBOX oSBox HORIZONTAL VERTICAL SIZE nYSize - 010,nXSize - 006 OF oDlg

//Coluna 1

nSpace := 2
nLinSp := 15
nColSp := 5
nChrSz := 6
nF3Sz  := 10
nStartLin := nSpace
nCol := 2
nLin := nStartLin
nSayAdj := 3
nGetAdj := 2
nSayDiv := 1.6
nChkSz	:= 0

//Coluna 1

nMaxSize := 0

oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0015}, oSBox, /*cPicture*/,,,,,.T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Origem"
nSize:=oSay:nWidth/nChrSz
nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

nLin += 3

nLin += nLinSp
oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0009}, oSBox, /*cPicture*/,,,,, .T., CLR_HBLUE, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Empresa Origem"
nSize:=oSay:nWidth/nChrSz
nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

nLin += nLinSp
oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0010}, oSBox, /*cPicture*/,,,,, .T., CLR_HBLUE, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Filial Origem"
nSize:=oSay:nWidth/nChrSz
nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

nLin += nLinSp

nLin += nLinSp
oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0017+STR0011}, oSBox, /*cPicture*/,,,,, .T., CLR_HBLUE, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Da" # "Conta"
nSize:=oSay:nWidth/nChrSz
nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

nLin += nLinSp
oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0018+STR0011}, oSBox, /*cPicture*/,,,,, .T., CLR_HBLUE, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Ate" # "Conta"
nSize:=oSay:nWidth/nChrSz
nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

If __lMovCTT
	nLin += nLinSp
	oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0019+STR0012}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Do" # "C.Custo"
	nSize:=oSay:nWidth/nChrSz
	nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

	nLin += nLinSp
	oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0018+STR0012}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Ate" # "C.Custo"
	nSize:=oSay:nWidth/nChrSz
	nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)
EndIf

If __lMovCTD
	nLin += nLinSp
	oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0019+STR0013}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Do" # "Item Contabil"
	nSize:=oSay:nWidth/nChrSz
	nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

	nLin += nLinSp
	oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0018+STR0013}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Ate" # "Item Contabil"
	nSize:=oSay:nWidth/nChrSz
	nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)
EndIf

If __lMovCTH
	nLin += nLinSp
	oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0017+STR0014}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Da" # "Classe de Valor"
	nSize:=oSay:nWidth/nChrSz
	nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

	nLin += nLinSp
	oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0018+STR0014}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Ate" # "Classe de Valor"
	nSize:=oSay:nWidth/nChrSz
	nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)
EndIf

If _lCpoEnt05 //Inclui o campo para entidade 05
	If __lMovE05
		nLin += nLinSp
		oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0017+CtbSayApro("","05")}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Da" # Entidade 05
		nSize:=oSay:nWidth/nChrSz
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		nLin += nLinSp
		oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0018+CtbSayApro("","05")}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Ate" # Entidade 05
		nSize:=oSay:nWidth/nChrSz
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)
	EndIf
EndIf

If _lCpoEnt06 //Inclui o campo para entidade 06
	If __lMovE06
		nLin += nLinSp
		oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0017+CtbSayApro("","06")}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Da" # Entidade 06
		nSize:=oSay:nWidth/nChrSz
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		nLin += nLinSp
		oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0018+CtbSayApro("","06")}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Ate" # Entidade 06
		nSize:=oSay:nWidth/nChrSz
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)
	EndIf
EndIf

If _lCpoEnt07 //Inclui o campo para entidade 07
	If __lMovE07
		nLin += nLinSp
		oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0017+CtbSayApro("","07")}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Da" # Entidade 07
		nSize:=oSay:nWidth/nChrSz
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		nLin += nLinSp
		oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0018+CtbSayApro("","07")}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Ate" # Entidade 07
		nSize:=oSay:nWidth/nChrSz
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)
	EndIf
EndIf

If _lCpoEnt08 //Inclui o campo para entidade 08
	If __lMovE08
		nLin += nLinSp
		oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0017+CtbSayApro("","08")}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Da" # Entidade 08
		nSize:=oSay:nWidth/nChrSz
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		nLin += nLinSp
		oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0018+CtbSayApro("","08")}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Ate" # Entidade 08
		nSize:=oSay:nWidth/nChrSz
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)
	EndIf
EndIf

If _lCpoEnt09 //Inclui o campo para entidade 09
	If __lMovE09
		nLin += nLinSp
		oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0017+CtbSayApro("","09")}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Da" # Entidade 09
		nSize:=oSay:nWidth/nChrSz
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		nLin += nLinSp
		oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0018+CtbSayApro("","09")}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Ate" # Entidade 09
		nSize:=oSay:nWidth/nChrSz
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)
	EndIf
EndIf

//Coluna 2

nChkSz := nMaxSize
nCol += nMaxSize + nColSp
nLin := nStartLin
nMaxSize := 0

nLin += 3

nLin += nLinSp

@ nLin, nCol MSGET oEmpOri VAR M->CV5_EMPORI OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID CheckSx3("CV5_EMPORI",M->CV5_EMPORI) .AND. Ctb290Say("EMPORI",M->CV5_EMPORI) F3 X3F3("CV5_EMPORI")
nSize:=(oEmpOri:nClientWidth/nGetAdj)+nF3Sz
nSize2:=Len(SM0->M0_NOME)*nChrSz/nSayDiv
@ nLin+nSayAdj, nCol+nSize SAY oSEmpOri VAR cSEmpOri OF oSBox PIXEL COLOR CLR_HBLUE SIZE nSize2,nil
nSize+=nSize2
nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

oEmpOri:lReadOnly := .T.
oEmpOri:cSx1hlp := "CV5_EMPORI"
oEmpOri:Disable()
If nOpcx <> 3
	Ctb290Say("EMPORI",M->CV5_EMPORI)
	oSEMPOri:Refresh()
EndIf

nLin += nLinSp
@ nLin, nCol MSGET oFilOri VAR M->CV5_FILORI OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI,.F.,@aXFilial) .AND. CheckSx3("CV5_FILORI",M->CV5_FILORI) .AND. Ctb290Say("FILORI",M->(CV5_EMPORI+CV5_FILORI)) F3 X3F3("CV5_FILORI")
nSize:=(oFilOri:nClientWidth/nGetAdj)+nF3Sz
nSize2:=Len(SM0->M0_FILIAL)*nChrSz/nSayDiv
@ nLin+nSayAdj, nCol+nSize SAY oSFilOri VAR cSFilOri OF oSBox PIXEL COLOR CLR_HBLUE SIZE nSize2,nil
nSize+=nSize2
nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

oFilOri:lReadOnly := .T.
oFilOri:cSx1hlp := "CV5_FILORI"
oFilOri:Disable()
If nOpcx <> 3
	Ctb290Say("FILORI",M->(CV5_EMPORI+CV5_FILORI))
	oSFILOri:Refresh()
EndIf

nLin += nLinSp

nLin += nLinSp
@ nLin, nCol MSGET oCT1Ori VAR M->CV5_CT1ORI OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID Ct290Vld("CT1","CT1",M->CV5_CT1ORI,nOpcx,.F.,"ORI") .AND. Ctb290Say("CT1ORI",M->CV5_CT1ORI) F3 X3F3("CV5_CT1ORI")
nSize:=(oCT1Ori:nClientWidth/nGetAdj)+nF3Sz
nSize2:=Len(CT1->CT1_DESC01)*nChrSz/nSayDiv
@ nLin+nSayAdj, nCol+nSize SAY oSCT1Ori VAR cSCT1Ori OF oSBox PIXEL COLOR CLR_HBLUE SIZE nSize2,nil
nSize+=nSize2
nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

oCT1Ori:lReadOnly := lSoVisual
oCT1Ori:cSx1hlp := "CV5_CT1ORI"
oCT1Ori:bGotFocus := {|| CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)}
If nOpcx <> 3 
	Ctb290Say("CT1ORI",M->CV5_CT1ORI)
	oSCT1Ori:Refresh()
EndIf

nLin += nLinSp
@ nLin, nCol MSGET oCT1Fim VAR M->CV5_CT1FIM OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID Ct290Vld("CT1","CT1",M->CV5_CT1FIM,nOpcx,.T.,"ORI") .and. Ctb290Say("CT1FIM",M->CV5_CT1FIM) F3 X3F3("CV5_CT1ORI")
nSize:=(oCT1Fim:nClientWidth/nGetAdj)+nF3Sz
nSize2:=Len(CT1->CT1_DESC01)*nChrSz/nSayDiv
@ nLin+nSayAdj, nCol+nSize SAY oSCT1Fim VAR cSCT1Fim OF oSBox PIXEL COLOR CLR_HBLUE SIZE nSize2,nil
nSize+=nSize2
nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

oCT1Fim:lReadOnly := lSoVisual
oCT1Fim:cSx1Hlp := "CV5_CT1FIM"
oCT1Fim:bGotFocus := {|| CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)}
If nOpcx <> 3
	Ctb290Say("CT1FIM",M->CV5_CT1FIM)
	oSCT1Fim:Refresh()
EndIf

If __lMovCTT
	nLin += nLinSp
	@ nLin, nCol MSGET oCTTOri VAR M->CV5_CTTORI OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID If(Empty(M->CV5_CTTORI),.T.,Ct290Vld("CTT","CTT",M->CV5_CTTORI,nOpcx,.F.,"ORI")) .AND. Ctb290Say("CTTORI",M->CV5_CTTORI) F3 X3F3("CV5_CTTORI")
	nSize:=(oCTTOri:nClientWidth/nGetAdj)+nF3Sz
	nSize2:=Len(CTT->CTT_DESC01)*nChrSz/nSayDiv
	@ nLin+nSayAdj, nCol+nSize SAY oSCTTOri VAR cSCTTORI OF oSBox PIXEL SIZE nSize2,nil
	nSize+=nSize2
	nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

	oCTTOri:lReadOnly := lSoVisual .or. !__lMovCTT
	oCTTOri:cSx1Hlp := "CV5_CTTORI"
	oCTTOri:bGotFocus := {|| CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)}
	If nOpcx <> 3
		Ctb290Say("CTTORI",M->CV5_CTTORI)
		oSCTTOri:Refresh()
	EndIf

	nLin += nLinSp
	@ nLin, nCol MSGET oCTTFim VAR M->CV5_CTTFIM OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID Ct290Vld("CTT","CTT",M->CV5_CTTFIM,nOpcx,.T.,"ORI") .and. Ctb290Say("CTTFIM",M->CV5_CTTFIM) F3 X3F3("CV5_CTTORI")
	nSize:=(oCTTFim:nClientWidth/nGetAdj)+nF3Sz
	nSize2:=Len(CTT->CTT_DESC01)*nChrSz/nSayDiv
	@ nLin+nSayAdj, nCol+nSize SAY oSCTTFim VAR cSCTTFim OF oSBox PIXEL SIZE nSize2,nil
	nSize+=nSize2
	nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

	oCTTFim:lReadOnly := lSoVisual .or. !__lMovCTT
	oCTTFim:cSx1Hlp := "CV5_CTTIM"
	oCTTFim:bGotFocus := {|| CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)}
	If nOpcx <> 3
		Ctb290Say("CTTFIM",M->CV5_CTTFIM)
		oSCTTFim:Refresh()
	EndIf
EndIf

If __lMovCTD
	nLin += nLinSp
	@ nLin, nCol MSGET oCTDOri VAR M->CV5_CTDORI OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID If(Empty(M->CV5_CTDORI),.T.,Ct290Vld("CTD","CTD",M->CV5_CTDORI,nOpcx,.F.,"ORI")) .AND. Ctb290Say("CTDORI",M->CV5_CTDORI) F3 X3F3("CV5_CTDORI")
	nSize:=(oCTDOri:nClientWidth/nGetAdj)+nF3Sz
	nSize2:=Len(CTD->CTD_DESC01)*nChrSz/nSayDiv
	@ nLin+nSayAdj, nCol+nSize SAY oSCTDOri VAR cSCTDOri OF oSBox PIXEL SIZE nSize2,nil
	nSize+=nSize2
	nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

	oCTDOri:lReadOnly := lSoVisual .or. !__lMovCTD
	oCTDOri:cSx1Hlp := "CV5_CTDORI"
	oCTDOri:bGotFocus := {|| CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)}
	If nOpcx <> 3
		Ctb290Say("CTDORI",M->CV5_CTDORI)
		oSCTDOri:Refresh()
	EndIf

	nLin += nLinSp
	@ nLin, nCol MSGET oCTDFim VAR M->CV5_CTDFIM OF oSBox PIXEL  WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID Ct290Vld("CTD","CTD",M->CV5_CTDFIM,nOpcx,.T.,"ORI") .and. Ctb290Say("CTDFIM",M->CV5_CTDFIM) F3 X3F3("CV5_CTDORI")
	nSize:=(oCTDFim:nClientWidth/nGetAdj)+nF3Sz
	nSize2:=Len(CTD->CTD_DESC01)*nChrSz/nSayDiv
	@ nLin+nSayAdj, nCol+nSize SAY oSCTDFim VAR cSCTDFim OF oSBox PIXEL SIZE nSize2,nil
	nSize+=nSize2
	nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

	oCTDFim:lReadOnly := lSoVisual .or. !__lMovCTD
	oCTDFim:cSx1Hlp := "CV5_CTDFIM"
	oCTDFim:bGotFocus := {|| CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)}
	If nOpcx <> 3
		Ctb290Say("CTDFIM",M->CV5_CTDFIM)
		oSCTDFim:Refresh()
	EndIf
EndIf

If __lMovCTH
	nLin += nLinSp
	@ nLin, nCol MSGET oCTHOri VAR M->CV5_CTHORI OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID If(Empty(M->CV5_CTHORI),.T.,Ct290Vld("CTH","CTH",M->CV5_CTHORI,nOpcx,.F.,"ORI")) .AND. Ctb290Say("CTHORI",M->CV5_CTHORI) F3 X3F3("CV5_CTHORI")
	nSize:=(oCTHOri:nClientWidth/nGetAdj)+nF3Sz
	nSize2:=Len(CTH->CTH_DESC01)*nChrSz/nSayDiv
	@ nLin+nSayAdj, nCol+nSize SAY oSCTHOri VAR cSCTHORI OF oSBox PIXEL SIZE nSize2,nil
	nSize+=nSize2
	nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

	oCTHOri:lReadOnly := lSoVisual .or. !__lMovCTH
	oCTHOri:cSx1Hlp := "CV5_CTHORI"
	oCTHOri:bGotFocus := {|| CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)}
	If nOpcx <> 3
		Ctb290Say("CTHORI",M->CV5_CTHORI)
		oSCTHOri:Refresh()
	EndIf

	nLin += nLinSp
	@ nLin, nCol MSGET oCTHFim VAR M->CV5_CTHFIM OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID Ct290Vld("CTH","CTH",M->CV5_CTHFIM,nOpcx,.T.,"ORI") .and. Ctb290Say("CTHFIM",M->CV5_CTHFIM) F3 X3F3("CV5_CTHORI")
	nSize:=(oCTHFim:nClientWidth/nGetAdj)+nF3Sz
	nSize2:=Len(CTH->CTH_DESC01)*nChrSz/nSayDiv
	@ nLin+nSayAdj, nCol+nSize SAY oSCTHFim VAR cSCTHFim OF oSBox PIXEL SIZE nSize2,nil
	nSize+=nSize2
	nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

	oCTHFim:lReadOnly := lSoVisual .or. !__lMovCTH
	oCTHFim:cSx1Hlp := "CV5_CTHFIM"
	oCTHFim:bGotFocus := {|| CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)}
	If nOpcx <> 3
		Ctb290Say("CTHFIM",M->CV5_CTHFIM)
		oSCTHFim:Refresh()
	EndIf
	
EndIf

If _lCpoEnt05
	If __lMovE05
		nLin += nLinSp
		@ nLin, nCol MSGET oE05Ori VAR M->CV5_E05ORI OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID If(Empty(M->CV5_E05ORI),.T.,Ct290Vld(cAliasE05,"E05",M->CV5_E05ORI,nOpcx,.F.,"ORI",,"05")) .And. Ctb290Say(cAliasE05+"ORI",M->CV5_E05ORI,"05") F3 X3F3("CV5_E05ORI")
		nSize:=(oE05Ori:nClientWidth/nGetAdj)+nF3Sz
		nSize2:=Len( &(cAliasE05+"->"+cCpoDscE05) )*nChrSz/nSayDiv
		@ nLin+nSayAdj, nCol+nSize SAY oSE05Ori VAR cSE05Ori OF oSBox PIXEL SIZE nSize2,nil
		nSize+=nSize2
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		oE05Ori:lReadOnly := lSoVisual .Or. !__lMovE05
		oE05Ori:cSx1Hlp := "CV5_E05ORI"
		oE05Ori:bGotFocus := {|| CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)}
		If nOpcx <> 3
			Ctb290Say(cAliasE05+"ORI",M->CV5_E05ORI,"05")
			oSE05Ori:Refresh()
		EndIf
	
		nLin += nLinSp
		@ nLin, nCol MSGET oE05Fim VAR M->CV5_E05FIM OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID Ct290Vld(cAliasE05,"E05",M->CV5_E05FIM,nOpcx,.T.,"ORI",,"05") .And. Ctb290Say(cAliasE05+"FIM",M->CV5_E05FIM,"05") F3 X3F3("CV5_E05ORI")
		nSize:=(oE05Fim:nClientWidth/nGetAdj)+nF3Sz
		nSize2:=Len( &(cAliasE05+"->"+cCpoDscE05) )*nChrSz/nSayDiv
		@ nLin+nSayAdj, nCol+nSize SAY oSE05Fim VAR cSE05Fim OF oSBox PIXEL SIZE nSize2,nil
		nSize+=nSize2
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		oE05Fim:lReadOnly := lSoVisual .Or. !__lMovE05
		oE05Fim:cSx1Hlp := "CV5_E05FIM"
		oE05Fim:bGotFocus := {|| CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)}
		If nOpcx <> 3
			Ctb290Say(cAliasE05+"FIM",M->CV5_E05FIM,"05")
			oSE05Fim:Refresh()
		EndIf
	EndIf
EndIf

If _lCpoEnt06
	If __lMovE06
		nLin += nLinSp
		@ nLin, nCol MSGET oE06Ori VAR M->CV5_E06ORI OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID If(Empty(M->CV5_E06ORI),.T.,Ct290Vld(cAliasE06,"E06",M->CV5_E06ORI,nOpcx,.F.,"ORI",,"06")) .And. Ctb290Say(cAliasE06+"ORI",M->CV5_E06ORI,"06") F3 X3F3("CV5_E06ORI")
		nSize:=(oE06Ori:nClientWidth/nGetAdj)+nF3Sz
		nSize2:=Len( &(cAliasE06+"->"+cCpoDscE06) )*nChrSz/nSayDiv
		@ nLin+nSayAdj, nCol+nSize SAY oSE06Ori VAR cSE06Ori OF oSBox PIXEL SIZE nSize2,nil
		nSize+=nSize2
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		oE06Ori:lReadOnly := lSoVisual .Or. !__lMovE06
		oE06Ori:cSx1Hlp := "CV5_E06ORI"
		oE06Ori:bGotFocus := {|| CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)}
		If nOpcx <> 3
			Ctb290Say(cAliasE06+"ORI",M->CV5_E06ORI,"06")
			oSE06Ori:Refresh()
		EndIf
	
		nLin += nLinSp
		@ nLin, nCol MSGET oE06Fim VAR M->CV5_E06FIM OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID Ct290Vld(cAliasE06,"E06",M->CV5_E06FIM,nOpcx,.T.,"ORI",,"06") .And. Ctb290Say(cAliasE06+"FIM",M->CV5_E06FIM,"06") F3 X3F3("CV5_E06ORI")
		nSize:=(oE06Fim:nClientWidth/nGetAdj)+nF3Sz
		nSize2:=Len( &(cAliasE06+"->"+cCpoDscE06) )*nChrSz/nSayDiv
		@ nLin+nSayAdj, nCol+nSize SAY oSE06Fim VAR cSE06Fim OF oSBox PIXEL SIZE nSize2,nil
		nSize+=nSize2
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		oE06Fim:lReadOnly := lSoVisual .Or. !__lMovE06
		oE06Fim:cSx1Hlp := "CV5_E06FIM"
		oE06Fim:bGotFocus := {|| CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)}
		If nOpcx <> 3
			Ctb290Say(cAliasE06+"FIM",M->CV5_E06FIM,"06")
			oSE06Fim:Refresh()
		EndIf
	EndIf
EndIf

If _lCpoEnt07
	If __lMovE07
		nLin += nLinSp
		@ nLin, nCol MSGET oE07Ori VAR M->CV5_E07ORI OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID If(Empty(M->CV5_E07ORI),.T.,Ct290Vld(cAliasE07,"E07",M->CV5_E07ORI,nOpcx,.F.,"ORI",,"07")) .And. Ctb290Say(cAliasE07+"ORI",M->CV5_E07ORI,"07") F3 X3F3("CV5_E07ORI")
		nSize:=(oE07Ori:nClientWidth/nGetAdj)+nF3Sz
		nSize2:=Len( &(cAliasE07+"->"+cCpoDscE07) )*nChrSz/nSayDiv
		@ nLin+nSayAdj, nCol+nSize SAY oSE07Ori VAR cSE07Ori OF oSBox PIXEL SIZE nSize2,nil
		nSize+=nSize2
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		oE07Ori:lReadOnly := lSoVisual .Or. !__lMovE07
		oE07Ori:cSx1Hlp := "CV5_E07ORI"
		oE07Ori:bGotFocus := {|| CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)}
		If nOpcx <> 3
			Ctb290Say(cAliasE07+"ORI",M->CV5_E07ORI,"07")
			oSE07Ori:Refresh()
		EndIf
	
		nLin += nLinSp
		@ nLin, nCol MSGET oE07Fim VAR M->CV5_E07FIM OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4)VALID Ct290Vld(cAliasE07,"E07",M->CV5_E07FIM,nOpcx,.T.,"ORI",,"07") .And. Ctb290Say(cAliasE07+"FIM",M->CV5_E07FIM,"07") F3 X3F3("CV5_E07ORI")
		nSize:=(oE07Fim:nClientWidth/nGetAdj)+nF3Sz
		nSize2:=Len( &(cAliasE07+"->"+cCpoDscE07) )*nChrSz/nSayDiv
		@ nLin+nSayAdj, nCol+nSize SAY oSE07Fim VAR cSE07Fim OF oSBox PIXEL SIZE nSize2,nil
		nSize+=nSize2
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		oE07Fim:lReadOnly := lSoVisual .Or. !__lMovE07
		oE07Fim:cSx1Hlp := "CV5_E07FIM"
		oE07Fim:bGotFocus := {|| CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)}
		If nOpcx <> 3
			Ctb290Say(cAliasE07+"FIM",M->CV5_E07FIM,"07")
			oSE07Fim:Refresh()
		EndIf
	EndIf
EndIf

If _lCpoEnt08
	If __lMovE08
		nLin += nLinSp
		@ nLin, nCol MSGET oE08Ori VAR M->CV5_E08ORI OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID If(Empty(M->CV5_E08ORI),.T.,Ct290Vld(cAliasE08,"E08",M->CV5_E08ORI,nOpcx,.F.,"ORI",,"08")) .And. Ctb290Say(cAliasE08+"ORI",M->CV5_E08ORI,"08") F3 X3F3("CV5_E08ORI")
		nSize:=(oE08Ori:nClientWidth/nGetAdj)+nF3Sz
		nSize2:=Len( &(cAliasE08+"->"+cCpoDscE08) )*nChrSz/nSayDiv
		@ nLin+nSayAdj, nCol+nSize SAY oSE08Ori VAR cSE08Ori OF oSBox PIXEL SIZE nSize2,nil
		nSize+=nSize2
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		oE08Ori:lReadOnly := lSoVisual .Or. !__lMovE08
		oE08Ori:cSx1Hlp := "CV5_E08ORI"
		oE08Ori:bGotFocus := {|| CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)}
		If nOpcx <> 3
			Ctb290Say(cAliasE08+"ORI",M->CV5_E08ORI,"08")
			oSE08Ori:Refresh()
		EndIf
	
		nLin += nLinSp
		@ nLin, nCol MSGET oE08Fim VAR M->CV5_E08FIM OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID Ct290Vld(cAliasE08,"E08",M->CV5_E08FIM,nOpcx,.T.,"ORI",,"08") .And. Ctb290Say(cAliasE08+"FIM",M->CV5_E08FIM,"08") F3 X3F3("CV5_E08ORI")
		nSize:=(oE08Fim:nClientWidth/nGetAdj)+nF3Sz
		nSize2:=Len( &(cAliasE08+"->"+cCpoDscE08) )*nChrSz/nSayDiv
		@ nLin+nSayAdj, nCol+nSize SAY oSE08Fim VAR cSE08Fim OF oSBox PIXEL SIZE nSize2,nil
		nSize+=nSize2
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		oE08Fim:lReadOnly := lSoVisual .Or. !__lMovE08
		oE08Fim:cSx1Hlp := "CV5_E08FIM"
		oE08Fim:bGotFocus := {|| CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)}
		If nOpcx <> 3
			Ctb290Say(cAliasE08+"FIM",M->CV5_E08FIM,"05")
			oSE08Fim:Refresh()
		EndIf
	EndIf
EndIf

If _lCpoEnt09
	If __lMovE09
		nLin += nLinSp
		@ nLin, nCol MSGET oE09Ori VAR M->CV5_E09ORI OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID If(Empty(M->CV5_E09ORI),.T.,Ct290Vld(cAliasE09,"E09",M->CV5_E09ORI,nOpcx,.F.,"ORI",,"09")) .And. Ctb290Say(cAliasE09+"ORI",M->CV5_E09ORI,"09") F3 X3F3("CV5_E09ORI")
		nSize:=(oE09Ori:nClientWidth/nGetAdj)+nF3Sz
		nSize2:=Len( &(cAliasE09+"->"+cCpoDscE09) )*nChrSz/nSayDiv
		@ nLin+nSayAdj, nCol+nSize SAY oSE09Ori VAR cSE09Ori OF oSBox PIXEL SIZE nSize2,nil
		nSize+=nSize2
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		oE09Ori:lReadOnly := lSoVisual .Or. !__lMovE09
		oE09Ori:cSx1Hlp := "CV5_E09ORI"
		oE09Ori:bGotFocus := {|| CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)}
		If nOpcx <> 3
			Ctb290Say(cAliasE09+"ORI",M->CV5_E09ORI,"09")
			oSE09Ori:Refresh()
		EndIf
	
		nLin += nLinSp
		@ nLin, nCol MSGET oE09Fim VAR M->CV5_E09FIM OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID Ct290Vld(cAliasE09,"E09",M->CV5_E09FIM,nOpcx,.T.,"ORI",,"09") .And. Ctb290Say(cAliasE09+"FIM",M->CV5_E09FIM,"09") F3 X3F3("CV5_E09ORI")
		nSize:=(oE09Fim:nClientWidth/nGetAdj)+nF3Sz
		nSize2:=Len( &(cAliasE09+"->"+cCpoDscE09) )*nChrSz/nSayDiv
		@ nLin+nSayAdj, nCol+nSize SAY oSE09Fim VAR cSE09Fim OF oSBox PIXEL SIZE nSize2,nil
		nSize+=nSize2
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		oE09Fim:lReadOnly := lSoVisual .Or. !__lMovE09
		oE09Fim:cSx1Hlp := "CV5_E09FIM"
		oE09Fim:bGotFocus := {|| CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)}
		If nOpcx <> 3
			Ctb290Say(cAliasE09+"FIM",M->CV5_E09FIM,"09")
			oSE09Fim:Refresh()
		EndIf
	EndIf
EndIf

//Coluna 3

nCol += nMaxSize + nColSp
nLin := nStartLin
nMaxSize := 0

oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0016}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Destino"
nSize:=oSay:nWidth/nChrSz
nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

nLin += 3

nLin += nLinSp
oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0009}, oSBox, /*cPicture*/,,,,, .T., CLR_HBLUE, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Empresa Destino"
nSize:=oSay:nWidth/nChrSz
nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

nLin += nLinSp
oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0010}, oSBox, /*cPicture*/,,,,, .T., CLR_HBLUE, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Filial Destino"
nSize:=oSay:nWidth/nChrSz
nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

nLin += nLinSp
If lExstCT1Ig                   
	If M->CV5_CT1IGU == "S"
		lCtaIgual	:= .T.
	EndIf	
	oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0028}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Igual Origem?"
	nLin += nLinSp
	@ nLin, nCol CHECKBOX oCtaIgual VAR lCtaIgual PROMPT AllTrim(STR0011) WHEN (nOpcX == 3 .Or. ( nOpcX == 4 .And. nCarrDes == 1)) PIXEL OF oSBox SIZE nChkSz*2,9 MESSAGE STR0029; //"Se estiver marcado, a entidade destino serแ considerada igual เ origem."
				ON CLICK Ctb290Igual("CT1",nOpcX,lCtaIgual,oCT1Des)
	nLin += nLinSp
Else
	nLin += nLinSp
	oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0011}, oSBox, /*cPicture*/,,,,, .T., CLR_HBLUE, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Conta"
	nLin += nLinSp
EndIf

If __lMovCTT
	nLin += nLinSp
	If lExstCTTIg
		If M->CV5_CTTIGU == "S"
			lCCIgual	:= .T.
		EndIf	
		@ nLin, nCol CHECKBOX oCCIgual VAR lCCIgual PROMPT ALLTRIM(STR0012) WHEN (nOpcX == 3 .Or. ( nOpcX == 4 .And. nCarrDes == 1)) PIXEL OF oSBox SIZE nChkSz*2,9 MESSAGE STR0029; //"Se estiver marcado, a entidade destino serแ considerada igual เ origem."
					ON CLICK Ctb290Igual("CTT",nOpcX,lCCIgual,oCTTDes)
	Else
		oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0012}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"C.Custo"
	EndIf
	nLin += nLinSp
EndIf

If __lMovCTD
	nLin += nLinSp
	If lExstCTDIg
		If M->CV5_CTDIGU == "S"
			lItIgual	:= .T.
		EndIf
		@ nLin, nCol CHECKBOX oItIgual VAR lItIgual PROMPT ALLTRIM(STR0013) WHEN (nOpcX == 3 .Or. ( nOpcX == 4 .And. nCarrDes == 1)) PIXEL OF oSBox SIZE nChkSz*2,9 MESSAGE STR0029; //"Se estiver marcado, a entidade destino serแ considerada igual เ origem."
					ON CLICK Ctb290Igual("CTD",nOpcX,lItIgual,oCTDDes)
	Else
		oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0013}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Item Contabil"
	EndIf	
	nLin += nLinSp
EndIf

If __lMovCTH
	nLin += nLinSp
	If lExstCTHIg
		If M->CV5_CTHIGU == "S"
			lCvIgual	:= .T.
		EndIf
		@ nLin, nCol CHECKBOX oCvIgual VAR lCvIgual PROMPT ALLTRIM(STR0014) WHEN (nOpcX == 3 .Or. ( nOpcX == 4 .And. nCarrDes == 1)) PIXEL OF oSBox SIZE nChkSz*2,9 MESSAGE STR0029; //"Se estiver marcado, a entidade destino serแ considerada igual เ origem."
					ON CLICK Ctb290Igual("CTH",nOpcX,lCvIgual,oCTHDes)
	Else
		oSay := TSay():New(nLin+nSayAdj, nCol, {|| STR0014}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //"Classe de Valor"
	EndIf
	nLin += nLinSp
EndIf

If _lCpoEnt05
	If __lMovE05
		nLin += nLinSp
		If lExstE05Ig
			If M->CV5_E05IGU == "S"
				lE05Igual	:= .T.
			EndIf
			@ nLin, nCol CHECKBOX oE05Igual VAR lE05Igual PROMPT CtbSayApro("","05") WHEN (nOpcX == 3 .Or. ( nOpcX == 4 .And. nCarrDes == 1)) PIXEL OF oSBox SIZE nChkSz*2,9 MESSAGE STR0029; //"Se estiver marcado, a entidade destino serแ considerada igual เ origem."
						ON CLICK Ctb290Igual(cAliasE05,nOpcX,lE05Igual,oE05Des,"05")
		Else
			oSay := TSay():New(nLin+nSayAdj, nCol, {|| CtbSayApro("","05")}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //Entidade 05
		EndIf	
		nLin += nLinSp
	EndIf
EndIf

If _lCpoEnt06
	If __lMovE06
		nLin += nLinSp
		If lExstE06Ig
			If M->CV5_E06IGU == "S"
				lE06Igual	:= .T.
			EndIf
			@ nLin, nCol CHECKBOX oE06Igual VAR lE06Igual PROMPT CtbSayApro("","06") WHEN (nOpcX == 3 .Or. ( nOpcX == 4 .And. nCarrDes == 1)) PIXEL OF oSBox SIZE nChkSz*2,9 MESSAGE STR0029; //"Se estiver marcado, a entidade destino serแ considerada igual เ origem."
						ON CLICK Ctb290Igual(cAliasE06,nOpcX,lE06Igual,oE06Des,"06")
		Else
			oSay := TSay():New(nLin+nSayAdj, nCol, {|| CtbSayApro("","06")}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //Entidade 06
		EndIf	
		nLin += nLinSp
	Endif
EndIf

If _lCpoEnt07
	If __lMovE07
		nLin += nLinSp
		If lExstE07Ig
			If M->CV5_E07IGU == "S"
				lE07Igual	:= .T.
			EndIf
			@ nLin, nCol CHECKBOX oE07Igual VAR lE07Igual PROMPT CtbSayApro("","07") WHEN (nOpcX == 3 .Or. ( nOpcX == 4 .And. nCarrDes == 1)) PIXEL OF oSBox SIZE nChkSz*2,9 MESSAGE STR0029; //"Se estiver marcado, a entidade destino serแ considerada igual เ origem."
						ON CLICK Ctb290Igual(cAliasE07,nOpcX,lE07Igual,oE07Des,"07")
		Else
			oSay := TSay():New(nLin+nSayAdj, nCol, {|| CtbSayApro("","07")}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //Entidade 07
		EndIf	
		nLin += nLinSp
	EndIf
EndIf

If _lCpoEnt08
	If __lMovE08
		nLin += nLinSp
		If lExstE08Ig
			If M->CV5_E08IGU == "S"
				lE08Igual	:= .T.
			EndIf
			@ nLin, nCol CHECKBOX oE08Igual VAR lE08Igual PROMPT CtbSayApro("","08") WHEN (nOpcX == 3 .Or. ( nOpcX == 4 .And. nCarrDes == 1)) PIXEL OF oSBox SIZE nChkSz*2,9 MESSAGE STR0029; //"Se estiver marcado, a entidade destino serแ considerada igual เ origem."
						ON CLICK Ctb290Igual(cAliasE08,nOpcX,lE08Igual,oE08Des,"08")
		Else
			oSay := TSay():New(nLin+nSayAdj, nCol, {|| CtbSayApro("","08")}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //Entidade 08
		EndIf	
		nLin += nLinSp
	Endif
EndIf

If _lCpoEnt09
	If __lMovE09
		nLin += nLinSp
		If lExstE09Ig
			If M->CV5_E09IGU == "S"
				lE09Igual	:= .T.
			EndIf
			@ nLin, nCol CHECKBOX oE09Igual VAR lE09Igual PROMPT CtbSayApro("","09") WHEN (nOpcX == 3 .Or. ( nOpcX == 4 .And. nCarrDes == 1)) PIXEL OF oSBox SIZE nChkSz*2,9 MESSAGE STR0029; //"Se estiver marcado, a entidade destino serแ considerada igual เ origem."
						ON CLICK Ctb290Igual(cAliasE09,nOpcX,lE09Igual,oE09Des,"09")
		Else
			oSay := TSay():New(nLin+nSayAdj, nCol, {|| CtbSayApro("","09")}, oSBox, /*cPicture*/,,,,, .T., /*nClrText*/, /*nClrBack*/, /*nWidth*/, /*nHeight*/,,,,,) //Entidade 09
		EndIf	
		nLin += nLinSp
	EndIf
EndIf

If nCarrDes == 2
	lSoVisual := .T.
Else
	lSoVisual := .F.
Endif

//Coluna 4

nCol += nChkSz + nColSp
nLin := nStartLin
nMaxSize := 0

nLin += 3

nLin += nLinSp

@ nLin, nCol MSGET oEmpDes VAR M->CV5_EMPDES OF oSBox WHEN (nOpcX == 3 .Or. nOpcX == 4) PIXEL VALID CheckSx3("CV5_EMPDES",M->CV5_EMPDES) .And. Ctb290Say("EMPDES",M->CV5_EMPDES) F3 X3F3("CV5_EMPDES")
nSize:=(oEmpDes:nClientWidth/nGetAdj)+nF3Sz
nSize2:=Len(SM0->M0_NOME)*nChrSz/nSayDiv
@ nLin+nSayAdj, nCol+nSize SAY oSEmpDes VAR cSEmpDes OF oSBox PIXEL COLOR CLR_HBLUE SIZE nSize2,nil
nSize+=nSize2
nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

oEmpDes:lReadOnly := lSoVisual
oEmpDes:cSx1Hlp := "CV5_EMPDES"

nLin += nLinSp

@ nLin, nCol MSGET oFilDes VAR M->CV5_FILDES OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) VALID CtbOpCad(M->CV5_EMPDES,M->CV5_FILDES,.T.,@aXFilial) .AND. CheckSx3("CV5_FILDES",M->CV5_FILDES) .AND. Ctb290Say("FILDES",M->(CV5_EMPDES+CV5_FILDES)) F3 X3F3("CV5_FILDES")
nSize:=(oFilDes:nClientWidth/nGetAdj)+nF3Sz
nSize2:=Len(SM0->M0_FILIAL)*nChrSz/nSayDiv
@ nLin+nSayAdj, nCol+nSize SAY oSFilDes VAR cSFilDes OF oSBox PIXEL COLOR CLR_HBLUE SIZE nSize2,nil
nSize+=nSize2
nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

oFilDes:lReadOnly := lSoVisual
oFilDes:cSx1Hlp := "CV5_FILDES"

nLin += nLinSp

nLin += nLinSp
@ nLin, nCol MSGET oCT1Des VAR M->CV5_CT1DES OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) .And. !lCtaIgual VALID Ct290Vld("CT1","CT1",M->CV5_CT1DES,nOpcx,.F.,"DES",@aXFilial,,lCtaIgual) .AND. Ctb290Say("CT1DES",M->CV5_CT1DES) F3 X3F3("CV5_CT1DES")
nSize:=(oCT1Des:nClientWidth/nGetAdj)+nF3Sz
nSize2:=Len(CT1->CT1_DESC01)*nChrSz/nSayDiv
@ nLin+nSayAdj, nCol+nSize SAY oSCT1Des VAR cSCT1Des OF oSBox PIXEL COLOR CLR_HBLUE SIZE nSize2,nil
nSize+=nSize2
nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

oCT1Des:lReadOnly := lSoVisual
oCT1Des:cSx1Hlp := "CV5_CT1DES"
oCT1Des:bGotFocus := {|| CtbOpCad(M->CV5_EMPDES,M->CV5_FILDES)}
If nOpcx <> 3 
	Ctb290Say("CT1DES",M->CV5_CT1DES)
	oSCT1Des:Refresh()
EndIf

nLin += nLinSp

If __lMovCTT
	nLin += nLinSp
	@ nLin, nCol MSGET oCTTDes VAR M->CV5_CTTDES OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) .And. !lCCIgual VALID If(Empty(M->CV5_CTTDES),.T.,Ct290Vld("CTT","CTT",M->CV5_CTTDES,nOpcx,.F.,"DES",@aXFilial)) .AND. Ctb290Say("CTTDES",M->CV5_CTTDES) F3 X3F3("CV5_CTTDES")
	nSize:=(oCTTDes:nClientWidth/nGetAdj)+nF3Sz
	nSize2:=Len(CTT->CTT_DESC01)*nChrSz/nSayDiv
	@ nLin+nSayAdj, nCol+nSize SAY oSCTTDes VAR cSCTTDes OF oSBox PIXEL SIZE nSize2,nil
	nSize+=nSize2
	nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

	oCTTDes:lReadOnly := lSoVisual .or. !__lMovCTT
	oCTTDes:cSx1Hlp := "CV5_CTTDES"
	oCTTDes:bGotFocus := {|| CtbOpCad(M->CV5_EMPDES,M->CV5_FILDES)}
	If nOpcx <> 3
		Ctb290Say("CTTDES",M->CV5_CTTDES)
		oSCTTDes:Refresh()
	EndIf
	nLin += nLinSp
EndIf

If __lMovCTD
	nLin += nLinSp
	@ nLin, nCol MSGET oCTDDes VAR M->CV5_CTDDES OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) .And. !lItIgual VALID If(Empty(M->CV5_CTDDES),.T.,Ct290Vld("CTD","CTD",M->CV5_CTDDES,nOpcx,.F.,"DES",@aXFilial)) .AND. Ctb290Say("CTDDES",M->CV5_CTDDES) F3 X3F3("CV5_CTDDES")
	nSize:=(oCTDDes:nClientWidth/nGetAdj)+nF3Sz
	nSize2:=Len(CTD->CTD_DESC01)*nChrSz/nSayDiv
	@ nLin+nSayAdj, nCol+nSize SAY oSCTDDes VAR cSCTDDes OF oSBox PIXEL SIZE nSize2,nil
	nSize+=nSize2
	nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

	oCTDDes:lReadOnly := lSoVisual .or. !__lMovCTD
	oCTDDes:cSx1Hlp := "CV5_CTDDES"
	oCTDDes:bGotFocus := {|| CtbOpCad(M->CV5_EMPDES,M->CV5_FILDES)}
	If nOpcx <> 3
		Ctb290Say("CTDDES",M->CV5_CTDDES)
		oSCTDDES:Refresh()
	EndIf
	nLin += nLinSp
EndIf

If __lMovCTH
	nLin += nLinSp
	@ nLin, nCol MSGET oCTHDes VAR M->CV5_CTHDES OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) .And. !lCvIgual VALID If(Empty(M->CV5_CTTDES),.T.,Ct290Vld("CTH","CTH",M->CV5_CTHDES,nOpcx,.F.,"DES",@aXFilial)) .AND. Ctb290Say("CTHDES",M->CV5_CTHDES) F3 X3F3("CV5_CTHDES")
	nSize:=(oCTHDes:nClientWidth/nGetAdj)+nF3Sz
	nSize2:=Len(CTH->CTH_DESC01)*nChrSz/nSayDiv
	@ nLin+nSayAdj, nCol+nSize SAY oSCTHDes VAR cSCTHDes OF oSBox PIXEL SIZE nSize2,nil
	nSize+=nSize2
	nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

	oCTHDes:lReadOnly := lSoVisual .or. !__lMovCTH
	oCTHDes:cSx1Hlp := "CV5_CTHDES"
	oCTHDes:bGotFocus := {|| CtbOpCad(M->CV5_EMPDES,M->CV5_FILDES)}
	If nOpcx <> 3
		Ctb290Say("CTHDES",M->CV5_CTHDES)
		oSCTHDES:Refresh()
	EndIf
	nLin += nLinSp
EndIf

If _lCpoEnt05
	If __lMovE05
		nLin += nLinSp
		@ nLin, nCol MSGET oE05Des VAR M->CV5_E05DES OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) .And. !lE05Igual VALID If(Empty(M->CV5_E05DES),.T.,Ct290Vld(cAliasE05,"E05",M->CV5_E05DES,nOpcx,.F.,"DES",@aXFilial,"05")) .AND. Ctb290Say(cAliasE05+"DES",M->CV5_E05DES,"05") F3 X3F3("CV5_E05DES")
		nSize:=(oE05Des:nClientWidth/nGetAdj)+nF3Sz
		nSize2:=Len( &(cAliasE05+"->"+cCpoDscE05) )*nChrSz/nSayDiv
		@ nLin+nSayAdj, nCol+nSize SAY oSE05Des VAR cSE05Des OF oSBox PIXEL SIZE nSize2,nil
		nSize+=nSize2
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		oE05Des:lReadOnly := lSoVisual .or. !__lMovE05
		oE05Des:cSx1Hlp := "CV5_E05DES"
		oE05Des:bGotFocus := {|| CtbOpCad(M->CV5_EMPDES,M->CV5_FILDES)}
		If nOpcx <> 3
			Ctb290Say(cAliasE05+"DES",M->CV5_E05DES,"05")
			oSE05Des:Refresh()
		EndIf
		nLin += nLinSp
	EndIf
EndIf

If _lCpoEnt06
	If __lMovE06
		nLin += nLinSp
		@ nLin, nCol MSGET oE06Des VAR M->CV5_E06DES OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) .And. !lE06Igual VALID If(Empty(M->CV5_E06DES),.T.,Ct290Vld(cAliasE06,"E06",M->CV5_E06DES,nOpcx,.F.,"DES",@aXFilial,"06")) .AND. Ctb290Say(cAliasE06+"DES",M->CV5_E06DES,"06") F3 X3F3("CV5_E06DES")
		nSize:=(oE06Des:nClientWidth/nGetAdj)+nF3Sz
		nSize2:=Len( &(cAliasE06+"->"+cCpoDscE06) )*nChrSz/nSayDiv
		@ nLin+nSayAdj, nCol+nSize SAY oSE06Des VAR cSE06Des OF oSBox PIXEL SIZE nSize2,nil
		nSize+=nSize2
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		oE06Des:lReadOnly := lSoVisual .or. !__lMovE06
		oE06Des:cSx1Hlp := "CV5_E06DES"
		oE06Des:bGotFocus := {|| CtbOpCad(M->CV5_EMPDES,M->CV5_FILDES)}
		If nOpcx <> 3
			Ctb290Say(cAliasE06+"DES",M->CV5_E06DES,"06")
			oSE06Des:Refresh()
		EndIf
		nLin += nLinSp
	EndIf
EndIf

If _lCpoEnt07
	If __lMovE07
		nLin += nLinSp
		@ nLin, nCol MSGET oE07Des VAR M->CV5_E07DES OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) .And. !lE07Igual VALID If(Empty(M->CV5_E07DES),.T.,Ct290Vld(cAliasE07,"E07",M->CV5_E07DES,nOpcx,.F.,"DES",@aXFilial,"07")) .AND. Ctb290Say(cAliasE07+"DES",M->CV5_E07DES,"07") F3 X3F3("CV5_E07DES")
		nSize:=(oE07Des:nClientWidth/nGetAdj)+nF3Sz
		nSize2:=Len( &(cAliasE07+"->"+cCpoDscE07) )*nChrSz/nSayDiv
		@ nLin+nSayAdj, nCol+nSize SAY oSE07Des VAR cSE07Des OF oSBox PIXEL SIZE nSize2,nil
		nSize+=nSize2
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		oE07Des:lReadOnly := lSoVisual .or. !__lMovE07
		oE07Des:cSx1Hlp := "CV5_E07DES"
		oE07Des:bGotFocus := {|| CtbOpCad(M->CV5_EMPDES,M->CV5_FILDES)}
		If nOpcx <> 3
			Ctb290Say(cAliasE07+"DES",M->CV5_E07DES,"07")
			oSE07Des:Refresh()
		EndIf
		nLin += nLinSp
	EndIf
EndIf

If _lCpoEnt08
	If __lMovE08
		nLin += nLinSp
		@ nLin, nCol MSGET oE08Des VAR M->CV5_E08DES OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) .And. !lE08Igual VALID If(Empty(M->CV5_E08DES),.T.,Ct290Vld(cAliasE08,"E08",M->CV5_E08DES,nOpcx,.F.,"DES",@aXFilial,"08")) .AND. Ctb290Say(cAliasE08+"DES",M->CV5_E08DES,"08") F3 X3F3("CV5_E08DES")
		nSize:=(oE08Des:nClientWidth/nGetAdj)+nF3Sz
		nSize2:=Len( &(cAliasE08+"->"+cCpoDscE08) )*nChrSz/nSayDiv
		@ nLin+nSayAdj, nCol+nSize SAY oSE08Des VAR cSE08Des OF oSBox PIXEL SIZE nSize2,nil
		nSize+=nSize2
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		oE08Des:lReadOnly := lSoVisual .or. !__lMovE08
		oE08Des:cSx1Hlp := "CV5_E08DES"
		oE08Des:bGotFocus := {|| CtbOpCad(M->CV5_EMPDES,M->CV5_FILDES)}
		If nOpcx <> 3
			Ctb290Say(cAliasE08+"DES",M->CV5_E08DES,"08")
			oSE08Des:Refresh()
		EndIf
		nLin += nLinSp
	EndIf
EndIf

If _lCpoEnt09
	If __lMovE09
		nLin += nLinSp
		@ nLin, nCol MSGET oE09Des VAR M->CV5_E09DES OF oSBox PIXEL WHEN (nOpcX == 3 .Or. nOpcX == 4) .And. !lE09Igual VALID If(Empty(M->CV5_E09DES),.T.,Ct290Vld(cAliasE09,"E09",M->CV5_E09DES,nOpcx,.F.,"DES",@aXFilial,"09")) .AND. Ctb290Say(cAliasE09+"DES",M->CV5_E09DES,"09") F3 X3F3("CV5_E09DES")
		nSize:=(oE09Des:nClientWidth/nGetAdj)+nF3Sz
		nSize2:=Len( &(cAliasE09+"->"+cCpoDscE09) )*nChrSz/nSayDiv
		@ nLin+nSayAdj, nCol+nSize SAY oSE09Des VAR cSE09Des OF oSBox PIXEL SIZE nSize2,nil
		nSize+=nSize2
		nMaxSize := IIf(nMaxSize>nSize,nMaxSize,nSize)

		oE09Des:lReadOnly := lSoVisual .or. !__lMovE09
		oE09Des:cSx1Hlp := "CV5_E09DES"
		oE09Des:bGotFocus := {|| CtbOpCad(M->CV5_EMPDES,M->CV5_FILDES)}
		If nOpcx <> 3
			Ctb290Say(cAliasE09+"DES",M->CV5_E09DES,"09")
			oSE09Des:Refresh()
		EndIf
		nLin += nLinSp
	EndIf
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {||If(cta290TOk(aVarsGet,nOpcx,@aXFilial,oDlg),nOpca:=1,nOpca:=0) } , {|| oDlg:End()} )

SM0->(dbSetOrder(nOrdSM0))
SM0->(dbGoto(nRecSM0))

If cEmpAnt <> cEmpCad
	cEmpAnt := cEmpCad
	cFilAnt := cFilCad
	CtbOpCad(cEmpAnt,cFilAnt,.F.,@aXFilial)
Else
	cFilAnt := cFilCad
Endif

If nOpca == 1
	If nOpcx >= 3 .and. nOpcx <= 5		/// SE FOR OPCAO DE INCLUIR/ALTERAR/EXCLUIR
		MsAguarde({|| Cta290Grv(aVarsGet,nOpcx,lExstCT1Ig,lExstCTTIg,lExstCTDIg,lExstCTHIg,lExstE05Ig,lExstE06Ig,lExstE07Ig,lExstE08Ig,lExstE09Ig,lCtaIgual,lCCIgual,lItIgual,lCvIgual,lE05Igual,lE06Igual,lE07Igual,lE08Igual,lE09Igual)},STR0020)		/// GRAVA O REGISTRO(S) NA BASE
	Endif
Endif

//RestArea(aAreaMain)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA290   บAutor  ณMicrosiga           บ Data ณ  07/24/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function X3F3(cCampoF3)

aX3Area := SX3->(GetArea())

dbSelectArea("SX3")
dbSetOrder(2)
If MsSeek(cCampoF3)
	If !Empty(SX3->X3_F3)
		cAliasF3 := SX3->X3_F3
	Else
		cAliasF3 := SX3->X3_ARQUIVO
	Endif
Else
	SX3->(dbSkip(-1))
	cAliasF3 := SX3->X3_ARQUIVO
Endif

RestArea(aX3Area)

Return(cAliasF3)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA290   บAutor  ณMicrosiga           บ Data ณ  07/24/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function X3Texto(cX3Campo)
Local cX3Texto := ""
Local cIdioma	 := Upper( Left( FWRetIdiom(), 2 ) )

nX3Ord := SX3->(IndexOrd())
nX3Rec := SX3->(Recno())

dbSelectArea("SX3")
dbSetOrder(2)
	Do Case 
		Case cIdioma == "EN"
			cX3Texto := ALLTRIM(SX3->X3_TITENG)
		Case cIdioma == "ES"
			cX3Texto := ALLTRIM(SX3->X3_TITSPA)
		Otherwise
			cX3Texto := ALLTRIM(SX3->X3_TITULO)
	EndCase

SX3->(dbSetOrder(nX3Ord))
SX3->(dbGoTo(nX3Rec))

Return(cX3Texto)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA290   บAutor  ณMicrosiga           บ Data ณ  07/24/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ctb290Say(cEntid,cContem,cIdEntid)

Local aArea      := GetArea()
Local cSay       := ""
Local cPlanoEnt  := ""
Local aIndexes

Default cIdEntid := ""

///////////////////////////////////////////////////////////////////////////////
//// DETERMINA A DESCRICAO QUE DEVE SER APRESENTADA DE ACORDO COM OS PARAMETROS
///////////////////////////////////////////////////////////////////////////////
DO CASE
	CASE SubStr(cEntid,1,3) == "EMP" .or. SubStr(cEntid,1,3) == "FIL"
		nIndSM0 := SM0->(IndexOrd())
		nRecSM0 := SM0->(Recno())
		
		dbSelectArea("SM0")
		dbSetOrder(1)
		If MsSeek(cContem)
			If SubStr(cEntid,1,3) == "EMP"
				cSay := ALLTRIM(SM0->M0_NOME)
			Else
				cSay := ALLTRIM(SM0->M0_FILIAL)
			Endif
		Endif
		
		SM0->(dbSetOrder(nIndSM0))
		SM0->(dbGoTo(nRecSM0))
	CASE Substr(cEntid,1,3)$("CT1/CTT/CTD/CTH")
		cEntAlias := Substr(cEntid,1,3)
		nIndEnt := (cEntAlias)->(IndexOrd())
		nRecEnt := (cEntAlias)->(Recno())
		
		dbSelectArea(cEntAlias)
		dbSetOrder(1)
		If MsSeek(xFilial(cEntAlias)+cContem)
			cSay := ALLTRIM((cEntAlias)->&(cEntAlias+"_DESC01"))
		Endif
		
		(cEntAlias)->(dbSetOrder(nIndEnt))
		(cEntAlias)->(dbGoTo(nRecEnt))
	CASE Substr(cEntid,1,3)$("CV0") .And. !Empty(cContem)
		cEntAlias := Substr(cEntid,1,3)
		nIndEnt   := (cEntAlias)->(IndexOrd())
		nRecEnt   := (cEntAlias)->(Recno())
		
		dbSelectArea("CT0")
		dbSetOrder(1)
		If DbSeek(xFilial("CT0")+cIdEntid)
			cPlanoEnt := CT0->CT0_ENTIDA
			dbSelectArea(cEntAlias)
			dbSetOrder(1)
			If MsSeek(xFilial(cEntAlias)+cPlanoEnt+cContem)
				cSay := ALLTRIM((cEntAlias)->&(cEntAlias+"_DESC"))
			Endif
		 EndIf
		 
		(cEntAlias)->(dbSetOrder(nIndEnt))
		(cEntAlias)->(dbGoTo(nRecEnt))
	Otherwise
		If !Empty(cContem)
			aIndexes := CTBEntGtIn()

			dbSelectArea("CT0")
			dbSetOrder(1)
			If DbSeek(xFilial("CT0")+cIdEntid)
				nIndEnt   := (CT0->CT0_ALIAS)->(IndexOrd())
				nRecEnt   := (CT0->CT0_ALIAS)->(Recno())
				
				dbSelectArea(CT0->CT0_ALIAS)
				dbSetOrder(aIndexes[Val(CT0->CT0_ID)][1])
				If MsSeek(xFilial(CT0->CT0_ALIAS)+cContem)
					cSay := ALLTRIM((CT0->CT0_ALIAS)->&(CT0->CT0_CPODSC))
				EndIf

				(CT0->CT0_ALIAS)->(dbSetOrder(nIndEnt))
				(CT0->CT0_ALIAS)->(dbGoTo(nRecEnt))
			 EndIf
		EndIf
ENDCASE

RestArea(aArea)

If Empty(cIdEntid)
	&("cS"+cEntid) := cSay		/// VARIAVEL CORRESPONDENTE DO SAY DE DESCRICAO NA TELA
Else
	&("cSE"+cIdEntid+Right(cEntid,3)) := cSay		/// VARIAVEL CORRESPONDENTE DO SAY DE DESCRICAO NA TELA	Entidades adicionais
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA290   บAutor  ณMicrosiga           บ Data ณ  07/25/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ct290Vld(cAliasEnt,cEnt,cConteud,nOpcx,lFim,cTpEnt,aXFilial,cIdEntid,lCtaIgual)

Local nIndEnt
Local nRecEnt
Local lOk		:= .T.
Local cFilDST	:= ""
Local lRetEnt	:= .F.
Local cPlanoCV0	:= ""
Local cEmpOld	:= cEmpAnt
Local cFilOld	:= cFilAnt
Default lCtaIgual	:= If( MV_PAR01==2.and.INCLUI , .T. , .F. )

If nOpcX < 3 .or. nOpcX > 4									/// SE FOR VISUALIZACAO RETORNA VALIDACAO OK
	Return(.T.)
Endif

cConteud := Alltrim(cConteud)

DEFAULT lFim 	 := .F.										/// SE TRATA-SE DE ENTIDADE FIM (NO DE-ATE DA ORIGEM)
DEFAULT cTpEnt   := "ORI"									/// TIPO DA ENTIDADE FOR ORIGEM
DEFAULT aXFilial := {}
DEFAULT cIdEntid := ""

If cTpEnt == "ORI"
	CtbOpCad(M->CV5_EMPORI,M->CV5_FILORI)
Else
	CtbOpCad(M->CV5_EMPDES,M->CV5_FILDES)
EndIf

nIndEnt := (cAliasEnt)->(IndexOrd())
nRecEnt := (cAliasEnt)->(Recno())

If Len(aXFilial) > 0
	cFilDST := xFilDST(aXFilial,cAliasEnt)
Else
	cFilDST := xFilial(cAliasEnt)		
Endif

If lFim														/// SE FOR ENTIDADE FIM NO CRITERIO DE-ATE DA ORIGEM
	If Empty(cConteud)										/// SE A ENTIDADE FIM ESTIVER EM BRANCO
		&("M->CV5_"+cEnt+"FIM") := &("M->CV5_"+cEnt+cTpEnt)	/// ATRUBUI O CODIGO FINAL COM O MESMO DO INICIAL
		CtbOpCad(cEmpOld,cFilOld)
		Return(lOk)
	Endif
	
	If ALLTRIM(&("M->CV5_"+cEnt+cTpEnt)) > cConteud			/// SE A ENTIDADE ORIGEM INICIAL FOR MAIOR QUE A FINAL
		HELP("",1,"CV5ORIFIM")
		CtbOpCad(cEmpOld,cFilOld)
		Return(.F.)
	Endif
Else
	//SE CONTA DESTINO ESTIVER EM BRANCO E ORIG <> DES e MV_PAR01 == 1
	If	(cTpEnt == "DES" .AND. ReadVar() == "M->CV5_CT1DES" ) .AND. Empty(CV5_CT1DES) .and. !lCtaIgual .and. !Empty(CV5_CT1ORI)
		Help( " ", 1, "NOCONTAC" )
		RETURN(.F.)
	EndIf
	
	If Empty(cConteud)										/// NรO ษ ENTIDADE FIM, TEM DE-ATE E ESTA EM BRANCO
		CtbOpCad(cEmpOld,cFilOld)
		Return(.T.)											/// ESTม VALIDO POIS SERA UTILIZADO DE-ATE
	Endif
	If cTpEnt <> "DES" 										/// CHECA PELO SX3 SOMENTE NA ORIGEM
		lOk := CheckSx3("CV5_"+cEnt+cTpEnt,&("M->CV5_"+cEnt+cTpEnt))
	Else
		If cAliasEnt $ "CT1/CTT/CTD/CTH"
			dbSelectArea(cAliasEnt)
			dbSetOrder(1)
			If MsSeek(cFilDST+cConteud,.F.)						/// PARA ENTIDADE DESTINO NรO Hม XFILIAL (ALIAS xxxDST.)
				lOk := .T.
	    	Else
	    		lOk := .F.
	    	EndIf
		ElseIf cAliasEnt == "CV0"
	    	dbSelectArea("CT0")
	    	dbSetOrder(1)
	    	If dbSeek(xFilial("CT0")+cIdEntid)
	    		cPlanoCV0 := CT0->CT0_ENTIDA
			EndIf
			dbSelectArea(cAliasEnt)
			dbSetOrder(1)
			If MsSeek(cFilDST+cPlanoCV0+cConteud,.F.)			/// PARA ENTIDADE DESTINO NรO Hม XFILIAL (ALIAS xxxDST.)
				lOk := .T.
		    Else
		    	lOk := .F.
		    EndIf
		Else
			aIndexes := CTBEntGtIn()

	    	dbSelectArea("CT0")
	    	dbSetOrder(1)
	    	If dbSeek(xFilial("CT0")+cIdEntid)
				dbSelectArea(CT0->CT0_ALIAS)
				dbSetOrder(aIndexes[Val(CT0->CT0_ID)][1])
				If MsSeek(cFilDST+cConteud,.F.)			/// PARA ENTIDADE DESTINO NรO Hม XFILIAL (ALIAS xxxDST.)
					lOk := .T.
			    Else
			    	lOk := .F.
			    EndIf
			EndIf
		EndIf
		If !lOk
			DO CASE
				CASE cEnt == "CT1"
					Help( " ", 1, "NOCONTAC" )
				CASE cEnt == "CTT"
					Help( " ", 1, "NOCUSTO" )
				CASE cEnt == "CTD"
					Help( " ", 1, "NOITEM" )
				CASE cEnt == "CTH"
					Help( " ", 1, "NOCLVL" )
				CASE cIdEntid == "05"
					Help( " ", 1, "NOENT05" )
				CASE cIdEntid == "06"
					Help( " ", 1, "NOENT06" )
				CASE cIdEntid == "07"
					Help( " ", 1, "NOENT07" )
				CASE cIdEntid == "08"
					Help( " ", 1, "NOENT08" )
				CASE cIdEntid == "09"
					Help( " ", 1, "NOENT09" )					
			ENDCASE
		Endif
	Endif
    
	If !lOk													/// HOUVE ALGUM PROBLEMA ATRAVES DE VALIDAวรO DO SX3
		CtbOpCad(cEmpOld,cFilOld)
		Return(.F.)											/// RETORNA .F.
	Endif
Endif

If !lFim .or. (UPPER(Substr(cConteud,Len(cConteud)-1,1)) <> "Z" .and. lFim)			/// SE NรO FOR ENTIDADE FIM, OU, SE FOR ENTIDADE FIM E O CONTEUDO FINAL NรO ESTIVER COM O ZZZ
	If cAliasEnt $ "CT1/CTT/CTD/CTH"
		dbSelectArea(cAliasEnt)
		dbSetOrder(1)
		If MsSeek(cFilDST+cConteud)					/// VALIDA SE EXISTE NO CADASTRO
			lRetEnt := .T.
		EndIf
	ElseIf cAliasEnt == "CV0"
		dbSelectArea("CT0")
	    dbSetOrder(1)
	    If dbSeek(xFilial("CT0")+cIdEntid)
	    	cPlanoCV0 := CT0->CT0_ENTIDA
		EndIf
		dbSelectArea(cAliasEnt)
		dbSetOrder(1)
		If MsSeek(cFilDST+cPlanoCV0+cConteud)		/// VALIDA SE EXISTE NO CADASTRO Entidades adicionais
			lRetEnt := .T.
		EndIf
	Else
		aIndexes := CTBEntGtIn()

    	dbSelectArea("CT0")
    	dbSetOrder(1)
    	If dbSeek(xFilial("CT0")+cIdEntid)
			dbSelectArea(CT0->CT0_ALIAS)
			dbSetOrder(aIndexes[Val(CT0->CT0_ID)][1])
			If MsSeek(cFilDST+cConteud)			/// PARA ENTIDADE DESTINO NรO Hม XFILIAL (ALIAS xxxDST.)
				lRetEnt := .T.
		    EndIf
		EndIf
	EndIf
	
	If !lRetEnt
		DO CASE
			CASE cEnt == "CT1"
				Help( " ", 1, "NOCONTAC" )
			CASE cEnt == "CTT"
				Help( " ", 1, "NOCUSTO" )
			CASE cEnt == "CTD"
				Help( " ", 1, "NOITEM" )
			CASE cEnt == "CTH"
				Help( " ", 1, "NOCLVL" )
			CASE cIdEntid == "05"
				Help( " ", 1, "NOENT05" )
			CASE cIdEntid == "06"
				Help( " ", 1, "NOENT06" )
			CASE cIdEntid == "07"
				Help( " ", 1, "NOENT07" )
			CASE cIdEntid == "08"
				Help( " ", 1, "NOENT08" )
			CASE cIdEntid == "09"
				Help( " ", 1, "NOENT09" )				
		ENDCASE
		Return(.F.)
	Else   													/// SE EXISTIR
		IF cEnt <> "CT1" 									/// SE NAO FOR CONTA
			If Empty(cConteud)								/// PODE FICAR EM BRANCO
				CtbOpCad(cEmpOld,cFilOld)
				Return(lOk)									/// ENTAO RETORNA OK
			Endif
		Endif
		/// SE NรO ESTIVER EM BRANCO
		If cAliasEnt $ "CT1/CTT/CTD/CTH"
			If &(cAliasEnt+"->"+cEnt+"_CLASSE") <> "2"				/// VALIDA SE ษ ANALITICA
				Help( " ", 1, "NOCLASSE" )
				CtbOpCad(cEmpOld,cFilOld)
				Return(.F.)
			Endif
		ElseIf cAliasEnt == "CV0"
			If &(cAliasEnt+"->"+cAliasEnt+"_CLASSE") <> "2" 		/// VALIDA SE ษ ANALITICA
				Help( " ", 1, "NOCLASSE" )
				CtbOpCad(cEmpOld,cFilOld)
				Return(.F.)
			Endif
		EndIf
	Endif
Endif

(cAliasEnt)->(dbSetOrder(nIndEnt))
(cAliasEnt)->(dbGoTo(nRecEnt))

/*
// Retirado Gatilho. Estแ sendo ativado o CheckBox caso o MV_PAR01==2
If mv_par01 == 2 .and. cTpEnt == "ORI"		//// SE O PARAMETRO ORIGEM = DESTINO ESTIVER COMO SIM E FOR VALID DE ENTIDADE ORIGEM
	If !Empty(cConteud) .and. Empty(&("M->CV5_"+cEnt+"DES")) //// SE ESTIVER OK, NรO ESTIVER VAZIO, E O DESTINO ESTIVER EM BRANCO
		&("M->CV5_"+cEnt+"DES") := &("M->CV5_"+cEnt+"ORI")	/// ATRUBUI O CODIGO DESTINO COM O MESMO DO ORIGEM
	Endif
Endif
*/

CtbOpCad(cEmpOld,cFilOld)

Return(lOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA290   บAutor  ณMicrosiga           บ Data ณ  07/25/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Cta290TOk(aVarsGet,nOpcX,aXFilial,oDlg)

Local aAreaTok	:= GetArea()
Local lTok		:= .T.
Local nV
Local cEmpOld	:= cEmpAnt
Local cFilOld	:= cFilAnt
Local cCpoEntid := ""

DEFAULT aVarsGet:= {}

If nOpcX >= 3 .and. nOpcX <= 4								/// VALIDA SE FOR INCLUSAO OU ALTERACAO
	//// EFETUA AS VALIDAวีES DE CAMPOS PADROES (SX3)
	For nV := 1 to Len(aVarsGet)
		cEnt		:= Substr(aVarsGet[nV],5,3)					/// CODIGO DA ENTIDADE (EMP,FIL,CT1,CTT,CTD,CTH)
		cConteud 	:= &("M->"+ALLTRIM(aVarsGet[nV]))			/// CONTEUDO DA VARIAVEL EM QUESTรO
		c3LstChr	:= Right(ALLTRIM(aVarsGet[nV]),3)			/// 3 ULTIMOS CARACTERES DO NOME DA VARIAVEL = TIPO DA ENTIDADE
		lFim		:= c3LstChr == "FIM"						/// SE FOR ENTIDADE FIM (NOME DA VAR COM FINAL = "FIM")
		cTpEnt		:= If(lFim,"ORI",c3LstChr)					/// TIPO DA ENTIDADE (ORI=ORIGEM/DES=DESTINO) SE FOR FIM RETORNA COMO ORIGEM
		
		If cEnt$("EMP/FIL/COD/DES")										/// SE FOR EMPRESA/FILIAL/CODIGO/DESCRICAO VALIDA PELO SX3
			lTOk := CheckSX3(ALLTRIM(aVarsGet[nV]),cConteud)
		Else													/// CASO CONTRARIO
			If Substr(aVarsGet[nV],8,3)<> "IGU"
				cEmpAnt := &("M->CV5_EMP"+cTpEnt)
				cFilAnt := &("M->CV5_FIL"+cTpEnt)
				If c3LstChr=="DES"						/// SE FOR ENTIDADE DESTINO
					If nV <= 21
						IF !ca295Abre({cEnt},cEmpAnt,cFilAnt,.F.,.T.,@aXFilial)
							Return( .T. )
						EndIF
					Else	//Entidades adicionais
						IF !ca295Abre({"CV0"},cEmpAnt,cFilAnt,.F.,.T.,@aXFilial)
							Return( .T. )
						EndIF
					EndIf

					If cEnt$"CTT/CTD/CTH" //Entidades padroes
						If Empty(cConteud)
							lTOk := .T.
						Else
							lTOk := Ct290Vld(cEnt,cEnt,cConteud,nOpcx,lFim,cTpEnt,@aXFilial)
						EndIf							                        
					ElseIf cEnt$"EC05/E05" //Verifica se e um campo das novas entidades
						If Empty(cConteud)
							lTOk := .T.
						Else
							lTOk := Ct290Vld(cAliasE05,cEnt,cConteud,nOpcx,lFim,cTpEnt,@aXFilial,Right(cEnt,2))							
						EndIf
					ElseIf cEnt$"EC06/E06" //Verifica se e um campo das novas entidades
						If Empty(cConteud)
							lTOk := .T.
						Else
							lTOk := Ct290Vld(cAliasE06,cEnt,cConteud,nOpcx,lFim,cTpEnt,@aXFilial,Right(cEnt,2))							
						EndIf
					ElseIf cEnt$"EC07/E07" //Verifica se e um campo das novas entidades
						If Empty(cConteud)
							lTOk := .T.
						Else
							lTOk := Ct290Vld(cAliasE07,cEnt,cConteud,nOpcx,lFim,cTpEnt,@aXFilial,Right(cEnt,2))							
						EndIf
					ElseIf cEnt$"EC08/E08" //Verifica se e um campo das novas entidades
						If Empty(cConteud)
							lTOk := .T.
						Else
							lTOk := Ct290Vld(cAliasE08,cEnt,cConteud,nOpcx,lFim,cTpEnt,@aXFilial,Right(cEnt,2))							
						EndIf
					ElseIf cEnt$"EC09/E09" //Verifica se e um campo das novas entidades
						If Empty(cConteud)
							lTOk := .T.
						Else
							lTOk := Ct290Vld(cAliasE09,cEnt,cConteud,nOpcx,lFim,cTpEnt,@aXFilial,Right(cEnt,2))							
						EndIf
					EndIf			
				ElseIf nV <= 21
					IF !ca295Abre({cEnt},cEmpAnt,cFilAnt,.F.,.T.,@aXFilial)
						Return( .T. )
					EndIF
				Else	// Entidades adicionais
					IF !ca295Abre({"CV0"},cEmpAnt,cFilAnt,.F.,.T.,@aXFilial)
						Return( .T. )
					EndIF
				EndIf
			Else	
				lTOk := CheckSX3(ALLTRIM(aVarsGet[nV]),cConteud)			
			EndIf
		Endif
		If !lTok 												/// SE NรO ESTIVER OK
			RestArea(aAreaTok)
			Return(.F.)											/// ABORTA E RETORNA .F.
		Endif
	Next
	
	/// SE FOR INCLUSAO OU ALTERACAO VALIDA SE A CHAVE Jม EXISTE
	If (nOpcx == 3 .or. nOpcx == 4)
		dbSelectArea("CV5")
		nOrdCV5 := IndexOrd()
		nRecCV5 := Recno()
		dbSetOrder(1)
		lCV5Alterado := .F.
		
		cCpoEntid := "CV5_COD+CV5_EMPORI+CV5_FILORI+CV5_EMPDES+CV5_FILDES+CV5_CT1ORI+CV5_CT1FIM+CV5_CTTORI+CV5_CTTFIM+CV5_CTDORI+CV5_CTDFIM+CV5_CTHORI+CV5_CTHFIM"
		If(_lCpoEnt05,cCpoEntid += "+CV5_E05ORI+CV5_E05FIM",Nil)
		If(_lCpoEnt06,cCpoEntid += "+CV5_E06ORI+CV5_E06FIM",Nil)
		If(_lCpoEnt07,cCpoEntid += "+CV5_E07ORI+CV5_E07FIM",Nil)
		If(_lCpoEnt08,cCpoEntid += "+CV5_E08ORI+CV5_E08FIM",Nil)
		If(_lCpoEnt09,cCpoEntid += "+CV5_E09ORI+CV5_E09FIM",Nil)
		
		cKeyCV5M := xFilial("CV5")+M->(&cCpoEntid)
		If nOpcx == 4	//// SE FOR ALTERACAO VERIFICA SOMENTE SE O CONTEUDO DA CHAVE POSICIONADA FOI ALTERADA
			If cKeyCV5M <> CV5->(&cCpoEntid)
				If MsSeek(cKeyCV5M)
					If CV5->(Recno()) <> nRecCV5
						Help( " ", 1, "EXISTCHAV" )
						CV5->(dbSetOrder(nOrdCV5))
						CV5->(dbGoTo(nRecCV5))
						RestArea(aAreaTok)
						Return(.F.)
					Endif
				Endif
			Endif
		Else			//// SE FOR INCLUSAO VALIDA A EXISTENCIA DA CHAVE
			If MsSeek(cKeyCV5M)
				Help( " ", 1, "EXISTCHAV" )
				RestArea(aAreaTok)
				Return(.F.)
			Endif
		Endif
		dbSelectArea("CV5")
		dbSetOrder(nOrdCV5)
		dbGoTo(nRecCV5)
	Endif
	
	//// TRATAMENTO PARA VALIDAวรO ORIGEM E DESTINO DA EMPRESA/FILIAL
	If M->CV5_EMPORI == M->CV5_EMPDES .AND. M->CV5_FILORI == M->CV5_FILDES
		Help("",1,"CV5ORIDES") //// SE ORIGEM E DESTINO FOREM IGUAIS
		RestArea(aAreaTok)
		Return(.F.)
	ElseIf Empty(M->CV5_EMPORI) .or. Empty(M->CV5_FILORI) .or. Empty(M->CV5_EMPDES) .or. Empty(M->CV5_FILDES)
		Help("",1,"CV5EMPFILB")
		lTOk := .F.
		RestArea(aAreaTok)
		Return(.F.)
	Endif
Endif

////////////////////////////////////////////////////////////////////////////////////
//// FIM DAS VALIDAวีES DA TOK
////////////////////////////////////////////////////////////////////////////////////
If lTok									/// SE ESTIVER TUDO OK PASSA PARA A GRAVACAO
	oDlg:End()
Endif

cEmpAnt := cEmpOld
cFilAnt := cFilOld

RestArea(aAreaTok)

Return(lTok)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA290   บAutor  ณMicrosiga           บ Data ณ  07/25/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Cta290Grv(aVarsGet,nOpcX,lExstCT1Ig,lExstCTTIg,lExstCTDIg,lExstCTHIg,lExstE05Ig,lExstE06Ig,lExstE07Ig,lExstE08Ig,lExstE09Ig,lCtaIgual,lCCIgual,lItIgual,lCvIgual,lE05Igual,lE06Igual,lE07Igual,lE08Igual,lE09Igual)

Local cArq2Grv    := "CV5"                  //// ALIAS DO ARQUIVO QUE SERA GRAVADO
Local cPrefCPO    := GetX3Pref(cArq2Grv)	//// PREFIXO DO CAMPO NO SX3 PARA GRAVACAO DA FILIAL
Local nV
Local cCpoEntid   := ""

DEFAULT lCtaIgual := .F.
DEFAULT lCCIgual  := .F.
DEFAULT lItIgual  := .F.
DEFAULT lCvIgual  := .F.
DEFAULT lE05Igual := .F.
DEFAULT lE06Igual := .F.
DEFAULT lE07Igual := .F.
DEFAULT lE08Igual := .F.
DEFAULT lE09Igual := .F.

dbSelectArea(cArq2Grv)
MsProcTxt(STR0022)
If nOpcX == 3								//// SE FOR INCLUSAO VALIDA A EXISTสNCIA DA CHAVE
	dbSelectArea(cArq2Grv)
	dbSetOrder(1)
	cFilCV5 := xFilial(cArq2Grv)

	cCpoEntid := "CV5_COD+CV5_EMPORI+CV5_FILORI+CV5_EMPDES+CV5_FILDES+CV5_CT1ORI+CV5_CT1FIM+CV5_CTTORI+CV5_CTTFIM+CV5_CTDORI+CV5_CTDFIM+CV5_CTHORI+CV5_CTHFIM"

	If(_lCpoEnt05,cCpoEntid += "+CV5_E05ORI+CV5_E05FIM",Nil)
	If(_lCpoEnt06,cCpoEntid += "+CV5_E06ORI+CV5_E06FIM",Nil)
	If(_lCpoEnt07,cCpoEntid += "+CV5_E07ORI+CV5_E07FIM",Nil)
	If(_lCpoEnt08,cCpoEntid += "+CV5_E08ORI+CV5_E08FIM",Nil)
	If(_lCpoEnt09,cCpoEntid += "+CV5_E09ORI+CV5_E09FIM",Nil)

	If MsSeek(cFilCV5+M->(&cCpoEntid))
		HELP("",1,"EXISTCHAV")
		Return
	Endif

Endif
RecLock(cArq2Grv,nOpcx == 3)
If nOpcx == 5
	dbDelete()
Else
	For nV := 1 to Len(aVarsGet)
		&(cArq2Grv+"->"+aVarsGet[nV]) := &("M->"+aVarsGet[nV])
	Next
	&(cArq2Grv+"->"+cPrefCPO+"_FILIAL") := xFilial(cArq2Grv)
	If lExstCT1Ig 
		If lCtaIgual	
			&(cArq2Grv+"->"+cPrefCPO+"_CT1IGU")		:= "S"
		Else
			&(cArq2Grv+"->"+cPrefCPO+"_CT1IGU")		:= "N"	
		EndIf
	EndIf
	
	If lExstCTTIg 
		If lCCIgual                       
			&(cArq2Grv+"->"+cPrefCPO+"_CTTIGU")		:= "S"
		Else
			&(cArq2Grv+"->"+cPrefCPO+"_CTTIGU")		:= "N"	
		EndIf
	EndIf
	
	If lExstCTDIg 
		If lItIgual                       
			&(cArq2Grv+"->"+cPrefCPO+"_CTDIGU")		:= "S"
		Else
			&(cArq2Grv+"->"+cPrefCPO+"_CTDIGU")		:= "N"	
		EndIf
	EndIf
	
	If lExstCTHIg 
		If lCvIgual                       
			&(cArq2Grv+"->"+cPrefCPO+"_CTHIGU")		:= "S"
		Else
			&(cArq2Grv+"->"+cPrefCPO+"_CTHIGU")		:= "N"			
		EndIf	
	EndIf

	If _lCpoEnt05 .And. lExstE05Ig 
		If lE05Igual
			&(cArq2Grv+"->"+cPrefCPO+"_E05IGU")		:= "S"
		Else
			&(cArq2Grv+"->"+cPrefCPO+"_E05IGU")		:= "N"			
		EndIf	
	EndIf

	If _lCpoEnt06 .And.lExstE06Ig 
		If lE06Igual
			&(cArq2Grv+"->"+cPrefCPO+"_E06IGU")		:= "S"
		Else
			&(cArq2Grv+"->"+cPrefCPO+"_E06IGU")		:= "N"			
		EndIf	
	EndIf

	If _lCpoEnt07 .And. lExstE07Ig 
		If lE07Igual
			&(cArq2Grv+"->"+cPrefCPO+"_E07IGU")		:= "S"
		Else
			&(cArq2Grv+"->"+cPrefCPO+"_E07IGU")		:= "N"			
		EndIf	
	EndIf
           
	If _lCpoEnt08 .And. lExstE08Ig 
		If lE08Igual
			&(cArq2Grv+"->"+cPrefCPO+"_E08IGU")		:= "S"
		Else
			&(cArq2Grv+"->"+cPrefCPO+"_E08IGU")		:= "N"			
		EndIf	
	EndIf

	If _lCpoEnt09 .And. lExstE09Ig 
		If lE09Igual
			&(cArq2Grv+"->"+cPrefCPO+"_E09IGU")		:= "S"
		Else
			&(cArq2Grv+"->"+cPrefCPO+"_E09IGU")		:= "N"			
		EndIf	
	EndIf
Endif         
         
(cArq2Grv)->(MsUnlock())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA290   บAutor  ณMicrosiga           บ Data ณ  07/25/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetX3Pref(cAlias)

cPref := UPPER(ALLTRIM(cAlias))
cPref := If(Substr(cAlias,1,1)=="S",SubStr(cAlias,2,2),cAlias)

Return(cPref)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA290   บAutor  ณMicrosiga           บ Data ณ  07/29/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function X3WHENGET(cCpoWhen,nOpcX,lIgual)

Local lWhen	 	:= .F.
Local lExecWhen	:= .T.
DEFAULT nOpcX := 3                      
DEFAULT lIgual	:= .F.

If nOpcX == 3 .Or. nOpcX == 4
	DO CASE
		CASE cCpoWhen$"CV5_CTTORI#CV5_CTTFIM#CV5_CTTDES"
			If !__lMovCTT
				lExecWhen := .F.
			Endif
		CASE cCpoWhen$"CV5_CTDORI#CV5_CTDFIM#CV5_CTDDES"
			If !__lMovCTD
				lExecWhen := .F.
			Endif
		CASE cCpoWhen$"CV5_CTHORI#CV5_CTHFIM#CV5_CTHDES"
			If !__lMovCTH
				lExecWhen := .F.
			Endif
		CASE cCpoWhen$"CV5_E05ORI#CV5_E05FIM#CV5_E05DES" //Entidade 05
			If !__lMovE05
				lExecWhen := .F.
			Endif
		CASE cCpoWhen$"CV5_E06ORI#CV5_E06FIM#CV5_E06DES" //Entidade 06
			If !__lMovE06
				lExecWhen := .F.
			Endif						
		CASE cCpoWhen$"CV5_E07ORI#CV5_E07FIM#CV5_E07DES" //Entidade 07
			If !__lMovE07
				lExecWhen := .F.
			Endif	
		CASE cCpoWhen$"CV5_E08ORI#CV5_E08FIM#CV5_E08DES" //Entidade 08
			If !__lMovE08
				lExecWhen := .F.
			Endif	
		CASE cCpoWhen$"CV5_E09ORI#CV5_E09FIM#CV5_E09DES" //Entidade 09
			If !__lMovE09
				lExecWhen := .F.
			Endif	
	ENDCASE                                                           
		
	If lExecWhen
		If !Empty(cCpoWhen)
			dbSelectArea("SX3")
			nIndX3 := IndexOrd()
			nRecX3 := Recno()
			dbSetOrder(2)
			If MsSeek(cCpoWhen)
				lWhen := &(SX3->X3_WHEN)
			Endif
			SX3->(dbSetOrder(nIndX3))
			SX3->(dbGoTo(nRecX3))
		Endif
	Endif                
	
	If lIgual 
		lWhen	:= .F.
	EndIf
EndIf

Return(lWhen)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA290   บAutor  ณMicrosiga           บ Data ณ  08/18/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VldCodxEmp(nOpcX)

Local lVldOk	:= .T.
Local nIdxCV5	:= 1
Local nRcnCV5	:= 1

If nOpcX == 3 .or. nOpcX == 4
	
	nIdxCV5	:= CV5->(IndexOrd())
	nRcnCV5	:= CV5->(Recno())
	
	dbSelectArea("CV5")
	dbSetOrder(1)
	If MsSeek(xFilial("CV5")+M->CV5_COD)									//// SE EXISTIR REGISTRO COM O MESMO CODIGO
		If M->(CV5_EMPORI+CV5_FILORI) <> CV5->(CV5_EMPORI+CV5_FILORI)		//// COM EMPRESA/FILIAL ORIGEM DIFERENTE
			Help("",1,"CV5CODXEMP")											//// APRESENTA VALIDAวรO
			lVldOk := .F.													//// (PARA EVITAR TRANSPORTE EM DUPLICIDADE)
		Endif
	Endif
	
	CV5->(dbSetOrder(nIdxCV5))
	CV5->(dbGoTo(nRcnCV5))
Endif

Return(lVldOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA290   บAutor  ณMicrosiga           บ Data ณ  07/29/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ'ฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function F3EMP(cAlias,cEmp,cFil,lDes)

DEFAULT lDes	:= .F.

If !Empty(cEmp) .and. !Empty(cFil)
	IF !ca295Abre({cAlias},cEmp,cFil,.F.,.T.,{})
		Return( .T. )
	EndIF
Endif

//cEmpAtu := cEmp
//cFilAtu := cFil

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA290   บAutor  ณMarcos S. Lobo      บ Data ณ  03/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAbre os cadastro de entidades contabeis para o cadastro     บฑฑ
ฑฑบ          ณdo intercompany.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtbOpCad(cCV5EMP,cCV5FIL,lDst,aXFilial)
Local aAlias := {"CT1","CTT","CTD","CTH","CT0"}

DEFAULT lDst := .F.

If Empty(cCV5EMP) .or. Empty(cCV5FIL)
	Return(.T.)
Endif

dbSelectArea("CT0")
dbSetOrder(1)
dbSeek(xFilial("CT0"))

Do While !CT0->(Eof()) .And. CT0->CT0_FILIAL==xFilial("CT0")
	If AScan(aAlias,CT0->CT0_ALIAS)==0
		AADD(aAlias,CT0->CT0_ALIAS)
	EndIf	
	CT0->(dbSkip())
EndDo

If cEmpAtu <> cCV5EMP .or. cFilAtu <> cCV5FIL
	cEmpAnt := cCV5EMP
	cFilAnt := cCV5FIL

	IF !ca295Abre(aAlias,cCV5EMP,cCV5FIL,.F.,.T.,@aXFilial)
		Return( .T. )
	EndIF	
Endif
    
cEmpAtu := cCV5EMP
cFilAtu := cCV5FIL

Return(.T.)      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA290   บAutor  ณSimone Mie Sato     บ Data ณ  16/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSe o checkbox estiver marcado, desabilita a digitacao para  บฑฑ
ฑฑบ          ณos campos de entidades destino.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ctb290Igual(cAlias,nOpcX,lClick,oObj,cIdEntid)

If nOpcX <> 2
	If lClick        	
		If cAlias == "CT1"
			M->CV5_CT1DES	:= SPACE(Len(CV5->CV5_CT1DES))
			cSCT1DES := M->CV5_CT1DES	 
			oSCT1DES:Refresh()
		ElseIf cAlias == "CTT"
			M->CV5_CTTDES	:= SPACE(Len(CV5->CV5_CTTDES))
			cSCTTDES := M->CV5_CTTDES				
			oSCTTDES:Refresh()		
		ElseIf cAlias == "CTD"
			M->CV5_CTDDES	:= SPACE(Len(CV5->CV5_CTDDES))
			cSCTDDES := M->CV5_CTDDES				
			oSCTDDES:Refresh()		
		ElseIf cAlias == "CTH"
			M->CV5_CTHDES	:= SPACE(Len(CV5->CV5_CTHDES))
			cSCTHDES := M->CV5_CTHDES				
			oSCTHDES:Refresh()		
		ElseIf cIdEntid == "05"
			M->CV5_E05DES	:= SPACE(Len(CV5->CV5_E05DES))
			cSE05DES := M->CV5_E05DES				
			oSE05DES:Refresh()		
		ElseIf cIdEntid == "06"
			M->CV5_E06DES	:= SPACE(Len(CV5->CV5_E06DES))
			cSE06DES := M->CV5_E06DES				
			oSE06DES:Refresh()		
		ElseIf cIdEntid == "07"
			M->CV5_E07DES	:= SPACE(Len(CV5->CV5_E07DES))
			cSE07DES := M->CV5_E07DES				
			oSE07DES:Refresh()		
		ElseIf cIdEntid == "08"
			M->CV5_E08DES	:= SPACE(Len(CV5->CV5_E08DES))
			cSE08DES := M->CV5_E08DES				
			oSE08DES:Refresh()		
		ElseIf cIdEntid == "09"
			M->CV5_E09DES	:= SPACE(Len(CV5->CV5_E09DES))
			cSE09DES := M->CV5_E09DES				
			oSE09DES:Refresh()																
		EndIf
		oObj:Refresh()	
		oObj:Disable()     		
	Else
		oObj:Enable()
		If cAlias == "CT1"
			cSCT1DES := M->CV5_CT1DES	 
			oCT1Des:Refresh()	
		ElseIf cAlias == "CTT"
			cSCTTDES := M->CV5_CTTDES				
			oCTTDes:Refresh()											
		ElseIf cAlias == "CTD"
			cSCTDDES := M->CV5_CTDDES				
			oCTDDes:Refresh()											
		ElseIf cAlias == "CTH"
			cSCTHDES := M->CV5_CTHDES		
			oCTHDes:Refresh()									
		ElseIf cIdEntid == "05"
			cSE05DES := M->CV5_E05DES		
			oE05Des:Refresh()
		ElseIf cIdEntid == "06"
			cSE06DES := M->CV5_E06DES		
			oE06Des:Refresh()
		ElseIf cIdEntid == "07"
			cSE07DES := M->CV5_E07DES		
			oE07Des:Refresh()
		ElseIf cIdEntid == "08"
			cSE08DES := M->CV5_E08DES		
			oE08Des:Refresh()
		ElseIf cIdEntid == "09"
			cSE09DES := M->CV5_E09DES		
			oE09Des:Refresh()														
		EndIf	
	EndIf
EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Ana Paula N. Silva    ณ Data ณ01/12/06  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados         ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function MenuDef(__lMovCTT,__lMovCTD,__lMovCTH,cEmpInit,cFilInit,nOrdSM0,nRecSM0)
Local aRotina := {}
	aAdd(aRotina,{STR0001, "AxPesqui"		,0, 1,,.F.})	/// Pesquisar
	aAdd(aRotina,{STR0002, "Ctb290Cad(2)"	,0, 2})			/// Visualizar
	aAdd(aRotina,{STR0003, "Ctb290Cad(3)"	,0, 3})			/// Incluir
	aAdd(aRotina,{STR0004, "Ctb290Cad(4)"	,0, 4})			/// Alterar
	aAdd(aRotina,{STR0005, "Ctb290Cad(5)"	,0, 5})			/// Excluir
	//aAdd(aRotina,{STR0005, "Ctb390Ger"	,0, 6})			/// "Gerar Autom."

Default cEmpInit := cEmpAnt
Default cFilInit := cFilAnt
Default nOrdSM0	:= SM0->(IndexOrd())
Default nRecSM0	:= SM0->(Recno())
	
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtb290IniVar  บAutor  ณMicrosiga       บ Data ณ  06/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Analise da exist๊ncia dos campos das novas entidades       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Ctb290IniVar()

If _lCpoEnt05 == Nil
	_lCpoEnt05 := CV5->(FieldPos("CV5_E05ORI")>0 .And. FieldPos("CV5_E05FIM")>0)
EndIf
     
If _lCpoEnt06 == Nil
	_lCpoEnt06 := CV5->(FieldPos("CV5_E06ORI")>0 .And. FieldPos("CV5_E06FIM")>0)
EndIf

If _lCpoEnt07 == Nil
	_lCpoEnt07 := CV5->(FieldPos("CV5_E07ORI")>0 .And. FieldPos("CV5_E07FIM")>0)
EndIf

If _lCpoEnt08 == Nil
	_lCpoEnt08 := CV5->(FieldPos("CV5_E08ORI")>0 .And. FieldPos("CV5_E08FIM")>0)
EndIf

If _lCpoEnt09 == Nil
	_lCpoEnt09 := CV5->(FieldPos("CV5_E09ORI")>0 .And. FieldPos("CV5_E09FIM")>0)
EndIf

Return
