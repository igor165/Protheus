#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "MSOLE.CH" 
#INCLUDE "GCPXFUN.CH" 
#INCLUDE "PARMTYPE.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWEVENTVIEWCONSTS.CH" 

Static cRetNE   := ""

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ GCRUSRF3     ∫Autor  ≥ Totvs          ∫ Data ≥  01/04/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao para montar consulta F3 customizada de usuarios do  ∫±±
±±∫          ≥ sistema. Usado no SXB customizado _CO5                     ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Function GCPUSRF3()

Local oDlg, oPswBrw, oPswCbx, oPswGet, oBtn1, oBtn2
Local aPswBrw := {}, cPswGet := Space(6), cPswOrd, aPswOrd := {STR0001,STR0002}//"CÛdigo"##"Nome"
Local aHeaders, aColsizes, bLine, aData, cCaption, nAt := 1
Local cCodigo, lExport := .F., nPos := 0
Local aWndPos := {}
Local nTop
Local nLeft
Local nBottom
Local nRight
Local lCenter
Local oTopPanel
Local oMainPanel
Local oBtnPanel1
Local oBtnPanel2
Local lBrwPos := .T.

Local cVarRet := ReadVar()

cCaption := STR0003 //"Usu·rio"
aData := AllUsers()
aEval(aData,{|cVal,nInd| Aadd(aPswBrw,{aData[nInd][1][1],aData[nInd][1][2],If(aData[nInd][1][1] <> "000000",aData[nInd][1][4],""),aData[nInd][1][14]})})
aHeaders := {STR0001, STR0002, STR0004}//"Nome Completo"##"CÛdigo"##"Nome"
aColSizes := {50,100,100}
bLine := {|| {aPswBrw[oPswBrw:nAt][1],;
	OemToAnsi(aPswBrw[oPswBrw:nAt][2]),;
	OemToAnsi(aPswBrw[oPswBrw:nAt][3])}}

nTop := 0
nLeft := 0
nBottom := 390
nRight := 515
lCenter := .T.

DEFINE MSDIALOG oDlg FROM nTop,nLeft TO nBottom,nRight TITLE STR0005 + OemToAnsi(cCaption) PIXEL OF oMainWnd //"Consulta Padr„o - "  

oDlg:SetMinimumSize(515,390)

@00,00 MSPANEL oTopPanel SIZE 250,43
oTopPanel:Align := CONTROL_ALIGN_TOP

@00,00 MSPANEL oMainPanel SIZE 250,39
oMainPanel:Align := CONTROL_ALIGN_ALLCLIENT

@00,00 MSPANEL oBtnPanel1 SIZE 250,15
oBtnPanel1:Align := CONTROL_ALIGN_BOTTOM

@03,03 COMBOBOX oPswCbx VAR cPswOrd ITEMS aPswOrd SIZE 210,36 OF oDlg PIXEL ;
ON CHANGE (If(oPswCbx:nAt==1,cPswGet:=Space(6),cPswGet:=Space(15)),;
aPswBrw := ASort(aPswBrw,,,{|x,y| x[oPswCbx:nAt]<y[oPswCbx:nAt]}),oPswBrw:Refresh(),oPswGet:cText(cPswGet),;
FastSeek(@aPswBrw,cCodigo,1,@oPswBrw))

@17,03 MSGET oPswGet VAR cPswGet SIZE 210,10 OF oDlg PIXEL
oPswGet:bLostFocus := {|| FastSeek(@aPswBrw,@cPswGet,oPswCbx:nAt,@oPswBrw)}

@03,215 BUTTON STR0006 SIZE 40,11 PIXEL OF oTopPanel ; //"Pesquisar" 	
ACTION FastSeek(@aPswBrw,@cPswGet,oPswCbx:nAt,@oPswBrw)

@31,03 CHECKBOX lBrwPos PROMPT STR0007  SIZE 210,10 PIXEL OF oTopPanel FONT oTopPanel:oFont	//"Posicionar no browse na abertura"

oPswBrw := TwBrowse():New(10,12,nRight,nBottom,,aHeaders,aColSizes,oMainPanel, , , ,{|| cCodigo := aPswBrw[oPswBrw:nAt][1]},{|| nAt := oPswBrw:nAt,lExport := .T., oDlg:End()}, , , , , , , , ,.T.)
oPswBrw:Align := CONTROL_ALIGN_ALLCLIENT
oPswBrw:SetArray(aPswBrw)
oPswBrw:bLine := bLine

@00,00 MSPANEL oBtnPanel2 SIZE 250,15 OF oBtnPanel1
oBtnPanel2:Align := CONTROL_ALIGN_ALLCLIENT

DEFINE SBUTTON oBtn1 FROM 02,02 TYPE 1 ENABLE OF oBtnPanel2 ACTION (nAt := oPswBrw:nAt,lExport := .T., oDlg:End())
oBtn1:lAutDisable := .f.

DEFINE SBUTTON oBtn2 FROM 02,32 TYPE 2 ENABLE OF oBtnPanel2 ACTION oDlg:End()

If lBrwPos
	oPswBrw:SetFocus()
Else
	oPswGet:SetFocus()
EndIf

oDlg:Activate(,,,lCenter,{|| .T.},,;
{|| oDlg:ReadClientCoors(.T.),oDlg:Cargo := {oDlg:nWidth,oDlg:nHeight},SetKey(15,oBtn1:bAction),;
SetKey(24,oBtn2:bAction),oDlg:bSet15 := oBtn1:bAction,oDlg:bSet24 := oBtn2:bAction},,)
            
If ( lExport )                             
	&(cVarRet) := aPswBrw[nAt][1]
EndIf

Return lExport


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ GCRUSRF3     ∫Autor  ≥ Totvs              ∫ Data ≥  01/04/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Funcao de busca de usuario da funcao GCRUSRF3()            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Static Function FastSeek(aBrw,cGet,nAt,oBrw)

Local nPos := 0

If (nPos := Ascan(aBrw,{|x| SubStr(x[nAt],1,Len(Trim(cGet)))==Trim(cGet)})) <> 0
	If ( oBrw:nAt <> nPos )
		oBrw:Skip(nPos - oBrw:nAt)
		oBrw:Refresh()
	EndIf
