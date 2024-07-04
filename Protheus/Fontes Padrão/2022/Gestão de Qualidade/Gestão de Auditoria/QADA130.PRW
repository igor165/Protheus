#include "TOTVS.CH"
#include "PROTHEUS.CH"
#include "QADA130.CH" 
 
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณQADA130   ณAutor  ณMarcelo Iuspa          ณ Data ณ19/10/00  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณCadastro de Resultados									  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAQAD                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.         	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ BOPS ณ  Motivo da Alteracao                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณEduardo S.  ณ14/10/02ณ------ณAlterado para apresentar 4 fases de statusณฑฑ
ฑฑณEduardo S.  ณ21/10/02ณ------ณAlterado para verificar o campo QAA_LOGIN ณฑฑ
ฑฑณ            ณ        ณ      ณno lugar do campo QAA_APELID.             ณฑฑ
ฑฑณEduardo S.  ณ28/11/02ณ------ณAlterado para apresentar somente os check-ณฑฑ
ฑฑณ            ณ        ณ      ณlist\topicos referente a Area Auditada.   ณฑฑ
ฑฑณEduardo S.  ณ28/11/02ณ------ณAlterado para permitir somente o acesso deณฑฑ
ฑฑณ            ณ        ณ      ณAuditores envolvidos na Auditoria.        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function MenuDef()

Local aRotina := {{STR0001, "AxPesqui"      , 0, 1,,.F.},;     //"Pesquisar" 
				  {STR0002, "QADA130ATU"    , 0, 2 },;         //"Visualizar"
				  {STR0003, "QADA130ATU"    , 0, 4 },;         //"Resultados"
                  {STR0021, "QADA130ATU" 	, 0, 4 },;         //"Excluir"  
               	  {STR0004, "QADA130Legenda", 0, 5,,.F.},;	   //"Legenda"  
               	  {STR0029, "MsDocument"    , 0, 4}}           //"Conhecimento"
    	
Return aRotina

Function QADA130()

Local aCores := {}   

Private cCadastro  := OemToAnsi(STR0005) //"Resultados"
Private aCheckList := {}
Private aTopico    := {}

Private cFilMat    := cFilAnt

Private aRotina := MenuDef()

//Avisa o cliente sobre as atualiza็๕es que serใo realizadas no SIGAQAD.
//QAvisoQad()

aCores:=	{{'QUB->QUB_STATUS == "1"','ENABLE'    },;
			{ 'QUB->QUB_STATUS == "2"','BR_AMARELO'},;
			{ 'QUB->QUB_STATUS == "3"','BR_PRETO'  },;
			{ 'QUB->QUB_STATUS == "4"','DISABLE'   }}

mBrowse( 6, 1,22,75,"QUB",,,,,,aCores)

Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณQADA130Atuณ Autor ณ Marcelo Iuspa			ณ Data ณ19/10/00  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cadastro de Respostas - Atualiza็ใo/Grava็ใo               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ QADA130Atu(cAlias,nReg,nOpcx)                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Alias do arquivo                                   ณฑฑ
ฑฑณ          ณ ExpN1 = Numero do registro                                 ณฑฑ
ฑฑณ          ณ ExpN2 = Opcao selecionada                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ QADA130                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QADA130Atu(cAlias,nReg,nOpcx)

Local aButtons := {}
Local aRet     := {}
Local aSavQUD  := {}
Local aUsrMat  := QNCUSUARIO()
Local cMatCod  := aUsrMat[3]
Local cMatFil  := aUsrMat[2]
Local cTxtEvi  := ''
Local nNotaAlt := 0
Local nX       := 0
Local lEncAud  :=.F.
Local lQ130ATU := ExistBlock("QAD130AT")
Local lRetQ130

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas na Folder								 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aPaginas := {}
Local aTitulos := {}
Local nControl := 0


Private aNotaNivel := {}
Private aQst 	   := {} 
Private aSeq       := {}
Private cObserv    := "" 	
Private cCodAud    := CriaVar("QUD_CODAUD") 
Private cEviden    := ""
Private cFilAud    := Criavar("QUD_FILMAT")
Private cNomAud    := CriaVar('QAA_NOME')
Private cQst 	   := Space(TAMSX3("QUD_QSTITE")[1])
Private cReqQst    := ""
Private cSN        := ""
Private cTxtQst    := ""
Private lAlt	    
Private lVerEvid   := GetMv("MV_QADEVI",.T.,.F.) 
Private lWhen      := (nOpcx = 3 .or. nOpcx = 4)
Private nFaixIn    := 0 
Private nFaixFi    := 0 
Private nFolder    := 1
Private nIniNota   := GetMv("MV_QADININ")
Private nNota      := 0 
Private nNotaNivel := 0
Private nPeso      := 0
Private nPosQ      := 0
Private oBtn1      
Private oBtn2
Private oDlg
Private oEviden
Private oNota 
Private oScrollBox
Private oSN
								

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define os objetos das questoes								 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private aAplica  := {} 
Private aAplica1 := {}
Private cAplica
Private lAtuQst  := .F.
Private lWhenAud := .T.
Private nQstAplica
Private oAplica
Private oChkIte
Private oChkLst
Private oChkRev
Private oFaiFin
Private oFaiIni
Private oFolder
Private oObsQst
Private oPesQst
Private oQtsIte
Private oReqQst
Private oTxtQst

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis para salvar as posicoes dos campos das NC,s		 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private nPosAcaCor 
Private nPosCateg  
Private nPosDescr
Private nPosIteSeq
Private nPosOcoNc 
Private nPosPrazo  
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ P.E. para definicao do criterio da nota da questao			 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private aCols   := {}
Private aHeader := {}
Private aMsSize	:= MsAdvSize()
Private aInfo	:= { aMsSize[ 1 ], aMsSize[ 2 ], aMsSize[ 3 ], aMsSize[ 4 ], 4, 4 } 
Private aObjects:= {{ 100, 100, .T., .T., .T. }}
Private oCombo1
Private oCombo2
Private oCombo3
Private oPanel
Private aPosObj	:= MsObjSize( aInfo, aObjects, .T. , .T. )
Private lQadNota := ExistBlock("QADNOTA") 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se o Usuario Logado eh auditor nesta Auditoria.     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpcX > 2 .Or. (nOpcX = 2 .And. Empty(QUB->QUB_ENCREA))
	If !QADCkAudit(QUB->QUB_NUMAUD) 
		Return(NIL)
	EndIf
Endif

dbSelectArea("QUD")               
aSavQUD := GetArea()                                           

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifico se a auditoria estแ encerrada. Se encerrada, retornoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpcx == 3

	If ! Empty(QUB->QUB_ENCREA)
		Help(" ",1,"AUDITENC")	
		Return(.F.)
	Endif	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Vou checar se tenho	 todas as questoes...					 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("QUJ")
	dbSetOrder(1)
	If !dbSeek(xFilial("QUJ") + QUB->QUB_NUMAUD)
		Help(" ",1,"QUFNEXIST")
		Return(0)
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Vou travar o arquivo para evitar dois usuแrios alterando     ณ
	//ณ simultaneamente a mesma auditoria...						 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lWhen .And. !SoftLock("QUB")
		Help(" ",1,"QUBLOCK")	
		Return(0)  	
	Endif	                      

	dbSelectArea("QUJ")
	While !Eof() .And. (QUJ->QUJ_FILIAL + QUJ->QUJ_NUMAUD) == (xFilial("QUJ") + QUB->QUB_NUMAUD)

		dbSelectArea("QUD")
        dbSetOrder(1)
		If !dbSeek(xFilial("QUD") + QUB->QUB_NUMAUD + QUJ->QUJ_SEQ + QUJ->QUJ_CHKLST + QUJ->QUJ_REVIS)
			IF QUJ->QUJ_CHKLST <> "999999"
				Help(" ",1,"QUDNEXIST",,QUJ->QUJ_CHKLST,05,00)
			Else
				MessageDlg(STR0027)//"Nใo poderแ informar resultados devido a utiliza็ใo do CheckList 999999, que nใo possui quest๕es"
			Endif
			Return(0)
		Endif 
		
		dbSelectArea("QUJ")
		dbSkip()
	Enddo
	
ElseIf nOpcx == 4

	If ! Empty(QUB->QUB_ENCREA)
		Help(" ",1,"AUDITENC")	
		Return(0)
	Endif	
	
	IF QUB->QUB_STATUS=="1"  
        Help(" ",1,"Q130SEMRES")  //Auditoria sem resultado.     
		Return(0)	
	Endif
EndIf

If nOpcx == 3
	If lQ130Atu
		If !(lRetq130 := ExecBlock("QAD130AT",.F.,.F.))
			Return(NIL)
		EndIf
	EndIf	
EndIf

