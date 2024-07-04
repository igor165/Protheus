STATIC cCodLocPar  	:= ""
STATIC cSeq 			:= ""
STATIC __cTipo     	:= "1"
STATIC __cdescri 	:= ""

STATIC oBrwBEA		:= NIL
STATIC oBrwPro		:= NIL
STATIC oBrwCri		:= NIL
STATIC oBrwEven		:= NIL
STATIC oEncAut		:= NIL
STATIC lBEANTit    	:= BEA->(FieldPos("BEA_NUMTIT"))>0
STATIC lInfRda	   	:= .F.
STATIC aAutFor  		:= {}
STATIC aDadCri  		:= {}
STATIC aCabCri  		:= {}
STATIC aTrbCri  		:= {}
STATIC aDentesFaces 	:= {}
STATIC aCdCores 		:= {}
STATIC aCabDf 		:= {}
STATIC aDadDf 		:= {}
STATIC aTrbDf 		:= {}
STATIC bImpGuia 		:= {|| A090PosArq(), If(BEA->BEA_STATUS$"1,2,3,4",IF(ExistBlock("PLSA090IMP"),ExecBlock("PLSA090IMP",.F.,.F.,{"1"}),PLSGODMUD()),(Help("",1,"PLSR430")))   }
STATIC bImpG2      	:= {|| A090PosArq(), If(BEA->BEA_STATUS$"1,2,3,4",IF(ExistBlock("PLSA090IMP"),ExecBlock("PLSA090IMP",.F.,.F.,{"1"}),PLSR431N({"0",lImpGuiDir})),(Help("",1,"PLSR431")))}
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#INCLUDE "plsa090od.ch"
#include "PLSMCCR.CH"

#define __aCdCri051 {"025",STR0001} //"Para este procedimento necessita Auditoria."
#define __aCdCri055 {"026",STR0002} //"Procedimento informado nao existe na tabela padrao."
#define __aCdCri09Z {"09Z",STR0099}
#define  K_Imprimir 6
#define  K_ImpRec 7
#define  K_BCOCON 8
#define  K_Copiar 6
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLS090O ³ Autor ³ Daher		            	³ Data ³ 21.05.05 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Atendimento Liberacao Odontologico	                     ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS090O(cTipoRot)
LOCAL nI			:= 0
LOCAL aCores		:= {}
LOCAL cMvPlsRdag 	:= GetNewPar("MV_PLSRDAG","999999")
LOCAL cFiltro    	:= ""

PRIVATE aRotina   	:= MenuDef(cTipoRot,@aCores)
PRIVATE cCadastro 	:= Fundesc()
PRIVATE lImpGuiDir	:= .F.
Private cCodIntSxb	:= ""

DEFAULT cTipoRot	:= "1"  

AjustaHLP()

__cTipo := cTipoRot

if !(__cTipo=="1") .AND. !(__cTipo=="2")
    help("",1,"plsa090tip")
    return
endif

if __cTipo=="2"
    BAU->( dbsetorder(1) )
    if !( BAU->( msseek( xfilial("BAU")+cMvPlsRdag) ) )
        aviso("Rede de Atendimento Generica","Para a correta utilizacao desta rotina deve ser criada a rede de atendimento generica para liberacoes e configurado o parametro mv_plsrdag.",{STR0090},2)
        return
    endif
endif

cFiltro := PLS090FIL(__cTipo)

If FindFunction("PLSRESTOP")
    cStrFil := PlsResTop("l",.f.)
    If !(Empty(cStrFil))
        cFiltro += " .and. "+cStrFil
    EndIf
EndIf

PERGUNTE("PLA090",.F.)

lImpGuiDir := (mv_par01==1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca dados do parametro...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar("MV_PLSMODA","1") == "0"
   If ! Pergunte("PLS090",.T.)
      Return
   Endif
   cCodLocPar := mv_par01
Endif

DbSelectArea("BEA")
DbSetOrder(1)

If ExistBlock( "PL090FIL" )
	cFiltro := ExecBlock( "PL090FIL", .F., .F., {cFiltro} )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Browse
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oBrwBEA := FWmBrowse():New()
oBrwBEA:SetAlias('BEA')
oBrwBEA:SetDescription( cCadastro )
oBrwBEA:SetFilterDefault( cFiltro )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inclui legenda
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if len(aCores)>0
	for nI:=1 to len(aCores)
		if ( nPos := aScan(aCdCores,{|x| x[1] == aCores[nI,2]}) ) > 0
			oBrwBEA:AddLegend( aCores[nI,1], aCores[nI,2], aCdCores[nPos,2] )
		endIf
	next
endif

oBrwBEA:activate()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄ-ÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLS090OMov³ Autor ³ Daher		         	³ Data ³ 21.05.05 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ-ÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Movimentacao														 ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS090OMov(cAlias,nReg,nOpc,cNil,aDadosPad,cBenef,ctipoesp,cRda,cLoc,cEsp,cCid,cRegsol,cRegExe,cNumProTMK, cTipoRot, lSolWeb)
LOCAL oSay02
LOCAL oSay
LOCAL I__f
LOCAL nFor
LOCAL nOpca      := 0
LOCAL aRetAux    := {}
LOCAL aCampos    := {}
LOCAL aButtons   := {}
LOCAL aRetorno   := {}
LOCAL aProcAbert := {}
LOCAL aMatCom	 	:= {}
LOCAL bOK        := {|| nOpca := 1,If(PLA090VLDo(aRetorno,oEncAut:aGets,oEncAut:aTela,oBrwPro,oEncAut,nOpc,__cTipo,oBrwCri,nil,oBrwEven,aMatCom),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.),Iif(FindFunction("PLSLIMSTA"),PLSLIMSTA(),NIL) }
LOCAL bCancel    := {|| oDlg:End(),Iif(FindFunction("PLSLIMSTA"),PLSLIMSTA(),NIL) }
LOCAL bFilCri    := {|| }

LOCAL nRegBEA    := Iif(BEA->(eof()),0,BEA->(Recno()))
LOCAL nOrdBEA    := BEA->(IndexOrd())

LOCAL cFaseGuia := ""
LOCAL slvinclui := iif(type("inclui")=="l",inclui, .t. )

LOCAL cOpeMov    := ""
LOCAL cAnoAut    := ""
LOCAL cMesAut    := ""
LOCAL cNumAut    := ""
LOCAL cSeqPF     := ""
LOCAL cChave     := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
LOCAL cChGui
LOCAL cMVPLSRDAG  := GetNewPar("MV_PLSRDAG","999999")

LOCAL bFilEven := {|| }
LOCAL aCabProc  := {}
LOCAL aDadProc  := {}
LOCAL aTrbProc  := {}
LOCAL lValidVis := .T.
LOCAL nX := 0
Local cLiber    := BEA->BEA_STALIB
Local nQtdPro   := 0
Local nValComp  := 0

PRIVATE oDlg
PRIVATE oFolder
PRIVATE aMatCBkp := {}
PRIVATE cNumProto:= Space(20)
Private cNrProWeb   := Space(20)

DEFAULT cTipoRot	:= "1"  
DEFAULT lSolWeb     := .F.  

DEFAULT cBenef	 := ""
DEFAULT ctipoesp := ""
DEFAULT cRda 	 := ""
DEFAULT cLoc 	 := ""
DEFAULT cEsp 	 := ""
DEFAULT cCid     := ""
DEFAULT cRegsol	 := ""
DEFAULT cRegExe	 := ""
DEFAULT cNumProTMK := ""

//  Necessaria a alteração da variavel private para chamada da rotina
If PLSALIASEXI("BKU") .And. !Empty(BKU->BKU_NRPRO) .And. cTipoRot == "2"  .And. lSolWeb
	cCadastro := "Liberação Odontológica"   
	cNrProWeb := BKU->BKU_NRPRO
EndIf

If !Empty(cRda)
	lInfRda := .T.
EndIf

if !empty(ctipoesp)
	__ctipo := ctipoesp
endif

if __cTipo == "1"
    __cDescri 	:= "autorizacao"
	aCampos 	:= nil
elseif __cTipo == "2"
	__cDescri 	:= "Liberacao"
	aCampos 	:= {}

	SX3->( DbSetOrder(1) )
	SX3->( MsSeek("B01") )
	aCampos := {}
	STORE FIELD "B01" TO aCampos For ! (SX3->X3_CAMPO $ "B01_FILIAL,B01_NUMLIB") .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)
else
	Help("",1,"plsa090tip")
	If nopc==3
		inclui := slvinclui
	Endif
    Return
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ja foi definido um numero de protocolo no atendimento call center				   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cNumProTMK)
	cNumProto := cNumProTMK
EndIf

DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-017 BOLD
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeader e aCols Sintetico...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDentesFaces := {}
acabdf 		 := {}
adaddf 	     := {}
atrbdf 		 := {}
aAutFor 	 := {}
aCabCri      := {}
aDadCri	     := {}
aTrbCri      := {}
cSeq		 := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca dado do parametro...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("PLS090",.F.)
cCodLocPar := mv_par01
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeader e aCols Procedimentos...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCabProc := PLSA090Hea("3",__ctipo)
aDadProc := PLSA090ClB(aCabProc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se for exclusao testa se pode ser excluida (no caso de exclusao)         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Excluir

	//³ Verifica se a Guia esta em análise antes da exclusão
	If nOpc == K_Excluir
		If !PLSA092VL2(cAlias)
			Return
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a guia foi cobrada (custo, VD, Co-Participacao, Etc)         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BCI->(DbSetOrder(1))
	If BCI->(MsSeek(xFilial("BCI")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG)))
		If BCI->BCI_TIPGUI $ "01,02,13"
			BD5->(DbSetOrder(1))
			If BD5->(MsSeek(xFilial("BD5")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)))
				cSeqPF    := BD5->BD5_SEQPF
				cFaseGuia := BD5->BD5_FASE
			Endif
		Else
			BE4->(DbSetOrder(1))
			If BE4->(MsSeek(xFilial("BE4")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)))
				cSeqPF    := BE4->BE4_SEQPF
				cFaseGuia := BE4->BE4_FASE
			Endif
		Endif
	Endif

	If ! Empty(cSeqPF)
		If PLSVERCCBG(BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG),BEA->BEA_ANOPAG,BEA->BEA_MESPAG,cSeqPF)
			Aviso(STR0004,STR0005,{STR0090},2) //"Guia Cobrada"###"Ja gerada a cobranca de custo operacional/co-participacao portanto nao podera ser excluida"
			Return
		Endif
	Endif

	If cFaseGuia == "4"
		Aviso(STR0006,STR0007,{STR0090},2)    //"Guia Paga"###"Guia ja paga portanto nao podera ser excluida"
		Return
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se e uma liberacao fechada nao pode ser excluida                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BEA->BEA_ORIGEM == "2" .And. BEA->(FieldPos("BEA_STALIB")) > 0 .And. BEA->BEA_STALIB == "2"
		Aviso( STR0089, ; 			//"Atencao"
				STR0088,; 			//"Para esta liberação foi gerada autorizações portando nao poderá ser excluída"
				{ STR0090 }, 2 )	//"Ok"
		Return
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se e uma liberacao em aberto que ja tenha sido gerado pelo menos uma autorizacao nao pode excluir ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BEA->BEA_ORIGEM == "2" .And. BEA->(FieldPos("BEA_STALIB")) > 0 .And. BEA->BEA_STALIB == "1" .And. BEA->(FieldPos("BEA_NRTROL")) > 0

	   cSQL := "SELECT BEA_FILIAL FROM "+BEA->(RetSQLName("BEA"))+" WHERE "
	   cSQL += "BEA_FILIAL = '"+xFilial("BEA")+"' AND "
	   cSQL += "BEA_NRLBOR = '"+cChave+"' AND "
	   cSQL += "D_E_L_E_T_ = ' '"
	   PLSQuery(cSQL,"TrbBEA")

	   If ! TrbBEA->(Eof())
			Aviso( STR0089, ; 			//"Atencao"
					STR0088,; 			//"Para esta liberação foi gerada autorizações portando nao poderá ser excluída"
					{ STR0090 }, 2 )	//"Ok"

	      	TrbBEA->(DbCloseArea())
	      	Return
	   Else
	      TrbBEA->(DbCloseArea())
	   Endif
	EndIf
	
	If BEA->BEA_GUIACO == "1" .And. BEA->BEA_QUACOB == "1"

		SE1->(DbSetOrder(1))

		If lBEANTit
			cChvSE1 := BEA->(BEA_PREFIX+BEA_NUMTIT+BEA_PARCEL+BEA_TIPTIT)
		else
			cChvSE1 := BEA->BEA_CHVSE1
		endIf

		If SE1->(MsSeek(xFilial("SE1")+cChvSE1))

			//Executa funcao que analisa a possibilidade de exclusao de uma guia que teve movimentacao financeiro relacionada..
			aRetASE1 := PLSA090AE1(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA)

			//[1] - Calendario contabil (.T./.F.)
			//[2] - Movimentado (.T./.F.)
			
			if aRetASE1[1] .and. aRetASE1[2]

				Aviso(	STR0101,;//"Guia Comprada"
						STR0100,; //"Esta guia foi comprada e paga no ato, e o respectivo titulo a receber ja sofreu baixa. Voce deve cancelar a baixa para consegui excluir a guia."
						{ STR0090 }, 2 )
				
				If nOpc == K_Incluir
					Inclui := SlvInclui
				endIf
				
				Return

			else

				//exclui titulos ou nota				
				if ! P629ExcE1()
					return
				endIf

			endIf

		endIf

	endIf

EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta dados do GetDados procedimentos...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Copiar

	   If cLiber == "2"
			Aviso(STR0094,STR0095,{STR0090},2)//"Copia não autorizada","Esta Liberação encontra-se fechada e não pode ser copiada!",{"OK"}
			Return
	   EndIf
       __lAutoriz := .F.
       Inclui := .F.

	   Copy "BE1" TO Memory
       Copy "B01" TO Memory

       Inclui := .T.

       cOpeMov    := BEA->BEA_OPEMOV
       cAnoAut    := BEA->BEA_ANOAUT
       cMesAut    := BEA->BEA_MESAUT
       cNumAut    := BEA->BEA_NUMAUT
       cChave     := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)

	   If M->B01_NUMLIB == cChave
       	 M->B01_NUMLIB:=""
	   EndIf

       If ! PLS090MDao(cChave,"1",aCabProc,aTrbProc,aDadProc,"BE2")
          Return
       Endif
		
		PLSA090USR(M->B01_USUARI,M->B01_DATPRO,M->B01_HORPRO,"B01")

		
	   PLSA090RDA(BEA->BEA_OPERDA,BEA->BEA_CODRDA,"1",BEA->BEA_DATPRO,BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG),BEA->(BEA_CODLOC+BEA_LOCAL),BEA->BEA_CODESP,"B01",.F.,,,,,__ctipo,oBrwPro,oBrwCri)

	   M->B01_TIPPRE := BEA->BEA_TIPPRE

	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida calendario pagto...                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   aRetAux := PLS746CAL(BEA->BEA_OPEMOV,BEA->BEA_ANOPAG,BEA->BEA_MESPAG)

       If ! aRetAux[1]
          Return
       Endif

       nPos1 := PLRETPOS("BE2_IMGSTA",aCabProc)
       nPos2 := PLRETPOS("BE2_STATUS",aCabProc)

       For nFor := 1 To Len(aDadProc)
           aDadProc[nFor,nPos1] := If(aDadProc[nFor,nPos2]=="1","ENABLE","DISABLE")
       Next
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Monta as criticas relacionadas ao procedimento...                        ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Store Header "BEG" TO aCabCri For .T.

       BEG->(DbSetOrder(1))
       If ! BEG->(MsSeek(xFilial("BEG")+cChave))
          Store COLS Blank "BEG" TO aDadCri FROM aCabCri
       Else
          Store COLS "BEG" TO aDadCri FROM aCabCri VETTRAB aTrbCri While ;
          xFilial("BEG")+cChave == BEG->(BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT)
       Endif
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Monta os Dentes/Faces relacionados ao procedimento...                    ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Store Header "BYS" TO aCabDF For .T.

       BYS->(DbSetOrder(1))
       If ! BYS->(MsSeek(xFilial("BYS")+cChave))
          Store COLS Blank "BYS" TO aDadDF FROM aCabDF
       Else
          Store COLS "BYS" TO aDadDF FROM aCabDF VETTRAB aTrbDF While ;
          xFilial("BYS")+cChave == BYS->(BYS_FILIAL+BYS_OPEMOV+BYS_ANOAUT+BYS_MESAUT+BYS_NUMAUT)
       EndIf
ElseIf nOpc <> K_Incluir .And. nOpc <> K_Copiar

       Copy "B01" TO Memory

       cOpeMov    := BEA->BEA_OPEMOV
       cAnoAut    := BEA->BEA_ANOAUT
       cMesAut    := BEA->BEA_MESAUT
       cNumAut    := BEA->BEA_NUMAUT
       cChave     := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)

       If ! PLS090MDao(cChave,"1",aCabProc,aTrbProc,aDadProc,"BE2")
          Return
       Endif

       If nOpc == K_Visualizar  .Or.  nOpc == K_Excluir
       		lValidVis := .F.
       Endif

       PLSA090USR(BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO),BEA->BEA_DATPRO,BEA->BEA_HORPRO,;
                        "B01",.F.,nil,nil,nil,nil,nil,nil,nil,nil,nil,;
       					nil,nil,nil,lValidVis,Iif(nOpc == K_Incluir .Or. nOpc == K_Copiar,.T.,.F.))

       If nOpc <> K_Visualizar .And. nOpc <> K_Excluir

   			PLSA090RDA(BEA->BEA_OPERDA,BEA->BEA_CODRDA,"1",BEA->BEA_DATPRO,;
            	      BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG),;
                	  BEA->(BEA_CODLOC+BEA_LOCAL),BEA->BEA_CODESP,"B01",.F.,,,,,__ctipo,oBrwPro,oBrwCri)
       Endif

	   M->B01_TIPPRE := BEA->BEA_TIPPRE
 	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Valida calendario pagto...                                               ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       aRetAux := PLS746CAL(BEA->BEA_OPEMOV,BEA->BEA_ANOPAG,BEA->BEA_MESPAG)
     
       nPos1 := PLRETPOS("BE2_IMGSTA",aCabProc)
       nPos2 := PLRETPOS("BE2_STATUS",aCabProc)

       For nFor := 1 To Len(aDadProc)
           aDadProc[nFor,nPos1] := If(aDadProc[nFor,nPos2]=="1","ENABLE","DISABLE")
       Next
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Monta as criticas relacionadas ao procedimento...                        ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   BEG->(DbCloseArea())

       Store Header "BEG" TO aCabCri For .T.

       BEG->(DbSetOrder(1))
       If ! BEG->(MsSeek(xFilial("BEG")+cChave))
          Store COLS Blank "BEG" TO aDadCri FROM aCabCri
       Else
          Store COLS "BEG" TO aDadCri FROM aCabCri VETTRAB aTrbCri While ;
          xFilial("BEG")+cChave == BEG->(BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT)
       Endif
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Monta os Dentes/Faces relacionados ao procedimento...                    ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       Store Header "BYS" TO aCabDF For .T.

       BYS->(DbSetOrder(1))
       If ! BYS->(MsSeek(xFilial("BYS")+cChave))
          Store COLS Blank "BYS" TO aDadDF FROM aCabDF
       Else
          Store COLS "BYS" TO aDadDF FROM aCabDF VETTRAB aTrbDF While ;
          xFilial("BYS")+cChave == BYS->(BYS_FILIAL+BYS_OPEMOV+BYS_ANOAUT+BYS_MESAUT+BYS_NUMAUT)
       EndIf
Elseif nOpc == K_Incluir

       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³ Valida calendario pagto...                                               ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       aRetAux := PLSXVLDCAL(dDataBase,PLSINTPAD(),.T.,"","")

       If ! aRetAux[1]
          Return
       Endif

       Store Header "BEG" TO aCabCri For .T.
       Store COLS Blank "BEG" TO aDadCri FROM aCabCri

       Store Header "BYS" TO aCabDF For .T.
       Store COLS Blank "BYS" TO aDadDF FROM aCabDF

	   Copy "B01" TO Memory Blank
	   Copy "BE1" TO Memory Blank

   	   If !Empty(Alltrim(cBenef))

    		SX3->(DbSetOrder(2))
	        SX3->(MsSeek("B01_USUARI"))

	        M->B01_USUARI := cBenef
	        If (Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .Or. Empty(SX3->X3_VALID)) .And. (Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }")) .Or. Empty(SX3->X3_VLDUSER))
	           RunTrigger(1)
	        Endif
       EndIf

       If __cTipo == "2" .or. !Empty(cRda)

	         cMVPLSRDAG := Iif(!Empty(cRda),cRda,GetNewPar("MV_PLSRDAG","999999"))
	         SX3->(DbSetOrder(2))
	         SX3->(MsSeek("B01_CODRDA"))

	         M->B01_CODRDA := cMVPLSRDAG
	         If (Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .Or. Empty(SX3->X3_VALID)) .And. (Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }")) .Or. Empty(SX3->X3_VLDUSER))
		        RunTrigger(1)
		     EndIf

       EndIf

       If !Empty(cLoc)

       		SX3->(DbSetOrder(2))
	        SX3->(MsSeek("B01_CODLOC"))

	        M->B01_CODLOC := cLoc

	         If (Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .Or. Empty(SX3->X3_VALID)) .And. (Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }")) .Or. Empty(SX3->X3_VLDUSER))
	            RunTrigger(1)
	         Endif

       EndIf

       If !Empty(cEsp)

       		SX3->(DbSetOrder(2))
	        SX3->(MsSeek("B01_CODESP"))

	        M->B01_CODESP := cEsp

	         If (Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .Or. Empty(SX3->X3_VALID)) .And. (Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }")) .Or. Empty(SX3->X3_VLDUSER))
	            RunTrigger(1)
	         Endif

       Endif

       If !Empty(cCid)

       		SX3->(DbSetOrder(2))
	        SX3->(MsSeek("B01_CID"))

	        M->B01_CID := cCid

	         If (Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .Or. Empty(SX3->X3_VALID)) .And. (Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }")) .Or. Empty(SX3->X3_VLDUSER))
	            RunTrigger(1)
	         Endif

       Endif

       If !Empty(cRegSol)

       		SX3->(DbSetOrder(2))
	        SX3->(MsSeek("B01_REGSOL"))

	        M->B01_REGSOL := cRegSol

	         If (Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .Or. Empty(SX3->X3_VALID)) .And. (Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }")) .Or. Empty(SX3->X3_VLDUSER))
	            RunTrigger(1)
	         Endif

       Endif

       If !Empty(cRegExe)

       		SX3->(DbSetOrder(2))
	        SX3->(MsSeek("B01_REGEXE"))

	        M->B01_REGEXE := cRegExe

	         If (Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .Or. Empty(SX3->X3_VALID)) .And. (Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }")) .Or. Empty(SX3->X3_VLDUSER))
	            RunTrigger(1)
	         Endif
       Endif
       
       //Preenchimento do Protocolo caso haja uma solicitação de autorização p um beneficiario via Portal.
	   If !Empty(cNrProWeb)
			M->B01_PROATE := cNrProWeb
	   EndIf 
	