EndIf
Return NIL

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ GeraArq  ∫Autor  ≥ Totvs              ∫ Data ≥  01/04/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Gera arquivo Word                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function GCPGeraArq(cArquivo,cArqDest,aCampos)
Local cNewCodEdt := RemoveEsp(StrTran(StrTran(cCodEdt,'\','_'),'/','_'))
Local cArqDot := cArquivo+".DOT"     // Nome do Arquivo MODELO do Word
Local cPathDot:= AllTrim(GETMV("MV_GCPDOT",,"\samples\documents\gcp\dot\")) // PATH DO ARQUIVO MODELO WORD
//NO SERVIDOR ; CONFIGURAR PATH ABAIXO DO ROOTPATH PROTHEUS E INFORMAR NO PARAMETRO
Local cPathDoc:= AllTrim(GETMV("MV_GCPDOC",,"\samples\documents\gcp\doc\")) + AllTrim(cNewCodEdt)+"\" // PATH PARA GRAVACAO DOS ARQUIVO WORD GERADOS
Local nCount
Private oWord := OLE_CreateLink()
Private nCntLin := 0 ; nCntCol := 0
Private cPathEst:= Alltrim(SuperGetMV("MV_GCPDEST",.F.,"C:\WORDTMP\")) + AllTrim(cNewCodEdt)+"\" // PATH DO ARQUIVO A SER ARMAZENADO NA

cArqDest := RemoveEsp(StrTran(StrTran(cArqDest,'\','_'),'/','_'))

If Empty(cArquivo)
	Return("")
Endif

MontaDir(cPathEst)

If !File(cPathDot + cArqDot) // Verifica a existencia do DOT no ROOTPATH Protheus / Servidor 
	cMsg := STR0008 + cPathDot + cArqDot + STR0009 //" nao encontrado no Servidor" 
	Help("",1,"GCPARQ","",cMsg,1,0)
	Return("")
EndIf

// Caso encontre arquivo ja gerado na estacao
//com o mesmo nome apaga primeiramente antes de gerar a nova impressao
If File( cPathEst + cArqDot )
	Ferase( cPathEst + cArqDot )
EndIf

CopiaArq(cPathDot,cPathEst,cArqDot)
//CpyS2T(cPathDot,cPathEst,.T.) // Copia do Server para o Remote, eh necessario
//para que o wordview e o proprio word possam preparar o arquivo para impressao e
// ou visualizacao .... copia o DOT que esta no ROOTPATH Protheus para o PATH da
// estacao , por exemplo C:\WORDTMP

//Cria novo arquivo no Word na estacao
OLE_NewFile( oWord, cPathEst + cArqDot)

//Salva o arquivo com o novo nome na estacao
OLE_SaveAsFile( oWord, cPathEst + cArqDest+".DOT", , , .F., oleWdFormatDocument )

// Preenche Variaveis do .DOT
// Verificar nomes de variaveis no .DOT via Word ... atraves da tecla ALT+F9
For nCount:=1 To Len(aCampos)
	OLE_SetDocumentVar(oWord, aCampos[nCount,1], aCampos[nCount,2])
Next

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Executa macro do Word                                                 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//OLE_ExecuteMacro(oWord,cArqDest)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Atualizando as variaveis do documento do Word                         ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

OLE_UpdateFields(oWord)
OLE_SaveAsFile( oWord, cPathEst + cArqDest+".DOC", , , .F., oleWdFormatDocument )

// Alterado o MsgYesNo para Aviso, retirando a pergunta Sim ou Nao
While .T.
	Aviso(STR0023,STR0010,{STR0024})// "Emiss„o de Termo" / "Deseja fechar o documento ?" / Sim 
		OLE_CloseFile(oWord)	
		OLE_CloseLink(oWord)
		Exit
EndDo

If File(cPathEst + cArqDest+".DOT")
	FErase(cPathEst + cArqDest+".DOT")
EndIf

//Caso nao exista, cria o diretorio no servidor
MontaDir(cPathDoc)

// Caso encontre arquivo ja gerado no Servidor
//com o mesmo nome apaga primeiramente antes de gerar a nova impressao
If File( cPathDoc + cArqDest+".DOC" )
	Ferase( cPathDoc + cArqDest+".DOC" )
EndIf

//COPIA O ARQUIVO GERADO NO SERVIDOR
CopiaArq(cPathEst,cPathDoc,cArqDest+".DOC")

Return(cPathDot+cArqDest+".DOC")


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ CopiaArq ∫Autor  ≥ Totvs              ∫ Data ≥  01/04/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Realiza a copia de arquivo do servidor para o remote       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function CopiaArq(cAtuDir,cNomeDir,cArquivo)

cNomeDir := Alltrim(cNomeDir)
	__COPYFILE(cAtuDir+cArquivo,cNomeDir+cArquivo)

Return .T.


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ GCPRetMes   ∫Autor  ≥ Totvs              ∫ Data ≥  01/04/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Retorna descricao do mes                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Function GCPRetMes(nMes)

Local cMes   := ""
Local aMeses := {}

AAdd(aMeses,STR0011)//"janeiro"
AAdd(aMeses,STR0012)//"fevereiro"
AAdd(aMeses,STR0013)//"marÁo"
AAdd(aMeses,STR0014 )//"abril"
AAdd(aMeses,STR0015)//"maio"
AAdd(aMeses,STR0016)//"junho"
AAdd(aMeses,STR0017 )//"julho"
AAdd(aMeses,STR0018 )//"agosto"
AAdd(aMeses,STR0019 )//"setembro"
AAdd(aMeses,STR0020 )//"outubro"
AAdd(aMeses,STR0021 )//"novembro"
AAdd(aMeses,STR0022 )//"dezembro"

cMes := aMeses[nMes]

Return(cMes)


                                                                        
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GCPValDesc∫Autor  ≥    Eduardo Dias    ∫ Data ≥  16/10/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Verifica se existe descriÁ„o na tabela SB5, caso exista, o ∫±±
±±∫          ≥ campo CO2_DESC dever· considerar o B5_DESC, caso nao tenha ∫±±
±±∫          ≥ devera considera o campo B1_DESC                           ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GCPA002                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function GCPValDesc(cCodPro)	
	Local cDescPro := ""

	SB5->(dbSetOrder(1)) //B5_FILIAL+B5_COD
	If SB5->( dbSeek(xFilial("SB5")+cCodPro) )
		cDescPro := SB5->B5_CEME	
	Else                                                                    
		cDescPro := POSICIONE( "SB1", 1, XFILIAL( "SB1" ) + cCodPro, "B1_DESC" )   
	EndIf
Return(cDescPro)

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCOPF3()
FunÁ„o para definir o F3 do Codigo do fornecedor ou do participante,
dependendo do tipo selecionado na Rotina GCPA100 - Analise de Mercado ;
- 1 = PrÈ-Fornecedor / Participante
- 2 = Fornecedor
Usado no SXB Customizado _CPO

@author alexandre.gimenez
@return lRet LÛgico para identificar se a consulta foi bem sucedida.
@since 17/07/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCPCOPF3()
Local oModel 	:= FWModelActive()
Local lRet    	:= .T.
Local cTipo	:= oModel:GetModel('COP_DETAIL'):GetValue('COP_TIPO')
Local cGerDoc	:= oModel:GetModel('CO1MASTER'):GetValue('CO1_GERDOC')

If cTipo == "1"
	lRet := ConPad1(,,,"CO6")  // pre-licitantes de compras e vendas 
Else           
	If cGerDoc == "2" // Vendas
		lRet := ConPad1(,,,"SA1") // Clientes
	Else
		lRet := ConPad1(,,,"SA2") // Fornecedores
	EndIf
Endif	
                       
If lRet
	If cTipo == "1"
		oModel:GetModel('COP_DETAIL'):SetValue('COP_CODFOR', CO6->CO6_CODIGO )
		oModel:GetModel('COP_DETAIL'):SetValue('COP_LOJFOR', CO6->CO6_LOJFOR )
	Else
		If cGerDoc == "2" // Vendas
			oModel:GetModel('COP_DETAIL'):SetValue('COP_CODFOR', SA1->A1_COD )
			oModel:GetModel('COP_DETAIL'):SetValue('COP_LOJFOR', SA1->A1_LOJA )	
		Else
			oModel:GetModel('COP_DETAIL'):SetValue('COP_CODFOR', SA2->A2_COD )
			oModel:GetModel('COP_DETAIL'):SetValue('COP_LOJFOR', SA2->A2_LOJA )	
		EndIf	
	Endif	
Endif	

Return lRet 



//-------------------------------------------------------------------
/*{Protheus.doc} GCPLCTF3()
FunÁ„o para definir o F3 do Codigo do fornecedor ou do participante,
dependendo do tipo selecionado na Rotina GCPA100 - Analise de Mercado ;
- 1 = PrÈ-Fornecedor / Participante
- 2 = Fornecedor
Usado no SXB Customizado _COP

@author alex.egydio
@return lRet LÛgico para identificar se a consulta foi bem sucedida.
@since 17/07/2013
@version P11
*/
//-------------------------------------------------------------------

Function GCPLCTF3(cIdModel,cCampo)
Local oModel 	:= FWModelActive()
Local lRet    := .T.
Local cTipo	:= oModel:GetModel(cIdModel):GetValue(cCampo)
Local cGerDoc	:= IIF(cIdModel # "COP_DETAIL",oModel:GetModel('CO1MASTER'):GetValue('CO1_GERDOC'),"1")

If cIdModel # "COP_DETAIL"
	oModel:GetModel('CO1MASTER'):GetValue('CO1_GERDOC')
EndIf
If cTipo == "1"
	If cGerDoc == "2" // Vendas
		lRet := ConPad1(,,,"CO6C")  // pre-licitantes de vendas
	Else
		lRet := ConPad1(,,,"CO6")  // pre-licitantes de compras
	EndIf
Else           
	If cGerDoc == "2" // Vendas
		lRet := ConPad1(,,,"SA1CLI") // Clientes
	Else
		lRet := ConPad1(,,,"SA2") // Fornecedores
	EndIf
Endif	

VAR_IXB := {}                       
If lRet
	If cTipo == "1"
		aadd(VAR_IXB, CO6->CO6_CODIGO )
		aadd(VAR_IXB, CO6->CO6_LOJFOR )
		aadd(VAR_IXB, CO6->CO6_NOME )
	Else
		If cGerDoc == "2" // Vendas
			aadd(VAR_IXB, SA1->A1_COD )
			aadd(VAR_IXB, SA1->A1_LOJA )
			aadd(VAR_IXB, SA1->A1_NOME)
		Else
			aadd(VAR_IXB, SA2->A2_COD )
			aadd(VAR_IXB, SA2->A2_LOJA )
			aadd(VAR_IXB, SA2->A2_NOME)
		Endif
	Endif	
Endif	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPPREVENC()
FunÁ„o para GravaÁ„o do prÈ-fornecedor como fornecedor 


@author alexandre.gimenez
@return lRet LÛgico.
@since 09/09/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCPPREVENC()
Local lRet    		:= .T.
local cAliasSql	:= GetNextAlias()
Local cEdital		:= CO1->CO1_CODEDT
Local cNProc		:= CO1->CO1_NUMPRO
Local cRevisa		:= CO1->CO1_REVISA
Local cCodPre		:= ''
Local cCodFor		:= ''
Local cCodLoj		:= ''
Local cTipo		:= ''
Local cTab			:= ''
Local aDados		:= {}
Local cOrdem		:= "% CO3.CO3_CODIGO %" 

Local cMsgFor		:= ''
Local cMsgPro		:= ''
Local cMsgCod		:= ''

BeginSQL Alias cAliasSql
			
	SELECT 
		CO3.R_E_C_N_O_  AS RecCO3,
		CO6.R_E_C_N_O_  AS RecCO6
	FROM 
		%table:CO3% CO3
	INNER JOIN %table:CO6% CO6
		ON CO3.CO3_CODIGO = CO6.CO6_CODIGO
	  	AND CO3.CO3_LOJA = CO6.CO6_LOJFOR
	WHERE 
			CO3.CO3_FILIAL = %xfilial:CO3%
		AND CO3.CO3_CODEDT = %exp:cEdital%
		AND CO3.CO3_NUMPRO = %exp:cNProc%
		AND CO3.CO3_REVISA = %exp:cRevisa%
		AND CO3.CO3_TIPO	 = '1'
		AND CO3.CO3_STATUS  = '5'
		AND CO3.%NotDel%
	ORDER BY %exp:cOrdem%					
EndSql

While !(cAliasSql)->(eof())
	CO3->(dbGoto((cAliasSql)->RecCO3))
	CO6->(dbGoto((cAliasSql)->RecCO6))
	cCodFor := CO6->CO6_FORNEC  // VALIDA SE NOVO PRE FORNECEDOR	
	cCodLoj := CO6->CO6_LOJFOR 
	cCodPre := CO3->CO3_CODIGO
	cTipo	 := CO6->CO6_TIPO
	cTab	 := IIF(cTipo == "F", "SA2", "SA1" )
	cMsgFor := IIF(cTipo == "F", STR0025 , STR0026 )//Fornecedor # Cliente
	cMsgPro := IIF(CO1->CO1_AVAL == '1', STR0027 , STR0028) // 'Produto' # 'Lote'
	cMsgCod := IIF(CO1->CO1_AVAL == '1', CO3->CO3_CODPRO, CO3->CO3_LOTE)
	
	If !((cTab)->(dbSeek(xFilial(cTab)+cCodFor+cCodLoj)))
		//--------------------------------------------------------//
		// Estruturas de Arrays abaixo devem ser mantidas apenas //
		// ate a convers„o das rotinas de cadastros de clientes  //
		// e fornecedores em MVC, apÛs esta rotina deve ser     //
		// atualizada para execView									//
		//-----------------------------------------------------//
		If MsgYesNo(STR0029 + cMsgFor +' '+ AllTrim(cCodPre) + STR0030 + cMsgPro +' '+AllTrim(cMsgCod) + STR0031 + cMsgFor + STR0032 , STR0033 )// 'O PrÈ-'#' ganhador do '#' deve ser cadastrado como '#'. Deseja Cadastra-lo?'#'Aviso' 		
			If cTipo == 'F'
				aDados := {	{"A2_COD",cCodPre},				{"A2_LOJA",cCodLoj},;
								{"A2_TIPO","J"},					{"A2_CGC",CO6->CO6_CNPJ},;
								{"A2_NOME",CO6->CO6_NOME},		{"A2_TEL",CO6->CO6_TEL},;
								{"A2_CONTATO",CO6->CO6_CONTAT}, {"A2_END",CO6->CO6_END},;
								{"A2_BAIRRO",CO6->CO6_BAIRRO},	{"A2_MUN",CO6->CO6_MUN},;
								{"A2_EST",CO6->CO6_UF},			{"A2_CEP",CO6->CO6_CEP},;
								{"A2_EMAIL",CO6->CO6_EMAIL},	{"A2_INSCR",CO6->CO6_INSCR}	}				
				lRet := GCPCadForn(aDados)
			Else
				aDados := {	{"A1_COD",cCodPre},				{"A1_LOJA",cCodLoj},;
								{"A1_PESSOA","J"},				{"A1_CGC",CO6->CO6_CNPJ},;
								{"A1_NOME",CO6->CO6_NOME},		{"A1_TEL",CO6->CO6_TEL},;
								{"A1_CONTATO",CO6->CO6_CONTAT}, {"A1_END",CO6->CO6_END},;
								{"A1_BAIRRO",CO6->CO6_BAIRRO},	{"A1_MUN",CO6->CO6_MUN},;
								{"A1_ESTADO",CO6->CO6_UF},		{"A1_CEP",CO6->CO6_CEP},;
								{"A1_EMAIL",CO6->CO6_EMAIL},	{"A1_INSCR",CO6->CO6_INSCR},;
								{"A1_TIPO","F"}	}
				lRet := (A030WebbIc(aDados)) == 1
			EndIf
			If lRet
				RecLock("CO6",.F.)
				CO6->CO6_FORNEC := (cTab)->&(Substr(cTab,2,2)+"_COD")
				CO6->CO6_LOJA 	:= (ctab)->&(Substr(cTab,2,2)+"_LOJA")
				CO6->(MsUnLock())
			Else
				lRet := .F.
				Exit
			EndIf
		Else
			lRet := .F.
			Exit
		EndIf		
	EndIf
	
	If lRet
		RecLock("CO3",.F.)
		CO3->CO3_CODIGO := CO6->CO6_FORNEC
		CO3->CO3_LOJA   := CO6->CO6_LOJFOR 
		CO3->CO3_TIPO   := "2"
		CO3->(MsUnLock())
	Else
		Exit
	EndIf
			
	(cAliasSql)->(DBSkip())	
End

(cAliasSql)->(DbCloseArea())

Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} GCPWinner()
FunÁ„o para definiÁ„o do vencedor 
GravaÁ„o do prÈ-fornecedor como fornecedor
GravaÁ„o do fornecedor vencedor do lote. 

@author alexandre.gimenez
@return lRet LÛgico.
@since 09/09/2013
@version P11
/*/
//-------------------------------------------------------------------
Function GCPWinner(oModel)
Local aAreas  		:= {CO6->(GetArea()), SA2->(GetArea()), SA1->(GetArea()), GetArea()}
Local lRet    		:= .T.
Local lUsaLote		:= oModel:GetId() == 'GCPA201'
Local lGCPXPREL		:= ExistBlock("GCPXPREL")
Local lWinner		:= .F.
Local lFracass		:= .T.
Local oModEdt		:= oModel:GetModel("CO1MASTER")
Local oModLic		:= oModel:GetModel("CO3DETAIL")
local oModLote		:= IIF(lUsaLote,oModel:GetModel("CP6DETAIL"),Nil)
Local oModProd		:= IIF(lUsaLote,oModel:GetModel("CP3DETAIL"),oModel:GetModel("CO2DETAIL"))
Local aSaveLines	:= FWSaveRows()
Local aGCPXPREL		:= {}
Local nX			:= 0
Local nY			:= 0
Local nL			:= 0
Local cMsgFor		:= ''
Local cMsgPro		:= ''
Local cMsgCod		:= ''
Local cCodPre		:= ''
Local cCodLoj		:= ''
Local cCodFor		:= ''
Local cAutom		:= oModEdt:GetValue("CO1_AUTO")
Local aDados		:= {}
Local lYesOrNo		:= .F.
Private cCadastro := ''
Private lMsErroAuto := .F. 

For nX := 1 To oModProd:length()
	oModProd:GoLine(nX)
	For nY := 1 To oModLic:length()
		oModLic:GoLine(nY)
		
		cMsgPro := IIF(lUsaLote, STR0028, STR0027  ) //'Lote' #  'Produto' 
		cMsgCod := IIF(lUsaLote, oModProd:GetValue("CP3_LOTE"), oModProd:GetValue("CO2_CODPRO"))
		
		If oModLic:GetValue("CO3_STATUS") == "5"
		 	
		 	lWinner := .T.
		 	cCodPre := oModLic:GetValue("CO3_CODIGO")
			cCodLoj := oModLic:GetValue("CO3_LOJA")
			cTipo	 	:= IIF(oModEdt:GetValue("CO1_GERDOC") == "2","C","F") 
			cTab	 	:= IIF(cTipo == "F", "SA2", "SA1" )			
			cMsgFor 	:= IIF(cTipo == "F", STR0025 , STR0026 )//Fornecedor # Cliente
			cCadastro 	:= IIF(cTipo == "F",STR0082,STR0083)//Cadastro de ? para o Processo LicitatÛrio
			
			If oModLic:GetValue("CO3_TIPO") == '1' .And. CO6->(dbSeek(xFilial("CO6")+cCodPre+cCodLoj))
			
				cCodFor := CO6->CO6_FORNEC // VALIDA SE NOVO PRE FORNECEDOR				
				If Empty(cCodFor) .Or. !((cTab)->(dbSeek(xFilial(cTab)+cCodFor+cCodLoj)))
					//--------------------------------------------------------//
					// Estruturas de Arrays abaixo devem ser mantidas apenas //
					// ate a convers„o das rotinas de cadastros de clientes  //
					// e fornecedores em MVC, apÛs esta rotina deve ser     //
					// atualizada para execView								//
					//-----------------------------------------------------//

					
					If cTipo == 'F'	
						aDados := {	{"A2_COD"		,cCodPre},;				
									{"A2_LOJA"		,cCodLoj},;
									{"A2_TIPO"		,"J"},;
									{"A2_CGC"		,CO6->CO6_CNPJ},;
									{"A2_NOME"		,CO6->CO6_NOME},;
									{"A2_NREDUZ"	,Left(CO6->CO6_NOME, GetSx3Cache('A2_NREDUZ','X3_TAMANHO'))},;
									{"A2_TEL"		,StrTran(CO6->CO6_TEL, '-')},;
									{"A2_CONTATO"	,CO6->CO6_CONTAT},;
									{"A2_END"		,CO6->CO6_END},;
									{"A2_BAIRRO"	,CO6->CO6_BAIRRO},;
									{"A2_MUN"		,CO6->CO6_MUN},;
									{"A2_EST"		,CO6->CO6_UF},;
									{"A2_CEP"		,CO6->CO6_CEP},;
									{"A2_EMAIL"		,CO6->CO6_EMAIL},;
									{"A2_INSCR"		,CO6->CO6_INSCR}}
					EndIf
					
					If cAutom == '0'						
						If (lRet := MsgYesNo(STR0029 + cMsgFor +' '+ AllTrim(cCodPre) + STR0030 + cMsgPro +' '+AllTrim(cMsgCod) + STR0031 + cMsgFor + STR0032 , STR0033 ))// 'O PrÈ-'#' ganhador do '#' deve ser cadastrado como '#'. Str0032 - Deseja Cadastra-lo?'#'Aviso'
							If cTipo == 'F'								
								//Ponto de entrada para manipulaÁ„o dos dados do fornecedor/cliente
								If lGCPXPREL
									aGCPXPREL := ExecBlock("GCPXPREL",.F.,.F.,{ aDados , cTipo }) 
									
									If ValType(aGCPXPREL) == "A"
										aDados := aGCPXPREL
									EndIf
								EndIf					
								
								lRet := GCPCadForn(aDados)
							Else								
								aDados := {	{"A1_COD",cCodPre},				{"A1_LOJA",cCodLoj},;
												{"A1_PESSOA","J"},				{"A1_CGC",CO6->CO6_CNPJ},;
												{"A1_NOME",CO6->CO6_NOME},		{"A1_TEL",CO6->CO6_TEL},;
												{"A1_CONTATO",CO6->CO6_CONTAT},{"A1_END",CO6->CO6_END},;
												{"A1_BAIRRO",CO6->CO6_BAIRRO},	{"A1_MUN",CO6->CO6_MUN},;
												{"A1_ESTADO",CO6->CO6_UF},		{"A1_CEP",CO6->CO6_CEP},;
												{"A1_EMAIL",CO6->CO6_EMAIL},	{"A1_INSCR",CO6->CO6_INSCR},;
												{"A1_TIPO","F"}	}
											
								//Ponto de entrada para manipulaÁ„o dos dados do fornecedor/cliente
								If lGCPXPREL
									aGCPXPREL := ExecBlock("GCPXPREL",.F.,.F.,{ aDados , cTipo }) 
									
									If ValType(aGCPXPREL) == "A"
										aDados := aGCPXPREL
									EndIf
								EndIf
												
								lRet := (A030WebbIc(aDados)) == 1
							EndIf
						EndIf
					ElseIf cAutom == '1'
						If cTipo == 'F'
							MSExecAuto({|v,x| MATA020(v,x)},aDados,3)
						Else							
							AAdd(aDados,{"A1_COD",cCodPre,Nil})
							AAdd(aDados,{"A1_PESSOA","J",Nil})
							AAdd(aDados,{"A1_NOME",CO6->CO6_NOME,Nil})
							AAdd(aDados,{"A1_CONTATO",CO6->CO6_CONTAT,Nil})
							AAdd(aDados,{"A1_BAIRRO",CO6->CO6_BAIRRO,Nil})
							AAdd(aDados,{"A1_EST","SP",Nil})
							AAdd(aDados,{"A1_EMAIL",CO6->CO6_EMAIL,Nil})							
							AAdd(aDados,{"A1_TIPO","F",Nil})
							AAdd(aDados,{"A1_LOJA",cCodLoj,Nil})
							AAdd(aDados,{"A1_CGC",CO6->CO6_CNPJ,Nil})
							AAdd(aDados,{"A1_TEL",CO6->CO6_TEL,Nil})
							AAdd(aDados,{"A1_END","EndGCPWinner",Nil})
							AAdd(aDados,{"A1_MUN","MunGCPWinner",Nil})
							AAdd(aDados,{"A1_CEP",CO6->CO6_CEP,Nil})
							AAdd(aDados,{"A1_INSCR",CO6->CO6_INSCR,Nil})
							AAdd(aDados,{"A1_NREDUZ",CO6->CO6_NOME,Nil})							
							MSExecAuto({|v,x| MATA030(v,x)},aDados,3)
						EndIf
						If lMsErroAuto
							DisarmTransaction()
							lMsErroAuto := .F.
							lRet := .F.
						EndIf			
					EndIf
					If lRet
						RecLock("CO6",.F.)
						CO6->CO6_FORNEC := (cTab)->&(Substr(cTab,2,2)+"_COD")
						CO6->CO6_LOJA := (ctab)->&(Substr(cTab,2,2)+"_LOJA")
						CO6->(MsUnLock())
					EndIf
				EndIf
				If lRet					
					oModLic:SetNoUpdateLine(.F.)
					oModLic:SetValue("CO3_TIPO",'2')
					oModLic:SetValue("CO3_CODIGO",CO6->CO6_FORNEC)
					oModLic:SetValue("CO3_LOJA",CO6->CO6_LOJFOR)
					oModLic:SetNoUpdateLine(.T.)
				EndIf
			EndIf
			Exit
		EndIf
	Next nY
	
	// Define Lote ou item Fracassado
	If lRet
		If lWinner
			lFracass := .F.
			// Grava Fornecedor ao lote do processo licitatÛrio
			If lUsaLote
				For nL := 1 To oModLote:length()
					oModLote:GoLine(nL)
					oModLote:SetNoUpdateLine(.F.)
					oModLote:SetValue("CP6_CODIGO",cCodPre) 
					oModLote:SetValue("CP6_LOJA",cCodLoj)
				Next nL
				lRet := GCP201VlLt(oModel)
			End				
		Else	
			lYesOrNo := IIF(IsBlind(), .T., MsgYesNo("O "+cMsgPro +' '+AllTrim(cMsgCod)+STR0058,STR0033)) // "O" + " n„o possui licitante vencedor, Deseja revoga-lo?" # Aviso
			
			If lYesOrNo
				oModProd:SetNoUpdateLine(.F.)
				If lUsaLote					
					oModProd:SetValue("CP3_STATUS","2")
					For nL := 1 To oModLote:length()//Desfazer Lote do processo licitatÛrio
						oModLote:GoLine(nL)
						oModLote:DeleteLine()
					Next nL				
				Else
					oModProd:SetValue("CO2_STATUS","2")
				EndIf
				oModProd:SetNoUpdateLine(.T.)
			Else
				lRet := .F.
			EndIf			
		EndIf
	EndIf
	lWinner := .F.
	If !lRet
		Help("",1,"GCPWINNER","","Erro na ValidaÁ„o do Vencedor",1,0)
		Exit
	EndIf 
Next nX	

If lRet .And. lFracass
	oModEdt:SetValue("CO1_STATUS","5")	
EndIf

FWRestRows( aSaveLines )
FwFreeArray(aSaveLines)
FwFreeArray(aDados)
aEval(aAreas,{|x|RestArea(x)})
FwFreeArray(aAreas)
Return lRet 

//------------------------------------------------------------------------
/*/{Protheus.doc} GCPGrdOrd
Botoes de movimentacao

@author Flavio Lopes Rasta
@since 10/09/2013
@version P11
/*/
//------------------------------------------------------------------------
Function GCPGrdOrd( oPanel, oView, cIdGrid, cOrdGrid )
Local lOrigEdt:= cIdGrid  == 'CO3DETAIL'
Local lWhen 	:= .T.
Local oModel := FWModelActive() 

If oModel:GetOperation() == MODEL_OPERATION_VIEW
	lWhen := .F.
ElseIf lOrigEdt
	lWhen := !GCPExistW()  
EndIf

@ oPanel:nTop + 15, 5 Button "Acima" Size 37, 10 Message "Move linha para cima" Pixel Action GridMove(.T.,.T.,.F.,.F.,cIdGrid,cOrdGrid) of oPanel When lWhen //"Acima"###"Move linha para cima"
@ oPanel:nTop + 27, 5 Button "Abaixo" Size 37, 10 Message "Move linha para baixo" Pixel Action GridMove(.F.,.T.,.F.,.F.,cIdGrid,cOrdGrid) of oPanel When lWhen //"Abaixo"###"Move linha para baixo"
@ oPanel:nTop + 40, 5 Button "Inicio" Size 37, 10 Message "Move linha para inicio" Pixel Action GridMove(.F.,.T.,.T.,.F.,cIdGrid,cOrdGrid) of oPanel When lWhen //"Inicio"###"Move linha para inicio"
@ oPanel:nTop + 52, 5 Button "Final" Size 37, 10 Message "Move linha para final" Pixel Action GridMove(.F.,.T.,.F.,.T.,cIdGrid,cOrdGrid) of oPanel When lWhen //"Final"###"Move linha para final"
	
Return NIL


//------------------------------------------------------------------------
/*/{Protheus.doc} GridMove
Movimentacao da linha

@author Flavio Lopes Rasta
@since 10/09/2013
@version P11
/*/
//------------------------------------------------------------------------
Function GridMove( lAcima, lRefresh, lIni, lFim, cId, cSeq, nGoTo )
Local nFrom    := 0
Local nLine    := 0
Local nTo      := 0
Local nX       := 0
Local aSaveLines	:= FWSaveRows()
Local oView		:= FwViewActive()
Local oModel		:= FwModelActive()
Local oCO3Detail 	:= oModel:GetModel('CO3DETAIL')
Local n75 			:= 0
Local n25 			:= 0
Local oGrid		:= oModel:GetModel(cId)
Local nLine    	:= oGrid:GetLine()
Local lRet			:= .T.
Local lOrigEdt	:= oModel:GetId() $ 'GCPA200|GCPA201'

Default nGoTo	:= 0

If lOrigEdt
	oCO3Detail := oModel:GetModel('CO3DETAIL')
	n75		:= MtFindMVC(oCO3Detail, {{'CO3_PERCEN',75}})
	n25 	:= MtFindMVC(oCO3Detail, {{'CO3_PERCEN',25}})	
EndIf	

If nGoTo > 0 
	If nLine <> nGoTo
		GridChange( oGrid, nLine, nGoTo, cId, cSeq)
	EndIf			
ElseIf n75 == 0 .Or. n25 == 0  
	If lIni
		If nLine == 1
			Return NIL
		EndIf
	                
		For nX := nLine To 2 Step -1
			GridChange( oGrid, nX, nX-1, cId, cSeq)
		Next
	                
	ElseIf lFim
	                
		If nLine == oGrid:Length()
			Return NIL
		EndIf
	                
		For nX := nLine To oGrid:Length() - 1
			GridChange( oGrid, nX, nX+1, cId, cSeq)
		Next
	                
	Else
		If lAcima
			nFrom := nLine
			nTo   := nLine - 1
		Else
			nFrom := nLine
			nTo   := nLine + 1
		EndIf
	                
		GridChange( oGrid, nFrom, nTo, cId, cSeq)
	                
	EndIf
Else
	Help("",1,'A200PROERC',,'Para definiÁ„o dos vencedores do item preencha o percentual dos vencedores' ,4,1)
	lRet := .F.			
EndIf
	
If lRet .And. lOrigEdt .And. oModel:GetModel("CO1MASTER"):GetValue("CO1_ETAPA") $ "JP|NE"
	A200KeepWn(oGrid)
EndIf
	
FwRestRows(aSaveLines)
oGrid:GoLine(1)
oView:Refresh()

Return NIL

//------------------------------------------------------------------------
/*/{Protheus.doc} GridChange

Troca linha do Grid

@author Flavio Lopes Rasta
@since 10/09/2013
@version P11
/*/
//------------------------------------------------------------------------
Static Function GridChange( oGrid, nFrom, nTo, cId, cSeq )
Local cSeqAux1	:= ""
Local cSeqAux2	:= ""
Local oView		:= FwViewActive()
Local aRows		:= FwSaveRows()


If oGrid:LineShift( nFrom, nTo )
	//aRows		:= FwSaveRows()
	cSeqAux1	:= oGrid:GetValue( cSeq, nTo   )
	cSeqAux2	:= oGrid:GetValue( cSeq, nFrom )
                
	oGrid:GoLine( nTo )
	oGrid:LoadValue( cSeq, cSeqAux2 )
	oGrid:GoLine( nFrom )
	oGrid:LoadValue( cSeq, cSeqAux1 )
	FwRestRows(aRows)
	oView:Refresh(cId)
EndIf

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} GCPSCS(oModel,cModProd, cModSC, cCpoNSC, cCpoISC, cModLote)
Rotina que retorna um array com as SC's Selecionadas 
Obs: Rotina retirada do GCPA100

@author Matheus Lando Raimundo
@param oModel - Modelo de dados
@param cModProd - Modelo de Produtos
@param cModProd - Modelo de SolicitaÁıes de Compra
@param cCpoNSC - Campo Numero da SolicitaÁ„o de Compra
@param cCpoISC - Campo Item da SolicitaÁ„o de Compra
@param cModLote - Modelo de Lote - Opicional
@return aSCs Vetor com as SC's
@since 22/07/2013
@version 1.1
/*/
//-------------------------------------------------------------------
Function GCPSCS(oModel,cModProd, cModSC, cCpoNSC, cCpoISC, cModLote)
Local nI 			:= 0
Local nI2 			:= 0
Local nI3 			:= 0
Local aSCs 			:= {}
Local aSaveLines 	:= FWSaveRows()
Local oModProd 		:= oModel:GetModel(cModProd)
Local oModSC		:= oModel:GetModel(cModSC)
Local oModLote 		:= Iif(ValType(cModLote)=="C",oModel:GetModel(cModLote),Nil)


If ValType(cModLote)=="C" .And. oModLote <> Nil //- Por Lote
	For nI := 1 To oModLote:Length()
			oModLote:GoLine( nI )
		For nI2 := 1 To oModProd:Length()
			oModProd:GoLine( nI2 )
		  	For nI3:= 1 To oModSC:Length()
	    		oModSC:GoLine( nI3 )             
	        	aadd(aSCs, oModSC:GetValue(cCpoNSC)+oModSC:GetValue(cCpoISC))                                                                                 
	    	Next nI3
		Next nI2
	Next nI	
Else //-  Por Item
	For nI := 1 To oModProd:Length()
		oModProd:GoLine( nI )
	  	For nI2:= 1 To oModSC:Length()
    		oModSC:GoLine( nI2 )             
        	aadd(aSCs, oModSC:GetValue(cCpoNSC)+oModSC:GetValue(cCpoISC))                                                                                 
    	Next nI2
	Next nI	
EndIf

FWRestRows(aSaveLines)
      
Return aSCs

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPSelSC
Tela de seleÁ„o de solicitaÁ„o de Compra
Obs: FunÁ„o Removiada GCPA002
@author alexandre.gimenez
@since 08/04/2010
@version 1.1
/*/
//-------------------------------------------------------------------
Function GCPSelSC(cProduto,cEdital,cProcesso,aSolC,lClick,lWndManutEdit,aSCs,aProds,aHeadC1,aFiltrPrd,cCtrCus,cContaC,cItemCC,cCvlv)
Local oDlg		:= Nil
Local cTitulo	:= "SolicitaÁıes de compra" //"SolicitaÁıes de compra"
Local nX		:= 0
Local aVetor		:= {}
Local aTam			:= {}
Local aCmbItens		:= {}
Local aCmbOrdem		:= {}
Local nOpcX			:= 0
Local nCmbOp		:= 1
Local cPesq			:= Space(100)
Local cCombo		:= ""
Local aDados		:= {}
Local nNumSc	:= aScan(aHeadC1,{|x| Trim(x[2])=="C1_NUM"})
Local nItemSc	:= aScan(aHeadC1,{|x| Trim(x[2])=="C1_ITEM"})
Local nProdSc	:= aScan(aHeadC1,{|x| Trim(x[2])=="C1_PRODUTO"})
Local nDescrSc	:= aScan(aHeadC1,{|x| Trim(x[2])=="C1_DESCRI"})
Local aRet 		:= {}
Local cQuery 	:= ""
Local cAliasTmp := GetNextAlias()
Local nY		:= 0
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aFilter		:= {}
Local aRetFil		:= {} 
Local aVetTst       := {}
Local aButtons		:= {}
Local oSizeMrk	:= NIL
Local cFiltro		:= ""
Local cCampC1 	:= ""
Local cWhereAux	:= ""
Local aAreaAux 	:= {}

Private oOk      	:= LoadBitmap( GetResources(), "LBOK" )
Private oNo      	:= LoadBitmap( GetResources(), "LBNO" )
Private oLbx		:= Nil
Private aTitulo := {}

Default lWndManutEdit := .F.
Default cProduto	:= ""
Default cEdital		:= ""
Default cProcesso	:= ""
Default cCtrCus		:= ""
Default cContaC		:= ""
Default cItemCC		:= ""
Default cCvlv		:= ""
Default aSolC		:= {}
Default lClick		:= .T.
Default aSCs		:= {}
Default aProds		:= {}
Default aHeadC1		:= {}
Default aFiltrPrd	:= {}

//Tratativa para considerar campos n„o usados na montagem do array
cCampC1:= "C1_FILENT|C1_FILIAL"

aHeadC1 := CriaHeader(cCampC1,Nil,Nil,"SC1")

nNumSc		:= aScan(aHeadC1,{|x| Trim(x[2])=="C1_NUM"})
nItemSc	:= aScan(aHeadC1,{|x| Trim(x[2])=="C1_ITEM"})
nProdSc	:= aScan(aHeadC1,{|x| Trim(x[2])=="C1_PRODUTO"})
nDescrSc	:= aScan(aHeadC1,{|x| Trim(x[2])=="C1_DESCRI"})
   
If Len(aSolC) <= 0

	If ExistBlock("GCPXSCFIL")
		cFiltro := ExecBlock("GCPXSCFIL",.F.,.F.)
	EndIf
	
	aAreaAux := GetArea()
	DbSelectArea("CX3")
	CX3->(DbSetOrder(1)) //CX3_FILIAL+CX3_NUMATA+CX3_CODPRO+CX3_NUMSC+CX3_ITEMSC
	If FwModeAcces("CX3",3) == "C" .And. CX3->(ColumnPos("CX3_FILSC")) > 0 
		cWhereAux += " AND CX3_FILSC = SC1.C1_FILIAL "
	EndIf
	RestArea(aAreaAux)

	If IsInCallStack("GCPA400") .or. IsInCallStack("GCP400CASC") 
		cQuery := " SELECT * "
		cQuery += " FROM " + RetSqlTab("SC1")
		cQuery += " LEFT JOIN " + RetSqlTab("CP4") + "ON (C1_PRODUTO = CP4_CODPRO AND C1_NUM =CP4_NUMSC) "
		cQuery += " LEFT JOIN " + RetSqlTab("CX3") + "ON (" + RetSQLCond("CX3") + " AND  C1_PRODUTO = CX3_CODPRO AND C1_NUM =CX3_NUMSC " + cWhereAux + ") "
		cQuery += " WHERE (CP4_EMPENH = 'F' or CP4_EMPENH IS NULL) AND (CX3_EMPENH = 'F' or CX3_EMPENH IS NULL)"  
	Else
		cQuery := " SELECT * "
		cQuery += " FROM " + RetSqlTab("SC1")
		cQuery += " WHERE C1_CODED = '' AND C1_NUMPR = ''"
	EndIf
	If !Empty(cCtrCus)
		cQuery += " AND C1_CC = '"+ cCtrCus +"' "	
	EndIf
	
	If !Empty(cContaC)
		cQuery += " AND C1_CONTA = '"+ cContaC +"' "	
	EndIf
	
	If !Empty(cItemCC)
		cQuery += " AND C1_ITEMCTA = '"+ cItemCC +"' "	
	EndIf
	
	If !Empty(cCvlv)
		cQuery += " AND C1_CLVL = '"+ cCvlv +"' "	
	EndIf
	
	cQuery += " AND C1_QUJE = 0 "
	If Funname() != 'GCPA100' .And. Funname() != 'GCPA101'
    	cQuery += " AND SC1.C1_TPSC = '2'"
	EndIf
	cQuery += " AND C1_QUANT > 0"
	cQuery += " AND C1_RESIDUO <> 'S'"
	cQuery += " AND C1_APROV NOT IN ('R','B')"
	cQuery += " AND C1_COTACAO = '' "
	If !Empty(cFiltro) .And. ValType(cFiltro) == "C"
		cQuery += " AND " + cFiltro 	
	EndIF
	If !Empty(aFiltrPrd)
		cQuery += " AND "
		For nX := 1 To Len(aFiltrPrd) 
			If Len(aFiltrPrd) > nX 
				cQuery += " C1_PRODUTO = '"+aFiltrPrd[nX]+"' OR "
			Else				
				cQuery += " C1_PRODUTO = '"+aFiltrPrd[nX]+"' "
			EndIf		
		Next nX
	Endif
   	cQuery += " AND NOT EXISTS (SELECT 1 FROM "+ RetSqlTab("COO")
  	cQuery += " WHERE SC1.C1_NUM = COO.COO_NUMSC AND SC1.C1_ITEM = COO.COO_ITEMSC "
  	cQuery += " AND " +RetSQLCond("COO")+")"
  	
   	cQuery += " AND NOT EXISTS (SELECT 1 FROM "+ RetSqlTab("CX5")  	
  	cQuery += " WHERE "+RetSQLCond("CX5")+" AND SC1.C1_NUM = CX5.CX5_NUMSC AND SC1.C1_ITEM = CX5.CX5_ITEMSC ) "
	
   	cQuery += " AND NOT EXISTS (SELECT 1 FROM "+ RetSqlTab("CX3")
  	cQuery += " WHERE "+RetSQLCond("CX3")+" AND SC1.C1_NUM = CX3.CX3_NUMSC AND SC1.C1_ITEM = CX3.CX3_ITEMSC " + cWhereAux + ") "
	
	cQuery += " AND " + RetSQLCond("SC1")
	cQuery := ChangeQuery(cQuery)
	IncProc("Selecionando as SolicitaÁıes de Compra...") //"Selecionando as SolicitaÁıes de Compra..."
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp)
	
	If (cAliasTmp)->(!Eof())
		TcFieldAll(cAliasTmp)
		While (cAliasTmp)->(!Eof())
			aVetor:= {}			
	        //CÛdigo para verificar se a SC j· foi selecionada - An·lise de Mercado - Matheus Lando
	        If aScan(aSCs,{|x| x == (cAliasTmp)->C1_NUM+C1_ITEM}) > 0 .Or. ;                
	               aScan(aProds,{|x| x == (cAliasTmp)->C1_PRODUTO}) > 0 
	                            
	               (cAliasTmp)->(dbSkip())                           
	               Loop
	     	EndIf
                    
			aAdd( aVetor, .F. )
						
			For nY:= 1 To Len(aHeadC1)-2
				If	SC1->(FieldPos(aHeadC1[nY,2] ) ) > 0 //.And. !Empty((cAliasTmp)->( FieldGet( SC1->(FieldPos(aHeadC1[nY,2] ) ) ) ))
					aAdd( aVetor, (cAliasTmp)->( FieldGet(FieldPos(aHeadC1[nY,2] ) ) ) )
				Else
					AAdd( aVetor, CriaVar(aHeadC1[nY,2]))
				EndIf
			Next nY
				aAdd( aDados , aVetor )
			(cAliasTmp)->(dbSkip())
		End
	ElseIf !Empty(xFilial("SC1"))
		If (lRet := MsgYesNo(STR0059)) //N„o existem solicitaÁıes de licitaÁ„o nesta filial. Deseja buscar solicitaÁıes de outras filiais?
			GCPXComCen(oLbx,cQuery,lWndManutEdit,@aDados)
	        If Len(aDados) == 0
				(cAliasTmp)->(DbCloseArea())
				lRet := .F.
			EndIf
		EndIf
	Else
		Help("",1,"GCP02SOLIC") //"N„o h· dados de solicitaÁ„o de compras"
		(cAliasTmp)->(DbCloseArea())
		lRet := .F.
	EndIf
Else
	aDados := aClone(aSolC)
EndIf

If lRet
	if Len(aDados) > 0
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Define o titulo das colunas do browse≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		aAdd( aTitulo, "" )
		aAdd( aTam, 10 )
		For nX:= 1 To Len(aHeadC1)
			If !("_WT" $ aHeadC1[nX,2])
				aAdd( aTitulo, aHeadC1[nX,1] )
				aAdd( aTam, GetTextWidth( 0, Replicate( ";", 5+Max( TamSX3( aHeadC1[nX,2] )[1], Len( aHeadC1[nX,1] ) ) ) ) )
			EndIf
		Next
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Calcula dimensıes                                            ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		oSizeMrk := FwDefSize():New()
		oSizeMrk:AddObject( "FILTRO"		,  100, 10, .T., .T.,.F.)
		oSizeMrk:AddObject( "GRID"   	  	,  100, 90, .T., .T.,.F.) 
		oSizeMrk:lProp := .T.
		oSizeMrk:aMargins := { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
		oSizeMrk:Process()
		
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Definicao da Dialog ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		DEFINE MSDIALOG oDlg TITLE cTitulo ;
							FROM oSizeMrk:aWindSize[1],oSizeMrk:aWindSize[2] TO oSizeMrk:aWindSize[3],oSizeMrk:aWindSize[4] OF oMainWnd PIXEL
	
		//Definicao dos objetos de busca
		aAdd(aCmbItens, aHeadC1[nNumSc ,  1] + " + " + aHeadC1[nItemSc ,1])
		aAdd(aCmbItens, aHeadC1[nProdSc , 1])
		aAdd(aCmbItens, aHeadC1[nDescrSc, 1])
		
		aAdd( aFilter, { 1, 'Numero da SC de  ?', Space(6), '@!', '', 'SC1', '', 40, .F. } )	// 'Numero da SC de  ?'
		aAdd( aFilter, { 1, 'Numero da SC ate ?', Space(6), '@!', '', 'SC1', '', 40, .F. } )	// 'Numero da SC ate ?'
		
		@ oSizeMrk:GetDimension('FILTRO','LININI'),oSizeMrk:GetDimension('FILTRO','COLINI') COMBOBOX oCombo VAR cCombo ITEMS aCmbItens SIZE 100,20 ON CHANGE (nCmbOp:=oCombo:nAt, SortSC1(aDados,oCombo:nAt, aHeadC1)) PIXEL OF oDlg
		@ oSizeMrk:GetDimension('FILTRO','LININI'),oSizeMrk:GetDimension('FILTRO','COLINI')+102 MSGET cPesq SIZE 100,09 PIXEL OF oDlg
		@ oSizeMrk:GetDimension('FILTRO','LININI'),oSizeMrk:GetDimension('FILTRO','COLINI')+204 BUTTON '&Buscar' SIZE 35,11 PIXEL OF oDlg ACTION ( oLbx:nAt := BuscaScm(aDados,cPesq,oLbx:nAt,nCmbOp,aHeadC1),oLbx:Refresh()) // '&Buscar'
		@ oSizeMrk:GetDimension('FILTRO','LININI'),oSizeMrk:GetDimension('FILTRO','COLINI')+241 BUTTON '&Filtro' SIZE 35,11 PIXEL OF oDlg ACTION ( If( ParamBox( aFilter, 'Filtro recursivo', @aRetFil ), GCAFilter( @aDados, aHeadC1, aRetFil, cAliasTmp ), Nil ) ) // '&Filtro'		// 'Filtro recursivo'
		
		//Definacao do MarkBrowse
		oLbx := TwBrowse():New( oSizeMrk:GetDimension('GRID','LININI'),oSizeMrk:GetDimension('GRID','COLINI'),;
					 			oSizeMrk:GetDimension('GRID','XSIZE'),oSizeMrk:GetDimension('GRID','YSIZE'),;
					 			,aTitulo,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oLbx:aColSizes := aTam
		SortSC1(aDados,1,aHeadC1)
		
		If lClick
			oLbx:bLDblClick := {|| aDados[oLbx:nAt,1] := !aDados[oLbx:nAt,1],oLbx:Refresh()}
		EndIf
		
		oLbx:bLine := GCAbLine( aDados )
		olbx:bheaderclick := { |x,y| If( Len( aDados )== 0, Alert( 'N„o existe dados para seleÁ„o' ), If( y == 1, GCAMarkAll( @aDados ), Nil ) ) }	// 'N„o existe dados para seleÁ„o'
		
		aAdd(aButtons,{'PROJETPMS',{|| GCPXComCen(oLbx,cQuery,lWndManutEdit,@aDados)},"Compra Centralizada"}) //-- Compra Centralizada
				
		ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| (oDlg:End(),nOpcX:= 1)},{||oDlg:End()},,aButtons)
	Else	
		Help("",1,"GCP02SOLIC") //"N„o h· dados de solicitaÁ„o de compras"
 	   (cAliasTmp)->(DbCloseArea())
		lRet := .F.
	Endif	
	
	If nOpcX == 1
		aRet := aClone(aDados)
	EndIf
	
EndIf

If Select(cAliasTmp) > 0
	(cAliasTmp)->(DbCloseArea())
EndIf

RestArea(aArea)
Return aRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} SortSC1(aData, nIndex, aHeadC1)
FunÁ„o para ordenaÁ„o das SolicitaÁıes de Compra na geraÁ„o de processo licitatÛrio por SC

@author	jose.delmondes
@param		aData - Array com as solicitaÁıes de compra
@param 		nIndex - Indice utilizado para ordenaÁ„o
@param 		aHeadSC1 - CabeÁalho do vetor aData 
@return	N„o possui
@since 		23/12/2014
@version 	11.8
/*/
//------------------------------------------------------------------------
Static Function SortSC1(aData, nIndex, aHeadC1)
Local nNum		:= aScan(aHeadC1,{|x| Trim(x[2]) == "C1_NUM"		}) + 1
Local nItem	:= aScan(aHeadC1,{|x| Trim(x[2]) == "C1_ITEM"		}) + 1
Local nProd	:= aScan(aHeadC1,{|x| Trim(x[2]) == "C1_PRODUTO"	}) + 1
Local nDesc	:= aScan(aHeadC1,{|x| Trim(x[2]) == "C1_DESCRI"	}) + 1

If nIndex == 1		// Ordena por Numero da SC + Item
	aSort(aData,,,{|x,y| x[nNum]+x[nItem] < y[nNum]+y[nItem]})
ElseIf nIndex == 2	// Ordena por Codigo do Produto
	aSort(aData,,,{|x,y| x[nProd]+x[nNum] < y[nProd]+y[nNum]})
ElseIf nIndex == 3	// Ordena por DescriÁ„o do produto 
	aSort(aData,,,{|x,y| x[nDesc]+x[nNum] < y[nDesc]+y[nNum]})
EndIf

//Atualiza objeto TWBrowse
oLbx:SetArray( aData )
oLbx:bLine := GCAbLine( aData )
oLbx:Refresh()

Return 

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥CriaHeader∫Autor  ≥Alvaro Camillo Neto ∫ Data ≥  21/02/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Cria o Aheader da getdados                                  ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GENERICO                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function CriaHeader(cCampos,cExcessao,aHeader,cAlias)
Local aArea		:= GetArea()
Local cX3Campo	:= ""
   
Default aHeader 	:= {}
DEFAULT cCampos 	:= "" // Campos a serem conciderados
DEFAULT cExcessao	:= "" // Campos que n„o conciderados

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
While SX3->(!EOF()) .And.  SX3->X3_ARQUIVO == cAlias
	cX3Campo := Alltrim(SX3->X3_CAMPO)	
	
	If (X3USO(GetSx3Cache(cX3Campo,'X3_USADO')) .Or. ( cX3Campo $ Alltrim(cCampos) )) .AND. (cNivel >= GetSx3Cache(cX3Campo,'X3_NIVEL')) .AND. !(cX3Campo $ Alltrim(cExcessao))
		aAdd( aHeader, { AlLTrim( X3Titulo() ), ; 		// 01 - Titulo
		cX3Campo									, ;			// 02 - Campo
		GetSx3Cache(cX3Campo,'X3_PICTURE')		, ;			// 03 - Picture
		GetSx3Cache(cX3Campo,'X3_TAMANHO')		, ;			// 04 - Tamanho
		GetSx3Cache(cX3Campo,'X3_DECIMAL')		, ;			// 05 - Decimal
		GetSx3Cache(cX3Campo,'X3_VALID') 		, ;			// 06 - Valid
		GetSx3Cache(cX3Campo,'X3_USADO')		, ;			// 07 - Usado
		GetSx3Cache(cX3Campo,'X3_TIPO')		 	, ;			// 08 - Tipo
		GetSx3Cache(cX3Campo,'X3_F3')		  	, ;			// 09 - F3
		GetSx3Cache(cX3Campo,'X3_CONTEXT')		, ;       // 10 - Contexto
		GetSx3Cache(cX3Campo,'X3_CBOX')			, ; 		// 11 - ComboBox
		GetSx3Cache(cX3Campo,'X3_RELACAO')		} )   		// 12 - Relacao
	Endif
	SX3->(dbSkip())
End

If cAlias # "COC"
	ADHeadRec(cAlias,aHeader)
EndIf

RestArea(aArea)
Return(aHeader)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥TcFieldAll∫Autor  ≥Alvaro Camillo Neto ∫ Data ≥  06/02/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Aplica o comando TcSetField em todos os campos de uma query ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function TcFieldAll(qQuery)
Local aStruQry 	:= {}
Local nI		:= 0
Local aArea		:= GetArea()
Local AAreaSX3	:= SX3->(GetArea())

SX3->(dbSetOrder(2)) //X3_CAMPO
aStruQry   := (qQuery)->(dbStruct())
For nI := 1 To Len(aStruQry)
	If SX3->(dbSeek(aStruQry[nI][1]))
		aStruQry[nI][2] := SX3->X3_TIPO
		If aStruQry[nI][2] <> "C"
			TcSetField(qQuery ,aStruQry[nI][1],aStruQry[nI][2],aStruQry[nI][3],aStruQry[nI][4])
		EndIf
	EndIf
Next nI
RestArea(AAreaSX3)
RestArea(aArea)
Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ GCAbLine ≥ Autor ≥      Icaro Queiroz    ≥ Data ≥29/09/2010≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥	Indica o bloco de codigo da lista de campos				  ≥±±
±±≥			 ≥	@param  aData	Itens disponiveis para selecao			  ≥±±
±±≥			 ≥	@Return bMyLine	blogo de codigo da lista de campos        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ GCAFilter                                                  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

Static Function GCAbLine( aData )
Local bMyLine
Local cLine		:= ''

cLine := '{ Iif( aData[oLbx:nAt,1], oOk, oNo )'
aEval( aTitulo, { |x,y| cLine += ',aData[oLbx:nAt,' + LTrim( Str(y) ) + ']' }, 2 ); cLine += '}'

bMyLine := & ( '{|| ' + cLine + '}' )

Return( bMyLine )

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥GCAMarkAll≥ Autor ≥      Icaro Queiroz    ≥ Data ≥28/09/2010≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Marca ou desmarca todos os itens;	    				  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ GCAMarkAll                                                 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function GCAMarkAll( aData )

aEval( aData, { |x| If( Empty( aData ), Nil, x[1] := !x[1] ) }, oLbx:Refresh() )

oLbx:bLine := GCAbLine( aData )
oLbx:Refresh()

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPCadProd(oModel, aDados, aHeader, cAliasPrd,cAliasSC, cModFor, cAliasLt)
Rotina que carrega os Produtos das SC's.
retirada do GPCA100

@author Matheus Lando Raimundo
@param oModel  Modelo de dados
@param aDados  Matriz com as SC's
@param aHeader 
@param cAliasPrd Alias de Produto
@param cAliasSC Alias de SolicitaÁ„o de Compras
@param cModFor Modelo do Fornecedor, padr„o COP_Detail(analise de mercado)
@param CAliasLt Alias do Lote, Padr„o COQ (Analise de Mercado)
@since 22/07/2013
@version 1.1
/*/
//-------------------------------------------------------------------
Function GCPCadProd(oModel, aDados, aHeader, cAliasPrd,cAliasSC, cModFor, cAliasLt)
Local nI    		:= 0
Local nAux  		:= 0
Local nQtde 		:= 0
Local nQtdeSegu		:= 0
Local lAddLine  	:= .T.  
Local cAjustaMod	:= IIF(cAliasPrd $ "CO2*CPY","","_")            
Local oModProd 		:= oModel:GetModel(cAliasPrd+cAjustaMod+'DETAIL')
Local oModSC 		:= oModel:GetModel(cAliasSC+cAjustaMod+'DETAIL')
Local oModFor 		:= IIF(ValType(cModFor)=="C",oModel:GetModel(cModFor),oModel:GetModel('COP_DETAIL'))
Local oModLt		:= oModel:GetModel(cAliasLt+cAjustaMod+'DETAIL')
Local aSaveLines 	:= FWSaveRows()
Local cPrefProd		:= PrefixoCpo(cAliasPrd)
Local cPrefSC		:= PrefixoCpo(cAliasSC)
Local lOriEdit		:= (oModel:GetId() $ 'GCPA200*GCPA201')		
Local lUsaLote		:= (oModel:GetId() $ 'GCPA101*GCPA201*GCPA301')
Local lOriAta		:= (oModel:GetId() $ 'GCPA300*GCPA301' )
Local lAnlMerc		:= (oModel:GetId() $ 'GCPA100*GCPA101')
Local oCPIDetail	:= (IIf(lOriAta,oModel:GetModel('CPIDETAIL'), Nil))	
Local lIncManual	:= .F.
Local cItem			:= Replicate("0", (TamSx3('CO2_ITEM')[1]))
Local lNotaEmp		:= SuperGetMV("MV_NOTAEMP",.F.,.F.)
Local oModOrg 		:= IIF(lOriEdit, oModel:GetModel('CPIDETAIL'), NIL)
Local oModCab		:= IIF(lOriEdit, oModel:GetModel('CO1MASTER'), oModel:GetModel('COM_MASTER'))
Local aCpos 		:= {}
Local nLinha		:= 0
Local nQunt 		:= 0
Local nTot          := 0 
Local nEst          := 0
Local cProduto		:= ""
Local cSegUnMed		:= ""
Local oLinhaXProd	:= THashMap():New()
Local oNPosFlds		:= JsonObject():New()
Local oGDFldPos		:= JsonObject():New()
Local aCampos		:= {}
Local aFldPos		:= {}
Local aAllFlds		:= {}
Local lFilSc		:= &(cPrefSC)->(ColumnPos(cPrefSC+'_FILSC')) > 0 .And. X3Uso(GetSx3Cache(cPrefSC+'_FILSC', 'X3_USADO'))
Local lCOOQuant		:= (COO->(ColumnPos('COO_QUANT')) > 0)
Local lUserOk		:= .T.
Local cMsgUser		:= ""
Local cFilSB1		:= xFilial("SB1")
Default aHeader  	:= {}

// desbloqueia linhas 
oModSC:SetNoInsertLine( .F. )
GCP017BMod(oModel, {cAliasPrd+cAjustaMod+'DETAIL'}, .F.)
GCP017BMod(oModel, {cAliasSC+cAjustaMod+'DETAIL'}, .F.)

If lOriAta 
	CO1->(DbSetOrder(1))	
	lIncManual := !CO1->(DbSeek(xFilial("CO1")+oModel:GetModel("CPHMASTER"):GetValue("CPH_CODEDT")))
EndIf

If lUsaLote
	If (!IsBlind())
		cMsgUser := STR0060 + Trim(oModLt:GetValue(cAliasLt+'_LOTE'))+ ' ' //"Os Produtos Selecionados ser„o inclusos para o Lote "
		cMsgUser += STR0061 //"Deseja Continuar?"
		lUserOk := 	MsgYesNo(cMsgUser, STR0062)//"Inclus„o de Produtos"
	EndIf
EndIf

CPA->(DBSetOrder(2))
SB1->(dbSetOrder(1))//B1_FILIAL+B1_COD
                  	
If (oModel:GetId() $ 'GCPA100|GCPA200|GCPA300|') .Or. ( lUsaLote .And. lUserOk)	
	aAllFlds := oModProd:GetStruct():GetFields()
	for nAux := 1 to Len(aAllFlds)	
		aAdd(aCampos, aAllFlds[nAux,3] )
	next nAux	

	aFldPos := oModProd:GetStruct():GetArrayPos(aCampos)
	for nAux := 1 to Len(aCampos)		
		oNPosFlds[aCampos[nAux]] := aFldPos[nAux]
	next nAux

	for nAux := 1 to Len(aHeader)-2		
		oGDFldPos[aHeader[nAux,2]] := GDFieldPos(aHeader[nAux,2],aHeader) + 1
	next nAux

	For nAux := 1 To oModProd:Length()                   
		oModProd:GoLine( nAux )
		cProduto	:= oModProd:GetValue(cPrefProd+'_CODPRO')
		If !oModProd:IsDeleted() .And. !Empty(cProduto)
			oLinhaXProd:Set(cProduto, nAux)
		EndIf
	Next nAux
															 
	If Len(aDados) > 0
		For nI := 1 to Len(aDados)
			lAddLine := .T.
			
			cProduto := aDados[nI, oGDFldPos["C1_PRODUTO"]]
			If (aDados[nI, 1])

				If oLinhaXProd:Get(cProduto, @nLinha)//Busca o cÛdigo do produto no modelo, se encontrar, realiza a aglutinaÁ„o de Produtos
					oModProd:GoLine( nLinha )					

					nQtde := oModProd:GetValueByPos(oNPosFlds[cPrefProd+'_QUANT'])
					If lOriAta
						nQtdeSegu := oModProd:GetValueByPos(oNPosFlds[cPrefProd+'_QUANT2'])						
					Else
						nQtdeSegu := oModProd:GetValueByPos(oNPosFlds[cPrefProd+'_QTSEGU'])						
					EndIf
					
					If oModProd:IsDeleted() 
						oModProd:UnDeleteLine()
						If lOriEdit
							nQtde := GCPSumSC(oModel,'CP4DETAIL','CP4')
						ElseIf lOriAta
							nQtde := GCPSumSC(oModel,'CX3DETAIL','CX3')
						Else
							nQtde := GCPSumSC(oModel,'COO_DETAIL','COO')
						EndIf	
					EndIf	                                                	
																														
					//Soma as Quantidades
					
					//-- SÛ n„o incrementa a quantidade caso seja Ata de SRP e inclus„o manual 											
					If !(lOriAta .And. !lIncManual) .Or. lOriEdit
						oModProd:LdValueByPos(oNPosFlds[cPrefProd+'_QUANT'], nQtde + aDados[nI, oGDFldPos["C1_QUANT"]]) 
						If lOriEdit
							oModProd:SetValue(cPrefProd+'_VLESTI', aDados[nI, oGDFldPos["C1_VUNIT"]] ) 
						EndIf
						If !lAnlMerc
							oModProd:LdValueByPos(oNPosFlds[cPrefProd+'_SALDO']	, nQtde + aDados[nI, oGDFldPos["C1_QUANT"]])
							If lOriAta
								oModProd:LdValueByPos(oNPosFlds[cPrefProd+'_QTDLIC']	, nQtde + aDados[nI, oGDFldPos["C1_QUANT"]])
							EndIf
						EndIf
													
						If 	lOriEdit .Or. lAnlMerc
							oModProd:LdValueByPos(oNPosFlds[cPrefProd+'_QTSEGU']	, nQtdeSegu + aDados[nI, oGDFldPos["C1_QTSEGUM"]]) 
						ElseIf lOriAta .And. lIncManual
							oModProd:LdValueByPos(oNPosFlds[cPrefProd+'_QUANT2']	, nQtdeSegu + aDados[nI, oGDFldPos["C1_QTSEGUM"]])							
							oCPIDetail:SetValue('CPI_QTDLIC', oModProd:GetValue(cPrefProd+'_QUANT'))
						EndIf					
					EndIf                
					//Insere a SC
					If !Empty(oModSC:GetValue(cPrefSC+'_NUMSC')) // N„o È primeira linha, ent„o inseri
						oModSC:AddLine()
					EndIf										
					oModSC:SetValue(cPrefSC+'_NUMSC' , aDados[nI, oGDFldPos["C1_NUM"]])
					oModSC:SetValue(cPrefSC+'_ITEMSC', aDados[nI, oGDFldPos["C1_ITEM"]])
					If lFilSc
						oModSC:SetValue(cPrefSC+'_FILSC', aDados[nI, oGDFldPos["C1_FILIAL"]])
					EndIf
					
					oModSC:SetValue(cPrefSC+'_QUANT' , aDados[nI, oGDFldPos["C1_QUANT"]])
					
					If lOriEdit //Insere campo C1_FILENT
						oModSC:LoadValue(cPrefSC+'_FILENT', aDados[nI, oGDFldPos["C1_FILENT"]])					
					ElseIf lOriAta
						oModSC:LoadValue('CX3_SALDO', oModSC:GetValue('CX3_QUANT'))	              
						
						If !lNotaEmp			
							oModSC:LoadValue("CX3_EMPENH",.T.)
						EndIf	              
					EndIf 
					
					//Tratativa para atualizar os Org„os Participantes
					If lOriEdit .and. oModCab:GetValue('CO1_SRP') == '1'
						CPA->(DBSetOrder(2))
						aAdd(aCpos, {"CPI_FILENT", aDados[nI, oGDFldPos["C1_FILENT"]]})
						nLinha := MTFindMVC(oModOrg, aCpos)
						
						If nLinha > 0
							oModOrg:GoLine(nLinha)
							nQunt := oModOrg:GetValue('CPI_QTDLIC')
							oModOrg:SetValue('CPI_QTDLIC'	, aDados[nI, GDFieldPos("C1_QUANT",aHeader) + 1] + nQunt)
						ElseIf CPA->(DbSeek(xFilial("CPA")+aDados[nI, GDFieldPos("C1_FILENT",aHeader) + 1]))
							If MsgYesNo("Deseja informar o org„o gerenciador na aba de org„os participantes? ")
								If !Empty(oModOrg:GetValue('CPI_CODORG')) // N„o È primeira linha, ent„o insere
									oModOrg:AddLine()		          		                       				
								EndIf
								CPA->(DBSetOrder(1))
								oModOrg:SetValue('CPI_CODORG'	, CPA->CPA_CODORG)
								oModOrg:SetValue('CPI_QTDLIC'	, aDados[nI, GDFieldPos("C1_QUANT",aHeader) + 1])
								oModOrg:SetValue('CPI_FILENT'	, CPA->CPA_SISFIL)
							EndIf
						EndIF
					EndIf
					
					lAddLine := .F.   
					//Caso esteja inserindo por Lote, Atualiza as quantidades.
					If ((oModel:GetId() == 'GCPA101') .And. (!Empty(oModFor:GetValue('COP_CODFOR'))))
						GCP101APrd(oModProd:GetValue(cPrefProd+'_CODPRO'),oModProd:GetValue(cPrefProd+'_QUANT'), @oModel)	                    
					EndIf                               
				Else
					lAddLine := !( IsProdBloq(cProduto , .F. , cFilSB1) ) //SÛ verifica se for um novo produto...
				EndIf			                                             			                    
	          	
				If lAddLine//Caso n„o tenha aglutinado insere um produto novo.
									           	 	            	           	 	   
					oModProd:GoLine( oModProd:Length() )					

					If !Empty(oModProd:GetValueByPos(oNPosFlds[cPrefProd+'_CODPRO']))	
						If cAliasPrd == "CO2" .And. !Empty(oModProd:GetValue(cPrefProd+'_ITEM'))
							cItem = oModProd:GetValue(cPrefProd+'_ITEM')
						EndIf
						oModProd:AddLine()
					EndIf
					
					oLinhaXProd:Set(cProduto, oModProd:GetLine())
					
					If (lOriAta .Or. lOriEdit)
						cItem := Soma1(cItem)		 
						oModProd:SetValue(cPrefProd+'_ITEM', cItem)
					EndIf

					If (cAliasPrd == "CON")
						oModProd:LdValueByPos(oNPosFlds[cPrefProd+'_CODPRO'], cProduto)
						oModProd:LdValueByPos(oNPosFlds[cPrefProd+'_DESCR']	, aDados[nI, oGDFldPos["C1_DESCRI"]]) 
					Else
						oModProd:SetValue(cPrefProd+'_CODPRO'	, cProduto)
						oModProd:SetValue(cPrefProd+'_DESCR' 	, aDados[nI, oGDFldPos["C1_DESCRI"]])  
					EndIf										
					oModProd:LdValueByPos(oNPosFlds[cPrefProd+'_QUANT']	, aDados[nI, oGDFldPos["C1_QUANT"]])
					oModProd:LdValueByPos(oNPosFlds[cPrefProd+'_UM' ]	, aDados[nI, oGDFldPos["C1_UM"]])

					If lOriEdit
						If GDFieldPos("C1_VUNIT",aHeader) > 0
							oModProd:SetValue(cPrefProd+'_VLESTI', aDados[nI, GDFieldPos("C1_VUNIT",aHeader) + 1])
						Else
							oModProd:SetValue(cPrefProd+'_VLESTI', 0)
						EndIf
					EndIf
					
					//-- SÛ n„o incrementa a quantidade caso seja Ata de SRP e inclus„o manual 											
					If !(lOriAta .And. !lIncManual) .Or. lOriEdit
						If !lAnlMerc
							oModProd:LdValueByPos(oNPosFlds[cPrefProd+'_SALDO' ]	, nQtde + aDados[nI, oGDFldPos["C1_QUANT"]])
							If lOriAta
								oModProd:LdValueByPos(oNPosFlds[cPrefProd+'_QTDLIC'], aDados[nI, oGDFldPos["C1_QUANT"]])
							EndIf
						EndIf
						cSegUnMed := aDados[nI, oGDFldPos["C1_SEGUM"]]
						If !Empty(cSegUnMed)							
							If 	lOriEdit .Or. lAnlMerc
								oModProd:LdValueByPos(oNPosFlds[cPrefProd+'_QTSEGU'], nQtdeSegu + aDados[nI, oGDFldPos["C1_QTSEGUM"]])
								oModProd:SetValue(cPrefProd+'_SEGUM'    , cSegUnMed)
							ElseIf lOriAta .And. lIncManual
								oModProd:LdValueByPos(oNPosFlds[cPrefProd+'_QUANT2'], nQtdeSegu + aDados[nI, oGDFldPos["C1_QTSEGUM"]])							
								oModProd:SetValue(cPrefProd+'_UM2'    , cSegUnMed)														
							EndIf
						EndIf

						If lOriAta .And. lIncManual
							oCPIDetail:SetValue('CPI_QTDLIC', oModProd:GetValue(cPrefProd+'_QUANT'))
						EndIf
                 	EndIf
					
					If !lOriEdit .And. !lOriAta						
						oModProd:LdValueByPos(oNPosFlds['CON_METODO'], '1')
					EndIf
						
					//Insere a SC                                        							
				 	If !Empty(oModSC:GetValue(cPrefSC+'_NUMSC')) // N„o È primeira linha, ent„o insere
						oModSC:AddLine()			
                 	EndIf

					oModSC:SetValue(cPrefSC+'_NUMSC'  , aDados[nI, oGDFldPos["C1_NUM"]])                         
					oModSC:SetValue(cPrefSC+'_ITEMSC' , aDados[nI, oGDFldPos["C1_ITEM"]])

					If lFilSc
						oModSC:SetValue(cPrefSC+'_FILSC', aDados[nI, oGDFldPos["C1_FILIAL"]])
					EndIf
					If lCOOQuant
						oModSC:SetValue(cPrefSC+'_QUANT' , aDados[nI, oGDFldPos["C1_QUANT"]])
					EndIf                
	              
					If lUsaLote 
						oModSC:SetValue(cPrefSC+	'_LOTE' , oModLt:GetValue(cAliasLt+'_LOTE'))
					EndIf	              
	              
					If lOriEdit 	//Insere campo C1_FILENT						
						oModSC:LoadValue(cPrefSC+'_FILENT', aDados[nI, oGDFldPos["C1_FILENT"]])
					ElseIf lOriAta			      	 	
			      	 	oModSC:LoadValue('CX3_SALDO', oModSC:GetValue('CX3_QUANT'))
			      	 	If !lNotaEmp			
							oModSC:LoadValue("CX3_EMPENH",.T.)
						EndIf							              
			       EndIf 
					
					//Tratativa para atualizar os Org„os Participantes
					If lOriEdit .and. oModCab:GetValue('CO1_SRP') == '1'
                 		CPA->(DBSetOrder(2))
                 		aAdd(aCpos, {"CPI_FILENT", aDados[nI, GDFieldPos("C1_FILENT",aHeader) + 1]})
                 		nLinha := MTFindMVC(oModOrg, aCpos)
                 		
                 		If nLinha > 0
                 			oModOrg:GoLine(nLinha)
							nQunt := oModOrg:GetValue('CPI_QTDLIC')
							oModOrg:SetValue('CPI_QTDLIC'	, aDados[nI, GDFieldPos("C1_QUANT",aHeader) + 1] + nQunt)
						ElseIf CPA->(DbSeek(xFilial("CPA")+aDados[nI, GDFieldPos("C1_FILENT",aHeader) + 1]))
                 			If MsgYesNo("Deseja informar o org„o gerenciador na aba de org„os participantes? ")
	                 			If !Empty(oModOrg:GetValue('CPI_CODORG')) // N„o È primeira linha, ent„o insere
									oModOrg:AddLine()					          		                       				
	                 			EndIf
	                 			CPA->(DBSetOrder(1))
	                 			oModOrg:SetValue('CPI_CODORG'	, CPA->CPA_CODORG)
	                 			oModOrg:SetValue('CPI_QTDLIC'	, aDados[nI, GDFieldPos("C1_QUANT",aHeader) + 1])
	                 			oModOrg:SetValue('CPI_FILENT'	, CPA->CPA_SISFIL)
                 			EndIf
                 		EndIF
					EndIf
	              
					//Caso esteja incluindo um produto novo, adiciona na composiÁ„o do Lote
					If ((lUsalote) .And. !lOriEdit .And. !lOriAta .And. (!Empty(oModFor:GetValue('COP_CODFOR'))))
						GCP101Load()
					EndIf	               
				EndIf                                                                                        	        	        	       
			EndIf		        	        	
		Next nI      	  
	EndIf
EndIf
oModProd:GoLine(1)

If oModel:GetID() $ 'GCPA200|GCPA201'
	If !lUsalote
		For nEst := 1 to  oModProd:length()
			oModProd:GoLine(nEst)
			nTot += oModProd:GetValue("CO2_QUANT") *  oModProd:GetValue("CO2_VLESTI")
		next nEst
	Else
		For nEst := 1 to  oModLt:length()
			oModLt:GoLine(nEst)
			nTot += oModLt:GetValue("CP3_VLRTOT") 
		next nEst
	EndIF
	If nTot > 0
  		oModCab:LoadValue("CO1_VLLL",nTot)
	EndIf
ElseIf lAnlMerc
	If !lUsalote		
		For nEst := 1 to  oModProd:length()
			oModProd:GoLine(nEst)
			If (oModProd:GetValueByPos(oNPosFlds['CON_VALEST']) > 0)				
				nTot += oModProd:GetValueByPos(oNPosFlds['CON_QUANT']) *  oModProd:GetValueByPos(oNPosFlds['CON_VALEST'])
			EndIf
		Next nEst
	Else
		For nEst := 1 to  oModLt:length()
			oModLt:GoLine(nEst)
			If !oModLt:IsDeleted()
				nTot += oModLt:GetValue("COQ_VLRTOT")
            EndIf  
		Next nEst				
		If nTot > 0
		  oModCab:LoadValue("COM_VALEST",nTot)
		EndIf  		
	EndIF
EndIf
// volta bloqueio de linhas
/*GCP017BMod(oModel, {cAliasPrdcAjustaMod+'DETAIL'}, .T.)
GCP017BMod(oModel, {cAliasSC+cAjustaMod+'DETAIL'}, .T.)*/
oModSC:SetNoInsertLine( .T. )
oModSC:SetNoUpdateLine( .T. )

//Recalcular o Lote
If lUsaLote .And. lOriEdit
	GCP201CVLT()
ElseIf lUsaLote .And. !lOriEdit 
	GCP101CVLT()
EndIf
FWRestRows(aSaveLines)
FwFreeArray(aSaveLines)

oLinhaXProd:Clean()
FreeObj(oLinhaXProd)
FreeObj(oNPosFlds)
FreeObj(oGDFldPos)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPSldPrd()
Valida se a quantidade informada È igual ou maior a quantidade a soma das SC

@author alexandre.gimenez
@since 12/09/2013
@version 1.1
/*/
//-------------------------------------------------------------------
Function GCPSldPrd()
Local oModel 	:= FWModelActive()
Local lOriEdit:= (oModel:GetId() == 'GCPA200' .Or. oModel:GetId() == 'GCPA201') //Originaria de Processo LicitatÛrio
Local lret		:= .T.
local nInf		:= &(ReadVar())
Local nSum		:= 0
Local lContinua := !(FwIsInCallStack("GCP200Cpy") .Or. FwIsInCallStack("GCPCADPROD"))

If lContinua
	If lOriEdit
		nSum := GCPSumSC(oModel,'CP4DETAIL','CP4')
		If nSum > 0 //Existe SC
			lRet := nInf == nSum
		EndIf
	Else
		nSum := GCPSumSC(oModel,'COO_DETAIL','COO')
		If nSum > 0 //Existe SC
			lRet := nInf == nSum
		EndIf
		If lRet
			//Recalcula valor total dos fornecedores
			GCPAllForn()
		EndIf	
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPSumSC(oModel,cModSC,cAliasSC)
Rotina que retorna a quantidade somada das solicitaÁıes de compra n„o deletadas.

@author alexandre.gimenez
@param oModel Modelo de dados
@param oModSC Modelo de SolicitaÁ„o de Compra
@param cAliasSC Alias da SolicitaÁ„o de Compra
@param cFilEnt Filial de entrega
@since 12/09/2013
@version 1.1
/*/
//-------------------------------------------------------------------
Function GCPSumSC(oModel,cModSC,cAliasSC,cFilEnt,cCampo)
Local oModSC 	:= oModel:GetModel(cModSC)
Local cPrefSC	:= PrefixoCpo(cAliasSC)
Local nX		:= 0
Local nRet		:= 0
Local aSaveLines 	:= FWSaveRows()

Default cFilEnt 	:= ""
Default cCampo	:= "_QUANT"

//Posiciona o registro na SC1 para recuperar a quantidade da SC.
dbSelectArea(cPrefSC)
SC1->(dbSetOrder(1))
For Nx := 1 to oModSC:Length()
	oModSC:GoLine( Nx )
	If !oModSC:IsDeleted() 
		If SC1-> (dbSeek(xFilial('SC1')+oModSC:GetValue(cPrefSC+'_NUMSC')+oModSC:GetValue(cPrefSC+'_ITEMSC')))
			IF cFilEnt == ""
				nRet += If(cPrefSC == 'COO',SC1->C1_QUANT,oModSC:GetValue(cPrefSC + cCampo))
			ElseIf oModSC:GetValue(cPrefSC+'_FILENT') == cFilEnt
				nRet += If(cPrefSC == 'COO',SC1->C1_QUANT,oModSC:GetValue(cPrefSC + cCampo))
			EndIf
		EndIf
	EndIf
Next Nx
FWRestRows(aSaveLines)
Return nRet

//-------------------------------------------------------------------
/*{Protheus.doc} GCPXGrvCOW
Inicializa a pasta processo licitatÛrio x Check-List 

@author Alex Egydio
@since 10/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function GCPXGrvCOW(cCodEdt,cNumPro,cRegra,cModali,cRevisa)
Local cChkLst	:= ""
Local cEtapa	:= ""
                                                               

//-- Checklist
//-- O checklist nao eh obrigatorio
//-- CP1_FILIAL + CP1_REGRA + CP1_MODALI + CP1_ETAPA + CP1_CHECK
CP1->(DbSetOrder(1))
If	CP1->(DbSeek(xFilial("CP1")+cRegra+cModali))
	//-- Check-List
	//-- CP1_FILIAL + CP1_REGRA + CP1_MODALI + CP1_ETAPA + CP1_CHECK
	While CP1->( !Eof() .And. CP1->CP1_FILIAL + CP1->CP1_REGRA + CP1->CP1_MODALI == xFilial("CP1") + cRegra + cModali )
		cChkLst := CP1->CP1_CHECK
		cEtapa	:= CP1->CP1_ETAPA
		If !CP1->CP1_USADO
			CP1->(DbSkip())
			Loop
		EndIf
		//-- COW_FILIAL+COW_CODEDT+COW_NUMPRO+COW_REVISA+COW_ETAPA+COW_CHKLT+COW_CHKIT                                                                                       
		COW->(DbSetOrder(1))
		If	! COW->(DbSeek(xFilial("COW")+cCodEdt+cNumPro+cRevisa+cEtapa+cChkLst))
			//-- COX_FILIAL + COX_CODIGO + COX_ITEM
			COX->(DbSetOrder(1))
			If	COX->(DbSeek(xFilial("COX")+cChkLst))
				While COX->( ! Eof() .And. COX->COX_FILIAL+COX->COX_CODIGO == xFilial("COX") + cChkLst )
					RecLock("COW",.T.)
					COW->COW_FILIAL	:= xFilial("COW")
					COW->COW_CODEDT	:= cCodEdt
					COW->COW_NUMPRO	:= cNumPro
					COW->COW_REVISA	:= cRevisa
					COW->COW_ETAPA	:= cEtapa
					COW->COW_CHKLT	:= cChkLst
					COW->COW_CHKIT	:= COX->COX_ITEM
					COW->COW_DESC	:= COX->COX_DESC
					COW->COW_PROPRI	:= COX->COX_PROPRI
					COW->COW_COND	:= COX->COX_COND
					COW->COW_OBRIGA	:= COX->COX_OBRIGA
					COW->COW_DPSLEG	:= COX->COX_DPSLEG
					COW->COW_CHKOK	:= .F.
					COW->COW_DESCDE	:= COX->COX_DESCDE
					COW->(MsUnLock())

					COX->(DbSkip())
				EndDo
			EndIf
		EndIf
		CP1->(DbSkip())
	EndDo
EndIf
Return
//-------------------------------------------------------------------
/*{Protheus.doc} GCPXGrvCP2
Gera a tabela CP2 - processo licitatÛrio X Etapa de Licitacao com base na tabela CP0

@author Alex Egydio
@since 10/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function GCPXGrvCP2(cCodEdt,cNumPro,cRevisa,cRegra,cModali,cEtapa)
Local lRet	:= .T.
Local cPbV := ""
Local cPbF := ""

Default cEtapa := ""

CP0->(DbSetOrder(1))
lRet := CP0->(DbSeek(xFilial("CP0")+cRegra+cModali))
	
If	lRet
	//-- CP2_FILIAL+CP2_CODEDT+CP2_NUMPRO+CP2_REVISA+CP2_ETAPA
	CP2->(DbSetOrder(1))
	lRet := CP2->(DbSeek(xFilial("CP2")+cCodEdt+cNumPro+cRevisa))
		
	If	! lRet
		lRet := .T.
		//-- Se nao encontrar Processo LicitatÛrio x Etapa de Licitacao, sera gerado o CP2 
		//-- CP0_FILIAL + CP0_REGRA + CP0_MODALI + CP0_ETAPA
		
		If (cModali == "DL" .Or. cModali == "IN") .And. (FwFldGet('CO1_LEI') $ '1|2')  .And. GCPXVldPub(@cPbV, @cPbF)
			While CP0->( !Eof() .And. CP0->CP0_FILIAL + CP0->CP0_REGRA + CP0->CP0_MODALI == xFilial("CP0") + cRegra + cModali )
						
				If CP0->CP0_ETAPA <> 'PB' // Pula etapa de publicaÁ„o
					RecLock("CP2",.T.)
					CP2->CP2_FILIAL	:= xFilial("CP2")
					CP2->CP2_CODEDT	:= cCodEdt
					CP2->CP2_NUMPRO	:= cNumPro
					CP2->CP2_REVISA	:= cRevisa
					CP2->CP2_ETAPA	:= CP0->CP0_ETAPA
					CP2->CP2_CONDIC	:= CP0->CP0_CONDIC
					CP2->CP2_PROXIV	:= If(CP0->CP0_PROXIV == "PB", cPbV, CP0->CP0_PROXIV)
					CP2->CP2_PROXIF	:= If(CP0->CP0_PROXIF == "PB", cPbF, CP0->CP0_PROXIF)
					CP2->CP2_ETPANT	:= If(CP0->CP0_ETPANT == "PB", "", CP0->CP0_ETPANT) 
					CP2->(MsUnLock())
				EndIf
			
				CP0->(DbSkip())
			EndDo
		Else
			While CP0->( !Eof() .And. CP0->CP0_FILIAL + CP0->CP0_REGRA + CP0->CP0_MODALI == xFilial("CP0") + cRegra + cModali )
						
				RecLock("CP2",.T.)
				CP2->CP2_FILIAL := xFilial("CP2")
				CP2->CP2_CODEDT := cCodEdt
				CP2->CP2_NUMPRO := cNumPro
				CP2->CP2_REVISA := cRevisa
				CP2->CP2_ETAPA	:= CP0->CP0_ETAPA
				CP2->CP2_CONDIC	:= CP0->CP0_CONDIC
				CP2->CP2_PROXIV	:= CP0->CP0_PROXIV
				CP2->CP2_PROXIF	:= CP0->CP0_PROXIF
				CP2->CP2_ETPANT := CP0->CP0_ETPANT
				CP2->(MsUnLock())
			
				CP0->(DbSkip())
			EndDo
		EndIf
		
	EndIf
		
EndIf
		
Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc} GCPXVldPub
Verifica se a etapa de publicaÁ„o do edital deve ser eliminada,
nos casos de dispensa de licitaÁ„o e inexigibilidade. 

@author jose.delmondes
@since 07/03/2016
@version P12.1.7
*/
//-------------------------------------------------------------------
Function GCPXVldPub(cPbV, cPbF)
Local oModel	:= FWModelActive()
Local oModelCO1	:= oModel:GetModel("CO1MASTER")
Local nTotEdt	:= GCPSUMEDT()
Local aArea	:= GetArea()
Local aAreaCP0:= CP0->(GetArea())
Local lRet		:= .F.
Local cAutom	:= oModelCO1:GetValue('CO1_AUTO')

	If cAutom == '0'
		dbSelectArea("COD")
		dbSetorder(2)
		If dbSeek(xFilial("COD")+oModelCO1:GetValue("CO1_REGRA")+oModelCO1:GetValue("CO1_MODALI")+oModelCO1:GetValue("CO1_ESPECI"))
			If nTotEdt <= COD->COD_FXFIM
				lRet := !(MsgYesNo(STR0071,"GCPXPUBLI"))
				If lRet
					If CP0->(dbSeek(xFilial("CP0")+oModelCO1:GetValue("CO1_REGRA")+oModelCO1:GetValue("CO1_MODALI")+"PB"))
						cPbV := CP0->CP0_PROXIV
						cPbF := CP0->CP0_PROXIF	
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

RestArea(aAreaCP0)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} GCPXGerPed
Programa para gerar os pedidos de compra do Processo LicitatÛrio  

@author Leandro.Moura
@since 17/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function GCPXGerPed(cMsg)

Local aArea		:= GetArea()
Local aResiduos 	:= {}
Local aParam    	:= {}
Local aRetParam 	:= {}
Local aDados    	:= {}
Local aRatCTB		:= {}
Local aRatAux		:= {}
Local aCTBEnt		:= CTBEntArr()
Local cFileLog  	:= ""
Local cPath     	:= ""
Local cCondPag  	:= ""
Local cTes      	:= ""
Local cFornec   	:= ""
Local cLoja     	:= ""
Local cCodpro   	:= ""
Local cLote		:= ""
Local cCodEdt   	:= ""
Local cNumProc  	:= ""
Local cFilEnt		:= ""
Local cQuebra   	:= ""
Local cNumPed   	:= ""
Local cPedidos  	:= ""
Local cNumSC 		:= ""
Local cItemSC 	:= ""
Local cFilBkp		:= cFilAnt
Local cFilPC		:= xFilial("SC7")
Local cCadastro 	:= STR0034 //-- Pedido de Compra
Local cSep      	:= STR0035 //-- Pedidos de Compra Gerados:
Local cObs      	:= STR0036+Alltrim(CO1->CO1_CODEDT) //-- Ref. Processo LicitatÛrio
Local nItem		:= 1
Local nCampos		:= 0
Local nQuant    	:= 0
Local nVlUnit   	:= 0
Local nX			:= 0
Local nY			:= 0
Local lRet      	:= .F.                               
Local cTpCto  	:= ''
Local cQuery 		:= ""
Local nIndxItens	:= 1
Local cAliasNw 	:= "TRB_SC1"
Local lRatItens	:= SuperGetMV("MV_GCPRATP",.F.,.F.)	//-- Rateio do pedido por Processo LicitatÛrio
Local cMVGCPFiAP	:= SuperGetMV("MV_GCPFIAP",.F.,"C")		//-- Filial que administrara o pedido de compra
Local cGCPFiAP	:= ""
Local aPedAux		:= {} 
Local aPedCom		:= {} 
Local nPosPC		:= 0
Local lHlpSld		:= .T.
Local aAreaCO3	:= CO3->(GetArea())
Local dDtEntreg	:= CTOD("  /  /  ")
Local oModelNEP	:= Nil
Local oModel		:= FWModelActive()
Local nGravou		:= 0
Local cForNE		:= ""
Local aDadosEdt	:= {}
Local lNotaEmp	:= SuperGetMV("MV_NOTAEMP",.F.,.F.)
Local lGCP011PED	:= ExistBlock("GCP011PED")
Local cNotEmp		:= ""
Local cItemEm		:= ""
Local lLote		:= (CO1->CO1_AVAL == '2')
Local cQryEmp		:= ""
Local lSaiEmp		:= .F.
Local cAlsEmp		:= ""
Local lAtaCtrt	:= .F.
Local cNAta		:= ""
Local nVlUnitA	:= 0
Local cCodProd	:= ""
Local lAuto		:= IsBlind()
Local lIsInTran := InTransaction()
Local cNum			:= ""
Local cNumOld		:= ""

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

If	CO1->CO1_COPC == "1"
	//"Este Processo LicitatÛrio originou a geraÁ„o de um Contrato, e n„o pode ser substituido para uma PC"
	If !lAuto
		MsgAlert(STR0037) 
	EndIf
	lRet := .F.
Else
	lRet := .T.
EndIf

//-- VerificaÁ„o de geraÁ„o de nota de empenho
If lNotaEmp .And. GCPSCED(CO1->CO1_CODEDT,CO1->CO1_NUMPRO)
	CP4->(DbSetOrder(1))
	If (CP4->(DbSeek(cSeek:=xFilial("CP4")+CO1->CO1_CODEDT+CO1->CO1_NUMPRO)) ) 
		While CP4->(CP4->CP4_FILIAL+CP4->CP4_CODEDT+CP4->CP4_NUMPRO==cSeek)
			If CP4->CP4_EMPENH == .F.
				lRet := .F.
				@cMsg := "Existem SolicitaÁıes n„o empenhadas neste processo licitatÛrio. Favor gerar Nota de Empenho."
				Exit
			EndIf
			CP4->(DbSkip())
		EndDo
	EndIf
EndIf 

If	lRet
	//-- Retorna array com os fornecedores e dados dos pedidos a gerar
	If lAuto
		aDados := GCPXPedCV() 
	Else
		MsgRun(STR0038,,{|| aDados := GCPXPedCV()}) //"Verificando ganhadores..."
	EndIf	 

	If	Len(aDados) == 0
		lRet := .F.
	Endif	
EndIf

If	lRet
	//-- Solicita condicao de pagamento e tes para geracao do pedido de compra
	aPedCom := {}
	For nX := 1 To Len(aDados)
		lRet := .T.
		cFilEnt := xFilial("SC7",If(Empty(aDados[nX,14]),cFilAnt,aDados[nX,14]))
		//-- Formato do vetor aPedAux
		//-- [01] = Fornecedor
		//-- [02] = Loja
		//-- [03] = Filial de Entrega
		//-- [04] = Condicao de Pagamento
		//-- [05] = TES
		nPosPC := ASCan(aPedAux,{|x| x[1]+x[2]+x[3]==aDados[nX,1]+aDados[nX,2]+cFilEnt })
		
		If	nPosPC > 0
			cCondPag := aPedAux[nPosPC,4]
			cTes     := aPedAux[nPosPC,5]
		Else
					
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Busca cond. pgto do fornecedor≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			SA2->(dbSetOrder(1))
			If !Empty(aDados[nX,19])
				cCondPag := aDados[nX,19]
			
			ElseIf SA2->( dbSeek( xFilial("SA2")+aDados[nX,1]+aDados[nX,2]) ) .AND. !Empty(SA2->A2_COND)

				cCondPag := SA2->A2_COND
				AAdd(aPedAux,{aDados[nX,1],aDados[nX,2],cFilEnt,cCondPag,cTes})

			Else
		        lRet := .F.
		        //"Deve ser cadastrada uma condicao de pagamento para o fornecedor ganhador. O pedido n„o ser· gerado."
		        If !lAuto
		        	MsgAlert(STR0043) 
		        EndIf
			EndIf
			
		EndIf
		
		If	lRet
			AAdd(aPedCom,{cCondPag,cTes})
		Else
			Exit
		EndIf
		
	Next

EndIf

//Verifica se È processo remanescente, busca o saldo do pedido de venda
If	lRet .And. CO1->CO1_REMAN        
	aResiduos := GCPLimpRes(CO1->CO1_COPC,aDados)
	lRet      := Iif(Empty(aResiduos),.F.,aResiduos[1,1])
EndIf

If	!lRet .And. CO1->CO1_COPC == "2" .And. lHlpSld
    //MsgAlert(STR0042)						//"Existe Pedido de Compra em aberto, dever· encerra-lo para gerar o remanescente"
	lRet := .F.
EndIf

DbSelectArea('CO3')
CO3->(DbSetOrder(1))
CO3->(DbGoTop())

//-- gera pedido para os primeiros colocados de cada produto
If	lRet .And. (CO1->CO1_COPC == "2" .Or. CO1->CO1_COPC == "3" .Or. CO1->CO1_COPC == " ")

	Begin Transaction

	For nX := 1 To Len(aDados)			
		cFornec := aDados[nX,1]
		cLoja   := aDados[nX,2]
		cCodpro := aDados[nX,3]
		cLote	 := aDados[nX,15]
		nQuant  := aDados[nX,4]
		nVlUnit := aDados[nX,5]
		cCodEdt := aDados[nX,6]
		cNumProc:= aDados[nX,7]    
		cFilEnt := xFilial("SC7",If(Empty(aDados[nX,14]),cFilAnt,aDados[nX,14]))
		cCondPag:= aPedCom[nX,1]
		cTes	:= aPedCom[nX,2]
			
		If nGravou == 0	
	    	// Posiciona no Processo LicitatÛrio
			CO1->(dbSetOrder(1))
			CO1->(MsSeek(xFilial("CO1")+cCodEdt+cNumProc))					
	
			If (cGCPFiAP := cMVGCPFiAP) == "E"
				cFilPC := xFilial("SC7",cFilEnt)
			EndIf
				
			// Posiciona no Produto
			SB1->(dbSetOrder(1))
			If !SB1->(MsSeek(xFilial("SB1",cFilPC)+cCodPro))
				cGCPFiAP := "C"
			EndIf
		
			// Posiciona no SA2
			SA2->(dbSetOrder(1))
			If !SA2->(MsSeek(xFilial("SA2",cFilPC)+cFornec+cLoja))
				cGCPFiAP := "C"
			EndIf
			
			// Posiciona no particante
			dDtEntreg	:= CTOD("  /  /  ")
			If CO3->(MsSeek(xFilial('CO3')+cCodEdt+cNumProc+cCodPro+'2'+cFornec+cLoja))
				dDtEntreg	:= CO3->CO3_PRZENT
			Elseif CO3->(MsSeek(xFilial('CO3')+cCodEdt+cNumProc+cCodPro))
				While CO3->(!Eof()) .And. ;
				xFilial('CO3')+cCodEdt+cNumProc+cCodPro == CO3_FILIAL+CO3_CODEDT+CO3_NUMPRO+CO3_CODPRO
					If CO3->(CO3_TIPO) == '1' .And. Posicione('CO6',1,xFilial('CO6')+CO3->CO3_CODIGO+CO3->CO3_LOJA,'CO6_FORNEC') == cFornec
						dDtEntreg	:= CO3->CO3_PRZENT
						Exit
					Endif
					CO3->(dbSkip())
				EndDo
			Endif

			//Posiciona Nota de empenho
			CX0->(dbSetOrder(3))//CX0_FILIAL+CX0_CODFOR+CX0_LOJFOR+CX0_CODEDT+CX0_NUMPRO+CX0_NUMATA
			If CX0->( MsSeek( xFilial("CX0") + cFornec + cLoja + cCodEdt + cNumProc ) )
				//Popula as vari·veis conforme o padr„o, mas agora tambÈm efetua uma busca por cancelamentos
				cCodProd := IIF(CO1->CO1_AVAL == '1', CO3->CO3_CODPRO, CP6->CP6_CODPRO)
				CX1->(dbSetOrder(1))
				If CX1->(MsSeek(xFilial("CX0")+CX0->CX0_CODNE+cCodProd))
					cNotEmp := CX0->CX0_CODNE
					cItemEm := CX1->CX1_ITEM
				EndIf

				cAlsEmp := Alias()

				//Pesquisa cancelamentos da nota de empenho
				While !CX0->( Eof() ) .And. CX0->( CX0_FILIAL + CX0_CODFOR + CX0_LOJFOR + CX0_CODEDT + CX0_NUMPRO ) == xFilial("CX0") + cFornec + cLoja + cCodEdt + cNumProc
					cQryEmp := GetNextAlias()

					BeginSQL Alias cQryEmp
						SELECT CX0_CODNE
						  FROM %Table:CX0%
						 WHERE CX0_FILIAL = %xFilial:CX0%
						   AND CX0_CODFOR = %Exp:cFornec%
						   AND CX0_LOJFOR = %Exp:cLoja%
						   AND CX0_CODEDT = %Exp:cCodEdt%
						   AND CX0_CODORI = %Exp:CX0->CX0_CODNE%
						   AND CX0_ESTORN = 'F'
						   AND %NotDel% 
					EndSql

					//Se vazio, n„o possui cancelamento 
					If (cQryEmp)->( Eof() ) .And. Empty( CX0->CX0_CODORI )//Quando preenchido È um cancelamento
						CX1->(dbSetOrder(1))
						If CX1->(MsSeek(xFilial("CX0")+CX0->CX0_CODNE+cCodProd))
							cNotEmp := CX0->CX0_CODNE
							cItemEm := CX1->CX1_ITEM
							lSaiEmp := .T.
						EndIf
					EndIf

					If Select( cQryEmp ) > 0
						(cQryEmp)->( dbCloseArea() )
					EndIf

					//Se n„o encontrou cancelamento, sai do loop
					If lSaiEmp
						Exit
					Else
						CX0->( dbSkip() )
					EndIf
				EndDo

				If !Empty( cAlsEmp )
					dbSelectArea( cAlsEmp )
				EndIf
			EndIf
			
			// Verifica se ha data de entrega do participante
			dDtEntreg := Iif(!Empty(dDtEntreg),dDtEntreg,dDataBase)
				
			If cGCPFiAP == "C"
				cFilPC := xFilial("SC7")
			EndIf
		
			If cFilPC+cFornec+cLoja+cFilEnt <> cQuebra
				cQuebra := cFilPC+cFornec+cLoja+cFilEnt
					
				//-- Se filial administradora do PC for a solicitante, troca filial
				If cGCPFiAP == "E" .And. PadR(cFilAnt,Len(AllTrim(cFilEnt))) # AllTrim(cFilEnt)
					SM0->(dbSetOrder(1))
					SM0->(dbSeek(cEmpAnt+AllTrim(cFilEnt)))
					cFilAnt := FWCodFil()
				EndIf			
				
				//-- Preenche cabecalho
				aCab    := {}
		
				AAdd(aCab,{"C7_EMISSAO", dDataBase			,NIL})
				AAdd(aCab,{"C7_FORNECE", cFornec   			,NIL})
				AAdd(aCab,{"C7_LOJA"   , cLoja      		,NIL})
				AAdd(aCab,{"C7_CONTATO", SA2->A2_CONTATO	,NIL})
				AAdd(aCab,{"C7_COND"   , cCondPag   		,NIL})
				AAdd(aCab,{"C7_FILENT" , cFilEnt     		,NIL})
			
				aItens := {}
				aRatCTB	:= {}
		    Endif
		    	
			cC7Item := StrZero(nItem,TamSX3("C7_ITEM")[1])
	
			//Verifica se È processo remanescente, busca o saldo do pedido de compra  
			If CO1->CO1_REMAN
				nPos := aScan(aResiduos,{|x| x[2] == cCodPro .And. If(!Empty(aDados[nX,12]),x[4] == aDados[nX,12]+aDados[nX,13],.T.)})
				If Empty(nPos) //-- Se nao tem saldo para remanescente, pula
					nQuant := 0
				Else
					nQuant := aResiduos[nPos,3]
				EndIf
			EndIf			
			
			//-- fazendo manutenÁ„o de um pedido gerado pela ata mediante um REMANESCENTE.
			CPH->(dbSetOrder(1))
			If CPH->(dbSeek(xFilial("CPH")+cCodEdt+cNumProc))
				cNAta := CPH->CPH_NUMATA
				CPY->(dbSetOrder(1))
				If CPY->(dbSeek(xFilial("CPY")+cNAta+cCodpro))
					nVlUnitA := CPY->CPY_VALATU
					lAtaCtrt := .T.
				EndIf
			EndIf
			
			If	nQuant > 0
				//-- Preenche itens
				aAdd(aItens,{})
				aAdd(aTail(aItens), {"C7_ITEM"			,cC7Item  				,Nil} ) 
				aAdd(aTail(aItens), {"C7_PRODUTO"		,cCodPro				,Nil} )
				aAdd(aTail(aItens), {"C7_FISCORI"		,IIF(Empty(aDados[nX,12]), cFilAnt, cFilBkp),Nil} )
				aAdd(aTail(aItens), {"C7_NUMSC"			,aDados[nX,12]			,Nil} )
				aAdd(aTail(aItens), {"C7_ITEMSC"		,aDados[nX,13]			,Nil} )
				aAdd(aTail(aItens), {"C7_QUANT"			,nQuant					,Nil} ) 
				If !lAtaCtrt
					aAdd(aTail(aItens), {"C7_PRECO"			,nVlUnit			,Nil} ) 
				Else
					aAdd(aTail(aItens), {"C7_PRECO"			,nVlUnitA			,Nil} )
				EndIf
				aAdd(aTail(aItens), {"C7_DATPRF"		,dDtEntreg				,Nil} ) 
				aAdd(aTail(aItens), {"C7_TES"			,cTes					,Nil} ) 
				aAdd(aTail(aItens), {"C7_FLUXO"			,"S"					,Nil} ) 
				aAdd(aTail(aItens), {"C7_OBS"			,cObs					,Nil} ) 
				aAdd(aTail(aItens), {"C7_LOCAL"			,SB1->B1_LOCPAD			,Nil} ) 
				aAdd(aTail(aItens), {"C7_CODED"			,cCodEdt				,Nil} )	
				aAdd(aTail(aItens), {"C7_NUMPR" 		,cNumProc				,Nil} ) 
				aAdd(aTail(aItens), {"C7_CC"			,aDados[nX,8]			,Nil} )
				aAdd(aTail(aItens), {"C7_CONTA"			,aDados[nX,9]			,Nil} )
				aAdd(aTail(aItens), {"C7_ITEMCTA"		,aDados[nX,10]			,Nil} )
				aAdd(aTail(aItens), {"C7_CLVL"			,aDados[nX,11]			,Nil} )
				aAdd(aTail(aItens), {"C7_GCPLT"			,cLote					,Nil} )
				aAdd(aTail(aItens), {"C7_FILEDT"		,cFilBkp				,Nil} )
				If A400GetIt(cNotEmp,cCodPro)
					aAdd(aTail(aItens), {"C7_CODNE"		,cNotEmp			,Nil} )
					cItemEm := Posicione( "CX1", 1, xFilial( "CX1" )+cNotEmp+cCodPro, "CX1_ITEM" )
					aAdd(aTail(aItens), {"C7_ITEMNE"	,cItemEm			,Nil} )
				EndIf
				For nY := 1 To Len(aCTBEnt)
					If Len(aDados[nX])>15 .And. SC7->(FieldPos("C7_EC" +aCTBEnt[nY] +"CR")) > 0 
						aAdd(aTail(aItens),{"C7_EC"+aCTBEnt[nY]+"CR", aDados[nX,18 + (nY * 2)],Nil})
						aAdd(aTail(aItens),{"C7_EC"+aCTBEnt[nY]+"DB", aDados[nX,19 + (nY * 2)],Nil})   
					EndIf
				Next nY
				
				If lRatItens .And. Len(aDados[nX]) > 7 .And. !Empty(aRatAux := GCPA011RAT(cC7Item,cCodPro))
					aTail(aItens)[aScan(aTail(aItens),{|x| x[1] == "C7_CC"}),2] := CriaVar("C7_CC",.F.)
					aAdd(aRatCTB,{cC7Item,aRatAux})
				EndIf
				
				nItem	+= 1
			EndIf
				
			//-- Se ainda a itens a gerar, avalia a quebra de acordo com a filial de adm do pedido
			If nX < Len(aDados)
				If (cGCPFiAP := cMVGCPFiAP) == "E"
					cFilPC := xFilial("SC7",If(Empty(aDados[nX+1,14]),cFilAnt,aDados[nX+1,14]))
				EndIf
					
				// Posiciona no Produto
				SB1->(dbSetOrder(1))
				If !SB1->(MsSeek(xFilial("SB1",cFilPC)+aDados[nX+1,3]))
					cGCPFiAP := "C"
				EndIf
			
				// Posiciona no SA2
				SA2->(dbSetOrder(1))
				If !SA2->(MsSeek(xFilial("SA2",cFilPC)+aDados[nX+1,1]+aDados[nX+1,2]))
					cGCPFiAP := "C"
				EndIf
					
				If cGCPFiAP == "C"
					cFilPC := xFilial("SC7",cFilBkp)
				EndIf
			EndIf
			
			If nX == Len(aDados) .Or. cFilPC+aDados[nX+1,1]+aDados[nX+1,2]+xFilial("SC7",If(Empty(aDados[nX+1,14]),cFilAnt,aDados[nX+1,14])) <> cQuebra
				If cGCPFiAP == "E" .And. Substr(cQuebra,1,FwSizeFilial()) # cFilAnt
					SM0->(dbSetOrder(1))
					SM0->(dbSeek(cEmpAnt+AllTrim(Substr(cQuebra,1,FwSizeFilial()))))
					cFilAnt := FWCodFil()
				EndIf
				nItem	:= 1                                       
		        //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		        //≥ Ponto de entrada para tratamento de campos ≥
	    	    //≥ especificos na geracao do pedido de compra ≥
	        	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		        If	lGCP011PED
		            aRet := ExecBlock("GCP011PED",.f.,.f.,{aCab,aItens,aRatCTB})    
					If	Valtype(aRet) == "A"
						aCab := aRet[1]
						aItens := aRet[2]
						aRatCTB := aRet[3]
					EndIf
		        EndIf				
				lMsErroAuto := .F.
				lMsHelpAuto := .T.
				
				If lAuto
					MSExecAuto({|v,x,y,z,w,a| MATA120(v,x,y,z,w,a)},1,aCab,aItens,3,.F.,aRatCTB) //"Gerando Pedido de Compra"
				Else
					MsgRun(STR0044,, {||MSExecAuto({|v,x,y,z,w,a| MATA120(v,x,y,z,w,a)},1,aCab,aItens,3,.F.,aRatCTB)}) //"Gerando Pedido de Compra"
			    EndIf
			      
				If lNotaEmp
					oModel:Activate()	
				EndIf
				
				If lMsErroAuto
					DisarmTransaction()
					lMsErroAuto := .F.
					lRet := .F.
					Exit
				Else
					cPedidos += cSep + cNumPed
					cSep := ","	
				Endif
				
				If lRet .And. CO1->CO1_SRP == "1" .And. CO1->CO1_REMAN
					cNum := SC7->C7_NUM	
					CPE->(dbSetOrder(1))
					If CPE->(dbSeek(xFilial('CPE')+CPH->CPH_CODORG+CPI->CPI_TIPO+CPI->CPI_CODEDT+CPI->CPI_NUMPRO))
						While CPE->( !Eof()) .And. CPE->CPE_OK .And. (CPE->(CPE_CODEDT+CPE_NUMPRO) == CPI->(CPI_CODEDT+CPI_NUMPRO))
							If CPE->CPE_TIPDOC == '2' .And. Rtrim(CPE->CPE_DOCMOV) == cNumOld
								RecLock("CPE",.F.)
								CPE->CPE_DOCMOV := cNum
								CPE->(MsUnLock())
							EndIf
							CPE->(dbSkip())
						End	
					EndIf
					SC7->(dbSetOrder(1))	
					If SC7->(dbSeek(xFilial('SC7')+cNum))
						While SC7->(EOF()) .And. SC7->C7_NUM == cNum
							RecLock("SC7",.F.)
							SC7->C7_OBS := CPH->CPH_CODORG
							SC7->(MsUnlock())
							SC7->(dbSkip())
						End
					EndIf						
					If SC7->(dbSeek(xFilial('SC7')+cNumOld))
						While SC7->(EOF()) .And. SC7->C7_NUM == cNumOld
							RecLock("SC7",.F.)
							SC7->C7_RESIDUO := "S"
							SC7->(MsUnlock())
							SC7->(dbSkip())
						End
					EndIf
				EndIf
				
			EndIf
			//-- Restaura filial
			If cFilAnt # cFilBkp
				SM0->(dbSetOrder(1))
				SM0->(dbSeek(cEmpAnt+cFilBkp))
				cFilAnt := FWCodFil()
			EndIf
		Else
			lRet := .F.
			DisarmTransaction()
			Exit
		EndIf
	Next nX

	End Transaction
	
EndIf

cFileLog := NomeAutoLog()

If !Empty(cFileLog) .And. !lRet
	If !lAuto
		MostraErro(cPath,cFileLog)
	EndIf
	Help(" ",1,"GCP11EDT")//"N„o foi possÌvel gerar o pedido para o Processo LicitatÛrio "
Endif

RestArea(aAreaCO3)
RestArea(aArea)

Return({lRet,cPedidos})

function aR()

Return aRetorno

//-------------------------------------------------------------------
/*{Protheus.doc} GCPXGerCt
Programa para gerar os contratos do processo licitatÛrio  

@author Leandro.Moura
@since 17/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function GCPXGerCt(oModel, cMsg)

Local aParam    	:= {}
Local aRet      	:= {}
Local aDados    	:= {}
Local aLogReg   	:= {}
Local aNumCtr		:= {}
Local aArea			:= GetArea()
Local aAreaSM0		:= SM0->(GetArea())
Local aCTBEnt   	:= CTBEntArr()
Local aLoteProc		:= {}
Local aCtrRev  		:= {}
Local aArea2 		:= {}
Local cTit1			:= ""
Local cQuebra   	:= ""
Local cPartic   	:= ""
Local cLoja     	:= ""
Local cCodProLt  	:= ""
Local cCodEdt   	:= ""
Local cNumProc  	:= ""
Local cContrato 	:= ""
Local cNumContr 	:= ""
Local cCondPgto 	:= ""
Local cItemCto		:= ""
Local cFilEnt		:= ""
Local cFilBkp		:= cFilAnt
Local cAcao  	  	:= "1"
Local cFilSC1		:= xFilial("SC1")
Local lRet   	  	:= .T.
Local lEncontrou 	:= .T.
Local lHlpSld  		:= .T.
Local nQuant    	:= 0
Local nVlUnit   	:= 0
Local nY        	:= 0
Local nX        	:= 0
Local nPosNCtr  	:= 0
Local cRemAdt		:= SuperGetMV("MV_REMADT",.F.,"")
Local lAuto			:= IsBlind()
Local cLoteAnt		:= ""
Local lLote 		:= (CO1->CO1_AVAL == '2')
Local oModel300 	:= Nil
Local oModelCN9		:= Nil
Local oModelCNA		:= Nil
Local oModelCNB		:= Nil

Static aRetorno 	:= {}

Private lRevisad 	:= .F.
Private nRevRtp		:= 0
Private aHdFor		:= {}
Private aItFor		:= {}
Private cContra		:= ""

Default cMsg 		:= ""

If	lRet
	//-- chama funcao para criar os fornecedores a partir dos participantes. Retorna array com os fornecedores
	If lAuto
		aDados := GCPXPedCV()
	Else
		MsgRun(STR0057,,{|| aDados := GCPXPedCV()})
	EndIf	

	If	Len(aDados) == 0
		lRet := .F.
	Endif	
EndIf

If	lRet
	//Abertura das Tabelas de Contrato
	DbSelectArea("CN9")
	DbSetOrder(1)
	
	DbSelectArea("CNA")
	DbSetOrder(1)
	                 
	DbSelectArea("CNB")
	DbSetOrder(1)
	
	DbSelectArea("CNC")
	DbSetOrder(1)
	
	DbSelectArea("CNN")
	DbSetOrder(1)

EndIf


//Verifica se È processo remanescente, busca o saldo do contrato
If lRet .And. CO1->CO1_REMAN        
	aRetorno := GCPLimpRes(CO1->CO1_COPC,aDados)
	lRet     := Iif(Empty(aRetorno),.F.,aRetorno[1,1])
	If !lRet .And. CO1->CO1_COPC == "1" .And. lHlpSld
		If !lAuto
			MsgAlert(STR0073)
		EndIf
	EndIf	
EndIf	

If lRet .And. CO1->CO1_REMAN .And. Empty(cRemAdt)
	Help(' ',1,'GCPREMADT',,"Informe o tipo de revis„o de aditivo por decrÈscimo, que dever· ser utilizada no processo de remanescente, atravÈs do par‚metro MV_REMADT.",4,0)
	lRet := .F.
Else
	CN0->(DbSetOrder(1))
	If CN0->(DbSeek(xFilial("CN0")+cRemAdt))
		If (CN0->CN0_TIPO <> '1' .OR. (CN0->CN0_TIPO = '1' .AND. CN0->CN0_MODO <> '2'))   
			Help(' ',1,'GCPREMADT',,"Informe o tipo de revis„o de aditivo por decrÈscimo , que dever· ser utilizada no processo de remanescente, atravÈs do par‚metro MV_REMADT.",4,0)
			lRet := .F.
		EndIf
	EndIf
EndIf

If lRet .And. (CO1->CO1_COPC == "1" .Or. CO1->CO1_COPC == " " .Or. CO1->CO1_COPC == "3")
	
	Begin Transaction
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Informa que esta incluindo um contrato≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	INCLUI := .T.
	
	For nY := 1 To Len(aDados)
		
		cPartic 	:= aDados[nY,1]
		cLoja   	:= aDados[nY,2]
		cCodProLt 	:= If(lLote, aDados[nY,15], aDados[nY,3])
		nQuant    	:= aDados[nY,4]
		nVlUnit	:= aDados[nY,5]
		cCodEdt	:= aDados[nY,6]
		cNumProc	:= aDados[nY,7]
		//cLote		:= aDados[nY,8]
		
		//Verificar se a aÁ„o È 1 ou 4 e se o lote È o mesmo ainda
		If lLote .And. (cLoteAnt == cCodProLt)  
			Loop
		Else
			cLoteAnt := cCodProLt 	
		EndIf
	
		//Verifica se È processo remanescente, busca o saldo do contrato
		If CO1->CO1_REMAN
			If lLote
				nPosNCtr := aScan(aRetorno,{|x| x[8] == cCodProLt .And. If(!Empty(aDados[nY,12]),x[4] == aDados[nY,12]+aDados[nY,13],.T.)})
			Else
				nPosNCtr := aScan(aRetorno,{|x| x[2] == cCodProLt .And. If(!Empty(aDados[nY,12]),x[4] == aDados[nY,12]+aDados[nY,13],.T.)})
			EndIf
			If Empty(nPosNCtr) .Or. Empty(aRetorno[nPosNCtr,3]) //-- Se nao tem saldo para remanescente, pula
				nQuant := 0
			Else
				nQuant := aRetorno[nPosNCtr,3]
			EndIf
			//-- 1. se remanescente de todos os produtos do contrato
			//-- se o contrato estiver em elaboracao - estorna o contrato atual e gera novo contrato
			//-- caso contrario                      - gera revisao de troca do fornecedor

			//-- 2. se remanescente parcial
			//-- se o contrato estiver em elaboracao - retira do contrato os produtos(CNB) marcados no remanescente e altera os valores direto no CN9 e CNA
			//-- caso contratio                      - gera revisao
			If	nQuant > 0
				CNB->(DbGoTo(aRetorno[nPosNCtr,5])) //RecNo da CNB
				
				
				CN9->(DbGoTo(aRetorno[nPosNCtr,7])) //RecNo da CN9
				//-- remanescente de todos os itens do contrato
				If	GCPXCTR(CNB->CNB_CONTRA,CNB->CNB_REVISA,CNB->CNB_NUMERO,aRetorno)
					If	aRetorno[nPosNCtr,6] == "02"			//-- Contrato em elaboracao
						cAcao := "1"	//-- estorna o contrato atual e gera novo contrato
					Else
						cAcao := "4"	//-- gera revisao de troca do fornecedor
					EndIf
				//-- remanescente parcial do contrato
				Else
					If	aRetorno[nPosNCtr,6] == "02"			//-- Contrato em elaboracao
						cAcao := "3"	//-- retira do contrato os produtos(CNB) marcados no remanescente e altera os valores direto no CN9 e CNA
					Else
						cAcao := "2"	//-- gera revisao e gera novo contrato
					EndIf
				EndIf

				//-- Estorna o contrato atual que esta em elaboracao e gera novo contrato
				If	cAcao=="1" .And. AScan(aCtrRev,{|x| x[1]+x[2]==CNB->CNB_CONTRA+CNB->CNB_REVISA})==0
					
					AAdd(aCtrRev,{CNB->CNB_CONTRA,CNB->CNB_REVISA})

					oModel300 := FWLoadModel('CNTA300')
					oModel300:SetOperation(5)
					
					CN9->(DbGoTo(aRetorno[nPosNCtr,7]))

					lRet := oModel300:Activate() 
					
					If lRet
						lRet := oModel300:VldData()
						If lRet 
							lRet := oModel300:CommitData()
						EndIf
					EndIf

				//-- gera revisao
				ElseIf	cAcao=="2" .And. AScan(aCtrRev,{|x| x[1]+x[2]==CNB->CNB_CONTRA+CNB->CNB_REVISA})==0
					
					//-- Posiociona no contrato
					CN9->(DbGoTo(aRetorno[nPosNCtr,7]))	
					
					//-- Seta revisao de aditivo
					A300STpRev("1")	
					
					//-- Carrega o modelo
					oModel300 := FWLoadModel('CNTA300')
					oModel300:SetOperation(MODEL_OPERATION_INSERT)
					
					lRet := oModel300:Activate(.T.)
					
					If lRet
						oModelCN9 := oModel300:GetModel('CN9MASTER')
						oModelCN9:SetValue('CN9_TIPREV'	, cRemAdt)
						oModelCN9:SetValue('CN9_JUSTIF'	,'Remanescente do processo licitatorio.')
						
						oModelCNB := oModel300:GetModel('CNBDETAIL')
						CNTA300BlMd(oModelCNB, .F.)
						
						For nX := 1 to oModelCNB:Length()
							oModelCNB:Goline(nX)
							lEncontrou := If(lLote, oModelCNB:GetValue('CNB_GCPLT') == cCodProLt, oModelCNB:GetValue('CNB_PRODUT') == cCodProLt)
							If lEncontrou
								If oModelCNB:GetValue('CNB_QTDMED') == 0
									lRet := oModelCNB:DeleteLine()
								Else
									lRet := oModelCNB:SetValue('CNB_QUANT',oModelCNB:GetValue('CNB_QTDMED'))
								EndIf
							EndIf
						Next nX
						
						If lRet 
							If oModel300:VldData() //-- Se n„o tiver cronogramas realiza a gravacao
								oModel300:CommitData()
							Else //-- Caso contrario, abre a tela de contratos para ajuste de cronogramas
								CNTA300BlMd(oModelCNB, .T.)
								If FwExecView('Revisao','CNTA300',OP_COPIA,,{||.T.},,,,,,,oModel300) <> 0
									lRet := .F.
								EndIf
							EndIf
						EndIF
					EndIf
					
				//-- Retira do contrato os produtos marcados no remanescente
				ElseIf	cAcao=="3"

					CN9->(DbGoTo(aRetorno[nPosNCtr,7]))

					oModel300 := FWLoadModel('CNTA300')
					oModel300:SetOperation(4)
					
					lRet := oModel300:Activate() 

					If lRet

						//deletar o produto - DeleteLine
						oModelCNA := oModel300:GetModel('CNADETAIL')
						oModelCNB := oModel300:GetModel('CNBDETAIL')
						CNTA300BlMd(oModelCNA, .F.)
						CNTA300BlMd(oModelCNB, .F.)
						
						For nX := 1 to oModelCNB:Length()
							oModelCNB:Goline(nX)
							lEncontrou := If(lLote, oModelCNB:GetValue('CNB_GCPLT') == cCodProLt, oModelCNB:GetValue('CNB_PRODUT') == cCodProLt)
							If lEncontrou
								lRet := oModelCNB:DeleteLine()
								If !lRet
									Exit
								EndIf
							EndIf
						Next nX
						
						If lRet
							If oModel300:VldData() //-- Se n„o tiver cronogramas realiza a gravacao
								oModel300:CommitData()
							Else //-- Caso contrario, abre a tela de contratos para ajuste de cronogramas
								CNTA300BlMd(oModelCNA, .T.)
								CNTA300BlMd(oModelCNB, .T.)
								If FwExecView('Alterar','CNTA300',MODEL_OPERATION_UPDATE,,{||.T.},,,,,,,oModel300) <> 0
									lRet := .F.
								EndIf
							EndIf
						EndIf
					EndIf
					
				//-- Marca o contrato como cancelado e gera outro
				ElseIf	cAcao=="4"
					
					CN9->(DbGoTo(aRetorno[nPosNCtr,7]))
					RecLock("CN9",.F.)
					CN9-> CN9_SITUAC:= '01'
					CN9->(MsUnLock())
					
				EndIf
				
				If !lRet
					If ValType(oModel300) == "O" .And. oModel300:HasErrorMessage()
						cMsg := oModel300:GetErrorMessage()[5] + " [" + oModel300:GetErrorMessage()[4] + "] - " + oModel300:GetErrorMessage()[6] 
					EndIf
					Exit
				EndIf
				
			EndIf
			
		EndIf	
	
	Next nY   
			
	//GeraÁ„o efetiva dos contratos
	If lRet
		If CO1->CO1_AVAL == '1'
			lRet := GCP200Ctrs(oModel)
		Else
			lRet := GCP201Ctrs(oModel)
		EndIf
	EndIf

	If ExistBlock("GCP13GRV")
		ExecBlock("GCP13GRV",.F.,.F.,{aLogReg})
	EndIf
	
	End Transaction
	
EndIf

RestArea(aArea)
Return({lRet,cContrato})

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPXCTR
Analisa o contrato para saber se o processo remanescente esta sendo realizado em todos os itens ou parcial

@author Alex Egydio
@since 06/05/2013
@version P11.80
/*/
//-------------------------------------------------------------------
Static Function GCPXCTR(cContrat,cRevisa,cPlanilha,aRetorno)
Local aAreaAnt := GetArea()
Local aAreaCNB := CNB->(GetArea())
Local cSeek    := ""
Local lRet := .T.

CNB->(DbSetOrder(1))
If	CNB->(DbSeek(cSeek:=xFilial("CNB")+cContrat+cRevisa+cPlanilha))
	While CNB->(CNB->CNB_FILIAL+CNB->CNB_CONTRA+CNB->CNB_REVISA+CNB->CNB_NUMERO==cSeek)
		//-- Nao achou o produto no vetor aretorno, entao esta fazendo o processo remanescente parcial do contrato
		If	AScan(aRetorno,{|x| x[2]==CNB->CNB_PRODUT})==0
			lRet := .F.
			Exit
		EndIf
		CNB->(DbSkip())
	EndDo
EndIf
RestArea(aAreaCNB)
RestArea(aAreaAnt)
Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} GCPXStaCO3
Altera o status da CO3 de acordo com o status no cadastro do 
fornecedor habilitado 

@author Flavio Lopes Rasta
@since 25/09/2013
@version P11.80
/*/
//-------------------------------------------------------------------
Function GCPXStaCO3(oModelCO3,lTotal)
Local aSaveLines	:= FWSaveRows()
Local nAux 		:= 0
Local cCodForn		:= ""
Local cLojForn		:= ""

Default lTotal := .T.

COR->(DbSetOrder(1))
For nAux := 1 To oModelCO3:Length()
	if lTotal
		oModelCO3:GoLine( nAux )
	EndIF
	If 	(oModelCO3:GetValue('CO3_STATUS') $ '1|5|6') // Habilitado  //Ganhador //Inabilitado
		cCodForn := oModelCO3:GetValue('CO3_CODIGO')
		cLojForn := oModelCO3:GetValue('CO3_LOJA')
		If !Empty(cCodForn)
			If COR->(DbSeek(xFilial("COR")+cCodForn+cLojForn))
				If COR->COR_STATUS == '3' 
					oModelCO3:LoadValue('CO3_STATUS','6')//Inabilitado
				ElseIf COR->COR_STATUS == '2' .And. oModelCO3:GetValue('CO3_STATUS') <> '5'
					oModelCO3:LoadValue('CO3_STATUS','1')//Habilitado
				Endif			
			Endif
		Endif
	Endif
	if !lTotal
		Exit
	EndIF		
Next

FWRestRows( aSaveLines )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExistAM(cCodEdt,cNumPro)
FunÁ„o que verifica se um processo licitatÛrio possui Analise de Mercado

@author guilherme.pimentel
@param cCodEdt Codigo do processo licitatÛrio
@param cNumPro Numero do processo
@return lRet Resultado da verificaÁ„o 
@since 30/09/2013
@version 1.0
/*/
//------------------------------------------------------------------

Function ExistAM(cCodEdt,cNumPro)
Local lRet

dbSelectArea("COM")
dbSetOrder(2)
dbGoTop()
lRet := COM->(DbSeek(xFilial("COM")+cCodEdt+cNumPro ) )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPXImport
Rotina de importaÁ„o genÈrica para rotinas MVC

@author Raphael F. Augustos
@since 30/09/2013
/*/
//-------------------------------------------------------------------
Class GCPXImport

DATA aField		//Utilizado para popular o ID do AddFields 
DATA aGrids		//Utilizado para popular o ID do AddGrid
DATA nOpetarion	//Tipo de operaÁ„o
DATA cModel		//Informar o nome MODEL
DATA cIDForm		//Informar os ID do Form (AddFields)
DATA aIDGrid		//Informa os IDS do GRID (AddGrid)
DATA oModel		//Objeto do MODEL
DATA lRet			//Status de processamento
DATA lMostraErro	//Indica de mostra erro na tela ou n„o
DATA lValidLine	//Se informado .T. a classe ira validar por linhas do contr·rio sÛ valida o modelo totalmente preenchido

METHOD New()
METHOD Import()
METHOD Commit()
EndClass

METHOD New( cModel , nOpetarion , cIDForm , aIDGrid ) CLASS GCPXImport
	::cModel		:= cModel 
	::cIDForm		:= cIDForm
	::aIDGrid		:= aIDGrid
	::nOpetarion	:= nOpetarion
	::aField		:= {}
	::aGrids		:= {}		
	::oModel		:= nil
	::lRet 		:= .T.
	::lMostraErro := .T.
	::lValidLine  := .T.
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Import
Efetua carga de dados no model
 
@author Raphael F. Augustos
@since 30/09/2013
/*/
//-------------------------------------------------------------------
METHOD Import( aField , aGrids )CLASS GCPXImport
Local nX 		:= 0
Local nY 		:= 0
Local nI 		:= 0
Local nPos 	:= 0
Local lRet 	:= .T.
Local aAux 	:= {}
Local oAux
Local oStruct

PARAMTYPE 0 VAR aField		AS ARRAY	OPTIONAL DEFAULT {}
PARAMTYPE 1 VAR aGrids		AS ARRAY	OPTIONAL DEFAULT {}

::lRet := .T.
::aField := aField
::aGrids := aGrids


::oModel := FWLoadModel( ::cModel )
::oModel:SetOperation( ::nOpetarion )
::oModel:Activate()

If !Empty(::cIDForm)
	oAux 		:= 	::oModel:GetModel( ::cIDForm )
	oStruct 	:=	oAux:GetStruct()
	aAux 		:= 	oStruct:GetFields()
	//------------------------------------------------------------------
	// Fields - Seta ID criado pelo Metodo AddFields
	//------------------------------------------------------------------
	For nX := 1 To Len(::aField)
		For nI := 1 To Len( ::aField[nX] )
			If ( nPos := aScan(aAux,{|x| AllTrim( x[3] )== AllTrim(::aField[nX][nI][1]) } ) ) > 0
				If !( lAux := ::oModel:SetValue( ::cIDForm, ::aField[nX][nI][1], ::aField[nX][nI][2] ) )
					::lRet := .F.
					Exit
				EndIf
			EndIf
		Next nI		
	Next nX

	//------------------------------------------------------------------
	// Grid - Seta ID criado pelo Metodo AddGrid
	//------------------------------------------------------------------
	If Len(::aIDGrid) > 0 .And. ::lRet
		//------------------------------------------------------------------
		// Modelo de dados - nY
		//------------------------------------------------------------------
		For nY := 1 To Len (::aIDGrid)
			oAux := ::oModel:GetModel( ::aIDGrid[nY] )
			oStruct := oAux:GetStruct()
			aAux := oStruct:GetFields()
			//------------------------------------------------------------------
			// aCols  - nX
			//------------------------------------------------------------------
			For nX := 1 To Len(::aGrids[nY])
				If nX > 1
					oAux:AddLine()
					oAux:GoLine(nX)
				EndIf
				//------------------------------------------------------------------
				// aHeader - Ni
				//------------------------------------------------------------------				
				For nI := 1 To Len( aGrids[nY][nX] )
					If ( nPos := aScan(aAux,{|x| AllTrim( x[3] )== AllTrim(aGrids[nY][nX][nI][1]) } ) ) > 0
						If !( lAux := ::oModel:SetValue( ::aIDGrid[nY], aGrids[nY][nX][nI][1], aGrids[nY][nX][nI][2] ) )
							::lRet := .F.
							Exit
						EndIf
					EndIf
				Next nI
				If ::lValidLine .And. !oAux:VldData()
					::lRet := .F.
				 	Exit
				EndIf
			Next nX
		Next nY
	EndIf	
EndIf
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} Commit
Efetua o Commit no modelo de dados

@author Raphael F. Augustos
@since 30/09/2013
/*/
//-------------------------------------------------------------------
METHOD Commit( oAux ) CLASS GCPXImport
Local aErro	:= {}

If ::lRet
	If ( ::lRet := ::oModel:VldData() )
		::oModel:CommitData()
	EndIf
EndIf	

If !::lRet
	aErro := ::oModel:GetErrorMessage()	
	AutoGrLog( "Id do formul·rio de origem:" + ' [' + AllToChar( aErro[1] ) + ']' )
	AutoGrLog( "Id do campo de origem: " + ' [' + AllToChar( aErro[2] ) + ']' )
	AutoGrLog( "Id do formul·rio de erro: " + ' [' + AllToChar( aErro[3] ) + ']' )
	AutoGrLog( "Id do campo de erro: " + ' [' + AllToChar( aErro[4] ) + ']' )
	AutoGrLog( "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' )
	AutoGrLog( "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' )
	AutoGrLog( "Mensagem da soluÁ„o: " + ' [' + AllToChar( aErro[7] ) + ']' )
	AutoGrLog( "Valor atribuÌdo: " + ' [' + AllToChar( aErro[8] ) + ']' )
	AutoGrLog( "Valor anterior: " + ' [' + AllToChar( aErro[9] ) + ']' )
	If ::lMostraErro 
		MostraErro()
	EndIf
EndIf
::oModel:DeActivate()		
Return ::lRet

//

Function GCPXPedCV(lAta,aRecNoCPE,cFilOrig,cFilEnt)
Local aRet 		:= {}
Local aParticip := {}
Local aGCP9QRY	:= {}
Local cQuery  	:= ""
Local cFornec 	:= ""
Local cLoja   	:= ""
Local nGCP9QTD	:= 0
Local nPos    	:= 0
Local nX	  	:= 0
Local aCTBEnt 	:= CtbEntArr()
Local oDlg		:= NIL
Local oLbx		:= NIL
Local lGCP9QRY  := Existblock('GCP9QRY')
Local lGCP9QTD	:= Existblock('GCP9QTD')
Local lRatItens	:= .F.  //-- Grava dados contabeis do pedido como rateio (SCH)
Local lLote := (CO1->CO1_AVAL == '2')
Local cXFilial := "" 
Local nQtd25	:= 0
Local nQtd75	:= 0 
Local lContinua := .F.
Local cItem     := ""
Local lItensAlgu := SuperGetMV("MV_GCPAGL",.F.,.F.)
Local cAliasSC1 := GetNextAlias()
Local cAliasTMP := GetNextAlias()
Default lAta := .F.
Default aRecNoCPE := {}
Default cFilOrig := cFilAnt
Default cFilEnt := cFilAnt

cXFilial := xFilial("SC1",cFilOrig)

BeginSQL Alias cAliasSC1
	SELECT COUNT(*) AS USARAT
	FROM %Table:SC1% SC1
	WHERE SC1.%NotDel% AND
		SC1.C1_FILIAL = %Exp:cXFilial% AND
		SC1.C1_CODED = %Exp:CO1->CO1_CODEDT% AND
		SC1.C1_NUMPR = %Exp:CO1->CO1_NUMPRO% AND
		SC1.C1_FILIAL <> SC1.C1_FILENT
EndSQL

//-- Caso o processo licitatÛrio seja de compra compartilhada,
//-- desabilita a utilizacao do rateio por item do pedido (SCH)
lRatItens := SuperGetMV("MV_GCPRATP",.F.,.F.) .And. Empty((cAliasSC1)->USARAT)
(cAliasSC1)->(dbCloseArea())

If !lAta
	GCPXEdital(@cQuery,aCTBEnt,aGCP9QRY,lGCP9QRY,lRatItens,lLote)
Else
	GCPXAta(@cQuery,aCTBEnt,aGCP9QRY,lGCP9QRY,lRatItens,aRecNoCPE,cFilOrig,cFilEnt)
EndIf

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP)

While !((cAliasTMP)->(Eof()))
	
	If CO2->CO2_PARTEX <> "3"
		lContinua := Ascan(aRet,{|a| a[3] == (cAliasTMP)->CODPRO} ) == 0 .Or. (Ascan(aRet,{|a| a[12] == (cAliasTMP)->NUMSC} ) == 0 .Or. Ascan(aRet,{|a| a[13] == (cAliasTMP)->ITEM} ) == 0)
	Else
		If (cAliasTMP)->PERCEN = 75 .OR. (cAliasTMP)->PERCEN = 25 
			lContinua := .T.
		EndIf
	EndIf
	
	If lContinua
		cFornec := (cAliasTMP)->CODIGO
		cLoja   := (cAliasTMP)->LOJA
		
		aAdd(aRet,Array(19))
		 
		If lItensAlgu
			If !lAta
				cItem:= PadR(POSICIONE("SC1",8,xFilial("SC1")+(cAliasTMP)->CODEDT+(cAliasTMP)->NUMPROC +(cAliasTMP)->CODPRO+(cAliasTMP)->NUMSC, "C1_ITEM"),TamSX3("C1_ITEM")[1])
			Else
				cItem:= PadR(POSICIONE("SC1",8,xFilial("SC1")+(cAliasTMP)->CODEDT+(cAliasTMP)->NUMPRO +(cAliasTMP)->CODPRO+(cAliasTMP)->NUMSC, "C1_ITEM"),TamSX3("C1_ITEM")[1])
			EndIf
		Else
			cItem:= PadR((cAliasTMP)->ITEM,TamSX3("C1_ITEM")[1])
		EndIf
		  
		aTail(aRet)[1] := cFornec																							//-- 1. Codigo do fornecedor
		aTail(aRet)[2] := cLoja																								//-- 2. Loja do fornecedor
	    aTail(aRet)[3] := (cAliasTMP)->CODPRO
		//-- Ponto de entrada para manipulacao da quantidade
		If lGCP9QTD
			nGCP9QTD := Execblock('GCP9QTD',.F.,.F.,{cAliasTMP})
			aTail(aRet)[4] := If(ValType(nGCP9QTD) == "N" .And. nGCP9QTD > 0,nGCP9QTD,(cAliasTMP)->QUANT)
		Else
			If !lAta .And. !lLote .And. (cAliasTMP)->PERCEN > 0    
				nQtd25 := Int((cAliasTMP)->QUANT*0.25)
				nQtd75 := Int((cAliasTMP)->QUANT-nQtd25)                     
           
        		If (cAliasTMP)->PERCEN == 25
           			aTail(aRet)[4] := nQtd25 
           		ElseIf (cAliasTMP)->PERCEN == 75
           			aTail(aRet)[4] := nQtd75				           	           	
           		EndIf		
			Else		
				aTail(aRet)[4] := (cAliasTMP)->QUANT																					//-- 4. Quantidade
			EndIf
		
		EndIf
		aTail(aRet)[5] := (cAliasTMP)->VLUNIT							   															//-- 5. PreÁo unitario
		If !lAta
			aTail(aRet)[6] := (cAliasTMP)->CODEDT													  								//-- 6. Codigo do edital
			aTail(aRet)[7] := (cAliasTMP)->NUMPROC																				//-- 7. Numero do processo
		Else
			aTail(aRet)[6] := (cAliasTMP)->CODEDT													  								//-- 6. Codigo do edital
			aTail(aRet)[7] := (cAliasTMP)->NUMPRO
		EndIf		
		aTail(aRet)[8] := If(!lRatItens,(cAliasTMP)->CC,"")																		//-- 8. Centro de custo
		aTail(aRet)[9] := If(!lRatItens,(cAliasTMP)->CONTA,"")																	//-- 9. Conta contabil
		aTail(aRet)[10] := If(!lRatItens,(cAliasTMP)->ITEMCTA,"")																//-- 10. Item de conta
		aTail(aRet)[11] := If(!lRatItens,(cAliasTMP)->CLVL,"")																	//-- 11. Classe de valor
		aTail(aRet)[12] := If(!lRatItens .And. !Empty((cAliasTMP)->NUMSC),(cAliasTMP)->NUMSC,"")									//-- 12. Solicitacao
		aTail(aRet)[13] := If(!lRatItens .And. !Empty((cAliasTMP)->NUMSC),cItem,"")	//-- 13. Item
		aTail(aRet)[14] := (cAliasTMP)->FILENT																					//-- 14. Filial de Entrega
		If !lAta
			aTail(aRet)[15] := (cAliasTMP)->LOTE																					//-- 15. Lote
		EndIf	
		If lAta 
			aTail(aRet)[16] := (cAliasTMP)->CODNE																					//-- 16. CÛdigo da Nota de Empenho
			aTail(aRet)[17] := (cAliasTMP)->ITEMNE																				//-- 17. Item da Nota de Empenho	
			aTail(aRet)[18] := !Empty((cAliasTMP)->CODNE)																		//-- 18. Possui Nota de Empenho
			aTail(aRet)[19] := (cAliasTMP)->CONDPG																				//-- 19. CondiÁ„o de Pagamento 
		Else
			aTail(aRet)[19] := (cAliasTMP)->CONDPG																				//-- 19. CondiÁ„o de Pagamento 
		EndIf
		
		//-- Adiciona entidades contabeis
		For nPos := 1 To Len(aCTBEnt)
			aAdd(aTail(aRet),If(!lRatItens,(cAliasTMP)->&("EC"+aCTBEnt[nPos]+"CR"),""))
			aAdd(aTail(aRet),If(!lRatItens,(cAliasTMP)->&("EC"+aCTBEnt[nPos]+"DB"),""))
		Next nPos

	EndIf
	
	(cAliasTMP)->(dbSkip())
End

(cAliasTMP)->(DbCloseArea())
Return(aRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} GCPSUMEDT()
Calcula o valor total do processo licitatÛrio

@author alexandre.gimenez
@since 30/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function GCPSUMEDT()
Local nRet			:= 0
Local nX			:= 0
Local oModel 		:= FWModelActive()
Local lUsaLote	:= oModel:GetId() == 'GCPA201'
Local oModSum		:= IIF(lUsaLote,oModel:GetModel("CP3DETAIL"),oModel:GetModel("CO2DETAIL"))
Local aSaveLines	:= FWSaveRows()

For nX := 1 To oModSum:Length()
	oModSum:GoLine( nX )
	If	!oModSum:IsDeleted()
		If lUsaLote
			nRet += oModSum:GetValue("CP3_VLRTOT")
		Else
			nRet += oModSum:GetValue("CO2_VLESTI") * oModSum:GetValue("CO2_QUANT")
		EndIf
	EndIf
Next nX

FWRestRows(aSaveLines)
Return nRet

/*-------------------------------------------------------------------
{Protheus.doc} GCPSmartCL(cCodEdt,cNumPro,cRevisa,cEtapa,cChkLt,cChkIt,cDesc,cDescDe,lChkOk,cObriga,bCond,cPropri,cCondChk,cDpsLeg)
FunÁ„o para adicionar ou remover Check-List Inteligente

@author alexandre.gimenez
@since 08/10/2013
@version 1.0
-------------------------------------------------------------------*/
Function GCPSmartCL(cCodEdt,cNumPro,cRevisa,cEtapa,cChkLt,cChkIt,cDesc,cDescDe,lChkOk,cObriga,bCond,cPropri,cCondChk,cDpsLeg)
Local lRet := .T.
Default bCond := {|| .T. }
Default cDescDe := "   "
Default cPropri := "1"
Default cCondChk:= ""
Default cDpsLeg	:= ""

COW->(DbSetOrder(1))
If	Eval(bCond)
	If	!(COW->(DbSeek(xFilial("COW")+cCodEdt+cNumPro+cRevisa+cEtapa+cChkLt+cChkIt)))
		RecLock("COW",.T.)
		COW->COW_FILIAL	:= xFilial("COW")
		COW->COW_CODEDT	:= cCodEdt
		COW->COW_NUMPRO	:= cNumPro
		COW->COW_REVISA	:= cRevisa
		COW->COW_ETAPA	:= cEtapa
		COW->COW_CHKLT	:= cChkLt
		COW->COW_CHKIT	:= cChkIt
		COW->COW_DESC	:= cDesc
		COW->COW_PROPRI	:= cPropri
		COW->COW_COND	:= cCondChk
		COW->COW_OBRIGA	:= cObriga
		COW->COW_DPSLEG	:= cDpsLeg
		COW->COW_CHKOK	:= lChkOk
		COW->COW_DESCDE	:= cDescDe
		COW->(MsUnLock())
	EndIf
Else
	If	COW->(DbSeek(xFilial("COW")+cCodEdt+cNumPro+cRevisa+cEtapa+cChkLt+cChkIt))
		RecLock("COW",.F.)
		COW->(dbDelete())
		COW->(MsUnLock())			
	EndIf
EndIf

Return lRet	

//-------------------------------------------------------------------
/*{Protheus.doc} GCPChkData
Valida se a data passada esta entre a data de abertura do processo licitatÛrio e a data de vigencia do processo licitatÛrio  

@author Alex Egydio
@since 10/10/2013
@version P11.90
*/
//-------------------------------------------------------------------
Function GCPChkData(dData,cDscEtp,cEtapa,dDtAber,cTpPraz,nPrazo,dDataVenc,lHelp)
Local lRet := .T.
DEFAULT cDscEtp := ""
DEFAULT dDataVenc:= CToD("")
DEFAULT lHelp	:= .T.

If	Empty(cDscEtp)
	cDscEtp:=AllTrim(Posicione("SX5",1,xFilial("SX5")+'LE'+cEtapa,"X5_DESCRI"))
EndIf

If	lHelp .And. !Empty( dData ) .And. DToS(dData) < DToS(dDtAber)
	Help("",1,"GCPXFUN01",,STR0049+cDscEtp+STR0050+DToc(dDtAber),4,1)//DATA//menor que a data de Abertura do Proc. LicitatÛrio:.                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
	lRet := .F.
EndIf

If	cTpPraz == "1"
	dDataVenc := dDtAber + nPrazo

	If	lHelp .And. DToS(dData) > DToS(dDataVenc)
		Help("",1,"GCPXFUN01",,STR0049+cDscEtp+STR0051+DToC(dDataVenc),4,1)//Data//maior que a data de VigÍncia do Proc. LicitatÛrio:.
		lRet := .F.
	EndIf
	
Else

	dDataVenc := MonthSum(dDtAber,nPrazo)
	
	If	lHelp .And. !Empty( dData ) .And. DToS(dData) > DToS(dDataVenc)
		Help("",1,"GCPXFUN01",,STR0049+cDscEtp+STR0051+DToC(dDataVenc),4,1)//Data//maior que a data de VigÍncia do Proc. LicitatÛrio:.
		lRet := .F.
	EndIf

EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPExistW(oModel)
ValidaÁ„o para verificar se existe ganhador no processo licitatÛrio

@author alexandre.gimenez	 
@since 15/10/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------
Function GCPExistW()
Local aSaveLines	:= FWSaveRows()
Local oModel 		:= FWModelActive()
Local lRet			:= .F.
Local lUsaLote	:= oModel:GetId() == 'GCPA201'  
Local nX			:= 0
Local nY			:= 0
Local oModCO3		:= oModel:GetModel('CO3DETAIL')
Local oModProd	:= IIF(lUsaLote,oModel:GetModel('CP3DETAIL'),oModel:GetModel('CO2DETAIL'))

//Buscar ganhador
For nX := 1 to oModProd:Length()
	oModProd:GoLine(nX)
	For nY := 1 to oModCO3:Length()
		oModCO3:GoLine(nY)
		If oModCO3:GetValue("CO3_STATUS") == '5'
			lRet := .T.
		Endif
		If lRet
			Exit
		EndIf
	Next nY
	If lRet
		Exit
	EndIf
Next nX					

If oModel:GetModel("CO1MASTER"):GetValue("CO1_ETAPA") $ "JP|NE"
	lRet := .F.
EndIf

FWRestRows( aSaveLines )

Return lRet

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ GCPLimpRes  ≥ Autor ≥      TOTVS            ≥ Data ≥28/06/2011≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥	A rotina tem como objetivo eliminar residuos de pedidos de≥±±
±±≥			 ≥	de compras e pedido de venda                			  ≥±±
±±≥			 ≥	Para contratos o cancelamento                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametro ≥	GCPLimpRes( cTipo, aDados )                                  ≥±±
±±≥			 ≥	cTipo : PC ( Pedido de Compra )                           ≥±±
±±≥			 ≥	        PV ( Pedido de Venda )                            ≥±±
±±≥			 ≥	        CO ( Contrato )                                   ≥±±
±±≥			 ≥	aDados : C6_NUM / C7_NUM / CN9_NUMERO, CN9_REVISA         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ DATAPREV                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

Function GCPLimpRes(cTipo,aDados)
Local aArea   := GetArea()
Local aAreaSM0 := SM0->(GetArea())
Local aRet     := {}
Local aAux     := {}
Local aTipDoc	 := {}
Local lRet     := .T.
Local cNumPro  := CO1->CO1_NUMPRO
Local cCodEdt	 := CO1->CO1_CODEDT
Local cOrg		 := CO1->CO1_CODORG 
Local lLote 	 := (CO1->CO1_AVAL == '2')
Local cQuery   := ""
Local cFilSC1  := ""
Local cSitAnt  := " "
Local cFilBkp  := cFilAnt
Local lCancelCN9:= .F.
Local lCancelSC7:= .F.
Local lDoc := .F.
Local nX	:= 1

If Empty(Alltrim(cTipo)) .Or. !(Alltrim(UPPER(cTipo)) $ '1_2_3')
	Help( "", 1, "GCPXTOIN") //"Tipo de operaÁ„o inv·lido ! - GCPLIMPRES()"
	aAdd(aRet,{.F.,''})
	lRet := .F.
EndIf

// -- Tipo de documento gerado quando consumida a ata - Remanescente
aTipDoc := A200TipDoc(cOrg,cCodEdt,cNumPro)
If Len(aTipDoc) >= 1
	lDoc := .T.
EndIf

If lRet
	Do Case
	
	Case cTipo == '1' .Or. (lDoc .And. aTipDoc[nX][1] == "1")//-- Contrato
	
		cQuery := "SELECT CN9.R_E_C_N_O_ CN9RECNO, CNB.R_E_C_N_O_ CNBRECNO "
		cQuery += "FROM " +RetSqlName("CN9") +" CN9 "
		cQuery += "JOIN " +RetSqlName("CNB") +" CNB ON CNB.D_E_L_E_T_ = ' ' AND "
			cQuery += "	CNB.CNB_FILORI = '" +xFilial('CNB') +"' AND "
		cQuery += "	CNB.CNB_CONTRA = CN9.CN9_NUMERO AND "
		cQuery += "	CNB.CNB_REVISA = CN9.CN9_REVATU AND "
		cQuery += "	CNB.CNB_SLDREC > 0 "
		cQuery += "WHERE CN9.D_E_L_E_T_ = ' ' AND "
			cQuery += "	CN9.CN9_FILORI = '" +xFilial('CN9') +"' AND "
		cQuery += "	CN9.CN9_NUMERO = CNB.CNB_CONTRA AND "
		cQuery += " CN9.CN9_REVATU = CNB.CNB_REVISA AND "
		cQuery += "	CN9.CN9_CODED = '" +CO1->CO1_CODEDT +"' AND "
		cQuery += "	CN9.CN9_NUMPR = '" +CO1->CO1_NUMPRO +"' AND "
		cQuery += "	CN9_RESREM <> 'S'"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CN9TMP")

		Begin Transaction
								
		While lRet .And. !CN9TMP->(EOF())

			CNB->(dbGoTo(CN9TMP->CNBRECNO))

			dbSelectArea("CN9")
			dbGoTo(CN9TMP->CN9RECNO)
			cSitAnt := CN9->CN9_SITUAC

			//-- o vetor adados contem os dados do ganhador durante o processo remanescente (Processo LicitatÛrio, processo, produto e fornecedor)
			//-- somente o contrato com o fornecedor substituido no processo remanescente sera cancelado. 
			lCancelCN9 := .F.
			If	!Empty(aDados) .And. CNB->CNB_CONTRA+CNB->CNB_REVISA == CN9->CN9_NUMERO+CN9->CN9_REVATU .And.;
				Ascan(aDados,{|x| x[6] + x[7] + If(!lLote,x[3],x[15]) == CN9->CN9_CODED + CN9->CN9_NUMPR + If(!lLote,CNB->CNB_PRODUT,CNB->CNB_GCPLT) }) > 0
				lCancelCN9 := .T.  //-- Cancela somente o contrato com o fornecedor substituido no processo remanescente
			EndIf
			//-- Verifica se e originado de compra centralizada,
			//-- Se sim troca filial para execucao das eliminacoes
			If CN9->CN9_FILIAL # xFilial("CN9")
				SM0->(dbSetOrder(1))
				SM0->(dbSeek(cEmpAnt+AllTrim(CN9->CN9_FILIAL)))
				cFilAnt := FWCodFil()
			EndIf			
			If CN9->CN9_SITUAC == "09"
				Help("",1,"GCPLIMPRES",,STR0052+CN9->CN9_NUMERO +STR0053,1,1)	//"O contrato "###" est· em processo de revis„o. Exclua ou aprove a revis„o para que o remanescente possa ser processado."
				aAdd(aRet,{.F.,''})
				lRet := .F.
			ElseIf CN9->CN9_SITUAC <> '01' .And. lCancelCN9 .And. !(lRet := CN100Cance(,,aRet))
				Help("",1,"GCPLIMPRES",,STR0054 +AllTrim(CN9->CN9_NUMERO) +'/' +CN9->CN9_REVISA,1,1) //"Erro ao cancelar o contrato/revis„o : "
				aAdd(aRet,{.F.,''})
				lRet := .F.
			EndIf
			
			//-- se houver Pedido de Compra aret eh preenchido na funcao CN100Cance, caso contrario devera ser preenchido no if abaixo
			If	lRet .And. lCancelCN9 .And. Empty(aScan(aAux,{|x| x == CN9TMP->CNBRECNO}))
	
				CNB->(dbGoTo(CN9TMP->CNBRECNO))
				aAdd(aRet,{lRet,CNB->CNB_PRODUT,CNB->CNB_SLDREC,CNB->(CNB_NUMSC+CNB_ITEMSC),CN9TMP->CNBRECNO,cSitAnt,CN9TMP->CN9RECNO,CNB->CNB_GCPLT})
				aAdd(aAux,CN9TMP->CNBRECNO)
			EndIf

           SM0->(RestArea(aAreaSM0))
			cFilAnt := cFilBkp
			CN9TMP->(dbSkip())
		End
		
		If !lRet
			DisarmTransaction()
		EndIf
		
		End Transaction
							
		CN9TMP->(dbCloseArea())
	
	Case cTipo == '2' .Or. (lDoc .And. aTipDoc[nX][1] == "2")//-- Pedido de Compra
	
		cQuery := "SELECT R_E_C_N_O_ SC7RECNO "
		cQuery += "FROM " +RetSqlName('SC7') +" WHERE "
		cQuery += "	D_E_L_E_T_ = ' ' AND "
		cQuery += "	CASE C7_FISCORI WHEN '" +Space(FWSizeFilial()) +"' THEN C7_FILIAL "
		cQuery += " ELSE C7_FISCORI END = '" +xFilial('SC7') +"' AND "
		cQuery += "	C7_CODED = '" +CO1->CO1_CODEDT +"' AND "
		cQuery += "	C7_NUMPR = '" +CO1->CO1_NUMPRO +"' AND "
		cQuery += "	C7_QUANT - C7_QUJE > 0 AND "
		cQuery += "	C7_RESREM <> 'S'"
		cQuery := ChangeQuery(cQuery)		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SC7TMP")

		Begin Transaction

		While lRet .And. SC7TMP->(!EOF())			
			dbSelectArea('SC7')
			dbGoTo(SC7TMP->SC7RECNO)
							
			lCancelSC7:=.F.
			If	!Empty(aDados) .And. Ascan(aDados,{|x| x[6] + x[7] + x[3] + x[15] == SC7->C7_CODED + SC7->C7_NUMPR + SC7->C7_PRODUTO + SC7->C7_GCPLT }) > 0
				lCancelSC7:=.T.
			EndIf

			If	lCancelSC7
				If AllTrim(SC7->C7_RESIDUO) <> "S"
					lRet := MA235ElRes()
					SC7->(dbGoTo(SC7TMP->SC7RECNO))
				EndIf
				
				If !lRet
					Help("",1,"GCPLIMPRES",,STR0055+SC7->C7_NUM +"/" +SC7->C7_ITEM,1,1) //"Erro ao eliminar o resÌduo do pedido de compra : "
					aAdd(aRet,{.F.,''})
					DisarmTransaction()
					lRet := .F.
				Else	
					RecLock("SC7",.F.)
					SC7->C7_RESREM := "S"
					SC7->(MsUnLock())
					aAdd(aRet,{lRet,SC7->C7_PRODUTO,SC7->(C7_QUANT - C7_QUJE),SC7->(C7_NUMSC-C7_ITEMSC)})
				EndIf
			EndIf
	
			SC7TMP->(dbSkip())				
		End
		
		End Transaction
		
		SC7TMP->(dbCloseArea())		
		
	Case cTipo == '3' //-- Pedido de venda
	
		cQuery := "SELECT SC6.R_E_C_N_O_ SC6RECNO "
		cQuery += "FROM " +RetSqlName("SC6") +" SC6 "
		cQuery += "JOIN " +RetSqlName("SC5") +" SC5 ON SC5.D_E_L_E_T_ = ' ' AND "
		cQuery += "	SC5.C5_FILIAL = '" + xFilial('SC5') + "' AND "
		cQuery += "	SC5.C5_NUM = SC6.C6_NUM AND "
		cQuery += "	SC5.C5_CODED = '" +CO1->CO1_CODEDT +"' AND "
		cQuery += "	SC5.C5_NUMPR = '" +CO1->CO1_NUMPRO +"' AND "
		cQuery += "	SC5.C5_RESREM <> 'S' "
		cQuery += "WHERE SC6.D_E_L_E_T_ = ' ' AND SC6.C6_FILIAL = '" + xFilial('SC6') + "' AND"
		cQuery += "	SC6.C6_QTDVEN - SC6.C6_QTDENT > 0
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SC6TMP")
		
		Begin Transaction
		
		While lRet .And. SC6TMP->(!EOF())			
			dbSelectArea("SC6")
			dbGoTo(SC6TMP->SC6RECNO)
			
			If AllTrim(SC6->C6_BLQ) <> "R"
				lRet := MAResDoFat()
				SC6->(dbGoTo(SC6TMP->SC6RECNO))
			EndIf
			
			If !lRet
				Help("",1,"GCPLIMPRES",,STR0056 +SC6->C6_NUM +"/" +SC6->C6_ITEM,1,1) //"Erro ao eliminar o resÌduo do pedido de venda : "
				aAdd(aRet,{.F.,''})
				DisarmTransaction()
				lRet := .F.
			Else
				aAdd(aRet,{lRet,SC6->C6_PRODUTO,SC6->(C6_QTDVEN - C6_QTDENT)})

				SC5->(dbSetOrder(1))
				SC5->(dbSeek(xFilial("SC5")+SC6->C6_NUM))
				RecLock("SC5",.F.)
				SC5->C5_RESREM := "S"
				SC5->(MsUnLock())
			EndIf
			
			SC6TMP->(dbSkip())
		End
		
		End Transaction
		
		SC6TMP->(DbCloseArea())
		
	EndCase
Endif	

RestArea(aArea)
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPVldHr()
ValidaÁ„o dos campos Hora
FunÁ„o retirado do gcpa002 - antiga GCP02HR()

@author alexandre.gimenez	 
@since 15/10/2013
@version 1.1
@return lRet
/*/
//-------------------------------------------------------------------
Function GCPVldHr()       
Local cHora := &(ReadVar())
 
If "-" $ cHora .Or. "  " $ cHora
	Help(" ",1,"HORAINVALI")
	Return(.F.)
Endif

If ! Empty(cHora)
	If Val(Left(ALLTRIM(cHora), 2)) > 23 .Or. Val(Right(ALLTRIM(cHora), 2)) > 59
		Help(" ",1,"HORAINVALI")
		Return(.F.)
	Endif
Endif

Return .T.
/*-------------------------------------------------------------------
{Protheus.doc} GCPXLmpCk
Necessario limpar a resposta do checklist, caso a etapa tenha voltado.

@author Alex Egydio
@since 17/10/2013
@version P11.90
--------------------------------------------------------------------*/
Function GCPXLmpCk(oModel,cCodEdt, cNumPro,cRevisa,cEtapa)
Local oModelCOW := oModel:GetModel('COWDETAIL')
Local nAux := 0

For nAux := 1 To oModelCOW:Length()
	oModelCOW:GoLine( nAux )
	If	Empty(oModelCOW:GetValue('COW_ETAPA'))
		Exit
	EndIf
	oModelCOW:LoadValue('COW_CHKOK',.F.)
	oModelCOW:LoadValue('COW_USER',Space(Len(COW->COW_USER)))
	oModelCOW:LoadValue('COW_DTCONC',CToD(''))
	oModelCOW:LoadValue('COW_HRCONC',Space(Len(COW->COW_HRCONC)))
	
	CP2->(DBSETORDER(1))
	If	CP2->(DbSeek(xFilial("CP2")+cCodEdt+cNumPro+cRevisa+cEtapa))	
		RecLock("CP2",.F.)
		CP2->CP2_USER := Space(Len(CP2->CP2_USER))
		CP2->CP2_DATA := CToD('')
		CP2->CP2_HORA := Space(Len(CP2->CP2_HORA))
		CP2->(MsUnLock())			
	EndIf
Next

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPSldItm(cCodPro)
VerificaÁ„o de existencia de saldo no produto

@author guilherme.pimentel	 
@since 21/10/2013
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function GCPSldItm(cProd,cLote,lValor)
Local aAreaAnt:= GetArea()
Local cQuery  := ""
Local nRet    := 0
Local lRet		:= .T.

Default cProd		:= ''
Default cLote		:= ''
Default lValor	:= .F.

nRet := CO2->CO2_QUANT
   cQuery += "SELECT "

If CO1->CO1_COPC == "1"
	cQuery += "MAX(CNB.CNB_SLDREC) AS SLDREM "
ElseIf CO1->CO1_COPC == "2"
	cQuery += "DISTINCT SC7.C7_CODED,SC7.C7_NUMPR,SC7.C7_RESREM,SC7.C7_PRODUTO,SC7.C7_QUANT QUANT,SC7.C7_QUJE QUJE "
ElseIf CO1->CO1_COPC == "3"
	cQuery += "SUM(SC6.C6_QTDVEN - SC6.C6_QTDENT) AS SLDREM "
EndIf

cQuery += "FROM " +RetSqlName("CO3") +" CO3 "

Do Case
Case CO1->CO1_COPC == "1"
	cQuery += "JOIN " +RetSQLName("CN9") + " CN9 ON CN9.D_E_L_E_T_ = ' ' AND "
		cQuery += "CN9.CN9_FILORI = '" +xFilial("CN9") +"' AND "
	cQuery += "CN9.CN9_CODED = '" +CO1->CO1_CODEDT +"' AND CN9.CN9_NUMPR = '" +CO1->CO1_NUMPRO +"' AND "
	cQuery += "CN9.CN9_REVATU = '" +Space(TamSX3("CN9_REVATU")[1]) +"' AND CN9.CN9_RESREM <> 'S' "
	
	cQuery += "JOIN " +RetSQLName("CNB") + " CNB ON CNB.D_E_L_E_T_ = ' ' AND "
		cQuery += "CNB.CNB_FILORI = '" +xFilial("CNB") +"' AND "
	cQuery += "CNB.CNB_CONTRA = CN9.CN9_NUMERO AND CNB.CNB_REVISA = CN9.CN9_REVISA "
	If CO1->CO1_AVAL == '1'
		cQuery += "AND CNB.CNB_PRODUT = CO3.CO3_CODPRO "
		cQuery += "AND CNB.CNB_PRODUT =  '"+cProd+"'"
	Else
//		cQuery += "AND CNB.CNB_GCPIT = CO3.CO3_LOTE "
		cQuery += "AND CNB.CNB_GCPLT = '"+cLote+"' "
		cQuery += "AND CNB.CNB_PRODUT = '"+cProd+"' "
	EndIf
Case CO1->CO1_COPC == "2"
	cQuery += "JOIN " +RetSQLName("SC7") + " SC7 ON SC7.D_E_L_E_T_ = ' ' AND "
		cQuery += "CASE SC7.C7_FISCORI WHEN '" +Space(FWSizeFilial()) +"' THEN SC7.C7_FILIAL "
		cQuery += "ELSE SC7.C7_FISCORI END = '" +xFilial("SC7") +"' AND "
	cQuery += "SC7.C7_CODED = '" +CO1->CO1_CODEDT +"' AND SC7.C7_NUMPR = '" +CO1->CO1_NUMPRO +"' AND "
	cQuery += "SC7.C7_RESREM <> 'S' "
	If CO1->CO1_AVAL == '1'
		cQuery += "AND SC7.C7_PRODUTO = CO3.CO3_CODPRO "
	EndIf	
Case CO1->CO1_COPC == "3"
	cQuery += "JOIN " +RetSQLName("SC5") + " SC5 ON SC5.D_E_L_E_T_ = ' ' AND SC5.C5_FILIAL = '" +xFilial("SC5") +"' AND "
	cQuery += "SC5.C5_CODED = '" +CO1->CO1_CODEDT +"' AND SC5.C5_NUMPR = '" +CO1->CO1_NUMPRO +"' AND "
	cQuery += "SC5.C5_RESREM <> 'S' "
	
	cQuery += "JOIN " +RetSQLName("SC6") + " SC6 ON SC6.D_E_L_E_T_ = ' ' AND SC6.C6_FILIAL = '" +xFilial("SC6") +"' AND "
	cQuery += "SC6.C6_NUM = SC5.C5_NUM"
EndCase

cQuery += "WHERE CO3.D_E_L_E_T_ = ' ' AND CO3.CO3_FILIAL = '" +xFilial("CO3") +"' AND "
cQuery += "CO3.CO3_CODEDT = '" +CO1->CO1_CODEDT +"' AND CO3.CO3_NUMPRO = '" +CO1->CO1_NUMPRO +"'"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SLDREM")

If SLDREM->(!EOF())
	If CO1->CO1_COPC == "1"
		nRet := SLDREM->SLDREM
	ElseIf	CO1->CO1_COPC == "2"
		nRet := SLDREM->QUANT - SLDREM->QUJE
	ElseIf CO1->CO1_COPC == "3"
		nRet := SLDREM->SLDREM
	EndIf
EndIf

SLDREM->(dbCloseArea())

lRet := (nRet > 0)

RestArea(aAreaAnt)	
Return If(lValor,nRet,lRet)
/*-------------------------------------------------------------------
{Protheus.doc} GCPXVlRem
Verifica se ha item no Processo LicitatÛrio com saldo para remanescente e com fornecedores ainda nao utilizados.

@author Andre Anjos
@since 18/04/2012
@version P11.90
--------------------------------------------------------------------*/
Function GCPXVlRem(cEdit,cNumPro)
Local lRet      := .T.
Local cQuery	:= ""

cQuery += "SELECT CO3.R_E_C_N_O_ CO3RECNO FROM " +RetSqlName("CO3") +" CO3 "

cQuery += "WHERE CO3.D_E_L_E_T_ = ' ' AND CO3.CO3_FILIAL = '" +xFilial("CO3") +"' AND "
cQuery += "CO3.CO3_CODEDT = '" +cEdit +"' AND CO3.CO3_NUMPRO = '" +cNumPro +"' AND "
cQuery += "CO3.CO3_STATUS NOT IN ('2','3','4','5')"
cQuery += "GROUP BY CO3.R_E_C_N_O_ "

Do Case
Case CO1->CO1_COPC == "P"
	cQuery += "HAVING SUM(SC7.C7_QUANT - SC7.C7_QUJE) > 0"
Case CO1->CO1_COPC == "F"
	cQuery += "HAVING SUM(SC6.C6_QTDVEN - SC6.C6_QTDENT) > 0"
Case CO1->CO1_COPC == "C"
	cQuery += "HAVING SUM(CNB.CNB_SLDREC) > 0"
EndCase

cQuery := ChangeQuery(cQuery) 
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),"CO3TMP", .T., .F. )
If Empty(CO3TMP->CO3RECNO)
	Help(" ",1,"GCP05NOFO")// "N„o existe participante disponivel"
  	lRet := .F.
EndIf
CO3TMP->(dbCloseArea())

Return lRet

/*-------------------------------------------------------------------
{Protheus.doc} GCPVlrImov
Calculo do valor do bem imovel e verificacao dos 5% de garantia conforme lei 8666 art. 18

@author Alex Egydio
@since 17/10/2013
@version P11.90
--------------------------------------------------------------------*/
Function GCPVlrImov(oModel,lChkPgto)
Local aCnd		:= {}
Local oModelCO2 := oModel:GetModel("CO2DETAIL")
Local n1Cnt		:= 0
Local n2Cnt		:= 0
Local nRet		:= 0
Local lLote       	:= oModel:GetId() == 'GCPA201'
Local oModelCP4 	:= If(lLote, oModel:GetModel("CP3DETAIL"), Nil)

Default lChkPgto	:= .F.
//-- Lei 8.666/93 Art. 18 concorrÍncia para a venda de bens imÛveis
If	oModel:GetValue("CO1MASTER","CO1_MODALI")=="CC" .And. oModel:GetValue("CO1MASTER","CO1_GERDOC")=="2" 
	If lLote
		For n1Cnt := 1 To oModelCP4:Length()
			oModelCP4:GoLine( n1Cnt )
			If	!oModelCP4:IsDeleted()
				For n2Cnt := 1 To oModelCO2:Length()
					oModelCO2:GoLine( n2Cnt )
					If	!oModelCO2:IsDeleted()
						If	oModelCO2:GetValue("CO2_TPBEM")=="3"
							nRet += oModelCO2:GetValue("CO2_VLESTI") * oModelCO2:GetValue("CO2_QUANT")
						EndIf
					EndIf
				Next n2Cnt
			EndIf					 						
		Next n1Cnt	
	Else			
	For n1Cnt := 1 To oModelCO2:Length()
		oModelCO2:GoLine( n1Cnt )
		If	!oModelCO2:IsDeleted()
			If	oModelCO2:GetValue("CO2_TPBEM")=="3"
				nRet += oModelCO2:GetValue("CO2_VLESTI") * oModelCO2:GetValue("CO2_QUANT")
			EndIf
		EndIf
	Next
	EndIf		
	
	
	If	lChkPgto
		aCnd := Condicao(nRet,oModel:GetValue("CO1MASTER","CO1_CONDPG"),,oModel:GetValue("CO1MASTER","CO1_DATARP"))
		For n1Cnt := 1 To Len(aCnd)
			If	DToS(aCnd[n1Cnt,1])==DToS(oModel:GetValue("CO1MASTER","CO1_DATARP"))
				If	! ( ( ( aCnd[n1Cnt,2] * 100 ) / nRet ) >= 5 )
					nRet := 0
				EndIf
			EndIf
		Next
	EndIf
EndIf
Return(nRet)

/*-------------------------------------------------------------------
{Protheus.doc} GCPXComCen
Monta a interface de tela para compra centralizada.

@author Rodrigo Toledo 
@since 27/12/2012
@version P11.90
--------------------------------------------------------------------*/
Function GCPXComCen(oLbx,cQuery,lWndManutEdit,aDados)
Local aArea		:= GetArea()
Local aHeadC1		:= CriaHeader("C1_FILENT|C1_FILIAL",Nil,Nil,"SC1")
Local aVetTst		:= {}
Local aVetor		:= {}
Local nY			:= 0
Local lGCP2HEAD	:= ExistBlock("GCP2HEAD")

If MaComCent()
	aDados := {}
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"ARQTRB")
	
	TcFieldAll("ARQTRB")
	While ARQTRB->(!Eof())
		aVetor := {}		
		If lWndManutEdit .And. lGCP2HEAD
			aVetTst := Execblock("GCP2HEAD",.F.,.F. ,{ARQTRB->C1_NUMPR,aVetor})
		   	If ValType(aVetTst) == "A"
		 		aVetor := aClone(aVetTst)
			EndIf
		EndIf

		If Empty(aVetor)
			aAdd(aVetor,.F.)
		EndIf
		
		For nY := 1 To Len(aHeadC1)-2
			If SC1->(FieldPos(aHeadC1[nY,2] ) ) > 0 .And. !Empty(ARQTRB->(FieldGet(FieldPos(aHeadC1[nY,2]))))
				aAdd(aVetor,ARQTRB->(FieldGet(FieldPos(aHeadC1[nY,2]))))
			Else
				aAdd(aVetor,CriaVar(aHeadC1[nY,2]))
			EndIf
		Next nY
		aAdd(aDados,aVetor)
		ARQTRB->(dbSkip())
	End
	ARQTRB->(dbCloseArea())
	
	If ValType(oLbx) == "O"
		oLbx:SetArray(aDados)
		oLbx:bLine := GCAbLine(aDados)
		oLbx:Refresh()
	EndIf
EndIf

RestArea(aArea)
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPWHEGERD()
FunÁ„o para habilitar a ediÁ„o do campo GERDOC se a modalidade do processo licitatÛrio for CC ou DL.
ValidaÁ„o no campo when do CO1_GERDOC
@author antenor.silva
@return LÛgico para identificar se a consulta foi bem sucedida.
@since 12/11/2013
@version P11.9
/*/
//-------------------------------------------------------------------
Function GCPWHEGERD()
Local cLei 	:= FwFldGet('CO1_LEI')
Local cModal	:= FwFldGet('CO1_MODALI')
Local cTipo	:= FwFldGet('CO1_TIPO')
Local cEspec	:= FwFldGet('CO1_ESPECI')

Local lRet		:= .F.
Local lSRP		:= FwFldGet("CO1_SRP") == "1"

If ((cModal $ "CC|DL") .Or. (cModal == 'PG' .And. cTipo == 'MO' .And. cEspec == '3'))  .And. !lSRP
	lRet := .T.
EndIf

If cLei == "4" // -- RDC
	lRet := .F.
EndIf

Return lRet

/*-------------------------------------------------------------------
{Protheus.doc} BuscaScm
Funcao de busca da usada pela tela de 
inclusao da analise de mercado via solicitacao de compra. 

@author Leonardo Quintania
@since 27/11/2013
@version P11.90
--------------------------------------------------------------------*/
Static Function BuscaScm(aDados,cPesq,nPosAtu,nIndex,aHeadC1)
Local nPos
//Definicao do criterio de pesquisa
If nIndex == 1
	nPos:= aScan(aDados,{|x| RTrim(cPesq) $ RTrim(x[aScan(aHeadC1,{|x| Trim(x[2])=="C1_NUM"}) + 1]) + RTrim(x[aScan(aHeadC1,{|x| Trim(x[2])=="C1_ITEM"}) + 1])},nPosAtu + 1)
ElseIf nIndex == 2
	nPos:= aScan(aDados,{|x| RTrim(cPesq) $ RTrim(x[aScan(aHeadC1,{|x| Trim(x[2])=="C1_PRODUTO"}) + 1])},nPosAtu + 1)
ElseIf nIndex == 3
	nPos:= aScan(aDados,{|x| RTrim(cPesq) $ RTrim(x[aScan(aHeadC1,{|x| Trim(x[2])=="C1_DESCRI"}) + 1])},nPosAtu + 1)
EndIf

If nPos == 0
	Help("",1,"GCP02BUS") //"InformaÁ„o n„o localizada"
	nPos:= 1
Endif

Return nPos

/*-------------------------------------------------------------------
{Protheus.doc} GCAFilter
Filtro recursivo - SC de|ate
@param  aData	Itens disponiveis para selecao
@param  aHeadC1	Itens disponiveis para selecao
@param  aRetFil	Retorna da selecao dos parametros
@author Leonardo Quintania
@since 27/11/2013
@version P11.90
--------------------------------------------------------------------*/
Static Function GCAFilter( aData, aHeadC1, aRetFil, cAliasTmp )
Local nX		:= 0
Local nY		:= 0
Local aAuxData	:= {}
Local aVetor := {}

aData := {}
dbSelectArea(cAliasTmp)
dbGoTop()
If (cAliasTmp)->(!Eof())
	TcFieldAll(cAliasTmp)
	While (cAliasTmp)->(!Eof())
		aVetor:= {}
		aAdd( aVetor, .F. )
		For nY:= 1 To Len(aHeadC1)-2
			If SC1->(FieldPos(aHeadC1[nY,2] ) ) > 0 .And. !Empty((cAliasTmp)->(FieldGet(FieldPos(aHeadC1[nY,2]))))
				aAdd(aVetor,(cAliasTmp)->(FieldGet(FieldPos(aHeadC1[nY,2]))))
			Else
				aAdd(aVetor,CriaVar(aHeadC1[nY,2]))
			EndIf
		Next nY
		aAdd( aData , aVetor )
		(cAliasTmp)->(dbSkip())
	End
EndIf

aEval( aData, { |y| nX++, If( aRetFil[1] <= aData[nX][ aScan( aHeadC1, { |z| Trim( z[2] ) == 'C1_NUM' } ) + 1] .And. aRetFil[2] >= aData[nX][ aScan( aHeadC1, { |z| Trim( z[2] ) == 'C1_NUM' } ) + 1], aAdd( aAuxData, y ), Nil ) }, oLbx:Refresh() )

aData := aClone( aAuxData )

oLbx:SetArray( aData )
oLbx:bLine := GCAbLine( aData )
oLbx:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPXVldCnd
ValidaÁ„o da existencia da condiÁ„o de execuÁ„o 

@author guilherme.pimentel

@return lRet
@since 28/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function GCPXVldCnd(oModel,cField,cValue,cOldValue)
Local lRet  := .T.
Local lCond := FWFldGet(cField) 

If AT('(',FWFldGet(cField)) > 0
	lCond := Substr(lCond,0,AT('(',FWFldGet(cField) )-1)
End 

lRet := FindFunction(lCond)

If !lRet
	Help("",1,"A017VldCnd")//FunÁ„o n„o encontrada no repositÛrio. Favor verificar.
EndIf

Return lRet
/*-------------------------------------------------------------------
{Protheus.doc} GCPXAndOk
Verifica o status dos Lotes e Produtos para permitir o andamento do processo licitatÛrio

@author Alex Egydio
@since 30/11/2013
@version P11.90
--------------------------------------------------------------------*/
Function GCPXAndOk(oModel)
Local cMsg		:= ""
Local lRet		:= .F.
Local n1Cnt		:= 0
Local oModelCO1	:= oModel:GetModel("CO1MASTER")
Local lLote		:= (oModelCO1:GetValue("CO1_AVAL")=="2")
Local cEtapa	:= oModelCO1:GetValue("CO1_ETAPA") 
Local oModelCP3	:= NIL

//-- Lotes
If	lLote
	oModelCP3 := oModel:GetModel("CP3DETAIL")
	For n1Cnt := 1 To oModelCP3:Length()
		oModelCP3:GoLine( n1Cnt )
		If	!oModelCP3:IsDeleted()
			If	oModelCP3:GetValue("CP3_STATUS")$"1|4"
				lRet := GCPXAndPr(oModel,cEtapa)
				If	lRet
					Exit
				EndIf
			EndIf
		EndIf
		If	lRet
			Exit
		EndIf
	Next
	If	!lRet
		cMsg:=STR0046	//"Verifique o status dos Lotes, Produtos e Licitantes, pois n„o permitem o andamento do Processo LicitatÛrio!"
	EndIf
Else
	lRet := GCPXAndPr(oModel,cEtapa)
	If	!lRet
		cMsg:=STR0045	//"Verifique o status dos Produtos e Licitantes, pois n„o permitem o andamento do Processo LicitatÛrio!"
	EndIf
EndIf

If	!lRet .And. cEtapa $ 'JP|NE'
	If MSGYESNO(STR0048,STR0008)//"N„o h· licitantes v·lidos para os itens. Deseja revogar o Processo LicitatÛrio ?".//AtenÁ„o                                                                                                             
		GCPRevgEdt(oModel)	
	Else
		Help("",1,"GCP200OCPU")//OperaÁ„o cancelada pelo usu·rio.
	EndIf
ElseIf !lRet
	Help("",1,"GCPXAndOk",,cMsg,4,1)
EndIf

Return lRet
/*-------------------------------------------------------------------
{Protheus.doc} GCPXAndPr
Verifica o status dos produtos para permitir o andamento do processo licitatÛrio

@author Alex Egydio
@since 30/11/2013
@version P11.90
--------------------------------------------------------------------*/
Function GCPXAndPr(oModel,cEtapa)
Local lRet		:= .F.
Local n1Cnt		:= 0
Local oModelCO2 := oModel:GetModel("CO2DETAIL")

For n1Cnt := 1 To oModelCO2:Length()
	oModelCO2:GoLine( n1Cnt )
	If	!oModelCO2:IsDeleted()
		If	oModelCO2:GetValue("CO2_STATUS")$"1|4"
			//-- Analisa o status dos licitante apenas se estiver nas etapas de Julgamento e Adjudicacao
			If	cEtapa$"JP|AD"
				lRet := GCPXAndLc(oModel)
			Else
				lRet := .T.
			EndIf
			If lRet
			  Exit
			EndIf  
		EndIf
	EndIf
Next

Return lRet
/*-------------------------------------------------------------------
{Protheus.doc} GCPXAndLc
Verifica o status dos licitantes para permitir o andamento do processo licitatÛrio

@author Alex Egydio
@since 30/11/2013
@version P11.90
--------------------------------------------------------------------*/
Function GCPXAndLc(oModel)
Local lRet		:= .F.
Local n1Cnt		:= 0
Local oModelCO3 := oModel:GetModel("CO3DETAIL")

For n1Cnt := 1 To oModelCO3:Length()
	oModelCO3:GoLine( n1Cnt )
	If	!oModelCO3:IsDeleted()
		If	oModelCO3:GetValue("CO3_STATUS")$"1|4|5|7" .And. !Empty(oModelCO3:GetValue("CO3_CODIGO"))
			lRet := .T.
			Exit
		EndIf
	EndIf
Next

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GCPXQtdLic
Quantidade licitada do Org„o participante n„o pode ficar zerada

@author Taniel Balsanelli
@param cCPIModel
@since 11/12/2013
@version P11.90
@return lRet
/*/
//-------------------------------------------------------------------

Function GCPXQtdLic(cCPIModel)
Local oModel  := FWModelActive()
Local oModCPI := oModel:GetModel(cCPIModel)  
Local oModCO2 := oModel:GetModel('CO2DETAIL')
Local lRet    := .T.
Local nQtdLic := 0


If !oModCPI:IsDeleted()
	nQtdLic := oModCPI:GetValue('CPI_QTDLIC')
	If nQtdLic == 0
    		lRet := .F.
    		Help("",1,"A200QtdLic",,STR0047+oModCO2:GetValue('CO2_CODPRO') ,4,1)//"A quantidade deve ser maior que zero(0). Produto: "                                                                                                                                                                                                                                                                                                                                                                                                                                                                		    								
	EndIf 
EndIf

Return lRet


/*-------------------------------------------------------------------
{Protheus.doc} GCPWHENSRP()
Habilita o campo SRP somente quando a modalidade for pregao ou concorrencia menor preco

@author Taniel Balsanelli
@since 12/12/2013
@version P11.90
--------------------------------------------------------------------*/
Function GCPWHENSRP()
Local lRet   := (FWFLDGET("CO1_MODALI") $ "CC|PG" .And. FWFLDGET("CO1_TIPO") <> "MT") .Or. FWFLDGET("CO1_LEI") == '5'
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GCPWorkDay( dDate1 , nDias , lSaturday , lSunday , lHoliday )
Retorna a data somada com a quantidade de dias ˙teis informada.

@author Antenor Silva
@since 07/02/2014
@version P11.90
@return lRet
/*/
//-------------------------------------------------------------------
Function GCPWorkDay( dDate1 , nDias , lSaturday , lSunday , lHoliday )
Local aHoliday		:= RetFeriados()
Local nX			:= 0

Default lSaturday	:= .T.
Default lSunday  	:= .T.
Default lHoliday 	:= .T.

For nX := 1 To nDias
	lOk := .T.
	While lOk
		If  Dow(dDate1) == 7 .And. !lSaturday
			dDate1++
		ElseIf  Dow(dDate1) == 1 .And. !lSunday 
			dDate1++
		ElseIf Ascan(aHoliday,DTOS(dDate1)) > 0 .And. lHoliday
			dDate1++
		Else
			dDate1++
			lOk := .F.
		EndIf   
	End
Next nX

Return dDate1

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPVMdxRg(cRegra)
FunÁ„o que retorna se existe Modalidades para uma determinada regra

@param cRegra
@author Matheus Lando Raimundo
@return lRet
/*/
//-------------------------------------------------------------------
Function GCPVMdxRg(cRegra)
Local lRet := .T.
Local cAliasCP5 := GetNextAlias()

BeginSql Alias cAliasCP5
	SELECT CP5_REGRA FROM %table:CP5% CP5
		WHERE CP5.CP5_FILIAL = %xfilial:CP5%
		AND CP5.CP5_REGRA = %exp:cRegra%
		AND CP5.%NotDel%		
EndSql

lRet := (cAliasCP5)->(!EOF())

(cAliasCP5)->(DbCloseArea())

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} GCPXEdital()
Retorna a query com as informaÁıes do produto e licitantes a partir do processo licitatÛrio.

@author taniel.silva
@since 14/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GCPXEdital(cQuery,aCTBEnt,aGCP9QRY,lGCP9QRY,lRatItens,lLote)
Local nPos := 0
Local cFator := "CASE WHEN CO3.CO3_PERCEN > 0 THEN (CO3.CO3_PERCEN / 100) WHEN CO3.CO3_PERCEN = 0 THEN (1) END"
Local lAglutina := SuperGetMV("MV_GCPAGL",.F.,.F.)
Local oModel	:= FwModelActive()
local lPosHMCO1		:= CO1->(FieldPos("CO1_HMPARC")) > 0
local lPosHMCO2		:= CO2->(FieldPos("CO2_HOMOLO")) > 0
local lPosDOCO2		:= CO2->(FieldPos("CO2_DOCOK")) > 0
Local lProdSC		:= !Empty(oModel:GetValue( "CP4DETAIL" , "CP4_NUMSC" ))


cQuery := "SELECT DISTINCT CO3.CO3_FILIAL FILIAL, "
cQuery += " CO3.CO3_CODEDT CODEDT, "
cQuery += " CO3.CO3_NUMPRO NUMPROC, "
cQuery += " CO3.CO3_CODIGO CODIGO, "
cQuery += " CO3.CO3_LOJA LOJA, "
cQuery += " CO3.CO3_TIPO TIPO, "
cQuery += " CO3.CO3_CONDPG CONDPG, "
cQuery += " CO2.CO2_CODPRO CODPRO, "
cQuery += " CO2.CO2_LOTE LOTE, "

If CO1->CO1_SRP == '1'
	cQuery += " CO3.CO3_VALATU VLUNIT, "
Else
	If CO1->CO1_AVAL == '1' //Item
		cQuery += " CO3.CO3_VLUNIT VLUNIT, "
	Else
		cQuery += " CASE WHEN CO3.CO3_PERCEN > 25 OR CO3.CO3_PERCEN = 0 THEN CP6.CP6_PRCUN  WHEN CO3.CO3_PERCEN <= 25 THEN CP6.CP6_PRCUN2 END VLUNIT, "
	Endif
EndIf
cQuery += " CO3.CO3_LOTE LOTE, "
If lRatItens .Or. lAglutina
	cQuery += " CO2.CO2_QUANT QUANT, " 
	cQuery += " CO2.CO2_ITEM ITEM, "
Else
	If A200CMSP()
		If lLote
			If lProdSC
				cQuery += " CASE WHEN CO3.CO3_PERCEN > 25 OR CO3.CO3_PERCEN = 0 THEN CP4.CP4_QUANT WHEN CO3.CO3_PERCEN <= 25 THEN CP6.CP6_QUANT2 END QUANT,"
			Else
				cQuery += " CASE WHEN CO3.CO3_PERCEN > 25 OR CO3.CO3_PERCEN = 0 THEN CP6.CP6_QUANT WHEN CO3.CO3_PERCEN <= 25 THEN CP6.CP6_QUANT2 END QUANT,"
			EndIf
		Else 
			cQuery += " ISNULL(SC1.C1_QUANT,CO2.CO2_QUANT) QUANT, " 
		EndIf	
	Else
		cQuery += " ISNULL(SC1.C1_QUANT,CO2.CO2_QUANT) QUANT, "
	Endif 
	cQuery += " ISNULL(SC1.C1_ITEM,CO2.CO2_ITEM) ITEM, "      
EndIf      
cQuery += " ISNULL(SC1.C1_CC,SB1.B1_CC) CC, "
cQuery += " ISNULL(SC1.C1_CONTA,SB1.B1_CONTA) CONTA, "
cQuery += " ISNULL(SC1.C1_ITEMCTA,SB1.B1_ITEMCC) ITEMCTA, "
cQuery += " ISNULL(SC1.C1_CLVL,SB1.B1_CLVL) CLVL, "
cQuery += " ISNULL(SC1.C1_NUM,'') NUMSC, "
cQuery += " ISNULL(SC1.C1_FILENT,'') FILENT "
cQuery += " ,CO3.CO3_PERCEN PERCEN  "

//-- Adiciona campos das novas entidades contabeis
For nPos := 1 To Len(aCTBEnt)
	If SC1->(FieldPos("C1_EC" +aCTBEnt[nPos] +"CR")) > 0
		cQuery += ", ISNULL(SC1.C1_EC" +aCTBEnt[nPos] +"CR,SB1.B1_EC" +aCTBEnt[nPos] +"CR) EC" +aCTBEnt[nPos] +"CR "
		cQuery += ", ISNULL(SC1.C1_EC" +aCTBEnt[nPos] +"DB,SB1.B1_EC" +aCTBEnt[nPos] +"DB) EC" +aCTBEnt[nPos] +"DB "
	Else
		cQuery += ", SB1.B1_EC" +aCTBEnt[nPos] +"CR EC" +aCTBEnt[nPos] +"CR "
		cQuery += ", SB1.B1_EC" +aCTBEnt[nPos] +"DB EC" +aCTBEnt[nPos] +"DB "
	EndIf
Next nPos

//-- Ponto de entrada para adicao de campos na query
If lGCP9QRY
	aGCP9QRY := Execblock('GCP9QRY',.F.,.F.)
	
	If (lGCP9QRY := ValType(aGCP9QRY[1]) == "C" .And. ValType(aGCP9QRY[2]) == "C")
		cQuery += aGCP9QRY[1]
	EndIf
EndIf

cQuery += "FROM " +RetSqlName("CO3") +" CO3 "

cQuery += "JOIN " +RetSQLName("CO2") +" CO2 ON "
cQuery += " CO2.D_E_L_E_T_ = ' ' AND "
cQuery += " CO2.CO2_FILIAL = '" +xFilial("CO2") +"' AND "
cQuery += " CO2.CO2_CODEDT = CO3.CO3_CODEDT AND "
cQuery += " CO2.CO2_NUMPRO = CO3.CO3_NUMPRO AND "
If !lLote
	cQuery += " CO2.CO2_CODPRO = CO3.CO3_CODPRO "
Else
	cQuery += " CO2.CO2_LOTE = CO3.CO3_LOTE "
EndIf    

cQuery += "JOIN " +RetSQLName("SB1") +" SB1 ON "
cQuery += " SB1.D_E_L_E_T_ = ' ' AND "
cQuery += " SB1.B1_FILIAL = '" +xFilial("SB1") +"' AND "
cQuery += " SB1.B1_COD = CO2.CO2_CODPRO "

cQuery += "LEFT JOIN " +RetSQLName("CP4") +" CP4 ON "
cQuery += " CP4.D_E_L_E_T_ = ' ' AND "
cQuery += " CP4.CP4_FILIAL = '"+xFilial("CP4")+"' AND "	
cQuery += " CP4.CP4_CODEDT = CO2.CO2_CODEDT AND "
cQuery += " CP4.CP4_NUMPRO = CO2.CO2_NUMPRO AND "
cQuery += " CP4.CP4_CODPRO = CO2.CO2_CODPRO "
cQuery += " AND CP4.CP4_LOTE = CO2.CO2_LOTE "

cQuery += "LEFT JOIN " +RetSQLName("SC1") +" SC1 ON "
cQuery += " SC1.D_E_L_E_T_ = ' ' AND "
cQuery += " SC1.C1_FILIAL = '"+xFilial("SC1")+"' AND "	
cQuery += " SC1.C1_CODED = CP4.CP4_CODEDT "
cQuery += " AND SC1.C1_NUMPR = CP4.CP4_NUMPRO AND "
cQuery += " SC1.C1_PRODUTO = CP4.CP4_CODPRO "

cQuery += " AND SC1.C1_NUM=CP4.CP4_NUMSC "
cQuery += " AND SC1.C1_ITEM = CP4.CP4_ITEMSC "

cQuery += "LEFT JOIN " +RetSQLName("CP6") +" CP6 ON "
cQuery += " CP6.D_E_L_E_T_ = ' ' AND "
cQuery += " CP6.CP6_FILIAL = '"+xFilial("CP6")+"' AND "	
cQuery += " CP6.CP6_CODEDT = CO2.CO2_CODEDT AND "
cQuery += " CP6.CP6_LOTE   = CO2.CO2_LOTE  AND "
cQuery += " CP6.CP6_NUMPRO = CO2.CO2_NUMPRO AND "
cQuery += " CP6.CP6_CODPRO = CO2.CO2_CODPRO "

//-- Se rateio contabil na SCH, forca nao trazer SC1
If lRatItens
	cQuery += " AND SC1.C1_PRODUTO = '' "
EndIf

cQuery += "WHERE CO3.CO3_FILIAL = '"+xFilial("CO3")+"' "
cQuery += " AND CO3.CO3_CODEDT = '" +CO1->CO1_CODEDT+ "' "
cQuery += " AND CO3.CO3_NUMPRO = '" +CO1->CO1_NUMPRO+ "' "

If CO1->CO1_REMAN
	cQuery += " AND ( CO3.CO3_STATUS = '5' OR CO2.CO2_STATUS = '2') "
	cQuery += " AND ( CO3.CO3_WINREM  = 'T' OR CO3.CO3_PERCEN = 0) "
	cQuery += " AND CO2.CO2_REMAN = 'T' "
	cQuery += " AND CO3.CO3_CODIGO IN "
	cQuery += 		" ( SELECT CO3_CODIGO FROM " +RetSqlName("CO3") +" CO3 "
	cQuery +=		" WHERE CO3.CO3_FILIAL = '"+xFilial("CO3")+"' "
	cQuery += 		" AND CO3.CO3_CODEDT = '" +CO1->CO1_CODEDT+ "' "
	cQuery +=		" AND CO3.CO3_NUMPRO = '" +CO1->CO1_NUMPRO+ "' "  
	cQuery += 		" AND CO3.CO3_STATUS = '5' )"	
Else 
	cQuery += " AND CO3.CO3_STATUS = '5' "
EndIf

If lPosHMCO1 .And. lPosHMCO2 .And. lPosDOCO2 //Verifica se existe os campos da Homologacao Parcial
	If CO1->CO1_HMPARC //Se for homologacao parcial
		cQuery += " AND CO2.CO2_HOMOLO = 'T' "
		cQuery += " AND CO2.CO2_DOCOK = 'F' "
	EndIf
EndIf

//-- Ponto de entrada para adicao de filtro 
If lGCP9QRY
	cQuery += aGCP9QRY[2]
EndIf

cQuery += " AND CO3.D_E_L_E_T_ = ' ' "

If lRatItens .Or. lAglutina
	cQuery += "ORDER BY FILIAL,CODIGO,LOJA,TIPO,FILENT"
Else
	cQuery += "ORDER BY FILIAL,CODIGO,LOJA,FILENT,ITEM,CODPRO" 
EndIf

Return nil

//------------------------------------------------------------------
/*/{Protheus.doc} GCPXAta()
Retorna a query com as informaÁıes do produto e licitantes a partir da Ata.

@author taniel.silva
@since 14/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GCPXAta(cQuery,aCTBEnt,aGCP9QRY,lGCP9QRY,lRatItens,aRecNoCPE,cFilOrig,cFilEnt)
Local nPos := 0
Local cRecNos := ""
Local nI := 0
Local lGerCent	:= SuperGetMV("MV_GCPFIAP", .T., "C") == "C"
Local oModel	:= FwModelActive()
Local lLote	:= .F.

If oModel <> Nil .And. oModel:GetId() == "GCPA320"
	lLote := GCP301Lote( oModel:GetValue( "CPHMASTER" , "CPH_NUMATA" ) )
EndIf

Default cFilOrig := cFilAnt
Default cFilEnt := cFilAnt

cQuery := "SELECT CPZ.CPZ_FILIAL FILIAL, "
cQuery += " CPZ.CPZ_NUMATA NUMATA, "
cQuery += " CPZ.CPZ_CODIGO CODIGO, "
cQuery += " CPZ.CPZ_LOJA LOJA, "
cQuery += " CPZ.CPZ_TIPO TIPO, "
cQuery += " CPZ.CPZ_CONDPG CONDPG, "
cQuery += " CPY.CPY_CODPRO CODPRO, "
cQuery += " CPH.CPH_CODEDT CODEDT, "
cQuery += " CPH.CPH_NUMPRO NUMPRO, "
cQuery += " CPY.CPY_VALATU VLUNIT, "
cQuery += " SUM(CPE.CPE_QUANT) QUANT, "
cQuery += " CPE.CPE_CODNE CODNE,"
cQuery += " CPE.CPE_ITEMNE ITEMNE,"
cQuery += " CPE.CPE_NUMSC NUMSC,"    
cQuery += " CPE.CPE_ITEMSC ITEM,"        
cQuery += " ISNULL(SC1.C1_CC,SB1.B1_CC) CC, "
cQuery += " ISNULL(SC1.C1_CONTA,SB1.B1_CONTA) CONTA, "
cQuery += " ISNULL(SC1.C1_ITEMCTA,SB1.B1_ITEMCC) ITEMCTA, "
cQuery += " ISNULL(SC1.C1_CLVL,SB1.B1_CLVL) CLVL, "
cQuery += " ISNULL(SC1.C1_FILENT,'') FILENT "

//-- Adiciona campos das novas entidades contabeis
For nPos := 1 To Len(aCTBEnt)
	If SC1->(FieldPos("C1_EC" +aCTBEnt[nPos] +"CR")) > 0
		cQuery += ", ISNULL(SC1.C1_EC" +aCTBEnt[nPos] +"CR,SB1.B1_EC" +aCTBEnt[nPos] +"CR) EC" +aCTBEnt[nPos] +"CR "
		cQuery += ", ISNULL(SC1.C1_EC" +aCTBEnt[nPos] +"DB,SB1.B1_EC" +aCTBEnt[nPos] +"DB) EC" +aCTBEnt[nPos] +"DB "
	Else
		cQuery += ", SB1.B1_EC" +aCTBEnt[nPos] +"CR EC" +aCTBEnt[nPos] +"CR "
		cQuery += ", SB1.B1_EC" +aCTBEnt[nPos] +"DB EC" +aCTBEnt[nPos] +"DB "
	EndIf
Next nPos

//-- Ponto de entrada para adicao de campos na query
If lGCP9QRY
	aGCP9QRY := Execblock('GCP9QRY',.F.,.F.)
	
	If (lGCP9QRY := ValType(aGCP9QRY[1]) == "C" .And. ValType(aGCP9QRY[2]) == "C")
		cQuery += aGCP9QRY[1]
	EndIf
EndIf

cQuery += "FROM " +RetSqlName("CPZ") +" CPZ "

cQuery += "JOIN " +RetSQLName("CPY") +" CPY ON "
cQuery += " CPY.D_E_L_E_T_ = ' ' AND "
cQuery += " CPY.CPY_FILIAL = '" +xFilial("CPY",cFilOrig) +"' AND "

If lLote
	cQuery += " CPY.CPY_LOTE = CPZ.CPZ_LOTE AND "
Else
	cQuery += " CPY.CPY_CODPRO = CPZ.CPZ_CODPRO AND "  
EndIf

cQuery += " CPY.CPY_NUMATA = CPZ.CPZ_NUMATA "

cQuery += "JOIN " +RetSQLName("CPH") +" CPH ON "
cQuery += " CPH.CPH_NUMATA = CPY.CPY_NUMATA "

cQuery += "JOIN " +RetSQLName("SB1") +" SB1 ON "
cQuery += " SB1.D_E_L_E_T_ = ' ' AND "
cQuery += " SB1.B1_FILIAL = '" +xFilial("SB1",cFilOrig) +"' AND "
cQuery += " SB1.B1_COD = CPY.CPY_CODPRO "


cQuery += " INNER JOIN " + RetSQLName("CPE") +  " CPE ON CPE.CPE_FILIAL = CPZ.CPZ_FILIAL"  
cQuery += " AND CPE.CPE_NUMATA = CPZ.CPZ_NUMATA "									
cQuery += " AND CPE.CPE_CODPRO = CPY.CPY_CODPRO "

If lLote
	cQuery += " AND CPE.CPE_LOTE = CPZ.CPZ_LOTE "
EndIf						

cQuery += "LEFT JOIN " +RetSQLName("SC1") +" SC1 ON "
cQuery += " SC1.D_E_L_E_T_ = ' ' AND "
cQuery += " SC1.C1_FILIAL = '"+xFilial("SC1",cFilOrig)+"' AND "	
cQuery += " SC1.C1_CODED = CPH.CPH_CODEDT AND "
cQuery += " SC1.C1_NUMPR = CPH.CPH_NUMPRO AND "
cQuery += " SC1.C1_PRODUTO = CPY.CPY_CODPRO "

If !lGerCent
	cQuery += " AND SC1.C1_FILENT = '" + cFilEnt + "'"
EndIf	

//-- Se rateio contabil na SCH, forca nao trazer SC1
If lRatItens
	cQuery += " AND SC1.C1_PRODUTO = '' "
EndIf

cQuery += "WHERE CPZ.CPZ_FILIAL = '"+xFilial("CPZ",cFilOrig)+"' "
cQuery +=	" AND CPZ.CPZ_NUMATA = '" +CPH->CPH_NUMATA+ "' "  
cQuery += " AND CPZ.CPZ_STATUS = '5' "

For nI := 1 To Len(aRecNoCPE)	
	cRecNos +=  "'" + AllTrim(Str(aRecNoCPE[nI])) + "'" + Iif( (nI < Len(aRecNoCPE)), ",", "")	
Next nI		

cQuery += " AND CPE.R_E_C_N_O_ IN (" +  cRecNos + ")"
cQuery += " AND CPZ.CPZ_STATUS = '5' "

//-- Ponto de entrada para adicao de filtro
If lGCP9QRY
	cQuery += aGCP9QRY[2]
EndIf

cQuery += " AND CPZ.D_E_L_E_T_ = ' ' "

cQuery += "  GROUP BY CPZ.CPZ_FILIAL ,"
cQuery += "  CPZ.CPZ_NUMATA ,"
cQuery += "         CPZ.CPZ_CODIGO ,"
cQuery += "         CPZ.CPZ_LOJA ,"
cQuery += "         CPZ.CPZ_TIPO ,"
cQuery += " 		CPZ.CPZ_CONDPG, "
cQuery += "         CPY.CPY_CODPRO ,"
cQuery += "         CPH.CPH_CODEDT ,"
cQuery += "         CPH.CPH_NUMPRO ,"
cQuery += "         CPY.CPY_VALATU ,"
cQuery += " 		  CPE.CPE_CODNE,"
cQuery += " 		  CPE.CPE_ITEMNE,"
cQuery += " 		  CPE.CPE_NUMSC ,"    
cQuery += " 		   CPE.CPE_ITEMSC ,"
cQuery += "         ISNULL(SC1.C1_CC,SB1.B1_CC) ,"
cQuery += "         ISNULL(SC1.C1_CONTA,SB1.B1_CONTA) ,"
cQuery += "         ISNULL(SC1.C1_ITEMCTA,SB1.B1_ITEMCC),"
cQuery += "         ISNULL(SC1.C1_CLVL,SB1.B1_CLVL) ,"
cQuery += "         ISNULL(SC1.C1_FILENT,'')" 

//-- Adiciona campos das entidades contabeis adicionais
For nPos := 1 To Len(aCTBEnt)
	If SC1->(FieldPos("C1_EC" +aCTBEnt[nPos] +"CR")) > 0
		cQuery += ", ISNULL(SC1.C1_EC" +aCTBEnt[nPos] +"CR,SB1.B1_EC" +aCTBEnt[nPos] +"CR) "
		cQuery += ", ISNULL(SC1.C1_EC" +aCTBEnt[nPos] +"DB,SB1.B1_EC" +aCTBEnt[nPos] +"DB) "
	Else
		cQuery += ", SB1.B1_EC" +aCTBEnt[nPos] +"CR "
		cQuery += ", SB1.B1_EC" +aCTBEnt[nPos] +"DB "
	EndIf
Next nPos 

If lRatItens
	cQuery += "ORDER BY FILIAL,CODIGO,LOJA,TIPO,FILENT"
Else
	cQuery += "ORDER BY FILIAL,CODIGO,LOJA,FILENT,ITEM,CODPRO" 
EndIf

Return nil
/*-------------------------------------------------------------------
{Protheus.doc} GCPXForVen(oModel,cMsg, aFornsSRP)
Retorna lista de fornecedores vencedores de um processo licitatÛrio.
@author israel.escorizza	
@since 20/01/2015
@version 1.0
@return aForns
--------------------------------------------------------------------*/
Function GCPXForVen(oModel)

Local oCO1Master 	:= oModel:GetModel("CO1MASTER")
Local oCO2Detail 	:= oModel:GetModel("CO2DETAIL")
Local oCO3Detail 	:= oModel:GetModel("CO3DETAIL")
Local nI 		   	:= 0
Local nI2			:= 0
Local aForns 	   	:= {}
Local cCodFor    	:= ""
Local cLoja      	:= ""
Local cCodPro		:= ""
Local nVlUnit		:= 0
Local nQuant		:= 0
Local nPos			:= 0
Local cSrp			:= oCO1Master:GetValue("CO1_SRP")
Local lNOTAEMP	:= SuperGetMV("MV_NOTAEMP",.F.,.F.) 

//Percorre o modelo e guarda em um array todos os vencedores do processo licitatÛrio.
For nI := 1 To oCO2Detail:Length()
	oCO2Detail:GoLine(nI)
	If (oCO2Detail:GetValue('CO2_STATUS') == '1' .Or. oCO2Detail:GetValue('CO2_STATUS') == '4') .And. (IF(CO1->CO1_REMAN,oCO2Detail:GetValue('CO2_REMAN'),.T.))  
		For nI2 := 1 To oCO3Detail:Length()
			oCO3Detail:GoLine(nI2)
			If oCO3Detail:GetValue('CO3_STATUS') == '5'										
				cCodFor := oCO3Detail:GetValue('CO3_CODIGO')
				cLoja   := oCO3Detail:GetValue('CO3_LOJA')
				cCodPro := oCO3Detail:GetValue('CO3_CODPRO')
				nVlUnit := oCO3Detail:GetValue('CO3_VLUNIT')
				//-- Se utilizar a nota de 
				If lNOTAEMP .And. cSrp == "1"
					nQuant := GCP200QtSc(oModel)
				Else	
				nQuant  := oCO2Detail:GetValue('CO2_QUANT')
				EndIf					
				
				nPos := aScan( aForns, {|x| AllTrim(x[1]) + AllTrim(x[2]) == AllTrim(cCodFor) +  AllTrim(cLoja)} )
				If  nPos == 0 					
						Aadd(aForns, {cCodFor, cLoja,{{cCodPro,nVlUnit,nQuant}}})
				Else
						Aadd(aForns[nPos][3], {cCodPro,nVlUnit,nQuant})
				EndIf
			EndIf
		Next
	EndIf
Next

Return aForns

/*-------------------------------------------------------------------
{Protheus.doc} GCPXGeraNE(oModel,cMsg,)
Formato da geraÁ„o do Nota de Empenho
@author israel.escorizza	
@param oModel Modelo de dados
@since 20/01/2015
@version 1.0
-------------------------------------------------------------------*/
Function GCPXGeraNE(oModel,oModelNEP,cCodFor,cLoja,lPdC,lEdital,lAta,aAta,aDadosEdt,aGerNe,cNumero,nRevisa,cNumpla,cNumAta)
Local oCX0Master	:= Nil
Local oCX1Detail	:= Nil
Local oCX5Detail	:= Nil
Local oCO1Master	:= Nil
Local oStruCX0  	:= Nil 
Local lRet 		:= .F.
Local aForns 		:= {}
Local nPos	   		:= 0
Local nRet	   		:= 0
Local nQtdEC		:= 1
Local nX			:= 1

Default oModelNEP	:= FWLoadModel('GCPA400')
Default oModel 	:= FwModelActive()
Default aAta		:= {}
Default aGerNe	:= {}
Default cNumAta	:= ""
Default lAta		:= .F.

oModelNEP:SetOperation(3)
oModelNEP:Activate()

oCX0Master	:= oModelNEP:GetModel('CX0MASTER')
oCX1Detail	:= oModelNEP:GetModel('CX1DETAIL')
oCX5Detail	:= oModelNEP:GetModel('CX5DETAIL')

oStruCX0  	:= oCX0Master:GetStruct()

oCX0Master:SetValue("CX0_CODFOR",cCodFor)
oCX0Master:SetValue("CX0_LOJFOR",cLoja)
If lEdital	
	oCX0Master:SetValue("CX0_FILENT",aGerNe[2])
	oStruCX0:SetProperty('CX0_FILENT', MODEL_FIELD_WHEN, {||.F.})
ElseIf lAta
	oCX0Master:SetValue("CX0_FILENT",aAta[4][1][4])
	oStruCX0:SetProperty('CX0_FILENT', MODEL_FIELD_WHEN, {||.F.})
EndIf
//Campos do Contrato
If !Empty(cNumero)
	oCX0Master:SetValue("CX0_CTR",cNumero)
	oCX0Master:SetValue("CX0_REVISA",nRevisa)
	oCX0Master:LoadValue("CX0_NUMPLA",cNumpla)
Else
	oCX0Master:LoadValue("CX0_CTR","")
	oCX0Master:LoadValue("CX0_REVISA","")
	oCX0Master:LoadValue("CX0_NUMPLA","")
EndIf

If !Empty(cNumpla) .Or. lAta
	oCX0Master:SetValue("CX0_NUMATA",cNumAta)
ElseIf  Empty(cNumpla) .And. !lEdital
	oCX0Master:SetValue("CX0_NUMATA",aAta[2])
EndIf
	
If lPdC
	oCX0Master:SetValue("CX0_MODEMP",'2')
	oStruCX0:SetProperty('CX0_MODEMP', MODEL_FIELD_WHEN, {||.F.})
EndIf	

If Len(aGerNe) == 0
	If Len(aAta) == 0
		aForns := GCPXForVen(oModel)
		nPos := aScan( aForns, {|x| AllTrim(x[1]) + AllTrim(x[2]) == AllTrim(cCodFor) +  AllTrim(cLoja)} )
		oCX0Master:SetValue("CX0_TOTEMP",GCPGerGNEF(oCX1Detail,aForns,nPos))
	Else
		oCX0Master:SetValue("CX0_NUMATA",aAta[2])	
		oCX0Master:SetValue("CX0_TOTEMP",GCPGerGNEA(oModelNEP,oCX1Detail,oCX5Detail,aAta))
	EndIf
Else
	//Tratativa criada para pegar a quebra da Nota de empenho
	//Adicionado verificaÁ„o por EC devido a possibilidade de n„o estar configurado a verificaÁ„o por todas entidades.
	oCX0Master:SetValue("CX0_TOTEMP"	,GCPGerGNEQ(oModelNEP,oCX1Detail,oCX5Detail,aGerNe,aDadosEdt,cNumAta)) 
	If aScan(aGerNe[5],{|x| AllTrim(x[1]) == '1'}) > 0
		oCX0Master:SetValue("CX0_CC"		,aGerNe[5][nQtdEC][2])
		nQtdEC += 1
	EndIf
	If aScan(aGerNe[5],{|x| AllTrim(x[1]) == '2'}) > 0
		oCX0Master:SetValue("CX0_CONTA"		,aGerNe[5][nQtdEC][2])
		nQtdEC += 1
	EndIf
	If aScan(aGerNe[5],{|x| AllTrim(x[1]) == '3'}) > 0
		oCX0Master:SetValue("CX0_ITEMCT"	,aGerNe[5][nQtdEC][2])
		nQtdEC += 1
	EndIf
	If aScan(aGerNe[5],{|x| AllTrim(x[1]) == '4'}) > 0
		oCX0Master:SetValue("CX0_CVLV"		,aGerNe[5][nQtdEC][2])
		nQtdEC += 1
	EndIf 
EndIF

If !Empty(aDadosEdt[3])
	oCX0Master:LoadValue("CX0_UGEMIT",aDadosEdt[3])
	oStruCX0:SetProperty('CX0_UGEMIT', MODEL_FIELD_WHEN, {||.F.})
EndIf	

oCX0Master:LoadValue("CX0_CODEDT",aDadosEdt[1])
oCX0Master:LoadValue("CX0_NUMPRO",aDadosEdt[2])
	

oCX0Master:SetValue("CX0_TOTPED",0)
oCX0Master:SetValue("CX0_TOTDIS",oCX0Master:GetValue("CX0_TOTEMP"))

If !ISBlind()
nRet := FWExecView ("Nota de Empenho","GCPA400",MODEL_OPERATION_INSERT,,,,,,,,,oModelNEP)
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GCPGerGNEQ(oModel,oCX1Detail,aGerNe)
GeraÁ„o do GRID Nota de Empenho para fornecedores vencedores via processo licitatÛrio

@author filipe.goncalves
@param oModel Modelo de dados, oCX1Detail modelo da tabela CX1 e aGerNe array contendo as quebras e os campos 
@since 30/06/2015
@version P12.1.6
@return nSoma
/*/
//--------------------------------------------------------------------
Function GCPGerGNEQ(oModel,oCX1Detail,oCX5Detail,aGerNe,aDadosEdt,cNumAta)
Local nX 		:= 1
Local nX1		:= 1
Local nSoma 	:= 0
Local nTotEmp := 0
Local nTotSc	:= 0
Local cSubItem:= Soma1(Replicate("0", (TamSx3('CX1_SUBITE')[1])))

Default aGerNe 	:= {}
Default aDadosEdt	:=	{}
Default cNumAta	:= ""

If Len(aGerNe) > 0
	GCP017BMod(oModel, {"CX1DETAIL"},.F.)
	For nX1 := 1 to Len(aGerNe[6])
		If nX1 != 1
			oCX1Detail:addLine()
		EndIf
		//Adiciona valores no grid
		oCX1Detail:SetValue('CX1_SUBITE',cSubItem)
		oCX1Detail:SetValue('CX1_CODPRO',aGerNe[6][nX1][1])
		//FunÁ„o para popular a aba de SC
		GCPGERSCOM(oModel,oCX5Detail,aGerNe[6][nX1][4])
		oCX1Detail:LoadValue('CX1_QTDEMP',aGerNe[6][nX1][2])
		oCX1Detail:LoadValue('CX1_VLREMP',aGerNe[6][nX1][2] * aGerNe[6][nX1][3])
		oCX1Detail:SetValue('CX1_VLRDIS' ,oCX1Detail:GetValue('CX1_VLREMP'))
		nSoma += oCX1Detail:GetValue('CX1_VLREMP')
		cSubItem := Soma1(cSubItem)
	Next nX1
	//Posicionar Produto e SC na primeira linha 
	oCX1Detail:GoLine(1)
	oCX5Detail:GoLine(1)
EndIf

Return nSoma

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPGERSOCO(oModel,oCX5Detail,aGerNe)
GeraÁ„o do GRID SolicitaÁ„o de compras na Nota de empenho

@author filipe.goncalves
@param oModel Modelo de dados, oCX1Detail modelo da tabela CX1 e aGerNe array contendo as quebras e os campos 
@since 30/06/2015
@version P12.1.6
@return nSoma
/*/
//--------------------------------------------------------------------
Function GCPGERSCOM(oModel,oCX5Detail,aGerSC,aAta)
Local nX1		:= 1
Local nSoma 	:= 0
Local cSubItem	:= Soma1(Replicate("0", (TamSx3('CX1_SUBITE')[1])))

Default aGerSC := {}
Default aAta 	 := {}

If Len(aGerSC) > 0 .And. Len(aAta) == 0 
	GCP017BMod(oModel, {"CX5DETAIL"},.F.)
	For nX1 := 1 to Len(aGerSC)
		If nX1 != 1
			oCX5Detail:addLine()
		EndIf
		oCX5Detail:SetValue('CX5_NUMSC'		,aGerSC[nX1][1])
		oCX5Detail:SetValue('CX5_ITEMSC'	,aGerSC[nX1][2])
		oCX5Detail:SetValue('CX5_QUANT'		,aGerSC[nX1][3])
		oCX5Detail:SetValue('CX5_FILENT'	,aGerSC[nX1][4])
		cSubItem := Soma1(cSubItem)	
	Next nX1
ElseIf Len(aAta)> 0 .And. Len(aGerSC) == 0
	GCP017BMod(oModel, {"CX5DETAIL"},.F.)
	For nX1 := 1 to Len(aAta)
		If nX1 != 1
			oCX5Detail:addLine()
		EndIf
		oCX5Detail:SetValue('CX5_NUMSC'		,aAta[nX1][5])
		oCX5Detail:SetValue('CX5_ITEMSC'	,aAta[nX1][6])
		oCX5Detail:SetValue('CX5_QUANT'		,aAta[nX1][2])
		oCX5Detail:SetValue('CX5_FILENT'	,aAta[nX1][4])
		cSubItem := Soma1(cSubItem)	
	Next nX1
EndIf

Return 

/*-------------------------------------------------------------------
{Protheus.doc} GCPGerGNEF(oModel,cMsg,)
GeraÁ„o do GRID Nota de Empenho para fornecedores vencedores
@author israel.escorizza	
@param oModel Modelo de dados
@since 20/01/2015
@version 1.0
@return nSoma
-------------------------------------------------------------------*/
Function GCPGerGNEF(oCX1Detail,aForn,nPos)
Local nX 		:= 1
Local nSoma 	:= 0
Local cSubItem	:= Soma1(Replicate("0", (TamSx3('CX1_SUBITE')[1])))

Default aForn := GCPXForVen(oModel)

CNTA300BlMd(oCX1Detail,.F.)
For nX := 1 to len(aForn[nPos][3])
	If nX != 1
		oCX1Detail:addLine()
	EndIf
	
	//Adiciona valores no grid
	oCX1Detail:SetValue('CX1_SUBITE',cSubItem)
	oCX1Detail:SetValue('CX1_CODPRO',aForn[nPos][3][nX][1])
	oCX1Detail:LoadValue('CX1_QTDEMP',aForn[nPos][3][nX][3])
	oCX1Detail:SetValue('CX1_VLREMP',aForn[nPos][3][nX][2] * aForn[nPos][3][nX][3])
	oCX1Detail:SetValue('CX1_VLRDIS',oCX1Detail:GetValue('CX1_VLREMP'))
	
	nSoma += oCX1Detail:GetValue('CX1_VLREMP')
	cSubItem := Soma1(cSubItem)
Next
CNTA300BlMd(oCX1Detail,.T.)

Return nSoma

/*-------------------------------------------------------------------
{Protheus.doc} GCPGerGNEA(oModel,cMsg,)
GeraÁ„o do GRID Nota de Empenho para fornecedores vencedores
@author israel.escorizza	
@param oModel Modelo de dados
@since 20/01/2015
@version 1.0
@return nSoma
-------------------------------------------------------------------*/
Function GCPGerGNEA(oModelNEP,oCX1Detail,oCX5Detail,aAta)
Local nX 		:= 1
Local nSoma 	:= 0
Local cSubItem	:= Soma1(Replicate("0", (TamSx3('CX1_SUBITE')[1])))

GCP017BMod(oModelNEP, {"CX1DETAIL"},.F.)
For nX := 1 to len(aAta[4])
	If nX != 1
		oCX1Detail:addLine()
	EndIf
	
	//Adiciona valores no grid
	oCX1Detail:SetValue('CX1_SUBITE',cSubItem)
	oCX1Detail:SetValue('CX1_CODPRO',aAta[4][nX][1])
	oCX1Detail:LoadValue('CX1_QTDEMP',aAta[4][nX][2])
	oCX1Detail:LoadValue('CX1_VLREMP',aAta[4][nX][3])	
	oCX1Detail:SetValue('CX1_VLRDIS',oCX1Detail:GetValue('CX1_VLREMP'))
	GCPGERSCOM(oModelNEP,oCX5Detail,,aAta[4])
	cSubItem := Soma1(cSubItem)
	nSoma += oCX1Detail:GetValue('CX1_VLREMP')
	oCX1Detail:GoLine(1)
	oCX5Detail:GoLine(1)
Next

Return nSoma

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPGrHistNE()
FunÁ„o que gera o histÛrico da Nota de Empenho.

@author Matheus Lando Raimundo
@param aDados
	DefiniÁ„o do aDados 
	aDados[1] = CÛdigo da Nota de Empenho
	aDados[2] = Tipo do Documento
				1= Pedido de Compra
				2= Documento de Entrada
				3= Documento Habil
				4= NE ReforÁo								
				5= NE Cancelamento				
				6= NE Contrato Continuado				
			    7= NE Resto a Pagar
	aDados[3] = CÛdigo do Documento
	aDados[4] = Evento
				1=Inclusao
				2=Estorno
				3=Exclusao
	aDados[5] = Tipo de MovimentaÁ„o
				1=Debito
				2=Credito
	aDados[6] = Valores de MovimentaÁ„o
				 {{Item, Valor}}
	aDados[7] = ObservaÁ„o	 
	lDelCX2   = Indica se ser· processado a deleÁ„o das linhas do histÛrio com 
				 o valor zerado
				 
@param	lHabil	   	= MovimentaÁ„o Habil
@param oModelNE  	= Modelo dados ativo da NE
@param oMdlAct   	= Modelo a ser reativado apÛs o processamento
@param lMostraHlp = Se ser· apresentado o Help caso haja alguma divergÍncia					 

@return aRet
/*/
//-------------------------------------------------------------------
Function GCPGrHistNE(aDados,lDelCX2,lHabil,oModelNE,oMdlAct,lMostraHlp,cFilNE)
Local lRet 		:= .F.
Local cCodNE 		:= ''
Local cTpDoc		:= ''
Local cCodDoc		:= ''
Local cEvento		:= ''
Local cTpMov		:= ''
Local oCX0Master 	:= Nil
Local oCX1Detail 	:= Nil
Local oCX2Detail 	:= Nil
Local cItemX2		:= ""
Local nTotal		:= 0 
Local aVals		:= {}
Local aFiltro		:= {}
Local lSetValue  	:= .T.  
Local aError		:= {}
Local aRet			:= {}
Local lNaoGrava	:= .F.
Local cAliasCX2 	:= Nil
Local nLinha		:= 0
Local cTamDoc		:= 0
Local cCmpMvNE  	:= "" 
Local nValor		:= 0
Local cAviso		:= ""
Local lEncontrou	:= .F.
Local lMdlAtivo	:= .F.
Local nI 			:= 0
Local nX 			:= 0
Local cFilBkp		:= cFilAnt 

Default cFilNE	:= cFilAnt 
Default lDelCX2 	:= .F.
Default lHabil 	:= .F.
Default oModelNE	:= Nil
Default oMdlAct  	:= Nil
Default lMostraHlp := .T.


If cFilBkp <> cFilNE
	cFilAnt := cFilNE
EndIf  


CX0->(dbSetOrder(1))

SetlHabil(lHabil)
lMdlAtivo := oModelNE <> Nil

For nX:=1 To Len(aDados)
	nLinha  	:= 0
	lNaoGrava	:= .F.
	lEncontrou	:= .F.
	lSetValue 	:= .T.	
	nTotal		:= 0  
	aFiltro	:= {}
	aVals		:= {}
	cItemX2		:= Soma1(Replicate("0", (TamSx3('CX2_CODHIS')[1])))
	
	
	cCodNE 	:= 	aDados[nX][1]
	cTpDoc		:= 	aDados[nX][2]
	cCodDoc	:= 	aDados[nX][3]
	cEvento	:= 	aDados[nX][4]
	cTpMov		:= 	aDados[nX][5]
	//-- Localiza a Nota de Empenho
	If !lMdlAtivo
		If lEncontrou := CX0->(dbSeek(xFilial("CX0",cFilNE)+cCodNE)) 
			oModelNE := FWLoadModel('GCPA400')			
			oModelNE:SetOperation(MODEL_OPERATION_UPDATE)
			oModelNE:Activate()			
		EndIf							
	EndIf			
			
	If lEncontrou .Or. lMdlAtivo
		oCX0Master 	:= oModelNE:GetModel('CX0MASTER')
		oCX1Detail 	:= oModelNE:GetModel('CX1DETAIL')
		oCX2Detail 	:= oModelNE:GetModel('CX2DETAIL')
		GCP017BMod(oModelNE, {'CX1DETAIL', 'CX2DETAIL'}, .F.)
			
		//-- Se exclus„o, devo posicionar na linha para atualizar o valor do historico.	
		If cEvento == "3"
			Aadd(aFiltro, {'CX2_CODDOC', PADR(cCodDoc, TamSx3("CX2_CODDOC")[1])} ) 
					
			nLinha := MTFindMVC(oCX2Detail, aFiltro)
			
			If nLinha > 0
				oCX2Detail:GoLine(nLinha)
			EndIf																			
		EndIf
			
		If nLinha == 0
			oCX2Detail:GoLine(oCX2Detail:Length())																	
			If !Empty(oCX2Detail:GetValue('CX2_CODDOC'))   
				cItemX2 := Soma1(oCX2Detail:GetValue('CX2_CODHIS'))						
				oCX2Detail:AddLine()					
			EndIf
			oCX2Detail:SetValue('CX2_CODHIS',cItemX2)
			oCX2Detail:SetValue('CX2_TPDOC',cTpDoc)
			oCX2Detail:SetValue('CX2_CODDOC',cCodDoc)
			oCX2Detail:SetValue('CX2_EVENTO',cEvento)
			oCX2Detail:SetValue('CX2_TPMOV',cTpMov)										
		EndIf			
			
		//-- Array com os produtos
		aVals   := aDados[nX][6]
											
		//-- Rotina que atualiza o saldo dos produtos.
		For nI := 1 To Len(aVals)
			aFiltro := {}	
			Aadd(aFiltro, {'CX1_ITEM', aVals[nI, 1]} )
			nLinha := MTFindMVC(oCX1Detail, aFiltro)			
			If nLinha > 0
				oCX1Detail:GoLine(nLinha)
								
				Do Case				
					Case cTpDoc == "1" //-- Pedido de Compra
						If cTpMov == "1" //-- Debito
							lSetValue := oCX1Detail:SetValue('CX1_VLRPED', oCX1Detail:GetValue('CX1_VLRPED') +  aVals[nI, 2])
						ElseIf cTpMov == "2"
							lSetValue := oCX1Detail:SetValue('CX1_VLRPED', oCX1Detail:GetValue('CX1_VLRPED') -  aVals[nI, 2])
						EndIf	
						
												
					Case cTpDoc == "2" //-- Documento de Entrada
						If cTpMov == "1" //-- Debito
							lSetValue := oCX1Detail:SetValue('CX1_VLRCON', oCX1Detail:GetValue('CX1_VLRCON') +  aVals[nI, 2])
						ElseIf cTpMov == "2"
							lSetValue := oCX1Detail:SetValue('CX1_VLRCON', oCX1Detail:GetValue('CX1_VLRCON') -  aVals[nI, 2])
						EndIf
							
							
					Case cTpDoc == "3" //-- Documento H·bil
						If cTpMov == "1" //-- Debito
							lSetValue := oCX1Detail:SetValue('CX1_VLRLIQ', oCX1Detail:GetValue('CX1_VLRLIQ') +  aVals[nI, 2])
						ElseIf cTpMov == "2"
							lSetValue := oCX1Detail:SetValue('CX1_VLRLIQ', oCX1Detail:GetValue('CX1_VLRLIQ') - aVals[nI, 2])					
						End
							
					Case cTpDoc $ "4|5|6|7"
						cCmpNE	:= If(Empty(oCX0Master:GetValue('CX0_TPEMP')) , 'CX1_VLREMP', 'CX1_VLRMOV') 
						//-- Nota Comum
						If Empty(oCX0Master:GetValue('CX0_TPEMP'))
							If cTpMov == "1" //-- Debito
								lSetValue := oCX1Detail:SetValue('CX1_VLREMP', oCX1Detail:GetValue('CX1_VLREMP') -  aVals[nI, 2])
							Else								
								lSetValue := oCX1Detail:SetValue('CX1_VLREMP', oCX1Detail:GetValue('CX1_VLREMP') + aVals[nI, 2])
							EndIf								
							If lSetValue .And. cTpMov == "1" //-- Debito
								lSetValue := oCX1Detail:LoadValue('CX1_QTDEMP', oCX1Detail:GetValue('CX1_QTDEMP') -  aVals[nI, 3])
							Else								
								lSetValue := oCX1Detail:LoadValue('CX1_QTDEMP', oCX1Detail:GetValue('CX1_QTDEMP') + aVals[nI, 3])
							EndIf													
						Else
							If cTpMov == "1" //-- Debito
								lSetValue := oCX1Detail:SetValue('CX1_VLRMOV', oCX1Detail:GetValue('CX1_VLRMOV') + aVals[nI, 2])
							Else								
								lSetValue := oCX1Detail:SetValue('CX1_VLRMOV', oCX1Detail:GetValue('CX1_VLRMOV') - aVals[nI, 2])
							EndIf														
						EndIf
				EndCase				
					
				If !lSetValue		
					lNaoGrava := .T.
					If Ascan(aError, oModelNE:AerrorMessage[6]) == 0
						Aadd(aError, oModelNE:AerrorMessage[6])												
					EndIf																	
				Else						
					nTotal += aVals[nI, 2]
				EndIf
			Else
				Aadd(aError, 'Item n„o encontrado na Nota de Empenho ' + AllTrim(cCodNE))
				lNaoGrava := .T.								
			EndIf									
		Next nI
		
		If !lNaoGrava
			nValor := If(oCX2Detail:GetValue('CX2_TPMOV')=='1',oCX2Detail:GetValue('CX2_VLRMOV')*-1,oCX2Detail:GetValue('CX2_VLRMOV'))
			If cTpMov == "1"  //--Debito
				oCX2Detail:SetValue('CX2_VLRMOV',ABS(nValor - nTotal))
			Else
				oCX2Detail:SetValue('CX2_VLRMOV',ABS(nValor + nTotal))			
			EndIf					

			oCX2Detail:SetValue('CX2_OBS',aDados[nX][7])
							
			If !lMdlAtivo
				lRet := oModelNE:VldData()
		
				If lRet
					lRet := oModelNE:CommitData()
				ElseIf Ascan(aError, oModelNE:AerrorMessage[6]) == 0					
					Aadd(aError, oModelNE:AerrorMessage[6])								
				EndIf
			Else
				If !Empty(oModelNE:AerrorMessage[6])
					Aadd(aError, oModelNE:AerrorMessage[6])
					lRet := .F.
				Else
					lRet := .T.																
				EndIf
			EndIf		
												
		EndIf
		
		If lRet .And. lDelCX2
			cAliasCX2 := GetNextAlias()	
			BeginSql Alias cAliasCX2
				SELECT R_E_C_N_O_ RecCX2 FROM %table:CX2% CX2
				WHERE CX2.CX2_FILIAL = %xfilial:CX2%
					AND CX2.%NotDel%
					AND CX2.CX2_VLRMOV = 0
					
			EndSql
			While (cAliasCX2)->(!EOF())
				CX2->(dbGoto((cAliasCX2)->RecCX2))
				RecLock("CX2",.F.)
				CX2->(dbDelete())
				CX2->(MsUnLock())
			   (cAliasCX2)->(DBSkip())						
			EndDo 
			
		   (cAliasCX2)->(DbCloseArea())		
		EndIf
		GCP017BMod(oModelNE, {'CX2DETAIL'}, .T.)
		If !lMdlAtivo
			oModelNE:Deactivate()
			oModelNE 	:= Nil
		EndIf					
		If oMdlAct <> Nil
			oMdlAct:Activate()
		EndIf
	EndIf			
Next nX

If !lRet .And. lMostraHlp
	For nI := 1 To Len(aError)
		cAviso := cAviso + aError[nI] + CRLF + CRLF 
	Next nI
	Aviso( "AtenÁ„o", "N„o foi possÌvel efetuar as movimentaÁ„o na Nota de Empenho" + CRLF + CRLF + cAviso , {"Ok"}, 3)
EndIf

Aadd(aRet, lRet)
Aadd(aRet, aError)

If cFilAnt <> cFilBkp
	cFilAnt := cFilBkp
EndIf  

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ShowDivNe()
Filtra produtos do modelo de produtos

@author Flavio Lopes Rasta
@param aDocAgluNE array de itens aglutinados por nota de empenho
@since 20/01/2015
@version 12
/*/
//-------------------------------------------------------------------
Function ShowDivNe(aDocAgluNE,lAuto,lAltera)
Local aArea		:= GetArea()
Local lRet 		:= .T.
Local nX 		:= 1 
Local aShowDiv := {}

Local oDlg
Local aSize		:= MsAdvSize()
Local aPosObj := {}
Local oSize
Local aHeadCols := {}
Local aHeadCpos := {}
Local nConsumido := 0
Local cHlpAuto := ""

Default lAuto := .F.
Default lAltera	:= .F. 

lAltera	:= (Type("ALTERA") == "L" .And. ALTERA) .Or. lAltera

For nX:=1 To Len(aDocAgluNE)
	If lAltera
		CX2->(DbSetOrder(1))
		CX2->(DbSeek(xFilial("CX2")+aDocAgluNE[nX][2]))
		If Len(aDocAgluNe[nX]) >= 5
			While CX2->(! Eof()) .And. CX2->CX2_CODNE == aDocAgluNE[nX][2] 
				If Alltrim(aDocAgluNe[nX][5]) == Alltrim(CX2->CX2_CODDOC)
					nConsumido := CX2->CX2_VLRMOV
					Exit
				EndIf
				CX2->(dbSkip())
			End
		Else
			nConsumido := CX2->CX2_VLRMOV
		EndIf
	EndIf
	
	CX1->(DbSetOrder(2))
	CX1->(DbSeek(xFilial("CX1")+aDocAgluNE[nX][2]+aDocAgluNE[nX][3]))
	
	While CX1->(!Eof()) .And. CX1->(CX1_CODNE+CX1_ITEM) == aDocAgluNE[nX][2]+aDocAgluNE[nX][3]
		If IsInCallStack("MATA103") .or. IsInCallStack("MATA140")
			If aDocAgluNE[nX][4] > (CX1->CX1_VLRPED+nConsumido - CX1->CX1_VLRCON) 				
				aadd(aShowDiv, {aDocAgluNE[nX][1],aDocAgluNE[nX][4],CX1->CX1_VLRPED+nConsumido - CX1->CX1_VLRCON,.F.})								
			Endif				
		Else
			If aDocAgluNE[nX][4] > CX1->CX1_VLRDIS+nConsumido	
				Aadd(aShowDiv, {aDocAgluNE[nX][1],aDocAgluNE[nX][4],CX1->CX1_VLRDIS+nConsumido,.F.})
			EndIf			
		Endif
		
		CX1->(DbSkip())
	End
Next nX

If !Empty(aShowDiv)
	Help("",1,"AtenÁ„o" ,, STR0063,4, 1)//Itens com divergÍncia na nota de empenho
	lRet := .F.
	If !lAuto		
		Aadd(aHeadCpos,{ STR0064, 'C7_PRODUTO', '@!', 18, 0,,,'C'} )//Produto
		Aadd(aHeadCpos,{ STR0065, 'C7_VALOR', '@E 9,999,999,999,999.99', 16, 2,,, 'N'} )//Valor
		Aadd(aHeadCpos,{ STR0066, 'C7_VALOR', '@E 9,999,999,999,999.99', 16, 2,,, 'N'} )//Valor disponÌvel na Nota de Empenho
		
		DEFINE MSDIALOG oDlg TITLE STR0067 FROM 0,0 TO 300, 700 OF oMainWnd PIXEL // 'Divergencia com Nota de Empenho'
		DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
		oSize := FwDefSize():New(.F.,,,oDlg)
		oSize:AddObject( "GETDADOS",  100, 90, .T., .T. ) // Totalmente dimensionavel
		oSize:AddObject( "BUTTONS",  100, 10, .T., .T. ) // Totalmente dimensionavel
		
		oSize:lProp 	:= .T. // Proporcional             
		oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
				
		oSize:Process() 	   // Dispara os calculos
		
		oGetDiver := MsNewGetDados():New(oSize:GetDimension("GETDADOS","LININI"),;
										oSize:GetDimension("GETDADOS","COLINI"),;
			     						oSize:GetDimension("GETDADOS","LINEND"),; 
			     						oSize:GetDimension("GETDADOS","COLEND"),;
		    							,;
		    							,;
		    							,;
		    							,;
		    							,;
		    							,;
		    							999,;
		    							,;
		    							,;
		    							,;
		    							oDlg,;
		    							@aHeadCpos,;
		    							@aShowDiv)
		    								    																 							 							 				 					 										 																	
		oDlg:Refresh()
		DEFINE SBUTTON oBut2 FROM 135, 310  TYPE 1 ACTION ( oDlg:End() )  ENABLE of oDlg	 		 
		ACTIVATE MSDIALOG oDlg CENTERED
	Else
		For nX:=1 To Len(aShowDiv)
			Help("",1,STR0068,,I18N("Item: #[Produto]# Valor Pedido: #[Valor]# Valor na NE: #[Valor na nota]#",{aShowDiv[nX][1],aShowDiv[nX][2],aShowDiv[nX][3]}), 1, )
		Next nX
	Endif
Endif

RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc}GCPXRefCan
FunÁ„o para separar o ReforÁo e Cancelamento fazendo a chamada da tela Nota de Empenho.

@author taniel.silva
@since 27/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GCPXRefCan(aDados)
Local cCodNE  		
Local cItem	
Local nVlAnt
Local nVlAtu	
Local nDifer
Local nX			:= 0
Local nY			:= 0
local lRet 		:= .T.
Local aCancela	:= {}
Local aReforco	:= {}
Local aAgluCan	:= {}

CX0->(dbSetOrder(1))

For nX:=1 To Len(aDados)
	For nY:=2 To Len(aDados[nX])
		cCodNE := aDados[nX][1]
		cItem 	:= aDados[nX][nY][1]
		nVlAnt	:= aDados[nX][nY][2]
		nVlAtu	:= aDados[nX][nY][3]
		
		If CX0->(dbSeek(xFilial("CX0")+cCodNE)) 
			nDifer := nVlAtu - nVlAnt 		
			If  nVlAtu > nVlAnt 			
				aAdd(aReforco,{})
			  	aAdd(aTail(aReforco),cCodNE)
			  	aAdd(aTail(aReforco),cItem)
			  	aAdd(aTail(aReforco),nDifer) 		  
			ElseIf nVlAtu < nVlAnt
			  	aAdd(aCancela,{})
			  	aAdd(aTail(aCancela),cCodNE)
			  	aAdd(aTail(aCancela),cItem)
			  	aAdd(aTail(aCancela),nDifer) 		  			
			EndIf	
		EndIf	
	Next nY
Next nX
	
If !Empty(aReforco)
	lRet := GCPAgluRef(aReforco)
EndIf	

If !Empty(aCancela)
	lRet := GCPAgluCan(aCancela)
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc}GCPAgluRef
FunÁ„o para aglutinar os itens por tipo de documento ReforÁo.

@author taniel.silva
@since 27/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GCPAgluRef(aReforco)	
Local nY			:= 0
Local nZ			:= 0
local lRet 		:= .F.
Local aAgluRef	:= {}


For nY := 1 To Len(aReforco)
	nPos := aScan(aAgluRef,{|x| AllTrim(x[1])== AllTrim(aReforco[nY][1])}) 
 	If nPos > 0
 		aAdd(aAgluRef[nPos][2],{aReforco[nY][2],aReforco[nY][3]})
 	Else
 		aAdd(aAgluRef,{})	 		
	  	aAdd(aTail(aAgluRef), aReforco[nY][1])
 		aAdd(aTail(aAgluRef),{{aReforco[nY][2],aReforco[nY][3]}})
 	EndIf	 	
Next nY

		
If !Empty(aAgluRef)
	For nZ := 1 To Len(aAgluRef)
		lRet := GCPAReforc(aAgluRef[nZ])		
	Next nZ	 			
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc}GCPAgluCan
FunÁ„o para aglutinar os itens por tipo de documento Cancelamento.

@author taniel.silva
@since 27/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GCPAgluCan(aCancela)
Local nY			:= 0
Local nZ			:= 0
local lRet 		:= .F.
Local aAgluCan	:= {}

For nY := 1 To Len(aCancela)
	nPos := aScan(aAgluCan,{|x| AllTrim(x[1])== AllTrim(aCancela[nY][1])}) 
 	If nPos > 0
 		aAdd(aAgluCan[nPos][2],{aCancela[nY][2],aCancela[nY][3]})
 	Else
 		aAdd(aAgluCan,{})	 		
	  	aAdd(aTail(aAgluCan), aCancela[nY][1])
 		aAdd(aTail(aAgluCan),{{aCancela[nY][2],aCancela[nY][3]}})
 	EndIf	 	
Next nY	
		
If !Empty(aAgluCan)
	For nZ := 1 To Len(aAgluCan)
		lRet := GCP400Canc(aAgluCan[nZ])		
	Next nZ	 			
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}GCPBissest
FunÁ„o verifica quantos dias existem num determinado perÌodo, considerando os anos bissestos.
Par‚metros:
nVal È o valor de referÍncia para o c·lculo
dRef È a data de referÍncia, caso n„o seja informada ser· adotada a data base, pode ser informada em formato de caracter ('dd/mm/aaa')
cMetodo determina qual ser· a unidade base para o c·lculo: Meses ("M") ou Anos ("A"), caso n„o seja informado ser· adotado MÍs como referÍncia

@author jose.eulalio
@since 28/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GCPBissest(nVal,dRef,cBase)
Local dNewData	:= dDataBase

DEFAULT nVal 	:= 0
DEFAULT dRef 	:= dDataBase
DEFAULT cBase	:= "M"

If ValType(dRef) == "C"
	dRef := CtoD(dRef)
EndIf

Do Case
	Case Upper(cBase) == "A"
		dNewData := YearSum(dRef,nVal)
	OtherWise
		dNewData := MonthSum(dRef,nVal)		
EndCase

nDias := dNewdata - dRef

Return nDias

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPSUMITEM()
Calcula o valor total do item do processo licitatÛrio.

@author Antenor Silva
@since 22/05/2015
@version 12.0
/*/
//-------------------------------------------------------------------
Function GCPSUMITEM()
Local oModel		:= FWModelActive()
Local lUsaLote	:= oModel:GetId() == 'GCPA201'
Local oModSum		:= IIF(lUsaLote,oModel:GetModel("CP3DETAIL"),oModel:GetModel("CO2DETAIL"))
Local aSaveLines	:= FWSaveRows()
Local nRet			:= 0
Local nX			:= 0

If lUsaLote
	nRet = oModSum:GetValue("CP3_VLRTOT")
Else
	nRet = oModSum:GetValue("CO2_VLESTI") * oModSum:GetValue("CO2_QUANT")
EndIf

FWRestRows(aSaveLines)
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc}GCPAtPrExc
FunÁ„o que verifica o ano da NE e atualiza ou n„o para "Resto a Pagar"

@author Matheus Lando Raimundo
@since 29/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GCPAtPrExc(cFil,cCodNE)
Local lRet	  	:= .F. 	
Default cFil 	:= xFilial('CX0')

CX0->(dbSetOrder(1))
If CX0->(dbSeek(cFil+cCodNE))
	If Year(CX0->CX0_PRZEXC) < Year(dDataBase)
		RecLock("CX0",.F.)
		CX0->CX0_TPEMP := '4'
		CX0->(MsUnLock())
		lRet := .T.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}Monta
FunÁ„o Para montar chave de entidades EC

@author filipe.goncalves
@since 29/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function GCPMonChav(cNumSC)
Local cParam	:= SuperGetMv("MV_GCPECNE",.F.,"")
Local aCTBEnt	:= CTBEntArr()
Local aRet 	:= {""/*cChave*/,{}/*aEntCont*/}
Local nA		:= 0
Local nY		:= 0