Aadd(aSeq,{}) 
Aadd(aSeq,{}) 
dbSelectArea("QUD")       
QUD->(dbSetOrder(1))
If QUD->(dbSeek(xFilial("QUD") + QUB->QUB_NUMAUD))
	While QUD->(!Eof()) .And. (QUD->QUD_FILIAL + QUD->QUD_NUMAUD) == (xFilial("QUD") + QUB->QUB_NUMAUD)

		dbSelectArea("QUH")
		QUH->(dbSetOrder(1))
		dbSeek(xFilial("QUH") + QUB->QUB_NUMAUD + QUD->QUD_SEQ)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Compara O usuario corrente com o codigo do auditor, somente  ณ
		//ณ na inclusao do do Resultado									 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		QAA->(dbSetOrder(1))
		QAA->(dbSeek(QUH->QUH_FILMAT+QUH->QUH_CODAUD))
		If nOpcx == 3                                            
			If Upper(QAA->QAA_LOGIN) # Upper(cUserName) .And. ;
				!(QUB->QUB_FILMAT == cMatFil .AND. QUB->QUB_AUDLID == cMatCod)
				dbSelectArea("QUD") 
				dbSkip()
				Loop              	
			Else
				lEncAud := If(!lEncAud,.T.,lEncAud)
				cFilAud := QAA->QAA_FILIAL				 
				cCodAud := QAA->QAA_MAT
				cNomAud	:= QAA->QAA_NOME
			EndIf                
		Else
			lEncAud := If(!lEncAud,.T.,lEncAud)
			cFilAud := QAA->QAA_FILIAL		
			cCodAud := QAA->QAA_MAT
			cNomAud	:= QAA->QAA_NOME
		EndIf

		If aScan(aSeq[1], QUD->QUD_SEQ) == 0
			Aadd(aSeq[1], QUH->QUH_SEQ)
			Aadd(aSeq[2], QUH->QUH_SEQ + " " + QUH->QUH_DESTIN)
		Endif

		QAD130FGet("QUG" ,IIF(nOpcx == 3,4,nOpcx), xFilial("QUG")+QUB->QUB_NUMAUD+QUD->QUD_SEQ+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE, 2, "QUG->QUG_FILIAL+QUG->QUG_NUMAUD+QUG->QUG_SEQ+QUG->QUG_CHKLST+QUG->QUG_REVIS+QUG->QUG_CHKITE+QUG->QUG_QSTITE")
		
		nNotaAlt := QUD->QUD_NOTA

		nQstAplica := Val(QUD->QUD_APLICA)
		If nQstAplica == 0
			nQstAplica := SuperVal(GetSX3Cache("QUD_APLICA","X3_RELACAO"))
		Endif

		cTxtEvi  := MsMM(QUD->QUD_EVICHV,TamSX3('QUD_EVIDE1')[1])
		
		If QUD->QUD_TIPO == "1"
			QU4->(dbSetorder(1))
			If QU4->(dbSeek(xFilial("QU4")+QUD->(QUD_CHKLST+QUD_REVIS+QUD_CHKITE+QUD_QSTITE)))
				If QU4->QU4_USAALT == "2"   
					lAlt := .F.
					If Empty(QUD->QUD_DTAVAL) 
						If QU4->QU4_FAIXIN >= QUD->QUD_NOTA
						nNotaAlt := 999.99
						EndIf
					EndIf
				Else
					lAlt := .T.
				EndIf
				nFaixIn	:=  QU4->QU4_FAIXIN
				nFaixFi	:=  QU4->QU4_FAIXFI
			EndIf	
		Else 
			QUE->(dbSetOrder(1))
			If QUE->(dbSeek(xFilial("QUE")+QUB->QUB_NUMAUD+QUd->(QUD_CHKLST+QUD_REVIS+QUD_CHKITE+QUD_QSTITE)))
				If QUE->QUE_USAALT == "2"   
					lAlt := .F.
					If Empty(QUD->QUD_DTAVAL) 
						If QUE->QUE_FAIXIN >= QUD->QUD_NOTA
						nNotaAlt := 999.99
						EndIf
					EndIf
				Else
					lAlt := .T.    
				EndIf
				nFaixIn	:=  QUE->QUE_FAIXIN
				nFaixFi	:=  QUE->QUE_FAIXFI
			EndIf
		EndIf

		Aadd(aNotaNivel,{QUD->QUD_SEQ,QUD->QUD_CHKLST+QUD->QUD_REVIS,QUD->QUD_CHKITE,QUD->QUD_QSTITE,.F.,nNotaAlt,AllTrim(cTxtEvi),QUH->QUH_CODAUD,aClone(aCols),nQstAplica,QUH->QUH_FILMAT,nFaixIn,nFaixFi,lAlt})	

		dbSelectArea("QUD")
		QUD->(dbSkip())
	Enddo	

	nFaixIn	:=  0
	nFaixFi	:=  0

	If !lEncAud    
		Help("",1,"Q130AUDNAU") 
		Return(NIL)
	EndIf
Else 
	Messagedlg(STR0028)//"A auditoria nใo possui itens a serem auditados, nesse caso deverแ ser informado checklist para a Auditoria, ou trata-se de uma auditoria com o CheckList 999999 que nใo possui quest๕es")
	Return(NIL)

Endif

If SetMdiChild()
	DEFINE MSDIALOG oDlg FROM aMsSize[7],000 TO aMsSize[6]-50,700 TITLE cCadastro OF oMainWnd Pixel
Else
	DEFINE MSDIALOG oDlg FROM aMsSize[7],000 TO aMsSize[6],700 TITLE cCadastro OF oMainWnd Pixel
Endif

nFolder := 2
nOption := 1 
nUsado  := 0
                                         
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta os vetores com as opcoes no Folder					 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Aadd(aTitulos,STR0006)//"Questใo"
Aadd(aPaginas,STR0006)
nControl++

Aadd(aTitulos,STR0007)//"Nใo-Conformidades"
Aadd(aPaginas,STR0007)
nControl++                         

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem do Folder											 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oFolder        := TFolder():New(72,03,aTitulos,aPaginas,oDlg,,,,.T., .T.,310,126,)
For nX := 1 to Len(oFolder:aDialogs)
    DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[nX]
Next
oFolder:aPrompts[1] := STR0006 //"Questใo"
oFolder:aPrompts[2] := STR0007 //"Nใo-Conformidades"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Realiza o Scrool na tela das nao-conformidades				 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oScrollBox         := TScrollBox():New(oFolder:aDialogs[1],.1,.1, 114,309.9,.T.,.T.,.T.)
oScrollBox:Align   := CONTROL_ALIGN_ALLCLIENT
oFolder:bSetOption := {|nDlg|nFolder:=nDlg,oDlg:CommitControls(),FolderChange(nFolder),oFolder:SetFocus()}                                   
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a Getdados das nao-conformidades			 			 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oGet1                     := MSGetDados():New(.1,.1,114,309,nOpcx,"QADA130LOk","QADA130TOk","+QUG_ITESEQ",.T.,,,,,'QADA130GETDAD()' , , ,'QADA130GETDAD()' ,oFolder:aDialogs[2])		
oGet1:oBrowse:bLostFocus := {|| oGet1:oBrowse:Refresh(), aNotaNivel[aQst[nPosQ,2],9] := aClone(aCols), QADA130ChGet(),QADA130Qst()}
oGet1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

aNota1 := QADCombo("QUD_NOTA")
aNota  := {} 
For nX := 1 to Len(aNota1)
	Aadd(aNota, aNota1[nX, 1])
Next	


aAplica1 := QADCombo("QUD_APLICA")
aAplica  := {} 
For nX := 1 to Len(aAplica1)
	Aadd(aAplica, aAplica1[nX, 1])
Next	


cChkLst := ""
cChkIte := ""
cSeq    := ""

@ 00,00 MSPANEL oPanel PROMPT "" SIZE 008,085 OF oDlg
oPanel:Align := CONTROL_ALIGN_TOP

@ 010, 005 Say RetTitle("QUD_NUMAUD") Size 50, 10 Of oPanel Pixel
@ 010, 037 MSGET QUB->QUB_NUMAUD Picture PesqPict("QUB", "QUB_NUMAUD") WHEN .F. Size 40, 5 Of oPanel Pixel

@ 010, 119 Say RetTitle("QUB_INIAUD") Size 50, 10 Of oPanel Pixel
@ 010, 145 MsGet QUB->QUB_INIAUD Picture PesqPict("QUB", "QUB_INIAUD") WHEN .F. Size 40, 5 Of oPanel Pixel

@ 010, 215 Say RetTitle("QUB_ENCAUD") Size 50, 10 Of oPanel Pixel
@ 010, 255 MsGet QUB->QUB_ENCAUD Picture PesqPict("QUB", "QUB_ENCAUD") WHEN .F. Size 40, 5 Of oPanel Pixel

cMotAud := AllTrim(QUB->QUB_MOTAUD) + " - " + Posicione("SX5", 1, xFilial("SX5") + Left(CpoRetF3("QUB_MOTAUD", "QE"), 2) + QUB->QUB_MOTAUD, "X5DESCRI()")
@ 023, 005 Say RetTitle("QUB_MOTAUD") Size 50, 10 Of oPanel Pixel
@ 023, 037 MsGet cMotAud WHEN .F. Size 70,5 Of oPanel Pixel

