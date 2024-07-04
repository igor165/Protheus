#define __aCdCri086 {"052","Evento cobrado pela operadora destino nao foi pre-autorizado."}
#define __aCdCri090 {"056","A guia que foi autorizada para a operadora destino nao foi cobrada portando nao sera paga."}
#define __aCdCri091 {"057","Usuario importado invalido. Deve ser alterado o usuario para o correto ou glosada a nota."}
#define __aCdCri099 {"063","Participacao de servico informada invalida."}
#define __aCdCri195 {"575","O tipo de atendimento  e uma consulta e o codigo de servico e um procedimento."}
#define __aCdCri145 {"083","Item com quantidade maior que a solicitada"}
#define __aCdCri146 {"084","Resumo de internação sem previa Solicitação"}
#define __aCdCri001 {"035","Usuario nao possui cobertura para este procedimento."}

#include "PLSMGER.CH"
#include "PROTHEUS.CH"

#define cPerg    "PLS500    "
#define cPerAna  "PLS50B    "
#define aLayouts {"2.6","2.7","2.8","2.9","3.0","3.1","3.2","3.3","3.4","3.5","3.6","3.7","3.8","4.0","4.1","4.1A","4.1B","5.0","5.0a","6.0","6.1","6.3","7.0","8.0","9.0","9.1","10.0","10.0A","11.0","11.0A","11.3"}
#define cLocalExec "2" //a importacao do ptu e encarada como sendo feita no contas medicas

#define G_CONSULTA  "01"
#define G_SADT_ODON "02"
#define G_SOL_INTER "03"
#define G_REEMBOLSO "04"
#define G_RES_INTER "05"
#define G_HONORARIO "06"
#define G_ANEX_QUIM "07"
#define G_ANEX_RADI "08"
#define G_ANEX_OPME "09"
#define G_REC_GLOSA "10"
#define G_PROR_INTE "11"

STATIC aUnidades := {	{"AUX","AUR"},{"COP","COR","UCO"},{"HM ","HMR","PPM","RCC","CIR"},{"PA ","PAP","PAR"},{"FIL"},{"DOP","CRR","INC"},{"TCR","VDI","VMD","VMT","VTX","REA"}}

STATIC aPriorida := {  	{"HM ,HMR,PPM,RCC,CIR"},; 		//[1]honorario
						{"PA ,PAP,PAR"},;        		//[2]honorario
						{"AUX,AUR"},;					//[3]honorario
						{"DOP,CRR,INC"},;				//[4]honorario
						{"COP,COR,UCO"},;     			//[5]custo
						{"TCR,VDI,VMD,VMT,VTX,REA"},;	//[6]custo
						{"FIL"}}  						//[7]filme

STATIC aTpPart    := {}
STATIC nHorIni
STATIC cArquivo   := ""
STATIC lUsrGen    := .F.
STATIC a500Var    := {}
STATIC a500Pos    := {}
STATIC aCriticas  := {}
STATIC aCritReal  := {}
STATIC aResumo    := {}
STATIC aCritNota  := {}
STATIC lOK        := .F.
STATIC _nPosITREG := 0
STATIC _nPosFTREG := 0
STATIC _nPosISEQ  := 0
STATIC _nPosFSEQ  := 0
STATIC cUniDes    := ""
STATIC cUniOri    := ""
STATIC cAnoMes    := ""
STATIC cAMPAG     := ""
STATIC aDadRda    := {}
STATIC aDadUsr    := {}
STATIC nLine      := 1
STATIC cAliasPLS  := ""
STATIC aRecnosGer := {}
STATIC cPLSFiltro
STATIC cCodSeq	 := ""
STATIC _DT_EMI_FAT
STATIC _DT_VEM_FAT
STATIC _DT_EMI_NDC
STATIC _DT_VEM_NDC
STATIC _NR_FATURA
STATIC _VL_TOT_FAT := 0
STATIC _VL_TOT_NDC := 0
STATIC _NR_NDC
STATIC _NR_COMP
STATIC cTipDoc1    := ""
STATIC cTipDoc2    := ""
STATIC cDocFis1    := ""
STATIC cDocFis2    := ""
STATIC cCodProGen
STATIC lConverProc
STATIC lCriadoBRJ := .F.
STATIC nRegraGrvImp
STATIC lImpPTU    := .T.
STATIC cMatrCob
STATIC cNomCob
STATIC cUltCodigo := ""
STATIC cUltPart   := ""
STATIC cRdaUlt    := ""
STATIC cDataUlt   := ""
STATIC cViaUlt	  := ""
STATIC cMatrAntGen := "99999999999999999"
STATIC cCodPadCon  := ""
STATIC cCodUni502  := ""
STATIC aGuiaNaoExi := {}
STATIC aRegAtuMov := {}
STATIC lCrit099   := .F.
STATIC cDes099    := ""
STATIC pMoeda2    := "@E 999,999,999.99"
STATIC nImpBD6	  := GetNewPar("MV_P500BD6","0")
STATIC nNVerTra
STATIC cCodPaPro  := GetNewPar("MV_PLSTBPD","01")
STATIC aCodEdi	  := {}
STATIC cCodLayPLS := ""
STATIC oBrwBRJ	:= NIL
STATIC nTamBD7	:= 0
STATIC xaPegs	:= {}

//Arrays da estrutura do BD5, BE4, BD5xBD6 e BE4xBD6
STATIC aCmpBD5BD6 := {}
STATIC aCmpBE4BD6 := {}
STATIC aCposPadD5	:= {}
STATIC aCposPadE4	:= {}

STATIC lMVPLSX500 := (GetNewPar("MV_PLSX500","0")=="1")
//CASO SEJA CRIADA MAIS UMA VARIAVEL STATICA LEMBRAR DE LIMPA-LA NA FUNCAO
//ProcA50

/*/{Protheus.doc} PLSEDIA500
Importacao A500
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Function PLSEDIA500
PRIVATE lDelBd7Rec := .F.
PRIVATE aCdCores:= {}
PRIVATE cCadastro := "Importacao PTU-500"
PRIVATE aRotina   := MenuDef()
PRIVATE aCodSeqImp:= {}
PRIVATE aErrVarVin:= {.F., "", "", ""}
Private l500S := .F.

BD6->(dbsetorder(1))
BE2->(dbsetorder(1))

//Define cores da legenda
aCdCores := { 	{ 'BR_VERMELHO','Importado e Pago' },{ 'BR_VERDE'  ,'Importado' } }

//Adiciona rotinas no menu
Aadd(aRotina,{ "Legenda"    	    , "PLSP500LEG", 0 , K_Incluir , 0, .F.})
aadd(aRotina,{ "Listar Crit."		,'PLSP500Usr' , 0 , K_Alterar , 0, Nil})
aadd(aRotina,{ "Alt.For.Pagto"		,'PLSP500AFP' , 0 , K_Alterar , 0, Nil})
aadd(aRotina,{ "Inc.Manual Fat."	,'AxInclui'   , 0 , K_Incluir , 0, Nil})

aCmpBD5BD6 := CmpCabxBD6("BD5")
aCmpBE4BD6 := CmpCabxBD6("BE4")

//Monta novo Browse
cPLSFiltro := "BRJ->BRJ_FILIAL == '"+ BRJ->(xFilial("BRJ"))+ "' .And. BRJ->BRJ_REGPRI == '1' "

oBrwBRJ := FWmBrowse():New()
oBrwBRJ:SetAlias( 'BRJ' )
oBrwBRJ:SetDescription( 'Importação PTU A500' )
oBrwBRJ:SetFilterDefault( cPLSFiltro )

oBrwBRJ:AddLegend( "BRJ->BRJ_STATUS == '1'",	'BR_VERDE'   ,	OemToAnsi( "Importado" ) )
oBrwBRJ:AddLegend( "BRJ->BRJ_STATUS == '2'",	'BR_VERMELHO',	OemToAnsi( "Importado e Pago" ) )

oBrwBRJ:Activate()
	
Return

/*/{Protheus.doc} PLSED500MV
Importacao A500
@author Tulio Cesar
@since  17.01.2005
@version P12
/*/
Function PLSED500MV()
Local aSays     := {}
Local aButtons  := {}
Local aRetPri   := {}
Local aArea     := {}
Local cCadastro := "Efetua a importacao do Layout A-500"
Local aAmbiente	:= {}
Local nFor		:= 0
Local nI		:= 0
Local nPos		:= 0
Local aNotas    := {}
Local aNotasAux := {}
Local lFatal	:= .F.
Local lImport	:= .F.
Local lAnalisar := .F.
Local nAltura 	:= 160
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Local aResAux	:= {}
Local cMensagem	:= ""
Local nPos1		:= 0
Local nPos2		:= 0
Local nPos3		:= 0
Local nPos4		:= 0

//Carregas as criticas em memoria e cria o SX1 On Demand...
CarregaCrit()

SX3->(dbsetorder(2))
SX3->(dbseek("BD7_VLRAPR"))
nTamBD7 := SX3->X3_DECIMAL

aCritReal := {}
aResumo   := {}
aCritNota := {}
aNotas	  := {}

//Analisa ambiente para verificar se a rotina pode ser executada...
cAMPAG := ""
aAmbiente := AnalisaAmb()

If ! aAmbiente[1]
	PLSCRIGEN(aAmbiente[2],{ {"Descricao","@C",200} }, "  Falha no ambiente ",NIL,NIL,NIL,NIL, NIL,NIL,"G",220)
	
	//Novo filtro
	
	If Valtype(oBrwBRJ) == "O"
		oBrwBRJ:Refresh(.T.)
		oBrwBRJ:ExecuteFilter()
	Else
		DbSelectArea("BRJ")
		cPLSFiltro := "@BRJ_FILIAL = '"+xFilial("BRJ")+"' AND BRJ_REGPRI = '1' AND D_E_L_E_T_ = ' '"
		SET FILTER TO &cPLSFiltro
	EndIf
	Return
Else
	cUniDes := PLSINTPAD()
Endif

//Monta dados para exibicao da tela de perguntas/processamento

aadd(aSays,"Efetua a importacao do Layout A-500")

//Monta botoes para janela de processamento

aadd(aButtons, { 5,.T.,{|| aCriticas := {},  CarregaCrit(), Pergunte(cPerg,.T. ), VldMesAno() } } )
aadd(aButtons, { 1,.T.,{|| Proc2BarGauge({|| aRetPri := ProcA50(@cMensagem) }, cCadastro) , FechaBatch() }} )
aadd(aButtons, { 2,.T.,{|| FechaBatch() }} )

//Exibe janela de processamento

FormBatch( cCadastro, aSays, aButtons,, nAltura )

//NOVO MECANISMO DE CRITICAS DO PTU 500
If Len(aRetPri) >= 2
	lFatal   := aRetPri[2]
	lImport  := aRetPri[3]
	If Len(aRetPri) >= 4
		lAnalisar := aRetPri[4]
	Endif
Endif

If ! lFatal .and. lImport
	aNotasAux := {}
	For nFor := 1 To Len(aCodSeqImp)
		If !Empty(aCodSeqImp[nFor])
			BRJ->(DbSetOrder(1))
			BRJ->(MsSeek(xFilial("BRJ")+aCodSeqImp[nFor]))
		EndIf
		aNotasAux := PLSP500Usr(nil,nil,nil,nil,.F.,cCodProGen)
		For nI := 1 To Len(aNotasAux)
			aAdd(aNotas,aNotasAux[nI])
		Next nI
	Next nFor
Endif

If Len(aRetPri) >= 5
	If !Empty(aRetPri[05]) 
		PLSCRIGEN(aRetPri[05],{ {"Arquivo","@C",50},{"Critica","@C",30},{"Conteudo","@C",80} },"Criticas da Importacao",NIL,NIL,NIL,NIL, NIL,NIL,"G",240)
	EndIf
Endif

If Len(aCritReal) > 0 .or. Len(aCritNota) > 0 .or. Len(aResumo) > 0 .or. Len(aNotas) > 0
	
	DbSelectArea("BRJ")
	oDialog   := nil
	aArea     := GetArea()
	cCadastro := "Resumo do processamento"
	oFolder := nil
	bOK     := {|| RestArea(aArea) , nOpca :=1 , oDialog:End()}
	bCancel := {|| RestArea(aArea) , nOpca :=2 , oDialog:End()}
	oCriti01:= nil
	oCriti02:= nil
	oCriti03:= nil
	nFor	:= 1
	bBlock  := {||}
	aBut	:= {}
	aCab01  := { {"Arquivo","@C",040} , {"Codigo","@C",040} , {"Critica","@C",200 } , {"Linha","@C",040 } , {"Descricao","@C",300 } }
	aCab02  := { {"Arquivo","@C",040} , {"Guia","@C",080} , {"Status","@C",100 } , {"Alias","@C",60 } , {"Numero do Registro","9999999999",60 } , {"Pre-Autorizada? (Sim/Nao)","@C",60 } , {"Loc.Dig/PEG/Nota","@C",100 } }
	aCab03  := { {"Arquivo","@C",040} , {"Guia","@C",080} , {"Critica","@C",200 } , {"Descricao","@C",150 },{"Dado","@C",100 }}
	aCab04  := { {"Arquivo","@C",040} , {"Tipo de Critica","@C",080} , {"Numero da Guia","@C",080} , {"Matricula","@C",060} , {"Nome do Usuario","@C",080} , {"Impresso","@C",040 } , {"Codigo do Evento","@C",040 } }
	aCritRea:= {}
	aResum  := {}
	aCritNot:= {}
	aNota	:= {}
	xaPegs	:= {}
	
	//Define Dialogo...
	aSize := MsAdvSize()
	AAdd( aObjects, { 100, 100, .T., .T. } )
	
	aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	nPos1 := aPosObj[1][1]
	nPos2 := aPosObj[1][2]
	nPos3 := aPosObj[1][4]*0.80 
	nPos4 := aPosObj[1][3]*0.90
	
	DEFINE MSDIALOG oDialog TITLE cCadastro FROM aSize[7],0 TO aSize[4]/7.5,aSize[3]/4.8 OF GetWndDefault()
	@ nPos1,nPos2 FOLDER oFolder SIZE nPos3,nPos4 OF oDialog PIXEL PROMPTS  OemtoAnsi("Criticas do arquivo"),OemtoAnsi("Guias geradas"),OemtoAnsi("Criticas das guias"),OemtoAnsi("Outras criticas PTU")
		
	If Len(aCritReal) > 0
		
		oCriti01 := TcBrowse():New( 012, 005, aSize[3]/1.3, aSize[4]/1.3,,,, oFolder:aDialogs[1],,,,,,,,,,,, .F.,, .T.,, .F., )
		aCritRea := aClone(aCritReal)
		For nFor := 1 To Len(aCab01)
			bBlock := "{ || aCritRea[oCriti01:nAt, "+Str(nFor,4)+"] }"
			bBlock := &bBlock
			oCriti01:AddColumn(TcColumn():New(aCab01[nFor,1],bBlock,aCab01[nFor,2],nil,nil,nil,aCab01[nFor,3],.F.,.F.,nil,nil,nil,.F.,nil))
		Next	
		oCriti01:SetArray(aCritRea)
		aCritReal := {}
	Endif
	
	If Len(aResumo) > 0
		oCriti02 := TcBrowse():New( 012, 005, aSize[3]/1.3, aSize[4]/1.3,,,, oFolder:aDialogs[2],,,,,,,,,,,, .F.,, .T.,, .F., )
		// Altera-se a ordem do aResumo para que o arquivo fique em primeiro. 
		// Assim mantenho o legado das posições enviadas e recebidas por Pontos de Entradas.
		aResAux  := {}
		For nFor := 1 To Len(aResumo)
			aAdd(aResAux,{aResumo[nFor][7],aResumo[nFor][1],aResumo[nFor][2],aResumo[nFor][3],aResumo[nFor][4],aResumo[nFor][5],aResumo[nFor][6]})
		Next nFor
		aResum	 := aClone(aResAux)
		For nFor := 1 To Len(aCab02)
			bBlock := "{ || aResum[oCriti02:nAt, "+Str(nFor,4)+"] }"
			bBlock := &bBlock
			oCriti02:AddColumn(TcColumn():New(aCab02[nFor,1],bBlock,aCab02[nFor,2],nil,nil,nil,aCab02[nFor,3],.F.,.F.,nil,nil,nil,.F.,nil))
		Next nFor
		oCriti02:SetArray(aResum)
		aResumo := {}
	Endif
	
	If Len(aCritNota) > 0
		
		oCriti03 := TcBrowse():New( 012, 005, aSize[3]/1.3, aSize[4]/1.3,,,, oFolder:aDialogs[3],,,,,,,,,,,, .F.,, .T.,, .F., )
		For nFor := 1 To Len(aCritNota)
			nPos := Ascan(aCriticas,{|x| x[1] == aCritNota[nFor,3]})
			If nPos > 0
				aCritNota[nFor,3] := aCritNota[nFor,3]+" - "+aCriticas[nPos,2]
			Endif
		Next
		aCritNot := aClone(aCritNota)
		For nFor := 1 To Len(aCab03)
			bBlock := "{ || aCritNot[oCriti03:nAt, "+Str(nFor,4)+"] }"
			bBlock := &bBlock
			oCriti03:AddColumn(TcColumn():New(aCab03[nFor,1],bBlock,aCab03[nFor,2],nil,nil,nil,aCab03[nFor,3],.F.,.F.,nil,nil,nil,.F.,nil))
		Next
		oCriti03:SetArray(aCritNot)
		aCritNota := {}
	Endif
	
	If Len(aNotas) > 0
		
		oCriti04 := TcBrowse():New( 012, 005, aSize[3]/1.3, aSize[4]/1.3,,,, oFolder:aDialogs[4],,,,,,,,,,,, .F.,, .T.,, .F., )
		aNota := aClone(aNotas)
		For nFor := 1 To Len(aCab04)
			bBlock := "{ || aNota[oCriti04:nAt, "+Str(nFor,4)+"] }"
			bBlock := &bBlock
			oCriti04:AddColumn(TcColumn():New(aCab04[nFor,1],bBlock,aCab04[nFor,2],nil,nil,nil,aCab04[nFor,3],.F.,.F.,nil,nil,nil,.F.,nil))
		Next
		oCriti04:SetArray(aNota)
		aNotas := {}
		
	Endif
	
	Aadd(aBut, {"RELATORIO",{ || ImpCriT(aCritRea,aCab01,aResum,aCab02,aCritNot,aCab03,aNota,aCab04,"Criticas","M",132) },"Imprimir"} )
	
	ACTIVATE MSDIALOG oDialog  ON INIT EnchoiceBar(oDialog,bOK,bCancel,.F.,aBut) CENTER
	
Elseif Len(aCritReal)+Len(aCritNota)+Len(aResumo)+Len(aNotas) == 0  .and. (lAnalisar .or. lImport)
	If Empty(cMensagem)
		MsgInfo("Nao foram encontradas criticas no arquivo.")
	Else
		MsgInfo(cMensagem)
	EndIf
Endif


//Fim da rotina principal...

If Valtype(oBrwBRJ) == "O"
	oBrwBRJ:Refresh(.T.)
	oBrwBRJ:ExecuteFilter()
Else
	DbSelectArea("BRJ")
	cPLSFiltro := "@BRJ_FILIAL = '"+xFilial("BRJ")+"' AND BRJ_REGPRI = '1' AND D_E_L_E_T_ = ' '"
	SET FILTER TO &cPLSFiltro
EndIf
	
Return

/*/{Protheus.doc} ProcA50
Processamento da Importacao A500
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Static Function ProcA50(cMensagem, lAutoma, aLista)
LOCAL cLayPLS
LOCAL cArquivo
Local cDirOri    := ""
Local aArquivos  := {}
//Local aLista     := {}
Local aMatCol    := {}
Local aRetCri    := {}
Local aResCri    := {}
Local lOk        := .F.
LOCAL lImportar
LOCAL lGerarLog
LOCAL cCodLDP
LOCAL lMudarFase
LOCAL bRet       := { || {lOK,lFatal,lImportar,lAnalisar,aResCri} }
LOCAL lFileOpen
LOCAL aStruc     := { {"CAMPO","C",1082,0}}
LOCAL oTempTable
LOCAL aRetFun
LOCAL lFoundUsr	 := .F.
LOCAL lGuiaCriada := .F.
LOCAL nRSeqIni    := 0
LOCAL nArqu       := 0
LOCAL nTotArq     := 0
LOCAL cProcesso   := ""
LOCAL nFor
LOCAL nPos
LOCAL nRecno
LOCAL cTipGui
LOCAL cChvNtPesq
LOCAL cLote		  := ""
LOCAL nQtdEveAux := 0
LOCAL cCodCri    := ""
LOCAL cDesCri    := ""
LOCAL lCriIntern := .T.
LOCAL cTpProc    := Alltrim(GetNewPar("MV_PLSICRE","Z"))
LOCAL lCriaUsr   := .f.

LOCAL lP500MATANT:= existBlock("P500MATANT")
LOCAL lPLS500PU  := existBlock("PLS500PU")
LOCAL lPL500CFN  := existBlock("PL500CFN")
LOCAL lPL500MF	 := existBlock("PL500MF")
Local lPLS500AF := ExistBlock("PLS500AF")
Local lPL500AC := Existblock("PL500AC")
Local lPL500FIM := ExistBlock("PL500FIM")

//501

LOCAL dDatGer
LOCAL dDatVen
LOCAL dDatEmi
LOCAL nValTot  := 0
LOCAL nValNdc  := 0
LOCAL cChaveGui
local cCodOpe := ""

//502

LOCAL cChav502 := ""
LOCAL aChav502 := {}
LOCAL lAmbulat := .F.
LOCAL nQtd502  := 0
LOCAL nQtdDiZ  := 0
LOCAL cNextLote:= ""
LOCAL cTpCarater := ""
LOCAL lFindGui   := .F.

//503

LOCAL cChav503 := ""
LOCAL aChav503 := {}
LOCAL nQtd503  := 0
LOCAL lOnApr503:= .F.
LOCAL nJ       := 1
LOCAL nI	   := 1
LOCAL lDiaria  := .F.
LOCAL cCodSer  := ""

//504

LOCAL nQtd504  := 0
LOCAL nVal     := 0
LOCAL nValTpCob2 := 0
LOCAL nValTpCob3 := 0
LOCAL nValServ := 0
LOCAL dDatSer
LOCAL nQtdCob  := 0
LOCAL cChav504 := ""
LOCAL cSenhaPLS,nFilesTat
LOCAL aChaUlGu := {}
LOCAL nTotAPRImp := 0
LOCAL nVal1 := 0
LOCAL nVal2 := 0
LOCAL nVal3 := 0
LOCAL nVal4 := 0
LOCAL nVal5 := 0
LOCAL nVal6 := 0
LOCAL nTot	:= 0
LOCAL aBD6Nota := {}
LOCAL cAuxDat  := ""
LOCAL cDataPro := ""
LOCAL cHorPro  := ""
LOCAL cHorFim  := ""
LOCAL lAteRN   := .F.
LOCAL cGuiJur  := ""
LOCAL nNextRec := 0
LOCAL lCompativel := .F.
LOCAL lFoundBR8 := .F.
LOCAL lConsulta	:= .F.
LOCAL aAreaBE4  := {}
LOCAL aEventos  := {}
LOCAL cVarSer   := ""

//505

LOCAL cChave505 := ""
LOCAL aChav505 := {}
LOCAL nQtd505  := 0
LOCAL lFatal   := .F.
LOCAL cTpNota
LOCAL lAnalisar:= .F.
LOCAL nRecNext := 0
LOCAL cCodExcess:= ""
LOCAL lMudSituac := .F.
LOCAL aRetBTU    := {}
LOCAL lAtuGuia   := GetNewPar("MV_PLAG500","1") == "1"
LOCAL lDePara    := GetNewPar("MV_P500HDP","1") == "1"
LOCAL lDeParaBTU := GetNewPar("MV_PLAJBTU","0") == "1"
LOCAL cTpConsulta:= ""
LOCAL cSenNrOp   := ""
LOCAL lNovInd    := GETNEWPAR("MV_PLSUNI","0") == "1" .And. PLSALIASEXI("BZC") .And. BZC->(FieldPos("BZC_CHVGUI")) > 0 .And. BZC->(FieldPos("BZC_ALIAS")) > 0 .And.  FindFunction('MSGCOMINT')
LOCAL aTrtMsg    := {}
LOCAL nLinMsg    := 0
LOCAL nQtd507   := 0
LOCAL nSeqGui   := 0
LOCAL aRetR507  := {}
LOCAL lVldMesAno := .T.
LOCAL lDuplicado := .F.
LOCAL aChaveOld := {"","0"}
LOCAL aChaveAtu := {"","0"}
LOCAL nRecnoB5T  := 0

//506
LOCAL nQtd506  := 0

Local lMVPLVLALP := getNewPar("MV_PLVLALP","0") == '0'
Local cCD_SERVICO := ""
Local cCD_VIA_ACE := ""
Local aItePac01	:= {}

Default aLista     := {}
Default cMensagem := ""
Default lAutoma		:= .F.

PRIVATE lAbortPrint := .F. // Controle para abortar (sempre como esta aqui)
PRIVATE lNaoConsulta:=.F.  // Verifica se o procedimento pertence ao tipo de atendimento
PRIVATE cTpFasSt:='211' 	// BCI_TIPO+BCI_FASE+BCI_SITUAC  COMPLEMENTADO DA CHAVE PARA A BUSCA DA PEG NA TABELA BCI
PRIVATE aRecVlrApr	:={}
PRIVATE nTpCob := 0
Private cNmUsrAlt	:= ""
PRIVATE lExB5T_B6T  := PLSALIASEXI("B5T") .And. PLSALIASEXI("B6T")
Private aPacPTU01 := {}

//Limpa variaveis estaticas

aTpPart     := {}
aCriticas   := {}
aCritReal   := {}
aResumo     := {}
aCritNota   := {}
aNotas		:= {}
lOK         := .F.
_nPosITREG  := 0
_nPosFTREG  := 0
_nPosISEQ   := 0
_nPosFSEQ   := 0
cUniOri     := ""
aDadRda     := {}
aDadUsr     := {}
nLine       := 1
cAliasPLS   := ""
aRecnosGer  := {}
cCodSeq	   := ""
_DT_EMI_FAT := nil
_DT_VEM_FAT := nil
_DT_EMI_NDC := nil
_DT_VEM_NDC := nil
_NR_FATURA  := nil
_VL_TOT_FAT := 0
_VL_TOT_NDC := 0
_NR_NDC		:= 0
_NR_COMP    := nil
cCodProGen  := nil
lConverProc := nil
lCriadoBRJ  := .F.
nRegraGrvImp:= nil
lImpPTU     := .T.
cMatrCob    := nil
cNomCob 	:= nil
cUltCodigo  := ""
cUltPart    := ""
cRdaUlt     := ""
cViaUlt		:= ""
cDataUlt    := ""
cMatrAntGen := "99999999999999999"
cCodPadCon  := ""
cCodUni502  := ""
aGuiaNaoExi := {}
aRegAtuMov  := {}
lCrit099    := .F.
cDes099     := ""
nNVerTra	:= 0
aCodEdi		:= {}
cCodLayPLS  := ""
xaPegs	:= {}

Pergunte(cPerg,.F.)
//Valida parâmetros mês/ano
lVldMesAno := VldMesAno()

if lVldMesAno

If !lAutoma
	IncProcG1("Preparando importacao.")
EndIf

If lAutoma .AND. Empty(cUniDes)
	cUniDes		:=	PLSINTPAD()
EndIf

//Busca parametros...
Pergunte(cPerg,.F.)

cLayPLS      := mv_par01
cDirOri      := AllTrim(mv_par02)
lImportar    := mv_par03 == 1
lGerarLog    := mv_par04
cCodLDP      := mv_par05
lMudarFase   := mv_par06 == 1

cCodProGen  := alltrim(mv_par10)

If !empty(mv_par11+mv_par12)
	cAMPAG   := mv_par11+mv_par12
Endif

lConverProc  := (mv_par13==2) //1 = Nao , 2 = Sim
cCodPaPro	 := If(Empty(mv_par14),GetNewPar("MV_PLSTBPD","01"),mv_par14)
cCodPadCon   := mv_par15
nRegraGrvImp := mv_par16

lAnalisar    := mv_par03==2
lImpPTU := .T.

l500S := cLayPLS >= "A500S"

If Empty(cDirOri)
	lRet := .F.
	cMensagem := "Cancelou a janela de seleção do diretório."
	Return(Eval(bRet))
EndIf

aArquivos := directory(cDirOri+"*.*")

If Len(aArquivos) == 0
	lRet := .F.
	cMensagem := "Não haviam arquivos no diretório."
	Return(Eval(bRet))
Else
	If !lAutoma
		For nFor := 1 to len(aArquivos)
			aAdd(aLista,{aArquivos[nFor][1],DtoC(aArquivos[nFor][3]),aArquivos[nFor][4],AllTrim(transform(aArquivos[nFor][2]/1000,"@E 999,999,999.99"))+" KB",.F.})
		Next
	EndIf
	
	aLista := aSort(aLista,,, { |x,y| DTOS(CTOD(x[2])) < DTOS(CTOD(y[2])) })
	// Colunas do browse
	aAdd( aMatCol,{"Arquivo"	,'@!',200} )
	aAdd( aMatCol,{"Data"		,'@!',040} )
	aAdd( aMatCol,{"Hora"		,'@!',040} )
	aAdd( aMatCol,{"Tamanho"	,'@!',040} )
		
	// Browse para selecionar
	If !lAutoma
		lOk := PLSSELOPT( "Selecione o(s) arquivos(s) a serem importados", "Marca e Desmarca todos", aLista, aMatCol, K_Incluir,.T.,.T.,.F.)
	EndIf
	
	// Verifica se algum arquivo foi selecionado
	If lOk
		lOk := aScan(aLista,{|x| x[len(aLista[1])] == .T.}) > 0
	EndIf

	// Processando arquivos
	If !lOk .AND. !lAutoma
		lRet := .F.
		cMensagem := "Não foi selecionado nenhum registro."
		Return(Eval(bRet))
	EndIf
EndIf

nTotArq := 0
For nArqu := 1 to Len(aLista)
	If (aLista[nArqu][len(aLista[nArqu])])
		nTotArq++
	EndIf
Next nArqu

For nArqu := 1 to Len(aLista)
	If !(aLista[nArqu][len(aLista[nArqu])])
		Loop
	EndIf
	
	cProcesso := "["+StrZero(nArqu,6)+"] de ["+StrZero(nTotArq,6)+"] - "
	
	cArquivo 	:= cDirOri+aLista[nArqu][01]
	aTpPart     := {}
	aCriticas   := {}
	lOK         := .F.
	_nPosITREG  := 0
	_nPosFTREG  := 0
	_nPosISEQ   := 0
	_nPosFSEQ   := 0
	cUniOri     := ""
	aDadRda     := {}
	aDadUsr     := {}
	nLine       := 1
	cAliasPLS   := ""
	aRecnosGer  := {}
	cCodSeq	   := ""
	_DT_EMI_FAT := nil
	_DT_VEM_FAT := nil
	_DT_EMI_NDC := nil
	_DT_VEM_NDC := nil
	_NR_FATURA  := nil
	_VL_TOT_FAT := 0
	_VL_TOT_NDC := 0
	_NR_NDC		:= 0
	_NR_COMP    := nil
	lCriadoBRJ  := .F.
	cMatrCob    := nil
	cNomCob 	:= nil
	cUltCodigo  := ""
	cUltPart    := ""
	cRdaUlt     := ""
	cViaUlt		:= ""
	cDataUlt    := ""
	cMatrAntGen := "99999999999999999"
	cCodUni502  := ""
	aGuiaNaoExi := {}
	aRegAtuMov  := {}
	lCrit099    := .F.
	cDes099     := ""
	nNVerTra	:= 0
	aCodEdi		:= {}
	cCodLayPLS  := ""
	xaPegs		:= {}
	aPacPTU01	:= {}
	
	//Verifica se pode ocorrer a importacao
	aRetCri := ProcPerImp(cLayPLS,cArquivo,lImportar,lGerarLog,cCodLDP,lMudarFase,cCodProGen,cAMPAG,lConverProc,cCodPadCon,nRegraGrvImp)
	If !Empty(aRetCri)
		lFatal := .t.
		lImportar:= .f.
		For nFor := 1 To Len(aRetCri)
			aAdd(aResCri,aRetCri[nFor])
		Next
		Loop
	Else
		lImportar:= .T.
	Endif
	
	PLSConTPA()
	
	PLSLSC500(@mv_par07,@mv_par08,.F.,@mv_par09)
	
	If !lAutoma
		IncProcG1(cProcesso + "Iniciando Transacao.")
	EndIf
		
	//Inicia a transacao
		
	//Verifica se layout existe...
	
	DE9->(DbSetOrder(1))
	If ! DE9->(MsSeek(xFilial("DE9")+cLayPLS))
		AnalisaCrit("01","",Nil,Nil,Nil,Nil,aLista[nArqu][01])
		lFileOpen := .F.
	Else
		cCodLayPLS := AllTrim(DE9->DE9_VERLAY)
	Endif
	
	lCrit099   := PLSPOSGLO(PLSINTPAD(),__aCdCri099[1],__aCdCri099[2],cLocalExec)
	cDes099    := PLSBCTDESC()
	
	//Regra - Testa existencia do arquivo...
	
	If ! File(cArquivo)
		AnalisaCrit("01","",,Nil,Nil,Nil,Nil,aLista[nArqu][01])
		lFileOpen := .F.
	Else
		If !lAutoma
			IncProcG1(cProcesso + "Abrindo arquivo de origem.")
		EndIf
		
		//--< Criação do objeto FWTemporaryTable >---
		oTempTable := FWTemporaryTable():New( "Trb" )
		oTemptable:SetFields( aStruc )
		oTempTable:Create()
		
		dbSelectArea( "Trb" )
		nFileStat := AppFromTXT(cArquivo)
		
		If nFileStat = 0 // OK
			lFileOpen := .T.
			Trb->(DbGoBottom())
			If Empty(Trb->Campo)
				Trb->(RecLock("Trb",.F.))
				Trb->(DbDelete())
				Trb->(MsUnLock())
			Endif
			Trb->(DbGoTop())
		ElseIf nFileStat = -1
			// Falha de abertura
			lFileOpen := .F.
			aadd(aResCri,{aLista[nArqu][01],"00","Falha na Abertura do Arquivo. Codigo do erro -1"})
		elseIF nFileStat = -2
			// Falha de abertura
			lFileOpen := .F.
			aadd(aResCri,{aLista[nArqu][01],"00","Falha na Abertura do Arquivo. Codigo do erro -2"})
		elseIF nFileStat = -3
			// Falha de abertura
			lFileOpen := .F.
			aadd(aResCri,{aLista[nArqu][01],"00","Falha na Abertura do Arquivo. Codigo do erro -3"})
		Endif
	Endif
	
	cCodSeq := ""
	
	
	//Se arquivo de importacao foi lido inicia checagem de regras...
	
	If lFileOpen
		
		//Mensagem ao usuario...
		If !lAutoma
			BarGauge1Set(Trb->(RecCount()))
			IncProcG1(cProcesso + "Preparando ambiente de processamento.")
		EndIf
				
		//Monta layout para matriz de apoio...
		
		MonLayout(cLayPLS)

		If JaImporFat()
			aadd(aResCri,{aLista[nArqu][01],"00","Fatura ["+alltrim(_NR_FATURA) +"] já importada para esta Unimed ["+alltrim(cUniOri)+"]"})
			lImpPTU := .f.
			cMensagem := "Importação cancelada devido a duplicidade do Número do Documento Fiscal."
		Endif
		
		//Regra - Buscar em qual posicao fica o tipo de registro no layout...
		
		DE0->(DbSetOrder(1))
		If DE0->(MsSeek(xFilial("DE0")+cLayPLS))
			
			aRetFun    := PLSA500GPF(AllTrim(DE0->DE0_CODREG),"TP_REG",aLista[nArqu][01])
			_nPosITREG := aRetFun[1]
			_nPosFTREG := aRetFun[2]
			
			If _nPosITREG == 0 .Or. _nPosFTREG == 0
				AnalisaCrit("03","",,Nil,Nil,Nil,Nil,aLista[nArqu][01])
			Endif
			
			aRetFun   := PLSA500GPF(AllTrim(DE0->DE0_CODREG),"NR_SEQ",aLista[nArqu][01])
			_nPosISEQ := aRetFun[1]
			_nPosFSEQ := aRetFun[2]
			
			If _nPosISEQ == 0 .Or. _nPosFSEQ == 0
				AnalisaCrit("04","",Nil,Nil,Nil,Nil,aLista[nArqu][01])
			Endif
		Else
			AnalisaCrit("05","",Nil,Nil,Nil,Nil,aLista[nArqu][01])
		Endif
		
		//Regra - Testa se layout definido ja esta suportado...
		
		If Ascan(aLayouts,cCodLayPLS) == 0
			AnalisaCrit("06","",Nil,Nil,Nil,Nil,aLista[nArqu][01])
		Endif
		
		//Processa um arquivo de Reembolso de Anestesista - R507
		If mv_par19 == 2
			
			//Verifica se pode executar a importacao
			
			While ! Trb->(Eof())
				
				If Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "501"
					
					//Regra - Testa se existe a unimed origem e destino...
					
					BA0->(DbSetOrder(1))
					If ! BA0->(MsSeek(xFilial("BA0")+PLSA500GCF("R501","CD_UNI_ORI")))
						AnalisaCrit("08",PL5GetCo("R501","CD_UNI_ORI"),PLSA500GCF("R501","CD_UNI_ORI"),Nil,Nil,Nil,aLista[nArqu][01])
					Else
						cCodOpe := PLSA500GCF("R501","CD_UNI_ORI")
						BAU->(DbSetOrder(7))
						If ! BAU->(MsSeek(xFilial("BAU")+PLSA500GCF("R501","CD_UNI_ORI")))
							AnalisaCrit("09",PL5GetCo("R501","CD_UNI_ORI"),PLSA500GCF("R501","CD_UNI_ORI"),Nil,Nil,Nil,aLista[nArqu][01])
						Else
							aRetFun := PLSDADRDA(cUniDes,BAU->BAU_CODIGO)
							
							If ! aRetFun[1]
								AnalisaCrit("10",PL5GetCo("R501","CD_UNI_ORI"),PLSA500GCF("R501","CD_UNI_ORI"),Nil,Nil,Nil,aLista[nArqu][01])
							Else
								aDadRda := PLSGETRDA()
								cUniOri := PLSA500GCF("R501","CD_UNI_ORI")
							Endif
						Endif
					Endif
					
					//Regra - Testa se a data de geracao eh valida
					
					dDatGer := stod(PLSA500GCF("R501","DT_GERACAO"))
					If ((Month(dDatGer) < 1 .OR. Month(dDatGer) > 12))
						AnalisaCrit("11",PL5GetCo("R501","DT_GERACAO"),PLSA500GCF("R501","DT_GERACAO"),Nil,Nil,Nil,aLista[nArqu][01])
					Endif
					
					//Regra - Testa se o numero da competencia eh valido
					
					cAnoMes := "20"+PLSA500GCF("R501","NR_COMP")
					If ((val(Subs(cAnoMes,5,2)) < 1 .OR. (val(Subs(cAnoMes,5,2))) > 12))
						AnalisaCrit("12",PL5GetCo("R501","NR_COMP"),PLSA500GCF("R501","NR_COMP"),Nil,Nil,Nil,aLista[nArqu][01] )
					Endif
					
					//Regra - Testa data de vencimento da fatura
					dDatVen := stod(PLSA500GCF("R501","DT_VEM_DO1"))
					nTpCob 	:= val(Subs(PLSA500GCF("R501","TP_COBRANC"),1))
					
					If !nTpCob == 1
						If Month(dDatVen) < 1 .OR. Month(dDatVen) > 12
							AnalisaCrit("13",PL5GetCo("R501","DT_VEM_DO1"),PLSA500GCF("R501","DT_VEM_DO1"),Nil,Nil,Nil,aLista[nArqu][01])
						Endif
					EndIf
					
					//Regra - Testa data de emissao da fatura
					
					dDatEmi := stod(PLSA500GCF("R501","DT_EMI_DO1"))
					If !nTpCob == 1
						If ((Year(dDatEmi) > Year(dDataBase)) .OR. (Month(dDatEmi) < 1 .OR. Month(dDatEmi) > 12))
							AnalisaCrit("14",PL5GetCo("R501","DT_EMI_DO1"),PLSA500GCF("R501","DT_EMI_DO1"),Nil,Nil,Nil,aLista[nArqu][01])
						Endif
					EndIf
					
					If ! BA0->(MsSeek(xFilial("BA0")+PLSA500GCF("R501","CD_UNI_DES")))
						AnalisaCrit("15",PL5GetCo("R501","CD_UNI_DES"),PLSA500GCF("R501","CD_UNI_DES"),Nil,Nil,Nil,aLista[nArqu][01])
					Endif
				EndIf
				Trb->(DbSkip())
				nRSeqIni ++
				nLine ++
			EndDo
			
			If !lAutoma
				BarGauge2Set(nRSeqIni)
			EndIf
			Trb->(DbGoTop())
			
			nSeqGui := 1
			
			BAU->(DbSetOrder(4))//BAU_FILIAL+BAU_CPFCGC
			BA1->(DbSetOrder(1))
			BB0->(DbSetOrder(4))//BB0_FILIAL+BB0_ESTADO+BB0_NUMCR+BB0_CODSIG+BB0_CODOPE
			
			//Realiza a importacao do arquivo de Reembolso de Anestesista
			
			If lImpPTU
				While ! Trb->(Eof())
					If !lAutoma
						IncProcG2("[ " + AllTrim(Str(nTot)) + " ] De [ " + AllTrim(Str(nRSeqIni)) + " ] " + AllTrim(Str((nTot*100)/nRSeqIni,3)) + "% Concluido ")
					EndIf
					
					//R501 - HEADER
					
					If Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "501"
						nTot++
						If PLSLOG500()
							nHorIni := Seconds()
						Endif
						
						_DT_EMI_FAT := stod(PLSA500GCF("R501","DT_EMI_DO1"))
						_DT_VEM_FAT := stod(PLSA500GCF("R501","DT_VEM_DO1"))
						_NR_FATURA  := PLSA500GCF("R501","NR_DOC_1_A")
						_NR_COMP    := PLSA500GCF("R501","NR_COMP")
						_VL_TOT_FAT := val(Subs(PLSA500GCF("R501","VL_TOT_DO1"),1,12)+"."+Subs(PLSA500GCF("R501","VL_TOT_DO1"),13,2))
						_NR_NDC     := PLSA500GCF("R501","NR_DOC_2_A")//Preciso gravar o numero ou espacos para posterior envio do A550
						nNVerTra	:= val(PLSA500GCF("R501","NR_VER_TRA"))
						nTpCob      := val(Subs(PLSA500GCF("R501","TP_COBRANC"),1))
						
						cTipDoc1 := PLSA500GCF("R501","TP_DOC_1")
						cTipDoc2 := PLSA500GCF("R501","TP_DOC_2")
						cDocFis1 := PLSA500GCF("R501","DOC_FISC_1")
						cDocFis2 := PLSA500GCF("R501","DOC_FISC_2")
						cUniOri  := PLSA500GCF("R501","CD_UNI_ORI")
						
						If nTpCob != 2
							_DT_VEM_NDC  := stod(PLSA500GCF("R501","DT_VEN_DO2"))
							_DT_EMI_NDC := stod(PLSA500GCF("R501","DT_EMI_DO2"))
							_VL_TOT_NDC := val(Subs(PLSA500GCF("R501","VL_TOT_DO2"),1,12)+"."+Subs(PLSA500GCF("R501","VL_TOT_DO2"),13,2))
						EndIf
						
						If PLSLOG500()
							PlsLogFil("-> Registro 500                          -> "+AllTrim(Str(Seconds()-nHorIni,10,3))+" Segundo(s)",__PLSFL500)
							nHorIni := Seconds()
						Endif
						
						//Cria BRJ
						CriBRJReem(cArquivo)
						
					EndIf
					
					//R507 - COBRANÇA DE REEMBOLSO DE ANESTESISTA
					If Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "507"
						aRetR507  := CriGRemAne(nSeqGui,aLista[nArqu][01])
						nSeqGui   := aRetR507[1]
						nQtd507 ++
					EndIf
					Trb->(DbSkip())
				EndDo
			EndIf
			
			//Fecha o arquivo de trabalho...
			
			Trb->(DbGoBottom())
			if( select( "Trb" ) > 0 )
				oTempTable:Delete()
			endIf
			
			//Finaliza aqui o processamento
			
			Return(Eval(bRet))
			
		Else
			//Validar estrutura fisica do arquivo...
			While ! Trb->(Eof())
				
				//Exibe mensagem de processamento...
				If !lAutoma
					IncProcG1(cProcesso + "Analisando estrutura do arquivo [ "+Subs(Trb->Campo,_nPosISEQ,_nPosFSEQ)+" ]")
				EndIf
				
				If Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "501"
					
					
					//Regra - Testa se existe a unimed origem e destino...
					
					BA0->(DbSetOrder(1))
					If ! BA0->(MsSeek(xFilial("BA0")+PLSA500GCF("R501","CD_UNI_ORI")))
						AnalisaCrit("08",PL5GetCo("R501","CD_UNI_ORI"),PLSA500GCF("R501","CD_UNI_ORI"),Nil,Nil,Nil,aLista[nArqu][01])
					Else
						cCodOpe := PLSA500GCF("R501","CD_UNI_ORI")
						BAU->(DbSetOrder(7))
						If ! BAU->(MsSeek(xFilial("BAU")+PLSA500GCF("R501","CD_UNI_ORI")))
							AnalisaCrit("09",PL5GetCo("R501","CD_UNI_ORI"),PLSA500GCF("R501","CD_UNI_ORI"),Nil,Nil,Nil,aLista[nArqu][01])
						Else
							aRetFun := PLSDADRDA(cUniDes,BAU->BAU_CODIGO)
							
							If ! aRetFun[1]
								AnalisaCrit("10",PL5GetCo("R501","CD_UNI_ORI"),PLSA500GCF("R501","CD_UNI_ORI"),Nil,Nil,Nil,aLista[nArqu][01])
							Else
								aDadRda := PLSGETRDA()
								cUniOri := PLSA500GCF("R501","CD_UNI_ORI")
							Endif
						Endif
					Endif
					
					//Regra - Testa se a data de geracao eh valida
					
					dDatGer := stod(PLSA500GCF("R501","DT_GERACAO"))
					If ((Month(dDatGer) < 1 .OR. Month(dDatGer) > 12))
						AnalisaCrit("11",PL5GetCo("R501","DT_GERACAO"),PLSA500GCF("R501","DT_GERACAO"),Nil,Nil,Nil,aLista[nArqu][01])
					Endif
					
					//Regra - Testa se o numero da competencia eh valido
					
					cAnoMes := "20"+PLSA500GCF("R501","NR_COMP")
					If ((val(Subs(cAnoMes,5,2)) < 1 .OR. (val(Subs(cAnoMes,5,2))) > 12))
						AnalisaCrit("12",PL5GetCo("R501","NR_COMP"),PLSA500GCF("R501","NR_COMP"),Nil,Nil,Nil,aLista[nArqu][01] )
					Endif
					
					//Regra - Testa data de vencimento da fatura
					dDatVen := stod(PLSA500GCF("R501","DT_VEM_DO1"))
					nTpCob 	:= val(Subs(PLSA500GCF("R501","TP_COBRANC"),1))
					If ! nTpCob == 1
						If Month(dDatVen) < 1 .OR. Month(dDatVen) > 12
							AnalisaCrit("13",PL5GetCo("R501","DT_VEM_DO1"),PLSA500GCF("R501","DT_VEM_DO1"),Nil,Nil,Nil,aLista[nArqu][01])
						Endif
					EndIf
					
					//Regra - Testa data de emissao da fatura			                    	?
					dDatEmi := stod(PLSA500GCF("R501","DT_EMI_DO1"))
					If ! nTpCob == 1
						If ((Year(dDatEmi) > Year(dDataBase)) .OR. (Month(dDatEmi) < 1 .OR. Month(dDatEmi) > 12))
							AnalisaCrit("14",PL5GetCo("R501","DT_EMI_DO1"),PLSA500GCF("R501","DT_EMI_DO1"),Nil,Nil,Nil,aLista[nArqu][01])
						Endif
					EndIf
					
					If ! BA0->(MsSeek(xFilial("BA0")+PLSA500GCF("R501","CD_UNI_DES")))
						AnalisaCrit("15",PL5GetCo("R501","CD_UNI_DES"),PLSA500GCF("R501","CD_UNI_DES"),Nil,Nil,Nil,aLista[nArqu][01])
					Endif
					
					//Regra - Testa o valor total da fatura			                    	?
					//Somatoria das seq(013,014,015,022,023 e 024) do Registro 504.
					
					nValTot 	:= val(Subs(PLSA500GCF("R501","VL_TOT_DO1"),1,12)+"."+Subs(PLSA500GCF("R501","VL_TOT_DO1"),13,2))
					nNVerTra	:= val(PLSA500GCF("R501","NR_VER_TRA"))
					
					//Regra - Validacao para importacao do NDC - Registro R501 , VL_TOT_FAT
					//
					//Quando o Tipo de Cobranca (R501 - TP_COBRANCA) for igual:
					//    1 = NDC (Reembolso de Custo Assistencial)
					//    2 = Fatura (considerar a regra do nValTot, sendo que a regra eh a
					//        Somatoria das seq(013,014,015,022,023 e 024) do Registro 504).
					//
					//    3 = Fatura + NDC (Reembolso de Custo Assistencial)
					//		Somatoria das seq(022,023 e 024) do Registro 504.
					
					nValNdc := val(Subs(PLSA500GCF("R501","VL_TOT_DO2"),1,12)+"."+Subs(PLSA500GCF("R501","VL_TOT_DO2"),13,2))
					
				ElseIf Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "502"
					
					//Regra - Para um mesmo lote, nao podera haver numeros de notas repetidos.
					//A "chave" do registro sera sempre LOTE+NOTA.
					
					cChav502   := PLSA500GCF("R502","CD_UNI")+PLSA500GCF("R502","NR_LOTE")+PLSA500GCF("R502","NR_NOTA")
					cCodUni502 := PLSA500GCF("R502","CD_UNI")
					If Ascan(aChav502,{|a| a[1] = cChav502}) <> 0
						AnalisaCrit("16",PL5GetCo("R502","NR_NOTA"),Nil,Nil,Nil,aLista[nArqu][01])
					Endif
					aadd(aChav502,{cChav502})
					
					//Regra - Codigo da excecao ao atendimento
					
					If     ! PLSA500GCF("R502","CD_EXCESSA") $ "0,C,I,L,O,E,J"
						AnalisaCrit("18",PL5GetCo("R502","CD_EXCESSA"),PLSA500GCF("R502","CD_EXCESSA"),Nil,Nil,Nil,aLista[nArqu][01])
					ElseIf PLSA500GCF("R502","CD_EXCESSA") $ "C,I,L,O,E,J"
						nQtdDiZ ++
					Endif
					
					cCodExcess := PLSA500GCF("R502","CD_EXCESSA")
					
					If PLSA500GCF("R502","ID_RN") == "S"
						lAteRN := .T.
					Endif
					
					If PLSA500GCF("R502","ID_LIMINAR") == "S"
						cGuiJur := "1"
					Else
						cGuiJur := "0"
					Endif
					
					//Regra - Carater de atendimento
					
					cTpCarater := ""
					If PLSA500GCF("R502","TP_NOTA","025") == "1" .And. !PLSA500GCF("R502","TP_CONSULT","048") $ "1,2,3,4,5"
						AnalisaCrit("19",PL5GetCo("R502","TP_CARATER","048"),PLSA500GCF("R502","TP_CONSULT","048"),Nil,Nil,Nil,aLista[nArqu][01])
					Else
						cTpCarater  := PLSA500GCF("R502","TP_CARATER","047")
						cTpConsulta := PLSA500GCF("R502","TP_CONSULT","049")
					Endif
					
					//Tratamento do tipo de consulta
					If ! empty(cTpConsulta)
						
						cLote     := PLSA500GCF("R502","NR_LOTE")+PLSA500GCF("R502","NR_NOTA")
						cNextLote := cLote
						lConsulta := .F.
						nRecno    := Trb->(Recno())
						BR8->(DbSetOrder(3))
						While !Trb->(Eof()) .and. cLote == cNextLote
							
							If Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "504"
								cCodSer := cValToChar(PLSA500GCF("R504","CD_SERVICO"))
								If PLSISCON(If(!Empty(cCodPadCon),cCodPadCon,"02"),cValToChar(PLSA500GCF("R504","CD_SERVICO"))) .or. PLSISCON(If(!Empty(cCodPaPro),cCodPaPro,"01"),cValToChar(PLSA500GCF("R504","CD_SERVICO"))) ;
										.Or. cCodSer $ ("10101012/10101039/10101020")
									lConsulta := .T.
									exit
								Endif
							Endif
							Trb->(DbSkip())
							
							If 	Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "502"
								cNextLote := PLSA500GCF("R502","NR_LOTE")+PLSA500GCF("R502","NR_NOTA")
							Elseif Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "503"
								cNextLote := PLSA500GCF("R503","NR_LOTE")+PLSA500GCF("R503","NR_NOTA")
							Elseif Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "504"
								cNextLote := PLSA500GCF("R504","NR_LOTE")+PLSA500GCF("R504","NR_NOTA")
							Else
								cNextLote := "###"
							Endif
						Enddo
						
						//Nova regra - Critica de Consulta com carater de Urg/Eme aplica somente para Consulta Eletiva 10101012
						If (lConsulta .and. !Empty(cTpCarater) .And. cCodSer == "10101012") .or. (!lConsulta .and. Empty(cTpCarater))
							AnalisaCrit("64",PL5GetCo("R502","TP_CARATER","047"),PLSA500GCF("R502","TP_CARATER","047"),Nil,Nil,Nil,aLista[nArqu][01])
						Endif
						
						Trb->(DbGoTo(nRecno))
					Endif
					
					//Regra - Indicador do tipo de paciente
					
					BGY->(DbSetOrder(1))
					If ! BGY->(MsSeek(xFilial("BGY")+PLSINTPAD()+PLSA500GCF("R502","TP_PACIENT")))
						AnalisaCrit("21",PL5GetCo("R502","TP_PACIENT"),PLSA500GCF("R502","TP_PACIENT"),Nil,Nil,Nil,aLista[nArqu][01])
					Endif
					
					//Regra - Tipo de saida para atendimento de consulta e SADT
					
					nRecno := Trb->(Recno())
					Trb->(DbSkip())
					If Subs(Trb->Campo,_nPosITREG,_nPosFTREG) <> "503"
						Trb->(DbGoTo(nRecno))
						If !(PLSA500GCF("R502","TP_SAIDCON","018") $ "1,2,3,4,5,6,9") .And. PLSA500GCF("R502","NR_VER_TIS") <= "3.00.00"
							AnalisaCrit("61",PL5GetCo("R502","TP_SAIDCON"),PLSA500GCF("R502","TP_SAIDCON"),Nil,Nil,Nil,aLista[nArqu][01])
						Endif
					Endif
					Trb->(DbGoTo(nRecno))
					
					//Checa a regra da guia principal
					If PLSA500GCF("R502","TP_ATENDIM","019") == "07" .and. Empty(PLSA500GCF("R502","NR_GUIA_PR","021"))
						AnalisaCrit("65",PL5GetCo("R502","NR_GUIA_PR"),PLSA500GCF("R502","NR_GUIA_PR","021"),Nil,Nil,Nil,aLista[nArqu][01])
					Endif
					
					//Checa a regra da consulta e se o procedimento e um servi?
					If PLSA500GCF("R502","TP_ATENDIM","019") == "04"  .and. !lConsulta
						AnalisaCrit("73",PL5GetCo("R502","TP_ATENDIM"),PLSA500GCF("R502","","019"),Nil,Nil,Nil,aLista[nArqu][01])
						lNaoConsulta := .T.
					Endif
					
					nQtd502 ++
					
				ElseIf Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "503"
					
					nQtd503 ++
					
					//guardo o lote atual
					cLote     := PLSA500GCF("R503","NR_LOTE")+PLSA500GCF("R503","NR_NOTA")
					cNextLote := cLote
					lDiaria   := .F.
					nRecno    := Trb->(Recno())
					BR8->(DbSetOrder(3))
					
					While !Trb->(Eof()) .and. cLote == cNextLote
						
						If Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "504"
							cCodSer := cValToChar(PLSA500GCF("R504","CD_SERVICO"))
							If BR8->(MsSeek(xFilial("BR8")+cCodSer)) .and. BR8->BR8_TPPROC == '4'
								lDiaria := .T.
								exit
							Endif
						Endif
						Trb->(DbSkip())
						
						If 	Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "502"
							cNextLote := PLSA500GCF("R502","NR_LOTE")+PLSA500GCF("R502","NR_NOTA")
						Elseif Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "503"
							cNextLote := PLSA500GCF("R503","NR_LOTE")+PLSA500GCF("R503","NR_NOTA")
						Elseif Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "504"
							cNextLote := PLSA500GCF("R504","NR_LOTE")+PLSA500GCF("R504","NR_NOTA")
						Else
							cNextLote := "###"
						Endif
					Enddo
	
					Trb->(DbGoTo(nRecno))
					If !lDiaria
						AnalisaCrit("63","",Nil,Nil,Nil,Nil,aLista[nArqu][01])
					Endif
					
				ElseIf Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "504"
					
					//A "chave" do registro sera sempre LOTE+NOTA.
					
					cChav504 := cCodUni502+PLSA500GCF("R504","NR_LOTE")+PLSA500GCF("R504","NR_NOTA")
					If cChav502 != cChav504
						AnalisaCrit("26",PL5GetCo("R504","NR_NOTA"),Nil,Nil,Nil,Nil,aLista[nArqu][01])
					Endif
					
					//Regra - Procedimento...
					if !empty(PLSA500GCF("R504","ID_PACOTE"))
						cCdServ := cValToChar(PLSA500GCF("R504","CD_SERVICO"))
					else
						cCdServ := GetNewPar("MV_PLPACPT","99999998")
					endif
					If lDeParaBTU //lDeParaBTU
						aRetBTU := PTUDePaBTU(PLSA500GCF("R504","TP_TABELA"),cCdServ,cCodPaPro,.T.,.F.)
						If len(aRetBTU) > 0
							BR8->(DbSetOrder(1))
							BR8->(MsSeek(xFilial("BR8")+aRetBTU[1]+aRetBTU[2]))
						Else
							BR8->(DbSetOrder(1))
							BR8->(MsSeek(xFilial("BR8")+cCodPaPro+cCdServ))
						Endif
						
					ElseIf lDePara
						PLBusProTab(cCdServ,.F.,PLSA500GCF("R504","DT_SERVICO"),nil,lConverProc,cUniOri,cCodProGen,cCodPadCon,cCodPaPro)
					Else
						BR8->(DbSetOrder(1))
						If !BR8->(MsSeek(xFilial("BR8")+cCodPaPro+cCdServ))
							BR8->(DbSetOrder(3))
							BR8->(MsSeek(xFilial("BR8")+cCdServ))
						Endif
					EndIf
					
					If ! BR8->(Found())
						AnalisaCrit("45",PL5GetCo("R504","CD_SERVICO"),cCdServ,Nil,Nil,Nil,aLista[nArqu][01])
					ElseIf BR8->BR8_BENUTL <> "1"
						AnalisaCrit("76",PL5GetCo("R504","CD_SERVICO"),cCdServ,Nil,Nil,Nil,aLista[nArqu][01])
					Endif
					
					//Regra - Data de Servico
					
					dDatSer := stod(PLSA500GCF("R504","DT_SERVICO"))
					If Empty(dDatSer)
						AnalisaCrit("27",PL5GetCo("R504","DT_SERVICO"),PLSA500GCF("R504","DT_SERVICO"),Nil,Nil,Nil,aLista[nArqu][01])
					Endif
					
					//Regra - Quantidade Cobrada
					
					If PLSA500GCF("R504","TP_TABELA") $ '0/4'
						nQtdCob += val(Substr(PLSA500GCF("R504","QT_COBRADA"),1,4))
					Else
						nQtdCob += Val(Substr(PLSA500GCF("R504","QT_COBRADA"),1,4)+"."+Substr(PLSA500GCF("R504","QT_COBRADA"),5,4))
					EndIf
					
					//Regra - CPF/CNPJ
					
					If ! PLSA500GCF("R504","TP_PESSOA") $ "F,J"
						AnalisaCrit("31",PL5GetCo("R504","TP_PESSOA"),PLSA500GCF("R504","TP_PESSOA"),Nil,Nil,Nil,aLista[nArqu][01])
					Endif
					
					lFoundBR8 := BR8->(Found())
					
					//Regra - Que trata o valor total das notas quando TP_COBRANCA = 1  (NDC)
					
					nVal7 := val(Subs(PLSA500GCF("R504","VL_SERV_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_SERV_CO"),13,2)) //seq 013 (R504 VL_SERV_COB)
					nVal8 := val(Subs(PLSA500GCF("R504","VL_CO_COB"),1,12)+"."+Subs(PLSA500GCF("R504","VL_CO_COB"),13,2))	//seq 014 (R504 VL_CO_COB)
					nVal9 := val(Subs(PLSA500GCF("R504","VL_FILME_C"),1,12)+"."+Subs(PLSA500GCF("R504","VL_FILME_C"),13,2))	//seq 015 (R504 VL_FILME_COB)
					
					//Regra - Que trata o valor total das notas quando TP_COBRANCA = 2  (NDC)
					
					nVal1 := val(Subs(PLSA500GCF("R504","VL_SERV_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_SERV_CO"),13,2))
					nVal2 := val(Subs(PLSA500GCF("R504","VL_CO_COB"),1,12)+"."+Subs(PLSA500GCF("R504","VL_CO_COB"),13,2))
					nVal3 := val(Subs(PLSA500GCF("R504","VL_FILME_C"),1,12)+"."+Subs(PLSA500GCF("R504","VL_FILME_C"),13,2))
					
					nVal1 += val(Subs(PLSA500GCF("R504","VL_ADIC_SE"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_SE"),13,2))
					nVal2 += val(Subs(PLSA500GCF("R504","VL_ADIC_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_CO"),13,2))
					nVal3 += val(Subs(PLSA500GCF("R504","VL_ADIC_FI"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_FI"),13,2))
					
					
					//Regra - Que trata o valor total das notas quando TP_COBRANCA = 3  (NDC)
					
					nVal4 := val(Subs(PLSA500GCF("R504","VL_ADIC_SE"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_SE"),13,2))  //seq 022(R504 VL_ADIC_SER)
					nVal5 := val(Subs(PLSA500GCF("R504","VL_ADIC_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_CO"),13,2))  //seq 023(R504 VL_ADIC_CO)
					nVal6 := val(Subs(PLSA500GCF("R504","VL_ADIC_FI"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_FI"),13,2))  //seq 024(R504 VL_ADIC_FILME)
					
					If Len(aDadRda) >= 18
						
						aRdas := PLS720IBD7("0",0,BR8->BR8_CODPAD,BR8->BR8_CODPSA,"",cUniDes,BAU->BAU_CODIGO,'','','','',aDadRda[15],aDadRda[18],"3",'',"1","02",STOD(PLSA500GCF("R504","DT_SERVICO")))
						
						lCompativel := .F.
						
						//verifico se ele nao eh compativem com nenhuma
						For nI := 1 to Len(aRdas)
							
							If   Len(aRdas[nI]) >= 9 .and.;
									!ProcHM(AllTrim(aRdas[nI][1]),AllTrim(PLSA500GCF("R504","TP_PARTICI")),aRdas[nI][9],PLSA500GCF("R504","CD_PORTE_A")) .and. ;
									!ProcCOP(AllTrim(aRdas[nI][1]),AllTrim(PLSA500GCF("R504","TP_PARTICI"))) .and. ;
									!ProcFIL(AllTrim(aRdas[nI][1]),AllTrim(PLSA500GCF("R504","TP_PARTICI")))
								lCompativel := .F.
							Else
								lCompativel := .T.
								exit
							Endif
						Next
						
						If !lCompativel  .and. lFoundBR8
							AnalisaCrit("62",PL5GetCo("R504","CD_SERVICO"),cChav504,Nil,Nil,Nil,aLista[nArqu][01])
						Endif
						
						If ( (nVal1 > 0 .and. (nVal2 > 0 .or. nVal3 > 0))   .or. (nVal2 > 0 .and. (nVal1 > 0 .or. nVal3 > 0))   .or. (nVal3 > 0 .and. (nVal2 > 0 .or. nVal1 > 0)) ) .and. lFoundBR8
							
							nTot := 0
							If nVal1 > 0
								nTot++
							Endif
							
							If nVal2 > 0
								nTot++
							Endif
							
							If nVal3 > 0
								nTot++
							Endif
							
							If Len(aRdas) < nTot
								AnalisaCrit("58",PL5GetCo("R504","CD_SERVICO"),cChav504,Nil,Nil,Nil,aLista[nArqu][01])
							Endif
							
						Endif
						
						// se o procedimento nao tem composição na TDE
						If Len(aRdas) == 0 .and. lFoundBR8
							AnalisaCrit("48",PL5GetCo("R504","CD_SERVICO"),Nil,Nil,Nil,Nil,aLista[nArqu][01])
						Endif
						
					Endif
					
					nValServ 	+= val(Subs(PLSA500GCF("R504","VL_SERV_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_SERV_CO"),13,2))
					nVal		+= nVal1 + nVal2 + nVal3
					nValTpCob2 	+= nVal4 + nVal5 + nVal6
					nValTpCob3 	+= nVal7 + nVal8 + nVal9
					
					If cCodExcess $ "L,C,O"
						If ! ValidaSenha(StrZero(Val((PLSA500GCF("R504","NR_AUTORIZ"))),10),@cCodLDP,StrZero(Val((PLSA500GCF("R504","NR_AUTORIZ"))),10))
							AnalisaCrit("72","Lote/Nota: [ " + PLSA500GCF("R502","NR_LOTE")+" / "+PLSA500GCF("R502","NR_NOTA") + " ]  Senha Informada no arquivo: " + StrZero(Val((PLSA500GCF("R504","NR_AUTORIZ"))),10),Nil,Nil,Nil,Nil,aLista[nArqu][01] )
						EndIf
						
					EndIf
					
					
					//Regra - Quantidade total de registros
					
					nQtd504 ++
				ElseIf Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "505"
					
					//Regra - Para um mesmo lote, nao podera haver numeros de notas repetidos.
					//A "chave" do registro sera sempre LOTE+NOTA.
					
					nQtd505 ++
				ElseIf Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "506"
					nQtd506 ++
				
				ElseIf Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "509"
					
					//Regra - Que trata o valor total das notas
					//QT_TOT_R502	Quantidade total de registros do tipo 502.
					//QT_TOT_R503	Quantidade total de registros do tipo 503.
					//QT_TOT_R504	Quantidade total de registros do tipo 504.
					//QT_TOT_R505	Quantidade total de registros do tipo 505.
					//QT_NOT_EXC	Quantidade total de notas com exceção diferente de 0.
					//QT_NOT_AMB	Quantidade total de notas com Ambulatório igual a 1 (sim).
					//QT_TOT_SER	Quantidade total de serviços dos registros 504.
					//VL_TOT_SERV	Valor total de serviços nos registros 504.
					
					If val(PLSA500GCF("R509","QT_TOTR502")) != nQtd502
						AnalisaCrit("33","Quantidade no campo QT_TOTR502 ["+PLSA500GCF("R509","QT_TOTR502")+"], quantidade no arquivo ["+STRZERO(nQtd502 ,5)+"]",Nil,Nil,Nil,Nil,aLista[nArqu][01])
					Endif
					If val(PLSA500GCF("R509","QT_TOTR503")) != nQtd503
						AnalisaCrit("34","Quantidade no campo QT_TOTR503 ["+PLSA500GCF("R509","QT_TOTR503")+"], quantidade no arquivo ["+STRZERO(nQtd503 ,5)+"]",Nil,Nil,Nil,Nil,aLista[nArqu][01])
					Endif
					If val(PLSA500GCF("R509","QT_TOTR504")) != nQtd504
						AnalisaCrit("35","Quantidade no campo QT_TOTR504 ["+PLSA500GCF("R509","QT_TOTR504")+"], quantidade no arquivo ["+STRZERO(nQtd504 ,5)+"]",Nil,Nil,Nil,Nil,aLista[nArqu][01])
					Endif
					If val(PLSA500GCF("R509","QT_TOTR505")) != nQtd505
						AnalisaCrit("36","Quantidade no campo QT_TOTR505 ["+PLSA500GCF("R509","QT_TOTR505")+"], quantidade no arquivo ["+STRZERO(nQtd505 ,5)+"]",Nil,Nil,Nil,Nil,aLista[nArqu][01])
					Endif
					If val(PLSA500GCF("R509","QT_NOT_EXC")) != nQtdDiZ
						AnalisaCrit("37",PL5GetCo("R509","QT_NOT_EXC"))
					Endif
					If val(Subs(PLSA500GCF("R509","QT_TOT_SER"),1,7)+"."+Subs(PLSA500GCF("R509","QT_TOT_SER"),8,4))  != nQtdCob
						AnalisaCrit("39","Quantidade informada no campo QT_TOT_SER ["+strtran(sTR(val(Subs(PLSA500GCF("R509","QT_TOT_SER"),1,7)+"."+Subs(PLSA500GCF("R509","QT_TOT_SER"),8,4)),11,4),".",",")+"] diferente do total contido QT_COBRADA ["+strtran(str(nQtdCob,11,4),".",",")+"]",Nil,Nil,Nil,Nil,aLista[nArqu][01])
					Endif
					
					If val(Subs(PLSA500GCF("R509","VL_TOT_SER"),1,12)+"."+Subs(PLSA500GCF("R509","VL_TOT_SER"),13,2)) != nValServ
						AnalisaCrit("40","Valor do campo VL_TOT_SER ["+TransForm(val(Subs(PLSA500GCF("R509","VL_TOT_SER"),1,12)+"."+Subs(PLSA500GCF("R509","VL_TOT_SER"),13,2)),pMoeda2)+"] diferente do total contido em VL_SERV_CO ["+transform(nValServ,pMoeda2)+"]",Nil,Nil,Nil,Nil,aLista[nArqu][01])
					Endif
					
				else
					
					//esse Else existe por causa de uma situação em que um cliente Não UNIMED importava PTU. E por algum azar do destino, uma das
					//UNIMEDs que enviavam PTU, enviavam o arquivo formatado errado. Com isso, se passa daqui, ele fica num loop infinito, começa no 1 de 100 e no 400 de 100 ainda tá rodando.
					If !(Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "998" .OR. Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "999")
						lImportar := .F.
						aadd(aResCri,{aLista[nArqu][01],"00","Há inconsistência grave no layout do arquivo, não é possível prosseguir a importação."})
						Exit
					EndIf
					
				Endif
				
				Trb->(DbSkip())
				nRSeqIni ++
				nLine ++
			Enddo
		EndIf
		
		//Regra - Verifica qual Tipo de Cobranca conforme registro R501 TP_COBRANCA
		//
		//1 - Compara nValTpCob3 (somatoria Seq 013,014 e 015) do Registro R504
		//		 com nValNdc (valor do arquivo Registro R501 VL_TOT_NDC)
		//
		//2 - Compara nVal (somatoria Seq 013,014,015,022,023 e 024) do Registro R504
		//  		 com nValTot (valor do arquivo Registro R501 VL_TOT_FAT)
		//
		//3 - Compara nValTpCob2 (somatoria Seq 022,023 e 024) do Registro R504
		// 		 com nValNdc (valor do arquivo Registro RR501 VL_TOT_NDC)
		
		
		If nTpCob == 1
			If (round(nValTpCob3,2) != round(nValNdc,2))
				nLine := 0
				AnalisaCrit("41","Valor R504 ["+TransForm(nVal,pMoeda2)+"] Valor R501 ["+TransForm(nValTot,pMoeda2)+"]",Nil,Nil,Nil,Nil,aLista[nArqu][01])
			Endif
		ElseIf nTpCob == 2
			If (round(nVal,2) != round(nValTot,2))
				nLine := 0
				AnalisaCrit("41","Valor R504 ["+TransForm(nVal,pMoeda2)+"] Valor R501 ["+TransForm(nValTot,pMoeda2)+"]",Nil,Nil,Nil,Nil,aLista[nArqu][01])
			Endif
		ElseIf nTpCob == 3
			If (round(nValTpCob2,2) != round(nValTot,2))
				nLine := 0
				AnalisaCrit("41","Valor R504 ["+TransForm(nVal,pMoeda2)+"] Valor R501 ["+TransForm(nValTot,pMoeda2)+"]",Nil,Nil,Nil,Nil,aLista[nArqu][01])
			Endif
		EndIf
		
		If !lAutoma
			IncProcG1(cProcesso + "Analise finalizada com sucesso.")
		EndIf
		Trb->(DbGoTop())
		
		aRecnosGer := {}
		If !lAutoma
			BarGauge2Set(nRSeqIni)
		EndIf
		
		//INICIO DO PROCESSAMENTO... Somente se tudo foi validado [lImpPTU]
		
		If lImpPTU .And. lImportar .OR. lAutoma
			lOK		:= .t.
			nTot 	:= 0
			nLinMsg := 0
			aTrtMsg := {}
			
			While ! Trb->(Eof())
				If !lAutoma
					IncProcG2("[ " + AllTrim(Str(nTot)) + " ] De [ " + AllTrim(Str(nRSeqIni)) + " ] " + AllTrim(Str((nTot*100)/nRSeqIni,3)) + "% Concluido ")
				EndIf
				
				cDescCp := ""
				lAchInd := .F.
				
				//R501 - HEADER
				
				If subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "501"
					
					nTot++
					
					If PLSLOG500()
						nHorIni := Seconds()
					Endif
					
					_DT_EMI_FAT := stod(PLSA500GCF("R501","DT_EMI_DO1"))
					_DT_VEM_FAT := stod(PLSA500GCF("R501","DT_VEM_DO1"))
					_NR_FATURA  := PLSA500GCF("R501","NR_DOC_1_A")
					_NR_COMP    := PLSA500GCF("R501","NR_COMP")
					_VL_TOT_FAT := val(Subs(PLSA500GCF("R501","VL_TOT_DO1"),1,12)+"."+Subs(PLSA500GCF("R501","VL_TOT_DO1"),13,2))
					
					
					cTipDoc1 := PLSA500GCF("R501","TP_DOC_1")
					cTipDoc2 := PLSA500GCF("R501","TP_DOC_2")
					
					cDocFis1 := PLSA500GCF("R501","DOC_FISC_1")
					cDocFis2 := PLSA500GCF("R501","DOC_FISC_2")
					
					
					
					_NR_NDC     := PLSA500GCF("R501","NR_DOC_2_A")//Preciso gravar o numero ou espacos para posterior envio do A550
					If nTpCob != 2
						_DT_VEM_NDC := stod(PLSA500GCF("R501","DT_VEN_DO2"))
						_DT_EMI_NDC := stod(PLSA500GCF("R501","DT_EMI_DO2"))
						_VL_TOT_NDC := val(Subs(PLSA500GCF("R501","VL_TOT_DO2"),1,12)+"."+Subs(PLSA500GCF("R501","VL_TOT_DO2"),13,2))
					EndIf
					
					
					If PLSLOG500()
						PlsLogFil("-> Registro 500                          -> "+AllTrim(Str(Seconds()-nHorIni,10,3))+" Segundo(s)",__PLSFL500)
						nHorIni := Seconds()
					Endif
					nNVerTra	:= val(PLSA500GCF("R501","NR_VER_TRA"))
					
				//R502 - NOTA DE COBRANCA
				ElseIf Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "502"
					nTot++
					cUltCodigo 	:= ""
					cUltPart   	:= ""
					cRdaUlt   	:= ""
					cViaUlt	 	:= ""
					cDataUlt   	:= ""
					cTipGui	 	:= ""
					cAliasPLS  	:= ""
					nRecNext	:= 0
					nRecnoB5T   := 0
					aChaveOld 	:= {"","0"}
					
					If PLSLOG500()
						nHorIni := Seconds()
					Endif
					
					If lOnApr503
						AnalisaCrit("56",cLote,Nil,Nil,Nil,Nil,aLista[nArqu][01])
						PLCrProGen(aChaUlGu,cCodProGen,PLSA500GCF("R502","DT_ATEND"),;
							cCodSeq,PLSA500GCF("R504","CD_VIA_ACE"),nRegraGrvImp,;
							PLSA500GCF("R502","NR_LOTE"),PLSA500GCF("R502","NR_NOTA"))
						lOnApr503 := .F.
					Endif
					
					//guardo o lote atual
					cLote 	  := PLSA500GCF("R502","NR_LOTE")+PLSA500GCF("R502","NR_NOTA")
					cNextLote := cLote
					aBD6Nota  := {}
					nRecno    := Trb->(Recno())
					
					While !Trb->(Eof()) .and. cLote == cNextLote
						
						If Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "504"
							
							cAuxDat  	:= PLSA500GCF("R504","DT_SERVICO")
							cDataPro 	:= subs(cAuxDat,7,2)+"/"+subs(cAuxDat,5,2)+"/"+subs(cAuxDat,1,4)
							cHorPro  	:= PLSA500GCF("R504","HR_INICIAL")
							cHorFim  	:= PLSA500GCF("R504","HR_FINAL")
							cCD_SERVICO := cValToChar(PLSA500GCF("R504","CD_SERVICO"))
							cCD_VIA_ACE := alltrim(PLSA500GCF("R504","CD_VIA_ACE"))
							cTpPart 	:= alltrim(PLSA500GCF("R504","TP_PARTICI"))
							
							If (nI:=aScan(aBD6Nota,{|x| x[1]+x[2]+x[4]+x[5] == cCD_SERVICO+cDataPro+cHorPro+cCD_VIA_ACE} )) == 0 .or. ;
								(nI > 0 .and. aScan(aBD6Nota[nI][3],{|x| x[1] == cTpPart} ) > 0)
								
								aadd(aBD6Nota,{ cCD_SERVICO,;
									cDataPro,;
									{{cTpPart,Trb->(Recno())}} ,;
									cHorPro,;
									IIF(lConsulta,"00",cCD_VIA_ACE),;
									cHorFim})
								
							Else
								aadd(aBD6Nota[nI][3],{alltrim(PLSA500GCF("R504","TP_PARTICI")),Trb->(Recno())} )
							Endif
						Endif
						
						Trb->(DbSkip())
						
						If 	Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "502"
							cNextLote := PLSA500GCF("R502","NR_LOTE")+PLSA500GCF("R502","NR_NOTA")
						Elseif Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "503"
							cNextLote := PLSA500GCF("R503","NR_LOTE")+PLSA500GCF("R503","NR_NOTA")
						Elseif Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "504"
							cNextLote := PLSA500GCF("R504","NR_LOTE")+PLSA500GCF("R504","NR_NOTA")
						Else
							cNextLote := "###"
						Endif
					Enddo
					
					Trb->(DbGoTo(nRecno))
					lGuiaCriada := .F.
					
					If PLSA500GCF("R502","TP_NOTA") == "1"
						cTipGui   := "01"
						cAliasPLS := "BD5"
					ElseIf PLSA500GCF("R502","TP_NOTA") == "4"
						cTipGui   := "06"
						cAliasPLS := "BD5"
					ElseIf PLSA500GCF("R502","TP_NOTA") == "3" .and. ! lAmbulat
						cTipGui := "05"
						cAliasPLS := "BE4"
					Else
						cTipGui   := "02"
						cAliasPLS := "BD5"
					Endif
					
					nRecno  := Trb->(Recno())
					Trb->(DbSkip())
					If ! Trb->(Eof()) .and. Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "503"
						If cAliasPLS <> "BE4"
							cTipGui := "05"
							cAliasPLS := "BE4"
						Endif
					Endif
					Trb->(DbGoTo(nRecno))
					
					//buscar senha NR_AUTORIZ no 504
					nRecno 		:= Trb->(Recno())
					cSenhaPLS 	:= ""
					cSenNrOp  	:= ""
					nQtdEveAux 	:= 0
					lConsulta 	:= .F.
					
					Trb->(DbSkip()) //p passar o 502
					While ! Trb->(Eof())
						
						If Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "504" .And. Empty(cSenhaPLS)
							cSenhaPLS := StrZero(Val((PLSA500GCF("R504","NR_AUTORIZ"))),10)
							cSenNrOp  := StrZero(Val((PLSA500GCF("R504","NR_AUTORIZ"))),10)
						Endif
						
						If Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "504"
							nQtdEveAux ++
							If !lConsulta
								lConsulta := PLSISCON(If(!Empty(cCodPadCon),cCodPadCon,"02"),cValToChar(PLSA500GCF("R504","CD_SERVICO"))) .or. PLSISCON(If(!Empty(cCodPaPro),cCodPaPro,"01"),cValToChar(PLSA500GCF("R504","CD_SERVICO")))
							Endif
						Endif
						If Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "502" //ja estamos na proxima guia sair do while...
							nRecNext := Trb->(Recno())
							Exit
						Endif
						
						Trb->(DbSkip())
					Enddo
					
					Trb->(DbGoTo(nRecno))
					
					//Se nNVerTra for >= 14 ainda nao tratou a guia de consulta devido a
					//retirada de uso do campo ID_AMBULA
					
					If Empty(cTipGui)
						cTipGui   := "01"
						cAliasPLS := "BD5"
					EndIf
					
					//Se for guia de consulta, tiver + de um evento eu transformo em guia de
					//serviço
					
					If cTipGui == "01" .And. (nQtdEveAux >= 2 .or. !lConsulta)
						cTipGui   := "02"
						cAliasPLS := "BD5"
					Endif
					
					//Se for guia de servico, tiver um evento e ele for consulta transformo em
					//guia de consulta
					
					If cTipGui == "02" .And. nQtdEveAux == 1 .and. lConsulta
						cTipGui   := "01"
						cAliasPLS := "BD5"
					Endif
					
					If PLSLOG500()
						PlsLogFil("-> Registro 502 Parte 1                  -> "+AllTrim(Str(Seconds()-nHorIni,10,3))+" Segundo(s)",__PLSFL500)
						nHorIni := Seconds()
					Endif
					
					If PLSLOG500()
						nHorIni := Seconds()
					Endif
					
					//1o caminho. Caso a nota tivesse sido autorizada vou confrotar dados que a?
					//operadora origem esta cobrando com o que foi autorizado.
					
					If nRegraGrvImp == 1
						cChvNtPesq := Subs(PLSA500GCF("R502","NR_LOTE"),4,5)+PLSA500GCF("R502","NR_NOTA")
					ElseIf nRegraGrvImp == 2
						cChvNtPesq := PLSA500GCF("R502","NR_NOTA")
					ElseIf nRegraGrvImp == 3
						cChvNtPesq := cUniOri+PLSA500GCF("R502","NR_NOTA")
					Endif
					
					cMatrCob := PLSA500GCF("R502","CD_UNI")+PLSA500GCF("R502","ID_BENEF")
					cNomCob  := PLSA500GCF("R502","NM_BENEF")
					aChaUlGu := {}
					
					If Empty(cCodSeq)
						AnalisaPEG(cUniDes,BAU->BAU_CODIGO,cAMPAG,cTipGui,cCodLDP,cArquivo,.T.)
					Endif
					
					cMatric := PLSA500GCF("R502","CD_UNI")+PLSA500GCF("R502","ID_BENEF")
					If cTipGui <> '05' .And. lAtuGuia
						aRet500PQ := A500PQNOTA(cChvNtPesq,cSenhaPLS,cAliasPLS,cCodOpe,cMatric,PLSA500GCF("R502","NR_NOTA"),cLayPls,aLista[nArqu][01])
					Else
						aRet500PQ := {.F.,.F.}
					EndIf
					
					If  lAtuGuia .And.  aRet500PQ[1]
						
						//Ok, guia ok...
						
						DbSelectArea(cAliasPLS)
						aadd(aRecnosGer,{cAliasPLS,&(cAliasPLS+"->("+"Recno())")})
						aadd(aResumo,{PLSA500GCF("R502","NR_LOTE")+PLSA500GCF("R502","NR_NOTA"),"",cAliasPLS,Recno(),"Sim",RetGuia(cAliasPLS),aLista[nArqu][01]})
					Else
						
						//Buscar usuario...
						lFoundUsr := .F.
						
						If lP500MATANT
							lFoundUsr := ExecBlock("P500MATANT",.F.,.F.,{PLSA500GCF("R502","CD_UNI"),PLSA500GCF("R502","ID_BENEF"),PLSA500GCF("R502","NM_BENEF")})
							
							If lFoundUsr
								aRetFun := PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),"1",.F.,dDataBase,,,,,,.F.)
								lUsrGen := .F.
							Endif
						EndIf
						
						If ! lFoundUsr
							aRetFun := PLSDADUSR(PLSA500GCF("R502","CD_UNI")+PLSA500GCF("R502","ID_BENEF"),"1",.F.,dDataBase,,,,,,.F.)
							lUsrGen := .F.
						EndIf
						
						If ! aRetFun[1]
							aRetFun := PLSDADUSR(PLSA500GCF("R502","CD_UNI")+PLSA500GCF("R502","ID_BENEF"),"2",.F.,dDataBase,,,,,,.F.)
							If ! aRetFun[1]
								aRetFun := PLSDADUSR(Subs(PLSA500GCF("R502","CD_UNI"),2,3)+PLSA500GCF("R502","ID_BENEF"),"2",.F.,dDataBase,,,,,,.F.)
								
								If ! aRetFun[1] .And. lPLS500PU
									lFoundUsr := ExecBlock("PLS500PU",.F.,.F.,{PLSA500GCF("R502","CD_UNI"),PLSA500GCF("R502","ID_BENEF")})
									
									If lFoundUsr
										aRetFun := PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),"1",.F.,dDataBase,,,,,,.F.)
									Endif
								Endif
								
								If ! aRetFun[1]
									lFoundUsr := PLSUsrGen(PLSA500GCF("R502","CD_UNI"),,@lCriaUsr)
									
									If ! lFoundUsr
										aadd(aCritNota,{aLista[nArqu][01],PLSA500GCF("R502","NR_LOTE")+PLSA500GCF("R502","NR_NOTA"),"02","Nao foi possivel criar o usuario generico",PLSA500GCF("R502","CD_UNI")+PLSA500GCF("R502","ID_BENEF")})
										lFoundUsr := .F.
									Else
										lUsrGen := .T.
										aRetFun := PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),"1",.F.,dDataBase,,,,,,.F.)
										If ! aRetFun[1]
											aadd(aCritNota,{aLista[nArqu][01],PLSA500GCF("R502","NR_LOTE")+PLSA500GCF("R502","NR_NOTA"),"02",IF(Len(aRetFun)>=2,aRetFun[2,1,2],"Nao foi possivel criar o usuario generico"),PLSA500GCF("R502","CD_UNI")+PLSA500GCF("R502","ID_BENEF")})
											lFoundUsr := .F.
										Else
											lFoundUsr := .T.
											aDadUsr   := PLSGETUSR()
										Endif
									Endif
								Else
									lFoundUsr := .T.
									aDadUsr   := PLSGETUSR()
								Endif
							Else
								lFoundUsr := .T.
								aDadUsr   := PLSGETUSR()
							Endif
						Else
							aDadUsr   := PLSGETUSR()
							lFoundUsr := .T.
						Endif
						
						If lFoundUsr
							//Reposiciona Usuario cfme data de atendimento
							cDatAte := PLSA500GCF("R502","DT_ATEND")
							dDatAte := ctod(subs(cDatAte,9,2)+"/"+subs(cDatAte,6,2)+"/"+subs(cDatAte,1,4))
							lMsgUsr := AltCodUsr(dDatAte)
							If ! lMsgUsr
								aadd(aCritNota,{aLista[nArqu][01],PLSA500GCF("R502","NR_LOTE")+PLSA500GCF("R502","NR_NOTA"),"47","Erro no histórico de transferencias do usuario.",PLSA500GCF("R502","CD_UNI")+PLSA500GCF("R502","ID_BENEF")})
							Endif
							//Alimenta dados do usuario
							aDadUsr := PLSGETUSR()
						Endif
						
						If PLSLOG500()
							PlsLogFil("-> Registro 502 Parte 2                  -> "+AllTrim(Str(Seconds()-nHorIni,10,3))+" Segundo(s)",__PLSFL500)
							nHorIni := Seconds()
						Endif
						
						//Testa dados fundamentais para incluir o cabecalho da guia...
						If lFoundUsr
							
							//Posiciona na PEG de acordo com tipo de guia...
							If PLSLOG500()
								nHorIni := Seconds()
							Endif
							
							AnalisaPEG(cUniDes,BAU->BAU_CODIGO,cAMPAG,cTipGui,cCodLDP,cArquivo)
							
							If PLSLOG500()
								PlsLogFil("-> Registro 502 Parte 3                  -> "+AllTrim(Str(Seconds()-nHorIni,10,3))+" Segundo(s)",__PLSFL500)
								nHorIni := Seconds()
							Endif
							
							//Cria o arquivo de cabecalho (Guia de servico ou GIH)....
							If cAliasPLS == "BD5"
								
								If PLSLOG500()
									nHorIni := Seconds()
								Endif

								aChaUlGu    := CriaGuiaSV(cAMPAG,cSenhaPLS,lAteRN,cGuiJur,@nRecnoB5T,lCriaUsr)
								lGuiaCriada := .T.
								
								aadd(aRecnosGer,{"BD5",BD5->(Recno())})
								
								DbSelectArea(cAliasPLS)
								aadd(aResumo,{PLSA500GCF("R502","NR_LOTE")+PLSA500GCF("R502","NR_NOTA"),"",cAliasPLS,Recno(),"Nao",RetGuia(cAliasPLS),aLista[nArqu][01]})
								
								If PLSLOG500()
									PlsLogFil("-> Registro 502 Parte 4                  -> "+AllTrim(Str(Seconds()-nHorIni,10,3))+" Segundo(s)",__PLSFL500)
									nHorIni := Seconds()
								Endif
								
							Else
								
								If PLSLOG500()
									nHorIni := Seconds()
								Endif
								
								aChaUlGu 	:= CriaGuiaHS(cAMPAG,cSenhaPLS,cChvNtPesq,cCodOpe,lAteRN,PLSA500GCF("R502","NR_NOTA"),cSenNrOp,cGuiJur,@nRecnoB5T)
								lGuiaCriada := .T.
									cTpCarater  := PLSA500GCF("R502","TP_CARATER","047")
									AtuGIHR502(cTpCarater,cLayPLS,aLista[nArqu][01])
									
									aAreaBE4 := BE4->(GetArea())
									BE4->(DbSetOrder(7))
									If BE4->(MsSeek(xFilial("BE4")+cSenhaPLS)) .and. val(cSenhaPLS) > 0 .and. VerOpeSol("BE4",cCodOpe,cSenhaPLS,.F.)
										lFindGui := .T.
									Else
										lFindGui := .F.
									EndIf
									
									If ! lFindGui .And. ! Empty(cSenNrOp) .And. val(cSenNrOp) > 0
										
										BE4->(DbSetOrder(8))
										If BE4->(MsSeek(xFilial("BE4")+cSenNrOp)) .and. VerOpeSol("BE4",cCodOpe,cSenNrOp,.F.)
											lFindGui := .T.
										EndIf
										
									EndIf
									
									RestArea(aAreaBE4)
									
									aadd(aRecnosGer,{"BE4",BE4->(Recno())})
									DbSelectArea(cAliasPLS)
									aadd(aResumo,{PLSA500GCF("R502","NR_LOTE")+PLSA500GCF("R502","NR_NOTA"),"",cAliasPLS,Recno(),Iif(lFindGui,"Sim","Nao"),RetGuia(cAliasPLS),aLista[nArqu][01]})
									
									If PLSLOG500()
										PlsLogFil("-> Registro 502 Parte 5                  -> "+AllTrim(Str(Seconds()-nHorIni,10,3))+" Segundo(s)",__PLSFL500)
										nHorIni := Seconds()
									Endif
							Endif
						Endif
					Endif
					
				//R503 - HOSPITALAR
				ElseIf Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "503" .And. cTipGui == "05" .and. (! lAmbulat .or. cAliasPLS == "BE4")
					
					If lGuiaCriada
						
						If PLSLOG500()
							nHorIni := Seconds()
						Endif
						
						//Busca procedimentos ja autorizados
						aAreaBE4  := BE4->(GetArea())
						aEventos  := BusEveInt(cSenhaPLS,cChvNtPesq,cCodOpe,cSenNrOp)
						aAreaBE4  := restArea(aAreaBE4)
						
						AtuGIHR503()
						
						If PLSLOG500()
							PlsLogFil("-> Registro 503                          -> "+AllTrim(Str(Seconds()-nHorIni,10,3))+" Segundo(s)",__PLSFL500)
							nHorIni := Seconds()
						Endif
						
					Endif
					
					lOnApr503 := .T.
					nTot++
					
				//R504 - SERVICO
				ElseIf Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "504"
					
	    				aChaveAtu :=  { PLSA500GCF("R504","CD_SERVICO")+;
	    				                PLSA500GCF("R504","DT_SERVICO")+;
	    				                PLSA500GCF("R504","TP_PARTICI")+;
	    				                PLSA500GCF("R504","HR_INICIAL")+;
	    				                PLSA500GCF("R504","CD_VIA_ACE")+;
	    				                PLSA500GCF("R504","HR_FINAL"), AllTrim(Str(Trb->(Recno()))) }
	    				
	    				if aChaveAtu[1] == aChaveOld[1]
	    				    //Procedimento duplicado, informar erro e ir para o próximo registro    				    
	    				    lDuplicado := .T.
	    				    nLine := Trb->(Recno())
	    				    AnalisaCrit("79","Duplicidade nas linhas [" + AllTrim(Str(Trb->(Recno()))) + "] e [" + aChaveOld[2] + "]",Nil,Nil,Nil,Nil,aLista[nArqu][01])
	    				    nTot++
	    				else
	    				    aChaveOld := aClone(aChaveAtu)
	    				    lDuplicado := .F.
	    				endif
	    				
					//Atualizacao do BD6/BD7...
	    				If lGuiaCriada .and. !lDuplicado
						
						If PLSLOG500()
							nHorIni := Seconds()
						Endif
						
						//Agora a CriaEvento() eh chamada em uma ordem pre-estabelecida por mim,
						//isso porque a unimed pode apresentar um arquivo ptu com uma participacao
						//de cirurgiao lah na primeira linha e o anestesista la na ultima, e eu
						//tenho que criar um unico BD6
						
						If Len(aBD6Nota) > 0
							nMaxRecno := 0
							For nI := 1 to Len(aBD6Nota)
								//quando tiver o tipo X, o 0 sempre deve vir primeiro
								If aScan(aBD6Nota[nI][3],{|x| upper(x[1]) == 'X'}) > 0
									aBD6Nota[nI][3] := aClone(aSort(aBD6Nota[nI][3],,,{|x,y| x[1] < y[1] }))
								Endif
								
								nQtdCob := 0

								For nJ := 1 to Len(aBD6Nota[nI][3])
									
									If aBD6Nota[nI][3][nJ][2] > nMaxRecno
										nMaxRecno := aBD6Nota[nI][3][nJ][2]
									Endif
									
									Trb->(DbGoTo(aBD6Nota[nI][3][nJ][2]))
									nTot++
									If !lAutoma
										IncProcG2("[ " + AllTrim(Str(nTot)) + " ] De [ " + AllTrim(Str(nRSeqIni)) + " ] " + AllTrim(Str((nTot*100)/nRSeqIni,3)) + "% Concluido ")
									EndIf
									
									If nJ < Len(aBD6Nota[nI][3])
										nNextRec := aBD6Nota[nI][3][nJ+1][2]
									Else
										If nI < Len(aBD6Nota)
											nNextRec := aBD6Nota[nI+1][3][1][2]
										Else
											nNextRec := 0
										Endif
									Endif

									If l500S .AND. PLSA500GCF("R504","ID_PACOTE") == "S" .and. PLSA500GCF("R504","DT_AUTORIZ") >= "20201201
										Loop
									endIf

									// Pensando um cenário com 2 pacotes no arquivo, se preencheu o array, e não achou algum item da sua composição eu gravo aqui
									if l500S .and. len(aPacPTU01) > 0 .and. empty(PLSA500GCF("R504","ID_PACOTE"))
										PlGrvPac01(aPacPTU01, aItePac01)
										aItePac01 := {}
										aPacPTU01 := {}
									endIf

									CriaEvento(nNextRec,aBD6Nota[nI][3],nJ,,,aBD6Nota[nI][4],,aBD6Nota[nI][6],,nRecnoB5T)																		

									//Se internacao, analisa possives criticas
									If lMVPLVLALP
										
										lCriIntern := .F.
										
										If lPL500CFN
											cVarSer := ExecBlock("PL500CFN",.F.,.F.,{PLSA500GCF("R504","CD_SERVICO"),cUniOri,cDataPro,cChaveMat})
										Else
											cVarSer := PLSA500GCF("R504","CD_SERVICO")
										Endif
										
										If PLSA500GCF("R504","TP_TABELA") $ '0/4'
											nQtdCob += val(Substr(PLSA500GCF("R504","QT_COBRADA"),1,4))
										Else
											nQtdCob += Val(Substr(PLSA500GCF("R504","QT_COBRADA"),1,4)+"."+Substr(PLSA500GCF("R504","QT_COBRADA"),5,4))
										EndIf
										
										nPos := (Ascan(aEventos,{|x| alltrim(x[3]) == alltrim(cVarSer) } ) )
										
									EndIf
								Next nJ
							Next nI
							If l500S .and. len(aPacPTU01) > 0
								PlGrvPac01(aPacPTU01, aItePac01 )
							endIf
							aItePac01 := {}
							aPacPTU01 := {}
						//Atualiza o Cod da Especialidade no cabecalho correspondente
						Trb->(DbGoTo(nMaxRecno))
						Endif
						
						If PLSLOG500()
							PlsLogFil("-> Registro 504                          -> "+AllTrim(Str(Seconds()-nHorIni,10,3))+" Segundo(s)",__PLSFL500)
							nHorIni := Seconds()
						Endif
					Endif
					
					lOnApr503 := .F.
					
				//R505 - COMPLEMENTO
					
				ElseIf Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "505"
					
					cDesGui:= PLSA500GCF("R505","NM_DESC_CP")
					cTipDes:= PLSA500GCF("R505","TP_REG_CPL")
					
					If lNovInd
						
						AADD(aTrtMsg,{cAliasPLS,Alltrim(BD5->BD5_INDCLI) + PLSA500GCF("R505","NM_DESC_CP"),xFilial(cAliasPLS)+&(cAliasPLS+"->"+cAliasPLS+"_CODOPE")+&(cAliasPLS+"->"+cAliasPLS+"_CODLDP")+	&(cAliasPLS+"->"+cAliasPLS+"_CODPEG")+&(cAliasPLS+"->"+cAliasPLS+"_NUMERO"),cTipDes,"1"})
						
						If Len(aTrtMsg)> 0 .And. !Empty(cDesGui) .And. !Empty(cTipDes)
							nLinMsg++
						EndIf
						
					Else
						
						If cAliasPLS == "BD5"
							BD5->(Reclock("BD5",.F.))
							BD5->BD5_INDCLI := Alltrim(BD5->BD5_INDCLI) + PLSA500GCF("R505","NM_DESC_CP")
							BD5->(MsUnlock())
						ElseIf cAliasPLS == "BE4"
							BE4->(Reclock("BE4",.F.))
							BE4->BE4_INDCLI := Alltrim(BE4->BE4_INDCLI) + PLSA500GCF("R505","NM_DESC_CP")
							BE4->(MsUnlock())
						EndIf
						
					EndIf
					
					nTot++
					
				//R509 - TRAILER
				ElseIf Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "509"
					nTot++
				Endif
				
				If Interrupcao(lAbortPrint)
					lImpPTU := .F.
					Exit
				Endif
				
			Trb->(DbSkip())
			Enddo
			
		Else
			
			If lImportar
				aadd(aResCri,{aLista[nArqu][01],"00","O arquivo nao foi importado devido a criticas fatais."})
			Endif
			
			lFatal := .T.
			
		Endif
		
		//Fecha o arquivo de trabalho...
		Trb->(DbGoBottom())
		if( select( "Trb" ) > 0 )
			oTempTable:Delete()
		endIf
		
	Endif
	
	If nLinMsg > 0
		
		MSGCOMINT(aTrtMsg,"1")
		
	EndIf
	
	//Atualiza dados da numero sequencial de guias que nao atualizadas...
	For nFor := 1 To Len(aRegAtuMov)
		
		lMudSituac := .F.
		
		If aRegAtuMov[nFor,2] == "BD5"
			
			BD5->(DbGoTo(aRegAtuMov[nFor,1]))
			
			aAreaBEA := BEA->(GetArea())
			
			BEA->(DbSetOrder(14))//BEA_FILIAL+BEA_SENHA
			If BEA->(MsSeek(xFilial("BEA")+cSenhaPLS)) .And. BEA->BEA_COMUNI == "1"
				lMudSituac := .T.
			EndIf
			
			RestArea(aAreaBEA)
			
			BD5->(Reclock("BD5",.F.))
			
			BD5->BD5_SEQIMP := cCodSeq
			BD5->BD5_FASE   := "1"
			
			BD5->(MsUnlock())
			
			AtuSEQEv(BD5->BD5_CODOPE,BD5->BD5_CODLDP,BD5->BD5_CODPEG,BD5->BD5_NUMERO,BD5->BD5_ORIMOV,cCodSeq,"BD5","",lMudSituac)
			
		Else
			
			BE4->(DbGoTo(aRegAtuMov[nFor,1]))
			
			BE4->(Reclock("BE4",.F.))
			
			BE4->BE4_SEQIMP := cCodSeq
			BE4->BE4_FASE   := "1"
			
			BE4->(MsUnlock())
			
			AtuSEQEv(BE4->BE4_CODOPE,BE4->BE4_CODLDP,BE4->BE4_CODPEG,BE4->BE4_NUMERO,BE4->BE4_ORIMOV,cCodSeq,"BE4","")
		Endif
	Next
	
	//Exclui Subitens que nao tiveram participacao...
	
	For nFor := 1 To Len(aRecnosGer)
		If !lAutoma
			IncProcG2("Atualizacoes finais [ " + AllTrim(Str(nFor)) + " ] De [ " + AllTrim(Str(Len(aRecnosGer))) + " ] ")
		EndIf
		
		cAliasPLS := aRecnosGer[nFor,1]
		
		DbSelectArea(cAliasPLS)
		nRecno := aRecnosGer[nFor,2]
		
		DbGoto(nRecno)
		
		BD7->(DbSetOrder(1))//BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC
		
		cChaveGui := xFilial(cAliasPLS)+&(cAliasPLS+"->"+cAliasPLS+"_CODOPE")+&(cAliasPLS+"->"+cAliasPLS+"_CODLDP")+&(cAliasPLS+"->"+cAliasPLS+"_CODPEG")+&(cAliasPLS+"->"+cAliasPLS+"_NUMERO")+&(cAliasPLS+"->"+cAliasPLS+"_ORIMOV")
		
		cSQL := "SELECT SUM(BD6_QTDPRO) QTDPRO FROM "+RetSqlName("BD6")+" WHERE "
		cSQL += "BD6_FILIAL = '"+xFilial(cAliasPLS)+"' AND "
		cSQL += "BD6_CODOPE = '"+&(cAliasPLS+"->"+cAliasPLS+"_CODOPE")+"' AND "
		cSQL += "BD6_CODLDP = '"+&(cAliasPLS+"->"+cAliasPLS+"_CODLDP")+"' AND "
		cSQL += "BD6_CODPEG = '"+&(cAliasPLS+"->"+cAliasPLS+"_CODPEG")+"' AND "
		cSQL += "BD6_NUMERO = '"+&(cAliasPLS+"->"+cAliasPLS+"_NUMERO")+"' AND "
		cSQL += "BD6_ORIMOV = '"+&(cAliasPLS+"->"+cAliasPLS+"_ORIMOV")+"' AND "
		cSQL += "D_E_L_E_T_ <> '*' "
		PLSQuery(cSQL,"Trb")
		
		If ! Trb->(Eof())
			&(cAliasPLS+"->(Reclock('"+cAliasPLS+"',.F.))")
			&(cAliasPLS+"->"+cAliasPLS+"_QTDEVE") := TRB->QTDPRO
			&(cAliasPLS+"->(MsUnlock())")
		Endif
		Trb->(DbCloseArea())
		
	Next
	
	If lPLS500AF
		ExecBlock("PLS500AF",.F.,.F.,{aResumo})
	Endif
	
	If lPL500AC
		aResumo := Execblock("PL500AC",.F.,.F.,{lImportar,lFatal,cCodSeq,nTotAPRImp,_VL_TOT_FAT,aResumo})
	Endif
	
	If lPL500MF	//	P.E. para atuali
		aRecnosGer := aClone(ExecBlock("PL500MF",.F.,.F.,{aRecnosGer}))
	Endif
	
	//Processa / muda a fase de todas as guias importadas e ou ajustadas...
	If lMudarFase
		If !lAutoma
			BarGauge2Set(Len(aRecnosGer))
		EndIf
		
		For nFor := 1 To Len(aRecnosGer)
			If !lAutoma
				IncProcG2("Checando regras [ " + AllTrim(Str(nFor)) + " ] De [ " + AllTrim(Str(Len(aRecnosGer))) + " ] ")
			EndIf
			
			cAliasPLS := aRecnosGer[nFor,1]
			DbSelectArea(cAliasPLS)
			nRecno := aRecnosGer[nFor,2]
			DbGoto(nRecno)
			
			BCL->(DbSetOrder(1))
			BCL->(MsSeek(xFilial("BCL")+PLSINTPAD()+&(cAliasPLS+"->"+cAliasPLS+"_TIPGUI")))
			
			BCI->(DbSetOrder(1))
			BCI->(MsSeek(xFilial("BCI")+&(cAliasPLS+"->"+cAliasPLS+"_CODOPE")+&(cAliasPLS+"->"+cAliasPLS+"_CODLDP")+&(cAliasPLS+"->"+cAliasPLS+"_CODPEG")))
			
			aRecVlrApr:={}
			
			If cAliasPLS == "BD5"
				BD6->(DbSetOrder(1))
				If BD6->(DbSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)))
					While !eof() .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)=BD5->(BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)
						
						AADD(aRecVlrApr,{BD6->BD6_VALORI,BD6->(Recno())})
						
						BD6->(DbSkip())
					Enddo
				Endif
			Else
				
				If BD6->(DbSeek(xFilial("BD6")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)))
					While !eof() .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)=BE4->(BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)
						
						AADD(aRecVlrApr,{BD6->BD6_VALORI,BD6->(Recno())})
						
						BD6->(DbSkip())
					Enddo
				Endif
			Endif
			
			PLSA500FAS(cAliasPLS,nRecno,0,Nil,.F.,.T.)
			
			DbSelectArea(cAliasPLS)
			DbGoto(nRecno)
			
			nPos := Ascan(aResumo,{|x| x[3] == cAliasPLS .And. x[4] == nRecno})
			If nPos > 0
				aResumo[nPos,2] := If((&(cAliasPLS+"->"+cAliasPLS+"_FASE"))=="3","Pronta",If((&(cAliasPLS+"->"+cAliasPLS+"_FASE"))=="1","Em Digitacao","Em conferencia"))
			Endif
			
		Next
		
	Else
		If !lAutoma
			BarGauge2Set(Len(aRecnosGer))
		EndIf
		
		For nFor := 1 To Len(aRecnosGer)
			If !lAutoma
				IncProcG2("Atualizando status das guias [ " + AllTrim(Str(nFor)) + " ] De [ " + AllTrim(Str(Len(aRecnosGer))) + " ] ")
			EndIf
			
			cAliasPLS := aRecnosGer[nFor,1]
			
			DbSelectArea(cAliasPLS)
			nRecno := aRecnosGer[nFor,2]
			DbGoto(nRecno)
			
			nPos := Ascan(aResumo,{|x| x[3] == cAliasPLS .And. x[4] == nRecno})
			If nPos > 0
				aResumo[nPos,2] := "Em digitacao"
			Endif
			
		Next
	Endif
	
	If lPL500FIM
		ExecBlock("PL500FIM",.F.,.F.,{cCodSeq})
	Endif
Next nArqu

Else
    MsgAlert("Importação cancelada.")
EndIf //EndIf Validação Mes/Ano (if lVldMesAno)

If Valtype(oBrwBRJ) == "O"
	oBrwBRJ:Refresh(.T.)
	oBrwBRJ:ExecuteFilter()
Else
	DbSelectArea("BRJ")
	cPLSFiltro := "@BRJ_FILIAL = '"+xFilial("BRJ")+"' AND BRJ_REGPRI = '1' AND D_E_L_E_T_ = ' '"
	SET FILTER TO &cPLSFiltro
Endif
BRJ->(MsSeek(xFilial("BRJ")+BRJ_CODIGO))//nao tirar isso daqui
	
Return(Eval(bRet))

/*/{Protheus.doc} PLSA500GCF
Retorna um determinado dado a partir do layout/arq. de trab.
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Static Function PLSA500GCF(cTipReg,cDado,cSeq)
LOCAL nPos
LOCAL cRet   := ""
DEFAULT cSeq := ""

nPos := Ascan( a500Pos , {  | x | x[1] == cTipReg .And. (x[2] == cDado .or. alltrim(x[6]) == alltrim(cSeq)) } )
If nPos > 0
	cRet := Subs(Trb->Campo,a500Pos[nPos,3],(a500Pos[nPos,4]-a500Pos[nPos,3])+1)
	
	If ExistBlock("P500GCF")
		cRet := ExecBlock("P500GCF",.F.,.F.,{cTipReg,cDado,cSeq,cRet})
	EndIf
	
Else
	AnalisaCrit("43","Campo "+cDado+" Tipo de Registro "+cTipReg)
Endif
	
Return(cRet)



/*/{Protheus.doc} P500GeraBd7
Função para gravação do BD7 para os caso em que mv_par17=1 grava como esta no arquivo
@author Microsiga
@since 18/05/2016
@version P12
/*/

Static Function P500GeraBd7(cCodTab,cCodPad,cCodPro,cCodInt,dDatPro,cOriMov,cCodUnmBd7,nVlrTApr,nVlrTXpap,cTpPart,aRegBd7Im,aBD7Ger,lAllBlq)
Local aCompo		:={}
Local nInd			:= 0
Local i				:= 0
Local cAliasAx  	:= "BP1"
Local nRef			:= 1
Local lCorpoCli 	:= IF(Empty(BD6->BD6_REGEXE),.F.,.T.)
Local nForUnd		:= 0
Local lPagarItem	:= .T.
Local cLocal 	 	:= If (Len(BD6->(BD6_CODLOC+BD6_LOCAL)) = 6 ,Subs(BD6->(BD6_CODLOC+BD6_LOCAL),4,3),"")
Local nVlrAux		:= 0
LocaL aAreaBR8   	:= BR8->(GetArea())
Local aUnidsProp 	:= {}
Local j				:= 0
Local cJaFoi 		:= ''
Local cSql 			:= ''
Local aTpParBkc		:= {}
Local lUnl			:= .F.
Local lProGen		:= .F.
Local lGrvPrf	:= .F.
Local cMVPLSCAUX := GetNewPar("MV_PLSCAUX","AUX")

DEFAULT aBD7Ger     := {}
Default lAllBlq		:= .F.

//Busca participacoes para atraves do  cTpPart
cSql := " SELECT BKC_CODIGO FROM "+RetSqlName("BD3")+" BD3,"+RetSqlName("BKC")+" BKC WHERE "
cSql += " BKC_FILIAL = BD3_FILIAL AND "
cSql += " BKC_CODIGO = BD3_CODIGO AND "
cSql += " BKC_CODPAR = '"+alltrim(cTpPart)+"' AND "
cSql += " BKC.D_E_L_E_T_ = ' ' AND "
cSql += " BD3.D_E_L_E_T_ = ' ' "
cSql += " ORDER BY BD3_ORDEM "
PLSQuery(cSQL,"Trb11")

Trb11->(dbGoTop())
While ! Trb11->(Eof())
	AAdd(aTpParBkc,Trb11->BKC_CODIGO)
	Trb11->(Dbskip())
Enddo
Trb11->(DbCloseArea())

aCompo := PLSCOMEVE(cCodTab,cCodPad,cCodPro,cCodInt,dDatPro)

BB0->(DbSetOrder(4))//BB0_FILIAL + BB0_ESTADO + BB0_NUMCR + BB0_CODSIG + BB0_CODOPE...
If !Empty(PLSA500GCF("R504","SG_CONS_PR")) .And. !Empty(PLSA500GCF("R504","NR_CONS_PR")) .And. !Empty(PLSA500GCF("R504","SG_UF_CONS"))
	If BB0->(DbSeek(xFilial("BB0")+PLSA500GCF("R504","SG_UF_CONS")+;
			Alltrim(PLSA500GCF("R504","NR_CONS_PR")) + Space(TamSX3("BB0_NUMCR")[1] - len( Alltrim(PLSA500GCF("R504","NR_CONS_PR")) ))+;
			Alltrim(PLSA500GCF("R504","SG_CONS_PR")) + Space(TamSX3("BB0_CODSIG")[1] - len( Alltrim(PLSA500GCF("R504","SG_CONS_PR")) )) ))
		lFindBB0 := .T.
	Else
		PlSveProfAll(Alltrim(PLSA500GCF("R504","NM_PROF_PR")), Alltrim(PLSA500GCF("R504","SG_CONS_PR")), PLSA500GCF("R504","SG_UF_CONS"),;
					 Alltrim(PLSA500GCF("R504","NR_CONS_PR")), cUniDes, PLSA500GCF("R504","NR_CNJP_CP"), '2', cUniOri, {},.t.)			
	Endif
	lGrvPrf := .T.
EndIf

If lAllBlq
	PLS720IBD7('',BD6->BD6_VLPGMA,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODTAB,BD6->BD6_CODOPE,BD6->BD6_CODRDA,;
				BD6->BD6_REGEXE,BD6->BD6_SIGEXE,BD6->BD6_ESTEXE,BD6->BD6_CDPFRE,BD6->BD6_CODESP,BD6->(BD6_CODLOC+BD6_LOCAL),"1",BD6->BD6_SEQUEN,;
				BD6->BD6_ORIMOV,BD6->BD6_TIPGUI,BD6->BD6_DATPRO)
	
	PLSPOSGLO(BD6->BD6_CODOPE,"599","Item Avisado (PTU A520), mas não cobrado no PTU A500","3")
	BD6->(RecLock("BD6", .F.))
		BD6->BD6_BLOPAG := "1"
		BD6->BD6_MOTBPG := "599"
		BD6->BD6_DESBPG := "Item Avisado (PTU A520), mas não cobrado no PTU A500"
	BD6->(MsUnLock())
endIf

For i := 1 to Len(aRegBd7Im)
	lUnl := .F.
	For j:=1 to len(aTpParBkc)
		If aScan(aCompo,{|x| Alltrim(x[1]) == Alltrim(aTpParBkc[j]) .And. !( aTpParBkc[j] $ cJaFoi)}) > 0 .And. AllTrim(aRegBd7Im[i,1]) $ AllTrim(aTpParBkc[j])
			aRegBd7Im[i,4] := aTpParBkc[j]
			cJaFoi += aTpParBkc[j]+"|"
			exit
		EndIf
	Next j
	
	If Alltrim(aRegBd7Im[i,4]) $ cMVPLSCAUX
		nInd	:= Ascan(aCompo,{|x| AllTrim(x[1]) == Alltrim(aRegBd7Im[i][4]) .And. cValtoChar(x[3]) == aRegBd7Im[i][6] })
	Else
		nInd	:= Ascan(aCompo,{|x| AllTrim(x[1]) == Alltrim(aRegBd7Im[I][4])})
	EndIf
	
	//Caso não encontre a participação é feita a busca no procedimento generico alterando assim o array aCompo
	//Este trecho serve para retomar a composição do procedimento enviado no A500
	If nInd == 0 .And. lProGen
		aCompo := PLSCOMEVE(cCodTab,cCodPad,cCodPro,cCodInt,dDatPro,/*cTipoGuia*/,/*lRetCoC*/,/*lCobCoPart*/,/*cCodRDA*/,/*cCodEsp*/,/*cSubEsp*/,/*cCodLoc*/,/*cOrigem*/,/*aPartic*/,/*lAneste*/,/*aVetTab*/,.T.)
		
		//lRegPtu - no intercambio n posso deixar de gerar bd7 msmo com data de vigencia finalizada.
		If Len(aCompo) > 0
			nInd := Ascan(aCompo,{|x| AllTrim(x[1]) == Alltrim(aRegBd7Im[I][4])})
		EndIf
		lProGen := .F.
	EndIf
	If nInd = 0
		
		BR8->(DbSetOrder(3))
		If !Empty(MV_PAR10) .And. BR8->(MsSeek(xFilial("BR8")+Alltrim(MV_PAR10)))  // UTILIZANDO O PROCEDIMENTO GENERICO
			aCompo  := PLSCOMEVE(cCodTab,BR8->BR8_CODPAD,Alltrim(MV_PAR10),cCodInt,dDatPro)
			nInd	:= Ascan(aCompo,{|x| x[1] == aRegBd7Im[I][4]})
			lProGen := .T.
		Endif
	Endif
	
	lPagarItem := PLSPRRDAP(BD6->BD6_CODRDA,BD6->BD6_OPERDA,BD6->BD6_CODLOC,BD6->BD6_CODESP,BD6->BD6_CODPLA,BD6->BD6_CODPAD,BD6->BD6_CODPRO)
	
	
	BD7->(DbSetOrder(1))	
	lNovo := .T.
	BD7->(RecLock("BD7",.T.))
	BD7->BD7_FILIAL := xFilial("BD7")
	BD7->BD7_CODOPE := BD6->BD6_CODOPE
	BD7->BD7_CODLDP := BD6->BD6_CODLDP
	BD7->BD7_CODPEG := BD6->BD6_CODPEG
	BD7->BD7_NUMERO := BD6->BD6_NUMERO
	BD7->BD7_SEQUEN := BD6->BD6_SEQUEN
	
	If lGrvPrf
		BD7->BD7_REGPRE := BB0->BB0_NUMCR
		BD7->BD7_SIGLA  := BB0->BB0_CODSIG
		BD7->BD7_ESTPRE := BB0->BB0_UF
		BD7->BD7_NOMPRE := BB0->BB0_NOME
	endIf
	lGrvPrf := .F.
	
	if nInd == 0
		BD7->BD7_CODUNM := 'UNL'
		lUnl := .T.
	else
		BD7->BD7_CODUNM := aRegBd7Im[i,4]
		BD7->BD7_NLANC  := IF(alltrim(aCompo[nInd,1]) $ cMVPLSCAUX,StrZero(aCompo[nInd,3],2),"")
	endIf
	
	BD7->BD7_CODPRO := BD6->BD6_CODPRO
	BD7->BD7_CODPAD := BD6->BD6_CODPAD
	BD7->BD7_LIBERA := BD6->BD6_LIBERA
	BD7->BD7_CC     := BD6->BD6_CC	
	BD7->BD7_NUMIMP := BD6->BD6_NUMIMP
	BD7->BD7_ORIMOV := cOriMov
	BD7->BD7_FASE   := BD6->BD6_FASE
	BD7->BD7_SITUAC := BD6->BD6_SITUAC
	
	BD7->BD7_MODCOB := BD6->BD6_MODCOB
	BD7->BD7_TIPUSR := BD6->BD6_TIPUSR
	BD7->BD7_INTERC := BD6->BD6_INTERC
	BD7->BD7_TIPINT := BD6->BD6_TIPINT
	
	BD7->BD7_VALORI := aRegBd7Im[i,2]
	BD7->BD7_VLRAPR := BD7->BD7_VALORI / BD6->BD6_QTDPRO
	
	BD7->BD7_VTXPAP := aRegBd7Im[i,10]
	BD7->BD7_VLTXAP := aRegBd7Im[i,10]

	if BD7->(FieldPos("BD7_VLADSE")) > 0
		BD7->BD7_VLADSE := aRegBd7Im[i,10]
	endIf

	if BD7->(FieldPos("BD7_VLAPAJ")) > 0
		BD7->BD7_VLAPAJ := aRegBd7Im[i,9]
	endIf
	
	BD7->BD7_CODTPA := aRegBd7Im[i,6]
	
	If BD7->(FieldPos("BD7_LOTGUI")) > 0
		BD7->BD7_LOTGUI := BD6->BD6_LOTGUI
	EndIf
	
	If BD7->(FieldPos("BD7_CLAINS")) > 0 .And. BQC->(FieldPos("BQC_CLAINS")) > 0 .And. FindFunction("PLSCLAINS")
		BD7->BD7_CLAINS := PLSCLAINS() //Considera o BD6 posicionado!!!
	Endif
	
	If BD7->(FieldPos("BD7_NOMUSR")) > 0
		BD7->BD7_NOMUSR := BD6->BD6_NOMUSR
	Endif
	
	If BD7->(FieldPos("BD7_SEQIMP")) > 0 .And. BD6->(FieldPos("BD6_SEQIMP")) > 0
		BD7->BD7_SEQIMP := aCodSeqImp[Len(aCodSeqImp)]// Pega o ultimo código
	Endif
	
	If BD7->(FieldPos("BD7_SEQNFS")) > 0 .And. BD6->(FieldPos("BD6_SEQNFS")) > 0 .and. Empty(BD7->BD7_SEQNFS)
		BD7->BD7_SEQNFS := BD6->BD6_SEQNFS
	Endif
	
	If BD7->(FieldPos("BD7_PROBD7")) > 0
		
		If Empty(BD7->BD7_PROBD7)
			cProBD7Ori      := "0"
			BD7->BD7_PROBD7 := "1"
		Else
			cProBD7Ori := BD7->BD7_PROBD7
		Endif
		
	Endif
	
	If BD7->(FieldPos("BD7_TIPGUI")) > 0 //todos os campos abaixo foram criados de uma unica vez
		BD7->BD7_TIPGUI := BD6->BD6_TIPGUI
		BD7->BD7_CID    := BD6->BD6_CID
		BD7->BD7_OPEUSR := BD6->BD6_OPEUSR
		BD7->BD7_CODESP := BD6->BD6_CODESP
		BD7->BD7_DESESP := BAQ->(Posicione("BAQ",1,xFilial("BAQ")+BD6->(BD6_OPERDA+BD6_CODESP),"BAQ_DESCRI"))
		BD7->BD7_TIPREG := BD6->BD6_TIPREG
		BD7->BD7_MATRIC := BD6->BD6_MATRIC
		BD7->BD7_CODEMP := BD6->BD6_CODEMP
	Endif
	
	BD7->BD7_BLOPAG := "0"     // SEMPRE DESBLOQUEADO O PAGAMENTO
	
	If BD7->(FieldPos("BD7_UNITDE")) > 0 .And. BD7->(FieldPos("BD7_REFTDE")) > 0 .and. nInd > 0
		BD7->BD7_UNITDE := aCompo[nInd,7]
		BD7->BD7_REFTDE := aCompo[nInd,3]
	Endif
	
	If BD7->(FieldPos("BD7_CONMFT")) > 0
		BR8->(DbSetOrder(1))
		BR8->(MsSeek(xFilial("BR8")+BD7->(BD7_CODPAD+BD7_CODPRO)))
		
		BD7->BD7_CONMFT := BR8->BR8_CONMFT
	Endif
	
	If BD7->(FieldPos("BD7_PROCCI")) > 0
		BR8->(DbSetOrder(1))
		BR8->(MsSeek(xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO)))
		BD7->BD7_PROCCI := If(BR8->BR8_TIPEVE$"2,3","1","0")
	Endif
	
	If BD7->(FieldPos("BD7_CONEMP")) > 0
		BD7->BD7_CONEMP := BD6->BD6_CONEMP
	EndIf
	
	If BD7->(FieldPos("BD7_SUBCON")) > 0
		BD7->BD7_SUBCON := BD6->BD6_SUBCON
	EndIf
	
	If BD7->(FieldPos("BD7_VERSUB")) > 0
		BD7->BD7_VERSUB := BD6->BD6_VERSUB
	EndIf
	
	If BD7->(FieldPos("BD7_VERCON")) > 0
		BD7->BD7_VERCON := BD6->BD6_VERCON
	EndIf
	
	BD7->BD7_FASE   := BD6->BD6_FASE
	BD7->BD7_SITUAC := BD6->BD6_SITUAC
	BD7->BD7_TPGRV  := BD6->BD6_TPGRV
	BD7->BD7_CODPLA := BD6->BD6_CODPLA
	BD7->BD7_ANOPAG := BD6->BD6_ANOPAG
	BD7->BD7_MESPAG := BD6->BD6_MESPAG
	BD7->BD7_DATPRO := BD6->BD6_DATPRO
	BD7->BD7_DTDIGI := BD6->BD6_DTDIGI

	If BD7->(FieldPos("BD7_CONMFT")) > 0
		BR8->(DbSetOrder(1))
		BR8->(MsSeek(xFilial("BR8")+BD7->(BD7_CODPAD+BD7_CODPRO)))
		
		BD7->BD7_CONMFT := BR8->BR8_CONMFT
	Endif
	
	If lCorpoCli
		
		If Len(aCompo) > 0
			nPos := Ascan(aUnidsProp,{|x| AllTrim(x[1]) == AllTrim(aCompo[nInd,1])})
		Else
			nPos := 0
		EndIf
		
		If  nPos > 0 .And. aUnidsProp[nPos,2] == "1"
			
			If BAU->(BAU_FILIAL+BAU_CODIGO) <> xFilial("BAU")+BD6->BD6_CODRDA
				BAU->(DbSetOrder(1))
				BAU->(MsSeek(xFilial("BAU")+BD6->BD6_CODRDA))
			Endif
			
			BD7->BD7_CODRDA := BAU->BAU_CODIGO
			BD7->BD7_LOCATE := BD6->(BD6_CODLOC+BD6_LOCAL)+cLocal
			BD7->BD7_CODLOC := BD6->(BD6_CODLOC+BD6_LOCAL)
			BD7->BD7_LOCAL  := cLocal
			BD7->BD7_DATPRO := BD6->BD6_DATPRO
			BD7->BD7_DESLOC := BD1->(Posicione("BD1",1,xFilial("BD1")+cCodInt+BD6->(BD6_CODLOC+BD6_LOCAL),"BD1_DESLOC"))
			
		ElseIf nPos > 0 .And. aUnidsProp[nPos,2] == "0"
			
			If cTipoCorpo == "1" //Profissisonal de saude
				BAU->(DbSetOrder(5))
				BAU->(MsSeek(xFilial("BAU")+BD6->BD6_CDPFRE))
				
				BD7->BD7_CODRDA := BAU->BAU_CODIGO
				BD7->BD7_LOCATE := BD6->(BD6_CODLOC+BD6_LOCAL)+cLocal
				BD7->BD7_CODLOC := BD6->(BD6_CODLOC+BD6_LOCAL)
				BD7->BD7_LOCAL  := cLocal
				BD7->BD7_DATPRO := BD6->BD6_DATPRO
				BD7->BD7_DESLOC := BD1->(Posicione("BD1",1,xFilial("BD1")+cCodInt+BD6->(BD6_CODLOC+BD6_LOCAL),"BD1_DESLOC"))
				
			Else
				
				If BAU->(BAU_FILIAL+BAU_CODIGO) <> xFilial("BAU")+BD6->BD6_CODRDA
					BAU->(DbSetOrder(1))
					BAU->(MsSeek(xFilial("BAU")+BD6->BD6_CODRDA))
				Endif
				
				BD7->BD7_CODRDA := BAU->BAU_CODIGO
				BD7->BD7_LOCATE := BD6->(BD6_CODLOC+BD6_LOCAL)+cLocal
				BD7->BD7_CODLOC := BD6->(BD6_CODLOC+BD6_LOCAL)
				BD7->BD7_DATPRO := BD6->BD6_DATPRO
				BD7->BD7_LOCAL  := cLocal
				BD7->BD7_DESLOC := BD1->(Posicione("BD1",1,xFilial("BD1")+cCodInt+BD6->(BD6_CODLOC+BD6_LOCAL),"BD1_DESLOC"))
			Endif
			
		ElseIf nPos <= 0
			
			If BAU->(BAU_FILIAL+BAU_CODIGO) <> xFilial("BAU")+BD6->BD6_CODRDA
				BAU->(DbSetOrder(1))
				BAU->(MsSeek(xFilial("BAU")+BD6->BD6_CODRDA))
			Endif
			
			If BD7->(FieldPos("BD7_PROBD7")) == 0 .Or. cProBD7Ori <> "1"
				
				BD7->BD7_CODRDA := BAU->BAU_CODIGO
				BD7->BD7_LOCATE := BD6->(BD6_CODLOC+BD6_LOCAL)+cLocal
				BD7->BD7_CODLOC := BD6->(BD6_CODLOC+BD6_LOCAL)
				BD7->BD7_LOCAL  := cLocal
				BD7->BD7_DATPRO := BD6->BD6_DATPRO
				BD7->BD7_DESLOC := BD1->(Posicione("BD1",1,xFilial("BD1")+cCodInt+BD6->(BD6_CODLOC+BD6_LOCAL),"BD1_DESLOC"))
				
			Endif
			
		Endif
		
	Else
		If BAU->(BAU_FILIAL+BAU_CODIGO) <> xFilial("BAU")+BD6->BD6_CODRDA
			BAU->(DbSetOrder(1))
			BAU->(MsSeek(xFilial("BAU")+BD6->BD6_CODRDA))
		Endif
		
		If lNovo
			BD7->BD7_CODRDA := BAU->BAU_CODIGO
			BD7->BD7_LOCATE := BD6->(BD6_CODLOC+BD6_LOCAL)+cLocal
			BD7->BD7_CODLOC := BD6->(BD6_CODLOC+BD6_LOCAL)
			BD7->BD7_LOCAL  := cLocal
			BD7->BD7_DATPRO := BD6->BD6_DATPRO
			BD7->BD7_DESLOC := BD1->(Posicione("BD1",1,xFilial("BD1")+cCodInt+BD6->(BD6_CODLOC+BD6_LOCAL),"BD1_DESLOC"))
		Else
			BAU->(DbSetOrder(1))
			BAU->(MsSeek(xFilial("BAU")+BD7->BD7_CODRDA))
		Endif
	Endif
	
	If BD7->(FieldPos("BD7_PROBD7")) == 0 .Or. cProBD7Ori <> "1"
		BD7->BD7_NOMRDA := BAU->BAU_NOME
	Endif
	
	If lNovo
		If !Empty(BD6->BD6_CDPFRE) .and. empty(BD7->BD7_REGPRE)
			BD7->BD7_REGPRE := BD6->BD6_REGEXE
			BD7->BD7_SIGLA  := BD6->BD6_SIGEXE
			BD7->BD7_ESTPRE := BD6->BD6_ESTEXE
			BD7->BD7_NOMPRE := BR8->( Posicione("BB0",1,xFilial("BB0")+BD6->BD6_CDPFRE,"BB0_NOME") )
		EndIf
		BD7->BD7_CDPFPR := BD6->BD6_CDPFSO
	EndIf
	
	BD7->(MsUnLock())
	
	Aadd(aBD7Ger,{BD7->(Recno()) })
	
	aRetEspec := PLSGTESPP(BD7->BD7_CODRDA)
	
	If Empty(BD6->BD6_CODESP)
		cCodEsp := aRetEspec[1]
	Else
		cCodEsp := BD6->BD6_CODESP
	EndIf
	
	BD7->(RecLock("BD7",.F.))
	BD7->BD7_CODESP := cCodEsp
	BD7->BD7_DESESP := BAQ->(Posicione("BAQ",1,xFilial("BAQ")+cCodInt+cCodEsp,"BAQ_DESCRI"))
	
	If aRegBd7Im[i,4] $ "AUX"
		BP1->(DbSetOrder(1))
		If BP1->(MsSeek(xFilial("BP1")+cCodInt+cCodTab))
			While ! BP1->(Eof()) .And. BP1->(BP1_FILIAL+BP1_CODINT+BP1_CODTAB) == xFilial("BP1")+cCodInt+cCodTab
				
				If Val(aRegBd7Im[i,6]) == BP1->BP1_NUMAUX
					nVlrAux := BP1->BP1_PERCAX
					lOK     := .T.
					cAliasAx:= "BP1"
					Exit
				Endif
				BP1->(DbSkip())
			Enddo
		Endif
		BD7->BD7_COEFUT := nVlrAux
		BD7->BD7_CODUNC := aRegBd7Im[i,6]
		BD7->BD7_ALIAUS	:= cAliasAx
	Endif
	
	If BD7->(FieldPos("BD7_SEQ500")) > 0
		BD7->BD7_SEQ500 := aRegBd7Im[i,8]
	Endif
	
	BD7->(MsUnLock())
	
	If lUNL
		BD6->(Reclock("BD6",.F.))
			BD6->BD6_VALORI -= aRegBd7Im[i,2]
			BD6->BD6_VLRAPR := BD6->BD6_VALORI / BD6->BD6_QTDPRO 
		BD6->( MsUnLock() )
	EndIf
	
Next i

if lUNL .and. PLSPOSGLO(BD6->BD6_CODOPE,__aCdCri099[1],__aCdCri099[2],cLocalExec)
	
	BD6->(Reclock("BD6",.f.))
	BD6->BD6_ENVCON := "1"
	BD6->( MsUnLock() )
	
EndIf

//Caso a condição desse if dê .T., ele vai gerar um UNL pra não ficar BD6 sem BD7
If !lAllBlq .AND. empTy(aRegBd7Im)
	PCrB7Gen("UNL")
endIf

RestArea(aAreaBR8)
	
Return .T.

/*/{Protheus.doc} VerNotaINT
Busca a solicitacao original para preencher o cammpo excluida
@author Microsiga
@since 18/05/2016
@version P12
/*/

static Function VerNotaINT(cSenhaPLS,cNota,cCodOpe,cNota20,cSenNrOp)
Local aGuiOrig 	:= {"","","","",""}
Local lFind    	:= .F.

Default cNota20 	:= ''
Default cSenNrOp 	:= ""

//Faz a primeira pesquisa de nota com 20 caracteres (PTU 5.0)
If ! Empty(cNota20) .And. Val(cNota20) <> 0
	
	BE4->(DbSetOrder(6))//BE4_FILIAL+BE4_NUMIMP
	If BE4->(MsSeek(xFilial("BE4") + cNota20))
		
		While xFilial("BE4") + cNota20 == BE4->(BE4_FILIAL+BE4_NUMIMP) .And. !BE4->(Eof())
			
			If BE4->BE4_CODLDP <> PLSRETLDP(9) .AND. BE4->BE4_CODLDP <> PLSRETLDP(9)
				BE4->(DbSkip())
				Loop
			EndIf
			
			aGuiOrig[1] := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
			aGuiOrig[2] := BE4->BE4_TIPADM
			aGuiOrig[3] := BE4->BE4_TIPINT
			aGuiOrig[4] := BE4->BE4_PADINT
			aGuiOrig[5] := BE4->BE4_INDCLI
			lFind := .T.
			Exit
			
			BE4->(DbSkip())
		EndDo
		
	EndIf
	
EndIf

If ! lFind .And. ! Empty(cNota)

	BE4->(DbSetOrder(6))//BE4_FILIAL+BE4_NUMIMP
	
	If BE4->(MsSeek(xFilial("BE4") + cNota)) .AND. !(BE4->BE4_CODLDP <> PLSRETLDP(9) .AND. BE4->BE4_CODLDP <> PLSRETLDP(9))
					
		aGuiOrig[1] := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
		aGuiOrig[2] := BE4->BE4_TIPADM
		aGuiOrig[3] := BE4->BE4_TIPINT
		aGuiOrig[4] := BE4->BE4_PADINT
		aGuiOrig[5] := BE4->BE4_INDCLI
		lFind := .T.
		
	EndIf
	
EndIf

If ! Empty(cSenhaPLS) .and. val(cSenhaPLS) > 0 .and. ! lFind
	
	BE4->(DbSetOrder(7))//BE4_FILIAL+BE4_SENHA
	If BE4->(MsSeek(xFilial("BE4")+cSenhaPLS)) .and. (IIF(IsInCallStack("CriaGuiaHS"),.T.,BE4->BE4_SITUAC == "1" .And. Empty(BE4->BE4_SEQIMP))) .And. VerOpeSol("BE4",cCodOpe,cSenhaPLS,.F.) .AND. !(BE4->BE4_CODLDP <> PLSRETLDP(9) .AND. BE4->BE4_CODLDP <> PLSRETLDP(9))
	
		aGuiOrig[1] := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
		aGuiOrig[2] := BE4->BE4_TIPADM
		aGuiOrig[3] := BE4->BE4_TIPINT
		aGuiOrig[4] := BE4->BE4_PADINT
		aGuiOrig[5] := BE4->BE4_INDCLI
		
	EndIf
	
EndIf

If ! Empty(cSenNrOp) .and. val(cSenNrOp) > 0 .and. ! lFind
	
	BE4->(DbSetOrder(8))//BE4_FILIAL+BE4_NRAOPE
	If BE4->(MsSeek(xFilial("BE4")+cSenNrOp)) .and. (IIF(IsInCallStack("CriaGuiaHS"),.T.,BE4->BE4_SITUAC == "1" .And. Empty(BE4->BE4_SEQIMP))) .And. VerOpeSol("BE4",cCodOpe,cSenNrOp,.F.) .AND. !(BE4->BE4_CODLDP <> PLSRETLDP(9) .AND. BE4->BE4_CODLDP <> PLSRETLDP(9))
		
		aGuiOrig[1] := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
		aGuiOrig[2] := BE4->BE4_TIPADM
		aGuiOrig[3] := BE4->BE4_TIPINT
		aGuiOrig[4] := BE4->BE4_PADINT
		aGuiOrig[5] := BE4->BE4_INDCLI
		
	EndIf
	
EndIf
	
Return(aGuiOrig)

/*/{Protheus.doc} PL5GetCo
Retorna o intervalo de colunas
@author Daher
@since 17.01.2005
@version P12
/*/
Static Function PL5GetCo(cTipReg,cDado)
LOCAL nPos
LOCAL cRet := ""

nPos := Ascan( a500Pos , {  | x | x[1] == cTipReg .And. x[2] == cDado } )
If nPos > 0
	cRet := "Posicao no arquivo ["+alltrim(str(a500Pos[nPos,3])) + "] -> [" + alltrim(str(a500Pos[nPos,4]))+"] "
else
	cRet := "ERRO"
Endif
	
Return(cRet)

/*/{Protheus.doc} PLSA500GPF

@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Static Function PLSA500GPF(cTipReg,cDado,cNomArq)
LOCAL nPos
LOCAL nPosIni := 0
LOCAL nPosFin := 0

nPos := Ascan( a500Pos , {  | x | x[1] == cTipReg .And. x[2] == cDado } )
If nPos > 0
	nPosIni := a500Pos[nPos,3]
	nPosFin := (a500Pos[nPos,4]-a500Pos[nPos,3])+1
Else
	AnalisaCrit("44","Campo "+cDado+" Tipo de Registro "+cTipReg,Nil,Nil,Nil,Nil,cNomArq)
Endif
	
Return({nPosIni,nPosFin})

/*/{Protheus.doc} MonLayout
Monta matriz de apoio com todos os layouts do respectivo EDI
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Static Function MonLayout(cLayPLS)
	
a500Pos := {} //Limpa o array a500pos. O mesmo fica acumulando layout caso não saia da rotina.

DE1->(DbSetOrder(1))
If DE1->(MsSeek(xFilial("DE1")+cLayPLS))
	While ! DE1->(Eof()) .And. DE1->DE1_FILIAL == xFilial("DE1") .And. DE1->DE1_CODLAY == cLayPLS
		aadd(a500Pos,{AllTrim(DE1->DE1_CODREG),AllTrim(DE1->DE1_CAMPO),Val(DE1->DE1_POSINI),Val(DE1->DE1_POSFIM), Val(DE1->DE1_POSFIM)-Val(DE1->DE1_POSINI)+1,DE1->DE1_SEQUEN})
		DE1->(DbSkip())
	Enddo
Endif
	
Return
/*/{Protheus.doc} A500PQNOTA
Pesquisa uma nota no arquivo de contas medicas.
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Static Function A500PQNOTA(cNota,cSenhaPLS,cAliasPLS,cCodOpe,cMatric,cNota20,cLayPLS,cNomArq)
LOCAL lExiste := .F.
LOCAL aRetPto
LOCAL cNroImp := ""
LOCAL nRecno  := 0
LOCAL nRecBAU := 0
LOCAL nOrdBAU := 0
LOCAL cTpCarater := ""
LOCAL lCriSenha  := .F.
Local aArea	:= (cAliasPLS)->(GetArea())

//Ponto de entrada para regra especifica de localizacao de guia pre-autorizada...
If ExistBlock("PLS500PN")
	aRetPto := ExecBlock("PLS500PN",.F.,.F.,{lExiste,cAliasPLS,cNota,cSenhaPLS,cMatrCob,aDadRda,cUniOri,cCodSeq})
	lExiste := aRetPto[1]
	
	If lExiste .And. ;
			! PLSVERCCBG(&(cAliasPLS+"->"+cAliasPLS+"_OPEUSR")+&(cAliasPLS+"->"+cAliasPLS+"_CODEMP")+&(cAliasPLS+"->"+cAliasPLS+"_MATRIC")+;
			&(cAliasPLS+"->"+cAliasPLS+"_TIPREG"),&(cAliasPLS+"->"+cAliasPLS+"_ANOPAG"),&(cAliasPLS+"->"+cAliasPLS+"_MESPAG"),;
			&(cAliasPLS+"->"+cAliasPLS+"_SEQPF")) .And. ;
			&(cAliasPLS+"->"+cAliasPLS+"_FASE") <> "4" .and. Empty(&(cAliasPLS+"->"+cAliasPLS+"_SEQIMP"))
		
		If cAliasPLS == "BE4"
			
			If ! Empty(cCodSeq)
				
				BE4->(Reclock("BE4",.F.))
				
				BE4->BE4_SEQIMP := cCodSeq
				BE4->BE4_FASE   := "1"
				
				BE4->(MsUnlock())
				
				AtuSEQEv(BE4->BE4_CODOPE,BE4->BE4_CODLDP,BE4->BE4_CODPEG,BE4->BE4_NUMERO,BE4->BE4_ORIMOV,cCodSeq,"BE4","*")
			Else
				aadd(aRegAtuMov,{BE4->(Recno()),"BE4"})
			Endif
			
		Else
			If ! Empty(cCodSeq)
				BD5->(Reclock("BD5",.F.))
				
				BD5->BD5_SEQIMP := cCodSeq
				BD5->BD5_FASE   := "1"
				BD5->BD5_TIPATE := PLSP500ATE(PLSA500GCF("R502","TP_ATENDIM","018"), BD5->BD5_TIPGUI)   
				BD5->BD5_TIPSAI := PLSA500GCF("R502","TP_SAI_SAD","017")
				BD5->BD5_GUIPRI := PLSA500GCF("R502","NR_GUIA_PR","021")
				
				BD5->(MsUnlock())
				
				AtuSEQEv(BD5->BD5_CODOPE,BD5->BD5_CODLDP,BD5->BD5_CODPEG,BD5->BD5_NUMERO,BD5->BD5_ORIMOV,cCodSeq,"BD5","*")
			Else
				aadd(aRegAtuMov,{BD5->(Recno()),"BD5"})
			Endif
		Endif
	Else
		lExiste := .F.
	Endif
Endif

If ! lExiste
	
	//Primeiro procuro pelo numero da nota
	
	If ! Empty(cNota)
		
		//Posiciono na GIH
		
		If cAliasPLS == "BE4"
			BE4->(DbSetOrder(6))
			If BE4->(MsSeek(xFilial("BE4")+cNota))
				nRecBAU := BAU->(Recno())
				nOrdBAU := BAU->(IndexOrd())
				While !BE4->(Eof()) .and. rtrim(xFilial("BE4")+cNota) == rtrim(BE4->(BE4_FILIAL+BE4_NUMIMP)) .and. !lExiste
					If BE4->BE4_SITUAC == "1" .And. ;
							Posicione("BAU",1,xFilial("BE4")+BE4->BE4_CODRDA,"BAU_CODOPE") == cUniOri .And. ;
							! PLSVERCCBG(&(cAliasPLS+"->"+cAliasPLS+"_OPEUSR")+&(cAliasPLS+"->"+cAliasPLS+"_CODEMP")+&(cAliasPLS+"->"+cAliasPLS+"_MATRIC")+;
							&(cAliasPLS+"->"+cAliasPLS+"_TIPREG"),&(cAliasPLS+"->"+cAliasPLS+"_ANOPAG"),&(cAliasPLS+"->"+cAliasPLS+"_MESPAG"),;
							&(cAliasPLS+"->"+cAliasPLS+"_SEQPF")) .And. ;
							&(cAliasPLS+"->"+cAliasPLS+"_FASE") <> "4" .and. Empty(BE4->BE4_SEQIMP)
						
						If ! Empty(cCodSeq)
							
							BE4->(Reclock("BE4",.F.))
							
							BE4->BE4_SEQIMP := cCodSeq
							BE4->BE4_FASE   := "1"
							
							BE4->(MsUnlock())
							
							AtuSEQEv(BE4->BE4_CODOPE,BE4->BE4_CODLDP,BE4->BE4_CODPEG,BE4->BE4_NUMERO,BE4->BE4_ORIMOV,cCodSeq,"BE4","*")
						Else
							aadd(aRegAtuMov,{BE4->(Recno()),"BE4"})
						Endif
						lExiste := .T.
					Endif
					//mantenho o BE4 localizado posicionado
					If !lExiste
						BE4->(DbSkip())
					Endif
				Enddo
				BAU->(DbGoTo(nRecBAU))
				BAU->(DbSetOrder(nOrdBAU))
			Endif
		Endif
		
		If ! lExiste
			
			//Posiciono no cabecalho de servicos
			
			If cAliasPLS == "BD5"
				BD5->(DbSetOrder(6))
				If BD5->(MsSeek(xFilial("BD5")+cNota))
					nRecBAU := BAU->(Recno())
					nOrdBAU := BAU->(IndexOrd())
					While !BD5->(Eof()) .and. rtrim(xFilial("BD5")+cNota) == rtrim(BD5->(BD5_FILIAL+BD5_NUMIMP)) .and. !lExiste
						If BD5->BD5_SITUAC == "1" .And. ;
								Posicione("BAU",1,xFilial("BD5")+BD5->BD5_CODRDA,"BAU_CODOPE") == cUniOri .And. ;
								! PLSVERCCBG(&(cAliasPLS+"->"+cAliasPLS+"_OPEUSR")+&(cAliasPLS+"->"+cAliasPLS+"_CODEMP")+&(cAliasPLS+"->"+cAliasPLS+"_MATRIC")+;
								&(cAliasPLS+"->"+cAliasPLS+"_TIPREG"),&(cAliasPLS+"->"+cAliasPLS+"_ANOPAG"),&(cAliasPLS+"->"+cAliasPLS+"_MESPAG"),;
								&(cAliasPLS+"->"+cAliasPLS+"_SEQPF")) .And. ;
								&(cAliasPLS+"->"+cAliasPLS+"_FASE") <> "4" .and. Empty(BD5->BD5_SEQIMP)
							If ! Empty(cCodSeq)
								
								BD5->(Reclock("BD5",.F.))
								
								BD5->BD5_SEQIMP := cCodSeq
								BD5->BD5_FASE   := "1"
								
								BD5->BD5_TIPATE := PLSP500ATE(PLSA500GCF("R502","TP_ATENDIM","018"), BD5->BD5_TIPGUI)   
								BD5->BD5_TIPSAI := PLSA500GCF("R502","TP_SAI_SAD","017")
								BD5->BD5_GUIPRI := PLSA500GCF("R502","NR_GUIA_PR","021")
								
								BD5->(MsUnlock())
								
								AtuSEQEv(BD5->BD5_CODOPE,BD5->BD5_CODLDP,BD5->BD5_CODPEG,BD5->BD5_NUMERO,BD5->BD5_ORIMOV,cCodSeq,"BD5","*")
							Else
								aadd(aRegAtuMov,{BD5->(Recno()),"BD5"})
							Endif
							lExiste := .T.
						Endif
						//mantenho o Bd5 localizado posicionado
						If !lExiste
							BD5->(DbSkip())
						Endif
					Enddo
					BAU->(DbGoTo(nRecBAU))
					BAU->(DbSetOrder(nOrdBAU))
				Endif
			Endif
		Endif
	Endif
Endif

If !lExiste
	
	//Primeiro procuro pelo numero da nota	com 20 caracteres (PTU 5.0)
	
	If ! Empty(cNota20)
		
		//Posiciono na GIH
		
		If cAliasPLS == "BE4"
			BE4->(DbSetOrder(6))
			If BE4->(MsSeek(xFilial("BE4")+cNota20))
				nRecBAU := BAU->(Recno())
				nOrdBAU := BAU->(IndexOrd())
				While !BE4->(Eof()) .and. rtrim(xFilial("BE4")+cNota20) == rtrim(BE4->(BE4_FILIAL+BE4_NUMIMP)) .and. !lExiste
					If BE4->BE4_SITUAC == "1" .And. ;
							Posicione("BAU",1,xFilial("BE4")+BE4->BE4_CODRDA,"BAU_CODOPE") == cUniOri .And. ;
							! PLSVERCCBG(&(cAliasPLS+"->"+cAliasPLS+"_OPEUSR")+&(cAliasPLS+"->"+cAliasPLS+"_CODEMP")+&(cAliasPLS+"->"+cAliasPLS+"_MATRIC")+;
							&(cAliasPLS+"->"+cAliasPLS+"_TIPREG"),&(cAliasPLS+"->"+cAliasPLS+"_ANOPAG"),&(cAliasPLS+"->"+cAliasPLS+"_MESPAG"),;
							&(cAliasPLS+"->"+cAliasPLS+"_SEQPF")) .And. ;
							&(cAliasPLS+"->"+cAliasPLS+"_FASE") <> "4" .and. Empty(BE4->BE4_SEQIMP)
						
						If ! Empty(cCodSeq)
							
							BE4->(Reclock("BE4",.F.))
							
							BE4->BE4_SEQIMP := cCodSeq
							BE4->BE4_FASE   := "1"
							
							BE4->(MsUnlock())
							
							AtuSEQEv(BE4->BE4_CODOPE,BE4->BE4_CODLDP,BE4->BE4_CODPEG,BE4->BE4_NUMERO,BE4->BE4_ORIMOV,cCodSeq,"BE4","*")
						Else
							aadd(aRegAtuMov,{BE4->(Recno()),"BE4"})
						Endif
						lExiste := .T.
					Endif
					//mantenho o BE4 localizado posicionado
					If !lExiste
						BE4->(DbSkip())
					Endif
				Enddo
				BAU->(DbGoTo(nRecBAU))
				BAU->(DbSetOrder(nOrdBAU))
			Endif
		Endif
		
		If ! lExiste
			
			//Posiciono no cabecalho de servicos
			If cAliasPLS == "BD5"
				BD5->(DbSetOrder(6))
				If BD5->(MsSeek(xFilial("BD5")+cNota20))
					nRecBAU := BAU->(Recno())
					nOrdBAU := BAU->(IndexOrd())
					While !BD5->(Eof()) .and. rtrim(xFilial("BD5")+cNota20) == rtrim(BD5->(BD5_FILIAL+BD5_NUMIMP)) .and. !lExiste
						If BD5->BD5_SITUAC == "1" .And. ;
								Posicione("BAU",1,xFilial("BD5")+BD5->BD5_CODRDA,"BAU_CODOPE") == cUniOri .And. ;
								! PLSVERCCBG(&(cAliasPLS+"->"+cAliasPLS+"_OPEUSR")+&(cAliasPLS+"->"+cAliasPLS+"_CODEMP")+&(cAliasPLS+"->"+cAliasPLS+"_MATRIC")+;
								&(cAliasPLS+"->"+cAliasPLS+"_TIPREG"),&(cAliasPLS+"->"+cAliasPLS+"_ANOPAG"),&(cAliasPLS+"->"+cAliasPLS+"_MESPAG"),;
								&(cAliasPLS+"->"+cAliasPLS+"_SEQPF")) .And. ;
								&(cAliasPLS+"->"+cAliasPLS+"_FASE") <> "4" .and. Empty(BD5->BD5_SEQIMP)
							
							If ! Empty(cCodSeq)
								
								BD5->(Reclock("BD5",.F.))
								
								BD5->BD5_SEQIMP := cCodSeq
								BD5->BD5_FASE   := "1"
								
								BD5->BD5_TIPATE := PLSP500ATE(PLSA500GCF("R502","TP_ATENDIM","018"), BD5->BD5_TIPGUI)   
								BD5->BD5_TIPSAI := PLSA500GCF("R502","TP_SAI_SAD","017")
								BD5->BD5_GUIPRI := PLSA500GCF("R502","NR_GUIA_PR","021")
								
								BD5->(MsUnlock())
								
								AtuSEQEv(BD5->BD5_CODOPE,BD5->BD5_CODLDP,BD5->BD5_CODPEG,BD5->BD5_NUMERO,BD5->BD5_ORIMOV,cCodSeq,"BD5","*")
							Else
								aadd(aRegAtuMov,{BD5->(Recno()),"BD5"})
							Endif
							lExiste := .T.
						Endif
						//mantenho o Bd5 localizado posicionado
						If !lExiste
							BD5->(DbSkip())
						Endif
					Enddo
					BAU->(DbGoTo(nRecBAU))
					BAU->(DbSetOrder(nOrdBAU))
				Endif
			Endif
		Endif
	Endif
Endif

//Depois procuro pela senha por eles fornecida
If ! Empty(cSenhaPLS) .And. Val(cSenhaPLS) > 0 .and. ! lExiste
	
	//Posiciono no cabecalho de servicos
	
	If cAliasPLS == "BD5"
		BD5->(DbSetOrder(7))
		If BD5->(MsSeek(xFilial("BD5")+cSenhaPLS))
			while (!BD5->(EOF()) .and. allTrim(BD5->BD5_SENHA) == allTrim(cSenhaPLS))
				if Empty(BD5->BD5_SEQIMP) .And. !(lCriSenha := !VerOpeSol("BD5",cCodOpe,cSenhaPLS)) .And. ;
					! PLSVERCCBG(&(cAliasPLS+"->"+cAliasPLS+"_OPEUSR")+&(cAliasPLS+"->"+cAliasPLS+"_CODEMP")+&(cAliasPLS+"->"+cAliasPLS+"_MATRIC")+;
					&(cAliasPLS+"->"+cAliasPLS+"_TIPREG"),&(cAliasPLS+"->"+cAliasPLS+"_ANOPAG"),&(cAliasPLS+"->"+cAliasPLS+"_MESPAG"),;
					&(cAliasPLS+"->"+cAliasPLS+"_SEQPF")) .And. ;
					&(cAliasPLS+"->"+cAliasPLS+"_FASE") <> "4" .And. VerIteSol("BD5")
				
					aAreaBEA := BEA->(GetArea())
					BEA->(DbSetOrder(14))//BEA_FILIAL+BEA_SENHA
					If (BEA->(MsSeek(xFilial("BEA")+cSenhaPLS)))
						
						if len(aDadUsr) == 0 .or. aDadUsr[2] <> BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO)
							
							aRetFun := PLSDADUSR(BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO),"1",.F.,dDataBase,,,,,,.F.)
							if aRetFun[1]
								aDadUsr := PLSGETUSR()
							endIf
							
						endIf
						
						lMudSituac := .T.
						If ! Empty(cCodSeq)
							
							BD5->(Reclock("BD5",.F.))
							
							BD5->BD5_SEQIMP := cCodSeq
							BD5->BD5_FASE   := "1"
							BD5->BD5_SITUAC := "1"
							BD5->BD5_TIPATE := PLSP500ATE(PLSA500GCF("R502","TP_ATENDIM","018"), BD5->BD5_TIPGUI) 
							BD5->BD5_TIPSAI := PLSA500GCF("R502","TP_SAI_SAD","017")
							BD5->BD5_GUIPRI := PLSA500GCF("R502","NR_GUIA_PR","021")
							
							BD5->(MsUnlock())
							
							AtuSEQEv(BD5->BD5_CODOPE,BD5->BD5_CODLDP,BD5->BD5_CODPEG,BD5->BD5_NUMERO,BD5->BD5_ORIMOV,cCodSeq,"BD5","*",lMudSituac)
						Else
							aadd(aRegAtuMov,{BD5->(Recno()),"BD5"})
						Endif
					EndIf
					RestArea(aAreaBEA)
					lExiste := .T.
					exit
				EndIf
				BD5->(DbSkip())
			EndDo
		Endif
	Endif
	
	//Posiciono no cabecalho da GIH
	If cAliasPLS == "BE4"
		
		BE4->(DbSetOrder(7))
		If BE4->(MsSeek(xFilial("BE4")+cSenhaPLS)) 
			while (!BE4->(EOF()) .and. allTrim(BE4->BE4_SENHA) == allTrim(cSenhaPLS))
				if BE4->BE4_SITUAC == "1" .And. empty(BE4->BE4_SEQIMP) .And. !(lCriSenha := !VerOpeSol("BE4",cCodOpe,cSenhaPLS)) .And. ;
					! PLSVERCCBG(&(cAliasPLS+"->"+cAliasPLS+"_OPEUSR")+&(cAliasPLS+"->"+cAliasPLS+"_CODEMP")+&(cAliasPLS+"->"+cAliasPLS+"_MATRIC")+;
					&(cAliasPLS+"->"+cAliasPLS+"_TIPREG"),&(cAliasPLS+"->"+cAliasPLS+"_ANOPAG"),&(cAliasPLS+"->"+cAliasPLS+"_MESPAG"),;
					&(cAliasPLS+"->"+cAliasPLS+"_SEQPF")) .And. ;
					&(cAliasPLS+"->"+cAliasPLS+"_FASE") <> "4"  .And. VerIteSol("BE4")
			
					if len(aDadUsr) == 0 .or. aDadUsr[2] <> BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)
							
						aRetFun := PLSDADUSR(BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO),"1",.F.,dDataBase,,,,,,.F.)
						
						if aRetFun[1]
							aDadUsr := PLSGETUSR()
						endIf
						
					endIf
					
					If ! Empty(cCodSeq)
						
						BE4->(Reclock("BE4",.F.))
						
						BE4->BE4_SEQIMP := cCodSeq
						BE4->BE4_FASE   := "1"
						
						BE4->(MsUnlock())
						
						AtuSEQEv(BE4->BE4_CODOPE,BE4->BE4_CODLDP,BE4->BE4_CODPEG,BE4->BE4_NUMERO,BE4->BE4_ORIMOV,cCodSeq,"BE4","*")
					Else
						aadd(aRegAtuMov,{BE4->(Recno()),"BE4"})
					Endif
					lExiste := .T.
					exit
				EndIf
				BE4->(DbSkip())
			EndDo
		Endif
	Endif
Endif

//Se a guia existe confrontar dados da guia pre-autorizada com o que esta sendo cobrada

If lExiste .and. MV_PAR17 == 1      //Se o parametro for para Buscar pelo arquivo
	lDelBd7Rec := .T.               //Sera realizado a Limpeza da BD7 para que o sistema inclua as informações do arquivo
Endif
If lExiste
	If Empty(cNomArq)
		cNomArq := IIF(!Empty(cArquivo), Substr(cArquivo, RAT("\",cArquivo)+1, Len(cArquivo)), cNomArq)
	EndIf
	ConfNota(cAliasPLS,cMatric)
	If cAliasPLS == "BE4"
		nRecno := Trb->(Recno())
		cTpCarater := PLSA500GCF("R502","TP_CARATER","012")
		AtuGIHR502(cTpCarater,cLayPLS,cNomArq)
		Trb->(DbSkip()) //p passar o 502
		AtuGIHR503()
		Trb->(DbGoTo(nRecno))
	Endif
Endif

If nRegraGrvImp == 1
	cNroImp := Subs(PLSA500GCF("R502","NR_LOTE"),4,5)+PLSA500GCF("R502","NR_NOTA")
ElseIf nRegraGrvImp == 2
	cNroImp := PLSA500GCF("R502","NR_NOTA")
ElseIf nRegraGrvImp == 3
	cNroImp := cUniOri+PLSA500GCF("R502","NR_NOTA")
Endif

If ExistBlock("PLS500PQ")
	ExecBlock("PLS500PQ",.F.,.F.,{cAliasPLS,cNroImp,lExiste,PLSA500GCF("R502","NR_NOTA")})
Endif

If !lExiste
	RestArea(aArea)
EndIf
	
Return({lExiste,lCriSenha})

/*/{Protheus.doc} AnalisaPEG
Cria a PEG caso necessario...
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Static Function AnalisaPEG(cUniDes,cCodRDA,cAMPAG,cTipGui,cCodLDP,cArquivo,lNaoCriaPeg)
LOCAL lCrieiPEG 	:= .F.
LOCAL nHBRJ			:= 0
Local nPos			:= 0
LOCAL cTpPag        := ""
LOCAL cCodBRJ       := ""
LOCAL aAreaBA0      := {}
LOCAL dDatPeg			:= cTod("01/"+subs(cAMPAG,5,2)+"/"+subs(cAMPAG,1,4)) //Criando uma data referente para criação de PEG, mas somente será utilziada ano e mes 
DEFAULT lNaoCriaPeg := .F.

if !lCriadoBRJ
	cCodBRJ := GetSx8Num("BRJ","BRJ_CODIGO")
else
	cCodBRJ := BRJ->BRJ_CODIGO
endif

if (nK := aScan(xaPegs,{|x| alltrim(x[2]) == alltrim(cCodRDA) .and. alltrim(x[3]) == alltrim(cTipGui) .and. alltrim(x[4]) == alltrim(cArquivo) })) == 0
	
	If ! lNaoCriaPeg
		
		lCrieiPEG := .T.
		
		PLSIPP(cUniDes,cCodLDP,cUniDes,cCodRDA,subs(cAMPAG,5,2),subs(cAMPAG,1,4),dDataBase,cTipGui,"",{},"1",cArquivo,,,,,,dDatPeg,,,"BRJ|"+cCodBRJ)
		
		aadd(xaPegs,{BCI->(Recno()),cCodRDA,cTipGui,cArquivo})
		
	Endif
	
else
	BCI->(DbGoTo(xaPegs[nK][1]))
Endif

aAreaBA0 := BA0->(GetArea())
BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
If BA0->(FieldPos("BA0_TPPAG")) > 0 .And. BA0->(DbSeek(xFilial("BA0")+cUniOri))
	cTpPag := IIf(!Empty(BA0->BA0_TPPAG),BA0->BA0_TPPAG,CriaVar("BRJ_TPPAG"))
Else
	cTpPag := CriaVar("BRJ_TPPAG")
EndIf
RestArea(aAreaBA0)

if !lCriadoBRJ
	nHBRJ := PLSAbreSem("PLSBRJ.SMF")
	BRJ->(RecLock("BRJ",.T.))
	BRJ->BRJ_FILIAL := xFilial("BRJ")
	BRJ->BRJ_CODIGO := cCodBRJ
	BRJ->BRJ_DATA   := dDataBase
	BRJ->BRJ_REGPRI := "1"
	BRJ->BRJ_ARQUIV := cArquivo
	BRJ->BRJ_OPEORI := cUniOri
	BRJ->BRJ_NOMORI := BA0->(Posicione("BA0",1,xFilial("BA0")+cUniOri,"BA0_NOMINT"))
	BRJ->BRJ_ANO    := "20"+Subs(_NR_COMP,1,2)
	BRJ->BRJ_TPPAG  := cTpPag
	BRJ->BRJ_ANOPAG := Subs(cAMPAG,1,4)
	BRJ->BRJ_MESPAG := Subs(cAMPAG,5,2)
	BRJ->BRJ_MES 	:= Subs(_NR_COMP,3,2)
	BRJ->BRJ_NUMFAT := _NR_FATURA
	BRJ->BRJ_NRNDC  := _NR_NDC
	BRJ->BRJ_TPCOB  := cValToChar(nTpCob)		
	If nTpCob == 1
		BRJ->BRJ_VLRNDC := _VL_TOT_NDC
		BRJ->BRJ_VALOR  := _VL_TOT_NDC
	ElseIf nTpCob == 2
		BRJ->BRJ_VALOR  := _VL_TOT_FAT
		BRJ->BRJ_VLRFAT := _VL_TOT_FAT
	ElseIf nTpCob == 3
		BRJ->BRJ_VALOR  := _VL_TOT_FAT + _VL_TOT_NDC
		BRJ->BRJ_VLRNDC := _VL_TOT_NDC
		BRJ->BRJ_VLRFAT  := _VL_TOT_FAT
	Endif	
	BRJ->BRJ_DTEMIS := _DT_EMI_FAT
	BRJ->BRJ_DTVENC := _DT_VEM_FAT
	BRJ->BRJ_DTENDC := _DT_EMI_NDC
	BRJ->BRJ_DTVNDC := _DT_VEM_NDC
	BRJ->BRJ_STATUS := "1"
	BRJ->BRJ_CAMCOM := PLSRTCCOMP(BRJ->BRJ_OPEORI)
	If BRJ->(FieldPos("BRJ_TPDOC1")) > 0 .And. BRJ->(FieldPos("BRJ_TPDOC2")) > 0
		BRJ->BRJ_TPDOC1 := cTipDoc1
		BRJ->BRJ_TPDOC2 := cTipDoc2
	EndIf
	If BRJ->(FieldPos("BRJ_DOCFI1")) > 0 .And. BRJ->(FieldPos("BRJ_DOCFI2")) > 0
		BRJ->BRJ_DOCFI1 := cDocFis1
		BRJ->BRJ_DOCFI2 := cDocFis2
	EndIf
	BRJ->(MsUnLock())
	BRJ->(ConfirmSX8())
	cCodSeq    := BRJ->BRJ_CODIGO
	lCriadoBRJ := .T.
	
	BRJ->(RecLock("BRJ",.T.))
	BRJ->BRJ_FILIAL := xFilial("BRJ")
	BRJ->BRJ_CODIGO := cCodSeq
	BRJ->BRJ_DATA   := dDataBase
	BRJ->BRJ_REGPRI := "0"
	If !lNaoCriaPeg
		BRJ->BRJ_CODOPE := BCI->BCI_CODOPE
		BRJ->BRJ_CODLDP := BCI->BCI_CODLDP
		BRJ->BRJ_CODPEG := BCI->BCI_CODPEG
	Endif
	BRJ->(MsUnLock())
	
	PLSFechaSem(nHBRJ,"PLSBRJ.SMF")
Else
	If lCrieiPEG
		nHBRJ := PLSAbreSem("PLSBRJ.SMF")
		BRJ->(RecLock("BRJ",.F.))
		BRJ->BRJ_FILIAL := xFilial("BRJ")
		BRJ->BRJ_CODIGO := cCodSeq
		BRJ->BRJ_DATA   := dDataBase
		BRJ->BRJ_REGPRI := "0"
		BRJ->BRJ_CODOPE := BCI->BCI_CODOPE
		BRJ->BRJ_CODLDP := BCI->BCI_CODLDP
		BRJ->BRJ_CODPEG := BCI->BCI_CODPEG
		BRJ->(MsUnLock())
		PLSFechaSem(nHBRJ,"PLSBRJ.SMF")
	Endif
Endif

nPos := Ascan(aCodSeqImp,{|x| x == BRJ->BRJ_CODIGO})
If nPos = 0
	aAdd(aCodSeqImp,BRJ->BRJ_CODIGO)
Endif
	
Return

/*/{Protheus.doc} CriaGuiaSV
Cria Guia de servico...
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Static Function CriaGuiaSV(cAMPAG,cSenhaPLS,lAteRN,cGuiJur,nRecnoB5T,lCriaUsr)
LOCAL nH       := PLSAbreSem(BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)+".SMF")
LOCAL cNumero  := PLSA500NUM("BD5", BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG)
LOCAL cCC      := PLSUSRCC(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))
LOCAL cAuxDat  := PLSA500GCF("R502","DT_ATEND")
LOCAL dDataPro := ctod(subs(cAuxDat,9,2)+"/"+subs(cAuxDat,6,2)+"/"+subs(cAuxDat,1,4))
LOCAL cHorPro  := ""
LOCAL aRet     := {"",""}
LOCAL cLoteRef :=""
LOCAL aGuiOrig := ""
LOCAL cGuiPri  := ""
LOCAL cTipCon  := ""
LOCAL cTipAdm  := ""
LOCAL cGuijur  := ""
local cCodOpe  := ""

DEFAULT lAteRN := .F.
DEFAULT cGuiJur:= ""
DEFAULT nRecnoB5T := 0 
DEFAULT lCriaUsr  := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//Verifica se foi alterado o tamanho dos campos _HORPRO
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If Len(BD5->BD5_HORPRO) == 6
	cHorPro := subs(cAuxDat,11,2)+subs(cAuxDat,14,2)+subs(cAuxDat,17,2)
Else
	cHorPro := subs(cAuxDat,11,2)+subs(cAuxDat,14,2)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//Procura pela guia principal informada com o novo registro NR_NOTAPRINCIPAL
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If nRegraGrvImp == 1
	cGuiPri := PLSA500GCF("R502","NR_LOTE")+PLSA500GCF("R502","NR_GUIA_PR")
ElseIf nRegraGrvImp == 2
	cGuiPri := PLSA500GCF("R502","NR_GUIA_PR")
ElseIf nRegraGrvImp == 3
	cGuiPri := cUniOri+PLSA500GCF("R502","NR_GUIA_PR")
Endif

aGuiOrig := VerNotaINT("",cGuiPri,cUniOri,PLSA500GCF("R502","NR_GUIA_PR"))

cGuijur := PLSA500GCF("R502","ID_LIMINAR")

BD5->(RecLock("BD5",.T.))
BD5->BD5_FILIAL := xFilial("BD5")
BD5->BD5_CODOPE := BCI->BCI_CODOPE
BD5->BD5_TIPPAC := PLSA500GCF("R502","TP_PACIENT")
BD5->BD5_CODLDP := BCI->BCI_CODLDP
BD5->BD5_CODPEG := BCI->BCI_CODPEG
BD5->BD5_NUMERO := cNumero
BD5->BD5_DATPRO := dDataPro
BD5->BD5_HORPRO := cHorPro
If BD5->(FieldPos("BD5_PESEDI")) > 0
	BD5->BD5_PESEDI := PLSA500GCF("R502","TP_PESSOA","050")
	BD5->BD5_CGCEDI := PLSA500GCF("R502","NR_CNPJ_CP","051")
	BD5->BD5_CNESED := PLSA500GCF("R502","CD_CNES_EX","052")
	BD5->BD5_MUNEDI := PLSA500GCF("R502","CD_MUNIC_E","053")
EndIf
If !Empty(cGuijur)
	If cGuijur == "S"
		BD5->BD5_GUIJUR := "1"
	Else
		BD5->BD5_GUIJUR := "0"
	EndIf
EndIf

//NR_NOTAPRINCIPAL

If len(aGuiOrig) > 0 .And. !Empty(aGuiOrig[1])
	BD5->BD5_GUIINT := aGuiOrig[1]
EndIf

//TP_IND_ACIDENTE - Tipo de indicador de acidente

Do Case
Case PLSA500GCF("R502","TP_IND_ACI") == "0" // 0|9-Nao informado
	BD5->BD5_INDACI := ""
Case PLSA500GCF("R502","TP_IND_ACI") == "1" // 1-Acidente do trabalho
	BD5->BD5_INDACI := "0"
Case PLSA500GCF("R502","TP_IND_ACI") == "2" // 2-Acidente de transito
	BD5->BD5_INDACI := "1"
Case PLSA500GCF("R502","TP_IND_ACI") == "3" // 3-Acidente - outros
	BD5->BD5_INDACI := "2"
Case PLSA500GCF("R502","TP_IND_ACI") == "9" // 3-Acidente - outros
	BD5->BD5_INDACI := "9"
EndCase


BD5->BD5_NUMIMP := PLSA500GCF("R502","NR_NOTA")
If BD5->(FieldPos("BD5_LOTEDI")) > 0
	BD5->BD5_LOTEDI := PLSA500GCF("R502","NR_LOTE")
EndIf


BD5->BD5_OPEUSR := BA1->BA1_CODINT
If ! lUsrGen .or. (lUsrGen .and. lCriaUsr)
	BD5->BD5_MATANT := BA1->BA1_MATANT
	BD5->BD5_NOMUSR := IIF( empTy(cNmUsrAlt), BA1->BA1_NOMUSR, cNmUsrAlt )
	cNmUsrAlt := ""
Else
	BD5->BD5_MATANT := PLSA500GCF("R502","CD_UNI")+PLSA500GCF("R502","ID_BENEF")
	BD5->BD5_NOMUSR := PLSA500GCF("R502","NM_BENEF")
Endif
BD5->BD5_CODRDA := BAU->BAU_CODIGO
BD5->BD5_OPERDA := cUniDes
BD5->BD5_TIPRDA := BAU->BAU_TIPPE
BD5->BD5_NOMRDA := BAU->BAU_NOME
BD5->BD5_DESLOC := aDadRda[19]
BD5->BD5_ENDLOC := aDadRda[20]
BD5->BD5_CODESP := aDadRda[15]
BD5->BD5_CID    := PLSA500GCF("R502","CD_CID")

If Empty(BD5->BD5_CID)
	BD5->BD5_CID:= PlRetCidGe()
Endif
BD5->BD5_OPESOL := cUniDes


cTipCon	:= PLSVARVINC('52',, PLSA500GCF("R502","TP_CONSULT","048"))
If Empty(cTipCon) .Or. aErrVarVin[1]
	cTipCon := PLSA500GCF("R502","TP_CONSULT","048")
	If cTipCon == '1' //Primeira Consulta
		cTipCon := '1'
	ElseIf cTipCon == '2' //Retorno
		cTipCon := '5'
	ElseIf cTipCon == '3' //Pre-natal
		cTipCon := '3'
	ElseIf cTipCon == '4' //Por encaminhamento
		cTipCon := '4'
	ElseIf cTipCon == '5' //Seguimento
		cTipCon := '2'
	EndIf
EndIf
BD5->BD5_TIPCON := cTipCon

If BD5->(FieldPos("BD5_TIPADM")) > 0
	cTipAdm := PLSVARVINC('23',, PLSA500GCF("R502","TP_CARATER","047"))
	
	If Empty(cTipAdm) .Or. aErrVarVin[1]
		
		DbSelectArea("BDR")
		BDR->(DbGoTop())
		If !Empty(PLSA500GCF("R502","TP_CARATER","047"))
			While !BDR->(Eof())
				If PLSA500GCF("R502","TP_CARATER","047") == "1" .And. BDR->BDR_CARINT == "E"//Eletivo
					cTipAdm := BDR->BDR_CODTAD
					Exit
				EndIf
				
				If PLSA500GCF("R502","TP_CARATER","047") == "2" .And. BDR->BDR_CARINT == "U"//Urgencia/Emergencia
					cTipAdm := BDR->BDR_CODTAD
					Exit
				EndIf
				BDR->(DbSkip())
			EndDo
		Endif
	EndIf
	BD5->BD5_TIPADM := 	Alltrim(cTipAdm)
EndIf

BD5->BD5_TIPGUI := BCI->BCI_TIPGUI
BD5->BD5_CODEMP := BA1->BA1_CODEMP
BD5->BD5_MATRIC := BA1->BA1_MATRIC
BD5->BD5_TIPREG := BA1->BA1_TIPREG
BD5->BD5_CPFUSR := BA1->BA1_CPFUSR
BD5->BD5_IDUSR  := BA1->BA1_DRGUSR
BD5->BD5_DATNAS := BA1->BA1_DATNAS
BD5->BD5_CPFRDA := BAU->BAU_CPFCGC
BD5->BD5_FASE   := "1"
BD5->BD5_SITUAC := BCI->BCI_SITUAC
BD5->BD5_DIGITO := BA1->BA1_DIGITO
BD5->BD5_CONEMP := BA1->BA1_CONEMP
BD5->BD5_VERCON := BA1->BA1_VERCON
BD5->BD5_SUBCON := BA1->BA1_SUBCON
BD5->BD5_VERSUB := BA1->BA1_VERSUB
BD5->BD5_LOCAL  := aDadRda[13]
BD5->BD5_CODLOC := aDadRda[18]
BD5->BD5_MATVID := BA1->BA1_MATVID
BD5->BD5_DTDIGI := date()
BD5->BD5_MATUSA := "1"
BD5->BD5_ATERNA := "0"
BD5->BD5_PACOTE := "0"
BD5->BD5_SENHA  := cSenhaPLS
BD5->BD5_ORIMOV := "1"
BD5->BD5_MESPAG := subs(cAMPAG,5,2)
BD5->BD5_ANOPAG := subs(cAMPAG,1,4)
BD5->BD5_GUIACO := "0"
BD5->BD5_LIBERA := "0"
BD5->BD5_CC     := cCC
BD5->BD5_TIPPRE := BAU->BAU_TIPPRE
BD5->BD5_RGIMP  := "1"
BD5->BD5_TPGRV  := "4"
if BD5->(fieldpos("BD5_TISVER")) > 0
	BD5->BD5_TISVER	:= PLSA500GCF("R502","NR_VER_TIS") 	
endif
BD5->BD5_SEQIMP := cCodSeq
BD5->BD5_TIPATE := PLSP500ATE(PLSA500GCF("R502","TP_ATENDIM","018"), BD5->BD5_TIPGUI)                                                 
BD5->BD5_TIPSAI := PLSA500GCF("R502","TP_SAI_SAD","017")
BD5->BD5_GUIPRI := PLSA500GCF("R502","NR_GUIA_PR","021")

BD5->BD5_ATERNA := IIF(lAteRN,"1","0")

If ExistBlock("P500GRVGUI")
	ExecBlock("P500GRVGUI",.F.,.F.,{"BD5"})
EndIf

BD5->(MsUnLock())

aRet[1] := "BD5"
aRet[2] := BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO)
PLSFechaSem(nH,BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)+".SMF")

If Val(cCodLayPLS) >= 10 .And. lExB5T_B6T	
	nRecnoB5T := PLPTAtuB5T(cCodOpe,PLSA500GCF("R502","NR_LOTEPRE"),PLSA500GCF("R502","NR_GT_PRES"),BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),'BD5')
EndIf

Return aRet

/*/{Protheus.doc} CriaGuiaHS
Cria Guia GIH...
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
static Function CriaGuiaHS(cAMPAG,cSenhaPLS,cChvNtPesq,cCodOpe,lAteRN,cNota20,cSenNrOp,cGuiJur,nRecnoB5T)
LOCAL nH       		:= PLSAbreSem(BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)+".SMF")
LOCAL cNumero  		:= PLSA500NUM("BE4", BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG)
LOCAL cCC      		:= PLSUSRCC(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))
LOCAL cAuxDat  		:= PLSA500GCF("R502","DT_ATEND")
LOCAL dDataPro 		:= ctod(subs(cAuxDat,9,2)+"/"+subs(cAuxDat,6,2)+"/"+subs(cAuxDat,1,4))
LOCAL cHorPro  		:= ""
LOCAL cMesInt  		:= subs(dtos(dDataPro),5,2)
LOCAL cAnoInt  		:= subs(dtos(dDataPro),1,4)
LOCAL cNumInt		:= ""
LOCAL nRecno   		:= 0
LOCAL aRet     		:= {"",""}
LOCAL cLoteRef 		:= ""
LOCAL aGuiOrig 		:= {}
LOCAL cGuiPri  		:= ""
LOCAL cLotePre      := ""
LOCAL cNumGuiPre    := ""
LOCAL CIDOBT        := ""	
LOCAL lLayVer11     := Val(cCodLayPLS) >= 11
DEFAULT cSenNrOp	:= ""
DEFAULT lAteRN 		:= .F.
DEFAULT cGuiJur		:= ""
DEFAULT nRecnoB5T   := 0

//Procura pela guia principal informada com o novo registro NR_NOTAPRINCIPAL
If nRegraGrvImp == 1
	cGuiPri := PLSA500GCF("R502","NR_LOTE") + PLSA500GCF("R502","NR_GUIA_PR")
ElseIf nRegraGrvImp == 2
	cGuiPri := PLSA500GCF("R502","NR_GUIA_PR")
ElseIf nRegraGrvImp == 3
	cGuiPri := cCodOpe+PLSA500GCF("R502","NR_GUIA_PR")
Endif

aGuiOrig := VerNotaINT("",cGuiPri,cCodOpe,PLSA500GCF("R502","NR_GUIA_PR"))

If Empty(aGuiOrig[1])
	aGuiOrig := VerNotaINT(cSenhaPLS,cChvNtPesq,cCodOpe,cNota20,cSenNrOp)
Endif

cNumInt  := PLNUMINT(PLSINTPAD(),cAnoInt,cMesInt)

//Verifica se foi alterado o tamanho dos campos _HORPRO
If Len(BE4->BE4_HORPRO) == 6
	cHorPro := subs(cAuxDat,11,2)+subs(cAuxDat,14,2)+subs(cAuxDat,17,2)
Else
	cHorPro := subs(cAuxDat,11,2)+subs(cAuxDat,14,2)
EndIf
	
	BE4->(RecLock("BE4",.T.))
	
	BE4->BE4_FILIAL := xFilial("BE4")
	BE4->BE4_CODOPE := BCI->BCI_CODOPE
	BE4->BE4_CODLDP := BCI->BCI_CODLDP
	BE4->BE4_CODPEG := BCI->BCI_CODPEG
	BE4->BE4_NUMERO := cNumero
	BE4->BE4_NUMIMP := PLSA500GCF("R502","NR_NOTA")
	
	If BE4->(FieldPos("BE4_LOTEDI")) > 0
		BE4->BE4_LOTEDI := PLSA500GCF("R502","NR_LOTE")
	EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//Replica informacoes da guia original, elas podem ser alteradas posteriormente
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	BE4->BE4_GUIINT := aGuiOrig[1]
	BE4->BE4_TIPADM := aGuiOrig[2]
	BE4->BE4_TIPINT := aGuiOrig[3]
	BE4->BE4_PADINT := aGuiOrig[4]
	BE4->BE4_INDCLI := aGuiOrig[5]	
	BE4->BE4_GUIIMP := "1"
	BE4->BE4_DATPRO := dDataPro
	BE4->BE4_PRVINT := dDataPro
	BE4->BE4_DATVAL := BE4->BE4_DATPRO + GetNewPar("MV_PLPRZAI",30)	
	BE4->BE4_HORPRO := cHorPro
	BE4->BE4_OPEUSR := BA1->BA1_CODINT
	
	If ! lUsrGen
		BE4->BE4_MATANT := BA1->BA1_MATANT
		BE4->BE4_NOMUSR := IIF( empTy(cNmUsrAlt), BA1->BA1_NOMUSR, cNmUsrAlt )
		cNmUsrAlt := ""
	Else
		BE4->BE4_MATANT := PLSA500GCF("R502","CD_UNI")+PLSA500GCF("R502","ID_BENEF")
		BE4->BE4_NOMUSR := PLSA500GCF("R502","NM_BENEF")
	Endif
	
	BE4->BE4_CODRDA := BAU->BAU_CODIGO
	BE4->BE4_OPERDA := cUniDes
	BE4->BE4_NOMRDA := BAU->BAU_NOME
	BE4->BE4_CODESP := aDadRda[15]
	BE4->BE4_CID    := PLSA500GCF("R502","CD_CID")
	
	If Empty(BE4->BE4_CID)
		BE4->BE4_CID:= PlRetCidGe()
	Endif
	
	BE4->BE4_DESCID := BA9->(Posicione("BA9",1,xFilial("BA9")+BE4->BE4_CID,"BA9_DOENCA"))
	BE4->BE4_OPESOL := cUniDes
	BE4->BE4_TIPGUI := BCI->BCI_TIPGUI
	BE4->BE4_CODEMP := BA1->BA1_CODEMP
	BE4->BE4_MATRIC := BA1->BA1_MATRIC
	BE4->BE4_TIPREG := BA1->BA1_TIPREG
	BE4->BE4_CPFUSR := BA1->BA1_CPFUSR
	BE4->BE4_IDUSR  := BA1->BA1_DRGUSR
	BE4->BE4_DATNAS := BA1->BA1_DATNAS
	BE4->BE4_FASE   := "1"
	BE4->BE4_SITUAC := BCI->BCI_SITUAC
	BE4->BE4_DIGITO := BA1->BA1_DIGITO
	BE4->BE4_CONEMP := BA1->BA1_CONEMP
	BE4->BE4_VERCON := BA1->BA1_VERCON
	BE4->BE4_SUBCON := BA1->BA1_SUBCON
	BE4->BE4_VERSUB := BA1->BA1_VERSUB
	BE4->BE4_LOCAL  := aDadRda[13]
	BE4->BE4_CODLOC := aDadRda[12]
	BE4->BE4_MATVID := BA1->BA1_MATVID
	BE4->BE4_DTDIGI := Date()
	BE4->BE4_ANOINT := cAnoInt
	BE4->BE4_MESINT := cMesInt
	BE4->BE4_NUMINT := cNumInt
	BE4->BE4_MATUSA := "1"
	BE4->BE4_PACOTE := "0"
	BE4->BE4_SENHA  := cSenhaPLS
	BE4->BE4_ORIMOV := "2"
	BE4->BE4_MESPAG := Subs(cAMPAG,5,2)
	BE4->BE4_ANOPAG := Subs(cAMPAG,1,4)
	BE4->BE4_CC     := cCC
	BE4->BE4_TIPPRE := BAU->BAU_TIPPRE
	BE4->BE4_RGIMP  := "1"
	if BE4->(fieldpos("BE4_TISVER")) > 0
		BE4->BE4_TISVER	:= PLSA500GCF("R502","NR_VER_TIS") 	
	endif
	
	BE4->BE4_SEQIMP := cCodSeq
	
	If Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "502" .And. BE4->(FieldPos("BE4_PESEDI")) > 0
		BE4->BE4_PESEDI := PLSA500GCF("R502","TP_PESSOA","050")
		BE4->BE4_CGCEDI := PLSA500GCF("R502","NR_CNPJ_CP","051")
		BE4->BE4_CNESED := PLSA500GCF("R502","CD_CNES_EX","052")
		BE4->BE4_MUNEDI := PLSA500GCF("R502","CD_MUNIC_E","053")
	EndIf
	
	cLotePre   := PLSA500GCF("R502","NR_LOTEPRE")
	cNumGuiPre := PLSA500GCF("R502","NR_GT_PRES")
	cCIDOBT    := PLSA500GCF("R502","CD_CIDOBT")	
		
	If PLSA500GCF("R503","TP_FATURA","031") == "1"
		BE4->BE4_TIPFAT := "4"
	ElseIf PLSA500GCF("R503","TP_FATURA","031") == "2"
		BE4->BE4_TIPFAT := "1"
	ElseIf PLSA500GCF("R503","TP_FATURA","031") == "3"
		BE4->BE4_TIPFAT := "2"
	ElseIf PLSA500GCF("R503","TP_FATURA","031") == "4"
		BE4->BE4_TIPFAT := "3"
	EndIf
	
	If Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "502"
		Trb->(DbSkip())	
		BE4->BE4_CIDOBT := cCIDOBT
		BE4->BE4_NRDCOB := PLSA500GCF("R503","NR_DECOBT","040")
		BE4->BE4_NRDCNV := PLSA500GCF("R503","NR_VIVO1") + ;
		 	iif(!empty(val(PLSA500GCF("R503","NR_VIVO2"))),","+PLSA500GCF("R503","NR_VIVO2"),"") + ;		 	 
		 	iif(!empty(val(PLSA500GCF("R503","NR_VIVO3"))),","+PLSA500GCF("R503","NR_VIVO3"),"") + ;
		 	iif(!empty(val(PLSA500GCF("R503","NR_VIVO4"))),","+PLSA500GCF("R503","NR_VIVO4"),"") + ; 
		 	iif(!empty(val(PLSA500GCF("R503","NR_VIVO5"))),","+PLSA500GCF("R503","NR_VIVO5"),"")
		
		If Len(aDadUsr) > 0 .and. aDadUsr[1]
			BE4->BE4_PADCON := PLSACOMUSR(aDadUsr[2],'2')
			BE4->BE4_TIPUSR := aDadUsr[43]
		Endif
		
		If PLSA500GCF("R503","TP_OBTMULH","039") <> "0"
			BE4->BE4_OBTMUL	:= PLSA500GCF("R503","TP_OBTMULH","039")
		Else
			BE4->BE4_OBTMUL	:= ""
		EndIf
		Trb->(DbSkip(-1))	
	EndIf
	
	BE4->BE4_ATERNA := IIF(lAteRN,"1","0")
	BE4->BE4_GUIJUR := cGuiJur
	
	If BIY->(FieldPos("BIY_CODEDI")) > 0
		BIY->(DbSetOrder(4))//BIY_FILIAL + BIY_CODEDI
		If BIY->(DbSeek(xFilial("BIY")+PLSA500GCF("R502","MOTIVO_ENC")))
			BE4->BE4_TIPALT := Alltrim(BIY->BIY_CODSAI)
		EndIf
	EndIf
	
	If ExistBlock("P500GRVGUI")
		ExecBlock("P500GRVGUI",.F.,.F.,{"BE4"})
	EndIf
	
	BE4->(MsUnLock())
	
	aRet[1] := "BE4"
	aRet[2] := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
	
	If lExB5T_B6T
		nRecnoB5T := PLPTAtuB5T(cCodOpe,cLotePre,cNumGuiPre,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),'BE4')
	EndIf
		
PLSFechaSem(nH,BCI->(BCI_CODOPE+BCI_CODLDP+BCI_CODPEG)+".SMF")
	
Return aRet

/*/{Protheus.doc} CriaEvento
Cria Evento a partir do BD5 ou BE4
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Static Function CriaEvento(nNextRec,aPartPro,nJ,lForNBD6,nRecnoBD6,cHorario,cMatric,cHoraFim,aBD7Ger,nRecnoB5T)
LOCAL aCpoNiv
LOCAL nFor
LOCAL nForCpo
LOCAL cMacro
LOCAL cCampoOri
LOCAL aCodTab
LOCAL cGrpEmpInt := GetNewPar("MV_PLSGEIN","0050")
LOCAL lDePara    := GetNewPar("MV_P500HDP","1") == "1"
Local lDeParaBTU := GetNewPar("MV_PLAJBTU","0") == "1"
Local aRetBTU    := {}
LOCAL nAux
LOCAL cNewSeq
LOCAL nI
LOCAL cChavePes  := &(cAliasPLS+"->"+cAliasPLS+"_CODOPE")+&(cAliasPLS+"->"+cAliasPLS+"_CODLDP")+;
					&(cAliasPLS+"->"+cAliasPLS+"_CODPEG")+&(cAliasPLS+"->"+cAliasPLS+"_NUMERO")+&(cAliasPLS+"->"+cAliasPLS+"_ORIMOV")
LOCAL cAuxDat  := PLSA500GCF("R504","DT_SERVICO")
LOCAL dDataPro := ctod(subs(cAuxDat,7,2)+"/"+subs(cAuxDat,5,2)+"/"+subs(cAuxDat,1,4))
LOCAL cOriMov  := &(cAliasPLS+"->"+cAliasPLS+"_ORIMOV")
LOCAL cCodSer  := cValToChar(PLSA500GCF("R504","CD_SERVICO"))
LOCAL lAjusBR8 := .F.
LOCAL lCriaBD6 := .T.
LOCAL cTpPart  := PLSA500GCF("R504","TP_PARTICI")
LOCAL lUptHM   := .F.
LOCAL aBD7     := {}
LOCAL cMatAnt  := BA1->BA1_MATANT
LOCAL lAltQtd  := .F.
LOCAL lExclui  := .F.
LOCAL nControl := 0
LOCAL nTotAtM  := 0
LOCAL nTtTAtM  := 0
LOCAL nQtdPro  := 0
LOCAL nTotApr  := 0
LOCAL nToTaAp  := 0
LOCAL lFlagDel := .T.
LOCAL nAprCheio := 0
LOCAL nTaxCheio := 0
LOCAL aCtrlBD7  := {.F.,.F.,.F.}
LOCAL lAprUsado := .F.
LOCAL cTipApr   := ""
LOCAL nRecno	:= 0
LOCAL cProxPart := ""
LOCAL lPreAut   := .F.
LOCAL lOldAlt   := .F.
LOCAL aArea		:= GetArea()
LOCAL lHaCritca	:= .F.
LOCAL cCodUnmBd7:= ""
LOCAL nVlrTApr  := 0
LOCAL nVlrTXpap := 0
LOCAL aRegBd7Im	:= {}
LOCAL aTpParBkc	:= {}
LOCAL aTpParCOP := {}
LOCAL aMatTOTBD7:= {}
LOCAL lMatBD7	:= .f.
LOCAL xy		:= 0
LOCAL cUnidBd4	:= ""
LOCAL lHaUnBd4	:= .F.
LOCAL cLoteRef	:= ""
LOCAL lFindBB0  := .F.
LOCAL nPosR502  := 0
LOCAL lGerBd7	:= .T.
LOCAL lConsulta := .F.
LOCAL lP500BLPG	:= existBlock("P500BLPG")
LOCAL lPL500MF	:= existBlock("PL500MF")

// Importação de Genericos
LOCAL cCodMedGen    := GetNewPar("MV_PLMEDPT","")
LOCAL cCodMatGen    := GetNewPar("MV_PLMATPT","")
LOCAL cCodTaxGen    := GetNewPar("MV_PLTAXPT","")
LOCAL cCodOpmGen    := GetNewPar("MV_PLOPMPT","")
LOCAL cCodPacGen    := getNewPar("MV_PLPACPT","99999998")
Local cBloPag		:= "1"

local lBD6_VLTXAP 	:= BD6->(fieldPos("BD6_VLTXAP")) > 0
local lBD7_PEINPT 	:= BD7->(fieldPos("BD7_PEINPT")) > 0
local lBD7_VLINPT 	:= BD7->(fieldPos("BD7_VLINPT")) > 0

local cChaveBD6 	:= ""
local cTipoGuia 	:= ""
local aRdas 		:= {}
local lCirurgico	:= .f.
local cRegAte 		:= ""
local cRegInt 		:= ""
local cRegPag 		:= ""
local cRegCob 		:= ""
local cFinAte 		:= ""
local cTipAdm 		:= ""
local cTPRDAE		:= ""
local cCNPJED		:= ""
local aValor 		:= {}
local lValorizou	:= .f.
local aAux	 		:= {}
local nVlrTotEve	:= {}
local nVlrTotApr	:= 0
local nVlrTotApTx	:= 0
local nPos 			:= 0
local nPercen		:= 0
local nRecAPRBD7 	:= 0
local nTotPerCen	:= 0
local lLayVer11		:= Val(cCodLayPLS) >= 11
local cTRDAED 		:= ""
local cRPEDI		:= ""
local cNOMEDI		:= ""
local cNomArq		:= ""
local nVlrEvent		:= 0
local nVlrTaxa		:= 0
Local lGrvPrf		:= .F.
Local nPosCmpX	:= 0
Local aCposPad	:= {}
Local cMVPLSCAUX := GetNewPar("MV_PLSCAUX","AUX")
Local lAllBlq		:= .F.
Local cTpTabela := PLSA500GCF("R504","TP_TABELA")

DEFAULT nNextRec 	:= 0
DEFAULT nJ		 	:= 0
DEFAULT aPartPro 	:= {}
DEFAULT lForNBD6 	:= .F.
DEFAULT nRecnoBD6  	:= 0
DEFAULT cMatric    	:= ""
DEFAULT cHoraFim   	:= ""
DEFAULT aBD7Ger    	:= {}
DEFAULT nRecnoB5T   := 0

If empTy(cTpPart)
	cTpPart := "0"
endIf

//Posiciona na familia/usuario/grupo empresa/sub-contrato
If !Empty(cMatric)
	BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1 _MATRIC+BA1_TIPREG+BA1_DIGITO
	BA1->(DbSeek(xFilial("BA1")+cMatric))
	BA3->(DbSetOrder(1))
	BA3->(DbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
	BG9->(DbSetOrder(1))//BG9_FILIAL + BG9_CODINT + BG9_CODIGO + BG9_TIPO
	BG9->(DbSeek(xFilial("BG9")+BA1->(BA1_CODINT+BA1_CODEMP)))
	BQC->(DbSetOrder(1))//BQC_FILIAL + BQC_CODIGO + BQC_NUMCON + BQC_VERCON + BQC_SUBCON + BQC_VERSUB
	BQC->(DbSeek(xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON + BA1_VERSUB)))
EndIf

nRecno := Trb->(Recno())
If nNextRec > 0
	Trb->(DbGoTo(nNextRec))
Else
	Trb->(DbSkip())
Endif
cProxPart := alltrim(PLSA500GCF("R504","TP_PARTICI"))
Trb->(DbGoTo(nRecno))

If PLSLOG500()
	nHorIni := Seconds()
Endif

If PLSLOG500()
	PlsLogFil("-> 504 Parte 1                           -> "+AllTrim(Str(Seconds()-nHorIni,10,3))+" Segundo(s)",__PLSFL500)
	nHorIni := Seconds()
Endif
If Empty(dDataPro)
	dDataPro := &(cAliasPLS+"->"+cAliasPLS+"_DATPRO")
Endif

if empty(PLSA500GCF("R504","ID_PACOTE"))
	cCodSer := GetNewPar("MV_PLPACPT","99999998")
endif

If lDeParaBTU
	
	aRetBTU := PTUDePaBTU(PLSA500GCF("R504","TP_TABELA"),cCodSer,cCodPaPro,.T.,.F.)
	If len(aRetBTU) > 0
		BR8->(DbSetOrder(1))
		BR8->(MsSeek(xFilial("BR8")+aRetBTU[1]+aRetBTU[2]))
	Else
		BR8->(DbSetOrder(1))
		BR8->(MsSeek(xFilial("BR8")+cCodPaPro+cCodSer))
	Endif
	
ElseIf lDePara
	lAjusBR8 := PLBusProTab(cCodSer,.T.,PLSA500GCF("R504","DT_SERVICO"),nil,lConverProc,cUniOri,cCodProGen,cCodPadCon,cCodPaPro)
Else
	BR8->(DbSetOrder(1))
	If !BR8->(MsSeek(xFilial("BR8")+cCodPaPro+cCodSer))
		BR8->(DbSetOrder(3))
		If !BR8->(MsSeek(xFilial("BR8")+cCodSer))
			lAjusBR8 := PlsBr8Gen(cCodProGen,.t.,cCodPaPro)[1]
		EndIf
	Endif
EndIf

If PLSLOG500()
	PlsLogFil("-> 504 Parte 2                           -> "+AllTrim(Str(Seconds()-nHorIni,10,3))+" Segundo(s)",__PLSFL500)
	nHorIni := Seconds()
Endif

//Busca participacoes para HM e para COP/COR
BKC->(DbgOTop())
BKC->(MsSeek(xFilial("BKC")))
While !BKC->(EOF()) .and. BKC->BKC_FILIAL == xFilial("BKC")
	If Alltrim(BKC->BKC_CODPAR) == cTpPart
		If ! substr(BKC->BKC_CODIGO,1,2) $ "CO|FI" 
			AAdd(aTpParBkc,BKC->BKC_CODIGO)
		elseIf Substr(BKC->BKC_CODIGO,1,2) $ "CO"
			AAdd(aTpParCOP,BKC->BKC_CODIGO)
		Endif
	Endif
	BKC->(Dbskip())
Enddo

If cTpPart == "0"
	
	lCriaBD6 := .T.
	
	BD6->(DbSetOrder(1))
	If BD6->(DbSeek(xFilial("BD6")+cChavePes))
		While !BD6->(Eof()) .AND. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)=xFilial("BD6")+cChavePes
			
			If Alltrim(BD6->BD6_CODPRO) == cValToChar(PLSA500GCF("R504","CD_SERVICO"))
				
				If MV_PAR18<> 1 .AND. cValToChar(PLSA500GCF("R504","CD_SERVICO")) $ "90000021#90000013"
					lCriaBD6 := .F.
					lAltQtd  := .T.
					Exit
				Endif
				
			Endif
			
			BD6->(Dbskip())
		Enddo
		
		BD6->(DbGoto(nRecnoBD6))
	Endif
	
Else
	
	If cUltCodigo == BR8->BR8_CODPSA
		
		If cTpPart == cUltPart .And. cRdaUlt ==  PLSA500GCF("R504","CD_PREST")  .And. cDataUlt == PLSA500GCF("R504","DT_SERVICO") .And. cViaUlt == PLSA500GCF("R504","CD_VIA_ACE")
			
			//Nao criar outro evento
			
			If MV_PAR18<> 1 .AND. (cValToChar(PLSA500GCF("R504","CD_SERVICO")) $ "90000021#90000013"+"/"+cCodMedGen+"/"+cCodMatGen .Or. BR8->BR8_TPPROC $ "12")
				lCriaBD6 := .F.
				lAltQtd  := .T.
			Else
				lCriaBD6 := .T.
				lAltQtd  := .F.
			Endif
		Else
			
			//Mesmo codigo participacao diferente e um bd7 diferente
			
			// Esse item se faz necessario para não gerar varios bd6 e bd7 devido que no arquivo de importação do ptu esta por tipo de participação.
			aArBD6Ant := BD6->(GetArea())
			If BD6->(DbSeek(xFilial("BD6")+cChavePes))
				
				While !BD6->(EOF())	.AND. BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == cChavePes
					
					If BD6->(BD6_CODPAD+BD6_CODPRO) == BR8->(BR8_CODPAD+BR8_CODPSA)
						
						If MV_PAR18 <> 1 .AND. (cValToChar(PLSA500GCF("R504","CD_SERVICO")) $ "90000021#90000013"+"/"+cCodMedGen+"/"+cCodMatGen .Or. BR8->BR8_TPPROC $ "12")
							lCriaBD6 := .F.
							lAltQtd  := .T.
							Exit
						Else
							lCriaBD6 := .T.
							lAltQtd  := .F.
							Exit
						EndIf
						
					Endif
					BD6->(DbSkip())
				Enddo
			Else
				lCriaBD6 := .T.
			Endif
			RestArea(aArBD6Ant)
		Endif
		
		//Aqui eu verifico se a linha de baixo do registro 504 esta complementando a linha de cima
		//antes de se efetuar esta alteração foi contactada a UNIMED BRASIL a fim de esclarecer
		//se esta situacao poderia ocorrer
		
		If alltrim(cTpPart) == 'X' .and. ( alltrim(cUltPart) == '0' .or. alltrim(cProxPart) == 'X') .and. ;
				cRdaUlt <> PLSA500GCF("R504","CD_PREST") .and. cDataUlt == PLSA500GCF("R504","DT_SERVICO") .and.;
				cViaUlt == PLSA500GCF("R504","CD_VIA_ACE")
			lCriaBD6 := .F.
			lAltQtd  := .F.
		Endif
		
		//Aqui indica que eh uma cirurgia, ou seja, antes o sistema criava 3 BD6, o que estava
		//errado, visto que poderia dar problema no calculo da co-participacao, e no tratamento
		//da quantidade X percentual.
		
		If aScan(aPartPro,{|x| upper(alltrim(x[1])) $ "C"}) > 0 .and. ; // tem cirurgiao
			(aScan(aPartPro,{|x| upper(alltrim(x[1])) $ "A"}) > 0 .or. ; // em toda cirurgia tem anestesista
			aScan(aPartPro,{|x| upper(alltrim(x[1])) $ "1"}) > 0) .and.; // ou tem auxiliar ou tem os dois
			!(upper(alltrim(cTpPart)) $ "0,X,H,P,L") .and. ; // cirugia nao tem isso
			nJ <> 1 .and.;//jah criou o primeiro procedimento da nota
			cViaUlt == PLSA500GCF("R504","CD_VIA_ACE")
			
			lCriaBD6 := .F.
			lAltQtd  := .F.
			
		Endif
	Else
		
		//Outro codigo portando eh outro procedimento
		// Esse item se faz necessario para não gerar varios bd7 e bd7 devido que no arquivo de importação do ptu esta por tipo de participação.
		aArBD6Ant := BD6->(GetArea())
		If BD6->(DbSeek(xFilial("BD6")+cChavePes))
			
			While !BD6->(EOF())	.AND. BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == cChavePes
				
				If BD6->(BD6_CODPAD+BD6_CODPRO) == BR8->(BR8_CODPAD+BR8_CODPSA)
					
					If MV_PAR18 <> 1 .AND. (cValToChar(PLSA500GCF("R504","CD_SERVICO")) $ "90000021#90000013"+"/"+cCodMedGen+"/"+cCodMatGen .Or. BR8->BR8_TPPROC $ "12")
						lCriaBD6 := .F.
						lAltQtd  := .T.
						Exit
					Else
						lCriaBD6 := .T.
						lAltQtd  := .F.
						Exit
					EndIf
				Endif
				
				BD6->(DbSkip())
			Enddo
		Else
			lCriaBD6 := .T.
			lAltQtd  := .F.
		Endif
		
		RestArea(aArBD6Ant)
	Endif
	
Endif

If lForNBD6
	
	//Posiciona no Recno correto
	If nRecnoBD6 > 0
		BD6->(DbGoTo(nRecnoBD6))
	EndIf
	
	lCriaBD6 := .F.
	
	If nJ == 1 .or. cTpPart == "0"  .or. cUltCodigo <> BR8->BR8_CODPSA
		lOldAlt  := .T.
	Else
		lOldAlt  := lAltQtd
	Endif
	
	lAltQtd  := .T.
	lPreAut  := .T.
Endif

If lCriaBD6
	
	//Verifica se o solicitante existe na base de dados
	While !Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "502"
		Trb->(DbSkip(-1))
		nPosR502 ++
		
		//Campos que eram do R504 e na versao 10.0 foram migrados para o R502
		cTRDAED := PLSA500GCF("R502","TP_PREST")
		cNOMEDI := PLSA500GCF("R502","NM_PREST") 
		cRPEDI  := PLSA500GCF("R502","ID_REC_PRO")
		cTPRDAE := PLSA500GCF("R502","TP_PESSOA")
		cCNPJED := PLSA500GCF("R502","NR_CNPJ_CP")
			
	EndDo
	
	BB0->(DbSetOrder(4))//BB0_FILIAL + BB0_ESTADO + BB0_NUMCR + BB0_CODSIG + BB0_CODOPE
	If !Empty(PLSA500GCF("R502","SG_CON_REQ")) .And. !Empty(PLSA500GCF("R502","NR_CON_REQ")) .And. !Empty(PLSA500GCF("R502","UF_CON_REQ"))
		
		If  BB0->(DbSeek(xFilial("BB0")+PLSA500GCF("R502","UF_CON_REQ")+;
				Alltrim(PLSA500GCF("R502","NR_CON_REQ")) + Space(TamSX3("BB0_NUMCR")[1] - len( Alltrim(PLSA500GCF("R502","NR_CON_REQ")) ))+;
				Alltrim(PLSA500GCF("R502","SG_CON_REQ")) + Space(TamSX3("BB0_CODSIG")[1] - len( Alltrim(PLSA500GCF("R502","SG_CON_REQ")) )) ))
			
			lFindBB0 := .T.
		Else

			PlSveProfAll(Alltrim(PLSA500GCF("R502","NM_PREST_R")), Alltrim(PLSA500GCF("R502","SG_CON_REQ")), PLSA500GCF("R502","UF_CON_REQ"),;
					 	 Alltrim(PLSA500GCF("R502","NR_CON_REQ")), PLSA500GCF("R502","CD_UNI"), '', '2', PLSA500GCF("R502","CD_UNI"),{},.t.)
			
			&(cAliasPLS)->(RecLock(cAliasPLS,.F.))
			&(cAliasPLS+"->"+cAliasPLS+"_ESTSOL") 	:= BB0->BB0_ESTADO
			&(cAliasPLS+"->"+cAliasPLS+"_SIGLA")  	:= BB0->BB0_CODSIG
			&(cAliasPLS+"->"+cAliasPLS+"_REGSOL") 	:= BB0->BB0_NUMCR
			&(cAliasPLS+"->"+cAliasPLS+"_NOMSOL") 	:= BB0->BB0_NOME
			&(cAliasPLS+"->"+cAliasPLS+"_CDPFSO")	:= BB0->BB0_CODIGO
			&(cAliasPLS)->(MsUnLock())
			
		Endif
		
	EndIf	

	Trb->(DbSkip(nPosR502))
	
	//Atualiza dados do cabecalho que somente existe no layout no item
	
	If !lFindBB0
		BB0->(DbSetOrder(5))
		If ! BB0->(MsSeek(xFilial("BB0")+PLSA500GCF("R504","CD_UNI_PRE")))
			BA0->(DbSetOrder(1))
			If BA0->(MsSeek(xFilial("BA0")+PLSA500GCF("R504","CD_UNI_PRE")))

				PlSveProfAll("SOLIC. PAD. OPER. "+PLSA500GCF("R504","CD_UNI_PRE"), GETMV("MV_PLSIGLA"), BA0->BA0_EST,;
					 		 "OPE"+PLSA500GCF("R504","CD_UNI_PRE"), PLSA500GCF("R504","CD_UNI_PRE"), '', '1', PLSA500GCF("R504","CD_UNI_PRE"),{},.t.)
			Endif
		Endif
	EndIf
	
	If PLSLOG500()
		PlsLogFil("-> 504 Parte 4                           -> "+AllTrim(Str(Seconds()-nHorIni,10,3))+" Segundo(s)",__PLSFL500)
		nHorIni := Seconds()
	Endif
	&(cAliasPLS)->(RecLock(cAliasPLS,.F.))
	&(cAliasPLS+"->"+cAliasPLS+"_ESTSOL") := BB0->BB0_ESTADO
	&(cAliasPLS+"->"+cAliasPLS+"_SIGLA")  := BB0->BB0_CODSIG
	&(cAliasPLS+"->"+cAliasPLS+"_REGSOL") := BB0->BB0_NUMCR
	&(cAliasPLS+"->"+cAliasPLS+"_CDPFSO") := BB0->BB0_CODIGO
	If cAliasPLS == "BD5"
		&(cAliasPLS+"->"+cAliasPLS+"_NOMSOL") := BB0->BB0_NOME
		&(cAliasPLS+"->"+cAliasPLS+"_DATSOL") := stod(PLSA500GCF("R504","DT_SOLICIT"))
	EndIf	
	&(cAliasPLS)->(MsUnLock())
	
	BD6->(DbSetOrder(1))
	BD6->(DbSeek(xFilial("BD6")+cChavePes+Replicate("Z",Len(BD6->BD6_SEQUEN)),.T.))
	BD6->(DbSkip(-1))
	
	If BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == xFilial("BD6")+cChavePes
		cNewSeq := Soma1(BD6->BD6_SEQUEN)
	Else
		cNewSeq := StrZero(1,Len(BD6->BD6_SEQUEN))
	Endif
	
	If PLSLOG500()
		PlsLogFil("-> 504 Parte 5                           -> "+AllTrim(Str(Seconds()-nHorIni,10,3))+" Segundo(s)",__PLSFL500)
		nHorIni := Seconds()
	Endif
	
	aCpoNiv := PLSUpCpoNv(BR8->BR8_CODPAD,BR8->BR8_CODPSA,"BD6")
	
	If PLSA500GCF("R504","TP_TABELA") $ '0/4'
		nAux := val(Substr(PLSA500GCF("R504","QT_COBRADA"),1,4))
	Else
		nAux := Val(Substr(PLSA500GCF("R504","QT_COBRADA"),1,4)+"."+Substr(PLSA500GCF("R504","QT_COBRADA"),5,4))
	EndIf
	
	
	BD6->(RecLock("BD6",.T.))
	
	For nFor := 1 To Len(aCpoNiv)
		&(aCpoNiv[nFor,1]) := (aCpoNiv[nFor,2])
	Next
	
	If PLSLOG500()
		PlsLogFil("-> 504 Parte 6                           -> "+AllTrim(Str(Seconds()-nHorIni,10,3))+" Segundo(s)",__PLSFL500)
		nHorIni := Seconds()
	Endif
	
	BD6->BD6_FILIAL := xFilial("BD6")
	If Empty(BA1->BA1_CODPLA)
		BD6->BD6_CODPLA := BA3->BA3_CODPLA
	Else
		BD6->BD6_CODPLA := BA1->BA1_CODPLA
	EndIf
	BD6->BD6_TPGRV  := "4"
	BD6->BD6_SEQUEN := cNewSeq
	BD6->BD6_CODPAD := BR8->BR8_CODPAD 
	BD6->BD6_CODPRO := BR8->BR8_CODPSA
	
	cUltCodigo := BR8->BR8_CODPSA
	cUltPart   := cTpPart
	cRdaUlt    := PLSA500GCF("R504","CD_PREST")
	cDataUlt   := PLSA500GCF("R504","DT_SERVICO")
	
	lConsulta  := PLSISCON(BD6->BD6_CODPAD,BD6->BD6_CODPRO)
	
	If lConsulta
		cViaUlt := "00"
	Else
		cViaUlt := PLSA500GCF("R504","CD_VIA_ACE")
	EndIf
		
	BD6->BD6_TRDAED := cTRDAED
	BD6->BD6_RPEDI  := cRPEDI
	BD6->BD6_TPRDAE := cTPRDAE
	BD6->BD6_CNPJED := cCNPJED
	BD6->BD6_ESPEDI := getEspEdi(PLSA500GCF("R504","NR_CBO_EXE"))
	
	// verifica se o CD_SERVICO  e generico
	If 	Alltrim(BR8->BR8_CODPSA) == cCodMedGen .Or. Alltrim(BR8->BR8_CODPSA) == cCodMatGen .Or. ;
			Alltrim(BR8->BR8_CODPSA) == cCodTaxGen .Or. Alltrim(BR8->BR8_CODPSA) == cCodOpmGen .or. ;
			Alltrim(BR8->BR8_CODPSA) == cCodPacGen
		
		BD6->BD6_DESPRO := IIf(Empty(PLSA500GCF("R504","DS_SERVICO")),BR8->BR8_DESCRI,PLSA500GCF("R504","DS_SERVICO"))
		
	Else
		BD6->BD6_DESPRO := BR8->BR8_DESCRI
	Endif
	
	BD6->BD6_DES500 := iIf(Empty(PLSA500GCF("R504","DS_SERVICO")),BR8->BR8_DESCRI,PLSA500GCF("R504","DS_SERVICO"))
	BD6->BD6_QTDPRO := nAux
	
	//Valor apresentado e sem a taxa o valor de taxa apresentado deve ficar no campo VLTXAP para que a glosa fique correta
	BD6->BD6_VALORI := Val(Subs(PLSA500GCF("R504","VL_SERV_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_SERV_CO"),13,2))
	BD6->BD6_VALORI += Val(Subs(PLSA500GCF("R504","VL_CO_COB"),1,12)+"."+Subs(PLSA500GCF("R504","VL_CO_COB"),13,2))
	BD6->BD6_VALORI += Val(Subs(PLSA500GCF("R504","VL_FILME_C"),1,12)+"."+Subs(PLSA500GCF("R504","VL_FILME_C"),13,2))

	BD6->BD6_VLRAPR := BD6->BD6_VALORI / BD6->BD6_QTDPRO
	
	If lBD6_VLTXAP
		BD6->BD6_VLTXAP :=  Val(Subs(PLSA500GCF("R504","VL_ADIC_SE"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_SE"),13,2))
		BD6->BD6_VLTXAP +=  Val(Subs(PLSA500GCF("R504","VL_ADIC_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_CO"),13,2))
		BD6->BD6_VLTXAP +=  Val(Subs(PLSA500GCF("R504","VL_ADIC_FI"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_FI"),13,2))
	EndIf
	
	BD6->BD6_VLRBPF := Val(Subs(PLSA500GCF("R504","VL_SERV_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_SERV_CO"),13,2))
	
	BD6->BD6_ORIMOV := cOriMov
	BD6->BD6_NIVEL  := BR8->BR8_NIVEL
	BD6->BD6_STATUS := "1"
	
	If len(aDadUsr) < 48
		aDadUsr := PLSDADUSR(cMatric,"1",.F.,dDataPro)
	EndIf
	
	BD6->BD6_MODCOB := iIf( len(aDadUsr) >= 48, aDadUsr[48], "")
	BD6->BD6_TIPUSR := iIf( len(aDadUsr) >= 90, aDadUsr[90], "")
	BD6->BD6_INTERC := iIf( len(aDadUsr) >= 91, aDadUsr[91], "")
	BD6->BD6_TIPINT := iIf( len(aDadUsr) >= 43, aDadUsr[43], "")
	
	BD6->BD6_OPEORI := BA1->BA1_OPEORI
	BD6->BD6_CHVNIV := ""
	BD6->BD6_NIVAUT := ""
	BD6->BD6_PROCCI := If(BR8->BR8_TIPEVE$"2,3","1","0")
	
	BD6->BD6_SEQIMP := cCodSeq
	BD6->BD6_TIPRDA := PLSA500GCF("R504","TP_PESSOA")
	BD6->BD6_CODATO := PLSA500GCF("R504","CD_ATO")
	BD6->BD6_CODLOC := aDadRda[12]
	BD6->BD6_LOCAL  := aDadRda[13]
	BD6->BD6_MATCOB := cMatrCob
	BD6->BD6_NOMCOB := cNomCob
	BD6->BD6_ENVCON := "0"
	
	If PLSA500GCF("R504","ID_PACOTE")=="S"
		BD6->BD6_CD_PAC := PLSA500GCF("R504","CD_PACOTE")
	elseIF empty(PLSA500GCF("R504","ID_PACOTE"))
		BD6->BD6_CD_PAC := PLSA500GCF("R504","CD_SERVICO")
	Endif
	
	BD6->BD6_INCAUT := "1"
	
	If !Empty(PLSA500GCF("R504","CD_REF_MAT")) .And. BD6->(FieldPos("BD6_REFFED")) > 0
		BD6->BD6_REFFED := PLSA500GCF("R504","CD_REF_MAT")
	EndIf
	
	If cAliasPLS == "BD5"
		aCposPad := aClone(aCposPadD5)
	else
		aCposPad := aClone(aCposPadE4)
	EndIf
	
	For nForCpo := 1 To Len(aCposPad)
		
		cMacro := ("BD6->BD6_" + Subs(aCposPad[nForCpo,1],5,10))
		If cAliasPLS == "BD5"
			nPosCmpX := ascan(aCmpBD5BD6, cMacro)
		else
			nPosCmpX := ascan(aCmpBE4BD6, cMacro)
		endIf

		If nPosCmpX > 0 .AND. !(alltrim("BD6_"+Subs(aCposPad[nForCpo,1],5,10)) $ "BD6_CNPJED,BD6_VLRAPR,BD6_VALORI,BD6_TPRDAE,BD6_QTDAPR,BD6_TIPUSR,BD6_RDAEDI,BD6_NOMEDI,BD6_TRDAED,BD6_RPEDI,BD6_ESPEDI")
			
			cCampoOri := cAliasPLS+"->"+cAliasPLS+"_"+Subs(aCposPad[nForCpo,1],5,10)
			&(cMacro) := &(cCampoOri)
			
		Endif
		
	Next	
	
	BD6->BD6_NOMEDI := cNOMEDI	
	BD6->BD6_RDAEDI := cRdaUlt
	cHorario := strtran(cHorario,':','')

	If len(BD6->BD6_HORPRO) > 4
		BD6->BD6_HORPRO := (SUBSTR (cHorario,1,2) + SUBSTR (cHorario,3,2)+SUBSTR (cHorario,5,2))
	Else
		BD6->BD6_HORPRO := (SUBSTR (cHorario,1,2) + SUBSTR (cHorario,3,2))
	Endif
	
	If !Empty(cHoraFim)
		cHoraFim := strtran(cHoraFim,':','')
		If len(BD6->BD6_HORFIM) > 4
			BD6->BD6_HORFIM := (SUBSTR (cHoraFim,1,2) + SUBSTR (cHoraFim,3,2)+SUBSTR (cHoraFim,5,2))
		Else
			BD6->BD6_HORFIM := (SUBSTR (cHoraFim,1,2) + SUBSTR (cHoraFim,3,2))
		Endif
	EndIf
	
	aCodTab := PLSRETTAB(BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_DATPRO,;
						BD6->BD6_CODOPE,BD6->BD6_CODRDA,BD6->BD6_CODESP,BD6->BD6_SUBESP,BD6->(BD6_CODLOC+BD6_LOCAL),;
						BD6->BD6_DATPRO,"1",BD6->BD6_OPEORI,BD6->BD6_CODPLA,"2","1")
	
	If aCodTab[1]
		BD6->BD6_CODTAB := aCodTab[3]
		BD6->BD6_ALIATB := aCodTab[4]
	Endif
	
	BD6->BD6_DATPRO := dDataPro
	
	BGR->(DbSetOrder(2))
	If !lConsulta .And. BGR->(MsSeek(xFilial("BGR")+PLSINTPAD()+StrZero(Val(PLSA500GCF("R504","CD_VIA_ACE")),1))) .And. BR8->BR8_TIPEVE <> '1'
		BD6->BD6_VIA     := BGR->BGR_CODVIA
		BD6->BD6_PERVIA  := BGR->BGR_PERC
	Else
		BGR->(DbSetOrder(1))
		If !lConsulta .And. BGR->(MsSeek(xFilial("BGR")+PLSINTPAD()+StrZero(Val(PLSA500GCF("R504","CD_VIA_ACE")),1))) .And. BR8->BR8_TIPEVE <> '1'
			BD6->BD6_VIA    := BGR->BGR_CODVIA
			BD6->BD6_PERVIA := BGR->BGR_PERC
		Endif
	Endif
	
	If BD6->BD6_VIA >= "1"
		BD6->BD6_PROCCI := "1" //Somente pelo fato de vir como via de acesso
	Endif
	
	If lAjusBR8
		BD6->BD6_CODERR := cCodSer
		BD6->BD6_SLVPRO := cCodSer
		If cTpTabela == '1'
			BD6->BD6_SLVPAD := "22"
		Elseif cTpTabela == '5'
			BD6->BD6_SLVPAD := "19"
		Elseif cTpTabela == '6'
			BD6->BD6_SLVPAD := "20"
		Else // cTpTabela 0,2,3,4
			BD6->BD6_SLVPAD := "00"
		Endif
	Endif
	
	BD6->BD6_NUMIMP := PLSA500GCF("R504","NR_NOTA")
	BD6->BD6_LOTEDI := PLSA500GCF("R504","NR_LOTE")
	BD6->BD6_FATMUL := Val(PLSA500GCF("R504","FAT_MULT_S")) / 100 //Val(transform(PLSA500GCF("R504","FAT_MULT_S"), "@E 9.99")) 
	
	If BD6->BD6_PROCCI == "1"
		Do Case
		Case PLSA500GCF("R504","TEC_UTILIZ") == "1"
			BD6->BD6_TECUTI := 'C'
		Case PLSA500GCF("R504","TEC_UTILIZ") == "2"
			BD6->BD6_TECUTI := 'V'
		Case PLSA500GCF("R504","TEC_UTILIZ") == "3"
			BD6->BD6_TECUTI := 'R'
		Case Empty(PLSA500GCF("R504","TEC_UTILIZ"))
			BD6->BD6_TECUTI :=  '1'
		EndCase
	Else
		BD6->BD6_TECUTI := ' '
	EndIf
	
	
	BD6->(MsUnLock())
	if !empty(BD6->BD6_CD_PAC) .and. alltrim(BD6->BD6_CODPRO) == getNewPar("MV_PLPACPT","99999998") 
		aadd(aPacPTU01, {BD6->BD6_CODOPE, BD6->BD6_SEQUEN, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO, BD6->BD6_ORIMOV, BD6->(recno()),StrZero(Val((PLSA500GCF("R504","NR_AUTORIZ"))),10)  } )
	endif
	
	//Esse item esta sendo chamdo apos a gração devido, quando a importação do PTU estiver 1=Material;2=Medicamento;3=Taxas;4=Diarias;5=Ortese/Protese;7=Gases Medicinais;8=Alugueis;	
	//Apos plTpServ ira chamar a função PlVlMatM essa ira reposicionar assim ocorrendo a nao conformidade
	cTpeVct := plTpServ(BD6->BD6_CODPAD, BD6->BD6_CODPRO, BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG), cAliasPLS)

	BD6->(RecLock("BD6",.F.))
	BD6->BD6_TPEVCT :=  cTpeVct
	BD6->(MsUnLock())
Else
	cUltCodigo := BR8->BR8_CODPSA
	
	If PLSA500GCF("R504","TP_TABELA") $ '0/4'
		nAux :=  val(Substr(PLSA500GCF("R504","QT_COBRADA"),1,4))
	Else
		nAux :=  Val(Substr(PLSA500GCF("R504","QT_COBRADA"),1,4)+"."+Substr(PLSA500GCF("R504","QT_COBRADA"),5,4))
	Endif
	
	//Valor apresentado e sempre liquido
	nTotAtM := BD6->BD6_VALORI
	
	If lBD6_VLTXAP
		nTtTAtM := BD6->BD6_VLTXAP
	EndIf
	
	if lAltQtd
		
		BD6->(RecLock("BD6",.F.))
			BD6->BD6_QTDPRO := nAux
		BD6->(MsUnLock())
		
	endIf
	
	BD6->(RecLock("BD6",.F.))
	
	BD6->BD6_NUMIMP := PLSA500GCF("R504","NR_NOTA")
	If BD6->(fieldPos("BD6_LOTEDI")) > 0
		BD6->BD6_LOTEDI := PLSA500GCF("R504","NR_LOTE")
	EndIf
	
	nTotApr :=	val(subs(PLSA500GCF("R504","VL_SERV_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_SERV_CO"),13,2))
	nTotApr +=	val(subs(PLSA500GCF("R504","VL_CO_COB"),1,12)+"."+Subs(PLSA500GCF("R504","VL_CO_COB"),13,2))
	nTotApr +=	val(subs(PLSA500GCF("R504","VL_FILME_C"),1,12)+"."+Subs(PLSA500GCF("R504","VL_FILME_C"),13,2))
	
	nTotTxAp := val(subs(PLSA500GCF("R504","VL_ADIC_SE"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_SE"),13,2))
	nTotTxAp += val(subs(PLSA500GCF("R504","VL_ADIC_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_CO"),13,2))
	nTotTxAp += val(subs(PLSA500GCF("R504","VL_ADIC_FI"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_FI"),13,2))
	
	BD6->BD6_VALORI := (nTotAtM + nTotApr)
	BD6->BD6_VLRAPR := BD6->BD6_VALORI / BD6->BD6_QTDPRO
	
	If lBD6_VLTXAP
		BD6->BD6_VLTXAP := (nTtTAtM + nTotTxAp)
	EndIf
	
	BD6->(MsUnLock())
	
	&(cAliasPLS)->(RecLock(cAliasPLS,.F.))
	
	&(cAliasPLS+"->"+cAliasPLS+"_NUMIMP") := PLSA500GCF("R504","NR_NOTA")
	If &(cAliasPLS+"->(FieldPos('"+cAliasPLS+"_LOTEDI')) ") > 0
		&(cAliasPLS+"->"+cAliasPLS+"_LOTEDI") := PLSA500GCF("R504","NR_LOTE")
	EndIf
	
	(cAliasPLS)->(MsUnLock())
	
Endif

//Se existir campos da tabela BX6 para versao 6.3 ou superior, cria registro

If (!Empty(PLSA500GCF("R504","NM_FORNECE")) .Or. !Empty(PLSA500GCF("R504","DET_REG_AN")) .Or. !Empty(PLSA500GCF("R504","NR_NF_FORN")))
	
	BX6->(dbSetOrder(1)) //BX6_FILIAL + BX6_CODOPE + BX6_CODLDP + BX6_CODPEG + BX6_NUMERO + BX6_ORIMOV + BX6_SEQUEN + BX6_CODPAD + BX6_CODPRO
	If !BX6->(MsSeek(xFilial("BX6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO)))
		
		BX6->(RecLock("BX6",.T.))
		//Chave da BX6
		BX6->BX6_FILIAL := xFilial("BX6")
		BX6->BX6_CODOPE := BD6->BD6_CODOPE
		BX6->BX6_CODLDP := BD6->BD6_CODLDP
		BX6->BX6_CODPEG := BD6->BD6_CODPEG
		BX6->BX6_NUMERO := BD6->BD6_NUMERO
		BX6->BX6_ORIMOV := BD6->BD6_ORIMOV
		BX6->BX6_SEQUEN := BD6->BD6_SEQUEN
		BX6->BX6_CODPAD := BD6->BD6_CODPAD
		BX6->BX6_CODPRO := BD6->BD6_CODPRO
		If Alltrim(PLSA500GCF("R504","ID_PAG_FOR")) $ "1/2"
			BX6->BX6_PAGFOR := PLSA500GCF("R504","ID_PAG_FOR")
		EndIf
		BX6->BX6_NOMFOR := PLSA500GCF("R504","NM_FORNECE")
		BX6->BX6_DREANV := PLSA500GCF("R504","DET_REG_AN")
		BX6->BX6_NNFFOR := PLSA500GCF("R504","NR_NF_FORN")
		BX6->BX6_CNPJFO := PLSA500GCF("R504","NR_CNPJ_FO")
		BX6->BX6_REGANV := PLSA500GCF("R504","NR_REG_ANV")
		
		BX6->(MsUnLock())
	EndIf
EndIf

If Empty(cNomArq)
	cNomArq := IIF(!Empty(cArquivo), Substr(cArquivo, RAT("\",cArquivo)+1, Len(cArquivo)), cNomArq)
EndIf

//e o parametro for diferente de 1 o sistema irá respeitar as composições da TDE da operadora que esta recebendo o arquivo.
If MV_PAR17 <> 1 //Pela TDE
	
	cTipoGuia := BCL->BCL_TIPGUI
	
	aRdas := PLS720IBD7(&(cAliasPLS+"->"+cAliasPLS+"_PACOTE"),BD6->BD6_VLPGMA,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODTAB,BD6->BD6_CODOPE,BD6->BD6_CODRDA,;
						BD6->BD6_REGEXE,BD6->BD6_SIGEXE,BD6->BD6_ESTEXE,BD6->BD6_CDPFRE,BD6->BD6_CODESP,BD6->(BD6_CODLOC+BD6_LOCAL),"1",BD6->BD6_SEQUEN,;
						cOriMov,cTipoGuia,BD6->BD6_DATPRO,nil,nil)
						
	BD7->(DbSetOrder(1))//BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC
	BD3->(DbSetOrder(1))
	
	cChaveBD6 := BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
	
	if BD7->( msSeek( xFilial("BD7") + cChaveBD6 ) )
		
		while ! BD7->(Eof()) .And. xFilial("BD7") + cChaveBD6 == BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
			
			BD3->(msSeek(xFilial("BD3")+BD7->BD7_CODUNM))
			aadd(aBD7,{BD3->BD3_ORDEM , BD7->(Recno()) , If(  (nI := aScan(aPriorida,{|x| alltrim(BD7->BD7_CODUNM) $ x[1] }))   > 0 , nI , 999 )})
			
			BD7->(DbSkip())
		endDo
		
	else
		aadd(aCritNota,{cNomArq,PLSA500GCF("R504","NR_LOTE")+PLSA500GCF("R504","NR_NOTA"),"48","Codigo de procedimento existente porem sem unidade definida na TDE.",cCodSer})
	endIf

endIf


aBD7 := aSort(aBD7,,,{|x,y|x[1]<y[1]})

While .T.
	
	lSwapped := .F.
	
	For nI := 1 to (Len(aBD7)-1)
		
		If aBD7[nI][3] > aBD7[nI+1][3]
			aSlvAr       := aClone(aBD7[nI])
			aBD7[nI]     := aClone(aBD7[nI+1])
			aBD7[nI + 1] := aClone(aSlvAr)
			lSwapped := .T.
		Endif
		
	Next
	
	If !lSwapped
		Exit
	Endif
	
Enddo

For nFor := 1 To Len(aBD7)
	
	BD7->(DbGoTo(aBD7[nFor,2]))
	
	nAprCheio := 0
	nTaxCheio := 0
	lFlagDel  := .T.
	lAprUsado := .F.
	cTipApr   := ""
	
	If  (AllTrim(cTpPart) == 'X' .and. AllTrim(BD7->BD7_CODUNM) $ PLSCHMP()) .or. (AllTrim(cTpPart) == '0' .and. AllTrim(cProxPart) == 'X' .and. !(AllTrim(BD7->BD7_CODUNM) $ PLSCHMP()))
		loop
	Endif
	
	If Empty(BD7->BD7_CODTPA) .And. ProcHM(AllTrim(BD7->BD7_CODUNM),AllTrim(cTpPart),BD7->BD7_NLANC,PLSA500GCF("R504","CD_PORTE_A")) .And. ! aCtrlBD7[1]
		
		BB0->(DbSetOrder(4))//BB0_FILIAL + BB0_ESTADO + BB0_NUMCR + BB0_CODSIG + BB0_CODOPE
		If !Empty(PLSA500GCF("R504","SG_CONS_PR")) .And. !Empty(PLSA500GCF("R504","NR_CONS_PR")) .And. !Empty(PLSA500GCF("R504","SG_UF_CONS"))
			If BB0->(DbSeek(xFilial("BB0")+PLSA500GCF("R504","SG_UF_CONS")+;
					Alltrim(PLSA500GCF("R504","NR_CONS_PR")) + Space(TamSX3("BB0_NUMCR")[1] - len( Alltrim(PLSA500GCF("R504","NR_CONS_PR")) ))+;
					Alltrim(PLSA500GCF("R504","SG_CONS_PR")) + Space(TamSX3("BB0_CODSIG")[1] - len( Alltrim(PLSA500GCF("R504","SG_CONS_PR")) )) ))

				lFindBB0 := .T.
			Else

				PlSveProfAll(Alltrim(PLSA500GCF("R504","NM_PROF_PR")), Alltrim(PLSA500GCF("R504","SG_CONS_PR")), PLSA500GCF("R504","SG_UF_CONS"),;
					 Alltrim(PLSA500GCF("R504","NR_CONS_PR")), cUniDes, PLSA500GCF("R504","NR_CNJP_CP"), '2', cUniOri, {},.t.)

			Endif
			lGrvPrf := .T.
		EndIf

		BD7->(RecLock("BD7",.F.))
		
		BD7->BD7_CODTPA := cTpPart
		BD7->BD7_SEQIMP := aCodSeqImp[Len(aCodSeqImp)]// Pega o ultimo código
		
		If lGrvPrf
			BD7->BD7_REGPRE := BB0->BB0_NUMCR
			BD7->BD7_SIGLA  := BB0->BB0_CODSIG
			BD7->BD7_ESTPRE := BB0->BB0_UF
			BD7->BD7_NOMPRE := BB0->BB0_NOME
		endIf
		lGrvPrf		  := .F.
		lExclui         := .F.
		lFlagDel        := .F.
		
		If lP500BLPG
			cBloPag := ExecBlock("P500BLPG",.F.,.F.,{"PPM",cBloPag})
		EndIf
		
		If ( Val(Subs(PLSA500GCF("R504","VL_SERV_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_SERV_CO"),13,2)) == 0 ) .Or. ( lUptHM .And. cTpPart == "0" )
			BD7->BD7_BLOPAG := cBloPag// O padrão é sempre 1. Grava diferente de 1  se passar pelo PE P500BLPG. Rafael Almeida 13/01/17
			lExclui         := .T.
		Endif
		
		lUptHM := .T.
		
		BD7->(MsUnLock())
		
		lAprUsado := BD7->BD7_VALORI > 0
		
		If lAprUsado
			cTipApr := "HM"
		Endif
		
		aCtrlBD7[1] := .T.
		
	Endif
	
	If ! aCtrlBD7[1] .And. ! lAprUsado
		
		nAprCheio += Val(Subs(PLSA500GCF("R504","VL_SERV_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_SERV_CO"),13,2))
		nTaxCheio += Val(Subs(PLSA500GCF("R504","VL_ADIC_SE"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_SE"),13,2))
		
		lAprUsado := nAprCheio > 0
		
		If lAprUsado
			cTipApr := "HM"
		Endif
		
	Endif
	
	If (Empty(BD7->BD7_CODTPA) .or. (!Empty(BD7->BD7_CODTPA) .and. BD7->BD7_VALORI == 0 .and. Val(Subs(PLSA500GCF("R504","VL_CO_COB"),1,12)+"."+Subs(PLSA500GCF("R504","VL_CO_COB"),13,2)) > 0) ) .And. ;
			ProcCOP(AllTrim(BD7->BD7_CODUNM),AllTrim(cTpPart)) .And. ;
			! aCtrlBD7[2] .And. ;
			! lAprUsado
		
		BD7->(RecLock("BD7",.F.))
		
		BD7->BD7_CODTPA := cTpPart
		BD7->BD7_SEQIMP := cCodSeq
		
		lExclui         := .F.
		lFlagDel        := .F.
		
		If lP500BLPG
			cBloPag := ExecBlock("P500BLPG",.F.,.F.,{"CO",cBloPag})
		EndIf
		
		If Val(Subs(PLSA500GCF("R504","VL_CO_COB"),1,12)+"."+Subs(PLSA500GCF("R504","VL_CO_COB"),13,2)) == 0
			BD7->BD7_BLOPAG := cBloPag// O padrão é sempre 1. Grava diferente de 1  se passar pelo PE P500BLPG. Rafael Almeida 13/01/17
			lExclui         := .T.
		Endif
		
		aCtrlBD7[2] := .T.
		
		BD7->(MsUnLock())
		
		lAprUsado := BD7->BD7_VALORI > 0
		
		If lAprUsado
			cTipApr := "CO"
			
			If BD7->BD7_BLOPAG == '1'
				
				BD7->(RecLock("BD7",.F.))
				
					PLBLOPC("BD7", .f.)
					
				BD7->(MsUnLock())
				
			Endif
		Endif
		
	Endif
	
	If ! aCtrlBD7[2] .And. ! lAprUsado
		
		nAprCheio += Val(Subs(PLSA500GCF("R504","VL_CO_COB"),1,12)+"."+Subs(PLSA500GCF("R504","VL_CO_COB"),13,2))
		nTaxCheio += Val(Subs(PLSA500GCF("R504","VL_ADIC_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_CO"),13,2))
		lAprUsado := nAprCheio > 0
		
		If lAprUsado
			cTipApr := "CO"
		Endif
		
	Endif
	
	If (Empty(BD7->BD7_CODTPA) .or. (!Empty(BD7->BD7_CODTPA) .and. BD7->BD7_VALORI == 0 .and. Val(Subs(PLSA500GCF("R504","VL_FILME_C"),1,12)+"."+Subs(PLSA500GCF("R504","VL_FILME_C"),13,2)) > 0) ) .And. ;
			ProcFIL(AllTrim(BD7->BD7_CODUNM),AllTrim(cTpPart)) .And. ;
			! aCtrlBD7[3] .And. ;
			! lAprUsado
		
		BD7->(RecLock("BD7",.F.))
		
		BD7->BD7_CODTPA := cTpPart
		BD7->BD7_SEQIMP := cCodSeq
		
		lExclui         := .F.
		lFlagDel        := .F.
		
		If lP500BLPG
			cBloPag := ExecBlock("P500BLPG",.F.,.F.,{"FILME",cBloPag})
		EndIf
		
		If Val(Subs(PLSA500GCF("R504","VL_FILME_C"),1,12)+"."+Subs(PLSA500GCF("R504","VL_FILME_C"),13,2)) == 0
			BD7->BD7_BLOPAG := cBloPag// O padrão é sempre 1. Grava diferente de 1  se passar pelo PE P500BLPG. Rafael Almeida 13/01/17
			lExclui         := .T.
		Endif
		
		aCtrlBD7[3] := .T.
		
		BD7->(MsUnLock())
		
		lAprUsado := BD7->BD7_VALORI > 0
		
		If lAprUsado
			
			cTipApr := "FI"
			
			If BD7->BD7_BLOPAG == '1'
				
				BD7->(RecLock("BD7",.F.))
				
					PLBLOPC("BD7", .f.)
				
				BD7->(MsUnLock())
			Endif
		Endif
		
	Endif
	
	If ! aCtrlBD7[3] .And. ! lAprUsado
		
		nAprCheio += Val(Subs(PLSA500GCF("R504","VL_FILME_C"),1,12)+"."+Subs(PLSA500GCF("R504","VL_FILME_C"),13,2))
		nTaxCheio += Val(Subs(PLSA500GCF("R504","VL_ADIC_FI"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_FI"),13,2))
		lAprUsado := nAprCheio > 0
		
		If lAprUsado
			cTipApr := "FI"
		Endif
		
	Endif
	
	If BD7->BD7_VALORI == 0 .And. (nAprCheio+nTaxCheio) > 0 .And.;
			( (ProcHM(AllTrim(BD7->BD7_CODUNM),AllTrim(cTpPart),BD7->BD7_NLANC,PLSA500GCF("R504","CD_PORTE_A")) .And. cTipApr == "HM") .or.;
			(ProcFIL(AllTrim(BD7->BD7_CODUNM),AllTrim(cTpPart)) .And. cTipApr == "FI") .or.;
			(ProcCOP(AllTrim(BD7->BD7_CODUNM),AllTrim(cTpPart))  .And. cTipApr == "CO" ) )
		
		If cTipApr == "HM" .And. ! aCtrlBD7[1]
			aCtrlBD7[1] := .T.
		Endif
		
		If cTipApr == "CO" .And. ! aCtrlBD7[2]
			aCtrlBD7[2] := .T.
		Endif
		
		If cTipApr == "FI" .And. ! aCtrlBD7[3]
			aCtrlBD7[3] := .T.
		Endif
		
	Endif
	
	If lAltQtd  .And. alltrim(BD7->BD7_CODTPA) == AllTrim(cTpPart) .and. nImpBD6 == '0'
		
		nTotAtM := BD7->BD7_VALORI
		nTtTAtM := BD7->BD7_VLTXAP
		
		If ProcCOP(AllTrim(BD7->BD7_CODUNM),AllTrim(cTpPart))
			
			If PLSA500GCF("R504","TP_TABELA") $ '0/4'
				nQtdPro := val(Substr(PLSA500GCF("R504","QT_COBRADA"),1,4))
			Else
				nQtdPro := Val(Substr(PLSA500GCF("R504","QT_COBRADA"),1,4)+"."+Substr(PLSA500GCF("R504","QT_COBRADA"),5,4))
			EndIf
			
			nTotApr := Val(Subs(PLSA500GCF("R504","VL_CO_COB"),1,12)+"."+Subs(PLSA500GCF("R504","VL_CO_COB"),13,2))
			nToTaAp := Val(Subs(PLSA500GCF("R504","VL_ADIC_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_CO"),13,2))
			
		ElseIf ProcFIL(AllTrim(BD7->BD7_CODUNM),AllTrim(cTpPart))
			
			If PLSA500GCF("R504","TP_TABELA") $ '0/4'
				nQtdPro := val(Substr(PLSA500GCF("R504","QT_COBRADA"),1,4))
			Else
				nQtdPro := Val(Substr(PLSA500GCF("R504","QT_COBRADA"),1,4)+"."+Substr(PLSA500GCF("R504","QT_COBRADA"),5,4))
			EndIf
			
			nTotApr := Val(Subs(PLSA500GCF("R504","VL_FILME_C"),1,12)+"."+Subs(PLSA500GCF("R504","VL_FILME_C"),13,2))
			nToTaAp := Val(Subs(PLSA500GCF("R504","VL_ADIC_FI"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_FI"),13,2))
			
		ElseIf ProcHM(AllTrim(BD7->BD7_CODUNM),AllTrim(cTpPart),BD7->BD7_NLANC,PLSA500GCF("R504","CD_PORTE_A"))
			
			If PLSA500GCF("R504","TP_TABELA") $ '0/4'
				nQtdPro := val(Substr(PLSA500GCF("R504","QT_COBRADA"),1,4))
			Else
				nQtdPro := Val(Substr(PLSA500GCF("R504","QT_COBRADA"),1,4)+"."+Substr(PLSA500GCF("R504","QT_COBRADA"),5,4))
			EndIf
			
			nTotApr := Val(Subs(PLSA500GCF("R504","VL_SERV_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_SERV_CO"),13,2))
			nToTaAp := Val(Subs(PLSA500GCF("R504","VL_ADIC_SE"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_SE"),13,2))
			
		Endif
		
	Endif
		
next


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//Tratamento para efetuar a importaçõa de acordo com as compições enviado pela operadora origem
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If MV_PAR17 == 1  .and.  Len(aBD7) == 0
	
	If lAltQtd
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//qui sera realizado a limpeza do BD7  para que o sistema inclua
		//s informações referente ao que vem no arquivo, n? sendo necessario
		//ados digitados pela operdadora de Recebimento.
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		
		If lDelBd7Rec
			DbSelectArea("BD7")
			BD7->(DbSetOrder(2))
			If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD)))
				While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD) == ;
						xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD)
					
					If ! Ascan(aBD7Ger,{|x| x[1] == BD7->(Recno())}) > 0
						BD7->(RecLock("BD7",.F.))
						BD7->(DbDelete())
						BD7->(MsUnLock())
					EndIf
					BD7->(DbSkip())
				Enddo
				lDelBd7Rec:=.F.
			Endif
		Endif
		
	Endif
	
	aRegBd7Im	:={}
	If PLSA500GCF("R504","ID_AVISO") == "S" .AND. Val(Subs(PLSA500GCF("R504","VL_SERV_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_SERV_CO"),13,2)) == 0 .AND. Val(Subs(PLSA500GCF("R504","VL_CO_COB"),1,12)+"."+Subs(PLSA500GCF("R504","VL_CO_COB"),13,2)) == 0 .AND. Val(Subs(PLSA500GCF("R504","VL_FILME_C"),1,12)+"."+Subs(PLSA500GCF("R504","VL_FILME_C"),13,2)) == 0
		lAllBlq := .t.
	endIf
	
	If ( Val(Subs(PLSA500GCF("R504","VL_SERV_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_SERV_CO"),13,2)) > 0 ) //HM
		
		nVlrAJius	:= val(Subs(PLSA500GCF("R504","VL_SERV_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_SERV_CO"),13,2))
		nVlrAdic 	:= val(Subs(PLSA500GCF("R504","VL_ADIC_SE"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_SE"),13,2))
		nVlrTApr 	:= val(Subs(PLSA500GCF("R504","VL_SERV_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_SERV_CO"),13,2))
		nVlrTXpap  	:= val(Subs(PLSA500GCF("R504","VL_ADIC_SE"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_SE"),13,2))
		
		cCodUnmBd7 	:= "HM"
		cUnidBd4	:= ""
		
		lHaUnBd4	:=	.F.
		BD3->(DBSetOrder(1))
		BD4->(DbSetOrder(1))
		cUnidBd4 := "HM"
		
		For xy := 1 to Len(aTpParBkc)
		
			If BD4->(DbSeek(xFilial("BD4")+BD6->BD6_CODOPE+BD6->BD6_CODTAB+BD6->BD6_CODPAD+BD6->BD6_CODPRO+aTpParBkc[xy]))
				While !BD4->(Eof()) .And. BD4->BD4_CODTAB == BD6->BD6_CODOPE+BD6->BD6_CODTAB .And. BD4->BD4_CDPADP == BD6->BD6_CODPAD .And. BD4->BD4_CODPRO == BD6->BD6_CODPRO .And. BD4->BD4_CODIGO == aTpParBkc[xy] 

					If PLSINTval("BD4","BD4_VIGINI","BD4_VIGFIM",dDataPro)

						cUnidBd4 := BD4->BD4_CODIGO
						lHaUnBd4 := .T.
				
						If Substr(cUnidBd4,1,2) == "HM"
							BD3->(MsSeek(xFilial("BD3")+BD4->BD4_CODIGO))
							exit
						Endif
					EndIf
				BD4->(Dbskip())					
				EndDo							
			Endif
						
		Next xy
		
		If !lHaUnBd4 
			BD4->(DbSetOrder(2))
			cUnidBd4 := "HM"
			For xy := 1 to Len(aTpParBkc)
				If BD4->(DbSeek(xFilial("BD4")+BD6->BD6_CODPRO))
					While !BD4->(Eof()) .And. BD4->BD4_CODPRO == BD6->BD6_CODPRO
						
						If BD4->BD4_CDPADP == BD6->BD6_CODPAD .And. BD4->BD4_CODIGO == aTpParBkc[xy] .And. ;
								((( dtos(dDataPro) >= dtos(BD4->BD4_VIGINI) ) .And. ;
								( dtos(dDataPro) <= dtos(BD4->BD4_VIGFIM) .Or. Empty(BD4->BD4_VIGFIM) ) ) .Or. ;
								( Empty(BD4->BD4_VIGINI) .And. Empty(BD4->BD4_VIGFIM) ))
							
							
							cUnidBd4 := BD4->BD4_CODIGO
							BD3->(MsSeek(xFilial("BD3")+BD4->BD4_CODIGO))
							lHaUnBd4 := .T.
							exit
						Endif
						BD4->(Dbskip())
					Enddo
				Endif
				If lHaUnBd4
					Exit
				Endif
			Next xy
		Endif
		cUnidBd4 := iif(alltrim(BD6->BD6_CODPRO) == getNewPar("MV_PLPACPT","99999998"),"HMR",cUnidBd4)
		AaDd(aRegBd7Im,{iif(alltrim(BD6->BD6_CODPRO) == getNewPar("MV_PLPACPT","99999998"),"HMR","HM"),nVlrTApr,nVlrTXpap,cUnidBd4,cTpPart,AllTrim(PLSA500GCF("R504","TP_PARTICI")),BD3->BD3_UNIDAD,PLSA500GCF("R504","NR_SEQ"),nVlrAJius,nVlrAdic})
		
	Endif
	
	If Val(Subs(PLSA500GCF("R504","VL_CO_COB"),1,12)+"."+Subs(PLSA500GCF("R504","VL_CO_COB"),13,2)) > 0 //COP
		
		nVlrAJius	:= Val(Subs(PLSA500GCF("R504","VL_CO_COB"),1,12)+"."+Subs(PLSA500GCF("R504","VL_CO_COB"),13,2))
		nVlrAdic 	:= Val(Subs(PLSA500GCF("R504","VL_ADIC_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_CO"),13,2))
		nVlrTApr 	:= Val(Subs(PLSA500GCF("R504","VL_CO_COB"),1,12)+"."+Subs(PLSA500GCF("R504","VL_CO_COB"),13,2))
		nVlrTApr 	:= Round(nVlrTApr,nTamBD7)
		nVlrTXpap 	:= Val(Subs(PLSA500GCF("R504","VL_ADIC_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_CO"),13,2))
		cCodUnmBd7 	:= "COP"
		
		cUnidBd4	:= ""
		
		lHaUnBd4	:= .F.
		BD3->(DBSetOrder(1))
		BD4->(DbSetOrder(1))
		cUnidBd4 := "COP"
		For xy := 1 to Len(aTpParCOP)
			If BD4->(DbSeek(xFilial("BD4")+BD6->BD6_CODOPE+BD6->BD6_CODTAB+BD6->BD6_CODPAD+BD6->BD6_CODPRO+aTpParCOP[xy]))
			
				While !BD4->(Eof()) .And. BD4->BD4_CODTAB == BD6->BD6_CODOPE+BD6->BD6_CODTAB .And. BD4->BD4_CDPADP == BD6->BD6_CODPAD .And. BD4->BD4_CODPRO == BD6->BD6_CODPRO .And. BD4->BD4_CODIGO == aTpParCOP[xy] 

					If PLSINTval("BD4","BD4_VIGINI","BD4_VIGFIM",dDataPro)
					
						cUnidBd4 := BD4->BD4_CODIGO
						lHaUnBd4 := .T.
						If Substr(cUnidBd4,1,2) == "CO"
							BD3->(MsSeek(xFilial("BD3")+BD4->BD4_CODIGO))
							exit
						Endif
					EndIf	
					BD4->(Dbskip())
				Enddo
			Endif
		Next xy
		
		If !lHaUnBd4
			BD4->(DbSetOrder(2))
			cUnidBd4 := "COP"
			For xy:=1 to Len(aTpParCOP)
				If BD4->(DbSeek(xFilial("BD4")+BD6->BD6_CODPRO))
					While !BD4->(Eof()) .And. BD4->BD4_CODPRO == BD6->BD6_CODPRO
						
						If BD4->BD4_CDPADP == BD6->BD6_CODPAD .And. BD4->BD4_CODIGO == aTpParCOP[xy] .And. ;
								((( dtos(dDataPro) >= dtos(BD4->BD4_VIGINI) ) .And. ;
								( dtos(dDataPro) <= dtos(BD4->BD4_VIGFIM) .Or. Empty(BD4->BD4_VIGFIM) ) ) .Or. ;
								( Empty(BD4->BD4_VIGINI) .And. Empty(BD4->BD4_VIGFIM) ))
							
							cUnidBd4 := BD4->BD4_CODIGO
							BD3->(MsSeek(xFilial("BD3")+BD4->BD4_CODIGO))
							lHaUnBd4 := .T.
							exit
						Endif
						BD4->(Dbskip())
					Enddo
				Endif
				If lHaUnBd4
					Exit
				Endif
			Next xy
		Endif
		cUnidBd4 := iif(alltrim(BD6->BD6_CODPRO) == getNewPar("MV_PLPACPT","99999998"),"COR",cUnidBd4)
		AaDd(aRegBd7Im,{iif(alltrim(BD6->BD6_CODPRO) == getNewPar("MV_PLPACPT","99999998"),"COR","COP"),nVlrTApr,nVlrTXpap,cUnidBd4,cTpPart,AllTrim(PLSA500GCF("R504","TP_PARTICI")),BD3->BD3_UNIDAD,PLSA500GCF("R504","NR_SEQ"),nVlrAJius,nVlrAdic})
	Endif
	
	If Val(Subs(PLSA500GCF("R504","VL_FILME_C"),1,12)+"."+Subs(PLSA500GCF("R504","VL_FILME_C"),13,2)) > 0 //FIL
		
		nVlrAJius	:= Val(Subs(PLSA500GCF("R504","VL_FILME_C"),1,12)+"."+Subs(PLSA500GCF("R504","VL_FILME_C"),13,2))
		nVlrAdic 	:= Val(Subs(PLSA500GCF("R504","VL_ADIC_FI"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_FI"),13,2))
		nVlrTApr 	:= Val(Subs(PLSA500GCF("R504","VL_FILME_C"),1,12)+"."+Subs(PLSA500GCF("R504","VL_FILME_C"),13,2))
		nVlrTApr	:= Round(nVlrTApr,nTamBD7)
		nVlrTXpap 	:= Val(Subs(PLSA500GCF("R504","VL_ADIC_FI"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_FI"),13,2))
		
		cCodUnmBd7 	:= 	"FIL"
		
		AaDd(aRegBd7Im,{"FIL",nVlrTApr,nVlrTXpap,"FIL",cTpPart,AllTrim(PLSA500GCF("R504","TP_PARTICI")),BD3->BD3_UNIDAD,PLSA500GCF("R504","NR_SEQ"),nVlrAJius,nVlrAdic})
		
	Endif
	// Esse item se faz necessario para n? gerar varios bd7 e bd7 devido que no arquivo de importação do ptu esta por tipo de participação.
	If lCriaBD6
		P500GeraBd7(BD6->BD6_CODTAB,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODOPE,BD6->BD6_DATPRO,cOriMov,cCodUnmBd7,nVlrTApr,nVlrTXpap,cTpPart,aRegBd7Im,@aBD7Ger, lAllBlq)
	Else
		If BD7->(MsSeek((BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+cOriMov+BD6_SEQUEN))))
			
			While !BD7->(Eof()) .and.  BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODPEG+BD7_CODLDP+BD7_NUMERO+cOriMov+BD7_SEQUEN) == BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODPEG+BD6_CODLDP+BD6_NUMERO+cOriMov+BD6_SEQUEN)
				
				If  BD6->BD6_NUMERO == BD7->BD7_NUMERO .and. BD6->BD6_SEQUEN == BD7->BD7_SEQUEN  .AND. Alltrim(BD7->BD7_CODUNM) ==  cUnidBd4 .And. !cUnidBd4 $ cMVPLSCAUX
					lGerBd7 := .F.
				Endif
				
				BD7->(DbSkip())
			Enddo
			
			If lGerBd7
				P500GeraBd7(BD6->BD6_CODTAB,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODOPE,BD6->BD6_DATPRO,cOriMov,cCodUnmBd7,nVlrTApr,nVlrTXpap,cTpPart,aRegBd7Im,@aBD7Ger)
			Endif
		Else
			P500GeraBd7(BD6->BD6_CODTAB,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODOPE,BD6->BD6_DATPRO,cOriMov,cCodUnmBd7,nVlrTApr,nVlrTXpap,cTpPart,aRegBd7Im,@aBD7Ger)
		Endif
	Endif
	
	lGerBd7 := .T.
	
Endif

If lExB5T_B6T .And. nRecnoB5T > 0
	nVlrEvent := Val(Subs(PLSA500GCF("R504","VL_SERV_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_SERV_CO"),13,2))
	nVlrEvent += Val(Subs(PLSA500GCF("R504","VL_CO_COB"),1,12)+"."+Subs(PLSA500GCF("R504","VL_CO_COB"),13,2))
	nVlrEvent += Val(Subs(PLSA500GCF("R504","VL_FILME_C"),1,12)+"."+Subs(PLSA500GCF("R504","VL_FILME_C"),13,2))
	
	nVlrTaxa :=  Val(Subs(PLSA500GCF("R504","VL_ADIC_SE"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_SE"),13,2))
	nVlrTaxa +=  Val(Subs(PLSA500GCF("R504","VL_ADIC_CO"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_CO"),13,2))
	nVlrTaxa +=  Val(Subs(PLSA500GCF("R504","VL_ADIC_FI"),1,12)+"."+Subs(PLSA500GCF("R504","VL_ADIC_FI"),13,2))
		
	PLPTAtuB6T(nVlrEvent,nVlrTaxa,nRecnoB5T)
EndIf

If ExistBlock("PLS500CG")
	ExecBlock("PLS500CG",.F.,.F.)
Endif

RestArea(aArea)

Return

/*/{Protheus.doc} AtuGIHR502
Atualiza campos na GIH a partir do registro R502
@author Microsiga
@since 17.01.2005
@version P12
/*/
Static Function AtuGIHR502(cTpAdm,cLayPLS,cNomArq)
LOCAL cAuxDat  := ""
LOCAL dDatAlta
LOCAL cHorAlta := ""
LOCAL cAux1Dat := ""
LOCAL dDatPro
LOCAL cHorPro  := ""
LOCAL nDiasIN  := 0
LOCAL cTpAdmAux:= ""
LOCAL cGuiJur  := ""

DEFAULT cTpAdm := ""

//Campos de Faturamento Inicial e Final foram alterados na versao 6.0

cAuxDat  := PLSA500GCF("R502","DT_FIM_FAT")
cAux1Dat := PLSA500GCF("R502","DT_INI_FAT")
cGuiJur  := PLSA500GCF("R502","ID_LIMINAR")

dDatAlta := ctod(subs(cAuxDat,9,2)+"/"+subs(cAuxDat,6,2)+"/"+subs(cAuxDat,1,4))
cHorAlta := subs(cAuxDat,11,2)+subs(cAuxDat,14,2)
dDatPro  := ctod(subs(cAux1Dat,9,2)+"/"+subs(cAux1Dat,6,2)+"/"+subs(cAux1Dat,1,4))

BE4->(RecLock("BE4",.F.))
BE4->BE4_AUDITO := "0"
BE4->BE4_TIPPAR := ""

//TP_CARATER_ATEND - Tipo de carater de atendimento

If BDR->(FieldPos("BDR_CODEDI")) > 0
	
	If Empty(cTpAdmAux) .Or. aErrVarVin[1]
		cTpAdmAux := PLSVARVINC('23',, PLSA500GCF("R502","TP_CARATER","047"))
		DbSelectArea("BDR")
		BDR->(DbGoTop())
		While !BDR->(Eof())
			If cTpAdm == "1" .And. BDR->BDR_CODEDI == "1"//Eletivo
				cTpAdmAux := BDR->BDR_CODTAD
				Exit
			EndIf
			
			If cTpAdm == "2" .And. BDR->BDR_CODEDI == "2"//Urgencia/Emergencia
				cTpAdmAux := BDR->BDR_CODTAD
				Exit
			EndIf
			BDR->(DbSkip())
		EndDo
	EndIf
	
	If !Empty(cTpAdmAux) //Alimenta o campo
		BE4->BE4_TIPADM := cTpAdmAux
	EndIf

	//Regra antiga
	If Empty(cTpAdmAux)
		BDR->(dbSetOrder(3))
		If BDR->(MsSeek(xFilial("BDR")+cTpAdm))
			BE4->BE4_TIPADM := BDR->BDR_CODTAD
		Else
			BE4->BE4_TIPADM := '0'
		EndIf
	EndIf
Else
	BE4->BE4_TIPADM := '0'
EndIf

//TP_IND_ACIDENTE - Tipo de indicador de acidente
Do Case
Case PLSA500GCF("R502","TP_IND_ACI") == "0" // 09-Nao informado
	BE4->BE4_INDACI := ""
Case PLSA500GCF("R502","TP_IND_ACI") == "1" // 1-Acidente do trabalho
	BE4->BE4_INDACI := "0"
Case PLSA500GCF("R502","TP_IND_ACI") == "2" // 2-Acidente de transito
	BE4->BE4_INDACI := "1"
Case PLSA500GCF("R502","TP_IND_ACI") == "3" // 3-Acidente - outros
	BE4->BE4_INDACI := "2"
Case PLSA500GCF("R502","TP_IND_ACI") == "9" // 4-Nao acidente
	BE4->BE4_INDACI := "9"
EndCase

If Len(aDadUsr) > 0 .and. aDadUsr[1]
	BE4->BE4_PADCON := PLSACOMUSR(aDadUsr[2],'2')
Endif

//Verifica periodo de internacao

nDiasIN := (BE4->BE4_DTALTA-BE4->BE4_DATPRO)+1
If nDiasIN >= 99 .Or. nDiasIN <= 0
	aadd(aCritNota,{cNomArq,PLSA500GCF("R503","NR_LOTE")+PLSA500GCF("R503","NR_NOTA"),"47","Campo data de internacao x data de alta invalido na guia de internacao.",""})
Else
	BE4->BE4_DIASIN := nDiasIN
Endif

//MOTIVO_ENCERRAM
BE4->BE4_STATUS := "1"
BE4->BE4_DTALTA := dDatAlta
BE4->BE4_HRALTA := cHorAlta
BE4->BE4_DATPRO := dDatPro

If !Empty(cGuijur)
	
	If cGuijur == "S"
		BE4->BE4_GUIJUR := "1"
	Else
		BE4->BE4_GUIJUR	 := "0"
	EndIf
	
EndIf

//Horario dos Eventos

If Len(BE4->BE4_HORPRO) == 6
	cHorPro := subs(cAux1Dat,11,2)+subs(cAux1Dat,14,2)+subs(cAux1Dat,17,2)
Else
	cHorPro := subs(cAux1Dat,11,2)+subs(cAux1Dat,14,2)
EndIf

BE4->BE4_HORPRO := cHorPro

//Data de Faturamtento Inicial e Final TISS 3.00.00

If PLSA500GCF("R502","NR_VER_TIS") >= "3.00.00"
	BE4->BE4_DTINIF := ctod(subs(PLSA500GCF("R502","DT_INI_FAT"),9,2)+"/"+subs(PLSA500GCF("R502","DT_INI_FAT"),6,2)+"/"+subs(PLSA500GCF("R502","DT_INI_FAT"),1,4))
	BE4->BE4_HRINIF := subs(PLSA500GCF("R502","DT_INI_FAT"),11,2)+":"+subs(PLSA500GCF("R502","DT_INI_FAT"),14,2)
	BE4->BE4_DTFIMF := ctod(subs(PLSA500GCF("R502","DT_FIM_FAT"),9,2)+"/"+subs(PLSA500GCF("R502","DT_FIM_FAT"),6,2)+"/"+subs(PLSA500GCF("R502","DT_FIM_FAT"),1,4))
	BE4->BE4_HRFIMF := subs(PLSA500GCF("R502","DT_FIM_FAT"),11,2)+":"+subs(PLSA500GCF("R502","DT_FIM_FAT"),14,2)
EndIf

If BIY->(FieldPos("BIY_CODEDI")) > 0
	BIY->(DbSetOrder(4))//BIY_FILIAL + BIY_CODEDI
	If BIY->(DbSeek(xFilial("BIY")+PLSA500GCF("R502","MOTIVO_ENC")))
		BE4->BE4_TIPALT := Alltrim(BIY->BIY_CODSAI)
	EndIf
EndIf

BE4->(MsUnLock())
Return	
/*/{Protheus.doc} AtualizaDad
Atualiza campos na GIH a partir do registro R503
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Function AtuGIHR503()
LOCAL nY	   := 0
LOCAL lTisVer  := .F.
LOCAL lLayVer11     := Val(cCodLayPLS) >= 11

BE4->(RecLock("BE4",.F.))
BE4->BE4_AUDITO := "0"

//TP_INTERNACAO - Tipo de Internação

If Len(aCodEdi) == 0 .and. BQR->(FieldPos("BQR_CODEDI")) > 0
	BQR->(dbSetOrder(1))
	If BQR->(MsSeek(xFilial("BQR")))
		While BQR->(!Eof()) .and. xFilial("BQR") == BQR->BQR_FILIAL
			aadd(aCodEdi,{BQR->BQR_CODEDI,BQR->BQR_GRPINT,BQR->BQR_TIPINT})
			BQR->(DbSkip())
		Enddo
	Endif
Endif

If ExistBlock("PLS500IN")
	ExecBlock("PLS500IN",.F.,.F.,{ PLSA500GCF("R503","TP_INTERNA") })
Else
	If (nY := aScan(aCodEdi,{|x| alltrim(x[1]) == alltrim(PLSA500GCF("R503","TP_INTERNA"))})) > 0
		BE4->BE4_GRPINT := aCodEdi[nY][2]
		BE4->BE4_TIPINT := aCodEdi[nY][3]
	Else
		Do Case
		Case PLSA500GCF("R503","TP_INTERNA") == "1" // Internacao Clinica
			BE4->BE4_GRPINT := "1"
			BE4->BE4_TIPINT := "01"
		Case PLSA500GCF("R503","TP_INTERNA") == "6" // Pediatrica
			BE4->BE4_GRPINT := "1"
			BE4->BE4_TIPINT := "02"
		Case PLSA500GCF("R503","TP_INTERNA") == "7" // Psiquiatrica
			BE4->BE4_GRPINT := "1"
			BE4->BE4_TIPINT := "03"
		Case PLSA500GCF("R503","TP_INTERNA") == "3" // Internacao Obstetrica
			BE4->BE4_GRPINT := "1"
			BE4->BE4_TIPINT := "05"
		Case PLSA500GCF("R503","TP_INTERNA") == "2" // Internacao Cirurgica
			BE4->BE4_GRPINT := "2"
			BE4->BE4_TIPINT := "01"
		Case PLSA500GCF("R503","TP_INTERNA") == "3" // Internacao Obstetrica
			BE4->BE4_GRPINT := "2"
			BE4->BE4_TIPINT := "03"
		EndCase
	Endif
EndIf

//TP_ACOMODACAO - Tipo de acomodação.
//A == coletivo
//B == Individual
BE4->BE4_PADINT := FindTpAco(AllTrim(PLSA500GCF("R503","TP_ACOMODA"))) //Iif( == "A" ,"02" ,"01")

If PLSA500GCF("R503","TP_FATURA","031") == "1"
	BE4->BE4_TIPFAT := "4"
ElseIf PLSA500GCF("R503","TP_FATURA","031") == "2"
	BE4->BE4_TIPFAT := "1"
ElseIf PLSA500GCF("R503","TP_FATURA","031") == "3"
	BE4->BE4_TIPFAT := "2"
ElseIf PLSA500GCF("R503","TP_FATURA","031") == "4"
	BE4->BE4_TIPFAT := "3"
EndIf

BE4->BE4_CGCRDA := PLSA500GCF("R503","CGC_HOSPIT")

If PLSA500GCF("R503","TP_OBTMULH","039") <> "0"
	BE4->BE4_OBTMUL	:= PLSA500GCF("R503","TP_OBTMULH","039")
Else
	BE4->BE4_OBTMUL	:= ""
EndIf

BE4->BE4_REGINT := PLSA500GCF("R503","REG_INTERN")

if !lLayVer11
	Do Case
		Case PLSA500GCF("R503","ID_OBT1","022") == "S"
			BE4->BE4_TIPNAS := '01'
		Case PLSA500GCF("R503","ID_OBT2","023") == "S"
			BE4->BE4_TIPNAS := '02'
		Case PLSA500GCF("R503","ID_OBT3","024") == "S"
			BE4->BE4_TIPNAS := '06'
		Case PLSA500GCF("R503","ID_OBT4","025") == "S"
			BE4->BE4_TIPNAS := '07'
		Case PLSA500GCF("R503","ID_OBT5","026") == "S"
			BE4->BE4_TIPNAS := '08'
		Case PLSA500GCF("R503","ID_OBT6","027") == "S"
			BE4->BE4_TIPNAS := '09'
		Case PLSA500GCF("R503","ID_OBT7","028") == "S"
			BE4->BE4_TIPNAS := '10'
		Case PLSA500GCF("R503","ID_OBT8","029") == "S"
			BE4->BE4_TIPNAS := '11'
		Case PLSA500GCF("R503","ID_OBT9","030") == "S"
			BE4->BE4_TIPNAS := '12'
	EndCase

	BE4->BE4_NASVIV := val(PLSA500GCF("R503","QT_NAVIVOS","017"))
	BE4->BE4_NASMOR := val(PLSA500GCF("R503","QT_NAMORTO","018"))
	BE4->BE4_NASVPR := val(PLSA500GCF("R503","QT_NAVIVOP","019"))
	BE4->BE4_OBTPRE := val(PLSA500GCF("R503","QT_OBITOPR","020"))
	BE4->BE4_OBTTAR := val(PLSA500GCF("R503","QT_OBITOTR","021"))
endif

BE4->BE4_NRDCOB := PLSA500GCF("R503","NR_DECOBT","040")
BE4->BE4_NRDCNV := PLSA500GCF("R503","NR_VIVO1") + ;
		iif(!empty(val(PLSA500GCF("R503","NR_VIVO2"))),","+PLSA500GCF("R503","NR_VIVO2"),"") + ;		 	 
		iif(!empty(val(PLSA500GCF("R503","NR_VIVO3"))),","+PLSA500GCF("R503","NR_VIVO3"),"") + ;
		iif(!empty(val(PLSA500GCF("R503","NR_VIVO4"))),","+PLSA500GCF("R503","NR_VIVO4"),"") + ; 
		iif(!empty(val(PLSA500GCF("R503","NR_VIVO5"))),","+PLSA500GCF("R503","NR_VIVO5"),"")

//Medicos e Enfermeiros Auditores
BE4->BE4_RMAUDI := Alltrim(PLSA500GCF("R503","NR_CR_AUD"))
BE4->BE4_NMAUDI := Alltrim(PLSA500GCF("R503","NM_MED_AUD"))
BE4->BE4_REAUDI := Alltrim(PLSA500GCF("R503","NR_COREN_A"))
BE4->BE4_NEAUDI := Alltrim(PLSA500GCF("R503","NM_ENF_AUD"))

if BE4->(fieldPos("BE4_UMAUDI")) > 0
	BE4->BE4_UMAUDI := allTrim(PLSA500GCF("R503","CD_UF_CRM"))
endIf
	
if BE4->(fieldPos("BE4_UEAUDI")) > 0
	BE4->BE4_UEAUDI := Alltrim(PLSA500GCF("R503","CD_UF_CORE"))
endIf

BE4->(MsUnLock())
	
Return


/*/{Protheus.doc} PLSED500VS

@author PLS TEAM
@since 17.01.2005
@version P12
/*/
Function PLSED500VS
	PLSED500GN("1",.T.)
Return

/*/{Protheus.doc} PLSED500GN

@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Function PLSED500GN(cTipo,lMsg,lAutoma)
LOCAL aDados   	:= {}
LOCAL lRet     	:= .F.
LOCAL cChave   	:= BRJ->BRJ_CODIGO
LOCAL nRecno   	:= BRJ->(Recno())
LOCAL nOrdem   	:= BRJ->(IndexOrd())
LOCAL aPegs    	:= {}
LOCAL cAliasTrb	:= GetNextAlias()
LOCAL lCftTit 	:= BRJ->(FieldPos("BRJ_CFTPRE")) > 0 .And. BRJ->(FieldPos("BRJ_CFTTIT")) > 0 .And. BRJ->(FieldPos("BRJ_CFTPAR")) > 0 .And. BRJ->(FieldPos("BRJ_CFTTIP")) > 0
LOCAL lPtuV60   := BRJ->(FieldPos("BRJ_TPDOC1")) > 0 .And. !Empty(BRJ->BRJ_TPDOC1)
LOCAL cStatAjius:= ""
DEFAULT lMsg := .F.
Default lAutoma := .F.

BAU->(dbSetOrder(7))
BAU->(MsSeek(xFilial("BAU")+BRJ->BRJ_OPEORI))

aadd(aDados,{"Data da Importacao",dtoc(BRJ->BRJ_DATA)})
aadd(aDados,{"Arquivo de Importacao",AllTrim(BRJ->BRJ_ARQUIV)})
aadd(aDados,{"Operadora Origem",BRJ->BRJ_OPEORI+" - "+Alltrim(BRJ->BRJ_NOMORI)})
aadd(aDados,{"Competencia do Arquivo",BRJ->(BRJ_ANO+"/"+BRJ_MES)})
aadd(aDados,{"Competencia de Pagto",BRJ->(BRJ_ANOPAG+"/"+BRJ_MESPAG)})
aadd(aDados,{"Numero "+Iif(lPtuV60,"DOC 1","da Fatura"),BRJ->BRJ_NUMFAT})
If BRJ->(FieldPos("BRJ_DOCFI1")) > 0 .And. !Empty(BRJ->BRJ_DOCFI1)
	aadd(aDados,{"Numero Documento Fiscal 1",BRJ->BRJ_DOCFI1})
EndIf
aadd(aDados,{"Valor "+Iif(lPtuV60,"DOC 1","da Fatura"),IIf (BRJ->BRJ_TPCOB <> '2',TransForm(BRJ->BRJ_VLRFAT,PLPMONEY_P),TransForm(BRJ->BRJ_VALOR,PLPMONEY_P))})
aadd(aDados,{"Data da Emissao",dtoc(BRJ->BRJ_DTEMIS)})
aadd(aDados,{"Data de Vencimento",dtoc(BRJ->BRJ_DTVENC)})
If BRJ->(FieldPos("BRJ_TPDOC1")) > 0 .And. !Empty(BRJ->BRJ_TPDOC1)
	Do Case
	Case BRJ->BRJ_TPDOC1 == "1"
		aadd(aDados,{"Tipo do Documento 1","Fatura"})
	Case BRJ->BRJ_TPDOC1 == "2"
		aadd(aDados,{"Tipo do Documento 1","Nota Fiscal"})
	Case BRJ->BRJ_TPDOC1 == "3"
		aadd(aDados,{"Tipo do Documento 1","Nota Fiscal Eletronica"})
	EndCase
EndIf
aadd(aDados,{"",""})
aadd(aDados,{"Numero "+Iif(lPtuV60,"DOC 2","da NDC"),BRJ->BRJ_NRNDC})
If BRJ->(FieldPos("BRJ_DOCFI2")) > 0 .And. !Empty(BRJ->BRJ_DOCFI2)
	aadd(aDados,{"Numero Documento Fiscal 2",BRJ->BRJ_DOCFI2})
EndIf
aadd(aDados,{"Valor "+Iif(lPtuV60,"DOC 2","da NDC"),TransForm(BRJ->BRJ_VLRNDC,PLPMONEY_P)})
aadd(aDados,{"Data da Emissao",dtoc(BRJ->BRJ_DTENDC)})
aadd(aDados,{"Data de Vencimento",dtoc(BRJ->BRJ_DTVNDC)})
If BRJ->(FieldPos("BRJ_TPDOC2")) > 0 .And. !Empty(BRJ->BRJ_TPDOC2)
	Do Case
	Case BRJ->BRJ_TPDOC2 == "1"
		aadd(aDados,{"Tipo do Documento 2","Fatura"})
	Case BRJ->BRJ_TPDOC2 == "2"
		aadd(aDados,{"Tipo do Documento 2","Nota Fiscal"})
	Case BRJ->BRJ_TPDOC2 == "3"
		aadd(aDados,{"Tipo do Documento 2","Nota Fiscal Eletronica"})
	EndCase
EndIf
aadd(aDados,{"",""})

SE2->(DbSetOrder(1))
If BRJ->(FieldPos("BRJ_TPCOB")) > 0
	
	//Titulo tipo 1-NDC ou vazio (somente titulo de NDC)
	
	If BRJ->BRJ_TPCOB == '1'
		aadd(aDados,{"Tipo de Cobrança","1 = NDC"})
		aadd(aDados,{"",""})
		If SE2->(MsSeek(xFilial("SE2")+BRJ->(BRJ_PREE2N+BRJ_NUME2N+BRJ_PARE2N+BRJ_TIPE2N)+BAU->(BAU_CODSA2+BAU_LOJSA2)))
			aadd(aDados,{"Dados Titulo a Pagar NDC","Numero do Titulo :"+BRJ->(BRJ_PREE2N+BRJ_NUME2N+BRJ_PARE2N+BRJ_TIPE2N)+"    Vencimento "+dtoc(SE2->E2_VENCTO)+"     Valor "+Transform(SE2->E2_VALOR,PLPMONEY_M)})
		Endif
		
		//Titulo tipo 2-Ambos ou vazio (antes da atualizacao do PTU 4.1a)
		
	ElseIf Empty(BRJ->BRJ_TPCOB) .Or. BRJ->BRJ_TPCOB == '2'
		aadd(aDados,{"Tipo de Cobrança",IIF(!Empty(BRJ->BRJ_TPCOB),Iif(lPtuV60,"2 = DOC_1 (Valor do Item + Taxa Administrativa)","2 = Fatura"),"nao informada")})
		aadd(aDados,{"",""})
		If SE2->(MsSeek(xFilial("SE2")+BRJ->(BRJ_PRESE2+BRJ_NUMSE2+BRJ_PARSE2+BRJ_TIPSE2)+BAU->(BAU_CODSA2+BAU_LOJSA2)))
			aadd(aDados,{"Dados Titulo a Pagar","Numero do Titulo :"+BRJ->(BRJ_PRESE2+BRJ_NUMSE2+BRJ_PARSE2+BRJ_TIPSE2)+"    Vencimento "+dtoc(SE2->E2_VENCTO)+"     Valor "+Transform(SE2->E2_VALOR,PLPMONEY_M)})
		Endif
		
		//Titulo tipo 3-Ambos (titulos de NDC e fatura)
		
	ElseIf BRJ->BRJ_TPCOB == '3'
		aadd(aDados,{"Tipo de Cobrança",IIf(lPtuV60,"3 = DOC_1 (Taxa Administrativa) + DOC_2 (Valor do Item)","3 = Fatura + NDC")})
		aadd(aDados,{"",""})
		If SE2->(MsSeek(xFilial("SE2")+BRJ->(BRJ_PREE2N+BRJ_NUME2N+BRJ_PARE2N+BRJ_TIPE2N)+BAU->(BAU_CODSA2+BAU_LOJSA2)))
			aadd(aDados,{"Dados Titulo a Pagar "+Iif(lPtuV60,"DOC 2","NDC"),"Numero do Titulo :"+BRJ->(BRJ_PREE2N+BRJ_NUME2N+BRJ_PARE2N+BRJ_TIPE2N)+"    Vencimento "+dtoc(SE2->E2_VENCTO)+"     Valor "+Transform(SE2->E2_VALOR,PLPMONEY_M)})
		Endif
		If SE2->(MsSeek(xFilial("SE2")+BRJ->(BRJ_PRESE2+BRJ_NUMSE2+BRJ_PARSE2+BRJ_TIPSE2)+BAU->(BAU_CODSA2+BAU_LOJSA2)))
			aadd(aDados,{"Dados Titulo a Pagar "+Iif(lPtuV60,"DOC 1","FAT"),"Numero do Titulo :"+BRJ->(BRJ_PRESE2+BRJ_NUMSE2+BRJ_PARSE2+BRJ_TIPSE2)+"    Vencimento "+dtoc(SE2->E2_VENCTO)+"     Valor "+Transform(SE2->E2_VALOR,PLPMONEY_M)})
		Endif
		
	EndIf
Else
	If SE2->(MsSeek(xFilial("SE2")+BRJ->(BRJ_PRESE2+BRJ_NUMSE2+BRJ_PARSE2+BRJ_TIPSE2)+BAU->(BAU_CODSA2+BAU_LOJSA2)))
		aadd(aDados,{"Dados Titulo a Pagar","Numero do Titulo :"+BRJ->(BRJ_PRESE2+BRJ_NUMSE2+BRJ_PARSE2+BRJ_TIPSE2)+"    Vencimento "+dtoc(SE2->E2_VENCTO)+"     Valor "+Transform(SE2->E2_VALOR,PLPMONEY_M)})
	Endif
EndIf
aadd(aDados,{"",""})

SE1->(DbSetOrder(1))
If BRJ->(FieldPos("BRJ_TPCOB")) > 0
	
	//Titulo tipo 1-NDC ou vazio (somente titulo de NDC)
	
	If BRJ->BRJ_TPCOB == '1'
		If SE1->(MsSeek(xFilial("SE1")+BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))) .And. !Empty(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))
			aadd(aDados,{"Dados Titulo a Receber NDC [P]","Numero do Titulo :"+BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC)+"    Vencimento "+dtoc(SE1->E1_VENCTO)+"     Valor "+Transform(SE1->E1_VALOR,PLPMONEY_M)})
		Endif
		
		If SE1->(MsSeek(xFilial("SE1")+BRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+BRJ_CNDTIP))) .And. !Empty(BRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+BRJ_CNDTIP))
			aadd(aDados,{"Dados Titulo a Receber NDC [C]","Numero do Titulo :"+BRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+BRJ_CNDTIP)+"    Vencimento "+dtoc(SE1->E1_VENCTO)+"     Valor "+Transform(SE1->E1_VALOR,PLPMONEY_M)})
		Endif
		
		//Titulo tipo 2-Ambos ou vazio (antes da atualizacao do PTU 4.1a)
		
	ElseIf Empty(BRJ->BRJ_TPCOB) .Or. BRJ->BRJ_TPCOB == '2'
		If SE1->(MsSeek(xFilial("SE1")+BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))) .And. !Empty(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))
			aadd(aDados,{"Dados Titulo a Receber [P1]","Numero do Titulo :"+BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT)+"    Vencimento "+dtoc(SE1->E1_VENCTO)+"     Valor "+Transform(SE1->E1_VALOR,PLPMONEY_M)})
		Endif
		
		//Novos campos de faturamento Parcial 2 - PTU 7.0
		
		If SE1->(MsSeek(xFilial("SE1")+BRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+BRJ_FP2TIP))) .And. !Empty(BRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+BRJ_FP2TIP))
			aadd(aDados,{"Dados Titulo a Receber [P2]","Numero do Titulo :"+BRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+BRJ_FP2TIP)+"    Vencimento "+dtoc(SE1->E1_VENCTO)+"     Valor "+Transform(SE1->E1_VALOR,PLPMONEY_M)})
		Endif
		
		If lCftTit .And. SE1->(MsSeek(xFilial("SE1")+BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+BRJ_CFTTIP))) .And. !Empty(BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+BRJ_CFTTIP))
			aadd(aDados,{"Dados Titulo a Receber [C]","Numero do Titulo :"+BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+BRJ_CFTTIP)+"    Vencimento "+dtoc(SE1->E1_VENCTO)+"     Valor "+Transform(SE1->E1_VALOR,PLPMONEY_M)})
		Endif
		
		
		//Titulo tipo 3-Ambos (titulos de NDC e fatura)
		
	ElseIf BRJ->BRJ_TPCOB == '3'
		
		If SE1->(MsSeek(xFilial("SE1")+BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))) .And. !Empty(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))
			aadd(aDados,{"Dados Titulo a Receber "+Iif(lPtuV60,"DOC 2","NDC")+" [P1]","Numero do Titulo :"+BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC)+"    Vencimento "+dtoc(SE1->E1_VENCTO)+"     Valor "+Transform(SE1->E1_VALOR,PLPMONEY_M)})
		Endif
		
		If SE1->(MsSeek(xFilial("SE1")+BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))) .And. !Empty(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))
			aadd(aDados,{"Dados Titulo a Receber "+Iif(lPtuV60,"DOC 1","FAT")+" [P1]","Numero do Titulo :"+BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT)+"    Vencimento "+dtoc(SE1->E1_VENCTO)+"     Valor "+Transform(SE1->E1_VALOR,PLPMONEY_M)})
		Endif
		
		//Novos campos de faturamento Parcial 2 - PTU 7.0
		If SE1->(MsSeek(xFilial("SE1")+BRJ->(BRJ_NP2PRE+BRJ_NP2TIT+BRJ_NP2PAR+BRJ_NP2TIP))) .And. !Empty(BRJ->(BRJ_NP2PRE+BRJ_NP2TIT+BRJ_NP2PAR+BRJ_NP2TIP))
			aadd(aDados,{"Dados Titulo a Receber "+Iif(lPtuV60,"DOC 2","NDC")+" [P2]","Numero do Titulo :"+BRJ->(BRJ_NP2PRE+BRJ_NP2TIT+BRJ_NP2PAR+BRJ_NP2TIP)+"    Vencimento "+dtoc(SE1->E1_VENCTO)+"     Valor "+Transform(SE1->E1_VALOR,PLPMONEY_M)})
		Endif
		
		If SE1->(MsSeek(xFilial("SE1")+BRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+BRJ_FP2TIP))) .And. !Empty(BRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+BRJ_FP2TIP))
			aadd(aDados,{"Dados Titulo a Receber "+Iif(lPtuV60,"DOC 1","FAT")+" [P2]","Numero do Titulo :"+BRJ->(BRJ_FP2PRE+BRJ_FP2TIT+BRJ_FP2PAR+BRJ_FP2TIP)+"    Vencimento "+dtoc(SE1->E1_VENCTO)+"     Valor "+Transform(SE1->E1_VALOR,PLPMONEY_M)})
		Endif
		
		
		If SE1->(MsSeek(xFilial("SE1")+BRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+BRJ_CNDTIP))) .And. !Empty(BRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+BRJ_CNDTIP))
			aadd(aDados,{"Dados Titulo a Receber "+Iif(lPtuV60,"DOC 2","NDC")+" [C]","Numero do Titulo :"+BRJ->(BRJ_CNDPRE+BRJ_CNDTIT+BRJ_CNDPAR+BRJ_CNDTIP)+"    Vencimento "+dtoc(SE1->E1_VENCTO)+"     Valor "+Transform(SE1->E1_VALOR,PLPMONEY_M)})
		Endif
		
		If SE1->(MsSeek(xFilial("SE1")+BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+BRJ_CFTTIP))) .And. !Empty(BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+BRJ_CFTTIP))
			aadd(aDados,{"Dados Titulo a Receber "+Iif(lPtuV60,"DOC 1","FAT")+" [C]","Numero do Titulo :"+BRJ->(BRJ_CFTPRE+BRJ_CFTTIT+BRJ_CFTPAR+BRJ_CFTTIP)+"    Vencimento "+dtoc(SE1->E1_VENCTO)+"     Valor "+Transform(SE1->E1_VALOR,PLPMONEY_M)})
		Endif
		
	EndIf
	
	//Verifica se foi gerado o abatimento
	
	SE1->(MsSeek(xFilial("SE1")+BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC)))
	nVlrTitCon := SE1->E1_VALOR
	If SE1->(MsSeek(xFilial("SE1")+BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+"AB-"))) .And. !Empty(BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+BRJ_TIPNDC))
		aadd(aDados,{"",""})
		aadd(aDados,{"Dados Titulo Abatimento NDC","Numero do Titulo :"+BRJ->(BRJ_PRENDC+BRJ_NUMNDC+BRJ_PARNDC+"AB-")+"    Vencimento "+dtoc(SE1->E1_VENCTO)+"     Valor "+Transform(SE1->E1_VALOR,PLPMONEY_M)})
		aadd(aDados,{"Saldo de Glosa NDC",Transform(nVlrTitCon - SE1->E1_VALOR,PLPMONEY_M)})
	EndIf
	
	SE1->(MsSeek(xFilial("SE1")+BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT)))
	nVlrTitCon := SE1->E1_VALOR
	If SE1->(MsSeek(xFilial("SE1")+BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+"AB-"))) .And. !Empty(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))
		aadd(aDados,{"",""})
		aadd(aDados,{"Dados Titulo Abatimento FAT","Numero do Titulo :"+BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+"AB-")+"    Vencimento "+dtoc(SE1->E1_VENCTO)+"     Valor "+Transform(SE1->E1_VALOR,PLPMONEY_M)})
		aadd(aDados,{"Saldo de Glosa FAT",Transform(nVlrTitCon - SE1->E1_VALOR,PLPMONEY_M)})
	Endif
	
Else
	If SE1->(MsSeek(xFilial("SE1")+BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))) .And. !Empty(BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT))
		aadd(aDados,{"Dados Titulo a Receber","Numero do Titulo :"+BRJ->(BRJ_PREFIX+BRJ_NUMTIT+BRJ_PARCEL+BRJ_TIPTIT)+"    Vencimento "+dtoc(SE1->E1_VENCTO)+"     Valor "+Transform(SE1->E1_VALOR,PLPMONEY_M)})
	Endif
EndIf

aadd(aDados,{"",""})
aadd(aDados,{"Tipo de Pagamento",X3COMBO("BRJ_TPPAG",BRJ->BRJ_TPPAG)})
aadd(aDados,{"",""})
aadd(aDados,{"Status",X3COMBO("BRJ_STATUS",BRJ->BRJ_STATUS)})
aadd(aDados,{"",""})

//Verifica o status do processo Ajius
If BRJ->(FieldPos("BRJ_NP2TIT")) > 0 .and. BRJ->BRJ_GERPTU == "0"
	
	Do Case
	Case BRJ->BRJ_NIV550 == "1"
		cStatAjius := 'Arquivo A550 "Tipo 1 - Arquivo para inclusão de questionamentos" exportado.'
		
	Case BRJ->BRJ_NIV550 $ "34" .And. BRJ->BRJ_ARQPAR == "1" .And. Empty(BRJ->BRJ_NUMTIT) .And. Empty(BRJ->BRJ_NUMNDC)
		cStatAjius := "Arquivo Parcial 1 importado (nao gerado titulo de contestação)."
		
	Case BRJ->BRJ_NIV550 $ "34" .And. BRJ->BRJ_ARQPAR == "1" .And. (!Empty(BRJ->BRJ_NUMTIT) .Or. !Empty(BRJ->BRJ_NUMNDC))
		cStatAjius := "Arquivo Parcial 1 importado e pago (gerado titulo de contestação)."
		
	Case BRJ->BRJ_NIV550 $ "34" .And. BRJ->BRJ_ARQPAR == "2" .And. Empty(BRJ->BRJ_FP2TIT) .And. Empty (BRJ->BRJ_NP2TIT)
		cStatAjius := "Arquivo Parcial 2 importado (nao gerado titulo de contestação)."
		
	Case BRJ->BRJ_NIV550 $ "34" .And. BRJ->BRJ_ARQPAR == "2" .And. (!Empty(BRJ->BRJ_FP2TIT) .Or. !Empty (BRJ->BRJ_NP2TIT))
		cStatAjius := "Arquivo Parcial 2 importado e pago (gerado titulo de contestação)."
		
	Case BRJ->BRJ_NIV550 $ "78" .And.  Empty(BRJ->BRJ_CFTTIT) .And. Empty(BRJ->BRJ_CNDTIT)
		cStatAjius := "Arquivo de Fechamento Complementar importado (nao gerado titulo de contestação)."
		
	Case BRJ->BRJ_NIV550 $ "78" .And.  (!Empty(BRJ->BRJ_CFTTIT) .Or. !Empty(BRJ->BRJ_CNDTIT))
		cStatAjius := "Arquivo de Fechamento Complementar importado e pago (gerado titulo de contestação)."
		
	Case BRJ->BRJ_NIV550 $ "56" .And. Empty(BRJ->BRJ_NUMTIT) .And. Empty(BRJ->BRJ_NUMNDC)
		cStatAjius := "Arquivo de Fechamento importado (nao gerado titulo de contestação)."
		
	Case BRJ->BRJ_NIV550 $ "56" .And. (!Empty(BRJ->BRJ_NUMTIT) .Or. !Empty(BRJ->BRJ_NUMNDC))
		cStatAjius := "Arquivo de Fechamento importado e pago (gerado titulo de contestação)."
		
	Otherwise
		cStatAjius := "Processo AJIUS nao iniciado."
	EndCase
	
	aadd(aDados,{"Status Processo AJIUS",cStatAjius})
	aadd(aDados,{"",""})
	
EndIf

DbSelectArea("BRJ")
BRJ->(DbClearFilter())
BRJ->(DbSetOrder(1))
BRJ->(MsSeek(xFilial("BRJ")+cChave))
While ! BRJ->(Eof()) .And. BRJ->BRJ_CODIGO == cChave
	If !Empty(BRJ->(BRJ_CODLDP+BRJ_CODPEG))
		
		
		BeginSql Alias cAliasTrb
			SELECT * FROM %table:BD6% BD6
			WHERE BD6.BD6_FILIAL = %exp:xFilial("BD6")% AND BD6.BD6_SEQIMP = %exp:cChave%  AND BD6.%notDel%
		Endsql
		
		If (cAliasTrb)->(!Eof())
			While (cAliasTrb)->(!Eof())
				IF Ascan(aPegs,{|x| x[1]+x[2]+x[3] == (cAliasTrb)->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG)})=0
					aadd(aDados,{"PEG Criada",(cAliasTrb)->(BD6_CODOPE+"."+BD6_CODLDP+"."+BD6_CODPEG)})
					aadd(aPegs,{(cAliasTrb)->BD6_CODOPE,(cAliasTrb)->BD6_CODLDP,(cAliasTrb)->BD6_CODPEG})
				Endif
				(cAliasTrb)->(DbSkip())
			Enddo
		Endif
		(cAliasTrb)->(DbCloseArea())
	Endif
	BRJ->(DbSkip())
Enddo

If Len(aDados) > 0 .And. lMsg .AND. !lAutoma
	lRet := PLSCRIGEN(aDados,{ {"Campo","@C",80} , {"Conteudo","@C",80 } },IF(cTipo=="1","Dados da Importacao - Arquivo "+AllTrim(cArquivo),"Confirma Cancelamento da Importacao - Arquivo "+AllTrim(cArquivo)),NIL,NIL,NIL,NIL, NIL,NIL,"G",240)[1]
Endif

//Novo filtro

If Valtype(oBrwBRJ) == "O"
	oBrwBRJ:Refresh(.T.)
	oBrwBRJ:ExecuteFilter()
Else
	DbSelectArea("BRJ")
	cPLSFiltro := "@BRJ_FILIAL = '"+xFilial("BRJ")+"' AND BRJ_REGPRI = '1' AND D_E_L_E_T_ = ' '"
	SET FILTER TO &cPLSFiltro
Endif

BRJ->(DbGoTo(nRecno))
BRJ->(DbSetOrder(nOrdem))
	
Return(If(cTipo=="1",lRet,{lRet,aPegs}))

/*/{Protheus.doc} PLSED500CN
Trata a exclusao de uma importacao
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Function PLSED500CN(cAlias, nRecno, cOpc, lAutoma)
LOCAL aRet			:= {}
LOCAL lOK			:= .f.
LOCAL aDados		:= {}
LOCAL nFor			:= 0
LOCAL nI        	:= 0
LOCAL aBD6Clear 	:= {}
LOCAL cChave    	:= BRJ->BRJ_CODIGO
LOCAL cSql 			:= ""
LOCAL cLocDigBrj	:= ""
LOCAL aAreaBRJ 		:= BRJ->(GetArea())
LOCAL cAliasTrb		:= GetNextAlias()
LOCAL k				:= 0
LOCAL lClearBCI		:= .F.
Local lExLOTEDI 	:= (BD6->(FieldPos("BD6_LOTEDI")) > 0 .And. BD7->(FieldPos("BD7_LOTEDI")) > 0)
Local lUsaMsPt  	:= GETNEWPAR("MV_PLSUNI","0") == "1" .And. PLSALIASEXI("BZC") .And. BZC->(FieldPos("BZC_CHVGUI")) > 0 .And. BZC->(FieldPos("BZC_ALIAS")) > 0 .And.  FindFunction('MSGCOMINT')
local cCdPac := GetNewPar("MV_PLPACPT","99999998")

Default lAutoma		:= .F.

If BRJ->BRJ_STATUS == "2"
	If !lAutoma
		MsgInfo("Esta importacao nao podera ser excluido porque ja foi paga.")
	EndIf
	Return
Endif

//Verifica se e uma importacao de reembolso

If BRJ->BRJ_TIPLOT == "2"
	B7Q->(DbSetOrder(1))
	B7R->(DbSetOrder(1))
	Begin Transaction
		If B7R->(DbSeek(xFilial("B7R")+cChave))
			While B7R->(B7R_FILIAL+B7R_CODBRJ) == xFilial("B7R")+cChave .And. !B7R->(Eof())
				B7R->(RecLock("B7R",.F.))
				B7R->(DbDelete())
				B7R->(MsUnLock())
				
				B7R->(DbSkip())
			EndDo
		EndIf
		
		If B7Q->(DbSeek(xFilial("B7Q")+cChave))
			While B7Q->(B7Q_FILIAL+B7Q_CODBRJ) == xFilial("B7Q")+cChave .And. !B7Q->(Eof())
				B7Q->(RecLock("B7Q",.F.))
				B7Q->(DbDelete())
				B7Q->(MsUnLock())
				
				B7Q->(DbSkip())
			EndDo
		EndIf
		
		BRJ->(DbSetOrder(1))
		While BRJ->(DbSeek(xFilial("BRJ")+cChave))
			BRJ->(RecLock("BRJ",.F.))
			BRJ->(DbDelete())
			BRJ->(MsUnLock())
		Enddo
		
	End Transaction
	
	If Valtype(oBrwBRJ) == "O"
		oBrwBRJ:Refresh(.T.)
		oBrwBRJ:ExecuteFilter()
	Else
		DbSelectArea("BRJ")
		cPLSFiltro := "@BRJ_FILIAL = '"+xFilial("BRJ")+"' AND BRJ_REGPRI = '1' AND D_E_L_E_T_ = ' '"
		SET FILTER TO &cPLSFiltro
	EndIf
	
	//Encerra
	
	MsgInfo("Lote cancelado com sucesso")
	Return
EndIf

//Tratamento para os casos em que a guia foi feito antes
//de uma autorizaçãoi e seu local de digitação e outro e não
//pode exclui-la e sim limpar o seqimp para uma nova importação

BeginSql Alias cAliasTrb
	SELECT * FROM %table:BRJ% BRJ
	WHERE BRJ_FILIAL = %exp:xFilial("BRJ")%
	AND BRJ_CODIGO=  %exp:cChave%
	AND BRJ.D_E_L_E_T_ = ' '
Endsql

While !(cAliasTrb)->(Eof())
	cLocDigBrj:=(cAliasTrb)->BRJ_CODLDP
	If !Empty(cLocDigBrj)
		Exit
	Endif
	
	(cAliasTrb)->(DbSkip())
Enddo

RestArea(aAreaBRJ)

cSql := " SELECT COUNT(*) TOTAL FROM "+RetSqlName("BD6")
cSql += " WHERE BD6_FILIAL = '"+xFilial("BD6")+"' AND"
cSql += " BD6_SEQIMP = '"+cChave+"' AND "
cSql += " (BD6_NUMSE1 <> ' ' OR  BD6_NUMTIT <> ' ' OR BD6_PREFIX <> ' ' OR BD6_TIPTIT <> ' ') AND "
cSql += " D_E_L_E_T_ = ' '"

PLSQuery(cSql,"Trb")

If Trb->TOTAL > 0
	Trb->(DbCloseArea())
	MsgInfo("Não será possível a exclusão. Existem guias nesta importação que já foram cobradas.")
	Return
Endif

Trb->(DbCloseArea())


	aRet   := PLSED500GN("2",.T.,lAutoma)
	lOK    := aRet[1]
	aDados := aRet[2]

If lOK .OR. lAutoma
	Begin Transaction
		
		
		//Ponto de entrada antes da exclusao das guias importadas
		
		If ExistBlock("PLSP500E")
			ExecBlock("PLSP500E",.F.,.F.)
		Endif
		
		DbSelectArea("BRJ")
		SET FILTER TO
		
		BRJ->(DbSetOrder(1))
		While BRJ->(DbSeek(xFilial("BRJ")+cChave))
			BRJ->(RecLock("BRJ",.F.))
			BRJ->(DbDelete())
			BRJ->(MsUnLock())
		Enddo
		
		BD6->(DbSetOrder(14))
		BD6->(DbGoTop())
		If BD6->(DbSeek(xFilial("BD6")+cChave))
			
			If lUsaMsPt
				
				BZC->(DbSetOrder(1))
				cChvBZC := BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)
				
				If BZC->(DbSeek(xFilial("BZC")+cChvBZC))
					BZC->(RecLock("BZC",.F.))
					BZC->(DbDelete())
					BZC->(MsUnLock())
				EndIf
				
			EndIf
			
			While ! BD6->(Eof()) .And. BD6->(BD6_FILIAL+BD6_SEQIMP) == xFilial("BD6")+cChave

				if FWAliasInDic("B6L", .F.) .and. alltrim(BD6->BD6_CODPRO) == alltrim(cCdPac)
					if B6L->( FieldPos("B6L_CODLDP") ) > 0 .and. B6L->( FieldPos("B6L_CODPEG") ) > 0 .and. B6L->( FieldPos("B6L_NUMERO") ) > 0 .and. B6L->( FieldPos("B6L_ORIMOV") ) > 0
						cSql := " SELECT R_E_C_N_O_ RECNO FROM " + retSqlName("B6L")
						cSql += " WHERE B6L_FILIAL = '" + xFilial("B6L") + "' "
						cSql += " AND B6L_OPEMOV = '" + BD6->BD6_CODOPE + "' "
						cSql += " AND B6L_CODLDP = '" + BD6->BD6_CODLDP + "' "
						cSql += " AND B6L_CODPEG = '" + BD6->BD6_CODPEG + "' "
						cSql += " AND B6L_NUMERO = '" + BD6->BD6_NUMERO + "' "
						cSql += " AND B6L_ORIMOV = '" + BD6->BD6_ORIMOV + "' "
						cSql += " AND D_E_L_E_T_ = ' ' "

						dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBB6L",.F.,.T.)

						while !TRBB6L->(Eof())
							B6L->(DBGoTo(TRBB6L->RECNO))

							B6L->(RecLock("B6L",.F.))
							B6L->(DbDelete())
							B6L->( MsUnLock() )

							TRBB6L->(DBSkip())
						enddo

						TRBB6L->(DBCloseArea())
					endif
				endif
				
				BD7->(DbSetOrder(1))
				If BD7->(MsSeek(xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
					
					While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+;
							BD7_SEQUEN) == ;
							xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+;
							BD6_SEQUEN)
						
						If BD6->BD6_INCAUT <> '1'
							BD7->(RecLock("BD7",.F.))

								PLBLOPC("BD7", .f.)

								BD7->BD7_VLRAPR := 0
								BD7->BD7_VALORI := 0
								BD7->BD7_VLTXAP := 0
								BD7->BD7_FASE	:= '3'
								BD7->BD7_SEQIMP := ""
								BD7->BD7_SITUAC := "3"
								BD7->BD7_NUMIMP := ""
								If lExLOTEDI
									BD7->BD7_LOTEDI := ""
								EndIf
								
							BD7->(MsUnLock())
							
						Else
							If Empty(cLocDigBrj)
								BD7->(RecLock("BD7",.F.))
								BD7->(DbDelete())
								BD7->(MsUnLock())
							Else
								If cLocDigBrj == BD7->BD7_CODLDP
									BD7->(RecLock("BD7",.F.))
									BD7->(DbDelete())
									BD7->(MsUnLock())
								Else
									BD7->(RecLock("BD7",.F.))
										
										PLBLOPC("BD7", .f.)
										
										BD7->BD7_VLRAPR := 0
										BD7->BD7_VALORI := 0
										BD7->BD7_VLTXAP := 0
										BD7->BD7_FASE	:= '3'
										BD7->BD7_SEQIMP := ""
										BD7->BD7_SITUAC := "3"
										BD7->BD7_NUMIMP := ""
										
										If lExLOTEDI
											BD7->BD7_LOTEDI := ""
										EndIf
										
									BD7->(MsUnLock())
								Endif
							EndIf
						Endif
						
						BD7->(DbSkip())
					Enddo
					
					BDX->(dbSetOrder(1))
					If BDX->(MsSeek(xFilial("BDX")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO)))
						BDX->(RecLock("BDX",.F.))
						BDX->(dbDelete())
						BDX->(MsUnlock())
					EndIf
					
					
					BX6->(dbSetOrder(1))//BX6_FILIAL + BX6_CODOPE + BX6_CODLDP + BX6_CODPEG + BX6_NUMERO + BX6_ORIMOV + BX6_SEQUEN + BX6_CODPAD + BX6_CODPRO
					If BX6->(MsSeek(xFilial("BX6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO)))
						BX6->(RecLock("BX6",.F.))
						BX6->(dbDelete())
						BX6->(MsUnlock())
					EndIf
					
					
					If BD6->BD6_INCAUT <> '1'
						aadd(aBD6Clear,{BD6->(RecNO()),.F.,BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)}) // NAO APAGAR O BD6 POIS SURGIU DE UM AUTORIZAÇÃO
					ElseIf Empty(cLocDigBrj)
						aadd(aBD6Clear,{BD6->(RecNO()),.T.,BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)}) // APAGAR O BD6 E UMA GUIA IMPORTADA
					Else
						If cLocDigBrj==BD6->BD6_CODLDP
							aadd(aBD6Clear,{BD6->(RecNO()),.T.,BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)}) // APAGAR O BD6 E UMA GUIA IMPORTADA
						Else
							aadd(aBD6Clear,{BD6->(RecNO()),.F.,BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)}) // NAO APAGAR O BD6 POIS SURGIU DE UM AUTORIZAÇÃO
						Endif
					Endif
					
				Endif
				
				BD6->(DbSkip())
				
			Enddo
			
		Endif
		
		BCI->(DbSetOrder(1))
		BD5->(DbSetOrder(1))
		BE4->(DbSetOrder(1))
		
		For nI := 1 To Len(aBD6Clear)
			lClearBCI  := .F.
			BD6->(DbGoTo(aBD6Clear[nI][1]))
			
			If BCI->(MsSeek(xFilial("BCI")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG)))
				lClearBCI := PLSP500CP(cChave,BCI->BCI_CODLDP,BCI->BCI_CODPEG)
			Endif
			
			//Se houver um item marcado como .F. na guia, a mesma nao e excluida
			
			If aBD6Clear[nI,2]
				If !(Ascan(aBD6Clear,{|x| x[3] == BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) .And. !x[2]}) > 0)
					If BD6->BD6_TIPGUI $ "01,02,05,06"
						If BD5->(DbSeek(xFilial("BD5")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
							BD5->(RecLock("BD5",.F.))
							BD5->(DbDelete())
							BD5->(MsUnLock())
						Else
							If BE4->(DbSeek(xFilial("BE4")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
								BE4->(RecLock("BE4",.F.))
								BE4->(DbDelete())
								BE4->(MsUnLock())
							Endif
						Endif
					Endif
					
					
					//pagando a PEG
					
					If lClearBCI
						BCI->(RecLock("BCI",.F.))
						BCI->(DbDelete())
						BCI->(MsUnLock())
					Endif
				EndIf
				
				BD6->(RecLock("BD6",.F.))
				BD6->(DbDelete())
				BD6->(MsUnLock())
				
			Else
				
				//estornando as Guias Pre-autorizadas?
				
				BD6->(RecLock("BD6",.F.))

					PLBLOPC("BD6", .f., nil, nil, .t., .f., .f.)
					
					BD6->BD6_INCAUT := ""
					BD6->BD6_FASE	:= '3'
					BD6->BD6_VLRAPR := 0
					BD6->BD6_VALORI := 0
					BD6->BD6_NUMIMP := ""
				
					If lExLOTEDI
						BD6->BD6_LOTEDI := ""
					EndIf
					
					If BD6->BD6_TPGRV <> "4"
						BD6->BD6_SEQIMP := ""
						BD6->BD6_SITUAC	:= "3"
					Endif
					
					If BD6->(FieldPos("BD6_VLTXAP")) >0
						BD6->BD6_VLTXAP := 0
					EndIf
					
					If BD6->(FieldPos("BD6_VLRTAP")) > 0
						BD6->BD6_VLRTAP := 0
					Endif
				
				BD6->(MsUnLock())
				
				If BD6->BD6_TPGRV <> "4"
					If BD6->BD6_TIPGUI $ "01,02,06"
						BD5->(DbSetOrder(1))
						If BD5->(DbSeek(xFilial("BD5")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
							BD5->(RecLock("BD5",.F.))
							BD5->BD5_SEQIMP	:= ""
							BD5->BD5_FASE 	:= '3'
							BD5->BD5_SITUAC	:= "3"
							BD5->BD5_NUMIMP := ""
							BD5->(MsUnLock())
						Endif
					Else
						BE4->(DbSetOrder(1))
						If BE4->(DbSeek(xFilial("BE4")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
							BE4->(RecLock("BE4",.F.))
							BE4->BE4_SEQIMP	:= ""
							BE4->BE4_FASE	:= '3'
							BE4->BE4_SITUAC	:= '3'
							BE4->BE4_NUMIMP := ""
							BE4->(MsUnLock())
						Endif
					Endif
				Endif
			Endif
		Next
		
		//Atualiza os avisos
		If PLSALIASEXI("B5T") .And. PLSALIASEXI("B6T")
			B5T->(DbSetOrder(3)) //B5T_FILIAL+B5T_SEQIMP
			While B5T->(MsSeek(xFilial("B5T")+cChave)) //B5T->(B5T_FILIAL+B5T_SEQIMP) == xFilial("B5T")+Alltrim(cChave)	 
				B5T->(RecLock("B5T",.F.))
				B5T->B5T_CODLDP := ""
				B5T->B5T_CODPEG := ""
				B5T->B5T_NUMGUI := ""
				B5T->B5T_VLR500 := 0
				B5T->B5T_SEQIMP := ""
				B5T->(MsUnLock())
			EndDo	
					
			B6T->(DbSetOrder(5)) //B6T_FILIAL+B6T_SEQIMP
			While B6T->(MsSeek(xFilial("B6T")+cChave)) //B6T->(B6T_FILIAL+B6T_SEQIMP) == xFilial("B6T")+Alltrim(cChave)
				B6T->(RecLock("B6T",.F.))
				B6T->B6T_VLR500 := 0
				B6T->B6T_SEQIMP := ""
				B6T->(MsUnLock())
			EndDo

		EndIf
	End Transaction
	
	
	//Novo filtro
	
	If Valtype(oBrwBRJ) == "O"
		oBrwBRJ:Refresh(.T.)
		oBrwBRJ:ExecuteFilter()
	Else
		DbSelectArea("BRJ")
		cPLSFiltro := "@BRJ_FILIAL = '"+xFilial("BRJ")+"' AND BRJ_REGPRI = '1' AND D_E_L_E_T_ = ' '"
		SET FILTER TO &cPLSFiltro
	EndIf
Endif
	
Return

/*/{Protheus.doc} PLSP500LEG
Exibe a legenda
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Function PLSP500Leg()
	
BrwLegenda(cCadastro,"Status" ,aCdCores)
	
Return

/*/{Protheus.doc} AnalisaCrit

@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Static Function AnalisaCrit(cCodigo,cDado,cDadoAux,cTipo,cLote,cNota,cNomArq)
Local nPos		:= 0
Local nPosCri	:= 0
Local lFlag 	:= .T.
Local cCritica	:= ""
Local cCriPar	:= MV_PAR07 + "," + MV_PAR08 + "," + MV_PAR09

DEFAULT cDadoAux := ""
DEFAULT cTipo    := "1"
DEFAULT cNomArq := ""

If Empty(cNomArq)
	cNomArq := IIF(!Empty(cArquivo), Substr(cArquivo, RAT("\",cArquivo)+1, Len(cArquivo)), cNomArq)
EndIf

nPos := aScan(aCriticas,{|x| x[1] == cCodigo})

//Caso a critica esteja desativada nas perguntas não considerar
If nPos > 0 .And. !(cCodigo $ cCriPar) .and. allTrim(cCriPar) <> ',,'
	nPos := 0
EndIf

If nPos > 0
	If Empty(cDadoAux)
		cCritica := aCriticas[nPos,2]
	Else
		cCritica := AllTrim(aCriticas[nPos,2])+"   ["+AllTrim(cDadoAux)+"]"
	Endif
	
	If cTipo == "1"
		aadd(aCritReal,{cNomArq,aCriticas[nPos,1],cCritica,alltrim(str(nLine)),cDado})
	Elseif cTipo == "2"
		aadd(aGuiaNaoExi,{aCriticas[nPos,1],cCritica,cLote,cNota,cDado })
	Endif
	
	lFlag := aCriticas[nPos,3]=="1"
ElseIf cCodigo $ cCriPar
	If cTipo == "1"
		aadd(aCritReal,{cNomArq,cCodigo,"Codigo da Critica nao localizado",alltrim(str(nLine)),cDado})
	Elseif cTipo == "2"
		aadd(aGuiaNaoExi,{cCodigo,"Codigo da Critica nao localizado",cLote,cNota,"","","","" })
	Endif
	
	lFlag := .F.
Endif

If ! lFlag .And. lImpPTU
	lImpPTU := .F.
Endif
	
Return(lFlag)

/*/{Protheus.doc} PLSLSC500
F3 da listagem das criticas do ptu 500
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Function PLSLSC500(cDado1,cDado2,lTela,cDado3)
LOCAL oDlg
LOCAL nOpca     := 0
LOCAL bOK       := { || nOpca := K_OK, oDlg:End() }
LOCAL bCancel   := { || oDlg:End() }
LOCAL oCritica
LOCAL cSQL
LOCAL aLista    := {}
LOCAL nInd
LOCAL nPos
DEFAULT lTela := .T.
DEFAULT cDado3:= ""

//coloca virgula no comeco (caso tenha inicializador padrao)

cDado1  := AllTrim(cDado1)
cDado2  := AllTrim(cDado2)
cDado3  := AllTrim(cDado3)

if subs(cDado1,len(cDado1),1) != "," .AND. cDado1 != ""
	cDado1 += ","
endif

aCriticas := {}
CarregaCrit()
For nInd := 1 To Len(aCriticas)
	If aCriticas[nInd,3] == "1"
		aadd(aLista,{aCriticas[nInd,1],aCriticas[nInd,2],If(aCriticas[nInd,1]$cDado1+cDado2+cDado3,.T.,.F.)})
	Endif
Next

If lTela
	
	DEFINE MSDIALOG oDlg TITLE "Criticas" FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()
	
	@ 020,012 SAY oSay PROMPT "Selecione a(s) criticas(s) que podem(rao) impedir a importacao" SIZE 300,010 OF oDlg PIXEL COLOR CLR_HBLUE
	
	oCritica := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	
	oCritica:AddColumn(TcColumn():New(" ",{ || IF(aLista[oCritica:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },;
		"@c",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))
	
	oCritica:AddColumn(TcColumn():New("Codigo",{ || OemToAnsi(aLista[oCritica:nAt,1]) },;
		"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))
	
	oCritica:AddColumn(TcColumn():New("Descricao",{ || OemToAnsi(aLista[oCritica:nAt,2]) },;
		"@C",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))
	
	oCritica:SetArray(aLista)
	oCritica:bLDblClick := { || aLista[oCritica:nAt,3] := IF(aLista[oCritica:nAt,3],.F.,.T.) }
	
	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})
	
Else
	nOpca := K_OK
Endif

If nOpca == K_OK
	
	cDado1 := ""
	cDado2 := ""
	cDado3 := ""
	For nInd := 1 To Len(aLista)
		
		If aLista[nInd,3]
			If nInd <= 20
				cDado1 += aLista[nInd,1]+","
			Elseif nInd > 20 .and. nInd <= 40
				cDado2 += aLista[nInd,1]+","
			Else
				cDado3 += aLista[nInd,1]+","
			Endif
			
			nPos := Ascan(aCriticas,{|x| x[1] == aLista[nInd,1]})
			If nPos > 0
				aCriticas[nPos,3] := "0"
			Endif
		Endif
	Next
Endif


//tira a virgula do final
if subs(cDado1,len(cDado1),1) == ","
	cDado1 := subs(cDado1,1,len(cDado1)-1)
endif

if subs(cDado2,len(cDado2),1) == ","
	cDado2 := subs(cDado2,1,len(cDado2)-1)
endif

if subs(cDado3,len(cDado3),1) == ","
	cDado3 := subs(cDado3,1,len(cDado3)-1)
endif
	
Return .T.

/*/{Protheus.doc} PLSLSC500
F3 da listagem das criticas do ptu 500
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Function PLSLAR500(cArqImp,lFloppy,lHard,lNetwork)
LOCAL cSalvo := cArqImp
Default lFloppy := .T.
Default lHard   := .T.
Default lNetwork:= .T.

If Alltrim(Upper(FunName())) == "PLSEDIA500"
	cArqImp := cGetFile("Todos os Arquivos|*.*|","Selecione o diretorio dos arquivos",,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY)
Else
	cArqImp := cGetFile("*.*","Selecione o Arquivo",0,"SERVIDOR\",.T.,Iif(lFloppy,GETF_LOCALFLOPPY,0) + Iif(lHard,GETF_LOCALHARD,0) + Iif(lNetwork,GETF_NETWORKDRIVE,0))
EndIf

If Empty(cArqImp)
	cArqImp := cSalvo
Endif
	
Return (!Empty(cArqImp))
/*/{Protheus.doc} PLSP500Usr
Analisa uma importacao e lista os usuarios nao encontrados.
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Function PLSP500Usr(cAlias,nReg,nOpc,cNil,lMsg,cCodProGen)
LOCAL aRet   := PLSED500GN("2",.F.)
LOCAL lOK    := aRet[1]
LOCAL aDados := aRet[2]
LOCAL nFor
LOCAL cMatrUsrGen
LOCAL aNotas := {}
LOCAL cSQL
LOCAL cNomArq := ""

DEFAULT lMsg := .T.
DEFAULT cCodProGen := ""

If Empty(cArquivo) //variavel static
	cArquivo := BRJ->BRJ_ARQUIV
Endif

cNomArq := IIF(!Empty(cArquivo), Substr(cArquivo, RAT("\",cArquivo)+1, Len(cArquivo)), cNomArq)

If Empty(cCodProGen)
	Pergunte("PLS500",.F.)
	cCodProGen := alltrim(mv_par09)
Endif

BA1->(DbSetOrder(5))
If BA1->(MsSeek(xFilial("BA1")+cMatrAntGen))
	cMatrUsrGen := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
	
	BD5->(DbSetOrder(5))
	If BD5->(MsSeek(xFilial("BD5")+cMatrUsrGen))
		While ! BD5->(Eof()) .And. BD5->(BD5_FILIAL+BD5_OPEUSR+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO) == xFilial("BD5")+cMatrUsrGen
			If Ascan(aDados,{|x| x[1]+x[2]+x[3] == BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG) }) > 0
				aadd(aNotas,{cNomArq,;
					"Usuario Invalido",;
					BD5->BD5_CODOPE+"-"+BD5->BD5_CODLDP+"-"+BD5->BD5_CODPEG+"-"+BD5->BD5_NUMERO,;
					BD5->BD5_MATANT,;
					Subs(BD5->BD5_NOMUSR,1,30),;
					BD5->BD5_NUMIMP,;
					""})
			Endif
			BD5->(DbSkip())
		Enddo
	Endif
Endif

For nFor := 1 To Len(aDados)
	cSQL := "SELECT BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_MATANT,BD6_NOMUSR,BD6_NUMIMP,BD6_DATPRO, BD6_CODPRO "
	cSQL += ", BD6_CODERR "
	
	cSQL += "FROM "+RetSQLName("BD6")+" WHERE "
	cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
	cSQL += "BD6_CODOPE = '"+aDados[nFor,1]+"' AND "
	cSQL += "BD6_CODLDP = '"+aDados[nFor,2]+"' AND "
	cSQL += "BD6_CODPEG = '"+aDados[nFor,3]+"' AND "
	cSQL += "BD6_CODPRO = '"+cCodProGen+"' AND "
	cSQL += "D_E_L_E_T_ = ' '"
	PLSQuery(cSQL,"Trb")
	
	While ! Trb->(Eof())
		aadd(aNotas,{cNomArq,;
			"Cod. Evento Invalido",;
			Trb->BD6_CODOPE+"-"+Trb->BD6_CODLDP+"-"+Trb->BD6_CODPEG+"-"+Trb->BD6_NUMERO,;
			Trb->BD6_MATANT,;
			Subs(Trb->BD6_NOMUSR,1,30),;
			Trb->BD6_NUMIMP,;
			Trb->BD6_CODERR})
		Trb->(DbSkip())
	Enddo
	Trb->(DbCloseArea())
Next
	
Return (aNotas)

/*/{Protheus.doc} CriaUsrGen
Cria um usuario generico caso nao seja encontrado
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Function PLSUsrGen(cOpeOri,cNomeUsr,lCriaUsr)
LOCAL lRet      	:= .T.
LOCAL cMatric       := ""
LOCAL cCodInt       := ""
LOCAL cCodEmp       := ""
LOCAL cConEmp       := ""
LOCAL cVerCon       := ""
LOCAL cSubCon       := ""
LOCAL cVerSub       := ""
LOCAL cMatrAntGen 	:= "99999999999999999"
LOCAL lStrTPLS		:= FindFunction("StrTPLS")
LOCAL cModulo   	:= IIF(lStrTPLS,Modulo11(StrTPLS(cOpeOri+"999999999999")),Modulo11(cOpeOri+"999999999999"))
LOCAL aDadosUsr 	:= PLSUSRIEVE(cOpeOri+"999999999999"+cModulo,"1",dDataBase)
DEFAULT cNomeUsr 	:= "USUARIO GENERICO"
DEFAULT lCriaUsr  	:= .F.

//Verifica se existe o usuario generico...

If aDadosUsr[1] == "0"
	lRet     := .T.
	lCriaUsr := .F.
ElseIf aDadosUsr[1] == "1"
	lRet     := .T.
	lCriaUsr := .T.
	cConEmp  := aDadosUsr[5]
	cVerCon  := aDadosUsr[6]
	cSubCon  := aDadosUsr[7]
	cVerSub  := aDadosUsr[8]
ElseIf aDadosUsr[1] == "2"
	lRet     := .F.
	lCriaUsr := .F.
EndIf

//Verifica se existe o usuario generico...

If lCriaUsr
	BA1->( DbSetOrder(5) )//BA1_FILIAL+BA1_MATANT+BA1_TIPANT
	If ! BA1->( MsSeek( xFilial("BA1")+cMatrAntGen ) )
		
		//Se nao existir inclui...
		
		cCodInt := PLSINTPAD()
		cCodEmp := GetNewPar("MV_PLSGEIN","0050")
		cMatric := PLPROXMAT(cCodInt,cCodEmp)
		
		//Inclui familia
		
		BA3->( RecLock("BA3",.T.) )
		BA3->BA3_FILIAL := xFilial("BA3")
		BA3->BA3_CODINT := cCodInt
		BA3->BA3_CODEMP := cCodEmp
		BA3->BA3_CONEMP := cConEmp
		BA3->BA3_VERCON := cVerCon
		BA3->BA3_SUBCON := cSubCon
		BA3->BA3_VERSUB := cVerSub
		BA3->BA3_ROTINA := "PLSPORFAI"
		BA3->BA3_MATRIC := cMatric
		BA3->BA3_MATANT := cMatrAntGen
		BA3->BA3_HORACN := StrTran(SubStr(Time(),1,5),":","")
		BA3->BA3_COBNIV := "0"
		BA3->BA3_VENCTO := 0
		BA3->BA3_DATBAS := dDataBase
		BA3->BA3_DATCIV := dDataBase
		BA3->BA3_TIPOUS := "2"
		BA3->BA3_USUOPE := PLSRtCdUsr()
		BA3->BA3_MODPAG := "2"
		
		BT6->( DbSetOrder(1) )//BT6_FILIAL+BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB+BT6_CODPRO+BT6_VERSAO
		If BT6->(MsSeek(xFilial("BT6")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))
			BA3->BA3_CODPLA := BT6->BT6_CODPRO
			BA3->BA3_VERSAO := BT6->BT6_VERSAO
		Else
			BA3->BA3_CODPLA := GetNewPar("MV_PLSPLPE","0001")
			BA3->BA3_VERSAO := GetNewPar("MV_PLSVRPE","0001")
		EndIf
		BA3->BA3_FORPAG := GetNewPar("MV_PLSFCPE","101")
		BA3->BA3_DATCON := Date()
		BA3->BA3_HORCON := StrTran(SubStr(Time(),1,5),":","")
		BA3->(MsUnLock())
		
		//Inclui Usuario
		
		BA1->( RecLock("BA1",.T.) )
		BA1->BA1_FILIAL := xFilial("BA1")
		BA1->BA1_CODINT := BA3->BA3_CODINT
		BA1->BA1_CODEMP := BA3->BA3_CODEMP
		BA1->BA1_MATRIC := BA3->BA3_MATRIC
		BA1->BA1_CONEMP := BA3->BA3_CONEMP
		BA1->BA1_VERCON := BA3->BA3_VERCON
		BA1->BA1_SUBCON := BA3->BA3_SUBCON
		BA1->BA1_VERSUB := BA3->BA3_VERSUB
		BA1->BA1_IMAGE  := "ENABLE"
		BA1->BA1_TIPREG := GetNewPar("MV_PLTRTIT","00")

		If !lStrTPLS
			BA1->BA1_DIGITO := Modulo11(BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG)
		Else
			BA1->BA1_DIGITO := Modulo11(StrTPLS(BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG))
		EndIf
		
		BA1->BA1_NOMUSR := cNomeUsr
		BA1->BA1_TIPUSU := SuperGetMv("MV_PLCDTIT")
		BA1->BA1_GRAUPA := GetMv("MV_PLCDTGP")
		
		If BA1->(FieldPos("BA1_ENDCLI")) > 0
			BA1->BA1_ENDCLI := "0"
		EndIf
		
		BA1->BA1_MATANT := ""
		BA1->BA1_MATEMP := ""
		BA1->BA1_SEXO   := ""
		BA1->BA1_ESTCIV := ""
		BA1->BA1_CPFUSR := ""
		BA1->BA1_DRGUSR := ""
		BA1->BA1_DATINC := CtoD("")
		BA1->BA1_DATNAS := CtoD("")
		BA1->BA1_DATCAR := CtoD("")
		BA1->BA1_CBTXAD := "1"
		BA1->BA1_OPEORI := cOpeOri
		BA1->BA1_OPEDES := cCodInt
		BA1->BA1_OPERES := cCodInt
		BA1->BA1_LOCATE := "2"
		BA1->BA1_LOCCOB := "2"
		BA1->BA1_LOCEMI := "2"
		BA1->BA1_LOCANS := "2"
		
		//Esta funcao analise a criacao de uma nova vida ou nao...
		
		PLSA766ANV(nil,.F.)
		
		//Grava no usuario a vida criada ou a ja existente...
		
		BA1->BA1_MATVID := BTS->BTS_MATVID
		BA1->(MsUnLock())
	EndIf
EndIf
	
Return(lRet)
/*/{Protheus.doc} PLSLOG500

@author PLS TEAM
@since 17.01.2005
@version P12
/*/

Function PLSLOG500()
Return lMVPLSX500

/*/{Protheus.doc} PLSP500AFP

@author PLS TEAM
@since 17.01.2005
@version P12
/*/
Function PLSP500AFP()
LOCAL aRet
LOCAL aComboResp := Eval( { || SX3->(DbSetOrder(2)), SX3->(MsSeek("BRJ_TPPAG")), RetSx3Box(X3CBox(),,,1) } )
LOCAL aOpcoes    := {}
LOCAL nFor
LOCAL nPosTpPag  := 0

If BRJ->BRJ_STATUS == "2"
	MsgInfo("Esta importacao nao podera ser alterada a forma de pagamento porque ja foi paga.")
	Return
Endif

nPosTpPag := Ascan(aComboResp,{|x|x[2] == BRJ->BRJ_TPPAG})

If nPosTpPag > 0
	aadd(aOpcoes,aComboResp[nPosTpPag,1])
EndIf

For nFor := 1 To Len(aComboResp)
	If Ascan(aOpcoes,{|x| x == aComboResp[nFor,1] }) == 0
		aadd(aOpcoes,aComboResp[nFor,1])
	EndIf
Next

If ! ParamBox({	{2,"Informe a desejada ","222222222",aOpcoes,125,  ,.T.} }, "Forma de Pagamento da Fatura de Intercambio",@aRet )
	Return
Else
	BRJ->(RecLock("BRJ",.F.))
	BRJ->BRJ_TPPAG := aRet[1]
	BRJ->(MsUnLock())
Endif
	
Return


/*/{Protheus.doc} AtuSEQEv

@author PLS TEAM
@since 17.01.2005
@version P12
/*/
Static Function AtuSEQEv(cCodOpe,cCodLDP,cCodPEG,cNumero,cOriMov,cCodSeq,cAlias,cIncAut,lMudSituac)
LOCAL cChaveBDH
DEFAULT cAlias := "BD5"
DEFAULT cIncAut := ""
DEFAULT lMudSituac := .F.

cChaveBDH := &(cAlias+"->"+cAlias+"_OPEUSR")+&(cAlias+"->"+cAlias+"_CODEMP")+;
	&(cAlias+"->"+cAlias+"_MATRIC")+&(cAlias+"->"+cAlias+"_TIPREG")+&(cAlias+"->"+cAlias+"_ANOPAG")+&(cAlias+"->"+cAlias+"_MESPAG")+&(cAlias+"->"+cAlias+"_SEQPF")

BDH->(DbSetOrder(3))
If BDH->(DbSeek(xFilial("BDH")+cChaveBDH))
	PLSM180Del() //Se esta consolidado exclui todos as ligacoes de eventos relativos a esta consolidacao
	BDH->(RecLock("BDH",.F.)) //Exclui a consolidacao referente a guia atual e a outras que estajam ligadas
	BDH->(DbDelete())
	BDH->(MsUnLock())
Endif

DbSelectArea(cAlias)
RecLock(cAlias,.F.)
&(cAlias+"->"+cAlias+"_ANOPAG") := Subs(cAMPAG,1,4)
&(cAlias+"->"+cAlias+"_MESPAG") := Subs(cAMPAG,5,2)
MsUnLock()

//Se guia Online, altera o SITUAC para 1=Ativo

If lMudSituac
	BD5->(Reclock("BD5",.F.))
	BD5->BD5_SITUAC := "1"
	BD5->(MsUnlock())
Endif

//Posiciono nos itens da guia

BD6->(DbSetOrder(1))
If BD6->(MsSeek(xFilial("BD6")+cCodOpe+cCodldp+cCodPEG+cNumero+cOriMov))
	While ! BD6->(Eof()) .And. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == ;
			xFilial("BD6")+cCodOpe+cCodldp+cCodPEG+cNumero+cOriMov
		
		//Atualizo o numero do lote de PTU nestes itens
		
		BD6->(Reclock("BD6",.F.))
		
		BD6->BD6_SEQIMP := cCodSeq
		BD6->BD6_FASE   := "1" //Voltar a fase para digitacao...
		BD6->BD6_ANOPAG := Subs(cAMPAG,1,4)
		BD6->BD6_MESPAG := Subs(cAMPAG,5,2)
		
		If ! Empty(cIncAut)
			BD6->BD6_INCAUT := cIncAut
		Endif
		
		If lMudSituac
			BD6->BD6_SITUAC := "1"
		EndIf
		BD6->(MsUnlock())
		
		//Posiciono nos sub-itens
		
		BD7->(DbSetOrder(1))
		If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
			While ! BD7->(Eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
					xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
				
				//Atualizo o numero do lote de PTU nestes sub-itens
				
				BD7->(Reclock("BD7",.F.))
				
				BD7->BD7_SEQIMP := cCodSeq
				BD7->BD7_FASE   := "1" //Voltar a fase para digitacao...
				BD7->BD7_ANOPAG := Subs(cAMPAG,1,4)
				BD7->BD7_MESPAG := Subs(cAMPAG,5,2)
				If lMudSituac
					BD7->BD7_SITUAC := "1"
				EndIf
				BD7->(MsUnlock())
				BD7->(DbSkip())
			Enddo
		Endif
		BD6->(DbSkip())
	Enddo
Endif

If ExistBlock("PLS500AP")
	ExecBlock("PLS500AP",.F.,.F.,{cAlias,cCodOpe,cCodLDP,cCodPEG,cNumero,cOriMov,cCodSeq,&(cAlias+"->"+cAlias+"_NUMIMP")})
Endif
	
Return
/*/{Protheus.doc} ConfNota

@author PLS TEAM
@since 17.01.2005
@version P12
/*/
Static Function ConfNota(cAliasPLS,cMatric)
LOCAL nRecno
LOCAL aEventos := {}
LOCAL cChave
LOCAL nPos
LOCAL cNotaArq := PLSA500GCF("R502","NR_LOTE")+PLSA500GCF("R502","NR_NOTA")
LOCAL cNomArq  := ""
LOCAL cAuxDat
LOCAL cDatAte := PLSA500GCF("R502","DT_ATEND")
LOCAL dDatAte := ctod(subs(cDatAte,9,2)+"/"+subs(cDatAte,6,2)+"/"+subs(cDatAte,1,4))
LOCAL dDataPro
LOCAL cDataPro
LOCAL cHorPro
LOCAL cHorFim
LOCAL nQtdCob    := 0
LOCAL aEventosCob := {}
LOCAL nFor
LOCAL nI		 := 1
LOCAL nJ		 := 1
LOCAL cVarSer    := ""
LOCAL cChaveMat  := ""
LOCAL aBD6Nota   := {}
LOCAL nSize		 := 0
LOCAL cHoraFim   := ""
LOCAL aBD7Ger    := {}
LOCAL lPL500CFN  := existBlock("PL500CFN")
LOCAL cTRDAED    := ""
LOCAL cRPEDI     := ""
LOCAL cNOMEDI    := "" 
LOCAL cLotePre   := ""
LOCAL cNumGuiPre := ""
LOCAL lLayVer11  := Val(cCodLayPLS) >= 11
LOCAL lForNBD6	 := .t.
LOCAL aRecBD6	 := {}
LOCAL nRecnoB5T  := 0	
Local cCodOpe	:= PLSINTPAD() //PLSA500GCF("R501","CD_UNI_ORI")

//Campos que eram do R504 e na versao 10.0 foram migrados para o R502
cTRDAED := PLSA500GCF("R502","TP_PREST")
cRPEDI  := PLSA500GCF("R502","ID_REC_PRO")
cNOMEDI := PLSA500GCF("R502","NM_PREST") 
cLotePre   := PLSA500GCF("R502","NR_LOTEPRE")
cNumGuiPre := PLSA500GCF("R502","NR_GT_PRES")	

//Atribuir conteudo a campo de data de atendimento, caso internacao...
If cAliasPLS == "BE4"
	If Empty(BE4->BE4_DATPRO) .And. !Empty(dDatAte)
		BE4->(Reclock("BE4",.F.))
		BE4->BE4_DATPRO := dDatAte
		BE4->BE4_NUMIMP := PLSA500GCF("R502","NR_NOTA")
		BE4->(MsUnlock())
	Endif
ElseIf cAliasPLS == "BD5" .And. !Empty(dDatAte)
	BD5->(Reclock("BD5",.F.))
	BD5->BD5_DATPRO := dDatAte
	BD5->BD5_NUMIMP := PLSA500GCF("R502","NR_NOTA")
	If len(BD5->BD5_HORPRO) == 6
		BD5->BD5_HORPRO := Substr(cDatAte,11,2) +Substr(cDatAte,14,2) +Substr(cDatAte,17,2)
	Else
		BD5->BD5_HORPRO := Substr(cDatAte,11,2) +Substr(cDatAte,14,2)
	EndIf
	
	BD5->(MsUnlock())
Endif

//Busca e atualiza os eventos que foram previamente autorizado

cChave    := xFilial("BD6")+&(cAliasPLS+"->("+cAliasPLS+"_CODOPE+"+cAliasPLS+"_CODLDP+"+cAliasPLS+"_CODPEG+"+cAliasPLS+"_NUMERO+"+cAliasPLS+"_ORIMOV)")
cChaveMat := xFilial("BD6")+&(cAliasPLS+"->("+cAliasPLS+"_OPEUSR+"+cAliasPLS+"_CODEMP+"+cAliasPLS+"_MATRIC+"+cAliasPLS+"_TIPREG+"+cAliasPLS+"_DIGITO)")

BD6->(DbSetOrder(1))
If BD6->(DbSeek(cChave))
	While ! BD6->(Eof()) .And. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == cChave
		
		//Aqui eu pego todos os procedimentos que estao na guia pre autorizada
		
		aadd(aEventos,{BD6->BD6_SEQUEN,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->(Recno()),BD6->BD6_QTDPRO})
		
		BD6->(DbSkip())
	Enddo
Else
	If Empty(cNomArq)
		cNomArq := IIF(!Empty(cArquivo), Substr(cArquivo, RAT("\",cArquivo)+1, Len(cArquivo)), cNomArq)
	EndIf
	aadd(aCritNota,{cNomArq,cNotaArq,"46"," Chave Alias "+cAliasPLS,cChave})
Endif

//Salva posicao em que estou no arquivo de importacao...
nRecno    := Trb->(Recno())

//Busca todas os procedimentos da nota em questao
While !Trb->(Eof())
	If Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "504"
		cAuxDat  := PLSA500GCF("R504","DT_SERVICO")
		cDataPro := subs(cAuxDat,7,2)+"/"+subs(cAuxDat,5,2)+"/"+subs(cAuxDat,1,4)
		cHorPro  := PLSA500GCF("R504","HR_INICIAL")
		cHorFim  := PLSA500GCF("R504","HR_FINAL")
		cTpPart  := alltrim(PLSA500GCF("R504","TP_PARTICI"))
		If (nI:=aScan(aBD6Nota,{|x| x[1]+x[2]+x[4]+x[5] == cValToChar(PLSA500GCF("R504","CD_SERVICO"))+cDataPro+cHorPro+AllTrim(PLSA500GCF("R504","CD_VIA_ACE")) }))  == 0 .or. ;
				(nI > 0 .and. aScan(aBD6Nota[nI][3],{|x| x[1] == cTpPart} ) > 0)
			
			aadd(aBD6Nota,{ cValToChar(PLSA500GCF("R504","CD_SERVICO")),;
				cDataPro,;
				{{cTpPart,Trb->(Recno())}} ,;
				cHorPro,;
				AllTrim(PLSA500GCF("R504","CD_VIA_ACE")),;
				cHorFim})
			
		Else
			aadd(aBD6Nota[nI][3],{alltrim(PLSA500GCF("R504","TP_PARTICI")),Trb->(Recno())} )
		Endif
	Endif
	Trb->(DbSkip())
	If     Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "504"
		If PLSA500GCF("R504","NR_LOTE")+PLSA500GCF("R504","NR_NOTA") <> cNotaArq
			Exit
		Endif
	ElseIf Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "502"
		If PLSA500GCF("R502","NR_LOTE")+PLSA500GCF("R502","NR_NOTA") <> cNotaArq
			Exit
		Endif
	Endif
Enddo

//Verifica se todos os itens autorizados estao em conforme com o cobrado

aBD7Ger := {}

If Len(aBD6Nota) > 0 .And. lExB5T_B6T
	nRecnoB5T := PLPTAtuB5T(cCodOpe,cLotePre,cNumGuiPre,cMatric,cAliasPLS)
EndIf

For nI:= 1 to Len(aBD6Nota)
	For nJ := 1 to Len(aBD6Nota[nI][3])
		Trb->(DbGoTo(aBD6Nota[nI][3][nJ][2]))
		
		If nJ < Len(aBD6Nota[nI][3])
			nNextRec := aBD6Nota[nI][3][nJ+1][2]
		Else
			If nI < Len(aBD6Nota)
				nNextRec := aBD6Nota[nI+1][3][1][2]
			Else
				nNextRec := 0
			Endif
		Endif
		
		If PLSA500GCF("R504","TP_TABELA") $ '0/4'
			nQtdCob := val(Substr(PLSA500GCF("R504","QT_COBRADA"),1,4))
		Else
			nQtdCob := Val(Substr(PLSA500GCF("R504","QT_COBRADA"),1,4)+"."+Substr(PLSA500GCF("R504","QT_COBRADA"),5,4))
		EndIf
		cDataPro := aBD6Nota[nI][2]
		
		If len(BD6->BD6_HORPRO) > 4
			cHorPro  := alltrim(strtran(subs(aBD6Nota[nI][4],1,8),':',''))
		Else
			cHorPro  := alltrim(strtran(subs(aBD6Nota[nI][4],1,5),':',''))
		EndIf
		
		If !Empty(cHorFim)
			If len(BD6->BD6_HORFIM) > 4
				cHorFim  := alltrim(strtran(subs(aBD6Nota[nI][6],1,8),':',''))
			Else
				cHorFim  := alltrim(strtran(subs(aBD6Nota[nI][6],1,5),':',''))
			EndIf
		EndIf
		
		dDataPro := ctod(cDataPro)
		
		If lPL500CFN
			cVarSer := ExecBlock("PL500CFN",.F.,.F.,{PLSA500GCF("R504","CD_SERVICO"),cUniOri,cDataPro,cChaveMat})
		Else
			cVarSer := PLSA500GCF("R504","CD_SERVICO")
		Endif
		
		nPos := Ascan(aEventos,{ |x| alltrim(x[3]) == alltrim(cVarSer) .and. nQtdCob == x[5] } )
		aadd(aEventosCob,cVarSer)
		
		If nPos == 0
			
			//Evento esta sendo cobrado porem nao existe na autorizacao previa devo
			//incluir ele na guia pre-autorizada...
			
			CriaEvento(nNextRec,aBD6Nota[nI][3],nJ,,BD6->(RECNO()),cHorPro,cMatric,,@aBD7Ger,nRecnoB5T)//cria o evento para a guia pre-autorizada...
			
			BD6->(RecLock("BD6",.F.))
			BD6->BD6_QTDPRO := nQtdCob
			BD6->BD6_DATCOB := dDataPro
			BD6->BD6_DATPRO := dDataPro
			BD6->BD6_HORCOB := cHorPro
			BD6->BD6_MATCOB := cMatrCob
			BD6->BD6_NOMCOB := cNomCob
			BD6->BD6_INCAUT := "1"
			BD6->(MsUnLock())
			
		Else
			BD6->(DbGoTo(aEventos[nPos,4]))
			
			BD6->(RecLock("BD6",.F.))
			BD6->BD6_DATCOB := dDataPro
			BD6->BD6_DATPRO := dDataPro
			BD6->BD6_HORCOB := cHorPro
			BD6->BD6_HORPRO := cHorPro
			BD6->BD6_HORFIM := cHorFim
			BD6->BD6_MATCOB := cMatrCob
			BD6->BD6_NOMCOB := cNomCob
			BD6->BD6_INCAUT := "*"
			BD6->BD6_RDAEDI := PLSA500GCF("R504","CD_PREST")
			BD6->BD6_NOMEDI := cNOMEDI
			BD6->BD6_TRDAED := cTRDAED
			BD6->BD6_RPEDI  := cRPEDI
			BD6->BD6_TPRDAE := PLSA500GCF("R504","TP_PESSOA")
			BD6->BD6_CNPJED := PLSA500GCF("R504","NR_CNJP_CP")
			BD6->BD6_ESPEDI := getEspEdi(PLSA500GCF("R504","NR_CBO_EXE"))
			BD6->BD6_FATMUL := Val(PLSA500GCF("R504","FAT_MULT_S")) / 100 //Val(transform(PLSA500GCF("R504","FAT_MULT_S"), "@E 9.99")) 
			BD6->BD6_DES500 := IIf(Empty(PLSA500GCF("R504","DS_SERVICO")),BR8->BR8_DESCRI,PLSA500GCF("R504","DS_SERVICO"))
			If PLSA500GCF("R504","ID_PACOTE")=="S"
				BD6->BD6_CD_PAC := PLSA500GCF("R504","CD_PACOTE")
			elseIF empty(PLSA500GCF("R504","ID_PACOTE"))
				BD6->BD6_CD_PAC := PLSA500GCF("R504","CD_SERVICO")
			Endif
			
			cHoraFim := PLSA500GCF("R504","HR_FINAL")
			If !Empty(cHoraFim)
				cHoraFim := strtran(cHoraFim,':','')
				If len(BD6->BD6_HORFIM) > 4
					BD6->BD6_HORFIM := (SUBSTR (cHoraFim,1,2) + SUBSTR (cHoraFim,3,2)+SUBSTR (cHoraFim,5,2))
				Else
					BD6->BD6_HORFIM := (SUBSTR (cHoraFim,1,2) + SUBSTR (cHoraFim,3,2))
				Endif
			EndIf
			
			If BD6->BD6_PROCCI == "1"
				Do Case
				Case PLSA500GCF("R504","TEC_UTILIZ") == "1"
					BD6->BD6_TECUTI := 'C'
				Case PLSA500GCF("R504","TEC_UTILIZ") == "2"
					BD6->BD6_TECUTI := 'V'
				Case PLSA500GCF("R504","TEC_UTILIZ") == "3"
					BD6->BD6_TECUTI := 'R'
				Case Empty(PLSA500GCF("R504","TEC_UTILIZ"))
					BD6->BD6_TECUTI :=  '1'
				EndCase
			EndIf
			
			
			BD6->(MsUnLock())
			lForNBD6 := If(ascan(aRecBD6,BD6->(RECNO()))>0,.f.,.t.)
			CriaEvento(nNextRec,aBD6Nota[nI][3],nJ,lForNBD6,BD6->(RECNO()),cHorPro,cMatric,,@aBD7Ger,nRecnoB5T)
			aadd(aRecBD6, BD6->(RECNO()))
		Endif
	Next
Next

//Analisa se tudo que eu autorizei foi cobrado, p evitar que eu nao pague algo que ele nao esta cobrando
//aEventos - Eventos que eu autorizei
//aEventosCob - Eventos que a operadora destino esta me cobrando
If PLSPOSGLO(PLSINTPAD(),__aCdCri090[1],__aCdCri090[2],cLocalExec)
	For nFor := 1 To Len(aEventos)
		
		nPos := Ascan(aEventosCob,AllTrim(aEventos[nFor,3]))
		
		If nPos == 0 //Eu autorizei, mas ele nao me cobrou
			
			BD6->(DbGoTo(aEventos[nFor,4]))
			
			BD6->(RecLock("BD6",.F.))
			
				PLBLOPC("BD6", (mv_par17 <> 1), __aCdCri090[1], PLSBCTDESC(), .t., .f., iIf(mv_par17 <> 1,.t.,.f.))
			
				BD6->BD6_INCAUT := "X"
				BD6->BD6_MATCOB := cMatrCob
				BD6->BD6_NOMCOB := cNomCob
				
			BD6->(MsUnLock())
			
			BD7->(DbSetOrder(1))
			If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
				While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
						xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
					
					BD7->(RecLock("BD7",.F.))
					
						PLBLOPC("BD7", (mv_par17 <> 1), __aCdCri090[1], PLSBCTDESC())
					
					BD7->(MsUnLock())
					
					BD7->(DbSkip())
				Enddo
			Endif
		Endif
	Next
Endif


//Restaura a posicao de onde estava sendo importado o PTU 500
Trb->(DbGoTo(nRecno))
	
Return

/*/{Protheus.doc} AppFromTXT
Função de Importação de TXT para alias exclusivo TRB
Identifica linhas com CRLF e apenas LF ( formatos windows e Linux )
@author PLS TEAM
@since 17.01.2005
@version P12
/*/
Static Function AppFromTXT(cTXTFile)
Local nH , nTam , nBuff , cBuff , cTXTBuff := ""
Local lPLS500LI := ExistBlock("PLS500LI")

nH := fopen(cTXTFile)

if nH == -1
	Return -1 // Falha de abertura
Endif

nTam := fseek(nH,0,2)
fseek(nH,0)

If nTam <= 0
	fclose(nH)
	Return -2 // Tamanho do arquivo invalido
Endif

While nTam > 0 .or. !empty(cTXTBuff)
	
	If len(cTXTBuff) < 10000 .and. nTam > 0
		// Mantem um buffer minimo de 10K do arquivo em memória
		nBuff := min(10000,nTam)
		cBuff := space(nBuff)
		nRead := fread(nH,@cBuff,nBuff)
		If nRead<>nBuff
			fclose(nH)
			Return -3 // Falha de Leitura
		Endif
		cTXTBuff += left(cBuff,nBuff)
		nTam := nTam - nBuff
	Endif
	
	// Identifica linhas do arquivo com CRLF e LF
	nPos := at(chr(10),cTXTBuff)
	If nPos > 0
		IF substr(cTXTBuff,nPos-1,1) == chr(13)
			cLine := substr(cTXTBuff,1,nPos-2)
		Else
			cLine := substr(cTXTBuff,1,nPos-1)
		Endif
		cTXTBuff := substr(cTXTBuff,nPos+1)
		
		// Identifica linhas do arquivo com CR
	ElseIf at(chr(13),cTXTBuff) > 0
		nPos := at(chr(13),cTXTBuff)
		cLine := substr(cTXTBuff,1,nPos-1)
		cTXTBuff := substr(cTXTBuff,nPos+1)
		
	Else
		
		cLine := cTXTBuff
		cTXTBuff := ''
		
	Endif
	
	If lPLS500LI
		cLine := ExecBlock("PLS500LI",.F.,.F.,{cLine})
	EndIf
	
	If !Empty(cLine)
		Trb->(dbappend(.T.))
		Trb->CAMPO := cLine
	Endif
	
	cLine := ""
	
Enddo

fclose(nH)

// Reposiciona no topo a tabela
TRB->(dbCommit())
Trb->(DbGoTop())
	
Return 0 // Append Ok

/*/{Protheus.doc} AnalisaAmb

@author PLS TEAM
@since 17.01.2005
@version P12
/*/
Static Function AnalisaAmb()
LOCAL lRet := .T.
LOCAL aRetAux
LOCAL aCri := {}

aRetAux := PLSXVLDCAL(dDataBase,PLSINTPAD(),.T.,"","")

If Len(aRetAux) >= 4 .and. empty(cAMPAG)
	cAMPAG := aRetAux[4]+aRetAux[5]
Else
	aadd(aCri,{"Nao existe calendario de pagamento para a competencia atual."})
Endif

If Len(aCri) > 0
	lRet := .F.
Endif
	
Return({lRet,aCri})
/*/{Protheus.doc} CarregaCrit
Carrega criticas padroes
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Static Function CarregaCrit()
//ATENCAO !!! nao excluir nenhum destes aadd e sempre que for adicionar, adiciona-los ao final da funca
aadd(aCriticas,{"01","Arquivo de importacao nao encontrado.","0"})
aadd(aCriticas,{"02","Nao foi possivel criar usuario generico.","0"})
aadd(aCriticas,{"03","Falha ao buscar posicao do tipo de registro.","0"})
aadd(aCriticas,{"04","Falha ao buscar posicao do numero sequencial.","0"})
aadd(aCriticas,{"05","Nao encontrado nenhum tipo de registro para o layout informado.","0"})
aadd(aCriticas,{"06","Layout definido na operadora origem nao disponivel para utilizacao.","0"})
aadd(aCriticas,{"07","Sequencia invalida para o campo NR_SEQ.","1"})
aadd(aCriticas,{"08","Operadora origem nao encontrada.","0"})
aadd(aCriticas,{"09","Operadora origem cadastrada como RDA nao encontrada.","0"})
aadd(aCriticas,{"10","Operadora origem cadastrada como RDA invalida.","0"})
aadd(aCriticas,{"11","Data de geracao invalida.","1"})
aadd(aCriticas,{"12","Numero da competencia invalido.", "1"})
aadd(aCriticas,{"13","Data de vencimento da fatura invalida.","1" })
aadd(aCriticas,{"14","Data de emissao da fatura invalida.","1"})
aadd(aCriticas,{"15","Operadora destino nao encontrada.","1"})
aadd(aCriticas,{"16","Numero de notas (LOTE+NOTA) repetidos em um mesmo lote.","1"})
aadd(aCriticas,{"17","Tipo de nota invalido.","1"})
aadd(aCriticas,{"18","Codigo da excecao ao atendimento invalido.","1"})
aadd(aCriticas,{"19","Codigo de tipo de consulta invalido.","1"})
aadd(aCriticas,{"20","Codigo de indicador do atendimento em ambulatorio invalido.","1"})
aadd(aCriticas,{"21","Codigo do tipo de paciente nao encontrado no cadastro de tipos de pacientes.","1"})
aadd(aCriticas,{"22","Chave (LOTE+NOTA) do registro 502 diferente do registro 503.","1"})
aadd(aCriticas,{"23","Numero de notas (LOTE+NOTA) repetidos em um mesmo lote.","1"})
aadd(aCriticas,{"24","Codigo do tipo de admissao nao encontrado no cadastro de tipos de admissao.","1"})
aadd(aCriticas,{"26","Chave (LOTE+NOTA) do registro 502 diferente do registro 504.","1"})
aadd(aCriticas,{"27","Data do servico invalida.","1"})
aadd(aCriticas,{"28","Nao foi possivel localizar o tipo de nascimento na tabela de tipos de nascimento.","1"})
aadd(aCriticas,{"29","Codigo do PTU nao localizado na tabela de vias de acesso.","1"})
aadd(aCriticas,{"31","Tipo de pessoa informado invalido.","1"})
aadd(aCriticas,{"32","Numero de notas (LOTE+NOTA) repetidos em um mesmo lote.","1"})
aadd(aCriticas,{"33","Quantidade de registros do tipo 502 invalida.","1"})
aadd(aCriticas,{"34","Quantidade de registros do tipo 503 invalida.","1"})
aadd(aCriticas,{"35","Quantidade de registros do tipo 504 invalida.","1"})
aadd(aCriticas,{"36","Quantidade de registros do tipo 505 invalida.","1"})
aadd(aCriticas,{"37","Quantidade de registros, com excecao diferente de zero, invalida.","1"})
aadd(aCriticas,{"38","Quantidade de registros de ambulatorio invalida.","1"})
aadd(aCriticas,{"39","Quantidade total de servicos cobrados invalida.","1"})
aadd(aCriticas,{"40","Valor total de servicos [VL_TOT_SER] nos registros do tipo 504 invalido.","1"})
aadd(aCriticas,{"41","Valor total da fatura (HEADER), nao corresponde ao somatorio dos valores.","1"})
aadd(aCriticas,{"43","Campo do tipo de registro nao encontrado no layout.","1"})
aadd(aCriticas,{"44","Campo do tipo de registro nao encontrado no layout.","1"})
aadd(aCriticas,{"45","Codigo do servico nao encontrado.","1"})
aadd(aCriticas,{"46","Nota pre-autorizada sem eventos autorizados encontratos.","0"})
aadd(aCriticas,{"47","Campo data de internacao x data de alta invalido na guia de internacao.","1"})
aadd(aCriticas,{"48","Codigo de procedimento existente porem sem unidade definida na tde.","1"})
aadd(aCriticas,{"49","Para a conversao de CBHPM para AMB deve ser informado o parametro 'Tp.Tab. CBHPM' corretamente.","0"})
aadd(aCriticas,{"50","Codigo de procedimento generico nao localizado na tabela padrao.","0"})
aadd(aCriticas,{"51","Arquivo de importacao informado ja importado com a sequencia de importacao informada.","0"})
aadd(aCriticas,{"52","Valor total apresentado pela unimed diferente do total importado.","0"})
aadd(aCriticas,{"53","Guia do arquivo PTU nao encontrada como importada.","0"})
aadd(aCriticas,{"54","Nao localizado nro. do imp. no arquivo, verif. a regra de gravacao do impresso.","0"})
aadd(aCriticas,{"55","Nao localizado nro. do imp. no sistema, verif. a regra de gravacao do impresso.","0"})
aadd(aCriticas,{"56","Nao existe registro 504 para o registro 502 no arquivo informado.","1"})
aadd(aCriticas,{"57","Valor importado no campo BD7_VLRAPR diferente do total da fatura.","1"})
aadd(aCriticas,{"58","Quantidade de valores apresentados no registro 504 maior que a composicao do procedimento.","1"})
aadd(aCriticas,{"59","Preenchimento do campo TP_OBSTETRICIA obrigatorio para a nota informada.","1"})
aadd(aCriticas,{"60","Ao menos um dos campos das sequencias 017 a 021 devem ser preenchidos.","1"})
aadd(aCriticas,{"61","Preenchimento do campo TP_SAIDA_CONS_SADT obrigatorio para guias de servico.","1"})
aadd(aCriticas,{"62","Incompatibilidade entre participacoes enviadas e a participacao do procedimento.","1"})
aadd(aCriticas,{"63","Informado registro do tipo 503 sem que existam diarias informadas no lote.","1"})
aadd(aCriticas,{"64","Dominio do carater de atendimento invalido, para os procedimentos contidos na nota.","1"})
aadd(aCriticas,{"65","Para o tipo de atendimento 07 (SADT Internado) o naoero da guia principal deve ser informado.","1"})
aadd(aCriticas,{"66","Conteudo campo tipo de admissao invalido.","1"})
aadd(aCriticas,{"67","Tipo de internação informado no regitro 503 invalido.","1"})
aadd(aCriticas,{"68","Ao menos um dos campos das seqüências 022 a 030 deveria estar sinalizado como Sim.","1"})
aadd(aCriticas,{"69","Os campos de sequencia 34 a 38 deveria  ser preenchidos com a quantidade de nascidos vivos.","1"})
aadd(aCriticas,{"70","O campo NR_DECLARA_OBITO deve ser informado pois o campo CD_CID_OBITO foi preenchido.","1"})
aadd(aCriticas,{"71","O campo CD_CNES_PREST deve ser informado para prestadores do tipo hospital.","1"})
aadd(aCriticas,{"72","Senha de autorização do arquivo nao confere com a da guia pre-autorizada","1"})
aadd(aCriticas,{"73","O tipo de atendimento  e uma consulta e o codigo de servico e um procedimento. ","1"})
aadd(aCriticas,{"74","A senha informada esta autorizada para outra Operadora","1"})
aadd(aCriticas,{"75","Arquivo incompativel com o layout selecionado","0"})
aadd(aCriticas,{"76","O procedimento esta bloqueado na Tabela Padrao","1"})
aadd(aCriticas,{"77","Profissional executante anestesista nao encontrado","1"})
aadd(aCriticas,{"78","Reembolso de Anestesista - Rede de Atendimento nao encontrada","1"})
aadd(aCriticas,{"79","Procedimento duplicado encontrado não importado","1"})

Return

/*/{Protheus.doc} PLSConTPA
Carga inicial de dados
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Static Function PLSConTPA()
LOCAL nFor
LOCAL nAux
LOCAL aLista    := {}

BKC->(DbSetOrder(1))

If Existblock("PL500TPA")
	aUnidades := Execblock("PL500TPA",.F.,.F.,{aUnidades})
Endif

For nFor := 1 To Len(aUnidades)
	aLista := {}
	For nAux := 1 To Len(aUnidades[nFor])
		If BKC->(DbSeek(xFilial("BKC")+aUnidades[nFor,nAux]+PLSINTPAD()))
			While ! BKC->(Eof()) .And. BKC->(BKC_FILIAL+BKC_CODIGO+BKC_CODOPE) == xFilial("BKC")+aUnidades[nFor,nAux]+PLSINTPAD()
				aadd(aLista,{AllTrim(BKC->BKC_CODPAR),AllTrim(BKC->BKC_CODIGO)})
				BKC->(DbSkip())
			Enddo
		Endif
	Next
	aadd(aTpPart,aLista)
Next
	
Return

/*/{Protheus.doc} ProcHM
Composicao Honorario
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Static Function ProcHM(cCodigo,cTpPart,nLanc,cCodPA)
LOCAL nPos 		:= If(Ascan(aUnidades[1],cCodigo)>0,1,0)
DEFAULT cCodPA  := ""

If nPos > 0
	If Val(nLanc) <> Val(cTpPart)
		nPos := 0
	Endif
Endif

If nPos == 0
	nPos := If(Ascan(aUnidades[3],cCodigo)>0,3,0)
Endif
If nPos == 0
	nPos := If(Ascan(aUnidades[4],cCodigo)>0 .and. ! empty(cCodPA),4,0)
Endif
If nPos == 0
	nPos := If(Ascan(aUnidades[6],cCodigo)>0,6,0)
Endif
If nPos == 0
	nPos := If(Ascan(aUnidades[7],cCodigo)>0,7,0)
Endif

If nPos > 0
	If cTpPart $ "0"
		nPos := 1 //.t. no return
	Else
		nPos := Ascan(aTpPart[nPos],{ |x| x[1] == cTpPart .And. x[2] == cCodigo })
	Endif
Endif
	
Return(nPos>0)

/*/{Protheus.doc} ProcCOP
Composicao Honorario
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Static Function ProcCOP(cCodigo,cTpPart)
LOCAL nPos := If(Ascan(aUnidades[2],cCodigo)>0,2,0)

If nPos > 0
	If cTpPart $ "0"
		nPos := 1 //.t. no return
	Else
		nPos := Ascan(aTpPart[nPos],{ |x| x[1] == cTpPart .And. x[2] == cCodigo })
	Endif
Endif
	
Return(nPos>0)

/*/{Protheus.doc} ProcFIL
Composicao Honorario
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Static Function ProcFIL(cCodigo,cTpPart)
LOCAL nPos := If(Ascan(aUnidades[5],cCodigo)>0,5,0)

If nPos > 0
	If cTpPart $ "0"
		nPos := 1 //.t. no return
	Else
		nPos := Ascan(aTpPart[nPos],{ |x| x[1] == cTpPart .And. x[2] == cCodigo })
	Endif
Endif
	
Return(nPos>0)


/*/{Protheus.doc} JaImportado
Verifica se o arquivo jah foi importado
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
static function JaImportado(cArquivo)
local lFound     	:= .F.
local aDirArq    	:= DIRECTORY(cArquivo)
local cArqBusca  	:= ""
local cSql 			:= ""
if Len(aDirArq) > 0
	cArqBusca := aDirArq[1,1]
endif

cSql := " SELECT 1 FROM " + RetSqlName("BRJ") 
cSql += " WHERE BRJ_FILIAL = '" + xFilial("BRJ") + "' "
cSql += " AND UPPER(BRJ_ARQUIV) LIKE '%" + UPPER(cArqBusca) + "%' "
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMPBRJ",.F.,.T.)

if TMPBRJ->(!eof())
	lFound := .t.
endif
TMPBRJ->(dbclosearea())
return(lFound)


/*/{Protheus.doc} ProcPerImp
Verifica se pode ocorrer a importacao
@author Daher
@since 17.01.2005
@version P12
/*/
Static Function ProcPerImp(cLayPLS,cArquivo,lImportar,lGerarLog,cCodLDP,lMudarFase,cCodProGen,cAMPAG,lConverProc,cCodPadCon,nRegraGrvImp)	
LOCAL aRet 		:= {}
LOCAL aUnidPad  := {{"AUX",4},{"HM",1},{"PA",1},{"COP",1}} //[1]unidade [2]referencia
LOCAL aUnidUsr  := {}
LOCAL nI		:= 1
LOCAL cCodPro   := ""
LOCAL cCodTab   := ""
LOCAL cCdPaDp   := ""
Local cNomArq	:= Substr( cArquivo, RAT("\",cArquivo)+1, Len(cArquivo) )

If JaImportado(cArquivo)
	CarregaCrit()
	aadd(aRet,{cNomArq,aCriticas[48,1],aCriticas[48,2]})
Endif

If lConverProc
	BR4->(DbSetOrder(1))
	If ! BR4->(DbSeek(xFilial("BR4")+cCodPadCon))
		CarregaCrit()
		aadd(aRet,{cNomArq,aCriticas[46,1],aCriticas[46,2]})
	Endif
Endif

BR8->(DbSetOrder(3))
If ! BR8->( MsSeek( xFilial("BR8") + cCodProGen)) .or. Empty(cCodProGen)
	CarregaCrit()
	aadd(aRet,{cNomArq,aCriticas[47,1], aCriticas[47,2]})
Else
	BA8->(DbSetOrder(4))
	If BA8->( MsSeek( xFilial("BA8") + cCodProGen))
		
		cCodPro := BA8->BA8_CODPRO // esse aqui eh o codigo do proc generico
		cCodTab := BA8->BA8_CODTAB
		cCdPaDp := BA8->BA8_CDPADP
		
		BD4->(DbSetOrder(2))
		If BD4->(MsSeek(xFilial("BD4") + cCodPro + cCodTab))
			
			While BD4->(!Eof()) .and. BD4->(BD4_FILIAL+BD4_CODPRO+BD4->BD4_CODTAB) == xFilial("BD4")+cCodPro+cCodTab
				aadd(aUnidUsr,{alltrim(BD4->BD4_CODIGO),BD4->BD4_VALREF})
				BD4->(DbSkip())
			Enddo
			
			//todo proc. generico tem q ter essas unidades, se nao tiver eu crio
			For nI := 1 to len(aUnidPad) 
				
				If aScan(aUnidUsr,{|x| x[1] == aUnidPad[nI][1] .and. x[2] == aUnidPad[nI][2]}) == 0
				
					BD4->(Reclock("BD4",.T.))
					BD4->BD4_FILIAL := xFilial("BD4")
					BD4->BD4_CODPRO := cCodPro
					BD4->BD4_CODTAB := cCodTab
					BD4->BD4_CDPADP := cCdPaDp
					BD4->BD4_CODIGO := aUnidPad[nI][1]
					BD4->BD4_VALREF := aUnidPad[nI][2]
					BD4->(MsUnlock())
					
				Endif
				
			Next
			
		Else
			//todo proc. generico tem q ter essas unidades, se nao tiver eu crio
			For nI := 1 to len(aUnidPad) 
				
				BD4->(Reclock("BD4",.T.))
				BD4->BD4_FILIAL := xFilial("BD4")
				BD4->BD4_CODPRO := cCodPro
				BD4->BD4_CODTAB := cCodTab
				BD4->BD4_CDPADP := cCdPaDp
				BD4->BD4_CODIGO := aUnidPad[nI][1]
				BD4->BD4_VALREF := aUnidPad[nI][2]
				BD4->(MsUnlock())
				
			Next
			
		Endif
		
	Endif
	
Endif

Return aRet

/*/{Protheus.doc} PlRetCidGe
Retorna um codigo de cid Generico
@author Daher
@since 17.01.2005
@version P12
/*/
function PlRetCidGe()
LOCAL cCodCid := GetNewPar("MV_PLCDGEN","00000000")
BA9->(DbSetOrder(1))
If !BA9->(MsSeek(xFilial("BA9")+cCodCid))
	BA9->(RecLock("BA9",.T.))
	BA9->BA9_CODDOE := cCodCid
	BA9->BA9_DOENCA := "CID GENERICO PARA USO NO PTU 500 IMPORTACAO"
	BA9->BA9_ABREVI := "CID GENERICO"
	BA9->(MsUnlock())
endif
return cCodCid



/*/{Protheus.doc} AltCodUsr
Posiciona usuario conforme data de atendimento
@author Thiago Machado Correa
@since 17.01.2005
@version P12
/*/
Static Function AltCodUsr(dDatAte)
Local lRet := .F.
Local lSai := .F.
Local lErr := .F.
Local aAreaBA1 := BA1->(GetArea())

BA1->(DbSetOrder(2))

//Posiciona no ultimo codigo do usuario
While ! Empty(BA1->BA1_TRADES)
	If BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) <> BA1->BA1_TRADES
		BA1->(MsSeek(xFilial("BA1")+BA1->BA1_TRADES))
	Else
		lErr := .T.
		Exit
	Endif
EndDo

If ! lErr .and. ! BA1->(Eof())
	
	While ! lSai
		
		//Testa Data
		If dDatAte >= BA1->BA1_DATINC
			lRet := .T.
			Exit
		Endif
		
		//Reposiciona Usuario
		If Empty(BA1->BA1_TRAORI)
			lSai := .T.
		Else
			BA1->(DbSetOrder(2))
			If ! BA1->(MsSeek(xFilial("BA1")+BA1->BA1_TRAORI))
				lSai := .T.
			Endif
		Endif
		
	EndDo
	
Endif

If ! lRet
	RestArea(aAreaBA1)
Endif
	
Return lRet

/*/{Protheus.doc} RetGuia
Retorna o codigo completo de uma guia.
@author Tulio Cesar
@since 17.01.2005
@version P12
/*/
Static Function RetGuia(cAlias)
LOCAL cRet := ""

If cAlias $ "BD5/BE4"
	cRet := &(cAlias+"->"+cAlias+"_CODOPE")+"."+&(cAlias+"->"+cAlias+"_CODLDP")+"."+;
		&(cAlias+"->"+cAlias+"_CODPEG")+"."+&(cAlias+"->"+cAlias+"_NUMERO")
Endif
	
Return(cRet)

/*/{Protheus.doc} ImpCriT
Imprime uma critica
@author Daher
@since 17/07/06
@version P12
/*/
Static Function ImpCriT(aCritRea,aCab01,aResum,aCab02,aCritNot,aCab03,aNota,aCab04,cTitulo,cTpRel,nTmRel)
LOCAL aPrints := {}
LOCAL nI := 0

If Len(aCritRea) > 0
	aadd(aPrints,{"criticas do arquivo",aCritRea,aCab01})
Endif
If Len(aResum) > 0
	aadd(aPrints,{"guias geradas",aResum,aCab02})
Endif
If Len(aCritNot) > 0
	aadd(aPrints,{"criticas das guias",aCritNot,aCab03})
Endif
If Len(aNota) > 0
	aadd(aPrints,{"outras criticas",aNota,aCab04})
Endif

For nI:=1 To Len(aPrints)
	If MsgYesNo("Imprimir "+aPrints[nI][1]+" ?")
		RImpCriT(aPrints[nI][2],aPrints[nI][3],aPrints[nI][1],cTpRel,nTmRel)
	Endif
Next
	
Return

/*/{Protheus.doc} RImpCriT
Imprime uma critica
@author Daher
@since 17.01.2005
@version P12
/*/
Static Function RImpCriT(aDados,aCabec,cTit,cTpRel,nTmRel)
LOCAL nFor
LOCAL nFor2
LOCAL cDado
LOCAL uDado
PRIVATE nQtdLin     := 58       // Qtd de Linhas Por Pagina
PRIVATE nLimite     := 132       // Limite de Colunas
PRIVATE cTamanho    := "M"       // P=Pequeno;M=Medio;G=Grande -> P=80;M=132;G=220 (colunas)
PRIVATE cTitulo     := cTit // Titulo do Relatorio
PRIVATE cDesc1      := cTitulo // Descritivo para o usuario
PRIVATE cDesc2      := "" // Descritivo para o usuario
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BA1" // Alias
//PRIVATE cPerg       := nil // Pergunta padrao (SX1) dos parametros
PRIVATE cRelNome    := "IMPCRIGEN" // Nome do Relatorio
PRIVATE cRel
PRIVATE nli         := 01   // Variavel padrao para controlar numero de linha
PRIVATE nQtdini     := nli  // Variavel para controlar numero de linha inicial
PRIVATE m_pag       := 1    // Variavel padrao para contar numero da pagina
PRIVATE lCompres    := .F. // nao mude e padrao
PRIVATE lDicion     := .F. // nao mude e padrao
PRIVATE lFiltro     := .F. // Habilitar o filtro ou nao
PRIVATE lCrystal    := .F. // nao mudar controle do crystal reports
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 } // padrao nao mude
PRIVATE lAbortPrint := .F. // Controle para abortar (sempre como esta aqui)
PRIVATE cCabec1     := "" // Primeira linha do cabecalho ;
	PRIVATE cCabec2     := "" // utilizado pela funcao cabec...
PRIVATE nColuna     := 03 // Numero da coluna que sera impresso as colunas

DEFAULT cTpRel     := "M"
DEFAULT nTmRel     := 132

nLimite     := nTmRel
cTamanho    := cTpRel

//Chama SetPrint (padrao)

cRel  := SetPrint(cAlias,cRelNome,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)

//Verifica se foi cancelada a operacao (padrao)

If nLastKey  == 27 // Verifica o cancelamento...
	Return
Endif

//Configura impressora (padrao)

SetDefault(aReturn,cAlias)

@ ++nLi, nColuna pSay "**** "+cTit+" ****"

@ ++nLi, nColuna pSay Replicate("*",nLimite-nColuna)
cDado := ""
For nFor := 1 To Len(aCabec)
	cDado += aCabec[nFor,1]+Space(10)
Next
@ ++nLi, nColuna pSay cDado
@ ++nLi, nColuna pSay Replicate("*",nLimite-nColuna)

For nFor := 1 To Len(aDados)
	cDado := ""
	For nFor2 := 1 To Len(aCabec)
		uDado := aDados[nFor,nFor2]
		If     ValType(uDado) == "C"
			cDado += uDado+Space(02)
		ElseIf ValType(uDado) == "D"
			cDado += dtoc(uDado)+Space(02)
		ElseIf ValType(uDado) == "N"
			cDado += str(uDado,17,4)+Space(02)
		Endif
	Next
	@ ++nLi, nColuna pSay cDado
Next

@ ++nLi, nColuna pSay Replicate("*",nLimite-nColuna)
@ ++nLi, nColuna pSay StrZero(Len(aDados),2)+" Registro(s) Listado(s)"
@ ++nLi, nColuna pSay Replicate("*",nLimite-nColuna)

If  aReturn[5] == 1
	Set Printer To
	Ourspool(cRel)
EndIf
	
Return

/*/{Protheus.doc} ValidaSenha

@author PLS TEAM
@since 17.01.2005
@version P12
/*/
Static Function ValidaSenha(cSenhaPLS,cCodLDP,cSenNrOp)
Local 	lOk			:= .T.
DEFAULT cSenhaPLS 	:= ""
DEFAULT cAliasPLS 	:= ""
BD5->(DbSetOrder(7))
BE4->(DbSetOrder(7))

If Empty(cSenhaPLS) .Or. Val(cSenhaPLS) == 0
	lOk := .F.
Else
	If !BD5->(MsSeek(xFilial("BD5") + AllTrim(cSenhaPLS)))
		If !BE4->(MsSeek(xFilial("BE4") + AllTrim(cSenhaPLS)))
			lOk := .F.
		Else
			If Empty(mv_par05)
				cCodLDP:=BE4->BE4_CODLDP
			Endif
		EndIf
	Else
		If Empty(mv_par05)
			cCodLDP:=BD5->BD5_CODLDP
		Endif
	EndIf
	
	cTpFasSt:='211'
	
	If !lOk
		
		cSenNrOp := StrZero(Val((PLSA500GCF("R504","NR_AUTORIZ"))),10)
		
		BD5->(DbSetOrder(8))
		BE4->(DbSetOrder(8))
		
		If BD5->(MsSeek(xFilial("BD5") + AllTrim(cSenNrOp)))
			
			lOk := .T.
			
			If Empty(mv_par05)
				cCodLDP:=BD5->BD5_CODLDP
			Endif
			
		EndIf
		
		If !lOk .And. BE4->(MsSeek(xFilial("BE4") + AllTrim(cSenNrOp)))
			
			lOk := .T.
			
			If Empty(mv_par05)
				cCodLDP:=BE4->BE4_CODLDP
			Endif
			
		EndIf
		
	EndIf
	
EndIf
	
Return(lOk)


/*/{Protheus.doc} MenuDef
MenuDef
@author Darcio R. Sporl
@since 17.01.2005
@version P12
/*/
Static Function MenuDef()
	
Local nItem := 0
Private aRotina := {	{ "Pesquisar"      ,'AxPesqui'    , 0, K_Pesquisar  , 0, .F.},;
	{ "Visualizar"     ,'PLSED500VS'  , 0, K_Visualizar , 0, Nil},;
	{ "Importar"       ,'PLSED500MV'  , 0, K_Incluir    , 0, Nil},;
	{ "Canc.Importacao",'PLSED500CN'  , 0, K_Alterar    , 0, Nil}}

Aadd(aRotina,{ "Guias Reemb"    	    , "PLSA984", 0 , K_Alterar , 0, .F.})
if findFunction( "PLSP500ANA" )
	aadd(aRotina,{ "Analisar"    	    	, "PLSP500ANA(0)", 0 , K_Visualizar , 0, .F.})
endif

If ExistBlock("PL500MNU")	//	P.E. para incluir itens no aRotina (Menu)
	aItens := ExecBlock("PL500MNU",.F.,.F.)
	If ValType(aItens) == "A"
		For nItem := 1 To Len(aItens)
			Aadd(aRotina, aItens[nItem])
		Next
	EndIf
Endif
	
Return(aRotina)

/*/{Protheus.doc} PLSP500CP
Funcao para validar se a PEG da guia posicionada deve ser excluida
@author Victor Ferreira
@since 17.01.2005
@version P12
/*/
Function PLSP500CP(cSeqImp,cCodLdp,cCodPeg)
Local cAliasTrb		:= GetNextAlias()
Local lRet 			:= .T.
Local cOpePad       := PlsIntPad()
BeginSql Alias cAliasTrb
	SELECT COUNT(*) COUNT FROM %table:BD6% BD6
	WHERE 	BD6_FILIAL 		=  	%exp:xFilial("BD6")%
	AND     BD6_CODOPE      =   %exp:cOpePad%
	AND 	BD6_CODLDP		= 	%exp:cCodLdp%
	AND 	BD6_CODPEG		= 	%exp:cCodPeg%
	AND 	BD6_SEQIMP		<>  %exp:cSeqImp%
	AND 	BD6.%notDel%
Endsql

If (cAliasTrb)->COUNT > 0
	lRet := .F.
Endif

(cAliasTrb)->(DbCloseArea())

Return lRet


/*/{Protheus.doc} BusEveInt
Busca a solicitacao original para preencher o campo excluido
@author PLS TEAM
@since 17.01.2005
@version P12
/*/
Static Function BusEveInt(cSenhaPLS,cNota,cCodOpe,cSenNrOp)
Local lFind     := .F.
Local aEventos  := {}
Local cAliasPLS := "BE4"
Local cChave    := ""
Local cNomArq	:= ""

Default cSenNrOp:= ""

If ! Empty(cNota)

	BE4->(DbSetOrder(6))//BE4_FILIAL+BE4_NUMIMP
	
	If BE4->(MsSeek(xFilial("BE4") + cNota))
		lFind := .T.
	EndIf
	
EndIf

If ! empty(cSenNrOp) .And. ! lFind .And. Val(cSenNrOp) > 0 .And. ! Empty(cSenNrOp)     //verificacao pelo campo NRAOPE
	
	BE4->(DbSetOrder(8))//BE4_FILIAL+BE4_NRAOPE
	If BE4->(MsSeek(xFilial("BE4") + cSenNrOp)) .and. BE4->BE4_SITUAC == "1" .And. VerOpeSol("BE4",cCodOpe,cSenNrOp,.F.)
		lFind := .T.
	EndIf
	
EndIf

If ! empty(cSenhaPLS) .And. ! lFind .and. val(cSenhaPLS) > 0
	
	BE4->(DbSetOrder(7))//BE4_FILIAL+BE4_SENHA
	If BE4->(MsSeek(xFilial("BE4") + cSenhaPLS)) .and. BE4->BE4_SITUAC == "1" .And. VerOpeSol("BE4",cCodOpe,cSenhaPLS,.F.)
		lFind := .T.
	EndIf
	
EndIf

If lFind
	
	//Busca e atualiza os eventos que foram previamente autorizado
	cChave    := xFilial("BD6")+&(cAliasPLS+"->("+cAliasPLS+"_CODOPE+"+cAliasPLS+"_CODLDP+"+cAliasPLS+"_CODPEG+"+cAliasPLS+"_NUMERO+"+cAliasPLS+"_ORIMOV)")
	
	BD6->(DbSetOrder(1))
	If BD6->(DbSeek(cChave))
		
		While ! BD6->(Eof()) .And. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == cChave
			
			//Aqui eu pego todos os procedimentos que estao na guia pre autorizada
			aadd(aEventos,{BD6->BD6_SEQUEN,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->(Recno()),BD6->BD6_QTDPRO})
			
			BD6->(DbSkip())
		Enddo
		
	Else
		If Empty(cNomArq)
			cNomArq := IIF(!Empty(cArquivo), Substr(cArquivo, RAT("\",cArquivo)+1, Len(cArquivo)), cNomArq)
		EndIf
		aadd(aCritNota,{cNomArq,cNota,"46"," Chave Alias "+cAliasPLS,cChave})
	Endif
EndIf
	
Return(aEventos)

/*/{Protheus.doc} VerOpeSol
Verifica se a senha enviada pertence a operadora correta
@author PLS TEAM
@since 17.01.2005
@version P12
/*/
Static Function VerOpeSol(cAlias,cCodOpe,cSenhaPLS,lLogCri)
Local lRet 	  := .F.
Local aRetFun := {}
Local aAreaBAU := BAU->(GetArea())
DEFAULT lLogCri := .T.

BAU->(DbSetOrder(1))//BAU_FILIAL+BAU_CODIGO
If BAU->(DbSeek(xFilial("BAU")+&(cAlias+"->"+cAlias+"_CODRDA"))) .And. BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE")
	aRetFun := PLSDADRDA(PlsIntpad(),BAU->BAU_CODIGO)
	If aRetFun[28] == cCodOpe
		lRet := .T.
	EndIf
EndIf
If !lRet .And. &(cAlias+"->"+cAlias+"_CODRDA") == GetNewPar("MV_PLSRDAG","999999")
	BAU->(DbSetOrder(7))//BAU_FILIAL+BAU_CODOPE
	If BAU->(DbSeek(xFilial("BAU")+cCodOpe)) .And. BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE")
		lRet := .T.
	EndIf
EndIf

//Se a operadora que liberou for diferente critica

If !lRet .And. lLogCri
	AnalisaCrit("74","Lote/Nota: [ " + PLSA500GCF("R502","NR_LOTE") + " / " + PLSA500GCF("R502","NR_NOTA") + " ]  Senha Informada no arquivo: " + cSenhaPLS )
EndIf

RestArea(aAreaBAU)
	
Return(lRet)

/*/{Protheus.doc} VerIteSol
Verifica se a senha enviada pertence a operadora correta
@author PLS TEAM
@since 17.01.2005
@version P12
/*/
Static Function VerIteSol(cAliasPLS)
Local cLote     := PLSA500GCF("R502","NR_LOTE")+PLSA500GCF("R502","NR_NOTA")
Local cNextLote := cLote
Local nRecno    := Trb->(Recno())
Local aItensArq := {}
Local lRet      := .F.
Local cChave    := ""

//Carrega itens do arquivo

While !Trb->(Eof()) .and. cLote == cNextLote
	
	If Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "504"
		Aadd(aItensArq,{cValToChar(PLSA500GCF("R504","CD_SERVICO"))})
	EndIf
	
	Trb->(DbSkip())
	If 	Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "502"
		cNextLote := PLSA500GCF("R502","NR_LOTE")+PLSA500GCF("R502","NR_NOTA")
	Elseif Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "503"
		cNextLote := PLSA500GCF("R503","NR_LOTE")+PLSA500GCF("R503","NR_NOTA")
	Elseif Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == "504"
		cNextLote := PLSA500GCF("R504","NR_LOTE")+PLSA500GCF("R504","NR_NOTA")
	Else
		cNextLote := "###"
	Endif
Enddo
Trb->(DbGoTo(nRecno))

BD6->(DbSetOrder(1))//BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO

//Verifica se os itens enviados existem na solicitacao

cChave := 	&(cAliasPLS+"->"+cAliasPLS+"_CODOPE")+;
	&(cAliasPLS+"->"+cAliasPLS+"_CODLDP")+;
	&(cAliasPLS+"->"+cAliasPLS+"_CODPEG")+;
	&(cAliasPLS+"->"+cAliasPLS+"_NUMERO")+;
	&(cAliasPLS+"->"+cAliasPLS+"_ORIMOV")

If BD6->(DbSeek(xFilial("BD6")+cChave))
	While BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == cChave .And. !BD6->(Eof())
		If Ascan(aItensArq,{|x| Alltrim(x[1]) == Alltrim(BD6->BD6_CODPRO)}) > 0
			lRet := .T.
			Exit
		EndIf
		BD6->(DbSkip())
	EndDo
EndIf
	
Return lRet


/*/{Protheus.doc} CriBRJReem
Cria guia de reembolso de anestesista
@author PLS TEAM
@since 17.01.2005
@version P12
/*/
Static Function CriBRJReem(cArquivo)
Local cTpPag   := ""
Local aAreaBA0 := {}

aAreaBA0 := BA0->(GetArea())
BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
If BA0->(FieldPos("BA0_TPPAG")) > 0 .And. BA0->(DbSeek(xFilial("BA0")+cUniOri))
	cTpPag := IIf(!Empty(BA0->BA0_TPPAG),BA0->BA0_TPPAG,CriaVar("BRJ_TPPAG"))
Else
	cTpPag := CriaVar("BRJ_TPPAG")
EndIf
RestArea(aAreaBA0)

nHBRJ := PLSAbreSem("PLSBRJ.SMF")
BRJ->(RecLock("BRJ",.T.))
BRJ->BRJ_FILIAL := xFilial("BRJ")
BRJ->BRJ_CODIGO := GetSx8Num("BRJ","BRJ_CODIGO")
BRJ->BRJ_DATA   := dDataBase
BRJ->BRJ_REGPRI := "1"
BRJ->BRJ_ARQUIV := cArquivo
BRJ->BRJ_OPEORI := cUniOri
BRJ->BRJ_NOMORI := BA0->(Posicione("BA0",1,xFilial("BA0")+cUniOri,"BA0_NOMINT"))
BRJ->BRJ_ANO    := "20"+Subs(_NR_COMP,1,2)
BRJ->BRJ_TPPAG  := cTpPag
BRJ->BRJ_ANOPAG := Subs(cAMPAG,1,4)
BRJ->BRJ_MESPAG := Subs(cAMPAG,5,2)
BRJ->BRJ_MES := Subs(_NR_COMP,3,2)
BRJ->BRJ_NUMFAT := _NR_FATURA
If BRJ->(FieldPos("BRJ_VLRNDC")) > 0
	BRJ->BRJ_NRNDC  := _NR_NDC
	BRJ->BRJ_TPCOB  := cValToChar(nTpCob)
	
	If nTpCob == 1
		BRJ->BRJ_VLRNDC := _VL_TOT_NDC
		BRJ->BRJ_VALOR  := _VL_TOT_NDC
	ElseIf nTpCob == 2
		BRJ->BRJ_VALOR  := _VL_TOT_FAT
		BRJ->BRJ_VLRFAT := _VL_TOT_FAT
	ElseIf nTpCob == 3
		BRJ->BRJ_VALOR  := _VL_TOT_FAT + _VL_TOT_NDC
		BRJ->BRJ_VLRNDC := _VL_TOT_NDC
		BRJ->BRJ_VLRFAT  := _VL_TOT_FAT
	Endif
EndIf
BRJ->BRJ_DTEMIS := _DT_EMI_FAT
BRJ->BRJ_DTVENC := _DT_VEM_FAT
BRJ->BRJ_DTENDC := _DT_EMI_NDC
BRJ->BRJ_DTVNDC := _DT_VEM_NDC
BRJ->BRJ_STATUS := "1"
BRJ->BRJ_TIPLOT := "2"
BRJ->BRJ_CAMCOM := PLSRTCCOMP(BRJ->BRJ_OPEORI)
If BRJ->(FieldPos("BRJ_TPDOC1")) > 0 .And. BRJ->(FieldPos("BRJ_TPDOC2")) > 0
	BRJ->BRJ_TPDOC1 := cTipDoc1
	BRJ->BRJ_TPDOC2 := cTipDoc2
EndIf
If BRJ->(FieldPos("BRJ_DOCFI1")) > 0 .And. BRJ->(FieldPos("BRJ_DOCFI2")) > 0
	BRJ->BRJ_DOCFI1 := cDocFis1
	BRJ->BRJ_DOCFI2 := cDocFis2
EndIf

BRJ->(MsUnLock())

BRJ->(ConfirmSX8())
PLSFechaSem(nHBRJ,"PLSBRJ.SMF")

Return

/*/{Protheus.doc} CriGRemAne
Cria guia de reembolso de anestesista
@author Microsiga
@since 17.01.2005
@version P12
/*/
Static Function CriGRemAne(nSeqGui,cArquivo)
Local cCodSer  := ""
Local nFor     := 0
Local nQtd		:= 0
Local cMes		:= strzero(month(stod(PLSA500GCF("R507","DT_REEMBOL"))),2)
Local cAno		:= cvaltochar(year(stod(PLSA500GCF("R507","DT_REEMBOL"))))

Default cArquivo := ""

B7Q->(RecLock("B7Q",.T.))
B7Q->B7Q_FILIAL := xFilial("B7Q")
B7Q->B7Q_CODBRJ := BRJ->BRJ_CODIGO
B7Q->B7Q_SEQGUI := Strzero(nSeqGui,6)
B7Q->B7Q_NRSEQ  := AllTrim(PLSA500GCF("R507","NR_SEQ"))
B7Q->B7Q_LOTE   := AllTrim(PLSA500GCF("R507","NR_LOTE"))
B7Q->B7Q_NOTA   := AllTrim(PLSA500GCF("R507","NR_NOTA"))
B7Q->B7Q_CODOPE := AllTrim(PLSA500GCF("R507","CD_UNI"))
B7Q->B7Q_MATRIC := AllTrim(PLSA500GCF("R507","CD_UNI")) + AllTrim(PLSA500GCF("R507","ID_BENEF"))
B7Q->B7Q_NOMUSR := AllTrim(PLSA500GCF("R507","NM_BENEF"))
B7Q->B7Q_DATNAS := Stod(AllTrim(PLSA500GCF("R507","DT_NASC")))
B7Q->B7Q_SEXO   := IIf( Alltrim(AllTrim(PLSA500GCF("R507","TP_SEXO"))) == "M" ,"1","2")
B7Q->B7Q_ATERNA := IIf( Alltrim(AllTrim(PLSA500GCF("R507","ID_RN"))) == "S" ,"1","0")
B7Q->B7Q_DATREE := Stod(AllTrim(PLSA500GCF("R507","DT_REEMBOL")))
B7Q->B7Q_CARATE := IIf( Alltrim(AllTrim(PLSA500GCF("R507","TP_CARATER"))) == "1" ,"1","2")

If BAU->(DbSeek(xFilial("BAU")+cValtoChar(Val(PLSA500GCF("R507","NR_CNPJ_CP")))))
	B7Q->B7Q_CODRDA := BAU->BAU_CODIGO
	B7Q->B7Q_NOMRDA := BAU->BAU_NOME
Else
	B7Q->B7Q_NOMRDA := AllTrim(PLSA500GCF("R507","NM_PRESTAD"))
	AnalisaCrit("78",PL5GetCo("R507","NR_CNPJ_CP"),PLSA500GCF("R507","NR_CNPJ_CP"),Nil,Nil,Nil,cArquivo )
Endif

B7Q->B7Q_CPFCGC := cValtoChar(Val(PLSA500GCF("R507","NR_CNPJ_CP")))

Trb->(DbSkip())
If Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == '508'
	B7Q->B7Q_NUMAUT := AllTrim(PLSA500GCF("R508","NR_AUTORIZ"))
	B7Q->B7Q_DATSER := Stod(AllTrim(PLSA500GCF("R508","DT_SERVICO")))
Else
	B7Q->B7Q_NUMAUT := ""
	B7Q->B7Q_DATSER := Stod("")
EndIf

B7Q->(MsUnLock())

While Subs(Trb->Campo,_nPosITREG,_nPosFTREG) == '508'
	cCodSer  := cValToChar(PLSA500GCF("R508","CD_SERVICO"))
	nQtd  	:= Val(subStr(PLSA500GCF("R508","QT_COBRADA"),1,4))
	// Procura se existe o evento
	BR8->(DbSetOrder(1))
	If !BR8->(MsSeek(xFilial("BR8")+cCodPaPro+cCodSer))
		AnalisaCrit("45",PL5GetCo("R508","CD_SERVICO"),cValToChar(Val(PLSA500GCF("R508","CD_SERVICO"))),Nil,Nil,Nil,cArquivo )
		Return({nSeqGui})
	EndIf
	
	//Calcula o valor do procedimento
	aValor := PLSCALCEVE(cCodPaPro,cCodSer,cMes,cAno,B7Q->B7Q_CODOPE,BAU->BAU_CODIGO,"",iIf(len(aDadRda)>0,aDadRda[21],''),"",nQtd,,iIf(len(aDadUsr),aDadUsr[48],''),,,,aDadUsr)
	
	B7R->(RecLock("B7R",.T.))
	B7R->B7R_FILIAL := xFilial("B7R")
	B7R->B7R_CODBRJ := BRJ->BRJ_CODIGO
	B7R->B7R_SEQGUI := Strzero(nSeqGui,6)
	B7R->B7R_NRSEQ  := AllTrim(PLSA500GCF("R508","NR_SEQ"))
	B7R->B7R_CODPAD := cCodPaPro
	B7R->B7R_CODPRO := cCodSer
	B7R->B7R_DESPRO	:= BR8->BR8_DESCRI
	B7R->B7R_QTDAPR := Val(Substr(PLSA500GCF("R508","QT_COBRADA"),1,4)+"."+Substr(PLSA500GCF("R508","QT_COBRADA"),5,4))
	B7R->B7R_VLRDIF := Val(Substr(PLSA500GCF("R508","VL_DIF_INT"),1,12)+"."+Substr(PLSA500GCF("R508","VL_DIF_INT"),13,2))
	B7R->B7R_VLRSER := Val(Substr(PLSA500GCF("R508","VL_SERV_CO"),1,12)+"."+Substr(PLSA500GCF("R508","VL_SERV_CO"),13,2))
	
	If !BB0->(DbSeek(xFilial("BB0")+PLSA500GCF("R508","SG_UF_CONS")+;
			Padr(Alltrim(PLSA500GCF("R508","NR_CONS_PR") ),TamSx3("B7R_REGEXE")[1])+;
			Padr(Alltrim(PLSA500GCF("R508","SG_CONS_PR") ),TamSx3("B7R_SIGEXE")[1])))
		AnalisaCrit("77",PL5GetCo("R508","SG_CONS_PR"),PLSA500GCF("R508","SG_UF_CONS"),Nil,Nil,Nil,cArquivo )
	Else
		B7R->B7R_NOMEXE := Alltrim(PLSA500GCF("R508","NM_PROFISS"))
	EndIf
	
	B7R->B7R_VLRBPG := aValor[2]
	nVlrEvento      := B7R->B7R_VLRSER - B7R->B7R_VLRDIF
	
	If (nVlrDifCalc := B7R->B7R_VLRBPG - nVlrEvento) > 0
		B7R->B7R_VLRGLO := B7R->B7R_VLRDIF - nVlrDifCalc
	Else
		B7R->B7R_VLRGLO := 0
	Endif
	
	B7R->B7R_REGEXE := Alltrim(PLSA500GCF("R508","NR_CONS_PR"))
	B7R->B7R_SIGEXE := Alltrim(PLSA500GCF("R508","SG_CONS_PR"))
	B7R->B7R_ESTEXE := Alltrim(PLSA500GCF("R508","SG_UF_CONS"))
	If B7R->(FieldPos("B7R_CODTPA")) > 0
		B7R->B7R_TPTAB	:= AllTrim(PLSA500GCF("R508","TP_PARTICI"))
		B7R->B7R_CODTPA	:= AllTrim(PLSA500GCF("R508","TP_TABELA"))
	EndIf
	B7R->(MsUnLock())
	Trb->(DbSkip())
EndDo

nSeqGui ++
Return({nSeqGui})


/*/{Protheus.doc} VldMesAno
Valida parâmetros mês/ano informados pelo usuário
@author Rodrigo Morgon
@since 02.03.2018
@version P12
/*/
static function VldMesAno()

local lLoop := .T.

while lLoop .and. (len(alltrim(mv_par11)) <> 4 .or. len(alltrim(mv_par12)) < 2)    
    MsgInfo("Os parâmetros mês/ano foram informados incorretamente." + chr(13) + "Favor verificá-los antes de prosseguir." + chr(13) + chr(13) + "Formato mês: MM - Exemplo: 09" + chr(13) + "Formato ano: AAAA - Exemplo: 2018")
    
    lLoop := Pergunte(cPerg,.T. )
enddo

Return lLoop


//-------------------------------------------------------------------
/*/{Protheus.doc} PLPTAtuB5T

Atualiza registro de Aviso B5T na importacao do A500
@author Renan Sakai
@version P12
@since 16/04/2018
/*/ 
//-------------------------------------------------------------------  
Function PLPTAtuB5T(cCodOpe,cLote,cGuia,cMatric,cAlias)
local nRecnoB5T := 0
local lAchou 	:= .f.
Default cAlias := "BD5"

B5T->(DbSetOrder(2))//B5T_FILIAL+B5T_OPEHAB+B5T_NUMLOT+B5T_NMGPRE+B5T_MATRIC
lAchou := B5T->(MsSeek(xFilial("B5T")+cCodOpe+strzero(val(cLote),10)+space(2)+cGuia+cMatric))

if !lAchou
	lAchou := B5T->(MsSeek(xFilial("B5T")+cCodOpe+strzero(val(cLote),12)+cGuia+cMatric))
endif

If lAchou
	nRecnoB5T := B5T->(Recno())
	B5T->(RecLock("B5T",.F.))
	B5T->B5T_CODLDP := iif(cAlias == "BD5",BD5->BD5_CODLDP,BE4->BE4_CODLDP)
	B5T->B5T_CODPEG := iif(cAlias == "BD5",BD5->BD5_CODPEG,BE4->BE4_CODPEG)
	B5T->B5T_NUMGUI := iif(cAlias == "BD5",BD5->BD5_NUMERO,BE4->BE4_NUMERO)
	B5T->B5T_SEQIMP := cCodSeq
	B5T->(MsUnLock())
EndIf

Return nRecnoB5T

//-------------------------------------------------------------------
/*/{Protheus.doc} PLPTAtuB6T

Atualiza registro de Item do Aviso B6T na importacao do A500
@author Renan Sakai
@version P12
@since 16/04/2018
/*/ 
//-------------------------------------------------------------------  
Function PLPTAtuB6T(nVlrEvent,nVlrTaxa,nRecnoB5T)
Default nVlrEvent := 0
Default nVlrTaxa  := 0

B5T->(DbGoTo(nRecnoB5T))
B6T->(DbSetOrder(2))//B6T_FILIAL+B6T_SEQLOT+B6T_SEQGUI+B6T_CODPAD+B6T_CODPRO
If nRecnoB5T > 0 .And. B6T->(MsSeek(xFilial("B6T")+B5T->(B5T_SEQLOT+B5T_SEQGUI)+BD6->(BD6_CODPAD+BD6_CODPRO))) .And. ;
	Empty(B6T->B6T_SEQIMP) .Or. Alltrim(B6T->B6T_SEQIMP) == Alltrim(cCodSeq)

	B6T->(RecLock("B6T",.F.))
	B6T->B6T_VLR500 += nVlrEvent+nVlrTaxa
	B6T->B6T_SEQIMP := cCodSeq
	B6T->(MsUnLock())
	
	B5T->(RecLock("B5T",.F.))
	B5T->B5T_VLR500 += nVlrEvent+nVlrTaxa
	B5T->(MsUnLock())
EndIf

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} PLSP500ATE

Ajusta o tipo de atendimento caso tenha sido enviado errado
@author Lucas Nonato
@version P12
@since 05/02/2019
/*/ 
//--------------------------------------------------------------------  
function PLSP500ATE(cTipAte, cTipGui)
local cRet := ""

if(cTipAte $ "01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,  ")
	cRet := cTipAte
else
	if cTipGui == '01'
		cRet = '04'
	else
		cRet = '05'
	endif	
endif

return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FindTpAco
//TP_ACOMODACAO - Tipo de acomodação.
//A == coletivo
//B == Individual

@author Oscar
@version P12
@since 18/02/2019
/*/ 
//-------------------------------------------------------------------  
Static Function FindTpAco(ctipAco)

Local cRet := ""
Local cCompara := ""
Default ctipAco := ""

If ctipAco == "A"
	cCompara := "2"
else
	cCompara := "1"
endIf

BI4->(DbsetOrder(1))
If BI4->(MsSeek(xfilial("BI4")))
	While BI4->BI4_FILIAL == xfilial("BI4") .AND. !(BI4->(eoF()))
		If BI4->BI4_CODEDI == cCompara
			cRet := BI4->BI4_CODACO
			exit
		endIf
		BI4->(Dbskip())
	endDo
EndIf

If empTy(cret)
	cRet := IIF(ctipAco == "A", "01", "02")
endIf

return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CmpCabxBD6
Carrega variáveis static com base na relação dos campos que existem no cabeçalho e no item
@author Oscar
@version P12
@since 03/04/2019
/*/ 
//-------------------------------------------------------------------  
function CmpCabxBD6(cAliasPLS)
Local aret := {}
Local aCposPad := {}
Local nForCpo	:= 1
Local cMacro := ""

aCposPad := Eval( { || DbSelectArea(cAliasPLS), DbStruct() })

If cAliasPLS == "BD5"
	aCposPadD5 := aClone(aCposPad)
else
	aCposPadE4 := aClone(aCposPad)
endIf

For nForCpo := 1 To Len(aCposPad)
	
	cMacro := ("BD6->BD6_" + Subs(aCposPad[nForCpo,1],5,10))
	
	//Não remover o Type, pois ele protege de errorlog caso exista um campo na BD5 e não exista na BD6.
	If Type(cMacro) <> "U"
		aadd(aret, cMacro)
	Endif
	
Next
	
return aclone(aret)

//-------------------------------------------------------------------
/*/{Protheus.doc} getEspEdi
Retorna a especialidade EDI para o campo BD6_ESPEDI
@author Lucas Nonato
@version P12
@since 10/06/2020
/*/ 
static function getEspEdi(cCbos)
local cRet := ''

if !empty(cCbos)
	cRet := BAQ->(Posicione("BAQ",6,xFilial("BAQ")+alltrim(cCbos),"BAQ_INTERC"))
endif

return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PlGrvPac01
Grava o B43 para os itens de um pacote a partir da versão 11.3
@author PLS TEAM
@version P12
@since 10/06/2020
/*/ 
static function PlGrvPac01(aPacPTU01, aItePac )
local cSql 	:= ""
local nI 	:= 1
local nT 	:= 1
local lCriaB6L := .t.
local aChave	:= {}
Local lB43Qtd := B43->(FieldPos("B43_QTDPRO")) > 0

For nI := 1  To Len(aPacPTU01)
	BD6->(dbgoto(aPacPTU01[nI][7]))
	//Reaproveito a transação feita no PTU Online para pegar os itens dos pacotes no SISPAC
	if val(aPacPTU01[nI][8]) > 0
		cSql := " SELECT B43_CODPAD,B43_DESPRO,B43_CODPRO,B43_VALFIX,B43_TIPO,B43_PRINCI  " + iif(lB43Qtd,",B43_QTDPRO ","") + " FROM " + retSqlName("BEA") + " BEA "
		cSql += " INNER JOIN " + retSqlName("BE2") + " BE2 "
		cSql += " ON BE2_FILIAL = '" + xFilial("BE2") + "' "
		cSql += " AND BE2_OPEMOV = BEA_OPEMOV "
		cSql += " AND BE2_ANOAUT = BEA_ANOAUT "
		cSql += " AND BE2_MESAUT = BEA_MESAUT "
		cSql += " AND BE2_NUMAUT = BEA_NUMAUT "
		cSql += " AND BE2_CODPRO = '"+alltrim(BD6->BD6_CODPRO)+"' "
		if BE2->(fieldpos("BE2_CDPACO")) > 0
			cSql += " AND BE2_CDPACO = '"+alltrim(BD6->BD6_CD_PAC)+"' "
		endif
		cSql += " AND BE2.D_E_L_E_T_ = ' ' "
		cSql += " INNER JOIN " + retSqlName("B43") + " B43 "
		cSql += " ON B43_FILIAL = '" +  xfilial("B43") + "' " 
		cSql += " AND B43_OPEMOV = BE2_OPEMOV "
		cSql += " AND B43_ANOAUT = BE2_ANOAUT "
		cSql += " AND B43_MESAUT = BE2_MESAUT "
		cSql += " AND B43_NUMAUT = BE2_NUMAUT "
		cSql += " AND B43_SEQUEN = BE2_SEQUEN "
		cSql += " AND B43.D_E_L_E_T_ = ' ' "
		cSql += " WHERE BEA_FILIAL = '" + xFilial("BEA") + "' "
		cSql += " AND BEA_NRAOPE = '"+aPacPTU01[nI][8]+"' "
		cSql += " AND BEA.D_E_L_E_T_ = ' ' "
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMPBE2",.F.,.T.)


		while !TMPBE2->(eof())
			if aScan(aItePac,{|x| allTrim(x[1]) == alltrim(TMPBE2->B43_CODPRO)}) == 0
				lCriaB6L := .F.
				aadd(aItePac,{TMPBE2->B43_CODPRO,TMPBE2->B43_VALFIX,TMPBE2->B43_DESPRO,TMPBE2->B43_CODPAD,TMPBE2->B43_TIPO,TMPBE2->B43_PRINCI,iif(lB43Qtd,TMPBE2->B43_QTDPRO,0)})
			endif
			TMPBE2->(dbskip())
		enddo
		TMPBE2->(dbclosearea())
	endif

	if (lCriaB6L)
		aChave		:= {BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO, BD6->BD6_ORIMOV}
		if !PLSPACWEB(BD6->BD6_CODOPE,BD6->BD6_OPEORI,BD6->BD6_SEQUEN,alltrim(BD6->BD6_CD_PAC),;
						BD6->BD6_CODRDA,BD6->BD6_DATPRO,aChave,'BD6','') .and. FWAliasInDic("B6L", .F.)

			if B6L->( FieldPos("B6L_CODLDP") ) > 0 .and. B6L->( FieldPos("B6L_CODPEG") ) > 0 .and. B6L->( FieldPos("B6L_NUMERO") ) > 0 .and. B6L->( FieldPos("B6L_ORIMOV") ) > 0
				B6L->(RecLock("B6L",.T.))
				B6L->B6L_FILIAL := xFilial("B6L")
				B6L->B6L_OPEMOV := BD6->BD6_CODOPE
				B6L->B6L_CODLDP := BD6->BD6_CODLDP
				B6L->B6L_CODPEG := BD6->BD6_CODPEG
				B6L->B6L_NUMERO := BD6->BD6_NUMERO
				B6L->B6L_SEQUEN := BD6->BD6_SEQUEN
				B6L->B6L_ORIMOV := BD6->BD6_ORIMOV
				B6L->B6L_ALIAS  := "BD6"
				B6L->B6L_UNIORI := cUniOri
				B6L->B6L_CODRDA := BD6->BD6_RDAEDI
				B6L->B6L_DTATEN := BD6->BD6_DATPRO
				B6L->B6L_CODPAC := BD6->BD6_CD_PAC
				B6L->B6L_COMUNI := "0"
				B6L->B6L_NRTROL := ""
				B6L->( MsUnLock() )
			endif
		endif
	endif

	for nT := 1 To Len(aItePac)
		B43->(RecLock("B43",.T.))
		B43->B43_FILIAL := xFilial("B43")
		B43->B43_OPEMOV := BD6->BD6_CODOPE
		B43->B43_SEQUEN := BD6->BD6_SEQUEN
		B43->B43_CODOPE := BD6->BD6_CODOPE
		B43->B43_CODLDP := BD6->BD6_CODLDP
		B43->B43_CODPEG := BD6->BD6_CODPEG
		B43->B43_NUMERO := BD6->BD6_NUMERO
		B43->B43_ORIMOV := BD6->BD6_ORIMOV
		B43->B43_DESPRO := aItePac[nT][3]
		B43->B43_CODPAD := aItePac[nT][4]
		B43->B43_CODPRO := aItePac[nT][1]
		B43->B43_TIPO 	:= aItePac[nT][5]
		B43->B43_PRINCI := aItePac[nT][6]
		B43->B43_VALCH  := 0 
		B43->B43_VALFIX := aItePac[nT][2]
		B43->B43_NIVPAC := "IMP" 
		iif(lB43Qtd,B43->B43_QTDPRO,aItePac[nT][7])
		B43->( MsUnLock() )	
	next
	
	BD6->(RecLock("BD6",.F.))
	BD6->BD6_PACOTE := '1'
	BD6->(MsUnLock())
Next

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsBr8Gen
Verifica se há o código genérico na BR8 e posiciona no registro 
@author Eduardo Bento
@version P12
@since 24/08/2021
/*/ 
function PlsBr8Gen(cCodProGen,lAtivo,cCodPadGen)

local aBR8Gen		:= {.f.,,,,} //{regEncontrado,codpad,codpro,ativo,recno}
local cSql 			:= ""
default cCodProGen	:= getNewPar("MV_PLPSPXM","99999994")
default cCodPadGen	:= getNewPar("MV_PLCDPXM","01")
default lAtivo 		:= .f.


cSql := "SELECT BR8_CODPAD, BR8_CODPSA, BR8_BENUTL, R_E_C_N_O_ FROM " + RetSqlName("BR8") + " WHERE BR8_CODPAD = '" + cCodPadGen + "' AND BR8_CODPSA = '" + cCodProGen + "' AND D_E_L_E_T_ <> '*' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMPBR8",.F.,.T.)

while !TMPBR8->(eof())
	if lAtivo
		if TMPBR8->BR8_BENUTL == "1"
			aBR8Gen[1]	:= .t.
			aBR8Gen[2]	:= TMPBR8->BR8_CODPAD
			aBR8Gen[3]	:= TMPBR8->BR8_CODPSA
			aBR8Gen[4]	:= .t.
			aBR8Gen[5]	:= TMPBR8->R_E_C_N_O_
			exit
		endif
	else
		aBR8Gen[1]	:= .t.
		aBR8Gen[2]	:= TMPBR8->BR8_CODPAD
		aBR8Gen[3]	:= TMPBR8->BR8_CODPSA
		aBR8Gen[4]	:= TMPBR8->BR8_BENUTL
		aBR8Gen[5]	:= TMPBR8->R_E_C_N_O_
		exit
	endif
	TMPBR8->(dbskip())
enddo

TMPBR8->(dbclosearea())

//Se preencheu o array, posiciono a BR8
if aBR8Gen[5] > 0
	BR8->(DbGoTo(aBR8Gen[5]))
endif

return aBR8Gen

/*/{Protheus.doc} JaImporFat
Verifica se já existe a fatura importada para evitar duplicidade
@author Eduardo Bento
@since 12.2021
/*/
static function JaImporFat()
local lFound	:= .F.
local cSql 		:= ""

if empty(cUniOri)
	cUniOri := PLSA500GCF("R501","CD_UNI_ORI")
endif
if empty(_NR_FATURA)
	_NR_FATURA := PLSA500GCF("R501","NR_DOC_1_A")
endif

cSql := " SELECT BRJ_CODIGO FROM " + retSqlName("BRJ") + " BRJ "
cSql += " WHERE BRJ_FILIAL = '" + xFilial("BRJ") + "' "
cSql += " AND BRJ_OPEORI = '"+alltrim(cUniOri)+"' "
cSql += " AND BRJ_NUMFAT = '"+alltrim(_NR_FATURA)+"' "
cSql += " AND BRJ.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMPBRJ",.F.,.T.)
if !TMPBRJ->(eof())
	lFound := .t.
endif
TMPBRJ->(dbclosearea())

return lFound