SC1-> (dbSetOrder(1))
If SC1-> (DbSeek(xFilial('SC1')+ cNumSC))
	If "1" $ cParam
		aRet[1] += SC1->C1_CC
		aadd(aRet[2], {'1',SC1->C1_CC})
	EndIf
	If "2" $ cParam
		aRet[1] += SC1->C1_CONTA
		aadd(aRet[2], {'2',SC1->C1_CONTA})
	EndIf
	If "3" $ cParam 
		aRet[1] += SC1->C1_ITEMCTA
		aadd(aRet[2], {'3',SC1->C1_ITEMCTA})
	EndIf
	If "4" $ cParam
		aRet[1] += SC1->C1_CLVL
		aadd(aRet[2], {'4',SC1->C1_CLVL})
	EndIf
	For nA := 1 To Len(aCTBEnt)
		If aCTBEnt[nA] $ cParam .And. SC1->(FieldPos("C1_EC"+aCTBEnt[nA]+"DB"))
			aRet[1] += SC1->&("C1_EC"+aCTBEnt[nA]+"DB")
			aadd(aRet[2], {aCTBEnt[nA],&("C1_EC"+aCTBEnt[nA]+"DB")})
		EndIf	
	Next nA
EndIf
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPXNEMP(oModel)
Rotina de Inclus„o de Nota de Empenho pelo processo licitatÛrio