@ 023, 215 Say RetTitle("QUB_TIPAUD") Size 50, 10 Of oPanel Pixel                                                         
@ 023, 255 MsGet QADCBox("QUB_TIPAUD", QUB->QUB_TIPAUD) WHEN .F. Size 40,5 Of oPanel Pixel
                                   
@ 036, 005 Say RetTitle("QUD_SEQ") Size 50, 10  Of oPanel Pixel
@ 036, 037 ComboBox oCombo1 Var cSeq  Items aSeq[2] WHEN lWhenAud Size 105, 5 Of oPanel Pixel
oCombo1:bChange := {|| QADA130Cx(1, oCombo1, oCombo2, oCombo3)}

@ 036, 170 Say RetTitle("QUD_CHKLST") Size 50, 10  Of oPanel Pixel
@ 036, 210 ComboBox oCombo2 Var cChkLst   Items {} Valid CheckSx3("QUD_CHKLST") WHEN lWhenAud Size 105, 5 Of oPanel Pixel
oCombo2:bChange := {|| QADA130Cx(2, oCombo1, oCombo2, oCombo3)}

@ 051, 005 Say RetTitle("QUD_CHKITE") Size 50, 10  Of oPanel Pixel
@ 051, 037 ComboBox oCombo3 Var cChkIte   Items {} Valid CheckSx3("QUD_CHKITE") WHEN lWhenAud Size 192, 5 Of oPanel Pixel
oCombo3:bChange := {|| QADA130Cx(3, oCombo1, oCombo2, oCombo3)}

@ 051, 233 Say RetTitle("QUD_QSTITE") Size 50, 10  Of oPanel Pixel

@ 051, 270 BUTTON oBtn1 Prompt "<" ACTION If(Qada130Nota() .And. QADA130Evid(),QADA130Nav(-1),NIL) WHEN .T. SIZE 9,10 OF oPanel Pixel
@ 051, 316 BUTTON oBtn2 Prompt ">" ACTION If(Qada130Nota() .And. QADA130Evid(),QADA130Nav(+1),NIL) WHEN .T. SIZE 9,10 OF oPanel Pixel

If SetMDIChild()
	@ 051, 283 MsGet oGet2 Var Alltrim(cQst+" / "+STRZERO(LEN(aQst),3)) Picture PesqPict("QUD", "QUD_QSTITE")	Valid CheckSx3("QU4_FAIXFI") .And. QADA130Nav(0) WHEN .F. Size 30, 5 Of oPanel Pixel
Else
	@ 051, 283 MsGet oGet2 Var Alltrim(cQst+" / "+STRZERO(LEN(aQst),3)) Picture PesqPict("QUD", "QUD_QSTITE")	Valid CheckSx3("QU4_FAIXFI") .And. QADA130Nav(0) WHEN .F. Size 20, 5 Of oPanel Pixel
Endif
oGet2:bChange := {|| QADA130Nav(0)}

@ 066, 005 Say RetTitle("QUJ_NIVEL") Size 50, 10 Of oPanel Pixel
@ 066, 037 MSGET QADCBox("QUJ_NIVEL", QUJ->QUJ_NIVEL) Picture PesqPict("QUJ", "QUJ_NIVEL") WHEN .F. Size 40, 5 Of oPanel Pixel

@ 025, 145 ComboBox oAplica VAR cAplica Items aAplica WHEN lWhen UpDate Size 55,5 Of oScrollBox Pixel

@ 025, 235 MsGet    oNota VAR nNota            WHEN lWhen Valid CheckSx3("QUD_NOTA") .And. QADA130ChGet() UpDate Picture PesqPict("QUD", "QUD_NOTA") Size 50, 5 Of oScrollBox Pixel
@ 025, 235 ComboBox oSN   VAR cSN  Items aNota WHEN lWhen Valid CheckSx3("QUD_NOTA") .And. QADA130ChGet() UpDate  Size 60,5 Of oScrollBox Pixel

If lQadNota
	oSN:bChange := {||nNota:=ExecBlock("QADNOTA",.F.,.F.,"N")}                                                               
Else
	oSN:bChange := {||If(lAlt,nNota:=If(oSN:nAt==3,0,If(oSN:nAt==1,nFaixFi,nFaixIn)),NIL)}                                                               
	
	If nIniNota <> 3
		oSN:nAt:=nIniNota
		oSN:Refresh()
		If lAlt
			nNota:=If(oSN:nAt==3,0,If(oSN:nAt==1,nFaixFi,nFaixIn)) 
		EndIf	
	Endif
EndIf	
oNota:Refresh()

@ 039,010 SAY RetTitle("QUD_CODAUD") Size 50,10 Of oScrollBox Pixel
@ 039,050 MSGET oCodAud VAR cCodAud PICTURE PesqPict("QUD", "QUD_CODAUD");
	VALID (CheckSX3("QUD_CODAUD",cCodAud).And. QADA130ChGet()) .Or..T. F3 "QAA"; 
	WHEN VisualSX3("QUD","QUD_CODAUD") .And. .F.  Size 40,5 Of oScrollBox Pixel 

@ 039, 110 SAY RetTitle("QAA_NOME") Size 50, 10 Of oScrollBox Pixel
@ 039, 145 MSGET oNomAud VAR cNomAud WHEN .F. Size 125,5 Of oScrollBox Pixel

If nOPcx == 3
	@ 053, 050 GET oEviden VAR cEviden MEMO NO VSCROLL Valid CheckSx3("QUD_EVIDE1") .And. QADA130ChGet() UpDate Size 220, 40 Of oScrollBox Pixel
Else
	@ 053, 050 GET oEviden VAR cEviden MEMO READONLY NO VSCROLL Valid CheckSx3("QUD_EVIDE1") .And. QADA130ChGet() UpDate Size 220, 40 Of oScrollBox Pixel
EndIf

QU4->(dbGoBottom())
QU4->(dbSkip())

QADA130Cx(1, oCombo1, oCombo2, oCombo3)

// Ponto de entrada para alterar as informa็๕es mostradas no campo T๓pico.
IF ExistBlock("QAD130TO")
	aRet := ExecBlock("QAD130TO", .F., .F., {aCheckList, oCombo1, oCombo2, oCombo3, aSeq})
    If ValType(aRet) == "A" .AND. Len(aRet) > 1
        aTopico := aRet
        oCombo3:aItems := aRet[2]
        oCombo3:nAt := 1
    EndIf
Endif

QADA130Say(nOpcx)

aButtons := {{"RELATORIO" ,{ || QAD130VAUD()},OemToAnsi(STR0020) , OemToAnsi(RIGHT(STR0020,9)) }} // "Visualiza Auditoria"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ponto de Entrada criado para criar/mudar os botoes da enchoicebar               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF ExistBlock( "QAD130BT" )
	aButtons := ExecBlock( "QAD130BT", .f., .f., {nOpcx,QUB->QUB_NUMAUD,aButtons} )
Endif

oFolder:Align := CONTROL_ALIGN_ALLCLIENT

If nOpcx == 3
	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||  IF (nFolder == 2, EVAL(oGet1:oBrowse:bLostFocus) ,""),;
								 IF(QAD130AllNota()  .And. QADA130TOk(),(QADA130Save(), oDlg:End()),"") },{||oDlg:End()},,aButtons) 
Else 
	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| IF(nOpcx==4,QADA130Del(),""), oDlg:End()},{||oDlg:End()},,aButtons)
EndIf	                                                                                     

dbSelectArea("QUB")
MsUnlock()
                            
RestArea(aSavQUD)

Return(1)

                                  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณQADA130Cx ณ Autor ณ Marcelo Iuspa			ณ Data ณ19/10/00  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณTrata preenchimento dos Combos dinamicamente                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ QADA130Cx(nCombo, oCombo1, oCombo2, oCombo3)               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ															  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ QADA130                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function QADA130Cx(nCombo,oCombo1,oCombo2,oCombo3)
Local nFor

If nCombo == 1
	aCheckList := {}
	Aadd(aCheckList, {})
	Aadd(aCheckList, {})
	dbSelectArea("QUD")
	dbSetOrder(1)
	dbSeek(xFilial("QUD") + QUB->QUB_NUMAUD + aSeq[1, oCombo1:nAt])
	While ! Eof() .and. QUD->QUD_FILIAL + QUD->QUD_NUMAUD + QUD->QUD_SEQ == xFilial("QUD") + QUB->QUB_NUMAUD + aSeq[1, oCombo1:nAt]
		If aScan(aCheckList[1], QUD->QUD_CHKLST + QUD->QUD_REVIS) = 0
			dbSelectArea("QU2")
			dbSetOrder(1)
			dbSeek(xFilial("QU2") + QUD->QUD_CHKLST+QUD->QUD_REVIS)
			Aadd(aCheckList[1], QU2->QU2_CHKLST + QUD->QUD_REVIS)
			Aadd(aCheckList[2], QU2->QU2_DESCRI)
			dbSelectArea("QUD")
		Endif
		dbSkip()
	Enddo		
	oCombo2:aItems := aCheckList[2]
	oCombo2:nAt := 1
Endif		

