#include "fileio.ch"
#include "protheus.ch"
#include "totvs.ch"
#include "plsmger.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPlsPTU    บAutor  ณEQUIPE PLS          บ Data ณ  10/12/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 - Pls                                                  บฑฑ
ฑฑบAlexander ณ Troca do DbSeek por MsSeek								  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PlsPTU(cCodLay,cNomArq,cNovDir,lMsg)
LOCAL 	cSistem
PRIVATE cDirEnv 
PRIVATE nLinha := 0
PRIVATE aCont := {}
PRIVATE cFileMd5		:= lower( allTrim( getNextAlias() ) ) + "_" + dtos( dDataBase ) + "_" + strTran( time(),":","" ) + ".tmp"

DEFAULT cNovDir := ""
DEFAULT lMsg    := .T.

If Empty(cNovDir)
	cDirEnv := PLSMUDSIS( "\ptu\" )
Else            
	cDirEnv := PLSMUDSIS( AllTrim(cNovDir)+"\" )
EndIf	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProcura o layoutณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DBSelectArea("DE9")
DBSetOrder(1)
If !MsSeek(xFilial("DE9")+cCodLay)
	MsgStop("Layout "+cCodLay+" nใo encontrado.")
	Return
EndIF                      
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณNa criacao do arquivo se nao existir o diretorio o mesmo vai ser criadoณ
//ณa criacao do arquivo estava na funcao PTUProc logo apos o ultimo stor  ณ
//ณ FERROR() = 430 caminho nao encontrado								  ณ
//ณAlexander 12/04/2005                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nH := FCreate(cDirEnv+cNomArq,0,,.F.) 
if FERROR() = 430 
   MakeDir(cDirEnv)
   nH := FCreate(cDirEnv+cNomArq,0,,.F.) 
endif   
if nH == -1
   MsgInfo('Nใo foi possivel CRIAR o ARQUIVO!')
   return
endif

cFileMd5 := cDirEnv + cFileMd5

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFoi trocado o parametro nome do arquivo por nH. a funcao nao vai mais criar o arquivo.	    ณ
//ณAlexander 12/04/2005                                                                 		ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Processa({|| PTUProc(cCodLay,nH)},AllTrim(DE9->DE9_DSCLAY))

If lMsg .and. File(cDirEnv+cNomArq)
   MsgInfo('Arquivo gerado. '+cDirEnv+cNomArq)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPTUProc   บAutor  ณEQUIPE PLS          บ Data ณ  10/12/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 - Pls                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PTUProc(cCodLay,nH)
Local cCodReg
Local nJ,nI
Local cCampo 
Local lProcessa  := .T.
Private aCabDE0  := {}
Private aDadDE0  := {}
Private aTrabDE0 := {}
Private aCabDE1  := {}
Private aDadDE1  := {}
Private aTrabDE1 := {}
Private aInfoHash:= {}
Private nPosReg    := 0
Private nPosRegDE0 := 0
Private nPosRegCp1 := 0
Private nPosRegCp2 := 0
Private nPosRegCp3 := 0 
Private nPosRegCp4 := 0
Private nPosRegCp5 := 0

Private aHeader
Private cLinStr := ""
Private cNomLay := cCodLay

Store Header "DE0" to aCabDE0 For ! AllTrim(SX3->X3_CAMPO) $ "DE0_DSCLAY/DE0_DSCREG/DE0_QUERY/DE0_DSCRCP"
DbSelectArea("DE0")
DbSetOrder(1)
MsSeek(xFilial("DE0")+cCodLay)
Store COLS "DE0" TO aDadDE0 FROM aCabDE0 VETTRAB aTrabDE0 While xFilial("DE0") == DE0->DE0_FILIAL .and. cCodLay == DE0->DE0_CODLAY

Store Header "DE1" to aCabDE1 For .T.
aHeader := aClone(aCabDE1)  // MANTER COMPATIBILIDADE COM INICIALIZADORES PADRAO
DbSelectArea("DE1")
DbSetOrder(2)
MsSeek(xFilial("DE1")+cCodLay)
Store COLS "DE1" TO aDadDE1 FROM aCabDE1 VETTRAB aTrabDE1 While xFilial("DE1") == DE1->DE1_FILIAL .and. cCodLay == DE1->DE1_CODLAY

nPosReg    := GDFieldPos("DE1_CODREG",aCabDE1)
If nPosReg == 0
   MsgInfo('Favor criar, via configurador, o campo DE1_CODREG!')
   lProcessa := .F.
EndIf
nPosRegDE0 := GDFieldPos("DE0_CODREG",aCabDE0)
If nPosRegDE0 == 0
   MsgInfo('Favor criar, via configurador, o campo DE0_CODREG!')
   lProcessa := .F.
EndIf
nPosRegCp1 := GDFieldPos("DE0_CODRCP",aCabDE0)
If nPosRegCp1 == 0
   MsgInfo('Favor criar, via configurador, o campo DE0_CODRCP!')
   lProcessa := .F.
EndIf
nPosRegCp2 := GDFieldPos("DE0_CODRC2",aCabDE0)
If nPosRegCp2 == 0
   MsgInfo('Favor criar, via configurador, o campo DE0_CODRC2!')
   lProcessa := .F.
EndIf
nPosRegCp3 := GDFieldPos("DE0_CODRC3",aCabDE0)
If nPosRegCp3 == 0
   MsgInfo('Favor criar, via configurador, o campo DE0_CODRC3!')
   lProcessa := .F.
EndIf
nPosRegCp4 := GDFieldPos("DE0_CODRC4",aCabDE0)
If nPosRegCp4 == 0
   MsgInfo('Favor criar, via configurador, o campo DE0_CODRC4!')
   lProcessa := .F.
EndIf
nPosRegCp5 := GDFieldPos("DE0_CODRC5",aCabDE0)
If nPosRegCp5 == 0
   MsgInfo('Favor criar, via configurador, o campo DE0_CODRC5!')
   lProcessa := .F.
EndIf   
nPosRegCp6 := GDFieldPos("DE0_CODRC6",aCabDE0)
If nPosRegCp6 == 0
   MsgInfo('Favor criar, via configurador, o campo DE0_CODRC6!')
   lProcessa := .F.
EndIf   

If lProcessa
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณArquivo criado na funcao PlsPTU. nH esta vindo da mesma funcao 	 ณ
	//ณAlexander 12/04/2005              								 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//nH := FCreate(cNomArq)             

	cLinStr := ""
	For nI := 1 to Len(aDadDE0)
		cCodReg  := GDFieldGet("DE0_CODREG",nI,,aCabDE0,aDadDE0)
		If aScan(aDadDE0,{|x|x[nPosRegCp1]==cCodReg .or. x[nPosRegCp2]==cCodReg .or. x[nPosRegCp3]==cCodReg .or. x[nPosRegCp4]==cCodReg .or. x[nPosRegCp5]==cCodReg .or. x[nPosRegCp6]==cCodReg } ) == 0
		   PtuProcReg(cCodReg,nI,nH)
		EndIf
	Next	          
	ChkGrava(nH,@cLinStr,.t.)
EndIf
PTUHash("", .T.)
FClose(nH)
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPTUProcRegบAutor  ณEQUIPE PLS          บ Data ณ  10/12/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 - Pls                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PTUProcReg(cCodReg,nPosDE0,nH)
Local cAlias
Local lPosic
Local cOrdem
Local cKey
Local cWhile
Local cValid
Local nLinDE0
Local nLinDE1
Local nPosDE1 := aScan(aDadDE1,{|x|x[nPosReg]==cCodReg } )
Local nCont   := 1
Local nJ
Local cCampo
Local cVal
Local aVar 		:= {}
Local aVar2 		:= {}
Local lSkip 		:= .T.
Local lGeraTpReg	:= .T.
Local nFlgRCP 	:= 0

If GDFieldGet("DE0_STATUS",nPosDE0,,aCabDE0,aDadDE0) # "1"  // SE ESTIVER DESATIVADO
	Return
EndIf

For nJ := 1 To Len(aCabDE0)
	cCampo := AllTrim(aCabDE0[nJ,2])
	PtuPutVar(cCampo,GDFieldGet(cCampo,nPosDE0,,aCabDE0,aDadDE0),aVar)
Next
cAlias := PtuGetVar("DE0_ALIAS",aVar)
lPosic := (PtuGetVar("DE0_POSICI",aVar)=="1")
cOrdem := PtuGetVar("DE0_POSORD",aVar)
cKey   := PtuGetVar("DE0_POSCHV",aVar)
cWhile := PtuGetVar("DE0_COND",aVar)
cValid := PtuGetVar("DE0_VALID",aVar)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ponto de entrada para tratamento se o tipo de registo sera gerado em arquivo ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If  Existblock("PLSPTUREG")
    lGeraTpReg := Execblock("PLSPTUREG",.F.,.F.,{cNomLay,cCodReg})
    If Valtype(lGeraTpReg) <> "L"
    	lGeraTpReg	:= .T.
    Endif
Endif                     

If Empty(cWhile)
	cWhile := ".T."
EndIf
If Empty(cValid)
	cValid := ".T."
EndIf
If !Empty(cAlias)
	DbSelectArea(cAlias)
	If lPosic
		If Val(cOrdem) # 0
			DbSetOrder(Val(cOrdem))
		Else
			DbSetOrder(Asc(cOrdem)-55)
		EndIf
	EndIf
	If !Empty(cKey)
		MsSeek(&cKey,.t.)
	EndIf
EndIf
While &cWhile
	nFlgRCP 	:= 0
    lSkip := .t.
	If &cValid
		nLinDE1 := nPosDE1
		While Len(aDadDE1) >= nLinDE1 .and. aDadDE1[nLinDE1,nPosReg] == cCodReg
			aVar2 	  := {} 
			For nJ := 1 To Len(aCabDE1)
				cCampo := AllTrim(aCabDE1[nJ,2])
				PtuPutVar(cCampo,GDFieldGet(cCampo,nLinDE1,,aCabDE1,aDadDE1),aVar2)
			Next
		    cVal    := &(AllTrim(PtuGetVar("DE1_REGRA",aVar2)))
		    cVal    := PadR(cVal,PtuGetVar("DE1_LAYTAM",aVar2))
		    If !Empty(cAlias) .AND. (cAlias)->(FieldPos('GERARCP')) > 0 .AND. (cAlias)->(GERARCP) == '1'
				lGeraTpReg := .F.
				nFlgRCP++
				If nFlgRCP == 1 // Valida็ใo para remover uma linha do sequenciador ja que esta linha vai ser removida do texto.
					nLinha--
				EndIf
			ElseIf !Empty(cAlias) .AND. (cAlias)->(FieldPos('GERARCP')) > 0 .AND. (cAlias)->(GERARCP) == '0'
				lGeraTpReg := .T.
			EndIf  
		    If lGeraTpReg
	  		    cLinStr += cVal
  		    Endif
		    nLinDE1++
		EndDo
	  	ChkGrava(nH,@cLinStr)
		If nLinDE1 # nPosDE1
			If lGeraTpReg
			    cLinStr+=Chr(13)+Chr(10)
		    Endif
  		    ChkGrava(nH,@cLinStr)
			If !Empty(PtuGetVar("DE0_CODRCP",aVar))
				nLinDE0 := aScan(aDadDE0,{|x|x[nPosRegDE0]==PtuGetVar("DE0_CODRCP",aVar)} )
				If nLinDE0 > 0
				    If GDFieldGet("DE0_ALIAS",nLinDE0,,aCabDE0,aDadDE0)==cAlias
				       lSkip := .F.
				    EndIf
					PtuProcReg(PtuGetVar("DE0_CODRCP",aVar),nLinDE0,nH)
				EndIf
			EndIf
			
			If !Empty(PtuGetVar("DE0_CODRC2",aVar))
				nLinDE0 := aScan(aDadDE0,{|x|x[nPosRegDE0]==PtuGetVar("DE0_CODRC2",aVar)} )
				If nLinDE0 > 0
					PtuProcReg(PtuGetVar("DE0_CODRC2",aVar),nLinDE0,nH)
				EndIf
			EndIf
			
			If !Empty(PtuGetVar("DE0_CODRC3",aVar))
				nLinDE0 := aScan(aDadDE0,{|x|x[nPosRegDE0]==PtuGetVar("DE0_CODRC3",aVar)} )
				If nLinDE0 > 0
					PtuProcReg(PtuGetVar("DE0_CODRC3",aVar),nLinDE0,nH)
				EndIf
			EndIf   
			
			If !Empty(PtuGetVar("DE0_CODRC4",aVar))
				nLinDE0 := aScan(aDadDE0,{|x|x[nPosRegDE0]==PtuGetVar("DE0_CODRC4",aVar)} )
				If nLinDE0 > 0
					PtuProcReg(PtuGetVar("DE0_CODRC4",aVar),nLinDE0,nH)
				EndIf
			EndIf
			
			If !Empty(PtuGetVar("DE0_CODRC5",aVar))
				nLinDE0 := aScan(aDadDE0,{|x|x[nPosRegDE0]==PtuGetVar("DE0_CODRC5",aVar)} )
				If nLinDE0 > 0
					PtuProcReg(PtuGetVar("DE0_CODRC5",aVar),nLinDE0,nH)
				EndIf
			EndIf

			If !Empty(PtuGetVar("DE0_CODRC6",aVar))
				nLinDE0 := aScan(aDadDE0,{|x|x[nPosRegDE0]==PtuGetVar("DE0_CODRC6",aVar)} )
				If nLinDE0 > 0
					PtuProcReg(PtuGetVar("DE0_CODRC6",aVar),nLinDE0,nH)
				EndIf
			EndIf
		EndIf
	EndIf
	
	If !Empty(cAlias)
		DbSelectArea(cAlias)
		If lSkip
  		   DbSkip()
  		EndIf   
	Else
		Exit
	EndIf
EndDo

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPTUGetVar บAutor  ณEQUIPE PLS          บ Data ณ  10/12/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 - Pls                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PTUGetVar(cCampo,aVar)
Local nPos
Local uRet                                                         
nPos := aScan(aVar,{|x|Upper(AllTrim(x[1]))==Upper(AllTrim(cCampo))})
If nPos # 0
	uRet := aVar[nPos,2]
EndIf
Return uRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPTUPutVar บAutor  ณEQUIPE PLS          บ Data ณ  10/12/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 - Pls                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PTUPutVar(cCampo,uVal,aVar)
Local nPos
Local uRet
nPos := aScan(aVar,{|x|Upper(AllTrim(x[1]))==Upper(AllTrim(cCampo))})
If nPos # 0
	aVar[nPos,2] := uVal
Else
	aadd(aVar,{cCampo,uVal})
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPTULn     บAutor  ณEQUIPE PLS          บ Data ณ  10/12/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera o numero sequencial da linha + registro                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 - Pls                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PTULn(cTipReg,lInic,lTotal)
Local nPos
Local nRet := 0
Local nTam := 8
Local cRet
//STATIC nLinha := 0
//STATIC aCont := {}
DEFAULT lInic  := .F.
DEFAULT lTotal := .F.

If lInic
	aCont  := {}
	nLinha := 0
	Return
EndIf
If lTotal
	nPos := aScan(aCont,{|x| x[1]==cTipReg})
	If nPos # 0
		nRet := aCont[nPos,2]
	EndIf
	nTam := 4
Else
	nPos := aScan(aCont,{|x| x[1]==cTipReg})
	If nPos == 0
		aadd(aCont,{cTipReg,0})
		nPos := Len(aCont)
	EndIf
	aCont[nPos,2] := aCont[nPos,2] + 1
	
	If  Existblock("PLSPTUREG")
		lGeraTpReg := Execblock("PLSPTUREG",.F.,.F.,{cNomLay,cTipReg})
		If Valtype(lGeraTpReg) <> "L"
			lGeraTpReg:=.T.
		Endif
		If lGeraTpReg
			nLinha++
		EndIf
    Else                    
    	nLinha++
	EndIf
	nRet := nLinha
EndIf    
cRet :=StrZero(nRet,nTam)
IncProc("Processando... "+cRet)
Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlsPtuApl
Funcao para enviar lay-outs de PTU para a base do sistema

@author    TOTVS
@version   1.xx
@since     03/04/2017
/*/
//------------------------------------------------------------------------------------------
function PlsPtuApl(lAuto)
	local cPerg		:= "PLSPTU"
	local cCadastro	:= "Importa็ใo do Layout PTU - Batch"
	local cCodLay	:= space( 6 )
	local cPath		:= "\PTU\" + space( 95 )
	local nOpca		:= 0
	local aPergs	:= { }
	local aRetPerg	:= { }
	local aSays		:= { }
	local aButtons	:= { }
	local lEnd		:= .F.
	default lAuto	:= .F. 
	private oProcess
	
	if valtype(lAuto) <> 'L'
		lAuto := .f.
	endif

	aadd( aSays,"Objetivo deste Programa:" )
	aadd( aSays,"" )
	aadd( aSays,"Efetuar a leitura e importa็ใo dos layouts do PTU Batch" )
	aadd( aSays,"atrav้s dos arquivos: DE0.CSV, DE1.CSV, DE3.CSV e DE9.CSV" )

	aadd( aButtons,{ 1,.T.,{ || nOpca := 1, fechaBatch() } } )
	aadd( aButtons,{ 2,.T.,{ || nOpca := 0, fechaBatch() } } )
	if !lAuto
		formBatch( cCadastro,aSays,aButtons,,250 )
	else
		nOpca := 1
		aadd(aRetPerg,'A400J')
		aadd(aRetPerg,'/ptu/')
	endif
	
	if( nOpca == 1 )
		aadd( aPergs,{ 1,"Layout",cCodLay,"@!",'.T.','',/*'.T.'*/,40,.T. } )
		aadd( aPergs,{ 6,"Caminho:",cPath,"@!",'.T.',nil,50,.T.,"Arquivos .CSV |*.CSV","\PTU\",GETF_RETDIRECTORY /*nOR( GETF_LOCALHARD,GETF_LOCALFLOPPY, GETF_RETDIRECTORY )*/ } )        
		
		if lAuto .or. ( paramBox( aPergs,"Parโmetros - Processa arquivo de envio ANS",aRetPerg,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSPTU',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
			cCodLay	:= aRetPerg[ 1 ]
			cPath	:= allTrim( aRetPerg[ 2 ] )

			if !lAuto
				begin transaction
					oProcess := msNewProcess():New( { | lEnd | PtuCopia( cCodLay,cPath,@lEnd ) },"Processando","Aguarde...",.T. )
					oProcess:Activate()
				end transaction
			else
				oProcess := P270fProc():New()
				PtuCopia( cCodLay,cPath,@lEnd,lAuto )
			endif
		endIf
	endif
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PtuCopia
Layout PTU

@author    TOTVS
@version   1.xx
@since     03/04/2017
/*/
//------------------------------------------------------------------------------------------
static function PtuCopia( cCodLay,cPath,lEnd,lAuto )
	local aArquivos	:= { }
	local aCabec	:= { }
	local aDados	:= { }
	local aFilDados	:= { }
	local aTemp		:= { }
	local aCodReg	:= { }
	local aLayouts	:= { "DE0.CSV","DE1.CSV","DE3.CSV","DE9.CSV" }
	local ny		:= 0
	local nZ		:= 0
	local nErro		:= 0
	local nPosCReg	:= 0
	local nPosDReg	:= 0
	local lPrim		:= .T.
	local cLinha	:= ""
	//local bPtuCpEr	:= .F.
	local oError	:= errorBlock( { | e | PtuCpErr( e ) } )
	default lAuto 	:= .f.
	
	//--< PRE VALIDACOES >---------------------------------------------
	if( empty( cCodLay ) )
		msgAlert( "ษ necessแrio preencher o parโmetro: 'LayOut'.","Aten็ใo" )
		disarmTransaction()
		break
	endIf

	aArquivos	:= directory( cPath + "*.csv" )
	
	if( len( aArquivos ) > 0 )
		nPosDE0 := ascan( aArquivos, { |x| upper( x[ 1 ] ) ==  aLayouts[ 1 ] } )
		nPosDE1 := ascan( aArquivos, { |x| upper( x[ 1 ] ) ==  aLayouts[ 2 ] } )
		nPosDE3 := ascan( aArquivos, { |x| upper( x[ 1 ] ) ==  aLayouts[ 3 ] } )
		nPosDE9 := ascan( aArquivos, { |x| upper( x[ 1 ] ) ==  aLayouts[ 4 ] } )
		
		if( nPosDE0 == 0 )
			msgStop( "Arquivo [" + cPath + upper( aLayouts[ 1 ] ) + "] nใo encontrado.","Aten็ใo" )
			disarmTransaction()
			break
		endIf
		
		if( nPosDE1 == 0 )
			msgStop( "Arquivo [" + cPath + upper( aLayouts[ 2 ] ) + "] nใo encontrado.","Aten็ใo" )
			disarmTransaction()
			break
		endIf
		
		if( nPosDE3 == 0 )
			msgStop( "Arquivo [" + cPath + upper( aLayouts[ 3 ] ) + "] nใo encontrado.","Aten็ใo" )
			disarmTransaction()
			break
		endIf
		
		if( nPosDE9 == 0 )
			msgStop( "Arquivo [" + cPath + upper( aLayouts[ 4 ] ) + "] nใo encontrado.","Aten็ใo" )
			disarmTransaction()
			break
		endIf
		
		//--< PROCESSA LEITURA DOS ARQUIVOS VALIDOS >---------------------------------------------
		oProcess:SetRegua1( len( aArquivos ) )
		
		for nY:=1 to len( aArquivos )
			oProcess:IncRegua1( "Processando arquivo: " + aArquivos[ nY ][ 1 ] )
			
			//--< CASO SOLICITADO, CANCELA PROCESSAMENTO >---------------------------------------------
			if( lEnd )
				msgStop( "Processo cancelado pelo usuแrio!" )
				disarmTransaction()
				break
			endIf
			
			if( nPosDE0 == nY .or. nPosDE1 == nY .or. nPosDE3 == nY .or. nPosDE9 == nY )
				aCabec		:= { }
				aTemp		:= { }
				aDados		:= { }
				cArquivo	:= cPath + aArquivos[ nY ][ 1 ]
				nErro		:= ft_fUse( allTrim( cArquivo ) )
				lPrim		:= .T.

				//--< LEITURA DO ARQUIVO >---------------------------------------------
				oProcess:SetRegua2( ft_fLastRec() )
				ft_fGoTop()
		
				while( !FT_FEOF() )
					oProcess:IncRegua2( )
					cLinha := ft_fReadLn()
				 
					if( lPrim )
						aTemp := separa( cLinha,";",.T. )
								
						for nZ:=1 to len( aTemp )
							aadd( aCabec,separa( aTemp[ nZ ],",",.T. ) )
									
							aCabec[ nZ ][ 03 ] := val( aCabec[ nZ ][ 03 ] )
							aCabec[ nZ ][ 04 ] := val( aCabec[ nZ ][ 04 ] )
						next nZ
		
						lPrim := .F.
					else
						aadd( aDados,separa( cLinha,";",.T. ) )
					endIf
				 
					ft_fSkip()
				endDo
						
				//--< GRAVA DE0,DE1,DE3 e DE9 >---------------------------------------------
				if( nPosDE0 == nY )
					aCodReg := { }
					gravaPTU( "DE0",aCabec,aDados,cCodLay,@aCodReg )
				elseIf( nPosDE1 == nY )
					gravaPTU( "DE1",aCabec,aDados,cCodLay )
				elseIf( nPosDE3 == nY )
					gravaPTU( "DE3",aCabec,aDados,cCodLay,aCodReg )
				elseIf( nPosDE9 == nY )
					gravaPTU( "DE9",aCabec,aDados,cCodLay )
				endIf
		
				ft_fUse()
			endIf
		next nY

		//--< VERIFICA A GRAVACAO DO LAYOUT >---------------------------------------------
		DE0->( dbSetOrder( 1 ) )
		if( DE0->( dbSeek( xFilial( "DE0" ) + cCodLay ) ) )
			if !lAuto
				msgInfo( 'Layout: "' + allTrim( cCodLay ) + '" aplicado com ๊xito.',"Sucesso!" )
			endif
		else
			msgStop( 'Layout: "' + allTrim( cCodLay ) + '" nใo encontrado.',"Aten็ใo" )
		endIf
	else
		msgStop( 'Nใo existem arquivos a serem processados nesta pasta!',"Aten็ใo" )
	endIf
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} gravaPTU
Grava os dados do novo Layout PTU

@author    TOTVS
@version   1.xx
@since     03/04/2017
/*/
//------------------------------------------------------------------------------------------
static function gravaPTU( cAlias,aCabec,aDados,cCodLay,aCodReg )
	local nX		:= 0
	local nZ		:= 0
	local nPosCReg	:= 0
	local nPosCpo	:= 0
	local nPosCDic	:= 0
	local nPosDDic	:= 0
	
	( cAlias )->( dbSetOrder( 1 ) )
	aFilDados := { }
	
	if( cAlias == "DE3" )
		if( len( aCodReg ) > 0 )
			//--< 1. EXCLUI LOGICAMENTE OS REGISTROS ANTERIORES >---------------------------------------------
			for nZ:=1 to len( aCodReg )
				if( ( cAlias )->( dbSeek( xFilial( cAlias ) + aCodReg[ nZ ] ) ) )
					recLock( cAlias,.F. )
					( cAlias )->( dbDelete() )
					( cAlias )->( msUnLock() )
					( cAlias )->( dbSkip() )
				endIf
		
				//--< 2. FILTRA OS NOVOS CODREG'S DE ACORDO COM A DE0 >---------------------------------------------
				aEval( aDados,{ | x | iif( allTrim( upper( x[ 2 ] ) ) == allTrim( upper( aCodReg[ nZ ] ) ),aadd( aFilDados,x ),nil ) } )
			next nZ
		endIf
	else
		//--< 1. EXCLUI LOGICAMENTE OS REGISTROS ANTERIORES >---------------------------------------------
		( cAlias )->( msSeek( xFilial( cAlias ) + cCodLay ) )
		while( xFilial( cAlias ) + cCodLay == ( cAlias )->&( cAlias + "_FILIAL" ) + ( cAlias )->&( cAlias + "_CODLAY" ) )
			recLock( cAlias,.F. )
			( cAlias )->( dbDelete() )
			( cAlias )->( msUnLock() )
			( cAlias )->( dbSkip() )
		EndDo
		
		//--< 2. FILTRA O LAYOUT DO ARQUIVO A SER GRAVADO >---------------------------------------------
		aEval( aDados,{ | x | iif( allTrim( upper( x[ 2 ] ) ) == allTrim( upper ( cCodLay ) ),aadd( aFilDados, x ),nil ) } )
	endIf
	
	//--< 3. GRAVACAO DE DADOS - DE0,DE1,DE3 E DE9 >---------------------------------------------
	if( len( aFilDados ) > 0 )
		//--< RESERVA OS CODREG'S A SEREM GRAVADOS NA DE3 >---------------------------------------------
		if( cAlias == "DE0" )
			nPosCReg := ascan( aCabec,{ |x| upper( allTrim( x[ 1 ] ) ) == "DE0_CODREG" } )
			aEval( aFilDados,{ | x | aadd( aCodReg,x[ nPosCReg ] ) } )
		endIf
				
		for nZ:=1 to len( aFilDados )
			recLock( cAlias,.T. )
			for nX:=1 to len( aCabec )
				nPosCpo := ( cAlias )->( fieldPos( aCabec[ nX ][ 1 ] ) )
				if( nPosCpo > 0 )
					if( "FILIAL" $ aCabec[ nX ][ 1 ] )
						( cAlias )->( fieldPut( nPosCpo,xFilial( cAlias ) ) )
					elseIf( aCabec[ nX ][ 2 ] == "N" )
						( cAlias )->( fieldPut( nPosCpo,val( aFilDados[ nZ ][ nX ] ) ) )
					elseIf( aCabec[ nX ][ 2 ] == "D" )
						( cAlias )->( fieldPut( nPosCpo,CtoD( aFilDados[ nZ ][ nX ] ) ) )
					else
						( cAlias )->( fieldPut( nPosCpo,aFilDados[ nZ ][ nX ] ) )
					endIf
				else
					msgStop( "Campo nใo inexistente no dicionแrio de dados:[ " + aCabec[ nX ][ 1 ] + " ]","Erro encontrado" )
					disarmTransaction()
					break
				endIf
			next nX
			( cAlias )->( msUnLock() )
		next nZ
	endIf
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PtuCpErr
Funcao auxiliar do PtuCopia() contra de erros no processamento do PTU BATCH

@author    TOTVS
@version   1.xx
@since     03/04/2017
/*/
//------------------------------------------------------------------------------------------
static function PtuCpErr( e )
	if( e:gencode > 0 )
		msgStop( "Descri็ใo do erro: " + allTrim( e:Description ),"Erro encontrado"  )
		disarmTransaction()
		break
	endIf
Return

//+------------------------------------------------------------------
/*/{Protheus.doc} ChkGrava

@author  PLS TEAM
@version P11
@since   22/09/16
/*/
//+------------------------------------------------------------------ 
Function ChkGrava(nH,cLinStr,lForce)
DEFAULT lForce := .F.
If Len(cLinStr) > 10240 .or. lForce
   PTUHash(cLinStr)
   FWrite(nH,cLinStr,Len(cLinStr))   
   cLinStr := ""
EndIf   
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ PLSMUDSIS  ณ Autor ณ Alexander           ณ Data ณ 05.10.07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Verifica o sistema operacional usado e ajusta as barras	  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSMUDSIS(cConteudo)

If  !ISSRVUNIX()
	cConteudo := StrTran(cConteudo,"/","\")
Else
	cConteudo := StrTran(cConteudo,"\","/")
EndIf   
cConteudo := lower(cConteudo)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fim da rotina															   |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
Return cConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} PTUHash
Funcao de gera็ใo do hash para o PTU Batch, implementado na versใo 8.0

@author  Lucas Nonato
@version P11
@since   22/09/16
/*/
//------------------------------------------------------------------- 

Function PTUHash(cLin, lEnd, nHandle)
	local cHash			:= ""
	local nTam 			:= 0
	local lGeraHash 	:= .T.
	local nHdlMd5

	default lEnd 		:= .F.
	default nHandle		:= 0

	// Validacao para nao gerar o hash em versoes antigas, 
	// lGeraHash iniciado como .T. devido a alguns layous nao utilizarem as funcoes genericas para exportacao
	if( select( 'DE9' ) > 0 .And. val( DE9->DE9_VERLAY ) < 8.0 )
		lGeraHash := .F.
	EndIf

	if( lGeraHash )
		if( !lEnd )
			if (! file( cFileMd5 ) )
				nHdlMd5 := fCreate( cFileMd5,0,,.F. )
			else
				nHdlMd5 := fOpen( cFileMd5,FO_READWRITE + FO_SHARED )
			endif
		
			if ( nHdlMd5 >= 0 )
			 	nTam := fSeek( nHdlMd5,0,2 )
				cHash := strTran( cLinStr,chr( 13 ) + chr( 10 ),"" )
				fWrite( nHdlMd5,cHash,len( cHash ) )
				fClose( nHdlMd5 )			
			endIf
		Else
			cHash := padR( PTULN( "R998" ),8 ) + '998' + padR( MD5File( cFileMd5,2 ), 32 )
		
			if( nHandle <> 0 )
				fWrite( nHandle,cHash,len( cHash ) )
			else
				fWrite( nH,cHash,len( cHash ) )
			endIf

			if( file( cFileMd5 ) )
				fClose( nHdlMd5 )
				fErase( cFileMd5 )
			endIf
		endIf
	endIf
return