@author filipe.goncalves
@since 24/06/2015
@version P12.1.6
@param oModel Modelo ativo
@return Nil
/*/
//------------------------------------------------------------------
Function GCPXNEMP(aItCtr,cCodEdit,cNumProc,cNumero,nRevisa,cNumpla,cFilEdit,cNumAta,lAta,aAtaNe,lPed)
Local oModel	 		:= NIL 
Local oModelCO3		:= NIL 
Local oModelPrd		:= NIL 
Local oModelCP4		:= NIL 
Local oModelCO1		:= NIL
Local aGerNe 			:= {}
Local aDadosEdt		:= {}
Local aEnt				:= {}
Local aSaveLines		:= FWSaveRows()
Local aGCPMonChav		:= {,}
Local cParam			:= SuperGetMv("MV_GCPECNE",.F.,"")
Local cSRP				:= ""	
Local cProd			:= ""
Local cValor			:= ""
Local cCodFor 		:= ""
Local cLoja			:= ""
Local cFilEnt			:= ""
Local cEntCont		:= ""
Local cChave			:= ""
Local cMsg				:= ""
Local cFilBkp 		:= ""
Local nPos				:= 0
Local nPosProd		:= 0
Local nI				:= 0
Local nI2				:= 0
Local nY				:= 0
Local nX				:= 0
Local nCO2				:= 0
Local nGravou			:= 0
Local lEdit			:= Empty(aItCtr) .and. !lAta 
Local lPdc				:= .F.
Local lSCX				:= .T.
Local lRet				:= .T.
Local lLote			:= (CO1->CO1_AVAL == '2') 
Local lAuto			:= IsBlind()

Default	aItCtr		:= {}
Default	aAtaNe		:= {}
Default	cCodEdit	:= ""
Default	cNumProc	:= ""
Default	cNumero	:= ""
Default	cNumpla	:= ""
Default	cFilEdit	:= ""
Default	cNumAta	:= ""
Default	nRevisa	:= 0
Default	lAta		:= .F.
Default lPed	:= .F.

If CO1->CO1_STATUS == "B"
	lRet := .F.
EndIf

If lRet
	//-- Altera filial
	If cFilAnt # cFilEdit .and. !Empty( cFilEdit)
		cFilBkp:= cFilAnt
		SM0->(dbSetOrder(1))
		SM0->(dbSeek(cEmpAnt+cFilEdit))
		cFilAnt := FWCodFil()
	EndIf
	
	If !lEdit 
		dbSelectArea("CO1")
		CO1->(DbsetOrder(1))
		CO1->(dbSeek(cFilEdit+cCodEdit+cNumProc))
	EndIf
	
	If !lLote 
		oModel	 	:= FWLoadModel('GCPA200')
		oModel:SetOperation(MODEL_OPERATION_VIEW)
		oModel:Activate()
		
	Else
		oModel	:= FwLoadModel('GCPA201')
		oModel:SetOperation(MODEL_OPERATION_VIEW)
		oModel:Activate()
		
		oModelCP3	:= oModel:GetModel("CP3DETAIL")
		oModelCP6	:= oModel:GetModel("CP6DETAIL")		
	EndIf	
	oModelCO1	:= oModel:GetModel("CO1MASTER")
	oModelPrd	:= oModel:GetModel("CO2DETAIL")
	oModelCO3	:= oModel:GetModel('CO3DETAIL')
	oModelPrd	:= oModel:GetModel("CO2DETAIL")
	oModelCP4	:= oModel:GetModel("CP4DETAIL")
	
	//-- Restaura filial
	If !Empty(cFilBkp)
		SM0->(dbSetOrder(1))
		SM0->(dbSeek(cEmpAnt+cFilBkp))
		cFilAnt := FWCodFil()
	EndIf
	
	cSRP		:= oModelCO1:GetValue('CO1_SRP')
	
	/*
	Estrutura do array aGerNE
	
	1- Chave de quebra (Filial de Entrega+Fornecedor+Loja+EntidadeContabil)
	2- Filial de Entrega
	3- Forncedor
	4- Loja
	5- Array aGcpne
		1- Codigo do Parametro
		2- Valor Entidade cont·bil
	6- Array aProd
		1- Produto
		2- Quantidade
		3- Valor Unit·rio
		4- Array aSc
			1- Codigo da SC
			2- Item SC
			3- Qauntidade SC
	*/
	//Verifica ganhador 
	If lEdit
		A200KeepWn(oModelCO3,.F.)
	EndIf
	
	Aadd(aDadosEdt,oModel:GetModel("CO1MASTER"):GetValue('CO1_CODEDT'))
	Aadd(aDadosEdt,oModel:GetModel("CO1MASTER"):GetValue('CO1_NUMPRO'))
	Aadd(aDadosEdt,oModel:GetModel("CO1MASTER"):GetValue('CO1_CODORG'))
	
	If !lAta .And. lEdit
		nY := IIF(!lLote,oModelPrd:Length(), oModelCP3:Length())
	ElseIf !lAta .And. !lEdit
		ny := Len(aItCtr)//-- Tratamento efetuado quando È CTR ler a quantidade do array aItCtr
	Else 
		nY := 1 //-- Tratamento efetuado quando È Ata gera sÛ um produto
	EndIf
	
	If Empty(cNumATa) .And. lEdit
		lPdC := IF(oModelCO1:GetValue('CO1_COPC') == '2' .And. oModelCO1:GetValue('CO1_GERDOC')=='1',.T.,.F.)
	Else
		lPdC := lPed
	EndIf
	
	If (oModelCO1:GetValue('CO1_MODALI') <> 'LL') .And. (oModelCO3:GetValue('CO3_STATUS') == '5') .And. (oModelCO1:GetValue('CO1_STATUS') == '1') .Or. !lEdit .Or. lAta
		If !lLote	
			For nI := 1 To nY 
				If lEdit .And. !lAta					
					oModelPrd:GoLine(nI)
				Else
					// Criar posicionamento do item do pedido para o item do Proc. LicitatÛrio 
					If !lAta
					aArea:= Getarea()
					CO2->(Dbsetorder(2))
					CO2->(MsSeek(XFilial('CO2')+cCodEdit+cNumProc+ aItCtr[nI][1]))
					nPos := Val(CO2->CO2_ITEM)
					RestArea(aArea)
				Else
					CO2->(MsSeek(XFilial('CO2')+cCodEdit+cNumProc+ aAtaNe[1]))
					nPos := Val(CO2->CO2_ITEM)
				EndIf
				If nPos > 0 
					oModelPrd:GoLine(nPos)
				EndIf	
			EndIf 
			For nI2 := 1 To oModelCO3:Length()
				oModelCO3:GoLine(nI2)
				If lAta .Or. oModelCO3:GetValue('CO3_STATUS') == '5'
					cCodFor := oModelCO3:GetValue('CO3_CODIGO') // COD DO PARTICIPANTE
					cLoja   := oModelCO3:GetValue('CO3_LOJA') // LOJA DO PARTICIPANTE			
					cProd := oModelPrd:GetValue('CO2_CODPRO') // CODIGO DO PRODUTO DO EDITAL
					cValor:= oModelCO3:GetValue('CO3_VLUNIT')// NULO ??
					Exit
				EndIf
			Next nI2
			
			For nI2 := 1 To oModelCP4:Length()
				oModelCP4:GoLine(nI2)
				//Adicionado para verificar ausÍncia de solicitaÁıes
				If Empty(oModelCP4:GetValue('CP4_NUMSC'))
					Exit
				EndIf
				//Montagem do Array de Nota de Empenho
				If (oModelCP4:GetValue('CP4_EMPENH') == .F.)
					cFilEnt := oModelCP4:GetValue('CP4_FILENT')
					//Montar Entidade de Quebra
					aGCPMonChav	:= GCPMonChav(oModelCP4:GetValue('CP4_NUMSC')+ oModelCP4:GetValue('CP4_ITEMSC'))
					cEntCont		:= aGCPMonChav[1]
					aEnt			:= aGCPMonChav[2]
					//Cria a chave de quebra
					cChave 		:= cFilEnt + cCodFor + cLoja + cEntCont
					If (nPos := aScan( aGerNe, {|x|, x[1] == cChave}) ) == 0 					
						Aadd(aGerNe, {cChave,cFilEnt,cCodFor,cLoja,aEnt,{/*aProd*/}})
						nPos:= Len(aGerNe)
					EndIf
					If (nPosProd := aScan( aGerNe[nPos][6], {|x| x[1] == cProd}) ) == 0 .and. !lAta 	
						AaDD(aGerNe[nPos][6], {cProd, oModelCP4:GetValue('CP4_QUANT'), cValor, {/*aSC*/}})
						nPosProd:= Len(aGerNe[nPos][6])
					ElseIf (nPosProd := aScan( aGerNe[nPos][6], {|x| x[1] == cProd}) ) == 0 .and. lAta
						AaDD(aGerNe[nPos][6], {cProd, aAtaNe[2], cValor, {/*aSC*/}})
						nPosProd:= Len(aGerNe[nPos][6])
						Exit
					Else
						aGerNe[nPos][6][nPosProd][2]+= oModelCP4:GetValue('CP4_QUANT')			
					EndIf
					aadd(aGerNe[nPos][6][nPosProd][4], {oModelCP4:GetValue('CP4_NUMSC'), oModelCP4:GetValue('CP4_ITEMSC'), oModelCP4:GetValue('CP4_QUANT'), oModelCP4:GetValue('CP4_FILENT') })
				Else
					cMsg += "SolicitaÁ„o " + oModelCP4:GetValue('CP4_NUMSC') + " Item " + oModelCP4:GetValue('CP4_ITEMSC') + CRLF	    
				EndIf
			Next nI2
		Next nI
		Else
			For nI := 1 To nY 
				If lEdit .And. !lAta								
					oModelCP3:GoLine(nI)
				Else
					// Criar posicionamento do item do pedido para o item do Proc. LicitatÛrio 
					If !lAta
						aArea:= Getarea()
						CO2->(Dbsetorder(2))
						CO2->(MsSeek(XFilial('CO2')+cCodEdit+cNumProc+ aItCtr[nI][1]))
						nPos := Val(CO2->CO2_ITEM)
						RestArea(aArea)
					Else
						CO2->(MsSeek(XFilial('CO2')+cCodEdit+cNumProc+ aAtaNe[1]))
						nPos := Val(CO2->CO2_ITEM)
					EndIf
					If nPos > 0 
						//oModelPrd:GoLine(nPos)
						oModelCP3:GoLine(nPos)
					EndIf	
				EndIf
				
				For nCO2 := 1 To oModelPrd:Length()
					oModelPrd:GoLine(nCO2)
					oModelCP6:GoLine(nCO2)
					For nI2 := 1 To oModelCO3:Length()
						oModelCO3:GoLine(nI2)
						If lAta .Or. oModelCO3:GetValue('CO3_STATUS') == '5'
							cCodFor	:= oModelCO3:GetValue('CO3_CODIGO') // COD DO PARTICIPANTE
							cLoja  	:= oModelCO3:GetValue('CO3_LOJA') // LOJA DO PARTICIPANTE			
							cProd		:= oModelPrd:GetValue('CO2_CODPRO') // CODIGO DO PRODUTO DO EDITAL
							cValor		:= oModelCP6:GetValue('CP6_PRCUN')
							Exit
						EndIf
					Next nI2
					
					For nI2 := 1 To oModelCP4:Length()
						oModelCP4:GoLine(nI2)
						//Adicionado para verificar ausÍncia de solicitaÁıes
						If Empty(oModelCP4:GetValue('CP4_NUMSC'))
							Exit
						EndIf
						//Montagem do Array de Nota de Empenho
						If (oModelCP4:GetValue('CP4_EMPENH') == .F.)
							cFilEnt := oModelCP4:GetValue('CP4_FILENT')
							//Montar Entidade de Quebra
							aGCPMonChav	:= GCPMonChav(oModelCP4:GetValue('CP4_NUMSC')+ oModelCP4:GetValue('CP4_ITEMSC'))
							cEntCont		:= aGCPMonChav[1]
							aEnt			:= aGCPMonChav[2]
							//Cria a chave de quebra
							cChave 		:= cFilEnt + cCodFor + cLoja + cEntCont
							If (nPos := aScan( aGerNe, {|x|, x[1] == cChave}) ) == 0 					
								Aadd(aGerNe, {cChave,cFilEnt,cCodFor,cLoja,aEnt,{/*aProd*/}})
								nPos:= Len(aGerNe)
							EndIf
							If (nPosProd := aScan( aGerNe[nPos][6], {|x| x[1] == cProd}) ) == 0 .and. !lAta 	
								AaDD(aGerNe[nPos][6], {cProd, oModelCP4:GetValue('CP4_QUANT'), cValor, {/*aSC*/}})
								nPosProd:= Len(aGerNe[nPos][6])
							ElseIf (nPosProd := aScan( aGerNe[nPos][6], {|x| x[1] == cProd}) ) == 0 .and. lAta
								AaDD(aGerNe[nPos][6], {cProd, aAtaNe[2], cValor, {/*aSC*/}})
								nPosProd:= Len(aGerNe[nPos][6])
								Exit
							Else
								aGerNe[nPos][6][nPosProd][2]+= oModelCP4:GetValue('CP4_QUANT')			
							EndIf
							aadd(aGerNe[nPos][6][nPosProd][4], {oModelCP4:GetValue('CP4_NUMSC'), oModelCP4:GetValue('CP4_ITEMSC'), oModelCP4:GetValue('CP4_QUANT'), oModelCP4:GetValue('CP4_FILENT') })
						Else
							cMsg += "SolicitaÁ„o " + oModelCP4:GetValue('CP4_NUMSC') + " Item " + oModelCP4:GetValue('CP4_ITEMSC') + CRLF	    
						EndIf
					Next nI2
				Next nCO2								
			Next nI			
		EndIf
		If !Empty(cMsg)
			Help(,,"SCJAEMP",,"SolicitaÁıes abaixo j· empenhadas e n„o ser· possivel geraÁ„o de uma nova Nota de Empenho." + CRLF + CRLF;
				+ "Somente ser· possivel fazer uma nota de reforÁo para estas SC." + CRLF + CRLF ;
				+ cMsg, 1, 0) 
		EndIf
		
		Begin Transaction
			For nI := 1 To Len(aGerNe)
				//"Gerando Nota de Empenho " + " de "
				If lAuto
					nGravou := GCPXGeraNE(oModel,,aGerNe[nI][3],aGerNe[nI][4],lPdC,IIF(Empty(aGerNe) .And. Empty(NumAta),.F., .T.),IIf (Empty(cNumAta),cSRP == '1', .T.),,aDadosEdt,aGerNe[nI]	,cNumero,nRevisa,cNumpla,cNumAta)
				Else
					MsgRun("Gerando Nota de Empenho  " + AllTrim(STR(nI)) + " de " + AllTrim(STR(Len(aGerNe))), "Processando" ,{||nGravou := GCPXGeraNE(oModel,,aGerNe[nI][3],aGerNe[nI][4],lPdC,IIF(Empty(aGerNe) .And. Empty(NumAta),.F., .T.),IIf (Empty(cNumAta),cSRP == '1', .T.),,aDadosEdt,aGerNe[nI]	,cNumero,nRevisa,cNumpla,cNumAta)}) 
				EndIf
				
				If nGravou != 0 
					If (Len(aGerNe) == 1) 
						DisarmTransaction()
						Help("",1,"GCPXGERANE")//OpÁ„o cancelada pelo operador. N„o gravou a Nota de Empenho!
					ElseIf MsgYesNo(STR0069)
						DisarmTransaction()
						Help("",1,"GCPXGERANE")//OpÁ„o cancelada pelo operador. N„o gravou a Nota de Empenho!
						Exit
					EndIf
				EndIf
			Next nI
			
			If Len(aGerNe)==0
				Help(,,"EMPSEMSC",,"N„o h· solicitaÁıes disponÌveis para empenho, favor verificar.", 1, 0)
			EndIf
		End Transaction
	Else 
		Help("",1,"GCP200NE")//Proc. LicitatÛrio n„o possui vencedor ou j· est· encerrado, por isso n„o pode gerar Notas de Empenho!           
	EndIf
	
	If !lAuto
	oModel:Deactivate()
	EndIf
	
	FWRestRows( aSaveLines )