Endif

aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 001, Iif(GetNewPar("MV_PLSMODA","1") == "0",020,Iif(nOpc == K_Incluir .Or. nOpc == K_Copiar,000,020)), .T., .F.,.F. } )
AAdd( aObjects, { 001, 000, .T., .T.,.F. } )
AAdd( aObjects, { 001, 100, .T., .F.,.T. } )

aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects )

aPosObj[1][2]+=15
aPosObj[2][2]+=15
aPosObj[3][2]+=15
aPosObj[3][3]-=15

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Dialog...                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5]  of oMainWnd PIXEL//OF GetWndDefault()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Enchoice...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oEncAut := &(PLSRetAut('2')[2])->(MSMGet():New(PLSRetAut('2')[2],B01->(Recno()),nOpc,,,,aCampos,aPosObj[2],,,,,,oDlg,,IIF(nOpc == K_Incluir,.T.,),.F.))
	If FunName() == "TMKA271"//tratamento referente ao chamado TRPWSM
   	   If !Empty(Alltrim(cBenef))

    		SX3->(DbSetOrder(2))
	        SX3->(MsSeek("B01_USUARI"))

	        M->B01_USUARI := (Alltrim(cBenef))
	        If Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .And. Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }"))
	           RunTrigger(1)
	        Endif
       EndIf
       
       If !Empty(cNumProto) 
        	M->B01_PROATE := cNumProto
       EndIf
       
       If !Empty(Alltrim(cRda))

    		SX3->(DbSetOrder(2))
	        SX3->(MsSeek("B01_CODRDA"))

	        M->B01_CODRDA := (Alltrim(cRda))
       EndIf
       
       Endif

If nOpc == K_Copiar	
	If FunName() == 'PLSA094D' //Liberacao Odonto
		M->B01_NUMLIB := Space(TamSx3("B01_NUMLIB")[1])
		M->B01_USUARI := Space(TamSx3("B01_USUARI")[1])
		M->B01_NOMUSR := Space(TamSx3("B01_NOMUSR")[1])
		M->B01_TIPUSR := Space(TamSx3("B01_TIPUSR")[1])
		M->B01_MATANT := Space(TamSx3("B01_MATANT")[1])
		M->B01_MATUSA := Space(TamSx3("B01_MATUSA")[1])
	ElseIf FunName() == 'PLSA094C' //Autorizacao Odonto
		M->B01_USUARI := Space(TamSx3("B01_USUARI")[1])
		M->B01_NOMUSR := Space(TamSx3("B01_NOMUSR")[1])
		M->B01_TIPUSR := Space(TamSx3("B01_TIPUSR")[1])
		M->B01_MATANT := Space(TamSx3("B01_MATANT")[1])
		M->B01_MATUSA := Space(TamSx3("B01_MATUSA")[1])
		M->B01_CODRDA := Space(TamSx3("B01_CODRDA")[1])
		M->B01_NOMRDA := Space(TamSx3("B01_NOMRDA")[1])
		M->B01_TIPPRE := Space(TamSx3("B01_TIPPRE")[1])
		M->B01_CODLOC := Space(TamSx3("B01_CODLOC")[1])
		M->B01_DESLOC := Space(TamSx3("B01_DESLOC")[1])
		M->B01_ENDLOC := Space(TamSx3("B01_ENDLOC")[1])
		M->B01_CODESP := Space(TamSx3("B01_CODESP")[1])
		M->B01_DESESP := Space(TamSx3("B01_DESESP")[1])
	EndIf
EndIf

If nOpc == K_Incluir .Or. nOpc == K_Copiar
      M->B01_MESPAG := aRetAux[5]
      M->B01_ANOPAG := aRetAux[4]
	  if __cTipo == "2" .or. !Empty(cRda)			
		M->B01_CODRDA := cMVPLSRDAG 
		if !Empty(M->B01_CODRDA)
			PLA090VRDo()
		endif
	endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe say...                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPosObj[1,1]+6,aPosObj[1,2]+5  SAY oSay PROMPT STR0008  SIZE 220,010 OF oDlg PIXEL FONT oFontAutor //"Autorização Número  "
	@ aPosObj[1,1]+6,aPosObj[1,2]+100 SAY oSay PROMPT TransForm(M->B01_NUMAUT,PesqPict("B01","B01_NUMAUT")) SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED FONT oFontAutor
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zera o campo BE2_QTDPRO quando escolhida a opcao de Copiar.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Copiar
	nQtdPro  := Ascan(aCabProc,{|x| Alltrim(x[2]) == "BE2_QTDPRO"})
	nValComp := Ascan(aCabProc,{|x| Alltrim(x[2]) == "BE2_VLCOMP"})

	For nX := 1 To Len(aDadProc)
		aDadProc[nX][nQtdPro]  := 0
		aDadProc[nX][nValComp] := 0
	Next nX
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define folder...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFolder 		:= TFolder():New(aPosObj[3,1],aPosObj[3,2],{STR0009,STR0010,STR0011},{"","",""},oDlg,,,,.T.,.F.,aPosObj[3,3],aPosObj[3,4])  //"Eventos"###"Dentes/Faces"###"Críticas"
oFolder:bChange := {|nFolder| oBrwPro:oBrowse:oBrowse:Refresh(), oBrwEven:oBrowse:oBrowse:nAt := Len(oBrwEven:aCols),	oBrwEven:ForceRefresh(oBrwPro), oBrwCri:ForceRefresh(oBrwPro), P090SEQCRI() }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Eventos	                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FindFunction("PLSNEGCOM")
	If nOpc == K_Incluir
		AaDd(aProcAbert,{"NCO",{|| aMatCom := PLSNEGCOM(M->BE2_SEQUEN,M->BE2_CODPAD,M->BE2_CODPRO,M->BE2_STATUS,M->B01_DATPRO,,,IIF(__cTipo == '1',.F.,.T.),M->B01_CODRDA,M->B01_CODESP,M->B01_CODLOC,M->B01_USUARI) },STR0096,IIF(__cTipo == '1',STR0097,"Composição")}) //"Composição do procedimento" "Negar Comp./Composição"
	Else
		AaDd(aProcAbert,{"NCO",{|| aMatCom := PLSNEGCOM(M->BE2_SEQUEN,M->BE2_CODPAD,M->BE2_CODPRO,M->BE2_STATUS,M->B01_DATPRO,oBrwPro:nOpcX,BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)+M->BE2_SEQUEN,,M->B01_CODRDA,M->B01_CODESP,BEA->(BEA_CODLOC+BEA_LOCAL),BEA->(BEA_OPEMOV+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO) ) },STR0096,STR0098})//"Composição"
	EndIf
EndIf

oBrwPro 			:= TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil,  oFolder:aDialogs[1],nil,,nil,nil,nil,.T.,nil,.T.,nil,aCabProc,aDadProc,.F.,"BE2",IIf(nOpc = K_Excluir,K_Visualizar,nOpc),STR0012,nil,nil,nil,aTrbProc,"PlVlOOk()",nil,nil,{|a,b,c| PLSA090CoO(a,b,c), PLSGRVEVEN(aDentesFaces,oBrwEven,oBrwPro)},aProcAbert,nil,{|| Iif(oBrwPro:nOpcX==K_Incluir .And. FindFunction("PLSLIMSTA"),PLSLIMSTA(M->BE2_SEQUEN+M->BE2_CODPAD+M->BE2_CODPRO),nil) }) //"Eventos da Liberação"
oBrwPro:bLostFocus 	:= {|| P090SEQCRI(),lRefresh := .T. }
oBrwPro:bChange    	:= {|| Eval(oBrwPro:bLostFocus), oBrwEven:ForceRefresh(oBrwPro), oBrwCri:ForceRefresh(oBrwPro) }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Dentes/Faces                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bFilEven         := {|nLine,aCols,aHeader| aCols[nLine,PLRETPOS("BYS_SEQUEN",aHeader,.T.)] == oBrwPro:FieldGet("BE2_SEQUEN") }
oBrwEven 		 := TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil  ,oFolder:aDialogs[2],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabDF,aDadDF,.F.,"BYS",K_Visualizar,STR0010,nil,nil,nil,aTrbDF,,,bFilEven) //"Dentes/Faces"
oBrwEven:oPai    := oBrwPro
oBrwEven:aOrigem := {"BE2_SEQUEN"}
oBrwEven:aRelac  := {"BYS_SEQUEN"}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Criticas                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bFilCri         := {|nLine,aCols,aHeader| aCols[nLine,PLRETPOS("BEG_SEQUEN",aHeader)] == oBrwPro:FieldGet("BE2_SEQUEN") }
oBrwCri 		:= TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil  ,oFolder:aDialogs[3],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabCri,aDadCri,.F.,"BEG",K_Visualizar,STR0013,nil,nil,nil,aTrbCri,,,bFilCri) //"Criticas da Liberação"
oBrwCri:oPai    := oBrwPro
oBrwCri:aOrigem := {"BE2_SEQUEN"}
oBrwCri:aRelac  := {"BEG_SEQUEN"}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Starta funcao padrao para montar botoes padrao...                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PLSA090Bot(nOpc,"B01",oEncAut,oBrwPro,"BE2",{ || M->B01_USUARI },aButtons,oFolder,oDlg,oSay02,STR0014,oBrwCri) //"Autorizacao"

if existblock("plsoddia")
    execblock("plsoddia", .f. , .f. )
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna a chave relacionado a auditoria para a exclusao de registros na B72																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if nOpc == K_Excluir

	If PLSALIASEX("B53")
		dbSelectArea("B53")
		dbSetOrder(3)

		If dbSeek(xFilial("BEA")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)) // B53_SITUAC, B53_NUMGUI, B53_ORIMOV
			cChGui := b53->(B53_ALIMOV+B53_RECMOV)
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa Dialog...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT Eval( { || EnchoiceBar(oDlg,bOK,bCancel,.F.,aButtons), oEncAut:SetFocus() })
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca retorno contido no aRetorno...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK
   cOpeMov := aRetorno[2]
   cAnoAut := aRetorno[3]
   cMesAut := aRetorno[4]
   cNumAut := aRetorno[5]
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Conclui um protocolo                                                     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If GetNewPar("MV_PLRN395","0") == "1" .And. !Empty(cNumProto)
       P773AutCon("B01",cNumProto,cOpeMov+cAnoAut+cMesAut+cNumAut)
   EndIf
   
   If nOpc == K_Incluir .Or. nOpc == K_Alterar .Or. nOpc == K_Copiar
      A090Finalo(cOpeMov,cAnoAut,cMesAut,cNumAut,aRetorno,oBrwPro)
   Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui os registros no banco de conhecimento relacionados com a guia excluida //
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÄÄÄÄÄ¿
If nOpca == K_OK .AND. FindFunction("PLSA092EBC")
	PLSA092EBC(cOpeMov, cAnoAut, cMesAut, cNumAut)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui os registros da B72 relacionados a auditoria  							 //
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÄÄÄÄÄ¿
If nOpca == K_OK .And. FindFunction("PLS92B72")
	If !EMPTY(cChGui)
		PLS92B72(cChGui)
		If nOpc == K_Excluir
			DelMovAud(cChGui)
		EndIf		
	EndIf	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Limpa DADUSR
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PLSCLEAUSR()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desativa Sets Keys...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET KEY VK_F5 TO
SET KEY VK_F6 TO
SET KEY VK_F7 TO
SET KEY VK_F8 TO
SET KEY VK_F9 TO
SET KEY VK_F10 TO
SET KEY VK_F11 TO
SET KEY VK_F12 TO
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Refaz filtro...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("BEA")
BEA->(DbSetOrder(nOrdBEA))

if Type('oBrwBEA') == "O"
	oBrwBEA:Refresh()
endIf

If nRegBEA > 0
   BEA->(DbGoTo(nRegBEA))
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLA090oHEA³ Autor ³ Daher                 ³ Data ³ 13.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta a header padrao                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLA090oHea()
LOCAL cCampos := PLA090oFld()
LOCAL aCabProc := {}
Store Header "BYS" TO aCabProc For ( alltrim(SX3->X3_CAMPO) $ cCampos )
Return(aCabProc)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLA090oCLB³ Autor ³ Daher		            ³ Data ³ 13.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta aCols Blank padrao...                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLA090oClB(aCabProc)
LOCAL aDadProc := {}
Store COLS Blank "BYS" TO aDadProc FROM aCabProc
Return(aDadProc)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLA090oFld³ Autor ³ Daher		            ³ Data ³ 13.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Campos do odonto a serem exibidos                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLA090oFld()

LOCAL cCampos := "BYS_CODIGO,BYS_DESCRI,BYS_TIPO,"
      cCampos += "BYS_M_ARCO,BYS_FACES"

If  ExistBlock("PL090oFL1")
      cCampos += ","+ExecBlock("PL090oFL1",.F.,.F.)
endif

Return(cCampos)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLA090CPMo³ Autor ³ Daher		            ³ Data ³ 13.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLA090CPMo(cAliasIte, cAliasPro, cAliasCri, OBrCri)

LOCAL cAliasIte := IIF(!EMPTY(cAliasIte),cAliasIte,"B01")
LOCAL cAliasPro := IIF(!EMPTY(cAliasPro),cAliasPro,"BE2")
LOCAL cAliasCri := IIF(!EMPTY(cAliasCri),cAliasCri,"BEG")

LOCAL lRet      := .T.
LOCAL lFlag		:= .F.
LOCAL aDadUsr   := PLSGETUSR()
LOCAL aDadRDA   := PLSGETRDA()
LOCAL cCodPad   := &("M->"+cAliasPro+"_CODPAD")
LOCAL cCodPro   := &("M->"+cAliasPro+"_CODPRO")
LOCAL dDatPro   := &("M->"+cAliasIte+"_DATPRO")
LOCAL nQtdPro   := &("M->"+cAliasPro+"_QTDPRO")
LOCAL cCid      := &("M->"+cAliasIte+"_CID")
LOCAL cCodExe   := &("M->"+cAliasIte+"_REGEXE")
LOCAL cHorPro   := &("M->"+cAliasIte+"_HORPRO")
LOCAL cOpeSol   := &("M->"+cAliasIte+"_OPESOL")
LOCAL cCdPfSo   := &("M->"+cAliasIte+"_CDPFSO")
LOCAL cAnoPag   := &("M->"+cAliasIte+"_ANOPAG")
LOCAL cMesPag   := &("M->"+cAliasIte+"_MESPAG")
LOCAL cchavlib 	:= ""
LOCAL cCodEsp   := ""
LOCAL cFaces	:= &("M->"+cAliasPro+"_FADENT")
LOCAL cDente	:= &("M->"+cAliasPro+"_DENREG")
LOCAL nFor		:= 1
LOCAL aHisCri	:= {}
LOCAL aRetFun	  := {}
LOCAL aAuxRetPro  := {}
LOCAL aOldCodCri  := {}
LOCAL aRet		:= {}
LOCAL aValor	  	:= {}
LOCAL aQtdBrow	:= {}
LOCAL lAuditoria := .F.
LOCAL lPerFor	  	:= .T.
LOCAL lLibEsp	  	:= .F.
LOCAL lAto		:= .F.
LOCAL lChkPag	  	:= .T.
LOCAL cCodGloAud := __aCdCri051[1]
LOCAL cSequen    	:= &("M->"+cAliasPro+"_SEQUEN")
LOCAL cGuiJur	  	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ passa objeto por parâmetro									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(oBrwCri) != "O" .AND. !EMPTY(OBrCri)
 oBrwCri := OBrCri
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se todos obrigatorios foram informados									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(oEncAut) <> 'U'
	If !Obrigatorio(oEncAut:aGets,oEncAut:aTela)
	   Return(.F.)
	Endif
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao informado															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("M->"+cAliasIte+"_CODRDA") == "C"
   If Empty(&("M->"+cAliasIte+"_CODRDA"))
      Aviso( "RDA", ;
             STR0015,; //"Rede de Atendimento." //"Informe a Rede de Atendimento."
             { STR0090 }, 2 )
      Return(.F.)
   Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao informado															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aDadUsr) == 0
   If Empty(&("M->"+cAliasIte+"_USUARI"))
      Aviso( STR0016, ; //"Usuario" //"Usuario"
             STR0017,; //"Informe um usuario valido." //"Informe um usuario valido."
             { STR0090 }, 2 )
      Return(.F.)
   Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Numero da Liberacao														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("M->"+cAliasIte+"_NUMLIB")=="C"
    If !( Empty( &("M->"+cAliasIte+"_NUMLIB") ) )
        cChavLib := &("M->"+cAliasIte+"_NUMLIB")
    EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guia Juridica.
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("M->"+cAliasIte+"_GUIJUR")=="C"
	cGuiJur := &("M->"+cAliasIte+"_GUIJUR")

	// O campo Guia Juridica só será considerado se todos os critérios da critica forem atendidos.
	// Caso contrario, ignora o conteudo do campo.
	If cGuiJur == "1"
		If !PlsGetJur()[1]
			cGuiJur := ""
		Endif
	Endif
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Pega os procedimentos que estao contidos no browse
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If ValType(oBrwPro) == "O"
	For nFor := 1 To Len(oBrwPro:aCols)
	    If !oBrwPro:aCols[nFor][Len(oBrwPro:aCols[nFor])] .and. oBrwPro:aCols[nFor][oBrwPro:FieldPos(cAliasPro+"_STATUS")] == "1" .and. oBrwPro:aCols[nFor][oBrwPro:FieldPos(cAliasPro+"_SEQUEN")] <> cSequen
	        AaDd(aQtdBrow,{oBrwPro:aCols[nFor][oBrwPro:FieldPos(cAliasPro+"_CODPAD")],;
	        				oBrwPro:aCols[nFor][oBrwPro:FieldPos(cAliasPro+"_CODPRO")],;
	        				oBrwPro:aCols[nFor][oBrwPro:FieldPos(cAliasPro+"_QTDPRO")],;
	        				dDatPro,;
	        				&("M->"+cAliasIte+"_HORPRO"),;
	        				If(oBrwPro:FieldPos(cAliasPro+"_DENREG")>0,oBrwPro:aCols[nFor][oBrwPro:FieldPos(cAliasPro+"_DENREG")],""),;//dente
	        				If(oBrwPro:FieldPos(cAliasPro+"_FADENT")>0,oBrwPro:aCols[nFor][oBrwPro:FieldPos(cAliasPro+"_FADENT")],""),;//face
							oBrwPro:aCols[nFor][oBrwPro:FieldPos(cAliasPro+"_SEQUEN")]})
	    EndIf
	Next
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciono no procedimento												 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BR8->( DbSetOrder(1) )
lRet := BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Utiliza a especialidade indicada na rotina					             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("M->B01_CODESP") == "C" .And. !Empty(M->B01_CODESP)
    cCodEsp := M->B01_CODESP
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se foi um procedimento sem inf. o dente									 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Rodo aAutorizacao pra todos os dentes									 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRetFun := PLSAUTP(dDatPro,;
	               	cHorPro,;
                	cCodPad,;
                	cCodPro,;
                	nQtdPro,;
                	aDadUsr,;
                	0,;
                	aDadRDA,;
                	"1",;
                	.T.,;
                	cCid,;
                	.T.,;
                	"1",;
					.F.,; //Parametro alterado pelo chamado TIAXJ4
					cOpeSol,;
					cCdPfSo,;
					cAnoPag,;
					cMesPag,;
                	nil,;
                	nil,;
                	nil,;
                	.T.,;
                	cCodExe,;
                	nil,;
                	nil,;
                	nil,;
                	nil,;
                	nil,;
                	nil,;
                	nil,;
                	cSequen,;
                	nil,;
                	nil,;
                	"1",;
                	cFaces,;
                	nil,;
                	nil,;
                	nil,;
                	nil,;
                	nil,;
                	nil,;
                	cChavLib,;
                	nil,;
                	nil,;
                	nil,;
                	cDente,;
                	NIL,;
                	nil,;
                	Iif(__cTipo=="2", .F. , .T. ),;
                	nil,;
                	iif(__cTipo=="2","S","E"),;
                	if(!Empty(cCodEsp),cCodEsp,nil),;//52
                	aQtdBrow,nil,nil,nil,;
				 nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,cGuiJur)

	aRet := aClone(aRetFun)
    lRet := aRet[1]
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa o browse caso troque o procedimento	Alexander 05/08/05			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nFor := 1 To Len(oBrwCri:aCols)
	    If oBrwCri:FieldGet(cAliasCri+"_SEQUEN",nFor) == cSequen .And. !Empty(oBrwCri:FieldGet(cAliasCri+"_DESGLO",nFor))
	       oBrwCri:FieldPut(cAliasCri+"_SEQUEN","",nFor)
	       oBrwCri:FieldPut(cAliasCri+"_CODGLO","",nFor)
	       oBrwCri:FieldPut(cAliasCri+"_DESGLO","",nFor)
	    EndIf
	Next
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa o browse caso troque o procedimento								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If ! aRet[1]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Paga as criticas														 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aHisCri 	:= aClone( aRet[2] )
		lAuditoria	:= Ascan( aHisCri,{|x| x[1] == cCodGloAud } ) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico se a critica dele colocar o procedimento em auditoria			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lAuditoria .And. Len(aHisCri) > 0
			If BCT->( FieldPos("BCT_AUDITO") ) > 0
			      BCT->( DbSetOrder(1) ) //BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO
			      If BCT->( MsSeek( xFilial("BCT")+PlsIntPad()+aHisCri[1,1] ) )
				     	lAuditoria := Iif(BCT->BCT_AUDITO == "1",.T.,.F.)
			      EndIf
			EndIf
		EndIf	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se procedimento em auditoria se enquandra na exceção cadastrada ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   if lAuditoria 
	     //³B1O_CODPRO+B1O_TPGUIA+B1O_IDADE+B1O_QTDPRO
	     if PLSVLDEX(cCodPro+PLSRetAut()[1],aDadUsr[26],nQtdPro)
	       lAuditoria := .F.
	       aRet[1] := .T.
	       aRet[2] := {}
	       aRet[3] := "B1O"
	     endif  
	   endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso nao seja autorizada analiso o campo que trata se e permitido forcar ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPerFor .And. ! aRet[1]
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ 1o Regra. somente se todos as criticas podem forcar e que entra na regra de forcar ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If BR8->BR8_PERFOR <> "1"
	      BCT->(DbSetOrder(1))
	      For nFor := 1 To Len(aRet[2])
	          If aRet[2][nFor][1] <> cCodGloAud
	             If ! Empty(aRet[2][nFor][1])
	                If BCT->(MsSeek(xFilial("BCT")+PlsIntPad()+aRet[2][nFor][1])) .And. BCT->BCT_PERFOR == "1"
	                   lFlag := .T.
	                Else
	                  lFlag := .F.
	                  Exit
	                Endif
	             Endif
	          Endif
	      Next
	   Else
	      lFlag := .T.
	   Endif
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Se existe pelo menos uma critica que pode forcar entra nessa regra de forcar³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   If lFlag

	      lForcou := PLSMOVCRI("1",{cCodPad,cCodPro,BR8->BR8_DESCRI,cSequen},aHisCri,.T.)

	      If lForcou
	         aRet[1] 	:= .T.
	         lRet		:= .T.
	         lAuditoria := .F.

	         If FindFunction("PLLimpCCri") .and. aDadUsr[1] .and. Len(aDadUsr) >= 38
		         aOldCodCri  := PLLimpCCri(.F.)//pega o aCodCri
		         //precisa disso pq antes a funcao nao retornava nada, e se o cliente receber o 090 sem o XAUT vai sar erro
		         If aOldCodCri == nil
		         	aOldCodCri  := {}
		         Endif
				 PLLimpCCri(.T.)//limpa o a codCri
				 aAuxRetPro  := PLSAUTPDIR(aDadUsr[37],aDadUsr[38],cCodPad,cCodPro,aDadUsr,dDatPro,cHorPro,nil,nil,.F.,nil,nQtdPro,nil,nil,nil,;
										   &("M->"+cAliasIte+"_NRAOPE"),&("M->"+cAliasIte+"_NRAEMP"),aDadUsr[11],aDadUsr[12],.T.,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,;
							   	 		   {.F.,.F.,.F.,.F.,.T.,.T.,.T.,.F.,.F.,.F.,.F.})//rodo para pegar o nivel de cobertura, vou precisar para calcular a co participacao
		         PLLimpCCri(.F.,.T.,aOldCodCri)//limpa o a codCri

				 If aAuxRetPro[1] .and. Len(aAuxRetPro) >= 4 .and. Len(aRet) >= 4
		         		aRet[3] := aAuxRetPro[3]
		         		aRet[4] := aAuxRetPro[4]
		         Endif
	         Endif

	         nPos    	:= Ascan(aAutFor,{|x| x[2]+x[3] == cCodPad+cCodPro})
	         If nPos == 0
	         	cCodMot := RetCodMot(cCodPad,cCodPro,aHisCri)[1]
	         	cObsMot := RetCodMot(cCodPad,cCodPro,aHisCri)[2]
	
		        aadd(aAutFor,{.T.,cCodPad,cCodPro,"","","","",0,BCS->(RetCodUsr()),Date(),Time(),cCodMot,cObsMot,cSequen})
	         Endif
	      Else
	         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	         //³ Alimento as criticas...                                                  ³
	         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	         PLSA090ACC(aDadCri,aCabCri,aTrbCri,aHisCri,oBrwCri,cSequen,cAliasCri,oBrwPro)
	      Endif
	   Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Novo tratamento para analisar caso nao tenha cobertura se pode ser       ³
	//³ enviado para liberacao especial ou nao...                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! aRet[1] .And. BCT->(FieldPos("BCT_LIBESP")) > 0
	   BCT->(DbSetOrder(1))
	   If ValType(aRet[2]) == "A" .And. Len(aRet[2]) > 0 .And. BCT->(MsSeek(xFilial("BCT")+plsintpad()+aRet[2,1,1]))
		      lLibEsp := BCT->BCT_LIBESP$"1, "
	   Endif

	   If lLibEsp
	      If BR8->BR8_LIBESP == "0"
	         lLibEsp := .F.
	      Endif
	   Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Atualizo dados da internação											 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	&("M->"+cAliasPro+"_STATUS") := If(aRet[1],"1","0")
    &("M->"+cAliasPro+"_NIVAUT") := If(aRet[1],aRet[3],Space(03))

    If BE2->(FieldPos("BE2_CHVNIV")) > 0
       &("M->"+cAliasPro+"_CHVNIV") := If(Len(aRet)>=4 .And. ValType(aRet[4]) == "C",aRet[4],Space(60))
    Endif

    &("M->"+cAliasPro+"_DESPRO") := BR8->BR8_DESCRI
    &("M->"+cAliasPro+"_NIVCRI") := If(!aRet[1],aRet[3],Space(03))
    &("M->"+cAliasPro+"_NIVEL")  := BR8->BR8_NIVEL

    If lLibEsp
       &("M->"+cAliasPro+"_LIBESP")  := If(lLibEsp,"1","0")
    Endif
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Trata situacao de prioridade da rede de atendimento...                   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If GetNewPar("MV_PLSMODA","1") == "0"
      Pergunte("PLS090",.F.)
      cCodLocPar := mv_par01
      PLSA090ATP(cAliasPro,cAliasIte,oEnc,cCodLocPar)
    Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ foi autorizado, verificar guia paga no ATO...                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aRet) >= 5 .And. aRet[5]
	   aValor := aRet[6]

	   If aValor[1] .And. aValor[16] == "1" .and. If(Len(aValor)>=27,!aValor[27],.T.)
	      If BA3->BA3_TIPOUS == "1"
	         aCliente := PLBuscaClien("1","1",aDadUsr)
	      Else
	         aCliente := PLBuscaClien("2","1",aDadUsr)
	      Endif

	      If     ! aCliente[1]
	             Help("",1,"PLSA090NCC")
	             &("M->"+cAliasPro+"_STATUS") := "0"

	      ElseIf aValor[12] == 0 .And. BR8->BR8_PODDIG <> "1"
	             Help("",1,"PLSA090NC1")
	             &("M->"+cAliasPro+"_STATUS") := "0"
	      Else
	            If lChkPag
	                lAto          := .T.
	                &("M->"+cAliasIte+"_PAGATO") := "1" //Paga no Ato sim/nao
	                &("M->"+cAliasIte+"_GUIACO") := "1" //Guia comprada sim/nao
	                &("M->"+cAliasIte+"_QUACOB") := "1" //1-No Ato;2-Fatura
	                &("M->"+cAliasPro+"_VLCOMP") := aValor[12]
	                &("M->"+cAliasIte+"_CODCLI") := aCliente[3]
	                &("M->"+cAliasIte+"_LOJA")   := aCliente[4]
	                lRefresh      := .T.

	             Else
	                Aviso( STR0018, ;  //"Compra de Procedimentos"
	                       STR0019,;  //"Este procedimento possui cobertura porem devera ser efetuado o pagamento do procedimento na proxima fatura"
	                        { STR0090 }, 2 )
	             Endif
	      Endif
	   Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Habilita campo para informar valores de compras de mat/med.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	If cAliasPro == "BE2"
		&("M->"+cAliasPro+"_PEREVC") := IF(BR8->BR8_PODDIG$" ,1","1","0")
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se existir critica exibe dialogo...                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( !aRet[1]  .And. ! lPerFor ) .Or. ( !aRet[1]  .And. ! lFLag )
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Monta aHisCri...                                                         ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   PLSMOVCRI("1",{cCodPad,cCodPro,BR8->BR8_DESCRI,cSequen},aHisCri)
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Alimento as criticas...                                                  ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   PLSA090ACC(aDadCri,aCabCri,aTrbCri,aHisCri,oBrwCri,cSequen,cAliasCri,oBrwPro)
	Endif

    &("M->"+cAliasPro+"_AUDITO") := If(lAuditoria,"1","0")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for guia paga no ato exibir mensagem...                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAto .And. aRet[1] //Somente mostrar que tem que pagar no ato se realmente ele tem direito
	   PLSPOSGLO(PLSINTPAD(),__aCdCri056[1],__aCdCri056[2],"1")
	   Aviso( STR0020, PLSBCTDESC(), { STR0090 }, 2 ) 	  //"Pagamento no Ato"
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ aTO																		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAto
	   AtuVlComp(.T.)
	Endif

	If FindFunction("PLSRETNCRI")
	   If ( ! lRet .And. ! lPerFor ) .Or. ( ! lRet .And. ! lFLag ) .Or. ! lRet
		  If      Type("M->"+cAliasPro+"_DNIVCR") == "C" .And. Type("M->"+cAliasPro+"_NIVAUT") == "C" .And. Type("M->"+cAliasPro+"_CHVNIV") == "C" .And. Type("M->"+cAliasPro+"_NIVCRI") == "C"
		          &("M->"+cAliasPro+"_DNIVAU") := ''
		          &("M->"+cAliasPro+"_DNIVCR") := PLSRETNCRI(&("M->"+cAliasPro+"_NIVAUT"), &("M->"+cAliasPro+"_CHVNIV"),&("M->"+cAliasPro+"_NIVCRI"))
	      Endif
	   Else
	       If     Type("M->"+cAliasPro+"_DNIVAU") == "C" .And. Type("M->"+cAliasPro+"_NIVAUT") == "C" .And. Type("M->"+cAliasPro+"_CHVNIV") == "C" .And. Type("M->"+cAliasPro+"_NIVCRI") == "C"
		          &("M->"+cAliasPro+"_DNIVCR") := ''
		          &("M->"+cAliasPro+"_DNIVAU") := PLSRETNCRI(&("M->"+cAliasPro+"_NIVAUT"), &("M->"+cAliasPro+"_CHVNIV"),&("M->"+cAliasPro+"_NIVCRI"))
		   Endif
	   Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava array para pasta Dentes/Faces										 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSeq 	:= cSequen
   lRefresh := .T.
