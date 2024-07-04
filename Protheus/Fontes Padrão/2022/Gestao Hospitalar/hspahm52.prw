#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "Rwmake.ch"

Static cDadosErro := ""
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Function HSPAHM52()
Local aCposGG2	:= {}
Private aRotina := {	{ OemToAnsi("Pesquisar")	,"AxPesqui" 				,0, 1}, ; //"Pesquisar"
{ OemToAnsi("Visualizar")	,"HS_RotEdi"				,0,	2}, ; //"Visualizar"
{ OemToAnsi("Incluir")		,"HS_RotEdi"				,0,	3}, ; //"Incluir"
{ OemToAnsi("Alterar")		,"HS_RotEdi"				,0,	4}, ; //"Alterar"
{ OemToAnsi("Excluir")		,"HS_RotEdi"				,0,	5}, ; //"Excluir"
{ OemToAnsi("Exportar")		,"Hs_M52EXEC('HS_PEDIExp')"	,0,	2}, ; //"Exportar"
{ OemToAnsi("Imp. XML")		,"Hs_M52EXEC('HS_ImpXml')"	,0, 3}, ; //"Imp. XML"
{ OemToAnsi("Importar")		,"Hs_M52EXEC('HS_EDIImp')"	,0, 3}, ; //"Importar"
{ OemToAnsi("Imp.LayOut")	,"HS_LayLoad"				,0, 3}, ; //"Imp.LayOut"
{ OemToAnsi("Exp.LayOut")	,"Hs_LayDump"				,0, 4}}  //"Exp.LayOut"


Private cCadastro := OemToAnsi("Cadastro de Layout")
Private cDado_EDI := ""
Private	lMark			:= .F.
Private cMark			:= GetMark()
Private cFiltro	:= ""
Private __aMarkBrw  := {}
Private nTotEDI := 0
Private cCodCNS := ""
Private cCodCBO := ""

DbSelectArea("GG8")
DbSelectArea("GG4")
DbSelectArea("GG3")
DbSelectArea("GG2")
DBSelectArea("SYP")
DbSelectArea("GG2")
DbSetOrder(1)

AjustaSX1()

aAdd(aCposGG2, { "GG2_IDMARC",, "", "" })

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("GG2")
Do While !Eof() .and. SX3->X3_ARQUIVO == "GG2"
	If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL .and. SX3->X3_BROWSE == "S" ;
		.and. SX3->X3_CONTEXT <> "V" .and. !SX3->X3_CAMPO$"GG2_IDMARC"
		aAdd(aCposGG2, {SX3->X3_CAMPO,, SX3->X3_TITULO, SX3->X3_PICTURE })
	Endif
	
	DbSkip()
Enddo


MarkBrowse("GG2", "GG2_IDMARC",, aCposGG2, .F., cMark, "HS_M52MALL(@__aMarkBrw)",,,,,{|| oMB := GetMarkBrow(), oMB:bMark := {|| HS_M52MARK(@__aMarkBrw, "GG2_IDMARC", "GG2->GG2_CODPAR") }}, cFiltro, .T.)
//mBrowse( 6, 1, 22, 75,"GG2",,,,,,)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_M52MALL(aMBrow, cCondSql, lDesmarca)
Local cSql  := ""
Local aArea := GetArea()

Default cCondSql := PrefixoCpo("GG2") + "_FILIAL = '" + xFilial("GG2") + "' AND D_E_L_E_T_ <> '*'"
Default lDesmarca := ThisInv()

CursorWait()

NewMark()

SetInvert(!lDesmarca)

If !lDesmarca
	aMBrow := {}
	cSql := "SELECT GG2_CODPAR FROM " + RetSqlName("GG2") + " WHERE " + cCondSql
	cSql += " ORDER BY "+SqlOrder(GG2->(IndexKey()))
	
	TCQUERY cSql NEW ALIAS "QRYMRK"
	
	While !Eof()
		aAdd(aMBrow, {QRYMRK->GG2_CODPAR})
		DBSkip()
	End
	
	DbCloseArea()
Else
	aMBrow := {}
EndIf

CursorArrow()

RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */

Function HS_M52MARK(aMBrow, cCpoMark, cCpoChv)

Local nPSolici := 0

IF IsMark(cCpoMark, ThisMark(), ThisInv())
	aAdd(aMBrow, {GG2->GG2_CODPAR})
ElseIf (nPSolici := aScan(aMBrow, {| aVet | aVet[1] == &(cCpoChv)})) > 0
	aDel(aMBrow, nPSolici)
	aSize(aMBrow, Len(aMBrow) - 1)
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */

Function Hs_M52EXEC(cFuncao)
Local nFor   := 0
Local cParametro := IF(at("(",cFuncao) > 0,"","(cAlias, nRecNo)")

Private cAlias := "", nRecNo := 0, nOpcE := 0

//Solicitado que comandos CTREE fossem removidos, portanto nใo ้ possํvel exporta็ใo pra 
if GG2->GG2_TIPARQ = "2"
	Alert("Tipo de exporta็ใo descontinuada !")
	Return()
EndIf