If nCombo <= 2
	QU2->(dbSeek(xFilial("QU2") + aCheckList[1, oCombo2:nAt]))
	aTopico    := {}
	Aadd(aTopico, {})
	Aadd(aTopico, {})
	dbSelectArea("QUD")
	dbSetOrder(1)
	dbSeek(xFilial("QUD") + QUB->QUB_NUMAUD + aSeq[1, oCombo1:nAt] + aCheckList[1, oCombo2:nAt])
	While !Eof() .and. QUD->QUD_FILIAL + QUD->QUD_NUMAUD + QUD->QUD_SEQ + QUD->QUD_CHKLST + QUD->QUD_REVIS == xFilial("QUD") + QUB->QUB_NUMAUD + aSeq[1, oCombo1:nAt] + aCheckList[1, oCombo2:nAt]
		If aScan(aTopico[1], QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE) == 0
			dbSelectArea("QU3")
			dbSetOrder(1)
			dbSeek(xFilial("QU3") + QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE)
			Aadd(aTopico[1], QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE)
			Aadd(aTopico[2], AllTrim(QU3->QU3_NORMA) + " " + QU3->QU3_DESCRI)
			dbSelectArea("QUD")
		Endif
		dbSkip()
	Enddo
	oCombo3:aItems := aTopico[2]
	oCombo3:nAt := 1
Endif

If nCombo <= 3
	QUJ->(DBSeek(xFilial("QUJ") + QUB->QUB_NUMAUD + aSeq[1, oCombo1:nAt] + aTopico[1,oCombo3:nAt] ))
	nNotaNivel := Max(Val(QUJ->QUJ_NIVEL), 1)

	aQst := {}
	For nFor := 1 to Len(aNotaNivel)
		If aNotaNivel[nFor,1]+aNotaNivel[nFor,2]+aNotaNivel[nFor,3] == aSeq[1,oCombo1:nAt]+aTopico[1,oCombo3:nAt]
			Aadd(aQst, {aNotaNivel[nFor, 4], nFor,aNotaNivel[nFor,2]+aNotaNivel[nFor,3]+aNotaNivel[nFor,4]})
		Endif
	Next		
	If Len(aQst) > 0
		cQst := aQst[1, 1]
		oBtn1:Enable()
		oBtn2:Enable()
	Else
		cQst := SPACE(Len(QUD->QUD_QSTITE))
		oBtn1:Disable()
		oBtn2:Disable()
	Endif
	dbSelectArea("QUD")
Endif
nPosQ := 1

QADA130Qst()            
        
If nFolder == 2        
	oGet1:oBrowse:Refresh()                              
	oGet1:oBrowse:SetFocus() 
EndIf	

Return(NIL)             


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณQADA130Qstณ Autor ณ Marcelo Iuspa			ณ Data ณ19/10/00  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณAtualiza variแveis a serem exibidas ou editadas             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ QADA130Cx(nCombo, oCombo1, oCombo2, oCombo3)               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ															  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ QADA130                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function QADA130Qst()
Local lAdic 

QUD->(dbSeek(xFilial("QUD")+QUB->QUB_NUMAUD + aSeq[1, oCombo1:nAt] + aQst[nPosQ, 3]))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ QUD_TIPO  1 - Padrao 												 ณ
//ณ 		  2 - Adicional 											 ณ
//ณ    		  3 - Unica												     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lAdic := QUD->QUD_TIPO = "2" 
If lAdic
	QUE->(dbSeek(xFilial("QUE") + QUB->QUB_NUMAUD + aQst[nPosQ, 3]))
	lAlt := If(QUE->QUE_USAALT == "1",.T.,.F.)
Else
	QU4->(dbSeek(xFilial("QU4") + aQst[nPosQ, 3]))
	lAlt := If(QU4->QU4_USAALT== "1",.T.,.F.) 
Endif	
nFaixIn := If(lAdic, QUE->QUE_FAIXIN, QU4->QU4_FAIXIN)
nFaixFi := If(lAdic, QUE->QUE_FAIXFI, QU4->QU4_FAIXFI)
nPeso   := If(lAdic, QUE->QUE_PESO  , QU4->QU4_PESO)                 

cReqQst := If(lAdic,MsMM(QUE->QUE_REQCHV,TamSX3('QUE_REQQS1')[1]),;
	MsMM(QU4->QU4_REQCHV,TamSX3('QU4_REQQS1')[1]))
	
cObserv := If(lAdic, MsMM(QUE->QUE_OBSCHV,TamSX3('QUE_OBSER1')[1]),;
	MsMM(QU4->QU4_OBSCHV,TamSX3('QU4_OBSER1')[1]))                   

cTxtQst := If(lAdic,MsMM(QUE->QUE_TXTCHV,TamSX3('QUE_TXTQS1')[1]),;
	MsMM(QU4->QU4_TXTCHV,TamSX3('QU4_TXTQS1')[1]))      

// Pergunta respondida com combo (.T. ou nota .F.)
nNota   := aNotaNivel[aQst[nPosQ, 2], 6]
oNota:Refresh()

// Atualiza Pergunta de considera Sim/Nao 

oAplica:nAt:=aNotaNivel[aQst[nPosQ, 2], 10]
oAplica:Refresh()

cEviden := aNotaNivel[aQst[nPosQ, 2], 7]
oEviden:Refresh()

cFilAud := aNotaNivel[aQst[nPosQ, 2], 11]
cCodAud := aNotaNivel[aQst[nPosQ, 2], 8]
aCols   := aClone(aNotaNivel[aQst[nPosQ, 2], 9])
If QAA->(dbSeek(cFilAud+cCodAud))
	cNomAud := QAA->QAA_NOME
Endif            

If lAlt
	If lQadNota
		cSN := ExecBlock("QADNOTA",.F.,.F.,"C")
	Else	
		cSN := If(nNota==0,"3",If(nNota==nFaixFi,"1","2"))		  
	EndIf
	
	oSN:nAt := Val(cSN)
	If nIniNota <> 3 .And. (oSN:nAt) == 3
		oSN:nAt:=nIniNota
		nNota:=If(oSN:nAt==3,0,If(oSN:nAt==1,nFaixFi,nFaixIn)) 		
	Endif
	oSN:Refresh()
	oSN:Show()
	oNota:Hide()
Else
	oSN:Hide()
	oNota:Show()
Endif		

oGet2:Refresh()
oScrollBox:Refresh()
oDlg:UpDateGets()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Atualiza as variaveis dos campos referentes a Questao				 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lAtuQst
	oChkLst:Refresh() 
	oChkRev:Refresh() 
	oChkIte:Refresh() 
	oQtsIte:Refresh() 
	oTxtQst:Refresh() 
	oObsQst:Refresh()
	oReqQst:Refresh()
	oFaiIni:Refresh()
	oFaiFin:Refresh()
	oPesQst:Refresh()
	oAplica:Refresh()
	
EndIf
Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณQADA130Sayณ Autor ณ Marcelo Iuspa			ณ Data ณ19/10/00  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณRealiza posicionamento dos campos a serem exibidos          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ QADA130Say(nOpcx)							              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ EXPN1 = Opcao do aRotina									  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ QADA130                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function QADA130Say(nOpcx)

@ 010, 010 Say RetTitle("QUD_CHKLST") Size 50, 10  Of oScrollBox Pixel
@ 010, 050 MsGet oChkLst Var QUD->QUD_Chklst WHEN .F.  Picture PesqPict("QUD", "QUD_CHKLST") Size 40, 5 Of oScrollBox Pixel

@ 010, 110 Say RetTitle("QUD_REVIS")  Size 50, 10  Of oScrollBox Pixel
@ 010, 145 MsGet oChkRev Var QUD->QUD_Revis    WHEN .F.  Picture PesqPict("QUD", "QUD_REVIS") Size 30, 5 Of oScrollBox Pixel

@ 010, 200 Say RetTitle("QUD_CHKITE") Size 50, 10  Of oScrollBox Pixel
@ 010, 235 MsGet oChkIte Var QUD->QUD_Chkite   WHEN .F. Picture PesqPict("QUD", "QUD_CHKITE") Size 34, 5 Of oScrollBox Pixel

@ 025, 010 Say RetTitle("QUD_QSTITE") Size 50, 10  Of oScrollBox Pixel
@ 025, 050 MsGet oQtsIte Var QUD->QUD_Qstite    WHEN .F. Picture PesqPict("QUD", "QUD_QSTITE") Size 50, 5 Of oScrollBox Pixel


@ 025, 110 Say RetTitle("QUD_APLICA")   Size 50, 10  Of oScrollBox Pixel

@ 025, 200 Say RetTitle("QUD_NOTA")   Size 50, 10  Of oScrollBox Pixel

@ 053, 010 Say RetTitle("QUD_EVIDE1") Size 50, 10  Of oScrollBox Pixel

@ 098, 010 Say RetTitle("QU4_TXTQS1") Size 50, 10  Of oScrollBox Pixel

@ 098, 050 Get oTxtQst Var cTXTQST MEMO READONLY NO VSCROLL Size 220, 40 Of oScrollBox Pixel
                                                           
@ 143, 010 Say RetTitle("QU4_OBSER1") Size 50, 10  Of oScrollBox Pixel