Else
	Help("",1,"A200VldSusp",,STR0072,4,1) //Processo licitatÛrio suspenso, permitido apenas visualizaÁ„o.
EndIf

Return (nGravou == 0)

/*-------------------------------------------------------------------
{Protheus.doc} A200MDCO2()
FunÁ„o para calculo do valor unitario(licitante) na modalidade maior
desconto

@author Henrique Cunha
@since 03/06/2015
@version P12
-------------------------------------------------------------------*/

Function A200MDCO2()
Local aSaveLines	:= FWSaveRows()
Local oModel		:= FwModelActive()
Local oView		:= FwViewActive()
Local oMCO3Det	:= oModel:GetModel('CO3DETAIL')
Local oCO1Mod		:= oModel:GetModel('CO1MASTER')
Local oModelCO2	:= oModel:GetModel('CO2DETAIL')
Local lMD			:= (oCO1Mod:GetValue("CO1_TIPO") == "MD")
Local lLote		:= oModel:GetId() == 'GCPA201' 
Local nDesco		:= oMCO3Det:GetValue("CO3_DESCON")
Local nPreco		:= 0
Local nCalcl		:= 0
Local nI			:= 0
Local lRet			:= .T.
Local nVest		:= 0
 
If lMD
	oMCO3Det:GetStruct():SetProperty('CO3_VLUNIT', MODEL_FIELD_WHEN,{||.T.})
	For nI := 1 To oMCO3Det:Length()
		oMCO3Det:GoLine(nI)
	 	If !oMCO3Det:IsDeleted() .And. !Empty(oMCO3Det:GetValue('CO3_CODIGO')) 
		 	If lLote
			 	nPreco	:= FwFldGet("CP3_VLRTOT")
			  	nCalc 	:= nPreco-(nPreco*nDesco/100)
			 	oMCO3Det:SetValue("CO3_VLUNIT",nCalc)			 	
		 	Else
			 	nPreco	:= FwFldGet("CO2_VLESTI")
			  	nCalc 	:= nPreco-(nPreco*nDesco/100)
			 	oMCO3Det:SetValue("CO3_VLUNIT",nCalc)
		 	Endif
		EndIf		 	
	Next nI
	oMCO3Det:GetStruct():SetProperty('CO3_VLUNIT', MODEL_FIELD_WHEN,{||oCO1Mod:GetValue('CO1_TIPO') <> 'MD'})
	//oView:Refresh() 	