For nFor := 1 To Len(__aMarkBrw)
	
	IIF(Alias()         # "GG2"              , DbSelectArea("GG2"), Nil)
	IIF(IndexOrd()      # 1                  , DbSetOrder(1), Nil) // GG2_FILIAL+GG2_CODPAR
	IIF(GG2->GG2_CODPAR # __aMarkBrw[nFor][1], DbSeek(xFilial("GG2") + __aMarkBrw[nFor][1]), Nil)
	
	cAlias := Alias()
	nRecNo := &(cAlias+"->(RecNo())")
	
	If !Hs_ExisDic({{"C", "GG2_FVLLAY"}},.F.) .Or. (Empty(GG2->GG2_FVLLAY) .Or. &(GG2->GG2_FVLLAY))
		//Begin Transaction
		Processa({ || &(cFuncao+cParametro)},"Processando Layout ["+GG2->GG2_CODPAR+"]")
		//End Transaction
	EndIf
	
Next nFor
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿  */

Function HS_ImpXml(cAlias, nReg, nOpc)

If !(GG2->GG2_MODINT $ "N/A")
	Hs_msgInf("Layout de Importa็ใo, opera็ใo nใo pode ser efetuada","Aten็ใo","Valida็ใo Layout")
	Return()
EndIf

Processa({|| FS_ImpXml()})
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */

Static Function FS_ImpXml()
Local oXml
Local cError := "", cWarning := "", cXmlName := "", cMask := "Arquivos TISS (*.XML) |*.XML|"

Private cItem := "000", cVersion := "", __cXmlHash := "", __cMD5Hash := "", lGrvLOut := .T.

If Empty(cXmlName := cGetFile(cMask, OemToAnsi("Selecione o arquivo"))) //, 1, "\EDI\TISS\", .F., GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY))
	Return(Nil)
EndIf

lGrvLOut := (MsgYesNo("Gera LayOut EDI"))

ProcRegua(0)

// Coisa pro futuro
//oXml := XmlParserFile ( "\EDI\TISS\tissV2_01_02.xsd" , "_" , @cError, @cWarning)

oXml := XmlParserFile(cXmlName/*"\EDI\TISS\GEAP.XML"*/, "_", @cError, @cWarning)

FT_FUSE(cXmlName/*"\EDI\TISS\GEAP.XML"*/) //C:\Protheus8\Protheus_Data
FT_FGoTop()

While !FT_FEof()
	
	If ("xml version" $ (cVersion := FT_FReadLn()))
		Exit
	EndIf
	
	FT_FSkip()
End

FT_FUse()

Begin Transaction
FS_GrvXml(XmlGetChild(oXml, 1), "00", .T.)
End Transaction

__cMD5Hash := MD5(__cXmlHash, 2)

HS_MsgInf("Hash [" + __cMD5Hash + "]" + Chr(13) + Chr(10) + "Valor [" + __cXmlHash + "]", "Aten็ใo", "Xml Hash")

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */

Static Function FS_GrvXml(oXml, cNivel, lGrava)
Local oXmlFilho
Local nXml1 := 1
Local nXml2 := 1

cNivel := Soma1(cNivel, 2)

For nXml1 := 1 To XmlChildCount(oXml)
	oXmlFilho := XmlGetChild(oXml, nXml1)
	
	If lGrvLOut .And. lGrava
		
		If (cNivel == "01")
			cCodGru := FS_GrvGG0(oXmlFilho, IIf(IIf(ValType(oXmlFilho) == "A", oXmlFilho[1], oXmlFilho):Type == "ATT", oXml:RealName, Nil))
			cItem := "000"
		EndIf
		
		IncProc(IIf(ValType(oXmlFilho) == "A", oXmlFilho[1]:RealName, oXmlFilho:RealName))
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Item [" + cItem + "] Nivel [" + cNivel + "][" + oXml:RealName + "/" + IIf(ValType(oXmlFilho) == "A", oXmlFilho[1]:RealName, oXmlFilho:RealName) + "]" , 0, 0, {})
		
		If !Empty(cVersion)
			FS_GrvGG1(cCodGru, Nil, "00", cVersion)
			cVersion := ""
		EndIf
		
		FS_GrvGG1(cCodGru, IIf(ValType(oXmlFilho) == "A", oXmlFilho[1], oXmlFilho), cNivel, IIf(IIf(ValType(oXmlFilho) == "A", oXmlFilho[1], oXmlFilho):Type == "ATT", oXml:RealName, Nil))
		
	EndIf
	
	If ValType(oXmlFilho) == "A"
		For nXml2 := 1 To Len(oXmlFilho)
			If XmlChildCount(oXmlFilho[nXml2]) > 0
				FS_GrvXml(oXmlFilho[nXml2], cNivel, nXml2 == 1)
			ElseIf oXmlFilho[nXml2]:REALNAME <> "ans:hash" .And. oXmlFilho[nXml2]:REALNAME <> "ans:mensagemTISS" .And. oXmlFilho[nXml2]:REALNAME <> "xmlns:ans" .And. !Empty(oXmlFilho[nXml2]:Text)
				__cXmlHash += oXmlFilho[nXml2]:Text
			EndIf
		Next
	Else
		If XmlChildCount(oXmlFilho) > 0
			FS_GrvXml(oXmlFilho, cNivel, nXml2 == 1)
		ElseIf oXmlFilho:REALNAME <> "ans:hash" .And. oXmlFilho:REALNAME <> "ans:mensagemTISS" .And. oXmlFilho:REALNAME <> "xmlns:ans" .And. !Empty(oXmlFilho:Text)
			__cXmlHash += oXmlFilho:Text
		EndIf
	EndIf
	
Next nXml1

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_GrvGG0(oXmlFilho, cRealName)

DbSelectArea("GG0")
RecLock("GG0", .T.)
GG0->GG0_FILIAL := xFilial("GG0")
GG0->GG0_CODGRU := HS_VSxeNum("GG0", "M->GG0_CODGRU", 1)
GG0->GG0_SEGMEN := IIf(!Empty(cVersion), "1", "2")
GG0->GG0_NOMGRU := IIf(cRealName <> Nil, cRealName, oXmlFilho:RealName)
MsUnLock()
ConfirmSx8()

Return(GG0->GG0_CODGRU)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_GrvGG1(cCodGru, oXmlFilho, cNivel, cRealName)

cItem := Soma1(cItem, 3)

DbSelectArea("GG1")
RecLock("GG1", .T.)
GG1->GG1_FILIAL := xFilial("GG1")
GG1->GG1_CODGRU := cCodGru
GG1->GG1_ITEM   := cItem
GG1->GG1_SEGMEN := IIf(!Empty(cVersion) .Or. cRealName <> Nil, "1", "2")
GG1->GG1_TIPREG := "C"
GG1->GG1_ORDCAM := cItem
GG1->GG1_TAMCAM := "000"
GG1->GG1_DECIMA := 0
GG1->GG1_PICCAM := ""

If !Empty(cVersion)
	GG1->GG1_COLUNA := ""
	GG1->GG1_FUNEXP := "'" + cVersion + "'"
	
ElseIf cRealName <> Nil
	GG1->GG1_COLUNA := ""
	GG1->GG1_FUNEXP := "'" + cRealName + " " + oXmlFilho:RealName + '="' + oXmlFilho:Text + '"' + "'"
	
ElseIf XmlChildCount(oXmlFilho) == 0
	GG1->GG1_COLUNA := '"' + oXmlFilho:RealName + '"'
	GG1->GG1_FUNEXP := '"' + AllTrim(oXmlFilho:Text) + '"'
	
Else
	GG1->GG1_COLUNA := ""
	GG1->GG1_FUNEXP := '"' + oXmlFilho:RealName + '"'
EndIf

GG1->GG1_GRPREP := ""
GG1->GG1_QTDREP := 0
GG1->GG1_NNIVEL := cNivel
GG1->GG1_MODEXP := "1"
MsUnLock()

Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Function HS_RotEdi(cAlias, nReg, nOpc)

Local nOpcG  := aRotina[nOpc, 4]
Local nOpA 		:= ""
Local nGDOpc := IIf( Inclui .Or. Altera, GD_INSERT + GD_UPDATE + GD_DELETE, 0)
Local nLenGD := 0, nTabelas := 0
Local aButtons := {{'FORM',{|| Processa({|| HS_EDIVeri("B")}) } ,"Analisar"}}
Local bKeyF6		:=	SetKey(VK_F6, {|| IIf(PadR(SubStr(ReadVar(), 4), 10) $ "M->GG2_FILTRO", HS_FilPEDI(&("M->GG2_ARQPAI")) , Nil)})
Local aCposGG2 := {}
Local aMemoGG2 := {}
Local aFolder  := {}
Local nCont    := 0

Private aTela  := {}, aGets := {}, aPObjs := {}, aPGDs := {}, aSize := {}, aObjects := {}
Private aHGG3  := {}, aCGG3 := {}, aHGG4  := {}, aCGG4 := {}, aHGG8 := {}, aCGG8    := {}
Private aGg8Gd := {}
Private nUGG3  := 0, nUGG4 := 0, nLGG3 := 0, nUGG8 := 0
Private oDlg, oGG3 , oGG4, oGG5, oEnchoi, oFolGDs
Private nGG3Item   := 0, nGG3TipReg := 0, nGG3CodGru := 0, nGG4Item  := 0, nGG4DesArq := 0, nGG4Arquiv := 0
Private nGG4Instru := 0, nGG8Item   := 0, nAtAnt     := 1, nPosACols := 0
Private nGG8Campo  := 0, nGG8NomCpo := 0
Private cGG0TipReg := "", cSx3CodTab := ""

Private cFiltro := "", cFilRel := "", cRetSx3 := "" // Retorno para Consultas padrao
Private cArqPri := "M->GG2_ARQPAI", cACols  := "oGG4:aCols", cNPosArq := "nGG4Arquiv"
Private cCpoFilRel := "oGG4:aCols[oGG4:nAt, nGG4Instru]"
Private cCpoSX3   := "oGG8:aCols[oGG8:nAt, nGG8Campo]"
Private aTravas := {}

If !Hs_LockTab(@aTravas, cAlias,,aRotina[nOpc, 4])
	Return(nil)
EndIf

RegToMemory("GG2", (nOpcG == 3))

DbSelectArea("SX3")
DbSetOrder(1)
If DbSeek("GG2")
	While !SX3->(EoF()) .And. SX3->X3_ARQUIVO == "GG2"
		If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
			If X3_TIPO == "M" .And. X3_PROPRI # "U"
				_SetOwnerPrvt("o"+X3_CAMPO)
				aAdd(aMemoGG2, {X3_CAMPO, X3_TITULO, X3_VALID, X3_FOLDER, X3_WHEN, "o"+X3_CAMPO})
			Else
				aAdd(aCposGG2, X3_CAMPO)
			EndIf
		EndIF
		DbSkip()
	End
EndIf

aAdd(aFolder, "Dados Gerais")
For nCont := 1 to Len(aMemoGG2)
	aAdd(aFolder, aMemoGG2[nCont, 2])
Next

nLGG3 := HS_BDados("GG3", @aHGG3, @aCGG3, @nUGG3, 1,, IIf((nOpcG == 3), Nil, "GG3->GG3_CODPAR == '" + M->GG2_CODPAR + "'"),Nil)

HS_BDados("GG4", @aHGG4, @aCGG4, @nUGG4, 1,, IIf((nOpcG == 3), Nil, "GG4->GG4_CODPAR == '" + M->GG2_CODPAR + "'"),Nil)

nGG3Item   := aScan(aHGG3, {| aVet | AllTrim(aVet[2]) == "GG3_ITEM"  })
nGG3TipReg := aScan(aHGG3, {| aVet | AllTrim(aVet[2]) == "GG3_TIPREG"})
nGG3CodGru := aScan(aHGG3, {| aVet | AllTrim(aVet[2]) == "GG3_CODGRU"})

nGG4Item   := aScan(aHGG4, {| aVet | AllTrim(aVet[2]) == "GG4_ITEM"  })
nGG4DesArq := aScan(aHGG4, {| aVet | AllTrim(aVet[2]) == "GG4_DESARQ"})
nGG4Arquiv := aScan(aHGG4, {| aVet | AllTrim(aVet[2]) == "GG4_ARQUIV"})
nGG4Instru := aScan(aHGG4, {| aVet | AllTrim(aVet[2]) == "GG4_INSTRU"})

For nTabelas := 1 To Len(aCGG4)
	
	aHGG8 := {}
	aCGG8 := {}
	nUGG8 := 0
	
	HS_BDados("GG8", @aHGG8, @aCGG8, @nUGG8, 1,, IIf((nOpcG == 3), Nil, "GG8->GG8_CODPAR == '" + M->GG2_CODPAR + "' .AND. GG8->GG8_SEQARQ == '" + aCGG4[nTabelas, nGG4Item] + "'" ),Nil)
	
	nGG8Item   := aScan(aHGG8, {| aVet | AllTrim(aVet[2]) == "GG8_ITEM"  })
	nGG8Campo  := aScan(aHGG8, {| aVet | AllTrim(aVet[2]) == "GG8_CAMPO" })
	nGG8NomCpo := aScan(aHGG8, {| aVet | AllTrim(aVet[2]) == "GG8_NOMCPO"})
	
	If Empty(aCGG8[1, nGG8Item])
		aCGG8[1, nGG8Item] := StrZero(1, Len(GG8->GG8_ITEM))
	EndIf
	
	aAdd(aGg8Gd, {nTabelas, {} })
	
	aGg8Gd[Len(aGg8Gd), 2] := aClone(aCGG8)
	
Next nFor

nAtAnt := Len(aGg8Gd)

If Empty(aCGG3[1, nGG3Item])
	aCGG3[1, nGG3Item] := StrZero(1, Len(GG3->GG3_ITEM))
EndIf

If Empty(aCGG4[1, nGG4Item])
	aCGG4[1, nGG4Item] := StrZero(1, Len(GG4->GG4_ITEM))
EndIf

aSize := MsAdvSize(.T.)
aObjects := {}

AAdd( aObjects, { 100, 050, .T., .T., .T. } )
AAdd( aObjects, { 100, 050, .T., .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
aPGDs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE OemToAnsi("Cadastro de Layout") From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd

oFolEnc := TFolder():New( aPObjs[1, 1],  aPObjs[1, 2], aFolder, aFolder, oDlg,,,, .T., , aPObjs[1, 3], aPObjs[1, 4] )
oFolEnc:Align := CONTROL_ALIGN_TOP

oEnchoi := MsMGet():New("GG2",nReg,nOpc, , , ,aCposGG2,{aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}, , , , , ,oFolEnc:aDialogs[1])
oEnchoi:oBox:align:= CONTROL_ALIGN_ALLCLIENT

For nCont := 1 to Len(aMemoGG2)
	&(aMemoGG2[nCont, 6]) := &("tMultiget():New("+AllTrim(str(aPObjs[1, 1]))+","+AllTrim(str(aPObjs[1, 2]))+",{|u|if(Pcount()>0,M->"+aMemoGG2[nCont, 1]+":=u,M->"+aMemoGG2[nCont, 1]+")},oFolEnc:aDialogs["+AllTrim(Str(nCont+1))+"],"+AllTrim(str(aPObjs[1, 3]))+","+AllTrim(str(aPObjs[1, 4]))+",,,,,,.T.)")
	&(aMemoGG2[nCont, 6]):Align := CONTROL_ALIGN_ALLCLIENT
Next

@ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolGDs SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts "Itens da Estrutura", "Tabelas Filho", "Campos Tab. Filho"

oGG3 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,,"+GG3_ITEM",,, 99999,,,, oFolGDs:aDialogs[1], aHGG3, aCGG3)
oGG3:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
oGG3:oBrowse:bGotFocus := {|| cGG0TipReg := oGG3:aCols[oGG3:nAt, nGG3TipReg]}
oGG3:bChange           := {|| cGG0TipReg := oGG3:aCols[oGG3:nAt, nGG3TipReg]}

oGG4 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,,"+GG4_ITEM",,, 99999,,,, oFolGDs:aDialogs[2], aHGG4, aCGG4)
oGG4:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
oGG4:bChange  	    := {|| FS_MudAcol() }

oGG8 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,,"+GG8_ITEM",,, 99999,,,, oFolGDs:aDialogs[3], aHGG8, aCGG8)
oGG8:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {	|| nOpA := 1,;
IIF(Obrigatorio(aGets, aTela) .And. oGG3:TudoOk();
.And. oGG4:TudoOk();
.And. oGG8:TudoOk();
.And. HS_EDIVeri("OK"),;
oDlg:End(), nOpA := 0)},;
{|| nOpA := 0, oDlg:End()},,aButtons)

If ValType(nOpA) <> "N"	// Caso na inclusao seja clicado no botao "x" superior
	Return()
EndIf

If (nOpA == 1) .And. (nOpcG <> 2)
	
	If (nPosACols := aScan(aGg8Gd, {| aVet | aVet[1] == nAtAnt})) == 0
		aAdd(aGg8Gd, {nAtAnt, {} })
		nPosACols := Len(aGg8Gd)
	EndIf
	
	aGg8Gd[nPosACols, 2] := aClone(oGG8:aCols)
	
	Begin Transaction
	FS_GrvEst(nOpcG)
	While __lSx8
		ConfirmSx8()
	End
	End Transaction
	
ElseIf nOpcG <>2
	While __lSx8
		RollBackSxe()
	End
Endif

HS_UnLockT(@aTravas)
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_GrvEst(nOpcG)
Local lAchou := .T.

DbselectArea("GG2")
DbsetOrder(1) //GG2_FILIAL+GG2_CODPAR
lAchou := DbSeek(xFilial("GG2") + M->GG2_CODPAR)

If nOpcG == 3 .or. nOpcG == 4   // INCLUSAO ou ALTERACAO
	RecLock("GG2", !lAchou)
	HS_GRVCPO("GG2")
	GG2->GG2_FILIAL  := xFilial("GG2")
	MsUnlock()
	
	FS_GrvGD("GG3", 1, oGG3, nGG3Item, nOpcG, nGG3CodGru)
	FS_GrvGD("GG4", 1, oGG4, nGG4Item, nOpcG, nGG4Arquiv)
	
Else // EXCLUSAO
	
	FS_GDExc("GG3", 1)
	FS_GDExc("GG4", 1)
	FS_GDExc("GG8", 1)
	
	RecLock("GG2", .F., .T.)
	DbDelete()
	MsUnlock()
	WriteSx2("GG2")
EndIf
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_GrvGD(cAlias, nOrdem, oGet, nPosItem, nOpcG, nPosPrinc)

Local nFor     := 0, nPosACols := 0
Local lAchou   := .F.
Local cPrefixo :=  cAlias + "->" + PrefixoCpo(cAlias)

DbSelectArea(cAlias)
DbSetOrder(nOrdem)

For nFor :=1 To Len(oGet:aCols)
	If !Empty(oGet:aCols[nFor, nPosPrinc])
		lAchou := DbSeek(xFilial(cAlias) + M->GG2_CODPAR + oGet:aCols[nFor, nPosItem])
		If oGet:aCols[nFor, Len(oGet:aHeader)+1 ]== .T.  // Se a linha esta deletada na get e achou o kra no banco
			If lAchou .And. nOpcG <> 3
				RecLock(cAlias, .F., .F. )
				DbDelete()
				MsUnlock()
				WriteSx2(cAlias)
			EndIf
		Else
			RecLock(cAlias, !lAchou )
			HS_GRVCPO(cAlias, oGet:aCols, oGet:aHeader, nFor)
			&(cPrefixo + "_FILIAL") := xFilial(cAlias)
			&(cPrefixo + "_CODPAR") := M->GG2_CODPAR
			MsUnlock()
			If cAlias == "GG4"
				If (nPosACols := aScan(aGg8Gd, {| aVet | aVet[1] == nFor})) > 0
					FS_GrvGG8("GG8", 1, aGg8Gd[nPosACols, 2], oGG8:aHeader,oGet:aCols[nFor, nPosItem], nGG8Item, GG4->GG4_ARQUIV, nOpcG)
				EndIf
			EndIf
		EndIf
	EndIf
Next

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_GrvGG8(cAlias, nOrdem, aCols, aHeader, cSeqArq, nPosItem, cChave, nOpcG)
Local aArea  := GetArea()
Local lAchou := .F.
Local nFor   := 0
Local cPrefixo :=  cAlias + "->" + PrefixoCpo(cAlias)

DbSelectArea(cAlias)
DbSetOrder(nOrdem) //GG8_FILIAL+GG8_CODPAR+GG8_SEQARQ+GG8_ITEM
For nFor := 1 To Len(aCols)
	lAchou := DbSeek(xFilial(cAlias) + M->GG2_CODPAR + cSeqArq + aCols[nFor, nPosItem])
	If acols[nFor, Len(aHeader) + 1] == .T.
		If lAchou .And. nOpcG <> 3
			RecLock(cAlias, .F., .F. )
			DbDelete()
			MsUnlock()
			WriteSx2(cAlias)
		EndIf
	Else
		RecLock(cAlias, !lAchou )
		HS_GRVCPO(cAlias, aCols, aHeader, nFor)
		&(cPrefixo + "_FILIAL") := xFilial(cAlias)
		&(cPrefixo + "_CODPAR") := M->GG2_CODPAR
		&(cPrefixo + "_ARQUIV") := cChave
		&(cPrefixo + "_SEQARQ") := cSeqArq
		MsUnlock()
	EndIf
Next

RestArea(aArea)
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_GDExc(cAlias,nOrdem)
Local cPrefixo :=  cAlias + "->" + PrefixoCpo(cAlias)

DbSelectArea(cAlias)
DbSetOrder(nOrdem)
DbSeek(xFilial(cAlias) + M->GG2_CODPAR)
While !Eof() .And. &(cPrefixo + "_FILIAL") = xFilial(cAlias) .And. &(cPrefixo + "_CODPAR") = M->GG2_CODPAR
	RecLock(cAlias, .F., .F. )
	DbDelete()
	MsUnlock()
	WriteSx2(cAlias)
	DbSkip()
End

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ  HS_EdiSDir   ณ Autor ณ Rogerio Tabosa   ณ Data ณ17/01/2011ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ  Fun็ใo para selecionar diretorio ou arquivo atrav้s do cpoณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ  Retorna Verdadeiro ou Falso                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ  Gestao Hospitalar                                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_EdiSDir()

Local aArea	   := GetArea()
Local cTipo			 := ""
Local cCpoVld  := ReadVar()

If Type("lSelectArq") # "U" .And. lSelectArq
	&(cCpoVld) 	:= cGetFile("*.JPG|*.jpg|*.bmp|*.BMP|*.png|*.PNG","Selecione o Arquivo",1 ,"c:\",.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE)   //"Selecione o Arquivo"
Else
	&(cCpoVld) 	:= cGetFile( cTipo , OemToAnsi("Selecione o Diret๓rio"),,,.F.,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY)
EndIf

RestArea(aArea)
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Function HS_EdiSRet()
Return( &(ReadVar()) )

Function HS_VCadEst()
Local aArea   := GetArea()
Local lRet    := .T.
Local cCpoVld := ReadVar()

If cCpoVld $ "M->GG2_ARQPAI/M->GG4_ARQUIV"
	DbSelectArea("SX2")
	DbSetOrder(1)
	If !DbSeek(&(cCpoVld))
		HS_MsgInf("Tabela nใo encontrada", "Aten็ใo", "Valida็ใo EDI")
		lRet := .F.
	Else
		If cCpoVld == "M->GG2_ARQPAI"
			M->GG2_DESARQ := X2Nome()
		ElseIf cCpoVld == "M->GG4_ARQUIV"
			oGG4:aCols[oGG4:nAt, nGG4DesArq ] := X2Nome()
			cSx3CodTab := oGG4:aCols[oGG4:nAt, nGG4Arquiv]
		EndIf
	EndIf
ElseIf cCpoVld == "M->GG2_PERGUN"
	DbSelectArea("SX1")
	DbSetOrder(1)
	If !DbSeek(&(cCpoVld))
		HS_MsgInf("Grupo de perguntas nใo encontrado", "Aten็ใo", "Valida็ใo EDI")
		lRet := .F.
	EndIf
ElseIf cCpoVld == "M->GG3_TIPREG"
	cGG0TipReg := M->GG3_TIPREG
	oGG3:aCols[oGG3:nAt, nGG3CodGru ] := CriaVar("GG3_CODGRU", .F.)
	
ElseIf cCpoVld == "M->GG3_CODGRU"
	If !(lRet := HS_SeekRet("GG0", "M->GG3_CODGRU", 1, .F., "GG3_DESGRU", "GG0_NOMGRU" ))
		HS_MsgInf("Grupo nใo encontrada", "Aten็ใo", "Valida็ใo EDI")
	ElseIf !(lRet := (GG0->GG0_SEGMEN == oGG3:aCols[oGG3:nAt, nGG3TipReg] ))
		HS_MsgInf("Este grupo nใo ้ do tipo especificado no campo Tipo de Registro", "Aten็ใo", "Valida็ใo EDI")
	EndIf
	
ElseIf cCpoVld == "M->GG3_SEQUEN"
	M->GG3_SEQUEN := PADL(AllTrim(M->GG3_SEQUEN), 3, "0")
ElseIf cCpoVld == "M->GG2_ARQIMP"
	If !(lRet := File(&(cCpoVld)))
		Hs_MsgInf("Arquivo nใo encontrado", "Aten็ใo", "Valida็ใo EDI")
	EndIf
EndIf

RestArea(aArea)
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Function HS_PEDIExp(cAlias, nReg, nOpc)
Local cArq := ""
Private lEdiAuto   := IIf(Type("lAuto")<>"U",lAuto, .F.)

If !(GG2->GG2_MODINT $ "N/A")
	Hs_msgInf("Layout de Importa็ใo, opera็ใo nใo pode ser efetuada","Aten็ใo","Valida็ใo Layout")
	Return()
EndIf


If lEdiAuto .Or. MsgYesNo("EDI - Confirma gera็ใo de arquivo ? ")
	
	Processa({|| cArq := HS_EDIExp(cAlias, nReg, nOpc)})
	
EndIf

Return(cArq)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Function HS_EDIExp(cAlias, nReg, nOpcs)

Local aArea      := GetArea()
Local cExtensao  := AllTrim(HS_RDescrB("GG2_TIPARQ", GG2->GG2_TIPARQ))
Local bBlock     := ErrorBlock(), bErro := ErrorBlock( { |e| ChekBug(e) } )
Local nHandle    := 0
Local cSqlGG4    := "", cAux  := "", cArq   := "", cSql := "", cJoin := "", cLinha := "", cWhereFil := ""
Local aCpoData   := {}, aJoin := {}, cChave := "", cGrupo := "", cChaveRem := "", cCondQbr := ""
Local cArqTmp := "", cArqDef := "", cGG2Direct := AllTrim(GG2->GG2_DIRECT), cGG2NomArq := AllTrim(GG2->GG2_NOMARQ)
Local aLayOut    := {}, aCampos := {}
Local nFor       := 0, nLayOut := 0, nPosArqPai := 0, nPosAux := 0, nLoop := 0, nField := 0
Local cJoinPai   := "", cFilGG2 := "", cModoInt := GG2->GG2_MODINT
Local cTipArq    := GG2->GG2_TIPARQ
Local aGrpCpoRep := {}, nGrpRep := 0, nCpoRep := 0, nPosGrpLOut := 0, nPosIteLOut := 0, nPosInsLO := 0, cCodItem := ""
Local aCopyItens := {}, nColuna := 0, nLOutOld := 0, aTemItens := {}, aFields := {}
Local cTipoForm  := ""
Local lRSeq      := .F.
Local cCodCrm    := ""
LOCAL  cCnsProf   := ""
Local cRegAte    := "" , cRegAt    := ""
Local nIten   := 0
Local nRecProc := 0
Local aNumProc := {}, cReg := "", nTotProc := 0
Local cProOpm := '070203%'
Local cProNas := GetMv("MV_PROREG", ,"")
Local nContReg := 0
Local nCntAih  	:= 0

Local lPerg	:= .T.

Private __aTagsFim := {}
Private __lIncReme := .T. // Usado na fun็ใo HS_IncRem para definir se incrementa o sequencial da remessa, .F. nใo incrementa.
//Private nHdlCnt    := fCreate("conteudoXMLHSP.Log", 0)
Private cNumseq := 0
Private nLinReg := 0

//Variแveis Private da chamada da rotina pelo lote de cobran็a e intercโmbio
IF Type('cLoteEDI') == "C" .AND. Type('cTipoEDI') == "C"
	If !EmpTy(AllTrim(cLoteEDI)) .AND. !EmpTy(AllTrim(cTipoEDI))
		lPerg := .F.
	EndIf
EndIf

If !lEdiAuto .And. !Empty(GG2->GG2_PERGUN)
	If (lPerg)
		If !Pergunte(GG2->GG2_PERGUN, .T.)
			Return(.F.)
		EndIf
	else
		Pergunte(GG2->GG2_PERGUN, .F.)
	EndIf
EndIf

ProcRegua(0)

FS_CamMac(GG2->GG2_CAMMAC)

IncProc(OemToAnsi("Carregando inicializa็๕es..."))

If cModoInt $ "N"
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(GG2->GG2_ARQPAI)
	While SX3->X3_ARQUIVO == GG2->GG2_ARQPAI
		If SX3->X3_TIPO == "D"
			aAdd(aCpoData, {SX3->X3_CAMPO, "" } )
		EndIf
		SX3->(DbSkip())
	End
	
	cFilGG2 := E_MSMM(GG2->GG2_MFILTR)
	
	cFilGG2 := FS_EDiRQry(cFilGG2)
	//MONTAGEM DA QUERY DE ACORDO COM A ESTRUTURA CRIADA PELO USUARIO
	cSelect :=  "SELECT " + GG2->GG2_ARQPAI + ".* "
	cFrom   := " FROM " + RetSqlName(GG2->GG2_ARQPAI) + " " + GG2->GG2_ARQPAI + " "
	cWhere  := " WHERE " + GG2->GG2_ARQPAI + ".D_E_L_E_T_ <> '*' AND "
	cWhere  +=     GG2->GG2_ARQPAI + "." + GG2->GG2_ARQPAI + "_FILIAL = '" + xFilial(GG2->GG2_ARQPAI) + "' "
	If !Empty(cFilGG2)
		cWhere  += " AND " + cFilGG2 + " "
	EndIf
EndIf

//QUERY QUE BUSCA O LAYOUT QUE VAI SER SEGUIDO DURANTE A EXPORTACAO
cSqlLayOut := "SELECT * "
cSqlLayOut += "FROM " + RetSqlName("GG3") + " GG3 "
cSqlLayOut +=   "JOIN " + RetSqlName("GG1") + " GG1 ON GG1.D_E_L_E_T_ <> '*' AND GG1.GG1_FILIAL = '" + xFilial("GG1") + "' AND "
cSqlLayOut +=       "GG1.GG1_CODGRU = GG3.GG3_CODGRU "
cSqlLayOut += "WHERE GG3.D_E_L_E_T_ <> '*' AND GG3.GG3_FILIAL = '" + xFilial("GG3") + "' AND GG3.GG3_CODPAR = '" + GG2->GG2_CODPAR + "' "
cSqlLayOut += "ORDER BY GG3.GG3_FILIAL, GG3.GG3_SEQUEN, GG1.GG1_ORDCAM"

cSqlLayOut := ChangeQuery(cSqlLayOut)

TCQuery cSqlLayOut New Alias "LAYOUT"

DbSelectArea("LAYOUT")
DbGotop()

IncProc(OemToAnsi("Verificando LayOut..."))

//O LayOut sera colocado em um array para possibilitar reposicionamento...
cGrupo := ""
While !Eof()

	If cTipArq == "2" .And. !Empty(LAYOUT->GG1_COLUNA)// DBF
		aAdd(aCampos, {LAYOUT->GG1_COLUNA, LAYOUT->GG1_TIPREG, Val(LAYOUT->GG1_TAMCAM), LAYOUT->GG1_DECIMA} )
		
	ElseIf cTipArq == "2"
		DbSelectArea("LAYOUT")
		DbSkip()
		Loop
		
	EndIf
	
	IncProc(OemToAnsi("Verificando LayOut..."))
	
	If !Empty(LAYOUT->GG1_COLUNA) .And. !Empty(LAYOUT->GG1_GRPREP) .And. LAYOUT->GG1_QTDREP > 0
		If (nCpoRep := aScan(aGrpCpoRep, {| aVet | aVet[1] == LAYOUT->GG1_GRPREP})) == 0
			aAdd(aGrpCpoRep, {LAYOUT->GG1_GRPREP, LAYOUT->GG1_QTDREP - 1, LAYOUT->GG1_CODGRU, {LAYOUT->GG1_COLUNA}})
		Else
			aAdd(aGrpCpoRep[nCpoRep][4], LAYOUT->GG1_COLUNA)
		EndIf
	EndIf
	
	If cGrupo <> LAYOUT->GG3_CODGRU
		aAdd(aLayOut, {LAYOUT->GG3_CODGRU, LAYOUT->GG3_TIPREG, {}})
	EndIf
	
	aAdd(aLayOut[Len(aLayOut), 3] , {LAYOUT->GG1_TAMCAM, ;
	IIf(LAYOUT->GG3_TIPREG $ "45", StrTran(LAYOUT->GG1_FUNEXP, "HSPEDI->","TMPPAI->" ), LAYOUT->GG1_FUNEXP), ;
	LAYOUT->GG1_COLUNA, ;
	LAYOUT->GG1_GRPREP, ;
	LAYOUT->GG1_NNIVEL, ;
	LAYOUT->GG1_MODEXP, ;
	LAYOUT->GG1_CONEXP, ;
	LAYOUT->GG1_TIPREG})
	
	cGrupo := LAYOUT->GG3_CODGRU
	DbSelectArea("LAYOUT")
	DbSkip()
End

If Len(aGrpCpoRep) > 0 // Campos com repeti็ใo por grupo
	For nGrpRep := 1 To Len(aGrpCpoRep)
		If (nPosGrpLOut := aScan(aLayOut, {| aVet | aVet[1] == aGrpCpoRep[nGrpRep][3]})) > 0
			aCopyItens := {}
			For nCpoRep := 1 To Len(aGrpCpoRep[nGrpRep][4])
				If (nPosIteLOut := aScan(aLayOut[nPosGrpLOut][3], {| aVet | aVet[3] == aGrpCpoRep[nGrpRep][4][nCpoRep]})) > 0
					aAdd(aCopyItens, {aClone(aLayOut[nPosGrpLOut][3][nPosIteLOut]), IIf(cTipArq == "2", aClone(aCampos[nPosIteLOut]), {})})
					nPosInsLO := nPosIteLOut
				EndIf
			Next
			
			If Len(aCopyItens) > 0
				aSize(aLayOut[nPosGrpLOut][3], Len(aLayOut[nPosGrpLOut][3]) + (Len(aGrpCpoRep[nGrpRep][4]) * aGrpCpoRep[nGrpRep][2]))
				If cTipArq == "2"
					aSize(aCampos, Len(aCampos) + (Len(aGrpCpoRep[nGrpRep][4]) * aGrpCpoRep[nGrpRep][2]))
				EndIf
				For nCpoRep := 1 To aGrpCpoRep[nGrpRep][2]
					
					For nColuna := 1 To Len(aCopyItens)
						cCodItem := Right(AllTrim(aCopyItens[nColuna][1][3]), 1)
						cCodItem := SubStr(AllTrim(aCopyItens[nColuna][1][3]), 1, Len(AllTrim(aCopyItens[nColuna][1][3])) - 1) + Soma1(cCodItem, 1)
						aCopyItens[nColuna][1][3] := cCodItem
						
						If cTipArq == "2"
							cCodItem := Right(AllTrim(aCopyItens[nColuna][2][1]), 1)
							cCodItem := SubStr(AllTrim(aCopyItens[nColuna][2][1]), 1, Len(AllTrim(aCopyItens[nColuna][2][1])) - 1) + Soma1(cCodItem, 1)
							aCopyItens[nColuna][2][1] := cCodItem
							
						EndIf
						
						nPosInsLO++
						aIns(aLayOut[nPosGrpLOut][3], nPosInsLO)
						aLayOut[nPosGrpLOut][3][nPosInsLO] := aClone(aCopyItens[nColuna][1])
						
						If cTipArq == "2"
							aIns(aCampos, nPosInsLO)
							aCampos[nPosInsLO] := aClone(aCopyItens[nColuna][2])
							
						EndIf
					Next
					
				Next
			EndIf
		EndIf
	Next
EndIf

DbSelectArea("LAYOUT")
DbCloseArea()

// Monta nome do arquivo que serแ renomenado no final do precesso de exporta็ใo do EDI
cArqTmp := CriaTrab(Nil, .F.) + "." + cExtensao

If cTipArq == "2" // DBF
	Return()
Else
	nHandle := fCreate(cArqTmp)
	
EndIf

If cModoInt $ "N"
	
	//QUERY AUXILIAR QUE TRAZ AS TABELAS FILHO E OS SEUS RESPECTIVOS CAMPOS
	cSqlGG4 := "SELECT * "
	cSqlGG4 += "FROM " + RetSqlName("GG8") + " GG8 "
	cSqlGG4 +=  "JOIN " + RetSqlName("GG4") + " GG4 ON GG8.D_E_L_E_T_ <> '*' AND GG4.GG4_FILIAL = '" + xFilial("GG4") + "' AND "
	cSqlGG4 +=     "GG4.GG4_ARQUIV = GG8.GG8_ARQUIV AND GG4.GG4_ITEM = GG8.GG8_SEQARQ AND GG4.GG4_CODPAR = '" + GG2->GG2_CODPAR + "' "
	cSqlGG4 += "WHERE GG8.D_E_L_E_T_ <> '*' AND GG8.GG8_FILIAL = '" + xFilial("GG8") + "' AND GG8.GG8_CODPAR = '" + GG2->GG2_CODPAR + "' "
	cSqlGG4 += "ORDER BY GG4.GG4_ORDARQ, GG8.GG8_SEQARQ, GG8.GG8_ITEM, GG8.GG8_ORDCPO"
	
	cSqlGG4 := ChangeQuery(cSqlGG4)
	
	TCQuery cSqlGG4 New Alias "TMPGG4"
	
	DbSelectArea("TMPGG4")
	DbGotop()
	
	IncProc(OemToAnsi("Montando estrutura de tabelas relacionadas..."))
	
	While !(TMPGG4->(Eof()))
		
		IncProc(OemToAnsi("Montando estrutura de tabelas relacionadas..."))
		
		cMudaArq := TMPGG4->GG4_ARQUIV + TMPGG4->GG8_SEQARQ
		cArq     := TMPGG4->GG4_ARQUIV
		cPrefArq := cArq + "."
		
		If TMPGG4->GG4_TIPREL == "0"  // 0=Um Para Um; 1=Um Para N
			cJoin    := "JOIN " + RetSqlName(cArq) + " " + cArq + " ON " + cArq + ".D_E_L_E_T_ <> '*' AND "
			cJoin    +=   cPrefArq + cArq + "_FILIAL = '" + xFilial(cArq) + "' "
			cJoin    +=   "AND " + AllTrim(TMPGG4->GG4_INSTRU) + " "
			If AT(GG2->GG2_ARQPAI + ".", TMPGG4->GG4_INSTRU) > 0
				cFrom    += cJoin
			EndIf
			cJoinPai := cJoin
		ElseIf TMPGG4->GG4_TIPREL == "1"
			cWhereFil := cArq + ".D_E_L_E_T_ <> '*' AND " + cPrefArq + cArq + "_FILIAL = '" + xFilial(cArq) + "' "
			cWhereFil += " AND " + AllTrim(TMPGG4->GG4_INSTRU) + " "
			
			aAdd(aJoin, {cArq, "", cWhereFil, TMPGG4->GG4_INSTRU } )
		EndIf
		
		While !(TMPGG4->(Eof())) .And. cMudaArq == TMPGG4->GG4_ARQUIV + TMPGG4->GG8_SEQARQ
			
			IncProc(OemToAnsi("Montando estrutura de tabelas relacionadas..."))
			
			If Empty(TMPGG4->GG8_CAMPO) .And. !Empty(TMPGG4->GG8_NOMCPO)
				cCpoFilho := ", '  ' " + TMPGG4->GG8_NOMCPO
			ElseIf !Empty(TMPGG4->GG8_CAMPO)
				DbSelectArea("SX3")
				DbSetOrder(2)
				If DbSeek(TMPGG4->GG8_CAMPO)
					cCpoFilho := ", " + cPrefArq + TMPGG4->GG8_CAMPO + " " + TMPGG4->GG8_NOMCPO
				Else
					cCpoFilho := ", " + TMPGG4->GG8_CAMPO + " " + TMPGG4->GG8_NOMCPO
				EndIf
			EndIf
			
			If !Empty(cCpoFilho)
				If TMPGG4->GG4_TIPREL == "0"// 0=Um Para Um; 1=Um Para N
					cSelect += cCpoFilho
				Else
					aJoin[Len(aJoin), 2] += cCpoFilho
				EndIf
			EndIf
			
			cCpoFilho := ""
			cMudaArq := TMPGG4->GG4_ARQUIV + TMPGG4->GG8_SEQARQ
			cArq := TMPGG4->GG4_ARQUIV
			
			If SX3->X3_CAMPO == TMPGG4->GG8_CAMPO .And. SX3->X3_TIPO == "D"
				aAdd(aCpoData, {SX3->X3_CAMPO, TMPGG4->GG8_NOMCPO } )
			EndIf
			
			DbSelectArea("TMPGG4")
			DbSkip()
		End
	End
	
	DbSelectArea("TMPGG4")
	DbCloseArea()
	
	cSql += cSelect + cFrom + cWhere
	
	If !Empty(GG2->GG2_ORDEBY)
		cSql += "ORDER BY " + GG2->GG2_ORDEBY
	EndIf
	
ElseIf cModoInt $ "A"
	DbSelectArea("GG2")
	cSql := IIF(GetSx3Cache("GG2->GG2_QRYPAI", "X3_CONTEXT") == "V", E_MSMM(GG2->GG2_MQRPAI), GG2->GG2_QRYPAI) //Verifica็ใo se o campo GG2_QRYPAI ้ real, para a gera็ใo de XML no PLS
	cSql := FS_EDiRQry(cSql)
EndIf

cSql := ChangeQuery(cSql)

DbUseArea(.T., "TOPCONN", TcGenQry(,, cSql), "TMPPAI", .F., .F.)


If cModoInt $ "N"
	For nFor := 1 to Len(aCpoData)
		If !Empty(aCpoData[nFor,2])
			TCSetField("TMPPAI", aCpoData[nFor,2], "D", 8, 0)
		Else
			TCSetField("TMPPAI", aCpoData[nFor,1], "D", 8, 0)
		EndIf
	Next
End

cChave := ""
cChaveRem := AllTrim(StrTran(GG2->GG2_CHVREM, GG2->GG2_ARQPAI + ".", "TMPPAI->"))
cCondQbr  := IIF(Hs_ExisDic({{"C","GG2_CONQBR"}},.F.) .And. !Empty(GG2->GG2_CONQBR),GG2->GG2_CONQBR, '.F.')

nLayOut := 1

DbSelectArea("TMPPAI")
nContReg := 0
nTotPai := 0
aNumProc := {}

If aLayOut[nLayOut][2] <> "7"
	While !Eof()
		nTotPai++
		If TMPPAI->(FieldPos("TPAIH"))>0
			aAdd(aNumProc, {TMPPAI->GE7_REGATE,TMPPAI->PROREL,Iif(nTotPai > 10,nTotProc:= nTotProc+1 ,nTotProc :=1),Iif(nContReg < 11 .And. !Empty(cRegAt) .And. cRegAt == TMPPAI->GE7_REGATE, nContReg := nContReg + 1 ,nContReg := 1)})
			cRegAt := TMPPAI->GE7_REGATE
		EndIf
		DbSkip()
	End
	
	If nTotPai > 100 .AND. cTipArq == "3" //xmL
		If !MsgYesNo("O arquivo possui mais de 100 guias para este lote, limite estipulado pela ANS, deseja gerar mesmo assim?","Aten็ใo")
			If Select("TMPPAI") > 0
				DbSelectArea("TMPPAI")
				DbCloseArea()
			EndIf
			Return(NIl)
		EndIf
	EndIf
	
	
	DbGotop()
	
EndIf
_SetOwnerPrvt("__cHXml", "")

nItePai := 1
While !(TMPPAI->(Eof()))
	
	IncProc(OemToAnsi("Aguarde enquanto o LayOut ้ interpretado..."))
	If aLayOut[nLayOut][2] == "7"
		HS_ExLOut(aLayOut, nLayOut, nHandle, , cTipArq, "ARQDBF")
		
		DbSkip()
		Loop
	EndIf
	
	While nLayOut <= Len(aLayOut) .And. !(TMPPAI->(Eof()))
		
		IncProc(OemToAnsi("Aguarde enquanto o LayOut ้ interpretado..."))
		
		nLOutOld  := 0
		//, '387287', '387296'
		If Select("HSPEDI") == 0 .And. aLayOut[nLayOut][2] $ "23"
			If aLayOut[nLayOut][2] == "2"
				nLOutOld := nLayOut
			EndIf
			
			While IIf(nLOutOld > 0 .And. aLayOut[nLOutOld][2] == "2", (nLayOut := aScan(aLayOut, {| aVet | aVet[2] == "3"}, ++nLayOut)) > 0, .T.)
				
				If cModoInt $ "N"
					cSql := ""
					//Montagem da query com os itens
					//UNION com as tabelas filho(1-N)
					For nFor := 1 To Len(aJoin)
						IncProc(OemToAnsi("Aguarde enquanto o LayOut ้ interpretado..."))
						If nFor > 1
							cSql += " UNION ALL "
						EndIf
						cWhere := aJoin[nFor,3]
						While (nPosArqPai := AT(GG2->GG2_ARQPAI + ".", cWhere)) > 0
							IncProc(OemToAnsi("Aguarde enquanto o LayOut ้ interpretado..."))
							//Tratamento para substituir os campos da chave no Join com os seus respectivos valores
							//para cada itera็ใo da tabela pai
							cAux  := Substr(cWhere, nPosArqPai + 4,Len(SX3->X3_CAMPO))
							cAux  := FS_EdiRCpo(cAux)
							cWhere := StrTran(cWhere, GG2->GG2_ARQPAI + "." + AllTrim(cAux) , "'" + &("TMPPAI->" + cAux) + "'" ,, 1)
						End
						cSql += cSelect + aJoin[nFor, 2]
						cSql += " FROM " + RetSqlName(aJoin[nFor, 1]) + " " + aJoin[nFor, 1] + " "
						cSql += " JOIN " + RetSqlName(GG2->GG2_ARQPAI) + " " + GG2->GG2_ARQPAI + " ON "
						cSql += aJoin[nFor, 4] + " "
						If !Empty(cJoinPai)
							cSql += cJoinPai
						EndIf
						cSql += " WHERE " + cWhere
					Next nFor
					
					If !Empty(GG2->GG2_ORDEBY)
						cSql += " ORDER BY " + GG2->GG2_ORDEBY
					EndIf
				ElseIf cModoInt $ "A"
					DbSelectArea("GG0")
					DbSetOrder(1)
					If DbSeek(xFilial("GG0") + aLayOut[nLayOut][1]) .And. !Empty(GG0->GG0_QRYFIL)
						//cSql := E_MSMM(GG0->GG0_MQRFIL)
						cSql := FS_EDiRQry(GG0->GG0_QRYFIL)
					Else
						DbSelectArea("GG2")
						cSql := IIF(GetSx3Cache("GG2->GG2_QRYFIL", "X3_CONTEXT") == "V", E_MSMM(GG2->GG2_MQRFIL), GG2->GG2_QRYFIL) //Verifica็ใo se o campo GG2_QRYFIL ้ real, para a gera็ใo de XML no PLS
						cSql := FS_EDiRQry(cSql)
					EndIf
				EndIf
				
				cSql := ChangeQuery(cSql)
				
				DbUseArea(.T., "TOPCONN", TcGenQry(,, cSql), "HSPEDI", .F., .F.)
				
				If cModoInt $ "N"
					For nFor := 1 to Len(aCpoData)
						If !Empty(aCpoData[nFor,2])
							TCSetField("HSPEDI", aCpoData[nFor,2], "D", 8, 0)
						Else
							TCSetField("HSPEDI", aCpoData[nFor,1], "D", 8, 0)
						EndIf
					Next
				EndIf
				
				DbSelectArea("HSPEDI")
				DbGotop()
				
				If nLOutOld > 0 .And. aLayOut[nLOutOld][2] == "2"
					aAdd(aTemItens, {nLayOut, HSPEDI->(!Eof())})
					DbCloseArea()
					DbSelectArea("TMPPAI")
				EndIf
				
				If nLOutOld == 0 //.Or. lTemItens .Or. aLayOut[nLOutOld][2] <> "2"
					Exit
				EndIf
				
			End
			
			If nLOutOld > 0
				nLayOut := nLOutOld
			EndIf
		EndIf
		
		cChave := &(cChaveRem)

		If aLayOut[nLayOut, 2] $ "12" //Cabecalho
			If aLayOut[nLayOut, 2] == "2" .And. nLoop == 0
				nLoop := nLayOut
			EndIf

			IncProc(OemToAnsi("Gravando dados..."))
			
			If aLayOut[nLayOut, 2] == "1" .Or. aScan(aTemItens, {| aVet | aVet[2]}) > 0
				
				If TMPPAI->(FieldPOS("TPFORM"))>0
					If (!Empty(cTipoForm)  .And. TMPPAI->TPFORM<> cTipoForm)  .Or. (!Empty(cCodCrm) .And. cCodCrm   <> TMPPAI->CODCRM) .OR. (!Empty(cCnsProf) .And. cCnsProf  <> TMPPAI->CODCNS)
						lRSeq := .T.
						If (!Empty(cTipoForm)  .And. TMPPAI->TPFORM<> cTipoForm)
							cNumfolha := 0
						EndIf
					Else
						lRSeq := .F.
					EndIf
					
					cTipoForm := TMPPAI->TPFORM
					cCodCrm   := TMPPAI->CODCRM
					cCnsProf  := TMPPAI->CODCNS
				EndIf
				
				If TMPPAI->(FieldPos("TPAIH"))>0
					If  (!Empty(cRegAte) .And. cRegAte  == TMPPAI->GE7_REGATE .And. nIten<>nItePai)
						DbSelectArea("TMPPAI")
						DbSkip()
						Loop
					EndIf
					
					If !TMPPAI->(Eof())
						cRegAte   := TMPPAI->GE7_REGATE
						nIten     := nItePai
						cProd     := Iif(nLayOut == 9 .Or. nLayOut == 10, cProNas, Iif (nLayOut == 6 .Or. nLayOut == 7, cProOpm,'%'))
					Else
						Exit
					EndIF
					
					If nLayOut == 6
						If  TMPPAI->TPEDI > 0
							HS_ExLOut(aLayOut, nLayOut, nHandle, , cTipArq, "ARQDBF",,,,lRSeq,cNumSeq)
						EndiF
					ElseIf nLayOut == 9
						If  TMPPAI->TPNAS > 0
							HS_ExLOut(aLayOut, nLayOut, nHandle, , cTipArq, "ARQDBF",,,,lRSeq,cNumSeq)
						EndiF
					Else
						HS_ExLOut(aLayOut, nLayOut, nHandle, , cTipArq, "ARQDBF",,,,lRSeq,cNumSeq)
					EndIf
				Else
					HS_ExLOut(aLayOut, nLayOut, nHandle, , cTipArq, "ARQDBF",,,,lRSeq,cNumSeq)
				Endif
			EndIf
			
			If Len(aLayOut) > nLayOut
				nLayOut++
				If TMPPAI->(FieldPos("TPAIH"))>0
					cProd     := Iif(nLayOut == 9 .Or. nLayOut == 10, cProNas, Iif (nLayOut == 6 .Or. nLayOut == 7, cProOpm,'%'))
				EndIf
			EndIf
			
		EndIf
		
		If Select("HSPEDI") > 0 .And. aLayOut[nLayOut, 2] == "3" //.And. aScan(aTemItens, {| aVet | aVet[1] == nLayOut .And. aVet[2]}) > 0 //Itens.....
			DbSelectArea("HSPEDI")
			nTotRec := 0
			
			While HSPEDI->(!Eof())
				nTotRec++
				/*    	If TMPPAI->(FieldPos("TPAIH"))>0
				aAdd(aNumProc, {HSPEDI->GE7_REGATE,HSPEDI->GD7_CODDES,Iif(nTotRec > 10,nTotProc:= nTotProc+1 ,nTotProc :=1),nTotRec})
				EndIf
				*/
				DbSkip()
			End
			
			If TMPPAI->(FieldPos("TPAIH"))>0
				DbGotop()
				If HSPEDI->(!Eof())
					nRecAtu := 0
					nRecProc := 0
			
					//Variavel utilizada para verificar se o layout sendo processado eh da interface do SISAIH01 ver 07.40, caso seja o loop sera realizado 9 vezes
					nCntAih := Iif(AllTrim(aLayout[2][3][46][3]) == "dai-codsol", 9, 10)
					While HSPEDI->(!Eof()) .Or. IIF(nLayOut == 9 .Or. nLayOut == 10, nRecProc < 8,nRecProc < nCntAih) 
		   				If HSPEDI->(!Eof()) .And. aScan(aNumProc, {| aVet | aVet[2] == HSPEDI->GE7_CODDES .And. aVet[1] == HSPEDI->GE7_REGATE})>0
							nLinReg := aNumProc[aScan(aNumProc, {| aVet | aVet[2] == HSPEDI->GE7_CODDES .And. aVet[1] == HSPEDI->GE7_REGATE})][4]
						Else
							nLinReg := 0
						EndIf
						
						nRecAtu++
						nRecProc++
						If !IIF(nLayOut == 9 .Or. nLayOut == 10, nRecProc < 9,nRecProc < 11)
							nRecProc := 1
							HS_ExLOut(aLayOut, nLayOut + 1, nHandle, , cTipArq, "ARQDBF",,,,lRSeq,cNumSeq)
							HS_ExLOut(aLayOut, nLayOut - 1, nHandle, , cTipArq, "ARQDBF",,,,lRSeq,cNumSeq)
						EndIf
						
						IncProc(OemToAnsi("Gravando dados..."))
						If nLayOut <> 10
							HS_ExLOut(aLayOut, nLayOut , nHandle, , cTipArq, "ARQDBF", aGrpCpoRep, nRecAtu == 1, nRecAtu == nTotRec)
						Else
							If nLayOut == 10 .And. TMPPAI->TPNAS >0
								HS_ExLOut(aLayOut, nLayOut , nHandle, , cTipArq, "ARQDBF", aGrpCpoRep, nRecAtu == 1, nRecAtu == nTotRec)
							EndIf
						EndIf
						
						DbSelectArea("HSPEDI")
						DbSkip()
					End
				EndIF
				
				DbSelectArea("HSPEDI")
				DbCloseArea()
			Else
				DbGotop()
				nRecAtu := 0
				While HSPEDI->(!Eof())
					nRecAtu++
					IncProc(OemToAnsi("Gravando dados..."))
					HS_ExLOut(aLayOut, nLayOut, nHandle, , cTipArq, "ARQDBF", aGrpCpoRep, nRecAtu == 1, nRecAtu == nTotRec)
					
					DbSelectArea("HSPEDI")
					DbSkip()
				End
				
				DbSelectArea("HSPEDI")
				DbCloseArea()
			EndIf
			
			DbSelectArea("TMPPAI")
			
			If aLayOut[nLayOut + 1 , 2] $ "2/3"
				nLayOut++
			ElseIf Len(aLayOut) > nLayOut .And. aLayOut[nLayOut + 1 , 2] $ "4/5"
				nLayOut++
			Else
				nLayOut := Iif (nLoop > 0, nLoop, Iif(Len(aLayOut) > nLayOut, nLayOut + 1, nLayOut))
			EndIf
			
			If TMPPAI->(FieldPos("TPAIH"))>0
				cProd     := Iif(nLayOut == 9 .Or. nLayOut == 10, cProNas, Iif (nLayOut == 6 .Or. nLayOut == 7, cProOpm,'%'))
			EndIf
		EndIf
		
		If aLayOut[nLayOut, 2] == "4"
			IncProc(OemToAnsi("Gravando dados..."))
			
			If  TMPPAI->(FieldPos("TPEDI"))>0  .And. nLayout == 8
				If TMPPAI->TPEDI >0
					HS_ExLOut(aLayOut, nLayOut, nHandle, , cTipArq, "ARQDBF",, nItePai == 1, nItePai == nTotPai)
				EndIf
			ElseIf TMPPAI->(FieldPos("TPNAS"))>0 .And.  nLayout == 11
				If TMPPAI->TPNAS >0
					HS_ExLOut(aLayOut, nLayOut, nHandle, , cTipArq, "ARQDBF",, nItePai == 1, nItePai == nTotPai)
				EndIf
			Else
				If aScan(aTemItens, {| aVet | aVet[2]}) > 0
					HS_ExLOut(aLayOut, nLayOut, nHandle,, cTipArq, "ARQDBF",, nItePai == 1, nItePai == nTotPai)
				EndIf
			EndIf
			If Len(aLayOut) > nLayOut
				nLayOut++
				If TMPPAI->(FieldPos("TPAIH"))>0
					cProd     := Iif(nLayOut == 9 .Or. nLayOut == 10, cProNas, Iif (nLayOut == 6 .Or. nLayOut == 7, cProOpm,'%'))
				EndIf
			EndIf
		EndIf
		
		If !(aLayOut[nLayOut, 2] $ "123") .Or. (nItePai == nTotPai .And. Len(aTemItens) > 0 .And. aScan(aTemItens, {| aVet | aVet[2]}) == 0)
			
			aFields := {}
			For nField := 1 To TMPPAI->(FCount())
				If Hs_ExisDic({{"C",TMPPAI->(FieldName(nField))}}, .F.)
					aAdd(aFields, {TMPPAI->(FieldName(nField)), IIf(TMPPAI->(FieldName(nField)) <> "R_E_C_N_O_", HS_CfgSx3(TMPPAI->(FieldName(nField)))[SX3->(FieldPos("X3_TIPO"))], "N"), &("TMPPAI->"+ TMPPAI->(FieldName(nField)))})
				Else
					aAdd(aFields, {TMPPAI->(FieldName(nField)), Type(TMPPAI->(FieldName(nField))), &("TMPPAI->"+ TMPPAI->(FieldName(nField)))})
				EndIf
			Next
			
			DbSelectArea("TMPPAI")
			DbSkip()
			
			nItePai++
			aTemItens := {}
			
			If TMPPAI->(Eof())
				nLOutOld := nLayOut
				If (nLayOut := aScan(aLayOut, {| aVet | aVet[2] == "5"}, nLayOut)) == 0
					nLayOut := nLOutOld
					If (nLayOut := aScan(aLayOut, {| aVet | aVet[2] == "6"}, nLayOut)) == 0
						//FS_FinTags(cLinha, __aTagsFim, lTagFim, aLayOut, nLayOut, nFor, lTagDel)
					EndIf
				EndIf
			EndIf
			
			If aLayOut[nLayOut, 2] $ "5#6"//Se for quebra ou rodape da remessa
				
				If aLayOut[nLayOut, 2] == "5" .And. (cChave <> &(cChaveRem) .Or. &(cCondQbr) )
					IncProc(OemToAnsi("Gravando dados..."))
					HS_ExLOut(aLayOut, nLayOut, nHandle, aFields, cTipArq, "ARQDBF")
				EndIf
				nLayOut := If (nLoop > 0 .And. !(TMPPAI->(Eof())), nLoop, Iif(Len(aLayOut) > nLayOut,nLayOut + 1,nLayOut ))
			EndIf
		EndIf
	End
End

If aLayOut[nLayOut, 2] == "6"//Se for quebra
	IncProc(OemToAnsi("Gravando dados..."))
	HS_ExLOut(aLayOut, nLayOut, nHandle, aFields, cTipArq, "ARQDBF")
EndIf

// Monta nome definitivo do arquivo exportado, o arquivo contido cArqTmp serแ renomenado para o arquivo contido em cArqDef.
__lIncReme := .F.
cArqDef := cGG2Direct + AllTrim(&(cGG2NomArq)) + "." + cExtensao

If Select("TMPPAI") > 0
	DbSelectArea("TMPPAI")
	DbCloseArea()
EndIf

If Select("HSPEDI") > 0
	DbSelectArea("HSPEDI")
	DbCloseArea()
EndIf

If cTipArq == "2"
	DbSelectArea("ARQDBF")
	DbCloseArea()
	
Else
	fClose(nHandle)
	
EndIf

If Fs_ChkDir(cGG2Direct)
	If !(__CopyFile(cArqTmp, cArqDef))
		HS_MsgInf("Erro na c๓pia do arquivo " + cArqTmp + " para " + cArqDef + Chr(13) + Chr(10) + ;
		AllTrim(Str(FError())), "Aten็ใo", "EDI - Exporta็ใo")
	EndIf
EndIf

FErase(cArqTmp)

If !lEdiAuto
	HS_MsgInf("Arquivo gerado com sucesso", "Processamento finalizado", "EDI - Exporta็ใo")
EndIf

RestArea(aArea)
Return(cArqDef)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function Fs_ChkDir(cDir, lPerg)

Local lRet := File(IIF(Substr(cDir, Len(cDir)) $ "\/",SubStr(cDir, 1, Len(cDir)-1),cDir))
Local cAux := cDir, nPos := 0

Default lPerg := .T.

If !lRet
	If !lPerg .Or. MsgYesNo("Diret๓rio ["+cDir+"] nใo encontrado."+chr(10)+chr(13)+"Deseja criแ-lo?")
		
		While at("/",substr(cDir, nPos+1) ) > 0 .Or. at("\",substr(cDir, nPos+1) )  > 0
			nPos := IIF(at("/",substr(cDir, nPos+1) ) > 0, at("/",substr(cDir, nPos+1) ),at("\",substr(cDir, nPos+1) )) + nPos
			cAux := SubStr(cDir, 1, nPos-1)
			Fs_ChkDir(cAux, .F.)
		EndDo
		
		If !(lRet := File(IIF(Substr(cDir, Len(cDir)) $ "\/",SubStr(cDir, 1, Len(cDir)-1),cDir)) .Or. (MakeDir(cDir) == 0))
			Hs_MsgInf("Erro na cria็ใo do diret๓rio","Aten็ใo","EDI - Exporta็ใo")
		EndIf
	EndIf
EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executa o LayOut e grava a linha no arquivo                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function HS_ExLOut(aLayOut, nLayOut, nHandle, aFields, cTipArq, cAliasDbf, aGrpCpoRep, lTagIni, lTagFim,lRSeq)
Local cAliasOld := Alias()
Local cAux := ""
Local nFor   := 0, nPos := 0, nPosAux := 0, nScan := 0, nDelTag := 0
Local nCpoRep := 0
Local cCpoRep := "0"
Local cCpoLayOut := ""
Local aLinha := {}
Local lDelTag := .F.
Local cNNivel := ""

Private cLinha := ""

Default nHandle := -1
Default aFields := {}
Default aGrpCpoRep := {}
Default lTagIni := .T.
Default lTagFim := .T.
Default lRSeq   := .F.

If Len(aGrpCpoRep) > 0
	DbSelectArea("HSPEDI")
	
	For nFor := 1 To Len(aLayOut[nLayOut, 3])
		//aScan(aGrpCpoRep, {| aCpoRep | aScan(aCpoRep[4], {| aCpoRep1 | aCpoRep1 == aLayOut[nLayOut, 3][nFor][3]}) > 0}) == 0
		If Empty(aLayOut[nLayOut, 3][nFor][4])
			aAdd(aLinha, {aLayOut[nLayOut, 3][nFor][3], &(aLayOut[nLayOut, 3][nFor][2]), Val(aLayOut[nLayOut, 3][nFor][1]), .T.})
		Else
			aAdd(aLinha, {aLayOut[nLayOut, 3][nFor][3], aLayOut[nLayOut, 3][nFor][2], Val(aLayOut[nLayOut, 3][nFor][1]), .F.})
		EndIf
	Next nFor
	
	While !Eof() .And. nCpoRep <= aGrpCpoRep[nLayOut][2]
		For nFor := 1 To Len(aLinha)
			If !aLinha[nFor][4] .And. Right(AllTrim(aLinha[nFor][1]), 1) == cCpoRep
				aLinha[nFor][2] := &(aLinha[nFor][2])
				aLinha[nFor][4] := .T.
			EndIf
		Next nFor
		
		cCpoRep := Soma1(cCpoRep, 1)
		nCpoRep++
		
		DbSelectArea("HSPEDI")
		DbSkip()
	End
	
	If cTipArq == "2"
		DbSelectArea(cAliasDBF)
		Reclock(cAliasDBF, .T.)
	EndIf
	
	For nFor := 1 To Len(aLinha)
		If cTipArq == "2"
			If ValType(&(cAliasDBF + "->" + aLinha[nFor, 1])) <> "U" .And. aLinha[nFor][4]
				&(cAliasDBF + "->" + aLinha[nFor, 1]) := aLinha[nFor, 2]
			EndIf
		Else
			If aLinha[nFor][4]
				cLinha += PADR(aLinha[nFor, 2], aLinha[nFor, 3])
			Else
				cLinha += Space(aLinha[nFor, 3])
			EndIf
		EndIf
	Next nFor
Else
	If cTipArq == "2"
		DbSelectArea(cAliasDBF)
		Reclock(cAliasDBF, .T.)
	EndIf
	
	For nFor := 1 To Len(aLayOut[nLayOut, 3])
		If     cTipArq == "3" .And. !lTagIni .And. aLayOut[nLayOut, 3][nFor][6] == "0" // Cabec
			Loop
		ElseIf cTipArq == "3" .And. !lTagFim .And. aLayOut[nLayOut, 3][nFor][6] == "2" // Rodap้
			Loop
		ElseIf cTipArq == "3" .And. aLayOut[nLayOut, 3][nFor][6] == "3" // Totalizador
			&(aLayOut[nLayOut, 3][nFor][2])
			FS_FinTags(@cLinha, @__aTagsFim, lTagFim, aLayOut, nLayOut, nFor, .F.)
			Loop
		ElseIf cTipArq == "3" .And. !Empty(aLayOut[nLayOut, 3][nFor][7]) .And. !(&(aLayOut[nLayOut, 3][nFor][7]))
			cNNivel := aLayOut[nLayOut, 3][nFor][5]
			FS_FinTags(@cLinha, @__aTagsFim, lTagFim, aLayOut, nLayOut, nFor, .F.)
			Loop
		ElseIf cTipArq == "3" .And. !Empty(cNNivel) .And. aLayOut[nLayOut, 3][nFor][5] > cNNivel
			Loop
		ElseIf cTipArq == "3" .And. !Empty(cNNivel) .And. aLayOut[nLayOut, 3][nFor][5] <= cNNivel
			cNNivel := ""
		EndIf
		
		cLayOut := aLayOut[nLayOut, 3][nFor][2]
		If !Empty(aFields)
			While (nPos := At("TMPPAI->", cLayOut)) > 0
				cAux := SubStr(cLayOut, nPos + 8, Len(SX3->X3_CAMPO))
				cAux := FS_EdiRCpo(cAux)
				nScan := Ascan(aFields,{|x| x[1] == cAux })
				If aFields[nScan, 2] $ "C/D"
					cLayOut := StrTran(cLayOut,"TMPPAI->" + cAux, "'" + aFields[nScan, 3] + "'" )
				ElseIf aFields[nScan, 2] == "N"
					cLayOut := StrTran(cLayOut,"TMPPAI->" + cAux, aFields[nScan, 3] )
				EndIf
			End
		EndIf
		
		If cTipArq == "2"
			If ValType(&(cAliasDBF + "->" + aLayOut[nLayOut, 3][nFor][3]) ) <> "U"
				&(cAliasDBF + "->" + aLayOut[nLayOut, 3][nFor][3]) := &(cLayOut)
			EndIf
		Else
			
			If aLayOut[nLayOut, 3][nFor][8] == "N"
				cLayOut := AllTrim(Str(&(cLayOut)))
			ElseIf aLayOut[nLayOut, 3][nFor][8] == "D"
				cLayOut := DToC(&(cLayOut))
			Else
				If lRSeq .Or. cNumSeq > 20
					cNumSeq := 1
				EndIf
				
				If 'HS_REQPMED' $ cLayOut .and. GetNewPar("MV_TISSVER", "2.02.03") >= "3" .and. nLayout == 3 .and. nRecAtu == nTotRec
					cLayOut := &(cLayOut)
					cLinha := Alltrim(cLinha)
					cLinha += chr(10)+SPACE(06)+"</ans:procedimentosExecutados>"
				Else
					cLayOut := &(cLayOut)
				EndIf
			EndIf
			
			If cTipArq == "3" .And. Val(aLayOut[nLayOut, 3][nFor][5]) > 0
				
				If Empty(aLayOut[nLayOut, 3][nFor][3]) .And. aScan(__aTagsFim, {| aVet | aVet[1] == &(aLayOut[nLayOut, 3][nFor][2]) .And. aVet[2] == aLayOut[nLayOut, 3][nFor][5]}) > 0
					FS_FinTags(@cLinha, @__aTagsFim, lTagFim, aLayOut, nLayOut, nFor, .T.)
				ElseIf Empty(aLayOut[nLayOut, 3][nFor][3]) .And. aScan(__aTagsFim, {| aVet | aVet[2] >= aLayOut[nLayOut, 3][nFor][5]}) > 0
					FS_FinTags(@cLinha, @__aTagsFim, lTagFim, aLayOut, nLayOut, nFor, .T.)
				EndIf
				
				cLinha += Space(Val(aLayOut[nLayOut, 3][nFor][5]))
				cLinha += "<"
				
				If !Empty(aLayOut[nLayOut, 3][nFor][3])
					cLinha += &(aLayOut[nLayOut, 3][nFor][3]) + IIf(Empty(cLayOut), " />" + Chr(10), ">")
				Else
					aAdd(__aTagsFim, {&(aLayOut[nLayOut, 3][nFor][2]), aLayOut[nLayOut, 3][nFor][5], aLayOut[nLayOut, 2]})
				EndIf
				
			EndIf
			
			If cTipArq == "1"
	     		If Valtype(cLayOut) <> "U"
	     			cLinha += IIf(Val(aLayOut[nLayOut, 3][nFor][1]) == 0, cLayOut, IIf(Empty(cLayOut),Space(Val(aLayOut[nLayOut, 3][nFor][1])),PADR(cLayOut, Val(aLayOut[nLayOut, 3][nFor][1]))))
	     		Endif
			ElseIf !Empty(cLayOut)
				cLinha += AllTrim(IIf(Val(aLayOut[nLayOut, 3][nFor][1]) == 0, cLayOut, PADR(cLayOut, Val(aLayOut[nLayOut, 3][nFor][1]))))
			EndIf
			
			If cTipArq == "3" .And. Val(aLayOut[nLayOut, 3][nFor][5]) > 0 .And. !Empty(aLayOut[nLayOut, 3][nFor][3])
				If !Empty(cLayOut)
					If !("HS_CHASHXML" $ Upper(AllTrim(aLayOut[nLayOut, 3][nFor][2])))
						__cHXml += AllTrim(cLayOut)
						//FS_LogProc(nHdlCnt, AllTrim(cLayOut))
					EndIf
					
					cLinha += "</" + &(aLayOut[nLayOut, 3][nFor][3]) + ">" + Chr(10)
				EndIf
				
				FS_FinTags(@cLinha, @__aTagsFim, lTagFim, aLayOut, nLayOut, nFor, .F.)
				
			ElseIf cTipArq == "3" .And. Val(aLayOut[nLayOut, 3][nFor][5]) > 0
				cLinha += ">" + Chr(10)
			ElseIf cTipArq == "3"
				cLinha += Chr(10)
			EndIf
			
		EndIf
	Next nFor
EndIf

If !(cTipArq == "2")
	FWrite(nHandle, cLinha, Len(cLinha))
Else
	DbSelectArea(cAliasDBF)
	MsUnlock()
EndIf

DbSelectArea(cAliasOld)
Return(cLinha)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_FinTags(cLinha, __aTagsFim, lTagFim, aLayOut, nLayOut, nFor, lTagDel)
Local nDelTag := 0, lDelTag := .F.

Default lDelTag := .F.

For nDelTag := Len(__aTagsFim) To IIf(lTagFim, 1, Len(__aTagsFim)) Step -1
	If     lTagDel
		lDelTag := (__aTagsFim[Len(__aTagsFim)][2] >= aLayOut[nLayOut, 3][nFor][5])
	ElseIf aLayOut[nLayOut, 2] == "1" // Cabe็alho
		lDelTag := __aTagsFim[Len(__aTagsFim)][3] == aLayOut[nLayOut, 2] .And. ((nFor + 1) > Len(aLayOut[nLayOut, 3]) .Or. __aTagsFim[Len(__aTagsFim)][2] >= aLayOut[nLayOut, 3][nFor + 1][5])
		//((nFor + 1) > Len(aLayOut[nLayOut, 3]) .Or. __aTagsFim[Len(__aTagsFim)][2] >= aLayOut[nLayOut, 3][nFor + 1][5])
	ElseIf aLayOut[nLayOut, 2] == "2" // Detalhe Pai
		lDelTag := __aTagsFim[Len(__aTagsFim)][2] >= aLayOut[nLayOut + 1, 3][1][5] .And. __aTagsFim[Len(__aTagsFim)][3] == aLayOut[nLayOut, 2] .And. ((nFor + 1) > Len(aLayOut[nLayOut, 3]) .Or. __aTagsFim[Len(__aTagsFim)][2] >= IIf(Empty(aLayOut[nLayOut, 3][nFor + 1][5]),"999",aLayOut[nLayOut, 3][nFor + 1][5]))
		//((nFor + 1) > Len(aLayOut[nLayOut, 3]) .Or. __aTagsFim[Len(__aTagsFim)][2] >= aLayOut[nLayOut, 3][nFor + 1][5])
	ElseIf aLayOut[nLayOut, 2] == "3" // Detalhe Filho
		lDelTag := (__aTagsFim[Len(__aTagsFim)][3] == aLayOut[nLayOut, 2] .Or. __aTagsFim[Len(__aTagsFim)-1][3] == aLayOut[nLayOut-1, 2]) .And. ((nFor + 1) > Len(aLayOut[nLayOut, 3]) .Or. __aTagsFim[Len(__aTagsFim)][2] >= aLayOut[nLayOut, 3][nFor + 1][5])
		//((nFor + 1) > Len(aLayOut[nLayOut, 3]) .Or. __aTagsFim[Len(__aTagsFim)][2] >= aLayOut[nLayOut, 3][nFor + 1][5])
	ElseIf aLayOut[nLayOut, 2] == "4" // Rodape Pai
		lDelTag := IIf(!lTagFim, (__aTagsFim[Len(__aTagsFim)][3] == aLayOut[nLayOut, 2] .Or. __aTagsFim[Len(__aTagsFim)][3] == aLayOut[nLayOut-2, 2]) .And. ((nFor + 1) > Len(aLayOut[nLayOut, 3]) .Or. __aTagsFim[Len(__aTagsFim)][2] >= aLayOut[nLayOut, 3][nFor + 1][5]), ((nFor + 1) > Len(aLayOut[nLayOut, 3]) .Or. __aTagsFim[Len(__aTagsFim)][2] >= aLayOut[nLayOut, 3][nFor + 1][5]))
	Else
		lDelTag := (__aTagsFim[Len(__aTagsFim)][3] == aLayOut[nLayOut, 2]) // .Or. __aTagsFim[Len(__aTagsFim)][3] == aLayOut[nLayOut-1, 2]) .And. ((nFor + 1) > Len(aLayOut[nLayOut, 3]) .Or. __aTagsFim[Len(__aTagsFim)][2] >= aLayOut[nLayOut, 3][nFor + 1][5])
	EndIf
	
	If lDelTag
		cLinha += Space(Val(__aTagsFim[Len(__aTagsFim)][2])) + "</" + __aTagsFim[Len(__aTagsFim)][1] + ">" + Chr(10)
		aDel(__aTagsFim, Len(__aTagsFim))
		aSize(__aTagsFim, Len(__aTagsFim) - 1)
	EndIf
Next

Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_EdiRCpo(cCampo)

Local nPos := 0, cAux := ""

While (nPos := AT(".", cCampo)) > 0 .Or. (nPos := AT(",", cCampo)) > 0 .Or. (nPos := AT(" ", cCampo)) > 0 .Or.;
	(nPos := AT("+", cCampo)) > 0 .Or. (nPos := AT("-", cCampo)) > 0 .Or. (nPos := AT("*", cCampo)) > 0 .Or.;
	(nPos := AT("/", cCampo)) > 0 .Or. (nPos := AT(")", cCampo)) > 0 .Or. (nPos := AT("(", cCampo)) > 0
	cAux   := Substr(cCampo, 1,nPos-1)
	cCampo := cAux
End

Return(cCampo)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida funcoes que o usuario cadastrou para serem          บฑฑ
ฑฑบ          ณ executadas                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Function HS_EDIVeri(cLocCham)

Local aArea    := GetArea()
Local nLinGG4  := 0, nLinGG8 := 0, nPos := 0, nFor := 0
Local cSql     := "", cSelect := "", cFrom := "", cSqlPai := "", cArq := "", cPrefArq := "", cArqJoin := ""
Local aColsCpo := {}, aCpoData := {}
Local cModoInt := M->GG2_MODINT, lDbf := (M->GG2_TIPARQ == "2")
Local bBlock   := ErrorBlock(), bErro := ErrorBlock( { |e| ChekBug(e) } )
Local nHandle  := fCreate("Analise_EDI.Log", 0)
Local cQryFil  := "", cSqlFil  := ""

Private lRetErro := .T.

_SetOwnerPrvt("__cHXml", "")

If !Empty(GG2->GG2_PERGUN)
	Pergunte(GG2->GG2_PERGUN, .F.)
EndIf

If !Empty(M->GG2_CAMMAC)
	FS_CamMac(M->GG2_CAMMAC) // Campo memo.. com inicializa็ใo de variแveis
EndIf
If (nPosACols := aScan(aGg8Gd, {| aVet | aVet[1] == nAtAnt})) == 0
	aAdd(aGg8Gd, {nAtAnt, {} })
	nPosACols := Len(aGg8Gd)
EndIf

aGg8Gd[nPosACols, 2] := aClone(oGG8:aCols)

FS_LogProc(nHandle, "Iniciando validacao - EDI")

If cModoInt $ "N" // Modo Interpreta็ใo normal
	
	cSelect :=  "SELECT " + M->GG2_ARQPAI + ".* "
	cFrom   := " FROM " + RetSqlName(M->GG2_ARQPAI) + " " + M->GG2_ARQPAI + " "
	cWhere  := " WHERE " + M->GG2_ARQPAI + ".D_E_L_E_T_ <> '*' AND "
	cWhere  +=     M->GG2_ARQPAI + "." + M->GG2_ARQPAI + "_FILIAL = '" + xFilial(M->GG2_ARQPAI) + "' "
	
	DbSelectArea("SX3")
	DbSetOrder(1)
	If DbSeek(M->GG2_ARQPAI)
		While SX3->X3_ARQUIVO == M->GG2_ARQPAI
			If SX3->X3_TIPO == "D"
				aAdd(aCpoData,  {SX3->X3_CAMPO, "" } )
			EndIf
			SX3->(DbSkip())
		End
	EndIf
	
	FS_LogProc(nHandle, "Montando comando SQL - " + M->GG2_ARQPAI)
	
	For nLinGG4 := 1 To Len(oGG4:aCols)
		If oGG4:aCols[nLinGG4, Len(oGG4:aHeader) + 1] == .F. .And. !(oGG4:aCols[nLinGG4, nGG4Arquiv] $ cArqJoin)// Linha naum estah deletada
			
			cArqJoin += oGG4:aCols[nLinGG4, nGG4Arquiv] + "/"
			
			cArq     := oGG4:aCols[nLinGG4, nGG4Arquiv]
			cPrefArq := cArq + "."
			
			cFrom    += "JOIN " + RetSqlName(cArq) + " " + cArq + " ON " + cArq + ".D_E_L_E_T_ <> '*' AND "
			cFrom    +=   cPrefArq + cArq + "_FILIAL = '" + xFilial(cArq) + "'"
			cFrom    +=   " AND " + AllTrim(oGG4:aCols[nLinGG4, nGG4Instru]) + " "
			
			nPos := aScan(aGg8Gd, {| aVet | aVet[1] == nLinGG4})
			
			aColsCpo := aGg8Gd[nPos, 2]
			
			For nLinGG8 := 1 To Len(aColsCpo)
				If aColsCpo[nLinGG8, Len(oGG8:aHeader) + 1] == .F. // Linha naum estah deletada
					If !Empty(aColsCpo[nLinGG8, nGG8Campo])
						DbSelectArea("SX3")
						DbSetOrder(2)
						If DbSeek(aColsCpo[nLinGG8, nGG8Campo])
							cSelect += ", " + cPrefArq + aColsCpo[nLinGG8, nGG8Campo] + " " + aColsCpo[nLinGG8, nGG8NomCpo]
						Else
							cSelect += ", " + aColsCpo[nLinGG8, nGG8Campo] + " " + aColsCpo[nLinGG8, nGG8NomCpo]
						EndIf
					Else
						cSelect += ", '  ' " + aColsCpo[nLinGG8, nGG8NomCpo] + " "
					EndIf
				EndIf
				
				If SX3->X3_CAMPO == aColsCpo[nLinGG8, nGG8Campo] .And. SX3->X3_TIPO == "D"
					aAdd(aCpoData, {SX3->X3_CAMPO, aColsCpo[nLinGG8, nGG8NomCpo] } )
				EndIf
				
			Next nLinGG8
			
			FS_LogProc(nHandle, "Montando comando SQL - " + oGG4:aCols[nLinGG4, nGG4Arquiv])
		EndIf
	Next nLinGG4
	
	cQryFil := cSelect + cFrom +	cWhere
	
	If !Empty(M->GG2_ORDEBY)
		cQryFil += "ORDER BY " + M->GG2_ORDEBY
	EndIf
	
ElseIf cModoInt $ "A" // Modo avan็ado
	DbSelectArea("GG2")
	cSqlPai  := M->GG2_QRYPAI //E_MSMM(M->GG2_MQRPAI)
	cSqlPai  := FS_EDiRQry(cSqlPai)
	cSqlPai  := ChangeQuery(cSqlPai)
	
	cQryFil  := M->GG2_QRYFIL //E_MSMM(M->GG2_MQRFIL)
EndIf

cQryFil := StrTran(cQryFil, Chr(13) + Chr(10), " ")

Begin Sequence

If cModoInt $ "A"
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cSqlPai), "TMPPAI", .F., .F.)
EndIf

cDadosErro := "Erro nos dados do campo de inicializa็ใo 	GG0_CAMMAC"

FS_LogProc(nHandle, "Inicializacoes: ")
FS_LogProc(nHandle, "  " + M->GG2_CAMMAC)

cDadosErro := "Formula็ใo do nome do arquivo: " + AllTrim(M->GG2_NOMARQ)

&(AllTrim(M->GG2_NOMARQ))

FS_LogProc(nHandle, cDadosErro + " Funcao: " + AllTrim(M->GG2_NOMARQ))

ProcRegua(0)

For nLinGG4 := 1 To Len(oGG3:aCols)
	If !(oGG3:aCols[nLinGG4, Len(oGG3:aHeader)+1])
		cSqlFil := ""
		
		//Atribui valores aos parametros da query
		DbSelectArea("GG0")
		DbSetOrder(1)
		DbSeek(xFilial("GG0") + oGG3:aCols[nLinGG4, nGG3CodGru])
		cSqlFil := StrTran(GG0->GG0_QRYFIL, Chr(13) + Chr(10), " ")
		If !Empty(cSqlFil)
			cSqlFil := FS_EDiRQry(GG0->GG0_QRYFIL)
		ElseIf !Empty(cQryFil)
			cSqlFil := FS_EDiRQry(cQryFil)
		EndIf
		
		If !Empty(cSqlFil)
			cDadosErro := "Erro na Select do grupo: " + oGG3:aCols[nLinGG4, nGG3CodGru ] + "[" + cSqlFil + "]"
			cSqlFil := ChangeQuery(cSqlFil)
			DbUseArea(.T., "TOPCONN", TcGenQry(,, cSqlFil), "HSPEDI", .F., .F.)
		EndIf
		
		If cModoInt $ "N"
			For nFor := 1 to Len(aCpoData)
				If !Empty(aCpoData[nFor,2])
					TCSetField("HSPEDI", aCpoData[nFor,2], "D", 8, 0)
				Else
					TCSetField("HSPEDI", aCpoData[nFor,1], "D", 8, 0)
				EndIf
			Next
		EndIf
		
		cSql := "SELECT GG0.GG0_CODGRU, GG1.GG1_ITEM, GG1.GG1_FUNEXP "
		cSql += "FROM " + RetSqlName("GG0") + " GG0 "
		cSql +=   "JOIN " + RetSqlName("GG1") + " GG1 ON GG1.D_E_L_E_T_ <> '*' AND GG1.GG1_FILIAL ='" + xFilial("GG1") + "' AND "
		cSql +=       "GG1.GG1_CODGRU = GG0.GG0_CODGRU "
		cSql += "WHERE GG0.D_E_L_E_T_ <> '*' AND GG0.GG0_FILIAL = '" + xFilial("GG0") + "' AND "
		cSql +=       "GG0.GG0_CODGRU = '" + oGG3:aCols[nLinGG4, nGG3CodGru ] + "' "
		cSql += "ORDER BY GG0.GG0_CODGRU, GG1.GG1_ITEM "
		
		cSql := ChangeQuery(cSql)
		TCQuery cSql New Alias "TMPEDI"
		
		DbSelectArea("TMPEDI")
		DbGotop()
		
		While !Eof()
			IncProc("Grupo: " + oGG3:aCols[nLinGG4, nGG3CodGru ] + " Item do Grupo: " + TMPEDI->GG1_ITEM)
			
			cDadosErro := "Grupo: " + oGG3:aCols[nLinGG4, nGG3CodGru ] + " Item do Grupo: " + TMPEDI->GG1_ITEM
			
			&(TMPEDI->GG1_FUNEXP)
			
			FS_LogProc(nHandle, cDadosErro + " Funcao: " + AllTrim(TMPEDI->GG1_FUNEXP))
			
			DbSelectArea("TMPEDI")
			DbSkip()
		End
		
		DbSelectArea("TMPEDI")
		DbCloseArea()
		
		If Select("HSPEDI") > 0
			DbSelectArea("HSPEDI")
			DbCloseArea()
		EndIf
		
	EndIf
Next nLinGG4

If AllTrim(cLocCham) <> "OK"
	HS_MsgInf("Anแlise finalizada","Aten็ใo","Anแlise EDI")
EndIf

End Sequence

ErrorBlock(bBlock)

If Select("TMPPAI") > 0
	DbSelectArea("TMPPAI")
	DbCloseArea()
EndIf

FS_LogProc(nHandle, "Valida็ใo Finalizada.")
FClose(nHandle)

RestArea(aArea)

If !lRetErro .And. cLocCham == "OK"
	If MsgYesNo(OemToAnsi("O Layout cont้m erros deseja gravar assim?"),OemToAnsi("Aten็ใo"))
		Return(.T.)
	EndIf
EndIf

Return(lRetErro)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function Chekbug(e)
If e:gencode > 0
	cDadosErro := IIf(Empty(cDadosErro),"Pilha: " + e:ERRORSTACK,cDadosErro)
	HS_MsgInf("Erro: " + e:Description + Chr(13) + Chr(10) + cDadosErro,"Aten็ใo","Anแlise EDI")
	If Select("HSPEDI") > 0
		DbSelectArea("HSPEDI")
		DbCloseArea()
	EndIf
	
	If Select("TMPEDI") > 0
		DbSelectArea("TMPEDI")
		DbCloseArea()
	EndIf
	lRetErro:=.F.
EndIf
Break
Return(lRetErro)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_LogProc(nHandle, cLog)
fWrite(nHandle, cLog + CHR(13) + CHR(10), Len(cLog + CHR(13) + CHR(10)))
Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_MudAcol()
Local nPosACols := 0, nForGD := 0, cAliasOld := Alias()

cSx3CodTab := oGG4:aCols[oGG4:nAt, nGG4Arquiv]

If nAtAnt # oGG4:nAt
	If (nPosACols := aScan(aGg8Gd, {| aVet | aVet[1] == nAtAnt})) == 0
		aAdd(aGg8Gd, {nAtAnt, {} })
		nPosACols := Len(aGg8Gd)
	EndIf
	
	aGg8Gd[nPosACols, 2] := aClone(oGG8:aCols)
	
	If (nPosACols := aScan(aGg8Gd, {| aVet | aVet[1] == oGG4:nAt})) > 0
		oGG8:SetArray(aGg8Gd[nPosACols, 2])
	Else
		oGG8:aCols := {}
		oGG8:AddLine(.T., .F.)
		oGG8:lNewLine := .F.
	EndIf
	
	oGG8:oBrowse:Refresh()
	
	nAtAnt := oGG4:nAt
EndIf

DbSelectArea(cAliasOld)

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Function HS_FilPEDI(cAlias)

If Empty(cAlias)
	HS_MsgInf("O arquivo principal (pai) nใo foi definido","Aten็ใo","Valida็ใo EDI")
	Return(.F.)
EndIf

cFiltro := BuildExpr(cAlias, , , .T.)

M->GG2_FILTRO := cFiltro

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Function HS_FilREdi(cArqPri,cACols,cNPosArq)
Local oDlgFil, oCbTab1, oCbTab2, oCbOpera, oCbCpo1, oCbCpo2, oExpr1, oMemo
Local cCbTab1 := "", cCbTab2 := "", cCbOpera := "", cCbCpo1 := "", cCbCpo2 := "", cExpr1
Local cMemo := "", cRFil := ""
Local aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}
Local aItCbTab1 := {}, aItCbTab2 := {}, aItCbOpera := {}, aItCbCpo1 := {}, aItCbCpo2 := {}
Local nOpcA := 0 ,nFor := 0
Local cPict1 := ""
Local cArq := &(cArqPri) , aCols := &(cAcols), nPosArq := &(cNposArq)

Private nContPar := 0
Private oBtnAd, oBtnLF, oBtnPE, oBtnPD, oBtnE, oBtnOu

If Empty(cArq)
	HS_MsgInf("O arquivo principal (pai) nใo foi definido","Aten็ใo","Valida็ใo EDI")
	Return(.F.)
EndIf

aAdd(aItCbOpera, "Igual a")
aAdd(aItCbOpera, "Diferente de")
aAdd(aItCbOpera, "Menor que")
aAdd(aItCbOpera, "Menor ou igual a")
aAdd(aItCbOpera, "Maior que")
aAdd(aItCbOpera, "Maior ou igual a")
aAdd(aItCbOpera, OemToAnsi("Contem a expressao") )
aAdd(aItCbOpera, OemToAnsi("Nใo cont้m") )
aAdd(aItCbOpera, OemToAnsi("Estแ contido em") )
aAdd(aItCbOpera, OemToAnsi("Nใo estแ contido em") )

aAdd(aItCbTab1, cArq)

For nFor := 1 To Len(aCols)
	If !Empty(aCols[nFor, nPosArq])
		aAdd(aItCbTab1, aCols[nFor, nPosArq])
	EndIf
Next nFor

aItCbTab2 := aClone(aItCbTab1)

FS_CbCampos(cArq,@aItCbCpo1)

aItCbCpo2 := {"Expressao"}

For nFor := 1 To Len(aItCbCpo1)
	aAdd(aItCbCpo2, aItCbCpo1[nFor])
Next nFor

FS_MudaCpo(aItCbCpo1[1], @cExpr1, @cPict1)

aSize := MsAdvSize(.T.)
aObjects := {}

AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlgFil TITLE OemToAnsi("Filtro de tabelas - EDI") From aSize[7],0 TO aSize[6]/1.5, aSize[5]/2.5 	PIXEL of oMainWnd

//Combo - Tabelas(Esquerda)
@ 015,010 Say OemToAnsi("Tabelas:") Size 075, 009 OF oDlgFil PIXEL COLOR CLR_BLACK
@ 023,010 MSCOMBOBOX oCbTab1 VAR cCbTab1 SIZE 30,9 COLOR CLR_BLACK ITEMS aItCbTab1 OF oDlgFil PIXEL VALID {||FS_CbCampos(cCbTab1,@aItCbCpo1,oCbCpo1), FS_MudaCpo(cCbCpo1, @cExpr1, @cPict1, oExpr1)}

//Combo - Campos(Esquerda)
@ 035,010 Say OemToAnsi("Campos:") Size 075, 009 OF oDlgFil PIXEL COLOR CLR_BLACK
@ 043,010 MSCOMBOBOX oCbCpo1 VAR cCbCpo1 SIZE 50,9 COLOR CLR_BLACK ITEMS aItCbCpo1 OF oDlgFil PIXEL VALID {|| FS_MudaCpo(cCbCpo1,@cExpr1,@cPict1,oExpr1)}

//Combo - Operacoes
@ 035,070 Say OemToAnsi("Opera็ใo:") Size 075, 009 OF oDlgFil PIXEL COLOR CLR_BLACK   // "Codigo"
@ 043,070 MSCOMBOBOX oCbOpera VAR cCbOpera SIZE 70,9 COLOR CLR_BLACK ITEMS aItCbOpera OF oDlgFil PIXEL

//Combo - Tabelas(Direita)
@ 015,150 Say OemToAnsi("Tabelas:") Size 075, 009 OF oDlgFil PIXEL COLOR CLR_BLACK
@ 023,150 MSCOMBOBOX oCbTab2 VAR cCbTab2 SIZE 30,9 COLOR CLR_BLACK ITEMS aItCbTab2 OF oDlgFil PIXEL VALID {||FS_CbCampos(cCbTab2,@aItCbCpo2,oCbCpo2, .T.)}

//Combo - Campos(Direita)
@ 035,150 Say OemToAnsi("Campos:") Size 075, 009 OF oDlgFil PIXEL COLOR CLR_BLACK
@ 043,150 MSCOMBOBOX oCbCpo2 VAR cCbCpo2 SIZE 50,9 COLOR CLR_BLACK ITEMS aItCbCpo2 OF oDlgFil PIXEL

@ 055,010 Say OemToAnsi("Expressใo:") Size 075, 009 OF oDlgFil PIXEL COLOR CLR_BLACK
@ 063,010 MSGet oExpr1 Var cExpr1 Picture cPict1 Size 70, 009 Of oDlgFil Pixel Color CLR_BLACK

oBtnAd := tButton():New(78,010,"&Adicionar"   ,oDlgFil,{|| FS_BAdFil(@cMemo,cCbTab1,cCbCpo1,cCbOpera,oCbOpera:nAt,cCbTab2,cCbCpo2,cExpr1,@cRFil)}    ,035,012,,,,.T.)    //"Adicionar"


oBtnLF := tButton():New(78,050,"&Limpa Filtro",oDlgFil,{|| FS_BtnLimp(@cMemo) },035,012,,,,.T.)    //"Limpa Filtro"

//Botao - Parentese Esquerdo
oBtnPE := tButton():New(062,156,"(",  oDlgFil, {|| FS_BtnPare(@cMemo, "(", @cRFil) }    ,012,012,,,,.T.)    //"("]

//Botao - Parentese Direito
oBtnPD := tButton():New(062,170,")",  oDlgFil, {|| FS_BtnPare(@cMemo, ")", @cRFil) }    ,012,012,,,,.T.)    //"("
oBtnPD:Disable()

//Botao - E
oBtnE  := tButton():New(075,156,"e",  oDlgFil, {|| FS_BtnEOu(@cMemo, "E", @cRFil) }    ,012,012,,,,.T.)    //"e"
oBtnE:Disable()

//Botao - OU
oBtnOu := tButton():New(075,170,"ou", oDlgFil, {|| FS_BtnEOu(@cMemo, "OU", @cRFil) }   ,012,012,,,,.T.)    //"ou"
oBtnOu:Disable()

oMemo := tMultiget():New(93, 010, {|u|if(Pcount()>0,cMemo:=u,cMemo)}, oDlgFil, 190, 70,,,,RGB(250,250,210),, .T.,,,,,,.T.)

ACTIVATE MSDIALOG oDlgFil CENTERED ON INIT EnchoiceBar (oDlgFil, {	|| nOpcA := 1, oDlgFil:End()},	{|| nOpcA := 0, oDlgFil:End()} )

If nOpcA == 1
	cFilRel := cRFil
EndIf

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Function HS_RetFilR(cCampo)
If Type("cFilRel") # "U" .And. !Empty(cFilRel)
	&(cCampo) := cFilRel
EndIf
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_CbCampos(cCbTab,aItCbCpo, oCbCpo, lExp)
Local aArea := GetArea()

Default lExp := .F.

aItCbCpo := {}

If lExp
	aAdd(aItCbCpo, "Expressao")
EndIf

DbSelectArea("SX3")
dbSetOrder(1)
DbSeek(AllTrim(cCbTab))
While SX3->(!Eof()) .And. (SX3->X3_ARQUIVO == AllTrim(cCbTab))
	aAdd(aItCbCpo, SX3->X3_CAMPO)
	SX3->(DbSkip())
End

If oCbCpo # Nil
	oCbCpo:SetItems(aItCbCpo)
	oCbCpo:Refresh()
EndIf

RestArea(aArea)
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_MudaCpo(cCbCpo, cExpr, cPict,oExpr)

DbSelectArea("SX3")
dbSetOrder(2)
DbSeek(Alltrim(cCbCpo))

cPict := SX3->X3_PICTURE

If Empty(AllTRIM(cPict))
	cPict := "@!"
EndIf

cExpr := Nil

If SX3->X3_TIPO == "C"
	cExpr := Space(SX3->X3_TAMANHO)
ElseIf SX3->X3_TIPO == "N"
	cExpr := 0
ElseIf SX3->X3_TIPO == "D"
	cExpr := dDataBase
Else
	cExpr := Space(SX3->X3_TAMANHO)
EndIf

If oExpr # Nil
	oExpr:Refresh()
EndIf

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_BAdFil(cMemo,cCbTab1,cCbCpo1,cCbOpera,nCbAtOp,cCbTab2,cCbCpo2,cExpr1,cRFil)

If "Expressao" $ cCbCpo2
	// Adicionar campo da esquerda + operacao + campo de expressao
	cMemo += cCbCpo1 + " " + cCbOpera + " "
	
	If ValType(cExpr1) == "C"
		cMemo += "'" + cExpr1 + "'"
	ElseIf ValType(cExpr1) == "N"
		cMemo += Str(cExpr1)
	ElseIf ValType(cExpr1) == "D"
		cMemo += "'" + DtoS(cExpr1) + "'"
	Else
		cMemo += "'" + cExpr1 + "'"
	EndIf
	
Else
	// Adicionar campo da esquerda + operacao + campo da direita
	cMemo += cCbCpo1 + " " + cCbOpera + " " + cCbCpo2
EndIf

cRFil := FS_TradOp(cCbTab1,cCbCpo1,nCbAtOp,cCbTab2,cCbCpo2,cExpr1)

oBtnAd:Disable()
oBtnPE:Disable()
If nContPar > 0
	oBtnPD:Enable()
EndIf
oBtnE:Enable()
oBtnOu:Enable()

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_BtnPare(cMemo, cParentese, cRFil)

cMemo   += " " + cParentese + " "
cRFil += cParentese

If cParentese == "("
	nContPar++
	oBtnAd:Enable()
	oBtnPE:Enable()
	oBtnPD:Disable()
	oBtnE:Disable()
	oBtnOu:Disable()
Else
	nContPar--
	oBtnAd:Disable()
	oBtnPE:Disable()
	If nContPar > 0
		oBtnPD:Enable()
	Else
		oBtnPD:Disable()
	EndIf
	oBtnE:Enable()
	oBtnOu:Enable()
EndIf

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_BtnEOu(cMemo, cOpRel, cRFil)

cMemo += " " + cOpRel + " "

cRFil += Iif(cOpRel == "E", " AND ", " OR ")

oBtnAd:Enable()
oBtnPE:Enable()
oBtnPD:Disable()
oBtnE:Disable()
oBtnOu:Disable()

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_BtnLimp(cMemo, cRFil)

cMemo   := ""
cRFil := ""

nContPar := 0

oBtnAd:Enable()
oBtnLF:Enable()
oBtnPE:Enable()
oBtnPD:Disable()
oBtnE:Disable()
oBtnOu:Disable()

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_TradOp(cCbTab1,cCbCpo1,nCbAtOp,cCbTab2,cCbCpo2,cExpr1)

Local cAuxFil := "", cExpressao := ""

If ValType(cExpr1) == "C"
	cExpressao := "'" + cExpr1 + "'"
ElseIf ValType(cExpr1) == "N"
	cExpressao := AllTrim(Str(cExpr1))
ElseIf ValType(cExpr1) == "D"
	cExpressao := "'" + DtoS(cExpr1) + "'"
Else
	cExpressao := "'" + cExpr1 + "'"
EndIf

cAuxFil += cCbTab1 + "." + cCbCpo1

If nCbAtOp == 1 // "Igual a"
	
	cAuxFil += " = " + Iif("Expressao" $ cCbCpo2, cExpressao, cCbTab2 + "." + cCbCpo2)
	
ElseIf nCbAtOp == 2 //"Diferente de"
	
	cAuxFil += " <> " + Iif("Expressao" $ cCbCpo2, cExpressao, cCbTab2 + "." + cCbCpo2) + " "
	
ElseIf nCbAtOp == 3 //"Menor que"
	
	cAuxFil += " < " + Iif("Expressao" $ cCbCpo2, cExpressao, cCbTab2 + "." + cCbCpo2) + " "
	
ElseIf nCbAtOp == 4 //"Menor ou igual a"
	
	cAuxFil += " <= " + Iif("Expressao" $ cCbCpo2, cExpressao, cCbTab2 + "." + cCbCpo2) + " "
	
ElseIf nCbAtOp == 5 //"Maior que"
	
	cAuxFil += " > " + Iif("Expressao" $ cCbCpo2, cExpressao, cCbTab2 + "." + cCbCpo2) + " "
	
ElseIf nCbAtOp == 6 //"Maior ou igual a"
	
	cAuxFil += " >= " + Iif("Expressao" $ cCbCpo2, cExpressao, cCbTab2 + "." + cCbCpo2) + " "
	
ElseIf StrZero(nCbAtOp,2) $ "07/08" //"Contem a expressao" / "Nใo contem"
	
	cAuxFil += Iif(nCbAtOp == 7, " LIKE ", " NOT LIKE ")
	
	If  "Expressao" $ cCbCpo2
		If ValType(cExpr1) == "C"
			cAuxFil += "'%" + cExpr1 + "%'"
		ElseIf ValType(cExpr1) == "N"
			cAuxFil += "'%" + AllTrim(Str(cExpr1)) + "%'"
		ElseIf ValType(cExpr1) == "D"
			cAuxFil += "'%" + DtoS(cExpr1) + "%'"
		Else
			cAuxFil += "'%" + cExpr1 + "%'"
		EndIf
	Else
		cAuxFil += cCbTab2 + "." + cCbCpo2
	EndIf
	
ElseIf StrZero(nCbAtOp,2) $ "09/10" //"Esta contido em"
	
	cAuxFil += Iif(nCbAtOp == 9, " IN (", " NOT IN (")
	
	If  "Expressao" $ cCbCpo2
		If ValType(cExpr1) == "C"
			cAuxFil += "'" + cExpr1 + "')"
		ElseIf ValType(cExpr1) == "N"
			cAuxFil += AllTrim(Str(cExpr1)) + ")"
		ElseIf ValType(cExpr1) == "D"
			cAuxFil += "'" + DtoS(cExpr1) + "')"
		Else
			cAuxFil += "'" + cExpr1 + "')"
		EndIf
	Else
		cAuxFil += cCbTab2 + "." + cCbCpo2  + ")"
	EndIf
	
EndIf

Return(cAuxFil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_EDiRQry(cQuery)
Local cStr := "", xValor, cQryAux := ""

While (nPos1 := At("[", cQuery)) > 0
	If (nPos2 := At("]", cQuery)) > 0
		
		cStr   := Substr(cQuery, nPos1 + 1 , nPos2 - nPos1 - 1 )
		xValor := &(cStr)
		
		If ValType(xValor) == "C"
			cQryAux := xValor
		ElseIf ValType(xValor) == "N"
			cQryAux := Str(xValor)
		ElseIf ValType(xValor) == "D"
			cQryAux := "'" + DtoS(xValor) + "'"
		Else
			cQryAux := "'" + xValor + "'"
		EndIf
		
		cQuery := StrTran(cQuery, "[" + cStr, cQryAux,,1)
		cQuery := StrTran(cQuery, "]", "",,1)
		
		xValor := Nil
	Else
		HS_MsgInf("Sintaxe incorreta", "Aten็ใo","Anแlise EDI")
	EndIf
End

Return(cQuery)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorno String de controle do arquivo XML                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Function HS_CHashXml()
Local nHndHash := 0
Local cRetHash := ""

nHndHash := fCreate("XmlHash.Txt")
fWrite(nHndHash, __cHXml, Len(__cHXml))
fClose(nHndHash)

cRetHash := MD5(__cHXml, 2)

Return(cRetHash)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_CamMac(cCamMac)
Local nForMem := 0

For nForMem := 1 To MLCount(cCamMac)
	
	&(MemoLine(cCamMac,, nForMem))
	
Next nForMem
Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Function Hs_LayDump()
Local lRet    := .F.
Private aTravas := {}

Alert("Rotina de exporta็ใo descontinuada")
Return()

While !(lRet := Hs_LockTab(@aTravas, "GG2", "HSLAYDUMP"))
	
	If !MsgYesNo("Rotina de Exporta็ใo de Layout bloqueada por outro usuแrio." +;
		"Deseja tentar novamente?")
		Exit
	EndIf
End

If lRet
	Processa({|| Fs_LayDump()})
EndIf

HS_UnLockT(@aTravas)
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function Fs_LayDump(cAlias, nReg, nOpc)
Local aArea   := GetArea()
//{cTab, cArq, cInd, cAlias, aCampos, cChvSix, Header, Cols}
Local aTabs   := {}

Local aAux    := {}
Local aCampos := {}
Local cChvSix := ""
Local nX := 0, nY := 0, nCont := 0

Local cEnvSrv     := GetEnvServer()
Local cLocalFiles := Upper(GetPvProfString(cEnvSrv, "LocalFiles", "ADS", GetADV97()))
Local cRdd        := ""

Local nContFor    := 0
Local nTot        := 0
Local aArqGer     := {}
Local cSx1Grupo   := ""

Private aHGG3 := {}
Private aCGG3 := {}
Private nUGG3 := 0
Private cGrupo      := ""

Alert("Op็ใo de exporta็ใo descontinuada!")
Return()

cDir := getMv("MV_DEXPLAY")
If Substr(cDir,len(cDir)) $ "\/"
	cDir := SubStr(cDir, 1, Len(cDir)-1)
EndIF
If !HS_VldSx6({{"MV_DEXPLAY",{"C","","","File('"+cDir+"')"}}},.T.)
	Return(.F.)
EndIf
cDir += "/"

If !Pergunte("HSPM52", .T.)
	Return(.F.)
EndIf

While Empty(MV_PAR01) .Or. Empty(MV_PAR02) .Or. Empty(MV_PAR03)
	Hs_MsgInf("Todos os campos devem estar preenchidos","Aten็ใo","Valida็ใo Exporta็ใo")
	If !Pergunte("HSPM52", .T.)
		Return(.F.)
	EndIf
End

If (nTot := Hs_CountTb("GG2", " GG2_CODPAR >= '"+MV_PAR01+"' AND GG2_CODPAR <= '"+MV_PAR02+"'")) == 0
	Hs_MsgInf("Nenhum registro encontrado","Aten็ใo","Valida็ใo")
	Return(.F.)
EndIf

aTabs   := {{"GG2","","GG2->GG2_CODPAR >= '"+MV_PAR01+"' .And. GG2->GG2_CODPAR <= '"+MV_PAR02+"'","",""},;
{"GG3","","GG3->GG3_CODPAR >= '"+MV_PAR01+"' .And. GG3->GG3_CODPAR <= '"+MV_PAR02+"'","",""},;
{"GG4","","GG4->GG4_CODPAR >= '"+MV_PAR01+"' .And. GG4->GG4_CODPAR <= '"+MV_PAR02+"'","",""},;
{"GG8","","GG8->GG8_CODPAR >= '"+MV_PAR01+"' .And. GG8->GG8_CODPAR <= '"+MV_PAR02+"'","",""},;
{"GG0","",'"GG0->GG0_CODGRU IN ("+cGrupo+")"',"",""},;
{"GG1","",'"GG1->GG1_CODGRU IN ("+cGrupo+")"',"",""}}

If MV_PAR03 == 1
	cRdd := "DBFCDXADS"
Else
	cRdd := "CTREECDX"
EndIf

ProcRegua(Len(aTabs))
IncProc(OemToAnsi("Carregando Dados Layout ..."))
For nX := 1 to Len(aTabs)
	IncProc()
	aAux := Fs_GeraArq(aTabs[nx][1], IIF(aTabs[nx][1] $ "GG0/GG1",&(aTabs[nx][3]),aTabs[nx][3]),"TMPM52", , ,@aArqGer)
	
	aTabs[nx][2] := aAux[1]
	aTabs[nx][4] := aAux[2]
	aTabs[nx][5] := aAux[3]
	
	If aTabs[nx][1] == "GG2"
		DbSelectArea(aTabs[nx][2])
		DbGoTop()
		While &(aTabs[nx][2]+"->(!EoF())")
			If !Empty(&(aTabs[nx][2]+"->GG2_PERGUN"))
				cSx1Grupo += PADR(&(aTabs[nx][2]+"->GG2_PERGUN"), Len(SX1->X1_GRUPO),"")+"/"
			EndIf
			DbSkip()
		EndDo
	ElseIf aTabs[nx][1] == "GG3"
		HS_BDados("GG3", @aHGG3, @aCGG3, @nUGG3, 1,, "GG3->GG3_CODPAR >=  '"+MV_PAR01+"' AND GG3->GG3_CODPAR <= '"+MV_PAR02+"'",Nil,,,,,,,,.T.)
		nGG3Item   := aScan(aHGG3, {| aVet | AllTrim(aVet[2]) == "GG3_ITEM"  })
		nGG3TipReg := aScan(aHGG3, {| aVet | AllTrim(aVet[2]) == "GG3_TIPREG"})
		nGG3CodGru := aScan(aHGG3, {| aVet | AllTrim(aVet[2]) == "GG3_CODGRU"})
		
		For nCont := 1 to Len(aCGG3)
			IF !aCGG3[nCont, nGG3CodGru] $ cGrupo
				cGrupo += IIF(Empty(cGrupo),"",",")+"'"+aCGG3[nCont, nGG3CodGru]+"'"
			EndIf
		Next
	EndIf
Next

ProcRegua(Len(aTabs))
IncProc(OemToAnsi("Exportando Layouts para "+cDir))
For nX := 1 To Len(aTabs)
	DbSelectArea(aTabs[nX][2])
	DbGoTop()
	
	
	DbCloseArea()
	IncProc()
Next

ProcRegua(2)
IncProc(OemToAnsi("Apagando Arquivos Temporแrios"))
Fs_ApgArq(aArqGer)
IncProc(OemToAnsi("Finalizando ..."))
Hs_MsgInf("Layouts exportados com sucesso","Aten็ใo", "Exporta็ใo Completa")

RestArea(aArea)

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_DbClik(oObj)
Local cMark := oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos]

If oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] $ "LBTIK/LBNO"
	oObj:aCols[oObj:nAt, oObj:oBrowse:ColPos] := IIF(cMark == "LBTIK", "LBNO", "LBTIK")
EndIf

oObj:Refresh()
Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Function HS_LayLoad()

Local lRet    := .F.
Private aTravas := {}

While !(lRet := Hs_LockTab(@aTravas, "GG2", "HSLAYLOAD"))
	
	If !MsgYesNo("Rotina de Importa็ใo de Layout bloqueada por outro usuแrio." +;
		"Deseja tentar novamente?")
		Exit
	EndIf
End

If lRet
	Processa({|| FS_LayLoad()})
EndIf

HS_UnLockT(@aTravas)
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_LayLoad()
Local aArea := GetArea()
Local cDir    := ""//GetMv("MV_DEXPLAY", ,"")
Local cTabRec := ""
Local cInd    := ""
Local nPos    := 0
Local aLayout := {}
Local nX := 0
Local aHGG2 := {}, aCGG2 := {} , oGDGG2
Local nOpcA := 0
Local aTabs      := {{"GG2","TMPM52GG2","GG2_CODPAR $ cLayout","",""},{"GG3","TMPM52GG3","GG3_CODPAR $ cLayout","",""},;
						{"GG4","TMPM52GG4","GG4_CODPAR $ cLayout","",""},{"GG8","TMPM52GG8","GG8_CODPAR $ cLayout","",""},;
{"GG0","TMPM52GG0","GG0_CODGRU $ cGrupo" ,"",""},{"GG1","TMPM52GG1","GG1_CODGRU $ cGrupo" ,"",""}}
Local cOldCodPar := ""
Local cCodPar    := ""
Local aAuxGG0    :=  {}
Local nCont := 0
Local aAux  := {}
Local aGG2 := {}, aGG3 := {}, aGG4 := {}, aGG1 := {}, aGG0 := {}, aGG8 := {}
Local aMemos := {}
Local nContMemo := 0
Local cMsg := ""
Local aArqGer   := {}
Local lMarca    := .T.
Local aButtons  := {}
Local cMsgErro  := ""

Private cChvSix
Private cLayout   := ""
Private cGrupo    := ""

cDir := getMv("MV_DEXPLAY")
If Substr(cDir,len(cDir)) $ "\/"
	cDir := SubStr(cDir, 1, Len(cDir)-1)
EndIF
If !HS_VldSx6({{"MV_DEXPLAY",{"C","","","File('"+cDir+"')"}}},.T.)
	Return(.F.)
EndIf
cDir += "/"

ProcRegua(2)

IncProc(OemToAnsi("Carregado Dados Layout"))
ProcRegua(Len(aTabs))
For nX := 1 To Len(aTabs)
	IncProc()
	If FILE ( cDir +aTabs[nX][1]+"EXP"+GetDBExtension() )
		Fs_CriaArq(aTabs[nX][1], cDir +aTabs[nX][1]+"EXP", , ,@aArqGer,.T., .F.)
	Else
		Hs_MsgInf("Arquivo "+cDir +aTabs[nX][1]+"EXP"+GetDBExtension()+" nใo encontrado."+;
		"Verifique!","Aten็ใo","Opera็ใo Cancelada")
		Fs_ApgArq(aArqGer)
		Return(.F.)
	EndIf
Next

DbSelectArea("TMPM52GG2")
DbSetOrder(1)
DbGoTop()
ProcRegua(TMPM52GG2->(RECNO()))

aAdd(aButtons,{"CHECKED", {|| FS_MarcT(lMarca, oGDGG2), lMarca := !lMarca}, "Todos", "Marcar Todos"})

While !TMPM52GG2->(Eof())
	IncProc()
	aAdd(aCGG2, {"LBNO", TMPM52GG2->GG2_FILIAL/*FWCodFil()*/ , TMPM52GG2->GG2_CODPAR, TMPM52GG2->GG2_DESCRI,.F.})
	DbSkip()
End

Aadd(aHGG2, {" "             , "cRet"     , "@BMP"  , 2                        , 0, ".F.", ""   , "C", "", "V" , "" , "","","V"})
Aadd(aHGG2, {"Filial"        , "cFilial"  , "@!"    , TamSx3("GG2_FILIAL")[1] , 0, ".F.", ""    , "C", "", "V" , "" , "", "", "V"})
Aadd(aHGG2, {"Layout"        , "cCODPAR"  , "@!"    , TamSx3("GG2_CODPAR")[1] , 0, ".F.", ""    , "C", "", "V" , "" , "", "", "V"})
Aadd(aHGG2, {"Descricao"     , "cDESCRI"  , "@!"    , TamSx3("GG2_DESCRI")[1] , 0, ".F.", ""    , "C", "", "V" , "" , "", "", "V"})


DEFINE MSDIALOG oDlg TITLE "Selecione Layout para Importa็ใo" From 000, 000 To 300, 500 Of oMainWnd Pixel

oGDGG2 := MsNewGetDados():New(000, 000, 300, 500,0,,,,,,,,,, oDlg, aHGG2, aCGG2)
oGDGG2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
oGDGG2:oBrowse:BlDblClick := { || FS_DbClik(oGDGG2) }

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {||nOpca := 1, oDlg:End()}, {|| nOpca := 0, oDlg:End()},, aButtons)