@ 143, 050 Get oObsQst Var cObserv MEMO READONLY NO VSCROLL Size 220, 40 Of oScrollBox Pixel

@ 188, 010 Say RetTitle("QU4_REQQS1") Size 50, 10  Of oScrollBox Pixel

@ 188, 050 Get oReqQst Var cReqqst MEMO READONLY NO VSCROLL Size 220, 40 Of oScrollBox Pixel

@ 233, 010 Say RetTitle("QU4_FAIXIN") Size 50, 10  Of oScrollBox Pixel
@ 233, 050 MsGet oFaiIni Var nFaixin    WHEN .F. Picture PesqPict("QU4", "QU4_FAIXIN") Size 50, 5 Of oScrollBox Pixel

@ 233, 181 Say RetTitle("QU4_FAIXFI") Size 50, 10  Of oScrollBox Pixel
@ 233, 221 MsGet oFaiFin Var nFaixfi    WHEN .F. Picture PesqPict("QU4", "QU4_FAIXFI") Size 50, 5 Of oScrollBox Pixel

@ 248, 010 Say RetTitle("QU4_PESO")   Size 50, 10  Of oScrollBox Pixel
@ 248, 050 MsGet oPesQst Var nPeso      WHEN .F. Picture PesqPict("QU4", "QU4_PESO")  Size 50, 5 Of oScrollBox Pixel

@ 255, 010 Say ""   Size 50, 10  Of oScrollBox Pixel  // Isto serve para dar uma folga no final do ScrollBox

lAtuQst := .T.

Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณQADA130Navณ Autor ณ Marcelo Iuspa			ณ Data ณ19/10/00  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณRealiza posicionamento dos campos a serem exibidos          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ QADA130Nav(nOpt)								              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ															  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ QADA130                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QADA130Nav(nOpt)

If aNotaNivel[aQst[nPosQ, 2],6] # nNota .or. (!aNotaNivel[aQst[nPosQ, 2], 7] == cEviden) .or. (! aNotaNivel[aQst[nPosQ, 2], 8] == cCodAud .And. aNotaNivel[aQst[nPosQ, 2], 11] == cFilAud) 
	QADA130ChGet()
Endif

nPosQ := aScan(aQst, {|_1| _1[1] == cQst})
If ! ((nPosQ + nOpt) <= 0 .or. (nPosQ + nOpt) > Len(aQst))
	nPosQ += nOpt
	If Len(aQst) > 0                
		cQst := aQst[nPosQ, 1]
	Else
		cQst := SPACE(Len(QUD->QUD_QSTITE))
	Endif       
	
Endif                   

QADA130Qst()

If nFolder == 2
	oGet1:oBrowse:Refresh()                              	
	oGet1:oBrowse:SetFocus() 
EndIf	

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQADA130NotaบAutor  ณMarcelo Iuspa      บ Data ณ  19/10/00   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a digitacao da nota (chamada pelo X3)                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QADA130                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function QADA130Nota()
Local lRetorno := .T.   
Local lAplica := If((oAplica:nAt) == 1 ,.T.,.F.)

lWhenAud := .T.

oNota:Refresh()
oSN:Refresh() 

//Verifica se a Evidencia esta preenchida
If lAplica
	If lVerEvid
	    IF lAlt   
			If nNota==0 .And. !Empty(cEviden)
				lRetorno := .F.  
			Else
				If !(nNota==0 .And. Empty(cEviden))
					//Verifica se a Nota esta entre as faixas   
					If (nNota < nFaixIn) .Or. (nNota > nFaixFi)
						lRetorno := .F.
					EndIf
				EndIf
			EndIf               
		Else
			If nNota==999.99 .And. !Empty(cEviden)
				lRetorno := .F.  
			Else
				If !(nNota==999.99 .And. Empty(cEviden))
					//Verifica se a Nota esta entre as faixas   
					If (nNota < nFaixIn) .Or. (nNota > nFaixFi)
						lRetorno := .F.
					EndIf
				EndIf
			EndIf               
		
		Endif
	Else
		//Verifica se a Nota esta entre as faixas   
		IF lAlt
			If !(nNota==0) 
				If (nNota < nFaixIn) .Or. (nNota > nFaixFi)
					lRetorno := .F.
				EndIf
			EndIf	
		Else
			If !(nNota==999.99) 
				If (nNota < nFaixIn) .Or. (nNota > nFaixFi)
					lRetorno := .F.
				EndIf
			EndIf		
		Endif
	Endif
EndIf	

If !lRetorno            
	Help("",1,"QUDNOTA")
	lWhenAud := .F.
EndIf	

oCombo1:Refresh()
oCombo2:Refresh()
oCombo3:Refresh()

Return(lRetorno)

                         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQADA130EvidบAutor  ณPaulo Emidio       บ Data ณ  11/04/02   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida  digitacao da evidencia da questao na mudanca de    บฑฑ
ฑฑบ          ณ questoes.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QADA130                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function QADA130Evid()
Local lRetorno := .T.
Local lAplica := If((oAplica:nAt) == 1,.T.,.F.)

oEviden:Refresh()                       

lWhenAud := .T.

If Empty(cEviden) .And. lAplica
    IF lAlt
		If !(nNota == 0)
			If lVerEvid
				Help("",1,"QUDEVIDEN",,OemToAnsi(STR0016),1) 
				lRetorno := .F.
				lWhenAud := .F.
			EndIf
		EndIf    
	Else
		If !(nNota == 999.99)
			If lVerEvid
				Help("",1,"QUDEVIDEN",,OemToAnsi(STR0016),1) 
				lRetorno := .F.
				lWhenAud := .F.
			EndIf
		EndIf    
	Endif
EndIf	                   

oCombo1:Refresh()
oCombo2:Refresh()
oCombo3:Refresh()


Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณQADA130ChGetบAutor  ณMarcelo Iuspa       บ Data ณ 19/10/00  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza Array com ultimo valor do get editado              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QADA130ChGet()
Local cTopico    := ''
Local cCheckList := ''
Local nFor       := 0
Local bBlo      
Local nNotaAux	 :=0

oEviden:Refresh()
oNota:Refresh()                                                                 

If lQadNota
	nNota := If(lAlt,ExecBlock("QADNOTA",.F.,.F.,"N"),nNota)
Else
	nNota := If(lAlt,If(oSN:nAt==3,0,If(oSN:nAt==1,nFaixFi,nFaixIn)),nNota)
	If lAlt .And. nIniNota <> 3 .And. (oSN:nAt) == 3
		oSN:nAt:=nIniNota
		oSN:Refresh()
		nNota := If(oSN:nAt==3,0,If(oSN:nAt == 1,nFaixFi,nFaixIn))
	Endif
EndIf	

aNotaNivel[aQst[nPosQ, 2], 5] := .T.
aNotaNivel[aQst[nPosQ, 2], 6] := nNota
aNotaNivel[aQst[nPosQ, 2], 7] := AllTrim(cEviden)
aNotaNivel[aQst[nPosQ, 2], 8] := cCodAud
aNotaNivel[aQst[nPosQ, 2],11] := cFilAud
aNotaNivel[aQst[nPosQ, 2], 9] := aClone(aCols)
aNotaNivel[aQst[nPosQ, 2],10] := oAplica:nAt
                                        
If nNotaNivel > 1
	cSeq       := aNotaNivel[aQst[nPosQ, 2], 1]
	cCheckList := aNotaNivel[aQst[nPosQ, 2], 2]
	cTopico    := aNotaNivel[aQst[nPosQ, 2], 3]
	bBlo       := If(nNotaNivel == 2, 	{|| aNotaNivel[nFor, 2]+aNotaNivel[nFor,3]==cCheckList+cTopico}, {|| aNotaNivel[nFor, 2]==cCheckList})
	For nFor := 1 to Len(aNotaNivel)
		If Eval(bBlo) .And. aNotaNivel[nFor, 3] == cTopico                  
			nNotaAux   := nNota
			If lAlt	 			                                                          			
				IF nNota == 0 
					IF aNotaNivel[nFor,14]  //Alternativa
						nNotaAux:=0 //Nao Informada
					Else
						nNotaAux:=999.99 //Nao Informada	
					Endif
				ElseIf nNota==nFaixIn
					nNotaAux:=aNotaNivel[nFor,12] //nFaixin da questao
				Else
					nNotaAux:=aNotaNivel[nFor,13] //nFaixFi da questao
				Endif				                        
			Else            
				IF aNotaNivel[nFor,14]  //Alternativa
					IF nNota == 999.99
						nNotaAux:=0 //Nao Informada					
					ElseIF nNota <= aNotaNivel[nFor,12] 
						nNotaAux:=aNotaNivel[nFor,12] //nFaixin da questao
					Else
						nNotaAux:=aNotaNivel[nFor,13] //nFaixFi da questao
					Endif
				Else                               
					IF nNota == 999.99
						nNotaAux:=999.99 //Nao Informada						
					ElseIF nNota < aNotaNivel[nFor,12] 
						nNotaAux:=aNotaNivel[nFor,12] //nFaixin da questao
					Elseif nNota > aNotaNivel[nFor,13] 
						nNotaAux:=aNotaNivel[nFor,13] //nFaixFi da questao
					Endif
				Endif	
			Endif			
			aNotaNivel[nFor, 5] := .T.
			aNotaNivel[nFor, 6] := nNotaAux
		Endif                                  				
	Next		                  	