Endif


Return  .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLShowFace³ Autor ³ Daher		            ³ Data ³ 13.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ FACES                          							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLShowFace(cAlias)
LOCAL nLeft   := 40
LOCAL nTop    := 74
LOCAL i       := 1
LOCAL cChave  := ""
LOCAL aFaces  := {}
LOCAL bOk     := {|| aFaces := PlAliFac(),oDlg2:End()}
LOCAL bCancel := {|| oDlg2:End()}

PRIVATE oDlg2 ,oBmp0
PRIVATE oBmp1 ,oBmp2 ,oBmp3 ,oBmp4 ,oBmp5 ,oBmp6 ,oBmp7 ,oBmp8 ,oBmp9 ,oBmp10,oBmp11,oBmp12,oBmp13,oBmp14
PRIVATE oBmp15,oBmp16,oBmp17,oBmp18,oBmp19,oBmp20,oBmp21,oBmp22,oBmp23,oBmp24,oBmp25,oBmp26,oBmp27,oBmp28,oBmp29,oBmp30
PRIVATE oBmp31,oBmp32,oBmp33,oBmp34,oBmp35,oBmp36,oBmp37,oBmp38,oBmp39,oBmp40,oBmp41,oBmp42,oBmp43,oBmp44,oBmp45,oBmp46
PRIVATE oBmp47,oBmp48,oBmp49,oBmp50,oBmp51,oBmp52,oBmp53,oBmp54,oBmp55,oBmp56,oBmp57,oBmp58,oBmp59,oBmp60,oBmp61,oBmp62
PRIVATE oBmp63,oBmp64,oBmp65,oBmp66,oBmp67,oBmp68,oBmp69,oBmp70,oBmp71,oBmp72,oBmp73,oBmp74,oBmp75,oBmp76,oBmp77,oBmp78
PRIVATE oBmp79,oBmp80,oBmp81,oBmp82,oBmp83,oBmp84,oBmp85,oBmp86,oBmp87,oBmp88,oBmp89,oBmp90,oBmp91,oBmp92,oBmp93,oBmp94
PRIVATE oBmp95,oBmp96,oBmp97,oBmp98,oBmp99,oBmp100,oBmp101,oBmp102,oBmp103,oBmp104,oBmp105,oBmp106,oBmp107,oBmp108,oBmp109
PRIVATE oBmp110,oBmp111,oBmp112,oBmp113,oBmp114,oBmp115,oBmp116,oBmp117,oBmp118,oBmp119,oBmp120,oBmp121,oBmp122,oBmp123,oBmp124
PRIVATE oBmp125,oBmp126,oBmp127,oBmp128,oBmp129,oBmp130,oBmp131,oBmp132,oBmp133,oBmp134,oBmp135,oBmp136,oBmp137,oBmp138,oBmp139
PRIVATE oBmp140,oBmp141,oBmp142,oBmp143,oBmp144,oBmp145,oBmp146,oBmp147,oBmp148,oBmp149,oBmp150,oBmp151,oBmp152,oBmp153,oBmp154
PRIVATE oBmp155,oBmp156,oBmp157,oBmp158,oBmp159,oBmp160,oBmp161,oBmp162,oBmp163,oBmp164,oBmp165,oBmp166,oBmp167,oBmp168,oBmp169
PRIVATE oBmp170,oBmp171,oBmp172,oBmp173,oBmp174,oBmp175,oBmp176,oBmp177,oBmp178,oBmp179,oBmp180,oBmp181,oBmp182,oBmp183,oBmp184
PRIVATE oBmp185,oBmp186,oBmp187,oBmp188,oBmp189,oBmp190,oBmp191,oBmp192,oBmp193,oBmp194,oBmp195,oBmp196,oBmp197,oBmp198,oBmp199
PRIVATE oBmp200,oBmp201,oBmp202,oBmp203,oBmp204,oBmp205,oBmp206,oBmp207,oBmp208,oBmp209,oBmp210,oBmp211,oBmp212,oBmp213,oBmp214
PRIVATE oBmp215,oBmp216,oBmp217,oBmp218,oBmp219,oBmp220,oBmp221,oBmp222,oBmp223,oBmp224,oBmp225,oBmp226,oBmp227,oBmp228,oBmp229
PRIVATE oBmp230,oBmp231,oBmp232,oBmp233,oBmp234,oBmp235,oBmp236,oBmp237,oBmp238,oBmp239,oBmp240,oBmp241,oBmp242,oBmp243,oBmp244
PRIVATE oBmp245,oBmp246,oBmp247,oBmp248,oBmp249,oBmp250,oBmp251,oBmp252,oBmp253,oBmp254,oBmp255,oBmp256,oBmp257,oBmp258,oBmp259
PRIVATE oBmp260,oBmp261,oBmp262,oBmp263,oBmp264,oBmp265,oBmp266,oBmp267,oBmp268,oBmp269,oBmp270,oBmp271,oBmp272,oBmp273,oBmp274
PRIVATE oBmp275,oBmp276,oBmp277,oBmp278

If cAlias $ "BE2,BD6"
	oDlg2 := MSDIALOG():Create()
	oDlg2:cName := "oDlg"
	oDlg2:cCaption := STR0021                                  //"Faces Dentarias"
	oDlg2:nLeft := 0
	oDlg2:nTop := 0
	oDlg2:nWidth := 570
	oDlg2:nHeight := 650
	oDlg2:lShowHint := .F.
	oDlg2:lCentered := .F.

	oBmp0 := TBITMAP():Create(oDlg2)
	oBmp0:cName     := "oBmp0"
	oBmp0:cCaption  := "oBmp0"
	oBmp0:nLeft 	:= 1
	oBmp0:nTop 		:= 0
	oBmp0:nWidth 	:= 563
	oBmp0:nHeight 	:= 650
	oBmp0:lShowHint := .F.
	oBmp0:lReadOnly := .F.
	oBmp0:Align 	:= 0
	oBmp0:lVisibleControl := .T.
	oBmp0:lStretch 	:= .F.
	oBmp0:lAutoSize := .F.
	oBmp0:cBmpFile 	:= "faces.bmp"
	oBmp0:LTRANSPARENT := .T.
	oBmp0:LACTIVE := .F.


	For i:= 1 to 104
			if     i == 33
				nLeft := 133
				nTop  += 63
			elseif i == 53
		 		nLeft := 133
				nTop  += 59
			elseif i == 73
				nLeft := 40
				nTop  += 63
			endif
			cChave := "oBmp"+alltrim(str(i))
			cMacro := cChave+ ":= TBITMAP():Create(oDlg2)"
			&(cMacro)
			cMacro := cChave+":cName     := '" + "fac_la" + "'"
			&(cMacro)
			cMacro := cChave+":cCaption  := '" + alltrim(str(i)) + "'"
			&(cMacro)
			cMacro := cChave+":nTop      := "  + alltrim(str(nTop))
			&(cMacro)
			cMacro := cChave+":nWidth    := 6"
			&(cMacro)
			cMacro := cChave+":nHeight   := 26"
			&(cMacro)
			cMacro := cChave+":lVisibleControl := .T."
			&(cMacro)
			cMacro := cChave+":cBmpFile  := '" + "fac_la_out.bmp" + "'"
			&(cMacro)
			cMacro := cChave+":nLeft     := "  + alltrim(str(nLeft))
			&(cMacro)
			cMacro := cChave+":BlClicked := {|| PLSCliFace(" + cChave + ")}"
			&(cMacro)
			if mod(i,2) == 0
			    nLeft += 17
			else
				nLeft += 14
			endif
	next

	nLeft := 39
	nTop  := 67

	For i:= 105 to 208
			if     i == 121
				nTop  += 32
				nLeft := 39
			elseif i == 137
				nTop  += 31
				nLeft := 132
			elseif i == 147
				nTop  += 32
				nLeft := 132
			elseif i == 157
				nTop  += 27
				nLeft := 132
			elseif i == 167
				nTop  += 32
				nLeft := 132
			elseif i == 177
				nTop  += 31
				nLeft := 39
			elseif i == 193
				nTop  += 32
				nLeft := 39
			endif

			cChave := "oBmp"+alltrim(str(i))
			cMacro := cChave+ ":= TBITMAP():Create(oDlg2)"
			&(cMacro)
			cMacro := cChave+":cName     := '" + "fac_si" + "'"
			&(cMacro)
			cMacro := cChave+":cCaption  := '" + alltrim(str(i)) + "'"
		 	&(cMacro)
		 	cMacro := cChave+":nTop      := "  + alltrim(str(nTop))
			&(cMacro)
			cMacro := cChave+":nWidth    := 22"
			&(cMacro)
			cMacro := cChave+":nHeight   := 8"
			&(cMacro)
			cMacro := cChave+":lVisibleControl := .T."
			&(cMacro)
			//&(cMacro)
			cMacro := cChave+":cBmpFile  := '" + "fac_si_out.bmp" + "'"
			&(cMacro)
			cMacro := cChave+":nLeft     := "  + alltrim(str(nLeft))
			&(cMacro)
			cMacro := cChave+":BlClicked := {|| PLSCliFace("+cChave+")}"
			&(cMacro)
			nLeft += 31

	Next

	nLeft := 45
	nTop  := 73
	For i:= 209 to 260

		    if     i == 225
		  		nTop  += 63
		  		nLeft := 138
		    elseif i == 235
		  		nTop  += 59
		  		nLeft := 138
		    elseif i == 245
		    	nTop  += 63
		  		nLeft := 45
			endif

			cChave := "oBmp"+alltrim(str(i))
			cMacro := cChave+ ":= TBITMAP():Create(oDlg2)"
			&(cMacro)
			cMacro := cChave+":cName     := '" + "fac_ce" + "'"
			&(cMacro)
			cMacro := cChave+":cCaption  := '" + alltrim(str(i)) + "'"
			&(cMacro)
		 	cMacro := cChave+":nTop      := "  + alltrim(str(nTop))
			&(cMacro)
			cMacro := cChave+":nWidth    := 10"
			&(cMacro)
			cMacro := cChave+":nHeight   := 28"
			&(cMacro)
			cMacro := cChave+":lVisibleControl := .T."
			&(cMacro)
			cMacro := cChave+":cBmpFile  := '" + "fac_ce_out.bmp" + "'"
			&(cMacro)
			cMacro := cChave+":nLeft     := "  + alltrim(str(nLeft))
			&(cMacro)
			cMacro := cChave+":BlClicked := {|| PLSCliFace("+cChave+")}"
			&(cMacro)
			cMacro := cChave+":BlDbLClick := {|| PLSCliDent("+cChave+")}"
			&(cMacro)
			nLeft += 31
	Next

	nLeft := 115
	nTop  := 366
	For i:= 261 to 270
			if      i == 263
			    nTop += 40
			    nLeft := 115
			elseif  i == 265
				nTop  := 366
			    nLeft := 368
			elseif  i == 268
				nTop += 40
			    nLeft := 368
			endif

			cChave := "oBmp"+alltrim(str(i))
			cMacro := cChave+ ":= TBITMAP():Create(oDlg2)"
			&(cMacro)
			cMacro := cChave+":cName     := '" + "sa" + "'"
			&(cMacro)
			cMacro := cChave+":cCaption  := '" + alltrim(str(i)) + "'"
			&(cMacro)
		 	cMacro := cChave+":nTop      := "  + alltrim(str(nTop))
			&(cMacro)
			cMacro := cChave+":nWidth    := 20"
			&(cMacro)
			cMacro := cChave+":nHeight   := 23"
			&(cMacro)
			cMacro := cChave+":lVisibleControl := .T."
			&(cMacro)
			cMacro := cChave+":cBmpFile  := '" + "sa_out.bmp" + "'"
			&(cMacro)
			cMacro := cChave+":nLeft     := "  + alltrim(str(nLeft))
			&(cMacro)
			cMacro := cChave+":BlClicked := {|| PLSCliFace("+cChave+",9)}"
			&(cMacro)
			nLeft += 51
	Next


	nLeft := 31
	nTop  := 474
	For i:= 271 to 278

			cChave := "oBmp"+alltrim(str(i))
			cMacro := cChave+ ":= TBITMAP():Create(oDlg2)"
			&(cMacro)
			cMacro := cChave+":cName     := '" + "da" + "'"
			&(cMacro)
			cMacro := cChave+":cCaption  := '" + alltrim(str(i)) + "'"
			&(cMacro)
		 	cMacro := cChave+":nTop      := "  + alltrim(str(nTop))
			&(cMacro)
			cMacro := cChave+":nWidth    := 9"
			&(cMacro)
			cMacro := cChave+":nHeight   := 9"
			&(cMacro)
			cMacro := cChave+":lVisibleControl := .T."
			&(cMacro)
			cMacro := cChave+":cBmpFile  := '" + "da_out.bmp" + "'"
			&(cMacro)
			cMacro := cChave+":nLeft     := "  + alltrim(str(nLeft))
			&(cMacro)
			cMacro := cChave+":BlClicked := {|| PLSCliFace("+cChave+",9)}"
			&(cMacro)
			nTop += 19

	Next

	ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT EnchoiceBar(oDlg2,bOk,bCancel)

Endif

return {.T.,aFaces}
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSCliFace³ Autor ³ Daher		            ³ Data ³ 13.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Regras de duplo clique         							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSCliFace(oObj,nSize)
LOCAL cImage := oObj:cBmpFile
LOCAL cName  := ""
Default nSize  := 10
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Muda a face									                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if len(cImage) > nSize
	cName 		  := oObj:cName  +".bmp"
	oObj:cBmpFile := cName
	oObj:lModified    := .T.
else
	cName 		  := oObj:cName + "_out.bmp"
	oObj:cBmpFile := cName
	oObj:lModified    := .F.
endif