If nOpcA == 1
	If aScan(oGDGG2:aCols, {| aVet | aVet[1] == "LBTIK"}) == 0
		Hs_MsgInf("Nenhum Layout Selecionado", "Aten็ใo", "Valida็ใo")
	Else
		While aScan(oGDGG2:aCols, {| aVet | aVet[1] == "LBTIK"}, nPos+1) > 0
			nPos := aScan(oGDGG2:aCols, {| aVet | aVet[1] == "LBTIK"}, nPos+1)
			aAdd(aLayout, {oGDGG2:aCols[nPos, 2],oGDGG2:aCols[nPos, 3]})
			cLayout += IIF(EMPTY(cLayout),"","/")+oGDGG2:aCols[nPos, 3]
		End
		cLayout := "'"+cLayout+"'"
	EndIf
Else
	Fs_ApgArq(aArqGer)
	Return(.F.)
EndIf

ProcRegua(2)
IncProc(OemToAnsi("Criando Arquivos Temporแrios"))

ProcRegua(Len(aTabs))
For nX := 1 to Len(aTabs)
	IncProc()
	aAux := Fs_GeraArq(aTabs[nx][1], "", "_TMP", aTabs[nx][2], aTabs[nx][3], @aArqGer)
	cAliasRec   := aAux[1]
	cTabRec     := aAux[2]
	cInd        := aAux[3]
	
	DbSelectArea("_TMP"+aTabs[nx][1])
	DbCloseArea()
	
	DbSelectArea(aTabs[nx][2])
	DbCloseArea()
	
	Fs_CriaArq(aTabs[nX][1], cTabRec, ,cInd, @aArqGer)
	aTabs[nX][4] := cTabRec
	aTabs[nX][5] := cInd
	
	If aTabs[nx][1] == "GG3"
		DbSelectArea("TMPM52GG3")
		DbSetOrder(1)
		DbGoTop()
		While !Eof()
			IF !TMPM52GG3->GG3_CODGRU $ cGrupo
				aAdd(aAuxGG0,{TMPM52GG3->GG3_FILIAL/*FWCodFil()*/,TMPM52GG3->GG3_CODGRU})
				cGrupo += IIF(Empty(cGrupo),"","/")+TMPM52GG3->GG3_CODGRU
			EndIf
			DbSkip()
		End
		cGrupo := "'"+cGrupo+"'"
	EndIf
	