Endif

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQADA130Save บAutor  ณMarcelo Iuspa       บ Data ณ  19/10/00   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza dados do Array no disco                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QADA130Save()
Local cChave    := ""
Local cStatusQUB:= "1" // "Auditorias Sem Resultado"
Local cTxtEvi   := ""
Local lAlte     := .F.
Local lAltern   := .F.
Local lBlqEvi	:= .F.
Local lQstZer   := GetMv("MV_QADQZER",.T.,.T.)
Local nConAval  := 0
Local nMax      := 0
Local nMin      := 0
Local nNota     := 0
Local nPeso     := 0
Local nPesoTotal:= 0
Local nPONOBT   := 0
Local nPontos   := 0
Local nSemAval  := 0
Local nTotRes   := 0
Local nX        := 0

dbSelectArea("QUD")

QADA130ChGet()
QADA130Nav(0)

BEGIN TRANSACTION

For nX := 1 to Len(aNotaNivel)  
	If aNotaNivel[nX, 5]
		If 	QUD->(DBSeek(xFilial("QUD") + QUB->QUB_NUMAUD + aNotaNivel[nX,1]+aNotaNivel[nX,2]+aNotaNivel[nX,3]+aNotaNivel[nX,4]))
		
            IF EMPTY(ALLTRIM(aNotaNivel[nX, 7])) .and. !EMPTY(QUD->QUD_EVICHV)
  				MSMM(QUD->QUD_EVICHV ,,,,2) 				
  			Else	
				MsMM(,TamSX3("QUD_EVIDE1")[1],,aNotaNivel[nX,7],1,,,"QUD","QUD_EVICHV")
			Endif

			cChave := QUD->QUD_CHKLST + QUD->QUD_REVIS + QUD->QUD_CHKITE + QUD->QUD_QSTITE
		            
			lAlte :=aNotaNivel[nX,14] //Alternativa SIM/NAO
			
			RecLock("QUD", .F.)                      
			IF lAlte // Alternativa SIM
				If !(aNotaNivel[nX, 6]==0 .And. Empty(aNotaNivel[nX, 7])) 
					QUD->QUD_NOTA   := aNotaNivel[nX, 6]
					QUD->QUD_FILMAT := aNotaNivel[nX,11]
					QUD->QUD_CODAUD := aNotaNivel[nX, 8]
					QUD->QUD_DTAVAL := dDataBase
				Elseif aNotaNivel[nX, 6]==0 .And. Empty(aNotaNivel[nX, 7])
					QUD->QUD_NOTA   := 0
					QUD->QUD_FILMAT := ""
					QUD->QUD_CODAUD := ""
					QUD->QUD_DTAVAL := CTOD(SPACE(6))
				EndIf	
			Else // Alternativa NAO
				If !(aNotaNivel[nX, 6] == 999.99  .And. Empty(aNotaNivel[nX, 7]))
					QUD->QUD_NOTA   := aNotaNivel[nX, 6]
					QUD->QUD_FILMAT := aNotaNivel[nX,11]
					QUD->QUD_CODAUD := aNotaNivel[nX, 8]
					QUD->QUD_DTAVAL := dDataBase
				Elseif aNotaNivel[nX, 6] == 999.99 .And. Empty(aNotaNivel[nX, 7]) 
					QUD->QUD_NOTA   := 0
					QUD->QUD_FILMAT := ""
					QUD->QUD_CODAUD := ""
					QUD->QUD_DTAVAL := CTOD(SPACE(6))
				EndIf				
			Endif       
		    
			IF Empty(ALLTRIM(aNotaNivel[nX, 7]))
				QUD->QUD_EVICHV:=""
			EndIf	
			
			QUD->QUD_APLICA := Str(aNotaNivel[nX, 10],1)
			
		
			MsUnlock()

			aNotaNivel[nX, 5] := .F.			
		Endif	
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se o questionario esta parcialmente respondido.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(aNotaNivel[nX, 6])
		If !lVerEvid .Or. (lVerEvid .And. !Empty(aNotaNivel[nX, 7]))		
			nTotRes++
		EndIf
	EndIf

Next

QADA130GrvQUG()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe existir o campo Grava o Status da Auditoria.	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

nPosQUD:= QUD->(RecNo())

dbSelectArea("QUD")
QUD->(dbSeek(xFilial("QUD") + QUB->QUB_NUMAUD))
While QUD->(!Eof()) .and. (QUD->QUD_FILIAL + QUD->QUD_NUMAUD) == (xFilial("QUD") + QUB->QUB_NUMAUD)
    
	If lVerEvid
		cTxtEvi := MsMM(QUD->QUD_EVICHV,TamSX3('QUD_EVIDE1')[1])
		If Empty(cTxtEvi)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณResultados Parcialmente Respondido   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			lBlqEvi:=.T.
	    EndIf
	EndIf

	cChave := QUD->QUD_CHKLST + QUD->QUD_REVIS + QUD->QUD_CHKITE + QUD->QUD_QSTITE

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ QUD_TIPO = 1) Padrao 										 ณ
	//ณ			   2) Adicional 									 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If QUD->QUD_TIPO = "2"    
		QUE->(dbSeek(xFilial("QUE") + QUD->QUD_NUMAUD + cChave))
		nMin  := QUE->QUE_FAIXIN
		nMax  := QUE->QUE_FAIXFI
		nPeso := If(QUE->QUE_PESO==0,1,QUE->QUE_PESO)
		lAltern := If(QUE->QUE_USAALT=="1",.T.,.F.)
	Else
		QU4->(dbSeek(xFilial("QU4") + cChave))
		nMin  := QU4->QU4_FAIXIN
		nMax  := QU4->QU4_FAIXFI
		nPeso := If(QU4->QU4_PESO==0,1,QU4->QU4_PESO)
		lAltern := If(QU4->QU4_USAALT=="1",.T.,.F.)
	Endif	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se a nota informada na questao Alternativa e igual  ณ
	//ณ a Faixa Inicial, se o MV_QADQZER for igual a .T., a nota da  ณ
	//ณ questao sera sugerida como Zero para efeito de calculo.      ณ 
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    nNota := QUD->QUD_NOTA 
	If lQstZer .And. lAltern
		If nNota == nMin
			nNota := 0
		EndIf	
	Endif	
	nSemAval   += If(Empty(QUD->QUD_DTAVAL), 1, 0)
	nPontos	   += (((nNota * nPeso)*100)/nMax)
	nPesoTotal += (nPeso)
	nConAval++
	QUD->(DbSkip())
Enddo	     

If nSemAval > 0
	IF nConAval == nSemAval
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ"Auditorias Sem Resultado"  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cStatusQUB:= "1"	
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณResultados Parcialmente Respondido   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cStatusQUB:= "2"
	Endif
Else
	IF lBlqEvi //Evidencia Nใo Preenchida
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณResultados Parcialmente Respondido   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cStatusQUB:= "2"
	Else	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณLiberada para Encerramento           ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cStatusQUB:= "3"
		nPONOBT := nPontos / nPesoTotal
	Endif
Endif

RecLock("QUB",.F.)
QUB->QUB_STATUS := cStatusQUB
QUB->QUB_PONOBT := nPONOBT
QUB->QUB_PONPOS := QADSomPon(QUB->QUB_NUMAUD) //Grava a pontuacao maxima na Auditoria
MsUnlock()
FKCOMMIT()

QUD->(DbGoto(nPosQUD))
END TRANSACTION

Return(NIL)
          
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณFolderChange บAutor  ณMarcelo Iuspa      บ Data ณ 19/10/00  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao executada na troca de Folder Ativo                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FolderChange(nDlg)