return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSCliDent³ Autor ³ Otacilio A. Junior    ³ Data ³ 11.11.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Regras de duplo clique         							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSCliDent(oObj,nSize)
LOCAL aImage  := {" ","fac_la","fac_la","fac_si","fac_si"}
LOCAL cName   := ""
LOCAL cChave  := ""
LOCAL cMacro  := ""
LOCAL cNBmpIn := ""
LOCAL cNBmpOut:= ""
LOCAL aAux    := {}
LOCAL Ix
Default nSize:= 10
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Muda a face									                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aAux,{18,1,2,105,121,209})
	aadd(aAux,{17,3,4,106,122,210})
	aadd(aAux,{16,5,6,107,123,211})
	aadd(aAux,{15,7,8,108,124,212})
	aadd(aAux,{14,9,10,109,125,213})
	aadd(aAux,{13,11,12,110,126,214})
	aadd(aAux,{12,13,14,111,127,215})
	aadd(aAux,{11,15,16,112,128,216})
	aadd(aAux,{21,17,18,113,129,217})
	aadd(aAux,{22,19,20,114,130,218})
	aadd(aAux,{23,21,22,115,131,219})
	aadd(aAux,{24,23,24,116,132,220})
	aadd(aAux,{25,25,26,117,133,221})
	aadd(aAux,{26,27,28,118,134,222})
	aadd(aAux,{27,29,30,119,135,223})
	aadd(aAux,{28,31,32,120,136,224})
	aadd(aAux,{55,33,34,137,147,225})
	aadd(aAux,{54,35,36,138,148,226})
	aadd(aAux,{53,37,38,139,149,227})
	aadd(aAux,{52,39,40,140,150,228})
	aadd(aAux,{51,41,42,141,151,229})
	aadd(aAux,{61,43,44,142,152,230})
	aadd(aAux,{62,45,46,143,153,231})
	aadd(aAux,{63,47,48,144,154,232})
	aadd(aAux,{64,49,50,145,155,233})
	aadd(aAux,{65,51,52,146,156,234})
	aadd(aAux,{85,53,54,157,167,235})
	aadd(aAux,{84,55,56,158,168,236})
	aadd(aAux,{83,57,58,159,169,237})
	aadd(aAux,{82,59,60,160,170,238})
	aadd(aAux,{81,61,62,161,171,239})
	aadd(aAux,{71,63,64,162,172,240})
	aadd(aAux,{72,65,66,163,173,241})
	aadd(aAux,{73,67,68,164,174,242})
	aadd(aAux,{74,69,70,165,175,243})
	aadd(aAux,{75,71,72,166,176,244})
	aadd(aAux,{48,73,74,177,193,245})
	aadd(aAux,{47,75,76,178,194,246})
	aadd(aAux,{46,77,78,179,195,247})
	aadd(aAux,{45,79,80,180,196,248})
	aadd(aAux,{44,81,82,181,197,249})
	aadd(aAux,{43,83,84,182,198,250})
	aadd(aAux,{42,85,86,183,199,251})
	aadd(aAux,{41,87,88,184,200,252})
	aadd(aAux,{31,89,90,185,201,253})
	aadd(aAux,{32,91,92,186,202,254})
	aadd(aAux,{33,93,94,187,203,255})
	aadd(aAux,{34,95,96,188,204,256})
	aadd(aAux,{35,97,98,189,205,257})
	aadd(aAux,{36,99,100,190,206,258})
	aadd(aAux,{37,101,102,191,207,259})
	aadd(aAux,{38,103,104,192,208,260})
    nPos:= Ascan(aAux,{|x| Alltrim(Str(x[6])) == oObj:cCaption})

	cChave := "oBmp"+alltrim(str(aAux[nPos,6]))
	cMacro := cChave+":cBmpFile"
	cNBmpIn:= &(cMacro)

For Ix:= 2 to 6
	 		cChave := "oBmp"+alltrim(str(aAux[nPos,Ix]))
			cMacro := cChave+":cBmpFile"
			cNBmpOut:= &(cMacro)
		If Len(cNBmpOut) > nSize
		    If  Len(cNBmpIn) <> Len(cNBmpOut)
				cName 		  := aImage[Ix]  +".bmp"
				cChave := "oBmp"+alltrim(str(aAux[nPos,Ix]))
				cMacro := cChave+":cBmpFile  := '" + cName + "'"
				&(cMacro)
				cMacro := cChave+":lModified:= .T."
				&(cMacro)
			EndIf
		else
		    If  Len(cNBmpIn) <> Len(cNBmpOut)
				cName 		  := aImage[Ix] + "_out.bmp"
				cChave := "oBmp"+alltrim(str(aAux[nPos,Ix]))
				cMacro := cChave+":cBmpFile  := '" + cName + "'"
				&(cMacro)
				cMacro := cChave+":lModified:= .F."
				&(cMacro)
			EndIf
        EndIf
Next
return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLA090VRDo| Autor ³ Daher		            ³ Data ³ 13.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao de campo	         							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLA090VRDo()
LOCAL cInvCla	 := ""

lRet := PLSA090RDA(M->B01_OPERDA,M->B01_CODRDA,"1",M->B01_DATPRO,M->B01_USUARI,;
                   "","","B01",,,,,,__ctipo,oBrwPro,oBrwCri)

if ExistBlock("PL090oFL2")
	cInvCla := ExecBlock("PL090oFL2",.F.,.F.)
endif

if lRet
	if BAU->BAU_TIPPRE $ cInvCla
	    MsgInfo(STR0022) //"Classe de rede de atendimento invalida, selecione um valido."
	    lRet := .F.
	else
		M->B01_TIPPRE := BAU->BAU_TIPPRE
	endif
endif

return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLA090VR2o| Autor ³ Daher		            ³ Data ³ 13.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao de campo	         							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLA090VR2o()
LOCAL lRet    := .T.
LOCAL cCodRda

If M->B01_OPERDA == PLSINTPAD()
   Return(lRet)
Endif

BA0->(DbSetOrder(1))
If ! BA0->(MsSeek(xFilial("BA0")+M->B01_OPERDA))
   Help("",1,"REGNOIS")
   lRet := .F.
Endif

If lRet
   cCodRda       := BA0->BA0_CODRDA
   M->B01_CODRDA := cCodRda

   If ( M->B01_OPERDA <> PLSINTPAD() ) .And. ( ! Empty(cCodRda) )
      lRet := PLSA090RDA(M->B01_OPERDA,M->B01_CODRDA,"1",M->B01_DATPRO,;
                         M->B01_USUARI,M->B01_CODLOC,M->B01_CODESP,"B01",,,,,,__ctipo,oBrwPro,oBrwCri)

      If lRet
         M->B01_TIPPRE := BAU->BAU_TIPPRE
         lRefresh := .T.
         oEncAut:Refresh()
      Else
         M->B01_CODRDA := ""
      Endif
   Endif
Endif

M->B01_OPERDA := PLSINTPAD()

Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PlAliFac  | Autor ³ Daher		            ³ Data ³ 13.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Alimenta variavel de faces alteradas						  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static function PlAliFac()
LOCAL aAux   := {}
LOCAL lChave := .F.
LOCAL cChave := ""
LOCAL nChave := 1
LOCAL j      := 1
LOCAL i      := 1
LOCAL nPos   := 0
LOCAL nPos2  := 0
LOCAL nPos3  := 0
LOCAL aFaces := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Matriz objetos por faces									        ³
//|   3                                                                 |
//|	1 5 2                                                               |
//|   4                                                                 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	//faces		   1,2,3,4,5
	aadd(aAux,{18,{1,2,105,121,209}})
	aadd(aAux,{17,{3,4,106,122,210}})
	aadd(aAux,{16,{5,6,107,123,211}})
	aadd(aAux,{15,{7,8,108,124,212}})
	aadd(aAux,{14,{9,10,109,125,213}})
	aadd(aAux,{13,{11,12,110,126,214}})
	aadd(aAux,{12,{13,14,111,127,215}})
	aadd(aAux,{11,{15,16,112,128,216}})
	aadd(aAux,{21,{17,18,113,129,217}})
	aadd(aAux,{22,{19,20,114,130,218}})
	aadd(aAux,{23,{21,22,115,131,219}})
	aadd(aAux,{24,{23,24,116,132,220}})
	aadd(aAux,{25,{25,26,117,133,221}})
	aadd(aAux,{26,{27,28,118,134,222}})
	aadd(aAux,{27,{29,30,119,135,223}})
	aadd(aAux,{28,{31,32,120,136,224}})
	aadd(aAux,{55,{33,34,137,147,225}})
	aadd(aAux,{54,{35,36,138,148,226}})
	aadd(aAux,{53,{37,38,139,149,227}})
	aadd(aAux,{52,{39,40,140,150,228}})
	aadd(aAux,{51,{41,42,141,151,229}})
	aadd(aAux,{61,{43,44,142,152,230}})
	aadd(aAux,{62,{45,46,143,153,231}})
	aadd(aAux,{63,{47,48,144,154,232}})
	aadd(aAux,{64,{49,50,145,155,233}})
	aadd(aAux,{65,{51,52,146,156,234}})
	aadd(aAux,{85,{53,54,157,167,235}})
	aadd(aAux,{84,{55,56,158,168,236}})
	aadd(aAux,{83,{57,58,159,169,237}})
	aadd(aAux,{82,{59,60,160,170,238}})
	aadd(aAux,{81,{61,62,161,171,239}})
	aadd(aAux,{71,{63,64,162,172,240}})
	aadd(aAux,{72,{65,66,163,173,241}})
	aadd(aAux,{73,{67,68,164,174,242}})
	aadd(aAux,{74,{69,70,165,175,243}})
	aadd(aAux,{75,{71,72,166,176,244}})
	aadd(aAux,{48,{73,74,177,193,245}})
	aadd(aAux,{47,{75,76,178,194,246}})
	aadd(aAux,{46,{77,78,179,195,247}})
	aadd(aAux,{45,{79,80,180,196,248}})
	aadd(aAux,{44,{81,82,181,197,249}})
	aadd(aAux,{43,{83,84,182,198,250}})
	aadd(aAux,{42,{85,86,183,199,251}})
	aadd(aAux,{41,{87,88,184,200,252}})
	aadd(aAux,{31,{89,90,185,201,253}})
	aadd(aAux,{32,{91,92,186,202,254}})
	aadd(aAux,{33,{93,94,187,203,255}})
	aadd(aAux,{34,{95,96,188,204,256}})
	aadd(aAux,{35,{97,98,189,205,257}})
	aadd(aAux,{36,{99,100,190,206,258}})
	aadd(aAux,{37,{101,102,191,207,259}})
	aadd(aAux,{38,{103,104,192,208,260}})
	aadd(aAux,{07,{261}})
	aadd(aAux,{08,{262}})
	aadd(aAux,{10,{263}})
	aadd(aAux,{09,{264}})
	aadd(aAux,{01,{265}})
	aadd(aAux,{02,{266}})
	aadd(aAux,{03,{267}})
	aadd(aAux,{06,{268}})
	aadd(aAux,{05,{269}})
	aadd(aAux,{04,{270}})
	aadd(aAux,{90,{271}})
	aadd(aAux,{91,{272}})
	aadd(aAux,{93,{273}})
	aadd(aAux,{94,{274}})
	aadd(aAux,{95,{275}})
	aadd(aAux,{96,{276}})
	aadd(aAux,{97,{277}})
	aadd(aAux,{99,{278}})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Matriz objetos por faces									        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
for i:=1 to 278
	cChave := "oBmp"+alltrim(str(i))+":lModified"
	if TYPE(cChave) <> "U"
		lChave := &(cChave)
	else
		lChave := .F.
	endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se o objeto foi alterado											|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if lChave
		cChave := "oBmp"+alltrim(str(i))+":cCaption"
		nChave := val(&(cChave))
		j      := 1
		nPos   := 0
		nPos2  := 0
		nPos3  := 0
		nPos   := aScan(aAux,{|x| (nPos2 := aScan(x[2],{|p| nChave == p})) > 0 })
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Teoricamente esse npos sempre eh maior q zero						|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if nPos > 0 .and. nPos2 > 0
			 if (nPos3 := aScan(aFaces,{|x| x[1] == aAux[nPos][1]})) > 0
				aadd(aFaces[nPos3][2],nPos2)
			 else
			 	aadd(aFaces,{aAux[nPos][1],{nPos2}} )
			 endif
		endif

	endif
next

return aFaces
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS090Vldo ³ Autor ³ Daher		        	³ Data ³ 14.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que confirma uma autorizacao retornando o seu numero³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLA090Vldo(aRetorno,aGets,aTela,oBrwPro,oEncAut,nOpc,cTipo,oBrwCri,cNaoUsado,oBrwEven,aMatCom)
LOCAL lforbloq 	:= .F.
LOCAL lgersenha 	:= .F.
LOCAL lumvld 		:= .F.
LOCAL lstalib 	:= .T.
LOCAL lNMudFase 	:= GETNEWPAR("MV_PLMFSA","1")=="0"
LOCAL nsaldo 		:= 0
LOCAL nfor 		:= 0
LOCAL npos 		:= 0
LOCAL npospro 	:= 0
LOCAL nvlrcom 	:= 0
LOCAL ni 			:= 0
LOCAL aDadUsr 	:= plsgetusr()
LOCAL aDadRda 	:= plsgetrda()
LOCAL aDadbea 	:= {}
LOCAL aChaveGen 	:= {}
LOCAL aDados 		:= {}
LOCAL aCabec 		:= {{"Codigo","@!!.!!!!!!!!",60},{STR0058,"@!",150},{"Raio x","@!",30}}
LOCAL cStaLib 	:= "2"
LOCAL cStaLibG 	:= "2"
LOCAL cTitulo 	:= STR0023
LOCAL cExcAtend 	:= GETNEWPAR("MV_PLEXATE","0")
Local nOpc2		:= 0
Local nQtdPrc		:= 0
Local nQtdCri		:= 0
Local aColBEG		:= {}
Local aHeaBEG		:= {}
Local aVtaBEG		:= {}
Local nPr			:= 0
Local nCr			:= 0
Local lPacInt		:=.F.
Local aRetInt		:= {}
Local cNrAutWeb     := ""
Local cStAutWeb     := ""
Local cTpAutWeb     := ""

DEFAULT cNaoUsado	:= ""
DEFAULT aMatCom 		:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Exclusão Guia comprada onde o Título sofre movimentação           				   	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Excluir .And. cExcAtend == "1"
	If BEA->( FieldPos("BEA_NUMTIT") ) > 0
		cChaveSE1 := Iif(!Empty(BEA->BEA_PREFIX+BEA->BEA_NUMTIT+BEA->BEA_PARCEL+BEA->BEA_TIPTIT),;
		                 BEA->BEA_PREFIX+BEA->BEA_NUMTIT+BEA->BEA_PARCEL+BEA->BEA_TIPTIT,;
		                 BEA->BEA_CHVSE1)
	Else
		cChaveSE1 := BEA->BEA_CHVSE1
	EndIf
	SE1->(DbSetOrder(1))
	If !Empty(cChaveSE1) .and. SE1->(MsSeek(xFilial("SE1")+cChaveSE1))

		//Executa funcao que analisa a possibilidade de exclusao de uma guia que teve movimentacao financeiro relacionada..
		aRetASE1 := PLSA090AE1(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA)

		//[1] - Calendario contabil (.T./.F.)
		//[2] - Movimentado (.T./.F.)
		
		if aRetASE1[1] .and. aRetASE1[2]
		
			Aviso(	STR0024,;		//"Atencao" //"Atenção"
					STR0075,;		//"Título Movimentado Não é possível excluir Atendimento!"
					{ STR0090 }, 2 )//"ok"
					
			Return(.F.)

		EndIf

	EndIf

EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi informado algum procedimento												   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len(oBrwPro:aCols)
	If !oBrwPro:aCols[nI,Len(oBrwPro:aHeader)+1]
		lUmVld := .T.
		Exit
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe msg se nao for informado																   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lUmVld
	Aviso(	STR0024,; 				//"Atencao" //"Atenção"
	STR0025,; 				//"Nenhum procedimento informado!" //"Nenhum procedimento informado!"
	{ STR0090 }, 2 ) 		//"ok"
	Return(.F.)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso que pode acontecer da guia com ano e mes em branco...               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(M->B01_ANOPAG) .Or. Empty(M->B01_MESPAG)
   MsgStop(STR0026) //"Ano ou Mes de pagamento em branco. Esta guia nao pode ser gravada."
   Return(.F.)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi informado pelo menos um item...                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! oBrwPro:TudoOK() .Or. ! Obrigatorio(oEncAut:aGets,oEncAut:aTela)
   Return(.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida a guia juridica				                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("M->B01_GUIJUR") == "C" .and. Type("M->B01_NUMPRO") == "C" .AND. nOpc <> K_Excluir
	If M->B01_GUIJUR == "1" .and. Empty(M->B01_NUMPRO)
		If PlsGetJur()[1]
			Help("",1,"PLSGUIJUR")
			Return(.F.)
		Endif
    Endif
Endif

aRetInt:=PLSA090USR(M->B01_USUARI,M->B01_DATPRO,M->B01_HORPRO,"B01",.F.,.T.)
lPacInt:=aRetInt[6]
If lPacInt
	If Type("M->B01_GUIPRI") == "C" .AND. nOpc <> K_Excluir
		If  Empty(M->B01_GUIPRI) 
			Aviso(STR0024 ,"Este Paciente Encontra -se  Bloqueado ,Necessario informar a Guia Principal da Internação ", { STR0090 }, 2 ) //"Este Paciente Encontra -se  Bloqueado" #"Necessario informar a Guia Principal da Internação "
			Return(.F.)	
		Endif
	Endif		
Endif		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata uma autorizacao que veio de uma liberacao...                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOpc == K_Incluir .Or. nOpc == K_Copiar) .And. ! Empty(M->B01_NUMLIB)
    BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
    If ! BEA->(MsSeek(xFilial("BEA")+M->B01_NUMLIB))
       	Help("",1,"PLNUMLIB")
      	Return(.F.)
    EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajusta Itens da guia BE2												 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    For nFor:=1 To Len(oBrwPro:aVetTrab)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no Registro													 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BE2->( DbGoTo(oBrwPro:aVetTrab[nFor]) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procura registro com saldo												 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosSeq := oBrwPro:FieldPos("BE2_SEQUEN")
		nPosPad := oBrwPro:FieldPos("BE2_CODPAD")
		nPosPro := oBrwPro:FieldPos("BE2_CODPRO")
		nPosDen := oBrwPro:FieldPos("BE2_DENREG")
		nPosFad := oBrwPro:FieldPos("BE2_FADENT")

		If ( nPos := Ascan( oBrwPro:aCols,{|x| x[nPosSeq]+x[nPosPad]+x[nPosPro]+x[nPosDen]+x[nPosFad] == BE2->(BE2_SEQUEN+BE2_CODPAD+BE2_CODPRO+BE2_DENREG+BE2_FADENT) } ) ) > 0 .And. !oBrwPro:aCols[nPos,Len(oBrwPro:aCols[nPos])]

	        If oBrwPro:FieldGet("BE2_QTDPRO",nPos) == BE2->BE2_SALDO

			    If oBrwPro:FieldGet("BE2_STATUS",nPos) == '1'
			    	nSaldo := BE2->BE2_SALDO-oBrwPro:FieldGet("BE2_QTDPRO",nPos)
			    Else
			    	nSaldo  := BE2->BE2_SALDO
			    Endif

			    cStaLib := Iif(nSaldo==0,"2","1")

			    If cStaLib == '1'
				    cStaLibG := cStaLib
			    EndIf
			Else
			    	nSaldo  := BE2->BE2_SALDO

			    	cStaLib := Iif(nSaldo==0,"2","1")

			    If cStaLib == '1'
				    cStaLibG := cStaLib
			    EndIf

			EndIf

			//PLSATUSS( BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)+BE2->(BE2_SEQUEN+BE2_CODPAD+BE2_CODPRO),,,nSaldo,cStaLib,.F.,BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) )
		Else
			lStaLib := .F.
        EndIf
    Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajusta cabecalho da guia BEA											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lStaLib
		PLSATUCS(cStaLibG)
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ << BEA BEA BEA BEA >> Monta dados do CABECALHO...                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados sempre atualizados (Inclusao/Alteracao)...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Incluir .Or. nOpc == K_Alterar .Or. nOpc == K_Copiar
   aadd(aDadBEA,{"BEA_ORIMOV","1"})
   aadd(aDadBEA,{"BEA_TIPO"  ,"4"})
   aadd(aDadBEA,{"BEA_OPERDA",M->B01_OPERDA})
   aadd(aDadBEA,{"BEA_DATPRO",M->B01_DATPRO})
   aadd(aDadBEA,{"BEA_HORPRO",M->B01_HORPRO})
   aadd(aDadBEA,{"BEA_CDPFSO",M->B01_CDPFSO})
   aadd(aDadBEA,{"BEA_ANOPAG",M->B01_ANOPAG})
   aadd(aDadBEA,{"BEA_MESPAG",M->B01_MESPAG})
   aadd(aDadBEA,{"BEA_NUMIMP",M->B01_NUMIMP})
   aadd(aDadBEA,{"BEA_MATANT",M->B01_MATANT})
   aadd(aDadBEA,{"BEA_MATUSA",M->B01_MATUSA})
   aadd(aDadBEA,{"BEA_MSG01",M->B01_MSG01})
   aadd(aDadBEA,{"BEA_MSG02",M->B01_MSG02})
   aadd(aDadBEA,{"BEA_MSG03",M->B01_MSG03})

   If !Empty(M->B01_NUMLIB)
      aadd(aDadBEA,{"BEA_NRLBOR",M->B01_NUMLIB})
   Endif

   If BEA->(FieldPos("BEA_TIPPRE")) > 0
      aadd(aDadBEA,{"BEA_TIPPRE",M->B01_TIPPRE})
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Se for um usuario da operadora padrao sendo atendido em outra operadora  |
   //| OU se o parametro que define que                                         |
   //| sempre sera gerado uma senha na autorizacao/liberacao estiver ligado     |
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If ( ( BAU->bau_tippre==getnewpar("mv_plstpin","OPE") ) .or. (getnewpar("mv_plsgsal","0")=="1")) .or. (getnewpar("mv_plstiss","1")=="1" .and. __ctipo=="2")
	  lGerSenha := .T.
   Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Somente na inclusao...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Incluir .Or. nOpc == K_Copiar
   aadd(aDadBEA,{"BEA_HHDIGI",StrTran(Time(),":","")})
   aadd(aDadBEA,{"BEA_DTDIGI",Date()})
   aadd(aDadBEA,{"BEA_USUOPE",PLSRtCdUsr()})
   aadd(aDadBEA,{"BEA_DESOPE",PLRETOPE()})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rede de Atendimento...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nOpc == K_Incluir ) .Or. ( nOpc == K_Alterar) .Or. (nOpc == K_Copiar)
	aadd(aDadBEA,{"BEA_CODRDA",M->B01_CODRDA})
	aadd(aDadBEA,{"BEA_NOMRDA",M->B01_NOMRDA})
	aadd(aDadBEA,{"BEA_SIGLA ",M->B01_SIGLA})
	aadd(aDadBEA,{"BEA_ESTSOL",M->B01_ESTSOL})
	aadd(aDadBEA,{"BEA_REGSOL",M->B01_REGSOL})
	aadd(aDadBEA,{"BEA_NOMSOL",M->B01_NOMSOL})
	aadd(aDadBEA,{"BEA_ESTEXE",M->B01_ESTEXE})
	aadd(aDadBEA,{"BEA_REGEXE",M->B01_REGEXE})
	aadd(aDadBEA,{"BEA_NOMEXE",M->B01_NOMEXE})
	aadd(aDadBEA,{"BEA_SIGEXE",M->B01_SIGEXE})
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ LOCAL de Atendimento...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nOpc == K_Incluir ) .Or. ( nOpc == K_Alterar)  .Or. (nOpc == K_Copiar)
   aadd(aDadBEA,{"BEA_CODLOC",Subs(M->B01_CODLOC,1,3)})
   aadd(aDadBEA,{"BEA_LOCAL ",Subs(M->B01_CODLOC,1,3)})
   aadd(aDadBEA,{"BEA_DESLOC",M->B01_DESLOC})
   aadd(aDadBEA,{"BEA_ENDLOC",M->B01_ENDLOC})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Especialidade...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nOpc == K_Incluir ) .Or. ( nOpc == K_Alterar)  .Or. (nOpc == K_Copiar)
   aadd(aDadBEA,{"BEA_CODESP",M->B01_CODESP})
   aadd(aDadBEA,{"BEA_DESESP",M->B01_DESESP})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Usuario...                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nOpc == K_Incluir ) .Or. ( nOpc == K_Alterar) .Or. (nOpc == K_Copiar)
   M->B01_VALOR := 0
   For nFor := 1 To Len(oBrwPro:aCols)
		If !oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1]
			nVlrCom += oBrwPro:FieldGet("BE2_VLCOMP",nFor)
		Endif
   Next
   M->B01_VALOR := nVlrCom
   aadd(aDadBEA,{"BEA_OPEUSR",Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])})
   aadd(aDadBEA,{"BEA_CODEMP",Subs(aDadUsr[2],atCodEmp[1],atCodEmp[2])})
   aadd(aDadBEA,{"BEA_MATRIC",Subs(aDadUsr[2],atMatric[1],atMatric[2])})
   aadd(aDadBEA,{"BEA_TIPREG",Subs(aDadUsr[2],atTipReg[1],atTipReg[2])})
   aadd(aDadBEA,{"BEA_MATVID",aDadUsr[5]})
   aadd(aDadBEA,{"BEA_NOMUSR",M->B01_NOMUSR})
   aadd(aDadBEA,{"BEA_NOMTIT",aDadUsr[40]})
   aadd(aDadBEA,{"BEA_CONEMP",aDadUsr[9]})
   aadd(aDadBEA,{"BEA_VERCON",aDadUsr[39]})
   aadd(aDadBEA,{"BEA_SUBCON",aDadUsr[41]})
   aadd(aDadBEA,{"BEA_VERSUB",aDadUsr[42]})
   aadd(aDadBEA,{"BEA_CPFUSR",BA1->BA1_CPFUSR})
   aadd(aDadBEA,{"BEA_IDUSR ",BA1->BA1_DRGUSR})
   aadd(aDadBEA,{"BEA_DATNAS",aDadUsr[26]})
   aadd(aDadBEA,{"BEA_DIGITO",Subs(aDadUsr[2],atDigito[1],atDigito[2])})

   aadd(aDadBEA,{"BEA_GUIACO",M->B01_GUIACO})

   If BEA->(FieldPos("BEA_TIPPRE")) > 0
      aadd(aDadBEA,{"BEA_TIPPRE",M->B01_TIPPRE})
   Endif

   aadd(aDadBEA,{"BEA_QUACOB",M->B01_QUACOB})
   If Type("M->B01_PAGATO") == "C"
      aadd(aDadBEA,{"BEA_PAGATO",M->B01_PAGATO})
   Endif
   aadd(aDadBEA,{"BEA_CODCLI",M->B01_CODCLI})
   aadd(aDadBEA,{"BEA_LOJA  ",M->B01_LOJA  })
   aadd(aDadBEA,{"BEA_VALOR ",M->B01_VALOR })

   If Type("M->B01_GUIJUR") == "C"
      aadd(aDadBEA,{"BEA_GUIJUR",M->B01_GUIJUR})
   Endif

   If Type("M->B01_NUMPRO") == "C"
      aadd(aDadBEA,{"BEA_NUMPRO",M->B01_NUMPRO})
   Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                                                                          ³