Next
aAux := {}
While __lSx8
	RollBackSxe()
End

Begin Transaction
ProcRegua(Len(aLayout)*Len(aTabs) )
IncProc(OemToAnsi("Carregando Dados ..."))
For nX := 1 to Len(aLayout)
	cCodPar := GetSxeNum('GG2','GG2_CODPAR',,1)
	lExiste := .F.
	For nCont := 1 To Len(aTabs)
		If aTabs[nCont][1] $ "GG0/GG1"
			Loop
		EndIf
		
		If aTabs[nCont][1] == "GG2"
			DbSelectArea(aTabs[nCont][2])
			DbSetOrder(1)
			DbGoTop()
			If DbSeek(Padr(aLayout[nX][1],TamSx3("GG2_FILIAL")[1])+cCodPar)  
				lExiste := .T.
				aAdd(aAux, {aLayout[nX][1]+cCodPar})
				nAuxPos := aScan(aLayout,{ |aVet| aLayout[nX][1]+cCodPar == aVet[1]+aVet[2]})
				cAuxFil := aLayout[nX][1]
				cAuxCod := aLayout[nX][2]
				aLayout[nX][1] := aLayout[nAuxPos][1]
				aLayout[nX][2]	 := aLayout[nAuxPos][2]
				aLayout[nAuxPos][1] := cAuxFil
				aLayout[nAuxPos][2] := cAuxCod
			EndIf
			
			IncProc(OemToAnsi("Importando Layout "+&(aTabs[nCont][2]+"->GG2_DESCRI")))
		EndIf
		
		DbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek(aTabs[nCont][1])
		aMemos := {}
		While !SX3->(Eof()) .And. X3_ARQUIVO == aTabs[nCont][1]
			If SX3->X3_TIPO == "M" .AND. SX3->X3_CONTEXT == "V"
				aAdd(aMemos, {SX3->X3_CAMPO, SX3->X3_RELACAO, SX3->X3_TAMANHO})
			EndIF
			DbSkip()
		End
		
		DbSelectArea(aTabs[nCont][2])
		DbSetOrder(1)
		DbGoTop()
		If lExiste
			If DbSeek(Padr(aLayout[nX][1],TamSx3("GG2_FILIAL")[1])+aLayout[nX][2])
				While !&(aTabs[nCont][2])->(EoF()) .And. &(aTabs[nCont][2]+"->"+aTabs[nCont][1]+"_FILIAL")+&(aTabs[nCont][2]+"->"+aTabs[nCont][1]+"_CODPAR") == aLayout[nX][1]+aLayout[nX][2]
					RecLock(aTabs[nCont][2],.F.)
					If aTabs[nCont][1] # "GG3"
						&(aTabs[nCont][2]+"->"+aTabs[nCont][1]+"_FILIAL") := xFilial(aTabs[nCont][1])
					EndIf
					&(aTabs[nCont][2]+"->"+aTabs[nCont][1]+"_CODPAR") := cCodPar
					
					For nContMemo := 1 to len(aMemos)
						Fs_GrvMemo(aTabs[nCont][1], aTabs[nCont][2], aMemos[nContMemo])
					Next
					MsUnLock()
					While __lSx8
						ConfirmSx8()
					End
					DbSelectArea(aTabs[nCont][2])
					DbSkip()
				End
			EndIf
		Else
			While DbSeek(Padr(aLayout[nX][1],TamSx3("GG2_FILIAL")[1])+aLayout[nX][2])
				RecLock(aTabs[nCont][2],.F.)
				If aTabs[nCont][1] # "GG3"
					&(aTabs[nCont][2]+"->"+aTabs[nCont][1]+"_FILIAL") := xFilial(aTabs[nCont][1])
				EndIf
				
				&(aTabs[nCont][2]+"->"+aTabs[nCont][1]+"_CODPAR") := cCodPar
				
				For nContMemo := 1 to len(aMemos)
					Fs_GrvMemo(aTabs[nCont][1], aTabs[nCont][2], aMemos[nContMemo])
				Next
				MsUnLock()
				While __lSx8
					ConfirmSx8()
				End
				DbSelectArea(aTabs[nCont][2])
			End
		EndIf
	Next