If lAlt                                               
	If lQadNota
		cSN := ExecBlock("QADNOTA",.F.,.F.,"C")
	Else                     
		cSN := If(nNota==nFaixFi,'1',If(nNota==nFaixIn,'2','3'))
	EndIf	
	oSN:nAt := Val(cSN)
	If (nIniNota # 3) .And. (oSN:nAt == 3)
		oSN:nAt:=nIniNota
		nNota:=If(oSN:nAt==3,0,If(oSN:nAt==1,nFaixFi,nFaixIn)) 		
		oSN:Refresh()
	Endif
	oSN:Show()
	oNota:Hide()
Else
	oSN:Hide()
	oNota:Show()
Endif		

oAplica:Refresh()
oEviden:Refresh()                       
oEviden:SetFocus()

If nDlg == 2
	oGet1:oBrowse:Refresh()                              
	oGet1:oBrowse:SetFocus() 
EndIf

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณQADA130LegendaบAutor  ณMarcelo Iuspa     บ Data ณ 19/10/00  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para exibicao de legenda                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function QADA130Legenda()

BrwLegenda(cCadastro,STR0008, {	{"ENABLE"    ,STR0019 },; // "Auditorias" ### "Sem Resultado"
   						       	{"BR_AMARELO",STR0017 },; // "Resultados Parcialmente Respondido"
   						       	{"BR_PRETO"  ,STR0018 },; // "Liberada para Encerramento"
   						       	{"DISABLE"   ,STR0010 }}) // "Encerrada"

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณQADA130GrvQug บAutor  ณMarcelo Iuspa     บ Data ณ 19/10/00  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para gravacao dos dados dos aCols no arquivo QUG.    บฑฑ
ฑฑบ          ณNao conformidades do item                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function QADA130GrvQug()
Local aCols       := Nil
Local lDeletou    := Nil
Local nDescr      := Nil
Local nFor        := Nil
Local nFor1       := Nil
Local nFor2       := Nil
Local nIteSeq     := aScan(aHeader, {|_1| Upper(AllTrim(_1[2]))=="QUG_ITESEQ"})
Local nNewIte     := Nil

Private QUG_DESCR := Nil

nDescr  := aScan(aHeader, {|_1| Upper(AllTrim(_1[2]))=="QUG_DESC1"})

If ! lWhen
	Return(.F.)
Endif

dbSelectArea("QUG")
QUG->(dbSetOrder(2))
For nFor := 1 to Len(aNotaNivel)
	aCols    := aClone(aNotaNivel[nFor, 9])
	cChave   := xFilial("QUG")+QUB->QUB_NUMAUD+aNotaNivel[nFor,1]+aNotaNivel[nFor,2]+aNotaNivel[nFor,3]+aNotaNivel[nFor,4]
	lDeletou := .F.             
	
	QU2->(dbSeek(xFilial("QU2")+aNotaNivel[nFor,2]))
	For nFor1 := 1 To Len(aCols)
		If Empty(aCols[nFor1, nDescr])
			Loop
		Endif
		If QUG->(dbSeek(cChave+aCols[nFor1,nIteSeq]))
			If aCols[nFor1, Len(aCols[nFor1])]
  				MSMM(QUG_DESCHV ,,,,2) 				
				RecLock("QUG", .F.)                                          
				dbDelete()
				MsUnLock()
				FKCOMMIT()
				lDeletou := .T.
				Loop
			Endif          
			RecLock("QUG", .F.)                                          
		Else
			If aCols[nFor1, Len(aCols[nFor1])]
				Loop
			Endif
			RecLock("QUG", .T.)
		Endif
		QUG->QUG_FILIAL := xFilial("QUG")       // Filial
		QUG->QUG_NUMAUD := QUB->QUB_NUMAUD      // Auditoria
		QUG->QUG_SEQ    := aNotaNivel[nFor, 1]  // Sequencia
		QUG->QUG_CHKLST := QU2->QU2_CHKLST      // Check List
		QUG->QUG_REVIS  := QU2->QU2_REVIS       // Revisao
		QUG->QUG_CHKITE := aNotaNivel[nFor, 3]  // Topico
		QUG->QUG_QSTITE := aNotaNivel[nFor, 4]  // Num Questao
		For nFor2 := 1 to Len(aHeader)
			If aHeader[nFor2,10] # "V"
				FieldPut(FieldPos(aHeader[nFor2,2]),aCols[nFor1,nFor2])
			EndIf	
		Next	
		MsUnlock()          
		FKCOMMIT()		              
		MsMM(,TamSX3("QUG_DESC1")[1],,aCols[nFor1,nPosDescr],1,,,"QUG","QUG_DESCHV")

	Next	
	If lDeletou
		dbSeek(cChave)
		nNewIte := 1
		While ! Eof() .And. QUG->QUG_FILIAL+QUG->QUG_NUMAUD+QUG->QUG_SEQ+QUG->QUG_CHKLST+QUG->QUG_REVIS+QUG->QUG_CHKITE+QUG->QUG_QSTITE == cChave
			RecLock("QUG", .F.)
			QUG->QUG_ITESEQ := StrZero(nNewIte++, Len(QUG->QUG_ITESEQ))
			MsUnlock()
			FKCOMMIT()
			dbSkip()
		Enddo
	Endif

Next						
Return(.T.)							

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณQADA130GetDad บAutor  ณMarcelo Iuspa     บ Data ณ 19/10/00  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para Validacao da GetDados                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QADA130GETDAD()
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณQADA130LOk    บAutor  ณMarcelo Iuspa     บ Data ณ 19/10/00  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para validacao da linha na GetDados                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QADA130LOk()
Local lRetorno := .T.

if  ! (Empty(Alltrim(aCols[n,nPosDescr])) .and. Empty(aCols[n,nPosAcaCor]) .and. Empty(aCols[n,nPosCateg])  )
	If nPosOcoNc > 0 .And. !Acols[n,Len(aHeader)+1]  
		If Empty(aCols[n,nPosOcoNc])
			Help("",1,"QUG_OCORNC")
			lRetorno := .F.
		EndIf
	EndIf

	If nPosDescr > 0 .And. ! Acols[n,Len(aHeader)+1]
		If Empty(aCols[n,nPosDescr])
			Help("",1,"QUG_DESC1")
			lRetorno := .F.
		EndIf
	EndIf

	If Acols[n,Len(aHeader)+1]
		lRetorno := .T.
	EndIf

	If nPosCateg > 0 .and. nPosDescr > 0
		If !Empty(Acols[n,nPosCateg]) .and. Empty(Acols[n,nPosDescr])   
			MessageDlg(STR0023,,3) //"Por favor preencher o campo Descricao - pasta Nao-Conformidade"				        	 
			lRetorno := .F.
		Endif	                             
	
		If (Empty(Acols[n,nPosCateg]) .and. !Empty(Acols[n,nPosDescr])) .and. lRetorno
			MessageDlg(STR0024,,3) //"Por favor preencher o campo Descricao - pasta Nao-Conformidade"				        	 
			lRetorno := .F.
		Endif	                            
		If (!Empty(Acols[n,nPosCateg]) .and. !Empty(Acols[n,nPosDescr]).and. empty(acols[n,nposacacor])) .and. lRetorno
		MessageDlg(STR0025,,3) // "Por favor preencher o campo A็ใo corretiva - pasta Nao-Conformidade"				        	 
		lRetorno := .F.
	endif 
	 
	If (!Empty(Acols[n,nPosCateg]) .and. !Empty(Acols[n,nPosDescr]).and. !empty(acols[n,nposacacor]) .and. empty(acols[n,nposprazo])) .and. lRetorno
		MessageDlg(STR0026,,3) // "Por favor preencher o campo Prazo Corre็ใo - pasta Nao-Conformidade"				        	 
		lRetorno := .F.
	endif 
	//Ponto de Entrada para novas validacoes
	If ExistBlock("QAD130GD")
		lRetorno := ExecBlock("QAD130GD",.F.,.F.)
	EndIf
	
	Endif
else 
	lRetorno:=.T.    
endif

Return(lRetorno)		


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณQADA130TOk    บAutor  ณMarcelo Iuspa     บ Data ณ 19/10/00  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para Validacao de toda a tela                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function QADA130TOk()

Local lRetorno := .T.
Local nX               
Local nY
Local aColsVrf
Local cMsgLap                       
                          
//Verifica se a nota foi digitada                          
lRetorno := Qada130Nota()
	
//Verifica se a evidencia da questao foi preenchida
If lRetorno
	lRetorno := Qada130Evid()
EndIf
	
	
If lRetorno
	For nX := 1 to Len(aNotaNivel)
	
		aColsVrf := aClone(aNotaNivel[nX, 9])
		
		For nY := 1 To Len(aColsVrf)
			If !aColsVrf[nY,Len(aHeader)+1] //Caso NAO esteja deletado                                                           
			
				// verifica se a questใo foi respondida e se foi preenchido algum campo na pasta Nใo conformidade
				If (anotanivel[nx,4] == (strzero(nposq,(tamsx3("QUD_QSTITE")[1])))) .and.;
				(anotanivel[nx,10] == 1 .and. ((lalt .and. cSn <> "3") .or. (!lalt .and. nNota <> 999.99)) .and.;
				!(Empty(Alltrim(aColsVrf[nY,nPosDescr])) .and. Empty(aColsVrf[nY,nPosAcaCor]) .and. Empty(aColsVrf[nY,nPosCateg])) ) 
			   		If nPosDescr > 0 
						If Empty(Alltrim(aColsVrf[nY,nPosDescr]))
							lRetorno:=.F.
						EndIf 
					Else
						lRetorno := .F.
					EndIf
				
					IF nPosCateg > 0 
						If Empty(aColsVrf[nY,nPosCateg]) 
							lRetorno := .F.
						EndIf
					Else
						lRetorno := .F.
					Endif                 
					if nPosAcacor > 0
						If Empty(aColsVrf[nY,nPosAcacor]) 
							lRetorno := .F.
						EndIf
					Else
						lRetorno := .F.
					Endif	           
					
				
				else 
					lRetorno:=.T.
				endif
			Endif
			
			//Forca a saida da consistencia
			If !lRetorno
				Exit
			EndIf
		Next
		
		If !lRetorno                 
	            
			cMsgLap := RetTitle("QUD_CHKLST")+" "+AllTrim(aNotaNivel[nX,2])+" "+AllTrim(RetTitle("QUD_CHKITE"))
			cMsgLap += AllTrim(aNotaNivel[nX,3])+" "+AllTrim(RetTitle("QUD_QSTITE"))+" "+AllTrim(aNotaNivel[nX,4])
	   		cMsgLap += " "+OemToAnsi(STR0007)+" "+OemToAnsi(STR0011)+" "+Alltrim(RetTitle("QUG_CATEG"))+" / "+Alltrim(RetTitle("QUG_DESC1"))+" / "+Alltrim(RetTitle("QUG_ACACOR"))+" / "+Alltrim(RetTitle("QUG_PRAZO")) //"esta faltando dados a serem preenchidos"
	
			MsgStop(cMsgLap)
			Exit
	
		EndIf
	Next nx
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณQAD130AllNota บAutor  ณPaulo Emidio      บ Data ณ 14/06/02  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se a questao com evidencia preenchida possui nota บฑฑ
ฑฑบ          ณ informada.												  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function QAD130AllNota()
Local cChave   := ""                
Local cMsgHlp  := ''  
Local lAlte    := .F.                             
Local lRetorno := .T.
Local nNotNiv  := 0
Local nTotQst  := 0

For nNotNiv := 1 to Len(aNotaNivel)

	nTotQst++

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCaso a Evidencia seja Digitada o Sistema forca a inclusao da Nota.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(aNotaNivel[nNotNiv,7])

	    cChave := aNotaNivel[nNotNiv,2] + aNotaNivel[nNotNiv,3] + aNotaNivel[nNotNiv,4]
	   
		QUD->(dbSeek(xFilial("QUD") + QUB->QUB_NUMAUD + aNotaNivel[nNotNiv,1]+cChave))				
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ QUD_TIPO  1 - Padrao 												 ณ
		//ณ 		  2 - Adicional 											 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		IF QUD->QUD_TIPO = "2" 
			QUE->(dbSeek(xFilial("QUE")+QUB->QUB_NUMAUD+cChave))
			lAlte := If(QUE->QUE_USAALT == "1",.T.,.F.)
		Else
			QU4->(dbSeek(xFilial("QU4")+cChave))
			lAlte := If(QU4->QU4_USAALT== "1",.T.,.F.) 
		Endif		
		
		IF lAlte // Alternativa SIM
			If aNotaNivel[nNotNiv,6] == 0
				lRetorno := .F.
			EndIf
		Else   //Alternativa NAO
			If aNotaNivel[nNotNiv,6] == 999.99
				lRetorno := .F.
			EndIf
		Endif       
		IF !lRetorno
			cMsgHlp += STR0012+" "+AllTrim(aNotaNivel[nNotNiv,2])+CHR(13)+CHR(10) //CheckList
			cMsgHlp += STR0013+" "+AllTrim(aNotaNivel[nNotNiv,3])+" " //Topico
			cMsgHlp += STR0014+" "+AllTrim(aNotaNivel[nNotNiv,4])+CHR(13)+CHR(10) //Questao
			cMsgHlp += STR0015+" "+AllTrim(aNotaNivel[nNotNiv,1])+" "+POSICIONE("QUH",1,QUB->QUB_FILIAL+QUB->QUB_NUMAUD+aNotaNivel[nNotNiv,1],"QUH_DESTIN") //Area
			Help("",1,"QUD_NOEVI",,cMsgHlp,05,00)
			Exit
		Endif				
	EndIf
Next
                
If nTotQst == 0
	lRetorno := .F.
	Help("",1,"QUDNQST",,OemToAnsi(STR0022),05,00)
Endif
Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณ QAD130VAUD   บAutor  ณAldo Marini Juniorบ Data ณ 20/09/03  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Visualiza a Auditoria para consultar algumas informacoes   บฑฑ
ฑฑบ          ณ antes de realizar os resultados                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QADA130                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function QAD130VAUD()
Local aSaveArea := GetArea()
cCadastro := OemtoAnsi(STR0008)	// "Auditorias"

Qad100Man("QUB",QUB->(Recno()),2)

RestArea(aSaveArea)
cCadastro  := OemToAnsi(STR0005) //"Resultados"

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQADA130DelบAutor  ณTelso Carneiro      บ Data ณ  25/02/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exclusao dos Resultados da Auditoria                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QADA130ATU                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

STATIC FUNCTION QADA130Del()	
Local nSemAval  := 0
Local nConAval  := 0

Begin Transaction

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Movimento (Itens Auditados)									ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	QUD->(dbSetOrder(1))
	QUD->(dbSeek(xFilial("QUD")+QUB->QUB_NUMAUD))
	While QUD->(!Eof()) .And. xFilial("QUD") == QUD->QUD_FILIAL .And. QUD->QUD_NUMAUD == QUB->QUB_NUMAUD		
			
		IF cFilAud== QUD->QUD_FILMAT .AND. cCodAud == QUD->QUD_CODAUD
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Nao-conformidades associadas								 ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			QUG->(dbSetOrder(2))
			IF QUG->(dbSeek(xFilial("QUG")+QUB->QUB_NUMAUD+QUD->QUD_SEQ+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE))
				While QUG->(!Eof()) .And. xFilial("QUG")+QUB->QUB_NUMAUD+QUD->QUD_SEQ+QUD->QUD_CHKLST+QUD->QUD_REVIS+QUD->QUD_CHKITE+QUD->QUD_QSTITE == ;
					QUG->QUG_FILIAL+QUG->QUG_NUMAUD+QUG->QUG_SEQ+QUG->QUG_CHKLST+QUG->QUG_REVIS+QUG->QUG_CHKITE+QUG->QUG_QSTITE
					
					MSMM(QUG->QUG_DESCHV ,,,,2)
					RecLock("QUG",.F.)
					QUG->(dbDelete())
					MsUnlock()
					FKCommit()
					QUG->(dbSkip())
				EndDo
			Endif
			
			MSMM(QUD->QUD_EVICHV ,,,,2)
			RecLock("QUD",.F.)
			QUD->QUD_NOTA  :=0
			QUD->QUD_DTAVAL:=CTOD(SPACE(8))
			QUD->QUD_FILMAT:=""
			QUD->QUD_CODAUD:=""
			QUD->QUD_EVICHV:=""
			MsUnlock()
			FKCommit()
		ENDIF
		
		nSemAval += If(Empty(QUD->QUD_DTAVAL), 1, 0)
		nConAval++
		QUD->(dbSkip())
	EndDo
	
	If nSemAval > 0
		IF nConAval == nSemAval
			RecLock("QUB",.F.)
			QUB->QUB_STATUS:="1"
			QUB->QUB_PONOBT:= 0
			QUB->QUB_PONPOS:= QADSomPon(QUB->QUB_NUMAUD) //Grava a pontuacao maxima na Auditoria
			MsUnlock()
			FKCommit()
		Else
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณResultados Parcialmente Respondido   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			RecLock("QUB",.F.)
			QUB->QUB_STATUS:= "2"
			QUB->QUB_PONOBT:= 0
			QUB->QUB_PONPOS:= QADSomPon(QUB->QUB_NUMAUD) //Grava a pontuacao maxima na Auditoria
			MsUnlock()
			FKCommit()
		Endif
	Endif
	

End Transaction

Return(NIL)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQAD130FGetบAutor  ณRafael S. Bernardi  บ Data ณ  12/02/2007 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta aHeader e aCols                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QADA130                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function QAD130FGet(cAlias,nOpc,cSeek, nOrder,cWhile)
Local aNoFields := {"QUG_NUMAUD","QUG_SEQ","QUG_CHKLST","QUG_REVIS","QUG_CHKITE","QUG_QSTITE", "QUG_DESCHV"}
aHeader := {}
aCols   := {}
FillGetDados(nOpc,cAlias,nOrder,cSeek ,{|| &cWhile},         ,aNoFields,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
//FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
nPosIteSeq := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUG_ITESEQ"})
nPosOcoNc  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUG_OCORNC"})
nPosAcaCor := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUG_ACACOR"})
nPosPrazo  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUG_PRAZO" })
nPosCateg  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUG_CATEG" })
nPosDescr  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUG_DESC1" })


Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQAD130Ini บAutor  ณRafael S. Bernardi  บ Data ณ  12/02/2007 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inicializador padrao do campo QUG_DESC1                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ QADA130                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function QAD130Ini()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Salva a posicao dos campos das NCs no aCols					 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPosIteSeq    := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUG_ITESEQ"})
nPosOcoNc  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUG_OCORNC"})
nPosAcaCor := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUG_ACACOR"})
nPosPrazo  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUG_PRAZO" })
nPosCateg  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUG_CATEG" })
nPosDescr  := Ascan(aHeader,{|x| AllTrim(x[2]) == "QUG_DESC1" })

If Len(aCols) == 1
	aCols[1,nPosIteSeq] := "01"
EndIf

If Empty(aCols[Len(aCols),nPosCateg])
	Return ""
Else
	Return MsMM(QUG->QUG_DESCHV,TamSX3('QUG_DESC1')[1])
EndIf
Return