EndIf
 
FWRestRows(aSaveLines)
 
Return lRet

/*-------------------------------------------------------------------
{Protheus.doc} A200MDCO3()
FunÁ„o para calculo do valor unitario(licitante) na modalidade maior
desconto

@author Henrique Cunha
@since 03/06/2015
@version P12
-------------------------------------------------------------------*/

Function A200MDCO3()

 Local oModel	:= FwModelActive()
 Local oMCO3Det	:= oModel:GetModel('CO3DETAIL')
 Local oCO1Mod	:= oModel:GetModel('CO1MASTER')
 
 Local nDesco	:= FwFldGet("CO3_DESCON")
 Local nPreco	:= 0
 Local nCalcl	:= 0
 
 Local lMD		:= (FwFldGet("CO1_TIPO") == "MD")
 Local lLote	:= oModel:GetId() == 'GCPA201'
 Local nI		:= 0
 Local lRet	:= .T.

 Local oView	:= FwViewActive()
  
If lMD
	oMCO3Det:GetStruct():SetProperty('CO3_VLUNIT', MODEL_FIELD_WHEN,{||.T.})
	If lLote
	 	nPreco	:= FwFldGet("CP3_VLRTOT")
	  	nCalc 	:= nPreco-(nPreco*nDesco/100)
	 	oMCO3Det:SetValue("CO3_VLUNIT",nCalc)
	 Else
		nPreco	:= FwFldGet("CO2_VLESTI")
	  	nCalc 	:= nPreco-(nPreco*nDesco/100)	 	
	 	oMCO3Det:SetValue("CO3_VLUNIT",nCalc)	 	
	EndIf		 	
	oMCO3Det:GetStruct():SetProperty('CO3_VLUNIT', MODEL_FIELD_WHEN,{||oCO1Mod:GetValue('CO1_TIPO') <> 'MD'})
	oView:Refresh() 	