Next

If OrdBagExt() == ".IDX"
	If Select("TMPM52GG3") > 0
		DbSelectArea("TMPM52GG3")
		CtreeDelIdxs()
		DbCloseArea()
	EndIf
	CTREEDELINT("TMPM52GG3")
Else
	DbSelectArea("TMPM52GG3")
	DbCloseArea()
End

nPos := aScan(aTabs,{|aVet| aVet[2] == "TMPM52GG3"})

fErase(aTabs[nPos][5] + ".CDX")

cInd   := CriaTrab(Nil , .F.)

DbUseArea(.T.,aTabs[nPos][4],"TMPM52GG3",.T.,.F.)
//USE &(aTabs[nPos][4]) NEW ALIAS "TMPM52GG3"
DbCreateIndex(cInd, "GG3_FILIAL+GG3_CODGRU+GG3_ITEM", {|| GG3_FILIAL + GG3_CODGRU + GG3_ITEM})

DbSelectArea("TMPM52GG3")
DbCloseArea()

DbSetIndex(cInd)
DbSetOrder(1)

aArqGer[aScan(aArqGer,{|aVet| aVet[3] == aTabs[nPos][5]})][3] := cInd

aTabs[nPos][5] := cInd

aSort(aTabs,,,{|x , y| x[1] < y[1]})
While __lSx8
	RollBackSxe()