//³ << BE2 BE2 BE2 BE2 >> Monta dados dos ITENS PROCEDIMENTOS...             ³
//³                                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados sempre atualizados (Inclusao/Alteracao)...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Incluir .Or. nOpc == K_Alterar .Or. nOpc == K_Copiar
   aadd(aChaveGen,{"BE2_DATPRO",M->B01_DATPRO})
   aadd(aChaveGen,{"BE2_HORPRO",M->B01_HORPRO})
   aadd(aChaveGen,{"BE2_TPGRV" ,"1"})
   aadd(aChaveGen,{"BE2_CDPFSO",M->B01_CDPFSO})
   aadd(aChaveGen,{"BE2_CDPFSO",M->B01_CDPFSO})
   aadd(aChaveGen,{"BE2_TIPRDA",BAU->BAU_TIPPE})
   aadd(aChaveGen,{"BE2_IDUSR",BA1->BA1_DRGUSR})
   aadd(aChaveGen,{"BE2_ENDLOC",M->B01_ENDLOC})
   aadd(aChaveGen,{"BE2_DESLOC",M->B01_DESLOC})
   aadd(aChaveGen,{"BE2_DATNAS",aDadUsr[26]})
   aadd(aChaveGen,{"BE2_CPFRDA",BAU->BAU_CPFCGC})
   aadd(aChaveGen,{"BE2_NUMIMP",M->B01_NUMIMP})
   If BE2->(FieldPos("BE2_NRAOPE")) > 0
      aadd(aChaveGen,{"BE2_NRAOPE",M->B01_NRAOPE})
   Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Usuario...                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nOpc == K_Incluir ) .Or. ( nOpc == K_Alterar)  .Or. (nOpc == K_Copiar)
   aadd(aChaveGen,{"BE2_OPEUSR",Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])})
   aadd(aChaveGen,{"BE2_CODEMP",Subs(aDadUsr[2],atCodEmp[1],atCodEmp[2])})
   aadd(aChaveGen,{"BE2_MATRIC",Subs(aDadUsr[2],atMatric[1],atMatric[2])})
   aadd(aChaveGen,{"BE2_TIPREG",Subs(aDadUsr[2],atTipReg[1],atTipReg[2])})
   aadd(aChaveGen,{"BE2_CONEMP",aDadUsr[9]})
   aadd(aChaveGen,{"BE2_VERCON",aDadUsr[39]})
   aadd(aChaveGen,{"BE2_SUBCON",aDadUsr[41]})
   aadd(aChaveGen,{"BE2_VERSUB",aDadUsr[42]})
   aadd(aChaveGen,{"BE2_MATVID",aDadUsr[5]})
   aadd(aChaveGen,{"BE2_DIGITO",Subs(aDadUsr[2],atDigito[1],atDigito[2])})
   aadd(aChaveGen,{"BE2_MATANT",M->B01_MATANT})
   aadd(aChaveGen,{"BE2_GUIACO",M->B01_GUIACO})
   aadd(aChaveGen,{"BE2_QUACOB",M->B01_QUACOB})
   aadd(aChaveGen,{"BE2_CID",M->B01_CID})
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rede de Atendimento...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nOpc == K_Incluir ) .Or. ( nOpc == K_Alterar)  .Or. (nOpc == K_Copiar)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Procedimentos...                                                         ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aadd(aChaveGen,{"BE2_PRFATD",aDadRDA[5]})
   aadd(aChaveGen,{"BE2_OPERDA",M->B01_OPERDA})
   aadd(aChaveGen,{"BE2_CODRDA",M->B01_CODRDA})
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ LOCAL de Atendimento...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nOpc == K_Incluir ) .Or. ( nOpc == K_Alterar)  .Or. (nOpc == K_Copiar)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Procedimentos...                                                         ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aadd(aChaveGen,{"BE2_CODLOC",Subs(M->B01_CODLOC,1,3)})
   aadd(aChaveGen,{"BE2_LOCAL ",Subs(M->B01_CODLOC,4,3)})
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Especialidade...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nOpc == K_Incluir ) .Or. ( nOpc == K_Alterar)  .Or. (nOpc == K_Copiar)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Procedimentos...                                                         ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aadd(aChaveGen,{"BE2_CODESP",M->B01_CODESP})
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento de RaioX, por exemplo, as guias que contem procedimentos que  ³
//| necessitam de raioX devem ser geradas bloqueadas ate que o prestador enca|
//| minhe o raio x para desbloqueio											 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BR8->(DbSetOrder(1))
If PLRETPOS("BE2_CODPAD",oBrwPro:aHeader) > 0 .and. PLRETPOS("BE2_CODPRO",oBrwPro:aHeader) > 0
	For nFor:= 1 to Len(oBrwPro:aCols)
		If BR8->(Msseek(xFilial("BR8")+oBrwPro:aCols[nFor][PLRETPOS("BE2_CODPAD",oBrwPro:aHeader)]+oBrwPro:aCols[nFor][PLRETPOS("BE2_CODPRO",oBrwPro:aHeader)]))
			If BR8->(FieldPos("BR8_TIPRAX")) > 0 .and. !Empty(BR8->BR8_TIPRAX) .and. ;
			    oBrwPro:aCols[nFor][1] == "ENABLE" .and. BR8->BR8_TIPRAX <> '0'
				lForBloq := .T.
				aadd(aDados,{oBrwPro:aCols[nFor][PLRETPOS("BE2_CODPAD",oBrwPro:aHeader)]+"-"+oBrwPro:aCols[nFor][PLRETPOS("BE2_CODPRO",oBrwPro:aHeader)],BR8->BR8_DESCRI,alltrim(X3Combo("BR8_TIPRAX",BR8->BR8_TIPRAX))})
			Endif
		Endif
	Next
Endif
If lForBloq .and. (nOpc == K_Incluir .Or. nOpc == K_Copiar)
   PLSCRIGEN(aDados,aCabec,cTitulo)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa rotina generica de gravacao...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Copiar
	nOpc2 := nOpc
	nOpc := K_Incluir
Endif

If FindFunction("PLSA790C") .And. PLSALIASEXI("B53")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o procedimento tem crítica, mas não é de auditoria
//	as criticas que são enviadas para a tabela de críticas da auditoria 
//	são retiradas.                   												³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nQtdPrc := Len(oBrwPro:aCols)
	nQtdCri := LEN(oBrwCri:aCols)
	
	for nPr := 1 To nqtdPrc
//		If oBrwPro:aCols[nPr][GdFieldPos("BE2_AUDITO",oBrwPro:aHeader)] != "0" -  esse item foi retirado pois mesmo sem enviar para auditoria temos que gravar a critica      
			
			For nCr:= 1 To nQtdCri
				If oBrwCri:aCols[nCr][GdFieldPos("BEG_SEQUEN",oBrwCri:aHeader)] == oBrwPro:aCols[nPr][GdFieldPos("BE2_SEQUEN",oBrwPro:aHeader)]
					
					aadd(aColBEG,oBrwCri:aCols[nCr])
				EndIf
			Next
//		EndIf
	Next
Else
	
	aColBEG := aClone(oBrwCri:aCols)
EndIf

aHeaBEG := aClone(oBrwCri:aHeader)
aVtaBEG := aClone(oBrwCri:aVetTrab)

aRetorno := PLSA090Grv(oBrwPro:aCols,oBrwPro:aHeader,aDadBEA,nOpc,oBrwPro:aVetTrab,aChaveGen,;
                       M->B01_USUARI,M->B01_DATPRO,M->B01_HORPRO,M->B01_MATUSA,M->B01_ANOPAG,M->B01_MESPAG,;
                       "13",;
                       nil,aColBEG,aHeaBEG,aVtaBEG,nil,__ctipo,If(nOpc == K_Incluir .Or. nOpc == K_Copiar,"",BEA->BEA_CODLDP),nil,nil,;
                       "B01",lForBloq,NIL,lnmudfase,NIL,NIL,NIL,NIL,NIL,lGerSenha,nil,nil,nil,nil,oBrwEven,,,,,,,,,,,oBrwEven:aCols,oBrwEven:aHeader,oBrwEven:aVetTrab,,,,aMatCom,;
                       /*lResInt*/,/*cAliasCmp*/,/*lOdontoWeb*/,M->B01_NRLBOR,/*cArqImp*/,/*lEvoSadt*/,/*cSituac*/,/*lProtoc*/,/*aPartic*/,/*aColsB4B*/,/*aHeaderB4B*/,/*aVetB4B*/,;
                       IIf(UPPER( Alltrim( FunName() ) ) $ "PLSA094C,PLSA094D"  .and. !Empty("M->B01_NUMLIB"),M->B01_NUMLIB,M->B01_NUMLIB))

nOpc := nOpc2


// Vinculo do protocolo da Solicitação de Autorização gerado pelo beneficiario via Portal
If !Empty(cNrProWeb) 		
	cNrAutWeb := aRetorno[2]
	cNrAutWeb += aRetorno[3]
	cNrAutWeb += aRetorno[4]
    cNrAutWeb += aRetorno[5]
    cStAutWeb := aRetorno[10]
    cTpAutWeb := "O" 
    If !Empty(cNrAutWeb) .And. !Empty(cNrProWeb)
    	GrvVincAut(cNrAutWeb,cNrProWeb,cStAutWeb,cTpAutWeb,"")
    EndIf			
EndIf



if existblock("pls090ar")
    execblock("pls090ar", .f. , .f. ,{nopc, .t. })
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLA090SEQo³ Autor ³ Tulio Cesar           ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria Sequencia											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLA090SEQo()
LOCAL cRet

If ValType(oBrwEven) == "O"
   If oBrwEven:aCols[Len(oBrwEven:aCols),Len(oBrwEven:aHeader)+1]
	   cRet := Soma1(oBrwEven:FieldGet("B02_SEQUEN"))
   Else
	   cRet := PLSINCRE("B02_SEQUEN",oBrwEven)
   EndIf
Else
   cRet := PLSINCRE("B02_SEQUEN")
Endif

Return(cRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLS090MDao³ Autor ³ Daher			        ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta dados de uma autorizacao (itens)                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS090MDao(cChave,cTipo,aCabProc,aTrbProc,aDadProc,cAlias)
LOCAL aAux := {}
LOCAL lRet := .T.

if cAlias == "BE2"
	BE2->(DbSetOrder(1))
	BE2->(MsSeek(xFilial("BE2")+cChave))
	STORE COLS "BE2" TO aAux FROM aCabProc VETTRAB aTrbProc While xFilial("BE2")+cChave == BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)
else
	B02->(DbSetOrder(1))
	B02->(MsSeek(xFilial("B02")+cChave))
	STORE COLS "B02" TO aAux FROM aCabProc VETTRAB aTrbProc While xFilial("B02")+cChave == B02->(B02_FILIAL+B02_OPEMOV+B02_ANOAUT+B02_MESAUT+B02_NUMAUT)
endif

If Len(aAux) == 0 .and. cAlias == "BE2"
   Help("",1,"PLS090ITEN")
   Return
   lRet := .F.
Endif

aDadProc := aClone(aAux)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A090Finalo³ Autor ³ Daher 		        ³ Data ³ 20.04.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibir dados da autorizacao/liberacao efetuada             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function A090Finalo(cOpeMov,cAnoAut,cMesAut,cNumAut,aRetorno,oBrwPro)
LOCAL lAuditoria := aRetorno[9]
LOCAL cNomUser
LOCAL cSIM
LOCAL cNAO
LOCAL cNomRDA
LOCAL oDlg
LOCAL cMsgTaxa  := STR0027                        //"Valor da Taxa Administracao    R$"
LOCAL oFontNum
LOCAL oFontAutor
LOCAL oFontTit
LOCAL oSay
LOCAL nItensSIM := 0
LOCAL nItensNAO := 0
LOCAL nVlrPF
LOCAL nVlrBPF
LOCAL nVlrTPF
LOCAL nVlrTAD
LOCAL nPercPF
LOCAL aVlrPF
LOCAL nColAut
LOCAL oBot01,oBot02, oBot03
LOCAL __cDescri := STR0028 //"Autorização"
LOCAL lJaCobLib := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define fontes utilizadas somente nesta funcao...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFontNum NAME "Arial" SIZE 000,-016 BOLD
DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-019 BOLD
DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011 BOLD

If lAuditoria
   Aviso( STR0029, ; //"Auditoria"
          STR0030,; //"Esta guia foi gravada e esta sendo analisada pela auditoria."
          { STR0090 }, 2 )
   Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ponto de entrada para poder trocar a msg de taxa de administracao...     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PLS090F1")
   cMsgTaxa := ExecBlock("PLS090F1",.F.,.F.)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra Resumo da Autorizacao...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE STR0031 FROM 009,000 TO 024,070 OF GetWndDefault() //"Dados da Autorização"

nColAut := PLRETPOS("BE2_IMGSTA",oBrwPro:aHeader)

aEval(oBrwPro:aCols,{ |aVet|  IF(!aVet[Len(oBrwPro:aHeader)+1],If(AllTrim(aVet[nColAut])=="ENABLE",nItensSIM++,nItensNAO++),nil) })

cNomUser := TransForm(M->B01_USUARI,PesqPict("B01","B01_USUARI"))+" - "+M->B01_NOMUSR
cNomRDA  := TransForm(M->B01_CODRDA,PesqPict("B01","B01_CODRDA"))+" - "+M->B01_NOMRDA
cSIM     := StrZero(nItensSIM,2)
cNAO     := StrZero(nItensNAO,2)

If M->B01_GUIACO == "1" //Guia comprada
      If M->B01_QUACOB == "1" //No Ato
         oBot02 := SButton():New(097, 035, 4, {|| PLSA090Bxt()},,.T.)
         oBot02:cToolTip := STR0032 //"Baixar Titulo a Receber Vinculado a Guia" //"Baixar Titulo a Receber Vinculado a Guia"
      Else
         oBot02 := SButton():New(097, 035, 6, {|| Pergunte("PLA090",.F.),lImpGuiDir:=(mv_par01==1),Eval(bImpGuia),If(lImpGuiDir,oDlg:End(),nil) },,.T.)
         oBot02:cToolTip := STR0033+__cDescri //"Imprimir a " //"Imprimir a "
      Endif
Else
      oBot02 := SButton():New(097, 035, 6, {|| Pergunte("PLA090",.F.),lImpGuiDir:=(mv_par01==1),Eval(bImpGuia),If(lImpGuiDir,oDlg:End(),nil) },,.T.)
      oBot02:cToolTip := STR0033+__cDescri //"Imprimir a " //"Imprimir a "
Endif

aVlrPF  := PLSVALCOPA()

nVlrPF  := aVlrPF[1]
nVlrBPF := aVlrPF[2]
nPercPF := aVlrPF[3]
nVlrTPF := aVlrPF[4]
nVlrTAD := aVlrPF[5]

If Len(aRetorno) > 10
	lJaCobLib := aRetorno[11]
EndIf

If nVlrPF > 0 .And. (M->B01_CODRDA <> GetNewPar("MV_PLSRDAG","999999") .Or. GetNewPar("MV_PLSCOLI",.F.) ) .And. !lJaCobLib
      If GetNewPar("MV_PLSEXPF","1") == "1"
         If GetNewPar("MV_PLSEXBT","1") == "1"
            If M->B01_GUIACO <> "1"
               @ 063,151 SAY oSay PROMPT STR0034 SIZE 220,010 OF oDlg PIXEL //"Valor da Co-Participacao       R$" //"Valor da Co-Participacao       R$"
            Else
               @ 063,151 SAY oSay PROMPT STR0035 SIZE 220,010 OF oDlg PIXEL       //"Valor da Compra                R$" //"Valor da Compra                R$"
            Endif
            @ 063,230 SAY oSay PROMPT Round(nVlrPF,2) PICTURE PLPMONEY_P   SIZE 030,010 OF oDlg PIXEL FONT oFontTit COLOR CLR_HBLUE

            If nVlrTAD > 0
               @ 080,151 SAY oSay PROMPT cMsgTaxa SIZE 220,010 OF oDlg PIXEL

               @ 080,230 SAY oSay PROMPT Round(nVlrTAD,2) PICTURE PLPMONEY_P   SIZE 030,010 OF oDlg PIXEL FONT oFontTit COLOR CLR_HBLUE
            Endif
         Endif

         If M->B01_GUIACO <> "1"
            @ 097,151 SAY oSay PROMPT STR0036 SIZE 220,010 OF oDlg PIXEL //"Valor Total da Co-Participacao R$" //"Valor Total da Co-Participacao R$"
         Else
            @ 097,151 SAY oSay PROMPT STR0037 SIZE 220,010 OF oDlg PIXEL  //"Valor Total da Compra          R$" //"Valor Total da Compra          R$"
         Endif
         @ 097,230 SAY oSay PROMPT Round(nVlrTPF,2)  PICTURE PLPMONEY_P   SIZE 030,010 OF oDlg PIXEL FONT oFontTit COLOR CLR_HBLUE

         @ 105,151 SAY oSay PROMPT STR0038 SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED //"(*) Nao inclui valores de materiais e medicamentos." //"(*) Nao inclui valores de materiais e medicamentos."
      Endif
Endif

oBot01 := SButton():New(097, 005, 1, {|| oDlg:End() },,.T.)
oBot01:cToolTip := STR0039 //"Fechar Tela" //"Fechar Tela"

oBot03 := SButton():New(097, 065, 5, {|| Pergunte("PLA090",.T.),lImpGuiDir:=(mv_par01==1) },,.T.)
oBot03:cToolTip := STR0040 //"Parametros Impressao" //"Parametros Impressao"

@ 007,005 SAY oSay PROMPT __cDescri+" "+STR0041  SIZE 220,010 OF oDlg PIXEL FONT oFontNum //" Numero   " //" Numero   "
@ 006,095 SAY oSay PROMPT cOpeMov+"."+cAnoAut+"."+cMesAut+"."+cNumAut SIZE 220,010 OF oDlg PIXEL FONT oFontAutor COLOR CLR_HRED

If nItensSIM > 0 .And. ! Empty(M->B01_SENHA)
   @ 005,230 SAY oSay PROMPT STR0042  SIZE 220,010 OF oDlg PIXEL //"Senha" //"Senha"
   @ 014,150 SAY oSay PROMPT "[ "+M->B01_SENHA+" ]" SIZE 220,010 OF oDlg PIXEL FONT oFontAutor COLOR CLR_HRED