EndIf
  
Return lRet


/*---------------------------------------------------------------------
{Protheus.doc} A200MDCO1()
FunÁ„o para validaÁ„o da troca de tipo a partir do maior desconto "MD"

@author Henrique Cunha
@since 03/06/2015
@version P12
----------------------------------------------------------------------*/

Function A200MDCO1(cTpMod)

 Local oModel	:= FwModelActive()
 Local oCO3Det := oModel:GetModel('CO3DETAIL')
 Local oCO1Mod := oModel:GetModel('CO1MASTER')
 Local oView	:= FwViewActive()
 Local oModPai

 
 Local cTitulo	:= "MudanÁa do Tipo"
 Local cTexto	:= "A troca do Tipo de Modalidade Maior desconto para outra modalidade pode ocasionar na redefiniÁ„o de algumas informaÁıes de Licitantes deseja continuar?"
 
 Local nLinF	:= 0
 Local nLinP	:= 0
 Local nP		:= 0
 Local nF		:= 0
 
 Local lLote	:= oModel:GetId() == 'GCPA201'
 Local lRet		:= .T.
  	
 If lLote
  	oModPai := oModel:GetModel('CP3DETAIL') 
 Else
  	oModPai := oModel:GetModel('CO2DETAIL')
 Endif

 If  (cTpMod == "MD") .Or.  MSGYESNO(cTexto, cTitulo)
	 nLinP := oModPai:GetQTDLine()
	 	
	 For nP := 1 To nLinP
	 	oModPai:GoLine(nP)
	 	nLinF := oCO3Det:GetQTDLine()
	 		
	 	For nF := 1 To nLinF
	 		oCO3Det:GoLine(nF)
	 		oCO3Det:GetStruct():SetProperty('CO3_VLUNIT', MODEL_FIELD_WHEN,{||.T.})
	 		oCO3Det:GetStruct():SetProperty('CO3_DESCON', MODEL_FIELD_WHEN,{||.T.})
	 		oCO3Det:SetValue("CO3_VLUNIT",0)
	 		oCO3Det:SetValue("CO3_DESCON",0)
	 		oCO3Det:GetStruct():SetProperty('CO3_DESCON', MODEL_FIELD_WHEN,{||oCO1Mod:GetValue('CO1_TIPO') == 'MD'})
	 		oCO3Det:GetStruct():SetProperty('CO3_VLUNIT', MODEL_FIELD_WHEN,{||oCO1Mod:GetValue('CO1_TIPO') <> 'MD'})	 			 	
	 		oCO3Det:DeleteLine()
	 		
	 	Next nF 
	 	
	 Next nP 
	 oCO3Det:GoLine(1)
 EndIf
  	 