End

ProcRegua(Len(aAuxGG0)*Len(aTabs))
IncProc(OemToAnsi("Importando dados complementares..."))
For nX := 1 to Len(aAuxGG0)
	cCodPar := GetSxeNum('GG0','GG0_CODGRU',,1)
	lExiste := .F.
	For nCont := 1 To Len(aTabs)
		If !aTabs[nCont][1] $ "GG0/GG1/GG3"
			Loop
		EndIf
		IncProc()
		If aTabs[nCont][1] == "GG0"
			DbSelectArea(aTabs[nCont][2])
			DbSetOrder(1)
			DbGoTop()
			If DbSeek(aAuxGG0[nX][1]+cCodPar)
				lExiste := .T.
				aAdd(aAux, {aAuxGG0[nx][1]+cCodPar})
				nAuxPos := aScan(aAuxGG0,{ |aVet| aAuxGG0[nX][1]+cCodPar == aVet[1]+aVet[2]})
				cAuxFil := aAuxGG0[nX][1]
				cAuxCod := aAuxGG0[nX][2]
				aAuxGG0[nX][1] := aAuxGG0[nAuxPos][1]
				aAuxGG0[nX][2]	 := aAuxGG0[nAuxPos][2]
				aAuxGG0[nAuxPos][1] := cAuxFil
				aAuxGG0[nAuxPos][2] := cAuxCod
			EndIf
		EndIf
		
		DbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek(aTabs[nCont][1])
		aMemos := {}
		While !SX3->(Eof()) .And. X3_ARQUIVO == aTabs[nCont][1]
			If SX3->X3_TIPO == "M" .AND. SX3->X3_CONTEXT == "V"
				aAdd(aMemos, {SX3->X3_CAMPO, SX3->X3_RELACAO, SX3->X3_TAMANHO})
			EndIF
			DbSkip()
		End
		
		DbSelectArea(aTabs[nCont][2])
		DbSetOrder(1)
		DbGoTOp()
		If lExiste
			If DbSeek(aAuxGG0[nx][1]+aAuxGG0[nx][2])
				While !&(aTabs[nCont][2])->(EoF()) .And. &(aTabs[nCont][2]+"->"+aTabs[nCont][1]+"_FILIAL")+&(aTabs[nCont][2]+"->"+aTabs[nCont][1]+"_CODGRU") == aAuxGG0[nX][1]+aAuxGG0[nX][2]
					RecLock(aTabs[nCont][2],.F.)
					&(aTabs[nCont][2]+"->"+aTabs[nCont][1]+"_FILIAL") := xFilial(aTabs[nCont][1])
					&(aTabs[nCont][2]+"->"+aTabs[nCont][1]+"_CODGRU") := cCodPar
					
					For nContMemo := 1 to len(aMemos)
						Fs_GrvMemo(aTabs[nCont][1], aTabs[nCont][2], aMemos[nContMemo])
					Next
					MsUnLock()
					While __lSx8
						ConfirmSx8()
					End
					DbSelectArea(aTabs[nCont][2])
					DbSkip()
				End
			EndIf
		Else
			While DbSeek(aAuxGG0[nx][1]+aAuxGG0[nx][2])
				RecLock(aTabs[nCont][2],.F.)
				&(aTabs[nCont][2]+"->"+aTabs[nCont][1]+"_FILIAL") := xFilial(aTabs[nCont][1])
				&(aTabs[nCont][2]+"->"+aTabs[nCont][1]+"_CODGRU") := cCodPar
				
				For nContMemo := 1 to len(aMemos)
					Fs_GrvMemo(aTabs[nCont][1], aTabs[nCont][2], aMemos[nContMemo])
				Next
				MsUnLock()
				While __lSx8
					ConfirmSx8()
				End
				DbSelectArea(aTabs[nCont][2])
			End
		EndIf
	Next