Endif

@ 025,005 SAY oSay PROMPT STR0043  SIZE 220,010 OF oDlg PIXEL //"Usuario              " //"Usuario              "
@ 025,065 MSGET cNomUser                           SIZE 205,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

@ 043,005 SAY oSay PROMPT STR0044  SIZE 220,010 OF oDlg PIXEL //"Rede Atendimento     " //"Rede Atendimento     "
@ 043,065 MSGET cNomRDA                           SIZE 205,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

@ 061,005 SAY oSay PROMPT STR0045+IF(__cTipo=="1",STR0046,STR0047)+"s"  SIZE 220,010 OF oDlg PIXEL //"Itens "###"Autorizado"###"Liberado" //"Itens "###"Autorizado"###"Liberado"
@ 061,065 MSGET cSIM                               SIZE 004,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

@ 079,005 SAY oSay PROMPT STR0048+IF(__cTipo=="1",STR0046,STR0047)+"s"  SIZE 220,010 OF oDlg PIXEL  //"Itens NAO "###"Autorizado"###"Liberado" //"Itens NAO "###"Autorizado"###"Liberado"
@ 079,065 MSGET cNAO                               SIZE 004,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE


ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSNIVAut  ³ Autor ³ DAHER		      ³ Data ³ 22.10.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Exibe os tipos da RDA para uso em um F3                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ F3 BYQ                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Padrao do mBrowse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSNIVAut(cDado,cCampo,cTipo)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oDlg
LOCAL nOpca     := 0
LOCAL bOK       := { || nOpca := K_OK, oDlg:End() }
LOCAL bCancel   := { || oDlg:End() }
LOCAL oCritica
LOCAL cSQL
LOCAL aCritica  := {}
LOCAL nInd, nI
LOCAL bMarkF5	:= {|| PLMarkF5(oCritica) }

DEFAULT cCampo  := ""
DEFAULT cTipo	:= "1"
SetKey(VK_F5,bMarkF5)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ coloca virgula no comeco (caso tenha inicializador padrao)               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDado  := AllTrim(cDado)
If subs(cDado,len(cDado),1) != "," .AND. cDado != ""
	cDado += ","
Endif

If     cTipo == "1"
	SX5->(DbSetOrder(1))
	SX5->(MsSeek(xFilial("SX5")+"BH"))
	
	aSX5    := FWGetSX5("BH")
	nLenSX5 := LEN(aSX5)	
	FOR nI := 1 TO nLenSX5	
		aadd(aCritica,{aSX5[nI][3],aSX5[nI][4],if(alltrim(aSX5[nI][3]) $ cDado,.T.,.F.)})	
	NEXT
	
Elseif cTipo == "2"
	aadd(aCritica,{"1"  ,STR0049,if("1"   $ cDado,.T.,.F.)}) //"Distal"
	aadd(aCritica,{"2"  ,STR0050,if("2"   $ cDado,.T.,.F.)}) //"Mesial"
	aadd(aCritica,{"3"  ,STR0051,if("3"   $ cDado,.T.,.F.)}) //"Vestibular"
	aadd(aCritica,{"4"  ,STR0052,if("4"   $ cDado,.T.,.F.)}) //"Lingual/Palatino"
	aadd(aCritica,{"5"  ,STR0053,if("5"   $ cDado,.T.,.F.)}) //"Oclusal/Incisal"
Endif


DEFINE MSDIALOG oDlg TITLE STR0054 FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault() //"Regioes Autorizadas"

@ 020,012 SAY oSay PROMPT STR0055 SIZE 200,400 OF oDlg PIXEL COLOR CLR_HBLUE //"Regioes em que o procedimento pode ser/sera executado"
@ 027,012 SAY oSay PROMPT STR0056 SIZE 200,400 OF oDlg PIXEL COLOR CLR_HBLUE //"<F5> - Inverte selecao de todos os itens"