oView:Refresh()
 
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} GCPFltCX1()
Consulta especifica CX1

@author Matheus Lando Raimundo
@since 24/06/2015
@version P12.1.6
@param oModel Modelo ativo
@return Nil
/*/
//------------------------------------------------------------------
Function GCPFltCX1()

Local oModel         := FWModelActive()
Local oCPEDetail     := oModel:GetModel('CPEDETAIL')
Local oCPYDetail     := oModel:GetModel('CPYDETAIL')
Local oCPHMaster     := oModel:GetModel('CPHMASTER')
Local lRet           := .T.
Local oBrowse        := Nil
Local cNEAls         := GetNextAlias()
Local nSuperior      := 0
Local nEsquerda      := 0
Local nInferior      := 0
Local nDireita       := 0
Local oDlgTela       := Nil
Local cNEQry         := ""
Local cNumAta        := oCPHMaster:GetValue("CPH_NUMATA")
Local cProd        	:= oCPYDetail:GetValue("CPY_CODPRO")
Local cTabGrid       := SUBSTR(ReadVar(),4,3)
Local cValNE         := oCPEDetail:GetValue("CPE_CODNE")
Local cITemNE        := ""
Local oView			:= FwViewActive()
/*
* DefiniÁ„o do Ìndice da Consulta Padr„o
*/
Local aIndex         := {"CX0_CODNE"}
/*
* DefiniÁ„o da DescriÁ„o da Chave de Pesquisa da Consulta Padr„o
*/
Local aSeek               := {{ "Nota de Empenho", {{"Nota de Empenho","C",15,0,"",,}} }} //"Nota de Empenho"#"Nota de Empenho"

cRetNE := ""


cNEQry := " SELECT " + CRLF
cNEqRY += " CX0.CX0_FILIAL, " + CRLF
cNEQry += " CX0.CX0_CODNE,     " + CRLF
cNEQry += " CX1.CX1_ITEM     " + CRLF
cNEQry += " FROM " + RetSqlName("CX0") + " CX0 " + CRLF
cNEQry += " INNER JOIN " + RetSqlName("CX1") + " CX1 " + CRLF
cNEQry += " ON CX0.CX0_CODNE = CX1.CX1_CODNE " + CRLF
cNEQry += " WHERE " + RetSqlCond("CX0") + CRLF
cNEQry += " AND " + RetSqlCond("CX1") + CRLF
cNEQry += " AND CX0.CX0_NUMATA = '" + cNumAta + "' " + CRLF
cNEQry += " AND CX1.CX1_CODPRO = '" + cProd + "' " + CRLF


nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800
 
DEFINE MSDIALOG oDlgTela TITLE "Nota de Empenho" FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL //"Nota de Empenho"
 
oBrowse := FWFormBrowse():New()
oBrowse:SetDescription("Notas de Empenho") // "Notas de Empenho"
oBrowse:SetAlias(cNEAls)
oBrowse:SetDataQuery()
oBrowse:SetQuery(cNEQry)
oBrowse:SetOwner(oDlgTela)
oBrowse:SetDoubleClick({ || cRetNE := (oBrowse:Alias())->CX0_CODNE, cITemNE := (oBrowse:Alias())->CX1_ITEM, oDlgTela:End()})
oBrowse:AddButton( OemTOAnsi("Confirmar"), {|| cRetNE := (oBrowse:Alias())->CX0_CODNE, cITemNE := (oBrowse:Alias())->CX1_ITEM, oDlgTela:End() } ,, 2 ) //"Confirmar"
oBrowse:AddButton( OemTOAnsi("Cancelar"),  {|| cRetNE := "", lRet := .F., oDlgTela:End() } ,, 2 ) //"Cancelar"
oBrowse:DisableDetails()
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetSeek({||.T.},aSeek)
 
ADD COLUMN oColumn DATA { ||  CX0_FILIAL } TITLE "Filial" SIZE 15 OF oBrowse //"Filial"
ADD COLUMN oColumn DATA { ||  CX0_CODNE  } TITLE "CÛdigo" SIZE 15 OF oBrowse //"CÛdigo"
ADD COLUMN oColumn DATA { ||  CX1_ITEM } TITLE "Item" SIZE 15 OF oBrowse //"CÛdigo"
            
oBrowse:Activate()
 
ACTIVATE MSDIALOG oDlgTela CENTERED
  
If cValNE <> cRetNE  
	oCPEDetail:LoadValue("CPE_ITEMNE",cITemNE)
EndIf

oView:Refresh()
     	
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPRetCX1()
Retorno da consulta especifica

@author Matheus Lando Raimundo
@since 24/06/2015
@version P12.1.6
@param oModel Modelo ativo
@return Nil
/*/
//------------------------------------------------------------------
Function GCPRetCX1()

Return cRetNE

//-------------------------------------------------------------------
/*/{Protheus.doc} CX0GCPFlt()
Consulta especifica CX0

@author Filipe Goncalves	
@since 15/10/2015
@version P12
@param oModel Modelo ativo
@return Nil
/*/
//------------------------------------------------------------------
Function CX0GCPFlt()

Local oModel         := FWModelActive()
Local oCNEDetail     := oModel:GetModel('CNEDETAIL')
Local oCNDMaster     := oModel:GetModel('CNDMASTER')
Local lRet           := .T.
Local oBrowse        := Nil
Local cNEAls         := GetNextAlias()
Local nSuperior      := 0
Local nEsquerda      := 0
Local nInferior      := 0
Local nDireita       := 0
Local oDlgTela       := Nil
Local cNEQry         := ""
Local cNumCtr        := oCNDMaster:GetValue("CND_CONTRA")
Local cProd        	:= oCNEDetail:GetValue("CNE_PRODUT")
Local cTabGrid       := SUBSTR(ReadVar(),4,3)
Local cValNE         := oCNEDetail:GetValue("CNE_CODNE")
Local cITemNE        := ""
Local oView			:= FwViewActive()
//DefiniÁ„o do Ìndice da Consulta Padr„o
Local aIndex         := {"CX0_CODNE"}
//DefiniÁ„o da DescriÁ„o da Chave de Pesquisa da Consulta Padr„o
Local aSeek               := {{ "Nota de Empenho", {{"Nota de Empenho","C",15,0,"",,}} }} //"Nota de Empenho"#"Nota de Empenho"

cRetNE := ""

cNEQry := " SELECT " + CRLF
cNEqRY += " CX0.CX0_FILIAL, " + CRLF
cNEQry += " CX0.CX0_CODNE,     " + CRLF
cNEQry += " CX1.CX1_ITEM     " + CRLF
cNEQry += " FROM " + RetSqlName("CX0") + " CX0 " + CRLF
cNEQry += " INNER JOIN " + RetSqlName("CX1") + " CX1 " + CRLF
cNEQry += " ON CX0.CX0_CODNE = CX1.CX1_CODNE " + CRLF
cNEQry += " WHERE " + RetSqlCond("CX0") + CRLF
cNEQry += " AND " + RetSqlCond("CX1") + CRLF
cNEQry += " AND CX0.CX0_CTR = '" + cNumCtr + "' " + CRLF
cNEQry += " AND CX1.CX1_CODPRO = '" + cProd + "' " + CRLF


nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800
 
DEFINE MSDIALOG oDlgTela TITLE "Nota de Empenho" FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL //"Nota de Empenho"
 
oBrowse := FWFormBrowse():New()
oBrowse:SetDescription("Notas de Empenho") // "Notas de Empenho"
oBrowse:SetAlias(cNEAls)
oBrowse:SetDataQuery()
oBrowse:SetQuery(cNEQry)
oBrowse:SetOwner(oDlgTela)
oBrowse:SetDoubleClick({ || cRetNE := (oBrowse:Alias())->CX0_CODNE, cITemNE := (oBrowse:Alias())->CX1_ITEM, oDlgTela:End()})
oBrowse:AddButton( OemTOAnsi("Confirmar"), {|| cRetNE := (oBrowse:Alias())->CX0_CODNE, cITemNE := (oBrowse:Alias())->CX1_ITEM, oDlgTela:End() } ,, 2 ) //"Confirmar"
oBrowse:AddButton( OemTOAnsi("Cancelar"),  {|| cRetNE := "", lRet := .F., oDlgTela:End() } ,, 2 ) //"Cancelar"
oBrowse:DisableDetails()
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetSeek({||.T.},aSeek)
 
ADD COLUMN oColumn DATA { ||  CX0_FILIAL } TITLE "Filial" SIZE 15 OF oBrowse //"Filial"
ADD COLUMN oColumn DATA { ||  CX0_CODNE  } TITLE "CÛdigo" SIZE 15 OF oBrowse //"CÛdigo"
ADD COLUMN oColumn DATA { ||  CX1_ITEM } TITLE "Item" SIZE 15 OF oBrowse //"CÛdigo"
            
oBrowse:Activate()
 
ACTIVATE MSDIALOG oDlgTela CENTERED
  
If cValNE <> cRetNE  
	oCNEDetail:SetValue("CNE_ITEMNE",cITemNE)
EndIf

oView:Refresh()
     	
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDBValue()
Recupera o valor do campo de uma tabela

@author Matheus Lando Raimundo
@since 01/03/2016
@return Nil
/*/
//------------------------------------------------------------------
Function GetDBValue(cTabela,cCampo,cRecno)
Local aArea	:= GetArea()
Local xValue	:= Nil	

(cTabela)->(dbGoto(cRecno))

xValue := (cTabela)->&(cCampo) 
RestArea(aArea)

	
Return xValue

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GCPA011RAT∫ Autor ≥      Totvs         ∫ Data ≥  02/03/11   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Programa para obter o centro de custo solicitante do item  ∫±±
±±∫          ≥ e sua percentagem baseada na quantidade total daquele item,∫±± 
±±∫          ≥ de acordo com as solicitaÁıes de compra                    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GCP - Gest„o de Compras Publicas                           ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
                
Function GCPA011RAT(cC7Item,cProduto)
Local cQry	  := ""
Local cInd	  := ""
Local nli	  := 0
Local nAux	  := 0
Local nSoma	  := 0
Local aAux	  := {} 
Local aRet	  := {}
Local aCTBEnt := CTBEntArr()
Local nItem	  := 1

cQry:="SELECT C1.C1_CC,"+char(13)+char(10) 	
cQry+="		C1.C1_CONTA,"+char(13)+char(10)  	
cQry+="		C1.C1_ITEMCTA,"+char(13)+char(10)  	
cQry+="		C1.C1_CLVL,"+char(13)+char(10)
For nAux := 1 To Len(aCTBEnt)
	If SC1->(FieldPos("C1_EC"+aCTBEnt[nAux]+"CR")) > 0
		cQry+="	C1.C1_EC"+aCTBEnt[nAux]+"CR, "
		cQry+="	C1.C1_EC"+aCTBEnt[nAux]+"DB, "
	EndIf
Next nAux
cQry+="		((C1.C1_QUANT/CO2.CO2_QUANT)*100) PERC"+char(13)+char(10) 
		
cQry+="	FROM "+RetSqlName("SC1")+" C1"+char(13)+char(10) 	
cQry+="	INNER JOIN "+RetSqlName("CO2")+" CO2"+char(13)+char(10) 
	
cQry+="	ON("+char(13)+char(10) 
cQry+="		C1.C1_CODED			= CO2.CO2_CODEDT"+char(13)+char(10) 
cQry+="		AND	C1.C1_NUMPR		= CO2.CO2_NUMPRO"+char(13)+char(10) 
cQry+="		AND	C1.C1_PRODUTO	= CO2.CO2_CODPRO"+char(13)+char(10) 
cQry+="		AND C1.C1_FILIAL	= CO2.CO2_FILIAL"+char(13)+char(10) 
cQry+="		AND C1.D_E_L_E_T_	= ' '"+char(13)+char(10)  	
cQry+="	)"+char(13)+char(10) 

cQry+="	WHERE CO2.CO2_CODEDT	= '"+CO1->CO1_CODEDT+"'"+char(13)+char(10) 
cQry+="	AND CO2.CO2_NUMPRO		= '"+CO1->CO1_NUMPRO+"'"+char(13)+char(10) 
cQry+="	AND CO2.CO2_CODPRO		= '"+cProduto+"'"+char(13)+char(10) 
cQry+="	AND CO2.CO2_FILIAL		= '"+xFilial("CO2")+"'"+char(13)+char(10) 
cQry+="	AND CO2.D_E_L_E_T_		= ' '"+char(13)+char(10) 
cQry+="	ORDER BY C1.C1_CC,"+char(13)+char(10) 
cQry+="				C1.C1_CONTA,"+char(13)+char(10) 
cQry+="				C1.C1_ITEMCTA,"+char(13)+char(10) 
cQry+="				C1.C1_CLVL"+char(13)+char(10) 

If Select("QRAT") > 0
	 QRAT->(DbCloseArea())
EndIf
cQry := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRAT",.T.,.T.) 

While QRAT->(!EOF()) 
	If !Empty(AllTrim(QRAT->C1_CC+QRAT->C1_CONTA+QRAT->C1_ITEMCTA+QRAT->C1_CLVL))
		If cInd == QRAT->C1_CC+QRAT->C1_CONTA+QRAT->C1_ITEMCTA+QRAT->C1_CLVL
			aRet[Len(aRet),3,2]+=NOROUND(QRAT->PERC,2)	
		Else 
			aAdd(aAux,{"CH_ITEMPD"	, cC7Item	   			   				, nil})
			aAdd(aAux,{"CH_ITEM"	, StrZero(nItem,TamSX3("CH_ITEM")[1])	, nil})
			aAdd(aAux,{"CH_PERC"	, NOROUND(QRAT->PERC,2)	  				, nil})
			aAdd(aAux,{"CH_CC"		, QRAT->C1_CC	   		  				, nil})
			aAdd(aAux,{"CH_CONTA"	, QRAT->C1_CONTA  		 				, nil})
			aAdd(aAux,{"CH_ITEMCTA"	, QRAT->C1_ITEMCTA 		 				, nil})
			aAdd(aAux,{"CH_CLVL" 	, QRAT->C1_CLVL			  				, nil})
			For nAux := 1 To Len(aCTBEnt)
				If SC1->(FieldPos("C1_EC"+aCTBEnt[nAux]+"CR")) > 0
					aAdd(aAux,{"CH_EC"+aCTBEnt[nAux]+"CR", QRAT->&("C1_EC"+aCTBEnt[nAux]+"CR"), nil})
					aAdd(aAux,{"CH_EC"+aCTBEnt[nAux]+"DB", QRAT->&("C1_EC"+aCTBEnt[nAux]+"DB"), nil})
				EndIf
			Next nAux
			aAdd(aRet,aAux)
			aAux := {}
			nItem += 1		
		EndIf
	EndIf 
	cInd:=QRAT->C1_CC+QRAT->C1_CONTA+QRAT->C1_ITEMCTA+QRAT->C1_CLVL
	QRAT->(DbSkip())
EndDo
If !Empty(aRet)
	
	For nli:=1 To Len(aRet)
		nSoma	+= aRet[nli,3,2]
		nAux	:= nli
	Next nli	
	
	If nSoma < 100
		aRet[nAux,3,2]	+= (100 - nSoma)
	ElseIf nSoma > 100
		aRet[nAux,3,2]	+= (nSoma - 100)
	End
EndIf
QRAT->(DbCloseArea())
Return aRet     

//-------------------------------------------------------------------
/*/{Protheus.doc} RemoveEsp()
Remove caracter especiais de uma string

@author Matheus Lando Raimundo
@since 01/03/2016
@return Nil
/*/
//------------------------------------------------------------------
Function RemoveEsp(cStr)
Local cRet := cStr

cRet := strtran (cRet, "%", "")
cRet := strtran (cRet, "#", "")
cRet := strtran (cRet, "*", "")
cRet := strtran (cRet, "@", "")
cRet := strtran (cRet, "&", "")
cRet := strtran (cRet, "·", "a")
cRet := strtran (cRet, "È", "e")
cRet := strtran (cRet, "Ì", "i")
cRet := strtran (cRet, "Û", "o")
cRet := strtran (cRet, "˙", "u")
cRet := STRTRAN (cRet, "¡", "A")
cRet := STRTRAN (cRet, "…", "E")
cRet := STRTRAN (cRet, "Õ", "I")
cRet := STRTRAN (cRet, "”", "O")
cRet := STRTRAN (cRet, "⁄", "U")
cRet := strtran (cRet, "„", "a")
cRet := strtran (cRet, "ı", "o")
cRet := STRTRAN (cRet, "√", "A")
cRet := STRTRAN (cRet, "’", "O")
cRet := strtran (cRet, "‚", "a")
cRet := strtran (cRet, "Í", "e")
cRet := strtran (cRet, "Ó", "i")
cRet := strtran (cRet, "Ù", "o")
cRet := strtran (cRet, "˚", "u")
cRet := STRTRAN (cRet, "¬", "A")
cRet := STRTRAN (cRet, " ", "E")
cRet := STRTRAN (cRet, "Œ", "I")
cRet := STRTRAN (cRet, "‘", "O")
cRet := STRTRAN (cRet, "€", "U")
cRet := strtran (cRet, "Á", "c")
cRet := strtran (cRet, "«", "C")
cRet := strtran (cRet, "‡", "a")
cRet := strtran (cRet, "¿", "A")
cRet := strtran (cRet, "∫", ".")
cRet := strtran (cRet, "™", ".")
cRet := strtran (cRet, chr (9), " ") // TAB

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc}GCPSCED
FunÁ„o que verifica se o edital tem solicitaÁ„o de compras

@author antenor.silva
@since 06/02/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GCPSCED(cCodEdt,cNumPro)
Local lRet	  	:= .F. 	
Default cCodEdt 	:= ''
Default cNumPro 	:= ''

CP4->(dbSetOrder(1))
If CP4->(dbSeek(xFilial('CP4')+cCodEdt+cNumPro))
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}GCPInitFun
Rotina executada durante a incializaÁ„o do mÛdulo SIGAGCP

@author antenor.silva
@since 04/01/2018
@version P12
/*/
//-------------------------------------------------------------------
Function GCPInitFun()
Local aArea	:= GetArea()

// 	-- AtualizaÁ„o das Modalidades X Par·grafos - GCPA140

DbSelectArea("CP9")
CP9->(DbSetOrder(1))
If CP9->( DbSeek(xFilial("CP9")+"1"+"24        "+"1o    ") )
	RecLock("CP9",.F.)	
	CP9->CP9_PARAG := "1∫"	 
	CP9->(MsUnLock())
EndIf

If CP9->( DbSeek(xFilial("CP9")+"1"+"24        "+"2o    ") )
	RecLock("CP9",.F.)
	CP9->CP9_PARAG := "2∫"
	CP9->(MsUnlock())
EndIf

If CP9->( DbSeek(xFilial("CP9")+"1"+"25        "+"1o    ") )
	RecLock("CP9",.F.)
	CP9->CP9_PARAG := "1∫"
	CP9->(MsUnlock())
EndIf

If CP9->( DbSeek(xFilial("CP9")+"1"+"25        "+"2o    ") )
	RecLock("CP9",.F.)
	CP9->CP9_PARAG := "2∫"
	CP9->(MsUnlock())
EndIf

If CP9->( DbSeek(xFilial("CP9")+"4"+"14        "+"3o    ") )
	RecLock("CP9",.F.)
	CP9->CP9_PARAG := "3∫"
	CP9->(MsUnlock())
EndIf

DbSelectArea("CPB")
CPB->(DbSetOrder(1))
If CPB->( DbSeek(xFilial("CP9")+"1"+"24        "+"1o    ") )
	RecLock("CPB",.F.)
	CPB->CPB_PARAG := "1∫"
	CPB->(MsUnlock())
EndIf

If CPB->( DbSeek(xFilial("CP9")+"1"+"24        "+"2o    ") )
	RecLock("CPB",.F.)
	CPB->CPB_PARAG := "2∫"
	CPB->(MsUnlock())
EndIf

If CPB->( DbSeek(xFilial("CP9")+"1"+"25        "+"1o    ") )
	RecLock("CPB",.F.)
	CPB->CPB_PARAG := "1∫"
	CPB->(MsUnlock())
EndIf

If CPB->( DbSeek(xFilial("CP9")+"1"+"25        "+"2o    ") )
	RecLock("CPB",.F.)
	CPB->CPB_PARAG := "2∫"
	CPB->(MsUnlock())
EndIf

If CPB->( DbSeek(xFilial("CP9")+"4"+"14        "+"3o    ") )
	RecLock("CPB",.F.)
	CPB->CPB_PARAG := "3∫"
	CPB->(MsUnlock())
EndIf

RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}GCPInitFun
Rotina para verificar a existÍncia do Ìndice 5

@author antenor.silva
@since 15/06/2018
@version P12
/*/
//-------------------------------------------------------------------
Function GCPIndice()
Local aArea	:= GetArea()
Local lRet	:= .F.

DbSelectArea("SIX")
If DbSeek('CO3'+'5')
	lRet := .T. 
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}GCPXEtpIni
FunÁ„o que busca primeira etapa do fluxo de regras customizadas (CO0_REGRA e CP0_REGRA maior que '020')

@author leonardo.magalhaes
@since 20/07/2018
@version P12
/*/
//-------------------------------------------------------------------
Function GCPXEtpIni(cRegra, cModali)
	Local cEtapa 	:= ""
	Local cAliasTmp := GetNextAlias()
	
	BeginSQL Alias cAliasTmp
		SELECT
			CP0A.CP0_ETAPA AS ETPINI
		FROM
			%table:CP0% CP0A
		WHERE
			CP0A.CP0_FILIAL		= %xFilial:CP0%
			AND CP0A.CP0_REGRA	= %exp:cRegra%
			AND CP0A.CP0_MODALI	= %exp:cModali%
			AND CP0A.%NotDel%
		AND CP0A.CP0_ORDEM	= (	SELECT MIN(CP0B.CP0_ORDEM) 
									FROM 
										%table:CP0% CP0B 
									WHERE 
										CP0B.CP0_FILIAL 	= CP0A.CP0_FILIAL 
										AND CP0B.CP0_REGRA 	= CP0A.CP0_REGRA 
										AND CP0B.CP0_MODALI	= CP0A.CP0_MODALI 
										AND CP0B.%NotDel% )
	EndSQL
	
	If !Eof((cAliasTmp))
		cEtapa := (cAliasTmp)->ETPINI
	EndIf
	
	(cAliasTmp)->(DbCloseArea())
	
Return cEtapa

/*/{Protheus.doc} GCPCadForn
	Exibe a tela para cadastro de um fornecedor(SA2)
@author philipe.pompeu
@since 13/03/2019
@return lResult, se a operaÁ„o foi concluida corretamente
/*/
Function GCPCadForn(aDados as Array) as Logical
	Local oModel As Object
	Local nPercReduc:= 15
	Local nResult 	:= 1
	Local bOk		:= {|x| GCPOkForn(x) }

	oModel := FWLoadModel("MATA020")	
	If(oModel != Nil)
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		
		If(oModel:Activate())
		
			aEval(aDados,{|x| oModel:LoadValue('SA2MASTER', x[1], x[2]) })		
			nResult := FWExecView(STR0025,'MATA020', MODEL_OPERATION_INSERT,/*oDlg*/,{||.T.},bOk,nPercReduc,/*aEnableButtons*/,;
				/*bCancel*/,/*cOperatId*/,/*cToolBar*/,oModel)
		Else
			Help( ,, 'HELP',, oModel:GetErrorMessage()[6], 1, 0)
		EndIf
		
	EndIf	
Return (nResult == 0)

/*/{Protheus.doc} GCPOkForn
	Bloco de validaÁ„o do bot„o OK da chamada ao MATA020 feita pela funÁ„o <GCPCadForn>
@author philipe.pompeu
@since 05/10/2022
@return lResult, se pode confirmar a gravaÁ„o do fornecedor
/*/
Function GCPOkForn(oMdlForn)
	Local lResult := .T.
	
	If oMdlForn:GetModel("SA2MASTER"):HasField("A2_MSBLQL")		
		If !(lResult := oMdlForn:GetValue("SA2MASTER","A2_MSBLQL") != "1")
			Help(" ",1,"REGBLOQ",,, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0081})//N„o È possÌvel informar um fornecedor bloqueado como licitante.
		EndIf
	EndIf
Return lResult

/*/{Protheus.doc}IsProdBloq
	FunÁ„o que verifica se o produto est· bloqueado (B1_MSBLQL)
@author EDUARDO.DIAS
@return lRet, .T. se o produto estiver bloqueado
@since 26/03/2019/*/
Static Function IsProdBloq(cCodPro As Character, lSetOrder as Logical, cFilSB1 as Char) As Logical
	Local aArea	:= {}
	Local lRet	:= .F.
	Default cCodPro		:= ''
	Default lSetOrder	:= .T.
	Default cFilSB1		:= xFilial("SB1")
	
	If lSetOrder
		aArea:= SB1->(GetArea())		
		SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
	EndIf

	If SB1->(DbSeek(cFilSB1 + cCodPro)) .And. SB1->B1_MSBLQL == '1' //Verifica se o Produto est· bloqueado para movimentaÁ„o	
		Help("",1,"PRODBLQL",,STR0078 + cCodPro + STR0079,4,1,,,,,,{STR0080}) //"O Produto " # " n„o ser· inserido pois encontra-se bloqueado para uso!" # "Verifique o Cadastro do Produto (B1_MSBLQL)"
		lRet := .T.		
	EndIf

	If !Empty(aArea)
		RestArea(aArea)
		FwFreeArray(aArea)
	EndIf
Return lRet

/*/{Protheus.doc} GCPMrkDoc()
	Esta rotina e utilizada para Contratos gerados apartir do processo de licitacao (GCP)
	Aqui ira marcar os itens que foram gerados documentos.

@Param cNumCtr  - Numero do Contrato
@Param cCodEdt - Cod. Edital
@Param cNumPr 	- Numero do Processo do Edital

@author Eduardo.Dias
@since 03/06/2020
@return Nil
/*/
Function GCPMrkDoc(cCodEdt, cNumPro, lIsCreden)
	Local cAliasQry := GetNextAlias()
	Local aAreaCO2	:= CO2->(GetArea())
	Local lPosDHMC02	:= CO2->(FieldPos("CO2_DTHOMO")) > 0
	Local lPosHHMC02	:= CO2->(FieldPos("CO2_HRHOMO")) > 0

	Default cCodEdt	:= " "
	Default cNumPro	:= " "
	Default lIsCreden := .F.

	BeginSQL Alias cAliasQry
		
		SELECT 	CO2.CO2_CODEDT, CO2.CO2_NUMPRO, CO2.CO2_CODPRO, CO2.CO2_LOTE, CO2.CO2_DOCOK, CO2.CO2_HOMOLO, CO2.R_E_C_N_O_ CO2RECNO
		FROM 	%Table:CO2% CO2
		WHERE 	CO2.CO2_FILIAL 		= %xFilial:CO2%
				AND CO2.CO2_CODEDT	= %Exp:cCodEdt%   
				AND CO2.CO2_NUMPRO	= %Exp:cNumPro% 
				AND CO2.CO2_DOCOK = 'F' 
				AND CO2.CO2_HOMOLO = 'T'  
				AND CO2.%NotDel%
	EndSQL				  	


	CO2->(dbGoTop())
	While (cAliasQry)->(!Eof()) 
		CO2->(dbGoTo((cAliasQry)->CO2RECNO))
		If CO2->CO2_DOCOK == .F. .And. CO2->CO2_HOMOLO == .T.
			RecLock("CO2",.F.)			
			CO2->CO2_DOCOK 	:= IIF(lIsCreden, (CO2->CO2_SALDO == 0), .T.) //Marca o Item como "Documento gerado" para tratativas da homologacao por item no Edital			
			If lPosDHMC02 .And. lPosHHMC02 //Verifica se existem os campos da Homologacao Parcial no item
				If Empty(CO2->CO2_DTHOMO)					
					CO2->CO2_DTHOMO := dDataBase //Grava a Data de HomologaÁ„o no item
					CO2->CO2_HRHOMO := Subs(Time(),1,5) //Grava a hora de HomologaÁ„o
				EndIf
			EndIf
			
			CO2->(MsUnlock())
		EndIf

		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

	RestArea(aAreaCO2)
	FwFreeArray(aAreaCO2)
Return Nil

/*/{Protheus.doc} WhenHML()
	Esta rotina e utilizada no X3_WHEN dos campos CO2_HOMOLO, CP3_HOMOLO

@Param CO1_ETAPA - Cod. Etapa
@Param CO2_DOCOK - Documento gerado

@author Eduardo.Dias
@since 19/06/2020
@return Nil
/*/
Function WhenHML(cEtapa, cDocOk)
	Local lRet	:= .T.

	Default cEtapa	:= " "
	Default cDocOk	:= " "

	If !IsInCallStack('GCPA100') 
		If cEtapa == "HO" .And. cDocOk == .F.
			lRet := .T.
		Else
			Help("",1,"GCPMRKHM",,STR0075,1) //--"GCPMRKHM"STR0074 # "N„o permite desmarcar homologacao de item que ja gerou Contrato ou Pedido" 
			lRet := .F.
		EndIf
	ElseIf IsInCallStack('GCPA100') .And. !IsInCallStack('GCP100GEdt')
		Help("",1,"GCPMRKNP",,STR0077,1) //--"GCPMRKNP"STR0076 # "N„o permite marcar homologacao de item nesta etapa."
		lRet := .F.
	EndIf

Return lRet