Next

//--------------- AJUSTA FILIAL   
For nCont := 1 To Len(aLayout)
	DbSelectArea("TMPM52GG2")
	DbSetOrder(1)
	DbGoTOp()
	If DbSeek(Padr(aLayout[nCont,1],TamSx3("GG2_FILIAL")[1]) + aLayout[nCont,2])
		RecLock("TMPM52GG2",.F.)
		TMPM52GG2->GG2_FILIAL := FWCodFil()
		MsUnLock()
	EndIf  
Next nCont

//------------------------------


ProcRegua(Len(aTabs))
IncProc("Finalizando Opera็ใo ...")
For nX := 1 To Len(aTabs)
	DbSelectArea(aTabs[nx][1])
	
	APPEND FROM &(aTabs[nx][4] + GetDBExtension())
	
	DbSelectArea(aTabs[nx][2])
	DbCloseArea()
	IncProc()
Next

If FILE ( cDir +"SX1EXP"+GetDBExtension() )
	If !Empty(cMsgErro := Fs_CopySx1(cDir, @aArqGer))
		Hs_MsgInf(cMsgErro, "Aten็ใo", "Valida็ใo Importa็ใo SX1")
	EndIf
EndIF

Fs_ApgArq(aArqGer)

DbSelectArea("GG2")
End Transaction

While __lSx8
	RollBackSx8()
End

Hs_MsgInf("Layouts importados com sucesso","Aten็ใo", "Importa็ใo Completa")

MBrChgLoop(.F.)
RestArea(aArea)
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
/*Static Function Fs_CopySx1(cDir, aArqGer)
Local cInd1 := ""
Local nTamSx1  := Len(SX1->X1_GRUPO)
Local cSx1Grp  := ""
Local cSx1NImp := ""
Local cMsgErro := ""

cInd1   := CriaTrab(Nil , .F.)
DbUseArea(.T., , cDir +"SX1EXP", "TMPM52SX1", .F., .F.) 
//USE &(cDir +"SX1EXP") NEW ALIAS "TMPM52SX1"
TMPM52SX1->(DbCreateIndex(cInd1,"X1_GRUPO", {|| X1_GRUPO }))

DbSelectArea("TMPM52SX1")
DbCloseArea()

//DbUseArea(.T., , cDir +"SX1EXP", "TMPM52SX1", .T., .F.)
TMPM52SX1->(DbSetIndex(cInd1))
TMPM52SX1->(DbSetOrder(1))

While TMPM52SX1->(!Eof())
	
	If (cSx1Grp # TMPM52SX1->X1_GRUPO)
		
		If nTamSx1 <  Len(AllTrim(TMPM52SX1->X1_GRUPO))
			cSx1Grp := TMPM52SX1->X1_GRUPO
			cSx1NImp += TMPM52SX1->X1_GRUPO+"/"
			cMsgErro += " O Grupo de Perguntas "+ AllTrim(TMPM52SX1->X1_GRUPO)+" nใo foi importado, devido incompatibilidade do dicionแrio."+chr(13)+chr(10)
		Else
			DbSelectArea("SX1")
			DbSetOrder(1)
			
			If DbSeek(PADR(TMPM52SX1->X1_GRUPO, nTamSx1, ""))
				While SX1->(!Eof()) .And. SX1->X1_GRUPO == PADR(TMPM52SX1->X1_GRUPO, nTamSx1, "")
					RecLock("SX1", .F.)
					DbDelete()
					MsUnLock()
					DbSkip()
				EndDo
			EndIf
			cSx1Grp := TMPM52SX1->X1_GRUPO
		EndIf
	EndIf
	
	DbSelectArea("TMPM52SX1")
	DbSkip()
EndDo

DbSelectArea("SX1")

APPEND FROM &(cDir +"SX1EXP" + GetDBExtension()) FOR !(X1_GRUPO $ cSx1NImp)

DbSelectArea("TMPM52SX1")
DbCloseArea()

aAdd(aArqGer, {"TMPM52SX1", cDir +"SX1EXP", cInd1, .T.})

Return(cMsgErro)*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function Fs_GrvMemo(cAlias, cAliasTmp,aMemo)
Local lRet := .F.
Local nPos := aT("MSMM", aMemo[2])
Local cCpoCod := "", cChave := "", cSeq := "0" , cString := ""
Local nYP_CAMPO := 0
Local nCont     := 0
cString := &(cAliasTmp+"->"+aMemo[1])

If (nPos == 0) .Or. Empty(cString)
	return(lRet)
EndIf

nPos := aT(cAlias+"_", aMemo[2])
cCpoCod := Substr(aMemo[2], nPos, Len(SX3->X3_CAMPO))
cChave  := GetSX8Num("SYP","YP_CHAVE")
ConfirmSx8()

nTam    := aMemo[3] - 6

While !Empty(cString)
	nTexto := At(CRLF,cString)
	If nTexto == nTam
		cLine := Subs(cString,1,nTam+1)
	Else
		cLine := Subs(cString,1,nTam)
	EndIf
	nTexto := At(CRLF,cLine)
	
	If nTexto > 0
		cLine := Subs(cLine,1,nTexto-1)+"\13\10"
		nTexto += 2
	Else
		If !Empty(cLine)
			nTexto := nTam+1
			nLen1 := Len(cLine)
			nLen2 := Len(Trim(cLine))
			//verifica se tem espaco no final da linha para colocar no inicio do proximo registro
			If nLen1 <> nLen2
				cLine := Trim(cLine)
				nTexto -= (nLen1 - nLen2)
			EndIf
		Else
			cLine := Subs( cLine, 1, nTam-6 ) + '\14\10'
			nTexto += nTam + 1
		EndIf
	EndIf
	
	cString := Subs(cString,nTexto)
	
	cSeq := PADL(Soma1( cSeq , TAMSX3("YP_SEQ")[1] ), TAMSX3("YP_SEQ")[1],"0")
	
	DbSelectArea("SYP")
	RecLock( "SYP" , .T. )
	FieldPut(FieldPos("YP_FILIAL"),xFilial("SYP"))
	FieldPut(FieldPos("YP_CHAVE"),cChave)
	FieldPut(FieldPos("YP_SEQ"),cSeq)
	FieldPut(FieldPos("YP_TEXTO"),cLine)
	IF (nYP_CAMPO := FieldPos("YP_CAMPO")) > 0
		FieldPut(nYP_CAMPO,cCpoCod)
	EndIF
	MsUnlock()
End

&(cAliasTmp+"->"+cCpoCod)  := cChave

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function Fs_GeraArq(cAlias, cFiltro, cPref, cAliasTmp, cCond, aArqGer)
Local aStru := {}
Local aHDados := {}, aCDados := {}, nUDados := 0
Local aCampos := {}
Local nCont := 0
Local cChvSix := ""
Local aAux := {}
Local nX := 0

Default cAliasTmp := ""
Default cAliasTmp := ""
Default cPref     := ""

aAux := Fs_CriaArq(cAlias, , cPref,,@aArqGer)
cAliasRec := aAux[1]
cTabRec   := aAux[2]
cInd1     := aAux[3]

If !Empty(cAliasTmp)
	cFiltro := "1 = 0"
EndIf

HS_BDados(cAlias, @aHDados, @aCDados, @nUDados, 1,, cFiltro,Nil,,,,,,,,.T.)

DbSelectArea(cAliasRec)
DbSetOrder(1)

If Empty(cAliasTmp)
	For nX := 1 to Len(aCDados)
		RecLock(cAliasRec, .T.)
		For nCont := 1 to Len(aHDados)
			If  HS_CfgSx3(aHDados[nCont, 2])[SX3->(FieldPos("X3_TIPO"))] == "M"
				If ValType(aCDados[nX, nCont]) == "N"
					&(cAlias)->(DbGoTo(aCDados[nX, nCont]))
					&(cAliasRec+"->"+aHDados[nCont, 2]) := &(cAlias +"->"+aHDados[nCont, 2])
				Else
					&(cAliasRec+"->"+aHDados[nCont, 2]) := aCDados[nX, nCont]
				EndIf
				//If HS_CfgSx3(aHDados[nCont, 2])[SX3->(FieldPos("X3_CONTEXT"))] # "V"
				//Else
				//Endif
			ElseIf HS_CfgSx3(aHDados[nCont, 2])[SX3->(FieldPos("X3_CONTEXT"))] # "V"
				&(cAliasRec+"->"+aHDados[nCont, 2]) := IIF(HS_CfgSx3(aHDados[nCont, 2])[SX3->(FieldPos("X3_CAMPO"))] == cAlias+"_FILIAL",xFilial("GG2"), aCDados[nX, nCont])
			EndIf
		Next
		MsUnLock()
	Next
Else
	DbSelectArea(cAliasTmp)
	DbSetOrder(1)
	DbGoTop()
	While !&(cAliasTmp)->(Eof())
		If &(cCond)
			DbSelectArea(cAliasRec)
			RecLock(cAliasRec, .T.)
			For nCont := 1 to Len(aHDados)
				If  HS_CfgSx3(aHDados[nCont, 2])[SX3->(FieldPos("X3_TIPO"))] == "M" .Or. HS_CfgSx3(aHDados[nCont, 2])[SX3->(FieldPos("X3_CONTEXT"))] # "V"
					If Type(cAliasTmp +"->"+aHDados[nCont, 2]) # "U"
						&(cAliasRec+"->"+aHDados[nCont, 2]) := &(cAliasTmp +"->"+aHDados[nCont, 2])
						/*If "_FILIAL" $ aHDados[nCont, 2]
							&(cAliasRec+"->"+aHDados[nCont, 2]) := FWCodFil()
							&(cAliasTmp +"->"+aHDados[nCont, 2]):= FWCodFil()
						Else
							&(cAliasRec+"->"+aHDados[nCont, 2]) := &(cAliasTmp +"->"+aHDados[nCont, 2])
						EndIf */
					EndIf
				EndIf
			Next
			MsUnLock()
		EndIf
		DbSelectArea(cAliasTmp)
		DbSkip()
	End
	
EndIf
Return({cAliasRec, cTabRec, cInd1})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function Fs_CriaArq(cAlias, cFile, cPref, cInd1, aArqGer, lSoInd, lShared)
Local cTabRec := "",  cAliasRec := "", cChvSix := ""
Local aCampos := {}

Default cFile   := ""
Default cInd1   := ""
Default cPref   := "TMPM52"
Default aArqGer := nil
Default lSoInd  := .F.
Default lShared := .T.

cAliasRec := cPref+cAlias

If Empty(cFile)
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cAlias)
	
	While !SX3->(EoF()) .And. X3_ARQUIVO == cAlias
		If     X3_TIPO # "M" .AND. X3_CONTEXT # "V"
			aAdd(aCampos, {X3_CAMPO , TamSX3(X3_CAMPO)[3], TamSX3(X3_CAMPO)[1], TamSX3(X3_CAMPO)[2]})
		ElseIf X3_TIPO == "M"
			aAdd(aCampos, {X3_CAMPO , "M" , 1000, 0})
		EndIf
		DbSkip()
	EndDo
	
	cFile := FWTemporaryTable():New( cAliasRec )
	cFile:SetFields(aCampos)
	cFile:AddIndex("01", {aCampos->X3_CAMPO})
	cFile:Create()
EndIf

cTabRec   := cFile

If Empty(cInd1)
	DbSelectArea("SIX")
	DbSetOrder(1)
	DbSeek(cAlias)
	cChvSix := SIX->CHAVE


	cInd1 := FWTemporaryTable():New( "cInd1" )	
	cInd1:Create() 
	DbCreateIndex(cInd1,cChvSix, {|| &(cChvSix) })
	
	DbSelectArea(cAliasRec)
	DbCloseArea()
EndIf

cAliasRec->(DbSetIndex(cInd1))
cAliasRec->(DbSetOrder(1))

If aArqGer # nil .And. aScan(aArqGer, {|aVet| aVet[2] == cTabRec}) == 0
	aAdd(aArqGer, {cAliasRec, cTabRec, cInd1, lSoInd})
EndIf

Return({cAliasRec, cTabRec, cInd1})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function FS_MarcT(lMarca, oObj, aPos)

Local nForCols := 0
Local nContFor := 0
Local cMarcT   := IIF(lMarca, "LBTIK", "LBNO")

Default aPos := {1}

For nForCols := 1 To Len(oObj:aCols)
	For nContFor := 1 To Len(aPos)
		oObj:aCols[nForCols, aPos[nContFor]] := cMarcT
	Next