oCritica := TcBrowse():New( 039, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

oCritica:AddColumn(TcColumn():New(" ",{ || IF(aCritica[oCritica:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },;
         "@!",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))

oCritica:AddColumn(TcColumn():New(STR0057,{ || OemToAnsi(aCritica[oCritica:nAt,1]) },; //"Codigo"
         "@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))

oCritica:AddColumn(TcColumn():New(STR0058,{ || OemToAnsi(aCritica[oCritica:nAt,2]) },; //"Descricao"
         "@!",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))

oCritica:SetArray(aCritica)
oCritica:bLDblClick := { || aCritica[oCritica:nAt,3] := IF(aCritica[oCritica:nAt,3],.F.,.T.) }

ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

If nOpca == K_OK
   cDado := ""
   For nInd := 1 To Len(aCritica)
       If aCritica[nInd,3]
          cDado += alltrim(aCritica[nInd,1])+","
       Endif
   Next
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ tira a virgula do final                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if subs(cDado,len(cDado),1) == ","
	cDado := subs(cDado,1,len(cDado)-1)
endif

if !empty(cCampo)
	cCampo  := "M->"+cCampo
	&cCampo := cDado
endif

SET KEY VK_F5 TO
Return(cDado)

function PlGeObrPro()
return oBrwPro

static function PLMarkF5(oObj)

LOCAL nCnt
For nCnt := 1 To Len(oObj:aArray)
	If oObj:aArray[nCnt,3]
		oObj:aArray[nCnt,3]	 := .F.
	Else
		oObj:aArray[nCnt,3]	 := .T.
	Endif
Next

oObj:Refresh()
return

Function PLRetOProO()
Return oBrwPro

Function PLRetOCriO()
Return oBrwCri

Function PLRetOEnOd()
Return oEncAut
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS090IMA  ³ Autor ³ Tulio               ³ Data ³ 04.06.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a impressao de guias via menu                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS090Ima()
Eval(bImpGuia)
Return


Static Function A090PosArq()

BA3->(DbSetOrder(1))
BA3->(MsSeek(xFilial("BA3")+BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC)))

BD5->(DbSetOrder(1))
BD5->(MsSeek(xFilial("BD5")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)))
BD6->(DbSetOrder(1))
BD6->(MsSeek(xFilial("BD6")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)))

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090IMA
Executa a impressao de guias via menu

@author  PLS TEAM
@version P11
@since   04.06.03
/*/
//-------------------------------------------------------------------
Function PL090ODIMG()
	Eval(bImpG2)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSGRVEVEN³ Autor ³ Regiane R. Barreira   ³ Data ³ 10.11.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Atualiza array da pasta Dentes/Faces				  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³PLSGRVEVEN()		                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSGRVEVEN(aDentesFaces,oBrwEven,oBrwPro)
LOCAL nI	  := 1
LOCAL lfind   :=  .f.

For nI:=1 to Len(oBrwEven:aCols)
	If alltrim(cSeq) == alltrim(oBrwEven:aCols[nI][oBrwEven:FieldPos("BYS_SEQUEN")]) .or. Empty(oBrwEven:aCols[nI][oBrwEven:FieldPos("BYS_SEQUEN")])
        lfind :=  .t.
        exit
	Endif
Next

if !(lfind)
    obrweven:addblank()
    ni :=  len(obrweven:acols)
endif

oBrwEven:FieldPut("BYS_SEQUEN",cSeq,ni)
oBrwEven:FieldPut("BYS_CODIGO",M->BE2_DENREG,ni)

B04->(DbSetOrder(1))
If B04->(MsSeek(xFilial("B04")+M->BE2_DENREG))
	oBrwEven:FieldPut("BYS_DESCRI",B04->B04_DESCRI,ni)
	oBrwEven:FieldPut("BYS_TIPO",B04->B04_TIPO,ni)
	oBrwEven:FieldPut("BYS_SEGMEN",B04->B04_SEGMEN,ni)
	oBrwEven:FieldPut("BYS_DESSEG",B04->B04_DESSEG,ni)
	oBrwEven:FieldPut("BYS_M_ARCO",B04->B04_M_ARCO,ni)
	oBrwEven:FieldPut("BYS_DESARC",B04->B04_DESARC,ni)
EndIf

oBrwEven:FieldPut("BYS_FACES",M->BE2_FADENT,ni)
oBrwEven:FieldPut("BYS_CODPAD",M->BE2_CODPAD,ni)
oBrwEven:FieldPut("BYS_CODPSA",M->BE2_CODPRO,ni)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AtuVlComp ³ Autor ³ Tulio Cesar          ³ Data ³ 11.11.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function AtuVlComp(lValid)
LOCAL nFor
LOCAL nVlrComp := 0

For nFor := 1 To Len(oBrwPro:aCols)
    If lValid .And. n == nFor
          nVlrComp += M->BE2_VLCOMP
    Else
       If ! oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1]
          nVlrComp += oBrwPro:FieldGet("BE2_VLCOMP",nFor)
       Endif
    Endif
Next

If n > Len(oBrwPro:aCols)
   nVlrComp += M->BE2_VLCOMP
Endif

M->B01_VALOR := nVlrComp
lRefresh := .T.
oEncAut:oBox:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PLS90CRDB ºAutor  ³Otacilio A. Junior  º Data ³ 16/12/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa que Gera um Credito para a Rda de Metade do Valor º±±
±±º          ³ da Guia como um Adiantamento.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Desenvolvido conforme solicitacao UNIODONTO.               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLS90CRDB(cOPERDA,cCODRDA,cCODLDP,cCODPEG,cNUMGUI,cOPEUSR,cCODEMP,cMATRIC,cTIPREG,cCONEMP,cVERCON,cCODLANC,nOpc)

LOCAL lGrvLanc:= .T.
LOCAL nVlrPag := 0
LOCAL aArea   := GetArea()
LOCAL nPERC   := GetNewPar("MV_PLPEDIV",50)
LOCAL cTipoCT := ""
LOCAL cCodCli := ""
LOCAL cLojCli := ""

If nOpc == 3
	cSQL := "SELECT SUM(BD6_VLRPAG) AS VALOR FROM "+RetSQLName("BD6")+" WHERE "
	cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
	cSQL += "BD6_CODOPE = '"+cOPERDA+"' AND "
	cSQL += "BD6_CODLDP = '"+cCODLDP+"' AND "
	cSQL += "BD6_CODPEG = '"+cCODPEG+"' AND "
	cSQL += "BD6_NUMERO = '"+cNUMGUI+"' AND "
	cSQL += "BD6_NIVAUT <> '0  ' AND "
	cSQL += "D_E_L_E_T_ = '' "

	PLSQuery(cSQL,"TrbVal")

	nVlrPag := TrbVal->VALOR
EndIf

If (nVlrPag > 0 .Or. nOpc == 5 .Or. nOpc == 9 .Or. nOpc == 10)

	BA3->(DbSetOrder(1))
	BA3->(DbSeek(xFilial("BA3")+COPEUSR+CCODEMP+CMATRIC))
	BA1->(DbSetOrder(2))
	BA1->(DbSeek(xFilial("BA1")+COPEUSR+CCODEMP+CMATRIC+CTIPREG))
	aCliente := PLSAVERNIV(BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_MATRIC,IF(BA3->BA3_TIPOUS=="1","F","J"),;
				BA1->BA1_CONEMP,BA1->BA1_VERCON,BA1->BA1_SUBCON,BA1->BA1_VERSUB,nil,BA1->BA1_TIPREG,.F.)

	If aCliente[1,1] <> "ZZZZZZ"
		cCodCli		:= aCliente[1][1]//BA1->BA1_CODCLI
		cLojCli		:= aCliente[1][2]//BA1->BA1_LOJA
	EndIf
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojCli))
	cTipoCt:= SA1->A1_PESSOA

	BBB->(DbSetOrder(1))
	If ! BBB->(msSeek(xFilial("BBB")+cCodLanc))
		Return
	Endif

	If BBB->BBB_TIPSER == "1"
		BAU->(DbSetOrder(1))
		BAU->(msSeek(xFilial("BAU")+cCODRDA))

	    SIX->(DbSetOrder(1))
	    If SIX->(MsSeek("BGQ7"))
			BGQ->(DbSetOrder(7))
			If BGQ->(msSeek(xFilial("BGQ")+PlsIntPad()+cCODLDP+cCODPEG+cNUMGUI))
				While BGQ->(!EOF()) .AND. PlsIntPad()+cCODLDP+cCODPEG+cNUMGUI == ALLTRIM(BGQ->BGQ_GUIA)
		   		If EMPTY(BGQ->BGQ_OPELOT+BGQ->BGQ_NUMLOT)
			   		BGQ->(RecLock("BGQ",.F.))
			   		BGQ->(DbDelete())
			   		BGQ->(MsUnLock())
					lGrvLanc:= .F.
	   			EndIf
					BGQ->(DbSkip())
				End
			Else
				lGrvLanc:= .F.
			EndIf
		Else
				lGrvLanc:= .F.
		EndIf
 	EndIf

	If lGrvLanc
	   BGQ->(RecLock("BGQ",.T.))
	   BGQ->BGQ_FILIAL := xFilial("BGQ")
	   BGQ->BGQ_CODSEQ := GETSX8NUM("BGQ","BGQ_CODSEQ")
	   BGQ->BGQ_CODIGO := BAU->BAU_CODIGO
	   BGQ->BGQ_NOME   := BAU->BAU_NOME
	   If ALLTRIM(UPPER(FUNNAME())) == "PLSA0900"
	      BGQ->BGQ_ANO := BEA->BEA_ANOPAG
	      BGQ->BGQ_MES := BEA->BEA_MESPAG
	   Else
	      BGQ->BGQ_ANO := BD5->BD5_ANOPAG
	      BGQ->BGQ_MES := BD5->BD5_MESPAG
	   EndIf
	   BGQ->BGQ_CODLAN := BBB->BBB_CODSER
	   BGQ->BGQ_VALOR  := (nVLRPAG*nPerc)/100
	   BGQ->BGQ_TIPO   := BBB->BBB_TIPSER
	   BGQ->BGQ_TIPOCT := Iif(Empty(cTipoCT),BBB->BBB_TIPOCT,Iif(cTipoCT == "F","1","2"))
	   BGQ->BGQ_INCIR  := BBB->BBB_INCIR
	   BGQ->BGQ_INCINS := BBB->BBB_INCINS
	   BGQ->BGQ_INCPIS := BBB->BBB_INCPIS
	   BGQ->BGQ_INCCOF := BBB->BBB_INCCOF
	   BGQ->BGQ_INCCSL := BBB->BBB_INCCSL
	   BGQ->BGQ_VERBA  := BBB->BBB_VERBA
	   BGQ->BGQ_CODOPE := PlsIntPad()
	   BGQ->BGQ_CONMFT := BBB->BBB_CONMFT
	   BGQ->BGQ_OBS    := STR0060 //"GERADO PELA ROTINA DE ADIANTAMENTO DE PAGAMENTO"
	   BGQ->BGQ_LANAUT := "1"
       BGQ->BGQ_OPELAU := ""
	   BGQ->BGQ_NUMLAU := "" //Sera gravado quando o titulo for gerado...
	   BGQ->BGQ_INTERC := "0"
	   BGQ->BGQ_GUIA   := PlsIntPad()+cCODLDP+cCODPEG+cNUMGUI
	   BGQ->(msUnLock())
	   ConfirmSX8()
    EndIf
EndIf
If nOpc == 3
	TrbVal->(DbCloseArea())
EndIf
RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA090ACC³ Autor ³ Daher           		³ Data ³ 13.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA090ACC(aDadCri,aCabCri,aTrbCri,aHisCri,oBrwCri,cSequen,cAliasCri,oBrwPro)
LOCAL nFor
LOCAL cCodGlo
LOCAL cDesGlo
LOCAL lFirst  := .T.

For nFor := 1 To Len(aHisCri)
    cCodGlo := aHisCri[nFor,1]
    cDesGlo := aHisCri[nFor,2]

    If !lFirst
       oBrwCri:AddBlank()
       oBrwCri:SetPos(Len(oBrwCri:aCols))
    Else
		If Len(oBrwCri:aCols)  > 1
			oBrwCri:AddBlank()
		Endif
	    oBrwCri:SetPos(Len(oBrwCri:aCols))
	    lFirst := .F.
    Endif
    oBrwCri:FieldPut(cAliasCri+"_SEQUEN",cSequen)
    oBrwCri:FieldPut(cAliasCri+"_CODGLO",cCodGlo)
    oBrwCri:FieldPut(cAliasCri+"_DESGLO",cDesGlo)

    nFor ++
    While nFor <= Len(aHisCri) .And. Empty(aHisCri[nFor,1])
          oBrwCri:AddBlank()
          oBrwCri:SetPos(Len(oBrwCri:aCols))
          oBrwCri:FieldPut(cAliasCri+"_SEQUEN",cSequen)
          oBrwCri:FieldPut(cAliasCri+"_CODGLO","")
          oBrwCri:FieldPut(cAliasCri+"_DESGLO",aHisCri[nFor,2])
          oBrwCri:FieldPut(cAliasCri+"_INFGLO",aHisCri[nFor,3])
    nFor ++
    Enddo
    nFor --
Next
aDadCri := oBrwCri:aCols
aCabCri := oBrwCri:aHeader
aTrbCri := oBrwCri:aVetTrab
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA090COR³ Autor ³ Tulio Cesar           ³ Data ³ 13.06.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Muda a cor do browse de acordo com a autorizacao...        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA090CoO(nLinha,aHeaderEd,aColsEd)
LOCAL nPos := PLRETPOS("BE2_IMGSTA",aHeaderEd,.F.)

If nPos > 0
   aColsEd[nLinha,nPos] := If(M->BE2_STATUS=="1","ENABLE","DISABLE")
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Bkp do browse criticas													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aMatCBkp := aClone(oBrwCri:aCols)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Otacilio A. Junior    ³ Data ³01/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa??o a ser efetuada:                        ³±±
±±³          ³	   1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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

Static Function MENUDEF(CTIPOROT,ACORES)
LOCAL aPtoEntrada

Local  aRotConh     := {{STR0107 , "Pls090ODBco('C')", 0, 0}, ;//"Guia"
		                 {STR0108 , "Pls090ODBco('I')", 0, 0}} //"Item"

local cInteracao

cInteracao := "PLSAINTE('BE2','13', 'BEA->BEA_OPEMOV' , 'BEA->BEA_ANOAUT' , 'BEA->BEA_MESAUT' , 'BEA->BEA_NUMAUT' )"


Private aRotina:= {	{ STR0064			,'AxPesqui'			,0 ,K_Pesquisar	    ,0 ,.F. },; //"Pesquisar"
							{ STR0065	,'PLS090OMov'		,0 ,K_Visualizar	,0 ,Nil },; //"Visualizar"
							{ STR0066	,'PLS090OMov'		,0 ,K_Incluir		,0 ,Nil },; //"Incluir"
							{ STR0067	,'NAODISP'			,0 ,K_Alterar		,0 ,Nil },; //"Nao Disponivel"
							{ STR0068	,'PLS090OMov'		,0 ,K_Excluir		,0 ,Nil },; //"Excluir"
							{ STR0093	,'PLS090OMov'		,0 ,K_Incluir		,0 ,Nil },;   //"Copiar"
							{ STR0069	,'PLS090Ima'		,0 ,K_Imprimir		,0 ,Nil },; //"Imp.Guia"
							{ STR0070	,'PLSA090REC(.T.)'  ,0 ,K_ImpRec		,0 ,Nil },; //"Imp. Recibo"
							{ STR0071 	,'PLSA090Bxt'		,0 ,K_Visualizar	,0 ,Nil },; //"Baixar Tit"
							{ STR0072	,'PL090ODIMG'			,0 ,K_Imprimir	,0 ,Nil },;   //"Imp.Varias Guias"
							{ STR0073	,'PLSA090CAN(.F.)'	,0 ,K_Visualizar	,0 ,Nil },;  //"Cancelar Guia"
							{ STR0091	, aRotConh			,0 ,K_BCOCON		,0 ,Nil },;  //"Conhecimento"
							{ STR0102	, cInteracao		,0 ,K_Incluir		,0 ,Nil }}  //Interação

                     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Protocolo de Atendimento												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar("MV_PLRN395","0") == "1" 
	AaDd( aRotina,{ STR0109 ,'PL90InfPro("BEA")' , 0 , K_Alterar , 0 , Nil} ) //"Informar Protoc."
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para ponto de entrada													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PLS090M1")
	aPtoEntrada := ExecBlock("PLS090M1",.F.,.F.)
	AaDd( aRotina,{ aPtoEntrada[1] ,aPtoEntrada[2] , 0 , K_Imprimir , 0 , Nil} )
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para ponto de entrada													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PLS090M2")
	aPtoEntrada := ExecBlock("PLS090M2",.F.,.F.)
	AaDd( aRotina,{ aPtoEntrada[1] ,aPtoEntrada[2] , 0 , K_Imprimir , 0 , Nil} )
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para ponto de entrada													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("PLS090M3")
	aPtoEntrada := ExecBlock("PLS090M3",.F.,.F.)
	AaDd( aRotina,{ aPtoEntrada[1] ,aPtoEntrada[2] , 0 , K_Imprimir , 0 , Nil} )
Endif

//*******************************************************************************
If cTipoRot == "2" .And. BEA->(FieldPos("BEA_STALIB")) > 0
	Aadd(aRotina, { STR0087 , "PLSA090RAS", 0 , K_Imprimir     })	 //Rastrear
Endif

If ExistBlock("PLS090CR")
	aCores := ExecBlock( "PLS090CR",.F.,.F., aCores )
ElseIf cTipoRot == "2" .And. BEA->(FieldPos("BEA_STALIB")) > 0
       aCores 	:= 	{	{ "BEA->BEA_STALIB=='1'", 'BR_VERDE'    },; 
       					{ "BEA->BEA_STALIB=='2'", 'BR_VERMELHO' },;
       					{ "BEA->BEA_STALIB=='6'", 'BR_AZUL'     } }

       aCdCores := {	{ 'BR_VERDE'    ,STR0084},; //Liberação em aberto
       					{ 'BR_VERMELHO' ,STR0085},; //Liberação fechada
					 	{ 'BR_AZUL' ,STR0112} } //"Em análise pela auditoria"

       Aadd(aRotina, { STR0086    	 , "PLS090LOD"		, 0 , K_Incluir     }) //Legenda
Endif

Return(aRotina)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSGODMUD ³ Autor ³ Luciano Aparecido     ³ Data ³ 26.06.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Opção de escolha da guia a Imprimir...   			      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION PLSGODMUD()
LOCAL oRadio
LOCAL oDlg
LOCAL nRadio   	 := 1
LOCAL nOpca    	 := 0

DEFINE MSDIALOG oDlg FROM 0,0 TO 80,227 PIXEL TITLE STR0076 //"Qual Guia TISS deseja imprimir ?"

	@ 001,003 TO 040,080 LABEL STR0077 OF oDlg PIXEL //"Tratamento Odontológico :"
 	@ 008,008 RADIO oRadio VAR nRadio 3D SIZE 060,009 ITEMS STR0078,"Odonto"  PIXEL OF oDlg                  //"Situação Inicial"###"Cobrança"

	DEFINE SBUTTON FROM 003,084 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
	DEFINE SBUTTON FROM 020,084 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)

If nOpca == 1
	If nRadio == 1 .OR. nRadio == 2
   		PLSR431N({Alltrim(Str(nRadio))})
 	Endif
Endif


Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSFILREG ³ Autor ³ Daher			        ³ Data ³ 26.06.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao de campos autorizacao			   			      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSFILREG()
LOCAL cRet := "@#.T.@#"

If Type("M->BE2_CODPRO") == "C" .AND. Type("M->BE2_CODPAD")  == "C" .AND. Type("M->BE2_DENREG")  == "C"
	cRet := "@#B05_FILIAL == '"+xFilial("B05")+"' .AND. B05_CODPSA == '"+M->BE2_CODPRO+"' .AND. B05_CODPAD == '"+M->BE2_CODPAD+"'@#"
Endif

If Type("M->BD6_CODPRO") == "C" .AND. Type("M->BD6_CODPAD")  == "C" .AND. Type("M->BD6_DENREG")  == "C"
	cRet := "@#B05_FILIAL == '"+xFilial("B05")+"' .AND. B05_CODPSA == '"+M->BD6_CODPRO+"' .AND. B05_CODPAD == '"+M->BD6_CODPAD+"'@#"
Endif

If Type("M->B08_CODPSA") == "C" .AND. Type("M->B08_CODPAD")  == "C" .AND. Type("M->B08_DENREG")  == "C"
	cRet := "@#B05_FILIAL == '"+xFilial("B05")+"' .AND. B05_CODPSA == '"+M->B08_CODPSA+"' .AND. B05_CODPAD == '"+M->B08_CODPAD+"'@#"
Endif

If Type("M->B0N_CODPSA") == "C" .AND. Type("M->B0N_CODPAD")  == "C" .AND. Type("M->B0N_DENREG")  == "C"
	cRet := "@#B05_FILIAL == '"+xFilial("B05")+"' .AND. B05_CODPSA == '"+M->B0N_CODPSA+"' .AND. B05_CODPAD == '"+M->B0N_CODPAD+"'@#"
Endif

If Type("M->B09_CODPSA") == "C" .AND. Type("M->B09_CODPAD")  == "C" .AND. Type("M->B09_DENREG")  == "C"
	cRet := "@#B05_FILIAL == '"+xFilial("B05")+"' .AND. B05_CODPSA == '"+M->B09_CODPSA+"' .AND. B05_CODPAD == '"+M->B09_CODPAD+"'@#"
Endif

If Type("M->B87_CODPSA") == "C" .AND. Type("M->B87_CODPAD")  == "C" .AND. Type("M->B87_DENREG")  == "C"
	cRet := "@#B05_FILIAL == '"+xFilial("B05")+"' .AND. B05_CODPSA == '"+M->B87_CODPSA+"' .AND. B05_CODPAD == '"+M->B87_CODPAD+"'@#"
Endif

If Type("M->B45_CODPRO") == "C" .AND. Type("M->B45_CODPAD")  == "C" .AND. Type("M->B45_DENREG")  == "C"
	cRet := "@#B05_FILIAL == '"+xFilial("B05")+"' .AND. B05_CODPSA == '"+M->B45_CODPRO+"' .AND. B05_CODPAD == '"+M->B45_CODPAD+"'@#"
Endif

Return cRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSFILFAC ³ Autor ³ Daher			        ³ Data ³ 26.06.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao de campos autorizacao			   			      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSFILFAC()
LOCAL cRet := "@#.T.@#"

If Type("M->BE2_CODPRO") == "C" .AND. Type("M->BE2_CODPAD")  == "C" .AND. Type("M->BE2_DENREG")  == "C"
	cRet := "@#BYL_FILIAL == '"+xFilial("BYL")+"' .AND. BYL_CODPSA == '"+M->BE2_CODPRO+"' .AND. BYL_CODPAD == '"+M->BE2_CODPAD+"' .AND. BYL_CODIGO == '"+M->BE2_DENREG+"' @#"
Endif

If Type("M->BD6_CODPRO") == "C" .AND. Type("M->BD6_CODPAD")  == "C" .AND. Type("M->BD6_DENREG")  == "C"
	cRet := "@#BYL_FILIAL == '"+xFilial("BYL")+"' .AND. BYL_CODPSA == '"+M->BD6_CODPRO+"' .AND. BYL_CODPAD == '"+M->BD6_CODPAD+"' .AND. BYL_CODIGO == '"+M->BD6_DENREG+"' @#"
Endif

If Type("M->B09_CODPSA") == "C" .AND. Type("M->B09_CODPAD")  == "C" .AND. Type("M->B09_DENREG")  == "C"
	cRet := "@#BYL_FILIAL == '"+xFilial("BYL")+"' .AND. BYL_CODPSA == '"+M->B09_CODPSA+"' .AND. BYL_CODPAD == '"+M->B09_CODPAD+"' .AND. BYL_CODIGO == '"+M->B09_DENREG+"' @#"
Endif

If Type("M->B87_CODPSA") == "C" .AND. Type("M->B87_CODPAD")  == "C" .AND. Type("M->B87_DENREG")  == "C"
	cRet := "@#BYL_FILIAL == '"+xFilial("BYL")+"' .AND. BYL_CODPSA == '"+M->B87_CODPSA+"' .AND. BYL_CODPAD == '"+M->B87_CODPAD+"' .AND. BYL_CODIGO == '"+M->B87_DENREG+"' @#"
Endif

If Type("M->B45_CODPRO") == "C" .AND. Type("M->B45_CODPAD")  == "C" .AND. Type("M->B45_DENREG")  == "C"
	cRet := "@#BYL_FILIAL == '"+xFilial("BYL")+"' .AND. BYL_CODPSA == '"+M->B45_CODPRO+"' .AND. BYL_CODPAD == '"+M->B45_CODPAD+"' .AND. BYL_CODIGO == '"+M->B45_DENREG+"' @#"
Endif

Return cRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PlVlOOk   ³ Autor ³ Daher			        ³ Data ³ 26.06.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 											   			      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlVlOOk()
LOCAL lRet 	  := .T.
LOCAL cAliIte := "BE2"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se tem dente a ser informado									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
B05->( DbSetORder(1) )//B05_FILIAL + B05_CODPAD + B05_CODPSA + B05_CODIGO + B05_TIPO
If B05->( MsSeek( xFilial("B05")+&("M->"+cAliIte+"_CODPAD")+&("M->"+cAliIte+"_CODPRO") ) ) .And. Empty( &("M->"+cAliIte+"_DENREG") )
	MsgStop(STR0083) //"Será necessário informar o(s) dente/região(s) dentária(s) para este procedimento."
	lRet := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se tem face a ser informado									 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BYL->( DbSetOrder(1) )
If BYL->( MsSeek( xFilial("BYL")+&("M->"+cAliIte+"_CODPAD")+&("M->"+cAliIte+"_CODPRO")+&("M->"+cAliIte+"_DENREG") ) ) .And. Empty( &("M->"+cAliIte+"_FADENT") )
	MsgStop(STR0081) //"Será necessário informar a(s) face(s) dentária(s) para este procedimento."
	lRet := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fim da Funcao															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSVLDODO ³ Autor ³ Daher			        ³ Data ³ 26.06.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao de campos autorizacao			   			      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVLDODO()
LOCAL lRet 		:= .F.
local aRet		:= {}

If Readvar() == "M->BE2_DENREG"
	If !Empty(M->BE2_DENREG)
		B04->(DbSetOrder(1))
		B04->(MsSeek(xFilial("B04")+M->BE2_DENREG))
		lRet := ExistCpo("B05",M->BE2_CODPAD+M->BE2_CODPRO+M->BE2_DENREG) .and. ExistCpo("B04",M->BE2_DENREG)
		If lRet
			M->BE2_DESREG := B04->B04_DESCRI
			M->BE2_FADENT := Space(TamSx3("BE2_FADENT")[1])
			M->BE2_FACDES := Space(TamSx3("BE2_FACDES")[1])
		Endif
	Else
		M->BE2_DESREG := Space(TamSx3("BE2_DESREG")[1])
		M->BE2_FADENT := Space(TamSx3("BE2_FADENT")[1])
		M->BE2_FACDES := Space(TamSx3("BE2_FACDES")[1])
		lRet := .T.
	Endif
EndIf

If Readvar() == "M->BD6_DENREG"
	If !Empty(M->BD6_DENREG)
		B04->(DbSetOrder(1))
		B04->(MsSeek(xFilial("B04")+M->BD6_DENREG))
		lRet := ExistCpo("B05",M->BD6_CODPAD+M->BD6_CODPRO+M->BD6_DENREG) .and. ExistCpo("B04",M->BD6_DENREG)
		If lRet
			M->BD6_DESREG := B04->B04_DESCRI
			M->BD6_FADENT := space(TamSx3("BE2_FADENT")[1])
			M->BD6_FACDES := space(TamSx3("BE2_FACDES")[1])
		Endif
	Else
		M->BD6_DESREG := space(TamSx3("BE2_DESREG")[1])
		M->BD6_FADENT := space(TamSx3("BE2_FADENT")[1])
		M->BD6_FACDES := space(TamSx3("BE2_FACDES")[1])
		lRet := .T.
	Endif
Endif

If Readvar() == "M->BE2_FADENT"
	If !Empty(M->BE2_FADENT)
		aRet := PlLpzFrmVl(M->BE2_FADENT)
		if (aRet[1] .and. aRet[2])
			lRet := .t.
			M->BE2_FADENT := padr(aRet[4], TamSx3("BE2_FADENT")[1], "")
			M->BE2_FACDES := aRet[3]
		else
			MsgAlert(STR0113 + CHR(10) + CHR(13) + STR0114, STR0024) //Não localizada a(s) face(s) informada(s). - Digite uma ou mais faces válidas! - Atenção
			M->BE2_FADENT := space(TamSx3("BE2_FADENT")[1])	
			M->BE2_FACDES := ""
		endif
	Else
		M->BE2_FACDES := ""
		lRet := .T.
	Endif
Endif

If Readvar() == "M->BD6_FADENT"
	If !Empty(M->BD6_FADENT)
		B09->(DbSetOrder(1))
		B09->(MsSeek(xFilial("B09")+M->BD6_FADENT))
		lRet := ExistCpo("BYL",M->BD6_CODPAD+M->BD6_CODPRO+M->BD6_DENREG+B04->B04_TIPO+M->BD6_FADENT) .And. ExistCpo("B09",M->BD6_FADENT)
		If lRet
			M->BD6_FACDES := B09->B09_FACDES
		Endif
	Else
		M->BD6_FACDES := ""
		lRet := .T.
	Endif
Endif

//tabela B45
If Readvar() == "M->B45_DENREG"
	If !Empty(M->B45_DENREG)
		B04->(DbSetOrder(1))
		B04->(MsSeek(xFilial("B04")+M->B45_DENREG))
		lRet := ExistCpo("B05",M->B45_CODPAD+M->B45_CODPRO+M->B45_DENREG) .and. ExistCpo("B04",M->B45_DENREG)
		If lRet
			M->B45_DESREG := B04->B04_DESCRI
			M->B45_FADENT := Space(TamSx3("B45_FADENT")[1])
			M->B45_FACDES := Space(TamSx3("B45_FACDES")[1])
		Endif
	Else
		M->B45_DESREG := Space(TamSx3("B45_DESREG")[1])
		M->B45_FADENT := Space(TamSx3("B45_FADENT")[1])
		M->B45_FACDES := Space(TamSx3("B45_FACDES")[1])
		lRet := .T.
	Endif
EndIf

If Readvar() == "M->B45_FADENT"
	If !Empty(M->B45_FADENT)
		B09->(DbSetOrder(1))
		B09->(MsSeek(xFilial("B09")+M->B45_FADENT))
		lRet := ExistCpo("BYL",M->B45_CODPAD+M->B45_CODPRO+M->B45_DENREG+B04->B04_TIPO+M->B45_FADENT) .and. ExistCpo("B09",M->B45_FADENT)
		If lRet
			M->B45_FACDES := B09->B09_FACDES
		Endif
	Else
		M->B45_FACDES := ""
		lRet := .T.
	Endif
Endif

return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³plaodolib ³ Autor ³ Alexander		        ³ Data ³ 26.06.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Liberacao do Odontologico								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLAODOLIB(cNumLib,dDatPro)
LOCAL lRet 		:= .T.
LOCAL lRdaGen
LOCAL cCampoB01
LOCAL cCampoBEA
LOCAL nRow
LOCAL __nAux
LOCAL cField
LOCAL xField
LOCAL __nInd
LOCAL aDadRda    	:= PLSGETRDA()
LOCAL cCamposRDA := "BEA_CODRDA,BEA_CODLOC,BEA_CODESP,BEA_NOMRDA,BEA_TIPPRE,BEA_LOCAL,BEA_DESLOC,BEA_ENDLOC,BEA_DESESP"
LOCAL lRn395     := GetNewPar("MV_PLRN395","0") == "1"
LOCAL lInterProt := .F.
DEFAULT dDatPro  := dDataBase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica integridade do numero da liberacao...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("BEA")
BEA->(DbSetOrder(1))

If BEA->(MsSeek(xFilial("BEA")+cNumLib)) .And. BEA->BEA_ORIGEM == "2" .And. IF(BEA->(FieldPos("BEA_STALIB"))==0,.T.,BEA->BEA_STALIB=="1") .And. BEA->BEA_STATUS $ '1,2'
   lRdaGen 	  := ( BEA->BEA_CODRDA == GetNewPar("MV_PLSRDAG","999999") )
   __cCodRdaP := BEA->BEA_CODRDA

   BYS->(dbsetorder(1))
   BE2->(DbSetOrder(1))
   BE2->(MsSeek(xFilial("BE2")+cNumLib))
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Liberacao OK. Busco dados da da Enchoice (BE2)...                        ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   SX3->(MsSeek("BEA"))
   While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == "BEA"
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Campos chave nao podem ser atualizados...                                ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         IF AllTrim(SX3->X3_CAMPO) $ "BEA_ANOAUT,BEA_MESAUT,BEA_NUMAUT,BEA_MESAUT,BEA_ANOAUT,BEA_DATPRO"
            SX3->(DbSkip())
            Loop
         Endif
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Se a rda for generica nao atualiza dados da rda aqui na autorizacao...   ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         If lRdaGen .and. AllTrim(SX3->X3_CAMPO) $ cCamposRDA
            SX3->(DbSkip())
            Loop
         Endif
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Liberacao OK. Busco dados da da Enchoice (BEA)...                        ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         If (SX3->X3_CONTEXT <> "V")
            cCampoB01 := "M->B01_"+Subs(AllTrim(SX3->X3_CAMPO),5,10)
            cCampoBEA := "BEA->"+AllTrim(SX3->X3_CAMPO)

    		If cCampoBEA == 'BEA->BEA_HORPRO'
 				&cCampoB01 := M->B01_HORPRO
            Else
            	&cCampoB01 := &cCampoBEA
            EndIf

         Endif
   SX3->(DbSkip())
   Enddo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se e vai gerar um novo protocolo                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cNrProWeb)	
	If lRn395
		cNumProto := Space(20)
		If GetNewPar("MV_PLSUNI","1") == "1" .And. BEA->BEA_CODEMP == GetNewPar("MV_PLSGEIN","0050")
			P773AutInc("B01",@cNumProto,nil,.T.,.F.,nil,nil,nil,BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO),.T.)         
			lInterProt := .T.
		Else
			P773AutInc("B01",@cNumProto,nil,nil,nil,nil,nil,nil,BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO),.T.)
		EndIf	
			
		If Empty(cNumProto) .And. !lInterProt 
			lRet := .F.
			Return(lRet)
		Endif	
    EndIf
EndIf    
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta dados do usuario...                                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   M->B01_USUARI := BEA->(BEA_OPEMOV+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG)

   BA1->(DbSetOrder(2))
   If BA1->(MsSeek(xFilial("BA1")+M->B01_USUARI))
      M->B01_USUARI := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
      M->B01_NOMUSR := BA1->BA1_NOMUSR
      M->B01_MATANT := BA1->BA1_MATANT
      M->B01_MATUSU := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
      If ! lRdaGen
         M->B01_CODLOC := BEA->(BEA_CODLOC+BEA_LOCAL)
      Endif
   Else
      Help("",1,"PLA090BA1")
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Atualiza Enchoice...                                                     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   lRefresh := .T.
   oEncAut:oBox:Refresh()
   oEncAut:oBox:SetFocus()
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Agora busco dados da GetDados...                                         ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   oBrwPro:aCols 	 := Array(1,Len(oBrwPro:aHeader)+1)
   nRow			 	 := 1

   oBrwEven:aCols 	 := Array(1,Len(oBrwEven:aHeader)+1)
   oBrwEven:aVetTrab := aClone(oBrwPro:aVetTrab)
   nRowBYS 			 := 1

   While ! BE2->( Eof() ) .And. BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == xFilial("BE2")+cNumLib

    	 If BE2->BE2_STATUS <> '1'
		     BE2->(DbSkip())
        	 Loop
         EndIf

         If BE2->(FieldPos("BE2_SALDO")) > 0 .And. BE2->BE2_SALDO == 0
            BE2->(DbSkip())
            Loop
         EndIf

         If ! Empty(BE2->BE2_NUMINT)
            BE2->(DbSkip())
            Loop
         EndIf

         If nRow > Len(oBrwPro:aCols)
            oBrwPro:AddBlank()
         EndIf

   		If GetNewPar("MV_PLSLIBE","0") == "1"
			BE2->(DbSkip())
			Loop
		EndIf

         __nInd := 1
         For __nInd := 1 To Len(oBrwPro:aHeader)
             If oBrwPro:aHeader[__nInd,2] == "BE2_QTDSOL" .And. oBrwPro:FieldPos("BE2_QTDSOL") > 0
                oBrwPro:FieldPut("BE2_QTDSOL",BE2->BE2_QTDPRO,nRow)
                Loop
             EndIf

             If oBrwPro:aHeader[__nInd,2] == "BE2_SALDO"
                oBrwPro:FieldPut("BE2_SALDO",0,nRow)
                Loop
             EndIf

             If oBrwPro:aHeader[__nInd,2] == "BE2_QTDPRO"
                oBrwPro:FieldPut("BE2_QTDPRO",BE2->BE2_SALDO,nRow)
                Loop
             EndIf

             If oBrwPro:aHeader[__nInd,10] <> "V"
                cField := "BE2->"+oBrwPro:aHeader[__nInd,2]
                cField := StrTran(cField,"BE2","BE2")

                If TYPE(cField) <> "U"
                   oBrwPro:aCols[nRow,__nInd] := &cField
                EndIf
             Else
                If     oBrwPro:aHeader[__nInd,8] == "C"
                       xField := ""
                ElseIf oBrwPro:aHeader[__nInd,8] == "N"
                       xField := 0
                ElseIf oBrwPro:aHeader[__nInd,8] == "D"
                       xField := ctod("")
                ElseIf oBrwPro:aHeader[__nInd,8] == "L"
                       xField := .F.
                EndIf

                oBrwPro:aCols[nRow,__nInd] := xField
             EndIf
         Next

         oBrwPro:aCols[nRow,Len(oBrwPro:aHeader)+1] := .F.
         oBrwPro:FieldPut("BE2_IMGSTA","ENABLE",nRow)
         oBrwPro:aVetTrab[nRow] := BE2->(Recno())

		 BYS->( MsSeek(xFilial("BYS")+cNumLib+BE2->BE2_SEQUEN) )
         while !BYS->( Eof() ) .And. BYS->(BYS_FILIAL+BYS_OPEMOV+BYS_ANOAUT+BYS_MESAUT+BYS_NUMAUT+BYS_SEQUEN) == xFilial("BYS")+cNumLib+BE2->BE2_SEQUEN

            if nRowBYS > Len(oBrwEven:aCols)
                oBrwEven:ADDBLANK()
            endif

	         __nInd := 1
	         For __nInd := 1 To Len(oBrwEven:aHeader)

                if oBrwEven:aHeader[__nInd,10] <> "V"

                    cField := "BYS->"+oBrwEven:aHeader[__nInd,2]
                    cField := StrTran(cField,"BYS","BYS")

                    if TYPE(cField)<>"U"
                        oBrwEven:aCols[nRowBYS,__nInd] := &cField
                    endif
                else
                    if oBrwEven:aHeader[__nInd,8]=="C"
                        xField := ""
                    elseif oBrwEven:aHeader[__nInd,8]=="N"
                        xField := 0
                    elseif oBrwEven:aHeader[__nInd,8]=="D"
                        xField := ctod("")
                    elseif oBrwEven:aHeader[__nInd,8]=="L"
                        xField :=  .F.
                    endif
                    oBrwEven:aCols[nRowBYS,__nInd] := xField
                endif
            next
            oBrwEven:aCols[nRowBYS, Len(oBrwEven:aHeader)+1] := .F.
         	oBrwEven:aVetTrab[nRowBYS] := BYS->( Recno() )

            BYS->(dbskip())
            nRowBYS++
         EndDo

   BE2->(DbSkip())
   nRow ++
   Enddo

   For __nInd := 1 To Len(oBrwPro:aCols)
       For __nAux := 1 To Len(oBrwPro:aHeader)
           If ValType(oBrwPro:aCols[__nInd,__nAux]) == "U"
              oBrwPro:aCols[__nInd,__nAux] := CriaVar(AllTrim(oBrwPro:aHeader[__nAux,2]))
           Endif
       Next
       oBrwPro:aCols[__nInd,Len(oBrwPro:aHeader)+1] := .F.
   Next

   for __nInd := 1 to  len(oBrwEven:aCols)
        for __nAux := 1 to  len(oBrwEven:aHeader)
            if valtype(oBrwEven:aCols[__nInd,__nAux])=="u"
                oBrwEven:aCols[__nInd,__nAux] := CriaVar( AllTrim(oBrwEven:aHeader[__nAux,2]))
            endif
        next
        oBrwEven:aCols[__nInd, Len(oBrwEven:aHeader)+1] :=  .F.
   next

   PLSA090USR(M->B01_USUARI,M->B01_DATPRO,M->B01_HORPRO,"B01",.F.)
   PLSA090RDA(M->B01_OPERDA,M->B01_CODRDA,"1",M->B01_DATPRO,M->B01_USUARI,M->B01_CODLOC,M->B01_CODESP,"B01",.F.,,,,,__ctipo,oBrwPro,oBrwCri)

   	// Atualiza os dados da guia juridica.
	If BEA->(FieldPos("BEA_GUIJUR")) > 0 // Se existir no BEA, vai existir no B01.
		PLSGUIJUR("B01_GUIJUR")
	Endif

   oBrwPro:ForceRefresh()

ElseIf BEA->(MsSeek(xFilial("BEA")+cNumLib)) .And. BEA->BEA_STATUS $ '5'
   	lRet := .F.
   	Help("",1,"PLLIBFIN")

Else
   	lRet := .F.
   	Help("",1,"PLNUMLIB")
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da funcao...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLS090lod ³ Autor ³ Alexander		        ³ Data ³ 26.06.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS090lod()

BrwLegenda(ccadastro,STR0082,acdcores)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLS090FIL ³ Autor ³ Alexander		       ³ Data ³ 26.06.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta o Filtro												    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS090FIL(cTipo)
LOCAL cFiltro := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Filtro original
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cFiltro := "BEA_FILIAL = '"+xFilial("BEA")+"' .and. BEA_TIPO = '4' .and. BEA_ORIGEM = '"+cTipo+"' "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Caso exista a necessidade de alterar o filtro
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If ExistBlock("PL090OFI")
	cFiltro := EXECBLOCK("PL090OFI", .F. , .F. ,{cFiltro, .T. })
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cFiltro

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Pls090ODBco³ Autor ³ Microsiga            º Data ³ 19/07/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Chama a rotina do Banco do Conhecimento.					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function Pls090ODBco(cOp)

Local aArea		:= GetArea()
Local aAreaBEA	:= BEA->(GetArea())
Local aRotBack  := aRotina
Local cQuery	:= ""
Local cIndex	:= ""
LOCAL cChaveInt  	:= BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
LOCAL cChaveAC9 := BEA->BEA_FILIAL+cChaveInt

Default cOp		:= "I" // C = Anexo vinculado ao cabeçalho  I = Anexo vinculado ao item

aRotina := {{STR0091,'MsDocument',0,3},{"Inclusão Rápida",'PLSDOcs',0,3}} //"Conhecimento"

BEA->( DbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + DTOS(BEA_DATPRO) + BEA_HORPRO
BEA->( MsSeek( xFilial("BEA") + cChaveInt ) )
If cOp == "I" // inclusão nos itens
	DbSelectArea("BE2")
	cIndex := CriaTrab(NIL,.F.)
	cQuery := "BE2_FILIAL == '" + xFilial("BE2") + "' "
	cQuery += " .And. BE2_OPEMOV == '" + BEA->BEA_OPEMOV + "'"
	cQuery += " .And. BE2_ANOAUT == '" + BEA->BEA_ANOAUT + "'"
	cQuery += " .And. BE2_MESAUT == '" + BEA->BEA_MESAUT + "'"
	cQuery += " .And. BE2_NUMAUT == '" + BEA->BEA_NUMAUT + "'"
	
	IndRegua("BE2",cIndex,BE2->(IndexKey()),,cQuery)
	
	If BE2->(!Eof())
		MaWndBrowse(0,0,300,600,STR0092,"BE2",,aRotina,,,,.T.,,,,,,.F.) //"Conhecimento - Liberação / Autorização Odontológica"
	EndIf
	
	If PLSALIASEX("B53")
	
		AC9->(DbSetOrder(2))//AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ, R_E_C_N_O_, D_E_L_E_T_
	
		If AC9->(dbSeek( xFilial("AC9") + "BE2" +xfilial('BE2')+cChaveAC9))
		    dbSelectArea("B53")
		    If B53->(dbSeek(xFilial("B53")+cChaveInt))
		      	If B53->B53_BANCON != '1'
			      	B53->(Reclock("B53",.F.))
					B53->B53_BANCON := '1'
					B53->(MsUnlock())
				EndIf
			EndIf
		else
				 dbSelectArea("B53")
		    If B53->(dbSeek(xFilial("B53")+cChaveInt))
		      If B53->B53_BANCON != '0'
			      	B53->(Reclock("B53",.F.))
					B53->B53_BANCON := '0'
					B53->(MsUnlock())
				EndIf
			EndIf
		EndIf
	EndIf
	
	BE2->(DbCloseArea())
	RetIndex( "BE2" )
	dbClearFilter()
	FErase( cIndex+OrdBagExt() )
Else
	MsDocument( "BEA", BEA->( RecNo() ), 2 )
EndIf

aRotina := aRotBack

dbSelectArea("BE2")
dbSetOrder(1)

RestArea(aAreaBEA)
RestArea(aArea)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA090OD ºAutor  ³Microsiga           º Data ³  08/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSACOPIA()

Local bCampo := { |nCPO| Field(nCPO) }
Local i      := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Copia os campos do produto de referˆncia para a mem¢ria. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("BEA")
For i := 1 To FCount()
			M->&(EVAL(bCampo,i)) := FieldGet(i)
//	aadd(aCopy,{FieldGet(i)})
Next i

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Pl090ODAuF³ Autor ³ Totvs		            ³ Data ³ 10.04.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retornar Critica Forcada									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pl090ODAuF()
Return aAutFor



//-------------------------------------------------------------------
/*/{Protheus.doc} PLPESINTODO 
Executa a consulta padrao (especifica)

@author  PLS 
@version P12
@since   14.02.16
/*/
//-------------------------------------------------------------------
Function PLPESINTODO()
Local cSql := ""
Local cWhr := ""
Local aIndices 	:= {}
Local aHeader 	:= {}
Local lRet		:= .F.
Local oConsulta	:= Nil
Local aArea := GetArea()

If AllTrim( TCGetDB() ) $ "POSTGRES/ORACLE" 
	cSQL := " SELECT (BE4_ANOINT||BE4_MESINT||BE4_NUMINT) INTERNACAO,(BE4_CODOPE||BE4_CODEMP||BE4_MATRIC||BE4_TIPREG||BE4_DIGITO) MATRIC,SUBSTR(BE4_DATPRO,7,2) || '/' || SUBSTR(BE4_DATPRO,5,2) || '/' || SUBSTR(BE4_DATPRO,1,4) BE4_DATPRO,SUBSTR(BE4_DTALTA,7,2) || '/' || SUBSTR(BE4_DTALTA,5,2) || '/' || SUBSTR(BE4_DTALTA,1,4) AS BE4_DTALTA FROM " + RetSQLName("BE4")
	cWhr := " WHERE BE4_FILIAL= '" + xFilial("BE4")+ "' AND  (BE4_CODOPE||BE4_CODEMP||BE4_MATRIC||BE4_TIPREG||BE4_DIGITO) = '"+M->B01_USUARI+"' AND  BE4_DATPRO <> ' ' AND BE4_DTALTA = ' ' AND D_E_L_E_T_ = ''"
Else
	cSQL := " SELECT  BE4_ANOINT+ BE4_MESINT+ BE4_NUMINT AS INTERNACAO,(BE4_CODOPE+ BE4_CODEMP+ BE4_MATRIC+ BE4_TIPREG+ BE4_DIGITO) AS MATRIC,SUBSTRING(BE4_DATPRO,7,2) + '/' +SUBSTRING(BE4_DATPRO,5,2)+ '/' + SUBSTRING(BE4_DATPRO,1,4) AS BE4_DATPRO,SUBSTRING(BE4_DTALTA,7,2) + '/' +SUBSTRING(BE4_DTALTA,5,2)+ '/' + SUBSTRING(BE4_DTALTA,1,4) AS BE4_DTALTA FROM " + RetSQLName("BE4")
	cWhr := " WHERE BE4_FILIAL= '" + xFilial("BE4")+ "' AND  (BE4_CODOPE+ BE4_CODEMP+ BE4_MATRIC+ BE4_TIPREG+ BE4_DIGITO) = '"+M->B01_USUARI+"' AND  BE4_DATPRO <> ' ' AND BE4_DTALTA = ' ' AND D_E_L_E_T_ = ''"
Endif
cSql += cWhr

//Monta a aHeader da consulta³
SX3->( dbSetOrder( 2 ) )
SX3->( dbGotop(  ) )
If SX3->( dbSeek( "BE4_NUMINT", .F. ) )
	Aadd(aHeader,{SX3->X3_TITULO,'BE4_ANOINT+BE4_MESINT+BE4_NUMINT'        ,SX3->X3_PICTURE,20,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"})
	aAdd( aIndices, {"BE4_NUMINT",SX3->X3_TITULO})
Endif

If SX3->( dbSeek( "BE4_MATRIC", .F. ) )
	Aadd(aHeader,{"Matricula",'BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO',SX3->X3_PICTURE,15,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"})
Endif

If SX3->( dbSeek( "BE4_DATPRO", .F. ) )
	Aadd(aHeader,{SX3->X3_TITULO,'BE4_DATPRO',SX3->X3_PICTURE,SX3->X3_TAMANHO	,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"})
Endif

If SX3->( dbSeek( "BE4_DTALTA", .F. ) )
	Aadd(aHeader,{SX3->X3_TITULO,'BE4_DTALTA',SX3->X3_PICTURE,SX3->X3_TAMANHO	,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"})
Endif


//Monta a consulta padrao³
oConsulta:=PlsIntSxb():New()
oConsulta:cTitle 		:= "CONSULTA" 					    							//Titulo da Consulta
oConsulta:cQuery 		:= cSql															//Query dos dados a serem apresentados
oConsulta:aIndex 		:= aIndices														//Indices disponiveis (deve usar os mesmos campos da query)
oConsulta:aHeader 		:= aHeader                      								//Header da grid presente consulta (deve usar os mesmos campos da query)
oConsulta:aReturn		:= {'BE4_ANOINT+BE4_MESINT+BE4_NUMINT'}	//Campos de retorno da consulta (deve usar os mesmos campos da query)
oConsulta:lDataBaseRM 	:= .T.															//Indica se a query eh executada na base do protheus ou da RM
oConsulta:Show()

//Coleta o retorno³
If Len(oConsulta:aRetSXB) > 0
	cCodIntSxb := oConsulta:aRetSXB[1]
	lRet:=.t.
EndIf

RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o    ³AjustaHlp ³ Autor ³Roger Cangianeli       ³ Data ³18.05.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Ajusta Helps 								          ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AjustaHlp()	               	                         ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                         ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function AjustaHlp()  
Local aHlpPor := {}
Local aHlpSpa := {}
Local aHlpEng := {}

Aadd (aHlpPor, STR0103 )//"Para este procedimento deve ser   "
Aadd (aHlpPor, STR0104 )//"efetuado o pagamento no Ato.      "
aHlpSpa := aHlpEng := aHlpPor
PutSX1Help("PPLLIBFIN",aHlpPor,aHlpEng,aHlpSpa,.T.)                                                              

aHlpPor := aHlpSpa := aHlpEng := {}
Aadd (aHlpPor, STR0105 )//"Realize o pagamento e retorne na  "
Aadd (aHlpPor, STR0106 )//"rotina.      "
aHlpSpa := aHlpEng := aHlpPor
PutSX1Help("SPLLIBFIN",aHlpPor,aHlpEng,aHlpSpa,.T.)                                                              

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} P90ODVldDF
 
@author  Renan Sakai
@version P12
@since   20/07/2018
/*/
//-------------------------------------------------------------------
Function P90ODVldDF(cTipo,cCodPad,cCodPro,cCodDen,cCodFace,lAutoma)    
Local lProTemDen := .F.    
Local lProTemFac := .F.  
Local lValid     := .F.
Local nTamCodPsa := TamSX3("B05_CODPSA")[1]
Local nTamCodDen := TamSX3("BYL_CODIGO")[1]      
Local nTamCodFac := TamSX3("BYL_FACE")[1]
Local cDesc      := ""
Local aCodFace	 := {}
Local i 		 := 1
Local nX		 := 1
Local cSQLFace	 := ""
Local cCod		 := ""
LOCAL cFaceNEnc	 := ""	//guarda as faces que não forem encontradas
Local cVerifBd	 := TCGetDB() //Retorna qual banco de dados está sendo utilizado
default lAutoma	 := .F.
Default cCodFace := ""


cCodPro := cCodPro+Space(nTamCodPsa - len(cCodPro) ) 
B05->(DbSetOrder(1))//B05_FILIAL+B05_CODPAD+B05_CODPSA+B05_CODIGO+B05_TIPO

//Verifica Dente
if cTipo == "D"
	//Primeiro verifico se o evento tem dente parametrizado
	if B05->(MsSeek(xFilial("B05")+cCodPad+cCodPro+"1")) 
		lProTemDen := .T.
		//Verifico se o dente informado e valido
		if !Empty(cCodDen) .And. B05->(MsSeek(xFilial("B05")+cCodPad+cCodPro+cCodDen))
			lValid := .T.
			BTQ->(DbSetOrder(1))//BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM
			if BTQ->(MsSeek(xFilial("BTQ")+"28"+cCodDen))
				cDesc := Alltrim(BTQ->BTQ_DESTER)
			endIf
		endIf     
	endIf	
	aRet := {lProTemDen,lValid,cDesc}

//Verifica Face
elseIf cTipo == "F"	
	aCodFace 	:= StrTokArr(cCodFace, "|")
	cCodFace := StrTran( cCodFace, "|" )
	//Posiciono no dente
	if B05->(MsSeek(xFilial("B05")+cCodPad+cCodPro))
		BYL->(DbSetOrder(1))//BYL_FILIAL+BYL_CODPAD+BYL_CODPSA+BYL_CODIGO+BYL_TIPO+BYL_FACE    
		cCodDen  := cCodDen +Space(nTamCodDen - len(cCodDen))
		//Primeiro verifico se o evento tem face parametrizada
	    if BYL->(MsSeek(xFilial("BYL")+cCodPad+cCodPro+cCodDen+B05->B05_TIPO))
	    	lProTemFac := .T.
  	    	cCodFace := cCodFace+Space(nTamCodFac - len(cCodFace))
	    	//Verifico se o conjunto de faces informado e valida
	    	if !Empty(cCodDen) .And. !Empty(cCodFace) 
				if BYL->(MsSeek(xFilial("BYL")+cCodPad+cCodPro+cCodDen+B05->B05_TIPO+cCodFace)) 
					lValid := .T.
					BTQ->(DbSetOrder(1))//BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM
					if BTQ->(MsSeek(xFilial("BTQ")+"32"+cCodFace))
						cDesc := Alltrim(BTQ->BTQ_DESTER)
						cCod  := Alltrim(BTQ->BTQ_CDTERM)
						aRet := {lProTemFac,lValid,cDesc,cCod,cFaceNEnc}
						Return aRet
					endIf 
				endif
			endif
			//Verificação digito a digito
			For nX:= 1 to Len(aCodFace)
				if BYL->(MsSeek(xFilial("BYL")+cCodPad+cCodPro+cCodDen+B05->B05_TIPO+aCodFace[nX]))
					lValid := .T.
				else
					iif (cFaceNEnc != "" .And. nX != 1, cFaceNEnc += " - ",)
					cFaceNEnc += aCodFace[nX]		//guarda as faces não encontradas para apresentar ao usuario
				endif
			Next

			if lValid .And. Empty(cFaceNEnc)
				cSQLFace := " SELECT BYL_FACE, BYL_DESFAC FROM "+RetSqlName("BYL")+" WHERE "
				cSQLFace += " BYL_FILIAL = '"+xFilial('BYL')+"' "
				cSQLFace += " AND BYL_CODPAD = '"+cCodPad+"' "
				cSQLFace += " AND BYL_CODPSA = '"+cCodPro+"' "
				cSQLFace += " AND BYL_CODIGO = '"+cCodDen+"' "
				If cVerifBd $ "ORACLE|POSTGRES"
					cSQLFace += " AND LENGTH(BYL_FACE) = "+cValToChar(Len(aCodFace))
				else
					cSQLFace += " AND LEN(BYL_FACE) = "+cValToChar(Len(aCodFace))
				endif
				cSQLFace += " AND BYL_FACE LIKE '%"+aCodFace[i]+"%'"
				For i:= 2 to Len(aCodFace)
					cSQLFace += " AND BYL_FACE LIKE '%"+aCodFace[i]+"%'"
				Next
				cSQLFace += " AND D_E_L_E_T_ = ' ' "

				cSQLFace := ChangeQuery(cSQLFace)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQLFace),"BYL2",.F.,.T.)
				if !BYL2->(Eof()) 
					cDesc := Alltrim(BYL2->BYL_DESFAC)
					cCod  := Alltrim(BYL2->BYL_FACE)
				endIf

				BYL2->(dbCloseArea())
			endIf	

			if lValid .And. Empty(cCod)
				i := 1
				cSQLFace := " SELECT B09_FADENT, B09_FACDES FROM "+RetSqlName("B09")+" WHERE "
				cSQLFace += " B09_FILIAL = '"+xFilial("B09")+"' "
				
				//Verifica a possibilidade de ser uma consulta de outros BD.
				If cVerifBd $ "ORACLE|DB2|POSTGRES|INFORMIX" .Or. lAutoma
					cSQLFace += " AND LENGTH(B09_FADENT) = '"+cValToChar(Len(aCodFace))+"' "
				Else
					cSQLFace += " AND LEN(B09_FADENT) = '"+cValToChar(Len(aCodFace))+"' " 
				EndIf

				cSQLFace += " AND B09_FADENT LIKE '%"+aCodFace[i]+"%'"
				For i:= 2 to Len(aCodFace)
					cSQLFace += " AND B09_FADENT LIKE '%"+aCodFace[i]+"%'"
				Next
				cSQLFace += " AND D_E_L_E_T_ = ' ' "

				cSQLFace := ChangeQuery(cSQLFace)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQLFace),"B092",.F.,.T.)
				if !B092->(Eof()) 
					cCod  := Alltrim(B092->B09_FADENT)
					cDesc := Alltrim(B092->B09_FACDES)
				endIf
				B092->(dbCloseArea())

				if Empty(cCod)
					lValid := .F.
				endIf

			endIf				
	    endIf
	endIf 
	aRet := {lProTemFac,lValid,cDesc,cCod,cFaceNEnc}
endIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLRetMlFcDentes
Pesquisa que permite múltipla seleção de faces
@since 07/2022
@version P12
/*/
//-------------------------------------------------------------------
function PLRetMlFcDentes()
Local aOpcoes 		:= {}
local aTamJan		:= FwGetDialogSize()
local cAliasTmp		:= GetNextAlias()	
local cFiltro		:= ""
local cDado			:= ""
local lRet			:= .f.
local lRetorBtn		:= .f.
local nTamCmp		:= TamSx3("BE2_FADENT")[1]
local nFor			:= 0

if Type("M->BE2_CODPRO") == "C" .AND. Type("M->BE2_CODPAD")  == "C" .AND. Type("M->BE2_DENREG")  == "C"
	cFiltro := "% BYL_CODPSA = '" + M->BE2_CODPRO + "' AND BYL_CODPAD = '" + M->BE2_CODPAD + "' "
	cFiltro += " AND BYL_CODIGO = '" + M->BE2_DENREG + "' %"
endif
	
BeginSql  Alias cAliasTmp
	SELECT BYL_FACE, BYL_DESFAC FROM %table:BYL% BYL
		WHERE 	BYL_FILIAL = %xFilial:BYL%
			AND %Exp:cFiltro% 
			AND BYL.%NotDel%
EndSql

If ( (cAliasTmp)->(!eof()) )
	While (cAliasTmp)->(!eof())
		aadd(aOpcoes, {alltrim((cAliasTmp)->BYL_FACE), (cAliasTmp)->BYL_DESFAC, .f.})
		(cAliasTmp)->(dbskip())
	EndDo
EndIf
(cAliasTmp)->(DbCloseArea())

if len(aOpcoes) > 0

	//Criação da Modal
	oPrinWnd := FWDialogModal():New()
	oPrinWnd:SetBackground(.t.)
	oPrinWnd:SetTitle(STR0021) //"Faces Dentarias" 
	oPrinWnd:SetFreeArea(aTamJan[4] * 0.2, aTamJan[3] * 0.2)
	oPrinWnd:EnableFormBar(.t.)
	oPrinWnd:SetEscClose(.t.)
	oPrinWnd:CreateDialog()
	oPrinWnd:addCloseButton({|| lRetorBtn := .t., oPrinWnd:oOwner:End() })

	oPainel := oPrinWnd:getPanelMain()

	oFwCamada := FwLayer():New()
	oFwCamada:init(oPainel,.F.) 
	oFwCamada:AddLine( "LINSUP",100, .F.)

	oLINSUP  := oFwCamada:GetLinePanel("LINSUP")

	//criação dos checkboxes
	oWinBrw := TcBrowse():New( 015, 005, aTamJan[4] * 0.195, aTamJan[3] * 0.170,,,, oLINSUP,,,,,,,,,,,, .F.,, .T.,, .F., )
	oWinBrw:AddColumn(TcColumn():New(" ",{ ||if(aOpcoes[oWinBrw:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },"@!",Nil,Nil,Nil,015,.T.,.T.,Nil,Nil,Nil,.T.,Nil))
	oWinBrw:AddColumn(TcColumn():New("Código",{ || OemToAnsi(aOpcoes[oWinBrw:nAt,1]) },"@!",Nil,Nil,Nil,020,.F.,.F.,Nil,Nil,Nil,.F.,Nil)) //Dias
	oWinBrw:AddColumn(TcColumn():New("Descrição",{ || OemToAnsi(aOpcoes[oWinBrw:nAt,2]) },"@!",Nil,Nil,Nil,020,.F.,.F.,Nil,Nil,Nil,.F.,Nil)) //Dias
	oWinBrw:SetArray(aOpcoes) 
	oWinBrw:bLDblClick := { || aOpcoes[oWinBrw:nAt,3] := Eval( { || nIteMar := 0, aEval(aOpcoes, {|x| Iif(x[3], nIteMar++, )}), Iif(nIteMar < 50 .Or. aOpcoes[oWinBrw:nAt, 3],if(aOpcoes[oWinBrw:nAt,3],.F.,.T.),.F.) })}

	oPrinWnd:Activate() 

	if lRetorBtn
		For nFor := 1 To Len(aOpcoes)
			cDado += iif( aOpcoes[nFor,3], alltrim(aOpcoes[nFor,1]), "") 
		Next
	endif
else
	MsgAlert(STR0115, STR0021) //"Não existem dados para a consulta." - "Faces Dentarias" 
endif	
M->BE2_FADENT := padr(cDado, nTamCmp, "") //item não selecionado retorna com asterisco, por isso, o tratamento.
lRet := .t.
return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PlLpzFrmVl
Realiza o ajuste na string da face digitada e chama a função que realiza a validação dos itens informados.
@since 07/2022
@version P12
/*/
//-------------------------------------------------------------------
static function PlLpzFrmVl(cChave)
local nFor		:= 0
local cStrFrm	:= ""
local aRetVld	:= {}

cChave := alltrim(strtran(cChave, "*", ""))  //devido ao retorno do f_opcoes
for nFor := 1 to len(cChave) 
	cStrFrm += SUBSTR(cChave, nFor, 1) + "|"
next

aRetVld := P90ODVldDF("F", M->BE2_CODPAD, M->BE2_CODPRO, M->BE2_DENREG, cStrFrm)
         
return aRetVld