Next
oObj:Refresh()

Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
/*Static Function Fs_ApgArq(aArqGer)
Local nI := 0
Local cAliasTab

For nI := 1 to Len(aArqGer)
	
	If Select(aArqGer[nI, 1]) == 0
		DbUseArea(.T., , aArqGer[nI][2], aArqGer[nI][1], .F., .F.) 
		//USE &(aArqGer[nI][2])  NEW ALIAS &(aArqGer[nI][1])
		cAliasTab := aArqGer[nI][1] 
		
		cAliasTab->(DbSetIndex(aArqGer[nI][3]))
		cAliasTab->(DbSetOrder(1))
	EndIf
	
	If OrdBagExt() == ".IDX"
		DbSelectArea(aArqGer[nI, 1])
		CtreeDelIdxs()
		DbCloseArea()
		
		If !aArqGer[nI, 4]
			CTREEDELINT(aArqGer[nI, 2])
		EndIf
	Else
		DbSelectArea(aArqGer[nI, 1])
		DbCloseArea()
	End
	
	fErase(aArqGer[nI, 3] + ".CDX")
	If !aArqGer[nI, 4]
		fErase(aArqGer[nI, 2] + GetDBExtension())
		fErase(aArqGer[nI, 2] + ".FPT")
	EndIf
Next
return(nil)*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณHS_EDIImp ณ Autor ณ Paulo Cesar           ณ Data ณ  12/03/08ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Funcao para importacao de dados - EDI                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Gestao Hospitalar                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_EDIImp(cAlias, nReg, nOpcs)

Local aArea      := GetArea()
Local cExtensao  := AllTrim(HS_RDescrB("GG2_TIPARQ", GG2->GG2_TIPARQ))
// Local bBlock    := ErrorBlock(), bErro := ErrorBlock( { |e| ChekBug(e) } )
Local cModoInt   := GG2->GG2_MODINT
Local aLayOut    := {}, aCabPV := {}, aItemPV1 := {}
Local aCopyItens := {}, nColuna := 0, nLOutOld := 0, aTemItens := {}, aCampos := {}, aDados := {}
Local cMask   := PadR("Texto (*.txt)", 27) + "|*.txt|" + PadR("Todos (*.*)", 27)+ "|*.*|"
Local cFile   := "", cAliasT := "", cChave := ""
Local nInd    := 0, nHandle := 0, nBuffer := 0, nLidos := 0, nTotal := 0, nFor := 0, nPosVet := 0, nConta := 0
Local nForInd := 0
Local lFound  := .F.
Local aIndice := {}
Local lImpArq := GetMv("MV_EDIIMPF",,"F")

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
Private cBuffer := Space(nBuffer)
Private __aTagsFim := {}
Private __lIncReme := .T. // Usado na fun็ใo HS_IncRem para definir se incrementa o sequencial da remessa, .F. nใo incrementa.
Private cVarCabec   := "", cVarItem := ""

If cModoInt <> "I"    // Se nao for Importacao
	HS_MsgInf("Layout ["+GG2->GG2_CODPAR+"] nใo ้ de Importa็ใo!", "Aten็ใo","Importa็ใo")
	Return(.F.)
EndIf

If !Empty(GG2->GG2_ARQIMP) .AND. !File(Alltrim(GG2->GG2_ARQIMP))
	HS_MsgInf("Verifique a estrutura do Arq. Importa็ใo parametrizado [ "+Alltrim(GG2->GG2_ARQIMP)+" ] !", "Aten็ใo","Importa็ใo")
	Return(.F.)
EndIf

If !Empty(GG2->GG2_PERGUN)
	If !Pergunte(GG2->GG2_PERGUN, .T.)
		Return(.F.)
	EndIf
EndIf

If HS_ExisDic({{"C", "GG2_ARQIMP"}}, .F.) .And. !Empty(GG2->GG2_ARQIMP) .And. lImpArq
	cFile := GG2->GG2_ARQIMP
Else
	cFile := Trim(cGetFile(OemToAnsi(	cMask), OemToAnsi("Selecione o Arquivo"), 0,, .F., GETF_ONLYSERVER)) //, 1,, .F., GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY))
EndIf

// cFile := cGetFile(cMask, OemToAnsi("Selecione o arquivo")), 1, "\EDI\TISS\", .F., GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY))
If AllTrim(cFile) = ""
	HS_MsgInf("Selecione um arquivo para importar!", "Aten็ใo","Importa็ใo")
	Return(.F.)
EndIf

FS_CamMac(GG2->GG2_CAMMAC) // Executa macro

If !Empty(GG2->GG2_FUNINI)
	&(GG2->GG2_FUNINI)
EndIf

IncProc(OemToAnsi("Carregando inicializa็๕es..."))

If GG2->GG2_USAIDE != "0"
	
	//QUERY QUE BUSCA O LAYOUT QUE VAI SER SEGUIDO DURANTE A EXPORTACAO
	cSqlLayOut := "SELECT GG3_FILIAL, GG3_CODPAR, GG3_ITEM, GG3_TIPREG, GG3_SEQUEN, GG3_QTDEXE, "
	cSqlLayOut += "       GG3_CODGRU, GG3_IDREG, GG1_IDREG, GG1_COLINI, GG1_TAMCAM, GG1_FUNEXP "
	cSqlLayOut += "FROM " + RetSqlName("GG3") + " GG3 "
	cSqlLayOut += "JOIN " + RetSqlName("GG1") + " GG1 ON GG1.GG1_FILIAL =  '" + xFilial("GG1") +"' "
	cSqlLayOut += "               AND GG1.GG1_CODGRU = GG3.GG3_CODGRU AND GG1_IDREG = '1' AND GG1.D_E_L_E_T_ <> '*' "
	cSqlLayOut += "WHERE GG3.GG3_FILIAL = '" + xFilial("GG3") + "' AND GG3.GG3_CODPAR = '" + GG2->GG2_CODPAR + "' "
	cSqlLayOut += "  AND GG3.D_E_L_E_T_ <> '*' "
	cSqlLayOut += "ORDER BY GG3.GG3_FILIAL, GG3.GG3_SEQUEN, GG1.GG1_ORDCAM "
Else
	cSqlLayOut := "SELECT * "
	cSqlLayOut += "FROM " + RetSqlName("GG2") + " GG2 "
	cSqlLayOut +=   "JOIN " + RetSqlName("GG3") + " GG3 ON GG3.GG3_FILIAL = '" + xFilial("GG3") + "' AND GG3.D_E_L_E_T_ <> '*' AND "
	cSqlLayOut +=                                        "GG3.GG3_CODPAR = GG2.GG2_CODPAR "
	cSqlLayOut += "WHERE GG2.GG2_FILIAL = '" + xFilial("GG2") + "' AND GG2.D_E_L_E_T_ <> '*' AND GG2.GG2_CODPAR = '" + GG2->GG2_CODPAR + "' "
	cSqlLayOut += "ORDER BY GG2.GG2_FILIAL, GG2.GG2_CODPAR, GG3.GG3_SEQUEN"
EndIf

cSqlLayOut := ChangeQuery(cSqlLayOut)

TCQuery cSqlLayOut New Alias "INICIAL"

DbSelectArea("INICIAL")

nHandle := fOpen(cFile, 0)

nTotal := fSeek(nHandle, 0, 2)

fSeek(nHandle, 0)

ProcRegua(nTotal / 300)

While nLidos < nTotal
	FSeek(nHandle, nLidos)
	nBuffer := 500
	cBuffer := Space(nBuffer)
	FRead(nHandle, @cBuffer, nBuffer)
	FSeek(nHandle, nLidos)
	nBuffer := At(Chr(13), cBuffer)
	nBuffer := IIF(nBuffer == 0, 500, nBuffer)
	cBuffer := Space(nBuffer)
	FRead(nHandle, @cBuffer, nBuffer)
	
	//QUERY QUE BUSCA O LAYOUT QUE VAI SER SEGUIDO DURANTE A EXPORTACAO
	cSqlLayOut := "SELECT GG1_ITEM, GG1_SEGMEN, GG1_TIPREG, GG1_ORDCAM, GG1_TAMCAM, GG1_DECIMA, GG1_PICCAM, GG1_COLUNA, "
	cSqlLayOut += "       GG1_FUNEXP, GG1_GRPREP, GG1_QTDREP, GG1_NNIVEL, GG1_MODEXP, GG1_CONEXP, GG1_COLINI, GG1_ORDCPO, "
	cSqlLayOut += "       GG1_IDREG, GG1_POSGRV, GG0_ARQIMP, GG0_ORDARQ, GG0_SEGMEN "
	cSqlLayOut += "FROM " + RetSqlName("GG1") + " GG1 "
	cSqlLayOut += "JOIN " + RetSqlName("GG0") + " GG0 ON GG0.GG0_FILIAL = '" + xFilial("GG0") +"' AND GG0.D_E_L_E_T_ <> '*' "
	cSqlLayOut += "                 AND GG0.GG0_CODGRU = GG1.GG1_CODGRU "
	cSqlLayOut += "WHERE GG1.GG1_FILIAL =  '" + xFilial("GG1") +"' "
	cSqlLayOut += "  AND GG1.GG1_CODGRU = '"+IDRegistro(cBuffer)+"' "
	cSqlLayOut += "  AND GG1.D_E_L_E_T_ <> '*' "
	
	cSqlLayOut := ChangeQuery(cSqlLayOut)
	
	TCQuery cSqlLayOut New Alias "LAYOUT"
	
	DbSelectArea("LAYOUT")
	DbGotop()
	
	If GG2->GG2_EXECAU != "1" // Nao eh execauto
		If Empty(cVarCabec)
			cVarCabec := "__aEDI" + LAYOUT->GG0_ARQIMP + "_Cabec"
		EndIf
		aAdd(&(cVarCabec), {})
		aAdd(aIndice, {LAYOUT->GG0_ARQIMP, LAYOUT->GG0_ORDARQ})
	EndIf
	
	While !eof()
		cDado_EDI := SubStr(cBuffer, Val(LAYOUT->GG1_COLINI), Val(LAYOUT->GG1_TAMCAM))
		If !Empty(LAYOUT->GG1_FUNEXP)
			cDado_EDI := &(LAYOUT->GG1_FUNEXP)
		EndIf
		
		If !Empty(LAYOUT->GG1_COLUNA)
			If GG2->GG2_EXECAU != "0" // ExecAuto
				
				If ValType(&(AllTrim(LAYOUT->GG1_COLUNA))) <> "U" .and. ValType(&("__aEDI"+LAYOUT->GG0_ARQIMP + IIf(GG2->GG2_EXECAU == "1" .Or. (GG2->GG2_EXECAU == "2" .And. LAYOUT->GG0_SEGMEN == "1"), "_Cabec", "_Item"))) <> "U"
					If GG2->GG2_EXECAU == "1" .Or. (GG2->GG2_EXECAU == "2" .And. LAYOUT->GG0_SEGMEN == "1")
						cVarCabec := "__aEDI" + LAYOUT->GG0_ARQIMP + "_Cabec"
						aAdd(&(cVarCabec)[Len(&(cVarCabec))], {&(LAYOUT->GG1_COLUNA), cDado_EDI, val(LAYOUT->GG1_POSGRV)})
					Else
						cVarItem := "__aEDI" + LAYOUT->GG0_ARQIMP + "_Item"
						aAdd(&(cVarItem)[Len(&(cVarCabec))], {&(LAYOUT->GG1_COLUNA), cDado_EDI, val(LAYOUT->GG1_POSGRV)})
					EndIf
				EndIf
				
			Else  // Grava em tabelas
				
				cCpo := AllTrim(StrTran(SubStr(LAYOUT->GG1_COLUNA, At(">", LAYOUT->GG1_COLUNA) + 1, Len(AllTrim(LAYOUT->GG1_COLUNA))), '"', ""))
				If aScan(aCampos, cCpo) == 0
					aAdd(aCampos, cCpo)
				EndIf
				
				aAdd(&(cVarCabec)[Len(&(cVarCabec))], {cDado_EDI, cCpo})
				
			EndIf
		EndIf
		
		DbSkip()
		If val(LAYOUT->GG1_COLINI) == 1  // Se for coluna 1 no mesmo item, entende que serแ o pr๓ximo registro no arquivo de origem.
			nLidos += Len(cBuffer) + 1
			FSeek(nHandle, nLidos)
			nBuffer := 500
			cBuffer := Space(nBuffer)
			FRead(nHandle, @cBuffer, nBuffer)
			
			FSeek(nHandle, nLidos)
			nBuffer := At(Chr(13), cBuffer)
			nBuffer := IIF(nBuffer == 0, 500, nBuffer)
			cBuffer := Space(nBuffer)
			FRead(nHandle, @cBuffer, nBuffer)
		EndIf
	End
	
	DbSelectArea("LAYOUT")
	DbCloseArea()
	
	nLidos += Len(cBuffer) + 1
End

For nFor := 1 To Len(&(cVarCabec))
	HS_ZAPCOND(aIndice[nFor][1])
Next nForInd

For nFor := 1 To Len(&(cVarCabec))
	
	aCabPV   := {}
	aItemPV1 := {}
	
	If GG2->GG2_EXECAU != "0" .and. !Empty(GG2->GG2_FUNFIN) // ExecAuto
		If ValType(&(cVarCabec)) == "A"
			aCabPV := aClone(&(cVarCabec)[nFor])
		EndIf
		
		If ValType(&(cVarItem)) == "A"
			aItemPV1 := aClone(&(cVarItem)[nFor])
		EndIf
		
		DbSelectArea("SX3")
		
		If GG2->GG2_EXECAU == "1"
			
			MSExecAuto(&("{|"+SubStr(alltrim(GG2->GG2_FUNFIN), at("(", GG2->GG2_FUNFIN)+1, (at(")", GG2->GG2_FUNFIN)-1) - at("(", GG2->GG2_FUNFIN))+"| "+ ;
			alltrim(GG2->GG2_FUNFIN)+"}"), aCabPV, 3)
			
		ElseIf GG2->GG2_EXECAU == "2"
			
			MSExecAuto(&("{|"+SubStr(alltrim(GG2->GG2_FUNFIN), at("(", GG2->GG2_FUNFIN)+1, (at(")", GG2->GG2_FUNFIN)-1) - at("(", GG2->GG2_FUNFIN))+"| "+ ;
			alltrim(GG2->GG2_FUNFIN)+"}"), aCabPV, aItemPV1, 3)
		EndIf
		
		If lMsErroAuto
			MostraErro()
		EndIf
		
	Else // Grava em tabelas
		
		aCabPV := aClone(&(cVarCabec)[nFor])
		
		cAliasT := aIndice[nFor][1]
		nInd    := Val(aIndice[nFor][2])
		
		aCPoInd := HS_RetInd(cAliasT, nInd)
		
		cChave := ""
		
		For nForInd := 1 To Len(aCpoInd)
			
			If "_FILIAL" $ aCpoInd[nForInd]
				cChave += xFilial(cAliasT)
			Else
				nPosVet := Ascan(aCabPV,{ |x| aCpoInd[nForInd] $ x[2]})
				cChave  += aCabPV[nPosVet, 1]
			EndIf
			
		Next nForInd
		
		DbSelectArea(cAliasT)
		DbSetOrder(nInd)
		lFound := DbSeek(cChave)
		
		Begin Transaction
		RecLock(cAliasT, !lFound)
		&(cAliasT + "->" + cAliasT + "_FILIAL") := xFilial(cAliasT)
		For nForInd := 1 To Len(aCabPV)
			&(cAliasT + "->" + aCabPV[nForInd, 2]) := aCabPV[nForInd, 1]
		Next nForInd
		MsUnlock()
		End Transaction
		
	EndIf
	
Next

fClose(nhandle)
DbSelectArea("INICIAL")
DbCloseArea()
RestArea(aArea)
Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Function HS_RetInd(cAlias, nInd)

Local cChave := ""
Local nPos   := 0
Local aRet   := {}

DbSelectArea(cAlias)
DbSetOrder(nInd)

cChave := &(cAlias)->(IndexKey(nInd))

While (nPos := At("+", cChave)) > 0
	aAdd(aRet, SubStr(cChave, 1, nPos - 1))
	cChave := SubStr(cChave, nPos + 1, Len(cChave))
End

aAdd(aRet, cChave)
Return(aRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM52  บAutor  ณMicrosiga           บ Data ณ  11/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Function IDRegistro(cLinha)
Local aArea      := GetArea()
Local sRet := ""
DbSelectArea("INICIAL")
DbGotop()

If GG2->GG2_USAIDE != "0"
	While !eof()
		If SubStr(cLinha, Val(INICIAL->GG1_COLINI), Val(INICIAL->GG1_TAMCAM)) $ INICIAL->GG3_IDREG
			sRet:=INICIAL->GG3_CODGRU
			exit
		Endif
		dbSkip()
	End
Else
	sRet:=INICIAL->GG3_CODGRU
EndIf

RestArea(aArea)
Return(sRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_ZAPCONDบAutor  ณLuiz Pereira S. Jr. บ Data ณ  04/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_ZAPCOND(cAlias, cCond)

Local cSql  := ""
Local cPref := PrefixoCpo(cAlias)
Local aArea := GetArea()

Default cCond := ""

DbSelectArea(cAlias)

cSql := "SELECT " + cPref + "_FILIAL, R_E_C_N_O_ "
cSql += "FROM " + RetSqlName(cAlias) + " "
cSql += "WHERE " + cPref + "_FILIAL = '" + xFilial(cAlias) + "' AND D_E_L_E_T_ <> '*' "
If !Empty(cCond)
	cSql += "AND " + cCond
EndIf

cSql := ChangeQuery(cSql)

TCQUERY cSql New Alias "TMP"

DbSelectArea("TMP")

While !(TMP->(Eof()))
	DbSelectArea(cAlias)
	DbGoto(TMP->R_E_C_N_O_)
	RecLock(cAlias, .F.)
	DbDelete()
	MsUnlock()
	//  WriteSX2(cAlias)
	TMP->(DbSkip())
End

TMP->(DbCloseArea())
RestArea(aArea)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณAjustaSX1 ณ Autor ณSa๚de                  ณ Data ณ27/07/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณAjuste no grupo de perguntas                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณNenhum                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function AjustaSx1()
Local aArea := GetArea()
Local cPerg	:= ""

dbSelectArea("SX1")
dbSetOrder(1)    

cPerg := PADR("TISXML", Len(SX1->X1_GRUPO))
If SX1->(DbSeek(cPerg + "01"))
		If !(X1_TAMANHO == FWSizeFilial())
			RecLock("SX1",.F.)
				Replace SX1->X1_TAMANHO With FWSizeFilial()
			MsUnlock()	
		Endif
Endif

RestArea(aArea)
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPIDDOCPRบ Autor ณLeonardo Candido    บ Data ณ  08/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o item 001 do leiaute DETALHE FILHO AIH,           บฑฑ
ฑฑบ          ณ que corresponde a dfil-idprof                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPHM52                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPIDDOCPR(cTdeAih, cCicProf, cCnsProf)    

Local cTexto := ""

If !EMPTY(cTdeAih) .AND. cTdeAih = "1"
    If !EMPTY(cCicProf)
    	cTexto := "1"
    EndIf
ElseIf !EMPTY(cTdeAih) .AND. cTdeAih = "2"
    If !EMPTY(cCnsProf)  
        cTexto := "2"
    EndIf     
Else
    cTexto := "0"
EndIf   				          

Return(cTexto)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPDOCPROFบ Autor ณLeonardo Candido    บ Data ณ  08/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o item 002 do leiaute DETALHE FILHO AIH,           บฑฑ
ฑฑบ          ณ que corresponde a dfil-docprof                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPHM52                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPDOCPROF( cCodDes,cTdeAih,cCicProf, cCnsProf )    

Local cTexto := ""

Default cCodDes 	 := ""
Default cTdeAih 	 := ""
Default cCicProf 	 := ""
Default cCnsProf 	 := ""

/*cTexto := 	IIF(SUBSTR(cCodDes,1,4) == "0202" .OR. SUBSTR(cCodDes,1,4) == "0702".OR. SUBSTR(cCodDes,1,6) == "080201","",;
			 	IIF(!EMPTY(cTdeAih) .AND. cTdeAih = "1",;
				IIF(!EMPTY(cCicProf),cCicProf,;
				IIF(!EMPTY(cTdeAih) .AND. cTdeAih = "2",;
				IIF(!EMPTY(cCnsProf),cCnsProf,"")))))      */

If SUBSTR( cCodDes,1,4 ) == "0202" .OR. SUBSTR( cCodDes,1,4 ) == "0702".OR. SUBSTR( cCodDes,1,6 ) == "080201"
    cTexto := ""
ElseIf !EMPTY( cTdeAih ) .AND. cTdeAih = "1"
    If !EMPTY( cCicProf )  
        cTexto := cCicProf 
    EndIf
ElseIf !EMPTY(cTdeAih) .AND. cTdeAih = "2"
        If !EMPTY( cCnsProf )
            cTexto := cCnsProf
        EndIf   
EndIf   				          

Return( cTexto )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPIDEXEC บ Autor ณLeonardo Candido    บ Data ณ  08/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o item 007 do leiaute DETALHE FILHO AIH,           บฑฑ
ฑฑบ          ณ que corresponde a dfil-idexec                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPHM52                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPIDEXEC( cCnpj, cTdeAih, cCnes )    

Local cTexto := ""

Default cCnpj 	 := ""
Default cTdeAih := ""
Default cCnes	 := ""

/*cTexto := IIF(!EMPTY(HSPEDI->GD7_CNPJFO),3,IIF(!EMPTY(HSPEDI->TDEAIH),HSPEDI->TDEAIH,IIF(!EMPTY(__CCNES),5,0)))  */

If !EMPTY( cCnpj ) 
    	cTexto := "3"
ElseIf !EMPTY( cTdeAih ) 
    	cTexto := cTdeAih
ElseIf !EMPTY( cCnes )  
       cTexto := "5"
Else
    cTexto := "0"
EndIf   				          

Return( cTexto )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPDOCEXECบ Autor ณLeonardo Candido    บ Data ณ  08/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o item 008 do leiaute DETALHE FILHO AIH,           บฑฑ
ฑฑบ          ณ que corresponde a dfil-docexec                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPHM52                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPDOCEXEC( cCnpj, cTdeAih, cDesAih, cCnes )    

Local cTexto := ""

Default cCnpj 	 := ""
Default cTdeAih := ""
Default cDesAih := ""
Default cCnes	 := ""

/*cTexto := IIF(!EMPTY(HSPEDI->GD7_CNPJFO),HSPEDI->GD7_CNPJFO,IIF(!EMPTY(HSPEDI->TDEAIH),HSPEDI->DDEAIH,IIF(!EMPTY(__CCNES),__CCNES,"")))  */

If !EMPTY( cCnpj ) 
    cTexto := cCnpj
ElseIf !EMPTY( cTdeAih ) 
    cTexto := cDesAih 
ElseIf !EMPTY( cCnes ) 
    cTexto := cCnes
Else
    cTexto := ""
EndIf   				          

Return( cTexto )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPVldTel บ Autor ณVictor Ferreira     บ Data ณ  27/12/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna os itens DDD e Tel do paciente do layout AIH       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HSPHM52                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPVldTel(cTel,lType)
Local cAux := ""
Local cRet := ""

cTel:= StrTran(cTel,"(")
cTel:= StrTran(cTel,")")
cTel:= StrTran(cTel,"-")

cAux:= SubStr(cTel,1,1)
If cAux == "0"
	cTel:= SubStr(cTel,2,Len(cTel)-1)
Endif

If lType
	cRet := SubStr(cTel,1,2)
Else
	cRet := SubStr(cTel,3,Len(cTel)-2)
Endif

Return (cRet)